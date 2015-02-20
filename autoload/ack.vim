if exists('g:ack_use_dispatch')
  if g:ack_use_dispatch && !exists(':Dispatch')
    call s:Warn('Dispatch not loaded! Falling back to g:ack_use_dispatch = 0.')
    let g:ack_use_dispatch = 0
  endif
else
  let g:ack_use_dispatch = 0
end

function! ack#Ack(cmd, args)
  redraw

  let l:ackprg_run = g:ackprg
  let l:using_loclist = (a:cmd =~# '^l') ? 1 : 0

  " Format to match search output, like 'grepformat'. Include column number.
  let l:ackformat = '%f:%l:%c:%m,%f:%l:%m'

  if g:ack_use_dispatch && l:using_loclist
    call s:Warn('Dispatch does not support location lists! Proceeding with quickfix...')
    let l:using_loclist = 0
  endif

  if l:using_loclist
    let s:handler = g:ack_lhandler
    let s:apply_mappings = g:ack_apply_lmappings
    let l:wintype = 'l'
  else
    let s:handler = g:ack_qhandler
    let s:apply_mappings = g:ack_apply_qmappings
    let l:wintype = 'c'
  endif

  " If no pattern is provided, search for the word under the cursor
  if empty(a:args)
    let l:grepargs = expand("<cword>")
  else
    let l:grepargs = a:args . join(a:000, ' ')
  end

  " For :AckFile (the -g option -- find matching files, not lines), strip some
  " options that become meaningless and set match format accordingly.
  if a:cmd =~# '-g$'
    let l:ackformat = '%f'
    let l:ackprg_run = substitute(l:ackprg_run, '-H\|--column', '', 'g')

    " We don't execute a:cmd for Dispatch, so add the -g here instead
    if g:ack_use_dispatch
      let l:ackprg_run .= ' -g'
    endif
  endif

  let grepprg_bak = &grepprg
  let grepformat_bak = &grepformat
  let &grepprg=l:ackprg_run
  let &grepformat=l:ackformat

  echo "Searching ..."

  try
    " NOTE: we escape special chars, but not everything using shellescape to
    "       allow for passing arguments etc
    " TODO: we need to restore makeprg for dispatch just as we do grepprg
    if g:ack_use_dispatch
      let &l:errorformat = l:ackformat
      let &l:makeprg = l:ackprg_run . ' ' . escape(l:grepargs, '|#%')
      Make
    else
      silent execute a:cmd escape(l:grepargs, '|#%')
    endif
  finally
    let &grepprg=grepprg_bak
    let &grepformat=grepformat_bak
  endtry

  " Dispatch has no callback mechanism currently, we just have to display the
  " list window early and wait for it to populate :-/
  call ack#show_results(l:wintype)
  call s:highlight(l:grepargs)
endfunction

function! ack#show_results(wintype)
  execute s:handler
  call s:apply_maps(a:wintype)
  redraw!
endfunction

" wintype param is either 'l' for location list, or 'c' for quickfix
function! s:apply_maps(wintype)
  let l:closemap = ':' . a:wintype . 'close<CR>'

  let g:ack_mappings.q = l:closemap

  execute 'nnoremap <buffer> <silent> ? :call ack#quick_help(' . string(a:wintype) . ')<CR>'

  if s:apply_mappings && &ft == "qf"
    if g:ack_autoclose
      " We just map the 'go' and 'gv' mappings to close on autoclose, wtf?
      for key_map in items(g:ack_mappings)
        execute printf("nnoremap <buffer> <silent> %s %s", get(key_map, 0), get(key_map, 1) . l:closemap)
      endfor

      execute "nnoremap <buffer> <silent> <CR> <CR>" . l:closemap
    else
      for key_map in items(g:ack_mappings)
        execute printf("nnoremap <buffer> <silent> %s %s", get(key_map, 0), get(key_map, 1))
      endfor
    endif

    if exists("g:ackpreview") " if auto preview in on, remap j and k keys
      execute "nnoremap <buffer> <silent> j j<CR><C-W><C-W>"
      execute "nnoremap <buffer> <silent> k k<CR><C-W><C-W>"
    endif
  endif
endfunction

function! ack#quick_help(wintype)
  execute "edit " . globpath(&rtp, "doc/ack_quick_help.txt")

  silent normal gg
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal nomodifiable
  setlocal filetype=help
  setlocal nonumber
  setlocal norelativenumber
  setlocal nowrap
  setlocal foldlevel=20
  setlocal foldmethod=diff

  exec 'nnoremap <buffer> <silent> ? :q!<CR>:call ack#show_results(' . string(a:wintype) . ')<CR>'
endfunction

function! s:highlight(args)
  if !g:ackhighlight
    return
  endif

  let @/ = matchstr(a:args, "\\v(-)\@<!(\<)\@<=\\w+|['\"]\\zs.{-}\\ze['\"]")
  call feedkeys(":let &l:hlsearch=1 \| echo \<CR>", "n")
endfunction

function! ack#AckFromSearch(cmd, args)
  let search = getreg('/')
  " translate vim regular expression to perl regular expression.
  let search = substitute(search, '\(\\<\|\\>\)', '\\b', 'g')
  call ack#Ack(a:cmd, '"' . search . '" ' . a:args)
endfunction

function! s:GetDocLocations()
  let dp = ''
  for p in split(&rtp, ',')
    let p = p . '/doc/'
    if isdirectory(p)
      let dp = p . '*.txt ' . dp
    endif
  endfor

  return dp
endfunction

function! ack#AckHelp(cmd, args)
  let args = a:args . ' ' . s:GetDocLocations()
  call ack#Ack(a:cmd, args)
endfunction

function! ack#AckWindow(cmd, args)
  let files = tabpagebuflist()
  " remove duplicated filenames (files appearing in more than one window)
  let files = filter(copy(sort(files)), 'index(files,v:val,v:key+1)==-1')
  call map(files, "bufname(v:val)")
  " remove unnamed buffers as quickfix (empty strings before shellescape)
  call filter(files, 'v:val != ""')
  " expand to full path (avoid problems with cd/lcd in au QuickFixCmdPre)
  let files = map(files, "shellescape(fnamemodify(v:val, ':p'))")
  let args = a:args . ' ' . join(files)
  call ack#Ack(a:cmd, args)
endfunction

function! s:Warn(msg)
  echohl WarningMsg | echomsg 'Ack: ' . a:msg | echohl None
endf

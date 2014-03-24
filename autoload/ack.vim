function! ack#Ack(cmd, args)
  redraw
  echo "Searching ..."

  " If no pattern is provided, search for the word under the cursor
  if empty(a:args)
    let l:grepargs = expand("<cword>")
  else
    let l:grepargs = a:args . join(a:000, ' ')
  end
  let l:ackprg_run = g:ackprg

  " Format, used to manage column jump
  if a:cmd =~# '-g$'
    let g:ackformat="%f"
    if s:ackprg_version > 2
      " remove arguments that conflict with -g
      let l:ackprg_run = substitute(l:ackprg_run, '-H\|--column', '', 'g')
    endif
  else
    let g:ackformat="%f:%l:%c:%m,%f:%l:%m"
  endif

  let grepprg_bak = &grepprg
  let grepformat_bak = &grepformat
  let &grepprg=l:ackprg_run
  let &grepformat=g:ackformat

  try
    " NOTE: we escape special chars, but not everything using shellescape to
    "       allow for passing arguments etc
    silent execute a:cmd . " " . escape(l:grepargs, '|#%')
  finally
    let &grepprg=grepprg_bak
    let &grepformat=grepformat_bak
  endtry

  if a:cmd =~# '^l'
    let s:handler = g:ack_lhandler
    let s:apply_mappings = g:ack_apply_lmappings
    let s:close_cmd = ':lclose<CR>'
  else
    let s:handler = g:ack_qhandler
    let s:apply_mappings = g:ack_apply_qmappings
    let s:close_cmd = ':cclose<CR>'
  endif

  call <SID>show_results(a:cmd)
  call <SID>highlight(a:args)

  redraw!
endfunction

function! s:show_results(cmd)
  execute s:handler
  call <SID>apply_maps()
endfunction

function! s:apply_maps()
  let s:maps = {
        \ "q": s:close_cmd,
        \ "t": "<C-W><CR><C-W>T",
        \ "T": "<C-W><CR><C-W>TgT<C-W>j",
        \ "o": "<CR>",
        \ "O": "<CR><C-W><C-W>:ccl<CR>",
        \ "go": "<CR><C-W>j",
        \ "h": "<C-W><CR><C-W>K",
        \ "H": "<C-W><CR><C-W>K<C-W>b",
        \ "v": "<C-W><CR><C-W>H<C-W>b<C-W>J<C-W>t",
        \ "gv": "<C-W><CR><C-W>H<C-W>b<C-W>J" }

  if s:apply_mappings && &ft == "qf"
    if !exists("g:ack_autoclose") || !g:ack_autoclose
      for key_map in items(s:maps)
        execute printf("nnoremap <buffer> <silent> %s %s", get(key_map, 0), get(key_map, 1))
      endfor
    else
      for key_map in items(s:maps)
        execute printf("nnoremap <buffer> <silent> %s %s", get(key_map, 0), get(key_map, 1) . s:close_cmd)
      endfor
    endif

    if exists("g:ackpreview") " if auto preview in on, remap j and k keys
      execute "nnoremap <buffer> <silent> j j<CR><C-W><C-W>"
      execute "nnoremap <buffer> <silent> k k<CR><C-W><C-W>"
    endif
  endif
endfunction

function! s:highlight(args)
  if g:ackhighlight
    set hlsearch
    let @/ = substitute(a:args, '["'']', '', 'g')
    call feedkeys(":let &hlsearch=1\<CR>", "n")
  endif
endfunction

function! ack#AckFromSearch(cmd, args)
  let search =  getreg('/')
  " translate vim regular expression to perl regular expression.
  let search = substitute(search, '\(\\<\|\\>\)', '\\b', 'g')
  call ack#Ack(a:cmd, '"' .  search . '" ' . a:args)
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

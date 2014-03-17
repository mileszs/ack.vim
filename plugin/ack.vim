" NOTE: You must, of course, install the ack script
"       in your path.
" On Debian / Ubuntu:
"   sudo apt-get install ack-grep
" With MacPorts:
"   sudo port install p5-app-ack
" With Homebrew:
"   brew install ack

" Location of the ack utility
if !exists("g:ackprg")
  let s:ackcommand = executable('ack-grep') ? 'ack-grep' : 'ack'
  if !executable(s:ackcommand)
    finish
  endif
  let g:ackprg = s:ackcommand." -H --nocolor --nogroup --column"
endif

let s:ackprg_version = eval(matchstr(system(g:ackprg . " --version"),  '[0-9.]\+'))

if !exists("g:ack_apply_qmappings")
  let g:ack_apply_qmappings = !exists("g:ack_qhandler")
endif

if !exists("g:ack_apply_lmappings")
  let g:ack_apply_lmappings = !exists("g:ack_lhandler")
endif

if !exists("g:ack_qhandler")
  let g:ack_qhandler = "botright copen"
endif

if !exists("g:ack_lhandler")
  let g:ack_lhandler = "botright lopen"
endif

if !exists("g:ackhighlight")
  let g:ackhighlight = 0
end

function! s:Ack(cmd, args)
  redraw
  echo "Searching ..."

  " If no pattern is provided, search for the word under the cursor
  if empty(a:args)
    let l:grepargs = expand("<cword>")
  else
    let l:grepargs = a:args . join(a:000, ' ')
  end

  " Format, used to manage column jump
  if a:cmd =~# '-g$'
    let g:ackformat="%f"
  else
    let g:ackformat="%f:%l:%c:%m,%f:%l:%m"
  end

  let grepprg_bak=&grepprg
  let grepformat_bak=&grepformat
  try
    let l:ackprg_run = g:ackprg
    if a:cmd =~# '-g$' && s:ackprg_version > 2
      " remove arguments that conflict with -g
      let l:ackprg_run = substitute(l:ackprg_run, '-H\|--column', '', 'g')
    end
    let &grepprg=l:ackprg_run
    let &grepformat=g:ackformat
    " NOTE: we escape special chars, but not everything using shellescape to
    "       allow for passing arguments etc
    silent execute a:cmd . " " . escape(l:grepargs, '|#%')
  finally
    let &grepprg=grepprg_bak
    let &grepformat=grepformat_bak
  endtry

  if a:cmd =~# '^l'
    exe g:ack_lhandler
    let l:apply_mappings = g:ack_apply_lmappings
    let l:close_cmd = ':lclose<CR>'
  else
    exe g:ack_qhandler
    let l:apply_mappings = g:ack_apply_qmappings
    let l:close_cmd = ':cclose<CR>'
  endif

  if l:apply_mappings
    if !exists("g:ack_autoclose") || !g:ack_autoclose
      exec "nnoremap <silent> <buffer> q " . l:close_cmd
      exec "nnoremap <silent> <buffer> t <C-W><CR><C-W>T"
      exec "nnoremap <silent> <buffer> T <C-W><CR><C-W>TgT<C-W>j"
      exec "nnoremap <silent> <buffer> o <CR>"
      exec "nnoremap <silent> <buffer> O <CR><C-W><C-W>:ccl<CR>"
      exec "nnoremap <silent> <buffer> go <CR><C-W>j"
      exec "nnoremap <silent> <buffer> h <C-W><CR><C-W>K"
      exec "nnoremap <silent> <buffer> H <C-W><CR><C-W>K<C-W>b"
      exec "nnoremap <silent> <buffer> v <C-W><CR><C-W>H<C-W>b<C-W>J<C-W>t"
      exec "nnoremap <silent> <buffer> gv <C-W><CR><C-W>H<C-W>b<C-W>J"
    else
      exec "nnoremap <silent> <buffer> q " . l:close_cmd
      exec "nnoremap <silent> <buffer> t <C-W><CR><C-W>T" . l:close_cmd
      exec "nnoremap <silent> <buffer> T <C-W><CR><C-W>TgT<C-W>j" . l:close_cmd
      exec "nnoremap <silent> <buffer> o <CR>" . l:close_cmd
      exec "nnoremap <silent> <buffer> O <CR><C-W><C-W>:ccl<CR>" . l:close_cmd
      exec "nnoremap <silent> <buffer> go <CR><C-W>j" . l:close_cmd
      exec "nnoremap <silent> <buffer> h <C-W><CR><C-W>K" . l:close_cmd
      exec "nnoremap <silent> <buffer> H <C-W><CR><C-W>K<C-W>b" . l:close_cmd
      exec "nnoremap <silent> <buffer> v <C-W><CR><C-W>H<C-W>b<C-W>J<C-W>t" . l:close_cmd
      exec "nnoremap <silent> <buffer> gv <C-W><CR><C-W>H<C-W>b<C-W>J" . l:close_cmd
    endif

    " If auto preview in on, remap j and k keys
    if exists("g:ackpreview")
      exec "nnoremap <silent> <buffer> j j<CR><C-W><C-W>"
      exec "nnoremap <silent> <buffer> k k<CR><C-W><C-W>"
    endif
  endif

  " If highlighting is on, highlight the search keyword.
  if g:ackhighlight
    let @/ = substitute(l:grepargs,'["'']','','g')
    set hlsearch
  end

  redraw!
endfunction

function! s:AckFromSearch(cmd, args)
  let search =  getreg('/')
  " translate vim regular expression to perl regular expression.
  let search = substitute(search,'\(\\<\|\\>\)','\\b','g')
  call s:Ack(a:cmd, '"' .  search .'" '. a:args)
endfunction

function! s:GetDocLocations()
  let dp = ''
  for p in split(&rtp,',')
    let p = p.'/doc/'
    if isdirectory(p)
      let dp = p.'*.txt '.dp
    endif
  endfor
  return dp
endfunction

function! s:AckHelp(cmd,args)
  let args = a:args.' '.s:GetDocLocations()
  call s:Ack(a:cmd,args)
endfunction

function! s:AckWindow(cmd,args)
  let files = tabpagebuflist()
  " remove duplicated filenames (files appearing in more than one window)
  let files = filter(copy(sort(files)),'index(files,v:val,v:key+1)==-1')
  call map(files,"bufname(v:val)")
  " remove unnamed buffers as quickfix (empty strings before shellescape)
  call filter(files, 'v:val != ""')
  " expand to full path (avoid problems with cd/lcd in au QuickFixCmdPre)
  let files = map(files,"shellescape(fnamemodify(v:val, ':p'))")
  let args = a:args.' '.join(files)
  call s:Ack(a:cmd,args)
endfunction

command! -bang -nargs=* -complete=file Ack call s:Ack('grep<bang>',<q-args>)
command! -bang -nargs=* -complete=file AckAdd call s:Ack('grepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file AckFromSearch call s:AckFromSearch('grep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LAck call s:Ack('lgrep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LAckAdd call s:Ack('lgrepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file AckFile call s:Ack('grep<bang> -g', <q-args>)
command! -bang -nargs=* -complete=help AckHelp call s:AckHelp('grep<bang>',<q-args>)
command! -bang -nargs=* -complete=help LAckHelp call s:AckHelp('lgrep<bang>',<q-args>)
command! -bang -nargs=* -complete=help AckWindow call s:AckWindow('grep<bang>',<q-args>)
command! -bang -nargs=* -complete=help LAckWindow call s:AckWindow('lgrep<bang>',<q-args>)

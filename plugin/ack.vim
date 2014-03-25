" Location of the ack utility
if !exists("g:ackprg")
  if executable('ack')
    let g:ackprg = "ack"
  elseif executable('ack-grep')
    let g:ackprg = "ack-grep"
  else
    finish
  endif
  let g:ackprg .= " -s -H --nocolor --nogroup --column"
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
endif

if !exists("g:ack_autofold_results")
  let g:ack_autofold_results = 0
endif

command! -bang -nargs=* -complete=file Ack           call ack#Ack('grep<bang>', <q-args>)
command! -bang -nargs=* -complete=file AckAdd        call ack#Ack('grepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file AckFromSearch call ack#AckFromSearch('grep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LAck          call ack#Ack('lgrep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LAckAdd       call ack#Ack('lgrepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file AckFile       call ack#Ack('grep<bang> -g', <q-args>)
command! -bang -nargs=* -complete=help AckHelp       call ack#AckHelp('grep<bang>', <q-args>)
command! -bang -nargs=* -complete=help LAckHelp      call ack#AckHelp('lgrep<bang>', <q-args>)
command! -bang -nargs=* -complete=help AckWindow     call ack#AckWindow('grep<bang>', <q-args>)
command! -bang -nargs=* -complete=help LAckWindow    call ack#AckWindow('lgrep<bang>', <q-args>)

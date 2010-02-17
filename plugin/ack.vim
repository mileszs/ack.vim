" NOTE: You must, of course, install the ack script
"       in your path.
" On Ubuntu:
"   sudo apt-get install ack-grep
"   ln -s /usr/bin/ack-grep /usr/bin/ack
" With MacPorts:
"   sudo port install p5-app-ack

let g:ackprg="ack -H --nocolor --nogroup"

function! s:Ack(cmd, args)
    let grepprg_bak=&grepprg
    let &grepprg = g:ackprg

    redraw
    echo "Searching ..."
    execute "silent! " . a:cmd . " " . a:args

    if a:cmd =~# '^l'
        botright lopen
    else
        botright copen
    endif
    let &grepprg=grepprg_bak
    exec "redraw!"
endfunction

function! s:AckFromSearch(args)
  let search =  getreg('/')
  " interprete vim regular expression to perl regular expression.
  let search = substitute(search,'\(\\<\|\\>\)','\\b','g')
  cal s:Ack("grep", '"' .  search .'" '. a:args)
endfunction

command! -nargs=* -complete=file Ack call s:Ack('grep',<q-args>)
command! -nargs=* -complete=file AckAdd call s:Ack('grepadd', <q-args>)
command! -nargs=* -complete=file AckFromSearch  :call s:AckFromSearch(<q-args>)
command! -nargs=* -complete=file LAck call s:Ack('lgrep', <q-args>)
command! -nargs=* -complete=file LAckAdd call s:Ack('lgrepadd', <q-args>)

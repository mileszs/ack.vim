" NOTE: You must, of course, install the ack script
"       in your path.
" On Ubuntu:
"   sudo apt-get install ack-grep
"   ln -s /usr/bin/ack-grep /usr/bin/ack
" With MacPorts:
"   sudo port install p5-app-ack

let g:ackprg="ack\\ -H\\ --nocolor\\ --nogroup"

function! s:Ack(args)
    let grepprg_bak=&grepprg
    exec "set grepprg=" . g:ackprg

    redraw
    echo "Searching ..."
    execute "silent! grep " . a:args

    botright copen
    let &grepprg=grepprg_bak
    exec "redraw!"
endfunction

function! s:AckFromSearch(args)
  let search =  getreg('/')
  " interprete vim regular expression to perl regular expression.
  let search = substitute(search,'\(\\<\|\\>\)','\\b','g')
  cal s:Ack( '"' .  search .'" '. a:args)
endfunction

function! s:AckAdd(args)
    let grepprg_bak=&grepprg
    exec "set grepprg=" . g:ackprg
    execute "silent! grepadd " . a:args
    botright copen
    let &grepprg=grepprg_bak
    exec "redraw!"
endfunction

function! s:LAck(args)
    let grepprg_bak=&grepprg
    exec "set grepprg=" . g:ackprg
    execute "silent! lgrep " . a:args
    botright lopen
    let &grepprg=grepprg_bak
    exec "redraw!"
endfunction

function! s:LAckAdd(args)
    let grepprg_bak=&grepprg
    exec "set grepprg=" . g:ackprg
    execute "silent! lgrepadd " . a:args
    botright lopen
    let &grepprg=grepprg_bak
    exec "redraw!"
endfunction

command! -nargs=* -complete=file Ack call s:Ack(<q-args>)
command! -nargs=* -complete=file AckAdd call s:AckAdd(<q-args>)
command! -nargs=* -complete=file AckFromSearch  :call s:AckFromSearch(<q-args>)
command! -nargs=* -complete=file LAck call s:LAck(<q-args>)
command! -nargs=* -complete=file LAckAdd call s:LAckAdd(<q-args>)

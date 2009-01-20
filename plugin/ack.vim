" NOTE: You must, of course, install the ack script
"       in your path.
" On Ubuntu:
"   sudo apt-get install ack-grep
"   ln -s /usr/bin/ack-grep /usr/bin/ack
"
function! Ack(args)
    let grepprg_bak=&grepprg
    set grepprg=ack\ -H\ --nocolor\ --nogroup
    execute "silent! grep " . a:args
    botright copen
    let &grepprg=grepprg_bak
endfunction

command! -nargs=* -complete=file Ack call Ack(<q-args>)

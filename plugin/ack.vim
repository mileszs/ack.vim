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
  let g:ackprg=s:ackcommand." -H --nocolor --nogroup --column"
endif

if !exists("g:ack_apply_qmappings")
  let g:ack_apply_qmappings = !exists("g:ack_qhandler")
endif

if !exists("g:ack_apply_lmappings")
  let g:ack_apply_lmappings = !exists("g:ack_lhandler")
endif

if !exists("g:ack_qhandler")
  let g:ack_qhandler="botright copen"
endif

if !exists("g:ack_lhandler")
  let g:ack_lhandler="botright lopen"
endif

function! s:Ack(cmd, args)
  redraw
  echo "Searching ..."

  " If no pattern is provided, search for the word under the cursor
  if empty(a:args)
    let l:grepargs = expand("<cword>")
  else
    let l:grepargs = a:args
  end

  " As grep expects filename, we shoule escape it first otherwise special
  " characters like '#' or '%' will be expanded.
  let l:grepargs = escape(l:grepargs, '%#')

  " Format, used to manage column jump
  if a:cmd =~# '-g$'
    let g:ackformat="%f"
  else
    let g:ackformat="%f:%l:%c:%m,%f:%l:%m"
  end

  let grepprg_bak=&grepprg
  let grepformat_bak=&grepformat
  try
    let &grepprg=g:ackprg
    let &grepformat=g:ackformat
    silent execute a:cmd . " " . l:grepargs
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
    exec "nnoremap <silent> <buffer> q " . l:close_cmd
    exec "nnoremap <silent> <buffer> t <C-W><CR><C-W>T"
    exec "nnoremap <silent> <buffer> T <C-W><CR><C-W>TgT<C-W><C-W>"
    exec "nnoremap <silent> <buffer> o <CR>"
    exec "nnoremap <silent> <buffer> go <CR><C-W><C-W>"
    exec "nnoremap <silent> <buffer> h <C-W><CR><C-W>K"
    exec "nnoremap <silent> <buffer> H <C-W><CR><C-W>K<C-W>b"
    exec "nnoremap <silent> <buffer> v <C-W><CR><C-W>H<C-W>b<C-W>J<C-W>t"
    exec "nnoremap <silent> <buffer> gv <C-W><CR><C-W>H<C-W>b<C-W>J"
  endif

  " If highlighting is on, highlight the search keyword.
  if exists("g:ackhighlight")
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

function! s:FileNameComp(arglead, cmdline, cursorpos)
    let path = expand(fnameescape(a:arglead), 1)
    if path =~ '\n'
        return split(path, '\n')
    else
        if isdirectory(path) && path !~ '/$'
            return [ path . '/' ]
        else
            let pattern = path . '*'
            return split(glob(pattern, 1), '\n')
        endif
    endif
endfunction

command! -bang -nargs=* -complete=customlist,s:FileNameComp Ack call s:Ack('grep<bang>',<q-args>)
command! -bang -nargs=* -complete=customlist,s:FileNameComp AckAdd call s:Ack('grepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=customlist,s:FileNameComp AckFromSearch call s:AckFromSearch('grep<bang>', <q-args>)
command! -bang -nargs=* -complete=customlist,s:FileNameComp LAck call s:Ack('lgrep<bang>', <q-args>)
command! -bang -nargs=* -complete=customlist,s:FileNameComp LAckAdd call s:Ack('lgrepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=customlist,s:FileNameComp AckFile call s:Ack('grep<bang> -g', <q-args>)
command! -bang -nargs=* -complete=customlist,s:FileNameComp AckHelp call s:AckHelp('grep<bang>',<q-args>)
command! -bang -nargs=* -complete=customlist,s:FileNameComp LAckHelp call s:AckHelp('lgrep<bang>',<q-args>)

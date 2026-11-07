" Vim filetype detection
" Language: TRS-80 Model 100 BASIC
"
" .BA is a tokenised BASIC program and is claimed outright. Reading one as
" text is never what anybody wants, so plugin/m100basic.vim converts it on
" the way in.
"
" .DO is the Model T text extension and is NOT claimed outright, for two
" reasons: Vim's own filetype.vim already maps *.do to Stata, and on a real
" machine a .DO file is just as likely to be a shopping list as a BASIC
" listing. A .DO whose first line opens with a line number is a listing, so
" that is what gets claimed. To take every .DO regardless:
"
"     let g:m100basic_claim_do = 1
"
" TS-DOS and the Super Backpack show .BA and .DO; a card written on a Mac may
" hold the same names in lower case. The patterns below spell out both cases in
" one pattern each rather than listing '*.ba,*.BA', because with
" 'fileignorecase' on - the macOS default - a single file matches both of those
" and the autocmd would fire twice.

augroup m100basic
    autocmd!
    autocmd BufNewFile,BufRead *.[bB][aA] setfiletype m100basic

    if get(g:, 'm100basic_claim_do', 0)
        " 'set filetype', not 'setfiletype': filetype.vim has already run by
        " the time an ftdetect script's autocmds fire, so Stata owns the
        " buffer and the non-forcing form would do nothing.
        autocmd BufNewFile,BufRead *.[dD][oO] set filetype=m100basic
    else
        autocmd BufRead *.[dD][oO] call m100basic#ClaimIfListing()
    endif

    " A .txt or .lst dump that uses a keyword only this machine has. Narrow
    " on purpose: these extensions are shared with every other BASIC, and
    " 'setfiletype' leaves the buffer alone if another plugin got there
    " first - including vim-cbmbasic, which claims the same two extensions.
    autocmd BufRead *.txt,*.lst,*.bas
        \ if getline(1) =~? '^\s*\d\+\s' && join(getline(1, 50), "\n") =~?
        \      '\<\%(MAXFILES\|LCOPY\|LFILES\|CSRLIN\|DAY\$\|IPL\|POWER\|MENU\|HIMEM\|MAXRAM\|DSKI\$\)\>' |
        \   setfiletype m100basic |
        \ endif
augroup END

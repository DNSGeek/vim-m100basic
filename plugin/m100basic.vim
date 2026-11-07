" Vim global plugin
" Language:   TRS-80 Model 100 BASIC
" Maintainer: Thomas Knox
"
" Transparent editing of tokenised .BA programs. The hooks have to live here
" rather than in ftplugin: a .BA is binary, so it has to be converted before
" anything can look at it to decide a filetype.
"
"     let g:m100basic_transparent_ba = 0    " leave .BA files alone
"
" See :help m100basic.

if exists('g:loaded_m100basic') || &compatible
    finish
endif
let g:loaded_m100basic = 1

" Global rather than buffer-local on purpose. A .DO file that does not exist
" yet has no first line to sniff, so it never reaches filetype m100basic - and
" writing a new program to the card is exactly when these are wanted.
command! -bang -nargs=? -complete=file M100Tokenize
    \ call m100basic#TokenizeTo(<q-args>, <bang>0)
command! -bang -nargs=? -complete=dir  M100Deploy
    \ call m100basic#Deploy(<q-args>, <bang>0)

if !get(g:, 'm100basic_transparent_ba', 1)
    finish
endif

" One pattern covering both cases, not '*.ba,*.BA'. With 'fileignorecase' on -
" the default on macOS - a file named PROG.BA matches both of those patterns,
" so every hook ran twice and the read pasted the program in on top of itself.
augroup m100basic_tokenized
    autocmd!
    autocmd BufReadCmd   *.[bB][aA]
        \ call m100basic#ReadTokenized(expand('<amatch>'))
    autocmd BufWriteCmd  *.[bB][aA]
        \ call m100basic#WriteTokenized(expand('<amatch>'), 1, line('$'))
    autocmd FileWriteCmd *.[bB][aA]
        \ call m100basic#WriteTokenized(expand('<amatch>'), line("'["), line("']"))
augroup END

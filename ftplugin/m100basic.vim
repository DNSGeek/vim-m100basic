" Vim filetype plugin
" Language:   TRS-80 Model 100 BASIC
" Maintainer: Thomas Knox

if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

" REM and ' both run to end of line. ' is listed first so 'gc'-style
" commenting plugins and 'commentstring' prefer the short form, which is
" what costs the least RAM on the machine.
setlocal comments=:',:REM
setlocal commentstring='\ %s

setlocal formatoptions-=t
setlocal formatoptions+=croql

" $ belongs to a word so * and w treat CHR$ and A$ as one. '#' does not:
" there is no PRINT# token on this machine.
setlocal iskeyword=@,48-57,_,$

" A listing is one statement per numbered line. Wrapping or auto-indenting
" it would misrepresent the file, and there is no block structure to fold.
setlocal nowrap
setlocal noautoindent
setlocal nosmartindent
setlocal foldmethod=manual

" The LCD is 40 columns. A logical line may run to 255 characters, which the
" machine will accept and wrap across the display, so this marks the screen
" edge rather than a limit:
"
"     let g:m100basic_colorcolumn = 255   " mark the real line limit instead
"     let g:m100basic_colorcolumn = 0     " no marker
"
let s:cc = get(g:, 'm100basic_colorcolumn', 40)
if s:cc > 0
    let &l:colorcolumn = s:cc
endif

" .DO files go to the machine as CRLF. .BA files never reach the disk as
" text at all - plugin/m100basic.vim pipes them through the tokeniser - so
" only the text side needs this, and only when the buffer is not already
" carrying its own answer.
if expand('%:e') =~? '^do$' && !&modified
    setlocal fileformat=dos
endif

" :M100Tokenize and :M100Deploy are global, defined in plugin/m100basic.vim.

let b:undo_ftplugin = "setlocal fo< com< cms< isk< wrap< ai< si< fdm< cc< ff<"

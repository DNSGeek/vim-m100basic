" Vim autoload script
" Language:   TRS-80 Model 100 BASIC
" Maintainer: Thomas Knox
"
" Tokenised .BA round-trip and card deployment. The tokeniser and
" detokeniser are external tools, not reimplementations:
"
"   detok85   .BA -> ASCII    https://github.com/bkw777/detok85
"   tokenize  ASCII -> .BA    https://github.com/hackerb9/tokenize
"
" Override either with g:m100basic_detokenize_cmd / g:m100basic_tokenize_cmd.
" Both are looked up with executable(), so a missing tool degrades to a
" warning rather than a stack trace.

function! s:Warn(msg) abort
    echohl WarningMsg
    echomsg 'm100basic: ' . a:msg
    echohl None
endfunction

" Resolve a configured command, returning '' when its binary is not on the
" path. Only the first word is checked, so 'python3 /path/detok85.py' works.
function! s:Tool(var, default) abort
    let l:cmd = get(g:, a:var, a:default)
    return executable(split(l:cmd)[0]) ? l:cmd : ''
endfunction

function! s:Detok() abort
    return s:Tool('m100basic_detokenize_cmd', 'detok85')
endfunction

function! s:Tok() abort
    return s:Tool('m100basic_tokenize_cmd', 'tokenize')
endfunction

" --------------------------------------------------------------- .DO sniffing
" Claim a .DO buffer only when it opens with a line number, and only from a
" filetype nobody chose on purpose. Vim's filetype.vim hands every *.do to
" Stata; a Model T .DO is as often prose as it is a listing.
function! m100basic#ClaimIfListing() abort
    if index(['', 'stata', 'text', 'conf'], &filetype) < 0
        return
    endif
    if getline(1) =~# '^\s*\d\+\%(\s\|$\)'
        set filetype=m100basic
    endif
endfunction

" ------------------------------------------------------------ reading a .BA
" BufReadCmd: the buffer is empty and nothing has been read yet, so this
" function owns the whole load.
function! m100basic#ReadTokenized(fname) abort
    setlocal filetype=m100basic
    let b:m100basic_tokenized = 1

    " :e on a name that does not exist yet is a new program, not an error.
    if !filereadable(a:fname)
        setlocal nomodified
        return
    endif

    let l:cmd = s:Detok()
    if empty(l:cmd)
        " No detokeniser. Show the bytes rather than an empty window, and
        " keep the buffer read-only so a stray :w cannot flatten a program.
        execute 'silent keepalt 0read ++bin' fnameescape(a:fname)
        silent keepjumps $delete _
        setlocal binary noswapfile nomodifiable nomodified
        call s:Warn('detok85 not found: showing raw bytes, buffer is read-only. '
            \ . 'See :help m100basic-tools')
        return
    endif

    execute 'silent keepalt 0read !' . l:cmd . ' ' . shellescape(a:fname)
    if v:shell_error
        silent keepjumps %delete _
        setlocal nomodifiable nomodified
        call s:Warn(l:cmd . ' failed on ' . fnamemodify(a:fname, ':t')
            \ . ' (exit ' . v:shell_error . ')')
        return
    endif

    " 0read leaves the buffer's original empty line at the bottom.
    silent keepjumps $delete _
    setlocal fileformat=unix
    setlocal nomodified
endfunction

" ------------------------------------------------------------ writing a .BA
" BufWriteCmd / FileWriteCmd: this function owns the whole save, including
" clearing 'modified' - and must leave it set if the tokeniser fails, or a
" failed write looks like a successful one.
function! m100basic#WriteTokenized(fname, line1, line2) abort
    let l:cmd = s:Tok()
    if empty(l:cmd)
        call s:Warn('tokenize not found: NOTHING WAS WRITTEN. Save as .DO, or '
            \ . 'see :help m100basic-tools')
        return
    endif

    " The tokeniser works file to file, so the buffer goes out as ASCII
    " first. noautocmd keeps this temp write from re-entering these hooks.
    let l:tmp = tempname() . '.DO'
    execute 'silent noautocmd keepalt' a:line1 . ',' . a:line2 'write!'
        \ fnameescape(l:tmp)

    let l:out = system(l:cmd . ' ' . shellescape(l:tmp) . ' '
        \ . shellescape(a:fname))
    call delete(l:tmp)

    if v:shell_error
        call s:Warn(l:cmd . ' failed (exit ' . v:shell_error . '): '
            \ . substitute(l:out, '\n\+$', '', ''))
        return
    endif

    let b:m100basic_tokenized = 1
    setlocal nomodified
endfunction

" :M100Tokenize [path] - write the buffer as a tokenised .BA without
" making it the buffer's file. Defaults to the buffer's name with .BA.
function! m100basic#TokenizeTo(arg, bang) abort
    let l:dest = empty(a:arg) ? expand('%:p:r') . '.BA' : fnamemodify(a:arg, ':p')
    if filereadable(l:dest) && !a:bang
        call s:Warn(fnamemodify(l:dest, ':t') . ' exists (add ! to overwrite)')
        return
    endif
    call m100basic#WriteTokenized(l:dest, 1, line('$'))
    if filereadable(l:dest)
        echomsg printf('m100basic: wrote %s (%d bytes)',
            \ fnamemodify(l:dest, ':t'), getfsize(l:dest))
    endif
endfunction

" --------------------------------------------------------------- deployment
" TS-DOS and the Super Backpack show a 6.2 filename: six characters of name,
" two of extension, upper case. Anything longer is truncated on the machine
" rather than rejected, which is how two programs end up sharing a name.
function! s:CardName(stem, ext) abort
    let l:stem = substitute(toupper(a:stem), '[^A-Z0-9]', '', 'g')
    if empty(l:stem)
        let l:stem = 'NONAME'
    endif
    return strpart(l:stem, 0, 6) . '.' . a:ext
endfunction

" :M100Deploy [dir] - put this program on the card. A .BA buffer goes out
" tokenised, anything else goes out as CRLF text; ! forces tokenising.
function! m100basic#Deploy(arg, bang) abort
    let l:dir = !empty(a:arg) ? a:arg : get(g:, 'm100basic_card_dir', '')
    if empty(l:dir)
        call s:Warn('set g:m100basic_card_dir to the mounted card, or pass a '
            \ . 'directory: :M100Deploy /Volumes/M100')
        return
    endif
    let l:dir = fnamemodify(expand(l:dir), ':p')
    if !isdirectory(l:dir)
        call s:Warn(l:dir . ' is not a directory - is the card mounted?')
        return
    endif

    let l:tokenised = a:bang || expand('%:e') =~? '^ba$'
    let l:dest = l:dir . s:CardName(expand('%:t:r'), l:tokenised ? 'BA' : 'DO')

    if l:tokenised
        call m100basic#WriteTokenized(l:dest, 1, line('$'))
    else
        " The machine's TEXT editor expects CRLF.
        let l:save_ff = &l:fileformat
        try
            setlocal fileformat=dos
            execute 'silent noautocmd keepalt write!' fnameescape(l:dest)
        finally
            let &l:fileformat = l:save_ff
        endtry
    endif

    if filereadable(l:dest)
        echomsg printf('m100basic: %s -> %s (%d bytes)',
            \ expand('%:t'), fnamemodify(l:dest, ':t'), getfsize(l:dest))
    endif
endfunction

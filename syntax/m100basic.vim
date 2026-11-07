" Vim syntax file
" Language:     TRS-80 Model 100 BASIC
" Maintainer:   Thomas Knox
" Last Change:  2026 Nov 07
"
" The BASIC in ROM on the TRS-80 Model 100 and 102, TANDY 200, Kyotronic
" KC-85 and Olivetti M-10. These machines share one tokeniser and one keyword
" set: the ROM token table, $80 (END) through $FF ('). Tokens are a single
" byte throughout, with no prefix byte, and multi-word forms are token pairs -
" MAXFILES is MAX + FILES, LINE INPUT is LINE + INPUT, DEFINT is DEF + INT.
"
" The NEC PC-8201 and PC-8300 are not covered. They run N82 BASIC, which
" assigns several of the same bytes to different keywords.
"
" Like Commodore BASIC and for the same Microsoft reasons, this tokeniser
" crunches keywords out of unspaced text, so real listings look like
"
"     100 FORI=1TO8:IFA(I)THENPRINTTAB(5)I:NEXT
"
" and every keyword below is therefore matched WITHOUT a word boundary: FOR
" has to colour inside FORI. The scan is leftmost-first, which is what the ROM
" does too, so FOREMAN crunches to FOR + EMAN rather than FOR + REM + AN.
"
" One consequence worth knowing while reading a listing: a variable may not
" contain a keyword, because the keyword is what gets crunched. COST is COS +
" T, and only the first two characters of a name are significant anyway.
"
" The keyword section is generated. Definition order carries meaning: when two
" items match at one position Vim gives priority to the one defined LAST, so
" keywords are emitted shortest-first and the longest wins - ERROR over ERR,
" LPRINT over PRINT, INPUT$ over INPUT. Keep that order if you edit it.

if exists("b:current_syntax")
    finish
endif

syn case ignore

" ------------------------------------------------------- literal-text regions
" These come first so nothing below can match inside them. Each is a region
" that contains only what it lists, which is how a keyword is kept from
" colouring inside a comment, a string or a DATA operand.

" REM takes the rest of the line. ' is the shorthand, stored on the machine as
" the three bytes : REM $FF.
syn match m100basicComment "REM.*$" contains=m100basicTodo
syn match m100basicComment "'.*$"   contains=m100basicTodo
syn keyword m100basicTodo contained TODO FIXME XXX NOTE

" An unterminated string is legal at end of line:
"   10 PRINT "HELLO
" so the region needs an end at EOL as well as at the closing quote, or it
" matches nothing at all on such a line. There are no escape sequences.
syn region m100basicString start=+"+ end=+"+ end=+$+ oneline

" The ROM does not crunch DATA operands - the tokeniser switches to copying
" text until a colon or end of line - so a bare DATA item that happens to
" contain a keyword really is just text.
syn region m100basicData matchgroup=m100basicStatement
    \ start="DATA" end=":"me=e-1 end="$"
    \ oneline contains=m100basicNumber,m100basicString

" ------------------------------------------------------------------- keywords
syn match m100basicClause      "AS"         " untokenised
syn match m100basicFunction    "FN"         " untokenised
syn match m100basicConditional "IF"
syn match m100basicStatement   "ON"
syn match m100basicOperator    "OR"
syn match m100basicRepeat      "TO"
syn match m100basicFunction    "ABS"
syn match m100basicOperator    "AND"
syn match m100basicFunction    "ASC"
syn match m100basicFunction    "ATN"
syn match m100basicStatement   "CLS"
syn match m100basicStatement   "COM"
syn match m100basicFunction    "COS"
syn match m100basicStatement   "DEF"
syn match m100basicStatement   "DIM"
syn match m100basicStatement   "END"
syn match m100basicFunction    "EOF"
syn match m100basicOperator    "EQV"
syn match m100basicReserved    "ERL"
syn match m100basicReserved    "ERR"
syn match m100basicFunction    "EXP"
syn match m100basicFunction    "FIX"
syn match m100basicRepeat      "FOR"
syn match m100basicFunction    "FRE"
syn match m100basicOperator    "IMP"
syn match m100basicFunction    "INP"
syn match m100basicFunction    "INT"
syn match m100basicStatement   "IPL"
syn match m100basicStatement   "KEY"
syn match m100basicFunction    "LEN"
syn match m100basicStatement   "LET"
syn match m100basicFunction    "LOC"
syn match m100basicFunction    "LOF"
syn match m100basicFunction    "LOG"
syn match m100basicStatement   "MAX"
syn match m100basicStatement   "MDM"
syn match m100basicOperator    "MOD"
syn match m100basicStatement   "NEW"
syn match m100basicOperator    "NOT"
syn match m100basicClause      "OFF"
syn match m100basicStatement   "OUT"
syn match m100basicFunction    "POS"
syn match m100basicFunction    "RND"
syn match m100basicStatement   "RUN"
syn match m100basicFunction    "SGN"
syn match m100basicFunction    "SIN"
syn match m100basicFunction    "SQR"
syn match m100basicFunction    "TAN"
syn match m100basicFunction    "VAL"
syn match m100basicOperator    "XOR"
syn match m100basicStatement   "BEEP"
syn match m100basicStatement   "CALL"
syn match m100basicFunction    "CDBL"
syn match m100basicFunction    "CHR\$"
syn match m100basicFunction    "CINT"
syn match m100basicStatement   "CONT"
syn match m100basicFunction    "CSNG"
syn match m100basicReserved    "DAY\$"
syn match m100basicStatement   "EDIT"
syn match m100basicConditional "ELSE"
syn match m100basicStatement   "GOTO"
syn match m100basicStatement   "KILL"
syn match m100basicStatement   "LINE"
syn match m100basicStatement   "LIST"
syn match m100basicStatement   "LOAD"
syn match m100basicFunction    "LPOS"
syn match m100basicStatement   "MENU"
syn match m100basicFunction    "MID\$"
syn match m100basicStatement   "NAME"
syn match m100basicRepeat      "NEXT"
syn match m100basicStatement   "OPEN"
syn match m100basicFunction    "PEEK"
syn match m100basicStatement   "POKE"
syn match m100basicStatement   "PSET"
syn match m100basicStatement   "READ"
syn match m100basicStatement   "SAVE"
syn match m100basicRepeat      "STEP"
syn match m100basicStatement   "STOP"
syn match m100basicFunction    "STR\$"
syn match m100basicFunction    "TAB("
syn match m100basicConditional "THEN"
syn match m100basicStatement   "CLEAR"
syn match m100basicStatement   "CLOAD"
syn match m100basicStatement   "CLOSE"
syn match m100basicStatement   "CSAVE"
syn match m100basicReserved    "DATE\$"
syn match m100basicFunction    "DSKI\$"
syn match m100basicFunction    "DSKO\$"
syn match m100basicStatement   "ERROR"
syn match m100basicStatement   "FILES"
syn match m100basicStatement   "GOSUB"
syn match m100basicReserved    "HIMEM"
syn match m100basicStatement   "INPUT"
syn match m100basicFunction    "INSTR"
syn match m100basicStatement   "LCOPY"
syn match m100basicFunction    "LEFT\$"
syn match m100basicStatement   "LLIST"
syn match m100basicStatement   "MERGE"
syn match m100basicStatement   "MOTOR"
syn match m100basicStatement   "POWER"
syn match m100basicStatement   "PRINT"
syn match m100basicStatement   "SOUND"
syn match m100basicReserved    "TIME\$"
syn match m100basicClause      "USING"
syn match m100basicStatement   "WIDTH"
syn match m100basicClause      "APPEND"     " untokenised
syn match m100basicReserved    "CSRLIN"
syn match m100basicReserved    "INKEY\$"
syn match m100basicFunction    "INPUT\$"    " untokenised
syn match m100basicStatement   "LFILES"
syn match m100basicStatement   "LPRINT"
syn match m100basicReserved    "MAXRAM"     " untokenised
syn match m100basicClause      "OUTPUT"     " untokenised
syn match m100basicStatement   "PRESET"
syn match m100basicStatement   "RESUME"
syn match m100basicStatement   "RETURN"
syn match m100basicFunction    "RIGHT\$"
syn match m100basicStatement   "SCREEN"
syn match m100basicFunction    "SPACE\$"
syn match m100basicFunction    "VARPTR"
syn match m100basicStatement   "RESTORE"
syn match m100basicFunction    "STRING\$"

" ------------------------------------------------ forms written as two words
" Defined after the generated block so they outrank the single keywords they
" contain. DEFINT is DEF + INT on the machine and DEFDBL is DEF + plain text;
" both read better as one statement. GO TO is the one token the ROM accepts
" with a space inside it (136, the same byte as GOTO).
syn match m100basicStatement "GO\s\+TO"
syn match m100basicStatement "DEF\%(INT\|SNG\|DBL\|STR\)"

" --------------------------------------------------- operators and separators
" \ is integer division, ^ is exponentiation. In a collection so the ^ is not
" read as a start-of-line anchor.
syn match m100basicOperator "[-+*/^\\=<>]"
syn match m100basicOperator "<>"
syn match m100basicOperator "[<>]="

" ? is the standard abbreviation for PRINT and crunches to the same byte.
syn match m100basicStatement "?"

" ------------------------------------------------------------------- numbers
" Microsoft BASIC literals: decimal, hex &H, octal &O (a bare & is octal too),
" E for a single-precision exponent and D for double, plus the !/#/% type
" suffixes. No \< before the &: '&' is not a word character, so a word-boundary
" assertion in front of it can never be true.
syn match m100basicNumber "&[hH]\x\+\>"
syn match m100basicNumber "&[oO]\=[0-7]\+\>"
syn match m100basicNumber "\<\d\+[!#%]\=\>"
syn match m100basicNumber "\<\d\+\.\d*\%([eEdD][-+]\=\d\+\)\=[!#]\="
syn match m100basicNumber "\.\d\+\%([eEdD][-+]\=\d\+\)\=[!#]\=\>"
syn match m100basicNumber "\<\d\+[eEdD][-+]\=\d\+[!#]\=\>"

" A file number after a channel keyword or a comma: PRINT #1, CLOSE #2
syn match m100basicFilenumber "#\s*\d\+"

" -------------------------------------------------------------- line numbers
" Every statement line opens with one, and telling them apart from ordinary
" numeric literals is the most useful thing to colour in a listing. Defined
" after the number rules so it wins where both start at one column.
syn match m100basicLineNumber "^\s*\d\+"

" A jump target reads as a label rather than a number. Lookbehind, so the
" match starts on the digits: a pattern starting at the GOTO would lose to the
" GOTO keyword and never fire. No word boundary before the keyword, because in
" a crunched listing there is not one (IFIGOTO100).
syn match m100basicLineRef
    \ "\%(\%(GOTO\|GOSUB\|THEN\|ELSE\|RESTORE\|RESUME\|GO\s\+TO\)\s*\)\@<=\d\+\%(\s*,\s*\d\+\)*"

" --------------------------------------------------------------------- sync
" One statement per numbered line, no block structure, so there is nothing to
" look back through.
syn sync minlines=1 maxlines=2

" ---------------------------------------------------------------- highlight
" 'hi def link' so a colorscheme or the user can override these.
hi def link m100basicComment     Comment
hi def link m100basicTodo        Todo
hi def link m100basicStatement   Statement
hi def link m100basicConditional Conditional
hi def link m100basicRepeat      Repeat
hi def link m100basicClause      Keyword
hi def link m100basicFunction    Function
hi def link m100basicReserved    Identifier
hi def link m100basicOperator    Operator
hi def link m100basicString      String
hi def link m100basicData        Constant
hi def link m100basicNumber      Number
hi def link m100basicFilenumber  Number
hi def link m100basicLineNumber  LineNr
hi def link m100basicLineRef     Label

" Must be set last, so the guard at the top of the file means something.
let b:current_syntax = "m100basic"

# vim-m100basic

A Vim syntax highlighting plugin for TRS-80 Model 100 BASIC, with transparent
editing of tokenised `.BA` programs.

Covers the BASIC in ROM on the TRS-80 Model 100 and 102, TANDY 200, Kyotronic
KC-85 and Olivetti M-10, which all share one tokeniser and one keyword set.
The NEC PC-8201 and PC-8300 are **not** covered: they run N82 BASIC, which
assigns several of the same token bytes to different keywords.

## What it does

* Highlights the full ROM keyword set, `$80` (`END`) through `$FF` (`'`).
* Highlights **crunched** listings. Model 100 BASIC crunches keywords out of
  unspaced text the way Commodore BASIC does, so a real listing looks like
  `100 FORI=1TO8:IFA(I)THENPRINTTAB(5)I:NEXT` — and every keyword in it
  colours.
* Opens a tokenised `.BA` file as editable text and writes it back tokenised,
  so a program can be edited in place on a mounted microSD card.
* Knows the Microsoft literal forms the C64 does not have: `&H` hex, `&O`
  octal, `D` double-precision exponents, and the `! # % $` type suffixes.
* Leaves `DATA` operands and string contents alone, because the ROM does not
  crunch those either.

## Install

With any plugin manager, e.g. vim-plug:

```vim
Plug 'DNSGeek/vim-m100basic'
```

Or by hand:

```bash
git clone https://github.com/DNSGeek/vim-m100basic ~/.vim/pack/plugins/start/vim-m100basic
```

## Tokenised .BA round-trip

The tokeniser and detokeniser are external tools, not reimplementations:

| Tool | Direction | Source |
|---|---|---|
| `detok85` | `.BA` → ASCII | <https://github.com/bkw777/detok85> |
| `tokenize` | ASCII → `.BA` | <https://github.com/hackerb9/tokenize> |

Put both on your `$PATH` and `.BA` files open and save as text. Without them
a `.BA` still opens, as read-only raw bytes with a warning, and a save is
refused rather than writing a broken program.

```vim
let g:m100basic_detokenize_cmd = 'detok85'   " or 'python3 /path/detok85.py'
let g:m100basic_tokenize_cmd   = 'tokenize'
let g:m100basic_transparent_ba = 1           " 0 leaves .BA files alone
```

## Filetype detection

`.BA` is claimed outright. `.DO` is not, for two reasons: Vim's own
`filetype.vim` maps `*.do` to Stata, and on a real machine a `.DO` file is as
likely to be a shopping list as a program. A `.DO` **whose first line starts
with a line number** is claimed; anything else is left alone.

```vim
let g:m100basic_claim_do = 1    " take every .DO regardless
```

A `.DO` that does not exist yet has no first line to sniff, so a brand-new
program needs `:setf m100basic` or the option above.

`.txt`, `.lst` and `.bas` are sniffed too, but only for keywords unique to
this machine (`MAXFILES`, `LCOPY`, `CSRLIN`, `DAY$`, `IPL`, `POWER`, …), and
only with `setfiletype`, so an already-detected buffer is never stolen — from
[vim-cbmbasic](https://github.com/DNSGeek/vim-cbmbasic) among others.

## Commands

| Command | Effect |
|---|---|
| `:M100Tokenize [path]` | Write the buffer as a tokenised `.BA`. Defaults to the buffer's name with a `.BA` extension; `!` overwrites. |
| `:M100Deploy [dir]` | Put the program on a card. A `.BA` buffer goes out tokenised, anything else as CRLF text; `!` forces tokenising. |

```vim
let g:m100basic_card_dir = '/Volumes/M100'   " where :M100Deploy writes
```

`:M100Deploy` upper-cases the name, strips anything that is not a letter or
digit, and truncates to the 6.2 filename TS-DOS and the Super Backpack show,
so `MyProgram.do` lands as `MYPROG.DO`.

## Other options

```vim
let g:m100basic_colorcolumn = 40    " 0 to turn off, 255 for the real limit
```

The LCD is 40 columns; a logical line may run to 255 characters, which the
machine accepts and wraps. The default marks the screen edge.

## Known limits

* Highlighting only. There is no syntax checking, no renumbering and no
  variable analysis. For those on the Model T itself, see
  [MTRenum](https://github.com/LEJ-Projects/MTRenum),
  [MTLineRef](https://github.com/LEJ-Projects/MTLineRef) and
  [MTVarConcor](https://github.com/LEJ-Projects/MTVarConcor).
* Only the first two characters of a variable name are significant on the
  machine, and a name may not contain a keyword, because the keyword is what
  gets crunched: `COST` is `COS` + `T`. Neither rule is checked here — a
  line-by-line syntax file cannot see the collisions.
* `.CO` machine-code files are 8085 and out of scope. For those, see
  [vim-m80](https://github.com/gseidler/vim-m80).

## Credits

Keyword set and token values cross-checked against
[bkw777/detok85](https://github.com/bkw777/detok85) and
[hackerb9/tokenize](https://github.com/hackerb9/tokenize), and against
Appendix C of *Exploring the TRS-80 Model 100*.

Structured after [vim-cbmbasic](https://github.com/DNSGeek/vim-cbmbasic).

## License

GPL-2.0, same as vim-cbmbasic. See [LICENSE](LICENSE).

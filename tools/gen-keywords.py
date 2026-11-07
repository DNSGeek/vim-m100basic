#!/usr/bin/env python3
"""Generate syntax/m100basic.vim.

The keyword section is generated because correctness depends on definition
order: Vim gives the LAST-defined item priority when two match at the same
position, so keywords must be emitted shortest-first for the longest one to
win (ERROR over ERR, INPUT$ over INPUT, LPRINT over PRINT).
"""
# group -> keywords. Names and spellings are the ROM token table, $80-$FF.
GROUPS = {
    'Repeat':      ['FOR', 'TO', 'STEP', 'NEXT'],
    'Conditional': ['IF', 'THEN', 'ELSE'],
    # DATA is deliberately absent: it is the start of the literal-text
    # region in the hand-written part of the file, and a plain match here
    # would outrank that region and stop it ever opening.
    'Statement':   ['END', 'INPUT', 'DIM', 'READ', 'LET', 'GOTO', 'RUN',
                    'RESTORE', 'GOSUB', 'RETURN', 'STOP', 'WIDTH', 'LINE', 'EDIT',
                    'ERROR', 'RESUME', 'OUT', 'ON', 'OPEN', 'CLOSE', 'LOAD',
                    'MERGE', 'FILES', 'SAVE', 'LFILES', 'LPRINT', 'DEF', 'POKE',
                    'PRINT', 'CONT', 'LIST', 'LLIST', 'CLEAR', 'CLOAD', 'CSAVE',
                    'COM', 'MDM', 'KEY', 'CLS', 'BEEP', 'SOUND', 'LCOPY', 'PSET',
                    'PRESET', 'MOTOR', 'MAX', 'POWER', 'CALL', 'MENU', 'IPL',
                    'NAME', 'KILL', 'SCREEN', 'NEW'],
    'Clause':      ['USING', 'OFF', 'AS', 'OUTPUT', 'APPEND'],
    'Function':    ['TAB(', 'VARPTR', 'STRING$', 'INSTR', 'DSKI$', 'DSKO$', 'SGN',
                    'INT', 'ABS', 'FRE', 'INP', 'LPOS', 'POS', 'SQR', 'RND', 'LOG',
                    'EXP', 'COS', 'SIN', 'TAN', 'ATN', 'PEEK', 'EOF', 'LOC', 'LOF',
                    'CINT', 'CSNG', 'CDBL', 'FIX', 'LEN', 'STR$', 'VAL', 'ASC',
                    'CHR$', 'SPACE$', 'LEFT$', 'RIGHT$', 'MID$', 'FN', 'INPUT$'],
    'Reserved':    ['TIME$', 'DATE$', 'DAY$', 'ERL', 'ERR', 'INKEY$', 'CSRLIN',
                    'HIMEM', 'MAXRAM'],
    'Operator':    ['AND', 'OR', 'XOR', 'EQV', 'IMP', 'MOD', 'NOT'],
}
# Not in the ROM token table - the machine stores these as plain text - but
# part of the language and expected to colour: AS, OUTPUT, APPEND, FN, MAXRAM
# (MAX + RAM), INPUT$ (INPUT + $).
UNTOKENISED = {'AS', 'OUTPUT', 'APPEND', 'FN', 'MAXRAM', 'INPUT$'}

def esc(kw):
    return kw.replace('\\', '\\\\').replace('$', '\\$')

rows = [(kw, g) for g, kws in GROUPS.items() for kw in kws]
# Shortest first, so the longest definition is the last one standing.
rows.sort(key=lambda r: (len(r[0]), r[0]))

width = max(len(esc(kw)) + 2 for kw, _ in rows)
lines = []
for kw, g in rows:
    pat = '"%s"' % esc(kw)
    note = '   " untokenised' if kw in UNTOKENISED else ''
    lines.append('syn match m100basic%-11s %-*s%s' % (g, width, pat, note))
print('\n'.join(lines))

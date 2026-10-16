"""rb0_xref.py -- referee B for thread `sfi`: mechanical check of every printed-number citation of
SOI Paper 1 ("P1 ...") and of the earlier axiom-induction paper ("AI-paper ...") in notes.md against
the label tables in the two papers' main.aux (the cleveref lines `\\newlabel{lab@cref}{{[type][..][..]num}...}`).

For each citation the script reports the label(s) carrying that type and printed number, so the
descriptive label name can be compared with what notes.md says the item is.  Also resolves the
backtick labels (`thm:...`, `prop:...`) that notes.md cites directly, and the first column of the
transfer table (notes.md section 5.5), whose items are P1 numbers without the "P1" prefix.

Deterministic.  Output: rb0_xref.out next to this script.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
NOTES = os.path.join(HERE, '..', 'notes.md')
P1_AUX = '/home/user/AI-works/solomonoff-operator-induction/paper/main.aux'
AI_AUX = '/home/user/AI-works/axiom-induction/paper/main.aux'

out_lines = []


def out(s=''):
    out_lines.append(s)
    print(s)


ABBR = {
    'Thm': 'theorem', 'Thms': 'theorem', 'Theorem': 'theorem',
    'Prop': 'proposition', 'Props': 'proposition', 'Proposition': 'proposition',
    'Cor': 'corollary', 'Cors': 'corollary', 'Corollary': 'corollary',
    'Lemma': 'lemma', 'Lemmas': 'lemma', 'Lem': 'lemma',
    'Def': 'definition', 'Defs': 'definition', 'Definition': 'definition',
    'Rem': 'remark', 'Rems': 'remark', 'Remark': 'remark',
    'Ex': 'example', 'Exs': 'example', 'Example': 'example',
    'Q': 'question', 'Question': 'question',
    'Conv': 'convention', 'Convention': 'convention',
}


def load_aux(path):
    by_num = {}   # (type, num) -> [labels]
    by_lab = {}   # label -> (type, num)
    pat = re.compile(r'\\newlabel\{([^}]*)@cref\}\{\{\[([^\]]*)\]\[[^\]]*\]\[[^\]]*\]([^}]*)\}')
    with open(path) as fh:
        for line in fh:
            m = pat.search(line)
            if not m:
                continue
            lab, typ, num = m.group(1), m.group(2), m.group(3)
            by_lab[lab] = (typ, num)
            by_num.setdefault((typ, num), []).append(lab)
    return by_num, by_lab


def types_in(by_num):
    return sorted(set(t for t, _ in by_num))


NUM = r'(?:[A-Z]\.\d+|\d+(?:\.\d+)?)'


def parse_citations(text, prefix):
    """yield (abbr, num, context) for '<prefix> Abbr num[(..)][, num ...]'."""
    res = []
    pat = re.compile(prefix + r'\s+(' + '|'.join(sorted(ABBR, key=len, reverse=True)) + r')\.?\s+(' + NUM +
                     r'(?:\([^)]*\))?(?:\s*(?:,|and|–|-)\s*' + NUM + r'(?:\([^)]*\))?)*)')
    for m in pat.finditer(text):
        abbr = m.group(1)
        nums = re.findall(NUM, re.sub(r'\([^)]*\)', '', m.group(2)))
        ctx = text[max(0, m.start() - 30): m.end() + 40].replace('\n', ' ')
        for n in nums:
            res.append((abbr, n, ctx))
    return res


def main():
    text = open(NOTES).read()
    p1_num, p1_lab = load_aux(P1_AUX)
    ai_num, ai_lab = load_aux(AI_AUX)
    out('rb0_xref.py (deterministic)')
    out('P1 aux: %d cref labels, types %s' % (len(p1_lab), types_in(p1_num)))
    out('AI aux: %d cref labels, types %s' % (len(ai_lab), types_in(ai_num)))
    bad = []
    for name, prefix, by_num in (('P1', r'P1(?:\'s)?', p1_num), ('AI-paper', r'AI-paper', ai_num)):
        cits = parse_citations(text, prefix)
        seen = {}
        for abbr, n, ctx in cits:
            seen.setdefault((abbr, n), ctx)
        out('')
        out('== %s citations in notes.md: %d distinct (type, number) pairs' % (name, len(seen)))
        for (abbr, n), ctx in sorted(seen.items(), key=lambda kv: (kv[0][1], kv[0][0])):
            typ = ABBR[abbr]
            labs = by_num.get((typ, n), [])
            other = [(t, l) for (t, nn), ls in by_num.items() if nn == n for l in ls if t != typ]
            flag = 'ok ' if labs else 'MISSING'
            if not labs:
                bad.append((name, abbr, n, other, ctx))
            out('  %-7s %-6s %-6s -> %s%s' % (flag, abbr, n, ', '.join(labs) if labs else '-',
                                               ('   [same number, other type: %s]' % other) if not labs and other else ''))
    # backtick labels
    out('')
    out('== backtick labels cited in notes.md')
    for lab in sorted(set(re.findall(r'`((?:thm|prop|rem|cor|def|lem|ex|eq|sec|app)[:\w]+)`', text))):
        if lab in p1_lab:
            out('  P1       %-30s = %s %s' % (lab, *p1_lab[lab]))
        elif lab in ai_lab:
            out('  AI-paper %-30s = %s %s' % (lab, *ai_lab[lab]))
        else:
            out('  ??       %-30s not found in either aux' % lab)
    # transfer table first column
    out('')
    out('== transfer table (notes section 5.5), first column, resolved against P1')
    sec = text.split('### 5.5 The transfer table')[1].split('So **the content of SAI')[0]
    for row in sec.splitlines():
        if not row.startswith('| ') or row.startswith('| P1 item') or row.startswith('|---'):
            continue
        first = row.split('|')[1]
        items = re.findall(r'(' + '|'.join(sorted(ABBR, key=len, reverse=True)) + r')\.?\s+(' + NUM +
                           r'(?:\s*(?:,|–)\s*' + NUM + r')*)', first)
        res = []
        for abbr, nums in items:
            for n in re.findall(NUM, nums):
                labs = p1_num.get((ABBR[abbr], n), [])
                res.append('%s %s=%s' % (abbr, n, labs[0] if labs else 'MISSING'))
                if not labs:
                    bad.append(('P1-table', abbr, n, [], first.strip()))
        out('  %-60s %s' % (first.strip()[:60], '; '.join(res)))
    out('')
    out('== unresolved citations: %d' % len(bad))
    for b in bad:
        out('  %s %s %s ; other types with that number: %s ; context: ...%s...' % b)
    with open(os.path.join(HERE, 'rb0_xref.out'), 'w') as fh:
        fh.write('\n'.join(out_lines) + '\n')


if __name__ == '__main__':
    main()

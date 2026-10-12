"""Compare each theorem-like environment's \\status in Paper 1 with the status column of CLAIMS.md §1,
after normalising track abbreviations (F/Hi/Ex/Co/St -> foundations/...), check ids in parentheses,
markup and whitespace. Prints only substantive mismatches, ledger rows missing in the paper, and
paper labels missing in the ledger. Usage: python3 -I compare_status2.py CLAIMS.md envs.json"""
import json, re, sys
claims = open(sys.argv[1], encoding='utf8').read()
envs = json.load(open(sys.argv[2]))
ledger = {}
for line in claims.split('\n'):
    if not line.startswith('| ') or line.startswith('| id ') or line.startswith('|---'):
        continue
    cols = [c.strip() for c in line.strip().strip('|').split(' | ')]
    if len(cols) < 5: continue
    lid = cols[0].strip('`')
    if re.match(r'^(def|thm|prop|lem|cor|ex|rem|conj|q|tab|fig|eq|sec):', lid):
        ledger[lid] = dict(status=cols[2], section=cols[-1], statement=cols[1])
def norm(s):
    s = s or ''
    s = s.replace('--', '–').replace('\\cref{', '').replace('`', '')
    s = re.sub(r'\((?:F|Hi|Ex|Co|St|foundations|history|examples|context|steeper)\b[^()]*(?:\([^()]*\)[^()]*)*\)', '', s)  # check-id parentheses
    s = re.sub(r'\b(F|Hi|Ex|Co|St|foundations|history|examples|context|steeper)\s+[a-z]\d+[^;,)]*', '', s)
    s = re.sub(r'\\[a-zA-Z]+\{?', '', s); s = s.replace('{', '').replace('}', '').replace('$', '')
    s = re.sub(r'\s+', ' ', s).strip().lower().rstrip(';, ')
    return s
paper = {}
for e in envs:
    if e['label']: paper[e['label']] = e
mism = []
for lab, e in paper.items():
    if lab not in ledger:
        print('NOT IN LEDGER:', lab, e['file'], e['line']); continue
    ps, ls = e['status'], ledger[lab]['status']
    if ps is None:
        if not ls.lower().startswith(('definition', 'remark')):
            mism.append((lab, '(none)', ls, e))
        continue
    if norm(ps) != norm(ls):
        mism.append((lab, ps, ls, e))
print('\n# substantive status mismatches (paper | ledger):', len(mism))
for lab, ps, ls, e in mism:
    print(f"{lab}  [{e['file']}:{e['line']}]\n   paper : {ps}\n   ledger: {ls}\n   n(p)  : {norm(ps)}\n   n(l)  : {norm(ls)}")
missing = [l for l in ledger if l not in paper and not l.startswith(('q:', 'tab:', 'fig:', 'eq:', 'sec:'))]
print('\n# ledger ids with no environment in paper:', missing)

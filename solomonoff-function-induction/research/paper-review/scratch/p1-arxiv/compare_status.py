"""Compare each environment's \\status in Paper 1 with the status column of CLAIMS.md §1, and list
ledger rows missing from the paper and paper labels missing from the ledger."""
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
    s = (s or '').replace('--', '–').replace('\\cref{cor:hist:H4}', 'cor:hist:H4')
    s = re.sub(r'\\[a-zA-Z]+\{?', '', s); s = s.replace('{', '').replace('}', '').replace('$', '')
    s = re.sub(r'\s+', ' ', s).strip().lower()
    return s
paper = {e['label']: e for e in envs if e['label']}
mism = []
for lab, e in paper.items():
    if lab not in ledger:
        print('NOT IN LEDGER:', lab, e['file'], e['line']); continue
    ps, ls = e['status'], ledger[lab]['status']
    if ps is None:
        if not ls.lower().startswith(('definition', 'remark')):
            mism.append((lab, '(none)', ls))
        continue
    if norm(ps) != norm(ls):
        mism.append((lab, ps, ls))
print('\n# status mismatches (paper | ledger):', len(mism))
for m in mism:
    print(f"{m[0]}\n   paper : {m[1]}\n   ledger: {m[2]}")
missing = [l for l in ledger if l not in paper and not l.startswith(('q:', 'tab:', 'fig:', 'eq:', 'sec:'))]
print('\n# ledger ids with no environment in paper:', missing)

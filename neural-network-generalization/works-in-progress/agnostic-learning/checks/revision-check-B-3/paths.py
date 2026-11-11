import re, os, sys
doc = sys.argv[1]
base = os.path.dirname(doc)
proj = '/workspace/ai-works/neural-network-generalization'
txt = open(doc).read()
cands = set()
for m in re.finditer(r'\]\(([^)\s]+)\)', txt):
    cands.add(('link', m.group(1)))
for m in re.finditer(r'`([^`$]+)`', txt):
    s = m.group(1)
    if '/' in s or re.search(r'\.(md|py|out|tex|json)$', s):
        cands.add(('code', s))
for kind, p in sorted(cands, key=lambda x: x[1]):
    if p.startswith('NNG/'):
        full = os.path.join(proj, p[4:])
    elif p.startswith('/'):
        full = p
    else:
        full = os.path.normpath(os.path.join(base, p))
    ok = os.path.exists(full)
    print(f"{'OK     ' if ok else 'MISSING'} {kind:4s} {p}  ->  {full}")

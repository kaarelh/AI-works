import re, sys
L = open(sys.argv[1], encoding='utf-8').read().split('\n')
ctx_head=''; ctx_res=''
# strip latex commands and their names so letters inside \mathbb, \rm etc are not counted
cmd = re.compile(r'\\[A-Za-z]+')
out = {}
for i,l in enumerate(L,1):
    if l.startswith('## Appendix R'): break
    if l.startswith('#'): ctx_head=l.strip('# ')[:30]; ctx_res=''
    mres = re.match(r'^\*\*([A-Z][a-z]+ [0-9.a-z′]+)', l)
    if mres: ctx_res=mres.group(1)
    segs = re.findall(r'\$\$(.+?)\$\$|\$(.+?)\$', l)
    for a,b in segs:
        s = a or b
        s2 = re.sub(r'\\(mathbb|mathcal|mathsf|rm|operatorname|text|mathrm)\s*\{[^}]*\}', ' ', s)
        s2 = re.sub(r'\\(mathbb|mathcal|mathsf)\s+[A-Za-z]', ' ', s2)
        s2 = re.sub(r'\\(mathbb|mathcal|mathsf|rm)\s*[A-Za-z]', ' ', s2)
        s2 = cmd.sub(' ', s2)
        s2 = re.sub(r'_\{[^}]*\}', ' ', s2)  # drop subscripts
        s2 = re.sub(r'_[A-Za-z0-9]', ' ', s2)
        for sym in ['m','p','B','E']:
            if re.search(r'(?<![A-Za-z])'+sym+r'|(?<=[0-9A-Za-z])'+sym+r'(?![a-z])', s2) and re.search(sym, s2):
                key=(sym, ctx_head, ctx_res)
                out.setdefault(key, []).append((i, s[:80]))
for (sym,h,r),v in sorted(out.items()):
    print(f'{sym} [{h:30s}|{r:22s}] {len(v)}  e.g. l.{v[0][0]}: {v[0][1]}')

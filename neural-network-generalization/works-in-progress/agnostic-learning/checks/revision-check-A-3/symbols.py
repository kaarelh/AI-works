import re, sys
path = sys.argv[1]
L = open(path, encoding='utf-8').read().split('\n')
# Track context: last heading and last bold result label
ctx_head = ''; ctx_res = ''
pats = {
 'm': r'(?<![A-Za-z\\])m(?![A-Za-z_])(?!_\\sigma)(?!\^\{\\rm cl\})',
 'p': r'(?<![A-Za-z\\{])p(?![A-Za-z])(?!_\\sigma)',
 'rho': r'\\rho(?!_)(?![A-Za-z])',
 'gamma': r'\\gamma(?!_E)(?![A-Za-z])',
 'E': r'(?<![A-Za-z\\{])E(?![A-Za-z_])(?!\^)',
 'B': r'(?<![A-Za-z\\{])B(?![A-Za-z_])',
 'delta': r'\\delta(?![A-Za-z])',
}
stop = None
for i,l in enumerate(L,1):
    if l.startswith('## Appendix R'): break
    if l.startswith('#'): ctx_head = l.strip('# ')[:40]; ctx_res=''
    mres = re.match(r'^\*\*([A-Z][a-z]+ [0-9.a-z′]+)', l)
    if mres: ctx_res = mres.group(1)
    if l.startswith('*Proof'): ctx_res = (ctx_res + ' proof') if 'proof' not in ctx_res else ctx_res
    # extract math segments
    segs = re.findall(r'\$\$(.+?)\$\$|\$(.+?)\$', l)
    math = ' '.join(a or b for a,b in segs)
    for name,pat in pats.items():
        for mm in re.finditer(pat, math):
            s = math[max(0,mm.start()-15):mm.end()+15]
            print(f'{name:6s} l.{i:4d} [{ctx_head[:28]:28s}|{ctx_res[:22]:22s}] ...{s}...')

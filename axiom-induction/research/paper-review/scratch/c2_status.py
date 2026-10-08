import re,glob
S={}
for f in sorted(glob.glob('/home/user/AI-works/axiom-induction/paper/sections/*.tex')):
    t=open(f).read()
    for m in re.finditer(r'\\begin\{(theorem|proposition|lemma|corollary|remark|example|conjecture|definition)\}(\[[^\]]*(?:\[[^\]]*\][^\]]*)*\])?(.{0,700}?)\\label\{([^}]*)\}',t,re.S):
        hdr=m.group(3)
        st=re.search(r'\\status\{((?:[^{}]|\{[^{}]*\})*)\}',hdr)
        src=re.search(r'\\src\{((?:[^{}]|\{[^{}]*\})*)\}',hdr)
        S[m.group(4)]=(st.group(1) if st else None, src.group(1) if src else None, f.split('/')[-1])
C={}
for line in open('/home/user/AI-works/axiom-induction/paper/CLAIMS.md'):
    if line.startswith('| ') and re.match(r'\| [a-z]+:[a-z]+:',line):
        cells=[c.strip() for c in line.strip().strip('|').split(' | ')]
        C[cells[0]]=(cells[2] if len(cells)>2 else '', cells[3] if len(cells)>3 else '')
for k in sorted(C):
    if k in S:
        print(f"{k}\n   PAPER: {S[k][0]} || {S[k][1]}  [{S[k][2]}]\n   CLAIM: {C[k][0]} || {C[k][1]}")
    else:
        print(f"{k}\n   PAPER: (not a theorem env)\n   CLAIM: {C[k][0]} || {C[k][1]}")

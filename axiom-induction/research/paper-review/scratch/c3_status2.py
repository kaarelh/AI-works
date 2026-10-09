import re,glob
def bal(t,i):
    # t[i]=='{' ; return content and end
    d=0
    for j in range(i,len(t)):
        if t[j]=='{': d+=1
        elif t[j]=='}':
            d-=1
            if d==0: return t[i+1:j], j
    return None,None
S={}
envs='theorem|proposition|lemma|corollary|remark|example|conjecture|definition'
for f in sorted(glob.glob('/home/user/AI-works/axiom-induction/paper/sections/*.tex')):
    t=open(f).read()
    for m in re.finditer(r'\\begin\{('+envs+r')\}',t):
        env=m.group(1)
        end=t.find(r'\end{'+env+'}',m.end())
        body=t[m.end():end]
        head=body[:900]
        lab=re.search(r'\\label\{([^}]*)\}',head)
        st=None;src=None
        k=head.find(r'\status{')
        if k>=0: st,_=bal(head,k+7)
        k=head.find(r'\src{')
        if k>=0: src,_=bal(head,k+4)
        line=t[:m.start()].count('\n')+1
        key=lab.group(1) if lab else f'NOLABEL:{f.split("/")[-1]}:{line}'
        S[key]=(env,st,src,f.split('/')[-1],line)
C={}
for line in open('/home/user/AI-works/axiom-induction/paper/CLAIMS.md'):
    if re.match(r'\| [a-z]+:[a-z]+:',line):
        cells=[c.strip() for c in line.strip().strip('|').split(' | ')]
        C[cells[0]]=cells
import json
out=[]
for k in sorted(set(S)|set(C)):
    s=S.get(k); c=C.get(k)
    out.append((k,s,c[2] if c else None, c[3] if c else None))
for k,s,cs,csrc in out:
    print(k)
    print('   PAPER:', s)
    print('   CLAIM:', cs,'||',csrc)

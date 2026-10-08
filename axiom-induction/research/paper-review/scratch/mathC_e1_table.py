import re,sys
txt=open('/home/user/AI-works/axiom-induction/code/results/e1_universal.md').read().replace('(|-','(T-')
secs=re.split(r'\n## phi = ',txt)[1:]
gen_col={'sch':'H_sch','all':'H_all','allq':'H_all','open':'H_open','allq2':'H_all'}
for s in secs:
    head=s.split('\n',1)[0]
    m=re.match(r'(.*), generator (\w+)',head); phi,gen=m.group(1),m.group(2)
    parts=re.split(r'\n\*\*(L0|L1sel|L1)\*\*',s)
    for i in range(1,len(parts),2):
        lik=parts[i]; body=parts[i+1]
        rows=[l for l in body.split('\n') if l.startswith('| ') and not l.startswith('| n ') ]
        hdr=[l for l in body.split('\n') if l.startswith('| n ')][0].split('|')[1:-1]
        hdr=[h.strip() for h in hdr]
        d={}
        for r in rows:
            c=[x.strip() for x in r.split('|')[1:-1]]
            if not c[0].isdigit(): continue
            d[int(c[0])]=dict(zip(hdr,c))
        col=gen_col[gen]
        vals=[d[n][col] if n in d else '-' for n in (4,8,32,256)]
        # first n from which generator mass >=0.99 (mean)
        print(f"{phi:10s} {gen:6s} {lik:6s} gen-mass@4,8,32,256={vals}  MAP256={d[256].get('MAP','?')}  P(T-forall)@256={d[256]['P(T-forall)']}  Mem@8={d[8]['Mem']} overgen@8={d[8]['over-gen']} P(T-inst)@8={d[8].get('P(T-inst)','?')} lo256={d[256].get('lo sch:all','?')}")

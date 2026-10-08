# Independent re-read of E1 per-seed results from code/results/e1_universal.json
import json, collections
d=json.load(open('/home/user/AI-works/axiom-induction/code/results/e1_universal.json'))
R=d['results']
gen_key={'sch':'H_sch','all':'H_all','allq':'H_all','open':'H_open','allq2':'H_all'}
first=collections.defaultdict(list)
inst8=collections.defaultdict(list)
mem8=[];og8=[]
both=collections.defaultdict(list)
for r in R:
    phi,gen,seed=r['phi'],r['gen'],r['seed']
    for lik,v in r['liks'].items():
        rows=v['rows']
        # first n from which generator mass >=0.99 for all later n
        key=gen_key[gen]
        ns=[row['n'] for row in rows]; ms=[row['mass'][key] for row in rows]
        fn=None
        for i in range(len(ns)):
            if all(m>=0.99 for m in ms[i:]): fn=ns[i]; break
        first[(gen,lik)].append((phi,seed,fn))
        for row in rows:
            if row['n']>=8:
                inst8[(gen,lik)].append(row['P_inst'])
            if gen=='sch' and row['n']==8 and lik in('L0','L1'):
                mem8.append(row['mass']['mem']); og8.append(row['mass']['over-general'])
        if lik=='L0' and gen in ('all','allq','open','allq2'):
            for row in rows:
                both[(gen,row['n'])].append((row['mass'].get('H_all+sch'),row['post'].get('H_all+open') if 'post' in row else None,row['mass']['mem'],row['P_forall']))
for k,v in sorted(first.items()):
    fns=[x[2] for x in v]
    print('first n>=0.99',k,'worst',max(fns) if None not in fns else 'never', sorted(set(fns),key=lambda z:(z is None, z)))
for k,v in sorted(inst8.items()):
    print('min P_inst n>=8',k,min(v))
print('max Mem@8 (sch, L0/L1)',max(mem8),' max overgen@8',max(og8))
for g in ('all','allq','open','allq2'):
    for n in (8,16,32,64,256):
        v=both[(g,n)]
        print(g,n,'min H_all+sch',min(x[0] for x in v),' min H_all+open', min((x[1] or 0) for x in v),' min mem',min(x[2] for x in v),' min Pforall',min(x[3] for x in v))

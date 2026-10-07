# Remark after Prop 4.4: MC canonical chain vs L7 sec 8.2 semantics on random propositional context trees.
# Formulas = truth functions over 3 atoms (bitmasks over 8 valuations); complete local logic => theories <-> model sets.
import random
rng=random.Random(11)
NV=8; ALL=(1<<NV)-1
def rf(p=0.5):
    return sum(1<<v for v in range(NV) if rng.random()<p)
def sub(a,b): return a&~b==0
stats=dict(trees=0,allsound=0,coinc_fail=0,unsound=0,differ=0,sup_fail=0,sup_tests=0)
for trial in range(20000):
    # build tree
    nodes=[dict(par=None,kind='@',K=rf(0.7))]
    for _ in range(rng.randint(1,5)):
        par=rng.randrange(len(nodes))
        kind=rng.choice(['SUP','IDL'])
        if kind=='SUP':
            nodes.append(dict(par=par,kind='SUP',A=rf(0.5)))
        else:
            F=[rf(0.5) for _ in range(rng.randint(0,6))]
            B=[(rf(0.6),rf(0.7),rf(0.6)) for _ in range(rng.randint(0,3))]
            nodes.append(dict(par=par,kind='IDL',S=rf(0.6),F=F,B=B))
    N=len(nodes)
    # L7 semantics (top-down; parents have smaller index)
    L=[0]*N
    for x,nd in enumerate(nodes):
        if nd['kind']=='@': L[x]=nd['K']
        elif nd['kind']=='SUP': L[x]=L[nd['par']]&nd['A']
        else:
            m=nd['S']
            for f in nd['F']:
                if sub(L[nd['par']],f): m&=f
            L[x]=m
    # soundness of every Exp instance (w.r.t. L7 Mod)
    sound=True
    for x,nd in enumerate(nodes):
        if nd['kind']=='IDL':
            p=nd['par']
            for (phi,sig,eps) in nd['B']:
                if sub(L[x],phi) and not sub(L[p]&sig,eps): sound=False
    # MC canonical chain (model sets), start from Mod(K) and shrink by bridges
    c=[ALL]*N
    for x,nd in enumerate(nodes):
        c[x]= nd['K'] if nd['kind']=='@' else (nd['A'] if nd['kind']=='SUP' else nd['S'])
    ch=True
    while ch:
        ch=False
        for x,nd in enumerate(nodes):
            if nd['kind']=='@': continue
            p=nd['par']
            if nd['kind']=='SUP':
                new_c=c[x]&c[p]                       # full import
                new_p=c[p]&((ALL&~nd['A'])|c[x])      # discharge A->psi for all psi established
            else:
                new_c=c[x]
                for f in nd['F']:
                    if sub(c[p],f): new_c&=f          # import
                new_p=c[p]
                for (phi,sig,eps) in nd['B']:
                    if sub(c[x],phi) and sub(c[p],sig): new_p&=eps   # export
            if new_c!=c[x] or new_p!=c[p]:
                c[x]=new_c; c[p]=new_p; ch=True
    stats['trees']+=1
    if sound:
        stats['allsound']+=1
        if c!=L: stats['coinc_fail']+=1; print("COINCIDENCE FAILS",nodes,c,L); break
    else:
        stats['unsound']+=1
        if c!=L: stats['differ']+=1
    for x,nd in enumerate(nodes):
        if nd['kind']=='SUP':
            stats['sup_tests']+=1
            if c[x]!=(c[nd['par']]&nd['A']): stats['sup_fail']+=1
print(stats)

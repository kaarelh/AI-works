# Blame ambiguity in a Hilbert practice {K,S,MP,DN} + fallacy AC (affirming the consequent).
# Bounded closure: formulas over atoms {p,q,F} (F = falsum) with at most L leaves.
# A "conflict" = set of schemas whose instances derive F from a designated context (within the bound).
import itertools, sys
L=int(sys.argv[1]) if len(sys.argv)>1 else 6
ATOMS=['p','q','F']
def imp(a,b): return ('>',a,b)
def leaves(f): return 1 if isinstance(f,str) else leaves(f[1])+leaves(f[2])
by={1:ATOMS[:]}
for n in range(2,L+1):
    by[n]=[imp(a,b) for k in range(1,n) for a in by[k] for b in by[n-k]]
U=[f for n in range(1,L+1) for f in by[n]]; Uset=set(U)
def axioms(name):
    out=[]
    if name=='K':
        for la in range(1,L+1):
            for lb in range(1,L+1):
                if 2*la+lb>L: continue
                for a in by[la]:
                    for b in by[lb]: out.append(imp(a,imp(b,a)))
    if name=='S':
        for la in range(1,L+1):
          for lb in range(1,L+1):
            for lc in range(1,L+1):
              if 3*la+2*lb+2*lc>L: continue
              for a in by[la]:
                for b in by[lb]:
                  for c in by[lc]:
                    out.append(imp(imp(a,imp(b,c)),imp(imp(a,b),imp(a,c))))
    if name=='DN':
        for a in U:
            f=imp(imp(imp(a,'F'),'F'),a)
            if f in Uset: out.append(f)
    return out
AX={n:axioms(n) for n in ["K","S","DN"]}
print("L=",L,"|U|=",len(U),"axiom instances:",{k:len(v) for k,v in AX.items()})
def closure(rules,ctx):
    D=set(ctx)
    for r in rules:
        if r in AX: D|=set(AX[r])
    # index implications
    changed=True
    while changed:
        changed=False
        new=set()
        for f in D:
            if isinstance(f,tuple):
                a,b=f[1],f[2]
                if 'MP' in rules and a in D and b not in D: new.add(b)
                if 'AC' in rules and b in D and a not in D: new.add(a)
        if new: D|=new; changed=True
        if 'F' in D: return D
    return D
def conflict(rules,ctx): return 'F' in closure(rules,ctx)
P=['K','S','MP','DN','AC']
def minimal_conflicts(ctxs):
    confs=[frozenset(s) for r in range(1,len(P)+1) for s in itertools.combinations(P,r)
           if any(conflict(set(s),c) for c in ctxs)]
    return [c for c in confs if not any(d<c for d in confs)]
def diagnoses(mcs):
    hs=[frozenset(s) for r in range(0,len(P)+1) for s in itertools.combinations(P,r) if all(set(s)&c for c in mcs)]
    return [h for h in hs if not any(g<h for g in hs)]
A1=[('p' if False else 'q'), imp('p','q'), imp('p','F')]   # consistent: p false, q true
for name,ctxs in [('A={empty}',[[]]),('A={A1}',[A1]),('A={empty,A1}',[[],A1])]:
    genuine_ok = not any(conflict({'K','S','MP','DN'},c) for c in ctxs)
    mcs=minimal_conflicts(ctxs); dg=diagnoses(mcs)
    print(name,'| genuine part coherent:',genuine_ok)
    print('   minimal conflicts:',[sorted(c) for c in mcs])
    print('   minimal diagnoses:',[sorted(d) for d in dg])
    coll=set().union(*mcs)-{'AC'} if mcs else set()
    print('   collateral (genuine schemas in some minimal conflict):',sorted(coll))
# world blame: closed instance of AC with true premises, false conclusion, under the 2-valued semantics
def val(f): return {'p':None,'q':None,'F':False}[f] if isinstance(f,str) else ((not val(f[1])) or val(f[2]))
B=imp('F','F'); A='F'
print('AC closed instance: premises',B,imp(A,B),'values',val(B),val(imp(A,B)),'conclusion',A,val(A))

# ---- bilateral designated positions [A : D]: a conflict = deriving F or any denied judgment ----
def conflict_pos(rules,pos):
    A,Dn=pos
    C=closure(rules,A)
    return 'F' in C or any(d in C for d in Dn)
def minimal_conflicts_pos(poss):
    confs=[frozenset(s) for r in range(1,len(P)+1) for s in itertools.combinations(P,r)
           if any(conflict_pos(set(s),c) for c in poss)]
    return [c for c in confs if not any(d<c for d in confs)]
for name,poss in [('positions {[A1 : p]}',[(A1,['p'])]),('positions {[empty:], [A1 : p]}',[([],[]),(A1,['p'])])]:
    mcs=minimal_conflicts_pos(poss)
    print(name,'| minimal conflicts:',[sorted(c) for c in mcs],'| diagnoses:',[sorted(d) for d in diagnoses(mcs)],
          '| collateral:',sorted(set().union(*mcs)-{'AC'}))
# the two-rule core of the lower bound: practice {MP, AC}, context A1
P=['MP','AC']
mcs=minimal_conflicts([A1]); print('core {MP,AC} on A1: minimal conflicts',[sorted(c) for c in mcs],'diagnoses',[sorted(d) for d in diagnoses(mcs)])
print('closure of A1 under AC alone:',sorted(map(str,closure({'AC'},A1))))

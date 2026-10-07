import itertools
T={1:lambda p,q: p and q, 2:lambda p,q: p and not q, 3:lambda p,q: (not p) and q}
def valid(i, prem, concl):
    for p,q in itertools.product([0,1],repeat=2):
        if T[i](p,q) and all(f(p,q) for f in prem) and not concl(p,q): return False
    return True
P=lambda p,q:p; Q=lambda p,q:q; AND=lambda p,q:p and q; NAND=lambda p,q: not(p and q); BOT=lambda p,q:False
steps={'|>p':([],P),'|>q':([],Q),'p,q|>p&q':([P,Q],AND),'|>~(p&q)':([],NAND),'p&q,~(p&q)|>bot':([AND,NAND],BOT)}
for n,(pr,c) in steps.items():
    print(n,[i for i in (1,2,3) if valid(i,pr,c)])

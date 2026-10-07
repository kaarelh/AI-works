import itertools
# --- Thm 2.4 check via truth tables over p,q ---
def models(T):
    return [(p,q) for p,q in itertools.product([0,1],repeat=2) if all(f(p,q) for f in T)]
P=lambda p,q:p; Q=lambda p,q:q; NP=lambda p,q:1-p; NQ=lambda p,q:1-q
T={1:[P,Q],2:[P,NQ],3:[NP,Q]}
def entails(T,prem,concl):  # T u prem |= concl ; concl None means bottom
    for v in models(T):
        if all(f(*v) for f in prem):
            if concl is None or not concl(*v): return False
    return True
AND=lambda p,q:p&q; NAND=lambda p,q:1-(p&q)
steps={'|>p':([],P),'|>q':([],Q),'p,q|>p&q':([P,Q],AND),'|>~(p&q)':([],NAND),'p&q,~(p&q)|>bot':([AND,NAND],None)}
for name,(prem,c) in steps.items():
    print(name,[i for i in T if entails(T[i],prem,c)])
print("each h_i coherent:",[len(models(T[i]))>0 for i in T])

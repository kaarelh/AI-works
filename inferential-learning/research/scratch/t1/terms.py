# terms: tuples (symbol, args...) ; variables: ('?', name)
import itertools
def is_var(t): return t[0]=='?'
def size(t):
    return 1 if is_var(t) else 1+sum(size(a) for a in t[1:])
def vars_of(t, acc=None):
    if acc is None: acc=set()
    if is_var(t): acc.add(t[1])
    else:
        for a in t[1:]: vars_of(a,acc)
    return acc
def mu(t): return size(t)-len(vars_of(t))
def match(pat, t, sub=None):
    if sub is None: sub={}
    if is_var(pat):
        v=pat[1]
        if v in sub: return sub if sub[v]==t else None
        sub=dict(sub); sub[v]=t; return sub
    if is_var(t) or pat[0]!=t[0] or len(pat)!=len(t): return None
    for a,b in zip(pat[1:],t[1:]):
        sub=match(a,b,sub)
        if sub is None: return None
    return sub
def is_instance(t, pat): return match(pat,t) is not None
def lgg_list(ts):
    table={}
    cnt=[0]
    def A(col):
        f=col[0]
        if not is_var(f) and all((not is_var(u)) and u[0]==f[0] and len(u)==len(f) for u in col):
            return (f[0],)+tuple(A(tuple(u[i] for u in col)) for i in range(1,len(f)))
        if col not in table:
            table[col]=('?','z%d'%cnt[0]); cnt[0]+=1
        return table[col]
    return A(tuple(ts))
def canon(t):
    # rename variables in order of first occurrence
    ren={}
    def R(u):
        if is_var(u):
            if u[1] not in ren: ren[u[1]]='v%d'%len(ren)
            return ('?',ren[u[1]])
        return (u[0],)+tuple(R(a) for a in u[1:])
    return R(t)
def show(t):
    if is_var(t): return t[1]
    if len(t)==1: return t[0]
    return t[0]+'('+','.join(show(a) for a in t[1:])+')'
def ground_terms(sig, maxsize):
    # sig: dict symbol->arity
    by={}
    for n in range(1,maxsize+1):
        out=[]
        for f,ar in sig.items():
            if ar==0:
                if n==1: out.append((f,))
            else:
                # compositions of n-1 into ar positive parts
                for parts in itertools.product(range(1,n), repeat=ar):
                    if sum(parts)!=n-1: continue
                    for args in itertools.product(*[by[p] for p in parts]):
                        out.append((f,)+args)
        by[n]=out
    return by

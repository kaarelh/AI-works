from terms import *
def rename(t, suffix):
    if is_var(t): return ('?', t[1]+suffix)
    return (t[0],)+tuple(rename(a,suffix) for a in t[1:])
def walk(t, s):
    while is_var(t) and t[1] in s: t=s[t[1]]
    return t
def occurs(v, t, s):
    t=walk(t,s)
    if is_var(t): return t[1]==v
    return any(occurs(v,a,s) for a in t[1:])
def unify(a,b,s):
    a=walk(a,s); b=walk(b,s)
    if is_var(a):
        if is_var(b) and a[1]==b[1]: return s
        if occurs(a[1],b,s): return None
        s=dict(s); s[a[1]]=b; return s
    if is_var(b): return unify(b,a,s)
    if a[0]!=b[0] or len(a)!=len(b): return None
    for x,y in zip(a[1:],b[1:]):
        s=unify(x,y,s)
        if s is None: return None
    return s
def resolve(t,s):
    t=walk(t,s)
    if is_var(t): return t
    return (t[0],)+tuple(resolve(a,s) for a in t[1:])
def glb(terms_):
    ts=[rename(t,'_%d'%i) for i,t in enumerate(terms_)]
    s={}
    for t in ts[1:]:
        s=unify(ts[0],t,s)
        if s is None: return None
    return resolve(ts[0],s)
def equiv(a,b):
    return canon(a)==canon(b)

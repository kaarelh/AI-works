import itertools
def imp(a,b): return ('>',a,b)
F='F'
K1=imp(F,imp('p',F)); K2=imp(imp('p',F),imp(F,imp('p',F)))
isK=lambda f: isinstance(f,tuple) and f[0]=='>' and isinstance(f[2],tuple) and f[2][0]=='>' and f[2][2]==f[1]
def AC(b,ab): return ab[1] if ab[0]=='>' and ab[2]==b else None
print('K-instances:',isK(K1),isK(K2))
x=AC(K1,K2); print('AC(K1,K2) =',x); y=AC(x,K1); print('AC(p->F, K1) =',y)
# closure of A1 under AC alone
A1={'q',imp('p','q'),imp('p',F)}; X=set(A1)
while True:
    new={AC(b,f) for b in X for f in X if isinstance(f,tuple) and AC(b,f) is not None}-X
    if not new: break
    X|=new
print('AC-closure of A1:',X)
# classical validity of K (truth table) and soundness on A1 (p=0,q=1)
print('K valid:',all((not a) or ((not b) or a) for a in (0,1) for b in (0,1)))

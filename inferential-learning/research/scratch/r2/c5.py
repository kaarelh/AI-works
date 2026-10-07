import itertools
def models(fs, n):
    return [v for v in itertools.product([0,1],repeat=n) if all(f(*v) for f in fs)]
imp=lambda a,b:(not a) or b
# vars p1,p2,q1,q2
K=[lambda p1,p2,q1,q2: imp(p1,q1), lambda p1,p2,q1,q2: imp(p2,q2)]
A=[lambda p1,p2,q1,q2: q1 or q2, lambda p1,p2,q1,q2: not p1, lambda p1,p2,q1,q2: not p2]
conv=[lambda p1,p2,q1,q2: imp(q1,p1), lambda p1,p2,q1,q2: imp(q2,p2)]
M=models(K+A,4); print("K+A models",M)
print("K+A entails q1?", all(v[2] for v in M), "q2?", all(v[3] for v in M))
print("K+A+conv consistent?", bool(models(K+A+conv,4)))
# sprinkler: vars rain,spr,wet
K2=[lambda r,s,w: imp(r,w), lambda r,s,w: imp(s,w), lambda r,s,w: not(r and s)]
A2=[lambda r,s,w: w]
clark=[lambda r,s,w: w==(r or s)]
conv2=[lambda r,s,w: imp(w,r), lambda r,s,w: imp(w,s)]
print("clark consistent", bool(models(K2+A2+clark,3)), "perlaw consistent", bool(models(K2+A2+conv2,3)))
print("full Clark (rain,spr undefined -> false) consistent", bool(models(K2+A2+clark+[lambda r,s,w: not r, lambda r,s,w: not s],3)))

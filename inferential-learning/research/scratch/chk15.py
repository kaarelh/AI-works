# Exhaustive check of Thm 1.5(b),(c) on all Moore families over n<=4 elements, sound model sets.
import itertools, sys
def moore_families(n):
    full=(1<<n)-1
    subs=list(range(1<<n))
    # enumerate families containing full, closed under intersection
    others=[s for s in subs if s!=full]
    res=[]
    # brute force over 2^(2^n -1) families: n=3 -> 128, n=4 -> 32768
    for mask in range(1<<len(others)):
        fam=[full]+[others[i] for i in range(len(others)) if mask>>i&1]
        fs=set(fam)
        ok=all((a&b) in fs for a in fam for b in fam)
        if ok: res.append(fam)
    return res
def run(n, sound_only=True):
    full=(1<<n)-1
    fams=moore_families(n)
    tested=fb=fc=0; fc_uns=0
    for fam in fams:
        fs=set(fam)
        def C(X):
            out=full
            for T in fam:
                if X & ~T==0: out&=T
            return out
        proper=[T for T in fam if T!=full]
        maximal=[T for T in proper if not any(T!=U and T&~U==0 for U in proper)]
        # points
        pts=[]
        for T in proper:
            common=full
            for U in fam:
                if U!=T and T&~U==0: common&=U
            if common & ~T: pts.append(T)
        cand = proper if sound_only else [s for s in range(full)]  # models' theories != S
        for mmask in range(1<<len(cand)):
            models=[cand[i] for i in range(len(cand)) if mmask>>i&1]
            def ThMod(X):
                out=full
                for m in models:
                    if X&~m==0: out&=m
                return out
            strong=all(C(X)==ThMod(X) for X in range(1<<n))
            weak=all(any(X&~m==0 for m in models) for X in range(1<<n) if C(X)!=full)
            mset=set(models)
            ptsreal=all(P in mset for P in pts)
            maxreal=all(T in mset for T in maximal)
            if sound_only:
                tested+=1
                fb+= strong!=ptsreal
                fc+= weak!=maxreal
            else:
                if weak!=maxreal: fc_uns+=1
    return len(fams),tested,fb,fc,fc_uns
#print("n=3 sound:",run(3))
#print("n=3 unsound (models arbitrary proper sets):",run(3,False))
#print("n=4 sound:",run(4))

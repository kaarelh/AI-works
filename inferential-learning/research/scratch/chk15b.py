from chk15 import moore_families
n=3; full=7
bad_impl=0; fwd=0
for fam in moore_families(n):
    def C(X):
        out=full
        for T in fam:
            if X&~T==0: out&=T
        return out
    proper=[T for T in fam if T!=full]
    maximal=[T for T in proper if not any(T!=U and T&~U==0 for U in proper)]
    cand=list(range(full))
    for mmask in range(1<<len(cand)):
        models=[cand[i] for i in range(len(cand)) if mmask>>i&1]
        weak=all(any(X&~m==0 for m in models) for X in range(8) if C(X)!=full)
        maxreal=all(T in set(models) for T in maximal)
        if maxreal and not weak: bad_impl+=1
        if weak and not maxreal: fwd+=1
print("unsound n=3: (<=) failures:",bad_impl," (=>) failures:",fwd)

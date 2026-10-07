p='sections/experiments.tex'
s=open(p).read()
def rep(old,new):
    global s
    assert old in s, old[:90]
    s=s.replace(old,new)
rep(r"(With leading quantifiers stripped, Q4 becomes an instance of $z+0=z$; the referee re-ran \DTRC{} so, with the same labels recovered and no non-target probe \src{referee R13}.)",
    r"(With leading quantifiers stripped, Q4 becomes an instance of $z+0=z$ and Q6 of $z\cdot0=0$; the referee re-ran \DTRC{} so and found ARI $1$ on unambiguous data, Q4 and Q6 absorbed into the clusters of these schemas, and no non-target probe \src{referee R13}.)")
rep(r"A \DTRC{} run took under $1$\,s (PA) or $6$\,s (ZF)",r"A \DTRC{} run took at most $0.8$\,s (PA) or $6$\,s (ZF)")
open(p,'w').write(s)

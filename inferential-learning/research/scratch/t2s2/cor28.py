import itertools, random
# Chain h_n = Cn_CPC{~p_i : i<n}, h_omega = Cn_CPC{~p_i : all i}; all coherent with A={emptyset}.
# Target-dependent designation: environment designates (a stream of) target-coherent contexts,
# eventually including every target-coherent singleton {p_j}.  {p_j} is h_n-coherent iff j>=n (check by truth table on p_0..p_{N-1}).
N=7
def coherent(n,ctx):  # is ctx u {~p_i:i<n} satisfiable? n=None means omega (restricted to N atoms)
    lim = N if n is None else n
    for v in itertools.product([0,1],repeat=N):
        if all(v[i]==0 for i in range(min(lim,N))) and all(v[j]==1 for j in ctx): return True
    return False
assert all(coherent(n,[j])==(j>=n) for n in range(N) for j in range(N))
assert all(not coherent(None,[j]) for j in range(N))
# learner: output h_{min j with {p_j} designated}, else h_omega
def run(target,T=400):
    singles=[j for j in range(N) if coherent(target,[j])]
    stream=[]; out=None
    for t in range(T):
        if singles and random.random()<0.05: stream.append(singles[len(stream)%len(singles)])
        out = min(stream) if stream else 'omega'
    return out
random.seed(0)
ok=all(run(n)==n for n in range(N) for _ in range(20)) and all(run(None)=='omega' for _ in range(20))
print("learner identifies every member of chain+union from target-dependent designations:",ok)

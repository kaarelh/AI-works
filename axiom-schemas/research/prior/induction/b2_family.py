# Prop B2: pairwise-unsound infinite families of raw induction instances; consequences for unions H_k.
import itertools
from raw_common import *
from raw_search import pretty, rename_pretty

NMAX = 10
# ---------------- family F' : phi_n = (g_n(x) = x),  g_n(x) = 0+(0+...(0+x)) ----------------
def phi(n): return eq(g(n, X), X)
def Ln(n):
    a, b, c = MV('a'), MV('b'), MV('c')
    return IMP(AND(eq(g(n, a), Z), ALL(X, IMP(eq(g(n, b), X), eq(g(n, c), S(X))))), ALL(X, eq(g(n, b), X)))
def Istar(n):
    return IMP(AND(eq(g(n, Z), Z), ALL(X, IMP(eq(g(n, Z), X), eq(g(n, S(Z)), S(X))))), ALL(X, eq(g(n, Z), X)))

ok = True
for n in range(NMAX + 1):
    assert truth(Ind(phi(n)))                         # each member is a true sentence
    assert truth(Istar(n)) is False                   # each I*_n is false
for n in range(NMAX + 1):
    for m in range(n + 1, NMAX + 1):
        L = lgg_list([Ind(phi(n)), Ind(phi(m))])
        ok &= canon(L) == canon(Ln(n))
        ok &= is_instance(Istar(n), L)
print("F': for all 0<=n<m<=%d, lgg(Ind phi_n, Ind phi_m) == L_n and I*_n is a false instance:" % NMAX, ok)
print("   L_2 =", rename_pretty(Ln(2)))
print("   I*_2 =", pretty(Istar(2)), "  true:", truth(Istar(2)))
ok = all(is_instance(Istar(M), Ln(a)) for a in range(NMAX + 1) for M in range(a, NMAX + 1))
print("F': I*_M is an instance of L_a for all a<=M<=%d:" % NMAX, ok)
# lgg of every subset of size >= 2 is L_min
ok = True; cnt = 0
idx = list(range(8))
for r in range(2, len(idx) + 1):
    for sub in itertools.combinations(idx, r):
        cnt += 1
        ok &= canon(lgg_list([Ind(phi(i)) for i in sub])) == canon(Ln(min(sub)))
print("F': lgg of each of the %d subsets of {0..7} with >=2 members equals L_min:" % cnt, ok)

# ---------------- family F : psi_n = (S^n0 + x = S^n x) ----------------
def psi(n): return eq(add(num(n), X), num(n, X))
def Kn(n):
    z1, z2 = MV('z1'), MV('z2')
    return IMP(AND(eq(add(num(n, z1), Z), num(n, z1)),
                   ALL(X, IMP(eq(add(num(n, z1), X), num(n, z2)), eq(add(num(n, z1), S(X)), num(n + 1, z2))))),
               ALL(X, eq(add(num(n, z1), X), num(n, z2))))
def Jstar(n): return subst_meta(Kn(n), {'z1': Z, 'z2': Z})
ok = True
for n in range(NMAX + 1):
    assert truth(Ind(psi(n))) and truth(Jstar(n)) is False
    for m in range(n + 1, NMAX + 1):
        L = lgg_list([Ind(psi(n)), Ind(psi(m))])
        ok &= canon(L) == canon(Kn(n)) and is_instance(Jstar(n), L)
print("F : for all 0<=n<m<=%d, lgg(Ind psi_n, Ind psi_m) == K_n and J*_n is a false instance:" % NMAX, ok)
print("   K_0 =", rename_pretty(Kn(0)))
print("   J*_0 =", pretty(Jstar(0)))

# ---------------- untagged unions H_k: the cautious verifier contains the false I*_M ----------------
def set_partitions_le_k(items, k):
    def rec(i, blocks):
        if i == len(items):
            yield [list(b) for b in blocks]; return
        for b in blocks:
            b.append(items[i]); yield from rec(i + 1, blocks); b.pop()
        if len(blocks) < k:
            blocks.append([items[i]]); yield from rec(i + 1, blocks); blocks.pop()
    yield from rec(0, [])
print("H_k: D = {Ind phi_0..Ind phi_N}; is I*_N in every minimal member of VS_{H_k}(D) (i.e. in cap VS)?")
for N in range(1, 7):
    for k in range(1, N + 1):          # need N+1 > k
        D = [Ind(phi(i)) for i in range(N + 1)]
        allin = True; nparts = 0
        for part in set_partitions_le_k(D, k):
            nparts += 1
            if not any(is_instance(Istar(N), lgg_list(b)) for b in part):
                allin = False; break
        print("   N+1=%d k=%d partitions=%d  I*_N in cap VS: %s" % (N + 1, k, nparts, allin))
# and with k = N+1 (enough schemas for singletons) the cautious verifier is sound on this data:
N = 3; D = [Ind(phi(i)) for i in range(N + 1)]
print("   control: k=N+1=%d, the all-singletons partition is a member of VS; I*_N in it:" % (N + 1),
      any(is_instance(Istar(N), d) for d in D))

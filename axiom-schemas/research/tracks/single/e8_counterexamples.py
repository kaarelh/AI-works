# e8: the counterexamples of Section 6 checked with the INDEPENDENT brute-force enumerator, and the
# explicit escalation chain of Theorem F (lower bound).
import time
from dtcore import *
from dtfeat import Prefix
from dtenum import enumerate_covering, minimal_elements
from dtwitness import events
X, Y = H(0), H(1)


def check(name, T, ths, smax, amax, arT, arF, consts=('0',), funcs=(('S', 1),)):
    ev, D = events(T, ths)
    print(name)
    print('   T* =', pp(T))
    for d in D:
        print('   datum', pp(d))
    print('   events', {k: ev[k] for k in ('R*', 'R', 'N', 'D', 'Upat', 'U')})
    t = time.time()
    E = enumerate_covering(D, smax, amax=amax, arities_T=arT, arities_F=arF, consts=consts, funcs=funcs)
    mins, _ = minimal_elements(E)
    bad = [U for U in E if not subsumes(U, T)]
    print('   brute force (size<=%d, args<=%d): %d covering DT° templates, minimal: %s' % (
        smax, amax, len(E), [pp(m) for m in mins]))
    print('   covering templates not >= T*: %d; e.g. %s' % (len(bad), pp(min(bad, key=size)) if bad else '-'))
    P = Prefix(D)
    satmins = P.minimal()[0]
    print('   Sat-minimal (theory):', [pp(m) for m in satmins],
          ' same as brute force:', len(satmins) == len(mins) and all(any(equivalent(a, b) for b in mins) for a in satmins))
    print('   (%.1fs)' % (time.time() - t))
    return D, bad


# Prop D.4
Tu = AND(ALL(ALL(eq(S(M('f', V(1), V(0))), Z))), ALL(ALL(eq(M('f', V(1), S(V(0))), Z))))
D, bad = check('Prop D.4', Tu, [{'f': X}, {'f': Y}, {'f': S(X)}], 18, 2, (0, 1, 2), (0,))
q = instantiate(Tu, {'f': Z})
print('   witness instance T*[f:=0] =', pp(q), ' missed by:', [pp(U) for U in bad if not covers(U, q)][:3])

# Prop D.5
Tv = ALL(eq(Z, M('f', V(0))))
D, bad = check('Prop D.5', Tv, [{'f': Z}, {'f': X}], 9, 2, (0, 1), (0,))
q = instantiate(Tv, {'f': S(X)})
print('   witness instance T*[f:=Sz] =', pp(q), ' missed by:', [pp(U) for U in bad if not covers(U, q)][:3])

# Example D.6
Tw = AND(ALL(ALL(eq(M('f', V(1), V(0)), Z))), ALL(eq(V(0), Z)))
D, bad = check('Example D.6', Tw, [{'f': X}, {'f': Y}], 18, 1, (0, 1, 2), (0,))
q = instantiate(Tw, {'f': S(X)})
print('   witness instance T*[f:=Sz1] =', pp(q), ' missed by:', [pp(U) for U in bad if not covers(U, q)][:3])

# Theorem F lower bound: explicit elastic chain of length N+1 with queries of size <= N
print('Theorem F lower-bound chain')
for N in [5, 8, 12, 16]:
    k = N - 3
    chain = [eq(Z if True else None, Z)]
    def Sk(t, j):
        for _ in range(j):
            t = S(t)
        return t
    chain = [eq(Sk(Z, k), Z), eq(Sk(PA, k), Z)] + [eq(Sk(Z, j), Z) for j in range(k - 1, -1, -1)] + \
            [eq(Z, S(Z)), NOT(eq(Z, Z))]
    ok = True
    for j in range(1, len(chain)):
        if Prefix(chain[:j]).accepts(chain[j]):
            ok = False
    print('   N=%2d  chain length %d  max query size %d  every query escalated: %s' % (
        N, len(chain), max(size(c) for c in chain), ok))

# Theorem F, quadratic lower bound: d1 = A^b (0=0 & ... & 0=0) (m atoms), d2 = same with a=0,
# then q_{j,k} = d1 with the j-th left-hand side replaced by the k-th bound variable: each query adds a
# new bound variable to the scope of one slot, so it violates a Scope feature and is escalated.
print('Theorem F quadratic lower-bound chain (scope growth)')
def conjs(parts):
    f = parts[0]
    for g in parts[1:]:
        f = AND(f, g)
    return f
def allb(f, b):
    for _ in range(b):
        f = ALL(f)
    return f
for m in [2, 4, 6, 8]:
    b = m
    d1 = allb(conjs([eq(Z, Z)] * m), b)
    d2 = allb(conjs([eq(PA, Z)] * m), b)
    chain = [d1, d2]
    for j in range(m):
        for k in range(b):
            lhs = [Z] * m
            lhs[j] = V(k)
            chain.append(allb(conjs([eq(t, Z) for t in lhs]), b))
    ok = all(not Prefix(chain[:i]).accepts(chain[i]) for i in range(1, len(chain)))
    N = max(size(c) for c in chain)
    print('   m=b=%d  N=max size=%d  chain length %d (= 2 + m*b)  every query escalated: %s   (N+1)^2/25 = %.1f' % (
        m, N, len(chain), ok, (N + 1) ** 2 / 25))

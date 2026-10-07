# e10 (revision): Theorem E for ground templates, and the kappa lower bound / exact rate (Prop E.2).
#  (1) ground target T* (a single ZF-style axiom): Acc({T*}) = {T*} (one datum is an anchor), and the
#      tagged bound with c_i := 1, lambda_i := 1 dominates the exact (1 - pi_i)^N.
#  (2) for every non-valid pair (sigma, r) of the three laws of e7 (+ the law of referee t6):
#      beta = max_u Lambda(A_u) (= max weight of a compatible set of the support),
#      exact P[coincidence at (sigma,r) in D_N] by inclusion-exclusion over the maximal compatible sets,
#      and the check  beta^N <= exact <= K beta^N  (K = number of maximal compatible sets),
#      next to the pair-splitting term (1 - kappa)^floor(N/2) of Thm E(a).
import itertools, math
from dtcore import *
from dtfeat import Prefix
from dtunion import ematch, compatible
from e7_rates import cases, params, upairs

X = H(0)
print('== (1) ground templates')
EXT = ALL(ALL(IMP(ALL(IFF(mem(V(0), V(1)), mem(V(0), V(2)))), eq(V(1), V(0)))))
P1 = Prefix([EXT])
qs = [EXT, ALL(ALL(IMP(ALL(IFF(mem(V(0), V(2)), mem(V(0), V(1)))), eq(V(1), V(0))))),
      ALL(ALL(IMP(ALL(IFF(mem(V(0), V(1)), mem(V(0), V(2)))), eq(V(0), V(1))))), eq(Z, Z)]
print('  T* = Extensionality (ground). Acc({T*}) accepts exactly T* among %d test sentences: %s'
      % (len(qs), [P1.accepts(q) for q in qs] == [True, False, False, False]))
for pi in (0.05, 0.2, 0.5):
    rows = []
    for N in (1, 5, 10, 20, 50, 100):
        exact = (1 - pi) ** N
        bnd = math.sqrt(math.e) * math.exp(-3 * N * pi / 8)
        rows.append('N=%d: %.3g<=%.3g %s' % (N, exact, bnd, 'ok' if exact <= bnd else 'VIOLATED'))
    print('  ground tag, pi=%.2f: P[not exact]=(1-pi)^N vs sqrt(e)exp(-3N pi/8):  %s' % (pi, '; '.join(rows)))

print('== (2) kappa terms: lower bound beta^N and exact rate (finite support)')
Tt6 = ALL(eq(Z, M('f', V(0))))
Tgap = ALL(ALL(eq(M('f', V(1)), M('g', V(0)))))
gap_pool = [{'f': fb, 'g': gb} for fb in (X, S(X)) for gb in (X, Z, S(X))]
cases = list(cases) + [('referee t6 law  Ax(0=f(x)), f ~ {0:.4, z:.3, Sz:.3}', Tt6,
                        [{'f': Z}, {'f': X}, {'f': S(X)}], [0.4, 0.3, 0.3]),
                       ('gap law  AxAy(f(x)=g(y)), f ~ U{z,Sz}, g ~ U{z,0,Sz} indep.', Tgap, gap_pool, [1 / 6] * 6)]
from dtwitness import events, anchor_by_features
from e7_rates import bound as thmE_bound
for name, T, pool, w in cases:
    res = params(T, pool, w)
    pairs = upairs(T)
    print('--', name, '  T* =', pp(T), '  non-valid pairs:', len(pairs))
    data = [instantiate(T, th) for th in pool]
    worst = []
    for (sp, r), kap in zip(pairs, res['kappa']):
        E = {}
        for i, s in enumerate(data):
            e = ematch(sub(s, sp), sub(s, r))
            if e is not None:
                E[i] = e
        idx = sorted(E)
        cliques = []
        for k in range(len(idx), 0, -1):
            for B in itertools.combinations(idx, k):
                if all(compatible(E[a], E[b]) for a, b in itertools.combinations(B, 2)):
                    if not any(set(B) <= set(C) for C in cliques):
                        cliques.append(B)
        beta = max([sum(w[i] for i in C) for C in cliques] + [0.0])
        K = len(cliques)
        def exact(N):
            tot = 0.0
            for j in range(1, K + 1):
                for J in itertools.combinations(cliques, j):
                    inter = set(J[0]).intersection(*map(set, J[1:]))
                    tot += (-1) ** (j + 1) * sum(w[i] for i in inter) ** N
            return tot
        ok = True
        row = []
        for N in (2, 4, 8, 16, 24):
            ex = exact(N)
            lo, hi = beta ** N, K * beta ** N
            ok &= (lo - 1e-12 <= ex <= hi + 1e-12)
            row.append((N, ex, lo, (1 - kap) ** (N // 2)))
        worst.append((beta, K, kap, ok, row, sp, r))
    worst.sort(key=lambda z: -z[0])
    for beta, K, kap, ok, row, sp, r in worst[:3]:
        print('   pair sigma=%s r=%s: beta=%.4f K=%d 1-kappa=%.4f sqrt(1-kappa)=%.4f  beta^N<=exact<=K beta^N: %s'
              % (sp, r, beta, K, 1 - kap, math.sqrt(max(0, 1 - kap)), ok))
        print('      ' + '; '.join('N=%d exact=%.3g beta^N=%.3g pairsplit=%.3g' % z for z in row))
    print('   all %d pairs satisfy beta^N <= exact <= K beta^N: %s' % (len(worst), all(z[3] for z in worst)))

print('== (3) exact P[D_N not an anchor] for the two small laws, with the lower bounds')
for name, T, pool, w in cases[-2:]:
    res = params(T, pool, w)
    n = len(pool)
    status = {}
    disagree = 0
    for k in range(1, n + 1):
        for S_ in itertools.combinations(range(n), k):
            ev, D = events(T, [pool[i] for i in S_])
            st_feat = anchor_by_features(T, D)[0]
            disagree += (ev['pred'] != st_feat)
            status[S_] = ev['pred']
    def p_not_anchor(N):
        tot = 0.0
        for S_, anc in status.items():
            if anc:
                continue
            pS = 0.0
            for j in range(0, len(S_) + 1):
                for Sp in itertools.combinations(S_, j):
                    pS += (-1) ** (len(S_) - j) * sum(w[i] for i in Sp) ** N
            tot += pS
        return tot
    betas = []
    data = [instantiate(T, th) for th in pool]
    for (sp, r) in upairs(T):
        E = {i: ematch(sub(s, sp), sub(s, r)) for i, s in enumerate(data)}
        E = {i: e for i, e in E.items() if e is not None}
        best = 0.0
        for k in range(1, len(E) + 1):
            for B in itertools.combinations(sorted(E), k):
                if all(compatible(E[a], E[b]) for a, b in itertools.combinations(B, 2)):
                    best = max(best, sum(w[i] for i in B))
        betas.append(best)
    print('--', name, ' (Thm D events vs feature-template anchor check disagree on %d support subsets)' % disagree)
    print('    N   exact P[not anchor]   old lower max((1-rho)^N,(1-nu)^N)   new lower max(..., beta^N)   Thm E upper')
    for N in (2, 4, 8, 12, 16, 24):
        old = max([(1 - r) ** N for r in res['rho']] + [(1 - v) ** N for v in res['nu']])
        new = max([old] + [b ** N for b in betas])
        print('   %2d   %.6f              %.6f                          %.6f                   %.6f'
              % (N, p_not_anchor(N), old, new, thmE_bound(res, N)))

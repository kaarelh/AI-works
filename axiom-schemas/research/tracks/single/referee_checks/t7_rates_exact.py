# Referee: EXACT P[D_N not an anchor] (inclusion-exclusion over supports) for the author's e7 laws,
# anchor status by the referee's feature search (not by Theorem D), compared with Theorem E's bound
# as printed in the author's e7_rates.out.
import itertools
from rc_core import *
from rc_anchor import feat_truth
X, Y = ('z', 0), ('z', 1)
Tu = AND(ALL(ALL(EQ(S(M('f', V(1), V(0))), Z))), ALL(ALL(EQ(M('f', V(1), S(V(0))), Z))))
u_pool = [X, Y, S(X), S(Y), Z, ADD(X, Y), S(Z), ('a',)]
u_w = [0.3, 0.2, 0.2, 0.1, 0.05, 0.05, 0.05, 0.05]
P = 'P'
IND = Ind_T()
ind_pool = [EQ(X, X), EQ(X, Z), EQ(Z, Z), NOT(EQ(X, Z)), NOT(EQ(Z, S(Z))), EQ(ADD(X, Z), X), ALL(EQ(V(0), X)), AND(EQ(X, X), EQ(Z, Z))]
ind_w = [0.3, 0.25, 0.1, 0.1, 0.05, 0.1, 0.05, 0.05]
SEP = ALL(EX(ALL(IFF(IN(V(0), V(1)), AND(IN(V(0), V(2)), M(P, V(0), V(2)))))))
sep_pool = [IN(X, ('a',)), IN(X, Y), NOT(IN(X, X)), EQ(X, ('a',)), IN(('a',), ('b',)), EX(AND(IN(V(0), X), IN(V(0), Y))), ('|', IN(X, ('a',)), IN(X, ('b',)))]
sep_w = [0.3, 0.05, 0.15, 0.2, 0.1, 0.1, 0.1]
# ---- referee's own exact computation of Theorem E's parameters and bound (replaces the rounded author numbers)
def thmE_bound(T, nm, pool, w, Ns):
    data = [inst(T, {nm: b}) for b in pool]
    occs = occurrences(T)
    skel = [(p, s) for (p, s, b) in all_positions(T) if s[0] != '?']
    rhos = []
    for p, o, b in occs:
        dist = {}
        for d, wi in zip(data, w):
            k = root_sym(sub_at(d, p)); dist[k] = dist.get(k, 0) + wi
        rhos.append(1 - max(dist.values()))
    ar = len(occs[0][1][2])
    nus = [sum(wi for b_, wi in zip(pool, w) if m in holes(b_)) for m in range(ar)]
    kappas = []
    rpos = skel + [(p, o) for (p, o, b) in occs]
    for sp, so, sb in occs:
        for rp, rs in rpos:
            if comparable(sp, rp) or sort_of(sub_at(data[0], sp)) != sort_of(sub_at(data[0], rp)):
                continue
            if rs[0] == '?' and rs[1] == so[1] and solve_eq(list(zip(so[2], rs[2]))) is not None:
                continue
            k = 0.0
            for (a, wa), (b2, wb) in itertools.product(list(zip(data, w)), repeat=2):
                if solve_eq([(sub_at(a, sp), sub_at(a, rp)), (sub_at(b2, sp), sub_at(b2, rp))]) is None:
                    k += wa * wb
            kappas.append(k)
    return {N: sum((1 - r) ** (N - 1) for r in rhos) + sum((1 - v) ** N for v in nus) + sum((1 - k) ** (N // 2) for k in kappas) for N in Ns}

print('--- comparison with the referee-computed Theorem E bound')
for name, T, nm, pool, w in [('D4', Tu, 'f', u_pool, u_w), ('Ind', IND, P, ind_pool, ind_w), ('Sep', SEP, P, sep_pool, sep_w)]:
    Ns = [2, 4, 8, 12, 16, 24]
    bd = thmE_bound(T, nm, pool, w, Ns)
    n = len(pool)
    status = {}
    for mask in range(1, 2 ** n):
        S_ = [pool[i] for i in range(n) if mask >> i & 1]
        status[mask] = feat_truth(T, list({inst(T, {nm: b}) for b in S_}))[0]
    def wsum(mask): return sum(w[i] for i in range(n) if mask >> i & 1)
    for N in Ns:
        p_not = 0.0
        for mask in range(1, 2 ** n):
            if status[mask]: continue
            sub = mask; tot = 0.0
            while True:
                k = bin(mask).count('1') - bin(sub).count('1')
                tot += (-1) ** k * wsum(sub) ** N
                if sub == 0: break
                sub = (sub - 1) & mask
            p_not += tot
        print('  %-4s N=%2d exact=%.8f  bound=%.8f  %s' % (name, N, p_not, bd[N], 'OK' if p_not <= bd[N] + 1e-12 else 'VIOLATED'))

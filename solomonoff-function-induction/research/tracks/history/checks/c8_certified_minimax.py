"""c8: the certified search step of Thm 3.8(b) (notes-final.md) for predictors and input laws
with COMPUTABLE REAL (here irrational) probabilities, some of them exactly 0.

Thm 3.8(b) replaces the hypothesis "rational-valued P and Delta" of notes.md by "computable
real-valued P and Delta".  Its proof searches for a rational random function
G = (1/2) G0 + (1/2) Uniform (G0 rational) such that, for EVERY f : A_n -> Y,

      E_{x|f}[ -log2 G(D_n) ]  <  E_{x|f}[ L_P ] + 3            (non-peeking case)

and argues: (i) the left side is a computable real, the right side is lower semicomputable
(P computable => -log P lower semicomputable, possibly +inf), so each strict inequality is
certifiable in finite time when true; (ii) some grid point satisfies all of them with slack,
because the minimax value V is <= 1 and each Phi_f is Lipschitz on the restricted set.

This script illustrates the search on random instances with X = {0,1,2}, Y = {0,1}, n = 3:
 * P(1|h,x) = sqrt(a)/(sqrt(a)+sqrt(b)) with random integers a, b in 1..9, and a = 0 or b = 0
   (so P(1|h,x) = 0 or P(0|h,x) = 0 exactly) at a random 1.5% + 1.5% of arguments;  Delta(x|h) proportional to sqrt(c_x);
 * an approximate minimax G0 is computed (SLSQP, epigraph form, over f in F_fin);
 * G0 is rounded to the dyadic grid with denominator 2^12 (exact Fractions);
 * every one of the 8 strict inequalities is then CERTIFIED with mpmath interval arithmetic
   (sqrt and log enclosures), including f outside F_fin, where the right side is +inf.
It reports the float minimax value, the certified upper bound of max_f [E(-log G) - E(L_P)]
for the rounded G, and whether all inequalities were certified.  This is an illustration of
the proof's search step, not a proof.
Seed 20261013.  Output saved to c8_certified_minimax.out.
"""
import itertools, math
from fractions import Fraction as Fr
import numpy as np
from scipy.optimize import minimize
from mpmath import iv, mp

SEED = 20261013
rng = np.random.default_rng(SEED)
iv.prec = 80
X = (0, 1, 2); Y = (0, 1); n = 3
FUNCS = list(itertools.product(Y, repeat=len(X)))
NF = len(FUNCS)


def histories_upto(m):
    out = [()]
    for k in range(1, m + 1):
        out += list(itertools.product(itertools.product(X, Y), repeat=k))
    return out


def random_instance():
    Pab, Dc = {}, {}
    for h in histories_upto(n - 1):
        for x in X:
            a = int(rng.integers(1, 10)); b = int(rng.integers(1, 10))
            u = rng.random()
            if u < 0.015:
                a = 0
            elif u < 0.03:
                b = 0
            Pab[(h, x)] = (a, b)
        Dc[h] = [int(rng.integers(1, 10)) for _ in X]
    return Pab, Dc


def P_float(Pab, h, x, y):
    a, b = Pab[(h, x)]
    sa, sb = math.sqrt(a), math.sqrt(b)
    return (sa if y == 1 else sb) / (sa + sb)


def P_iv(Pab, h, x, y):
    a, b = Pab[(h, x)]
    if (y == 1 and a == 0) or (y == 0 and b == 0):
        return iv.mpf(0)
    sa, sb = iv.sqrt(iv.mpf(a)), iv.sqrt(iv.mpf(b))
    return (sa if y == 1 else sb) / (sa + sb)


def D_float(Dc, h, x):
    s = [math.sqrt(c) for c in Dc[h]]
    return s[x] / sum(s)


def D_iv(Dc, h, x):
    s = [iv.sqrt(iv.mpf(c)) for c in Dc[h]]
    return s[x] / (s[0] + s[1] + s[2])


def paths(f, Dc, Dfun):
    """yield (prob, list of (h, x, y)) over input sequences, labels from f."""
    out = []
    for xs in itertools.product(X, repeat=n):
        p = None
        h = ()
        steps = []
        for x in xs:
            q = Dfun(Dc, h, x)
            p = q if p is None else p * q
            steps.append((h, x, f[x]))
            h = h + ((x, f[x]),)
        out.append((p, steps))
    return out


def ELP_float(f, Pab, Dc):
    tot = 0.0
    for p, steps in paths(f, Dc, D_float):
        loss = 0.0
        for h, x, y in steps:
            q = P_float(Pab, h, x, y)
            if q == 0:
                return math.inf
            loss += -math.log2(q)
        tot += p * loss
    return tot


def ELP_iv_lower(f, Pab, Dc):
    """certified lower bound on E_{x|f}[L_P] (may be +inf)."""
    tot = iv.mpf(0)
    ln2 = iv.log(iv.mpf(2))
    for p, steps in paths(f, Dc, D_iv):
        loss = iv.mpf(0)
        for h, x, y in steps:
            q = P_iv(Pab, h, x, y)
            if q.b == 0:
                return math.inf  # P = 0 exactly on a positive-probability path
            loss = loss - iv.log(q) / ln2
        tot = tot + p * loss
    return float(mp.mpf(tot.a))


def path_sets(f):
    return [frozenset((x, f[x]) for x in xs) for xs in itertools.product(X, repeat=n)]


def G_of_D(G0, D):
    """G = 1/2 G0 + 1/2 U, evaluated on a data set D (floats)."""
    g0 = sum(G0[j] for j, g in enumerate(FUNCS) if all(g[x] == y for x, y in D))
    return 0.5 * g0 + 0.5 * 0.5 ** len({x for x, _ in D})


def ElogG_float(f, G0, Dc):
    tot = 0.0
    for (p, steps), D in zip(paths(f, Dc, D_float), path_sets(f)):
        tot += p * (-math.log2(G_of_D(G0, D)))
    return tot


def ElogG_iv_upper(f, G0frac, Dc):
    tot = iv.mpf(0)
    ln2 = iv.log(iv.mpf(2))
    for (p, steps), D in zip(paths(f, Dc, D_iv), path_sets(f)):
        g0 = sum((G0frac[j] for j, g in enumerate(FUNCS) if all(g[x] == y for x, y in D)), Fr(0))
        val = Fr(1, 2) * g0 + Fr(1, 2) * Fr(1, 2 ** len({x for x, _ in D}))
        gv = iv.mpf(val.numerator) / iv.mpf(val.denominator)
        tot = tot + p * (-iv.log(gv) / ln2)
    return float(mp.mpf(tot.b))


def solve(Pab, Dc):
    ELP = [ELP_float(f, Pab, Dc) for f in FUNCS]
    fin = [j for j in range(NF) if ELP[j] < math.inf]
    if not fin:
        return np.ones(NF) / NF, -math.inf, ELP, fin
    def phi(G0, j):
        return ElogG_float(FUNCS[j], G0, Dc) - ELP[j]
    best = None
    for r in range(4):
        z0 = rng.dirichlet(np.ones(NF))
        t0 = max(phi(z0, j) for j in fin)
        cons = [{'type': 'eq', 'fun': lambda v: np.sum(v[:NF]) - 1.0}]
        for j in fin:
            cons.append({'type': 'ineq', 'fun': (lambda v, j=j: v[NF] - phi(np.clip(v[:NF], 0, 1), j))})
        res = minimize(lambda v: v[NF], np.append(z0, t0), constraints=cons,
                       bounds=[(0, 1)] * NF + [(None, None)], method='SLSQP',
                       options={'maxiter': 400, 'ftol': 1e-10})
        G0 = np.clip(res.x[:NF], 0, 1); G0 = G0 / G0.sum()
        val = max(phi(G0, j) for j in fin)
        if best is None or val < best[1]:
            best = (G0, val)
    return best[0], best[1], ELP, fin


def round_dyadic(G0, k=12):
    den = 2 ** k
    ints = [int(round(g * den)) for g in G0]
    diff = den - sum(ints)
    j = int(np.argmax(G0)); ints[j] += diff
    if ints[j] < 0:
        ints = [max(0, i) for i in ints]; ints[int(np.argmax(ints))] += den - sum(ints)
    return [Fr(i, den) for i in ints]


def main():
    lines = []
    NI = 12
    all_cert = True
    worst_cert = -math.inf
    for t in range(NI):
        Pab, Dc = random_instance()
        G0, V_float, ELP, fin = solve(Pab, Dc)
        G0frac = round_dyadic(G0)
        cert_ok = True
        cert_max = -math.inf
        for j, f in enumerate(FUNCS):
            up = ElogG_iv_upper(f, G0frac, Dc)
            lo = ELP_iv_lower(f, Pab, Dc)
            if lo == math.inf:
                continue  # inequality certified: right side is +inf
            cert_max = max(cert_max, up - lo)
            if not (up < lo + 3):
                cert_ok = False
        all_cert &= cert_ok
        worst_cert = max(worst_cert, cert_max)
        lines.append(f"instance {t}: |F_fin| = {len(fin)}/8; float minimax value over restricted G ~ {V_float:+.5f}; "
                     f"certified max_f [E(-log G) - E(L_P)] for dyadic G (den 2^12) <= {cert_max:+.5f}; "
                     f"all 8 strict inequalities (slack 3) certified: {cert_ok}")
    lines.append(f"largest certified upper bound over instances: {worst_cert:+.5f} (proof guarantees a grid point with <= 2)")
    lines.append("ALL CHECKS PASSED" if all_cert else "SOME CHECK FAILED")
    out = "\n".join(lines)
    print(out)
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write(out + "\n")


if __name__ == "__main__":
    main()

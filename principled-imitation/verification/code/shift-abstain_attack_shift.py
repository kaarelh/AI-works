#!/usr/bin/env python3
"""Adversary's checks for Sections 1 and 2 of research/prove-c/shift-abstain.md.

Everything here is exact (enumeration of all runs and of all paths of the protocol);
nothing is simulated.  Independent of the prover's scripts.

(1) Example 2.2 recomputed by a generic exact engine for Protocol R (not by the closed
    formulas of the file), for small n, and by the closed formulas for the n quoted in
    the file.  The ratio beta_hum / beta_own = L/(1 + omega (L-1)) tends to L as omega -> 0,
    so the lower bound for the factor in Proposition 2.3 is L, not L/2.
(2) Corollary 1.3 (R1 for any driver), Lemma 1.4 and Proposition 2.3 on random instances
    with scaffolds whose inputs depend on the answers, runs of different lengths, a human
    who is a function or a sampler, and classes that contain samplers:
        sum_t E sum_j KL(P || M^(t))(x_tj) <= L ln(W/w(P));
        p <= beta, p <= beta^P, TV(Q_C, Q_P) <= p, |int g d d_C - int g d d_P| <= (L-1) p,
        beta^P <= L p, beta <= L p;
        E int TV(P, M^(T)) d dbar <= (2L-1) E beta(M^(T))     (dbar realised, B = 1).
    The largest observed ratio of the two sides of the last line is reported.
(3) A search for the largest factor in Proposition 2.3 over small instances (random search),
    to see how close to 2L-1 one gets.
"""
import itertools
import math
import random

BOT = "bot"


# ---------------------------------------------------------------- exact engine
class Scaffold:
    def __init__(self, Z, D0, L, nxt):
        self.Z, self.D0, self.L, self.nxt = Z, D0, L, nxt


def runs(scaf, C):
    """All runs of the kernel C (dict x -> dict y -> prob; y may be BOT).
    Returns a list of (prob, z, xs, ys).  A run ends at STOP, after L calls, or at BOT."""
    out = []

    def rec(z, xs, ys, p):
        if len(ys) == scaf.L or (ys and ys[-1] == BOT):
            out.append((p, z, tuple(xs), tuple(ys)))
            return
        x = scaf.nxt(z, tuple(ys))
        if x is None:
            out.append((p, z, tuple(xs), tuple(ys)))
            return
        for y, py in C[x].items():
            if py > 0:
                rec(z, xs + [x], ys + [y], p * py)

    for z, pz in zip(scaf.Z, scaf.D0):
        if pz > 0:
            rec(z, [], [], pz)
    return out


def visit(scaf, C, X):
    d = {x: 0.0 for x in X}
    for p, _z, xs, _ys in runs(scaf, C):
        for x in xs:
            d[x] += p
    return d


def tv(p, q):
    keys = set(p) | set(q)
    return 0.5 * sum(abs(p.get(k, 0.0) - q.get(k, 0.0)) for k in keys)


def kl(p, q):
    s = 0.0
    for k, pk in p.items():
        if pk > 0:
            s += pk * math.log(pk / q.get(k, 0.0)) if q.get(k, 0.0) > 0 else float("inf")
    return s


def posterior(hyps, w, D):
    post = []
    for h, wh in zip(hyps, w):
        v = wh
        for x, y in D:
            v *= h[x].get(y, 0.0)
        post.append(v)
    tot = sum(post)
    return [v / tot for v in post]


def mixture(hyps, post, X, Y):
    M = {}
    for x in X:
        M[x] = {y: sum(pw * h[x].get(y, 0.0) for pw, h in zip(post, hyps)) for y in Y}
        miss = 1.0 - sum(M[x].values())
        if miss > 1e-12:
            M[x][BOT] = miss
    return M


def protocol_paths(scaf, hyps, w, P, X, Y, n, driver=None):
    """Exact Protocol R[driver] (driver = mixture if None).  Yields (prob, [D_<1, ..., D_<n+1]).
    In a round the asked input is x with probability d_t(x)/L, and nothing is asked with
    the remaining probability; the answer is drawn from P."""
    cache = {}

    def dt_of(D):
        if D not in cache:
            post = posterior(hyps, w, D)
            M = mixture(hyps, post, X, Y)
            C = M if driver is None else driver(D, M)
            cache[D] = (visit(scaf, C, X), M, C)
        return cache[D]

    out = []

    def rec(t, D, hist, p):
        if t == n:
            out.append((p, hist + [D]))
            return
        d, _M, _C = dt_of(D)
        rest = 1.0
        for x in X:
            px = d[x] / scaf.L
            if px <= 0:
                continue
            rest -= px
            for y, py in P[x].items():
                if py > 0:
                    rec(t + 1, D + ((x, y),), hist + [D], p * px * py)
        if rest > 1e-15:
            rec(t + 1, D, hist + [D], p * rest)

    rec(0, (), [], 1.0)
    return out, dt_of


# ---------------------------------------------------------------- (1) Example 2.2
def example_22_engine(L, omega, n):
    X = ["x0", "a", "b"]
    Y = [0, 1]
    f = {x: {0: 1.0} for x in X}
    g = {"x0": {1: 1.0}, "a": {1: 1.0}, "b": {0: 1.0}}
    hyps, w = [f, g], [omega, 1 - omega]

    def nxt(z, ys):
        if len(ys) == 0:
            return "x0"
        return "a" if ys[0] == 0 else "b"

    scaf = Scaffold([0], [1.0], L, nxt)
    paths, dt_of = protocol_paths(scaf, hyps, w, f, X, Y, n)
    d_f = visit(scaf, f, X)
    own = hum = 0.0
    dbar = {x: 0.0 for x in X}
    for p, hist in paths:
        for t in range(n):
            d, M, _ = dt_of(hist[t])
            e = {x: 1.0 - M[x].get(0, 0.0) for x in X}
            own += p * sum(d[x] * e[x] for x in X) / n
            hum += p * sum(d_f[x] * e[x] for x in X) / n
            for x in X:
                dbar[x] += p * d[x] / n
    B = max(d_f[x] / dbar[x] for x in X if d_f[x] > 0)
    return own, hum, B


def example_22_formula(L, omega, n):
    kappa = (1 + omega * (L - 1)) / L
    s = (1 - (1 - kappa) ** n) / kappa          # sum_t P[g alive in round t]
    own = (1 - omega) * (1 + omega * (L - 1)) * s / n
    hum = (1 - omega) * L * s / n
    dbar_a = (L - 1) * (n - (1 - omega) * s) / n
    B = max(1.0, (L - 1) / dbar_a)
    return own, hum, B


# ---------------------------------------------------------------- (2) random instances
def random_instance(rng, stochastic_human):
    nX = rng.randrange(3, 5)
    X = list(range(nX))
    Y = [0, 1]
    L = rng.randrange(2, 4)
    nZ = rng.randrange(1, 4)
    table = {}

    def nxt(z, ys):
        key = (z, ys)
        if key not in table:
            if len(ys) >= 1 and rng.random() < 0.15:
                table[key] = None                     # the run stops early
            else:
                table[key] = rng.randrange(nX)
        return table[key]

    D0 = [rng.random() + 0.05 for _ in range(nZ)]
    s = sum(D0)
    D0 = [v / s for v in D0]
    scaf = Scaffold(list(range(nZ)), D0, L, nxt)
    nH = rng.randrange(2, 5)
    hyps = []
    for i in range(nH):
        h = {}
        for x in X:
            if (i == 0 and not stochastic_human) or (i > 0 and rng.random() < 0.6):
                h[x] = {rng.randrange(2): 1.0}
            else:
                a = rng.choice([0.1, 0.25, 0.5, 0.8])
                h[x] = {0: a, 1: 1 - a}
        hyps.append(h)
    raw = [rng.random() ** 2 + 0.02 for _ in range(nH)]
    scale = rng.uniform(0.4, 1.0) / sum(raw)
    w = [r * scale for r in raw]
    return X, Y, L, scaf, hyps, w


def coupled_p(scaf, C, P):
    """Probability that the coupled runs of C and P separate (Lemma 1.4)."""
    total = 0.0

    def rec(z, ys, p):
        nonlocal total
        if len(ys) == scaf.L:
            return
        x = scaf.nxt(z, tuple(ys))
        if x is None:
            return
        total += p * tv(P[x], C[x])
        for y in set(P[x]) & set(C[x]):
            m = min(P[x][y], C[x][y])
            if m > 0:
                rec(z, ys + [y], p * m)

    for z, pz in zip(scaf.Z, scaf.D0):
        rec(z, [], pz)
    return total


def run_law(scaf, C):
    law = {}
    for p, z, xs, ys in runs(scaf, C):
        law[(z, ys)] = law.get((z, ys), 0.0) + p
    return law


def check_random(trials, n, stochastic_human, seed):
    rng = random.Random(seed)
    worst = dict(r1=-1e9, lem=-1e9, core=-1e9, prop=0.0)
    for _ in range(trials):
        X, Y, L, scaf, hyps, w = random_instance(rng, stochastic_human)
        P = hyps[0]
        W = sum(w)
        paths, dt_of = protocol_paths(scaf, hyps, w, P, X, Y, n)
        assert abs(sum(p for p, _ in paths) - 1) < 1e-9
        d_P = visit(scaf, P, X)
        sum_kl = 0.0
        lhs = rhs = 0.0
        for p, hist in paths:
            ds, Ms = [], []
            for t in range(n):
                d, M, _ = dt_of(hist[t])
                ds.append(d)
                Ms.append(M)
                sum_kl += p * sum(d[x] * kl(P[x], M[x]) for x in X if d[x] > 0)
            tvs = [{x: tv(P[x], M[x]) for x in X} for M in Ms]
            beta = [sum(ds[t][x] * tvs[t][x] for x in X) for t in range(n)]
            for u in range(n):
                for t in range(n):
                    I = sum(ds[t][x] * tvs[u][x] for x in X)
                    worst["core"] = max(worst["core"], I - (L * beta[u] + (L - 1) * beta[t]))
                    lhs += p * I / (n * n)
            rhs += p * sum(beta) / n
            # Lemma 1.4 for the kernels met on this path (only on paths of some weight)
            if p > 1e-4:
                for t in range(n):
                    C = Ms[t]
                    pc = coupled_p(scaf, C, P)
                    bP = sum(d_P[x] * tvs[t][x] for x in X)
                    lawC, lawP = run_law(scaf, C), run_law(scaf, P)
                    tvrun = 0.5 * sum(abs(lawC.get(k, 0) - lawP.get(k, 0))
                                      for k in set(lawC) | set(lawP))
                    g = {x: rng.random() for x in X}
                    diff = abs(sum(g[x] * (ds[t][x] - d_P[x]) for x in X))
                    worst["lem"] = max(worst["lem"], pc - beta[t], pc - bP, tvrun - pc,
                                       diff - (L - 1) * pc, bP - L * pc, beta[t] - L * pc)
        worst["r1"] = max(worst["r1"], sum_kl - L * math.log(W / w[0]))
        if rhs > 1e-12:
            worst["prop"] = max(worst["prop"], lhs / ((2 * L - 1) * rhs))
            assert lhs <= (2 * L - 1) * rhs + 1e-9
    return worst


# ---------------------------------------------------------------- (3) search for a large factor
def factor_search(L, trials, seed):
    """Random search over two-hypothesis instances for a large value of
       E int e_{M^(T)} d dbar / E beta(M^(T))   (B = 1, realised dbar)."""
    rng = random.Random(seed)
    best = (0.0, None)
    n = 3
    for _ in range(trials):
        nX = 3
        X = list(range(nX))
        Y = [0, 1]
        table = {}

        def nxt(z, ys, table=table):
            key = ys
            if key not in table:
                table[key] = rng.randrange(nX)
            return table[key]

        scaf = Scaffold([0], [1.0], L, nxt)
        f = {x: {0: 1.0} for x in X}
        g = {x: {rng.randrange(2): 1.0} for x in X}
        om = rng.choice([0.01, 0.05, 0.2, 0.5])
        hyps, w = [f, g], [om, 1 - om]
        paths, dt_of = protocol_paths(scaf, hyps, w, f, X, Y, n)
        lhs = rhs = 0.0
        for p, hist in paths:
            ds, es = [], []
            for t in range(n):
                d, M, _ = dt_of(hist[t])
                ds.append(d)
                es.append({x: 1 - M[x].get(0, 0.0) for x in X})
            for u in range(n):
                for t in range(n):
                    lhs += p * sum(ds[t][x] * es[u][x] for x in X) / (n * n)
            rhs += p * sum(sum(ds[t][x] * es[t][x] for x in X) for t in range(n)) / n
        if rhs > 1e-12 and lhs / rhs > best[0]:
            best = (lhs / rhs, (om, dict(table), g))
    return best


def main():
    print("(1) Example 2.2: generic exact engine against the closed formulas")
    print("     L  omega    n   own(engine)  own(formula)  hum(engine)  hum(formula)   B(eng)  B(form)")
    for L, om, n in [(3, 0.2, 6), (4, 0.25, 6), (5, 0.1, 5), (6, 1 / 6, 5)]:
        o1, h1, b1 = example_22_engine(L, om, n)
        o2, h2, b2 = example_22_formula(L, om, n)
        print(f"   {L:3d}  {om:.3f}  {n:3d}   {o1:.8f}   {o2:.8f}   {h1:.8f}   {h2:.8f}   {b1:.4f}  {b2:.4f}")
        assert abs(o1 - o2) < 1e-9 and abs(h1 - h2) < 1e-9 and abs(b1 - b2) < 1e-9
    print("    the numbers quoted in the file (closed formulas):")
    for L, om, n in [(100, 0.01, 10 ** 4), (1000, 0.001, 10 ** 6)]:
        own, hum, B = example_22_formula(L, om, n)
        K = math.log2(1 / om)
        claim = B * L * K * math.log(2) / n
        print(f"    L={L} omega={om} n={n}: beta_hum = {hum:.4f}, candidate's S1 bound = {claim:.5f}, "
              f"ratio {hum / claim:.1f};  (2L-1) B beta_own = {(2 * L - 1) * B * own:.4f}")
    print("    the factor beta_hum/beta_own = L/(1+omega(L-1)) as omega -> 0 (n = 100 L):")
    for L in (10, 100):
        for om in (1 / L, 0.1 / L, 0.001 / L):
            own, hum, B = example_22_formula(L, om, 100 * L)
            print(f"    L={L:4d} omega={om:.2e}: factor {hum / own:8.3f}  (L = {L}, 2L-1 = {2 * L - 1}), B = {B:.4f}")

    print()
    print("(2) random instances, exact (all paths of Protocol R, n = 3 rounds)")
    for stoch in (False, True):
        wst = check_random(150, 3, stoch, seed=11 + stoch)
        kind = "sampler" if stoch else "function"
        print(f"    human a {kind}: 150 instances")
        print(f"      Corollary 1.3: max of [sum_t E sum_j KL - L ln(W/w(P))] = {wst['r1']:.3e} (<= 0)")
        print(f"      Lemma 1.4: max violation of the six inequalities = {wst['lem']:.3e} (<= 0)")
        print(f"      proof of Prop. 2.3: max of [I_ut - L beta_u - (L-1) beta_t] = {wst['core']:.3e} (<= 0)")
        print(f"      Prop. 2.3 (B = 1): max of lhs/((2L-1) rhs) = {wst['prop']:.4f} (<= 1)")

    print()
    print("(3) random search for a large factor E int e_(M^(T)) d dbar / E beta(M^(T)), n = 3")
    for L in (2, 3, 4):
        val, _arg = factor_search(L, 4000, seed=5 + L)
        print(f"    L={L}: largest factor found {val:.4f}   (L = {L}, 2L-1 = {2 * L - 1})")


if __name__ == "__main__":
    main()

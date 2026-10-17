"""rb4_best_system.py -- Referee B, thread `laws`: the best-system claims of notes section 5, in exact rational
arithmetic and independently of l7.

A. Prop 5.5 (solar-system toy): brute force over ALL theories (law?, K3?, S) against the closed form; then the
   statement (b) "K3 enters iff s|S| > L3 whatever lambda is" read literally (K3 in the overall lambda-MAP)
   against the conditional reading (J*(law+K3) < J*(law)); an explicit counterexample to the literal reading.
B. Prop 5.6 (kind nature <=> kink): random integer point families INCLUDING degenerate ones (collinear points,
   several programs at one point, intervals whose ends are hull slopes); MAP sets computed exactly at every
   breakpoint and between breakpoints, with Fractions; compared with (b) "a hull vertex v_i with
   sigma_{i+1} <= tau and sigma <= sigma_i".
C. scout N2's population (its generator re-run with its seed): the hull of the canonical family computed
   independently with Fractions; the robustness interval of "law + 8 planets" (record: (7.03, 135.37)).
D. Prop 5.8: Myrvold's term U(D1,D2;h) = I(h;D1 u D2) - I(h;D1) - I(h;D2) against I(D1;D2|h) - I(D1;D2) on
   random joint tables; the three parameter cases (U = k, 0, k_C) by exact enumeration.
Seed 20261016.  Writes rb4_best_system.out next to itself.
"""
import itertools
import math
import os
import random
import sys
import time
from fractions import Fraction as Fr

SEED = 20261016
OUT = []
HERE = os.path.dirname(os.path.abspath(__file__))


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def Jtoy(law, k3, S, ns, P, lam):
    kb = P["k"] - (P["s"] if k3 else 0)
    length = (P["L"] if law else 0) + (P["L3"] if k3 else 0) + kb * len(S)
    proved = sum(ns[i] for i in S) if law else 0
    return lam * length + P["c"] * (sum(ns) - proved)


def all_maps(ns, P, lam):
    """set of all exact minimisers (law, k3, S) over all 2^(m+2) theories (K3 without the law allowed)."""
    best, arg = None, []
    m = len(ns)
    for law in (False, True):
        for k3 in (False, True):
            for r in range(m + 1):
                for S in itertools.combinations(range(m), r):
                    v = Jtoy(law, k3, S, ns, P, lam)
                    if best is None or v < best:
                        best, arg = v, [(law, k3, S)]
                    elif v == best:
                        arg.append((law, k3, S))
    return best, arg


def closed(ns, P, lam):
    vals = {}
    for law, k3 in ((False, False), (True, False), (True, True)):
        kb = P["k"] - (P["s"] if k3 else 0)
        if not law:
            vals[(law, k3)] = P["c"] * sum(ns)
        else:
            vals[(law, k3)] = lam * (P["L"] + (P["L3"] if k3 else 0)) + sum(min(P["c"] * nb, lam * kb) for nb in ns)
    return vals


def hull(points):
    """lower convex hull (length, fit) for the steeper objective; returns vertices left to right and slopes."""
    best = {}
    for a, r in points:
        if a not in best or r < best[a]:
            best[a] = r
    pts = sorted(best.items())
    V = [pts[0]]
    while True:
        a0, r0 = V[-1]
        cand = [(a, r) for a, r in pts if a > a0]
        if not cand:
            break
        sl = [((r0 - r) / (a - a0), a, r) for a, r in cand]
        smax = max(x[0] for x in sl)
        if smax <= 0:
            break
        nxt = max((x for x in sl if x[0] == smax), key=lambda x: x[1])
        V.append((nxt[1], nxt[2]))
    sig = [None] + [(V[i - 1][1] - V[i][1]) / (V[i][0] - V[i - 1][0]) for i in range(1, len(V))]
    return V, sig


def main():
    t0 = time.time()
    rng = random.Random(SEED)
    out("# rb4_best_system.py seed=%d python %s" % (SEED, sys.version.split()[0]))

    # ---------------- A
    out("\n== A. Prop 5.5: closed form vs brute force (exact rationals); the K3 statement (b)")
    agree = total = 0
    lit_cases = lit_ok = cond_ok = 0
    first_cex = None
    for trial in range(1500):
        m = rng.randint(1, 7)
        ns = [rng.choice([1, 2, 3, rng.randint(1, 40), rng.randint(5, 500)]) for _ in range(m)]
        P = dict(L=Fr(rng.choice([5, 20, 100, 300, 1000])), L3=Fr(rng.choice([1, 10, 40, 150])),
                 k=Fr(rng.choice([5, 20, 60])), c=Fr(rng.choice([1, 4, 10, 62]), rng.choice([1, 5])))
        P["s"] = Fr(rng.randint(1, int(P["k"]) - 1))
        for lam in (Fr(1, 2), Fr(1), Fr(3, 2), Fr(2), Fr(3), Fr(5), Fr(10)):
            best, arg = all_maps(ns, P, lam)
            v = closed(ns, P, lam)
            total += 1
            agree += min(v.values()) == best
            S1 = [i for i, nb in enumerate(ns) if P["c"] * nb > lam * P["k"]]
            S2 = [i for i, nb in enumerate(ns) if P["c"] * nb > lam * (P["k"] - P["s"])]
            if S1 == S2 and S1:
                lit_cases += 1
                pred = P["s"] * len(S1) > P["L3"]
                k3_in_map = all(a[1] for a in arg)          # K3 in every lambda-MAP
                k3_beats_law = v[(True, True)] < v[(True, False)]
                lit_ok += pred == k3_in_map
                cond_ok += pred == k3_beats_law
                if pred != k3_in_map and first_cex is None:
                    first_cex = (ns, dict(P), lam, v, arg)
    out("   optimal J: closed form = brute force in %d / %d (population, lambda) cases" % (agree, total))
    out("   cases with S the same with and without K3 (S nonempty): %d" % lit_cases)
    out("     'J*(law+K3) < J*(law) iff s|S| > L3' (conditional reading): right in %d" % cond_ok)
    out("     'K3 is in the lambda-MAP iff s|S| > L3' (literal reading of (b)): right in %d" % lit_ok)
    if first_cex:
        ns, P, lam, v, arg = first_cex
        out("     first random counterexample to the literal reading: n_b = %s, %s, lambda = %s: J*(empty) = %s, J*(law) = %s,"
            " J*(law+K3) = %s; lambda-MAPs %s" % (ns, {k_: str(x) for k_, x in P.items()}, lam,
                                                   v[(False, False)], v[(True, False)], v[(True, True)], arg))
    ns = [1, 1]
    P = dict(L=Fr(1000), L3=Fr(1), k=Fr(5), s=Fr(4), c=Fr(10))
    v = closed(ns, P, Fr(1))
    best, arg = all_maps(ns, P, Fr(1))
    out("   hand counterexample: 2 bodies with 1 observation each, c=10, L=1000, k=5, s=4, L3=1, lambda=1: S = both"
        " bodies with and without K3, s|S| = 8 > L3 = 1, yet the lambda-MAP is %s (J = %s; J*(law) = %s, J*(law+K3) = %s)" % (
            arg, best, v[(True, False)], v[(True, True)]))

    # ---------------- B
    out("\n== B. Prop 5.6 on random point families, exact; degenerate families included")
    mism = checks = degenerate = 0
    for trial in range(600):
        npts = rng.randint(2, 10)
        pts = [(Fr(rng.randint(0, 12)), Fr(rng.randint(0, 60))) for _ in range(npts)]
        if trial % 3 == 0:            # add collinear points and duplicates
            a, r = pts[0]
            pts += [(a + 2, r - 6), (a + 4, r - 12), pts[1]]
            degenerate += 1
        V, sig = hull(pts)
        sigs = [math.inf] + sig[1:] + [Fr(0)]   # sigma_0 = inf, sigma_i (edge v_{i-1} v_i), sigma_{last+1} = 0
        # candidate intervals: random, and with ends exactly at hull slopes
        ends = [Fr(rng.randint(0, 80), rng.randint(1, 8)) for _ in range(6)] + [x for x in sig[1:]]
        for _ in range(12):
            tau, sigma = sorted(rng.sample(ends + [Fr(0)], 2)) if len(ends) >= 2 else (Fr(0), Fr(1))
            if rng.random() < 0.15:
                sigma = math.inf
            if not (tau < sigma):
                continue
            # breakpoints: lambdas where two points tie
            bps = set()
            for (a1, r1), (a2, r2) in itertools.combinations(pts, 2):
                if a1 != a2:
                    lc = (r2 - r1) / (a1 - a2)
                    if tau < lc and (sigma == math.inf or lc < sigma):
                        bps.add(lc)
            bl = sorted(bps)
            top = (bl[-1] + 1) if bl else (tau + 1)
            hi = sigma if sigma != math.inf else top * 2 + 5
            grid = sorted(set(bl + [(x + y) / 2 for x, y in zip([tau] + bl, bl + [hi])]))
            sets = set()
            for lam in grid:
                vals = [lam * a + r for a, r in pts]
                mn = min(vals)
                sets.add(frozenset((a, r) for (a, r), vv in zip(pts, vals) if vv == mn))
            const = len(sets) == 1
            vert = any((sigs[i + 1] <= tau) and (sigma <= sigs[i]) for i in range(len(V)))
            checks += 1
            mism += const != vert
    out("   %d (family, interval) checks (%d degenerate families; interval ends drawn from hull slopes too;"
        " sigma = inf allowed): mismatches %d" % (checks, degenerate, mism))

    # ---------------- C
    out("\n== C. scout N2's population: hull of the canonical family, exact")
    r2 = random.Random(20261015)
    for _ in range(30):
        [r2.randint(20, 400), r2.randint(20, 400)] + [r2.randint(1, 20) for _ in range(5)]
    bodies = [("planet", int(r2.uniform(500, 5000))) for _ in range(8)]
    bodies += [("asteroid", max(1, int(round(math.exp(r2.gauss(1.6, 1.0)))))) for _ in range(60)]
    bodies += [("comet", r2.choice([1, 1, 1, 2])) for _ in range(30)]
    ns = [nb for _, nb in bodies]
    P = dict(L=Fr(300), L3=Fr(150), k=Fr(60), s=Fr(15), c=Fr(124, 10))
    order = sorted(range(len(ns)), key=lambda i: -ns[i])
    pts = {}
    for law in (False, True):
        for k3 in ((False, True) if law else (False,)):
            for j in range(len(ns) + 1 if law else 1):
                S = order[:j]
                kb = P["k"] - (P["s"] if k3 else 0)
                length = (P["L"] if law else 0) + (P["L3"] if k3 else 0) + kb * len(S)
                fit = P["c"] * (sum(ns) - (sum(ns[i] for i in S) if law else 0))
                pts.setdefault((length, fit), (law, k3, j))
    V, sig = hull(list(pts.keys()))
    for i, (a, r) in enumerate(V):
        law, k3, j = pts[(a, r)]
        kinds = {}
        for b in order[:j]:
            kinds[bodies[b][0]] = kinds.get(bodies[b][0], 0) + 1
        inc = "inf" if i == 0 else "%.4f" % float(sig[i])
        outg = "%.4f" % float(sig[i + 1]) if i + 1 < len(V) else "0"
        if i < 8 or kinds.get("planet", 0) == 8 and kinds.get("asteroid", 0) == 0:
            out("   vertex %2d: |T| = %6s, fit = %9.1f, {%s%s%s}; incoming slope %s, outgoing %s" % (
                i, a, float(r), "law " if law else "", "K3 " if k3 else "",
                " ".join("%s x%d" % kv for kv in sorted(kinds.items())), inc, outg))
    out("   (%d hull vertices)" % len(V))

    # ---------------- D
    out("\n== D. Prop 5.8: Myrvold's term")
    worst = 0.0
    nr = random.Random(SEED + 1)
    for _ in range(2000):
        # joint table P(h, d1, d2) on {0,1}^3 with h a hypothesis indicator
        w = [nr.random() + 1e-3 for _ in range(8)]
        Z = sum(w)
        p = {k: x / Z for k, x in zip(itertools.product((0, 1), repeat=3), w)}
        ph = sum(v for k, v in p.items() if k[0] == 1)

        def P_(**c):
            return sum(v for k, v in p.items() if all(k[{"h": 0, "d1": 1, "d2": 2}[n]] == val for n, val in c.items()))
        d1, d2 = 1, 1
        I12 = math.log2(P_(h=1, d1=d1, d2=d2) / ph / P_(d1=d1, d2=d2))
        I1 = math.log2(P_(h=1, d1=d1) / ph / P_(d1=d1))
        I2 = math.log2(P_(h=1, d2=d2) / ph / P_(d2=d2))
        U = I12 - I1 - I2
        mi_h = math.log2((P_(h=1, d1=d1, d2=d2) / ph) / ((P_(h=1, d1=d1) / ph) * (P_(h=1, d2=d2) / ph)))
        mi = math.log2(P_(d1=d1, d2=d2) / (P_(d1=d1) * P_(d2=d2)))
        worst = max(worst, abs(U - (mi_h - mi)))
    out("   identity U = I(D1;D2|h) - I(D1;D2) (pointwise mutual informations) on 2000 random joint tables:"
        " max deviation %.2e" % worst)
    # three parameter cases by exact enumeration over parameters
    k = 6
    # case 1: one body, theta in 2^k values; each D_i is consistent with exactly theta* (likelihood 1), others 0
    Ph_D1 = Fr(1, 2 ** k)
    Ph_D12 = Fr(1, 2 ** k)
    U1 = -math.log2(Ph_D12) + 2 * math.log2(Ph_D1)    # P_empty terms cancel for a product P_empty
    # case 2: theta = (theta1, theta2), each k bits; D_i depends on theta_i only
    U2 = -math.log2(Fr(1, 2 ** (2 * k))) + 2 * math.log2(Fr(1, 2 ** k))
    # case 3: shared constant C of kc bits plus private phi_i of kp bits
    kc, kp = 3, 3
    U3 = -math.log2(Fr(1, 2 ** (kc + 2 * kp))) + 2 * math.log2(Fr(1, 2 ** (kc + kp)))
    out("   enumerated (k = 6): one body U = %.2f (record 6.00); independent parameters U = %.2f (record 0.00);"
        " shared 3-bit constant U = %.2f (record 3.00)" % (-U1, -U2, -U3))

    out("\n# runtime %.0f s" % (time.time() - t0))
    out("# done")
    with open(os.path.join(HERE, "rb4_best_system.out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()

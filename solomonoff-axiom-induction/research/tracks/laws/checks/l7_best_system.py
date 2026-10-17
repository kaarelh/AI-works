"""l7_best_system.py -- the best system as a steeper MAP (thread `laws`, T5; notes section 5).

Seed 20261016.  Writes l7_best_system.out next to itself.  Independent of scout N2's n2 (written from the
statements of notes section 5; the population generator differs).

Toy (notes Def 5.4): bodies b with n_b observations of c bits each (code Q literal cost); the law Lam (L bits)
with body b's elements E_b (k bits) proves b's observations; nothing else proves any observation; K3 (L3 bits)
shortens every elements module by s bits.  Theories: (lam?, k3?, S), S the bodies whose elements are axioms.
J_lambda = lambda |T| + Exc.
Parts:
  A. closed form of Prop 5.5 (three choices, S = {b : c n_b > lambda k_chi}) against brute force over all
     theories, on fresh random populations and parameters; the K3 criterion: correct (s |S| > L3 when S is the
     same with and without K3) against scout N2's stated one (s |S| > lambda L3); an explicit counterexample.
  B. Prop 5.6 on random point families: "the lambda-MAP set is constant on (tau, sigma)" (checked exactly, at
     every pairwise crossing point inside the interval and between consecutive ones) against "some hull vertex
     v_i has sigma_{i+1} <= tau and sigma <= sigma_i".
  C. scout N2's main population re-generated with its own generator and parameters: the lambda-MAP by
     lambda, the hull vertex 'law + 8 planets' and its kink, where K3 enters (both criteria).
  D. explanatory power: the law's EP against the elements' EP as the number of bodies grows (n = 5 obs each),
     and in the question format (elements as question antecedents; Prop 5.9).
  E. Myrvold's unification term in an exactly enumerable model (Prop 5.8): deterministic theory with stated
     parameters (U = 0); a law with marginalised k-bit parameters: U = k within one body, 0 across bodies;
     a shared universal constant: U = its bits across bodies.
"""
import itertools
import math
import random
import sys
import time
import numpy as np

SEED = 20261016
OUT = []


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def J(theory, ns, P, lam):
    law, k3, S = theory
    kb = P["k"] - (P["s"] if k3 else 0)
    length = (P["L"] if law else 0) + (P["L3"] if k3 else 0) + kb * len(S)
    proved = sum(ns[i] for i in S) if law else 0
    exc = P["c"] * (sum(ns) - proved)
    return lam * length + exc, length, exc


def closed_form(ns, P, lam):
    best = None
    for law, k3 in ((False, False), (True, False), (True, True)):
        kb = P["k"] - (P["s"] if k3 else 0)
        S = tuple(i for i, nb in enumerate(ns) if law and P["c"] * nb > lam * kb)
        val, length, exc = J((law, k3, S), ns, P, lam)
        if best is None or (val, length) < best[0]:
            best = ((val, length), (law, k3, S))
    return best


def brute(ns, P, lam):
    best = None
    m = len(ns)
    for law in (False, True):
        for k3 in (False, True):
            for r in range(m + 1):
                for S in itertools.combinations(range(m), r):
                    val, length, exc = J((law, k3, S), ns, P, lam)
                    key = (round(val, 9), length)
                    if best is None or key < best[0]:
                        best = (key, (law, k3, S))
    return best


def hull_vertices(points):
    """lower-left convex hull vertices (alpha, rho) of a finite point set with alpha >= 0, as in P2's lemma."""
    pts = sorted(set(points))
    # keep, for each length, the least fit
    best = {}
    for a, r in pts:
        best[a] = min(best.get(a, math.inf), r)
    pts = sorted(best.items())
    verts = [pts[0]]
    i = 0
    while True:
        a0, r0 = verts[-1]
        cand = [(a, r) for a, r in pts if a > a0]
        if not cand:
            break
        slopes = [((r0 - r) / (a - a0), a) for a, r in cand]
        smax = max(sl for sl, _ in slopes)
        if smax <= 0:
            break
        anext = max(a for sl, a in slopes if abs(sl - smax) <= 1e-12 * max(1, abs(smax)))
        verts.append((anext, r0 - smax * (anext - a0)))
    return verts


def main():
    t0 = time.time()
    rng = random.Random(SEED)
    out("# l7_best_system.py seed=%d python %s numpy %s" % (SEED, sys.version.split()[0], np.__version__))

    # ---------------- A
    out("\n== A. closed form (Prop 5.5) against brute force; K3 criteria")
    agree = total = 0
    k3_cases = k3_correct_ok = k3_n2_ok = 0
    for trial in range(300):
        m = rng.randint(2, 8)
        ns = [rng.choice([rng.randint(1, 3), rng.randint(1, 30), rng.randint(5, 600)]) for _ in range(m)]
        P = dict(L=rng.choice([20, 100, 300]), L3=rng.choice([10, 40, 150]), k=rng.choice([20, 60]),
                 c=rng.choice([1.0, 4.0, 12.4]))
        P["s"] = rng.choice([2, P["k"] // 4, P["k"] // 2])
        for lam in (0.5, 1.0, 1.5, 2.0, 3.0, 5.0, 10.0):
            a = closed_form(ns, P, lam)
            b = brute(ns, P, lam)
            total += 1
            agree += abs(a[0][0] - b[0][0]) < 1e-9
            # K3 criterion when S is the same with and without K3
            S1 = [i for i, nb in enumerate(ns) if P["c"] * nb > lam * P["k"]]
            S2 = [i for i, nb in enumerate(ns) if P["c"] * nb > lam * (P["k"] - P["s"])]
            if S1 == S2 and S1:
                k3_cases += 1
                d = J((True, True, tuple(S1)), ns, P, lam)[0] - J((True, False, tuple(S1)), ns, P, lam)[0]
                k3_in = d < 0
                k3_correct_ok += k3_in == (P["s"] * len(S1) > P["L3"])
                k3_n2_ok += k3_in == (P["s"] * len(S1) > lam * P["L3"])
    out("   optimal J agrees in %d / %d (population, lambda) cases (populations of 2-8 bodies, random parameters)" % (agree, total))
    out("   cases with S the same with and without K3: %d; K3 enters iff s|S| > L3: right in %d; "
        "iff s|S| > lambda L3 (scout N2's statement): right in %d" % (k3_cases, k3_correct_ok, k3_n2_ok))
    P = dict(L=300, L3=150, k=60, s=15, c=12.4)
    ns = [1000] * 15
    lam = 2.0
    S = tuple(range(15))
    jk3 = J((True, True, S), ns, P, lam)[0]
    jno = J((True, False, S), ns, P, lam)[0]
    out("   counterexample: 15 bodies with 1000 observations, L=300, L3=150, k=60, s=15, c=12.4, lambda=2:"
        " J(law+K3+all) = %.1f < J(law+all) = %.1f, so K3 enters; s|S| = %d > L3 = %d, but s|S| < lambda L3 = %d" % (
            jk3, jno, P["s"] * 15, P["L3"], lam * P["L3"]))

    # ---------------- B
    out("\n== B. Prop 5.6: 'lambda-MAP set constant on (tau, sigma)' <=> 'a vertex with sigma_{i+1} <= tau, sigma <= sigma_i'")
    nrng = np.random.default_rng(SEED)
    mism = checks = 0
    for trial in range(400):
        npts = int(nrng.integers(3, 12))
        alphas = nrng.integers(0, 40, size=npts)
        fits = nrng.integers(0, 200, size=npts).astype(float)
        pts = list(zip(alphas.tolist(), fits.tolist()))
        V = hull_vertices(pts)
        sig = [math.inf] + [(V[i - 1][1] - V[i][1]) / (V[i][0] - V[i - 1][0]) for i in range(1, len(V))] + [0.0]
        for _ in range(10):
            tau, sigma = sorted(nrng.uniform(0, 30, size=2).tolist())
            # exact test points: every pairwise crossing lambda inside (tau, sigma) and the midpoints between
            # consecutive breakpoints (the MAP set is constant between breakpoints)
            cross = set()
            for (a1, r1), (a2, r2) in itertools.combinations(pts, 2):
                if a1 != a2:
                    lc = (r2 - r1) / (a1 - a2)
                    if tau < lc < sigma:
                        cross.add(lc)
            bps = [tau] + sorted(cross) + [sigma]
            grid = sorted(cross) + [(bps[i] + bps[i + 1]) / 2 for i in range(len(bps) - 1)]
            sets = set()
            for lam_ in grid:
                vals = [lam_ * a + r for a, r in pts]
                mn = min(vals)
                sets.add(frozenset(i for i, v in enumerate(vals) if v <= mn + 1e-9))
            const = len(sets) == 1
            vert = any(sig[i + 1] <= tau and sigma <= sig[i] for i in range(len(V)))
            checks += 1
            mism += const != vert
    out("   400 random point families x 10 random intervals: mismatches %d / %d (MAP sets compared at every"
        " breakpoint inside the interval and between consecutive breakpoints)" % (mism, checks))

    # ---------------- C
    out("\n== C. scout N2's population (its generator, seed 20261015) and parameters L=300, L3=150, k=60, s=15, c=12.4")
    r2 = random.Random(20261015)
    for _ in range(30):  # n2 consumed its RNG on 30 small trials first; replicate the draws
        [r2.randint(20, 400), r2.randint(20, 400)] + [r2.randint(1, 20) for _ in range(5)]
    bodies = []
    for i in range(8):
        bodies.append(("planet", int(r2.uniform(500, 5000))))
    for i in range(60):
        bodies.append(("asteroid", max(1, int(round(math.exp(r2.gauss(1.6, 1.0)))))))
    for i in range(30):
        bodies.append(("comet", r2.choice([1, 1, 1, 2])))
    ns = [nb for _, nb in bodies]
    out("   planets' observations: %s; total observations %d" % (sorted(nb for k_, nb in bodies if k_ == "planet"), sum(ns)))
    P = dict(L=300, L3=150, k=60, s=15, c=12.4)
    prev = None
    for lam in [1.0, 1.05, 1.2, 1.5, 2, 3, 4, 5, 6, 6.5, 7, 7.5, 8, 12, 20, 50, 100, 135, 136, 200, 319, 320, 400]:
        (val, length), (law, k3, S) = closed_form(ns, P, lam)
        kinds = {}
        for i in S:
            kinds[bodies[i][0]] = kinds.get(bodies[i][0], 0) + 1
        desc = ("law " if law else "") + ("K3 " if k3 else "") + " ".join("%s x%d" % kv for kv in sorted(kinds.items()))
        out("   lambda=%7.2f: |T|=%6d Exc=%9.1f  {%s}" % (lam, length, val - lam * length, desc.strip() or "empty"))
    # hull over the canonical family (law?, K3?, S = top-j bodies)
    order = sorted(range(len(ns)), key=lambda i: -ns[i])
    pts = []
    for law, k3 in ((False, False), (True, False), (True, True)):
        for j in range(len(ns) + 1):
            S = tuple(order[:j]) if law else ()
            _, length, exc = J((law, k3, S), ns, P, 1.0)
            pts.append((length, exc))
    V = hull_vertices(pts)
    for i in range(1, len(V)):
        sl_in = (V[i - 1][1] - V[i][1]) / (V[i][0] - V[i - 1][0])
        sl_out = (V[i][1] - V[i + 1][1]) / (V[i + 1][0] - V[i][0]) if i + 1 < len(V) else 0.0
        if sl_in > 1 and sl_out > 0 and sl_in / sl_out > 5:
            out("   steep kink at vertex |T|=%d Exc=%.1f: incoming slope %.2f, outgoing slope %.2f (ratio %.1f)" % (
                V[i][0], V[i][1], sl_in, sl_out, sl_in / max(sl_out, 1e-9)))
    # where K3 enters
    for lam in np.arange(4.0, 9.01, 0.25):
        (val, length), (law, k3, S) = closed_form(ns, P, lam)
        S1 = [i for i in range(len(ns)) if P["c"] * ns[i] > lam * P["k"]]
        out("   lambda=%.2f: K3 in MAP: %s; |S(lambda)| without K3 = %d; s|S| = %d vs L3 = %d vs lambda L3 = %.0f" % (
            lam, k3, len(S1), P["s"] * len(S1), P["L3"], lam * P["L3"]))

    # ---------------- D
    out("\n== D. explanatory power as the number of bodies grows: n = 5 observations per body, c = 12.4, k = 60, L = 300")
    P = dict(L=300, L3=150, k=60, s=15, c=12.4)
    for m in (1, 10, 100, 1000):
        ns = [5] * m
        for lam in (1.0, 1.02):
            (val, length), (law, k3, S) = closed_form(ns, P, lam)
            ep_law = P["c"] * sum(ns[i] for i in S) / P["L"] if law else float("nan")
            ep_el = P["c"] * 5 / (P["k"] - (P["s"] if k3 else 0))
            out("   m=%5d lambda=%.2f: MAP = %s; EP(law) = %.2f; EP(elements of one body) = %.3f" % (
                m, lam, ("law" + (" K3" if k3 else "") + " + %d elements" % len(S)) if law else "empty", ep_law, ep_el))
    out("   question format (elements in the antecedent; Prop 5.9): EP(law) = c * (all observations) / L, elements never enter:")
    for m in (1, 10, 100, 1000):
        out("   m=%5d: EP(law) = %.2f; the law enters iff lambda < %.2f" % (m, 12.4 * 5 * m / 300, 12.4 * 5 * m / 300))

    # ---------------- E
    out("\n== E. Myrvold's unification term U(D1,D2;h) = I(h;D1 u D2) - I(h;D1) - I(h;D2), I(h;D) = log2 P_h(D)/P_0(D)")
    out("   model: each observation is one bit g(theta, t) of a fixed random table, c = 1 bit literal; parameters theta of k bits")
    k = 6
    nr = np.random.default_rng(SEED)
    table = nr.integers(0, 2, size=(2 ** k, 64))  # g(theta, t)

    def logP_det(theta, obs):  # stated parameter: deterministic theory
        return 0.0 if all(table[theta, t] == v for t, v in obs) else -math.inf

    def logP_marg(obs):  # law with marginalised k-bit parameter
        cnt = sum(1 for th in range(2 ** k) if all(table[th, t] == v for t, v in obs))
        return math.log2(cnt) - k if cnt else -math.inf

    def I_(logp, obs):
        return logp - (-len(obs))  # P_0(D) = 2^{-|D|}

    th1, th2 = 13, 41
    D1 = [(t, int(table[th1, t])) for t in range(0, 20)]
    D2 = [(t, int(table[th1, t])) for t in range(20, 40)]
    E2 = [(t, int(table[th2, t])) for t in range(20, 40)]  # another body, independent parameter
    U_det = I_(logP_det(th1, D1 + D2), D1 + D2) - I_(logP_det(th1, D1), D1) - I_(logP_det(th1, D2), D2)
    U_m = I_(logP_marg(D1 + D2), D1 + D2) - I_(logP_marg(D1), D1) - I_(logP_marg(D2), D2)
    out("   one body, stated parameter (deterministic theory): I(D1)=%.1f I(D2)=%.1f I(D1+D2)=%.1f  U = %.2f" % (
        I_(logP_det(th1, D1), D1), I_(logP_det(th1, D2), D2), I_(logP_det(th1, D1 + D2), D1 + D2), U_det))
    out("   one body, marginalised %d-bit parameter: I(D1)=%.2f I(D2)=%.2f I(D1+D2)=%.2f  U = %.2f (prediction: k = %d)" % (
        k, I_(logP_marg(D1), D1), I_(logP_marg(D2), D2), I_(logP_marg(D1 + D2), D1 + D2), U_m, k))

    # two bodies with independent parameters: P_h(D1, E2) = P_h(D1) P_h(E2)
    lp_joint = logP_marg(D1) + logP_marg(E2)
    U_2 = (lp_joint + len(D1) + len(E2)) - I_(logP_marg(D1), D1) - I_(logP_marg(E2), E2)
    out("   two bodies, independent marginalised parameters: U = %.2f (prediction 0)" % U_2)
    # shared universal constant: theta_b = (C, phi_b) with C of kc bits shared, phi_b of k - kc bits private
    kc = 3

    def logP_shared(obs_by_body):
        tot = 0.0
        for C in range(2 ** kc):
            prod = 1.0
            for obs in obs_by_body:
                cnt = sum(1 for ph in range(2 ** (k - kc))
                          if all(table[(C << (k - kc)) | ph, t] == v for t, v in obs))
                prod *= cnt / 2 ** (k - kc)
            tot += prod / 2 ** kc
        return math.log2(tot) if tot > 0 else -math.inf
    Cst = 5
    thA, thB = (Cst << (k - kc)) | 2, (Cst << (k - kc)) | 6
    DA = [(t, int(table[thA, t])) for t in range(0, 20)]
    DB = [(t, int(table[thB, t])) for t in range(20, 40)]
    U_s = (logP_shared([DA, DB]) + 40) - (logP_shared([DA]) + 20) - (logP_shared([DB]) + 20)
    out("   two bodies sharing a %d-bit universal constant (private %d bits each): U = %.2f (prediction %d)" % (
        kc, k - kc, U_s, kc))

    out("\n# runtime %.0f s" % (time.time() - t0))
    out("# done")
    with open(__file__.replace(".py", ".out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()

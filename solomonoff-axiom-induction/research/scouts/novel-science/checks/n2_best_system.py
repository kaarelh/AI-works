#!/usr/bin/env python3
"""n2: the steeper best system on a toy solar system: laws, initial conditions and contingent facts.

Scout N2 (novel-science), push P2.  Seed 20261015.  Writes n2_best_system.out next to itself.

Model (all lengths in bits; nothing here is fitted to real data):
  * m bodies; body b has n_b interval observations, each costing c bits when stated literally;
  * the law Lam (Kepler's first two laws, formalised) costs L bits; with Lam, body b's elements (k bits)
    prove all n_b observations of b; without Lam, elements prove nothing (scout P, Prop 2.1);
  * the law K3 (period from semi-major axis) costs L3 bits and saves cP bits of every body's elements
    whose elements are in the theory (it is a law about initial conditions);
  * a theory T is (lam? , k3?, S) with S the set of bodies whose elements are axioms; the fit X(T) is the
    literal cost of the observations T does not prove ("exceptions");
  * the steeper two-part objective J_lambda(T) = lambda |T| + X(T); |T| = L[lam] + L3[k3] + sum_{b in S} k_b,
    k_b = k - cP[k3].

Computed:
  A. the lambda-MAP for a grid of lambda, by the closed-form rule (Prop P2.3) and by brute force on a small
     population (agreement check);
  B. the vertices of the lower convex hull of (|T|, X(T)) and their slopes (kink steepness sigma_i);
  C. deletion slopes (bits of data explained per bit of axiom) of the law, of K3 and of elements;
  D. the lambda = 1 tie for single-use facts.
"""
import itertools
import math
import random
import sys

SEED = 20261015
OUT = []


def out(*a):
    s = " ".join(str(x) for x in a)
    OUT.append(s)
    print(s)


def make_population(rng):
    bodies = []
    for i in range(8):  # planets: many observations
        bodies.append(("planet%d" % i, int(rng.uniform(500, 5000))))
    for i in range(60):  # asteroids: few observations (lognormal)
        bodies.append(("asteroid%02d" % i, max(1, int(round(math.exp(rng.gauss(1.6, 1.0)))))))
    for i in range(30):  # comets / one-off events: one or two observations
        bodies.append(("comet%02d" % i, rng.choice([1, 1, 1, 2])))
    return bodies


def cost(theory, bodies, P, lam):
    has_law, has_k3, S = theory
    k_b = P["k"] - (P["cP"] if has_k3 else 0)
    length = (P["L"] if has_law else 0) + (P["L3"] if has_k3 else 0) + k_b * len(S)
    proved = sum(bodies[i][1] for i in S) if has_law else 0
    X = P["c"] * (sum(nb for _, nb in bodies) - proved)
    return lam * length + X, length, X


def closed_form_map(bodies, P, lam):
    """Prop P2.3: for each (law, k3) choice, include body b iff c n_b > lam k_b; pick the best of 4 choices
    (ties broken toward the shorter theory)."""
    best = None
    for has_law in (False, True):
        for has_k3 in (False, True):
            if has_k3 and not has_law:
                continue  # K3 without positions-law saves nothing here (no elements are useful)
            k_b = P["k"] - (P["cP"] if has_k3 else 0)
            S = tuple(i for i, (_, nb) in enumerate(bodies) if has_law and P["c"] * nb > lam * k_b)
            J, length, X = cost((has_law, has_k3, S), bodies, P, lam)
            key = (J, length)
            if best is None or key < best[0]:
                best = (key, (has_law, has_k3, S))
    return best[1]


def brute_force_map(bodies, P, lam):
    best = None
    idx = range(len(bodies))
    for has_law in (False, True):
        for has_k3 in (False, True):
            for r in range(len(bodies) + 1):
                for S in itertools.combinations(idx, r):
                    J, length, X = cost((has_law, has_k3, S), bodies, P, lam)
                    key = (round(J, 9), length)
                    if best is None or key < best[0]:
                        best = (key, (has_law, has_k3, S))
    return best[1]


def describe(theory, bodies):
    has_law, has_k3, S = theory
    kinds = {}
    for i in S:
        kind = bodies[i][0].rstrip("0123456789")
        kinds[kind] = kinds.get(kind, 0) + 1
    parts = (["LAW"] if has_law else []) + (["K3"] if has_k3 else []) + ["%s x%d" % (k, v) for k, v in sorted(kinds.items())]
    return "{" + ", ".join(parts) + "}" if parts else "{} (all data as exceptions)"


def hull(points):
    """Lower convex hull (Andrew) of points (x, y), keeping the lower-left chain with decreasing y."""
    pts = sorted(set(points))
    lower = []
    for p in pts:
        while len(lower) >= 2:
            (x1, y1), (x2, y2) = lower[-2], lower[-1]
            if (x2 - x1) * (p[1] - y1) - (y2 - y1) * (p[0] - x1) <= 0:
                lower.pop()
            else:
                break
        lower.append(p)
    # keep the part with strictly decreasing y (the boundary that J_c can select)
    res = [lower[0]]
    for p in lower[1:]:
        if p[1] < res[-1][1]:
            res.append(p)
    return res


def main():
    rng = random.Random(SEED)
    out(f"# n2_best_system.py seed={SEED} python={sys.version.split()[0]}")
    # ---------------- A. agreement on a small population
    out("== A. closed-form lambda-MAP (Prop P2.3) against brute force, small populations")
    P_small = dict(L=300, L3=150, k=60, cP=15, c=12.4)
    agree = total = 0
    for trial in range(30):
        bodies = [("planet0", rng.randint(20, 400)), ("planet1", rng.randint(20, 400))] + \
                 [("asteroid%02d" % i, rng.randint(1, 20)) for i in range(5)] + [("comet00", 1), ("comet01", 1)]
        for lam in (1.0, 1.5, 2.0, 3.0, 5.0, 10.0, 30.0):
            a = closed_form_map(bodies, P_small, lam)
            b = brute_force_map(bodies, P_small, lam)
            Ja = cost(a, bodies, P_small, lam)[0]
            Jb = cost(b, bodies, P_small, lam)[0]
            total += 1
            agree += abs(Ja - Jb) < 1e-9
    out(f"  optimal values agree in {agree}/{total} (population, lambda) cases")

    # ---------------- main population
    bodies = make_population(rng)
    N_obs = sum(nb for _, nb in bodies)
    out("== population: 8 planets (500-5000 obs), 60 asteroids (lognormal, median ~5 obs), 30 comets (1-2 obs);"
        f" total observations {N_obs}")
    for P in (dict(L=300, L3=150, k=60, cP=15, c=12.4), dict(L=3000, L3=600, k=60, cP=15, c=12.4)):
        out(f"\n== parameters: law L={P['L']} bits, K3 L3={P['L3']} bits, elements k={P['k']} bits "
            f"(K3 saves cP={P['cP']}), datum c={P['c']} bits")
        # B. thresholds
        thr = sorted({P['c'] * nb / P['k'] for _, nb in bodies}, reverse=True)
        out("  element thresholds lambda_b = c n_b / k (body joins iff lambda < lambda_b): "
            f"planets {min(P['c'] * nb / P['k'] for n, nb in bodies if n.startswith('planet')):.1f}.."
            f"{max(P['c'] * nb / P['k'] for n, nb in bodies if n.startswith('planet')):.1f}; asteroids "
            f"{min(P['c'] * nb / P['k'] for n, nb in bodies if n.startswith('asteroid')):.2f}.."
            f"{max(P['c'] * nb / P['k'] for n, nb in bodies if n.startswith('asteroid')):.2f}; comets "
            f"{min(P['c'] * nb / P['k'] for n, nb in bodies if n.startswith('comet')):.2f}.."
            f"{max(P['c'] * nb / P['k'] for n, nb in bodies if n.startswith('comet')):.2f}")
        out("  lambda-MAP by lambda:")
        prev = None
        for lam in [1.0, 1.05, 1.2, 1.5, 2, 3, 5, 8, 12, 20, 50, 100, 200, 400, 800, 1600]:
            T = closed_form_map(bodies, P, lam)
            J, length, X = cost(T, bodies, P, lam)
            d = describe(T, bodies)
            out(f"    lambda={lam:7.2f}: |T|={length:7.0f} X={X:9.1f}  {d}")
        # hull over the canonical family: law+k3 choices and S = top-j bodies by n_b
        order = sorted(range(len(bodies)), key=lambda i: -bodies[i][1])
        pts = {}
        for has_law in (False, True):
            for has_k3 in (False, True):
                if has_k3 and not has_law:
                    continue
                for j in range(len(bodies) + 1):
                    S = tuple(order[:j]) if has_law else ()
                    _, length, X = cost((has_law, has_k3, S), bodies, P, 1.0)
                    key = (length, round(X, 6))
                    if key not in pts:
                        pts[key] = (has_law, has_k3, S)
        H = hull(list(pts.keys()))
        out("  lower hull of (|T|, X) (canonical family: law?, K3?, top-j bodies): vertices with slopes sigma_i")
        shown = 0
        for i, v in enumerate(H):
            sl = (H[i - 1][1] - v[1]) / (v[0] - H[i - 1][0]) if i > 0 else float("inf")
            nxt = (v[1] - H[i + 1][1]) / (H[i + 1][0] - v[0]) if i + 1 < len(H) else 0.0
            if i < 6 or i == len(H) - 1 or (sl > 1 >= nxt):
                out(f"    v{i:<3d} |T|={v[0]:7.0f} X={v[1]:9.1f}  left steepness sigma={sl:9.2f}  right flatness={nxt:7.2f}  "
                    f"{describe(pts[v], bodies)}")
                shown += 1
        out(f"    ({len(H)} vertices in all; vertices with left steepness > 1: {sum(1 for i in range(1, len(H)) if (H[i-1][1]-H[i][1])/(H[i][0]-H[i-1][0]) > 1)})")
        # C. deletion slopes at lambda = 2
        lam = 2.0
        T = closed_form_map(bodies, P, lam)
        has_law, has_k3, S = T
        J, length, X = cost(T, bodies, P, lam)
        out(f"  deletion slopes (bits of data explained per bit of axiom) in the lambda=2 MAP {describe(T, bodies)}:")
        if has_law:
            X_nolaw = cost((False, has_k3, S), bodies, P, lam)[2]
            out(f"    law: (X(T - law) - X(T)) / L = {(X_nolaw - X) / P['L']:.1f}")
        if has_k3:
            # removing K3 makes each body's elements cP bits longer; the deletion slope compares theory lengths
            out(f"    K3: saves {P['cP']} bits on each of {len(S)} bodies' elements: {P['cP'] * len(S)} bits per {P['L3']} bits "
                f"= {P['cP'] * len(S) / P['L3']:.2f}")
        for kind in ("planet", "asteroid"):
            sl = [P['c'] * bodies[i][1] / (P['k'] - (P['cP'] if has_k3 else 0)) for i in S if bodies[i][0].startswith(kind)]
            if sl:
                out(f"    elements of {kind}s in T: slopes {min(sl):.1f}..{max(sl):.1f}")
        # scaling: law's slope grows with the number of bodies, elements' slopes with observations per body
        out("  scaling (law slope vs elements slope) with m identical bodies of n observations each:")
        for m_, n_ in ((1, 50), (10, 50), (100, 50), (1000, 50), (100, 5), (100, 500)):
            law_slope = m_ * n_ * P['c'] / P['L']
            el_slope = n_ * P['c'] / P['k']
            out(f"    m={m_:5d} n={n_:4d}: law {law_slope:10.1f}   elements {el_slope:8.2f}")
    # D. lambda=1 tie for a single-use fact
    out("\n== D. single-use fact: datum d of c bits; as an axiom it costs c + a bits (a = delimiter overhead)")
    for a in (0, 1, 2):
        c = 12.4
        for lam in (1.0, 1.1, 2.0):
            ax = lam * (c + a)
            ex = c
            out(f"  a={a} lambda={lam}: axiom {ax:.1f} vs exception {ex:.1f} -> {'axiom' if ax < ex else ('tie' if ax == ex else 'exception')}")
    with open(__file__.replace(".py", ".out"), "w") as f:
        f.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()

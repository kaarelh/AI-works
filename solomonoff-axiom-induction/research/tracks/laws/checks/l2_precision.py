"""l2_precision.py -- precision regimes for proof-requiring compatibility of exact laws (thread `laws`, T2).

Seed 20261016.  Writes l2_precision.out next to itself.  Independent of scout N2's n3 (written from the
statements of notes.md section 2, not from n3's code).

Model.  A quantity q(t), t ~ U[0,1); an exact law f with error e(t) = f(t) - q(t).  Two error shapes:
    spread : e(t) = A sin(2 pi t)                      (eps* = A, E|e| = 2A/pi, pk = pi/2)
    peaked : e(t) = +-A on a set of measure rho, else 0 (eps* = A, E|e| = rho A, pk = 1/rho)
Units: arcmin, A = 1.
(G) guaranteed tolerance: datum "q(t) in [v - delta, v + delta]", v = q(t) + eta, eta ~ U[-delta0, delta0].
    The exact law proves the datum iff |e(t) - eta| <= delta, else refutes it (Prop 2.3).
(R) dithered rounding: datum "q(t) in the cell of width Delta (offset u ~ U[0,1)) containing q(t)".
    The exact law proves it iff f(t) is in the same cell, else refutes it (Prop 2.4).
Parts:
    A. (G): per-datum refutation probability r(delta) by Monte Carlo (10^6 draws) and the exact zero
       for delta >= eps* + delta0.
    B. (R): survival probability after n data, simulated (up to 20000 runs), against (1 - p_Delta)^n, and the mean
       index of the first refutation against 1/p_Delta, for Delta from 0.5 to 600 arcmin.
    C. a pool of three exact theories (proof-requiring, shortest compatible theory chosen): the choice as n
       grows under (G) and (R), against the predictions of Prop 2.5.
"""
import sys
import time
import numpy as np

SEED = 20261016
OUT = []


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def err(kind, t, A=1.0, rho=0.05):
    if kind == "spread":
        return A * np.sin(2 * np.pi * t)
    # peaked: +A on [0, rho/2), -A on [1/2, 1/2 + rho/2), 0 elsewhere
    e = np.zeros_like(t)
    e[t < rho / 2] = A
    e[(t >= 0.5) & (t < 0.5 + rho / 2)] = -A
    return e


def p_delta(kind, Delta, A=1.0, rho=0.05, m=2_000_000, rng=None):
    t = rng.random(m)
    return float(np.mean(np.minimum(np.abs(err(kind, t, A, rho)) / Delta, 1.0)))


def same_cell(x, y, Delta, u):
    return np.floor(x / Delta + u) == np.floor(y / Delta + u)


def main():
    t0 = time.time()
    rng = np.random.default_rng(SEED)
    out("# l2_precision.py seed=%d python %s numpy %s" % (SEED, sys.version.split()[0], np.__version__))

    # ---------------- A
    out("\n== A. regime (G): per-datum refutation probability r(delta) = Pr[|e(t) - eta| > delta], eta ~ U[-d0, d0]")
    out("   eps* = 1', delta0 = 0.5'; prediction: r > 0 iff delta < eps* + delta0 = 1.5' (Prop 2.3)")
    m = 1_000_000
    for kind in ("spread", "peaked"):
        t = rng.random(m)
        eta = rng.uniform(-0.5, 0.5, m)
        e = err(kind, t)
        row = []
        for d in (1.0, 1.25, 1.4, 1.45, 1.49, 1.5, 1.6, 2.0):
            r = float(np.mean(np.abs(e - eta) > d))
            row.append("delta=%.2f: %.2e" % (d, r))
        out("   %-6s " % kind + "; ".join(row))
        out("          survival of n=1000 data at delta=1.45: (1-r)^1000 = %.3e" %
            (1 - float(np.mean(np.abs(e - eta) > 1.45))) ** 1000)

    # ---------------- B
    out("\n== B. regime (R): survival of the exact law over n dithered data; first refutation index")
    out("   columns: Delta | p_Delta (MC) | p formula (Delta >= 2eps*: E|e|/Delta) | Pr[survive n=1,10,100] sim vs (1-p)^n |"
        " mean first-refutation index sim vs 1/p")
    for kind in ("spread", "peaked"):
        Ee = 2 / np.pi if kind == "spread" else 0.05
        out("   error shape: %s (E|e| = %.4f, eps* = 1, pk = %.3f)" % (kind, Ee, 1 / Ee))
        for Delta in (0.5, 1.0, 2.0, 10.0, 60.0, 600.0):
            p = p_delta(kind, Delta, rng=rng)
            pf = Ee / Delta if Delta >= 2 else float("nan")
            # simulate the first refutation index, drawing data only for runs not yet refuted
            R_ = int(min(20000, max(400, 4e7 * p)))
            cap = int(min(40.0 / p, 2_000_000))
            idx = np.full(R_, cap + 1, dtype=np.int64)
            alive_ids = np.arange(R_)
            n = 0
            chunk = 16
            while n < cap and alive_ids.size:
                k = min(chunk, cap - n)
                tt = rng.random((alive_ids.size, k))
                uu = rng.random((alive_ids.size, k))
                q = rng.uniform(0, 21600.0, (alive_ids.size, k))
                f = q + err(kind, tt)
                ref = ~same_cell(q, f, Delta, uu)
                hit = ref.any(axis=1)
                idx[alive_ids[hit]] = ref[hit].argmax(axis=1) + 1 + n
                alive_ids = alive_ids[~hit]
                n += k
                chunk = min(chunk * 2, 8192)
            surv = {nn: float(np.mean(idx > nn)) for nn in (1, 10, 100)}
            runs_used = R_
            mean_idx = float(np.mean(idx[idx <= cap])) if (idx <= cap).any() else float("nan")
            censored = int(np.sum(idx > cap))
            out("   Delta=%7.1f' | p=%.6f | %s | %.4f/%.4f %.4f/%.4f %.4f/%.4f | %10.1f vs %10.1f  (%d runs%s)" % (
                Delta, p, ("%.6f" % pf) if Delta >= 2 else "    -   ",
                surv[1], (1 - p), surv[10], (1 - p) ** 10, surv[100], (1 - p) ** 100,
                mean_idx, 1 / p, runs_used, (", censored %d at %d" % (censored, cap)) if censored else ""))

    # ---------------- C
    out("\n== C. pool of three exact theories, proof-requiring; the shortest compatible theory is chosen")
    out("   T1: |T1| = 100, error 10*sin (eps* = 10'); T2: |T2| = 150, error 1*sin (eps* = 1'); T3: |T3| = 400, exact.")
    out("   (G) prediction: eventual choice = shortest T_i with eps*_i + delta0 <= delta (delta0 = 0.5')")
    out("   (R) prediction: T_i survives about 1/p_i data, p_i = E min(|e_i|/Delta, 1); eventually only T3")
    eps = [10.0, 1.0, 0.0]
    runs = 2000
    ns = [1, 10, 100, 1000, 10000]
    for regime, levels in (("G", (20.0, 10.5, 5.0, 1.5, 1.2)), ("R", (600.0, 60.0, 10.0, 1.0))):
        for lev in levels:
            counts = {n_: [0, 0, 0] for n_ in ns}
            for r_ in range(runs):
                t = rng.random(max(ns))
                u = rng.random(max(ns))
                eta = rng.uniform(-0.5, 0.5, max(ns))
                q = rng.uniform(0, 21600.0, max(ns))
                first_ref = []
                for e_ in eps:
                    e = e_ * np.sin(2 * np.pi * t)
                    if regime == "G":
                        ref = np.abs(e - eta) > lev
                    else:
                        ref = ~same_cell(q, q + e, lev, u)
                    fr = int(ref.argmax()) + 1 if ref.any() else max(ns) + 1
                    first_ref.append(fr)
                for n_ in ns:
                    choice = next(i for i in range(3) if first_ref[i] > n_)
                    counts[n_][choice] += 1
            if regime == "G":
                pred = next(i for i in range(3) if eps[i] + 0.5 <= lev) + 1
                ptxt = "eventual choice T%d" % pred
            else:
                ps = [float(np.mean(np.minimum(np.abs(e_ * np.sin(2 * np.pi * rng.random(10 ** 6))) / lev, 1)))
                      for e_ in eps[:2]]
                ptxt = "1/p1 = %.1f, 1/p2 = %.1f" % (1 / ps[0], 1 / ps[1])
            cells = "  ".join("n=%-5d %4.2f/%4.2f/%4.2f" % (n_, *(c / runs for c in counts[n_])) for n_ in ns)
            out("   (%s) %s=%6.1f': shares of T1/T2/T3: %s   [%s]" % (
                regime, "delta" if regime == "G" else "Delta", lev, cells, ptxt))
    out("\n# runtime %.0f s" % (time.time() - t0))
    out("# done")
    with open(__file__.replace(".py", ".out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()

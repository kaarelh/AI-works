#!/usr/bin/env python3
"""n3: approximate theories under interval data: regimes, the humility window, and derivation horizons.

Scout N2 (novel-science), push P3.  Seed 20261015.  Writes n3_precision_phases.out next to itself.

Toy (units: arcminutes; nothing is fitted to real data):
  truth q(t) = 0.21 t (any value works: only cell membership matters), Kepler's law f_K = q + e with
  e(t) = eps_K sin(2 pi t / 0.37 + phi), eps_K = 1'; Newton is exact.  Times t uniform on [0, 1000].
Theories and lengths (common part omitted):
  E   exact Kepler                     lambda * 0
  P   exact Kepler + r patches         lambda * r (logN + 2) + r c_f   (each refuted datum: the law is
                                       withdrawn at that time (logN + 2 bits) and the datum is an exception)
  H   honest Kepler ("within eps_K")   lambda * D_eps + c_f * #(fine data it does not prove)
  N   Newton                           lambda * D_N
Data: fine interval data at cell width h ("rounding with dither": a random offset per datum), cost
c_f = log2(21600 / h) bits each.
Parts:
  A  survival of exact Kepler under rounding: mean refutation time against 1/p, p = E min(|e|/h, 1);
  B  guaranteed-tolerance data: refutation probability p_G(delta) is 0 iff delta >= eps_K + delta_0;
  C  the phase diagram over (h, n_f) for two error profiles (spread-out sinusoid; concentrated on 5% of
     times), lambda in {1, 2}, D_N in {200, 2000}; asymptotic per-datum costs;
  D  derivation horizons of an approximate iterated law x_{s+1} = F(x_s) + O(eps), F L-Lipschitz.
"""
import math
import sys

import numpy as np

SEED = 20261015
OUT = []


def out(*a):
    s = " ".join(str(x) for x in a)
    OUT.append(s)
    print(s)


EPS_K = 1.0
RANGE = 21600.0
LOGN = 20.0
D_EPS = 20.0


PROFILE = {"name": "sinusoid"}


def err(t, phi):
    """Kepler's error e(t).  'sinusoid': eps_K sin(.) (spread out, sup/mean = pi/2);
    'concentrated': +-eps_K on a fraction 0.05 of times, 0 elsewhere (sup/mean = 20)."""
    if PROFILE["name"] == "sinusoid":
        return EPS_K * np.sin(2 * np.pi * t / 0.37 + phi)
    frac = np.mod(t / 0.37 + phi, 1.0)
    return np.where(frac < 0.05, EPS_K * np.where(frac < 0.025, 1.0, -1.0), 0.0)


def p_round(h, rng, nsamp=400000):
    t = rng.uniform(0, 1000, nsamp)
    e = err(t, 0.3)
    return float(np.mean(np.minimum(np.abs(e) / h, 1.0)))


def simulate(h, nf, nseeds, rng):
    """Returns arrays over seeds: r (refuted count), proved_by_honest."""
    t = rng.uniform(0, 1000, (nseeds, nf))
    phi = 0.3
    q = 0.21 * t
    fK = q + err(t, phi)
    u = rng.uniform(0, h, (nseeds, nf))
    cell_q = np.floor((q + u) / h)
    cell_K = np.floor((fK + u) / h)
    refuted = (cell_q != cell_K).sum(axis=1)
    lo = np.floor((fK - EPS_K + u) / h)
    hi = np.floor((fK + EPS_K + u) / h)
    honest_proves = ((lo == hi) & (lo == cell_q)).sum(axis=1)
    return refuted, honest_proves


def main():
    rng = np.random.default_rng(SEED)
    out(f"# n3_precision_phases.py seed={SEED} python={sys.version.split()[0]} numpy={np.__version__}")

    out("== A. exact Kepler under rounded data with dither: refutation time")
    out("   h      p=E min(|e|/h,1)   1/p      mean refutation index (2000 runs)   P(survive 10 data) sim / (1-p)^10")
    for h in (0.25, 0.5, 1.0, 2.0, 5.0, 10.0, 60.0):
        p = p_round(h, rng)
        n = 4000
        t = rng.uniform(0, 1000, (2000, n))
        q = 0.21 * t
        fK = q + err(t, 0.3)
        u = rng.uniform(0, h, (2000, n))
        bad = np.floor((q + u) / h) != np.floor((fK + u) / h)
        first = np.where(bad.any(axis=1), bad.argmax(axis=1) + 1, n + 1)
        surv10 = float(np.mean(first > 10))
        out(f"   {h:5.2f}  {p:8.4f}         {1 / p:8.2f}   {first.mean():8.2f}                         {surv10:.3f} / {(1 - p) ** 10:.3f}")

    out("\n== B. guaranteed-tolerance data: v = q + eta, eta ~ U[-d0, d0], datum 'q in [v-delta, v+delta]' (true)")
    d0 = 0.5
    out(f"   d0={d0}; exact Kepler refutes iff |e - eta| > delta; threshold eps_K + d0 = {EPS_K + d0}")
    t = rng.uniform(0, 1000, 2_000_000)
    e = err(t, 0.3)
    eta = rng.uniform(-d0, d0, t.size)
    for delta in (0.5, 1.0, 1.25, 1.4, 1.49, 1.5, 1.6, 2.0):
        pG = float(np.mean(np.abs(e - eta) > delta))
        out(f"   delta={delta:5.2f}: p_G={pG:.6f}   P(survive 10^4 data)~{math.exp(-1e4 * pG) if pG > 0 else 1.0:.3g}")

    out("\n== C. phase diagram: modal lambda-MAP over 300 seeds (E exact Kepler, P patched exact Kepler,"
        " H honest Kepler, N Newton) and its frequency")
    out("   asymptotic per-datum costs: P: p(h)(lambda(logN+2)+c_f), p = E min(|e|/h,1);  H: q(h) c_f, q = min(2 eps_K/h, 1);"
        "  N: 0 (one-off lambda D_N).  'asym' = the cheaper of P and H per datum.")
    hs = (0.05, 0.1, 0.25, 0.5, 1.0, 1.5, 2.0, 3.0, 5.0, 10.0)
    nfs = (1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 3000)
    for prof, lam, DN in (("sinusoid", 1.0, 200.0), ("sinusoid", 1.0, 2000.0), ("sinusoid", 2.0, 2000.0),
                          ("concentrated", 1.0, 2000.0), ("concentrated", 2.0, 2000.0)):
        PROFILE["name"] = prof
        ps = {h: p_round(h, rng) for h in hs}
        tt = rng.uniform(0, 1000, 400000)
        ee = np.abs(err(tt, 0.3))
        kappa = float(ee.max() / ee.mean())
        out(f"\n  error profile={prof} (sup|e|/E|e| = {kappa:.2f})  lambda={lam} D_N={DN:.0f} D_eps={D_EPS:.0f} logN={LOGN:.0f}")
        out("   h \\ n_f " + "".join(f"{nf:>9d}" for nf in nfs) + "   p(h)  q(h)  asym  n_f*(H->N) n_f*(P->N)")
        for h in hs:
            cf = math.log2(RANGE / h)
            row = []
            for nf in nfs:
                r, hp = simulate(h, nf, 300, rng)
                J_P = lam * r * (LOGN + 2) + r * cf  # r = 0 is exact Kepler
                J_H = lam * D_EPS + cf * (nf - hp)
                J_N = lam * DN * np.ones_like(J_P)
                Js = np.stack([J_P, J_H, J_N])
                win = Js.argmin(axis=0)
                labels = np.where(win == 0, np.where(r == 0, 0, 1), win + 1)  # 0 E, 1 P, 2 H, 3 N
                counts = np.bincount(labels, minlength=4)
                k = int(counts.argmax())
                row.append(f"{'EPHN'[k]}{counts[k] / 300:4.2f}".rjust(9))
            p = ps[h]
            q = min(2 * EPS_K / h, 1.0)
            costP = p * (lam * (LOGN + 2) + cf)
            costH = q * cf
            asym = "H" if costH < costP else "P"
            nHN = lam * (DN - D_EPS) / costH
            nPN = lam * DN / costP
            out(f"   {h:6.2f} " + "".join(row) + f"  {p:5.3f} {q:5.3f}   {asym}   {nHN:9.1f} {nPN:10.1f}")
    out("   (for h >= 2 eps_K: H beats P per datum iff lambda (logN+2) > c_f (2 kappa - 1), kappa = sup|e|/E|e|;"
        " for h -> 0: iff P(e != 0) > c_f / (lambda(logN+2) + c_f))")
    out("\n== D. derivation horizon of an approximate iterated law: tolerance after r steps "
        "e_r = L^r e0 + eps (L^r - 1)/(L - 1)")
    eps = 1.0
    out("   L      delta/eps=10   100    10^4   (largest r with e_r <= delta, e0 = 0)   typical |error| after r* steps"
        " with random-sign errors (2000 runs, L=1 only: ~ eps sqrt(r))")
    for L in (1.0, 1.01, 1.1, 2.0):
        hz = []
        for ratio in (10, 100, 1e4):
            delta = ratio * eps
            if L == 1.0:
                r = int(delta / eps)
            else:
                r = int(math.floor(math.log(1 + delta * (L - 1) / eps) / math.log(L)))
            hz.append(r)
        extra = ""
        if L == 1.0:
            r = hz[1]
            signs = rng.choice([-1.0, 1.0], size=(2000, r))
            typ = float(np.mean(np.abs(signs.sum(axis=1)))) * eps
            extra = f"r*={r}: mean |error| {typ:.1f} (worst case {r * eps:.0f}; sqrt(2r/pi)={math.sqrt(2 * r / math.pi):.1f})"
        out(f"   {L:5.2f}  {hz[0]:8d} {hz[1]:8d} {hz[2]:8d}      {extra}")
    with open(__file__.replace(".py", ".out"), "w") as f:
        f.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()

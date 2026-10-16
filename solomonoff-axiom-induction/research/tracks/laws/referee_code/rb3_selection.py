"""rb3_selection.py -- Referee B, thread `laws`: (A) independent recomputation of the code-Q statements of notes
section 3.6 from the saved residuals; (B) independent simulation of Thm 3.8 / Cor 3.9 (phases, switch times, ties).

A. Pure forms 0, P (exact law of the mean fit, deterministic patches), H (honest law of the minimax fit) under Q/det,
   lambda in {1, 2, 4}, Delta on a fine log grid in [0.1', 10800'].  Rates are exact over the dither in all
   regimes (Lemma 3.2 exact form): P refuted w.p. min(|e|/Delta, 1) and then costs lam pi_c + gamma;
   H not proved w.p. min((eps + max(|e|, eps))/Delta, 1) (silent, never refuted), costing gamma.  Checked:
   (i) record: "at lambda = 1 the honest law wins only at the coarsest cells (30 deg, in two windows already
   10 deg), and for 17 of the 39 body-window pairs not even at 30 deg"; (ii) takeover widths at lambda = 2, 4;
   (iii) the fine regime: H's per-datum cost is exactly gamma (= the empty law's), an exact tie.
B. Cor 3.9 rows 1-2 (sinusoid, Delta = 60', lambda = 1 and 2; l_0 = 200, h = 20, h_N = 2000, pi_c = 22):
   independent simulation (different RNG stream and event code): mean P->H passage time against Wald bounds,
   H->N, first refutation against 1/p; ties (pi_c tuned so that m_P = m_H): sign changes of J(P) - J(H).
Seed 20261017 (deliberately different from the developer's).  Writes rb3_selection.out next to itself.
"""
import math
import os
import sys
import time
import numpy as np

SEED = 20261017
OUT = []
RANGE = 21600.0
HERE = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(HERE, "..", "checks", "l4_residuals.npz")


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def main():
    t0 = time.time()
    out("# rb3_selection.py seed=%d python %s numpy %s" % (SEED, sys.version.split()[0], np.__version__))
    Z = np.load(RES, allow_pickle=False)
    order_b = ["Mercury", "Venus", "EMB", "Mars", "Jupiter", "Saturn", "Moon"]

    def sortkey(k):
        b, w = k.split("_")
        wv = {"1month": 1 / 12, "1year": 1.0, "18.6yr": 18.6}.get(w, None)
        return (order_b.index(b), float(w) if wv is None else wv)
    rows = sorted({k[:-2] for k in Z.files if k.endswith("_t")}, key=sortkey)

    # ---------------- A
    out("\n== A. code Q, deterministic patches: least rate among 0, P, H (exact dither averages)")
    record_D = [0.1, 0.3, 1.0, 3.0, 10.0, 30.0, 60.0, 120.0, 300.0, 600.0, 1800.0]
    grid = np.exp(np.linspace(math.log(0.1), math.log(10800.0), 600))
    never30 = []
    out("   %-8s %7s | lam=1: H wins from (record grid) | lam=2 takeover | lam=4 takeover | fine-regime tie H = 0 exact" % (
        "body", "window"))
    takeover = {2.0: [], 4.0: []}
    tie_ok = True
    for k in rows:
        b, w = k.split("_")
        em = Z[k + "_e_mean"].astype(float)
        ex = Z[k + "_e_max"].astype(float)
        eps = float(np.max(np.abs(ex)))
        t = Z[k + "_t"].astype(float)
        pic = math.log2(float(t.max() - t.min())) + 2
        ae, ax = np.abs(em), np.abs(ex)

        def rates(D, lam):
            g = math.log2(RANGE / D)
            p = float(np.mean(np.minimum(ae / D, 1.0)))
            npH = float(np.mean(np.minimum((eps + np.maximum(ax, eps)) / D, 1.0)))
            return g, p * (lam * pic + g), npH * g, npH
        res = {}
        for lam in (1.0, 2.0, 4.0):
            wins = []
            for D in record_D:
                g, P, H, npH = rates(D, lam)
                wins.append(min((g, "0"), (P, "P"), (H, "H"))[1])
                if D < 2 * eps and lam == 1.0:
                    tie_ok &= (npH == 1.0 and H == g)
            res[lam] = wins
            if lam > 1:
                first = None
                for D in grid:
                    g, P, H, npH = rates(D, lam)
                    if H < P and H < g:
                        first = D
                        break
                takeover[lam].append((first, k))
        h1 = [D for D, wv in zip(record_D, res[1.0]) if wv == "H"]
        if "H" not in res[1.0]:
            never30.append(k)
        out("   %-8s %7s | %-14s | %s" % (b, w, ("%g'" % h1[0]) if h1 else "never (<=1800')",
                                         " ".join(res[1.0])))
    out("   lambda = 1: pairs where H never has the least rate up to 1800' (30 deg): %d of %d (record: 17 of 39)" % (
        len(never30), len(rows)))
    out("   fine regime (Delta < 2 eps*), code Q: H silent on every datum, rate exactly gamma = the empty law's: %s" % tie_ok)
    for lam in (2.0, 4.0):
        vals = sorted((D, k) for D, k in takeover[lam] if D is not None)
        nn = sum(1 for D, k in takeover[lam] if D is None)
        med = np.median([D for D, k in vals]) if vals else float("nan")
        out("   lambda = %g: least Delta (fine grid) at which H has the least rate: min %.3g' (%s), median %.3g', max %.3g' (%s);"
            " never below 10800': %d" % (lam, vals[0][0], vals[0][1], med, vals[-1][0], vals[-1][1], nn))

    # ---------------- B
    out("\n== B. Cor 3.9, independent simulation (sinusoid, eps* = 1', Delta = 60')")
    rng = np.random.default_rng(SEED)
    D = 60.0
    g = math.log2(RANGE / D)
    l0, h, hN, pic = 200.0, 20.0, 2000.0, 22.0
    p = 2 / math.pi / D
    q = 2 / D
    for lam in (1.0, 2.0):
        mP, mH = p * (lam * pic + g), q * g
        PH, HN, FR = [], [], []
        seqs = {}
        runs, nmax = 2000, 40000
        for _ in range(runs):
            tt = rng.random(nmax)
            e = np.sin(2 * np.pi * tt)
            u = rng.random(nmax)
            # exact law refuted iff the point f = q + e lies outside q's cell [-uD, (1-u)D)
            ref = ~((e >= -u * D) & (e < (1 - u) * D))
            # honest law (eps = 1) proves iff [e-1, e+1] inside the cell
            prv = (e - 1 >= -u * D) & (e + 1 < (1 - u) * D)
            n = np.arange(1, nmax + 1)
            R0 = np.cumsum(ref)
            Sil = np.cumsum(~prv)
            JP = lam * l0 + R0 * (lam * pic + g)          # E/P (E = P with no patch)
            JH = lam * (l0 + h) + Sil * g
            JN = np.full(nmax, lam * (l0 + hN))
            J0 = n * g
            M = np.vstack([J0, JP, JH, JN])
            win = np.argmin(M, axis=0)
            lab = np.array(["0", "P", "H", "N"])[win]
            lab = np.where((lab == "P") & (R0 == 0), "E", lab)
            s = [lab[0]]
            for x in lab[1:]:
                if x != s[-1]:
                    s.append(x)
            key = "".join(s)
            seqs[key] = seqs.get(key, 0) + 1
            i = np.nonzero(JH < JP)[0]
            if i.size:
                PH.append(i[0] + 1)
            i = np.nonzero(JN < JH)[0]
            if i.size:
                HN.append(i[0] + 1)
            if R0[-1] > 0:
                FR.append(int(np.argmax(ref)) + 1)
        lo, hi = lam * h / (mP - mH), (lam * h + lam * pic + g) / (mP - mH)
        loN, hiN = lam * (hN - h) / mH, (lam * (hN - h) + g) / mH
        top = sorted(seqs.items(), key=lambda kv: -kv[1])[:4]
        out("   lambda=%g: m_P=%.4f m_H=%.4f; top sequences %s" % (lam, mP, mH, ", ".join("%s (%d)" % kv for kv in top)))
        out("      P->H passage: mean %.1f +- %.1f (%d runs), Wald [%.1f, %.1f];  H->N: mean %.1f +- %.1f, Wald [%.1f, %.1f];"
            "  first refutation %.1f +- %.1f vs 1/p = %.2f" % (
                np.mean(PH), np.std(PH) / math.sqrt(len(PH)), len(PH), lo, hi, np.mean(HN), np.std(HN) / math.sqrt(len(HN)),
                loN, hiN, np.mean(FR), np.std(FR) / math.sqrt(len(FR)), 1 / p))
    # ties: Delta = 10', lambda = 1, pi_c with m_P = m_H
    D = 10.0
    g = math.log2(RANGE / D)
    p, q = 2 / math.pi / D, 2 / D
    pic_t = q * g / p - g
    ch2k, ch200k, late = [], [], []
    for _ in range(100):
        nn = 200_000
        e = np.sin(2 * np.pi * rng.random(nn))
        u = rng.random(nn)
        ref = ~((e >= -u * D) & (e < (1 - u) * D))
        prv = (e - 1 >= -u * D) & (e + 1 < (1 - u) * D)
        d = np.cumsum(ref * (pic_t + g) - (~prv) * g) - 20.0
        sg = np.sign(d)
        c = np.nonzero(sg[1:] != sg[:-1])[0]
        ch2k.append(int(np.sum(c < 2000)))
        ch200k.append(c.size)
        late.append(bool(c.size and c[-1] > 100_000))
    out("   ties (Delta = 10', pi_c = %.3f so that m_P = m_H): mean sign changes up to 2000: %.1f, up to 2e5: %.1f;"
        " share with a change after 1e5: %.2f  (record: 14.9, 148, 0.43)" % (pic_t, np.mean(ch2k), np.mean(ch200k), np.mean(late)))

    out("\n# runtime %.0f s" % (time.time() - t0))
    out("# done")
    with open(os.path.join(HERE, "rb3_selection.out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()

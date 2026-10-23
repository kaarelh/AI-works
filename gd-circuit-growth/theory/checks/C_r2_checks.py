"""C revision 2: numerical checks for the changes made after the round-1 referee report (referee_C_r1.json).

  (1) Class sizes for the 'Which class wins' paragraph of section 1.2: PAR_8 and dnf3 in the three classes.
  (2) Corollary C2.5, the three admissible size bounds: (i) measured kappa_B, (ii) Gershgorin with the empirical
      coherence mu_n, (iii) Gershgorin with the Hoeffding bound mubar = sqrt(2 ln(2 D_{2k}/delta')/n), with effective
      time tau(t) and with raw time t.  Recomputed from c2_diag_check.json (no re-integration).
  (3) Float16 -> float32 transfer term for the section 1.4 certificates (from referee_C_r1_fp16.out: at most 2 of the
      4096 independent test inputs disagree).
  (4) Real-valued junta distance of the saved final networks: rigorous upper confidence bound on
      ||clip f - E[clip f | x_R]||^2 by the pair estimator, against the saved (d-|R|)*infl_irr, which averages only
      the first 5 irrelevant coordinates, and against the full influence sum over all d-|R| irrelevant coordinates.
  (5) Corollary C3.5(1) with the corrected union bound ln(2|T||Sigma|/delta).
  (6) Section 1.4 per-seed (error, certificate) pairs from c1_fourier_cert.json.

Reads $RESULTS read-only (part 4 only).  Runs in about a minute on one core with OPENBLAS_NUM_THREADS=1.
"""
import os, sys, json, math, time
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, "..", "..", "study"))
import numpy as np
import c_common as cc
from boolfuncs import make_suite

RESULTS = os.environ.get("RESULTS", "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/results")
FNS = ["dict", "and3", "maj3", "maj9", "thr10", "par2", "par3", "par4", "dnf3", "majpar", "mux", "parmaj", "stair5"]


def lnF(k, T, d=30):
    Dk = sum(math.comb(d, i) for i in range(1, k + 1))
    return cc.log_binom(Dk, T) + cc.log_Phi(2 ** min(T, d), T)


def lnC(T, d=30):
    return cc.logsumexp([s * math.log(16 * (d + s) ** 2) + math.log(d + s) - math.lgamma(s + 1) for s in range(T + 1)])


def lnJ(k, d=30):
    Ness = lambda j: sum((-1) ** (j - i) * math.comb(j, i) * 2 ** (2 ** i) for i in range(j + 1))
    return math.log(sum(math.comb(d, j) * Ness(j) for j in range(k + 1)))


def part1():
    print("(1) class sizes at d=30, nats")
    print(f"    PAR_8 = chi_[8]:  F_(8,1) {lnF(8, 1):.1f}   C_<=7 {lnC(7):.1f}   J_<=8 {lnJ(8):.1f}")
    print(f"    dnf3 (OR of three 3-literal ANDs on disjoint variables):  C_<=8 {lnC(8):.1f}   "
          f"F_(3,21) [sgn(p1+p2+p3-1/2), 21 characters] {lnF(3, 21):.1f}   F_(3,18) {lnF(3, 18):.1f}   J_<=9 {lnJ(9):.1f}")
    # check the 21-character representation of dnf3 by enumeration of its 9 relevant variables
    X = np.array(np.meshgrid(*[[-1.0, 1.0]] * 9, indexing="ij")).reshape(9, -1).T
    lit = lambda i, neg: -X[:, i] if neg else X[:, i]
    terms = [[(0, 0), (1, 0), (2, 0)], [(3, 0), (4, 1), (5, 0)], [(6, 0), (7, 0), (8, 1)]]
    p = sum(np.prod([(1 + lit(i, ng)) / 2 for i, ng in t], axis=0) for t in terms)
    y = make_suite(30)["dnf3"]["fn"](np.hstack([X, np.ones((len(X), 21))]))
    print(f"    sgn(p1+p2+p3-1/2) == dnf3 on all 512 assignments of x1..x9: {bool(np.all(np.sign(p - 0.5) == y))}")


def part2():
    print("(2) Corollary C2.5 at gamma=1/2 (eps = gamma/(2D)); delta = 0.05 for C2.4, delta' = 0.05 for (iii)")
    R = json.load(open(os.path.join(HERE, "c2_diag_check.json")))
    d, k, D, gam, dl, dlp = 10, 3, 176, 0.5, 0.05, 0.05
    D2k = sum(math.comb(d, i) for i in range(min(2 * k, d) + 1))
    ell = lambda N: cc.log_binom(D, N) + cc.log_Phi(2 ** min(N, d + 1), N)
    def bound(phat, N, n):
        N = min(N, D)
        lstar = max(ell(j) for j in range(N + 1))
        return cc.klinv_upper(phat, (lstar + math.log((N + 1) * (N + 2) / dl)) / n)
    def Ngersh(mu, x):
        if x < 1:
            return 0
        if mu * x >= 1:
            return None
        return int(math.floor((1 - mu) * x / (1 - mu * x) + 1e-12))
    print("    target   n  alpha | mu_n  mubar | t=60: tau  x=(tau/Th)^2 | (i) N bound | (ii) N bound | (iii,tau) N bound"
          " | (iii,t) N | best over printed t: (iii,tau); (iii,t) [N]")
    for r in R:
        n, a = r["n"], r["alpha"]
        Th = 0.25 * math.asinh((gam / (2 * D)) / (2 * a * a))
        mubar = math.sqrt(2 * math.log(2 * D2k / dlp) / n)
        best, bestt = (1.0, None), (1.0, None)
        for row in r["rows"]:
            x = (row["tau"] / Th) ** 2
            Nh = Ngersh(mubar, x)
            b = bound(row["phat_gamma"], Nh, n) if Nh is not None else 1.0
            if b < best[0]:
                best = (b, row["t"])
            Nt = Ngersh(mubar, (row["t"] / Th) ** 2)
            b = bound(row["phat_gamma"], Nt, n) if Nt is not None else 1.0
            if b < bestt[0]:
                bestt = (b, row["t"], Nt)
        row = r["rows"][-1]
        x = (row["tau"] / Th) ** 2
        xt = (row["t"] / Th) ** 2
        Ng, Nh, Nht = Ngersh(r["mu_coh"], x), Ngersh(mubar, x), Ngersh(mubar, xt)
        bg = bound(row["phat_gamma"], Ng, n) if Ng is not None else 1.0
        bh = bound(row["phat_gamma"], Nh, n) if Nh is not None else 1.0
        fmt = lambda N, b: (f"{N:4d} {b:.3f}" if N is not None else "   - vac. ")
        print(f"    {r['name']:5s} {n:4d} {a:.0e} | {r['mu_coh']:.3f} {mubar:.3f} | {row['tau']:6.2f} {x:7.3f} |"
              f" {row['apriori_N_kappa']:4d} {row['apriori_kappa']:.3f} | {fmt(Ng, bg)} | {fmt(Nh, bh)} | "
              f"{'vac.' if Nht is None else Nht} | {best[0]:.3f} at t={best[1]}; {bestt[0]:.3f} at t={bestt[1]}"
              + (f" [N={bestt[2]}]" if bestt[1] is not None else ""))
    # sample size at which (iii) with raw time t is non-vacuous in the sense mubar * xbar <= 1/2
    print("    (iii) with raw time needs mubar*(t/Theta)^2 < 1, i.e. n > 2 ln(2 D_2k/delta') (t/Theta)^4;"
          f" ln(2 D_2k/delta') = {math.log(2 * D2k / dlp):.2f} at d=10, k=3")


def part3():
    print("(3) fp16 -> fp32 transfer: dis(h32, h16) <= klinv(j/4096, ln(1/delta3)/4096), delta3 = 0.01")
    for j in (0, 1, 2):
        print(f"    {j} disagreements of 4096: {cc.klinv_upper(j / 4096, math.log(1 / 0.01) / 4096):.4f}")


def fwd(p, X):
    h1 = np.maximum(X @ p["W1"].T + p["b1"], 0)
    h2 = np.maximum(h1 @ p["W2"].T + p["b2"], 0)
    return h2 @ p["a"]


def part4(m_pairs=40000, m_infl=2000, delta=0.05):
    print(f"(4) junta distance of the saved final networks (n in 256, 2048, 16384; 3 seeds), R = relevant set")
    print(f"    Jc = pair estimate of ||clip f - E[clip f|x_R]||^2 on {m_pairs} pairs; UCB = 2*klinv(Jc/2, ln(1/{delta})/m)")
    print(f"    J  = the same for f unclipped (estimate); S = sum over ALL irrelevant i of E(f-f.flip_i)^2/4 on {m_infl}"
          f" inputs (estimate); E5 = (d-|R|)*infl_irr as saved (first 5 irrelevant coordinates, 1024 test inputs)")
    print("    target     n | max over seeds:  Jc     UCB(Jc)  |  J      S       E5     | S/E5 per seed")
    suite = make_suite(30)
    rng = np.random.default_rng(20261023)
    t0 = time.time()
    out = {}
    for fn in FNS:
        P = np.load(os.path.join(RESULTS, f"params_fixed_adam_{fn}.npz"))
        Z = np.load(os.path.join(RESULTS, f"fixed_adam_{fn}.npz"))
        rel = suite[fn]["relevant"]
        irr = [i for i in range(30) if i not in rel]
        for n in (256, 2048, 16384):
            rows = []
            for j in [i for i, n_ in enumerate(Z["net_n"]) if n_ == n]:
                p = {kk: P[kk][j].astype(np.float32) for kk in ["W1", "b1", "W2", "b2", "a"]}
                X = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(m_pairs, 30))
                X2 = X.copy()
                X2[:, irr] = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(m_pairs, len(irr)))
                f1, f2 = fwd(p, X), fwd(p, X2)
                Jc = float(np.mean(0.5 * (np.clip(f1, -1, 1) - np.clip(f2, -1, 1)) ** 2))
                ucb = 2 * cc.klinv_upper(Jc / 2, math.log(1 / delta) / m_pairs)
                J = float(np.mean(0.5 * (f1 - f2) ** 2))
                Xi = X[:m_infl]
                fi = f1[:m_infl]
                S = 0.0
                for i in irr:
                    Xf = Xi.copy(); Xf[:, i] *= -1
                    S += float(np.mean((fi - fwd(p, Xf)) ** 2) / 4)
                E5 = float(len(irr) * Z["infl_irr"][-1, j])
                rows.append((Jc, ucb, J, S, E5))
            A = np.array(rows)
            out[(fn, n)] = A
            print(f"    {fn:7s} {n:5d} |  {A[:,0].max():.4f}  {A[:,1].max():.4f}  | {A[:,2].max():.4f} {A[:,3].max():.4f}"
                  f" {A[:,4].max():.4f} | " + " ".join(f"{s/e:.2f}" if e > 0 else "-" for s, e in zip(A[:, 3], A[:, 4])))
    allA = np.concatenate(list(out.values()))
    print(f"    over all {len(allA)} networks: J <= S always: {bool(np.all(allA[:,2] <= allA[:,3] * 1.05 + 1e-4))};"
          f" S/E5 ranges {np.min(allA[:,3]/allA[:,4]):.2f}-{np.max(allA[:,3]/allA[:,4]):.2f} (median "
          f"{np.median(allA[:,3]/allA[:,4]):.2f}); UCB(Jc) max {allA[:,1].max():.4f}; ({time.time()-t0:.0f}s)")
    for n in (2048, 16384):
        B = np.concatenate([out[(fn, n)] for fn in FNS])
        print(f"    n={n}: UCB(Jc) <= {B[:,1].max():.4f} for all 39 networks; median {np.median(B[:,1]):.4f}")


def part5():
    print("(5) Corollary C3.5(1): eps^U = ln(2 |T| |Sigma| / delta2) / m with |T| = 15, m = 4096, delta2 = 0.05")
    for sig in (14, 20, 23):
        print(f"    |Sigma| = {sig}: old ln(|T||Sigma|/d)/m = {math.log(15 * sig / 0.05) / 4096:.2e}, "
              f"corrected {math.log(2 * 15 * sig / 0.05) / 4096:.2e}")


def part6():
    print("(6) section 1.4 per-seed true error / certificate, seeds 0,1,2")
    d = json.load(open(os.path.join(HERE, "c1_fourier_cert.json")))
    g = {}
    for r in d:
        g.setdefault((r["fn"], r["n"]), []).append((r["seed"], r["true_err"], r["bound"]))
    worst = min(r["bound"] - r["true_err"] for r in d)
    for fn in FNS:
        cells = []
        for n in (256, 2048, 16384):
            v = sorted(g[(fn, n)])
            cells.append(" ".join(f"{e:.3f}/{b:.3f}" for _, e, b in v))
        print(f"    {fn:7s} | " + " | ".join(cells))
    print(f"    min over the 117 runs of (certificate - true error) = {worst:.4f}")


if __name__ == "__main__":
    part1(); part2(); part3(); part5(); part6()
    part4()

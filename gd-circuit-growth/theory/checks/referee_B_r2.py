"""Referee round 2 checks for ../B-nn-time-bounds.md (revision 2).  numpy/scipy only, about a minute.

  1. Lemma B2.1a (new): brute force over random margin vectors and complexities with c >= max(1, mean(yf)_+):
     the B2.1 bound (nnbounds.margin_bound) is >= 1 for every gamma_max; necessity of c >= mean(yf)_+;
     where the minimum sits and what it tends to as gamma_max grows.
  2. Lemma B1.4 / Theorem B3.3(c): C_t >= 1, C_t nondecreasing, C_t <= C_inf, so K <= S_K <= C_inf K.
  3. Theorem B3.3(d) (new): logistic regression (globally beta-smooth, bounded per-example gradients) with a
     non-trivial multiplier matrix M and SGD with replacement: E||Delta||^2_{M^-1} <= V(t) (B1.3), Markov tail
     used in (d1), and the convexity step of (d2) (KL of a Gaussian mixture <= mean KL) by quadrature.
  4. Theorem B2.4 (changed): the zero-function term: sqrt(a^2+b) <= a + min(sqrt b, b/2a) and
     (12/n) int_alpha^sqrt(n) [sqrt(rho^2/e^2 + ln2) - rho/e] de <= min(12 sqrt(ln2/n), 3 ln2/rho).
  5. Section 5.3 numbers recomputed from the sgd_short_*.json records: rigorous flags, flow KL with c_K,
     kl^-1 chains, ratio KL(b)/KL(a) at the same sigma, ||Delta|| <= sqrt(t L0), overshoot factors, block
     displacements at step 300, which time-based values are < 0.5 and where.
  6. Constants: lambda_sigma, t <= eps n / 200, (d) thresholds, Section 3 n-thresholds with and without q.
  7. Proposition B3.4: slack values, and a coverage simulation with adaptively changing error rates.

usage: OPENBLAS_NUM_THREADS=1 python3 referee_B_r2.py > referee_B_r2.out
"""
import os, sys, json, math
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import numpy as np
from scipy import integrate
import nnbounds as nb

rng = np.random.default_rng(20261023)
KP = nb.KAPPA_PATH(31)

# ------------------------------------------------------------------------------------------------ 1
print("== 1. Lemma B2.1a brute force ==")
viol, tested, edge_ok, edge_tot = 0, 0, 0, 0
lim_gap = []
for trial in range(400):
    n = int(rng.choice([64, 256, 2048, 16384]))
    kind = trial % 4
    if kind == 0:
        m = rng.normal(1.0, 0.1, n)
    elif kind == 1:
        m = rng.uniform(-1, 3, n)
    elif kind == 2:
        m = rng.exponential(1.0, n) * rng.choice([1, -1], n, p=[0.9, 0.1])
    else:
        m = np.full(n, rng.uniform(0.1, 3.0))
    mplus = np.maximum(m, 0).mean()
    target = max(1.0, mplus) * rng.uniform(1.0, 2.0)
    C = target * math.sqrt(n) / (2 * KP)          # grid rounding only increases c
    j = nb.grid_index(C, 1.0, 1.1); c = 2 * KP * 1.1 ** j / math.sqrt(n)
    assert c >= max(1.0, mplus) - 1e-12
    for gmax in [0.5, 4.0, 1000.0, 1e6]:
        kmax = int(math.log(gmax / 1e-3) / math.log(1.1)) + 2
        b = nb.margin_bound(m, C, KP, gmax=gmax, kmax=kmax)
        tested += 1
        viol += b[0] < 1 - 1e-12
        if gmax >= m.max():
            edge_tot += 1; edge_ok += abs(b[1] - gmax) < 1e-9
        if gmax == 1e6:
            jj = j
            conf0 = math.sqrt(math.log((jj + 1) * (jj + 2) * 2 / 0.05) / (2 * n))
            lim_gap.append((b[0] - 1, conf0))
print(f"   {tested} (margins, c, gamma_max) instances with c >= max(1, mean(yf)_+): bound < 1 in {viol}")
print(f"   minimum at the grid edge gamma = gamma_max whenever gamma_max >= max margin: {edge_ok} of {edge_tot}")
g = np.array(lim_gap)
print(f"   gamma_max = 1e6: bound - 1 ranges {g[:,0].min():.4f}-{g[:,0].max():.4f}; the k=0 confidence term ranges "
      f"{g[:,1].min():.4f}-{g[:,1].max():.4f}  (so the limit is 1 + conf, not 1)")
# necessity of c >= mean(yf)_+ : all margins 5, c = 2
m = np.full(16384, 5.0); C = 2.0 * 128 / (2 * KP)
print(f"   necessity: margins all 5, c ~ 2 (>= 1 but < mean margin): bound = {nb.margin_bound(m, C, KP, gmax=8.0)[0]:.3f} < 1")

# ------------------------------------------------------------------------------------------------ 2
print("\n== 2. Lemma B1.4: C_t >= 1, monotone, <= C_inf ==")
def Ct(t, b1, b2):
    r = b1 ** 2 / b2
    return (1 - b1) / (1 - b1 ** t) * math.sqrt((1 - b2 ** t) / (1 - b2)) * math.sqrt((1 - r ** t) / (1 - r))
for b1, b2 in [(0.9, 0.999), (0.9, 0.99), (0.5, 0.9), (0.0, 0.999), (0.95, 0.9999)]:
    if b1 ** 2 / b2 >= 1:
        continue
    T = np.arange(1, 100001)
    C = np.array([Ct(int(t), b1, b2) for t in T])
    Cinf = (1 - b1) / math.sqrt((1 - b2) * (1 - b1 ** 2 / b2))
    print(f"   beta=({b1},{b2}): min C_t {C.min():.6f}; nondecreasing: {bool(np.all(np.diff(C) >= -1e-12))};"
          f" max C_t {C.max():.4f} <= C_inf {Cinf:.4f}: {bool(C.max() <= Cinf + 1e-12)}")
# brute force: random gradient sequences never exceed C_t (and constant sequences give exactly 1)
b1, b2 = 0.9, 0.999
worst = 0.0
for _ in range(300):
    T = int(rng.integers(1, 200))
    gs = rng.standard_normal(T) * np.exp(rng.uniform(0, 0.1) * np.arange(T))
    m = v = 0.0
    for t, gv in enumerate(gs, 1):
        m = b1 * m + (1 - b1) * gv; v = b2 * v + (1 - b2) * gv ** 2
        worst = max(worst, abs(m / (1 - b1 ** t)) / math.sqrt(v / (1 - b2 ** t)) / Ct(t, b1, b2))
print(f"   random growing sequences: max ratio / C_t = {worst:.4f} (<= 1)")

# ------------------------------------------------------------------------------------------------ 3
print("\n== 3. Theorem B3.3(d) on logistic regression (smooth, bounded per-example gradients) ==")
n, d, B = 400, 12, 8
X = rng.standard_normal((n, d)) * np.linspace(0.3, 2.0, d)
wstar = rng.standard_normal(d)
y = np.where(X @ wstar + 0.5 * rng.standard_normal(n) > 0, 1.0, -1.0)
mvec = np.concatenate([np.full(4, 2.0), np.full(4, 1.0), np.full(4, 0.5)])     # three groups, multipliers 2, 1, 1/2
H = X.T @ X / (4 * n)                                                         # Hessian bound of logistic loss
Mh = np.sqrt(mvec)
beta = float(np.linalg.eigvalsh(Mh[:, None] * H * Mh[None, :]).max())         # smoothness in the M-geometry
nu2 = float(np.mean(np.sum(X ** 2 * mvec, 1)))                                 # >= sup_theta mean ||grad l_i - grad L||_M^2
eta = 1.0 / beta
def L(th):
    return float(np.mean(np.logaddexp(0, -y * (X @ th))))
th0 = np.zeros(d); L0 = L(th0)
R = 4000
for K in [10, 50, 200, 1000]:
    th = np.zeros((R, d))
    for k in range(K):
        idx = rng.integers(0, n, size=(R, B))
        Xb, yb = X[idx], y[idx]                                                   # (R, B, d)
        z = yb * np.einsum("rbd,rd->rb", Xb, th)
        s = 1 / (1 + np.exp(z))
        gr = -np.einsum("rb,rbd->rd", yb * s, Xb) / B
        th = th - eta * mvec * gr
    D2 = np.sum(th ** 2 / mvec, 1)
    t = eta * K
    V = 4 * t * L0 + 2 * eta * t * nu2 * (1 + beta * t) / B
    print(f"   K={K:5d} t={t:8.2f}: E||D||^2_M^-1 = {D2.mean():9.3f} <= V(t) = {V:10.2f}: {bool(D2.mean() <= V)};"
          f"  P[||D||^2 > V/0.1] = {np.mean(D2 > V / 0.1):.4f} (<= 0.1)  drift-only part 4tL0 = {4 * t * L0:.2f}")
# (d2) convexity: KL(mixture of N(mu_j, s^2) || N(0, s^2)) <= mean_j mu_j^2 / 2 s^2, 1-d quadrature
for trial in range(5):
    mus = rng.normal(0, 2, size=int(rng.integers(2, 6))); s = rng.uniform(0.3, 2)
    q = lambda x: np.mean(np.exp(-(x - mus) ** 2 / (2 * s ** 2))) / math.sqrt(2 * math.pi * s * s)
    p = lambda x: math.exp(-x * x / (2 * s * s)) / math.sqrt(2 * math.pi * s * s)
    lo, hi = mus.min() - 12 * s, mus.max() + 12 * s
    kl = integrate.quad(lambda x: q(x) * math.log(max(q(x), 1e-300) / max(p(x), 1e-300)), lo, hi, limit=200)[0]
    print(f"   mixture KL {kl:.4f} <= mean KL {np.mean(mus ** 2) / (2 * s * s):.4f}: {kl <= np.mean(mus ** 2) / (2 * s * s) + 1e-9}")

# ------------------------------------------------------------------------------------------------ 4
print("\n== 4. Theorem B2.4: cost of adding the zero function ==")
a = np.exp(rng.uniform(-6, 6, 100000)); bb = np.exp(rng.uniform(-6, 6, 100000))
print("   sqrt(a^2+b) <= a + min(sqrt b, b/2a) on 1e5 random pairs:",
      bool(np.all(np.sqrt(a ** 2 + bb) <= a + np.minimum(np.sqrt(bb), bb / (2 * a)) + 1e-9 * (a + 1))))
worst = 0.0
for _ in range(300):
    n_ = float(rng.choice([256, 2048, 16384])); rho = math.exp(rng.uniform(-3, math.log(n_ / 3)))
    al = math.exp(rng.uniform(math.log(1e-4), math.log(math.sqrt(n_))))
    extra = 12 / n_ * integrate.quad(lambda e: math.sqrt(rho ** 2 / e ** 2 + math.log(2)) - rho / e, al, math.sqrt(n_), limit=200)[0]
    cap = min(12 * math.sqrt(math.log(2) / n_), 3 * math.log(2) / rho)
    worst = max(worst, extra / cap)
print(f"   max over 300 random (n, rho, alpha) of extra / min(12 sqrt(ln2/n), 3 ln2/rho) = {worst:.4f} (<= 1)")

# ------------------------------------------------------------------------------------------------ 5
print("\n== 5. Section 5.3 recomputed from the trajectory records ==")
G = len(nb.SIG_GRID) ** 3
files = ["sgd_short_maj3_2048_sgd.json", "sgd_short_maj3_2048_gd.json", "sgd_short_maj3_2048_gd_eta0.02.json",
         "sgd_short_dict_16384_sgd.json", "sgd_short_maj3_16384_sgd.json", "sgd_short_dict_16384_adam.json",
         "sgd_short_maj3_16384_adam.json"]
ratios, below_half, maxdev = [], [], 0.0
over = dict(sqrt_tL0=0.0, path_len=0.0, sqrt_tE=0.0)
viol_flow = []
for f in files:
    S = json.load(open(os.path.join(HERE, f)))
    n, L0, mode, eta = S["n"], S["L0"], S["mode"], S["eta"]
    mg = np.array([1.0, 0.5, 0.5]) if mode == "adam" else np.array([2.0, 1.0, 0.5])
    for r in S["records"]:
        if r["step"] > 0 and mode != "adam":
            if r["dist_M"] > r["sqrt_tL0"]:
                viol_flow.append((f, r["step"]))
            for k in over:
                over[k] = max(over[k], r[k] / r["dist_M"])
        if "pb_KL" not in r:
            continue
        sig = np.array(r["pb_sig"]); lam = float((mg / (2 * sig ** 2)).max()); t = r["t"]
        pairs = [("adam", None)] if mode == "adam" else [("energy", None), ("flow", None)]
        for name, _ in pairs:
            KL = r[f"pb_KL_{name}"]
            RQ = nb.kl_inv_upper(r["pb_gibbs_up"], (KL + math.log(2 * math.sqrt(n) * G / 0.03)) / n)
            maxdev = max(maxdev, abs(RQ - r[f"pb_RQ_{name}"]))
            rig = (name == "energy") or (name == "adam") or (name == "flow" and r["flow_rigorous"])
            if RQ < 0.5 and rig:
                below_half.append((f.replace("sgd_short_", "").replace(".json", ""), name, r["step"], round(t, 2), round(RQ, 3)))
        if mode != "adam":
            KLf = t * L0 * lam / r["desc_c_used"]
            maxdev = max(maxdev, abs(KLf - r["pb_KL_flow"]) / KLf)
            if mode == "sgd":
                ratios.append(r["pb_KL_energy"] / r["pb_KL_flow"])
            # rigorous flag: GD and (D) held at every step so far
            exp_rig = (mode == "gd") and (r["desc_min"] > 0)
            if exp_rig != r["flow_rigorous"]:
                print("   FLAG MISMATCH", f, r["step"])
        else:
            pg = np.array([3968, 16512, 128])
            KLa = float((pg * (eta * mg * r["S_K"]) ** 2 / (2 * sig ** 2)).sum())
            maxdev = max(maxdev, abs(KLa - r["pb_KL_adam"]) / KLa)
print(f"   kl^-1 chains and KL formulas reproduce the JSON (max deviation {maxdev:.2e})")
print(f"   SGD checkpoints: KL(b)/KL(a) at the same sigma ranges {min(ratios):.1f}-{max(ratios):.1f}"
      f" over {len(ratios)} checkpoints  (text: '7-35 times')")
print(f"   ||Delta||_M^-1 > sqrt(t L0) at: {viol_flow if viol_flow else 'no record'}")
print("   largest overshoot over SGD/GD records: " + ", ".join(f"{k}/||Delta|| = {v:.1f}" for k, v in over.items()))
print("   rigorous time-based values below 0.5 (run, part, step, t, R(Q)):")
for x in below_half:
    print("      ", x)
for fn in ["dict"]:
    a_ = [r for r in json.load(open(os.path.join(HERE, f"sgd_short_{fn}_16384_sgd.json")))["records"] if r["step"] == 300][0]
    b_ = [r for r in json.load(open(os.path.join(HERE, f"sgd_short_{fn}_16384_adam.json")))["records"] if r["step"] == 300][0]
    print(f"   x1 step 300 block displacements (W1,b1 / W2,b2 / a): SGD {np.round(a_['dist_groups'], 2)}  Adam {np.round(b_['dist_groups'], 2)}")
S = json.load(open(os.path.join(HERE, "sgd_short_maj3_2048_gd_eta0.02.json")))
last = S["records"][-1]
print(f"   GD eta=0.02 run ends at step {last['step']} (t = {last['t']}): flow R(Q) {last['pb_RQ_flow']:.3f}, energy R(Q) {last['pb_RQ_energy']:.3f}"
      f"  -> non-vacuous at the last evaluated time; nothing measured beyond t = {last['t']}")
S = json.load(open(os.path.join(HERE, "sgd_short_maj3_2048_gd.json")))
r20 = [r for r in S["records"] if r["step"] == 20][0]
print(f"   GD eta=0.2 step 20: c_K = {r20['desc_c_used']:.4f}, rigorous = {r20['flow_rigorous']}, flow KL {r20['pb_KL_flow']:.0f}, R(Q) {r20['pb_RQ_flow']:.3f}")

# ------------------------------------------------------------------------------------------------ 6
print("\n== 6. Constants ==")
sig = np.array([0.14, 0.2, 0.025]); mg = np.array([2.0, 1.0, 0.5])
lam = float((mg / (2 * sig ** 2)).max()); print(f"   lambda_sigma = {lam:.1f} (set by group {int(np.argmax(mg / (2 * sig ** 2))) + 1})")
eps, L0 = 1.0, 0.5
print(f"   t <= eps n c / (L0 lambda) = eps n / {L0 * lam:.0f}; steps per 1000 samples: eta=0.2 -> {1000 / (L0 * lam) / 0.2:.1f} eps,"
      f" eta=0.02 -> {1000 / (L0 * lam) / 0.02:.1f} eps")
for nn in [16384]:
    print(f"   KL <= 0.1 n at n={nn}: (a) t <= {0.1 * nn / (lam * L0):.2f}; (d2) t <= {0.1 * nn / (4 * lam * L0):.3f};"
          f" (d1, delta'=0.01) t <= {0.1 * nn * 0.01 / (4 * lam * L0):.4f}")
KF = nb.KAPPA_FROB(31)
for name, kap, phi in [("path", KP, 31.5), ("Frobenius", KF, 11.3)]:
    print(f"   Section 3, {name}: c >= 1 guaranteed for n <= (2 kappa phi)^2 = {(2 * kap * phi) ** 2:.3g};"
          f" text uses (2 q kappa phi)^2 = {(2 * 1.1 * kap * phi) ** 2:.3g}")

# ------------------------------------------------------------------------------------------------ 7
print("\n== 7. Proposition B3.4 ==")
for dl, lab in [(0.05, "one window"), (0.05 / 3, "three windows")]:
    print(f"   slack sqrt(ln(1/delta)/(2 K' B)), K'=1000, B=64, {lab}: {math.sqrt(math.log(1 / dl) / (2 * 1000 * 64)):.5f}")
# coverage: error rate R_k adapts to past mistakes (a learner whose rate drops after each mistake)
sims, Kp, Bb, dl = 4000, 200, 16, 0.05
slack = math.sqrt(math.log(1 / dl) / (2 * Kp * Bb))
fails = 0
for s_ in range(sims):
    Rk, sumR, sume = 0.5, 0.0, 0.0
    for k in range(Kp):
        e = rng.binomial(Bb, Rk) / Bb
        sumR += Rk; sume += e
        Rk = max(0.0, Rk - 0.02 * e) if e > 0.3 else min(0.5, Rk + 0.001)
    fails += (sumR - sume) / Kp > slack
print(f"   adaptive-rate simulation ({sims} runs, K'={Kp}, B={Bb}): Pr[mean R - mean e > slack] = {fails / sims:.4f} (<= {dl})")

# ------------------------------------------------------------------------------------------------ 8
print("\n== 8. Small numeric details ==")
for f in ["sgd_short_maj3_2048_sgd.json", "sgd_short_maj3_2048_gd_eta0.02.json"]:
    S = json.load(open(os.path.join(HERE, f)))
    r = max([r for r in S["records"] if r["step"] > 0], key=lambda r: r["sqrt_tL0"] / r["dist_M"])
    print(f"   {f}: largest sqrt(t L0)/||Delta|| = {r['sqrt_tL0'] / r['dist_M']:.2f} at step {r['step']}  (Section 6 says 'up to 6')")
g = np.float32(0.37)
m_, v_ = np.float32(0.1) * g, np.float32(0.001) * g * g
c1, c2 = np.float32(1) - np.float32(0.9), np.float32(1) - np.float32(0.999)
print(f"   first Adam step in float32, eps = 0: |mhat|/sqrt(vhat) = {float((m_ / c1) / np.sqrt(v_ / c2)):.7f}"
      "  (the 0.999994 of Section 5.3 is float32 rounding of the bias corrections, not eps)")

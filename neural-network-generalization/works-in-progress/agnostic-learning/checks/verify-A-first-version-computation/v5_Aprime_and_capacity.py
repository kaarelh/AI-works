"""Checks for A.md Sections 3, 7, 8.
(a) Lemma 7.1(d): |E[g y | p]| <= Lambda r/4 is attained by g = Lambda |x_1| (so the pairing bound is sharp), and
    random width-m networks with |weights|<=B satisfy L_{D'}(g) >= 1 - Lambda_prod r/2 >= 1 - (r/2) B^L m^H sqrt(d).
(b) Theorem 7.2 Step 4 algebra on random admissible numbers: Delta(zeta) <= 2 E sqrt(W) + E^2.
(c) Lemma 3.1 and Lemma 8.1 step 5 on random networks: |z| <= ||v||_1 <= sqrt(kappa); path norm
    P = |v|^T|W^H|...|W^2| 1 <= (kappa/H)^{H/2}; Lipschitz (sampled gradients) <= sqrt(prod kappa_l/d) <= (kappa/L)^{L/2}/sqrt d.
(d) Consistency of Lemma 2.1 with Proposition 8.2(a): K_mem(d,s,a,H) >= H((1-a)sqrt(s)/D_{d,H})^{2/H} on a large grid
    (a violation would mean one of the two lemmas is false); same for H=1 with the Remark 2.5 energy.
(e) Lemma 8.1 step 2: Rad(Clip G) <= Rad(G) + 1/(2 sqrt m) on random finite G (exact expectation over all sign vectors, m<=14).
(f) Lemma 8.1 step 1: number of halfspace dichotomies of C_d (d=2,3) vs (M+1)^{d+1} and 2^{(d+1)^2}.
"""
import itertools, math
import numpy as np
from scipy.optimize import linprog

rng = np.random.default_rng(2026)

# ------------------------------------------------------------ (a)
print("(a) Lemma 7.1(d)")
def risk_Dprime(g, d, r, nmc=200000):
    # x = p*(1 - r*ups), y = +1 iff ups_1 < 1/2 ; returns L_{D'}(g) and max_p |E[g y | p]|
    M = 2 ** d; P = np.array(list(itertools.product([-1.0, 1.0], repeat=d)))
    tot = 0.0; corr = 0.0
    for p in P:
        ups = rng.uniform(size=(nmc, d))
        x = p * (1 - r * ups); y = np.where(ups[:, 0] < 0.5, 1.0, -1.0)
        gx = g(x)
        tot += np.mean((gx - y) ** 2) / M
        corr = max(corr, abs(np.mean(gx * y)))
    return tot, corr
d = 3; r = 0.05; Lam = 4.0
L, corr = risk_Dprime(lambda x: Lam * np.abs(x[:, 0]), d, r)
print(f"  g=Lam|x1|, Lam={Lam}, r={r}: max_p|E[gy|p]|={corr:.5f} vs Lam r/4={Lam*r/4:.5f} (equality expected)")
worst = 1e9
for trial in range(30):
    H = int(rng.integers(1, 4)); Lh = H + 1; m = int(rng.integers(1, 5)); B = float(rng.uniform(0.3, 1.5))
    W1 = rng.uniform(-B, B, size=(m, d + 1)); mids = [rng.uniform(-B, B, size=(m, m)) for _ in range(H - 1)]
    v = rng.uniform(-B, B, size=m)
    def net(x):
        h = np.tanh(np.hstack([np.ones((len(x), 1)), x]) @ W1.T)
        for Wl in mids:
            h = np.tanh(h @ Wl.T)
        return h @ v
    Lam_prod = np.linalg.norm(v) * np.linalg.norm(W1[:, 1:]) * np.prod([np.linalg.norm(Wl) for Wl in mids])
    Lam_crude = B ** Lh * m ** H * math.sqrt(d)
    rr = 0.2
    Lr, _ = risk_Dprime(net, d, rr, nmc=40000)
    lb1 = 1 - Lam_prod * rr / 2; lb2 = 1 - Lam_crude * rr / 2
    worst = min(worst, Lr - lb1)
    assert Lam_prod <= Lam_crude + 1e-12
print(f"  random nets (30): min over nets of L_D'(g) - (1 - Lam_prod r/2) = {worst:.4f} (>= -MC error expected)")

# ------------------------------------------------------------ (b)
print("(b) Theorem 7.2 Step 4 algebra")
bad = 0
for _ in range(200000):
    n = int(rng.integers(1, 10 ** 6)); c = 10 ** rng.uniform(-2, 3); K = 10 ** rng.uniform(0, 6); t = rng.uniform(0, 2)
    a = rng.uniform(0, 1); W = rng.uniform(0, n)
    R0 = (math.sqrt(W) + (a + 1 / n) * math.sqrt(n)) ** 2 * rng.uniform(0, 1)       # comparator residual (worst case)
    Rw = (c * (K + t) + R0) * rng.uniform(0, 1)                                      # near-minimizer residual
    lhs_sqrt = (math.sqrt(Rw) + math.sqrt(n) / n) * rng.uniform(0, 1)                # sqrt(Delta+W) <= this
    if lhs_sqrt ** 2 < W:
        continue
    Delta = lhs_sqrt ** 2 - W
    E = math.sqrt(c * (K + t)) + (a + 2 / n) * math.sqrt(n)
    if Delta > 2 * E * math.sqrt(W) + E ** 2 * (1 + 1e-12) + 1e-9:
        bad += 1
print("  violations:", bad)

# ------------------------------------------------------------ (c)
print("(c) output, path-norm and Lipschitz bounds on random networks")
w_out = w_path = w_lip = 0.0
for trial in range(300):
    H = int(rng.integers(1, 5)); Lh = H + 1; N = int(rng.integers(1, 40)); dd = int(rng.integers(1, 6))
    sc = 10 ** rng.uniform(-1.5, 1)
    W1 = rng.normal(size=(N, dd + 1)) * sc; mids = [rng.normal(size=(N, N)) * sc / math.sqrt(N) for _ in range(H - 1)]
    v = rng.normal(size=N) * sc / N
    parts = [(dd / N) * np.sum(W1 ** 2)] + [np.sum(Wl ** 2) for Wl in mids] + [N * np.sum(v ** 2)]
    kap = sum(parts)
    Pn = np.abs(v)
    for Wl in reversed(mids):
        Pn = Pn @ np.abs(Wl)
    Pn = float(Pn.sum())
    w_path = max(w_path, Pn / (kap / H) ** (H / 2))
    xs = rng.uniform(-1, 1, size=(400, dd))
    h = np.tanh(np.hstack([np.ones((400, 1)), xs]) @ W1.T); Js = []
    J = (1 - h ** 2)[:, :, None] * W1[None, :, 1:]
    for Wl in mids:
        h = np.tanh(h @ Wl.T)
        J = (1 - h ** 2)[:, :, None] * np.einsum("ij,bjk->bik", Wl, J)
    z = h @ v
    grad = np.einsum("i,bik->bk", v, J)
    w_out = max(w_out, float(np.max(np.abs(z))) / min(np.abs(v).sum(), math.sqrt(kap)) if np.abs(v).sum() > 0 else 0)
    lipb = math.sqrt(np.prod(parts) / dd); amgm = (kap / Lh) ** (Lh / 2) / math.sqrt(dd)
    assert lipb <= amgm * (1 + 1e-12)
    w_lip = max(w_lip, float(np.max(np.linalg.norm(grad, axis=1))) / lipb)
    assert np.abs(v).sum() <= math.sqrt(kap) * (1 + 1e-12)
print(f"  max |z|/min(||v||_1,sqrt kappa)={w_out:.4f}  max P/(kappa/H)^(H/2)={w_path:.4f}  max |grad|/sqrt(prod kappa_l/d)={w_lip:.4f}  (all <= 1)")

# ------------------------------------------------------------ (d)
print("(d) Lemma 2.1 vs Proposition 8.2(a) consistency")
def alpha_d(d): return 0.5 * math.log(4 * math.sqrt(2 * d))
def D(d, H): return math.sqrt(2 * math.log(2)) * (d + 1) + (H - 1) / 2
minratio = (1e300, None)
for H in range(1, 13):
    for d in list(range(1, 41)) + [50, 64, 80, 100, 150, 200]:
        for e in np.linspace(0, d, 41):
            s = 2 ** e
            for a in [1e-6, 1e-3, 0.1, 0.5, 0.9, 0.999]:
                if H >= 2:
                    Kup = d * (d + 1) * alpha_d(d) ** 2 + (H + 1) * max((8 * d * s) ** (1 / H), 9 / (2 * a))
                else:
                    Kup = d * (d + 1) * alpha_d(d) ** 2 + 16 * d * s       # Remark 2.5 (depth two)
                Klow = H * ((1 - a) * math.sqrt(s) / D(d, H)) ** (2 / H)
                if Kup / Klow < minratio[0]:
                    minratio = (Kup / Klow, (H, d, s, a))
print(f"  min K_mem/K_low over grid = {minratio[0]:.3f} at (H,d,s,a)={minratio[1]}  (must be >= 1)")

# ------------------------------------------------------------ (e)
print("(e) clip contraction  Rad(Clip G) <= Rad(G) + 1/(2 sqrt m)")
def clip(u, tau): return (np.abs(u + tau) - np.abs(u - tau)) / 2
worst = -1e9
for trial in range(40):
    m = int(rng.integers(2, 13)); G = rng.uniform(-1, 1, size=(int(rng.integers(1, 30)), m))
    taus = np.linspace(0, 1, 101)
    CG = np.concatenate([clip(G, tt) for tt in taus], axis=0)
    eps = np.array(list(itertools.product([-1.0, 1.0], repeat=m)))
    radG = np.mean(np.max(eps @ G.T, axis=1)) / m
    radC = np.mean(np.max(eps @ CG.T, axis=1)) / m
    worst = max(worst, radC - radG - 1 / (2 * math.sqrt(m)))
print(f"  max [Rad(Clip G) - Rad(G) - 1/(2 sqrt m)] = {worst:.4f}  (must be <= 0)")

# ------------------------------------------------------------ (f)
print("(f) halfspace dichotomies of the cube")
for d in [2, 3, 4]:
    C = np.array(list(itertools.product([-1.0, 1.0], repeat=d))); M = len(C)
    cnt = 0
    for lab in itertools.product([-1.0, 1.0], repeat=M):
        lab = np.array(lab)
        # feasibility of lab_i (w.x_i + b) >= 1
        A_ub = -lab[:, None] * np.hstack([C, np.ones((M, 1))]); b_ub = -np.ones(M)
        res = linprog(np.zeros(d + 1), A_ub=A_ub, b_ub=b_ub, bounds=[(None, None)] * (d + 1), method="highs")
        cnt += res.status == 0
    print(f"  d={d}: J={cnt}  (M+1)^(d+1)={(M+1)**(d+1)}  log J={math.log(cnt):.3f} <= (d+1)^2 log 2={(d+1)**2*math.log(2):.3f}")

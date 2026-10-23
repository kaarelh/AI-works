"""Bound calculators for B-nn-time-bounds.md (numpy only).

Network: f(x) = a . relu(W2 relu(W1 x + b1) + b2), x in {-1,1}^d.  Parameters are dicts with keys
W1 (N,d), b1 (N,), W2 (N,N), b2 (N,), a (N,).  All bounds are for the 0-1 test error
Pr[y f(x) <= 0] and hold with probability >= 1 - delta over the training sample.
Section numbers refer to B-nn-time-bounds.md.
"""
import numpy as np

# ----------------------------------------------------------------------------- network

def relu(z):
    return np.maximum(z, 0.0)

def forward(p, X):
    h1 = relu(X @ p["W1"].T + p["b1"])
    h2 = relu(h1 @ p["W2"].T + p["b2"])
    return h2 @ p["a"]

def path_norm(p):
    """l1 path norm with biases (Prop. B2.2): sum over input-to-output paths, a bias counts as an input 1."""
    r1 = np.abs(p["W1"]).sum(1) + np.abs(p["b1"])
    return float(np.abs(p["a"]) @ (np.abs(p["W2"]) @ r1 + np.abs(p["b2"])))

def frob_complexity(p):
    """P_F = ||a|| (||[W1 b1]||_F ||W2||_F + ||b2||)  (Prop. B2.3 after optimizing the constant unit)."""
    A = np.sqrt((p["W1"] ** 2).sum() + (p["b1"] ** 2).sum())
    return float(np.linalg.norm(p["a"]) * (A * np.linalg.norm(p["W2"]) + np.linalg.norm(p["b2"])))

def augmented(p, c=1.0):
    """Bias-free 3-layer representation on xhat = (x, 1): hat W1 = [[W1 b1],[0 c]], hat W2 = [W2, b2/c], a."""
    N, d = p["W1"].shape
    A1 = np.zeros((N + 1, d + 1)); A1[:N, :d] = p["W1"]; A1[:N, d] = p["b1"]; A1[N, d] = c
    A2 = np.concatenate([p["W2"], (p["b2"] / c)[:, None]], 1)
    A3 = p["a"][None, :]
    return [A1, A2, A3]

def spectral_quantities(p, p0=None, c=1.0):
    """s_i = ||A_i||_2 and b_i = ||(A_i - M_i)^T||_{2,1} = sum of row l2 norms of A_i - M_i (BFT)."""
    A = augmented(p, c)
    M = augmented(p0, c) if p0 is not None else [np.zeros_like(x) for x in A]
    s = [np.linalg.norm(x, 2) for x in A]
    b = [np.linalg.norm(x - m, axis=1).sum() for x, m in zip(A, M)]
    return np.array(s), np.array(b)

# ----------------------------------------------------------------------------- generic tools

def kl_bern(q, p):
    q = np.clip(q, 1e-12, 1 - 1e-12); p = np.clip(p, 1e-12, 1 - 1e-12)
    return q * np.log(q / p) + (1 - q) * np.log((1 - q) / (1 - p))

def kl_inv_upper(q, c):
    """sup{p in [q,1] : kl(q||p) <= c}."""
    if c <= 0:
        return q
    lo, hi = q, 1.0
    for _ in range(100):
        mid = (lo + hi) / 2
        if kl_bern(q, mid) > c:
            hi = mid
        else:
            lo = mid
    return hi

def grid_index(value, base, q):
    """smallest j >= 0 with base*q^j >= value."""
    if value <= base:
        return 0
    return int(np.ceil(np.log(value / base) / np.log(q) - 1e-12))

def ramp(u, gamma):
    return np.clip(1 - u / gamma, 0, 1)

# ----------------------------------------------------------------------------- Theorem B2.1 (margin bound)

KAPPA_PATH = lambda D, L=3: np.sqrt(2 * np.log(2 ** L * D))           # Prop. B2.2, inputs in [-1,1]^D incl. constant
KAPPA_FROB = lambda D, L=3: np.sqrt(D) * (1 + np.sqrt(2 * (L - 1) * np.log(2)))  # Prop. B2.3, ||xhat||^2 = D
KAPPA_GRS = lambda D, L=3: np.sqrt(D) * (1 + np.sqrt(2 * L * np.log(2)))         # GRS Thm 1 constant (Literature)

def margin_bound(margins, complexity, kappa, delta=0.05, q=1.1, phi0=1.0, gmax=4.0, kmax=120):
    """Theorem B2.1: min over grid margins gamma_k = gmax q^-k of
         ramp_gamma(train) + 2 kappa phi_j / (gamma sqrt n) + sqrt(ln(1/delta_jk)/(2n)),
       phi_j = phi0 q^j the grid value just above `complexity`, delta_jk = delta/((j+1)(j+2)(k+1)(k+2)).
       Returns (bound, gamma, train_ramp, complexity_term, confidence_term)."""
    n = len(margins)
    j = grid_index(complexity, phi0, q); phij = phi0 * q ** j
    best = (np.inf,)
    for k in range(kmax):
        g = gmax * q ** (-k)
        emp = ramp(margins, g).mean()
        comp = 2 * kappa * phij / (g * np.sqrt(n))
        conf = np.sqrt(np.log((j + 1) * (j + 2) * (k + 1) * (k + 2) / delta) / (2 * n))
        b = emp + comp + conf
        if b < best[0]:
            best = (b, g, emp, comp, conf)
    return best

def spectral_bound(margins, Xnorm_F, s, b, W, delta=0.05, q=1.1, base=1e-2, gmax=4.0, kmax=120):
    """Theorem B2.4 (BFT covering number + Dudley + union bound over grids of s_i, b_i, gamma).
       Returns (bound, gamma, emp, rademacher_term, conf)."""
    n = len(margins)
    js = [grid_index(v, base, q) for v in s]; jb = [grid_index(v, base, q) for v in b]
    sg = np.array([base * q ** j for j in js]); bg = np.array([base * q ** j for j in jb])
    RA = np.prod(sg) * (np.sum((bg / sg) ** (2 / 3))) ** 1.5
    logw = sum(np.log((j + 1) * (j + 2)) for j in js + jb)
    best = (np.inf,)
    for k in range(kmax):
        g = gmax * q ** (-k)
        emp = ramp(margins, g).mean()
        rho = Xnorm_F * np.sqrt(np.log(2 * W ** 2)) * RA / g
        # Dudley applied to (ramp class) U {0} (revision r2: BFT Lemma A.5 assumes 0 in the class); adding 0 costs
        # ln N -> ln N + ln 2, i.e. at most min(12 sqrt(ln2/n), 3 ln2/rho) on Rhat_S.  Never reached on the study's
        # networks, where 3 rho > n always (24 rho / n >= 679).
        rad = ((12 * rho / n) * (1 + np.log(n / (3 * rho))) + min(12 * np.sqrt(np.log(2) / n), 3 * np.log(2) / rho)
               if 3 * rho <= n else 1.0)  # 1.0 = trivial cap
        conf = 3 * np.sqrt((np.log(2 / delta) + logw + np.log((k + 1) * (k + 2))) / (2 * n))
        bd = emp + 2 * rad + conf
        if bd < best[0]:
            best = (bd, g, emp, 2 * rad, conf)
    # uncapped complexity at gamma = 1: 24 rho / n (the leading term of 2 * rad); >= 1 means vacuous
    return best + (24 * Xnorm_F * np.sqrt(np.log(2 * W ** 2)) * RA / n,)

# ----------------------------------------------------------------------------- PAC-Bayes (Theorem B3.2)

GROUPS = [("W1", "b1"), ("W2", "b2"), ("a",)]

def group_sq_dist(p, p0):
    return np.array([sum(((p[k] - p0[k]) ** 2).sum() for k in g) for g in GROUPS])

def perturb(p, sig, rng):
    out = {}
    for gi, g in enumerate(GROUPS):
        for k in g:
            out[k] = p[k] + (sig[gi] * rng.standard_normal(p[k].shape)).astype(p[k].dtype)
    return out

def gibbs_error(p, sig, X, y, rng, draws=64, sub=512):
    """Monte-Carlo estimate of E_{theta'~Q} err_S(theta'); each draw on an independent random subset."""
    errs = []
    for _ in range(draws):
        q = perturb(p, sig, rng)
        idx = rng.integers(0, len(X), size=min(sub, len(X)))
        errs.append(np.mean(y[idx] * forward(q, X[idx]) <= 0))
    return float(np.mean(errs))

def disagreement(p, sig, d, rng, draws=64, sub=512):
    """Monte-Carlo estimate of Pr_{x~U, theta'~Q}[sign f_theta'(x) != sign f_theta(x)] on fresh uniform x."""
    errs = []
    for _ in range(draws):
        q = perturb(p, sig, rng)
        X = rng.choice(np.array([-1.0, 1.0]), size=(sub, d))
        errs.append(np.mean(np.sign(forward(q, X)) != np.sign(forward(p, X))))
    return float(np.mean(errs))

SIG_GRID = 0.4 * 2.0 ** (-np.arange(16) / 2)  # 16 values per group, 0.4 ... 0.0022; 16^3 combinations

def pac_bayes(p, p0, X, y, rng, delta=0.05, sel_draws=24, fin_draws=400, sub=256, tau=0.02, verbose=False):
    """Theorem B3.2 with per-group isotropic Gaussians Q = N(theta, sig_g^2 I), prior P = N(theta0, sig_g^2 I).
       sig is chosen by a data-dependent search over the 16^3 grid (allowed: the PAC-Bayes bound is
       union-bounded over the whole grid); the final Monte-Carlo estimates use fresh draws.
       delta split: 0.6 PAC-Bayes, 0.2 Gibbs-train Monte Carlo, 0.2 disagreement Monte Carlo."""
    n, d = X.shape
    sq = group_sq_dist(p, p0)
    ng, K = len(GROUPS), len(SIG_GRID)
    G = K ** ng
    dPB, dMC, dD = 0.6 * delta, 0.2 * delta, 0.2 * delta
    cache = {}
    def predicted(ii):
        ii = tuple(int(min(max(i, 0), K - 1)) for i in ii)
        if ii not in cache:
            sig = SIG_GRID[list(ii)]
            KL = float((sq / (2 * sig ** 2)).sum())
            ge = gibbs_error(p, sig, X, y, rng, draws=sel_draws, sub=sub)
            cache[ii] = (kl_inv_upper(ge, (KL + np.log(2 * np.sqrt(n) * G / dPB)) / n), ge, KL)
        return cache[ii]
    # stage 1: per group, bisection for the largest sigma whose single-group Gibbs train error is
    # <= (unperturbed train error) + tau
    tau = tau + float(np.mean(y * forward(p, X) <= 0))
    idx = []
    for gi in range(ng):
        lo, hi = 0, K - 1        # invariant (assuming monotonicity): answer in [lo, hi]
        while lo < hi:
            mid = (lo + hi) // 2
            sig = np.zeros(ng); sig[gi] = SIG_GRID[mid]
            if gibbs_error(p, sig, X, y, rng, draws=sel_draws, sub=sub) <= tau:
                hi = mid
            else:
                lo = mid + 1
        idx.append(lo)
    # stage 2: joint shift down the grid, then coordinate descent on the predicted bound
    best = min((tuple(i + sh for i in idx) for sh in range(0, 6)), key=lambda ii: predicted(ii)[0])
    for sweep in range(2):
        for gi in range(ng):
            for step in (-1, 1):
                cand = list(best); cand[gi] += step
                cand = tuple(int(min(max(i, 0), K - 1)) for i in cand)
                if predicted(cand)[0] < predicted(best)[0]:
                    best = cand
    best = tuple(int(min(max(i, 0), K - 1)) for i in best)
    if verbose:
        print("   chosen", SIG_GRID[list(best)], predicted(best))
    sig = SIG_GRID[list(best)]
    KL = float((sq / (2 * sig ** 2)).sum())
    ge = gibbs_error(p, sig, X, y, rng, draws=fin_draws, sub=sub)
    ge_up = kl_inv_upper(ge, np.log(1 / dMC) / fin_draws)
    RQ = kl_inv_upper(ge_up, (KL + np.log(2 * np.sqrt(n) * G / dPB)) / n)
    dis = disagreement(p, sig, d, rng, draws=fin_draws, sub=sub)
    dis_up = kl_inv_upper(dis, np.log(1 / dD) / fin_draws)
    return dict(sig=sig, KL=KL, sqdist=sq, gibbs_train=ge, gibbs_train_up=ge_up, RQ=RQ,
                dis=dis, dis_up=dis_up, det=min(1.0, RQ + dis_up))

# ----------------------------------------------------------------------------- self-test: rebalancing

if __name__ == "__main__":
    rng = np.random.default_rng(0)
    N, d = 16, 5
    p = dict(W1=rng.standard_normal((N, d)), b1=rng.standard_normal(N), W2=rng.standard_normal((N, N)),
             b2=rng.standard_normal(N), a=rng.standard_normal(N))
    X = rng.choice([-1.0, 1.0], size=(100, d))
    # rebalanced representation of Prop. B2.2: unit-l1 incoming weights, output weights a'
    V = np.concatenate([p["W1"], p["b1"][:, None]], 1); r = np.abs(V).sum(1)
    Vn = V / r[:, None]
    U = np.concatenate([p["W2"] * r[None, :], p["b2"][:, None]], 1); s = np.abs(U).sum(1)
    Un = U / s[:, None]; ap = p["a"] * s
    Xh = np.concatenate([X, np.ones((len(X), 1))], 1)
    h1 = np.concatenate([relu(Xh @ Vn.T), np.ones((len(X), 1))], 1)
    f2 = relu(h1 @ Un.T) @ ap
    print("rebalanced = original:", np.allclose(f2, forward(p, X)), "  sum|a'| =", np.abs(ap).sum(),
          " path_norm =", path_norm(p))
    # |f(x)| <= path norm on the cube
    Xall = np.array(np.meshgrid(*[[-1, 1]] * d)).reshape(d, -1).T.astype(float)
    print("max |f| on cube", np.abs(forward(p, Xall)).max(), "<= path norm", path_norm(p))
    # P_F identity: inf_c product of augmented Frobenius norms
    A1, A2, A3 = augmented(p, 1.0)
    cs = np.exp(np.linspace(-5, 5, 20001))
    Aw = (p["W1"] ** 2).sum() + (p["b1"] ** 2).sum()
    prod = np.linalg.norm(p["a"]) * np.sqrt((Aw + cs ** 2) * ((p["W2"] ** 2).sum() + (p["b2"] ** 2).sum() / cs ** 2))
    print("inf_c product", prod.min(), " closed form", frob_complexity(p))
    print("kappa_path(31) =", KAPPA_PATH(31), " kappa_frob(31) =", KAPPA_FROB(31), " GRS =", KAPPA_GRS(31))

"""Core of the loop simulation, shared by loop_sim.py (part b) and stepsize_sim.py (part c).

One generation = one training run of n episodes under operator (B), with a grader
built by the previous generation:
    eps_{k+1} = eps_h + q_k * d_eps          (collusion: lenient to gaming)
    a_{k+1}   = a0 * (1 - q_k)               (audit power falls with q_k)
where q_k = posterior mass of generation k on misaligned dispositions (G and C).
Audits are honeypots (h = 1).  Dispositions game on an opportunity-looking,
unrecognised episode iff p_hat = u/(u+v) < t (A: t = 0, G: t = 1, C: t = tC).

Regimes:
    continued : prior of generation k+1 = posterior of generation k
    fresh     : prior of generation k+1 = base prior, then a data channel:
                Bayes on m 'signature' tokens z sampled from generation k's
                predictive; pi_A(z=1) = 1/2 + rho, pi_G(z=1) = 1/2 - rho and
                pi_C(z=1) = 1/2 + rho * c_sig (c_sig = -1: C carries the
                misaligned signature; +1: C mimics A).
"""
import numpy as np
from toy import draw_categories, normalize_log, lam, R, PRED, AUD_UNREC

THR = np.array([0.0, 1.0, 0.3])          # A, G (myopic), C (cautious, default tC = 0.3)
iA, iG, iC = 0, 1, 2


def default_params(**kw):
    p = dict(delta=0.01, s=0.5, a0=0.05, eps_h=0.02, d_eps=0.15, n=20000,
             L_base=4.0, LC_base=-np.inf, m=100, rho=0.1, c_sig=-1.0, tC=0.3, K=30)
    p.update(kw)
    return p


def grader(q, p):
    q = np.clip(q, 0.0, 1.0)
    eps = p["eps_h"] + q * p["d_eps"]
    a = p["a0"] * (1 - q)
    return eps, a


def p_hat_arr(eps, a, s):
    u, v = a * (1 - s), (1 - a) * eps
    return np.where(u + v > 0, u / np.maximum(u + v, 1e-300), 1.0)


def thresholds(p):
    return np.array([0.0, 1.0, p["tC"]])


def loglik_table(q, p):
    """ln P_theta(pass | category) for each seed: shape (S, 3, 6), and the
    category probabilities (S, 6).  Vectorised version of toy.px_table /
    toy.pass_table / toy.cat_probs."""
    q = np.atleast_1d(np.asarray(q, float))
    eps, a = grader(q, p)
    s, d = p["s"], p["delta"]
    ph = p_hat_arr(eps, a, s)
    thr = thresholds(p)[None, :]
    # C_t games iff p_hat < t; the myopic G (t = 1) games on every unrecognised opportunity, even when
    # p_hat = 1 (eps = 0: all opportunities are honeypots).  Fixed in reconciliation: the strict
    # inequality alone made G abstain at eps_h = 0, contrary to its definition (README, T1 section 0).
    g = ((ph[:, None] < thr) | (thr >= 1)).astype(float)            # (S, 3)
    px = np.full((len(q), 3, 6), d)
    px[:, :, PRED] = d + (1 - 2 * d) * g
    px[:, :, AUD_UNREC] = d + (1 - 2 * d) * g
    passp = px * R[:, 1][None, None, :] + (1 - px) * R[:, 0][None, None, :]
    zero = np.zeros_like(q)
    cp = np.stack([(1 - a) * (1 - eps), zero, (1 - a) * eps, zero, a * (1 - s), a * s], axis=1)
    return np.log(passp), cp


def base_logw(p, S):
    lw = np.array([0.0, -p["L_base"], p["LC_base"]], float)
    lw = np.where(np.isfinite(lw), lw, -1e300)
    return np.tile(lw, (S, 1))


def sig_probs(p):
    r = p["rho"]
    return np.array([0.5 + r, 0.5 - r, 0.5 + r * p["c_sig"]])


def misaligned_mass(logw):
    w = normalize_log(logw)
    return w[:, iG] + w[:, iC]


def misaligned_logodds(logw):
    """ln (mu(G) + mu(C)) / mu(A), computed stably."""
    from scipy.special import logsumexp
    return logsumexp(logw[:, [iG, iC]], axis=1) - logw[:, iA]


def data_channel(logw_teacher, p, S, rng, mean=False):
    """Fresh prior for the student: base prior + Bayes on m signature tokens."""
    wt = normalize_log(logw_teacher)
    pz_theta = sig_probs(p)
    pz = wt @ pz_theta                      # teacher's predictive P(z = 1)
    if mean:
        z1 = p["m"] * pz
    else:
        z1 = rng.binomial(p["m"], pz).astype(float)
    lw = base_logw(p, S)
    lw = lw + z1[:, None] * np.log(pz_theta)[None, :] + (p["m"] - z1)[:, None] * np.log(1 - pz_theta)[None, :]
    return lw


def train(logw_prior, q_teacher, p, rng, mode="counts"):
    """One training run of n episodes under (B), grader built by a teacher with
    misaligned mass q_teacher.  mode: 'episodes' draws every episode explicitly,
    'counts' draws the category counts (same distribution), 'mean' uses
    expected counts (the mean map)."""
    S = logw_prior.shape[0]
    ll, cp = loglik_table(q_teacher, p)
    n = p["n"]
    if mode == "mean":
        counts = n * cp
    elif mode == "counts":
        counts = rng.multinomial(n, cp).astype(float)
    else:
        eps, a = grader(np.atleast_1d(q_teacher), p)
        cat = draw_categories(rng, (S, n), eps[:, None], 0.0, a[:, None], 1.0, p["s"])
        counts = np.stack([np.bincount(c, minlength=6) for c in cat]).astype(float)
    return logw_prior + np.einsum("sc,sdc->sd", counts, ll)


def run_loop(q0, p, regime, rng, mode="counts", S=None):
    """Iterate K generations.  q0 = None: 'human start' -- the first generation
    is trained from the base prior with a human-built grader (q = 0) and, in the
    fresh regime, human-written data (an A-only teacher).  Otherwise q0 (scalar
    or per-seed array) is generation 0's misaligned mass, split between G and C
    in the base-prior ratio.  Returns the q trajectory (S, K+1) and final log-weights."""
    if q0 is None:
        S = 1 if S is None else S
        logw = None
        qs = [np.zeros(S)]
        los = [np.full(S, -np.inf)]
    else:
        q0 = np.atleast_1d(np.asarray(q0, float))
        S = len(q0) if S is None else S
        q0 = np.broadcast_to(q0, (S,)).copy()
        base = normalize_log(base_logw(p, 1))[0]
        mis = base[iG] + base[iC]
        fracG = base[iG] / mis if mis > 0 else 1.0
        w0 = np.stack([1 - q0, q0 * fracG, q0 * (1 - fracG)], axis=1)
        with np.errstate(divide="ignore"):
            logw = np.where(w0 > 0, np.log(np.maximum(w0, 1e-320)), -1e300)
        qs = [q0.copy()]
        los = [np.log(q0) - np.log1p(-q0)]
    for k in range(p["K"]):
        if logw is None:                      # human start
            q = np.zeros(S)
            if regime == "continued":
                prior = base_logw(p, S)
            else:
                prior = data_channel(np.tile(np.log([1.0, 1e-300, 1e-300]), (S, 1)), p, S, rng,
                                     mean=(mode == "mean"))
        else:
            q = misaligned_mass(logw)
            prior = logw if regime == "continued" else data_channel(logw, p, S, rng, mean=(mode == "mean"))
        logw = train(prior, q, p, rng, mode=mode)
        logw = logw - logw.max(axis=1, keepdims=True)
        qs.append(misaligned_mass(logw))
        los.append(misaligned_logodds(logw))
    run_loop.last_logodds = np.stack(los, axis=1)
    return np.stack(qs, axis=1), logw


def mean_map_L(L, p, regime="fresh"):
    """Two-type (A, G) mean map on L = ln mu(A)/mu(G).  For 'fresh':
    F(L) = L_base + Xi (1 - 2q) - n D(q).  For 'continued': L - n D(q)."""
    L = np.asarray(L, float)
    q = 1 / (1 + np.exp(np.clip(L, -700, 700)))
    eps, a = grader(q, p)
    u, v = a * (1 - p["s"]), (1 - a) * eps
    D = lam(p["delta"]) * (v - u)                 # myopic G games on every unrecognised opportunity
    rho = p["rho"]
    Xi = p["m"] * 2 * rho * np.log((1 + 2 * rho) / (1 - 2 * rho))
    if regime == "fresh":
        return p["L_base"] + Xi * (1 - 2 * q) - p["n"] * D
    return L - p["n"] * D


def D_of_q(q, p):
    eps, a = grader(np.asarray(q, float), p)
    u, v = a * (1 - p["s"]), (1 - a) * eps
    return lam(p["delta"]) * (v - u)


def q_dagger(p):
    """Root of D(q) = 0 (two-type), or nan."""
    from scipy.optimize import brentq
    f = lambda q: D_of_q(q, p)
    if f(0) * f(1) > 0:
        return np.nan
    return brentq(f, 0, 1)


def fixed_points_fresh(p, Lmin=-1e5, Lmax=1e5):
    """All fixed points of the two-type fresh mean map, with stability."""
    from scipy.optimize import brentq
    grid = np.concatenate([-np.logspace(5, -3, 3000), [0.0], np.logspace(-3, 5, 3000)])
    grid = grid[(grid >= Lmin) & (grid <= Lmax)]
    g = mean_map_L(grid, p) - grid
    out = []
    for i in np.where(np.sign(g[:-1]) != np.sign(g[1:]))[0]:
        r = brentq(lambda L: mean_map_L(L, p) - L, grid[i], grid[i + 1])
        h = 1e-4 * max(1, abs(r))
        slope = (mean_map_L(r + h, p) - mean_map_L(r - h, p)) / (2 * h)
        out.append((r, 1 / (1 + np.exp(np.clip(r, -700, 700))), abs(slope) < 1))
    return out


def p_below_fresh(p, L_thr, q_teacher=0.0):
    """Two types, fresh regime: P(ln mu(A)/mu(G) < L_thr) after one generation
    trained from the base prior with a teacher of misaligned mass q_teacher
    (which sets the grader and the data channel).
    L = L_base + lambda_rho (2Z - m) + Lam (N_caught - N_rewarded), with
    Z ~ Bin(m, 1/2 + rho (1 - 2 q_teacher)) and N_caught - N_rewarded ~
    Skellam(n u, n v) (Poisson limit of the multinomial counts)."""
    from scipy.stats import binom, skellam, poisson
    eps, a = grader(q_teacher, p)
    u, v = a * (1 - p["s"]), (1 - a) * eps
    Lam = lam(p["delta"])
    lam_r = np.log((1 + 2 * p["rho"]) / (1 - 2 * p["rho"]))
    zs = np.arange(p["m"] + 1)
    pz = binom.pmf(zs, p["m"], 0.5 + p["rho"] * (1 - 2 * q_teacher))
    thr = (L_thr - p["L_base"] - lam_r * (2 * zs - p["m"])) / Lam   # need K = N_c - N_r < thr
    if v == 0:
        pk = poisson.cdf(np.ceil(thr) - 1, p["n"] * u)
    elif u == 0:
        pk = 1 - poisson.cdf(np.floor(-thr), p["n"] * v)
    else:
        pk = skellam.cdf(np.ceil(thr) - 1, p["n"] * u, p["n"] * v)
    return float(np.sum(pz * pk))


def p_escape_fresh(p, q_teacher=0.0):
    """Per-generation probability of leaving the aligned basin (ending below the
    unstable fixed point L_u of the mean map).  Without an unstable fixed point:
    0 if only the aligned state exists; if only the misaligned state exists,
    P(L < 0) (each generation is then a fresh draw that usually fails)."""
    fps = fixed_points_fresh(p)
    Lu = [L for L, q, st in fps if not st]
    stable = [q for L, q, st in fps if st]
    if not Lu:
        if min(stable) < 0.5:
            return 0.0, "A-only"
        return p_below_fresh(p, 0.0, q_teacher), "G-only"
    return p_below_fresh(p, Lu[0], q_teacher), "bistable"


def p_fail_fresh(p, N):
    """P(q_N > 1/2) after N fresh-regime generations from the human start:
    1 - (1 - p_esc)^(N-1) (1 - P(L < 0)).  The misaligned state is treated as absorbing."""
    pe, status = p_escape_fresh(p)
    if status == "A-only":
        return 0.0
    p0 = p_below_fresh(p, 0.0)
    return 1 - (1 - pe) ** (N - 1) * (1 - p0)


def p_fail_continued(p, N):
    """Two types, continued regime, human start: the log-odds L_k = L_base +
    Lam * (sum of k Skellam(n u0, n v0) steps), steps from the q = 0 grader.
    After generations 1..N-1 the walk is absorbed (counted as failed) below
    L_bar = logit(1 - q_dagger) (or 0 if D(q) > 0 for all q); after generation N
    it fails if L_N < 0.  Exact dynamic programming over the integer step sum."""
    from scipy.stats import skellam, poisson
    qd = q_dagger(p)
    if np.isnan(qd) and D_of_q(0.0, p) < 0:
        return 0.0
    Lbar = np.log((1 - qd) / qd) if not np.isnan(qd) else 0.0
    Lam = lam(p["delta"])
    eps, a = grader(0.0, p)
    u, v = a * (1 - p["s"]), (1 - a) * eps
    mu1, mu2 = p["n"] * u, p["n"] * v
    kmax = int(np.ceil(mu1 + mu2 + 12 * np.sqrt(mu1 + mu2 + 1))) + 5
    ks = np.arange(-kmax, kmax + 1)
    if mu1 > 0 and mu2 > 0:
        step = skellam.pmf(ks, mu1, mu2)
    elif mu1 > 0:
        step = np.where(ks >= 0, poisson.pmf(np.abs(ks), mu1), 0.0)
    else:
        step = np.where(ks <= 0, poisson.pmf(np.abs(ks), mu2), 0.0)
    span = N * kmax + 5
    S = np.arange(-span, span + 1)
    dist = (S == 0).astype(float)
    failed = 0.0
    for k in range(N):
        new = np.convolve(dist, step)[kmax:kmax + len(S)]
        L = p["L_base"] + Lam * S
        absorb = L < (Lbar if k < N - 1 else 0.0)
        failed += new[absorb].sum()
        dist = np.where(absorb, 0.0, new)
    return float(failed)

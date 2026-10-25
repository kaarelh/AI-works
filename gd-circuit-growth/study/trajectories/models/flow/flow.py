"""Flow: reduced continuous dynamics for the learning trajectory of the study's muP MLP on a Boolean target.

The network (study/nn_train.py) is f(x) = a . relu(W2 relu(W1 x + b1) + b2) on x in {-1,1}^30, width 128, muP, Adam
(lr 1e-3, multipliers 1 for W1, b1 and 64/N for W2, b2, a), square loss, minibatch 64.  The model keeps the network's
own parameters, initialisation and optimiser, and reduces only what the conditional mean F(x_R) = E[f(x) | x_R] on the
relevant cube does not need (MODEL.md gives the justification of every step):

  1. inputs.  The r relevant inputs are kept exactly: all 2^r patterns of x_R, weighted by the training distribution.
     The d - r irrelevant inputs enter only through each first-layer unit's irrelevant pre-activation
     z_k = w_off,k . x_off, which given x_R is Gaussian (CLT over d - r >= 20 coordinates) with covariance W_off W_off^T.
  2. moment closure.  Every unit is propagated by its mean and variance given x_R (E relu of a Gaussian in closed form).
     The linear part of Var(f | x_R) is kept exactly through the vectors w_off,k (the network cancels it); the rest of
     the irrelevant noise is treated as independent across units.
  3. minibatch -> expectation.  The gradient is the expected gradient over the (population or training) distribution;
     the minibatch noise is kept where it acts systematically, in Adam's second moment, v = EMA(g^2 + Var(g_x) / B),
     with the per-sample gradient variance Var(g_x) computed in moment closure.
  4. width.  Same muP parametrisation at width N (128 = the network's when affordable).
  5. finite n.  The training residual of every sample can also be absorbed through its own irrelevant coordinates
     (memorisation).  Samples with the same relevant pattern see the same residual, so one memorised offset mu_p per
     pattern: d mu_p / dt = -lam_p (F_p + mu_p - y_p), with lam_p the diagonal of the Adam-preconditioned tangent
     kernel restricted to the irrelevant directions, divided by n (1 + n / n_c), n_c = 128 (d - r) memory slots.  The
     offsets carry no conditional mean at test points.  The random irrelevant output of the training samples is
     absorbed the same way, so its penalty in the training loss is weighted by exp(-int lam_p dt).
"""
import os, sys, itertools
os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")
os.environ.setdefault("XLA_FLAGS", "--xla_cpu_multi_thread_eigen=false intra_op_parallelism_threads=1")
try:   # the XLA CPU runtime still spreads work over a few threads: pin the process to one core (FLOW_CPU to choose)
    _cpus = sorted(os.sched_getaffinity(0))
    os.sched_setaffinity(0, {int(os.environ.get("FLOW_CPU", _cpus[os.getpid() % len(_cpus)]))})
except (AttributeError, OSError):
    pass
import numpy as np
import jax, jax.numpy as jnp
from jax.scipy.special import ndtr

HERE = os.path.dirname(os.path.abspath(__file__))
STUDY = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
sys.path.insert(0, STUDY)
from boolfuncs import make_suite

SUITE = make_suite(30)
# the network's training hyper-parameters (not fitted): input dimension, minibatch, Adam, muP base width, steps
D, B, LR, B1, B2, EPS, BASE, NNET, STEPS = 30, 64, 1e-3, 0.9, 0.999, 1e-8, 64, 128, 20000
SQ2PI = 0.3989422804014327
# the model's constants, all at their derived values (MODEL.md, section 3)
CONSTS = dict(c_mem=1.0,       # memorisation rate = c_mem x (diagonal of the preconditioned kernel) / n
              c_cap=1.0)       # memory slots n_c = c_cap x 128 x (d - r)
BETA_W = 0.1                   # onsets of a width-N model ~ (128 / N)^BETA_W x those at width 128 (model vs model)
# ablation switches (1 = full model; MODEL.md, section 5)
ABL = dict(noise_v=1.0,        # minibatch noise in Adam's second moment
           off=1.0,            # irrelevant inputs (initial off-R weights)
           cancel=1.0,         # exact (cancellable) linear part of Var(f | x_R)
           hermite=1.0,        # non-linear (higher-Hermite) part of the units' irrelevant variance in Var(f | x_R)
           absorb=1.0)         # memorisation also absorbs the random irrelevant output of the training samples
CONDS = {"online": None, "16384": 16384, "2048": 2048, "512": 512}


def _fn_seed(name):
    return int.from_bytes(name.encode(), "little") % (2 ** 31)


def target(fn):
    R = SUITE[fn]["relevant"]; r = len(R)
    pats = np.array(list(itertools.product([-1.0, 1.0], repeat=r)))
    X = np.ones((len(pats), D)); X[:, R] = pats
    y = SUITE[fn]["fn"](X).astype(np.float64)
    return R, pats, y


def train_weights(fn, seed, n):
    """Pattern weights of a training set of size n: the same draw as nn_train.make_data(fn, seed, 16384)[:n]."""
    R = SUITE[fn]["relevant"]; r = len(R)
    rng = np.random.default_rng([_fn_seed(fn), seed])
    X = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(max(n, 16384), D))[:n]
    idx = ((X[:, R] > 0).astype(int) * (2 ** np.arange(r - 1, -1, -1))).sum(1)
    return np.bincount(idx, minlength=2 ** r) / n


def gauss_relu(m, s):
    """E relu(m+z), E relu(m+z)^2, P(m+z>0) for z ~ N(0, s^2)."""
    s = jnp.maximum(s, 1e-5)
    t = m / s
    Phi = ndtr(t); phi = jnp.exp(-0.5 * t * t) * SQ2PI
    return s * phi + m * Phi, (m * m + s * s) * Phi + m * s * phi, Phi


def forward(p, X):
    """Moment closure on the relevant cube X [P, r].  Returns E[f | x_R], Var[f | x_R] and the unit statistics."""
    s2 = jnp.sum(p["Woff"] ** 2, 1)                        # irrelevant variance of every first-layer unit
    s = jnp.sqrt(s2 + 1e-12)
    u = X @ p["W1"].T + p["b1"]
    mu1, q1, P1 = gauss_relu(u, s[None, :])
    var1 = jnp.maximum(q1 - mu1 ** 2, 0.0)
    m2 = mu1 @ p["W2"].T + p["b2"]
    var2 = var1 @ (p["W2"] ** 2).T                         # second layer: irrelevant noise of the units independent
    mu2, q2, P2 = gauss_relu(m2, jnp.sqrt(var2 + 1e-12))
    F = mu2 @ p["a"]
    G = (P2 * p["a"]) @ p["W2"]                             # mean back-propagated gain of every first-layer unit
    vout = (G * P1) @ p["Woff"]                             # linear sensitivity of f to x_off given x_R  [P, d-r]
    vh2 = jnp.maximum(q2 - mu2 ** 2, 0.0)
    lin = ABL["cancel"] * jnp.sum(vout ** 2, 1) + (1 - ABL["cancel"]) * jnp.sum((G * P1) ** 2 * s2[None, :], 1)
    varF = (lin + ABL["hermite"] * jnp.sum(G ** 2 * jnp.maximum(var1 - P1 ** 2 * s2[None, :], 0.0), 1)
            + jnp.sum(p["a"] ** 2 * jnp.maximum(vh2 - P2 ** 2 * var2, 0.0), 1))
    return F, varF, dict(q1=q1, P1=P1, var1=var1, P2=P2, q2=q2, vh2=vh2, G=G, s=s)


def loss(p, X, y, w, mu, rho):
    """Expected (training) loss: E[(f - y)^2] / 2 = E_xR[(F + mu - y)^2 + rho Var(f | x_R)] / 2."""
    F, varF, h = forward(p, X)
    return jnp.sum(w * (0.5 * (F + mu - y) ** 2 + 0.5 * rho * varF)), (F, varF, h)


def moments(p, F, varF, h, y, w, mu, rho):
    """Second moment E[g_x^2] of the per-sample gradient of every parameter (moment closure: residual and gradient
    factor treated as independent given x_R), and E[delta_k^2 | x_R] of the back-propagated signal of every unit."""
    e = F + mu - y
    E2 = w * (e ** 2 + rho * varF)
    a2 = p["a"] ** 2
    P2 = h["P2"]
    Dsq = (h["G"] ** 2 + (P2 * (1 - P2) * a2[None, :]) @ (p["W2"] ** 2)) * h["P1"]
    gb1 = E2 @ Dsq
    g2 = dict(a=E2 @ h["q2"], b2=(E2 @ P2) * a2, W2=(E2[:, None] * P2 * a2[None, :]).T @ h["q1"], b1=gb1,
              W1=jnp.broadcast_to(gb1[:, None], p["W1"].shape), Woff=jnp.broadcast_to(gb1[:, None], p["Woff"].shape))
    return e, Dsq, g2


def init(key, N, r):
    """The network's muP initialisation at width N (W1 split into its relevant and irrelevant columns)."""
    k1, k2, k3, k4 = jax.random.split(key, 4)
    return dict(W1=jax.random.normal(k1, (N, r)) / np.sqrt(D), b1=jnp.zeros(N),
                Woff=ABL["off"] * jax.random.normal(k2, (N, D - r)) / np.sqrt(D),
                W2=jax.random.normal(k3, (N, N)) / np.sqrt(N), b2=jnp.zeros(N),
                a=jax.random.normal(k4, (N,)) / N)


def schedule(K0=300, kmax=2, steps=STEPS, n_rec=160):
    """Model steps: k(t) = clip(t // K0, 1, kmax) Adam steps lumped into one (exact while t < K0; kmax <= 2 keeps the
    late, near-converged phase free of lumping artefacts).  Returns the step sizes, the record-buffer row of every
    model step (n_rec = not recorded) and the recorded training steps (about n_rec, log-spaced)."""
    ks, t = [], 0
    while t < steps:
        k = int(min(max(1, t // K0), kmax, steps - t))
        ks.append(k); t += k
    ks = np.array(ks, dtype=np.int32)
    ends = np.cumsum(ks)
    want = np.unique(np.round(np.logspace(0, np.log10(steps), n_rec)).astype(int))
    rec_idx = np.unique(np.searchsorted(ends, want))
    rec_idx = rec_idx[rec_idx < len(ks)]
    row = np.full(len(ks), len(rec_idx), dtype=np.int32)
    row[rec_idx] = np.arange(len(rec_idx))
    return ks, row, np.concatenate([[0], ends[rec_idx]])


def make_sim(N, r, X, y, ks, row, consts):
    mult = dict(W1=1.0, b1=1.0, Woff=1.0, W2=BASE / N, b2=BASE / N, a=BASE / N)
    X = jnp.array(X, dtype=jnp.float32); y = jnp.array(y, dtype=jnp.float32)
    P = X.shape[0]
    vg = jax.value_and_grad(loss, has_aux=True)
    dr = D - r
    c_mem = consts["c_mem"]; n_c = consts["c_cap"] * NNET * dr
    diffuse = consts.get("diffuse", ())                    # ablation only: random walk of these parameters
    n_rec = int(row.max())

    def step(carry, inp):
        k, rw_prev = inp
        p, m, v, vn, t, mu, Lam, w, inv_n, key, Fbuf, Sbuf = carry
        rho = jnp.exp(-ABL["absorb"] * Lam)                # share of the random irrelevant output not yet memorised
        kf = k.astype(jnp.float32)
        (L, (F, varF, h)), g = vg(p, X, y, w, mu, rho)
        e, Dsq, g2 = moments(p, F, varF, h, y, w, mu, rho)
        # ---- Adam on the expected gradient, with the minibatch variance in the second moment
        b1k, b2k = B1 ** kf, B2 ** kf
        t = t + kf
        c1, c2 = 1 - B1 ** t, 1 - B2 ** t
        key, *sub = jax.random.split(key, len(p) + 1)
        newp, newm, newv, newvn = {}, {}, {}, {}
        for i, name in enumerate(sorted(p)):
            gg = g[name]
            noise = ABL["noise_v"] * jnp.maximum(g2[name] - gg ** 2, 0.0) / B
            mm = b1k * m[name] + (1 - b1k) * gg
            vv = b2k * v[name] + (1 - b2k) * (gg ** 2 + noise)
            nn = b2k * vn[name] + (1 - b2k) * noise
            upd = p[name] - LR * mult[name] * kf * (mm / c1) / (jnp.sqrt(vv / c2) + EPS)
            if name in diffuse:
                upd = upd + LR * mult[name] * jnp.sqrt(kf * nn / (vv + 1e-30)) * jax.random.normal(sub[i], upd.shape)
            newp[name] = upd; newm[name] = mm; newv[name] = vv; newvn[name] = nn
        # ---- memorisation (finite n only; inv_n = 0 online).  Per-sample rate: diagonal of the Adam-preconditioned
        # tangent kernel over the parameters' irrelevant fluctuations, Var(J_theta | x_R) / sqrt(v_theta), / n:
        # off-R first-layer weights (d - r of them per unit), second-layer weights, readout.
        rs = lambda vv: 1.0 / (jnp.sqrt(vv / c2) + 1e-12)
        lam1 = dr * (Dsq @ jnp.mean(rs(newv["Woff"]), 1))
        lam2 = mult["W2"] * jnp.sum(((p["a"] ** 2)[None, :] * h["P2"]) * (h["var1"] @ rs(newv["W2"]).T), 1)
        lam3 = mult["a"] * (h["vh2"] @ rs(newv["a"]))
        n_over_nc = jnp.where(inv_n > 0, 1.0 / (inv_n * n_c), 0.0)
        lam = c_mem * LR * inv_n * (lam1 + lam2 + lam3) / (1.0 + n_over_nc)
        mu = mu - (1 - jnp.exp(-kf * lam)) * e
        Lam = Lam + kf * lam
        # ---- record (F before this step = state reached by the previous model step)
        stats = jnp.stack([jnp.mean(h["s"]), jnp.sqrt(jnp.mean(p["W1"] ** 2)), jnp.sqrt(jnp.mean(p["a"] ** 2)),
                           jnp.mean(p["b1"]), jnp.sum(w * varF), L, jnp.sum(w * jnp.abs(mu)),
                           0.5 * jnp.mean((F - y) ** 2 + varF)])
        Fbuf = Fbuf.at[rw_prev].set(F); Sbuf = Sbuf.at[rw_prev].set(stats)
        return (newp, newm, newv, newvn, t, mu, Lam, w, inv_n, key, Fbuf, Sbuf), None

    @jax.jit
    def sim(p0, w, inv_n, key):
        z = jax.tree_util.tree_map(jnp.zeros_like, p0)
        mu0 = jnp.zeros_like(y)
        Fbuf = jnp.zeros((n_rec + 1, P)); Sbuf = jnp.zeros((n_rec + 1, 8))
        carry = (p0, z, z, z, jnp.float32(0), mu0, mu0, jnp.asarray(w, jnp.float32), jnp.float32(inv_n), key, Fbuf, Sbuf)
        rows_prev = jnp.concatenate([jnp.array([n_rec], jnp.int32), jnp.array(row[:-1])])
        carry, _ = jax.lax.scan(step, carry, (jnp.array(ks), rows_prev))
        Fbuf = carry[10].at[row[-1]].set(forward(carry[0], X)[0])
        return jnp.concatenate([forward(p0, X)[0][None], Fbuf[:n_rec]], 0), carry[11][:n_rec]

    return sim


def resolution(P):
    """Width and number of model seeds for a cube of P = 2^r patterns: width 64 (half the network's; with the width
    correction below it is as accurate as 128, MODEL.md section 3) and 6 seeds, narrower and fewer for r >= 8 so that
    the four conditions take at most about 4 minutes on one core."""
    if P <= 128:
        return 64, 6
    if P <= 256:
        return 64, 3
    if P <= 512:
        return 48, 2
    return 32, 2


def width_dilation(N):
    """Onsets of a width-N model relative to width 128 (measured on the model itself, MODEL.md section 3)."""
    return (NNET / N) ** BETA_W


def run(fn, conds=tuple(CONDS), N=128, seeds=3, K0=300, kmax=2, consts=None):
    """Simulate the model.  Returns the recorded steps [T] and, per condition, F [seeds, T, 2^r] (one row per model
    seed: init seed sd, training-set draw sd % 3 as in the networks).  run.stats holds the unit statistics."""
    consts = dict(CONSTS, **(consts or {}))
    R, pats, y = target(fn); r = len(R)
    ks, row, steps = schedule(K0, kmax)
    sim = make_sim(N, r, pats, y, ks, row, consts)
    out, stats = {}, {}
    for cond in conds:
        n = CONDS[cond]
        Fs, sts = [], []
        for sd in range(seeds):
            w = np.full(len(y), 1.0 / len(y)) if n is None else train_weights(fn, sd % 3, n)
            F, st = sim(init(jax.random.PRNGKey(100 + sd), N, r), w, 0.0 if n is None else 1.0 / n,
                        jax.random.PRNGKey(7 + sd))
            Fs.append(np.array(F)); sts.append(np.array(st))
        out[cond] = np.stack(Fs); stats[cond] = np.stack(sts)
    run.stats = stats
    return steps, out

"""Section B4: short SGD / full-batch GD runs that record the quantities of Theorems B1.1-B1.3 and
evaluate the time-based (a priori) and data-dependent bounds of Section B3 along the trajectory.

Same network, init and muP SGD multipliers as gd-circuit-growth/study/nn_train.py:
  f(x) = a.relu(W2 relu(W1 x + b1) + b2), N = 128, d = 30, W1 ~ N(0,1/d), W2 ~ N(0,1/N), a ~ N(0,1/N^2)
  SGD: lr 0.2, multipliers m = (W1,b1: N/64 = 2; W2,b2: 1; a: 64/N = 0.5)
Recorded per step: the M-norm of the update direction, so that
  path length  Lambda_K = eta * sum_k ||g_k||_M          (>= ||theta_K - theta_0||_{M^-1})
  energy       E_K      = eta * sum_k ||g_k||_M^2        (Lambda_K <= sqrt(t_K E_K),  t_K = eta K)
and, for full-batch GD, the descent ratio (L_k - L_{k+1}) / (eta ||g_k||_M^2).

mode adam: Adam (lr 1e-3, betas 0.9/0.999, eps 1e-8, bias correction, multipliers W1,b1: 1; W2,b2,a: 64/N),
records S_K = sum_t C_t (Lemma B1.4) and the largest per-coordinate step ratio |mhat|/(sqrt(vhat)+eps) seen,
and evaluates the time-based PAC-Bayes KL bound  sum_g p_g (eta m_g S_K)^2 / (2 sig_g^2).

usage: python3 sgd_short.py <fn> <n> <mode: sgd|gd|adam> <steps> [eta]     (a few minutes at most)
"""
import os, sys, json, time
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "study"))
import numpy as np
import jax, jax.numpy as jnp
import nn_train as nt
import nnbounds as nb

fn, n, mode, steps = sys.argv[1], int(sys.argv[2]), sys.argv[3], int(sys.argv[4])
seed = 0
ETA = float(sys.argv[5]) if len(sys.argv) > 5 else (0.2 if mode != "adam" else 1e-3)
TAG = f"_eta{sys.argv[5]}" if len(sys.argv) > 5 else ""
MULT = nt.MULT["sgd" if mode != "adam" else "adam"]
B1_, B2_ = 0.9, 0.999
def C_t(t):
    r = B1_ ** 2 / B2_
    return (1 - B1_) / (1 - B1_ ** t) * np.sqrt((1 - B2_ ** t) / (1 - B2_)) * np.sqrt((1 - r ** t) / (1 - r))
KEYS = ["W1", "b1", "W2", "b2", "a"]

X, y = nt.make_data(fn, seed, max(n, 16384)); X, y = jnp.array(X[:n]), jnp.array(y[:n])
Xte, yte = nt.make_test(fn); Xte, yte = jnp.array(Xte), jnp.array(yte)
p0 = nt.init_params(jax.random.PRNGKey(1000 * seed + 7))

def mnorm2(g):
    return sum(MULT[k] * jnp.sum(g[k] ** 2) for k in KEYS)

@jax.jit
def adam_step(p, m, v, t, xb, yb):
    g = jax.grad(nt.loss_fn)(p, xb, yb)
    m = {k: B1_ * m[k] + (1 - B1_) * g[k] for k in KEYS}
    v = {k: B2_ * v[k] + (1 - B2_) * g[k] ** 2 for k in KEYS}
    u = {k: (m[k] / (1 - B1_ ** t)) / (jnp.sqrt(v[k] / (1 - B2_ ** t)) + 1e-8) for k in KEYS}
    p = {k: p[k] - ETA * MULT[k] * u[k] for k in KEYS}
    return p, m, v, jnp.max(jnp.array([jnp.max(jnp.abs(u[k])) for k in KEYS]))

@jax.jit
def step(p, xb, yb):
    l, g = jax.value_and_grad(nt.loss_fn)(p, xb, yb)
    p = {k: p[k] - ETA * MULT[k] * g[k] for k in KEYS}
    return p, l, mnorm2(g)

full_loss = jax.jit(lambda p: nt.loss_fn(p, X, y))

ckpts = sorted(set([0, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 3000, 5000, 8000, 12000, 20000]) & set(range(steps + 1)) | {steps})
rng = np.random.default_rng(1)
PB_CKPTS = {20, 50, 100, 200, 500, 1000, 2000, 5000, 12000} if len(sys.argv) <= 5 else {50, 100, 200, 500, 1000, 2000, 5000}
key = jax.random.PRNGKey(123)
p = p0
L0 = float(full_loss(p0))
Lam = 0.0; E = 0.0; Eg = np.zeros(3); desc_min = np.inf; desc_q01 = []
S_K = 0.0; max_ratio = 0.0; max_ratio_over_C = 0.0
mA = jax.tree_util.tree_map(jnp.zeros_like, p0); vA = jax.tree_util.tree_map(jnp.zeros_like, p0)
out = []
t0 = time.time()
def gsq_groups(p, xb, yb):
    g = jax.grad(nt.loss_fn)(p, xb, yb)
    return [MULT["W1"] * (jnp.sum(g["W1"] ** 2) + jnp.sum(g["b1"] ** 2)),
            MULT["W2"] * (jnp.sum(g["W2"] ** 2) + jnp.sum(g["b2"] ** 2)), MULT["a"] * jnp.sum(g["a"] ** 2)]
gsq_groups = jax.jit(gsq_groups)

def record(k, p):
    pn = {kk: np.array(v, dtype=np.float32) for kk, v in p.items()}
    p0n = {kk: np.array(v, dtype=np.float32) for kk, v in p0.items()}
    Xn, yn = np.array(X), np.array(y)
    marg = yn * nb.forward(pn, Xn)
    te = float(np.mean(np.array(yte) * nb.forward(pn, np.array(Xte)) <= 0))
    sq = nb.group_sq_dist(pn, p0n)
    mg = np.array([MULT["W1"], MULT["W2"], MULT["a"]])
    distM = float(np.sqrt((sq / mg).sum()))
    t = ETA * k
    rec = dict(step=k, t=t, train_loss=float(full_loss(p)), train_err=float(np.mean(marg <= 0)), test_err=te,
               dist_M=distM, path_len=Lam, sqrt_tE=float(np.sqrt(t * E)), sqrt_tL0=float(np.sqrt(t * L0)),
               dist_groups=[float(v) for v in np.sqrt(sq)], energy_groups=[float(v) for v in Eg],
               path=nb.path_norm(pn), PF=nb.frob_complexity(pn), desc_min=float(desc_min),
               S_K=S_K, max_step_ratio=max_ratio, max_ratio_over_C=max_ratio_over_C)
    # descent constant for B1.2(b) / B3.3(a): (D) must hold at every step k < K, so c = running minimum of the
    # measured descent ratio (GD only).  If (D) fails (c <= 0) or the run is SGD, the 'flow' numbers use c = 1
    # and are NOT rigorous (flow_rigorous = False).  [revision r2: previously c = 1 was hard-coded]
    if mode == "gd" and 0 < desc_min < np.inf:
        desc_c, flow_rig = float(desc_min), True
    else:
        desc_c, flow_rig = 1.0, bool(mode == "gd" and desc_min == np.inf)   # k = 0: nothing to check
    rec.update(desc_c_used=desc_c, flow_rigorous=flow_rig)
    # Theorem B3.1 (a priori, Frobenius): P^max over the M^-1 ball of radius sqrt(t L0 / c).  [revision r2]
    # PF_apriori is the certified closed-form UPPER bound of Theorem B3.1; PF_apriori_search is the old
    # random-search value, a LOWER estimate of P^max, kept only for comparison.
    if mode != "adam":
        r_ = np.sqrt(t * L0 / desc_c)
        rec["PF_apriori"] = PF_sup_closed(p0n, r_)
        rec["PF_apriori_search"] = PF_sup(p0n, r_)
        jF = nb.grid_index(rec["PF_apriori"], 1.0, 1.1)
        rec["frob_apriori_unit_margin"] = float(2 * nb.KAPPA_FROB(31) * 1.1 ** jF / np.sqrt(n))   # complexity term at gamma = 1
        rec["frob_apriori_bound"] = nb.margin_bound(marg, rec["PF_apriori"], nb.KAPPA_FROB(31))[0]
    else:
        rec["PF_apriori"] = rec["PF_apriori_search"] = rec["frob_apriori_unit_margin"] = rec["frob_apriori_bound"] = float("nan")
    rec["frob_measured_bound"] = nb.margin_bound(marg, rec["PF"], nb.KAPPA_FROB(31))[0]
    rec["path_measured_bound"] = nb.margin_bound(marg, rec["path"], nb.KAPPA_PATH(31))[0]
    if k > 0 and (k in PB_CKPTS or k == steps):
        # Theorem B3.2, data-dependent: per-group sigma, KL from the measured displacement
        pb = nb.pac_bayes(pn, p0n, Xn, yn, rng)
        rec.update(pb_KL=pb["KL"], pb_sig=[float(v) for v in pb["sig"]], pb_gibbs=pb["gibbs_train"], pb_RQ=pb["RQ"], pb_det=pb["det"],
                   pb_gibbs_up=pb["gibbs_train_up"], pb_dis=pb["dis"], pb_dis_up=pb["dis_up"])
        # Theorem B3.3, time-based: same sigma, but KL replaced by its a-priori upper bound
        #   sum_g ||D_g||^2/(2 s_g^2) <= t * sum_g m_g E_g/(2 s_g^2)   [measured energies; Cor. B1.2]
        sig = pb["sig"]
        KL_energy = float(t * (mg * Eg / (2 * sig ** 2)).sum())
        #   and the fully a-priori version (gradient flow / descent with constant c): t L0 max_g m_g/(2 s_g^2)/c
        KL_flow = float(t * L0 * (mg / (2 * sig ** 2)).max() / desc_c)
        G = len(nb.SIG_GRID) ** 3
        pg = np.array([p0n["W1"].size + p0n["b1"].size, p0n["W2"].size + p0n["b2"].size, p0n["a"].size])
        KL_adam = float((pg * (ETA * mg * S_K) ** 2 / (2 * sig ** 2)).sum())
        cands = [("adam", KL_adam)] if mode == "adam" else [("energy", KL_energy), ("flow", KL_flow)]
        for name, KL in cands:
            rec[f"pb_KL_{name}"] = KL
            rec[f"pb_RQ_{name}"] = nb.kl_inv_upper(pb["gibbs_train_up"], (KL + np.log(2 * np.sqrt(n) * G / 0.03)) / n)
    out.append(rec)
    print(json.dumps({kk: (round(v, 4) if isinstance(v, float) else v) for kk, v in rec.items()}), flush=True)

def PF_sup_closed(p0n, r):
    """Certified upper bound on P^max(r) (Theorem B3.1, closed form): every block displacement is at most
       sqrt(m_g) r, so P_F <= (A0 + sqrt(m3) r)((F1 + sqrt(m1) r)(F2 + sqrt(m2) r) + B2 + sqrt(m2) r)."""
    A1 = np.sqrt((p0n["W1"] ** 2).sum() + (p0n["b1"] ** 2).sum()); A2 = np.linalg.norm(p0n["W2"])
    B2 = np.linalg.norm(p0n["b2"]); Aa = np.linalg.norm(p0n["a"])
    s1, s2, s3 = np.sqrt(MULT["W1"]) * r, np.sqrt(MULT["W2"]) * r, np.sqrt(MULT["a"]) * r
    return float((Aa + s3) * ((A1 + s1) * (A2 + s2) + B2 + s2))

def PF_sup(p0n, r, tries=4000):
    """LOWER estimate of P^max (not a certified bound; see PF_sup_closed): max of
       ||a||(||[W1 b1]||_F ||W2||_F + ||b2||) over sum_g ||D_g||^2/m_g <= r^2 by random search on the positive
       sphere + refinement."""
    A1 = np.sqrt((p0n["W1"] ** 2).sum() + (p0n["b1"] ** 2).sum()); A2 = np.linalg.norm(p0n["W2"])
    B2 = np.linalg.norm(p0n["b2"]); Aa = np.linalg.norm(p0n["a"])
    m = np.array([MULT["W1"], MULT["W2"], MULT["b2"], MULT["a"]])
    def val(u):
        dlt = np.sqrt(m) * r * u
        return (Aa + dlt[3]) * ((A1 + dlt[0]) * (A2 + dlt[1]) + B2 + dlt[2])
    rs = np.random.default_rng(0)
    U = np.abs(rs.standard_normal((tries, 4))); U /= np.linalg.norm(U, axis=1, keepdims=True)
    best = U[np.argmax([val(u) for u in U])]
    for scale in [0.1, 0.03, 0.01, 0.003]:
        for _ in range(200):
            v = np.abs(best + scale * rs.standard_normal(4)); v /= np.linalg.norm(v)
            if val(v) > val(best):
                best = v
    return float(val(best))

for k in range(steps + 1):
    if k in ckpts:
        record(k, p)
    if k == steps:
        break
    if mode in ("sgd", "adam"):
        idx = rng.integers(0, n, size=64)
        xb, yb = X[idx], y[idx]
    else:
        xb, yb = X, y
    if mode == "adam":
        p, mA, vA, mr = adam_step(p, mA, vA, k + 1, xb, yb)
        S_K += C_t(k + 1); max_ratio = max(max_ratio, float(mr)); max_ratio_over_C = max(max_ratio_over_C, float(mr) / C_t(k + 1))
        continue
    Lk = float(full_loss(p)) if mode == "gd" else None
    gg = gsq_groups(p, xb, yb)
    p_new, l, g2 = step(p, xb, yb)
    g2 = float(g2)
    Lam += ETA * np.sqrt(g2); E += ETA * g2; Eg += ETA * np.array([float(v) for v in gg])
    if mode == "gd" and g2 > 0:
        r_ = (Lk - float(full_loss(p_new))) / (ETA * g2)
        desc_min = min(desc_min, r_); desc_q01.append(r_)
    p = p_new
summary = dict(fn=fn, n=n, mode=mode, steps=steps, L0=L0, eta=ETA, records=out,
               desc_ratio_quantiles=(np.quantile(desc_q01, [0, 0.01, 0.5]).tolist() if desc_q01 else None),
               seconds=time.time() - t0)
with open(os.path.join(HERE, f"sgd_short_{fn}_{n}_{mode}{TAG}.json"), "w") as f:
    json.dump(summary, f, default=float)
print("done", round(time.time() - t0), "s;  descent ratio quantiles (min, 1%, median):", summary["desc_ratio_quantiles"])

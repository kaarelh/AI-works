"""D checks (Part I): two-layer ReLU network from balanced small initialization, d = 16.

f(x) = sum_j a_j relu(w_j . xt), xt = (x, 1); |a_j(0)| = |w_j(0)| = alpha; full-batch GD with a small step on
L = (1/2)|y - f|_n^2, as an approximation of gradient flow.  Test quantities are exact (all 2^16 cube points).

Checks, in the order of D-early-phase-theorem.md:
  D0     balance a_j^2 - |w_j|^2 (conserved by the flow; GD drift O(eta^2) per step);
         the exact clock  ln rho_j(t) - ln rho_j(0) = 2 int eps_j U_r(w_j/|w_j|)  (GD: Riemann sum, error O(eta));
         monotonicity of the loss; near-monotonicity of eps_j U_y(direction_j)  (Lemma D0(f)).
  D1     certified utility bound  Uhat(r) >= sup_v |U_r(v)|  (Lemma D1.1) against a multistart lower estimate;
         per-neuron growth bound  rho_j(t) <= rho_j(0) exp(2 int Ubar)  with Ubar = Uhat(r(s)) and with sqrt(lam)|r|;
         escape-time lower bound  t_beta >= T_beta  (Theorem D1(3)), with the certified Uhat(y) in place of U_0^*.
  D1.3   quantization: fraction of [0, t_beta] during which a neuron's tangential selection gradient exceeds eta_q,
         against the proved bound on that time.
  D2     path norm P(t) = |theta(t)|^2 against the a priori bound beta + |y|^2 (t - T_beta)_+  and the loss-curve bound.
  D2.2   Maurey/Occam generalization bound (Proved) evaluated along the trajectory, against the exact test error.
  D3     plateau diagnostics for Conjecture D3: clusters of the grown neurons, their training-set margins (kinks),
         the dormant-mass growth rate against 2 Uhat(r).
Runs in about a minute per configuration on one core.
"""
import math, sys, json, os
import numpy as np
sys.dont_write_bytecode = True
os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from c_common import klinv_upper  # noqa: E402

d = 16
relu = lambda z: np.maximum(z, 0.0)


def target(name, X):
    if name == "x1":
        return X[:, 0].copy()
    if name == "maj3":
        return np.sign(X[:, :3].sum(1))
    if name == "x1+x2x3":            # real-valued: two stages of different utility
        return X[:, 0] + 0.5 * X[:, 1] * X[:, 2]
    raise ValueError(name)


def cube(d):
    idx = np.arange(2 ** d)[:, None]
    return 1.0 - 2.0 * ((idx >> np.arange(d)[None, :]) & 1)


def U_hat(r, Xt):
    """Certified upper bound on sup_{|v|=1} |<r, relu(v.xt)>_n|  (Lemma D1.1)."""
    n = len(r)
    out = []
    for rr in (np.maximum(r, 0), np.maximum(-r, 0)):
        if rr.sum() == 0:
            out.append(0.0)
            continue
        # (i) |r^+|_n sqrt(lam_max(1/n sum_{r_i>0} xt xt^T));  (ii) sqrt(mean(r^+) lam_max(1/n sum r_i^+ xt xt^T))
        S = Xt[rr > 0]
        b1 = math.sqrt((rr ** 2).mean()) * math.sqrt(np.linalg.eigvalsh(S.T @ S / n)[-1])
        M = (Xt * rr[:, None]).T @ Xt / n
        b2 = math.sqrt(rr.mean() * np.linalg.eigvalsh(M)[-1])
        out.append(min(b1, b2))
    return max(out)


def U_est(r, Xt, rng, V0=None, starts=256, iters=300, lr=0.5):
    """Multistart projected (sub)gradient ascent of +-U_r on the sphere: a LOWER estimate of sup |U_r|."""
    n, D = Xt.shape
    V = rng.standard_normal((starts, D))
    if V0 is not None:
        V = np.vstack([V, V0])
    V /= np.linalg.norm(V, axis=1, keepdims=True)
    best = 0.0
    for sgn in (1.0, -1.0):
        W = V.copy()
        for _ in range(iters):
            Z = W @ Xt.T
            g = ((Z > 0) * (sgn * r)[None, :]) @ Xt / n
            g -= (g * W).sum(1, keepdims=True) * W
            W = W + lr * g
            W /= np.linalg.norm(W, axis=1, keepdims=True)
        best = max(best, float((sgn * relu(W @ Xt.T) @ r / n).max()))
    return best


def maurey_occam(P, gamma, n, emp_marg, b2, delta=0.05):
    """Theorem D2.2 bound for a given path-norm value P (mass B = P/2, rounded up to a power of 2), optimized over K."""
    B = 2.0 ** math.ceil(math.log2(max(P / 2, 1e-12)))
    bexp = int(round(math.log2(B)))
    best = 1.0
    for K in range(1, 4000):
        eta = 1.0 / math.sqrt(K * (d + 1))
        lnG = K * math.log(2 * (1 + 2 / eta) ** (d + 1) + 1)
        lnpi = math.log(K * (K + 1)) + math.log(2 * (abs(bexp) + 1) * (abs(bexp) + 2))
        eps2 = (B * (math.sqrt(b2) + 1) / math.sqrt(K)) ** 2
        apx = 2 * eps2 / gamma ** 2
        if apx >= 1:
            continue
        val = klinv_upper(min(1.0, emp_marg + apx), (lnG + lnpi + math.log(1 / delta)) / n) + apx
        best = min(best, val)
    return best


def cluster_occam(Wn, rho, eps, Ct, Xt, y, n, gammas=(0.125, 0.25, 0.5), delta=0.05, cos_thr=0.99, grow=1e-3):
    """Proposition D2.3: K-neuron Occam bound with the network's own clusters; sup|f-g| computed exactly on the cube."""
    G = np.where(rho >= grow * rho.max())[0]
    cl = []
    for j in G:
        for c in cl:
            if Wn[j] @ Wn[c[0]] > cos_thr and eps[j] == eps[c[0]]:
                c.append(j); break
        else:
            cl.append([j])
    coef = eps * rho / 2
    f_C = relu(Ct @ Wn.T) @ coef
    f_S = relu(Xt @ Wn.T) @ coef
    reps, cs = [], []
    for c in cl:
        v = (rho[c][:, None] * Wn[c]).sum(0); v /= np.linalg.norm(v)
        reps.append(v); cs.append(coef[c].sum())
    K = len(cl)
    g_C = relu(Ct @ np.array(reps).T) @ np.array(cs) if K else np.zeros(len(Ct))
    hsup = float(np.abs(f_C - g_C).max())
    B = float(np.abs(cs).sum()) if K else 0.0
    Bd = 2.0 ** math.ceil(math.log2(max(B, 1e-12)))
    bexp = int(round(math.log2(Bd)))
    best, arg = 1.0, None
    for g in gammas:
        if hsup > g / 4:
            continue
        eta_d = g / (8 * Bd * math.sqrt(d + 1)); eta_c = g / (8 * max(K, 1) * math.sqrt(d + 1))
        lnG = K * ((d + 1) * math.log(1 + 2 / eta_d) + math.log(2 * math.ceil(Bd / eta_c) + 1))
        lnpi = math.log((K + 1) * (K + 2)) + math.log(2 * (abs(bexp) + 1) * (abs(bexp) + 2)) + math.log(len(gammas))
        emp = float(np.mean(y * f_S <= g))
        val = klinv_upper(emp, (lnG + lnpi + math.log(1 / delta)) / n)
        if val < best:
            best, arg = val, (g, lnG)
    return best, K, hsup, B, arg


def run(name, n, m, alpha, eta, T, seed=0, log_every=10):
    rng = np.random.default_rng(seed)
    C = cube(d)
    Ct = np.hstack([C, np.ones((len(C), 1))])
    yC = target(name, C)
    idx = rng.choice(len(C), size=n, replace=False)
    Xt, y = Ct[idx], yC[idx]
    lam = float(np.linalg.eigvalsh(Xt.T @ Xt / n)[-1])
    ynorm = math.sqrt((y ** 2).mean())
    W = rng.standard_normal((m, d + 1))
    W *= alpha / np.linalg.norm(W, axis=1, keepdims=True)
    a = alpha * rng.choice([-1.0, 1.0], m)
    eps = np.sign(a)
    rho0 = a ** 2 + (W ** 2).sum(1)
    P0 = rho0.sum()
    U0hat = U_hat(y, Xt)
    U0est = U_est(y, Xt, rng)
    # D0(g) merging law: same-sign pairs, Q_jk = a_j a_k - w_j . w_k (>= 0 for same sign under balance)
    same = [(j, k) for j in range(m) for k in range(j + 1, m) if eps[j] == eps[k]]
    pairs = np.array([same[i] for i in rng.choice(len(same), size=min(200, len(same)), replace=False)])
    pj, pk = pairs[:, 0], pairs[:, 1]
    Qhist = []
    mono_viol = 0.0                  # most negative (s_ij - s_ik)(hw_j - hw_k).xt_i seen (>= 0 required)
    rhs_attr_max = -1e300            # max of dQ/dt / Q (flow velocity) over attracting pairs (<= 0 required)
    clock = np.zeros(m)              # int eps_j U_r(hat w_j) dt
    intUhat = 0.0                    # int Uhat(r) dt
    intUC31 = 0.0                    # int sqrt(lam)|r|_n dt
    Uy_prev = None
    worst_mono = 0.0                 # most negative (eps U_y increment + lam/4 |f|^2 dt) seen
    worst_balance = 0.0
    grad_time = {0.3: np.zeros(m), 0.1: np.zeros(m)}  # time with |P xi^y| >= eta_q, per neuron
    int_f2 = 0.0
    rec = []
    steps = int(round(T / eta))
    L_prev = None
    loss_up = 0
    for k in range(steps + 1):
        t = k * eta
        Z = Xt @ W.T                      # n x m
        H = relu(Z)
        f = H @ a
        r = y - f
        L = 0.5 * (r ** 2).mean()
        if L_prev is not None and L > L_prev + 1e-15:
            loss_up += 1
        L_prev = L
        rho = a ** 2 + (W ** 2).sum(1)
        P = rho.sum()
        Wn = W / np.linalg.norm(W, axis=1, keepdims=True)
        Hn = relu(Xt @ Wn.T)
        Ur = Hn.T @ r / n                 # U_r(hat w_j)
        Uy = Hn.T @ y / n
        S = (Z > 0).astype(float)
        xi_y = (S * y[:, None]).T @ Xt / n
        Pxi = xi_y - (xi_y * Wn).sum(1, keepdims=True) * Wn
        gnorm = np.linalg.norm(Pxi, axis=1)
        fn = math.sqrt((f ** 2).mean())
        Uh = U_hat(r, Xt)
        worst_balance = max(worst_balance, float(np.abs(a ** 2 - (W ** 2).sum(1)).max() / max(rho.max(), 1e-300)))
        if Uy_prev is not None:
            inc = eps * (Uy - Uy_prev) + lam / 4 * fn_prev ** 2 * eta
            worst_mono = min(worst_mono, float(inc.min()))
        nw = np.linalg.norm(W, axis=1)
        Q = nw[pj] * nw[pk] - (W[pj] * W[pk]).sum(1)              # = a_j a_k - w_j.w_k under exact balance; >= 0
        Sd = S[:, pj] - S[:, pk]                                  # n x pairs, selection differences
        mi = Sd * ((Xt @ Wn[pj].T) - (Xt @ Wn[pk].T))            # (s_ij - s_ik)(hw_j - hw_k).xt_i
        mono_viol = min(mono_viol, float(mi.min()))
        shared = (Sd != 0).sum(0) == 0
        attracting = ((Sd != 0) * (eps[pj][None, :] * r[:, None] > 0)).sum(0) == 0
        # flow-velocity form of the merging law at the current iterate (balanced form of Lemma D0(g))
        xi = (S * r[:, None]).T @ Xt / n                          # m x (d+1): xi_j = <r, s_j xt>_n
        rhs = eps[pj] * nw[pj] * nw[pk] * ((xi[pj] - xi[pk]) * (Wn[pj] - Wn[pk])).sum(1)
        if attracting.any():
            rhs_attr_max = max(rhs_attr_max, float((rhs[attracting] / np.maximum(Q[attracting], 1e-300)).max()))
        if k % log_every == 0:
            if k > 0:
                Qhist.append((t, Qstart.copy(), Q.copy(), all_shared.copy(), all_attr.copy(), cosfloor.copy()))
            Qstart, all_shared, all_attr = Q.copy(), shared.copy(), attracting.copy()
            cosfloor = Q / (nw[pj] * nw[pk]) >= 1e-4
        else:
            all_shared &= shared; all_attr &= attracting
        if k % log_every == 0:
            rec.append(dict(t=t, L=L, P=P, fn=fn, clock_max=float(clock.max()), intUhat=intUhat, intUC31=intUC31,
                            lnrho_max=float(np.log(rho / rho0).max()), Uh=Uh, rho=rho.copy(), Wn=Wn.copy(),
                            Ur=Ur.copy(), f_cube=None))
        if k == steps:
            break
        # integrals (left Riemann sums)
        clock += eta * eps * Ur
        intUhat += eta * Uh
        intUC31 += eta * math.sqrt(lam) * math.sqrt((r ** 2).mean())
        int_f2 += eta * fn ** 2
        for q in grad_time:
            grad_time[q] += eta * (gnorm >= q)
        Uy_prev, fn_prev = Uy, fn
        # GD step
        ga = H.T @ r / n
        gW = ((S * r[:, None]).T @ Xt / n) * a[:, None]
        a = a + eta * ga
        W = W + eta * gW
    return dict(name=name, n=n, m=m, alpha=alpha, eta=eta, T=T, lam=lam, ynorm=ynorm, P0=P0, U0hat=U0hat,
                U0est=U0est, rec=rec, worst_mono=worst_mono, worst_balance=worst_balance, loss_up=loss_up,
                grad_time=grad_time, int_f2=int_f2, Xt=Xt, y=y, Ct=Ct, yC=yC, a=a, W=W, eps=eps, rho0=rho0,
                Qhist=Qhist, mono_viol=mono_viol, pairs=pairs, rhs_attr_max=rhs_attr_max)


def analyse(R, out, rng):
    pr = lambda *s: print(*s, file=out, flush=True)
    rec = R["rec"]
    lam, P0, U0hat, U0est, yn = R["lam"], R["P0"], R["U0hat"], R["U0est"], R["ynorm"]
    pr(f"\n=== target {R['name']}  n={R['n']}  m={R['m']}  alpha={R['alpha']:.0e}  eta={R['eta']}  T={R['T']} ===")
    pr(f"lam_X={lam:.4f}  |y|_n={yn:.4f}  P(0)={P0:.3e}  U0 certified upper bound={U0hat:.4f}  "
       f"multistart estimate={U0est:.4f}  sqrt(lam)|y|={math.sqrt(lam)*yn:.4f}")
    pr(f"D0: max |a^2-|w|^2|/max rho over run = {R['worst_balance']:.2e};  loss increased at {R['loss_up']} steps;"
       f"  worst (eps*dU_y + lam/4 |f|^2 dt) = {R['worst_mono']:.2e}  (>= 0 up to O(eta^2) required)")
    # D0 exact clock: ln rho_j(t)/rho_j(0) vs 2*clock_j  -> compare at the end
    rho_end = rec[-1]["rho"]
    # D1: growth bound, per neuron, with Uhat integral and with C3.1's integral
    worst_hat, worst_c31 = 0.0, 0.0
    for e in rec[1:]:
        worst_hat = max(worst_hat, e["lnrho_max"] / (2 * e["intUhat"]))
        worst_c31 = max(worst_c31, e["lnrho_max"] / (2 * e["intUC31"]))
    pr(f"D1(1): max_j,t ln(rho_j/rho_j0) / (2 int Uhat) = {worst_hat:.4f}   (<= 1 required; = 1 would be tight)")
    pr(f"       same with C3.1's sqrt(lam)|r|: {worst_c31:.4f}")
    # escape times for beta grid
    pr("D1(3): escape-time lower bound T_beta = ln(beta/P0) / (2 (U0hat + lam beta/2))  vs observed t_beta:")
    for beta in (1e-2, 1e-1, 0.5):
        tb = next((e["t"] for e in rec if e["P"] >= beta), None)
        Tb = math.log(beta / P0) / (2 * (U0hat + lam * beta / 2))
        Tb_est = math.log(beta / P0) / (2 * (U0est + lam * beta / 2))
        Tc31 = math.log(beta / P0) / (2 * (math.sqrt(lam) * yn + lam * beta / 2))
        pr(f"   beta={beta:<5} observed t_beta={tb}  T_beta(certified U)={Tb:.2f}  "
           f"T_beta(estimated U)={Tb_est:.2f}  T_beta(C3.1 U)={Tc31:.2f}")
    # D1.3 quantization (time with large tangential gradient) up to t_0.1
    t01 = next((e["t"] for e in rec if e["P"] >= 0.1), rec[-1]["t"])
    pr(f"D1.3: up to t_end, per neuron, time with |P xi^y| >= q:  q=0.3 max {R['grad_time'][0.3].max():.2f}, "
       f"q=0.1 max {R['grad_time'][0.1].max():.2f}   (bound (4 U0hat + lam int|f|^2)/q^2: "
       f"{(4*U0hat+lam*R['int_f2'])/0.09:.1f}, {(4*U0hat+lam*R['int_f2'])/0.01:.1f});  run length {R['T']}, t_0.1={t01}")
    # D2: path norm vs bounds
    pr("D2: path norm P(t) vs a priori bound beta+|y|^2 (t-T_beta)_+ (best beta) and loss-curve bound:")
    betas = np.geomspace(1e-3, 1.0, 31)
    Ls = np.array([e["L"] for e in rec]); ts = np.array([e["t"] for e in rec]); Ps = np.array([e["P"] for e in rec])
    worst_ap, worst_lc = 0.0, 0.0
    rows = []
    for i, e in enumerate(rec):
        t = e["t"]
        ap, lc = math.inf, math.inf
        for beta in betas:
            Tb = math.log(beta / P0) / (2 * (U0hat + lam * beta / 2))
            ap = min(ap, beta + yn ** 2 * max(0.0, t - Tb))
            # loss-curve: sqrt(P) <= sqrt(beta) + sum_k sqrt(dt_k dL_k) over the logged partition after Tb
            j0 = np.searchsorted(ts, Tb)
            if j0 >= i or Tb <= 0:
                lc = min(lc, beta if t <= Tb else math.inf)
                continue
            # first segment [Tb, ts[j0]] uses L(Tb) <= L(ts[j0-1]) (monotone)
            Lb = Ls[max(j0 - 1, 0)]
            segs = [(ts[j0] - Tb, Lb - Ls[j0])] + [(ts[k + 1] - ts[k], Ls[k] - Ls[k + 1]) for k in range(j0, i)]
            s = math.sqrt(beta) + sum(math.sqrt(max(dt, 0) * max(dl, 0)) for dt, dl in segs)
            lc = min(lc, s ** 2)
        worst_ap = max(worst_ap, e["P"] / ap)
        worst_lc = max(worst_lc, e["P"] / lc)
        rows.append((t, e["L"], e["P"], ap, lc))
    pick = np.unique(np.linspace(0, len(rows) - 1, 9).astype(int))
    for i in pick:
        t, L, P, ap, lc = rows[i]
        pr(f"   t={t:7.2f}  L={L:.4f}  P={P:.4f}  a-priori bound={ap:.3f}  loss-curve bound={lc:.3f}")
    pr(f"   worst P/a-priori = {worst_ap:.3f}, worst P/loss-curve = {worst_lc:.3f}  (<= 1 required)")
    # D2.2 generalization and exact test error at checkpoints
    Ct, yC, Xt, y = R["Ct"], R["yC"], R["Xt"], R["y"]
    boolean = set(np.unique(yC)) <= {-1.0, 1.0}
    pr("D2.2 (Maurey/Occam, Proved) at gamma in {0.25,0.5}, with P(t) measured and with the a priori bound; exact test:")
    b2 = 0.5 * (1.0 + lam)
    for i in pick:
        e = rec[i]
        Wn = e["Wn"]; rho = e["rho"]
        coef = R["eps"] * rho / 2
        fC = relu(Ct @ Wn.T) @ coef
        fS = relu(Xt @ Wn.T) @ coef
        if boolean:
            terr = float(np.mean(np.where(fC >= 0, 1, -1) != yC))
            bvals = []
            for g in (0.25, 0.5):
                em = float(np.mean(y * fS <= 2 * g))
                bvals.append((maurey_occam(e["P"], g, R["n"], em, b2), maurey_occam(rows[i][3], g, R["n"], em, b2)))
            pr(f"   t={e['t']:7.2f}  test err={terr:.4f}  train err={np.mean(np.where(fS>=0,1,-1)!=y):.4f}  "
               f"bound(gamma=.25) meas/apriori={bvals[0][0]:.3f}/{bvals[0][1]:.3f}  "
               f"bound(gamma=.5)={bvals[1][0]:.3f}/{bvals[1][1]:.3f}")
        else:
            pr(f"   t={e['t']:7.2f}  test MSE={np.mean((fC-yC)**2):.4f}  train MSE={np.mean((fS-y)**2):.4f}")
    # D0(g) merging law: over each logged interval, relative change of Q_jk by category
    Qh = R["Qhist"]
    cat = {"shared pattern throughout": [], "attracting, not shared": [], "other": []}
    for (t, Qs, Qe, sh, at, fl) in Qh:
        ok = (Qs > 1e-14) & fl
        rel = (Qe - Qs)[ok] / Qs[ok]
        sh, at = sh[ok], at[ok]
        cat["shared pattern throughout"] += list(rel[sh])
        cat["attracting, not shared"] += list(rel[at & ~sh])
        cat["other"] += list(rel[~at & ~sh])
    pr(f"D0(g): min over steps/pairs/points of (s_ij-s_ik)(hw_j-hw_k).xt_i = {R['mono_viol']:.2e} (>= 0 required);"
       f"  max of (flow dQ/dt)/Q over attracting pairs = {R['rhs_attr_max']:.2e} (<= 0 required)")
    pr("       GD trajectory, intervals with 1-cos >= 1e-4 at the start (below that, O(eta^2) terms dominate Q):")
    for c, v in cat.items():
        v = np.array(v)
        if len(v):
            pr(f"       relative change of Q_jk over {R['eta']*10:.2f}-intervals, {c}: count={len(v)}  "
               f"median={np.median(v):+.2e}  max={v.max():+.2e}  min={v.min():+.2e}")
    Qfirst, Qlast = Qh[0][1], Qh[-1][2]
    pr(f"       Q_jk median at t=0: {np.median(Qfirst):.2e}, at the end: {np.median(Qlast):.2e}")
    # D2.3 cluster Occam bound
    pr("D2.3 (K-neuron Occam with the network's own clusters, Proved; sup|f-g| exact on the cube):")
    if boolean:
        for i in pick:
            e = rec[i]
            val, K, hsup, B, arg = cluster_occam(e["Wn"], e["rho"], R["eps"], Ct, Xt, y, R["n"])
            fC = relu(Ct @ e["Wn"].T) @ (R["eps"] * e["rho"] / 2)
            terr = float(np.mean(np.where(fC >= 0, 1, -1) != yC))
            pr(f"   t={e['t']:7.2f}  K={K}  sup|f-g|={hsup:.2e}  B={B:.3f}  bound={val:.3f} "
               f"(gamma, ln|G|)={arg}  test err={terr:.4f}")
    # D3 plateau diagnostics at the last checkpoint and mid-run
    pr("D3 diagnostics (plateaus): grown neurons rho>=1e-2*max, clusters (cos>0.99), training-set margins, dormant growth")
    for i in pick[2:]:
        e = rec[i]
        rho = e["rho"]; Wn = e["Wn"]
        g = rho >= 1e-2 * rho.max()
        G = np.where(g)[0]
        # greedy clustering
        cl = []
        for j in G:
            for c in cl:
                if Wn[j] @ Wn[c[0]] > 0.99 and R["eps"][j] == R["eps"][c[0]]:
                    c.append(j); break
            else:
                cl.append([j])
        marg = np.abs(Xt @ Wn[G].T).min(0) / math.sqrt(d + 1) if len(G) else np.array([])
        nb = (np.abs(Xt @ Wn[G].T) < 1e-2 * math.sqrt(d + 1)).sum(0) if len(G) else np.array([])
        D = ~g
        # dormant mass growth rate over the next logged interval vs 2*Uhat
        if i + 1 < len(rec):
            e2 = rec[i + 1]
            PD1, PD2 = rho[D].sum(), e2["rho"][D].sum()
            rate = math.log(PD2 / PD1) / (e2["t"] - e["t"]) if PD1 > 0 else float("nan")
        else:
            rate = float("nan")
        spread = max((1 - min(Wn[j] @ Wn[c[0]] for j in c)) for c in cl) if cl else 0
        pr(f"   t={e['t']:7.2f}  grown={len(G)}  clusters={len(cl)} (sizes {[len(c) for c in cl]})  "
           f"min margin={marg.min() if len(marg) else float('nan'):.2e}  #pts within 1e-2 of a grown hyperplane "
           f"(max over grown)={nb.max() if len(nb) else 0}  dormant mass={rho[D].sum():.2e}  "
           f"dormant d/dt ln P_D={rate:.3f} vs 2 Uhat(r)={2*e['Uh']:.3f}  max cluster 1-cos={spread:.1e}")


def main():
    out = sys.stdout
    rng = np.random.default_rng(1)
    configs = [("x1", 1000, 64, 1e-3, 0.02, 40.0), ("maj3", 1000, 64, 1e-3, 0.02, 60.0),
               ("maj3", 1000, 64, 1e-6, 0.02, 90.0), ("x1+x2x3", 1000, 64, 1e-6, 0.02, 120.0),
               ("maj3", 4000, 64, 1e-6, 0.02, 60.0), ("x1+x2x3", 1000, 64, 1e-2, 0.02, 60.0),
               ("maj3", 1000, 64, 1e-3, 0.004, 20.0)]
    if len(sys.argv) > 1:
        configs = [configs[int(i)] for i in sys.argv[1].split(",")]
    for c in configs:
        R = run(*c)
        analyse(R, out, rng)


if __name__ == "__main__":
    main()

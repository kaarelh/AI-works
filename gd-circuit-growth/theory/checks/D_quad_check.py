"""D checks (Part II): two-layer quadratic network with centred units, i.e. symmetric matrix sensing on the cube.

f(x) = sum_j [(u_j.x)^2 - |u_j|^2] - sum_j [(v_j.x)^2 - |v_j|^2] = <X, x x^T - I>,  X = U U^T - V V^T,
U(0) = alpha U0, V(0) = alpha V0;  full-batch GD (and one minibatch SGD run) on L = (1/2)|y - f|_n^2.
On the cube <X, xx^T - I> = sum_{k != l} X_kl x_k x_l, so each hidden unit is a rank-one pairwise-interaction feature.

Checks, in the order of D-early-phase-theorem.md, Part II:
  DQ1   the log-det clock (discrete form, Horn): for every K,
           sum_{k<=K} ln s_k(U_T) <= sum_{k<=K} ln s_k(U_0) + sum_j sum_{k<=K} ln(1 + 2 eta lam_k(M_j)),
        and its linearised form with 2 eta sum_j sum_{k<=K} lam_k(M_j);  the same for V with -M_j.
  DQ2   rank bound  N_eps(t) <= kappa (tau(t) / Theta_eps)^2  (kappa = 2 lam_max(Phi^T Phi / n), inputs only),
        the clock form  N Theta_eps <= int Ky-Fan,  and the first-escape lower bound.
  DQ3   generalization (Proved), uniform in t: with the measured N_eps(t) and with the a priori kappa (tau/Theta)^2;
        against the unrestricted degree-2 sign class (Cover count) and the exact test error on all 2^16 points.
Runs in about a minute in total on one core.
"""
import math, sys, os
import numpy as np
sys.dont_write_bytecode = True
os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from c_common import klinv_upper, log_Phi  # noqa: E402

d = 16


def cube(d):
    idx = np.arange(2 ** d)[:, None]
    return 1.0 - 2.0 * ((idx >> np.arange(d)[None, :]) & 1)


def target(name, X):
    if name == "x1x2":
        return X[:, 0] * X[:, 1]
    if name == "majpairs":                       # MAJ(x1x2, x3x4, x5x6) = sgn(x1x2 + x3x4 + x5x6)
        return np.sign(X[:, 0] * X[:, 1] + X[:, 2] * X[:, 3] + X[:, 4] * X[:, 5])
    if name == "x1x2+.5x3x4":                    # real-valued: two stages
        return X[:, 0] * X[:, 1] + 0.5 * X[:, 2] * X[:, 3]
    raise ValueError(name)


def fvals(Xmat, X):
    return np.einsum("ik,kl,il->i", X, Xmat, X) - np.trace(Xmat)


def Mres(r, X):
    n = len(r)
    return (X * r[:, None]).T @ X / n - r.mean() * np.eye(X.shape[1])


def capacity_rank(K, B, gamma):
    """ln |G_{K,B,gamma}| of Theorem DQ3 (grid over rank-K matrices, sup error <= gamma/4)."""
    if K == 0:
        return 0.0
    eta_l = gamma / (8 * (d - 1) * K)
    eta_z = gamma / (16 * (d - 1) * (B + 1))
    return K * math.log(2 * math.ceil(B / eta_l) + 1) + d * K * math.log(1 + 2 / eta_z)


def bound_rank(K, P, gamma, emp, n, delta=0.05):
    B = 2.0 ** math.ceil(math.log2(max(P, 1e-12)))
    bexp = int(round(math.log2(B)))
    lnpi = math.log((K + 1) * (K + 2)) + math.log(2 * (abs(bexp) + 1) * (abs(bexp) + 2)) + math.log(2)  # |Gamma| = 2
    return klinv_upper(emp, (capacity_rank(K, B, gamma) + lnpi + math.log(1 / delta)) / n)


def bound_unrestricted(emp0, n, delta=0.05):
    # all sets {y <X, xx^T - I> <= 0}: affine threshold of (y x_k x_l)_{k<l} on at most 2^(d+1) points (Cover)
    D = d * (d - 1) // 2
    return klinv_upper(emp0, (log_Phi(2 ** (d + 1), D + 1) + math.log(1 / delta)) / n)


def run(name, n, h, alpha, eta, T, seed=0, batch=None, out=sys.stdout):
    pr = lambda *s: print(*s, file=out, flush=True)
    rng = np.random.default_rng(seed)
    C = cube(d)
    yC = target(name, C)
    idx = rng.choice(len(C), size=n, replace=False)
    X, y = C[idx], yC[idx]
    iu = np.triu_indices(d, 1)
    Phi = X[:, iu[0]] * X[:, iu[1]]
    kappa = 2 * float(np.linalg.eigvalsh(Phi.T @ Phi / n)[-1])
    U0 = rng.standard_normal((d, h)) / math.sqrt(d)
    V0 = rng.standard_normal((d, h)) / math.sqrt(d)
    s0 = max(np.linalg.norm(U0, 2), np.linalg.norm(V0, 2))
    U, V = alpha * U0, alpha * V0
    P0 = float((U ** 2).sum() + (V ** 2).sum())
    lsv0U = np.log(np.linalg.svd(U, compute_uv=False))
    lsv0V = np.log(np.linalg.svd(V, compute_uv=False))
    Ky = np.linalg.eigvalsh(Mres(y, X))
    U0star = max(Ky[-1], -Ky[0])
    boolean = set(np.unique(yC)) <= {-1.0, 1.0}
    steps = int(round(T / eta))
    clockU = np.zeros(d); clockV = np.zeros(d)          # sum_j ln(1 + 2 eta lam_k(+-M_j)), sorted desc, cumulative
    linU = np.zeros(d); linV = np.zeros(d)
    tau = 0.0
    kyfan = np.zeros(2 * d + 1)                          # int of best (K+K')-sum of |eig| split, for clock form
    worst_horn, worst_lin, worst_rank, worst_clock = -1e9, -1e9, 0.0, -1e9
    minres = d
    esc = {}
    eps_list = [1e-2, 1e-1]
    gam_list = [0.25, 0.5]
    pr(f"\n=== target {name}  n={n}  h={h}  alpha={alpha:.0e}  eta={eta}  T={T}  batch={batch} ===")
    pr(f"kappa = 2 lam_max(Phi^T Phi/n) = {kappa:.4f} (population 2);  s0 = {s0:.3f};  U0* = |M_y|_op = {U0star:.4f}")
    rows = []
    for k in range(steps + 1):
        t = k * eta
        Xm = U @ U.T - V @ V.T
        f = fvals(Xm, X)
        r = y - f
        L = 0.5 * (r ** 2).mean()
        sU = np.linalg.svd(U, compute_uv=False); sV = np.linalg.svd(V, compute_uv=False)
        # DQ1 checks at every step (cumulative)
        lhsU = np.cumsum(np.log(sU)); lhsV = np.cumsum(np.log(sV))
        # only K up to the numerically resolved singular values (s_K >= 1e-9 s_1; smaller ones are SVD round-off)
        KU = max(1, int((sU >= 1e-9 * sU[0]).sum())); KV = max(1, int((sV >= 1e-9 * sV[0]).sum()))
        worst_horn = max(worst_horn, float((lhsU - np.cumsum(lsv0U) - clockU)[:KU].max()),
                         float((lhsV - np.cumsum(lsv0V) - clockV)[:KV].max()))
        worst_lin = max(worst_lin, float((lhsU - np.cumsum(lsv0U) - linU)[:KU].max()),
                        float((lhsV - np.cumsum(lsv0V) - linV)[:KV].max()))
        minres = min(minres, KU, KV)
        for eps in eps_list:
            NU = int((sU ** 2 >= eps).sum()); NV = int((sV ** 2 >= eps).sum()); N = NU + NV
            Th = 0.25 * math.log(eps / (alpha ** 2 * s0 ** 2))
            if N > 0:
                worst_rank = max(worst_rank, N / (kappa * (tau / Th) ** 2))
                # clock form: N Theta <= int [sum_{k<=NU} lam_k(M) + sum_{k<=NV} lam_k(-M)] <= kyfan[N]
                worst_clock = max(worst_clock, N * Th - kyfan[N])
                if eps not in esc:
                    esc[eps] = (t, Th / (U0star + 2 * kappa * math.sqrt(d) * eps))
        if k % int(round(1.0 / eta)) == 0 or k == steps:
            rows.append((t, L, tau, Xm.copy(), sU.copy(), sV.copy(), (U ** 2).sum() + (V ** 2).sum(), f.copy()))
        if k == steps:
            break
        # gradient (full batch or minibatch)
        if batch is None:
            M = Mres(r, X)
        else:
            b = rng.choice(n, size=batch, replace=False)
            M = Mres(r[b], X[b])
        ev = np.linalg.eigvalsh(M)[::-1]                # descending
        clockU += np.cumsum(np.log1p(2 * eta * ev)); clockV += np.cumsum(np.log1p(-2 * eta * ev[::-1]))
        linU += 2 * eta * np.cumsum(ev); linV += 2 * eta * np.cumsum(-ev[::-1])
        # Ky Fan of the split: best sum of K largest |eig| with positive parts (for the clock form bound)
        pos = np.sort(np.maximum(ev, 0))[::-1]; neg = np.sort(np.maximum(-ev, 0))[::-1]
        both = np.sort(np.concatenate([pos, neg]))[::-1]
        kyfan[1:] += eta * np.cumsum(both)
        tau += eta * math.sqrt((r ** 2).mean()) if batch is None else eta * math.sqrt((r[b] ** 2).mean())
        U = U + 2 * eta * M @ U
        V = V - 2 * eta * M @ V
    pr(f"DQ1: max over t,K of [sum ln s_k(t) - sum ln s_k(0) - Horn clock] = {worst_horn:.2e} (<= 0 required);"
       f"  linearised clock: {worst_lin:.2e} (<= 0 required);  K checked up to the resolved rank (min {minres})")
    pr(f"DQ2: max over t,eps in {eps_list} of N_eps / (kappa (tau/Theta)^2) = {worst_rank:.3f} (<= 1 required for full batch; not claimed for SGD);"
       f"  max of N Theta - int KyFan_N = {worst_clock:.3f} (<= 0 required)")
    for eps, (te, lb) in esc.items():
        pr(f"     first time N_eps>=1 at eps={eps}: t={te:.2f}  lower bound Theta/(U0*+2 kappa sqrt(d) eps)={lb:.2f}")
    # DQ3 at checkpoints
    C2 = C
    pick = np.unique(np.linspace(0, len(rows) - 1, 8).astype(int))
    for i in pick:
        t, L, tau_t, Xm, sU, sV, P, fS = rows[i]
        fC = fvals(Xm, C2)
        line = f"   t={t:6.1f} L={L:.4f} tau={tau_t:.2f} P={P:.3f} sv^2(U)={np.round(sU[:3]**2,3)} sv^2(V)={np.round(sV[:3]**2,3)}"
        if boolean:
            terr = float(np.mean(np.where(fC >= 0, 1, -1) != yC))
            best_meas, best_ap, best_unr = 1.0, 1.0, 1.0
            for g in gam_list:
                eps = g / (8 * (d - 1))
                N = int((sU ** 2 >= eps).sum() + (sV ** 2 >= eps).sum())
                Th = 0.25 * math.log(eps / (alpha ** 2 * s0 ** 2))
                Nap = min(d * (d - 1), int(math.floor(kappa * (tau_t / Th) ** 2)))
                emp = float(np.mean(y * fS <= g))
                Pap = P0 + t * float((y ** 2).mean())  # P(t) <= P(0) + t |y|_n^2 (full batch)
                best_meas = min(best_meas, bound_rank(N, P, g, emp, n))
                best_ap = min(best_ap, bound_rank(max(N, Nap), Pap, g, emp, n))
            best_unr = bound_unrestricted(float(np.mean(y * fS <= 0)), n)
            line += f" | test err={terr:.4f} N(eps)={N} apriori N<={Nap} | DQ3 measured={best_meas:.3f} a-priori={best_ap:.3f} unrestricted={best_unr:.3f}"
        else:
            line += f" | test MSE={np.mean((fC-yC)**2):.4f}"
        pr(line)


def main():
    configs = [("x1x2", 300, 16, 1e-6, 0.01, 20.0), ("x1x2", 3000, 16, 1e-6, 0.01, 20.0),
               ("majpairs", 3000, 16, 1e-6, 0.01, 30.0), ("x1x2+.5x3x4", 1000, 16, 1e-6, 0.01, 40.0),
               ("majpairs", 3000, 16, 1e-6, 0.01, 30.0, 0, 64)]
    if len(sys.argv) > 1:
        configs = [configs[int(i)] for i in sys.argv[1].split(",")]
    for c in configs:
        run(*c)


if __name__ == "__main__":
    main()

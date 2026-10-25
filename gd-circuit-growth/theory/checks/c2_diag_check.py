"""C2 checks: diagonal linear network over the degree-<=k characters of {-1,1}^d.

f_w(x) = sum_S w_S chi_S(x),  w = u*u - v*v,  u(0) = v(0) = alpha*1,  gradient flow on L(w) = (1/2n)|Xw - y|^2.
We integrate (u, v) together with G = int grad, tau = int |r|_n, A2 = int |g|_2 and R = int r, and check
  closed form   w(t) = -2 alpha^2 sinh(4 G(t))                                    (Lemma C2.1)
  (a)           first escape time of level eps in [Theta/(U+D_eps), Theta/(U-D_eps)], and tau >= Theta   (Thm C2.2)
  (b)           N_eps(t) <= (int|g|_2)^2/Theta^2  and  N_eps(t) <= kappa_B tau^2/Theta^2,  identity
                sum_S |w_S||G_S| = <R(t), f_t>_n                                    (Thm C2.3)
  (c)           err(sgn f_t) <= klinv(P_S[y f_t <= 2 mu_eps], (l_N + log((N+1)(N+2)/delta))/n)     (Thm C2.4)
                and the a priori version (Cor C2.5).
Test errors are exact (all 2^d inputs).  Runs in about a minute on one core.
"""
import itertools, math, sys, json, os
import numpy as np
from scipy.integrate import solve_ivp
from scipy.optimize import brentq
sys.dont_write_bytecode = True
import c_common as cc

d, k = 10, 3
DELTA = 0.05
SETS = [S for j in range(k + 1) for S in itertools.combinations(range(d), j)]
Dsz = len(SETS)
CUBE = np.array(list(itertools.product([-1.0, 1.0], repeat=d)))


def chars(X):
    C = np.ones((len(X), Dsz))
    for j, S in enumerate(SETS):
        for i in S:
            C[:, j] *= X[:, i]
    return C


CHI_CUBE = chars(CUBE)
TARGETS = {
    "par2": lambda X: X[:, 0] * X[:, 1],
    "maj3": lambda X: np.sign(X[:, 0] + X[:, 1] + X[:, 2]),
    "and3": lambda X: np.where((X[:, 0] > 0) & (X[:, 1] > 0) & (X[:, 2] > 0), 1.0, -1.0),
    "maj5": lambda X: np.sign(X[:, :5].sum(1)),
    "par4": lambda X: X[:, 0] * X[:, 1] * X[:, 2] * X[:, 3],
}


def ell_N(N):
    """log |A_N|: supports (log C(D,N)) times affine threshold sets of <= 2^min(N, d+1) points in R^N."""
    return cc.log_binom(Dsz, N) + cc.log_Phi(2 ** min(N, d + 1), N)


def L_N(N, n):
    return (ell_N(N) + math.log((N + 1) * (N + 2) / DELTA)) / n


def run(name, n, alpha, seed, t_max=60.0, n_grid=601, mode="uv", t_print=(2, 4, 6, 8, 10, 15, 20, 30, 45, 60)):
    """mode 'uv': integrate (u, v) and verify the closed form.  mode 'G': integrate the mirror form
    dG/dt = grad L(w(G)), w(G) = -2 alpha^2 sinh(4G) (valid by Lemma C2.1; used for tiny alpha)."""
    rng = np.random.default_rng(seed)
    X = rng.choice([-1.0, 1.0], size=(n, d))
    y = TARGETS[name](X)
    C = chars(X)
    Kfull = C.T @ C / n
    lam_full = float(np.linalg.eigvalsh(Kfull)[-1])
    y_cube = TARGETS[name](CUBE)
    D = Dsz
    a2 = alpha ** 2

    if mode == "uv":
        off = 2 * D

        def wof(z):
            return z[:D] ** 2 - z[D:2 * D] ** 2

        def rhs(t, z):
            u, v = z[:D], z[D:2 * D]
            r = y - C @ (u * u - v * v)
            g = -(C.T @ r) / n
            return np.concatenate([-2 * u * g, 2 * v * g, g, [math.sqrt(np.mean(r * r)), np.linalg.norm(g)], r])

        z0 = np.concatenate([alpha * np.ones(D), alpha * np.ones(D), np.zeros(D), [0.0, 0.0], np.zeros(n)])
    else:
        off = 0

        def wof(z):
            return -2 * a2 * np.sinh(4 * z[:D])

        def rhs(t, z):
            r = y - C @ wof(z)
            g = -(C.T @ r) / n
            return np.concatenate([g, [math.sqrt(np.mean(r * r)), np.linalg.norm(g)], r])

        z0 = np.zeros(D + 2 + n)
    ts = np.linspace(0, t_max, n_grid)
    sol = solve_ivp(rhs, (0, t_max), z0, t_eval=ts, method="DOP853", rtol=1e-10, atol=1e-14, dense_output=True)
    assert sol.success, sol.message
    Z = sol.y.T
    G = Z[:, off:off + D]
    tau, A2, R = Z[:, off + D], Z[:, off + D + 1], Z[:, off + D + 2:]
    W = np.array([wof(z) for z in Z])
    out = dict(name=name, n=n, alpha=alpha, seed=seed, D=D, lam_full=lam_full, mode=mode)
    if mode == "uv":
        u, v = Z[:, :D], Z[:, D:2 * D]
        Wcf = -2 * a2 * np.sinh(4 * G)
        out["closed_form_relerr"] = float(np.max(np.abs(W - Wcf) / np.maximum(np.abs(W), a2)))
        out["uv_const_relerr"] = float(np.max(np.abs(u * v - a2)) / a2)
    # (a) first escape
    U0 = float(np.max(np.abs(C.T @ y) / n))
    esc = []
    for eps in [1e-4, 1e-3, 1e-2, 1e-1]:
        Th = 0.25 * math.asinh(eps / (2 * a2))
        idx = np.where(np.max(np.abs(W), 1) >= eps)[0]
        if len(idx) == 0:
            continue
        i = idx[0]

        def gap(tt):
            return float(np.max(np.abs(wof(sol.sol(tt))))) - eps
        t_cross = brentq(gap, ts[i - 1], ts[i], xtol=1e-13)
        Deps = min(D * eps, math.sqrt(lam_full * D) * eps)
        lo = Th / (U0 + Deps)
        hi = Th / (U0 - Deps) if U0 > Deps else math.inf
        tau_c = float(sol.sol(t_cross)[off + D])
        esc.append(dict(eps=eps, Theta=Th, t_cross=float(t_cross), lower=lo, upper=hi, tau_at_cross=tau_c,
                        ok=bool(lo <= t_cross * (1 + 1e-9) and t_cross <= hi * (1 + 1e-9)
                                and tau_c >= Th * (1 - 1e-9))))
    out["escape"] = esc
    # (b), (c)
    rows = []
    ok_b1 = ok_b2 = True
    worst_b2 = 0.0
    ident_err = 0.0
    Koff = Kfull - np.diag(np.diag(Kfull))
    mu_coh = float(np.max(np.abs(Koff)))
    for it in range(0, n_grid):
        t = ts[it]
        w = W[it]
        f_tr = C @ w
        lhs = float(np.sum(np.abs(w) * np.abs(G[it])))
        rhs_id = float(np.mean(R[it] * f_tr))
        ident_err = max(ident_err, abs(lhs - rhs_id) / (abs(rhs_id) + 1e-9))
        eps_grid = [10.0 ** e for e in np.arange(-6, 0.01, 0.25)]
        printing = any(abs(t - tp) < 1e-9 for tp in t_print)
        if not printing and it % 10:
            continue
        best = None
        for eps in eps_grid:
            Th = 0.25 * math.asinh(eps / (2 * a2))
            B = np.where(np.abs(w) >= eps)[0]
            N = len(B)
            b1 = A2[it] ** 2 / Th ** 2
            kap = float(np.linalg.eigvalsh(C[:, B].T @ C[:, B] / n)[-1]) if N > 0 else 1.0
            b2 = kap * tau[it] ** 2 / Th ** 2
            ok_b1 &= N <= b1 * (1 + 1e-6)
            ok_b2 &= N <= b2 * (1 + 1e-6)  # (b2) is tight for a single-character target
            if N > 0:
                worst_b2 = max(worst_b2, N / b2)
            mu = float(np.sum(np.abs(w[np.abs(w) < eps])))
            phat = float(np.mean(y * f_tr <= 2 * mu))
            bnd = cc.klinv_upper(phat, L_N(N, n))
            if best is None or bnd < best["bound"]:
                best = dict(eps=eps, N=N, mu=mu, phat=phat, bound=bnd, kappa=kap, b1=b1, b2=b2)
        if not printing:
            continue
        f_cube = CHI_CUBE @ w
        # a priori version (Cor C2.5), gamma = 1/2, eps = gamma/(2D)
        gam = 0.5
        eps_g = gam / (2 * D)
        Th = 0.25 * math.asinh(eps_g / (2 * a2))
        x = (tau[it] / Th) ** 2
        N_gersh = int(math.floor((1 - mu_coh) * x / (1 - mu_coh * x))) if mu_coh * x < 1 else None
        Bg = np.where(np.abs(w) >= eps_g)[0]
        kapg = float(np.linalg.eigvalsh(C[:, Bg].T @ C[:, Bg] / n)[-1]) if len(Bg) else 1.0
        N_kap = int(math.floor(kapg * x))
        phat_g = float(np.mean(y * f_tr <= gam))
        ap_g = cc.klinv_upper(phat_g, L_N(min(N_gersh, Dsz), n)) if N_gersh is not None else 1.0
        ap_k = cc.klinv_upper(phat_g, L_N(min(N_kap, Dsz), n))
        rows.append(dict(t=float(t), tau=float(tau[it]), train_loss=float(0.5 * np.mean((y - f_tr) ** 2)),
                         train_err=float(np.mean(y * f_tr <= 0)), test_err=float(np.mean(y_cube * f_cube <= 0)),
                         l1=float(np.sum(np.abs(w))), N_1e2=int(np.sum(np.abs(w) >= 1e-2)), N_eps_g=int(len(Bg)),
                         best=best, apriori_N_gersh=N_gersh, apriori_gersh=ap_g, apriori_N_kappa=N_kap,
                         apriori_kappa=ap_k, phat_gamma=phat_g))
    out.update(rows=rows, ok_b1=bool(ok_b1), ok_b2=bool(ok_b2), worst_ratio_b2=worst_b2, identity_relerr=ident_err,
               mu_coh=mu_coh, U0=U0)
    return out


def report(r):
    print(f"== {r['name']} n={r['n']} alpha={r['alpha']:.0e} mode={r['mode']} D={r['D']} lam_max(K)={r['lam_full']:.2f}"
          f" coherence mu={r['mu_coh']:.3f} U0=max|<y,chi>|={r['U0']:.3f}")
    if r["mode"] == "uv":
        print(f"   closed form w = -2a^2 sinh(4G): max rel.err {r['closed_form_relerr']:.1e}; u*v = a^2: rel.err "
              f"{r['uv_const_relerr']:.1e}")
    print(f"   identity sum|w||G| = <R,f>_n: max rel.err {r['identity_relerr']:.1e}; (b1) holds: {r['ok_b1']}; "
          f"(b2) holds: {r['ok_b2']} (max N/bound = {r['worst_ratio_b2']:.2f})")
    for e in r["escape"]:
        print(f"   (a) eps={e['eps']:.0e}: Theta_eps={e['Theta']:.3f}  first escape t={e['t_cross']:.4f}  bracket "
              f"[{e['lower']:.4f}, {e['upper']:.4f}]  tau(t)={e['tau_at_cross']:.4f} >= Theta: ok={e['ok']}")
    print("      t    tau   loss   train  test  N(1e-2) |w|_1 | C2.4: eps     N   mu     P_S[yf<=2mu] bound | "
          "C2.5 (gamma=.5): P_S[yf<=.5] N_gersh bound  N_kappa bound")
    for row in r["rows"]:
        b = row["best"]
        print(f"   {row['t']:5.1f} {row['tau']:6.2f} {row['train_loss']:.4f} {row['train_err']:.3f} {row['test_err']:.3f}"
              f" {row['N_1e2']:5d} {row['l1']:6.2f} |  {b['eps']:.0e} {b['N']:4d} {b['mu']:.4f}  {b['phat']:.3f}  "
              f"{b['bound']:.3f} |  {row['phat_gamma']:.3f}  {row['apriori_N_gersh']}  {row['apriori_gersh']:.3f}  "
              f"{row['apriori_N_kappa']}  {row['apriori_kappa']:.3f}")
    sys.stdout.flush()


def main():
    res = []
    jobs = [("par2", 100, 1e-3, "uv", 60), ("maj3", 100, 1e-3, "uv", 60), ("maj3", 400, 1e-3, "uv", 60),
            ("and3", 400, 1e-3, "uv", 60), ("maj5", 100, 1e-3, "uv", 60), ("par4", 100, 1e-3, "uv", 60),
            ("par2", 100, 1e-8, "G", 60), ("maj3", 400, 1e-8, "G", 60), ("and3", 400, 1e-8, "G", 60),
            ("maj5", 100, 1e-8, "G", 60)]
    for name, n, alpha, mode, tmax in jobs:
        r = run(name, n, alpha, seed=0, mode=mode, t_max=tmax)
        res.append(r)
        report(r)
    with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "c2_diag_check.json"), "w") as fh:
        json.dump(res, fh, indent=1)


if __name__ == "__main__":
    main()

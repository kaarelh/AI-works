"""C3 checks: no-growth-before-escape bounds for ReLU nets from small initialization (Lemmas C3.1, C3.2).

Two-layer, f(x) = sum_j a_j relu(w_j . xt), xt = (x, 1), full-batch GD with step eta on (1/2)|y - f|_n^2:
  Lemma C3.1 (discrete form): rho_j = a_j^2 + |w_j|^2 satisfies
        rho_j(k+1) <= rho_j(k) (1 + eta Ubar_k)^2,   Ubar_k = sqrt(lam_X) |r_k|_n,
  hence rho_j(K) <= rho_j(0) exp(2 sqrt(lam_X) tau_K), tau_K = eta sum_k |r_k|_n.
Deep bias-free (constant input), L layers, gradient flow approximated by GD with small step:
  Lemma C3.2: Q(t) = max_l |W_l(0)|_F^2 + Delta(t) obeys Q^(1-L/2) >= Q0^(1-L/2) - (L-2) sqrt(lam_X) tau(t),
  so |f|_n <= sqrt(lam_X) Q^(L/2) stays tiny until tau >= Q0^(-(L-2)/2) / (2 (L-2) sqrt(lam_X)).
We report the worst ratio (observed / bound) for C3.1 and, for C3.2, the observed escape time against the bound.
"""
import math, sys, json, os
import numpy as np
sys.dont_write_bytecode = True

d = 10


def data(name, n, rng):
    X = rng.choice([-1.0, 1.0], size=(n, d))
    if name == "maj3":
        y = np.sign(X[:, :3].sum(1))
    elif name == "par2":
        y = X[:, 0] * X[:, 1]
    else:
        y = X[:, 0]
    return np.hstack([X, np.ones((n, 1))]), y


def two_layer(name, n=200, m=64, alpha=1e-3, eta=0.02, K=40000, seed=0, balanced=True):
    rng = np.random.default_rng(seed)
    Xt, y = data(name, n, rng)
    lamX = float(np.linalg.eigvalsh(Xt.T @ Xt / n)[-1])
    W = alpha * rng.standard_normal((m, d + 1)) / math.sqrt(d + 1)
    a = (np.linalg.norm(W, axis=1) * rng.choice([-1, 1], m)) if balanced else alpha * rng.standard_normal(m)
    rho0 = a ** 2 + (W ** 2).sum(1)
    logprod = 0.0
    tau = 0.0
    worst_step, worst_cum = 0.0, 0.0
    esc_t = None
    L0 = 0.5 * np.mean(y ** 2)
    for k in range(K):
        Z = Xt @ W.T
        H = np.maximum(Z, 0)
        f = H @ a
        r = y - f
        rn = math.sqrt(np.mean(r * r))
        Ub = math.sqrt(lamX) * rn
        A = H.T @ r / n                      # -dL/da_j
        V = ((Z > 0) * r[:, None]).T @ Xt / n  # rows: <r, s_j xt>_n
        rho = a ** 2 + (W ** 2).sum(1)
        a_new = a + eta * A
        W_new = W + eta * a[:, None] * V
        rho_new = a_new ** 2 + (W_new ** 2).sum(1)
        worst_step = max(worst_step, float(np.max(rho_new / (rho * (1 + eta * Ub) ** 2))))
        logprod += 2 * math.log(1 + eta * Ub)
        tau += eta * rn
        worst_cum = max(worst_cum, float(np.max(np.log(rho_new / rho0)) / (2 * math.sqrt(lamX) * tau)))
        a, W = a_new, W_new
        if esc_t is None and 0.5 * rn ** 2 < 0.99 * L0:
            esc_t = (k + 1) * eta
    # escape lower bound: |f|_n <= (sqrt(lamX)/2) sum rho_j  <=  eps   until  tau >= log(2 eps/(sqrt(lamX) sum rho0))/(2 sqrt lamX)
    # loss drops by 1% only once |f|_n >= |y|_n - sqrt(0.99)|y|_n ~ 0.005: take eps = 0.005
    eps = (1 - math.sqrt(0.99)) * math.sqrt(np.mean(y ** 2))
    t_lb = math.log(2 * eps / (math.sqrt(lamX) * rho0.sum())) / (2 * math.sqrt(lamX))
    U0 = None
    return dict(name=name, n=n, m=m, alpha=alpha, eta=eta, balanced=balanced, lamX=lamX,
                worst_step_ratio=worst_step, worst_cum_ratio=worst_cum, escape_time=esc_t, escape_lower=t_lb,
                final_loss=0.5 * rn ** 2)


def deep(name, L=3, n=256, m=32, alpha=0.1, eta=0.02, K=60000, seed=0, eps_f=0.1):
    """GD on a bias-free L-layer ReLU net (constant input coordinate).  'Escape' = first time |f|_n >= eps_f.
    Lemma C3.2 gives |f|_n <= sqrt(lamX) Q^(L/2) with Q^(1-L/2) >= Q0^(1-L/2) - (L-2) sqrt(lamX) tau, hence
    tau(escape) >= [Q0^(1-L/2) - (eps_f/sqrt(lamX))^(-(L-2)/L)] / ((L-2) sqrt(lamX))."""
    rng = np.random.default_rng(seed)
    Xt, y = data(name, n, rng)
    lamX = float(np.linalg.eigvalsh(Xt.T @ Xt / n)[-1])
    dims = [d + 1] + [m] * (L - 1) + [1]
    Ws = [alpha * rng.standard_normal((dims[l + 1], dims[l])) / math.sqrt(dims[l]) for l in range(L)]
    q0 = [float((Wl ** 2).sum()) for Wl in Ws]
    Q0 = max(q0)
    tau = 0.0
    esc = None
    worst = 0.0
    f0 = None
    for k in range(K):
        hs, zs = [Xt], []
        for l in range(L):
            z = hs[-1] @ Ws[l].T
            zs.append(z)
            hs.append(np.maximum(z, 0) if l < L - 1 else z)
        f = hs[-1][:, 0]
        fn = math.sqrt(np.mean(f * f))
        if f0 is None:
            f0 = fn
        r = y - f
        rn = math.sqrt(np.mean(r * r))
        Q = Q0 + max(float((Wl ** 2).sum()) - ql for Wl, ql in zip(Ws, q0))
        rhs = Q0 ** (1 - L / 2) - (L - 2) * math.sqrt(lamX) * tau
        worst = max(worst, rhs / Q ** (1 - L / 2))
        if fn >= eps_f:
            esc = dict(t=k * eta, tau=tau)
            break
        b = -r[:, None] / n
        grads = [None] * L
        for l in reversed(range(L)):
            grads[l] = b.T @ hs[l]
            if l > 0:
                b = (b @ Ws[l]) * (zs[l - 1] > 0)
        for l in range(L):
            Ws[l] = Ws[l] - eta * grads[l]
        tau += eta * rn
    tau_lb = (Q0 ** (1 - L / 2) - (eps_f / math.sqrt(lamX)) ** (-(L - 2) / L)) / ((L - 2) * math.sqrt(lamX))
    return dict(name=name, L=L, n=n, m=m, alpha=alpha, eta=eta, lamX=lamX, Q0=Q0, f0=f0, escape=esc,
                tau_lower=tau_lb, worst_comparison_ratio=worst)


def main():
    out = []
    for name in ["maj3", "par2"]:
        for alpha in [1e-2, 1e-4]:
            for bal in [True, False]:
                r = two_layer(name, alpha=alpha, balanced=bal, K=20000)
                out.append(r)
                print(f"2-layer {name} alpha={alpha:.0e} balanced={bal}: lam_X={r['lamX']:.3f}  max step ratio "
                      f"rho'/(rho(1+eta U)^2) = {r['worst_step_ratio']:.4f} (<=1)  max log(rho/rho0)/(2 sqrt(lam) tau) = "
                      f"{r['worst_cum_ratio']:.3f} (<=1)  escape t={r['escape_time']}  lower bound {r['escape_lower']:.2f}"
                      f"  final loss {r['final_loss']:.3f}", flush=True)
    for L, alpha, eta, K in [(3, 0.03, 0.02, 100000), (3, 0.01, 0.02, 100000), (3, 0.003, 0.02, 200000),
                             (4, 0.2, 0.02, 100000), (4, 0.1, 0.02, 200000)]:
        r = deep("maj3", L=L, alpha=alpha, eta=eta, K=K)
        out.append(r)
        e_ = r["escape"]
        print(f"deep L={L} maj3 alpha={alpha}: lam_X={r['lamX']:.3f} Q0={r['Q0']:.2e} |f(0)|_n={r['f0']:.1e}  "
              f"escape (|f|_n>=0.1) at t={e_['t'] if e_ else None} tau={e_['tau'] if e_ else float('nan'):.2f};  "
              f"Lemma C3.2: tau >= {r['tau_lower']:.2f}  (ratio {e_['tau'] / r['tau_lower'] if e_ and r['tau_lower'] > 0 else float('nan'):.1f});"
              f" max comparison ratio {r['worst_comparison_ratio']:.4f} (<=1)", flush=True)
    with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "c3_gronwall_check.json"), "w") as fh:
        json.dump(out, fh, indent=1)


if __name__ == "__main__":
    main()

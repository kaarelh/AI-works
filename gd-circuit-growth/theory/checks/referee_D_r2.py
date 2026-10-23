"""Round-2 referee checks for D-early-phase-theorem.md (single-threaded; about a minute on one core).

S1  Theorem D2(6): the explicit instance (y = x1 on the full cube, one balanced neuron at v* = (e1+e0)/sqrt2,
    selection s = 0 on the kink {x1 = -1}). Integrate the selection flow (RK4), compare P(t) and t_beta with the
    closed forms, check U0* = 1/sqrt2 by multistart, and compare t_beta with (a) item 3's T_beta and (b) the
    sharper lower bound max_{P(0) < beta' <= beta} T_beta' that item 3 gives through monotonicity of t_beta in beta.
S2  Theorem D6(5), path norm with no step-size condition: GD and SGD with large steps on random cube data;
    check P_J <= exp(4 eta^2 sum |M_j|^2)(P0 + eta sum |y|_Bj^2) and its kappa_B form, and that the flow bound
    P <= P0 + t|y|^2 can fail.
S3  Section 7.4 replayed (same seeds as D_quad_check.py, configs 1, 2, 4): the step-size condition 2 eta |M_j| < 1
    along the runs; the D6(5) GD path-norm bound B_GD; the D7 'weight-free' numbers recomputed with the PROVED
    GD norm bound instead of the flow bound; for SGD the proved D6(5) rank form with kappa_Bj and the proved
    SGD analogue of the first-growth bound D6(3).
S4  Numbers quoted in the D7 'Comparison', the time-only rank bound (N <= 42), and the D3.3 capacity remark.
"""
import math, os, sys, time
os.environ["OPENBLAS_NUM_THREADS"] = "1"
os.environ["OMP_NUM_THREADS"] = "1"
import numpy as np
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from c_common import klinv_upper, log_Phi  # noqa: E402
import D_quad_check as Q  # noqa: E402  (functions only; main() is guarded)

T0 = time.time()
pr = lambda *s: print(*s, flush=True)
relu = lambda z: np.maximum(z, 0.0)


def cube(d):
    idx = np.arange(2 ** d)[:, None]
    return 1.0 - 2.0 * ((idx >> np.arange(d)[None, :]) & 1)


# ---------------------------------------------------------------- S1
def S1():
    pr(f"\n=== S1 Theorem D2(6): explicit instance, closed form, and the leading constant  [{time.time()-T0:.0f}s]")
    d = 6
    X = cube(d)
    Xt = np.hstack([X, np.ones((len(X), 1))])           # bias coordinate e0 is the last one
    n = len(X)
    y = X[:, 0].copy()
    lamX = float(np.linalg.eigvalsh(Xt.T @ Xt / n)[-1])
    vstar = np.zeros(d + 1); vstar[0] = vstar[-1] = 1 / math.sqrt(2)
    Uy = lambda v: float(np.mean(y * relu(Xt @ v)))
    # multistart projected (sub)gradient ascent of |U_y| on the sphere
    rng = np.random.default_rng(5)
    best = 0.0
    for sgn in (1, -1):
        for _ in range(200):
            v = rng.standard_normal(d + 1); v /= np.linalg.norm(v)
            for _ in range(300):
                z = Xt @ v
                g = sgn * (Xt * (y * (z > 0))[:, None]).mean(0)
                g -= (g @ v) * v
                v = v + 0.2 * g; v /= np.linalg.norm(v)
            best = max(best, sgn * Uy(v))
    pr(f"   d={d}: lambda_X = {lamX:.6f} (claim 1);  U_y(v*) = {Uy(vstar):.6f};  multistart sup|U_y| = {best:.6f};  1/sqrt2 = {1/math.sqrt(2):.6f}")
    U0 = 1 / math.sqrt(2)

    def rhs(a, w):
        z = Xt @ w
        f = a * relu(z)
        r = y - f
        s = (z > 0).astype(float)                       # sigma'(0) = 0 at the kink
        adot = float(np.mean(r * relu(z)))
        xi = (Xt * (r * s)[:, None]).mean(0)
        return adot, a * xi

    pr("   alpha     max|P_RK4 - P_closed|/P   t_beta(RK4)  t_beta(closed)  T_beta(item 3)  max_{b'<=b} T_b'   ratios t_b*U0/ln(1/a), T_b*U0/ln(1/a), maxT*U0/ln(1/a)   kink |w.x| max, off-v* drift")
    beta = 0.5
    for alpha in (1e-1, 1e-2, 1e-4, 1e-8):
        a = alpha; w = alpha * vstar.copy()
        P0 = 2 * alpha ** 2
        h = 1e-3; t = 0.0; tb = None; maxerr = 0.0; maxkink = 0.0
        Tend = 1.5 * math.log(beta / P0) / (2 * U0) + 5
        while t < Tend:
            k1 = rhs(a, w); k2 = rhs(a + h / 2 * k1[0], w + h / 2 * k1[1])
            k3 = rhs(a + h / 2 * k2[0], w + h / 2 * k2[1]); k4 = rhs(a + h * k3[0], w + h * k3[1])
            a_new = a + h / 6 * (k1[0] + 2 * k2[0] + 2 * k3[0] + k4[0])
            w_new = w + h / 6 * (k1[1] + 2 * k2[1] + 2 * k3[1] + k4[1])
            Pold = a * a + w @ w
            a, w = a_new, w_new; t += h
            P = a * a + w @ w
            Pc = math.sqrt(2) / (1 + (math.sqrt(2) / P0 - 1) * math.exp(-math.sqrt(2) * t))
            maxerr = max(maxerr, abs(P - Pc) / Pc)
            maxkink = max(maxkink, float(np.abs(Xt[X[:, 0] < 0] @ w).max()))
            if tb is None and P >= beta:
                tb = t - h * (P - beta) / (P - Pold)
        tb_closed = math.log(beta / P0) / (2 * U0) + (1 / math.sqrt(2)) * math.log((math.sqrt(2) - P0) / (math.sqrt(2) - beta))
        Tb = math.log(beta / P0) / (2 * (U0 + lamX * beta / 2))
        bs = np.exp(np.linspace(math.log(P0 * 1.0001), math.log(beta), 4000))
        Tmax = float(np.max(np.log(bs / P0) / (2 * (U0 + lamX * bs / 2))))
        L = math.log(1 / alpha) / U0
        drift = float(np.linalg.norm(w / np.linalg.norm(w) - vstar))
        pr(f"   {alpha:7.0e}   {maxerr:.2e}                 {tb:9.4f}    {tb_closed:9.4f}      {Tb:9.4f}       {Tmax:9.4f}          {tb/L:.4f}, {Tb/L:.4f}, {Tmax/L:.4f}                  {maxkink:.1e}, {drift:.1e}")
    pr("   item 3 at fixed beta has limit U0/(U0+lam beta/2) = %.4f (beta=0.5); the monotone version max_{beta'<=beta} T_beta' tends to 1," % (U0 / (U0 + lamX * beta / 2)))
    pr("   so liminf t_beta U0*/ln(1/alpha) >= 1 for every flow, and the instance attains 1: the constant 1/U0* itself is sharp at every fixed beta.")


# ---------------------------------------------------------------- S2
def S2():
    pr(f"\n=== S2 Theorem D6(5): path norm for GD/SGD with no step-size condition  [{time.time()-T0:.0f}s]")
    d, n, h = 8, 200, 8
    rng = np.random.default_rng(21)
    C = cube(d)
    X = C[rng.choice(len(C), n, replace=False)]
    y = np.sign(X[:, 0] * X[:, 1] + X[:, 2] * X[:, 3] + X[:, 4] + 0.1)
    iu = np.triu_indices(d, 1)

    def kap(Xb):
        Phi = Xb[:, iu[0]] * Xb[:, iu[1]]
        G = Phi @ Phi.T / len(Xb)                      # same nonzero spectrum as Phi^T Phi / n
        return 2 * float(np.linalg.eigvalsh(G)[-1])
    for mode, eta, batch, scale in (("gd", 0.05, None, 0.3), ("gd", 0.2, None, 0.5), ("sgd", 0.05, 16, 0.3), ("sgd", 0.15, 8, 0.5)):
        U = scale * rng.standard_normal((d, h)) / math.sqrt(d); V = scale * rng.standard_normal((d, h)) / math.sqrt(d)
        P0 = float((U ** 2).sum() + (V ** 2).sum())
        S_M2 = 0.0; S_y2 = 0.0; S_k = 0.0
        worst, worst_k, flow_fail, max2eM = -1e9, -1e9, 0, 0.0
        P = P0
        for j in range(400):
            Xm = U @ U.T - V @ V.T
            f = Q.fvals(Xm, X); r = y - f
            b = np.arange(n) if batch is None else rng.choice(n, batch, replace=False)
            M = Q.Mres(r[b], X[b])
            nM = float(np.abs(np.linalg.eigvalsh(M)).max())
            max2eM = max(max2eM, 2 * eta * nM)
            kB = kap(X[b])
            S_M2 += nM ** 2; S_y2 += float((y[b] ** 2).mean()); S_k += kB * float((r[b] ** 2).mean())
            U = U + 2 * eta * M @ U; V = V - 2 * eta * M @ V
            P = float((U ** 2).sum() + (V ** 2).sum())
            if not np.isfinite(P) or P > 1e12:
                break
            bnd = math.exp(min(700, 4 * eta ** 2 * S_M2)) * (P0 + eta * S_y2)
            bndk = math.exp(min(700, 4 * eta ** 2 * S_k)) * (P0 + eta * S_y2)
            worst = max(worst, P / bnd); worst_k = max(worst_k, P / bndk)
            flow_fail += int(P > P0 + eta * (j + 1) * float((y ** 2).mean()) + 1e-12)
        pr(f"   [{mode} eta={eta} batch={batch}] steps={j+1}  max 2eta|M_j| = {max2eM:.2f}  max P_J/bound = {worst:.4f}  max P_J/(kappa_B form) = {worst_k:.4f}  (<= 1 required)  steps where flow bound P0+t|y|^2 fails: {flow_fail}")


# ---------------------------------------------------------------- S3
def replay(name, n, h, alpha, eta, T, seed=0, batch=None):
    d = Q.d
    rng = np.random.default_rng(seed)
    C = Q.cube(d)
    yC = Q.target(name, C)
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
    steps = int(round(T / eta))
    tau = 0.0; S_M2 = 0.0; S_y2 = 0.0; tau_sgd = 0.0; max2eM = 0.0; max2eM_wf = 0.0
    MyB_max = 0.0; kB_max = 0.0; first_growth = None
    eps_fg = 1e-2
    Th_fg = 0.25 * math.log(eps_fg / (alpha ** 2 * s0 ** 2))
    rows = []
    for k in range(steps + 1):
        t = k * eta
        Xm = U @ U.T - V @ V.T
        f = Q.fvals(Xm, X); r = y - f
        sU = np.linalg.svd(U, compute_uv=False); sV = np.linalg.svd(V, compute_uv=False)
        if first_growth is None and (sU[0] ** 2 >= eps_fg or sV[0] ** 2 >= eps_fg):
            first_growth = t
        if k % int(round(1.0 / eta)) == 0 or k == steps:
            rows.append((t, tau, tau_sgd, sU.copy(), sV.copy(), float((U ** 2).sum() + (V ** 2).sum()), f.copy(),
                         S_M2, S_y2))
        if k == steps:
            break
        if batch is None:
            M = Q.Mres(r, X); kB = kappa; rb = r; yb = y; MyB = float(np.abs(np.linalg.eigvalsh(Q.Mres(y, X))).max())
        else:
            b = rng.choice(n, size=batch, replace=False)
            M = Q.Mres(r[b], X[b]); rb = r[b]; yb = y[b]
            PhiB = X[b][:, iu[0]] * X[b][:, iu[1]]
            kB = 2 * float(np.linalg.eigvalsh(PhiB @ PhiB.T / batch)[-1])
            MyB = float(np.abs(np.linalg.eigvalsh(Q.Mres(yb, X[b]))).max())
        nM = float(np.abs(np.linalg.eigvalsh(M)).max())
        max2eM = max(max2eM, 2 * eta * nM)
        max2eM_wf = max(max2eM_wf, 2 * eta * math.sqrt(kB) * math.sqrt((rb ** 2).mean()))
        if first_growth is None:
            MyB_max = max(MyB_max, MyB); kB_max = max(kB_max, kB)
        S_M2 += nM ** 2; S_y2 += float((yb ** 2).mean())
        tau += eta * math.sqrt((rb ** 2).mean())
        tau_sgd += eta * math.sqrt(kB) * math.sqrt((rb ** 2).mean())
        U = U + 2 * eta * M @ U
        V = V - 2 * eta * M @ V
    return dict(X=X, y=y, n=n, kappa=kappa, s0=s0, P0=P0, rows=rows, alpha=alpha, eta=eta, max2eM=max2eM,
                max2eM_wf=max2eM_wf, first_growth=first_growth, MyB_max=MyB_max, kB_max=kB_max, Th_fg=Th_fg, d=d)


def S3():
    pr(f"\n=== S3 Section 7.4 replayed with the proved GD/SGD forms of D6(5)  [{time.time()-T0:.0f}s]")
    d = Q.d
    configs = [("x1x2", 3000, 16, 1e-6, 0.01, 20.0, 0, None), ("majpairs", 3000, 16, 1e-6, 0.01, 30.0, 0, None),
               ("x1x2", 300, 16, 1e-6, 0.01, 20.0, 0, None), ("majpairs", 3000, 16, 1e-6, 0.01, 30.0, 0, 64)]
    for name, n, h, alpha, eta, T, seed, batch in configs:
        R = replay(name, n, h, alpha, eta, T, seed, batch)
        pr(f"   --- {name} n={n} batch={batch}: kappa={R['kappa']:.4f} s0={R['s0']:.3f}  max_j 2eta|M_j|_op = {R['max2eM']:.4f}"
           f"  (weight-free check 2eta sqrt(kappa_Bj)|r_j|_Bj: max {R['max2eM_wf']:.4f}; < 1 needed)")
        pick = np.unique(np.linspace(0, len(R["rows"]) - 1, 8).astype(int))
        for i in pick:
            t, tau, tau_sgd, sU, sV, P, fS, S_M2, S_y2 = R["rows"][i]
            yv = R["y"]
            P_flow = R["P0"] + t * float((yv ** 2).mean())
            P_gd = math.exp(4 * eta ** 2 * S_M2) * (R["P0"] + eta * S_y2)
            meas = flowB = gdB = sgdN_b = 1.0
            Nap_out = Nsgd_out = None
            for g in (0.25, 0.5):
                eps = g / (8 * (d - 1))
                N = int((sU ** 2 >= eps).sum() + (sV ** 2 >= eps).sum())
                Th = 0.25 * math.log(eps / (alpha ** 2 * R["s0"] ** 2))
                Nap = min(d * (d - 1), int(math.floor(R["kappa"] * (tau / Th) ** 2)))
                Nsgd = int(math.floor((tau_sgd / Th) ** 2))
                emp = float(np.mean(yv * fS <= g))
                meas = min(meas, Q.bound_rank(N, P, g, emp, n))
                flowB = min(flowB, Q.bound_rank(max(N, Nap), P_flow, g, emp, n))
                gdB = min(gdB, Q.bound_rank(max(N, Nap), P_gd, g, emp, n))
                sgdN_b = min(sgdN_b, Q.bound_rank(max(N, min(2 * d, Nsgd)), P_gd, g, emp, n))
                if g == 0.5:
                    Nap_out, Nsgd_out, N_out = Nap, Nsgd, N
            line = (f"     t={t:5.1f} P={P:.3f}  B: flow {P_flow:.2f} -> {2**math.ceil(math.log2(P_flow)):.0f}, proved-GD {P_gd:.2f} -> {2**math.ceil(math.log2(P_gd)):.0f}"
                    f"  | N meas={N_out} wf={Nap_out}")
            if batch is None:
                line += f"  | D7: meas {meas:.3f}  wf+flowB {flowB:.3f}  wf+provedGD-B {gdB:.3f}"
            else:
                line += (f" SGD-proved N<={Nsgd_out}  | D7: meas {meas:.3f}  (full-batch wf form, flow B) {flowB:.3f}"
                         f"  SGD-proved N (capped at 2d={2*d}) + proved B {sgdN_b:.3f}")
            pr(line)
        if batch is not None:
            eps = 1e-2
            lb = R["Th_fg"] / (R["MyB_max"] + 2 * R["kB_max"] * math.sqrt(d) * eps)
            pr(f"     first growth at eps=0.01: observed t={R['first_growth']:.2f}; flow D6(3) bound (table) uses |M_y|_op; the proved SGD analogue "
               f"Theta/(max_j |M_y^Bj|_op + 2 max_j kappa_Bj sqrt(d) eps) = {R['Th_fg']:.2f}/({R['MyB_max']:.3f} + 2*{R['kB_max']:.2f}*4*0.01) = {lb:.2f}")


# ---------------------------------------------------------------- S4
def S4():
    pr(f"\n=== S4 numbers in the D7 Comparison, time-only rank bound, D3.3 capacity  [{time.time()-T0:.0f}s]")
    d = 16
    D = d * (d - 1) // 2
    lp = log_Phi(2 ** (d + 1), D + 1)
    pr(f"   ln Phi(2^17, 121) = {lp:.1f} nats (file: ~964);  crude (C(d,2)+1)(d+1) ln2 = {(D+1)*(d+1)*math.log(2):.1f} (file: 1426)")
    delta, G = 0.05, 2
    unr = lp + math.log(1 / delta)
    for B in (1, 2):
        rows = []
        for N in range(1, 10):
            cap = Q.capacity_rank(N, B, 0.5)
            bexp = int(round(math.log2(B)))
            prior = math.log((N + 1) * (N + 2)) + math.log(2 * (abs(bexp) + 1) * (abs(bexp) + 2)) + math.log(G) + math.log(1 / delta)
            rows.append((N, cap / N, cap + prior))
        be = [N for N, _, c in rows if c < unr]
        pr(f"   B={B}, gamma=1/2: per-unit capacity N=1..9: {', '.join(f'{c:.1f}' for _, c, _ in rows)};  rank bound total < unrestricted ({unr:.1f}) for N <= {max(be)}")
    # time-only rank bound at t=20, x1x2 n=3000 (kappa, s0 from D_quad_check.out)
    kappa, s0, alpha, tau = 2.8527, 1.970, 1e-6, 6.83
    for g in (0.5, 0.25):
        eps = g / (8 * (d - 1))
        Th = 0.25 * math.log(eps / (alpha ** 2 * s0 ** 2))
        pr(f"   gamma={g}: Theta={Th:.3f}; time-only kappa(R0 t/Theta)^2 at t=20, R0=1: {kappa*(20/Th)**2:.1f};  from tau={tau}: {kappa*(tau/Th)**2:.2f};  trivial bound min(d,h)+min(d,h') = 32")
    # D3.3 capacity per cluster
    for K in (1, 2, 64):
        B, gam, dd = 2.0, 0.5, 16
        cap = K * ((dd + 1) * math.log(1 + 16 * B * math.sqrt(dd + 1) / gam) + math.log(2 * math.ceil(8 * K * B * math.sqrt(dd + 1) / gam) + 1))
        pr(f"   D3.3 capacity bound, K={K}, B=2 (dyadic >= 1.4), gamma=1/2: {cap:.0f} nats ({cap/K:.0f} per cluster)")


if __name__ == "__main__":
    S1(); S2(); S3(); S4()
    pr(f"\ndone in {time.time()-T0:.0f}s")

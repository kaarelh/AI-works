"""Referee checks, round 1, for D-early-phase-theorem.md.

Sections (each prints PASS/FAIL-style numbers; nothing here edits D):
  R1  kl-inverse facts used in D0 (q + sqrt(2qc) + 2c, and c at q = 0).
  R2  Lemma D1 (a),(b),(d),(e),(f),(g),(g3): selection-flow vector-field identities at random balanced points.
  R3  Lemma D1(g1): Lorentz conservation of Q_jk inside a shared activation cell (RK4, tiny step).
  R4  Lemma D2.1: certified bound >= multistart lower estimate of sup|U_r| (small d); exactness for y = x1 at d = 16.
  R5  Theorem D2(5): one-step discrete growth inequality, unbalanced random parameters.
  R6  Theorem D5: log-det clock, continuous (solve_ivp) and discrete, all K.
  R7  kappa identity and the <M,Z> step of Theorem D6(2); nuclear-norm facts of Theorem D7; non-nestedness of the D7 grids.
  R8  Independent quadratic-network GD/SGD run (d = 10, other seed): D6(1),(2),(3),(5) incl. the SGD kappa_B form.
      Also: D6(4) (P <= P(0) + t|y|^2) is a flow statement; a one-step GD counterexample.
  R9  Horn clock on the D_quad_check config 0 trajectory (reported excess +2.8e-8): split by SVD resolution, and
      excluding K = d = h, where D5 is an equality (determinant identity). (mpmath is not installed.)
  R10 Independent recomputation of the D7 numbers 0.084 / 0.213 (x1x2, n = 3000).
  R11 D_relu_check's D3.3 certificate is computed for the balanced surrogate sum_j eps_j rho_j/2 relu(hat w_j . xt),
      not for the GD network sum_j a_j relu(w_j . xt); recompute it for the real GD network (maj3, n=1000, alpha=1e-3),
      and test Proposition D4.1's cluster bound along that GD run.
Set OPENBLAS_NUM_THREADS=1.  Runtime: a few minutes on one core.
"""
import math, os, sys, time
os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")
sys.dont_write_bytecode = True
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from c_common import klinv_upper, kl  # noqa: E402

relu = lambda z: np.maximum(z, 0.0)
T0 = time.time()


def hdr(s):
    print(f"\n=== {s}  [{time.time()-T0:.0f}s]", flush=True)


# ---------------------------------------------------------------- R1
def R1():
    hdr("R1 kl-inverse facts")
    rng = np.random.default_rng(1)
    worst1, worst2 = -1.0, -1.0
    for _ in range(4000):
        q = rng.uniform(0, 1) ** 3
        c = 10 ** rng.uniform(-4, 0.5)
        p = klinv_upper(q, c)
        worst1 = max(worst1, p - min(1.0, q + math.sqrt(2 * q * c) + 2 * c))
        p0 = klinv_upper(0.0, c)
        worst2 = max(worst2, p0 - min(1.0, c))
    print(f"max [klinv(q,c) - (q+sqrt(2qc)+2c)] = {worst1:.2e} (<=0 up to bisection 1e-15);  max [klinv(0,c) - c] = {worst2:.2e}")


# ---------------------------------------------------------------- R2
def sel_velocity(a, W, Xt, y):
    """Selection-flow velocity with s = 1[z>0] (generic points: no ties)."""
    n = len(y)
    Z = Xt @ W.T
    S = (Z > 0).astype(float)
    f = relu(Z) @ a
    r = y - f
    adot = relu(Z).T @ r / n
    xi = (S * r[:, None]).T @ Xt / n
    Wdot = a[:, None] * xi
    return adot, Wdot, r, f, S, xi


def R2():
    hdr("R2 Lemma D1 identities at random balanced points (d=6, n=40, m=8)")
    rng = np.random.default_rng(2)
    d, n, m = 6, 40, 8
    errs = dict(bal=0, clock=0, dir=0, energy=0, Pdot=0, f_id=0, f_ineq=0, g_id=0, m_neg=0, g3=0)
    Pdot_excess = -1e9
    for trial in range(300):
        X = rng.choice([-1.0, 1.0], size=(n, d)); Xt = np.hstack([X, np.ones((n, 1))])
        y = rng.standard_normal(n)
        lam = np.linalg.eigvalsh(Xt.T @ Xt / n)[-1]
        W = rng.standard_normal((m, d + 1)) * rng.uniform(0.2, 1.5, (m, 1))
        eps = rng.choice([-1.0, 1.0], m)
        a = eps * np.linalg.norm(W, axis=1)
        # make some pairs share sign and nearly share direction (to exercise g)
        adot, Wdot, r, f, S, xi = sel_velocity(a, W, Xt, y)
        nw = np.linalg.norm(W, axis=1); Wn = W / nw[:, None]
        # (a)
        errs["bal"] = max(errs["bal"], np.abs(2 * a * adot - 2 * (W * Wdot).sum(1)).max())
        # (b) d/dt ln rho = 2 eps U_r(hat w)
        rho = a ** 2 + nw ** 2
        rhodot = 2 * a * adot + 2 * (W * Wdot).sum(1)
        Ur = relu(Xt @ Wn.T).T @ r / n
        errs["clock"] = max(errs["clock"], np.abs(rhodot / rho - 2 * eps * Ur).max())
        # (d) direction velocity
        Pi_xi = xi - (xi * Wn).sum(1, keepdims=True) * Wn
        wdot_hat = (Wdot - (Wdot * Wn).sum(1, keepdims=True) * Wn) / nw[:, None]
        errs["dir"] = max(errs["dir"], np.abs(wdot_hat - eps[:, None] * Pi_xi).max())
        # (e) energy: central finite difference of L along the velocity
        h = 1e-6
        def Lval(a_, W_):
            return 0.5 * np.mean((y - relu(Xt @ W_.T) @ a_) ** 2)
        dL = (Lval(a + h * adot, W + h * Wdot) - Lval(a - h * adot, W - h * Wdot)) / (2 * h)
        sq = (adot ** 2).sum() + (Wdot ** 2).sum()
        errs["energy"] = max(errs["energy"], abs(dL + sq) / max(sq, 1e-12))
        Pdot = rhodot.sum()
        errs["Pdot"] = max(errs["Pdot"], abs(Pdot - 4 * np.mean(r * f)))
        Pdot_excess = max(Pdot_excess, Pdot - np.mean(y ** 2))
        # (f)
        xi_y = (S * y[:, None]).T @ Xt / n; xi_f = (S * f[:, None]).T @ Xt / n
        Py = xi_y - (xi_y * Wn).sum(1, keepdims=True) * Wn
        Pf = xi_f - (xi_f * Wn).sum(1, keepdims=True) * Wn
        def Uy_dir(W_):
            Wn_ = W_ / np.linalg.norm(W_, axis=1, keepdims=True)
            return relu(Xt @ Wn_.T).T @ y / n
        dUy = (Uy_dir(W + h * Wdot) - Uy_dir(W - h * Wdot)) / (2 * h)
        lhs = eps * dUy
        errs["f_id"] = max(errs["f_id"], np.abs(lhs - ((Pi_xi * Py).sum(1))).max())
        fn = math.sqrt(np.mean(f ** 2))
        mid = (Py ** 2).sum(1) - np.linalg.norm(Py, axis=1) * math.sqrt(lam) * fn
        errs["f_ineq"] = max(errs["f_ineq"], float(np.max(mid - lhs)), float(np.max(-lam / 4 * fn ** 2 - mid)))
        # (g)
        for j in range(m):
            for k in range(j + 1, m):
                if eps[j] != eps[k]:
                    continue
                Q = a[j] * a[k] - W[j] @ W[k]
                Qdot = adot[j] * a[k] + a[j] * adot[k] - Wdot[j] @ W[k] - W[j] @ Wdot[k]
                mi = (S[:, j] - S[:, k]) * (Xt @ (Wn[j] - Wn[k]))
                errs["m_neg"] = max(errs["m_neg"], float(-mi.min()))
                form = eps[j] * nw[j] * nw[k] * np.mean(r * mi)
                errs["g_id"] = max(errs["g_id"], abs(Qdot - form))
                sep = (S[:, j] != S[:, k])
                rrep = np.sum(np.abs(r) * (sep & (eps[j] * r > 0))) / n
                if Q > 1e-12:
                    bound = math.sqrt(2 * (d + 1) * nw[j] * nw[k] * Q) * rrep
                    errs["g3"] = max(errs["g3"], Qdot - bound)
    for k_, v in errs.items():
        print(f"   {k_:7s}: worst violation / identity error = {v:.2e}")
    print(f"   max (Pdot - |y|_n^2) = {Pdot_excess:.3f} (<= 0 required)")


# ---------------------------------------------------------------- R3
def R3():
    hdr("R3 Lemma D1(g1): Q conserved in a shared activation cell (RK4)")
    rng = np.random.default_rng(3)
    d, n = 8, 60
    X = rng.choice([-1.0, 1.0], size=(n, d)); Xt = np.hstack([X, np.ones((n, 1))])
    y = rng.standard_normal(n)
    # two same-sign neurons with nearby directions in the same cell, plus three others
    m = 5
    W = rng.standard_normal((m, d + 1)); W *= 0.3 / np.linalg.norm(W, axis=1, keepdims=True)
    cand = rng.standard_normal((100000, d + 1)); cand /= np.linalg.norm(cand, axis=1, keepdims=True)
    best = cand[np.argmax(np.abs(cand @ Xt.T).min(1))]           # direction with the largest training margin
    W[0] = 0.3 * best
    W[1] = W[0] + 3e-3 * rng.standard_normal(d + 1)
    y = 0.3 * y
    eps = np.array([1.0, 1.0, -1.0, 1.0, -1.0])
    a = eps * np.linalg.norm(W, axis=1)
    Z = Xt @ W.T
    assert np.all(np.sign(Z[:, 0]) == np.sign(Z[:, 1]))
    def vel(st):
        a_, W_ = st[:m], st[m:].reshape(m, d + 1)
        ad, Wd, *_ = sel_velocity(a_, W_, Xt, y)
        return np.concatenate([ad, Wd.ravel()])
    st = np.concatenate([a, W.ravel()])
    Q0 = a[0] * a[1] - W[0] @ W[1]
    h, worst, steps = 1e-3, 0.0, 0
    pattern0 = (Xt @ W.T > 0)
    for _ in range(5000):
        k1 = vel(st); k2 = vel(st + h / 2 * k1); k3 = vel(st + h / 2 * k2); k4 = vel(st + h * k3)
        new = st + h / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
        Wn_ = new[m:].reshape(m, d + 1)
        if np.any((Xt @ Wn_[:2].T > 0) != pattern0[:, :2]):     # only the pair must keep its pattern
            break
        st = new; steps += 1
        a_, W_ = st[:m], st[m:].reshape(m, d + 1)
        Q = a_[0] * a_[1] - W_[0] @ W_[1]
        worst = max(worst, abs(Q - Q0) / Q0)
    a_, W_ = st[:m], st[m:].reshape(m, d + 1)
    print(f"   {steps} RK4 steps (t={steps*h:.2f}) inside the cell; rho_0 grew x{(a_[0]**2+W_[0]@W_[0])/(a[0]**2+W[0]@W[0]):.3f};"
          f"  max |Q-Q0|/Q0 = {worst:.2e} (0 for the flow)")


# ---------------------------------------------------------------- R4
def U_hat(r, Xt):
    n = len(r); out = []
    for rr in (np.maximum(r, 0), np.maximum(-r, 0)):
        if rr.sum() == 0:
            out.append(0.0); continue
        S = Xt[rr > 0]
        b1 = math.sqrt((rr ** 2).mean()) * math.sqrt(np.linalg.eigvalsh(S.T @ S / n)[-1])
        M = (Xt * rr[:, None]).T @ Xt / n
        b2 = math.sqrt(rr.mean() * np.linalg.eigvalsh(M)[-1])
        out.append(min(b1, b2))
    return out


def R4():
    hdr("R4 Lemma D2.1 certified bound vs a dense multistart lower estimate (d=4, full cube)")
    rng = np.random.default_rng(4)
    d = 4
    idx = np.arange(2 ** d)[:, None]
    C = 1.0 - 2.0 * ((idx >> np.arange(d)[None, :]) & 1)
    Xt = np.hstack([C, np.ones((len(C), 1))]); n = len(C)
    worst, tight = -1e9, []
    for trial in range(60):
        r = rng.standard_normal(n) * (rng.uniform(size=n) < 0.7)
        Up, Um = U_hat(r, Xt)
        V = rng.standard_normal((200000, d + 1)); V /= np.linalg.norm(V, axis=1, keepdims=True)
        vals = relu(V @ Xt.T) @ r / n
        for sgn, Uh in ((1, Up), (-1, Um)):
            best = V[np.argsort(-sgn * vals)[:200]].copy()
            for _ in range(200):
                Z = best @ Xt.T
                g = ((Z > 0) * (sgn * r)[None, :]) @ Xt / n
                g -= (g * best).sum(1, keepdims=True) * best
                best += 0.3 * g; best /= np.linalg.norm(best, axis=1, keepdims=True)
            est = max(float((sgn * relu(best @ Xt.T) @ r / n).max()), float((sgn * vals).max()))
            worst = max(worst, est - Uh)
            if est > 0:
                tight.append(Uh / est)
    print(f"   max (lower estimate - certified bound) = {worst:.2e} (<= 0 required);  certified/estimate: "
          f"median {np.median(tight):.3f}, max {np.max(tight):.3f}")
    # exactness for y = x1, full cube, d = 16
    d = 16
    idx = np.arange(2 ** d)[:, None]
    C = 1.0 - 2.0 * ((idx >> np.arange(d)[None, :]) & 1)
    Xt = np.hstack([C, np.ones((len(C), 1))])
    y = C[:, 0]
    Up, Um = U_hat(y, Xt)
    v = np.zeros(d + 1); v[0] = 1; v[-1] = 1; v /= np.linalg.norm(v)
    print(f"   y=x1, full cube d=16: U_hat^+ = {Up:.6f}, U_hat^- = {Um:.6f}, U_y((e1+e0)/sqrt2) = {np.mean(y*relu(Xt@v)):.6f}, 1/sqrt2 = {1/math.sqrt(2):.6f}")


# ---------------------------------------------------------------- R5
def R5():
    hdr("R5 Theorem D2(5) discrete one-step growth inequality (unbalanced)")
    rng = np.random.default_rng(5)
    worst = -1e9
    for _ in range(2000):
        d, n = 5, 30
        X = rng.choice([-1.0, 1.0], size=(n, d)); Xt = np.hstack([X, np.ones((n, 1))])
        lam = np.linalg.eigvalsh(Xt.T @ Xt / n)[-1]
        w = rng.standard_normal(d + 1) * rng.uniform(0.1, 3); a = rng.standard_normal() * rng.uniform(0.1, 3)
        r = rng.standard_normal(n); eta = 10 ** rng.uniform(-3, 0)
        z = Xt @ w; s = (z > 0).astype(float)
        A = np.mean(r * relu(z)); V = (s * r) @ Xt / n
        a2, w2 = a + eta * A, w + eta * a * V
        rho, rho2 = a * a + w @ w, a2 * a2 + w2 @ w2
        Uabs = abs(np.mean(r * relu(Xt @ (w / np.linalg.norm(w)))))
        rhs = rho + 4 * eta * abs(a) * np.linalg.norm(w) * Uabs + eta ** 2 * rho * lam * np.mean(r ** 2)
        worst = max(worst, (rho2 - rhs) / rho)
    print(f"   max (rho' - [rho + 4 eta |a||w| |U_r(hat w)| + eta^2 rho lam |r|^2]) / rho = {worst:.2e} (<= 0 required;"
          f" this implies D2(5) since |U_r(hat w)| <= U*(r))")


# ---------------------------------------------------------------- R6
def R6():
    hdr("R6 Theorem D5 log-det clock, continuous and discrete")
    from scipy.integrate import solve_ivp
    rng = np.random.default_rng(6)
    d, h = 6, 4
    worst_c, worst_d = -1e9, -1e9
    for trial in range(20):
        B0, B1, B2 = [rng.standard_normal((d, d)) for _ in range(3)]
        B0, B1, B2 = B0 + B0.T, B1 + B1.T, B2 + B2.T
        A = lambda t: B0 + math.sin(3 * t) * B1 + math.cos(1.7 * t) * B2 * t
        W0 = rng.standard_normal((d, h)) * np.array([1, 1e-2, 1e-4, 1e-6])[None, :]
        T = 1.0
        def rhs(t, z):
            Wm = z[:d * h].reshape(d, h)
            ev = np.sort(np.linalg.eigvalsh(A(t)))[::-1]
            return np.concatenate([(A(t) @ Wm).ravel(), np.cumsum(ev)[:h]])
        sol = solve_ivp(rhs, (0, T), np.concatenate([W0.ravel(), np.zeros(h)]), rtol=1e-11, atol=1e-14, method="DOP853")
        WT = sol.y[:d * h, -1].reshape(d, h); clock = sol.y[d * h:, -1]
        lhs = np.cumsum(np.log(np.linalg.svd(WT, compute_uv=False))) - np.cumsum(np.log(np.linalg.svd(W0, compute_uv=False)))
        worst_c = max(worst_c, float((lhs - clock).max()))
        # discrete
        W = W0.copy(); clockd = np.zeros(h); eta = 0.05
        for j in range(40):
            Aj = rng.standard_normal((d, d)); Aj = Aj + Aj.T
            ev = np.sort(np.linalg.eigvalsh(Aj))[::-1]
            if 1 + eta * ev[-1] <= 0:
                Aj *= 0.9 / (eta * abs(ev[-1])); ev = np.sort(np.linalg.eigvalsh(Aj))[::-1]
            W = (np.eye(d) + eta * Aj) @ W
            clockd += np.cumsum(np.log1p(eta * ev))[:h]
        lhs = np.cumsum(np.log(np.linalg.svd(W, compute_uv=False))) - np.cumsum(np.log(np.linalg.svd(W0, compute_uv=False)))
        worst_d = max(worst_d, float((lhs - clockd).max()))
    print(f"   continuous: max over trials,K of [LHS - RHS] = {worst_c:.2e} (<= 0 up to ODE error);"
          f"  discrete (Horn): {worst_d:.2e} (<= 0)")


# ---------------------------------------------------------------- R7
def R7():
    hdr("R7 kappa identity, the <M,Z> step of D6(2), nuclear-norm facts of D7, grid nesting")
    rng = np.random.default_rng(7)
    d, n = 10, 200
    X = rng.choice([-1.0, 1.0], size=(n, d))
    iu = np.triu_indices(d, 1)
    Phi = X[:, iu[0]] * X[:, iu[1]]
    ev, evec = np.linalg.eigh(Phi.T @ Phi / n)
    kappa = 2 * ev[-1]
    worst = 0.0
    for _ in range(2000):
        Z = rng.standard_normal((d, d)); Z = Z + Z.T
        AZ = np.einsum("ik,kl,il->i", X, Z, X) - np.trace(Z)
        worst = max(worst, np.mean(AZ ** 2) / (Z ** 2).sum())
    z = evec[:, -1]; Z = np.zeros((d, d)); Z[iu] = z; Z = Z + Z.T
    AZ = np.einsum("ik,kl,il->i", X, Z, X) - np.trace(Z)
    print(f"   kappa = {kappa:.4f}; max random ratio = {worst:.4f} (<= kappa); ratio at the zero-diagonal top eigvec = {np.mean(AZ**2)/(Z**2).sum():.4f}")
    # D6(2) pointwise step: sum_{k<=NU} lam_k(M) + sum_{k<=NV} lam_k(-M) <= |r|_n sqrt(kappa N)
    worst2 = -1e9
    for _ in range(500):
        r = rng.standard_normal(n)
        M = (X * r[:, None]).T @ X / n - r.mean() * np.eye(d)
        ev_ = np.sort(np.linalg.eigvalsh(M))[::-1]
        for NU in range(0, 6):
            for NV in range(0, 6):
                if NU + NV == 0:
                    continue
                lhs = ev_[:NU].sum() + (-ev_[::-1][:NV]).sum()
                worst2 = max(worst2, lhs - math.sqrt(np.mean(r ** 2)) * math.sqrt(kappa * (NU + NV)))
    print(f"   D6(2) pointwise step: max [KyFan split - |r| sqrt(kappa N)] = {worst2:.3f} (<= 0)")
    # D7 nuclear facts
    worst3 = 0.0
    for _ in range(2000):
        z = rng.standard_normal(d); z /= np.linalg.norm(z)
        zp = z + rng.standard_normal(d) * 10 ** rng.uniform(-3, 0); zp /= np.linalg.norm(zp)
        nuc = np.abs(np.linalg.eigvalsh(np.outer(z, z) - np.outer(zp, zp))).sum()
        worst3 = max(worst3, nuc / (2 * np.linalg.norm(z - zp)))
    x = X[0]
    E = np.linalg.eigvalsh(np.outer(x, x) - np.eye(d))
    print(f"   max |zz^T-z'z'^T|_* / (2|z-z'|) = {worst3:.4f} (<= 1);  |xx^T-I|_* = {np.abs(E).sum():.1f} (2(d-1)={2*(d-1)}),"
          f" |xx^T-I|_op = {np.abs(E).max():.1f}")
    # nesting of D7 grids in N: eta_lambda(N) Z subset of eta_lambda(N+1) Z ?  ratio (N+1)/N must be an integer
    print("   D7 grids: eta_lambda(N)/eta_lambda(N+1) = (N+1)/N, an integer only for N = 1; so G_{N} is NOT a subset of G_{N+1}"
          " for N >= 2 (claim 'nested in N' is false; the conclusion 'any N >= N_eps admissible' still holds by padding).")


# ---------------------------------------------------------------- R8
def R8():
    hdr("R8 independent quadratic run (d=10, n=400, seed 11): D6(1),(2),(3),(5); SGD kappa_B form; GD vs D6(4)")
    rng = np.random.default_rng(11)
    d, n, h, alpha, eta = 10, 400, 10, 1e-5, 0.005
    idx = np.arange(2 ** d)[:, None]
    C = 1.0 - 2.0 * ((idx >> np.arange(d)[None, :]) & 1)
    sel = rng.choice(len(C), n, replace=False)
    X = C[sel]
    y = X[:, 0] * X[:, 1] + 0.7 * X[:, 2] * X[:, 3] - 0.5 * X[:, 4] * X[:, 5] * X[:, 6]   # last term outside the model
    iu = np.triu_indices(d, 1)
    Phi = X[:, iu[0]] * X[:, iu[1]]
    kappa = 2 * np.linalg.eigvalsh(Phi.T @ Phi / n)[-1]
    def Mres(r, Xb):
        return (Xb * r[:, None]).T @ Xb / len(r) - r.mean() * np.eye(Xb.shape[1])
    def fv(Xm, Xb):
        return np.einsum("ik,kl,il->i", Xb, Xm, Xb) - np.trace(Xm)
    for mode in ("gd", "sgd"):
        rng2 = np.random.default_rng(12)
        U0 = rng2.standard_normal((d, h)) / math.sqrt(d); V0 = rng2.standard_normal((d, h)) / math.sqrt(d)
        s0 = max(np.linalg.norm(U0, 2), np.linalg.norm(V0, 2))
        U, V = alpha * U0, alpha * V0
        Uy = np.linalg.eigvalsh(Mres(y, X)); U0s = max(Uy[-1], -Uy[0])
        tau = 0.0; tauB = 0.0; worst_rank = 0.0; worst_rankB = 0.0; worst_clock = -1e9; first = {}
        kfU = np.zeros(d); kfV = np.zeros(d)
        cond = 0.0
        for k in range(8000):
            t = k * eta
            sU = np.linalg.svd(U, compute_uv=False); sV = np.linalg.svd(V, compute_uv=False)
            for eps_ in (1e-2, 1e-1):
                NU = int((sU ** 2 >= eps_).sum()); NV = int((sV ** 2 >= eps_).sum())
                Th = 0.25 * math.log(eps_ / (alpha ** 2 * s0 ** 2))
                if NU + NV > 0:
                    if mode == "gd":
                        worst_rank = max(worst_rank, (NU + NV) / (kappa * (tau / Th) ** 2))
                    worst_rankB = max(worst_rankB, (NU + NV) / ((tauB / Th) ** 2))
                    worst_clock = max(worst_clock, NU * Th - kfU[NU - 1] if NU else -1e9, NV * Th - kfV[NV - 1] if NV else -1e9)
                    if eps_ not in first:
                        first[eps_] = (t, Th / (U0s + 2 * kappa * math.sqrt(d) * eps_))
            r = y - fv(U @ U.T - V @ V.T, X)
            if mode == "gd":
                b = np.arange(n)
            else:
                b = rng2.choice(n, 32, replace=False)
            M = Mres(r[b], X[b])
            ev = np.sort(np.linalg.eigvalsh(M))[::-1]
            cond = max(cond, 2 * eta * np.abs(ev).max())
            kfU += eta * np.cumsum(ev); kfV += eta * np.cumsum(-ev[::-1])
            tau += eta * math.sqrt(np.mean(r ** 2))
            PhiB = Phi[b]; kB = 2 * np.linalg.eigvalsh(PhiB.T @ PhiB / len(b))[-1]
            tauB += eta * math.sqrt(kB) * math.sqrt(np.mean(r[b] ** 2))
            U = U + 2 * eta * M @ U; V = V - 2 * eta * M @ V
        print(f"   [{mode}] kappa={kappa:.3f}  max 2 eta |M_j| = {cond:.3f} (<1 needed)  "
              f"D6(1) max [K Theta - KyFan] = {worst_clock:.3f} (<= 0)  "
              + (f"D6(2) max N/(kappa(tau/Theta)^2) = {worst_rank:.3f} (<= 1)  " if mode == "gd" else "")
              + f"D6(5) kappa_B form max ratio = {worst_rankB:.4f} (<= 1)  "
              + "first growth " + ", ".join(f"eps={e}: t={v[0]:.2f} >= bound {v[1]:.2f}" for e, v in first.items()))
    # GD counterexample to the flow statement D6(4) after one step: choose f = y/2 on the sample
    rng3 = np.random.default_rng(13)
    d2, n2 = 6, 15
    Xs = rng3.choice([-1.0, 1.0], size=(n2, d2))
    Xstar = rng3.standard_normal((d2, d2)); Xstar = Xstar + Xstar.T
    y2 = 2 * fv(Xstar, Xs)
    w_, Q_ = np.linalg.eigh(Xstar)
    U = Q_[:, w_ > 0] * np.sqrt(w_[w_ > 0]); V = Q_[:, w_ < 0] * np.sqrt(-w_[w_ < 0])
    r = y2 - fv(U @ U.T - V @ V.T, Xs)
    M = Mres(r, Xs)
    eta2 = 0.4 / (2 * np.abs(np.linalg.eigvalsh(M)).max())
    P0 = (U ** 2).sum() + (V ** 2).sum()
    U1 = U + 2 * eta2 * M @ U; V1 = V - 2 * eta2 * M @ V
    P1 = (U1 ** 2).sum() + (V1 ** 2).sum()
    print(f"   one GD step from f = y/2 (2 eta |M| = 0.4): P1 - P0 = {P1-P0:.4f}  vs  eta |y|_n^2 = {eta2*np.mean(y2**2):.4f}"
          f"  -> the flow bound P(t) <= P(0) + t|y|^2 of D6(4) {'FAILS' if P1-P0 > eta2*np.mean(y2**2) else 'holds'} for GD at this step")


# ---------------------------------------------------------------- R9
def R9():
    hdr("R9 Horn clock on the D_quad_check config 0 trajectory (x1x2, n=300, alpha=1e-6, eta=0.01, T=20): is the +2.8e-8 excess round-off?")
    # mpmath is not installed; instead, split the excess by how well the K-th singular value is resolved.
    d, n, h, alpha, eta, T = 16, 300, 16, 1e-6, 0.01, 20.0
    idx = np.arange(2 ** d)[:, None]
    C = 1.0 - 2.0 * ((idx >> np.arange(d)[None, :]) & 1)
    yC = C[:, 0] * C[:, 1]
    rng = np.random.default_rng(0)
    sel = rng.choice(len(C), size=n, replace=False)
    X, y = C[sel], yC[sel]
    U0 = rng.standard_normal((d, h)) / math.sqrt(d); V0 = rng.standard_normal((d, h)) / math.sqrt(d)
    U, V = alpha * U0, alpha * V0
    l0U = np.cumsum(np.log(np.linalg.svd(U, compute_uv=False))); l0V = np.cumsum(np.log(np.linalg.svd(V, compute_uv=False)))
    cU = np.zeros(d); cV = np.zeros(d)
    thr = [1e-9, 1e-7, 1e-6, 1e-5, 1e-4]
    worst = {t: -1e9 for t in thr}; argK = {t: None for t in thr}; worst_below = -1e9
    steps = int(round(T / eta))
    for k in range(steps + 1):
        for W_, l0, c in ((U, l0U, cU), (V, l0V, cV)):
            sv = np.linalg.svd(W_, compute_uv=False)
            ex = np.cumsum(np.log(sv)) - l0 - c
            Kn = min(d - 1, max(1, int((sv >= 1e-9 * sv[0]).sum())))
            worst_below = max(worst_below, float(ex[:Kn].max()))
            for t in thr:
                K = max(1, int((sv >= t * sv[0]).sum()))
                i = int(np.argmax(ex[:K]))
                if ex[i] > worst[t]:
                    worst[t] = float(ex[i]); argK[t] = (i + 1, k * eta, float(sv[i] / sv[0]))
        if k == steps:
            break
        Xm = U @ U.T - V @ V.T
        f = np.einsum("ik,kl,il->i", X, Xm, X) - np.trace(Xm)
        r = y - f
        M = (X * r[:, None]).T @ X / n - r.mean() * np.eye(d)
        ev = np.sort(np.linalg.eigvalsh(M))[::-1]
        cU += np.cumsum(np.log1p(2 * eta * ev)); cV += np.cumsum(np.log1p(-2 * eta * ev[::-1]))
        U = U + 2 * eta * M @ U; V = V - 2 * eta * M @ V
    for t in thr:
        K, tt, ratio = argK[t]
        print(f"   K restricted to s_K >= {t:.0e} s_1: max excess = {worst[t]:+.2e}  (at K={K}, t={tt:.2f}, s_K/s_1={ratio:.1e})")
    print(f"   excluding K = d = h = 16 (where the inequality is an EQUALITY, ln|det U_J| = ln|det U_0| + sum ln det(I+2 eta M_j)):"
          f" max excess over K <= 15 resolved to 1e-9 = {worst_below:+.2e}")
    print("   float64 SVD has absolute error ~1e-16 s_1, i.e. relative error ~1e-16/(s_K/s_1) in s_K; the excess should shrink accordingly.")


# ---------------------------------------------------------------- R10
def R10():
    hdr("R10 recompute D7 numbers for x1x2, n=3000 (gamma=0.5, delta=0.05, |Gamma|=2, emp=0)")
    d, n, g = 16, 3000, 0.5
    def cap(K, B):
        el = g / (8 * (d - 1) * max(K, 1)); ez = g / (16 * (d - 1) * (B + 1))
        return K * math.log(2 * math.ceil(B / el) + 1) + d * K * math.log(1 + 2 / ez)
    def bound(K, B, ell):
        lnpi = math.log(2 * 2 * (K + 1) * (K + 2) * (abs(ell) + 1) * (abs(ell) + 2) / 0.05)
        return klinv_upper(0.0, (cap(K, B) + lnpi) / n)
    print(f"   measured N=2, B=1 (l=0): {bound(2,1,0):.4f};  B=2 (l=1): {bound(2,2,1):.4f}   [file: 0.084]")
    print(f"   a priori N=4, B=32 (l=5): {bound(4,32,5):.4f}   [file: 0.213];  N=4, measured B=1: {bound(4,1,0):.4f}")
    print(f"   capacity per unit at B=1, gamma=1/2: {cap(1,1):.1f} nats [file: ~125]")


# ---------------------------------------------------------------- R11
def R11():
    hdr("R11 D3.3 certificate for the real GD network vs the balanced surrogate; Proposition D4.1 along GD (maj3, n=1000, alpha=1e-3)")
    import D_relu_check as DR
    d = 16
    name, n, m, alpha, eta, T = "maj3", 1000, 64, 1e-3, 0.02, 60.0
    rng = np.random.default_rng(0)
    C = DR.cube(d); Ct = np.hstack([C, np.ones((len(C), 1))]); yC = DR.target(name, C)
    idx = rng.choice(len(C), size=n, replace=False)
    Xt, y = Ct[idx], yC[idx]
    W = rng.standard_normal((m, d + 1)); W *= alpha / np.linalg.norm(W, axis=1, keepdims=True)
    a = alpha * rng.choice([-1.0, 1.0], m); eps = np.sign(a)
    steps = int(round(T / eta))
    snaps = {}
    t1 = 15.0; k1 = int(round(t1 / eta))
    attract_ok = None; Qt1 = None; ref = None; clusters = None
    d41 = []
    for k in range(steps + 1):
        Z = Xt @ W.T; S = (Z > 0).astype(float); H = relu(Z); f = H @ a; r = y - f
        if k == k1:
            nw = np.linalg.norm(W, axis=1)
            clusters = [np.where(eps == s)[0] for s in (1.0, -1.0)]
            ref = [c[np.argmax(nw[c])] for c in clusters]
            Qt1 = {j: (nw[j] * nw[rk] - W[j] @ W[rk]) for c, rk in zip(clusters, ref) for j in c}   # balanced form |w_j||w_k|(1-cos)
            attract_ok = {j: True for j in Qt1}
        if k > k1:
            for c, rk in zip(clusters, ref):
                for j in c:
                    sep = S[:, j] != S[:, rk]
                    if np.any(sep & (eps[j] * r > 0)):
                        attract_ok[j] = False
        if k >= k1 and k % 250 == 0:
            nw = np.linalg.norm(W, axis=1); Wn = W / nw[:, None]
            fC = relu(Ct @ W.T) @ a
            g = np.zeros(len(Ct)); rhs = 0.0
            for c, rk in zip(clusters, ref):
                ck = (eps[c] * (a[c] ** 2 + nw[c] ** 2) / 2).sum()
                g += ck * relu(Ct @ Wn[rk])
                for j in c:
                    rhs += math.sqrt(2) * nw[j] ** 1.5 / math.sqrt(nw[rk]) * math.sqrt(max(Qt1[j], 0.0))
            rhs *= math.sqrt(d + 1)
            d41.append((k * eta, float(np.abs(fC - g).max()), rhs, sum(attract_ok.values())))
        if k in (int(round(30 / eta)), steps):
            snaps[k] = (a.copy(), W.copy())
        if k == steps:
            break
        ga = H.T @ r / n; gW = ((S * r[:, None]).T @ Xt / n) * a[:, None]
        a = a + eta * ga; W = W + eta * gW
    for k, (a_, W_) in snaps.items():
        nw = np.linalg.norm(W_, axis=1); Wn = W_ / nw[:, None]; rho = a_ ** 2 + nw ** 2
        f_real_C = relu(Ct @ W_.T) @ a_; f_sur_C = relu(Ct @ Wn.T) @ (eps * rho / 2)
        f_real_S = relu(Xt @ W_.T) @ a_
        val_sur, K, hsup, B, arg = DR.cluster_occam(Wn, rho, eps, Ct, Xt, y, n)
        # same clusters/representatives, but the real network as f
        G = np.where(rho >= 1e-3 * rho.max())[0]
        cl = []
        for j in G:
            for c in cl:
                if Wn[j] @ Wn[c[0]] > 0.99 and eps[j] == eps[c[0]]:
                    c.append(j); break
            else:
                cl.append([j])
        coef = eps * rho / 2
        reps = [((rho[c][:, None] * Wn[c]).sum(0)) for c in cl]; reps = [v / np.linalg.norm(v) for v in reps]
        cs = [coef[c].sum() for c in cl]
        g_C = relu(Ct @ np.array(reps).T) @ np.array(cs)
        hsup_real = float(np.abs(f_real_C - g_C).max())
        gm = arg[0]
        emp_real = float(np.mean(y * f_real_S <= gm))
        Bd = 2.0 ** math.ceil(math.log2(max(B, 1e-12))); bexp = int(round(math.log2(Bd)))
        eta_d = gm / (8 * Bd * math.sqrt(d + 1)); eta_c = gm / (8 * max(K, 1) * math.sqrt(d + 1))
        lnG = K * ((d + 1) * math.log(1 + 2 / eta_d) + math.log(2 * math.ceil(Bd / eta_c) + 1))
        lnpi = math.log((K + 1) * (K + 2)) + math.log(2 * (abs(bexp) + 1) * (abs(bexp) + 2)) + math.log(3)
        val_real = klinv_upper(emp_real, (lnG + lnpi + math.log(20)) / n) if hsup_real <= gm / 4 else 1.0
        terr_real = float(np.mean(np.where(f_real_C >= 0, 1, -1) != yC))
        print(f"   t={k*eta:5.1f}: sup_cube|f_GD - f_surrogate| = {np.abs(f_real_C-f_sur_C).max():.2e};  "
              f"surrogate: sup|f-g|={hsup:.2e}, bound={val_sur:.3f};  real GD net: sup|f-g|={hsup_real:.2e}, "
              f"bound={val_real:.3f}, test err={terr_real:.4f}")
    print("   Proposition D4.1 along GD (checkpoint t1=15, clusters = sign classes, ref = largest neuron; no dormant neurons):")
    for t, lhs, rhs, nok in d41:
        print(f"     t={t:5.1f}  sup|f_t - g_t| = {lhs:.3e}  D4.1 right side = {rhs:.3e}  ({'holds' if lhs <= rhs else 'VIOLATED'});"
              f"  neurons with (A) held on [t1,t] at every GD step: {nok}/64")


if __name__ == "__main__":
    which = sys.argv[1].split(",") if len(sys.argv) > 1 else ["R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9", "R10", "R11"]
    for w in which:
        globals()[w]()
    print(f"\ndone in {time.time()-T0:.0f}s")

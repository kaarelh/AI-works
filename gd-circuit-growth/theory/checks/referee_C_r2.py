"""Referee round 2 for C-bridge-and-certificates.md (revision 2): independent numerical checks.

Everything here is re-implemented from the statements in the file (it does not import c_common.py), so that a
shared bug would show up as a mismatch.

  (1) Lemma C0.1 for [0,1]-valued variables (new in revision 2): Monte Carlo failure rates against e^{-n eps}.
  (2) Corollary C2.5 choices 2-3 (new): the Gershgorin fixed point and the monotonicity argument on a grid;
      Gershgorin bound on random unit-diagonal Gram matrices.
  (3) Diagonal network, gradient flow, independent integration (mirror form in G): Theorems C2.2(1)-(2), C2.3(1)-(3),
      and the three admissible size bounds of Corollary C2.5 at every grid time and several eps.
      Also the empirically orthogonal case (full cube): do other coordinates stay exactly zero?
  (4) Hoeffding coherence event of Theorem C2.3(2)/C2.5(3): frequency of mu_n > mubar over random training sets.
  (5) Proposition C2.6 item 6 (new): GD version of C2.5 choices 1-3 with x_K = tau_K^2/(Theta - Phi_K)^2;
      SGD item 3 (no early growth in minibatch effective time).
  (6) Section 1.2 pair estimator identity  E 1/2 (f(x)-f(x'))^2 = ||f - E[f|x_R]||^2 = sum_{S not in R} fhat^2
      <= sum_{i notin R} Inf_i  (exact on a small cube).
  (7) Theorem C3.4: the library constants. Real-valued gates can give more readout dichotomies than the Boolean
      constant allows (exact count by LP); L^2-form inequality P(yf<=0) <= P(yf^M<=gamma) + eta^2/gamma^2.
  (8) Corollary C3.5(1): Hoeffding constant for [0,4]-valued squared differences (simulation).
  (9) Class sizes quoted in sections 1.2 and 1.5, recomputed independently.
 (10) Remark C4.5 (consistent online learner) by simulation, and C4.3 arithmetic.
 (11) Float16 transfer term and the maj9 slack arithmetic (section 1.3, 1.5).

Runs in about two minutes on one core with OPENBLAS_NUM_THREADS=1.
"""
import os
os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")
import sys, math, itertools, time
sys.dont_write_bytecode = True
import numpy as np
from scipy.integrate import solve_ivp
from scipy.optimize import linprog
import warnings
warnings.filterwarnings("ignore", category=RuntimeWarning)   # overflow in rejected LSODA trial steps only; accepted
                                                             # solutions are asserted finite in flow()

T0 = time.time()


# ------------------------------------------------------------------ independent helpers
def kl(q, p):
    q = np.clip(q, 0.0, 1.0); p = np.clip(p, 1e-300, 1 - 1e-16)
    a = np.where(q > 0, q * np.log(np.where(q > 0, q, 1) / p), 0.0)
    b = np.where(q < 1, (1 - q) * np.log(np.where(q < 1, 1 - q, 1) / (1 - p)), 0.0)
    return a + b


def klinv(q, eps, iters=80):
    q = np.asarray(q, float); eps = np.broadcast_to(np.asarray(eps, float), q.shape)
    lo, hi = q.copy(), np.ones_like(q)
    for _ in range(iters):
        mid = (lo + hi) / 2
        bad = kl(q, mid) > eps
        hi = np.where(bad, mid, hi); lo = np.where(bad, lo, mid)
    return hi


def lbinom(a, b):
    return math.lgamma(a + 1) - math.lgamma(b + 1) - math.lgamma(a - b + 1)


def lPhi(N, T):
    """ln Phi(N,T) = ln(2 sum_{i<=T} C(N-1,i))."""
    terms = [lbinom(N - 1, i) for i in range(0, min(T, N - 1) + 1)]
    m = max(terms)
    return math.log(2) + m + math.log(sum(math.exp(t - m) for t in terms))


def Gamma(mu, x):
    return (1 - mu) * x / (1 - mu * x)


out = []
def P(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)


# ------------------------------------------------------------------ (1) Lemma C0.1 for [0,1] variables
def part1():
    P("(1) Lemma C0.1, [0,1]-valued: max over eps grid of P(p > klinv(phat, eps)) / e^{-n eps} (must be <= 1 up to MC error)")
    rng = np.random.default_rng(1)
    reps = 100000
    dists = {
        "Bernoulli(0.1)": lambda s: (rng.random(s) < 0.1).astype(float),
        "unif{0,1/2,1}": lambda s: rng.integers(0, 3, s) / 2.0,
        "Beta(0.3,2)": lambda s: rng.beta(0.3, 2.0, s),
        "0 w.p. .7, else .25": lambda s: np.where(rng.random(s) < 0.7, 0.0, 0.25),
        "0 w.p. .95, else 1": lambda s: np.where(rng.random(s) < 0.95, 0.0, 1.0),
    }
    means = {"Bernoulli(0.1)": 0.1, "unif{0,1/2,1}": 0.5, "Beta(0.3,2)": 0.3 / 2.3,
             "0 w.p. .7, else .25": 0.075, "0 w.p. .95, else 1": 0.05}
    for n in (10, 50):
        for name, f in dists.items():
            Z = f((reps, n)); ph = Z.mean(1); p = means[name]
            worst = 0.0; worst_eps = None
            for eps in np.linspace(0.005, 0.3, 20):
                fail = np.mean((ph < p) & (kl(ph, np.full_like(ph, p)) > eps))   # = {p > klinv(phat, eps)}
                bound = math.exp(-n * eps)
                if bound > 20 / reps:     # only where the MC estimate is meaningful
                    r = fail / bound
                    if r > worst:
                        worst, worst_eps = r, eps
            P(f"    n={n:3d} {name:22s} max ratio {worst:.3f} (at eps={worst_eps:.3f})")


# ------------------------------------------------------------------ (2) C2.5 choices 2-3: algebra
def part2():
    P("(2) Corollary C2.5 choices 2-3: algebra on a grid")
    rng = np.random.default_rng(2)
    viol_fix = viol_mono = viol_small = 0; cnt = 0
    for _ in range(200000):
        mun = rng.random() * 0.6; mub = mun + rng.random() * 0.6
        x = rng.random() * 6; xb = x + rng.random() * 6
        if mub * xb >= 1:
            continue
        cnt += 1
        # every integer N with N <= (1+(N-1)mun) x must satisfy N <= floor(Gamma(mun,x)) <= floor(Gamma(mub,xb))
        for N in range(0, 60):
            if N <= (1 + (N - 1) * mun) * x + 1e-12 and N >= 1:
                if N > math.floor(Gamma(mun, x) + 1e-12):
                    viol_fix += 1
                if N > math.floor(Gamma(mub, xb) + 1e-12):
                    viol_mono += 1
        if x < 1 and Gamma(mun, x) >= 1:
            viol_small += 1
    P(f"    {cnt} admissible (mu_n<=mubar, x<=xbar, mubar*xbar<1) points: violations of N<=Gamma(mu_n,x): {viol_fix};"
      f" of N<=Gamma(mubar,xbar): {viol_mono}; x<1 but Gamma>=1: {viol_small}")
    # Gershgorin on random unit-diagonal PSD Gram matrices with coherence mu
    worst = 0
    for _ in range(3000):
        N = rng.integers(2, 30); m = rng.integers(N, 200)
        A = rng.choice([-1.0, 1.0], size=(m, N))
        K = A.T @ A / m
        mu = np.max(np.abs(K - np.eye(N)))
        worst = max(worst, np.linalg.eigvalsh(K)[-1] / (1 + (N - 1) * mu))
    P(f"    Gershgorin: max lambda_max(K_B)/(1+(N-1)mu) over 3000 random +-1 Gram matrices = {worst:.4f} (<=1)")


# ------------------------------------------------------------------ diagonal network
def char_sets(d, k):
    return [S for j in range(k + 1) for S in itertools.combinations(range(d), j)]


def char_matrix(X, sets):
    C = np.ones((len(X), len(sets)))
    for j, S in enumerate(sets):
        for i in S:
            C[:, j] *= X[:, i]
    return C


TGT = {
    "x1": lambda X: X[:, 0],
    "par2": lambda X: X[:, 0] * X[:, 1],
    "maj3": lambda X: np.sign(X[:, 0] + X[:, 1] + X[:, 2]),
    "and3": lambda X: np.where((X[:, 0] > 0) & (X[:, 1] > 0) & (X[:, 2] > 0), 1.0, -1.0),
    "maj5": lambda X: np.sign(X[:, :5].sum(1)),
}


def flow(C, y, alpha, t_max, n_grid):
    """Mirror-form gradient flow: state (G, tau, A2 = int|g|_2, R = int r)."""
    n, D = C.shape

    def rhs(t, z):
        G = z[:D]
        w = -2 * alpha ** 2 * np.sinh(np.clip(4 * G, -700, 700))   # clip only guards LSODA trial steps
        r = y - C @ w
        g = -C.T @ r / n
        return np.concatenate([g, [np.sqrt(np.mean(r ** 2)), np.linalg.norm(g)], r])

    z0 = np.zeros(D + 2 + n)
    ts = np.linspace(0, t_max, n_grid)
    sol = solve_ivp(rhs, (0, t_max), z0, method="LSODA", t_eval=ts, rtol=1e-10, atol=1e-13)
    assert sol.success and np.all(np.isfinite(sol.y)) and np.max(np.abs(4 * sol.y[:D])) < 700, "integration failed"
    return ts, sol.y.T


def part3(d=10, k=3, delta_p=0.05):
    P(f"(3) diagonal network, gradient flow (independent LSODA integration of the mirror form), d={d}, k={k}")
    sets = char_sets(d, k); D = len(sets)
    D2k = sum(math.comb(d, i) for i in range(min(2 * k, d) + 1))
    cube = np.array(list(itertools.product([-1.0, 1.0], repeat=d)))
    worst = {"C2.3(1)": 0, "C2.3(2)": 0, "gersh": 0, "hoeff_tau": 0, "hoeff_t": 0}
    viol = {k_: 0 for k_ in ["C2.2(1)", "C2.2(2)", "C2.3(1)", "C2.3(2)", "C2.3(3)", "gersh", "hoeff_tau", "hoeff_t"]}
    checks = 0; brackets = 0; id_err = 0.0
    runs = [("par2", 100, 1e-3), ("maj3", 100, 1e-3), ("maj3", 400, 1e-3), ("and3", 400, 1e-3), ("x1", 64, 1e-3),
            ("maj5", 100, 1e-3), ("par2", 100, 1e-8), ("and3", 400, 1e-8), ("x1", 400, 1e-8)]
    for ir, (name, n, alpha) in enumerate(runs):
        rng = np.random.default_rng(300 + ir)
        X = rng.choice([-1.0, 1.0], size=(n, d)); y = TGT[name](X)
        C = char_matrix(X, sets); K = C.T @ C / n
        mun = np.max(np.abs(K - np.eye(D)))
        mub = math.sqrt(2 * math.log(2 * D2k / delta_p) / n)
        lam = np.linalg.eigvalsh(K)[-1]
        U = np.abs(C.T @ y / n); U0 = U.max()
        t_max = 40.0 if alpha > 1e-6 else 60.0
        ts, Z = flow(C, y, alpha, t_max, 801)
        for eps in (1e-4, 1e-3, 1e-2, 1e-1, 0.5 / (2 * D)):
            Th = 0.25 * math.asinh(eps / (2 * alpha ** 2))
            # C2.2(2) bracket (grid resolution dt = t_max/800)
            epsD = math.sqrt(lam * D) * eps
            tesc = None
            for t, z in zip(ts, Z):
                if np.max(np.abs(z[:D])) >= Th:
                    tesc = t; break
            if U0 > epsD and tesc is not None:
                brackets += 1
                dt = ts[1] - ts[0]
                if not (Th / (U0 + epsD) - 1e-9 <= tesc and tesc - dt <= Th / (U0 - epsD) + 1e-9):
                    viol["C2.2(2)"] += 1
            for t, z in zip(ts, Z):
                G = z[:D]; tau = z[D]; A2 = z[D + 1]; R = z[D + 2:]
                w = -2 * alpha ** 2 * np.sinh(4 * G)
                B = np.where(np.abs(w) >= eps)[0]; N = len(B)
                checks += 1
                if tau < Th and N > 0:
                    viol["C2.2(1)"] += 1
                if N == 0:
                    continue
                b1 = A2 ** 2 / Th ** 2
                kB = np.linalg.eigvalsh(K[np.ix_(B, B)])[-1]
                x = (tau / Th) ** 2
                b2 = kB * x
                worst["C2.3(1)"] = max(worst["C2.3(1)"], N / b1); worst["C2.3(2)"] = max(worst["C2.3(2)"], N / b2)
                viol["C2.3(1)"] += N > b1 * (1 + 1e-7); viol["C2.3(2)"] += N > b2 * (1 + 1e-7)
                if mun * x < 1:
                    g2 = math.floor(Gamma(mun, x) + 1e-9)
                    worst["gersh"] = max(worst["gersh"], N / max(g2, 1e-9)); viol["gersh"] += N > g2
                if mun <= mub:
                    for key, xb in (("hoeff_tau", x), ("hoeff_t", (t / Th) ** 2)):
                        if mub * xb < 1:
                            g3 = 0 if xb < 1 else math.floor(Gamma(mub, xb) + 1e-9)
                            worst[key] = max(worst[key], N / max(g3, 1e-9)); viol[key] += N > g3
                # l1 identity: sum |w||G| = <R, f>_n
                f = C @ w
                lhs = np.sum(np.abs(w) * np.abs(G)); rhs = np.mean(R * f)
                id_err = max(id_err, abs(lhs - rhs) / max(abs(rhs), 1e-12))
                if not (np.sum(np.abs(w[B])) <= rhs / Th * (1 + 1e-6) + 1e-12 and rhs <= tau * math.sqrt(np.mean(f ** 2)) * (1 + 1e-9) + 1e-12
                        and math.sqrt(np.mean(f ** 2)) <= 2 + 1e-9):
                    viol["C2.3(3)"] += 1
        P(f"    {name:5s} n={n:3d} alpha={alpha:.0e}: mu_n={mun:.3f} mubar={mub:.3f} lam_max={lam:.2f} U0={U0:.3f};"
          f" final train loss {0.5*np.mean((y - C @ (-2*alpha**2*np.sinh(4*Z[-1,:D])))**2):.1e}")
    P(f"    {checks} (time, eps) checks, {brackets} first-escape brackets. Violations: {viol}")
    P(f"    worst N/bound ratios: " + ", ".join(f"{k_} {v:.3f}" for k_, v in worst.items()) +
      f"; l1 identity max rel. error {id_err:.1e}")
    # empirically orthogonal dictionary: full cube, y = chi_{S*}
    d2, k2 = 6, 2
    sets2 = char_sets(d2, k2); cube2 = np.array(list(itertools.product([-1.0, 1.0], repeat=d2)))
    C2 = char_matrix(cube2, sets2); y2 = cube2[:, 0] * cube2[:, 1]
    ts, Z = flow(C2, y2, 1e-3, 20.0, 201)
    G = Z[-1, :len(sets2)]; j = sets2.index((0, 1))
    others = np.max(np.abs(np.delete(G, j)))
    P(f"    full cube d={d2}, y=chi_12: |G_S*|/tau = {abs(G[j])/Z[-1,len(sets2)]:.10f}; max_{{S!=S*}} |w_S(t=20)| ="
      f" {2e-6*np.sinh(4*others):.1e} (the file says 'every coordinate is nonzero for t>0')")


# ------------------------------------------------------------------ (4) Hoeffding coherence event
def part4(d=10, k=3, delta_p=0.05, reps=1000):
    P(f"(4) Hoeffding coherence event: P(mu_n > mubar) over {reps} training sets (must be <= delta' = {delta_p})")
    sets = char_sets(d, k); D2k = sum(math.comb(d, i) for i in range(min(2 * k, d) + 1))
    rng = np.random.default_rng(4)
    for n in (100, 400):
        mub = math.sqrt(2 * math.log(2 * D2k / delta_p) / n)
        fails = 0; mus = []
        for _ in range(reps):
            X = rng.choice([-1.0, 1.0], size=(n, d)); C = char_matrix(X, sets)
            K = C.T @ C / n; mu = np.max(np.abs(K - np.eye(len(sets)))); mus.append(mu)
            fails += mu > mub
        P(f"    n={n}: mubar={mub:.3f}, median mu_n={np.median(mus):.3f}, max {np.max(mus):.3f}, failure rate {fails/reps:.3f}")


# ------------------------------------------------------------------ (5) Proposition C2.6
def part5(d=10, k=3):
    P("(5) Proposition C2.6: GD version of C2.5 (item 6) and SGD no-early-growth (item 3)")
    sets = char_sets(d, k); D = len(sets)
    D2k = sum(math.comb(d, i) for i in range(min(2 * k, d) + 1))
    viol = {"item5": 0, "gersh_GD": 0, "hoeff_GD": 0, "item3_SGD": 0, "item4_SGD": 0}
    worst = {"item5": 0, "gersh_GD": 0, "hoeff_GD": 0, "item4_SGD": 0}
    nchk = 0
    for name, n, alpha, eta in [("maj3", 400, 1e-3, 0.1), ("and3", 400, 1e-3, 0.05), ("par2", 100, 1e-3, 0.2),
                                ("maj5", 100, 1e-3, 0.1), ("x1", 64, 1e-4, 0.2)]:
        rng = np.random.default_rng(5)
        X = rng.choice([-1.0, 1.0], size=(n, d)); y = TGT[name](X); C = char_matrix(X, sets)
        K = C.T @ C / n; mun = np.max(np.abs(K - np.eye(D))); mub = math.sqrt(2 * math.log(2 * D2k / 0.05) / n)
        for mode in ("GD", "SGD"):
            u = np.full(D, alpha); v = np.full(D, alpha)
            psi = np.zeros(D); tau = 0.0; Phi = 0.0; Gm = 0.0; taub = 0.0; sumg = 0.0
            steps = 1500 if mode == "GD" else 3000
            for j in range(steps):
                w = u * u - v * v
                if mode == "GD":
                    r = y - C @ w; g = -C.T @ r / n; rn = math.sqrt(np.mean(r ** 2))
                else:
                    idx = rng.integers(0, n, 16); r = y[idx] - C[idx] @ w; g = -C[idx].T @ r / 16
                    rn = math.sqrt(np.mean(r ** 2))
                z = 2 * eta * np.max(np.abs(g))
                if z >= 1:
                    P(f"    {name} {mode}: 2 eta |g|_inf >= 1 at step {j}; stopped"); break
                Gm = max(Gm, np.max(np.abs(g)))
                Phi += 0.5 * z ** 3 / (3 * (1 - z ** 2))
                psi += np.arctanh(2 * eta * g)
                if mode == "GD":
                    tau += eta * rn
                else:
                    taub += eta * rn
                sumg += eta * np.linalg.norm(g)
                u = u * (1 - 2 * eta * g); v = v * (1 + 2 * eta * g)
                w = u * u - v * v
                c = 1 / (1 - 4 * eta ** 2 * Gm ** 2)
                for eps in (1e-3, 1e-2, 1e-1, 0.5 / (2 * D)):
                    Th = 0.25 * math.asinh(eps / (2 * alpha ** 2))
                    B = np.where(np.abs(w) >= eps)[0]; N = len(B); nchk += 1
                    if mode == "SGD":
                        if N > 0 and taub < Th * (1 - 4 * eta ** 2 * Gm ** 2):
                            viol["item3_SGD"] += 1
                        if N > 0:
                            b4 = (c * sumg) ** 2 / Th ** 2
                            worst["item4_SGD"] = max(worst["item4_SGD"], N / b4); viol["item4_SGD"] += N > b4 * (1 + 1e-9)
                        continue
                    if N == 0 or Th <= Phi:
                        continue
                    kB = np.linalg.eigvalsh(K[np.ix_(B, B)])[-1]
                    xK = tau ** 2 / (Th - Phi) ** 2
                    b5 = kB * xK
                    worst["item5"] = max(worst["item5"], N / b5); viol["item5"] += N > b5 * (1 + 1e-9)
                    if mun * xK < 1:
                        g2 = 0 if xK < 1 else math.floor(Gamma(mun, xK) + 1e-9)
                        worst["gersh_GD"] = max(worst["gersh_GD"], N / max(g2, 1e-9)); viol["gersh_GD"] += N > g2
                    if mun <= mub and mub * xK < 1:
                        g3 = 0 if xK < 1 else math.floor(Gamma(mub, xK) + 1e-9)
                        worst["hoeff_GD"] = max(worst["hoeff_GD"], N / max(g3, 1e-9)); viol["hoeff_GD"] += N > g3
    P(f"    {nchk} (step, eps) checks; violations {viol}; worst ratios " + ", ".join(f"{k_} {v:.3f}" for k_, v in worst.items()))


# ------------------------------------------------------------------ (6) pair estimator identity
def part6():
    P("(6) Section 1.2: E 1/2 (f(x)-f(x'))^2 = ||f-E[f|x_R]||^2 = sum_{S not<= R} fhat(S)^2 <= sum_{i notin R} Inf_i (exact, d=7)")
    d = 7; cube = np.array(list(itertools.product([-1.0, 1.0], repeat=d)))
    sets = char_sets(d, d); C = char_matrix(cube, sets)
    rng = np.random.default_rng(6); worst_id = 0; worst_ineq = -1
    for _ in range(50):
        f = np.tanh(2 * rng.normal(size=len(cube)) + 3 * cube[:, 0] * cube[:, 1])
        R = list(rng.choice(d, size=rng.integers(0, d), replace=False))
        fhat = C.T @ f / len(cube)
        tail = sum(fhat[j] ** 2 for j, S in enumerate(sets) if not set(S) <= set(R))
        # pair expectation: x' agrees on R, fresh elsewhere
        keyR = [tuple(x[R]) for x in cube]
        groups = {}
        for i, kk in enumerate(keyR):
            groups.setdefault(kk, []).append(i)
        pair = 0.0
        for idx in groups.values():
            vals = f[idx]
            pair += len(idx) / len(cube) * 0.5 * np.mean((vals[:, None] - vals[None, :]) ** 2)
        infl = 0.0
        for i in range(d):
            if i in R:
                continue
            flip = cube.copy(); flip[:, i] *= -1
            jj = [int("".join("1" if b > 0 else "0" for b in x), 2) for x in flip]
            infl += np.mean((f - f[jj]) ** 2) / 4
        worst_id = max(worst_id, abs(pair - tail)); worst_ineq = max(worst_ineq, tail - infl)
    P(f"    max |pair - Fourier tail| = {worst_id:.1e}; max (tail - influence sum) = {worst_ineq:.2e} (<= 0)")


# ------------------------------------------------------------------ (7) Theorem C3.4 constants and L2 form
def count_threshold_dichotomies(Z):
    """Exact number of {sgn(c0 + c.z)} labelings of the distinct rows of Z (strict-separation LP; sgn(0)=+1 handled
    by strict patterns, which Lemma C0.2 step 1 shows suffice)."""
    Z = np.unique(Z, axis=0); N, T = Z.shape
    A = np.hstack([np.ones((N, 1)), Z]); cnt = 0
    for lab in itertools.product([-1, 1], repeat=N):
        lab = np.array(lab)
        res = linprog(np.zeros(T + 1), A_ub=-(lab[:, None] * A), b_ub=-np.ones(N), bounds=[(None, None)] * (T + 1),
                      method="highs")
        cnt += res.status == 0
    return N, cnt


def part7():
    P("(7) Theorem C3.4 library constants; L^2-form inequality")
    # one real-valued gate g(x) = relu(x1 + x2) on d=2: gate vector image has 3 points > 2^min(T,d) = 2
    cube = np.array(list(itertools.product([-1.0, 1.0], repeat=3)))
    g1 = np.minimum(np.maximum(cube[:, 0] + 0.5 * cube[:, 1], 0), 1)
    N, cnt = count_threshold_dichotomies(g1[:, None])
    P(f"    T=1 real gate min(relu(x1+x2/2),1): {N} image points, {cnt} readout dichotomies; Boolean constant"
      f" Phi(2^min(T,d),T)={math.exp(lPhi(2,1)):.0f} (too small), real-valued constant Phi(2^d,T)={math.exp(lPhi(8,1)):.0f}")
    g2 = np.maximum(cube[:, 0] - cube[:, 2], 0) * 0.7 + 0.1 * cube[:, 1]
    N, cnt = count_threshold_dichotomies(np.stack([g1, g2], 1))
    P(f"    T=2 real gates: {N} image points, {cnt} dichotomies; Boolean constant Phi(4,2)={math.exp(lPhi(4,2)):.0f},"
      f" real-valued Phi(8,2)={math.exp(lPhi(8,2)):.0f}")
    # L2 form on random functions over a small cube
    rng = np.random.default_rng(7); viol = 0; tot = 0
    for _ in range(20000):
        m = 64
        y = rng.choice([-1.0, 1.0], size=m)
        fM = y * rng.normal(0.5, 1.0, size=m) * 1.5
        fth = fM + rng.normal(0, rng.random() * 1.5, size=m)
        gam = rng.uniform(0.01, 0.99)
        lhs = np.mean(y * fth <= 0)
        eta2 = np.mean((np.clip(fth, -1, 1) - np.clip(fM, -1, 1)) ** 2)
        rhs = np.mean(y * fM <= gam) + eta2 / gam ** 2
        tot += 1; viol += lhs > rhs + 1e-12
        if not np.all((y * fM <= gam) == (y * np.clip(fM, -1, 1) <= gam)):
            viol += 1
    P(f"    P(yf<=0) <= P(yf^M<=gamma) + ||clip f - clip f^M||^2/gamma^2, and yf<=gamma <=> y clip f<=gamma: {viol} violations in {tot}")


# ------------------------------------------------------------------ (8) Corollary C3.5(1) L2 constant
def part8():
    P("(8) Corollary C3.5(1): P(E Z > mean + 4 sqrt(ln(1/d)/(2m))) <= d for Z in [0,4] (one fixed pair)")
    rng = np.random.default_rng(8)
    for m, dlt in ((50, 0.05), (400, 0.01)):
        for name, f in (("4*Bernoulli(.5)", lambda s: 4.0 * (rng.random(s) < 0.5)), ("4*Beta(.2,.2)", lambda s: 4 * rng.beta(.2, .2, s))):
            Z = f((100000, m)); mu = 2.0
            fail = np.mean(mu > Z.mean(1) + 4 * math.sqrt(math.log(1 / dlt) / (2 * m)))
            P(f"    m={m} delta={dlt} {name}: failure rate {fail:.5f}")


# ------------------------------------------------------------------ (9) class sizes
def part9():
    P("(9) class sizes (nats), independent recomputation, d=30")
    d = 30
    Dk = lambda k: sum(math.comb(d, i) for i in range(1, k + 1))
    lF = lambda k, T: lbinom(Dk(k), T) + lPhi(2 ** min(T, d), T)
    def lC(T):
        terms = [s * math.log(16 * (d + s) ** 2) + math.log(d + s) - math.lgamma(s + 1) for s in range(T + 1)]
        m = max(terms); return m + math.log(sum(math.exp(t - m) for t in terms))
    Nj = lambda j: sum((-1) ** (j - i) * math.comb(j, i) * 2 ** (2 ** i) for i in range(j + 1))
    lJ = lambda k: math.log(sum(math.comb(d, j) * Nj(j) for j in range(k + 1)))
    P(f"    F_(1,9) {lF(1,9):.1f}  F_(1,10) {lF(1,10):.1f}  F_(2,3) {lF(2,3):.1f}  F_(3,1) {lF(3,1):.1f}  F_(8,1) {lF(8,1):.1f}"
      f"  F_(3,18) {lF(3,18):.1f}  F_(3,19) {lF(3,19):.1f}  F_(3,21) {lF(3,21):.1f}  F_(2,18) {lF(2,18):.1f}")
    P(f"    C_<=7 {lC(7):.1f}  C_<=8 {lC(8):.1f}  J_<=8 {lJ(8):.1f}  J_<=9 {lJ(9):.1f}  J_<=3 {lJ(3):.2f}  J_<=5 {lJ(5):.2f}")
    # dnf3 21-character representation: GF(2) rank of the 21 supports (the Proposition C1.2(2) bound uses 2^min(T,d))
    terms = [(0, 1, 2), (3, 4, 5), (6, 7, 8)]
    sup = [S for t in terms for r in (1, 2, 3) for S in itertools.combinations(t, r)]
    M = np.array([[1 if i in S else 0 for i in range(d)] for S in sup], dtype=np.uint8)
    def gf2rank(M):
        M = M.copy(); r = 0
        for c in range(M.shape[1]):
            piv = [i for i in range(r, M.shape[0]) if M[i, c]]
            if not piv:
                continue
            M[[r, piv[0]]] = M[[piv[0], r]]
            for i in range(M.shape[0]):
                if i != r and M[i, c]:
                    M[i] ^= M[r]
            r += 1
        return r
    rk = gf2rank(M)
    P(f"    dnf3 sign representation: {len(sup)} supports, GF(2) rank {rk}; with the rank refinement of C1.2(2)"
      f" the support's own class has ln Phi(2^{rk},21) = {lPhi(2**rk,21):.1f} vs ln Phi(2^21,21) = {lPhi(2**21,21):.1f}")
    # the maj9 slack quoted in 1.5
    P(f"    maj9 slack (60.4+6.6+3.7)/2048 = {(60.4+6.6+3.7)/2048:.4f}; ln(8*9*10) = {math.log(720):.2f}; ln(1/0.025) = {math.log(40):.2f}")


# ------------------------------------------------------------------ (10) Remark C4.5 and C4.3 arithmetic
def part10():
    P("(10) Remark C4.5 by simulation (adversarially chosen consistent hypothesis); C4.3 arithmetic")
    rng = np.random.default_rng(10)
    M = 200; H = np.arange(M + 1)  # thresholds h_c(x) = 1[x >= c] on x uniform in {0..M-1}
    for target in (37, 150):
        for N in (50, 500):
            mist = []
            for _ in range(400):
                lo, hi = 0, M  # consistent thresholds c in [lo, hi]
                mcount = 0
                for i in range(N):
                    # adversarial consistent choice: the endpoint farthest from the target
                    c = lo if abs(lo - target) > abs(hi - target) else hi
                    x = rng.integers(0, M); yv = int(x >= target)
                    mcount += int(int(x >= c) != yv)
                    if yv == 1:
                        hi = min(hi, x)
                    else:
                        lo = max(lo, x + 1)
                mist.append(mcount)
            bound = 1 + (math.log(len(H)) + math.log(N)) * (1 + math.log(N)) + (1 + math.log(N))
            P(f"    target {target}, N={N}: E[M_N] = {np.mean(mist):.2f}  <=  bound {bound:.1f}")
    L = 1.0
    P(f"    C4.3: (b/eta)(5 Theta/(4U*)) at b/eta = 80 U* L/(Theta gamma^2) equals {80*5/4:.0f} L/gamma^2; "
      f"par2 example: 100*ln(2*2205/0.05)/0.25 = {100*math.log(2*2205/0.05)/0.25:.0f}")


# ------------------------------------------------------------------ (11) fp16 term
def part11():
    P("(11) section 1.3 float16 transfer: klinv(j/4096, ln(100)/4096) for j = 0, 1, 2")
    P("    " + "  ".join(f"j={j}: {float(klinv(np.array([j/4096]), math.log(100)/4096)[0]):.5f}" for j in (0, 1, 2)))
    P(f"    C3.5 eps^U with |T|=15, |Sigma|=23, delta=0.05, m=4096: {math.log(2*15*23/0.05)/4096:.2e}")


if __name__ == "__main__":
    for f in (part1, part2, part3, part4, part5, part6, part7, part8, part9, part10, part11):
        t = time.time(); f(); P(f"    [{time.time()-t:.0f}s]")
    P(f"total {time.time()-T0:.0f}s")

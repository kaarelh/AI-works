"""Repair checks for T5 after adversarial verification (see the Verification log in T5).
Each block re-checks one referee issue or one revised statement.  Run: python3 repair_checks.py"""
from math import log2, log, sqrt, comb, ceil, inf
import itertools, random
import numpy as np
random.seed(7); rng = np.random.default_rng(7)
def H(p): return 0.0 if p in (0, 1) else -(p*log2(p)+(1-p)*log2(1-p))
def g(t): return 1 - log2(1 + 2.0**(1-t))          # exact per-region risk floor (Lemma 2.5b, p=0)
def s(t): return 2*t + 2*log2(t+1)                  # list-decoding cost
print("=" * 78)

# ---------------------------------------------------------------- Thm 3.3 (fatal) -------------
print("[Thm 3.3] referee counterexample to the OLD clause 2 (m=1, pi=1, d=40, a K-random):")
G2 = g(2)
for kappa in [10, 100, 1000]:
    for q in [0.74, 0.745, 0.749]:
        d, pi = 40, 1.0
        c = 1e-6/(kappa+100)
        shat = 2*q-1; R = -log2(q)
        Kh = d + 2*log2(d) + kappa                         # upper bound on K(h_q), generous
        eta = c*Kh + R                                     # eta := J_c(h_q) >= J_c(h_q) - Phi
        D0 = c*((2*log2(d) + 0 + 4 + kappa) + kappa) + pi*2**(1-d/4)
        Dl = 2*D0 + eta
        old = (pi > c*d + Dl + pi*2**(1-d/4)) and (pi > 2*Dl + 16*c)
        new = (pi*(1 - log2(1+2**(1-d/4))) > c*d + Dl) and (pi*G2 > Dl + 8*c)
        print(f"   kappa={kappa:5d} q={q}: shat={shat:.3f}<1/2, R={R:.4f}; old hyps hold: {old}; "
              f"new hyps hold: {new}  (new threshold (Delta+8c)/g(2) = {(Dl+8*c)/G2:.4f})")
print(f"   g(2) = 1-log2(3/2) = {G2:.5f}; 1/g(2) = {1/G2:.4f};  sqrt2-1 = {sqrt(2)-1:.4f}")

# concavity of g and the identification inequality under the NEW hypotheses
viol = 0; tests = 0
for _ in range(20000):
    d = random.randint(8, 200); pi = 10**random.uniform(-3, 0); c = 10**random.uniform(-7, -1)
    Dl = 10**random.uniform(-6, 0)
    if not ((pi*(1 - log2(1+2**(1-d/4))) > c*d + Dl) and (pi*G2 > Dl + 8*c)): continue
    tests += 1
    lb = min(max(c*(d - 4*t), 0) + pi*g(t) for t in range(2, 4*d))   # phi_j(t) >= c(d-4t)^+ + pi g(t)
    lb = min(lb, pi*1.0)                                                # t = infinity: R_j >= 1
    if not lb > c*d + Dl: viol += 1
print(f"[Thm 3.3] new clause 2: phi_j(t) > c d_j + Delta for all integer t>=2 under the new hypotheses: "
      f"{viol} violations in {tests} random admissible instances")

# two-sided estimate: min_t phi_j(t) >= min(cd,pi) - 4c - pi 2^{1-d/4} (stated Delta_0, no 1/ln2)
viol = 0; worst = inf
for d in list(range(1, 64)) + [80, 100, 200, 400]:
    for e in range(-60, 10):
        c = 2**(e/4)
        for pi in [1e-3, 3e-3, 1e-2, 3e-2, 0.1, 0.3, 1.0]:
            rhs = min(c*d, pi) - 4*c - pi*2**(1-d/4)
            for ss in (s, lambda t: 4*t):
                phis = [c*d] + [max(c*(d - ss(t)), 0) + pi*g(t) for t in range(1, 4*d+8)] + [pi]
                m_ = min(phis); worst = min(worst, m_ - rhs)
                if m_ < rhs - 1e-12: viol += 1
print(f"[Thm 3.3] per-region lower bound with the stated Delta_0: {viol} violations; min slack {worst:.3e}")
xs = np.linspace(1, 400, 400000)
print(f"   absorption needs 0.4427*2^(1-d/4) <= 4/d: max_d d*0.8854*2^(-d/4) = "
      f"{np.max(xs*(1/log(2)-1)*2*2**(-xs/4)):.3f} <= 4")

# ---------------------------------------------------------------- Thm 2.1 ---------------------
print("\n[Thm 2.1] F = {(a,a),(a,b),(b,a),(c,a)} on two inputs: minimax value vs sum log|F(x)|")
F = [("a", "a"), ("a", "b"), ("b", "a"), ("c", "a")]
from scipy.optimize import minimize
def negHQ(z):
    Q = np.exp(z)/np.exp(z).sum(); tot = 0.0
    for i in (0, 1):
        mm = {}
        for q, f in zip(Q, F): mm[f[i]] = mm.get(f[i], 0) + q
        tot += -sum(v*log2(v) for v in mm.values() if v > 0)
    return -tot
best_Q = max(-minimize(negHQ, rng.normal(size=4), method="Nelder-Mead",
                       options={"xatol": 1e-10, "fatol": 1e-12, "maxiter": 20000}).fun for _ in range(20))
# min over h of max over f: epigraph form, variables (h1a,h1b,h1c,h2a,h2b,s)
cons = [{"type": "eq", "fun": lambda v: v[0]+v[1]+v[2]-1}, {"type": "eq", "fun": lambda v: v[3]+v[4]-1}]
idx1 = {"a": 0, "b": 1, "c": 2}; idx2 = {"a": 3, "b": 4}
for f in F:
    cons.append({"type": "ineq", "fun": (lambda f: lambda v: v[5] + log2(v[idx1[f[0]]]) + log2(v[idx2[f[1]]]))(f)})
best_h = min(minimize(lambda v: v[5], np.r_[rng.dirichlet(np.ones(3)), rng.dirichlet(np.ones(2)), 3.0],
                      method="SLSQP", constraints=cons, bounds=[(1e-9, 1)]*5 + [(0, 10)],
                      options={"ftol": 1e-13, "maxiter": 2000}).fun for _ in range(20))
print(f"   max_Q sum H(Q_x) ~ {best_Q:.4f};  min_h max_f loss ~ {best_h:.4f};  "
      f"sum log|F(x)| = {log2(3)+1:.4f}")

# ---------------------------------------------------------------- Thm 2.5(b) -----------------
print("\n[Thm 2.5(b)] unconditional bound 1-(2^-t+2p)/ln2 vs H(p): crossover in p")
lo_, hi_ = 0.01, 0.25
for _ in range(100):
    mid = (lo_+hi_)/2
    if 1 - 2*mid/log(2) > H(mid): lo_ = mid
    else: hi_ = mid
print(f"   1-2p/ln2 = H(p) at p = {lo_:.5f};  p=0.15: {1-0.3/log(2):.3f} vs H={H(0.15):.3f}; "
      f"p=0.2: {1-0.4/log(2):.3f} vs {H(0.2):.3f}")

print("[Lemma 2.5c] exact identity E_x h(y*|x) = 1/2 + shat/2 - (1/n) sum_E sigma, and the "
      "deviation eta_0 of sum_E sigma from p n shat, for random E:")
d = 12; n = 2**d
X = np.array([[(x >> i) & 1 for i in range(d)] for x in range(n)])
a = rng.integers(0, 2, d); chi_a = 1 - 2*((X @ a) % 2)
for p in [1/64, 0.15, 0.2, 0.24]:
    m = int(round(p*n)); p = m/n; worst_id = 0; etas = []; adv_old = []; adv_new = []
    for trial in range(40):
        # hypotheses: list mixtures missing u bits, plus random partially-correct h
        u = random.randint(1, 4)
        if trial % 2 == 0:
            L = []
            for t in range(2**u):
                b = a.copy()
                for k in range(u): b[d-1-k] = (t >> k) & 1
                L.append((X @ b) % 2)
            q1 = np.mean(np.array(L) == 1, axis=0); h1 = (1-p)*q1 + p*(1-q1)
        else:
            conf = rng.uniform(0, 1, n) * (rng.uniform(size=n) < 2.0**-u)
            h0 = np.where(chi_a == 1, 0.5 + conf/2, 0.5 - conf/2); h1 = 1 - h0
        h0 = 1 - h1; sh = h0 - h1; sigma = sh*chi_a; shat = sigma.mean()
        E = rng.choice(n, m, replace=False); eE = np.zeros(n, int); eE[E] = 1
        ystar = ((X @ a) % 2 + eE) % 2
        hy = np.where(ystar == 0, h0, h1)
        lhs = hy.mean(); rhs = 0.5 + shat/2 - sigma[E].sum()/n
        worst_id = max(worst_id, abs(lhs - rhs))
        eta0 = abs(sigma[E].mean() - shat); etas.append(eta0)
        adv_old.append((0.5 + shat/2 + p) - lhs); adv_new.append((0.5 + (1-2*p)*shat/2 + p*eta0) - lhs)
    print(f"   p={p:.4f} (|E|={m}): identity error {worst_id:.1e}; eta_0 max {max(etas):.4f} "
          f"(sqrt(8 ln2 * d/(pn)) = {sqrt(8*log(2)*d/(p*n)):.4f}); new-bound slack min "
          f"{min(adv_new):.2e} (>=0 required)")
p = 1/64; n10 = 1024
for t in [1, 2, 3]:
    eps = sqrt(32*log(2)*p*(10 + 10 + 2*log2(12))/n10)
    print(f"   d=10, p=1/64, t={t}: old slack 2p={2*p:.4f}; Lemma 2.5c slack eps_E (kappa=0, delta_E=0) = {eps:.4f}")
for dd in [20, 30, 40]:
    nn = 2.0**dd
    print(f"   d={dd}, p=0.2: eps_E (kappa=0, delta_E=0) = "
          f"{sqrt(32*log(2)*0.2*(2*dd + 2*log2(dd+2))/nn):.2e}  vs 2p = 0.4")

print("[Thm 2.5(b) reading] product list mixtures from c2(b): advantage over the coin by missing bits u")
for u, r in [(0, 0.1161), (1, 0.5464), (2, 0.7790), (3, 0.8895), (4, 0.9506), (5, 0.9753)]:
    print(f"   u={u}: 1-R = {1-r:.4f};  2^-u (1-H(p)) = {2**-u*(1-H(1/64)):.4f}")

# ---------------------------------------------------------------- Thm 2.5(a) -----------------
print("\n[Thm 2.5(a)] -log P_u(y*) >= u + nH(p) - o(1) (true component dominates):")
for d_, p_ in [(10, 1/64), (20, 2**-10)]:
    n_ = 2**d_
    for u in [0, d_//2, d_]:
        # other components: weight w >= n/2 - pn mismatches; their total is at most 2^u (p/(1-p))^{n/2-2pn} times the true term
        log2ratio = u + (n_/2 - 2*p_*n_)*log2(p_/(1-p_))
        print(f"   d={d_}, u={u}: log2(others/true) <= {log2ratio:.1f}  (so the o(1) term is < 2^{log2ratio:.0f} bits)")

# ---------------------------------------------------------------- Prop 2.6 --------------------
print("\n[Prop 2.6] telescoping identity with history-dependent personas (3 labels, blocks of 6)")
worst = 0; worst_gap = inf
for trial in range(2000):
    T = 3
    w = rng.dirichlet(np.ones(T)) * rng.uniform(0.5, 1.0)       # sub-probability weights allowed
    tabs = [rng.dirichlet(np.ones(3), size=(3, 3)) for _ in range(T)]   # nu_theta(y | x, last y)
    hist = []; xs_ = []; ys_ = []; tot = 0.0; prev = 0
    for i in range(6):
        x = int(rng.integers(0, 3)) if i == 0 else (prev + i) % 3     # inputs depend on history
        lik = np.array([np.prod([tabs[th][xx][py][yy] for (xx, py, yy) in hist]) for th in range(T)])
        post = w*lik/np.sum(w*lik)
        pred = sum(post[th]*tabs[th][x][prev] for th in range(T))
        y = int(rng.integers(0, 3))
        tot += -log2(pred[y]); hist.append((x, prev, y)); prev = y
    joint = np.array([np.prod([tabs[th][xx][py][yy] for (xx, py, yy) in hist]) for th in range(T)])
    exact = -log2(np.sum(w*joint)/np.sum(w))
    bound = min(-log2(w[th]) - log2(joint[th]) for th in range(T))
    worst = max(worst, abs(tot - exact)); worst_gap = min(worst_gap, bound - tot)
print(f"   max |block loss - (-log2 sum_th w_th prod nu_th / sum w)| = {worst:.1e}; "
      f"min (bound - loss) = {worst_gap:.3f} (>= 0 required)")

print("[Prop 2.6 consequence] exact expected per-context loss of the calibrated norm model (c5):")
M2, q2, eta2 = 2**16, 0.2, 0.05
e_n = q2*(1 - eta2/M2) + (1-q2)*eta2*(M2-1)/M2
lv, lo = -log2(1-e_n), -log2(e_n/(M2-1))
pv_corr = 1 - eta2 + eta2/M2                       # correct persona plays v
pv_idio = eta2/M2                                  # idiosyncratic persona plays v
exact = (1-q2)*(pv_corr*lv + (1-pv_corr)*lo) + q2*(pv_idio*lv + (1-pv_idio)*lo)
print(f"   norm model: {exact:.4f} bits per error context, for every K (c5's 4.52-4.76 is MC noise)")

# ---------------------------------------------------------------- Lemma 3.1 / Thm 4.1(iii) ----
print("\n[Thm 4.1(iii)] ray example A={(0,1),(1,0),(2,0)}: is (2,0) ever a minimiser for c>0?")
A = [(0, 1), (1, 0), (2, 0)]
print("   ", any(min(A, key=lambda P: (c*P[0]+P[1], P[0])) == (2, 0) or
               abs(c*2 - min(c*a_+b_ for a_, b_ in A)) < 1e-15 for c in np.logspace(-6, 3, 2000)))

# ---------------------------------------------------------------- 200-bit rule ---------------
print("\n[after Thm 4.1] 200-bit rule at frequency 1e-4: rate 5e-7*g vs the user's error rate 1.1185e-6;"
      f" break-even g = {1.1185e-6/5e-7:.2f} bits; with g=5.42: rate {5e-7*5.423:.2e}")

# ---------------------------------------------------------------- Prop 4.4 --------------------
print("\n[Prop 4.4] three options per sigma-region: none / unguarded / guarded")
M, eta = 64, 0.05
p_hit = 1 - eta + eta/M
xent = -(p_hit*log2(p_hit) + (M-1)*(eta/M)*log2(eta/M)); gain = log2(M) - xent
def sel(c, piG, pinG, ks, kG):
    # risk relative to 'none' (uniform on all sigma-applicable contexts)
    opts = {"none": (0, 0.0),
            "unguarded": (ks, -piG*gain + pinG*(log2(M/eta) - log2(M))),
            "guarded": (ks+kG, -piG*gain + pinG*(log2(M-1) - log2(M)))}
    return min(opts, key=lambda k: c*opts[k][0] + opts[k][1]), opts
for (piG, pinG, ks, kG) in [(0.05, 5e-4, 22, 12), (0.002, 0.002, 22, 12)]:
    _, opts = sel(1, piG, pinG, ks, kG)
    rho_s = -opts["unguarded"][1]/ks; rho_G = (opts["unguarded"][1]-opts["guarded"][1])/kG
    seen = []
    for c in np.logspace(-6, -1, 400):
        sname = sel(c, piG, pinG, ks, kG)[0]
        if not seen or seen[-1][1] != sname: seen.append((c, sname))
    print(f"   pi_G={piG}, pi_notG={pinG}: rate(unguarded)={rho_s:.2e}, rate(guard)={rho_G:.2e}; "
          f"selection path (c increasing): {[(f'{c:.1e}', nm) for c, nm in seen]}")
print(f"   guard gain per not-G context = log2(M/eta)-log2(M-1) = {log2(M/eta)-log2(M-1):.3f} > log2(1/eta) = {log2(1/eta):.3f}")

# ---------------------------------------------------------------- (d3) ------------------------
print("\n[(d3)] bundle example: v (k=10, r=0.01), e (K(e)=100, K(e|v)=1, r=0.01), c=1.5e-3")
c = 1.5e-3
J = {"{}": 0, "{v}": 10*c - 0.01, "{e}": 100*c - 0.01, "{v,e}": 11*c - 0.02}
print("   ", {k: round(v_, 5) for k, v_ in J.items()}, "-> optimum", min(J, key=J.get))

# ---------------------------------------------------------------- (d6) ------------------------
print("\n[(d6)] Kraft construction: lengths l0 + sum_{j in S} k_j with l0 = m")
viol = 0
for _ in range(3000):
    m = random.randint(1, 8); c = 10**random.uniform(-4, -1)
    r = [10**random.uniform(-5, -1) for _ in range(m)]
    target = [random.random() < 0.5 for _ in range(m)]
    k = [max(0, ceil(r[j]/c) - 1) if target[j] else int(r[j]/c) + 1 for j in range(m)]
    for j in range(m):
        if target[j] and not k[j] < r[j]/c: k[j] = 0
    kraft = sum(2.0**-(m + sum(k[j] for j in range(m) if S[j]))
                for S in itertools.product([0, 1], repeat=m))
    best = min(itertools.product([0, 1], repeat=m),
               key=lambda S: sum(S[j]*(c*k[j] - r[j]) for j in range(m)))
    if kraft > 1 + 1e-12 or list(map(bool, best)) != target: viol += 1
print(f"   violations (Kraft > 1 or S*(c) != target): {viol} of 3000")

# ---------------------------------------------------------------- Cor 5.2a --------------------
print("\n[Cor 5.2a] counterexample without valid dominance: V={v} (r=.01,k=10), F (r=.02,k=10), witness {v}")
for c in [1e-4, 5e-4, 9e-4, 1.1e-3]:
    vals = {"{}": 0, "{v}": 0.01-10*c, "{F}": 0.02-10*c}       # {v,F} infeasible
    print(f"   c={c:.1e}: coherent optimum {max(vals, key=vals.get)}")

# ---------------------------------------------------------------- Thm 5.2 step 4 --------------
print("\n[Thm 5.2 step 4] V={v+,v0} (nu(v0)=0), F with sole witness {v+,v0}:")
feas = lambda S: not ({"v+", "v0", "F"} <= S)
print(f"   S={{v0,F}} feasible: {feas({'v0','F'})}; S+v+ feasible: {feas({'v0','F','v+'})}; "
      f"S*={{v+}} u {{F}} feasible: {feas({'v+','F'})}")

# ---------------------------------------------------------------- Cor 3.5a numbers ------------
print("\n[Cor 3.5a] identification in the parity example (kappa'=kappa=0 for illustration)")
for d_, p_, c in [(20, 2**-10, 1e-4), (20, 2**-10, 1e-3), (10, 1/64, 2e-3)]:
    n_ = 2**d_; LE = log2(comb(n_, int(p_*n_)))
    shat_lb = 2**(1 - c*d_ - H(p_)) - 1 - 2*p_
    Lam = log2(n_+1) + 2*log2(d_)
    R_lb = H(p_) - c*Lam/(c*n_ - 1)
    print(f"   d={d_}, p={p_:.4g}, c={c:.0e} (cn={c*n_:.0f}): eta=0 => shat >= {shat_lb:.4f}, "
          f"R >= H(p) - {c*Lam/(c*n_-1):.2e} = {R_lb:.5f} (H(p)={H(p_):.5f}); L_E={LE:.0f}, nH={n_*H(p_):.0f}")

print("\n[Thm 3.5] numbers: d=20, p=2^-10 window")
n_ = 2**20; LE = log2(comb(n_, 2**10))
print(f"   L_E = {LE:.1f}; H(p)/L_E = {H(2**-10)/LE:.3e}; (1-H(p))/20 = {(1-H(2**-10))/20:.4f}")

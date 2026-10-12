"""q4 (referee, second run):
(A) Theorem 1(a),(c1) and Theorem 5(ii) in an explicit shared class that contains its own Bayes mixture U
    as a member of length l_U (so (Dom) holds with c_0 = 0).  Members: Bernoulli product samplers on two
    input classes (grid {1..15}/16, 8-bit codes), deterministic 'constant per class' functions, and U.
    Checks every lambda-MAP: length <= (lambda l_U)/(lambda-1); loss <= -log U(D) + lambda l_U - lambda l;
    cumulative steeper-Bayes loss on a deterministic teacher <= min(lambda l_t, lambda l_U + l_t);
    posterior mass of lengths >= L <= 2^{-(lambda-1)L + lambda l_U + c_1}, c_1 = 0.
(B) Where Thm 2(iii) (memoriser regime) actually applies: the condition rho < (1 - c 2^m) B_S / 2^m and the
    resulting lower bound on the error-label probability, for c = x 2^-m, x in (0, 1).
Seeded: numpy default_rng(4242). Output: q4_absorption_and_regimes.out
"""
from math import log2, comb, ceil, inf
import numpy as np

rng = np.random.default_rng(4242)
out = []
P = lambda *a: out.append(" ".join(str(x) for x in a))

def lse(v):
    v = np.asarray(v, float); mx = v.max()
    return mx + log2(np.sum(2.0**(v - mx)))

# ---------------------------------------------------------------- (A)
P("=" * 78)
P("(A) Theorem 1 / Theorem 5 in a shared class containing its own mixture")
grid = np.arange(1, 16)/16
members = []    # (length, kind, params)
for a in grid:
    for b in grid:
        members.append((10, "samp", (a, b)))          # '01' + 8 bits
for a in (0, 1):
    for b in (0, 1):
        members.append((5, "det", (a, b)))            # '001' + 2 bits
kraft_others = sum(2.0**-l for l, _, _ in members)
for lU in [3, 6, 9]:
    assert kraft_others <= 1 - 2.0**-lU + 1e-12, (kraft_others, lU)
P(f"  Kraft sum of non-U members = {kraft_others:.4f}")

def member_loglik(mem, xs, ys):
    l, kind, (a, b) = mem
    if kind == "samp":
        p1 = np.where(xs % 2 == 0, a, b)
        return float(np.sum(np.where(ys == 1, np.log2(p1), np.log2(1 - p1))))
    f = np.where(xs % 2 == 0, a, b)
    return 0.0 if np.all(f == ys) else -inf

viol = {"len": 0, "loss": 0, "c1": 0, "t5": 0}; nchecks = 0; maxratio = 0.0
for run in range(60):
    lU = int(rng.choice([3, 6, 9]))
    N = int(rng.integers(5, 200))
    xs = np.arange(N)
    mode = run % 3
    if mode == 0:     # deterministic teacher in the class
        tch = members[-1 - int(rng.integers(0, 4))]
        ys = np.where(xs % 2 == 0, tch[2][0], tch[2][1]).astype(int)
    elif mode == 1:   # stochastic teacher in the class
        a, b = rng.choice(grid, 2)
        ys = (rng.uniform(size=N) < np.where(xs % 2 == 0, a, b)).astype(int)
    else:             # deterministic teacher NOT in the class (pattern with period 3)
        ys = ((xs % 3) == 0).astype(int)
    lls = np.array([member_loglik(m, xs, ys) for m in members])
    lens = np.array([m[0] for m in members], float)
    # U = (1 - 2^-lU)^-1 * sum_{others} 2^-l P
    logU = lse(-lens + lls) - log2(1 - 2.0**-lU) if np.isfinite(lls).any() else -inf
    for lam in [1.25, 1.5, 2.0, 3.0, 8.0]:
        J = np.concatenate([lam*lens - lls, [lam*lU - logU]])
        L_all = np.concatenate([lens, [lU]]); LL_all = np.concatenate([lls, [logU]])
        Jmin = J.min(); maps = np.where(J <= Jmin + 1e-9)[0]
        Llam = lam*lU/(lam - 1)
        for t in maps:
            nchecks += 1
            if L_all[t] > Llam + 1e-9: viol["len"] += 1
            if -LL_all[t] > -logU + lam*lU - lam*L_all[t] + 1e-9: viol["loss"] += 1
            maxratio = max(maxratio, L_all[t]/Llam)
        # Thm 5(ii): posterior on lengths >= Lc
        logpost = -lam*L_all + LL_all
        lZ = lse(logpost[np.isfinite(logpost)])
        for Lc in [4, 6, 10]:
            sel = logpost[(L_all >= Lc) & np.isfinite(logpost)]
            if len(sel) and lse(sel) - lZ > -(lam - 1)*Lc + lam*lU + 1e-9: viol["t5"] += 1
        # (c1) for deterministic teachers in the class: cumulative steeper-Bayes loss
        if mode == 0:
            lt = 5
            # xi_lambda(D_N) = sum over all members incl U of 2^{-lam l} P(D); cumulative loss <= -log xi_lambda(D_N)
            lxi = lse(logpost[np.isfinite(logpost)])
            # empty-set normaliser log xi_lambda(empty) <= 0, so cumulative loss = -lxi + log xi(empty) <= -lxi
            if -lxi > min(lam*lt, lam*lU + lt) + 1e-9: viol["c1"] += 1
P(f"  60 data sets x 5 lambdas: {nchecks} MAP checks; violations {viol}; max l(MAP)/L_lambda = {maxratio:.3f}")

# ---------------------------------------------------------------- (B)
P("=" * 78)
P("(B) Theorem 2(iii): where the memoriser-regime conclusion applies (d=100, m=20, p=2^-10, B=inf, kappa=0, delta_S=0)")
d, m, r = 100, 20, 10
p = 2.0**-r; s0 = 2**(m - r)
def log2_bigint(n):
    b = n.bit_length(); sh = max(0, b - 900)
    return log2(n >> sh) + sh
LS = log2_bigint(comb(2**m, s0)); BS = LS
Lam1 = 2*log2(d) + 2*log2(m); kb = 2*log2(d) + 2*log2(m) + 2*log2(s0)
const = ceil(LS) - LS + 4 + Lam1 + kb
for x in [0.1, 0.5, 0.9, 0.95, 0.99, 0.995]:
    c = x*2.0**-m
    rho = c*const
    ok = rho < (1 - x)*BS/2**m
    e = 2**(-(rho/(1 - x))/p) if ok else float('nan')
    P(f"  c = {x:5.3f} * 2^-m: condition rho < (1-c2^m)B_S/2^m holds: {ok}; error-label prob e >= {e:.3f}")
xs_ = np.linspace(0.5, 0.99999, 200001)
okx = xs_[xs_*2.0**-m*const < (1 - xs_)*BS/2**m]
P(f"  condition holds exactly for c < {okx.max():.5f} * 2^-m; e >= 0.5 needs c <= "
  f"{xs_[(xs_*2.0**-m*const/(1 - xs_))/p <= 1].max():.4f} * 2^-m")


# ---------------------------------------------------------------- (C)
P("=" * 78)
P("(C) Structured error rule with Hanni's density: S = S_cheap u S_rand in {0,1}^20, |S| = 1024, p = 2^-10")
P("    S_cheap = {z : z_1..z_11 = 0} (512 points, ~2log11 bits to name), S_rand = 512 random points.")
P("    Three explicit product hypotheses (kappa = 0, B = inf), population risk under uniform inputs:")
def Hb(q): return 0.0 if q <= 0 or q >= 1 else -(q*log2(q) + (1-q)*log2(1-q))
d, m = 100, 20
pc = 2.0**-11                  # density of the cheap part
pr = 2.0**-11                  # density of the random part
kg = 2*log2(d) + 2*log2(10)
# good model: f_a with flip prob p everywhere
R_good = Hb(pc + pr); l_good = d + kg
# cheap-envelope model: flipped label on the cheap subcube (prob 1), elsewhere f_a with flip prob pr/(1-pc)
R_env = (1 - pc)*Hb(pr/(1 - pc)); l_env = l_good + 2*log2(11) + 2   # name the 11 fixed coordinates' count + pattern '0'
LSr = log2_bigint(comb(2**m - 2**(m-11), 2**(m-11)))
l_mem = l_env + LSr + 2*log2(m) + 2*log2(512)        # memorise the random half as well
P(f"  good: l = d+{l_good-d:.1f}, R = {R_good:.5f};  envelope: l = d+{l_env-d:.1f}, R = {R_env:.5f};  "
  f"full memoriser: l = d+{l_mem-d:.0f}, R = 0")
rate_env = (R_good - R_env)/(l_env - l_good)
rate_mem = R_env/(l_mem - l_env)
P(f"  envelope beats good iff c < {rate_env:.3e};  full memoriser beats envelope iff c < {rate_mem:.3e}; 2^-m = {2.0**-m:.3e}")
for c in [1e-5, 1e-4, 3e-4, 1e-3]:
    J = {"good": c*l_good + R_good, "envelope": c*l_env + R_env, "memoriser": c*l_mem}
    best = min(J, key=J.get)
    eprob = {"good": 2.0**-10, "envelope": 0.5*(1.0) + 0.5*(pr/(1-pc)), "memoriser": 1.0}[best]
    P(f"  c={c:.0e}: best of the three = {best}; its average probability of the teacher's error label on E = {eprob:.3f}")

open(__file__.replace(".py", ".out"), "w").write("\n".join(out) + "\n")
print("\n".join(out))

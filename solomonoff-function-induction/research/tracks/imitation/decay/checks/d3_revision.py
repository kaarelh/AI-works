"""d3: checks for the revision of sub-track "decay" after its referee report (research/tracks/imitation/decay).

Written for notes-final.md, 2026-10-14. Deterministic or seeded (seeds printed). Python 3.11, NumPy, SciPy.
Output: d3_revision.out (same folder). Does not import d1, d2 or the referee's rd1.

Parts
 (A) Summable versus non-summable priors on a repeated sample (referee M2; notes-final Prop 2.2(iv), Example 2.7).
     (A1) random finite classes: beyond the exact threshold r_ML every MAP of a fixed prior attains the maximum likelihood;
     (A2) a countable class with a full-support NON-summable prior whose MAPs exist at every r and never attain P*.
 (B) Which fixed priors reproduce the cn-MAP sets (referee M1, A4; notes-final Prop 2.2(v), Example 2.6):
     exact feasibility of the priors (1, t), t > 0, and of the degenerate priors, on all samples of size <= N,
     (B1) in the coin / deterministic-f class of Example 2.4, (B2) in a class of two Bernoulli rates 1/2 and 1/4,
     where for 0 < ck < log(3/2) no fixed prior at all reproduces the cn-MAP sets, already on samples of size <= 4.
 (C) Teacher window: c_+ := H(p)/(B_S - 4 - Lambda_1 - kappa_g) from the definitions of Paper 2 (referee A1).
 (D) Example 4.3: AdamW box threshold in closed form (referee A2); the L2 switch happens iff eps^2 < 1 - 2q (A3);
     AdamW runs where L2 never switches but the box does.
 (E) Kinks for weight decay (referee m2): L(theta) = |theta - 1| selects theta = 1 for every omega in (0, 1];
     for the differentiable toy every point is selected at one omega only.
 (F) Error rates of the programs of d1(C): argmax against randomised (referee m1).
 (G) Schedules lambda_n/n -> c > 0 at a breakpoint of the hull (notes Remark 2.5(a), simplified as the referee suggests):
     random classes with dyadic kernels (exact integer fits), c n0 an edge slope, lambda_n = c n + sqrt(n).
"""
import math
from fractions import Fraction

import numpy as np
from scipy.optimize import brentq, minimize

LOG3 = math.log2(3.0)

# ================================================================================================
print("=" * 100)
print("(A) Repeated sample: summable priors end at maximum likelihood; a non-summable prior need not")
print("=" * 100)
rng = np.random.default_rng(20261015)
tested = 0
ok = 0
rml_max = 0.0
for t in range(3000):
    K = int(rng.integers(3, 10))
    lengths = rng.integers(1, 14, size=K)
    P1 = rng.uniform(0.02, 0.98, size=(K, 3))
    det = rng.random(K) < 0.2
    P1[det] = rng.integers(0, 2, size=(int(det.sum()), 3)).astype(float)
    n0 = int(rng.integers(1, 10))
    xs = rng.integers(0, 3, size=n0)
    ys = rng.integers(0, 2, size=n0)
    pr = np.where(ys[None, :] == 1, P1[:, xs], 1.0 - P1[:, xs])
    with np.errstate(divide="ignore"):
        L = -np.sum(np.log2(pr), axis=1)
    if not np.isfinite(L).any():
        continue
    c = [0.02, 0.05, 0.1, 0.3][t % 4]
    J = c * n0 * lengths + L
    Lmin = L.min()
    ML = set(np.flatnonzero(L <= Lmin + 1e-12).tolist())
    MAP = set(np.flatnonzero(J <= J.min() + 1e-12).tolist())
    if MAP & ML:
        continue  # condition (b) fails
    tested += 1
    logw = -lengths + np.log2(rng.uniform(0.1, 10.0, size=K))
    star = max(ML, key=lambda i: logw[i])
    # exact threshold: a non-ML program with w > w* is beaten by pi* iff r > (log w - log w*)/(L - L*)
    rml = 0.0
    for i in range(K):
        if i not in ML and np.isfinite(L[i]) and logw[i] > logw[star]:
            rml = max(rml, (logw[i] - logw[star]) / (L[i] - Lmin))
    rml_max = max(rml_max, rml)
    r = int(math.floor(rml)) + 1
    with np.errstate(invalid="ignore"):
        score = logw - r * L
    wmap = set(np.flatnonzero(score >= np.nanmax(score[np.isfinite(score)]) - 1e-9).tolist())
    ok += wmap <= ML
print(f"(A1) random finite classes, samples with (a),(b): {tested}; at r = floor(r_ML)+1 every w-MAP attains P*: {ok} of {tested};"
      f" largest r_ML = {rml_max:.1f}")

# (A2) single input, Y = {0,1}, h = 4 labels with one 1: theta_hat = 1/4, P* = (1/4)(3/4)^3.
# pi_j = Bernoulli(theta_j), theta_j in (1/4, 1) with log2(P*/nu_j(h)) = 4 KL(1/4 || theta_j) = d_j := 1/j^3 bits.
# Prior (not summable, full support): log2 w(pi*) = -1, log2 w(pi_j) = 1/j. On h^r: score_j = 1/j - r d_j, score* = -1.
def kl_bits(a, b):
    return a * math.log2(a / b) + (1 - a) * math.log2((1 - a) / (1 - b))


thetas = []
for j in [1, 2, 5, 10, 100]:
    th = brentq(lambda b: 4 * kl_bits(0.25, b) - 1.0 / j**3, 0.25 + 1e-15, 1 - 1e-15, xtol=1e-15)
    thetas.append((j, th))
print("(A2) realisation: theta_j with 4 KL(1/4||theta_j) = 1/j^3 bits: " +
      ", ".join(f"j={j}: {th:.6f}" for j, th in thetas))
print("     non-summable prior log2 w(pi*) = -1, log2 w(pi_j) = 1/j; on h^r the score of pi_j is 1/j - r/j^3 (relative to r log P*)")
for r in [1, 10, 100, 10**4, 10**6, 10**8]:
    js = np.arange(1, int(4 * math.sqrt(3 * r)) + 10, dtype=float)
    f = 1.0 / js - r / js**3
    jbest = int(js[np.argmax(f)])
    fbest = float(f.max())
    J_tail = int(math.ceil(1.0 / fbest)) + 1  # every j >= J_tail has score < 1/J_tail < fbest
    js2 = np.arange(1, max(J_tail, len(js)) + 1, dtype=float)
    f2 = 1.0 / js2 - r / js2**3
    assert int(js2[np.argmax(f2)]) == jbest and abs(f2.max() - fbest) < 1e-15
    nties = int(np.sum(f2 >= fbest - 1e-15))
    print(f"   r = {r:>9}: unique MAP pi_j at j = {jbest:>5} (sqrt(3r) = {math.sqrt(3 * r):9.1f}), score {fbest:.3e} > 0 > -1 = score of pi*;"
          f" tail j >= {J_tail} scores below 1/{J_tail}; maximisers: {nties}")
print("   So at every r the MAP exists and has likelihood P* 2^(-1/j^3) < P*: summability cannot be dropped in Prop 2.2(iv).")

# ================================================================================================
print()
print("=" * 100)
print("(B) Which fixed priors reproduce the cn-MAP sets on all samples of size <= N?")
print("=" * 100)


def feasible_report(name, c, k, cases, N, degenerate):
    """cases(n) yields (description, cnmap, constraint) with constraint = ('>', v) / ('<', v) / ('=', v) on u = log2 t
    for the prior (1, t), and degenerate(n) yields, for each degenerate prior, whether it matches on all size-n samples."""
    lo, hi, eq = -math.inf, math.inf, None
    deg_ok = {d: True for d in ["(1,0)", "(0,1)", "(0,0)"]}
    first_infeasible = None
    for n in range(1, N + 1):
        for cnmap, (op, v) in cases(n):
            if op == ">":
                lo = max(lo, v)
            elif op == "<":
                hi = min(hi, v)
            else:
                eq = v if eq is None else (eq if abs(eq - v) < 1e-12 else math.nan)
        for d, good in degenerate(n).items():
            deg_ok[d] = deg_ok[d] and good
        feas = lo < hi and (eq is None or (not math.isnan(eq) and lo < eq < hi))
        if not feas and first_infeasible is None:
            first_infeasible = n
    return lo, hi, deg_ok, first_infeasible


# (B1) coin (length 1) against deterministic f (length 1+k); a sample is f-consistent or not.
k = 10
print(f"(B1) coin (length 1) / deterministic f (length 1+{k}), all samples of size n <= 30 (only n and f-consistency matter)")
for c in [Fraction(1, 20), Fraction(1, 5)]:
    def cases(n, c=c):
        out = []
        # consistent: J(coin) = cn + n, J(f) = cn(1+k); prior (1,t): f wins iff log2 t > -n
        Jc, Jf = c * n + n, c * n * (1 + k)
        if Jf < Jc:
            out.append(("f", (">", -n)))
        elif Jf > Jc:
            out.append(("coin", ("<", -n)))
        else:
            out.append(("tie", ("=", -n)))
        return out  # inconsistent samples: coin is the only finite fit, every prior with w(coin) > 0 agrees

    def degenerate(n, c=c):
        Jc, Jf = c * n + n, c * n * (1 + k)
        cn = "f" if Jf < Jc else ("coin" if Jf > Jc else "tie")
        # (1,0) = delta_coin: MAP coin on every sample; (0,1) = delta_f: MAP f on consistent, all (score 0) on inconsistent
        return {"(1,0)": cn == "coin", "(0,1)": False, "(0,0)": False}

    lo, hi, deg, first = feasible_report("B1", c, k, cases, 30, degenerate)
    print(f"   c = {c} (ck = {c * k}): priors (1,t) consistent with all samples n <= 30: log2 t in ({lo:g}, {hi:g})"
          f"{'  [empty]' if not lo < hi else ''}; degenerate priors matching: {[d for d, g in deg.items() if g]}")
print("   ck = 1/2: every full-support prior with t > 1/2 works (no sample has (a),(b)); ck = 2: only t < 2^-30 survives n <= 30,")
print("   so in the limit only delta_coin (no full support) reproduces the cn-MAPs: the hypothesis of Prop 2.2(ii) is needed.")

# (B2) two Bernoulli rates on Y = {0,1}, kernels independent of x: pi_h (rate 1/2, length 1), pi_q (P(y=1) = 1/4, length 1+k).
# Per-sample gain of pi_q over pi_h on a sample with empirical frequency phat of label 1: g(phat) = log(3/2) - phat log 3.
# cn-MAP: pi_q iff g > ck. Prior (1, t) = (w(pi_h), w(pi_q)): pi_q wins iff log2 t > -n g.
print()
print(f"(B2) two Bernoulli rates: pi_h = rate 1/2 (length 1), pi_q = rate 1/4 (length 1+k), k = {k}; log2(3/2) = {math.log2(1.5):.6f}")
min_margin = math.inf
for c in [0.01, 0.03, 0.05, 0.0584, 0.0586, 0.1]:
    def gain(n, j):
        return math.log2(1.5) - (j / n) * LOG3

    def cases(n, c=c):
        global min_margin
        out = []
        for j in range(n + 1):
            g = gain(n, j)
            min_margin = min(min_margin, abs(g - c * k))
            if g > c * k:
                out.append(("q", (">", -n * g)))
            elif g < c * k:
                out.append(("h", ("<", -n * g)))
            else:
                out.append(("tie", ("=", -n * g)))
        return out

    def degenerate(n, c=c):
        res = {}
        cns = ["q" if gain(n, j) > c * k else "h" for j in range(n + 1)]
        # (1,0) = delta_h: MAP pi_h on every sample (likelihood 2^-n > 0); (0,1) = delta_q: MAP pi_q on every sample (j < n)
        # and also at j = n (likelihood 4^-n > 0); (0,0): MAP set = both
        res["(1,0)"] = all(s == "h" for s in cns)
        res["(0,1)"] = all(s == "q" for s in cns)
        res["(0,0)"] = False
        return res

    lo, hi, deg, first = feasible_report("B2", c, k, cases, 40, degenerate)
    zone = "ck < log(3/2)" if c * k < math.log2(1.5) else "ck > log(3/2)"
    print(f"   c = {c:<7} (ck = {c * k:.3f}, {zone}): (1,t) feasible for n <= 40: "
          f"{'none' if first is not None else f'log2 t in ({lo:.3f}, {hi:.3f})'}"
          f"{f' (empty from N = {first} on)' if first is not None else ''}; degenerate priors matching: {[d for d, g in deg.items() if g] or 'none'}")
print(f"   smallest |g(phat) - ck| over all samples examined: {min_margin:.3e} (no float tie)")
print("   For ck < log(3/2): no fixed prior of any kind reproduces the cn-MAP sets (Prop 2.2(v)); for ck > log(3/2) delta_{pi_h} does.")

# ================================================================================================
print()
print("=" * 100)
print("(C) Teacher window: c > c* for c in (max(2^-m, c_+), c_hi), c_+ = H(p)/(B_S - 4 - Lambda_1 - kappa_g)")
print("=" * 100)
d, m, rr = 100, 20, 10
p = 2.0**-rr
Hp = -p * math.log2(p) - (1 - p) * math.log2(1 - p)
s0 = int(p * 2**m)
LS = (math.lgamma(2**m + 1) - math.lgamma(s0 + 1) - math.lgamma(2**m - s0 + 1)) / math.log(2)
print(f"d = {d}, m = {m}, p = 2^-{rr}, s0 = {s0}, H(p) = {Hp:.7f}, L_S = log2 C(2^m, s0) = {LS:.3f}, 2^m H(p) = {2**m * Hp:.3f}")
for kappa in [0, 30]:
    for dS in [0, 20]:
        BS = LS - dS
        Lam1 = 2 * math.log2(d) + 2 * math.log2(m) + kappa  # B = infinity
        kg = 2 * math.log2(d) + 2 * math.log2(rr) + kappa  # p = 2^-r, K(p) <= 2 log r + kappa
        Lam2 = 2**m * Hp - BS + 4 + Lam1 + kg
        den = BS - 4 - Lam1 - kg
        assert abs((2**m * Hp - Lam2) - den) < 1e-6
        cplus = Hp / den
        rb = lambda c: Hp - c * Lam2 / (c * 2**m - 1)
        print(f"  kappa = {kappa:>2}, delta_S = {dS:>2}: Lambda_2 = {Lam2:7.2f}, c_+ = {cplus:.6e} = {cplus * 2**m:.5f} * 2^-m;"
              f" (ii)(b) bound at c_+: {rb(cplus):+.1e}, at c = 1e-4: {rb(1e-4):.6f} (H(p) = {Hp:.6f})")
print("  Paper 2 (rem:teacher:numbers): window (9.54e-7, 8.06e-3] at kappa = 0, (9.54e-7, 3.65e-3] at kappa = 30, so c_+ < c_hi.")

# ================================================================================================
print()
print("=" * 100)
print("(D) Example 4.3: the box threshold, the switch condition, AdamW where L2 never switches")
print("=" * 100)


def make_toy(eps, q):
    def sp(u):  # ln(1 + e^-u)
        return math.log1p(math.exp(-u)) if u > -30 else -u + math.log1p(math.exp(u))

    def sg(u):  # sigma(u)
        return 1.0 / (1.0 + math.exp(-u)) if u > -700 else 0.0

    def L(t1, t2):
        return (1 - q) * sp(eps * t1 + t2) + q * sp(eps * t1 - t2)

    def gradL(t1, t2):
        a, b = eps * t1 + t2, eps * t1 - t2
        A, Bv = sg(-a), sg(-b)
        return -eps * ((1 - q) * A + q * Bv), -(1 - q) * A + q * Bv

    def hessL(t1, t2):
        a, b = eps * t1 + t2, eps * t1 - t2
        ha, hb = sg(a) * sg(-a), sg(b) * sg(-b)
        return ((1 - q) * ha + q * hb) * eps * eps, ((1 - q) * ha - q * hb) * eps, (1 - q) * ha + q * hb

    def argminF(om):
        t1, t2 = 0.0, 0.0
        for _ in range(400):
            g1, g2 = gradL(t1, t2)
            g1 += om * t1
            g2 += om * t2
            h11, h12, h22 = hessL(t1, t2)
            h11 += om
            h22 += om
            det = h11 * h22 - h12 * h12
            s1, s2 = (h22 * g1 - h12 * g2) / det, (h11 * g2 - h12 * g1) / det
            F0 = L(t1, t2) + 0.5 * om * (t1 * t1 + t2 * t2)
            st = 1.0
            while st > 1e-14:
                n1, n2 = t1 - st * s1, t2 - st * s2
                if L(n1, n2) + 0.5 * om * (n1 * n1 + n2 * n2) <= F0 - 1e-4 * st * (g1 * s1 + g2 * s2):
                    break
                st *= 0.5
            t1, t2 = n1, n2
            if abs(s1) + abs(s2) < 1e-14 * (1 + abs(t1) + abs(t2)):
                break
        return t1, t2

    def box(lam):
        Bb = 1.0 / lam
        # theta_1 = B since dL/dtheta_1 < 0; theta_2 minimises the strictly convex L(B, .) on [-B, B]
        g = lambda t2: gradL(Bb, t2)[1]
        if g(Bb) <= 0:
            return Bb, Bb
        if g(-Bb) >= 0:
            return Bb, -Bb
        return Bb, brentq(g, -Bb, Bb, xtol=1e-15)

    return L, gradL, argminF, box


print("(D1) box (AdamW-limit) threshold: closed form 2 eps / ln((2-3q)/q) against direct box minimisation")
for eps, q in [(0.1, 0.2), (0.05, 0.1), (0.3, 0.25), (0.5, 0.3), (0.8, 0.2), (0.7, 0.3), (0.9, 0.1), (0.5, 0.4)]:
    L, gradL, argminF, box = make_toy(eps, q)
    lam_cf = 2 * eps / math.log((2 - 3 * q) / q)
    bb = lambda lam: (lambda t: eps * t[0] - t[1])(box(lam))
    lam_num = brentq(bb, lam_cf / 30, lam_cf * 30, xtol=1e-14)
    # 2-D check that theta_1 sits at the bound
    lam_t = 1.5 * lam_cf
    r = minimize(lambda t: L(t[0], t[1]), x0=np.zeros(2), jac=lambda t: np.array(gradL(t[0], t[1])), method="L-BFGS-B",
                 bounds=[(-1 / lam_t, 1 / lam_t)] * 2, options={"ftol": 1e-15, "gtol": 1e-12, "maxiter": 10000})
    print(f"   eps = {eps}, q = {q}: closed form {lam_cf:.6f}, numerical {lam_num:.6f}; at 1.5x: L-BFGS-B box theta = "
          f"({r.x[0]:.6f}, {r.x[1]:.6f}) vs ({box(lam_t)[0]:.6f}, {box(lam_t)[1]:.6f})")

print("(D2) L2 switch iff eps^2 < 1 - 2q: sign of b = eps th1 - th2 at the minimiser of F over omega in [1e-6, 1e4] (241 values)")
oms = np.logspace(-6, 4, 241)
for eps, q in [(0.8, 0.2), (0.7, 0.3), (math.sqrt(0.6), 0.2), (0.9, 0.1), (0.5, 0.4), (0.77, 0.2), (0.6, 0.3), (0.1, 0.2)]:
    L, gradL, argminF, box = make_toy(eps, q)
    bs = []
    for om in oms:
        t1, t2 = argminF(float(om))
        bs.append(eps * t1 - t2)
    bs = np.array(bs)
    cond = eps**2 < 1 - 2 * q - 1e-15
    if cond:
        s = q * (1 + eps**2) / (2 * (1 - q) * (1 - eps**2))
        om_star = 2 * q * eps**2 / ((1 - eps**2) * math.log(1 / s - 1))
        expect = (bs > 0) == (oms < om_star)
        print(f"   eps = {eps:.4f}, q = {q}: eps^2 = {eps**2:.4f} < 1-2q = {1 - 2 * q:.2f}: omega* = {om_star:.4e};"
              f" sign of b as predicted at {expect.sum()} of {len(oms)} omegas")
    else:
        print(f"   eps = {eps:.4f}, q = {q}: eps^2 = {eps**2:.4f} >= 1-2q = {1 - 2 * q:.2f}: b > 0 at {(bs > 0).sum()} of {len(oms)} omegas"
              f" (min b = {bs.min():.3e}; omega b at 1e4 = {oms[-1] * bs[-1]:.4f}, limit (eps^2-(1-2q))/2 = {(eps**2 - (1 - 2 * q)) / 2:.4f})")

print("(D3) full-batch Adam on F (coupled L2) and AdamW (decoupled), 2e5 steps, lr 0.05/sqrt(1+t/1000), betas (0.9, 0.999)")


def adam(eps, q, lam, decoupled, T=200000, lr0=0.05, b1=0.9, b2=0.999, ea=1e-8):
    L, gradL, argminF, box = make_toy(eps, q)
    t1 = t2 = 0.0
    m1 = m2 = v1 = v2 = 0.0
    for t in range(1, T + 1):
        g1, g2 = gradL(t1, t2)
        if not decoupled:
            g1 += lam * t1
            g2 += lam * t2
        m1 = b1 * m1 + (1 - b1) * g1
        m2 = b1 * m2 + (1 - b1) * g2
        v1 = b2 * v1 + (1 - b2) * g1 * g1
        v2 = b2 * v2 + (1 - b2) * g2 * g2
        c1, c2 = 1 - b1**t, 1 - b2**t
        s1 = (m1 / c1) / (math.sqrt(v1 / c2) + ea)
        s2 = (m2 / c1) / (math.sqrt(v2 / c2) + ea)
        eta = lr0 / math.sqrt(1 + t / 1000.0)
        if decoupled:
            t1 -= eta * (s1 + lam * t1)
            t2 -= eta * (s2 + lam * t2)
        else:
            t1 -= eta * s1
            t2 -= eta * s2
    return t1, t2


def err(eps, q, t1, t2):
    a, b = eps * t1 + t2, eps * t1 - t2
    return (1 - q) * (a <= 0) + q * (b <= 0)


for eps, q, lams in [(0.8, 0.2, [0.3, 0.6, 1.2, 2.0]), (0.7, 0.3, [0.5, 2.0])]:
    L, gradL, argminF, box = make_toy(eps, q)
    lam_cf = 2 * eps / math.log((2 - 3 * q) / q)
    print(f"   eps = {eps}, q = {q} (eps^2 >= 1-2q; box threshold {lam_cf:.4f}):")
    for lam in lams:
        tA = adam(eps, q, lam, False)
        tF = argminF(lam)
        tW = adam(eps, q, lam, True)
        tB = box(lam)
        print(f"     coef {lam:<4}: Adam on F ({tA[0]:.4f}, {tA[1]:.4f}) err {err(eps, q, *tA):.2f} [argmin F ({tF[0]:.4f}, {tF[1]:.4f})]"
              f" | AdamW ({tW[0]:.4f}, {tW[1]:.4f}) err {err(eps, q, *tW):.2f} [box ({tB[0]:.4f}, {tB[1]:.4f}) err {err(eps, q, *tB):.2f}]")

# ================================================================================================
print()
print("=" * 100)
print("(E) Kinks for weight decay")
print("=" * 100)
grid = np.linspace(-1.0, 3.0, 400001)
rows = []
for om in [0.1, 0.5, 0.9, 1.0, 1.1, 2.0, 5.0]:
    F = np.abs(grid - 1.0) + 0.5 * om * grid**2
    th = grid[np.argmin(F)]
    rows.append(f"omega {om}: {th:.5f} (predicted {min(1.0, 1.0 / om):.5f})")
print("(E1) L(theta) = |theta - 1|: minimiser of L + (omega/2) theta^2 on a grid of step 1e-5: " + "; ".join(rows))
vals = []
for rho in [0.25, 0.81, 1.0, 1.21, 4.0]:
    sub = grid[grid**2 <= rho]
    vals.append(f"v({rho}) = {np.abs(sub - 1.0).min():.5f} (pred. {max(0.0, 1 - math.sqrt(rho)):.5f})")
print("     value function v(rho) = min{L : theta^2 <= rho}: " + "; ".join(vals) + "; convex, kink at rho = 1")
L, gradL, argminF, box = make_toy(0.1, 0.2)
pts = [argminF(float(om)) for om in np.logspace(-5, 1, 61)]
gaps = [math.hypot(pts[i + 1][0] - pts[i][0], pts[i + 1][1] - pts[i][1]) for i in range(len(pts) - 1)]
print(f"(E2) toy (eps, q) = (0.1, 0.2): minimisers at 61 log-spaced omegas in [1e-5, 10] are pairwise distinct along the path;"
      f" smallest distance between neighbours {min(gaps):.3e}")

# ================================================================================================
print()
print("=" * 100)
print("(F) Error rates of the programs of d1(C) against the sampler (f, p = 0.1), inputs uniform on 8 points")
print("=" * 100)
f8 = np.array([0, 1, 1, 0, 1, 0, 0, 1])
fprime = f8.copy()
fprime[3] ^= 1
ps = 0.1
progs = {"pi0 = (f, 0.1)": (f8, 0.1), "(f, 1/8)": (f8, 0.125), "(f', 0.1)": (fprime, 0.1), "coin": (f8, 0.5)}
for name, (g, qq) in progs.items():
    # label = f(x) w.p. 1-p; model gives g(x) w.p. 1-qq
    agree_det = (g == f8)
    argmax_err = np.mean(np.where(agree_det, ps, 1 - ps)) if qq < 0.5 else 0.5
    rand_err = np.mean(np.where(agree_det, qq * (1 - ps) + (1 - qq) * ps, (1 - qq) * (1 - ps) + qq * ps))
    print(f"   {name:<16}: argmax error {argmax_err:.4f}, randomised error {rand_err:.4f}")
print("   The sampler's randomised error is 2p(1-p) = 0.18; its argmax error is p = 0.1 (the coin's is 0.5 either way).")

# ================================================================================================
print()
print("=" * 100)
print("(G) Schedules lambda_n = c n + sqrt(n) with c n0 a breakpoint of h's hull (exact integer fits)")
print("=" * 100)
base = [(Fraction(1, 4),) * 4, (Fraction(1, 2), Fraction(1, 4), Fraction(1, 8), Fraction(1, 8)),
        (Fraction(1, 2), Fraction(1, 2), Fraction(0), Fraction(0)), (Fraction(1, 2), Fraction(1, 4), Fraction(1, 4), Fraction(0)),
        (Fraction(1), Fraction(0), Fraction(0), Fraction(0)), (Fraction(1, 2), Fraction(1, 8), Fraction(1, 8), Fraction(1, 4)),
        (Fraction(1, 2), Fraction(1, 4), Fraction(1, 8), Fraction(1, 16))]  # the last is a sub-probability kernel (mass 15/16)
rng = np.random.default_rng(777)


def lg2(fr):  # exact log2 of a power of two 2^-a (every nonzero kernel value above is one), as an int
    assert fr.numerator == 1 and fr.denominator & (fr.denominator - 1) == 0
    return -(fr.denominator.bit_length() - 1)


n_cases = 0
n_sub = 0
n_disj = 0
first_r = []
rs = [1, 10, 100, 1000, 10**4, 10**5, 10**6, 10**7]
for trial in range(4000):
    K = int(rng.integers(4, 10))
    kern = []
    for _ in range(K):
        b = list(base[int(rng.integers(0, len(base)))])
        rng.shuffle(b)
        kern.append(b)
    lengths = [int(v) for v in rng.integers(1, 15, size=K)]
    n0 = int(rng.integers(2, 9))
    counts = np.bincount(rng.integers(0, 4, size=n0), minlength=4)
    L = []
    for b in kern:
        if any(counts[y] > 0 and b[y] == 0 for y in range(4)):
            L.append(None)
        else:
            L.append(-sum(int(counts[y]) * lg2(b[y]) for y in range(4) if counts[y] > 0))
    fin = [i for i in range(K) if L[i] is not None]
    if len(fin) < 2:
        continue
    # lower hull of the points (length, fit); exact: the fits are integers (every kernel value is a power of 2)
    pts = sorted(set((lengths[i], L[i]) for i in fin))
    best = {}
    for a, Lv in pts:
        best[a] = min(best.get(a, math.inf), Lv)
    P = sorted(best.items())
    hull = []
    for pnt in P:
        # keep only points with strictly smaller fit than every shorter hull point (Pareto), then convexify
        if hull and pnt[1] >= hull[-1][1]:
            continue
        while len(hull) >= 2:
            (a1, l1), (a2, l2) = hull[-2], hull[-1]
            if (l2 - l1) * (pnt[0] - a1) >= (pnt[1] - l1) * (a2 - a1):
                hull.pop()
            else:
                break
        hull.append(pnt)
    Lmin = min(L[i] for i in fin)
    for e in range(1, len(hull)):
        (a1, l1), (a2, l2) = hull[e - 1], hull[e]
        if l2 <= Lmin:
            continue  # the edge reaches the maximum-likelihood vertex: condition (b) fails
        sigma = Fraction(l1 - l2, a2 - a1)  # exact: lengths and fits are integers
        Jb = {i: sigma * lengths[i] + L[i] for i in fin}
        jmin = min(Jb.values())
        M = {i for i in fin if Jb[i] == jmin}
        ML = {i for i in fin if L[i] == Lmin}
        if M & ML:
            continue
        n_cases += 1
        logw = [-lengths[i] + math.log2(float(rng.uniform(0.1, 10.0))) for i in range(K)]
        star = max(ML, key=lambda i: logw[i])
        rth = max([(logw[i] - logw[star]) / (L[i] - Lmin) for i in M if logw[i] > logw[star]] + [0.0])
        sub_from = None
        all_sub = True
        disj_ok = True
        for r in rs:
            lam = float(sigma) * r + math.sqrt(r * n0)  # lambda_{r n0} with c = sigma/n0
            Jr = [lam * lengths[i] + r * L[i] if L[i] is not None else math.inf for i in range(K)]
            jm = min(Jr)
            S = {i for i in range(K) if Jr[i] <= jm + 1e-9 * max(1.0, abs(jm))}
            if S <= M:
                if sub_from is None:
                    sub_from = r
            else:
                sub_from = None
            if r > rth:
                sc = [logw[i] - r * L[i] if L[i] is not None else -math.inf for i in range(K)]
                sm = max(sc)
                W = {i for i in range(K) if sc[i] >= sm - 1e-9 * max(1.0, abs(sm))}
                disj_ok = disj_ok and not (W & S)
        n_sub += sub_from is not None
        n_disj += disj_ok
        if sub_from is not None:
            first_r.append(sub_from)
print(f"cases (class, sample, breakpoint sigma = c n0 whose closed edge misses maximum likelihood): {n_cases}")
print(f"  lambda_{{r n0}}-MAPs of h^r inside the breakpoint's MAP set M at every listed r from some r on, up to r = {rs[-1]:.0e}: {n_sub} of {n_cases}")
print(f"  (that r is 1 in {sum(1 for v in first_r if v == 1)} cases; the largest is {max(first_r) if first_r else None})")
print(f"  for every listed r > r_th the lambda-MAPs and the MAPs of a full-support prior are disjoint: {n_disj} of {n_cases}")

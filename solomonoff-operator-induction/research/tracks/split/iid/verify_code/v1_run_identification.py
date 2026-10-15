"""v1: independent checks for iid notes-final Prop 3.3 (identification on the run, every lambda >= 1, any input
rule, PQ or FR).  Written for verify-iid.md; it does not import or read any record script.  Prop 3.3 is an
almost-sure, eventual statement; the simulations below illustrate it and check its finite-time ingredients.

(A) The Kakutani step: E[sqrt(Lambda_{n+1}/Lambda_n) | past, x_{n+1}] = sum_{y: nu > 0} sqrt(nu nu_pi) = 1 - g_{n+1}
    on 10^5 random kernel pairs (sub-probabilities and zeros included), exactly by summation; and a Monte Carlo of
    the martingale M_n = sqrt(Lambda_n)/prod(1 - g_i) under an adaptive rule (its mean stays 1).
(B) Step (a): Ville for Z^L under an adaptive rule: P[exists n <= H : Z^L_n >= 2^{-k}] <= 2^k t_L.
(C) The whole statement at lambda = 1, in a class with inputs x in {0, 1, 2, ...}, nu(1|x) = 0.8 (x even),
    0.2 (x odd), and programs
        nu_pi  the truth, l = 5 (k = 5)                       -- in K
        coin   Bern(1/2), l = 1                                 -- not in K once infinitely many inputs are queried
        even   truth on even x, Bern(1/2) on odd x, l = 2      -- not in K iff the run has infinitely many odd queries
        sig    truth +- 0.15 * 2^{-x/4} (summable Hellinger), l = 3
                                                                -- in K on distinct inputs; not in K in PQ with repeats
        u_t    truth on x <= t, Bern(1/2) above, l = 7 + 2 ceil(log2(t+1)), t = 0..4095  -- not in K
        e_t    truth except deterministic label 1 at x = t, same lengths as u_t            -- in K (finite deviation)
    Kraft sum < 1.  Two objects and adversarial rules:
      FR: distinct inputs; the rule queries new even inputs and a new odd input only at perfect-square steps,
          so the odd queries are sparse (sum of g for `even` grows like sqrt(n));
      PQ: fresh labels; the rule repeats the inputs {0, 2, ..., 18}, with input 1 at perfect-square steps.
    Reported per checkpoint: the fraction of runs whose lambda-MAPs are all in the run's K, and the mean posterior
    mass Pi_lambda(C \\ K | data) (power posterior), lambda in {1, 1.5}; and the largest MAP length seen.
Seeds 4101-4104.
"""
import math

import numpy as np

LOG2E = 1 / math.log(2)

print("=" * 100)
print("(A) Kakutani identity and martingale")
rng = np.random.default_rng(4101)
worst = 0.0
for _ in range(100000):
    Y = int(rng.integers(2, 5))
    nu = rng.dirichlet(np.ones(Y))
    if rng.random() < 0.3:
        nu[rng.integers(Y)] = 0
        nu /= nu.sum()
    q = rng.dirichlet(np.ones(Y)) * rng.uniform(0.5, 1)
    if rng.random() < 0.3:
        q[rng.integers(Y)] = 0
    lhs = sum(nu[y] * math.sqrt(q[y] / nu[y]) for y in range(Y) if nu[y] > 0)
    g = 1 - sum(math.sqrt(nu[y] * q[y]) for y in range(Y))
    worst = max(worst, abs(lhs - (1 - g)))
print(f"  max |E sqrt(Lambda ratio) - (1 - g)| over 1e5 random pairs: {worst:.1e}")
# martingale mean under an adaptive rule: x_{n+1} = argmax of the current g over two inputs, alternating ties
nu_x = {0: np.array([0.3, 0.7]), 1: np.array([0.6, 0.4])}
pi_x = {0: np.array([0.5, 0.45]), 1: np.array([0.7, 0.3])}
gx = {x: 1 - float(np.sum(np.sqrt(nu_x[x] * pi_x[x]))) for x in (0, 1)}
R, H = 200000, 40
M = np.ones(R)
lam_ = np.ones(R)
prodg = np.ones(R)
for n in range(H):
    # adaptive: query x = 0 if the current likelihood ratio exceeds 1, else x = 1
    x = (lam_ <= 1).astype(int)
    p1 = np.where(x == 0, nu_x[0][1], nu_x[1][1])
    y = (rng.random(R) < p1).astype(int)
    num = np.where(x == 0, pi_x[0][y], pi_x[1][y])
    den = np.where(x == 0, nu_x[0][y], nu_x[1][y])
    lam_ = lam_ * num / den
    prodg = prodg * np.where(x == 0, 1 - gx[0], 1 - gx[1])
M = np.sqrt(lam_) / prodg
print(f"  adaptive rule, n = {H}: mean of M_n = {M.mean():.4f} (s.e. {M.std() / math.sqrt(R):.4f}); "
      f"mean Lambda_n = {lam_.mean():.4f} (<= 1)")

# ----------------------------------------------------------------------------- the class of (B), (C)
TMAX = 4095


def bl(t):
    return int(t + 1 - 1).bit_length() if t >= 1 else 0


LU = [7 + 2 * math.ceil(math.log2(t + 1)) if t >= 1 else 7 for t in range(TMAX + 1)]
LEN = {"nu": 5, "coin": 1, "even": 2, "sig": 3}
kraft = sum(2.0 ** -l for l in LEN.values()) + 2 * sum(2.0 ** -l for l in LU)
assert kraft <= 1, kraft
K_TRUE = 5


def p1_true(x):
    return np.where(x % 2 == 0, 0.8, 0.2)


def p1_sig(x):
    sgn = np.where(x % 3 == 0, 1.0, -1.0)
    return np.clip(p1_true(x) + sgn * 0.15 * 2.0 ** (-x / 4), 0.01, 0.99)


def hel(p, q):
    return 1 - (math.sqrt(p * q) + math.sqrt((1 - p) * (1 - q)))


def run(obj, lam, rng, H, checkpoints):
    """one run; returns per checkpoint (all MAPs in K?, posterior mass outside K) and the max MAP length."""
    xs = []
    seen = set()
    nextE, nextO = 0, 1
    for n in range(1, H + 1):
        if obj == "FR":
            if math.isqrt(n) ** 2 == n:
                x, nextO = nextO, nextO + 2
            else:
                x, nextE = nextE, nextE + 2
        else:
            x = 1 if math.isqrt(n) ** 2 == n else 2 * int(rng.integers(0, 10))
        xs.append(x)
    xs = np.array(xs)
    y = (rng.random(H) < p1_true(xs)).astype(int)          # FR: each x is new, so one frozen label each
    if obj == "FR":
        assert len(set(xs.tolist())) == H
    # per-step log2 likelihood ratios vs the truth
    pt = np.where(y == 1, p1_true(xs), 1 - p1_true(xs))
    def llr(p1):
        return np.log2(np.where(y == 1, p1, 1 - p1) / pt)
    inc = {
        "coin": llr(np.full(H, 0.5)),
        "even": llr(np.where(xs % 2 == 0, p1_true(xs), 0.5)),
        "sig": llr(p1_sig(xs)),
    }
    cum = {k: np.cumsum(v) for k, v in inc.items()}
    # Hellinger sums g over the run (for K, read at the horizon)
    gsum = {"coin": sum(hel(float(p), 0.5) for p in p1_true(xs)),
            "even": sum(hel(float(p), 0.5) for p, x in zip(p1_true(xs), xs) if x % 2 == 1),
            "sig": sum(hel(float(p), float(q)) for p, q in zip(p1_true(xs), p1_sig(xs)))}
    # u_t: truth on x <= t, coin above; e_t: truth except label 1 forced at x = t
    out = []
    maxlen = 0
    for n in checkpoints:
        xn, yn = xs[:n], y[:n]
        ptn = pt[:n]
        # u_t log-ratio = sum over queries with x > t of log2(0.5 / pt)
        order = np.argsort(xn)
        xs_sorted = xn[order]
        contrib = np.log2(0.5 / ptn)[order]
        suffix = np.concatenate([np.cumsum(contrib[::-1])[::-1], [0.0]])
        ts = np.arange(TMAX + 1)
        idx = np.searchsorted(xs_sorted, ts, side="right")
        llr_u = suffix[idx]
        # e_t: at queries with x = t: label 1 -> log2(1/pt), label 0 -> -inf
        llr_e = np.zeros(TMAX + 1)
        for t in np.unique(xn[xn <= TMAX]):
            m = xn == t
            llr_e[t] = -np.inf if np.any(yn[m] == 0) else float(np.sum(np.log2(1 / ptn[m])))
        names = ["nu", "coin", "even", "sig"]
        llrs = np.array([0.0, cum["coin"][n - 1], cum["even"][n - 1], cum["sig"][n - 1]])
        lens = np.array([LEN[k] for k in names], float)
        allllr = np.concatenate([llrs, llr_u, llr_e])
        alllen = np.concatenate([lens, LU, LU])
        # K membership in the limit of the rule (decided analytically, not from the finite horizon):
        #  FR: the run's distinct inputs are eventually every even and every odd x, so coin, even, u_t are not in K
        #      (infinitely many terms bounded below) and sig, e_t are (summable, resp. one term < 1);
        #  PQ: the run repeats each of Q = {0, 2, ..., 18} and 1 infinitely often, so pi is in K iff nu_pi = nu
        #      on Q: coin, even, sig are not in K; u_t is in K iff t >= 18; e_t is in K iff t is not in Q.
        ts_ = np.arange(TMAX + 1)
        if obj == "FR":
            inK = np.concatenate([[True, False, False, True], np.zeros(TMAX + 1, bool), np.ones(TMAX + 1, bool)])
        else:
            Q = set(range(0, 19, 2)) | {1}
            inK = np.concatenate([[True, False, False, False], ts_ >= 18,
                                  np.array([t not in Q for t in ts_])])
        J = lam * alllen - allllr
        jmin = J.min()
        maps = J <= jmin + 1e-9
        maxlen = max(maxlen, int(alllen[maps].max()))
        w = np.exp2(-(J - jmin))
        out.append((bool(np.all(inK[maps])), float(w[~inK].sum() / w.sum())))
    return out, maxlen, gsum


print("=" * 100)
print(f"(C) lambda >= 1, adversarial rules (class of 4 + 2*{TMAX + 1} programs, Kraft sum {kraft:.4f})")
H = 4000
CPS = [50, 200, 1000, 4000]
for obj, seed in (("FR", 4103), ("PQ", 4104)):
    rngC = np.random.default_rng(seed)
    for lam in (1.0, 1.5):
        R = 200
        inK = np.zeros(len(CPS))
        mass = np.zeros(len(CPS))
        mx = 0
        gs = None
        for _ in range(R):
            out, ml, gs = run(obj, lam, rngC, H, CPS)
            inK += [o[0] for o in out]
            mass += [o[1] for o in out]
            mx = max(mx, ml)
        print(f"  {obj}, lambda={lam}: Hellinger sums over the n={H} queries of the last run: coin "
              f"{gs['coin']:.1f}, even {gs['even']:.2f}, sig {gs['sig']:.2f}")
        print(f"     fraction of runs with all MAPs in K at n = {CPS}: {[round(float(v) / R, 3) for v in inK]}; "
              f"mean Pi(C \\ K) = {[float(f'{v / R:.2e}') for v in mass]}; largest MAP length seen {mx}")

print("=" * 100)
print("(B) Ville for Z^L under the PQ rule of (C), lambda = 1: P[exists n <= 2000 : Z^L_n >= 2^-k] vs 2^k t_L")
rngB = np.random.default_rng(4102)
for L in (8, 12, 16):
    tL = sum(2.0 ** -l for l in LEN.values() if l > L) + 2 * sum(2.0 ** -l for l in LU if l > L)
    R = 300
    hit = 0
    for _ in range(R):
        Hb = 2000
        xs = np.array([1 if math.isqrt(n) ** 2 == n else 2 * int(rngB.integers(0, 10)) for n in range(1, Hb + 1)])
        y = (rngB.random(Hb) < p1_true(xs)).astype(int)
        pt = np.where(y == 1, p1_true(xs), 1 - p1_true(xs))
        # long programs: u_t and e_t with LU[t] > L; Z^L_n = sum 2^-l Lambda_n
        Z = np.zeros(Hb)
        for t in range(TMAX + 1):
            if LU[t] <= L:
                continue
            lu = np.cumsum(np.where(xs > t, np.log2(0.5 / pt), 0.0))
            m = xs == t
            le = np.cumsum(np.where(m, np.where(y == 1, np.log2(1 / pt), -np.inf), 0.0))
            Z += 2.0 ** -LU[t] * (np.exp2(lu) + np.exp2(le))
        hit += bool(np.any(Z >= 2.0 ** -K_TRUE))
    print(f"  L={L}: t_L = {tL:.3e}; MC P = {hit / R:.3f} <= 2^k t_L = {2 ** K_TRUE * tL:.3f}: "
          f"{hit / R <= 2 ** K_TRUE * tL}")
print("done")

"""rB1 (referee B): exact enumeration in many random small product classes, per-query i.i.d. data.

Tests, on exactly enumerable cases, the finite-sample statements of notes.md:
  * Lemma 2.1(d): rho_s <= rho_{1/2}^{2 min(s,1-s)}, on random kernel pairs including sub-probability
    kernels and kernels with zeros; and E[Lambda_n^s] = rho_s^n by exact enumeration (Lemma 2.1(c)).
  * Thm 4.1(iv): P[set of lambda-MAPs != E*] <= Renyi sum  sum_{pi not in E} 2^{l*-l(pi)} rho_{1/lambda}(pi)^n
    (finite class, L = longest program, so the delta* term is 0) <= margin bound 2^{l*} e^{-a n}.
    Checked at lambda = 1 as well (s = 1: Markov for Lambda itself).
  * Thm 4.1(vi): P[ Pi_lambda(C \\ E | h_n) > B_eps ] <= eps, with B_eps as stated in the notes
    (L = longest program in the class).
  * Thm 3.2: E[Pi_lambda(E* | h_n)] -> w_lambda = |E*| 2^{-lambda l*} / sum_{E} 2^{-lambda l}.
  * Def 1.2 (mu-a.e.): each class has an input x = 2 of mu-mass 0, and some programs of E differ from
    nu there.  They must count as members of E.

Setting.  X = {0, 1, 2}, mu(2) = 0, Y = {0, 1}.  Labels fresh per query, so the four counts
(n_{x,y}), x in {0,1}, are sufficient; their law is multinomial and is enumerated exactly.
Classes are random (seeded): truth nu, E* (one or two programs of length l*), possibly a longer
equivalent program, and 6-14 wrong programs of random types (random kernels, sub-probability kernels,
deterministic functions, local perturbations of nu, exceptions, the coin) and random lengths; Kraft
sum <= 1 is enforced.  Deterministic given the seed (numpy default_rng(20261013)).
"""
import numpy as np
from scipy.special import gammaln

rng = np.random.default_rng(20261013)
NEG = -1e300          # stands for log2(0); 0 * NEG = 0, c * NEG very negative but finite


def comp_array(n):
    i, j, k = np.meshgrid(np.arange(n + 1), np.arange(n + 1), np.arange(n + 1), indexing="ij")
    m = (i + j + k) <= n
    i, j, k = i[m], j[m], k[m]
    return np.stack([i, j, k, n - i - j - k], axis=1).astype(float)


def rho(nu, mu, K, s):
    """rho_s = E_mu sum_{y: nu>0} nu^{1-s} K^s  (K may be a sub-probability kernel)."""
    tot = 0.0
    for x in range(len(mu)):
        if mu[x] == 0:
            continue
        for y in range(2):
            if nu[x, y] > 0 and K[x, y] > 0:
                tot += mu[x] * nu[x, y] ** (1 - s) * K[x, y] ** s
    return tot


def random_class():
    mu = np.zeros(3)
    mu[0] = rng.uniform(0.15, 0.85)
    mu[1] = 1 - mu[0]
    p = rng.uniform(0.05, 0.95, size=3)
    nu = np.stack([1 - p, p], axis=1)
    lstar = int(rng.integers(3, 8))
    progs = []          # (name, length, kernel, inE)
    progs.append(("t*", lstar, nu.copy(), True))
    if rng.random() < 0.3:                       # a second shortest program, differing at the null input 2
        K = nu.copy(); K[2] = [0.0, 1.0]
        progs.append(("t*b", lstar, K, True))
    if rng.random() < 0.6:                       # a longer equivalent program (E \ E*)
        K = nu.copy(); K[2] = [0.3, 0.3]         # also differs at the null input
        progs.append(("tlong", lstar + int(rng.integers(1, 5)), K, True))
    nwrong = int(rng.integers(6, 15))
    for w in range(nwrong):
        typ = rng.choice(["rand", "sub", "det", "near", "exc", "coin"])
        K = nu.copy()
        if typ == "rand":
            q = rng.uniform(0, 1, size=3); K = np.stack([1 - q, q], axis=1)
        elif typ == "sub":
            q = rng.uniform(0, 1, size=3); c = rng.uniform(0.5, 1.0, size=3)
            K = np.stack([(1 - q) * c, q * c], axis=1)
            K[int(rng.integers(0, 2))] *= 1.0     # keep at least one row sub-probability (c < 1)
        elif typ == "det":
            f = rng.integers(0, 2, size=3); K = np.zeros((3, 2)); K[np.arange(3), f] = 1.0
        elif typ == "near":
            x = int(rng.integers(0, 2)); d = rng.choice([-1, 1]) * rng.uniform(0.005, 0.12)
            q = np.clip(nu[x, 1] + d, 0.001, 0.999); K[x] = [1 - q, q]
        elif typ == "exc":
            x = int(rng.integers(0, 2)); K[x] = [0.0, 1.0] if rng.random() < 0.5 else [1.0, 0.0]
        elif typ == "coin":
            K = np.full((3, 2), 0.5)
        L = int(rng.integers(1, lstar + 7))
        progs.append((f"{typ}{w}", L, K, False))
    # enforce Kraft <= 1 by lengthening wrong programs
    while sum(2.0 ** -L for _, L, _, _ in progs) > 1:
        progs = [(nm, L + (0 if inE else 1), K, inE) for nm, L, K, inE in progs]
    # a "wrong" program could coincide with nu on supp mu only by accident; recheck membership in E
    fixed = []
    for nm, L, K, inE in progs:
        eq = all(np.allclose(K[x], nu[x]) for x in range(2))
        fixed.append((nm, L, K, eq))
    return mu, nu, lstar, fixed


# ------------------------------------------------------------------------------------------------
print("=" * 78)
print("(1) Lemma 2.1(c),(d) on random kernel pairs (incl. sub-probability kernels and zeros)")
worst = -1.0
cnt = 0
worst_off = -1.0      # excluding s = 1/2, where the two sides are equal
for t in range(20000):
    mu = rng.dirichlet(np.ones(3))
    p = rng.uniform(0, 1, size=3)
    if rng.random() < 0.2:
        p[int(rng.integers(0, 3))] = rng.choice([0.0, 1.0])
    nu = np.stack([1 - p, p], axis=1)
    q = rng.uniform(0, 1, size=3)
    K = np.stack([1 - q, q], axis=1) * rng.uniform(0.3, 1.0, size=(3, 1)) ** (rng.random() < 0.5)
    if rng.random() < 0.2:
        K[int(rng.integers(0, 3)), int(rng.integers(0, 2))] = 0.0
    r12 = rho(nu, mu, K, 0.5)
    for s in np.linspace(0.02, 0.98, 25):
        dlt = rho(nu, mu, K, s) - r12 ** (2 * min(s, 1 - s))
        worst = max(worst, dlt)
        if abs(s - 0.5) > 1e-9:
            worst_off = max(worst_off, dlt)
        cnt += 1
print(f"  {cnt} (pair, s) cases: max of rho_s - rho_1/2^(2 min(s,1-s)) = {worst:.3e} (must be <= ~1e-15);"
      f" excluding s = 1/2: {worst_off:.3e}")

# exact E[Lambda_n^s] for a few pairs, n = 5, by enumeration over (x_i, y_i) sequences' counts
maxerr = 0.0
for t in range(30):
    mu = rng.dirichlet(np.ones(2)); mu = np.append(mu, 0.0)
    p = rng.uniform(0.05, 0.95, size=3); nu = np.stack([1 - p, p], axis=1)
    q = rng.uniform(0, 1, size=3); K = np.stack([1 - q, q], axis=1) * rng.uniform(0.5, 1.0)
    n = 5
    A = comp_array(n)
    cells = np.array([mu[0] * nu[0, 0], mu[0] * nu[0, 1], mu[1] * nu[1, 0], mu[1] * nu[1, 1]])
    logpmf = gammaln(n + 1) + (A * np.log(cells) - gammaln(A + 1)).sum(1)
    lr = np.log2(np.array([K[0, 0] / nu[0, 0], K[0, 1] / nu[0, 1], K[1, 0] / nu[1, 0], K[1, 1] / nu[1, 1]]))
    for s in (0.3, 0.5, 0.75, 1.0):
        e = float((np.exp(logpmf) * 2.0 ** (s * (A @ lr))).sum())
        maxerr = max(maxerr, abs(e - rho(nu, mu, K, s) ** n))
print(f"  max |E Lambda_5^s - rho_s^5| over 30 random pairs, s in {{.3,.5,.75,1}} = {maxerr:.2e}")

# ------------------------------------------------------------------------------------------------
print("=" * 78)
print("(2) Thm 4.1(iv) and (vi), Thm 3.2: 300 random classes, exact enumeration")
LAMS = [1.0, 1.05, 1.25, 1.5, 2.0, 3.0, 5.0]
NS = [4, 8, 16, 32, 64, 128]
COMP = {n: comp_array(n) for n in NS}
EPSS = [0.1, 0.01]
viol_R = viol_H = viol_vi = 0
rows = 0
nontriv_R = nontriv_vi = 0
max_ratio_R = 0.0          # exact / Renyi, over rows with Renyi < 1
min_slack_vi = np.inf
post_err = 0.0
lam1_last = []
nE_null = 0
examples = []
for c in range(300):
    mu, nu, lstar, progs = random_class()
    names = [p[0] for p in progs]
    lens = np.array([p[1] for p in progs], float)
    inE = np.array([p[3] for p in progs])
    nE_null += sum(1 for nm, L, K, e in progs if e and not np.allclose(K[2], nu[2]))
    Estar = inE & (lens == lstar)
    i0 = names.index("t*")
    LK = np.array([[np.log2(K[0, 0]) if K[0, 0] > 0 else NEG, np.log2(K[0, 1]) if K[0, 1] > 0 else NEG,
                    np.log2(K[1, 0]) if K[1, 0] > 0 else NEG, np.log2(K[1, 1]) if K[1, 1] > 0 else NEG]
                   for _, _, K, _ in progs])                     # (programs, 4 cells)
    cells = np.array([mu[0] * nu[0, 0], mu[0] * nu[0, 1], mu[1] * nu[1, 0], mu[1] * nu[1, 1]])
    gam = min(1 - rho(nu, mu, progs[i][2], 0.5) for i in range(len(progs)) if not inE[i])
    Lmax = lens.max()
    for n in NS:
        A = COMP[n]
        pmf = np.exp(gammaln(n + 1) + (A * np.log(cells) - gammaln(A + 1)).sum(1))
        LL = A @ LK.T                                             # (vectors, programs), log2 likelihoods
        for lam in LAMS:
            J = lam * lens[None, :] - LL
            J0 = J[:, i0]
            fail = (J[:, ~inE] <= J0[:, None] + 1e-9).any(1)
            exact = float(pmf[fail].sum())
            s = 1 / lam
            BR = sum(2.0 ** (lstar - lens[i]) * rho(nu, mu, progs[i][2], s) ** n for i in range(len(progs)) if not inE[i])
            rows += 1
            if exact > BR + 1e-12:
                viol_R += 1
                examples.append((c, lam, n, exact, BR))
            if BR < 1:
                nontriv_R += 1
                max_ratio_R = max(max_ratio_R, exact / BR)
            if lam > 1:
                a = 2 * min(1, lam - 1) * gam / lam
                BH = 2.0 ** lstar * np.exp(-a * n)
                if BR > BH + 1e-12:
                    viol_H += 1
                # (vi): posterior mass of C \ E
                W = -lam * lens[None, :] + LL
                mx = W.max(1, keepdims=True)
                Q = np.exp2(W - mx)
                postbad = Q[:, ~inE].sum(1) / Q.sum(1)
                for eps in EPSS:
                    B = 2.0 ** (lam * lstar) * ((2 / eps) ** lam * np.exp(-lam * a * n)
                                                + 2.0 ** (np.log2(2 / eps) - (lam - 1) * Lmax))
                    pr = float(pmf[postbad > B].sum())
                    nontriv_vi += B < 1
                    min_slack_vi = min(min_slack_vi, eps - pr)
                    if pr > eps + 1e-12:
                        viol_vi += 1
            if n == NS[-1] and lam in (1.0, 1.5, 3.0):
                W = -lam * lens[None, :] + LL
                mx = W.max(1, keepdims=True); Q = np.exp2(W - mx)
                pE = float((pmf * Q[:, Estar].sum(1) / Q.sum(1)).sum())
                pEall = float((pmf * Q[:, inE].sum(1) / Q.sum(1)).sum())
                wl = Estar.sum() * 2.0 ** (-lam * lstar) / (2.0 ** (-lam * lens[inE])).sum()
                # compare the conditional share of E* within E (the limit object) at finite n
                post_err = max(post_err, abs(pE / max(pEall, 1e-300) - wl) if pEall > 0.999 else 0.0)
            if lam == 1.0 and n == NS[-1]:
                lam1_last.append(exact)
print(f"  rows (class, lambda, n) = {rows}")
print(f"  Thm 4.1(iv): exact > Renyi sum in {viol_R} rows; Renyi > margin bound in {viol_H} rows (lambda>1)")
print(f"  rows with Renyi sum < 1 (non-trivial): {nontriv_R}; largest exact/Renyi ratio among them: {max_ratio_R:.3f}")
print(f"  Thm 4.1(vi): P[Pi(C\\E) > B_eps] > eps in {viol_vi} (class, lambda, n, eps) cases; "
      f"smallest slack eps - P = {min_slack_vi:.3e}; cases with B_eps < 1 (non-trivial): {nontriv_vi}")
print(f"  Thm 3.2: max |E*-share of the E-posterior - w_lambda| at n = 128 (rows with Pi(E) > 0.999): {post_err:.2e}")
print(f"  programs of E that differ from nu on the null input x = 2 (counted in E): {nE_null}")
print(f"  lambda = 1, n = 128: exact P[MAPs != E*] over classes: median {np.median(lam1_last):.2e}, "
      f"max {np.max(lam1_last):.3f}")
if examples:
    print("  violations:", examples[:5])

# ------------------------------------------------------------------------------------------------
print("=" * 78)
print("(3) Is lambda = 2 slower than lambda = 1?  (notes Prop 4.4(c): yes, against shorter programs)")
# For each class: exact P_fail at lambda = 1 and 2, n in {64, 128}.  The 'dominant competitor' is the
# wrong program that most often has J_1 <= J_1(truth) (probability of that event, exact).
res = {"shorter": [0, 0], "longer": [0, 0]}
for c in range(300):
    mu, nu, lstar, progs = random_class()
    names = [p[0] for p in progs]; lens = np.array([p[1] for p in progs], float)
    inE = np.array([p[3] for p in progs]); i0 = names.index("t*")
    LK = np.array([[np.log2(K[a, b]) if K[a, b] > 0 else NEG for a in (0, 1) for b in (0, 1)] for _, _, K, _ in progs])
    cells = np.array([mu[0] * nu[0, 0], mu[0] * nu[0, 1], mu[1] * nu[1, 0], mu[1] * nu[1, 1]])
    for n in (64, 128):
        A = COMP[n]
        pmf = np.exp(gammaln(n + 1) + (A * np.log(cells) - gammaln(A + 1)).sum(1))
        LL = A @ LK.T
        pf = {}
        for lam in (1.0, 2.0):
            J = lam * lens[None, :] - LL
            pf[lam] = float(pmf[(J[:, ~inE] <= J[:, [i0]] + 1e-9).any(1)].sum())
        J = lens[None, :] - LL
        wrong = np.flatnonzero(~inE)
        pw = [float(pmf[J[:, i] <= J[:, i0] + 1e-9].sum()) for i in wrong]
        dom = wrong[int(np.argmax(pw))]
        if max(pw) < 1e-6:
            continue
        key = "shorter" if lens[dom] < lstar else "longer"
        res[key][0] += 1
        res[key][1] += pf[2.0] > pf[1.0] + 1e-12
for key in ("shorter", "longer"):
    print(f"  (class, n) with dominant lambda=1 competitor {key} than l*: {res[key][0]}; "
          f"lambda=2 has larger P_fail in {res[key][1]}")

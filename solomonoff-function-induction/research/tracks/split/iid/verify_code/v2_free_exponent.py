"""v2: independent checks of iid notes-final Thm 4.1(iv') (free-exponent bound), Thm 4.1(v) (uniform in time) and
the lambda = 1 numbers of Remark 4.7, in PQ, by exact enumeration and Monte Carlo.  Written for verify-iid.md; it
does not import or read any record script.

Class A (designed here).  X = {a, b}, mu = (0.3, 0.7), Y = {0, 1}, nu(1|a) = 0.2, nu(1|b) = 0.65.  Programs, given
by (P(0|a), P(1|a), P(0|b), P(1|b)) so that sub-probabilities are allowed:
  t4  truth, l=4  (E0);  t6, t9 truth copies, l=6, 9 (E \ E0)
  coin l=2; s2 = (0.8,0.2,0.8,0.2) l=2; n3 = near (0.75,0.25 at a; truth at b) l=3; d3 deterministic (1,0,0,1) l=3;
  n5 = (truth at a; 0.4,0.6 at b) l=5; sub4 = 0.9 * truth l=4; z7 = (1,0 at a; truth at b) l=7;
  r8_1..r8_10: ten random kernels (seed 4201) of length 8.
  Kraft sum < 1 (asserted).
Exact P[set of lambda-MAPs != E0] at n by enumeration of all count vectors (ties counted as failures), against
  (iv')  sum_{pi not in E} inf_{0<s<=1} 2^{-s lambda (l - l0)} rho_s^n   (inf by convex minimisation in s, since
         log rho_s is convex in s; checked against a grid),
  the s = 1/lambda form, and the second displayed form of (iv') (s = 1/lambda up to L, s = 1 above).
Remark 4.7 numbers: the lambda = 1 free-exponent bound in the record's i1 class (data re-typed from the record's
  description in notes-final §2/§4 and i8's header), at n = 40 and 160.
(v): class B (designed here) with a moderate margin; Monte Carlo of P[exists n in [n0, H]: MAPs != E0] against
  2^{lambda l0 - (lambda-1) L} + 2^{l0} e^{-a_L n0} (1 + 1/a_L); and the inequality 1/(1-e^{-a}) <= 1 + 1/a.
Seeds: 4201 (random kernels), 4202 (Monte Carlo).
"""
import math

import numpy as np
from scipy.optimize import minimize_scalar
from scipy.special import gammaln

LN2 = math.log(2)


def make_class_A():
    nu = np.array([0.8, 0.2, 0.35, 0.65])
    C = {
        "t4": (4, nu.copy()), "t6": (6, nu.copy()), "t9": (9, nu.copy()),
        "coin": (2, np.array([0.5, 0.5, 0.5, 0.5])),
        "s2": (2, np.array([0.8, 0.2, 0.8, 0.2])),
        "n3": (3, np.array([0.75, 0.25, 0.35, 0.65])),
        "d3": (3, np.array([1.0, 0.0, 0.0, 1.0])),
        "n5": (5, np.array([0.8, 0.2, 0.4, 0.6])),
        "sub4": (4, 0.9 * nu),
        "z7": (7, np.array([1.0, 0.0, 0.35, 0.65])),
    }
    rng = np.random.default_rng(4201)
    for i in range(10):
        pa = rng.dirichlet([1, 1]) * rng.uniform(0.7, 1.0)
        pb = rng.dirichlet([1, 1]) * rng.uniform(0.7, 1.0)
        C[f"r8_{i}"] = (8, np.array([pa[0], pa[1], pb[0], pb[1]]))
    mu = np.array([0.3, 0.3, 0.7, 0.7])            # mu(x) per cell
    E = {"t4", "t6", "t9"}
    return mu, nu, C, E, 4



def make_class_A2():
    """Class A with the near programs moved away from the truth (moderate margin), same structure otherwise."""
    mu, nu, C, E, l0 = make_class_A()
    C = dict(C)
    C["n3"] = (3, np.array([0.55, 0.45, 0.35, 0.65]))
    C["n5"] = (5, np.array([0.8, 0.2, 0.75, 0.25]))
    return mu, nu, C, E, l0


def rho(mu, nu, ker, s):
    m = (nu > 0) & (ker > 0)
    # sum over x of mu(x) sum_y nu^{1-s} ker^s; mu per cell already repeats mu(x) for both labels
    return float(np.sum(np.where(m, mu * nu ** (1 - s) * np.where(ker > 0, ker, 1) ** s, 0.0)))


def free_exp_term(mu, nu, ker, lam, dl, n):
    """inf_{0<s<=1} 2^{-s lam dl} rho_s^n, via convex minimisation of the log (plus a grid as a safeguard)."""
    def g(s):
        r = rho(mu, nu, ker, s)
        return -s * lam * dl * LN2 + (n * math.log(r) if r > 0 else -math.inf)
    res = minimize_scalar(g, bounds=(1e-12, 1.0), method="bounded", options={"xatol": 1e-12})
    grid = min(g(s) for s in np.concatenate([[1e-12, 1e-6, 1e-3], np.linspace(0.01, 1, 100)]))
    best = min(res.fun, grid, g(1.0), g(1 / lam) if lam >= 1 else math.inf)
    assert best <= grid + 1e-9
    return math.exp(best), grid


def count_vectors(n, ncell=4):
    assert ncell == 4
    out = []
    for c1 in range(n + 1):
        r = n - c1
        c2 = np.repeat(np.arange(r + 1), np.arange(r + 1, 0, -1))
        c3 = np.concatenate([np.arange(r - a + 1) for a in range(r + 1)])
        c4 = r - c2 - c3
        out.append(np.stack([np.full_like(c2, c1), c2, c3, c4], 1))
    return np.concatenate(out)


def exact_fail(mu, nu, C, E0, n, lam, tol=1e-9):
    cv = count_vectors(n)
    pc = mu * nu
    with np.errstate(divide="ignore"):
        logp = gammaln(n + 1) - gammaln(cv + 1).sum(1) + (cv * np.log(np.where(pc > 0, pc, 1))).sum(1)
    feasible = np.all((pc > 0) | (cv == 0), axis=1)
    names = list(C)
    J = np.empty((len(cv), len(names)))
    for j, nm in enumerate(names):
        l, ker = C[nm]
        with np.errstate(divide="ignore", invalid="ignore"):
            lk = np.where(ker > 0, np.log2(np.where(ker > 0, ker, 1)), -np.inf)
            terms = np.where(cv > 0, cv * lk[None, :], 0.0)
        J[:, j] = lam * l - terms.sum(1)
    i0 = names.index(E0)
    Jt = J[:, i0]
    others = np.delete(J, i0, axis=1)
    fail = np.any(others <= Jt[:, None] + tol, axis=1)
    p = np.exp(logp)
    return float(np.sum(np.where(feasible & fail, p, 0.0))), float(np.sum(np.where(feasible, p, 0.0)))


print("=" * 100)
print("(A) Thm 4.1(iv'): exact P[MAPs != E0] <= free-exponent bound <= min(s=1/lambda form, second form)")
viol = 0
rows = 0
for cname, maker in (("A", make_class_A), ("A2", make_class_A2)):
    mu, nu, C, E, l0 = maker()
    kraft = sum(2.0 ** -l for l, _ in C.values())
    assert kraft <= 1
    nonE = [nm for nm in C if nm not in E]
    gam = min(1 - rho(mu, nu, C[nm][1], 0.5) for nm in nonE)
    print(f"  class {cname}: Kraft sum {kraft:.4f}; l0 = {l0}; |class| = {len(C)}; global margin gamma = {gam:.5f}")
    for lam in (0.5, 1.0, 1.5, 2.0, 3.0):
        for n in (10, 40, 80, 160, 240, 320):
            ex, tot = exact_fail(mu, nu, C, "t4", n, lam)
            assert abs(tot - 1) < 1e-9
            fe = 0.0
            gridb = 0.0
            for nm in nonE:
                l, ker = C[nm]
                v, gv = free_exp_term(mu, nu, ker, lam, l - l0, n)
                fe += v
                gridb += math.exp(gv)
            if lam >= 1:
                ren = sum(2.0 ** (l0 - C[nm][0]) * rho(mu, nu, C[nm][1], 1 / lam) ** n for nm in nonE)
                L = 6
                tL = sum(2.0 ** -C[nm][0] for nm in C if C[nm][0] > L)
                second = sum(2.0 ** (l0 - C[nm][0]) * rho(mu, nu, C[nm][1], 1 / lam) ** n
                             for nm in nonE if C[nm][0] <= L) + 2.0 ** (lam * l0 - (lam - 1) * L) * tL
            else:
                ren = second = float("nan")
            rows += 1
            ok = ex <= fe * (1 + 1e-9) and (lam < 1 or fe <= min(ren, second) * (1 + 1e-9))
            viol += not ok
            print(f"    lambda={lam:3.1f} n={n:3d}: exact={ex:.3e}  free-exp={fe:.3e} (grid {gridb:.3e})  "
                  f"s=1/lambda={ren:.3e}  2nd form(L=6)={second:.3e}  {'ok' if ok else 'VIOLATION'}")
print(f"  rows: {rows}, violations of exact <= free-exp <= min(s=1/lambda form, second form): {viol}")

print("=" * 100)
print("(B) Remark 4.7: the lambda = 1 free-exponent bound in the record's i1 class (data re-typed)")
# i1's class: X = {a, b} uniform; nu(.|a) = (0.9, 0.1), nu(.|b) = (0.2, 0.8); cells (a0, a1, b0, b1)
mu1 = np.array([0.5, 0.5, 0.5, 0.5])
nu1 = np.array([0.9, 0.1, 0.2, 0.8])
C1 = {"t5": (5, nu1), "t7": (7, nu1), "coin": (2, np.array([.5, .5, .5, .5])),
      "s3": (3, np.array([.9, .1, .9, .1])), "near": (4, np.array([.9, .1, .6, .4])),
      "far6": (6, np.array([.5, .5, .2, .8])), "det": (3, np.array([1., 0., 0., 1.])),
      "sub6": (6, np.array([.9, .1, .1, .6]))}
E1 = {"t5", "t7"}
for n in (40, 80, 160):
    fe = sum(free_exp_term(mu1, nu1, C1[nm][1], 1.0, C1[nm][0] - 5, n)[0] for nm in C1 if nm not in E1)
    ren = sum(2.0 ** (5 - C1[nm][0]) * rho(mu1, nu1, C1[nm][1], 1.0) ** n for nm in C1 if nm not in E1)
    ex, _ = exact_fail(mu1, nu1, C1, "t5", n, 1.0)
    print(f"  n={n:3d}: exact={ex:.3e}  free-exp (lambda=1)={fe:.3e}  s=1 (Renyi at lambda=1)={ren:.3f}")

print("=" * 100)
print("(C) Thm 4.1(v): Monte Carlo of the uniform-in-time event, class B")
muB = np.array([0.5, 0.5, 0.5, 0.5])
nuB = np.array([0.9, 0.1, 0.2, 0.8])
CB = {"t3": (3, nuB), "t6": (6, nuB), "coin": (2, np.array([.5, .5, .5, .5])),
      "flip": (3, np.array([.1, .9, .8, .2])), "hb": (4, np.array([.9, .1, .5, .5])),
      "ha": (4, np.array([.6, .4, .2, .8])), "det": (4, np.array([1., 0., 0., 1.])),
      "q5": (5, np.array([.75, .25, .2, .8]))}
assert sum(2.0 ** -l for l, _ in CB.values()) <= 1
EB = {"t3", "t6"}
l0B = 3
gB = min(1 - rho(muB, nuB, CB[nm][1], 0.5) for nm in CB if nm not in EB)
print(f"  class B margin gamma = {gB:.5f}")
rng = np.random.default_rng(4202)
names = list(CB)
LK = np.array([[math.log2(v) if v > 0 else -np.inf for v in CB[nm][1]] for nm in names])   # (prog, cell)
LENS = np.array([CB[nm][0] for nm in names], float)
it = names.index("t3")
H = 6000
R = 3000
for lam in (1.5, 2.0, 4.0):
    a = 2 * min(1, lam - 1) * gB / lam
    L = 60
    for n0 in (200, 600, 1500):
        bound = 2.0 ** (lam * l0B - (lam - 1) * L) + 2.0 ** l0B * math.exp(-a * n0) * (1 + 1 / a)
        bad = 0
        for r in range(R):
            cells = rng.choice(4, size=H, p=muB * nuB)
            onehot = np.zeros((H, 4))
            onehot[np.arange(H), cells] = 1
            cnt = np.cumsum(onehot, 0)[n0 - 1:]            # counts at n = n0..H
            with np.errstate(invalid="ignore"):
                Lfit = -np.where(cnt[:, None, :] > 0, cnt[:, None, :] * LK[None], 0.0).sum(2)
            J = lam * LENS[None] + Lfit
            Jt = J[:, it]
            oth = np.delete(J, it, axis=1)
            bad += bool(np.any(oth <= Jt[:, None] + 1e-9))
        print(f"  lambda={lam}: n0={n0:5d}: MC P[exists n in [n0, {H}]: MAPs != E0] = {bad / R:.4f}  "
              f"<= (v) bound {min(bound, 99):.4g}: {bad / R <= bound}")
aa = np.logspace(-6, 2, 2000)
print(f"  1/(1-e^-a) <= 1 + 1/a on a in [1e-6, 1e2]: {bool(np.all(1 / (-np.expm1(-aa)) <= 1 + 1 / aa + 1e-12))}")
print("done")

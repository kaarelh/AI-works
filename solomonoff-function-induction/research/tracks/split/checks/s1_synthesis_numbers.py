"""s1: synthesis-level recomputation of the numbers that ../notes-final.md quotes in its headline statements and
cross-track comparisons.  Deterministic (no randomness).  Python 3.11, numpy, scipy.

Every quantity is recomputed here from its closed form, independently of the sub-tracks' scripts; the values the
sub-track records quote are given next to each line for comparison.  Inputs that are properties of a sub-track's
explicit class (for example the margins of k6's class) are copied from that sub-track's saved output and marked
"input from <file>".

(A) iid Thm 4.1(iv): n(lambda, l0, gamma, eps) = ceil(lambda (l0 + log(2/eps)) ln2 / (2 min(1, lambda-1) gamma)) at
    the noisy-parity class of iid i4 (l0 = 10, gamma = h_=(1/8, 3/16), eps = 0.05).
(B) The two finite-sample forms side by side at kink k6's per-query instance (l0 = 19): iid Thm 4.1(iv) with
    L_eps = ceil((lambda l0 + log(2/eps))/(lambda-1)) and kink Cor 5.5 with lbar = l0 + (l0 + log(1/eps))/(lambda-1),
    each at the same guarantee 0.90 (iid eps = 0.10; kink eps = 0.05, guarantee 1 - 2 eps).
(C) iid Prop 5.1 / i7: the lambda = 1 recovery times 2^((k+4)/2) + 6 at eps = 0.01 against the proved bracket
    (2^((k-8)/2) - 6, max(32, ceil(2^((k+1)/2)/sqrt(eps)))]; and iid Remark 4.5's attained parity lengths.
(D) The flip-rate constants: G_1 = H (0.05596), f_1 = 1 - log(3/2 - p) = H (0.12331), min of f_2 - H on (0, 1/4]
    with f_2 = 1 - log(1 + (1-2p)/4) (>= 0.0187), and teacher Prop 5.3's psi_2(p, 1) = H crossing (0.07787) and
    a*(p) at p = 5/64, 3/32, 0.1, 7/64, 15/128, 0.12.
(E) The three-hypothesis rates of rem:teacher:hanni: H(2^-10)/9990 and (1 - H(2^-10))/110.
(F) The good model's offset b_0 at d = m = 20, p = 2^-10, kappa = 0, delta_E = 0, in the two conventions
    (2 log d, teacher's final record; 2 log(d+1), kink's final record) and the resulting length bound at lambda = 2.
(G) iid Prop 4.4(a) constants 8.66 and 0.083.
"""
import math
from math import ceil, comb, log2, sqrt

import numpy as np
from scipy.optimize import brentq, minimize_scalar
from scipy.special import gammaln

LN2 = math.log(2)


def H(p):
    if p <= 0 or p >= 1:
        return 0.0
    return -p * log2(p) - (1 - p) * log2(1 - p)


def line(c="-"):
    print(c * 100)


# ---------------------------------------------------------------------------------------------------------------
line("=")
print("(A) iid Thm 4.1(iv) sample size at the i4 class (l0 = 10, eps = 0.05)")
p, q = 1 / 8, 3 / 16
gamma_i4 = 1 - sqrt(p * q) - sqrt((1 - p) * (1 - q))  # h_=(1/8, 3/16)
print(f"  gamma = h_=(1/8, 3/16) = {gamma_i4:.6f}   (iid quotes 0.003736)")


def n_iid(lam, l0, gamma, eps):
    return ceil(lam * (l0 + log2(2 / eps)) * LN2 / (2 * min(1.0, lam - 1) * gamma))


for lam, eps, quoted in [(2.0, 0.05, 2843), (1.5, 0.05, 4264), (4.0, 0.05, 5686),
                         (2.0, 0.01, 3274), (1.5, 0.01, 4911), (4.0, 0.01, 6547)]:
    v = n_iid(lam, 10, gamma_i4, eps)
    raw = lam * (10 + log2(2 / eps)) * LN2 / (2 * min(1.0, lam - 1) * gamma_i4)
    flag = "" if v == quoted else "   <-- i4 prints the rounded value, not the ceiling of the theorem"
    print(f"  lambda = {lam}, eps = {eps}: raw = {raw:.3f}, ceiling n = {v}   (i4 prints {quoted}){flag}")
    assert abs(v - quoted) <= 1

# ---------------------------------------------------------------------------------------------------------------
line("=")
print("(B) iid Thm 4.1(iv) against kink Cor 5.5 at k6's per-query noisy parity (l0 = 19), guarantee 0.90")
# Margins of k6's class: input from kink/checks/k6_perquery.out, part (D):
#   gamma_L(20) = 3.736e-03, gamma_L(21) = 1.013e-03, gamma_L(22) = ... = gamma_L(30) = 2.652e-04, and
#   gamma_lbar = 2.652e-04 at every cap used by Cor 5.5 (lbar = 65.6, 42.3, 26.8, 22.3).
GAMMA_CAP = {20: 3.736e-3, 21: 1.013e-3}


def gamma_L(L):
    assert L >= 22 or L in GAMMA_CAP
    return GAMMA_CAP.get(L, 2.652e-4)


l0 = 19
kink_quoted = {1.5: 9.144e4, 2.0: 6.096e4, 4.0: 1.106e5, 8.0: 2.1e5}
for lam in [1.5, 2.0, 4.0, 8.0]:
    eps_iid = 0.10  # guarantee 1 - eps
    L_eps = ceil((lam * l0 + log2(2 / eps_iid)) / (lam - 1))
    n_i = n_iid(lam, l0, gamma_L(L_eps), eps_iid)
    eps_k = 0.05  # guarantee 1 - 2 eps
    lbar = l0 + (l0 + log2(1 / eps_k)) / (lam - 1)
    g = gamma_L(math.floor(lbar))
    n_k = LN2 * (max(0.0, 2 - lam) * lbar + lam * l0 + 2 * log2(1 / eps_k)) / (2 * g)
    print(f"  lambda = {lam}: iid L_eps = {L_eps}, n = {n_i:.4g};  kink lbar = {lbar:.1f}, n0 = {n_k:.4g} "
          f"(k6 quotes {kink_quoted[lam]:.4g});  ratio iid/kink = {n_i / n_k:.3f}")
    assert abs(n_k / kink_quoted[lam] - 1) < 0.01

# ---------------------------------------------------------------------------------------------------------------
line("=")
print("(C) iid Prop 5.1 and i7: recovery times in C_k at eps = 0.01; iid Remark 4.5")
i7_quoted = {16: 1030, 24: 16390, 32: 262150, 40: 4194310}  # iid notes-final, table after Prop 5.1 (i7(A))
for k in [16, 24, 32, 40]:
    v = 2 ** ((k + 4) // 2) + 6
    lo = 2 ** ((k - 8) / 2) - 6
    hi = max(32, ceil(2 ** ((k + 1) / 2) / sqrt(0.01)))
    print(f"  k = {k}: 2^((k+4)/2)+6 = {v} (i7: {i7_quoted[k]}); proved bracket ({lo:.0f}, {hi}]; "
          f"inside: {lo < v <= hi}")
    assert v == i7_quoted[k] and lo < v <= hi
for (k, lam), quoted in {(20, 2): 38, (20, 1.5): 56, (30, 3): 44, (16, 1.25): 72, (40, 2): 78}.items():
    n = lam * (k - 2) / (lam - 1)
    length = (lam * k - 2) / (lam - 1)
    gap = log2(1 + 2 ** (2 - k)) / (lam - 1)
    print(f"  Remark 4.5 (k, lambda) = ({k}, {lam}): n = M = {n:g}, parity length (lambda k - 2)/(lambda - 1) = "
          f"{length:g} (iid: {quoted}); gap to the delta_n bound = {gap:.2e} bits")
    assert abs(length - quoted) < 1e-9 and abs(n - round(n)) < 1e-9

# ---------------------------------------------------------------------------------------------------------------
line("=")
print("(D) flip-rate constants")
G1 = lambda p: 1 - log2(1.5 + 2 * p)          # G_1 at B = infinity
f1 = lambda p: 1 - log2(1.5 - p)
f2 = lambda p: 1 - log2(1 + (1 - 2 * p) / 4)
r1 = brentq(lambda p: G1(p) - H(p), 1e-6, 0.2)
r2 = brentq(lambda p: f1(p) - H(p), 1e-3, 0.249)
print(f"  G_1(p) = H(p) at p = {r1:.5f}   (paper 0.0560; kink 0.05596)")
print(f"  f_1(p) = H(p) at p = {r2:.5f}   (kink, teacher 0.12331)")
ps = np.linspace(1e-6, 0.25, 250001)
vals = np.array([f2(x) - H(x) for x in ps])
print(f"  min over a 250001-point grid of (0, 1/4] of f_2 - H = {vals.min():.7f} at p = {ps[vals.argmin()]:.5f} "
      f"(kink: rigorous lower bound 0.0187953, value at 1/4 is 0.0187969)")
assert vals.min() >= 0.0187


def psi2(p, a):
    A = 0.75 - p / 2
    k = 2 * p * sqrt(LN2 / 2)
    fobj = lambda y: a * p * y * y - log2(A + k * y)  # convex in y = sqrt(x) >= 0
    res = minimize_scalar(fobj, bounds=(0.0, 100.0), method="bounded", options={"xatol": 1e-12})
    return min(res.fun, fobj(0.0))


r3 = brentq(lambda p: psi2(p, 1.0) - H(p), 0.03, 0.12)
print(f"  psi_2(p, 1) = H(p) at p = {r3:.5f}   (teacher p* = 0.07787)")


def a_star(p):
    if psi2(p, 1.0) > H(p):
        return 1.0
    return brentq(lambda a: psi2(p, a) - H(p), 1.0, 1e4)


for p, quoted in [(5 / 64, 1.011), (3 / 32, 2.128), (0.1, 3.034), (7 / 64, 5.999), (15 / 128, 15.585), (0.12, 30.20)]:
    v = a_star(p)
    print(f"  a*({p:.6g}) = {v:.4f}   (teacher {quoted})")
    assert abs(v / quoted - 1) < 2e-3

# ---------------------------------------------------------------------------------------------------------------
line("=")
print("(E) the three-hypothesis rates (rem:teacher:hanni, per-sample version)")
h = H(2 ** -10)
print(f"  H(2^-10) = {h:.6f}; errors' rate H/9990 = {h / 9990:.5g} (paper 1.1185e-6); "
      f"model's rate (1-H)/110 = {(1 - h) / 110:.5g} (paper 8.989e-3); ratio = {((1 - h) / 110) / (h / 9990):.0f}")

# ---------------------------------------------------------------------------------------------------------------
line("=")
print("(F) b_0 at d = m = 20, p = 2^-10, kappa = 0, delta_E = 0; the length bound d + kappa_g + b_0/(lambda-1) at lambda = 2")
d, r = 20, 10
N = 2 ** d
pN = N >> r
L_E = (gammaln(N + 1) - gammaln(pN + 1) - gammaln(N - pN + 1)) / LN2
NH = N * H(2 ** -r)
kappa_g = 2 * log2(d) + 2 * log2(r)
for name, lt in [("2 log d (teacher final)", 2 * log2(d)), ("2 log(d+1) (kink final)", 2 * log2(d + 1))]:
    b0 = kappa_g + (NH - L_E) + 0 + lt
    print(f"  {name}: NH - L_E = {NH - L_E:.4f}, kappa_g = {kappa_g:.4f}, b_0 = {b0:.4f}, "
          f"length bound at lambda = 2: d + {kappa_g + b0:.4f}")
print("  (teacher quotes d + 45.55 and d + 45.69; kink quotes d + 45.7 with 2 log(d+1), d + 45.5 with 2 log d)")

# ---------------------------------------------------------------------------------------------------------------
line("=")
print("(G) iid Prop 4.4(a) constants")
c1 = max(4 * (1 + 2 * e) / ((1 - 2 * e) * LN2) for e in np.linspace(1e-6, 0.1, 100001))
print(f"  max over eps' <= 0.1 of 4(1+2eps')/((1-2eps') ln2) = {c1:.4f} (iid 8.66; referee 8.6562)")
print(f"  0.96 ln2 / 8 = {0.96 * LN2 / 8:.5f} (iid 0.083; referee 0.08318)")
line("=")
print("all assertions passed")

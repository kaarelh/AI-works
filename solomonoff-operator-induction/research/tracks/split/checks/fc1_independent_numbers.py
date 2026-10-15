"""fc1 (final check of ../notes-final.md): independent recomputation of numbers quoted in the synthesis.

Deterministic; shares no code with s1_synthesis_numbers.py. Each block names the statement it checks.
Run: python3 -I fc1_independent_numbers.py > fc1_independent_numbers.out
"""
from fractions import Fraction
from math import ceil, log, log2, sqrt


def H(p):
    return -p * log2(p) - (1 - p) * log2(1 - p)


# (A) iid Thm 4.1(iv), sample size at the i4 class: l0 = 10, gamma = h_=(1/8, 3/16)  [synthesis §7.3]
print("(A) iid Thm 4.1(iv) at the i4 class (l0 = 10)")
g = 1 - sqrt(1 / 8 * 3 / 16) - sqrt(7 / 8 * 13 / 16)
print(f"  gamma = h_=(1/8, 3/16) = {g:.6f}")
for eps in (0.05, 0.01):
    for lam in (1.5, 2.0, 4.0):
        raw = lam * (10 + log2(2 / eps)) * log(2) / (2 * min(1, lam - 1) * g)
        print(f"  eps = {eps}, lambda = {lam}: raw = {raw:.3f}, ceiling = {ceil(raw)}, rounded = {round(raw)}")

# (B) Theorem A(d) against kink Cor 5.5 at k6's per-query instance (l0 = 19), guarantee 0.90  [synthesis §2.3, §7.1]
#     gamma_L = 2.6517e-4 for every cap L >= 22 (fc2 checks this over k6's whole class).
print("(B) Theorem A(d) (iid Thm 4.1(iv), eps = 0.1) against kink Cor 5.5 (eps = 0.05) at l0 = 19")
gL = 2.6517e-4
for lam in (1.5, 2, 4, 8):
    L = ceil((lam * 19 + log2(2 / 0.1)) / (lam - 1))
    n_iid = ceil(lam * (19 + log2(2 / 0.1)) * log(2) / (2 * min(1, lam - 1) * gL))
    lbar = 19 + (19 + log2(1 / 0.05)) / (lam - 1)
    n_k = log(2) * (max(0, 2 - lam) * lbar + lam * 19 + 2 * log2(1 / 0.05)) / (2 * gL)
    print(f"  lambda = {lam}: iid L_eps = {L}, n = {n_iid:.4g}; kink lbar = {lbar:.1f}, n0 = {n_k:.4g}; "
          f"ratio = {n_iid / n_k:.3f}")

# (C) iid Prop 5.1: lambda = 1 recovery times and the proved bracket (eps = 0.01, k even)  [synthesis §2.1]
print("(C) iid Prop 5.1 at eps = 0.01")
for k in (16, 24, 32, 40):
    lo = 2 ** ((k - 8) // 2) - 6
    hi = max(32, ceil(2 ** ((k + 1) / 2) / sqrt(0.01)))
    v = 2 ** ((k + 4) // 2) + 6
    print(f"  k = {k}: 2^((k+4)/2)+6 = {v}; bracket ({lo}, {hi}]; inside = {lo < v <= hi}")

# (D) iid Remark 4.5: n = lambda(k-2)/(lambda-1) and the parity length (lambda k - 2)/(lambda - 1)  [synthesis §2.1]
print("(D) iid Remark 4.5, exact arithmetic")
for k, lam in [(20, Fraction(2)), (20, Fraction(3, 2)), (30, Fraction(3)), (16, Fraction(5, 4)), (40, Fraction(2))]:
    print(f"  (k, lambda) = ({k}, {lam}): n = {lam * (k - 2) / (lam - 1)}, parity length = {(lam * k - 2) / (lam - 1)}")

# (E) small constants quoted in the synthesis
print("(E) constants")
print(f"  iid Prop 7.6(d): 1 - (63/64)^10 = {1 - (63 / 64) ** 10:.4f}")
print(f"  iid Cor 6.1(vi): (7/8)^64 = {(7 / 8) ** 64:.3e}")
for lam in (1.5, 2):
    w = 2 ** (-5 * lam) / (2 ** (-5 * lam) + 2 ** (-7 * lam))
    print(f"  iid Thm 3.2 refutation, lengths 5 and 7: w_lambda({lam}) = {w:.4f}")
print(f"  teacher §5: -log(5/8 - 1/16) = {-log2(5 / 8 - 1 / 16):.3f} against H(1/4) = {H(0.25):.3f}")

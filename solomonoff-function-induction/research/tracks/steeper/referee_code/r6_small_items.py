"""Referee check r6: small items, independent code. Deterministic.

(a) Lemma 1.2(iii) wording: the end vertices of a lower hull are unique minimisers on open
    c-intervals although one of their incident hull edges is vertical (slope -inf) or horizontal
    (slope 0).
(b) Prop 2.13 (guard erosion) numbers recomputed from the notes' formulas.
(c) Floating-point ceil in checks/c3: ceil(log2 C(2^m, 1)) via lgamma vs exact (affects k_b
    and the Prop 2.11 rates for single-prefix error rules).
(d) Prop 2.8 example as printed in the notes (2^-776) vs J_g = c(d+kappa_g)+H(p) (kappa = 0).
"""
from math import log2, lgamma, log, ceil, comb


def H(q):
    return 0.0 if q in (0, 1) else -(q * log2(q) + (1 - q) * log2(1 - q))


print("(a) A = {(0,1), (10,0.5), (20,0)}: unique minimiser of c*l + R by c")
A = [(0, 1.0), (10, 0.5), (20, 0.0)]
for c in [0.2, 0.06, 0.05, 0.04, 0.001]:
    vals = [c * l + R for (l, R) in A]
    mn = min(vals)
    arg = [A[i] for i, v in enumerate(vals) if abs(v - mn) < 1e-12]
    print(f"  c={c}: minimisers {arg}")
print("  -> (0,1) is the unique minimiser on (0.05, inf) and (20,0) on (0, 0.05); (10,0.5) never is.")

print("(b) guard erosion")
M, eta = 64, 0.05
ph = 1 - eta + eta / M

Hteach = -(ph * log2(ph) + (M - 1) * (eta / M) * log2(eta / M))
gain = log2(M) - Hteach
DG = log2(M / eta) - log2(M - 1)
for (piG, pinG, ks, kG) in [(0.05, 5e-4, 22, 12), (0.002, 0.002, 22, 12)]:
    rs = (piG * gain - pinG * log2(1 / eta)) / ks
    rG = pinG * DG / kG
    if rG < rs:
        print(f"  piG={piG}, pinG={pinG}: unguarded selected on ({rG:.3e}, {rs:.3e})")
    else:
        cswitch = (ks * rs + kG * rG) / (ks + kG)
        print(f"  piG={piG}, pinG={pinG}: guarded -> none at c = {cswitch:.3e}")

print("(c) ceil of a float log-binomial")
for m in [3, 6, 7, 8]:
    LS_lg = (lgamma(2 ** m + 1) - lgamma(2) - lgamma(2 ** m)) / log(2)
    print(f"  m={m}: lgamma L_S = {LS_lg!r}, ceil = {ceil(LS_lg)}; exact log2 C(2^m,1) = {log2(comb(2 ** m, 1))}, "
          f"ceil = {ceil(log2(comb(2 ** m, 1)))}")

print("(d) Prop 2.8 example: c=1e-4, eta=1e-3, N=1e6")
d, r, c, etaa, N = 100, 10, 1e-4, 1e-3, 10 ** 6
kg = 2 * log2(d) + 2 * log2(r)
Jg = c * (d + kg) + H(2.0 ** -10)
print(f"  J_g (notes' formula, kappa=0) = {Jg:.4f}; exponent = {-N * etaa + (Jg + etaa) / c:.1f}; "
      f"c5 used J = 0.0214 -> {-N * etaa + (0.0214 + etaa) / c:.1f}")

"""c1: Hanni's own numbers for the teacher's-mistakes trick (both versions in the 'messy notes'
of prior/hanni-grokking-a-notion.md), recomputed.

Version 1 ('simple model of 100 bits which predicts 100 bits per specification bit, systematic
error model of 100 bits which predict 10 bits per specification bit'): total-bit units.
Version 2 ('simple model 100 bits; systematic error on a 2^-10 fraction of inputs taking 10000
bits to specify'): per-sample units, c = lambda/N.

For each version we list the three hypotheses he names, the lower convex hull, and the window
of lambda (or c) in which 'simple model + noise' is the unique minimiser of
lambda*(description length) + (negative log-likelihood).  Deterministic; no randomness.
"""
from math import log2

def H(p):
    return 0.0 if p in (0.0, 1.0) else -(p * log2(p) + (1 - p) * log2(1 - p))

print("=" * 78)
print("Version 1 (total bits; data fixed).")
# simple model: 100 bits, saves 100*100 = 10^4 bits of likelihood loss;
# error model: 100 more bits, saves 100*10 = 10^3 bits.
base = 20000.0  # an arbitrary baseline loss of the 'coin'; only differences matter
hyps1 = {"coin": (0, base), "simple": (100, base - 1e4), "simple+errors": (200, base - 1e4 - 1e3)}
for lam in [0.5, 1, 5, 9.99, 10.01, 50, 99.99, 100.01, 200]:
    best = min(hyps1, key=lambda h: lam * hyps1[h][0] + hyps1[h][1])
    print(f"  lambda={lam:7.2f}: selected {best}")
print("  => 'simple' alone is selected exactly for lambda in (10, 100); lambda=1 selects simple+errors.")

print("=" * 78)
print("Version 2 (per sample; c = lambda/N).")
p = 2.0 ** -10
print(f"  H(2^-10) = {H(p):.6f} bits/sample;  p*log2(1/p) = {p*log2(1/p):.6f}  "
      f"(Hanni writes '~ p log2(1/p) ~ 1/100'; the exact entropy is 14% larger)")
for k_flip in [0, 10]:
    K_f, K_E = 100, 10000
    hyps = {"coin": (0.0, 1.0), "good": (K_f + k_flip, H(p)), "bad": (K_f + K_E, 0.0)}
    r_model = (1 - H(p)) / (K_f + k_flip)        # slope coin -> good
    r_err = H(p) / (K_E - k_flip)                # slope good -> bad
    print(f"  [flip-rate cost {k_flip} bits] rate(model) = {r_model:.4e}, rate(error) = {r_err:.4e}; "
          f"window c in ({r_err:.4e}, {r_model:.4e}), ratio {r_model/r_err:.0f}")
    for N in [10**5, 10**6, 10**7, 10**9]:
        lo, hi = r_err * N, r_model * N
        lam1 = min(hyps, key=lambda h: (1.0 / N) * hyps[h][0] + hyps[h][1])
        print(f"     N={N:>10}: lambda-window ({lo:.4g}, {hi:.4g}); lambda=1 selects '{lam1}'")
    print(f"     lambda=1 switches from good to bad at N = {(K_E - k_flip) / H(p):.4g}")

print("=" * 78)
print("Rigorous instances used in notes Thm 3 (parity simple model, random junta error set):")
from math import comb, lgamma, log
def log2binom(n, k):
    return (lgamma(n + 1) - lgamma(k + 1) - lgamma(n - k + 1)) / log(2)
for d, m in [(20, 20), (100, 20), (100, 24)]:
    s0 = int(p * 2 ** m)
    LS = log2binom(2 ** m, s0)
    print(f"  d={d:3d}, m={m}: |S| = {s0}, L_S = log2 C(2^m,|S|) = {LS:.1f} bits; 2^m H(p) = {2**m*H(p):.1f}; "
          f"error rate ~ H(p)/L_S = {H(p)/LS:.3e} (vs 2^-m = {2.0**-m:.3e}); model rate ~ (1-H)/d = {(1-H(p))/d:.3e}")

"""Check 1: the user's worked example (100-bit simple model, 10000-bit systematic error
on a 2^-10 fraction of inputs).  Computes the per-sample objective
    J_c(h) = c*K(h) + R(h)          (c = lambda / N)
for the hypotheses the user lists, the window of c in which the 'good model' wins,
and the corresponding lambda windows for several N.  Also the hull slopes."""
from math import log2

def H(p):
    return 0.0 if p in (0, 1) else -(p * log2(p) + (1 - p) * log2(1 - p))

p = 2 ** -10
K_f, K_E, K_flip = 100, 10000, 10      # K_flip: bits to specify the flip rate (generous)
hyps = {
    "coin (50/50)":      (0.0,               1.0),
    "good (f + flips)":  (K_f + K_flip,      H(p)),
    "bad (f + errors)":  (K_f + K_E,         0.0),
}
print(f"H(p) for p=2^-10: {H(p):.6f} bits/sample  (user: 'about 1/100')")
for name, (k, r) in hyps.items():
    print(f"  {name:20s} K={k:7.0f}  R={r:.6f}")

# hull slopes (rates): coin->good and good->bad
s1 = (1.0 - H(p)) / (K_f + K_flip)          # risk reduction per bit of the simple model
s2 = H(p) / (K_E - K_flip)                  # risk reduction per bit of the error component
print(f"rate of simple model  (coin->good): {s1:.4e} bits/sample per bit")
print(f"rate of error component (good->bad): {s2:.4e} bits/sample per bit")
print(f"=> good model selected iff {s2:.3e} < c < {s1:.3e}  (ratio {s1/s2:.0f}x)")

def selected(c):
    return min(hyps, key=lambda n: c * hyps[n][0] + hyps[n][1])

for c in [1e-1, 1e-2, 9e-3, 1e-3, 1e-5, 1e-6, 1e-7]:
    print(f"  c={c:.0e}: selected = {selected(c)}")

for N in [10**3, 10**5, 10**6, 10**7, 10**9]:
    lo, hi = s2 * N, s1 * N
    std = "good" if lo < 1 < hi else ("bad" if 1 <= lo else "coin")
    print(f"  N={N:>10}: lambda window ({lo:.3g}, {hi:.3g});  standard MDL (lambda=1) picks: {std}")
print("standard MDL switches to the error-memorising model at N =", round(1 / s2))

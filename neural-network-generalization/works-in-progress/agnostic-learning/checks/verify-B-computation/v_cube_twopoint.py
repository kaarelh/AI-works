"""Checks of B.md Section 7 (noisy cube) and Section 9 (two-point law) constants.
(a) Lemma 7.1(d): E S_1 = M(1-1/M)^{M-1} >= M/e, McDiarmid tail Pr(S_1 < M/e - M^{2/3}) <= exp(-M^{1/3}/2) (simulation).
(b) Thm 7.4(b): eps_n and the excess lower bound (sqrt(1/e - n^{-1/3}) - sqrt(eps_n))_+^2 as n = 2^d grows.
(c) Prop 9.1(b): t_H >= (2/3) tilde t_H, omega <= v <= 1.5 omega, clone energy <= (H+9/4) delta0^{-2/L}; converse
    energy >= L delta0^{-2/L} (from Lemma 2.1(b)); (c) eta = 1/2 at the stated delta0.
(d) Lemma 9.2: width-m chain with weights <= B fits D_{delta0} at delta0 = (tanh 1)^{-H}/(m^H B^L)."""
import math
import numpy as np
rng = np.random.default_rng(7)

print("(a) Lemma 7.1(d)")
for d in [6, 8, 10, 12, 14]:
    M = 2 ** d
    ES1 = M * (1 - 1 / M) ** (M - 1)
    sims = []
    for _ in range(400):
        k = np.bincount(rng.integers(0, M, M), minlength=M)
        sims.append(np.sum(k == 1))
    sims = np.array(sims)
    thr = M / math.e - M ** (2 / 3)
    print(f"   d={d:2d}: E S1/M = {ES1/M:.5f} >= 1/e = {1/math.e:.5f};  sim mean/M = {sims.mean()/M:.5f};"
          f"  empirical Pr(S1 < M/e - M^(2/3)) = {np.mean(sims < thr):.3f} <= bound {math.exp(-M**(1/3)/2):.2e};"
          f" sd(S1)/sqrt(M) = {sims.std()/math.sqrt(M):.3f}")

print("(b) Thm 7.4(b): eps_n and excess lower bound, n = 2^d, t = n^{-theta/2}")
import mpmath as mp
def eps_n(d, H, th):
    n = mp.mpf(2) ** d
    beta = max(mp.mpf(1), mp.log(2 * (d + 1) * n ** ((1 + th) / 2)) / 2)
    R2 = max(mp.mpf(2), mp.mpf('2.25') * n ** (th / 2), ((d + 1) ** 2 * n) ** (mp.mpf(1) / H))
    return n ** (-th) * (beta ** 2 * d ** 3 + (H + 1) * R2 + 1) + 9 * n ** (-th), beta, R2
for H, th in [(2, 0.55), (2, 0.75), (3, 0.4), (3, 0.6)]:
    row = []
    for d in [50, 100, 200, 400, 800, 1600]:
        e, beta, R2 = eps_n(d, H, th)
        n = mp.mpf(2) ** d
        q = 1 / mp.e - n ** (-mp.mpf(1) / 3)
        exc = float(max(mp.mpf(0), mp.sqrt(q) - mp.sqrt(e)) ** 2); e = float(e)
        row.append(f"d={d}: eps={e:.3g}, exc>={exc:.3f}")
    print(f"   H={H} theta={th}: " + "; ".join(row))
# requirement t = n^{-theta/2} <= 1/4  <=>  n >= 16^{1/theta}
print("   t<=1/4 <=> n>=16^(1/theta): e.g. theta=0.55 -> n >= ", f"{16**(1/0.55):.1f}")

print("(c) Prop 9.1(b),(c)")
worst = dict(tH=1e9, vlo=1e9, vhi=0, en=0)
for L in range(2, 9):
    H = L - 1
    for delta0 in np.logspace(-12, math.log10(2 ** (-L / 2)), 60):   # omega^2 >= 2  <=>  delta0 <= 2^{-L/2}
        om = delta0 ** (-1 / L)
        t = delta0
        for _ in range(H): t = math.tanh(om * t)
        tH_tilde = om ** (H - L)
        v = 1 / t
        worst['tH'] = min(worst['tH'], t / tH_tilde)
        worst['vlo'] = min(worst['vlo'], v / om); worst['vhi'] = max(worst['vhi'], v / om)
        worst['en'] = max(worst['en'], (H * om ** 2 + v ** 2) / ((H + 2.25) * delta0 ** (-2 / L)))
print(f"   min t_H/tilde t_H = {worst['tH']:.4f} (>= 2/3);  v/omega in [{worst['vlo']:.4f}, {worst['vhi']:.4f}] (in [1,1.5]);"
      f"  max clone energy/((H+9/4) delta0^(-2/L)) = {worst['en']:.4f} (<=1)")
for L in [2, 3, 4]:
    for nth in [2 * L, 10, 1e3, 1e6]:
        K = nth + 1
        delta0 = 0.5 * (L / K) ** (L / 2)
        eta = delta0 * (K / L) ** (L / 2)
        om2 = delta0 ** (-2 / L)
        print(f"   L={L} n^theta={nth:g}: eta={eta:.3f}, omega^2={om2:.3f}(>=2), omega/(n^theta+1)^0.5={math.sqrt(om2/K):.3f}(<=1),"
              f" energy bound (1+5/(4L))4^(1/L)(n^theta+1)={(1+5/(4*L))*4**(1/L)*K:.2f} vs (H+9/4)omega^2={(L-1+2.25)*om2:.2f}")

print("(d) Lemma 9.2")
bad = 0; cnt = 0
for _ in range(3000):
    L = int(rng.integers(2, 7)); H = L - 1; m = int(rng.integers(1, 20)); B = 10 ** rng.uniform(-1, 2)
    if m * B < math.tanh(1) ** (-H): continue
    delta0 = math.tanh(1) ** (-H) / (m ** H * B ** L)
    if delta0 > 1: continue
    t = math.tanh(B * delta0)
    for _ in range(H - 1): t = math.tanh(m * B * t)
    v = 1 / (m * t)
    cnt += 1
    if v > B * (1 + 1e-12): bad += 1
print(f"   {cnt} admissible random (L,m,B): readout v <= B violated {bad} times")

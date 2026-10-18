"""Numerical checks for the revision of drafts/T3-prior.md (response to the referee report).

Sections (numbering follows the revision notes of T3):
  R1. T3.5 with grader-modelling overhead on both slices: exact break-even gap, drift at g = 2.
  R2. T3.4(3') Occam bound: expected posterior deviation rate of rivals that deviate on a
      predicate sigma of training measure rho is at most O_riv * max_rho rho (1-rho)^n
      <= O_riv / (e n).  Monte Carlo over random rival populations; schemer contrast.
  R3. T3.9 combined with T3.3 and T3.13: the ambiguity a prior can tolerate, the data-mix ratio
      the self-written-data fixed point needs, and the per-task (mixture) bit requirement.
  R4. T3.13: both saturation conditions; the eta = 0.001 counterexample; how small the absolute
      share of grading material must be when a human anchor corpus is kept.
  R5. Tice et al. (2026) calibration of P2: log-odds moved by alignment upsampling, and the
      share ratio phi / w that P2 would need to reproduce it.
  R6. Honesty on frontier questions: bits needed per question under the per-question reading.
"""
import numpy as np

LN2 = np.log(2.0)
rng = np.random.default_rng(7)


def hdr(s):
    print("\n" + "=" * 72 + "\n" + s + "\n" + "=" * 72)


# ---------------------------------------------------------------- R1
hdr("R1. Speed drift toward G with overhead on both slices (T3.5 revised)")
kappa, alpha, ck, o = 0.01, 1.0, 10.0, 0.01
u = np.log2(1 + o) / alpha
g0_both = u + np.sqrt(u * u + 2 * ck * u)              # exact, c_k fixed
g0_sound_only = np.sqrt(2 * ck * np.log2(1 + o) / alpha)  # original draft (exact with c_k fixed)
print(f"u = log2(1+o)/alpha = {u:.5f}")
print(f"break-even gap, overhead on both slices (c_k fixed): g0 = {g0_both:.4f}")
print(f"break-even gap, overhead on sound slice only (draft): g0 = {g0_sound_only:.4f}")
for g in (0.5, 1.0, 2.0, 4.0):
    c1 = ck + g
    D = kappa * (alpha * g * g / (2 * c1) - np.log2(1 + o))
    print(f"g={g:3.1f}: D_spd(G) = {D:+.3e} nats/episode (both slices)")
# Monte Carlo of the revised drift at g = 2
g = 2.0
d = rng.uniform(0, ck + g, 2_000_000)
logratio = np.where(d <= ck, -np.log2(1 + o), alpha * (d - ck) - np.log2(1 + o))
print(f"MC check at g=2: {kappa * logratio.mean():+.3e} nats/episode")

# ---------------------------------------------------------------- R2
hdr("R2. Occam bound for deviation predicates (T3.4(3') revised)")
# Rivals: A everywhere except on a predicate sigma, where they do something else.
# A deviation on a training episode is caught (the rival fails the proxy there).
# Posterior deviation rate on a fresh input from the SAME distribution as training:
#   r_n = sum_s w_s 1[sample avoids s] rho_s / (w_A + sum_s w_s 1[avoids s]).
# Bound: E r_n <= O_riv * max_rho rho (1-rho)^n <= O_riv / (e n), O_riv = sum_s w_s / w_A.
O_riv_bits = 13.7
O_riv = 2.0 ** O_riv_bits
S = 20000
for n in (1e3, 1e5, 1e7, 1e9):
    vals = []
    for trial in range(200):
        rho = 10.0 ** rng.uniform(-12, 0, S)
        w = rng.exponential(1.0, S)
        w = w / w.sum() * O_riv            # rivals' total prior odds against A = 2^13.7
        surv = rng.random(S) < np.exp(n * np.log1p(-np.minimum(rho, 1 - 1e-16)))
        r = (w[surv] * rho[surv]).sum() / (1.0 + w[surv].sum())
        vals.append(r)
    nn = int(n)
    exact_max = (1 / (nn + 1)) * (nn / (nn + 1)) ** nn
    print(f"n={n:.0e}: MC mean posterior deviation rate {np.mean(vals):.3e};"
          f"  bound O*max rho(1-rho)^n = {O_riv * exact_max:.3e};  O/(e n) = {O_riv / (np.e * n):.3e}")
# Tightness: one rival class with prior odds O = 1/16 against A, all at the worst breadth rho = 1/(n+1)
for n in (1e3, 1e5):
    nn = int(n); rho = 1.0 / (nn + 1); O = 1.0 / 16
    surv = (1 - rho) ** nn
    r_exact = O * surv * rho / (1 + O * surv)       # deterministic once survival is averaged in odds
    print(f"tightness, O=1/16, rho=1/(n+1), n={n:.0e}: E-odds-weighted rate {r_exact:.3e};"
          f" bound O/(e n) = {O / (np.e * n):.3e}")
print("schemer contrast: sigma_C has training measure 0, so no attenuation; frontier deviation rate"
      f" = posterior mass of C = 2^{O_riv_bits}/(1+2^{O_riv_bits}) = {O_riv / (1 + O_riv):.5f}")
# Careful gamer: training measure of sigma = rate of unrecognised audits a(1-s) on the frontier share
for a, s in ((0.01, 0.9), (0.05, 0.5)):
    rho_c = a * (1 - s)
    for n in (1e4, 1e6):
        print(f"audits a={a}, recognition s={s}: training measure {rho_c:.4f};"
              f" survival (1-rho)^n at n={n:.0e} = {np.exp(n * np.log1p(-rho_c)):.3e}")

# ---------------------------------------------------------------- R3
hdr("R3. T3.9 combined with T3.3 (near-misses) and T3.13 (fixed point); per-task reading")
for K, delta in ((10, 0.01), (30, 0.01), (100, 1e-3)):
    need = np.log2(K / delta)
    amb_max = np.log2(1 + delta / K)
    print(f"K={K:3d}, delta={delta}: need {need:5.1f} bits per generation;"
          f" tolerable amb <= log2(1+delta/K) = {amb_max:.2e} bits"
          f" (= off-tolerance conditional mass <= {delta / K:.1e});"
          f" nu_I/nu_R >= K/delta = {K / delta:,.0f}")
for amb in (0.0, 0.5, 1.0):
    print(f"with amb={amb}: fixed point needs nu_I/nu_R >= 2^amb K/delta = {2**amb * 30 / 0.01:,.0f} (K=30, delta=1%)")
for Ntask in (1e4, 1e6, 1e8):
    print(f"mixture reading, K=30, delta=1%, {Ntask:.0e} frontier tasks per generation:"
          f" need log2(K N/delta) = {np.log2(30 * Ntask / 0.01):.1f} bits")
print(f"mixture reading, amb = 1 bit: per-task near-miss rate 1 - 2^-amb = {1 - 2**-1:.2f}")

# ---------------------------------------------------------------- R4
hdr("R4. Self-written-data fixed point: both saturation conditions (T3.13 revised)")


def dK(eta, lI0, lR0, nuI, nuR, amb=0.0):
    lI = -np.log2((1 - eta) * 2.0 ** -lI0 + eta * nuI)
    lR = -np.log2((1 - eta) * 2.0 ** -lR0 + eta * nuR)
    return lR - lI - amb


for eta in (0.001, 0.01, 0.05, 0.1):
    print(f"l_base(I)=12, l_base(R)=40, nu_I=0.02, nu_R=0.05, eta={eta}:"
          f" dK = {dK(eta, 12, 40, 0.02, 0.05):+.2f} bits (fixed point {np.log2(0.02 / 0.05):+.2f});"
          f" eta*nu_I / 2^-l_base(I) = {eta * 0.02 / 2**-12:.2f}")
# Required absolute share of grading material for dK >= 11.6 bits (K=30, delta=1%), amb = 0
target = np.log2(30 / 0.01)
for eta, nuI in ((0.5, 0.02), (0.5, 0.2), (0.9, 0.2)):
    num = (1 - eta) * 2.0 ** -12 + eta * nuI
    max_share_R = num / 2 ** target - (1 - eta) * 2.0 ** -40
    print(f"eta={eta}, nu_I={nuI}: need eta*nu_R <= {max_share_R:.2e}"
          f" (nu_R <= {max_share_R / eta:.2e}) for dK >= {target:.1f} bits")

# ---------------------------------------------------------------- R5
hdr("R5. Calibrating P2 against Tice et al. (2026)")


def logit2(p):
    return np.log2(p / (1 - p))


pre = logit2(0.45) - logit2(0.09)
post = logit2(0.46) - logit2(0.35)
print(f"alignment upsampling, before post-training: 45% -> 9% misaligned: {pre:.2f} bits ({pre * LN2:.2f} nats)")
print(f"after post-training: 46% -> 35%: {post:.2f} bits ({post * LN2:.2f} nats)")
print(f"P2 reproduces {pre:.2f} bits iff log2(1+phi/w) = {pre:.2f}, i.e. phi/w = {2**pre - 1:.1f}")
print(f"P2 reproduces {post:.2f} bits iff phi/w = {2**post - 1:.2f}")
for lw, phi in ((30, 1e-4), (30, 1e-2), (10, 1e-3), (7, 1e-2)):
    print(f"P2 with l_before={lw}, phi={phi:.0e}: gain {np.log2(1 + phi / 2.0**-lw):.2f} bits")

# ---------------------------------------------------------------- R6
hdr("R6. Honesty on frontier questions (per-question reading)")
for K, Nq, delta in ((30, 1e4, 0.01), (30, 1e6, 0.01), (30, 1e8, 0.01)):
    print(f"K={K}, {Nq:.0e} frontier questions per generation, delta={delta}:"
          f" honest reporter needs {np.log2(K * Nq / delta):.1f} bits over the overseer simulator")

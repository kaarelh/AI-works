"""Numerical checks and worked numbers for drafts/T3-prior.md.

Sections:
  1. Ledger crossing times n* = dK ln2 / D for dK = 10, 100, 1000 bits.
  2. Counting versus simplicity: a block (Elias-like) slot prior; the class mass of
     scheming goals saturates while the naive count grows without bound.
  3. Speed: drift toward G from a log-time penalty on a frontier slice; break-even gap;
     drift against careful gamers from detection overhead; compile trade-off.
  4. Prior shaping: pointer-length gain log2(1 + phi/w) from a corpus share phi.
  5. Inheritance: salience recursion l_{k+1} = -log2((1-eta) 2^-l_base + eta nu)
     and its fixed point dK_inf = log2(nu_I / nu_R).
  6. Union bound for re-issued priors on zero-drift classes.
  2b. Monte Carlo check of the Kraft cap: random prefix-free slot priors never give a
     class more than 2^{l(I)} times A's mass.
"""
import numpy as np

LN2 = np.log(2.0)
rng = np.random.default_rng(3)


def hdr(s):
    print("\n" + "=" * 70 + "\n" + s + "\n" + "=" * 70)


# ---------------------------------------------------------------- 1
hdr("1. Crossing times n* = dK ln2 / D")
Lam = np.log(0.99 / 0.01)
cases = {
    "(B) delta=0.01, eps=0.01, no audits": 0.01 * Lam,
    "(D) lambda+=0.05, eps=0.01, no audits": 0.01 * 0.05,
    "near-balanced audits, D=1e-5": 1e-5,
}
for name, D in cases.items():
    row = [f"{dk * LN2 / D:,.0f}" for dk in (10, 100, 1000)]
    print(f"{name:42s} D={D:.3g} nats/ep  n*: " + "  ".join(row))
for dk in (10, 100, 1000):
    print(f"dK={dk:5d} bits -> L0 = {dk * LN2:.2f} nats, odds = 2^{dk}")
n, D = 1e6, 5e-4
print(f"bits consumed per generation at n={n:.0e}, D={D}: {n * D / LN2:.0f} bits")
for cap in (20, 40):
    print(f"max D sustainable per generation with cap {cap} bits, n=1e6: "
          f"{cap * LN2 / n:.2e} nats/episode")

# ---------------------------------------------------------------- 2
hdr("2. Counting versus simplicity: block slot prior")
# Block j (j = 0,1,2,...) has 2^j goals and total mass p_j = 1/((j+1)(j+2)).
# Each goal in block j has code length l = j + log2((j+1)(j+2)).


def l_block(j):
    return j + np.log2((j + 1) * (j + 2))


jI = 10
lI = l_block(jI)
print(f"intent pointer in block {jI}: l(I) = {lI:.2f} bits")
for f in (0.1, 1e-3):
    print(f"-- fraction f = {f} of goal mass is scheming-compatible (inert slot)")
    for m in (10, 20, 30, 40, 60):
        mass_Q = f * sum(1 / ((j + 1) * (j + 2)) for j in range(m + 1))
        naive = np.log2(f * (2 ** (m + 1) - 1))
        univ = np.log2(mass_Q) + lI
        print(f"   goals up to block {m:2d}: naive log2 count = {naive:6.1f} bits;"
              f"  log2 mu(C)/mu(A) = {univ:6.2f} bits  (cap l(I)+log2 f = {lI + np.log2(f):.2f})")
# persona reading
for f, lI2 in ((1e-3, 3.0), (1e-2, 3.0), (0.1, 8.0)):
    print(f"persona reading f={f}, l(I)={lI2}: log2 odds A:C = {np.log2(1 / f) - lI2:.2f} bits")

# exact Kraft check with a random finite prefix-free code
hdr("2b. Kraft cap, Monte Carlo over random slot priors")
worst = -np.inf
for trial in range(2000):
    N = rng.integers(50, 2000)
    lengths = rng.integers(1, 40, size=N).astype(float)
    w = 2.0 ** (-lengths)
    w = w / max(1.0, w.sum())  # enforce Kraft sum <= 1
    iI = rng.integers(N)
    Q = rng.random(N) < rng.random()
    Q[iI] = False
    ratio = np.log2(w[Q].sum() + 1e-300) - np.log2(w[iI])
    cap = -np.log2(w[iI])
    worst = max(worst, ratio - cap)
print(f"max over trials of [log2 mu(Q)/mu(I) - l(I)] = {worst:.3f} (must be <= 0)")

# ---------------------------------------------------------------- 3
hdr("3. Speed")
# Difficulty d ~ U[0, c1], grader sound up to c0 = c1 - g; t_A = 2^(alpha d),
# t_fool = 2^(alpha c0) on d > c0.  Log-time penalty kappa nats per bit of log2 t.
kappa, alpha = 0.01, 1.0


def speed_drift_G(c0, g, overhead):
    c1 = c0 + g
    gain_bits = alpha * g ** 2 / (2 * c1)           # E[(d-c0)^+] * alpha
    over_bits = (c0 / c1) * np.log2(1 + overhead)  # grader-modelling overhead on sound slice
    return kappa * (gain_bits - over_bits), gain_bits, over_bits


# Monte Carlo check of E[(d-c0)^+]
c0, g = 10.0, 2.0
d = rng.uniform(0, c0 + g, 2_000_000)
print(f"E[(d-c0)^+]: closed form {g**2/(2*(c0+g)):.5f}, MC {np.maximum(d-c0,0).mean():.5f}")
for gg in (0.1, 0.5, 1.0, 2.0, 4.0):
    Dg, gb, ob = speed_drift_G(c0, gg, 0.01)
    print(f"g={gg:4.1f}: bits saved/ep {gb:.4f}, overhead bits/ep {ob:.4f}, "
          f"D_spd(G) = {Dg:+.2e} nats/ep")
# break-even gap: alpha g^2/(2(c0+g)) = (c0/(c0+g)) log2(1+o)  =>  g^2 = 2 c0 log2(1+o)/alpha
for o in (0.01, 0.1):
    print(f"overhead {o}: break-even gap g = {np.sqrt(2 * c0 * np.log2(1 + o) / alpha):.3f}")
for o in (1e-2, 1e-4):
    Dc = -kappa * np.log2(1 + o)
    print(f"careful gamer, relative detection overhead {o}: D_spd(C) = {Dc:.2e} nats/ep;"
          f" episodes per nat = {1 / abs(Dc):,.0f}")
# compile trade-off: compiling the detector costs b bits, cuts overhead from o to 0
for b in (10, 30):
    o = 1e-2
    print(f"compiled detector costing {b} bits pays off after "
          f"{b * LN2 / (kappa * np.log2(1 + o)):,.0f} episodes (o={o})")

# ---------------------------------------------------------------- 4
hdr("4. Prior shaping: pointer-length gain from a corpus share phi")
for lw in (20, 30):
    w = 2.0 ** -lw
    for phi in (1e-6, 1e-4, 1e-2):
        gain = np.log2(1 + phi / w)
        print(f"l_before={lw} bits, phi={phi:.0e}: gain {gain:5.2f} bits, "
              f"l_after = {-np.log2((1 - phi) * w + phi):5.2f} bits")

# ---------------------------------------------------------------- 5
hdr("5. Inheritance: salience recursion")


def run(lI0, lR0, nuI, nuR, etas):
    out = []
    for eta in etas:
        lI = -np.log2((1 - eta) * 2.0 ** -lI0 + eta * nuI)
        lR = -np.log2((1 - eta) * 2.0 ** -lR0 + eta * nuR)
        out.append((eta, lI, lR, lR - lI))
    return out


etas = np.linspace(0.0, 0.9, 10)
for nuI, nuR in ((0.02, 0.05), (0.2, 0.05), (0.2, 0.005)):
    print(f"-- base l(I)=12, l(R)=40; data shares nu_I={nuI}, nu_R={nuR};"
          f" fixed point dK = log2(nu_I/nu_R) = {np.log2(nuI / nuR):+.2f} bits")
    for eta, lI, lR, dk in run(12, 40, nuI, nuR, etas):
        print(f"   eta={eta:.1f}: l(I)={lI:6.2f}  l(R)={lR:6.2f}  dK={dk:+7.2f} bits")

# ---------------------------------------------------------------- 6
hdr("6. Union bound for re-issued priors on zero-drift classes")
for K, delta in ((10, 0.01), (30, 0.01), (100, 1e-3)):
    print(f"K={K} generations, total failure <= {delta}: need dK_band >= "
          f"{np.log2(K / delta):.1f} bits per generation")

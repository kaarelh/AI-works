"""c4: the model-vs-randomness split (notes Section 3).

(A) Ville's inequality for the SFI mixture: Z_N = xi(D_N)/nu(D_N) is a nonnegative supermartingale
    under fresh nu-labels, so P[sup_N Z_N >= 2^m] <= 2^-m.  Simulated for a finite product class
    (Bernoulli samplers on dyadic grids plus deterministic hypotheses), truth nu = Bernoulli(0.3)
    per input (not in the class), N <= 3000, 4000 runs.
(B) Hashing lemma (derandomisation of a sampler by an N-wise independent family): exact
    enumeration over GF(2^4) for N = 1, 2, 3 distinct inputs: P_seed[fill-in agrees with D] = nu(D).
(C) Full truth table of a noisy parity (d = 12): product class {coin, parity+noise samplers,
    memoriser = good model + the flip set} vs shared class (the same plus U = Bayes mixture over all
    parities and noise rates, a single learning hypothesis of code length l_U = 12).  lambda-MAP in each.
Seeded: numpy default_rng(4).
"""
import itertools
from math import log2, log, lgamma, ceil, pi
import numpy as np
rng = np.random.default_rng(4)

print("=" * 78)
print("(A) Ville: P[sup_N log2(xi/nu) >= m] <= 2^-m")
grid = [(b, j) for b in range(1, 7) for j in range(1, 2**b) if j % 2 == 1]   # reduced dyadics
w = {bj: 2.0**-(bj[0] + 2*log2(bj[0]) + 2) for bj in grid}                    # Kraft-valid weights
dets = {"all0": 2.0**-4, "all1": 2.0**-4, "alt01": 2.0**-6, "alt10": 2.0**-6}
assert sum(w.values()) + sum(dets.values()) <= 1
th = np.array([j/2**b for (b, j) in grid]); wv = np.array([w[bj] for bj in grid])
runs, Nmax, truth = 4000, 3000, 0.3
sups = np.empty(runs)
for r in range(runs):
    y = (rng.uniform(size=Nmax) < truth).astype(int)
    c1 = np.cumsum(y); idx = np.arange(1, Nmax+1); c0 = idx - c1
    lognu = c1*log2(truth) + c0*log2(1-truth)
    L = c1[:, None]*np.log2(th)[None, :] + c0[:, None]*np.log2(1-th)[None, :] + np.log2(wv)[None, :]
    mx = L.max(axis=1); logxi = mx + np.log2(np.exp2(L - mx[:, None]).sum(axis=1))
    # deterministic hypotheses survive only while consistent (they are 0/1 likelihood)
    alld0 = (c1 == 0); alld1 = (c0 == 0)
    extra = np.where(alld0, dets["all0"], 0.0) + np.where(alld1, dets["all1"], 0.0)
    pat01 = np.cumprod(y == (idx - 1) % 2) > 0; pat10 = np.cumprod(y == idx % 2) > 0
    extra = extra + np.where(pat01, dets["alt01"], 0.0) + np.where(pat10, dets["alt10"], 0.0)
    with np.errstate(divide='ignore'):
        logxi = np.log2(np.exp2(logxi) + extra)
    sups[r] = max(0.0, np.max(logxi - lognu))
for m in [1, 2, 3, 4, 6]:
    print(f"  m={m}: empirical P[sup >= m] = {np.mean(sups >= m):.4f}  <= 2^-m = {2.0**-m:.4f}")

print("=" * 78)
print("(B) Hashing lemma, exact over GF(16) (modulus x^4+x+1); r = 4 random bits per input")
def gmul(a, b):
    res = 0
    for _ in range(4):
        if b & 1: res ^= a
        b >>= 1; a <<= 1
        if a & 0x10: a ^= 0x13
    return res
def peval(coef, x):
    acc = 0
    for cf in reversed(coef): acc = gmul(acc, x) ^ cf
    return acc
# a sampler on inputs x in GF(16): y = 1 iff (4 random bits as integer) < g(x), so nu(1|x) = g(x)/16
g = {x: (3*x + 5) % 17 % 17 for x in range(16)}
g = {x: min(16, v) for x, v in g.items()}
def sampler(x, bits): return 1 if bits < g[x] else 0
worst = 0.0; count = 0
for N in [1, 2, 3]:
    for xs in itertools.combinations(range(16), N):
        if len(xs) > 2 and xs[0] > 3: continue           # subsample triples for speed
        for ys in itertools.product([0, 1], repeat=N):
            nuD = np.prod([g[x]/16 if y else 1 - g[x]/16 for x, y in zip(xs, ys)])
            agree = 0
            for coef in itertools.product(range(16), repeat=N):
                if all(sampler(x, peval(coef, x)) == y for x, y in zip(xs, ys)): agree += 1
            frac = agree/16**N
            worst = max(worst, abs(frac - nuD)); count += 1
print(f"  {count} (domain, labelling) pairs checked; max |P_seed[agree] - nu(D)| = {worst:.2e}")

print("=" * 78)
print("(C) full truth table of a noisy parity (d=12, n=4096, flips i.i.d. p=1/8): product vs shared class")
from math import comb
d = 12; n = 2**d; p = 1/8
X = np.arange(n)
popc = np.array([bin(v).count("1") for v in range(n)])
a = int(rng.integers(0, n)); fa = popc[X & a] % 2
flips = (rng.uniform(size=n) < p).astype(int); y = fa ^ flips; F = int(flips.sum())
qs = [k/16 for k in range(1, 16)]                          # noise grid, 4 bits
def nll(agree, q): return -(agree*log2(1-q) + (n-agree)*log2(q))
# agreements of every parity a' with the labels
agree_all = np.array([int(np.sum((popc[X & ap] % 2) == y)) for ap in range(n)])
kg = d + 2*log2(d) + 4 + 1                                 # sampler nu_{a,q}: a, q, flag
Jlik_good = min(nll(agree_all[a], q) for q in qs)
q_hat = min(qs, key=lambda q: nll(agree_all[a], q))
# memoriser (deterministic): good model + the flip set as a subset of X
l_mem = d + 2*log2(d) + 2*log2(F+1) + log2(comb(n, F)) + 1
# shared class mixture U over (a', q) with uniform weights 2^-d * 2^-4 (a learning hypothesis)
L = np.array([[-nll(agree_all[ap], q) for q in qs] for ap in range(n)]) - d - 4
mx = L.max(); logU = mx + log2(np.exp2(L - mx).sum())
lU = 12.0
print(f"  flips F={F}; -log2 nu_(a,qhat)(D) = {Jlik_good:.1f} (qhat={q_hat}); log2 C(n,F) = {log2(comb(n, F)):.1f}; "
      f"-log2 U(D) = {-logU:.1f}")
for lam in [1.0, 1.1, 1.5, 2.0, 3.0, 6.0]:
    J = {"coin": lam*2 + n, "sampler (parity+noise)": lam*kg + Jlik_good, "memoriser (fill-in)": lam*l_mem,
         "U (shared mixture)": lam*lU - logU}
    prod = min([k for k in J if k != "U (shared mixture)"], key=J.get); shar = min(J, key=J.get)
    print(f"  lambda={lam:4}: product-class MAP = {prod:24s} shared-class MAP = {shar:20s} "
          f"[J(memo)-J(sampler) = {J['memoriser (fill-in)'] - J['sampler (parity+noise)']:.1f}, "
          f"J(U)-J(sampler) = {J['U (shared mixture)'] - J['sampler (parity+noise)']:.1f}]")
print(f"  J(U)-J(sampler) = lambda*(lU - kg) + (-log2 U(D) + log2 nu(D)); U wins iff lambda > "
      f"{(-logU - Jlik_good)/(kg - lU):.3f}  (kg = {kg:.1f}, lU = {lU})")
print("  [Theorem 5 bound] log2 odds(det : sampler) <= lam*k + lam*m* - (lam-1)(-log2 nu(D)):")
for lam in [1.5, 3.0]:
    for NH in [100, 1000, 10**4]:
        print(f"    lam={lam}, k=26, m*=10, -log2 nu(D)={NH}: bound {lam*26 + lam*10 - (lam-1)*NH:.0f}")

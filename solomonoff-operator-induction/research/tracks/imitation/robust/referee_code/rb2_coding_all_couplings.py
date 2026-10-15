"""rb2 (referee B): the alien coding lemma (notes Lemma 4.4) and its consequence, the right line of slope 2^-m
(Lemma 4.5), tested in a machine-free form over EVERY coupling of a type class, against structured aliens.
Seeds: numpy default_rng(202) for (A); the dictionary family in (B) uses default_rng(203); PRG = sha256.

(A) Lemma 4.4's two steps on a latent-cause instance different from the prover's r6: W = {0,1}^4 (16 cells),
    coins B = {0,1} with rho = (3/4, 1/4), inputs x in {0..9} from a random channel mu(x|w), labels Y = {0,1,2,3},
    response h(x,b) = (g(x) + 2b) mod 4 (injective in b).  For 2000 random programs (kernels nu(y|x), a third of
    them strict sub-probabilities, a tenth with zeros): sum_b q_w(b) <= 1; the total mass of Q over ALL 2^16
    functions beta': W -> B (exact brute force for 10 programs, product formula for all); and the Jensen step
    -log2 Q(beta) <= 2^m R(pi) for a coupling of exact type rho.  Plus a search for the worst Jensen gap.

(B) The class analog of Lemma 4.5.  Feature world: x = (w, v), w uniform on 32 cells (m = 5), v uniform bit; the
    human answers y = v XOR b with a private coin b ~ Bern(1/8); in the world b = beta(w), beta of exact type
    (28, 4).  ALL C(32,4) = 35960 couplings are enumerated.  Programs that know the human's model (the map v -> y,
    'g', which costs L_G = 6 bits, shared) add an explicit prefix-coded extra part (Kraft sum of extra parts
    <= 1, checked):
      tag 000  human-type: one rate q in Q17 = {0, 1/16, ..., 1}                         extra = 3 + 5
      tag 001  T-memoriser: any T (|T| = t, gamma(t) + ceil log2 C(32,t) bits), rates q_in on T, q_out off T
      tag 010  subcube T = {w : w matches a pattern in {0,1,*}^5}                         extra = 3 + 8 + 10
      tag 011  cyclic interval [a, a + len)                                               extra = 3 + 10 + 10
      tag 100  affine subspace {w : A w = c} of codimension 1, 2 or 3                     extra = 3 + 2 + 6k + 10
      tag 101  dictionary: one of 256 fixed random 4-subsets (seed 203)                   extra = 3 + 8 + 10
      tag 110  PRG: the 4 cells with the smallest sha256(seed, w), seed of s in {4, 8, 12} bits   3 + 2 + s + 10
    each set-based alien then has a 1-bit flag: 'deterministic' (coin 1 on T, 0 off T; no further bits) or
    'rated' (two rates q_in, q_out from Q17, 5 bits each; the lengths above include these 10 bits, the
    deterministic version is 10 bits shorter than listed), and the fair coin (no model; length 3).  The human has
    length L_G + 8 = 14 and risk H(1/8).  (With L_G = 10 no coupling has a window: Prop. 4.9(d).)
    Since Q_pi(beta) = 2^{-2^m R_beta(pi)} here, sum_{beta in type class} sum_pi 2^{-extra(pi)} 2^{-2^m R_beta(pi)}
    <= Kraft <= 1, so the class deficiency D(beta) := L_beta - min_pi [extra(pi) + 2^m R_beta(pi)] has
    P_beta[D >= j] <= Kraft 2^-j for beta uniform on the type class: the machine-free form of
    'every alien that knows the model pays 2^m bits per bit of advantage per sample, up to an offset that is
    small except for a 2^-j fraction of couplings'.  We report this distribution, the largest alien rate s_+(beta)
    (advantage per extra bit relative to the human) for every beta, the human's left steepness s_-, and the
    fraction of couplings for which the window (s_+, s_-) is empty, with the families responsible.
(C) Couplings produced by the PRG with a short seed (Proposition 4.9(c)): D(beta) and the window.
"""
import hashlib
import itertools
from math import comb, log2, floor, ceil
import numpy as np

# ------------------------------------------------------------------ (A)
rng = np.random.default_rng(202)
print("(A) Lemma 4.4, latent cause: W = 16 cells, rho = (3/4, 1/4), x in {0..9}, Y = {0,1,2,3}")
NW, NX, NB = 16, 10, 2
rho = np.array([0.75, 0.25])
mu = rng.dirichlet(np.ones(NX) * 0.5, size=NW)                     # mu(x | w)
g = rng.integers(0, 4, NX)
hmap = (g[:, None] + 2 * np.arange(NB)[None, :]) % 4               # h(x, b), injective in b
types = np.array([0] * 12 + [1] * 4)
worst_sum, worst_tot, worst_j, worst_prod = 0.0, 0.0, -np.inf, 0.0
for trial in range(2000):
    nu = rng.dirichlet(np.ones(4) * rng.choice([0.2, 1.0, 4.0]), size=NX)
    if trial % 3 == 0:
        nu = nu * rng.uniform(0.3, 1.0, size=(NX, 1))
    if trial % 10 == 0:
        nu[rng.random(nu.shape) < 0.15] = 0.0                       # zeros: infinite risk allowed
    q = np.einsum("wx,xb->wb", mu, nu[np.arange(NX)[:, None], hmap])
    worst_sum = max(worst_sum, q.sum(axis=1).max())
    worst_prod = max(worst_prod, float(np.prod(q.sum(axis=1))))      # = total mass of Q over all 2^16 betas
    if trial < 10:
        tot = 0.0
        for bp in itertools.product((0, 1), repeat=NW):
            tot += np.prod(q[np.arange(NW), bp])
        worst_tot = max(worst_tot, tot)
    beta = rng.permutation(types)
    lab = hmap[:, beta].T                                            # (NW, NX)
    with np.errstate(divide="ignore"):
        R = float((mu * -np.log2(nu[np.arange(NX)[None, :], lab])).sum() / NW)
        mlogQ = float(-np.log2(q[np.arange(NW), beta]).sum())
    if np.isfinite(R):
        worst_j = max(worst_j, mlogQ - NW * R)
print(f"  max_w sum_b q_w(b) = {worst_sum:.12f} (<= 1);  max total mass of Q over all 2^16 couplings ="
      f" {worst_prod:.12f} (product formula), {worst_tot:.12f} (brute force, 10 programs)")
print(f"  max over finite-risk programs of [-log2 Q(beta) - 2^m R(pi)] = {worst_j:.4f} (<= 0)")
# adversarial search: programs concentrated near the human on some x, far elsewhere
nuH = np.zeros((NX, 4))
for x in range(NX):
    nuH[x, hmap[x]] = rho
best = -np.inf
for trial in range(3000):
    eps = rng.uniform(0, 1)
    nu = (1 - eps) * nuH + eps * rng.dirichlet(np.ones(4) * 0.3, size=NX)
    q = np.einsum("wx,xb->wb", mu, nu[np.arange(NX)[:, None], hmap])
    beta = rng.permutation(types)
    lab = hmap[:, beta].T
    R = float((mu * -np.log2(nu[np.arange(NX)[None, :], lab])).sum() / NW)
    best = max(best, float(-np.log2(q[np.arange(NW), beta]).sum()) - NW * R)
print(f"  adversarial search near the human (3000 programs): max [-log2 Q - 2^m R] = {best:.6f} (<= 0;"
      f" equality only for programs constant in x within each coupling cell)")
qH = np.einsum("wx,xb->wb", mu, nuH[np.arange(NX)[:, None], hmap])
print(f"  the human: q_w = rho at every w: {np.allclose(qH, rho[None, :])}; so -log2 Q(beta) = 2^m R_H = 2^m H(rho)"
      f" = {NW * float(-(rho * np.log2(rho)).sum()):.4f}: Lemma 4.4 is tight at the human")

# ------------------------------------------------------------------ (B)
print("\n(B) Class analog of Lemma 4.5 over all C(32,4) = 35960 couplings (m = 5, s0 = 4, p = 1/8)")
m, N, s0 = 5, 32, 4
LN = log2(comb(N, s0))
Q17 = np.arange(17) / 16.0
LG = 6                                                              # cost of the human's model g


def gam(t):
    return 2 * floor(log2(t + 1)) + 1


def nlog(x):
    with np.errstate(divide="ignore"):
        return -np.log2(x)


# best total fit N*R for a set of size a containing k of the 4 coin-1 cells, rates from Q17 (inf if impossible)
A1, A0 = nlog(Q17), nlog(1 - Q17)


def fitNR_det(a, k):
    return 0.0 if (a == k == s0) else np.inf


def fitNR(a, k):
    with np.errstate(invalid="ignore"):
        fin = k * A1 + (a - k) * A0                                  # inside T: k coin-1 cells, a-k coin-0 cells
        fout = (s0 - k) * A1 + (N - a - s0 + k) * A0
    fin = np.where(np.isnan(fin), 0.0, fin).min()
    fout = np.where(np.isnan(fout), 0.0, fout).min()
    return float(fin + fout)


BEST = np.array([[fitNR(a, k) if k <= min(a, s0) and s0 - k <= N - a else np.inf for k in range(s0 + 1)]
                 for a in range(N + 1)])
# with the 1-bit flag: deterministic version costs 1 bit, rated version 1 + 10 bits; slen below counts the 10
# rate bits, so the deterministic option is cheaper by 10 bits and has fit 0 iff T = S exactly
BEST_DET = np.array([[fitNR_det(a, k) for k in range(s0 + 1)] for a in range(N + 1)])
H18 = -(1 / 8) * log2(1 / 8) - (7 / 8) * log2(7 / 8)
humanNR = min(s0 * A1[j] + (N - s0) * A0[j] for j in range(1, 17))
assert abs(humanNR - N * H18) < 1e-9
EXTRA_H = 3 + 5
L_H = LG + EXTRA_H
L_COIN = 3

# structured sets as 32-bit masks, with their extra lengths (duplicates removed, keeping the shortest code)
W2 = (np.uint64(1) << np.arange(N, dtype=np.uint64))


def tomask(boolvec):
    return int((W2[np.asarray(boolvec, bool)]).sum())


cand = {}


def put(mask, ln, fam):
    if mask and (mask not in cand or cand[mask][0] > ln):
        cand[mask] = (ln, fam)


wbits = np.array([[(w >> i) & 1 for i in range(m)] for w in range(N)])
for pat in itertools.product((0, 1, 2), repeat=m):                  # 2 = '*'
    ok = np.all([(np.array(pat) == 2) | (wbits[w] == np.array(pat)) for w in range(N)], axis=1)
    put(tomask(ok), 3 + 8 + 1 + 10, "subcube")
for a in range(N):
    for ln in range(1, N + 1):
        put(tomask(np.isin(np.arange(N), (a + np.arange(ln)) % N)), 3 + 10 + 1 + 10, "interval")
PAR = np.array([[bin(a & w).count("1") & 1 for w in range(N)] for a in range(N)])
for k in (1, 2, 3):
    lk = 3 + 2 + ceil(log2(comb(N - 1, k))) + k + 1 + 10
    for rows in itertools.combinations(range(1, N), k):
        P_ = PAR[list(rows)]                                         # (k, N)
        for c in range(2 ** k):
            cv = np.array([(c >> i) & 1 for i in range(k)])[:, None]
            put(tomask(np.all(P_ == cv, axis=0)), lk, f"affine(codim {k})")
drng = np.random.default_rng(203)
for i in range(256):
    T = drng.choice(N, size=s0, replace=False)
    put(tomask(np.isin(np.arange(N), T)), 3 + 8 + 1 + 10, "dictionary")


def prg_set(seed, s):
    hv = [hashlib.sha256(f"{s}:{seed}:{w}".encode()).digest()[:8] for w in range(N)]
    order = sorted(range(N), key=lambda w: hv[w])
    return int(sum(1 << w for w in order[:s0]))


for s in (4, 8, 12):
    for seed in range(2 ** s):
        put(prg_set(seed, s), 3 + 2 + s + 1 + 10, f"PRG({s}-bit seed)")
sets = np.array(list(cand.keys()), dtype=np.uint64)
slen = np.array([v[0] for v in cand.values()], float)
sfam = np.array([v[1] for v in cand.values()])
ssize = np.bitwise_count(sets).astype(int)
NR2 = 17 ** 2                                                       # rate pairs (5 + 5 bits)


def gam_ex(t):
    return 3 + gam(t) + ceil(log2(comb(N, t)) - 1e-12) + 1 + 10


kraft = 17 * 2.0 ** -8 + sum(comb(N, t) * (NR2 + 2 ** 10) * 2.0 ** -gam_ex(t) for t in range(1, N + 1)) \
    + (NR2 + 2 ** 10) * float((2.0 ** -slen).sum())                  # rated + deterministic versions
print(f"  Kraft sum of the extra parts (given the model) = {kraft:.4f} (<= 1);"
      f" L_beta = log2 C(32,4) = {LN:.3f}, 2^m H(1/8) = {N * H18:.3f}; human: length {L_H}, risk {H18:.4f}")
assert kraft <= 1

# beta-independent part: T-memorisers (best T for given t is inside S if t <= 4, else containing S)
mem_best = np.inf
mem_rows = []
for t in range(1, N + 1):
    k = min(t, s0)
    ex = gam_ex(t)
    nr = BEST[t, k]
    mem_rows.append((t, ex, nr))
    mem_rows.append((t, ex - 10, BEST_DET[t, k]))
    mem_best = min(mem_best, ex + nr, ex - 10 + BEST_DET[t, k])
hum_best = EXTRA_H + humanNR

couplings = np.array([sum(1 << c for c in S) for S in itertools.combinations(range(N), s0)], dtype=np.uint64)
NB_ = len(couplings)
print(f"  enumerated {NB_} couplings; structured sets: {len(sets)}")
best_struct = np.full(NB_, np.inf)
best_fam = np.full(NB_, "", dtype=object)
best_rate = np.zeros(NB_)
rate_fam = np.full(NB_, "memoriser(t=4)", dtype=object)
# memoriser rates (beta-independent)
mem_rate = max((N * H18 - nr) / N / (ex - EXTRA_H) for (t, ex, nr) in mem_rows if ex > EXTRA_H)
mem_rate_rated = max((N * H18 - nr) / N / (ex - EXTRA_H) for (t, ex, nr) in mem_rows[0::2] if ex > EXTRA_H)
best_rate[:] = mem_rate
CH = 512
for i0 in range(0, len(sets), CH):
    blk = sets[i0:i0 + CH]
    kk = np.bitwise_count(couplings[:, None] & blk[None, :]).astype(int)        # (NB_, blk)
    nr_r = BEST[ssize[i0:i0 + CH][None, :], kk]
    nr_d = BEST_DET[ssize[i0:i0 + CH][None, :], kk]
    use_d = (slen[i0:i0 + CH][None, :] - 10 + nr_d) < (slen[i0:i0 + CH][None, :] + nr_r)
    nr = np.where(use_d, nr_d, nr_r)
    ln_ = np.where(use_d, slen[i0:i0 + CH][None, :] - 10, slen[i0:i0 + CH][None, :])
    tot = ln_ + nr
    j = np.argmin(tot, axis=1)
    v = tot[np.arange(NB_), j]
    upd = v < best_struct
    best_struct = np.where(upd, v, best_struct)
    best_fam = np.where(upd, sfam[i0:i0 + CH][j], best_fam)
    rate = np.maximum((N * H18 - nr_r) / N / (slen[i0:i0 + CH][None, :] - EXTRA_H),
                      (N * H18 - nr_d) / N / (slen[i0:i0 + CH][None, :] - 10 - EXTRA_H))
    jr = np.argmax(rate, axis=1)
    vr = rate[np.arange(NB_), jr]
    upd = vr > best_rate
    best_rate = np.where(upd, vr, best_rate)
    rate_fam = np.where(upd, sfam[i0:i0 + CH][jr], rate_fam)
min_code = np.minimum(np.minimum(best_struct, mem_best), hum_best)
D = LN - min_code
print(f"  beta-independent minima: human {hum_best:.2f}, best T-memoriser {mem_best:.2f} (extra + 2^m R, bits)")
print("  distribution of the class deficiency D(beta) = L_beta - min_pi[extra + 2^m R_beta] over all couplings:")
for jj in (-8, -6, -4, -2, 0, 2, 4, 6, 8, 10):
    frac = np.mean(D >= jj)
    print(f"    P[D >= {jj:3d}] = {frac:.6f}   bound Kraft*2^-j = {min(1.0, kraft * 2.0 ** -jj):.6f}")
assert all(np.mean(D >= jj) <= kraft * 2.0 ** -jj + 1e-12 for jj in range(-10, 14))
s_minus = (1 - H18) / (L_H - L_COIN)
print(f"  human's left steepness s_- = (1 - H(1/8))/(l_H - l_coin) = {s_minus:.5f};  2^-m = {1 / N:.5f};"
      f"  best T-memoriser rate = {mem_rate:.5f} = {mem_rate * N:.4f} * 2^-m (deterministic full memoriser;"
      f" rated version {mem_rate_rated * N:.4f} * 2^-m)")
print(f"  largest alien rate s_+(beta): median {np.median(best_rate):.5f}, max {best_rate.max():.5f};"
      f" P[s_+ > 2^-m] = {np.mean(best_rate > 1 / N):.5f}")
empty = best_rate >= s_minus
print(f"  window (s_+, s_-) EMPTY for {empty.sum()} of {NB_} couplings (fraction {empty.mean():.5f});"
      f" their D(beta): min {D[empty].min() if empty.any() else float('nan'):.2f}")
fams, cnts = np.unique(rate_fam[best_rate > mem_rate + 1e-12].astype(str), return_counts=True)
print("  couplings whose s_+ exceeds the memoriser's, by the family attaining s_+: "
      + ", ".join(f"{f}: {c}" for f, c in zip(fams, cnts)))
fams, cnts = np.unique(rate_fam[empty].astype(str), return_counts=True)
print("  couplings with an empty window, by family: " + ", ".join(f"{f}: {c}" for f, c in zip(fams, cnts)))
# the right line with the class offset: every alien satisfies extra - EXTRA_H >= 2^m (R_H - R) - G(beta),
# G(beta) = 2^m H + EXTRA_H - min_code; report its distribution
G = N * H18 + EXTRA_H - min_code
print(f"  explicit right-line offset G(beta) (bits): median {np.median(G):.2f}, 99.9% quantile"
      f" {np.quantile(G, 0.999):.2f}, max {G.max():.2f};  G = D + (2^m H - L_beta) + extra(human) ="
      f" D + {N * H18 - LN + EXTRA_H:.2f}")

# Proposition 4.9(d): the human's left steepness falls as its model gets longer; s_+(beta) does not depend on L_G
for lg in (6, 8, 9, 10):
    sm = (1 - H18) / (lg + EXTRA_H - L_COIN)
    print(f"  L_G = {lg:2d}: s_- * 2^m = {sm * N:.3f}; window empty for a fraction {np.mean(best_rate >= sm):.5f} of couplings"
          f"  [(l_H - l_coin)/(1 - H(1/8)) = {(lg + EXTRA_H - L_COIN) / (1 - H18):.1f} vs 2^m = {N}]")

# ------------------------------------------------------------------ (C)
print("\n(C) Couplings generated by the PRG with a short seed (Proposition 4.9(c))")
for s in (4, 8, 12):
    idx = []
    for seed in (0, 1, 2):
        msk = prg_set(seed, s)
        i = int(np.flatnonzero(couplings == np.uint64(msk))[0])
        idx.append(i)
    print(f"  s = {s:2d}: D(beta) = {', '.join(f'{D[i]:.2f}' for i in idx)};  s_+ * 2^m ="
          f" {', '.join(f'{best_rate[i] * N:.3f}' for i in idx)};  window empty: {[bool(empty[i]) for i in idx]}"
          f"  (s_- * 2^m = {s_minus * N:.3f})")

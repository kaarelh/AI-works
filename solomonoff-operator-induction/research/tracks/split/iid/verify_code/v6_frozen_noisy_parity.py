"""v6: independent check of iid notes-final Cor 6.1(vi) (frozen noise on a finite domain, the i4 class).
Written for verify-iid.md; it does not import or read any record script.

The class (from the record's description of i4): inputs {0,1}^6 (64 inputs); programs (a, q) for every a in
{0,1}^6 and q in RATES = [0, 1/4, 1/8, 1/16, 3/16, 5/16, 3/8, 7/16] with rate-code lengths [2,2,3,4,5,6,7,7], of
length 1 + 6 + l_rate(q); and the coin, of length 2.  Truth (a*, 1/8), a* = 0b101101, l0 = 10.
Frozen full table: F(x) = <a*, x> xor flip(x), flips i.i.d. Bern(1/8).  The lambda-MAP on the full table "fails"
if some program other than the truth has J <= J(truth) (ties count as failures, as in the record).

(A) The proved lower bound (7/8)^64 and its mechanism ((a*, 0) beats the truth when no input is flipped).
(B) Exact bracket.  A := {some (a*, q != 1/8) or the coin has J <= J(truth)} depends only on K = #flips.
    For a != a*, the set S_a = {x : <a xor a*, x> = 1} has 32 elements, and the mismatch count of a is
    32 + K - 2 K_in with K_in = #flips in S_a, (K_in, K - K_in) ~ Bin(32, 1/8) x Bin(32, 1/8).  So
       P[A] <= P[fail] <= P[A] + 63 P[B_a \ A],   B_a := {some (a, q) has J <= J(truth)},
    all computed exactly.
(C) Monte Carlo over 200,000 tables (seed 4601) of P[fail] and of which program is the unique lambda-MAP.
(D) The same exact bracket in the second class quoted by the record (referee B's rB6 class, re-typed from its
    description): rates 1/8, 1/4, 1/16, 3/16, 0, 3/32, 5/32 with codes 2, 3, 3, 4, 4, 5, 5; (a, q) of length
    2 + 6 + code; function competitors (a, q, x0) (parity bit flipped at one input x0) of length 2 + 6 + code + 7;
    the coin, length 2.  For (a*, q, x0) the best x0 changes the mismatch count K by -1 (K >= 1), so its event
    depends only on K; wrong parities (with or without x0) are bounded by the union bound as in (B).
"""
import math
from math import comb, log2

import numpy as np

d = 6
NX = 64
RATES = [0.0, 1 / 4, 1 / 8, 1 / 16, 3 / 16, 5 / 16, 3 / 8, 7 / 16]
LRATE = [2, 2, 3, 4, 5, 6, 7, 7]
LEN = [1 + d + l for l in LRATE]
ASTAR = 0b101101
P = 1 / 8
IQ = RATES.index(P)
assert 64 * sum(2.0 ** -l for l in LEN) + 2 ** -2 <= 1


def fit(mis, q):
    if q == 0:
        return 0.0 if mis == 0 else math.inf
    return mis * -log2(q) + (NX - mis) * -log2(1 - q)


def binom(nn, k, p):
    return comb(nn, k) * p ** k * (1 - p) ** (nn - k)


LAMS = (1.0, 1.5, 2.0, 4.0)
TOL = 1e-9

print("=" * 100)
print("(A) proved lower bound")
for lam in LAMS:
    Jt = lam * LEN[IQ] + fit(0, P)
    J0 = lam * LEN[0] + fit(0, 0.0)
    print(f"  lambda={lam}: no flip: J(a*,0) = {J0:.3f} < J(truth) = {Jt:.3f}: {J0 < Jt}")
print(f"  (7/8)^64 = {(7 / 8) ** 64:.4e}")

print("=" * 100)
print("(B) exact bracket for P[frozen lambda-MAP != truth]")
for lam in LAMS:
    def A_event(K):
        Jt = lam * LEN[IQ] + fit(K, P)
        if lam * 2 + NX <= Jt + TOL:
            return True
        return any(lam * LEN[i] + fit(K, q) <= Jt + TOL for i, q in enumerate(RATES) if i != IQ)

    PA = sum(binom(NX, K, P) for K in range(NX + 1) if A_event(K))
    PBnotA = 0.0
    for kin in range(33):
        for kout in range(33):
            K = kin + kout
            if A_event(K):
                continue
            Jt = lam * LEN[IQ] + fit(K, P)
            mis = 32 + K - 2 * kin
            if any(lam * LEN[i] + fit(mis, q) <= Jt + TOL for i, q in enumerate(RATES)):
                PBnotA += binom(32, kin, P) * binom(32, kout, P)
    print(f"  lambda={lam}: P[A] = {PA:.5f};  63 P[B_a minus A] = {63 * PBnotA:.2e};  "
          f"so P[fail] in [{PA:.5f}, {PA + 63 * PBnotA:.5f}]")

print("  exact breakdown by K of the unique lambda-MAP among (a*, q) and the coin (wrong parities never compete):")
for lam in LAMS:
    out = {}
    for K in range(NX + 1):
        cand = [(lam * LEN[i] + fit(K, q), f"rate {q:.4g}") for i, q in enumerate(RATES)] + [(lam * 2 + NX, "coin")]
        jm = min(c[0] for c in cand)
        win = [c[1] for c in cand if c[0] <= jm + TOL]
        key = win[0] if len(win) == 1 else "tie"
        out[key] = out.get(key, 0.0) + binom(NX, K, P)
    print(f"    lambda={lam}: " + ", ".join(f"{k}: {v:.4f}" for k, v in sorted(out.items(), key=lambda kv: -kv[1])))

print("=" * 100)
print("(C) Monte Carlo, 200,000 frozen full tables (seed 4601)")
rng = np.random.default_rng(4601)
X = np.arange(NX)
PAR = np.array([[bin(a & x).count("1") & 1 for x in X] for a in X], dtype=np.int8)
with np.errstate(divide="ignore"):
    LQ = np.array([-log2(q) if q > 0 else np.inf for q in RATES])
L1Q = np.array([-log2(1 - q) for q in RATES])
LENA = np.array(LEN, float)
B = 20000
stats = {lam: {"fail": 0, "win": {}} for lam in LAMS}
for _ in range(10):
    flips = (rng.random((B, NX)) < P).astype(np.int8)
    F = PAR[ASTAR][None, :] ^ flips
    mis = (PAR[None, :, :] != F[:, None, :]).sum(-1)               # (B, 64)
    m = mis[..., None].astype(float)
    with np.errstate(invalid="ignore"):
        fits = np.where(m > 0, m * LQ, 0.0) + (NX - m) * L1Q          # (B, 64, 8)
    for lam in LAMS:
        J = lam * LENA[None, None, :] + fits
        Jt = J[:, ASTAR, IQ].copy()
        Jflat = J.reshape(B, -1)
        oth = Jflat.copy()
        oth[:, ASTAR * 8 + IQ] = np.inf
        Jcoin = lam * 2 + NX
        fail = (oth.min(1) <= Jt + TOL) | (Jcoin <= Jt + TOL)
        stats[lam]["fail"] += int(fail.sum())
        allJ = np.concatenate([Jflat, np.full((B, 1), Jcoin)], 1)
        jmin = allJ.min(1)
        nmin = (allJ <= jmin[:, None] + TOL).sum(1)
        arg = allJ.argmin(1)
        for b in np.flatnonzero(fail):
            if nmin[b] > 1:
                key = "tie"
            elif arg[b] == 64 * 8:
                key = "coin"
            else:
                a, qi = divmod(int(arg[b]), 8)
                key = f"rate {RATES[qi]:.4g}" if a == ASTAR else "wrong parity"
            stats[lam]["win"][key] = stats[lam]["win"].get(key, 0) + 1
N = 10 * B
for lam in LAMS:
    p = stats[lam]["fail"] / N
    wins = ", ".join(f"{k}: {v / N:.3f}" for k, v in sorted(stats[lam]["win"].items(), key=lambda kv: -kv[1]))
    print(f"  lambda={lam}: P[fail] = {p:.4f} (s.e. {math.sqrt(p * (1 - p) / N):.4f}); unique MAP instead: {wins}")
print("=" * 100)
print("(D) exact bracket in the second class (rB6's, re-typed)")
R2 = [1 / 8, 1 / 4, 1 / 16, 3 / 16, 0.0, 3 / 32, 5 / 32]
C2 = [2, 3, 3, 4, 4, 5, 5]
assert sum(2.0 ** -c for c in C2) <= 1
L2 = [2 + d + c for c in C2]
IQ2 = 0
for lam in LAMS:
    Jt_of = lambda K: lam * L2[IQ2] + fit(K, 1 / 8)

    def A2(K):
        Jt = Jt_of(K)
        if lam * 2 + NX <= Jt + TOL:
            return True
        if any(lam * L2[i] + fit(K, q) <= Jt + TOL for i, q in enumerate(R2) if i != IQ2):
            return True
        Kx = K - 1 if K >= 1 else K + 1          # best single-input function competitor of a*
        return any(lam * (L2[i] + d + 1) + fit(Kx, q) <= Jt + TOL for i, q in enumerate(R2))

    PA2 = sum(binom(NX, K, P) for K in range(NX + 1) if A2(K))
    PB2 = 0.0
    for kin in range(33):
        for kout in range(33):
            K = kin + kout
            if A2(K):
                continue
            Jt = Jt_of(K)
            mis = 32 + K - 2 * kin
            if any(lam * L2[i] + fit(mis, q) <= Jt + TOL or lam * (L2[i] + d + 1) + fit(max(mis - 1, 0), q) <= Jt + TOL
                   for i, q in enumerate(R2)):
                PB2 += binom(32, kin, P) * binom(32, kout, P)
    print(f"  lambda={lam}: P[fail] in [{PA2:.5f}, {PA2 + 63 * PB2:.5f}]")
print("done")

"""f8: model-coupling confounding (notes-final Proposition 4.11 = referee A's R1, and Proposition 4.10(a2),
the decomposition bound).  (A) exact enumeration; (B) deterministic, with one seeded table default_rng(81).

(A) R1's world, exhaustively, for (m, s0) = (3, 1), (3, 2), (3, 3), (4, 2): the human H_f answers
    y = f(w) XOR b with private coin b ~ Bern(p), p = s0/2^m < 1/2; the coupling beta is an s0-subset of the
    cells; the data are (w, T(w)) with T = f XOR 1_beta.  Checks: (f, beta) -> (T, beta) is a bijection; every
    data law T is shared by exactly C(2^m, s0) worlds; their humans' kernels are pairwise different; hence
    for the Bayes-optimal procedure (and so for every procedure) the probability of copying the world's
    human, averaged over uniform (f, beta), is exactly C(2^m, s0)^-1 = 2^-L_beta.
(B) The same coupling law with a SIMPLE human (f = 0: the coin-flipping human) and with a COMPLEX human (f a
    uniformly random table), m = 6, s0 = 16, p = 1/4, in one explicit prefix class:
      '00' fair coin (l = 2); '010' + 4 bits: Bern(j/16) flips of f' = 0 (l = 7); '011' + 4 bits: the same
      for f' = 1 (l = 7); '10' + 64 + 4 bits: any table g with Bern(j/16) flips, j = 0..15 (l = 70; j = 0 is
      the deterministic table D(g)); '11' + gamma(t) + ceil(log2 C(64, t)) + 4 bits: f' = 0 with y = 1
      forced on a t-set (memorisers of the simple world, t <= 64).
    Population J_c-minimisers over the whole class, for c across six decades.
"""
import itertools
from math import comb, log2, floor
import numpy as np


def H(p):
    return 0.0 if p <= 0 or p >= 1 else -p * log2(p) - (1 - p) * log2(1 - p)


print("(A) R1 exhaustively: every data law is shared by C(2^m, s0) worlds with pairwise different humans")
for m, s0 in ((3, 1), (3, 2), (3, 3), (4, 2)):
    N = 2 ** m
    p = s0 / N
    assert p < 0.5
    groups = {}
    nworlds = 0
    for f in range(2 ** N):                                  # f as an N-bit table
        for S in itertools.combinations(range(N), s0):
            bmask = sum(1 << w for w in S)
            T = f ^ bmask
            groups.setdefault(T, []).append((f, bmask))
            nworlds += 1
    sizes = {len(v) for v in groups.values()}
    distinct = all(len({f for f, _ in v}) == len(v) for v in groups.values())
    # Bayes-optimal success: for each T, output the kernel of one world in the group -> exactly one success
    # (kernels nu_f differ whenever f differs, since p != 1/2); average over uniform worlds:
    succ = len(groups) / nworlds
    print(f"  m = {m}, s0 = {s0}: {nworlds} worlds, {len(groups)} data laws (all 2^{N} tables T: "
          f"{len(groups) == 2 ** N}); worlds per data law = {sizes}; humans distinct within each law: {distinct};"
          f" best average success = {succ:.6f} = 1/{round(1 / succ)} = 1/C({N},{s0}) = {1 / comb(N, s0):.6f}")

print()
print("(B) simple human (f = 0) versus complex human (f random), m = 6, s0 = 16, p = 1/4, explicit class")
rng = np.random.default_rng(81)
m, s0 = 6, 16
N = 2 ** m
p = s0 / N
S = rng.choice(N, size=s0, replace=False)
beta = np.zeros(N, int); beta[S] = 1
f_complex = rng.integers(0, 2, size=N)
qs = np.arange(0, 16) / 16


def gl(t):
    return 2 * floor(log2(t)) + 1


def risk_flip(d, q):
    """Population risk of 'table g with Bern(q) flips' when g disagrees with the data on d of the N cells."""
    a = 0.0
    if d > 0:
        a += d * (np.inf if q == 0 else -log2(q))
    if N - d > 0:
        a += (N - d) * (np.inf if q == 1 else -log2(1 - q))
    return a / N


for label, f in (("simple human f = 0 (the coin-flipping human)", np.zeros(N, int)),
                 ("complex human f = random table", f_complex)):
    T = f ^ beta
    progs = [(2.0, 1.0, "fair coin")]
    for j, q in enumerate(qs):
        if j == 0:
            continue
        progs.append((7.0, risk_flip(int(T.sum()), q), f"f'=0, q={j}/16"))
        progs.append((7.0, risk_flip(int((1 - T).sum()), q), f"f'=1, q={j}/16"))
    # tables: the best table for each q is g = T (d = 0) or the true f (d = s0); all tables have l = 70
    for j, q in enumerate(qs):
        progs.append((70.0, risk_flip(0, q), f"table T, q={j}/16" if j else "D(T) (table, deterministic)"))
        progs.append((70.0, risk_flip(int((f ^ T).sum()), q), f"table f (the human's own table), q={j}/16"))
    # memorisers of the simple world: f' = 0 with y = 1 forced on t cells (best: t cells inside T's ones)
    ones = int(T.sum())
    for t in range(1, N + 1):
        lt = 2 + gl(t) + (comb(N, t) - 1).bit_length() + 4
        for j, q in enumerate(qs):
            if j == 0:
                continue
            inside = min(t, ones)
            if t > ones:                                       # forced 1 on a 0-cell: infinite loss
                R = np.inf
            else:
                R = ((ones - inside) * -log2(q) + (N - ones) * -log2(1 - q)) / N
            progs.append((float(lt), R, f"memoriser on f'=0, t={t}"))
    Ls = np.array([x[0] for x in progs]); Rs = np.array([x[1] for x in progs]); nm = [x[2] for x in progs]
    human_name = "f'=0, q=4/16" if label.startswith("simple") else "table f (the human's own table), q=4/16"
    print(f"  {label}: l(human) = {Ls[nm.index(human_name)]:.0f}, R(human) = {Rs[nm.index(human_name)]:.4f} "
          f"(= H(1/4) = {H(0.25):.4f})")
    for c in (1e-4, 3e-4, 1e-3, 3e-3, 1e-2, 1.6e-2, 2.5e-2, 3e-2, 5e-2, 1e-1, 1.0):
        J = c * Ls + Rs
        ix = int(np.argmin(J))
        print(f"     c = {c:8.1e} (= {c * N:7.3f} 2^-m): argmin = {nm[ix]:45s} l = {Ls[ix]:4.0f}  R = {Rs[ix]:.4f}"
              f"  {'<- the human' if nm[ix] == human_name else ''}")

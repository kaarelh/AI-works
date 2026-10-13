"""rB6: numerical checks of the coding steps used in notes.md Prop 3.3(b) and Paper 2's
lem:teacher:coding, on random semimeasure hypotheses (including zero probabilities).

(A) The sampled coding lemma: for a sample dom D_n and the cells Z it hits, q_z(b) :=
    2^{-(1/n_z) sum_{x in cell z} -log2 nu(f_a(x) xor b | x)} satisfies q_z(0) + q_z(1) <= 1 (weighted AM-GM),
    so Q(T) := prod_{z in Z} q_z(1_T(z)) has total mass <= 1 over subsets T of Z; and
    -log2 Q(S cap Z) = sum_z F_z / n_z, with F_z the fit of nu on the sampled inputs of cell z.
    Also the equal-multiplicity identity F = nbar * sum_z F_z / n_z.
(B) lem:teacher:coding (full table, B = inf and integer B): -log2 Q(S) = 2^m R_B + beta_B with per-factor
    normalisation, total mass <= 1; and the total mass with a single global division by 1 + tau_B.
Seeded: numpy default_rng(66).
"""
import math
import sys

import numpy as np

sys.dont_write_bytecode = True
from rBcommon import parity_table

rng = np.random.default_rng(66)


def random_hyp(N):
    """random conditional semimeasure: nu(0|x) + nu(1|x) <= 1, with some exact zeros and ones."""
    tot = rng.uniform(0.2, 1.0, N)
    tot[rng.random(N) < 0.3] = 1.0
    sp = rng.uniform(0, 1, N)
    sp[rng.random(N) < 0.1] = 0.0
    sp[rng.random(N) < 0.1] = 1.0
    nu0 = tot * sp
    nu1 = tot * (1 - sp)
    return np.stack([nu0, nu1], axis=1)


def nlog(v):
    with np.errstate(divide="ignore"):
        return -np.log2(v)


def part_A(trials=3000):
    worst_sum = 0.0
    worst_id = 0.0
    worst_mass = 0.0
    n_inf = 0
    for _ in range(trials):
        d = int(rng.integers(6, 11))
        m = int(rng.integers(2, d + 1))
        N = 1 << d
        a = int(rng.integers(0, N))
        fa = parity_table(a, d)
        S = rng.random(1 << m) < rng.uniform(0.05, 0.5)
        ystar = fa ^ S[np.arange(N) >> (d - m)].astype(np.int8)
        nu = random_hyp(N)
        if rng.random() < 0.5:  # correlate nu with the teacher on some inputs
            good = rng.random(N) < 0.7
            nu[good, :] = 0.0
            nu[good, ystar[good]] = rng.uniform(0.5, 1.0, int(good.sum()))
        n = int(rng.integers(1, N + 1))
        xs = rng.choice(N, size=n, replace=False)
        cell = xs >> (d - m)
        Z = np.unique(cell)
        tot_bits = 0.0
        sumFz = 0.0
        logmass = 0.0
        for z in Z:
            xz = xs[cell == z]
            nz = len(xz)
            l0 = nlog(nu[xz, fa[xz]])          # label f_a(x)
            l1 = nlog(nu[xz, 1 - fa[xz]])      # label f_a(x) xor 1
            q0 = 2.0 ** (-l0.mean()) if np.all(np.isfinite(l0)) else 0.0
            q1 = 2.0 ** (-l1.mean()) if np.all(np.isfinite(l1)) else 0.0
            worst_sum = max(worst_sum, q0 + q1 - 1.0)
            logmass += math.log2(q0 + q1) if q0 + q1 > 0 else -math.inf
            Fz = float(nlog(nu[xz, ystar[xz]]).sum())
            tot_bits += Fz
            sumFz += Fz / nz
            qS = q1 if S[z] else q0
            lhs = -math.log2(qS) if qS > 0 else math.inf
            if math.isinf(lhs) or math.isinf(Fz):
                n_inf += 1
                assert math.isinf(lhs) == math.isinf(Fz)
            else:
                worst_id = max(worst_id, abs(lhs - Fz / nz) / max(1.0, abs(lhs)))
        worst_mass = max(worst_mass, logmass)
    print(f"  {trials} random (d, m, a, S, nu, sample): max of q_z(0) + q_z(1) - 1 = {worst_sum:.3e} (must be <= 0);")
    print(f"  max log2 of the total mass of Q = {worst_mass:.3e} (must be <= 0); identity -log Q_z(S) = F_z/n_z: max rel. "
          f"error {worst_id:.2e} ({n_inf} cells with infinite fit, matched)")
    # equal multiplicities: full table with m < d gives n_z = 2^(d-m) for every cell
    d, m = 9, 5
    N = 1 << d
    nu = rng.uniform(0.05, 0.5, (N, 2))  # strictly positive, so that the fit is finite
    fa = parity_table(5, d)
    S = rng.random(1 << m) < 0.2
    ystar = fa ^ S[np.arange(N) >> (d - m)].astype(np.int8)
    F = float(nlog(nu[np.arange(N), ystar]).sum())
    perz = sum(float(nlog(nu[(z << (d - m)) + np.arange(1 << (d - m)), ystar[(z << (d - m)) + np.arange(1 << (d - m))]]).sum()) / (1 << (d - m))
               for z in range(1 << m))
    print(f"  equal multiplicities (full table, n_z = {1 << (d - m)}): F = {F:.6f}, nbar * sum F_z/n_z = {(1 << (d - m)) * perz:.6f}")


def part_B(trials=2000):
    worst_id, worst_mass, single_max = 0.0, -math.inf, 0.0
    for _ in range(trials):
        d = int(rng.integers(4, 9))
        m = int(rng.integers(2, d + 1))
        N = 1 << d
        r = int(rng.integers(2, m + 1))
        B = rng.choice([math.inf, r, r + 1, r + 3])
        a = int(rng.integers(0, N))
        fa = parity_table(a, d)
        S = np.zeros(1 << m, dtype=bool)
        S[rng.choice(1 << m, size=1 << (m - r), replace=False)] = True
        ystar = fa ^ S[np.arange(N) >> (d - m)].astype(np.int8)
        nu = random_hyp(N)
        if rng.random() < 0.3:  # deterministic hypotheses
            lab = rng.integers(0, 2, N)
            nu = np.zeros((N, 2))
            nu[np.arange(N), lab] = 1.0
        tauB = 0.0 if B == math.inf else 2.0 ** (1 - B)
        betaB = 0.0 if B == math.inf else (1 << m) * math.log2(1 + tauB)
        cut = lambda v: np.minimum(B, nlog(v)) if B != math.inf else nlog(v)
        RB = float(cut(nu[np.arange(N), ystar]).mean())
        logQ = 0.0
        logmass = 0.0
        for z in range(1 << m):
            xz = (z << (d - m)) + np.arange(1 << (d - m))
            e0 = cut(nu[xz, fa[xz]]).mean()
            e1 = cut(nu[xz, 1 - fa[xz]]).mean()
            q0, q1 = 2.0 ** (-e0), 2.0 ** (-e1)
            logmass += math.log2((q0 + q1) / (1 + tauB)) if q0 + q1 > 0 else -math.inf
            qS = q1 if S[z] else q0
            logQ += math.log2(qS / (1 + tauB)) if qS > 0 else -math.inf
        lhs = -logQ
        rhs = (1 << m) * RB + betaB
        if math.isfinite(lhs) or math.isfinite(rhs):
            worst_id = max(worst_id, abs(lhs - rhs) / max(1.0, abs(rhs)))
        worst_mass = max(worst_mass, logmass)
        if B != math.inf:
            single = logmass + (1 << m) * math.log2(1 + tauB) - math.log2(1 + tauB)
            single_max = max(single_max, single)
    print(f"  {trials} random instances (B in {{inf, r, r+1, r+3}}): identity -log Q(S) = 2^m R_B + beta_B, max rel. error "
          f"{worst_id:.2e}; max log2 total mass (per-factor normalisation) = {worst_mass:.3e} (must be <= 0)")
    print(f"  with one global division by 1 + tau_B instead: largest log2 total mass = {single_max:.3f} (> 0: not a semimeasure)")


if __name__ == "__main__":
    print("=" * 100)
    print("(A) the sampled coding lemma of Prop 3.3(b)")
    part_A()
    print("=" * 100)
    print("(B) lem:teacher:coding on the full table")
    part_B()

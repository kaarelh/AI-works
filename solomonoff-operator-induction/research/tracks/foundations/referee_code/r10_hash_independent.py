"""r10 (referee): independent check of the hashing step in Prop 4.4 of the foundations notes, with a
different field size and irreducible polynomial than the track's c2, and only on the embedded points.

Field GF(2^5) with modulus x^5 + x^2 + 1; n = 4, so {0,1}^{<=4} embeds via x -> binary number "1x",
which is injective onto {1,...,31}.  Seeds s in GF(2^5)^k, h_s(z) = lowest bit of sum_{i<k} s_i z^i.
For k = 2 and k = 3, for every j <= k and every j-subset of the 31 embedded points, every labelling
must be hit by exactly 2^{5k-j} seeds.  (numpy, exhaustive.)

Deterministic.  Output: r10_hash_independent_output.txt
"""
import itertools

import numpy as np

M = 5
MOD = 0b100101  # x^5 + x^2 + 1


def gf_mul(a, b):
    r = 0
    while b:
        if b & 1:
            r ^= a
        b >>= 1
        a <<= 1
        if a & (1 << M):
            a ^= MOD
    return r


MUL = np.array([[gf_mul(a, b) for b in range(32)] for a in range(32)], dtype=np.int64)


def embed(x):
    return int("1" + x, 2)


def main():
    lines = []
    pts = sorted({embed("".join(b)) for L in range(0, 5) for b in itertools.product("01", repeat=L)})
    lines.append(f"embedded points: {len(pts)} distinct (expected 31), range {min(pts)}..{max(pts)}")
    for k in (2, 3):
        seeds = np.array(list(itertools.product(range(32), repeat=k)), dtype=np.int64)
        H = np.zeros((len(seeds), 32), dtype=np.int64)
        for z in range(32):
            acc = np.zeros(len(seeds), dtype=np.int64)
            zp = 1
            for i in range(k):
                acc ^= MUL[seeds[:, i], zp]
                zp = gf_mul(zp, z)
            H[:, z] = acc & 1
        worst = 0
        checks = 0
        for j in range(1, k + 1):
            expected = len(seeds) // 2 ** j
            for sub in itertools.combinations(pts, j):
                key = np.zeros(len(seeds), dtype=np.int64)
                for z in sub:
                    key = key * 2 + H[:, z]
                cnt = np.bincount(key, minlength=2 ** j)
                worst = max(worst, int(np.abs(cnt - expected).max()))
                checks += 1
        lines.append(f"k={k}: seeds={len(seeds)}, subsets checked={checks}, max |count - 2^(5k-j)| = {worst}")
    out = "\n".join(lines)
    print(out)
    with open(__file__.replace(".py", "_output.txt"), "w") as f:
        f.write(out + "\n")


if __name__ == "__main__":
    main()

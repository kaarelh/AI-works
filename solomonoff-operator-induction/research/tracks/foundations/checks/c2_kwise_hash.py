"""c2: k-wise independence of the polynomial hash family used in Prop 4.4 of notes.md.

Family: seeds s = (s_0..s_{k-1}) in GF(2^m)^k, h_s(z) = low bit of sum_i s_i z^i.
Claim checked exhaustively for (m,k) in {(3,2),(3,3),(4,2),(4,3)}: for every set of j <= k
distinct field elements z_1..z_j and every labelling b in {0,1}^j, the number of seeds with
h_s(z_i) = b_i for all i is exactly 2^{mk-j}.  (Hence Pr_s[h_s extends D] = 2^{-|D|}.)

Deterministic (no randomness).  Output: c2_kwise_hash.out.txt
"""
import itertools

IRRED = {3: 0b1011, 4: 0b10011}  # x^3+x+1, x^4+x+1


def gf_mul(a, b, m):
    r = 0
    while b:
        if b & 1:
            r ^= a
        b >>= 1
        a <<= 1
        if a >> m:
            a ^= IRRED[m]
    return r


def h(seed, z, m):
    acc = 0
    zp = 1
    for s in seed:
        acc ^= gf_mul(s, zp, m)
        zp = gf_mul(zp, z, m)
    return acc & 1


def check(m, k):
    field = range(2 ** m)
    seeds = list(itertools.product(field, repeat=k))
    # table of h values
    table = {seed: [h(seed, z, m) for z in field] for seed in seeds}
    worst_dev = 0
    nchecks = 0
    for j in range(1, k + 1):
        expected = len(seeds) // (2 ** j)
        for zs in itertools.combinations(field, j):
            counts = {}
            for seed in seeds:
                key = tuple(table[seed][z] for z in zs)
                counts[key] = counts.get(key, 0) + 1
            for b in itertools.product((0, 1), repeat=j):
                nchecks += 1
                worst_dev = max(worst_dev, abs(counts.get(b, 0) - expected))
    return len(seeds), nchecks, worst_dev


def main():
    lines = []
    for m, k in [(3, 2), (3, 3), (4, 2), (4, 3)]:
        ns, nc, dev = check(m, k)
        lines.append(f"m={m} k={k}: seeds={ns}, (subset,labelling) pairs checked={nc}, "
                     f"max |count - 2^(mk-j)| = {dev}")
    out = "\n".join(lines)
    print(out)
    with open(__file__.replace(".py", ".out.txt"), "w") as f:
        f.write(out + "\n")


if __name__ == "__main__":
    main()

"""rA1_gadget_ratio.py -- referee A, thread `sfi`: exact check of the prior-ratio bound used in
Cor 10.2(b) of notes.md (exception gadget for verifier circuits).

Prior (notes Cor 10.2): w(V) = 2^{-s} * 1/(2s+1) * 1/N_{s,k},  N_{s,k} = prod_{j=1}^{s} 16 (d+k+1+j)^2,
size s, k <= 2s certificate bits.  The gadget appends g' <= gamma := 2d+2 gates and keeps k.
Claim: w(V')/w(V) >= 2^{-Gamma_N(s)},
       Gamma_N(s) = gamma*(5 + 2 log2(d+3s+gamma+1)) + log2(gamma+1).
The script evaluates log2 of the exact ratio for all d <= 24, a grid of s, every k <= 2s on the
grid, and every g' in 1..gamma, and reports the smallest slack Gamma_N(s) + log2(ratio) (must be >= 0).
Deterministic (no randomness).  Output: rA1_gadget_ratio.out next to this script.
"""
import math

def log2_ratio(d, s, k, g):
    # log2 w(V')/w(V), V' of size s+g with the same k
    val = -g + math.log2((2 * s + 1) / (2 * (s + g) + 1))
    for j in range(s + 1, s + g + 1):
        val -= math.log2(16 * (d + k + 1 + j) ** 2)
    return val

def Gamma_N(d, s):
    gamma = 2 * d + 2
    return gamma * (5 + 2 * math.log2(d + 3 * s + gamma + 1)) + math.log2(gamma + 1)

def main():
    lines = []
    worst = None
    n = 0
    s_grid = sorted(set(list(range(2, 40)) + [50, 64, 100, 128, 200, 500, 1000, 4096]))
    for d in range(1, 25):
        gamma = 2 * d + 2
        for s in s_grid:
            ks = sorted(set([0, 1, s, 2 * s] + list(range(0, 2 * s + 1, max(1, (2 * s) // 8)))))
            for k in ks:
                if k > 2 * s:
                    continue
                for g in range(1, gamma + 1):
                    slack = Gamma_N(d, s) + log2_ratio(d, s, k, g)
                    n += 1
                    if worst is None or slack < worst[0]:
                        worst = (slack, d, s, k, g)
    lines.append('rA1: prior-ratio bound of Cor 10.2(b) (exception gadget), exact evaluation')
    lines.append('cases evaluated: %d (d = 1..24, s on a grid of %d values up to 4096, k on a grid in [0, 2s], g = 1..2d+2)' % (n, len(s_grid)))
    lines.append('smallest slack Gamma_N(s) + log2(w(V\')/w(V)) = %.6f at d=%d, s=%d, k=%d, g=%d' % worst)
    lines.append('bound holds in every case: %s' % (worst[0] >= 0))
    out = '\n'.join(lines) + '\n'
    print(out, end='')
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write(out)

if __name__ == '__main__':
    main()

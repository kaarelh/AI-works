"""c10: finite checks for Prop. 4.10(d) (single shortest program for SFI^hist).

Track "history", notes-final.md, Prop. 4.10(d).  Seed 20261014.  Output saved to c10_single_program_counting.out.

Prop. 4.10(d) rests on two elementary facts, checked here on finite instances:
  (1) Summation by parts: for any finite prefix-free set of programs with k_L programs of length L and
      C(L) := #programs of length <= L,  sum_{L<=M} k_L 2^-L = sum_{L<=M} C(L) 2^-(L+1) + C(M) 2^-(M+1).
      Checked exactly (rationals) on random prefix-free sets.
  (2) The counting bound: if every y in {0,1}^n has a consistent program of length <= n + e*(n), with e*
      nondecreasing, then sum_n 2^-e*(n) <= 2.  Checked on (a) the toy language <n>_delta y (Elias-delta
      code of n followed by the n label bits), whose excess is len_delta(n); and (b) random prefix-free
      "monotone" families built greedily from random infinite label sequences, where the excess function
      is computed by brute force over all y of length n <= 10.
  (3) The toy language's excess len_delta(n) compared with log n + log log n: it exceeds it for all n >= 4,
      as Prop. 4.10(d) says any family must for infinitely many n.
This checks the counting argument on finite families; it proves nothing about the universal machine.
"""
import random
from fractions import Fraction as Fr
from math import log2, floor

OUT = []


def say(s=""):
    OUT.append(s)
    print(s)


def elias_gamma_len(n):
    return 2 * floor(log2(n)) + 1


def elias_delta_len(n):
    L = floor(log2(n)) + 1
    return L - 1 + elias_gamma_len(L)


def random_prefix_free(rng, size, maxlen):
    """random prefix-free set: grow a random binary tree and take leaves."""
    leaves = ['']
    while len(leaves) < size:
        i = rng.randrange(len(leaves))
        w = leaves[i]
        if len(w) >= maxlen:
            continue
        leaves[i] = w + '0'
        leaves.append(w + '1')
    # drop a random subset so the set is not complete
    return [w for w in leaves if rng.random() < 0.7]


def part1(rng):
    ok = True
    for trial in range(200):
        P = random_prefix_free(rng, rng.randrange(2, 40), 12)
        if not P:
            continue
        assert all(not (a != b and b.startswith(a)) for a in P for b in P)
        M = max(len(p) for p in P)
        k = [sum(1 for p in P if len(p) == L) for L in range(M + 1)]
        C = [sum(k[:L + 1]) for L in range(M + 1)]
        for MM in range(M + 1):
            lhs = sum(Fr(k[L], 2 ** L) for L in range(MM + 1))
            rhs = sum(Fr(C[L], 2 ** (L + 1)) for L in range(MM + 1)) + Fr(C[MM], 2 ** (MM + 1))
            if lhs != rhs:
                ok = False
        if sum(Fr(1, 2 ** len(p)) for p in P) > 1:
            ok = False
    say("(1) summation by parts, 200 random prefix-free sets, exact rationals: %s" % ok)
    return ok


def part2a():
    say("(2a) toy language <n>_delta y: excess e(n) = len_delta(n); partial sums of 2^-e*(n)")
    s = 0.0
    emax = 0
    ok = True
    for n in range(1, 2 ** 16 + 1):
        emax = max(emax, elias_delta_len(n))
        s += 2.0 ** (-emax)
        if s > 2:
            ok = False
        if n in (1, 2, 4, 16, 256, 4096, 65536):
            say("    n = %6d: e*(n) = %2d, sum_{m<=n} 2^-e*(m) = %.6f" % (n, emax, s))
    say("    sum stays <= 2: %s" % ok)
    return ok


def part2b(rng):
    """Greedy families: programs are (prefix-free codeword, infinite label sequence) pairs.  Assign to each
    finite y (|y| <= NMAX) the shortest program whose label sequence extends y; e(n) = max_y len - n."""
    NMAX = 10
    ok = True
    worst = -1.0
    for trial in range(30):
        # programs: codewords from a random complete prefix code (Kraft sum 1), each with a random label sequence;
        # add enough programs so that every y of length <= NMAX is covered: one program per y of length NMAX
        # (label sequence = y), plus random extra programs.
        lab = {}
        ys = [format(i, '0%db' % NMAX) for i in range(2 ** NMAX)]
        extra = rng.randrange(0, 200)
        seqs = ys + [''.join(rng.choice('01') for _ in range(NMAX)) for _ in range(extra)]
        rng.shuffle(seqs)
        # prefix-free code with lengths from a random Kraft-feasible choice: Shannon-style lengths
        weights = [rng.random() ** 3 + 1e-6 for _ in seqs]
        tot = sum(weights)
        lengths = [max(1, -floor(log2(w / tot))) for w in weights]   # sum 2^-len <= 1
        assert sum(2.0 ** (-L) for L in lengths) <= 1 + 1e-12
        e = []
        for n in range(1, NMAX + 1):
            best = {}
            for seq, L in zip(seqs, lengths):
                y = seq[:n]
                if y not in best or L < best[y]:
                    best[y] = L
            assert len(best) == 2 ** n
            e.append(max(best.values()) - n)
        es, m = [], -10 ** 9
        for v in e:
            m = max(m, v)
            es.append(m)
        ssum = sum(2.0 ** (-v) for v in es)
        worst = max(worst, ssum)
        if ssum > 2 + 1e-12:
            ok = False
    say("(2b) 30 random prefix-free families covering all y of length <= 10: max over families of")
    say("     sum_{n<=10} 2^-e*(n) = %.4f (claim: <= 2): %s" % (worst, ok))
    return ok


def part3():
    bad = [n for n in range(4, 2 ** 20) if not elias_delta_len(n) > log2(n) + log2(log2(n))]
    say("(3) len_delta(n) > log n + log log n for all 4 <= n < 2^20: %s (exceptions: %d)" % (not bad, len(bad)))
    return not bad


if __name__ == "__main__":
    rng = random.Random(20261014)
    a = part1(rng)
    b = part2a()
    c = part2b(rng)
    d = part3()
    say("")
    say("ALL CHECKS PASSED" if (a and b and c and d) else "SOME CHECK FAILED")
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write('\n'.join(OUT) + '\n')

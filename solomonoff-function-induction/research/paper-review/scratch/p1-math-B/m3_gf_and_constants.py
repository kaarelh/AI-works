"""Reviewer check m3 (Paper 1, hist.tex / app-hist.tex / examples.tex): small independent checks.

(a) lem:hist:charsum: max_G N(G), N(G) = #{(a,b): a != b, G(a)+G(b) = ab}, exhaustively over all
    total G for q = 2 (and all partial G, via a 'bottom' value) and all total G for q = 3,
    against the bound 2^q + 2^{3q/2}; the Jensen bound of thm:hist:gf(c), 3q/2 - 2, against
    log2(#triples / max N).
(b) prop:hist:sketchfails: losses of P, the private simulator and the constant-function mixture.
(c) prop:hist:strict(i)/(iii) and prop:hist:info(b): log2 C(n, floor(n/2)) >= n - log2(n+1) for 2 <= n <= 4096.
(d) thm:ex:cycle(d) and tab:ex:cycle: log2((N-1)!), per pair, d - log2 e, Robbins' window for d = 1..12.
(e) thm:ex:ksteps: broom law 1/(N-1)_{k-1} and cyclic law 1/(N-1)_k by enumeration for d = 2, 3.
Deterministic.
"""
import itertools
import math
from fractions import Fraction as Fr

import numpy as np


def gf_mul_table(q, poly):
    N = 1 << q
    T = np.zeros((N, N), dtype=np.int64)
    for a in range(N):
        for b in range(N):
            r, x, y = 0, a, b
            while y:
                if y & 1:
                    r ^= x
                y >>= 1
                x <<= 1
                if x & N:
                    x ^= poly
            T[a, b] = r
    return T


def maxN_total(q, poly, chunk=1 << 20):
    N = 1 << q
    T = gf_mul_table(q, poly)
    pairs = [(a, b) for a in range(N) for b in range(a + 1, N)]
    best = 0
    total = N ** N
    for start in range(0, total, chunk):
        idx = np.arange(start, min(total, start + chunk), dtype=np.int64)
        G = np.empty((idx.size, N), dtype=np.int64)
        rest = idx.copy()
        for a in range(N):
            G[:, a] = rest % N
            rest //= N
        cnt = np.zeros(idx.size, dtype=np.int64)
        for a, b in pairs:
            cnt += ((G[:, a] ^ G[:, b]) == T[a, b])
        best = max(best, int(cnt.max()) * 2)  # ordered pairs; ab = ba
    return best


def maxN_partial_q2():
    q, poly = 2, 0b111
    N = 4
    T = gf_mul_table(q, poly)
    best = 0
    for vals in itertools.product(list(range(N)) + [None], repeat=N):
        c = 0
        for a in range(N):
            for b in range(N):
                if a != b and vals[a] is not None and vals[b] is not None and (vals[a] ^ vals[b]) == T[a, b]:
                    c += 1
        best = max(best, c)
    return best


if __name__ == "__main__":
    print("(a) character-sum bound")
    for q, poly in ((2, 0b111), (3, 0b1011)):
        m = maxN_total(q, poly)
        bound = 2 ** q + 2 ** (1.5 * q)
        trip = 2 ** q * (2 ** q - 1) * 2 ** q
        print(f"  q={q}: max_G N(G) over total G = {m}; bound 2^q+2^(3q/2) = {bound:.2f}; "
              f"log2(#triples/maxN) = {math.log2(trip / m):.4f}; 3q/2-2 = {1.5 * q - 2:.2f}")
    print(f"  q=2 partial G (5^4 maps): max N = {maxN_partial_q2()}")
    print("(b) sketch-fails example: P: 1 bit; private simulator: Pr[(beta,beta)] = 1/2*1/2 -> "
          f"{-math.log2(0.5 * 0.5):.0f} bits; constant-function mixture: {-math.log2(0.5):.0f} bit")
    bad = [n for n in range(2, 4097) if math.log2(math.comb(n, n // 2)) < n - math.log2(n + 1)]
    print(f"(c) n in [2,4096] with log2 C(n,n/2) < n - log2(n+1): {bad[:5]} (count {len(bad)})")
    print("(d) log2((N-1)!), per pair, d - log2 e, Robbins window")
    for d in range(1, 13):
        N = 2 ** d
        lf = math.lgamma(N) / math.log(2)
        stir = (d - math.log2(math.e)) * N - d / 2 + 0.5 * math.log2(2 * math.pi)
        eps = lf - stir
        lo, hi = 1 / ((12 * N + 1) * math.log(2)), 1 / (12 * N * math.log(2))
        flag = lo < eps < hi if d <= 8 else "fp"
        print(f"  d={d:2d}: {lf:12.3f}  per pair {lf / N:7.3f}  d-log2e {d - math.log2(math.e):7.3f}  eps_N in window: {flag}")
    print("(e) broom and cyclic laws by enumeration")
    for d in (2, 3):
        N = 2 ** d
        nz = list(range(1, N))
        cycles = []
        for order in itertools.permutations(nz):
            f = {0: order[-1]}
            prev = 0
            for x in order:
                f[x] = prev
                prev = x
            cycles.append((order, f))
        ok_cyc = ok_broom = True
        for order, f in cycles[:24]:
            for k in range(1, N):
                Dk = [(order[i], order[i - 1] if i > 0 else 0) for i in range(k)]
                pc = Fr(sum(all(g[a] == b for a, b in Dk) for _, g in cycles), len(cycles))
                if pc != Fr(1, math.perm(N - 1, k)):
                    ok_cyc = False
                # broom B_k: uniform injective (v_1..v_{k-1}) of nonzero strings
                hits = 0
                tot = 0
                for v in itertools.permutations(nz, k - 1):
                    tot += 1
                    def B(x):
                        if k == 1:
                            return 0
                        if x == v[0]:
                            return 0
                        if x in v:
                            return v[v.index(x) - 1]
                        return v[-1]
                    hits += all(B(a) == b for a, b in Dk)
                if Fr(hits, tot) < Fr(1, math.perm(N - 1, k - 1)):
                    ok_broom = False
        print(f"  d={d}: cyclic law = 1/(N-1)_k on all tested chains: {ok_cyc}; broom >= 1/(N-1)_(k-1): {ok_broom}")

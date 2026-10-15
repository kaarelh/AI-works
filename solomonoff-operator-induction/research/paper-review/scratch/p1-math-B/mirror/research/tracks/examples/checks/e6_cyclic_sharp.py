"""e6: Haenni's cyclic-permutation example (H5), checks for the revision (notes-final.md §2).

Strings of length n are integers 0..N-1 (N = 2^n), with 0 = 0^n.  The revealed chain after k
steps is D_k = {(x_1,0),(x_2,x_1),...,(x_k,x_{k-1})} for an ordering x_1..x_{N-1} of the
nonzero strings.

(a) Component laws, exhaustively for n = 2 (all 6 orderings) and n = 3 (4 seeded orderings),
    by enumerating each law's finite randomness:
      cyclic law       : uniform cyclic permutation of {0..N-1};
      broom B_j        : uniform injective (v_1..v_{j-1}) of nonzero strings;
                         v_1 -> 0, v_i -> v_{i-1}, every other input -> v_{j-1} (B_1: all -> 0);
      partial chain P_j: uniform injective (v_1..v_j); v_1 -> 0, v_i -> v_{i-1}, undefined elsewhere.
    Checked against closed forms: nu(D_k) and the normaliser sum_y nu(D_{t-1}+(x_t,y)).
(b) Depth-count lemma |A_k(F)| <= N-k: exhaustive over all 625 partial functions for n = 2
    and all 8^8 total functions for n = 3 (numpy, chunked); 10^5 seeded random partial
    functions for n = 3, 4.  Also reports the maximum and whether N-k is attained.
(c) Old (notes.md Thm 2.3) and new (notes-final Thm 2.3) k-step bounds at n = 64, mpmath.
    K(k) is replaced by the proxy log2(k+1) + 2 log2 log2(k+2) (constants omitted).
(d) Robbins window for log2((N-1)!) at 120 digits, n = 1..24, 32, 40, 64.
(e) Order-free proxy with brooms, and a normalised proxy with partial chains: per-step
    check of the proxy form of Prop 2.9, l_t >= log2(N-t+1) + log2 w^B_{t-1}, and the
    normalised loss over the full cycle against log2((N-1)!).
(f) SI illustration (Prop 2.10 vs Prop 2.6): exact block-level label loss of a Bayes mixture
    of the true processes mu_m (m = 1..10) and a uniform-bits null model, on the interleaved
    history with the prefix code s -> 1^{|s|} 0 s and with raw n-bit blocks.

Seed 20261012.  Output: e6_cyclic_sharp.out.txt next to this file.
"""
import itertools
import math
import os
import time
from fractions import Fraction

import numpy as np
import mpmath as mp

HERE = os.path.dirname(os.path.abspath(__file__))
OUTFILE = os.path.join(HERE, "e6_cyclic_sharp.out.txt")
OUT = []
SEED = 20261012


def say(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


def falling(a, k):
    r = 1
    for i in range(k):
        r *= (a - i)
    return r


# ----------------------------------------------------------------------------------------
# (a) component laws by enumeration
# ----------------------------------------------------------------------------------------

def cyclic_realisations(N):
    """All cyclic permutations of {0..N-1}, as tuples f[x]."""
    out = []
    for perm in itertools.permutations(range(1, N)):
        cyc = (0,) + perm          # cycle 0 -> perm[0] -> ... -> perm[-1] -> 0 (as successor list)
        f = [None] * N
        for i in range(N):
            f[cyc[i]] = cyc[(i + 1) % N]
        out.append(tuple(f))
    return out


def broom_realisations(N, j):
    out = []
    if j == 1:
        return [tuple([0] * N)]
    for v in itertools.permutations(range(1, N), j - 1):
        f = [v[-1]] * N
        f[v[0]] = 0
        for i in range(1, j - 1):
            f[v[i]] = v[i - 1]
        out.append(tuple(f))
    return out


def partial_chain_realisations(N, j):
    out = []
    for v in itertools.permutations(range(1, N), j):
        f = [None] * N
        f[v[0]] = 0
        for i in range(1, j):
            f[v[i]] = v[i - 1]
        out.append(tuple(f))
    return out


def law(realisations, D):
    """Fraction of realisations extending the data set D (list of (x,y))."""
    cnt = sum(1 for f in realisations if all(f[x] == y for x, y in D))
    return Fraction(cnt, len(realisations))


def defined_mass(realisations, D, x):
    cnt = sum(1 for f in realisations if f[x] is not None and all(f[xx] == y for xx, y in D))
    return Fraction(cnt, len(realisations))


def chain(order, k):
    D = [(order[0], 0)]
    for i in range(1, k):
        D.append((order[i], order[i - 1]))
    return D


def closed_broom(N, j, k):
    if k == 1:
        return Fraction(1) if j == 1 else Fraction(1, N - 1)
    if j == k:
        return Fraction(1, falling(N - 1, k - 1))
    if j > k:
        return Fraction(1, falling(N - 1, k))
    return Fraction(0)


def closed_partial(N, j, k):
    return Fraction(1, falling(N - 1, k)) if j >= k else Fraction(0)


def closed_partial_norm(N, j, t):
    """sum_y P_j(D_{t-1} + (x_t, y)) for 2 <= t <= N-1."""
    if j < t:
        return Fraction(0)
    return Fraction(j - t + 1, (N - t) * falling(N - 1, t - 1))


def part_a(rng):
    say("(a) component laws by exhaustive enumeration of their randomness (exact rationals)")
    for n in (2, 3):
        N = 2 ** n
        nz = list(range(1, N))
        if n == 2:
            orders = list(itertools.permutations(nz))
        else:
            orders = [tuple(rng.permutation(nz).tolist()) for _ in range(4)]
        cyc = cyclic_realisations(N)
        brooms = {j: broom_realisations(N, j) for j in range(1, N)}
        partials = {j: partial_chain_realisations(N, j) for j in range(1, N)}
        n_checks = 0
        n_bad = 0
        for order in orders:
            for k in range(1, N):
                D = chain(order, k)
                # cyclic
                n_checks += 1
                if law(cyc, D) != Fraction(1, falling(N - 1, k)):
                    n_bad += 1
                for j in range(1, N):
                    n_checks += 2
                    if law(brooms[j], D) != closed_broom(N, j, k):
                        n_bad += 1
                    if law(partials[j], D) != closed_partial(N, j, k):
                        n_bad += 1
            # normalisers at x_t, 2 <= t <= N-1
            for t in range(2, N):
                Dprev = chain(order, t - 1)
                x = order[t - 1]
                n_checks += 1
                if defined_mass(cyc, Dprev, x) != Fraction(1, falling(N - 1, t - 1)):
                    n_bad += 1
                for j in range(1, N):
                    n_checks += 2
                    if defined_mass(brooms[j], Dprev, x) != closed_broom(N, j, t - 1):
                        n_bad += 1
                    if defined_mass(partials[j], Dprev, x) != closed_partial_norm(N, j, t):
                        n_bad += 1
            # the full cycle D_N: last pair (0, x_{N-1})
            DN = chain(order, N - 1) + [(0, order[N - 2])]
            n_checks += 1
            if law(cyc, DN) != Fraction(1, math.factorial(N - 1)):
                n_bad += 1
            for j in range(1, N):
                n_checks += 2
                if law(brooms[j], DN) != 0 or law(partials[j], DN) != 0:
                    n_bad += 1
        say(f"   n={n}: {len(orders)} orderings, {n_checks} exact comparisons with the closed forms, mismatches: {n_bad}")
    say("   closed forms: cyclic 1/(N-1)_k; broom B_j: 1/(N-1)_{k-1} if j=k, 1/(N-1)_k if j>k, 0 if j<k (k>=2);")
    say("   partial chain P_j: 1/(N-1)_k if j>=k; normaliser of P_j at x_t: (j-t+1)/((N-t)(N-1)_{t-1}) for j>=t.")
    say("   example n=3, k=4: broom B_4 gives 1/" + str(falling(7, 3)) + ", cyclic law 1/" + str(falling(7, 4)))


# ----------------------------------------------------------------------------------------
# (b) depth-count lemma
# ----------------------------------------------------------------------------------------

def depth_counts_partial(F, N):
    """F: tuple of length N with values in 0..N-1 or -1 (undefined). Returns counts c[k] = |A_k(F)|."""
    c = [0] * (N + 1)
    for x in range(1, N):
        y = x
        for k in range(1, N + 1):
            y = F[y]
            if y < 0:
                break
            if y == 0:
                c[k] += 1
                break
    return c


def part_b(rng):
    say("")
    say("(b) depth-count lemma |A_k(F)| <= N - k")
    # n = 2, all partial functions
    N = 4
    best = [0] * (N + 1)
    total = 0
    for F in itertools.product(range(-1, N), repeat=N):
        c = depth_counts_partial(F, N)
        total += 1
        for k in range(1, N):
            best[k] = max(best[k], c[k])
    say(f"   n=2: all {total} partial functions; max |A_k| for k=1..3: {best[1:N]}; bound N-k: {[N-k for k in range(1, N)]}")
    # n = 3, all total functions (8^8), vectorised
    N = 8
    t0 = time.time()
    best = np.zeros(N + 1, dtype=np.int64)
    viol = 0
    base = np.array(list(itertools.product(range(N), repeat=6)), dtype=np.int8)   # last 6 coordinates
    for a in range(N):
        for b in range(N):
            F = np.empty((base.shape[0], N), dtype=np.int8)
            F[:, 0] = a
            F[:, 1] = b
            F[:, 2:] = base
            rows = np.arange(F.shape[0])
            counts = np.zeros((F.shape[0], N + 1), dtype=np.int64)
            for x in range(1, N):
                y = np.full(F.shape[0], x, dtype=np.int64)
                hit = np.zeros(F.shape[0], dtype=np.int64)
                for k in range(1, N + 1):
                    y = F[rows, y].astype(np.int64)
                    newly = (hit == 0) & (y == 0)
                    hit[newly] = k
                for k in range(1, N):
                    counts[:, k] += (hit == k)
            mx = counts.max(axis=0)
            best = np.maximum(best, mx)
            for k in range(1, N):
                viol += int((counts[:, k] > N - k).sum())
    say(f"   n=3: all 8^8 = {8**8} total functions; max |A_k| for k=1..7: {best[1:N].tolist()}; "
        f"bound N-k: {[N-k for k in range(1, N)]}; violations: {viol}  ({time.time()-t0:.0f} s)")
    # random partial functions, n = 3, 4
    for n in (3, 4):
        N = 2 ** n
        best = [0] * (N + 1)
        viol = 0
        for _ in range(100000):
            F = tuple(int(v) for v in rng.integers(-1, N, size=N))
            c = depth_counts_partial(F, N)
            for k in range(1, N):
                best[k] = max(best[k], c[k])
                if c[k] > N - k:
                    viol += 1
        say(f"   n={n}: 100000 random partial functions (values uniform on undefined/0..N-1); "
            f"max |A_k|, k=1..{N-1}: {best[1:N]}; violations: {viol}")
    say("   (the broom with its spine realised attains N-k for every k: its A_k is every input outside v_1..v_{k-1})")
    # verify attainment by brooms explicitly
    for n in (2, 3, 4):
        N = 2 ** n
        ok = True
        for k in range(1, N):
            v = list(range(1, k))   # v_1..v_{k-1}
            F = [v[-1] if v else 0] * N
            if v:
                F[v[0]] = 0
                for i in range(1, len(v)):
                    F[v[i]] = v[i - 1]
            c = depth_counts_partial(tuple(F), N)
            ok &= (c[k] == N - k)
        say(f"   n={n}: broom attains |A_k| = N-k for all k: {ok}")


# ----------------------------------------------------------------------------------------
# (c) bounds at n = 64
# ----------------------------------------------------------------------------------------

def part_c():
    say("")
    say("(c) k-step bounds at n = 64 (mpmath, 60 digits); Kproxy(k) := log2(k+1) + 2 log2 log2(k+2); constants c omitted")
    mp.mp.dps = 60
    n = 64
    N = mp.mpf(2) ** n

    def lf(a, k):     # log2 falling factorial (a)_k
        return (mp.loggamma(a + 1) - mp.loggamma(a - k + 1)) / mp.log(2)

    say("        k | log2(N-1)_k        | old upper - new upper | old gap (upper-lower) | new gap (upper-lower)")
    for k in [1, 2, 64, 1000, 2 ** 20, 2 ** 32, 2 ** 63, int(N) - 1]:
        k = mp.mpf(k)
        fk = lf(N - 1, k)
        fk1 = lf(N - 1, k - 1)
        kp = mp.log(k + 1, 2) + 2 * mp.log(mp.log(k + 2, 2), 2)
        old_up = fk - max(mp.mpf(0), mp.log(N - k, 2) - k)
        old_lo = fk - mp.log(N - 1, 2)
        new_up = fk1 + min(kp, mp.log(N - k, 2), k)
        new_lo = fk1
        say(f"   {mp.nstr(k, 6):>8} | {mp.nstr(fk, 12):>18} | {mp.nstr(old_up - new_up, 6):>21} | "
            f"{mp.nstr(old_up - old_lo, 6):>21} | {mp.nstr(new_up - new_lo, 6):>21}")
    say("   (at k = 64 the new upper bound lies log2(N-64) - Kproxy(64) = 52.8 bits below the old one, up to c;")
    say("    the old gap between upper and lower bound is about min(n, k) bits, the new one min(Kproxy(k), log2(N-k)))")


# ----------------------------------------------------------------------------------------
# (d) Robbins window
# ----------------------------------------------------------------------------------------

def part_d():
    say("")
    say("(d) eps_N := log2((N-1)!) - [(n - log2 e) N - n/2 + log2(2 pi)/2]; Robbins: 1/((12N+1) ln2) < eps_N < 1/(12 N ln2)")
    mp.mp.dps = 120
    allok = True
    say("    n |  eps_N             1/(12N ln2)        1/((12N+1)ln2)    window holds")
    for n in list(range(1, 25)) + [32, 40, 64]:
        N = mp.mpf(2) ** n
        exact = mp.loggamma(N) / mp.log(2)
        stir = (n - mp.log(mp.e, 2)) * N - mp.mpf(n) / 2 + mp.log(2 * mp.pi, 2) / 2
        eps = exact - stir
        hi = 1 / (12 * N * mp.log(2))
        lo = 1 / ((12 * N + 1) * mp.log(2))
        ok = (lo < eps < hi)
        allok &= ok
        if n <= 4 or n in (10, 16, 17, 18, 20, 24, 32, 40, 64):
            say(f"   {n:2d} | {mp.nstr(eps, 6):>16}  {mp.nstr(hi, 6):>16}  {mp.nstr(lo, 6):>16}   {ok}")
    say(f"   window holds for every n tested: {allok}")
    say("   (notes.md and e3 said 'the Stirling error equals 1/(12N ln2) to the printed precision for n<=24':")
    say("    false at n = 1, 2, and e3's double-precision column is rounding noise for n >= 17; see the rows above)")


# ----------------------------------------------------------------------------------------
# (e) proxies: order-free with brooms, normalised with partial chains
# ----------------------------------------------------------------------------------------

def lfall(a, k):
    return (math.lgamma(a + 1) - math.lgamma(a - k + 1)) / math.log(2)


def proxy_losses(n, w_cyc, wB, u):
    """Closed-form per-step quantities on a revealed chain (all chains give the same values).

    Mixture: w_cyc * cyclic + sum_j wB[j] * B_j + sum_j u[j] * P_j  (j = 1..N-1; total weight <= 1).
    Returns arrays over t = 1..N of semimeasure log-mass log2 nu(D_t) and normalised step losses.
    Computed in log2 space with exact closed forms (validated in (a) for n = 2, 3)."""
    N = 2 ** n
    J = np.arange(1, N)

    def lognu(k):          # log2 nu(D_k), 1 <= k <= N-1
        terms = [math.log2(w_cyc) - lfall(N - 1, k)] if w_cyc > 0 else []
        for j in J:
            if wB[j] > 0:
                if k == 1:
                    terms.append(math.log2(wB[j]) + (0.0 if j == 1 else -math.log2(N - 1)))
                elif j == k:
                    terms.append(math.log2(wB[j]) - lfall(N - 1, k - 1))
                elif j > k:
                    terms.append(math.log2(wB[j]) - lfall(N - 1, k))
            if u[j] > 0 and j >= k:
                terms.append(math.log2(u[j]) - lfall(N - 1, k))
        return lse(terms)

    def lognorm(t):        # log2 sum_y nu(D_{t-1} + (x_t, y)), 2 <= t <= N-1
        terms = [math.log2(w_cyc) - lfall(N - 1, t - 1)] if w_cyc > 0 else []
        for j in J:
            if wB[j] > 0:
                k = t - 1
                if k == 1:
                    terms.append(math.log2(wB[j]) + (0.0 if j == 1 else -math.log2(N - 1)))
                elif j == k:
                    terms.append(math.log2(wB[j]) - lfall(N - 1, k - 1))
                elif j > k:
                    terms.append(math.log2(wB[j]) - lfall(N - 1, k))
            if u[j] > 0 and j >= t:
                terms.append(math.log2(u[j]) + math.log2(j - t + 1) - math.log2(N - t) - lfall(N - 1, t - 1))
        return lse(terms)

    semi = np.zeros(N + 1)
    norm_step = np.zeros(N + 1)
    for t in range(1, N):
        semi[t] = lognu(t)
    # last step: D_N; only the cyclic law extends it; normaliser: cyclic + broom B_{N-1} (total)
    semi[N] = math.log2(w_cyc) - math.lgamma(N) / math.log(2)
    # normalised steps
    S1 = lse(([math.log2(w_cyc)] if w_cyc > 0 else []) + [math.log2(wB[j]) for j in J if wB[j] > 0] +
             [math.log2(u[j]) + math.log2(j / (N - 1)) for j in J if u[j] > 0])
    norm_step[1] = -(semi[1] - S1)
    for t in range(2, N):
        norm_step[t] = -(semi[t] - lognorm(t))
    SN = lse([math.log2(w_cyc) - math.lgamma(N) / math.log(2)] +
             ([math.log2(wB[N - 1]) - lfall(N - 1, N - 2)] if wB[N - 1] > 0 else []))
    norm_step[N] = -(semi[N] - SN)
    return semi, norm_step


def lse(xs):
    xs = [x for x in xs if x > -math.inf]
    if not xs:
        return -math.inf
    m = max(xs)
    return m + math.log2(sum(2.0 ** (x - m) for x in xs))


def part_e():
    say("")
    say("(e) proxies (closed forms validated in (a)); all chains give the same values, so these are exact for every f")
    say("   order-free proxy: w_cyc = 1/2; brooms: wB_j = (1/4)/(j(j+1)) for every j, plus (1/4)/(i(i+1)) more at j = 2^i")
    say("   (the second family imitates K(k) being small for simple k such as powers of two); no partial chains.")
    say("   For each k the loss is about the cheaper of two routes: cyclic law, log2(N-k) + log2(1/w_cyc) above")
    say("   log2(N-1)_{k-1}; broom B_k, log2(1/wB_k) above it.  Thm 2.3(1): min{K(k), log2(N-k)} + c.")
    say("    n |    k   | -log2 nu(D_k) | log2(N-1)_{k-1} | excess  | cyclic route | broom route")
    for n in (4, 6, 8, 10, 12):
        N = 2 ** n
        wB = np.zeros(N)
        for j in range(1, N - 1):
            wB[j] = 0.25 / (j * (j + 1))
        wB[N - 1] = 0.25 - wB[1:N - 1].sum()
        i = 1
        while 2 ** i <= N - 1:
            wB[2 ** i] += 0.25 / (i * (i + 1))
            i += 1
        u = np.zeros(N)
        semi, _ = proxy_losses(n, 0.5, wB, u)
        for k in (1, N // 3, N // 2, N - 1):
            L = -semi[k]
            say(f"   {n:2d} | {k:6d} | {L:13.3f} | {lfall(N-1, k-1):15.3f} | {L - lfall(N-1, k-1):7.3f} | "
                f"{math.log2(N - k) + 1:12.3f} | {-math.log2(wB[k]):11.3f}")
    say("   (at k = N/3 the broom is expensive in this prior and the cyclic route wins; at k = N/2 = 2^(n-1) the broom")
    say("    route costs 2 + log2(n(n-1)) bits against n for the cyclic route, so it wins from n = 8 on (by 3.0 bits at")
    say("    n = 12). SFI has K(N/2) <= K(n) + c, so for SFI the old e3 proxy, which has no broom, overstates the")
    say("    k = N/2 cost by n - O(log n) bits)")
    say("")
    say("   normalised proxy: weights (w_cyc, broom total, partial-chain total); brooms wB_j ∝ 1/(j(j+1)),")
    say("   partial chains u_j ∝ 2^{-j}.  Check of the proxy form of Prop 2.9 at every 2 <= t <= N-1:")
    say("   normalised step loss l_t >= log2(N-t+1) + log2 wB_{t-1}.")
    say("    n | weights            | min_t [l_t - log2(N-t+1) - log2 wB_{t-1}] | normalised loss, full cycle | semimeasure loss | log2((N-1)!)")
    for n in (3, 4, 6, 8, 10):
        N = 2 ** n
        for (wc, bt, pt) in [(0.5, 0.5, 0.0), (0.02, 0.02, 0.96), (0.001, 0.001, 0.998)]:
            wB = np.zeros(N)
            raw = np.array([0.0] + [1.0 / (j * (j + 1)) for j in range(1, N)])
            wB[1:] = bt * raw[1:] / raw[1:].sum()
            u = np.zeros(N)
            rawu = np.array([0.0] + [2.0 ** (-j) for j in range(1, N)])
            if pt > 0:
                u[1:] = pt * rawu[1:] / rawu[1:].sum()
            semi, ns = proxy_losses(n, wc, wB, u)
            margins = [ns[t] - (math.log2(N - t + 1) + math.log2(wB[t - 1])) for t in range(2, N)]
            say(f"   {n:2d} | ({wc:.3f},{bt:.3f},{pt:.3f}) | {min(margins):40.4f} | {ns[1:].sum():27.3f} | "
                f"{-semi[N]:16.3f} | {math.lgamma(N)/math.log(2):12.3f}")
    say("   (normalised loss below log2((N-1)!) shows that the order-free lower bound does not transfer to the")
    say("    normalised predictor without an argument; Prop 2.9 still holds step by step in every case)")


# ----------------------------------------------------------------------------------------
# (f) SI: prefix code vs raw blocks
# ----------------------------------------------------------------------------------------

class Mu:
    """True process mu_m on block sequences x_1 y_1 x_2 y_2 ... (m-bit blocks), continued after
    step 2^m by uniform bits.  Gives the probability of a binary prefix under either encoding."""

    def __init__(self, m, code):
        self.m = m
        self.code = code   # 'prefix' or 'raw'

    def log2prob(self, bits):
        """log2 mu_m(the encoded sequence starts with `bits`)."""
        m = self.m
        Nm = 2 ** m
        pos = 0
        lp = 0.0
        used = set()
        prev = 0           # previous input (label of the next one); y_1 = 0^m
        t = 0
        L = len(bits)
        while pos < L:
            t += 1
            is_x_block = True
            for blk in range(2):
                if pos >= L:
                    return lp
                if t > Nm:           # after the cycle: uniform bits
                    return lp - (L - pos)
                if self.code == 'prefix':
                    # header 1^m 0
                    hdr = '1' * m + '0'
                    seg = bits[pos:pos + len(hdr)]
                    if seg != hdr[:len(seg)]:
                        return -math.inf
                    pos += len(seg)
                    if pos >= L:
                        return lp
                seg = bits[pos:pos + m]
                if blk == 0:
                    # input block: uniform over unused nonzero strings (t <= Nm-1), or 0^m at t = Nm
                    if t < Nm:
                        cands = [v for v in range(1, Nm) if v not in used]
                    else:
                        cands = [0]
                    if len(seg) < m:
                        ok = [v for v in cands if format(v, f'0{m}b').startswith(seg)]
                        if not ok:
                            return -math.inf
                        return lp + math.log2(len(ok) / len(cands))
                    v = int(seg, 2)
                    if v not in cands:
                        return -math.inf
                    lp += -math.log2(len(cands))
                    used.add(v)
                    cur = v
                    pos += m
                else:
                    want = format(prev, f'0{m}b')
                    if not want.startswith(seg):
                        return -math.inf
                    if len(seg) < m:
                        return lp
                    pos += m
                    prev = cur
        return lp


def si_label_loss(order, n, code, models, w, w_null):
    """Block-level label loss sum_t -log2 rho(c(h_{t-1}) x_t y_t) / rho(c(h_{t-1}) x_t) for the mixture
    rho = sum_m w_m mu_m + w_null * uniform bits."""
    N = 2 ** n
    xs = list(order) + [0]
    ys = [0] + list(order)
    enc = (lambda s: '1' * len(s) + '0' + s) if code == 'prefix' else (lambda s: s)
    hist = ''
    total = 0.0
    for t in range(N):
        xb = enc(format(xs[t], f'0{n}b'))
        yb = enc(format(ys[t], f'0{n}b'))
        a = hist + xb
        b = a + yb
        la = lse([math.log2(w[i]) + mu.log2prob(a) for i, mu in enumerate(models)] + [math.log2(w_null) - len(a)])
        lb = lse([math.log2(w[i]) + mu.log2prob(b) for i, mu in enumerate(models)] + [math.log2(w_null) - len(b)])
        total += la - lb
        hist = b
    return total


def part_f(rng):
    say("")
    say("(f) SI illustration: exact block-level label loss over the full cycle of a Bayes mixture of mu_m (m = 1..10,")
    say("    weight (3/4)/(m(m+1)) normalised) and a uniform-bits null model (weight 1/4); 3 seeded permutations per n")
    say("    n | prefix code s -> 1^|s| 0 s : label loss (3 runs) | raw n-bit blocks: label loss (3 runs)")
    ms = list(range(1, 11))
    raw = np.array([1.0 / (m * (m + 1)) for m in ms])
    w = 0.75 * raw / raw.sum()
    for n in range(2, 7):
        N = 2 ** n
        res = {'prefix': [], 'raw': []}
        for _ in range(3):
            order = rng.permutation(np.arange(1, N)).tolist()
            for code in ('prefix', 'raw'):
                models = [Mu(m, code) for m in ms]
                res[code].append(si_label_loss(order, n, code, models, w, 0.25))
        say(f"   {n:2d} | {', '.join(f'{v:7.4f}' for v in res['prefix']):>44} | {', '.join(f'{v:7.4f}' for v in res['raw'])}")
    say("   (prefix code: once the header 1^n 0 of x_1 is read only mu_n and the null model remain, and the labels")
    say("    cost only the null model's residual weight; raw blocks: the first label must resolve where blocks end)")


def main():
    t0 = time.time()
    rng = np.random.default_rng(SEED)
    say(f"e6_cyclic_sharp.py  seed={SEED}")
    say("")
    part_a(rng)
    part_b(rng)
    part_c()
    part_d()
    part_e()
    part_f(rng)
    say("")
    say(f"runtime {time.time() - t0:.0f} s")
    with open(OUTFILE, "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()

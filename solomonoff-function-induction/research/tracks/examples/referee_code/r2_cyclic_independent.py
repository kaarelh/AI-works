"""r2: independent checks of Haenni's cyclic-permutation example (examples track, notes section 2).

(a) The referee's "broom law" b_k: a uniformly random injective path v_1..v_{k-1} of nonzero
    strings, F(v_1) = 0^n, F(v_i) = v_{i-1}, every other nonzero string -> v_{k-1}.
    Claim: b_k(D_k) = 1/(N-1)_{k-1} for every chain D_k of length k (exhaustive, n = 2, 3).
    Consequence: L_SFI(D_k) <= log2 (N-1)_{k-1} + K(k) + c, matching the lower bound of (b).
    Also the "block law" nu_k: a uniformly random ordering w_1..w_{N-1} of the nonzero
    n-bit strings is cut into consecutive blocks of length k; inside a block
    w_{jk+1} -> w_{jk+2} -> ... -> w_{jk+k} -> 0^n (a leftover short block likewise).
    Claim: nu_k(D_k) = floor((N-1)/k) / (N-1)_k for every chain D_k of length k.
    Exhaustive over all orderings for n = 2, 3 (and all k).  Consequence (with (F1) and
    K(nu_k) <= K(k) + c):  L_SFI(D_k) <= log2 (N-1)_k - log2 floor((N-1)/k) + K(k) + c,
    which beats Thm 2.3(1) by about n - 2 log2 k bits and answers open problem 3 (no).
(b) Depth-count lemma used for the matching lower bound: for every (partial) function F on
    {0,1}^n, the number of nonzero x whose F-orbit stays in {0,1}^n \\ {0^n} for k-1 steps and
    then hits 0^n is at most N - k.  Exhaustive for n = 2 (all 625 partial functions) and
    n = 3 (all 8^8 total functions, vectorised); attained.
(c) Thm 2.3(1), second term: the law T' (private coin per input: 0^n, or pi(x) for a shared
    uniform cyclic pi) has nu_T'(D_k) >= 2^-k / (N-1)_{k-1}.  Exact for n = 2, 3.
(d) Weak semimeasures, N = 4 (n = 2), labels {0,1,2,3}: LP maximum of sum_z nu(D(x,z)) over
    all weak function semimeasures (expected 1: Prop 2.4(1) extends to weak semimeasures),
    and of sum_{x, |z|=k-1} nu(D(x,z)) (compare N-1 and N-k).
(e) Robbins / Stirling constants of Thm 2.1(4) with 100-digit arithmetic, n = 1..64, and the
    double-precision artefact in e3(a).
(f) Normalised vs semimeasure convention on H5: a partial law nu_geo (random ordering, defined
    on a geometric number of chain positions) has normalised loss 1 bit/step but semimeasure
    loss ~ n bits/step; mixed half/half with the cyclic law, the normalised loss is ~ n
    bits/step again.  Exact formulas, n = 10.
(g) Table: the track's k-step bounds vs the referee's sharpened bounds (constants c omitted).

Deterministic except (b)'s sampling of partial functions for n = 3 (seed 20261011).
Output: r2_cyclic_independent_output.txt
"""
import itertools
import math
import os

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []


def say(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


def falling(a, k):
    return math.prod(range(a - k + 1, a + 1)) if k > 0 else 1


def lg_falling(a, k):
    """log2 of the falling factorial (a)_k, in 80-digit arithmetic (float lgamma cancels for a ~ 2^64)."""
    import mpmath as mp
    with mp.workdps(80):
        return float((mp.loggamma(mp.mpf(a) + 1) - mp.loggamma(mp.mpf(a) - k + 1)) / mp.log(2))


# ---------------------------------------------------------------------------
def part_a():
    say("(a) broom law and block law: exact probability that F extends a fixed chain D_k")
    for n in [2, 3]:
        N = 2 ** n
        nz = list(range(1, N))
        chain = nz[::-1]                 # x_1..x_{N-1}: a fixed ordering; D_k uses x_1..x_k
        for k in range(1, N):
            D = {chain[0]: 0}
            for i in range(1, k):
                D[chain[i]] = chain[i - 1]
            hit = 0
            tot = 0
            for w in itertools.permutations(nz):
                F = {}
                for start in range(0, N - 1, k):
                    blk = w[start:start + k]
                    for a, b in zip(blk, blk[1:]):
                        F[a] = b
                    F[blk[-1]] = 0
                tot += 1
                hit += all(F.get(x) == y for x, y in D.items())
            # broom law: uniform injective path (v_1..v_{k-1}) of nonzero strings, F(v_1)=0,
            # F(v_i)=v_{i-1}, every other nonzero string -> v_{k-1} (-> 0 if k = 1)
            hitb = 0
            totb = 0
            for v in itertools.permutations(nz, k - 1):
                Fb = {}
                if k == 1:
                    for y in nz:
                        Fb[y] = 0
                else:
                    Fb[v[0]] = 0
                    for i in range(1, k - 1):
                        Fb[v[i]] = v[i - 1]
                    for y in nz:
                        if y not in v:
                            Fb[y] = v[-1]
                totb += 1
                hitb += all(Fb.get(x) == y for x, y in D.items())
            say(f"  n={n} k={k}: broom law nu(D_k) = {hitb}/{totb} = {hitb/totb:.6e}; 1/(N-1)_(k-1) = {1/falling(N-1,k-1):.6e}; "
                f"match: {hitb * falling(N - 1, k - 1) == totb}")
            B = (N - 1) // k
            claim = B / falling(N - 1, k)
            say(f"  n={n} k={k}: nu_k(D_k) = {hit}/{tot} = {hit/tot:.6e}; floor((N-1)/k)/(N-1)_k = {claim:.6e}; "
                f"match: {hit * falling(N - 1, k) == B * tot}; cyclic law 1/(N-1)_k = {1/falling(N-1,k):.6e}")


# ---------------------------------------------------------------------------
def depth_counts(F, N, k):
    """number of nonzero x whose orbit stays in nonzero strings for k-1 steps and hits 0 at step k.
    F: dict or list with None for undefined."""
    cnt = 0
    for x in range(1, N):
        cur = x
        ok = True
        for step in range(1, k + 1):
            nxt = F[cur]
            if nxt is None:
                ok = False
                break
            if step < k:
                if nxt == 0:
                    ok = False
                    break
            else:
                if nxt != 0:
                    ok = False
            cur = nxt
        cnt += ok
    return cnt


def part_b():
    say("")
    say("(b) depth-count lemma: max over F of #{x: orbit first hits 0^n at step exactly k, staying in {0,1}^n} <= N-k")
    n, N = 2, 4
    best = {k: 0 for k in range(1, N)}
    for vals in itertools.product([None, 0, 1, 2, 3], repeat=N):
        for k in range(1, N):
            best[k] = max(best[k], depth_counts(list(vals), N, k))
    say(f"  n=2, all 625 partial functions: max counts {best}; N-k = { {k: N-k for k in range(1, N)} }")
    # n = 3: all total functions, vectorised
    n, N = 3, 8
    idx = np.arange(N ** N, dtype=np.int64)
    Fm = np.empty((N ** N, N), dtype=np.int8)
    for j in range(N):
        Fm[:, j] = (idx // (N ** j)) % N
    del idx
    maxc = {}
    first_hit = np.zeros((Fm.shape[0], N), dtype=np.int8)   # first hitting time of 0 (0 = never within N steps)
    for x in range(1, N):
        cur = np.full(Fm.shape[0], x, dtype=np.int8)
        fh = np.zeros(Fm.shape[0], dtype=np.int8)
        for step in range(1, N + 1):
            cur = Fm[np.arange(Fm.shape[0]), cur]
            newly = (cur == 0) & (fh == 0)
            fh[newly] = step
        first_hit[:, x] = fh
    for k in range(1, N):
        c = (first_hit[:, 1:] == k).sum(axis=1)
        maxc[k] = int(c.max())
    say(f"  n=3, all 8^8 = {N**N} total functions: max counts {maxc}; N-k = { {k: N-k for k in range(1, N)} }")
    # partial functions for n = 3: random sample plus brooms
    rng = np.random.default_rng(20261011)
    bestp = {k: 0 for k in range(1, N)}
    for _ in range(20000):
        vals = [None if rng.random() < 0.2 else int(rng.integers(0, N)) for _ in range(N)]
        for k in range(1, N):
            bestp[k] = max(bestp[k], depth_counts(vals, N, k))
    say(f"  n=3, 20000 random partial functions (each value undefined w.p. 0.2): max counts {bestp}")


# ---------------------------------------------------------------------------
def cyclic_perms(N):
    out = []
    for order in itertools.permutations(range(1, N)):
        f = [None] * N
        f[order[0]] = 0
        for i in range(1, N - 1):
            f[order[i]] = order[i - 1]
        f[0] = order[-1]
        out.append(f)
    return out


def part_c():
    say("")
    say("(c) law T' of Thm 2.3(1): nu_T'(D_k) vs 2^-k/(N-1)_{k-1}")
    for n in [2, 3]:
        N = 2 ** n
        cyc = cyclic_perms(N)
        chain = list(range(1, N))[::-1]
        for k in range(1, N):
            D = [(chain[0], 0)] + [(chain[i], chain[i - 1]) for i in range(1, k)]
            # each input independently: zero branch w.p. 1/2 (answers 0), else pi(x)
            tot = 0.0
            for f in cyc:
                p = 1.0
                for x, y in D:
                    pz = 0.5 if y == 0 else 0.0
                    pp = 0.5 if f[x] == y else 0.0
                    p *= pz + pp
                tot += p
            nu = tot / len(cyc)
            bound = 2.0 ** (-k) / falling(N - 1, k - 1)
            say(f"  n={n} k={k}: nu_T'(D_k) = {nu:.6e} >= {bound:.6e}: {nu >= bound * (1 - 1e-12)}")


# ---------------------------------------------------------------------------
def part_d():
    from scipy.optimize import linprog
    say("")
    say("(d) LP over all weak function semimeasures on 4 inputs {0,1,2,3} (0 = 0^n) with labels {0,1,2,3}")
    N = 4
    # data sets = partial functions as tuples with None
    sets = list(itertools.product([None, 0, 1, 2, 3], repeat=N))
    index = {s: i for i, s in enumerate(sets)}
    rows, cols, vals = [], [], []
    r = 0
    for s in sets:
        for x in range(N):
            if s[x] is None:
                # nu(D) - sum_y nu(D+(x,y)) >= 0   ->  -nu(D) + sum_y nu(D+(x,y)) <= 0
                rows.append(r); cols.append(index[s]); vals.append(-1.0)
                for y in range(N):
                    t = list(s); t[x] = y
                    rows.append(r); cols.append(index[tuple(t)]); vals.append(1.0)
                r += 1
    empty = index[tuple([None] * N)]
    rows.append(r); cols.append(empty); vals.append(1.0)
    r += 1
    from scipy.sparse import csr_matrix
    A = csr_matrix((vals, (rows, cols)), shape=(r, len(sets)))
    b = np.zeros(r)
    b[-1] = 1.0

    def chains_from(x, length=None):
        """data sets D(x,z): x -> z1 -> ... -> zj -> 0, z_i distinct nonzero, != x"""
        out = []
        others = [v for v in range(1, N) if v != x]
        for j in range(0, len(others) + 1):
            if length is not None and j != length:
                continue
            for z in itertools.permutations(others, j):
                D = [None] * N
                seq = [x] + list(z)
                for a, bb in zip(seq, seq[1:]):
                    D[a] = bb
                D[seq[-1]] = 0
                out.append(tuple(D))
        return out

    def lpmax(targets):
        c = np.zeros(len(sets))
        for t in targets:
            c[index[t]] -= 1.0
        res = linprog(c, A_ub=A, b_ub=b, bounds=(0, 1), method="highs")
        return -res.fun

    v = lpmax(chains_from(3))
    say(f"  max over weak semimeasures of sum_z nu(D(x=3, z)) = {v:.6f}  (adaptive-tree argument predicts 1)")
    for k in range(1, N):
        targets = []
        for x in range(1, N):
            targets += chains_from(x, length=k - 1)
        v = lpmax(targets)
        say(f"  k={k}: max over weak semimeasures of sum_(x,|z|=k-1) nu(D(x,z)) = {v:.6f}; N-1 = {N-1}; "
            f"bound for random-function laws N-k = {N-k}")


# ---------------------------------------------------------------------------
def part_e():
    import mpmath as mp
    mp.mp.dps = 100
    say("")
    say("(e) log2((N-1)!) - [(n - log2 e) N - n/2 + log2(2 pi)/2] = eps_N; Robbins: 1/((12N+1) ln 2) < eps_N < 1/(12 N ln 2)")
    say("    n | eps_N (100 digits)        | 1/(12N ln2)      | in Robbins window | e3(a) double-precision value | e3 rel. error")
    e3vals = {1: 5.964e-02, 2: 2.999e-02, 10: 1.174e-04, 17: 9.171e-07, 18: 4.591e-07, 19: 2.291e-07, 20: 1.155e-07, 24: 5.960e-08}
    for n in list(range(1, 25)) + [32, 40, 64]:
        N = mp.mpf(2) ** n
        exact = mp.loggamma(N) / mp.log(2)
        stir = (n - 1 / mp.log(2)) * N - mp.mpf(n) / 2 + mp.log(2 * mp.pi, 2) / 2
        eps = exact - stir
        lo = 1 / ((12 * N + 1) * mp.log(2))
        hi = 1 / (12 * N * mp.log(2))
        e3 = e3vals.get(n)
        rel = "" if e3 is None else f"{float(abs(e3 - eps) / eps):.2e}"
        say(f"  {n:3d} | {mp.nstr(eps, 12):>22} | {mp.nstr(hi, 8):>14} | {bool(lo < eps < hi)!s:5} | "
            f"{'' if e3 is None else e3:>10} | {rel}")


# ---------------------------------------------------------------------------
def part_f():
    say("")
    n = 10
    N = 2 ** n
    say(f"(f) normalised vs semimeasure loss on the first k pairs of the H5 chain, n = {n}")
    say("    nu_geo: uniform random ordering w of nonzero strings; m ~ Geometric(1/2) on {1,2,...} (capped at N-1);")
    say("    F(w_1) = 0^n, F(w_j) = w_{j-1} for 2 <= j <= m, undefined elsewhere.  cyc: uniform cyclic permutation.")

    def Pm_ge(t):
        return 2.0 ** (-(t - 1)) if t <= N - 1 else 0.0

    def E_resid(t):
        # E[(m' - t + 1)^+] with m' = min(m, N-1)
        s = 0.0
        for m in range(t, N - 1):
            s += 2.0 ** (-m) * (m - t + 1)
        s += 2.0 ** (-(N - 2)) * (N - 1 - t + 1)    # P(m >= N-1) = 2^{-(N-2)}
        return s

    for a, b, name in [(0.0, 1.0, "nu_geo alone"), (1.0, 0.0, "cyc alone"), (0.5, 0.5, "1/2 cyc + 1/2 nu_geo")]:
        norm = 0.0
        semi = 0.0
        rows = []
        for t in range(1, N):
            num = (a + b * Pm_ge(t)) / (N - t)              # times (N-1)_{t-1}
            den = a + b * E_resid(t) / (N - t)              # times (N-1)_{t-1}
            norm += -math.log2(num / den)
            # semimeasure: nu(D_t) = a/(N-1)_t + b P(m>=t)/(N-1)_t
            if t in (1, 2, 10, 100, N - 1):
                semi = -math.log2(a + b * Pm_ge(t)) + lg_falling(N - 1, t) if a + b * Pm_ge(t) > 0 else float("inf")
                rows.append(f"k={t}: normalised {norm:10.2f}, semimeasure {semi:10.2f}")
        say(f"  {name:22s}: " + "; ".join(rows))


# ---------------------------------------------------------------------------
def part_g():
    say("")
    say("(g) k-step bounds for L_SFI(D_k), reported as  bound - log2 (N-1)_k  (additive constants c omitted;")
    say("    K(k) replaced by log2(k+1) + 2 log2 log2(k+2)).")
    say("    track:   lower log2(N-1)_k - log2(N-1) [Thm 2.3(2)];  upper log2(N-1)_k - max{0, log2(N-k) - k} [Thm 2.3(1)]")
    say("    referee: lower log2(N-1)_{k-1} = log2(N-1)_k - log2(N-k) [depth count];  upper log2(N-1)_{k-1} + min{K(k), log2(N-k), k} [broom]")
    say("    n                    k | track lower  referee lower | referee upper  track upper | referee gap")
    for n in [10, 20, 64]:
        N = 2 ** n
        for k in [1, 2, 4, n, 4 * n, 2 ** (n // 2), 2 ** (n - 2), N // 2, N - 2, N - 1]:
            if k < 1 or k > N - 1:
                continue
            tl = -math.log2(N - 1)
            rl = -math.log2(N - k)
            Kk = math.log2(k + 1) + 2 * math.log2(math.log2(k + 2))
            ru = -math.log2(N - k) + min(Kk, math.log2(N - k), k)
            tu = -max(0.0, math.log2(N - k) - k)
            say(f"  {n:3d} {k:20d} | {tl:11.2f} {rl:14.2f} | {ru:13.2f} {tu:12.2f} | {ru - rl:8.2f}")


def main():
    say("r2_cyclic_independent.py")
    part_a()
    part_b()
    part_c()
    part_d()
    part_e()
    part_f()
    part_g()
    with open(os.path.join(HERE, "r2_cyclic_independent_output.txt"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()

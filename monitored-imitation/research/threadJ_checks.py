"""Thread J: exact checks for research/threadJ-optimality.md.

Part A  brute-force checks of the silent-damage class W(n, sigma, D) of Theorem J1:
        (T1), (B_D) on every notebook and every entry, tau(x0) <= n0, Lemma S,
        failure of the base run, gamma-unguessability, and the max load s/N.
Part B  online simulation on W(n, sigma, D): slack imitation (SI, uniform query),
        LAST, MIX, and the location protocol; failed runs against Lambda*K.
Part C  CHAIN without slack: the location protocol (query just before the decoder
        writes k_p, else at the last step) against chained imitation and BIS.
Part D  the ask budget of Proposition 5(a) is attained.
Part E  the explicit constants of Theorem J1 for a few parameter sets.

Run:  python3 threadJ_checks.py > threadJ_checks.out
"""
import itertools
import math
import random


def ceil_div(a, b):
    return -(-a // b)


def wclass(n, sigma, D):
    s = ceil_div(sigma + 1, D + 1)
    N = n - s * (D + 1) + 1
    W = [frozenset(t + i * (D + 1) for i in range(s)) for t in range(N)]
    return s, N, W


def unit_fn(Wt, k):
    return lambda i: (k if i in Wt else 0)


def valid_count(a, u, D):
    v, last_wrong = 0, -10 ** 9
    for i, x in enumerate(a):
        if x != u(i):
            last_wrong = i
        elif i - last_wrong > D:
            v += 1
    return v


def tau(a, u, D, n0, cap):
    """Simulate the human from notebook a: the number of its own steps until S holds."""
    v, last_wrong = 0, -10 ** 9
    for i, x in enumerate(a):
        if x != u(i):
            last_wrong = i
        elif i - last_wrong > D:
            v += 1
    L = len(a)
    for m in range(cap + 1):
        if v >= n0:
            return m
        if L - last_wrong > D:      # the human's unit u(L) is correct; valid iff no recent wrong unit
            v += 1
        L += 1
    return math.inf


# ---------------------------------------------------------------- Part A
def part_a():
    print("== Part A: brute-force checks of the class W(n, sigma, D) ==")
    for (n, sigma, D, q) in [(6, 1, 1, 3), (7, 2, 0, 2), (7, 3, 1, 3), (8, 2, 2, 2), (7, 0, 0, 2), (8, 5, 1, 2)]:
        n0 = n - sigma
        s, N, W = wclass(n, sigma, D)
        bad = {"T1": 0, "BD": 0, "T2": 0, "tau0": 0, "lemmaS": 0, "base": 0, "guess": 0}
        maxload = max(sum(1 for Wt in W if j in Wt) for j in range(n))
        for t in range(N):
            for k in range(1, q + 1):
                u = unit_fn(W[t], k)
                if tau([], u, D, n0, 3 * n) > n0:
                    bad["tau0"] += 1
                for L in range(n):
                    for y in itertools.product(range(q + 1), repeat=L):
                        ty = tau(y, u, D, n0, 3 * n)
                        if ty >= 1 and tau(list(y) + [u(L)], u, D, n0, 3 * n) != ty - 1:
                            bad["T1"] += 1
                        for g in range(q + 1):
                            if g == u(L):
                                continue
                            tg = tau(list(y) + [g], u, D, n0, 3 * n)
                            if ty == 0 and tg != 0:
                                bad["T2"] += 1
                            if tg > ty + D:
                                bad["BD"] += 1
                base = [0] * n
                if valid_count(base, u, D) >= n0 or sum(1 for i in range(n) if base[i] != u(i)) != s:
                    bad["base"] += 1
        # Lemma S and unguessability over all runs of length n
        nfail, minM = 0, n + 1
        for a in itertools.product(range(q + 1), repeat=n):
            for t in range(N):
                succ_k = 0
                for k in range(1, q + 1):
                    u = unit_fn(W[t], k)
                    if valid_count(a, u, D) >= n0:
                        succ_k += 1
                    else:
                        nfail += 1
                        M = sum(1 for i in range(n) if a[i] != u(i))
                        minM = min(minM, M)
                if succ_k > s:
                    bad["guess"] += 1
        if minM < ceil_div(sigma + 1, D + 1):
            bad["lemmaS"] += 1
        print(f"n={n} sigma={sigma} D={D} q={q}: s={s} N={N} max load={maxload} (s={s}); "
              f"min |M| over failing runs={minM} (Lemma S needs {ceil_div(sigma + 1, D + 1)}); "
              f"violations={bad}")


# ---------------------------------------------------------------- Part B
class WProblem:
    def __init__(self, rng, n, s, N, W, D, eta, q):
        self.n, self.s, self.N, self.W, self.D = n, s, N, W, D
        self.special = rng.random() < eta
        self.t = rng.randrange(N) if self.special else None
        self.k = rng.randrange(1, q + 1) if self.special else None
        self.alive = [True] * N      # offsets not eliminated
        self.hits = set()            # positions known to be in the window
        self.kk = None               # learned content
        self.cache = None

    def u(self, i):
        return self.k if (self.special and i in self.W[self.t]) else 0

    def decoder_run(self):
        if self.kk is None:
            return [0] * self.n
        cons = [t for t in range(self.N) if self.alive[t] and self.hits <= self.W[t]]
        run = []
        for j in range(self.n):
            c = sum(1 for t in cons if j in self.W[t])
            run.append(self.kk if 2 * c > len(cons) else 0)
        return run

    def fails(self, n0):
        if self.cache is None:
            run = self.decoder_run()
            self.cache = valid_count(run, self.u, self.D) < n0
        return self.cache

    def query(self, j):
        ans = self.u(j)
        self.cache = None
        if ans:
            self.hits.add(j)
            self.kk = ans
        else:
            for t in range(self.N):
                if j in self.W[t]:
                    self.alive[t] = False
        return ans


def part_b(seeds=10):
    print("\n== Part B: online runs on W(n, sigma, D), n=64, sigma=32, m=40, eta=1/2 ==")
    print("failed runs until every problem's run succeeds; mean over seeds")
    n, sigma, m, eta = 64, 32, 40, 0.5
    n0 = n - sigma
    for D in [0, 1, 3, 7, 15]:
        s, N, W = wclass(n, sigma, D)
        q = 2 * s
        Lam = min(n, (D + 1) * n / (sigma + 1))
        row = {}
        for proto in ["SI", "MIX", "LAST"]:
            tot_fail, tot_K, tot_spec, stalled = 0, 0.0, 0, 0
            for seed in range(seeds):
                rng = random.Random(1000 * D + seed)
                probs = [WProblem(rng, n, s, N, W, D, eta, q) for _ in range(m)]
                K = sum(math.log2(1 / eta) + math.log2(N * q) if p.special else math.log2(1 / (1 - eta)) for p in probs)
                fails, rounds = 0, 0
                while any(p.fails(n0) for p in probs):
                    rounds += 1
                    if rounds > 200000:
                        stalled += 1
                        break
                    p = probs[rng.randrange(m)]
                    if p.fails(n0):
                        fails += 1
                    if proto == "SI" or (proto == "MIX" and rng.random() < 0.5):
                        j = rng.randrange(n)
                    else:
                        j = n - 1
                    p.query(j)
                tot_fail += fails
                tot_K += K
                tot_spec += sum(p.special for p in probs)
            row[proto] = (tot_fail / seeds, tot_K / seeds, tot_spec / seeds, stalled)
        si = row["SI"]
        print(f"D={D:2d} s={s:2d} N={N:2d} Lambda={Lam:6.2f} K={si[1]:6.1f} specials={si[2]:4.1f}: "
              f"SI failed={si[0]:7.1f} (failed/(Lambda*K)={si[0] / (Lam * si[1]):.3f}, "
              f"failed/(specials*n/s)={si[0] / (si[2] * n / s):.2f}); "
              f"MIX failed={row['MIX'][0]:7.1f}; LAST stalled in {row['LAST'][3]}/{seeds} seeds")


# ---------------------------------------------------------------- Part C
def part_c(seeds=20):
    print("\n== Part C: CHAIN (catch-up human with dependent work), sigma=0, m=100, eta=1/2 ==")
    print("LOC = query just before the decoder writes k_p (else the last step); one query per round")
    m, eta = 100, 0.5
    for n in [16, 64, 256, 1024]:
        res = {}
        for proto in ["LOC", "CI", "BIS"]:
            F, Q, KK, worst = 0, 0, 0.0, 0.0
            for seed in range(seeds):
                rng = random.Random(7 * n + seed)
                P = []
                for _ in range(m):
                    sp = rng.random() < eta
                    P.append(dict(sp=sp, t=rng.randrange(n) if sp else None, lo=-1, hi=n - 1, known=False, resolved=False))
                K = sum(math.log2(1 / eta) + math.log2(n) + 1 if p["sp"] else 1.0 for p in P)

                def w_of(p):
                    return (p["lo"] + p["hi"]) // 2 + 1   # first j with Pr[t <= j] > 1/2

                def failing(p):
                    if not p["sp"]:
                        return False
                    if not p["known"]:
                        return True
                    return w_of(p) > p["t"]

                fails = queries = 0
                while any(failing(p) for p in P):
                    p = P[rng.randrange(m)]
                    fails += failing(p)
                    if not p["sp"] and p["resolved"]:
                        continue
                    if proto == "BIS" and p["known"]:
                        continue
                    if proto == "LOC":
                        j = n - 1 if not p["known"] else w_of(p) - 1
                        if j < 0:
                            continue
                    elif proto == "BIS":
                        j = n - 1
                    else:
                        j = rng.randrange(n)
                        if p["known"] and j >= w_of(p):
                            queries += 1          # human writes the next chain unit: no information
                            continue
                    queries += 1
                    if not p["sp"]:
                        p["resolved"] = True       # non-special problems never fail; mark and stop querying them
                        continue
                    if p["t"] <= j:
                        p["known"] = True
                        p["hi"] = min(p["hi"], j)
                        if proto == "BIS":         # binary search on the fixed run for the first due step
                            lo, hi = p["lo"], p["hi"]
                            while hi - lo > 1:
                                mid = (lo + hi) // 2
                                queries += 1
                                if p["t"] <= mid:
                                    hi = mid
                                else:
                                    lo = mid
                            p["lo"], p["hi"] = lo, hi
                    else:
                        p["lo"] = max(p["lo"], j)
                F += fails
                Q += queries
                KK += K
                worst = max(worst, fails / K)
            res[proto] = (F / seeds, Q / seeds, KK / seeds, worst)
        print(f"n={n:5d} K={res['LOC'][2]:6.1f}: LOC failed={res['LOC'][0]:7.1f} (max over seeds of failed/K={res['LOC'][3]:.2f}), "
              f"queries={res['LOC'][1]:7.1f}; CI failed={res['CI'][0]:8.1f}; BIS failed={res['BIS'][0]:6.1f}, queries={res['BIS'][1]:7.1f}")


# ---------------------------------------------------------------- Part D
def part_d():
    print("\n== Part D: the ask budget K/log2(1/(1-alpha)) of Proposition 5(a) is attained ==")
    m = 1000
    for alpha in [0.3, 0.1, 0.01]:
        for delta in [1e-2 * alpha, 1e-4 * alpha]:
            K = m * math.log2(1 / (1 - alpha - delta))
            bound = K / math.log2(1 / (1 - alpha))
            print(f"alpha={alpha:5.2f} delta={delta:.1e}: asks={m}, K={K:9.2f}, budget={bound:9.2f}, asks/budget={m / bound:.4f}")


# ---------------------------------------------------------------- Part E
def part_e():
    print("\n== Part E: Theorem J1's constants (eps = 1/64) ==")
    eps = 1 / 64
    for (n, rho, D) in [(64, 0.5, 0), (64, 0.5, 3), (1024, 0.5, 0), (1024, 0.5, 7), (1024, 0.25, 31), (1024, 0.5, 600)]:
        sigma = round(rho * n)
        n0 = n - sigma
        if D > n0 // 2:
            print(f"n={n} rho={rho} D={D}: outside D <= n0/2")
            continue
        s, N, W = wclass(n, sigma, D)
        Lam = min(n, (D + 1) * n / (sigma + 1))
        Leps = math.log2(math.e * n * n / (4 * eps))
        print(f"n={n:5d} rho={rho} D={D:3d}: s={s:4d} N={N:5d} N/s={N / s:8.2f} ((1-rho)/4)*Lambda={(1 - rho) * Lam / 4:8.2f} "
              f"Lambda={Lam:8.2f}; queries needed >= {N / (4 * s):.1f}*m >= K*{N / s / (32 * eps * Leps):.1f}; "
              f"Corollary 3 upper ~ K*{(D + 1) / (rho * eps):.0f}*ln(K^2/delta)")


if __name__ == "__main__":
    part_a()
    part_b()
    part_c()
    part_d()
    part_e()

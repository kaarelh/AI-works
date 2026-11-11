"""Independent checks of the passages changed in the final revision of small-learner-width.md.

(a) sup_{t>=1} t^-a sqrt(ln 2t) = 2^a/sqrt(2 e a) for 0 < a <= 1/4 (Corollary 3(i) constant), by numerical maximization.
(b) Corollary 3(i) and the Section 0 "more generally" sentence: exact Exc of (5.1) at c = 1, class width N, weights n^a,
    for random 1 <= N <= 2 n^a, 1 <= d <= n^a, compared with C_{L,a,delta} n^(2a-1/2).
(c) Section 7.1 item 1 example: average of k raw outputs, each <= 1 and < -(2k-1) on its own set.
(d) Remark 7 window L/(2(2L-1)).
(e) Section 7.1 item 2 / Remark 8: at A's N_0 (Lemma 2.1, a <= 1) on the cube family, Dev_N >= 4 for H >= 2.
(f) Lemma E remark: moment condition of BLM Theorem 2.10 with scale b/3, i.e. 3^(q-2) <= q!/2 for q >= 3.
(g) Section 7.3, A2 entry: weight-bound sentence (B Prop. 9.1(a) + Lemma 9.2 at width 1), sample numbers.
(h) Section 7.3, red-team Section 8 entry: T <= n^(1/2-eps) iff theta < (gamma-1)/(2(L-2)) (exponent only).
"""
import math
import random
import mpmath as mp
from scipy.optimize import minimize_scalar

mp.mp.dps = 50
rng = random.Random(7)

# (a)
worst = 0.0
for _ in range(400):
    a = rng.uniform(1e-3, 0.25)
    f = lambda u: -(math.exp(-a * u) * math.sqrt(math.log(2) + u))  # t = e^u, u >= 0
    res = minimize_scalar(f, bounds=(0, 2000), method="bounded", options={"xatol": 1e-12})
    sup = -res.fun
    bound = 2 ** a / math.sqrt(2 * math.e * a)
    tstar_u = 1 / (2 * a) - math.log(2)  # ln t* = 1/(2a) - ln 2
    worst = max(worst, sup / bound)
    assert tstar_u > 0, "t* <= 1"
    assert abs(res.x - tstar_u) < 1e-3 * max(1, tstar_u), (a, res.x, tstar_u)
print("(a) 400 random a in (0,1/4]: max sup/(2^a/sqrt(2ea)) = %.12f ; argmax matches t* = e^(1/(2a))/2 > 1" % worst)


# (b)
def Lam(n, N, d, H):
    K = n + 1
    return mp.log(2 + 2 * n * mp.sqrt(K * N) * H * (d + N + 1) * (K + 1) ** (mp.mpf(H) / 2))


def Exc(n, N, d, H, Bb, delta):
    L = H + 1
    l = mp.log(4 / mp.mpf(delta))
    E = d * (d + 1) * Bb ** 2 + 2 * (L - 1) * N ** 2 * Bb ** 2
    P = N * (d + 1) + (H - 1) * N ** 2 + N
    dev = 4 * mp.sqrt((P * Lam(n, N, d, H) + l) / (2 * n))
    U1 = N * Bb + 1
    return (E + 1) / n + mp.mpf(4) / n + dev + U1 * mp.sqrt(2 * l / n) + 2 * U1 ** 2 * l / (3 * n)


worst_b = mp.mpf(0)
worstcase = None
for _ in range(20000):
    logn = rng.uniform(math.log10(2), 300)
    n = mp.mpf(10) ** logn
    a = rng.uniform(1e-3, 0.2499)
    H = rng.randint(1, 10)
    L = H + 1
    delta = 10 ** rng.uniform(-12, math.log10(0.999))
    na = n ** a
    Nmax = int(mp.floor(2 * na))
    dmax = int(mp.floor(na))
    if Nmax < 1 or dmax < 1:
        continue
    # random admissible N, d, biased toward the extremes
    N = rng.choice([1, Nmax, max(1, int(mp.ceil(na))), rng.randint(1, Nmax) if Nmax < 10**15 else Nmax])
    N = min(N, Nmax)
    d = rng.choice([1, dmax, rng.randint(1, dmax) if dmax < 10**15 else dmax])
    l = mp.log(4 / mp.mpf(delta))
    C = 5 * mp.sqrt(2) * mp.sqrt(l) + 4 * mp.sqrt((2 * H + 1) * (H + 5)) * 2 ** mp.mpf(a) / mp.sqrt(2 * mp.e * a) + (8 * L - 1) * (1 + l)
    r = Exc(n, N, d, H, na, delta) / (C * n ** (2 * mp.mpf(a) - mp.mpf(1) / 2))
    if r > worst_b:
        worst_b, worstcase = r, (float(logn), a, H, N if N < 10**6 else "big", d if d < 10**6 else "big", delta)
print("(b) 20000 random cases, N in [1, 2n^a], d in [1, n^a], Bbar = n^a: max Exc/(C n^(2a-1/2)) = %s at %s"
      % (mp.nstr(worst_b, 6), worstcase))

# (c)
viol = 0
for _ in range(2000):
    k = rng.randint(2, 12)
    for j in range(k):
        zs = [rng.uniform(-50, 1) for _ in range(k)]  # each <= 1
        zs[j] = -(2 * k - 1) - rng.uniform(1e-9, 10)  # below -(2k-1) on its own set A_j
        zbar = sum(zs) / k
        if not zbar < -1:
            viol += 1
# extremal: the others exactly 1
for k in range(2, 50):
    zs = [1.0] * k
    zs[0] = -(2 * k - 1) - 1e-12
    assert sum(zs) / k < -1
print("(c) average of k raw outputs is < -1 on A_j in all random cases: violations = %d" % viol)

# (d)
print("(d) L/(2(2L-1)) for L=2..8:", [round(L / (2 * (2 * L - 1)), 4) for L in range(2, 9)])

# (e)
worst_e = mp.mpf(10) ** 9
for H in [2, 3, 5]:
    for lam in [0.25, 0.5, 1, 2, 4]:
        for d in range(3, 120):
            M = 2 ** d
            n = max(1, int(math.ceil(lam * M)))
            s = min(n, M)
            N0 = int(math.floor(64 * math.log(2) * d * (d + 1) * s / 1.0 ** 2)) + 1  # a = 1, the smallest N_0
            P = N0 * (d + 1) + (H - 1) * N0 ** 2 + N0
            dev = 4 * mp.sqrt((P * Lam(mp.mpf(n), N0, d, H) + mp.log(4 / mp.mpf(0.5))) / (2 * n))
            worst_e = min(worst_e, dev)
print("(e) min Dev_N at N = N_0(d, s, a=1), H in {2,3,5}, lambda in [1/4,4], d in [3,119]: %s (must be >= 4)" % mp.nstr(worst_e, 5))

# (f)
print("(f) 3^(q-2) <= q!/2 for q = 3..40:", all(3 ** (q - 2) <= math.factorial(q) / 2 for q in range(3, 41)))

# (g)
th = math.tanh(1)
for n in [10**3, 10**6, 10**12]:
    for H in [1, 2, 4]:
        L = H + 1
        K = n + 1  # c = 1
        delta0 = 0.5 * (L / K) ** (L / 2)  # eta = 1/2
        eta = delta0 * (K / L) ** (L / 2)
        B = max(th ** (-H), (th ** (-H) / delta0) ** (1 / L))
        ok = (B >= th ** (-H)) and (delta0 >= th ** (-H) / B ** L - 1e-15) and delta0 <= 1
        print("(g) n=%.0e H=%d: delta0=%.3e eta=%.2f (1-eta)^2=%.2f width-1 weight bound B=%.3e Lemma 9.2 hypotheses %s"
              % (n, H, delta0, eta, (1 - eta) ** 2, B, ok))

# (h)
for L in [3, 4, 6]:
    for gamma in [1.5, 2.0, 3.0]:
        thr = (gamma - 1) / (2 * (L - 2))
        for theta in [0.5 * thr, 0.99 * thr, 1.01 * thr, 2 * thr]:
            expo = theta * (L - 2) / (gamma - 1)  # exponent of n in T at fixed accuracy a
            assert (expo < 0.5) == (theta < thr)
print("(h) exponent of T is theta(L-2)/(gamma-1) < 1/2 iff theta < (gamma-1)/(2(L-2)): ok")

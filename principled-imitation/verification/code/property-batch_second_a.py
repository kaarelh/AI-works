"""Second checker, part property-batch: numerical checks of Lemma 2.8, item (3) after
Corollary 3.7, remark (3) after Theorem 4.5, Remark 4.14, Theorem 4.11(B), Proposition 4.15
and the constant of 4.13 item 4.  Written independently of the editor's script.
Run:  python3 property-batch_second_a.py > property-batch_second_a.out
"""
from fractions import Fraction as Fr
from math import comb, log, sqrt, exp, ceil, log1p
import itertools, random

random.seed(12345)

def hdr(s):
    print("\n" + "=" * 78 + "\n" + s + "\n" + "=" * 78)

# ---------------------------------------------------------------- Lemma 2.8
hdr("(A) Lemma 2.8: exact check of every step, including edge cases")
def binom_tail_ge(N, k):  # Pr[Bin(N,1/2) >= k], exact
    return Fr(sum(comb(N, i) for i in range(max(k, 0), N + 1)), 2 ** N)

allok = True
cases = []
for N in [1, 2, 3, 5, 8, 12, 20, 40, 100, 300]:
    lo = (N + 1) ** 2
    hi = exp(N)
    if lo > hi:
        cases.append((N, lo, "M range empty"))
        continue
    Ms = sorted(set([lo, lo + 1, int(min(hi, (N + 1) ** 3)), int(hi ** 0.5) if hi ** 0.5 > lo else lo, int(hi)]))
    for M in Ms:
        if not (lo <= M <= hi):
            continue
        ts = 0.5 * sqrt(log(M / (N + 1) ** 2) / N) - 1.0 / N
        if ts < 0:
            p = binom_tail_ge(N, ceil(N / 2))  # Pr[Qhat >= 1/2]
            step_ok = p >= Fr(1, 2) and M * log(2) >= N + 1
            log_none = M * log1p(-float(p))
        else:
            k = ceil(N * (0.5 + ts) - 1e-12)
            # least integer k >= N(1/2 + t*)
            while k - 1 >= N * (0.5 + ts):
                k -= 1
            while k < N * (0.5 + ts):
                k += 1
            tprime = k / N - 0.5
            p = binom_tail_ge(N, k)
            pk = Fr(comb(N, k), 2 ** N)
            kl = (0.5 + tprime) * log(1 + 2 * tprime) + ((0.5 - tprime) * log(1 - 2 * tprime) if tprime < 0.5 else 0)
            step_ok = (k <= N and ts <= tprime < ts + 1.0 / N + 1e-12 and tprime <= 0.5 + 1e-12
                       and float(pk) >= exp(-N * kl) / (N + 1) * (1 - 1e-12)
                       and kl <= 4 * tprime ** 2 + 1e-15
                       and float(p) >= (N + 1) / M * (1 - 1e-12))
            log_none = M * log1p(-float(p)) if float(p) < 1 else float("-inf")  # log1p: no underflow
        concl = log_none <= -(N + 1) + 1e-9
        cube = (M < (N + 1) ** 3) or (ts >= 0.5 * sqrt(log(M) / (3 * N)) - 1.0 / N - 1e-12)
        ok = step_ok and concl and cube
        allok &= ok
        cases.append((N, M, f"t*={ts:+.4f} Pr[one deviates]={float(p):.3e} (N+1)/M={(N+1)/M:.3e} "
                            f"ln Pr[none]={log_none:.3e} <= -(N+1)={-(N+1)}: {concl}; steps {step_ok}; cube-form {cube}"))
for c in cases:
    print("  N=%d M=%s: %s" % c)
print("  all steps and the conclusion hold on these cases:", allok)
print("  note: (N+1)^3 <= e^N first holds at N =", next(N for N in range(1, 50) if (N + 1) ** 3 <= exp(N)),
      "; (N+1)^2 <= e^N first holds at N =", next(N for N in range(1, 50) if (N + 1) ** 2 <= exp(N)))

# ---------------------------------------------------------------- item (3)
hdr("(B) item (3) after Corollary 3.7: human repeats a fair bit; best stateless sampler")
def tv_rep(p):
    q = [p * p, p * (1 - p), (1 - p) * p, (1 - p) ** 2]
    h = [0.5, 0, 0, 0.5]
    return 0.5 * sum(abs(a - b) for a, b in zip(q, h))
best = min((tv_rep(i / 200000), i / 200000) for i in range(200001))
print("  min TV over a grid of 200001 values of p: %.6f at p=%.5f; sqrt(2)-1 = %.6f" % (best[0], best[1], sqrt(2) - 1))
mx = max(abs(tv_rep(p) - (2 * p * (1 - p) if 1 - 1 / sqrt(2) <= p <= 1 / sqrt(2)
                         else (0.5 * (4 * p - 1 - 2 * p * p) if p > 0.5 else 0.5 * (4 * (1 - p) - 1 - 2 * (1 - p) ** 2))))
         for p in [i / 1000 for i in range(1001)])
print("  largest deviation of the closed form of the proof file from the direct value: %.2e" % mx)
print("  3*(sqrt2-1) = %.4f > 1" % (3 * (sqrt(2) - 1)))

# ---------------------------------------------------------------- memoriser classes
def tables(u):
    # all tables on {0..u-1}: dict x -> bit, as tuples with None for 'not in table'
    return itertools.product([None, 0, 1], repeat=u)

def mem_class_predict(u, K, D, x, versions):
    """versions: list of (fraction, behaviour off table) with behaviour in {'b','g','silent'}.
    Returns exact (Pr[b], Pr[silent], Pr[abiding answer]) of the mixture at x (all Fractions)."""
    f = {xx: 0 for xx in range(u)}  # human: f = 0 everywhere (by symmetry any f works)
    for (xx, yy) in D:
        f[xx] = yy
    wf = Fr(1, 2 ** K)
    c0 = (1 - wf) / (1 + Fr(1, 2 * u)) ** u
    num_b = num_s = num_a = Fr(0)
    M = Fr(0)
    # human
    M += wf; num_a += wf
    for T in tables(u):
        size = sum(t is not None for t in T)
        w = c0 * Fr(1, (4 * u) ** size)
        if any(T[xx] != yy for (xx, yy) in D):
            continue
        M += w
        for frac, beh in versions:
            ww = w * frac
            if T[x] is not None:
                num_a += ww
            elif beh == 'b':
                num_b += ww
            elif beh == 'g':
                num_a += ww
            else:
                num_s += ww
    return num_b / M, num_s / M, num_a / M

hdr("(C) remark (3) after Theorem 4.5: u=4, K=30, one pair seen, versions b/g with fractions lam, 1-lam")
for lam in [Fr(1), Fr(1, 2), Fr(1, 50)]:
    vb, vs, va = mem_class_predict(4, 30, [(0, 0)], 1, [(lam, 'b'), (1 - lam, 'g')])
    closed = lam * Fr(8, 9) / (1 + Fr(18, 2 ** 30 - 1))
    print("  lam=%s: Pr[b]=%.6f, lam*(value of 4.5(b))=%.6f, equal: %s" % (lam, float(vb), float(closed), vb == closed))

hdr("(D) Remark 4.14: closed class of Corollary 4.6, u=4, K=30, one pair seen")
for C in [4, 99]:
    CR = C + 1
    vb, vs, va = mem_class_predict(4, 30, [(0, 0)], 1, [(Fr(C, C + 1), 'b'), (Fr(1, C + 1), 'silent')])
    print("  C_R=%d: violating %.4f, silent %.4f, abiding %.4f; normalised violation %.4f; 1-1/C_R=%.4f"
          % (CR, vb, vs, va, vb / (vb + va), 1 - 1 / CR))
    print("     exact formula of Corollary 4.6: %.6f, equal: %s" %
          (float(Fr(C, C + 1) * Fr(8, 9) / (1 + Fr(18, 2 ** 30 - 1))),
           vb == Fr(C, C + 1) * Fr(8, 9) / (1 + Fr(18, 2 ** 30 - 1))))

# ---------------------------------------------------------------- Theorem 4.11(B)
hdr("(E) Theorem 4.11(B): the machine U'' for d=3 (u=8), exact enumeration of g_T, h_T, r0")
d, u = 3, 8
# (B1) weights
code_len_q = lambda size: size * (d + 2) + 1
S_tables = sum(comb(u, i) * 2 ** i * Fr(1, 2 ** (i * (d + 2))) for i in range(u + 1))
print("  sum_T (4u)^-|T| = %.6f = (1+1/(2u))^u = %.6f; < e^0.5" % (float(S_tables), (1 + 1 / (2 * u)) ** u))
for size in [0, 1, 3]:
    assert Fr(1, 2 ** (2 + code_len_q(size))) == Fr(1, 8) * Fr(1, (4 * u) ** size)
    assert Fr(1, 2 ** (6 + code_len_q(size))) == Fr(1, 128) * Fr(1, (4 * u) ** size)
print("  weights of codes 00q(T), 011000q(T) equal (1/8),(1/128)*(4u)^-|T|: True")
tot0 = (Fr(1, 8) + Fr(1, 128)) * S_tables + Fr(1, 64)
print("  weight of the non-U part: %.5f; with 2^-c: < 2^-c + 0.24: %s; bound with e^0.5: %.5f" %
      (float(tot0), float(tot0) < 0.24, (1/8 + 1/128) * exp(0.5) + 1/64))
# prefix-freeness on a sample of code words (U part represented by '1'*c + p for a prefix-free toy set)
def qcode(T):
    s = ""
    for x in range(u):
        if T[x] is not None:
            s += "1" + format(x, "0%db" % d) + str(T[x])
    return s + "0"
c = 7
toyU = ["0", "10", "110", "111"]  # a prefix-free set of U-programs
words = ["1" * c + p for p in toyU] + ["010000"]
sampleT = random.sample(list(tables(u)), 300)
words += ["00" + qcode(T) for T in sampleT] + ["011000" + qcode(T) for T in sampleT]
pf = all(not (a != b and b.startswith(a)) for a in words for b in words)
print("  prefix-free on %d sample code words: %s" % (len(words), pf))
# (B2) closure constant
print("  preimage weight of 011000q(T) / its weight = (1/8+1/128)/(1/128) =", (Fr(1, 8) + Fr(1, 128)) / Fr(1, 128))

def Bpredict(c, k_seen, fvals, x, worst=True, rng=None):
    """Exact posterior predictive Pr[b] at unseen x for the class of U'' with d=3.
    U-part: all weight 2^-c on one hypothesis that fits the data and never answers b (worst case),
    or else several random semimeasures."""
    D = [(xx, fvals[xx]) for xx in range(k_seen)]
    M = Fr(0); nb = Fr(0)
    for T in tables(u):
        if any(T[xx] != yy for (xx, yy) in D):
            continue
        size = sum(t is not None for t in T)
        wg = Fr(1, 8) * Fr(1, (4 * u) ** size)
        wh = Fr(1, 128) * Fr(1, (4 * u) ** size)
        M += wg + wh
        if T[x] is None:
            nb += wg
    if k_seen == 0:
        M += Fr(1, 64)  # r0 has likelihood 1 on the empty data set
    if worst:
        M += Fr(1, 2 ** c)
    else:
        for i in range(5):
            # random semimeasure at each input over {0,1,b,none}; weight 2^-c/5
            w = Fr(1, 2 ** c) / 5
            lik = Fr(1)
            for (xx, yy) in D:
                lik *= Fr(rng.randint(0, 10), 10)
            pb = Fr(rng.randint(0, 10), 30)
            M += w * lik; nb += w * lik * pb
    return nb / M

worst_ok = True
for c in [5, 10, 15, 20]:
    nmax = min(u // 4, (c - 5) // (d + 2))
    for k in range(0, 3):
        fvals = [random.randint(0, 1) for _ in range(u)]
        x = u - 1
        pb = Bpredict(c, k, fvals, x)
        bound = Fr(16, 17) * Fr(2 * u, 2 * u + 1) / (1 + Fr(2 ** 3, 2 ** c) * (4 * u) ** k) if k >= 1 else None
        V = Fr(u - k, u) * pb  # seen inputs answered f(x) with prob 1 by every consistent hypothesis
        ok = (bound is None or pb >= bound)
        if k >= 1 and k <= nmax:
            ok &= V > Fr(51, 100)
        if k == 0:
            ok &= V >= Fr(70, 100)
        worst_ok &= ok
        print("  c=%2d k=%d: M_D(b|x)=%.5f  bound(B3)=%s  V=%.5f  (k within the range of the theorem: %s) ok=%s"
              % (c, k, float(pb), "%.5f" % float(bound) if bound is not None else "  -  ", float(V), 1 <= k <= nmax, ok))
rng = random.Random(7)
rand_ok = all(Bpredict(15, k, [rng.randint(0, 1) for _ in range(u)], u - 1, worst=False, rng=rng)
              >= Fr(16, 17) * Fr(16, 17) / (1 + Fr(8, 2 ** 15) * 32 ** k) for k in [1, 2] for _ in range(20))
print("  worst case of the U part: all bounds hold:", worst_ok, "; random U parts (40 cases, c=15):", rand_ok)
val = 0.75 * 16 / 17 * 10 / 11 * 0.8
print("  (3/4)(16/17)(10/11)(4/5) = %.5f; 0.51/ln2 = %.4f, %.5f/ln2 = %.4f (4.13 item 4 uses 0.74), 1/ln2 = %.4f"
      % (val, 0.51 / log(2), val, val / log(2), 1 / log(2)))

# ---------------------------------------------------------------- Proposition 4.15
hdr("(F) Proposition 4.15 on random finite classes (exact rationals)")
def rand_sampler(nx, ny, always=True):
    s = []
    for x in range(nx):
        v = [random.randint(0, 6) for _ in range(ny)]
        if not always:
            v.append(random.randint(0, 4))  # mass of 'no answer'
        tot = sum(v) or 1
        if sum(v) == 0:
            v[0] = 1; tot = 1
        s.append([Fr(a, tot) for a in v[:ny]])
    return s
def condRtheta(nu, R, G, th):
    out = []
    for x, row in enumerate(nu):
        v = sum(p for y, p in enumerate(row) if not R[x][y])
        den = 1 - (1 - th) * v
        out.append([(p * (1 if R[x][y] else 0) + th * v * G[x][y]) / den for y, p in enumerate(row)])
    return out
okall = True; ntr = 0
for trial in range(300):
    nx, ny = random.randint(1, 3), random.randint(2, 4)
    R = [[random.random() < 0.6 for _ in range(ny)] for _ in range(nx)]
    for x in range(nx):
        if not any(R[x]): R[x][random.randrange(ny)] = True
    G = []
    for x in range(nx):
        okys = [y for y in range(ny) if R[x][y]]
        g = [Fr(0)] * ny
        for y in okys: g[y] = Fr(1, len(okys))
        G.append(g)
    th = random.choice([Fr(1), Fr(1, 2), Fr(1, 5), Fr(9, 10)])
    always = random.random() < 0.5
    base = [rand_sampler(nx, ny, always) for _ in range(random.randint(1, 4))]
    imgs = [condRtheta(nu, R, G, th) for nu in base]
    # check the formula properties
    for nu, im in zip(base, imgs):
        for x in range(nx):
            v = sum(p for y, p in enumerate(nu[x]) if not R[x][y])
            if always:
                okall &= sum(im[x]) == 1
            okall &= all(im[x][y] == 0 for y in range(ny) if not R[x][y])
            okall &= all(im[x][y] >= nu[x][y] / (1 - (1 - th) * v) for y in range(ny) if R[x][y])
            okall &= all(condRtheta(im, R, G, th)[x][y] == im[x][y] for y in range(ny))  # idempotent
    H = base + imgs
    wb = [Fr(random.randint(1, 5), 40) for _ in base]
    wi = [Fr(random.randint(1, 5), 40) for _ in imgs]
    w = wb + wi
    phi = list(range(len(base), 2 * len(base))) + list(range(len(base), 2 * len(base)))
    C = max(sum(w[i] for i in range(len(H)) if phi[i] == j) / w[j] for j in set(phi))
    for _ in range(3):
        n = random.randint(1, 4)
        D = []
        for _ in range(n):
            x = random.randrange(nx); y = random.choice([y for y in range(ny) if R[x][y]])
            D.append((x, y))
        lik = []
        for nu in H:
            l = Fr(1)
            for (x, y) in D: l *= nu[x][y]
            lik.append(l)
        M = sum(wi_ * l for wi_, l in zip(w, lik))
        if M == 0: continue
        ntr += 1
        post = [wi_ * l / M for wi_, l in zip(w, lik)]
        lhs = Fr(0); lhs_float = 0.0
        for i, nu in enumerate(H):
            if post[i] == 0: continue
            prod = Fr(1)
            for (x, y) in D:
                v = sum(p for yy, p in enumerate(nu[x]) if not R[x][yy])
                prod *= 1 / (1 - (1 - th) * v)
            lhs += post[i] * prod
        okall &= lhs <= C
        if th < 1:
            cnt = sum(sum(post[i] * sum(p for yy, p in enumerate(H[i][x]) if not R[x][yy]) for i in range(len(H))) for (x, y) in D)
            okall &= float(cnt) <= log(float(C)) / (1 - float(th)) + 1e-12
        wimg = sum(post[i] for i in range(len(base), len(H)))
        okall &= wimg >= 1 / C
        if always:
            for x in range(nx):
                ab = sum(post[i] * sum(p for yy, p in enumerate(H[i][x]) if R[x][yy]) for i in range(len(H)))
                okall &= ab >= 1 / C
print("  %d data sets on 300 random classes: formula, never violating, lower bound, (a), (b): all hold: %s" % (ntr, okall))

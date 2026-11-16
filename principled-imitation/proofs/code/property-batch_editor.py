# Editor's checks for proofs/property-batch.md (key: property-batch).
# Pure Python 3, exact rational arithmetic wherever a probability is compared with a bound.
# Run as:  python3 property-batch_editor.py > property-batch_editor.out
# Every block is written from the statements of the proof file, not from the provers' or verifiers' code.

import itertools, math
from fractions import Fraction as Fr
from math import comb, log, sqrt, exp

def binom_pmf(N, k, q):
    return comb(N, k) * q**k * (1 - q)**(N - k)

# ---------------------------------------------------------------------------
# (E1) Remark after Theorem 2.5: the draft's joint statement (two-sided tolerance and the one-sided
#      bound ln(1/delta)/N for a test that never occurred, both at confidence 1 - delta) for ONE test
#      of weight 1.  Exact failure probability for N = 4.
print("(E1) Theorem 2.5(c), remark: one test of weight 1, N = 4; exact failure probability of the draft's joint statement")
for delta in (0.34, 0.332, 0.3315):
    N = 4
    tol = sqrt(log(2 / delta) / (2 * N))
    qR = log(1 / delta) / N
    q = qR + 1e-9                      # Q(R) just above the one-sided bound
    fail = 0.0
    for k in range(N + 1):
        p = binom_pmf(N, k, q)
        if abs(k / N - q) > tol or (k == 0 and q > qR):
            fail += p
    print("    delta = %.4f: tol = %.5f, ln(1/delta)/N = %.5f, failure probability = %.4f  (%s delta)"
          % (delta, tol, qR, fail, ">" if fail > delta else "<="))

# ---------------------------------------------------------------------------
# (E2) Lemma 2.8 (the proved form of Remark 2.7(4)): M independent events of probability 1/2, N runs.
#      Claim: if (N+1)^2 <= M and ln M <= N, then with t* = (1/2) sqrt(ln(M/(N+1)^2)/N) - 1/N,
#      Pr[max_j (Qhat_j - 1/2) >= t*] >= 1 - exp(-(N+1)).  Exact binomial tails.
print("(E2) Lemma 2.8 (Remark 2.7(4)): exact Pr[largest of M deviations >= t*] against 1 - exp(-(N+1))")
ok = True
for N, M in ((10, 11**3), (30, 31**3), (30, 10**8), (100, 101**3), (100, 10**20), (400, 401**3), (400, 10**40)):
    assert (N + 1)**2 <= M and log(M) <= N
    tstar = 0.5 * sqrt(log(M / (N + 1)**2) / N) - 1.0 / N
    k0 = math.ceil(N * (0.5 + tstar) - 1e-12)
    tail = sum(Fr(comb(N, k), 2**N) for k in range(k0, N + 1))        # Pr[S/N - 1/2 >= t*]
    lower_step = exp(-4 * N * (tstar + 1.0 / N)**2) / (N + 1)         # the bound used in the proof
    log_none = M * math.log1p(-float(tail))                           # ln Pr[no event deviates by t*]
    ok &= float(tail) >= lower_step * (1 - 1e-12) and log_none <= -(N + 1)
    third = 0.5 * sqrt(log(M) / (3 * N)) - 1.0 / N
    print("    N = %3d, M = %.3g: t* = %.4f, Pr[one event deviates] = %.3e >= %.3e, ln Pr[none of M deviates] = %.3g <= %d; (1/2)sqrt(ln M/(3N)) - 1/N = %.4f %s"
          % (N, M, tstar, float(tail), lower_step, log_none, -(N + 1), third, "(<= t*, M >= (N+1)^3)" if M >= (N + 1)**3 else ""))
print("    all inequalities of the proof hold:", ok)

# ---------------------------------------------------------------------------
# (E3) Remark (3) after Corollary 3.7 (a human who repeats himself): scaffold = the same question twice,
#      human system = (0,0) or (1,1) with probability 1/2; stateless sampler with Pr[1] = p.
best = min((0.5 * (abs(p * p - 0.5) + 2 * p * (1 - p) + abs((1 - p)**2 - 0.5)), p)
           for p in [i / 200000 for i in range(200001)])
print("(E3) least total variation between the run law of a stateless sampler and the repeating human: %.6f at p = %.5f (sqrt(2) - 1 = %.6f, 1/sqrt(2) = %.5f or its mirror image)"
      % (best[0], best[1], sqrt(2) - 1, 1 / sqrt(2)))

# ---------------------------------------------------------------------------
# (E4) Corollary 4.6, remark on silence: closed memoriser class, u = 4, K = 30, C_R = C + 1 = 5, one pair seen.
#      Brute force over all tables in exact rationals.
def tables(u):
    for vals in itertools.product((None, 0, 1), repeat=u):
        yield vals                                   # vals[x] is None if x is not in the table

def closed_memoriser_split(u, K, C, data, x):
    """posterior probabilities (violating answer b, no answer, abiding answer) of the mixture at input x"""
    f = [0] * u                                      # the human: f = 0 (any f gives the same numbers)
    c0 = (1 - Fr(1, 2**K)) / (1 + Fr(1, 2 * u))**u
    tot = Fr(0); viol = Fr(0); silent = Fr(0); abide = Fr(0)
    wf = Fr(1, 2**K)                                 # the human's index
    tot += wf; abide += wf
    for T in tables(u):
        if any(T[xi] != yi for xi, yi in data):
            continue                                 # not consistent (answers b, nothing, or the wrong bit at a seen input)
        size = sum(v is not None for v in T)
        base = c0 * Fr(1, (4 * u)**size)
        wg, wh = base * Fr(C, C + 1), base * Fr(1, C + 1)
        tot += wg + wh
        if T[x] is None:
            viol += wg; silent += wh
        else:
            abide += wg + wh
    return viol / tot, silent / tot, abide / tot

for C in (4, 99):
    v, s, a = closed_memoriser_split(4, 30, C, [(0, 0)], 1)
    print("(E4) closed memoriser class, u = 4, K = 30, C_R = %d, one pair seen, unseen input: violating %.4f, no answer %.4f, abiding answer %.4f; given an answer: violating %.4f (1 - 1/C_R = %.4f)"
          % (C + 1, float(v), float(s), float(a), float(v / (v + a)), 1 - 1 / (C + 1)))

# ---------------------------------------------------------------------------
# (E5) Proposition 4.8(d): 1 - V(D) >= M(D)^(1/k) for every data set with k >= 1 distinct inputs (closed forms of 4.8(a),(b)).
worst = 10.0
cases = 0
for u in (8, 16, 64, 1024, 2**16):
    for s in sorted(set([1, 2, u // 4, u // 2, u - 1])):
        if not (1 <= s < u):
            continue
        for K in (1, 2, 5, 20, 200):
            for k in range(1, min(s, 60) + 1):
                a = 2.0**(-K)
                om = 1.0
                for i in range(k):
                    om *= (s - i) / (u - i)
                Mv = a + (1 - a) * om
                one_minus_V = (a + (s / u) * (1 - a) * om) / Mv
                if Mv > 0:
                    worst = min(worst, one_minus_V / Mv**(1.0 / k))
                    cases += 1
print("(E5) Proposition 4.8(d): least value of (1 - V(D)) / M(D)^(1/k) over %d cases = %.6f (must be >= 1)" % (cases, worst))

# ---------------------------------------------------------------------------
# (E6) Theorem 4.11, machine U'': code, weights, closure constant of the memoriser part, and the lower bound,
#      by enumeration of all tables for d = 3 (u = 8), exact rationals.
d = 3; u = 2**d
def code_of_table(T):
    q = ""
    for x in range(u):
        if T[x] is not None:
            q += "1" + format(x, "0%db" % d) + str(T[x])
    return q + "0"
codes_g = []; codes_h = []
for T in tables(u):
    q = code_of_table(T)
    codes_g.append("00" + q); codes_h.append("011000" + q)
decider = "010000"
allcodes = codes_g + codes_h + [decider] + ["1"]      # "1" stands for every program 1^c p (all begin with 1)
allcodes_sorted = sorted(allcodes)
prefix_free = all(not allcodes_sorted[i + 1].startswith(allcodes_sorted[i]) for i in range(len(allcodes_sorted) - 1))
kraft_g = sum(Fr(1, 2**len(cw)) for cw in codes_g)
kraft_h = sum(Fr(1, 2**len(cw)) for cw in codes_h)
print("(E6) machine U'', d = 3: codes of g_T, h_T, the decider and the prefix 1 form a prefix-free set: %s;" % prefix_free)
print("     weight of all g_T = %.6f = (1/8)(1+1/(2u))^u: %s; of all h_T = %.6f = (1/128)(1+1/(2u))^u: %s; decider 2^-6; total without the programs of U = %.4f"
      % (float(kraft_g), kraft_g == Fr(1, 8) * (1 + Fr(1, 2 * u))**u, float(kraft_h), kraft_h == Fr(1, 128) * (1 + Fr(1, 2 * u))**u,
         float(kraft_g + kraft_h + Fr(1, 64))))
ratio = set()
for T in list(tables(u))[:200]:
    q = code_of_table(T)
    ratio.add((Fr(1, 2**len("00" + q)) + Fr(1, 2**len("011000" + q))) / Fr(1, 2**len("011000" + q)))
print("     (weight of g_T + weight of h_T) / weight of h_T =", ratio, "(closure constant of the memoriser part)")

def Udd_values(c, data, x, base_never_b=True):
    """Mixture of U'' at the unseen input x.  The programs of U are replaced by the worst case for the lower bound:
       total weight 2^-c on a hypothesis that fits the data and never answers b."""
    tot = Fr(1, 2**c)                                 # all programs 1^c p, likelihood 1, never b
    bad = Fr(0)
    if len(data) == 0:
        tot += Fr(1, 64)                              # the decider gives no answer on X: likelihood 1 only for empty data
    for T in tables(u):
        if any(T[xi] != yi for xi, yi in data):
            continue
        size = sum(v is not None for v in T)
        wg = Fr(1, 8) * Fr(1, (4 * u)**size); wh = wg / 16
        tot += wg + wh
        if T[x] is None:
            bad += wg
    return bad / tot

okb = True; minV = {}
for c in (5, 10, 15, 20, 30):
    for k in range(0, 4):
        data = [(i, i % 2) for i in range(k)]
        Mb = Udd_values(c, data, u - 1)
        V = Fr(u - k, u) * Mb
        if k >= 1:
            bound = Fr(16, 17) * Fr(2 * u, 2 * u + 1) / (1 + Fr(2**3, 2**c) * (4 * u)**k)
            okb &= Mb >= bound
        if 1 <= k <= min(u // 4, (c - 5) // (d + 2)):
            okb &= V >= Fr(3, 4) * Fr(16, 17) * Fr(10, 11) * Fr(4, 5)
            minV[c] = min(minV.get(c, 1), float(V))
        if k == 0:
            okb &= V >= Fr(7, 10)
print("     lower bound M_D(b|x) >= (16/17)(2u/(2u+1))/(1 + 2^(3-c)(4u)^k) for k >= 1, V >= 0.5134 for 1 <= k <= min(u/4,(c-5)/(d+2)), V >= 0.70 for k = 0: %s" % okb)
print("     least V over the admissible k, by c:", {c: round(v, 4) for c, v in minV.items()}, " (3/4)(16/17)(10/11)(4/5) = %.4f" % (0.75 * 16 / 17 * 10 / 11 * 0.8))

# ---------------------------------------------------------------------------
# (E7) 4.13, item 5: the coin bound.  Memorisers and one fair coin (Proposition 4.10), n distinct inputs:
#      V(D_n) <= 1/2 + (k_c ln 2 + ln(1/delta))/(2n) with 2^-k_c the weight of the coin; here the left side
#      does not depend on which distinct inputs were drawn, so the bound must hold outright.
okc = True; rows = []
for (uu, K, kc) in ((2**20, 1000, 20), (16, 40, 3), (16, 40, 30), (2**10, 300, 100)):
    gam = Fr(1, 2**kc)
    for n in range(1, 60):
        if n > uu:
            break
        mem = (1 - gam) * (1 - Fr(1, 2**K)) * Fr(1, (4 * uu + 2)**n)
        Mn = (1 - gam) * Fr(1, 2**K) + mem + gam * Fr(1, 2**n)
        V = Fr(uu - n, uu) * Fr(2 * uu, 2 * uu + 1) * mem / Mn
        for delta in (0.5, 0.1, 0.01):
            okc &= float(V) <= 0.5 + (kc * log(2) + log(1 / delta)) / (2 * n) + 1e-12
    rows.append((uu, K, kc))
print("(E7) coin bound V(D_n) <= 1/2 + (k_c ln 2 + ln(1/delta))/(2n) in the classes of Proposition 4.10 %s, n < 60: %s" % (rows, okc))

# ---------------------------------------------------------------------------
# (E8) Proposition 6.4 (two answers per probe): E[s] = sum_y (P(y) - A(y))^2 and -1/2 <= s <= 2, exact, on a grid of laws.
def laws(q, den):
    for comp in itertools.product(range(den + 1), repeat=q - 1):
        if sum(comp) <= den:
            yield [Fr(c, den) for c in comp] + [Fr(den - sum(comp), den)]
oke = True; smin = Fr(10); smax = Fr(-10); cnt = 0
for q in (2, 3, 4):
    den = {2: 10, 3: 6, 4: 4}[q]
    L = list(laws(q, den))
    for P in L:
        for A in L:
            sumA2 = sum(a * a for a in A)
            Es = Fr(0)
            for y1 in range(q):
                for y2 in range(q):
                    s = (1 if y1 == y2 else 0) - A[y1] - A[y2] + sumA2
                    smin = min(smin, s); smax = max(smax, s)       # range over all pairs, whether or not P gives them
                    Es += P[y1] * P[y2] * s
            oke &= Es == sum((p - a)**2 for p, a in zip(P, A))
            # per-input step of (c): TV <= (sqrt(q)/2) d
            tv = sum(abs(p - a) for p, a in zip(P, A)) / 2
            oke &= float(tv) <= sqrt(q) / 2 * sqrt(float(sum((p - a)**2 for p, a in zip(P, A)))) + 1e-12
            cnt += 1
print("(E8) Proposition 6.4: E[s] = sum_y (P(y)-A(y))^2 and TV <= (sqrt(q)/2) d on %d pairs of laws (q = 2, 3, 4): %s; range of s: [%s, %s] (claimed: within [-1/2, 2])"
      % (cnt, oke, smin, smax))

# ---------------------------------------------------------------------------
# (E9) Theorem 6.6 (answers from a large set).  P0 uniform on s answers; the other human uniform on a random half.
#  (i) one input asked r times: exact total variation between the two laws of the r answers (averaged over the half)
#      = (1/2) sum_j S(r,j) (s)_j | s^-r - (2/s)^r C(s-j, s/2-j)/C(s, s/2) |, against the bound C(r,2)/s;
#  (ii) brute force over all halves for small s, with an adaptive procedure on two inputs.
def stirling2(r):
    S = [[0] * (r + 1) for _ in range(r + 1)]
    S[0][0] = 1
    for n in range(1, r + 1):
        for j in range(1, n + 1):
            S[n][j] = j * S[n - 1][j] + S[n - 1][j - 1]
    return S[r]
def falling(s, j):
    out = 1
    for i in range(j):
        out *= (s - i)
    return out
def tv_one_input(s, r):
    S = stirling2(r)
    tot = Fr(0)
    for j in range(1, r + 1):
        p0 = Fr(1, s**r)
        p1 = Fr(2**r, s**r) * Fr(comb(s - j, s // 2 - j), comb(s, s // 2)) if j <= s // 2 else Fr(0)
        tot += S[j] * falling(s, j) * abs(p0 - p1)
    return tot / 2
print("(E9) Theorem 6.6: one input asked r times; exact total variation of the two laws of the answers against C(r,2)/s")
okl = True
for s, r in ((4, 2), (4, 3), (8, 3), (16, 4), (256, 2), (256, 8), (4096, 8), (4096, 32), (65536, 32), (65536, 128)):
    tv = tv_one_input(s, r); bd = Fr(comb(r, 2), s)
    okl &= tv <= bd
    print("     s = %6d, r = %3d: TV = %.5f, bound C(r,2)/s = %.5f" % (s, r, float(tv), float(bd)))
print("     TV <= C(r,2)/s in all cases:", okl)

def transcript_law(s, m, proc, human):
    """exact law of the transcript of an adaptive deterministic procedure with m questions on inputs {0,1};
       human[x] is the list of answers (uniform on it).  proc(history) -> input."""
    law = {(): Fr(1)}
    for _ in range(m):
        new = {}
        for hist, pr in law.items():
            x = proc(hist)
            sup = human[x]
            for y in sup:
                h2 = hist + ((x, y),)
                new[h2] = new.get(h2, 0) + pr * Fr(1, len(sup))
        law = new
    return law
def adaptive(hist):                                   # asks input 0; goes on with input 0 after a repeated answer, else moves to input 1
    if not hist:
        return 0
    ys = [y for (x, y) in hist if x == 0]
    return 0 if (len(ys) != len(set(ys)) or len(hist) % 2 == 1) else 1
okbf = True; rep = []
for s, m in ((4, 2), (4, 3), (4, 4), (6, 3), (6, 4), (8, 3)):
    halves = list(itertools.combinations(range(s), s // 2))
    full = list(range(s))
    for name, proc in (("same input", lambda h: 0), ("adaptive, two inputs", adaptive)):
        law0 = transcript_law(s, m, proc, {0: full, 1: full})
        avg = {}
        for H0 in halves:
            for H1 in (halves if name != "same input" else [halves[0]]):
                lawH = transcript_law(s, m, proc, {0: list(H0), 1: list(H1)})
                wgt = Fr(1, len(halves) * (len(halves) if name != "same input" else 1))
                for hst, pr in lawH.items():
                    avg[hst] = avg.get(hst, 0) + wgt * pr
        keys = set(law0) | set(avg)
        tv = sum(abs(law0.get(kk, 0) - avg.get(kk, 0)) for kk in keys) / 2
        okbf &= tv <= Fr(comb(m, 2), s)
        if name == "same input":
            okbf &= tv == tv_one_input(s, m)
        rep.append("s=%d m=%d %s: %.4f <= %.4f" % (s, m, name, float(tv), comb(m, 2) / s))
print("     brute force over all halves (exact): " + "; ".join(rep))
print("     all within the bound, and the one-input cases equal the closed form:", okbf)

# ---------------------------------------------------------------------------
# (E10) Remark (3) after Theorem 4.5: a prior lam on the answer a memoriser gives outside its table (b, or an
#       abiding answer g that the human never gives).  Brute force, u = 4, K = 30, one pair seen.
def default_prior(u, K, lam_b, data, x):
    c0 = (1 - Fr(1, 2**K)) / (1 + Fr(1, 2 * u))**u
    tot = Fr(1, 2**K); bad = Fr(0)
    for T in tables(u):
        if any(T[xi] != yi for xi, yi in data):
            continue
        base = c0 * Fr(1, (4 * u)**sum(v is not None for v in T))
        tot += base                                   # both defaults fit the data equally
        if T[x] is None:
            bad += lam_b * base
    return bad / tot
uu, KK, kk = 4, 30, 1
thm45b = Fr(2 * uu, 2 * uu + 1) / (1 + Fr((4 * uu + 2)**kk, 2**KK - 1))
vals = [(lam, default_prior(uu, KK, lam, [(0, 0)], 1)) for lam in (Fr(1), Fr(1, 2), Fr(1, 50))]
print("(E10) memorisers with a prior lam(b) on the default answer, u = 4, K = 30, one pair seen: M_D(b|x) =",
      ", ".join("%.3f for lam(b) = %s" % (float(v), lam) for lam, v in vals),
      "; equals lam(b) x value of Theorem 4.5(b):", all(v == lam * thm45b for lam, v in vals))

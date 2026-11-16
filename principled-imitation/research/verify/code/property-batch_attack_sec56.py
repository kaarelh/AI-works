# Adversary's checks of Sections 5 and 6 of research/prove-c/property-batch.md (the two prices; the certificate; what single answers certify).
# Exact enumeration with rational arithmetic.  Pure Python.  Run:  python3 property-batch_attack_sec56.py > property-batch_attack_sec56.out
import math, random, itertools
from fractions import Fraction as Fr
from math import log, sqrt
random.seed(99)

def kl(p, q):
    if p == q: return 0.0
    if q <= 0.0 or q >= 1.0: return float('inf')
    s = 0.0
    if p > 0: s += p*log(p/q)
    if p < 1: s += (1-p)*log((1-p)/(1-q))
    return s

# ================================================================ (A) Proposition 5.2(a), exact over ALL functions
# inputs: d-bit strings, uniform; P0 = fair coin; tests: for every pair (input bit i, value a) and answer c: {x_i = a, y = c};
# for every pair of bits the parity test {x_i xor x_j xor y = 0}; the tests {y = c}.  Equal weights.
d = 4; u = 2**d; X = list(range(u))
def bit(x, i): return (x >> i) & 1
tests = []
for c in (0, 1):
    tests.append(lambda x, y, c=c: y == c)
    for i in range(d):
        for a in (0, 1): tests.append(lambda x, y, i=i, a=a, c=c: bit(x, i) == a and y == c)
for i in range(d):
    for j in range(i+1, d): tests.append(lambda x, y, i=i, j=j: (bit(x, i) ^ bit(x, j) ^ y) == 0)
nT = len(tests); pi = 1.0/nT
# table[t][x][y]
tab = [[[1 if t(x, y) else 0 for y in (0, 1)] for x in X] for t in tests]
coin_freq = [sum(tab[t][x][0] + tab[t][x][1] for x in X)/(2.0*u) for t in range(nT)]
print(f"(A) Proposition 5.2(a), exact over all 2^{u} functions f (uniform law on {u} inputs, fair coin, {nT} tests of equal weight):")
for eta in (0.5, 0.1, 0.01):
    bound = sqrt(log(2/(pi*eta))/(2*u)); bad = 0; worst = 0.0
    for fm in range(2**u):
        dev = 0.0
        for t in range(nT):
            fr = sum(tab[t][x][(fm >> x) & 1] for x in X)/u
            dev = max(dev, abs(fr - coin_freq[t]))
        worst = max(worst, dev)
        if dev > bound + 1e-12: bad += 1
    print(f"    eta = {eta}: bound sqrt(coll ln(2/(pi eta))/2) = {bound:.4f}; fraction of functions with some test beyond the bound = {bad/2**u:.6f} (must be <= eta); largest deviation over all f = {worst:.4f}")
print("    TV(Q_f, Q_coin) = 1/2 for every f (part (b)); with only 16 inputs the bound is weak, the check is of the probability statement.")

# ================================================================ (B) Is the coin a MEMBER of the matching set M_N when the human is a random function?  exact
# u inputs uniform, N recorded runs (x_i, F(x_i)); tests: the 2u singletons {(x, y)} plus {y = 1}; kl-form matching at level delta.
def coin_in_MN_prob(u, N, delta):
    tests = [("pair", x, y) for x in range(u) for y in (0, 1)] + [("y1",)]
    pi = 1.0/len(tests)
    a = log(2/(pi*delta))/N
    qcoin = {t: (1.0/(2*u) if t[0] == "pair" else 0.5) for t in tests}
    def matches(sample):
        for t in tests:
            if t[0] == "pair": fr = sum(1 for s in sample if s == (t[1], t[2]))/N
            else: fr = sum(1 for s in sample if s[1] == 1)/N
            if kl(fr, qcoin[t]) > a + 1e-12: return False
        return True
    # (i) data from a random function F: enumerate inputs and the function values at the distinct inputs
    p_fail_F = Fr(0); p_coll = Fr(0)
    for xs in itertools.product(range(u), repeat=N):
        distinct = sorted(set(xs))
        if len(distinct) < N: p_coll += Fr(1, u**N)
        for vals in itertools.product((0, 1), repeat=len(distinct)):
            Fv = dict(zip(distinct, vals))
            sample = [(x, Fv[x]) for x in xs]
            if not matches(sample): p_fail_F += Fr(1, u**N)*Fr(1, 2**len(distinct))
    # (ii) data from the coin itself
    p_fail_coin = Fr(0)
    for xs in itertools.product(range(u), repeat=N):
        for ys in itertools.product((0, 1), repeat=N):
            if not matches(list(zip(xs, ys))): p_fail_coin += Fr(1, u**N)*Fr(1, 2**N)
    return float(p_fail_F), float(p_fail_coin), float(p_coll)
print("(B) Human = a random function F, imitator = the coin: probability (over F and N recorded runs) that the coin is NOT in the matching set M_N")
print("    (kl form, level delta), exact; it is at most [the same probability for data from the coin, <= delta] + Pr[two recorded inputs coincide]:")
for (u, N, delta) in ((6, 3, 0.5), (8, 4, 0.5), (8, 4, 0.2), (10, 5, 0.5)):
    pF, pc, pcol = coin_in_MN_prob(u, N, delta)
    print(f"    u = {u}, N = {N}, delta = {delta}: Pr[coin not in M_N | human = F] = {pF:.5f}; Pr[coin not in M_N | human = coin] = {pc:.5f}; Pr[collision] = {pcol:.5f}; sum = {pc+pcol:.5f}")

# ================================================================ (C) Example 5.3, exact: per-call frequencies against the run test
u = 16
print(f"(C) Example 5.3 (the same question twice; human = coin; imitator = a function g on {u} inputs), all 2^{u} functions g, tests of (A):")
worst_g = 0.0; cnt_good = 0
bound = sqrt(log(2/(pi*0.5))/(2*u))
for gm in range(2**u):
    dev = max(abs(sum(tab[t][x][(gm >> x) & 1] for x in X)/u - coin_freq[t]) for t in range(nT))
    if dev <= bound: cnt_good += 1
print(f"    fraction of g with all per-call frequencies within {bound:.4f} of the human's: {cnt_good/2**u:.4f} (at least 1/2 by Proposition 5.2(a) with eta = 1/2);")
print("    for every g the run test 'the two answers agree' has probability 1 (imitator) against 1/2 (human system): difference 1/2.")

# ================================================================ (D) Theorem 6.1 / V1(b): which average estimates Delta(B)
# scaffold: horizon L = 2; a run makes 1 call with probability 1/2 and 2 calls with probability 1/2; all calls put the same input;
# imitator answers 1 always; human answers 1 with probability 1/4.  B = {answer = 1}.
L = 2; Elen = Fr(3, 2)
aB = Elen*1/L; hB = Elen*Fr(1, 4)/L; Delta = aB - hB
p_nonempty = Elen/L
mean_all_rounds = Delta                               # E[alpha_i - eta_i], empty rounds counted as 0
mean_nonempty_only = Delta/p_nonempty                 # average over the non-empty rounds only
print(f"(D) V1(b) with runs of variable length (L = 2, E[len] = 3/2): Delta(B) = {Delta} = {float(Delta):.4f};")
print(f"    mean of the recorded difference over ALL m rounds (empty rounds count 0) = {float(mean_all_rounds):.4f};  over the non-empty rounds only = {float(mean_nonempty_only):.4f} (= Delta x L/E[len])")

# ================================================================ (E) Theorem 6.2(c), exact, for a human P0 that is neither uniform nor binary
def run_procedure(proc, m, answer_law, lazy):
    """exact acceptance probability.  proc: dict history(tuple of (x,y)) -> next input; accept: set of full histories.
    answer_law(x) -> dict y -> prob.  lazy=True: the human is a random function drawn from the law (answers at repeated inputs repeat)."""
    nxt, acc = proc
    def rec(hist, prob, memo):
        if len(hist) == m: return prob if hist in acc else Fr(0)
        x = nxt[hist]
        if lazy and x in memo: return rec(hist + ((x, memo[x]),), prob, memo)
        tot = Fr(0)
        for y, p in answer_law(x).items():
            if p == 0: continue
            m2 = dict(memo); m2[x] = y
            tot += rec(hist + ((x, y),), prob*p, m2)
        return tot
    return rec((), Fr(1), {})
def repeat_prob(proc, m, answer_law):
    nxt, _ = proc
    def rec(hist, prob):
        if len(hist) == m: return Fr(0)
        x = nxt[hist]
        if any(x == h[0] for h in hist): return prob
        return sum(rec(hist + ((x, y),), prob*p) for y, p in answer_law(x).items() if p > 0)
    return rec((), Fr(1))
def random_procedure(u, Yv, m, allow_repeat):
    nxt = {}; acc = set()
    def build(hist):
        if len(hist) == m:
            if random.random() < 0.5: acc.add(hist)
            return
        used = {h[0] for h in hist}
        choices = list(range(u)) if allow_repeat else [x for x in range(u) if x not in used]
        x = random.choice(choices); nxt[hist] = x
        for y in Yv: build(hist + ((x, y),))
    build(()); return nxt, acc
u, Yv, m = 5, (0, 1, 2), 3
law = [{0: Fr(1, 2), 1: Fr(1, 3), 2: Fr(1, 6)}, {0: Fr(1, 10), 1: Fr(9, 10), 2: Fr(0)}, {0: Fr(1, 3), 1: Fr(1, 3), 2: Fr(1, 3)},
       {0: Fr(0), 1: Fr(0), 2: Fr(1)}, {0: Fr(3, 4), 1: Fr(0), 2: Fr(1, 4)}]
al = lambda x: law[x]
eq = True; gapmax = Fr(0); okrep = True
for _ in range(150):
    pr = random_procedure(u, Yv, m, allow_repeat=False)
    if run_procedure(pr, m, al, lazy=True) != run_procedure(pr, m, al, lazy=False): eq = False
for _ in range(150):
    pr = random_procedure(u, Yv, m, allow_repeat=True)
    g = abs(run_procedure(pr, m, al, lazy=True) - run_procedure(pr, m, al, lazy=False)); xi = repeat_prob(pr, m, al)
    gapmax = max(gapmax, g)
    if g > xi: okrep = False
print(f"(E) Theorem 6.2(c), exact (5 inputs, 3 answers, a human P0 that is not uniform, 3 adaptive questions):")
print(f"    150 procedures without repeated questions: E_F Pr_F[accept] = Pr_P0[accept] exactly: {eq};  150 procedures that may repeat: |difference| <= xi: {okrep} (largest difference {float(gapmax):.4f})")

# one-sidedness: for a FIXED f a one-question procedure separates P_f from the coin
print("    one question 'ask input 1, accept iff the answer is 0': Pr_coin[accept] = 1/2; Pr_f[accept] is 0 or 1 for every function f:")
print("    for each fixed f this procedure tells P_f from the coin with advantage 1/2; only the AVERAGE over f equals 1/2 (Theorem 6.2(c)), and (d) is one-sided.")
# repeated questions are allowed by A1 and separate the coin from EVERY function
print("    two questions 'ask input 1 twice, accept iff the two answers are equal': Pr_coin[accept] = 1/2, Pr_f[accept] = 1 for every f (here xi = 1).")
m_pairs = 50
p_all_equal_coin = 0.5**m_pairs
print(f"    with {m_pairs} inputs asked twice each: the coin gives {m_pairs} equal pairs with probability 2^-{m_pairs} = {p_all_equal_coin:.2e}; every function gives them with probability 1.")
print("    The statistic is the frequency of the test 'the two answers agree' of a derived run that puts one question twice; it is not a frequency of a test of single pairs.")

# ================================================================ (E2) two answers per input certify a distance between answer laws (A1 allows asking again)
ok2 = True
for pn in range(0, 11):
    for an in range(0, 11):
        p, a = Fr(pn, 10), Fr(an, 10)
        # y1, y2 independent Bernoulli(p); statistic (y1 - a)(y2 - a)
        mean = sum((Fr(y1) - a)*(Fr(y2) - a)*(p if y1 else 1-p)*(p if y2 else 1-p) for y1 in (0, 1) for y2 in (0, 1))
        if mean != (p - a)**2: ok2 = False
ok3 = True
for _ in range(300):
    g = [Fr(random.randrange(0, 6)) for _ in range(4)]; t = sum(g) or 1; Pv = [x/t for x in g] if sum(g) else [Fr(1), 0, 0, 0]
    g = [Fr(random.randrange(0, 6)) for _ in range(4)]; Av = [x/sum(g) for x in g] if sum(g) else [Fr(1), 0, 0, 0]
    sA = sum(x*x for x in Av)
    mean = sum(Pv[y1]*Pv[y2]*((1 if y1 == y2 else 0) - Av[y1] - Av[y2] + sA) for y1 in range(4) for y2 in range(4))
    if mean != sum((x-y)**2 for x, y in zip(Pv, Av)): ok3 = False
print("(E2) Two answers y1, y2 of the human to ONE input x, imitator's law A(.|x) known:")
print(f"    binary answers: E[(y1 - a)(y2 - a)] = (p - a)^2 for all p, a in {{0, 0.1, ..., 1}}: {ok2}  (a = A(1|x), p = P(1|x))")
print(f"    four answers:   E[1(y1 = y2) - A(y1|x) - A(y2|x) + sum_y A(y|x)^2] = sum_y (P(y|x) - A(y|x))^2 on 300 random pairs of laws: {ok3}")
print("    imitator = coin: the statistic is 1/4 with certainty if the human is ANY function, and has mean 0 if the human is the coin.")
for mp in (25, 100, 400):
    # Hoeffding for an average of mp independent terms in [-1/4, 1/4] (coin human): Pr[average >= 1/8] <= exp(-2 mp (1/8)^2/(1/2)^2)
    print(f"    {mp} inputs asked twice ({2*mp} answers): Pr[the average statistic of a coin human reaches 1/8] <= {math.exp(-2*mp*(1/8)**2/(1/2)**2):.2e}; a function human gives 1/4 always.")
print("    So for binary answers, m probe inputs asked twice (2m answers) certify E_x (P(1|x) - A(1|x))^2 on the probe distribution to within")
print("    sqrt(2 ln(2/delta)/m) (Hoeffding, terms in [-1, 1]), and the mean total variation per call is at most the square root of that number.")

# ================================================================ (F) with repetitions and a large answer set: uniform on s answers against uniform on a random half
print("(F) Repetitions allowed, answer set of size s at each input: P0 uniform on s answers; P_F uniform on a random half of them (TV = 1/2 at every input).")
print("    r answers to ONE input: total variation between the two laws of the r answers (exact; the law depends only on the pattern of coincidences):")
def tv_r_answers(s, r):
    # P0: i.i.d. uniform on s.  P_F: i.i.d. uniform on a uniformly random subset of size s/2.
    # Both laws are exchangeable in the labels; probability of a sequence with j distinct values:
    #   P0: s^-r;   P_F: (2/s)^r * C(s-j, s/2-j)/C(s, s/2).
    # number of sequences of length r with exactly j distinct values out of s: C(s, j) * surj(r, j)
    from math import comb
    def surj(r, j): return sum((-1)**i*comb(j, i)*(j-i)**r for i in range(j+1))
    tot = Fr(0)
    for j in range(1, min(r, s)+1):
        cnt = comb(s, j)*surj(r, j)
        p0 = Fr(1, s**r)
        pF = Fr(2, s)**r*Fr(comb(s-j, s//2-j), comb(s, s//2)) if j <= s//2 else Fr(0)
        tot += cnt*abs(p0 - pF)
    return float(tot/2)
for (s, r) in ((16, 2), (256, 2), (256, 8), (4096, 8), (4096, 32), (2**16, 32)):
    print(f"    s = {s:6d}, r = {r:3d}: TV = {tv_r_answers(s, r):.5f}   (r^2/s = {r*r/s:.4f})")

# ================================================================ (G) Example 6.3: equal frequencies, but one question separates
d = 5; u = 2**d
par = [bin(x).count("1") & 1 for x in range(u)]
okG = True
for _ in range(300):
    i = random.randrange(d)
    # a random test that ignores bit i
    base = {}
    for x in range(u):
        key = x & ~(1 << i)
        if key not in base: base[key] = (random.randrange(2), random.randrange(2))
    Bset = lambda x, y: base[x & ~(1 << i)][y] == 1
    f_freq = Fr(sum(1 for x in range(u) if Bset(x, par[x])), u)
    c_freq = Fr(sum((1 if Bset(x, 0) else 0) + (1 if Bset(x, 1) else 0) for x in range(u)), 2*u)
    if f_freq != c_freq: okG = False
print(f"(G) Example 6.3 (d = {d}): parity and the coin have exactly equal frequencies on 300 random tests that ignore one input bit: {okG};")
print("    but the single question 'ask any x, accept iff y = parity(x)' accepts the parity human with probability 1 and the coin with probability 1/2:")
print("    Example 6.3 is an example of equal test frequencies, not of two humans that m answers cannot tell apart.")

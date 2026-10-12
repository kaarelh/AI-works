"""Independent checks for Paper 1, Section 4 (learn) and Appendix C.

Reviewer p1-math-A. Exact rationals where possible; seed 777.
Checks:
  (1) prop:learn:freshnoise: exact P(D_n consistent) for 10 uniform inputs, fair-coin labels (paper:
      0.95, 0.113, 5e-4 at n=2,10,20); bound (b) for several (alpha, p); the proof's displayed sum with
      j starting at 0 versus the correct expression.
  (2) prop:learn:curve: closed forms r_0, r_1, r_t = 2^{1-t} r_1 versus brute-force enumeration of
      i.i.d. samples (t <= 6); threshold (1+w)^3 > 8w; value 0.128 at 1/5; sum = log2(1/w).
  (3) rem:learn:increasing numbers (|B|=16, w=w_f=1/17): last step 1 bit, average 0.255,
      each LOO error 1/2, LOO sum 8 versus bound 16.
  (4) prop:learn:active: mean of min(pos(a), N-1) over a for the best order >= (N-1)/2.
  (5) prop:learn:typical / cor:learn:perstep constants: (1-2^-l)^n >= 1/2 and
      (1/2) 2^-l (l+1)^-2 >= 1/(8 n (log n + 3)^2), l = ceil(log n)+1; eps choice in (a).
  (6) Finite Bayes mixture of deterministic partial functions on a 5-point domain (an exact analogue
      of W or M_F): random splits identity (prop:learn:splits), LOO disjointness bound
      (prop:learn:loo), exchangeability bound cor:learn:perstep(b) for i.i.d. inputs (n<=4),
      Markov form (a), and e^wr <= e_norm <= e at every test point.
  (7) Merging identity for a finite mixture containing a total-function law nu:
      sum_t E d_t = E log(nu(D_n)/M(D_n)) <= -log w_nu, for i.i.d. and an adaptive past-only rule.
  (8) Pinsker for sub-probabilities in bits and the integrability inequality, random tests.
"""
from fractions import Fraction as Fr
from itertools import product, permutations, combinations
import math, random

random.seed(777)
log2 = math.log2

print("(1) fresh noise")
def p_consistent(m, n):
    # inputs uniform on m points, fair-coin labels: E[2^{-(n - #distinct)}]
    # dp over number of distinct
    dist = {0: Fr(1)}
    for _ in range(n):
        new = {}
        for k, p in dist.items():
            new[k + 1] = new.get(k + 1, 0) + p * Fr(m - k, m)
            if k:
                new[k] = new.get(k, 0) + p * Fr(k, m)
        dist = new
    return sum(p * Fr(1, 2 ** (n - k)) for k, p in dist.items())
for n in (2, 10, 20):
    print("   n=%d  P(consistent)=%.6g" % (n, float(p_consistent(10, n))))
# bound (b): P(labels at x0 agree) <= (1-a)^n + p^-1 (1-a+a p)^n ; exact agree prob for labels {0,1} with probs (p,1-p)
ok = True
for a in (0.05, 0.1, 0.3, 0.7):
    for pm in (0.5, 0.6, 0.9):
        probs = [pm, 1 - pm]
        for n in (2, 5, 10, 30):
            exact = sum(comb_ * a ** j * (1 - a) ** (n - j) * (sum(q ** j for q in probs) if j else 1)
                        for j in range(n + 1) for comb_ in [math.comb(n, j)])
            bound = (1 - a) ** n + (1 - a + a * pm) ** n / pm
            if exact > bound + 1e-12:
                ok = False
            # the paper's displayed sum with j from 0 including sum_y P^0 = |supp| = 2
            paper = sum(math.comb(n, j) * a ** j * (1 - a) ** (n - j) * sum(q ** j for q in probs) for j in range(n + 1))
            if n == 2 and a == 0.3 and pm == 0.5:
                print("   a=0.3, p=(1/2,1/2), n=2: correct agree-prob %.4f ; paper's j>=0 formula %.4f ; bound %.4f" % (exact, paper, bound))
print("   bound (b) holds in all cases:", ok)

print("(2) learning curve example")
def curve_bruteforce(w, tmax):
    # hypotheses on X={a,b}: phi=00 weight w, 10, 01 weight (1-w)/2; target 00, mu uniform
    H = {(0, 0): w, (1, 0): (1 - w) / 2, (0, 1): (1 - w) / 2}
    res = []
    for t in range(tmax + 1):
        r = Fr(0) if isinstance(w, Fr) else 0.0
        tot = 0.0
        for seq in product((0, 1), repeat=t):
            seen = set(seq)
            post = {h: v for h, v in H.items() if all(h[i] == 0 for i in seen)}
            Z = sum(post.values())
            risk = 0.0
            for x in (0, 1):
                if x in seen:
                    continue
                pr0 = sum(v for h, v in post.items() if h[x] == 0) / Z
                risk += 0.5 * -log2(float(pr0))
            tot += risk * 0.5 ** t
        res.append(tot)
    return res
for w in (Fr(1, 16), Fr(1, 5), Fr(1, 4)):
    bf = curve_bruteforce(w, 6)
    r0 = -log2((1 + w) / 2); r1 = 0.5 * log2((1 + w) / (2 * w))
    closed = [r0] + [2 ** (1 - t) * r1 for t in range(1, 7)]
    print("   w=%s: brute %s ; closed-form match %s ; r1>r0 %s ; (1+w)^3>8w %s ; r0+2r1=%.4f log(1/w)=%.4f" % (
        w, [round(x, 4) for x in bf[:3]], all(abs(a - b) < 1e-12 for a, b in zip(bf, closed)), r1 > r0,
        (1 + w) ** 3 > 8 * w, r0 + 2 * r1, log2(1 / w)))
f = lambda w: (1 + w) ** 3 - 8 * w
print("   (1+w)^3-8w at 1/5 = %.4f ; decreasing on [0,1/5]: %s ; root in (0,1): %.4f" % (
    f(0.2), all(f(i / 1000) > f((i + 1) / 1000) for i in range(200)),
    next(i / 10000 for i in range(1, 10000) if f(i / 10000) <= 0)))

print("(3) learning curves can increase")
B = 16; w = Fr(1, 17); wf = Fr(1, 17)
steps = [log2(float((wf + w * (B - k + 1)) / (wf + w * (B - k)))) for k in range(1, B + 1)]
print("   last step %.4f, average %.4f, increasing %s" % (steps[-1], sum(steps) / B, all(steps[i] < steps[i + 1] for i in range(B - 1))))
eloo = 1 - wf / (wf + w)
print("   each LOO error %s ; LOO sum %s ; bound (nu(empty)-nu(f))/nu(f) = %s" % (eloo, B * eloo, (1 - wf) / wf))

print("(4) active learning lower bound")
for d in range(1, 12):
    N = 2 ** d
    mean = Fr(sum(range(1, N)) + (N - 1), N)
    assert mean >= Fr(N - 1, 2)
print("   mean >= (N-1)/2 for d=1..11: True (e.g. d=3: %s vs %s)" % (Fr(sum(range(1, 8)) + 7, 8), Fr(7, 2)))

print("(5) constants of prop:learn:typical and cor:learn:perstep")
ok = True
for n in list(range(1, 5000)) + [10 ** k for k in range(4, 13)]:
    l = math.ceil(log2(n)) + 1
    if (1 - 2.0 ** -l) ** n < 0.5:
        ok = False
    if 0.5 * 2.0 ** -l * (l + 1) ** -2 < 1 / (8 * n * (log2(n) + 3) ** 2) - 1e-18:
        ok = False
print("   both inequalities for n in [1,5000] and 10^4..10^12:", ok)
ok = True
for K in (0, 1, 5, 20):
    for n in (2, 10, 1000, 10 ** 6):
        eps = (K * math.log(2) + math.log(n)) / n
        if abs(2 ** K * math.exp(-eps * n) - 1 / n) > 1e-12:
            ok = False
print("   eps choice makes the second term exactly 1/n:", ok)

print("(6) finite mixture over deterministic partial functions on 5 points")
X = list(range(5))
hyps = []
for vals in product((None, 0, 1), repeat=5):
    hyps.append(vals)
weights = [random.random() ** 3 for _ in hyps]
s = sum(weights) * 1.1   # nu(empty) < 1, like W
weights = [Fr(round(v / s * 10 ** 6), 10 ** 6) for v in weights]
nu_empty = sum(weights)
f = (1, 0, 1, 1, 0)
def nu(D):
    return sum(wt for h, wt in zip(hyps, weights) if all(h[x] == y for x, y in D.items()))
# splits identity on B = all 5 points
Bset = X
tot = Fr(0)
for order in permutations(Bset):
    for k in range(1, len(Bset) + 1):
        D = {x: f[x] for x in order[:k - 1]}
        x = order[k - 1]
        tot += Fr(1) * 0  # placeholder for exact; use float below
loss_sum = 0.0
for order in permutations(Bset):
    for k in range(1, len(Bset) + 1):
        D = {x: f[x] for x in order[:k - 1]}
        x = order[k - 1]
        loss_sum += -log2(float(nu({**D, x: f[x]}) / nu(D)))
avg = loss_sum / (math.factorial(5) * 5)
print("   splits: expected test loss %.10f ; -log(nu(f|B)/nu(empty))/|B| = %.10f" % (avg, -log2(float(nu({x: f[x] for x in X}) / nu_empty)) / 5))
# LOO bound for every subset B
okloo = True
for r in range(1, 6):
    for Bs in combinations(X, r):
        fB = {x: f[x] for x in Bs}
        s_ = sum(1 - nu(fB) / nu({x: f[x] for x in Bs if x != z}) for z in Bs)
        if s_ > (nu_empty - nu(fB)) / nu(fB):
            okloo = False
print("   LOO bound on all 31 subsets:", okloo)
# e^wr <= e_norm <= e
okerr = True
for r in range(0, 5):
    for A in combinations(X, r):
        D = {x: f[x] for x in A}
        for xs in X:
            if xs in A:
                continue
            base = nu(D)
            e = 1 - nu({**D, xs: f[xs]}) / base
            Z = nu({**D, xs: 0}) + nu({**D, xs: 1})
            enorm = 1 - nu({**D, xs: f[xs]}) / Z
            ewr = nu({**D, xs: 1 - f[xs]}) / base
            if not (ewr <= enorm <= e):
                okerr = False
print("   e^wr <= e_norm <= e at every (A, x*):", okerr)
# exchangeability bound (b) and Markov form (a) with mu non-uniform
mu = [Fr(1, 2), Fr(1, 4), Fr(1, 8), Fr(1, 16), Fr(1, 16)]
okb = True
for n in range(1, 5):
    Ee = Fr(0); Eb = Fr(0)
    for seq in product(X, repeat=n + 1):
        p = Fr(1)
        for x in seq:
            p *= mu[x]
        train = seq[:n]; xs = seq[n]
        D = {x: f[x] for x in train}
        e = 0 if xs in D else 1 - nu({**D, xs: f[xs]}) / nu(D)
        Ee += p * e
        S = set(seq)
        fS = {x: f[x] for x in S}
        Eb += p * (nu_empty - nu(fS)) / ((n + 1) * nu(fS))
    # Markov form: min over eps of eps + nu(empty) e^{-eps n}/nu(f) (nu(f): full truth extension mass lower bound)
    nf = nu({x: f[x] for x in X})
    markov = min(eps + float(nu_empty) * math.exp(-eps * n) / float(nf) for eps in [i / 1000 for i in range(1, 1000)])
    print("   n=%d: E e(x*) = %.6f ; exchangeability bound %.6f ; Markov bound %.4f" % (n, float(Ee), float(Eb), markov))
    if not (Ee <= Eb and float(Ee) <= markov):
        okb = False
print("   bounds (a),(b) hold:", okb)

print("(7) merging identity for a finite mixture")
# nu: law of a random total function = uniform mixture over 3 total functions on 3 points
X3 = [0, 1, 2]
tot_funcs = list(product((0, 1), repeat=3))
nu_law = {g: Fr(1, 3) for g in [(0, 0, 1), (1, 0, 1), (1, 1, 0)]}
wnu = Fr(1, 4)
other = {g: Fr(1, 16) for g in tot_funcs}   # 8 total functions, weight 1/2 total
partial = {(None, 0, None): Fr(1, 4)}
def M(D):
    v = wnu * sum(p for g, p in nu_law.items() if all(g[x] == y for x, y in D.items()))
    v += sum(p for g, p in other.items() if all(g[x] == y for x, y in D.items()))
    v += sum(p for g, p in partial.items() if all(g[x] == y for x, y in D.items()))
    return v
def nuD(D):
    return sum(p for g, p in nu_law.items() if all(g[x] == y for x, y in D.items()))
def run(rule, n):
    # returns sum_t E d_t and E log(nu(D_n)/M(D_n)); rule(hist) -> distribution over next input
    sumd = 0.0; elog = 0.0
    def rec(hist, D, prob, F, t):
        nonlocal sumd, elog
        if t == n:
            elog += prob * log2(float(nuD(D) / M(D)))
            return
        for x, px in rule(hist).items():
            if x in D:
                rec(hist + [(x, D[x])], D, prob * px, F, t + 1)
                continue
            p = {y: nuD({**D, x: y}) / nuD(D) for y in (0, 1)}
            q = {y: M({**D, x: y}) / M(D) for y in (0, 1)}
            dt = sum(float(p[y]) * log2(float(p[y] / q[y])) for y in (0, 1) if p[y] > 0)
            sumd += prob * px * dt
            y = F[x]
            rec(hist + [(x, y)], {**D, x: y}, prob * px, F, t + 1)
    for F, pF in nu_law.items():
        rec([], {}, float(pF), F, 0)
    return sumd, elog
iid = lambda hist: {0: 0.5, 1: 0.3, 2: 0.2}
def adaptive(hist):
    if not hist:
        return {0: 1.0}
    return {1: 1.0} if hist[-1][1] == 0 else {2: 1.0}
for name, rule in (("iid", iid), ("adaptive (past only)", adaptive)):
    for n in (1, 2, 3):
        sd, el = run(rule, n)
        print("   %-21s n=%d: sum E d_t = %.12f ; E log(nu/M) = %.12f ; bound -log w = %.4f" % (name, n, sd, el, -log2(float(wnu))))

print("(8) Pinsker with sub-probabilities; integrability inequality")
okp = True; worst = 0.0
for _ in range(20000):
    k = random.randint(2, 5)
    p = [random.random() for _ in range(k)]; sp = sum(p); p = [v / sp for v in p]
    q = [random.random() for _ in range(k)]; sq = sum(q) / random.uniform(0.3, 1.0); q = [v / sq for v in q]
    kl = sum(pi * log2(pi / qi) for pi, qi in zip(p, q))
    l1 = sum(abs(pi - qi) for pi, qi in zip(p, q))
    if l1 ** 2 > 2 * math.log(2) * kl + 1e-12:
        okp = False
    integ = sum(pi * max(0.0, log2(qi / pi)) for pi, qi in zip(p, q))
    worst = max(worst, integ)
    if integ > math.log2(math.e) * sum(max(0.0, qi - pi) for pi, qi in zip(p, q)) + 1e-12:
        okp = False
print("   all inequalities hold:", okp, " largest sum p max(0,log q/p) = %.4f" % worst)

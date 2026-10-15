"""Reviewer p1-math-A (run 2): independent checks for Paper 1, learn.tex / app-learn.tex.

Finite analogues: "SFI" is replaced by a finite Bayes mixture of random partial functions with known
weights; K(nu) by -log2 of the weight. Exact arithmetic where cheap. Seed 20261012.
 (1) prop:learn:curve closed forms; threshold (1+w)^3 > 8w; w = 1/16 numbers; sum r_t = log2(1/w).
 (2) prop:learn:freshnoise: exact P(consistent) for m equally likely inputs, fair labels; bound (b).
 (3) rem:learn:increasing numbers (|B| = 16): last step 1 bit, random-split mean 0.2555, LOO errors 1/2.
 (4) prop:learn:loo and prop:learn:splits on random finite mixtures (deterministic partial + shared-tape).
 (5) cor:learn:perstep (b) exact on a 4-point domain and (a) with the finite-mixture constant.
 (6) thm:learn:merging finite analogue with adaptive (past-only) input rules; and a rule that sees F.
 (7) thm:learn:batch (a) finite analogue: sum_{t<n} E R(Q_t) <= -log2 w_target, E R(Qbar_n) <= that / n.
 (8) prop:learn:perquery (a) on a small class; positivity on inconsistent sequences.
 (9) prop:learn:typical arithmetic; prop:learn:active mean bound.
 (10) Pinsker for sub-probabilities (eq:learn:pinsker) on random pairs.
"""
from fractions import Fraction as Fr
from itertools import product, permutations, combinations
import math, random

random.seed(20261012)
BOT = None

print("(1) learning curve")
for w in (Fr(1, 2), Fr(1, 4), Fr(1, 5), Fr(1, 16), Fr(1, 100)):
    # hypotheses on (a,b): (0,0) weight w; (1,0),(0,1) weight (1-w)/2
    H = {(0, 0): w, (1, 0): (1 - w) / 2, (0, 1): (1 - w) / 2}
    def risk_after(seen):
        cons = {h: p for h, p in H.items() if all(h[i] == 0 for i in seen)}
        Z = sum(cons.values())
        r = 0.0
        for i in (0, 1):
            pr = sum(p for h, p in cons.items() if h[i] == 0) / Z
            r += 0.5 * -math.log2(pr)
        return r
    rs = []
    for t in range(0, 6):
        # expectation over i.i.d. uniform samples of the set seen
        tot = 0.0
        for seq in product((0, 1), repeat=t):
            tot += risk_after(set(seq)) / 2 ** t
        rs.append(tot)
    r0 = -math.log2((1 + w) / 2); r1 = 0.5 * math.log2((1 + w) / (2 * w))
    closed = abs(rs[0] - r0) < 1e-12 and abs(rs[1] - r1) < 1e-12 and all(abs(rs[t] - 2 ** (1 - t) * r1) < 1e-12 for t in range(1, 6))
    print(f"   w={w}: r0={rs[0]:.4f} r1={rs[1]:.4f} closed forms ok={closed} r1>r0={rs[1] > rs[0]} "
          f"(1+w)^3>8w={(1 + w) ** 3 > 8 * w} r0+2r1={r0 + 2 * r1:.4f} log2(1/w)={math.log2(1 / w):.4f}")
print("   root of (1+w)^3 = 8w in (0,1):", math.sqrt(5) - 2, " check:", (1 + math.sqrt(5) - 2) ** 3 - 8 * (math.sqrt(5) - 2))

print("(2) fresh noise")
def p_consistent(m, n):
    # exact: E[2^{-(n - #distinct)}] for n draws among m equally likely inputs, fair labels
    # = sum over occupancy; use DP over number of distinct inputs seen
    dist = {0: Fr(1)}
    for _ in range(n):
        new = {}
        for k, p in dist.items():
            new[k + 1] = new.get(k + 1, 0) + p * Fr(m - k, m)
            new[k] = new.get(k, 0) + p * Fr(k, m) * Fr(1, 2)  # repeat must agree with stored label
        dist = new
    return sum(dist.values())
for n in (2, 10, 20):
    print(f"   m=10, n={n}: P(consistent) = {float(p_consistent(10, n)):.6f}")
ok = True
for alpha in (0.05, 0.2, 0.5):
    for pmax in (0.5, 0.7, 0.9):
        for n in (2, 5, 20, 60):
            # exact P(labels at x0 agree) for a two-label law (pmax, 1-pmax)
            exact = sum(math.comb(n, j) * alpha ** j * (1 - alpha) ** (n - j) * (pmax ** j + (1 - pmax) ** j if j >= 1 else 1)
                        for j in range(n + 1))
            bound = (1 - alpha) ** n + (1 - alpha + alpha * pmax) ** n / pmax
            ok &= exact <= bound + 1e-12
print("   bound (b) holds on grid:", ok)

print("(3) rem:learn:increasing")
B = 16; w = Fr(1, B + 1); wf = w
steps = [math.log2(float((wf + w * (B - k + 1)) / (wf + w * (B - k)))) for k in range(1, B + 1)]
print(f"   last step {steps[-1]:.4f} bits; random-split mean {sum(steps) / B:.4f}; increasing {all(a < b for a, b in zip(steps, steps[1:]))};"
      f" LOO error each {float(1 - wf / (wf + w))}; LOO sum {B * float(1 - wf / (wf + w))} vs bound (nu(empty)-nu(f))/nu(f) = {float((wf + B * w - wf) / wf)}")

print("(4) leave-one-out and random splits on random finite mixtures")
def rand_mixture(B_pts, nh=12, tapes=False):
    hyps = []
    for _ in range(nh):
        wt = Fr(random.randint(1, 9), 1)
        if not tapes:
            f = tuple(random.choice([0, 1, BOT]) for _ in B_pts)
            hyps.append((wt, [(Fr(1), f)]))
        else:
            # shared-tape law: a small random law over functions
            fs = [tuple(random.choice([0, 1, BOT]) for _ in B_pts) for _ in range(3)]
            ps = [Fr(random.randint(1, 4)) for _ in fs]; s = sum(ps)
            hyps.append((wt, [(p / s, f) for p, f in zip(ps, fs)]))
    tot = sum(wt for wt, _ in hyps) * Fr(random.randint(10, 13), 10)  # nu(empty) < 1 as for W
    return [(wt / tot, comp) for wt, comp in hyps]
def nu_of(mix, D):
    return sum(wt * sum(p for p, f in comp if all(f[i] == y for i, y in D)) for wt, comp in mix)
viol_loo = 0; viol_split = 0; trials = 0
for trial in range(200):
    Bp = list(range(5))
    mix = rand_mixture(Bp, tapes=(trial % 2 == 1))
    target = tuple(random.choice([0, 1]) for _ in Bp)
    # ensure target has positive mass
    mix.append((Fr(1, 50), [(Fr(1), target)]))
    fB = [(i, target[i]) for i in Bp]
    nuB = nu_of(mix, fB); nu0 = nu_of(mix, [])
    loo = sum(1 - nuB / nu_of(mix, [(j, target[j]) for j in Bp if j != i]) for i in Bp)
    if not (loo <= (nu0 - nuB) / nuB):
        viol_loo += 1
    # random split expectation = -log(nuB/nu0)/|B|
    tot = 0.0
    for perm in permutations(Bp):
        for k in range(1, len(Bp) + 1):
            train = [(j, target[j]) for j in perm[:k - 1]]
            x = perm[k - 1]
            tot += -math.log2(float(nu_of(mix, train + [(x, target[x])]) / nu_of(mix, train)))
    tot /= math.factorial(len(Bp)) * len(Bp)
    if abs(tot - (-math.log2(float(nuB / nu0))) / len(Bp)) > 1e-9:
        viol_split += 1
    trials += 1
print(f"   trials {trials}: LOO bound violations {viol_loo}; split identity violations {viol_split}")

print("(5) per-step error, exchangeability form (b), exact")
viol_b = 0; viol_a = 0
for trial in range(40):
    X = list(range(4))
    mix = rand_mixture(X, nh=8, tapes=(trial % 2 == 0))
    target = tuple(random.choice([0, 1]) for _ in X)
    wt_target = Fr(1, 40)
    mix.append((wt_target, [(Fr(1), target)]))
    for n in range(1, 5):
        Ee = Fr(0); rhs = Fr(0)
        for seq in product(X, repeat=n + 1):
            p = Fr(1, len(X) ** (n + 1))
            train = sorted({(x, target[x]) for x in seq[:-1]})
            xs = seq[-1]
            if any(x == xs for x, _ in train):
                e = Fr(0)
            else:
                e = 1 - nu_of(mix, train + [(xs, target[xs])]) / nu_of(mix, train)
            Ee += p * e
            S = sorted({(x, target[x]) for x in seq})
            rhs += p * (nu_of(mix, []) - nu_of(mix, S)) / ((n + 1) * nu_of(mix, S))
        if Ee > rhs:
            viol_b += 1
        # (a) with constant: E e <= eps + (1/w_target) e^{-eps n}, minimised over eps grid
        best = min(eps + float(1 / wt_target) * math.exp(-eps * n) for eps in [i / 1000 for i in range(1, 1000)])
        if float(Ee) > best + 1e-12:
            viol_a += 1
print(f"   violations of (b): {viol_b}; of (a) with 2^K -> 1/w_target: {viol_a}")

print("(6) merging, finite analogue")
# class of random total functions on 3 inputs, labels {0,1}: product laws and shared-coin laws
X = [0, 1, 2]
def law_from_table(table):
    return table  # dict function-tuple -> prob
laws = []
for _ in range(5):
    ps = [Fr(random.randint(1, 9), 10) for _ in X]
    tab = {}
    for f in product((0, 1), repeat=3):
        pr = Fr(1)
        for i in X:
            pr *= ps[i] if f[i] == 1 else 1 - ps[i]
        tab[f] = pr
    laws.append(tab)
laws.append({(0, 0, 0): Fr(1, 2), (1, 1, 1): Fr(1, 2)})   # shared coin
laws.append({(0, 1, 1): Fr(1, 3), (1, 0, 0): Fr(2, 3)})
ws = [Fr(random.randint(1, 5)) for _ in laws]; s = sum(ws); ws = [w / s for w in ws]
def mixP(D):
    return sum(w * sum(p for f, p in L.items() if all(f[i] == y for i, y in D)) for w, L in zip(ws, laws))
def lawP(L, D):
    return sum(p for f, p in L.items() if all(f[i] == y for i, y in D))
worst_ratio = 0.0; maxsum = 0.0
for ti, L in enumerate(laws):
    bound = -math.log2(float(ws[ti]))
    # deterministic adaptive rules: x_t chosen as function of history; enumerate all rules for horizon 3
    # (a rule is a map from histories to inputs); sample random rules
    for r in range(200):
        rule = {}
        def choose(h):
            key = tuple(h)
            if key not in rule:
                rule[key] = random.choice(X)
            return rule[key]
        # exact expectation over F ~ L
        tot = 0.0
        for f, pf in L.items():
            h = []; D = []
            for t in range(4):
                x = choose(h)
                dom = dict(D)
                if x in dom:
                    h += [x, f[x]]
                    continue
                p = lawP(L, D + [(x, f[x])]) / lawP(L, D)
                q = mixP(D + [(x, f[x])]) / mixP(D)
                # d_t contribution: KL is E over y of log p/q; accumulate log ratio at realised y
                tot += float(pf) * math.log2(float(p / q))
                D.append((x, f[x])); h += [x, f[x]]
        maxsum = max(maxsum, tot)
        worst_ratio = max(worst_ratio, tot / bound)
print(f"   largest sum_t E d_t / (-log2 w) over 7 laws x 200 past-only rules: {worst_ratio:.4f} (must be <= 1)")
# rule that sees F: query the first input whose label is 1
L = laws[0]; ti = 0
tot = 0.0
for f, pf in L.items():
    D = []
    order = sorted(X, key=lambda i: -f[i])  # inputs labelled 1 first
    for x in order:
        p_cond = {y: lawP(L, D + [(x, y)]) / lawP(L, D) for y in (0, 1)}
        q_cond = {y: mixP(D + [(x, y)]) / mixP(D) for y in (0, 1)}
        kl = sum(float(p_cond[y]) * math.log2(float(p_cond[y] / q_cond[y])) for y in (0, 1) if p_cond[y] > 0)
        tot += float(pf) * kl
        D.append((x, f[x]))
print(f"   rule that sees F: sum_t E d_t = {tot:.4f} vs -log2 w = {-math.log2(float(ws[ti])):.4f}")

print("(7) online-to-batch, finite analogue (deterministic target in a finite mixture)")
viol = 0
for trial in range(30):
    X = list(range(4)); mu = [Fr(random.randint(1, 5)) for _ in X]; sm = sum(mu); mu = [m / sm for m in mu]
    mix = rand_mixture(X, nh=6, tapes=True)
    target = tuple(random.choice([0, 1]) for _ in X)
    wt = Fr(1, 30); mix.append((wt, [(Fr(1), target)]))
    nu0 = nu_of(mix, [])
    K = -math.log2(float(wt / nu0))  # posterior normalised by nu(empty)
    for n in (1, 2, 3, 4):
        cum = 0.0; Rbar = 0.0
        # E R(Q_t) for t = 0..n-1 and E R(Qbar_n)
        # enumerate sample sequences of length n-1 for Qbar (needs D_t for t<n along one sequence)
        for seq in product(X, repeat=n - 1):
            pseq = math.prod(float(mu[x]) for x in seq)
            Ds = [sorted({(x, target[x]) for x in seq[:t]}) for t in range(n)]
            for t in range(n):
                # R(Q_t)
                pass
            Rq = 0.0
            for x in X:
                qs = []
                for D in Ds:
                    if any(z == x for z, _ in D):
                        qs.append(1.0)
                    else:
                        qs.append(float(nu_of(mix, D + [(x, target[x])]) / nu_of(mix, D)))
                Rq += float(mu[x]) * -math.log2(sum(qs) / n)
                cum += pseq * float(mu[x]) * sum(-math.log2(q) for q in qs)
            Rbar += pseq * Rq
        if cum > K + 1e-9 or Rbar > K / n + 1e-9:
            viol += 1
print("   violations of sum E R(Q_t) <= K and E R(Qbar_n) <= K/n:", viol)

print("(8) per-query mixture")
X = [0, 1]; Y = [0, 1]
cls = []
for _ in range(6):
    cls.append({x: {1: Fr(random.randint(0, 10), 10)} for x in X})
for P in cls:
    for x in X:
        p1 = P[x][1]; P[x][0] = (1 - p1) * Fr(random.randint(5, 10), 10)  # sub-probability allowed
ws = [Fr(random.randint(1, 5)) for _ in cls]; s = sum(ws) * Fr(11, 10); ws = [w / s for w in ws]
def Mpq(xs, ys):
    return sum(w * math.prod(P[x][y] for x, y in zip(xs, ys)) for w, P in zip(ws, cls))
def Mprod(D):
    return sum(w * math.prod(P[x][y] for x, y in D) for w, P in zip(ws, cls))
chron_bad = 0; mult_bad = 0; le_bad = 0; strict = 0; pos_incons = 0; incons = 0
for n in range(0, 4):
    for xs in product(X, repeat=n):
        for ys in product(Y, repeat=n):
            m = Mpq(xs, ys)
            for x in X:
                if sum(Mpq(xs + (x,), ys + (y,)) for y in Y) > m:
                    chron_bad += 1
            for perm in permutations(range(n)):
                if Mpq(tuple(xs[i] for i in perm), tuple(ys[i] for i in perm)) != m:
                    mult_bad += 1
            D = {}
            consistent = True
            for x, y in zip(xs, ys):
                if x in D and D[x] != y:
                    consistent = False
                D[x] = y
            if consistent:
                mp = Mprod(list(D.items()))
                if m > mp:
                    le_bad += 1
                if m < mp:
                    strict += 1
            else:
                incons += 1
                pos_incons += (m > 0)
print(f"   chronological violations {chron_bad}; multiset violations {mult_bad}; M_pq > M_prod on consistent {le_bad};"
      f" strict at repeats {strict}; inconsistent sequences with M_pq>0: {pos_incons}/{incons}")

print("(9) typical-separation arithmetic and active-learning mean")
ok = True
for n in range(1, 200001):
    ell = math.ceil(math.log2(n)) + 1
    ok &= (1 - 2.0 ** -ell) ** n >= 0.5 - 1e-12
    ok &= 0.5 * 2.0 ** -ell / (ell + 1) ** 2 >= 1 / (8 * n * (math.log2(n) + 3) ** 2) - 1e-18
print("   (1-2^-l)^n >= 1/2 and 1/2 2^-l (l+1)^-2 >= 1/(8n(log n+3)^2) for n <= 2e5:", ok)
for d in range(1, 12):
    N = 2 ** d
    mean = (sum(range(1, N)) + (N - 1)) / N
    assert mean >= (N - 1) / 2
print("   active-learning mean bound holds for d<=11: True")

print("(10) Pinsker for sub-probabilities")
ok = True
for _ in range(20000):
    k = random.randint(2, 5)
    p = [random.random() for _ in range(k)]; s = sum(p); p = [v / s for v in p]
    q = [random.random() for _ in range(k)]; s = sum(q) * random.uniform(1, 3); q = [v / s for v in q]
    kl = sum(a * math.log2(a / b) for a, b in zip(p, q))
    l1 = sum(abs(a - b) for a, b in zip(p, q))
    ok &= l1 ** 2 <= 2 * math.log(2) * kl + 1e-12
print("   ||p-q||_1^2 <= 2 ln2 KL_bits for sub-probability q:", ok)

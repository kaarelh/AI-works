"""r1 (referee, independent of checks/c2): exact-arithmetic tests of Thm 3.5, Thm 3.6 and the
directed-information values claimed for Thm 3.7 and Sec. 5.3 of the history notes.

Differences from c2: label alphabet of size 3; exact rational probabilities (fractions.Fraction);
the non-peeking selector has PRIVATE MEMORY (a hidden state drawn once at the start), which
Thm 3.5 allows but c2 did not test; logs are evaluated with mpmath at 60 digits so identities are
checked to ~1e-50 rather than 1e-15.

Tests
 (A) Thm 3.5(a): for a non-peeking selector with private memory, for every reachable (h_{i-1}, x_i),
     the true conditional law of y_i equals pi(D u {(x,y)}) / pi(D) EXACTLY (rational equality).
 (B) Thm 3.5(b) / Gibbs: E[L_P] >= E[-log pi(D_n)] for random and for sharp predictors.
 (C) Thm 3.6(a) identity  E[-log pi(D_n)] - E[L_B] = I(f->x) - E[KL]  for peeking kernels with
     private memory (exact rationals, logs at 60 digits), and the inequality <= I(f->x).
 (D) Randomized chain (Thm 3.7) with block lengths 1..n, n = 2, 3, 4: exact I(f->x), E[-log pi(D_n)],
     E[L_B] (claimed: n(n+1)/2, n(n+1)/2, 0).
 (E) GF(2^m) reading-B process of Sec. 5.3, m = 2, 3: exact I(f->x) against the claimed
     m - 1 + log2(2^m - 1).
Seed 101.  Output saved to r1_exact_bayes_directed.out.
"""
import itertools, random
from fractions import Fraction as Fr
import mpmath as mp

mp.mp.dps = 60
SEED = 101
rng = random.Random(SEED)


def lg(q):
    """-log2 of a positive Fraction, as an mpmath number"""
    return -mp.log(mp.mpf(q.numerator) / q.denominator, 2)


def rand_dist(k, zero_prob=0.0):
    w = [0 if rng.random() < zero_prob else rng.randint(1, 9) for _ in range(k)]
    if sum(w) == 0:
        w[rng.randrange(k)] = 1
    s = sum(w)
    return [Fr(v, s) for v in w]


# ------------------------------------------------------------------ finite world
X = (0, 1, 2)
Y = (0, 1, 2)
n = 3
FUNCS = list(itertools.product(Y, repeat=len(X)))
S_STATES = (0, 1)  # private memory of the selector


def pi_of(pi, D):
    return sum(pi[j] for j, g in enumerate(FUNCS) if all(g[x] == y for x, y in D))


def all_hist(k):
    return list(itertools.product(itertools.product(X, Y), repeat=k))


HISTS = {k: all_hist(k) for k in range(n)}


def run_process(pi, sel, peek):
    """exact joint law over (f index, history of length n).
    sel[(s, h)] or sel[(s, f, h)] is a distribution over X; the private state s ~ uniform."""
    joint = {}
    for fi, f in enumerate(FUNCS):
        if pi[fi] == 0:
            continue
        for s in S_STATES:
            stack = [((), pi[fi] * Fr(1, len(S_STATES)))]
            while stack:
                h, p = stack.pop()
                if len(h) == n:
                    joint[(fi, h)] = joint.get((fi, h), 0) + p
                    continue
                dist = sel[(s, f, h)] if peek else sel[(s, h)]
                for x, q in zip(X, dist):
                    if q:
                        stack.append((h + ((x, f[x]),), p * q))
    return joint


def prefix_tables(joint):
    ph, phx = {}, {}
    for (fi, h), p in joint.items():
        for k in range(n + 1):
            ph[h[:k]] = ph.get(h[:k], 0) + p
            if k < n:
                key = (h[:k], h[k][0])
                phx[key] = phx.get(key, 0) + p
    return ph, phx


def rand_selector(peek, zero_prob):
    if peek:
        return {(s, f, h): rand_dist(len(X), zero_prob) for s in S_STATES for f in FUNCS
                for k in range(n) for h in HISTS[k]}
    return {(s, h): rand_dist(len(X), zero_prob) for s in S_STATES for k in range(n) for h in HISTS[k]}


def rand_predictor(sharp):
    P = {}
    for k in range(n):
        for h in HISTS[k]:
            for x in X:
                P[(h, x)] = rand_dist(len(Y), 0.6 if sharp else 0.0)
    return P


out = []
# ---------------- (A), (B)
worstA = 0
minB = None
for inst in range(25):
    pi = rand_dist(len(FUNCS), 0.3)
    sel = rand_selector(False, 0.2)
    joint = run_process(pi, sel, peek=False)
    ph, phx = prefix_tables(joint)
    # (A) exact conditional law
    for (h, x), pxx in phx.items():
        D = set(h)
        base = pi_of(pi, D)
        for y in Y:
            true_cond = ph.get(h + ((x, y),), 0) / pxx
            bayes = pi_of(pi, D | {(x, y)}) / base
            if true_cond != bayes:
                worstA += 1
    # (B) Gibbs against random and sharp predictors (infinite losses allowed)
    for sharp in (False, True):
        P = rand_predictor(sharp)
        EP = mp.mpf(0); Epi = mp.mpf(0); inf = False
        for (fi, h), p in joint.items():
            lp = mp.mpf(0)
            for i, (x, y) in enumerate(h):
                q = P[(h[:i], x)][y]
                if q == 0:
                    inf = True
                    break
                lp += lg(q)
            if not inf:
                EP += p * lp
            Epi += p * lg(pi_of(pi, set(h)))
        gap = mp.inf if inf else EP - Epi
        minB = gap if minB is None else min(minB, gap)
out.append(f"(A) non-peeking selector with private memory, 25 instances: exact mismatches between the true "
           f"conditional law of y_i and pi(D+(x,y))/pi(D): {worstA} (claim: 0)")
out.append(f"(B) min over 50 (instance, predictor) pairs of E[L_P] - E[-log pi(D_n)] = {mp.nstr(minB, 8)} (claim: >= 0)")
assert worstA == 0 and minB >= 0

# ---------------- (C) peeking identity with private memory
max_id_err = mp.mpf(0); max_ineq = -mp.inf
for inst in range(25):
    pi = rand_dist(len(FUNCS), 0.3)
    sel = rand_selector(True, 0.2)
    joint = run_process(pi, sel, peek=True)
    ph, phx = prefix_tables(joint)
    # marginal kernel of x given (f, h): average over the private state given (f, h)
    # mu(x_i | f, h_{i-1}) = P(f, h_{i-1}, x_i) / P(f, h_{i-1})
    pfh = {}
    pfhx = {}
    for (fi, h), p in joint.items():
        for k in range(n + 1):
            pfh[(fi, h[:k])] = pfh.get((fi, h[:k]), 0) + p
            if k < n:
                pfhx[(fi, h[:k], h[k][0])] = pfhx.get((fi, h[:k], h[k][0]), 0) + p
    E_logpi = E_LB = I_dir = E_KL = mp.mpf(0)
    hs = {}
    for (fi, h), p in joint.items():
        hs.setdefault(h, []).append((fi, p))
    for h, lst in hs.items():
        p_h = ph[h]
        D = set(h)
        piD = pi_of(pi, D)
        LB = sum((lg(ph[h[:i + 1]] / phx[(h[:i], h[i][0])]) for i in range(n)), mp.mpf(0))
        E_logpi += p_h * lg(piD)
        E_LB += p_h * LB
        for fi, p in lst:
            post = p / p_h
            q = pi[fi] / piD
            E_KL += p * (lg(q) - lg(post))  # p * log(post/q)
            for i in range(n):
                x = h[i][0]
                mu_x_f = pfhx[(fi, h[:i], x)] / pfh[(fi, h[:i])]
                mu_x = phx[(h[:i], x)] / ph[h[:i]]
                I_dir += p * (lg(mu_x) - lg(mu_x_f))
    lhs = E_logpi - E_LB
    max_id_err = max(max_id_err, abs(lhs - (I_dir - E_KL)))
    max_ineq = max(max_ineq, lhs - I_dir)
out.append(f"(C) peeking kernels with private memory, 25 instances: max |identity error| = {mp.nstr(max_id_err, 5)}; "
           f"max (E[-log pi(D)] - E[L_B]) - I(f->x) = {mp.nstr(max_ineq, 8)} (claim: <= 0)")
assert max_id_err < mp.mpf(10) ** -40 and max_ineq <= 0


# ---------------- (D) randomized chain
def chain_values(n_):
    lens = list(range(1, n_ + 1))
    blocks = [list(itertools.product((0, 1), repeat=l)) for l in lens]
    total = 1
    for b in blocks:
        total *= len(b)
    p0 = Fr(1, total)
    # f determined by the tuple; history = ((x1, eps), (x2, x1), ...)
    # pi(D_n) = P(f contains D_n): f(x_{i+1}) = x_i requires X_{i+1} = x_{i+1}, X_i = x_i; f(x_1)=eps requires
    # x_1 not equal to X_2's predecessor... compute by brute force over all tuples.
    tuples = list(itertools.product(*blocks))
    def f_of(t):
        d = {}
        for i in range(1, len(t)):
            d[t[i]] = t[i - 1]
        return d  # default eps
    E_logpi = mp.mpf(0)
    for t in tuples:
        D = [(t[0], ())] + [(t[i], t[i - 1]) for i in range(1, n_)]
        cnt = 0
        for t2 in tuples:
            f2 = f_of(t2)
            if all(f2.get(x, ()) == y for x, y in D):
                cnt += 1
        E_logpi += p0 * lg(Fr(cnt, total))
    # L_B: given h_{i-1} and x_i (the true one), y_i = x_{i-1} is determined, so L_B = 0; check by brute force
    # I(f -> x) = sum_i H(x_i | h_{i-1}) - H(x_i | f, h_{i-1}); x_i determined by f, uniform given h_{i-1}
    # brute force: I = sum_i E[log mu(x_i | f, h_{i-1}) / mu(x_i | h_{i-1})]; given f (= the tuple) x_i is
    # determined, so mu(x_i | f, h_{i-1}) = 1; mu(x_i | h_{i-1}) is computed by counting tuples
    I_dir = mp.mpf(0)
    hist = {t: [(t[0], ())] + [(t[i], t[i - 1]) for i in range(1, n_)] for t in tuples}
    for t in tuples:
        for i in range(n_):
            den = sum(1 for t2 in tuples if hist[t2][:i] == hist[t][:i])
            num = sum(1 for t2 in tuples if hist[t2][:i] == hist[t][:i] and t2[i] == t[i])
            I_dir += p0 * (lg(Fr(num, den)) - 0)
    # brute-force L_B and H(x_i | f, h_{i-1}) = 0 checks
    LB_max = mp.mpf(0)
    for t in tuples:
        h = [(t[0], ())] + [(t[i], t[i - 1]) for i in range(1, n_)]
        for i in range(n_):
            # P(y_i | h_{i-1}, x_i) under the process
            num = den = 0
            for t2 in tuples:
                h2 = [(t2[0], ())] + [(t2[j], t2[j - 1]) for j in range(1, n_)]
                if h2[:i] == h[:i] and h2[i][0] == h[i][0]:
                    den += 1
                    if h2[i][1] == h[i][1]:
                        num += 1
            LB_max = max(LB_max, lg(Fr(num, den)))
    return E_logpi, I_dir, LB_max


for n_ in (2, 3, 4):
    E_logpi, I_dir, LB = chain_values(n_)
    out.append(f"(D) randomized chain n={n_}: E[-log pi(D_n)] = {mp.nstr(E_logpi, 10)}, I(f->x) = {mp.nstr(I_dir, 10)}, "
               f"max per-step Bayes loss = {mp.nstr(LB, 5)}; claimed n(n+1)/2 = {n_ * (n_ + 1) // 2}; "
               f"lower bound n(n-1)/2 = {n_ * (n_ - 1) // 2}")
    assert abs(E_logpi - n_ * (n_ + 1) / 2) < 1e-30 and abs(I_dir - n_ * (n_ + 1) / 2) < 1e-30 and LB == 0

# ---------------- (E) GF(2^m) reading-B process
IRRED = {2: 0b111, 3: 0b1011}


def gmul(a, b, m):
    r = 0
    while b:
        if b & 1:
            r ^= a
        b >>= 1
        a <<= 1
        if a >> m:
            a ^= IRRED[m]
    return r


for m in (2, 3):
    q = 1 << m
    triples = [(a, b, r) for a in range(q) for b in range(q) if a != b for r in range(q)]
    pt = Fr(1, len(triples))
    EPS = -1  # label of all other inputs
    def f_of(a, b, r):
        return {a: r, b: r ^ gmul(a, b, m)}
    # joint over (f-key, history); f-key = frozenset of the two (input,label) pairs
    joint = {}
    for a, b, r in triples:
        f = f_of(a, b, r)
        fk = frozenset(f.items())
        for first, second in ((a, b), (b, a)):
            h = ((first, f[first]), (second, f[second]))
            joint[(fk, h)] = joint.get((fk, h), 0) + pt * Fr(1, 2)
    ph, phx = {}, {}
    pfh, pfhx = {}, {}
    for (fk, h), p in joint.items():
        for k in range(3):
            ph[h[:k]] = ph.get(h[:k], 0) + p
            pfh[(fk, h[:k])] = pfh.get((fk, h[:k]), 0) + p
            if k < 2:
                phx[(h[:k], h[k][0])] = phx.get((h[:k], h[k][0]), 0) + p
                pfhx[(fk, h[:k], h[k][0])] = pfhx.get((fk, h[:k], h[k][0]), 0) + p
    I_dir = mp.mpf(0); E_logpi = mp.mpf(0); E_LB = mp.mpf(0)
    pf = {}
    for (fk, h), p in joint.items():
        pf[fk] = pf.get(fk, 0) + p
    for (fk, h), p in joint.items():
        for i in range(2):
            x = h[i][0]
            I_dir += p * (lg(phx[(h[:i], x)] / ph[h[:i]]) - lg(pfhx[(fk, h[:i], x)] / pfh[(fk, h[:i])]))
            E_LB += p * lg(ph[h[:i + 1]] / phx[(h[:i], x)])
        D = set(h)
        piD = sum(pv for fk2, pv in pf.items() if D <= set(fk2))
        E_logpi += p * lg(piD)
    claimed = (m - 1) + mp.log(q - 1, 2)
    out.append(f"(E) GF(2^{m}) process: I(f->x) = {mp.nstr(I_dir, 12)} (claimed m-1+log2(2^m-1) = {mp.nstr(claimed, 12)}); "
               f"E[L_B] = {mp.nstr(E_LB, 8)} (P's loss m = {m}); E[-log pi(D)] = {mp.nstr(E_logpi, 10)}")
    assert abs(I_dir - claimed) < 1e-30

for line in out:
    print(line)
print("ALL CHECKS PASSED")

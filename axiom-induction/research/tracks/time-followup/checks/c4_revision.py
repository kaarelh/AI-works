"""c4: checks added in the revision (notes-final.md of the time-followup track).

Part A  Theorem 3.2(c), sharpened bound.  The diagonal labeller sees approximations a_b with |a_b - q_b| <= 2^-(j+3)
        and picks the label with the smaller a_b (ties: 0).  Then q_beta <= 1/2 + 2^-(j+3), so the predictor's loss
        on the first n diagonal labels is >= n - sum_{j<=n} log2(1 + 2^-(j+2)) >= n - 1/(4 ln 2).  Checked for
        every n <= N against eight predictors and three approximation modes.  A 'sharp' adversary (q1 = 1/2 +-
        (1 - 1e-9) * 2^-(j+3), approximations pushed the wrong way) shows the bound is attained up to 1e-9 per step.
Part B  Corollary 4.3(f) and Remark 4.6.  A history-free predictor (q0, q1 a function of the sentence alone,
        q0 + q1 <= 1) has loss(D^empty_n) + loss(D^all_n) >= 2n on the two constant-label sequences over the same
        sentences, because q0 * q1 <= 1/4; so on one of them it loses >= n.  Checked on seeded random
        history-free predictors (deficient ones, near-deterministic ones, and ones that are right on one sequence).
Part C  Corollary 4.3(e3).  T(K) := sum_{k >= K} 2^(-2 ceil(log2(k+1)) - 1), the FIcons_poly weight of all clock
        exponents >= K (with sum_f w(f) <= 1), satisfies 1/(8(K+1)) <= T(K) <= 1/(2K), so -log2 T(K) = log2 K + O(1).
Deterministic except Part B (seed 2026).  Writes c4_revision.out next to itself.
"""
import math
import os
import random

out = []
N = 2000


# ------------------------------------------------------------------------------------------------- Part A
def l2(x):
    return math.log2(x)


class KT:
    def __init__(self, a=0.5):
        self.n = [0, 0]
        self.a = a

    def predict(self, j):
        t = self.n[0] + self.n[1]
        q1 = (self.n[1] + self.a) / (t + 2 * self.a)
        return (1.0 - q1, q1)

    def update(self, b):
        self.n[b] += 1


class LateStart:
    """Mixture in the style of Haenni's S: component k is tracked from step 4^k on, entering with weight
    2^-(k+1) * 2^-(4^k - 1) (as if it had predicted 1/2 before); untracked components count as 1/2-predictors."""

    def __init__(self):
        self.comps = []
        for k in range(6):
            if k % 2 == 0:
                self.comps.append(('kt', KT(0.5)))
            else:
                self.comps.append(('const', k % 4 == 1))
        self.lw = [-(k + 1) for k in range(6)]  # log2 weights, accumulate 1/2 factors until tracked
        self.start = [4 ** k for k in range(6)]

    def comp_pred(self, k, j):
        if j < self.start[k]:
            return (0.5, 0.5)
        kind, c = self.comps[k]
        if kind == 'kt':
            return c.predict(j)
        return (0.0, 1.0) if c else (1.0, 0.0)

    def predict(self, j):
        tot = max(self.lw)
        ws = [2.0 ** (w - tot) for w in self.lw]
        s = sum(ws)
        q1 = sum(w * self.comp_pred(k, j)[1] for k, w in enumerate(ws)) / s
        return (1.0 - q1, q1)

    def update(self, b, j):
        for k in range(6):
            p = self.comp_pred(k, j)[b]
            self.lw[k] += l2(p) if p > 0 else -1e9
            kind, c = self.comps[k]
            if kind == 'kt':
                c.update(b)


class PeriodicFI:
    """Semimeasure mixture over periodic deterministic assigners (period <= 5), some partial (abstain when
    j % 5 == 0), plus a uniform component; incompatible hypotheses drop out (q0 + q1 < 1 is possible)."""

    def __init__(self):
        self.h = []
        for p in range(1, 6):
            for pat in range(2 ** p):
                bits = [(pat >> i) & 1 for i in range(p)]
                for partial in (False, True):
                    self.h.append([bits, partial, -(3 * p + 2.0)])
        self.lu = -1.0

    def lab(self, h, j):
        bits, partial, _ = h
        if partial and j % 5 == 0:
            return None
        return bits[(j - 1) % len(bits)]

    def predict(self, j):
        allw = [x[2] for x in self.h] + [self.lu]
        m = max(allw)
        tot = sum(2.0 ** (w - m) for w in allw)
        num = [0.5 * 2.0 ** (self.lu - m), 0.5 * 2.0 ** (self.lu - m)]
        for x in self.h:
            b = self.lab(x, j)
            if b is not None:
                num[b] += 2.0 ** (x[2] - m)
        return (num[0] / tot, num[1] / tot)

    def update(self, b, j):
        for x in self.h:
            if self.lab(x, j) != b:
                x[2] = -1e18
        self.lu += -1.0


class Wrap:
    """Adapter: predictors with update(b) only."""

    def __init__(self, p):
        self.p = p

    def predict(self, j):
        return self.p.predict(j)

    def update(self, b, j):
        self.p.update(b)


class Deficient:
    def __init__(self):
        self.k = KT()

    def predict(self, j):
        q0, q1 = self.k.predict(j)
        return (0.9 * q0, 0.9 * q1)

    def update(self, b, j):
        self.k.update(b)


class NearHalf:
    """q1 = 1/2 + s * f * 2^-(j+3), s = +-1 by the parity of the ones so far: inside the approximation error."""

    def __init__(self, f):
        self.f = f
        self.ones = 0

    def predict(self, j):
        e = self.f * 2.0 ** -(j + 3) * (1 if self.ones % 2 == 0 else -1)
        return (0.5 - e, 0.5 + e)

    def update(self, b, j):
        self.ones += b


class IndexReader:
    def predict(self, j):
        return (0.1, 0.9) if j % 2 == 0 else (0.9, 0.1)

    def update(self, b, j):
        pass


PRED = {
    'KT': lambda: Wrap(KT(0.5)),
    'Laplace': lambda: Wrap(KT(1.0)),
    'late-start-S': LateStart,
    'periodic-FI': PeriodicFI,
    'deficient': Deficient,
    'near-half .99': lambda: NearHalf(0.99),
    'sharp': lambda: NearHalf(1 - 1e-9),
    'index-reader': IndexReader,
}


def approx(q, j, mode, rng):
    d = 2.0 ** -(j + 3)
    q0, q1 = q
    if mode == 'exact':
        return q0, q1
    if mode == 'random':
        return q0 + rng.uniform(-d, d), q1 + rng.uniform(-d, d)
    # adversarial: push towards picking the larger q_b
    return (q0 - d, q1 + d) if q0 >= q1 else (q0 + d, q1 - d)


B_SHARP = 1.0 / (4.0 * math.log(2.0))
tail = [0.0]
for j in range(1, N + 1):
    tail.append(tail[-1] + math.log2(1.0 + 2.0 ** -(j + 2)))
TAIL_INF = tail[N] + sum(math.log2(1.0 + 2.0 ** -(j + 2)) for j in range(N + 1, N + 60))

out.append(f"c4_revision  (N = {N}; Part B seed 2026)")
out.append("Part A: diagonal loss against the sharpened bound of Theorem 3.2(c)")
out.append(f"  bound: loss_n >= n - sum_(j<=n) log2(1 + 2^-(j+2)) >= n - {TAIL_INF:.6f} >= n - 1/(4 ln 2) = n - {B_SHARP:.6f}")
out.append(f"  {'predictor':<15} {'mode':<12} {'min(l_n - n)':>13} {'min slack to bound':>19} {'l_N - N':>11}  ok")
okA = True
sharp_gap = None
for name, mk in PRED.items():
    for mode in ('exact', 'random', 'adversarial'):
        rng = random.Random(4242)
        p = mk()
        loss, worst, slack = 0.0, math.inf, math.inf
        for j in range(1, N + 1):
            q = p.predict(j)
            a0, a1 = approx(q, j, mode, rng)
            b = 0 if a0 <= a1 else 1
            loss += -math.log2(q[b]) if q[b] > 0 else math.inf
            worst = min(worst, loss - j)
            slack = min(slack, loss - (j - tail[j]))
            p.update(b, j)
        ok = slack >= -1e-12 and worst >= -B_SHARP
        if mode == 'exact':
            ok = ok and worst >= -1e-12
        okA = okA and ok
        if name == 'sharp' and mode == 'adversarial':
            sharp_gap = slack
        out.append(f"  {name:<15} {mode:<12} {worst:>13.6f} {slack:>19.3e} {loss - N:>11.4f}  {ok}")
out.append(f"  sharp adversary, adversarial mode: min slack to the bound = {sharp_gap:.3e} (bound attained up to rounding)")
out.append(f"Part A verdict: {'all bounds hold' if okA else 'VIOLATION'}")

# ------------------------------------------------------------------------------------------------- Part B
rng = random.Random(2026)
okB = True
out.append("")
out.append("Part B: history-free predictors on the two constant-label sequences D^empty (all 0) and D^all (all 1)")
out.append(f"  {'kind':<16} {'#pred':>6} {'n':>6} {'min (l_0 + l_1)/n':>18} {'min max(l_0, l_1)/n':>20}  ok")
kinds = {
    'uniform': lambda: (lambda u: (u, 1 - u))(rng.random()),
    'deficient': lambda: (lambda u, s: (s * u, s * (1 - u)))(rng.random(), rng.uniform(0.5, 1.0)),
    'near-determ.': lambda: (lambda b: (1 - 1e-6, 1e-6) if b else (1e-6, 1 - 1e-6))(rng.random() < 0.5),
    'right-on-all': lambda: (1e-9, 1 - 1e-9),
    'right-on-empty': lambda: (1 - 1e-9, 1e-9),
}
n = 500
for kind, gen in kinds.items():
    mins, minm = math.inf, math.inf
    for _ in range(200):
        qs = [gen() for _ in range(n)]
        l0 = sum(-math.log2(q[0]) for q in qs)  # D^empty: every label 0
        l1 = sum(-math.log2(q[1]) for q in qs)  # D^all: every label 1
        mins = min(mins, (l0 + l1) / n)
        minm = min(minm, max(l0, l1) / n)
    ok = mins >= 2 - 1e-12 and minm >= 1 - 1e-12
    okB = okB and ok
    out.append(f"  {kind:<16} {200:>6} {n:>6} {mins:>18.4f} {minm:>20.4f}  {ok}")
out.append(f"Part B verdict: {'l_0 + l_1 >= 2n and max >= n in every case' if okB else 'VIOLATION'}")

# ------------------------------------------------------------------------------------------------- Part C
out.append("")
out.append("Part C: T(K) = sum_(k>=K) 2^(-2 ceil(log2(k+1)) - 1) against 1/(8(K+1)) and 1/(2K)")
out.append(f"  {'K':>12} {'-log2 T(K)':>11} {'log2 K':>8} {'T(K)*2K':>9} {'T(K)*8(K+1)':>12}  ok")
okC = True


def T(K):
    # ceil(log2(k+1)) = k.bit_length() for k >= 0.  The k >= 1 with bit_length c are 2^(c-1) .. 2^c - 1.
    # Sum the partial block of K exactly, the full blocks up to c = 400 exactly, and the rest in closed form:
    # sum_{c > C} 2^(c-1) * 2^(-2c-1) = 2^(-C-2).
    c0 = K.bit_length()
    s = ((1 << c0) - K) * 2.0 ** (-2 * c0 - 1)
    C = 400
    for c in range(c0 + 1, C + 1):
        s += (1 << (c - 1)) * 2.0 ** (-2 * c - 1)
    return s + 2.0 ** (-C - 2)


for K in (1, 2, 3, 15, 16, 255, 1000, 65535, 10 ** 6, 2 ** 32 - 1, 10 ** 12):
    t = T(K)
    ok = 1.0 / (8 * (K + 1)) <= t <= 1.0 / (2 * K)
    okC = okC and ok
    out.append(f"  {K:>12} {-math.log2(t):>11.4f} {math.log2(K):>8.4f} {t * 2 * K:>9.4f} {t * 8 * (K + 1):>12.4f}  {ok}")
out.append(f"Part C verdict: {'bounds hold' if okC else 'VIOLATION'}")

out.append("")
out.append(f"verdict: {'all checks pass' if (okA and okB and okC) else 'FAILURE'}")
here = os.path.dirname(os.path.abspath(__file__))
with open(os.path.join(here, 'c4_revision.out'), 'w') as fh:
    fh.write('\n'.join(out) + '\n')
print('\n'.join(out))

"""c1: the diagonal construction of Theorem 4.2 (time-followup notes.md), run against concrete computable predictors.

A predictor maps (label history, step index j) to a pair (q0, q1) with q0, q1 >= 0 and q0 + q1 <= 1 (a semimeasure step).
The diagonal labeller of Theorem 4.2 does not see (q0, q1) exactly: it sees approximations a_b with |a_b - q_b| <= 2^-(j+3)
and picks the label b_j with the smaller a_b (ties: 0).  Claim checked (Theorem 4.2(c)):
    the predictor's cumulative log loss on the first n diagonal labels is >= n - 1/(2 ln 2) for every n,
and >= n when the approximations are exact.  Approximation modes: exact; seeded random errors of size <= 2^-(j+3);
adversarial errors of that size (they push the choice towards the *larger* q_b whenever |q0 - q1| < 2^-(j+2)).

Predictors:
  KT, Laplace                          estimators on the label bits
  markov-mix                           Bayes mixture of order-0..3 Markov KT models (equal prior weights)
  periodic-FI                          toy FI_all,tau: semimeasure mixture over deterministic assigners (every label
                                       pattern of period <= 6), some of them partial (abstain when j % 7 == 0, so
                                       q0 + q1 < 1 there), plus a uniform component; deterministic hypotheses drop out
  late-start-S                         a mixture in the style of Hanni's polytime S: component k (KT of order k % 4, or a
                                       periodic pattern) is tracked only from step 4^k on, entering with weight
                                       2^-(k+1) * 2^-(4^k - 1), as if it had predicted 1/2 before
  deficient                            0.9 * KT (q0 + q1 = 0.9)
  near-half                            q1 = 1/2 +- 0.9 * 2^-(j+3): within the approximation error of 1/2, so the
                                       adversarial mode makes the diagonal pick the larger probability (loss < 1 bit)
  index-reader                         q1 = 0.9 if j is even, else 0.1 (reads the sentence s_j, i.e. its index)
Part B re-runs the self-referential program D(n) = G(e, n) of the proof from scratch for every n <= 150 (KT, exact and
random modes) and checks that the label of s_j computed inside D(n) equals D(j) (the history-consistency step).
Part C checks the analytic tail bound sum_j log2(1 + 2^-(j+1)) <= 1/(2 ln 2).
"""
import math
import random

SEED = 4242
N = 2000
out = []


def log2sumexp2(xs):
    """log2(sum 2^x) for a list of log2-values (may contain -inf)."""
    xs = [x for x in xs if x != -math.inf]
    if not xs:
        return -math.inf
    m = max(xs)
    return m + math.log2(sum(2.0 ** (x - m) for x in xs))


# ---------------------------------------------------------------------------------------------------------------
# Predictors: objects with predict(j) -> (q0, q1) and update(bit).  They see only the label history (and j).
class KT:
    name = 'KT'

    def __init__(self):
        self.n = [0, 0]

    def predict(self, j):
        t = self.n[0] + self.n[1]
        q1 = (self.n[1] + 0.5) / (t + 1.0)
        return (1.0 - q1, q1)

    def update(self, b):
        self.n[b] += 1


class Laplace(KT):
    name = 'Laplace'

    def predict(self, j):
        t = self.n[0] + self.n[1]
        q1 = (self.n[1] + 1.0) / (t + 2.0)
        return (1.0 - q1, q1)


class MarkovKT:
    """KT estimator conditioned on the last k labels (contexts shorter than k at the start use the short context)."""

    def __init__(self, k):
        self.k = k
        self.hist = []
        self.cnt = {}

    def ctx(self):
        return tuple(self.hist[-self.k:]) if self.k > 0 else ()

    def predict(self, j):
        c = self.cnt.get(self.ctx(), [0, 0])
        q1 = (c[1] + 0.5) / (c[0] + c[1] + 1.0)
        return (1.0 - q1, q1)

    def update(self, b):
        c = self.cnt.setdefault(self.ctx(), [0, 0])
        c[b] += 1
        self.hist.append(b)


class MarkovMix:
    name = 'markov-mix'

    def __init__(self):
        self.comp = [MarkovKT(k) for k in range(4)]
        self.lw = [math.log2(0.25)] * 4  # log2 posterior weights (unnormalised)

    def predict(self, j):
        preds = [c.predict(j) for c in self.comp]
        tot = log2sumexp2(self.lw)
        q1 = sum(2.0 ** (lw - tot) * p[1] for lw, p in zip(self.lw, preds))
        return (1.0 - q1, q1)

    def update(self, b):
        for i, c in enumerate(self.comp):
            self.lw[i] += math.log2(c.predict(None)[b])
            c.update(b)


class PeriodicFI:
    """Semimeasure mixture over deterministic (partly partial) assigners plus a uniform component.
    Hypothesis (p, pattern, partial): label of s_j is pattern[(j-1) % p]; if partial, it abstains when j % 7 == 0
    (then it is compatible with neither label, which is what makes q0 + q1 < 1)."""
    name = 'periodic-FI'

    def __init__(self):
        self.hyp = []
        for p in range(1, 7):
            for pat in range(2 ** p):
                bits = [(pat >> i) & 1 for i in range(p)]
                for partial in (False, True):
                    # prior 2^-(2p + 1) / 2^p per pattern, halved for the partial flag; total weight < 1/2
                    self.hyp.append([p, bits, partial, -(2 * p + 1) - p - 1 - 1.0])
        self.lu = math.log2(0.5)  # uniform component, weight 1/2
        self.j = 0

    def lab(self, h, j):
        p, bits, partial, _ = h
        if partial and j % 7 == 0:
            return None
        return bits[(j - 1) % p]

    def predict(self, j):
        tot = log2sumexp2([h[3] for h in self.hyp] + [self.lu])
        num = [[], []]
        for h in self.hyp:
            b = self.lab(h, j)
            if b is not None:
                num[b].append(h[3])
        q = [2.0 ** (log2sumexp2(num[b] + [self.lu - 1.0]) - tot) for b in (0, 1)]
        return (q[0], q[1])

    def update(self, b):
        self.j += 1
        for h in self.hyp:
            if self.lab(h, self.j) != b:
                h[3] = -math.inf
        self.lu -= 1.0
        self.hyp = [h for h in self.hyp if h[3] != -math.inf]


class LateStartS:
    """Hanni-style late start: component k is tracked from step s_k = 4^k on; before that it counts as predicting 1/2.
    Components: k % 2 == 0 -> MarkovKT(order (k // 2) % 4); k % 2 == 1 -> deterministic period-((k // 2) % 5 + 1)
    pattern (k // 2) (abstaining is not used here)."""
    name = 'late-start-S'
    K = 6

    def __init__(self):
        self.comp = []
        for k in range(self.K):
            if k % 2 == 0:
                obj = MarkovKT((k // 2) % 4)
            else:
                p = (k // 2) % 5 + 1
                obj = ('pat', p, [((k // 2) >> i) & 1 for i in range(p)])
            self.comp.append({'k': k, 'start': 4 ** k, 'obj': obj, 'lw': None})
        self.j = 0
        self.hist = []

    def cpred(self, c, j):
        o = c['obj']
        if isinstance(o, tuple):
            b = o[2][(j - 1) % o[1]]
            return (1.0 - b, float(b))
        return o.predict(j)

    def predict(self, j):
        # untracked components predict 1/2 and carry weight 2^-(k+1) * 2^-(j-1) (as if tracked from the start)
        lws, q1s = [], []
        for c in self.comp:
            if c['lw'] is None:
                lws.append(-(c['k'] + 1) - (j - 1.0))
                q1s.append(0.5)
            else:
                lws.append(c['lw'])
                q1s.append(self.cpred(c, j)[1])
        tot = log2sumexp2(lws)
        q1 = sum(2.0 ** (lw - tot) * q for lw, q in zip(lws, q1s) if lw != -math.inf)
        return (1.0 - q1, q1)

    def update(self, b):
        self.j += 1
        for c in self.comp:
            if c['lw'] is not None:
                p = self.cpred(c, self.j)[b]
                c['lw'] = c['lw'] + math.log2(p) if p > 0 else -math.inf
                if not isinstance(c['obj'], tuple):
                    c['obj'].update(b)
            elif self.j + 1 >= c['start']:
                # start tracking at step j + 1: weight as if it had predicted 1/2 on the first j labels; for a Markov
                # component, warm it up on the history (its weight is NOT updated by that warm-up, as in Hanni's S)
                c['lw'] = -(c['k'] + 1) - float(self.j)
                if not isinstance(c['obj'], tuple):
                    for x in self.hist + [b]:
                        c['obj'].update(x)
        self.hist.append(b)


class Deficient(KT):
    name = 'deficient'

    def predict(self, j):
        q0, q1 = KT.predict(self, j)
        return (0.9 * q0, 0.9 * q1)


class NearHalf:
    """q1 = 1/2 + 0.9 * 2^-(j+3) * sign, sign = +1 if the number of ones so far is even, else -1: the two
    probabilities differ by less than the approximation error, so the adversarial mode picks the larger one."""
    name = 'near-half'

    def __init__(self):
        self.ones = 0

    def predict(self, j):
        e = 0.9 * 2.0 ** -(j + 3) * (1 if self.ones % 2 == 0 else -1)
        return (0.5 - e, 0.5 + e)

    def update(self, b):
        self.ones += b


class IndexReader:
    name = 'index-reader'

    def predict(self, j):
        return (0.1, 0.9) if j % 2 == 0 else (0.9, 0.1)

    def update(self, b):
        pass


PREDICTORS = [KT, Laplace, MarkovMix, PeriodicFI, LateStartS, Deficient, NearHalf, IndexReader]


# ---------------------------------------------------------------------------------------------------------------
def approx(q, j, hist_key, mode):
    """Approximations a_b with |a_b - q_b| <= 2^-(j+3), deterministic in (j, history) as the proof requires."""
    d = 2.0 ** -(j + 3)
    if mode == 'exact':
        return q
    if mode == 'random':
        r = random.Random(f"{SEED}-{j}-{hist_key}")
        return (q[0] + d * (2 * r.random() - 1), q[1] + d * (2 * r.random() - 1))
    # adversarial: lower the larger q_b, raise the smaller one
    if q[0] >= q[1]:
        return (q[0] - d, q[1] + d)
    return (q[0] + d, q[1] - d)


def run_diagonal(cls, mode, n):
    P = cls()
    labels, loss, worst = [], 0.0, math.inf
    for j in range(1, n + 1):
        q = P.predict(j)
        assert q[0] >= -1e-12 and q[1] >= -1e-12 and q[0] + q[1] <= 1 + 1e-9, (cls.name, j, q)
        a = approx(q, j, ''.join(map(str, labels[-64:])) + f"/{len(labels)}", mode)
        b = 0 if a[0] <= a[1] else 1
        loss += -math.log2(q[b]) if q[b] > 0 else math.inf
        labels.append(b)
        P.update(b)
        worst = min(worst, loss - j)
    return labels, loss, worst


BOUND = -1.0 / (2.0 * math.log(2.0))
out.append(f"c1_diagonal  (seed {SEED}, N = {N})")
out.append("Part A: cumulative log loss of each predictor on its own diagonal labels; claim loss_n >= n - 1/(2 ln 2) "
           f"= n - {-BOUND:.4f} for every n <= N (exact mode: >= n).")
out.append(f"{'predictor':<14} {'mode':<12} {'loss_N - N':>12} {'min_n (loss_n - n)':>20} {'#ones':>7}  verdict")
ok_all = True
for cls in PREDICTORS:
    for mode in ('exact', 'random', 'adversarial'):
        labels, loss, worst = run_diagonal(cls, mode, N)
        thr = -1e-9 if mode == 'exact' else BOUND
        ok = worst >= thr
        ok_all &= ok
        out.append(f"{cls.name:<14} {mode:<12} {loss - N:>12.4f} {worst:>20.6f} {sum(labels):>7}  {'ok' if ok else 'FAIL'}")
out.append(f"Part A verdict: {'all bounds hold' if ok_all else 'SOME BOUND FAILS'}")

# ---------------------------------------------------------------------------------------------------------------
# Part B: the self-referential program D(n) = G(e, n) recomputed from scratch for each n.
out.append("")
out.append("Part B: D(n) recomputed from scratch for n <= 150; the label of s_j inside D(n) must equal D(j).")
okB = True
for mode in ('exact', 'random'):
    full, _, _ = run_diagonal(KT, mode, 150)
    D = []
    for n in range(1, 151):
        labs, _, _ = run_diagonal(KT, mode, n)
        D.append(labs[-1])
        if labs != full[:n]:
            okB = False
    okB &= (D == full)
    out.append(f"  KT, {mode}: D(1..150) == single-pass labels: {D == full}")
out.append(f"Part B verdict: {'consistent' if okB else 'INCONSISTENT'}")

# ---------------------------------------------------------------------------------------------------------------
out.append("")
s = sum(math.log2(1 + 2.0 ** -(j + 1)) for j in range(1, 200))
out.append(f"Part C: sum_(j>=1) log2(1 + 2^-(j+1)) = {s:.6f} <= 1/(2 ln 2) = {-BOUND:.6f}: {s <= -BOUND}")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")

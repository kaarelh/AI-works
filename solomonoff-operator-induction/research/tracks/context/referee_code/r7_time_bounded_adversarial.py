"""r7 (referee): Thm 3.1(a) (time-bounded SFI, constant regret) under ADVERSARIAL labels and an adversarial
input stream, with the theorem's own construction (length-based activation, clock g(|x|) p(|x|)),
implemented independently of c5.

Class: p(n) = n.  Ten toy x-only probability predictors A_i with declared running times c_i*|x| or |x|^2,
some of which are over budget on short inputs (so "q_i = A_i" can hold on some short inputs and fail on
others -- the case where the notes' proof writes "-log2 q_i = log2|Y|", which is not literally true).
Weights w_i = 2^-(i+1); activation lengths n_i = i+1; clock factor g(n) = max(1, floor(log2 n)).
Labels: at every round the adversary picks the label MINIMISING the learner's predictive probability
(worst case for S), or (second stream) the label maximising a chosen comparator's probability.
Inputs: 4000 distinct strings, half of them short (length <= 9).
Check for every comparator A_i in the class: regret_i(k) <= log2(1/w_i) + #{j<=k : |x_j| < N_i} log2|Y|
for all k, with N_i = max(n_i, min{n : g(n) >= c_i}).  Also checks sum_y S(y|x,D) = 1.
Seeded (seed 7).
"""
import math
import zlib
import numpy as np

rng = np.random.default_rng(7)
Y = 3


def g(n):
    return max(1, int(math.floor(math.log2(n)))) if n >= 2 else 1


def p(n):
    return n


def mk(seed, c, quad=False):
    r = np.random.default_rng(seed)
    table = r.dirichlet(np.ones(Y), size=64)

    def prob(x):
        return table[(zlib.crc32((x + str(seed)).encode()) ^ len(x)) % 64]

    steps = (lambda x: len(x) ** 2) if quad else (lambda x: c * len(x))
    return prob, steps, c


machines = [mk(100 + i, c) for i, c in enumerate([1, 2, 3, 4, 6, 8, 12, 16])] + [mk(200, 1, quad=True), mk(201, 1, quad=True)]
M = len(machines)
w = np.array([2.0 ** -(i + 1) for i in range(M)])
n_act = [i + 1 for i in range(M)]


def q(i, x):
    prob, steps, _ = machines[i]
    if len(x) < n_act[i] or steps(x) > p(len(x)) * g(len(x)):
        return np.full(Y, 1.0 / Y)
    return prob(x)


xs, seen = [], set()
while len(xs) < 4000:
    L = int(rng.integers(1, 10)) if rng.random() < 0.5 else int(rng.integers(10, 60))
    x = "".join(rng.choice(list("01"), size=L))
    if x not in seen:
        seen.add(x)
        xs.append(x)
xs = list(rng.permutation(xs))


def _N_i(i):
    _, _, c = machines[i]
    if i >= 8:  # quadratic-time machines are not in C_p for p(n) = n: no finite N_i
        return None
    return max(n_act[i], min(n for n in range(1, 10 ** 6) if g(n) >= c))


_NI = [_N_i(i) for i in range(M)]


def N_i(i):
    return _NI[i]


out = []
for mode in ["adversarial-to-S", "favour-A3"]:
    logw = np.log2(w).copy()
    lossS = 0.0
    lossA = np.zeros(M)
    short = np.zeros(M)
    ok = True
    norm_err = 0.0
    worst_slack = np.full(M, np.inf)
    for t, x in enumerate(xs):
        Q = np.array([q(i, x) for i in range(M)])
        ww = 2.0 ** (logw - logw.max())
        pred = (ww[:, None] * Q).sum(0) / ww.sum()
        norm_err = max(norm_err, abs(pred.sum() - 1))
        if mode == "adversarial-to-S":
            y = int(np.argmin(pred))
        else:
            y = int(np.argmax(machines[3][0](x)))
        lossS += -math.log2(pred[y])
        for i in range(M):
            lossA[i] += -math.log2(machines[i][0](x)[y])
            Ni = N_i(i)
            if Ni is not None and len(x) < Ni:
                short[i] += 1
        logw += np.log2(Q[:, y])
        for i in range(M):
            Ni = N_i(i)
            if Ni is None:
                continue
            bound = -math.log2(w[i]) + short[i] * math.log2(Y)
            slack = bound - (lossS - lossA[i])
            worst_slack[i] = min(worst_slack[i], slack)
            ok &= slack >= -1e-9
    out.append(f"{mode}: final loss of S = {lossS:.1f} bits over {len(xs)} rounds; bound holds for all comparators "
               f"in C_p at every prefix: {ok}; min slack per comparator (bits): "
               + ", ".join(f"A{i}:{worst_slack[i]:.1f}" for i in range(8))
               + f"; max |sum_y S(y|x,D) - 1| = {norm_err:.1e}")
txt = "\n".join(out)
print(txt)
with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write(txt + "\n")

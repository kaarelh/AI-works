"""c9: time-bounded mixtures with length-based and round-based clocks (notes-final.md, Theorem 3.1(a),
Proposition 3.2a; referee m1, m2).

Toy model: Y = {0,1}; an input is a pair (length n, id); p(n) = n; the clock factor is g(t) = ceil(log2(t+1)) (the regret
statements hold for every nondecreasing unbounded g; the log log choice only matters for running time).
Comparators A_i are probability predictors with a simulated running time c_i * p(|x|) on every input
(a constant-factor time class C_p with constant c_i) and weights w_i = 2^-(i+1).

S_len (Theorem 3.1): machine i is active on inputs of length >= n_i and is used when its time c_i p(|x|)
  is within g(|x|) p(|x|); otherwise it predicts uniformly.  Bound (Thm 3.1(a), with the m1 wording):
  regret_i(k) <= log2(1/w_i) + #{j <= k : |x_j| < N_i} log2|Y|,   N_i = max(n_i, min{n : g(n) >= c_i}).
S_round (Prop 3.2a): machine i is active from round k_i on and is used when c_i p(|x_k|) <= g(k) p(|x_k|).
  Bound: regret_i(k) <= log2(1/w_i) + (J_i - 1) log2|Y|,   J_i = max(k_i, min{k : g(k) >= c_i}).
Both are per-round product mixtures (each machine predicts each round independently), so repeated
inputs with different labels are allowed.

Streams (seed 9): (A) 4000 rounds of distinct inputs, lengths growing, labels adversarial against S_len;
(B) 4000 rounds drawn from 12 short inputs (lengths 2..5) with noisy labels from comparator A_4.
We check both bounds at every prefix and report the final regrets.
"""
import math
import numpy as np

rng = np.random.default_rng(9)
NM = 6
c = [1, 2, 3, 3, 4, 5]                 # time constants c_i
n_act = [1, 2, 3, 4, 5, 6]             # activation lengths n_i (toy values; any schedule works)
k_act = [1, 2, 4, 8, 16, 32]           # activation rounds k_i
w = [2.0 ** -(i + 1) for i in range(NM)]
LOGY = 1.0


def g(t):
    return math.ceil(math.log2(t + 1))


def A(i, x):
    """prediction of comparator i: P(y=1 | x), a fixed pseudo-random function of (i, x) in [0.05, 0.95]"""
    n, ident = x
    h = (hash((i, n, ident)) % 10007) / 10007.0
    return 0.05 + 0.9 * h


def q_len(i, x):
    n = x[0]
    if n >= n_act[i] and c[i] * n <= g(n) * n:
        return A(i, x)
    return 0.5


def q_round(i, x, k):
    n = x[0]
    if k >= k_act[i] and c[i] * n <= g(k) * n:
        return A(i, x)
    return 0.5


N_i = [max(n_act[i], min(n for n in range(1, 10 ** 6) if g(n) >= c[i])) for i in range(NM)]
J_i = [max(k_act[i], min(k for k in range(1, 10 ** 9) if g(k) >= c[i])) for i in range(NM)]
out = []


def P(s):
    print(s)
    out.append(s)


P(f"N_i (length thresholds) = {N_i}; J_i (round thresholds) = {J_i}")


def run(stream_inputs, label_rule):
    logS = {"len": np.log2(np.array(w)), "round": np.log2(np.array(w))}  # log2 of w_i * prod q_i
    lossS = {"len": 0.0, "round": 0.0}
    lossA = np.zeros(NM)
    short = np.zeros(NM)
    ok = {"len": True, "round": True}
    min_slack = {"len": np.inf, "round": np.inf}
    for k, x in enumerate(stream_inputs, start=1):
        ql = np.array([q_len(i, x) for i in range(NM)])
        qr = np.array([q_round(i, x, k) for i in range(NM)])
        # predictive P(y=1) of each mixture
        pl = float(np.sum(2.0 ** (logS["len"] - logS["len"].max()) * ql) / np.sum(2.0 ** (logS["len"] - logS["len"].max())))
        y = label_rule(x, pl)
        for key, qq in (("len", ql), ("round", qr)):
            lik = np.where(y == 1, qq, 1 - qq)
            new = logS[key] + np.log2(lik)
            lossS[key] = -float(np.log2(np.sum(2.0 ** new)))
            logS[key] = new
        a = np.array([A(i, x) for i in range(NM)])
        lossA += -np.log2(np.where(y == 1, a, 1 - a))
        short += np.array([x[0] < N_i[i] for i in range(NM)])
        for i in range(NM):
            b_len = math.log2(1 / w[i]) + short[i] * LOGY
            b_round = math.log2(1 / w[i]) + (J_i[i] - 1) * LOGY
            rl = lossS["len"] - lossA[i]
            rr = lossS["round"] - lossA[i]
            ok["len"] &= rl <= b_len + 1e-9
            ok["round"] &= rr <= b_round + 1e-9
            min_slack["len"] = min(min_slack["len"], b_len - rl)
            min_slack["round"] = min(min_slack["round"], b_round - rr)
    return lossS, lossA, ok, min_slack, short


# Stream A: distinct inputs, lengths 1..40 cycling upward, labels adversarial against S_len
inputs_A = []
ident = 0
for k in range(4000):
    n = 1 + min(40, k // 50)
    inputs_A.append((n, ident)); ident += 1
lossS, lossA, ok, ms, short = run(inputs_A, lambda x, pl: 0 if pl > 0.5 else 1)
P("Stream A (4000 distinct inputs, adversarial labels against S_len):")
P(f"  Thm 3.1(a) bound holds at every prefix for every comparator: {ok['len']} (min slack {ms['len']:.2f} bits)")
P(f"  round-based bound holds at every prefix: {ok['round']} (min slack {ms['round']:.2f} bits)")
P(f"  final regrets S_len - A_i: {[round(lossS['len'] - a, 1) for a in lossA]}")
P(f"  final regrets S_round - A_i: {[round(lossS['round'] - a, 1) for a in lossA]}")

# Stream B: repeated short inputs, noisy labels drawn from comparator 3
pool = [(n, j) for n in range(2, 6) for j in range(3)]
inputs_B = [pool[int(rng.integers(len(pool)))] for _ in range(4000)]
lossS, lossA, ok, ms, short = run(inputs_B, lambda x, pl: int(rng.random() < A(4, x)))
P("Stream B (4000 rounds from 12 short inputs, labels ~ A_4, so repeated inputs get different labels):")
P(f"  Thm 3.1(a)-type bound (short-input count) holds: {ok['len']}; but the count of short rounds grows: {short.tolist()}")
P(f"  final regret S_len - A_4 = {lossS['len'] - lossA[4]:.1f} bits (grows linearly: A_4 is never within its length-based budget)")
P(f"  round-based bound holds at every prefix: {ok['round']} (min slack {ms['round']:.2f} bits); "
  f"final regret S_round - A_4 = {lossS['round'] - lossA[4]:.1f} bits <= {math.log2(1 / w[4]) + (J_i[4] - 1):.0f}")

with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write("\n".join(out) + "\n")

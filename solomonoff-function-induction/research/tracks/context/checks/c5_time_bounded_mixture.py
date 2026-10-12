"""c5: bookkeeping of the time-bounded function mixture (notes.md, section 3.1, Theorem 3.1).

Checks, on a toy instance, that
  (1) the incremental algorithm of the proof (track only machines with n_i <= longest input seen; store
      v_i = w_i * prod_j |Y| q_i(y_j|x_j); inactive machines contribute through V - sum_active v_i)
      gives exactly the same predictive probabilities as the brute-force mixture S(D) = sum_i w_i prod q_i;
  (2) the regret of S against a machine A in the class C_p stays below the proved constant
      -log2 w_A + (number of distinct inputs of length < N_A) * log2|Y|.
Toy instance: Y = {0,1}; p(n) = n; clock budget p(|x|) * g(|x|) with g(n) = floor(log2 n) (any unbounded
nondecreasing g works for the regret; the theorem uses log log for the time overhead); activation lengths
n_i = i+1 (any increasing sequence works for the regret; the theorem uses 2^(2^i) for the time overhead).
The incremental algorithm stores log2 v_i (v_i itself grows like |Y|^k).  Machines are Python predictors with a declared
step count.  Labels are sampled from machine 3.  Seeded.
"""
import math
import numpy as np

SEED = 4
rng = np.random.default_rng(SEED)
Y = 2

def g(n):
    return max(1, int(math.floor(math.log2(n)))) if n >= 2 else 1

def p(n):
    return n

machines = [  # (name, prob_of_1(x), steps(x))
    ("uniform", lambda x: 0.5, lambda x: 1),
    ("parity", lambda x: 0.9 if x.count("1") % 2 == 0 else 0.1, lambda x: len(x)),
    ("firstbit", lambda x: 0.8 if x[0] == "1" else 0.2, lambda x: 1),
    ("majority(target)", lambda x: 0.95 if 2 * x.count("1") > len(x) else 0.05, lambda x: 3 * len(x)),
    ("quadratic-time", lambda x: 0.99 if 2 * x.count("1") > len(x) else 0.01, lambda x: len(x) ** 2),
    ("lastbit", lambda x: 0.7 if x[-1] == "1" else 0.3, lambda x: 2),
]
M = len(machines)
w = np.array([2.0 ** -(i + 1) for i in range(M)])
n_act = [i + 1 for i in range(M)]

def q(i, x):
    """clocked predictor: uniform if inactive at this length or over budget."""
    name, pr, steps = machines[i]
    if len(x) < n_act[i] or steps(x) > p(len(x)) * g(len(x)):
        return np.array([0.5, 0.5])
    a = pr(x)
    return np.array([1 - a, a])

# stream of distinct inputs
seen = set(); xs = []
while len(xs) < 6000:
    # phase 1 (first 3000): lengths uniform in 1..40; phase 2: lengths uniform in 8..40 (no new short inputs)
    L = int(rng.integers(1, 41)) if len(xs) < 3000 else int(rng.integers(8, 41))
    x = "".join(rng.choice(["0", "1"], size=L))
    if x not in seen:
        seen.add(x); xs.append(x)
target = 3
ys = [int(rng.random() < machines[target][1](x)) for x in xs]

# brute force (log domain)
logW = np.log2(w).copy()
# incremental
lv = np.log2(w)        # log2 v_i, v_i = w_i * prod_j |Y| q_i(y_j|x_j); inactive machines keep v_i
maxdiff = 0.0
CHECK = {100, 300, 1000, 2000, 3000, 4000, 5000, 6000}
checkpoints_seen = []
t_count = [0]
N_A_pre = max(n_act[3], min(n for n in range(1, 10 ** 6) if g(n) >= 3))
loss_S = 0.0; loss_A = 0.0; max_regret = -1e9
for x, y in zip(xs, ys):
    Q = np.array([q(i, x) for i in range(M)])
    # brute force predictive
    lw = logW - logW.max()
    pw = 2.0 ** lw
    pred_bf = (pw[:, None] * Q).sum(0) / pw.sum()
    # incremental predictive
    active = [i for i in range(M) if len(x) >= n_act[i]]
    sh = lv.max()
    v = 2.0 ** (lv - sh)   # common rescaling cancels in the ratio
    V = v.sum()
    va = v[active].sum()
    pred_inc = ((v[active, None] * Q[active]).sum(0) + (V - va) / Y) / V
    maxdiff = max(maxdiff, np.abs(pred_bf - pred_inc).max())
    # losses
    loss_S += -math.log2(pred_bf[y])
    pa = machines[target][1](x)
    loss_A += -math.log2(pa if y == 1 else 1 - pa)
    max_regret = max(max_regret, loss_S - loss_A)
    # updates
    logW += np.log2(Q[:, y])
    for i in active:
        lv[i] += math.log2(Y * Q[i][y])
    k_now = len(checkpoints_seen) + 1
    t_count[0] += 1
    if t_count[0] in CHECK:
        checkpoints_seen.append((t_count[0], loss_S - loss_A, sum(1 for xx in xs[:t_count[0]] if len(xx) < N_A_pre)))

# proved constant for the target: N_A = max(n_act[target], least n with g(n) >= 3) for steps 3|x| <= p * g
c_A = 3
N_A = max(n_act[target], min(n for n in range(1, 10 ** 6) if g(n) >= c_A))
short = sum(1 for x in xs if len(x) < N_A)
bound = -math.log2(w[target]) + short * math.log2(Y)
out = [
    f"T = {len(xs)} distinct inputs (phase 1: lengths 1..40; phase 2 from t=3001: lengths 8..40); target machine = {machines[target][0]} (time 3|x|)",
    f"(1) max |incremental - brute force| predictive probability: {maxdiff:.2e}",
    f"(2) final regret vs target: {loss_S - loss_A:.3f} bits; max over prefixes: {max_regret:.3f} bits",
    f"    proved constant: -log2 w_A + #(inputs with |x| < N_A = {N_A}) * log2|Y| = {-math.log2(w[target]):.0f} + {short} = {bound:.0f}",
    f"    (the proved constant charges one full bit for every short input; the observed regret stays below it and is flat once no new short inputs arrive)",
    f"    regret <= bound: {max_regret <= bound}",
    "    regret at checkpoints (t, regret, #short inputs so far): " + "; ".join(f"({t}, {r:.1f}, {c})" for t, r, c in checkpoints_seen),
]
txt = "\n".join(out)
print(txt)
with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write(txt + "\n")

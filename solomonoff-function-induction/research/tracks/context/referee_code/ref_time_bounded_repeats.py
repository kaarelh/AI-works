"""Referee check for notes.md section 3.1 (time-bounded SFI, Theorem 3.1), written independently of c5.

S(D) = sum_i w_i prod_{(x,y) in D} q_i(y|x), q_i = A_i's vector if |x| >= n_i and A_i finishes within
g(|x|) p(|x|) steps, else uniform.  Here the "machines" are a small explicit list with declared running
times (time model only), |Y| = 2, p(n) = n, g(n) = ceil(log2 log2 (n+4)).

(a) Distinct inputs: recompute the regret against the target machine and compare with the proved
    constant log2(1/w_i) + #{j : |x_j| < N_A} * log2|Y|; check the incremental algorithm of (b) against
    brute force; check the precision claim by perturbing stored weights by relative errors eps_k = k^-2.
(b) Repeated inputs with fresh noisy labels (the standard i.i.d. supervised setting with label noise),
    which notes 3.1 excludes with the sentence "restricting to distinct inputs loses nothing":
    (i) any random-FUNCTION predictor in the semimeasure convention assigns probability 0 to a repeated input
        with a different label (infinite loss);
    (ii) the product mixture S extended to sequences (multiply per round) is fine semantically, but its regret
        against the target grows linearly when a short input (|x| < N_A) recurs: the target is never activated there.
Seeded.  Output: ref_time_bounded_repeats_output.txt
"""
import math

import numpy as np

SEED = 99
rng = np.random.default_rng(SEED)
OUT = []


def log(s):
    OUT.append(s)
    print(s)


def g(n):
    return math.ceil(math.log2(math.log2(n + 4)))


def p(n):
    return n


# machines: (name, activation length n_i, weight w_i, time(x), prob vector function)
def parity(x):
    return sum(x) % 2


machines = [
    ("uniform", 1, 0.5, lambda x: 1, lambda x: np.array([0.5, 0.5])),
    ("first-bit 0.8", 2, 0.25, lambda x: 2, lambda x: np.array([0.2, 0.8]) if x[0] else np.array([0.8, 0.2])),
    # target: noisy parity, time 3|x| -> c_A = 3, needs g(|x|) >= 3, i.e. log2 log2 (n+4) > 2, n >= 13
    ("noisy parity (target)", 8, 0.125, lambda x: 3 * len(x), lambda x: np.array([0.1, 0.9]) if parity(x) else np.array([0.9, 0.1])),
    ("slow exact parity", 4, 0.125, lambda x: len(x) ** 2, lambda x: np.array([0.0, 1.0]) if parity(x) else np.array([1.0, 0.0])),
]
TARGET = 2


def q(i, x):
    name, ni, wi, tm, vec = machines[i]
    n = len(x)
    if n >= ni and tm(x) <= g(n) * p(n):
        return vec(x)
    return np.array([0.5, 0.5])


def N_A(i, cA):
    ni = machines[i][1]
    n = 1
    while g(n) < cA:
        n += 1
    return max(ni, n)


def run_bruteforce(seq):
    logS = np.array([math.log2(m[2]) for m in machines])  # log2 of w_i * prod q_i
    loss = 0.0
    for x, y in seq:
        qs = np.array([q(i, x)[y] for i in range(len(machines))])
        num = np.logaddexp2.reduce(logS + np.log2(np.maximum(qs, 1e-300)))
        den = np.logaddexp2.reduce(logS)
        loss += den - num
        logS = logS + np.log2(np.maximum(qs, 1e-300))
    return loss


def run_incremental(seq, eps_fn=None):
    """the notes' bookkeeping: v_i = w_i |Y|^k prod q_i, inactive machines untouched; optional relative
    perturbation of the updated weights (precision test)."""
    v = np.array([m[2] for m in machines], dtype=float)
    V = v.sum()
    loss = 0.0
    for k, (x, y) in enumerate(seq, start=1):
        act = [i for i in range(len(machines)) if len(x) >= machines[i][1]]
        pv = sum(v[i] * q(i, x)[y] for i in act) + (V - sum(v[i] for i in act)) / 2
        loss += -math.log2(pv / V)
        for i in act:
            nv = v[i] * 2 * q(i, x)[y]
            if eps_fn is not None:
                nv *= 1 + eps_fn(k) * rng.uniform(-1, 1)
            V += nv - v[i]
            v[i] = nv
        if k % 50 == 0:  # renormalise to avoid overflow (does not change predictions)
            v /= V
            V = 1.0
    return loss


def target_loss(seq):
    return sum(-math.log2(machines[TARGET][4](x)[y]) for x, y in seq)


def main():
    cA = 3
    NA = N_A(TARGET, cA)
    log(f"target machine: noisy parity, time 3|x| (c_A = 3), activation n_i = {machines[TARGET][1]}; N_A = {NA}")
    # (a) distinct inputs, lengths 1..20, labels from the target's law
    seen = set()
    seq = []
    while len(seq) < 3000:
        n = int(rng.integers(1, 21))
        x = tuple(int(b) for b in rng.integers(0, 2, size=n))
        if x in seen:
            continue
        seen.add(x)
        y = int(rng.random() < machines[TARGET][4](x)[1])
        seq.append((x, y))
    Lb = run_bruteforce(seq)
    Li = run_incremental(seq)
    Lp = run_incremental(seq, eps_fn=lambda k: k ** -2.0)
    LA = target_loss(seq)
    short = sum(1 for x, _ in seq if len(x) < NA)
    bound = math.log2(1 / machines[TARGET][2]) + short * 1.0
    log("(a) 3000 distinct inputs, lengths 1..20, labels drawn from the target's law")
    log(f"    S loss (brute force) {Lb:.4f}; incremental {Li:.4f}; |diff| {abs(Lb - Li):.2e}")
    log(f"    with relative weight errors eps_k = k^-2: loss {Lp:.4f}; change {Lp - Li:+.4f} bits (sum eps_k = {sum(k ** -2.0 for k in range(1, 3001)):.3f})")
    log(f"    target loss {LA:.4f}; regret {Lb - LA:.4f}; proved constant log2(1/w)+#short*log2|Y| = {bound:.1f} "
        f"(#short = {short}); regret <= constant: {Lb - LA <= bound + 1e-9}")
    # (b)(i)
    log("(b)(i) random-function semantics: after (x0, 1) is observed, nu((x0,0) | D) = nu(D + (x0,0)) / nu(D) with")
    log("       D + (x0,0) inconsistent, hence 0: a repeated input with a fresh noisy label costs infinite log loss.")
    # (b)(ii) a single short input repeated with fresh labels
    x0 = (1, 0, 1)  # |x0| = 3 < N_A; parity 0 -> target says P(y=1) = 0.1
    for T in [100, 1000, 10000]:
        rep = [(x0, int(rng.random() < 0.1)) for _ in range(T)]
        Ls = run_bruteforce(rep)
        La = target_loss(rep)
        log(f"(b)(ii) x0 = {x0} repeated T = {T:5d} times, labels ~ target law: S loss {Ls:9.2f}, target loss {La:9.2f}, "
            f"regret {Ls - La:9.2f} (= {(Ls - La) / T:.3f} per round)")
    log("Reading: Theorem 3.1(a) is correct for distinct inputs, but the justification 'restricting to distinct inputs")
    log("loses nothing' is false for the comparison class used (conditional laws with fresh noise): with repeats the")
    log("random-function semantics breaks, and the length-activated product mixture has linear regret on recurring short inputs.")
    with open(__file__.replace(".py", "_output.txt"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()

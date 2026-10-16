#!/usr/bin/env python3
"""n4: what a law is worth to raw-data prediction and to question answering.

Scout N2 (novel-science), push P4.  Seed 20261015.  Writes n4_raw_vs_questions.out next to itself.

World: micro-states x in {0,1}^m; dynamics x_{t+1} = pi(x_t), pi a uniformly random permutation of each
weight class (so the Hamming weight |x| is conserved: the "law").  Raw data: the trajectory x_0, x_1, ...
Questions: "what is |x_t|?".

  A. exact per-step raw loss of the Bayes predictor that knows the law (log2 of the number of unvisited
     states of the weight class, ~ log2 C(m, w)) against one that does not (~ m); gain per step and
     relative gain; per-question QA loss with and without the law (0 against log2(m+1)).
  B. simulation (m = 12, T = 300): cumulative raw log loss of three predictors (law known, law unknown,
     the 1/2-1/2 Bayes mixture) and of two question answerers (law known; uniform over weights), and the
     mixture of these two.
"""
import math
import random
import sys

SEED = 20261015
OUT = []


def out(*a):
    s = " ".join(str(x) for x in a)
    OUT.append(s)
    print(s)


def main():
    rng = random.Random(SEED)
    out(f"# n4_raw_vs_questions.py seed={SEED} python={sys.version.split()[0]}")
    out("== A. per-step raw loss (bits) at the start of a trajectory, w = m/2; and per-question QA loss")
    out("     m   raw, law known   raw, law unknown   gain/step  relative gain   1/2 log2(pi m/2)   QA w/o law   QA with law")
    for m in (8, 16, 32, 64, 128, 1024, 10 ** 6):
        w = m // 2
        known = (math.lgamma(m + 1) - 2 * math.lgamma(w + 1)) / math.log(2)
        unknown = float(m)
        gain = unknown - known
        out(f"  {m:8d}  {known:14.3f}  {unknown:16.1f}  {gain:9.3f}  {gain / unknown:12.2e}  {0.5 * math.log2(math.pi * m / 2):14.3f}"
            f"  {math.log2(m + 1):10.2f}   0")

    out("\n== B. simulation: m=12, weight class w=6 (C(12,6)=924 states), T=300 steps")
    m, w, T = 12, 6, 300
    classes = {}
    for x in range(1 << m):
        classes.setdefault(bin(x).count("1"), []).append(x)
    pi = {}
    for k, xs in classes.items():
        ys = list(xs)
        rng.shuffle(ys)
        for a, b in zip(xs, ys):
            pi[a] = b
    x0 = rng.choice(classes[w])
    traj = [x0]
    for _ in range(T):
        traj.append(pi[traj[-1]])
    # Bayes predictors for a uniformly random permutation restricted to a set of size Nset containing the path:
    # next state is uniform over (unvisited states of the set) plus x0 (closing the cycle).
    def loss(Nset):
        # after the trajectory first returns to x0 the cycle is known and later steps cost 0 bits
        tot = 0.0
        seen = {traj[0]}
        per = []
        closed = False
        for t in range(T):
            nxt = traj[t + 1]
            if closed:
                per.append(0.0)
                continue
            avail = Nset - len(seen) + 1  # unvisited + x0
            if nxt in seen and nxt != traj[0]:
                raise RuntimeError("impossible")
            lp = -math.log2(1.0 / avail)
            per.append(lp)
            tot += lp
            if nxt == traj[0]:
                closed = True
            seen.add(nxt)
        return tot, per
    tot_known, per_known = loss(len(classes[w]))
    tot_unknown, per_unknown = loss(1 << m)
    # mixture with prior 1/2 each: -log2(1/2 2^-known + 1/2 2^-unknown) on the whole trajectory
    a, b = min(tot_known, tot_unknown), max(tot_known, tot_unknown)
    mix = a + 1 - math.log2(1 + 2 ** (-(b - a)))
    first_return = next((t for t in range(1, T + 1) if traj[t] == x0), None)
    out(f"  first return to x0 (cycle length) within T: {first_return}")
    out(f"  cumulative raw loss: law known {tot_known:.1f}; law unknown {tot_unknown:.1f}; mixture {mix:.1f}"
        f"  (law's share of the unknown-law loss: {(tot_unknown - tot_known) / tot_unknown:.4f})")
    # QA: questions |x_t| for t = 1..T (x_0's weight given)
    qa_known = 0.0
    qa_uniform = T * math.log2(m + 1)
    qa_mix = -math.log2(0.5 * 1.0 + 0.5 * 2 ** (-qa_uniform))
    out(f"  cumulative QA loss over T questions: law known {qa_known:.1f}; uniform over weights {qa_uniform:.1f};"
        f" mixture {qa_mix:.2f}  (law's share: {(qa_uniform - qa_known) / qa_uniform:.4f})")
    with open(__file__.replace(".py", ".out"), "w") as f:
        f.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()

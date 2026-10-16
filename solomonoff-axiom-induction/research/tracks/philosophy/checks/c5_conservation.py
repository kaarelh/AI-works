"""c5_conservation.py -- what a conservation law is worth to raw-data prediction and to question answering.

Thread `philosophy`, target T2 (notes.md section 2.2).  Seed 20261015.  Writes c5_conservation.out next
to itself.  An independent re-implementation of scout N2's n4_raw_vs_questions.py (different code,
different sampling scheme, exact expectations added); its outputs are compared with n4's at the end.

World W_m: micro-states x in {0,1}^m; the dynamics pi is a uniformly random permutation of each
weight class {x : |x| = w} (so |x| is conserved); x_0 is uniform on the class of weight w = m/2.
  Raw data:   the trajectory x_0, x_1, ..., x_T.
  Questions:  "what is |x_t|?", t = 0..T (answers in {0..m}).
Predictors (Bayes for the stated hypotheses):
  RAW-LAW:    pi is a uniformly random permutation of each weight class;
  RAW-NOLAW:  pi is a uniformly random permutation of {0,1}^m;
  QA-LAW:     |x_t| = |x_0| for all t, |x_0| uniform on {0..m};
  QA-NOLAW:   |x_t| i.i.d. uniform on {0..m};
  MIX:        prior 1/2 on each of the two hypotheses of a task.
Under a uniformly random permutation of a set S, given a path x_0..x_t of distinct states, x_{t+1}
is uniform on (S minus the path) together with x_0; after the path returns to x_0 the cycle is known
and later steps cost 0 bits.  The cycle containing x_0 in a uniformly random permutation of C
elements has length uniform on {1..C} (standard; checked by simulation in part C).

Parts:
  A. per-step raw loss at the start of a trajectory (exact), and per-question QA loss;
  B. exact expected cumulative losses over T steps (expectation over the cycle length), m = 12,
     T = 300 and T = infinity (the whole cycle), and the law's share of each task's loss;
  C. simulation by sequential sampling of the path (not by building pi), 2000 runs at m = 12,
     T = 300: means against part B; the cycle-length law against uniform; one run printed;
  D. the comparison with scout N2's n4 output (copied below as literals).
"""
import math
import sys
import numpy as np

SEED = 20261015


def log2comb(m, w):
    if m <= 4096:
        return math.log2(math.comb(m, w))
    return (math.lgamma(m + 1) - math.lgamma(w + 1) - math.lgamma(m - w + 1)) / math.log(2)


def raw_losses(C, S, ell, T):
    """cumulative raw loss (bits) of the Bayes predictors for sets of size C (law) and S (no law),
    over steps 1..T, when the true cycle of x_0 has length ell (x_ell = x_0).  Steps t = 0..min(T,ell)-1
    cost log2(size - t); later steps cost 0."""
    k = min(T, ell)
    t = np.arange(k)
    return float(np.sum(np.log2(C - t))), float(np.sum(np.log2(S - t)))


def mix(a, b):
    lo, hi = min(a, b), max(a, b)
    return lo + 1 - math.log2(1 + 2.0 ** (-(hi - lo)))


def main():
    out = []

    def p(*a):
        s = " ".join(str(x) for x in a)
        out.append(s)
        print(s)

    p("# c5_conservation.py  seed=%d  numpy %s  python %s" % (SEED, np.__version__, sys.version.split()[0]))
    p("== A. per-step raw loss at the start of a trajectory (bits); per-question QA loss")
    p("        m   law known  law unknown   gain/step   share of raw   1/2 log2(pi m/2)   QA no law  QA law")
    for m in (8, 12, 16, 32, 64, 128, 1024, 10 ** 6):
        w = m // 2
        known = log2comb(m, w)          # log2(C - 0): the first prediction x_1 given x_0
        unknown = float(m)
        gain = unknown - known
        p("  %7d  %10.3f  %11.1f  %10.3f   %12.3e   %16.3f   %9.2f  %6d"
          % (m, known, unknown, gain, gain / unknown, 0.5 * math.log2(math.pi * m / 2), math.log2(m + 1), 0))

    p("")
    p("== B. exact expectations over the cycle length ell ~ Uniform{1..C}; m = 12, w = 6, C = 924, S = 4096")
    m, w = 12, 6
    C, S = math.comb(m, w), 2 ** m
    for T in (300, 10 ** 9):
        EL, EU, EM, Eshare_num = 0.0, 0.0, 0.0, 0.0
        for ell in range(1, C + 1):
            a, b = raw_losses(C, S, ell, T)
            EL += a / C
            EU += b / C
            EM += mix(a, b) / C
        # questions t = 0..T (T+1 questions), capped at the trajectory length used
        nq = min(T, 10 ** 6) + 1
        qa_u = nq * math.log2(m + 1)
        qa_l = math.log2(m + 1)                  # the first answer; then |x_t| = |x_0|
        qa_m = mix(qa_l, qa_u)
        Ttxt = "T=%d" % T if T < 10 ** 9 else "T=inf (whole cycle)"
        p("  %s: E raw loss  law %.2f   no law %.2f   mixture %.2f   law's share of the no-law loss %.4f"
          % (Ttxt, EL, EU, EM, (EU - EL) / EU))
        p("  %s: QA loss (%d questions incl. t=0)  law %.2f   no law %.2f   mixture %.2f   law's share %.4f"
          % (Ttxt, nq, qa_l, qa_u, qa_m, (qa_u - qa_l) / qa_u))
    p("  per-step raw gain of the law, averaged over the pre-closure steps of a whole cycle:")
    tot_gain, tot_steps = 0.0, 0.0
    for ell in range(1, C + 1):
        a, b = raw_losses(C, S, ell, 10 ** 9)
        tot_gain += (b - a) / C
        tot_steps += ell / C
    p("    E[gain] / E[steps] = %.4f bits per step; log2(S/C) = %.4f; 1/2 log2(pi m/2) = %.4f"
      % (tot_gain / tot_steps, math.log2(S / C), 0.5 * math.log2(math.pi * m / 2)))

    p("")
    p("== C. simulation by sequential sampling of the path (m = 12, T = 300, 2000 runs)")
    rng = np.random.default_rng(SEED)
    states = [x for x in range(1 << m) if bin(x).count("1") == w]
    runs = 2000
    T = 300
    sL, sU, sM, ells = [], [], [], []
    first = None
    for r in range(runs):
        x0 = states[rng.integers(C)]
        visited = {x0}
        unvisited = [s for s in states if s != x0]
        rng.shuffle(unvisited)          # the order in which new states are drawn: uniform
        path = [x0]
        ell = None
        lossL = lossU = 0.0
        for t in range(T):
            # next = x0 with prob 1/(C - t), else a fresh unvisited state
            if ell is not None:
                path.append(path[(t + 1) % ell])
                continue
            nfree = C - 1 - t
            lossL += math.log2(C - t)
            lossU += math.log2(S - t)
            if rng.random() < 1.0 / (C - t) or nfree == 0:
                ell = t + 1
                path.append(x0)
            else:
                nxt = unvisited.pop()
                visited.add(nxt)
                path.append(nxt)
        if ell is None:
            # cycle length > T: draw the rest of the cycle length for the cycle-law check
            t = T
            while True:
                if rng.random() < 1.0 / (C - t) or C - 1 - t == 0:
                    ell = t + 1
                    break
                t += 1
        assert all(bin(s).count("1") == w for s in path)
        sL.append(lossL)
        sU.append(lossU)
        sM.append(mix(lossL, lossU))
        ells.append(ell)
        if first is None:
            first = (ell, lossL, lossU, mix(lossL, lossU))
    sL, sU, sM, ells = map(np.array, (sL, sU, sM, ells))
    p("  mean raw loss  law %.2f (se %.2f)   no law %.2f (se %.2f)   mixture %.2f   law's share of mean no-law loss %.4f"
      % (sL.mean(), sL.std() / math.sqrt(runs), sU.mean(), sU.std() / math.sqrt(runs), sM.mean(),
         (sU.mean() - sL.mean()) / sU.mean()))
    p("  max over runs of (mixture - law) = %.4f bits (bound: 1)" % float(np.max(sM - sL)))
    # cycle-length law: compare with uniform on 1..C by deciles
    q = np.histogram(ells, bins=10, range=(0.5, C + 0.5))[0]
    p("  cycle length deciles (expected %d each under Uniform{1..%d}): %s; KS distance %.4f"
      % (runs // 10, C, [int(v) for v in q], float(np.max(np.abs(np.sort(ells) / C - (np.arange(1, runs + 1) / runs))))))
    p("  first run: cycle length %d; raw loss law %.1f, no law %.1f, mixture %.1f; law's share %.4f"
      % (first[0], first[1], first[2], first[3], (first[2] - first[1]) / first[2]))

    p("")
    p("== D. comparison with scout N2's n4_raw_vs_questions.out")
    n4A = {8: (6.129, 1.871), 16: (13.652, 2.348), 32: (29.163, 2.837), 64: (60.669, 3.331),
           128: (124.171, 3.829), 1024: (1018.674, 5.326), 10 ** 6: (999989.708, 10.292)}
    worst = 0.0
    for m_, (k_, g_) in n4A.items():
        k2 = log2comb(m_, m_ // 2)
        worst = max(worst, abs(k2 - k_), abs((m_ - k2) - g_))
    p("  part A: largest difference from n4's printed per-step values: %.4f bits (n4 prints 3 decimals)" % worst)
    p("  part B of n4 is one run (cycle closed at step 275): raw loss law 2643.5, no law 3286.4, share 0.1956.")
    a, b = raw_losses(924, 4096, 275, 300)
    p("  this script's exact formula for ell = 275, T = 300: law %.1f, no law %.1f, share %.4f" % (a, b, (b - a) / b))
    p("  n4's QA convention: T = 300 questions t = 1..300 with x_0's weight given to the law-knower (0 bits)")
    p("  and %.1f bits without the law; this script counts t = 0 too and does not give |x_0|." % (300 * math.log2(13)))
    p("# done")
    with open(__file__.replace(".py", ".out"), "w") as f:
        f.write("\n".join(out) + "\n")


if __name__ == "__main__":
    main()

"""High stakes against low stakes, with the adder class of toy.py.

Two closed systems answered by the same imitator (the per-call mixture of Protocol R):
  chain   L independent additions; the run is good only if every answer is the human's
          (every call is critical);
  survey  L independent additions; the run is good if at most a fraction THETA of the answers
          differ from the human's (the human system tolerates THETA * L faults).
Inputs are uniform pairs, so the two systems have the same calls and differ only in what counts
as a good run. Rehearsal asks the human one uniformly chosen call per run.

Reported, for a uniformly random rehearsal round among the first n: the probability that the run
is bad. Theorem R1/R2 bounds the first by L K ln 2 / n, Theorem R3 the second by K ln 2 / (THETA n).

Also the validation certificate (Theorem V1(a)): after n rehearsal questions freeze the mixture,
ask m more questions without updating, and compare the bound ln(1/delta)/m (when no recorded pair
disagrees) with the true per-call rate of unfaithful calls.

Usage: python3 toy_stakes.py [trials]
"""
import sys

import numpy as np

from toy import F, K_BITS, M, PRIOR, mixture_answerer, update

THETA = 0.05


def rehearse(rng, L, n):
    """Returns the number of unfaithful calls in each rehearsal run, and the final posterior."""
    w = PRIOR.copy()
    bad = np.zeros(n)
    for t in range(n):
        ans = mixture_answerer(rng, w)
        xs = rng.integers(0, M * M, size=L)
        ys = ans(xs)
        bad[t] = (ys != F[xs]).sum()
        j = rng.integers(0, L)
        w = update(w, xs[j], F[xs[j]])
    return bad, w


def true_rate(w):
    """Per-call probability that the frozen mixture's draw differs from f, for uniform inputs."""
    wrong = (np.asarray(F)[None, :] != __import__("toy").TABLE)      # hypothesis x input
    return float((w[:, None] * wrong).sum() / (M * M))


if __name__ == "__main__":
    trials = int(sys.argv[1]) if len(sys.argv) > 1 else 20
    rng = np.random.default_rng(2)
    kln2 = K_BITS * np.log(2)
    ns = (100, 400, 1600, 6400)
    print(f"K ln 2 = {kln2:.2f}; tolerated fraction THETA = {THETA}; trials = {trials}\n")
    print("probability that the run of a uniformly random round among the first n is bad")
    print(f"{'L':>6} {'n':>6}   {'chain: any call':>16} {'bound LK ln2/n':>15}   "
          f"{'survey: > THETA L':>18} {'bound K ln2/(THETA n)':>22}")
    for L in (16, 256, 4096):
        chain = np.zeros(max(ns))
        survey = np.zeros(max(ns))
        for _ in range(trials):
            bad, _ = rehearse(rng, L, max(ns))
            chain += (bad > 0) / trials
            survey += (bad > THETA * L) / trials
        for n in ns:
            print(f"{L:6d} {n:6d}   {chain[:n].mean():16.4f} {min(1, L * kln2 / n):15.4f}   "
                  f"{survey[:n].mean():18.4f} {min(1, kln2 / (THETA * n)):22.4f}")
        print()

    print("validation certificate for the mixture frozen after n rehearsal questions (L = 256)")
    print(f"{'n':>6} {'m':>6}   {'runs with no disagreement':>26}   {'bound ln(20)/m':>15}   "
          f"{'true rate, mean':>16}   {'true rate > bound among those':>30}")
    delta = 0.05
    for n in (400, 1600):
        for m in (100, 1000):
            clean, rates, viol = 0, [], 0
            reps = 4 * trials
            for _ in range(reps):
                _, w = rehearse(rng, 256, n)
                rate = true_rate(w)
                rates.append(rate)
                # m validation questions: each recorded pair disagrees with probability `rate`
                if rng.binomial(m, rate) == 0:
                    clean += 1
                    viol += rate > np.log(1 / delta) / m
            print(f"{n:6d} {m:6d}   {clean / reps:26.3f}   {np.log(1 / delta) / m:15.5f}   "
                  f"{np.mean(rates):16.5f}   {viol}/{clean}")

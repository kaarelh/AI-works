#!/usr/bin/env python3
"""Independent check of the example of Proposition 6.3 (rehearsal-core.md) for small parameters.

The script rehearsal-core_lastround_count.py computes E beta(M^(t)) by a recursion over posterior
states that uses the closed form of the posterior.  Here Protocol R is simulated directly: all
2^(N+1) hypotheses are kept with their likelihoods, the mixture is computed from them, a run of
the scaffold is drawn, one uniformly chosen call is put to the human.  The simulated mean of
beta(M^(t)) is compared with the recursion.  (Fixed seed.)
"""
import importlib.util
import itertools
import math
import os
import random

import numpy as np

here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("count", os.path.join(here, "rehearsal-core_lastround_count.py"))
count = importlib.util.module_from_spec(spec)
spec.loader.exec_module(count)


def simulate(L, n, lam, N, trials, seed=1, a=1.0 / 3.0):
    rng = random.Random(seed)
    p = a * L / n
    kappa = (lam + 1.0) / n
    eta = math.exp(-lam)
    # inputs: 0 = c, 1 = r, 2.. = b_1..b_N ; a hypothesis is the vector of Pr[answer 1] at each input
    hyps, weights = [], []
    for S in itertools.product((0, 1), repeat=N):
        hyps.append([0.0, 1.0] + [float(s) for s in S]); weights.append(eta * 2.0 ** (-N) / (1 + eta))                  # h_S
        hyps.append([1 - math.exp(-kappa), 0.0] + [float(s) for s in S]); weights.append(2.0 ** (-N) / (1 + eta))    # g_S
    H = np.array(hyps); w = np.array(weights)
    f = np.array([0.0, 1.0] + [0.0] * N)            # the human: answers 0 at c, 1 at r, 0 at every trap

    def beta_of(M):
        """expected number of unfaithful calls of a run of the kernel M (M[x] = Pr[answer 1 at x])"""
        e = np.abs(M - f)                           # Pr[the draw differs from f(x)]
        tot = (1 - p) * L * e[0]
        for i in range(N):
            tot += (p / N) * (e[1] + (1 - e[1]) * (L - 1) * e[2 + i] + e[1] * (L - 1) * e[0])
        return tot

    sums = np.zeros(n + 2)
    for _ in range(trials):
        lik = np.ones(len(w))
        for t in range(1, n + 2):
            post = w * lik
            post /= post.sum()
            M = post @ H
            sums[t] += beta_of(M)
            if t == n + 1:
                break
            # a run of the scaffold answered by M
            if rng.random() < p:
                i = rng.randrange(N)
                y1 = 1 if rng.random() < M[1] else 0
                xs = [1] + [2 + i if y1 == 1 else 0] * (L - 1)
            else:
                xs = [0] * L
            x = xs[rng.randrange(L)]                # the call put to the human
            ans = f[x]
            lik = lik * (H[:, x] if ans == 1.0 else 1 - H[:, x])
    return sums / trials


if __name__ == "__main__":
    for (L, n, lam, N, trials) in ((6, 60, 2.0, 3, 20000), (8, 80, 3.0, 4, 10000)):
        mc = simulate(L, n, lam, N, trials)
        avg, last, bound, proved = count.run(L, n, lam, N, verbose=False)
        print(f"L={L} n={n} lambda={lam} N={N}: recursion: avg_t E beta = {avg:.5f}, E beta(M^(n+1)) = {last:.5f};  "
              f"simulation ({trials} rehearsals): avg_t = {mc[1:n + 1].mean():.5f}, last = {mc[n + 1]:.5f};  "
              f"bound L K ln2/n = {bound:.5f}")

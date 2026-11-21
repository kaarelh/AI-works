"""Thread G: numerical checks of two claims in threadG-byproducts.md.

1. Proposition G2(c): under the seeded rule "while units remain, with probability p redo a
   uniform done unit instead of doing a new one", the probability that unit u is never redone
   during the routine is about (u/N)^(p/(1-p)); averaged over u it is about 1 - p.
2. Lemma S-rand bookkeeping on random seeded humans: on every failed run with tau_0 <= n0,
   sum over mistakes of min(c_k^+, sigma+1) >= sigma+1, where c_k = tau_{k+1} - tau_k + 1 is
   computed with the run's own future seeds (and c_k = 0 once tau is infinite).

Usage: python3 threadG_checks.py
"""

import numpy as np


def check_redo(N, p, trials, rng):
    never = np.zeros(N)
    for _ in range(trials):
        j, redone = 0, np.zeros(N, bool)
        while j < N:
            if j >= 1 and rng.random() < p:
                redone[rng.integers(j)] = True
            else:
                j += 1
        # unit u is done when j goes from u to u+1; only redos after that count
        never += ~redone
    # redos of u can only happen after u is done, so 'redone' already means 'after'
    return never / trials


def lemma_s_rand(trials, rng):
    """Random humans on a small notebook model with seeds. A notebook is (units done, insight
    flag); the human's step with seed s: if the insight is missing and the touched unit is the
    trigger, write it. Touched unit: new unit if s < 1-p or nothing is done, else a uniform done
    unit (decided by s). Success: all N units and the insight. The 'imitator' is arbitrary: at
    each step it copies the human (1/2), omits the insight (0.3) or writes nothing (0.2)."""
    bad = checked = 0
    for _ in range(trials):
        N = int(rng.integers(2, 7))
        p = float(rng.choice([0.0, 0.3, 0.6]))
        t = int(rng.integers(N))
        n0 = int(np.ceil(N / (1 - p))) + 2
        sigma = int(rng.integers(0, 6))
        n = n0 + sigma
        H = 60                                   # horizon for tau (beyond it: infinite)
        seeds = rng.random(n + H)

        def touched(j, s):
            """Unit touched by a step with seed s at j units done, and the new unit count."""
            if j < N and (j == 0 or s < 1 - p):
                return j, j + 1                  # a new unit
            if j < N:                            # redo: uniform done unit
                return int(j * (s - (1 - p)) / p), j
            return int(N * s), j                 # recheck once the routine is done

        def step(state, s):
            j, ins = state
            u, j2 = touched(j, s)
            return (j2, ins or (u == t))

        def tau(state, k):
            for m in range(H):
                if state[0] >= N and state[1]:
                    return m
                state = step(state, seeds[k + m])
            return np.inf

        x = (0, False)
        taus, M, costs = [tau(x, 0)], [], []
        for k in range(n):
            hum = step(x, seeds[k])
            r = rng.random()
            dec = hum if r < 0.5 else ((hum[0], x[1]) if r < 0.8 else x)   # copy / omit / skip
            if dec != hum:
                M.append(k)
            x = dec
            taus.append(tau(x, k + 1))
        tau0 = taus[0]
        fail = not (x[0] >= N and x[1])
        if not fail or tau0 > n0:
            continue
        checked += 1
        total = 0.0
        for k in M:
            if taus[k] == np.inf:
                c = 0.0
            else:
                c = taus[k + 1] - taus[k] + 1
            total += min(max(c, 0.0), sigma + 1)
        if total < sigma + 1:
            bad += 1
    return checked, bad


def main():
    rng = np.random.default_rng(2026)
    print("1. P(unit u never redone during the routine) vs (u/N)^(p/(1-p)), N = 64, 4000 trials")
    for p in (0.25, 0.5):
        est = check_redo(64, p, 4000, rng)
        a = p / (1 - p)
        us = np.arange(64)
        pred = ((us + 1) / 64) ** a
        print(f"   p = {p}: mean over u {est.mean():.3f} (1 - p = {1 - p:.3f}); "
              f"u = 8, 16, 32, 48: {np.round(est[[8, 16, 32, 48]], 3)} "
              f"vs {np.round(pred[[8, 16, 32, 48]], 3)}")
    print("2. Lemma S-rand bookkeeping on 20000 random seeded runs:")
    checked, bad = lemma_s_rand(20000, rng)
    print(f"   failed runs with tau_0 <= n0: {checked}; violations of "
          f"sum min(c+, sigma+1) >= sigma+1: {bad}")


if __name__ == "__main__":
    main()

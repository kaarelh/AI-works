"""Thread C: brute-force checks of Theorems A and B of threadC-persistence.md.

Drafts are (step, set of items) with items in {0..U-1}; problems start from the empty set.
A persistent human is generated as a random monotone rule system: rule r writes item o_r at
every draft at step >= tau_r that contains pre_r (and lacks o_r). Such a human satisfies
persistence (X_1) on all drafts. Decoders are arbitrary append-only maps (random, memoised).

Checked, on every (human, decoder) pair:
  A   if some item of the human's final draft is missing from the decoder's final draft and
      fell due at some decoder draft x'_t (t <= n-1), the decoder errs at step n-1;
      and the steps at which that item is due form an up-set of [0, n) (so bisection works);
  B   the delay delta_k = min{d : x'_k contains c_{k-d}} rises only at mistakes, by at most
      one; hence a run whose final draft misses c_{n-sigma} has at least sigma+1 mistakes.
Counterexamples: the same checks on humans with inhibiting rules (an item is written only
if some other item is absent: "substitutes"). Some of these humans happen to be persistent;
every violation should come from one that is not (viol_by_persistent_humans = 0).

Usage: python3 threadC_checks.py
"""

import itertools

import numpy as np


def make_human(rng, U, n, inhibit=False):
    rules = []
    for _ in range(rng.integers(2, 2 * U + 1)):
        o = int(rng.integers(U))
        pre = frozenset(int(i) for i in np.flatnonzero(rng.random(U) < 0.25) if i != o)
        tau = int(rng.integers(0, n))
        inh = None
        if inhibit and rng.random() < 0.5:
            inh = int(rng.integers(U))
            if inh == o:
                inh = None
        rules.append((o, pre, tau, inh))

    def E(j, c):
        out = set(c)
        for (o, pre, tau, inh) in rules:
            if j >= tau and pre <= c and (inh is None or inh not in c):
                out.add(o)
        return frozenset(out)
    return E


def make_decoder(rng, U, E, p_copy):
    memo = {}

    def G(j, c):
        key = (j, c)
        if key not in memo:
            if rng.random() < p_copy:
                memo[key] = E(j, c)
            else:
                extra = frozenset(int(i) for i in np.flatnonzero(rng.random(U) < 0.3))
                drop = frozenset(int(i) for i in np.flatnonzero(rng.random(U) < 0.5))
                memo[key] = frozenset(c | ((E(j, c) - drop) | extra))
        return memo[key]
    return G


def persistent(E, U, n):
    """X_1 on all drafts: (j, c) <= (j', c') implies E(j, c) <= E(j', c')."""
    subsets = [frozenset(s) for r in range(U + 1) for s in itertools.combinations(range(U), r)]
    for j in range(n):
        for c in subsets:
            e = E(j, c)
            for j2 in range(j, n):
                for c2 in subsets:
                    if c <= c2 and not e <= E(j2, c2):
                        return False
    return True


def check(trials, inhibit, seed):
    rng = np.random.default_rng(seed)
    stats = dict(pairs=0, persistent_humans=0, fails=0, ripe_fail=0, ripe_fail_no_last=0,
                 upset_viol=0, delay_viol=0, slack_viol=0, viol_by_persistent_humans=0)
    for _ in range(trials):
        U, n = int(rng.integers(2, 5)), int(rng.integers(2, 7))
        E = make_human(rng, U, n, inhibit)
        pers = persistent(E, U, n)
        stats["persistent_humans"] += pers
        c = [frozenset()]
        for j in range(n):
            c.append(E(j, c[-1]))
        for _ in range(20):
            G = make_decoder(rng, U, E, p_copy=float(rng.uniform(0.3, 0.95)))
            x = [frozenset()]
            for j in range(n):
                x.append(G(j, x[-1]))
            M = [j for j in range(n) if G(j, x[j]) != E(j, x[j])]
            stats["pairs"] += 1
            missing = c[n] - x[n]
            # Theorem A
            ripe = [i for i in missing if any(i in E(t, x[t]) - x[t] for t in range(n))]
            if ripe:
                stats["ripe_fail"] += 1
                if (n - 1) not in M:
                    stats["ripe_fail_no_last"] += 1
                    stats["viol_by_persistent_humans"] += pers
                for i in ripe:
                    due = [i in E(t, x[t]) for t in range(n)]
                    first = due.index(True)
                    if not all(due[first:]):
                        stats["upset_viol"] += 1
                        stats["viol_by_persistent_humans"] += pers
            # Theorem B
            delta = [min(d for d in range(k + 1) if c[k - d] <= x[k]) for k in range(n + 1)]
            for k in range(n):
                inc = delta[k + 1] - delta[k]
                if inc > (1 if k in M else 0):
                    stats["delay_viol"] += 1
                    stats["viol_by_persistent_humans"] += pers
                    break
            if missing:
                stats["fails"] += 1
            for sigma in range(n + 1):
                if not c[n - sigma] <= x[n] and len(M) < sigma + 1:
                    stats["slack_viol"] += 1
                    stats["viol_by_persistent_humans"] += pers
                    break
    return stats


if __name__ == "__main__":
    print("monotone rule systems (persistent humans):", check(1500, inhibit=False, seed=1))
    print("with inhibiting rules (substitutes):      ", check(1500, inhibit=True, seed=2))

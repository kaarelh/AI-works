#!/usr/bin/env python3
"""c3_kolmogorov.py -- thread `fundamentals`: the Kolmogorov (shortest-compatible-theory) predictor.

Finite stand-in for Theorem 11.3 (answer to Q7) and Proposition 5.3(b) (F15(b)).
* L propositional atoms; theories are model sets (bitmasks over the 2^L valuations); 0 = inconsistent.
* A "program list" is a finite list of theories in a fixed priority order (the order in which the
  Kolmogorov predictor prefers them: by length, ties by a fixed rule).  It contains every complete
  description desc(w) (model set {w}) somewhere, plus random theories (incomplete, complete, inconsistent).
* The Kolmogorov predictor at each step uses the first theory in the list that is consistent and proves
  all data so far; it errs or abstains when that theory does not prove the next datum.
* The adversary of Theorem 11.3: pi(w) := first theory proving desc(w); w* := the w whose pi(w) is last;
  at each step present (not desc(v), true) for some v != w* left open by the current theory.
* Bayes comparison: the posterior-argmax trichotomy predictor with weights 2^-len (len nondecreasing
  along the list); its mistakes are at most -log(M(D)/M(empty)) (Proposition 5.3(a)).
Seed 20261016.  Output: c3_kolmogorov.out.
"""
import math
import os
import random

SEED = 20261016
rng = random.Random(SEED)
OUT = []


def out(s=""):
    OUT.append(s)
    print(s)


def subset(a, b):
    return a & ~b == 0


def run(L, n_random, order_mode):
    nv = 1 << L
    FULL = (1 << nv) - 1
    theories = [1 << w for w in range(nv)]
    for _ in range(n_random):
        r = rng.random()
        if r < 0.1:
            theories.append(0)
        elif r < 0.25:
            theories.append(FULL)
        else:
            theories.append(rng.getrandbits(nv) or 1)
    rng.shuffle(theories)
    if order_mode == "decoys first":
        # descriptions placed early, random theories after: the worst case for the predictor
        theories.sort(key=lambda M: 0 if (M and M & (M - 1) == 0) else 1)
    lens = [int(math.log2(j + 2)) for j in range(len(theories))]
    weights = [2.0 ** (-2 * l) for l in lens]

    def proves_all(M, data_masks):
        return M != 0 and all(subset(M, d) for d in data_masks)

    # pi(w) and w*
    pi = {}
    for w in range(nv):
        pi[w] = min(j for j, M in enumerate(theories) if M == (1 << w))
    wstar = max(range(nv), key=lambda w: pi[w])
    data = []                       # masks of sentences labelled true: not desc(v)
    kolmo_fail = 0
    bayes_err = 0
    used = set()
    final_index = None
    while True:
        comp = [j for j, M in enumerate(theories) if proves_all(M, data)]
        p = comp[0]
        if subset(theories[p], 1 << wstar):     # proves desc(w*): stable from now on
            final_index = p
            break
        open_v = [v for v in range(nv) if (theories[p] >> v) & 1 and v != wstar]
        assert open_v, "the current theory leaves only w* open, so it proves desc(w*)"
        v = rng.choice(open_v)
        assert v not in used
        used.add(v)
        datum = FULL & ~(1 << v)                # the sentence  not desc(v), true at w*
        # Kolmogorov predictor fails: p does not prove the datum
        assert not subset(theories[p], datum)
        kolmo_fail += 1
        # Bayes posterior-argmax over the trichotomy
        Z = sum(weights[j] for j in comp)
        bel = sum(weights[j] for j in comp if subset(theories[j], datum)) / Z
        dis = sum(weights[j] for j in comp if subset(theories[j], FULL & ~datum)) / Z
        ind = 1 - bel - dis
        if not (bel > dis and bel > ind):
            bayes_err += 1
        data.append(datum)
    cons = sum(wt for wt, M in zip(weights, theories) if M != 0)
    fin = sum(wt for wt, M in zip(weights, theories) if proves_all(M, data))
    bayes_bound = -math.log2(fin / cons)
    return dict(L=L, steps=kolmo_fail, target=nv - 1, before_final=final_index,
                bayes=bayes_err, bayes_bound=bayes_bound, true_at_wstar=all((d >> wstar) & 1 for d in data))


if __name__ == "__main__":
    out(f"seed {SEED}")
    out("Kolmogorov predictor against the adversary of Theorem 11.3 (data: 'not desc(v)' labelled true)")
    out(" L  order          list  K-fails  2^L-1  index of final theory (F15(b) bound)  Bayes mistakes  Bayes bound (bits)  data true at w*")
    for L in (2, 3, 4, 5):
        for order_mode in ("random", "decoys first"):
            for rep in range(3):
                n_random = 4 * (1 << L)
                r = run(L, n_random, order_mode)
                out(f"{L:2d}  {order_mode:13s} {n_random + (1 << L):5d}  {r['steps']:7d}  {r['target']:5d}  "
                    f"{r['before_final']:36d}  {r['bayes']:14d}  {r['bayes_bound']:18.3f}  {r['true_at_wstar']}")
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "c3_kolmogorov.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")

"""E9b (v2): ablation for Prop E9(b) -- the EInd/EInd2 pairs of the hard ZF set with the oracle's constant
propagation switched off (as in v1's oracle) vs on.  Same data as E9 'pairs' for that target pair.
usage: python3 experiments/e9b_nosimplify.py"""
import random
import itertools
from common import save, md_table, pp, TemplateRefuter
import dtrc.oracle_base as OB
from dtrc.mincover import aligned_min
from dtrc.datasets import HARD_ZF
from e9_separation import draw


def run(simplify_on, reps=12):
    orig = OB.simplify
    if not simplify_on:
        OB.simplify = lambda f, const_atom: f
    try:
        targets = HARD_ZF
        R = TemplateRefuter('ZF')
        rng = random.Random(1234)
        tested = refuted = 0
        for _ in range(reps):
            a = draw('EInd', targets, 'ZF', rng, 'EInd2')
            b = draw('EInd2', targets, 'ZF', rng, 'EInd')
            mins, _ = aligned_min([a, b])
            tested += 1
            refuted += int(all(R.refuted(T, [a, b]) for T in mins))
        return tested, refuted, R.oracle.calls
    finally:
        OB.simplify = orig


def main():
    rows = []
    for on in (False, True):
        t, r, c = run(on)
        rows.append(['on (v2)' if on else 'off (v1 oracle)', t, r, c])
    text = '# E9b: EInd/EInd2 merges with and without constant propagation\n\n'
    text += 'Command: `python3 experiments/e9b_nosimplify.py`; refuter budget 80; 12 random data pairs (seed 1234).\n\n'
    text += md_table(['constant propagation', 'pair merges', 'refuted', 'oracle calls'], rows)
    save('e9b_nosimplify', text)
    print(text)


if __name__ == '__main__':
    main()

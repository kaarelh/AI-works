"""Referee check R7: (a) E6 claims recomputed from the json; (b) held-out sentences that also occur in the training
data (leakage) in E1 and E2; (c) the E4(B, C) checkpoints (n at which the verifier is consulted).
Command: python3 r7_misc.py  (writes r7_misc.out)"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
EXP = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..', 'code', 'experiments'))
sys.path.insert(0, EXP)
import common  # noqa: E402,F401
L = []


def out(s):
    print(s, flush=True)
    L.append(s)


# (a) E6
J = json.load(open(os.path.join(EXP, '..', 'results', 'e6_equivalent.json')))
NS = [1, 2, 4, 8, 16, 32, 64, 128, 256]
for g in ['A_xy', 'M_x', 'S_ab']:
    rs = [r for r in J['results'] if r['gen'] == g]
    first = []
    for r in rs:
        f = None
        for i in range(len(NS)):
            if all(r['L1'][j].get(g, 0) >= 0.99 for j in range(i, len(NS))):
                f = NS[i]
                break
        first.append(f)
    sel8 = {k: round(sum(r['L1sel'][3].get(k, 0) for r in rs) / len(rs), 3) for k in ['A_xy', 'A_yx', 'S_ab', 'M_x', 'M_y']}
    spread = max(abs(r['L1sel'][i].get(k, 0) - rs[0]['L1sel'][i].get(k, 0)) for r in rs for i in range(3, len(NS))
                 for k in sel8)
    red = max(r['L1'][i].get(k, 0) for r in rs for i in range(len(NS)) for k in ['A_xy+A_yx', 'A_xy+S_ab'])
    out('E6 %s: first n with generator mass >= 0.99 from then on, per seed: %s; L1sel masses at n=8: %s; '
        'max spread of L1sel masses over seeds and n>=8: %.1e; max mass of redundant pairs under L1: %.1e'
        % (g, first, sel8, spread, red))

# (b) leakage
from bai.grammar import Grammar  # noqa: E402
from common import parse, Theory, Component, num, ZERO, S  # noqa: E402
from dtrc.templates import instantiate  # noqa: E402
import e1_universal as E1  # noqa: E402
Q = Grammar()
hits = 0
tot = 0
for phi, ps in E1.PHIS.items():
    P = parse(ps)
    held = [instantiate(P, {'t': t}) for t in E1.HELD]
    for g in E1.GENS:
        for s in E1.SEEDS:
            data = E1.make_data(P, g, 256, s, Q, E1.chains(Q))
            tot += 1
            if any(h in set(data) for h in held):
                hits += 1
out('E1: runs in which a held-out instance occurs in the 256 training data: %d of %d' % (hits, tot))
from pa_common import t_star, W_TRUE, pa_heldout  # noqa: E402
from bai.gens import cite_data  # noqa: E402
for s in range(5):
    data = cite_data(t_star(), W_TRUE, Q, 512, s)
    inst, false = pa_heldout(Q, s)
    first = [next((j + 1 for j, d in enumerate(data) if d == h), None) for h in inst]
    out('E2 seed %d: first training index of each held-out induction instance (None = absent): %s' % (s, first))

# (c) E4 checkpoints
ns = sorted(set(list(range(1, 65)) + list(range(64, 257, 8))))
out('E4(B, C): verifier consulted at %d of the 256 values of n (all n <= 64, then every 8th)' % len(ns))
with open(os.path.join(HERE, 'r7_misc.out'), 'w') as f:
    f.write('\n'.join(L) + '\n')

"""Referee check R10: notes section 1.8 says that among memorising theories covering D_n, Mem(D_n) has the largest
posterior "(any extra sentence costs prior bits and a Dirichlet factor)".  Under L1 a ground sentence such as
forall x phi derives other data, so adding it can raise the posterior.  Data: E1 'sch' streams (phi = x+0=x,
seeds 0-4), L1 chain with closed elim terms, K = 1 (the E1 likelihood).  Compares log2 posterior scores of
Mem(D_n) and Mem(D_n) + {forall x. x+0=x}.  Command: python3 r10_mem_not_max.py"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
EXP = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..', 'code', 'experiments'))
sys.path.insert(0, EXP)
import common  # noqa: E402,F401
from common import parse, Theory, Component  # noqa: E402
from bai.grammar import Grammar  # noqa: E402
from bai.lik import Chain  # noqa: E402
from bai.gens import cite_data  # noqa: E402
from bai.posterior import evaluate  # noqa: E402
from bai.pool import mem_theory  # noqa: E402

Q = Grammar()
ch = Chain(Q, Q, K=1, c_stop=0.5, qe_open=False)
P = parse('?t+0=?t')
A = parse('forall x. x+0=x')
lines = []
for seed in range(5):
    data = cite_data(Theory([Component(P)], 'g'), [1.0], Q, 256, seed)
    row = []
    for n in (16, 64, 256):
        mem = mem_theory(data[:n], 'MemFixed')
        memA = Theory([c for c in mem.comps] + [Component(A)], 'Mem+forall')
        res = evaluate([mem, memA], data[:n], [n], ch, Q=Q, alpha=0.5, with_mem=False, max_states=10 ** 6)[0]
        d = (res['Mem+forall']['lp'] + res['Mem+forall']['lm'] - res['MemFixed']['lp'] - res['MemFixed']['lm']) / math.log(2)
        b = 'bounded' if any('lm_hi' in res[k] for k in res) else 'exact'
        row.append('n=%d: %+.1f bits (%s)' % (n, d, b))
    lines.append('seed %d: log2 score(Mem + {Ax x+0=x}) - log2 score(Mem): %s' % (seed, '; '.join(row)))
print('\n'.join(lines))
with open(os.path.join(HERE, 'r10_mem_not_max.out'), 'w') as f:
    f.write('\n'.join(lines) + '\n')

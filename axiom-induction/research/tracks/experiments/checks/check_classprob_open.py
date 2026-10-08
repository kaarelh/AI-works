"""Check for E6 (added in the revision): the L1sel class probabilities c_i (bai.lik.class_prob_qf) of the E6
theories, including the open-guard variants added after the referee, against Monte Carlo of the chain
(K = 2, c_stop = 1/2, closed elim terms); 40000 chains per theory, seed 5.
Command: python3 check_classprob_open.py   (writes check_classprob_open.out)"""
import math
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', '..', 'code', 'experiments'))
import e6_equivalent as E  # noqa: E402
from bai.grammar import Grammar  # noqa: E402
from bai.lik import Chain, class_prob_qf, quantifier_free  # noqa: E402
from bai.theory import has_param  # noqa: E402

Q = Grammar()
ch = Chain(Q, Q, K=2, c_stop=0.5, qe_open=False)
rng = random.Random(5)
lines = []
worst = 0.0
for th in E.theories():
    if len(th.comps) > 1:
        continue
    N = 40000
    k = sum(1 for _ in range(N) if (lambda d: quantifier_free(d) and not has_param(d))(ch.sample(th.comps, [1.0], rng)))
    p = class_prob_qf(th.comps[0], ch)
    se = math.sqrt(max(p * (1 - p), 1e-12) / N)
    z = (k / N - p) / se if p < 1 else 0.0
    worst = max(worst, abs(z))
    lines.append('%-10s exact c = %.4f  Monte Carlo %.4f  z = %+.2f' % (th.name, p, k / N, z))
lines.append('largest |z| = %.2f' % worst)
print('\n'.join(lines))
with open(os.path.join(HERE, 'check_classprob_open.out'), 'w') as f:
    f.write('\n'.join(lines) + '\n')

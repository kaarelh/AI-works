"""Check for E4(A): on every seeded stream the full pipeline (evaluate + Deriver + threshold) wins exactly when
the first t* data are phi(0) (the closed-form event).  Command: python3 check_e4_tight.py"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', '..', 'code', 'experiments'))
import e4_ville as E  # noqa: E402
from bai.grammar import Grammar  # noqa: E402
from bai.gens import cite_data  # noqa: E402
from bai.posterior import evaluate, Deriver, support_mass  # noqa: E402
from common import Theory, Component  # noqa: E402
from dtrc.templates import instantiate  # noqa: E402
from dtrc.syntax import ZERO  # noqa: E402

for (u, w, dp) in [(0.5, 0.01, 0.01), (0.2, 0.05, 0.2)]:
    tstar, ex = E.tight_exact(u, w, dp)
    Qu = Grammar(term_w={'0': 1 - u, 'S': u})
    Ts = Theory([Component(E.P)], 'T*', {'log_prior': math.log(w)})
    Tp = Theory([instantiate(E.P, {'t': ZERO}), E.BAD], "T'", {'log_prior': math.log(1 - w)})
    der = Deriver(K=1, Q=Qu)
    agree = wins = closed = 0
    for tr in range(400):
        data = cite_data(Ts, [1.0], Qu, tstar + 5, tr)
        res = evaluate([Ts, Tp], data, list(range(1, tstar + 6)), 'L0', Q=Qu, alpha=0.5, with_mem=False)
        win = any(support_mass(r, [Ts, Tp], der, E.BAD) >= 1 - w * dp for r in res)
        ev = all(d == instantiate(E.P, {'t': ZERO}) for d in data[:tstar])
        wins += win
        closed += ev
        agree += (win == ev)
    print('u=%s w*=%s delta\'=%s t*=%d: pipeline wins %d, closed-form event %d, agreement %d/400, exact %.5f'
          % (u, w, dp, tstar, wins, closed, agree, ex))

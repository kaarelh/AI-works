"""Referee check R8: the E1 results file reports the 'inexact' counters of the likelihood chains only.  The
derivability oracle (posterior.Deriver, its own Chain with K = 1 and open elim terms) also drops predecessors when a
term has more than max_occ occurrences (TooManyOccurrences -> inexact += 1), which can turn 'derives' into a false
'does not derive'.  This script re-runs every E1 job with Deriver instances recorded and reports their counters.
Command: python3 r8_deriver_inexact.py  (writes r8_deriver_inexact.out)"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
EXP = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..', 'code', 'experiments'))
sys.path.insert(0, EXP)
import common  # noqa: E402,F401
import bai.posterior as BP  # noqa: E402
import e1_universal as E1  # noqa: E402

_Orig = BP.Deriver


class RecDeriver(_Orig):
    made = []

    def __init__(self, *a, **k):
        super().__init__(*a, **k)
        RecDeriver.made.append(self)


def job(args):
    RecDeriver.made.clear()
    E1.Deriver = RecDeriver
    E1.run(args)
    return args, sum(d.chain.inexact for d in RecDeriver.made), sum(len(d._memo) for d in RecDeriver.made)


if __name__ == '__main__':
    from multiprocessing import Pool
    jobs = [(p, g, s) for p in E1.PHIS for g in E1.GENS for s in E1.SEEDS]
    with Pool(4) as pl:
        res = pl.map(job, jobs, chunksize=1)
    bad = [(a, c) for a, c, m in res if c]
    lines = ['E1 jobs: %d; derivability queries memoised: %d; jobs with Deriver inexact > 0: %d %s' % (
        len(res), sum(m for _, _, m in res), len(bad), bad[:10])]
    print('\n'.join(lines))
    with open(os.path.join(HERE, 'r8_deriver_inexact.out'), 'w') as f:
        f.write('\n'.join(lines) + '\n')

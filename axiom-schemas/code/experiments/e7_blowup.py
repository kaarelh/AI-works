"""E7: size of Min(D) for pairs of data, in the full class DT° (term metavariables of any arity) vs the
class DT°_F (term metavariables 0-ary).  All pairs of PA-mix(0) and ZF-mix(0) data; a computation is cut off
after 2 seconds (SIGALRM) and counted as a timeout.
"""
import itertools
import signal
import time
from collections import Counter
from common import save, md_table, pp
from dtrc.datasets import pa_mix, zf_mix
from dtrc.mincover import MinCover


class _TO(Exception):
    pass


def _h(s, f):
    raise _TO


def main():
    signal.signal(signal.SIGALRM, _h)
    t0 = time.time()
    rows = []
    worst = {}
    for mix in ('PA', 'ZF'):
        data = pa_mix(0) if mix == 'PA' else zf_mix(0)
        sents = list(dict.fromkeys(s for s, _ in data))
        for cls, ta0 in (('DT°', False), ('DT°_F', True)):
            hist = Counter()
            tos = 0
            tot_time = 0.0
            maxmin = 0
            for a, b in itertools.combinations(sents, 2):
                signal.setitimer(signal.ITIMER_REAL, 2.0)
                t = time.time()
                try:
                    mins = MinCover([a, b], term_arity0=ta0).minimal()
                    signal.setitimer(signal.ITIMER_REAL, 0)
                    n = len(mins)
                    hist['1' if n == 1 else '2-4' if n <= 4 else '5-16' if n <= 16 else '>16'] += 1
                    if n > maxmin:
                        maxmin = n
                        worst[(mix, cls)] = (pp(a), pp(b), n)
                except _TO:
                    tos += 1
                tot_time += time.time() - t
            npairs = len(sents) * (len(sents) - 1) // 2
            rows.append([mix, cls, npairs, hist['1'], hist['2-4'], hist['5-16'], hist['>16'], tos, maxmin,
                         '%.1f' % tot_time])
    text = '# E7: size of Min(D) for pairs, DT° vs DT°_F\n\nCommand: `python3 experiments/e7_blowup.py`.\n\n'
    text += md_table(['mix', 'class', 'pairs', '|Min|=1', '2-4', '5-16', '>16', 'timeouts (>2s)', 'max |Min|',
                      'total time (s)'], rows)
    text += '\nLargest computed Min per (mix, class):\n\n'
    for k, (a, b, n) in worst.items():
        text += '* %s %s: |Min| = %d for\n    * `%s`\n    * `%s`\n' % (k[0], k[1], n, a, b)
    text += '\nWall time: %.1fs\n' % (time.time() - t0)
    save('e7_blowup', text)
    print(text)


if __name__ == '__main__':
    main()

"""rb6_c2_vacuity.py -- referee B, thread `sfi`.  How informative is the developer's density-lemma
check (checks/c2_independent_label.py, part "one-tape density lemma")?

The script reads c2's source, instruments it IN MEMORY (the file on disk is not changed), and runs
it with c2's own seed, counting, for the check (e2) "sigma outside J_w has consistent iota-mass
<= eps in [w]":
  * the dense prefixes by length (a dense prefix of full length L is a single consistent tape, on
    which every iota-labelled sentence is in J_w automatically);
  * the number of (w, sigma) pairs with sigma outside J_w and POSITIVE consistent iota-mass in [w]
    (only these can violate (e2)); if it is 0 the check is vacuous.
Deterministic (c2's seed).  Output: rb6_c2_vacuity.out
"""
import os
import re
import collections

HERE = os.path.dirname(os.path.abspath(__file__))
C2 = os.path.join(HERE, '..', 'checks', 'c2_independent_label.py')
out_lines = []


def out(s=''):
    out_lines.append(s)
    print(s)


def main():
    src = open(C2).read()
    # instrument: count dense-prefix lengths and non-vacuous (w, sigma) pairs
    anchor = "                nw += 1\n"
    assert anchor in src
    src = src.replace(anchor, anchor + "                STATS['len'][len(w)] += 1\n")
    anchor2 = """                        cm = sum(1 for om in ext if C[om] and labs[om].get(i) == 'iota') / len(ext)
"""
    assert anchor2 in src
    src = src.replace(anchor2, anchor2 + """                        if cm > 0:
                            STATS['nonvacuous'] += 1
                            STATS['max_ratio'] = max(STATS['max_ratio'], cm / eps)
                        STATS['pairs'] += 1
""")
    # do not overwrite c2's saved output
    src = src.replace("with open(__file__.replace('.py', '.out'), 'w') as fh:", "with open(os.devnull, 'w') as fh:")
    src = "import os\n" + src
    g = {'__name__': 'c2_instrumented', '__file__': C2,
         'STATS': {'len': collections.Counter(), 'nonvacuous': 0, 'pairs': 0, 'max_ratio': 0.0}}
    import io
    import contextlib
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        exec(compile(src, 'c2_instrumented', 'exec'), g)
        g['main']()
    st = g['STATS']
    out('rb6_c2_vacuity.py: developer c2 re-run in memory with instrumentation (seed of c2)')
    out('c2 printed line reproduced: %s' % [l for l in buf.getvalue().splitlines() if 'dense prefixes' in l][0].strip())
    out('dense prefixes by length (L = 8): %s' % dict(sorted(st['len'].items())))
    out('(w, sigma) pairs tested by (e2): %d; pairs with sigma outside J_w and positive consistent iota-mass in [w]: %d; '
        'largest (consistent iota-mass)/eps among them: %.4f' % (st['pairs'], st['nonvacuous'], st['max_ratio']))
    with open(os.path.join(HERE, 'rb6_c2_vacuity.out'), 'w') as fh:
        fh.write('\n'.join(out_lines) + '\n')


if __name__ == '__main__':
    main()

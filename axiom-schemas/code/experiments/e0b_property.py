"""E0b (v2, referee F2 and F8d): property-based checks of Min(D) beyond E0's arithmetic-only cross-validation:
both languages, '<', 'in', '<->', and templates with a rigid parameter c.

Random generating templates T* and data D subset inst(T*) come from the referee's generator
(recheck/r5_mincover.py, written by the referee of this track; imported unchanged).  For each data set:
  (a) every computed minimal template covers D, is DT°_F (0-ary term metavariables), and the minima are
      pairwise incomparable;
  (b) Prop E1(c): some computed minimum is <= T*;
  (c) random specialisation walks from T* (<= 8 steps, each step a covering one-step specialisation): every
      covering template reached is >= some computed minimum (Prop E1(b)) and none is strictly below one
      (minimality).
Two Min procedures: Min_lit (MinCover, parameter names compared literally) and Min^al (aligned_min, all
per-datum parameter alignments).  Prop E1-lit predicts 0 failures of (b) for parameter-free T* and possible
failures with a rigid parameter; Prop E1-al predicts 0 failures in all cases.

usage: python3 experiments/e0b_property.py [N_PER_CELL]
"""
import os
import sys
import random
import time
import itertools

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..'))
sys.path.insert(0, os.path.join(HERE, 'recheck'))
import r5_mincover as R5                                                  # noqa: E402  (referee's generator)
from dtrc.syntax import pp, canon_params, params_of, shift                # noqa: E402
from dtrc.templates import instantiate, geq, is_DT0, covers_all, metas    # noqa: E402
from dtrc.mincover import MinCover, aligned_min                           # noqa: E402
from common import save, md_table                                         # noqa: E402


def gen_data(rng, lang, with_param):
    """(T*, D) or None.  with_param: T* must contain the rigid parameter c (ZF) / a (PA)"""
    if not with_param:
        R5.rvar_zf = lambda rng_, nb: ('v', rng_.randrange(nb)) if nb else ('v', 0)
    else:
        R5.rvar_zf = lambda rng_, nb: ('v', rng_.randrange(nb)) if (nb and rng_.random() < 0.75) else ('p', 'c')
    metas_ = {}
    nb0 = 1 if (lang == 'ZF' and not with_param) else 0
    T = R5.gen_template(rng, lang, rng.randint(2, 4), nb0, metas_, [3])
    if lang == 'ZF' and not with_param:
        T = ('all', T)
    if lang == 'PA' and with_param:
        # put a rigid parameter into a random atom: replace the first 0 by the parameter a
        s = repr(T)
        if "('0',)" not in s:
            return None
        T = eval(s.replace("('0',)", "('p', 'a')", 1))
    if not metas(T) or not is_DT0(T):
        return None
    if bool(params_of(T)) != with_param:
        return None
    ms = metas(T)
    wraps = {m: rng.choice([None, 'not', 'and', 'imp', 'all']) for m in ms}
    shared = {m: R5.rbody(rng, lang, 'F' if m[0].isupper() else 'T', a) for m, a in ms.items()}
    D = []
    for _ in range(rng.randint(2, 3)):
        th = {}
        for m, a in ms.items():
            srt = 'F' if m[0].isupper() else 'T'
            b = R5.rbody(rng, lang, srt, a)
            w = wraps[m]
            if srt == 'F' and w == 'not':
                b = ('not', b)
            elif srt == 'F' and w in ('and', 'imp'):
                b = (w, shared[m], b)
            elif srt == 'F' and w == 'all':
                b = ('all', shift(b, 1))
            th[m] = b
        D.append(canon_params(instantiate(T, th)))
    D = list(dict.fromkeys(D))
    if len(D) < 2 or not covers_all(T, D):
        return None
    return T, D


def check(T, D, mins, rng, lang, st):
    for M in mins:
        if not (covers_all(M, D) and is_DT0(M) and all(a == 0 for m, a in metas(M).items() if m[0].islower())):
            st['a_fail'] += 1
    for M1, M2 in itertools.combinations(mins, 2):
        if geq(M1, M2) or geq(M2, M1):
            st['a_fail'] += 1
    if not any(geq(T, M) for M in mins):
        st['b_fail'] += 1
        if len(st['ex']) < 2:
            st['ex'].append((pp(T), [pp(d) for d in D], [pp(M) for M in mins]))
    cur = T
    for step in range(8):
        nxt = [Tp for Tp in R5.specialisations(cur, D, rng, lang)
               if is_DT0(Tp) and covers_all(Tp, D) and not any(a > 0 for m, a in metas(Tp).items() if m[0].islower())]
        if not nxt:
            break
        cur = rng.choice(nxt)
        st['walk'] += 1
        if not any(geq(cur, M) for M in mins):
            st['c_fail'] += 1
            break
        for M in mins:
            if geq(M, cur) and not geq(cur, M):
                st['below'] += 1


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 200
    t0 = time.time()
    rows = []
    exs = []
    for lang in ('PA', 'ZF'):
        for with_param in (False, True):
            for proc in ('Min_lit', 'Min^al'):
                rng = random.Random(1000 * (lang == 'ZF') + 10 * with_param + 7)
                st = dict(sets=0, mins=0, a_fail=0, b_fail=0, c_fail=0, below=0, walk=0, skipped=0, ex=[],
                          differs=0)
                while st['sets'] < n:
                    g = gen_data(rng, lang, with_param)
                    if g is None:
                        st['skipped'] += 1
                        continue
                    T, D = g
                    if proc == 'Min_lit':
                        mins = MinCover(D).minimal()
                    else:
                        mins, mc = aligned_min(D)
                        st['differs'] += int(bool(mc.differs))
                    st['sets'] += 1
                    st['mins'] += len(mins)
                    check(T, D, mins, random.Random(st['sets']), lang, st)
                rows.append([lang, 'yes' if with_param else 'no', proc, st['sets'], st['mins'], st['a_fail'],
                             st['b_fail'], st['walk'], st['c_fail'], st['below'],
                             st['differs'] if proc == 'Min^al' else '-'])
                for e in st['ex']:
                    exs.append((lang, with_param, proc, e))
    text = '# E0b: property-based checks of Min (both languages, rigid parameters)\n\n'
    text += ('Command: `python3 experiments/e0b_property.py %d`. Generator: the referee\'s (recheck/r5_mincover.py). '
             '(a) = minima cover D, are DT°_F, pairwise incomparable; (b) = Prop E1(c), some minimum <= T*; '
             '(c) = specialisation walks from T*: reached covering templates not >= any minimum (E1(b) failures) '
             'and strictly below a minimum (minimality failures).\n\n' % n)
    text += md_table(['language', 'T* has a rigid parameter', 'Min', 'data sets', 'minima', '(a) failures',
                      '(b) failures', 'walk templates', '(c) not above a min', '(c) below a min',
                      'Min^al differs from Min_lit'], rows)
    if exs:
        text += '\nExamples of (b) failures:\n\n'
        for (lang, wp, proc, e) in exs[:4]:
            text += '* %s, %s: T* = `%s`; D = `%s`; computed Min = `%s`\n' % (lang, proc, e[0], ' ; '.join(e[1]),
                                                                             ' ; '.join(e[2]))
    text += '\nWall time: %.1fs\n' % (time.time() - t0)
    save('e0b_property', text)
    print(text)


if __name__ == '__main__':
    main()

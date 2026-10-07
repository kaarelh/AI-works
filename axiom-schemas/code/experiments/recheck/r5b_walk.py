"""R5b: E1(b) completeness check by random specialisation walks from the generating template T* (no rigid
parameters): every covering template reached must be >= some computed minimal template; and a reached
covering template strictly below a computed min would refute minimality."""
import sys, random, time
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
import r5_mincover as R5
from dtrc.syntax import pp, canon_params, params_of
from dtrc.templates import instantiate, geq, is_DT0, covers_all, metas
from dtrc.mincover import MinCover

def rvar_noparam(rng, nb):
    return ('v', rng.randrange(nb)) if nb else ('v', 0)
R5.rvar_zf = rvar_noparam

def run(lang, n, seed):
    rng = random.Random(seed)
    st = dict(sets=0, walk_templates=0, e1b_fail=0, below_min=0, skipped=0)
    ex = []
    t0 = time.time()
    while st['sets'] < n:
        metas_ = {}
        T = R5.gen_template(rng, lang, rng.randint(2, 4), 1 if lang == 'ZF' else 0, metas_, [3])
        if lang == 'ZF': T = ('all', T)
        if not metas(T) or not is_DT0(T) or params_of(T):
            st['skipped'] += 1; continue
        ms = metas(T)
        wraps = {m: rng.choice([None, 'not', 'and', 'imp', 'all']) for m in ms}
        shared = {m: R5.rbody(rng, lang, 'F' if m[0].isupper() else 'T', a) for m, a in ms.items()}
        D = []
        for _ in range(rng.randint(2, 3)):
            th = {}
            for m, a in ms.items():
                srt = 'F' if m[0].isupper() else 'T'
                b = R5.rbody(rng, lang, srt, a); w = wraps[m]
                if srt == 'F' and w == 'not': b = ('not', b)
                elif srt == 'F' and w in ('and', 'imp'): b = (w, shared[m], b)
                elif srt == 'F' and w == 'all': b = ('all', R5.shift(b, 1))
                th[m] = b
            D.append(canon_params(instantiate(T, th)))
        D = list(dict.fromkeys(D))
        if len(D) < 2 or not covers_all(T, D):
            st['skipped'] += 1; continue
        mins = MinCover(D).minimal()
        st['sets'] += 1
        cur = T
        for step in range(8):
            nxt = [Tp for Tp in R5.specialisations(cur, D, rng, lang)
                   if is_DT0(Tp) and covers_all(Tp, D) and not any(a > 0 for m, a in metas(Tp).items() if m[0].islower())]
            if not nxt: break
            cur = rng.choice(nxt)
            st['walk_templates'] += 1
            if not any(geq(cur, M) for M in mins):
                st['e1b_fail'] += 1
                if len(ex) < 4: ex.append(('E1b', pp(cur), [pp(M) for M in mins], [pp(d) for d in D]))
                break
            for M in mins:
                if geq(M, cur) and not geq(cur, M):
                    st['below_min'] += 1
                    if len(ex) < 8: ex.append(('below a min', pp(cur), pp(M)))
    print(lang, st, '%.0fs' % (time.time() - t0))
    for e in ex: print('  ', e)

run(sys.argv[1], int(sys.argv[2]), int(sys.argv[3]))

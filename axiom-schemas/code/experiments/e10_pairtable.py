"""E10 (v2): computed check of the case table in the proof of Prop E8 (pairwise refutation separation for the
PA-mix and ZF-mix targets, ideal refuter).

For every pair of targets (T_i, T_j) and REPS random pairs a in inst(T_i) minus inst(T_j), b in inst(T_j) minus
inst(T_i), compute Min^al({a,b}) and check that
  (1) it has exactly the shape the proof predicts for the pair's case:
        A  root clash                         Min = {?P}
        B  clash under a common forall-prefix Min = {Ax..?P(..)}         (one slot, under k = 1 or 2 binders)
        C  comprehension clash (ZF)           Min = {Ax.Ey.Az.(z in y <-> ?P(z,x))}
        D  Found / Rep                        Min = {Ax.(?A(x) -> Ey.?B(y,x))}
        E  two ?t-instance schemas (PA)       every member has the form ?f = ?g, ?f = 0, or ?f+?g = R with ?f, ?g
                                              occurring nowhere else (U_add0 / U_0add);
  (2) the explicit false instance named in the proof (bot; Ax.bot; Russell; top -> Ey.bot; S(r)+0=r resp. 1=0)
      is certified false by the world oracle.
usage: python3 experiments/e10_pairtable.py [REPS]
"""
import sys
import random
import time
import itertools
from collections import Counter
from common import save, md_table, pp, Oracle
from dtrc.syntax import parse, canon_params, ZERO, S, EQ, NOT, ALL, IN, H
from dtrc.templates import match, canon, metas, instantiate, equiv, meta_occurrences
from dtrc.mincover import aligned_min
from dtrc.schemas import pa_targets, zf_targets
from dtrc.datasets import schema_instance

BOT = {'PA': EQ(S(ZERO), ZERO), 'ZF': NOT(ALL(EQ(('v', 0), ('v', 0))))}
TOP = {'PA': EQ(ZERO, ZERO), 'ZF': ALL(EQ(('v', 0), ('v', 0)))}


def case_of(lang, a, b):
    ka, kb = a, b
    if lang == 'PA':
        roots = {'Ind': 'imp', 'U_add0': '=', 'U_mul0': '=', 'U_0add': '='}
        ra, rb = roots.get(ka, 'all'), roots.get(kb, 'all')
        if ra != rb:
            return 'A'
        if ra == 'all':
            return 'B'
        return 'E'
    if 'Inf' in (ka, kb) or 'EInd' in (ka, kb):
        return 'A'
    if {ka, kb} <= {'Union', 'Power', 'Sep'}:
        return 'C'
    if {ka, kb} == {'Found', 'Rep'}:
        return 'D'
    return 'B'


def false_instance(case, lang, T):
    """the proof's explicit false instance of template T"""
    ms = metas(T)
    th = {}
    if case in ('A', 'B'):
        for m in ms:
            th[m] = BOT[lang]
    elif case == 'C':
        for m in ms:                       # ?P(z,x) := ~z in z  (Russell); hole 0 = z
            th[m] = NOT(IN(H(0), H(0)))
    elif case == 'D':
        occ = sorted(meta_occurrences(T), key=lambda o: o[3])
        first = occ[0][0]                  # ?A (antecedent) := top, ?B := bot
        for m in ms:
            th[m] = TOP[lang] if m == first else BOT[lang]
    else:
        # E: ?f = ?g -> 1 = 0; ?f = 0 -> 1 = 0; ?f + ?g = R -> S(r) + 0 = r with R's metavariables := 0
        if T[0] == '=' and T[1][0] == '+' and T[1][1][0] == 'M' and T[1][2][0] == 'M':
            f, g = T[1][1][1], T[1][2][1]
            rest = {m for m in ms if m not in (f, g)}
            r = instantiate(T[2], {m: ZERO for m in rest})
            th = {m: ZERO for m in rest}
            th[f] = S(r)
            th[g] = ZERO
        else:
            for m in ms:
                th[m] = S(ZERO) if T[1][0] == 'M' and T[1][1] == m else ZERO
    return instantiate(T, th)


def shape_ok(case, T, lang):
    s = pp(T)
    if case == 'A':
        return s == '?P0'
    if case == 'B':
        return s in ('Ax.?P0(x)', 'Ax.Ay.?P0(y,x)', 'Ax.Ay.?P0(x,y)')
    if case == 'C':
        return s == 'Ax.Ey.Az.z in y <-> ?P0(z,x)'
    if case == 'D':
        return s == 'Ax.?P0(x) -> (Ey.?P1(y,x))'
    # E
    if T[0] != '=':
        return False
    occ = Counter(o[0] for o in meta_occurrences(T))
    L = T[1]
    if L[0] == 'M':                                  # ?f = ?g  or  ?f = 0
        return occ[L[1]] == 1 and (T[2] == ZERO or (T[2][0] == 'M' and occ[T[2][1]] == 1))
    if L[0] == '+' and L[1][0] == 'M' and L[2][0] == 'M':
        return occ[L[1][1]] == 1 and occ[L[2][1]] == 1 and L[1][1] != L[2][1]
    return False


def main():
    reps = int(sys.argv[1]) if len(sys.argv) > 1 else 30
    t0 = time.time()
    rows = []
    bad = []
    for lang, targets in (('PA', pa_targets()), ('ZF', zf_targets())):
        oracle = Oracle(lang)
        rng = random.Random(77 if lang == 'PA' else 78)
        stats = {}
        for a, b in itertools.combinations(list(targets), 2):
            case = case_of(lang, a, b)
            st = stats.setdefault(case, Counter())
            st['pairs'] += 1
            for _ in range(reps):
                da = db = None
                for _ in range(50):
                    x = schema_instance(targets[a], lang, rng)
                    if match(targets[b], x) is None:
                        da = x
                        break
                for _ in range(50):
                    x = schema_instance(targets[b], lang, rng)
                    if match(targets[a], x) is None:
                        db = x
                        break
                if da is None or db is None:
                    st['skipped'] += 1
                    continue
                mins, _ = aligned_min([da, db])
                st['data sets'] += 1
                st['minima'] += len(mins)
                for T in mins:
                    ok = shape_ok(case, T, lang)
                    q = false_instance(case, lang, T)
                    ref = oracle.refutes(q)
                    st['shape ok'] += int(ok)
                    st['false instance refuted'] += int(ref)
                    if (not ok or not ref) and len(bad) < 10:
                        bad.append((lang, a, b, case, pp(T), pp(q), ok, ref))
        for case in sorted(stats):
            st = stats[case]
            rows.append([lang, case, st['pairs'], st['data sets'], st['minima'], st['shape ok'],
                         st['false instance refuted'], st['skipped']])
    text = '# E10: case table of Prop E8 (pairwise separation of the mix targets), computed check\n\n'
    text += 'Command: `python3 experiments/e10_pairtable.py %d` (%d random data pairs per target pair).\n\n' % (reps, reps)
    text += md_table(['language', 'case', 'target pairs', 'data pairs', 'minimal templates', 'predicted shape',
                      'explicit false instance refuted', 'skipped'], rows)
    text += '\nMismatches: %s\n' % (bad if bad else 'none')
    text += '\nWall time: %.1fs\n' % (time.time() - t0)
    save('e10_pairtable', text)
    print(text)


if __name__ == '__main__':
    main()

# Exhaustive statistics: for all pairs of quantifier-free formulas phi1 != phi2 (free variables within {x})
# up to a size bound, is lgg(Ind phi1, Ind phi2) unsound (false sentence instance found, exactly verified)?
import sys, itertools, time
from collections import Counter
from raw_common import *
from raw_search import find_false, pretty, rename_pretty

SMAX = int(sys.argv[1]) if len(sys.argv) > 1 else 5
CAP = int(sys.argv[2]) if len(sys.argv) > 2 else 4000

terms = {1: [Z, X]}
for n in range(2, SMAX):
    out = [S(t) for t in terms[n - 1]]
    for a in range(1, n - 1):
        b = n - 1 - a
        for s in terms.get(a, []):
            for t in terms.get(b, []):
                out += [add(s, t), mul(s, t)]
    terms[n] = out
forms = {}
for n in range(3, SMAX + 1):
    out = []
    for a in range(1, n - 1):
        b = n - 1 - a
        for s in terms.get(a, []):
            for t in terms.get(b, []): out.append(eq(s, t))
    out += [NOT(f) for f in forms.get(n - 1, [])]
    for a in range(3, n - 1):
        b = n - 1 - a
        for f in forms.get(a, []):
            for h in forms.get(b, []):
                out += [AND(f, h), OR(f, h), IMP(f, h)]
    forms[n] = out
allf = [(n, f) for n in forms for f in forms[n]]
print('formulas of size <= %d: %d (with x free: %d)' % (SMAX, len(allf), sum(1 for _, f in allf if X in free_vars(f))))

t0 = time.time()
res = Counter(); minsize = {}; sound_examples = []
genuine = lambda f: truth(ALL(X, f))          # Ind(f) has a true conclusion (and a true premise)
for (n1, f1), (n2, f2) in itertools.combinations(allf, 2):
    if X not in free_vars(f1) and X not in free_vars(f2):
        cls = 'both x-free'
    else:
        cls = 'x free in one' if (X not in free_vars(f1) or X not in free_vars(f2)) else 'x free in both'
    L = lgg_list([Ind(f1), Ind(f2)])
    r = find_false(L, cap=CAP)
    key = (cls, 'unsound' if r else 'no false instance found')
    res[key] += 1
    if r:
        tot = n1 + n2
        gen = genuine(f1) and genuine(f2)
        k2 = (cls, gen)
        if k2 not in minsize or tot < minsize[k2][0]:
            minsize[k2] = (tot, pretty(f1), pretty(f2), pretty(r[0]))
    elif cls == 'x free in both' and len(sound_examples) < 12:
        sound_examples.append((pretty(f1), pretty(f2), rename_pretty(L)))
print('time %.1fs' % (time.time() - t0))
for k in sorted(res): print('  ', k, res[k])
print('smallest unsound pairs (total |phi1|+|phi2|), by class and "both motives true for all x":')
for k in sorted(minsize, key=str): print('  ', k, minsize[k])
print('examples with x free in both and no false instance found:')
for e in sound_examples: print('  ', e)

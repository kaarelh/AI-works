"""Referee: alignment-complete Min(D): minimal elements over all injective per-datum parameter renamings."""
import sys, itertools
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
from dtrc.syntax import params_of, rename_params
from dtrc.templates import geq, canon
from dtrc.mincover import MinCover

def aligned_min(D, max_align=400, **kw):
    D = list(dict.fromkeys(D))
    ps = [params_of(d) for d in D]
    m = sum(len(p) for p in ps)
    names = ['w%d' % i for i in range(m)]
    choices = []
    for i, p in enumerate(ps):
        if i == 0:
            choices.append([dict(zip(p, names[:len(p)]))])
        else:
            choices.append([dict(zip(p, perm)) for perm in itertools.permutations(names, len(p))])
    cands = []
    seen = set()
    n = 0
    for combo in itertools.product(*choices):
        n += 1
        if n > max_align:
            return None
        Da = []
        for d, ren in zip(D, combo):
            tmp = rename_params(d, {k: '__t' + k for k in ren})
            Da.append(rename_params(tmp, {'__t' + k: v for k, v in ren.items()}))
        for M in MinCover(Da, **kw).minimal():
            c = canon(M)
            if c not in seen:
                seen.add(c); cands.append(c)
    mins = []
    for T in sorted(cands, key=lambda T: -len(repr(T))):
        if any(geq(T, M) for M in mins):
            continue
        mins = [M for M in mins if not geq(M, T)]
        mins.append(T)
    return mins

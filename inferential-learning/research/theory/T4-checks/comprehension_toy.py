"""Frege -> Russell -> Zermelo toy (Section 5 of T4).

Part A: finite-model sanity checks of the consistency / inconsistency facts used in the text.
  (Finite models only certify consistency; inconsistency facts are proved by hand in the text --
   here we only confirm that no small model exists, as a sanity check.)
Part B: the learning dynamics: unconstrained MDL, coherence pruning, coverage-maximizing repair.
"""
import itertools

# ---------------------------------------------------------------- menu of comprehension formulas
# phi(x, a, b, E) where E is the membership relation (set of pairs (u, v) meaning u in v)
MENU = {
    'V':    lambda x, a, b, E: True,                                   # x = x
    'EMP':  lambda x, a, b, E: False,                                  # x != x
    'S':    lambda x, a, b, E: (x, x) in E,                            # x in x
    'R':    lambda x, a, b, E: (x, x) not in E,                        # not x in x   (Russell)
    'INT':  lambda x, a, b, E: (x, a) in E and (x, b) in E,            # x in a and x in b
    'UNI':  lambda x, a, b, E: (x, a) in E or (x, b) in E,             # x in a or x in b
    'PAIR': lambda x, a, b, E: x == a or x == b,                       # x = a or x = b
    'DIFF': lambda x, a, b, E: (x, a) in E and (x, b) not in E,        # x in a and not x in b
    'CMP':  lambda x, a, b, E: (x, a) not in E,                        # not x in a
    'ZR':   lambda x, a, b, E: (x, a) in E and (x, x) not in E,        # x in a and not x in x (Zermelo 1908)
}
# syntactic classes (computed by hand from the definitions; see text)
POSITIVE = {'V', 'S', 'INT', 'UNI', 'PAIR'}                            # no negation
STRATIFIED = {'V', 'EMP', 'INT', 'UNI', 'PAIR', 'DIFF', 'CMP'}         # x in x is unstratifiable
SEPFORM = {'INT', 'DIFF', 'ZR'}                                        # of the form x in a and psi
HYP = {
    'NC':    set(MENU),                      # naive comprehension
    'POS':   POSITIVE,                       # positive comprehension
    'STRAT': STRATIFIED,                     # stratified comprehension (NF-like)
    'SEP':   SEPFORM,                        # separation only
    'Z':     SEPFORM | {'EMP', 'PAIR', 'UNI'},  # Zermelo-like: separation + elementary sets + union
}
# description lengths (illustrative; only the ORDER matters for the theorem):
ELL = {'NC': 1, 'POS': 3, 'SEP': 4, 'STRAT': 5, 'Z': 4 + 2 + 3 + 3}


def holds(name, D, E):
    phi = MENU[name]
    exts = {y: frozenset(x for x in D if (x, y) in E) for y in D}
    available = set(exts.values())
    for a in D:
        for b in D:
            ext = frozenset(x for x in D if phi(x, a, b, E))
            if ext not in available:
                return False
    return True


def find_model(names, maxn=3):
    for n in range(1, maxn + 1):
        D = list(range(n))
        pairs = [(u, v) for u in D for v in D]
        for bits in range(1 << len(pairs)):
            E = {pairs[i] for i in range(len(pairs)) if (bits >> i) & 1}
            if all(holds(nm, D, E) for nm in names):
                return n, E
    return None


def partA():
    print("Part A: finite-model sanity checks (domain size <= 3)")
    print("  POS menu instances have the 1-element model u in u:",
          all(holds(nm, [0], {(0, 0)}) for nm in POSITIVE))
    for bad in [['R'], ['V', 'ZR'], ['CMP', 'S'], ['V', 'DIFF', 'S'], ['EMP', 'CMP', 'ZR'],
                ['DIFF', 'CMP', 'ZR'], ['INT', 'CMP', 'ZR']]:
        print(f"  claimed inconsistent {bad}: small model found? {find_model(bad) is not None}")
    # instance-level McGee/Incurvati-Murzi trick: Comp(not x in x and p), Comp(not x in x and not p), p = Ex z in z
    def comp_formula(phi, D, E):
        exts = {y: frozenset(x for x in D if (x, y) in E) for y in D}
        ext = frozenset(x for x in D if phi(x, D, E))
        return ext in set(exts.values())
    p = lambda D, E: any((z, z) in E for z in D)
    c1 = lambda x, D, E: (x, x) not in E and p(D, E)
    c2 = lambda x, D, E: (x, x) not in E and not p(D, E)
    for label, phis in [('Comp(R & p)', [c1]), ('Comp(R & ~p)', [c2]), ('both', [c1, c2])]:
        found = None
        for n in range(1, 4):
            D = list(range(n)); pairs = [(u, v) for u in D for v in D]
            for bits in range(1 << len(pairs)):
                E = {pairs[i] for i in range(len(pairs)) if (bits >> i) & 1}
                if all(comp_formula(f, D, E) for f in phis):
                    found = (n, sorted(E)); break
            if found: break
        print(f"  {label}: small model {found}")
    # which subsets of the 10-formula menu have a model of size <= 2 (sanity only)
    names = list(MENU)
    cnt = 0
    for k in range(len(names) + 1):
        for sub in itertools.combinations(names, k):
            if find_model(list(sub), maxn=2):
                cnt += 1
    print(f"  subsets of the menu with a model of size <= 2: {cnt} of {2**len(names)}")


def coherent(h):
    """Coherence table established by hand-proofs in the text (Facts F1-F4)."""
    return h != 'NC'


def coverage(h, practice):
    return sum(w for inst, w in practice.items() if inst in HYP[h])


def learner(practice, refuted):
    covers_all = [h for h in HYP if all(i in HYP[h] for i in practice)]
    mdl = min(covers_all, key=lambda h: ELL[h]) if covers_all else None
    cands = [h for h in HYP if h not in refuted]
    best = max(cands, key=lambda h: (coverage(h, practice), -ELL[h]))
    return mdl, best


def partB():
    print("\nPart B: learning dynamics")
    # sanity: pairwise unions of maximal coherent repairs contain a minimal inconsistent set
    mis = [{'R'}, {'V', 'ZR'}, {'CMP', 'S'}]
    for h1, h2 in itertools.combinations(['POS', 'STRAT', 'Z'], 2):
        u = HYP[h1] | HYP[h2]
        print(f"  {h1} u {h2} contains a hand-proved inconsistent set:", any(m <= u for m in mis))
    for h1, h2 in itertools.permutations(['POS', 'STRAT', 'Z', 'SEP'], 2):
        if HYP[h1] < HYP[h2]:
            print(f"  {h1} strictly inside {h2}")
    stages = [
        ("Dedekind/Cantor operations (c.1872-1890)", {'INT': 5, 'UNI': 5, 'PAIR': 3, 'DIFF': 4, 'EMP': 1}),
        ("+ Frege's universal extension (1893)",     {'INT': 5, 'UNI': 5, 'PAIR': 3, 'DIFF': 4, 'EMP': 1, 'V': 1}),
        ("+ Cantor diagonal / Zermelo Thm (ZR)",     {'INT': 5, 'UNI': 5, 'PAIR': 3, 'DIFF': 4, 'EMP': 1, 'V': 1, 'ZR': 3}),
        ("same, but V used more than ZR",            {'INT': 5, 'UNI': 5, 'PAIR': 3, 'DIFF': 4, 'EMP': 1, 'V': 4, 'ZR': 3}),
    ]
    for label, P in stages:
        mdl0, _ = learner(P, refuted=set())
        _, rep = learner(P, refuted={'NC'})
        cov = {h: coverage(h, P) for h in HYP if h != 'NC'}
        print(f"  {label}:\n     unconstrained MDL -> {mdl0};  after Russell -> {rep};  coverage {cov}")


if __name__ == '__main__':
    partA()
    partB()

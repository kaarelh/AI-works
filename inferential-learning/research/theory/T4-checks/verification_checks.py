"""Checks added after adversarial verification of T4 (see the Verification log of T4).

V1  Thm 3.4(d) (revised): with bounded-gap practice data, complete object data and truthful
    designated contexts, the eventual survivors are exactly
        { h : St^g_h  contains St^g_{h*}   and   |=_h restricted to D*  is contained in |=_{h*} },
    NOT { h in U* : St^g_h contains St^g_{h*} } as originally claimed.  The original claim is
    recovered when h* is step-expressive on D* (|=_{h*} on D* = chain closure of St^g_{h*} in D*).
    Propositional hypotheses over atoms p0..p3; calculus = axiom steps |- tau (tau in T_h, one
    application each) + one-step tautological consequence (one application).
V2  Thm 5.2(iv): which uniform repair REP selects for every sub-support of the Dedekind-Cantor
    operations, with and without ZR / V.
V3  Thm 4.4 remarks: re-count the seed-7 random classes of bag_vs_elasticity.py; check
    M_obj <= M_bag <= el* <= |H|-1; count M_obj < M_bag and M_bag = el*; the antichain
    {{1},{0,3},{0,4}} with M_bag < el*.
V4  Thm 4.3: M_obj(H) = Littlestone dimension of H (random classes).
V5  Conjecture after Prop 4.6, proved case: M_obj(H) = 1  implies  M_bag^(r)(H) <= r.
"""
import itertools, functools, random, sys
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from bag_vs_object_game import solve
from bag_vs_elasticity import elasticity
import comprehension_toy as ct

# ----------------------------------------------------------------------------- V1
ATOMS = 4
ASSIGN = list(itertools.product([0, 1], repeat=ATOMS))


def lit(i, pos):
    return ('L', i, pos)


def ev(f, a):
    if f[0] == 'L':
        return a[f[1]] == (1 if f[2] else 0)
    if f[0] == 'IMP':
        return (not ev(f[1], a)) or ev(f[2], a)
    raise ValueError


FULL = (1 << len(ASSIGN)) - 1


@functools.lru_cache(maxsize=None)
def tv(f):
    """truth vector of formula f over all assignments, as a bitmask"""
    return sum(1 << k for k, a in enumerate(ASSIGN) if ev(f, a))


def mask(fs):
    m = FULL
    for f in fs:
        m &= tv(f)
    return m


def models(fs):
    m = mask(fs)
    return [a for k, a in enumerate(ASSIGN) if (m >> k) & 1]


def entails(prem, concl):
    return mask(prem) & ~tv(concl) == 0


def min_apps(T, Gamma, y, cap):
    """Least number of rule applications of a derivation of y from Gamma in R_T
    (axiom steps for T, one-step tautological consequence); None if > cap."""
    if y in Gamma:
        return 0
    if y in T:
        return 1
    T = list(T)
    for k in range(0, cap):          # k axioms + 1 tautological step
        if k + 1 > cap:
            break
        for sub in itertools.combinations(T, k):
            if entails(list(Gamma) + list(sub), y):
                return k + 1
    return None


def steps(D):
    out = []
    for r in range(len(D) + 1):
        for G in itertools.combinations(D, r):
            for y in D:
                out.append((frozenset(G), y))
    return out


def St(T, D, g):
    return {(G, y) for (G, y) in steps(D) if min_apps(T, G, y, g) is not None}


def Val(T, D):
    return {tuple(ev(x, a) for x in D) for a in models(T)}


def Ent(T, D):
    return {(G, y) for (G, y) in steps(D) if entails(list(T) + list(G), y)}


def coherent(T, A):
    return len(models(list(T) + list(A))) > 0


def chain_closure(S, D):
    S = list(S)
    out = set()
    for (G, y) in steps(D):
        cur = set(G)
        changed = True
        while changed:
            changed = False
            for (G2, y2) in S:
                if G2 <= cur and y2 not in cur:
                    cur.add(y2); changed = True
        if y in cur:
            out.add((G, y))
    return out


def survives(Th, Tstar, D, g, designated):
    if not St(Tstar, D, g) <= St(Th, D, g):
        return False                                   # practice datum refutes h
    if not Val(Tstar, D) <= Val(Th, D):
        return False                                   # an object datum refutes h
    if any(not coherent(Th, A) for A in designated):
        return False                                   # a paradox refutes h
    return True


def V1():
    print("V1  Thm 3.4(d)")
    p = [lambda i, s=True: lit(i, s)][0]
    chain = [('IMP', p(0), p(1)), ('IMP', p(1), p(2)), ('IMP', p(2), p(3))]
    Dsmall = [p(0), p(0, False), p(3), p(3, False)]
    # the referee's counterexample
    for g in range(1, 5):
        Tstar, Th = chain, []
        surv = survives(Th, Tstar, Dsmall, g, [A for r in range(5) for A in itertools.combinations(Dsmall, r)
                                                if coherent(Tstar, A)])
        inU = Ent(Th, Dsmall) == Ent(Tstar, Dsmall)
        print(f"  chain target, empty rival, D*={{p0,~p0,p3,~p3}}, g={g}: rival survives={surv}, rival in U*={inU}")
    # random instances
    rng = random.Random(11)
    pool = [('IMP', lit(i, s), lit(j, t)) for i in range(ATOMS) for j in range(ATOMS) if i != j
            for s in (True, False) for t in (True, False)]
    n_inst = mism_orig = mism_rev = expr_inst = mism_orig_expr = 0
    for trial in range(400):
        Tstar = rng.sample(pool, rng.randint(1, 4))
        if not models(Tstar):
            continue
        atoms = rng.sample(range(ATOMS), rng.choice([2, 3, 4]))
        D = [lit(i, s) for i in atoms for s in (True, False)]
        g = rng.randint(1, 3)
        designated = [A for r in range(3) for A in itertools.combinations(D, r) if coherent(Tstar, A)]
        rivals = [Tstar[:k] for k in range(len(Tstar))] + [rng.sample(pool, rng.randint(0, 4)) for _ in range(4)]
        Sst = St(Tstar, D, g); Est = Ent(Tstar, D)
        expressive = chain_closure(Sst, D) == Est
        for Th in rivals:
            n_inst += 1
            s = survives(Th, Tstar, D, g, designated)
            Sh = St(Th, D, g); Eh = Ent(Th, D)
            orig = (Eh == Est) and Sh >= Sst
            rev = Sh >= Sst and Eh <= Est
            mism_orig += (s != orig); mism_rev += (s != rev)
            if expressive:
                expr_inst += 1; mism_orig_expr += (s != orig)
    print(f"  random: {n_inst} (target, rival) pairs; mismatches with ORIGINAL (d): {mism_orig}; "
          f"with REVISED (d): {mism_rev}")
    print(f"  among {expr_inst} pairs whose target is step-expressive on D*: mismatches with original (d): "
          f"{mism_orig_expr}")


# ----------------------------------------------------------------------------- V2
def V2():
    print("V2  Thm 5.2(iv) sub-supports")
    DC = ['INT', 'UNI', 'PAIR', 'DIFF', 'EMP']
    bad = 0
    for extra in [(), ('ZR',), ('ZR', 'V')]:
        res = {}
        for r in range(1, 6):
            for sub in itertools.combinations(DC, r):
                P = {i: 1 for i in sub}
                for e in extra:
                    P[e] = 1
                if extra == ('ZR', 'V'):
                    P['ZR'] = 2                                 # w(ZR) > w(V)
                _, rep = ct.learner(P, refuted={'NC'})
                res.setdefault(rep, []).append(sub)
                s = set(sub)
                if extra == ():
                    pred = 'POS' if not s & {'DIFF', 'EMP'} else ('SEP' if not s & {'UNI', 'PAIR', 'EMP'} else 'STRAT')
                elif extra == ('ZR',):
                    pred = 'SEP' if not s & {'UNI', 'PAIR', 'EMP'} else 'Z'
                else:
                    pred = 'SEP' if not s & {'UNI', 'PAIR', 'EMP'} else 'Z'
                bad += (pred != rep)
        print(f"  support = (subset of DC) + {list(extra)}: " +
              "; ".join(f"{k}: {len(v)} supports" for k, v in sorted(res.items())))
        if extra == ():
            print("     e.g. {INT,UNI} ->", ct.learner({'INT': 1, 'UNI': 1}, {'NC'})[1],
                  "; {INT,DIFF} ->", ct.learner({'INT': 1, 'DIFF': 1}, {'NC'})[1],
                  "; full DC ->", ct.learner({i: 1 for i in DC}, {'NC'})[1])
    # full support with V more used than ZR, and ties
    full = {i: 1 for i in DC}
    print("  full DC + ZR(3) + V(1) ->", ct.learner({**full, 'ZR': 3, 'V': 1}, {'NC'})[1],
          "; full DC + ZR(1) + V(3) ->", ct.learner({**full, 'ZR': 1, 'V': 3}, {'NC'})[1],
          "; tie ZR=V=2 ->", ct.learner({**full, 'ZR': 2, 'V': 2}, {'NC'})[1])
    print("  {INT,UNI,PAIR} + ZR(1) + V(3) ->", ct.learner({'INT': 1, 'UNI': 1, 'PAIR': 1, 'ZR': 1, 'V': 3}, {'NC'})[1],
          "(POS ties STRAT on coverage and is shorter)")
    print("  exact-condition prediction mismatches:", bad)


# ----------------------------------------------------------------------------- V3
def V3():
    print("V3  Thm 4.4 remarks (seed-7 classes of bag_vs_elasticity.py)")
    rng = random.Random(7)
    tot = lt = eq = viol = 0
    for trial in range(300):
        m = rng.randint(2, 4)
        nh = rng.randint(2, 7)
        H = list({rng.randrange(1 << m) for _ in range(nh)})
        if len(H) < 2:
            continue
        mb = solve(H, m, 'bag'); el = elasticity(H, m); mo = solve(H, m, 'obj')
        tot += 1; lt += (mo < mb); eq += (mb == el)
        viol += not (mo <= mb <= el <= len(H) - 1)
    print(f"  classes: {tot}; M_obj < M_bag in {lt}; M_bag = el* in {eq}; "
          f"violations of M_obj <= M_bag <= el* <= |H|-1: {viol}")
    H, m = [0b00010, 0b01001, 0b10001], 5
    print(f"  antichain {{1}},{{0,3}},{{0,4}}: M_obj={solve(H, m, 'obj')} M_bag={solve(H, m, 'bag')} "
          f"el*={elasticity(H, m)}")


# ----------------------------------------------------------------------------- V4, V5
def ldim(H, m):
    @functools.lru_cache(maxsize=None)
    def L(hs):
        if len(hs) <= 1:
            return 0
        best = 0
        for s in range(m):
            one = tuple(h for h in hs if (h >> s) & 1)
            zero = tuple(h for h in hs if not (h >> s) & 1)
            if one and zero:
                best = max(best, 1 + min(L(one), L(zero)))
        return best
    return L(tuple(sorted(H)))


def V4_V5():
    print("V4  M_obj = Ldim;  V5  M_obj = 1 => M_bag^(r) <= r")
    rng = random.Random(5)
    n = bad4 = n5 = bad5 = 0
    for trial in range(250):
        m = rng.randint(2, 4)
        H = list({rng.randrange(1 << m) for _ in range(rng.randint(2, 8))})
        if len(H) < 2:
            continue
        mo = solve(H, m, 'obj'); n += 1
        bad4 += (mo != ldim(H, m))
        if mo == 1:
            for r in range(1, m + 1):
                n5 += 1; bad5 += solve(H, m, 'bag', r) > r
    print(f"  {n} classes: M_obj != Ldim in {bad4};  {n5} (class, r) pairs with M_obj = 1: M_bag > r in {bad5}")


if __name__ == '__main__':
    which = sys.argv[1:] or ['V1', 'V2', 'V3', 'V4']
    if 'V1' in which: V1()
    if 'V2' in which: V2()
    if 'V3' in which: V3()
    if 'V4' in which: V4_V5()

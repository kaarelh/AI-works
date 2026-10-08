# test_nd.py -- negative tests (the checker must reject unsound steps) and concrete-motive replays of every
# schematic derivation.  Run: python3 test_nd.py   (seeded; output in test_nd.out)
import random
from nd import *
from arith import *
import arith

def expect_fail(name, f):
    try:
        f()
    except ProofError as e:
        print('  rejected as expected: %-38s (%s)' % (name, str(e)[:60]))
        return True
    print('  ERROR: accepted unsound step:', name)
    return False

def neg_tests():
    print('negative tests')
    ok = True
    def t1():  # allI on a variable free in a hypothesis
        pf = Proof(AX); l = pf.hyp(eq(x, Z)); pf.allI(l, 'x')
    def t2():  # tc on a non-tautology
        pf = Proof(AX); l = pf.hyp(OR(eq(x, Z), eq(y, Z))); pf.tc([l], eq(x, Z))
    def t3():  # exE with an eigenvariable free in the conclusion
        pf = Proof(AX); l1 = pf.hyp(EX('v', eq(x, S(v)))); l2 = pf.hyp(eq(x, S(w))); pf.exE(l1, l2, 'w')
    def t4():  # subst with a mismatched premise
        pf = Proof(AX); l1 = pf.hyp(eq(x, y)); l2 = pf.hyp(eq(y, Z)); pf.subst(l1, l2, 'u', eq(u, Z))
    def t5():  # allE with capture
        pf = Proof(AX); l = pf.ax('Dlt'); pf.allE(l, V('v'))
        pf.allE(pf.lines and len(pf.lines) - 1, add(V('z'), Z))  # u := z under Ez  -> capture
    def t6():  # wrong conclusion
        pf = Proof(AX); pf.refl(x); pf.check_closed(eq(y, y))
    def t7():  # open hypothesis left
        pf = Proof(AX); pf.hyp(eq(x, x)); pf.check_closed(eq(x, x))
    def t8():  # quantifier atoms are not propositional: Ax P(x) does not tautologically give P(y)
        pf = Proof(AX); l = pf.hyp(ALL('x', Pm)); pf.tc([l], pred('P', y))
    def t9():  # exI with a wrong witness
        pf = Proof(AX); l = pf.refl(x); pf.exI(l, 'z', eq(z, y), x)
    def t10(): # exE eigenvariable free in a remaining hypothesis
        pf = Proof(AX); l1 = pf.hyp(EX('v', eq(x, S(v)))); l2 = pf.hyp(eq(w, Z)); l3 = pf.hyp(eq(x, S(w)))
        l4 = pf.tc([l2, l3], eq(w, Z)); pf.exE(l1, l4, 'w')
    for nm, f in [('allI eigenvariable', t1), ('tc non-tautology', t2), ('exE fresh (concl)', t3),
                  ('subst mismatch', t4), ('allE capture', t5), ('wrong goal', t6), ('open hypothesis', t7),
                  ('tc through a quantifier', t8), ('exI witness', t9), ('exE fresh (hyp)', t10)]:
        ok &= expect_fail(nm, f)
    return ok

# random concrete motives: free variable x (and parameter p), bound variables named a, b
def rterm(rng, d, vs):
    if d <= 0 or rng.random() < 0.4:
        return rng.choice([Z, V('x'), V('p')] + [V(c) for c in vs])
    r = rng.random()
    if r < 0.4: return S(rterm(rng, d - 1, vs))
    if r < 0.7: return add(rterm(rng, d - 1, vs), rterm(rng, d - 1, vs))
    return mul(rterm(rng, d - 1, vs), rterm(rng, d - 1, vs))

def rform(rng, d, vs=()):
    if d <= 0 or rng.random() < 0.3:
        return rng.choice([eq, lt])(rterm(rng, 2, vs), rterm(rng, 2, vs))
    r = rng.random()
    if r < 0.2: return NOT(rform(rng, d - 1, vs))
    if r < 0.6: return (rng.choice(['and', 'or', 'imp']), rform(rng, d - 1, vs), rform(rng, d - 1, vs))
    b = 'a' if 'a' not in vs else 'b'
    if b in vs: return rform(rng, d - 1, vs)
    return (rng.choice(['all', 'ex']), b, rform(rng, d - 1, vs + (b,)))

def replay(phi):
    m = (('x',), phi)
    negm = (('x',), NOT(phi))
    theta = ALL('y', IMP(lt(y, x), subst(phi, 'x', y)))
    out = []
    for name, build, goal in [
        ('A', lambda pf: d_ind_from_cvi(pf, phi, cite('CVI', m)), Ind(m)),
        ('B', lambda pf: d_cvi_from_ind(pf, phi, cite('Ind', (('x',), theta))), CVI(m)),
        ('C1', lambda pf: d_lnp_from_cvi_neg(pf, phi, cite('CVI', negm)), LNP(m)),
        ('C2', lambda pf: d_cvi_from_lnp_neg(pf, phi, cite('LNP', negm)), CVI(m))]:
        pf = Proof(AX, SCH)
        build(pf)
        pf.check_closed(goal)
        out.append((name, pf.stats()['written']))
    return out

if __name__ == '__main__':
    ok = neg_tests()
    rng = random.Random(20261008)
    n_ok = 0
    for i in range(200):
        phi = rform(rng, 3)
        if 'x' not in fv(phi):
            phi = AND(phi, eq(V('x'), V('x')))
        try:
            replay(phi); n_ok += 1
        except ProofError as e:
            print('  concrete replay FAILED on', show(phi), e)
            ok = False
    print('concrete replays: %d/200 motives, all four derivations checked' % n_ok)
    print('ALL TESTS PASSED' if ok else 'SOME TESTS FAILED')

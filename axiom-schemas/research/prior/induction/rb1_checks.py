# Referee checks of B1-B4, B8 with the independent core (rb_core.py).
import itertools, random
from rb_core import *

out = []
def say(*a):
    s = ' '.join(str(x) for x in a); print(s); out.append(s)

# ---------- B1(b): the natural pair ----------
D2 = [IND(EQ(ADD(X, ZERO), X)), IND(EQ(ADD(ZERO, X), X))]
L = antiunify(D2)
say('B1(b) lgg =', show(normalize(L)), '#mv =', len(mvars(L)))
I1 = IMP(AND(EQ(ADD(ZERO, ZERO), ZERO), ALL(X, IMP(EQ(ADD(ZERO, ZERO), X), EQ(ADD(ZERO, S(ZERO)), S(X))))),
         ALL(X, EQ(ADD(ZERO, ZERO), X)))
say('   I*_1 instance:', inst_of(I1, L), ' I*_1 true in N:', holds(I1), ' data true:', [holds(d) for d in D2])
four = [EQ(ADD(X, ZERO), X), EQ(ADD(ZERO, X), X), EQ(ADD(S(X), ZERO), S(X)), EQ(ADD(X, S(ZERO)), S(X))]
L4 = antiunify([IND(p) for p in four])
say('   lgg(4) more general than lgg(2):', inst_of(L, L4), '; strictly:', not inst_of(L4, L))

# ---------- B1(d): sound pair ----------
Ls = antiunify([IND(EQ(X, X)), IND(EQ(S(X), S(X)))])
say('B1(d) lgg(x=x, Sx=Sx) =', show(normalize(Ls)), ' false instance found:', false_instance(Ls))

# ---------- B2.1/B2.2 with own code, larger range ----------
def Ln(n):
    a, b, c = mv('a'), mv('b'), mv('c')
    return IMP(AND(EQ(gn(n, a), ZERO), ALL(X, IMP(EQ(gn(n, b), X), EQ(gn(n, c), S(X))))), ALL(X, EQ(gn(n, b), X)))
def Istar(n):
    return IMP(AND(EQ(gn(n, ZERO), ZERO), ALL(X, IMP(EQ(gn(n, ZERO), X), EQ(gn(n, S(ZERO)), S(X))))),
               ALL(X, EQ(gn(n, ZERO), X)))
ok = True
for n in range(0, 15):
    assert holds(IND(EQ(gn(n, X), X)))
    assert holds(Istar(n)) is False
    for m in range(n + 1, 15):
        Lnm = antiunify([IND(EQ(gn(n, X), X)), IND(EQ(gn(m, X), X))])
        ok &= equiv(Lnm, Ln(n))
say('B2.1 lgg(Ind phi_n, Ind phi_m) == L_n for 0<=n<m<=14:', ok)
say('B2.2 I*_M in inst(L_a) for all a<=M<=14:', all(inst_of(Istar(M), Ln(a)) for a in range(15) for M in range(a, 15)))
# random subsets of size >= 2 from {0..20}
rng = random.Random(7)
ok = True
for _ in range(300):
    sub = sorted(rng.sample(range(21), rng.randint(2, 6)))
    ok &= equiv(antiunify([IND(EQ(gn(i, X), X)) for i in sub]), Ln(sub[0]))
say('B2.1 300 random subsets of {0..20}: lgg == L_min:', ok)

# random generalizations tau >= L_n (anti-unify L_n's ground instance with random extra ground terms):
# every such tau must contain I*_n
ok = True
for _ in range(200):
    n = rng.randint(0, 5); m = n + rng.randint(1, 4)
    extra = IND(rng.choice([EQ(X, X), EQ(ZERO, X), EQ(MUL(ZERO, X), ZERO), NEG(EQ(X, S(X))), EQ(gn(rng.randint(0, 8), X), X)]))
    tau = antiunify([IND(EQ(gn(n, X), X)), IND(EQ(gn(m, X), X)), extra])
    ok &= inst_of(Istar(max(n, 0)), tau) or inst_of(Istar(n), tau)
say('B2(a) 200 random covering schemas: each has a false I*_n instance:', ok)

# family F: K_n, J*_M in inst(K_a) for a<=M
def Kn(n):
    z1, z2 = mv('z1'), mv('z2')
    return IMP(AND(EQ(ADD(numeral(n, z1), ZERO), numeral(n, z1)),
                   ALL(X, IMP(EQ(ADD(numeral(n, z1), X), numeral(n, z2)), EQ(ADD(numeral(n, z1), S(X)), numeral(n + 1, z2))))),
               ALL(X, EQ(ADD(numeral(n, z1), X), numeral(n, z2))))
def Jstar(n): return apply(Kn(n), {'z1': ZERO, 'z2': ZERO})
ok = True
for n in range(10):
    assert holds(IND(EQ(ADD(numeral(n), X), numeral(n, X)))) and holds(Jstar(n)) is False
    for m in range(n + 1, 10):
        ok &= equiv(antiunify([IND(EQ(ADD(numeral(n), X), numeral(n, X))), IND(EQ(ADD(numeral(m), X), numeral(m, X)))]), Kn(n))
say('B2(d) family F: lgg == K_n for 0<=n<m<=9:', ok,
    '; J*_M in inst(K_a) for a<=M<=9:', all(inst_of(Jstar(M), Kn(a)) for a in range(10) for M in range(a, 10)),
    '; inst(K_n) subset of inst(K_0) (K_0 >= K_n):', all(inst_of(Kn(n), Kn(0)) for n in range(10)))

# ---------- B3(a): root-diverse pairs with x free collapse to L_inf (random, incl. quantified motives) ----------
Linf = IMP(AND(mv('A'), ALL(X, IMP(mv('B'), mv('C')))), ALL(X, mv('B')))
def rterm(d):
    if d == 0 or rng.random() < 0.3: return rng.choice([ZERO, X, X])
    r = rng.random()
    if r < 0.4: return S(rterm(d - 1))
    if r < 0.75: return ADD(rterm(d - 1), rterm(d - 1))
    return MUL(rterm(d - 1), rterm(d - 1))
def rform(d):
    if d == 0 or rng.random() < 0.35: return EQ(rterm(2), rterm(2))
    r = rng.random()
    if r < 0.2: return NEG(rform(d - 1))
    if r < 0.3:  # quantifier over y (x stays free)
        return rng.choice([ALL, EX])(Y, EQ(ADD(rterm(1), Y), rterm(2)))
    return rng.choice([AND, OR, IMP])(rform(d - 1), rform(d - 1))
tested = 0; ok = True
for _ in range(3000):
    f1, f2 = rform(3), rform(3)
    if f1[0] == f2[0]: continue
    if X not in fv(f1) and X not in fv(f2): continue
    tested += 1
    ok &= equiv(antiunify([IND(f1), IND(f2)]), Linf)
say('B3(a) %d random root-diverse pairs (x free in one): lgg == L_inf:' % tested, ok)
LinfI = apply(Linf, {'A': EQ(ZERO, ZERO), 'B': EQ(ZERO, S(ZERO)), 'C': EQ(ZERO, S(ZERO))})
say('   L_inf instance', show(LinfI), 'true:', holds(LinfI))

# ---------- B4(b): H_k version spaces (own partition brute force, family F' and family F) ----------
def partitions(items, k):
    def rec(i, blocks):
        if i == len(items): yield [list(b) for b in blocks]; return
        for b in blocks:
            b.append(items[i]); yield from rec(i + 1, blocks); b.pop()
        if len(blocks) < k:
            blocks.append([items[i]]); yield from rec(i + 1, blocks); blocks.pop()
    yield from rec(0, [])
for fam, data, false in (("F'", lambda i: IND(EQ(gn(i, X), X)), Istar), ('F', lambda i: IND(EQ(ADD(numeral(i), X), numeral(i, X))), Jstar)):
    allok = True
    for N in range(1, 6):
        D = [data(i) for i in range(N + 1)]
        for k in range(1, N + 1):
            for part in partitions(D, k):
                if not any(inst_of(false(N), antiunify(b)) for b in part): allok = False
    say('B4(b) family %s, N+1<=6, all k<=N: every minimal member of VS_{H_k} contains the false instance:' % fam, allok)

# ---------- B8 with TTL's trimmed estimator: mgu of trimmed lggs still contains I*_M ----------
# hat sigma = mgu{lgg(P\E): |E|=e}; inst(mgu) = intersection of instance sets; check I*_M in every trimmed lgg
ok = True
for e in range(0, 3):
    for extra_noise in range(0, e + 1):
        idx = list(range(e + 2))
        P = [IND(EQ(gn(i, X), X)) for i in idx]
        # noise items: false or foreign sentences
        P += [EQ(ZERO, S(ZERO))] * 0 + [IMP(EQ(ZERO, ZERO), EQ(ZERO, S(ZERO)))] * extra_noise
        M = max(idx)
        for E in itertools.combinations(range(len(P)), e):
            rest = [p for j, p in enumerate(P) if j not in E]
            ok &= inst_of(Istar(M), antiunify(rest))
say('B8 clean data with e+2 members of F\' (e<=2, plus <=e noise items): I*_M in every e-trimmed lgg:', ok)

open('rb1_checks.out', 'w').write('\n'.join(out) + '\n')

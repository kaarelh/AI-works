# Prop B5: world refutations (Delta_0 truth + trusted first-order logic with equality) of the over-general
# lggs, with the paper's propagation (forward/backward through trusted steps of the derivation) and descent.
# A judgment is (Gamma, phi) with Gamma a frozenset of formulas (sequent format, Gamma |- phi).
from raw_common import *
from raw_search import pretty
from b2_family import Ln, Istar, Kn, Jstar
import b2_family  # noqa  (prints its own checks once)

TRUSTED = {'assume', 'refl', 'congS', 'sym', 'trans', 'impI', 'allI', 'andI', 'impE', 'allE'}

def fv_ctx(G):
    out = set()
    for f in G: out |= free_vars(f)
    return out

def check_step(rule, prem, concl, arg, schemas):
    G, f = concl
    if rule == 'schema':                       # an untrusted practice step: instance of a learned schema
        name = arg
        return not prem and not G and is_instance(f, schemas[name])
    if rule == 'leaf':                         # world leaf: closed Delta_0 sentence, W-true
        return not prem and not G and is_sentence(f) and truth(f) is True
    if rule == 'assume': return not prem and f in G
    if rule == 'refl': return not prem and f[0] == 'eq' and f[1] == f[2]
    if rule == 'congS':
        (G1, e1), = prem
        return G == G1 and e1[0] == 'eq' and f == eq(S(e1[1]), S(e1[2]))
    if rule == 'sym':
        (G1, e1), = prem
        return G == G1 and f == eq(e1[2], e1[1])
    if rule == 'trans':
        (G1, e1), (G2, e2) = prem
        return G == G1 | G2 and e1[0] == e2[0] == 'eq' and e1[2] == e2[1] and f == eq(e1[1], e2[2])
    if rule == 'impI':
        (G1, e1), = prem
        a = arg
        return f == IMP(a, e1) and G == G1 - {a}
    if rule == 'allI':
        (G1, e1), = prem
        return G == G1 and f == ALL(X, e1) and X not in fv_ctx(G1)
    if rule == 'andI':
        (G1, e1), (G2, e2) = prem
        return G == G1 | G2 and f == AND(e1, e2)
    if rule == 'impE':
        (G1, e1), (G2, e2) = prem
        return G == G1 | G2 and e1 == IMP(e2, f)
    if rule == 'allE':
        (G1, e1), = prem
        v, t = e1[1], arg
        return G == G1 and e1[0] == 'all' and f == subst(e1[2], v, t)
    raise ValueError(rule)

def run(name, deriv, schemas, designated=frozenset()):
    """deriv: list of (label, rule, premise labels, (Gamma, phi), arg)."""
    J = {}; step_of = {}
    for lab, rule, pl, concl, arg in deriv:
        prem = [J[p] for p in pl]
        assert check_step(rule, prem, concl, arg, schemas), ('bad step', lab, rule)
        J[lab] = concl; step_of[lab] = (rule, pl)
    assert len(set(J.values())) == len(J), 'judgments must be distinct'
    # e: world values on closed Delta_0 judgments with empty context; designated assertions get 1
    val = {}
    for lab, (G, f) in J.items():
        if not G and f in designated: val[lab] = 1
        elif not G and is_sentence(f) and quantifier_free(f):   # W = Delta_0 truth (here: closed q.f.)
            val[lab] = 1 if truth(f) else 0
    # propagation through the trusted steps of the derivation (forward / backward), to a fixed point
    changed = True
    while changed:
        changed = False
        for lab, (rule, pl) in step_of.items():
            if rule not in TRUSTED: continue
            if lab not in val and all(val.get(p) == 1 for p in pl):
                val[lab] = 1; changed = True
            if val.get(lab) == 0:
                unk = [p for p in pl if val.get(p) != 1]
                if len(unk) == 1 and unk[0] not in val:
                    val[unk[0]] = 0; changed = True
    concl = deriv[-1][0]
    assert val.get(concl) == 0, 'conclusion must be W-false'
    # descent
    cur = concl; path = [cur]; blocked = False
    while True:
        rule, pl = step_of[cur]
        if all(val.get(p) == 1 for p in pl): out = (cur, rule); break
        zero = [p for p in pl if val.get(p) == 0]
        if not zero: blocked = True; out = None; break
        cur = zero[0]; path.append(cur)
    size = sum(sum(size_(g) for g in G) + size_(f) for G, f in J.values())
    print('==', name)
    for lab, rule, pl, (G, f), arg in deriv:
        ctx = ', '.join(pretty(g) for g in sorted(G)) + ' ' if G else ''
        print('   %-3s %s|- %-48s [%s%s]  value=%s' % (lab, ctx, pretty(f), rule + (':' + arg if rule == 'schema' else ''), (' ' + ','.join(pl)) if pl else '', val.get(lab, '-')))
    print('   descent path:', ' -> '.join(path), '| blocked' if blocked else '| outputs step %s (%s)' % out)
    names = {lab: arg for lab, rule, pl, c, arg in deriv if rule == 'schema'}
    bag = sorted({names[l] for l in J if l in names}) if blocked else []
    if blocked: print('   blocked: only the bag of untrusted steps is condemned:', bag)
    print('   size (symbols of distinct judgments, contexts included) =', size)
    return size, blocked

def size_(t): return size(t)
def quantifier_free(f):
    if is_var(f) or len(f) == 1: return True
    if f[0] in ('all', 'ex'): return False
    return all(quantifier_free(a) for a in f[1:])

E = frozenset()
def refutation_Istar(n):
    a, b = g(n, Z), g(n, S(Z))
    h = eq(a, X); H = frozenset([h])
    inst = Istar(n)
    d = [
        ('1', 'schema', [], (E, inst), 'L'),
        ('2', 'leaf', [], (E, eq(a, Z)), None),
        ('3', 'leaf', [], (E, eq(b, S(a))), None),
        ('4', 'assume', [], (H, h), None),
        ('5', 'congS', ['4'], (H, eq(S(a), S(X))), None),
        ('6', 'trans', ['3', '5'], (H, eq(b, S(X))), None),
        ('7', 'impI', ['6'], (E, IMP(h, eq(b, S(X)))), h),
        ('8', 'allI', ['7'], (E, ALL(X, IMP(h, eq(b, S(X))))), None),
        ('9', 'andI', ['2', '8'], (E, AND(eq(a, Z), ALL(X, IMP(h, eq(b, S(X)))))), None),
        ('10', 'impE', ['1', '9'], (E, ALL(X, h)), None),
        ('11', 'allE', ['10'], (E, eq(a, S(Z))), S(Z)),
    ]
    if b == S(a):   # n = 0: b = S(a) syntactically, so leaf 3 and the transitivity step 6 are not needed
        d = [st for st in d if st[0] not in ('3', '6')]
        d = [(l, r, ['5'] if pl == ['6'] else pl, c, arg) for (l, r, pl, c, arg) in d]
    return d

if __name__ == '__main__':
    sizes = {}
    for n in range(0, 6):
        sizes[n] = run('refutation of L_%d via its instance I*_%d (n=%d)' % (n, n, n) if n < 2 else 'I*_%d' % n,
                       refutation_Istar(n), {'L': Ln(n)})[0]
    print('sizes of the I*_n refutations, n=0..5:', sizes, ' increments:', [sizes[i + 1] - sizes[i] for i in range(5)])

    # L_inf = zA & Ax(zB -> zC) -> Ax zB, refuted through its instance with zB := 0=S0
    Linf = IMP(AND(MV('A'), ALL(X, IMP(MV('B'), MV('C')))), ALL(X, MV('B')))
    bot = eq(Z, S(Z)); H = frozenset([bot])
    inst = IMP(AND(eq(Z, Z), ALL(X, IMP(bot, bot))), ALL(X, bot))
    run('L_inf via (0=0 & Ax(0=S0 -> 0=S0)) -> Ax(0=S0)', [
        ('1', 'schema', [], (E, inst), 'Linf'),
        ('2', 'refl', [], (E, eq(Z, Z)), None),
        ('3', 'assume', [], (H, bot), None),
        ('4', 'impI', ['3'], (E, IMP(bot, bot)), bot),
        ('5', 'allI', ['4'], (E, ALL(X, IMP(bot, bot))), None),
        ('6', 'andI', ['2', '5'], (E, AND(eq(Z, Z), ALL(X, IMP(bot, bot)))), None),
        ('7', 'impE', ['1', '6'], (E, ALL(X, bot)), None),
        ('8', 'allE', ['7'], (E, bot), Z)], {'Linf': Linf})

    # family F: J*_0 = (0+0=0 & Ax(0+x=0 -> 0+Sx=S0)) -> Ax(0+x=0) needs Q's recursion axiom for +
    Q3 = ALL(X, ALL(Y, eq(add(X, S(Y)), S(add(X, Y)))))
    h = eq(add(Z, X), Z); H = frozenset([h])
    der = [
        ('1', 'schema', [], (E, Jstar(0)), 'K'),
        ('2', 'leaf', [], (E, eq(add(Z, Z), Z)), None),
        ('3', 'schema', [], (E, Q3), 'Q3'),
        ('4', 'allE', ['3'], (E, ALL(Y, eq(add(Z, S(Y)), S(add(Z, Y))))), Z),
        ('5', 'allE', ['4'], (E, eq(add(Z, S(X)), S(add(Z, X)))), X),
        ('6', 'assume', [], (H, h), None),
        ('7', 'congS', ['6'], (H, eq(S(add(Z, X)), S(Z))), None),
        ('8', 'trans', ['5', '7'], (H, eq(add(Z, S(X)), S(Z))), None),
        ('9', 'impI', ['8'], (E, IMP(h, eq(add(Z, S(X)), S(Z)))), h),
        ('10', 'allI', ['9'], (E, ALL(X, IMP(h, eq(add(Z, S(X)), S(Z))))), None),
        ('11', 'andI', ['2', '10'], (E, AND(eq(add(Z, Z), Z), ALL(X, IMP(h, eq(add(Z, S(X)), S(Z)))))), None),
        ('12', 'impE', ['1', '11'], (E, ALL(X, h)), None),
        ('13', 'allE', ['12'], (E, eq(add(Z, S(Z)), Z)), S(Z))]
    schemas = {'K': Kn(0), 'Q3': Q3}
    run('family F, K_0 via J*_0, empty position (Q3 a practice axiom)', der, schemas)
    run('family F, K_0 via J*_0, position asserting Q3 designated', der, schemas, designated=frozenset([Q3]))

# compressed Hilbert-style refutation (one trusted FOL step  b=S(a) / Ax(a=x -> b=Sx)), sizes only
def compressed_size(n):
    a, b = g(n, Z), g(n, S(Z))
    js = [Istar(n), eq(a, Z), eq(b, S(a)), ALL(X, IMP(eq(a, X), eq(b, S(X)))),
          AND(eq(a, Z), ALL(X, IMP(eq(a, X), eq(b, S(X))))), ALL(X, eq(a, X)), eq(a, S(Z))]
    js = list(dict.fromkeys(js))          # distinct judgments (n=0: b=S(a) is the trivial S0=S0)
    return sum(size(j) for j in js), size(Istar(n))
if __name__ == '__main__':
    print('compressed refutation sizes (|pi|, |I*_n|) for n=0..5:', [compressed_size(n) for n in range(6)])

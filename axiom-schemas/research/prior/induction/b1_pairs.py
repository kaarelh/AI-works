# Prop B1: two raw induction instances suffice to force an unsound first-order schema; one never does.
from raw_common import *
from raw_search import find_false, pretty, rename_pretty

def report(name, phis):
    D = [Ind(p) for p in phis]
    L = lgg_list(D)
    print('==', name)
    for p in phis: print('   phi =', pretty(p))
    print('   lgg  =', rename_pretty(L), '  (#metavars=%d)' % len(vars_of(L)))
    r = find_false(L)
    if r is None:
        print('   no false sentence instance found in the search pool'); return L, None
    s, th = r
    print('   FALSE instance:', pretty(s))
    # sanity: every datum is an instance, and every datum is true
    assert all(is_instance(d, L) for d in D)
    assert all(truth(d) for d in D)
    assert is_instance(s, L) and is_sentence(s) and truth(s) is False
    return L, s

# (a) the natural pair: the paper's false instance from TWO instances (the paper used four)
L, s = report('natural pair  {Ind(x+0=x), Ind(0+x=x)}', [eq(add(X, Z), X), eq(add(Z, X), X)])
paper_false = IMP(AND(eq(add(Z, Z), Z), ALL(X, IMP(eq(add(Z, Z), X), eq(add(Z, S(Z)), S(X))))), ALL(X, eq(add(Z, Z), X)))
print('   the paper\'s false instance (0+0=0)&Ax(0+0=x -> 0+S0=Sx) -> Ax(0+0=x) is an instance:',
      is_instance(paper_false, L), '; true in N:', truth(paper_false))
# the paper's four instances
four = [eq(add(X, Z), X), eq(add(Z, X), X), eq(add(S(X), Z), S(X)), eq(add(X, S(Z)), S(X))]
L4 = lgg_list([Ind(p) for p in four])
print('   lgg of the paper\'s 4 instances =', rename_pretty(L4))
print('   lgg(4) is a specialization-or-equal of lgg(2)? (lgg(2) >= lgg(4)):', is_instance(L4, L),
      '; lgg(4) >= lgg(2):', is_instance(L, L4))

# (b) the pair {Ind(0+x=x), Ind(0+(0+x)=x)} also gives exactly the paper's false instance
L, s = report('pair {Ind(0+x=x), Ind(0+(0+x)=x)}', [eq(g(1, X), X), eq(g(2, X), X)])
print('   paper false instance is an instance:', is_instance(paper_false, L))

# (c) smallest formulas: |phi| = 3
for ph in ([eq(X, X), eq(Z, X)], [eq(X, X), eq(X, Z)], [eq(Z, X), eq(X, Z)], [eq(X, X), eq(g(1, X), X)]):
    report('small pair', ph)

# (d) a root-diverse pair: lgg is the bare frame L_inf = zA & Ax(zB -> zC) -> Ax zB
L, s = report('root-diverse pair {Ind(x=x), Ind(~(x=Sx))}', [eq(X, X), NOT(eq(X, S(X)))])
Linf = IMP(AND(MV('A'), ALL(X, IMP(MV('B'), MV('C')))), ALL(X, MV('B')))
print('   lgg == L_inf up to renaming:', canon(L) == canon(Linf))
bot_inst = subst_meta(Linf, {'A': eq(Z, Z), 'B': eq(Z, S(Z)), 'C': eq(Z, S(Z))})
print('   L_inf instance', pretty(bot_inst), ' true?', truth(bot_inst))

# (e) a pair whose lgg is sound (not every pair suffices): {Ind(x=x), Ind(Sx=Sx)}
L, s = report('coupled pair {Ind(x=x), Ind(Sx=Sx)}', [eq(X, X), eq(S(X), S(X))])
print('   (every well-sorted instance has the form  t=t & Ax(u=u -> Su=Su) -> Ax(u=u): conclusion true)')

# (f) one instance never suffices: the ground schema {Ind(phi)} is its own lgg and is sound
p = eq(add(Z, X), X)
print('\n== single instance: lgg({Ind(0+x=x)}) has', len(vars_of(lgg_list([Ind(p)]))), 'metavariables; it is the true sentence itself:', truth(Ind(p)))

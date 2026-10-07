# e15 (revision): Prop F.5 needs Theta_i nonempty for ground members (referee item F5-F6).
# Target: Ind  U  {Extensionality} (k' = 2), class H_2(DT°).  Ground member: Fail(Ext) is empty, so the
# old hypothesis of Prop F.5 holds vacuously even with no Extensionality datum, but the verifier is then not exact.
from dtcore import *
from dtunion import acc_union_bf, BlockAcc
X = H(0)
EXT = ALL(ALL(IMP(ALL(IFF(mem(V(0), V(1)), mem(V(0), V(2)))), eq(V(1), V(0)))))
ind = [Ind(m) for m in [eq(X, X), NOT(eq(X, Z)), ALL(eq(V(0), X))]]
fresh = [Ind(eq(add(X, Z), X)), Ind(EX(eq(V(0), S(X))))]
for name, D in [('3 Ind data, no Ext datum', ind), ('3 Ind data + Ext', ind + [EXT])]:
    print(name + ':')
    for qn, q in [('Ext', EXT)] + [('fresh Ind %d' % i, f) for i, f in enumerate(fresh)]:
        print('   k=2 accepts %-12s %s' % (qn, acc_union_bf(D, q, 2)))

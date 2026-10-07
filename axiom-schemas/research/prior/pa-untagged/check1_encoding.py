# (1) realizability and mixing: what can one schema cover?
from pa_common import *
phis=[(eq(add(x,Z),x),x),(lt(Z,S(y)),y),(AND(eq(n,n),lt(n,S(n))),n),(NOT(eq(S(m),Z)),m),
      (OR(eq(x,Z),lt(Z,x)),x),(ALL(y,eq(add(x,y),add(y,x))),x),(IMP(eq(x,y),eq(S(x),S(y))),x),(EX(y,eq(x,S(y))),x)]
for enc,ax,ind,sig in [('V',ax_V,ind_V,sigma_V),('L',ax_L,ind_L,sigma_L)]:
    I=[ind(p,v) for p,v in phis]
    print(f'--- encoding {enc} ---')
    # target pattern recovered by lgg (x metavariable, since data vary the induction variable)
    print(' lgg(induction data) == sigma (x metavar):', equiv(lgg_list(I),sig(True)))
    # lgg of the seven Q axiom steps
    LQ=lgg_list([ax(A) for A in Q]); print(' lgg(Q steps) =',show(LQ),'; covers an induction instance?',any(is_instance(i,LQ) for i in I))
    # mixing: any schema covering a Q-axiom step and an induction step
    allgen=True; universal=True
    for A in Q+Qopen:
        for i in I:
            l=lgg_list([ax(A),i])
            allgen&=gen(l,sig(True)); universal&= (l[0]=='?')
    print(' every lgg(Q-step, ind-step) is >= sigma_ind (x metavar):',allgen,'; always a bare metavariable:',universal)
    # ground axioms are never instances of the induction pattern
    print(' some Q step is an instance of sigma_ind:',any(is_instance(ax(A),sig(True)) for A in Q+Qopen))
    if enc=='L':
        # a non-universal mixed schema exists in the list encoding: it covers premise-free implications too
        mixed=('s',MV('L'),IMP(MV('u'),MV('v')))
        print(' list encoding: s(L, u->v) covers premise-free step |- 0=0 -> 0=S0:',is_instance(ax_L(IMP(eq(Z,Z),eq(Z,S(Z)))),mixed),
              '; covers all induction:',gen(mixed,sig(True)))

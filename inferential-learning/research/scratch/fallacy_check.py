import itertools
# check constant-substitution witnesses: premises become tautologies, conclusion a contradiction
imp=lambda a,b:(1-a)|b
fallacies={
 'affirming consequent  q, p->q / p': (lambda p,q:[q,imp(p,q)], lambda p,q:p),
 'denying antecedent   ~p, p->q / ~q': (lambda p,q:[1-p,imp(p,q)], lambda p,q:1-q),
 'conversion           p->q / q->p': (lambda p,q:[imp(p,q)], lambda p,q:imp(q,p)),
 'bad contraposition   p->q / ~p->~q': (lambda p,q:[imp(p,q)], lambda p,q:imp(1-p,1-q)),
 'or-as-xor            p v q, p / ~q': (lambda p,q:[p|q,p], lambda p,q:1-q),
 'or-elim confusion    p v q / p': (lambda p,q:[p|q], lambda p,q:p),
 'neg of and           ~(p&q) / ~p & ~q': (lambda p,q:[1-(p&q)], lambda p,q:(1-p)&(1-q)),
}
for name,(prem,conc) in fallacies.items():
    w=[(p,q) for p,q in itertools.product([0,1],repeat=2) if all(x==1 for x in prem(p,q)) and conc(p,q)==0]
    print(f"{name:40s} falsifying assignments (=constant substitutions p->T/F, q->T/F): {w}")

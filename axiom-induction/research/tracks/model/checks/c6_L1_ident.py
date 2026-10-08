"""c6: deductively equivalent theories with different derivation-grammar likelihoods (notes, Prop 2.5).

Propositional Hilbert calculus (Mendelson A1-A3, rule MP) over atoms a, b.
T1 = {a, b}, T2 = {a, a->b}: same theorems.  Bounded-depth derivation grammar (L2): a node cites a theory axiom
(prob al_ax, uniform over the theory's axioms), cites a logical axiom (al_lg; A1/A2/A3 uniformly, metavariables from a
PCFG Q truncated to formulas of size <= 3), or applies MP (al_mp) to two independent subtrees; at the depth bound
only citations (renormalised).  mu_k(s) = cite part + al_mp * sum_A mu_{k-1}(A) mu_{k-1}(A->s);  P_T = mu_d / Z_T.
Proved region (Prop 2.5): P_T1(b) >= al_ax/2 > al_r/(1-al_r) >= P_T2(b).  Here we compute P_T1, P_T2 exactly.
"""
import itertools
from collections import defaultdict

A_, B_ = ('a',), ('b',)

def imp(x, y):
    return ('>', x, y)

def neg(x):
    return ('~', x)

def fsize(f):
    return 1 + sum(fsize(c) for c in f[1:])

def show(f):
    if f[0] in ('a', 'b'):
        return f[0]
    if f[0] == '~':
        return '~' + show(f[1])
    return '(' + show(f[1]) + '>' + show(f[2]) + ')'

# PCFG Q on formulas: a .3, b .3, ~ .2, > .2 ; truncated to size <= 3, renormalised
pq = {'a': 0.3, 'b': 0.3, '~': 0.2, '>': 0.2}
def qprob(f):
    r = pq[f[0]]
    for c in f[1:]:
        r *= qprob(c)
    return r
forms = [A_, B_]
forms += [neg(x) for x in forms if fsize(x) <= 2]
forms = list(dict.fromkeys(forms + [neg(neg(A_)), neg(neg(B_))] + [imp(x, y) for x in (A_, B_) for y in (A_, B_)]))
forms = [f for f in forms if fsize(f) <= 3]
zq = sum(qprob(f) for f in forms)
Q = {f: qprob(f) / zq for f in forms}

# logical axiom instance distribution Q_Lambda
QL = defaultdict(float)
for P_, Q_ in itertools.product(forms, repeat=2):
    QL[imp(P_, imp(Q_, P_))] += Q[P_] * Q[Q_] / 3                               # A1
    QL[imp(imp(neg(Q_), neg(P_)), imp(imp(neg(Q_), P_), Q_))] += Q[P_] * Q[Q_] / 3  # A3
for P_, Q_, R_ in itertools.product(forms, repeat=3):
    QL[imp(imp(P_, imp(Q_, R_)), imp(imp(P_, Q_), imp(P_, R_)))] += Q[P_] * Q[Q_] * Q[R_] / 3  # A2

def run(theory, al_ax, al_lg, al_mp, depth):
    L0 = {s: 1 / len(theory) for s in theory}
    def cite(scale_ax, scale_lg):
        m = defaultdict(float)
        for s, w in L0.items():
            m[s] += scale_ax * w
        for s, w in QL.items():
            m[s] += scale_lg * w
        return m
    mu = cite(al_ax / (al_ax + al_lg), al_lg / (al_ax + al_lg))   # height 0: citations only
    for _ in range(depth):
        new = cite(al_ax, al_lg)
        for f, w in mu.items():   # f = A -> s as right premise
            if f[0] == '>' and f[1] in mu:
                new[f[2]] += al_mp * mu[f[1]] * w
        mu = new
    Z = sum(mu.values())
    return {s: w / Z for s, w in mu.items()}, Z

out = []
T1 = [A_, B_]
T2 = [A_, imp(A_, B_)]
for al_ax, al_lg, al_mp in ((0.6, 0.25, 0.15), (0.5, 0.3, 0.2), (0.3, 0.3, 0.4), (0.2, 0.4, 0.4)):
    for depth in (1, 2):
        P1, Z1 = run(T1, al_ax, al_lg, al_mp, depth)
        P2, Z2 = run(T2, al_ax, al_lg, al_mp, depth)
        tv = 0.5 * sum(abs(P1.get(s, 0) - P2.get(s, 0)) for s in set(P1) | set(P2))
        region = al_ax / 2 > al_mp / (1 - al_mp)
        out.append(f"al=({al_ax},{al_lg},{al_mp}) depth {depth}: Z1={Z1:.4f} Z2={Z2:.4f}; "
                   f"P1(b)={P1.get(B_,0):.4f} P2(b)={P2.get(B_,0):.4f}; "
                   f"P1(a>b)={P1.get(imp(A_,B_),0):.4f} P2(a>b)={P2.get(imp(A_,B_),0):.4f}; "
                   f"TV(P1,P2)={tv:.4f}; in proved region: {region}"
                   + (f"; bound al_r/(1-al_r) = {al_mp/(1-al_mp):.4f}" if True else ""))
text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")

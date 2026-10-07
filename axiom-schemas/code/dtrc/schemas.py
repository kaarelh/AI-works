"""Target axioms and schemas (as DT° templates) and instance constructors."""
from .syntax import parse, plug, canon_params, pp, ZERO, num
from .templates import instantiate, match

# ------------------------------------------------------------------------------------------- PA
Q_AXIOMS = {
    'Q1': 'forall x. ~Sx=0',
    'Q2': 'forall x. forall y. (Sx=Sy -> x=y)',
    'Q3': 'forall x. (~x=0 -> exists y. x=Sy)',
    'Q4': 'forall x. x+0=x',
    'Q5': 'forall x. forall y. x+Sy=S(x+y)',
    'Q6': 'forall x. x*0=0',
    'Q7': 'forall x. forall y. x*Sy=x*y+x',
}
T_IND = parse('(?P(0) & forall x. (?P(x) -> ?P(Sx))) -> forall x. ?P(x)')
# universal axioms observed only through instances (term metavariable ?t)
U_AXIOMS = {
    'U_add0': parse('?t+0=?t'),        # x+0=x
    'U_mul0': parse('?t*0=0'),         # x*0=0
    'U_0add': parse('0+?t=?t'),        # 0+x=x (not an axiom of Q; provable in PA)
}


def Ind(body):
    """induction instance for a motive body with hole 0 = x (parameters allowed)"""
    return canon_params(instantiate(T_IND, {'P': body}))


# ------------------------------------------------------------------------------------------- ZF
ZF_AXIOMS = {
    'Ext': 'forall x. forall y. ((forall z. (z in x <-> z in y)) -> x=y)',
    'Pair': 'forall x. forall y. exists z. forall w. (w in z <-> (w=x | w=y))',
    'Union': 'forall x. exists y. forall z. (z in y <-> exists w. (w in x & z in w))',
    'Power': 'forall x. exists y. forall z. (z in y <-> forall w. (w in z -> w in x))',
    'Inf': 'exists x. ((exists e. (e in x & forall w. ~w in e)) & forall y. (y in x -> exists z. (z in x & '
           'forall w. (w in z <-> (w in y | w=y)))))',
    'Found': 'forall x. ((exists y. y in x) -> exists y. (y in x & forall z. (z in y -> ~z in x)))',
}
# Separation: Aa Eb Ax (x in b <-> x in a & phi(x, a))      (b not free in phi: automatic)
T_SEP = parse('forall a. exists b. forall x. (x in b <-> (x in a & ?P(x, a)))')
# Replacement with exists-unique spelled out; phi(x, y, a)
T_REP = parse('forall a. ((forall x. (x in a -> exists y. (?P(x, y, a) & forall z. (?P(x, z, a) -> z=y)))) '
              '-> exists b. forall y. (y in b <-> exists x. (x in a & ?P(x, y, a))))')
# epsilon-induction: Ax(Ay(y in x -> phi(y)) -> phi(x)) -> Ax phi(x)
T_EIND = parse('(forall x. ((forall y. (y in x -> ?P(y))) -> ?P(x))) -> forall x. ?P(x)')


def Sep(body):
    """body: holes 0 = x, 1 = a"""
    return canon_params(instantiate(T_SEP, {'P': body}))


def Rep(body):
    """body: holes 0 = x, 1 = y, 2 = a"""
    return canon_params(instantiate(T_REP, {'P': body}))


def EInd(body):
    return canon_params(instantiate(T_EIND, {'P': body}))


def axioms(d):
    return {k: parse(v) for k, v in d.items()}


def pa_targets():
    """name -> template (ground sentences are 0-metavariable templates)"""
    t = {k: v for k, v in axioms(Q_AXIOMS).items()}
    t['Ind'] = T_IND
    t.update(U_AXIOMS)
    return t


def zf_targets():
    t = {k: v for k, v in axioms(ZF_AXIOMS).items()}
    t['Sep'] = T_SEP
    t['Rep'] = T_REP
    t['EInd'] = T_EIND
    return t


def target_of(s, targets):
    """names of the targets of which s is an instance"""
    return [k for k, T in targets.items() if match(T, s) is not None]

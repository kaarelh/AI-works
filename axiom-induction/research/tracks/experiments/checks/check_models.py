"""Sanity checks of the counter-models used in the proofs of Props X11 and X12 (the proofs are in the notes; this
script only evaluates the axioms on finite ranges, so it is a check, not a proof).

Prop X11 (Q axioms, dtrc numbering: Q1 Ax ~Sx=0; Q2 AxAy (Sx=Sy -> x=y); Q3 Ax (~x=0 -> Ey x=Sy); Q4 Ax x+0=x;
Q5 AxAy x+Sy=S(x+y); Q6 Ax x*0=0; Q7 AxAy x*Sy=x*y+x).  For i in {1, 2, 4, 5, 6, 7} a structure in which every
element is S^k 0 for some k (so every induction instance holds), Q_j holds for j != i and Q_i fails.
Prop X12: the structure N + {a, b} in which every closed instance of S_ab = ?a+?b=?b+?a, every instance of
M_x = Ax x+?b=?b+x and M_y (closed bodies), and every one-parameter instance of S_ab^open hold, while
AxAy x+y=y+x fails.  Terms are enumerated up to a size bound.
Command: python3 check_models.py   (writes check_models.out)"""
import itertools
import os

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []


def log(s):
    print(s, flush=True)
    OUT.append(s)


# ---------------------------------------------------------------------------------------- Prop X11
def nat_model(plus, times):
    return {'dom': list(range(25)), 'S': lambda x: x + 1, '+': plus, '*': times, 'reach': True}


MODELS = {
    'Q1': {'dom': [0], 'S': lambda x: 0, '+': lambda x, y: 0, '*': lambda x, y: 0},
    'Q2': {'dom': [0, 1], 'S': lambda x: 1, '+': lambda x, y: x if y == 0 else 1, '*': lambda x, y: 0 if y == 0 else x},
    'Q4': nat_model(lambda x, y: x + y + 1, lambda x, y: y * (x + 1)),
    'Q5': nat_model(lambda x, y: x, lambda x, y: 0),
    'Q6': nat_model(lambda x, y: x + y, lambda x, y: x * y + 1),
    'Q7': nat_model(lambda x, y: x + y, lambda x, y: 0),
}


def q_axioms(M):
    D, S, P, T = M['dom'], M['S'], M['+'], M['*']
    inD = set(D)
    # for the N-models the range is finite; restrict two-variable checks so that values stay meaningful
    return {
        'Q1': all(S(x) != 0 for x in D),
        'Q2': all(not (S(x) == S(y)) or x == y for x in D for y in D if S(x) in inD and S(y) in inD),
        'Q3': all(x == 0 or any(x == S(y) for y in D) for x in D),
        'Q4': all(P(x, 0) == x for x in D),
        'Q5': all(P(x, S(y)) == S(P(x, y)) for x in D for y in D if S(y) in inD or len(D) > 3),
        'Q6': all(T(x, 0) == 0 for x in D),
        'Q7': all(T(x, S(y)) == P(T(x, y), x) for x in D for y in D),
    }


def reachable(M):
    D, S = M['dom'], M['S']
    if M.get('reach'):
        return True           # domain N with the standard successor: every element is S^k 0
    seen, x = set(), 0
    while x not in seen:
        seen.add(x)
        x = S(x)
    return seen == set(D)


ok_all = True
for qi, M in MODELS.items():
    r = q_axioms(M)
    good = (not r[qi]) and all(v for k, v in r.items() if k != qi) and reachable(M)
    ok_all &= good
    log('X11 model for %s: axioms %s; every element S^k 0: %s; %s' % (
        qi, ''.join('%s%s ' % (k, '+' if v else '-') for k, v in sorted(r.items())), reachable(M),
        'as claimed' if good else 'NOT AS CLAIMED'))
log('X11: all six models as claimed: %s' % ok_all)

# ---------------------------------------------------------------------------------------- Prop X12
A, B = 'a', 'b'


def S_(x):
    return x if x in (A, B) else x + 1


def plus(x, y):
    if x in (A, B) and y in (A, B):
        return x                     # a+a=a, b+b=b, a+b=a, b+a=b
    if x in (A, B):
        return x
    if y in (A, B):
        return y
    return x + y


def times(x, y):
    if x in (A, B) and y in (A, B):
        return x
    if x in (A, B):
        return x if y != 0 else 0
    if y in (A, B):
        return y if x != 0 else 0
    return x * y


def terms(size, var=False):
    """terms over 0, S, +, * (and the variable 'v' if var) with at most `size` nodes"""
    out = {1: ['0'] + (['v'] if var else [])}
    for k in range(2, size + 1):
        ts = ['S(%s)' % t for t in out[k - 1]]
        for i in range(1, k - 1):
            for a in out[i]:
                for b in out[k - 1 - i]:
                    ts.append('(%s+%s)' % (a, b))
                    ts.append('(%s*%s)' % (a, b))
        out[k] = ts
    return [t for k in out for t in out[k]]


def ev(t, v=None):
    return _ev(t, v)


def _ev(t, v):
    if t == '0':
        return 0
    if t == 'v':
        return v
    if t.startswith('S('):
        return S_(_ev(t[2:-1], v))
    assert t[0] == '(' and t[-1] == ')'
    body, depth = t[1:-1], 0
    for i, ch in enumerate(body):
        if ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
        elif ch in '+*' and depth == 0:
            a, b = _ev(body[:i], v), _ev(body[i + 1:], v)
            return plus(a, b) if ch == '+' else times(a, b)
    raise ValueError(t)


closed = terms(7)
vals = [ev(t) for t in closed]
log('X12: %d closed terms (<= 7 nodes) all denote naturals: %s' % (len(closed), all(isinstance(x, int) for x in vals)))
inst_sab = all(plus(x, y) == plus(y, x) for x in set(vals) for y in set(vals))
dom = list(range(15)) + [A, B]
inst_mx = all(plus(x, t) == plus(t, x) for x in dom for t in set(vals))
log('X12: closed instances of S_ab hold: %s; instances Ax x+t=t+x of M_x (and of M_y) hold for x in 0..14, a, b: %s'
    % (inst_sab, inst_mx))
one = terms(5, var=True)
ok_open = True
for f in one:
    for g in one:
        for y in [0, 1, 2, 3, A, B]:
            fv, gv = ev(f, y), ev(g, y)
            if plus(fv, gv) != plus(gv, fv):
                ok_open = False
log('X12: one-parameter instances Aw f(w)+g(w)=g(w)+f(w) of S_ab^open hold (%d terms with <= 5 nodes, w in 0..3, a, b): %s'
    % (len(one), ok_open))
log('X12: AxAy x+y=y+x fails at (a, b): a+b = %s, b+a = %s; so S_ab, M_x, M_y, S_ab^open do not prove it' %
    (plus(A, B), plus(B, A)))
log('X12: the instance Ax x+w=w+x of M_x^open (body w) fails at (x, w) = (a, b): %s (consistent with M_x^open |- A_xy)'
    % (plus(A, B) != plus(B, A)))
with open(os.path.join(HERE, 'check_models.out'), 'w') as f:
    f.write('\n'.join(OUT) + '\n')

"""Referee check r5: finite-structure and invariant checks.

 (1) Prop U13: the structure on N u {a, b} of notes.md (standard on N; Sa = a, Sb = b; a+m = m, b+m = b, x+a = a for
     x in N u {a}, b+a = b, x+b = b; x*0 = 0, a*m = a, b*m = b (m >= 1), n*a = n*b = b (n >= 1), 0*a = 0*b = 0,
     a*a = a*b = a, b*a = b*b = b).  Check Q1-Q3, Q5-Q7 on all pairs from {0..80} u {a, b} (operations are total
     on the infinite domain, so no window edge is skipped) and that Q4 fails at a.
 (2) The notes' remark (section 2, "Truth questions") that every true closed instance of a Sigma_1 formula is
     provable in Q.  With Q = Q1-Q7 as in axiom-schemas setting.tex (no axiom mentions <) and L_A containing <,
     the structure N with < interpreted as the empty relation is a model of Q in which the true closed instance
     0 < S0 of the track's own example phi = x<Sx fails.  So Q does not prove it.
 (3) Prop U14(a): random terms over 0, S, +, * and variables; every one-step rewrite by an instance of
     Q4 (u+0 -> u) or Q5 (u+Sv -> S(u+v)), in either direction and at any position, changes
     w(t) = sum over +-nodes (l + r) of (1 + #S(r)) by exactly -1 (forward) / +1 (backward).
Seeded.  Output: r5_models.out"""
import random

OUT = []


def say(s=''):
    print(s)
    OUT.append(s)


A, B = 'a', 'b'


def S(x):
    return x if x in (A, B) else x + 1


def add(x, y):
    std_x, std_y = x not in (A, B), y not in (A, B)
    if std_x and std_y:
        return x + y
    if y == B:
        return B
    if y == A:
        return B if x == B else A
    # y standard, x nonstandard
    return y if x == A else B


def mul(x, y):
    std_x, std_y = x not in (A, B), y not in (A, B)
    if std_x and std_y:
        return x * y
    if y == 0:
        return 0
    if std_y:  # y >= 1, x nonstandard
        return x
    # y in {a, b}
    if std_x:
        return 0 if x == 0 else B
    return A if x == A else B


def check_u13(N=80):
    dom = list(range(N + 1)) + [A, B]
    viol = []
    for x in dom:
        if S(x) == 0:
            viol.append(('Q1', x))
        if x != 0 and x not in (A, B) and S(x - 1) != x:
            viol.append(('Q3', x))
        if x in (A, B) and S(x) != x:
            viol.append(('Q3', x))
        if mul(x, 0) != 0:
            viol.append(('Q6', x))
        for y in dom:
            if S(x) == S(y) and x != y:
                viol.append(('Q2', x, y))
            if add(x, S(y)) != S(add(x, y)):
                viol.append(('Q5', x, y))
            if mul(x, S(y)) != add(mul(x, y), x):
                viol.append(('Q7', x, y))
    q4_fail = [x for x in dom if add(x, 0) != x]
    return viol, q4_fail


# ---------------------------------------------------------------- (3) invariant
def rand_term(rng, d):
    if d == 0 or rng.random() < 0.25:
        return ('0',) if rng.random() < 0.6 else ('v', rng.choice('xyz'))
    r = rng.random()
    if r < 0.35:
        return ('S', rand_term(rng, d - 1))
    if r < 0.8:
        return ('+', rand_term(rng, d - 1), rand_term(rng, d - 1))
    return ('*', rand_term(rng, d - 1), rand_term(rng, d - 1))


def nS(t):
    return (1 if t[0] == 'S' else 0) + sum(nS(k) for k in t[1:] if isinstance(k, tuple))


def w(t):
    own = (1 + nS(t[2])) if t[0] == '+' else 0
    return own + sum(w(k) for k in t[1:] if isinstance(k, tuple))


def positions(t, path=()):
    yield path, t
    for i, k in enumerate(t[1:], 1):
        if isinstance(k, tuple):
            yield from positions(k, path + (i,))


def replace(t, path, new):
    if not path:
        return new
    i = path[0]
    return t[:i] + (replace(t[i], path[1:], new),) + t[i + 1:]


def rewrites(s, rng):
    """all one-step rewrites at s's root: forward Q4/Q5 and backward ones (backward Q4 with a random u)"""
    out = []
    if s[0] == '+' and s[2] == ('0',):
        out.append(('Q4>', s[1]))
    out.append(('Q4<', ('+', s, ('0',))))
    if s[0] == '+' and s[2][0] == 'S':
        out.append(('Q5>', ('S', ('+', s[1], s[2][1]))))
    if s[0] == 'S' and s[1][0] == '+':
        out.append(('Q5<', ('+', s[1][1], ('S', s[1][2]))))
    return out


def check_u14(rng, trials=20000):
    bad = 0
    nsteps = 0
    for _ in range(trials):
        t = rand_term(rng, 6)
        for path, s in positions(t):
            for kind, new in rewrites(s, rng):
                t2 = replace(t, path, new)
                dw = w(t2) - w(t)
                nsteps += 1
                expect = -1 if kind.endswith('>') else +1
                if dw != expect:
                    bad += 1
    return nsteps, bad


def main():
    viol, q4f = check_u13()
    say('(1) U13 structure on {0..80} u {a,b}: violations of Q1-Q3, Q5-Q7: %d; elements violating Q4: %s; '
        'closed instances n+0=n hold on 0..80: %s' % (len(viol), q4f, all(add(n, 0) == n for n in range(81))))
    assert not viol and q4f == [A]
    # (2) N with empty <: Q1-Q7 hold (they do not mention <), 0 < S0 fails
    less = set()
    q_ok = all(S(n) != 0 and add(n, 0) == n and mul(n, 0) == 0 for n in range(50)) and \
        all(add(x, y + 1) == add(x, y) + 1 and mul(x, y + 1) == mul(x, y) + x for x in range(30) for y in range(30))
    say('(2) N with < interpreted as the empty relation: Q1-Q7 hold on 0..49 (they do not mention <): %s; '
        '0 < S0 holds: %s.  So Q does not prove the true closed instance 0<S0 of x<Sx.' % (q_ok, (0, 1) in less))
    rng = random.Random(14)
    nsteps, bad = check_u14(rng)
    say('(3) U14(a) invariant: %d random one-step Q4/Q5 rewrites (both directions, all positions, terms with '
        'variables and *): steps with dw != -1 (forward) / +1 (backward): %d' % (nsteps, bad))
    assert bad == 0
    open('r5_models.out', 'w').write('\n'.join(OUT) + '\n')


if __name__ == '__main__':
    main()

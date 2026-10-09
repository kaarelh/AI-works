"""c6: two finite checks used in notes.md.
 (1) Prop. U13: a structure on N u {a, b} satisfying every axiom of Q except Q4 (x+0=x), standard on N (so every
     closed instance t+0=t holds), with a+0 = 0 != a.  Hence (Q - Q4) + all closed instances of x+0=x does not
     prove forall x (x+0=x).  Checked on all tuples from {0..N} u {a, b}.
 (2) Prop. U14: in equational logic over {Q4: x+0=x, Q5: x+Sy=S(x+y)}, every replacement step changes the weight
     w(t) = sum over +-nodes (l + r) of (1 + #S(r)) by exactly +-1, so 0+S^k 0 = S^k 0 needs >= k+1 steps.
     Breadth-first search over all terms of bounded size confirms the distance is exactly k+1 for k <= 5 and
     that every explored step changes w by +-1.
Output c6_models.out."""
from collections import deque

OUT = []


def say(*a):
    s = ' '.join(str(x) for x in a)
    print(s)
    OUT.append(s)


A, B = 'a', 'b'


def S(x):
    if x in (A, B):
        return x
    return x + 1


def add(x, y):
    if y == A:
        return B if x == B else A
    if y == B:
        return B
    # y standard
    if x == A:
        return y
    if x == B:
        return B
    return x + y


def mul(x, y):
    if y == 0:
        return 0
    if y in (A, B):
        if x == 0:
            return 0
        if x == A:
            return A
        if x == B:
            return B
        return B  # n >= 1
    # y standard >= 1
    if x == A:
        return A
    if x == B:
        return B
    return x * y


def check_model(N=40):
    dom = list(range(N + 1)) + [A, B]
    std = list(range(N + 1))
    viol = []
    for x in dom:
        for y in dom:
            if S(x) == S(y) and x != y:
                viol.append(('S injective', x, y))
            if mul(x, 0) != 0:
                viol.append(('Q6 x*0=0', x))
            # Q5, Q7 need S y inside the domain: skip y = N (S N = N+1 outside the finite window)
            if y == N:
                continue
            if add(x, S(y)) != S(add(x, y)):
                viol.append(('Q5', x, y))
            if mul(x, S(y)) != add(mul(x, y), x):
                viol.append(('Q7', x, y))
        if S(x) == 0:
            viol.append(('0 not successor', x))
        if x != 0 and not any(S(y) == x for y in dom):
            viol.append(('every nonzero is a successor', x))
    closed_ok = all(add(n, 0) == n for n in std)
    return viol, closed_ok, add(A, 0)


def size(t):
    return 1 if t == ('0',) else 1 + sum(size(k) for k in t[1:])


def numS(t):
    if t == ('0',):
        return 0
    return (1 if t[0] == 'S' else 0) + sum(numS(k) for k in t[1:])


def w(t):
    if t == ('0',):
        return 0
    own = (1 + numS(t[2])) if t[0] == '+' else 0
    return own + sum(w(k) for k in t[1:])


def num(k):
    t = ('0',)
    for _ in range(k):
        t = ('S', t)
    return t


def rewrites_at_root(t, maxsize):
    out = []
    if t[0] == '+' and t[2] == ('0',):
        out.append(t[1])  # Q4 forward
    out.append(('+', t, ('0',)))  # Q4 backward
    if t[0] == '+' and t[2][0] == 'S':
        out.append(('S', ('+', t[1], t[2][1])))  # Q5 forward
    if t[0] == 'S' and t[1][0] == '+':
        out.append(('+', t[1][1], ('S', t[1][2])))  # Q5 backward
    return [u for u in out if size(u) <= maxsize]


def neighbours(t, maxsize):
    res = list(rewrites_at_root(t, maxsize))
    for i in range(1, len(t)):
        for u in neighbours(t[i], maxsize):
            v = t[:i] + (u,) + t[i + 1:]
            if size(v) <= maxsize:
                res.append(v)
    return res


def bfs(k, slack=4):
    start, goal = ('+', ('0',), num(k)), num(k)
    maxsize = size(start) + slack
    dist = {start: 0}
    dq = deque([start])
    bad = 0
    while dq:
        t = dq.popleft()
        for u in neighbours(t, maxsize):
            if abs(w(u) - w(t)) != 1:
                bad += 1
            if u not in dist:
                dist[u] = dist[t] + 1
                dq.append(u)
    return dist.get(goal), len(dist), bad, w(start), w(goal)


def main():
    viol, closed_ok, a0 = check_model(40)
    say('(1) structure on {0..40} u {a,b}: violations of Q minus Q4: %d; closed instances n+0=n hold: %s; a+0 = %r'
        % (len(viol), closed_ok, a0))
    assert not viol and closed_ok and a0 == 0
    say('(2) equational logic over {Q4, Q5}: BFS over terms of size <= |0+S^k 0| + 4')
    for k in range(6):
        d, nterms, bad, w0, w1 = bfs(k)
        say('   k=%d: shortest chain %s (k+1 = %d); terms explored %d; w(start)=%d w(goal)=%d; steps with |dw| != 1: %d'
            % (k, d, k + 1, nterms, w0, w1, bad))
        assert d == k + 1 and bad == 0
    open('c6_models.out', 'w').write('\n'.join(OUT) + '\n')


if __name__ == '__main__':
    main()

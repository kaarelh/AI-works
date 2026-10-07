# e16 (revision): the untagged lower bound of Cor F.4 over the arithmetic signature (encoding step asked by
# the referee).  Queries q_a = (S^{a_1}0 + (... + S^{a_k}0)) = 0, a in {0..n}^k, by non-increasing sum(a);
# target (x_1 + ... + x_k) = 0 in DT°.  Each q_a must lie outside the cautious H_k(DT°) acceptance set of
# its predecessors: checked (i) by the explicit k-union of first-order DT° templates
# (... + S^{a_j+1}(x_j) + ...) = 0 that covers the predecessors and misses q_a, and (ii) by the brute-force
# union verifier of Prop F.6.
import itertools
from dtcore import *
from dtunion import acc_union_bf


def nest(k, t):
    for _ in range(k):
        t = S(t)
    return t


def plus(ts):
    t = ts[-1]
    for u in reversed(ts[:-1]):
        t = add(u, t)
    return t


for k, n1 in [(1, 6), (2, 3), (2, 4), (3, 2)]:
    vecs = sorted(itertools.product(range(n1), repeat=k), key=lambda a: -sum(a))
    qs = [eq(plus([nest(a_j, Z) for a_j in a]), Z) for a in vecs]
    N = max(size(q) for q in qs)
    target = eq(plus([M('x%d' % j) for j in range(k)]), Z)
    honest = all(det_match(target, q) is not None for q in qs)
    ok_explicit = ok_bf = True
    for i in range(1, len(qs)):
        a = vecs[i]
        Ts = [eq(plus([nest(a[j] + 1, M('x%d' % j)) if j == jj else M('x%d' % j) for j in range(k)]), Z)
              for jj in range(k)]
        ok_explicit &= all(is_DT0(T) for T in Ts)
        ok_explicit &= all(any(det_match(T, p) is not None for T in Ts) for p in qs[:i])
        ok_explicit &= all(det_match(T, qs[i]) is None for T in Ts)
        if i <= 12:
            ok_bf &= not acc_union_bf(qs[:i], qs[i], k)
    print('k=%d n+1=%d: %d escalations on sentences of size <= N=%d; (floor((N-1)/k)-1)^k = %d; honest %s; '
          'explicit witnesses %s; brute-force verifier (first 12 steps) %s'
          % (k, n1, len(qs), N, ((N - 1) // k - 1) ** k, honest, ok_explicit, ok_bf))

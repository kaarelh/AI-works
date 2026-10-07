# e12 (revision): prior conjecture C11 (escalations linear in the first escalated datum) is FALSE in DT°,
# for the universal template and for the PA-induction target; the quadratic bound of Thm F is tight.
# Chain (Prop F.8): d1 = A^b(0=0 & ... & 0=0) (m atoms), d2 = same with every lhs := a, then q_{j,k} = d1 with
# the j-th lhs := the k-th bound variable, j <= m, k < b.  For Ind: the same sentences as motives.
# Every escalation is certified twice: (i) the feature verifier (Thm C) rejects q, and (ii) independently of
# Thm C's hard direction, the explicit covering template T_0(predecessors) (in DT°, covers them) misses q.
from dtcore import *
from dtfeat import Prefix


def conj(fs):
    f = fs[-1]
    for g in reversed(fs[:-1]):
        f = AND(g, f)
    return f


def sentence(lhs, b):
    f = conj([eq(l, Z) for l in lhs])
    for _ in range(b):
        f = ALL(f)
    return f


def chain(m, b, wrap):
    out = [wrap(sentence([Z] * m, b)), wrap(sentence([PA] * m, b))]
    for j in range(m):
        for k in range(b):
            lhs = [Z] * m
            lhs[j] = V(k)
            out.append(wrap(sentence(lhs, b)))
    return out


def certify(ch):
    ok = ch[1] != ch[0]
    for i in range(2, len(ch)):
        pred = ch[:i]
        P = Prefix(pred)
        T0 = P.T0()
        ok &= (not P.accepts(ch[i])) and is_DT0(T0) and covers_all(T0, pred) and det_match(T0, ch[i]) is None
    return ok


def ind_wrap(s):
    # motive body: the sentence itself (x does not occur), so Ind(s) is an instance of T_ind
    return Ind(s)


print('universal template (0-ary formula metavariable), general N with m = floor((N+1)/5):')
for N in [4, 5, 9, 14, 19, 23, 24, 29, 34]:
    m = (N + 1) // 5
    ch = chain(m, m, lambda s: s)
    mx = max(size(s) for s in ch)
    print('  N=%2d m=%d: %d escalations (= 2 + m^2 = %d), max size %d <= N: %s, all certified: %s'
          % (N, m, len(ch), 2 + m * m, mx, mx <= N, certify(ch)))
print('PA-induction target (honest: every query is an instance of T_ind):')
for m in [2, 3, 4, 5]:
    ch = chain(m, m, ind_wrap)
    honest = all(det_match(T_IND, s) is not None for s in ch)
    n1 = size(ch[0])
    print('  m=b=%d: first datum size n=%d, escalations after it %d = 1 + m^2 (n = 20m+1, so ~ n^2/400); '
          'honest %s, all certified %s' % (m, n1, len(ch) - 1, honest, certify(ch)))

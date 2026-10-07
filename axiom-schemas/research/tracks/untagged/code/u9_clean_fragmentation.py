# u9: Theorem 5.4(d) on CLEAN data (referee U6): fragmentation without any mistaken datum, caused by a sound
# (truth-sound, target-unsound) cross merge.  Also the cautious k-union learner (k = k') with self-generated
# negatives (Lemma 1.2 finite form) on the same data, for comparison (Remark 5.3).
#  Example A (referee): sigma1 = (t+0=t), sigma2 = (0+t=t); D1 = {0+0=0, S0+0=S0} (an anchor of sigma1),
#             D2 = {0+S0=S0, 0+SS0=SS0, 0+(0+0)=0+0}.  (0+0=0 lies in both instance sets.)
#  Example B (disjoint instance sets): sigma1 = (t+0=t), ground target g = (0+S0=S0); D1 = {0+0=0, S0+0=S0}.
import sys, itertools
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
from dtlib import *
from dtrc import World, DTRC

W = World('arith', B=3, budget=1500)
a = eq(add(Z, Z), Z); b = eq(add(S(Z), Z), S(Z))
c1 = eq(add(Z, S(Z)), S(Z)); c2 = eq(add(Z, S(S(Z))), S(S(Z))); c3 = eq(add(Z, add(Z, Z)), add(Z, Z))
qa = eq(add(P('a1'), Z), P('a1'))          # the universal axiom forall x (x+0 = x), closure-normal form
qb = eq(add(Z, P('a1')), P('a1'))          # forall x (0+x = x): true, but not a target in example B

def partitions(xs, k):
    if not xs:
        yield []; return
    first, rest = xs[0], xs[1:]
    for p in partitions(rest, k):
        for i in range(len(p)):
            yield p[:i] + [[first] + p[i]] + p[i + 1:]
        if len(p) < k: yield [[first]] + p

def acc_k(D, k, q):
    """Lemma 1.2: q in Acc_k(D, N) iff q lies in the union for every partition into <= k blocks and every choice of
    unrefuted minimal templates; N = the world's negatives (self-generated: refuted instances of minimal templates)."""
    for p in partitions(list(D), k):
        choices = []
        for B in p:
            Ts = [T for T in mincov(B) if W.refute_template(T) is None]
            if not Ts: break
            choices.append(Ts)
        else:
            for combo in itertools.product(*choices):
                if not any(covers(T, q) for T in combo): return False
    return True

def show(name, orders, D, k):
    print('==', name)
    for order in orders:
        A = DTRC(W); A.run(order)
        print('  DTRC order', [pp(x) for x in order])
        for C, Ts in zip(A.clusters, A.templates):
            print('     cluster', sorted(pp(x) for x in C), '->', [pp(T) for T in Ts])
        print('     accepts a1+0=a1 (target sigma1 universal): %s   accepts 0+a1=a1 (true, sigma2 / non-target): %s'
              % (A.accepts(qa), A.accepts(qb)))
    print('  cautious %d-union learner with self-generated negatives (order-independent):' % k)
    print('     accepts a1+0=a1: %s   accepts 0+a1=a1: %s   accepts SS0+0=SS0: %s'
          % (acc_k(D, k, qa), acc_k(D, k, qb), acc_k(D, k, eq(add(S(S(Z)), Z), S(S(Z))))))

show('Example A (referee): sigma1 = t+0=t, sigma2 = 0+t=t',
     ([a, b, c1, c2, c3], [c1, a, b, c2, c3], [c1, c2, c3, a, b]), [a, b, c1, c2, c3], 2)
g = c1
show('Example B (disjoint instance sets): sigma1 = t+0=t, ground target g = 0+S0=S0',
     ([a, b, g], [g, a, b], [b, g, a]), [a, b, g], 2)
print('negatives found by the world:', [pp(n) for n, _ in W.neg])

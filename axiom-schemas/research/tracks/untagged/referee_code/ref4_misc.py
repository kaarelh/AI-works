# Referee check 4: (a) fragmentation WITHOUT noise (clean data, no separation): Theorem 5.4(d) cites only a noisy example.
# (b) failure family of a one-variable arithmetic pattern after parameter canonicalization: 5 head classes cover inst.
import sys
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code'); sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/referee_code')
from dtlib import *
from dtrc import World, DTRC
W = World('arith', B=3, budget=1500)
# targets: sigma1 = (t+0=t) [Q3 instance schema], sigma2 = (0+t=t) [theorem 0+x=x as instance schema]
# clean data: D1 = {0+0=0, S0+0=S0} (anchor for sigma1: heads 0, S), D2 = {0+S0=S0, 0+SS0=SS0, 0+(0+0)=(0+0)}
a = eq(add(Z, Z), Z); b = eq(add(S(Z), Z), S(Z))
c1 = eq(add(Z, S(Z)), S(Z)); c2 = eq(add(Z, S(S(Z))), S(S(Z))); c3 = eq(add(Z, add(Z, Z)), add(Z, Z))
s1 = eq(add(M('t0'), Z), M('t0')); s2 = eq(add(Z, M('t0')), M('t0'))
for order in ([a, b, c1, c2, c3], [c1, a, b, c2, c3], [c1, c2, c3, a, b]):
    A = DTRC(W); A.run(order)
    print('order', [pp(x) for x in order])
    for C, Ts in zip(A.clusters, A.templates):
        print('   cluster', sorted(pp(x) for x in C), '->', [pp(T) for T in Ts])
    # is sigma1 learned exactly? query (a1+0)=a1 and (SS0+0)=SS0
    print('   accepts (a1+0)=a1:', A.accepts(eq(add(P('a1'), Z), P('a1'))), ' accepts (0+a1)=a1:', A.accepts(eq(add(Z, P('a1')), P('a1'))))
print()
# (b) failure sets of phi(z) = (z+0 = z) by head of z after canonicalization: 0, S, +, *, parameter
phi = s1
fails = [instantiate(phi, {'t0': Z}), instantiate(phi, {'t0': S(M('u'))}), instantiate(phi, {'t0': add(M('u'), M('w'))}),
         instantiate(phi, {'t0': mul(M('u'), M('w'))}), instantiate(phi, {'t0': P('a1')})]
import random
rng = random.Random(0)
from practice import rand_closed
miss = 0
for _ in range(500):
    t = rand_closed(rng, 3) if rng.random() < .8 else P('a%d' % rng.randint(1, 5))
    q = canon_params(instantiate(phi, {'t0': t}))
    if not any(covers(F, q) for F in fails): miss += 1
print('instances of z+0=z (canonicalized) not covered by the 5 head-class failure templates:', miss, '/ 500')

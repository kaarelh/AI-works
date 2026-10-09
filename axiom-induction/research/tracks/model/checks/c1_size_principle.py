"""c1: the size principle under L0 (notes, Lemma 1.6 and Example 1.7).

T*  = {z + 0 = z}        P*(t+0=t)   = Q(t)
T'  = {z1 + 0 = z2}      P'(t+0=u)   = Q(t) Q(u)       (over-general)
eps = P'(outside supp P*) = 1 - sum_t Q(t)^2
Lemma: KL(P*||P') = KL(P*||P'(.|supp P*)) + log 1/(1-eps)  (exact decomposition).
Here KL(P*||P') = H(Q) (entropy of Q in nats).
Also simulate: (1/n) log P*(D)/P'(D) -> KL.
"""
import math
import random
from terms import enumerate_terms, q_prob, sample_term, mean_children

P = {'0': 0.5, 'S': 0.3, '+': 0.1, '*': 0.1}
MAXN = 11

out = []
out.append(f"PCFG p = {P}; mean children = {mean_children(P):.3f} (<1: subcritical)")
terms = [t for n, ts in enumerate_terms(MAXN).items() for t in ts]
qs = [q_prob(t, P) for t in terms]
mass = sum(qs)
out.append(f"terms of size <= {MAXN}: {len(terms)}, covered Q-mass = {mass:.6f}")
# renormalise the truncation so the identities are exact on the truncated space
qs = [q / mass for q in qs]
sum_q2 = sum(q * q for q in qs)
eps = 1 - sum_q2
H = -sum(q * math.log(q) for q in qs)
# KL(P*||P') directly: sum_t Q(t) log(Q(t) / (Q(t) Q(t))) = sum Q log 1/Q = H
kl_direct = sum(q * math.log(q / (q * q)) for q in qs)
# P'(.|supp P*) on t+0=t is Q(t)^2/(1-eps)
kl_cond = sum(q * math.log(q / (q * q / (1 - eps))) for q in qs)
out.append(f"eps = {eps:.6f}; log 1/(1-eps) = {math.log(1/(1-eps)):.6f}")
out.append(f"KL direct = {kl_direct:.6f}; H(Q) = {H:.6f}")
out.append(f"KL(P*||P'(.|supp)) + log 1/(1-eps) = {kl_cond + math.log(1/(1-eps)):.6f}  (should equal KL direct)")
assert abs(kl_direct - (kl_cond + math.log(1/(1-eps)))) < 1e-9
assert abs(kl_direct - H) < 1e-9

# simulation with the untruncated PCFG
rng = random.Random(1)
true_H = None
for n in (100, 1000, 10000):
    s = 0.0
    for _ in range(n):
        t = sample_term(P, rng)
        q = q_prob(t, P)
        s += math.log(q / (q * q))
    out.append(f"n = {n:6d}: (1/n) log P*(D)/P'(D) = {s/n:.4f}")
# exact entropy of the untruncated PCFG: E[#nodes] * H(root law), E[#nodes] = 1/(1-m)
Hp = -sum(v * math.log(v) for v in P.values())
H_exact = Hp / (1 - mean_children(P))
out.append(f"exact H(Q) of the untruncated PCFG = E[#nodes] H(p) = {H_exact:.4f} nats (the simulation estimates this; "
           f"the truncated H = {H:.4f} misses the heavy tail, truncated mass {1-mass:.2e})")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")

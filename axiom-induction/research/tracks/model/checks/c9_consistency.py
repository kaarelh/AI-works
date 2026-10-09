"""c9: posterior concentration on the generator class (notes, Thm 2.1, Cor 2.3, Prop 2.6), L0 with fixed weights.

Class: T* = {z+0=z};  T_split = the root split of T* (weights p_f; same generator as T*);
T_over = {z1+0=z2};  T_miss = T*'s split without the '*' root (weights renormalised; support misses (t1*t2)+0=t1*t2);
T_spare = T* plus the disjoint ground template 0 = S0 with weight 0.05.
Prior: 0.2 each.  Data i.i.d. from P_T*.
Expected: pi_n(T*)/pi_n(T_split) = 1 for all n (same likelihood); the other three -> 0
(T_over and T_spare exponentially, T_miss at the first '*'-rooted datum).
"""
import math
import random
from terms import sample_term, q_prob

P = {'0': 0.5, 'S': 0.3, '+': 0.1, '*': 0.1}
out = []
for seed in (21, 22, 23):
    rng = random.Random(seed)
    names = ['T*', 'T_split', 'T_over', 'T_miss', 'T_spare']
    logp = {k: math.log(0.2) for k in names}
    report = {}
    for n in range(1, 2001):
        t = sample_term(P, rng)
        q = q_prob(t, P)
        logp['T*'] += math.log(q)
        logp['T_split'] += math.log(P[t[0]] * q / P[t[0]])        # w_f * Q_{tau_f}(s) = p_f * Q(t)/p_f
        logp['T_over'] += math.log(q * q)
        logp['T_miss'] += (math.log(q / (1 - P['*'])) if t[0] != '*' else -math.inf)
        logp['T_spare'] += math.log(0.95 * q)
        if n in (10, 100, 1000, 2000):
            mx = max(logp.values())
            z = sum(math.exp(v - mx) for v in logp.values() if v > -math.inf)
            report[n] = {k: (math.exp(v - mx) / z if v > -math.inf else 0.0) for k, v in logp.items()}
    for n, post in report.items():
        out.append(f"seed {seed} n={n:5d}: " + ", ".join(f"{k}={v:.4f}" for k, v in post.items()))
text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")

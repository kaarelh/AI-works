"""c9b: c9 redone with genuine template matching (referee issue m5).

c9 coded T_split's log-likelihood as log(P[root] * q / P[root]), i.e. identical to T*'s by construction, so its check of
Corollary 2.2 was tautological.  Here every hypothesis's likelihood of a datum s = (t + 0 = t) is computed by first-order
matching of s against each of its templates, P_T(s) = sum_tau w_tau * prod_{metavariables} Q(theta(M)), with no algebra.
Class (prior 0.2 each): T* = {z+0=z}; T_split = {f(z1..zk)+0=f(z1..zk) : f in {0,S,+,*}} with weights p_f;
T_over = {z1+0=z2}; T_miss = T_split without the '*' template (weights renormalised); T_spare = T* plus the ground
template 0 = S0 with weight 0.05.  Data i.i.d. from P_T*, three seeds, n up to 2000.
"""
import math
import random
from terms import sample_term, q_prob, ARITY

P = {'0': 0.5, 'S': 0.3, '+': 0.1, '*': 0.1}


def match(pattern, s, theta):
    if pattern[0] == '?':
        name = pattern[1]
        if name in theta:
            return theta[name] == s
        theta[name] = s
        return True
    if pattern[0] != s[0] or len(pattern) != len(s):
        return False
    return all(match(a, b, theta) for a, b in zip(pattern[1:], s[1:]))


def eq(l, r):
    return ('=', l, r)


def plus0(t):
    return ('+', t, ('0',))


def lik(theory, s):
    tot = 0.0
    for w, tmpl in theory:
        th = {}
        if match(tmpl, s, th):
            r = 1.0
            for v in th.values():
                r *= q_prob(v, P)
            tot += w * r
    return tot


z = ('?', 'z')
TSTAR = [(1.0, eq(plus0(z), z))]
SPLIT = []
for f in P:
    head = (f,) + tuple(('?', f'z{j}') for j in range(ARITY[f]))
    SPLIT.append((P[f], eq(plus0(head), head)))
OVER = [(1.0, eq(plus0(('?', 'z1')), ('?', 'z2')))]
MISS = [(w / (1 - P['*']), tm) for w, tm in SPLIT if tm[1][1][0] != '*']
SPARE = [(0.95, eq(plus0(z), z)), (0.05, eq(('0',), ('S', ('0',))))]
H = {'T*': TSTAR, 'T_split': SPLIT, 'T_over': OVER, 'T_miss': MISS, 'T_spare': SPARE}

out = []
maxgap = 0.0
for seed in (21, 22, 23):
    rng = random.Random(seed)
    logp = {k: math.log(0.2) for k in H}
    died = {}
    for n in range(1, 2001):
        t = sample_term(P, rng)
        s = eq(plus0(t), t)
        for k, T in H.items():
            if logp[k] > -math.inf:
                v = lik(T, s)
                logp[k] = logp[k] + math.log(v) if v > 0 else -math.inf
                if logp[k] == -math.inf:
                    died.setdefault(k, n)
        maxgap = max(maxgap, abs(logp['T*'] - logp['T_split']))
        if n in (10, 100, 1000, 2000):
            mx = max(logp.values())
            zz = sum(math.exp(v - mx) for v in logp.values() if v > -math.inf)
            post = {k: (math.exp(v - mx) / zz if v > -math.inf else 0.0) for k, v in logp.items()}
            out.append(f"seed {seed} n={n:5d}: " + ", ".join(f"{k}={v:.3e}" for k, v in post.items()))
    out.append(f"seed {seed}: likelihood exactly 0 from datum: {died}  (T_over is never exactly 0; it decays by Q(t) per datum)")
out.append(f"max over all seeds and n of |log-lik(T*) - log-lik(T_split)| = {maxgap:.2e} (float rounding only)")
text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")

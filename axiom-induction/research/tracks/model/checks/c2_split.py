"""c2: split equivalence under L0 and the Dirichlet (Occam) comparison (notes, Prop 2.6 and Prop 5.4).

Part A. tau = z + 0 = z with z a 0-ary term metavariable, Q a PCFG on closed terms with root law p.
The split T' = { f(z1..zk) + 0 = f(z1..zk) : f in {0,S,+,*} } with weights p_f has P_T' = P_T exactly.
We check this by first-order matching on every enumerated instance (not by the algebra).

Part B. Dirichlet(1/2) weights on the split; data t_i i.i.d. with root law r and children from Q.
Delta_n := log P^Dir_T'(D) - log P_T(D) = log DirMult(n_f; 1/2) - sum_f n_f log p_f  (depends only on root counts).
Prediction (Stirling): Delta_n = n KL(rhat||p) - (K-1)/2 log n + log Gamma(K/2) - (K/2) log pi + (K-1)/2 log(2 pi) + o(1);
well specified (r = p): E Delta_n ~ -(3/2) log n + 0.467 + 3/2;  misspecified: ~ n KL(r||p) - (3/2) log n.
"""
import math
import random
from scipy.special import gammaln
import numpy as np
from terms import enumerate_terms, q_prob, ARITY

P = {'0': 0.5, 'S': 0.3, '+': 0.1, '*': 0.1}
out = []

# ---------------- Part A: genuine matching check ----------------
def match(pattern, s, theta):
    """First-order matching; pattern leaves ('?', name) are metavariables."""
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

z = ('?', 'z')
tau = eq(plus0(z), z)
split = {}
for f in P:
    args = tuple(('?', f'z{j}') for j in range(ARITY[f]))
    head = (f,) + args
    split[f] = eq(plus0(head), head)

def q_tau(template, s):
    theta = {}
    if not match(template, s, theta):
        return 0.0
    r = 1.0
    for v in theta.values():
        r *= q_prob(v, P)
    return r

terms = [t for n, ts in enumerate_terms(9).items() for t in ts]
maxdiff = 0.0
norm_tau = 0.0
norm_split = {f: 0.0 for f in P}
for t in terms:
    s = eq(plus0(t), t)
    a = q_tau(tau, s)
    b = sum(P[f] * q_tau(split[f], s) for f in P)
    maxdiff = max(maxdiff, abs(a - b))
    norm_tau += a
# normalisation of each split template: sum over its instances of Q(children)
for f in P:
    for t in terms:
        if t[0] == f:
            norm_split[f] += q_tau(split[f], eq(plus0(t), t))
out.append("Part A: P_T vs P_T' on all instances t+0=t with |t| <= 9 "
           f"({len(terms)} terms): max |difference| = {maxdiff:.3e}")
out.append(f"  covered mass of P_T: {norm_tau:.6f}; covered mass of each split template Q_tau_f: "
           + ", ".join(f"{f}: {v:.4f}" for f, v in norm_split.items())
           + "  (each -> 1 as the size bound grows; truncation only)")
assert maxdiff < 1e-15

# ---------------- Part B: Dirichlet comparison ----------------
K = 4
pvec = np.array([P[f] for f in ('0', 'S', '+', '*')])

def delta(counts, alpha=0.5):
    n = counts.sum()
    ldm = gammaln(K * alpha) - gammaln(K * alpha + n) + np.sum(gammaln(alpha + counts) - gammaln(alpha))
    return ldm - np.sum(counts * np.log(pvec))

const = gammaln(K / 2) - (K / 2) * math.log(math.pi) + (K - 1) / 2 * math.log(2 * math.pi)
rng = np.random.default_rng(2)
for label, r in (("well specified r = p", pvec),
                 ("misspecified r = (.4,.3,.2,.1)", np.array([0.4, 0.3, 0.2, 0.1]))):
    kl = float(np.sum(r * np.log(r / pvec)))
    out.append(f"Part B, {label}: KL(r||p) = {kl:.4f} nats")
    for n in (100, 1000, 10_000, 100_000, 1_000_000):
        vals = []
        for _ in range(400):
            c = rng.multinomial(n, r)
            vals.append(delta(c.astype(float)))
        vals = np.array(vals)
        pred = n * kl - (K - 1) / 2 * math.log(n) + const + ((K - 1) / 2 if kl == 0 else 0.0)
        out.append(f"  n = {n:8d}: mean Delta = {vals.mean():12.3f} (sd {vals.std():8.3f});"
                   f"  prediction {pred:12.3f};  P(Delta > 0) = {np.mean(vals > 0):.3f}")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")

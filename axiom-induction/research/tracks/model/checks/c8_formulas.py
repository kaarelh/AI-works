"""c8: small formula checks (notes, Def 1.4 L0-Dirichlet formula, Lemma 1.5 branching process).

(1) Dirichlet-integrated L0 with overlapping templates: the labelling-sum closed form equals Monte Carlo integration.
    tau1 = z + 0 = z (Q over terms), tau2 = 0 + 0 = 0 (ground; its only instance is also an instance of tau1),
    tau3 = z1 = z1 + 0 ... we keep two templates.  Data: n0 copies of 0+0=0 and the list of other instances t+0=t.
(2) Derivation-grammar branching process: E[#nodes] = 1/(1-m) for m = 2 al_mp + al_gen + al_inst < 1;
    for m = 1 the tree is finite a.s. but E[#nodes] = infinity; for m > 1 it is infinite with prob 1 - q, q the
    smallest root of G(q) = q.
"""
import math
import random
import itertools
import numpy as np
from scipy.special import gammaln
from terms import q_prob

out = []
P = {'0': 0.5, 'S': 0.3, '+': 0.1, '*': 0.1}

# (1)
alpha = np.array([0.5, 0.5])
S0 = ('S', ('0',))
others = [S0, ('S', S0), ('+', ('0',), ('0',))]       # data t+0=t with t != 0
n0 = 3                                                # three copies of 0+0=0
q1_others = [q_prob(t, P) for t in others]
q1_zero = q_prob(('0',), P)
# closed form: sum over labellings of the n0 zero-data (j of them to tau1); others must go to tau1
def log_dm(counts):
    return (gammaln(alpha.sum()) - gammaln(alpha.sum() + sum(counts))
            + sum(gammaln(a + c) - gammaln(a) for a, c in zip(alpha, counts)))
total = 0.0
for j in range(n0 + 1):
    c1 = j + len(others)
    c2 = n0 - j
    total += math.comb(n0, j) * math.exp(log_dm([c1, c2])) * q1_zero ** j * np.prod(q1_others)
rng = np.random.default_rng(8)
W = rng.dirichlet(alpha, size=2_000_000)
lik = (W[:, 0] * q1_zero + W[:, 1] * 1.0) ** n0 * np.prod([W[:, 0] * q for q in q1_others], axis=0)
mc = lik.mean()
se = lik.std() / math.sqrt(len(lik))
from scipy import integrate, special
quad = integrate.quad(lambda w: (w * q1_zero + 1 - w) ** n0 * np.prod([w * q for q in q1_others])
                      * w ** -0.5 * (1 - w) ** -0.5 / special.beta(0.5, 0.5), 0, 1, limit=200)[0]
out.append(f"(1) labelling-sum closed form = {total:.9e}; 1-D quadrature over w1 ~ Beta(1/2,1/2) = {quad:.9e}; "
           f"Monte Carlo = {mc:.6e} +- {se:.1e}")
assert abs(total - quad) < 1e-12

# (2)
def gw(al_mp, al_unary, rng, cap=10**6):
    nodes, frontier = 0, 1
    while frontier and nodes < cap:
        frontier -= 1
        nodes += 1
        r = rng.random()
        if r < al_mp:
            frontier += 2
        elif r < al_mp + al_unary:
            frontier += 1
    return nodes
rng = random.Random(9)
for al_mp, al_un in ((0.15, 0.2), (0.3, 0.3), (0.25, 0.5)):
    m = 2 * al_mp + al_un
    sizes = [gw(al_mp, al_un, rng) for _ in range(100_000)]
    out.append(f"(2) al_mp={al_mp}, al_unary={al_un}: m = {m:.2f}; mean #nodes = {np.mean(sizes):.3f}"
               + (f"; 1/(1-m) = {1/(1-m):.3f}" if m < 1 else "; m = 1: heavy tail, sample mean not meaningful")
               + f"; max = {max(sizes)}")
al_mp, al_un = 0.4, 0.3
m = 2 * al_mp + al_un
# extinction probability: smallest root of q = (1 - al_mp - al_un) + al_un q + al_mp q^2
c0 = 1 - al_mp - al_un
roots = np.roots([al_mp, al_un - 1, c0])
q = min(r.real for r in roots if r.real >= 0)
fin = sum(gw(al_mp, al_un, rng, cap=20000) < 20000 for _ in range(20000)) / 20000
out.append(f"(2) supercritical al_mp={al_mp}, al_unary={al_un}: m = {m:.2f}; extinction q = {q:.4f}; "
           f"simulated P(finite, < 20000 nodes) = {fin:.4f}")
text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")

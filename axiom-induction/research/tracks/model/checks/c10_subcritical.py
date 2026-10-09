"""c10: the uniform (h-weighted) subcriticality criterion of the revised Definition 1.5 and Lemma 1.6 (notes-final).

Referee issue M5: per-type mean < 1 is unsatisfiable for formula sorts, and insufficient with infinitely many types.
Revised definition: there are weights h(type) in [h_min, h_max], 0 < h_min, and rho < 1 with
    E[ sum over children c of h(type(c)) | parent of type i ]  <=  rho * h(i)      for every type i.
Lemma 1.6 then gives E[#nodes] <= h(root) / (h_min (1 - rho)), and an exponential tail.

Part A.  An explicit PCFG Q_A for L_A (sorts: term, formula; type = (sort, k = number of variables in scope)).
  term node:    0 .4, S .2, + .1, * .1, variable .2 (split uniformly over the k variables; absent and renormalised if k = 0)
  formula node: = .3, < .2 (two term children), not .1 (one formula child), and .1, imp .1 (two formula children),
                forall .1, exists .1 (one formula child, k+1 variables)
  The law of (number, sorts) of children depends on k only through [k = 0], so checking k in {0, 1} checks all types;
  we also print k up to 5.  Sort-only weights h(formula) = 1, h(term) = eta.
Part B.  Simulation of body sizes from a formula root and from a term root (k = 0): mean size against the Lemma 1.6 bound,
  and an empirical tail.
Part C.  The referee's counterexample (forall-chain with continuation probability 1 - 1/(k+2)^2) violates the revised
  criterion: any admissible h must satisfy h(k) <= h(0) * prod_{j<k} rho / (1 - 1/(j+2)^2) -> 0, contradicting h >= h_min.
  We print the forced upper bound on h(k) for several rho < 1.
"""
import math
import random

out = []

TERM_P = {'0': 0.4, 'S': 0.2, '+': 0.1, '*': 0.1, 'var': 0.2}
TERM_CH = {'0': 0, 'S': 1, '+': 2, '*': 2, 'var': 0}
FORM_P = {'=': 0.3, '<': 0.2, 'not': 0.1, 'and': 0.1, 'imp': 0.1, 'forall': 0.1, 'exists': 0.1}
FORM_TERMCH = {'=': 2, '<': 2, 'not': 0, 'and': 0, 'imp': 0, 'forall': 0, 'exists': 0}
FORM_FORMCH = {'=': 0, '<': 0, 'not': 1, 'and': 2, 'imp': 2, 'forall': 1, 'exists': 1}


def term_law(k):
    p = dict(TERM_P)
    if k == 0:
        del p['var']
    z = sum(p.values())
    return {s: v / z for s, v in p.items()}


def means(k):
    tl = term_law(k)
    m_tt = sum(tl[s] * TERM_CH[s] for s in tl)
    m_ff = sum(FORM_P[s] * FORM_FORMCH[s] for s in FORM_P)
    m_ft = sum(FORM_P[s] * FORM_TERMCH[s] for s in FORM_P)
    return m_tt, m_ff, m_ft


eta = 0.05
rho_needed = 0.0
for k in range(6):
    m_tt, m_ff, m_ft = means(k)
    lhs_term = m_tt * eta              # term node: children are terms
    lhs_form = m_ff * 1.0 + m_ft * eta  # formula node
    r = max(lhs_term / eta, lhs_form / 1.0)
    rho_needed = max(rho_needed, r)
    out.append(f"A: k = {k}: term mean children {m_tt:.3f}; formula: formula-children {m_ff:.3f}, term-children {m_ft:.3f}; "
               f"h-weighted ratios: term {lhs_term / eta:.3f}, formula {lhs_form:.3f}")
out.append(f"A: with h(formula) = 1, h(term) = {eta}: rho = {rho_needed:.3f} < 1 for every type (law depends on k only "
           f"through [k = 0]); note every formula production has >= 1 child, as the referee says, yet the criterion holds")

# Part B: simulation
rng = random.Random(1010)


def sample(sort, k, cap=10**6):
    """Return the number of nodes of a body drawn from Q_A, iteratively."""
    stack = [(sort, k)]
    n = 0
    while stack:
        s, kk = stack.pop()
        n += 1
        if n > cap:
            return None
        if s == 't':
            tl = term_law(kk)
            f = rng.choices(list(tl), [tl[x] for x in tl])[0]
            stack.extend([('t', kk)] * TERM_CH[f])
        else:
            f = rng.choices(list(FORM_P), [FORM_P[x] for x in FORM_P])[0]
            stack.extend([('t', kk)] * FORM_TERMCH[f])
            nk = kk + 1 if f in ('forall', 'exists') else kk
            stack.extend([('f', nk)] * FORM_FORMCH[f])
    return n


h_min = eta
for sort, hroot in (('f', 1.0), ('t', eta)):
    R = 200_000
    sizes = [sample(sort, 0) for _ in range(R)]
    assert all(s is not None for s in sizes)
    mean = sum(sizes) / R
    se = (sum((s - mean) ** 2 for s in sizes) / (R - 1) / R) ** 0.5
    bound = hroot / (h_min * (1 - rho_needed))
    tail = {L: sum(1 for s in sizes if s >= L) / R for L in (10, 20, 40, 80)}
    out.append(f"B: root sort {'formula' if sort == 'f' else 'term'}, {R} draws: mean size {mean:.3f} (s.e. {se:.3f}); Lemma 1.6 bound "
               f"{bound:.1f}; P(size >= L) for L = 10, 20, 40, 80: " + ", ".join(f"{v:.2e}" for v in tail.values()))
    # log-tail slope between L = 20 and 40 (exponential tail => roughly linear decay of log P)
    if tail[40] > 0:
        out.append(f"   empirical log-tail decay per node between L = 20 and 40: {math.log(tail[20] / tail[40]) / 20:.3f} nats")

out.append("B: for a term root at k = 0 the exact mean is 1/(1 - 0.75) = 4, equal to the bound (single-type case, "
           "where the bound is tight)")

# Part C: the referee's counterexample under the revised criterion
for rho in (0.9, 0.99, 0.999):
    h = 1.0
    bounds = {}
    for k in range(0, 2001):
        if k in (10, 100, 1000, 2000):
            bounds[k] = h
        h *= rho / (1 - 1 / (k + 2) ** 2)
    out.append(f"C: rho = {rho}: any admissible h has h(k)/h(0) <= " +
               ", ".join(f"{v:.2e} (k = {k})" for k, v in bounds.items()) + "  -> 0, so no h_min > 0 exists")
out.append("C: the referee's chain (per-type mean 1 - 1/(k+2)^2 < 1, infinite with probability 1/2) is excluded by the revised "
           "definition.")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")

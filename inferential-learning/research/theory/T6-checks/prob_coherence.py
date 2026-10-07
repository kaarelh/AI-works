"""T6 check 2: probabilistic coherence (de Finetti polytopes) vs. local / sequent constraints.
(a) exact facets of the coherence polytope for the agenda {P, Q, P->Q};
(b) k-exclusive example: coherent on every sub-agenda over k-1 atoms, globally incoherent;
(c) k=3: all valid multiple-conclusion sequents' union bounds hold, yet incoherent;
(d) the violated 'counting sequent' (at least 2 of a 6-element list hold in every world)."""
import itertools
import numpy as np
from scipy.optimize import linprog
from scipy.spatial import ConvexHull

def coherent(vectors, p):
    """Is p in conv(vectors)?  LP feasibility."""
    V = np.array(vectors, dtype=float).T          # dim x m
    m = V.shape[1]
    A_eq = np.vstack([V, np.ones((1, m))])
    b_eq = np.concatenate([np.array(p, dtype=float), [1.0]])
    r = linprog(np.zeros(m), A_eq=A_eq, b_eq=b_eq, bounds=[(0, None)] * m, method="highs")
    return r.status == 0

# (a) agenda (P, Q, P->Q)
pts = []
for a, b in itertools.product([0, 1], repeat=2):
    pts.append((a, b, int((not a) or b)))
hull = ConvexHull(np.array(pts, dtype=float))
print("(a) vertices:", pts)
for eq in hull.equations:
    nrm = eq[:-1] / np.max(np.abs(eq[:-1])); off = eq[-1] / np.max(np.abs(eq[:-1]))
    print("    facet: %+.0f*P(P) %+.0f*P(Q) %+.0f*P(P->Q) %+.0f <= 0" % (nrm[0], nrm[1], nrm[2], off))

# (b) k-exclusive
def k_exclusive(k):
    atoms = list(range(k))
    pairs = list(itertools.combinations(atoms, 2))
    def vec(v, A, Pr):
        return [v[i] for i in A] + [v[i] * v[j] for (i, j) in Pr]
    p_atom = 1.0 / (k - 1)
    # global
    allv = list(itertools.product([0, 1], repeat=k))
    glob = coherent([vec(v, atoms, pairs) for v in allv], [p_atom] * k + [0.0] * len(pairs))
    # every sub-agenda on k-1 atoms
    loc = True
    for A in itertools.combinations(atoms, k - 1):
        Pr = list(itertools.combinations(A, 2))
        vs = [vec(dict(zip(A, w)), A, Pr) for w in itertools.product([0, 1], repeat=k - 1)]
        loc &= coherent(vs, [p_atom] * (k - 1) + [0.0] * len(Pr))
    return glob, loc
for k in [3, 4, 5, 6]:
    g, l = k_exclusive(k)
    print("(b) k=%d: globally coherent=%s; coherent on every (k-1)-atom sub-agenda=%s" % (k, g, l))

# (c) k=3, agenda of 12 formulas: A_i, A_i&A_j, and their negations
k = 3
pairs = list(itertools.combinations(range(k), 2))
forms = []   # (name, function of valuation, credence)
for i in range(k):
    forms.append(("A%d" % i, lambda v, i=i: v[i], 0.5))
    forms.append(("~A%d" % i, lambda v, i=i: 1 - v[i], 0.5))
for (i, j) in pairs:
    forms.append(("A%d&A%d" % (i, j), lambda v, i=i, j=j: v[i] * v[j], 0.0))
    forms.append(("~(A%d&A%d)" % (i, j), lambda v, i=i, j=j: 1 - v[i] * v[j], 1.0))
F = len(forms)
allv = list(itertools.product([0, 1], repeat=k))
truth = [[f[1](v) for f in forms] for v in allv]
cred = [f[2] for f in forms]
print("(c) credence globally coherent:", coherent(truth, cred))
viol = 0; nvalid = 0
for assign in itertools.product([0, 1, 2], repeat=F):   # 0: absent, 1: in Gamma, 2: in Delta
    G = [i for i in range(F) if assign[i] == 1]; D = [i for i in range(F) if assign[i] == 2]
    valid = all(not (all(t[g] for g in G) and not any(t[d] for d in D)) for t in truth)
    if valid:
        nvalid += 1
        lhs = sum(1 - cred[g] for g in G) + sum(cred[d] for d in D)
        if lhs < 1 - 1e-12:
            viol += 1
print("    valid sequents over the 12 formulas: %d; union-bound violations: %d" % (nvalid, viol))

# (d) counting sequent: at least 2 of {~A0,~A1,~A2,A0&A1,A0&A2,A1&A2} in every world
idx = [forms.index(next(f for f in forms if f[0] == nm)) for nm in
       ["~A0", "~A1", "~A2", "A0&A1", "A0&A2", "A1&A2"]]
print("(d) min #true over worlds:", min(sum(t[i] for i in idx) for t in truth),
      "; credence sum:", sum(cred[i] for i in idx))

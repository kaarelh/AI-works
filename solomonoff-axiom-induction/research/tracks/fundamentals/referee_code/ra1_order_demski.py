"""Referee A, check ra1 (seeded, exact rational arithmetic; written independently of checks/).

Part A. Thm 11.1(a) of notes.md: for D = {(a,1),(a v c,1)} the ratio of the normalised
probabilities in the orders (a v c, a) and (a, a v c) equals
   1 + [(p11+p01) p0i + pi1 (p00+p0i)] / [(p11+p01+pi1+p00)(p11+p01)],
and the per-pair bound used in Thm 11.1(b): ratio >= 1 + p0i (cell masses of a probability).
Theories are deductive types on the two atoms a, c: nonempty sets of valuations (15 types),
plus an inconsistent type. Bel/Dis are computed from entailment = inclusion of model sets,
NOT from the closed form. Laws: random positive rational weights on all 16 types
("universal-like": every consistent type has positive mass), and random sparse laws.

Part B. Prop 10.1(a) (Demski's process) on a finite propositional language (3 atoms, all 256
Boolean functions as sentences, full-support mu): the exact law of the final kept theory is
computed by recursion over model sets; check that it is complete with probability 1
(P(phi) + P(not phi) = 1 for all phi). Same for the variant that draws whole theories
(model sets) from a weighted list ("draw a program, keep its output if consistent"),
the form of the modified Demski prior; and contrast with one draw (M_A style), whose
independent mass is the weight of the theories that decide neither.
"""
import random
from fractions import Fraction as Fr
from functools import lru_cache
from itertools import product

SEED = 20261016
random.seed(SEED)

# ---------------- Part A ----------------
VALS = [(1, 1), (1, 0), (0, 1), (0, 0)]          # valuations (a, c)
def mods(pred):
    return frozenset(v for v in VALS if pred(*v))
A = mods(lambda a, c: a == 1)
NA = mods(lambda a, c: a == 0)
AC = mods(lambda a, c: a == 1 or c == 1)
NAC = mods(lambda a, c: not (a == 1 or c == 1))
TYPES = [frozenset(s) for r in range(1, 5) for s in __import__('itertools').combinations(VALS, r)]
assert len(TYPES) == 15

def proves(S, M):      # consistent theory with model set S proves sentence with model set M
    return S <= M

def trich(law, data_mods, phi, nphi):
    """normalised Bel, Dis of phi under the posterior given data (list of model sets), law on TYPES."""
    post = {S: w for S, w in law.items() if all(proves(S, M) for M in data_mods)}
    Z = sum(post.values())
    b = sum(w for S, w in post.items() if proves(S, phi)) / Z
    d = sum(w for S, w in post.items() if proves(S, nphi)) / Z
    return b, d

def normprob(law, order):
    data, p = [], Fr(1)
    for (M, NM) in order:
        b, d = trich(law, data, M, NM)
        p *= b / (b + d)
        data.append(M)
    return p

def cells(law):
    Z = sum(law.values())
    def cell(S):
        x = 1 if proves(S, A) else (0 if proves(S, NA) else 'i')
        y = 1 if proves(S, AC) else (0 if proves(S, NAC) else 'i')
        return (x, y)
    out = {}
    for S, w in law.items():
        k = cell(S)
        out[k] = out.get(k, Fr(0)) + w / Z
    return out

def rand_law(sparse):
    law = {}
    for S in TYPES:
        if sparse and random.random() < 0.5:
            continue
        law[S] = Fr(random.randint(1, 50), 1)
    if not any(proves(S, A) for S in law):   # need p11 > 0
        law[frozenset({(1, 1)})] = Fr(random.randint(1, 50), 1)
    return law

worst_identity, n_strict, n_eq, n_laws, n_pos, n_zero = Fr(0), 0, 0, 0, 0, 0
viol_pairbound = 0
for trial in range(600):
    law = rand_law(sparse=(trial % 2 == 1))
    Nab = normprob(law, [(A, NA), (AC, NAC)])
    Nba = normprob(law, [(AC, NAC), (A, NA)])
    p = cells(law)
    g = lambda k: p.get(k, Fr(0))
    assert g((1, 0)) == 0 and g((1, 'i')) == 0 and g(('i', 0)) == 0
    p11, p01, pi1, p00, p0i = g((1, 1)), g((0, 1)), g(('i', 1)), g((0, 0)), g((0, 'i'))
    closed = 1 + ((p11 + p01) * p0i + pi1 * (p00 + p0i)) / ((p11 + p01 + pi1 + p00) * (p11 + p01))
    worst_identity = max(worst_identity, abs(Nba / Nab - closed))
    if Nba / Nab < 1 + p0i:
        viol_pairbound += 1
    num = (p11 + p01) * p0i + pi1 * (p00 + p0i)
    if num > 0:
        n_pos += 1
        n_strict += (Nba > Nab)
    else:
        n_zero += 1
        n_eq += (Nba == Nab)
    n_laws += 1
print("seed", SEED)
print("=== Part A: Thm 11.1(a) closed form and the per-pair bound of Thm 11.1(b) ===")
print(f"{n_laws} laws (half with all 15 consistent types positive, half sparse)")
print(f"max |N_ba/N_ab - closed form| = {float(worst_identity):.3e} (exact rationals)")
print(f"numerator positive in {n_pos} laws, of which strictly larger in order (a v c, a): {n_strict}; numerator 0 in {n_zero} laws, of which equal: {n_eq}")
print(f"(every law with all consistent types positive has p11, p0i > 0, so its numerator is positive)")
print(f"violations of ratio >= 1 + p0i: {viol_pairbound}")

# ---------------- Part B ----------------
VALS3 = list(product([0, 1], repeat=3))
ALLM = frozenset(VALS3)
SENTS = [frozenset(v for i, v in enumerate(VALS3) if (f >> i) & 1) for f in range(256)]
# full-support mu on sentences (including the contradiction and the tautology), random rationals
mu_raw = [Fr(random.randint(1, 9)) for _ in SENTS]
Zmu = sum(mu_raw)
mu = [x / Zmu for x in mu_raw]

@lru_cache(maxsize=None)
def final_law(S):
    """law of the final model set when the current kept theory has model set S (nonempty)."""
    if len(S) == 1:
        return ((S, Fr(1)),)
    stay = sum(m for M, m in zip(SENTS, mu) if not (S & M) or (S & M) == S)
    out = {}
    for M, m in zip(SENTS, mu):
        T = S & M
        if T and T != S:
            for F, q in final_law(T):
                out[F] = out.get(F, Fr(0)) + m * q / (1 - stay)
    return tuple(out.items())

law_dem = dict(final_law(ALLM))
tot = sum(law_dem.values())
incomplete = sum(q for F, q in law_dem.items() if len(F) > 1)
worst = max(abs(sum(q for F, q in law_dem.items() if F <= M) + sum(q for F, q in law_dem.items() if F <= ALLM - M) - 1)
            for M in SENTS if M and M != ALLM)
print("=== Part B: Demski's process on 3 atoms (256 sentences, full-support mu) ===")
print(f"total mass {tot}; mass on incomplete final theories {incomplete}; max |P(phi)+P(not phi)-1| = {float(worst):.1e}")

# modified variant: draw whole theories (consistent model sets) from a weighted list, keep if consistent
THEORIES = [M for M in SENTS if M]
w_raw = [Fr(random.randint(1, 9)) for _ in THEORIES]
Zw = sum(w_raw); wth = [x / Zw for x in w_raw]
@lru_cache(maxsize=None)
def final_law2(S):
    if len(S) == 1:
        return ((S, Fr(1)),)
    stay = sum(m for M, m in zip(THEORIES, wth) if not (S & M) or (S & M) == S)
    out = {}
    for M, m in zip(THEORIES, wth):
        T = S & M
        if T and T != S:
            for F, q in final_law2(T):
                out[F] = out.get(F, Fr(0)) + m * q / (1 - stay)
    return tuple(out.items())
law2 = dict(final_law2(ALLM))
inc2 = sum(q for F, q in law2.items() if len(F) > 1)
# one draw (M_A style): the drawn theory itself
a_mods = frozenset(v for v in VALS3 if v[0] == 1)
indep_one = sum(m for M, m in zip(THEORIES, wth) if not (M <= a_mods) and not (M <= ALLM - a_mods))
print("=== Part B': theory-drawing variant (modified-Demski form) and a single draw ===")
print(f"iterated theory draws: mass on incomplete final theories {inc2}")
print(f"single draw: independent mass for atom a = {float(indep_one):.4f} (> 0)")

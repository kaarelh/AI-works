"""Referee A: small explicit counterexamples and spot checks for tracks/shape/notes.md (deterministic).

Writes refA_extra.out next to itself. Uses refA_lib.py only.

B2  Theorem 7.1's "iff" fails in the universal reading too: a theory with a wide clause whose (unique)
    contained prime implicate completes a 2-hop TC-spanner, but which is not UP_2-usable.
H   Prop 4.2(b): the trivial rule {x_j = v} => x_j = v is sound in the record's sense (S and P entail l,
    P consistent with S) and has a premise missing m-1 variables; count sound rules with and without it.
J   Prop 3.1: the chain encoding of x_1+...+x_m = c is propagation complete on all variables, including
    conflict detection on inconsistent partial assignments to base and auxiliary variables (m = 3..6).
I   Theorem 1.12 / Cor 2.8 with auxiliary variables allowed: listing lengths of the GE core, of the minimum
    no-aux UP-usable theory and of Prop 3.2's chain-encoded circuit library, for the simplex family.
"""
import sys, math
from itertools import product
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from refA_lib import *

OUT = []


def P(*a):
    s = " ".join(str(x) for x in a)
    OUT.append(s)
    print(s, flush=True)


P("# refA_extra.py (deterministic)")


def chain_sols(m):
    return [sum(1 << v for v in range(a, m)) for a in range(m + 1)]


# ------------------------------------------------------------------ B2
P("== B2: Theorem 7.1, universal reading")
m, k = 4, 2
sols = chain_sols(m)
# variables x0..x3; clauses: x0->x1, x1->x2, x2->x3, and (x0 or ~x1 or x3)
F = [frozenset([-1, 2]), frozenset([-2, 3]), frozenset([-3, 4]), frozenset([1, -2, 4])]
P("  F = {~x0|x1, ~x1|x2, ~x2|x3, x0|~x1|x3}; every clause is an implicate of Ch_4:",
  projection(F, 4, 4) == sorted(sols))
P("  prime implicates contained in the wide clause: only ~x1|x3 (x0 occurs positively and precedes x1)")
Frep = F[:3] + [frozenset([-2, 4])]
P("  after replacement: edges {01,12,23,13}; UP_2-usable (= 2-hop TC-spanner):", usable(Frep, sols, m, rounds=k))
P("  F itself UP_2-usable:", usable(F, sols, m, rounds=k))
for alpha in ({3: 0}, {0: 1}):
    a, conf = up_rounds(F, alpha, k)
    P(f"    UP_2 from {alpha}: derived {dict(sorted(a.items()))}; entailed {entailed(sols, alpha, m)}")

# ------------------------------------------------------------------ H
P("== H: Prop 4.2(b), sound directed rules for one parity law (no auxiliaries)")
for m in range(2, 6):
    sols = [x for x in range(1 << m) if popcount(x) % 2 == 0]
    n_sound = n_trivial = n_full = 0
    for j in range(m):
        others = [v for v in range(m)]
        for vals in product((-1, 0, 1), repeat=m):
            Pm = {v: s for v, s in enumerate(vals) if s != -1}
            cons = [x for x in sols if all(((x >> v) & 1) == s for v, s in Pm.items())]
            if not cons:
                continue
            for val in (0, 1):
                if all(((x >> j) & 1) == val for x in cons):
                    n_sound += 1
                    if j in Pm:
                        n_trivial += 1
                    elif len(Pm) == m - 1:
                        n_full += 1
    P(f"  m={m}: sound rules {n_sound}; with conclusion in the premise (trivial) {n_trivial}; "
      f"non-trivial with |P|=m-1: {n_full} (= m*2^(m-1) = {m * 2 ** (m - 1)})")

# ------------------------------------------------------------------ I
P("== I: listing lengths for the simplex family (bits, Definition 1.6 with Elias-delta integer code)")


def elias_delta(n):
    n = n + 1  # code nonnegative integers
    L = n.bit_length()
    return L - 1 + 2 * (L.bit_length() - 1) + 1


def l_lst_clauses(groups, N, m):
    """groups: list of (number of clauses, width)."""
    b = math.ceil(math.log2(N)) if N > 1 else 0
    n = sum(c for c, _ in groups)
    return elias_delta(N - m) + elias_delta(n) + sum(c * (elias_delta(w) + w * (b + 1)) for c, w in groups)


def l_lst_linear(weights, N, m):
    b = math.ceil(math.log2(N)) if N > 1 else 0
    return elias_delta(N - m) + elias_delta(len(weights)) + sum(elias_delta(w) + w * b + 1 for w in weights)


for r in range(3, 9):
    m = 2 ** r - 1
    w = 2 ** (r - 1)
    ge = l_lst_linear([w] * r, m, m)
    noaux = l_lst_clauses([(m * 2 ** (w - 1), w)], m, m)
    if w <= 4:
        groups = [(m * 2 ** (w - 1), w)]
        naux = 0
    else:
        groups = [(4 * (w - 2) * m, 3), (2 * m, 2)]
        naux = (w - 2) * m
    lib = l_lst_clauses(groups, m + naux, m)
    noaux_s = f"{noaux:.3g}"
    P(f"  r={r} m={m}: GE core {ge:,} bits; min no-aux UP theory {noaux_s} bits; "
      f"chain-encoded circuit library (aux allowed) {lib:,} bits; ratio library/GE = {lib / ge:.1f}")

# ------------------------------------------------------------------ J
P("== J: Prop 3.1, propagation completeness of the chain encoding on all variables")


def xor_clauses(vs, c):
    out = []
    for bits in product((0, 1), repeat=len(vs)):
        if sum(bits) % 2 != c:
            out.append(frozenset(mk(v, 1 - b) for v, b in zip(vs, bits)))
    return out


for m in range(3, 7):
    for c in (0, 1):
        N = m + (m - 2)
        y = lambda i: m + i - 1  # y_1..y_{m-2}
        F = xor_clauses([0, 1, y(1)], 0)
        for i in range(2, m - 1):
            F += xor_clauses([y(i - 1), i, y(i)], 0)
        F += xor_clauses([y(m - 2), m - 1], c)
        mods = models(F, N)
        bad = ncons = ninc = 0
        for vals in product((-1, 0, 1), repeat=N):
            alpha = {v: s for v, s in enumerate(vals) if s != -1}
            cons = [x for x in mods if all(((x >> v) & 1) == s for v, s in alpha.items())]
            a, conf = up_rounds(F, alpha)
            if not cons:
                ninc += 1
                bad += (not conf)
                continue
            ncons += 1
            if conf:
                bad += 1
                continue
            for v in range(N):
                vs_ = set((x >> v) & 1 for x in cons)
                if len(vs_) == 1 and a.get(v) != vs_.pop():
                    bad += 1
                    break
        P(f"  m={m} c={c}: {len(F)} clauses (4m-6 = {4 * m - 6}); {ncons} consistent and {ninc} inconsistent "
          f"partial assignments to all {N} variables; failures {bad}")

open(__file__.rsplit('.', 1)[0] + ".out", "w").write("\n".join(OUT) + "\n")

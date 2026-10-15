#!/usr/bin/env python3
"""s1_onetape_toy.py -- finite propositional sanity check (scout S, notes.md section 2).

Checks, on a finite propositional analogue with finite random tapes, the set inclusions behind
  * Theorem B (one-tape equivalence): for an axiom machine G and the proof-search labeller T_G,
        {tapes: B u A_G(w) consistent and proves D}  ==  {tapes: f^{T_G}_w extends D, B u Gamma consistent};
    for a function machine T and the axiom machine G_T (enumerate Gamma_{f_w}),
        {tapes: f^T_w extends D, consistent}  is a subset of  {tapes: B u A_{G_T}(w) consistent, proves D};
  * Proposition E (logical closure and the trichotomy): axiom induction gives every consequence of the
    data probability 1; consistent function induction gives it probability 0 of 'false' but positive
    probability of 'undefined'; after deductive closure of the labellers the three predictive
    probabilities agree exactly (here the maps have no length overhead);
  * Remark E' (three outcomes are a measure): for axiom induction, W(D+(phi,1)) + W(D+(phi,0))
    + W(D+(phi,ind)) = W(D) exactly.

Everything is exact (fractions).  Propositional logic over 3 atoms; provability is semantic
(complete for propositional logic): Gamma |- phi iff every valuation satisfying Gamma satisfies phi.
This is an illustration of the logic of the maps, not a proof; the proofs are in notes.md.
Seed 20261015.  Writes s1_onetape_toy.out next to itself.
"""
import itertools
import os
import random
from fractions import Fraction

SEED = 20261015
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "s1_onetape_toy.out")

NV = 3                      # atoms p0, p1, p2
VALS = list(itertools.product([0, 1], repeat=NV))
FULL = (1 << len(VALS)) - 1


def mask_of(fn):
    m = 0
    for i, v in enumerate(VALS):
        if fn(v):
            m |= 1 << i
    return m


# base sentences (syntactic objects with a truth table); the list is closed under one negation
BASE = [
    ("p0", lambda v: v[0]),
    ("p1", lambda v: v[1]),
    ("p2", lambda v: v[2]),
    ("p0->p1", lambda v: (not v[0]) or v[1]),
    ("p1->p2", lambda v: (not v[1]) or v[2]),
    ("p0&p2", lambda v: v[0] and v[2]),
    ("p0|p1", lambda v: v[0] or v[1]),
    ("~~p0", lambda v: v[0]),               # same truth table as p0, different sentence
    ("p0<->p2", lambda v: v[0] == v[2]),
    ("p2->p0", lambda v: (not v[2]) or v[0]),
]
SENT = []
for name, fn in BASE:
    m = mask_of(fn)
    SENT.append((name, m))
    SENT.append(("~(" + name + ")", FULL & ~m))
NS = len(SENT)
NEG = {i: (i ^ 1) for i in range(NS)}      # index of the negation sentence


def lit_mask(i, b):
    """mask of phi^b (phi if b=1, ~phi if b=0)"""
    return SENT[i][1] if b == 1 else FULL & ~SENT[i][1]


def theory_mask(axioms, B):
    m = B
    for i in axioms:
        m &= SENT[i][1]
    return m


def consistent(m):
    return m != 0


def proves(m, target):
    return (m & ~target) == 0


K = 4                       # tape bits
TAPES = list(itertools.product([0, 1], repeat=K))
P_TAPE = Fraction(1, len(TAPES))


def rand_axiom_machine(rng):
    """for each tape: a random set of axioms (indices into SENT)"""
    return [frozenset(rng.sample(range(NS), rng.randint(0, 4))) for _ in TAPES]


def rand_function_machine(rng, B):
    """for each tape: a partial labelling (dict sentence -> 0/1); mostly truthful to a random valuation
    satisfying B, with occasional wrong labels (which may make the tape inconsistent)"""
    sat = [i for i in range(len(VALS)) if (B >> i) & 1]
    tm = []
    for _ in TAPES:
        v = rng.choice(sat)
        lab = {}
        for s in range(NS):
            r = rng.random()
            if r < 0.30:
                lab[s] = (SENT[s][1] >> v) & 1
            elif r < 0.36:
                lab[s] = 1 - ((SENT[s][1] >> v) & 1)
        tm.append(lab)
    return tm


def gamma_mask(lab, B):
    m = B
    for s, b in lab.items():
        m &= lit_mask(s, b)
    return m


def extends(lab, D):
    return all(lab.get(s) == b for s, b in D)


def proof_search_labeller(axioms, B):
    """T_G on one tape: label by consequence if consistent; if inconsistent, 'proof search' finds a
    proof of phi first for every phi (label 1 everywhere)."""
    m = theory_mask(axioms, B)
    if not consistent(m):
        return {s: 1 for s in range(NS)}
    lab = {}
    for s in range(NS):
        if proves(m, SENT[s][1]):
            lab[s] = 1
        elif proves(m, FULL & ~SENT[s][1]):
            lab[s] = 0
    return lab


def closure_labeller(lab, B):
    """deductive closure of a consistent labelling"""
    m = gamma_mask(lab, B)
    return proof_search_labeller([], m) if consistent(m) else None


def all_data(maxsize=2):
    out = [()]
    for size in range(1, maxsize + 1):
        for sents in itertools.combinations(range(NS), size):
            for labs in itertools.product([0, 1], repeat=size):
                out.append(tuple(zip(sents, labs)))
    return out


def nu_cons(tm, D, B):
    return sum((P_TAPE for lab in tm if extends(lab, D) and consistent(gamma_mask(lab, B))), Fraction(0))


def mu_ai(gm, D, B):
    tot = Fraction(0)
    for ax in gm:
        m = theory_mask(ax, B)
        if consistent(m) and all(proves(m, lit_mask(s, b)) for s, b in D):
            tot += P_TAPE
    return tot


def run(B, Bname, rng, log):
    log(f"=== background B = {Bname} (models: {bin(B).count('1')} of {len(VALS)} valuations) ===")
    DATA = all_data(2)
    log(f"sentences: {NS} (closed under one negation); tapes: {len(TAPES)}; data sets |D|<=2: {len(DATA)}")
    NM = 25
    G = [rand_axiom_machine(rng) for _ in range(NM)]
    T = [rand_function_machine(rng, B) for _ in range(NM)]
    weights = [Fraction(1, 2 ** (i + 1)) for i in range(NM)]

    # (1) axiom machine G -> proof-search labeller T_G : equality of the two events, tape by tape
    TG = [[proof_search_labeller(ax, B) for ax in g] for g in G]
    bad_eq = 0
    for g, tg in zip(G, TG):
        for D in DATA:
            if mu_ai(g, D, B) != nu_cons(tg, D, B):
                bad_eq += 1
    log(f"(1) mu_G(D) == nu^cons_(T_G)(D) for all {NM} machines x {len(DATA)} data sets: violations = {bad_eq}")

    # (2) function machine T -> axiom machine G_T (axioms = Gamma_f): inclusion, and how often strict
    GT = [[frozenset(s if b == 1 else NEG[s] for s, b in lab.items()) for lab in tm] for tm in T]
    bad_incl, strict = 0, 0
    for tm, gt in zip(T, GT):
        for D in DATA:
            a, b = nu_cons(tm, D, B), mu_ai(gt, D, B)
            if a > b:
                bad_incl += 1
            elif a < b:
                strict += 1
    log(f"(2) nu^cons_T(D) <= mu_(G_T)(D): violations = {bad_incl}; strict (closure adds consequences) "
        f"in {strict} of {NM * len(DATA)} cases")

    # mixtures
    def MAI(D):
        return sum((w * mu_ai(g, D, B) for w, g in zip(weights, G)), Fraction(0)) + \
            sum((w * mu_ai(g, D, B) for w, g in zip(weights, GT)), Fraction(0))

    def MF(D):
        return sum((w * nu_cons(tg, D, B) for w, tg in zip(weights, TG)), Fraction(0)) + \
            sum((w * nu_cons(tm, D, B) for w, tm in zip(weights, T)), Fraction(0))

    ratios = []
    for D in DATA[1:]:
        a, f = MAI(D), MF(D)
        if f > 0:
            ratios.append(a / f)
        elif a > 0:
            ratios.append(None)
    finite = [r for r in ratios if r is not None]
    log(f"(3) mixtures over both families: min M_AI/M_F^cons = {float(min(finite)):.4f}, "
        f"max = {float(max(finite)):.4f} (>= 1 expected: here the maps have no length overhead); "
        f"cases with M_F^cons = 0 < M_AI: {sum(r is None for r in ratios)}")

    # (4) Proposition E: consequences of the data, trichotomy
    def tri_ai(D, q):
        base = MAI(D)
        if base == 0:
            return None
        p1, p0 = MAI(D + ((q, 1),)), MAI(D + ((q, 0),))
        return (p1 / base, p0 / base, 1 - (p1 + p0) / base)

    def tri_fi(D, q, fam_T):
        # weights 2^-(i+1) for the random machines, and 2^-(NM+1) for the lookup table appended last
        wts = weights + [Fraction(1, 2 ** (NM + 1))] * (len(fam_T) - len(weights))
        base = sum((w * nu_cons(tm, D, B) for w, tm in zip(wts, fam_T)), Fraction(0))
        if base == 0:
            return None
        p1 = sum((w * nu_cons(tm, D + ((q, 1),), B) for w, tm in zip(wts, fam_T)), Fraction(0))
        p0 = sum((w * nu_cons(tm, D + ((q, 0),), B) for w, tm in zip(wts, fam_T)), Fraction(0))
        return (p1 / base, p0 / base, 1 - (p1 + p0) / base)

    # lookup-table labellers (deterministic: same labelling on every tape) for every consistent D
    n_cons, ai_ok, fi_false_zero, fi_undef_pos, n_fi = 0, 0, 0, 0, 0
    min_undef = None
    for D in DATA[1:]:
        dm = gamma_mask(dict(D), B)
        if not consistent(dm):
            continue
        lookup = [dict(D) for _ in TAPES]
        famT = T + [lookup]
        for q in range(NS):
            if q in dict(D):
                continue
            if proves(dm, SENT[q][1]):           # q is a consequence of B and the data
                n_cons += 1
                tr = tri_ai(D, q)
                if tr is None or tr == (1, 0, 0):
                    ai_ok += 1
                trf = tri_fi(D, q, famT)
                if trf is not None:
                    n_fi += 1
                    if trf[1] == 0:
                        fi_false_zero += 1
                    if trf[2] > 0:
                        fi_undef_pos += 1
                        min_undef = trf[2] if min_undef is None else min(min_undef, trf[2])
    log(f"(4) Prop E on {n_cons} (data, consequence) pairs: AI gives (1,0,0) [or has no compatible "
        f"hypothesis] in {ai_ok}; consistent FI (random machines + lookup table of D): P(false)=0 in "
        f"{fi_false_zero}/{n_fi}, P(undefined)>0 in {fi_undef_pos}/{n_fi}, smallest positive P(undefined) "
        f"= {float(min_undef) if min_undef is not None else 'n/a'}")

    # (5) deductively closed labellers: closure of each consistent tape of T equals G_T's theory
    #     pathwise, so all three predictive probabilities coincide with those of the G_T mixture
    closedT = []
    for tm in T:
        ctm = []
        for lab in tm:
            c = closure_labeller(lab, B)
            ctm.append(c if c is not None else {s: 1 for s in range(NS)})
        closedT.append(ctm)
    mism = 0
    checked = 0
    for D in DATA[:300]:
        for q in range(NS):
            if q in dict(D):
                continue
            base_c = sum((w * nu_cons(tm, D, B) for w, tm in zip(weights, closedT)), Fraction(0))
            base_g = sum((w * mu_ai(g, D, B) for w, g in zip(weights, GT)), Fraction(0))
            if base_c != base_g:
                mism += 1
                continue
            if base_c == 0:
                continue
            checked += 1
            for b in (0, 1):
                a = sum((w * nu_cons(tm, D + ((q, b),), B) for w, tm in zip(weights, closedT)), Fraction(0))
                g = sum((w * mu_ai(gg, D + ((q, b),), B) for w, gg in zip(weights, GT)), Fraction(0))
                if a != g:
                    mism += 1
    log(f"(5) closed labellers vs their axiom machines: trichotomy probabilities compared on {checked} "
        f"(D, phi) pairs (first 300 data sets): mismatches = {mism}")

    # (6) three outcomes are a measure for axiom induction (independent counted as an outcome)
    def W_ind(D, q):
        tot = Fraction(0)
        for w, g in zip(weights, G):
            for ax in g:
                m = theory_mask(ax, B)
                if consistent(m) and all(proves(m, lit_mask(s, b)) for s, b in D) and \
                        not proves(m, SENT[q][1]) and not proves(m, FULL & ~SENT[q][1]):
                    tot += w * P_TAPE
        return tot

    bad_meas = 0
    for D in DATA[:300]:
        base = sum((w * mu_ai(g, D, B) for w, g in zip(weights, G)), Fraction(0))
        for q in range(NS):
            if q in dict(D):
                continue
            p1 = sum((w * mu_ai(g, D + ((q, 1),), B) for w, g in zip(weights, G)), Fraction(0))
            p0 = sum((w * mu_ai(g, D + ((q, 0),), B) for w, g in zip(weights, G)), Fraction(0))
            if p1 + p0 + W_ind(D, q) != base:
                bad_meas += 1
    log(f"(6) W(D+(phi,1)) + W(D+(phi,0)) + W(D+(phi,ind)) == W(D) for AI (first 300 data sets x all phi): "
        f"violations = {bad_meas}")
    log("")


def main():
    rng = random.Random(SEED)
    lines = []

    def log(s):
        print(s)
        lines.append(s)

    log("s1_onetape_toy.py  seed=%d" % SEED)
    run(FULL, "empty (all valuations)", rng, log)
    run(mask_of(lambda v: v[0] or v[1] or v[2]), "p0|p1|p2", rng, log)
    with open(OUT, "w") as fh:
        fh.write("\n".join(lines) + "\n")


if __name__ == "__main__":
    main()

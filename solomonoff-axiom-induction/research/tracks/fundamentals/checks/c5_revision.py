#!/usr/bin/env python3
"""c5_revision.py -- thread `fundamentals`, revision round (2026-10-16).

Finite stand-ins for the claims added or changed after the referee reports.  Written from the
statements and proofs in notes-final.md, independently of the referees' scripts (referee_code/).

Representation.  k propositional atoms; a valuation is an integer in [0, 2^k); a proposition (the
content of a sentence) is a bitmask over the 2^k valuations.  A theory is its model set (a bitmask);
0 is the inconsistent theory.  "H proves x" iff H is a subset of x; "H consistent" iff H != 0.
A law is a finite list (theory, weight) with exact rational weights summing to 1 (every tape yields
a theory; the empty theory FULL carries the mass of the tapes with no program).

Parts.
  R1  Prop 7.2(b) (new; referee B, M1), single pair at D = empty:
      D_j = {(a,1),(a v e_j,1)}, e_j = -s_1 & ... & -s_{j-1} & s_j.  CR (Dempster-predictor)
      probabilities of the two orders; the identity
          P_(a,b)/P_(b,a) = 1 + N_j/(Pr[H|-b] T_j),  N_j = Pr[H|-a] rho_j - delta_j T_j;
      disjointness sum_j delta_j <= 1; #{j : N_j <= 0} <= 1/(Bel_0(a) eps_empty).
  R2  Prop 7.2(b), sequential pairs with adaptive j_i: the CR loss difference between the orders
      (b_1,a_1,b_2,a_2,...) and (a_1,b_1,a_2,b_2,...) equals the sum of the per-pair log ratios
      computed from the revealed set; N_i >= w_A eps - delta_i; each pair with delta_i <= w_A eps/2
      contributes at least log(1 + w_A eps/2).
  R3  Prop 7.3(e) (new; referee B, m1): on the inputs (phi, not phi), the Moebius mass of
      (undefined, undefined) is -1/2 x (mass of consistent theories deciding neither) for M_half,
      and +(that mass) for M.
  R4  Prop 10.1(a),(e),(f) (referee A, M1): Demski's sentence process and the theory-drawing
      (modified) process both end in a complete theory with probability 1 (exact absorbing-chain
      computation); a single draw (the M_A form) keeps independent mass; for a complete theory,
      "proves" and "is consistent with" coincide.
  R5  Cor 8.8 (referee A, m14): a law whose local defect is 0 at every sentence (at D = empty) has
      only complete theories among its consistent outcomes, and conversely.
Seed 20261016.  Output: c5_revision.out (next to this script).
"""
import math
import os
import random
from fractions import Fraction as Fr
from functools import lru_cache

SEED = 20261016
rng = random.Random(SEED)
OUT = []


def out(s=""):
    OUT.append(s)
    print(s)


def lg(x):
    return math.log2(x)


class U:
    def __init__(self, k):
        self.k = k
        self.nv = 1 << k
        self.FULL = (1 << self.nv) - 1
        self.atoms = []
        for i in range(k):
            m = 0
            for v in range(self.nv):
                if (v >> i) & 1:
                    m |= 1 << v
            self.atoms.append(m)

    def neg(self, m):
        return self.FULL & ~m

    def conj_lits(self, lits):
        """lits: list of (atom index, sign 1/0)."""
        m = self.FULL
        for (i, s) in lits:
            m &= self.atoms[i] if s else self.neg(self.atoms[i])
        return m

    def rand_clause(self, width):
        m = 0
        for i in rng.sample(range(self.k), width):
            m |= self.atoms[i] if rng.random() < 0.5 else self.neg(self.atoms[i])
        return m


def sub(a, b):
    return a & ~b == 0


def normalise_with_empty(Uv, law):
    """put the remaining mass on the empty theory; weights are Fractions summing to <= 1."""
    tot = sum((w for (_, w) in law), Fr(0))
    assert tot <= 1
    return law + [(Uv.FULL, 1 - tot)]


# ------------------------------------------------------------------ CR machinery
def cr_pred(law, psiD, x):
    """Dempster predictor Bel^nc_D(x) = Pr[H |- x | H consistent], H = theory & psi_D."""
    Z = sum((w for (T, w) in law if T & psiD), Fr(0))
    num = sum((w for (T, w) in law if (T & psiD) and sub(T & psiD, x)), Fr(0))
    return num / Z, Z


def pair_quantities(Uv, law, psiD, a, e):
    """Pr is Unif conditioned on H := T & psi_D consistent.  Returns the quantities of the proof."""
    b = a | e
    Z = sum((w for (T, w) in law if T & psiD), Fr(0))
    P = [((T & psiD), w / Z) for (T, w) in law if T & psiD]
    pa = sum((w for (H, w) in P if sub(H, a)), Fr(0))
    pb = sum((w for (H, w) in P if sub(H, b)), Fr(0))
    plb = sum((w for (H, w) in P if H & b), Fr(0))
    T_ = sum((w for (H, w) in P if (H & b) and sub(H & b, a)), Fr(0))     # H u {b} cons, H |- b -> a
    rho = sum((w for (H, w) in P if H & e & Uv.neg(a)), Fr(0))
    delta = sum((w for (H, w) in P if sub(H, b) and not sub(H, a)), Fr(0))
    # the two orders, computed directly from the predictor
    p1, _ = cr_pred(law, psiD, a)
    p2, _ = cr_pred(law, psiD & a, b)
    P_ab = p1 * p2
    q1, _ = cr_pred(law, psiD, b)
    q2, _ = cr_pred(law, psiD & b, a)
    P_ba = q1 * q2
    return dict(pa=pa, pb=pb, plb=plb, T=T_, rho=rho, delta=delta, P_ab=P_ab, P_ba=P_ba, Z=Z)


# ------------------------------------------------------------------ R1
def part_R1():
    out("=== R1: Prop 7.2(b)(a), CR order dependence of M_A itself, single pair at D = empty ===")
    J = 6
    Uv = U(1 + J)                      # atom 0 = a; atoms 1..J = s_1..s_J
    a = Uv.atoms[0]
    es = [Uv.conj_lits([(t, 0) for t in range(1, j)] + [(j, 1)]) for j in range(1, J + 1)]
    worst_id = Fr(0)
    worst_lb = Fr(0)
    worst_disj = Fr(-10)
    worst_count = -1e9
    npos = nneg = 0
    pairwise_ok = all(es[i] & es[j] == 0 for i in range(J) for j in range(i + 1, J))
    n_laws = 60
    for _ in range(n_laws):
        eps = Fr(rng.randint(2, 8), 16)
        law = [(0, Fr(rng.randint(0, 3), 64)), (a, Fr(rng.randint(1, 6), 64))]
        # adversarial short theories proving a v e_j without a
        for _ in range(rng.randint(1, 4)):
            j = rng.randrange(J)
            kind = rng.randrange(3)
            T = (Uv.neg(a) & es[j]) if kind == 0 else ((a | es[j]) if kind == 1 else ((a | es[j]) & Uv.rand_clause(2)))
            law.append((T, Fr(rng.randint(1, 12), 64)))
        for _ in range(rng.randint(0, 4)):     # random theories: conjunctions of clauses
            T = Uv.FULL
            for _ in range(rng.randint(1, 3)):
                T &= Uv.rand_clause(rng.randint(1, 3))
            law.append((T, Fr(rng.randint(1, 4), 128)))
        tot = sum((w for (_, w) in law), Fr(0))
        if tot > 1 - eps:
            law = [(T, w * (1 - eps) / tot) for (T, w) in law]
        law = normalise_with_empty(Uv, law)
        eps_empty = sum((w for (T, w) in law if T == Uv.FULL), Fr(0))
        bel0a = sum((w for (T, w) in law if T and sub(T, a)), Fr(0))
        deltas = []
        nonpos = 0
        for j in range(J):
            q = pair_quantities(Uv, law, Uv.FULL, a, es[j])
            N = q["pa"] * q["rho"] - q["delta"] * q["T"]
            ratio = q["P_ab"] / q["P_ba"]
            worst_id = max(worst_id, abs(ratio - (1 + N / (q["pb"] * q["T"]))))
            worst_id = max(worst_id, abs((q["plb"] - q["T"]) - q["rho"]), abs(q["pb"] - q["pa"] - q["delta"]))
            worst_lb = max(worst_lb, (q["pa"] * q["rho"] - q["delta"]) - N)       # N >= pa rho - delta
            assert q["rho"] >= eps_empty / q["Z"] >= eps_empty
            deltas.append(q["delta"])
            if N <= 0:
                nonpos += 1
                nneg += 1
            else:
                npos += 1
                assert ratio > 1
        worst_disj = max(worst_disj, sum(deltas) - 1)
        worst_count = max(worst_count, nonpos - float(1 / (bel0a * eps_empty)))
    out(f"{n_laws} laws (7 atoms: a, s_1..s_6), J = 6 incompatible e_j (pairwise incompatible: {pairwise_ok})")
    out(f"identities P_ab/P_ba = 1 + N/(Pr[H|-b] T), Pl(b) - T = rho, Pr[H|-b] = Pr[H|-a] + delta: max error = {float(worst_id):.1e} (exact)")
    out(f"N >= Pr[H|-a] rho - delta: max violation = {float(worst_lb):.1e}   [<= 0];  rho >= eps_empty: asserted in all")
    out(f"disjointness: max of sum_j delta_j - 1 = {float(worst_disj):.4f}   [<= 0]")
    out(f"count: max of #(j : N_j <= 0) - 1/(Bel_0(a) eps_empty) = {worst_count:.3f}   [<= 0]")
    out(f"pairs with N_j > 0 (order (a, a v e_j) strictly more probable): {npos}; with N_j <= 0: {nneg}")
    out()


# ------------------------------------------------------------------ R2
def part_R2():
    out("=== R2: Prop 7.2(b)(b), sequential pairs, adaptive j_i: linear CR order gap ===")
    for (n, J, nl) in ((2, 3, 8), (3, 3, 6), (2, 4, 6)):
        k = n * (1 + J)
        Uv = U(k)
        A = [Uv.atoms[i * (1 + J)] for i in range(n)]

        def e(i, j):
            base = i * (1 + J)
            return Uv.conj_lits([(base + t, 0) for t in range(1, j)] + [(base + j, 1)])

        allA = Uv.FULL
        for x in A:
            allA &= x
        min_margin = float("inf")
        ok_id = ok_lb = ok_half = 0
        n_half = 0
        total_pairs = 0
        min_gap_per_pair = float("inf")
        for _ in range(nl):
            eps = Fr(rng.randint(3, 8), 16)
            wA = Fr(rng.randint(2, 6), 64)
            law = [(0, Fr(rng.randint(0, 3), 64)), (allA, wA)]
            for _ in range(rng.randint(2, 6)):
                i = rng.randrange(n)
                j = rng.randrange(1, J + 1)
                kind = rng.randrange(2)
                T = (Uv.neg(A[i]) & e(i, j)) if kind == 0 else (A[i] | e(i, j))
                law.append((T, Fr(rng.randint(1, 10), 64)))
            tot = sum((w for (_, w) in law), Fr(0))
            if tot > 1 - eps:
                law = [(T, w * (1 - eps) / tot) for (T, w) in law]
                wA = wA * (1 - eps) / tot
            law = normalise_with_empty(Uv, law)
            eps_empty = sum((w for (T, w) in law if T == Uv.FULL), Fr(0))
            psiD = Uv.FULL
            chosen = []
            sum_log = 0.0
            for i in range(n):
                qs = [pair_quantities(Uv, law, psiD, A[i], e(i, j)) for j in range(1, J + 1)]
                jbest = min(range(J), key=lambda t: qs[t]["delta"])
                q = qs[jbest]
                N = q["pa"] * q["rho"] - q["delta"] * q["T"]
                ok_lb += int(N >= wA * eps_empty - q["delta"])
                if q["delta"] <= wA * eps_empty / 2:
                    n_half += 1
                    ok_half += int(lg(q["P_ab"] / q["P_ba"]) >= lg(1 + float(wA * eps_empty) / 2) - 1e-12)
                ok_id += int(q["P_ab"] / q["P_ba"] == 1 + N / (q["pb"] * q["T"]))
                total_pairs += 1
                sum_log += lg(q["P_ab"] / q["P_ba"])
                min_gap_per_pair = min(min_gap_per_pair, lg(1 + float(N)) if N > -1 else -1e9)
                chosen.append(e(i, jbest + 1))
                psiD = psiD & A[i] & (A[i] | e(i, jbest + 1))
            # total CR losses along the two complete orders
            def total(order):
                D = Uv.FULL
                L = 0.0
                for x in order:
                    p, _ = cr_pred(law, D, x)
                    L += -lg(p)
                    D &= x
                return L
            ordA, ordB = [], []
            for i in range(n):
                b = A[i] | chosen[i]
                ordA += [A[i], b]
                ordB += [b, A[i]]
            gap = total(ordB) - total(ordA)
            min_margin = min(min_margin, gap - sum_log)
            assert abs(gap - sum_log) < 1e-9, "per-pair decomposition must be exact"
        out(f"n = {n} pairs, J = {J}, {nl} laws: gap = sum of per-pair log ratios (|diff| < 1e-9) in all; "
            f"identity exact in {ok_id} of {total_pairs} pairs; N_i >= w_A eps - delta_i in {ok_lb} of {total_pairs}; "
            f"pairs with delta_i <= w_A eps/2: {n_half}, each contributing >= log(1 + w_A eps/2) in {ok_half} of {n_half}; "
            f"min per-pair log(1+N_i) = {min_gap_per_pair:.4f}")
    out()


# ------------------------------------------------------------------ R3
def part_R3():
    out("=== R3: Prop 7.3(e), Moebius mass of (undefined, undefined) on the inputs (phi, not phi) ===")
    Uv = U(3)
    F = Uv.FULL
    worst_half = Fr(0)
    worst_M = Fr(0)
    neg_half = neg_M = undecided_pos = 0
    n_laws = 150
    for _ in range(n_laws):
        law = [(0, Fr(rng.randint(0, 3), 32))]
        for _ in range(rng.randint(1, 6)):
            law.append((rng.getrandbits(Uv.nv) & F, Fr(rng.randint(1, 6), 64)))
        tot = sum((w for (_, w) in law), Fr(0))
        if tot > Fr(3, 4):
            law = [(T, w * Fr(3, 4) / tot) for (T, w) in law]
        law = normalise_with_empty(Uv, law)
        phi = rng.getrandbits(Uv.nv) & F
        nphi = F & ~phi

        def Mhalf(D):
            s = Fr(0)
            for (T, w) in law:
                if T == 0:
                    continue
                p = T
                val = Fr(1)
                for (m, b) in D:
                    lit = m if b == 1 else F & ~m
                    p &= lit
                    if not sub(T, lit):
                        val /= 2
                if p == 0:
                    continue
                s += w * val
            return s

        def M(D):
            p = F
            for (m, b) in D:
                p &= m if b == 1 else F & ~m
            return sum((w for (T, w) in law if T and sub(T, p)), Fr(0))

        def mob(f):
            tot = f([])
            tot -= sum(f([(phi, b)]) for b in (0, 1))
            tot -= sum(f([(nphi, b)]) for b in (0, 1))
            tot += sum(f([(phi, b), (nphi, c)]) for b in (0, 1) for c in (0, 1))
            return tot

        und = sum((w for (T, w) in law if T and not sub(T, phi) and not sub(T, nphi)), Fr(0))
        mh, mm = mob(Mhalf), mob(M)
        worst_half = max(worst_half, abs(mh + und / 2))
        worst_M = max(worst_M, abs(mm - und))
        undecided_pos += int(und > 0)
        neg_half += int(mh < 0)
        neg_M += int(mm < 0)
    out(f"{n_laws} random laws on 3 atoms, random phi: max |Moebius(M_half) + undecided/2| = {float(worst_half):.1e}; "
        f"max |Moebius(M) - undecided| = {float(worst_M):.1e} (exact)")
    out(f"undecided mass > 0 in {undecided_pos} laws; Moebius mass negative for M_half in {neg_half}, for M in {neg_M}")
    out()


# ------------------------------------------------------------------ R4
def part_R4():
    out("=== R4: Prop 10.1(a),(e),(f): Demski's process, the theory-drawing process, a single draw ===")
    k = 2
    Uv = U(k)
    F = Uv.FULL
    props = list(range(1 << Uv.nv))           # all 16 propositions (as sentences / as theories)

    def absorb(mu):
        """mu: dict proposition -> prob (draw law).  State S = model set of what has been kept
        (nonempty).  A draw x is kept iff S & x != 0; then S -> S & x.  Returns the law of the final
        state from S = FULL, as a dict, computed exactly (recursion on the size of S)."""
        @lru_cache(maxsize=None)
        def fin(S):
            if bin(S).count("1") == 1:
                return ((S, Fr(1)),)
            stay = sum((p for x, p in mu.items() if (S & x) in (0, S)), Fr(0))
            acc = {}
            for x, p in mu.items():
                S2 = S & x
                if S2 == 0 or S2 == S:
                    continue
                for (T, q) in fin(S2):
                    acc[T] = acc.get(T, Fr(0)) + p * q / (1 - stay)
            return tuple(sorted(acc.items()))
        return dict(fin(F))

    res = []
    for trial in range(4):
        raw = {x: Fr(rng.randint(1, 9)) for x in props}
        Z = sum(raw.values())
        mu = {x: r / Z for x, r in raw.items()}
        law_final = absorb(mu)
        tot = sum(law_final.values())
        inc_mass = sum((p for T, p in law_final.items() if bin(T).count("1") != 1), Fr(0))
        coh = max(abs(sum((p for T, p in law_final.items() if sub(T, x)), Fr(0))
                      + sum((p for T, p in law_final.items() if sub(T, F & ~x)), Fr(0)) - 1) for x in props)
        # single draw (the M_A form): independent mass of atom 0 among consistent draws
        a = Uv.atoms[0]
        indep = sum((p for x, p in mu.items() if x and not sub(x, a) and not sub(x, F & ~a)), Fr(0))
        res.append((tot, inc_mass, coh, indep))
    out("Demski's process (draw a sentence; keep it iff consistent with what is kept) and the theory-drawing")
    out("process (draw a theory = output of a machine on random bits; keep it iff consistent) have the same")
    out("finite stand-in: a full-support draw law over the 16 propositions of 2 atoms (0 = inconsistent draw).")
    for i, (tot, inc_mass, coh, indep) in enumerate(res):
        out(f"  law {i}: total final mass {tot}; mass on incomplete final theories {inc_mass}; "
            f"max |P(x) + P(not x) - 1| = {float(coh):.1e}; single draw: independent mass of an atom = {float(indep):.4f}")
    # (f): complete theories: proves iff consistent with
    ok = all((sub(1 << v, x)) == bool((1 << v) & x) for v in range(Uv.nv) for x in props)
    out(f"(f) for every complete theory {{v}} and proposition x: proves x iff consistent with x: {ok}")
    out()


# ------------------------------------------------------------------ R5
def part_R5():
    out("=== R5: Cor 8.8, zero local defect at every sentence <=> consistent outcomes complete ===")
    Uv = U(3)
    F = Uv.FULL
    agree = 0
    n = 200
    zero = 0
    for _ in range(n):
        law = [(0, Fr(rng.randint(0, 2), 16))]
        complete_only = rng.random() < 0.5
        for _ in range(rng.randint(1, 5)):
            T = (1 << rng.randrange(Uv.nv)) if complete_only else (rng.getrandbits(Uv.nv) & F)
            law.append((T, Fr(rng.randint(1, 6), 64)))
        tot = sum((w for (_, w) in law), Fr(0))
        law = [(T, w / tot) for (T, w) in law]          # no empty-theory remainder here: a general law
        defect0 = all(sum((w for (T, w) in law if T and not sub(T, x) and not sub(T, F & ~x)), Fr(0)) == 0
                      for x in range(1 << Uv.nv))
        allcomplete = all(bin(T).count("1") == 1 for (T, w) in law if T)
        agree += int(defect0 == allcomplete)
        zero += int(defect0)
    out(f"{n} random laws on 3 atoms: (defect 0 at all 256 sentences) == (all consistent outcomes complete) in {agree} of {n}; "
        f"laws with zero defect: {zero}")
    out()


if __name__ == "__main__":
    out(f"seed {SEED}")
    part_R1()
    part_R2()
    part_R3()
    part_R4()
    part_R5()
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "c5_revision.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")

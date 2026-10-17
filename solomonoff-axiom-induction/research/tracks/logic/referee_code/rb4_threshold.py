"""rb4_threshold.py -- referee B (thread `logic`): the threshold constructions of notes.md
Thm 3.1 (threshold theories T_k), Thm 3.2 (the threshold machine G*, simulated bit by bit),
Thm 4.4 (the prefix sets U_w and the longest-prefix case analysis of the companion G**) and
Remark 3.4 (the coin-free sum over dyadic levels), in finite models with a NON-dyadic
inconsistency mass Inc, as for the real Inc_0 (irrational).  Independent of the developer's c3,
whose weights are dyadic (so that 0.w = Inc can occur there).

Seed 20261016.  Output: rb4_threshold.out (stdout).  Exact rational arithmetic throughout.

Finite stand-in.  m tapes with integer weights summing to Z = 3^7 = 2187, so every mass is
k/2187 and is dyadic only if it is 0 or 1; at least one inconsistent tape and one consistent tape,
so Inc is strictly between 0 and 1 and non-dyadic.  Atoms: true and false Pi_1 atoms; a consistent
tape proves a set of TRUE atoms only ((Pi_1 T)); an inconsistent tape proves everything.  A Pi_1*
sentence is a nonempty set S of atoms (their conjunction); U(S) := Unif(O_S); Bel(S) := U(S) - Inc.

R1 (Thm 3.1)  for k = 0..16: I'_k = floor(2^(k+2) Inc) / 2^(k+2) is given by an integer < 2^(k+2)
     (k+2 bits); T_k := {S : U(S) > I'_k + 2^-(k+2)} contains every S with Bel(S) >= 2^-k and only
     sets of true atoms with Bel > 0.
R2 (Thm 3.2)  for non-dyadic tapes r (odd denominators) the machine G* is SIMULATED: after s bits it
     emits {S : U(S) > 0.r_{1:s} + 2^-s}; the union over s <= 80 equals A_r := {S : U(S) > r}.
     nu_{G*}(D) = Leb{r : A_r consistent and proves D} is computed from the simulation on a grid of
     3^9 tapes and compared with the closed form max(0, min_{a in D} U({a}) - Inc) and with
     M(D) = U(D) - Inc (claim: nu >= M).
R3 (Thm 4.4)  for non-dyadic r > Inc and all prefixes w of r (length <= 60):
     U_w (computed as the union of G*'s emissions over prefixes of w and over the extensions w0^j)
     equals {S : U(S) > 0.w}; U_w is consistent iff 0.w > Inc (STRICT: 0.w = Inc never occurs);
     U_{w'} subset of U_w for w prefix of w'; A_r subset of U_w; the prefixes with 0.w > Inc form a
     nonempty final segment; and for random finite sets of prefixes the longest one w* satisfies
     the case analysis of the proof (0.w* < Inc => every U_{w_i} inconsistent; 0.w* > Inc =>
     U_{w*} consistent, U_{w*} subset of every U_{w_i}, A_r subset of U_{w*}).
R4 (Rem 3.4)  for intervals (a, b) of length >= 2^-k, with weights g(L) := 2^-L * 2^-Kp(L),
     Kp(L) := 2 ceil(log2(L+1)) + 1 a stand-in for K(L):
       S_rep  = sum_{L>=k+1} #{j : j/2^L in (a,b)} g(L)   (indices of the pairs (j, L))
       S_dist = sum over DISTINCT dyadics q in (a,b) of g(level(q))   (indices of the rationals)
       bound  = sum_{L>=k+1} 2^(L-k-1) g(L)               (the record's displayed sum)
       bound2 = sum_{L>=k+2} 2^(L-k-2) g(L)               (the odd-numerator fix)
     (dyadics q of level <= k+12 only; all sums truncated at level k+12; level(q) := the exact level,
     i.e. q = odd/2^level).  Intervals: random, aligned (m 2^-k, (m+1) 2^-k) and half-shifted.
     Tested: the per-level count under both readings of "dyadic rationals of level L" (all
     multiples of 2^-L; exact level L); S_rep >= bound (referee A's fix 1); S_dist >= bound2
     (fix 2); S_dist >= bound (the conclusion with one index per rational); and the proof's step
     "W_A >= sum_L (count at level L) g(L)" with one index per rational, i.e. S_dist >= S_rep
     (the double count found by referee A, m6).
"""
import random
from fractions import Fraction
from math import ceil, log2, floor

SEED = 20261016
rng = random.Random(SEED)
Z = 3 ** 7


def instance():
    n_true, n_false = rng.randint(3, 7), rng.randint(1, 3)
    atoms = [("t", i) for i in range(n_true)] + [("f", i) for i in range(n_false)]
    m = rng.randint(4, 25)
    while True:
        cuts = sorted(rng.sample(range(1, Z), m - 1))
        pts = [0] + cuts + [Z]
        ws = [Fraction(pts[i + 1] - pts[i], Z) for i in range(m)]
        p_inc = rng.choice([0.1, 0.3, 0.5])
        tapes = []
        for _ in range(m):
            if rng.random() < p_inc:
                tapes.append(None)
            else:
                q = rng.random()
                tapes.append(frozenset(a for a in atoms if a[0] == "t" and rng.random() < q))
        if any(t is None for t in tapes) and any(t is not None for t in tapes):
            return atoms, ws, tapes


def all_sentences(atoms):
    out = []
    n = len(atoms)
    for mask in range(1, 1 << n):
        out.append(frozenset(atoms[i] for i in range(n) if mask >> i & 1))
    return out


def U(ws, tapes, S):
    return sum((w for w, th in zip(ws, tapes) if th is None or S <= th), Fraction(0))


def bits_of(r, nbits):
    out = []
    x = r
    for _ in range(nbits):
        x *= 2
        b = 1 if x >= 1 else 0
        out.append(b)
        x -= b
    return out


def val(bits):
    return sum((Fraction(b, 2 ** (i + 1)) for i, b in enumerate(bits)), Fraction(0))


def is_dyadic(q):
    d = q.denominator
    return d & (d - 1) == 0


def run_r1_r3(trials=100):
    v = {k: 0 for k in ("R1", "R2", "R2nu", "R3")}
    n = {k: 0 for k in v}
    boundary = 0
    for _ in range(trials):
        atoms, ws, tapes = instance()
        inc = sum((w for w, th in zip(ws, tapes) if th is None), Fraction(0))
        assert 0 < inc < 1 and not is_dyadic(inc)
        sents = all_sentences(atoms)
        Uv = {S: U(ws, tapes, S) for S in sents}
        # R1
        for k in range(17):
            sc = 2 ** (k + 2)
            num = floor(inc * sc)
            Ip = Fraction(num, sc)
            if not (0 <= num < sc and Ip <= inc < Ip + Fraction(1, sc)):
                v["R1"] += 1
            thr = Ip + Fraction(1, sc)
            for S in sents:
                n["R1"] += 1
                bel = Uv[S] - inc
                inT = Uv[S] > thr
                if bel >= Fraction(1, 2 ** k) and not inT:
                    v["R1"] += 1
                if inT and not (bel > 0 and all(a[0] == "t" for a in S)):
                    v["R1"] += 1
        # R2: simulate G* on non-dyadic tapes.  The union over s of {S : U(S) > thr_s} is
        # {S : U(S) > min_s thr_s} (finitely many thresholds), computed that way.
        for _ in range(4):
            r = Fraction(rng.randrange(1, 3 ** 9), 3 ** 9)
            if is_dyadic(r):
                continue
            bits = bits_of(r, 80)
            thr_min = min(val(bits[:s]) + Fraction(1, 2 ** s) for s in range(1, 81))
            emitted = {S for S in sents if Uv[S] > thr_min}
            Ar = {S for S in sents if Uv[S] > r}
            n["R2"] += 1
            if emitted != Ar:
                v["R2"] += 1
            # consistency of A_r iff r > inc
            cons = all(all(a[0] == "t" for a in S) for S in Ar)
            if cons != (r > inc):
                v["R2"] += 1
        # nu_{G*}(D) on a grid of tapes, vs closed form and vs M(D)
        G = 3 ** 6
        # A_r = {S : U(S) > r} is consistent iff every S containing a false atom has U(S) <= r, and
        # proves atom a iff some S containing a has U(S) > r: precompute the two maxima over ALL
        # sentences (not only singletons, so this is a separate route from the closed form)
        ufalse = max(Uv[S] for S in sents if any(a[0] == "f" for a in S))
        uatom = {a: max(Uv[S] for S in sents if a in S) for a in atoms}
        for _ in range(3):
            D = frozenset(rng.sample(atoms, rng.randint(1, min(3, len(atoms)))))
            closed = max(Fraction(0), min(Uv[frozenset([a])] for a in D) - inc)
            M = Uv[D] - inc
            good = 0
            for i in range(G):
                r = Fraction(2 * i + 1, 2 * G)          # denominator 2*3^6: never dyadic
                cons = ufalse <= r
                proves = all(uatom[a] > r for a in D)
                good += cons and proves
            nu_grid = Fraction(good, G)
            n["R2nu"] += 1
            if abs(nu_grid - closed) > Fraction(2, G) or closed < M:
                v["R2nu"] += 1
        # R3: prefixes
        for _ in range(4):
            r = inc + (1 - inc) * Fraction(rng.randrange(1, 3 ** 9), 3 ** 9)
            if is_dyadic(r) or not (inc < r < 1):
                continue
            bits = bits_of(r, 60)
            Ar = {S for S in sents if Uv[S] > r}
            prev_U = None
            cons_seen = False
            Ulist = []
            for L in range(0, 61):
                w = bits[:L]
                ow = val(w)
                if ow == inc:
                    boundary += 1
                # U_w as union of emissions: prefixes u of w, and extensions w + 0^j (j <= 60);
                # a union of {S : U(S) > thr} over finitely many thresholds is {S : U(S) > min thr}
                thrs = [val(bits[:Lu]) + Fraction(1, 2 ** Lu) for Lu in range(1, L + 1)]
                thrs += [ow + Fraction(1, 2 ** (L + j)) for j in range(0, 61) if L + j > 0]
                tmin = min(thrs)
                em = {S for S in sents if Uv[S] > tmin}
                Uw = {S for S in sents if Uv[S] > ow}
                n["R3"] += 1
                if em != Uw:
                    v["R3"] += 1
                cons = all(all(a[0] == "t" for a in S) for S in Uw)
                if cons != (ow > inc):
                    v["R3"] += 1
                if prev_U is not None and not Uw <= prev_U:
                    v["R3"] += 1
                if not Ar <= Uw:
                    v["R3"] += 1
                if cons_seen and not cons:
                    v["R3"] += 1               # consistent prefixes must form a final segment
                cons_seen |= cons
                prev_U = Uw
                Ulist.append((ow, Uw, cons))
            if not cons_seen:
                v["R3"] += 1                   # some prefix must have 0.w > Inc
            # longest-prefix case analysis on random finite sets of prefixes
            for _ in range(20):
                Ls = sorted(rng.sample(range(0, 61), rng.randint(1, 6)))
                Lstar = Ls[-1]
                ow_s, U_s, c_s = Ulist[Lstar]
                if ow_s < inc:
                    if any(Ulist[L][2] for L in Ls):
                        v["R3"] += 1
                else:
                    if not (c_s and all(U_s <= Ulist[L][1] for L in Ls) and Ar <= U_s):
                        v["R3"] += 1
    return v, n, boundary


def run_r4():
    def Kp(L):
        return 2 * ceil(log2(L + 1)) + 1

    def g(L):
        return Fraction(1, 2 ** (L + Kp(L)))

    def level(q):
        return q.denominator.bit_length() - 1

    span = 12                       # levels k+1 .. k+span (all sums truncated at the same level)
    st = {"cases": 0, "readA": 0, "readB": 0, "rep": 0, "dist": 0, "dist2": 0, "step": 0}
    worst = {"dist": None, "step": None}
    for k in range(0, 9):
        top = k + span
        bound = sum((2 ** (L - k - 1) * g(L) for L in range(k + 1, top + 1)), Fraction(0))
        bound2 = sum((2 ** (L - k - 2) * g(L) for L in range(k + 2, top + 1)), Fraction(0))
        h = Fraction(1, 2 ** k)
        intervals = []
        for _ in range(60):
            a = Fraction(rng.randrange(0, 2 ** 20), 2 ** 20) * (1 - h)
            length = h * (1 + Fraction(rng.randrange(0, 2 ** 10), 2 ** 12))
            intervals.append((a, min(a + length, Fraction(1))))
        for m in range(0, min(2 ** k, 4)):
            intervals.append((m * h, (m + 1) * h))                                 # aligned
            if (m + 1) * h + h / 2 <= 1:
                intervals.append((m * h + h / 2, (m + 1) * h + h / 2))             # half-shifted
        for (a, b) in intervals:
            if b - a < h:
                continue
            st["cases"] += 1
            S_rep = Fraction(0)
            seen = {}
            for L in range(k + 1, top + 1):
                lo = floor(a * 2 ** L) + 1
                hi = -((-(b * 2 ** L)) // 1) - 1
                cnt = max(0, hi - lo + 1)
                if cnt < 2 ** (L - k - 1):
                    st["readA"] += 1                     # multiples of 2^-L
                exact = sum(1 for j in range(lo, hi + 1) if j % 2 == 1)
                if exact < 2 ** (L - k - 1):
                    st["readB"] += 1                     # exact level L (odd numerators)
                S_rep += cnt * g(L)
                for j in range(lo, hi + 1):
                    q = Fraction(j, 2 ** L)
                    seen[q] = level(q)
            S_dist = sum((g(lv) for lv in seen.values()), Fraction(0))
            if S_rep < bound:
                st["rep"] += 1
            if S_dist < bound2:
                st["dist2"] += 1
            r1 = S_dist / bound
            worst["dist"] = r1 if worst["dist"] is None else min(worst["dist"], r1)
            if S_dist < bound:
                st["dist"] += 1
            r2 = S_dist / S_rep
            worst["step"] = r2 if worst["step"] is None else min(worst["step"], r2)
            if S_dist < S_rep:
                st["step"] += 1
    return st, worst


if __name__ == "__main__":
    print(f"seed {SEED}; Z = 3^7 = {Z}")
    v, n, boundary = run_r1_r3()
    print(f"R1 threshold theories T_k (k=0..16): {v['R1']} violations in {n['R1']} (sentence, k) checks")
    print(f"R2 G* simulated on non-dyadic tapes: emissions = A_r and A_r consistent iff r > Inc: "
          f"{v['R2']} violations in {n['R2']} tapes")
    print(f"   nu_G*(D) on a 3^6 grid vs closed form (within 2/3^6) and >= M(D): {v['R2nu']} violations in {n['R2nu']} data sets")
    print(f"R3 prefixes w (<= 60 bits): U_w = union of emissions = {{S: U(S) > 0.w}}; consistent iff 0.w > Inc (strict); "
          f"monotone; A_r inside; final segment; longest-prefix analysis: {v['R3']} violations in {n['R3']} prefix checks; "
          f"boundary cases 0.w = Inc: {boundary}")
    st, worst = run_r4()
    print(f"R4 Remark 3.4 on {st['cases']} intervals of length >= 2^-k (k = 0..8; random, aligned, half-shifted):")
    print(f"   per-level count, reading 'multiples of 2^-L' >= 2^(L-k-1): failures {st['readA']}")
    print(f"   per-level count, reading 'exact level L (odd numerator)' >= 2^(L-k-1): failures {st['readB']}")
    print(f"   S_rep  >= displayed bound (index per pair (j, L), referee A's fix 1): failures {st['rep']}")
    print(f"   S_dist >= odd-numerator bound from level k+2 (referee A's fix 2): failures {st['dist2']}")
    print(f"   S_dist >= displayed bound (index per rational): failures {st['dist']}; min S_dist/bound = {float(worst['dist']):.4f}")
    print(f"   the step 'W_A >= sum_L (multiples at level L) g(L)' with one index per rational, i.e. S_dist >= S_rep: "
          f"failures {st['step']}; min S_dist/S_rep = {float(worst['step']):.4f}")
    assert v["R1"] == v["R2"] == v["R2nu"] == v["R3"] == 0 and boundary == 0 and st["rep"] == 0 and st["dist2"] == 0 and st["readA"] == 0
    print("all assertions passed")

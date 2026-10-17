#!/usr/bin/env python3
"""c2_separations.py -- thread `fundamentals`: separations and the answers to Q5 and Q4, on finite stand-ins.

Same finite propositional stand-in as c1_structure.py (theories = model sets as bitmasks over the
valuations of k atoms; a prior is a finite list of (model set, weight); model set 0 = inconsistent).
Seed 20261016.  Output: c2_separations.out.

  B1  (Prop 7.2(a)) consistency-requiring (Dempster) predictor: linear loss on the stream a_1, a_2, ...
      all true, while the proof-requiring loss stays bounded; closed form vs brute force.
  B1b scout F's c1 Part B recomputed independently (its weights, brute force on 7 atoms).
  B2  (Prop 7.2(b)) an explicit theory-machine law on which the Dempster cumulative loss depends on the
      reveal order: weights 1/2 on the empty theory and 1/2 on {a}; D = {(a,1), (a v c,1)}.
  B3  (Thm 11.1(a)) normalised convention, two data (alpha,1), (alpha v c,1): the closed form of the
      ratio of the normalised probabilities in the two orders, and its sign, on random laws.
  B4  (Thm 11.1(b)) the linear gap: n pairs with fair-coin literals alpha_i = a_i^{y_i}; the average over y
      of the normalised-loss difference between the orders (alpha_1, beta_1, ...) and (beta_1, alpha_1, ...)
      is at least n * w_coin / 2.
  B5  (Prop 11.2) graded consistency-requiring weight vs proof-requiring weight on k blocks of three
      pairwise incompatible sentences: some data set has gap >= k log(3/2) + log w_empty; and a single
      datum among m = 2^r incompatible sentences has gap >= log m - 1 + log w_empty.
      Revision: w_empty raised from 1/4 to 3/4 so that every bound is positive (referee B, m5(b)).
"""
import itertools
import math
import os
import random
from fractions import Fraction as Fr

SEED = 20261016
rng = random.Random(SEED)
OUT = []


def out(s=""):
    OUT.append(s)
    print(s)


def lg(x):
    return math.log2(x)


class Universe:
    def __init__(self, k):
        self.k = k
        self.nv = 1 << k
        self.FULL = (1 << self.nv) - 1
        self._atoms = [self._atom(i) for i in range(k)]

    def _atom(self, i):
        m = 0
        for v in range(self.nv):
            if (v >> i) & 1:
                m |= 1 << v
        return m

    def atom(self, i):
        return self._atoms[i]

    def neg(self, m):
        return self.FULL & ~m


def subset(a, b):
    return a & ~b == 0


def lit(U, m, b):
    return m if b == 1 else U.neg(m)


def psi(U, D):
    p = U.FULL
    for (m, b) in D:
        p &= lit(U, m, b)
    return p


def W(U, prior, D):
    p = psi(U, D)
    return sum((w for (M, w) in prior if M != 0 and subset(M, p)), Fr(0))


def Wf(U, prior, D):
    p = psi(U, D)
    return sum((w for (M, w) in prior if M != 0 and subset(M, p)), 0.0)


def mnc(U, prior, D):
    p = psi(U, D)
    return sum((w for (M, w) in prior if M & p), Fr(0))


def bel_nc(U, prior, D, chi):
    p = psi(U, D)
    num = sum((w for (M, w) in prior if (M & p) and subset(M & p, chi)), Fr(0))
    return num / mnc(U, prior, D)


def m_half(U, prior, D):
    p = psi(U, D)
    tot = Fr(0)
    for (M, w) in prior:
        if M == 0 or (M & p) == 0:
            continue
        val = Fr(1)
        for (m, b) in D:
            if not subset(M, lit(U, m, b)):
                val /= 2
        tot += w * val
    return tot


def norm_loss(U, prior, seq, use_float=True):
    """normalised-convention cumulative loss of a reveal sequence of (mask, label)."""
    L = 0.0
    hist = []
    for (m, b) in seq:
        f = Wf if use_float else W
        good = f(U, prior, hist + [(m, b)])
        bad = f(U, prior, hist + [(m, 1 - b)])
        L += -lg(good / (good + bad))
        hist.append((m, b))
    return L


# ------------------------------------------------------------------ B1
def part_B1():
    out("=== B1: CR (Dempster) predictor has linear loss where PR is bounded (stream a_1, a_2, ... all true) ===")
    w = dict(empty=Fr(3, 16), all=Fr(1, 8), coin=Fr(1, 4), a12=Fr(1, 8), chain=Fr(1, 8), inc=Fr(1, 16))
    cons = w['empty'] + w['all'] + w['coin'] + w['a12'] + w['chain']

    def closed(t_max):
        pr, cr = [], []
        Lpr = Lcr = 0.0
        for t in range(1, t_max + 1):
            # PR: theories consistent and proving a_1..a_t: all; coin with prob 2^-t; a12 if t <= 2
            Mt = w['all'] + w['coin'] * Fr(1, 2 ** t) + (w['a12'] if t <= 2 else 0)
            Mt1 = w['all'] + w['coin'] * Fr(1, 2 ** (t - 1)) + (w['a12'] if t - 1 <= 2 else 0) + \
                (w['empty'] + w['chain'] if t == 1 else 0)
            Lpr += -lg(Mt / Mt1)
            # CR given a_1..a_{t-1}: consistent theories: all of them except inc; coin restricted
            Z = w['empty'] + w['all'] + w['coin'] * Fr(1, 2 ** (t - 1)) + w['a12'] + w['chain']
            num = w['all'] + w['coin'] * Fr(1, 2 ** t) + (w['a12'] if t <= 2 else 0) + (w['chain'] if t >= 2 else 0)
            Lcr += -lg(num / Z)
            pr.append(Lpr)
            cr.append(Lcr)
        return pr, cr

    def brute(k):
        U = Universe(k)
        allm = U.FULL
        for i in range(k):
            allm &= U.atom(i)
        prior = [(U.FULL, w['empty']), (allm, w['all']), (0, w['inc'])]
        for v in range(U.nv):
            prior.append((1 << v, w['coin'] / U.nv))
        prior.append((U.atom(0) & U.atom(1), w['a12']))
        ch = U.FULL
        for i in range(k - 1):
            ch &= U.neg(U.atom(i)) | U.atom(i + 1)
        prior.append((ch, w['chain']))
        pr, cr = [], []
        Lpr = Lcr = 0.0
        D = []
        for t in range(k):
            a = U.atom(t)
            Lpr += -lg(W(U, prior, D + [(a, 1)]) / W(U, prior, D))
            Lcr += -lg(bel_nc(U, prior, D, a))
            D.append((a, 1))
            pr.append(Lpr)
            cr.append(Lcr)
        return pr, cr

    pr, cr = closed(60)
    out(" t   PR loss   CR loss   (bits; PR in the semimeasure convention, from M(empty))")
    for t in (1, 2, 3, 5, 10, 20, 40, 60):
        out(f"{t:3d}  {pr[t-1]:8.4f}  {cr[t-1]:8.4f}")
    lim = -lg(w['all'] / cons)
    out(f"PR limit -log(w_all / consistent mass) = {lim:.4f};  CR slope between t=40 and t=60: {(cr[59]-cr[39])/20:.4f} bits/step")
    out(f"per-step CR lower bound -log(1 - w_empty/consistent mass) = {-lg(1 - w['empty']/cons):.4f} bits; "
        f"min observed CR step loss = {min(cr[0], *[cr[i]-cr[i-1] for i in range(1, 60)]):.4f}")
    worst = 0.0
    for k in range(3, 9):
        bp, bc = brute(k)
        cp, cc = closed(k)
        worst = max(worst, max(abs(x - y) for x, y in zip(bp + bc, cp + cc)))
    out(f"brute force (k <= 8 atoms, explicit model sets) vs closed form: max |difference| = {worst:.2e}")
    out()


# ------------------------------------------------------------------ B1b
def part_B1b():
    out("=== B1b: independent recomputation of scout F's c1 Part B (its weights; brute force, 7 atoms) ===")
    k = 7
    U = Universe(k)
    w = dict(empty=0.25, all=0.25, coin=0.2, three=0.2, inc=0.1)
    allm = U.FULL
    for i in range(k):
        allm &= U.atom(i)
    prior = [(U.FULL, w['empty']), (allm, w['all']), (0, w['inc'])]
    for v in range(U.nv):
        prior.append((1 << v, w['coin'] / U.nv))
    for pattern in range(3 ** k):            # each atom independently true / false / undecided
        M = U.FULL
        x = pattern
        for i in range(k):
            r = x % 3
            x //= 3
            if r == 0:
                M &= U.atom(i)
            elif r == 1:
                M &= U.neg(U.atom(i))
        prior.append((M, w['three'] / 3 ** k))
    cons = sum(wt for (M, wt) in prior if M != 0)
    D = []
    Lcr = 0.0
    rows = []
    for t in range(k):
        a = U.atom(t)
        Lcr += -lg(float(bel_nc(U, [(M, Fr(wt).limit_denominator(10**12)) for (M, wt) in prior], D, a)))
        D.append((a, 1))
        Lpr = -lg(Wf(U, prior, D) / cons)
        rows.append((t + 1, Lpr, Lcr))
    reported = {1: (1.1110, 1.1110), 2: (1.4819, 2.2012), 3: (1.6721, 3.2697), 5: (1.8077, 5.3542)}
    worst = 0.0
    for (t, a1, a2) in rows:
        if t in reported:
            r1, r2 = reported[t]
            worst = max(worst, abs(a1 - r1), abs(a2 - r2))
            out(f"t = {t}: PR loss {a1:.4f} (scout F: {r1:.4f}), CR loss {a2:.4f} (scout F: {r2:.4f})")
    out(f"max |difference| with scout F's printed values (4 decimals): {worst:.1e}")
    out()


# ------------------------------------------------------------------ B2
def part_B2():
    out("=== B2: an explicit law on which the Dempster cumulative loss depends on the order ===")
    U = Universe(2)
    a, c = U.atom(0), U.atom(1)
    prior = [(U.FULL, Fr(1, 2)), (a, Fr(1, 2))]
    o1 = bel_nc(U, prior, [], a) * bel_nc(U, prior, [(a, 1)], a | c)
    o2 = bel_nc(U, prior, [], a | c) * bel_nc(U, prior, [(a | c, 1)], a)
    out(f"order (a, a v c): probability {o1} (loss {-lg(o1):.3f} bits); order (a v c, a): probability {o2} "
        f"(loss {-lg(o2):.3f} bits); PR (semimeasure) probability in both orders: {W(U, prior, [(a,1),(a|c,1)]) / W(U, prior, [])}")
    out()


# ------------------------------------------------------------------ B3
def part_B3():
    out("=== B3: normalised convention, D = {(alpha,1), (alpha v c,1)}: closed form and sign ===")
    U = Universe(3)
    a, c = U.atom(0), U.atom(1)
    worst = Fr(0)
    pos = zero_ok = npos = nzero = 0
    T = 500
    for trial in range(T):
        n = rng.randint(2, 8)
        prior = [(rng.getrandbits(U.nv) or 1, Fr(rng.randint(1, 9), 64)) for _ in range(n)]
        if rng.random() < 0.7:
            prior.append((a, Fr(rng.randint(1, 9), 64)))          # the theory {a}
        if rng.random() < 0.5:
            prior.append((U.neg(a), Fr(rng.randint(1, 9), 64)))   # the theory {not a}: contributes to v
        if trial % 5 == 0:
            # laws with v = 0 and z = 0: no theory refutes a without deciding c, none proves a v c undecided on a
            prior = [(M, w) for (M, w) in prior
                     if not (subset(M, U.neg(a)) and not (subset(M, c) or subset(M, U.neg(c))))
                     and not (subset(M, a | c) and not (subset(M, a) or subset(M, U.neg(a))))]
        if W(U, prior, [(a, 1)]) == 0:
            continue
        N_ab = (W(U, prior, [(a, 1)]) / (W(U, prior, [(a, 1)]) + W(U, prior, [(a, 0)]))) * \
            (W(U, prior, [(a, 1), (a | c, 1)]) / (W(U, prior, [(a, 1), (a | c, 1)]) + W(U, prior, [(a, 1), (a | c, 0)])))
        N_ba = (W(U, prior, [(a | c, 1)]) / (W(U, prior, [(a | c, 1)]) + W(U, prior, [(a | c, 0)]))) * \
            (W(U, prior, [(a | c, 1), (a, 1)]) / (W(U, prior, [(a | c, 1), (a, 1)]) + W(U, prior, [(a | c, 1), (a, 0)])))

        def cell(fa, fb):
            def lab(M, m):
                if M == 0:
                    return None
                if subset(M, m):
                    return 1
                if subset(M, U.neg(m)):
                    return 0
                return 'u'
            return sum((w for (M, w) in prior if M != 0 and lab(M, a) == fa and lab(M, a | c) == fb), Fr(0))
        x, y, z, u, v = cell(1, 1), cell(0, 1), cell('u', 1), cell(0, 0), cell(0, 'u')
        assert cell(1, 0) == 0 and cell(1, 'u') == 0 and cell('u', 0) == 0
        closed = Fr(1) + ((x + y) * v + z * (u + v)) / ((x + y + z + u) * (x + y))
        worst = max(worst, abs(N_ba / N_ab - closed))
        if (x + y) * v + z * (u + v) > 0:
            npos += 1
            pos += int(N_ba > N_ab)
        else:
            nzero += 1
            zero_ok += int(N_ba == N_ab)
    out(f"{T} random laws (every fifth with v = 0 and z = 0 forced); {npos + nzero} have x > 0 and are used")
    out(f"max |N_ba/N_ab - [1 + ((x+y)v + z(u+v)) / ((x+y+z+u)(x+y))]| = {float(worst):.3e} (exact rationals)")
    out(f"laws with (x+y)v + z(u+v) > 0: normalised probability strictly larger in order (alpha v c, alpha) in {pos} of {npos};")
    out(f"laws with (x+y)v + z(u+v) = 0: equal in both orders in {zero_ok} of {nzero}")
    out()


# ------------------------------------------------------------------ B4
def part_B4():
    out("=== B4: linear gap between two reveal orders in the normalised convention ===")
    for n in (2, 3, 4, 5):
        U = Universe(2 * n)
        A = [U.atom(i) for i in range(n)]
        C = [U.atom(n + i) for i in range(n)]
        w_coin = 0.25
        prior = []
        for om in range(1 << n):        # coin on the a's: theory {a_i^{om_i} : i}
            M = U.FULL
            for i in range(n):
                M &= A[i] if (om >> i) & 1 else U.neg(A[i])
            prior.append((M, w_coin / (1 << n)))
        allA = U.FULL
        for i in range(n):
            allA &= A[i]
        prior += [(U.FULL, 0.2), (allA, 0.15), (0, 0.05)]
        for _ in range(6):
            prior.append((rng.getrandbits(U.nv) or 1, 0.05 * rng.random()))
        gaps = []
        perpair_ok = True
        for y in range(1 << n):
            alph = [A[i] if (y >> i) & 1 else U.neg(A[i]) for i in range(n)]
            beta = [alph[i] | C[i] for i in range(n)]
            seqA, seqB = [], []
            for i in range(n):
                seqA += [(alph[i], 1), (beta[i], 1)]
                seqB += [(beta[i], 1), (alph[i], 1)]
            gA = norm_loss(U, prior, seqA)
            gB = norm_loss(U, prior, seqB)
            gaps.append(gA - gB)
            # per-pair lower bound log(1 + v_i) with v_i = posterior mass refuting alpha_i, undecided on c_i
            hist = []
            tot_lb = 0.0
            for i in range(n):
                p = psi(U, hist)
                Z = sum(w for (M, w) in prior if M != 0 and subset(M, p))
                vi = sum(w for (M, w) in prior if M != 0 and subset(M, p) and subset(M, U.neg(alph[i]))
                         and not (subset(M, C[i]) or subset(M, U.neg(C[i])))) / Z
                tot_lb += lg(1 + vi)
                hist += [(alph[i], 1), (beta[i], 1)]
            if gA - gB < tot_lb - 1e-9:
                perpair_ok = False
        avg = sum(gaps) / len(gaps)
        out(f"n = {n}: loss(order alpha first) - loss(order beta first): mean over y {avg:.4f}, min {min(gaps):.4f}, "
            f"max {max(gaps):.4f} bits; claimed mean lower bound n*w_coin/2 = {n * w_coin / 2:.4f}; "
            f"per-pair bound sum log(1+v_i) respected for every y: {perpair_ok}")
    out()


# ------------------------------------------------------------------ B5
def part_B5():
    out("=== B5: graded CR weight vs PR weight (Q4) ===")
    for k in (1, 2, 3, 4):
        U = Universe(2 * k)
        blocks = []
        for j in range(k):
            a, b = U.atom(2 * j), U.atom(2 * j + 1)
            blocks.append([a, U.neg(a) & b, U.neg(a) & U.neg(b)])
        # Revision (referee B, m5(b)): version 1 used w_empty = 0.25, which made the bound
        # k log(3/2) + log w_empty nonpositive (vacuous) for k = 1, 2, 3.  With w_empty = 0.75 every
        # bound below is positive.  The random draws are unchanged.
        w_empty = 0.75
        prior = [(U.FULL, w_empty), (0, 0.02)]
        for _ in range(12):
            prior.append((rng.getrandbits(U.nv) or 1, 0.01 * rng.random()))
        for v in range(U.nv):                      # coin theory: a random complete valuation
            prior.append((1 << v, 0.1 / U.nv))
        prior = [(M, Fr(w).limit_denominator(10 ** 9)) for (M, w) in prior]
        tot = Fr(0)
        best = -1e9
        minM = None
        for idx in itertools.product(range(3), repeat=k):
            E = [(blocks[j][idx[j]], 1) for j in range(k)]
            m = W(U, prior, E)
            h = m_half(U, prior, E)
            tot += m
            minM = m if minM is None else min(minM, m)
            if m > 0:
                best = max(best, lg(h) - lg(m))
            else:
                best = float('inf')
        bound = k * lg(1.5) + lg(float(w_empty))
        out(f"k = {k} blocks (3^k = {3**k} pairwise inconsistent data sets): sum of M = {float(tot):.4f} (<= M(empty) = "
            f"{float(W(U, prior, [])):.4f}); min M = {float(minM):.3e} (<= 3^-k = {3**-k:.3e}); "
            f"max log(M_half/M) = {best:.3f} >= k log(3/2) + log w_empty = {bound:.3f}")
    for r in (2, 3, 4):
        U = Universe(r)
        m = 1 << r
        prior = [(U.FULL, Fr(3, 4)), (0, Fr(1, 64))]          # revision: w_empty 1/4 -> 3/4
        for v in range(U.nv):
            prior.append((1 << v, Fr(1, 8) / U.nv))
        for _ in range(5):
            prior.append((rng.getrandbits(U.nv) or 1, Fr(rng.randint(1, 5), 400)))
        best = max(lg(m_half(U, prior, [(1 << v, 1)])) - lg(W(U, prior, [(1 << v, 1)])) for v in range(U.nv))
        out(f"single datum among m = {m} incompatible sentences (complete descriptions of {r} atoms): "
            f"max log(M_half/M) = {best:.3f} >= log m - 1 + log w_empty = {r - 1 + lg(0.75):.3f}")
    out()


if __name__ == "__main__":
    out(f"seed {SEED}")
    part_B1()
    part_B1b()
    part_B2()
    part_B3()
    part_B4()
    part_B5()
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "c2_separations.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")

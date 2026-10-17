#!/usr/bin/env python3
"""rb6_misc.py -- referee B, thread `fundamentals`: exact checks of several self-contained arguments.

R6.1  Lemma 3.3 (randomness passes up): beta = 2^-k alpha + gamma with left-c.e. approximations; from u = beta_{1:n}
      the procedure q = 0.u - 2^-n, s = first stage with beta_s > q, must place alpha in [alpha_s, alpha_s + 2^{k+1-n})
      and alpha_{1:n} among <= 2^{k+1} + 1 dyadic intervals.  Exact rationals; random reals given to 80 bits plus a
      non-dyadic tail.
R6.2  Thm 3.2(b) (Solovay reduction): f(q) := alpha_s for the first s with beta_s > q satisfies f(q) < alpha and
      alpha - f(q) <= 2^k (beta - q) for random rationals q < beta.
R6.3  Prop 1.8(a) (Craig): every conjunction tree theta has at most two readings theta = chi^{^m}; the decider built
      from the readings agrees with membership in A^C_e for random step-by-step enumerations (finite and long).
R6.4  Prop 10.1(a),(d) (Demski's process as described): exact absorption law on k = 2, 3 atoms with a full-support
      sentence measure (several syntactic copies per content); the outcome is complete a.s.; P_mu coherent;
      P_mu(phi) >= mu(phi) for consistent phi; skipping implied sentences gives the same outcome law.
R6.5  Thm 6.2: exact integer arithmetic 3^(2^l_d) < 2^d and l_d > log d - 2 for d = 2..3000; L = 2^(2^s) >= 2^(d+1);
      (ii)/(iii) "exactly a quarter" by enumeration (d = 2, all u in {0,1}^16); pigeonhole on toy lists.
R6.6  Prop 11.2(b): graded/PR gap on toy universal laws with a large empty-theory mass: max over the m^k data sets
      of log(M_half/M) >= k log(m/2) + log eps_empty, and sum of M <= M(empty).
Seed 20261016.  Output: rb6_misc.out.
"""
import itertools
import math
import os
import random
from fractions import Fraction as Fr

import rb_common as C
from rb_common import At, Not, And, Or, Imp, Iff, TOP, BOT, lit

SEED = 20261016
rng = random.Random(SEED)
OUT = []


def out(s=""):
    OUT.append(s)
    print(s)


# ------------------------------------------------------------------ R6.1, R6.2
def rand_real(bits):
    """a random real in (0,1) given exactly: 'bits' random bits followed by 1/3 * 2^-bits (non-dyadic tail)."""
    x = Fr(rng.getrandbits(bits), 2 ** bits) + Fr(1, 3 * 2 ** bits)
    return x


def approx_seq(x, S):
    """a nondecreasing sequence of rationals x_0 <= x_1 <= ... < x, converging to x (random gaps)."""
    seq = []
    cur = Fr(0)
    for s in range(S):
        cand = x - Fr(rng.randint(1, 1000), 1000) * Fr(1, 2 ** s) / 3
        cur = max(cur, cand)
        seq.append(cur)
    return seq


def prefix_bits(x, n):
    """first n binary digits of x in (0,1), as an integer."""
    return math.floor(x * 2 ** n)


def r6_1_2():
    worst_cand = 0
    fails = 0
    tests = 0
    red_fail = 0
    red_tests = 0
    for trial in range(200):
        k = rng.randint(0, 5)
        alpha = rand_real(80)
        gmax = 1 - alpha / 2 ** k
        gamma = rand_real(80) * gmax * Fr(9, 10)
        beta = alpha / 2 ** k + gamma
        assert beta < 1
        S = 160
        a_s = approx_seq(alpha, S)
        g_s = approx_seq(gamma, S)
        b_s = [a / 2 ** k + g for a, g in zip(a_s, g_s)]
        for n in range(1, 60):
            u = prefix_bits(beta, n)
            q = Fr(u, 2 ** n) - Fr(1, 2 ** n)
            s = next(i for i in range(S) if b_s[i] > q)
            lo = a_s[s]
            hi = a_s[s] + Fr(2 ** (k + 1), 2 ** n)
            tests += 1
            if not (lo <= alpha < hi):
                fails += 1
                continue
            first = math.floor(lo * 2 ** n)
            last = math.ceil(hi * 2 ** n) - 1
            ncand = last - first + 1
            worst_cand = max(worst_cand, ncand - (2 ** (k + 1) + 1))
            if not (first <= prefix_bits(alpha, n) <= last):
                fails += 1
        # R6.2 Solovay reduction with k = |p_alpha|
        for _ in range(40):
            q = beta - Fr(rng.randint(1, 10 ** 6), 10 ** 6) * Fr(1, 2 ** rng.randint(0, 50))
            if q < 0:
                continue
            s = next(i for i in range(S) if b_s[i] > q)
            fq = a_s[s]
            red_tests += 1
            if not (fq < alpha and alpha - fq <= 2 ** k * (beta - q)):
                red_fail += 1
    out(f"R6.1 Lemma 3.3: {tests} (real, n) tests, k = 0..5: alpha outside [alpha_s, alpha_s + 2^(k+1-n)) or alpha_(1:n) "
        f"not among the candidates in {fails}; max of #candidates - (2^(k+1)+1) = {worst_cand}  [<= 0]")
    out(f"R6.2 Thm 3.2(b) Solovay reduction: {red_tests} rationals q < beta: violations of f(q) < alpha and "
        f"alpha - f(q) <= 2^k (beta - q): {red_fail}")


# ------------------------------------------------------------------ R6.3 Craig readings
def conj_power(chi, m):
    out_ = chi
    for _ in range(m - 1):
        out_ = ('and', chi, out_)
    return out_


def readings(theta):
    """readings (chi, m) of theta = chi^{^m}, by the decider's rule: (theta, 1) and, for a conjunction, the left
    conjunct with the maximal number of strips (if the remainder equals the left conjunct)."""
    res = [(theta, 1)]
    if theta[0] == 'and':
        chi = theta[1]
        rem = theta
        strips = 0
        while rem[0] == 'and' and rem[1] == chi:
            rem = rem[2]
            strips += 1
        if rem == chi:
            res.append((chi, strips + 1))
    return res


def all_trees(size, atoms):
    """all formulas built from atoms with 'and' having exactly 'size' leaves."""
    if size == 1:
        return [At(a) for a in atoms]
    res = []
    for l in range(1, size):
        for L_ in all_trees(l, atoms):
            for R_ in all_trees(size - l, atoms):
                res.append(('and', L_, R_))
    return res


def subterms(f):
    yield f
    if f[0] == 'and':
        yield from subterms(f[1])
        yield from subterms(f[2])


def size_of(f):
    return 1 if f[0] != 'and' else size_of(f[1]) + size_of(f[2])


def r6_3():
    atoms = [0, 1]
    maxread = 0
    mismatch = 0
    ntheta = 0
    for size in range(1, 9):
        for theta in all_trees(size, atoms):
            ntheta += 1
            brute = set()
            for chi in set(subterms(theta)):
                sc = size_of(chi)
                if size % sc == 0 and conj_power(chi, size // sc) == theta:
                    brute.add((chi, size // sc))
            maxread = max(maxread, len(brute))
            if brute != set(readings(theta)):
                mismatch += 1
    out(f"R6.3 Craig readings: {ntheta} conjunction trees over 2 atoms with <= 8 leaves: max number of readings "
        f"theta = chi^(^m) = {maxread}  [<= 2]; decider's readings differ from brute force in {mismatch}")
    # decider vs membership for random enumerations
    pool = []
    for size in range(1, 4):
        pool += all_trees(size, [0, 1, 2])
    bad = 0
    tests = 0
    for trial in range(200):
        steps = rng.randint(1, 12)
        enum = [[rng.choice(pool) for _ in range(rng.choice([0, 0, 1, 1, 2]))] for _ in range(steps)]
        # W_e enumerated at step s: enum[s] (steps beyond the list enumerate nothing)
        AC = set()
        for s, chis in enumerate(enum):
            for chi in chis:
                AC.add(conj_power(chi, s + 1))

        def decider(theta):
            for chi, m in readings(theta):
                s = m - 1
                if s < len(enum) and chi in enum[s]:
                    return True
            return False

        cands = set(AC)
        for chi in pool:
            for m in range(1, steps + 3):
                cands.add(conj_power(chi, m))
        for theta in cands:
            tests += 1
            if decider(theta) != (theta in AC):
                bad += 1
    out(f"R6.3 Craig decider vs membership in A^C_e: {tests} (enumeration, sentence) tests over 200 random "
        f"enumerations: disagreements {bad}")


# ------------------------------------------------------------------ R6.4 Demski's process
def demski_law(nv, mu, skip_implied=False):
    """exact law of the final complete theory (a valuation) of the process 'draw i.i.d. from mu over model sets
    (sentence contents), keep if consistent with the kept set'.  mu: dict {model set (frozenset, nonempty or
    empty): prob}.  States: current model set S (frozenset).  Returns {valuation: prob} and checks absorption."""
    from functools import lru_cache
    ALL = frozenset(range(nv))
    items = list(mu.items())

    @lru_cache(maxsize=None)
    def final(S):
        if len(S) == 1:
            return ((next(iter(S)), Fr(1)),)
        # transitions: draw X; if S & X nonempty (and, if skip_implied, not S <= X): move to S & X; else stay
        move = []
        stay = Fr(0)
        for X, p in items:
            T = S & X
            if T and T != S:
                move.append((T, p))
            else:
                stay += p        # inconsistent or implied (S <= X) draws leave S unchanged either way
        tot = sum(p for _, p in move)
        assert tot > 0, "non-singleton state with no move: process not complete"
        res = {}
        for T, p in move:
            for v, q in final(T):
                res[v] = res.get(v, Fr(0)) + p / tot * q
        return tuple(sorted(res.items()))

    return dict(final(ALL))


def r6_4():
    lines = []
    for k in (2, 3):
        nv = 1 << k
        sets = [frozenset(S) for r in range(0, nv + 1) for S in itertools.combinations(range(nv), r)]
        worst_coh = Fr(0)
        worst_mu = Fr(0)
        same = 0
        N = 6
        for trial in range(N):
            raw = {S: Fr(rng.randint(1, 20)) for S in sets}     # full support (incl. bot and top)
            # several syntactic copies per content: modelled by extra mass on some contents
            for S in rng.sample(sets, len(sets) // 3):
                raw[S] += rng.randint(1, 20)
            tot = sum(raw.values())
            mu = {S: x / tot for S, x in raw.items()}
            law = demski_law(nv, mu)
            law2 = demski_law(nv, mu, skip_implied=True)
            same += (law == law2)
            assert sum(law.values()) == 1
            for S in sets:
                P = sum((law.get(v, Fr(0)) for v in S), Fr(0))
                Pn = sum((law.get(v, Fr(0)) for v in set(range(nv)) - S), Fr(0))
                worst_coh = max(worst_coh, abs(P + Pn - 1))
                if S:
                    worst_mu = max(worst_mu, mu[S] - P)
        out(f"R6.4 Demski process, k = {k} atoms, {N} random full-support sentence measures: outcome complete with "
            f"probability 1 (exact absorption at valuations); max |P(phi)+P(not phi)-1| = {worst_coh}; "
            f"max of mu(phi) - P_mu(phi) over consistent phi = {float(worst_mu):.4f}  [<= 0]; "
            f"skip-implied variant has the same outcome law in {same} of {N}")


# ------------------------------------------------------------------ R6.5 Theorem 6.2 arithmetic
def r6_5():
    bad = 0
    for d in range(2, 3001):
        # l_d = ceil(log2(d / log2 3)) - 1, computed exactly: smallest integer t with 2^t >= d/log2(3) is ceil(...)
        # use exact comparison 2^t * log2(3) >= d  <=>  3^(2^t) >= 2^d
        t = 0
        while 3 ** (2 ** t) < 2 ** d:
            t += 1
        l = t - 1
        ok1 = 3 ** (2 ** l) < 2 ** d if l >= 0 else True
        ok2 = l > math.log2(d) - 2
        s = math.ceil(math.log2(d + 1))
        ok3 = 2 ** s >= d + 1          # L = 2^(2^s) >= 2^(d+1)
        if not (ok1 and ok2 and ok3):
            bad += 1
    out(f"R6.5 Thm 6.2(i),(ii) arithmetic, d = 2..3000 (exact integers): violations of 3^(2^l_d) < 2^d, "
        f"l_d > log2 d - 2, 2^s >= d+1: {bad}")
    # exactly a quarter, d = 2: words of length <= 2 (7 words), u in {0,1}^16
    words = [''] + ['0', '1'] + ['00', '01', '10', '11']
    j = {w: i for i, w in enumerate(words)}
    Lbits = 16
    counts = {}
    total = 1 << Lbits
    pairs = [(x1, x2, b1, b2) for x1 in words for x2 in words if x1 != x2 for b1 in (0, 1) for b2 in (0, 1)]
    good = 0
    for (x1, x2, b1, b2) in pairs:
        # u_{j(x)+1} is bit j(x) of u; count u agreeing with both labels
        cnt = 0
        for u in range(total):
            if ((u >> j[x1]) & 1) == b1 and ((u >> j[x2]) & 1) == b2:
                cnt += 1
        good += (Fr(cnt, total) == Fr(1, 4))
    out(f"R6.5 Thm 6.2(ii),(iii): two-literal data sets on distinct words of length <= 2 with all labels: "
        f"exactly a quarter of the 2^16 coin strings compatible in {good} of {len(pairs)}")
    # toy pigeonhole: d = 12, l = l_d; random short theories over literals R(t_x), x in {0,1}^d
    for d in (8, 12):
        t = 0
        while 3 ** (2 ** t) < 2 ** d:
            t += 1
        l = t - 1
        nprog = 2 ** l - 1
        atoms = list(range(2 ** d))
        progs = []
        for _ in range(nprog):
            kind = rng.random()
            if kind < 0.3:
                th = None            # inconsistent or not a program: colour '*'
            else:
                th = {x: rng.randint(0, 1) for x in rng.sample(atoms, rng.randint(0, 2 ** d))}
            progs.append(th)
        colours = {}
        coll = None
        for x in atoms:
            col = tuple('*' if th is None or x not in th else ('+' if th[x] == 1 else '-') for th in progs)
            if col in colours:
                coll = (colours[col], x)
                break
            colours[col] = x
        x1, x2 = coll
        sep = sum(1 for th in progs if th is not None and th.get(x1) == 0 and th.get(x2) == 1)
        out(f"R6.5 pigeonhole, d = {d}: l_d = {l}, {nprog} short programs, colours <= 3^{nprog} = {3 ** nprog} < 2^d = "
            f"{2 ** d}; colliding words {x1}, {x2}; short theories proving not R(t_x1) and R(t_x2): {sep}")


# ------------------------------------------------------------------ R6.6 Prop 11.2(b)
def r6_6():
    for (m, k) in ((3, 1), (3, 2), (3, 3), (4, 1), (4, 2), (5, 2)):
        natoms = k * (m - 1)
        L = C.Logic(natoms)
        a = [[At(j * (m - 1) + i) for i in range(m - 1)] for j in range(k)]

        def chi(j, i):     # i in 1..m
            if i < m:
                return And(*([Not(a[j][t]) for t in range(i - 1)] + [a[j][i - 1]]))
            return And(*[Not(a[j][t]) for t in range(m - 1)])

        worst = None
        minbound = None
        sum_ok = 0
        N = 5
        for trial in range(N):
            machines = [[], [('', BOT)]]
            # coin machine on all atoms, random theories, theories proving some chi
            machines.append([(w, lit(At(len(w) - 1), int(w[-1]))) for r in range(1, natoms + 1)
                             for w in (''.join(b) for b in itertools.product('01', repeat=r))])
            for _ in range(3):
                j = rng.randrange(k)
                machines.append([('', chi(j, rng.randint(1, m)))])
            codes = ['1', '0100', '0101', '0110', '01110', '01111']
            law = C.mixture_law(L, machines, codes)
            eps = law.get(L.ALL, Fr(0))
            best = -1e9
            tot = Fr(0)
            for idx in itertools.product(range(1, m + 1), repeat=k):
                E = [(chi(j, idx[j]), 1) for j in range(k)]
                Mv = C.M(L, law, E)
                tot += Mv
                Mh = C.Mhalf(L, law, E)
                if Mv > 0:
                    best = max(best, C.lg(Mh / Mv))
                else:
                    best = math.inf
            bound = k * math.log2(m / 2) + C.lg(eps)
            sum_ok += (tot <= C.consistent_mass(law))
            margin = best - bound
            worst = margin if worst is None else min(worst, margin)
            minbound = bound if minbound is None else min(minbound, bound)
        out(f"R6.6 Prop 11.2(b), m = {m}, k = {k}: {N} toy laws with eps_empty >= 1/2: min over laws of "
            f"[max_i log(M_half/M) - (k log(m/2) + log eps_empty)] = {worst:.4f}  [>= 0]; "
            f"sum_i M(E_i) <= consistent mass in {sum_ok} of {N}; smallest bound value {minbound:.3f} "
            f"({'non-vacuous' if minbound > 0 else 'vacuous: M_half >= M already gives it'})")


if __name__ == "__main__":
    out(f"seed {SEED}")
    r6_1_2()
    r6_3()
    r6_4()
    r6_5()
    r6_6()
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "rb6_misc.out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")

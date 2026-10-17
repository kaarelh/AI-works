"""rb4_arith.py -- referee B, thread `sfi`.  Arithmetic and small-construction checks.

(A) Thm 7.4 (AI-paper Thm 6.15): the worst case of the tie rule.  With approximations within
    eps_j = 2^-j-3 and the label of smaller approximate probability, q_{b_j} <= 1/2 + eps_j; the
    loss is >= n - sum_{j>=1} log2(1 + 2^-j-2) >= n - 1/(4 ln 2).  Computed: the exact infinite sum,
    and simulated diagonals against five concrete computable predictors, with the approximation
    error chosen adversarially (to push the chosen label's probability up), n = 60.
(B) Cor 10.2: the verifier exception gadget.  (i) Built explicitly (eq_a by a chain of d-1 AND-type
    gates of literals, or 1 gate for d = 1; then a' := a OR eq, r' := r AND NOT eq as single gates
    of the 16-function basis) and checked by brute force on random consistent verifier circuits,
    d <= 4, k <= 2: V' consistent, f_V' = f_V off a, f_V'(a) = b, V -> V' injective, gamma <= 2d+2.
    (ii) The weight ratio: -log2(w(V')/w(V)) against Gamma_N(s) over d <= 64, 2 <= s <= 400,
    k in {0, s, 2s}, gamma in {d+1 (built), 2d+2 (stated)}; exact via sums of logs.
(C) c3 thresholds recomputed without c3's conservative estimate log2(C 2^a + m) <= a + log2 C + 1
    (mpmath, 60 digits): exact m0 for (A), (B), (C) of c3, compared with c3's printed m0.
(D) Prop 9.4 constants.  (i) d(m)^{c_e} > 2^{2^{cm}} implies d(m) > 2^{2^{cm/2}} for all
    m >= (2/c) log2 c_e: the constant c'' = c/2 does not depend on e.  (ii) Reading (a1): with
    derivation size up to 2^{beta h log2 h} (SD Thm 4.2, under (F1)), the same argument gives only
    beta h log2 h > 2^{cm} / c_e, i.e. a singly exponential lower bound on h; the table prints the
    least h forced for illustrative c, beta, c_e, next to the size-reading bound.
Deterministic (B(i) seeded 20261016).  Output: rb4_arith.out
"""
import itertools
import math
import random
import re
import os

import mpmath as mp

mp.mp.dps = 60
HERE = os.path.dirname(os.path.abspath(__file__))
out_lines = []


def out(s=''):
    out_lines.append(s)
    print(s)


# ----------------------------------------------------------------------------- (A)
def part_A():
    out('(A) diagonal (Thm 7.4): worst case of the tie rule')
    S = mp.nsum(lambda j: mp.log(1 + mp.mpf(2) ** (-j - 2), 2), [1, mp.inf])
    out('    sum_{j>=1} log2(1 + 2^-j-2) = %s ;  1/(4 ln 2) = %s ;  bound 0.361 holds: %s'
        % (mp.nstr(S, 12), mp.nstr(1 / (4 * mp.log(2)), 12), S < mp.mpf('0.361')))
    S0 = mp.nsum(lambda j: mp.log(1 + mp.mpf(2) ** (-j - 2), 2), [0, mp.inf])
    out('    (had the sum started at j = 0 it would be %s > 0.361: the index starts at 1 in the source, '
        'as the record transcribes)' % mp.nstr(S0, 8))

    preds = {
        'Laplace': lambda h: (len(h) - sum(h) + 1) / (len(h) + 2),
        'KT': lambda h: (len(h) - sum(h) + 0.5) / (len(h) + 1),
        'last-bit 0.9': lambda h: 0.9 if (h and h[-1] == 0) else 0.1,
        'constant 1/2': lambda h: 0.5,
        'deficient (q0+q1=0.7)': lambda h: 0.35,
    }
    n = 60
    for name, p0 in preds.items():
        hist = []
        loss = 0.0
        for j in range(1, n + 1):
            q0 = p0(hist)
            q1 = (0.7 - q0) if name.startswith('deficient') else 1 - q0
            eps = 2.0 ** (-j - 3)
            # adversarial approximations: make the label with the LARGER true probability look smaller
            if q0 >= q1:
                a0, a1 = q0 - eps, q1 + eps
            else:
                a0, a1 = q0 + eps, q1 - eps
            b = 0 if a0 <= a1 else 1
            q = q0 if b == 0 else q1
            loss += -math.log2(q)
            hist.append(b)
        out('    %-22s n = %d: loss = %.4f, loss - n = %+.4f (>= -0.361: %s)' % (name, n, loss, loss - n, loss - n >= -0.361))


# ----------------------------------------------------------------------------- (B)
OPS = {i: (lambda i: (lambda a, b: (i >> (2 * a + b)) & 1))(i) for i in range(16)}
AND, OR = 0b1000, 0b1110          # truth table index 2a+b
ANDNOT = 0b0100                    # a AND NOT b: (a,b)=(1,0) -> bit 2
NOTA_B = 0b0010                    # NOT a AND b: (a,b)=(0,1) -> bit 1
NOR = 0b0001


def eval_v(gates, d, k, x, z):
    vals = list(x) + list(z) + [0, 1]
    for op, a, b in gates:
        vals.append(OPS[op](vals[a], vals[b]))
    return vals[-2], vals[-1]          # outputs: accept a, reject r


def f_of(gates, d, k):
    f = {}
    ok = True
    for x in itertools.product((0, 1), repeat=d):
        A = R = 0
        for z in itertools.product((0, 1), repeat=k):
            a, r = eval_v(gates, d, k, x, z)
            A |= a
            R |= r
        if A and R:
            ok = False
        f[x] = 1 if A else (0 if R else None)
    return f, ok


def gadget(gates, d, k, pt, b):
    """append eq_pt, then new outputs a', r'.  Returns new gate list and gamma."""
    g = list(gates)
    base = d + k + 2
    ia, ir = base + len(gates) - 2, base + len(gates) - 1     # old outputs
    # literal-AND chain for [x == pt]
    def lit_and(i, j):  # op for (x_i == pt_i) AND (x_j == pt_j) on inputs i, j
        tt = 0
        for a in (0, 1):
            for bb in (0, 1):
                if a == pt[i] and bb == pt[j]:
                    tt |= 1 << (2 * a + bb)
        return tt
    if d == 1:
        op = 0
        for a in (0, 1):
            for bb in (0, 1):
                if a == pt[0]:
                    op |= 1 << (2 * a + bb)
        g.append((op, 0, 0))
    else:
        g.append((lit_and(0, 1), 0, 1))
        for i in range(2, d):
            cur = base + len(g) - 1
            # cur AND (x_i == pt_i)
            tt = 0
            for a in (0, 1):
                for bb in (0, 1):
                    if a == 1 and bb == pt[i]:
                        tt |= 1 << (2 * a + bb)
            g.append((tt, cur, i))
    eq = base + len(g) - 1
    if b == 1:
        g.append((OR, ia, eq))          # a' = a or eq
        g.append((ANDNOT, ir, eq))      # r' = r and not eq
    else:
        g.append((ANDNOT, ia, eq))      # a' = a and not eq
        g.append((OR, ir, eq))          # r' = r or eq
    return g, len(g) - len(gates)


def rand_consistent_verifier(rng, d, k, s):
    while True:
        gates = []
        base = d + k + 2
        for j in range(s - 2):
            gates.append((rng.randrange(16), rng.randrange(base + j), rng.randrange(base + j)))
        # outputs: accept = h AND u, reject = h' AND NOT u, guaranteeing consistency often
        nb = base + len(gates)
        u = rng.randrange(nb)
        h1, h2 = rng.randrange(nb), rng.randrange(nb)
        gates.append((AND, h1, u))
        gates.append((NOTA_B, u, h2))
        f, ok = f_of(gates, d, k)
        if ok:
            return gates, f


def part_B():
    out('(B) verifier exception gadget (Cor 10.2)')
    rng = random.Random(20261016)
    tested = bad = 0
    gam = {}
    for d in range(1, 5):
        for k in range(0, 3):
            for _ in range(40):
                s = rng.randint(4, 12)
                gates, f = rand_consistent_verifier(rng, d, k, s)
                images = set()
                for pt in itertools.product((0, 1), repeat=d):
                    for b in (0, 1):
                        g2, gamma = gadget(gates, d, k, pt, b)
                        gam[d] = gamma
                        f2, ok = f_of(g2, d, k)
                        tested += 1
                        good = ok and f2[pt] == b and all(f2[x] == f[x] for x in f if x != pt) and gamma <= 2 * d + 2
                        bad += not good
                        images.add((pt, b, tuple(g2)))
    out('    %d (V, a, b) cases, d <= 4, k <= 2: gadget fails (V\' inconsistent, wrong at a, changed off a, '
        'or gamma > 2d+2): %d;  gamma built = %s (stated bound 2d+2)' % (tested, bad, dict(sorted(gam.items()))))
    # injectivity for fixed (a, b): V is the prefix of V' of length |V'| - gamma
    out('    injectivity: for fixed (a, b) and d, gamma is fixed, so V is recovered as the first |V\'| - gamma gates')

    def lg(x):
        return math.log2(x)

    worst = {}
    viol = 0
    for gamma_rule in ('built', 'stated'):
        for d in list(range(1, 17)) + [32, 64]:
            gamma = (d + 1 if d >= 2 else 3) if gamma_rule == 'built' else 2 * d + 2
            for s in range(2, 401):
                for k in sorted({0, s, 2 * s}):
                    # -log2 w(V')/w(V) = gamma + log2((2(s+g)+1)/(2s+1)) + sum_{j=s+1}^{s+g} (4 + 2 log2(d+k+1+j))
                    exact = gamma + lg((2 * (s + gamma) + 1) / (2 * s + 1)) + sum(4 + 2 * lg(d + k + 1 + j) for j in range(s + 1, s + gamma + 1))
                    GN = gamma * (5 + 2 * lg(d + 3 * s + gamma + 1)) + lg(gamma + 1)
                    if exact > GN + 1e-9:
                        viol += 1
                    worst[gamma_rule] = max(worst.get(gamma_rule, -1e9), exact - GN)
    out('    weight ratio: -log2(w(V\')/w(V)) > Gamma_N(s) in %d cases (d <= 64, s <= 400, k in {0,s,2s}); '
        'largest (exact - Gamma_N): built %.3f, stated %.3f' % (viol, worst['built'], worst['stated']))


# ----------------------------------------------------------------------------- (C)
def thresholds_exact():
    out('(C) c3 thresholds recomputed exactly (no conservative log estimate), m <= 3000')
    c3 = open(os.path.join(HERE, '..', 'checks', 'c3_presburger_constants.out')).read()
    blocks = re.split(r'\n\((A|B|C)\)', c3)
    printed = {}
    for i in range(1, len(blocks), 2):
        tag = blocks[i]
        for line in blocks[i + 1].splitlines():
            p = line.split()
            if len(p) == 5 and re.match(r'^[\d.]+$', p[0]):
                printed[(tag, float(p[0]), float(p[1]), float(p[2]), int(p[3]))] = p[4]

    def log2(x):
        return mp.log(x, 2)

    def condA(m, c, cp, C, k):
        X = mp.mpf(2) ** (cp * m)
        lhs = mp.log(k, 2) + log2(X + log2(C + m * mp.mpf(2) ** (-X)))
        return lhs < c * m

    def condB(m, c, cp, C, k):
        tau = mp.mpf(2) ** (cp * m)
        return log2(tau + k * log2(C * tau + m)) < c * m

    def condC(m, cB, cp, C, k):
        X = mp.mpf(2) ** (cp * m)
        lT = k * (X + log2(C + m * mp.mpf(2) ** (-X)))     # log2 T, T = (C tau + m)^k, tau = 2^X
        return log2(3 * lT + 2 * log2(lT)) < cB * m

    def m0(cond, *a):
        last = None
        for m in range(1, 3001):
            if not cond(m, *a):
                last = m
        return 1 if last is None else last + 1

    diffs = []
    rows = 0
    worse = 0
    bad_rows = []
    for tag, cond in (('A', condA), ('B', condB), ('C', condC)):
        for c in (1.0, 0.5, 0.2, 0.05):
            for frac in (0.9, 0.5, 0.25):
                cp = frac * c
                for C in (10.0, 1e6):
                    for k in (2, 6):
                        e = m0(cond, c, cp, C, k)
                        pr = printed.get((tag, c, round(cp, 6), C, k))
                        if pr is None:
                            # printed c' has limited digits; match by tolerance
                            for key, v in printed.items():
                                if key[0] == tag and key[1] == c and abs(key[2] - cp) < 1e-6 and key[3] == C and key[4] == k:
                                    pr = v
                        rows += 1
                        if pr is not None and pr != 'none':
                            diffs.append(int(pr) - e)
                            if int(pr) < e:
                                worse += 1
                                # where does c3's estimate fail?  log2(C 2^a + m) <= a + log2 C + 1 needs m <= C 2^a
                                a_at = cp * (e - 1) if tag == 'B' else 2 ** (cp * (e - 1))
                                bad_rows.append('      (%s) c=%g c\'=%g C=%g k=%d: c3 m0 = %s, exact m0 = %d; at m = %d: m <= C 2^a is %s'
                                                % (tag, c, cp, C, k, pr, e, e - 1, (e - 1) <= C * 2 ** a_at))
    out('    %d rows; c3 m0 below the exact m0 (c3 not conservative): %d; c3 m0 - exact m0: min %d, max %d'
        % (rows, worse, min(diffs), max(diffs)))
    for r in bad_rows:
        out(r)


# ----------------------------------------------------------------------------- (D)
def part_D():
    out('(D) Prop 9.4 constants')
    for c in (1.0, 0.2, 0.05):
        for ce in (2, 10, 100):
            m_e = math.ceil((2 / c) * math.log2(ce))
            ok = all(2 ** (c * m) / ce >= 2 ** (c * m / 2) for m in range(m_e, m_e + 200))
            out('    c = %-5g c_e = %-4d: 2^{cm}/c_e >= 2^{cm/2} for all m >= %d (checked to +200): %s' % (c, ce, m_e, ok))
    out('    so c\'\' = c/2 works for every e (only the threshold depends on e).')
    out('    reading (a1) versus size reading: least budget forced at sentence length m (c = 0.2, c_e = 10, beta = 4)')
    out('      m     size reading: log2 log2 d >     (a1): log2 h >')
    c, ce, beta = 0.2, 10, 4
    for m in (20, 40, 80, 160, 320):
        # size: d^{ce} > 2^{2^{cm}}  ->  log2 log2 d > c m - log2 ce
        size_ll = c * m - math.log2(ce)
        # (a1): derivation size <= 2^{beta h log2 h}; need (2^{beta h log2 h})^{ce} > 2^{2^{cm}}
        #   -> beta h log2 h > 2^{cm}/ce ; solve for h
        target = 2 ** (c * m) / ce / beta
        lo, hi = 1.0, max(2.0, target)
        for _ in range(200):
            mid = (lo + hi) / 2
            if mid * math.log2(max(mid, 2)) > target:
                hi = mid
            else:
                lo = mid
        out('      %-5d %8.2f  (d doubly exp.)           %8.2f  (h singly exp.: log2 h ~ cm - log2 m)' % (m, size_ll, math.log2(hi)))


def main():
    out('rb4_arith.py (deterministic; B(i) seeded 20261016)')
    part_A()
    part_B()
    thresholds_exact()
    part_D()
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write('\n'.join(out_lines) + '\n')


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Editor of part property-batch, second round: the editor's own checks of the findings of
verification/property-batch-second.md and of what the editor wrote in this round
(proofs/property-batch.md: Remark 4.4, Theorem 4.11(B), 4.13 item 4, Remark 5.5, Lemma 2.8;
note, Section 8.6: the two sentences of Pr2(b) that findings N5 and N6 concern).

Pure Python 3. Written from the statements, without reusing an earlier script.
Exact rational arithmetic wherever a block says "exact".
Run as:  python3 property-batch_editor_second.py > property-batch_editor_second.out
"""
import itertools
import math
import random
from fractions import Fraction as Fr
from math import comb, exp, log, sqrt

random.seed(20261116)


def hdr(s):
    print()
    print(s)


# ---------------------------------------------------------------------------------------------
hdr("(S1) Remark 4.4: the machine 'draw from nu until the answer does not violate R'")
# (a) The law of the loop. One round ends with y in R_x with probability nu(y), starts again with
#     probability v, and never ends with probability 1 - sum(nu).  After T rounds the probability of
#     having halted with y is nu(y) * (1 - v^T)/(1 - v); it must increase to nu^R(y) of Definition 4.1,
#     and to 0 for every y when v = 1.  Exact rationals, random semimeasures on 5 answers.
ok = True
cases = 0
for trial in range(2000):
    ny = 5
    R = [random.random() < 0.6 for _ in range(ny)]
    wts = [random.randint(0, 5) for _ in range(ny)]
    silent = random.choice([0, 0, 1, 3])          # mass of "no answer"
    if trial % 10 == 0:                           # force v = 1: all mass on violating answers
        wts = [0 if R[y] else max(1, wts[y]) for y in range(ny)]
        silent = 0
        if sum(wts) == 0:
            continue
    tot = sum(wts) + silent
    if tot == 0:
        continue
    nu = [Fr(a, tot) for a in wts]
    v = sum(nu[y] for y in range(ny) if not R[y])
    cases += 1
    for y in range(ny):
        closed = (nu[y] / (1 - v) if R[y] else Fr(0)) if v < 1 else Fr(0)   # Definition 4.1
        one_round = nu[y] if R[y] else Fr(0)
        part = Fr(0)
        for T in (1, 5, 40):
            part = one_round * sum(v ** i for i in range(T))
            ok &= part <= closed                                     # increasing limit from below
            ok &= (closed - part) == (closed * v ** T if v < 1 else 0)   # the remainder, exactly
    if v == 1:
        ok &= all((nu[y] if R[y] else 0) == 0 for y in range(ny))    # then nothing abiding has mass
    # the conditioned sampler is a semimeasure and never violates
    cond = [((nu[y] / (1 - v)) if (R[y] and v < 1) else Fr(0)) for y in range(ny)]
    ok &= sum(cond) <= 1 and all(cond[y] == 0 for y in range(ny) if not R[y])
print("    %d random semimeasures (a tenth of them with v = 1): after T rounds the loop has halted with y with"
      " probability nu^R(y)(1 - v^T), exactly; nu^R is a semimeasure that never violates: %s" % (cases, ok))

# (b) The code word sigma r p.  dom U is replaced by a finite prefix-free set; the set {r p} must be
#     prefix-free, the decomposition unique, the map (r, p) -> sigma r p injective, the lengths add.
def prefix_free(words):
    ws = sorted(words)
    return all(not ws[i + 1].startswith(ws[i]) for i in range(len(ws) - 1))

domU = ["00", "010", "011", "100", "1010", "1011", "110", "11100", "11101"]
assert prefix_free(domU) and len(set(domU)) == len(domU)
sigma = "1101"
pairs = [(r, p) for r in domU for p in domU]
words = [r + p for r, p in pairs]
unique = len(set(words)) == len(words)
decomp_unique = all(sum(1 for r in domU if w.startswith(r) and w[len(r):] in domU) == 1 for w in words)
print("    toy domain of %d programs: the %d words r p form a prefix-free set: %s; each has one decomposition: %s;"
      % (len(domU), len(words), prefix_free(words) and unique, decomp_unique))
print("    p -> sigma r p is injective for each r: %s; length = l(sigma) + l(r) + l(p): %s"
      % (all(len({sigma + r + p for p in domU}) == len(domU) for r in domU),
         all(len(sigma + r + p) == len(sigma) + len(r) + len(p) for r, p in pairs)))
# (c) The example against 'conditioning on an answer that abides': nu(y0|x) = 1/2,
#     nu(y1|x) = 1/4 if machine x halts, else 0.  Normalised probability of y0:
print("    normalised probability of y0: %s if machine x halts, %s if it does not (so '> 2/3' would enumerate the machines that do not halt)"
      % (Fr(1, 2) / (Fr(1, 2) + Fr(1, 4)), Fr(1, 2) / Fr(1, 2)))

# ---------------------------------------------------------------------------------------------
hdr("(S2) Theorem 4.11(B) and 4.13 item 4: the constants")
for u in (5, 8, 16, 1024):
    W0 = Fr(1, 8) * (1 + Fr(1, 2 * u)) ** u
    lowV = W0 * Fr(2 * u, 2 * u + 1) / (Fr(17, 16) * W0 + Fr(1, 64) + Fr(1, 32))
    print("    u = %4d: W0 = (1/8)(1+1/(2u))^u = %.5f; empty data: V >= W0 (2u/(2u+1)) / ((17/16) W0 + 2^-6 + 2^-5) = %.4f"
          % (u, float(W0), float(lowV)))
print("    (the file's 0.2013 is the value at u = 5; d >= 3 means u >= 8, where W0 >= 0.2030; e^(1/2)/8 = %.5f)" % (exp(0.5) / 8))
prod = Fr(3, 4) * Fr(16, 17) * Fr(10, 11) * Fr(4, 5)
print("    (3/4)(16/17)(10/11)(4/5) = %s = %.5f; non-U weight at most (17/128) e^(1/2) + 1/64 = %.4f"
      % (prod, float(prod), 17 / 128 * exp(0.5) + 1 / 64))
print("    4.13 item 4: 0.51/ln 2 = %.4f (below 0.74); %.5f/ln 2 = %.4f (at least 0.74); 1/ln 2 = %.4f (at most 1.45)"
      % (0.51 / log(2), float(prod), float(prod) / log(2), 1 / log(2)))
# 'What (B) shows': n* >= 1, then d >= 3 with 2^d >= 4 n*, then c >= 5 + n*(d+2); the two conditions of (B3).
ok = True
bad_without_d3 = []
for nstar in range(1, 2001):
    d_plain = max(0, math.ceil(log(4 * nstar, 2) - 1e-12))
    while 2 ** d_plain < 4 * nstar:
        d_plain += 1
    if d_plain < 3:
        bad_without_d3.append((nstar, d_plain))
    d = max(3, d_plain)
    c = 5 + nstar * (d + 2)
    u = 2 ** d
    ok &= (d >= 3 and c >= 5 and 4 * nstar <= u and nstar * (d + 2) <= c - 5)
print("    n* = 1..2000 with d := max{3, least d with 2^d >= 4n*}, c := 5 + n*(d+2): n* <= u/4 and n*(d+2) <= c-5 and d >= 3: %s"
      % ok)
print("    without the requirement d >= 3 the choice gives d < 3 for (n*, d) in %s" % bad_without_d3)

# ---------------------------------------------------------------------------------------------
hdr("(S3) Remark 5.5 (rare kinds of input) and the sentence it replaces")
# (a) A kind of input rarer than the tolerance on which a matching imitator may NOT do anything.
N, delta, pi = 1000, 0.05, 0.5
a = log(2 / (pi * delta)) / N
tol = sqrt(a / 2)
q = 0.02
print("    N = %d, delta = %.2f, pi(R) = %.1f: a_N(R) = %.5f, 1 - exp(-a_N(R)) = %.5f, tol_N(R) = %.5f"
      % (N, delta, pi, a, 1 - exp(-a), tol))
print("    a kind of input of frequency q = %.2f < tol on which the imitator always gives an answer the human never gives:"
      " kl(0 || q) = %.5f > a_N(R), so this imitator is not in the matching set" % (q, -log(1 - q)))


def kl(p, qq):
    def t(x, y):
        if x == 0:
            return 0.0
        if y == 0:
            return float("inf")
        return x * log(x / y)
    return t(p, qq) + t(1 - p, 1 - qq)


def exact_member_prob(u, N, delta, human, imit, tests):
    """One call at a uniform input among u.  human[x], imit[x]: laws on {0,1} as (p0, p1) Fractions.
    Exact probability, over N recorded runs of the human system, that the run law of imit lies in M_N."""
    Qp = []
    for B, w in tests:
        Qp.append(float(sum(Fr(1, u) * sum(imit[x][y] for y in (0, 1) if B(x, y)) for x in range(u))))
    runs = [(x, y, Fr(1, u) * human[x][y]) for x in range(u) for y in (0, 1) if human[x][y] > 0]
    good = Fr(0)
    for combo in itertools.product(runs, repeat=N):
        pr = Fr(1)
        for r in combo:
            pr *= r[2]
        member = True
        for (B, w), qv in zip(tests, Qp):
            ph = sum(1 for r in combo if B(r[0], r[1])) / N
            if kl(ph, qv) > log(2 / (w * delta)) / N + 1e-12:
                member = False
                break
        if member:
            good += pr
    return float(good)


det = lambda u: [(Fr(1), Fr(0)) for _ in range(u)]                   # the human answers 0 everywhere
coin = lambda u: [(Fr(1, 2), Fr(1, 2)) for _ in range(u)]            # the human is a fair coin
allok = True
rows = []
for name, mk, u, N, delta in (("function", det, 12, 3, 0.2), ("function", det, 30, 2, 0.1),
                              ("function", det, 10, 4, 0.3), ("coin", coin, 8, 3, 0.2), ("coin", coin, 12, 2, 0.1)):
    human = mk(u)
    imit = list(human)
    imit[0] = (Fr(0), Fr(1))                                         # on the kind E = {input 0}: always answer 1
    tests = [(lambda x, y: y == 1, 0.25), (lambda x, y: x == 0 and y == 1, 0.25),
             (lambda x, y: x < u // 2, 0.25), (lambda x, y: x % 2 == 0 and y == 0, 0.25)]
    pr = exact_member_prob(u, N, delta, human, imit, tests)
    bound = 1 - delta - N / u
    allok &= pr >= bound - 1e-12
    rows.append("    human = %-8s u = %2d, N = %d, delta = %.1f, q = 1/u: Pr[Q' in M_N] = %.4f >= 1 - delta - N q = %.4f: %s"
                % (name, u, N, delta, pr, bound, pr >= bound - 1e-12))
print("    (b) exact probability that an imitator which differs from the human system only on the input 0 lies in M_N:")
for r in rows:
    print(r)
print("    the bound of Remark 5.5 holds in all cases: %s (it is far from tight in these small cases)" % allok)

# ---------------------------------------------------------------------------------------------
hdr("(S4) Lemma 2.8: for which N the hypotheses can be met")
print("    (N+1)^2 <= e^N first at N = %d; (N+1)^3 <= e^N first at N = %d"
      % (next(n for n in range(1, 60) if (n + 1) ** 2 <= exp(n)), next(n for n in range(1, 60) if (n + 1) ** 3 <= exp(n))))

# ---------------------------------------------------------------------------------------------
hdr("(S5) Pr2(b) of the note (findings N5 and N6): exact enumeration of the memoriser class, u = 4, K = 12")


def mem_values(u, K, n_seen, w_g, w_h, w_f):
    """Human f = 0.  Memorisers g_T (answer b off the table) with weight w_g(size), copies h_T (silent off
    the table) with weight w_h(size), the human with weight w_f.  Data: inputs 0..n_seen-1.
    Returns Pr[b] at the unseen input u-1, exactly."""
    M = w_f
    nb = Fr(0)
    for T in itertools.product([None, 0, 1], repeat=u):
        if any(T[x] != 0 for x in range(n_seen)):
            continue
        size = sum(t is not None for t in T)
        M += w_g(size) + w_h(size)
        if T[u - 1] is None:
            nb += w_g(size)
    return nb / M


u, K = 4, 12
wf = Fr(1, 2 ** K)
c0 = (1 - wf) / (1 + Fr(1, 2 * u)) ** u
ok_formula = True
for n in (0, 1, 2, 3):
    unseen = mem_values(u, K, n, lambda s: c0 * Fr(1, (4 * u) ** s), lambda s: Fr(0), wf)
    f_unseen = Fr(2 * u, 2 * u + 1) / (1 + Fr((4 * u + 2) ** n, 2 ** K - 1))
    ok_formula &= unseen == f_unseen
    print("    n = %d questions at distinct inputs: at an unseen input Pr[b] = %.6f = (2u/(2u+1))/(1+(4u+2)^n/(2^K-1)): %s;"
          " at a uniform input drawn independently of the data: %.6f (the factor (u-n)/u = %s)"
          % (n, float(unseen), unseen == f_unseen, float(Fr(u - n, u) * unseen), Fr(u - n, u)))
# another total weight of the memorisers, same proportions: the formula of the note no longer holds
half = Fr(1, 2) / (1 + Fr(1, 2 * u)) ** u
other = mem_values(u, K, 2, lambda s: half * Fr(1, (4 * u) ** s), lambda s: Fr(0), wf)
print("    weights proportional to (4u)^-size but of total 1/2 instead of 1 - 2^-K, n = 2: Pr[b] = %.6f, the formula gives %.6f"
      % (float(other), float(Fr(2 * u, 2 * u + 1) / (1 + Fr((4 * u + 2) ** 2, 2 ** K - 1)))))
# the closure of Corollary 4.6 against another closure
C = 4
base = mem_values(u, K, 1, lambda s: c0 * Fr(1, (4 * u) ** s), lambda s: Fr(0), wf)
cl46 = mem_values(u, K, 1, lambda s: Fr(C, C + 1) * c0 * Fr(1, (4 * u) ** s), lambda s: Fr(1, C + 1) * c0 * Fr(1, (4 * u) ** s), wf)
print("    closure of Corollary 4.6 with C_R = %d: value / value of the open class = %s = 1 - 1/C_R: %s"
      % (C + 1, cl46 / base, cl46 / base == 1 - Fr(1, C + 1)))
# another closure: the silent copy of the empty table gets a thousandth of its share
tiny = Fr(1, 1000)
wg2 = lambda s: (Fr(C, C + 1) if s > 0 else 1 - tiny * Fr(1, C + 1)) * c0 * Fr(1, (4 * u) ** s)
wh2 = lambda s: (Fr(1, C + 1) if s > 0 else tiny * Fr(1, C + 1)) * c0 * Fr(1, (4 * u) ** s)
cl2 = mem_values(u, K, 1, wg2, wh2, wf)
CR2 = max((wg2(s) + wh2(s)) / wh2(s) for s in range(u + 1))
print("    another closure (the silent copy of the empty table has a thousandth of that share): least C_R = %s, 1 - 1/C_R = %.5f,"
      " value / value of the open class = %s" % (CR2, float(1 - 1 / CR2), cl2 / base))
print("    formula of Theorem 4.5(b) exact in all four cases: %s" % ok_formula)

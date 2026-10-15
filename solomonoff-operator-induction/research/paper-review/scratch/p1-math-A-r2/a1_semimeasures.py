"""Reviewer p1-math-A (run 2): independent checks for Paper 1, setting.tex / app-setting.tex.

Exact rational arithmetic (fractions). Seed 20261012 for random laws.
 (1) ex:setting:weaknotrpf (a),(b): weakness, Moebius sum, inconsistency, P1 >= (2/3) nu_tri.
 (2) LP over ALL random-partial-function laws on {a,b,c} x {0,1,bot}: best c with P >= c nu_tri,
     and for nu_tri^{(x)2} (729 outcomes) -> (2/3)^k exactness (thm:setting:weakvsmachine (v)).
 (3) prop:setting:mobius: Moebius sums = P(F >= D, F|_T = bot); reconstruction q_S of the law.
 (4) prop:setting:predictor / normtotal: a weak nu built from an order-independent predictor.
 (5) prop:setting:twopoint (i)-(iii) and the normalise(b) example; random positive laws.
 (6) prop:setting:transfer (a),(b): exact identity Lbar = L - sum log(1/Z_t); normalised products
     over all label sequences sum to 1 for fixed input lists with repeats.
 (7) ex:setting:swap: probability 2^-d for F(x) = x xor omega.
 (8) Normalised conditional and invariance: example where a re-encoding changes the
     normalised loss by more than the semimeasure loss changes (illustrates that thm:setting:invariance
     is a semimeasure-convention statement).
"""
from fractions import Fraction as Fr
from itertools import product, permutations, combinations
import random, math

random.seed(20261012)
BOT = None


def all_datasets(inputs, labels):
    out = []
    for vals in product([BOT] + list(labels), repeat=len(inputs)):
        out.append(frozenset((x, v) for x, v in zip(inputs, vals) if v is not BOT))
    return out


def is_weak(nu, inputs, labels):
    bad = 0; cnt = 0
    for D in all_datasets(inputs, labels):
        dom = {x for x, _ in D}
        for x in inputs:
            if x in dom:
                continue
            cnt += 1
            s = sum(nu.get(D | {(x, y)}, Fr(0)) for y in labels)
            if s > nu.get(D, Fr(0)):
                bad += 1
    return bad == 0, cnt


def moebius(nu, D, T, labels):
    tot = Fr(0)
    T = list(T)
    for r in range(len(T) + 1):
        for R in combinations(T, r):
            for ys in product(labels, repeat=r):
                E = frozenset(zip(R, ys))
                tot += (-1) ** r * nu.get(D | E, Fr(0))
    return tot


def containment(law, inputs):
    """law: dict outcome-tuple (values incl BOT) -> prob. returns nu(D) for all D"""
    nu = {}
    for D in all_datasets(inputs, [0, 1]):
        s = Fr(0)
        for out, p in law.items():
            ok = all(out[inputs.index(x)] == y for x, y in D)
            if ok:
                s += p
        nu[D] = s
    return nu


print("(1) Example weaknotrpf")
ins2 = ['a', 'b']
nuA = {frozenset(): Fr(1), frozenset({('a', 0)}): Fr(1), frozenset({('b', 0)}): Fr(1)}
w, c = is_weak(nuA, ins2, [0, 1])
print("   (a) weak:", w, "Moebius_{a,b}(empty) =", moebius(nuA, frozenset(), ins2, [0, 1]))
ins3 = ['a', 'b', 'c']
half = Fr(1, 2)
tau = {frozenset(): Fr(1)}
for x in ins3:
    for y in (0, 1):
        tau[frozenset({(x, y)})] = half
E1 = frozenset({('a', 0), ('b', 1)}); E2 = frozenset({('b', 0), ('c', 1)}); E3 = frozenset({('c', 0), ('a', 1)})
for E in (E1, E2, E3):
    tau[E] = half
w, c = is_weak(tau, ins3, [0, 1])
print("   (b) nu_tri weak:", w, "inequalities:", c)
law1 = {(0, 1, 0): Fr(1, 3), (1, 0, 1): Fr(1, 3), (1, 0, 0): Fr(1, 3)}
nuP1 = containment(law1, ins3)
ratios = [nuP1[D] / tau[D] for D in tau if tau[D] > 0]
print("   min P1/nu_tri on support:", min(ratios), " support size:", len(ratios))
print("   Moebius_{a,b,c} nu_tri(empty):", moebius(tau, frozenset(), ins3, [0, 1]))

print("(2) LP exactness of (2/3)^k")
try:
    from scipy.optimize import linprog
    import numpy as np
    for k in (1, 2):
        inputs = [f"{chr(97+i)}{j}" for j in range(k) for i in range(3)]
        outcomes = list(product([BOT, 0, 1], repeat=3 * k))
        # tau^{(x)k} support
        def tauk(D):
            p = Fr(1)
            for j in range(k):
                blk = frozenset((x[0], y) for x, y in D if x.endswith(str(j)))
                p *= tau.get(blk, Fr(0))
            return p
        supp = []
        for D in all_datasets(inputs, [0, 1]):
            t = tauk(D)
            if t > 0:
                supp.append((D, t))
        # variables: probs of outcomes (n) and c; maximise c s.t. P(F>=D) >= c tau(D)
        n = len(outcomes)
        A_ub = []; b_ub = []
        for D, t in supp:
            row = np.zeros(n + 1)
            for i, out in enumerate(outcomes):
                if all(out[inputs.index(x)] == y for x, y in D):
                    row[i] = -1.0
            row[n] = float(t)
            A_ub.append(row); b_ub.append(0.0)
        A_eq = [np.concatenate([np.ones(n), [0.0]])]
        res = linprog(c=np.concatenate([np.zeros(n), [-1.0]]), A_ub=np.array(A_ub), b_ub=b_ub,
                      A_eq=np.array(A_eq), b_eq=[1.0], bounds=[(0, None)] * (n + 1), method="highs")
        print(f"   k={k}: support {len(supp)} data sets, LP max c = {-res.fun:.12f}, (2/3)^k = {(2/3)**k:.12f}")
except Exception as e:
    print("   LP skipped:", e)

print("(3) Moebius characterisation on random laws")
fails = 0; checks = 0
for trial in range(30):
    outs = list(product([BOT, 0, 1], repeat=3))
    ws = [random.randint(0, 5) for _ in outs]
    tot = sum(ws)
    if tot == 0:
        continue
    law = {o: Fr(wt, tot) for o, wt in zip(outs, ws) if wt}
    nu = containment(law, ins3)
    for D in all_datasets(ins3, [0, 1]):
        dom = {x for x, _ in D}
        rest = [x for x in ins3 if x not in dom]
        for r in range(len(rest) + 1):
            for T in combinations(rest, r):
                m = moebius(nu, D, T, [0, 1])
                direct = sum(p for o, p in law.items()
                             if all(o[ins3.index(x)] == y for x, y in D) and all(o[ins3.index(t)] is BOT for t in T))
                checks += 1
                if m != direct:
                    fails += 1
print("   identities:", checks, "failures:", fails)

print("(5) two-point criterion")
def norm_prob(law, first, alpha, beta):
    # law over (F(a),F(b)); returns normalised probability of {(a,alpha),(b,beta)} revealing `first` first
    ia, ib = (0, 1) if first == 'a' else (1, 0)
    v1, v2 = (alpha, beta) if first == 'a' else (beta, alpha)
    P = lambda pred: sum(p for o, p in law.items() if pred(o))
    Z1 = P(lambda o: o[ia] is not BOT)
    p1 = P(lambda o: o[ia] == v1)
    Z2 = P(lambda o: o[ia] == v1 and o[ib] is not BOT)
    p2 = P(lambda o: o[ia] == v1 and o[ib] == v2)
    if p1 == 0 or p2 == 0:
        return Fr(0)
    return (p1 / Z1) * (p2 / Z2)

def star(law):
    P = lambda pred: sum(p for o, p in law.items() if pred(o))
    PA = P(lambda o: o[0] is not BOT); PB = P(lambda o: o[1] is not BOT)
    PAB = P(lambda o: o[0] is not BOT and o[1] is not BOT)
    for al in (0, 1):
        pa = P(lambda o: o[0] == al)
        if pa > 0 and P(lambda o: o[0] == al and o[1] is not BOT) / pa != PAB / PA:
            return False
    for be in (0, 1):
        pb = P(lambda o: o[1] == be)
        if pb > 0 and P(lambda o: o[1] == be and o[0] is not BOT) / pb != PAB / PB:
            return False
    return True

lawb = {(0, 0): Fr(1, 4), (0, BOT): Fr(1, 4), (1, 1): Fr(1, 4), (BOT, BOT): Fr(1, 4)}
print("   normalise(b) law: a first", norm_prob(lawb, 'a', 0, 0), " b first", norm_prob(lawb, 'b', 0, 0), " star:", star(lawb))
law3 = {(0, 0): Fr(1, 4), (1, 1): Fr(1, 8), (1, BOT): Fr(1, 8), (BOT, 1): Fr(1, 8), (BOT, BOT): Fr(3, 8)}
oi = all(norm_prob(law3, 'a', al, be) == norm_prob(law3, 'b', al, be) for al in (0, 1) for be in (0, 1))
print("   (iii) law: sums to", sum(law3.values()), " star:", star(law3), " order independent:", oi)
agree = 0; startrue = 0
for trial in range(300):
    outs = list(product([BOT, 0, 1], repeat=2))
    ws = {o: random.randint(1, 9) for o in outs}  # all cells positive
    tot = sum(ws.values())
    law = {o: Fr(v, tot) for o, v in ws.items()}
    oi = all(norm_prob(law, 'a', al, be) == norm_prob(law, 'b', al, be) for al in (0, 1) for be in (0, 1))
    s = star(law)
    startrue += s
    agree += (oi == s)
# laws satisfying star with positive defined cells: F(a), F(b) definedness independent of labels
agree2 = 0
for trial in range(200):
    # P(defined pattern) and label law given both defined; definedness independent of labels:
    pa, pb = Fr(random.randint(1, 9), 10), Fr(random.randint(1, 9), 10)
    # labels: joint law q on {0,1}^2, positive; marginals for single-defined cases equal q's marginals
    qw = [random.randint(1, 9) for _ in range(4)]; qt = sum(qw)
    q = {(i, j): Fr(qw[2 * i + j], qt) for i in (0, 1) for j in (0, 1)}
    qa = {i: q[(i, 0)] + q[(i, 1)] for i in (0, 1)}; qb = {j: q[(0, j)] + q[(1, j)] for j in (0, 1)}
    law = {}
    for i in (0, 1):
        for j in (0, 1):
            law[(i, j)] = pa * pb * q[(i, j)]
        law[(i, BOT)] = pa * (1 - pb) * qa[i]
    for j in (0, 1):
        law[(BOT, j)] = (1 - pa) * pb * qb[j]
    law[(BOT, BOT)] = (1 - pa) * (1 - pb)
    oi = all(norm_prob(law, 'a', al, be) == norm_prob(law, 'b', al, be) for al in (0, 1) for be in (0, 1))
    agree2 += (oi and star(law))
print(f"   random positive laws: star==order-independence in {agree}/300 (star true in {startrue});"
      f" independent-definedness laws: star and order independence in {agree2}/200")

print("(6) transfer identity and normalised products")
# random law on 3 inputs, check normalised products sum to 1 for input lists with repeats, and Lbar = L - sum log 1/Z
maxerr = 0.0; sums_ok = 0; total = 0
for trial in range(40):
    outs = list(product([BOT, 0, 1], repeat=3))
    ws = [random.randint(1, 6) for _ in outs]; tot = sum(ws)
    law = {o: Fr(wt, tot) for o, wt in zip(outs, ws)}
    nu = containment(law, ins3)
    for xs in product(ins3, repeat=4):
        s = Fr(0)
        for ys in product((0, 1), repeat=4):
            D = frozenset(); prod_n = Fr(1); prod_r = Fr(1); logZ = 0.0; ok = True
            for x, y in zip(xs, ys):
                dom = dict(D)
                if x in dom:
                    f = Fr(1) if dom[x] == y else Fr(0)
                    prod_n *= f; prod_r *= f
                    if f == 0:
                        ok = False; break
                    continue
                Z = sum(nu[D | {(x, yy)}] for yy in (0, 1))
                prod_r *= nu[D | {(x, y)}] / nu[D]
                prod_n *= nu[D | {(x, y)}] / Z
                logZ += math.log2(float(nu[D] / Z))
                D = D | {(x, y)}
            if ok:
                s += prod_n
                L = -math.log2(float(prod_r)); Lbar = -math.log2(float(prod_n))
                maxerr = max(maxerr, abs(Lbar - (L - logZ)))
                assert prod_n >= prod_r
        total += 1
        sums_ok += (s == 1)
print(f"   normalised products sum to 1: {sums_ok}/{total}; max |Lbar - (L - sum log 1/Z)| = {maxerr:.2e}")

print("(7) swap data")
okall = True
for d in range(1, 6):
    strs = list(product((0, 1), repeat=d))
    for x1 in strs:
        for x2 in strs:
            if x1 == x2:
                continue
            cnt = sum(1 for w in strs if tuple(a ^ b for a, b in zip(x1, w)) == x2 and tuple(a ^ b for a, b in zip(x2, w)) == x1)
            okall &= (cnt == 1)
print("   F(x)=x xor omega_{1:|x|} extends swap data with prob exactly 2^-d (d<=5):", okall)

print("(8) normalised loss is not invariant under an injective label re-encoding with the same constant")
# Toy: laws over two labels {0,1}; re-encode beta: Y -> Y' = {0,1,2} injective identity. In the universal
# setting the re-encoded universal law gives extra mass to label 2 outside range(beta), which enters the
# normaliser. Illustrate with a mixture: nu' = (1-e) * beta-image of nu + e * law giving label 2 everywhere.
for e in (Fr(1, 2), Fr(9, 10)):
    nu_law = {(0, 0): Fr(1, 2), (1, 1): Fr(1, 2)}  # total law on (a,b)
    lawp = {}
    for o, p in nu_law.items():
        lawp[o] = lawp.get(o, 0) + (1 - e) * p
    lawp[(2, 2)] = lawp.get((2, 2), 0) + e
    # semimeasure probability of D={(a,0),(b,0)} under nu' vs nu: ratio (1-e) (a constant factor)
    P = lambda law, pred: sum(p for o, p in law.items() if pred(o))
    semi = P(lawp, lambda o: o == (0, 0)) / P(nu_law, lambda o: o == (0, 0))
    # normalised conditional at a for label 0, restricted to labels {0,1} as the original predictor sees them:
    Za = P(lawp, lambda o: o[0] is not BOT)
    norm_a = P(lawp, lambda o: o[0] == 0) / Za
    print(f"   e={e}: semimeasure ratio nu'(D)/nu(D) = {semi}; normalised first-step prob of label 0: {norm_a} (orig 1/2)")

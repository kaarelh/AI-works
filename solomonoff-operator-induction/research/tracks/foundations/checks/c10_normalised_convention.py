"""c10: the normalised convention (notes-final.md Prop 5.4, Prop 5.5; referee item Q1).

Exact rational arithmetic.  A law P of a random partial function on finitely many inputs is a
probability vector over (Y u {bot})^inputs.  For a data set D and x not in dom D the semimeasure
conditional is P(D+(x,y))/P(D) and the normalised conditional is
P(D+(x,y)) / sum_y' P(D+(x,y')).

 (a) Prop 5.4 (two-point criterion), own implementation (independent of referee_code/r13).
     Inputs a, b; labels {0,1,2}.  Criterion: P(B | F(a)=alpha) = P(B | A) for all alpha and
     P(A | F(b)=beta) = P(A | B) for all beta, where A = {F(a) defined}, B = {F(b) defined}.
     Order independence: the normalised probability of {(a,alpha),(b,beta)} is the same in both
     reveal orders for every (alpha, beta).
       (a1) 400 random laws with all two-point cells positive: criterion <=> order independence.
       (a2) 400 laws built to satisfy the criterion (F(a) independent of B given A, F(b)
            independent of A given B, a random coupling on A n B): order independent in all.
       (a3) 200 random total laws: order independent, and normalised = semimeasure.
       (a4) A law without positivity where order independence holds but the criterion fails.
 (b) Prop 5.5(a) (Gibbs fact).  For a fixed input sequence (repeats allowed) the normalised
     products over all label sequences sum to exactly 1 when every normaliser is positive;
     the semimeasure products sum to P(all inputs defined) <= 1.  200 random partial laws on
     3 inputs with labels {0,1}, all 3^4 input sequences of length 4.
 (c) The first-step normaliser equals P(F(x) defined) (so for M_F it is >= 2^{-c}): checked as
     an identity on the same laws.

Seeded (20261012).  Output: c10_normalised_convention.out.txt
"""
import itertools
import random
from fractions import Fraction as Fr

SEED = 20261012
rng = random.Random(SEED)
BOT = None
out = []


def rand_law(inputs, labels, positive_cells=False, total=False, denom=30):
    vals = list(labels) if total else list(labels) + [BOT]
    outcomes = list(itertools.product(vals, repeat=len(inputs)))
    w = []
    for o in outcomes:
        lo = 1 if (positive_cells and BOT not in o) else 0
        w.append(rng.randint(lo, denom))
    if sum(w) == 0:
        w[0] = 1
    Z = sum(w)
    return {o: Fr(wi, Z) for o, wi in zip(outcomes, w)}


def P_of(law, inputs, D):
    idx = {x: i for i, x in enumerate(inputs)}
    return sum((p for o, p in law.items() if all(o[idx[x]] == y for x, y in D.items())), Fr(0))


def norm_seq(law, inputs, labels, seq):
    """normalised product along a sequence of (x, y); None if some normaliser is 0"""
    D = {}
    prod = Fr(1)
    for x, y in seq:
        if x in D:
            if D[x] != y:
                return Fr(0)
            continue
        Z = sum(P_of(law, inputs, {**D, x: yy}) for yy in labels)
        if Z == 0:
            # 0 * (undefined) = 0: an earlier factor already vanished
            return Fr(0) if prod == 0 else None
        prod *= P_of(law, inputs, {**D, x: y}) / Z
        D[x] = y
    return prod


def semi_seq(law, inputs, seq):
    D = {}
    for x, y in seq:
        if x in D and D[x] != y:
            return Fr(0)
        D[x] = y
    return P_of(law, inputs, D)


AB = ("a", "b")
Y3 = (0, 1, 2)


def criterion(law):
    PA = sum(p for o, p in law.items() if o[0] is not BOT)
    PB = sum(p for o, p in law.items() if o[1] is not BOT)
    PAB = sum(p for o, p in law.items() if o[0] is not BOT and o[1] is not BOT)
    if PA == 0 or PB == 0:
        return None
    ok = True
    for al in Y3:
        pa = sum(p for o, p in law.items() if o[0] == al)
        if pa > 0:
            pab = sum(p for o, p in law.items() if o[0] == al and o[1] is not BOT)
            ok &= (pab / pa == PAB / PA)
    for be in Y3:
        pb = sum(p for o, p in law.items() if o[1] == be)
        if pb > 0:
            pab = sum(p for o, p in law.items() if o[1] == be and o[0] is not BOT)
            ok &= (pab / pb == PAB / PB)
    return ok


def order_free(law):
    for al in Y3:
        for be in Y3:
            p1 = norm_seq(law, AB, Y3, [("a", al), ("b", be)])
            p2 = norm_seq(law, AB, Y3, [("b", be), ("a", al)])
            if p1 is None or p2 is None:
                if p1 != p2:
                    return False
                continue
            if p1 != p2:
                return False
    return True


# (a1)
agree = 0
crit_true = 0
of_true = 0
for _ in range(400):
    law = rand_law(AB, Y3, positive_cells=True)
    c = criterion(law)
    o = order_free(law)
    agree += (c == o)
    crit_true += bool(c)
    of_true += o
out.append(f"(a1) 400 random laws with positive two-point cells: criterion == order independence in {agree}; criterion true in {crit_true}; order-free in {of_true}")


# (a2) laws built to satisfy the criterion
def built_law():
    pAB, pAn, pnB, pnn = [Fr(rng.randint(1, 20)) for _ in range(4)]
    Z = pAB + pAn + pnB + pnn
    pAB, pAn, pnB, pnn = pAB / Z, pAn / Z, pnB / Z, pnn / Z
    ra = [Fr(rng.randint(1, 9)) for _ in Y3]
    ra = [v / sum(ra) for v in ra]
    rb = [Fr(rng.randint(1, 9)) for _ in Y3]
    rb = [v / sum(rb) for v in rb]
    # coupling on A n B with marginals ra, rb: mixture of product and north-west-corner coupling
    t = Fr(rng.randint(0, 10), 10)
    nw = {}
    i = j = 0
    ra_left, rb_left = ra[:], rb[:]
    while i < 3 and j < 3:
        m = min(ra_left[i], rb_left[j])
        nw[(i, j)] = nw.get((i, j), 0) + m
        ra_left[i] -= m
        rb_left[j] -= m
        if ra_left[i] == 0:
            i += 1
        if j < 3 and rb_left[j] == 0:
            j += 1
    law = {}
    for i in Y3:
        for j in Y3:
            law[(i, j)] = pAB * (t * ra[i] * rb[j] + (1 - t) * nw.get((i, j), Fr(0)))
        law[(i, BOT)] = pAn * ra[i]
    for j in Y3:
        law[(BOT, j)] = pnB * rb[j]
    law[(BOT, BOT)] = pnn
    assert sum(law.values()) == 1
    return law


ok2 = 0
crit2 = 0
for _ in range(400):
    law = built_law()
    crit2 += bool(criterion(law))
    ok2 += order_free(law)
out.append(f"(a2) 400 laws built to satisfy the criterion: criterion holds in {crit2}; order independent in {ok2}")

# (a3) total laws
ok3 = 0
eq3 = 0
for _ in range(200):
    law = rand_law(AB, Y3, total=True)
    ok3 += order_free(law)
    same = True
    for al in Y3:
        for be in Y3:
            for seq in ([("a", al), ("b", be)], [("b", be), ("a", al)]):
                pn = norm_seq(law, AB, Y3, seq)
                ps = semi_seq(law, AB, seq)
                if pn is not None and pn != ps:
                    same = False
    eq3 += same
out.append(f"(a3) 200 random total laws: order independent in {ok3}; normalised == semimeasure in {eq3}")

# (a4) no positivity: perfect correlation on A n B, criterion fails, order independence holds
law = {o: Fr(0) for o in itertools.product(list(Y3) + [BOT], repeat=2)}
law[(0, 0)] = Fr(1, 4)
law[(1, 1)] = Fr(1, 8)
law[(1, BOT)] = Fr(1, 8)
law[(BOT, 1)] = Fr(1, 8)
law[(BOT, BOT)] = Fr(3, 8)
out.append(f"(a4) law (0,0):1/4, (1,1):1/8, (1,bot):1/8, (bot,1):1/8, (bot,bot):3/8: criterion = {criterion(law)}; order independent = {order_free(law)}")
# report its numbers
PBa = {al: (sum(p for o, p in law.items() if o[0] == al and o[1] is not BOT) /
            sum(p for o, p in law.items() if o[0] == al)) for al in (0, 1)}
out.append(f"     P(B | F(a)=alpha) for alpha=0,1: {[str(PBa[al]) for al in (0, 1)]}; P(B|A) = 3/4")

# (b) Gibbs fact and (c) first normaliser
X3 = (0, 1, 2)
Y2 = (0, 1)
gibbs_ok = 0
gibbs_tot = 0
semi_ok = True
norm_ge = True
first_ok = True
for _ in range(200):
    law = rand_law(X3, Y2, positive_cells=True, denom=12)
    for xs in itertools.product(X3, repeat=4):
        s_norm = Fr(0)
        s_semi = Fr(0)
        defined = True
        for ys in itertools.product(Y2, repeat=4):
            seq = list(zip(xs, ys))
            pn = norm_seq(law, X3, Y2, seq)
            ps = semi_seq(law, X3, seq)
            if pn is None:
                defined = False
                break
            s_norm += pn
            s_semi += ps
            if pn < ps:
                norm_ge = False
        if not defined:
            continue
        gibbs_tot += 1
        gibbs_ok += (s_norm == 1)
        pall = sum(p for o, p in law.items() if all(o[x] is not BOT for x in set(xs)))
        if s_semi != pall or s_semi > 1:
            semi_ok = False
    for x in X3:
        Z = sum(P_of(law, X3, {x: y}) for y in Y2)
        if Z != sum(p for o, p in law.items() if o[x] is not BOT):
            first_ok = False
out.append(f"(b) 200 laws x 81 input sequences: normalised products sum to 1 in {gibbs_ok}/{gibbs_tot}; "
           f"semimeasure products sum to P(all defined) <= 1: {semi_ok}; normalised >= semimeasure on every sequence: {norm_ge}")
out.append(f"(c) first-step normaliser == P(F(x) defined) on all laws and inputs: {first_ok}")

text = "\n".join(out) + "\n"
print(text, end="")
with open(__file__.replace(".py", ".out.txt"), "w") as f:
    f.write(text)

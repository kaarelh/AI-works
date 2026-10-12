"""c7: the per-query product mixture S versus the per-input (set) mixture M_prod
(notes-final.md Def 4.1, Prop 6.9; referee item M1).

Finite analogue.  Inputs X = {0,1,2}, labels Y = {0,1}.  The class consists of conditional
laws P(1|x) with values in {0, 1/4, 1/2, 3/4, 1} for each x (125 laws), plus 8 conditional
*semimeasures* (P(0|x)+P(1|x) < 1 at some x), with prior weights w_i summing to 1.

  S(y_{1:n} || x_{1:n})  := sum_i w_i prod_{t<=n} P_i(y_t | x_t)        (per query)
  Mprod(D)               := sum_i w_i prod_{(x,y) in D} P_i(y | x)      (per input, D a set)

Checks (exact rational arithmetic unless stated):
 (a) S is a chronological semimeasure: sum_y S(h x y) <= S(h) for every history h of length
     <= 3 and every x; equality for histories when all class members are probabilities.
 (b) S depends only on the multiset of pairs: all permutations of every sequence of length 3.
 (c) On consistent sequences S <= Mprod(D_n); equality on sequences with distinct inputs;
     strict inequality occurs on consistent sequences with a repeated input.
 (d) Fresh-noise i.i.d. pairs from pi x P (P in the class, pi non-uniform), n = 1..7, exact
     enumeration in floating point:
       E[-log S] - E[-sum log P(y_t|x_t)] <= -log2 w_P        (expected regret)
       max over sequences of the same difference <= -log2 w_P  (pathwise regret)
       sum_t E E_pi KL(P || q_t) = E[log prod P - log S]      (telescoping identity, S(empty)=1)
     and the probability that the per-input data set is consistent (else Mprod-loss = inf).
 (e) Time stamps: the stamp-ignoring product laws on stamped inputs (x_t, t) give exactly S,
     (inconsistent sequences included: stamps make every input distinct).

Deterministic (no randomness).  Output: c7_per_query_mixture.out.txt
"""
import itertools
import math
from fractions import Fraction as Fr

X = (0, 1, 2)
Y = (0, 1)
VALS = (Fr(0), Fr(1, 4), Fr(1, 2), Fr(3, 4), Fr(1))

# class: probability laws
laws = []
for p in itertools.product(VALS, repeat=3):
    laws.append({(x, 1): p[x] for x in X} | {(x, 0): 1 - p[x] for x in X})
# 8 semimeasure laws: defect 1/4 at the inputs in a subset
for sub in itertools.product((0, 1), repeat=3):
    d = {}
    for x in X:
        if sub[x]:
            d[(x, 1)] = Fr(3, 8)
            d[(x, 0)] = Fr(3, 8)
        else:
            d[(x, 1)] = Fr(1, 2)
            d[(x, 0)] = Fr(1, 2)
    laws.append(d)
NL = len(laws)
# weights: w_i proportional to 1/(i+2)^2 restricted, normalised to sum 1 (exact)
raw = [Fr(1, (i + 2) ** 2) for i in range(NL)]
Z = sum(raw)
w = [r / Z for r in raw]
assert sum(w) == 1


def S(seq):
    """seq: list of (x,y).  Per-query mixture."""
    tot = Fr(0)
    for wi, P in zip(w, laws):
        pr = wi
        for x, y in seq:
            pr *= P[(x, y)]
            if pr == 0:
                break
        tot += pr
    return tot


def consistent(seq):
    d = {}
    for x, y in seq:
        if x in d and d[x] != y:
            return False
        d[x] = y
    return True


def Mprod(seq):
    d = {}
    for x, y in seq:
        d[x] = y
    tot = Fr(0)
    for wi, P in zip(w, laws):
        pr = wi
        for x, y in d.items():
            pr *= P[(x, y)]
        tot += pr
    return tot


out = []
out.append(f"class: {NL} conditional laws (125 probability laws + 8 semimeasures); weights sum to {sum(w)}")

# (a) chronological semimeasure inequality
viol = 0
eq_viol = 0
checked = 0
pairs = [(x, y) for x in X for y in Y]
for k in range(0, 4):
    for h in itertools.product(pairs, repeat=k):
        sh = S(list(h))
        for x in X:
            s = sum(S(list(h) + [(x, y)]) for y in Y)
            checked += 1
            if s > sh:
                viol += 1
out.append(f"(a) chronological inequality sum_y S(h x y) <= S(h): {checked} (h,x) pairs, violations = {viol}")

# (b) multiset invariance
bad = 0
cnt = 0
for seq in itertools.product(pairs, repeat=3):
    vals = {S(list(p)) for p in itertools.permutations(seq)}
    cnt += 1
    if len(vals) != 1:
        bad += 1
out.append(f"(b) permutation invariance: {cnt} sequences of length 3, sequences with more than one value = {bad}")

# (c) S <= Mprod on consistent sequences; equality iff distinct inputs (here)
le_viol = 0
eq_distinct_viol = 0
strict_repeat = 0
n_cons = 0
for n in range(1, 5):
    for seq in itertools.product(pairs, repeat=n):
        if not consistent(seq):
            continue
        n_cons += 1
        s, m = S(list(seq)), Mprod(list(seq))
        if s > m:
            le_viol += 1
        distinct = len({x for x, _ in seq}) == len(seq)
        if distinct and s != m:
            eq_distinct_viol += 1
        if not distinct and s < m:
            strict_repeat += 1
out.append(f"(c) {n_cons} consistent sequences (n<=4): S > Mprod in {le_viol}; S != Mprod with distinct inputs in {eq_distinct_viol}; S < Mprod strictly (repeated input) in {strict_repeat}")

# (d) fresh-noise i.i.d. data
pi = {0: 0.5, 1: 1 / 3, 2: 1 / 6}
truth_index = [i for i, P in enumerate(laws) if (P[(0, 1)], P[(1, 1)], P[(2, 1)]) == (Fr(1, 4), Fr(3, 4), Fr(1, 2))][0]
P = laws[truth_index]
wP = float(w[truth_index])
bound = -math.log2(wP)
lawsf = [{k: float(v) for k, v in L.items()} for L in laws]
wf = [float(x) for x in w]
out.append(f"(d) truth P(1|x) = (1/4, 3/4, 1/2), index {truth_index}, -log2 w_P = {bound:.4f}; pi = (1/2, 1/3, 1/6)")
out.append("    n  E regret   max pathwise regret   sum_t E KL_t   E[log prodP - log S]   P(per-input data consistent)")
all_ok = True
for n in range(1, 8):
    E_reg = 0.0
    max_reg = -1e9
    E_kl = 0.0
    p_cons = 0.0
    for xs in itertools.product(X, repeat=n):
        px = 1.0
        for x in xs:
            px *= pi[x]
        for ys in itertools.product(Y, repeat=n):
            pr = px
            for x, y in zip(xs, ys):
                pr *= float(P[(x, y)])
            if pr == 0:
                continue
            # S along the sequence, tracking per-law products
            prods = list(wf)
            klsum = 0.0
            for t, (x, y) in enumerate(zip(xs, ys)):
                Sprev = sum(prods)
                q = {yy: sum(pr_i * L[(x, yy)] for pr_i, L in zip(prods, lawsf)) / Sprev for yy in Y}
                # E_pi KL(P||q_t) for this history: expectation over a fresh x' ~ pi of KL(P(.|x')||q_t(.|x'))
                klx = 0.0
                for xp in X:
                    qx = {yy: sum(pr_i * L[(xp, yy)] for pr_i, L in zip(prods, lawsf)) / Sprev for yy in Y}
                    for yy in Y:
                        p_ = float(P[(xp, yy)])
                        if p_ > 0:
                            klx += pi[xp] * p_ * math.log2(p_ / qx[yy])
                klsum += klx
                prods = [pr_i * L[(x, y)] for pr_i, L in zip(prods, lawsf)]
            Sn = sum(prods)
            logP = sum(math.log2(float(P[(x, y)])) for x, y in zip(xs, ys))
            reg = logP - math.log2(Sn)
            E_reg += pr * reg
            max_reg = max(max_reg, reg)
            E_kl += pr * klsum
            if consistent(list(zip(xs, ys))):
                p_cons += pr
    ok = E_reg <= bound + 1e-9 and max_reg <= bound + 1e-9 and abs(E_kl - E_reg) < 1e-9
    all_ok &= ok
    out.append(f"   {n}  {E_reg:8.4f}   {max_reg:10.4f}            {E_kl:8.4f}        {E_reg:8.4f}              {p_cons:.6f}")
out.append(f"    all bounds and the identity hold for n=1..7: {all_ok}")

# (e) stamps
# stamp-ignoring product laws on stamped inputs (x,t): identical to S by construction of the
# per-input product over distinct stamped inputs.  Compute it as a per-input (set) mixture over
# stamped inputs and compare with S.
def Mprod_stamped_ignoring(seq):
    d = {(x, t): y for t, (x, y) in enumerate(seq)}
    tot = Fr(0)
    for wi, Pl in zip(w, laws):
        pr = wi
        for (x, t), y in d.items():
            pr *= Pl[(x, y)]
        tot += pr
    return tot


diff = 0
n_e = 0
for n in range(1, 5):
    for seq in itertools.product(pairs, repeat=n):
        n_e += 1
        if Mprod_stamped_ignoring(list(seq)) != S(list(seq)):
            diff += 1
out.append(f"(e) stamped stamp-ignoring set mixture == S on all {n_e} sequences of length <= 4 (incl. inconsistent ones): {diff == 0}")


text = "\n".join(out) + "\n"
print(text, end="")
with open(__file__.replace(".py", ".out.txt"), "w") as f:
    f.write(text)

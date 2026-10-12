"""c11: last iterate versus averaged predictor, the exchangeability identity, and the
integrability step of the merging theorem (notes-final.md Prop 6.10, Remark 6.11, Thm 6.5 proof;
referee items Q4 and m4).

 (a) Prop 6.10, the two-input example.  X = {a, b}, inputs i.i.d. uniform, target phi = 0.
     Prior: phi with weight w, the two one-flip functions (1,0) and (0,1) with weight (1-w)/2
     each.  Expected log risk of the posterior predictive after t samples, r_t, computed by
     brute force over input sequences (exact rationals inside the logs), compared with the
     closed forms r_0 = -log2((1+w)/2), r_1 = (1/2) log2((1+w)/(2w)), r_2 = r_1/2.
     Checks r_1 > r_0 and the cumulative bound r_0 + ... + r_{n-1} <= -log2 w, for
     w in {1/2, 1/4, 1/16, 1/100, 1/1000}, n <= 6.
 (b) Exchangeability identity E R(Q_n) = E[LOO_{n+1}] (Remark 6.11) on 50 random finite
     mixtures (all Boolean functions on 3 inputs, random prior, random target, random input
     law), n = 0..4; maximum absolute discrepancy reported.
 (c) m4: for a probability vector p and a sub-probability vector q on the same finite set,
     sum_y p(y) max(0, log2(q(y)/p(y))) <= log2 e.  20000 random pairs (seed 20261012), plus a
     near-extremal family; the largest value found is reported.

Seeded (20261012).  Output: c11_learning_curve.out.txt
"""
import itertools
import math
import random
from fractions import Fraction as Fr

SEED = 20261012
rng = random.Random(SEED)
out = []


def risk_curve(funcs, prior, target, pi, nmax):
    """r_t = E over t i.i.d. inputs of E_{x~pi}[-log2 Q_t(target(x)|x)], Q_t the posterior predictive
    (inputs seen: stored label with probability 1).  Exact enumeration over input sequences."""
    X = list(range(len(target)))
    rs = []
    for t in range(nmax + 1):
        r = 0.0
        for xs in itertools.product(X, repeat=t):
            px = 1.0
            for x in xs:
                px *= pi[x]
            seen = set(xs)
            cons = [(f, w) for f, w in zip(funcs, prior) if all(f[x] == target[x] for x in seen)]
            Z = sum(w for _, w in cons)
            R = 0.0
            for x in X:
                if x in seen:
                    continue
                q = sum(w for f, w in cons if f[x] == target[x]) / Z
                R += pi[x] * (-math.log2(q))
            r += px * R
        rs.append(r)
    return rs


out.append("(a) two inputs, target 00, prior w on 00 and (1-w)/2 on each of 10, 01:")
alls = True
for w in (Fr(1, 2), Fr(1, 4), Fr(1, 16), Fr(1, 100), Fr(1, 1000)):
    funcs = [(0, 0), (1, 0), (0, 1)]
    prior = [w, (1 - w) / 2, (1 - w) / 2]
    rs = risk_curve(funcs, prior, (0, 0), [0.5, 0.5], 6)
    wf = float(w)
    r0 = -math.log2((1 + wf) / 2)
    r1 = 0.5 * math.log2((1 + wf) / (2 * wf))
    closed_ok = abs(rs[0] - r0) < 1e-12 and abs(rs[1] - r1) < 1e-12 and abs(rs[2] - r1 / 2) < 1e-12
    cum_ok = all(sum(rs[:n]) <= -math.log2(wf) + 1e-12 for n in range(1, 8))
    alls &= closed_ok and cum_ok
    out.append(f"    w={str(w):7s} r_0..r_4 = " + ", ".join(f"{r:.4f}" for r in rs[:5])
               + f"   r_1 > r_0: {rs[1] > rs[0]}   closed forms: {closed_ok}   cumulative <= -log2 w = {-math.log2(wf):.3f}: {cum_ok}")
out.append(f"    all closed forms and cumulative bounds hold: {alls}")

# (b) exchangeability identity
maxdisc = 0.0
nonmono = 0
for trial in range(50):
    m = 3
    funcs = list(itertools.product((0, 1), repeat=m))
    prior = [rng.random() ** 3 + 1e-3 for _ in funcs]
    Zp = sum(prior)
    prior = [p / Zp for p in prior]
    target = funcs[rng.randrange(len(funcs))]
    pi = [rng.random() + 0.05 for _ in range(m)]
    Zx = sum(pi)
    pi = [p / Zx for p in pi]
    rs = risk_curve(funcs, prior, target, pi, 4)
    if any(rs[i + 1] > rs[i] + 1e-12 for i in range(4)):
        nonmono += 1
    # E[LOO_{n+1}]: n+1 i.i.d. draws, average over held-out position of -log2 Q_{others}(target(x_i)|x_i)
    for n in range(0, 4):
        e = 0.0
        for xs in itertools.product(range(m), repeat=n + 1):
            px = 1.0
            for x in xs:
                px *= pi[x]
            tot = 0.0
            for i in range(n + 1):
                others = set(xs[:i] + xs[i + 1:])
                if xs[i] in others:
                    continue
                cons = [(f, w) for f, w in zip(funcs, prior) if all(f[x] == target[x] for x in others)]
                Z = sum(w for _, w in cons)
                q = sum(w for f, w in cons if f[xs[i]] == target[xs[i]]) / Z
                tot += -math.log2(q)
            e += px * tot / (n + 1)
        maxdisc = max(maxdisc, abs(e - rs[n]))
out.append(f"(b) 50 random mixtures on 3 inputs: max |E R(Q_n) - E LOO_(n+1)| over n=0..3 = {maxdisc:.2e}; "
           f"instances with a non-monotone risk curve (n<=4): {nonmono}/50")

# (c) integrability bound
best = 0.0
for _ in range(20000):
    K = rng.randint(2, 6)
    p = [rng.random() for _ in range(K)]
    sp = sum(p)
    p = [v / sp for v in p]
    q = [rng.random() for _ in range(K)]
    sq = sum(q) * (1 + rng.random())
    q = [v / sq for v in q]
    val = sum(pi_ * max(0.0, math.log2(qi / pi_)) for pi_, qi in zip(p, q))
    best = max(best, val)
# near-extremal: p uniform on K points except a tiny atom where q puts almost all its mass
fam = []
for K in (2, 10, 100, 1000):
    for eps in (1e-1, 1e-2, 1e-3, 1e-4):
        p = [eps] + [(1 - eps) / (K - 1)] * (K - 1)
        q = [1 - 1e-12] + [1e-12 / (K - 1)] * (K - 1)
        val = sum(pi_ * max(0.0, math.log2(qi / pi_)) for pi_, qi in zip(p, q))
        fam.append(val)
        best = max(best, val)
out.append(f"(c) sum_y p max(0, log2(q/p)) <= log2 e = {math.log2(math.e):.4f}: largest value over 20000 random pairs "
           f"and a near-extremal family = {best:.4f} (near-extremal values up to {max(fam):.4f})")

text = "\n".join(out) + "\n"
print(text, end="")
with open(__file__.replace(".py", ".out.txt"), "w") as f:
    f.write(text)

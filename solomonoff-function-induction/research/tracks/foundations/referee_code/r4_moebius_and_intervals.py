"""r4 (referee): Prop 2.3 (sufficiency direction) and Prop 3.3(c) (interval machine) of the foundations notes.

The track computed only the necessity direction of Prop 2.3 (c6a).  Here, with exact rationals:
  (a) for random laws P of random partial functions on 3 inputs, labels {0,1,2}: from nu = P(F > .)
      alone, rebuild q_S(v) = Delta(v^def, S_bot(v)) for every S and v; check q_S(v) >= 0,
      sum_v q_S(v) = 1, the one-step consistency identity, and q_S = the true marginal of P;
  (b) for random weak semimeasures (trimmed random values) and for tau: whenever all Moebius sums
      are >= 0, the rebuilt law has containment functional exactly nu; when some sum is negative,
      no law exists (count how many random weak semimeasures fail);
  (c) Prop 3.3(c): nested interval partition J(v) of [0,1) built from the cylinder probabilities,
      with J(v bot) placed last; check nesting, tiling, lengths |J(v)| = q_k(v), and that the label
      read off at level k is consistent with all coarser levels (so the machine is consistent and
      its law is P).

Seed 20261011.  Output: r4_moebius_and_intervals_output.txt
"""
import itertools
import random
from fractions import Fraction as Fr

X = (0, 1, 2)
Y = (0, 1, 2)
BOT = None
YB = Y + (BOT,)


def partials(inputs, labels=Y):
    for vals in itertools.product((BOT,) + tuple(labels), repeat=len(inputs)):
        yield frozenset((x, v) for x, v in zip(inputs, vals) if v is not BOT)


def random_law(rng):
    pts = list(itertools.product(YB, repeat=3))
    w = [rng.randrange(0, 15) for _ in pts]
    tot = sum(w)
    return {pt: Fr(wi, tot) for pt, wi in zip(pts, w)}


def containment(P):
    tab = {}
    for D in partials(X):
        tab[D] = sum(p for pt, p in P.items() if all(pt[x] == y for x, y in D))
    return lambda D: tab.get(D, Fr(0))


def Delta(nu, D, T):
    return sum((-1) ** len(E) * nu(D | E) for E in partials(T))


def rebuild(nu):
    """q[S][v] for S a tuple of inputs (sorted) and v in YB^S."""
    q = {}
    for r in range(len(X) + 1):
        for S in itertools.combinations(X, r):
            q[S] = {}
            for v in itertools.product(YB, repeat=r):
                Ddef = frozenset((x, y) for x, y in zip(S, v) if y is not BOT)
                Tb = tuple(x for x, y in zip(S, v) if y is BOT)
                q[S][v] = Delta(nu, Ddef, Tb)
    return q


def check_rebuild(nu, P=None):
    q = rebuild(nu)
    neg = any(val < 0 for S in q for val in q[S].values())
    sums_ok = all(sum(q[S].values()) == nu(frozenset()) for S in q)
    # one-step consistency: q_{S u {x}}(v, .) sums to q_S(v)
    cons_ok = True
    for S in q:
        for x in X:
            if x in S:
                continue
            S2 = tuple(sorted(S + (x,)))
            pos = S2.index(x)
            for v in q[S]:
                tot = sum(q[S2][v[:pos] + (a,) + v[pos:]] for a in YB)
                cons_ok &= tot == q[S][v]
    true_ok = None
    if P is not None:
        true_ok = all(q[S][v] == sum(p for pt, p in P.items() if all(pt[x] == y for x, y in zip(S, v)))
                      for S in q for v in q[S])
    # containment of rebuilt law (full S = X) equals nu
    full = q[X]
    cont_ok = all(sum(p for pt, p in full.items() if all(pt[x] == y for x, y in D)) == nu(D)
                  for D in partials(X))
    return neg, sums_ok, cons_ok, true_ok, cont_ok


def random_weak(rng):
    vals = {}
    allD = sorted(partials(X), key=len)
    for D in allD:
        vals[D] = Fr(1) if len(D) == 0 else Fr(rng.randrange(0, 10), 10)
    changed = True
    while changed:
        changed = False
        for D in allD:
            dom = {x for x, _ in D}
            for x in X:
                if x in dom:
                    continue
                kids = [D | {(x, y)} for y in Y]
                s = sum(vals[k] for k in kids)
                if s > vals[D]:
                    changed = True
                    for k in kids:
                        vals[k] = vals[k] * vals[D] / s
    return lambda D: vals.get(D, Fr(0))


def tau():
    t = {frozenset(): Fr(1)}
    for x in X:
        for y in (0, 1):
            t[frozenset({(x, y)})] = Fr(1, 2)
    for E in ({(0, 0), (1, 1)}, {(1, 0), (2, 1)}, {(2, 0), (0, 1)}):
        t[frozenset(E)] = Fr(1, 2)
    return lambda D: t.get(D, Fr(0))


def intervals(P):
    """J[v] = (left, right) for v in YB^k, k = 0..3, built as in Prop 3.3(c)."""
    def qk(v):
        return sum(p for pt, p in P.items() if pt[:len(v)] == v)
    J = {(): (Fr(0), Fr(1))}
    for k in range(3):
        for v in itertools.product(YB, repeat=k):
            left, right = J[v]
            pos = left
            for a in Y:
                J[v + (a,)] = (pos, pos + qk(v + (a,)))
                pos += qk(v + (a,))
            lb = left + qk(v) - qk(v + (BOT,))
            J[v + (BOT,)] = (lb, lb + qk(v + (BOT,)))
    return J, qk


def check_intervals(P):
    J, qk = intervals(P)
    ok = True
    for v, (l, r) in J.items():
        ok &= (r - l) == qk(v)
        if len(v) > 0:
            pl, pr = J[v[:-1]]
            ok &= pl <= l and r <= pr  # nesting
    for k in range(3):
        for v in itertools.product(YB, repeat=k):
            kids = sorted(J[v + (a,)] for a in YB)
            ok &= kids[0][0] == J[v][0] and kids[-1][1] == J[v][1]
            ok &= all(kids[i][1] == kids[i + 1][0] for i in range(len(kids) - 1))  # tiling, no gaps/overlap
    # label read at level k from the level-k cell must equal the level-3 cell's coordinate k
    for w in itertools.product(YB, repeat=3):
        l, r = J[w]
        if r == l:
            continue
        mid = (l + r) / 2
        for k in range(1, 4):
            cell = [v for v in itertools.product(YB, repeat=k) if J[v][0] < mid < J[v][1]]
            ok &= len(cell) == 1 and cell[0] == w[:k]
    return ok


def main():
    rng = random.Random(20261011)
    lines = []
    res = [check_rebuild(containment(P), P) for P in (random_law(rng) for _ in range(40))]
    lines.append("(a) 40 random laws: any negative Moebius sum: %s; sums = 1: %s; consistency: %s; "
                 "rebuilt = true marginals: %s; rebuilt containment = nu: %s" % (
                     any(r[0] for r in res), all(r[1] for r in res), all(r[2] for r in res),
                     all(r[3] for r in res), all(r[4] for r in res)))
    n_ok = n_neg = 0
    good = True
    for _ in range(200):
        nu = random_weak(rng)
        neg, sums_ok, cons_ok, _, cont_ok = check_rebuild(nu)
        if neg:
            n_neg += 1
        else:
            n_ok += 1
            good &= sums_ok and cons_ok and cont_ok
    lines.append(f"(b) 200 random weak semimeasures: {n_neg} have a negative Moebius sum (no law exists); "
                 f"{n_ok} have all sums >= 0, and for all of them the rebuilt law reproduces nu: {good}")
    neg, *_ = check_rebuild(tau())
    lines.append(f"(b) tau of Example 2.4: negative Moebius sum present: {neg}")
    okc = all(check_intervals(random_law(rng)) for _ in range(40))
    lines.append(f"(c) Prop 3.3(c) interval machine on 40 random laws: nesting, tiling, lengths and label consistency all hold: {okc}")
    out = "\n".join(lines)
    print(out)
    with open(__file__.replace(".py", "_output.txt"), "w") as f:
        f.write(out + "\n")


if __name__ == "__main__":
    main()

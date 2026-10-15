"""c6: two finite identities used in notes.md.

(a) Prop 2.3 (Moebius characterisation).  For random sub-probability laws P on (Y+{bot})^S,
    S = 3 inputs, Y = {0,1,2}: the Moebius sum
        sum_{E: dom E subset of T} (-1)^{|E|} nu(D u E)
    of the containment functional nu(D) = P(F contains D) equals P(F contains D, F = bot on T)
    for every D and every T disjoint from dom D.  Checked on 200 seeded random laws.
(b) Thm 3.5(ii), proof step.  For a weak semimeasure nu and a fixed finite domain S with a fixed order,
    sequential sampling (label of x_1 from nu(x_1 .), then x_2 from nu(x_1 y_1, x_2 .)/nu(x_1 y_1), ...)
    gives a random partial function rho_S with rho_S(D) = nu(D) whenever dom D = S, and
    rho_S(D) <= nu(D) when dom D is a proper subset of S.  Checked on the weak semimeasure tau
    of c1 and on 200 seeded random weak semimeasures built by trimming.

Seed 20261011.  Output: c6_moebius_and_sequential.out.txt
"""
import itertools
import random
from fractions import Fraction as Fr

BOT = None


def partials(inputs, Y):
    for vals in itertools.product((BOT,) + tuple(Y), repeat=len(inputs)):
        yield frozenset((x, v) for x, v in zip(inputs, vals) if v is not BOT)


def check_moebius(rng, trials=200):
    S = (0, 1, 2)
    Y = (0, 1, 2)
    pts = list(itertools.product((BOT,) + Y, repeat=3))
    worst = Fr(0)
    for _ in range(trials):
        wts = [Fr(rng.randrange(0, 20)) for _ in pts]
        tot = sum(wts) + rng.randrange(0, 10)  # leave a defect: sub-probability
        P = {pt: w / tot for pt, w in zip(pts, wts)}

        def nu(D):
            return sum(p for pt, p in P.items() if all(pt[x] == y for x, y in D))
        for D in partials(S, Y):
            dom = {x for x, _ in D}
            rest = [x for x in S if x not in dom]
            for r in range(len(rest) + 1):
                for T in itertools.combinations(rest, r):
                    mob = sum((-1) ** len(E) * nu(D | E) for E in partials(T, Y))
                    direct = sum(p for pt, p in P.items()
                                 if all(pt[x] == y for x, y in D) and all(pt[t] is BOT for t in T))
                    worst = max(worst, abs(mob - direct))
    return worst


def tau():
    t = {frozenset(): Fr(1)}
    for x in (0, 1, 2):
        for y in (0, 1):
            t[frozenset({(x, y)})] = Fr(1, 2)
    for E in ({(0, 0), (1, 1)}, {(1, 0), (2, 1)}, {(2, 0), (0, 1)}):
        t[frozenset(E)] = Fr(1, 2)
    return lambda D: t.get(D, Fr(0))


def random_weak(rng, S, Y):
    """Random weak semimeasure on partial functions over S: random values, then trimmed
    top-down so that every one-point inequality holds (scale children down if needed)."""
    vals = {}
    allD = sorted(partials(S, Y), key=len)
    for D in allD:
        vals[D] = Fr(1) if len(D) == 0 else Fr(rng.randrange(0, 10), 10)
    # enforce nu(D u {(x,y)}) summed over y <= nu(D) for all D, x: process by size, cap children
    for D in allD:
        dom = {x for x, _ in D}
        for x in S:
            if x in dom:
                continue
            kids = [D | {(x, y)} for y in Y]
            s = sum(vals[k] for k in kids)
            if s > vals[D]:
                for k in kids:
                    vals[k] = vals[k] * vals[D] / s
    # capping a child can break nothing above it, but a node capped later via another parent
    # only decreases, so re-run until stable
    changed = True
    while changed:
        changed = False
        for D in allD:
            dom = {x for x, _ in D}
            for x in S:
                if x in dom:
                    continue
                kids = [D | {(x, y)} for y in Y]
                s = sum(vals[k] for k in kids)
                if s > vals[D]:
                    changed = True
                    for k in kids:
                        vals[k] = vals[k] * vals[D] / s
    return lambda D: vals.get(D, Fr(0))


def is_weak(nu, S, Y):
    for D in partials(S, Y):
        dom = {x for x, _ in D}
        for x in S:
            if x not in dom and sum(nu(D | {(x, y)}) for y in Y) > nu(D):
                return False
    return True


def sequential(nu, S, Y):
    """law of the sequentially sampled random partial function on S (order = S as given)."""
    law = {}

    def rec(prefix, prob, i):
        if i == len(S):
            law[tuple(v for _, v in prefix)] = law.get(tuple(v for _, v in prefix), 0) + prob
            return
        D = frozenset((x, v) for x, v in prefix if v is not BOT)
        if any(v is BOT for _, v in prefix):
            # once a label is bot (sampler never halts), later labels are never produced
            rec(prefix + [(S[i], BOT)], prob, i + 1)
            return
        base = nu(D)
        used = Fr(0)
        for y in Y:
            c = nu(D | {(S[i], y)})
            if c > 0:
                rec(prefix + [(S[i], y)], prob * c / base, i + 1)
                used += c
        if base > used:
            rec(prefix + [(S[i], BOT)], prob * (base - used) / base, i + 1)
    rec([], Fr(1), 0)
    # scale by nu(empty): mass not starting is defect
    scale = nu(frozenset())
    law = {k: v * scale for k, v in law.items()}

    def rho(D):
        return sum(p for pt, p in law.items() if all(pt[S.index(x)] == y for x, y in D))
    return rho


def check_sequential(nu, S, Y):
    rho = sequential(nu, S, Y)
    eq_full = all(rho(D) == nu(D) for D in partials(S, Y) if len(D) == len(S))
    le_sub = all(rho(D) <= nu(D) for D in partials(S, Y))
    strict = sum(1 for D in partials(S, Y) if rho(D) < nu(D))
    return eq_full, le_sub, strict


def main():
    rng = random.Random(20261011)
    lines = []
    w = check_moebius(rng)
    lines.append(f"(a) max |Moebius sum - P(F contains D, F=bot on T)| over 200 random laws: {w}")
    S = (0, 1, 2)
    eq, le, strict = check_sequential(tau(), S, (0, 1))
    lines.append(f"(b) tau: rho_S = nu on full domain: {eq}; rho_S <= nu everywhere: {le}; "
                 f"#D with rho_S(D) < nu(D): {strict}")
    ok_all = True
    nweak = 0
    for _ in range(200):
        nu = random_weak(rng, S, (0, 1))
        if not is_weak(nu, S, (0, 1)):
            continue
        nweak += 1
        eq, le, _ = check_sequential(nu, S, (0, 1))
        ok_all &= eq and le
    lines.append(f"(b) random weak semimeasures: {nweak} generated and verified weak; "
                 f"identities hold for all: {ok_all}")
    out = "\n".join(lines)
    print(out)
    with open(__file__.replace(".py", ".out.txt"), "w") as f:
        f.write(out + "\n")


if __name__ == "__main__":
    main()

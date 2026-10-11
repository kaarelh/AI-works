"""r3 (referee): executable test of the trimming construction in Theorem 3.4 of the foundations notes,
and of the rounding claim in the proof of Lemma 3.1.

Toy universe: inputs X = {0,1,2}, labels Y = {0,1,2}; stage universe U_t = data sets with inputs
and labels < t.  For a lower-semicomputable phi with approximations phi_t (nondecreasing in t):
    phi'_t(D) = max{ phi_t(D), max_{x<t, x not in dom D} sum_{y<t} phi'_t(D+(x,y)) }  on U_t,
computed by decreasing |dom D|; freeze at stage t if phi'_t(empty) > 1.
Checks:
  (a) phi'_t nondecreasing in t; weak inequality inside U_t; phi'_t(D) <= phi'_t(empty) <= 1 unless frozen;
  (b) the limit nu is a weak function semimeasure on the whole toy universe;
  (c) if phi is already a weak semimeasure (containment functionals of random laws, and tau of
      Example 2.4 on 3 inputs), there is no freezing and nu = phi exactly;
  (d) random non-weak phi: limit is weak (with or without freezing); counts of freezes.
  (e) Lemma 3.1 rounding: for nondecreasing a_t in [0,1], floor(a_t 2^t)/2^t is nondecreasing in t.

Seed 20261011.  Output: r3_trimming_thm34_output.txt
"""
import itertools
import random
from fractions import Fraction as Fr

X = (0, 1, 2)
Y = (0, 1, 2)
T_END = 8


def partials(inputs, labels):
    for vals in itertools.product((None,) + tuple(labels), repeat=len(inputs)):
        yield frozenset((x, v) for x, v in zip(inputs, vals) if v is not None)


ALLD = list(partials(X, Y))


def in_U(D, t):
    return all(x < t and y < t for x, y in D)


def is_weak(nu, inputs=X, labels=Y):
    if nu(frozenset()) > 1:
        return False
    for D in ALLD:
        dom = {x for x, _ in D}
        for x in inputs:
            if x not in dom and sum(nu(D | {(x, y)}) for y in labels) > nu(D):
                return False
    return True


def trim(phi_t):
    """phi_t(t, D) -> approximations.  Returns final nu (dict), list of stage tables, frozen stage."""
    prev = {D: Fr(0) for D in ALLD}
    stages = []
    frozen = None
    for t in range(1, T_END + 1):
        cur = {D: Fr(0) for D in ALLD}
        for D in sorted((D for D in ALLD if in_U(D, t)), key=len, reverse=True):
            dom = {x for x, _ in D}
            best = phi_t(t, D)
            for x in X:
                if x < t and x not in dom:
                    s = sum(cur[D | {(x, y)}] for y in Y if y < t)
                    best = max(best, s)
            cur[D] = best
        if cur[frozenset()] > 1:
            frozen = t
            stages.extend([prev] * (T_END - t + 1))
            break
        stages.append(cur)
        prev = cur
    return prev, stages, frozen


def check_stages(stages):
    bad = 0
    for t in range(1, len(stages)):
        if any(stages[t][D] < stages[t - 1][D] for D in ALLD):
            bad += 1
    for t, st in enumerate(stages, start=1):
        for D in ALLD:
            if not in_U(D, t):
                continue
            dom = {x for x, _ in D}
            for x in X:
                if x < t and x not in dom:
                    if sum(st[D | {(x, y)}] for y in Y if y < t) > st[D]:
                        bad += 1
    return bad


def random_law_containment(rng):
    pts = list(itertools.product((None,) + Y, repeat=3))
    w = [rng.randrange(0, 12) for _ in pts]
    tot = sum(w) + rng.randrange(0, 5)
    P = {pt: Fr(wi, tot) for pt, wi in zip(pts, w)}
    tab = {D: sum(p for pt, p in P.items() if all(pt[x] == y for x, y in D)) for D in ALLD}
    return lambda D: tab[D]


def tau3():
    t = {frozenset(): Fr(1)}
    for x in X:
        for y in (0, 1):
            t[frozenset({(x, y)})] = Fr(1, 2)
    for E in ({(0, 0), (1, 1)}, {(1, 0), (2, 1)}, {(2, 0), (0, 1)}):
        t[frozenset(E)] = Fr(1, 2)
    return lambda D: t.get(D, Fr(0))


def approx_of(phi, rng):
    sched = {D: sorted(rng.random() for _ in range(T_END)) for D in ALLD}

    def phi_t(t, D):
        if t >= T_END - 2:
            return phi(D)
        g = Fr(sched[D][t - 1]).limit_denominator(1000)
        return phi(D) * g
    return phi_t


def main():
    rng = random.Random(20261011)
    lines = []
    # (c) weak phi
    bad_c = mism = freezes = 0
    n = 0
    for phi in [tau3()] + [random_law_containment(rng) for _ in range(40)]:
        n += 1
        nu, stages, frozen = trim(approx_of(phi, rng))
        bad_c += check_stages(stages)
        freezes += frozen is not None
        mism += any(nu[D] != phi(D) for D in ALLD)
    lines.append(f"(c) weak phi (tau + 40 random containment functionals): stage-invariant violations={bad_c}, "
                 f"freezes={freezes}, limit != phi in {mism}/{n} cases")
    # (d) random non-weak phi
    bad_d = notweak = fr = 0
    trials = 200
    for i in range(trials):
        scale = Fr(rng.randrange(1, 9), 8)
        vals = {D: (Fr(1) if len(D) == 0 else Fr(rng.randrange(0, 101), 100) * scale) for D in ALLD}
        phi = lambda D, v=vals: v[D]
        nu, stages, frozen = trim(approx_of(phi, rng))
        bad_d += check_stages(stages)
        fr += frozen is not None
        if not is_weak(lambda D, nu=nu: nu[D]):
            notweak += 1
    lines.append(f"(d) {trials} random non-weak phi: stage-invariant violations={bad_d}, frozen in {fr}, "
                 f"limit not weak in {notweak}")
    # (e) rounding monotonicity
    viol = 0
    for _ in range(20000):
        a = sorted(rng.random() for _ in range(12))
        r = [Fr(int(Fr(x).limit_denominator(10 ** 9) * 2 ** t), 2 ** t) for t, x in enumerate(a, start=1)]
        viol += any(r[i + 1] < r[i] for i in range(len(r) - 1))
    lines.append(f"(e) rounding floor(a_t 2^t)/2^t of 20000 random nondecreasing sequences: monotonicity violations={viol}")
    out = "\n".join(lines)
    print(out)
    with open(__file__.replace(".py", "_output.txt"), "w") as f:
        f.write(out + "\n")


if __name__ == "__main__":
    main()

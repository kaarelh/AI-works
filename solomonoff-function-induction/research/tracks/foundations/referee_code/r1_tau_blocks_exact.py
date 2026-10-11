"""r1 (referee): independent checks of Example 2.4 and Theorem 3.5(iii) of the foundations notes.

Independent re-implementation (exact rationals, no LP solver):
  (a) the two-input weak semimeasure of Example 2.4 satisfies every one-point inequality and has
      Moebius sum -1 at (emptyset, {a,b});
  (b) tau^{(x)k} satisfies every one-point inequality, exhaustively, for k = 1, 2, 3
      (k = 3: 3^9 = 19683 partial functions on 9 inputs);
  (c) the explicit law "uniform over three total functions g1 > E1, g2 > E2, g3 > E3" and its
      k-fold product attain min_D P(F > D)/tau^{(x)k}(D) = (2/3)^k on the support of tau^{(x)k},
      for k = 1..4 and for every choice of the free coordinates (k = 1); this shows (2/3)^k is
      exact for every k, not only k <= 3 (the notes use an LP for k <= 3);
  (d) the 3^k data sets E_i are pairwise inconsistent and each has tau^{(x)k} = 2^-k (k <= 4).

Deterministic.  Output: r1_tau_blocks_exact_output.txt
"""
import itertools
from fractions import Fraction as Fr

Y = (0, 1)


def partials(inputs, labels=Y):
    for vals in itertools.product((None,) + tuple(labels), repeat=len(inputs)):
        yield frozenset((x, v) for x, v in zip(inputs, vals) if v is not None)


def weak_violations(val, inputs):
    n = bad = 0
    for D in partials(inputs):
        dom = {x for x, _ in D}
        vD = val(D)
        for x in inputs:
            if x in dom:
                continue
            n += 1
            if sum(val(D | {(x, y)}) for y in Y) > vD:
                bad += 1
    return n, bad


def tau1():
    a, b, c = 0, 1, 2
    t = {frozenset(): Fr(1)}
    for x in (a, b, c):
        for y in Y:
            t[frozenset({(x, y)})] = Fr(1, 2)
    E = [frozenset({(a, 0), (b, 1)}), frozenset({(b, 0), (c, 1)}), frozenset({(c, 0), (a, 1)})]
    for e in E:
        t[e] = Fr(1, 2)
    return t, E


T1, E1 = tau1()


def tau_k(k):
    def val(D):
        r = Fr(1)
        for x, _ in D:
            if not (0 <= x < 3 * k):
                return Fr(0)
        for j in range(k):
            Dj = frozenset((x - 3 * j, y) for x, y in D if 3 * j <= x < 3 * j + 3)
            r *= T1.get(Dj, Fr(0))
            if r == 0:
                return r
        return r
    return val


def support_k(k):
    pos = [D for D, v in T1.items() if v > 0]
    for combo in itertools.product(pos, repeat=k):
        yield frozenset((x + 3 * j, y) for j, Dj in enumerate(combo) for x, y in Dj)


def law_three(free):
    """uniform law over g1, g2, g3 on inputs a,b,c (total functions as tuples)."""
    fa, fb, fc = free  # free coordinates: c of g1, a of g2, b of g3
    g1 = (0, 1, fc)
    g2 = (fa, 0, 1)
    g3 = (1, fb, 0)
    return [(g1, Fr(1, 3)), (g2, Fr(1, 3)), (g3, Fr(1, 3))]


def product_law(law1, k):
    out = []
    for combo in itertools.product(law1, repeat=k):
        g = tuple(v for gj, _ in combo for v in gj)
        p = Fr(1)
        for _, pj in combo:
            p *= pj
        out.append((g, p))
    return out


def contain(law, D):
    return sum(p for g, p in law if all(g[x] == y for x, y in D))


def main():
    lines = []
    # (a)
    nu = {frozenset(): Fr(1), frozenset({(0, 0)}): Fr(1), frozenset({(1, 0)}): Fr(1)}
    val2 = lambda D: nu.get(D, Fr(0))
    n, bad = weak_violations(val2, [0, 1])
    mob = sum((-1) ** len(E) * val2(E) for E in partials([0, 1]))
    lines.append(f"(a) two-input example: {n} one-point inequalities, violations={bad}; Moebius sum at (empty,{{a,b}}) = {mob}")
    # (b)
    for k in (1, 2, 3):
        n, bad = weak_violations(tau_k(k), list(range(3 * k)))
        lines.append(f"(b) tau^(x){k}: {n} one-point inequalities checked, violations={bad}")
    # (c) k = 1, all free choices
    mins = set()
    for free in itertools.product(Y, repeat=3):
        law = law_three(free)
        r = min(contain(law, D) / T1[D] for D in T1 if T1[D] > 0)
        mins.add(r)
    lines.append(f"(c) k=1: min ratio over support for all 8 free choices: {sorted(mins)} (2/3 expected)")
    for k in (1, 2, 3, 4):
        law = product_law(law_three((0, 0, 0)), k)
        tv = tau_k(k)
        r = min(contain(law, D) / tv(D) for D in support_k(k))
        lines.append(f"(c) k={k}: product law min_D P(F>D)/tau(D) = {r} ; (2/3)^k = {Fr(2, 3) ** k} ; equal: {r == Fr(2, 3) ** k}")
    # (d)
    for k in (1, 2, 3, 4):
        Es = []
        for idx in itertools.product(range(3), repeat=k):
            Es.append(frozenset((x + 3 * j, y) for j, i in enumerate(idx) for x, y in E1[i]))
        tv = tau_k(k)
        ok_val = all(tv(E) == Fr(1, 2 ** k) for E in Es)

        def consistent(A, B):
            dA = dict(A)
            return all(dA.get(x, y) == y for x, y in B)
        incons = all(not consistent(A, B) for A, B in itertools.combinations(Es, 2))
        lines.append(f"(d) k={k}: {len(Es)} data sets E_i, all tau=2^-k: {ok_val}; pairwise inconsistent: {incons}")
    out = "\n".join(lines)
    print(out)
    with open(__file__.replace(".py", "_output.txt"), "w") as f:
        f.write(out + "\n")


if __name__ == "__main__":
    main()

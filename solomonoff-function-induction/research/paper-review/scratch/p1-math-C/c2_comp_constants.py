r"""c2 (reviewer p1-math-C): numerical checks of constants in comp.tex / app-comp.tex / ood.tex.

(a) thm:comp:circuitbayes explicit form: the largest L with L <= R(L) := 2E[(d+1)(5+2 log2(2d+4+L))+3]
    is at most 16 E (d+1) log2(2(E+1)(d+2)); the paper reports the largest ratio 10.85 at E~0.63, d=1.
(b) prop:comp:occam (a): (ln|H| + ln(1/delta))/eps with |H| < 2^{l+1}, eps = delta = 0.01, is <= 70 l + 531.
(c) prop:comp:occam (b): sum_{n=1}^{N} min(1, eps_n + (n+1)^-2) (step 1 counted as 1) <= 5.7 + ln|H|(1+ln N) + ln^2 N,
    with eps_n = ln(|H|(n+1)^2)/n and N = n_0 = ceil(ln|H| / p_min).
(d) rem:comp:uniformties: 1 + sum_{k=1}^{d-1} H_{C(d,k)} <= d + d^2 ln 2.
(e) thm:comp:timebounded(b): sum_j log2((1+eps_j)/(1-eps_j)) for eps_j = j^-2 (as printed) and (j+1)^-2.
(f) ex:ood:easyhard: K(ceil(log L)) <= log m + 2 log log m + c with m = ceil(log2 L); check against 2 log log L.
(g) rem:comp:constant: regret constant log(1/w_i) + (2^{n_A}-1) log|Y| with n_i = 2^{2^i} -- 'of order' vs 'at least'.
Deterministic.
"""
import math

OUT = []


def say(s=""):
    print(s)
    OUT.append(s)


def lstar(E, d):
    # largest L >= 0 with L <= R(L); R concave increasing, R(0) > 0
    R = lambda L: 2 * E * ((d + 1) * (5 + 2 * math.log2(2 * d + 4 + L)) + 3)
    lo, hi = 0.0, 1.0
    while hi <= R(hi):
        hi *= 2
    for _ in range(200):
        mid = (lo + hi) / 2
        if mid <= R(mid):
            lo = mid
        else:
            hi = mid
    return lo


def part_a():
    worst = (0, None, None)
    Es = [10 ** (k / 20) for k in range(-60, 101)]  # 1e-3 .. 1e5
    ds = sorted(set([1, 2, 3, 4, 5, 7, 10, 20, 50, 100, 300, 1000, 3000, 10000]))
    for E in Es:
        for d in ds:
            L = lstar(E, d)
            ratio = L / (E * (d + 1) * math.log2(2 * (E + 1) * (d + 2)))
            if ratio > worst[0]:
                worst = (ratio, E, d)
    say(f"(a) max L*/(E(d+1)log2(2(E+1)(d+2))) on grid = {worst[0]:.3f} at E={worst[1]:.3g}, d={worst[2]}  (paper: 10.85 < 16)")


def part_b():
    worst = -1e9
    for l in range(1, 10001):
        n = ((l + 1) * math.log(2) + math.log(100)) / 0.01
        worst = max(worst, n - (70 * l + 531))
    say(f"(b) max over l<=10000 of required samples - (70 l + 531) = {worst:.2f}  (<= 0 expected)")


def part_c():
    worst = -1e9
    arg = None
    for lnH in [0.7, 2, 5, 10, 30, 100, 300]:
        H = math.exp(lnH)
        for pmin in [0.5, 0.1, 1e-2, 1e-3, 1e-4]:
            N = math.ceil(lnH / pmin)
            s = 1.0  # step 1
            for n in range(1, N):
                eps = math.log(H * (n + 1) ** 2) / n
                s += min(1.0, eps + (n + 1) ** -2)
            s_tail = 1.0  # E[surviving bad] <= |H|(1-pmin)^N <= 1
            bound = 6.7 + lnH * (1 + math.log(N)) + math.log(N) ** 2
            slack = (s + s_tail) - bound
            if slack > worst:
                worst, arg = slack, (lnH, pmin, N)
    say(f"(c) max (computed mistake bound - 6.7 - ln|H|(1+ln N) - ln^2 N) = {worst:.3f} at (ln|H|, p_min, N)={arg}  (<= 0 expected)")


def part_d():
    worst = -1e9
    for d in range(2, 200):
        s = 1 + sum(sum(1 / j for j in range(1, math.comb(d, k) + 1)) if math.comb(d, k) < 10 ** 6
                    else (math.log(math.comb(d, k)) + 0.5772156649 + 1 / (2 * math.comb(d, k)))
                    for k in range(1, d))
        worst = max(worst, s - (d + d * d * math.log(2)))
    say(f"(d) max over d in 2..199 of [1 + sum H_C(d,k)] - (d + d^2 ln2) = {worst:.2f}  (<= 0 expected)")


def part_e():
    for name, eps in [("j^-2 (as printed)", lambda j: j ** -2.0), ("(j+1)^-2", lambda j: (j + 1) ** -2.0)]:
        total = 0.0
        for j in range(1, 100001):
            e = eps(j)
            if e >= 1:
                total = float("inf")
                break
            total += math.log2((1 + e) / (1 - e))
        say(f"(e) sum_j log2((1+eps_j)/(1-eps_j)) with eps_j = {name}: {total}")


def part_f():
    first = None
    for e in range(4, 400):
        L = 2.0 ** e
        m = math.ceil(math.log2(L))
        K_upper = math.log2(m) + 2 * math.log2(max(math.log2(m), 1))
        if K_upper <= 2 * math.log2(math.log2(L)) and first is None:
            first = e
    say(f"(f) log m + 2 log log m <= 2 log log L (m = ceil(log L)) first holds at L = 2^{first} (constant c ignored); 'for large L' is correct")


def part_g():
    for i in (1, 2, 3):
        n_i = 2 ** (2 ** i)
        say(f"(g) i={i}: n_i={n_i}; (2^n_i - 1) log|Y| with |Y|=2 is {2 ** n_i - 1} = 2^{n_i} - 1 ; n_A >= n_i, and n_A can exceed n_i when c_A is large -> 'at least', not 'of order'")


if __name__ == "__main__":
    part_a()
    part_b()
    part_c()
    part_d()
    part_e()
    part_f()
    part_g()
    with open(__file__.replace(".py", ".out.txt"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")

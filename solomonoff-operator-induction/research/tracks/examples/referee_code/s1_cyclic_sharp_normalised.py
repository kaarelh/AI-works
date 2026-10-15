"""s1 (referee, run 2): independent checks for the cyclic-permutation example (H5).

Written from scratch; it does not import the track's code.

(a) Exhaustive hypothesis-side counts for n = 2, 3 (N = 4, 8):
    * uniform cyclic law:   nu(D_k) = 1/(N-1)_k          (track Thm 2.3(1), first term)
    * broom law B_k:        nu(D_k) = 1/(N-1)_{k-1}      (referee: sharper upper bound)
    * partial chain PC_j:   nu(D_m) = 1/(N-1)_m (m <= j), and its mass defined at x_{m+1}
    computed by enumerating every cyclic permutation / every injective sequence and
    testing containment directly, for random orderings.
(b) Depth-count lemma |A_k(F)| <= N - k: random search over partial functions on
    {0,1}^n (n = 3, 4), plus the broom attaining N - k.
(c) Normalised versus semimeasure loss of an explicit order-free proxy mixture that
    contains total laws (cyclic, uniform permutation, uniform function, brooms) and
    partial laws (partial chains).  The losses depend only on k, by symmetry, so they
    are exact.  Compared with the referee's lower bound for the normalised predictor:
    per-step loss >= log2(N-t+1) + log2(w_broom(t-1)).
(d) Track bounds vs sharpened bounds at n = 64 (constants c omitted), and the answer
    to the track's open problem 3.
(e) Stirling/Robbins constants of Thm 2.1(4) at 120 digits (mpmath), and the e3 remark
    "the Stirling error equals 1/(12 N ln 2) to the printed precision for n <= 24".

Seed 20261012.  Output: s1_cyclic_sharp_normalised_output.txt (next to this file).
"""
import itertools
import math
import os
import random

import mpmath

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []


def say(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


def falling(a, k):
    r = 1
    for i in range(k):
        r *= (a - i)
    return r


def lg(x):
    return math.log2(x)


def lfall(a, k):
    """log2 of the falling factorial (a)_k, exact via lgamma."""
    return (math.lgamma(a + 1) - math.lgamma(a - k + 1)) / math.log(2)


# ---------------------------------------------------------------- (a)
def chain_data(order, k):
    """D_k for the ordering x_1..x_{N-1} (x_0 = 0): pairs (x_i, x_{i-1})."""
    xs = [0] + list(order)
    return [(xs[i], xs[i - 1]) for i in range(1, k + 1)]


def all_cyclic(N):
    out = []
    for perm in itertools.permutations(range(N)):
        x, L = 0, 0
        while True:
            x = perm[x]
            L += 1
            if x == 0:
                break
        if L == N:
            out.append(perm)
    return out


def broom_fn(v, N):
    """Broom with spine v = (v_1..v_{j-1}); returns a dict x -> label for all x."""
    f = {}
    last = v[-1] if v else 0
    for x in range(N):
        f[x] = last
    if v:
        f[v[0]] = 0
        for i in range(1, len(v)):
            f[v[i]] = v[i - 1]
    return f


def part_a(rng):
    say("(a) exhaustive hypothesis-side counts")
    for n in [2, 3]:
        N = 2 ** n
        cyc = all_cyclic(N)
        nonzero = list(range(1, N))
        orders = [tuple(rng.sample(nonzero, N - 1)) for _ in range(3)]
        ok_cyc = ok_broom = ok_pc = True
        for order in orders:
            for k in range(1, N):
                D = chain_data(order, k)
                # cyclic law
                cnt = sum(all(p[x] == y for x, y in D) for p in cyc)
                if cnt * falling(N - 1, k) != len(cyc):
                    ok_cyc = False
                # broom B_k: spine of length k-1, uniform over injective sequences
                tot = good = 0
                for v in itertools.permutations(nonzero, k - 1):
                    f = broom_fn(v, N)
                    tot += 1
                    good += all(f[x] == y for x, y in D)
                if good * falling(N - 1, k - 1) != tot:
                    ok_broom = False
                # partial chain PC_j for j = k..N-1: nu(D_k) and mass defined at x_{k+1}
                if k < N - 1:
                    for j in range(k, N):
                        tot = good = defd = 0
                        for v in itertools.permutations(nonzero, j):
                            f = {v[0]: 0}
                            for i in range(1, j):
                                f[v[i]] = v[i - 1]
                            tot += 1
                            if all(f.get(x) == y for x, y in D):
                                good += 1
                                if order[k] in f:      # x_{k+1}
                                    defd += 1
                        want_good = 1 / falling(N - 1, k)
                        want_def = want_good * (j - k) / (N - 1 - k)
                        if abs(good / tot - want_good) > 1e-12 or abs(defd / tot - want_def) > 1e-12:
                            ok_pc = False
        say(f"    n={n}: cyclic 1/(N-1)_k: {ok_cyc};  broom 1/(N-1)_(k-1): {ok_broom};  "
            f"partial chain formulas: {ok_pc}   (3 random orderings, all k)")


# ---------------------------------------------------------------- (b)
def depth_set(F, N, k):
    """A_k(F): nonzero x whose orbit stays in nonzero strings for k-1 steps and hits 0 at step k."""
    A = 0
    for x in range(1, N):
        y, ok = x, True
        for step in range(1, k + 1):
            if y not in F:
                ok = False
                break
            y = F[y]
            if step < k and y == 0:
                ok = False
                break
        if ok and y == 0:
            A += 1
    return A


def part_b(rng):
    say("")
    say("(b) depth-count lemma |A_k(F)| <= N-k (random partial functions; broom attains N-k)")
    for n in [3, 4]:
        N = 2 ** n
        worst = 0
        trials = 20000 if n == 3 else 6000
        for _ in range(trials):
            F = {}
            for x in range(N):
                r = rng.random()
                if r < 0.15:
                    continue                       # undefined
                elif r < 0.45:
                    F[x] = 0
                else:
                    F[x] = rng.randrange(N)
            for k in range(1, N):
                a = depth_set(F, N, k)
                worst = max(worst, a - (N - k))
        att = all(depth_set(broom_fn(tuple(range(1, k)), N), N, k) == N - k for k in range(1, N))
        say(f"    n={n}: max over {trials} random partial F and all k of |A_k| - (N-k) = {worst} (claim <= 0); "
            f"broom attains N-k for every k: {att}")


# ---------------------------------------------------------------- (c)
def proxy_losses(n, w, fam_weight_fn):
    """Exact semimeasure and normalised per-step losses of the proxy mixture on the chain.

    Components (all laws of random partial functions on {0,1}^n):
      cyc   : uniform cyclic permutation                       (total)
      perm  : uniform permutation                              (total)
      func  : uniform function                                 (total)
      B_j   : broom with spine length j-1, j = 1..N            (total)
      PC_j  : partial chain on v_1..v_j, j = 1..N-1            (partial)
    w = dict of family weights; fam_weight_fn(j) = within-family prior on j.
    Returns lists sm[t], nm[t] (per-step losses, t = 1..N) and S_broom_lb[t].
    """
    N = 2 ** n
    lf = lambda k: lfall(N - 1, k)

    def comps(m):
        """log2 nu_c(D_m) for each component c, m = 0..N; and log2 of the mass
        defined at x_{m+1} given D_m (m = 0..N-1)."""
        out_nu, out_def = [], []
        # cyc
        nu = -lf(min(m, N - 1))
        out_nu.append(lg(w['cyc']) + nu)
        out_def.append(lg(w['cyc']) + nu)
        # perm
        nu = -lfall(N, m)
        out_nu.append(lg(w['perm']) + nu)
        out_def.append(lg(w['perm']) + nu)
        # func
        nu = -n * m
        out_nu.append(lg(w['func']) + nu)
        out_def.append(lg(w['func']) + nu)
        # brooms
        for j in range(1, N + 1):
            if m <= j - 1:
                nu = -lf(m)
            elif m == j:
                nu = -lf(j - 1)
            else:
                nu = -math.inf
            lw = lg(w['broom']) + lg(fam_weight_fn(j))
            out_nu.append(lw + nu)
            out_def.append(lw + nu)
        # partial chains
        for j in range(1, N):
            lw = lg(w['pc']) + lg(fam_weight_fn(j))
            if m <= j:
                nu = -lf(m)
                out_nu.append(lw + nu)
                if m < j and m < N - 1:
                    out_def.append(lw + nu + lg((j - m) / (N - 1 - m)))
                else:
                    out_def.append(-math.inf)
            else:
                out_nu.append(-math.inf)
                out_def.append(-math.inf)
        return out_nu, out_def

    def lse(xs):
        xs = [x for x in xs if x > -math.inf]
        if not xs:
            return -math.inf
        mx = max(xs)
        return mx + lg(sum(2 ** (x - mx) for x in xs))

    lognu = []
    logdef = []
    for m in range(0, N + 1):
        a, b = comps(m)
        lognu.append(lse(a))
        logdef.append(lse(b))
    sm, nm, lb = [], [], []
    for t in range(1, N + 1):
        sm.append(lognu[t - 1] - lognu[t])               # -log2 nu(D_t)/nu(D_{t-1})
        nm.append(logdef[t - 1] - lognu[t])              # -log2 nu(D_t)/S_t
        if 2 <= t <= N - 1:
            lb.append(lg(N - t + 1) + lg(w['broom']) + lg(fam_weight_fn(t - 1)))
        else:
            lb.append(0.0)
    return sm, nm, lb, lognu


def part_c():
    say("")
    say("(c) normalised vs semimeasure loss of an order-free proxy mixture on the chain")
    say("    families: cyc, perm, func (total); brooms B_j (total); partial chains PC_j (partial);")
    say("    within-family prior pi(j) = 1/(j(j+1)).  'LB' = referee lower bound on the normalised loss,")
    say("    sum_{t=2}^{k} [log2(N-t+1) + log2(w_broom pi(t-1))]; it must be <= the normalised loss.")
    pi = lambda j: 1.0 / (j * (j + 1))
    settings = [
        ("balanced  ", dict(cyc=0.2, perm=0.1, func=0.1, broom=0.3, pc=0.3)),
        ("partial-heavy", dict(cyc=0.01, perm=0.01, func=0.01, broom=0.01, pc=0.96)),
    ]
    for name, w in settings:
        say(f"  proxy '{name}': weights {w}")
        say("      n     k | semimeasure  normalised    LB(norm)   log2(N-1)_(k-1)   log2(N-1)_k | norm/k  sm/k")
        for n in [4, 6, 8, 10, 12]:
            N = 2 ** n
            sm, nm, lb, lognu = proxy_losses(n, w, pi)
            ks = sorted(set([n, int(round(math.sqrt(N))), N // 4, N // 2, N - 1, N]))
            for k in ks:
                S = sum(sm[:k])
                Nn = sum(nm[:k])
                LB = sum(lb[:k])
                ok = "" if Nn >= LB - 1e-9 else "  VIOLATION"
                say(f"    {n:3d} {k:5d} | {S:11.3f} {Nn:11.3f} {LB:11.3f} {lfall(N-1, k-1):15.3f} "
                    f"{lfall(N-1, min(k, N-1)):13.3f} | {Nn/k:6.3f} {S/k:6.3f}{ok}")
            # per-step check of the referee bound
            viol = [t for t in range(2, N) if nm[t - 1] < lb[t - 1] - 1e-9]
            say(f"          n={n}: per-step normalised loss >= referee per-step bound at all t=2..N-1: {not viol}")


# ---------------------------------------------------------------- (d)
def Kint(i):
    """A standard upper bound proxy for K(i): log2(i+1) + 2 log2 log2(i+2) (constants omitted)."""
    return lg(i + 1) + 2 * lg(lg(i + 2))


def part_d():
    say("")
    say("(d) n = 64: track bounds vs sharpened bounds on L_SFI(D_k) (all additive constants c omitted)")
    n = 64
    N = 2 ** n
    say("    All bounds are log2(N-1)_k minus an offset; offsets are computed exactly (no large-float differences).")
    say("        k  | log2(N-1)_k | track: upper off  lower off  gap | referee: upper off  lower off  gap")
    for k in [1, 2, 8, 64, 1000, 2 ** 20, 2 ** 40, 2 ** 63]:
        mpmath.mp.dps = 80
        lfk = float((mpmath.loggamma(N) - mpmath.loggamma(N - k)) / mpmath.log(2))   # log2 (N-1)_k, exact enough
        t_up = max(0.0, lg(N - k) - k)                    # track upper = lfk - t_up
        t_lo = lg(N - 1)                                  # track lower = lfk - t_lo
        r_up = lg(N - k) - min(Kint(k), lg(N - k), k)     # referee upper = lfk - r_up
        r_lo = lg(N - k)                                  # referee lower = lfk - r_lo
        say(f"    {k:>19d} | {lfk:11.4g} | {t_up:9.3f} {t_lo:9.3f} {t_lo - t_up:7.3f} | "
            f"{r_up:9.3f} {r_lo:9.3f} {r_lo - r_up:7.3f}")
    say("    (open problem 3 asks whether L(D_k) = log2(N-1)_k + O(1) w.h.p. once k >= n; the referee upper offset is a")
    say("     lower bound, up to c, on log2(N-1)_k - L(D_k), and it grows like n - K(k).)")


# ---------------------------------------------------------------- (e)
def part_e():
    say("")
    say("(e) Thm 2.1(4): log2((N-1)!) - [(n - log2 e)N - n/2 + log2(2 pi)/2] at 120 digits")
    mpmath.mp.dps = 120
    say("     n |  error eps_N (true)        1/(12 N ln2)          1/((12N+1) ln2)   | Robbins window holds | e3 printed")
    e3_printed = {1: 5.964e-02, 2: 2.999e-02, 10: 1.174e-04, 17: 9.171e-07, 18: 4.591e-07, 19: 2.291e-07, 20: 1.155e-07, 24: 5.960e-08}
    allok = True
    for n in list(range(1, 25)) + [32, 40, 64]:
        N = mpmath.mpf(2) ** n
        exact = mpmath.loggamma(N) / mpmath.log(2)
        stir = (n - mpmath.log(mpmath.e, 2)) * N - mpmath.mpf(n) / 2 + mpmath.log(2 * mpmath.pi, 2) / 2
        eps = exact - stir
        up = 1 / (12 * N * mpmath.log(2))
        lo = 1 / ((12 * N + 1) * mpmath.log(2))
        ok = lo < eps < up
        allok &= ok
        if n in (1, 2, 3, 10, 16, 17, 18, 19, 20, 24, 32, 40, 64):
            pr = e3_printed.get(n)
            say(f"   {n:3d} | {mpmath.nstr(eps, 12):>22s} {mpmath.nstr(up, 12):>20s} {mpmath.nstr(lo, 12):>20s} | "
                f"{str(ok):>5s} | {'' if pr is None else f'{pr:.3e}'}")
    say(f"    Robbins window lo < eps < up holds for all n tested: {allok}")


def main():
    rng = random.Random(20261012)
    say("s1_cyclic_sharp_normalised.py  (referee, run 2; seed 20261012)")
    part_a(rng)
    part_b(rng)
    part_c()
    part_d()
    part_e()
    with open(os.path.join(HERE, "s1_cyclic_sharp_normalised_output.txt"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()

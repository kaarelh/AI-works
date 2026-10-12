"""r5 (referee): numeric checks of constants in the context notes and in the Vaintrob-Hanni slides.

  (1) Prop 2.12(1),(3): (1-2^-l)^m >= 1/2 and (1/2) 2^{-l-2 log2(l+1)} >= 1/(8 m (log2 m + 3)^2), l = ceil(log2 m)+1,
      for m = 1..10^6.
  (2) Prop 2.13(2): max_delta delta (1-delta)^m <= 1/(m+1).
  (3) Prop 3.8: (ln 2^(l+1) + ln 100)/0.01 <= 70 l + 531 for l = 0..10^4.
  (4) Prop 3.9: the first-N-steps sum 1 + sum_{n<N} [(H + 2 ln(n+1))/n + (n+1)^-2] <= 5.7 + H(1+ln N) + ln^2 N,
      on a grid of H = ln|H_f| and N; plus a seeded Monte Carlo of Occam learning on a toy class
      (all 2^6 functions on 6 points, random priority order, non-uniform mu), expected mistakes vs the bound.
  (5) Slides, warm-up: 3 (2/3)^(3C+26) < 3^-C / 2000 for all C >= 0, and 2^(3C+26) e^(-n/2000) = e^-C at
      n = 2000((3C+26) ln 2 + C); Appendix A: at eps = eta = T = 1/2000, delta = 1/(2000 M), the union-bound
      and Markov requirements each hold at n = 4000 (ln M + 4).
  (6) Prop 4.5 by brute force: uniform circuits of size exactly S (all 16 gates), fraction computing f
      >= 1 / (N_c(f) * 16 (d+1+S)^2), for (d,S) = (1,2), (1,3), (2,2), (3,2).
  (7) Thm 3.5(b) "solves to L = O(m d log(md+2))": largest L with L <= 2m[(d+1)(5+2 log2(2d+4+L))+3],
      divided by m d log2(md+2), maximised over m in [0.5, 10^4], d in [1, 10^3].
Seeded (seed 5) where random.
"""
import math
import itertools
import numpy as np

rng = np.random.default_rng(5)
out = []

# (1)
ok1a = ok1b = True
worst = 1e9
for m in range(1, 10 ** 6 + 1):
    l = math.ceil(math.log2(m)) + 1
    if (1 - 2.0 ** -l) ** m < 0.5:
        ok1a = False
    lhs = 0.5 * 2.0 ** (-l - 2 * math.log2(l + 1))
    rhs = 1 / (8 * m * (math.log2(m) + 3) ** 2)
    worst = min(worst, lhs / rhs)
    if lhs < rhs * (1 - 1e-12):
        ok1b = False
out.append(f"(1) Prop 2.12: (1-2^-l)^m >= 1/2 for m<=1e6: {ok1a}; constant inequality: {ok1b} (min lhs/rhs = {worst:.3f})")

# (2)
ok2 = True
for m in [1, 2, 5, 10, 100, 1000, 10 ** 5]:
    dl = np.linspace(0, 1, 200001)
    mx = np.max(dl * (1 - dl) ** m)
    ok2 &= mx <= 1 / (m + 1) + 1e-12
out.append(f"(2) Prop 2.13: max delta(1-delta)^m <= 1/(m+1): {ok2}")

# (3)
ok3 = all((math.log(2.0) * (l + 1) + math.log(100)) / 0.01 <= 70 * l + 531 for l in range(0, 10 ** 4 + 1))
out.append(f"(3) Prop 3.8: (ln 2^(l+1) + ln 100)/0.01 <= 70 l + 531 for l in [0,1e4]: {ok3}")

# (4) analytic sum
ok4 = True
worst4 = -1e9
for H in [0.0, 0.5, 1, 2, 5, 10, 50, 200, 1000]:
    for N in [1, 2, 3, 5, 10, 30, 100, 1000, 10 ** 4, 10 ** 5]:
        s = 1.0 + sum((H + 2 * math.log(n + 1)) / n + (n + 1) ** -2 for n in range(1, N))
        bound = 5.7 + H * (1 + math.log(N)) + math.log(N) ** 2
        worst4 = max(worst4, s - bound)
        ok4 &= s <= bound + 1e-12
out.append(f"(4a) Prop 3.9 first-N-steps sum <= 5.7 + H(1+ln N) + ln^2 N on the grid: {ok4} (max excess {worst4:.3f})")

# (4b) Monte Carlo Occam on a toy class
Mpts = 6
allf = np.array(list(itertools.product([0, 1], repeat=Mpts)))  # 64 functions
prio = rng.permutation(len(allf))  # Occam order: prio rank
mu = rng.dirichlet(np.ones(Mpts) * 0.5)
pmin = mu.min()
res = []
for trial_f in range(5):
    f_idx = int(rng.integers(len(allf)))
    f = allf[f_idx]
    rank_f = int(np.where(prio == f_idx)[0][0])
    Hf = prio[: rank_f + 1]  # hypotheses preceding or equal to f
    Hsize = len(Hf)
    N = math.ceil(math.log(Hsize) / pmin) if Hsize > 1 else 1
    bound = 6.7 + math.log(Hsize) * (1 + math.log(max(N, 1))) + math.log(max(N, 1)) ** 2
    T = 3000
    runs = 400
    tot = 0
    for r in range(runs):
        alive = np.ones(len(allf), bool)
        xs = rng.choice(Mpts, size=T, p=mu)
        mist = 0
        for x in xs:
            # Occam hypothesis: first alive in priority order
            h = next(int(i) for i in prio if alive[i])
            if allf[h][x] != f[x]:
                mist += 1
            alive &= allf[:, x] == f[x]
        tot += mist
    res.append((Hsize, round(pmin, 4), tot / runs, round(bound, 1)))
out.append("(4b) Occam Monte Carlo (|H_f|, p_min, mean mistakes over 400 runs of 3000 steps, Prop 3.9 bound): "
           + "; ".join(str(r) for r in res) + f"; all below bound: {all(r[2] <= r[3] for r in res)}")

# (5) slides warm-up
ok5a = all(math.log(3) + (3 * C + 26) * math.log(2 / 3) < -C * math.log(3) - math.log(2000) for C in range(0, 2000))  # log space
ok5b = all(abs(((3 * C + 26) * math.log(2) - (2000 * ((3 * C + 26) * math.log(2) + C)) / 2000) + C) < 1e-9
           for C in range(0, 200))
ok5c = all(M * math.exp(-0.0005 * 4000 * (math.log(M) + 4)) <= 1 / (2000 * M) and
           (1 / 2000) * math.exp(-0.0005 * 4000 * (math.log(M) + 4)) / (1 / (2000 * M)) <= 1 / 2000
           for M in [1, 2, 10, 10 ** 3, 10 ** 6, 10 ** 12])
out.append(f"(5) slides warm-up tail inequality for C in [0,2000): {ok5a}; union-bound exponent identity: {ok5b}; "
           f"Appendix A parameters at n = 4000(ln M + 4): {ok5c}")

# (6) Prop 4.5 brute force (truth tables as ints; gate g(a,b) = bit (2a+b) of g)
def enum_circuits(d, S):
    NP = 1 << d
    FULL = (1 << NP) - 1
    X = [sum(1 << i for i in range(NP) if (i >> j) & 1) for j in range(d)]
    base = X + [0, FULL]
    cache = {}

    def gate(g, u, v):
        key = (g, u, v)
        r = cache.get(key)
        if r is None:
            r = 0
            for a in (0, 1):
                for b in (0, 1):
                    if (g >> (2 * a + b)) & 1:
                        r |= (u if a else FULL ^ u) & (v if b else FULL ^ v)
            cache[key] = r
        return r

    counts = {}

    def rec(sigs, j):
        n = len(sigs)
        if j == S:  # last gate: count outputs directly
            for g in range(16):
                for u in sigs:
                    for v in sigs:
                        t = gate(g, u, v)
                        counts[t] = counts.get(t, 0) + 1
            return
        for g in range(16):
            for u in sigs:
                for v in sigs:
                    rec(sigs + [gate(g, u, v)], j + 1)

    rec(base, 1)
    return counts


def Nsz(d, s):
    return math.prod(16 * (d + 1 + j) ** 2 for j in range(1, s + 1))


for d, S in [(1, 2), (2, 2), (3, 2), (1, 3)]:
    if Nsz(d, S) > 2 * 10 ** 7:
        continue
    cnt1 = enum_circuits(d, 1)
    cntS = enum_circuits(d, S)
    tot = sum(cntS.values())
    assert tot == Nsz(d, S)
    ok = True
    worst = 1e9
    for f in cnt1:  # functions with c(f) = 1
        frac = cntS.get(f, 0) / tot
        lb = 1 / (Nsz(d, 1) * 16 * (d + 1 + S) ** 2)
        worst = min(worst, frac / lb)
        ok &= frac >= lb
    out.append(f"(6) Prop 4.5 d={d} S={S}: N_S={tot}; for all {len(cnt1)} functions with c(f)=1, "
               f"P_unif,S(f) >= 1/(N_1*16(d+1+S)^2): {ok} (min ratio {worst:.1f})")

# (7)
worst7 = 0
for d in [1, 2, 3, 5, 10, 30, 100, 1000]:
    for m in [0.5, 1, 2, 5, 10, 100, 1000, 10 ** 4]:
        # largest L with L <= 2m[(d+1)(5 + 2 log2(2d+4+L)) + 3]: iterate to the fixed point
        L = 1.0
        for _ in range(200):
            L = 2 * m * ((d + 1) * (5 + 2 * math.log2(2 * d + 4 + L)) + 3)
        worst7 = max(worst7, L / (m * d * math.log2(m * d + 2)))
out.append(f"(7) Thm 3.5: max over the grid of L_max / (m d log2(md+2)) = {worst7:.1f}  (an explicit constant for the O())")

txt = "\n".join(out)
print(txt)
with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write(txt + "\n")

"""r12 (referee, second pass): Thm 6.7(a) bounds the Cesaro-averaged predictor; what about the
posterior predictive itself (the "last iterate")?

Finite analogue of Thm 6.7(a): X = {0,...,m-1}, Y = {0,1}, the class of all 2^m Boolean
functions with positive prior weights w_g (sum 1), a target phi in the class, K := -log2 w_phi,
and i.i.d. inputs from pi.  Q_t is the Bayes posterior predictive after t samples; it depends
only on the set S_t of distinct inputs seen.  Exactly (inclusion-exclusion over subsets):
    P(S_t = S) = sum_{T subset S} (-1)^{|S|-|T|} pi(T)^t,
    r_t := E R(Q_t) = sum_S P(S_t = S) R(Q_S),   R(Q) = E_{x~pi}[-log2 Q(phi(x)|x)].
Checks:
 (1) sum_{t<n} r_t <= K for all n (Thm 6.1(b)/6.7(a) cumulative bound);
 (2) E R(Q_bar_n) <= K/n for the averaged predictor (exact enumeration of input sequences,
     small m and n only);
 (3) whether t -> r_t is monotone, and the largest observed (n+1) r_n / K, i.e. whether the
     last-iterate analogue "E R(Q_n) <= K/(n+1)" ever fails on the instances tried.
Instances: one hand-built example where seeing a frequent input makes predictions at a rare
input worse, and 300 seeded random instances (m = 3..5).

Seed 20261012.  Output: r12_last_iterate_risk_output.txt
"""
import itertools
import math
import random


def instance_stats(m, w, pi, phi, T=200):
    funcs = list(itertools.product((0, 1), repeat=m))
    K = -math.log2(w[funcs.index(phi)])
    subsets = list(range(1 << m))

    def RQ(S):
        cons = [i for i, g in enumerate(funcs) if all(g[x] == phi[x] for x in range(m) if S >> x & 1)]
        Z = sum(w[i] for i in cons)
        r = 0.0
        for x in range(m):
            q = sum(w[i] for i in cons if funcs[i][x] == phi[x]) / Z
            r += pi[x] * (-math.log2(q))
        return r

    R = [RQ(S) for S in subsets]
    piT = [sum(pi[x] for x in range(m) if T_ >> x & 1) for T_ in subsets]

    def PS(S, t):
        tot = 0.0
        T_ = S
        while True:
            sign = -1 if (bin(S).count("1") - bin(T_).count("1")) % 2 else 1
            tot += sign * piT[T_] ** t
            if T_ == 0:
                break
            T_ = (T_ - 1) & S
        return tot

    r = [sum(PS(S, t) * R[S] for S in subsets) for t in range(T + 1)]
    return K, r, funcs


def averaged_risk(m, w, pi, phi, n, funcs):
    """E R(Q_bar_n) by enumerating all input sequences of length n-1 (Q_0..Q_{n-1})."""
    tot = 0.0
    for seq in itertools.product(range(m), repeat=n - 1):
        p = 1.0
        for x in seq:
            p *= pi[x]
        preds = []
        S = 0
        for t in range(n):
            cons = [i for i, g in enumerate(funcs) if all(g[x] == phi[x] for x in range(m) if S >> x & 1)]
            Z = sum(w[i] for i in cons)
            preds.append([sum(w[i] for i in cons if funcs[i][x] == phi[x]) / Z for x in range(m)])
            if t < n - 1:
                S |= 1 << seq[t]
        risk = sum(pi[x] * -math.log2(sum(pr[x] for pr in preds) / n) for x in range(m))
        tot += p * risk
    return tot


def main():
    out = []
    # hand-built: inputs a=0 (frequent), b=1 (rare); phi = (0,0)
    # g=(1,0): wrong at a, right at b, heavy; g=(0,1): right at a, wrong at b; phi light.
    m = 2
    funcs = list(itertools.product((0, 1), repeat=m))
    wd = {(0, 0): 0.01, (1, 0): 0.90, (0, 1): 0.08, (1, 1): 0.01}
    w = [wd[g] for g in funcs]
    pi = [0.95, 0.05]
    K, r, _ = instance_stats(m, w, pi, (0, 0), T=200)
    incr = [t for t in range(200) if r[t + 1] > r[t] + 1e-15]
    cum = [sum(r[:n]) for n in range(1, 201)]
    out.append(f"hand-built: K={K:.4f}; r_0..r_5 = " + ", ".join(f"{x:.4f}" for x in r[:6]))
    out.append(f"   t with r_(t+1) > r_t: {incr[:10]}{' ...' if len(incr) > 10 else ''} (count {len(incr)})")
    out.append(f"   max_n sum_(t<n) r_t = {max(cum):.4f} <= K: {max(cum) <= K + 1e-9}")
    out.append(f"   max_n (n+1) r_n / K = {max((n + 1) * r[n] / K for n in range(200)):.4f}")
    for n in (1, 2, 3, 4, 6, 8):
        a = averaged_risk(m, w, pi, (0, 0), n, funcs)
        out.append(f"   n={n}: E R(Q_bar_n)={a:.4f}  K/n={K / n:.4f}  ok={a <= K / n + 1e-12}  "
                   f"last iterate E R(Q_(n-1))={r[n - 1]:.4f}")
    rng = random.Random(20261012)
    worst_ratio = 0.0
    worst_desc = ""
    nonmono = 0
    cum_ok = True
    avg_ok = True
    trials = 300
    for trial in range(trials):
        m = rng.choice((3, 4, 5))
        funcs = list(itertools.product((0, 1), repeat=m))
        raw = [rng.random() ** 4 + 1e-6 for _ in funcs]
        Z = sum(raw)
        w = [x / Z for x in raw]
        rp = [rng.random() ** 3 + 1e-3 for _ in range(m)]
        Zp = sum(rp)
        pi = [x / Zp for x in rp]
        phi = funcs[rng.randrange(len(funcs))]
        K, r, funcs = instance_stats(m, w, pi, phi, T=150)
        if any(r[t + 1] > r[t] + 1e-12 for t in range(150)):
            nonmono += 1
        if max(sum(r[:n]) for n in range(1, 151)) > K + 1e-9:
            cum_ok = False
        ratio = max((n + 1) * r[n] / K for n in range(150))
        if ratio > worst_ratio:
            worst_ratio = ratio
            worst_desc = f"trial {trial}, m={m}, K={K:.3f}"
        if trial < 40 and m <= 4:
            for n in (2, 3, 5):
                if averaged_risk(m, w, pi, phi, n, funcs) > K / n + 1e-12:
                    avg_ok = False
    out.append(f"random instances: {trials}; cumulative bound sum_(t<n) r_t <= K in all: {cum_ok}")
    out.append(f"   averaged-predictor bound E R(Q_bar_n) <= K/n (n=2,3,5; small instances): {avg_ok}")
    out.append(f"   instances with r_t non-monotone in t: {nonmono}/{trials}")
    out.append(f"   largest (n+1) r_n / K observed: {worst_ratio:.4f} ({worst_desc})")
    text = "\n".join(out) + "\n"
    print(text, end="")
    with open(__file__.replace(".py", "_output.txt"), "w") as f:
        f.write(text)


if __name__ == "__main__":
    main()

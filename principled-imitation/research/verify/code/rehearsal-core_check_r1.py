#!/usr/bin/env python3
"""Referee's exact check of Theorem 5.1 (R1), Lemma 4.3 and Proposition 5.2 of
research/prove-c/rehearsal-core.md, written independently of the prover's scripts.

Protocol R is enumerated exactly (every data history, every run of the mixture, every index J,
every answer of the human) on a scaffold of horizon L = 3 chosen to exercise the edge cases:
  * runs with no calls (z = 2), runs of length 1, 2 and 3;
  * inputs that depend on the answers, including on the answer "no answer" (bottom) that a
    mixture of semimeasures can give;
  * a repeated input inside one run;
  * hypotheses that are semimeasures, total weight W < 1.
Checked:
  (a)  sum_t E[Lambda(M^(t))] = L * sum_t E[a_t kappa_t] <= L ln(W/w(P));
  (b)  sum_t E[chi(M^(t))] <= (L/2) ln(W/w(P));
  (c)  deterministic human: max over paths of sum_{asked} e_t <= ln(W/w(f)); sum_t E[beta] <= L ln(W/w(f));
  4.3  exact probability that the predictable sums exceed their bounds, for several delta;
  5.2(a) the average over rounds;  9.1(a) E beta(M^(T)) <= sqrt(lbar L ln(W/w)/(2n)).
Then (separately) an example showing that the bound of Theorem 5.1(c) for beta, L ln(1/w(f)), is
approached (the two-function example of 5.1(d) only gives L (1 - w)).
"""
import itertools
from math import log, sqrt, exp

BOT = 2            # the answer "no answer"
YB = (0, 1, BOT)   # Y_bottom
L = 3
D0 = {0: 0.5, 1: 0.3, 2: 0.2}


def next_input(z, ys):
    """The scaffold.  Returns the input of call len(ys)+1, or None for STOP."""
    j = len(ys) + 1
    if j > L or z == 2:
        return None
    if z == 0:
        if j == 1:
            return 0
        if j == 2:
            if ys[0] == 0:
                return None
            return 1 if ys[0] == 1 else 3
        if j == 3:
            if ys[0] == BOT:
                return None
            return 1 if ys[1] == BOT else 2 + ys[1]     # a repeated input when y_2 = bottom
    if z == 1:
        if j == 1:
            return 2
        if j == 2:
            return 0
        if j == 3:
            return None if ys[1] == 0 else 3
    return None


def runs_of(kernel):
    """All runs of the scaffold answered by the kernel: list of (prob, z, inputs, answers)."""
    out = []
    for z, pz in D0.items():
        stack = [(pz, ())]
        while stack:
            pr, ys = stack.pop()
            x = next_input(z, ys)
            if x is None:
                xs = tuple(next_input(z, ys[:i]) for i in range(len(ys)))
                out.append((pr, z, xs, ys))
                continue
            for y in YB:
                py = kernel[x][y]
                if py > 0:
                    stack.append((pr * py, ys + (y,)))
    return out


def completed(nu):
    """A hypothesis given as {x: (nu(0|x), nu(1|x))} becomes a kernel on Y_bottom."""
    return {x: (a, b, max(0.0, 1.0 - a - b)) for x, (a, b) in nu.items()}


def mixture(hyps, weights, data):
    """Posterior weights and the mixture kernel given a tuple of pairs (x, y), y in {0,1}."""
    lik = []
    for h in hyps:
        l = 1.0
        for x, y in data:
            l *= h[x][y]
        lik.append(l)
    xi = sum(w * l for w, l in zip(weights, lik))
    post = [w * l / xi for w, l in zip(weights, lik)]
    M = {}
    for x in range(4):
        a = sum(p * h[x][0] for p, h in zip(post, hyps))
        b = sum(p * h[x][1] for p, h in zip(post, hyps))
        M[x] = (a, b, max(0.0, 1.0 - a - b))
    return post, M


def kl(p, q):
    s = 0.0
    for a, b in zip(p, q):
        if a > 0:
            if b <= 0:
                return float('inf')
            s += a * log(a / b)
    return s


def tv(p, q):
    return 0.5 * sum(abs(a - b) for a, b in zip(p, q))


def h2(p, q):
    return 1.0 - sum(sqrt(a * b) for a, b in zip(p, q))


def enumerate_protocol(hyps, weights, P, n, deterministic):
    """Exact enumeration of Protocol R.  Returns the sums of the expectations and, for the
    high-probability forms, the list of (probability, predictable sum of beta/L, predictable sum of chi/L)."""
    W = sum(weights)
    cache = {}

    def info(data):
        key = tuple(sorted(data))
        if key not in cache:
            post, M = mixture(hyps, weights, key)
            rs = runs_of(M)
            Lam = sum(pr * sum(kl(P[x], M[x]) for x in xs) for pr, z, xs, ys in rs)
            chi = sum(pr * sum(h2(P[x], M[x]) for x in xs) for pr, z, xs, ys in rs)
            bet = sum(pr * sum(tv(P[x], M[x]) for x in xs) for pr, z, xs, ys in rs)
            ln_ = sum(pr * len(xs) for pr, z, xs, ys in rs)
            # the law of the question: (x or None) -> probability
            qlaw = {}
            for pr, z, xs, ys in rs:
                for J in range(1, L + 1):
                    x = xs[J - 1] if J <= len(xs) else None
                    qlaw[x] = qlaw.get(x, 0.0) + pr / L
            akappa = sum(pq * kl(P[x], M[x]) for x, pq in qlaw.items() if x is not None)
            cache[key] = (M, Lam, chi, bet, ln_, qlaw, akappa)
        return cache[key]

    tot = dict(Lam=0.0, chi=0.0, beta=0.0, akappa=0.0, len=0.0)
    per_round_beta = [0.0] * n
    leaves = []          # (prob, sum_t beta_t/L, sum_t chi_t/L)
    max_path_e = 0.0

    def rec(t, data, pr, sb, sc, se):
        nonlocal max_path_e
        if t == n:
            leaves.append((pr, sb, sc))
            max_path_e = max(max_path_e, se)
            return
        M, Lam, chi, bet, ln_, qlaw, akappa = info(data)
        tot['Lam'] += pr * Lam
        tot['chi'] += pr * chi
        tot['beta'] += pr * bet
        tot['akappa'] += pr * akappa
        tot['len'] += pr * ln_
        per_round_beta[t] += pr * bet
        for x, pq in qlaw.items():
            if x is None:
                rec(t + 1, data, pr * pq, sb + bet / L, sc + chi / L, se)
            else:
                for y in (0, 1):
                    py = P[x][y]
                    if py > 0:
                        e = 1.0 - M[x][y] if deterministic else 0.0
                        rec(t + 1, data + ((x, y),), pr * pq * py, sb + bet / L, sc + chi / L, se + e)

    rec(0, (), 1.0, 0.0, 0.0, 0.0)
    return W, tot, per_round_beta, leaves, max_path_e


def report(title, hyps, weights, iP, n, deterministic):
    P = hyps[iP]
    W, tot, prb, leaves, mpe = enumerate_protocol(hyps, weights, P, n, deterministic)
    C = log(W / weights[iP])
    ok = True
    print(f"-- {title}: n = {n}, L = {L}, W = {W:.3f}, w(P) = {weights[iP]:g}, ln(W/w(P)) = {C:.4f}; total probability of the leaves = {sum(l[0] for l in leaves):.12f}")
    a = tot['Lam']; b = L * tot['akappa']
    ok &= abs(a - b) < 1e-9 and a <= L * C + 1e-12
    print(f"   (a) sum_t E Lambda = {a:.6f};  L * sum_t E[a_t kappa_t] = {b:.6f} (equal: {abs(a - b) < 1e-9});  bound L ln(W/w(P)) = {L * C:.6f}")
    ok &= tot['chi'] <= L * C / 2 + 1e-12
    print(f"   (b) sum_t E chi = {tot['chi']:.6f} <= (L/2) ln(W/w(P)) = {L * C / 2:.6f}")
    lbar = tot['len'] / n
    b91 = sqrt(lbar * L * C / (2 * n))
    ok &= tot['beta'] / n <= b91 + 1e-12
    print(f"   9.1(a) E beta(M^(T)) = {tot['beta'] / n:.6f} <= sqrt(lbar L ln(W/w)/(2n)) = {b91:.6f}  (lbar = {lbar:.4f})")
    if deterministic:
        ok &= mpe <= C + 1e-12 and tot['beta'] <= L * C + 1e-12
        print(f"   (c) max over paths of sum of e_t at the asked rounds = {mpe:.6f} <= {C:.6f};  sum_t E beta = {tot['beta']:.6f} <= {L * C:.6f}")
    for delta in (0.5, 0.2, 0.05):
        if deterministic:
            thr = C + log(1 / delta)
            pr = sum(p for p, sb, sc in leaves if sb > thr + 1e-12)
            ok &= pr <= delta
            print(f"   4.3(a) delta = {delta}: Pr[sum_t beta(M^(t))/L > ln(W/w) + ln(1/delta) = {thr:.4f}] = {pr:.6f} <= delta")
        thr = C / 2 + log(1 / delta)
        pr = sum(p for p, sb, sc in leaves if sc > thr + 1e-12)
        ok &= pr <= delta
        print(f"   4.3(b) delta = {delta}: Pr[sum_t chi(M^(t))/L > ln(W/w)/2 + ln(1/delta) = {thr:.4f}] = {pr:.6f} <= delta")
    # a sharper test of 4.3: the largest value of Pr[sum > thr] * exp(thr - c*C) over all thresholds (must be <= 1)
    for name, idx, c in (("4.3(a)", 1, 1.0), ("4.3(b)", 2, 0.5)):
        if name == "4.3(a)" and not deterministic:
            continue
        srt = sorted(leaves, key=lambda l: -l[idx])
        acc, worst = 0.0, 0.0
        for l in srt:
            acc += l[0]
            # Pr[sum >= s] <= exp(-(s - c C)) is what the martingale argument gives (non-strict form)
            worst = max(worst, acc * exp(l[idx] - c * C))
        ok &= worst <= 1 + 1e-9
        print(f"   {name}: max over thresholds s of Pr[sum >= s] * exp(s - {c:g} ln(W/w)) = {worst:.6f} <= 1")
    print("   " + ("all inequalities hold" if ok else "*** AN INEQUALITY FAILS ***"))
    return ok


def main():
    ok = True
    # ---- stochastic human, semimeasures, W < 1
    hyps = [completed(h) for h in (
        {0: (0.3, 0.7), 1: (0.6, 0.4), 2: (0.1, 0.9), 3: (0.5, 0.5)},      # the human P (a sampler)
        {0: (0.3, 0.6), 1: (0.5, 0.4), 2: (0.1, 0.8), 3: (0.2, 0.2)},      # a semimeasure
        {0: (0.9, 0.1), 1: (0.6, 0.4), 2: (0.5, 0.5), 3: (0.5, 0.5)},
        {0: (0.0, 1.0), 1: (1.0, 0.0), 2: (0.0, 0.5), 3: (0.3, 0.3)},      # deterministic at 0 and 1, defective at 2, 3
        {0: (0.3, 0.7), 1: (0.6, 0.4), 2: (0.9, 0.1), 3: (0.0, 1.0)},      # equals P at inputs 0 and 1
    )]
    weights = [0.02, 0.4, 0.2, 0.2, 0.08]                                   # W = 0.9
    ok &= report("stochastic human, semimeasures, W = 0.9", hyps, weights, 0, 5, False)

    # ---- deterministic human; the class contains samplers and semimeasures
    hyps = [completed(h) for h in (
        {0: (0.0, 1.0), 1: (0.0, 1.0), 2: (1.0, 0.0), 3: (0.0, 1.0)},      # the human f
        {0: (0.0, 1.0), 1: (1.0, 0.0), 2: (1.0, 0.0), 3: (1.0, 0.0)},      # a function, wrong at 1 and 3
        {0: (0.5, 0.5), 1: (0.0, 1.0), 2: (0.5, 0.4), 3: (0.0, 1.0)},      # a semimeasure
        {0: (1.0, 0.0), 1: (0.0, 1.0), 2: (1.0, 0.0), 3: (0.0, 1.0)},      # wrong at 0 only: its own runs stop early
        {0: (0.0, 0.8), 1: (0.0, 1.0), 2: (0.0, 1.0), 3: (0.3, 0.7)},      # answers "no answer" at 0 with prob. 0.2
    )]
    weights = [0.01, 0.3, 0.3, 0.2, 0.15]                                   # W = 0.96
    ok &= report("deterministic human, mixed class, W = 0.96", hyps, weights, 0, 5, True)

    # ---- horizon-1 behaviour inside the same code: a class in which everything is decided at call 1
    hyps = [completed(h) for h in (
        {0: (1.0, 0.0), 1: (0.0, 1.0), 2: (1.0, 0.0), 3: (0.0, 1.0)},
        {0: (0.0, 1.0), 1: (0.0, 1.0), 2: (0.0, 1.0), 3: (0.0, 1.0)},
    )]
    ok &= report("deterministic human, two functions, W = 1", hyps, [0.05, 0.95], 0, 6, True)

    # ---- Theorem 5.1(c): is the bound L ln(1/w(f)) for beta approached?
    print("-- tightness of Theorem 5.1(c) for beta.  Class: f = 0 and N functions g_i, g_i = 1 at x_i only, weights (1-w)/N;")
    print("   scaffold: z uniform on {1..N}, all L calls at x_z.  Then sum_t E[beta(M^(t))] = L * E[sum of the errors at the asked inputs],")
    print("   and when every x_i has been asked the pathwise sum is  sum_{k<N} ((1-w)/N) / (1 - k (1-w)/N)  ->  ln(1/w).")
    for w in (0.5, 0.01, 1e-6):
        for N in (2, 10, 100, 10000):
            s = sum(((1 - w) / N) / (1 - k * (1 - w) / N) for k in range(N))
            print(f"   w = {w:g}, N = {N}: limit over n of sum_t E beta(M^(t)) / L = {s:.5f};  ln(1/w) = {log(1 / w):.5f};  two-function example (5.1(d)): 1 - w = {1 - w:.5f}")
    # exact finite-n value for one case, by the chain of the number of inputs already asked
    N, w, n = 50, 0.01, 2000
    dist = [0.0] * (N + 1); dist[0] = 1.0
    total = 0.0
    for t in range(n):
        new = [0.0] * (N + 1)
        for k, pr in enumerate(dist):
            if pr == 0.0:
                continue
            err = ((N - k) / N) * ((1 - w) / N) / (1 - k * (1 - w) / N)   # beta(M^(t))/L in state k
            total += pr * err
            new[k] += pr * k / N
            if k < N:
                new[k + 1] += pr * (N - k) / N
        dist = new
    print(f"   exact, N = {N}, w = {w}, n = {n}: sum_t E beta(M^(t)) / L = {total:.5f} <= ln(1/w) = {log(1 / w):.5f}")
    print()
    print("ALL CHECKS PASSED" if ok else "SOME CHECK FAILED")


if __name__ == "__main__":
    main()

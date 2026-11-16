#!/usr/bin/env python3
"""Numerical checks for lower-bounds.md, Sections 3, 5 and 6.

(a) Block class [N]^m (Theorem 3.1): the 'all-or-nothing' protocol against the
    lower bound p(1 - 2L/N - 2n/(mN)).
(b) The plurality protocol AB (Theorem 3.3) simulated on the block class:
    questions used and failure probability against the proved bounds.
(c) Fault tolerance of the block-majority scaffold (Theorem 5.3), by brute force.
(d) Lemma 6.2: TV(Bin(L,1/2+t), Bin(L,1/2-t)) >= t sqrt(L) (1 - 2 L t^2).
(e) Theorem 6.1 against the exact Bayes risk of the equal-allocation protocol.
"""
import itertools, math, random
from math import comb, log, log2, sqrt


def p_hit(L, N):
    return 1 - (1 - 1 / N) ** L


# ---------------------------------------------------------------- (a)
def all_or_nothing(m, N, L, rho):
    """Scan ceil(rho m) random blocks completely (cells 1..N-1, the last one is
    inferred).  Returns (expected questions, failure probability), exactly."""
    k = math.ceil(rho * m)
    exp_q_block = (N - 1) * (N + 2) / (2 * N)        # E min(position, N-1)
    return k * exp_q_block, (1 - k / m) * p_hit(L, N)


def check_a():
    print("(a) block class: lower bound of Theorem 3.1 vs. the all-or-nothing protocol")
    print("   m     N    L   rho  E[questions]  failure(protocol)  lower bound at that n")
    for m, N, L in ((8, 40, 2), (16, 200, 5), (64, 1000, 10), (64, 1000, 50)):
        for rho in (0.25, 0.5, 0.75):
            n, fail = all_or_nothing(m, N, L, rho)
            lb = p_hit(L, N) * (1 - 2 * L / N - 2 * n / (m * N))
            assert lb <= fail + 1e-12
            print(f"{m:4d} {N:5d} {L:4d}  {rho:.2f}  {n:11.1f}   {fail:.6f}           {max(lb, 0):.6f}")
    print()


# ---------------------------------------------------------------- (b)
def run_AB(m, N, L, gamma, n_B, rng):
    """Protocol AB on the block class with uniform weights.  Target: a uniform
    a in [N]^m.  Returns (questions asked, A-steps, disagreements found,
    average over the B-steps of the failure probability of the deployed h)."""
    a = [rng.randrange(N) for _ in range(m)]
    asked = [set() for _ in range(m)]        # asked cells of unresolved blocks
    found = [False] * m
    unfound = m
    eligible = []                            # blocks with <= 1/gamma candidates left
    questions = a_steps = b_steps = disagreements = 0
    u_sum = 0.0
    thresh = 1.0 / gamma
    p = p_hit(L, N)
    if N <= thresh:
        eligible = list(range(m))

    def after_zero(j):                       # a 0 was observed in block j
        nonlocal unfound
        left = N - len(asked[j])
        if left == 1:                        # one candidate left: needle known
            found[j] = True; unfound -= 1
        elif left <= thresh and left + 1 > thresh:
            eligible.append(j)

    while b_steps < n_B:
        # A-step: an input whose plurality answer has posterior mass <= 1 - gamma
        while eligible and found[eligible[-1]]:
            eligible.pop()
        if eligible:
            jA = eligible[-1]
            c = next(c for c in range(N) if c not in asked[jA])
            questions += 1; a_steps += 1
            if a[jA] == c:
                found[jA] = True; unfound -= 1
            else:
                asked[jA].add(c); after_zero(jA)
            continue
        # B-step: h = plurality (0 on every cell not known to hold the needle)
        b_steps += 1
        u_sum += p * unfound / m
        j = rng.randrange(m)                               # block of the run
        c = rng.randrange(N)                               # the audited call
        if found[j] or c in asked[j]:
            continue                                       # answer known: not asked
        questions += 1
        if a[j] == c:
            found[j] = True; unfound -= 1; disagreements += 1
        else:
            asked[j].add(c); after_zero(j)
    return questions, a_steps, disagreements, u_sum / n_B


def check_b():
    print("(b) protocol AB on the block class with N = L/(2 eps) (scaffold: L uniform calls in one random block)")
    rng = random.Random(1)
    for m, L, eps in ((8, 2, 1 / 16), (16, 4, 1 / 64), (32, 8, 1 / 128), (32, 16, 1 / 256)):
        N = round(L / (2 * eps))
        K = m * log2(N)
        u = log2(L / eps)
        gamma = u * eps / L
        n_B = math.ceil(L * K / (eps * (u - log2(u))))
        qs, fs = [], []
        for _ in range(20):
            q, a_st, dis, f = run_AB(m, N, L, gamma, n_B, rng)
            assert a_st <= K * log(2) / gamma + 1e-9
            assert dis <= K / log2(1 / gamma) + 1e-9
            qs.append(q); fs.append(f)
        qbound = n_B + K * log(2) / gamma
        fbound = L * K / (n_B * log2(1 / gamma))
        assert max(qs) <= qbound and sum(fs) / len(fs) <= fbound
        lb_n = (m * N / 2) * (1 - 2 * L / N - eps / p_hit(L, N))
        print(f"   m={m}, N={N}, L={L}, eps={eps:.5f}, K={K:.0f} bits, log2(L/eps)={u:.0f}, gamma={gamma:.4f}, n_B={n_B}")
        print(f"      questions asked: mean {sum(qs)/len(qs):.0f}, max {max(qs)};"
              f" proved bound n_B + K ln2/gamma = {qbound:.0f}; 2.7 K L/(eps log2(L/eps)) = {2.7 * K * L / (eps * u):.0f}")
        print(f"      failure of the deployed h: mean {sum(fs)/len(fs):.5f}; proved bound {fbound:.5f} (<= eps)")
        print(f"      Theorem 3.1: failure <= eps for all members needs n >= {max(lb_n, 0):.0f};"
              f" Protocol R's bound L K ln2/eps = {L * K * log(2) / eps:.0f}")
    print()


# ---------------------------------------------------------------- (c)
def check_c():
    print("(c) block-majority scaffold: outcome unchanged by <= m replaced answers (brute force)")
    for m_f, G, N0 in ((1, 2, 3), (2, 1, 3), (1, 3, 2)):
        b = 2 * m_f + 1
        Lc = G * b
        ok = True
        def outcome(ans):
            return int(any(sum(1 for y in ans[g * b:(g + 1) * b] if y == 1) >= m_f + 1
                           for g in range(G)))
        for regions in itertools.product(range(N0), repeat=G):
            for member in range(N0 + 1):                 # 0 = zero function
                truth = [int(member != 0 and regions[g] == member - 1)
                         for g in range(G) for _ in range(b)]
                o = outcome(truth)
                for k in range(m_f + 1):
                    for pos in itertools.combinations(range(Lc), k):
                        for vals in itertools.product((0, 1, None), repeat=k):
                            ans = list(truth)
                            for q, v in zip(pos, vals):
                                ans[q] = v               # None = abstention symbol
                            ok &= (outcome(ans) == o)
        print(f"   m={m_f}, blocks G={G}, block size {b}, regions N0={N0}: tolerant = {ok}")
        assert ok
    print()


# ---------------------------------------------------------------- (d), (e)
def binom_pmf(L, p):
    return [comb(L, k) * p ** k * (1 - p) ** (L - k) for k in range(L + 1)]


def tv_binom(L, t):
    a, b = binom_pmf(L, 0.5 + t), binom_pmf(L, 0.5 - t)
    return 0.5 * sum(abs(x - y) for x, y in zip(a, b))


def check_d():
    print("(d) Lemma 6.2: min over a grid of TV / (t sqrt(L) (1 - 2 L t^2)); must be >= 1")
    worst = 1e9
    for L in list(range(1, 60)) + [101, 200, 401]:
        for i in range(1, 200):
            t = i / 200 / math.sqrt(2 * L)             # 0 < t < 1/sqrt(2L)
            rhs = t * sqrt(L) * (1 - 2 * L * t * t)
            worst = min(worst, tv_binom(L, t) / rhs)
    print(f"   smallest ratio found: {worst:.4f}")
    assert worst >= 1.0
    print()


def check_e():
    print("(e) Theorem 6.1: lower bound (t/2)(1 - t sqrt(8 q)) vs exact Bayes risk 2 t Pr[MAP sign wrong]")
    print("    (K coins, q = n/K questions per coin, bias 1/2 +- t, per-call TV averaged over coins)")
    print("    q     t        lower bound   exact (equal allocation)")
    for q in (1, 4, 16, 64, 256):
        t = sqrt(1 / (32 * q))                          # the choice in the proof
        pm = binom_pmf(q, 0.5 + t)
        wrong = sum(pm[k] for k in range(q + 1) if 2 * k < q) \
            + 0.5 * sum(pm[k] for k in range(q + 1) if 2 * k == q)
        lb = (t / 2) * (1 - t * sqrt(8 * q))
        assert lb <= 2 * t * wrong + 1e-12
        print(f"  {q:4d}  {t:.5f}   {lb:.6f}      {2 * t * wrong:.6f}"
              f"    [sqrt(K/n)/(16 sqrt 2) = {1 / (16 * sqrt(2) * sqrt(q)):.6f}]")
    print()


if __name__ == "__main__":
    check_a(); check_b(); check_c(); check_d(); check_e()
    print("all checks passed")

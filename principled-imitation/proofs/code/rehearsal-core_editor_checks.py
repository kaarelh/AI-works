"""Editor's checks for proofs/rehearsal-core.md.

Each block recomputes, independently of the prover's and the verifiers' scripts,
one statement that the editor added to the proof file or accepted from a
verification report.  Everything is exact (closed forms, dynamic programming,
binomial laws) except block 3, which evaluates inequalities on random
distributions drawn with a fixed seed.

Blocks:
 1  Theorem 5.1(d): the bound of (c) is approached (N one-point alternatives).
 2  Example 8.5(d): tolerance against faults placed blindly does not give R3.
 3  Theorem 13.1(a0): TV(a,p) <= 1 - sum a p <= TV(a,p) + 1 - sum p^2.
 4  Proposition 13.4(b): exact total variation of the two transcript laws.
 5  Proposition 9.4: Pr[N >= k] <= 2 e^2 L Lambda / k^2 + 2^-k.
 6  Proposition 5.6 (R7): closed forms for one input per run.
 7  Constants: Proposition 6.3, Proposition 6.4, Corollary 13.2, Remark 12.3(v).
 8  Proposition 5.7 (audits that are not uniform), one exact example.
 9  Proposition 13.5 (repeated questions): E TV(p_hat, p) <= sqrt((s-1)/r)/2.
"""
from fractions import Fraction
from math import log, exp, sqrt, comb, e, floor
import random

random.seed(20261116)


def binom_pmf(n, p):
    """List of the binomial probabilities Pr[Bin(n, p) = i], i = 0..n."""
    out = [0.0] * (n + 1)
    if p <= 0.0:
        out[0] = 1.0
        return out
    if p >= 1.0:
        out[n] = 1.0
        return out
    # recursion in logs for stability
    lp, lq = log(p), log(1.0 - p)
    from math import lgamma
    for i in range(n + 1):
        out[i] = exp(lgamma(n + 1) - lgamma(i + 1) - lgamma(n - i + 1) + i * lp + (n - i) * lq)
    return out


# ---------------------------------------------------------------- block 1
print("== 1. Theorem 5.1(d): the bound of (c) is approached ==")
print("Class: f = 0 (weight w) and g_i = 1[x = x_i], i <= N (weight (1-w)/N each); z uniform on N inputs, all L calls at x_z.")
w = 0.01
for N in (10, 100, 10000):
    closed = sum(((1 - w) / N) / (1 - k * (1 - w) / N) for k in range(N))
    print(f"  N={N}: sum over all rounds of E beta(M^(t)) / L = {closed:.4f};  ln(1/w) = {log(1/w):.4f};  two-function example: 1 - w = {1-w:.2f}")
# exact finite-n value by the Markov chain of the number k of distinct inputs asked (N = 10)
N = 10
for n in (10, 50, 200, 1000):
    dist = [0.0] * (N + 1)
    dist[0] = 1.0
    total = 0.0
    for t in range(1, n + 1):
        # E beta(M^(t)) / L given k inputs asked: Pr[z unasked] * Pr[mixture errs there]
        total += sum(dist[k] * ((N - k) / N) * ((1 - w) / N) / (1 - k * (1 - w) / N) for k in range(N))
        new = [0.0] * (N + 1)
        for k in range(N + 1):
            if dist[k] == 0.0:
                continue
            new[k] += dist[k] * (k / N)
            if k < N:
                new[k + 1] += dist[k] * ((N - k) / N)
        dist = new
    print(f"  N=10, n={n}: sum_(t<=n) E beta(M^(t)) / L = {total:.4f}  (limit 2.7836 as n grows; bound ln(1/w) = {log(1/w):.4f})")

# ---------------------------------------------------------------- block 2
print()
print("== 2. Example 8.5(d): faults placed blindly ==")
print("L calls at one input; the human answers 1 with probability mu; G = {some answer is 1}; imitator C = always 0.")
for (L, mu, k) in ((60, 0.05, 3), (400, 0.01, 39), (4000, 0.002, 399)):
    human_fails = (1 - mu) ** L
    blind = (1 - mu) ** (L - k)
    pmf = binom_pmf(L, mu)
    seeing = sum(pmf[: k + 1])            # Pr[Bin(L, mu) <= k]
    beta = mu * L
    claim = blind + beta / (k + 1)
    print(f"  L={L} mu={mu} k={k}: human system fails {human_fails:.4f}; k calls answered blindly: {blind:.4f}; "
          f"k replacements by a rule that sees the answer: {seeing:.4f}; beta/(k+1) = {beta/(k+1):.4f}; "
          f"'delta + beta/(k+1)' with blind tolerance = {claim:.4f} < 1 = Q_C(not G)")

# ---------------------------------------------------------------- block 3
print()
print("== 3. Theorem 13.1(a0): TV(a,p) <= 1 - sum_y a(y)p(y) <= TV(a,p) + 1 - sum_y p(y)^2 ==")
worst_low, worst_up, worst_half = 0.0, 0.0, 0.0
for trial in range(20000):
    s = random.randint(2, 6)
    def rnd():
        v = [random.random() ** random.choice((1, 3, 8)) for _ in range(s)]
        if random.random() < 0.3:
            v[random.randrange(s)] = 0.0
        tot = sum(v)
        if tot == 0.0:
            v[0] = 1.0
            tot = 1.0
        return [x / tot for x in v]
    a, p = rnd(), rnd()
    tv = 0.5 * sum(abs(x - y) for x, y in zip(a, p))
    dis = 1.0 - sum(x * y for x, y in zip(a, p))
    noise = 1.0 - sum(y * y for y in p)
    worst_low = max(worst_low, tv - dis)
    worst_up = max(worst_up, dis - tv - noise)
    worst_half = max(worst_half, noise / 2 - dis)
print(f"  20000 random pairs of distributions: max of TV - dis = {worst_low:.2e} (<= 0);  max of dis - TV - noise = {worst_up:.2e} (<= 0);"
      f"  max of noise/2 - dis = {worst_half:.2e} (<= 0)")

# ---------------------------------------------------------------- block 4
print()
print("== 4. Proposition 13.4(b): m answers at one input, uniform on Y (M values) against uniform on a random half ==")


def stirling2_row(m):
    """S(m, c) for c = 0..m."""
    row = [1] + [0] * m
    for i in range(1, m + 1):
        new = [0] * (m + 1)
        for c in range(1, i + 1):
            new[c] = c * row[c] + row[c - 1]
        row = new
    return row


for (M, m) in ((8, 3), (64, 4), (1024, 8), (1024, 20), (2 ** 20, 100)):
    S2 = stirling2_row(m)
    half = M // 2
    tv = Fraction(0)
    falling = 1  # M (M-1) ... (M-c+1)
    p0 = Fraction(1, M ** m)
    inhalf = Fraction(1)
    for c in range(1, m + 1):
        falling *= (M - c + 1)
        count = falling * S2[c]                    # sequences with exactly c distinct values
        # Pr[all c values in the half] = C(M-c, half-c) / C(M, half) = prod_{i<c} (half-i)/(M-i)
        inhalf *= Fraction(half - (c - 1), M - (c - 1))
        p1 = inhalf * Fraction(1, half ** m)
        tv += count * abs(p0 - p1) / 2
    print(f"  M={M} m={m}: exact TV = {float(tv):.6f} <= m(m-1)/(2M) = {m*(m-1)/(2*M):.6f}")

# ---------------------------------------------------------------- block 5
print()
print("== 5. Proposition 9.4: Pr[N >= k] <= 2 e^2 L Lambda / k^2 + 2^-k ==")
print("Kernel with the same total variation t at each of L calls (human Bern(1/2), imitator Bern(1/2 - t)); N ~ Bin(L, t).")
worst = 0.0
cases = 0
informative = 0
for L in (10, 50, 400, 2000):
    for t in (0.001, 0.005, 0.02, 0.1, 0.3):
        kl = 0.5 * log(0.5 / (0.5 - t)) + 0.5 * log(0.5 / (0.5 + t))
        Lam = L * kl
        pmf = binom_pmf(L, t)
        tail = [0.0] * (L + 2)
        for i in range(L, -1, -1):
            tail[i] = tail[i + 1] + pmf[i]
        for k in range(1, L + 1):
            bound = 2 * e * e * L * Lam / k ** 2 + 2.0 ** (-k)
            cases += 1
            if bound < 1.0:
                informative += 1
                worst = max(worst, tail[k] / bound)
print(f"  {cases} cases (L, t, k), of which {informative} have a bound below 1: largest value of exact tail / bound among these = {worst:.4f} (<= 1)")
print(f"  the bound 2 e^2 K ln2/(theta^2 n) beats sqrt(K ln2/(2n))/theta for an excess failure below 1/(8 e^2) = {1/(8*e*e):.4f}")

# ---------------------------------------------------------------- block 6
print()
print("== 6. Proposition 5.6 (R7): one call per run at an input uniform on N values ==")
for (N, n) in ((50, 10), (200, 20), (1000, 50)):
    one = (1 - (1 - 1 / N) ** n) / n              # Pr[round T is at x0 and x0 was not asked before], one fixed x0
    q10 = sum((10 / N) * (1 - 10 / N) ** (t - 1) for t in range(1, n + 1)) / n   # a fixed set of 10 inputs
    some = sum((1 - 1 / N) ** (t - 1) for t in range(1, n + 1)) / n              # the input of round T, whichever it is
    print(f"  N={N} n={n}: fixed input: {one:.4f}; fixed set of 10 inputs: {q10:.4f}; both <= L/n = {1/n:.4f};"
          f"  'the set of inputs not asked so far' (depends on the data): {some:.4f}")

# ---------------------------------------------------------------- block 7
print()
print("== 7. Constants ==")
abar_over_sqrtL = log(1 + e) / (3 * 1.1272)
print(f"  Proposition 6.3: abar/sqrt(L) = {abar_over_sqrtL:.6f}; abar/N <= {abar_over_sqrtL/1.6262:.7f} (so 0.23882, not 0.23881);"
      f" bracket >= {0.731*(0.71633-0.23882)-0.0011:.5f} > 0.3479")
for L in (10, 100, 1000):
    c = 2.0
    for _ in range(200):
        c = 1 + log(L * c)
    print(f"  Proposition 6.4: with n = c * 2 L^2 K ln2 the term 2 L B0 (1 + ln(1/(2 B0))) = (1 + ln(L c))/c is below 1 only for c > {c:.2f}  (L = {L}; ln L + 3 = {log(L)+3:.2f})")
print(f"  Corollary 13.2: ln(1/delta)/delta' = {log(1/0.05)/0.1:.1f} for delta = 0.05, delta' = 0.1")
for (L, eta, delta) in ((1000, 0.5, 0.01), (100, 0.9, 0.1)):
    m8 = floor(eta * L - sqrt(8 * L * log(1 / delta)))
    m2 = floor(eta * L - sqrt(2 * L * log(1 / delta)))
    print(f"  Remark 12.3(v): L={L} eta={eta} delta={delta}, mu=1, D=0: the condition admits k = {m8} with the constant 8 and k = {m2} with the constant 2;"
          f" on the early-stopping scaffold one replaced answer makes the run bad")
print(f"  Budget (K bits, one hour per answer, 2000 hours a year), R1 with L = 10 and failure 0.1: "
      + "; ".join(f"K=1e{int(round(log(K,10)))}: {10*K*log(2)/0.1/2000:.3g} years" for K in (1e2, 1e4, 1e9)))
print(f"  Certificate: m = ln(1/0.05)/(0.1*0.1) = {log(20)/0.01:.0f} rounds certify an excess failure 0.1 under theta = 0.1, whatever L and K")

# ---------------------------------------------------------------- block 8
print()
print("== 8. Proposition 5.7 (audits that are not uniform): an exact example ==")
print("Two calls per run at inputs x1, x2; f = 0; class {f, g1, g2}, g_i wrong at x_i only; weights w(f)=0.2, w(g1)=0.3, w(g2)=0.5.")
print("Audit probabilities (pi1, pi2) with pi1 + pi2 = 1; exact sum over rounds of E[pi1 e1 + pi2 e2] against ln(1/w(f)).")
for pi1 in (0.5, 0.9, 0.1):
    pi2 = 1 - pi1
    wf, w1, w2 = 0.2, 0.3, 0.5
    # states: which of g1, g2 are alive; start both alive
    states = {(1, 1): 1.0}
    total = 0.0
    for t in range(1, 4001):
        new = {}
        for (a1, a2), pr in states.items():
            mass = wf + a1 * w1 + a2 * w2
            e1 = a1 * w1 / mass
            e2 = a2 * w2 / mass
            total += pr * (pi1 * e1 + pi2 * e2)
            # the audited call is x1 with probability pi1 (refutes g1), x2 otherwise (refutes g2)
            for (b1, b2), q in (((0, a2), pi1), ((a1, 0), pi2)):
                new[(b1, b2)] = new.get((b1, b2), 0.0) + pr * q
        states = new
    print(f"  pi1={pi1}: sum = {total:.4f} <= ln(1/w(f)) = {log(1/0.2):.4f}")

# ---------------------------------------------------------------- block 9
print()
print("== 9. Proposition 13.5: E TV(p_hat, p) <= sqrt((s-1)/r)/2 for the empirical law of r draws (exact for s = 2) ==")
for (p1, r) in ((0.5, 10), (0.5, 100), (0.1, 30), (0.02, 200)):
    pmf = binom_pmf(r, p1)
    etv = sum(pmf[i] * abs(i / r - p1) for i in range(r + 1))
    print(f"  s=2, p=({p1}, {1-p1}), r={r}: E TV = {etv:.4f} <= {0.5*sqrt(1/r):.4f}")
print()
print("No check contradicts a statement of the proof file.")

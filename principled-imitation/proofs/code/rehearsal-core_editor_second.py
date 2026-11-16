#!/usr/bin/env python3
"""Editor of part rehearsal-core, second round: the editor's own checks of the findings of
verification/rehearsal-core-second.md.

Written from the statements, without reusing any earlier script. Exact arithmetic (fractions)
wherever a block says "exact"; floats from exact enumeration elsewhere. No sampling.

Blocks:
 1. The paragraph "Compute" of Section 2 of the note (finding N1; Remark 5.9 of the proof file):
    a posterior draw by rejection. (a) complete code: the accepted program has the posterior law,
    the number of trials is geometric with mean 1/xi(D) <= 2^K/P(D); (b) incomplete code: a trial
    hangs with probability 1 - W, the draw returns with probability xi/(xi + 1 - W) < 1;
    (c) under Protocol R, E ln(1/xi(D_n)) lies between E ln(1/P(D_n)) + ln(1/W) and
    E ln(1/P(D_n)) + K ln 2, and E ln(1/P(D_n)) is the summed entropy of the recorded answers.
 2. Finding N4: the 350 years of Section 3.1.
 3. Finding N5: the hypotheses and the constant of Theorem 9.2.
 4. Finding N7: the recoverable form. Two exact examples: the condition read against the human's
    average does not give the bound; the condition required only at histories of the human system
    does not give the bound.
 5. The clause after Proposition 5.6 that the second check left unchecked: coverage fails for the
    last mixture by a factor of order sqrt(L). The idealised chain in closed form, and Protocol R
    computed exactly on the class with weights proportional to eps^j.
 6. Remark 4.4(d) for Proposition 6.1(a): the human is not in the class, two members agree with
    the human on the inputs that the scaffold can produce.
"""
import itertools
import math
from fractions import Fraction as F

OUT = []


def say(s=""):
    print(s)
    OUT.append(s)


# -------------------------------------------------------------------------------------------
say("== 1. 'Compute': a posterior draw by rejection ==")
# Inputs X = {0, 1}, answers Y = {0, 1}. A program is an always-halting sampler: nu[x] = Pr[answer 1].
progs = {
    "0": {0: F(9, 10), 1: F(1, 5)},
    "10": {0: F(1, 2), 1: F(1, 2)},
    "110": {0: F(1, 4), 1: F(4, 5)},   # the human
    "111": {0: F(0), 1: F(1)},
}
human = "110"
data = [(0, 1), (1, 1), (0, 0), (1, 1), (1, 0)]


def lik(nu, D):
    p = F(1)
    for x, y in D:
        p *= nu[x] if y == 1 else 1 - nu[x]
    return p


def trial_table(code):
    """One trial: read fair bits until the string read is a codeword; then answer the recorded
    questions afresh. Returns {codeword: Pr[this codeword is read]} and Pr[the reading never ends],
    by enumeration of all bit strings up to the longest codeword."""
    m = max(len(c) for c in code)
    read = {c: F(0) for c in code}
    hang = F(0)
    for bits in itertools.product("01", repeat=m):
        s = "".join(bits)
        hit = [c for c in code if s.startswith(c)]
        assert len(hit) <= 1, "the code is not prefix-free"
        if hit:
            read[hit[0]] += F(1, 2 ** m)
        else:
            hang += F(1, 2 ** m)   # no codeword is a prefix of s and (checked below) none extends s
    for bits in itertools.product("01", repeat=m):
        s = "".join(bits)
        assert not any(c.startswith(s) and c != s for c in code)
    return read, hang


# (a) complete code
read, hang = trial_table(progs)
assert hang == 0 and all(read[c] == F(1, 2 ** len(c)) for c in progs)
acc = {c: read[c] * lik(progs[c], data) for c in progs}          # Pr[a trial reads c and keeps it]
xi = sum(acc.values())
post = {c: F(1, 2 ** len(c)) * lik(progs[c], data) / xi for c in progs}
assert all(acc[c] / xi == post[c] for c in progs)
K = len(human)
PD = lik(progs[human], data)
say(f"  complete code {sorted(progs)}: Pr[a trial keeps its program] = xi(D) = {xi} = {float(xi):.6f}")
say("    law of the kept program = posterior (exact, as fractions): "
    + ", ".join(f"{c}: {post[c]}" for c in progs))
say(f"    mean number of trials = 1/xi(D) = {float(1 / xi):.3f} <= 2^K/P(D) = {float(2 ** K / PD):.3f}: {1 / xi <= 2 ** K / PD}")
# (b) incomplete code: drop the program 111; the prefix 11 can still be extended (110), but 111 is dead
code_b = {c: progs[c] for c in ("0", "10", "110")}
read_b, hang_b = trial_table(code_b)
W_b = sum(read_b.values())
acc_b = {c: read_b[c] * lik(code_b[c], data) for c in code_b}
xi_b = sum(acc_b.values())
ret = xi_b / (xi_b + hang_b)     # Pr[some trial keeps a program before a trial hangs]
post_b = {c: acc_b[c] / xi_b for c in code_b}
say(f"  incomplete code {sorted(code_b)} (W = {W_b}): a trial never ends with probability 1 - W = {hang_b};")
say(f"    the draw returns with probability xi/(xi + 1 - W) = {float(ret):.6f} < 1; given that it returns, the law is the posterior: "
    + ", ".join(f"{c}: {post_b[c]}" for c in code_b))
say(f"    mean number of trials started = 1/(xi + 1 - W) = {float(1 / (xi_b + hang_b)):.3f} <= 1/xi = {float(1 / xi_b):.3f}")

# (c) Protocol R, exact: E ln(1/xi(D_n)) against E ln(1/P(D_n))
# Scaffold of horizon 2: z uniform on {0, 1}; call 1 at x = z; call 2 at x = y_1 (depends on the answer).


def protocol_R(H, w, P, n, L=2):
    """Exact enumeration of Protocol R. H: list of samplers (dict x -> Pr[1]); w: weights; P: the human.
    Returns the law of the ordered data list D_n as {tuple of pairs: probability} (floats)."""
    dist = {(): 1.0}
    for _ in range(n):
        new = {}
        for D, pD in dist.items():
            post = [float(wi) * float(lik(nu, D)) for wi, nu in zip(w, H)]
            Z = sum(post)
            M = {x: sum(pi * float(nu[x]) for pi, nu in zip(post, H)) / Z for x in (0, 1)}
            for z in (0, 1):
                for y1 in (0, 1):
                    p1 = M[z] if y1 == 1 else 1 - M[z]
                    xs = (z, y1)                    # the inputs of the two calls
                    for J in (1, 2):
                        x = xs[J - 1]
                        for y in (0, 1):
                            py = float(P[x]) if y == 1 else 1 - float(P[x])
                            pr = pD * 0.5 * p1 * 0.5 * py
                            if pr > 0:
                                key = D + ((x, y),)
                                new[key] = new.get(key, 0.0) + pr
        dist = new
    return dist


def entropy(p):
    return -sum(q * math.log(q) for q in (p, 1 - p) if q > 0)


H = [progs[c] for c in ("0", "10", "110", "111")]
w = [F(1, 2), F(1, 4), F(1, 8), F(1, 8)]
P = progs[human]
Kln2 = math.log(8)
for n in (2, 4, 6, 8):
    dist = protocol_R(H, w, P, n)
    assert abs(sum(dist.values()) - 1) < 1e-12
    Elnxi = sum(p * -math.log(sum(float(wi) * float(lik(nu, D)) for wi, nu in zip(w, H))) for D, p in dist.items())
    ElnP = sum(p * -math.log(float(lik(P, D))) for D, p in dist.items())
    Hsum = sum(p * sum(entropy(float(P[x])) for x, _ in D) for D, p in dist.items())
    ok = ElnP - 1e-12 <= Elnxi <= ElnP + Kln2 + 1e-12
    say(f"  Protocol R, n = {n}: E ln(1/P(D_n)) = {ElnP:.4f} (summed entropy of the recorded answers: {Hsum:.4f})"
        f" <= E ln(1/xi(D_n)) = {Elnxi:.4f} <= E ln(1/P(D_n)) + K ln 2 = {ElnP + Kln2:.4f}: {ok}")
say("    so the logarithm of the number of trials grows in proportion to the number of recorded answers of a human who varies;")
say("    for a deterministic human P(D) = 1 and the number of trials is at most 2^K whatever n.")

# -------------------------------------------------------------------------------------------
say()
say("== 2. Finding N4: the budget of Section 3.1 ==")
for Kbits in (1e2, 1e4, 1e9):
    n = 10 * Kbits * math.log(2) / 0.1
    say(f"  L = 10, 0.1 unfaithful calls per run, K = {Kbits:.0e}: n = L K ln 2/0.1 = {n:.4g} answers; at one hour each: "
        f"{n / 2000:.4g} years of 2000 working hours, {n / 8766:.4g} calendar years (8766 hours)")

# -------------------------------------------------------------------------------------------
say()
say("== 3. Finding N5: Theorem 9.2 ==")
say(f"  theta = sqrt(K/(32 n)) <= 1/4 exactly when n >= K/2; L theta/2 = L sqrt(K/n)/(8 sqrt 2), 1/(8 sqrt 2) = {1 / (8 * math.sqrt(2)):.5f} > 0.088")
worst = 0.0
for i in range(1, 2501):
    th = i / 10000.0
    klv = 2 * th * math.log((1 + 2 * th) / (1 - 2 * th))
    worst = max(worst, klv / (16 * th * th))
say(f"  kl(Bern(1/2 + theta) || Bern(1/2 - theta)) <= 16 theta^2 for theta <= 1/4: largest ratio on a grid = {worst:.4f} (<= 1)")
say("  the class P_sigma(1|i) = 1/2 + sigma_i theta depends on n through theta: the statement is 'for every K, L and n >= K/2")
say("  there is a class of 2^K members with equal weights such that every protocol with at most n questions in expectation ...'")

# -------------------------------------------------------------------------------------------
say()
say("== 4. Finding N7: the recoverable form (Theorem 8.6) ==")
# (i) One call. The human answers u or d with probability 1/2 each; the cost is 0 after u, 1 after d and 1 after b.
v = {"u": F(0), "d": F(1), "b": F(1)}
Phum = {"u": F(1, 2), "d": F(1, 2), "b": F(0)}
C = {"u": F(0), "d": F(1, 2), "b": F(1, 2)}       # the imitator: b where the human would say u
cost_h = sum(Phum[y] * v[y] for y in v)
cost_C = sum(C[y] * v[y] for y in v)
beta = sum(abs(C[y] - Phum[y]) for y in v) / 2
mu_avg = max(v[y] - cost_h for y in v)                                   # against the human's average
mu_pair = max(v[y] - v[yp] for y in v for yp in v if Phum[yp] > 0)       # condition (8.1)
say(f"  (i) one call, human u/d with probability 1/2, cost 0 after u, 1 after d or b; imitator d/b with probability 1/2:")
say(f"      E_Q_P[c] = {cost_h}, E_Q_C[c] = {cost_C}, beta(C) = {beta};")
say(f"      mu read against the human's average = {mu_avg}: E_Q_P[c] + mu beta = {cost_h + mu_avg * beta} < E_Q_C[c] = {cost_C}: the bound FAILS;")
say(f"      mu of condition (8.1), against each answer the human might give = {mu_pair}: E_Q_P[c] + mu beta = {cost_h + mu_pair * beta} >= {cost_C}: holds.")
# (ii) Two calls, f = 0 at both; the cost is 1 exactly if both answers are 1. The imitator answers 1 with probability e at each call.
e = F(1, 10)
cost_C2 = e * e
beta2 = 2 * e
mu_on_path = F(0)      # at the histories of the human system (start; after the answer 0): one replaced answer costs 0
mu_all = F(1)          # at the history after the answer 1: a second 1 costs 1
say(f"  (ii) two calls, f = 0, cost 1 exactly if both answers are 1; imitator answers 1 with probability {e} at each call:")
say(f"      E_Q_f[c] = 0, E_Q_C[c] = {cost_C2}, beta(C) = {beta2};")
say(f"      (8.1) only at histories of the human system: mu = {mu_on_path}, bound {mu_on_path * beta2} < {cost_C2}: FAILS;")
say(f"      (8.1) at every history: mu = {mu_all}, bound {mu_all * beta2} >= {cost_C2}: holds.")

# -------------------------------------------------------------------------------------------
say()
say("== 5. Coverage and the last mixture (the clause after Proposition 5.6) ==")
# Chain: inputs x_1..x_L; call j+1 is made only if call j was answered 1; f = 1 everywhere;
# g_j = 1 everywhere except 0 at x_j, for j < L. Q = {x_L}.
# Idealised chain (the mixture answers the first link not yet asked wrongly with certainty):
# each round makes exactly one useful draw of J with probability 1/L, so
# Pr[the run of M^(n+1) reaches x_L and no question of rounds 1..n lay in Q] = Pr[Bin(n, 1/L) = L - 1].


def binom_pmf(n, p, k):
    if k > n:
        return 0.0
    return math.exp(math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)
                    + k * math.log(p) + (n - k) * math.log(1 - p))


for L in (10, 40, 160):
    best = max(((binom_pmf(n, 1.0 / L, L - 1) * (n + 1) / L), n) for n in range(L - 1, 4 * L * L))
    say(f"  idealised chain, L = {L}: max over n of Pr[Bin(n, 1/L) = L - 1]/(L/(n + 1)) = {best[0]:.3f} at n = {best[1]}"
        f" (n/L^2 = {best[1] / L ** 2:.2f});  sqrt(L/(2 pi)) = {math.sqrt(L / (2 * math.pi)):.3f}")


def chain_exact(L, eps, nmax):
    """Protocol R on the chain with the class {g_1..g_{L-1}, f}, weights proportional to eps^j (g_j) and eps^L (f).
    State: (set A of links j < L already asked, as a bitmask; flag: a question lay in Q = {x_L}).
    Returns the lists last[n] = Pr[run of M^(n+1) reaches x_L and no question of rounds 1..n lay in Q], n = 0..nmax,
    and the sum over rounds t <= nmax of Pr[run of M^(t) reaches x_L and no question of rounds < t lay in Q]."""
    wts = [eps ** j for j in range(1, L)]      # g_1 .. g_{L-1}
    wf = eps ** L
    reach_cache = {}

    def reach(A):
        """reach[j-1] = Pr[the run of the mixture given A makes call j], j = 1..L."""
        if A in reach_cache:
            return reach_cache[A]
        Z = wf + sum(wts[j - 1] for j in range(1, L) if not (A >> (j - 1)) & 1)
        r = [1.0]
        for j in range(1, L):
            wrong = 0.0 if (A >> (j - 1)) & 1 else wts[j - 1] / Z
            r.append(r[-1] * (1 - wrong))
        reach_cache[A] = r
        return r

    dist = {(0, 0): 1.0}
    last = []
    total_random_round = 0.0
    for n in range(nmax + 1):
        val = sum(p * reach(A)[L - 1] for (A, flag), p in dist.items() if flag == 0)
        last.append(val)
        if n < nmax:
            total_random_round += val      # round t = n + 1 uses the mixture given D_n
        new = {}
        for (A, flag), p in dist.items():
            r = reach(A)
            stay = p
            for j in range(1, L + 1):
                pj = p * r[j - 1] / L      # J = j and the run made call j
                if j == L:
                    if flag == 0:
                        new[(A, 1)] = new.get((A, 1), 0.0) + pj
                        stay -= pj
                elif not (A >> (j - 1)) & 1:
                    key = (A | (1 << (j - 1)), flag)
                    new[key] = new.get(key, 0.0) + pj
                    stay -= pj
            new[(A, flag)] = new.get((A, flag), 0.0) + stay
        dist = new
    return last, total_random_round


for L, eps, nmax in ((6, 1e-3, 150), (10, 1e-1, 400), (10, 1e-3, 400), (12, 1e-3, 500)):
    last, tot = chain_exact(L, eps, nmax)
    ratio, n_at = max((last[n] * (n + 1) / L, n) for n in range(1, nmax + 1))
    ideal = max(binom_pmf(n, 1.0 / L, L - 1) * (n + 1) / L for n in range(L - 1, nmax + 1))
    say(f"  exact Protocol R, L = {L}, eps = {eps:g}: max over n <= {nmax} of Pr[last mixture enters Q unasked]/(L/(n + 1)) = {ratio:.3f}"
        f" at n = {n_at} (idealised chain: {ideal:.3f});  random round: sum over t <= {nmax} of the same probability = {tot:.4f} <= L = {L}")

# -------------------------------------------------------------------------------------------
say()
say("== 6. Remark 4.4(d) for Proposition 6.1(a): the human is not in the class ==")
# Non-adaptive scaffold, L = 2: z uniform on {0, 1, 2}; call 1 at z, call 2 at z + 1 mod 3. X = {0,..,4}, X0 = {0, 1, 2}.
# Human f = 0 everywhere; f is not in H. nu1, nu2 agree with f on X0 and differ at 3 and at 4.
Lh = 2
X0 = (0, 1, 2)
members = [
    ("nu1", F(1, 50), {0: F(0), 1: F(0), 2: F(0), 3: F(1), 4: F(0)}),
    ("nu2", F(1, 50), {0: F(0), 1: F(0), 2: F(0), 3: F(0), 4: F(1)}),
    ("g_a", F(3, 10), {0: F(1), 1: F(0), 2: F(0), 3: F(0), 4: F(0)}),
    ("g_b", F(3, 10), {0: F(0), 1: F(1), 2: F(1), 3: F(0), 4: F(0)}),
    ("s", F(3, 10), {x: F(3, 10) for x in range(5)}),
]
Wh = sum(m[1] for m in members)
wP = F(1, 50) + F(1, 50)
worst = F(0)
for n in range(1, 9):
    Ebeta = F(0)
    # each round asks one input, uniform on X0 (every run has two calls, each x in X0 is the input of 2/3 calls on average)
    for c0 in range(n + 1):
        for c1 in range(n + 1 - c0):
            c2 = n - c0 - c1
            pm = F(math.factorial(n), math.factorial(c0) * math.factorial(c1) * math.factorial(c2)) * F(1, 3) ** n
            cnt = {0: c0, 1: c1, 2: c2}
            post = []
            for _, wt, nu in members:
                l = wt
                for x in X0:
                    l *= (1 - nu[x]) ** cnt[x]      # the human answers 0
                post.append(l)
            Z = sum(post)
            err = {x: sum(pi * nu[x] for pi, (_, _, nu) in zip(post, members)) / Z for x in X0}
            Ebeta += pm * Lh * sum(F(1, 3) * err[x] for x in X0)
    bound = Lh * (math.log(Wh / wP) + 1) / n
    worst = max(worst, Ebeta / F(bound).limit_denominator(10 ** 12))
    say(f"  n = {n}: E beta(M^(n+1)) = {float(Ebeta):.6f} <= L (ln(W/w([f])) + 1)/n = {bound:.6f}: {float(Ebeta) <= bound}")
say(f"  largest ratio = {float(worst):.4f} (<= 1); here w([f]) = {wP}, W = {Wh}, and f itself has no weight.")

# -------------------------------------------------------------------------------------------
say()
say("== 7. Numbers that the second check compared with saved outputs or checked by hand ==")
# Proposition 6.4, 'Where the statement has content': (1 + ln(L c))/c = 1
for Lc in (10, 100, 1000):
    lo, hi = 1.0, 100.0
    for _ in range(200):
        mid = (lo + hi) / 2
        if (1 + math.log(Lc * mid)) / mid > 1:
            lo = mid
        else:
            hi = mid
    say(f"  Proposition 6.4: (1 + ln(L c))/c < 1 exactly for c > {hi:.3f} when L = {Lc} (ln L + 3 = {math.log(Lc) + 3:.2f})")
# Example 8.5(d), second count
mu, Dd, eta, delta, Lb = 0.2, 3.0, 0.5, 1e-3, 2_000_000
kmax = (eta * mu * Lb - math.sqrt(2 * Lb * math.log(1 / delta))) / max(2.0, mu + Dd)
k = math.floor(kmax)
beta = 0.9 * k
epsk = beta / (Lb * (1 + mu) / 2)
loss = (1 + Dd) * beta
allowed = eta * mu * Lb
sd = math.sqrt(Lb * (1 - mu * mu))
say(f"  Example 8.5(d), second count: the condition allows k <= {kmax:.1f}; the kernel with beta = 0.9 k = {beta:.1f} has eps = {epsk:.4f},")
say(f"    expected loss (1 + D) beta = {loss:.4g} against the allowed {allowed:.4g}; the sum of the human's steps has standard deviation {sd:.4g},")
say(f"    so the expected loss exceeds the allowed loss by {(loss - allowed) / sd:.1f} such standard deviations; delta + beta/(k + 1) = {delta + beta / (k + 1):.3f}")
# Proposition 9.4 against Proposition 9.1(b)
say(f"  Proposition 9.4: 4 e^2/gamma' < 1/(2 gamma'^2) exactly for gamma' < 1/(8 e^2) = {1 / (8 * math.e ** 2):.5f}")
# Corollary 13.2
say(f"  Corollary 13.2: ln(1/0.05)/0.1 = {math.log(20) / 0.1:.2f}; m = ln(1/0.05)/(0.1 * 0.1) = {math.log(20) / 0.01:.1f} rounds")
# Theorem 13.1(a2): 1 + sqrt(2) + 2
say(f"  Theorem 13.1(a2) at rho_hat = ln(1/delta)/m: 1 + sqrt 2 + 2 = {3 + math.sqrt(2):.3f}")

with open(__file__.replace(".py", ".out"), "w") as fh:
    fh.write("\n".join(OUT) + "\n")

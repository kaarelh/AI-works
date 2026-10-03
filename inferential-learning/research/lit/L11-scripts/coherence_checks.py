"""Sanity checks for memo L11 (justification, reflective equilibrium, coherence).

Run: python3 coherence_checks.py
Everything is exact or brute force; no external dependencies.
"""
from fractions import Fraction as F
from itertools import product, combinations
import random

# ---------------------------------------------------------------------------
# 1. Witness model (C. I. Lewis / Bovens-Hartmann / Olsson style).
#    Propositions R_1..R_n with a prior P over truth assignments.
#    Witness i reports R_i; P(E_i | R_i, rest) = p, P(E_i | not R_i, rest) = q,
#    reports conditionally independent given the assignment.
#    Claim: P(all R_i | all reports) = a_0 / sum_k a_k x^k, x = q/p,
#    where a_k = prior probability that exactly k of the R_i are false.
# ---------------------------------------------------------------------------
def posterior_bruteforce(P, p, q):
    n = len(next(iter(P)))
    num = den = F(0)
    for w, pw in P.items():
        lik = F(1)
        for bit in w:
            lik *= p if bit else q
        den += pw * lik
        if all(w):
            num += pw * lik
    return num / den

def posterior_formula(a, x):
    return a[0] / sum(ak * x**k for k, ak in enumerate(a))

def weights(P):
    n = len(next(iter(P)))
    a = [F(0)] * (n + 1)
    for w, pw in P.items():
        a[n - sum(w)] += pw
    return a

random.seed(0)
for trial in range(200):
    n = 3
    ws = list(product([0, 1], repeat=n))
    raw = [random.randint(1, 20) for _ in ws]
    P = {w: F(r, sum(raw)) for w, r in zip(ws, raw)}
    p, q = F(random.randint(5, 9), 10), F(random.randint(1, 5), 10)
    assert posterior_bruteforce(P, p, q) == posterior_formula(weights(P), q / p)
print("[1] posterior formula a0 / sum a_k x^k matches brute force (200 random cases)")

# ---------------------------------------------------------------------------
# 2. Reliability-dependent ranking flip (the Bovens-Hartmann phenomenon).
#    Two information sets with the SAME prior probability of the conjunction
#    (a_0 = 0.1).  Which yields the higher posterior depends on reliability.
# ---------------------------------------------------------------------------
def exchangeable(a, n=3):
    """Exchangeable joint distribution with weight vector a (a[k] = P(exactly k false))."""
    from math import comb
    P = {}
    for w in product([0, 1], repeat=n):
        k = n - sum(w)
        P[w] = a[k] / comb(n, k)
    return P

A = [F(1, 10), F(3, 10), F(3, 10), F(3, 10)]
B = [F(1, 10), F(2, 10), F(6, 10), F(1, 10)]
PA, PB = exchangeable(A), exchangeable(B)
for x in [F(1, 10), F(3, 10), F(49, 100), F(51, 100), F(7, 10), F(9, 10)]:
    pa, pb = posterior_formula(A, x), posterior_formula(B, x)
    print(f"    x=q/p={float(x):.2f}: post(A)={float(pa):.4f} post(B)={float(pb):.4f} -> {'A' if pa > pb else 'B'} higher")
# difference of denominators: sum (b_k - a_k) x^k = -0.1 x (2x-1)(x-1)
def marg(P, i):
    return sum(pw for w, pw in P.items() if w[i])
def conj(P):
    return sum(pw for w, pw in P.items() if all(w))
def disj(P):
    return sum(pw for w, pw in P.items() if any(w))
for name, P in [("A", PA), ("B", PB)]:
    shog = conj(P) / (marg(P, 0) * marg(P, 1) * marg(P, 2))
    olss = conj(P) / disj(P)
    print(f"    set {name}: P(R_i)={float(marg(P,0)):.4f}  Shogenji={float(shog):.4f}  Olsson-Glass overlap={float(olss):.4f}")
print("[2] same prior of conjunction; posterior ranking flips at x = 1/2; "
      "both standard measures rank A above B at every reliability")

# ---------------------------------------------------------------------------
# 3. Zero individual credibility (p = q): agreement gives no boost at all.
# ---------------------------------------------------------------------------
assert posterior_formula(A, F(1)) == A[0] and posterior_formula(B, F(1)) == B[0]
print("[3] p = q  =>  posterior = prior, whatever the coherence of the set")

# ---------------------------------------------------------------------------
# 4. Independence vs common cause.  m witnesses all assert the SAME claim R
#    (a maximally coherent information set), prior P(R) = 0.3, p = 0.8, q = 0.4.
#    Independent witnesses: posterior -> 1.  Witnesses that all copy one source:
#    posterior stuck at the one-witness value.
# ---------------------------------------------------------------------------
pr, p, q = F(3, 10), F(8, 10), F(4, 10)
for m in [1, 2, 5, 10, 20]:
    indep = pr * p**m / (pr * p**m + (1 - pr) * q**m)
    copied = pr * p / (pr * p + (1 - pr) * q)
    print(f"    m={m:2d}: independent {float(indep):.4f}   common-source {float(copied):.4f}")
print("[4] agreement amplifies only under conditional independence")

# ---------------------------------------------------------------------------
# 5. Eliminative (hard) coherence: conditioning on 'coherent' multiplies the
#    posterior of every coherent hypothesis by the same factor 1/P(Coh).
#    Truth (coherent) never loses; ratios among coherent rivals are unchanged.
# ---------------------------------------------------------------------------
prior = {"h*": F(1, 5), "h*+F (coherent fallacy)": F(1, 5), "h*+tonk": F(3, 5)}
coh = {"h*": True, "h*+F (coherent fallacy)": True, "h*+tonk": False}
Z = sum(v for h, v in prior.items() if coh[h])
post = {h: (v / Z if coh[h] else F(0)) for h, v in prior.items()}
assert post["h*"] / post["h*+F (coherent fallacy)"] == prior["h*"] / prior["h*+F (coherent fallacy)"]
print("[5] hard coherence: truth's posterior", prior["h*"], "->", post["h*"],
      "; odds vs coherent fallacy unchanged")

# ---------------------------------------------------------------------------
# 6. Klein-Warfield: adding a proposition can raise 'coherence' but can never
#    raise the probability of the conjunction.  (Monotonicity check.)
# ---------------------------------------------------------------------------
P3 = exchangeable(A)
p12 = sum(pw for w, pw in P3.items() if w[0] and w[1])
p123 = conj(P3)
assert p123 <= p12
print("[6] P(R1&R2&R3) <= P(R1&R2):", float(p123), "<=", float(p12))

# ---------------------------------------------------------------------------
# 7. Thagard's coherence problem (Thagard & Verbeurgt 1998 formulation):
#    positive constraint satisfied iff both accepted or both rejected;
#    negative constraint satisfied iff exactly one accepted.  Objective is
#    invariant under complementing the accepted set, so without a 'data
#    priority' element the optimum never decides WHICH side is accepted.
# ---------------------------------------------------------------------------
def coh_value(acc, pos, neg):
    s = 0
    for (i, j, w) in pos:
        s += w if (i in acc) == (j in acc) else 0
    for (i, j, w) in neg:
        s += w if (i in acc) != (j in acc) else 0
    return s

random.seed(1)
nel = 8
els = list(range(nel))
pairs = list(combinations(els, 2))
random.shuffle(pairs)
pos = [(i, j, random.randint(1, 5)) for (i, j) in pairs[:10]]
neg = [(i, j, random.randint(1, 5)) for (i, j) in pairs[10:16]]
best, argbest = -1, []
for mask in range(2**nel):
    acc = {e for e in els if mask >> e & 1}
    v = coh_value(acc, pos, neg)
    assert v == coh_value(set(els) - acc, pos, neg)
    if v > best:
        best, argbest = v, [acc]
    elif v == best:
        argbest.append(acc)
assert all((set(els) - a) in argbest for a in argbest)
print(f"[7] random instance: {len(argbest)} optimal partitions, closed under complement;"
      " a fixed-accepted EVIDENCE node is needed to break the symmetry")

# ---------------------------------------------------------------------------
# 8. Gambler's-fallacy rule is VALID in an anti-persistent stationary chain
#    with fair marginals (switch prob 0.6): P(T | last flip H) = 0.6 > 1/2.
# ---------------------------------------------------------------------------
s = F(6, 10)
# stationary distribution of a symmetric 2-state chain is (1/2, 1/2)
pi_H = F(1, 2)
assert pi_H * (1 - s) + (1 - pi_H) * s == pi_H
print("[8] symmetric switching chain: marginal P(H) = 1/2, P(T | prev H) =", float(s))

# ---------------------------------------------------------------------------
# 9. Miller & Sanjurjo (2018): for n = 4 fair flips, the expected proportion of
#    heads among flips immediately following a head (over sequences where it is
#    defined) is 17/42 < 1/2.  'The gambler's intuition' is right about THIS
#    finite-sample statistic; the experts' 1985 benchmark of 1/2 was wrong for it.
# ---------------------------------------------------------------------------
def ms_expectation(n):
    tot, cnt = F(0), 0
    for seq in product("HT", repeat=n):
        after = [seq[i + 1] for i in range(n - 1) if seq[i] == "H"]
        if after:
            tot += F(after.count("H"), len(after))
            cnt += 1
    return tot / cnt
for n in [3, 4, 5, 10]:
    print(f"    n={n}: E[prop H after H] = {ms_expectation(n)} = {float(ms_expectation(n)):.4f}")
assert ms_expectation(4) == F(17, 42)
print("[9] Miller-Sanjurjo n=4 value 17/42 confirmed")

# ---------------------------------------------------------------------------
# 10. Rule of proof vs premise (Smiley; Carroll).  Necessitation phi/Box phi is
#     sound on EVERY Kripke frame, but the axiom schema p -> Box p is valid on a
#     frame iff R is a subset of the identity (each world sees at most itself).
#     Brute force over all frames with <= 3 worlds and all valuations of p.
# ---------------------------------------------------------------------------
def frames(n):
    pairs = [(i, j) for i in range(n) for j in range(n)]
    for mask in range(2 ** len(pairs)):
        yield n, {pairs[k] for k in range(len(pairs)) if mask >> k & 1}

count = 0
for n in [1, 2, 3]:
    for _, R in frames(n):
        valid = True
        for vmask in range(2 ** n):
            V = {w for w in range(n) if vmask >> w & 1}
            for w in range(n):
                box_p = all((v in V) for (u, v) in R if u == w)
                if (w in V) and not box_p:
                    valid = False
        assert valid == all(u == v for (u, v) in R)
        # necessitation preserves validity on every frame: if p valid (V = all worlds) then Box p true everywhere
        assert all(all(v in set(range(n)) for (u, v) in R if u == w) for w in range(n))
        count += 1
print(f"[10] {count} frames: p->Box p valid iff R subset of identity; necessitation rule sound on all frames")

# ---------------------------------------------------------------------------
# 11. Carroll's regress in a toy engine.  Sentences are atoms or implications.
#     Closure under an engine E (set of rule-functions).  With E = {} adding
#     any number of conditional premises derives nothing new; with E = {MP} a
#     single-instance rule A,B / Z is simulated by the premise A->(B->Z), but
#     the premise version derives strictly more (the conditional itself and what
#     follows from it as an object).
# ---------------------------------------------------------------------------
def imp(a, b):
    return ("->", a, b)

def closure(S, rules, max_rounds=20):
    S = set(S)
    for _ in range(max_rounds):
        new = set()
        for r in rules:
            new |= r(S)
        if new <= S:
            return S
        S |= new
    return S

def MP(S):
    return {x[2] for x in S if isinstance(x, tuple) and x[0] == "->" and x[1] in S}

def single_rule(prem, concl):
    return lambda S: {concl} if set(prem) <= S else set()

A, B, Z, C = "A", "B", "Z", "C"
tortoise_store = {A, B, imp(A, imp(B, Z)), imp(imp(A, imp(B, Z)), imp(A, imp(B, Z)))}
assert closure(tortoise_store, []) == tortoise_store          # no engine: nothing follows
assert Z in closure({A, B, imp(A, imp(B, Z))}, [MP])          # one built-in rule suffices
cA = imp(A, imp(B, Z))
S0 = {A, B, imp(cA, C)}                                        # background mentions the conditional as an object
rule_version = closure(S0, [MP, single_rule([A, B], Z)])
premise_version = closure(S0 | {cA}, [MP])
assert rule_version <= premise_version and C in premise_version and C not in rule_version
print("[11] empty engine: conditionals inert; {MP}: rule A,B/Z simulated by premise; premise version strictly stronger (derives C)")

# ---------------------------------------------------------------------------
# 12. Imitation absorbs systematic errors (formal Cohen convergence).  Two-part
#     MDL: H0 = target calculus + noise; H1 = target + fallacy F as a rule.
#     Humans use F on a fraction phi of steps; alternatives per step M.
#     Code length difference grows linearly in n, so for ANY fixed simplicity
#     weight lambda, F is eventually absorbed: n* ~ lambda*K(F)/(H(phi)+phi*log2 M).
# ---------------------------------------------------------------------------
from math import log2
def H2(x):
    return 0.0 if x in (0, 1) else -(x * log2(x) + (1 - x) * log2(1 - x))
def excess_bits_H0(n, phi, M):
    # H0 must code F-steps as noise: best noise rate = phi; per-step cost H(phi) + phi*log2(M)
    return n * (H2(phi) + phi * log2(M))
for (lam, KF, phi, M) in [(1, 200, 0.01, 50), (10, 200, 0.01, 50), (10, 200, 0.001, 50)]:
    nstar = lam * KF / (H2(phi) + phi * log2(M))
    print(f"    lambda={lam:3d} K(F)={KF} bits phi={phi}: F absorbed after n* ~ {nstar:,.0f} human steps")
print("[12] fixed lambda => every systematic (compressible, frequent) error is eventually learned by imitation-MDL")

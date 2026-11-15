# Checks for Section 2 of research/prove-c/property-batch.md (Pr3).  Pure Python, exact binomial sums.
# Taken over from research/prove-b/code/property-batch_pr3.py (earlier worker); only the labels were corrected.
# Run:  python3 property-batch_pr3.py > property-batch_pr3.out
import math, random
from math import comb, log, sqrt, exp

def kl(p, q):
    if p == q: return 0.0
    if q <= 0.0 or q >= 1.0: return float('inf')
    s = 0.0
    if p > 0: s += p*log(p/q)
    if p < 1: s += (1-p)*log((1-p)/(1-q))
    return s

# (1) exact coverage: Pr[ kl(Qhat || q) > ln(2/eps)/N ] <= eps  (two-sided Chernoff)
worst = 0.0
for N in (5, 20, 100, 400):
    for q in (0.001, 0.01, 0.05, 0.2, 0.5, 0.8, 0.97):
        for eps in (0.3, 0.05, 0.001):
            a = log(2/eps)/N
            pr = sum(comb(N, k)*q**k*(1-q)**(N-k) for k in range(N+1) if kl(k/N, q) > a)
            worst = max(worst, pr/eps)
print("(1) Lemma 2.1 / Theorem 2.3: max over grid of Pr[kl(Qhat||q) > ln(2/eps)/N] / eps =", round(worst, 4), "(must be <= 1)")

# (2) inequality kl(p||q) >= (p-q)^2 / (2 max(p,q)) and Pinsker kl >= 2 (p-q)^2 on a grid
bad = 0; G = 400
for i in range(G+1):
    for j in range(1, G):
        p, q = i/G, j/G
        k = kl(p, q)
        if k < (p-q)**2/(2*max(p, q)) - 1e-12 or k < 2*(p-q)**2 - 1e-12: bad += 1
print("(2) Lemma 2.2: violations of kl >= (p-q)^2/(2max(p,q)) and of Pinsker on a 401x399 grid:", bad)

# (3) consequences of kl(phat||q) <= a and kl(phat||q') <= a  (Corollaries 2.4 and 2.6):
#     |q-q'| <= sqrt(2a),  |q-q'| <= 2 sqrt(2 a min(q,1-q)) + 6a ; phat=0 => q <= 1-exp(-a) <= a   (Corollary 2.6(ii),(iii))
random.seed(1); bad = 0; trials = 0
for _ in range(200000):
    ph, q, q2, a = random.random(), random.random(), random.random(), 10**random.uniform(-4, 0)
    if random.random() < 0.3: ph = 0.0
    if kl(ph, q) <= a and kl(ph, q2) <= a:
        trials += 1
        m = min(q, 1-q)
        if abs(q-q2) > sqrt(2*a) + 1e-12 or abs(q-q2) > 2*sqrt(2*a*m) + 6*a + 1e-12: bad += 1
        if ph == 0.0 and q > a + 1e-12: bad += 1
print("(3) random triples satisfying both kl constraints:", trials, " violations of Corollary 2.6(ii),(iii):", bad)

# (4) joint statement of the draft (two-sided Hoeffding at delta AND one-sided 'never occurred' at delta):
#     exact failure probability for one test of weight pi, as a multiple of pi*delta
worst = 0.0; arg = None
for N in (1, 2, 3, 5, 10, 30, 100, 300, 1000):
    for pd in (0.905, 0.5, 0.2, 0.05, 0.01, 0.001):   # pd = pi(R)*delta
        tol = sqrt(log(2/pd)/(2*N)); q0 = log(1/pd)/N
        for i in range(1, 400):
            q = i/400*min(1.0, 3*max(tol, q0))
            if q >= 1: continue
            pr = 0.0
            for k in range(N+1):
                ph = k/N
                if abs(ph-q) > tol or (k == 0 and q > q0):
                    pr += comb(N, k)*q**k*(1-q)**(N-k)
            if pr/pd > worst: worst, arg = pr/pd, (N, pd, round(q, 5))
print("(4) Theorem 2.5(c): max exact failure probability of the joint statement / (pi*delta) =", round(worst, 4), "at (N, pi*delta, q) =", arg)

# (5) the same maximum restricted to pi*delta <= 0.2 (the practical range)
worst = 0.0; arg = None
for N in (1, 2, 3, 5, 10, 30, 100, 300, 1000, 3000):
    for pd in (0.2, 0.1, 0.05, 0.01, 0.001, 1e-6):
        tol = sqrt(log(2/pd)/(2*N)); q0 = log(1/pd)/N
        for i in range(1, 800):
            q = i/800*min(1.0, 3*max(tol, q0))
            if q >= 1: continue
            pr = 0.0
            for k in range(N+1):
                ph = k/N
                if abs(ph-q) > tol or (k == 0 and q > q0):
                    pr += exp(math.lgamma(N+1)-math.lgamma(k+1)-math.lgamma(N-k+1) + k*log(q) + (N-k)*log(1-q))
            if pr/pd > worst: worst, arg = pr/pd, (N, pd, round(q, 6))
print("(5) same, restricted to pi*delta <= 0.2: max ratio =", round(worst, 4), "at", arg)

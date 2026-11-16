# Adversary's checks of Section 2 of research/prove-c/property-batch.md (Pr1, Pr3).
# Exact binomial computations; pure Python.  Run:  python3 property-batch_attack_sec2.py > property-batch_attack_sec2.out
import math
from math import log, sqrt, exp, lgamma

def kl(p, q):
    if p == q: return 0.0
    if q <= 0.0 or q >= 1.0: return float('inf')
    s = 0.0
    if p > 0: s += p*log(p/q)
    if p < 1: s += (1-p)*log((1-p)/(1-q))
    return s

def pmf(N, q):
    """exact binomial probabilities (floats, via lgamma)"""
    if q <= 0.0: return [1.0] + [0.0]*N
    if q >= 1.0: return [0.0]*N + [1.0]
    lq, l1 = log(q), log(1-q)
    return [exp(lgamma(N+1) - lgamma(k+1) - lgamma(N-k+1) + k*lq + (N-k)*l1) for k in range(N+1)]

# ---------------------------------------------------------------- (A) Lemma 2.1 and Theorem 2.3 for one test
worst2, worstU, worstL, arg2 = 0.0, 0.0, 0.0, None
for N in [1, 2, 3, 5, 8, 13, 21, 50, 120, 400]:
    for iq in range(1, 200):
        q = iq/200.0
        P = pmf(N, q)
        for eps in [0.9, 0.5, 0.2, 0.1, 0.03, 0.01, 1e-3, 1e-5]:
            a = log(2/eps)/N
            two = sum(P[k] for k in range(N+1) if kl(k/N, q) > a)
            up = sum(P[k] for k in range(N+1) if k/N > q and kl(k/N, q) > a)
            lo = sum(P[k] for k in range(N+1) if k/N < q and kl(k/N, q) > a)
            if two/eps > worst2: worst2, arg2 = two/eps, (N, q, eps)
            worstU = max(worstU, up/(eps/2)); worstL = max(worstL, lo/(eps/2))
print("(A) Lemma 2.1 / Theorem 2.3, one test, exact: max of Pr[kl(Qhat||q) > ln(2/eps)/N]/eps =", f"{worst2:.4f}", "at (N, q, eps) =", arg2)
print("    one-sided events against eps/2: max ratio upper", f"{worstU:.4f}", " lower", f"{worstL:.4f}", " (all must be <= 1)")

# ---------------------------------------------------------------- (B) Lemma 2.2 on a grid with the boundary
bad = 0; G = 600
for i in range(G+1):
    p = i/G
    for j in range(1, G):
        q = j/G
        k = kl(p, q)
        if k < 2*(p-q)**2 - 1e-12: bad += 1
        if k < (p-q)**2/(2*max(p, q)) - 1e-12: bad += 1
print("(B) Lemma 2.2 (i), (ii) on a", G+1, "x", G-1, "grid including p = 0 and p = 1: violations", bad)

# ---------------------------------------------------------------- (C) Corollary 2.4(b), (c) and 2.6(ii), (iii) at the extreme points
def kl_interval(p, a):
    """the interval {q : kl(p||q) <= a}, by bisection"""
    lo, hi = 0.0, p
    for _ in range(200):
        mid = (lo+hi)/2
        if kl(p, mid) <= a: hi = mid
        else: lo = mid
    qlo = hi
    lo, hi = p, 1.0
    for _ in range(200):
        mid = (lo+hi)/2
        if kl(p, mid) <= a: lo = mid
        else: hi = mid
    return qlo, lo
v24 = v26 = v26iii = 0; worst_ratio = 0.0; cnt = 0
for ip in range(0, 201):
    p = ip/200.0
    for a in [1e-4, 1e-3, 0.01, 0.03, 0.1, 0.3, 1.0, 3.0]:
        qlo, qhi = kl_interval(p, a)
        cnt += 1
        for q in (qlo, qhi):
            # Corollary 2.4(a), (b)
            if abs(p-q) > sqrt(a/2) + 1e-9: v24 += 1
            if q > p + sqrt(2*a*p) + 2*a + 1e-9 or q < p - sqrt(2*a*p) - 1e-9: v24 += 1
            if sqrt(p) > sqrt(q) + sqrt(2*a) + 1e-9: v24 += 1
        if p == 0.0 and qhi > a + 1e-9: v26iii += 1
        # Corollary 2.6(ii): Q and Q' are the two ends, in both orders
        for (q, q2) in ((qlo, qhi), (qhi, qlo)):
            qbar = min(q, 1-q)
            bound = min(sqrt(2*a), 2*sqrt(2*a*qbar) + 6*a)
            if abs(q2-q) > bound + 1e-9: v26 += 1
            if bound > 0: worst_ratio = max(worst_ratio, abs(q2-q)/bound)
print("(C) Corollaries 2.4 and 2.6 at the two ends of {q : kl(phat||q) <= a},", cnt, "pairs (phat, a): violations of 2.4:", v24,
      " of 2.6(ii):", v26, " of 2.6(iii):", v26iii, "; largest |Q'(R)-Q(R)|/bound =", f"{worst_ratio:.4f}")

# ---------------------------------------------------------------- (D) Theorem 2.5(c): the joint statement for one test, exact
def joint_fail(N, eps, q, P=None):
    """Pr[ |Qhat - q| > tol  or  (Qhat = 0 and q > ln(1/eps)/N) ] for one test with pi*delta = eps"""
    t = sqrt(log(2/eps)/(2*N)); qR = log(1/eps)/N
    if P is None: P = pmf(N, q)
    f = sum(P[k] for k in range(N+1) if abs(k/N - q) > t)
    if q > qR and not (abs(0.0 - q) > t): f += P[0]
    return f
def sup_ratio(N, eps):
    """sup over q of joint_fail/eps: a grid in q, refined just above q_R, where the one-sided clause starts to bite"""
    t = sqrt(log(2/eps)/(2*N)); qR = log(1/eps)/N
    cands = [i/400.0 for i in range(1, 400)]
    if qR < 1:
        cands += [min(1.0, qR*(1+1e-9)), min(1.0, qR*1.001), min(1.0, qR*1.01), min(1.0, qR*1.05), min(1.0, qR*1.2)]
        if t < 1: cands += [qR + (t-qR)*j/40.0 for j in range(1, 41) if qR < t]
        # inside (q_R, t] the failure probability is Pr[S > N(q+t)] + (1-q)^N; the first term jumps down when N(q+t)
        # passes an integer j, so the supremum is at q -> q_R or just below a jump point q = j/N - t
        for j in range(0, N+1):
            qj = j/N - t
            if qR < qj <= t: cands += [qj - 1e-12, qj*(1-1e-9)]
    best, arg = 0.0, None
    for q in cands:
        if not (0 < q < 1): continue
        r = joint_fail(N, eps, q)/eps
        if r > best: best, arg = r, q
    return best, arg
print("(D) Theorem 2.5(c), one test with pi*delta = eps; exact failure probability of the joint statement divided by eps (sup over q):")
r, _ = sup_ratio(1, 0.905); print("    the file's counterexample N = 1, eps = 0.905, q = 0.2: failure probability", f"{joint_fail(1, 0.905, 0.2):.4f}", "> eps; sup ratio", f"{r:.4f}")
Ns = [1, 2, 3, 4, 5, 6, 8, 10, 13, 17, 22, 30, 40, 60, 100, 200, 400, 1000, 3000]
overall = {}
for eps in [0.9, 0.8, 0.7, 0.6, 0.5, 0.45, 0.4, 0.35, 0.3, 0.25, 0.2, 0.1, 0.05, 0.01, 1e-3, 1e-5, 1e-8]:
    best, arg = 0.0, None
    for N in Ns:
        r, q = sup_ratio(N, eps)
        if r > best: best, arg = r, (N, round(q, 6))
    overall[eps] = best
    print(f"    eps = {eps:<8g} max over N in grid of sup_q ratio = {best:.4f} at (N, q) = {arg}   (proved: <= 1.5; the draft needs <= 1)")
# the largest eps for which no N in a dense range gives a ratio above 1
def worst_over_N(eps, Nmax=400):
    return max(sup_ratio(N, eps)[0] for N in range(1, Nmax+1))
viol = [(e/200.0) for e in range(1, 77) if worst_over_N(e/200.0, 150) > 1.0]
print("    every eps = j/200 <= 0.38 with every N <= 150: values of eps with a ratio above 1:", viol if viol else "none")
# the set of eps with a violation is not an interval (each small N has its own window); locate the smallest one
first = None
for j in range(2500, 4001, 5):
    e = j/10000.0
    hit = [(N, round(sup_ratio(N, e)[0], 4)) for N in range(1, 41) if sup_ratio(N, e)[0] > 1.0]
    if hit: first = (e, hit); break
print("    scan of eps = 0.2500, 0.2505, ..., all N <= 40: the smallest eps with a ratio above 1 is", first)
print("    large N at eps = 0.1: ratio", ", ".join(f"N={N}: {sup_ratio(N, 0.1)[0]:.6f}" for N in [300, 3000, 30000]), " (tends to 1 from below)")

# ---------------------------------------------------------------- (E) Remark 2.7(4): the largest of M independent deviations
print("(E) Remark 2.7(4): M independent tests of probability 1/2; exact median of max_R |Qhat_N(R) - 1/2| against sqrt(ln M/(2N)):")
for N in [100, 1000]:
    P = pmf(N, 0.5)
    for M in [10, 10**3, 10**6, 10**12]:
        # smallest t on the lattice with Pr[max dev <= t] >= 1/2
        med = None
        for d in range(0, N//2 + 1):
            within = sum(P[k] for k in range(N+1) if abs(k/N - 0.5) <= d/N + 1e-12)
            if within <= 0: continue
            if M*log(within) >= log(0.5): med = d/N; break
        print(f"    N = {N:5d}, M = {M:<14d} median = {med:.4f}   sqrt(ln M/(2N)) = {sqrt(log(M)/(2*N)):.4f}   ratio {med/sqrt(log(M)/(2*N)):.3f}")

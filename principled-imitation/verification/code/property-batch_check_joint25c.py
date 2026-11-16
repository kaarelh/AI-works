# Referee's check for Theorem 2.5(c) of research/prove-c/property-batch.md: for which eps = pi(R)*delta does the joint statement
# of the draft ("|Qhat - Q| <= tol for all R, and Q(R) <= ln(1/(pi delta))/N for all R that never occurred", at confidence 1 - delta)
# fail for a single test?  Exact binomial probabilities.  Pure Python 3.
# Run:  python3 property-batch_check_joint25c.py > property-batch_check_joint25c.out
from math import log, sqrt, comb
def joint_fail(N, eps, q):
    tol = sqrt(log(2/eps)/(2*N)); qR = log(1/eps)/N; f = 0.0
    for k in range(N+1):
        if abs(k/N - q) > tol or (k == 0 and q > qR): f += comb(N, k)*q**k*(1-q)**(N-k)
    return f
def sup_ratio(eps):
    best = (0.0, None)
    for N in list(range(1, 31)) + [40, 60, 100, 200]:
        tol = sqrt(log(2/eps)/(2*N)); qR = log(1/eps)/N
        cands = {j/2000 for j in range(2001)}
        for base in (qR, tol, 1 - tol):
            for d in (1e-9, 1e-6, 1e-4, 1e-3, 1e-2):
                for sgn in (-1, 1):
                    x = base + sgn*d
                    if 0 <= x <= 1: cands.add(x)
        if N > 30: cands = {c for c in cands if c <= min(1.0, 3*max(qR, tol))}
        for q in cands:
            f = joint_fail(N, eps, q)/eps
            if f > best[0]: best = (f, (N, round(q, 5)))
    return best
print("sup over N (1..30, 40, 60, 100, 200) and q (grid of 2001 points and points next to the thresholds) of Pr[joint statement fails for one test]/eps:")
first = None; largest = (0.0, None)
for e_i in range(2, 100, 2):
    eps = e_i/100; r, arg = sup_ratio(eps)
    if r > 1 and first is None: first = eps
    if r > largest[0]: largest = (r, (eps,) + arg)
    if e_i % 10 == 0 or 30 <= e_i <= 46: print(f"  eps = {eps:.2f}: {r:.4f} at (N, q) = {arg}")
print(f"smallest eps on the grid 0.02, 0.04, ... for which the ratio exceeds 1: {first}; largest ratio found: {largest[0]:.4f} at (eps, N, q) = {largest[1]} (the file proves <= 1.5)")
# one explicit instance, by hand: N = 4, eps = 0.34, q just above ln(1/eps)/N
N, eps = 4, 0.34; q = log(1/eps)/N*(1 + 1e-9); tol = sqrt(log(2/eps)/(2*N))
p0 = (1-q)**4; p34 = 4*q**3*(1-q) + q**4
print(f"instance N = 4, one test of weight 1, delta = 0.34, Q(R) = {q:.4f}: tol = {tol:.4f}; Pr[R never occurs] = {p0:.4f} (then the one-sided claim fails);")
print(f"  Pr[R occurs 3 or 4 times] = {p34:.4f} (then |Qhat - Q| >= {0.75 - q:.4f} > tol); total {p0 + p34:.4f} > delta = 0.34")

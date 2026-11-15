# Checks for Pr4 (key: property-batch): Theorems 3.2 (realizable) and 3.3 (oracle inequality) on small finite classes.
import random, math
from math import log, sqrt
random.seed(7)
W = 6          # size of the run space Omega = {0..W-1}
J = 12         # number of hypotheses, weights w_i = 2^-(i+1)
delta = 0.1

def rand_dist(conc=1.0):
    g = [random.gammavariate(conc, 1.0) for _ in range(W)]; s = sum(g); return [x/s for x in g]
def tv(p, q): return 0.5*sum(abs(a-b) for a, b in zip(p, q))
def sample(p, N):
    return random.choices(range(W), weights=p, k=N)

def run(realizable, N, trials):
    fails = 0; ratios = []
    for _ in range(trials):
        H = [rand_dist() for _ in range(J)]
        w = [2.0**-(i+1) for i in range(J)]
        if realizable:
            i0 = random.randrange(J); Q = H[i0]
        else:
            base = H[random.randrange(J)]; noise = rand_dist(0.3); lam = random.choice([0.05, 0.2, 0.5])
            Q = [(1-lam)*a + lam*b for a, b in zip(base, noise)]
        xs = sample(Q, N); emp = [xs.count(o)/N for o in range(W)]
        A = [[[o for o in range(W) if H[i][o] > H[j][o]] for j in range(J)] for i in range(J)]   # Yatracos sets
        mass = lambda p, S: sum(p[o] for o in S)
        if realizable:
            tol = lambda i, j: sqrt(log(2/(min(w[i], w[j])*delta))/(2*N))
            adm = [i for i in range(J) if all(mass(H[i], A[i][j]) - mass(emp, A[i][j]) <= tol(i, j) for j in range(J) if j != i)]
            if not adm: fails += 1; continue          # can only happen off the good event
            est = adm[0]                               # highest weight = smallest index
            bound = sqrt((2*log(1/w[i0]) + 2*log(2/delta))/N)
            err = tv(H[est], Q)
            if not (w[est] >= w[i0] and err <= 2*tol(est, i0) + 1e-12 and err <= bound + 1e-12): fails += 1
            ratios.append(err/bound)
        else:
            r = [sqrt((log(1/w[i]) + 0.5*log(2/delta))/(2*N)) for i in range(J)]
            S = [max(abs(mass(H[i], A[i][j]) - mass(emp, A[i][j])) - r[j] for j in range(J)) for i in range(J)]
            est = min(range(J), key=lambda i: S[i] + r[i])
            bound = min(3*tv(H[i], Q) + 4*r[i] for i in range(J))
            err = tv(H[est], Q)
            if err > bound + 1e-12: fails += 1
            ratios.append(err/bound)
    return fails, sum(ratios)/len(ratios), max(ratios)

for N in (30, 200, 2000):
    f, av, mx = run(True, N, 2000)
    print(f"realizable   N={N:5d}: failures {f}/2000 (allowed {delta:.0%}), mean err/bound {av:.3f}, max {mx:.3f}")
for N in (30, 200, 2000, 20000):
    f, av, mx = run(False, N, 2000)
    print(f"misspecified N={N:5d}: failures {f}/2000 (allowed {delta:.0%}), mean err/bound {av:.3f}, max {mx:.3f}")

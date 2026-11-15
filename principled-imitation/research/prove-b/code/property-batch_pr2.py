# Checks for Pr2 (key: property-batch): Theorem 4.4 (closed form for the memoriser class), 4.1 (hindsight), 4.6 (foresight).
import itertools, random, math
from fractions import Fraction as Fr
random.seed(3)

# ---- (A) brute force over all tables for |X| = m, exact rationals, against the closed form of Theorem 4.4
def brute(m, K, f, S):
    """S: list of distinct training inputs (labels f). Returns M(b | D, x) for a new x, and for an old x."""
    c0 = (1 - Fr(1, 2**K)) / (1 + Fr(1, 2*m))**m
    ev = Fr(1, 2**K); bad_new = Fr(0); x_new = next(x for x in range(m) if x not in S)
    for T in itertools.product((None, 0, 1), repeat=m):       # T[x] = None: x not in the table
        if any(T[x] != f[x] for x in S): continue
        wt = c0 * Fr(1, 4*m)**sum(t is not None for t in T)
        ev += wt
        if T[x_new] is None: bad_new += wt
    return bad_new/ev, ev
def closed(m, K, k):
    return Fr(2*m, 2*m+1) / (1 + Fr((4*m+2)**k, 2**K - 1))
ok = True
for m in (2, 4, 8):
    for K in (2, 7, 15):
        f = [random.randrange(2) for _ in range(m)]
        for k in range(0, m):
            S = random.sample(range(m), k)
            got, ev = brute(m, K, f, S)
            ok &= (got == closed(m, K, k)) and (ev == Fr(1, 2**K) + (1 - Fr(1, 2**K))*Fr(1, (4*m+2)**k))
print("(A) closed form of Theorem 4.4 equals brute-force enumeration (exact rationals), m in {2,4,8}:", ok)

# ---- (B) the numbers: predictive probability of violating R at a fresh uniform input
def V(m, K, k): return float(Fr(m-k, m) * Fr(2*m, 2*m+1) / (1 + Fr((4*m+2)**k, 2**K - 1)))
m, K = 2**20, 1000
b = math.log2(4*m+2); nstar = int((K-2)//b)
print(f"(B) m=2^20, K={K}: bits per pair log2(4m+2)={b:.3f}, threshold n*=floor((K-2)/b)={nstar}")
print("    n : V(D_n) with n distinct inputs")
for n in (0, 10, 30, nstar-1, nstar, nstar+1, nstar+2, nstar+3, nstar+5, 60):
    print(f"    {n:3d} : {V(m, K, n):.6g}")

# ---- (C) adding the fair coin with prior weight gamma (Proposition 4.9): exact V
def V_coin(m, K, n, gamma):      # n distinct inputs; class weights scaled by (1-gamma), coin has weight gamma
    mem = (1-gamma)*(1-2.0**-K)*(4*m+2.0)**-n; hum = (1-gamma)*2.0**-K; coin = gamma*2.0**-n
    return (m-n)/m*(2*m/(2*m+1))*mem/(mem+hum+coin)
print("(C) same class plus a fair coin of prior weight 2^-20:", [f"{V_coin(m, K, n, 2.0**-20):.2e}" for n in (0, 1, 2, 3, 5)])

# ---- (D) hindsight bound (Theorem 4.1) on random finite classes closed under conditioning
worst = 0.0
for _ in range(300):
    nx, ny, J = 4, 4, 5
    Rset = [[random.random() < 0.6 for _ in range(ny)] for _ in range(nx)]
    for x in range(nx): Rset[x][random.randrange(ny)] = True
    def rk():
        k = [[random.gammavariate(0.5, 1) for _ in range(ny)] for _ in range(nx)]
        return [[v/sum(row) for v in row] for row in k]
    base = [rk() for _ in range(J)]
    def cond(k):
        out = []
        for x in range(nx):
            a = sum(k[x][y] for y in range(ny) if Rset[x][y])
            out.append([k[x][y]/a if Rset[x][y] else 0.0 for y in range(ny)])
        return out
    C = random.choice([2.0, 8.0, 64.0])
    hyps = base + [cond(k) for k in base]
    wts = [1/(J*(1+1/C))]*J + [1/(J*(1+1/C))/C]*J      # w(phi(nu)) = w(nu)/C ; phi(cond) = cond
    # preimage of cond_i is {base_i, cond_i}: total weight w(cond_i)*(C+1), so the constant of (Cl) is C+1
    n = random.randrange(1, 12)
    data = []
    for _ in range(n):
        x = random.randrange(nx); y = random.choice([y for y in range(ny) if Rset[x][y]]); data.append((x, y))
    lik = [math.prod(h[x][y] for x, y in data) for h in hyps]
    ev = sum(w*l for w, l in zip(wts, lik))
    if ev == 0: continue
    lhs = 0.0
    for h, w, l in zip(hyps, wts, lik):
        if l == 0: continue
        A = math.prod(sum(h[x][y] for y in range(ny) if Rset[x][y]) for x, _ in data)
        lhs += w*l/ev/A
    worst = max(worst, lhs/(C+1))
print("(D) hindsight: max over 300 random classes of E_post[1/A_nu(D)] / C_R =", round(worst, 4), "(must be <= 1)")

# ---- (E) foresight inequality (Theorem 4.6): frequency of E_post[(1-V_nu)^-n] > P(D)/(delta M(D))
fails = 0; trials = 4000; delta = 0.1; nx, ny = 6, 3
for _ in range(trials):
    J = 8
    hyps = []
    for _ in range(J):
        hyps.append([[v/s for v in row] for row in [[random.gammavariate(0.4, 1) for _ in range(ny)] for _ in range(nx)] for s in [sum(row)]])
    P = [[0.0]+[v/(row[1]+row[2]) for v in row[1:]] for row in hyps[0]]       # the human never outputs y=0 ("bad")
    hyps[0] = P
    wts = [2.0**-(i+1) for i in range(J)]; wts[0] = 2.0**-J                    # the human has the smallest weight
    mu = [1/nx]*nx; n = random.choice([3, 10, 30])
    xs = random.choices(range(nx), k=n); ys = [random.choices(range(ny), weights=P[x])[0] for x in xs]
    lik = [math.prod(h[x][y] for x, y in zip(xs, ys)) for h in hyps]
    ev = sum(w*l for w, l in zip(wts, lik)); pd = math.prod(P[x][y] for x, y in zip(xs, ys))
    lhs = 0.0
    for h, w, l in zip(hyps, wts, lik):
        Vnu = sum(mu[x]*h[x][0] for x in range(nx))
        lhs += w*l/ev*(1-Vnu)**(-n)
    if lhs > pd/(delta*ev)*(1+1e-9): fails += 1
print(f"(E) foresight: failures {fails}/{trials} (allowed {delta:.0%})")

# Checks for Section 4 of research/prove-c/property-batch.md (Pr2: what the Bayes mixture does with a simple property).
# Pure Python, exact rationals where a statement is an identity.  Run:  python3 property-batch_pr2.py > property-batch_pr2.out
import itertools, random, math
from fractions import Fraction as Fr
random.seed(3)
BAD = 'b'      # the bad answer; BOT = no answer
BOT = None

# ================================================================ (A) Theorem 4.5: memorisers, brute force against the closed form
def memoriser_brute(u, K, f, S, C=None):
    """All partial tables T: {0..u-1} -> {0,1}.  g_T answers T(x) on dom T and BAD elsewhere, weight c0 (4u)^-|T|.
    With C given (Corollary 4.6), g_T has weight c0 (4u)^-|T| C/(C+1) and h_T (no answer outside dom T) has weight c0 (4u)^-|T| /(C+1).
    Data: the pairs (x, f(x)) for x in S.  Returns (evidence M(D), mixture probability of BAD at a new input, posterior weight of never-violators)."""
    c0 = (1 - Fr(1, 2**K)) / (1 + Fr(1, 2*u))**u
    ev = Fr(1, 2**K); bad_new = Fr(0); nonviol = Fr(1, 2**K)
    x_new = next(x for x in range(u) if x not in S)
    for T in itertools.product((None, 0, 1), repeat=u):
        if any(T[x] != f[x] for x in S): continue                      # inconsistent with the data
        size = sum(t is not None for t in T); wt = c0 * Fr(1, 4*u)**size
        ev += wt
        if C is None:
            if T[x_new] is None: bad_new += wt
            if size == u: nonviol += wt
        else:
            if T[x_new] is None: bad_new += wt * Fr(C, C+1)
            nonviol += wt * Fr(1, C+1) + (wt * Fr(C, C+1) if size == u else 0)
    return ev, bad_new/ev, nonviol/ev
def closed_bad(u, K, k):  return Fr(2*u, 2*u+1) / (1 + Fr((4*u+2)**k, 2**K - 1))
def closed_ev(u, K, k):   return Fr(1, 2**K) + (1 - Fr(1, 2**K))*Fr(1, (4*u+2)**k)
ok = True; okC = True; floor_ok = True
for u in (2, 4, 7):
    for K in (2, 7, 15):
        f = [random.randrange(2) for _ in range(u)]
        for k in range(0, u):
            S = random.sample(range(u), k)
            ev, bad, _ = memoriser_brute(u, K, f, S)
            ok &= (bad == closed_bad(u, K, k)) and (ev == closed_ev(u, K, k))
            for C in (1, 4):
                evC, badC, nv = memoriser_brute(u, K, f, S, C)
                okC &= (evC == closed_ev(u, K, k)) and (badC == Fr(C, C+1)*closed_bad(u, K, k))
                floor_ok &= (nv >= Fr(1, C+1)) and (badC <= 1 - Fr(1, C+1))
print("(A) Theorem 4.5(a),(b): closed forms equal brute-force enumeration over all 3^u tables (exact rationals), u in {2,4,7}:", ok)
print("    Corollary 4.6: closed class with constant C_R = C+1, C in {1,4}: predictive value = C/(C+1) x (Theorem 4.5):", okC,
      "; never-violators have posterior weight >= 1/C_R and the violation probability is <= 1 - 1/C_R:", floor_ok)

# ================================================================ (B) the numbers of Theorem 4.5(c),(d)
def V(u, K, k): return float(Fr(u-k, u) * closed_bad(u, K, k))
u, K = 2**20, 1000
b = math.log2(4*u+2); nstar = int((K-2)//b)
print(f"(B) u=2^20, K={K}: bits per pair log2(4u+2) = {b:.4f}; (K-2)/bits = {(K-2)/b:.2f}")
print("    k (distinct inputs seen) : V = probability that the mixture violates R at a fresh uniform input")
for k in (0, 1, 10, 30, 44, 45, 46, 47, 48, 50, 60):
    print(f"    {k:3d} : {V(u, K, k):.6g}")
print(f"    lower bound (3/4)(10/11)(3/4) = {0.75*10/11*0.75:.4f} of Theorem 4.5(d) holds for k <= min(u/4, (K-2)/bits): min over k<= {nstar} of V = {min(V(u,K,k) for k in range(nstar+1)):.6f}")
print(f"    upper bound 2^K (4u+2)^-k of Theorem 4.5(e) at k=47: {2.0**K*(4*u+2.0)**-47:.3g}")

# ================================================================ (C) Proposition 4.10: memorisers plus one fair coin, exact
def coin_brute(u, K, f, xs, gamma):
    """Class: (1-gamma) x memoriser class, plus the fair coin on {0,1} with weight gamma.  xs: list of inputs (repeats allowed)."""
    S = set(xs); ev, bad, _ = memoriser_brute(u, K, f, S)
    mem_ev = (1-gamma)*ev; coin_ev = gamma*Fr(1, 2**len(xs))
    return (1-gamma)*ev*bad / (mem_ev + coin_ev)
def coin_closed(u, K, n, k, gamma):
    mem = (1-gamma)*(1-Fr(1, 2**K))*Fr(1, (4*u+2)**k); hum = (1-gamma)*Fr(1, 2**K); coin = gamma*Fr(1, 2**n)
    return Fr(2*u, 2*u+1)*mem/(mem+hum+coin)
ok = True
for u_ in (3, 5):
    f = [random.randrange(2) for _ in range(u_)]
    for _ in range(20):
        n = random.randrange(0, 5); xs = [random.randrange(u_) for _ in range(n)]
        if len(set(xs)) == u_: continue
        g = Fr(1, random.choice([2, 16, 1024]))
        ok &= coin_brute(u_, 6, f, xs, g) == coin_closed(u_, 6, n, len(set(xs)), g)
print("(C) Proposition 4.10: closed form equals brute force (exact rationals):", ok)
gam = Fr(1, 2**20)
print("    u=2^20, K=1000, coin of prior weight 2^-20, n distinct inputs: V =",
      [f"{float(Fr(u-n, u)*coin_closed(u, K, n, n, gam)):.3g}" for n in (0, 1, 2, 3, 5)])
print("    bound ((1-gamma)/gamma)(2u+1)^-n of Proposition 4.10:", [f"{float((1-gam)/gam)*(2*u+1.0)**-n:.3g}" for n in (0, 1, 2, 3, 5)])

# ================================================================ (D) Theorem 4.2 and Corollary 4.3 on random classes closed under conditioning
# Hypotheses are semimeasures on Y = {0..ny-1} (deficit = no answer).  nu^R(y|x) = nu(y|x) 1[R] / (1 - v_nu(x)).
def rand_semi(nx, ny):
    k = [[random.gammavariate(0.5, 1) for _ in range(ny+1)] for _ in range(nx)]      # last coordinate: no answer
    return [[v/sum(row) for v in row[:ny]] for row in k]
worst = 0.0; worst_floor = 1.0; worst_jensen = 0.0; cases = 0
for _ in range(400):
    nx, ny, J = 4, 4, 5
    Rset = [[random.random() < 0.6 for _ in range(ny)] for _ in range(nx)]
    for x in range(nx): Rset[x][random.randrange(ny)] = True
    base = [rand_semi(nx, ny) for _ in range(J)]
    def viol(h, x): return sum(h[x][y] for y in range(ny) if not Rset[x][y])
    def cond(h):
        out = []
        for x in range(nx):
            v = viol(h, x)
            out.append([h[x][y]/(1-v) if Rset[x][y] else 0.0 for y in range(ny)] if v < 1 else [0.0]*ny)
        return out
    C = random.choice([1.0, 2.0, 8.0, 64.0])
    hyps = base + [cond(h) for h in base]
    wts = [C/(J*(C+1))]*J + [1/(J*(C+1))]*J            # phi(base_i) = phi(cond_i) = cond_i ; preimage weight = (C+1) w(cond_i)
    CR = C + 1
    n = random.randrange(1, 12); data = []
    for _ in range(n):
        x = random.randrange(nx); y = random.choice([y for y in range(ny) if Rset[x][y]]); data.append((x, y))
    lik = [math.prod(h[x][y] for x, y in data) for h in hyps]
    ev = sum(w*l for w, l in zip(wts, lik))
    if ev == 0: continue
    cases += 1
    lhs = sum(w*l/ev/math.prod(1-viol(h, x) for x, _ in data) for h, w, l in zip(hyps, wts, lik) if l > 0)
    worst = max(worst, lhs/CR)
    jens = sum(w*l/ev*sum(viol(h, x) for x, _ in data) for h, w, l in zip(hyps, wts, lik))
    worst_jensen = max(worst_jensen, jens/math.log(CR))
    post_nonviol = sum(w*l/ev for h, w, l in zip(hyps[J:], wts[J:], lik[J:]))
    worst_floor = min(worst_floor, post_nonviol*CR)
print(f"(D) Theorem 4.2 on {cases} random closed classes of semimeasures: max of E_post[prod(1-v)^-1]/C_R = {worst:.4f} (must be <= 1);")
print(f"    Corollary 4.3(a): max of E_post[sum_i v(x_i)]/ln C_R = {worst_jensen:.4f} (<= 1); (c): min of C_R x posterior weight of never-violators = {worst_floor:.4f} (>= 1)")

# ================================================================ (E) Theorem 4.7: the foresight inequality
# (E1) exact: E[ sum_nu w(nu) nu(D_n) (1-V_nu)^-n / P(D_n) ] <= sum w, by enumeration of all data sets, exact rationals.
def rand_frac_kernel(nx, ny, den=6, allow_deficit=True):
    ker = []
    for _ in range(nx):
        while True:
            row = [Fr(random.randrange(0, den), den*ny//2) for _ in range(ny)]
            s = sum(row)
            if 0 < s <= 1 and (allow_deficit or s == 1): break
        ker.append(row)
    return ker
worstE = Fr(0)
for _ in range(60):
    nx, ny, n = 3, 3, 3
    mu = [Fr(1, 2), Fr(1, 3), Fr(1, 6)]
    hyps = [rand_frac_kernel(nx, ny) for _ in range(4)]
    # the human: never answers y=0 ("bad"), a probability kernel
    P = []
    for _x in range(nx):
        a = Fr(random.randrange(0, 7), 6); P.append([Fr(0), a, 1-a])
    wts = [Fr(1, 2), Fr(1, 4), Fr(1, 8), Fr(1, 16)]
    Vnu = [sum(mu[x]*h[x][0] for x in range(nx)) for h in hyps]
    tot = Fr(0)
    for xs in itertools.product(range(nx), repeat=n):
        for ys in itertools.product(range(ny), repeat=n):
            pd = math.prod(P[x][y] for x, y in zip(xs, ys))
            if pd == 0: continue
            pm = math.prod(mu[x] for x in xs)
            z = Fr(0)
            for h, w, v in zip(hyps, wts, Vnu):
                l = math.prod(h[x][y] for x, y in zip(xs, ys))
                if l > 0: z += w*l/(1-v)**n          # l > 0 on abiding data implies v < 1
            tot += pm*z                               # = pm * pd * (z/pd)
    worstE = max(worstE, tot/sum(wts))
print(f"(E1) Theorem 4.7(a), exact enumeration (3 inputs, 3 answers, n=3, 60 random classes of semimeasures): max of E[Z_n]/sum(w) = {float(worstE):.4f} (must be <= 1)")

# (E2) Monte Carlo: frequency of  sup_n  E_post[(1-V_nu)^-n] M(D_n)/P(D_n) > 1/delta   (time-uniform form), and of the consequence for V(D_n)
fails = 0; fails_V = 0; trials = 4000; delta = 0.1; nx, ny = 6, 3
for _ in range(trials):
    J = 8
    hyps = []
    for _j in range(J):
        rows = [[random.gammavariate(0.4, 1) for _ in range(ny)] for _ in range(nx)]
        hyps.append([[v/sum(row) for v in row] for row in rows])
    P = [[0.0] + [v/(row[1]+row[2]) for v in row[1:]] for row in hyps[0]]          # the human never outputs y=0
    hyps[0] = P
    wts = [2.0**-(i+1) for i in range(J)]; wts[0] = 2.0**-J                         # the human has the smallest weight, K = J
    mu = [1/nx]*nx; nmax = 30
    Vnu = [sum(mu[x]*h[x][0] for x in range(nx)) for h in hyps]
    lik = [1.0]*J; pd = 1.0; bad = False; badV = False
    for n in range(1, nmax+1):
        x = random.randrange(nx); y = random.choices(range(ny), weights=P[x])[0]
        lik = [l*h[x][y] for l, h in zip(lik, hyps)]; pd *= P[x][y]
        ev = sum(w*l for w, l in zip(wts, lik))
        z = sum(w*l*(1-v)**(-n) for w, l, v in zip(wts, lik, Vnu) if l > 0)/pd
        if z > 1/delta*(1+1e-9): bad = True
        Vmix = sum(w*l*v for w, l, v in zip(wts, lik, Vnu))/ev
        if Vmix > (J*math.log(2) + math.log(1/delta))/n + 1e-12: badV = True
    fails += bad; fails_V += badV
print(f"(E2) Theorem 4.7(b),(d), all n <= 30 at once: failures {fails}/{trials} of the inequality, {fails_V}/{trials} of V(D_n) <= (K ln2 + ln(1/delta))/n (allowed {delta:.0%})")

# ================================================================ (F) Proposition 4.8: recognisers nu_S = (f on S, BAD elsewhere), |S| = s
def recog_brute(u, s, K, kset, x_new):
    """Prior: human 2^-K, each nu_S weight (1-2^-K)/C(u,s).  Data: inputs kset (answers f).  Returns (evidence, mixture probability of BAD at x_new)."""
    wS = (1 - Fr(1, 2**K))/math.comb(u, s)
    ev = Fr(1, 2**K); bad = Fr(0)
    for S in itertools.combinations(range(u), s):
        Sset = set(S)
        if not kset <= Sset: continue
        ev += wS
        if x_new not in Sset: bad += wS
    return ev, bad/ev
def recog_closed(u, s, K, k):
    om = Fr(1)
    for i in range(k): om *= Fr(s-i, u-i)
    W = (1 - Fr(1, 2**K))*om
    return Fr(u-s, u-k)*W/(Fr(1, 2**K) + W), Fr(u-s, u)*W/(Fr(1, 2**K) + W)
ok = True
for (u_, s_) in ((8, 2), (8, 4), (10, 5), (12, 3)):
    for K_ in (1, 4, 9):
        for k in range(0, s_+1):
            if k >= u_: continue
            kset = set(range(k)); ev, bad = recog_brute(u_, s_, K_, kset, u_-1 if k <= u_-1 else 0)
            if (u_-1) in kset: continue
            ok &= bad == recog_closed(u_, s_, K_, k)[0]
print("(F) Proposition 4.8: closed form equals brute force over all subsets S (exact rationals):", ok)
print("    violation level against bits per pair, u = 2^16, K = 200, k = n distinct inputs (V exact; 1 - sigma is the level; K/log2(1/sigma) the duration):")
uu = 2**16
for sig_pow in (1, 2, 4):
    ss = uu >> sig_pow
    row = []
    for k in (0, 10, 25, 40, 45, 50, 60, 100, 190, 200, 210):
        row.append(f"{k}:{float(recog_closed(uu, ss, 200, k)[1]):.3f}")
    print(f"    sigma = 2^-{sig_pow} (level {1-2.0**-sig_pow:.4f}, K/bits = {200/sig_pow:.0f}): " + "  ".join(row))
# tightness of Theorem 4.7(c): 1 - V(D_n) against delta^(1/n) (M(D_n)/P(D_n))^(1/n), with P(D_n) = 1
print("    Theorem 4.7(c) in this class, sigma = 1/4, delta = 0.1:  k : 1 - V(D_k)  >=  (delta M(D_k))^(1/k)")
ss = uu >> 2
for k in (5, 20, 50, 90):
    om = Fr(1)
    for i in range(k): om *= Fr(ss-i, uu-i)
    M = Fr(1, 2**200) + (1 - Fr(1, 2**200))*om
    print(f"    {k:3d} : {1-float(recog_closed(uu, ss, 200, k)[1]):.4f}  >=  {(0.1*float(M))**(1/k):.4f}")

# ================================================================ (G) Theorem 4.11: any class of prior weight 2^-c next to the memorisers
ok = True; worst = None
for _ in range(300):
    u_ = random.choice([3, 4, 5]); c = random.choice([1, 3, 6, 10])
    f = [random.randrange(2) for _ in range(u_)]
    k = random.randrange(0, u_); S = set(random.sample(range(u_), k)); x_new = next(x for x in range(u_) if x not in S)
    # the other class H0: random deterministic functions into {0,1,BAD} with random weights of total 1, scaled by 2^-c; one of them is f
    J = 6; funcs = [f] + [[random.choice([0, 1, BAD]) for _ in range(u_)] for _ in range(J-1)]
    raw = [random.random() for _ in range(J)]; tot = sum(raw); w0 = [Fr(int(1e6*r/tot), 10**6) for r in raw]
    a = Fr(1, 4)
    ev = Fr(0); bad = Fr(0)
    for T in itertools.product((None, 0, 1), repeat=u_):
        if any(T[x] != f[x] for x in S): continue
        wt = a*Fr(1, 4*u_)**sum(t is not None for t in T); ev += wt
        if T[x_new] is None: bad += wt
    for g, w_ in zip(funcs, w0):
        if all(g[x] == f[x] for x in S):
            ev += Fr(1, 2**c)*w_
            if g[x_new] == BAD: bad += Fr(1, 2**c)*w_
    lower = Fr(2*u_, 2*u_+1)/(1 + Fr(4, 2**c)*(4*u_)**k)
    ok &= bad/ev >= lower
print("(G) Theorem 4.11: mixture probability of the bad answer at a new input >= (2u/(2u+1))/(1 + 2^(2-c) (4u)^k) on 300 random instances (exact rationals):", ok)

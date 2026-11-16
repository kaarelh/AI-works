# Adversary's checks of Section 4 of research/prove-c/property-batch.md (Pr2: the Bayes mixture and a simple property).
# Independent implementation; exact rational arithmetic and exact enumeration wherever a probability is claimed.
# Pure Python.  Run:  python3 property-batch_attack_pr2.py > property-batch_attack_pr2.out
import math, random, itertools
from fractions import Fraction as Fr
from math import log, log2
random.seed(4711)
B = 'b'          # the bad answer
NONE = None      # "no answer"

# ================================================================ (A) Theorem 4.5 by brute force (all tables), incl. repeated inputs
def tables(u):
    """all partial functions {1..u} -> {0,1} as dicts"""
    for dom_mask in range(1 << u):
        dom = [x for x in range(u) if dom_mask >> x & 1]
        for vals in itertools.product((0, 1), repeat=len(dom)):
            yield dict(zip(dom, vals))

def mem_class(u, wf):
    """H_mem of Theorem 4.5 with w(f) = wf (so K = log2(1/wf)); returns list of (weight, kind, table)"""
    c0 = (1 - wf) / (1 + Fr(1, 2*u))**u
    H = [(wf, 'f', None)]
    for T in tables(u):
        H.append((c0 * Fr(1, 4*u)**len(T), 'g', T))
    return H

def answer_prob(h, f, x, y):
    """probability that hypothesis h answers y at x (deterministic hypotheses)"""
    kind, T = h[1], h[2]
    if kind == 'f': return Fr(int(y == f[x]))
    if kind == 'g': return Fr(int(y == (T[x] if x in T else B)))
    if kind == 'h': return Fr(int(x in T and y == T[x]))            # conditioned memoriser: silent outside its table
    if kind == 'coin': return Fr(1, 2) if y in (0, 1) else Fr(0)
    if kind == 'gd':                                                 # memoriser with default answer h[3]
        return Fr(int(y == (T[x] if x in T else h[3])))
    raise ValueError

def posterior_stats(H, f, data, x):
    """M(D), M_D(b|x), M_D(f(x)|x), posterior total"""
    M = Fr(0); Mb = Fr(0); Mf = Fr(0)
    for h in H:
        lik = h[0]
        for (xi, yi) in data:
            lik *= answer_prob(h, f, xi, yi)
            if lik == 0: break
        if lik == 0: continue
        M += lik; Mb += lik*answer_prob(h, f, x, B); Mf += lik*answer_prob(h, f, x, f[x])
    return M, Mb/M, Mf/M

ok_a = True; ncase = 0
for u in (1, 2, 3, 5):
    for wf in (Fr(1, 2), Fr(1, 3), Fr(1, 1024)):
        H = mem_class(u, wf)
        assert sum(h[0] for h in H) == 1
        for trial in range(6):
            f = [random.randrange(2) for _ in range(u)]
            n = random.randrange(0, u+2)
            xs = [random.randrange(u) for _ in range(n)]                      # inputs may repeat
            data = [(x, f[x]) for x in xs]; S = set(xs); k = len(S)
            twoK = 1/wf
            for x in range(u):
                M, vb, vf = posterior_stats(H, f, data, x); ncase += 1
                if M != wf + (1-wf)*Fr(1, 4*u+2)**k: ok_a = False
                if x in S:
                    if vb != 0 or vf != 1: ok_a = False
                else:
                    if vb != Fr(2*u, 2*u+1) / (1 + Fr(4*u+2)**k/(twoK - 1)): ok_a = False
print("(A) Theorem 4.5(a),(b): closed forms against enumeration of the whole class (exact rationals; u in {1,2,3,5}; w(f) in {1/2, 1/3, 2^-10};")
print("    data with repeated inputs),", ncase, "cases: all equal:", ok_a)
# the numbers quoted in the file
u, K = 2**20, 1000
beta = log2(4*u+2)
def V45(k): return float(Fr(u-k, u) * Fr(2*u, 2*u+1) / (1 + Fr(4*u+2)**k / (2**K - 1)))
print(f"    u = 2^20, K = 1000: beta = {beta:.6f}, (K-2)/beta = {(K-2)/beta:.2f};  V at k = 0, 44, 45, 46, 47: " + ", ".join(f"{V45(k):.6g}" for k in (0, 44, 45, 46, 47)))
print(f"    Theorem 4.5(d): min of V over k <= min(u/4, (K-2)/beta) = {min(V45(k) for k in range(0, int((K-2)/beta)+1)):.6f} (claimed > 0.51);  (e) at k = 47: V = {V45(47):.3g} <= 2^(K - k beta) = {2.0**(K-47*beta):.3g}")

# ================================================================ (B) Corollary 4.6: the closed class; the floor; and what the floor is made of
def closed_class(u, wf, C):
    c0 = (1 - wf) / (1 + Fr(1, 2*u))**u
    H = [(wf, 'f', None)]
    for T in tables(u):
        H.append((Fr(C, C+1) * c0 * Fr(1, 4*u)**len(T), 'g', T))
        H.append((Fr(1, C+1) * c0 * Fr(1, 4*u)**len(T), 'h', T))
    return H
print("(B) Corollary 4.6 (memorisers closed under conditioning with C_R = C + 1), exact:")
for (u, wf, C) in ((3, Fr(1, 2**12), 1), (4, Fr(1, 2**30), 4), (4, Fr(1, 2**30), 99)):
    H = closed_class(u, wf, C)
    f = [1, 0, 1, 1][:u]
    data = [(0, f[0])]; x = u-1
    M = Fr(0); vio = Fr(0); silent = Fr(0); good = Fr(0)
    for h in H:
        lik = h[0]
        for (xi, yi) in data: lik *= answer_prob(h, f, xi, yi)
        if lik == 0: continue
        M += lik; vio += lik*answer_prob(h, f, x, B)
        ans = sum(answer_prob(h, f, x, y) for y in (0, 1, B))
        silent += lik*(1-ans); good += lik*(answer_prob(h, f, x, 0) + answer_prob(h, f, x, 1))
    vio, silent, good = vio/M, silent/M, good/M
    pred = Fr(C, C+1)*Fr(2*u, 2*u+1)/(1 + Fr(4*u+2)**1/(1/wf - 1))
    print(f"    u = {u}, K = {log2(1/wf):.0f}, C_R = {C+1}, one pair seen, unseen input: Pr[violating answer] = {float(vio):.6f} (formula {float(pred):.6f}, floor 1 - 1/C_R = {1-1/(C+1):.4f});")
    print(f"        Pr[no answer] = {float(silent):.6f};  Pr[an answer that abides] = {float(good):.6f};  violation probability GIVEN that an answer is produced = {float(vio/(vio+good)):.6f}")

# ================================================================ (C) Theorem 4.2 / Corollary 4.3 on random closed classes of semimeasures
def rand_semimeasure(nx, Yset, sub=True):
    out = []
    for _ in range(nx):
        g = [Fr(random.randrange(0, 5)) for _ in Yset]
        tot = sum(g) + (Fr(random.randrange(0, 3)) if sub else 0)
        if tot == 0: out.append({y: Fr(0) for y in Yset})
        else: out.append({y: v/tot for y, v in zip(Yset, g)})
    return out
def condition(nu, Rsets, Yset):
    out = []
    for x, row in enumerate(nu):
        v = sum(row[y] for y in Yset if y not in Rsets[x])
        if v == 1: out.append({y: Fr(0) for y in Yset})
        else: out.append({y: (row[y]/(1-v) if y in Rsets[x] else Fr(0)) for y in Yset})
    return out
worst42 = Fr(0); worst43a = 0.0; worst43c = None; cases = 0; zero_times_inf = 0
Yset = (0, 1, 2)
for trial in range(1500):
    nx = random.choice([1, 2, 3]); Rsets = [set(random.sample(Yset, random.choice([1, 2]))) for _ in range(nx)]
    base = [rand_semimeasure(nx, Yset) for _ in range(random.choice([1, 2, 4]))]
    # close the class: add the conditioned versions; merge duplicates of the image so that phi is NOT injective in general
    H = list(base); phi = {}
    for i, nu in enumerate(base):
        c = condition(nu, Rsets, Yset)
        if c in H: phi[i] = H.index(c)
        else: H.append(c); phi[i] = len(H)-1
    for j in range(len(base), len(H)): phi[j] = j                         # conditioned ones are fixed points
    for i in range(len(base)):                                            # a base hypothesis that never violates is its own conditioning
        if condition(base[i], Rsets, Yset) == base[i]: phi[i] = i
    w = [Fr(random.randrange(1, 20)) for _ in H]; tot = sum(w); w = [x/tot for x in w]
    CR = max(sum(w[i] for i in range(len(H)) if phi[i] == j) / w[j] for j in set(phi.values()))
    n = random.choice([1, 2, 3, 4])
    data = []
    for _ in range(n):
        x = random.randrange(nx); data.append((x, random.choice(sorted(Rsets[x]))))     # abiding data, arbitrary origin
    liks = []
    for nu in H:
        l = Fr(1)
        for (x, y) in data: l *= nu[x][y]
        liks.append(l)
    M = sum(wi*li for wi, li in zip(w, liks))
    if M == 0: continue
    cases += 1
    lhs = Fr(0); never = Fr(0); hind = Fr(0)
    for i, nu in enumerate(H):
        vs = [sum(nu[x][y] for y in Yset if y not in Rsets[x]) for (x, _) in data]
        if liks[i] == 0:
            if any(v == 1 for v in vs): zero_times_inf += 1                # the term 0 x infinity of the display in Theorem 4.2
            continue
        post = w[i]*liks[i]/M
        prod = Fr(1)
        for v in vs: prod *= 1/(1-v)
        lhs += post*prod; hind += post*sum(vs)
        if all(sum(nu[x][y] for y in Yset if y not in Rsets[x]) == 0 for x in range(nx)): never += post
    worst42 = max(worst42, lhs/CR); worst43a = max(worst43a, float(hind)/math.log(float(CR))) if CR > 1 else worst43a
    worst43c = never*CR if worst43c is None else min(worst43c, never*CR)
print(f"(C) Theorem 4.2 and Corollary 4.3 on {cases} random closed classes of semimeasures (phi not injective in general, data with repeats, exact rationals):")
print(f"    max of [posterior mean of prod 1/(1-v)]/C_R = {float(worst42):.4f} (<= 1);  max of [posterior mean of sum v]/ln C_R = {worst43a:.4f} (<= 1);  min of C_R x posterior weight of never-violators = {float(worst43c):.4f} (>= 1)")
print(f"    indices with likelihood 0 and v = 1 at a data input (the display of Theorem 4.2 has the term 0 x infinity for them): {zero_times_inf}")

# ================================================================ (D) Theorem 4.7: exact probability of the events, i.i.d. inputs
def thm47_exact(H, w, P, mu, Rsets, nx, Yset, nmax, delta, Kbits):
    """exact Pr[exists n <= nmax: inequality (b) fails] and Pr[exists n <= nmax: V(D_n) > (K ln2 + ln(1/delta))/n]"""
    Vnu = [sum(mu[x]*sum(nu[x][y] for y in Yset if y not in Rsets[x]) for x in range(nx)) for nu in H]
    fail_b = Fr(0); fail_d = Fr(0)
    pairs = [(x, y) for x in range(nx) for y in Yset if mu[x]*P[x][y] > 0]
    def rec(n, prob, liks, PD, fb, fd):
        nonlocal fail_b, fail_d
        if n >= 1:
            M = sum(wi*li for wi, li in zip(w, liks))
            if M > 0:
                # (b): sum_post (1-V)^-n <= P(D)/(delta M)
                s = Fr(0); V = Fr(0); bad = False
                for i in range(len(H)):
                    if liks[i] == 0: continue
                    post = w[i]*liks[i]/M; V += post*Vnu[i]
                    if Vnu[i] == 1: bad = True
                    else: s += post*(1-Vnu[i])**(-n)
                if bad or s > PD/(delta*M): fb = True
                if Kbits is not None and float(V) > (Kbits*math.log(2) + math.log(1/float(delta)))/n + 1e-12: fd = True
        if n == nmax:
            if fb: fail_b += prob
            if fd: fail_d += prob
            return
        for (x, y) in pairs:
            p = mu[x]*P[x][y]
            rec(n+1, prob*p, [l*nu[x][y] for l, nu in zip(liks, H)], PD*P[x][y], fb, fd)
    rec(0, Fr(1), [Fr(1)]*len(H), Fr(1), False, False)
    return fail_b, fail_d
worst_b = 0.0; worst_d = 0.0; cnt = 0; argb = None
for trial in range(260):
    nx = random.choice([2, 3]); Yv = (0, 1, 2)
    Rsets = [set(random.sample(Yv, 2)) for _ in range(nx)]
    # the human: a proper sampler that never violates R
    P = []
    for x in range(nx):
        g = {y: (Fr(random.randrange(0, 4)) if y in Rsets[x] else Fr(0)) for y in Yv}
        if sum(g.values()) == 0: g[sorted(Rsets[x])[0]] = Fr(1)
        t = sum(g.values()); P.append({y: v/t for y, v in g.items()})
    mu = [Fr(random.randrange(1, 5)) for _ in range(nx)]; t = sum(mu); mu = [m/t for m in mu]
    H = [P] + [rand_semimeasure(nx, Yv) for _ in range(random.choice([1, 2, 3]))]
    if random.random() < 0.5:                                   # a designed competitor: agrees with P on a set of inputs, violates elsewhere
        g = [dict(P[x]) if random.random() < 0.6 else {y: (Fr(1) if y not in Rsets[x] else Fr(0)) for y in Yv} for x in range(nx)]
        H.append(g)
    wP = Fr(1, random.choice([2, 8, 64, 1024]))
    rest = [Fr(random.randrange(1, 10)) for _ in H[1:]]; t = sum(rest); w = [wP] + [(1-wP)*r/t for r in rest]
    delta = Fr(1, random.choice([2, 5, 20]))
    fb, fd = thm47_exact(H, w, P, mu, Rsets, nx, Yv, 5, delta, math.log2(1/float(wP)))
    cnt += 1
    if float(fb/delta) > worst_b: worst_b = float(fb/delta); argb = (nx, float(wP), float(delta))
    worst_d = max(worst_d, float(fd/delta))
print(f"(D) Theorem 4.7, exact over all data sequences of length <= 5, {cnt} random instances (stochastic humans, semimeasure hypotheses, designed competitors):")
print(f"    max of Pr[exists n <= 5: inequality (b) fails]/delta = {worst_b:.4f} at (inputs, w(P), delta) = {argb};  max of Pr[exists n <= 5: V(D_n) > (K ln2 + ln(1/delta))/n]/delta = {worst_d:.4f}   (both must be <= 1)")

# a two-hypothesis instance designed to make Ville's inequality tight: the competitor's likelihood ratio doubles or dies
P = [{0: Fr(1, 2), 1: Fr(1, 2), 2: Fr(0)}]; mu = [Fr(1)]; Rs = [{0, 1}]
comp = [{0: Fr(1), 1: Fr(0), 2: Fr(0)}]                                      # never violates, bets everything on answer 0
for (wc, delta) in ((Fr(1, 2), Fr(1, 4)), (Fr(1, 8), Fr(1, 16))):
    H = [P, comp]; w = [1-wc, wc]
    fb, fd = thm47_exact(H, w, P, mu, Rs, 1, (0, 1, 2), 8, delta, None)
    print(f"    designed instance (competitor of weight {wc} whose likelihood ratio doubles or dies): Pr[(b) fails for some n <= 8] = {float(fb):.5f}, delta = {float(delta):.5f}")

# ================================================================ (E) Proposition 4.8 (recognisers), brute force; and the direct inequality behind 4.8(d)
def rec_class(u, s, wf):
    subs = list(itertools.combinations(range(u), s))
    return [(wf, 'f', None)] + [((1-wf)/len(subs), 'S', set(S)) for S in subs]
ok_e = True; direct_ok = True; mind = None
for (u, s, wf) in ((5, 2, Fr(1, 4)), (6, 3, Fr(1, 64)), (7, 2, Fr(1, 2**20)), (8, 4, Fr(1, 2**40))):
    H = rec_class(u, s, wf)
    for k in range(0, s+1):
        seen = set(range(k))
        M = wf + sum(h[0] for h in H[1:] if seen <= h[2])
        omega = Fr(1)
        for i in range(k): omega *= Fr(s-i, u-i)
        if M != wf + (1-wf)*omega: ok_e = False
        if k < u:
            x = u-1 if (u-1) not in seen else None
            vx = sum(h[0] for h in H[1:] if seen <= h[2] and x not in h[2])/M
            if vx != Fr(u-s, u-k)*(1-wf)*omega/M: ok_e = False
            V = Fr(u-k, u)*vx
            if V != (1-Fr(s, u))*(1-wf)*omega/M: ok_e = False
            if k >= 1:
                # the inequality used in 4.8(d) for a FIXED data set: 1 - V(D) >= M(D)^(1/k)
                gap = float(1-V) - float(M)**(1.0/k)
                mind = gap if mind is None else min(mind, gap)
                if gap < -1e-12: direct_ok = False
print("(E) Proposition 4.8(a),(b): closed forms against enumeration of all subsets (exact rationals):", ok_e)
print(f"    the direct form of 4.8(d) for a fixed data set, 1 - V(D) >= M(D)^(1/k): holds in all cases: {direct_ok} (smallest gap {mind:.4f})")

# ================================================================ (F) Proposition 4.10 (memorisers and a coin), brute force
ok_f = True
for (u, wf, gam) in ((2, Fr(1, 2), Fr(1, 3)), (3, Fr(1, 1024), Fr(1, 1024)), (4, Fr(1, 2**20), Fr(1, 2**10))):
    Hm = mem_class(u, wf)
    H = [((1-gam)*h[0], h[1], h[2]) for h in Hm] + [(gam, 'coin', None)]
    f = [random.randrange(2) for _ in range(u)]
    for xs in ([], [0], [0, 0], [0, 1], [0, 1, 1]):
        if max(xs, default=0) >= u: continue
        data = [(x, f[x]) for x in xs]; k = len(set(xs)); n = len(xs)
        for x in range(u):
            if x in xs: continue
            M, vb, _ = posterior_stats(H, f, data, x)
            Mcl = (1-gam)*(wf + (1-wf)*Fr(1, 4*u+2)**k) + gam*Fr(1, 2)**n
            if M != Mcl or vb != Fr(2*u, 2*u+1)*(1-gam)*(1-wf)*Fr(1, 4*u+2)**k/Mcl: ok_f = False
print("(F) Proposition 4.10(a),(b): closed forms against enumeration (exact rationals, repeated inputs included):", ok_f)

# ================================================================ (G) Theorem 4.11 on small instances, with an arbitrary class H0 at weight 2^-c
ok_g = True; tight = 0.0
for trial in range(200):
    u = random.choice([2, 3, 4]); c = random.choice([1, 3, 8, 20])
    f = [random.randrange(2) for _ in range(u)]
    H0 = [rand_semimeasure(u, (0, 1, B)) for _ in range(random.choice([1, 3]))]
    w0 = [Fr(random.randrange(1, 9)) for _ in H0]; t = sum(w0); w0 = [x/t for x in w0]
    k = random.randrange(0, u); xs = random.sample(range(u), k); data = [(x, f[x]) for x in xs]
    x = random.choice([z for z in range(u) if z not in xs])
    M = Fr(0); Mb = Fr(0)
    for nu, wi in zip(H0, w0):
        l = Fr(1, 2**c)*wi
        for (xi, yi) in data: l *= nu[xi][yi]
        M += l; Mb += l*nu[x][B]
    for T in tables(u):
        h = (Fr(1, 4)*Fr(1, 4*u)**len(T), 'g', T); l = h[0]
        for (xi, yi) in data: l *= answer_prob(h, f, xi, yi)
        M += l; Mb += l*answer_prob(h, f, x, B)
    lower = Fr(2*u, 2*u+1)/(1 + Fr(4, 2**c)*Fr(4*u)**k)
    if Mb/M < lower: ok_g = False
    tight = max(tight, float(lower/(Mb/M)))
print("(G) Theorem 4.11: M_D(b|x) >= (2u/(2u+1))/(1 + 2^(2-c)(4u)^k) on 200 random instances (exact):", ok_g, f"(largest bound/value {tight:.4f})")

# ================================================================ (H) what the level 'near 1' of Theorem 4.5 depends on: the default answer of the memorisers
print("(H) What the level 'near 1' of Theorem 4.5 is: memorisers whose answer outside the table is a default d, drawn once from a prior lam over")
print("    {b, g}, where g is an answer that abides by R and that the human never gives (so no default explains any data); exact:")
u, wf = 4, Fr(1, 2**30); G = 'g'
for lam in ({B: Fr(1), G: Fr(0)}, {B: Fr(1, 2), G: Fr(1, 2)}, {B: Fr(1, 50), G: Fr(49, 50)}):
    c0 = (1 - wf) / (1 + Fr(1, 2*u))**u
    H = [(wf, 'f', None)] + [(c0*Fr(1, 4*u)**len(T)*lam[d], 'gd', T, d) for T in tables(u) for d in (B, G) if lam[d] > 0]
    f = [1, 0, 0, 1]; data = [(0, f[0])]; x = 3
    M = Fr(0); pb = Fr(0); pg = Fr(0); pf = Fr(0)
    for h in H:
        lik = h[0]
        for (xi, yi) in data: lik *= answer_prob(h, f, xi, yi)
        if lik == 0: continue
        M += lik; pb += lik*answer_prob(h, f, x, B); pg += lik*answer_prob(h, f, x, G); pf += lik*answer_prob(h, f, x, f[x])
    thm45 = Fr(2*u, 2*u+1)/(1 + Fr(4*u+2)/(1/wf - 1))
    print(f"    lam(b) = {float(lam[B]):.2f}: Pr[the mixture answers b at an unseen input] = {float(pb/M):.6f} = lam(b) x (value of Theorem 4.5) = {float(lam[B]*thm45):.6f};"
          f"  Pr[the abiding default g] = {float(pg/M):.6f};  Pr[f(x)] = {float(pf/M):.6f}")

# ================================================================ (I) Proposition 4.12, exact: random functions drawn from the coin, a class with memorisers and the coin
def prop412_exact(u, gam, wf, nmax, delta):
    """Pr over (F, inputs) that for some n <= nmax the inputs are distinct and V(D_n) > (K(S) ln 2 + ln(1/delta))/n; S = coin of weight gam"""
    KS = math.log2(1/float(gam)); bad = Fr(0)
    def V(k, n):
        Mm = (1-gam)*(wf + (1-wf)*Fr(1, 4*u+2)**k) + gam*Fr(1, 2)**n
        return Fr(u-k, u)*Fr(2*u, 2*u+1)*(1-gam)*(1-wf)*Fr(1, 4*u+2)**k/Mm
    # V depends on the data only through (k, n) (not on F, as long as the data come from F); the index f in the class is one fixed function,
    # which has likelihood 1 only if F agrees with it on the data: average over F by treating f as the all-zero function
    for xs in itertools.product(range(u), repeat=nmax):
        for ys in itertools.product((0, 1), repeat=nmax):
            # answers at repeated inputs must repeat; weight of this (inputs, answers) path
            consistent = True; seen = {}
            pw = Fr(1, u**nmax)
            for x, y in zip(xs, ys):
                if x in seen:
                    if seen[x] != y: consistent = False; break
                else:
                    seen[x] = y; pw *= Fr(1, 2)
            if not consistent: continue
            fail = False; seen = set()
            for n in range(1, nmax+1):
                x = xs[n-1]
                if x in seen: break                                        # a repeated input: the statement stops here
                seen.add(x)
                k = n
                agree = all(ys[i] == 0 for i in range(n))                  # likelihood of the index f (the zero function)
                Mm = (1-gam)*((wf if agree else 0) + (1-wf)*Fr(1, 4*u+2)**k) + gam*Fr(1, 2)**n
                Vn = Fr(u-k, u)*Fr(2*u, 2*u+1)*(1-gam)*(1-wf)*Fr(1, 4*u+2)**k/Mm
                if float(Vn) > (KS*math.log(2) + math.log(1/delta))/n + 1e-12: fail = True; break
            if fail: bad += pw
    return float(bad)
for (u, gam, delta) in ((4, Fr(1, 2), 0.5), (4, Fr(1, 64), 0.9), (5, Fr(1, 4), 0.3)):
    pr = prop412_exact(u, gam, Fr(1, 2**10), 4, delta)
    print(f"(I) Proposition 4.12, exact (u = {u}, coin of weight {gam}, humans = all functions, uniform inputs, n <= 4): Pr[bound fails before the first repeated input] = {pr:.5f} <= delta = {delta}")

# ================================================================ (J) a closure that keeps the samplers proper: soft conditioning with a fall-back sampler G
# nu^{R,theta}(y|x) = [nu(y|x) 1[(x,y) in R] + theta v_nu(x) G(y|x)] / (1 - (1-theta) v_nu(x)),   G a proper sampler that never violates R.
# Claim (adversary's Proposition X3): if the class is closed under nu -> nu^{R,theta} with constant C, then on abiding data
#   posterior mean of prod_i 1/(1 - (1-theta) v_nu(x_i)) <= C,   and the never-violators, which here ANSWER with probability 1, have posterior weight >= 1/C.
def rand_proper(nx, Yset):
    out = []
    for _ in range(nx):
        g = [Fr(random.randrange(0, 5)) for _ in Yset]
        if sum(g) == 0: g[random.randrange(len(Yset))] = Fr(1)
        t = sum(g); out.append({y: v/t for y, v in zip(Yset, g)})
    return out
def soft_condition(nu, G, Rsets, Yset, theta):
    out = []
    for x, row in enumerate(nu):
        v = sum(row[y] for y in Yset if y not in Rsets[x])
        den = 1 - (1-theta)*v
        out.append({y: ((row[y] if y in Rsets[x] else Fr(0)) + theta*v*G[x][y])/den for y in Yset})
    return out
worstJ = Fr(0); minfloor = None; casesJ = 0; proper_ok = True; minans = None
for trial in range(1200):
    nx = random.choice([1, 2, 3]); theta = random.choice([Fr(1, 2), Fr(1, 10), Fr(1)])
    Rsets = [set(random.sample(Yset, random.choice([1, 2]))) for _ in range(nx)]
    G = [{y: (Fr(1) if y == sorted(Rsets[x])[0] else Fr(0)) for y in Yset} for x in range(nx)]      # the first abiding answer
    base = [rand_proper(nx, Yset) for _ in range(random.choice([1, 2, 4]))]
    H = list(base); phi = {}
    for i, nu in enumerate(base):
        c = soft_condition(nu, G, Rsets, Yset, theta)
        if any(sum(row.values()) != 1 for row in c): proper_ok = False
        if c in H: phi[i] = H.index(c)
        else: H.append(c); phi[i] = len(H)-1
    for j in range(len(H)):
        if j not in phi: phi[j] = j                                    # images never violate, so they are fixed points
    for i in range(len(base)):
        if soft_condition(base[i], G, Rsets, Yset, theta) == base[i]: phi[i] = i
    w = [Fr(random.randrange(1, 20)) for _ in H]; tot = sum(w); w = [x/tot for x in w]
    C = max(sum(w[i] for i in range(len(H)) if phi[i] == j)/w[j] for j in set(phi.values()))
    n = random.choice([1, 2, 3, 4]); data = []
    for _ in range(n):
        x = random.randrange(nx); data.append((x, random.choice(sorted(Rsets[x]))))
    liks = []
    for nu in H:
        l = Fr(1)
        for (x, y) in data: l *= nu[x][y]
        liks.append(l)
    M = sum(wi*li for wi, li in zip(w, liks))
    if M == 0: continue
    casesJ += 1; lhs = Fr(0); never = Fr(0)
    for i, nu in enumerate(H):
        if liks[i] == 0: continue
        post = w[i]*liks[i]/M; prod = Fr(1)
        for (x, _) in data:
            v = sum(nu[x][y] for y in Yset if y not in Rsets[x]); prod *= 1/(1 - (1-theta)*v)
        lhs += post*prod
        if all(sum(nu[x][y] for y in Yset if y not in Rsets[x]) == 0 for x in range(nx)): never += post
    worstJ = max(worstJ, lhs/C); minfloor = never*C if minfloor is None else min(minfloor, never*C)
print(f"(J) Proposition X3 (soft conditioning with a fall-back answer; proper samplers stay proper: {proper_ok}), {casesJ} random closed classes, theta in {{1/10, 1/2, 1}}:")
print(f"    max of [posterior mean of prod 1/(1-(1-theta)v)]/C = {float(worstJ):.4f} (<= 1);  min of C x posterior weight of the never-violators (all of which answer) = {float(minfloor):.4f} (>= 1)")

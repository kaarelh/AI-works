# Referee's checks for Section 4 of research/prove-c/property-batch.md (Pr2: Theorem 4.2, Corollary 4.3, Theorem 4.5,
# Corollary 4.6, Theorem 4.7, Propositions 4.8, 4.9, 4.10, Theorem 4.11, Proposition 4.12).
# Independent of the prover's scripts; classes are enumerated in full and probabilities are exact rationals.
# Pure Python 3.  Run:  python3 property-batch_check_sec4.py > property-batch_check_sec4.out
import math, random, itertools
from fractions import Fraction as Fr
from math import log, log2, sqrt

random.seed(4115)
B = "b"                                     # the bad answer

# ================================================================= (1) Theorem 4.2 and Corollary 4.3 on random closed classes
def rand_semi(nx, ny):
    S = []
    for x in range(nx):
        g = [Fr(random.choice([0, 0, 1, 2, 3])) for _ in range(ny)]
        if sum(g) == 0: g[random.randrange(ny)] = Fr(1)
        tot = sum(g) + Fr(random.choice([0, 0, 1, 3]))        # a deficit: probability of "no answer"
        S.append([a/tot for a in g])
    return S
def viol(S, R, x): return sum((S[x][y] for y in range(len(S[x])) if (x, y) not in R), Fr(0))
def condition(S, R):
    out = []
    for x in range(len(S)):
        v = viol(S, R, x)
        out.append([Fr(0)]*len(S[x]) if v == 1 else [S[x][y]/(1-v) if (x, y) in R else Fr(0) for y in range(len(S[x]))])
    return out
def lik(S, D):
    p = Fr(1)
    for (x, y) in D: p *= S[x][y]
    return p

viol42 = 0; ncase = 0; maxratio = Fr(0); max43a = 0.0; min43c = None; viol43 = 0; n_inf = 0; n_semi_cond = 0
for trial in range(400):
    nx, ny = 3, 3
    R = set((x, y) for x in range(nx) for y in range(ny) if random.random() < 0.6)
    bases = [rand_semi(nx, ny) for _ in range(random.choice([1, 2, 4]))]
    H = []; phi = []
    for S in bases:
        H.append(S); H.append(condition(S, R)); phi.append(len(H)-1); phi.append(len(H)-1)
    # the conditioning of a conditioned sampler is itself
    for i, S in enumerate(H): assert condition(H[phi[i]], R) == H[phi[i]] and condition(S, R) == H[phi[i]]
    raw = [Fr(random.choice([1, 1, 2, 5, 40])) for _ in H]; tot = sum(raw)*random.choice([1, 1, 3]); w = [a/tot for a in raw]
    CR = max(sum(w[i] for i in range(len(H)) if phi[i] == j)/w[j] for j in set(phi))
    assert CR >= 1
    never = [i for i in range(len(H)) if all(viol(H[i], R, x) == 0 for x in range(nx))]
    pairs = sorted(R)
    for n in (1, 2, 3):
        for D in itertools.product(pairs, repeat=n):
            M = sum(w[i]*lik(H[i], D) for i in range(len(H)))
            if M == 0: continue
            ncase += 1
            lhs = Fr(0); exp_viol = Fr(0)
            for i in range(len(H)):
                li = lik(H[i], D)
                if li == 0:
                    if any(viol(H[i], R, x) == 1 for (x, _) in D): n_inf += 1      # the factor would be 1/0 with posterior weight 0
                    continue
                post = w[i]*li/M; prod = Fr(1)
                for (x, _) in D: prod *= 1/(1 - viol(H[i], R, x))
                lhs += post*prod
                exp_viol += post*sum(viol(H[i], R, x) for (x, _) in D)
            if lhs > CR: viol42 += 1
            maxratio = max(maxratio, lhs/CR)
            if CR > 1: max43a = max(max43a, float(exp_viol)/log(float(CR)))
            elif exp_viol > 0: viol43 += 1
            pn = sum(w[i]*lik(H[i], D) for i in never)/M
            if pn*CR < 1: viol43 += 1
            min43c = pn*CR if min43c is None else min(min43c, pn*CR)
            for x in range(nx):                                                   # the floor at every input, seen or not
                vm = sum(w[i]*lik(H[i], D)/M*viol(H[i], R, x) for i in range(len(H)))
                if vm > 1 - 1/CR: viol43 += 1
            for eta in (Fr(1, 2), Fr(1, 10)):                                     # Corollary 4.3(b)
                pw = Fr(0)
                for i in range(len(H)):
                    li = lik(H[i], D)
                    if li == 0: continue
                    prod = Fr(1)
                    for (x, _) in D: prod *= (1 - viol(H[i], R, x))
                    if prod <= eta: pw += w[i]*li/M
                if pw > eta*CR: viol43 += 1
print(f"(1) Theorem 4.2 on 400 random classes closed under conditioning (semimeasures, random R, weights of total <= 1), all abiding data of 1 to 3 pairs with M(D) > 0: {ncase} data sets")
print(f"    violations of E_post[prod 1/(1-v)] <= C_R: {viol42}; largest left side/C_R = {float(maxratio):.6f}")
print(f"    Corollary 4.3: violations of (a), (b), (c): {viol43}; largest E_post[sum v]/ln C_R = {max43a:.4f}; smallest C_R x (posterior weight of never-violators) = {float(min43c):.6f}")
print(f"    indices with likelihood 0 and v = 1 at a seen input (the factor 1/(1-v) is infinite, the posterior weight is 0) occurred {n_inf} times: the sum needs the convention 0 x infinity = 0")

# ================================================================= (2) Theorem 4.5 by enumeration of all tables
def all_tables(u):
    for vals in itertools.product((None, 0, 1), repeat=u):
        yield {x: t for x, t in enumerate(vals) if t is not None}
def mem_answer(T, x): return T[x] if x in T else B

def check_45(u, K, f):
    c0 = (1 - Fr(1, 2**K))/(1 + Fr(1, 2*u))**u
    tables = list(all_tables(u)); wts = [c0*Fr(1, (4*u)**len(T)) for T in tables]
    ok = (Fr(1, 2**K) + sum(wts) == 1)
    # a data set with repeated inputs has the same likelihoods as the set of its pairs, so it is enough to go through the sets S of inputs
    for k in range(0, u+1):
        for S in itertools.combinations(range(u), k):
            cons = [i for i, T in enumerate(tables) if all(mem_answer(T, x) == f[x] for x in S)]
            M = Fr(1, 2**K) + sum(wts[i] for i in cons)
            if M != Fr(1, 2**K) + (1 - Fr(1, 2**K))*Fr(1, (4*u+2)**k): ok = False
            Vsum = Fr(0)
            for x in range(u):
                vb = sum(wts[i] for i in cons if mem_answer(tables[i], x) == B)/M
                pf = (Fr(1, 2**K) + sum(wts[i] for i in cons if mem_answer(tables[i], x) == f[x]))/M
                if x in S:
                    if vb != 0 or pf != 1: ok = False
                else:
                    closed = Fr(2*u, 2*u+1)/(1 + Fr((4*u+2)**k, 2**K - 1))
                    if vb != closed: ok = False
                Vsum += Fr(1, u)*vb
            closedV = Fr(u-k, u)*Fr(2*u, 2*u+1)/(1 + Fr((4*u+2)**k, 2**K - 1))
            if Vsum != closedV: ok = False
            if Vsum > Fr(2**K - 1, (4*u+2)**k): ok = False                       # (e), in the sharper form (2^K - 1)/(4u+2)^k
            # (f): every index of positive posterior weight has v = 0 at the seen inputs
            if any(mem_answer(tables[i], x) == B for i in cons for x in S): ok = False
    return ok
res = []
for u in (1, 2, 3, 4, 5):
    for K in (1, 2, 5):
        f = [random.randrange(2) for _ in range(u)]
        res.append(check_45(u, K, f))
print(f"(2) Theorem 4.5(a),(b),(c),(e) and 'the weights sum to 1': closed forms against enumeration of all 3^u tables, u in 1..5, K in {{1, 2, 5}}, data with repeated inputs: {all(res)}")

def V45(u, K, k):
    return Fr(u-k, u)*Fr(2*u, 2*u+1)/(1 + Fr((4*u+2)**k, 2**K - 1))
# (d): V >= 0.51 for all n <= min(u/4, (K-2)/beta), u >= 5, K >= 2; and the general form
ok_d = True; minV = 1.0; cases = 0
for u in (5, 6, 8, 16, 100, 2**10, 2**20):
    beta = log2(4*u+2)
    for K in (2, 3, 10, 24, 25, 60, 200, 1000):
        kmax = int(min(u/4, (K-2)/beta))
        for k in range(0, kmax+1):
            v = float(V45(u, K, k)); cases += 1; minV = min(minV, v)
            if v < 0.51 or v < 0.75*(10/11)*0.75: ok_d = False
        # general form with theta = k/u and the largest admissible j
        for k in range(0, min(u, 40)):
            j = K - k*beta
            if j < 0: break
            lb = (1 - k/u)*(2*u/(2*u+1))/(1 + 2.0**(-j)/(1 - 2.0**(-K)))
            if float(V45(u, K, k)) < lb*(1 - 1e-12): ok_d = False
print(f"    Theorem 4.5(d): V >= (3/4)(10/11)(3/4) = {0.75*10/11*0.75:.6f} > 0.51 for all k <= min(u/4, (K-2)/beta) on {cases} (u, K, k): {ok_d}; smallest V found = {minV:.6f}")
u, K = 2**20, 1000; beta = log2(4*u+2)
print(f"    u = 2^20, K = 1000: beta = {beta:.7f}, (K-2)/beta = {(K-2)/beta:.3f}; V(k) for k = 0, 10, 30, 44, 45, 46, 47, 48:",
      ", ".join(f"{float(V45(u, K, k)):.6g}" for k in (0, 10, 30, 44, 45, 46, 47, 48)))
print(f"    Theorem 4.5(e) at k = 47: V = {float(V45(u, K, 47)):.4g} <= 2^(K - k beta) = {2.0**(K - 47*beta):.4g}; with (K + j)/beta distinct inputs V <= 2^-j: k = 46 >= (K+10)/beta = {(K+10)/beta:.2f}: V = {float(V45(u, K, 46)):.3g} <= 2^-10 = {2.0**-10:.3g}")

# ================================================================= (3) Corollary 4.6: the closed memoriser class
def check_46(u, K, C, f):
    c0 = (1 - Fr(1, 2**K))/(1 + Fr(1, 2*u))**u
    tables = list(all_tables(u))
    # indices: ("f",), ("g", T), ("h", T); kernels as functions x -> dict of probabilities
    def kern(idx):
        if idx[0] == "f": return [{f[x]: Fr(1)} for x in range(u)]
        T = tables[idx[1]]
        if idx[0] == "g": return [{mem_answer(T, x): Fr(1)} for x in range(u)]
        return [({T[x]: Fr(1)} if x in T else {}) for x in range(u)]
    idxs = [("f",)] + [("g", i) for i in range(len(tables))] + [("h", i) for i in range(len(tables))]
    wt = {("f",): Fr(1, 2**K)}
    for i, T in enumerate(tables):
        base = c0*Fr(1, (4*u)**len(T)); wt[("g", i)] = C/(C+1)*base; wt[("h", i)] = 1/(C+1)*base
    ok = (sum(wt.values()) == 1)
    def cond(kn):
        out = []
        for d in kn:
            v = d.get(B, Fr(0)); out.append({} if v == 1 else {y: p/(1-v) for y, p in d.items() if y != B})
        return out
    phi = {("f",): ("f",)}
    for i in range(len(tables)): phi[("g", i)] = ("h", i); phi[("h", i)] = ("h", i)
    for idx in idxs:
        if cond(kern(idx)) != kern(phi[idx]): ok = False
    CR = max(sum(wt[i] for i in idxs if phi[i] == j)/wt[j] for j in set(phi.values()))
    if CR != C + 1: ok = False
    for k in range(0, u):
        S = list(range(k)); x = k                                    # x is an unseen input
        def L(idx):
            kn = kern(idx); p = Fr(1)
            for xx in S: p *= kn[xx].get(f[xx], Fr(0))
            return p
        M = sum(wt[i]*L(i) for i in idxs)
        if M != Fr(1, 2**K) + (1 - Fr(1, 2**K))*Fr(1, (4*u+2)**k): ok = False
        vb = sum(wt[i]*L(i)*kern(i)[x].get(B, Fr(0)) for i in idxs)/M
        if vb != (1 - 1/CR)*Fr(2*u, 2*u+1)/(1 + Fr((4*u+2)**k, 2**K - 1)): ok = False
        if vb >= 1 - 1/CR: ok = False                                 # the floor is approached, never attained
        nv = wt[("f",)]*L(("f",)) + sum(wt[("h", i)]*L(("h", i)) for i in range(len(tables)))
        if nv/M < 1/CR: ok = False
    return ok
res = [check_46(u, K, C, [random.randrange(2) for _ in range(u)]) for u in (2, 3, 4) for K in (1, 3) for C in (Fr(1, 2), Fr(1), Fr(4))]
print(f"(3) Corollary 4.6 by enumeration (u in 2..4, K in {{1, 3}}, C in {{1/2, 1, 4}}): weights sum to 1, phi names the conditioned kernels, C_R = C + 1, M(D) unchanged,")
print(f"    v = (1 - 1/C_R) x (value of Theorem 4.5), strictly below the floor 1 - 1/C_R, never-violators keep posterior weight >= 1/C_R: {all(res)}")
u = 2**20
for CR in (2, 17):
    for (K, k) in ((1000, 10), (10**4, 300)):
        v = (1 - Fr(1, CR))*Fr(2*u, 2*u+1)/(1 + Fr((4*u+2)**k, 2**K - 1))
        print(f"    C_R = {CR}, u = 2^20, K = {K}, k = {k}: v = {float(v):.9f} against the floor 1 - 1/C_R = {1-1/CR:.9f}")

# ================================================================= (4) Theorem 4.7 by exact enumeration
def check_47(trial):
    nx, ny = 3, 3
    mu = random.choice([[Fr(1, 2), Fr(1, 2), Fr(0)], [Fr(1, 2), Fr(1, 3), Fr(1, 6)], [Fr(1), Fr(0), Fr(0)]])
    # the human: a proper sampler
    P = []
    for x in range(nx):
        g = [Fr(random.choice([0, 1, 2])) for _ in range(ny)]
        if sum(g) == 0: g[0] = Fr(1)
        P.append([a/sum(g) for a in g])
    # R contains the support of P at inputs of positive mu-probability, and random other pairs; off the support of mu the human may violate
    R = set((x, y) for x in range(nx) for y in range(ny) if (mu[x] > 0 and P[x][y] > 0) or random.random() < 0.3)
    if mu[2] == 0 and random.random() < 0.5: R -= {(2, y) for y in range(ny)}
    H = [rand_semi(nx, ny) for _ in range(random.choice([2, 4]))]
    inclass = random.random() < 0.5; iP = None
    if inclass: H.append(P); iP = len(H) - 1
    if random.random() < 0.5:                                         # an index that violates R with probability 1 on the support of mu
        bad = []
        for x in range(nx):
            ys = [y for y in range(ny) if (x, y) not in R]
            bad.append([Fr(1) if (ys and y == ys[0]) else Fr(0) for y in range(ny)] if ys else [Fr(0)]*ny)
        H.append(bad)
    raw = [Fr(random.choice([1, 2, 7, 30])) for _ in H]; tot = sum(raw)*random.choice([1, 2]); w = [a/tot for a in raw]
    Vn = [sum(mu[x]*viol(S, R, x) for x in range(nx)) for S in H]
    pairs = [(x, y) for x in range(nx) for y in range(ny) if mu[x]*P[x][y] > 0]
    out = {"superm": True, "det": 0, "EZ": [], "pfail": {}}
    nmax = 3
    def Z(D):
        n = len(D); PD = lik(P, D); z = Fr(0)
        for i, S in enumerate(H):
            li = lik(S, D)
            if li > 0: z += w[i]*li/((1 - Vn[i])**n if n > 0 else 1)/PD
        return z
    deltas = (0.5, 0.1)
    paths = {(): Fr(1)}; pfail = {d: Fr(0) for d in deltas}; alive = {(): {d: True for d in deltas}}
    out["EZ"].append(Z(()))
    assert Z(()) == sum(w)
    for n in range(1, nmax+1):
        new = {}; newalive = {}; EZ = Fr(0)
        for D, pD in paths.items():
            zD = Z(D); cond = Fr(0)
            for (x, y) in pairs:
                D2 = D + ((x, y),); p2 = pD*mu[x]*P[x][y]; z2 = Z(D2)
                new[D2] = p2; EZ += p2*z2; cond += mu[x]*P[x][y]*z2
                newalive[D2] = {}
                for d in deltas:
                    ok = alive[D][d] and float(z2) < 1/d
                    newalive[D2][d] = ok
                    if alive[D][d] and not ok: pfail[d] += p2
                    if not ok: continue
                    # deterministic consequences (b)-(g) on the event {Z_m < 1/delta for all m <= n}
                    M = sum(w[i]*lik(H[i], D2) for i in range(len(H))); PD = lik(P, D2)
                    if M == 0: continue
                    post = [w[i]*lik(H[i], D2)/M for i in range(len(H))]
                    lhs = sum(float(post[i])/float(1 - Vn[i])**n for i in range(len(H)) if post[i] > 0)
                    rhs = float(PD)/(d*float(M))
                    VD = float(sum(post[i]*Vn[i] for i in range(len(H))))
                    if lhs > rhs*(1+1e-9): out["det"] += 1
                    if 1 - VD < (d*float(M)/float(PD))**(1/n)*(1-1e-9): out["det"] += 1
                    if VD > (log(float(PD)/float(M)) + log(1/d))/n + 1e-9: out["det"] += 1
                    if inclass:
                        Kb = log2(1/float(w[iP]))
                        if VD > (Kb*log(2) + log(1/d))/n + 1e-9: out["det"] += 1
                        if n > Kb + log2(1/d) and VD >= 0.5: out["det"] += 1
                    for i in range(len(H)):                                       # (e)
                        li = lik(H[i], D2)
                        if li > 0 and VD > (log(1/float(w[i])) + log(float(PD)/float(li)) + log(1/d))/n + 1e-9: out["det"] += 1
                    for v in (0.1, 0.5, 0.9):                                     # (f), (g)
                        if VD >= v and log2(float(PD)/float(M)) < n*log2(1/(1-v)) - log2(1/d) - 1e-9: out["det"] += 1
                        pw = float(sum(post[i] for i in range(len(H)) if Vn[i] >= v))
                        if pw > (1-v)**n*float(PD)/(d*float(M))*(1+1e-9): out["det"] += 1
            if cond > zD: out["superm"] = False                                   # E[Z_{n+1} | D_n] <= Z_n, exactly
        paths = new; alive = newalive; out["EZ"].append(EZ)
    out["pfail"] = {d: float(pfail[d]) for d in deltas}
    return out
sup_ok = True; det = 0; worst = 0.0; mono = True; maxEZ = 0.0
for trial in range(120):
    o = check_47(trial)
    sup_ok = sup_ok and o["superm"]; det += o["det"]
    for d, p in o["pfail"].items(): worst = max(worst, p/d)
    if any(o["EZ"][i+1] > o["EZ"][i] for i in range(len(o["EZ"])-1)): mono = False
    maxEZ = max(maxEZ, float(o["EZ"][-1]/o["EZ"][0]))
print(f"(4) Theorem 4.7 on 120 random instances (3 inputs, some of mu-probability 0; 3 answers; semimeasure classes with or without the human; indices with V = 1), all paths of 3 pairs:")
print(f"    (a) E[Z_(n+1) | D_n] <= Z_n on every path, exactly: {sup_ok}; E Z_n non-increasing: {mono}; largest E Z_3 / Z_0 = {maxEZ:.4f}")
print(f"    (b) max Pr[some Z_n >= 1/delta, n <= 3]/delta = {worst:.4f} (must be <= 1); violations of (b)-(g) on the complementary event: {det} (must be 0)")

# ================================================================= (5) Proposition 4.8 (recognisers) by enumeration
def check_48(u, s, K, f):
    subs = list(itertools.combinations(range(u), s)); ws = (1 - Fr(1, 2**K))/len(subs); ok = True; strong = True
    for k in range(0, s+1):
        Sd = set(range(k))
        cons = [S for S in subs if Sd <= set(S)]
        omega = Fr(1)
        for i in range(k): omega *= Fr(s-i, u-i)
        M = Fr(1, 2**K) + ws*len(cons)
        if M != Fr(1, 2**K) + (1 - Fr(1, 2**K))*omega: ok = False
        V = Fr(0)
        for x in range(u):
            vb = ws*sum(1 for S in cons if x not in S)/M
            if x in Sd:
                if vb != 0: ok = False
            elif vb != Fr(u-s, u-k)*(1 - Fr(1, 2**K))*omega/M: ok = False
            V += Fr(1, u)*vb
        sig = Fr(s, u)
        if V != (1 - sig)*(1 - Fr(1, 2**K))*omega/M: ok = False
        if not (sig**k*(1 - Fr(k*k, 2*s)) <= omega <= sig**k): ok = False
        if k >= 1 and float(1 - V) < float(M)**(1.0/k)*(1 - 1e-12): strong = False      # 1 - V(D) >= M(D)^(1/k), with no delta
    return ok, strong
res = [check_48(u, s, K, None) for u in (3, 4, 6, 8) for s in range(1, u) for K in (1, 3, 8)]
print(f"(5) Proposition 4.8(a),(b) and the bounds on omega_k by enumeration of all subsets (u in {{3, 4, 6, 8}}, all s, K in {{1, 3, 8}}): {all(r[0] for r in res)};")
print(f"    the inequality 1 - V(D) >= M(D)^(1/k) (which is 4.7(c) with delta = 1) holds for every k in these classes: {all(r[1] for r in res)}")
def V48(u, s, K, k):
    omega = Fr(1)
    for i in range(k): omega *= Fr(s-i, u-i)
    a = Fr(1, 2**K)
    return (1 - Fr(s, u))*(1-a)*omega/(a + (1-a)*omega), a + (1-a)*omega
okc = True; okd = True; ok23 = True; strong = True; cnt = 0
for u in (2**6, 2**10, 2**16):
    for sigexp in (1, 2, 4):
        s = u >> sigexp; sig = s/u
        for K in (5, 6, 7, 20, 60, 200):
            for k in range(0, int(sqrt(s))+1):
                V, M = V48(u, s, K, k)
                if k >= 1 and float(1 - V) < float(M)**(1.0/k)*(1 - 1e-12): strong = False
                jj = K - 2 - k*sigexp
                if jj < 0: continue
                cnt += 1
                if float(V) < (1 - sig)/(1 + 2.0**(-jj))*(1 - 1e-12): okc = False
                if float(1 - V) > sig + 2.0**(-jj) + 1e-12: okd = False
                if k >= 1:
                    for d in (0.5, 0.1):
                        if not (float(1 - V) >= (d*float(M))**(1.0/k)*(1 - 1e-12) and (d*float(M))**(1.0/k) >= sig*(d/4)**(1.0/k)*(1 - 1e-12)): okd = False
                if sigexp == 2 and k <= (K-5)/2 and float(V) < 2/3 - 1e-12: ok23 = False
print(f"    (c), (d) on {cnt} triples (u, sigma, K) x k <= sqrt(s): V >= (1-sigma)/(1+2^-j): {okc}; 1-V <= sigma + 2^-j and 1-V >= (delta M)^(1/k) >= sigma (delta/4)^(1/k): {okd};")
print(f"    sigma = 1/4: V >= 2/3 for all k <= min((K-5)/2, sqrt(u/4)): {ok23}; 1 - V >= M^(1/k) throughout: {strong}")
u, K = 2**16, 200
for sigexp in (1, 2, 4):
    s = u >> sigexp
    print(f"    u = 2^16, K = 200, sigma = 2^-{sigexp}: V at k = 0, 45, 50, 100, 190, 200, 210: " + ", ".join(f"{float(V48(u, s, K, k)[0]):.3f}" for k in (0, 45, 50, 100, 190, 200, 210)))

# ================================================================= (6) Proposition 4.10 (memorisers and a coin) by enumeration
def check_410(u, K, gamma, f):
    c0 = (1 - Fr(1, 2**K))/(1 + Fr(1, 2*u))**u
    tables = list(all_tables(u)); wts = [(1-gamma)*c0*Fr(1, (4*u)**len(T)) for T in tables]; wf = (1-gamma)*Fr(1, 2**K); ok = True
    if wf + sum(wts) + gamma != 1: ok = False
    for n in range(0, 4):
        for xs in itertools.product(range(u), repeat=n):
            S = set(xs); k = len(S)
            cons = [i for i, T in enumerate(tables) if all(mem_answer(T, x) == f[x] for x in S)]
            M = wf + sum(wts[i] for i in cons) + gamma*Fr(1, 2**n)
            if M != (1-gamma)*(Fr(1, 2**K) + (1 - Fr(1, 2**K))*Fr(1, (4*u+2)**k)) + gamma*Fr(1, 2**n): ok = False
            V = Fr(0)
            for x in range(u):
                vb = sum(wts[i] for i in cons if mem_answer(tables[i], x) == B)/M
                if x not in S and vb != Fr(2*u, 2*u+1)*(1-gamma)*(1 - Fr(1, 2**K))*Fr(1, (4*u+2)**k)/M: ok = False
                if x in S and vb != 0: ok = False
                V += Fr(1, u)*vb
            if V > (1-gamma)/gamma*2**n*Fr(1, (4*u+2)**k): ok = False
            if k == n and V > (1-gamma)/gamma*Fr(1, (2*u+1)**n): ok = False
            if k == n:
                for j in range(0, 6):
                    if (1-gamma)*Fr(1, (2*u+1)**n) <= gamma*Fr(1, 2**j) and (1-gamma)*Fr(2**n, 2**K) <= gamma*Fr(1, 2**j):
                        if gamma*Fr(1, 2**n)/M < 1/(1 + Fr(2, 2**j)): ok = False
    return ok
res = [check_410(u, K, g, [random.randrange(2) for _ in range(u)]) for u in (2, 3, 4) for K in (2, 6, 12) for g in (Fr(1, 2), Fr(1, 16), Fr(1, 1000))]
print(f"(6) Proposition 4.10(a)-(d) by enumeration (u in 2..4, K in {{2, 6, 12}}, gamma in {{1/2, 1/16, 1/1000}}, data of up to 3 pairs with repeats): {all(res)}")
u, K, gamma = 2**20, 1000, Fr(1, 2**20)
vals = []
for n in range(0, 4):
    M = (1-gamma)*(Fr(1, 2**K) + (1 - Fr(1, 2**K))*Fr(1, (4*u+2)**n)) + gamma*Fr(1, 2**n)
    vals.append(float(Fr(u-n, u)*Fr(2*u, 2*u+1)*(1-gamma)*(1 - Fr(1, 2**K))*Fr(1, (4*u+2)**n)/M))
print("    u = 2^20, K = 1000, gamma = 2^-20: V after n = 0, 1, 2, 3 distinct inputs:", ", ".join(f"{v:.3g}" for v in vals))

# ================================================================= (7) Theorem 4.11 by enumeration, and the code of the machine U'
def check_411(u, c, f, nH0):
    tables = list(all_tables(u)); wm = [Fr(1, 4)*Fr(1, (4*u)**len(T)) for T in tables]
    Y = [0, 1, B, "other"]
    H0 = []
    for _ in range(nH0):
        S = []
        for x in range(u):
            g = [Fr(random.choice([0, 1, 2, 5])) for _ in Y]; tot = sum(g) + Fr(random.choice([0, 1])) or Fr(1)
            S.append({y: a/tot for y, a in zip(Y, g)})
        H0.append(S)
    raw = [Fr(random.choice([1, 3, 20])) for _ in H0]; tot = sum(raw)*random.choice([1, 2]); w0 = [a/tot for a in raw]
    ok = (Fr(1, 2**c)*sum(w0) + sum(wm) < 1) and (sum(wm) == Fr(1, 4)*(1 + Fr(1, 2*u))**u)
    vals = []
    for k in range(0, u):
        S = list(range(k)); x = k
        cons = [i for i, T in enumerate(tables) if all(mem_answer(T, xx) == f[xx] for xx in S)]
        def L0(Smp):
            p = Fr(1)
            for xx in S: p *= Smp[xx].get(f[xx], Fr(0))
            return p
        M = sum(wm[i] for i in cons) + Fr(1, 2**c)*sum(w0[i]*L0(H0[i]) for i in range(nH0))
        pb = (sum(wm[i] for i in cons if x not in tables[i]) + Fr(1, 2**c)*sum(w0[i]*L0(H0[i])*H0[i][x].get(B, Fr(0)) for i in range(nH0)))/M
        lb = Fr(2*u, 2*u+1)/(1 + Fr(4, 2**c)*(4*u)**k)
        if pb < lb: ok = False
        vals.append((k, float(Fr(u-k, u)*pb)))
    return ok, vals
res = []
for u in (2, 3, 5):
    for c in (1, 3, 9, 14):
        res.append(check_411(u, c, [random.randrange(2) for _ in range(u)], 4)[0])
print(f"(7) Theorem 4.11: total weight < 1 and M_D(b|x) >= (2u/(2u+1))/(1 + 2^(2-c) (4u)^k) by enumeration (u in {{2, 3, 5}}, c in {{1, 3, 9, 14}}, 4 random semimeasures as H_0): {all(res)}")
for (u, c) in ((5, 9), (8, 14), (8, 15)):
    okk, vals = check_411(u, c, [random.randrange(2) for _ in range(u)], 3)
    kmax = int(min(u/4, (c-4)/log2(4*u)))
    print(f"    u = {u}, c = {c}: n <= min(u/4, (c-4)/log2(4u)) = {kmax}; V(D) for k = 0..{kmax}: " + ", ".join(f"{v:.4f}" for (k, v) in vals if k <= kmax)
          + f"  (claimed > (3/4)(10/11)(4/5) = {0.75*10/11*0.8:.4f}): {all(v > 0.54 for (k, v) in vals if k <= kmax)}")
# the code of U': 0 (1 x t)^k 0 with x of d bits in increasing order; lengths, prefix-freeness, Kraft sum
for d in (1, 2, 3):
    u = 2**d; codes = []
    for T in all_tables(u):
        q = "".join("1" + format(x, f"0{d}b") + str(T[x]) for x in sorted(T)) + "0"
        codes.append(("0" + q, len(T)))
    okl = all(len(cw) == 2 + k*(d+2) for cw, k in codes)
    kraft = sum(Fr(1, 2**len(cw)) for cw, _ in codes)
    cs = sorted(cw for cw, _ in codes); pf = all(not cs[i+1].startswith(cs[i]) for i in range(len(cs)-1))
    print(f"    code of the memorisers for d = {d}: lengths 2 + |T|(d+2): {okl}; prefix-free: {pf}; sum of 2^-length = {float(kraft):.6f} = (1/4)(1 + 1/(2u))^u: {kraft == Fr(1, 4)*(1 + Fr(1, 2*u))**u}; no codeword starts with 1: {all(cw[0] == '0' for cw in cs)}")
# the parenthesis after Theorem 4.11: adding h_T at four more bits
u = 5; c = 9
tot = Fr(1, 4)*(1 + Fr(1, 2*u))**u*(1 + Fr(1, 16)) + Fr(1, 2**c)
print(f"    with the conditioned memorisers h_T at four more bits: closure constant (1 + 1/16)/(1/16) = {(1 + Fr(1, 16))/Fr(1, 16)}; total weight {float(tot):.4f} < 1; lower bound multiplied by 16/17: {0.75*10/11*0.8*16/17:.4f} > 0.51")

# ================================================================= (8) Proposition 4.12 by exact enumeration
# The bound itself is far from tight in classes small enough to enumerate (see the first lines of output), so the step of the proof is
# checked directly: for every threshold t, the event "V(D_n) > t for some n at which the inputs are still distinct" has the same
# probability when the human is a random function F with F(x) ~ S(.|x) as when the human is the sampler S.
def check_412(u, wS, pS, base):
    """S answers 1 with probability pS[x] and 0 otherwise (never the bad answer).  Class: S and all memorisers with weights prop. to base^-|T|."""
    tables = list(all_tables(u)); raw = [Fr(1, base**len(T)) for T in tables]; cm = (1 - wS)/sum(raw); wm = [cm*a for a in raw]
    assert wS + sum(wm) == 1
    def VD(D):
        lS = Fr(1)
        for (x, y) in D: lS *= (pS[x] if y == 1 else 1 - pS[x])
        cons = [i for i, T in enumerate(tables) if all(mem_answer(T, x) == y for x, y in D)]
        M = wS*lS + sum(wm[i] for i in cons)
        return sum(wm[i]*Fr(u - len(tables[i]), u) for i in cons)/M     # a memoriser violates at the inputs outside its table
    cache = {}; nmax = 4
    def worstV(xs, ys):
        """max of V(D_n) over the n <= nmax at which x_1..x_n are distinct."""
        best = Fr(-1)
        for n in range(1, nmax+1):
            if len(set(xs[:n])) < n: break
            key = tuple(sorted(zip(xs[:n], ys[:n])))
            if key not in cache: cache[key] = VD(key)
            best = max(best, cache[key])
        return best
    distF = {}; distS = {}
    for xs in itertools.product(range(u), repeat=nmax):
        px = Fr(1, u**nmax)
        for F in itertools.product((0, 1), repeat=u):                    # experiment 1: a random function
            pF = Fr(1)
            for x in range(u): pF *= (pS[x] if F[x] == 1 else 1 - pS[x])
            v = worstV(xs, [F[x] for x in xs]); distF[v] = distF.get(v, Fr(0)) + px*pF
        for ys in itertools.product((0, 1), repeat=nmax):                # experiment 2: the sampler S, fresh draws also at repeated inputs
            pY = Fr(1)
            for x, y in zip(xs, ys): pY *= (pS[x] if y == 1 else 1 - pS[x])
            v = worstV(xs, ys); distS[v] = distS.get(v, Fr(0)) + px*pY
    same = (distF == distS)
    KS = log2(1/float(wS)); rows = []
    for delta in (0.9, 0.5, 0.1):
        pbad = Fr(0)
        for xs in itertools.product(range(u), repeat=nmax):
            for F in itertools.product((0, 1), repeat=u):
                pF = Fr(1)
                for x in range(u): pF *= (pS[x] if F[x] == 1 else 1 - pS[x])
                bad = False
                for n in range(1, nmax+1):
                    if len(set(xs[:n])) < n: break
                    if float(cache[tuple(sorted((x, F[x]) for x in xs[:n]))]) > (KS*log(2) + log(1/delta))/n + 1e-12: bad = True; break
                if bad: pbad += Fr(1, u**nmax)*pF
        rows.append((delta, float(pbad)))
    return same, rows, float(max(distF)), len(distF)
for (u, wS, pS, base) in ((4, Fr(1, 2), [Fr(1, 2)]*4, 16), (4, Fr(1, 50), [Fr(1, 2), Fr(1, 3), Fr(9, 10), Fr(1, 2)], 1), (4, Fr(1, 1000), [Fr(1, 4)]*4, 2)):
    same, rows, vmax, nv = check_412(u, wS, pS, base)
    print(f"(8) Proposition 4.12, u = {u}, w(S) = {wS}, memoriser weights prop. to {base}^-|T|: the law of max_n V(D_n) over the distinct prefix ({nv} values, largest {vmax:.4f}) is the same")
    print(f"    for a random function F ~ S and for the sampler S: {same}; exact Pr[the bound of 4.12 fails] for delta = 0.9, 0.5, 0.1: " + ", ".join(f"{pb:.5f}" for (_, pb) in rows) + " (each must be <= its delta)")

# ================================================================= (9) Theorem 4.11: the price of R and the closure constant on the machine U'
# On U' as constructed in the file, a program that decides R is a U-program behind the prefix 1^c, so K_U'(R) = c + K_U(R) >= c + 1,
# and the conditioned memorisers h_T are U-programs too, so the closure constant of the class of all U'-programs is about 2^c.
# The phenomenon lasts (c - 4)/(d + 2) questions, which is LESS than K_U'(R) and than log2 C_R.  So U' does not separate the price K
# from the price K(R) measured on the same machine.  The following variant U'' does: programs
#     1^c p            -> U(p)                                 (weight 2^-c 2^-|p|)
#     00 q             -> the memoriser g_T                    (weight (1/8)(4u)^-|T|)
#     010000           -> a decider of R (as a sampler it gives no answer at the inputs of X)   (weight 2^-6)
#     011000 q         -> the conditioned memoriser h_T        (weight (1/128)(4u)^-|T| = w(g_T)/16)
# Then K_U''(R) <= 6 for every c, the class is closed under conditioning on R with C_R = max(17, 2^(K_U(R) + c_U)) for every c,
# and the claim to check is V(D) > 0.51 for all data sets of n <= min(u/4, (c - 5)/log2(4u)) pairs.
def check_411_variant(u, c, f, nH0):
    tables = list(all_tables(u))
    wg = [Fr(1, 8)*Fr(1, (4*u)**len(T)) for T in tables]; wh = [a/16 for a in wg]; wdec = Fr(1, 64)
    Y = [0, 1, B, "other"]; H0 = []
    for _ in range(nH0):
        S = []
        for x in range(u):
            g = [Fr(random.choice([0, 1, 2, 5])) for _ in Y]; tot = sum(g) + Fr(random.choice([0, 1])) or Fr(1)
            S.append({y: a/tot for y, a in zip(Y, g)})
        H0.append(S)
    raw = [Fr(random.choice([1, 3, 20])) for _ in H0]; tot = sum(raw); w0 = [a/tot for a in raw]         # total weight exactly 2^-c after scaling
    total = Fr(1, 2**c)*sum(w0) + sum(wg) + sum(wh) + wdec
    ok = total < 1
    # closure of the memoriser part: g_T and h_T are mapped to h_T
    if any((wg[i] + wh[i])/wh[i] != 17 for i in range(len(tables))): ok = False
    vals = []
    for k in range(0, u):
        S = list(range(k)); x = k
        cons = [i for i, T in enumerate(tables) if all(mem_answer(T, xx) == f[xx] for xx in S)]
        def L0(Smp):
            p = Fr(1)
            for xx in S: p *= Smp[xx].get(f[xx], Fr(0))
            return p
        M = sum(wg[i] + wh[i] for i in cons) + Fr(1, 2**c)*sum(w0[i]*L0(H0[i]) for i in range(nH0)) + (wdec if k == 0 else 0)
        pb = (sum(wg[i] for i in cons if x not in tables[i]) + Fr(1, 2**c)*sum(w0[i]*L0(H0[i])*H0[i][x].get(B, Fr(0)) for i in range(nH0)))/M
        if k >= 1 and pb < Fr(16, 17)*Fr(2*u, 2*u+1)/(1 + Fr(8, 2**c)*(4*u)**k): ok = False
        vals.append(float(Fr(u-k, u)*pb))
    return ok, vals, float(total)
print("(9) Theorem 4.11, the price of R on the machine: on U' of the file K_U'(R) >= c + 1 and log2 C_R is about c, while the phenomenon lasts (c-4)/(d+2) < c questions.")
for (u, c) in ((8, 10), (8, 15), (8, 20), (16, 17)):
    d = int(log2(u)); f = [random.randrange(2) for _ in range(u)] if u <= 8 else None
    if u <= 8:
        okv, vals, total = check_411_variant(u, c, f, 3)
        kmax = int(min(u/4, (c-5)/log2(4*u)))
        print(f"    variant U'' (K(R) <= 6, C_R independent of c), u = {u}, c = {c}: total weight {total:.4f} < 1 and M_D(b|x) >= (16/17)(2u/(2u+1))/(1 + 2^(3-c)(4u)^k) for k >= 1: {okv};"
              f" V(D) for k = 0..{kmax}: " + ", ".join(f"{v:.4f}" for v in vals[:kmax+1]) + f" (all > 0.51: {all(v > 0.51 for v in vals[:kmax+1])})")
# closed form for larger u: V for k >= 1 is at least ((u-k)/u)(16/17)(2u/(2u+1))/(1 + 2^(3-c)(4u)^k); for k = 0 the decider and the U-part enter
okbig = True; cnt = 0
for d in range(3, 21):
    u = 2**d
    for c in (5, 6, 10, 20, 50, 200, 1000):
        Wm0 = (1 + 1/(2*u))**u/8
        v0 = Wm0*(2*u/(2*u+1))/(Wm0*17/16 + 2.0**-c + 2.0**-6); cnt += 1
        if v0 <= 0.51: okbig = False
        for k in range(1, int(min(u/4, (c-5)/(d+2)))+1):
            v = (u-k)/u*(16/17)*(2*u/(2*u+1))/(1 + 2.0**(3-c)*float((4*u)**k)); cnt += 1
            if v <= 0.51: okbig = False
print(f"    lower bounds for U'' on {cnt} triples (u = 2^d with 3 <= d <= 20, c from 5 to 1000, all k <= min(u/4, (c-5)/(d+2)), including k = 0): all above 0.51: {okbig};"
      f" the constant: (3/4)(16/17)(10/11)(4/5) = {0.75*16/17*10/11*0.8:.4f}")
# what every class that contains the fair coin gives, for every human with answers in {0,1}: 1 - V >= (1/2)(delta w(coin))^(1/n)  (Theorem 4.7(c))
for kc in (10, 100, 1000):
    delta = 0.1; a = kc*log(2) + log(1/delta)
    ns = [int(a/0.08) + 1, 10*kc, 100*kc]
    print(f"    coin of weight 2^-{kc} in the class, delta = 0.1: V <= 1 - (1/2)(delta 2^-kc)^(1/n) = " + ", ".join(f"{1 - 0.5*math.exp(-a/n):.4f} at n = {n}" for n in ns))

# ================================================================= (10) Proposition 4.9: rehearsal, exact expectations on a small scaffold
# X = {0,1}; answers 0, 1 and the bad answer (index 2); the human answers 1 at x with probability p_x and never gives the bad answer.
# Scaffold of horizon L = 2: z uniform on {0,1}; call 1 at x = z; if the first answer is 0 or 1, call 2 at that answer; otherwise stop.
# Rehearsal as in note.md, Section 2: run with the mixture M^(t), draw J uniform on {1,2}, put the J-th call (if it exists) to the human.
def rehearsal_check(n, seed):
    rnd = random.Random(seed)
    P = [[1 - p, p, 0.0] for p in (rnd.choice([0.0, 0.2, 0.5]), rnd.choice([1.0, 0.7, 0.5]))]
    H = [P]
    for _ in range(rnd.choice([2, 4])):
        S = []
        for x in range(2):
            g = [rnd.choice([0.0, 1.0, 2.0]) for _ in range(3)]
            if sum(g) == 0: g[2] = 1.0
            tot = sum(g) + rnd.choice([0.0, 0.0, 1.0])           # a deficit: the hypothesis may give no answer
            S.append([a/tot for a in g])
        H.append(S)
    raw = [rnd.choice([1.0, 5.0, 50.0]) for _ in H]; raw[0] = rnd.choice([0.05, 1.0]); tot = sum(raw); w = [a/tot for a in raw]
    Kln2 = log(1/w[0]); L = 2
    def mixture(D):
        post = []
        for i, S in enumerate(H):
            li = w[i]
            for (x, y) in D: li *= S[x][y]
            post.append(li)
        M = sum(post); post = [a/M for a in post]
        return [[sum(post[i]*H[i][x][y] for i in range(len(H))) for y in range(3)] for x in range(2)]
    def kl_at(Mx, x): return sum(P[x][y]*log(P[x][y]/Mx[x][y]) for y in range(2) if P[x][y] > 0)
    tot_kl_calls = 0.0; tot_v_calls = 0.0; tot_lnv_calls = 0.0; tot_v_asked = 0.0; tot_lnv_asked = 0.0; last_round_viol = []
    states = {(): 1.0}
    for t in range(n):
        new = {}; viol_t = 0.0
        for D, pD in states.items():
            Mx = mixture(D)
            ask = {0: 0.0, 1: 0.0}; e_kl = 0.0; e_v = 0.0; e_lnv = 0.0
            for z in range(2):
                pz = 0.5
                # call 1 at x = z always exists
                ask[z] += pz/L; e_kl += pz*kl_at(Mx, z); e_v += pz*Mx[z][2]; e_lnv += pz*log(1/(1 - Mx[z][2]))
                for y1 in range(2):                               # call 2 exists iff the first answer is 0 or 1
                    p2 = pz*Mx[z][y1]
                    ask[y1] += p2/L; e_kl += p2*kl_at(Mx, y1); e_v += p2*Mx[y1][2]; e_lnv += p2*log(1/(1 - Mx[y1][2]))
            tot_kl_calls += pD*e_kl; tot_v_calls += pD*e_v; tot_lnv_calls += pD*e_lnv; viol_t += pD*e_v
            p_none = 1.0 - ask[0] - ask[1]
            new[D] = new.get(D, 0.0) + pD*p_none
            for x in range(2):
                tot_v_asked += pD*ask[x]*Mx[x][2]; tot_lnv_asked += pD*ask[x]*log(1/(1 - Mx[x][2]))
                for y in range(2):
                    if P[x][y] > 0:
                        D2 = tuple(sorted(D + ((x, y),))); new[D2] = new.get(D2, 0.0) + pD*ask[x]*P[x][y]
        states = new; last_round_viol.append(viol_t)
    return (tot_kl_calls/(L*Kln2), tot_lnv_calls/(L*Kln2), tot_v_calls/(L*Kln2), tot_lnv_asked/Kln2, tot_v_asked/Kln2,
            (sum(last_round_viol)/n)/(L*Kln2/n), tot_v_asked <= tot_lnv_asked + 1e-12)
worst = [0.0]*6; okord = True
for seed in range(200):
    for n in (1, 3, 6):
        r = rehearsal_check(n, seed)
        for i in range(6): worst[i] = max(worst[i], r[i])
        okord = okord and r[6]
print("(10) Proposition 4.9 and the step of Theorem R1 it uses, exact expectations, 200 random classes x n in {1, 3, 6} (largest ratio left side/right side; each must be <= 1):")
print(f"    sum_t E[sum over calls of KL_t]/(L K ln2) = {worst[0]:.4f}; sum_t E[sum over calls of ln(1/(1-v))]/(L K ln2) = {worst[1]:.4f}; sum_t E[sum over calls of v]/(L K ln2) = {worst[2]:.4f};")
print(f"    asked calls: sum_t E[ln(1/(1-v))]/(K ln2) = {worst[3]:.4f}; sum_t E[v]/(K ln2) = {worst[4]:.4f}; expected violating calls of the run of M^(T)/(L K ln2/n) = {worst[5]:.4f}; sum v <= sum ln(1/(1-v)): {okord}")

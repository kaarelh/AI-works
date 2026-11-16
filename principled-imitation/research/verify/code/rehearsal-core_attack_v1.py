#!/usr/bin/env python3
"""
Attack on Theorem V1 of note.md (Theorem 13.1 of research/prove-c/rehearsal-core.md)
and on the sentences that follow it.

Part A.  V1(a) is stated for a deterministic human.  Claim tested here: for ANY human
         (assumption H1 only) the probability rho_dis of a recorded disagreement in one
         validation round satisfies   beta(A)/L <= rho_dis <= beta(A)/L + s_P,
         where s_P is the same quantity for A = P (the human's own noise along A's runs).
         So "no disagreement in m rounds" certifies beta(A) <= L ln(1/delta)/m for every
         human; the statement "the rate of recorded disagreement says nothing about
         faithfulness" (13.1(c)) holds in one direction only.  Exact check on random
         instances (kernels and answerers that depend on the history).
Part B.  "For a human who is not deterministic only frequencies of tests can be
         estimated": the two-human construction that the outline asks for.
         B1: single answers, each input asked at most once: fair coin at every input
             against a uniformly random function; exact total variation between the two
             laws of a validation transcript of m rounds on N inputs.
         B2: any questions, repeated or not, answers from a set of size M: uniform on Y
             against uniform on a random half of Y (a new half at every input); exact
             total variation of r answers at one input, and the bound m(m-1)/(2M).
         In both cases the imitator A = (the first human) has beta = 0 against the first
         human and beta = L/2 against every human of the second kind.
Part C.  The other direction: under A1 the same question may be put several times.  For a
         small answer set this certifies beta(A) for a human who is not deterministic,
         with no assumption A2: simulation of the coverage of the bound
            beta(A)/L <= mean_i a_i TV(A(.|x_i), empirical law of r answers)
                         + (1/2) sqrt((|Y|-1)/r) + sqrt(ln(1/delta)/(2m)).
Part D.  Corollary 13.2 says a certificate, "whenever it is issued, is false with
         probability less than delta".  Exact numbers for the conditional probability.
"""
import math, random, itertools

STOP = -1

# ---------------------------------------------------------------- Part A
def partA():
    rng = random.Random(1301)
    worst_low = 1e9; worst_high = -1e9; n = 0
    for it in range(3000):
        nx, ny, L, nz = rng.choice([(3, 2, 3, 2), (4, 3, 3, 1), (3, 3, 2, 2), (5, 2, 4, 1)])
        D0 = [rng.random()+0.01 for _ in range(nz)]; s = sum(D0); D0 = [v/s for v in D0]
        nxt = {}
        for z in range(nz):
            for j in range(1, L+1):
                for hist in itertools.product(range(ny), repeat=j-1):
                    nxt[(z, hist)] = STOP if (j > 1 and rng.random() < 0.15) else rng.randrange(nx)
        def row():
            k = rng.choice(['det', 'dense', 'skew'])
            if k == 'det':
                r = [0.0]*ny; r[rng.randrange(ny)] = 1.0; return r
            r = [rng.random()**(4 if k == 'skew' else 1)+1e-9 for _ in range(ny)]; s = sum(r); return [v/s for v in r]
        P = [row() for _ in range(nx)]
        hist_dep = rng.random() < 0.5
        Atab = {}
        def A(z, hist, x):
            key = (z, hist) if hist_dep else x
            if key not in Atab:
                Atab[key] = list(P[x]) if rng.random() < 0.4 else row()
            return Atab[key]
        beta = dis = selfn = 0.0
        for z in range(nz):
            stack = [((), D0[z])]
            while stack:
                hist, pr = stack.pop()
                j = len(hist)+1
                if j > L or nxt[(z, hist)] == STOP: continue
                x = nxt[(z, hist)]; a = A(z, hist, x); p = P[x]
                beta += pr*0.5*sum(abs(a[y]-p[y]) for y in range(ny))
                dis += pr*(1.0-sum(a[y]*p[y] for y in range(ny)))
                selfn += pr*(1.0-sum(p[y]*p[y] for y in range(ny)))
                for y in range(ny):
                    if a[y] > 0: stack.append((hist+(y,), pr*a[y]))
        # one validation round records a disagreement with probability dis/L
        worst_low = min(worst_low, dis-beta); worst_high = max(worst_high, dis-beta-selfn); n += 1
    print("== Part A: the disagreement rate bounds beta for every human ==")
    print(f"{n} random instances (stochastic humans; kernels and history-dependent answerers):")
    print(f"  smallest value of L*rho_dis - beta(A)          = {worst_low:.3e}   (claim: >= 0)")
    print(f"  largest value of  L*rho_dis - beta(A) - L*s_P  = {worst_high:.3e}   (claim: <= 0)")

# ---------------------------------------------------------------- Part B
def distinct_law(N, m):
    """law of the number of distinct values among m uniform draws from N."""
    law = {0: 1.0}
    for i in range(m):
        new = {}
        for d, pr in law.items():
            if d > 0: new[d] = new.get(d, 0.0)+pr*d/N
            if d < N: new[d+1] = new.get(d+1, 0.0)+pr*(N-d)/N
        law = new
    return law

def tv_half(M, r):
    """exact TV between r i.i.d. uniform draws from a set of size M and r draws from a
    uniformly random half of it.  Both laws are exchangeable in the values, so they are
    functions of the pattern of repeats; compare by the number of distinct values and,
    within it, by the set partition.  For a partition of {1..r} into d blocks:
      uniform:      falling(M, d) / M^r
      random half:  falling(M, d) * [falling(M/2, d)/falling(M, d)] / (M/2)^r = falling(M/2,d)/(M/2)^r
    (probability that the r draws realise that partition, summed over the values)."""
    from fractions import Fraction
    h = M//2
    def falling(a, d):
        v = 1
        for i in range(d): v *= (a-i)
        return v
    # Stirling numbers of the second kind S(r, d)
    S = [[0]*(r+1) for _ in range(r+1)]; S[0][0] = 1
    for i in range(1, r+1):
        for d in range(1, i+1):
            S[i][d] = d*S[i-1][d]+S[i-1][d-1]
    tv = Fraction(0)
    for d in range(1, r+1):
        p1 = Fraction(falling(M, d), M**r)
        p2 = Fraction(falling(h, d), h**r)
        tv += S[r][d]*abs(p1-p2)
    return float(tv/2)

def partB():
    print("== Part B1: a fair coin against a random function; each input asked once per round ==")
    print("L = 1, N inputs drawn uniformly, A = fair coin: beta = 0 against the coin, 1/2 against every function.")
    for (N, m) in [(10**4, 10), (10**4, 50), (10**6, 100), (10**6, 1000), (10**9, 1000), (10**9, 10**4)]:
        if m <= 2000:
            law = distinct_law(N, m)
            tv = sum(pr*(1.0-2.0**(d-m)) for d, pr in law.items())
            print(f"  N={N:>10} m={m:>5}: exact TV between the two laws of the validation transcript = {tv:.3e}   (m(m-1)/(2N) = {m*(m-1)/(2*N):.3e})")
        else:
            print(f"  N={N:>10} m={m:>5}: TV <= m(m-1)/(2N) = {m*(m-1)/(2*N):.3e}")
    print("  A procedure that certifies 'beta(A) < 1/2' with probability c when the human is the coin")
    print("  certifies it with average probability at least c - TV when the human is a function, where it is false.")
    print("== Part B2: uniform on Y against uniform on a random half of Y; questions may be repeated ==")
    for (M, r) in [(16, 2), (16, 4), (256, 4), (256, 16), (2**16, 16), (2**16, 64)]:
        tv = tv_half(M, r)
        print(f"  |Y|={M:>6} r={r:>3} answers at one input: exact TV = {tv:.3e}   (r(r-1)/(2M) = {r*(r-1)/(2*M):.3e})")
    print("  For m questions in all, at any inputs: TV <= m(m-1)/(2|Y|).  With answers of 100 bits and m = 10^9: "
          f"{1e9*(1e9-1)/(2*2.0**100):.1e}")

# ---------------------------------------------------------------- Part C
def partC():
    print("== Part C: re-asking certifies beta for a small answer set, with no assumption A2 ==")
    rng = random.Random(77)
    ny = 2; nx = 6; L = 1
    P = [[0.5+0.4*(rng.random()-0.5)] for _ in range(nx)]
    P = [[p[0], 1-p[0]] for p in P]
    cases = {'A = P (beta = 0)': [list(r) for r in P],
             'A shifted by 0.1 at every input': [[min(1.0, r[0]+0.1), 1-min(1.0, r[0]+0.1)] for r in P],
             'A deterministic (coins filled in)': [[1.0, 0.0] if r[0] >= 0.5 else [0.0, 1.0] for r in P]}
    delta = 0.1
    import numpy as np
    nrng = np.random.default_rng(77)
    Pa = np.array([row[0] for row in P])
    for (m, r) in [(200, 100), (400, 400)]:
        for name, A in cases.items():
            Aa = np.array([row[0] for row in A])
            beta = sum(0.5*sum(abs(A[x][y]-P[x][y]) for y in range(ny)) for x in range(nx))/nx
            fails = 0; trials = 4000; avg_bound = 0.0
            slack = 0.5*math.sqrt((ny-1)/r)+math.sqrt(math.log(1/delta)/(2*m))
            for tr in range(trials):
                xs = nrng.integers(nx, size=m)
                ph = nrng.binomial(r, Pa[xs])/r
                tot = float(np.abs(Aa[xs]-ph).sum())    # TV between A(.|x) and the empirical law, two answers
                bound = tot/m+slack
                avg_bound += bound/trials
                if beta > bound: fails += 1
            print(f"  m={m} rounds x r={r} repeats, {name}: beta/L = {beta:.4f}; mean certified bound = {avg_bound:.4f}; "
                  f"bound violated in {fails}/{trials} trials (allowed: {delta})")
    print("  The estimate also has a lower side: mean_i TV - slack <= beta/L with the same probability, so a faithful A is recognised.")

# ---------------------------------------------------------------- Part D
def partD():
    print("== Part D: 'whenever it is issued it is false with probability less than delta' ==")
    delta = 0.05
    for m in [100, 1000]:
        thr = math.log(1/delta)/m
        print(f"  m={m}, delta={delta}: the certificate says rho <= {thr:.5f}.")
        for c in [1.01, 2.0, 5.0]:
            rho = c*thr
            p_issue = (1-rho)**m
            print(f"    a fixed imitator with rho = {c} x threshold: certificate issued with probability {p_issue:.2e} (< delta: {p_issue < delta}); "
                  f"given that it is issued it is false with probability 1")
        # a population reading: prior mass q on a good imitator (rho = 0), 1-q on a bad one
        for q in [0.5, 0.01]:
            rho = 2*thr
            p_bad = (1-rho)**m
            post = (1-q)*p_bad/(q*1.0+(1-q)*p_bad)
            print(f"    if the frozen imitator is good (rho = 0) with probability {q} and has rho = 2 x threshold otherwise: "
                  f"Pr[issued and false] = {(1-q)*p_bad:.2e}, Pr[false | issued] = {post:.3f}")
    print("  The theorem bounds Pr[issued and false] by delta for every imitator; it does not bound Pr[false | issued].")
    print("  Repeating a failed validation of the same imitator r times multiplies the bound by r (union bound).")

if __name__ == '__main__':
    partA(); print(); partB(); print(); partC(); print(); partD()

#!/usr/bin/env python3
"""
Attack on Theorem R3 of note.md (Theorem 8.4 of research/prove-c/rehearsal-core.md),
on the definition of tolerance, and on Proposition R3a of note.md.

Part 1.  R3 with the note's definition (rules that see the run so far and the human's
         answer).  For random small human systems (stochastic human, inputs that depend
         on the answers, runs of variable length, random sets G) the exact worst-case
         failure delta*(k) over ALL rules with at most k replacements is computed by
         dynamic programming, and for random kernels C the exact Q_C(not G) and beta(C).
         Checked: Q_C(not G) <= delta*(k) + beta(C)/(k+1) for every k; then a local
         search over C tries to make the left side exceed the right side.
Part 2.  The clause "sees the human's answer" is needed.  A rule is called blind if it
         decides, before the human's answer is seen, whether it answers the call itself;
         every call it answers counts as a fault.  Exact numbers for a human system that
         tolerates k blind faults with small failure while an imitator with
         beta/(k+1) small fails with probability 1.
Part 3.  R3a of note.md is stated for a "sequential scaffold"; Section 1 of the note
         lets a scaffold stop early.  A scaffold in which a replaced answer makes the
         run stop satisfies the hypotheses of R3a as written and tolerates no fault.
"""
import math, random, itertools
from math import comb

STOP = -1

# ---------------------------------------------------------------- Part 1
def make_system(rng, nx, ny, L, nz):
    D0 = [rng.random()+0.05 for _ in range(nz)]; s = sum(D0); D0 = [v/s for v in D0]
    nxt = {}
    pstop = rng.choice([0.0, 0.0, 0.2])
    for z in range(nz):
        for j in range(1, L+1):
            for hist in itertools.product(range(ny), repeat=j-1):
                nxt[(z, hist)] = STOP if (j > 1 and rng.random() < pstop) else rng.randrange(nx)
    P = []
    for x in range(nx):
        kind = rng.choice(['det', 'sparse', 'dense'])
        if kind == 'det':
            r = [0.0]*ny; r[rng.randrange(ny)] = 1.0
        elif kind == 'sparse':
            r = [0.0]*ny; a, b = rng.sample(range(ny), 2); p = rng.choice([0.05, 0.2, 0.5]); r[a] = p; r[b] = 1-p
        else:
            r = [rng.random()+0.02 for _ in range(ny)]; s = sum(r); r = [v/s for v in r]
        P.append(r)
    # the set of bad runs: random subset of complete runs, biased so that the human system is mostly good
    bad = {}
    style = rng.choice(['random', 'count', 'last'])
    target = rng.randrange(ny)
    def is_bad(z, hist):
        if style == 'count':
            return sum(1 for y in hist if y == target) >= 2
        if style == 'last':
            return len(hist) > 0 and hist[-1] == target
        return rng.random() < 0.3
    return dict(nx=nx, ny=ny, L=L, nz=nz, D0=D0, nxt=nxt, P=P, bad=bad, is_bad=is_bad)

def terminal_bad(S, z, hist):
    key = (z, hist)
    if key not in S['bad']:
        S['bad'][key] = bool(S['is_bad'](z, hist))
    return 1.0 if S['bad'][key] else 0.0

def worst_case(S, kmax):
    """delta*(k), k = 0..kmax: sup over rules in R_all with at most k replacements."""
    ny, L = S['ny'], S['L']
    memo = {}
    def V(z, hist, b):
        key = (z, hist, b)
        if key in memo: return memo[key]
        j = len(hist)+1
        if j > L or S['nxt'][(z, hist)] == STOP:
            v = terminal_bad(S, z, hist)
        else:
            x = S['nxt'][(z, hist)]
            v = 0.0
            for yp in range(ny):
                p = S['P'][x][yp]
                if p <= 0: continue
                best = V(z, hist+(yp,), b)
                if b > 0:
                    for y in range(ny):
                        if y != yp:
                            best = max(best, V(z, hist+(y,), b-1))
                v += p*best
        memo[key] = v
        return v
    return [sum(S['D0'][z]*V(z, (), k) for z in range(S['nz'])) for k in range(kmax+1)]

def kernel_stats(S, C):
    """Q_C(not G) and beta(C)."""
    ny, L = S['ny'], S['L']
    tv = [0.5*sum(abs(C[x][y]-S['P'][x][y]) for y in range(ny)) for x in range(S['nx'])]
    fail = 0.0; beta = 0.0
    for z in range(S['nz']):
        stack = [((), S['D0'][z])]
        while stack:
            hist, pr = stack.pop()
            j = len(hist)+1
            if j > L or S['nxt'][(z, hist)] == STOP:
                fail += pr*terminal_bad(S, z, hist); continue
            x = S['nxt'][(z, hist)]
            beta += pr*tv[x]
            for y in range(ny):
                if C[x][y] > 0:
                    stack.append((hist+(y,), pr*C[x][y]))
    return fail, beta

def rand_kernel(rng, S, closeness):
    C = []
    for x in range(S['nx']):
        if rng.random() < closeness:
            C.append(list(S['P'][x]))
        else:
            kind = rng.choice(['det', 'dense', 'mixP'])
            if kind == 'det':
                r = [0.0]*S['ny']; r[rng.randrange(S['ny'])] = 1.0
            elif kind == 'dense':
                r = [rng.random() for _ in range(S['ny'])]; s = sum(r); r = [v/s for v in r]
            else:
                e = rng.choice([0.01, 0.1, 0.3]); d = [0.0]*S['ny']; d[rng.randrange(S['ny'])] = 1.0
                r = [(1-e)*S['P'][x][y]+e*d[y] for y in range(S['ny'])]
            C.append(r)
    return C

def part1():
    rng = random.Random(8415)
    worst = -1e9; n_checks = 0
    for it in range(400):
        nx, ny, L, nz = rng.choice([(3, 3, 3, 2), (4, 2, 4, 2), (2, 3, 3, 1), (3, 2, 5, 1)])
        S = make_system(rng, nx, ny, L, nz)
        dstar = worst_case(S, L)
        for trial in range(15):
            C = rand_kernel(rng, S, rng.choice([0.0, 0.5, 0.8]))
            fail, beta = kernel_stats(S, C)
            for k in range(L+1):
                worst = max(worst, fail-(dstar[k]+beta/(k+1))); n_checks += 1
        # local search on the last kernel: maximise the smallest slack over k
        def slack(C):
            fail, beta = kernel_stats(S, C)
            return max(fail-(dstar[k]+beta/(k+1)) for k in range(L+1))
        cur = slack(C)
        for step in range(60):
            C2 = [list(r) for r in C]
            x = rng.randrange(nx)
            r = [max(0.0, v+rng.gauss(0, 0.2)) for v in C2[x]]; s = sum(r)
            if s <= 0: continue
            C2[x] = [v/s for v in r]
            v2 = slack(C2)
            if v2 > cur: cur = v2; C = C2
        worst = max(worst, cur)
    print("== Part 1: Theorem R3 with the note's definition of tolerance ==")
    print(f"400 random human systems, {n_checks} checks plus local search:")
    print(f"  largest value of Q_C(not G) - (delta*(k) + beta(C)/(k+1)) = {worst:.3e}   (a positive value would refute R3)")

# ---------------------------------------------------------------- Part 2
def binom_cdf(n, p, k):
    if k < 0: return 0.0
    tot = 0.0
    for i in range(0, min(k, n)+1):
        tot += math.exp(math.lgamma(n+1)-math.lgamma(i+1)-math.lgamma(n-i+1)+i*math.log(p)+(n-i)*math.log1p(-p))
    return min(1.0, tot)

def part2():
    print("== Part 2: tolerance against rules that do not see the human's answer does not suffice ==")
    print("Human system: L calls at one input; the human answers 1 with probability mu, else 0; G = {some answer is 1}.")
    print("Imitator C: always 0.  beta(C) = mu L, Q_C(not G) = 1.")
    for (L, mu, k) in [(60, 0.05, 3), (400, 0.01, 39), (4000, 0.002, 399)]:
        d0 = (1-mu)**L
        # blind rule with k faults: it answers k calls itself (any k calls; answer 0), the human answers L-k calls
        blind = (1-mu)**(L-k)
        # rule that sees the human's answer: replaces the first k answers equal to 1
        seeing = binom_cdf(L, mu, k)
        beta = mu*L
        print(f"  L={L} mu={mu} k={k}: human system fails {d0:.4f}; worst blind rule with k faults: {blind:.4f}; "
              f"worst rule that sees the answer, k replacements: {seeing:.4f}; beta/(k+1) = {beta/(k+1):.4f}")
        print(f"      'R3 with blind tolerance' would give {blind+beta/(k+1):.4f} < 1 = true failure of C;   "
              f"R3 as stated gives {min(1.0, seeing+beta/(k+1)):.4f}")

# ---------------------------------------------------------------- Part 3
def part3():
    print("== Part 3: R3a as written in note.md, on a scaffold that may stop early ==")
    print("Scaffold: at each of at most L calls the answer 'go' raises phi by 1; any other answer stops the run (phi unchanged).")
    print("Human: always 'go'.  Then mu = 1, human steps change phi by 1, no answer lowers phi (D = 0).")
    for (L, eta, delta) in [(1000, 0.5, 0.01), (100, 0.9, 0.1)]:
        m = int((eta*L-math.sqrt(8*L*math.log(1/delta)))//1)
        print(f"  L={L} eta={eta} delta={delta}: the condition m(1+D) + sqrt(8 L ln(1/delta)) <= eta mu L of note.md allows m = {m} faults;")
        print(f"      one replaced answer at call 1 stops the run: phi rises by 0 < (1-eta) mu L = {(1-eta)*L:.0f}; the run is bad with probability 1.")

if __name__ == '__main__':
    part1(); print(); part2(); print(); part3()

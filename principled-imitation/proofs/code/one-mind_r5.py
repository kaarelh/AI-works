"""R5: the trap scaffold. (1) class A (g_0 and N traps, human g_0, K = 1 bit): exact law of the number k of
surviving traps under the posterior-draw driver and under the mixture driver, and exact probabilities of
many unfaithful calls; (2) Monte Carlo of the protocols themselves as a check of (1); (3) class B (N traps,
no consensus member, human a uniformly random trap): the first consistent member against the mixture.
Usage: python3 one-mind_r5.py"""
import math
import numpy as np
from math import comb

def trans_one(N, L, k):
    """Pr[a trap is removed in one round | k traps survive], posterior-draw driver, human g_0."""
    if k == 0:
        return 0.0
    q = 1 - 1 / N
    s = q ** L * (k - 1) / (N - 1)
    for i in range(1, L + 1):
        s += q ** (i - 1) / N * ((i - 1) / L * (k - 1) / (N - 1) + (L - i + 1) / L)
    return N / (N + k) * k / N + k / (N + k) * s

def trans_mix(N, L, k):
    e0 = k / N / (N + k)                                   # an unflagged call is unfaithful
    return sum((1 - e0) ** (J - 1) * k / N + 1 - (1 - e0) ** (J - 1) for J in range(1, L + 1)) / L

def law_of_k(N, L, n, trans):
    p = np.zeros(N + 1); p[N] = 1.0
    tr = np.array([trans(N, L, k) for k in range(N + 1)])
    for _ in range(n):
        new = p * (1 - tr)
        new[:-1] += (p * tr)[1:]
        p = new
    return p

def tail_one(N, L, k, c):                                  # Pr[at least c unfaithful calls], c >= 1
    return k / (N + k) * (1 - (1 - 1 / N) ** (L - c + 1))

def tail_mix(N, L, k, c):
    e0, q = k / N / (N + k), 1 / (N + k)
    tot = 0.0
    for tau in range(1, L + 1):
        m = L - tau
        tb = 1.0 if c <= 1 else sum(comb(m, i) * q ** i * (1 - q) ** (m - i) for i in range(c - 1, m + 1))
        tot += (1 - e0) ** (tau - 1) * e0 * tb
    return tot

print("(1) class A, exact. Imitator built from the data of n = N rounds; c0 = ceil(L/4).")
print("    N=n   L   driver          E[k]/N   Pr[>=1 unf. call]  Pr[>=2]      Pr[>=c0]     (Pr[>=c0])*n/L   bounds: draw >= 0.11 L/n, mixture <= (L/n)^2/2")
for N, L in ((100, 10), (400, 20), (1600, 40), (1600, 20)):
    c0 = math.ceil(L / 4)
    for name, trans, tail in (("posterior draw", trans_one, tail_one), ("mixture", trans_mix, tail_mix)):
        p = law_of_k(N, L, N, trans)
        ks = np.arange(N + 1)
        t = [sum(p[k] * tail(N, L, k, c) for k in range(N + 1)) for c in (1, 2, c0)]
        print(f"   {N:5d} {L:3d}   {name:14s} {p @ ks / N:7.4f} {t[0]:14.5f} {t[1]:14.3e} {t[2]:12.3e} {t[2] * N / L:12.4f}")
        if name == "posterior draw":
            assert t[2] >= 0.11 * L / N
        else:
            assert t[1] <= (L / N) ** 2 / 2 and t[2] <= (L / N) ** c0 / math.factorial(c0)

# ---------- (2) Monte Carlo of the protocols for class A ----------
def simulate_A(N, L, n, driver, rng):
    alive = np.ones(N, dtype=bool)                         # surviving traps
    def run():
        """one run with the current posterior; returns (asked index or None, number of unfaithful calls)"""
        k = int(alive.sum()); z = rng.integers(N, size=L); J = int(rng.integers(L))
        flag, unf, asked = -1, 0, None
        d = -1
        if driver == "draw" and rng.random() < k / (N + k):
            d = int(rng.choice(np.flatnonzero(alive)))
        for j in range(L):
            a = int(z[j])
            if j == J:
                asked = a if flag < 0 else flag            # the question removes trap a (unflagged) or the flag's trap
            if driver == "draw":
                ans = (d >= 0) and (a == d if flag < 0 else flag == d)
            else:                                          # fresh posterior draw at every call
                target = a if flag < 0 else flag
                ans = alive[target] and rng.random() < 1 / (N + k)
            if ans:
                unf += 1
                if flag < 0:
                    flag = a
        return asked, unf
    for _ in range(n):
        asked, _ = run()
        alive[asked] = False
    _, unf = run()
    return int(alive.sum()), unf

rng = np.random.default_rng(12345)
N, L, n, trials = 40, 8, 40, 80000
print(f"\n(2) class A, Monte Carlo of the protocols, N = n = {N}, L = {L}, {trials} rehearsals; exact values in brackets")
for driver, trans, tail in (("draw", trans_one, tail_one), ("mixture", trans_mix, tail_mix)):
    sims = np.array([simulate_A(N, L, n, driver, rng) for _ in range(trials)])
    p = law_of_k(N, L, n, trans)
    ex_k = p @ np.arange(N + 1)
    ex1, ex2 = (sum(p[k] * tail(N, L, k, c) for k in range(N + 1)) for c in (1, 2))
    print(f"   {driver:8s} E[k] = {sims[:, 0].mean():.3f} [{ex_k:.3f}]   Pr[>=1] = {(sims[:, 1] >= 1).mean():.4f} [{ex1:.4f}]"
          f"   Pr[>=2] = {(sims[:, 1] >= 2).mean():.4f} [{ex2:.4f}]")

# ---------- (3) class B ----------
def simulate_B(N, L, n, rng):
    """Mixture-driven rehearsal, human = trap astar. Returns unfaithful calls of (a) the first consistent member,
    (b) the mixture, each on one fresh run after n rounds."""
    astar = int(rng.integers(N))
    alive = np.ones(N, dtype=bool); found = False
    def human(a, flag):
        return (a == astar) if flag < 0 else (flag == astar)
    def run(kind, J=None):
        z = rng.integers(N, size=L); flag, unf, asked = -1, 0, None
        surv = np.flatnonzero(alive)
        d = int(surv[0]) if kind == "first" else -1
        for j in range(L):
            a = int(z[j])
            if j == J:
                asked = (a, flag)
            c = d if kind == "first" else int(surv[int(rng.integers(len(surv)))])
            ans = (a == c) if flag < 0 else (flag == c)
            unf += ans != human(a, flag)
            if ans and flag < 0:
                flag = a
        return asked, unf
    for _ in range(n):
        (a, flag), _ = run("mix", int(rng.integers(L)))
        tested = a if flag < 0 else flag
        if tested == astar:
            alive[:] = False; alive[astar] = True
        else:
            alive[tested] = False
    return run("first")[1], run("mix")[1]

n, L, trials = 60, 12, 6000
N = 2 * n
sims = np.array([simulate_B(N, L, n, rng) for _ in range(trials)])
c0 = math.ceil(L / 4)
print(f"\n(3) class B, N = 2n = {N}, L = {L}, {trials} rehearsals with the mixture driver, then one fresh run each")
print(f"   first consistent member: Pr[>= L/4 unfaithful calls] = {(sims[:, 0] >= c0).mean():.4f}   lower bound L/(8n) = {L / (8 * n):.4f}")
print(f"   per-call mixture:        Pr[>= 3 unfaithful calls]   = {(sims[:, 1] >= 3).mean():.5f}   upper bound L/(2n^2) + (3L/(2n))^3/6 = "
      f"{L / (2 * n * n) + (1.5 * L / n) ** 3 / 6:.5f}")
print(f"   per-call mixture:        Pr[>= L/4 unfaithful calls] = {(sims[:, 1] >= c0).mean():.5f}")
print(f"   mean unfaithful calls: first consistent {sims[:, 0].mean():.4f}, mixture {sims[:, 1].mean():.4f}")

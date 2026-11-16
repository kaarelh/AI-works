"""R4 (one posterior draw per run): (a) the extremal example as an exact chain; (b) the refined
inequality on random small instances (random scaffolds with runs of variable length, random classes);
(c) a direct simulation of the extremal example with a finite number of top-level inputs.
Usage: python3 one-mind_r4.py"""
import math, random
import numpy as np

LN2 = math.log(2)

def chain_value(L, K):
    """Sum over rounds of Pr[run unfaithful] in Example 2.6 (fresh z every round): exact series."""
    R, q, S = 2.0 ** K - 1.0, 1.0 - 1.0 / L, 0.0
    for _ in range(10 ** 7):
        u = R / (1.0 + R)
        S += u / (1.0 - u * (L - 1) / (2.0 * L))
        R *= q
        if R < 1e-13:
            break
    return S

print("(a) extremal example: S(L,K) = sum_t Pr[run unfaithful], exact series")
print("   L     K   S(L,K)    S/(L K ln2)  lower bd 2L(L-1)(K-1)ln2/(L+1)  upper bd 2L^2 K ln2/(L+1)")
for L in (2, 5, 20, 100):
    for K in (1, 5, 20, 100):
        S = chain_value(L, K)
        lo = 2 * L * (L - 1) / (L + 1) * (K - 1) * LN2
        up = 2 * L * L / (L + 1) * K * LN2
        assert lo <= S <= up + 1e-9
        print(f"{L:4d} {K:5d} {S:10.2f} {S / (L * K * LN2):10.4f} {lo:18.2f} {up:26.2f}")

# ---------- (b) random instances ----------
class Scaffold:
    def __init__(self, nz, nx, ny, L, seed, stop=0.15):
        self.nz, self.nx, self.ny, self.L, self.seed, self.stop = nz, nx, ny, L, seed, stop
        self.cache = {}
    def nxt(self, z, ys):
        j = len(ys) + 1
        if j > self.L:
            return None
        key = (z, ys)
        if key not in self.cache:
            r = random.Random(hash((self.seed, z, ys)))
            self.cache[key] = None if (j >= 2 and r.random() < self.stop) else r.randrange(self.nx)
        return self.cache[key]
    def run(self, z, g):
        xs, ys = [], ()
        while True:
            x = self.nxt(z, ys)
            if x is None:
                return xs
            xs.append(x)
            ys = ys + (int(g[x]),)

def instance(seed, nz=6, nx=14, ny=3, L=5, m=40):
    rng = np.random.default_rng(seed)
    sc = Scaffold(nz, nx, ny, L, seed)
    f = rng.integers(0, ny, nx)
    G = [f]
    for _ in range(m):
        g = f.copy()
        flip = rng.random(nx) < rng.choice([0.05, 0.15, 0.4])
        g[flip] = (g[flip] + rng.integers(1, ny, flip.sum())) % ny
        G.append(g)
    G = np.array(G)
    w = rng.dirichlet(np.ones(m + 1) * 0.5) * 0.9          # total weight 0.9 < 1
    w[0] = max(w[0], 1e-3)
    fpaths = [sc.run(z, f) for z in range(nz)]
    dev = np.zeros((m + 1, nz), dtype=bool)                # dev[g,z] = run of g on z differs from run of f
    jstar = np.full((m + 1, nz), 10 ** 6)
    for gi in range(m + 1):
        for z in range(nz):
            for j, x in enumerate(fpaths[z], 1):
                if G[gi][x] != f[x]:
                    dev[gi, z], jstar[gi, z] = True, j
                    break
    return sc, f, G, w, dev, jstar

def psi(u, L):
    return u - u * u * (L - 1) / (2.0 * L)

def one_mind(inst, n, rng):
    sc, f, G, w, dev, jstar = inst
    alive = np.ones(len(G), dtype=bool)
    su = sp = 0.0
    for _ in range(n):
        p = np.where(alive, w, 0.0); p /= p.sum()
        uz = p @ dev                                       # Pr[run unfaithful | data, z]
        su += uz.mean(); sp += psi(uz, sc.L).mean()
        g = G[rng.choice(len(G), p=p)]
        xs = sc.run(int(rng.integers(sc.nz)), g)
        J = int(rng.integers(1, sc.L + 1))
        if J <= len(xs):
            x = xs[J - 1]
            alive &= (G[:, x] == f[x])
    return su, sp

print("\n(b) random instances (variable run length, 3 answers): Monte Carlo means over 300 rehearsals of 400 rounds")
print(" seed  L   K     sum E[u_t]   bound 2L^2 K ln2/(L+1)   sum E[psi_L(u_t)]   bound L K ln2")
rng = np.random.default_rng(0)
for seed in range(1, 9):
    inst = instance(seed, L=3 + seed % 4)
    L, K = inst[0].L, -math.log2(inst[3][0])
    res = np.array([one_mind(inst, 400, rng) for _ in range(300)])
    su, sp = res.mean(0)
    se = res.std(0) / math.sqrt(len(res))
    b1, b2 = 2 * L * L / (L + 1) * K * LN2, L * K * LN2
    assert su - 4 * se[0] <= b1 and sp - 4 * se[1] <= b2
    print(f"{seed:5d} {L:2d} {K:5.2f} {su:9.3f}±{se[0]:.3f} {b1:18.2f} {sp:16.3f}±{se[1]:.3f} {b2:12.2f}")

# ---------- (c) the extremal example simulated with finitely many top-level inputs ----------
def extremal_sim(L, K, nz, n, rng):
    """State: for each z the set of positions j not yet asked on the main path; wrong mass relative to f."""
    left = np.full(nz, L)                                  # surviving values of a(z)
    asked = [set() for _ in range(nz)]
    logR = math.log(2.0 ** K - 1.0)                        # log of (wrong mass)/(mass of f)
    tot = 0.0
    for _ in range(n):
        R = math.exp(logR) if left.min() > 0 else 0.0
        u_wrong = R / (1.0 + R)
        z = int(rng.integers(nz))
        # a wrong driver deviates on z at a(z), uniform on the surviving positions of z; every wrong
        # hypothesis deviates on every z, so Pr[run unfaithful | data, any z] = wrong posterior mass
        tot += u_wrong
        J = int(rng.integers(1, L + 1))
        if rng.random() < u_wrong:
            surv = [j for j in range(1, L + 1) if j not in asked[z]]
            a = surv[int(rng.integers(len(surv)))]
            on_path = J <= a
        else:
            on_path = True
        if on_path and J not in asked[z]:
            if left[z] == 1:
                logR = -math.inf; left[z] = 0
            else:
                logR += math.log((left[z] - 1) / left[z]); left[z] -= 1
            asked[z].add(J)
    return tot

print("\n(c) extremal example, direct simulation with nz = 20000 top-level inputs, 200 rehearsals")
print("   L   K  rounds   sum E[u_t] (sim)   S(L,K) (series)")
for L, K in ((5, 5), (10, 10), (20, 5)):
    n = int(6 * L * K)
    sims = [extremal_sim(L, K, 20000, n, rng) for _ in range(200)]
    print(f"{L:4d} {K:3d} {n:7d} {np.mean(sims):12.2f}±{np.std(sims) / math.sqrt(200):.2f} {chain_value(L, K):14.2f}")

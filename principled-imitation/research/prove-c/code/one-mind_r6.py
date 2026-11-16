"""R6. (a) Example 5.2 (nested positions): total number of unfaithful rounds under the three drivers.
(b) Theorem 5.5: selection of one consistent hypothesis after mixture-driven rehearsal, on random instances.
Usage: python3 one-mind_r6.py"""
import math, random
import numpy as np
LN2 = math.log(2)
rng = np.random.default_rng(0)

def nested(L, M, driver, max_rounds=10 ** 6):
    """Scaffold of Example 2.4 with one top-level input; g_i wrong at position i (i <= M <= L); f = 0.
    Returns the sum over rounds of the exact conditional probability that the run is unfaithful."""
    alive = np.ones(M + 1, dtype=bool)            # alive[i] for g_i, i = 1..M; index 0 unused
    alive[0] = False
    tot = 0.0
    for _ in range(max_rounds):
        k = int(alive.sum())
        if k == 0:
            break
        J = int(rng.integers(1, L + 1))
        if driver == "first":
            d = int(np.flatnonzero(alive)[0]); tot += 1.0
            on_path = J <= d
        elif driver == "draw":
            tot += k / (k + 1)
            c = int(rng.integers(k + 1))
            d = int(np.flatnonzero(alive)[c]) if c < k else L + 1
            on_path = J <= d
        else:                                     # mixture: fresh draw at every call
            tot += 1 - (1 - 1 / (k + 1)) ** k     # each alive g_j is drawn at its own position w.p. 1/(k+1)
            on_path = True
            for j in range(1, J):
                if j <= M and alive[j] and rng.random() < 1 / (k + 1):
                    on_path = False
                    break
        if on_path and J <= M:
            alive[J] = False
    return tot

print("(a) Example 5.2 with M = L (K = log2(L+1)): mean over 400 rehearsals of the number of unfaithful rounds")
print("    L    K     first consistent   [exact L*M]   posterior draw   [bound 2L^2 K ln2/(L+1)]   mixture   [bound L K ln2]")
for L in (4, 8, 16, 32):
    K = math.log2(L + 1)
    r = {d: np.mean([nested(L, L, d) for _ in range(400)]) for d in ("first", "draw", "mixture")}
    print(f"  {L:3d} {K:5.2f} {r['first']:14.1f} {L * L:14d} {r['draw']:14.2f} {2 * L * L / (L + 1) * K * LN2:18.2f}"
          f" {r['mixture']:16.2f} {L * K * LN2:12.2f}")
    assert r['draw'] <= 2 * L * L / (L + 1) * K * LN2 and r['mixture'] <= L * K * LN2

# ---------- (b) ----------
class Scaffold:
    def __init__(self, nz, nx, L, seed, stop=0.15):
        self.nz, self.nx, self.L, self.seed, self.stop, self.cache = nz, nx, L, seed, stop, {}
    def nxt(self, z, ys):
        j = len(ys) + 1
        if j > self.L:
            return None
        key = (z, ys)
        if key not in self.cache:
            r = random.Random(hash((self.seed, z, ys)))
            self.cache[key] = None if (j >= 2 and r.random() < self.stop) else r.randrange(self.nx)
        return self.cache[key]
    def run(self, z, answer):
        xs, ys = [], ()
        while True:
            x = self.nxt(z, ys)
            if x is None:
                return xs
            xs.append(x); ys = ys + (int(answer(x)),)

def instance(seed, nz=30, nx=60, ny=3, L=6, m=150):
    r = np.random.default_rng(seed)
    sc = Scaffold(nz, nx, L, seed)
    f = r.integers(0, ny, nx)
    G = [f]
    for _ in range(m):
        g = f.copy()
        flip = r.random(nx) < r.choice([0.02, 0.05, 0.15])
        g[flip] = (g[flip] + r.integers(1, ny, flip.sum())) % ny
        G.append(g)
    G = np.array(G)
    w = r.dirichlet(np.ones(m + 1) * 0.5) * 0.9
    w[0] = np.sort(w)[len(w) // 2]                # f has the median weight: many members are simpler
    fpaths = [sc.run(z, lambda x: f[x]) for z in range(nz)]
    dev = np.array([[any(G[gi][x] != f[x] for x in fpaths[z]) for z in range(nz)] for gi in range(m + 1)])
    return sc, f, G, w, dev

def rehearse_mixture(inst, n):
    sc, f, G, w, dev = inst
    alive = np.ones(len(G), dtype=bool)
    for _ in range(n):
        p = np.where(alive, w, 0.0); p /= p.sum(); cum = np.cumsum(p)
        xs = sc.run(int(rng.integers(sc.nz)), lambda x: G[min(int(np.searchsorted(cum, rng.random())), len(G) - 1)][x])
        J = int(rng.integers(1, sc.L + 1))
        if J <= len(xs):
            alive &= (G[:, xs[J - 1]] == f[xs[J - 1]])
    return alive

print("\n(b) Theorem 5.5 on random instances (L = 6, 151 functions, f of median weight), delta = 0.1, 300 rehearsals per cell")
print(" seed   K      n   bound B = 2L(K ln2 + ln(1/delta))/n   simplest consistent: mean u, Pr[u >= B]   draw at the end: mean u, Pr[u >= B']   (2*delta = 0.2)")
delta = 0.1
for seed in (1, 2, 3):
    inst = instance(seed)
    sc, f, G, w, dev = inst
    K = -math.log2(w[0]); u_all = dev.mean(1)
    for n in (50, 200, 800):
        B = 2 * sc.L * (K * LN2 + math.log(1 / delta)) / n
        B2 = sc.L * (2 * K * LN2 + 2 * math.log(1 / delta)) / n
        us, ud = [], []
        for _ in range(300):
            alive = rehearse_mixture(inst, n)
            us.append(u_all[int(np.argmax(np.where(alive, w, -1.0)))])
            p = np.where(alive, w, 0.0); p /= p.sum()
            ud.append(u_all[int(rng.choice(len(G), p=p))])
        us, ud = np.array(us), np.array(ud)
        assert (us >= B).mean() <= 2 * delta and (ud >= B2).mean() <= 2 * delta
        print(f"{seed:5d} {K:5.2f} {n:5d} {B:20.3f} {us.mean():28.4f} {(us >= B).mean():8.3f} {ud.mean():22.4f} {(ud >= B2).mean():8.3f}")

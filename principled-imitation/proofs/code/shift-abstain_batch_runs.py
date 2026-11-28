"""Checks for Theorem 7.11 of proofs/shift-abstain.md (the batch rule for whole runs, statement Ab6).

Setting.  A scaffold of horizon L whose next question depends on the task z, on a coin rho and on the
answers so far; a finite class H_b of functions X -> Y with weights; the human f in H_b.  Protocol R:
n rounds; in each round the Bayes mixture answers a run, one uniformly chosen call is put to the human.
V is the set of members that fit the n answers, h its first member (largest weight).  For a function g
the run tau_g(z, rho) is determined by (z, rho); u(g) is the probability that tau_g differs from tau_f.

The rule RBat_eps for a batch of pairs (z_i, rho_i): while some c in V has more than eps*r pairs, not yet
refused, with tau_c != tau_h, refuse all pairs with tau_c != tau_h.  Deliver tau_h for the others.

What is checked.
 (A) item 1, exactly: on random scaffolds, classes, rehearsals and batches of several kinds (from the
     task law, from another law, one pair repeated, the pairs on which h is unfaithful), the number of
     delivered runs that differ from the human system's run is at most eps*r; T < 1/eps.
 (B) the event of Theorem 5.5(b) of proofs/one-mind.md, on which items 3 and 4 rest: over many simulated
     rehearsals, the frequency of "some member of V has u(g) >= L(ln(1/w(g)) + K ln 2 + 2 ln(1/delta))/n"
     against 2*delta; and on the complement, mass(R) <= T * 2 * gamma_R for the batches tried.
 (C) item 5(b): after a second rehearsal of n' rounds on the pairs of a batch, the frequency of "some
     member that fits all answers is unfaithful on at least L(ln(1/w(g)) + K ln 2 + 2 ln(1/delta))/n'
     of the batch" against 2*delta.
 (D) an example with a guard: tasks from outside the rehearsed law are refused, not answered wrongly.

Run:  python3 shift-abstain_batch_runs.py        (fixed seed; about two minutes)
"""
import itertools
import math
import numpy as np

rng = np.random.default_rng(20261128)
STOP = -1


class Scaffold:
    """Horizon L; tasks z in range(nz) with law d0; a fair coin rho; the next input is a table entry
    indexed by (z, rho, answers so far)."""

    def __init__(self, nx, ny, nz, L, stop_prob=0.15):
        self.nx, self.ny, self.nz, self.L = nx, ny, nz, L
        self.d0 = rng.dirichlet(np.ones(nz))
        self.table = {}
        for z in range(nz):
            for rho in range(2):
                for j in range(L):
                    for hist in itertools.product(range(ny), repeat=j):
                        if j > 0 and rng.random() < stop_prob:
                            self.table[(z, rho, hist)] = STOP
                        else:
                            self.table[(z, rho, hist)] = int(rng.integers(0, nx))
        self.pairs = [(z, rho) for z in range(nz) for rho in range(2)]
        self.pair_prob = np.array([self.d0[z] * 0.5 for z, rho in self.pairs])

    def run_of_function(self, g, z, rho):
        """The run answered by the function g: the tuple of (input, answer) pairs."""
        hist = ()
        out = []
        for j in range(self.L):
            x = self.table[(z, rho, hist)]
            if x == STOP:
                break
            y = int(g[x])
            out.append((x, y))
            hist = hist + (y,)
        return tuple(out)

    def run_of_mixture(self, H, post, z, rho):
        """A run answered by the Bayes mixture with posterior `post` over the rows of H."""
        hist = ()
        xs = []
        for j in range(self.L):
            x = self.table[(z, rho, hist)]
            if x == STOP:
                break
            probs = np.bincount(H[:, x], weights=post, minlength=self.ny)
            y = int(rng.choice(self.ny, p=probs / probs.sum()))
            xs.append(x)
            hist = hist + (y,)
        return xs


def random_class(nx, ny, size):
    seen = set()
    rows = []
    base = rng.integers(0, ny, size=nx)
    while len(rows) < size:
        g = base.copy()
        k = int(rng.integers(0, nx + 1)) if rng.random() < 0.3 else int(rng.integers(0, 3))
        idx = rng.choice(nx, size=k, replace=False)
        g[idx] = rng.integers(0, ny, size=k)
        if tuple(g) not in seen:
            seen.add(tuple(g))
            rows.append(g)
    H = np.array(rows)
    w = rng.dirichlet(np.ones(size))
    order = np.argsort(-w)                       # non-increasing weight
    return H[order], w[order]


def rehearse(sc, H, w, f_index, n, pair_prob=None, post=None):
    """n rounds of Protocol R with the mixture.  Returns the posterior (zero for refuted members).
    `pair_prob` replaces the law of (z, rho); `post` continues from an earlier posterior."""
    f = H[f_index]
    post = (w / w.sum()).copy() if post is None else post.copy()
    pp = sc.pair_prob if pair_prob is None else pair_prob
    for _ in range(n):
        z, rho = sc.pairs[int(rng.choice(len(sc.pairs), p=pp))]
        xs = sc.run_of_mixture(H, post, z, rho)
        J = int(rng.integers(0, sc.L))
        if J < len(xs):
            x = xs[J]
            post = post * (H[:, x] == f[x])
            post = post / post.sum()
    return post


def runs_table(sc, H):
    """For every member and every pair (z, rho) an integer code of its run."""
    codes = {}
    tab = np.zeros((len(H), len(sc.pairs)), dtype=int)
    for i, g in enumerate(H):
        for p, (z, rho) in enumerate(sc.pairs):
            tau = sc.run_of_function(g, z, rho)
            tab[i, p] = codes.setdefault((p, tau), len(codes))
    return tab


def rbat(tab, V, batch, eps):
    """The rule for runs.  `batch` is an array of indices of pairs.  Returns (accepted, chosen, h)."""
    r = len(batch)
    h = V[0]
    dis = tab[V][:, batch] != tab[h][batch]
    acc = np.ones(r, dtype=bool)
    chosen = []
    while True:
        counts = (dis & acc).sum(axis=1)
        over = np.nonzero(counts > eps * r)[0]
        if len(over) == 0:
            break
        c = over[0]
        acc &= ~dis[c]
        chosen.append(int(V[c]))
    return acc, chosen, int(h)


def instance(nx_range=(5, 9), size_range=(4, 17), L=3, nz_range=(3, 7)):
    nx = int(rng.integers(*nx_range))
    ny = 2
    nz = int(rng.integers(*nz_range))
    sc = Scaffold(nx, ny, nz, L)
    size = int(rng.integers(*size_range))
    H, w = random_class(nx, ny, size)
    f_index = int(rng.integers(0, size))
    return sc, H, w, f_index


def part_A():
    print("(A) item 1 and the number of steps, exactly")
    viol = n_cases = 0
    worst = 0.0
    refused_some = 0
    for trial in range(600):
        sc, H, w, fi = instance()
        tab = runs_table(sc, H)
        n = int(rng.integers(0, 25))
        post = rehearse(sc, H, w, fi, n)
        V = np.nonzero(post > 0)[0]
        assert fi in V
        h = V[0]
        npairs = len(sc.pairs)
        wrong_pairs = np.nonzero(tab[h] != tab[fi])[0]
        for kind in range(4):
            r = int(rng.integers(1, 41))
            if kind == 0:
                batch = rng.choice(npairs, size=r, p=sc.pair_prob)
            elif kind == 1:
                batch = rng.integers(0, npairs, size=r)
            elif kind == 2:
                batch = np.full(r, int(rng.integers(0, npairs)))
            else:
                src = wrong_pairs if len(wrong_pairs) else np.arange(npairs)
                batch = np.where(rng.random(r) < 0.5, rng.choice(src, size=r), rng.integers(0, npairs, size=r))
            for eps in (1.0, 0.5, 0.25, 0.1, 0.05, 1.0 / (r + 1)):
                acc, chosen, _ = rbat(tab, V, batch, eps)
                wrong = int(((tab[h][batch] != tab[fi][batch]) & acc).sum())
                T = len(chosen)
                ok = wrong <= eps * r + 1e-12 and T < 1 / eps + 1e-12 and T <= r and T <= len(V) - 1
                if eps * r < 1:
                    unanimous = (tab[V] == tab[h]).all(axis=0)
                    ok = ok and np.array_equal(acc, unanimous[batch]) and wrong == 0
                viol += 0 if ok else 1
                worst = max(worst, wrong / (eps * r))
                refused_some += 0 if acc.all() else 1
                n_cases += 1
    print(f"    instances 600; cases {n_cases}; violations {viol}; largest (unfaithful delivered runs)/(eps*r): {worst:.4f};"
          f" cases with a refusal: {refused_some}")


def u_of(sc, tab, fi):
    """u(g) for every member: probability that its run differs from the human system's."""
    return ((tab != tab[fi]) * sc.pair_prob).sum(axis=1)


def part_B():
    print("(B) the event of Theorem 5.5(b) of proofs/one-mind.md, by simulation, and item 3 on it")
    delta = 0.1
    rows = []
    viol_mass = 0
    n_batches = 0
    for trial in range(12):
        sc, H, w, fi = instance(nx_range=(6, 9), size_range=(8, 17), L=3, nz_range=(4, 7))
        tab = runs_table(sc, H)
        u = u_of(sc, tab, fi)
        K_ln2 = math.log(1 / w[fi])
        b = math.log2(1 / w.min())
        for n in (20, 80):
            bad = 0
            sims = 400
            for _ in range(sims):
                post = rehearse(sc, H, w, fi, n)
                V = np.nonzero(post > 0)[0]
                bound = sc.L * (np.log(1 / w[V]) + K_ln2 + 2 * math.log(1 / delta)) / n
                if (u[V] >= bound).any():
                    bad += 1
                    continue
                gamma_R = 2 * sc.L * (b * math.log(2) + math.log(1 / delta)) / n
                batch = rng.integers(0, len(sc.pairs), size=int(rng.integers(1, 31)))
                eps = float(rng.choice([0.5, 0.2, 0.1]))
                acc, chosen, h = rbat(tab, V, batch, eps)
                R = np.zeros(len(sc.pairs), dtype=bool)
                for c in chosen:
                    R |= tab[c] != tab[h]
                n_batches += 1
                if sc.pair_prob[R].sum() > len(chosen) * 2 * gamma_R + 1e-12:
                    viol_mass += 1
            rows.append((len(H), sc.L, n, bad / sims, float(u.max())))
    worst = max(r[3] for r in rows)
    print(f"    24 settings, 400 rehearsals each: largest frequency of the bad event {worst:.4f} (bound 2*delta = {2 * delta});"
          f" batches on the good event {n_batches}, violations of mass(R) <= 2*T*gamma_R: {viol_mass}")
    # The bound is far from tight: a member with u(g) at the bound survives n rounds with probability of
    # the order of w(g)*delta^2*2^(-K).  A class of one-point patches shows members that fit with u(g) > 0.
    nx, ny, nz, L = 40, 2, 20, 3
    sc = Scaffold(nx, ny, nz, L, stop_prob=0.0)
    base = rng.integers(0, ny, size=nx)
    rows = [base]
    for x in rng.choice(nx, size=31, replace=False):
        g = base.copy()
        g[x] = 1 - g[x]
        rows.append(g)
    H = np.array(rows)
    w = np.full(32, 1 / 32)
    fi = 0
    tab = runs_table(sc, H)
    u = u_of(sc, tab, fi)
    K_ln2 = math.log(1 / w[fi])
    print(f"    a class of 32 functions (the human and 31 one-point patches), 20 tasks: u(g) between"
          f" {u[1:].min():.3f} and {u[1:].max():.3f} for the patches")
    for n in (50, 200, 800):
        bad = 0
        largest = 0.0
        fit = 0
        sims = 300
        for _ in range(sims):
            post = rehearse(sc, H, w, fi, n)
            V = np.nonzero(post > 0)[0]
            bound = sc.L * (np.log(1 / w[V]) + K_ln2 + 2 * math.log(1 / delta)) / n
            largest = max(largest, float((u[V] / bound).max()))
            fit += int((u[V] > 0).sum())
            bad += 1 if (u[V] >= bound).any() else 0
        print(f"    n={n:4d}: bad event in {bad} of {sims} rehearsals; members that fit with u(g) > 0, on average: {fit / sims:.2f};"
              f" largest u(g)/bound among them: {largest:.3f}")


def part_C():
    print("(C) item 5(b): a second rehearsal on the pairs of a batch")
    delta = 0.1
    worst = 0.0
    settings = 0
    for trial in range(10):
        sc, H, w, fi = instance(nx_range=(6, 9), size_range=(8, 17), L=3, nz_range=(4, 7))
        tab = runs_table(sc, H)
        K_ln2 = math.log(1 / w[fi])
        npairs = len(sc.pairs)
        for n1, n2 in ((5, 30), (20, 100)):
            bad = 0
            sims = 300
            for _ in range(sims):
                post = rehearse(sc, H, w, fi, n1)
                batch = rng.integers(0, npairs, size=12)                 # any batch; here uniform pairs
                law = np.bincount(batch, minlength=npairs) / len(batch)
                post2 = rehearse(sc, H, w, fi, n2, pair_prob=law, post=post)
                V2 = np.nonzero(post2 > 0)[0]
                frac = ((tab[V2] != tab[fi]) * law).sum(axis=1)           # unfaithful fraction of the batch
                bound = sc.L * (np.log(1 / w[V2]) + K_ln2 + 2 * math.log(1 / delta)) / n2
                bad += 1 if (frac >= bound).any() else 0
            worst = max(worst, bad / sims)
            settings += 1
    print(f"    {settings} settings, 300 simulations each: largest frequency of the bad event {worst:.4f} (bound 2*delta = {2 * delta})")


def part_D():
    print("(D) a guard on tasks from outside the rehearsed law")
    # Inputs: pairs (a, d) with a in 0..7 and depth d in 0..2, coded a + 8*d.  The scaffold on task a asks
    # (a, 0), then ((a + y1) mod 8, 1), then ((a + y1 + y2) mod 8, 2).  Rehearsal tasks have a < 4; the batch
    # has tasks a >= 4 as well.  The human answers the parity of a.  Members: the human; and guards that
    # answer as the human unless a >= 4 (one guard for each depth, and one for all depths).
    nx, L = 24, 3

    def human(x):
        return (x % 8) % 2

    members = [np.array([human(x) for x in range(nx)])]
    for depth in (0, 1, 2, None):
        g = members[0].copy()
        for x in range(nx):
            a, d = x % 8, x // 8
            if a >= 4 and (depth is None or d == depth):
                g[x] = 1 - g[x]
        members.append(g)
    H = np.array(members)
    w = np.array([0.4, 0.15, 0.15, 0.15, 0.15])

    def run(g, a):
        y1 = int(g[a])
        y2 = int(g[(a + y1) % 8 + 8])
        y3 = int(g[(a + y1 + y2) % 8 + 16])
        return (y1, y2, y3)

    tab = np.array([[hash(run(g, a)) % (10 ** 9) for a in range(8)] for g in H])
    # rehearsal on tasks a < 4, mixture-driven, 200 rounds
    post = w.copy()
    f = H[0]
    for _ in range(200):
        a = int(rng.integers(0, 4))
        xs = []
        s = a
        for d in range(L):
            x = s % 8 + 8 * d
            probs = np.bincount(H[:, x], weights=post, minlength=2)
            y = int(rng.choice(2, p=probs / probs.sum()))
            xs.append(x)
            s += y
        x = xs[int(rng.integers(0, L))]
        post = post * (H[:, x] == f[x])
        post = post / post.sum()
    V = np.nonzero(post > 0)[0]
    print(f"    members that fit after 200 rounds on tasks a < 4: {len(V)} of {len(H)} (the guards on a >= 4 are not refuted:"
          f" runs on tasks a < 4 never reach an input with a >= 4 at depth 0, and rarely elsewhere)")
    batch = np.array([int(a) for a in rng.integers(0, 8, size=40)])
    for eps in (0.1, 0.3):
        acc, chosen, h = rbat(tab, V, batch, eps)
        refused = batch[~acc]
        wrong = int(((tab[h][batch] != tab[0][batch]) & acc).sum())
        print(f"    eps={eps}: batch of 40 tasks, {int((batch >= 4).sum())} of them with a >= 4; refused {int((~acc).sum())},"
              f" of them with a >= 4: {int((refused >= 4).sum())}; delivered runs that differ from the human's: {wrong}")


if __name__ == "__main__":
    part_A()
    part_B()
    part_C()
    part_D()

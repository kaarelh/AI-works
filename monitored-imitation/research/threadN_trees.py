"""Thread N (decomposition trees): numerical checks for research/threadN-trees.md.

numpy only.  Four parts; each prints its own section.

1. Lemma T2 / Theorem T3 bookkeeping.  Random abstract call trees whose remaining-round
   counters tau obey (T1'), (T2'), (Budget) and bounded setback (B^T_D) at bad rounds.
   Children posed in mislabelled rounds get arbitrary tau (possibly infinite), since the
   lemma must not rely on them.  Checks that every failed root has
       sum over label mistakes rho of omega(rho) >= 1,
   omega(rho) = prod over calls w on the path root..call(rho) of 1/c_w,
   so the depth-weighted query q = omega/Phi hits with probability >= 1/Phi.
   Also checks the fooled-parent variant (Theorem T3'): weights 1/c_u, no (B-sub).

2. Game value.  For one query per run, drawn from q over rounds without knowing where the
   mistakes are, against an adversary choosing a minimal failure certificate.  Computed by
   Hedge for q against exact best responses (a recursion), which gives a certified interval
   [lower, upper] for max_q min_M q(M).  Balanced trees: compare with 1/Phi.  An unbalanced
   tree: the value can exceed 1/Phi (Phi is then only an upper bound on the charge).

3. Complaint walk (Proposition T8).  Random annotated trees in which the human's next round
   rejects exactly the non-good subanswers of the previous round, and the imitator's
   rejections are exact at its correct rounds and arbitrary at its mistaken ones.  Computes
   the walk's exact hit probability and checks it against the recursion bound.

4. Table of charges (expected failed runs per unit of K) for balanced trees.

Usage: python3 threadN_trees.py   (about a minute)
"""

import math
import numpy as np

INF = 10**9


# ---------------------------------------------------------------- 1. bookkeeping

class Call:
    __slots__ = ("r", "c", "rounds", "fails", "tau0")

    def __init__(self, r, c):
        self.r, self.c, self.rounds, self.fails, self.tau0 = r, c, [], False, 0


def step_tau(rng, tau, bad, D):
    """One round of a call's remaining-round counter.  Mostly extremal (good: -1, bad: +D),
    sometimes anything the assumptions allow."""
    if tau == INF or tau == 0:
        return tau  # (T2'): success is preserved by appending
    if rng.random() < 0.8:
        return tau - 1 if not bad else tau + D
    if not bad:
        return max(0, tau - int(rng.choice([1, 2])))  # (T1'): drops by at least 1
    return max(0, tau + int(rng.integers(-1, D + 1)))  # (B^T_D): rises by at most D


def start_tau(rng, P, budget_ok, r):
    if budget_ok:  # (Budget): tau <= r0, usually exactly r0
        return P["r0"] if rng.random() < 0.8 else int(rng.integers(0, P["r0"] + 1))
    # outside (Budget): anything, including never finishing
    return int(rng.choice([int(rng.integers(0, P["r0"] + 1)), P["r0"] + int(rng.integers(1, 2 * r)), INF]))


def gen_call(rng, depth, P, budget_ok):
    """P: dict with r0, s, D, dmax, bmax, pmax.  Returns a Call with fails set.
    Each call draws its own mistake rate, uniform on [0, pmax]."""
    r = P["r0"] + P["s"]
    c = max(1, math.ceil((P["s"] + 1) / (P["D"] + 1)))
    u = Call(r, c)
    tau = start_tau(rng, P, budget_ok, r)
    pm = rng.random() * P["pmax"]
    for _ in range(r):
        mistake = rng.random() < pm
        kids = []
        if depth < P["dmax"]:
            nb = int(rng.integers(0, P["bmax"] + 1))
            kids = [gen_call(rng, depth + 1, P, budget_ok=not mistake) for _ in range(nb)]
        bad = mistake or any(k.fails for k in kids)
        tau = step_tau(rng, tau, bad, P["D"])
        u.rounds.append((mistake, kids))
    u.fails = tau >= 1
    return u


def weighted_mass(u, w_parent, fooled=False):
    """Returns (sum of weights over label mistakes, Phi) in u's subtree.

    Depth-weighted: weight of a round of call v = prod over the path of 1/c.
    Fooled-parent variant: weight = 1/c_v (no depth discount)."""
    w = (1.0 / u.c) if fooled else w_parent / u.c
    m, phi = 0.0, 0.0
    for mistake, kids in u.rounds:
        phi += w
        if mistake:
            m += w
        for k in kids:
            mk, pk = weighted_mass(k, w, fooled)
            m += mk
            phi += pk
    return m, phi


def gen_call_fooled(rng, depth, P, budget_ok):
    """As gen_call, but a wrong subanswer may sink the parent for good; (B_D) is kept only at
    label mistakes of rounds whose subanswers are all good."""
    r = P["r0"] + P["s"]
    c = max(1, math.ceil((P["s"] + 1) / (P["D"] + 1)))
    u = Call(r, c)
    tau = start_tau(rng, P, budget_ok, r)
    pm = rng.random() * P["pmax"]
    for _ in range(r):
        mistake = rng.random() < pm
        kids = []
        if depth < P["dmax"]:
            nb = int(rng.integers(0, P["bmax"] + 1))
            kids = [gen_call_fooled(rng, depth + 1, P, budget_ok=not mistake) for _ in range(nb)]
        anyfail = any(k.fails for k in kids)
        if anyfail and tau != 0 and rng.random() < 0.7:
            tau = INF  # fooled: never recovers
        else:
            tau = step_tau(rng, tau, mistake or anyfail, P["D"])
        u.rounds.append((mistake, kids))
    u.fails = tau >= 1
    return u


def part1(rng):
    print("== 1. Lemma T2 / Theorem T3 bookkeeping on random trees ==")
    settings = [
        dict(r0=2, s=2, D=0, dmax=2, bmax=2, pmax=0.8),
        dict(r0=2, s=3, D=1, dmax=3, bmax=2, pmax=0.6),
        dict(r0=3, s=4, D=1, dmax=2, bmax=3, pmax=0.6),
        dict(r0=2, s=5, D=2, dmax=2, bmax=2, pmax=0.8),
        dict(r0=1, s=6, D=0, dmax=3, bmax=2, pmax=0.9),
    ]
    for P in settings:
        trials, failed, worst = 1500, 0, float("inf")
        for _ in range(trials):
            root = gen_call(rng, 0, P, budget_ok=True)
            if not root.fails:
                continue
            failed += 1
            m, phi = weighted_mass(root, 1.0)
            worst = min(worst, m)
        print(f"  {P}: failed roots {failed}/{trials}; min weighted mistake mass {worst:.4f} (must be >= 1)")
    print("  fooled parents (weights 1/c_u):")
    for P in settings[:3]:
        trials, failed, worst = 1500, 0, float("inf")
        for _ in range(trials):
            root = gen_call_fooled(rng, 0, P, budget_ok=True)
            if not root.fails:
                continue
            failed += 1
            m, _ = weighted_mass(root, 1.0, fooled=True)
            worst = min(worst, m)
        print(f"  {P}: failed roots {failed}/{trials}; min mass {worst:.4f} (must be >= 1)")


# ---------------------------------------------------------------- 2. game value

def build_balanced(r, b, d, c):
    """Tree as nested lists: node = (c, [ (pos, [child nodes]) for each round ]). Returns (root, npos)."""
    counter = [0]

    def mk(depth):
        rounds = []
        for _ in range(r):
            pos = counter[0]
            counter[0] += 1
            kids = [mk(depth + 1) for _ in range(b)] if depth < d else []
            rounds.append((pos, kids))
        return (c, rounds)

    root = mk(0)
    return root, counter[0]


def best_response(node, q):
    """Adversary: minimal failure certificate minimising q(M). Returns (value, positions)."""
    c, rounds = node
    opts = []
    for pos, kids in rounds:
        best = (q[pos], [pos])
        for k in kids:
            v, M = best_response(k, q)
            if v < best[0]:
                best = (v, M)
        opts.append(best)
    opts.sort(key=lambda t: t[0])
    val, M = 0.0, []
    for v, Mi in opts[:c]:
        val += v
        M += Mi
    return val, M


def phi_of(node, w=1.0):
    c, rounds = node
    w2 = w / c
    tot = 0.0
    for _, kids in rounds:
        tot += w2
        for k in kids:
            tot += phi_of(k, w2)
    return tot


def game_value(root, npos, T=6000):
    eta = math.sqrt(8 * math.log(npos) / T)
    logw = np.zeros(npos)
    counts = np.zeros(npos)
    lower = 0.0
    qsum = np.zeros(npos)
    for _ in range(T):
        q = np.exp(logw - logw.max())
        q /= q.sum()
        qsum += q
        v, M = best_response(root, q)
        lower = max(lower, v)
        g = np.zeros(npos)
        g[M] = 1.0
        counts += g
        logw += eta * g
    qbar = qsum / T
    lower = max(lower, best_response(root, qbar)[0])
    upper = counts.max() / T  # q-player's best response to the adversary's empirical mixture
    return lower, upper


def part2():
    print("== 2. Value of one-query distributions against failure certificates ==")
    for (r, b, d, c) in [(4, 2, 1, 2), (3, 2, 2, 2), (5, 1, 2, 3), (4, 3, 1, 3)]:
        root, npos = build_balanced(r, b, d, c)
        lo, hi = game_value(root, npos)
        print(f"  balanced r={r} b={b} d={d} c={c}: rounds {npos}; game value in [{lo:.5f}, {hi:.5f}];"
              f" 1/Phi = {1 / phi_of(root):.5f}; uniform-round guarantee c/N_r = {c / npos:.5f}")
    # unbalanced: root with 3 rounds, c = 2; round 0 has 4 children, each a balanced (3,2,1,2) subtree
    counter = [0]

    def leaf_call(c, r):
        rounds = []
        for _ in range(r):
            rounds.append((counter[0], []))
            counter[0] += 1
        return (c, rounds)

    def mid_call():
        rounds = []
        for _ in range(3):
            pos = counter[0]
            counter[0] += 1
            rounds.append((pos, [leaf_call(2, 3), leaf_call(2, 3)]))
        return (2, rounds)

    rounds = []
    pos0 = counter[0]; counter[0] += 1
    rounds.append((pos0, [mid_call() for _ in range(4)]))
    for _ in range(2):
        rounds.append((counter[0], []))
        counter[0] += 1
    root = (2, rounds)
    lo, hi = game_value(root, counter[0])
    print(f"  unbalanced (root: 3 rounds, c=2, one round with a big subtree): game value in [{lo:.5f}, {hi:.5f}];"
          f" 1/Phi = {1 / phi_of(root):.5f}  (value 1/2: put all mass on the two childless rounds)")


# ---------------------------------------------------------------- 3. complaint walk

class ACall:
    __slots__ = ("r", "c", "mist", "kids", "posed_ok", "compl", "fails", "height")


def gen_acall(rng, depth, P, budget_ok):
    r = P["r0"] + P["s"]
    c = max(1, math.ceil((P["s"] + 1) / (P["D"] + 1)))
    u = ACall()
    u.r, u.c, u.height = r, c, P["dmax"] - depth
    tau = start_tau(rng, P, budget_ok, r)
    pm = rng.random() * P["pmax"]
    pspur = rng.random()  # how freely this call's mistaken rounds reject subanswers
    u.mist, u.kids, u.compl = [], [], []
    prev_kids = []
    for j in range(r):
        mistake = rng.random() < pm
        # complaints in round j's label, about the subanswers of round j-1
        if not mistake:
            compl = [i for i, k in enumerate(prev_kids) if k.fails]  # (B-notice): exact
        else:
            compl = [i for i in range(len(prev_kids)) if rng.random() < pspur]  # arbitrary
        kids = []
        if depth < P["dmax"]:
            nb = int(rng.integers(0, P["bmax"] + 1))
            kids = [gen_acall(rng, depth + 1, P, budget_ok=not mistake) for _ in range(nb)]
        bad = mistake or any(k.fails for k in kids)
        tau = step_tau(rng, tau, bad, P["D"])
        u.mist.append(mistake)
        u.kids.append(kids)
        u.compl.append(compl)
        prev_kids = kids
    u.fails = tau >= 1
    return u


def walk_bound(P):
    """f[h] for h = 0..dmax and the lambda used at each height."""
    r = P["r0"] + P["s"]
    c = max(1, math.ceil((P["s"] + 1) / (P["D"] + 1)))
    A = (c - 1) / (4 * r)
    f = [c / r]
    lam = [1.0]
    for h in range(1, P["dmax"] + 1):
        B = min(0.25, f[h - 1] / 2)
        lam.append(B / (A + B))
        f.append(A * B / (A + B))
    return f, lam


def walk_hit(u, lam):
    """Exact hit probability of the complaint walk started at call u."""
    a = sum(u.mist)
    label_branch = a / u.r
    complaints = [(j, i) for j in range(u.r) for i in u.compl[j]]
    if not complaints:
        return label_branch
    tot = 0.0
    for j, i in complaints:
        child = u.kids[j - 1][i]
        v = 0.25 * u.mist[j] + 0.25 * u.mist[j - 1] + 0.5 * walk_hit(child, lam)
        tot += v
    L = lam[u.height]
    return L * label_branch + (1 - L) * tot / len(complaints)


def part3(rng):
    print("== 3. Complaint walk: exact hit probability vs the recursion bound ==")
    settings = [
        dict(r0=2, s=4, D=0, dmax=2, bmax=3, pmax=0.9),
        dict(r0=2, s=5, D=1, dmax=3, bmax=2, pmax=0.7),
        dict(r0=3, s=6, D=1, dmax=2, bmax=4, pmax=0.7),
        dict(r0=2, s=8, D=2, dmax=2, bmax=3, pmax=0.9),
    ]
    for P in settings:
        f, lam = walk_bound(P)
        trials, failed, worst_ratio = 1500, 0, float("inf")
        for _ in range(trials):
            root = gen_acall(rng, 0, P, budget_ok=True)
            if not root.fails:
                continue
            failed += 1
            worst_ratio = min(worst_ratio, walk_hit(root, lam) / f[P["dmax"]])
        print(f"  {P}: failed {failed}/{trials}; bound f_d = {f[P['dmax']]:.5f};"
              f" min hit/bound = {worst_ratio:.3f} (must be >= 1)")


# ---------------------------------------------------------------- 4. table

def charges(r0, s, D, b, d):
    r = r0 + s
    c = max(1, math.ceil((s + 1) / (D + 1)))
    B = r * b
    R = [r * B**i for i in range(d + 1)]           # rounds at each depth (slack tree)
    N = sum(B**i for i in range(d + 1))             # calls
    Nr = sum(R)
    Nr0 = sum(r0 * (r0 * b)**i for i in range(d + 1))  # rounds of the human's own tree
    phi = sum(R[i] / c**(i + 1) for i in range(d + 1))
    lvl = (d + 1) * max(R[i] / c**(i + 1) for i in range(d + 1))
    unif = Nr / c
    fooled = N * r / c
    if c >= 2:
        P = dict(r0=r0, s=s, D=D, dmax=d)
        f, _ = walk_bound(P)
        walk = 1 / f[d]
    else:
        walk = float("nan")
    return dict(c=c, N=N, Nr=Nr, Nr0=Nr0, phi=phi, lvl=lvl, unif=unif, fooled=fooled, walk=walk, lb=b**d)


def part4():
    print("== 4. Charges per unit of K (expected failed runs <= charge * K), balanced trees, r0 = 10 ==")
    print("  | s | D | b | d | c | calls N | rounds N_r | chained, own tree | uniform round | fooled parents |"
          " depth-weighted Phi | level-uniform | complaint walk | lower bound (D=0 class) b^d |")
    for (s, D, b, d) in [(10, 0, 1, 2), (10, 1, 1, 2), (10, 1, 2, 2), (10, 1, 2, 3), (10, 2, 2, 3),
                         (10, 1, 4, 2), (30, 1, 2, 3), (10, 0, 2, 3)]:
        x = charges(10, s, D, b, d)
        print(f"  | {s} | {D} | {b} | {d} | {x['c']} | {x['N']:,} | {x['Nr']:,} | {x['Nr0']:,} | {x['unif']:,.0f} |"
              f" {x['fooled']:,.0f} | {x['phi']:,.1f} | {x['lvl']:,.1f} | {x['walk']:,.1f} | {x['lb']} |")


if __name__ == "__main__":
    rng = np.random.default_rng(20261121)
    part1(rng)
    part2()
    part3(rng)
    part4()

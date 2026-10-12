"""c2: random finite instances for Section 3 of notes.md and notes-final.md.

Setting: X = {0,1,2}, Y = {0,1}, horizon n = 3, repeated inputs allowed (a repeated input
must get the same label, as data come from a function).

Checks, each over many seeded random instances:
 (A) Shared-randomness simulator G (Thm 3.2): one simulated trajectory from (Delta, P),
     G(x) = label at the first visit of x.  For every input/label sequence consistent with a
     function:  G(D_n) >= Delta(x||y) * P(y||x), and for sequences with distinct inputs
     G(D_n) >= sum over all orderings sigma of Delta(x_sigma||y_sigma) P(y_sigma||x_sigma).
     Also: G is a function semimeasure (sum_y G(D+(x,y)) <= G(D)).
 (B) Private-randomness simulator of the draft's sketch (each input gets its own simulated
     history, conditioned on visiting it): how often its expected loss exceeds E[L_P]
     (the sketch claims never), for f ~ pi and non-peeking Delta.
     Note: this simulator is the NORMALISED one (conditioned on visiting x) with the horizon
     truncated at n = 3.  The draft's simulator is unnormalised with unbounded horizon.
     Normalising only lowers the loss, so violations found here would also hold for an
     unnormalised version at the same horizon; the horizon truncation makes it a different
     object.  c1 alone establishes Prop. 3.1.
 (C) Bayes theorem, non-peeking Delta (Thm 3.5): the chronological Bayes predictor's loss
     equals -log pi(D_n) on every path, and E[L_P] >= E[-log pi(D_n)] for random P.
 (D) Directed-information identity, peeking Delta (Thm 3.6):
     E[-log pi(D)] - E[-log mu(y||x)] = I(f -> x) - E[KL(post || label-only post)] <= I(f -> x),
     and E[L_P] >= E[-log mu(y||x)].
Seed 20261011.  Output saved to c2_simulators_bayes.out.
"""
import itertools, math
import numpy as np

SEED = 20261011
rng = np.random.default_rng(SEED)
X = (0, 1, 2)
Y = (0, 1)
n = 3
FUNCS = list(itertools.product(Y, repeat=len(X)))  # f as tuple f[x]

def histories(k):
    """all histories of length k (tuples of (x,y)), not necessarily function-consistent"""
    return list(itertools.product(itertools.product(X, Y), repeat=k))

ALLH = {k: histories(k) for k in range(n + 1)}

def consistent(h):
    d = {}
    for x, y in h:
        if x in d and d[x] != y:
            return False
        d[x] = y
    return True

def rand_kernel_nonpeek():
    """Delta(x | h) for every history h of length < n"""
    return {h: rng.dirichlet(np.ones(len(X)) * 0.7) for k in range(n) for h in ALLH[k]}

def rand_kernel_peek():
    """Delta(x | f, h)"""
    return {(f, h): rng.dirichlet(np.ones(len(X)) * 0.7) for f in FUNCS for k in range(n) for h in ALLH[k]}

def rand_P():
    """P(y | h, x)"""
    return {(h, x): rng.dirichlet(np.ones(len(Y)) * 0.7) for k in range(n) for h in ALLH[k] for x in X}

def logp(p):
    return -math.log2(p) if p > 0 else math.inf

def seq_prob(Delta, P, h):
    """Delta(x||y) and P(y||x) along history h"""
    dx, py = 1.0, 1.0
    for i, (x, y) in enumerate(h):
        dx *= Delta[h[:i]][x]
        py *= P[(h[:i], x)][y]
    return dx, py

def shared_sim_G(Delta, P, T=n):
    """distribution over partial functions (as frozenset of (x,y)) induced by one trajectory"""
    G = {}
    for h in ALLH[T]:
        dx, py = seq_prob(Delta, P, h)
        w = dx * py
        if w == 0:
            continue
        pf = {}
        for x, y in h:
            if x not in pf:
                pf[x] = y
        key = frozenset(pf.items())
        G[key] = G.get(key, 0.0) + w
    return G

def G_of(G, D):
    D = set(D)
    return sum(w for pf, w in G.items() if D <= pf)

# ---------------- (A) ----------------
worstA1, worstA2, worstA3 = math.inf, math.inf, -math.inf
for inst in range(40):
    Delta, P = rand_kernel_nonpeek(), rand_P()
    G = shared_sim_G(Delta, P)
    for h in ALLH[n]:
        if not consistent(h):
            continue
        dx, py = seq_prob(Delta, P, h)
        g = G_of(G, h)
        worstA1 = min(worstA1, g - dx * py)
        xs = [x for x, _ in h]
        if len(set(xs)) == n:
            tot = 0.0
            for perm in itertools.permutations(range(n)):
                hp = tuple(h[j] for j in perm)
                a, b = seq_prob(Delta, P, hp)
                tot += a * b
            worstA2 = min(worstA2, g - tot)
    # semimeasure property on all D of size <= 2 and new x
    for k in range(0, 3):
        for dom in itertools.combinations(X, k):
            for ys in itertools.product(Y, repeat=k):
                D = list(zip(dom, ys))
                for x in X:
                    if x in dom:
                        continue
                    s = sum(G_of(G, D + [(x, y)]) for y in Y)
                    worstA3 = max(worstA3, s - G_of(G, D))
print(f"(A) min over instances/paths of G(D)-Delta*P = {worstA1:.3e} (must be >= 0)")
print(f"(A) min of G(D) - sum_sigma Delta*P (distinct inputs) = {worstA2:.3e} (must be >= 0)")
print(f"(A) max of sum_y G(D+(x,y)) - G(D) = {worstA3:.3e} (must be <= 0 up to rounding)")
assert worstA1 >= -1e-12 and worstA2 >= -1e-12 and worstA3 <= 1e-12

# ---------------- (B) and (C) ----------------
def process_nonpeek(pi, Delta, P):
    """returns E[L_P], E[-log pi(D)], E[private-sim loss], E[shared-sim loss], max |L_Bayes - (-log pi(D))|"""
    G = shared_sim_G(Delta, P)
    # private simulator: g(y|x) = P(label at first visit = y | visit x)
    gpriv = {}
    for x in X:
        num = {y: 0.0 for y in Y}
        for pf, w in G.items():
            d = dict(pf)
            if x in d:
                num[d[x]] += w
        tot = sum(num.values())
        gpriv[x] = {y: (num[y] / tot if tot > 0 else 0.0) for y in Y}
    EP = Epi = Epriv = Eshared = 0.0
    maxdev = 0.0
    for fi, f in enumerate(FUNCS):
        for xs in itertools.product(X, repeat=n):
            h = tuple((x, f[x]) for x in xs)
            dx = 1.0
            for i, x in enumerate(xs):
                dx *= Delta[h[:i]][x]
            w = pi[fi] * dx
            if w == 0:
                continue
            _, py = seq_prob(Delta, P, h)
            D = set(h)
            piD = sum(pi[gj] for gj, g in enumerate(FUNCS) if all(g[x] == y for x, y in D))
            # chronological Bayes predictor
            LB = 0.0
            for i in range(n):
                Dprev = set(h[:i]); Dcur = set(h[:i + 1])
                a = sum(pi[gj] for gj, g in enumerate(FUNCS) if all(g[x] == y for x, y in Dcur))
                b = sum(pi[gj] for gj, g in enumerate(FUNCS) if all(g[x] == y for x, y in Dprev))
                LB += logp(a / b)
            maxdev = max(maxdev, abs(LB - logp(piD)))
            ppriv = 1.0
            for x, y in D:
                ppriv *= gpriv[x][y]
            EP += w * logp(py)
            Epi += w * logp(piD)
            Epriv += w * logp(ppriv)
            Eshared += w * logp(G_of(G, D))
    return EP, Epi, Epriv, Eshared, maxdev

def bayes_P(prior):
    """chronological Bayes predictor for a prior over FUNCS (uniform on inconsistent histories)"""
    Pb = {}
    for k in range(n):
        for h in ALLH[k]:
            for x in X:
                D = set(h)
                cons = [gj for gj, g in enumerate(FUNCS) if all(g[xx] == yy for xx, yy in D)]
                b = sum(prior[gj] for gj in cons)
                if b == 0:
                    Pb[(h, x)] = np.ones(len(Y)) / len(Y)
                else:
                    Pb[(h, x)] = np.array([sum(prior[gj] for gj in cons if FUNCS[gj][x] == y) / b for y in Y])
    return Pb

viol_priv = {"random": 0, "bayes": 0, "bayes_other_prior": 0}
viol_shared = {"random": 0, "bayes": 0, "bayes_other_prior": 0}
gaps_priv = {"random": [], "bayes": [], "bayes_other_prior": []}
worstC = math.inf; maxdevC = 0.0; N_B = 60
for inst in range(N_B):
    pi = rng.dirichlet(np.ones(len(FUNCS)) * 0.5)
    pi2 = rng.dirichlet(np.ones(len(FUNCS)) * 0.5)
    Delta = rand_kernel_nonpeek()
    for kind, P in (("random", rand_P()), ("bayes", bayes_P(pi)), ("bayes_other_prior", bayes_P(0.5 * pi + 0.5 * pi2))):
        EP, Epi, Epriv, Eshared, maxdev = process_nonpeek(pi, Delta, P)
        gaps_priv[kind].append(Epriv - EP)
        viol_priv[kind] += Epriv > EP + 1e-9
        viol_shared[kind] += Eshared > EP + 1e-9
        worstC = min(worstC, EP - Epi)
        maxdevC = max(maxdevC, maxdev)
for kind in viol_priv:
    print(f"(B) P={kind}: private-randomness simulator has E[loss] > E[L_P] in {viol_priv[kind]}/{N_B} "
          f"instances (max excess {max(gaps_priv[kind]):.3f} bits); shared simulator E[loss] > E[L_P] in "
          f"{viol_shared[kind]}/{N_B}")
print("(B) note: the shared-simulator bound carries the input-entropy term, so its violations are expected")
assert viol_priv["bayes"] > 0
print(f"(C) min over instances of E[L_P] - E[-log pi(D)] = {worstC:.4f} (must be >= 0)")
print(f"(C) max over paths of |L_Bayes - (-log pi(D_n))| = {maxdevC:.2e} (must be 0)")
assert worstC >= -1e-9 and maxdevC < 1e-9

# ---------------- (D) peeking ----------------
worst_id = 0.0; worst_ineq = -math.inf; worst_P = math.inf; N_D = 40
for inst in range(N_D):
    pi = rng.dirichlet(np.ones(len(FUNCS)) * 0.5)
    Delta = rand_kernel_peek()
    P = rand_P()
    # joint over (f, h)
    joint = {}
    for fi, f in enumerate(FUNCS):
        for xs in itertools.product(X, repeat=n):
            h = tuple((x, f[x]) for x in xs)
            dx = 1.0
            for i, x in enumerate(xs):
                dx *= Delta[(f, h[:i])][x]
            joint[(fi, h)] = pi[fi] * dx
    # marginals of prefixes
    def pref_prob(hp):
        k = len(hp)
        return sum(w for (fi, h), w in joint.items() if h[:k] == hp)
    pref_cache = {}
    def pp(hp):
        if hp not in pref_cache:
            pref_cache[hp] = pref_prob(hp)
        return pref_cache[hp]
    def pp_x(hp, x):  # prob of prefix hp followed by input x
        key = (hp, x, 'x')
        if key not in pref_cache:
            k = len(hp)
            pref_cache[key] = sum(w for (fi, h), w in joint.items() if h[:k] == hp and h[k][0] == x)
        return pref_cache[key]
    E_logpi = E_logmu = I_dir = E_KL = E_LP = 0.0
    hs = set(h for (_, h) in joint)
    for h in hs:
        ph = pp(h)
        if ph == 0:
            continue
        D = set(h)
        cons = [gj for gj, g in enumerate(FUNCS) if all(g[x] == y for x, y in D)]
        piD = sum(pi[gj] for gj in cons)
        # chronological Bayes label loss and input predictive
        Lmu = 0.0; Lxbar = 0.0
        for i in range(n):
            x, y = h[i]
            Lmu += logp(pp(h[:i + 1]) / pp_x(h[:i], x))
            Lxbar += logp(pp_x(h[:i], x) / pp(h[:i]))
        LP = 0.0
        for i in range(n):
            x, y = h[i]
            LP += logp(P[(h[:i], x)][y])
        # posterior p(f|h) and label-only posterior q_D
        post = {fi: joint.get((fi, h), 0.0) / ph for fi in range(len(FUNCS))}
        q = {gj: pi[gj] / piD for gj in cons}
        KL = sum(p * math.log2(p / q[fi]) for fi, p in post.items() if p > 0)
        # directed information contribution: E[log Delta(x|f) / Deltabar(x||y)]
        for fi, p in post.items():
            if p == 0:
                continue
            f = FUNCS[fi]
            ldx = 0.0
            for i in range(n):
                ldx += -math.log2(Delta[(f, h[:i])][h[i][0]])
            I_dir += ph * p * (Lxbar - ldx)
        E_logpi += ph * logp(piD)
        E_logmu += ph * Lmu
        E_KL += ph * KL
        E_LP += ph * LP
    lhs = E_logpi - E_logmu
    rhs = I_dir - E_KL
    worst_id = max(worst_id, abs(lhs - rhs))
    worst_ineq = max(worst_ineq, lhs - I_dir)
    worst_P = min(worst_P, E_LP - E_logmu)
print(f"(D) max |(E[-log pi(D)] - E[-log mu(y||x)]) - (I_dir - E[KL])| = {worst_id:.2e} (identity)")
print(f"(D) max of (E[-log pi(D)] - E[-log mu(y||x)]) - I_dir = {worst_ineq:.4f} (must be <= 0)")
print(f"(D) min of E[L_P] - E[-log mu(y||x)] = {worst_P:.4f} (must be >= 0)")
assert worst_id < 1e-9 and worst_ineq <= 1e-9 and worst_P >= -1e-9
print("ALL CHECKS PASSED")

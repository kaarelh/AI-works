"""c7: the Shannon form of Hanni's mutual-information question (Prop. 3.10 of notes-final.md).

Setting.  A random function f and a random reveal law K are drawn jointly, (f, K) ~ p.
Given (f, K), a private memory R ~ p(R | K) is drawn (independent of f given K), and the
inputs are drawn from a NON-PEEKING kernel x_i ~ Delta_{K,R}(. | h_{i-1}); y_i = f(x_i).
So, for each fixed law index K, the reveal mechanism sees f only through revealed labels
(Reading C: per-f reveal laws that are standalone samplers), but K may be correlated with f.

Claims checked (all proved in notes-final.md, Prop. 3.10):
 (1) identity  I(f -> x) = I(f;K) - I(f;K | h_n) - sum_i I(y_i ; K | h_{i-1}, x_i),
     where I(f -> x) = sum_i I(f ; x_i | h_{i-1}) is the directed information;
 (2) hence I(f -> x) <= I(f;K);
 (3) with Thm 3.6(a): E[-log pi(D_n)] - E[L_B] <= I(f;K), where pi is the marginal law of f
     and L_B = -log mu(y||x) is the true chronological Bayes loss;
 (4) tightness on the randomized chain (K = the chain itself, a function of f), n = 2, 3:
     I(f -> x) = I(f;K) = H(K) = n(n+1)/2 and E[L_B] = 0.
Setting for (1)-(3): X = {0,1,2}, Y = {0,1}, n = 3, K in {0,1,2}, R in {0,1}; 40 random
instances.  Probabilities are floats; logs base 2.
Seed 20261012.  Output saved to c7_mi_shannon.out.
"""
import itertools, math
from collections import defaultdict
import numpy as np

SEED = 20261012
rng = np.random.default_rng(SEED)
X = (0, 1, 2); Y = (0, 1); n = 3
KS = (0, 1, 2); RS = (0, 1)
FUNCS = list(itertools.product(Y, repeat=len(X)))


def H(dist):
    return -sum(p * math.log2(p) for p in dist.values() if p > 0)


def marg(joint, key):
    out = defaultdict(float)
    for k, p in joint.items():
        out[key(k)] += p
    return out


def cmi(joint, a, b, c):
    """I(A;B|C) = H(A,C) + H(B,C) - H(A,B,C) - H(C) for key functions a, b, c."""
    return (H(marg(joint, lambda k: (a(k), c(k)))) + H(marg(joint, lambda k: (b(k), c(k))))
            - H(marg(joint, lambda k: (a(k), b(k), c(k)))) - H(marg(joint, c)))


def histories_upto(m):
    out = [()]
    for k in range(1, m + 1):
        out += list(itertools.product(itertools.product(X, Y), repeat=k))
    return out


def random_instance():
    pfk = rng.dirichlet(0.5 * np.ones(len(FUNCS) * len(KS))).reshape(len(FUNCS), len(KS))
    prk = {K: rng.dirichlet(np.ones(len(RS))) for K in KS}
    kern = {}
    for K in KS:
        for R in RS:
            for h in histories_upto(n - 1):
                kern[(K, R, h)] = rng.dirichlet(0.7 * np.ones(len(X)))
    return pfk, prk, kern


def build_joint(pfk, prk, kern):
    """joint law over keys (fi, K, xs); labels are determined by f and xs."""
    joint = defaultdict(float)
    for fi, f in enumerate(FUNCS):
        for K in KS:
            for R in RS:
                base = pfk[fi, K] * prk[K][R]
                if base == 0:
                    continue
                for xs in itertools.product(X, repeat=n):
                    p = base
                    h = ()
                    for x in xs:
                        p *= kern[(K, R, h)][x]
                        h = h + ((x, f[x]),)
                    if p > 0:
                        joint[(fi, K, xs)] += p
    return joint


def quantities(joint, nsteps):
    fkey = lambda k: k[0]
    Kkey = lambda k: k[1]

    def hist(k, i):  # h_i as tuple of (x, y) pairs
        f = FUNCS[k[0]]
        return tuple((x, f[x]) for x in k[2][:i])

    xkey = lambda i: (lambda k: k[2][i - 1])
    ykey = lambda i: (lambda k: FUNCS[k[0]][k[2][i - 1]])
    hkey = lambda i: (lambda k: hist(k, i))
    hxkey = lambda i: (lambda k: (hist(k, i - 1), k[2][i - 1]))
    I_dir = sum(cmi(joint, fkey, xkey(i), hkey(i - 1)) for i in range(1, nsteps + 1))
    I_fK = cmi(joint, fkey, Kkey, lambda k: 0)
    I_fK_h = cmi(joint, fkey, Kkey, hkey(nsteps))
    I_yK = sum(cmi(joint, ykey(i), Kkey, hxkey(i)) for i in range(1, nsteps + 1))
    # E[L_B] = sum_i H(y_i | h_{i-1}, x_i)
    ELB = sum(H(marg(joint, lambda k, i=i: (hist(k, i - 1), k[2][i - 1], FUNCS[k[0]][k[2][i - 1]])))
              - H(marg(joint, hxkey(i))) for i in range(1, nsteps + 1))
    # E[-log pi(D_n)], pi = marginal law of f
    pif = marg(joint, fkey)
    def pi_of(D):
        return sum(p for fi, p in pif.items() if all(FUNCS[fi][x] == y for x, y in D))
    cache = {}
    ElogpiD = 0.0
    for k, p in joint.items():
        D = frozenset(hist(k, nsteps))
        if D not in cache:
            cache[D] = -math.log2(pi_of(D))
        ElogpiD += p * cache[D]
    return I_dir, I_fK, I_fK_h, I_yK, ELB, ElogpiD


def main():
    lines = []
    max_id_err = 0.0
    max_slack2 = -math.inf
    max_slack3 = -math.inf
    min_gap = math.inf
    NI = 40
    for t in range(NI):
        pfk, prk, kern = random_instance()
        joint = build_joint(pfk, prk, kern)
        I_dir, I_fK, I_fK_h, I_yK, ELB, ElogpiD = quantities(joint, n)
        max_id_err = max(max_id_err, abs(I_dir - (I_fK - I_fK_h - I_yK)))
        max_slack2 = max(max_slack2, I_dir - I_fK)
        max_slack3 = max(max_slack3, (ElogpiD - ELB) - I_fK)
        min_gap = min(min_gap, I_fK - I_dir)
    lines.append(f"(1) {NI} random instances: max |I(f->x) - [I(f;K) - I(f;K|h_n) - sum_i I(y_i;K|h_(i-1),x_i)]| = {max_id_err:.3e} (identity)")
    lines.append(f"(2) max of I(f->x) - I(f;K) = {max_slack2:.4f} (must be <= 0); min slack I(f;K) - I(f->x) = {min_gap:.4f}")
    lines.append(f"(3) max of (E[-log pi(D_n)] - E[L_B]) - I(f;K) = {max_slack3:.4f} (must be <= 0)")

    # (4) randomized chain: x_i uniform on {0,1}^i; f(x_{i+1}) = x_i, f(x_1) = eps; K = the chain.
    for N in (2, 3):
        chains = list(itertools.product(*[list(itertools.product((0, 1), repeat=i)) for i in range(1, N + 1)]))
        pchain = 1.0 / len(chains)
        # keys: (chain index); f is a function of the chain on the relevant domain, K = chain.
        # Directed information: given the past h_{i-1} (which contains x_1..x_{i-1} and labels),
        # x_i is uniform on {0,1}^i a priori; given f it is determined.  Compute exactly by
        # enumeration over chains with f represented by its graph restricted to {0,1}^{<=N}.
        def fgraph(ch):
            g = {}
            for i in range(1, N + 1):
                for s in itertools.product((0, 1), repeat=i):
                    g[s] = ()
            for i in range(1, N):
                g[ch[i]] = ch[i - 1]
            return tuple(sorted(g.items()))
        joint = {}
        for ci, ch in enumerate(chains):
            joint[ci] = pchain
        fk = lambda ci: fgraph(chains[ci])
        Kk = lambda ci: ci
        def hk(i):
            return lambda ci: tuple((chains[ci][j], dict(fgraph(chains[ci]))[chains[ci][j]]) for j in range(i))
        xk = lambda i: (lambda ci: chains[ci][i - 1])
        I_dir = sum(cmi(joint, fk, xk(i), hk(i - 1)) for i in range(1, N + 1))
        I_fK = cmi(joint, fk, Kk, lambda ci: 0)
        HK = H(marg(joint, Kk))
        ELB = sum(H(marg(joint, lambda ci, i=i: (hk(i)(ci))))
                  - H(marg(joint, lambda ci, i=i: (hk(i - 1)(ci), chains[ci][i - 1]))) for i in range(1, N + 1))
        lines.append(f"(4) randomized chain N={N}: I(f->x) = {I_dir:.6f}, I(f;K) = {I_fK:.6f}, H(K) = {HK:.6f}, "
                     f"E[L_B] = {ELB:.6f}; N(N+1)/2 = {N*(N+1)//2}")
    ok = (max_id_err < 1e-9 and max_slack2 <= 1e-9 and max_slack3 <= 1e-9)
    lines.append("ALL CHECKS PASSED" if ok else "SOME CHECK FAILED")
    out = "\n".join(lines)
    print(out)
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write(out + "\n")


if __name__ == "__main__":
    main()

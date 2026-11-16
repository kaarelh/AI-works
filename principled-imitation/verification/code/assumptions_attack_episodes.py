"""Adversary's exact checks for research/prove-c/assumptions.md, part 2: episodes (Section 1.2).

A nested episodic scaffold is enumerated exactly: a parent episode of two messages with a child
episode of one message between them (L_e = 2 episodes, m_e = 2, L = 3 calls, binary answers).

  call 1  parent, opening message o (top-level input, fair bit)   input ('P', o)        -> a1
  call 2  child, opening message c = a1 xor rho (rho a fair bit)   input ('C', c)        -> b
  call 3  parent, second message b                                 input ('P', o, a1, b) -> a2

  A  Lemma 1.6: the run of the episodic mixture has the law of 'one posterior draw per episode'
  B  Theorem 1.7 (stochastic human, nested episodes): sum over rounds and episodes of
     KL(Q_{M[i<-P]} || Q_M) <= L_e K ln 2, Protocol R^ep enumerated exactly
  C  Theorem 1.7(b), 1.8(a) (deterministic human): E[N_ep(C)] <= sum_i KL(Q_{C[i<-f]} || Q_C),
     and Pr[mismatch in a validation round] = E[N_ep(C)]/L_e
  D  Theorem 1.9: search for a large ratio H^2(Q_C, Q_P) / sum_i KL(Q_{C[i<-P]} || Q_C) in a
     nested scaffold with m_e = 3 (a parent of three messages, two children), by hill climbing;
     the proved bound is 4 m_e = 12, the sequential bound is 2
  E  Example 1.1 and Example 1.10: the numbers claimed (total variation 1/2 and 1)

Usage: python3 assumptions_attack_episodes.py [seed]
"""
import itertools
import math
import sys

import numpy as np

SEED = int(sys.argv[1]) if len(sys.argv) > 1 else 20261117
INF = float("inf")

# inputs of the nested scaffold
X = [("P", o) for o in (0, 1)] + [("C", c) for c in (0, 1)] + \
    [("P", o, a1, b) for o in (0, 1) for a1 in (0, 1) for b in (0, 1)]
IDX = {x: i for i, x in enumerate(X)}
NX = len(X)


def kl2(p, q):
    s = 0.0
    for a, b in zip(p, q):
        if a > 0:
            if b <= 0:
                return INF
            s += a * math.log(a / b)
    return s


def run_law(kern_parent1, kern_child, kern_parent2):
    """Law of (o, rho, a1, b, a2) when call 1 is answered by kern_parent1 (a function of the
    input index giving a distribution), call 2 by kern_child, call 3 by kern_parent2.  The
    answerer of call 3 may depend on a1 (the episodic mixture conditions on it): it is given
    the pair (input index, a1)."""
    law = {}
    for o in (0, 1):
        for rho in (0, 1):
            p1 = kern_parent1(IDX[("P", o)])
            for a1 in (0, 1):
                pc = kern_child(IDX[("C", a1 ^ rho)])
                for b in (0, 1):
                    p3 = kern_parent2(IDX[("P", o, a1, b)], IDX[("P", o)], a1)
                    for a2 in (0, 1):
                        pr = 0.25 * p1[a1] * pc[b] * p3[a2]
                        if pr > 0:
                            law[(o, rho, a1, b, a2)] = pr
    return law


def kl_laws(P, Q):
    s = 0.0
    for k, p in P.items():
        q = Q.get(k, 0.0)
        if q <= 0:
            return INF
        s += p * math.log(p / q)
    return s


def hell2_laws(P, Q):
    return 1.0 - sum(math.sqrt(p * Q.get(k, 0.0)) for k, p in P.items())


class Mix:
    def __init__(self, kernels, w):
        self.k = [np.asarray(a, float) for a in kernels]
        self.w = np.asarray(w, float)

    def post(self, data):
        v = self.w.copy()
        for (x, y) in data:
            v = v * np.array([a[x, y] for a in self.k])
        s = v.sum()
        return v / s if s > 0 else self.w / self.w.sum()

    def M(self, data, x):
        p = self.post(data)
        return sum(pi * a[x] for pi, a in zip(p, self.k))


def episodic_run_law(mix, data, parent=None, child=None):
    """Run answered by the episodic mixture of `data`; if parent (child) is a kernel, that
    episode is answered by it instead (the hybrid C[i<-P])."""
    def k1(x):
        return parent[x] if parent is not None else mix.M(data, x)

    def kc(x):
        return child[x] if child is not None else mix.M(data, x)

    def k3(x, x1, a1):
        return parent[x] if parent is not None else mix.M(data + ((x1, a1),), x)

    return run_law(k1, kc, k3)


def sampler_run_law(C, parent=None, child=None):
    return run_law(lambda x: (parent if parent is not None else C)[x],
                   lambda x: (child if child is not None else C)[x],
                   lambda x, x1, a1: (parent if parent is not None else C)[x])


def rand_kernel(rng, det=False):
    if det:
        k = np.zeros((NX, 2))
        k[np.arange(NX), rng.integers(0, 2, NX)] = 1.0
        return k
    return rng.dirichlet(np.ones(2), size=NX)


def part_A(rng):
    print("== A: Lemma 1.6 (episodic mixture = one posterior draw per episode), exact")
    worst = 0.0
    for trial in range(20):
        H = int(rng.integers(2, 5))
        kern = [rand_kernel(rng) for _ in range(H)]
        mix = Mix(kern, rng.dirichlet(np.ones(H)))
        data = tuple((int(rng.integers(0, NX)), int(rng.integers(0, 2))) for _ in range(int(rng.integers(0, 4))))
        law1 = episodic_run_law(mix, data)
        post = mix.post(data)
        law2 = {}
        for i in range(H):
            for j in range(H):
                for k, p in sampler_run_law(kern[i], child=kern[j]).items():
                    law2[k] = law2.get(k, 0.0) + post[i] * post[j] * p
        worst = max(worst, max(abs(law1.get(k, 0.0) - law2.get(k, 0.0)) for k in set(law1) | set(law2)))
    print(f"  20 random instances: largest difference between the two run laws = {worst:.2e}")


def part_B(rng):
    print("== B: Theorem 1.7, nested episodes, human not deterministic; Protocol R^ep exactly")
    worst = INF
    for trial in range(10):
        H = int(rng.integers(2, 4))
        kern = [rand_kernel(rng) for _ in range(H)]
        w = rng.dirichlet(np.ones(H))
        mix = Mix(kern, w)
        P = kern[0]
        n = 3
        states = {(): 1.0}
        total = 0.0
        for t in range(1, n + 1):
            new = {}
            for data, pr in states.items():
                base = episodic_run_law(mix, data)
                h_par = episodic_run_law(mix, data, parent=P)
                h_chi = episodic_run_law(mix, data, child=P)
                total += pr * (kl_laws(h_par, base) + kl_laws(h_chi, base))
                # I = 1: the human carries out the parent episode; both of its pairs become data
                for (o, rho, a1, b, a2), q in h_par.items():
                    nd = data + ((IDX[("P", o)], a1), (IDX[("P", o, a1, b)], a2))
                    nd = tuple(sorted(nd))
                    new[nd] = new.get(nd, 0.0) + pr * 0.5 * q
                # I = 2: the human carries out the child episode
                for (o, rho, a1, b, a2), q in h_chi.items():
                    nd = tuple(sorted(data + ((IDX[("C", a1 ^ rho)], b),)))
                    new[nd] = new.get(nd, 0.0) + pr * 0.5 * q
            states = new
        bound = 2 * math.log(1.0 / w[0])
        assert total <= bound + 1e-9, (total, bound)
        worst = min(worst, bound - total)
    print(f"  10 random instances (n = 3): smallest value of L_e K ln 2 - sum = {worst:.4f}  (>= 0 required)")
    print("  (sorting the data is harmless: the episodic mixture conditions on the multiset of pairs)")


def part_C(rng):
    print("== C: Theorem 1.7(b) and 1.8(a), deterministic human, any sampler C, exact")
    worst = INF
    worst_id = 0.0
    for trial in range(200):
        f = rand_kernel(rng, det=True)
        C = rand_kernel(rng)
        if trial % 4 == 0:        # C close to f
            C = 0.97 * f + 0.03 * C
        law = sampler_run_law(C)
        n_ep = 0.0
        pr_par = pr_chi = 0.0
        for (o, rho, a1, b, a2), q in law.items():
            par_bad = int((f[IDX[("P", o)], a1] == 0) or (f[IDX[("P", o, a1, b)], a2] == 0))
            chi_bad = int(f[IDX[("C", a1 ^ rho)], b] == 0)
            n_ep += q * (par_bad + chi_bad)
            pr_par += q * par_bad
            pr_chi += q * chi_bad
        s = kl_laws(sampler_run_law(C, parent=f), law) + kl_laws(sampler_run_law(C, child=f), law)
        worst = min(worst, s - n_ep)
        assert n_ep <= s + 1e-9
        # validation round: hybrid run, C's answers drawn alongside at the human's messages
        mis_par = 0.0
        for (o, rho, a1, b, a2), q in sampler_run_law(C, parent=f).items():
            ok = C[IDX[("P", o)], a1] * C[IDX[("P", o, a1, b)], a2]      # a1, a2 are f's answers
            mis_par += q * (1 - ok)
        mis_chi = 0.0
        for (o, rho, a1, b, a2), q in sampler_run_law(C, child=f).items():
            mis_chi += q * (1 - C[IDX[("C", a1 ^ rho)], b])
        worst_id = max(worst_id, abs(0.5 * (mis_par + mis_chi) - n_ep / 2), abs(mis_par - pr_par),
                       abs(mis_chi - pr_chi))
    print(f"  200 random pairs: smallest (sum_i KL_i - E[N_ep]) = {worst:.4e} (>= 0 required);")
    print(f"  largest |Pr[mismatch] - E[N_ep]/L_e| = {worst_id:.2e}")


# --- part D: a nested scaffold with m_e = 3 ----------------------------------------------------
# parent messages: (), then b1, then b2; children: child1 input a1, child2 input a2 (distinct
# strings, so 4 child inputs).  Run = (a1, b1, a2, b2, a3).
def law3(par, ch):
    """par: dict history -> prob of answer 1; ch: dict (k, a) -> prob of answer 1."""
    law = {}
    for a1, b1, a2, b2, a3 in itertools.product((0, 1), repeat=5):
        def pick(p, bit):
            return p if bit else 1 - p
        pr = pick(par[()], a1) * pick(ch[(1, a1)], b1) * pick(par[(a1, b1)], a2) \
            * pick(ch[(2, a2)], b2) * pick(par[(a1, b1, a2, b2)], a3)
        law[(a1, b1, a2, b2, a3)] = pr
    return law


PAR_KEYS = [()] + list(itertools.product((0, 1), repeat=2)) + list(itertools.product((0, 1), repeat=4))
CH_KEYS = [(1, 0), (1, 1), (2, 0), (2, 1)]


def unpack(v):
    par = {k: v[i] for i, k in enumerate(PAR_KEYS)}
    ch = {k: v[len(PAR_KEYS) + i] for i, k in enumerate(CH_KEYS)}
    return par, ch


def ratio3(vC, vP):
    parC, chC = unpack(vC)
    parP, chP = unpack(vP)
    QC = law3(parC, chC)
    QP = law3(parP, chP)
    h2 = 1.0 - sum(math.sqrt(QC[k] * QP[k]) for k in QC)
    s = 0.0
    hyb = law3(parP, chC)                               # parent episode by P
    s += sum(p * math.log(p / QC[k]) for k, p in hyb.items() if p > 0)
    for child in (1, 2):                                # each child episode by P
        ch = dict(chC)
        for a in (0, 1):
            ch[(child, a)] = chP[(child, a)]
        hyb = law3(parC, ch)
        s += sum(p * math.log(p / QC[k]) for k, p in hyb.items() if p > 0)
    return h2 / s if s > 1e-300 else 0.0, h2, s


def part_D(rng):
    print("== D: Theorem 1.9(b), nested scaffold with m_e = 3: search for a large ratio")
    dim = len(PAR_KEYS) + len(CH_KEYS)
    best = (0.0, None)
    for restart in range(60):
        vC = rng.uniform(0.02, 0.98, dim)
        vP = rng.uniform(0.02, 0.98, dim) if restart % 2 else np.clip(vC + rng.normal(0, 0.05, dim), 0.02, 0.98)
        if restart % 3 == 0:
            vP = rng.choice([0.001, 0.5, 0.999], dim)
        cur = ratio3(vC, vP)[0]
        step = 0.2
        for it in range(3000):
            which = rng.integers(0, 2)
            i = rng.integers(0, dim)
            cand_C, cand_P = vC.copy(), vP.copy()
            tgt = cand_C if which == 0 else cand_P
            tgt[i] = min(0.9999, max(0.0001, tgt[i] + rng.normal(0, step)))
            val = ratio3(cand_C, cand_P)[0]
            if val > cur:
                cur, vC, vP = val, cand_C, cand_P
            if it % 500 == 499:
                step *= 0.6
        if cur > best[0]:
            best = (cur, (vC.copy(), vP.copy()))
    r, h2, s = ratio3(*best[1])
    print(f"  60 restarts of hill climbing: largest ratio H^2/sum_i KL_i = {best[0]:.4f}"
          f"  (H^2 = {h2:.4f}, sum = {s:.4f});")
    print("  proved bound 4 m_e = 12; the bound for sequential episodes is 2; 1/2 is the value for two")
    print("  close distributions")


def part_E():
    print("== E: Examples 1.1 and 1.10")
    real = {(0, 0): 0.5, (1, 1): 0.5}
    cold = {(a, b): 0.25 for a in (0, 1) for b in (0, 1)}
    tv = 0.5 * sum(abs(real.get(k, 0) - cold.get(k, 0)) for k in cold)
    print(f"  Example 1.1: TV(real system, system of cold humans) = {tv}")
    print("  Example 1.10: second answer uniform on {0,1} against the point mass at '?': TV = 1")


if __name__ == "__main__":
    print(f"seed {SEED}")
    rng = np.random.default_rng(SEED)
    part_A(rng)
    part_B(rng)
    part_C(rng)
    part_D(rng)
    part_E()

"""Referee checks for research/prove-c/assumptions.md, part 2: episodes (Section 1.2).

Scaffold N1 (nested): z uniform on {0,1}; call 1 = parent, message 1, input ('p', z);
call 2 = child (a second episode), input ('c', z, a1); call 3 = parent, message 2, with the
visible history ('p', z, a1, b). Binary answers. L_e = 2 episodes, m_e = 2.

  A  Lemma 1.6: the run law of the episodic mixture equals the law of "one posterior draw
     per episode" (exact, random posteriors).
  B  Theorem 1.7, exact enumeration of Protocol R^ep for n = 3 rounds:
     sum_t E sum_i KL(Q_{M[i<-P]} || Q_M) = L_e (ln(W/w(P)) - E ln(1/w_{D_n}(P))) <= L_e K ln 2.
  C  Theorem 1.7(b) and Theorem 1.8(a) for a deterministic human: E N_ep(C) <= sum_i KL_i,
     and the mismatch probability of a validation round equals E N_ep(C)/L_e (exact).
  D  Theorem 1.9: search for a large ratio H^2(Q_C, Q_P) / sum_i KL(Q_{C[i<-P]} || Q_C) on
     three scaffolds (nested with two children; two interleaved episodes; N1), and the
     referee's inequalities
        sqrt(H^2(Q_C,Q_P)) <= sum_i sqrt(H^2(Q_C, Q_{C[i<-P]}))   (any interleaving)
        H^2(Q_C,Q_P) <= 2 sum_i H^2(Q_C, Q_{C[i<-P]})             (two episodes).

Usage: python3 assumptions_check_episodes.py [seed]
"""
import itertools
import math
import sys

import numpy as np

SEED = int(sys.argv[1]) if len(sys.argv) > 1 else 7
LN2 = math.log(2.0)

# ------------------------------------------------------------------------------------------
# Scaffold N1. A sampler is an array of 14 numbers: the probability of the answer 1 at
#   ('p', z)            index z                     (2)
#   ('c', z, a1)        index 2 + 2 z + a1          (4)
#   ('p', z, a1, b)     index 6 + 4 z + 2 a1 + b    (8)
def ip1(z): return z
def ic(z, a1): return 2 + 2 * z + a1
def ip2(z, a1, b): return 6 + 4 * z + 2 * a1 + b


def pr(s, idx, y):
    return s[idx] if y == 1 else 1.0 - s[idx]


RUNS = list(itertools.product((0, 1), repeat=4))        # (z, a1, b, a2)


def run_law(parent, child):
    """Law of the run when the parent episode is answered by `parent` and the child by `child`
    (each a function (index, y) -> probability)."""
    q = {}
    for z, a1, b, a2 in RUNS:
        q[(z, a1, b, a2)] = 0.5 * parent(ip1(z), a1, None) * child(ic(z, a1), b) * parent(ip2(z, a1, b), a2, (ip1(z), a1))
    return q


def sampler_parent(s):
    return lambda idx, y, hist: pr(s, idx, y)


def sampler_child(s):
    return lambda idx, y: pr(s, idx, y)


def kl_laws(p, q):
    tot = 0.0
    for k, pk in p.items():
        if pk > 0:
            if q[k] <= 0:
                return math.inf
            tot += pk * math.log(pk / q[k])
    return tot


def h2_laws(p, q):
    return 1.0 - sum(math.sqrt(p[k] * q[k]) for k in p)


def part_A(rng):
    print("== A: Lemma 1.6 on the nested scaffold N1 (random classes of 5 samplers, random weights)")
    worst = 0.0
    for _ in range(200):
        H = rng.random((5, 14))
        w = rng.dirichlet(np.ones(5))
        # law of "one posterior draw per episode"
        q_draw = {r: 0.0 for r in RUNS}
        for i in range(5):
            for j in range(5):
                law = run_law(sampler_parent(H[i]), sampler_child(H[j]))
                for r in RUNS:
                    q_draw[r] += w[i] * w[j] * law[r]
        # law of the episodic mixture: M at fresh histories, M_{D + pairs(v)} at the parent's 2nd call

        def mix_parent(idx, y, hist):
            if hist is None:
                return float(sum(w[i] * pr(H[i], idx, y) for i in range(5)))
            hidx, hy = hist
            post = np.array([w[i] * pr(H[i], hidx, hy) for i in range(5)])
            post = post / post.sum()
            return float(sum(post[i] * pr(H[i], idx, y) for i in range(5)))

        def mix_child(idx, y):
            return float(sum(w[i] * pr(H[i], idx, y) for i in range(5)))

        q_mix = run_law(mix_parent, mix_child)
        worst = max(worst, max(abs(q_mix[r] - q_draw[r]) for r in RUNS))
    print(f"    max |Q_episodic-mixture(run) - Q_one-draw-per-episode(run)| over 200 instances: {worst:.2e}")


def part_B(rng):
    print("== B: Theorem 1.7 on N1, exact enumeration of Protocol R^ep, n = 3 rounds")
    for trial in range(3):
        nH = 4
        H = rng.random((nH, 14)) * 0.9 + 0.05
        w = rng.dirichlet(np.ones(nH)) * 0.8          # W = 0.8 < 1
        P = H[0]
        Le = 2

        def post_of(data):
            lik = np.ones(nH)
            for idx, y in data:
                lik = lik * np.where(y == 1, H[:, idx], 1.0 - H[:, idx])
            pw = w * lik
            return pw / pw.sum()

        def mixers(post):
            def mp(idx, y, hist):
                if hist is None:
                    p = post
                else:
                    hidx, hy = hist
                    p = post * np.where(hy == 1, H[:, hidx], 1.0 - H[:, hidx])
                    p = p / p.sum()
                return float(p @ np.where(y == 1, H[:, idx], 1.0 - H[:, idx]))

            def mc(idx, y):
                return float(post @ np.where(y == 1, H[:, idx], 1.0 - H[:, idx]))
            return mp, mc

        total = 0.0
        e_surprise = 0.0
        paths = {(): 1.0}
        n = 3
        for t in range(n):
            new = {}
            for data, prob in paths.items():
                post = post_of(data)
                mp, mc = mixers(post)
                qM = run_law(mp, mc)
                q1 = run_law(sampler_parent(P), mc)            # parent episode by the human
                q2 = run_law(mp, sampler_child(P))             # child episode by the human
                total += prob * (kl_laws(q1, qM) + kl_laws(q2, qM))
                # round: I = 1 (parent to the human): data gets both parent pairs
                for (z, a1, b, a2), pq in q1.items():
                    nd = tuple(sorted(data + ((ip1(z), a1), (ip2(z, a1, b), a2))))
                    new[nd] = new.get(nd, 0.0) + prob * 0.5 * pq
                # I = 2 (child to the human): data gets the child's pair
                marg = {}
                for (z, a1, b, a2), pq in q2.items():
                    marg[(z, a1, b)] = marg.get((z, a1, b), 0.0) + pq
                for (z, a1, b), pq in marg.items():
                    nd = tuple(sorted(data + ((ic(z, a1), b),)))
                    new[nd] = new.get(nd, 0.0) + prob * 0.5 * pq
            paths = new
        for data, prob in paths.items():
            e_surprise += prob * math.log(1.0 / post_of(data)[0])
        W = w.sum()
        exact = Le * (math.log(W / w[0]) - e_surprise)
        bound = Le * math.log(W / w[0])
        print(f"    instance {trial}: sum_t E sum_i KL(Q_M[i<-P] || Q_M) = {total:.8f};"
              f"  L_e (ln(W/w(P)) - E ln(1/w_Dn(P))) = {exact:.8f};  L_e ln(W/w(P)) = {bound:.4f}"
              f"  (total probability {sum(paths.values()):.10f})")


def part_C(rng):
    print("== C: Theorems 1.7(b), 1.8(a) on N1, deterministic human f, random samplers C")
    worst_gap = math.inf
    worst_mis = 0.0
    for _ in range(2000):
        f = rng.integers(0, 2, size=14)                 # the human: a function on visible histories
        C = rng.random(14) * 0.98 + 0.01
        fs = f.astype(float)
        qC = run_law(sampler_parent(C), sampler_child(C))
        q1 = run_law(sampler_parent(fs), sampler_child(C))
        q2 = run_law(sampler_parent(C), sampler_child(fs))
        kls = kl_laws(q1, qC) + kl_laws(q2, qC)
        # unfaithful episodes of a run of C
        un1 = sum(p for (z, a1, b, a2), p in qC.items() if a1 != f[ip1(z)] or a2 != f[ip2(z, a1, b)])
        un2 = sum(p for (z, a1, b, a2), p in qC.items() if b != f[ic(z, a1)])
        worst_gap = min(worst_gap, kls - (un1 + un2))
        # mismatch probability of a validation round (hybrid run, C's answers drawn alongside)
        mis1 = 0.0
        for (z, a1, b, a2), p in q1.items():           # parent by f; alongside draws of C at both parent calls
            ok = pr(C, ip1(z), a1) * pr(C, ip2(z, a1, b), a2)
            mis1 += p * (1.0 - ok)
        mis2 = 0.0
        for (z, a1, b, a2), p in q2.items():
            mis2 += p * (1.0 - pr(C, ic(z, a1), b))
        worst_mis = max(worst_mis, abs(mis1 - un1), abs(mis2 - un2))
    print(f"    min over 2000 instances of sum_i KL(Q_C[i<-f] || Q_C) - E N_ep(C) = {worst_gap:.6f} (>= 0)")
    print(f"    max |Pr[mismatch | I = i] - Pr[episode i of a run of C is unfaithful]| = {worst_mis:.2e}")


# ------------------------------------------------------------------------------------------
# General scaffolds for part D: a list of calls; call j belongs to episode ep[j]; every call
# sees the full history of earlier answers (so each call has its own free parameter per history:
# this is the most general sampler for scaffolds without top-level input).
def laws_general(ep, thetaC, thetaP, who):
    """who: set of episodes answered by P. theta[j][history] = Pr[answer 1]."""
    ncalls = len(ep)
    q = {}
    for ys in itertools.product((0, 1), repeat=ncalls):
        p = 1.0
        for j in range(ncalls):
            th = (thetaP if ep[j] in who else thetaC)[j][ys[:j]]
            p *= th if ys[j] == 1 else 1.0 - th
        q[ys] = p
    return q


def ratio_general(ep, vec):
    ncalls = len(ep)
    eps = sorted(set(ep))
    thetaC, thetaP = [], []
    pos = 0
    for j in range(ncalls):
        dC, dP = {}, {}
        for hist in itertools.product((0, 1), repeat=j):
            dC[hist] = vec[pos]
            dP[hist] = vec[pos + 1]
            pos += 2
        thetaC.append(dC)
        thetaP.append(dP)
    qC = laws_general(ep, thetaC, thetaP, set())
    qP = laws_general(ep, thetaC, thetaP, set(eps))
    h2 = h2_laws(qC, qP)
    kls, h2s = [], []
    for i in eps:
        qi = laws_general(ep, thetaC, thetaP, {i})
        kls.append(kl_laws(qi, qC))
        h2s.append(h2_laws(qi, qC))
    return h2, kls, h2s


def part_D(rng):
    print("== D: Theorem 1.9, ratio H^2(Q_C,Q_P) / sum_i KL(Q_C[i<-P] || Q_C); random search and hill climbing")
    scaffolds = (
        ("sequential, 2 episodes of 2 calls   (A A B B)", [0, 0, 1, 1], 2, 2),
        ("nested, parent 2 calls + 1 child    (A B A)", [0, 1, 0], 2, 4 * 2),
        ("nested, parent 3 calls + 2 children (A B A C A)", [0, 1, 0, 2, 0], 3, 4 * 3),
        ("interleaved, 2 episodes of 3 calls  (A B A B A B)", [0, 1, 0, 1, 0, 1], 3, 4 * 3),
        ("interleaved, 3 episodes of 2 calls  (A B C A B C)", [0, 1, 2, 0, 1, 2], 2, 4 * 2),
    )
    for name, ep, m_e, proved in scaffolds:
        npar = 2 * sum(2 ** j for j in range(len(ep)))
        best = 0.0
        best_metric = 0.0     # sqrt(H2) / sum_i sqrt(H2_i)
        best_two = 0.0        # H2 / sum_i H2_i
        for restart in range(40):
            # start near the regime P = point masses, C close to P (ratio H2/KL near 1/2), or random
            if restart % 2 == 0:
                v = rng.random(npar)
            else:
                v = rng.random(npar)
                v[1::2] = np.round(v[1::2])            # P deterministic
                v[0::2] = np.clip(v[1::2] + rng.normal(0, 0.1, npar // 2), 0.01, 0.99)
            v = np.clip(v, 1e-6, 1 - 1e-6)

            def val(u):
                h2, kls, h2s = ratio_general(ep, u)
                s = sum(kls)
                return h2 / s if s > 0 and s < math.inf else 0.0

            cur = val(v)
            step = 0.2
            for it in range(400):
                cand = np.clip(v + rng.normal(0, step, npar) * (rng.random(npar) < 0.3), 1e-9, 1 - 1e-9)
                c = val(cand)
                if c > cur:
                    v, cur = cand, c
                elif it % 50 == 49:
                    step *= 0.7
            h2, kls, h2s = ratio_general(ep, v)
            best = max(best, cur)
            if sum(h2s) > 0:
                best_metric = max(best_metric, math.sqrt(h2) / sum(math.sqrt(x) for x in h2s))
                best_two = max(best_two, h2 / sum(h2s))
        print(f"    {name}: largest H^2/sum_i KL_i found = {best:.4f}   (proved bound {proved});"
              f"  at the maximisers sqrt(H^2)/sum_i sqrt(H^2_i) <= {best_metric:.4f}, H^2/sum_i H^2_i <= {best_two:.4f}")
    # direct search for the two referee inequalities
    print("   referee's inequalities, searched directly (hill climbing on the ratio itself):")
    for name, ep, m_e, proved in scaffolds:
        npar = 2 * sum(2 ** j for j in range(len(ep)))
        neps = len(set(ep))
        best_metric = 0.0
        best_sq = 0.0
        for restart in range(30):
            for target in ("metric", "sq"):
                v = np.clip(rng.random(npar), 1e-6, 1 - 1e-6)

                def val(u):
                    h2, kls, h2s = ratio_general(ep, u)
                    if target == "metric":
                        d = sum(math.sqrt(max(x, 0.0)) for x in h2s)
                        return math.sqrt(max(h2, 0.0)) / d if d > 1e-12 else 0.0
                    d = sum(h2s)
                    return h2 / d if d > 1e-12 else 0.0

                cur = val(v)
                step = 0.2
                for it in range(300):
                    cand = np.clip(v + rng.normal(0, step, npar) * (rng.random(npar) < 0.3), 0.0, 1.0)
                    c = val(cand)
                    if c > cur:
                        v, cur = cand, c
                    elif it % 50 == 49:
                        step *= 0.7
                if target == "metric":
                    best_metric = max(best_metric, cur)
                else:
                    best_sq = max(best_sq, cur)
        print(f"    {name}: max sqrt(H^2)/sum_i sqrt(H^2_i) = {best_metric:.4f} (proved <= 1);"
              f"  max H^2/sum_i H^2_i = {best_sq:.4f} (proved <= {2 if neps == 2 else neps})")


if __name__ == "__main__":
    rng = np.random.default_rng(SEED)
    print(f"seed {SEED}")
    part_A(rng)
    part_B(rng)
    part_C(rng)
    part_D(rng)

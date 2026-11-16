"""Exact check of the inequality behind Theorem 1.9 of research/prove-c/assumptions.md.

For samplers C (imitator) and P (human) on visible histories of episodes, Theorem 1.9 rests on

    H^2(Q_C, Q_P)  <=  c * sum_i KL(Q_{C[i<-P]} || Q_C),

with c = 2 for sequential episodes and c = 4 m_e for nested ones (m_e = messages per episode).
Two small scaffolds with binary answers are enumerated exactly:

  sequential: two episodes of two messages each; the scaffold's second message of an episode
              depends on the first answer and a coin; the opening of episode 2 depends on the
              answers of episode 1.          (L_e = 2, m_e = 2, L = 4)
  nested:     a parent episode of two messages and, between them, a child episode of one
              message whose input depends on the parent's first answer and a coin; the parent's
              second message contains the child's answer.   (L_e = 2, m_e = 2, L = 3)

The script draws random pairs (C, P), and then runs a local search that tries to make the ratio
H^2 / sum_i KL_i large. It reports the largest ratio found. For the nested scaffold the proved
constant is 8; the search asks whether the constant 2 of the sequential case could fail.

Usage: python3 assumptions_episodes.py [seed]
"""
import itertools
import math
import sys

import numpy as np

SEED = int(sys.argv[1]) if len(sys.argv) > 1 else 20261115
B = (0, 1)


def kl(p, q):
    s = 0.0
    for a, b in zip(p, q):
        if a > 0:
            if b <= 0:
                return math.inf
            s += a * math.log(a / b)
    return s


def hell(p, q):
    return 1.0 - sum(math.sqrt(a * b) for a, b in zip(p, q))


# ---- nested scaffold --------------------------------------------------------------------
# kernels are given by the probability of answer 1 at each visible history:
#   parent msg 1: index z                      (2 histories)
#   child:        index (y1, rho)              (4 histories)
#   parent msg 2: index (z, y1, yc)            (8 histories)
def nested_law(k1, kc, k2):
    """k1, kc, k2: arrays of P[answer = 1]; returns the law of (z, rho, y1, yc, y2) as a list."""
    out = []
    for z, rho, y1, yc, y2 in itertools.product(B, B, B, B, B):
        a = k1[z] if y1 else 1 - k1[z]
        b = kc[y1, rho] if yc else 1 - kc[y1, rho]
        c = k2[z, y1, yc] if y2 else 1 - k2[z, y1, yc]
        out.append(0.25 * a * b * c)
    return out


def nested_ratio(theta):
    C1, Cc, C2, P1, Pc, P2 = theta
    qc = nested_law(C1, Cc, C2)
    qp = nested_law(P1, Pc, P2)
    q_parent = nested_law(P1, Cc, P2)      # the parent episode handed to the human
    q_child = nested_law(C1, Pc, C2)       # the child episode handed to the human
    den = kl(q_parent, qc) + kl(q_child, qc)
    return hell(qc, qp) / den if den > 0 else 0.0


# ---- sequential scaffold ----------------------------------------------------------------
# episode e in {1, 2}; opening o = z for episode 1 and o = (y1 xor y2 of episode 1) for episode 2;
# second message of the scaffold: (first answer, coin rho_e).
#   message 1 of an episode: index (e, o)                (4 histories)
#   message 2 of an episode: index (e, o, y, rho_e)      (16 histories)
def seq_law(k1, k2, who=(0, 0), other=None):
    """who[e] = 0: the kernels (k1, k2) answer episode e; 1: the kernels in `other` do."""
    out = []
    for z, r1, r2, a1, a2, b1, b2 in itertools.product(B, B, B, B, B, B, B):
        pr = 0.125
        ka = (k1, k2) if who[0] == 0 else other
        kb = (k1, k2) if who[1] == 0 else other
        p = ka[0][0, z]
        pr *= p if a1 else 1 - p
        p = ka[1][0, z, a1, r1]
        pr *= p if a2 else 1 - p
        o = a1 ^ a2
        p = kb[0][1, o]
        pr *= p if b1 else 1 - p
        p = kb[1][1, o, b1, r2]
        pr *= p if b2 else 1 - p
        out.append(pr)
    return out


def seq_ratio(theta):
    C1, C2, P1, P2 = theta
    qc = seq_law(C1, C2)
    qp = seq_law(P1, P2)
    q1 = seq_law(C1, C2, who=(1, 0), other=(P1, P2))
    q2 = seq_law(C1, C2, who=(0, 1), other=(P1, P2))
    den = kl(q1, qc) + kl(q2, qc)
    return hell(qc, qp) / den if den > 0 else 0.0


def search(ratio, shapes, rng, n_random, n_climb):
    def draw():
        return [np.clip(rng.beta(0.5, 0.5, size=s), 1e-6, 1 - 1e-6) for s in shapes]

    best, best_theta = 0.0, None
    for _ in range(n_random):
        th = draw()
        r = ratio(th)
        if r > best:
            best, best_theta = r, th
    rand_best = best
    th = [a.copy() for a in best_theta]
    step = 0.2
    for it in range(n_climb):
        cand = [np.clip(a + step * rng.normal(size=a.shape) * (rng.random(a.shape) < 0.3),
                        1e-6, 1 - 1e-6) for a in th]
        r = ratio(cand)
        if r > best:
            best, th = r, cand
        if it % 2000 == 1999:
            step *= 0.7
    return rand_best, best


if __name__ == "__main__":
    rng = np.random.default_rng(SEED)
    print(f"seed {SEED}")
    rb, b = search(seq_ratio, [(2, 2), (2, 2, 2, 2), (2, 2), (2, 2, 2, 2)], rng, 3000, 12000)
    print(f"sequential episodes: largest H^2/sum_i KL_i  random {rb:.4f}, after local search {b:.4f}"
          f"   (proved bound 2)")
    rb, b = search(nested_ratio, [(2,), (2, 2), (2, 2, 2), (2,), (2, 2), (2, 2, 2)], rng, 20000, 40000)
    print(f"nested episodes:     largest H^2/sum_i KL_i  random {rb:.4f}, after local search {b:.4f}"
          f"   (proved bound 4 m_e = 8)")

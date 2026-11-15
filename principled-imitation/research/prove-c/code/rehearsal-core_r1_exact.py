#!/usr/bin/env python3
"""Exact check of Theorem R1 (and of the remarks on several questions per run)
on tiny instances, by enumeration of all data histories of Protocol R.

Scaffold (L = 2, variable length): z uniform on {0,1}; call 1 at x = z;
if z = 0: call 2 at x = 2 + y_1;  if z = 1: STOP if y_1 = 0, else call 2 at x = 3.
Answers are bits. A kernel is a tuple p with p[x] = probability of answer 1 at x.
"""
import math

L = 2
X = range(4)

def runs(M):
    """All runs of the scaffold answered by kernel M: list of (prob, [x_1..x_T])."""
    out = []
    for z in (0, 1):
        for y1 in (0, 1):
            p1 = 0.5 * (M[z] if y1 else 1 - M[z])
            if p1 == 0:
                continue
            if z == 1 and y1 == 0:
                out.append((p1, [z]))
                continue
            x2 = 2 + y1 if z == 0 else 3
            out.append((p1, [z, x2]))   # the answer at call 2 does not change the inputs
    return out

def kl(p, q):
    s = 0.0
    for a, b in ((p, q), (1 - p, 1 - q)):
        if a > 0:
            if b == 0:
                return math.inf
            s += a * math.log(a / b)
    return s

def mixture(w, lik, H):
    tot = sum(wi * li for wi, li in zip(w, lik))
    post = [wi * li / tot for wi, li in zip(w, lik)]
    return [sum(pi * h[x] for pi, h in zip(post, H)) for x in X], post

def Lam(M, P):      # Lambda(M) = E_{Q_M} sum_j KL(P || M)(x_j)
    return sum(pr * sum(kl(P[x], M[x]) for x in xs) for pr, xs in runs(M))

def beta(M, P):     # expected number of unfaithful calls = E_{Q_M} sum_j TV(P, M)(x_j)
    return sum(pr * sum(abs(P[x] - M[x]) for x in xs) for pr, xs in runs(M))

def protocol(H, w, P, n, ask_all=False):
    """Returns (sum_t E Lambda(M^(t)), sum_t E beta(M^(t)), sum_t E[a_t kappa_t])."""
    tot = [0.0, 0.0, 0.0]
    def rec(t, lik, prob):
        if t > n or prob == 0:
            return
        M, _ = mixture(w, lik, H)
        tot[0] += prob * Lam(M, P)
        tot[1] += prob * beta(M, P)
        if not ask_all:
            # one question: call J uniform on {1..L}; children indexed by (x, y)
            ch = {}
            none = 0.0
            for pr, xs in runs(M):
                none += pr * (L - len(xs)) / L
                for x in xs:
                    tot[2] += prob * pr / L * kl(P[x], M[x])
                    for y in (0, 1):
                        py = P[x] if y else 1 - P[x]
                        if py > 0:
                            ch[(x, y)] = ch.get((x, y), 0.0) + pr / L * py
            if none > 0:
                rec(t + 1, lik, prob * none)
            for (x, y), pc in ch.items():
                nl = [li * (h[x] if y else 1 - h[x]) for li, h in zip(lik, H)]
                rec(t + 1, nl, prob * pc)
        else:
            # every call of the rehearsal run is put to the human
            for pr, xs in runs(M):
                def ans(i, nl, pa):
                    if i == len(xs):
                        rec(t + 1, nl, prob * pr * pa)
                        return
                    x = xs[i]
                    for y in (0, 1):
                        py = P[x] if y else 1 - P[x]
                        if py > 0:
                            ans(i + 1, [li * (h[x] if y else 1 - h[x]) for li, h in zip(nl, H)], pa * py)
                ans(0, lik, 1.0)
    rec(1, [1.0] * len(H), 1.0)
    return tot

if __name__ == "__main__":
    print("== R1, stochastic human, one question per run ==")
    P = (0.5, 0.9, 0.2, 0.7)
    H = [P, (0.1, 0.9, 0.2, 0.7), (0.5, 0.5, 0.5, 0.5), (0.9, 0.1, 0.8, 0.3), (0.5, 0.9, 0.8, 0.1)]
    w = [0.05, 0.30, 0.30, 0.20, 0.15]
    for n in (1, 2, 4, 6):
        a, b, c = protocol(H, w, P, n)
        bound = L * math.log(1 / w[0])
        print(f"n={n}: sum_t E Lambda = {a:.4f} <= L ln(1/w(P)) = {bound:.4f};"
              f"  sum_t E[a_t kappa_t] = {c:.4f} <= {bound / L:.4f};"
              f"  avg E beta = {b / n:.4f} <= L sqrt(ln(1/w)/(2n)) = {L * math.sqrt(math.log(1 / w[0]) / (2 * n)):.4f}")
    print("== R1/R2, deterministic human, one question per run ==")
    f = (1, 0, 0, 1)
    H = [f, (0, 0, 0, 1), (1, 1, 0, 1), (1, 0, 1, 0), (0.5, 0.5, 0.5, 0.5), (0, 1, 1, 0)]
    w = [0.02, 0.28, 0.2, 0.2, 0.1, 0.2]
    for n in (1, 2, 4, 6):
        a, b, c = protocol(H, w, f, n)
        bound = L * math.log(1 / w[0])
        print(f"n={n}: sum_t E Lambda = {a:.4f}, sum_t E beta = {b:.4f} <= {bound:.4f};"
              f"  sum_t E[a_t kappa_t] = {c:.4f} <= {bound / L:.4f}")
    print("== every call asked (frozen mixture): no gain in the worst case ==")
    # two hypotheses that differ everywhere: one answer already identifies f
    f = (1, 1, 1, 1); g = (0, 0, 0, 0)
    for wf in (0.5, 0.1, 0.01):
        a1, _, _ = protocol([f, g], [wf, 1 - wf], f, 3, ask_all=False)
        aL, _, _ = protocol([f, g], [wf, 1 - wf], f, 3, ask_all=True)
        lam1 = Lam(mixture([wf, 1 - wf], [1, 1], [f, g])[0], f)
        ET = 2 - (1 - wf) / 2     # expected run length under the prior mixture (STOP after z=1, y_1=0)
        print(f"w(f)={wf}: Lambda(M^(1)) = {lam1:.4f} = E[T] ln(1/w(f)) = {ET * math.log(1 / wf):.4f};"
              f" sum over 3 rounds, one question per run: {a1:.4f}; all calls asked: {aL:.4f}; ln(1/w(f)) = {math.log(1 / wf):.4f}")
    print("== Section 12 of the candidate theory: the counterexample ==")
    for eps in (0.1, 0.01, 0.001):
        joint = math.log(1 / eps)                 # KL(delta_b x Bern(1/2) || R)
        r2 = (1 - eps) * 0.01 + eps * 0.5         # second marginal of R: Bernoulli(r2)
        marg = math.log(1 / eps) + kl(0.5, r2)    # KL(P1||R1) + KL(P2||R2)
        print(f"eps={eps}: joint KL = {joint:.4f} < sum of marginal KLs = {marg:.4f}")

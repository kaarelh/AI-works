#!/usr/bin/env python3
"""Section 10 of rehearsal-core.md (the online form), checked by exact enumeration on the
tiny scaffold of rehearsal-core_r1_exact.py.

Scaffold (L = 2, variable length): z uniform on {0,1}; call 1 at x = z;
if z = 0: call 2 at x = 2 + y_1;  if z = 1: STOP if y_1 = 0, else call 2 at x = 3.
Answers are bits.  A kernel is a tuple p with p[x] = probability of answer 1 at x.

Variant "online":  every call is put to the human with probability q; then the human's
                   answer is used in the run and the mixture is updated at once.
Variant "shadow":  the run is driven by the mixture frozen at its start; every call is put
                   to the human with probability q; the answers are only recorded and the
                   mixture is updated after the run.
Quantities (r runs):
  S_all    = E sum over all calls of KL(P || current mixture)(x)      (online only)
  S_frozen = sum_i E Lambda(M_i),  M_i the mixture at the start of run i
  S_wrong  = E number of calls not put to the human whose answer differs from f (online, f a function)
  N_q      = E number of questions
"""
import math

L = 2
X = range(4)


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
    return [sum(pi * h[x] for pi, h in zip(post, H)) for x in X]


def runs(M):
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
            out.append((p1, [z, x2]))
    return out


def Lam(M, P):
    return sum(pr * sum(kl(P[x], M[x]) for x in xs) for pr, xs in runs(M))


def next_input(z, ys):
    """Input of call len(ys)+1, or None for STOP."""
    j = len(ys) + 1
    if j == 1:
        return z
    if j == 2:
        if z == 0:
            return 2 + ys[0]
        return None if ys[0] == 0 else 3
    return None


def experiment(H, w, P, r, q, variant, det=False):
    tot = {"all": 0.0, "frozen": 0.0, "wrong": 0.0, "nq": 0.0}

    def upd(lik, x, y):
        return tuple(li * (h[x] if y else 1 - h[x]) for li, h in zip(lik, H))

    def run_rec(i, lik, prob):
        if i > r or prob == 0:
            return
        M0 = mixture(w, lik, H)
        tot["frozen"] += prob * Lam(M0, P)

        def call(z, ys, cur, pending, pr):
            # cur: likelihoods that define the answering mixture; pending: likelihoods incl. recorded answers
            x = next_input(z, ys)
            if x is None:
                run_rec(i + 1, pending, pr)
                return
            M = mixture(w, cur, H)
            if variant == "online":
                tot["all"] += pr * kl(P[x], M[x])
            # put to the human
            if q > 0:
                tot["nq"] += pr * q
                for y in (0, 1):
                    py = P[x] if y else 1 - P[x]
                    if py == 0:
                        continue
                    if variant == "online":
                        nl = upd(cur, x, y)
                        call(z, ys + [y], nl, nl, pr * q * py)
                    else:
                        # shadow: the run continues with the frozen mixture's own answer
                        for ym in (0, 1):
                            pm = M[x] if ym else 1 - M[x]
                            if pm > 0:
                                call(z, ys + [ym], cur, upd(pending, x, y), pr * q * py * pm)
            # not put to the human
            if q < 1:
                for ym in (0, 1):
                    pm = M[x] if ym else 1 - M[x]
                    if pm == 0:
                        continue
                    if det and variant == "online" and ym != P[x]:
                        tot["wrong"] += pr * (1 - q) * pm
                    call(z, ys + [ym], cur, pending, pr * (1 - q) * pm)

        for z in (0, 1):
            call(z, [], lik, lik, prob * 0.5)

    run_rec(1, tuple([1.0] * len(H)), 1.0)
    return tot


if __name__ == "__main__":
    q = 1.0 / L
    fac = 1.0 / (q * (1 - q) ** (L - 1))
    print(f"L = {L}, q = 1/L = {q}:  1/q = {1 / q},  1/(q (1-q)^(L-1)) = {fac}")
    print("== stochastic human ==")
    P = (0.5, 0.9, 0.2, 0.7)
    H = [P, (0.1, 0.9, 0.2, 0.7), (0.5, 0.5, 0.5, 0.5), (0.9, 0.1, 0.8, 0.3), (0.5, 0.9, 0.8, 0.1)]
    w = [0.05, 0.30, 0.30, 0.20, 0.15]
    lw = math.log(1 / w[0])
    for r in (1, 2, 3):
        o = experiment(H, w, P, r, q, "online")
        s = experiment(H, w, P, r, q, "shadow")
        print(f"r={r}: online: S_all = {o['all']:.4f} <= ln(1/w)/q = {lw / q:.4f};  "
              f"S_frozen = {o['frozen']:.4f} <= ln(1/w)/(q(1-q)^(L-1)) = {lw * fac:.4f};  N_q = {o['nq']:.3f} <= r;  "
              f"shadow: S_frozen = {s['frozen']:.4f} <= {lw * fac:.4f}")
    print("== deterministic human ==")
    f = (1, 0, 0, 1)
    H = [f, (0, 0, 0, 1), (1, 1, 0, 1), (1, 0, 1, 0), (0.5, 0.5, 0.5, 0.5), (0, 1, 1, 0)]
    w = [0.02, 0.28, 0.2, 0.2, 0.1, 0.2]
    lw = math.log(1 / w[0])
    for r in (1, 2, 3):
        o = experiment(H, w, f, r, q, "online", det=True)
        s = experiment(H, w, f, r, q, "shadow", det=True)
        print(f"r={r}: online: S_all = {o['all']:.4f} <= {lw / q:.4f};  S_wrong = {o['wrong']:.4f} <= (1-q) ln(1/w)/q = {(1 - q) * lw / q:.4f};  "
              f"S_frozen = {o['frozen']:.4f} <= {lw * fac:.4f};  shadow: S_frozen = {s['frozen']:.4f} <= {lw * fac:.4f}")
    print("== two hypotheses that differ everywhere (f = 1, g = 0): the loss against Protocol R is real ==")
    f = (1, 1, 1, 1); g = (0, 0, 0, 0)
    for wf in (0.5, 0.1, 0.01):
        lw = math.log(1 / wf)
        o = experiment([f, g], [wf, 1 - wf], f, 6, q, "online", det=True)
        s = experiment([f, g], [wf, 1 - wf], f, 6, q, "shadow", det=True)
        print(f"w(f)={wf}: sum over 6 runs of E Lambda(M_i): online {o['frozen']:.4f}, shadow {s['frozen']:.4f};  "
              f"Protocol R (one uniformly placed question): at most L ln(1/w) = {L * lw:.4f};  bound of 10.3: {lw * fac:.4f}")
    print("== the same class on a scaffold with exactly L calls at distinct inputs: closed form ==")
    for Lc in (2, 5, 20, 100):
        qq = 1.0 / Lc
        print(f"L={Lc}: sum_i E Lambda(M_i) / (L ln(1/w)) = 1/(1-(1-1/L)^L) = {1 / (1 - (1 - qq) ** Lc):.4f};  "
              f"proved factor (1-1/L)^-(L-1) = {(1 - qq) ** (-(Lc - 1)):.4f}")

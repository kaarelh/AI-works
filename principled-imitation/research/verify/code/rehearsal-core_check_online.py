#!/usr/bin/env python3
"""Referee's exact check of Section 10 (the online form) of research/prove-c/rehearsal-core.md,
written independently of the prover's script.  No sampling.

The online form is enumerated exactly (every coin, every answer of the human, every draw of the mixture)
for r successive runs of the scaffold of rehearsal-core_check_r1.py (horizon 3; runs of length 0 to 3;
inputs that depend on the answers; a repeated input; semimeasures; W < 1), for several q.
Checked:
  10.1  S_all := sum over all steps of E KL(P || current mixture)(x) <= ln(W/w(P))/q;
        deterministic human: E[number of unasked wrong answers] <= (1-q) ln(W/w(f))/q;
        E[number of questions] = q * E[number of steps];
  10.2  with q = 1/L: E[number of questions] <= r;
  10.3  S_frozen := sum_i E Lambda(M_i) <= ln(W/w(P)) / (q (1-q)^(L-1)), for the online form and for the
        variant with shadow questions;  and the geometric series of the example of Theorem 5.1(d).
"""
import importlib.util
import os
from math import log

here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("r1", os.path.join(here, "rehearsal-core_check_r1.py"))
r1 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(r1)
L, D0, YB, BOT = r1.L, r1.D0, r1.YB, r1.BOT


def online(hyps, weights, P, r, q, shadow, deterministic):
    cache = {}

    def info(data):
        key = tuple(sorted(data))
        if key not in cache:
            post, M = r1.mixture(hyps, weights, key)
            rs = r1.runs_of(M)
            Lam = sum(pr * sum(r1.kl(P[x], M[x]) for x in xs) for pr, z, xs, ys in rs)
            cache[key] = (M, Lam)
        return cache[key]

    tot = dict(all=0.0, frozen=0.0, questions=0.0, steps=0.0, wrong=0.0)

    def run(i, data, pr):
        if i == r:
            return
        M0, Lam0 = info(data)
        tot['frozen'] += pr * Lam0
        for z, pz in D0.items():
            call(i, z, (), data, data, pr * pz)

    def call(i, z, ys, data, pending, pr):
        """data = data that defines the current mixture; pending = data to be used from the next run on
        (equal to data in the online form; in the shadow variant the answers are added only after the run)."""
        x = r1.next_input(z, ys)
        if x is None:
            run(i + 1, pending, pr)
            return
        M, _ = info(data)
        tot['steps'] += pr
        tot['all'] += pr * r1.kl(P[x], M[x])
        # coin = 1: the human is asked
        if q > 0:
            tot['questions'] += pr * q
            for y in (0, 1):
                py = P[x][y]
                if py > 0:
                    if shadow:
                        # the run is answered by the frozen mixture; the human's answer is only recorded
                        for ym in YB:
                            pm = M[x][ym]
                            if pm > 0:
                                call(i, z, ys + (ym,), data, pending + ((x, y),), pr * q * py * pm)
                    else:
                        nd = data + ((x, y),)
                        call(i, z, ys + (y,), nd, nd, pr * q * py)
        # coin = 0: the mixture answers
        if q < 1:
            for ym in YB:
                pm = M[x][ym]
                if pm > 0:
                    if deterministic and P[x][ym] < 1:
                        tot['wrong'] += pr * (1 - q) * pm
                    call(i, z, ys + (ym,), data, pending, pr * (1 - q) * pm)

    run(0, (), 1.0)
    return tot


def main():
    ok = True
    hy_s = [r1.completed(h) for h in (
        {0: (0.3, 0.7), 1: (0.6, 0.4), 2: (0.1, 0.9), 3: (0.5, 0.5)},
        {0: (0.3, 0.6), 1: (0.5, 0.4), 2: (0.1, 0.8), 3: (0.2, 0.2)},
        {0: (0.9, 0.1), 1: (0.6, 0.4), 2: (0.5, 0.5), 3: (0.5, 0.5)},
        {0: (0.3, 0.7), 1: (0.6, 0.4), 2: (0.9, 0.1), 3: (0.0, 1.0)},
    )]
    w_s = [0.02, 0.5, 0.2, 0.18]
    hy_d = [r1.completed(h) for h in (
        {0: (0.0, 1.0), 1: (0.0, 1.0), 2: (1.0, 0.0), 3: (0.0, 1.0)},
        {0: (0.0, 1.0), 1: (1.0, 0.0), 2: (1.0, 0.0), 3: (1.0, 0.0)},
        {0: (0.5, 0.5), 1: (0.0, 1.0), 2: (0.5, 0.4), 3: (0.0, 1.0)},
        {0: (1.0, 0.0), 1: (0.0, 1.0), 2: (1.0, 0.0), 3: (0.0, 1.0)},
    )]
    w_d = [0.01, 0.4, 0.3, 0.25]
    for title, hy, w, det in (("stochastic human, semimeasures, W = 0.9", hy_s, w_s, False),
                              ("deterministic human, W = 0.96", hy_d, w_d, True)):
        C = log(sum(w) / w[0])
        for q, r in ((1 / 3, 2), (1 / 3, 3), (0.5, 2), (0.9, 2), (1.0, 2)):
            if True:
                on = online(hy, w, hy[0], r, q, False, det)
                sh = online(hy, w, hy[0], r, q, True, det)
                b1 = C / q
                b3 = C / (q * (1 - q) ** (L - 1)) if q < 1 else float('inf')
                good = on['all'] <= b1 + 1e-12 and on['frozen'] <= b3 + 1e-12 and sh['frozen'] <= b3 + 1e-12
                good &= abs(on['questions'] - q * on['steps']) < 1e-12
                if abs(q - 1 / L) < 1e-12:
                    good &= on['questions'] <= r + 1e-12
                if det:
                    good &= on['wrong'] <= (1 - q) * C / q + 1e-12
                ok &= good
                extra = f"; unasked wrong answers = {on['wrong']:.4f} <= (1-q) ln(W/w)/q = {(1 - q) * C / q:.4f}" if det else ""
                print(f"{title}; q = {q:.3f}, r = {r}: S_all = {on['all']:.4f} <= {b1:.4f}; S_frozen online = {on['frozen']:.4f}, shadow = {sh['frozen']:.4f} <= {b3:.4f}; "
                      f"E questions = {on['questions']:.4f} = q E steps = {q * on['steps']:.4f}{extra}  {'OK' if good else 'FAIL'}")
    print("example of Theorem 5.1(d) in the online form: sum_i E Lambda(M_i) = L ln(1/w) sum_i (1-q)^(L(i-1)) -> L ln(1/w)/(1 - (1-q)^L);")
    for Lc in (2, 3, 10, 100):
        qq = 1 / Lc
        print(f"   L = {Lc}, q = 1/L: factor 1/(1 - (1-q)^L) = {1 / (1 - (1 - qq) ** Lc):.4f}; proved upper factor (1-q)^-(L-1) = {(1 - qq) ** (-(Lc - 1)):.4f}")
    print()
    print("ALL CHECKS PASSED" if ok else "SOME CHECK FAILED")


if __name__ == "__main__":
    main()

"""Referee checks for experiment E1 (hidden insights) and Theorem 3.

1. Regenerate the humans of hidden_insights.py from its seeds and replay the problem
   sequence of CS and MB. Check that MB's task queries equal the number of insights
   found (= triggered problems - 2 at the stopping time), that CS's task queries equal
   sum over found problems of (t_p + 1), and that the checks equal runs + found*log2(n).
   Also report the check count under the protocol as written in the note (Protocol MB
   step 3 reruns the problem and checks it again: one more check per failure).
2. Exact Bayesian check of the decoder in the class (class prior, small n and q): at every
   unprobed step (p, j, bottom) the majority label is the "no insight" continuation, and
   the predictive probability of an insight is (eta/n)/(1 - eta|S|/n) in [eta/n, 2eta/n].
3. Theorem 3's bound against the task-only protocols of E1 (CI and US-low) and a Monte
   Carlo check of the bound at eta = 8 eps, q = 2 with the best "scan" protocol.

Usage: python3 referee_e1_checks.py  (writes referee_e1_checks.out next to this file)
"""

import itertools
import json
import math
import os
import sys
from fractions import Fraction

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(HERE, "..", "results")


def sample_truth(rng, m, n, eta):  # copied from hidden_insights.py
    triggered = rng.random(m) < eta
    return np.where(triggered, rng.integers(0, n, size=m), n)


def part1(out):
    s = json.load(open(os.path.join(RES, "hidden_insights_summary.json")))
    m, eta, eps = 100, 0.5, 0.02
    out.append("## 1. Replay of CS and MB in E1\n")
    out.append("| n | mean triggered | mean found | MB task (saved) | sum(t_p+1)/found | "
               "(n+1)/2 | CS task (replay / saved) | MB checks (replay / saved) | "
               "MB checks incl. rerun check |")
    out.append("|---|---|---|---|---|---|---|---|---|")
    for n in [16, 64, 256, 1024]:
        trig, found_l, cs_l, mbc_l, mbc_fix, runs_l, per_ins = [], [], [], [], [], [], []
        for seed in range(10):
            rng = np.random.default_rng(1000 * n + seed)
            t = sample_truth(rng, m, n, eta)
            rng2 = np.random.default_rng(10**6 + 1000 * n + seed)
            triggered = t < n
            unfound = int(triggered.sum())
            found = np.zeros(m, bool)
            cs = 0
            nf = 0
            r = 0
            while unfound / m > eps and r < 200 * m:
                r += 1
                p = int(rng2.integers(m))
                if triggered[p] and not found[p]:
                    found[p] = True
                    unfound -= 1
                    nf += 1
                    cs += int(t[p]) + 1
            trig.append(int(triggered.sum()))
            found_l.append(nf)
            cs_l.append(cs)
            runs_l.append(r)
            mbc_l.append(r + nf * int(math.log2(n)))
            mbc_fix.append(r + nf * (1 + int(math.log2(n))))
            per_ins.append(cs / nf)
        out.append(
            f"| {n} | {np.mean(trig):.1f} | {np.mean(found_l):.1f} | {s[f'MB_n{n}']['task_mean']:.1f} | "
            f"{np.sum(cs_l)/np.sum(found_l):.1f} | {(n+1)/2:.1f} | {np.mean(cs_l):.1f} / {s[f'CS_n{n}']['task_mean']:.1f} | "
            f"{np.mean(mbc_l):.1f} / {s[f'MB_n{n}']['checks_mean']:.1f} | {np.mean(mbc_fix):.1f} |")
        assert abs(np.mean(found_l) - s[f"MB_n{n}"]["task_mean"]) < 1e-9
        assert abs(np.mean(cs_l) - s[f"CS_n{n}"]["task_mean"]) < 1e-9
        assert abs(np.mean(mbc_l) - s[f"MB_n{n}"]["checks_mean"]) < 1e-9
        assert all(f == tr - 2 for f, tr in zip(found_l, trig)), "found != triggered - 2"
    out.append("\nAll replays match the saved summary exactly; in every run MB's task queries "
               "equal triggered - 2 (the stopping rule is 'at most 2 of 100 problems unfound').\n")


def part2(out):
    out.append("## 2. Exact posterior in the hidden-insight class (class prior)\n")
    eta = Fraction(1, 2)
    worst = Fraction(0)
    for n in [2, 3, 4, 6, 8]:
        for q in [2, 3]:
            # posterior over (t, k) for one problem given a set S of missed probes
            for size in range(n):
                for S in itertools.combinations(range(n), size):
                    S = set(S)
                    w = {("inf", None): 1 - eta}
                    for t in range(n):
                        if t in S:
                            continue
                        for k in range(1, q + 1):
                            w[(t, k)] = eta / (n * q)
                    Z = sum(w.values())
                    for j in range(n):
                        if j in S:
                            continue
                        # label distribution of P(p, j, bottom)
                        lab = {}
                        for (t, k), v in w.items():
                            y = ("ins", k) if t == j else "bot"
                            lab[y] = lab.get(y, 0) + v / Z
                        hit = 1 - lab["bot"]
                        formula = (eta / n) / (1 - eta * len(S) / n)
                        assert hit == formula
                        assert eta / n <= hit < 2 * eta / n or (n == 2 and hit <= 2 * eta / n)
                        top = max(lab, key=lambda y: (lab[y], y == "bot"))
                        if top != "bot":
                            out.append(f"  majority is an insight at n={n}, q={q}, S={S}, j={j}")
                        worst = max(worst, hit)
    out.append("For n in {2,3,4,6,8}, q in {2,3}, eta = 1/2 and every set S of missed probes: "
               "the predictive insight probability equals (eta/n)/(1-eta|S|/n) exactly, lies in "
               "[eta/n, 2eta/n), and the majority label is always 'no insight'. So the majority "
               "decoder's run ends at (p, n, bottom) until the insight is found, and the failure "
               "of the decoder is exactly (#triggered unfound)/m, as the code computes.\n")


def part3(out):
    s = json.load(open(os.path.join(RES, "hidden_insights_summary.json")))
    m, eta, eps = 100, 0.5, 0.02
    out.append("## 3. Theorem 3 against E1, and a Monte Carlo check of the bound\n")
    out.append("Theorem 3 with q -> infinity: failure >= eta (1 - 2Q/(nm)), so failure <= 0.02 "
               "needs Q >= (nm/2)(1 - 0.02/eta) = 0.48 nm task queries (on average over the prior; "
               "E1 uses 10 fixed humans, so this is only a sanity check).\n")
    out.append("| n | lower bound 0.48nm | CI task | US(eta/2n) task | CI / bound | US / bound |")
    out.append("|---|---|---|---|---|---|")
    for n in [16, 64, 256, 1024]:
        lb = 0.48 * n * m
        ci = s[f"CI_n{n}"]["task_mean"]
        us = s[f"US_n{n}"]["task_mean"]
        out.append(f"| {n} | {lb:,.0f} | {ci:,.0f} | {us:,.0f} | {ci/lb:.2f} | {us/lb:.2f} |")
    out.append("\nCI's mean is close to the coupon-collector estimate m n (H_50 - H_2) = 3.0 m n; "
               "the low-threshold uncertainty sampler (the 'cheating' scan) is about 4x cheaper "
               "than CI at every n and within a factor 1.6 of the lower bound.\n")

    # Monte Carlo: eta = 8 eps, q = 2; protocol scans unprobed steps problem by problem
    rng = np.random.default_rng(12345)
    epsv, q = 1 / 32, 2
    eta = 8 * epsv
    rows = []
    for n, mm in [(8, 40), (32, 20)]:
        for frac in [0.05, 0.125, 0.25, 0.5]:
            Q = int(frac * n * mm)
            fails = []
            for rep in range(20000):
                trig = rng.random(mm) < eta
                t = np.where(trig, rng.integers(0, n, size=mm), n)
                found = np.zeros(mm, bool)
                budget = Q
                for p in range(mm):  # scan problem p from step 0 upwards
                    if budget == 0:
                        break
                    steps = min(budget, n)
                    budget -= steps if not (t[p] < steps) else (t[p] + 1)
                    if t[p] < steps:
                        found[p] = True
                # fresh problem: decoder fails if triggered and unfound, guess k right w.p. 1/q
                p = rng.integers(mm)
                fail = (t[p] < n) and (not found[p]) and (rng.random() > 1 / q)
                fails.append(fail)
            bound = (1 - 1 / q) * eta * (1 - 2 * Q / (n * mm))
            rows.append((n, mm, Q, np.mean(fails), bound))
    out.append(f"Monte Carlo (eta = 8 eps = 1/4, q = 2, 20000 draws of theta each), best-effort "
               f"scanning protocol with Q task queries:\n")
    out.append("| n | m | Q | Q/(nm) | simulated failure | Theorem 3 lower bound |")
    out.append("|---|---|---|---|---|---|")
    for n, mm, Q, f, b in rows:
        out.append(f"| {n} | {mm} | {Q} | {Q/(n*mm):.3f} | {f:.4f} | {max(b,0):.4f} |")
        assert f >= b - 0.01, "bound violated beyond MC error"
    out.append("\nThe simulated failure is at or above the bound in every case, within Monte Carlo "
               "error (standard error about 0.002). The bound is not tight for large Q: it "
               "reaches 0 at Q = nm/2, while scanning needs about Q = nm(1 - eta/2) to find every "
               "insight.\n")


def main():
    out = []
    part1(out)
    part2(out)
    part3(out)
    text = "\n".join(out)
    print(text)
    with open(os.path.join(HERE, "referee_e1_checks.out"), "w") as f:
        f.write(text + "\n")


if __name__ == "__main__":
    main()

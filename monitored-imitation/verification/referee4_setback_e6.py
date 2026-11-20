"""Referee 4: does E6's human class have the setbacks slack-imitation.md Section 6 claims?

Claim checked (Section 6, "Setbacks"): in the time-indexed sense of Remark 4, the noticing kind
has setback <= 0 at every mistake and misled-D has setback <= D, while silent humans have
unbounded setback at a missed idea and fooled humans at a wrong value.

Remaining time with a visible step: tau(a, u, j) = least m >= 0 such that the human's own steps
from draft (a, u) at step j reach S = [a == k_p and u >= n0 - t_p - 1] after m steps (inf if
never). The setback of an imitator output c at (a, u, j) is tau(next, j + 1) - tau(a, u, j).
(B-omit) asks setback <= 0 when c writes a strict part of the human's step (here: c = NOTHING
while the human writes something); (B-commit) asks setback <= D otherwise.

Part 0. The scalar human used here agrees with Problem.outputs of code/slack_imitation.py.
Part 1. Human alone: every draft (a, u, j), every output c != the human's. Reports the largest
        setback per kind and case, i.e. whether the human-alone version of (B_D) holds.
Part 2. Reachable runs: the protocols of E6 (SI, LAST, MIX, CI without slack) are replayed
        with the code's own Problem class, and every run any problem takes during learning is
        checked: setback at every mistake, Lemma S (|M| >= (sigma+1)/(D+1) on failed runs),
        overwrites of a correct value, and runs that reach S and then lose it.

Usage: python3 referee4_setback_e6.py
"""

import os
import sys
from collections import defaultdict

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(os.path.dirname(HERE), "code"))
import slack_imitation as si  # noqa: E402

import numpy as np  # noqa: E402

NOTHING, SET1, SET2, INC = si.NOTHING, si.SET1, si.SET2, si.INC
NAMES = {NOTHING: "NOTHING", SET1: "SET1", SET2: "SET2", INC: "INC"}
INF = float("inf")


def human(kind, j, a, u, tp, kp):
    persistent, D = si.KINDS[kind]
    if a == 0:
        avail = (j >= tp) if persistent else (j == tp)
        return kp if avail else NOTHING
    if kp == a:
        return INC
    return kp if (j >= tp and u >= D) else INC


def step(a, u, c):
    if c == INC:
        return a, u + 1
    if c in (SET1, SET2):
        return c, 0
    return a, u


def tau(kind, a, u, j, tp, kp, n0, n):
    target = n0 - tp - 1
    cap = 6 * n + 50
    for m in range(cap):
        if a == kp and u >= target:
            return m
        a, u = step(a, u, human(kind, j, a, u, tp, kp))
        j += 1
    return INF


def label(a, h, c, kp):
    """A readable name for the case."""
    if a == 0:
        cur = "empty"
    elif a == kp:
        cur = "on own value"
    else:
        cur = "on wrong value"
    return f"{cur}: human {NAMES[h]}, imitator {NAMES[c]}" + (
        " (= own value)" if c == kp else (" (wrong value)" if c in (SET1, SET2) else ""))


def part0():
    bad = 0
    for kind in si.KINDS:
        persistent, D = si.KINDS[kind]
        for n0 in (4, 8):
            n = 2 * n0
            pr = si.Problem(n, n0, persistent, D)
            for tp in range(n0):
                for kp in (1, 2):
                    for a in (0, 1, 2):
                        for u in range(n + 1):
                            for j in range(n):
                                ref = int(pr.outputs(j, a, u, np.array([tp]), np.array([kp]))[0])
                                if ref != human(kind, j, a, u, tp, kp):
                                    bad += 1
    print(f"Part 0: scalar human vs Problem.outputs, disagreements: {bad}")


def part1():
    print("\nPart 1: human alone, all drafts (a, u, j) and all imitator outputs c != human's.")
    for n0 in (4, 8):
        n = 2 * n0
        print(f"  n0 = {n0}, n = {n}")
        for kind in si.KINDS:
            D = si.KINDS[kind][1]
            worst = defaultdict(lambda: -INF)
            for tp in range(n0):
                for kp in (1, 2):
                    for a in (0, 1, 2):
                        for u in range(n + 1):
                            for j in range(n):
                                h = human(kind, j, a, u, tp, kp)
                                t0 = tau(kind, a, u, j, tp, kp, n0, n)
                                if t0 == INF:
                                    continue
                                for c in (NOTHING, SET1, SET2, INC):
                                    if c == h:
                                        continue
                                    a2, u2 = step(a, u, c)
                                    if (a2, u2) == step(a, u, h):
                                        continue  # same notebook as the human's step
                                    t1 = tau(kind, a2, u2, j + 1, tp, kp, n0, n)
                                    s = t1 - t0
                                    key = label(a, h, c, kp)
                                    worst[key] = max(worst[key], s)
            bound_c = "inf" if D >= si.INF else str(D)
            viol = {k: v for k, v in worst.items()
                    if (("imitator NOTHING" in k and v > 0) or
                        ("imitator NOTHING" not in k and v > (INF if D >= si.INF else D)))}
            print(f"    {kind:9s} (claimed: omissions <= 0, commissions <= {bound_c}); "
                  f"cases violating the human-alone bound: {len(viol)}")
            for k, v in sorted(viol.items()):
                print(f"        {k}: largest setback {v}")


def instrumented(kind, n, sigma, proto, seed, cap, stats):
    """one_human of slack_imitation.py, with every new run checked."""
    persistent, D = si.KINDS[kind]
    n0 = n - sigma
    rng = np.random.default_rng(seed)
    tp = rng.integers(0, n0, size=si.M)
    kp = np.where(rng.random(si.M) < si.PI, 1, 2)
    probs = [si.Problem(n, n0, persistent, D) for _ in range(si.M)]
    need = (sigma + 1) / (D + 1) if D < si.INF else None

    def check(p):
        pr = probs[p]
        t, k = int(tp[p]), int(kp[p])
        taus = [tau(kind, a, u, j, t, k, n0, n) for j, (a, u) in enumerate(pr.run)]
        if taus[0] != n0:
            stats["tau0 != n0"] += 1
        mistakes = 0
        for j in range(n):
            a, u = pr.run[j]
            h = human(kind, j, a, u, t, k)
            c = pr.codes[j]
            if c == h:
                continue
            mistakes += 1
            omission = (c == NOTHING)
            if a == k and c in (SET1, SET2):
                stats["overwrites of a correct value"] += 1
            if taus[j] == INF:
                stats["mistakes at tau = inf"] += 1
                continue
            s = taus[j + 1] - taus[j]
            key = ("omission" if omission else "commission")
            stats[f"max setback, {key}"] = max(stats.get(f"max setback, {key}", -INF), s)
            bound = 0 if omission else (INF if D >= si.INF else D)
            if s > bound:
                stats[f"violations, {key}"] += 1
                stats.setdefault("examples", []).append(
                    (kind, n, seed, p, j, label(a, h, c, k), s))
        ok_k = [(a == k and u >= n0 - t - 1) for (a, u) in pr.run]
        if any(ok_k) and not ok_k[-1]:
            stats["runs that reach S and lose it"] += 1
        stats["runs checked"] += 1
        if not ok_k[-1]:
            stats["failed runs checked"] += 1
            if need is not None and mistakes < need:
                stats["Lemma S violations"] += 1
            if mistakes == 1:
                stats["failed runs with one mistake"] += 1

    for p in range(si.M):
        check(p)
    ok = np.array([probs[p].success(tp[p], kp[p]) for p in range(si.M)])
    rng2 = np.random.default_rng(seed + 10**8)
    for r in range(cap):
        if (si.M - ok.sum()) / si.M <= si.EPS:
            break
        p = int(rng2.integers(si.M))
        j = si.pick_step(proto, n, rng2)
        before = list(probs[p].run)
        probs[p].query(j, tp[p], kp[p])
        if probs[p].run != before:
            check(p)
        ok[p] = probs[p].success(tp[p], kp[p])


def part2():
    print("\nPart 2: every run met while the E6 protocols learn (code's own Problem class).")
    for n in (8, 16, 32):
        for kind in si.KINDS:
            for sigma, proto in [(n // 2, "CI"), (n // 2, "MIX"), (n // 2, "LAST"), (0, "CI")]:
                if kind == "silent" and n == 32 and sigma == 0:
                    continue  # slow and uninformative (silent humans have no setback bound)
                stats = defaultdict(int)
                H = 10 if n < 32 else 5
                cap = 400 * si.M if proto == "LAST" else 40 * si.M * n
                for s in range(H):
                    instrumented(kind, n, sigma, proto, 1000 * n + s, cap, stats)
                ex = stats.pop("examples", [])
                keys = sorted(k for k in stats)
                print(f"  n={n:3d} sigma={sigma:3d} {proto:4s} {kind:9s}: " +
                      ", ".join(f"{k} {stats[k]}" for k in keys))
                for e in ex[:2]:
                    print(f"      example: {e}")


if __name__ == "__main__":
    parts = sys.argv[1:] or ["0", "1", "2"]
    if "0" in parts:
        part0()
    if "1" in parts:
        part1()
    if "2" in parts:
        part2()

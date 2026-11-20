"""Thread A, experiment E5: what drops do to monitored bisection, and what excuse lists fix.

The class is the hidden-insight class of note.md Section 3 with three independent
insights per problem and one generic, acknowledged "issue note":

  insight i in {1, 2, 3} of problem p is present with probability eta_i, at a step
  t_i uniform on {0, ..., n-1}; the (silent) human writes it at step t_i if the state
  lacks it, and otherwise carries on;
  the note: one step after insight 1 is in the state, the human writes a persistent
  note "having insight 1, I now see that the earlier approach had a flaw" (e = 1).
  The note rule is generic (prior mass 1), so every decoder gets it right.

Insights 1 and 2 are visible to the check (the human can tell a state lacks them by
now, as in note.md's Section 5.2 example); insight 3 is a discovery the check cannot
see. Two checks:

  V_strict = ok_1 and ok_2 and (no note): counts the acknowledged flaw as a defect, so
             the human's own runs drop at the step that writes the note;
  V_ack    = ok_1 and ok_2: acknowledged problems are not defects; preserved.

V_strict with the excuse list {note} is V_ack.

Protocols (each arrival is a problem drawn uniformly from the m problems):

  CI      chained imitation: task-query a uniform step of each run;
  RG      review-gated CI: review a uniform step (visible-only endorsement: "the
          visible part of this step is what I'd do"); task-query it only if unendorsed;
  PE      prefix endorsement: review the steps in order until the first unendorsed one
          (or all n), task-query it, rerun;
  MB-P9   MB with V_strict and Proposition 9: the first drop found ends the problem with
          a marked output;
  MBX     MB with V_strict and an excuse list: at a drop, the human names the new defect
          (the note), the list grows, and bisection continues to the right of the drop;
  MB-ack  MB with V_ack;
  MBX+A   MBX, plus a task query at a uniform step of every output run (Prop. 10, beta=1).

The decoder is the exact class-prior majority decoder with q large: it writes an insight
only once a task query has confirmed it (as in code/end_weighted.py), so its state on a
problem is the set of confirmed insights. A task query at a state reveals every insight
whose step is that state's step and which the state lacks. Repeated states are looked up,
not re-queried. After every arrival we compute, exactly over the m problems,
F_vis = Pr[the decoder's final state fails V_ack] (a visible failure the imitator caused)
and F_diff = Pr[the decoder's run differs from the human's].

Usage: python3 threadA_drops.py [OUTFILE.json]
"""

import json
import sys

import numpy as np

ETAS = (0.5, 0.5, 0.2)
M = 100
TARGET = 0.02


class Human:
    def __init__(self, rng, m, n):
        self.m, self.n = m, n
        self.t = np.full((3, m), -1, dtype=int)
        for i, eta in enumerate(ETAS):
            pres = rng.random(m) < eta
            self.t[i, pres] = rng.integers(0, n, pres.sum())


class Learner:
    """Confirmed insights per problem, the set of queried states, and counters."""

    def __init__(self, h):
        self.h = h
        self.known = np.zeros((3, h.m), dtype=bool)
        self.queried = [set() for _ in range(h.m)]
        self.excuse_states = [set() for _ in range(h.m)]
        self.cost = dict(task=0, checks=0, naming=0, reviews=0, marked=0, excused_runs=0)

    # decoder run, computed lazily: state at step k
    def state(self, p, k):
        t, kn = self.h.t[:, p], self.known[:, p]
        a = tuple(bool(kn[i] and t[i] >= 0 and k > t[i]) for i in range(3))
        e = bool(kn[0] and t[0] >= 0 and k >= t[0] + 2)
        return a, e

    def ok(self, p, i, k, ai):
        ti = self.h.t[i, p]
        if ai:
            return ti >= 0 and ti < k
        return ti < 0 or ti >= k

    def v_ack(self, p, k):
        a, e = self.state(p, k)
        return self.ok(p, 0, k, a[0]) and self.ok(p, 1, k, a[1])

    def v_strict(self, p, k):
        a, e = self.state(p, k)
        return self.v_ack(p, k) and not e

    def mistake(self, p, k):
        t, kn = self.h.t[:, p], self.known[:, p]
        return any(t[i] == k and not kn[i] for i in range(3))

    def visible_unendorsed(self, p, k):
        t, kn = self.h.t[:, p], self.known[:, p]
        return any(t[i] == k and not kn[i] for i in range(2))

    def task_query(self, p, k):
        """Ask (or look up) P at the decoder's state at step k; confirm what it shows.
        Returns True if the decoder made a mistake there."""
        key = (k,) + self.state(p, k)
        if key not in self.queried[p]:
            self.cost["task"] += 1
            self.queried[p].add(key)
        mis = self.mistake(p, k)
        t = self.h.t[:, p]
        for i in range(3):
            if t[i] == k:
                self.known[i, p] = True
        return mis

    def bisect(self, p, lo, hi, check):
        """check(lo) = 1, check(hi) = 0; returns j with check(j) = 1, check(j+1) = 0."""
        while hi - lo > 1:
            mid = (lo + hi) // 2
            self.cost["checks"] += 1
            if check(p, mid):
                lo = mid
            else:
                hi = mid
        return lo

    def f_vis(self):
        t, kn = self.h.t, self.known
        bad = ((t[0] >= 0) & ~kn[0]) | ((t[1] >= 0) & ~kn[1])
        return bad.mean()

    def f_diff(self):
        t, kn = self.h.t, self.known
        return (((t >= 0) & ~kn).any(axis=0)).mean()


def arrive(L, p, proto, rng):
    n = L.h.n
    if proto == "CI":
        L.task_query(p, int(rng.integers(n)))
        return
    if proto == "RG":
        k = int(rng.integers(n))
        L.cost["reviews"] += 1
        if L.visible_unendorsed(p, k):
            L.task_query(p, k)
        return
    if proto == "PE":
        while True:
            first = next((k for k in range(n) if L.visible_unendorsed(p, k)), None)
            L.cost["reviews"] += n if first is None else first + 1
            if first is None:
                return
            L.task_query(p, first)  # a mistake: self-endorsement holds exactly
    if proto == "MB-ack":
        while True:
            L.cost["checks"] += 1
            if L.v_ack(p, n):
                return
            j = L.bisect(p, 0, n, L.v_ack)
            assert L.task_query(p, j)  # V_ack is preserved: every flip is a mistake
    if proto in ("MB-P9", "MBX", "MBX+A"):
        while True:  # one pass per run of the current decoder
            excused, a = False, 0
            rerun = False
            while True:
                check = L.v_ack if excused else L.v_strict
                L.cost["checks"] += 1
                if check(p, n):
                    if excused:
                        L.cost["excused_runs"] += 1
                    break
                j = L.bisect(p, a, n, check)
                if L.task_query(p, j):
                    rerun = True
                    break
                # a drop: the decoder did what the human does
                assert not excused  # V_ack is preserved
                if proto == "MB-P9":
                    L.cost["marked"] += 1
                    break
                key = (j,) + L.state(p, j)
                if key not in L.excuse_states[p]:  # naming is deterministic: cached
                    L.excuse_states[p].add(key)
                    L.cost["naming"] += 1  # the human names the note; list = {note}
                excused, a = True, j + 1
                assert L.v_ack(p, a)
            if not rerun:
                break
        if proto == "MBX+A":
            L.task_query(p, int(rng.integers(n)))
        return
    raise ValueError(proto)


PROTOS = ["CI", "RG", "PE", "MB-P9", "MBX", "MB-ack", "MBX+A"]


def run(n, seed, proto, max_arrivals):
    rng_h = np.random.default_rng(1000 * n + seed)
    h = Human(rng_h, M, n)
    L = Learner(h)
    rng = np.random.default_rng(10**6 + 1000 * n + seed)
    first = {"vis": None, "diff": None}
    for step in range(1, max_arrivals + 1):
        p = int(rng.integers(M))
        arrive(L, p, proto, rng)
        fv, fd = L.f_vis(), L.f_diff()
        snap = dict(L.cost, arrivals=step)
        if first["vis"] is None and fv <= TARGET:
            first["vis"] = snap
        if first["diff"] is None and fd <= TARGET:
            first["diff"] = snap
            break
    return dict(first_vis=first["vis"], first_diff=first["diff"],
                final=dict(L.cost, arrivals=step, f_vis=float(L.f_vis()),
                           f_diff=float(L.f_diff())))


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else None
    ns = (16, 64, 256)
    humans = 10
    res = {}
    for n in ns:
        for proto in PROTOS:
            cap = 400 * M if proto in ("CI", "RG", "MBX+A") else 40 * M
            rs = [run(n, s, proto, cap) for s in range(humans)]
            res[f"{proto}/n={n}"] = rs

    def mean(xs):
        xs = [x for x in xs if x is not None]
        return float(np.mean(xs)) if xs else float("nan")

    print(f"E5: m={M}, etas={ETAS}, target {TARGET}, {humans} humans per n.")
    print("Columns: first passage F_vis<=2% (task / checks / reviews, humans reaching);")
    print("final F_vis, F_diff, marked outputs, excused runs, task, checks, naming, reviews.\n")
    hdr = (f"{'protocol':8s} {'n':>4s} | {'task@vis':>9s} {'checks@vis':>10s} "
           f"{'reviews@vis':>11s} {'#':>3s} | {'F_vis':>6s} {'F_diff':>6s} "
           f"{'marked':>7s} {'excused':>7s} {'task':>7s} {'checks':>7s} {'naming':>6s} "
           f"{'reviews':>9s} {'arrivals':>8s}")
    print(hdr)
    summary = {}
    for n in ns:
        for proto in PROTOS:
            rs = res[f"{proto}/n={n}"]
            fv = [r["first_vis"] for r in rs]
            reach = sum(x is not None for x in fv)
            row = dict(
                task_at_vis=mean([x["task"] if x else None for x in fv]),
                checks_at_vis=mean([x["checks"] if x else None for x in fv]),
                reviews_at_vis=mean([x["reviews"] if x else None for x in fv]),
                reached_vis=reach,
                f_vis=mean([r["final"]["f_vis"] for r in rs]),
                f_diff=mean([r["final"]["f_diff"] for r in rs]),
                marked=mean([r["final"]["marked"] for r in rs]),
                excused=mean([r["final"]["excused_runs"] for r in rs]),
                task=mean([r["final"]["task"] for r in rs]),
                checks=mean([r["final"]["checks"] for r in rs]),
                naming=mean([r["final"]["naming"] for r in rs]),
                reviews=mean([r["final"]["reviews"] for r in rs]),
                arrivals=mean([r["final"]["arrivals"] for r in rs]),
                reached_diff=sum(r["first_diff"] is not None for r in rs),
                task_at_diff=mean([r["first_diff"]["task"] if r["first_diff"] else None
                                   for r in rs]),
            )
            summary[f"{proto}/n={n}"] = row
            print(f"{proto:8s} {n:4d} | {row['task_at_vis']:9.1f} {row['checks_at_vis']:10.1f} "
                  f"{row['reviews_at_vis']:11.1f} {reach:3d} | {row['f_vis']:6.3f} "
                  f"{row['f_diff']:6.3f} {row['marked']:7.1f} {row['excused']:7.1f} "
                  f"{row['task']:7.1f} {row['checks']:7.1f} {row['naming']:6.1f} "
                  f"{row['reviews']:9.1f} {row['arrivals']:8.0f}")
        print()
    print("Runs stop when F_diff <= 2% or at the cap (40m arrivals; 400m for CI, RG, MBX+A).")
    print("naming = distinct drop states named (cached); excused = runs output with an excuse,")
    print("which is what drops would cost in task queries if no problem ever recurred.")
    print("F_diff reached 2% (humans / mean task queries then):")
    for k, row in summary.items():
        print(f"  {k:14s} {row['reached_diff']:2d}/{humans}  {row['task_at_diff']:.1f}")
    if out:
        with open(out, "w") as f:
            json.dump(dict(summary=summary, etas=ETAS, m=M, target=TARGET), f, indent=1)


if __name__ == "__main__":
    main()

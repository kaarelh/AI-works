"""Referee checks (second note, without-a-check.md): experiment E3.

  1. Re-run E3 in full from the unmodified code into referee2_rerun/ and compare with results/.
  2. Per-human numbers behind the table (original seeds).
  3. Silent humans under LAST: the last step *is* a mistake when t_p = n-1.
  4. 200 fresh humans per setting for the catch-up rows: is CI's 3,370 at n = 1024 a trend or noise?
  5. Coupon-collector prediction for LAST on catch-up humans; ratios quoted in the note.

Usage: python3 referee2_e3_checks.py [--no-rerun]     (about 3 minutes with the re-run)
"""

import json
import os
import subprocess
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
CODE = os.path.join(HERE, "..", "code")
RESULTS = os.path.join(HERE, "..", "results")
sys.path.insert(0, CODE)
import end_weighted as ew  # noqa: E402

m, eta, eps = 100, 0.5, 0.02
NS = [16, 64, 256, 1024]


def human(n, s, base=0):
    rng = np.random.default_rng(base + 1000 * n + s)
    trig = rng.random(m) < eta
    return np.where(trig, rng.integers(0, n, size=m), n)


def run(cls, proto, n, s, base_h=0, base_p=10**6):
    t = human(n, s, base_h)
    rng2 = np.random.default_rng(base_p + 1000 * n + s)
    max_runs = 100 * m * n if proto in ("CI", "EW") else 200 * m
    log, task, fail, exact_fail, mistakes = ew.simulate(cls, proto, t, n, rng2, max_runs, eps)
    return t, task, fail, exact_fail, mistakes


def section1(do_rerun):
    print("=" * 78)
    print("1. Full re-run of E3")
    out = os.path.join(HERE, "referee2_rerun")
    if do_rerun:
        os.makedirs(out, exist_ok=True)
        t0 = time.time()
        with open(os.path.join(out, "end_weighted.out"), "w") as f:
            subprocess.run([sys.executable, os.path.join(CODE, "end_weighted.py"), out], stdout=f, check=True)
        print(f"  re-run took {time.time()-t0:.0f} s")
    a = json.load(open(os.path.join(RESULTS, "end_weighted_summary.json")))
    b = json.load(open(os.path.join(out, "end_weighted_summary.json")))
    print(f"  summary identical to results/end_weighted_summary.json: {a == b}")
    same_out = open(os.path.join(RESULTS, "end_weighted.out")).read() == open(os.path.join(out, "end_weighted.out")).read()
    print(f"  stdout identical to results/end_weighted.out: {same_out}")
    return a


def section2(summary):
    print("=" * 78)
    print("2. Per-human numbers (original seeds), catch-up humans")
    for n in NS:
        print(f"  n = {n}")
        for proto in ["CI", "EW", "LAST", "BIS"]:
            tasks = []
            for s in range(10):
                t, task, fail, ef, mis = run("catch-up", proto, n, s)
                tasks.append(task)
            print(f"    {proto:4s} task per human: {tasks}  mean {np.mean(tasks):.1f}"
                  f" (summary {summary[f'catch-up_{proto}_n{n}']['task_mean']})")
        # what sets CI's cost: the slowest insights, u = (n - t_p)/n is CI's per-visit hit probability
        rows = []
        for s in range(10):
            t, task, *_ = run("catch-up", "CI", n, s)
            u = np.sort((n - t[t < n]) / n)
            rows.append((task, int((t < n).sum()), u[:3]))
        print("    CI: (task, #insights, three smallest per-visit hit probabilities (n - t_p)/n)")
        for task, k, u in sorted(rows, key=lambda r: -r[0])[:4]:
            print(f"      {task:6d}  {k:3d}  {np.round(u, 4)}")


def section3():
    print("=" * 78)
    print("3. Silent humans under LAST: insights at t_p = n - 1 are found")
    for n in NS:
        last_ins, mis, fails, init = [], [], [], []
        for s in range(10):
            t, task, fail, ef, mistakes = run("silent", "LAST", n, s)
            last_ins.append(int((t == n - 1).sum()))
            mis.append(mistakes)
            fails.append(fail)
            init.append((t < n).mean())
        print(f"  n = {n:4d}: problems with t_p = n-1 per human {last_ins} (mean {np.mean(last_ins):.1f});"
              f" mistakes queried mean {np.mean(mis):.1f}; failure at cap {np.mean(fails):.3f}"
              f" vs fraction with an insight {np.mean(init):.3f}")
    print("  -> the last step is a mistake exactly on problems with t_p = n-1; LAST learns those and nothing else.")


def section4():
    print("=" * 78)
    print("4. 200 fresh humans per setting, catch-up class (and silent CI/EW at n = 16, 64)")
    res = {}
    for n in NS:
        for proto in ["CI", "EW", "LAST", "BIS"]:
            tasks, rd = [], []
            for s in range(200):
                t, task, fail, ef, mis = run("catch-up", proto, n, s, base_h=5_000_000, base_p=9_000_000)
                assert fail <= eps
                tasks.append(task)
                rd.append(ef)
            tasks = np.array(tasks)
            res[(n, proto)] = tasks
            print(f"  catch-up n={n:4d} {proto:4s}: mean {tasks.mean():7.1f} +- {tasks.std(ddof=1)/np.sqrt(len(tasks)):6.1f} (s.e.)"
                  f"  median {np.median(tasks):7.1f}  90% {np.percentile(tasks, 90):7.1f}  max {tasks.max():6d}"
                  f"  run differs {np.mean(rd):.3f}")
    # resampling: how variable is a mean over 10 humans?
    rng = np.random.default_rng(3)
    for n in NS:
        x = res[(n, "CI")]
        means = np.array([rng.choice(x, 10, replace=False).mean() for _ in range(20000)])
        print(f"  CI n={n:4d}: means over 10 of these 200 humans: 5%..95% = {np.percentile(means,5):.0f}..{np.percentile(means,95):.0f};"
              f" P(mean >= 3370) = {np.mean(means >= 3370):.3f}")
    for n in [16, 64]:
        ci, e = [], []
        for s in range(40):
            ci.append(run("silent", "CI", n, s, base_h=5_000_000, base_p=9_000_000)[1])
            e.append(run("silent", "EW", n, s, base_h=5_000_000, base_p=9_000_000)[1])
        print(f"  silent n={n}: 40 fresh humans: CI {np.mean(ci):.0f}, EW {np.mean(e):.0f}, ratio {np.mean(e)/np.mean(ci):.2f}")
    return res


def section5(summary):
    print("=" * 78)
    print("5. LAST on catch-up humans as coupon collecting; ratios quoted in the note")
    for n in NS:
        preds = []
        for s in range(10):
            k = int((human(n, s) < n).sum())
            # runs until all but 2 of the k insight problems have been drawn at least once
            preds.append(sum(m / i for i in range(3, k + 1)))
        print(f"  n = {n:4d}: coupon-collector prediction {np.mean(preds):.1f}; observed {summary[f'catch-up_LAST_n{n}']['task_mean']}")
    print("  EW / CI on silent humans: " + ", ".join(
        f"n={n}: {summary[f'silent_EW_n{n}']['task_mean']/summary[f'silent_CI_n{n}']['task_mean']:.3f}" for n in NS))
    print("  EW / LAST on catch-up humans: " + ", ".join(
        f"n={n}: {summary[f'catch-up_EW_n{n}']['task_mean']/summary[f'catch-up_LAST_n{n}']['task_mean']:.3f}" for n in NS))
    print("  (BIS - LAST) / insights met: " + ", ".join(
        f"n={n}: {(summary[f'catch-up_BIS_n{n}']['task_mean']-summary[f'catch-up_LAST_n{n}']['task_mean'])/summary[f'catch-up_LAST_n{n}']['mistakes_queried_mean']:.2f}"
        for n in NS))
    print("  run differs at the end, catch-up: " + "; ".join(
        f"n={n}: " + ", ".join(f"{p} {summary[f'catch-up_{p}_n{n}']['run_differs_mean']:.3f}" for p in ["CI", "EW", "LAST", "BIS"])
        for n in NS))


if __name__ == "__main__":
    summ = section1("--no-rerun" not in sys.argv)
    section2(summ)
    section3()
    section4()
    section5(summ)

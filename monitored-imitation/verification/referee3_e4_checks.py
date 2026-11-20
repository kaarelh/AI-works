"""Referee 3: checks of experiment E4 (code/robust_runs.py) for robust-runs.md.

1. Recompute, per human, the number of task queries until the exact failure probability
   under "more than floor(rho*n) wrong steps" first reaches 2%, using the same seeds and
   the same RNG calls as robust_runs.py. Compare means, s.e.m. and medians with
   results/robust_runs_summary.json.  (Failure probabilities only change when the set of
   known rules changes, so this is much faster than the original.)
2. Check, on explicit state sequences with notes, that the decoder's run is a corrupted
   run whose replaced steps are exactly the steps at which an unknown rule fires (the
   quantity the code counts as "wrong").
3. Theorem 1's own quantity: the expected number of rounds whose run is bad,
   E sum_t F_t(rho), against the number of task queries that landed on a mistake, and
   against K(P)/rho and n*K/(floor(rho*n)+1).  Also check the identity
   E sum_t (mean per-step error of round t) = E[# mistake queries].
4. Shape of the runs: per-step error rate at the stopping time, and how many mistakes the
   failed runs have (the note: "a failed run has a single mistake").
5. Paired comparison across n of the fragile counts (the same 40 humans at every n).

Usage: python3 referee3_e4_checks.py   (about 1 minute)
"""

import json
import math
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "code"))
from property_rules import NC, N_R, MASK_R, World  # noqa: E402

RHOS = [0.0, 0.05, 0.2]
EPS = 0.02
NS = [16, 64, 256]
HUMANS = 40


def k_of_P(world):
    """-log2 prior of the human's rule set under E2's product prior."""
    sizes = {}
    props = set()
    for mi, pat in world.rules:
        props.add((mi, pat))
    for mi, pat in props:
        r = int(MASK_R[mi])
        sizes[r] = sizes.get(r, 0) + 1
    k = 0.0
    for r, Nr in N_R.items():
        a = sizes.get(r, 0)
        k += a * math.log2(Nr) + (Nr - a) * (-math.log2(1.0 - 1.0 / Nr))
    return k, len(props)


def stats(world, known):
    traj_hold = world.hold[world.traj]
    wrong = ((traj_hold & ~known) != 0).sum(axis=1)
    n = world.n
    F = {rho: float(np.mean(wrong > math.floor(rho * n))) for rho in RHOS}
    e = float(np.mean(wrong)) / n
    return F, e, wrong


def one_human(n, s, world=None, seed=None):
    world = World(seed=100 + s, n=n) if world is None else world
    rng = np.random.default_rng(7 + s if seed is None else seed)
    allrules = int(np.bitwise_or.reduce(world.window))
    known = 0
    F, e, wrong = stats(world, known)
    sumF = {rho: 0.0 for rho in RHOS}
    sum_e = 0.0
    first = {rho: None for rho in RHOS}
    at_first = {}
    mq = 0
    r = 0
    while True:
        r += 1
        for rho in RHOS:
            sumF[rho] += F[rho]
        sum_e += e
        c0 = int(rng.integers(NC))
        j = int(rng.integers(n))
        c = int(world.traj[c0, j])
        new = known | int(world.hold[c])
        if new != known:
            mq += 1
            known = new
            F, e, wrong = stats(world, known)
        for rho in RHOS:
            if first[rho] is None and F[rho] <= EPS:
                first[rho] = r
                failed = wrong[wrong > math.floor(rho * n)]
                at_first[rho] = {
                    "per_step_error": e,
                    "frac_failed_runs_with_1_mistake": float(np.mean(failed == 1)) if len(failed) else None,
                    "mean_mistakes_in_failed_runs": float(np.mean(failed)) if len(failed) else None,
                }
        if known == allrules and all(v is not None for v in first.values()):
            break
    K, nrules = k_of_P(world)
    return {"first": first, "sumF": sumF, "sum_e": sum_e, "mq": mq, "K": K,
            "nrules": nrules, "rounds": r, "at_first": at_first}


def check_corrupted_run(n=16, s=0, trials=200):
    """Explicit states (c0, step, notes as a tuple of tokens). Train a decoder with 300
    random queries, then compare its run with the human's process step by step."""
    world = World(seed=100 + s, n=n)
    rng = np.random.default_rng(12345)
    known = 0
    for _ in range(300):
        known |= int(world.hold[int(rng.integers(NC))])
    R = len(world.rules)

    def tokens(c, mask):
        h = int(world.hold[c]) & mask
        return tuple(k for k in range(R) if (h >> k) & 1)

    def P(state):
        c0, j, notes = state
        return (c0, j + 1, notes + tokens(int(world.traj[c0, j]), (1 << R) - 1))

    def G(state):
        c0, j, notes = state
        return (c0, j + 1, notes + tokens(int(world.traj[c0, j]), known))

    bad = 0
    for _ in range(trials):
        c0 = int(rng.integers(NC))
        x = (c0, 0, ())
        M = []
        for k in range(n):
            y = G(x)
            if y != P(x):
                M.append(k)
            x = y
        counted = int(((world.hold[world.traj[c0]] & ~known) != 0).sum())
        if len(M) != counted:
            bad += 1
    return bad


def main():
    with open(os.path.join(HERE, "..", "results", "robust_runs_summary.json")) as f:
        saved = json.load(f)
    out = {"per_n": {}}
    print("== 2. Decoder's run as a corrupted run (explicit states) ==")
    for n in [16, 64]:
        print(f"n={n}: runs where #(x'_(k+1) != P(x'_k)) differs from the code's count: "
              f"{check_corrupted_run(n=n)} of 200")
    per = {}
    for n in NS:
        per[n] = [one_human(n, s) for s in range(HUMANS)]
    print("\n== 1. Reproduction of the table (per-human recomputation vs saved summary) ==")
    for n in NS:
        for rho in RHOS:
            vals = np.array([h["first"][rho] for h in per[n]], dtype=float)
            mean, sem, med = vals.mean(), vals.std(ddof=1) / math.sqrt(len(vals)), np.median(vals)
            sv = saved[f"rho{rho}_n{n}"]
            ok = (abs(mean - sv["task_mean"]) < 1e-9 and abs(sem - sv["task_sem"]) < 1e-9
                  and abs(med - sv["task_median"]) < 1e-9)
            print(f"n={n:4d} rho={rho:<5} floor(rho n)={math.floor(rho * n):3d}  "
                  f"mean {mean:8.3f} sem {sem:7.3f} median {med:7.1f}  "
                  f"saved {sv['task_mean']:8.3f} {sv['task_sem']:7.3f} {sv['task_median']:7.1f}  "
                  f"{'MATCH' if ok else 'MISMATCH'}")
    print("\n== 3. Theorem 1's quantity: expected number of bad rounds ==")
    for n in NS:
        K = np.array([h["K"] for h in per[n]])
        mq = np.array([h["mq"] for h in per[n]], dtype=float)
        se = np.array([h["sum_e"] for h in per[n]])
        nr = np.array([h["nrules"] for h in per[n]])
        print(f"n={n}: K(P) mean {K.mean():.1f} bits (min {K.min():.1f}, max {K.max():.1f}); "
              f"distinct rules {nr.min()}..{nr.max()}; mistake queries mean {mq.mean():.2f} "
              f"(max {mq.max():.0f}); E sum_t per-step error {se.mean():.2f} "
              f"(identity: should equal E[mistake queries] = {mq.mean():.2f}, "
              f"se of difference {np.std(se - mq, ddof=1) / math.sqrt(len(mq)):.2f})")
        rows = {}
        for rho in RHOS:
            sF = np.array([h["sumF"][rho] for h in per[n]])
            j = math.floor(rho * n)
            sharp_eff = mq.mean() * n / (j + 1)
            rows[rho] = {"E_sum_F": float(sF.mean()), "sem": float(sF.std(ddof=1) / math.sqrt(len(sF))),
                         "K_over_rho": (float(K.mean() / rho) if rho > 0 else None),
                         "nK_over_floor_plus_1": float(K.mean() * n / (j + 1)),
                         "Emq_n_over_floor_plus_1": float(sharp_eff)}
            print(f"   rho={rho:<5} E sum_t F_t = {sF.mean():8.2f} +- {rows[rho]['sem']:.2f}   "
                  f"bounds: K/rho = {rows[rho]['K_over_rho'] if rho > 0 else float('inf'):9.1f}, "
                  f"nK/(floor+1) = {rows[rho]['nK_over_floor_plus_1']:9.1f}, "
                  f"E[mq]*n/(floor+1) = {sharp_eff:8.1f}")
        out["per_n"][n] = {"K_mean": float(K.mean()), "mq_mean": float(mq.mean()),
                           "sum_e_mean": float(se.mean()), "rows": {str(k): v for k, v in rows.items()}}
    print("\n== 4. Runs at the stopping time ==")
    for n in NS:
        for rho in RHOS:
            af = [h["at_first"][rho] for h in per[n]]
            e = np.array([a["per_step_error"] for a in af])
            f1 = [a["frac_failed_runs_with_1_mistake"] for a in af if a["frac_failed_runs_with_1_mistake"] is not None]
            mm = [a["mean_mistakes_in_failed_runs"] for a in af if a["mean_mistakes_in_failed_runs"] is not None]
            print(f"n={n:4d} rho={rho:<5}: per-step error at stop mean {e.mean():.4f} "
                  f"(rho = {rho}); failed runs with exactly 1 mistake: "
                  f"{np.mean(f1) if f1 else float('nan'):.3f}; mean mistakes in failed runs "
                  f"{np.mean(mm) if mm else float('nan'):.2f}")
    print("\n== 5. Paired comparison of the fragile counts across n (same humans) ==")
    for a, b in [(16, 64), (64, 256), (16, 256)]:
        va = np.array([h["first"][0.0] for h in per[a]], dtype=float)
        vb = np.array([h["first"][0.0] for h in per[b]], dtype=float)
        d = vb - va
        print(f"n={b} minus n={a}: mean diff {d.mean():8.1f} +- {d.std(ddof=1) / math.sqrt(len(d)):6.1f} (sem); "
              f"{int((d > 0).sum())} of {len(d)} humans more expensive at n={b}; "
              f"medians {np.median(va):.1f} -> {np.median(vb):.1f}")
    for rho in [0.05, 0.2]:
        for a, b in [(16, 64), (64, 256)]:
            va = np.array([h["first"][rho] for h in per[a]], dtype=float)
            vb = np.array([h["first"][rho] for h in per[b]], dtype=float)
            d = vb - va
            print(f"rho={rho}: n={b} minus n={a}: mean diff {d.mean():7.1f} +- "
                  f"{d.std(ddof=1) / math.sqrt(len(d)):5.1f}; {int((d < 0).sum())} of {len(d)} cheaper at n={b}")
    with open(os.path.join(HERE, "referee3_e4_checks.json"), "w") as f:
        json.dump(out, f, indent=1)




def fragile_target_analysis():
    """6. In E2/E4 the queried content is uniform on all 4096 contents at every n (c0 is
    uniform and the permutation is a bijection), independently across rounds, and the
    humans are the same at every n. If every single rule on its own makes more than 2% of
    runs fail, the fragile target is reached exactly when all rules are known, so the
    number of task queries it needs has the same distribution at every n. Compute, per
    human: the smallest single-rule failure probability, and E[T_all] exactly by
    inclusion-exclusion, E[T_all] = sum_{A nonempty} (-1)^{|A|+1} / p(A), where p(A) is
    the fraction of contents at which some rule in A fires.
    7. Mean number of mistakes in a run in which a rarest (size-9) rule fires."""
    print("\n== 6. The fragile target: same expected cost at every n ==")
    ET = []
    VT = []
    for s in range(HUMANS):
        w16 = World(seed=100 + s, n=16)
        R = len(w16.rules)
        sets = []
        for k in range(R):
            bits = ((w16.hold >> k) & 1).astype(bool)
            sets.append(int("".join("1" if b else "0" for b in bits[::-1]), 2))
        union = [0] * (1 << R)
        total = 0.0
        total2 = 0.0
        for A in range(1, 1 << R):
            low = (A & -A).bit_length() - 1
            union[A] = union[A & (A - 1)] | sets[low]
            p = union[A].bit_count() / NC
            sign = 1.0 if bin(A).count("1") % 2 == 1 else -1.0
            total += sign / p
            total2 += sign * (2.0 * (1.0 - p) / p ** 2 + 1.0 / p)
        ET.append(total)
        VT.append(total2 - total ** 2)
    ET = np.array(ET)
    print(f"E[queries until all 18 rules are known], exact per human, mean over the 40 humans: "
          f"{ET.mean():.1f} (sd over humans {ET.std(ddof=1):.1f}); this is the expected fragile cost at "
          f"every n at which each rule alone fails > 2% of runs")
    sdT = math.sqrt(float(np.mean(VT)))
    print(f"sd of T_all within a human (exact, root-mean over humans): {sdT:.1f}; so the s.e.m. of a "
          f"40-human mean is about {sdT / math.sqrt(HUMANS):.1f} (plus {ET.std(ddof=1) / math.sqrt(HUMANS):.1f} from humans)")
    with open(os.path.join(HERE, "..", "results", "robust_runs_summary.json")) as f:
        saved = json.load(f)
    for n in NS:
        m = saved[f"rho0.0_n{n}"]["task_mean"]
        print(f"   saved fragile mean at n={n}: {m:.1f}, z = (saved - {ET.mean():.1f}) / {sdT / math.sqrt(HUMANS):.1f} = "
              f"{(m - ET.mean()) / (sdT / math.sqrt(HUMANS)):+.2f}")
    for n in NS:
        mins = []
        rare = []
        for s in range(HUMANS):
            w = World(seed=100 + s, n=n)
            th = w.hold[w.traj]
            per_rule = [float(np.mean(((th >> k) & 1).any(axis=1))) for k in range(len(w.rules))]
            mins.append(min(per_rule))
            for k in range(len(w.rules)):
                if w.rule_size[k] == 9:
                    cnt = ((th >> k) & 1).sum(axis=1)
                    rare.append(float(cnt[cnt > 0].mean()))
        print(f"n={n:4d}: smallest single-rule failure probability over all humans' rules: {min(mins):.4f} "
              f"(> 0.02 means the fragile target needs every rule); mean mistakes in a run in which a "
              f"size-9 rule fires: {np.mean(rare):.2f}")
    return ET


def independent_seeds(extra=10):
    """8. The same 40 humans, with `extra` independent query sequences each (seeds
    10000 + 100*s + e), so 400 runs per n instead of 40."""
    print(f"\n== 8. Same humans, {extra} fresh query seeds each ({HUMANS * extra} runs per n) ==")
    res = {}
    for n in NS:
        vals = {rho: [] for rho in RHOS}
        sums = {rho: [] for rho in RHOS}
        for s in range(HUMANS):
            world = World(seed=100 + s, n=n)
            for e in range(extra):
                h = one_human(n, s, world=world, seed=10000 + 100 * s + e)
                for rho in RHOS:
                    vals[rho].append(h["first"][rho])
                    sums[rho].append(h["sumF"][rho])
        for rho in RHOS:
            v = np.array(vals[rho], dtype=float)
            sf = np.array(sums[rho])
            print(f"n={n:4d} rho={rho:<5}: queries to 2%: mean {v.mean():8.1f} +- {v.std(ddof=1) / math.sqrt(len(v)):5.1f}, "
                  f"median {np.median(v):7.1f};   E sum_t F_t = {sf.mean():7.1f} +- {sf.std(ddof=1) / math.sqrt(len(sf)):5.1f}")
            res[f"rho{rho}_n{n}"] = {"mean": float(v.mean()), "sem": float(v.std(ddof=1) / math.sqrt(len(v))),
                                     "median": float(np.median(v)), "E_sum_F": float(sf.mean())}
    with open(os.path.join(HERE, "referee3_e4_independent_seeds.json"), "w") as f:
        json.dump(res, f, indent=1)


if __name__ == "__main__":
    main()
    fragile_target_analysis()
    independent_seeds()

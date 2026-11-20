"""Referee 4: two extra checks on E6 (slack-imitation.md, Section 6).

1. "The same humans without slack." In slack_imitation.py the row "CI, no slack" at a given n
   uses n0 = n, while the slack rows use n0 = n/2, so t_p is drawn from a different range: they
   are not the same humans. Here CI without slack is run at n = n0 on exactly the humans of the
   slack cells (same seeds 1000*(2*n0) + s, same n0), for n0 = 8 and 32, and compared with the
   saved SI numbers at n = 2*n0.
2. SI-V (Proposition 4): which problems are rejected (by k_p), and how often a problem is
   rejected more than once; and K of each human, for scale.

Usage: python3 referee4_extra.py
"""

import json
import os
import sys
from multiprocessing import Pool

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(ROOT, "code"))
import slack_imitation as si  # noqa: E402

import numpy as np  # noqa: E402


def humans(n, n0, s):
    rng = np.random.default_rng(1000 * n + s)
    tp = rng.integers(0, n0, size=si.M)
    kp = np.where(rng.random(si.M) < si.PI, 1, 2)
    return tp, kp


def ci_same_humans(args):
    kind, n0, s = args
    # one_human draws (tp, kp) from the seed with n0 = n - sigma; with n = n0, sigma = 0 and
    # seed 1000*(2*n0) + s these are the humans of the slack cell at n = 2*n0.
    return si.one_human((kind, n0, 0, "CI", 1000 * (2 * n0) + s, 40 * si.M * n0))


def verifier_detail(args):
    kind, n, s = args
    persistent, D = si.KINDS[kind]
    n0 = n // 2
    tp, kp = humans(n, n0, s)
    rng2 = np.random.default_rng(1000 * n + s + 2 * 10**8)
    rej_by_k = {1: 0, 2: 0}
    problems_rejected = 0
    multi = 0
    for p in range(si.M):
        pr = si.Problem(n, n0, persistent, D)
        r = 0
        while not pr.success(tp[p], kp[p]):
            r += 1
            held = []
            while True:
                j = int(rng2.integers(n))
                a, u = pr.run[j]
                hum = pr.human_step(j, tp[p], kp[p])
                if hum != pr.decoder_step(j):
                    break
                held.append((j, a, u, hum))
            for (jj, aa, uu, hh) in [(j, a, u, hum)] + held:
                idx = np.flatnonzero(pr.alive)
                out = pr.outputs(jj, aa, uu, pr.t[idx], pr.k[idx])
                pr.alive[idx[out != hh]] = False
            pr.recompute()
        if r:
            problems_rejected += 1
            rej_by_k[int(kp[p])] += r
            multi += (r > 1)
    k2 = int((kp == 2).sum())
    K = float(sum(np.log2(n0) - np.log2(si.PI if k == 1 else 1 - si.PI) for k in kp))
    return rej_by_k[1], rej_by_k[2], problems_rejected, multi, k2, K


def main():
    saved = {}
    for name in ["slack_imitation_summary.json", "slack_imitation_verifier.json"]:
        with open(os.path.join(ROOT, "results", name)) as f:
            saved.update(json.load(f))

    print("0. Are the 'CI, no slack' humans the same as the slack humans? (seed 1000n+s, s=0)")
    for n in (16, 64):
        a = humans(n, n, 0)
        b = humans(n, n // 2, 0)
        print(f"   n={n}: t_p (no slack, n0=n) first 8 {a[0][:8].tolist()}, max {a[0].max()};"
              f" t_p (slack, n0=n/2) first 8 {b[0][:8].tolist()}, max {b[0].max()};"
              f" k_p equal on {(a[1] == b[1]).sum()}/100 problems")

    print("\n1. CI without slack on the same humans (n = n0), against SI with slack (n = 2*n0).")
    out = {}
    with Pool(4) as pool:
        for n0 in (8, 32):
            for kind in si.KINDS:
                rows = pool.map(ci_same_humans, [(kind, n0, s) for s in range(40)])
                summ = si.summarise(rows)
                out[f"{kind}_n0{n0}_CI_noslack_samehumans"] = summ
                si_key = f"{kind}_n{2 * n0}_sigma{n0}_CI"
                ci_key = f"{kind}_n{2 * n0}_sigma0_CI"
                print(f"   n0={n0:3d} {kind:9s}: CI no slack, same humans (n={n0}) "
                      f"{summ['task_mean']:9.1f} ± {summ['task_sem']:6.1f} (reached {summ['reached']}/40) | "
                      f"SI (n={2 * n0}) {saved[si_key]['task_mean']:8.1f} | "
                      f"note's 'CI, no slack' (n={2 * n0}, n0={2 * n0}) {saved[ci_key]['task_mean']:8.1f}",
                      flush=True)

        print("\n2. SI-V: rejected runs by k_p, problems rejected more than once, K for scale.")
        for n in (16, 64):
            for kind in si.KINDS:
                rows = pool.map(verifier_detail, [(kind, n, s) for s in range(40)])
                r1 = np.mean([r[0] for r in rows])
                r2 = np.mean([r[1] for r in rows])
                pr = np.mean([r[2] for r in rows])
                mu = np.mean([r[3] for r in rows])
                k2 = np.mean([r[4] for r in rows])
                K = np.mean([r[5] for r in rows])
                tot = r1 + r2
                sv = saved[f"{kind}_n{n}_sigma{n // 2}_SIV"]["rejected_mean"]
                print(f"   n={n:3d} {kind:9s}: rejections/human {tot:6.2f} (saved {sv:6.2f}); "
                      f"on k_p=1 problems {r1:5.2f}, on k_p=2 problems {r2:5.2f}; "
                      f"problems with k_p=2 {k2:5.2f}; problems rejected {pr:6.2f}, "
                      f"of them more than once {mu:5.2f}; mean K {K:6.1f} bits", flush=True)
    os.makedirs(os.path.join(HERE, "referee4_rerun"), exist_ok=True)
    with open(os.path.join(HERE, "referee4_rerun", "ci_same_humans.json"), "w") as f:
        json.dump(out, f, indent=1)


if __name__ == "__main__":
    main()

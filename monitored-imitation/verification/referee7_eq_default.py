"""Referee 7: EQ (thread Q section 8) re-run with VSI's recommended default weights.

verified-slack.md section 8 quotes EQ for the three streams in *equal* round robin (U+S+H), but
section 2.3 recommends the weights (w_S, w_U, w_H) = (1/2, 1/4, 1/4). This script re-runs thread Q's
experiment, unchanged except for the schedule of streams:

  USH   equal round robin (thread Q's protocol; reproduction check against threadQ_hints.json);
  SUSH  the default weights, deterministic period-4 schedule S, U, S, H, S, U, S, H, ...;
  RAND  the default weights, each query's stream drawn at random with probabilities (1/2, 1/4, 1/4).

It imports thread Q's own code (research/threadQ_hints.py) and E6's class (code/slack_imitation.py).
No bytecode is written next to those files. Writes referee7_eq_default.out here.
"""

import json
import os
import sys
import time
from multiprocessing import Pool

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "research"))
sys.path.insert(0, os.path.join(HERE, "..", "code"))

import numpy as np  # noqa: E402

import threadQ_hints as tq  # noqa: E402
from slack_imitation import KINDS, M, PI, SET1, SET2, Problem  # noqa: E402

WEIGHTS = {"S": 0.5, "U": 0.25, "H": 0.25}


def search_random(pr, tp, kp, rng_u, rng_s):
    """Thread Q's search, but each query's stream is drawn at random with WEIGHTS.
    An exhausted or empty list stream is skipped (its weight goes to the others)."""
    n = pr.n
    truth = [pr.human_step(j, tp, kp) for j in range(n)]
    hints = [j for j in range(n) if pr.codes[j] in (SET1, SET2)]
    lists = {"S": list(range(n)), "H": hints}
    pos = {"S": 0, "H": 0}
    asked, held, spent = set(), [], 0
    while True:
        live = ["U"]
        for s in ("S", "H"):
            while pos[s] < len(lists[s]) and lists[s][pos[s]] in asked:
                pos[s] += 1
            if pos[s] < len(lists[s]):
                live.append(s)
        w = np.array([WEIGHTS[s] for s in live])
        s = live[int(rng_s.choice(len(live), p=w / w.sum()))]
        if s == "U":
            j = int(rng_u.integers(n))
        else:
            j = lists[s][pos[s]]
            pos[s] += 1
        spent += 1
        asked.add(j)
        a, u = pr.run[j]
        if truth[j] != pr.decoder_step(j):
            return spent, (j, a, u, truth[j]), held
        held.append((j, a, u, truth[j]))


def one_human_random(args):
    kind, n, seed = args
    persistent, D = KINDS[kind]
    n0 = n - n // 2
    rng = np.random.default_rng(seed)
    tp = rng.integers(0, n0, size=M)
    kp = np.where(rng.random(M) < PI, 1, 2)
    rng_u = np.random.default_rng(seed + 2 * 10**8)
    rng_s = np.random.default_rng(seed + 3 * 10**8)
    queries = rejected = 0
    worst = 0
    for p in range(M):
        pr = Problem(n, n0, persistent, D)
        while not pr.success(tp[p], kp[p]):
            rejected += 1
            spent, hit, held = search_random(pr, tp[p], kp[p], rng_u, rng_s)
            worst = max(worst, spent)
            queries += spent
            for (jj, aa, uu, hh) in [hit] + held:
                idx = np.flatnonzero(pr.alive)
                out = pr.outputs(jj, aa, uu, pr.t[idx], pr.k[idx])
                pr.alive[idx[out != hh]] = False
            pr.recompute()
    return queries, rejected, worst


def one_human_det(args):
    kind, n, seed, streams = args
    q, r = tq.one_human((kind, n, seed, streams))
    return q, r, -1


def main():
    H = 40
    ns = [16, 64, 256]
    ref = json.load(open(os.path.join(HERE, "..", "research", "threadQ_hints.json")))
    res, lines = {}, []
    t0 = time.time()
    with Pool(4) as pool:
        for n in ns:
            for kind in KINDS:
                for proto in ("USH", "SUSH", "RAND"):
                    if proto == "RAND":
                        rows = pool.map(one_human_random, [(kind, n, 1000 * n + s) for s in range(H)])
                    else:
                        rows = pool.map(one_human_det, [(kind, n, 1000 * n + s, proto) for s in range(H)])
                    q = np.array([r[0] for r in rows], float)
                    rej = np.array([r[1] for r in rows], float)
                    res[(kind, n, proto)] = (q.mean(), q.std(ddof=1) / np.sqrt(H), rej.mean(),
                                             q.sum() / max(rej.sum(), 1), max(r[2] for r in rows))
                    print(kind, n, proto, res[(kind, n, proto)], f"[{time.time() - t0:.0f}s]", flush=True)
    lines.append("# referee7_eq_default.py: EQ (thread Q section 8) with VSI's default weights (1/2, 1/4, 1/4)")
    lines.append(f"# 40 humans per cell, same humans and seeds as threadQ_hints.py; total task queries for {M} problems")
    lines.append("# USH = thread Q's equal round robin (reproduction); SUSH = deterministic S,U,S,H; RAND = random draw of stream")
    lines.append("")
    lines.append("| human | protocol | n = 16 | n = 64 | n = 256 |")
    lines.append("|---|---|---|---|---|")
    for kind in KINDS:
        for proto in ("USH", "SUSH", "RAND"):
            cells = []
            for n in ns:
                m, se, rj, pr_, _ = res[(kind, n, proto)]
                cells.append(f"{m:,.1f} ± {se:,.1f} ({rj:.1f} rej.; {pr_:.2f}/rej.)")
            lines.append(f"| {kind} | {proto} | " + " | ".join(cells) + " |")
    lines.append("")
    lines.append("Reproduction check: USH against threadQ_hints.json task_mean")
    ok = True
    for kind in KINDS:
        for n in ns:
            a = res[(kind, n, "USH")][0]
            b = ref[f"{kind}_n{n}_USH"]["task_mean"]
            flag = "ok" if abs(a - b) < 1e-9 else "DIFF"
            ok &= flag == "ok"
            lines.append(f"  {kind:9s} n={n:3d}: referee7 {a:10.3f}  threadQ {b:10.3f}  {flag}")
    lines.append(f"  all identical: {ok}")
    lines.append("")
    lines.append("Ratios to thread Q's U (uniform search alone) and to USH")
    for kind in KINDS:
        for n in ns:
            u = ref[f"{kind}_n{n}_U"]["task_mean"]
            ush = res[(kind, n, "USH")][0]
            sush = res[(kind, n, "SUSH")][0]
            rnd = res[(kind, n, "RAND")][0]
            lines.append(f"  {kind:9s} n={n:3d}: SUSH/U {sush / u:5.2f}  SUSH/USH {sush / ush:5.2f}  "
                         f"RAND/U {rnd / u:5.2f}  RAND/USH {rnd / ush:5.2f}")
    lines.append("")
    lines.append("Largest single search under RAND, against 2*n0 (sure bound claimed for the default weights):")
    for kind in KINDS:
        for n in ns:
            lines.append(f"  {kind:9s} n={n:3d}: max search {res[(kind, n, 'RAND')][4]:4d}   2*n0 = {n}")
    lines.append(f"\nWall time {time.time() - t0:.0f}s")
    text = "\n".join(lines) + "\n"
    print(text)
    with open(os.path.join(HERE, "referee7_eq_default.out"), "w") as f:
        f.write(text)


if __name__ == "__main__":
    main()

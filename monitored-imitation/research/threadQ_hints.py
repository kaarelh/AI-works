"""Thread Q, experiment EQ: where to search a rejected run (Lemma Q2 of threadQ-alternatives.md).

E6's class and humans, unchanged, imported from ../code/slack_imitation.py (exact posteriors,
slack sigma = n/2, a perfect verifier, every problem rerun until its final notebook succeeds:
Protocol SI-V of slack-imitation.md, Proposition 4). Only the search on a rejected run changes.
A search queries steps of the fixed rejected run until it lands on a mistake; the hit's answer is
added first and the others after it, as in E6. Streams, taken in round robin (a stream with
nothing left is skipped at no cost):

  U  uniform step, with replacement (E6's SI-V search; repeats are counted, as in E6);
  S  scan from step 0 upwards (skipping steps already asked in this search);
  H  structural hint: the steps at which the decoder wrote a value (its "verdict" entries), in
     order. This is E6's version of a post-mortem pointer at load-bearing claims: it is computed
     from the run's content only, without the human;
  A  adversarial hint: the steps that are NOT mistakes, in order (uses the truth on purpose; the
     worst case for any pointer).

Protocols: U (= E6's SI-V, a reproduction check), US, UH, USH, UA.
Lemma Q2 says: queries per search <= (number of streams) * min over streams of each stream's cost.

Usage: python3 threadQ_hints.py [--quick]    (writes threadQ_hints.out and threadQ_hints.json here)
"""

import json
import os
import sys
import time
from multiprocessing import Pool

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "code"))

import numpy as np  # noqa: E402

from slack_imitation import KINDS, M, PI, SET1, SET2, Problem  # noqa: E402


def search(pr, tp, kp, streams, rng):
    """Search the fixed run of pr for a mistake. Returns (queries, hit, held answers)."""
    n = pr.n
    truth = [pr.human_step(j, tp, kp) for j in range(n)]
    hints = [j for j in range(n) if pr.codes[j] in (SET1, SET2)]
    adv = [j for j in range(n) if truth[j] == pr.codes[j]]
    lists = {"S": list(range(n)), "H": hints, "A": adv}
    pos = {"S": 0, "H": 0, "A": 0}
    asked, held, spent, turn = set(), [], 0, 0
    while True:
        s = streams[turn % len(streams)]
        turn += 1
        if s == "U":
            j = int(rng.integers(n))
        else:
            L = lists[s]
            while pos[s] < len(L) and L[pos[s]] in asked:
                pos[s] += 1
            if pos[s] >= len(L):
                continue
            j = L[pos[s]]
            pos[s] += 1
        spent += 1
        asked.add(j)
        a, u = pr.run[j]
        if truth[j] != pr.decoder_step(j):
            return spent, (j, a, u, truth[j]), held
        held.append((j, a, u, truth[j]))


def one_human(args):
    kind, n, seed, streams = args
    persistent, D = KINDS[kind]
    n0 = n - n // 2
    rng = np.random.default_rng(seed)
    tp = rng.integers(0, n0, size=M)
    kp = np.where(rng.random(M) < PI, 1, 2)
    rng2 = np.random.default_rng(seed + 2 * 10**8)  # E6's seed for SI-V's search
    queries = rejected = 0
    for p in range(M):
        pr = Problem(n, n0, persistent, D)
        while not pr.success(tp[p], kp[p]):
            rejected += 1
            spent, hit, held = search(pr, tp[p], kp[p], streams, rng2)
            queries += spent
            for (jj, aa, uu, hh) in [hit] + held:
                idx = np.flatnonzero(pr.alive)
                out = pr.outputs(jj, aa, uu, pr.t[idx], pr.k[idx])
                pr.alive[idx[out != hh]] = False
            pr.recompute()
    return queries, rejected


def main(quick=False):
    H = 8 if quick else 40
    ns = [16, 64] if quick else [16, 64, 256]
    protos = ["U", "US", "UH", "USH", "UA"]
    out, lines = {}, []
    t0 = time.time()
    with Pool(4) as pool:
        for n in ns:
            for kind in KINDS:
                for proto in protos:
                    rows = pool.map(one_human, [(kind, n, 1000 * n + s, proto) for s in range(H)])
                    q = np.array([r[0] for r in rows], dtype=float)
                    rej = np.array([r[1] for r in rows], dtype=float)
                    key = f"{kind}_n{n}_{proto}"
                    out[key] = dict(kind=kind, n=n, protocol=proto, humans=H,
                                    task_mean=float(q.mean()),
                                    task_sem=float(q.std(ddof=1) / np.sqrt(H)),
                                    rejected_mean=float(rej.mean()),
                                    per_rejection=float(q.sum() / max(rej.sum(), 1)))
                    print(json.dumps(out[key]), f"[{time.time() - t0:.0f}s]")
                    sys.stdout.flush()
    hdr = "| human | protocol | " + " | ".join(f"n = {n}" for n in ns) + " |"
    lines += [hdr, "|---|---|" + "---|" * len(ns)]
    for kind in KINDS:
        for proto in protos:
            cells = []
            for n in ns:
                e = out[f"{kind}_n{n}_{proto}"]
                cells.append(f"{e['task_mean']:,.0f} ± {e['task_sem']:,.0f} "
                             f"({e['rejected_mean']:.1f} rej.; {e['per_rejection']:.1f}/rej.)")
            lines.append(f"| {kind} | {proto} | " + " | ".join(cells) + " |")
    text = "\n".join(lines) + "\n"
    print(text)
    suffix = "_quick" if quick else ""
    with open(os.path.join(HERE, f"threadQ_hints{suffix}.json"), "w") as f:
        json.dump(out, f, indent=1)
    with open(os.path.join(HERE, f"threadQ_hints{suffix}.out"), "w") as f:
        f.write(f"# threadQ_hints.py, {H} humans per cell, total task queries for {M} problems\n")
        f.write(f"# (rejected runs per human; queries per rejection). Wall time {time.time() - t0:.0f}s\n\n")
        f.write(text)


if __name__ == "__main__":
    main(quick="--quick" in sys.argv)

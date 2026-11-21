"""Referee 8: E7's VSI column (thread R, research/threadR_compose.py) re-run with the note's
default schedule S, U, S, H, on the same humans and seeds.

Three variants of VSI, each with the L-first step:
  USL    thread R's equal round robin U, S, L with thread R's list (reproduction of E7's column);
  SUSL   the note's fixed schedule S, U, S, H (verified-slack.md §2.3), with thread R's list;
  SUSH   S, U, S, H with the list H exactly as §2.3 defines it when there are no post-mortem
         entries: the last review step and the labelled decision steps only. Thread R's list
         also holds "verdict steps" (E6 value entries, the G insight entry, F1 claim and record
         entries, HEDGE's A entry), which stand in for a perfect second-researcher post-mortem.

For each cell: mean total task queries for the 100 problems (± s.e.), rejections, and the
largest single search, compared with 2 n0 - 1 (Theorem 5(d)'s sure bound for S, U, S, H).

Imports thread R's code unchanged and writes nothing into research/.
Usage: python3 -B referee8_e7_default.py > referee8_e7_default.out
"""

import os
import sys
import time
import types
from multiprocessing import Pool

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(os.path.dirname(HERE), "research"))

import numpy as np  # noqa: E402

import threadR_compose as R  # noqa: E402

MECHS = ["M1", "M2", "M3", "M4", "M5", "M5'", "M6", "M7", "M8"]
VARIANTS = {"USL": ("USL", False), "SUSL": ("SUSL", False), "SUSH": ("SUSL", True)}


def note_H(self):
    """§2.3's list H without post-mortem entries: last review step, labelled decisions."""
    if isinstance(self, R.GA):
        return [self.rev[-1]] if self.rev and self.rev[-1] not in self.flags else []
    if isinstance(self, R.HedgeA):
        return [j for j in range(self.n) if self.codes[j] in self.DECISIONS and not self.flags[j]]
    return []          # E6 and F1 classes have no reviews and no labelled decisions


def first_mistake(A, n):
    for j in range(n):
        if not A.asked(j) and A.human(j) != A.code(j):
            return j
    return None


def run(args):
    mech, size, s, variant = args
    streams, use_note_H = VARIANTS[variant]
    cls = R.MECHS[mech]["cls"]
    As, nr, n0, n_slack, sd = R.humans(mech, size, s, True, None)
    if use_note_H:
        for A in As:
            A.pointer_list = types.MethodType(note_H, A)
    rng2 = np.random.default_rng(sd + R.OFFSETS[cls][1])     # thread R's VSI seed
    queries = rejected = lflag = 0
    max_search, max_first, over = 0, -1, 0
    for A in As:
        A.build(None)
        while A.failed():
            rejected += 1
            bad = A.invalid_steps()
            if bad:
                j = bad[0]
                A.add(j, A.human(j))
                queries += 1
                lflag += 1
            else:
                fm = first_mistake(A, nr)
                max_first = max(max_first, -1 if fm is None else fm)
                sq = R.search(A, streams, rng2, nr, False)
                queries += sq
                max_search = max(max_search, sq)
                over += sq > 2 * n0 - 1
            A.build(None)
    return (mech, size, variant), dict(q=queries, rej=rejected, lf=lflag, ms=max_search,
                                      mf=max_first, over=over, n0=n0, n=nr)


def main():
    t0 = time.time()
    jobs = []
    for mech in MECHS:
        cls = R.MECHS[mech]["cls"]
        for size in R.HORIZONS[cls]:
            for s in range(R.MECHS[mech]["H"]):
                for v in VARIANTS:
                    jobs.append((mech, size, s, v))
    with Pool(4) as pool:
        out = pool.map(run, jobs, chunksize=4)
    cells = {}
    for key, r in out:
        cells.setdefault(key, []).append(r)

    print("# referee8_e7_default.py: E7's VSI column with the default schedule S, U, S, H")
    print("# same humans, seeds and code as research/threadR_compose.py; total task queries for "
          "100 problems, mean ± s.e. (rejections); max = largest single search")
    print()
    print("| mechanism | n0 | USL (thread R) | SUSL (default, R's list) | SUSH (default, §2.3's H) "
          "| SUSL/USL | SUSH/USL |")
    print("|---|---|---|---|---|---|---|")
    summary = {}
    for mech in MECHS:
        cls = R.MECHS[mech]["cls"]
        for size in R.HORIZONS[cls]:
            row, means = [], {}
            n0 = None
            for v in VARIANTS:
                rs = cells[(mech, size, v)]
                q = np.array([r["q"] for r in rs], float)
                rej = np.mean([r["rej"] for r in rs])
                m, se = q.mean(), q.std(ddof=1) / np.sqrt(len(q))
                means[v] = m
                n0 = rs[0]["n0"]
                row.append(f"{m:,.1f} ± {se:.1f} ({rej:.1f} rej.; max {max(r['ms'] for r in rs)})")
            summary[(mech, size)] = means
            print(f"| {mech} | {n0} | " + " | ".join(row) +
                  f" | {means['SUSL'] / means['USL']:.2f} | {means['SUSH'] / means['USL']:.2f} |")
    print()

    # reproduction of thread R's published VSI column
    import json
    pub = json.load(open(os.path.join(os.path.dirname(HERE), "research", "threadR_compose.json")))
    ok = True
    print("Reproduction of thread R's VSI column (threadR_compose.json, queries_mean):")
    for mech in MECHS:
        cls = R.MECHS[mech]["cls"]
        for size in R.HORIZONS[cls]:
            key = [k for k in pub if k.startswith(f"{mech}|VSI|") and
                   (f"n₀={size // 2}" in k.split("|")[2] if cls != "G" else f"N={size} " in k)]
            assert len(key) == 1, (mech, size, key)
            p = pub[key[0]]["queries_mean"]
            h = summary[(mech, size)]["USL"]
            ok &= abs(p - h) < 1e-9
            print(f"  {key[0]:<28} published {p:10.3f}  here {h:10.3f}  {'ok' if abs(p - h) < 1e-9 else 'DIFF'}")
    print(f"  all identical: {ok}")
    print()

    print("Theorem 5(d)'s sure bound for S, U, S, H: no search above 2 n0 - 1 (searches over the bound):")
    for mech in MECHS:
        cls = R.MECHS[mech]["cls"]
        for size in R.HORIZONS[cls]:
            for v in ("SUSL", "SUSH"):
                rs = cells[(mech, size, v)]
                n0 = rs[0]["n0"]
                print(f"  {mech:<4} n0={n0:<4} {v}: max search {max(r['ms'] for r in rs):5d}  "
                      f"2n0-1 = {2 * n0 - 1:4d}  over: {sum(r['over'] for r in rs)}  "
                      f"latest first mistake {max(r['mf'] for r in rs)} (< n0 = {n0})")
    print()

    print("Per-rejection cost on M3 and M5 (searches only), in units of n0:")
    for mech in ("M3", "M5"):
        cls = R.MECHS[mech]["cls"]
        for size in R.HORIZONS[cls]:
            parts = []
            for v in VARIANTS:
                rs = cells[(mech, size, v)]
                q = sum(r["q"] for r in rs)
                rej = sum(r["rej"] for r in rs)
                parts.append(f"{v} {q / rej / rs[0]['n0']:.2f}")
            print(f"  {mech} n0={cells[(mech, size, 'USL')][0]['n0']}: " + ", ".join(parts))
    print()
    print(f"Wall time {time.time() - t0:.0f}s")


if __name__ == "__main__":
    main()

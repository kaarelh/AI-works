"""Referee B, thread `shape`: Conjecture 7.1b (s_2(m) = sum_{i<=m} floor(log2 i)) beyond the record's range.

Uses ilp_reach from refB_t7_spanners.py (layered-reach ILP, HiGHS via scipy, only edge variables integral).
Deterministic. Appends each result to refB_t7_conj.out as it is obtained (so partial runs are kept).
Usage: python3 refB_t7_conj.py M_FROM M_TO [TIME_LIMIT_SECONDS]
"""
import os, sys, time, math
here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, here)
src = open(os.path.join(here, "refB_t7_spanners.py")).read()
ns = {"__file__": os.path.join(here, "refB_t7_spanners.py")}
exec(src.split("# ------------------------------------------------------------------ A")[0], ns)
exec(src[src.index("def covered_all"):src.index("record = {")], ns)
ilp_reach, covered_all = ns["ilp_reach"], ns["covered_all"]
a, b = int(sys.argv[1]), int(sys.argv[2])
tl = float(sys.argv[3]) if len(sys.argv) > 3 else 7200
outp = os.path.join(here, "refB_t7_conj.out")
for m in range(a, b + 1):
    t = time.time()
    val, E = ilp_reach(m, 2, time_limit=tl)
    S = sum(int(math.floor(math.log2(i))) for i in range(1, m + 1))
    if val is not None:
        adj = [0] * (m + 1)
        for (i, j) in E:
            adj[i] |= 1 << j
        assert covered_all(adj, m, 2) is None
        line = f"k=2 m={m}: ILP optimum s_2(m) = {val}; sum floor(log2 i) = {S}; equal: {val == S} ({time.time() - t:.0f}s)"
    else:
        line = f"k=2 m={m}: ILP not solved to optimality within {tl:.0f}s (status {E}); sum floor(log2 i) = {S}"
    print(line, flush=True)
    with open(outp, "a") as f:
        f.write(line + "\n")

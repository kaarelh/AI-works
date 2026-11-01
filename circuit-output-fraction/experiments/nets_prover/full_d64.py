"""Attempt at a complete certificate of p for a d = 64 net, built and
verified piece by piece within a wall-clock budget.

The argument is a decision tree whose top k levels follow the prover's own
splitting rule (strong branching); its 2^k subtrees ("pieces") are built by
prove(root=piece) and checked by verify(root=piece), each in a worker
process, and then discarded (a whole argument would not fit in memory).
Soundness of the composition: the top tree is checked by `verify` as a
partition of the cube (all its leaves OPEN, so only the parse matters), and
p = 2^-k sum_pieces p_piece with every p_piece exact; so if every piece is
certified exactly, p is certified exactly, and with only some pieces done the
failing count is exactly known on that part of the cube.

Pieces are processed in a uniformly random order (seeded), so the pieces
done are a uniform sample of the 2^k and the totals extrapolate without bias.
No new piece is started after the budget; running pieces are allowed to end.

Usage: python3 full_d64.py [net] [k] [budget_minutes] [workers]
       -> results/full_d64_<net>.json (written as pieces complete)
"""
import json
import math
import os
import sys
import time

os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")
os.environ.setdefault("OMP_NUM_THREADS", "1")

import multiprocessing as mp  # noqa: E402

import numpy as np  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob.nets_prover import OPEN, SPLIT, CertNet, ProverConfig, _choose_split, prove, verify  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
CFG = dict(kinds=("lin",), r_leaf=5, node_budget=3_000_000, budget_leaf="open", strong_k=2, alpha_iters=100)
_CN = None


def top_tree(cn, k, strong_k=None):
    """The first k levels of the prover's tree: splits chosen by its strong
    branching rule, level by level. Returns the preorder tree (leaves OPEN)
    and the 2^k pieces in preorder."""
    levels = [[np.zeros(cn.d)]]
    splits = []
    for _ in range(k):
        X0 = np.array(levels[-1])
        ivs, clo, chi = cn.intervals(X0)
        var = _choose_split(cn, X0, ivs, 0.5 * clo + 0.5 * chi, strong_k or CFG["strong_k"])
        splits.append([int(v) for v in var])
        nxt = []
        for x0, v in zip(levels[-1], var):
            for s in (-1.0, 1.0):
                x = x0.copy()
                x[int(v)] = s
                nxt.append(x)
        levels.append(nxt)
    tree, pieces = [], []

    def walk(level, j):
        if level == k:
            tree.append((OPEN,))
            pieces.append(levels[k][j])
            return
        tree.append((SPLIT, splits[level][j]))
        walk(level + 1, 2 * j)
        walk(level + 1, 2 * j + 1)

    walk(0, 0)
    return tree, pieces


def _init(name):
    global _CN
    _CN = CertNet(load_net(os.path.join(NETS, name + ".npz")))


def _piece(job):
    idx, x0 = job
    cn = _CN
    t0 = time.time()
    arg, info = prove(cn, ProverConfig(**CFG), root=x0)
    tp = time.time() - t0
    res = verify(cn, arg, rng=np.random.default_rng(idx), root=x0)
    return {"index": idx, "r": int((x0 == 0).sum()), "nodes": info.nodes, "exact": res.exact, "F": res.F,
            "Z_open": res.Z, "demoted": res.demoted, "rejected": res.rejected, "leaves": res.leaves,
            "fpe": res.fpe, "flops_fpe": {k: v / cn.fpe_flops for k, v in res.flops.items()},
            "prover_seconds": tp, "verify_seconds": res.seconds, "exact_evals": res.exact_evals,
            "bytes": res.arg_bytes, "budget_hit": info.budget_hit, "lo": res.lo, "hi": res.hi}


def _mean_se(v, n_total):
    v = np.asarray(v, dtype=float)
    return float(v.mean() * n_total), float(v.std(ddof=1) / math.sqrt(len(v)) * n_total) if len(v) > 1 else math.nan


def main():
    name = sys.argv[1] if len(sys.argv) > 1 else "bce_d64_w64_s1000"
    k = int(sys.argv[2]) if len(sys.argv) > 2 else 10
    budget = float(sys.argv[3]) * 60 if len(sys.argv) > 3 else 100 * 60
    workers = int(sys.argv[4]) if len(sys.argv) > 4 else 3
    out_path = os.path.join(HERE, "results", f"full_d64_{name}.json")
    t_start = time.time()
    cn = CertNet(load_net(os.path.join(NETS, name + ".npz")))
    tree, pieces = top_tree(cn, k)
    chk = verify(cn, {"tree": tree, "samples": 0})  # the top tree parses as a partition of the cube
    assert chk.rejected is None and chk.leaves[OPEN] == 2 ** k and chk.Z == 2 ** cn.d
    t_top = time.time() - t_start
    order = np.random.default_rng(2026).permutation(2 ** k)
    recs = []
    base = {"net": name, "d": cn.d, "widths": cn.widths, "k": k, "pieces_total": 2 ** k, "config": CFG,
            "budget_seconds": budget, "workers": workers, "top_tree_seconds": t_top,
            "machine": "shared 4-core machine (other jobs running concurrently)",
            "seconds_note": "*_worker_seconds: elapsed time inside the worker processes, summed over pieces "
                            "(the workers shared the machine with other jobs, so this exceeds CPU time)",
            "fpe_flops": cn.fpe_flops}

    def dump(final=False):
        done = len(recs)
        rec = dict(base)
        rec["pieces_done"] = done
        rec["wall_seconds"] = time.time() - t_start
        rec["final"] = final
        if done:
            rec["all_exact"] = all(r["exact"] for r in recs)
            rec["F_found"] = int(sum(r["F"] for r in recs))
            rec["fraction_of_cube_certified"] = sum(1 for r in recs if r["exact"]) / 2 ** k
            rec["nodes_done"] = int(sum(r["nodes"] for r in recs))
            rec["fpe_done"] = float(sum(r["fpe"] for r in recs))
            rec["prover_worker_seconds_done"] = float(sum(r["prover_seconds"] for r in recs))
            rec["verify_worker_seconds_done"] = float(sum(r["verify_seconds"] for r in recs))
            if done > 1:
                rec["whole_cube_estimate"] = {
                    "nodes": _mean_se([r["nodes"] for r in recs], 2 ** k),
                    "verifier_fpe": _mean_se([r["fpe"] for r in recs], 2 ** k),
                    "prover_worker_seconds": _mean_se([r["prover_seconds"] for r in recs], 2 ** k),
                    "verify_worker_seconds": _mean_se([r["verify_seconds"] for r in recs], 2 ** k),
                    "note": "mean over the pieces done x 2^k (uniform random order), with its standard error"}
        rec["pieces"] = recs
        json.dump(rec, open(out_path, "w"), indent=1, default=float)

    ctx = mp.get_context("fork")
    with ctx.Pool(workers, initializer=_init, initargs=(name,)) as pool:
        pending = []
        nxt = 0
        while True:
            while nxt < len(order) and len(pending) < 2 * workers and time.time() - t_start < budget:
                j = int(order[nxt])
                pending.append(pool.apply_async(_piece, ((j, pieces[j]),)))
                nxt += 1
            still = []
            for a in pending:
                if a.ready():
                    recs.append(a.get())
                    r = recs[-1]
                    print(f"piece {r['index']:5d} r={r['r']} nodes {r['nodes']:7d} exact {r['exact']} F {r['F']} "
                          f"fpe {r['fpe']:.3g} prover {r['prover_seconds']:.1f}s verify {r['verify_seconds']:.1f}s | "
                          f"{len(recs)} done, {time.time() - t_start:.0f}s", flush=True)
                    if len(recs) % 8 == 0:
                        dump()
                else:
                    still.append(a)
            pending = still
            if not pending and (nxt >= len(order) or time.time() - t_start >= budget):
                break
            time.sleep(0.5)
    dump(final=True)
    print(json.dumps({k_: v for k_, v in json.load(open(out_path)).items() if k_ != "pieces"}, indent=1))


if __name__ == "__main__":
    main()

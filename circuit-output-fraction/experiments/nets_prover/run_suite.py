"""Exact certificates for the suite nets with exact p (d <= 28), checked by
`verify`, compared with Monte Carlo and with enumeration of the cube, in
forward-pass equivalents (fpe) and in wall-clock seconds.

For each net the prover first plans (Knuth estimate of its uncollapsed
'lin' tree from 64 random probes, under the verifier's cost model):
  * if the estimated tree fits in memory (<= NODE_CAP nodes), it builds the
    argument (prove: lin, r_leaf = 5, subtrees replaced by ENUM where that is
    cheaper to verify) and the verifier checks it;
  * if it does not fit but its estimated cost is below PIECE_FRACTION of
    enumeration, the argument is built and checked in pieces (the prover's
    top k levels, then prove/verify(root=piece) per subtree; p = sum of the
    exact piece counts / 2^d);
  * otherwise the prover sends the trivial argument [ENUM]: an exact
    certificate by enumeration (meet in the middle on the first layer).
Every count is exact for the exact-arithmetic net and is compared with the
suite's fail_count (computed in float64; they agree unless a point lies
within float rounding of t).

Costs. Verifier fpe = flops of the verifier as implemented / flops of one
forward pass. Monte Carlo: N = 3 ln(2/delta) / (eps^2 p) samples (eps = 0.1,
delta = 0.05; ratio 1 + eps two-sided) of 1 fpe each; its wall-clock is N
times the measured time per sample of a batched numpy forward pass (2^17
points). Enumeration: fpe of the verifier's meet-in-the-middle sweep; its
wall-clock is measured by verifying [ENUM] on the whole cube. Prover
wall-clock includes its Knuth plan. All times on a shared 4-core machine
with other jobs running (numpy, one BLAS thread per process).

Usage: python3 run_suite.py [names...]  -> results/suite_cert.json (merged per net)
       SUITE_KINDS=lin+quad python3 run_suite.py [names...] -> results/suite_cert_lin+quad.json
       (certificates of both kinds; 'quad' tried on subcubes with >= 6 free inputs)
"""
import fcntl
import json
import math
import os
import sys
import time

os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")

import numpy as np  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
sys.path.insert(0, HERE)
from rareprob.nets import load_net  # noqa: E402
from rareprob.nets_prover import ENUM, CertNet, ProverConfig, knuth_estimate, prove, verify  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
KINDS = tuple(os.environ.get("SUITE_KINDS", "lin").split("+"))
OUT = os.path.join(HERE, "results", "suite_cert.json" if KINDS == ("lin",) else f"suite_cert_{'+'.join(KINDS)}.json")
EPS, DELTA = 0.1, 0.05
NODE_CAP = 2_500_000
PIECE_FRACTION = 0.7
CFG = dict(kinds=KINDS, r_leaf=5, node_budget=4_000_000, open_policy="both", eps=EPS, delta=DELTA,
           strong_k=2, alpha_iters=100, quad_rmin=6, quad_iters=200)


def mc_seconds_per_sample(cn, reps=5):
    X = np.random.default_rng(0).choice([-1.0, 1.0], size=(1 << 17, cn.d))
    ts = []
    for _ in range(reps):
        t0 = time.perf_counter()
        fv = cn.forward(X)
        cn.classify(X, fv)
        ts.append(time.perf_counter() - t0)
    return float(np.median(ts)) / X.shape[0]


def run_pieces(cn, k):
    """Prove and verify the 2^k subtrees below the prover's top k levels."""
    from full_d64 import top_tree
    _, pieces = top_tree(cn, k, CFG["strong_k"])
    F, nodes, fpe, tp, tv, exact, ev, nbytes = 0, 0, 0.0, 0.0, 0.0, True, 0, 0
    for x0 in pieces:
        t0 = time.time()
        arg, info = prove(cn, ProverConfig(**{**CFG, "open_policy": "none"}), root=x0)
        tp += time.time() - t0
        res = verify(cn, arg, root=x0)
        F += res.F
        nodes += info.nodes
        fpe += res.fpe
        tv += res.seconds
        ev += res.exact_evals
        nbytes += res.arg_bytes
        exact &= res.exact
    return {"F": F, "exact": exact, "nodes": nodes + 2 ** k - 1, "fpe": fpe, "prover_seconds": tp,
            "verify_seconds": tv, "exact_evals": ev, "bytes": nbytes, "pieces_k": k}


def main():
    names = sys.argv[1:]
    suite = json.load(open(os.path.join(NETS, "suite.json")))
    for e in suite:
        name = e["name"]
        if e.get("p_exact") is None or (names and name not in names):
            continue
        cn = CertNet(load_net(os.path.join(NETS, name + ".npz")))
        Fsuite, p = int(e["fail_count"]), e["p_exact"]
        enum_fpe = cn.flops_enum(cn.d) / cn.fpe_flops
        t0 = time.time()
        est = knuth_estimate(cn, ProverConfig(kinds=KINDS, r_leaf=5, strong_k=2, alpha_iters=100, quad_rmin=6,
                                              quad_iters=200), probes=64)
        t_plan = time.time() - t0
        if est["nodes"] <= NODE_CAP:
            plan = "certificate"
        elif est["fpe"] < PIECE_FRACTION * enum_fpe:
            plan = "pieces"
        else:
            plan = "enumeration"
        rec = {"d": e["d"], "widths": e["widths"], "loss": e["loss"], "z": e["z"], "p_exact": p,
               "fail_count_suite": Fsuite, "kinds": "+".join(KINDS), "plan": plan, "knuth": est,
               "plan_seconds": t_plan,
               "machine": "shared 4-core machine (other jobs running); numpy, one BLAS thread"}
        print(f"{name}: plan {plan} (Knuth nodes {est['nodes']:.3g}, fpe {est['fpe']:.3g}, enum {enum_fpe:.3g})",
              flush=True)
        hybrid = None
        if plan == "certificate":
            t0 = time.time()
            arg, info = prove(cn, ProverConfig(**CFG))
            tp = time.time() - t0
            res = verify(cn, arg, rng=np.random.default_rng(7))
            ex = {"F": res.F, "exact": res.exact, "nodes": info.nodes, "leaves": res.leaves, "demoted": res.demoted,
                  "fpe": res.fpe, "flops_fpe": {k: v / cn.fpe_flops for k, v in res.flops.items()},
                  "prover_seconds": tp, "verify_seconds": res.seconds, "exact_evals": res.exact_evals,
                  "bytes": res.arg_bytes, "r_hist": info.r_hist, "budget_hit": info.budget_hit,
                  "precollapse": info.precollapse}
            if "hybrid" in arg:
                hres = verify(cn, arg["hybrid"], delta=DELTA, rng=np.random.default_rng(8))
                hybrid = {"lo": hres.lo, "hi": hres.hi, "ratio": hres.ratio, "contains_p": hres.contains(p),
                          "F_exact_part": hres.F, "Z_open": hres.Z, "samples": hres.n_samples,
                          "nodes": info.hybrid.nodes, "fpe": hres.fpe, "verify_seconds": hres.seconds}
        elif plan == "pieces":
            k = max(1, int(math.ceil(math.log2(est["nodes"] / 2e5))))
            ex = run_pieces(cn, k)
        else:
            ex = {"nodes": 1, "prover_seconds": 0.0}
        # enumeration of the whole cube by the verifier (measured)
        eres = verify(cn, {"tree": [(ENUM,)], "samples": 0})
        if plan == "enumeration":
            ex.update({"F": eres.F, "exact": eres.exact, "fpe": eres.fpe, "verify_seconds": eres.seconds,
                       "exact_evals": eres.exact_evals, "bytes": 9})
        assert eres.F == ex["F"]
        spc = mc_seconds_per_sample(cn)
        mc_n = 3 * math.log(2 / DELTA) / (EPS ** 2 * p) if p > 0 else math.inf
        rec.update({
            "exact": ex, "hybrid": hybrid, "match_suite": ex["F"] == Fsuite,
            "prover_seconds_total": t_plan + ex["prover_seconds"],
            "end_to_end_seconds": t_plan + ex["prover_seconds"] + ex["verify_seconds"],
            "enum_fpe": eres.fpe, "enum_seconds": eres.seconds,
            "mc_samples": mc_n, "mc_fpe": mc_n, "mc_seconds_per_sample": spc, "mc_seconds": mc_n * spc,
            "verifier_seconds_per_fpe": ex["verify_seconds"] / ex["fpe"] if ex.get("fpe") else None})
        with open(OUT + ".lock", "w") as lk:  # several runs may share the results file
            fcntl.flock(lk, fcntl.LOCK_EX)
            out = json.load(open(OUT)) if os.path.exists(OUT) else {}
            out[name] = rec
            json.dump(out, open(OUT, "w"), indent=1, default=float)
        print(f"{name:22s} p={p:.3g} F={ex['F']} (suite {Fsuite}) exact={ex['exact']} plan={plan} "
              f"nodes {ex['nodes']} | verifier {ex['fpe']:.3g} fpe {ex['verify_seconds']:.1f}s | prover "
              f"{rec['prover_seconds_total']:.1f}s | MC {mc_n:.3g} fpe {rec['mc_seconds']:.3g}s | "
              f"enum {eres.fpe:.3g} fpe {eres.seconds:.1f}s", flush=True)


if __name__ == "__main__":
    main()

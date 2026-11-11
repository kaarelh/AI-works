"""Identity sample for the d-scaling runs (designed targets at d = 15, 60, 120; eval_dfg.py designed_d<d>): seed-0
refits at every n of two targets per d, compared with part11/results/toy__dfg13-perm__designed_d<d>.json (test error
and FLOPs, exact).  usage: OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python identity_dscale.py
writes results/identity/designed_d<d>__<target>.json"""
import os, sys, json
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import dfg_hooks as H                                                  # noqa: E402

SAMPLE = [(15, "maj9"), (15, "mux"), (60, "majpar"), (60, "stair5"), (120, "par3"), (120, "mux")]
OUT = os.path.join(HERE, "results", "identity")

if __name__ == "__main__":
    for d, name in SAMPLE:
        R = json.load(open(os.path.join(H.RESULTS, f"toy__dfg13-perm__designed_d{d}.json")))
        T = H.targets("designed", d); b = R["seeds"].index(0); cells = []
        for a, n in enumerate(R["ns"]):
            r = H.fit_toy_dfg("designed", name, n, 0, d=d, T=T)
            ef, ff = R["fns"][name]["err"][a][b], R["fns"][name]["flops"][a][b]
            cells.append(dict(n=n, err=r["err"], flops=r["flops"], err_file=ef, flops_file=ff,
                              err_equal=bool(ef == r["err"]), flops_equal=bool(ff == r["flops"]), variant=r["variant"],
                              size=r["size"], lead=[(t["desc"], round(t["share"], 3)) for t in r["terms"][:4]]))
            print(d, name, n, r["err"], ef, cells[-1]["err_equal"], cells[-1]["flops_equal"], flush=True)
        json.dump(dict(suite=f"designed_d{d}", target=name, d=d, seed=0, cells=cells),
                  open(os.path.join(OUT, f"designed_d{d}__{name}.json"), "w"), indent=1)

"""Identity sample beyond the atlas: seed-0 refits of DFG alone (dfg_hooks.fit_toy_dfg) at every n of the grid for a
few targets of the suites the atlas covers thinly (dlheld2 and dlfamdev have no atlas target), so that every one of the
11 suites has refitted cells to compare with its merged evaluation file (atlas_make.identity_all does the comparison).
usage: OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python identity_run.py      writes results/identity/<suite>__<target>.json"""
import os, sys, json, time
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import dfg_hooks as H                                                  # noqa: E402

SAMPLE = [("dlheld2", "maj21"), ("dlheld2", "sym8"), ("dlfamdev", "fd_09"), ("dlfamdev", "fd_10"), ("random", "rf11"),
          ("dlsymdev", "sym7"), ("dlheld4", "symxor"), ("dlheld5", "h5t0"), ("dlheld6", "h6_10"), ("dlheld2", "xmaj")]
OUT = os.path.join(HERE, "results", "identity"); os.makedirs(OUT, exist_ok=True)

if __name__ == "__main__":
    Tc = {}
    for suite, name in SAMPLE:
        p = os.path.join(OUT, f"{suite}__{name}.json")
        res = json.load(open(p)) if os.path.exists(p) else dict(suite=suite, target=name, seed=0, cells=[])
        done = {c["n"] for c in res["cells"]}; T = Tc.setdefault(suite, H.targets(suite))
        for n in H.TH.NS:
            if n in done:
                continue
            t0 = time.process_time(); r = H.fit_toy_dfg(suite, name, n, 0, T=T)
            res["cells"].append(dict(n=n, err=r["err"], flops=r["flops"], variant=r["variant"], cv_errs=r["cv_errs"],
                                     size=r["size"], cpu=round(time.process_time() - t0, 2),
                                     lead=[(t["desc"], round(t["share"], 3)) for t in r["terms"][:4]]))
            json.dump(res, open(p + ".tmp", "w")); os.replace(p + ".tmp", p)
            print(f"{suite}/{name} n={n} err={r['err']:.4f} identity={H.check_identity(r)}", flush=True)

"""Export the networks' final test errors (per suite, variant, target: err[n][seed] on the harness grid) from the network
result directories to results/nets_final_err.json, so that compare_hybrid.py can rebuild the toy tables from the repository
alone (the .npz result directories are not committed).  usage: python nets_export.py"""
import os, sys, json, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import compare_hybrid as CH
out = {}
for suite, _ in CH.TOY_SUITES:
    for ref_name, suf in CH.NET_VARIANTS:
        d = CH.net_dir(suite, suf)
        if not os.path.isdir(d):
            continue
        for f in sorted(os.listdir(d)):
            if f.startswith("fixed_adam_") and f.endswith(".npz"):
                fn = f[len("fixed_adam_"):-4]
                e = CH.TH.nn_reference(fn, d)
                out.setdefault(suite, {}).setdefault(ref_name, {})[fn] = np.where(np.isnan(e), None, e).tolist()
json.dump(dict(ns=CH.TH.NS, err=out), open(os.path.join(HERE, "results", "nets_final_err.json"), "w"))
print({s: {v: len(t) for v, t in d.items()} for s, d in out.items()})

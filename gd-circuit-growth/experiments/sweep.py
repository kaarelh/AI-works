import attach, json, numpy as np, sys
res = []
for arch in ["mlp", "paths"]:
    for alpha in [0.3, 0.1, 0.03, 0.01, 0.003, 0.001]:
        for seed in range(5):
            o = attach.run(arch, alpha, seed, tmax=60000.0)
            res.append({k: o[k] for k in ("arch", "alpha", "seed", "T1", "T2")})
            print(json.dumps(res[-1]), flush=True)
json.dump(res, open("attach_results.json", "w"), indent=1)

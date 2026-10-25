"""Rate ~ utility check: at fixed depth 3 and alpha, vary the coefficient B of x2*x3
(the residual, hence the attach move's utility, is proportional to B) and record the
second-feature delay dT = T2 - T1.  Prediction: dT ~ 1/B for both architectures."""
import deep, numpy as np
print(f"{'arch':6} {'B':>5} {'dT med':>9} {'B*dT':>8}")
for arch in ("mlp", "paths"):
    for B in (0.1, 0.2, 0.4, 0.8):
        dts = []
        for seed in range(3):
            o = deep.run(arch, 0.01, seed, L=3, B=B, tmax=2e5)
            dts.append(o["T2"] - o["T1"])
        m = np.median(dts)
        print(f"{arch:6} {B:5.2f} {m:9.1f} {B*m:8.1f}", flush=True)

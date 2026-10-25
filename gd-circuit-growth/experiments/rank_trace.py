"""Trace loss, the two Fourier coefficients, and the participation-ratio rank of each
hidden layer's centred kernel during one small-init run (depth 3, alpha = 0.003)."""
import deep, numpy as np
for arch in ("mlp", "paths"):
    o = deep.run(arch, 0.003, 0, L=3, rec_every=200)
    print(arch, "T1=%.0f T2=%.0f" % (o["T1"], o["T2"]))
    print("      t    loss  c(x1) c(x2x3) PR(h1) PR(h2)")
    lg = o["log"]
    for i in sorted(set(np.linspace(0, len(lg) - 1, 14).astype(int))):
        e = lg[i]
        print(f"{e['t']:7.0f} {e['loss']:7.4f} {e['c1']:6.3f} {e['c23']:6.3f} {e['pr1']:7.2f} {e['pr2']:6.2f}")

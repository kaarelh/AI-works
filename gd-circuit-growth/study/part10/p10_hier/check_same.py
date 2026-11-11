"""Non-image inputs: p10_hier must give v2's predictions and FLOP count exactly (the gates block is skipped there).
Dev data only.  usage: python check_same.py [dataset] [n]   (default optdigits 300; also run on the toy designed suite
by the toy harness if wanted)."""
import os, sys, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); P10 = os.path.dirname(HERE); P9 = os.path.join(os.path.dirname(P10), "part9")
sys.path.insert(0, P10); sys.path.insert(0, P9)
import p10_hier.learner as NEW
import hyb_portfolio2.learner as V2
DATA = NEW.common.SH.DATA
ds = sys.argv[1] if len(sys.argv) > 1 else "optdigits"; n = int(sys.argv[2]) if len(sys.argv) > 2 else 300
D = DATA.load(ds); pool, te = DATA.splits(D, 0); tr = pool[:n]
out = []
for M in (V2, NEW):
    f = M.Learner().fit(D["X"][tr], D["y"][tr], list(D["types"]), D["C"], np.random.default_rng([0, n, 4242]))
    out.append((np.asarray(f["predict"](D["X"][te])), f["flops"]))
same = np.array_equal(out[0][0], out[1][0]) and out[0][1] == out[1][1]
print(f"{ds} n={n}: predictions identical {np.array_equal(out[0][0], out[1][0])}, flops {out[0][1]:.6g} / {out[1][1]:.6g} -> {'SAME' if same else 'DIFFERENT'}")

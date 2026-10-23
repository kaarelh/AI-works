"""Per-function behavioural comparison of the saved SSWM eval with NN-Adam: n*, curves, seed-to-seed agreement."""
import os, sys
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import numpy as np, common as C
E = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals"
res = C.load_eval(f"{E}/sswm.npz")
ns = np.array(res["ns"])
print("fn          split  n*(NN)  n*(sswm)  log2ratio | NN curve / sswm curve (seed means) | sizes")
rows = []
for fn in C.FNS:
    m_err = res["test_err"][fn].mean(1)
    have = os.path.exists(os.path.join(C.RESULTS, f"fixed_adam_{fn}.npz"))
    sz = np.nanmedian(res["size"][fn], 1); tm = np.nanmedian(res["time"][fn], 1)
    if have:
        nn = C.nn_fixed(fn); nn_err = nn["test_err"].mean(1)
        a, b = C.sample_complexity(ns, nn_err), C.sample_complexity(ns, m_err)
        lr = np.log2(min(b, 2 * ns.max()) / min(a, 2 * ns.max()))
    else:
        nn_err = np.full(len(ns), np.nan); a = b = np.nan; lr = np.nan; b = C.sample_complexity(ns, m_err)
    split = "CAL" if fn in C.CALIB else "HELD"
    print(f"{fn:11s} {split:5s} {a:7.0f} {b:8.0f} {lr:+6.2f}  NN " + " ".join(f"{v:.2f}" for v in nn_err))
    print(f"{'':38s} M  " + " ".join(f"{v:.2f}" for v in m_err) + "   size " + " ".join(f"{v:.0f}" for v in sz))
    print(f"{'':38s} t  " + " ".join(f"{v:.0f}" for v in tm))
# seed-to-seed agreement in partial cells: model vs NN
print("\nseed-to-seed agreement in NN-partial cells (0.05<=NN err<=0.45):  NN-NN | sswm-sswm | NN-sswm | indep")
for fn in C.FNS:
    if not os.path.exists(os.path.join(C.RESULTS, f"fixed_adam_{fn}.npz")):
        continue
    nn = C.nn_fixed(fn)
    for a, n in enumerate(ns):
        e = nn["test_err"][a]
        if 0.05 <= e.mean() <= 0.45:
            P = nn["pred"][a]; Q = res["pred"][fn][a]
            pp = np.mean([np.mean(P[i] == P[j]) for i in range(3) for j in range(i + 1, 3)])
            qq = np.mean([np.mean(Q[i] == Q[j]) for i in range(3) for j in range(i + 1, 3)])
            pq = np.mean([np.mean(P[i] == Q[j]) for i in range(3) for j in range(3)])
            pq_same = np.mean([np.mean(P[i] == Q[i]) for i in range(3)])
            em = res["test_err"][fn][a].mean(); en = e.mean()
            ind = (1 - en) * (1 - em) + en * em
            print(f"  {fn:10s} n={n:5d} errNN {en:.2f} errM {em:.2f} | {pp:.3f} | {qq:.3f} | {pq:.3f} (same data {pq_same:.3f}) | {ind:.3f}")

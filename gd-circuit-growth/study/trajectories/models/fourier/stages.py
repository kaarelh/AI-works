"""Print the predicted sequence of learned functions (the stages) for a target: every fired move with its time, type,
strength and the characters it brings in, and the final learned fraction of each character per condition.

    python stages.py <fn> [<fn> ...]
"""
import os, sys
os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import model as M


def name(m, R):
    return "x" + "x".join(str(R[i] + 1) for i in range(len(R)) if (m >> i) & 1) if m else "1"


def describe(fn, max_chars=8):
    sp = M.spectrum(fn); R = sp["R"]; yh = sp["yhat"]
    print(f"=== {fn}: {M.suite()[fn]['desc']}  (relevant {[i + 1 for i in R]}, {int(np.sum(yh[1:] != 0))} characters)")
    if yh[0]:
        print(f"  constant {yh[0]:+.3f}: learned by step ~{M.PARAMS['TAU'] / np.sqrt(M.D):.0f} (readout bias)")
    for cond in ["online", "2048", "512"]:
        n = None if cond == "online" else int(cond)
        tg, phi, ev = M.simulate(sp, n, return_events=True)
        print(f"  -- {cond}")
        for e in ev:
            k = e["key"]
            if k[0] == "X":
                kind = ("linear stage" if k[1] == 0 and e["e"] == 1 else
                        f"new {e['e']}-input feature" if k[1] == 0 else f"{name(k[1], R)} x {e['e']} input(s)")
            elif k[0] == "D":
                kind = "bundle x 1 input"
            else:
                kind = "junta completion"
            mem = sorted(e["members"], key=lambda m: -abs(yh[m]))
            txt = ", ".join(f"{name(m, R)}({yh[m]:+.3g})" for m in mem[:max_chars]) + (f", ... ({len(mem)} chars)" if len(mem) > max_chars else "")
            print(f"    t={e['t']:7.0f}  {kind:28s} rho={e['rho']:.2f} level={e['level']:.2f}  {txt}")
        fin = phi[-1]
        never = [m for m in range(1, len(yh)) if yh[m] and fin[m] < 0.5]
        if never:
            print(f"    below half-learned at step 20000: {len(never)} chars, e.g. " +
                  ", ".join(f"{name(m, R)}({fin[m]:.2f})" for m in never[:6]))


if __name__ == "__main__":
    for fn in sys.argv[1:] or ["sparsepoly"]:
        describe(fn)

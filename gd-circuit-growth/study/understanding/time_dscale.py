"""Networks' time to generalise against d: median steps to test error <= 0.1 over cells with n >= 2 n*(d) and n <= 65536,
and over the fixed n in {4096, 8192, 16384} where they generalise."""
import os, sys, numpy as np, importlib
sys.path.insert(0, "/home/user/AI-works/gd-circuit-growth/study")
SP = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad"
FNS = ["par2", "par3", "par4", "stair5", "mux", "majpar", "maj9"]
import common as C
def load(fn, d):
    C.RESULTS = SP + "/results" + ("" if d == 30 else f"_d{d}")
    return C.nn_fixed(fn)
print("| target | n* d=15/30/60 | median steps, n >= 2n*: d=15 / 30 / 60 | ratio 30/15, 60/30 | at n=16384: 15/30/60 |")
for fn in FNS:
    out, ns_, fix = [], [], []
    for d in (15, 30, 60):
        z = load(fn, d); ns = z["ns"]; e = z["test_err"].mean(1)
        nst = C.sample_complexity(ns, e); ns_.append(nst)
        sel = (ns >= 2 * nst)
        s = z["steps_to_gen"][sel]; s = s[np.isfinite(s)]
        out.append(np.median(s) if len(s) else np.nan)
        j = list(ns).index(16384); s16 = z["steps_to_gen"][j]; fix.append(np.median(s16))
    print(f"| {fn} | {' / '.join(f'{v:.0f}' for v in ns_)} | {' / '.join(f'{v:.0f}' for v in out)} | "
          f"{out[1]/out[0]:.2f}, {out[2]/out[1]:.2f} | {' / '.join(f'{v:.0f}' for v in fix)} |")

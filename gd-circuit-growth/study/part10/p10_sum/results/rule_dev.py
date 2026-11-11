"""Integration-rule numbers: n* of p10_sum vs v2 (designed, dlsymdev: p9_sum-perm = v2 on toy; dlfamdev: hyb_portfolio2-perm)."""
import os, sys, json, numpy as np, importlib.util
R = "/home/user/AI-works/gd-circuit-growth/study/hybrid/results/"
sp = importlib.util.spec_from_file_location("TH", "/home/user/AI-works/gd-circuit-growth/study/discrete_learner/harness.py")
TH = importlib.util.module_from_spec(sp); sp.loader.exec_module(TH)
ref = {"designed": "p9_sum-perm", "dlsymdev": "p9_sum-perm", "dlfamdev": "hyb_portfolio2-perm"}
me = sys.argv[1] if len(sys.argv) > 1 else "p10_sum-perm"
rows = []
for su in ["designed", "dlsymdev", "dlfamdev"]:
    fa, fb = R + f"toy__{me}__{su}.json", R + f"toy__{ref[su]}__{su}.json"
    if not (os.path.exists(fa) and os.path.exists(fb)):
        print("missing", su, os.path.exists(fa), os.path.exists(fb)); continue
    A, B = json.load(open(fa)), json.load(open(fb))
    for fn in B["fns"]:
        if fn not in A["fns"]:
            continue
        ea, eb = np.array(A["fns"][fn]["err"]), np.array(B["fns"][fn]["err"])
        na, nb = TH.nstar(A["ns"], ea.mean(1)), TH.nstar(B["ns"], eb.mean(1))
        fa_ = np.nanmax(np.array(A["fns"][fn]["flops"])) / A["gd_flops"]; ca = np.array(A["fns"][fn]["cpu_seconds"]); cb = np.array(B["fns"][fn]["cpu_seconds"])
        rows.append((su, fn, na, nb, fa_, ca.sum(), cb.sum(), ca.max()))
fin = [(r[2], r[3]) for r in rows if np.isfinite(r[2]) and np.isfinite(r[3])]
l2 = [np.log2(a / b) for a, b in fin]
print(f"{'suite':9s} {'target':10s} {'n* p10':>8s} {'n* v2':>8s} {'log2':>7s} {'maxFL/GD':>8s} {'cpu p10':>8s} {'cpu v2':>8s} {'max cpu/fit':>11s}")
for su, fn, na, nb, f_, ca, cb, cm in rows:
    l = np.log2(na / nb) if np.isfinite(na) and np.isfinite(nb) else (0.0 if na == nb else (-np.inf if np.isfinite(na) else np.inf))
    print(f"{su:9s} {fn:10s} {na:8.0f} {nb:8.0f} {l:+7.2f} {f_:8.3f} {ca:8.0f} {cb:8.0f} {cm:11.1f}")
both_inf = sum(1 for r in rows if not np.isfinite(r[2]) and not np.isfinite(r[3]))
print(f"targets {len(rows)}; both finite {len(fin)}; both never {both_inf}; mean log2 ratio over finite {np.mean(l2):+.4f}; "
      f"mean over all (never=never counted 0) {np.sum(l2) / (len(fin) + both_inf):+.4f}; max increase {max(l2):+.3f}; min {min(l2):+.3f}")

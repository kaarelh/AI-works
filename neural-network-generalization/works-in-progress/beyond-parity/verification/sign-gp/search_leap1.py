"""Search Boolean juntas on k=4 (exhaustive) and k=5 (random) bits for leap-1
(merged-staircase) functions with high threshold degree.  Writes search_leap1.json."""
import json, sys, time
import numpy as np
sys.path.insert(0, __file__.rsplit("/", 1)[0])
from common import cube, fourier_profile, leap, threshold_degree, sign_rep_feasible, popcount

out = {}
t0 = time.time()
# ---- exhaustive k = 4
k = 4
X = cube(k)
counts = {}
best4 = []
for code in range(2 ** (2 ** k)):
    f = np.array([1 - 2 * ((code >> i) & 1) for i in range(2 ** k)])
    c, supp, w, deg = fourier_profile(f, k)
    U = 0
    for m in supp:
        U |= m
    if U != 2 ** k - 1:
        continue  # must depend on all 4 coordinates
    lp = leap(supp)
    if lp != 1:
        continue
    if sign_rep_feasible(f, k, 1):
        td = 1
    elif sign_rep_feasible(f, k, 2):
        td = 2
    else:
        td = threshold_degree(f, k)
    counts[td] = counts.get(td, 0) + 1
    if td >= 3:
        best4.append(dict(code=code, f=f.tolist(), td=td, deg=deg, weight=w.tolist(), mean=float(f.mean()),
                          deg1_weight=float(w[1])))
out["k4_leap1_all_vars_threshold_degree_counts"] = {str(a): b for a, b in sorted(counts.items())}
out["k4_leap1_td>=3_count"] = len(best4)
# choose a balanced one with td>=3, preferring max threshold degree, then balance, then small mean |f|
best4.sort(key=lambda r: (-r["td"], abs(r["mean"]), -r["deg1_weight"]))
out["k4_examples"] = best4[:10]
print("k=4 done", time.time() - t0, counts, len(best4), flush=True)

# ---- random search k = 5 for leap-1 with td >= 4
k = 5
rng = np.random.default_rng(12345)
found5 = []
tried = 0
td_counts5 = {}
while tried < 4000:
    tried += 1
    f = rng.choice([-1, 1], size=2 ** k)
    c, supp, w, deg = fourier_profile(f, k)
    if leap(supp) != 1:
        continue
    U = 0
    for m in supp:
        U |= m
    if U != 2 ** k - 1:
        continue
    td = threshold_degree(f, k)
    td_counts5[td] = td_counts5.get(td, 0) + 1
    if td >= 4:
        found5.append(dict(f=f.tolist(), td=td, deg=deg, weight=w.tolist(), mean=float(f.mean())))
out["k5_random_tried"] = tried
out["k5_random_leap1_td_counts"] = {str(a): b for a, b in sorted(td_counts5.items())}
out["k5_examples_td>=4"] = found5[:5]
print("k=5 done", time.time() - t0, td_counts5, len(found5), flush=True)
json.dump(out, open(__file__.rsplit("/", 1)[0] + "/search_leap1.json", "w"), indent=1)

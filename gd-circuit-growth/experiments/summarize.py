"""Tabulate first-feature time T1 and second-feature delay dT = T2 - T1 (medians over seeds),
and fit log-log slopes of each against 1/alpha.  Usage: python3 summarize.py results.json"""
import json, sys, numpy as np
R = json.load(open(sys.argv[1]))
L = R[0].get("L", 3)
print(f"depth L = {L}  (fresh-circuit prediction: time ~ alpha^-(L-2) = alpha^-{L-2})")
print(f"{'arch':6} {'alpha':>6} {'T1':>9} {'dT':>9} {'dT/log^2(1/a)':>14}")
for arch in ("mlp", "paths"):
    rows = []
    for a in sorted({r["alpha"] for r in R}, reverse=True):
        rs = [r for r in R if r["arch"] == arch and r["alpha"] == a]
        T1 = np.median([r["T1"] for r in rs])
        dT = np.median([(r["T2"] if r["T2"] is not None else np.inf) - r["T1"] for r in rs])
        rows.append((a, T1, dT))
        print(f"{arch:6} {a:6.3f} {T1:9.1f} {dT:9.1f} {dT/np.log(1/a)**2:14.2f}")
    a, T1, dT = map(np.array, zip(*rows))
    s1 = np.polyfit(np.log(1 / a), np.log(T1), 1)[0]
    k = len(a) // 2  # slope over the smaller-alpha half, closer to the asymptotic regime
    s2 = np.polyfit(np.log(1 / a[k:]), np.log(dT[k:]), 1)[0]
    print(f"{arch:6} slope d log T1 / d log(1/a) = {s1:.2f};  slope of dT (small-alpha half) = {s2:.2f}")

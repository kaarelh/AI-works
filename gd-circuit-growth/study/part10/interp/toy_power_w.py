"""Detection power of the TRUE weighted block u = t + a*tau for the weighted toy targets, under DFG v1.3's test, and the
same for the unit-weight part t alone.  (Descriptive; complements toy_power.py, which tests the largest unit-weight class.)
At each n of the grid (seed-0 training rows of eval_toy), round 0 (r = y - mean y):
  T = |projection of r onto the level indicators of u (or |u|; groups merged as DFG merges them)|^2 / s^2,
  threshold = chi^2_m tail at exp(-t), t = tk(|S|) + ln_inner(d) for the weighted block (v1.3's union bound over every
  (S, s), fold, modulator count 1, size, and every inner term a*tau), t = tk(|S|) for the unit-weight block t.
usage: python toy_power_w.py        writes $INTERP_OUT/toy_power_w/<suite>__<target>.json"""
import os, sys, json, math, importlib.util, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import hooks as H
sp = importlib.util.spec_from_file_location("dfg13_p", os.path.join(os.path.dirname(HERE), "hyb_portfolio3", "dfg13.py"))
saved = sys.modules.get("harness"); sys.modules["harness"] = H.TH
DF = importlib.util.module_from_spec(sp); sp.loader.exec_module(DF)
if saved is not None:
    sys.modules["harness"] = saved
else:
    del sys.modules["harness"]
d, K, KM, delta = 30, 4, 24, 0.1
# (suite, target, unit-weight inputs S with signs, a, tau inputs)  - from the target definitions in boolfuncs.py / FAMILY.md
W = [("dlsymdev", "thrsum", list(range(6)), [1] * 6, 3, [6, 7]),
     ("dlheld6", "h6_10", list(range(12)), [1] * 12, -3, [12]),
     ("dlheld7", "f7_10", list(range(5)), [1] * 5, 2, [5]),
     ("dlheld5", "h5t0", list(range(7)), [-1, 1, 1, 1, 1, -1, 1], 2, [7, 8]),
     ("dlheld5", "h5t1", list(range(5)), [1, -1, 1, -1, 1], 2, [5, 6])]
out_dir = os.path.join(os.environ.get("INTERP_OUT", os.path.join(HERE, "results")), "toy_power_w"); os.makedirs(out_dir, exist_ok=True)


def test(stat, r, s2, n, t):
    E = DF._edges(stat, max(3, int(0.005 * n))); g = np.searchsorted(E, stat)
    Tv, lev = DF._multi_T(g[:, None], r, len(E) + 1); m = max(int(lev[0]) - 1, 1); thr = DF._chi2_thr(m, t)
    return dict(T=round(float(Tv[0]) / s2, 2), thr=round(thr, 2), ratio=round(float(Tv[0]) / s2 / thr, 3), levels=int(lev[0]))


for su, tg, S, sg, a, tau in W:
    T = H.targets(su)[tg]; k = len(S)
    tk = math.log(4 * K * math.comb(d, k) * 2.0 ** (k - 1) * 2 * 1 * KM / delta); tw = tk + DF._ln_inner(d)
    res = dict(suite=su, target=tg, desc=T["desc"], S=S, signs=sg, a=a, tau=tau, tk=tk, tk_weighted=tw, cells=[])
    for n in H.TH.NS:
        X, y = H.TH.train_data(T["fn"], tg, 0, n, d); X = np.asarray(X, float); y = np.asarray(y, float)
        r = y - y.mean(); s2 = float(np.mean(r * r)) or 1.0
        t = X[:, S] @ np.asarray(sg, float); u = t + a * np.prod(X[:, tau], 1)
        c = dict(n=n, weighted=test(u, r, s2, n, tw), weighted_fold=test(np.abs(u), r, s2, n, tw),
                 unit=test(t, r, s2, n, tk), unit_fold=test(np.abs(t), r, s2, n, tk))
        res["cells"].append(c)
        print(tg, n, {kk: v["ratio"] for kk, v in c.items() if kk != "n"}, flush=True)
    json.dump(res, open(os.path.join(out_dir, f"{su}__{tg}.json"), "w"), indent=1)

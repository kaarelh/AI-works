"""The block-statistic landscape around the TRUE block of a toy target: how much of DFG's test statistic survives when
the candidate is the true block with a few errors.  (Descriptive; why a local / greedy search does or does not reach S.)
At n (seed-0 training rows of eval_toy; round 0, r = y - mean y), for the largest true signed-symmetry class (S, s):
  T / threshold (best of unfolded and folded; threshold of DFG's test for the candidate's own size, v1.2 = v1.3
  unweighted union bound) for
    true      the true block
    drop_j    S minus j random inputs                       (j = 1..4; 200 draws each: median and max)
    add_j     S plus j random other inputs                  (j = 1..3)
    flip_j    S with j signs flipped                        (j = 1..3)
    mixed     j1 dropped, j2 added, j3 flipped, j1+j2+j3 = 3 (200 draws)
    random_k  random (S', s') of size |S|                   (200 draws)
    pairs_in  every pair inside S with its true relative sign (max), singles_in: every single input of S (max)
usage: python toy_landscape.py <suite>:<target>:<n> [...]     writes $INTERP_OUT/toy_landscape/<suite>__<target>__n<n>.json"""
import os, sys, json, math, itertools, importlib.util, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import hooks as H
sp = importlib.util.spec_from_file_location("dfg13_l", os.path.join(os.path.dirname(HERE), "hyb_portfolio3", "dfg13.py"))
saved = sys.modules.get("harness"); sys.modules["harness"] = H.TH
DF = importlib.util.module_from_spec(sp); sp.loader.exec_module(DF)
if saved is not None:
    sys.modules["harness"] = saved
else:
    del sys.modules["harness"]
d, K, KM, delta, M = 30, 4, 24, 0.1, 200
out_dir = os.path.join(os.environ.get("INTERP_OUT", os.path.join(HERE, "results")), "toy_landscape"); os.makedirs(out_dir, exist_ok=True)
tk = lambda k: math.log(4 * K * math.comb(d, k) * 2.0 ** (k - 1) * 2 * 1 * KM / delta)

for job in [a for a in sys.argv[1:] if not a.startswith("--")]:
    su, tg, n = job.split(":"); n = int(n); T = H.targets(su)[tg]
    c = sorted(H.symmetry_classes(T["fn"], T["relevant"]), key=lambda c: -len(c["S"]))[0]
    S = list(c["S"]); sg = [s if s is not None else 1 for s in c["signs"]]; k = len(S)
    X, y = H.TH.train_data(T["fn"], tg, 0, n, d); X = np.asarray(X, float); y = np.asarray(y, float)
    r = y - y.mean(); s2 = float(np.mean(r * r)); mc = max(3, int(0.005 * n)); rng = np.random.default_rng([7, n])

    def ratio(Sv, sv):
        t = X[:, Sv] @ np.asarray(sv, float); best = 0.0
        for st in (t, np.abs(t)):
            E = DF._edges(st, mc); g = np.searchsorted(E, st); Tv, lev = DF._multi_T(g[:, None], r, len(E) + 1)
            best = max(best, float(Tv[0]) / s2 / DF._chi2_thr(max(int(lev[0]) - 1, 1), tk(len(Sv))))
        return best

    def summ(v):
        v = np.asarray(v, float)
        return dict(median=round(float(np.median(v)), 4), q90=round(float(np.quantile(v, 0.9)), 4), max=round(float(v.max()), 4), frac_gt1=round(float(np.mean(v > 1)), 3))
    others = [i for i in range(d) if i not in S]
    res = dict(suite=su, target=tg, n=n, seed=0, S=S, signs=sg, k=k, true=round(ratio(S, sg), 3))
    for j in range(1, 5):
        v = []
        for _ in range(M):
            keep = sorted(rng.choice(k, k - j, replace=False)); v.append(ratio([S[q] for q in keep], [sg[q] for q in keep]))
        res[f"drop_{j}"] = summ(v)
    for j in range(1, 4):
        v = []
        for _ in range(M):
            ex = list(rng.choice(others, j, replace=False)); v.append(ratio(S + ex, sg + list(rng.choice([-1, 1], j))))
        res[f"add_{j}"] = summ(v)
        v = []
        for _ in range(M):
            fl = set(rng.choice(k, j, replace=False).tolist()); v.append(ratio(S, [-s if q in fl else s for q, s in enumerate(sg)]))
        res[f"flip_{j}"] = summ(v)
    v = []
    for _ in range(M):
        j1, j2 = int(rng.integers(0, 4)), 0; j2 = int(rng.integers(0, 4 - j1)); j3 = 3 - j1 - j2
        keep = sorted(rng.choice(k, k - j1, replace=False)); Sv = [S[q] for q in keep]; sv = [sg[q] for q in keep]
        fl = set(rng.choice(len(Sv), min(j3, len(Sv)), replace=False).tolist()); sv = [-s if q in fl else s for q, s in enumerate(sv)]
        ex = list(rng.choice(others, j2, replace=False)); v.append(ratio(Sv + ex, sv + list(rng.choice([-1, 1], j2))))
    res["mixed_3"] = summ(v)
    v = [ratio(sorted(rng.choice(d, k, replace=False).tolist()), list(rng.choice([-1, 1], k))) for _ in range(M)]
    res["random_k"] = summ(v)
    res["pairs_in_max"] = round(max(ratio([S[a], S[b]], [sg[a], sg[b]]) for a, b in itertools.combinations(range(k), 2)), 4)
    res["singles_in_max"] = round(max(ratio([S[a]], [1]) for a in range(k)), 4)
    res["pairs_out_max"] = round(max(ratio([a, b], [1, s]) for a, b in itertools.combinations(others[:12], 2) for s in (1, -1)), 4)
    json.dump(res, open(os.path.join(out_dir, f"{su}__{tg}__n{n}.json"), "w"), indent=1)
    print(tg, n, "true", res["true"], {kk: v["median"] for kk, v in res.items() if isinstance(v, dict)}, "pairs_in", res["pairs_in_max"],
          "singles", res["singles_in_max"], "pairs_out", res["pairs_out_max"], flush=True)

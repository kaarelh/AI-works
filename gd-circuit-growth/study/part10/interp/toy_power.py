"""Why does DFG miss a sum-structured target?  Detection power against search reach.  (Descriptive analysis.)
For a toy target and its largest true signed-symmetry class (S, s) (hooks.symmetry_classes), at each n of the grid
(training rows of eval_toy, seed 0):
  test     the block test DFG v1.2 would apply to the TRUE block if it were proposed in round 0: the statistic
           T = |projection of the centred labels onto the level indicators of t = sum_S s_i x_i (unfolded and folded;
           levels merged as DFG merges them, >= max(3, 0.005 n) points each)|^2 / s^2, against DFG's threshold
           chi^2_{m}(exp(-tk(|S|))) with tk the union bound over every (S, s) of that size, both folds, one modulator
           (dfg12.py: K = 4, sum_kmax = 24, delta = 0.1); ratio = T / threshold (> 1: the true block would be accepted)
  modulated  the same test on r * chi_M for the best modulator M among the target's other relevant inputs (|M| <= 3;
           threshold with the union bound over 5 modulators, as DFG uses at most sum_mod = 4 plus none)
  search   whether the candidate orders of DFG's block search reach S: the fraction of S among the top |S| inputs by
           |mean(y x_i)| (degree-1 order) and by |u_i| for the top-2 eigenvectors u of the pair matrix mean(y x_i x_j)
           with zero diagonal (pair order); 1.0 = the order lists S first, so a prefix of it IS the true block; *_k5: the
           fraction of S among the top |S| + 5 (DFG's greedy growth and local refinement can repair a few misses)
  fourier  the target's exact Fourier weight by degree (W_k = sum over |T| = k of fhat(T)^2), which sets the expected
           size of those degree-1 and pair signals
usage: python toy_power.py <suite> <target>[,<target>...]     writes results/toy_power/<suite>__<target>.json"""
import os, sys, json, math, itertools, importlib.util, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import hooks as H
sp = importlib.util.spec_from_file_location("dfg12_p", os.path.join(H.STUDY, "part9", "p9_sum", "dfg12.py"))
saved = sys.modules.get("harness"); sys.modules["harness"] = H.TH
DF = importlib.util.module_from_spec(sp); sp.loader.exec_module(DF)
if saved is not None:
    sys.modules["harness"] = saved
else:
    del sys.modules["harness"]

suite, names = sys.argv[1], sys.argv[2].split(",")
T = H.targets(suite); d = 30; K, KM, delta = 4, 24, 0.1
out_dir = os.path.join(os.environ.get("INTERP_OUT", os.path.join(HERE, "results")), "toy_power"); os.makedirs(out_dir, exist_ok=True)


def block_T(X, r, S, sg, fold, n):
    t = X[:, S] @ sg; t = np.abs(t) if fold else t
    E = DF._edges(t, max(3, int(0.005 * n))); g = np.searchsorted(E, t)
    Tv, lev = DF._multi_T(g[:, None], r, len(E) + 1)
    return float(Tv[0]), int(lev[0])


for name in names:
    t = T[name]; cls = sorted(H.symmetry_classes(t["fn"], t["relevant"]), key=lambda c: -len(c["S"]))
    if not cls:
        print(name, "no symmetry class"); continue
    c = cls[0]; S = np.array(c["S"]); sg = np.array([s if s is not None else 1 for s in c["signs"]], float); k = len(S)
    rest = [i for i in t["relevant"] if i not in c["S"]]
    F = H.fourier(t["fn"], t["relevant"]); W = np.zeros(len(t["relevant"]) + 1)
    for kk, v in F.items():
        W[len(kk)] += v * v
    tk = math.log(4 * K * math.comb(d, k) * 2.0 ** (k - 1) * 2 * 1 * KM / delta)
    res = dict(suite=suite, target=name, desc=t["desc"], cls=c, k=k, tk=tk, fourier_by_degree=[round(float(w), 5) for w in W], cells=[])
    for n in H.TH.NS:
        X, y = H.TH.train_data(t["fn"], name, 0, n, d); X = np.asarray(X, float); y = np.asarray(y, float)
        r = y - y.mean(); s2 = float(np.mean(r * r)) or 1.0
        cell = dict(n=n)
        for fold in (False, True):
            Tv, lev = block_T(X, r, S, sg, fold, n); m = max(lev - 1, 1); thr = DF._chi2_thr(m, tk)
            cell["fold" if fold else "unfold"] = dict(T=round(Tv / s2, 2), levels=lev, thr=round(thr, 2), ratio=round(Tv / s2 / thr, 3))
        # modulated test: the block on r * chi_M for every modulator M among the other relevant inputs (|M| <= 3); DFG
        # takes modulators from its current characters (up to sum_mod = 4 of them; one more term in the union bound each)
        best = (0.0, None)
        for q in range(1, min(3, len(rest)) + 1):
            for Mset in itertools.combinations(rest, q):
                cm = np.prod(X[:, list(Mset)], 1); rm = r * cm; s2m = float(np.mean(rm * rm)) or 1.0
                tkm = math.log(4 * K * math.comb(d, k) * 2.0 ** (k - 1) * 2 * 5 * KM / delta)
                for fold in (False, True):
                    Tv, lev = block_T(X, rm, S, sg, fold, n); thr = DF._chi2_thr(max(lev - 1, 1), tkm)
                    if Tv / s2m / thr > best[0]:
                        best = (Tv / s2m / thr, list(Mset))
        cell["modulated"] = dict(ratio=round(best[0], 3), M=best[1])
        c1 = X.T @ r / n; top1 = set(np.argsort(-np.abs(c1))[:k].tolist()); top1w = set(np.argsort(-np.abs(c1))[:k + 5].tolist())
        M = (X * r[:, None]).T @ X / n; np.fill_diagonal(M, 0.0); lam, U = np.linalg.eigh(M)
        eig = [len(set(np.argsort(-np.abs(U[:, q]))[:k].tolist()) & set(S.tolist())) / k for q in np.argsort(-np.abs(lam))[:2]]
        eigw = [len(set(np.argsort(-np.abs(U[:, q]))[:k + 5].tolist()) & set(S.tolist())) / k for q in np.argsort(-np.abs(lam))[:2]]
        cell["search"] = dict(deg1=len(top1 & set(S.tolist())) / k, eig=eig, deg1_k5=len(top1w & set(S.tolist())) / k, eig_k5=eigw)
        res["cells"].append(cell)
        print(f"{name} n={n:5d} unfold T/thr={cell['unfold']['ratio']:.2f} fold={cell['fold']['ratio']:.2f} "
              f"deg1 reach={cell['search']['deg1']:.2f} eig={[round(e, 2) for e in eig]}", flush=True)
    json.dump(res, open(os.path.join(out_dir, f"{suite}__{name}.json"), "w"), indent=1)
    print(name, "W_k:", res["fourier_by_degree"])

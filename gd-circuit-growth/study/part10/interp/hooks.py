"""Instrumented fits of a hyb_portfolio-style learner (v2 = part9/hyb_portfolio2, or a Part 10 copy of it) for the
interpretability analysis.  A fit here is bit-for-bit the fit of the evaluation harness (same training rows, same rng),
with the learner's internals recorded:
  - every DFG fit (characters, sum blocks, readout weights; the last fit on all n is the final member),
  - the pooling sets S_i(k) (the 0/1 matrices A_k), the prototype-pair directions U (and the classes of each pair's two
    points) and every ggbt booster,
  - the stacker's weights and the members' out-of-fold errors (the learner's own info).
Nothing is changed in the learner: module-level functions are wrapped, the wrapped calls return what they returned.

  HP = load_learner(path)                      the learner module (a copy is loaded per call; patching is local to it)
  rec = fit_toy(HP, suite, target, n, seed)    a toy fit exactly as eval_toy.py --perm runs it
  rec = fit_image(HP, dataset, n, seed)        an image fit exactly as part9/eval_cells.py runs it
  dfg_terms(rec)                               the final DFG model as terms in ORIGINAL input coordinates
  grid_of(dataset)                             column -> (row, col) on the 28 x 28 grid (QuickDraw columns are permuted)
"""
import os, sys, importlib.util, numpy as np

HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(os.path.dirname(HERE))
sys.path.append(STUDY)                                            # boolfuncs (study/common.py must not shadow hybrid's)
sys.path.insert(0, os.path.join(STUDY, "part9")); sys.path.insert(0, os.path.join(STUDY, "hybrid"))
import common                                                     # noqa: E402  (study/hybrid/common.py)
DATA = common.SH.DATA
_ts = importlib.util.spec_from_file_location("toy_harness_i", os.path.join(STUDY, "discrete_learner", "harness.py"))
TH = importlib.util.module_from_spec(_ts); _ts.loader.exec_module(TH)

V2 = os.path.join(STUDY, "part9", "hyb_portfolio2", "learner.py")
_n_loaded = [0]


def load_learner(path=V2):
    _n_loaded[0] += 1
    sp = importlib.util.spec_from_file_location(f"interp_learner_{_n_loaded[0]}", path)
    m = importlib.util.module_from_spec(sp); sp.loader.exec_module(m)
    return m


def _closure(fn):
    return dict(zip(fn.__code__.co_freevars, [c.cell_contents for c in (fn.__closure__ or ())]))


class Recorder:
    """Wraps HP's DFG._fit, pool_sets, pair_dirs and fit_ggbt for the duration of a with-block."""

    def __init__(self, HP):
        self.HP = HP; self.dfg, self.pool, self.ranked, self.pairs, self.pair_cls, self.ggbt = [], [], [], [], [], []

    def __enter__(self):
        HP = self.HP; self._saved = {}
        dfgm, th = HP._dfg_module(); self._dfgm = dfgm; orig_fit = dfgm.DFG._fit; rec = self

        def _fit(s, A, b, *a, **k):
            out = orig_fit(s, A, b, *a, **k)
            cl = _closure(out["predict"]); val = cl["value"]; vc = _closure(val)
            rec.dfg.append(dict(n=len(b), info=out["info"], F=list(vc["F"]), W=np.array(vc["W"]), B=list(vc["B"]),
                                bg=np.array(vc["bg"]), value=val))
            return out
        self._saved["dfg"] = orig_fit; dfgm.DFG._fit = _fit
        for name in ("pool_sets", "pair_dirs", "fit_ggbt"):
            self._saved[name] = getattr(HP, name)
        ps, pd, fg = self._saved["pool_sets"], self._saved["pair_dirs"], self._saved["fit_ggbt"]

        def pool_sets(X, ks, *a, **k):
            res = ps(X, ks, *a, **k); rec.pool.append({kk: v.copy() for kk, v in res[0].items()})
            rec.ranked.append(res[2].copy() if len(res) > 2 else None)    # p10_hier: ranked neighbour lists (active index space)
            return res

        def pair_dirs(X, y, m, rng):
            import copy
            rc = copy.deepcopy(rng); U = pd(X, y, m, rng); rec.pairs.append(U.copy())
            a = rc.integers(len(X), size=m); b = rc.integers(len(X), size=m)       # the same draws as pair_dirs makes
            for _ in range(100):
                bad = y[a] == y[b]
                if not bad.any():
                    break
                b[bad] = rc.integers(len(X), size=int(bad.sum()))
            keep = y[a] != y[b]; rec.pair_cls.append(np.stack([y[a[keep]], y[b[keep]]], 1))
            assert len(rec.pair_cls[-1]) == len(U)
            return U

        def fit_ggbt(Xr, y, *a, **k):
            m, fl, r = fg(Xr, y, *a, **k)
            c = _closure(type(m).proba) if hasattr(type(m), "proba") else {}
            npairs = a[4] if len(a) > 4 else k.get("n_pairs", 300)        # fit_ggbt(Xr, y, C, A, rng, seed, n_pairs, ...)
            rec.ggbt.append(dict(n=len(y), model=m, bst=c.get("bst"), best=c.get("best"), feat=c.get("feat"), rounds=r,
                                 U=rec.pairs[-1] if (rec.pairs and npairs) else np.zeros((0, Xr.shape[1]), np.float32),
                                 pair_cls=rec.pair_cls[-1] if (rec.pair_cls and npairs) else np.zeros((0, 2), int),
                                 l2=tuple(k.get("l2", ())), Sa=k.get("Sa")))
            return m, fl, r
        HP.pool_sets, HP.pair_dirs, HP.fit_ggbt = pool_sets, pair_dirs, fit_ggbt
        return self

    def __exit__(self, *exc):
        self._dfgm.DFG._fit = self._saved["dfg"]
        for name in ("pool_sets", "pair_dirs", "fit_ggbt"):
            setattr(self.HP, name, self._saved[name])
        return False


def fit_toy(HP, suite, target, n, seed, d=30, **learner_kw):
    """eval_toy.py <learner> <suite> --perm: X, y from the toy harness; rng = [fn_seed, seed, n, 77]; Permuted draws the
    column order pi from that rng (the learner sees X[:, pi]); ToyAdapter maps labels to {0, 1}, budget = one network run."""
    T = targets(suite, d); fn = T[target]["fn"]
    X, y = TH.train_data(fn, target, seed, n, d); Xte, yte = TH.test_data(fn, target, d)
    rng = np.random.default_rng([TH.fn_seed(target), seed, n, 77]); pi = rng.permutation(d)
    Xp = np.asarray(X, np.float64)[:, pi]; yy = (np.asarray(y) > 0).astype(np.int64)
    L = HP.Learner(**learner_kw)
    with Recorder(HP) as R:
        out = L.fit(Xp, yy, ["binary"] * d, 2, rng, budget=common.toy_budget(d))
    pred = np.where(np.asarray(out["predict"](np.asarray(Xte, np.float64)[:, pi])) == 1, 1.0, -1.0)
    return dict(kind="toy", suite=suite, target=target, n=n, seed=seed, pi=pi, X=Xp, y=yy, Xte=np.asarray(Xte, np.float64)[:, pi],
                yte=yte, err=float(np.mean(pred != yte)), info=out["info"], flops=out["flops"], rec=R, meta=T[target], fit=out)


def fit_image(HP, ds, n, seed, D=None, **learner_kw):
    """part9/eval_cells.py: training rows pool[:n] of DATA.splits(D, seed); rng = [seed, n, 4242]."""
    D = DATA.load(ds) if D is None else D; pool, te = DATA.splits(D, seed); tr = pool[:n]
    L = HP.Learner(**learner_kw)
    with Recorder(HP) as R:
        out = L.fit(D["X"][tr], D["y"][tr], list(D["types"]), D["C"], np.random.default_rng([seed, n, 4242]))
    pred = np.asarray(out["predict"](D["X"][te]))
    return dict(kind="image", dataset=ds, n=n, seed=seed, tr=tr, te=te, pred=pred, err=float(np.mean(pred != D["y"][te])),
                info=out["info"], flops=out["flops"], rec=R, fit=out, D=D)


def targets(suite, d=30):
    import boolfuncs
    mk = {"designed": boolfuncs.make_suite, "random": boolfuncs.make_random_suite,
          "dlheld": boolfuncs.make_dl_heldout_suite, "dlheld2": boolfuncs.make_dl_heldout2_suite,
          "dlheld3": boolfuncs.make_dl_heldout3_suite, "dlsymdev": boolfuncs.make_dl_symdev_suite,
          "dlheld4": boolfuncs.make_dl_heldout4_suite, "dlheld5": boolfuncs.make_dl_heldout5_suite,
          "dlheld6": boolfuncs.make_dl_heldout6_suite, "dlfamdev": boolfuncs.make_dl_famdev_suite,
          "dlheld7": boolfuncs.make_dl_heldout7_suite}[suite]
    return mk(d)


def final_dfg(rec, fallback=False):
    """The final DFG member: the last DFG fit on all n rows (the earlier ones are the out-of-fold fits), or None (the
    stacker gave DFG no weight, so it was not refitted); fallback=True: then the last out-of-fold fit (fewer rows)."""
    full = [f for f in rec["rec"].dfg if f["n"] == rec["n"]]
    if full:
        return full[-1]
    return rec["rec"].dfg[-1] if fallback and rec["rec"].dfg else None


def dfg_terms(rec, fit=None):
    """The DFG model f(x) = sum_t w_t phi_t(x) + bg . x as a list of terms in ORIGINAL coordinates (pi maps the learner's
    column j to the original input pi[j]).  Each term: kind ('const', 'chi' with set S, or 'sum' with the block's set,
    signs, fold, modulator and the weights of its level groups), and its share = the standard deviation of its
    contribution over the test inputs (sum terms: of the whole block's contribution)."""
    f = final_dfg(rec, fallback=True) if fit is None else fit
    if f is None:
        return []
    pi = rec["pi"]; Z = rec["Xte"]; o = lambda S: sorted(int(pi[i]) for i in S)
    terms, blocks = [], {}
    for (kind, k), w in zip(f["F"], f["W"]):
        if kind == "chi":
            S = tuple(k); col = np.prod(Z[:, list(S)], 1) if S else np.ones(len(Z))
            terms.append(dict(kind="const" if not S else "chi", S=o(S), w=float(w), share=float(np.std(w * col))))
        elif kind == "sum":
            bid, v = k; blocks.setdefault(bid, []).append((v, float(w)))
        else:                                                       # a spectral (quadratic) feature (u . x)^2 - |u|^2
            u = np.asarray(k, float); col = (Z @ u) ** 2 - u @ u; sup = np.where(np.abs(u) > 0.1 * np.abs(u).max())[0]
            terms.append(dict(kind="quad", S=o(sup), w=float(w), share=float(np.std(w * col))))
    for bid, lv in blocks.items():
        B = f["B"][bid]; g = B.group(Z); cm = np.prod(Z[:, list(B.mod)], 1) if B.mod else np.ones(len(Z))
        contrib = sum(w * (g == v) for v, w in lv) * cm
        sg = {int(pi[i]): int(s) for i, s in zip(B.S, B.sg)}
        factors, b = [], B                                          # a product block's factors (the block itself first)
        while b is not None:
            fs = {int(pi[i]): int(s) for i, s in zip(b.S, b.sg)}; factors.append(dict(S=sorted(fs), signs=[fs[i] for i in sorted(fs)]))
            b = b.other
        terms.append(dict(kind="sum", S=sorted(sg), signs=[sg[i] for i in sorted(sg)], fold=B.fold, mod=o(B.mod), factors=factors,
                          edges=[float(e) for e in B.edges], levels={int(v): w for v, w in lv}, desc=block_desc(B, pi),
                          product=B.other is not None, share=float(np.std(contrib))))
    bg = f["bg"]
    terms.append(dict(kind="background", w=[float(bg[np.where(pi == i)[0][0]]) for i in range(len(pi))],
                      share=float(np.std(Z @ bg))))
    return sorted(terms, key=lambda t: -t["share"])


def block_desc(B, pi):
    """A sum block in original coordinates, 1-indexed: e.g. 'chi[x3]*|x1-x2+x5|' (x 'other' for a product block)."""
    o = sorted((int(pi[i]), int(s)) for i, s in zip(B.S, B.sg))
    t = "".join(("+" if s > 0 else "-") + f"x{i + 1}" for i, s in o).lstrip("+")
    a = f"|{t}|" if B.fold else f"({t})"
    if B.mod:
        a = "chi[" + ",".join(f"x{int(pi[i]) + 1}" for i in sorted(B.mod, key=lambda i: pi[i])) + "]*" + a
    return a + ("" if B.other is None else " x " + block_desc(B.other, pi))


def grid_of(ds, d=784):
    """Column j of the dataset -> pixel index on the 28 x 28 grid.  QuickDraw sets: columns permuted by the fixed
    permutation of standard_tasks/data.py (seed 9192), X[:, j] = pixel perm[j]; MNIST / Fashion-MNIST: identity."""
    if ds.startswith("qd_"):
        return np.random.default_rng(9192).permutation(d)
    return np.arange(d)


def dfg_columns(f, Z):
    """The final DFG model's feature columns at the inputs Z (learner coordinates), in F order."""
    Z = np.asarray(Z, np.float64); cols, cache = [], {}
    for kind, k in f["F"]:
        if kind == "chi":
            cols.append(np.prod(Z[:, list(k)], 1) if k else np.ones(len(Z)))
        elif kind == "sum":
            bid, v = k
            if bid not in cache:
                B = f["B"][bid]; cache[bid] = (B.group(Z), np.prod(Z[:, list(B.mod)], 1) if B.mod else np.ones(len(Z)))
            g, cm = cache[bid]; cols.append((g == v) * cm)
        else:
            cols.append((Z @ k) ** 2 - k @ k)
    return np.stack(cols, 1)


def symmetry_classes(fn, rel, d=30, m=4096, seed=5):
    """The target's signed symmetry classes over its relevant inputs: i ~ j if f is invariant under swapping x_i and x_j
    ('+'), or under x_i -> -x_j, x_j -> -x_i ('-'); '+-' if both (e.g. inside a parity).  Tested on m random inputs.
    Returns a list of classes (sorted lists of original indices, size >= 2) with, for each, the relative signs fixed by
    the '+' / '-' relations (None where only '+-' relations connect an input)."""
    X = np.random.default_rng(seed).choice([-1.0, 1.0], size=(m, d)); f0 = fn(X); rel = list(rel)
    par = {i: i for i in rel}; E = {}

    def find(i):
        while par[i] != i:
            par[i] = par[par[i]]; i = par[i]
        return i
    for a in range(len(rel)):
        for b in range(a + 1, len(rel)):
            i, j = rel[a], rel[b]; Xs = X.copy(); Xs[:, [i, j]] = X[:, [j, i]]; sym = np.array_equal(fn(Xs), f0)
            Xa = X.copy(); Xa[:, i], Xa[:, j] = -X[:, j], -X[:, i]; anti = np.array_equal(fn(Xa), f0)
            if sym or anti:
                E[(i, j)] = "+-" if sym and anti else "+" if sym else "-"; par[find(i)] = find(j)
    groups = {}
    for i in rel:
        groups.setdefault(find(i), []).append(i)
    out = []
    for g in groups.values():
        if len(g) < 2:
            continue
        sg = {g[0]: 1}; todo = [g[0]]
        while todo:
            i = todo.pop()
            for (a, b), r in E.items():
                if r == "+-" or i not in (a, b):
                    continue
                j = b if a == i else a
                if j not in sg:
                    sg[j] = sg[i] * (1 if r == "+" else -1); todo.append(j)
        out.append(dict(S=sorted(g), signs=[sg.get(i) for i in sorted(g)]))
    return out


def fourier(fn, rel, d=30):
    """Exact Fourier coefficients of f over its relevant inputs (the others are irrelevant): {subset (orig. indices): fhat}."""
    rel = list(rel); k = len(rel); N = 1 << k
    B = ((np.arange(N)[:, None] >> np.arange(k)[None, :]) & 1)
    X = np.ones((N, d)); X[:, rel] = 1 - 2 * B
    a = fn(X).astype(np.float64).copy(); h = 1
    while h < N:                                                   # fast Walsh-Hadamard transform
        a = a.reshape(-1, 2, h); a = np.stack([a[:, 0] + a[:, 1], a[:, 0] - a[:, 1]], 1).reshape(-1); h *= 2
    a /= N
    return {tuple(rel[i] for i in range(k) if (m >> i) & 1): float(a[m]) for m in range(N) if abs(a[m]) > 1e-9}

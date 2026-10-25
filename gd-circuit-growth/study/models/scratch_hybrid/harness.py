"""Fast harness: cache race fits + NNGP grams on the NN's partial cells, score readout variants by per-example agreement."""
import sys, os, numpy as np, pickle, time
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import common as C
from models.race import Race
from models.baselines import nngp_table
H = '/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/hybrid'

def race_cols(fit, Z):
    cl = {k: c.cell_contents for k, c in zip(fit["predict"].__code__.co_freevars, fit["predict"].__closure__)}
    G, a, c0, relu, d = cl["G_"], cl["a_"], cl["c_"], cl["relu"], cl["d"]
    Z = np.asarray(Z, dtype=np.float32)
    W = np.zeros((len(Z), d + len(G)), dtype=np.float32); W[:, :d] = Z; Dz = d
    cols = np.zeros((len(Z), len(G)))
    for j, (gw, gb, gwire, gsd, gmu) in enumerate(G):
        sz = np.rint(W[:, :len(gw)] @ gw.astype(np.float32)).astype(np.float64)
        ind = (sz > gb).astype(np.float64)
        gv = np.maximum(sz - gb, 0.0) if relu else ind
        if gwire is not None:
            W[:, Dz] = 2 * ind - 1; Dz += 1
        cols[:, j] = (gv - gmu) / gsd
    return cols, a, c0

def partial_cells(fns):
    out = []
    for fn in fns:
        nn = C.nn_fixed(fn, 'adam')
        for a_, n in enumerate(nn['ns']):
            if 0.05 <= nn['test_err'][a_].mean() <= 0.45:
                out.append((fn, int(n), a_))
    return out

def build_cache(fns, path):
    M = Race(theta=1.5, Q=3, gate='relu')
    cache = []
    for fn, n, a_ in partial_cells(fns):
        nn = C.nn_fixed(fn, 'adam'); Xte, yte = C.test_data(fn); d = Xte.shape[1]; table = nngp_table(d)
        gram = lambda A, B: table[((A @ B.T).astype(np.int64) + d) // 2].astype(np.float64)
        for s in range(3):
            X, y = C.train_data(fn, s, n)
            fit = M.fit(X, y, np.random.default_rng([s, n, C._fn_seed(fn)]))
            Ftr, a, c0 = race_cols(fit, X); Fte, _, _ = race_cols(fit, Xte)
            cache.append(dict(fn=fn, n=n, seed=s, X=X, y=y.astype(np.float64), Ftr=Ftr, Fte=Fte, a=a, c0=c0,
                              Ktr=gram(X, X).astype(np.float32), Kte=gram(Xte, X).astype(np.float32), nn_pred=nn['pred'][a_, s],
                              nn_err=float(nn['test_err'][a_, s]), yte=yte))
        print(fn, n, flush=True)
    pickle.dump(cache, open(path, 'wb'), protocol=4)

def agreement_score(cache, preds, fns=None):
    """Same statistic as common.compare's example_agreement_score, on the cached partial cells.
    preds: list aligned with cache of (4096,) +-1 arrays."""
    cells = {}
    for c, p in zip(cache, preds):
        if fns is not None and c['fn'] not in fns:
            continue
        cells.setdefault((c['fn'], c['n']), []).append((c, p))
    num = den = 0.0
    per = {}
    for key, lst in cells.items():
        en = np.mean([c['nn_err'] for c, _ in lst]); em = np.mean([np.mean(p != c['yte']) for c, p in lst])
        agree = np.mean([np.mean(p == c['nn_pred']) for c, p in lst])
        indep = (1 - en) * (1 - em) + en * em
        num += agree - indep; den += 1 - indep; per[key] = (en, em, agree, indep)
    return num / den, per

if __name__ == '__main__':
    t0 = time.time()
    build_cache(C.CALIB + C.HELDOUT, H + '/cache.pkl')
    print('built', time.time() - t0)

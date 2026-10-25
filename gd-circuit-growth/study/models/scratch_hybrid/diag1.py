import sys, os, numpy as np, itertools, json
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import common as C
from models.race import Race
from models.baselines import nngp_table
from scipy.linalg import cho_factor, cho_solve

def race_score_fn(fit):
    cl = {k: c.cell_contents for k, c in zip(fit["predict"].__code__.co_freevars, fit["predict"].__closure__)}
    G, a, c0, relu, d = cl["G_"], cl["a_"], cl["c_"], cl["relu"], cl["d"]
    def score(Z):
        Z = np.asarray(Z, dtype=np.float32)
        W = np.zeros((len(Z), d + len(G)), dtype=np.float32); W[:, :d] = Z; Dz = d
        out = np.full(len(Z), c0)
        for j, (gw, gb, gwire, gsd, gmu) in enumerate(G):
            sz = np.rint(W[:, :len(gw)] @ gw.astype(np.float32)).astype(np.float64)
            ind = (sz > gb).astype(np.float64)
            gv = np.maximum(sz - gb, 0.0) if relu else ind
            if gwire is not None:
                W[:, Dz] = 2 * ind - 1; Dz += 1
            out += a[j] * (gv - gmu) / gsd
        return out
    return score

def kernel_score_fn(X, y, ridge=1e-4):
    d = X.shape[1]; table = nngp_table(d)
    gram = lambda A, B: table[((A @ B.T).astype(np.int64) + d) // 2].astype(np.float64)
    K = gram(X, X); lam = ridge * np.trace(K) / len(X)
    c = cho_solve(cho_factor(K + lam * np.eye(len(X))), y.astype(np.float64))
    return lambda Z: gram(Z, X) @ c

def nn_score_fn(P, j):
    p = {k: P[k][j].astype(np.float64) for k in P.files}
    def f(Z):
        h1 = np.maximum(Z @ p['W1'].T + p['b1'], 0); h2 = np.maximum(h1 @ p['W2'].T + p['b2'], 0); return h2 @ p['a']
    return f

def rel_part(f, Xp, rel):
    key = ((Xp[:, rel] > 0).astype(np.int64) * (2 ** np.arange(len(rel)))).sum(1)
    cnt = np.bincount(key, minlength=2 ** len(rel)); s = np.bincount(key, weights=f, minlength=2 ** len(rel))
    m = s / np.maximum(cnt, 1)
    return m[key]

def deg_parts(f, Xp):
    f0 = f.mean(); g = f - f0
    c1 = Xp.T @ g / len(Xp); f1 = Xp @ c1
    pairs = list(itertools.combinations(range(Xp.shape[1]), 2))
    Ch = np.stack([Xp[:, i] * Xp[:, j] for i, j in pairs], 1)
    c2 = Ch.T @ g / len(Xp); f2 = Ch @ c2
    return f1, f2, g - f1 - f2

def corr(a, b):
    a = a - a.mean(); b = b - b.mean()
    return float(a @ b / np.sqrt((a @ a) * (b @ b) + 1e-30))

EV = '/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals'
M = Race(theta=1.5, Q=3, gate='relu')
rows = []
fns = sys.argv[1].split(',') if len(sys.argv) > 1 else C.HELDOUT
probe = np.random.default_rng(99).choice(np.array([-1.0, 1.0], dtype=np.float32), size=(16384, C.D))
for fn in fns:
    nn = C.nn_fixed(fn, 'adam'); z = np.load(os.path.join(C.RESULTS, f'fixed_adam_{fn}.npz'))
    P = np.load(os.path.join(C.RESULTS, f'params_fixed_adam_{fn}.npz'))
    I = {(int(n), int(s)): j for j, (n, s) in enumerate(zip(z['net_n'], z['net_s']))}
    rel = C.SUITE[fn]['relevant']
    Xte, yte = C.test_data(fn); ytp = C.SUITE[fn]['fn'](probe)
    for a_, n in enumerate(nn['ns']):
        e = nn['test_err'][a_]
        if not (0.05 <= e.mean() <= 0.45):
            continue
        for s in range(3):
            X, y = C.train_data(fn, s, n)
            fit = M.fit(X, y, np.random.default_rng([s, n, C._fn_seed(fn)]))
            fs = {'nn': nn_score_fn(P, I[(int(n), s)]), 'race': race_score_fn(fit), 'ker': kernel_score_fn(X, y)}
            V = {k: f(probe) for k, f in fs.items()}
            r = dict(fn=fn, n=int(n), seed=s, size=fit['size'])
            for k, v in V.items():
                v = (v - v.mean()) / v.std()
                fr = rel_part(v, probe, rel); f1, f2, f3 = deg_parts(v, probe)
                V[k] = dict(v=v, rel=fr, irr=v - fr, f1=f1, f2=f2, f3=f3)
                r[f'{k}_err'] = float(np.mean(np.where(v > -1e9, np.sign(fs[k](probe) + 1e-12), 0) != ytp))
                r[f'{k}_share_rel'] = float(np.var(fr)); r[f'{k}_share_d1'] = float(np.var(f1)); r[f'{k}_share_d2'] = float(np.var(f2))
            for k in ('race', 'ker'):
                for part in ('v', 'rel', 'irr', 'f1', 'f2', 'f3'):
                    r[f'{k}_corr_{part}'] = corr(V['nn'][part], V[k][part])
            r['race_ker_corr_irr'] = corr(V['race']['irr'], V['ker']['irr'])
            # error tables on probe
            en = np.sign(fs['nn'](probe)) != ytp; er = np.sign(fs['race'](probe)) != ytp; ek = np.sign(fs['ker'](probe)) != ytp
            for a1, b1 in itertools.product((0, 1), (0, 1)):
                msk = (er == a1) & (ek == b1)
                r[f'pnn_r{a1}k{b1}'] = float(en[msk].mean()) if msk.any() else np.nan; r[f'frac_r{a1}k{b1}'] = float(msk.mean())
            rows.append(r)
            print(f"{fn:10s} n={n:5d} s={s} err nn/race/ker {r['nn_err']:.3f}/{r['race_err']:.3f}/{r['ker_err']:.3f} | corr(v) race {r['race_corr_v']:.2f} ker {r['ker_corr_v']:.2f} | "
                  f"irr-share nn {1-r['nn_share_rel']:.2f} race {1-r['race_share_rel']:.2f} ker {1-r['ker_share_rel']:.2f} | corr(irr) race {r['race_corr_irr']:.2f} ker {r['ker_corr_irr']:.2f} | corr(rel) race {r['race_corr_rel']:.2f} ker {r['ker_corr_rel']:.2f} | "
                  f"d1 share nn {r['nn_share_d1']:.2f} race {r['race_share_d1']:.2f} ker {r['ker_share_d1']:.2f} corr(d1) race {r['race_corr_f1']:.2f} ker {r['ker_corr_f1']:.2f} | P(nn err|r,k) 00 {r['pnn_r0k0']:.2f} 01 {r['pnn_r0k1']:.2f} 10 {r['pnn_r1k0']:.2f} 11 {r['pnn_r1k1']:.2f}", flush=True)
json.dump(rows, open('/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/hybrid/diag1_%s.json' % ('_'.join(fns) if len(fns) < 3 else 'set'), 'w'))

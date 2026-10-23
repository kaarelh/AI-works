"""Mechanism diagnostics behind ABLATIONS.md §4-§5 (each prints a markdown table).

usage: python models/ablation_diagnostics.py floor | hebb | delay NAME... | nnsteps | tprofile NAME... | gentime NAME...
  floor     parity noise floor: n at which U_k(true direction) on the training set reaches 1, 1.5, 2 x the largest U_k that
            power iteration finds on random labels (same inputs).  DIM selects d (DIM=60 needs NS_MAX=65536 and
            FLOOR_NMAX=32768).
  hebb      n* of the one-shot Hebbian classifier sign(c + a h.x), h = E_S[y x], continuous and rounded, dense targets
  delay     delayed generalisation: test error when the training error first reaches 0.1, vs at the end; NN vs ablations
  nnsteps   the networks' n* computed at intermediate training steps
  tprofile  median time to generalise at n = 16384, relative to par2, NN vs ablations
  gentime   rescore an ablation with its clock read at test error <= 0.1 along the trajectory
  budget    floor check: noise maximum on random labels with 32x40, 128x100, 512x100 power-iteration starts x steps
            (CASES env, e.g. "[('par3',3,[1779,3410]),('par4',4,[5545,14255])]")
  reach     fraction of 256 random starts from which power iteration on the training residual reaches the true
            parity direction (overlap > 0.9) within 8 and 100 steps (CASES env as above; 2 seeds)
"""
import os, sys, json, functools
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import common as C
from models.race import _order_k, F32
C.nn_fixed = functools.lru_cache(maxsize=None)(C.nn_fixed)
SCR = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad"
EVALS = os.path.join(SCR, "model_evals"); DIAG = os.path.join(SCR, "ablation_diag")
fmt = lambda v: "never" if not np.isfinite(v) else f"{v:.0f}"


def _power_max(U, r, k, rng, starts=32, iters=40):
    h = (U.T @ r) / len(r)
    V = rng.standard_normal((U.shape[1], starts)).astype(F32); V /= np.linalg.norm(V, axis=0)
    sgn = (np.ones(starts) if k % 2 else np.where(np.arange(starts) % 2 == 0, 1.0, -1.0)).astype(F32)
    for _ in range(iters):
        _, G = _order_k(U, r, V, k, h, float(r.mean())); G = G * sgn
        nr = np.linalg.norm(G, axis=0); nr[nr == 0] = 1; V = G / nr
    return float(np.abs(_order_k(U, r, V, k, h, float(r.mean()), need_grad=False)[0]).max())


def floor():
    nmax = int(os.environ.get("FLOOR_NMAX", 8192))
    ns = [int(round(2 ** (e / 2))) for e in range(10, int(2 * np.log2(nmax)) + 1)]
    print(f"| d = {C.D} | n at ratio 1 | 1.5 | 2 |"); print("|---|---|---|---|")
    for fn, k in [("par2", 2), ("par3", 3), ("par4", 4)]:
        rat = []
        for n in ns:
            v = []
            for s in range(3):
                X, y = C.train_data(fn, s, nmax); X, y = X[:n], y[:n]        # nested: = train_data(fn, s, n)
                U = X.astype(F32); r = (y - y.mean()).astype(F32)
                vt = np.zeros((C.D, 1), F32); vt[:k, 0] = 1 / np.sqrt(k)
                Ut = abs(float(_order_k(U, r, vt, k, (U.T @ r) / n, float(r.mean()), need_grad=False)[0][0]))
                yr = np.random.default_rng(100 + s).choice([-1.0, 1.0], n); rr = (yr - yr.mean()).astype(F32)
                v.append(Ut / _power_max(U, rr, k, np.random.default_rng(s)))
            rat.append(np.mean(v))
        rat = np.array(rat); ln = np.log2(ns); cross = []
        for c in (1.0, 1.5, 2.0):
            i = np.where(rat >= c)[0]
            if len(i) == 0 or i[0] == 0:
                cross.append(np.nan); continue
            i = i[0]; f = (c - rat[i - 1]) / (rat[i] - rat[i - 1]); cross.append(2 ** (ln[i - 1] + f * (ln[i] - ln[i - 1])))
        print(f"| {fn} | " + " | ".join(fmt(x) for x in cross) + " |", flush=True)


def hebb():
    race = C.load_eval(os.path.join(EVALS, "race.npz"))
    print("| fn | NN | race | sign(h.x) | h rounded to {-3..3} | h rounded to {-1,0,1} |"); print("|---|---|---|---|---|---|")
    for fn in ["dict", "maj3", "maj9", "thr10", "dnf3", "rmaj9"]:
        Xt, yt = C.test_data(fn); E = np.zeros((3, len(C.NS)))
        for a, n in enumerate(C.NS):
            for s in range(3):
                X, y = C.train_data(fn, s, n); h = X.T @ (y - y.mean()) / n
                for j, w in enumerate([h, np.rint(3 * h / np.abs(h).max()), np.rint(h / np.abs(h).max())]):
                    A = np.c_[np.ones(n), X @ w]; coef = np.linalg.lstsq(A, y, rcond=None)[0]
                    E[j, a] += np.mean(np.where(coef[0] + coef[1] * (Xt @ w) > 0, 1, -1) != yt) / 3
        f = lambda v: fmt(C.sample_complexity(C.NS, v))
        print(f"| {fn} | {f(C.nn_fixed(fn)['test_err'].mean(1))} | {f(race['test_err'][fn].mean(1))} | "
              + " | ".join(f(E[j]) for j in range(3)) + " |")


def _nn_fit_cells():
    out = {}
    for fn in C.FNS:
        nn = C.nn_fixed(fn); st = nn["step"]; te = nn["test_err_curve"]; tr = nn["train_err_curve"]
        for a, n in enumerate(nn["ns"]):
            for b in range(te.shape[2]):
                i = np.where(tr[:, a, b] <= 0.1)[0]
                if len(i):
                    out[(fn, int(n), b)] = (te[i[0], a, b], te[-1, a, b], st[i[0]], nn["steps_to_gen"][a, b])
    return out


def _rows(nm):
    rows = json.load(open(os.path.join(DIAG, f"race-abl-{nm}.json")))["rows"]
    seen = {}
    for r in rows:
        key = (r["fn"], r["n"]); b = seen.get(key, 0); seen[key] = b + 1
        yield (r["fn"], r["n"], b), r


def delay(names):
    NN = _nn_fit_cells()
    print("| | cells fitted | delayed: test > 0.1 at fit, <= 0.1 at end | ... test > 0.15 at fit | ... test > 0.2 at fit | gen/fit time 90th pct | max | in NN-delayed cells: generalises / already at fit |")
    print("|---|---|---|---|---|---|---|---|")
    cnt = lambda D, thr: sum(1 for k in D if D[k][0] > thr and D[k][1] <= 0.1)
    nnd = [k for k in NN if NN[k][0] > 0.1 and NN[k][1] <= 0.1]
    rN = [NN[k][3] / max(NN[k][2], 1) for k in NN if NN[k][1] <= 0.1 and np.isfinite(NN[k][3])]
    print(f"| networks | {len(NN)} | {len(nnd)} | {cnt(NN, 0.15)} | {cnt(NN, 0.2)} | {np.percentile(rN, 90):.1f} | {np.max(rN):.0f} | – |")
    for nm in names:
        M = {}
        for key, r in _rows(nm):
            tr, tt = r["train_traj"], r["test_traj"]
            j = next((i for i, (t, e) in enumerate(tr) if e <= 0.1), None)
            if j is None or not tt:
                continue
            jg = next((t for t, e in tt if e <= 0.1), np.inf)
            M[key] = (tt[j][1], tt[-1][1], tr[j][0], jg)
        md = [k for k in M if M[k][0] > 0.1 and M[k][1] <= 0.1]
        rM = [M[k][3] / max(M[k][2], 1e-9) for k in M if M[k][1] <= 0.1 and np.isfinite(M[k][3])]
        g = [k for k in nnd if k in M and M[k][1] <= 0.1]
        print(f"| race {nm} | {len(M)} | {len(md)} | {cnt(M, 0.15)} | {cnt(M, 0.2)} | {np.percentile(rM, 90):.2f} | {np.max(rM):.1f} | "
              f"{len(g)} / {sum(M[k][0] <= 0.1 for k in g)} |")


def nnsteps():
    show = [1000, 2000, 5000, 10000, 20000]
    print("| fn | " + " | ".join(f"n* at {s} steps" for s in show) + " |"); print("|---|" + "---|" * len(show))
    drops = []
    for fn in C.FNS:
        nn = C.nn_fixed(fn); st = list(nn["step"])
        v = [C.sample_complexity(nn["ns"], nn["test_err_curve"][st.index(s)].mean(1)) for s in show]
        if np.isfinite(v[-2]) and np.isfinite(v[-1]):
            drops.append(np.log2(v[-2] / v[-1]))
        print(f"| {fn} | " + " | ".join(fmt(x) for x in v) + " |")
    print(f"\nmean log2 drop of n* from 10000 to 20000 steps: {np.mean(drops):.2f} (over {len(drops)} targets)")


def tprofile(names):
    R = {nm: C.load_eval(os.path.join(EVALS, f"race-abl-{nm}.npz")) for nm in names}
    fns = ["dict", "maj9", "thr10", "par2", "par3", "par4", "stair5", "sparsepoly", "majpar", "mux", "rmaj9", "dnf3", "rand3"]
    med = lambda v: np.median(v[np.isfinite(v)]) if np.isfinite(v).any() else np.nan
    mt = lambda r, fn: med(np.where(r["test_err"][fn][-1] <= 0.1, r["time"][fn][-1], np.nan))
    nn0 = med(C.nn_fixed("par2")["steps_to_gen"][-1])
    print("| fn | networks | " + " | ".join(names) + " |"); print("|---|---|" + "---|" * len(names))
    dev = np.zeros(len(names)); cnt = 0
    for fn in fns:
        a = med(C.nn_fixed(fn)["steps_to_gen"][-1]) / nn0; v = [mt(r, fn) / mt(r, "par2") for r in R.values()]
        dev += (np.log2(v) - np.log2(a)) ** 2; cnt += 1
        print(f"| {fn} | {a:.2f} | " + " | ".join(f"{x:.2f}" for x in v) + " |")
    print("| rms log2 deviation from the networks | – | " + " | ".join(f"{np.sqrt(x / cnt):.2f}" for x in dev) + " |")


def gentime(names):
    from models.ablation_report import time_log
    for nm in names:
        res = C.load_eval(os.path.join(EVALS, f"race-abl-{nm}.npz"))
        res2 = dict(res, time={fn: np.full_like(v, np.nan) for fn, v in res["time"].items()})
        for (fn, n, b), r in _rows(nm):
            res2["time"][fn][list(res["ns"]).index(n), b] = next((t for t, e in r["test_traj"] if e <= 0.1), np.nan)
        for lab, rr in (("clock at training error <= 0.1", res), ("clock at test error <= 0.1", res2)):
            s = C.compare(rr, "adam", fns=C.HELDOUT, verbose=False); tl = time_log({nm: rr}, fns=C.HELDOUT)[nm]
            print(f"{nm}, {lab}: HELDOUT time Spearman {s['time_spearman']:.2f}, Pearson r of log times {tl[0]:.2f}")


def budget():
    for fn, k, ns in eval(os.environ["CASES"]):
        for n in ns:
            X, y = C.train_data(fn, 0, n); U = X.astype(F32); r = (y - y.mean()).astype(F32)
            vt = np.zeros((C.D, 1), F32); vt[:k, 0] = 1 / np.sqrt(k)
            Ut = abs(float(_order_k(U, r, vt, k, (U.T @ r) / n, float(r.mean()), need_grad=False)[0][0]))
            yr = np.random.default_rng(100).choice([-1.0, 1.0], n); rr = (yr - yr.mean()).astype(F32)
            out = [(st, it, _power_max(U, rr, k, np.random.default_rng(0), starts=st, iters=it)) for st, it in [(32, 40), (128, 100), (512, 100)]]
            print(f"d={C.D} {fn} n={n} U_true={Ut:.4f} | " + " | ".join(f"{a}x{b}: noise max {m:.4f}, ratio {Ut / m:.2f}" for a, b, m in out), flush=True)


def reach(starts=256):
    for fn, k, ns in eval(os.environ["CASES"]):
        for n in ns:
            fr = []
            for s in range(2):
                X, y = C.train_data(fn, s, n); U = X.astype(F32); r = (y - y.mean()).astype(F32); h = (U.T @ r) / n
                vt = np.zeros(C.D, F32); vt[:k] = 1 / np.sqrt(k)
                V = np.random.default_rng(s).standard_normal((C.D, starts)).astype(F32); V /= np.linalg.norm(V, axis=0)
                sgn = (np.ones(starts) if k % 2 else np.where(np.arange(starts) % 2 == 0, 1.0, -1.0)).astype(F32)
                res = {}
                for it in range(1, 101):
                    _, G = _order_k(U, r, V, k, h, float(r.mean())); G = G * sgn
                    nr = np.linalg.norm(G, axis=0); nr[nr == 0] = 1; V = G / nr
                    if it in (8, 100):
                        res[it] = float(np.mean(np.abs(vt @ V) > 0.9))
                fr.append(res)
            print(f"d={C.D} {fn} n={n}: fraction of starts reaching the true direction: 8 steps "
                  f"{np.mean([f[8] for f in fr]):.3f}, 100 steps {np.mean([f[100] for f in fr]):.3f}", flush=True)


if __name__ == "__main__":
    cmd, args = sys.argv[1], sys.argv[2:]
    dict(floor=lambda: floor(), hebb=lambda: hebb(), delay=lambda: delay(args), nnsteps=lambda: nnsteps(),
         tprofile=lambda: tprofile(args), gentime=lambda: gentime(args), budget=lambda: budget(), reach=lambda: reach())[cmd]()

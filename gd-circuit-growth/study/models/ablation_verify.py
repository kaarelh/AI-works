"""Independent checks behind the "Verification" section of ABLATIONS.md (read-only use of the saved evaluations,
except `reseeds`, which runs extra internal random streams of the calibrated race model).

usage: OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 python models/ablation_verify.py CMD
  scoreboard  recompute the scoreboard of every ablation (HELDOUT, CALIB, ALL) and check base == race.npz bit for bit
  pairwise    model-vs-model: mean |log2 n*_variant / n*_control| against the control streams (base, reseeds)
  agree       per-family per-example agreement; the same score when model and network saw DIFFERENT training samples
  dense       n* of the race circuit after its first gate / at fit / at the end / with nostop (dense targets)
  nostop      what running past interpolation does, cell by cell (same trajectory as base up to interpolation)
  time        time Spearman of the race clock against per-target constants, 1/n and gate count; within-target Spearman
  implied     ratio U_true / noise maximum at the networks' n* (the constant the noise-floor rule would need), DIM-aware
  reseeds K.. extra internal random streams (RaceAblation reseed=K) -> model_evals/verify-abl-reseedK[-d15].npz
  band        noise bands with all available streams, at d = 30 (HELDOUT/CALIB/ALL) and d = 15 (7 targets, exponents)
"""
import os, sys, json, glob, copy, itertools, importlib, functools, time
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import common as C
C.nn_fixed = functools.lru_cache(maxsize=None)(C.nn_fixed)
SCR = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad"
EV = os.path.join(SCR, "model_evals"); DG = os.path.join(SCR, "ablation_diag")
NAMES = ["base", "reseed1", "reseed2", "free", "free3", "flat", "reset-clock", "reset-all", "greedy", "theta0.5", "theta3",
         "theta6", "P1", "P32", "iters1", "iters32", "gmax96", "nostop", "depth1", "K3", "K2", "thr", "Q1", "Q2", "Q5",
         "oracle-align", "oracle-search", "indep-align", "indep-search", "indep-resample"]
KEYS = ["sc_mean_abs_log2_ratio", "sc_spearman", "success_agreement", "curve_mae", "example_agreement_score", "time_spearman"]
FAM = {"parity": ["par2", "par3", "par4"], "staircase/sparse poly": ["stair5", "sparsepoly", "mux"],
       "dense": ["maj9", "thr10", "rmaj9"], "compositions": ["majpar", "parmaj", "andxor"]}
FAM["other"] = [f for f in C.FNS if not any(f in v for v in FAM.values())]
CAP = 2 * 16384
ld = lambda nm: C.load_eval(os.path.join(EV, f"race-abl-{nm}.npz"))
nstar = lambda r, fn: C.sample_complexity(np.array(r["ns"]), np.nanmean(r["test_err"][fn], 1))


def rows(nm):
    out, seen = {}, {}
    for r in json.load(open(os.path.join(DG, f"race-abl-{nm}.json")))["rows"]:
        key = (r["fn"], r["n"]); b = seen.get(key, 0); seen[key] = b + 1; out[(r["fn"], r["n"], b)] = r
    return out


def scoreboard():
    ref, b = C.load_eval(os.path.join(EV, "race.npz")), ld("base")
    for k in ("pred", "test_err", "train_err", "time", "size"):
        print(f"base == race.npz ({k}):", all(np.array_equal(ref[k][fn], b[k][fn], equal_nan=True) for fn in C.FNS))
    for split, fns in (("HELDOUT", C.HELDOUT), ("CALIB", C.CALIB), ("ALL", C.FNS)):
        print(f"\n{split}\n| ablation | " + " | ".join(KEYS) + " |")
        for nm in NAMES:
            s = C.compare(ld(nm), "adam", fns=fns, verbose=False)
            print(f"| {nm} | " + " | ".join(f"{s[k]:.2f}" for k in KEYS) + " |")


def _shift(r, k=1):
    r2 = copy.deepcopy(r)
    for key in ("pred", "test_err", "time"):
        for fn in r2[key]:
            r2[key][fn] = np.roll(r[key][fn], k, axis=1)
    return r2


def agree():
    R = {nm: ld(nm) for nm in ["base", "reseed1", "greedy", "thr", "indep-search", "indep-align"]}
    R["nngp-kernel"] = C.load_eval(os.path.join(EV, "nngp-kernel.npz"))
    print("| model | " + " | ".join(FAM) + " |")
    for nm, r in R.items():
        print(f"| {nm} | " + " | ".join(
            "{:.2f} ({})".format(*(lambda s: (s["example_agreement_score"], s["n_partial_cells"]))(C.compare(r, "adam", fns=f, verbose=False)))
            for f in FAM.values()) + " |")
    print("\nper-example agreement, same training sample vs a DIFFERENT sample (model seed rolled by 1 and 2):")
    extra = {"nn-adam (vs itself)": C.nn_as_model_res("adam"), "nn-sgd": C.nn_as_model_res("sgd", fns=C.HELDOUT)}
    for nm, r in list(R.items()) + list(extra.items()):
        for split, fns in (("HELDOUT", C.HELDOUT), ("ALL", C.FNS)):
            if not set(fns) <= set(r["fns"]):
                continue
            same = C.compare(r, "adam", fns=fns, verbose=False)["example_agreement_score"] if not nm.startswith("nn-adam") else 1.0
            d = [C.compare(_shift(r, k), "adam", fns=fns, verbose=False)["example_agreement_score"] for k in (1, 2)]
            print(f"  {nm:22s} {split:8s} same sample {same:.2f}   different sample {d[0]:.2f} / {d[1]:.2f}")


def dense():
    B, N = rows("base"), rows("nostop")
    print("| fn | after 1st gate | at fit (train err <= 0.1) | end (base) | end (nostop) | first-gate order |")
    for fn in ["dict", "maj3", "maj9", "thr10", "rmaj9", "dnf3"]:
        E = np.zeros((4, len(C.NS))); first = set()
        for a, n in enumerate(C.NS):
            for b in range(3):
                r = B[(fn, n, b)]; tt = r["test_traj"]
                E[0, a] += (tt[1][1] if len(tt) > 1 else tt[0][1]) / 3; E[1, a] += tt[r["gates_at_fit"]][1] / 3
                E[2, a] += tt[-1][1] / 3; E[3, a] += N[(fn, n, b)]["test_traj"][-1][1] / 3
                if r["orders"]:
                    first.add(r["orders"][0])
        print(f"| {fn} | " + " | ".join(f"{C.sample_complexity(C.NS, e):.0f}" for e in E) + f" | {sorted(first)} |")


def nostop():
    B, N = rows("base"), rows("nostop")
    tot = imp = wor = 0; byn = {}; cross = []
    for k, rb in B.items():
        tb, tn = rb["test_traj"], N[k]["test_traj"]
        j = len(tb) - 1
        assert abs(tn[j][1] - tb[-1][1]) < 1e-12          # identical up to interpolation
        if len(tn) <= j + 1:
            continue
        dlt = tn[-1][1] - tb[-1][1]; tot += 1
        imp += dlt < -0.005; wor += dlt > 0.005
        byn.setdefault(k[1], []).append(dlt)
        if tb[-1][1] > 0.1 >= tn[-1][1]:
            cross.append((k, round(tb[-1][1], 3), round(tn[-1][1], 3)))
    print(f"cells running past interpolation: {tot}; final test error lower by >0.005: {imp}; higher by >0.005: {wor}")
    for n in sorted(byn):
        v = np.array(byn[n]); print(f"  n={n:5d}: {len(v)} cells, improved {int((v < -0.005).sum())}, worse {int((v > 0.005).sum())}")
    print("cells crossing from >0.1 (base end) to <=0.1 (nostop end):", cross)


def pairwise():
    N = {nm: {fn: min(nstar(ld(nm), fn), CAP) for fn in C.FNS} for nm in NAMES}
    for p in sorted(glob.glob(os.path.join(EV, "verify-abl-reseed[0-9].npz"))):
        r = C.load_eval(p); N[os.path.basename(p)[11:-4]] = {fn: min(nstar(r, fn), CAP) for fn in C.FNS}
    ctl = ["base"] + [k for k in N if k.startswith("reseed")]
    dd = lambda a, b, fns: np.mean([abs(np.log2(N[a][f] / N[b][f])) for f in fns])
    for split, fns in (("HELDOUT", C.HELDOUT), ("ALL", C.FNS)):
        pr = [dd(a, b, fns) for a, b in itertools.combinations(ctl, 2)]
        print(f"{split}: control streams {ctl}: pairwise mean |log2 n* ratio| mean {np.mean(pr):.2f}, range {min(pr):.2f}-{max(pr):.2f}")
        vs = {nm: np.mean([dd(nm, c, fns) for c in ctl]) for nm in NAMES if nm not in ctl}
        print("  variant vs controls:", ", ".join(f"{k} {v:.2f}" for k, v in sorted(vs.items(), key=lambda z: z[1])))


def time_():
    base = ld("base"); ns = np.array(base["ns"], float)
    gf = {fn: np.full((len(ns), 3), np.nan) for fn in C.FNS}
    for (fn, n, b), r in rows("base").items():
        gf[fn][list(base["ns"]).index(n), b] = r["gates_at_fit"] + 1e-3 * b      # tiny tie-break
    def with_time(f):
        r2 = copy.deepcopy(base)
        for fn in r2["fns"]:
            r2["time"][fn] = f(fn)
        return r2
    nnmed = lambda fn: np.nanmedian(np.where(np.isfinite(C.nn_fixed(fn)["steps_to_gen"]), C.nn_fixed(fn)["steps_to_gen"], np.nan))
    V = {"race clock": base,
         "race gate count at fit": with_time(lambda fn: gf[fn]),
         "per-target constant: race's own n*": with_time(lambda fn: np.full((len(ns), 3), min(nstar(base, fn), 1e9))),
         "per-target constant: NN median steps (oracle)": with_time(lambda fn: np.full((len(ns), 3), nnmed(fn))),
         "1/n": with_time(lambda fn: np.repeat((1 / ns)[:, None], 3, 1))}
    for nm, r in V.items():
        print(f"{nm:48s}" + " | ".join(f"{sp} {C.compare(r, 'adam', fns=f, verbose=False)['time_spearman']:.2f}"
                                       for sp, f in (("HELDOUT", C.HELDOUT), ("ALL", C.FNS))))
    for split, fns in (("HELDOUT", C.HELDOUT), ("ALL", C.FNS)):
        w = []
        for fn in fns:
            nn = C.nn_fixed(fn); P = [(nn["steps_to_gen"][a, b], base["time"][fn][a, b]) for a in range(len(ns)) for b in range(3)
                                      if np.isfinite(nn["steps_to_gen"][a, b]) and base["test_err"][fn][a, b] <= 0.1]
            if len(P) > 5:
                w.append(C._spearman(*zip(*P)))
        print(f"{split}: within-target time Spearman (race clock vs NN steps), mean over {len(w)} targets {np.mean(w):.2f}, min {min(w):.2f}")


def implied():
    from models.race import _order_k, F32
    from models.ablation_diagnostics import _power_max
    NNS = {fn: C.sample_complexity(C.nn_fixed(fn)["ns"], C.nn_fixed(fn)["test_err"].mean(1)) for fn in ["par2", "par3", "par4"]}
    for (fn, k) in [("par2", 2), ("par3", 3), ("par4", 4)]:
        n = int(round(NNS[fn])); v = []
        for s in range(3):
            X, y = C.train_data(fn, s, n); U = X.astype(F32); r = (y - y.mean()).astype(F32)
            vt = np.zeros((C.D, 1), F32); vt[:k, 0] = 1 / np.sqrt(k)
            Ut = abs(float(_order_k(U, r, vt, k, (U.T @ r) / n, float(r.mean()), need_grad=False)[0][0]))
            yr = np.random.default_rng(100 + s).choice([-1.0, 1.0], n); rr = (yr - yr.mean()).astype(F32)
            v.append(Ut / _power_max(U, rr, k, np.random.default_rng(s)))
        print(f"d={C.D} {fn}: networks' n* {n}, U_true / noise max there = {np.mean(v):.2f}", flush=True)


def reseeds(ks):
    from models.race_ablations import RaceAblation
    fns = C.FNS if C.D == 30 else [f for f in C.FNS if os.path.exists(os.path.join(C.RESULTS, f"fixed_adam_{f}.npz"))]
    suf = "" if C.D == 30 else f"-d{C.D}"
    for k in ks:
        t0 = time.time()
        res = C.evaluate(RaceAblation(reseed=k, theta=1.5, Q=3, gate="relu", name=f"verify-abl-reseed{k}{suf}"), fns=fns, verbose=False)
        C.save_eval(res, os.path.join(EV, f"verify-abl-reseed{k}{suf}.npz")); print(f"reseed{k}{suf} {time.time() - t0:.0f}s", flush=True)


def band():
    streams = [ld(nm) for nm in ("base", "reseed1", "reseed2")] + [C.load_eval(p) for p in sorted(glob.glob(os.path.join(EV, "verify-abl-reseed[0-9].npz")))]
    print(f"d = 30, {len(streams)} streams of the calibrated model:")
    for split, fns in (("HELDOUT", C.HELDOUT), ("CALIB", C.CALIB), ("ALL", C.FNS)):
        S = [C.compare(r, "adam", fns=fns, verbose=False) for r in streams]
        print(f"  {split:8s}" + " | ".join(f"{k} {min(s[k] for s in S):.2f}-{max(s[k] for s in S):.2f}" for k in KEYS))
    for fn in ["par2", "par3", "par4", "maj9", "thr10", "stair5"]:
        v = [nstar(r, fn) for r in streams]; print(f"  {fn}: n* {min(v):.0f}-{max(v):.0f} ({np.log2(max(v) / min(v)):.2f} log2)")
    # d = 15
    FN7 = ["par2", "par3", "par4", "stair5", "mux", "majpar", "maj9"]
    def at(dim, files):
        os.environ["DIM"] = str(dim); import common; CC = importlib.reload(common)
        nn = {fn: CC.sample_complexity(CC.nn_fixed(fn)["ns"], CC.nn_fixed(fn)["test_err"].mean(1)) for fn in FN7}
        out = {nm: (lambda r: {fn: CC.sample_complexity(np.array(r["ns"]), np.nanmean(r["test_err"][fn], 1)) for fn in FN7})(CC.load_eval(p))
               for nm, p in files.items() if os.path.exists(p)}
        return nn, out
    f15 = {"base": "race-abl-base-d15", "free": "race-abl-free-d15", "greedy": "race-abl-greedy-d15", "flat": "race-abl-flat-d15",
           "indep-search": "race-abl-indep-search-d15", **{f"reseed{k}": f"verify-abl-reseed{k}-d15" for k in range(1, 10)}}
    f30 = {"base": "race-abl-base", "free": "race-abl-free", "greedy": "race-abl-greedy", "flat": "race-abl-flat",
           "indep-search": "race-abl-indep-search", "reseed1": "race-abl-reseed1", "reseed2": "race-abl-reseed2",
           **{f"reseed{k}": f"verify-abl-reseed{k}" for k in range(3, 10)}}
    nn15, A = at(15, {k: os.path.join(EV, v + ".npz") for k, v in f15.items()})
    nn30, B = at(30, {k: os.path.join(EV, v + ".npz") for k, v in f30.items()})
    mae = lambda M, nn: np.mean([abs(np.log2(min(M[f], CAP) / nn[f])) for f in FN7])
    print("\nd = 15, mean |log2 n*/n*_NN| over the 7 d-scaling targets:", ", ".join(f"{k} {mae(v, nn15):.2f}" for k, v in A.items()))
    ctl15 = [k for k in A if k == "base" or k.startswith("reseed")]; ctl30 = [k for k in B if k == "base" or k.startswith("reseed")]
    gm = lambda v: float(np.exp(np.mean(np.log(v))))
    for f in ["par2", "par3", "par4"]:
        e15 = [A[k][f] for k in ctl15]; e30 = [B[k][f] for k in ctl30]
        ex = [np.log2(B[k][f] / A[k][f]) for k in ctl15 if k in B]
        print(f"  {f}: networks' exponent {np.log2(nn30[f] / nn15[f]):.2f}; control streams: d15 n* {min(e15):.0f}-{max(e15):.0f}, "
              f"d30 {min(e30):.0f}-{max(e30):.0f}, exponent of geometric means {np.log2(gm(e30) / gm(e15)):.2f}, "
              f"same-stream exponents {min(ex):.2f}-{max(ex):.2f}")


if __name__ == "__main__":
    cmd = sys.argv[1]
    dict(scoreboard=scoreboard, pairwise=pairwise, agree=agree, dense=dense, nostop=nostop, time=time_, implied=implied,
         band=band, reseeds=lambda: reseeds([int(a) for a in sys.argv[2:]]))[cmd]()

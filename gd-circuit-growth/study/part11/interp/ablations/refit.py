"""Part 11, Q5 / Q5b: refits of single cells of DFG alone, its ablations and the core, read as models (ABLATIONS.md).

A refit is the evaluation's fit of that cell, bit for bit: the training rows of harness.train_data (seed s, first n rows),
the fit rng default_rng([fn_seed(t), s, n, 77]) from which harness.Permuted draws the column order, the test inputs of
harness.test_data, and DFG(readout="logit", **kw).  It is made with ../calib/dfg13_instr.py, the frozen dfg13.py with
recorder calls added and none changed (calib.py audit; CALIB.md section 0), so that every feature of the final model
carries the class or block move that admitted it and its round.  Every refit is checked against the run's result file
(part11/results/toy__<run>__<suite>.json): test error and FLOP count must be equal (asserted where the cell exists).

  refit(suite, target, n, seed, run)   run = 'dfg13-perm' (DFG alone), 'dfg13-<tag>-perm' (an ablation; its kw are read
                                       from the result file) or 'dfg13-core-perm'
      -> dict(err, flops, variant, cv_errs, size, rounds, identical, terms=[...], log=[...], parts={...})
         terms: kind (const / chi / sum / quad / background), origin (the admitting class: global / ext1 / ext2 / local /
                linear / forced / sum_add / sum_mod / sum_prod / ... as dfg13_instr records it), round, desc in ORIGINAL
                coordinates (x1 ... x30), degree, share (sd of its contribution on the 4096 test inputs)
         parts: test error of the model restricted to groups of terms (no blocks, no characters, no background, ...)
usage: OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python refit.py <run> <suite> <target> <n> [<n> ...] [--seed=0] [--save]
       (--save appends the refits to results/refits.json, keyed run:suite:target:n:seed; with --out=<file>, to
       results/<file>: refits_verif.json holds those made when the independent verification was applied)
"""
import os, sys, json
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__)); INTERP = os.path.dirname(HERE); P11 = os.path.dirname(INTERP)
sys.path.insert(0, P11); sys.path.insert(0, INTERP); sys.path.insert(0, os.path.join(INTERP, "calib"))
import eval_dfg as E                                                   # noqa: E402
import dfg_hooks as H                                                  # noqa: E402  (descriptions in original coordinates)
import calib as C                                                      # noqa: E402  (instrumented module, origins)
TH = E.TH
OUT = os.path.join(HERE, "results", "refits.json")
_MOD = [None]


def kw_of(run, suite):
    if run == "dfg13-perm":
        return {}
    r = json.load(open(os.path.join(P11, "results", f"toy__{run}__{suite}.json")))
    kw = dict(r["kw"])
    if "sum_seeds" in kw:
        kw["sum_seeds"] = tuple(kw["sum_seeds"])
    return kw


def refit(suite, target, n, seed=0, run="dfg13-perm", kw=None):
    if _MOD[0] is None:
        _MOD[0] = C.load_instr()
    M = _MOD[0]
    kw = kw_of(run, suite) if kw is None else kw
    T = H.targets(suite); fn = T[target]["fn"]
    X, y = TH.train_data(fn, target, seed, n, 30); Xte, yte = TH.test_data(fn, target, 30)
    L = TH.Permuted(M.DFG(**{"readout": "logit", **kw}))
    C.REC.reset(True)
    out = L.fit(X, y, np.random.default_rng([TH.fn_seed(target), seed, n, 77]))
    C.REC.stop(); calls = list(C.REC.calls)
    err = float(np.mean(np.asarray(out["predict"](Xte)) != yte)); fl = float(out["flops"])
    ident = None
    p = os.path.join(P11, "results", f"toy__{run}__{suite}.json")
    if os.path.exists(p):
        Rf = json.load(open(p))
        if target in Rf["fns"] and n in Rf["ns"] and seed in Rf["seeds"]:
            a, b = Rf["ns"].index(n), Rf["seeds"].index(seed)
            ident = bool(Rf["fns"][target]["err"][a][b] == err and Rf["fns"][target]["flops"][a][b] == fl)
            assert ident, (run, suite, target, n, seed, err, Rf["fns"][target]["err"][a][b], fl, Rf["fns"][target]["flops"][a][b])
    mdl = C.model_of(out, True); fin = calls[-1]; pi = mdl["pi"]; Zte = np.asarray(Xte, np.float64)[:, pi]
    assert fin["n"] == n
    terms, v = C.terms_of(mdl, fin["origins"], Zte)
    descs = {B.desc(): H.block_desc(B, pi) for B in mdl["B"]}
    rows = []
    for t in terms:
        d = (H.chi_desc(t["S"]) if t["kind"] in ("chi", "const") else descs.get(t.get("desc"), t.get("desc")) if t["kind"] == "sum"
             else f"quad({len(t['S'])} inputs: {','.join('x%d' % (i + 1) for i in t['S'])})" if t["kind"] == "quad" else "background")
        rows.append(dict(kind=t["kind"], origin=t["origin"], rnd=t["rnd"], desc=d, deg=t.get("deg"), S=t["S"],
                         share=float(np.std(t["c"])), c=t["c"]))
    sdv = float(np.std(v))

    def part(keep):
        w = sum((t["c"] for t in rows if keep(t)), np.zeros(len(yte)))
        return float(np.mean(np.where(w > 0, 1.0, -1.0) != yte))
    rel = set(T[target].get("relevant", []))
    parts = dict(no_blocks=part(lambda t: t["kind"] != "sum"), no_chars=part(lambda t: t["kind"] not in ("chi",)),
                 no_background=part(lambda t: t["kind"] != "background"),
                 chars_only=part(lambda t: t["kind"] in ("chi", "const")), blocks_only=part(lambda t: t["kind"] in ("sum", "const")),
                 no_linear=part(lambda t: t["origin"] != "linear"), no_quad=part(lambda t: t["kind"] != "quad"),
                 no_spurious=part(lambda t: t["kind"] in ("const", "background") or set(t["S"]) <= rel))
    rows = sorted(rows, key=lambda t: -t["share"])
    o = dict(run=run, suite=suite, target=target, n=n, seed=seed, kw={k: (list(v_) if isinstance(v_, tuple) else v_) for k, v_ in kw.items()},
             err=err, flops=fl, flops_frac=fl / TH.gd_flops(30), identical=ident, variant=int(out["info"].get("variant", 0)),
             cv_errs=out["info"].get("cv_errs"), size=len(mdl["F"]), sd_model=sdv, relevant=sorted(rel),
             rounds=C.call_rounds(fin), parts=parts,
             terms=[{k: v_ for k, v_ in t.items() if k != "c"} | dict(share_frac=t["share"] / max(sdv, 1e-300)) for t in rows])
    return o


def show(o, top=14):
    print(f"== {o['run']} {o['suite']}/{o['target']} n={o['n']} seed={o['seed']}: err {o['err']:.4f} identical={o['identical']} "
          f"variant={o['variant']} cv={o['cv_errs']} size={o['size']} flops/GD={o['flops_frac']:.3f}")
    print("   parts:", {k: round(v, 4) for k, v in o["parts"].items()})
    for t in o["terms"][:top]:
        print(f"   {t['share']:.3f} ({t['share_frac']:.2f})  {t['kind']:10s} {str(t["origin"]):14s} r{t['rnd']}  {t['desc']}")
    if len(o["terms"]) > top:
        print(f"   ... {len(o['terms']) - top} more terms")
    for rd in o["rounds"]:
        adm = rd["added"]
        print(f"   round {rd['rnd']}: s={rd['s']} added={adm} acc={rd['acc']} forced={rd['forced']}")


def save(recs, out=OUT):
    old = json.load(open(out)) if os.path.exists(out) else {}
    for o in recs:
        old[f"{o['run']}:{o['suite']}:{o['target']}:{o['n']}:{o['seed']}"] = o
    json.dump(old, open(out, "w"), default=lambda v: None if v is None else (float(v) if isinstance(v, np.floating) else int(v) if isinstance(v, np.integer) else str(v)))


if __name__ == "__main__":
    a = sys.argv[1:]; opt = {k[2:].split("=", 1)[0]: (k.split("=", 1)[1] if "=" in k else True) for k in a if k.startswith("--")}
    pos = [x for x in a if not x.startswith("--")]
    run, suite, target, ns = pos[0], pos[1], pos[2], [int(x) for x in pos[3:]]
    recs = []
    for n in ns:
        o = refit(suite, target, n, int(opt.get("seed", 0)), run); show(o, int(opt.get("top", 14))); recs.append(o)
    if opt.get("save"):                                             # --out=<file>: into results/<file> instead
        save(recs, os.path.join(HERE, "results", opt["out"]) if "out" in opt else OUT)

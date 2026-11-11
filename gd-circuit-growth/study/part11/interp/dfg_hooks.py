"""Part 11 interpretability tooling: instrumented fits of DFG v1.3 RUN ALONE on the toy targets.

A fit here is the fit part11/eval_dfg.py makes for `dfg13-perm` (or one of its ablations), bit for bit: the same training
rows (discrete_learner/harness.train_data, seed s, first n rows), the same rng (default_rng([fn_seed(target), s, n, 77])),
the same column permutation (harness.Permuted draws pi from that rng before DFG.fit sees X[:, pi]), the same frozen
learner (eval_dfg.load_dfg13 checks md5 69cabe5c50345cb24079198ed52b562f), the same constructor arguments
(readout="logit" + kw).  Nothing in the learner changes: DFG._fit of the freshly loaded module is wrapped for the duration
of one fit and every call is recorded (the 2F out-of-fold fits of the small-n cross-validation, then the final fit on
all n rows, which is the model that predicts).  Run single-threaded (OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1), as the
evaluation queue does, so that BLAS sums in the same order.

  rec = fit_toy_dfg(suite, target, n, seed, kw=None)
        rec["err"]        test error (4096 test inputs; the number the evaluation stores)
        rec["variant"]    0 = default, 1 = forced (the small-n variant chosen by DFG's own paired cross-validation at
                          n <= 512; always 0 above), rec["cv_errs"] = held-out errors [default, forced] (n <= 512)
        rec["final"]      the final _fit call: info (rounds, round log, accepted blocks, size, train_err), F, W, B, bg,
                          flops, value (the model's real-valued output in learner coordinates)
        rec["calls"]      one summary per _fit call (n, force, hi, scale, flops, size, rounds, train_err)
        rec["terms"]      the final model as terms in ORIGINAL input coordinates (model_terms), largest share first
        rec["pi"]         learner column j = original input pi[j]
  model_terms(final, pi, Zte)   the terms: 'const'; 'chi' (a Fourier character, set S); 'quad' (spectral feature
                          (u.x)^2 - |u|^2: support, u in original coordinates); 'sum' (a sum block: set S, signs, fold,
                          modulator chi_M, inner term a*tau, product factors, group edges, the weight of every level
                          group); 'background' (the kernel background, one Hebbian step on the residual: its weight
                          vector).  share = standard deviation of the term's contribution over the test inputs; 'contrib'
                          (kept out of JSON) = the contribution itself, so that parts of the model can be removed.
  check_identity(rec, name=None)  compares rec's test error and FLOP count with the merged result file
                          part11/results/toy__<name>__<suite>.json (seed rec["seed"], same n), if it exists.
  cell_json(rec)          a JSON-serialisable summary of a fit (terms without their contribution vectors).
"""
import os, sys, json, math, importlib, numpy as np

HERE = os.path.dirname(os.path.abspath(__file__)); P11 = os.path.dirname(HERE); STUDY = os.path.dirname(P11)
if P11 not in sys.path:
    sys.path.insert(0, P11)
import eval_dfg as E                                                   # noqa: E402  sets sys.path as the runner does
TH, boolfuncs = E.TH, E.boolfuncs
RESULTS = os.path.join(P11, "results")


def targets(suite, d=30):
    """The targets dict exactly as eval_dfg.run builds it."""
    if suite in E.DL:
        return getattr(boolfuncs, E.DL[suite])(d)
    if suite in ("designed", "random"):
        return TH.suite_targets(suite, d)[0]
    raise ValueError(suite)


def _closure(fn):
    return dict(zip(fn.__code__.co_freevars, [c.cell_contents for c in (fn.__closure__ or ())]))


class Recorder:
    """Wraps DFG._fit of one loaded dfg13 module (its class only) for the duration of a with-block."""

    def __init__(self, cls):
        self.cls, self.calls = cls, []

    def __enter__(self):
        orig = self.cls._fit; self._orig = orig; rec = self

        def _fit(s, X, y, *a, **k):
            out = orig(s, X, y, *a, **k)
            val = _closure(out["predict"])["value"]; vc = _closure(val)
            # positional: c, force, lin0, ridge; keywords hi, scale (DFG.fit passes them either way)
            force = bool(a[1]) if len(a) > 1 else bool(k.get("force", False))
            rec.calls.append(dict(n=len(y), force=force, hi=bool(k.get("hi", True)), scale=float(k.get("scale", 1.0)),
                                  X=X, y=np.asarray(y), info=out["info"], flops=float(out["flops"]), F=list(vc["F"]),
                                  W=np.array(vc["W"], dtype=np.float64), B=list(vc["B"]), bg=np.array(vc["bg"]),
                                  value=val))
            return out
        self.cls._fit = _fit
        return self

    def __exit__(self, *exc):
        self.cls._fit = self._orig
        return False


def make_learner(kw=None, name=None):
    """eval_dfg.make_learner('dfg13', kw, name): a Permuted(DFG(readout='logit', **kw)) from a fresh, md5-checked copy."""
    kw = dict(kw or {})
    if "sum_seeds" in kw:
        kw["sum_seeds"] = tuple(kw["sum_seeds"])
    return E.make_learner("dfg13", kw, name)


def fit_toy_dfg(suite, target, n, seed, kw=None, d=30, name=None, T=None):
    """One toy fit of DFG alone exactly as eval_dfg.py runs it (TH.evaluate: train_data, test_data, the fit rng,
    Permuted), with every DFG._fit call recorded.  T: the targets dict (built if not given)."""
    T = targets(suite, d) if T is None else T
    fn = T[target]["fn"]
    L = make_learner(kw, name)
    X, y = TH.train_data(fn, target, seed, n, d); Xte, yte = TH.test_data(fn, target, d)
    pi = np.random.default_rng([TH.fn_seed(target), seed, n, 77]).permutation(d)   # the draw Permuted makes first
    with Recorder(type(L.inner)) as R:
        out = L.fit(X, y, np.random.default_rng([TH.fn_seed(target), seed, n, 77]))
    pred = np.asarray(out["predict"](Xte))
    err = float(np.mean(pred != yte))
    fin = R.calls[-1]
    assert fin["n"] == n, (fin["n"], n)
    assert np.array_equal(fin["X"], np.asarray(X, np.float64)[:, pi]), "learner columns are not X[:, pi]"
    Zte = np.asarray(Xte, np.float64)[:, pi]
    v = fin["value"](Zte); err_v = float(np.mean(np.where(v > 0, 1.0, -1.0) != yte))
    assert err_v == err, (err_v, err)                                # the recorded final model is the predictor
    info = out["info"]
    rec = dict(suite=suite, target=target, n=n, seed=seed, d=d, kw=dict(kw or {}), learner=L.name, pi=pi,
               err=err, flops=float(out["flops"]), gd_flops=float(TH.gd_flops(d)), variant=int(info.get("variant", 0)),
               cv_errs=info.get("cv_errs"), train_err=float(fin["info"]["train_err"]), size=int(fin["info"]["size"]),
               rounds=int(fin["info"]["rounds"]), final=fin, Zte=Zte, yte=np.asarray(yte, np.float64), value_te=v,
               calls=[dict(n=c["n"], force=c["force"], hi=c["hi"], scale=c["scale"], flops=c["flops"],
                           size=int(c["info"]["size"]), rounds=int(c["info"]["rounds"]),
                           train_err=float(c["info"]["train_err"])) for c in R.calls],
               meta=dict(relevant=list(T[target].get("relevant", [])), desc=T[target].get("desc", "")))
    rec["terms"] = model_terms(fin, pi, Zte)
    rec["log"] = round_log(fin, pi)
    return rec


# ------------------------------------------------------------------------------------------------ descriptions
def _x(i):
    return f"x{int(i) + 1}"                                             # original 0-indexed input -> 'x1'-style name


def chi_desc(S):
    return "1" if not S else "chi[" + ",".join(_x(i) for i in sorted(S)) + "]"


def _inner_orig(inn, pi):
    """v1.3 inner term (a, kind, j, l, sj, sl) in original coordinates: dict(a, kind, inputs, signs, desc)."""
    if inn is None:
        return None
    a, kind, j, l, sj, sl = inn
    if kind == "lit":
        ins, sg, tau = [int(pi[j])], [1], _x(pi[j])
    elif kind == "par":
        ins, sg, tau = sorted([int(pi[j]), int(pi[l])]), [1, 1], _x(pi[j]) + _x(pi[l])
    else:
        ins, sg = [int(pi[j]), int(pi[l])], [int(sj), int(sl)]
        tau = f"AND({'' if sj > 0 else '-'}{_x(pi[j])},{'' if sl > 0 else '-'}{_x(pi[l])})"
    return dict(a=int(a), kind=kind, inputs=ins, signs=sg, desc=f"{int(a):+d}*{tau}")


def _factor_orig(b, pi):
    o = sorted((int(pi[i]), int(s)) for i, s in zip(b.S, b.sg))
    inn = _inner_orig(b.inner, pi)
    return dict(S=[i for i, _ in o], signs=[s for _, s in o], fold=bool(b.fold), inner=inn,
                edges=[float(e) for e in b.edges])


def block_desc(B, pi):
    """A sum block in original coordinates, 1-indexed: e.g. 'chi[x3]*|x1-x2+x5|', '(x1+x2+x3 +3*x7)', 'A x B'."""
    o = sorted((int(pi[i]), int(s)) for i, s in zip(B.S, B.sg))
    t = "".join(("+" if s > 0 else "-") + _x(i) for i, s in o).lstrip("+")
    inn = _inner_orig(B.inner, pi)
    if inn is not None:
        t += " " + inn["desc"]
    a = f"|{t}|" if B.fold else f"({t})"
    if B.mod:
        a = chi_desc([int(pi[i]) for i in B.mod]) + "*" + a
    return a + ("" if B.other is None else " x " + block_desc(B.other, pi))


def block_support(B, pi):
    """Every original input a block reads: its set, its modulator, its inner term, and those of its product factors."""
    s, b = set(), B
    while b is not None:
        s |= {int(pi[i]) for i in b.S}
        if b.inner is not None:
            s |= set(_inner_orig(b.inner, pi)["inputs"])
        b = b.other
    return s | {int(pi[i]) for i in B.mod}


# ------------------------------------------------------------------------------------------------ the model as terms
def model_terms(f, pi, Zte):
    """The final model value(x) = sum_t w_t phi_t(x) + bg . x as a list of terms in ORIGINAL coordinates (pi maps the
    learner's column j to the original input pi[j]); share = sd of the term's contribution over the test inputs Zte
    (learner coordinates).  A sum block is one term (all its level indicators together)."""
    pi = np.asarray(pi); terms, blocks = [], {}
    for (kind, k), w in zip(f["F"], f["W"]):
        if kind == "chi":
            S = tuple(k); col = np.prod(Zte[:, list(S)], 1) if S else np.ones(len(Zte)); c = w * col
            So = sorted(int(pi[i]) for i in S)
            terms.append(dict(kind="const" if not S else "chi", S=So, deg=len(So), w=float(w), desc=chi_desc(So),
                              share=float(np.std(c)), contrib=c))
        elif kind == "sum":
            bid, v = k; blocks.setdefault(bid, []).append((int(v), float(w)))
        else:                                                         # spectral feature (u . x)^2 - |u|^2
            u = np.asarray(k, np.float64); c = w * ((Zte @ u) ** 2 - u @ u)
            uo = np.zeros(len(u)); uo[pi] = u                           # uo[pi[j]] = u[j]
            sup = np.where(np.abs(uo) > 0.1 * np.abs(uo).max())[0]
            terms.append(dict(kind="quad", S=[int(i) for i in sup], w=float(w), u=[round(float(a), 4) for a in uo],
                              desc=f"quad({len(sup)} inputs)", share=float(np.std(c)), contrib=c))
    for bid, lv in sorted(blocks.items()):
        B = f["B"][bid]; g = B.group(Zte); cm = np.prod(Zte[:, list(B.mod)], 1) if B.mod else np.ones(len(Zte))
        c = sum(w * (g == v) for v, w in lv) * cm
        fac, b = [], B
        while b is not None:
            fac.append(_factor_orig(b, pi)); b = b.other
        terms.append(dict(kind="sum", S=fac[0]["S"], signs=fac[0]["signs"], fold=fac[0]["fold"], inner=fac[0]["inner"],
                          mod=sorted(int(pi[i]) for i in B.mod), factors=fac, product=B.other is not None,
                          support=sorted(block_support(B, pi)), ngroups=int(B.ngroups()), levels={int(v): w for v, w in lv},
                          desc=block_desc(B, pi), bid=int(bid), share=float(np.std(c)), contrib=c))
    bg = np.asarray(f["bg"], np.float64); bo = np.zeros(len(bg)); bo[pi] = bg; c = Zte @ bg
    terms.append(dict(kind="background", w=[round(float(a), 5) for a in bo], desc="background", share=float(np.std(c)),
                      contrib=c))
    return sorted(terms, key=lambda t: -t["share"])


def round_log(f, pi):
    """The final fit's round log in original coordinates: residual rms s, the characters accepted (first 20 of them, as
    DFG logs them) and the block moves accepted ('linear', 'quad', or the sum block's description)."""
    pi = np.asarray(pi); descs = {B.desc(): block_desc(B, pi) for B in f["B"]}
    out = []
    for e in f["info"].get("log", []):
        bl = []
        for b in e["blocks"]:
            bl.append(b if b in ("linear", "quad") else descs.get(b, "(not added: no room) " + b))
        out.append(dict(round=e["round"], s=e["s"], n_new=e["n_new"],
                        new=[chi_desc([int(pi[i]) for i in S]) for S in e["new"]], blocks=bl))
    return out


def model_parts(rec, keep):
    """Test error of the model restricted to the terms t with keep(t) True (the others' contributions removed)."""
    v = sum((t["contrib"] for t in rec["terms"] if keep(t)), np.zeros(len(rec["yte"])))
    return float(np.mean(np.where(v > 0, 1.0, -1.0) != rec["yte"]))


# ------------------------------------------------------------------------------------------------ identity check
def result_file(suite, name="dfg13-perm"):
    p = os.path.join(RESULTS, f"toy__{name}__{suite}.json")
    return p if os.path.exists(p) else None


def check_identity(rec, name=None):
    """Compare a refit with the evaluation's merged result file: test error and FLOP count, exact equality."""
    name = name or rec["learner"]
    p = result_file(rec["suite"], name)
    if p is None:
        return dict(file=None)
    R = json.load(open(p)); r = R["fns"].get(rec["target"])
    if r is None or rec["n"] not in R["ns"] or rec["seed"] not in R["seeds"]:
        return dict(file=os.path.basename(p), cell=False)
    a, b = R["ns"].index(rec["n"]), R["seeds"].index(rec["seed"])
    ef, ff = r["err"][a][b], r["flops"][a][b]
    return dict(file=os.path.basename(p), cell=True, err_file=ef, err_refit=rec["err"], err_equal=bool(ef == rec["err"]),
                flops_file=ff, flops_refit=rec["flops"], flops_equal=bool(ff == rec["flops"]))


# ------------------------------------------------------------------------------------------------ JSON summary
def _clean(v):
    if isinstance(v, dict):
        return {str(k): _clean(x) for k, x in v.items() if k != "contrib"}
    if isinstance(v, (list, tuple)):
        return [_clean(x) for x in v]
    if isinstance(v, np.ndarray):
        return v.tolist()
    if isinstance(v, (np.floating,)):
        return float(v)
    if isinstance(v, (np.integer,)):
        return int(v)
    return v


def cell_json(rec, extra=None):
    o = {k: rec[k] for k in ("suite", "target", "n", "seed", "kw", "learner", "err", "flops", "gd_flops", "variant",
                             "cv_errs", "train_err", "size", "rounds", "calls", "log")}
    o["pi"] = [int(v) for v in rec["pi"]]; o["flops_ratio"] = rec["flops"] / rec["gd_flops"]
    o["terms"] = _clean(rec["terms"])
    if extra:
        o.update(extra)
    return _clean(o)


if __name__ == "__main__":                                            # smoke test: python dfg_hooks.py <suite> <target> <n>
    s, t, n = sys.argv[1], sys.argv[2], int(sys.argv[3])
    r = fit_toy_dfg(s, t, n, 0)
    print(f"{s}/{t} n={n} err={r['err']} variant={r['variant']} cv={r['cv_errs']} size={r['size']} rounds={r['rounds']} "
          f"flops/GD={r['flops'] / r['gd_flops']:.3f} identity={check_identity(r)}")
    for tm in r["terms"][:12]:
        print(f"  {tm['share']:.3f}  {tm['desc']}")
    for e in r["log"]:
        print("  round", e)

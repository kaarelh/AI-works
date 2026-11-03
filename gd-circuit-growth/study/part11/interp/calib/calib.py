"""Part 11, Q7: false admissions and where the compute goes, for DFG v1.3 run alone.

The object: part10/hyb_portfolio3/dfg13.py (md5 69cabe5c50345cb24079198ed52b562f) as DFG(readout="logit").fit, loaded by
part11/eval_dfg.load_dfg13 (md5-checked).  Internals are read from dfg13_instr.py, a copy with recorder calls ADDED
(make_instr.py builds it; `audit` checks with difflib that every difference is an inserted hook line, and every run
checks fits of the copy against the frozen module and the evaluation's result files: test error and FLOP total equal).

  audit      the copy = the frozen module + hook lines (difflib), and the md5 of the frozen module
  noise      (A1) labels independent of the inputs: X uniform +-1 (harness style, nested in n), y iid +-1 with
             P(y = 1) = p, p in {0.5, 0.8}; d = 30 (20 seeds) and d = 60 (10 seeds); n = 16 ... 16384; DFG fitted
             directly (no column permutation: the inputs are exchangeable); test error on 4096 fresh noise points.
             Every admitted feature by kind, the CV's variant (n <= 512), rounds, per-class test ratios.
  spur       (A2) designed and random suites, seed 0, every grid n, exactly as eval_dfg.py (harness data, fit rng,
             Permuted); the final model's terms in original coordinates against each target's exact relevant set.
  prof       (B) where FLOPs and CPU time go: par4, maj9, mux, stair5 (designed), f7_07, f7_08, f7_05 (dlheld7) and
             pure noise (p = 0.5) at n = 64, 512, 4096, 16384, seed 0; regions of DFG._fit by FLOP-counter differencing.
  summarize  tables from the records above and from the result files (FLOPs and CPU per fit, every suite, d = 15 ... 120);
             writes calib.json.
usage: OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python calib.py <command> [--d=30] [--seeds=0-19] [--ps=0.5,0.8]
records: results/noise.jsonl, results/spur.jsonl, results/prof.jsonl (resumable: done keys are skipped).
"""
import os, sys, json, time, math, re, difflib, hashlib, importlib.util
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__)); INTERP = os.path.dirname(HERE); P11 = os.path.dirname(INTERP)
STUDY = os.path.dirname(P11)
sys.path.insert(0, P11)
import eval_dfg as E                                                    # noqa: E402  (sets sys.path as the runner does)
TH, boolfuncs = E.TH, E.boolfuncs
sys.path.insert(0, HERE)
import calib_rec                                                        # noqa: E402
REC = calib_rec.REC
INSTR = os.path.join(HERE, "dfg13_instr.py")
RES = os.path.join(HERE, "results"); os.makedirs(RES, exist_ok=True)
NS = TH.NS
DELTA, KDEG = 0.1, 4


# ------------------------------------------------------------------------------------------------ modules and audit
def load_instr():
    sp = importlib.util.spec_from_file_location("dfg13_instr", INSTR)
    m = importlib.util.module_from_spec(sp); sp.loader.exec_module(m)
    return m


HOOK = re.compile(r"^\s*_P\.\w+\(.*\)(; _P\.\w+\(.*\))*$")


def audit():
    """Every difference between dfg13.py and dfg13_instr.py is an inserted line: the recorder import, or calls into it."""
    a = open(E.DFG13).read().split("\n"); b = open(INSTR).read().split("\n")
    md5 = hashlib.md5(open(E.DFG13, "rb").read()).hexdigest()
    ins, bad = [], []
    for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(a=a, b=b, autojunk=False).get_opcodes():
        if tag == "equal":
            continue
        if tag != "insert":
            bad.append((tag, i1, i2, j1, j2)); continue
        ins += b[j1:j2]
    bad += [L for L in ins if not (L == "from calib_rec import REC as _P" or HOOK.match(L))]
    return dict(md5_frozen=md5, md5_ok=md5 == E.MD5, lines_frozen=len(a), lines_instr=len(b), inserted=len(ins),
                non_hook_differences=bad, ok=(md5 == E.MD5 and not bad and len(b) - len(a) == len(ins)))


# ------------------------------------------------------------------------------------------------ fits
def _closure(fn):
    return dict(zip(fn.__code__.co_freevars, [c.cell_contents for c in (fn.__closure__ or ())]))


def fit_one(mod, X, y, rng, permuted, detail=False, record=True):
    """One fit as the harness makes it (process time around learner.fit); with record, REC holds every _fit call."""
    L = mod.DFG(readout="logit"); learner = TH.Permuted(L) if permuted else L
    if record:
        REC.reset(detail)
    t0 = time.process_time()
    out = learner.fit(X, y, rng)
    cpu = time.process_time() - t0
    if record:
        REC.stop()
    return out, cpu, (list(REC.calls) if record else None)


def model_of(out, permuted):
    """The final model in learner coordinates (F, W, B, bg, value) and pi (learner column j = original input pi[j])."""
    pr = out["predict"]; pi = None
    if permuted:
        pr, pi = pr.__defaults__
    val = _closure(pr)["value"]; vc = _closure(val)
    return dict(F=list(vc["F"]), W=np.array(vc["W"], dtype=np.float64), B=list(vc["B"]), bg=np.array(vc["bg"]), value=val,
                pi=None if pi is None else np.asarray(pi))


def block_support(B):
    """Learner columns a sum block reads: its set, modulator, inner term, and those of its product factors."""
    s, b = set(), B
    while b is not None:
        s |= {int(i) for i in b.S}
        if b.inner is not None:
            s |= {int(b.inner[2])} | ({int(b.inner[3])} if b.inner[1] != "lit" else set())
        b = b.other
    return s | {int(i) for i in B.mod}


def terms_of(mdl, origins, Zte):
    """The model value(x) = sum_t w_t phi_t(x) + bg . x as terms, with ORIGINAL input sets (via pi), origin (the class or
    block move that admitted it), and contribution on the test inputs Zte (learner coordinates)."""
    F, W, Bs, pi = mdl["F"], mdl["W"], mdl["B"], mdl["pi"]
    o = (lambda S: sorted(int(pi[i]) for i in S)) if pi is not None else (lambda S: sorted(int(i) for i in S))
    assert len(origins) == len(F), (len(origins), len(F))
    terms, blocks = [], {}
    for (kind, k), w, org in zip(F, W, origins):
        if kind == "chi":
            S = tuple(k); c = w * (np.prod(Zte[:, list(S)], 1) if S else np.ones(len(Zte)))
            terms.append(dict(kind="const" if not S else "chi", origin=org[1], rnd=org[2], S=o(S), deg=len(S), c=c))
        elif kind == "sum":
            bid, v = k; blocks.setdefault(bid, []).append((v, float(w), org))
        else:
            u = np.asarray(k, np.float64); c = w * ((Zte @ u) ** 2 - u @ u)
            uo = np.zeros(len(u))
            if pi is not None:
                uo[pi] = u
            else:
                uo[:] = u
            sup = np.where(np.abs(uo) > 0.1 * np.abs(uo).max())[0]
            terms.append(dict(kind="quad", origin="quad", rnd=org[2], S=[int(i) for i in sup], u2=(uo ** 2).tolist(), c=c))
    for bid, lv in sorted(blocks.items()):
        B = Bs[bid]; g = B.group(Zte); cm = np.prod(Zte[:, list(B.mod)], 1) if B.mod else np.ones(len(Zte))
        c = sum(w * (g == v) for v, w, _ in lv) * cm
        terms.append(dict(kind="sum", origin=lv[0][2][1], rnd=lv[0][2][2], S=o(block_support(B)), nfeat=len(lv),
                          desc=B.desc(), product=B.other is not None, c=c))
    terms.append(dict(kind="background", origin="background", rnd=-1, S=[], c=Zte @ mdl["bg"]))
    tot = sum(t["c"] for t in terms); v = mdl["value"](Zte)
    assert np.allclose(tot, v, atol=1e-8 * (1 + np.abs(v).max())), "terms do not add up to the model value"
    return terms, v


def call_rounds(c):
    out = []
    for rd in c["rounds"]:
        added = {}
        for kind, org, S in rd["added"]:
            key = f"{kind}:{org}" + (f":{len(S)}" if (kind == "chi" and S is not None) else "")
            added[key] = added.get(key, 0) + 1
        out.append(dict(rnd=rd["rnd"], stage=rd["stage"], s=rd["s"],
                        cls={k: [round(v["maxz"], 5), v["npass"], v["noff"]] for k, v in rd["cls"].items()},
                        sub={k: v[0] if len(set(v)) == 1 else v for k, v in rd["sub"].items()},
                        top=None if rd["top"][1] is None else [round(rd["top"][0], 5), list(rd["top"][1]), rd["top"][2]],
                        lin=rd["lin"], quad=rd["quad"], bs=rd["bs"], acc=[a["kind"] for a in rd["acc"]],
                        acc_desc=[a["desc"] for a in rd["acc"]], forced=rd["forced"], sel=rd["sel"], added=added,
                        blocks_added=rd.get("blocks_added", [])))
    return out


def stop_reason(c, rounds_max=8):
    if not c["rounds"]:
        return "none"
    st = c["rounds"][-1]["stage"]
    if st == "start":
        return "fit"                      # exact fit or every training sign right (the LS fit, before the background)
    if st in ("fitcheck_ok", "budget_ok"):
        return "budget" if st == "fitcheck_ok" else "unknown"
    if st == "sel":
        sel = c["rounds"][-1]["sel"]
        return "nothing" if (sel["n_new"] == 0 and sel["n_blk"] == 0) else "room"
    return "rounds" if len(c["rounds"]) >= rounds_max else "unknown"


def adm_counts(c):
    """Admitted features of one _fit call by kind (origin = the class or move that admitted them; chars by degree)."""
    feats, blocks = {}, {}
    for kind, org, rnd, S in c["origins"][1:]:
        key = f"{kind}:{org}" + (f":{len(S)}" if kind == "chi" else "")
        feats[key] = feats.get(key, 0) + 1
    for rd in c["rounds"]:
        for b in rd.get("blocks_added", []):
            blocks[b["kind"]] = blocks.get(b["kind"], 0) + 1
    return feats, blocks


def call_json(c, rounds=True):
    feats, blocks = adm_counts(c)
    o = dict(n=c["n"], force=c["force"], hi=c["hi"], scale=c["scale"], flops=c["flops"], rounds_done=c["rounds_done"],
             size=c["size"], train_err=c["train_err"], stop=stop_reason(c), feats=feats, blocks=blocks)
    if rounds:
        o["rounds"] = call_rounds(c)
    return o


def jl_keys(path):
    if not os.path.exists(path):
        return set()
    return {json.loads(L)["key"] for L in open(path) if L.strip()}


def jl_append(path, rec):
    with open(path, "a") as f:
        f.write(json.dumps(rec, default=_jd) + "\n")


def _jd(v):
    if isinstance(v, (np.integer,)):
        return int(v)
    if isinstance(v, (np.floating,)):
        return float(v)
    if isinstance(v, np.ndarray):
        return v.tolist()
    if isinstance(v, (set, tuple)):
        return list(v)
    raise TypeError(type(v))


# ------------------------------------------------------------------------------------------------ (A1) pure noise
def noise_name(p, d):
    return f"noise_p{int(round(100 * p))}_d{d}"


def noise_data(p, d, seed, n):
    """Harness style (train_data): rng = default_rng([fn_seed(name), seed]), 16384 rows nested in n; y iid, P(y=1) = p."""
    rng = np.random.default_rng([TH.fn_seed(noise_name(p, d)), seed])
    X = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(TH.N_MAX, d))
    y = np.where(rng.random(TH.N_MAX) < p, 1.0, -1.0).astype(np.float32)
    return X[:n], y[:n]


def noise_test(p, d):
    rng = np.random.default_rng([TH.fn_seed(noise_name(p, d)), 10 ** 6])
    X = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(TH.N_TEST, d))
    return X, np.where(rng.random(TH.N_TEST) < p, 1.0, -1.0).astype(np.float32)


def run_noise(d, ps, seeds, ns, frozen_seeds):
    M = load_instr(); FZ = E.load_dfg13(); path = os.path.join(RES, "noise.jsonl"); done = jl_keys(path)
    for p in ps:
        Xte, yte = noise_test(p, d)
        for n in ns:
            for s in seeds:
                key = f"{d}:{p}:{n}:{s}"
                if key in done:
                    continue
                X, y = noise_data(p, d, s, n); rng = lambda: np.random.default_rng([TH.fn_seed(noise_name(p, d)), s, n, 77])
                out, cpu, calls = fit_one(M, X, y, rng(), permuted=False, detail=True)
                pred = np.asarray(out["predict"](Xte)); err = float(np.mean(pred != yte))
                mdl = model_of(out, False); fin = calls[-1]
                terms, v = terms_of(mdl, fin["origins"], np.asarray(Xte, np.float64))
                adm = [t for t in terms if t["kind"] not in ("const", "background")]
                rec = dict(key=key, d=d, p=p, n=n, seed=s, err=err, frac_neg=float(np.mean(pred < 0)), ybar=float(np.mean(y)),
                           variant=int(out["info"].get("variant", 0)), cv_errs=out["info"].get("cv_errs"),
                           flops=float(out["flops"]), gd=float(TH.gd_flops(d)), cpu=cpu,
                           final=call_json(fin), folds=[call_json(c, rounds=False) for c in calls[:-1]],
                           sd_model=float(np.std(v)), sd_admitted=float(np.std(sum((t["c"] for t in adm), np.zeros(len(v))))),
                           sd_bg=float(np.std(terms[-1]["c"])),
                           terms=[dict(kind=t["kind"], origin=t["origin"], S=t["S"], sd=float(np.std(t["c"]))) for t in adm])
                if s in frozen_seeds:
                    o2, cpu2, _ = fit_one(FZ, X, y, rng(), permuted=False, record=False)
                    e2 = float(np.mean(np.asarray(o2["predict"](Xte)) != yte))
                    rec["frozen"] = dict(err=e2, flops=float(o2["flops"]), cpu=cpu2, equal=bool(e2 == err and o2["flops"] == out["flops"]))
                    assert rec["frozen"]["equal"], (key, e2, err, o2["flops"], out["flops"])
                jl_append(path, rec)
                f = rec["final"]
                print(f"noise d={d} p={p} n={n:5d} s={s:2d} err={err:.3f} var={rec['variant']} rounds={f['rounds_done']} "
                      f"feats={f['feats']} blocks={f['blocks']} cpu={cpu:.2f}" + (" frozen=ok" if "frozen" in rec else ""), flush=True)


# ------------------------------------------------------------------------------------------------ (A2) spurious features
def suite_targets(suite, d=30):
    if suite in E.DL:
        return getattr(boolfuncs, E.DL[suite])(d)
    return TH.suite_targets(suite, d)[0]


def relevant_exact(fn, d=30, K=12, m=20000):
    """The inputs f depends on.  Every designed / random target reads only x[:, :k] with k <= 10 (boolfuncs: explicit
    indices < 10; _random_formula(rng, k, .) reads x[:, :k], k <= 8), so enumerating all 2^K assignments of the first
    K = 12 inputs (the others +1) decides dependence exactly; inputs >= K are also checked on m random points."""
    B = (np.arange(1 << K)[:, None] >> np.arange(K)[None, :]) & 1
    X = np.ones((1 << K, d)); X[:, :K] = 1 - 2 * B; f0 = fn(X); rel = []
    for i in range(K):
        Xi = X.copy(); Xi[:, i] = -Xi[:, i]
        if np.any(fn(Xi) != f0):
            rel.append(i)
    Z = np.random.default_rng(0).choice([-1.0, 1.0], size=(m, d)); fz = fn(Z)
    extra = [i for i in range(K, d) if np.any(fn(Z * np.where(np.arange(d) == i, -1.0, 1.0)) != fz)]
    return rel, extra


def classify_terms(terms, rel):
    """S (spurious) = reads an irrelevant input; spectral features: < 90% of |u|^2 on relevant inputs (the atlas's rule)
    and, separately, any input with |u_i| > 0.1 max |u| irrelevant."""
    rel = set(rel)
    for t in terms:
        if t["kind"] in ("const", "background"):
            t["spur"] = None; continue
        if t["kind"] == "quad":
            u2 = np.asarray(t["u2"]); m = float(u2[list(rel)].sum() / max(u2.sum(), 1e-300)); t["mass_rel"] = m
            t["spur"] = m < 0.9; t["spur_support"] = not set(t["S"]) <= rel
        else:
            t["spur"] = not set(t["S"]) <= rel
        t["irr"] = sorted(set(t["S"]) - rel)


def term_cat(t):
    """chi_test (an individually tested character), chi_lin (entered with the linear block), chi_forced, quad, sum,
    sum_forced."""
    if t["kind"] == "chi":
        return {"linear": "chi_lin", "forced": "chi_forced"}.get(t["origin"], "chi_test")
    if t["kind"] == "sum":
        return "sum_forced" if t["origin"] == "forced_block" else "sum"
    return t["kind"]


def run_spur(suites=("designed", "random"), seed=0, fns=None, ns=None, path=None):
    M = load_instr(); path = path or os.path.join(RES, "spur.jsonl"); done = jl_keys(path)
    for suite in suites:
        T = suite_targets(suite); R = json.load(open(os.path.join(P11, "results", f"toy__dfg13-perm__{suite}.json")))
        for name in T:
            if fns and name not in fns:
                continue
            fn = T[name]["fn"]; rel, extra = relevant_exact(fn)
            Xte, yte = TH.test_data(fn, name, 30)
            for n in (ns or NS):
                key = f"{suite}:{name}:{n}:{seed}"
                if key in done:
                    continue
                X, y = TH.train_data(fn, name, seed, n, 30)
                out, cpu, calls = fit_one(M, X, y, np.random.default_rng([TH.fn_seed(name), seed, n, 77]), permuted=True,
                                          detail=True)
                pred = np.asarray(out["predict"](Xte)); err = float(np.mean(pred != yte))
                a, b = R["ns"].index(n), R["seeds"].index(seed); ef, ff = R["fns"][name]["err"][a][b], R["fns"][name]["flops"][a][b]
                mdl = model_of(out, True); fin = calls[-1]; Zte = np.asarray(Xte, np.float64)[:, mdl["pi"]]
                terms, v = terms_of(mdl, fin["origins"], Zte); classify_terms(terms, rel)
                sdv = float(np.std(v)); adm = [t for t in terms if t["spur"] is not None]
                sp = [t for t in adm if t["spur"]]
                csp = sum((t["c"] for t in sp), np.zeros(len(v))); cadm = sum((t["c"] for t in adm), np.zeros(len(v)))
                err_noS = float(np.mean(np.where(v - csp > 0, 1.0, -1.0) != yte))
                cats = {}
                for t in sp:
                    cats.setdefault(term_cat(t), []).append(t)
                rec = dict(key=key, suite=suite, target=name, n=n, seed=seed, rel=rel, rel_suite=list(T[name]["relevant"]),
                           extra_dep=extra, err=err, err_file=ef, flops=float(out["flops"]), flops_file=ff,
                           identical=bool(err == ef and out["flops"] == ff), variant=int(out["info"].get("variant", 0)),
                           cpu=cpu, final=call_json(fin), sd_model=sdv, sd_admitted=float(np.std(cadm)),
                           sd_spur=float(np.std(csp)), share_spur=float(np.std(csp)) / max(sdv, 1e-300), err_noS=err_noS,
                           n_terms=len(adm), n_spur=len(sp),
                           cat={k: dict(n=len(L), sd=float(np.std(sum((t["c"] for t in L), np.zeros(len(v)))))) for k, L in cats.items()},
                           terms=[dict(kind=t["kind"], cat=term_cat(t), origin=t["origin"], rnd=t["rnd"], S=t["S"],
                                       irr=t.get("irr"), spur=t["spur"], sd=float(np.std(t["c"])), desc=t.get("desc"),
                                       mass_rel=t.get("mass_rel"), spur_support=t.get("spur_support"))
                                  for t in adm])
                assert rec["identical"], (key, err, ef, out["flops"], ff)
                jl_append(path, rec)
                print(f"spur {suite}/{name} n={n:5d} err={err:.4f} (file {ef:.4f}) terms={len(adm)} spur={len(sp)} "
                      f"share={rec['share_spur']:.3f} cats={ {k: v_['n'] for k, v_ in rec['cat'].items()} } cpu={cpu:.2f}", flush=True)


# ------------------------------------------------------------------------------------------------ (B) compute profile
PROF = [("designed", "par4"), ("designed", "maj9"), ("designed", "mux"), ("designed", "stair5"), ("dlheld7", "f7_07"),
        ("dlheld7", "f7_08"), ("dlheld7", "f7_05"), ("noise", "p50")]
PROF_NS = [64, 512, 4096, 16384]


def run_prof(seed=0):
    M = load_instr(); FZ = E.load_dfg13(); path = os.path.join(RES, "prof.jsonl"); done = jl_keys(path)
    for suite, name in PROF:
        if suite == "noise":
            p, d = 0.5, 30; Xte, yte = noise_test(p, d); R = None
            data = lambda n: noise_data(p, d, seed, n); rngf = lambda n: np.random.default_rng([TH.fn_seed(noise_name(p, d)), seed, n, 77])
            perm = False
        else:
            T = suite_targets(suite); fn = T[name]["fn"]; Xte, yte = TH.test_data(fn, name, 30)
            R = json.load(open(os.path.join(P11, "results", f"toy__dfg13-perm__{suite}.json")))
            data = lambda n, fn=fn, name=name: TH.train_data(fn, name, seed, n, 30)
            rngf = lambda n, name=name: np.random.default_rng([TH.fn_seed(name), seed, n, 77]); perm = True
        for n in PROF_NS:
            key = f"{suite}:{name}:{n}:{seed}"
            if key in done:
                continue
            X, y = data(n)
            o2, cpu2, _ = fit_one(FZ, X, y, rngf(n), permuted=perm, record=False)          # the frozen module first
            e2 = float(np.mean(np.asarray(o2["predict"](Xte)) != yte))
            out, cpu, calls = fit_one(M, X, y, rngf(n), permuted=perm, detail=False)
            err = float(np.mean(np.asarray(out["predict"](Xte)) != yte))
            rec = dict(key=key, suite=suite, target=name, n=n, seed=seed, err=err, flops=float(out["flops"]), cpu=cpu,
                       gd=float(TH.gd_flops(30)), frozen=dict(err=e2, flops=float(o2["flops"]), cpu=cpu2),
                       equal_frozen=bool(e2 == err and o2["flops"] == out["flops"]),
                       variant=int(out["info"].get("variant", 0)), rounds=int(out["info"]["rounds"]),
                       calls=[dict(n=c["n"], force=c["force"], hi=c["hi"], scale=c["scale"], flops=c["flops"],
                                   rounds_done=c["rounds_done"], size=c["size"], ovh=c["ovh"],
                                   reg={k: [v[0], v[1], v[2]] for k, v in c["reg"].items()},
                                   sub=[rd["sub"] for rd in c["rounds"]], stop=stop_reason(c)) for c in calls])
            if R is not None:
                a, b = R["ns"].index(n), R["seeds"].index(seed)
                rec.update(err_file=R["fns"][name]["err"][a][b], flops_file=R["fns"][name]["flops"][a][b],
                           cpu_file=R["fns"][name]["cpu_seconds"][a][b])
                rec["equal_file"] = bool(rec["err_file"] == err and rec["flops_file"] == out["flops"])
            assert rec["equal_frozen"] and rec.get("equal_file", True), key
            jl_append(path, rec)
            tot = {}
            for c in calls:
                for k, v in c["reg"].items():
                    tot[k] = tot.get(k, 0.0) + v[0]
            print(f"prof {suite}/{name} n={n:5d} err={err:.4f} flops/GD={out['flops'] / rec['gd']:.4f} cpu={cpu:.2f} (frozen {cpu2:.2f}) "
                  f"calls={len(calls)} top={sorted(((round(v / out['flops'], 3), k) for k, v in tot.items()), reverse=True)[:4]}", flush=True)


if __name__ == "__main__":
    a = sys.argv[1:]; opt = {k[2:].split("=", 1)[0]: k.split("=", 1)[1] for k in a if k.startswith("--")}
    cmd = [x for x in a if not x.startswith("--")][0]
    rng_ = lambda s: list(range(int(s.split("-")[0]), int(s.split("-")[1]) + 1)) if "-" in s else [int(v) for v in s.split(",")]
    if cmd == "audit":
        print(json.dumps(audit(), indent=1))
    elif cmd == "noise":
        d = int(opt.get("d", 30)); seeds = rng_(opt.get("seeds", "0-19" if d == 30 else "0-9"))
        ps = [float(v) for v in opt.get("ps", "0.5,0.8").split(",")]
        ns = [int(v) for v in opt["ns"].split(",")] if "ns" in opt else NS
        assert audit()["ok"]
        run_noise(d, ps, seeds, ns, frozen_seeds=set(rng_(opt.get("frozen", "0-1"))))
    elif cmd == "spur":
        assert audit()["ok"]
        run_spur(tuple(opt.get("suites", "designed,random").split(",")), fns=opt["fns"].split(",") if "fns" in opt else None,
                 ns=[int(v) for v in opt["ns"].split(",")] if "ns" in opt else None, path=opt.get("out"))
    elif cmd == "prof":
        assert audit()["ok"]
        run_prof()
    elif cmd == "summarize":
        import calib_summary
        calib_summary.main()
    else:
        raise SystemExit(__doc__)

"""What structure does the learner's DFG member learn on a toy target, and at which n?  (Descriptive analysis.)
For each n of the toy grid (seed s), the fit of eval_toy.py --perm is reproduced (hooks.fit_toy) and summarised:
  err          the whole learner's test error (equals the evaluation's cell: same rows, same rng)
  err_dfg      the final DFG member alone (sign of its value); where the stacker gave DFG no weight (no final fit),
               the last out-of-fold DFG fit is summarised instead (dfg_source says which)
  w_dfg        the stacker's weight share of the DFG members (dfg + dfg_forced) among all kept members
  terms        the DFG model's largest terms in original coordinates (hooks.dfg_terms; share = sd of the term's output)
  support      inputs used by terms with share >= 5% of the largest (precision / recall against the true relevant set)
  classes      for each true signed-symmetry class of size >= 3 (hooks.symmetry_classes): the best-matching sum block
               (Jaccard of the sets; sign_ok = signs agree up to a global flip; exact = both)
  fourier_chi  the target's Fourier weight on the characters in the model (sum of fhat(S)^2 over its chi_S)
  g            per class: [t, count, mean target, mean DFG value] over the test inputs at each value of the class's
               signed sum t (the learned accept set against the true one)
  span_r2      held-out R^2 of the target on the span of the model's features (least squares on half the test inputs,
               scored on the other half): how much of f the learned dictionary can express, whatever the weights
The grid stops early after two consecutive n with err <= 0.005.
usage: python toy_structure.py <suite> [targets,...] [--seed=0] [--learner=path] [--tag=v2]
writes results/toy/<tag>/<suite>__<target>__s<seed>.json"""
import os, sys, json, time, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import hooks as H

suite = sys.argv[1]; args = [a for a in sys.argv[2:] if not a.startswith("--")]
opt = {a.split("=", 1)[0][2:]: a.split("=", 1)[1] for a in sys.argv[2:] if a.startswith("--") and "=" in a}
seed = int(opt.get("seed", 0)); tag = opt.get("tag", "v2"); path = opt.get("learner", H.V2)
T = H.targets(suite); names = args[0].split(",") if args else list(T)
HP = H.load_learner(path)
out_dir = os.path.join(os.environ.get("INTERP_OUT", os.path.join(HERE, "results")), "toy", tag)   # INTERP_OUT: live runs write outside the repository; os.makedirs(out_dir, exist_ok=True)


def summarise(r, truth, F):
    f = H.final_dfg(r, fallback=True); w = r["info"].get("weights", {}); tot = sum(w.values()) or 1.0
    o = dict(n=r["n"], err=r["err"], w_dfg=round(sum(v for k, v in w.items() if k.startswith("dfg")) / tot, 3),
             weights=w, flops=r["flops"])
    if f is None:
        return dict(o, dfg=None)
    o["dfg_source"] = "final" if f["n"] == r["n"] else f"out-of-fold fit on {f['n']} rows (no final fit: zero stack weight)"
    o["err_dfg"] = float(np.mean(np.where(f["value"](r["Xte"]) > 0, 1.0, -1.0) != r["yte"]))
    terms = H.dfg_terms(r); top = max([t["share"] for t in terms] + [1e-12])
    o["terms"] = [{k: v for k, v in t.items() if k not in ("w",) or t["kind"] != "background"} for t in terms[:10]]
    o["n_terms"] = dict(chi=sum(t["kind"] == "chi" for t in terms), sum=sum(t["kind"] == "sum" for t in terms))
    used = set()
    for t in terms:
        if t["kind"] in ("chi", "sum", "quad") and t["share"] >= 0.05 * top:
            used |= set(t["S"]) | set(t.get("mod", []))
    rel = set(truth["relevant"])
    o["support"] = dict(used=sorted(used), precision=len(used & rel) / max(len(used), 1), recall=len(used & rel) / len(rel))
    cls = []
    for c in truth["classes"]:
        if len(c["S"]) < 3:
            continue
        best = dict(jaccard=0.0, sign_ok=False, exact=False, desc=None, share=0.0)
        for t in terms:
            if t["kind"] != "sum":
                continue
            S = set(t["S"]); J = len(S & set(c["S"])) / len(S | set(c["S"]))
            sg = dict(zip(t["S"], t["signs"])); ok = [(i, s) for i, s in zip(c["S"], c["signs"]) if s is not None and i in sg]
            agree = bool(ok) and (all(sg[i] == s for i, s in ok) or all(sg[i] == -s for i, s in ok))
            if (J, agree, t["share"]) > (best["jaccard"], best["sign_ok"], best["share"]):
                best = dict(jaccard=round(J, 3), sign_ok=agree, exact=J == 1.0 and (agree or not ok), desc=t["desc"], share=t["share"])
        cls.append(dict(S=c["S"], signs=c["signs"], **best))
    # the learned function of each true class's signed sum t (classes of size >= 3): mean DFG value and mean target by t
    inv = np.argsort(r["pi"]); val = f["value"](r["Xte"])
    for c in cls:
        sg = np.array([s if s is not None else 1 for s in c["signs"]], float)
        tt = r["Xte"][:, inv[c["S"]]] @ sg; lv = np.unique(tt)
        c["g"] = [[float(v), int(np.sum(tt == v)), round(float(np.mean(r["yte"][tt == v])), 3), round(float(np.mean(val[tt == v])), 3)]
                  for v in lv]                                          # [t, count, mean target, mean model value]
    o["classes"] = cls
    o["fourier_chi"] = round(sum(F.get(tuple(t["S"]), 0.0) ** 2 for t in terms if t["kind"] == "chi"), 4)
    A = H.dfg_columns(f, r["Xte"]); yv = r["yte"].astype(np.float64); h = len(yv) // 2
    wls, *_ = np.linalg.lstsq(A[:h], yv[:h], rcond=None); res = yv[h:] - A[h:] @ wls
    o["span_r2"] = round(float(1 - np.mean(res ** 2) / np.var(yv[h:])), 4)
    o["dfg_log"] = [dict(round=e["round"], n_new=e["n_new"], blocks=e["blocks"]) for e in f["info"].get("log", [])]
    return o


for name in names:
    p = os.path.join(out_dir, f"{suite}__{name}__s{seed}.json")
    res = json.load(open(p)) if os.path.exists(p) else None
    if res is not None and res.get("complete"):
        continue
    t = T[name]; truth = dict(relevant=list(t["relevant"]), desc=t["desc"],
                              classes=H.symmetry_classes(t["fn"], t["relevant"]))
    F = H.fourier(t["fn"], t["relevant"]) if len(t["relevant"]) <= 16 else {}
    res = res or dict(suite=suite, target=name, seed=seed, learner=path, truth=truth,
                      fourier_top=sorted(([list(k), v] for k, v in F.items()), key=lambda kv: -abs(kv[1]))[:12], cells=[])
    done = {c["n"] for c in res["cells"]}; good = 0
    for c in res["cells"]:
        good = good + 1 if c["err"] <= 0.005 else 0
    for n in H.TH.NS:
        if n in done:
            continue
        if good >= 2:
            break
        t0 = time.process_time(); r = H.fit_toy(HP, suite, name, n, seed)
        c = summarise(r, truth, F); c["cpu"] = round(time.process_time() - t0, 1); res["cells"].append(c)
        good = good + 1 if c["err"] <= 0.005 else 0
        json.dump(res, open(p + ".tmp", "w"), default=lambda v: v.item() if hasattr(v, "item") else str(v)); os.replace(p + ".tmp", p)
        cl = ";".join(f"J={x['jaccard']}{'+' if x['sign_ok'] else ''}" for x in c.get("classes", []))
        print(f"{suite}/{name} n={n} err={c['err']:.4f} dfg={c.get('err_dfg', float('nan')):.4f} w_dfg={c['w_dfg']} "
              f"chi={c.get('fourier_chi')} r2={c.get('span_r2')} {cl} cpu={c['cpu']}s", flush=True)
    res["complete"] = True
    json.dump(res, open(p + ".tmp", "w"), default=lambda v: v.item() if hasattr(v, "item") else str(v)); os.replace(p + ".tmp", p)

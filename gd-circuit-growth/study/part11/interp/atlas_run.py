"""Part 11 structure atlas, step 1: seed-0 fits of DFG v1.3 ALONE on the whole n grid (16 ... 16384) for the atlas
targets (atlas_truth.ATLAS), each reproduced exactly as part11/eval_dfg.py fits it (dfg_hooks.fit_toy_dfg), with the
fitted model described against the target's own representation (atlas_truth.spec).  Descriptive; nothing is tuned.

Per cell (target, n): test error, train error, the variant DFG's own cross-validation chose (n <= 512) and its held-out
errors, model size, FLOPs, the round log, every term of the model in original coordinates with its share (sd of its
contribution over the 4096 test inputs) and its category against the target:
  T  target term: a character in the target's Fourier support or in one of its compact representations (atlas_truth),
     or a sum block whose every factor has a true block's set and signs (up to a global flip; folded only if the true
     accept set is even); flags: sign_ok (characters: sign of the weight = sign of the representation's coefficient /
     of fhat), inner_ok (weighted blocks: inner term right), coupled (an inner term or modulator the truth does not have,
     on relevant inputs)
  R  relevant but not a target term: every input relevant (characters with fhat = 0, partial or wrong-sign blocks,
     spectral features with >= 90% of |u|^2 on relevant inputs)
  S  spurious: reads an irrelevant input (flag exact_factor: a product whose other factor is a true block)
and the cell summaries: share of each category (sd of the category's summed contribution / sd of the model value), test
error with parts removed, which compact representations are complete in the model, the Fourier weight carried by the
characters present, and the span R^2 / oracle sign error of the learned feature set (fit on half of the test inputs,
scored on the other half).
usage: OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python atlas_run.py [suite:target,...]
writes results/atlas/<suite>__<target>.json (resumable: cells already present are skipped)"""
import os, sys, json, time, math, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import dfg_hooks as H                                                  # noqa: E402
import atlas_truth as A                                                # noqa: E402

OUT = os.path.join(HERE, "results", "atlas"); os.makedirs(OUT, exist_ok=True)
NS = H.TH.NS


# ------------------------------------------------------------------------------------------------ spec as JSON
def spec_json(sp):
    o = {k: sp[k] for k in ("rel", "k", "desc", "family", "combine", "couple", "W", "classes")}
    o["reps"] = []
    for r in sp["reps"]:
        q = {k: v for k, v in r.items() if k not in ("chars",)}
        if "chars" in r:
            q["chars"] = [[list(S), c] for S, c in sorted(r["chars"].items(), key=lambda kv: (len(kv[0]), kv[0]))]
        o["reps"].append(q)
    F = sp["fourier"]
    o["n_fourier"] = None if F is None else len(F)
    o["fourier_top"] = None if F is None else [[list(S), v] for S, v in sorted(F.items(), key=lambda kv: -abs(kv[1]))[:16]]
    return o


# ------------------------------------------------------------------------------------------------ classification
def _nsg(signs):
    return [int(s * signs[0]) for s in signs]


def factor_vs(fac, tb):
    """A block factor (term) against a true block: None if the sets differ, else dict(signs, fold_ok, inner_ok, extra)."""
    if fac["S"] != tb["S"]:
        return None
    sig = _nsg(fac["signs"]) == _nsg(tb["signs"]); flip = fac["signs"][0] * tb["signs"][0]
    fold_ok = (not fac["fold"]) or tb["even"]
    ti, fi = tb["inner"], fac.get("inner")
    if ti is None:
        inner_ok, extra = fi is None, fi is not None
    elif fi is None:
        inner_ok, extra = False, False
    else:
        same = fi["kind"] == ti["kind"] and (sorted(zip(fi["inputs"], fi["signs"])) == sorted(zip(ti["inputs"], ti["signs"]))
                                             if fi["kind"] == "and" else sorted(fi["inputs"]) == sorted(ti["inputs"]))
        inner_ok, extra = bool(same and fi["a"] * flip == ti["a"]), False
    return dict(signs=sig, fold_ok=fold_ok, inner_ok=inner_ok, extra_inner=extra)


def classify(rec, sp):
    rel = set(sp["rel"]); F = sp["fourier"]
    rep_chars = {}
    for r in sp["reps"]:
        for S, c in r.get("chars", {}).items():
            if S:
                rep_chars.setdefault(tuple(S), c)
    tblocks = [b for r in sp["reps"] for b in r.get("blocks", [])]
    odd = sp["family"].startswith("Gaussian halfspace")                     # thr30: f odd, no Fourier table
    # degree-1 characters that entered through the linear block (all d inputs at once) rather than one by one: those
    # not in any round's list of accepted characters (DFG logs the first 20 per round; with more the split is unknown)
    lin_round = any("linear" in e["blocks"] for e in rec["log"])
    listed = {d_ for e in rec["log"] for d_ in e["new"]}
    rec["linear_uncertain"] = lin_round and any(e["n_new"] > 20 for e in rec["log"])
    for t in rec["terms"]:
        if t["kind"] == "chi" and t["deg"] == 1:
            t["via_linear"] = bool(lin_round and t["desc"] not in listed)
        k = t["kind"]
        if k in ("const", "background"):
            t["cat"] = None; continue
        if k == "chi":
            S = tuple(t["S"]); inr = set(S) <= rel
            fh = F.get(S, 0.0) if F is not None else None
            sup = (fh is not None and abs(fh) > 1e-12) or (F is None and odd and len(S) % 2 == 1)
            t["cat"] = "S" if not inr else ("T" if (sup or S in rep_chars) else "R")
            ref = rep_chars.get(S, fh)
            t["fhat"] = fh; t["sign_ok"] = None if not ref else bool(np.sign(t["w"]) == np.sign(ref))
        elif k == "quad":
            u = np.asarray(t["u"], float); m = float(np.sum(u[list(rel)] ** 2) / max(np.sum(u ** 2), 1e-12))
            t["mass_rel"] = round(m, 3); t["cat"] = "R" if m >= 0.9 else "S"
            for r in sp["reps"]:                                             # parmaj / majxor: u ~ 1_A +- 1_B
                if r.get("quad"):
                    A_, B_ = tblocks[0]["S"], tblocks[1]["S"]
                    for sg in (1, -1):
                        v = np.zeros(len(u)); v[A_] = 1; v[B_] = sg
                        if abs(u @ v) / (np.linalg.norm(u) * np.linalg.norm(v)) >= 0.9:
                            t["cat"] = "T"; t["quad_match"] = "1_A" + ("+" if sg > 0 else "-") + "1_B"
        else:                                                                # sum block
            inr = set(t["support"]) <= rel; fm = []
            for fac in t["factors"]:
                best = None
                for j, tb in enumerate(tblocks):
                    v = factor_vs(fac, tb)
                    if v is not None and (best is None or (v["signs"], v["fold_ok"], v["inner_ok"]) > (best[1]["signs"], best[1]["fold_ok"], best[1]["inner_ok"])):
                        best = (j, v)
                if best is None:                                             # partial overlap with the closest true block
                    J = max([len(set(fac["S"]) & set(tb["S"])) / len(set(fac["S"]) | set(tb["S"])) for tb in tblocks] + [0.0])
                    fm.append(dict(block=None, jaccard=round(J, 3), exact=False))
                else:
                    j, v = best
                    fm.append(dict(block=j, jaccard=1.0, exact=bool(v["signs"] and v["fold_ok"]), **v))
            allx = all(m["exact"] for m in fm)
            t["factor_match"] = fm
            # a product whose unfolded factors partition a true block, each with the true signs up to its own global
            # flip, is exact too: the joint cells of (t_1, t_2) determine t = +-t_1 +- t_2 (the 'split' form)
            t["partition"] = None
            if t["product"] and not any(f["fold"] or f["inner"] for f in t["factors"]):
                for j, tb in enumerate(tblocks):
                    sg = dict(zip(tb["S"], tb["signs"]))
                    if set().union(*[set(f["S"]) for f in t["factors"]]) == set(tb["S"]) and \
                            sum(len(f["S"]) for f in t["factors"]) == len(tb["S"]) and tb["inner"] is None and not tb["mod"] and \
                            all(len({v * sg[i] for i, v in zip(f["S"], f["signs"])}) == 1 for f in t["factors"]):
                        t["partition"] = j; allx = True
            t["cat"] = "S" if not inr else ("T" if allx else "R")
            t["exact_factor"] = any(m["exact"] for m in fm) or t["partition"] is not None
            t["inner_ok"] = all(m.get("inner_ok", False) for m in fm if m["exact"]) if t["exact_factor"] else None
            t["coupled"] = bool(t["exact_factor"] and (any(m.get("extra_inner") for m in fm) or
                                                       (t["mod"] and not any(tblocks[m["block"]]["mod"] == t["mod"] for m in fm if m["exact"]))))
    return rec


def rep_status(rec, sp):
    """Which compact representations are complete in the model."""
    out = []
    chars = {tuple(t["S"]): t for t in rec["terms"] if t["kind"] == "chi"}
    tblocks = [b for r in sp["reps"] for b in r.get("blocks", [])]
    for r in sp["reps"]:
        o = dict(name=r["name"])
        if "chars" in r:
            C = {S: c for S, c in r["chars"].items() if S}
            pres = [S for S in C if S in chars]
            o.update(n=len(C), present=len(pres), sign_ok=sum(1 for S in pres if np.sign(chars[S]["w"]) == np.sign(C[S])),
                     weight=round(sum(C[S] ** 2 for S in pres) / max(sum(c * c for c in C.values()), 1e-12), 4))
            o["complete"] = o["present"] == o["n"]
        if "blocks" in r:
            found = []                                                       # per true block: 'T', 'S' (only inside a
            for b in r["blocks"]:                                            # spurious product) or None
                j = tblocks.index(b); where = None
                for t in rec["terms"]:
                    if t["kind"] != "sum" or t["cat"] not in ("T", "S"):
                        continue
                    for q, (fac, m) in enumerate(zip(t["factors"], t["factor_match"])):
                        if m.get("block") == j and m["exact"] and (b["inner"] is None or m["inner_ok"]) and \
                                (not b["mod"] or (q == 0 and t["mod"] == b["mod"])):
                            where = "T" if (t["cat"] == "T" or where == "T") else "S"
                found.append(where)
            o.update(blocks=len(found), found=sum(f is not None for f in found), found_in=found,
                     complete=all(f is not None for f in found))
        if r.get("quad"):
            o["complete"] = sum(1 for t in rec["terms"] if t.get("quad_match")) >= 2
        out.append(o)
    return out


def p10_exact(terms, classes):
    """Part 10's criterion (toy_structure.summarise): every signed-symmetry class of size >= 3 has a sum-block factor
    or a modulator chi_M on exactly its set, with signs equal up to a global flip where the class fixes them."""
    res = []
    for c in classes:
        if len(c["S"]) < 3:
            continue
        ok = False
        for t in terms:
            if t["kind"] != "sum":
                continue
            facs = [(f["S"], f["signs"]) for f in t["factors"]] + ([(t["mod"], [None] * len(t["mod"]))] if t["mod"] else [])
            for S, sg in facs:
                if sorted(S) != c["S"]:
                    continue
                d_ = dict(zip(S, sg)); pr = [(i, s) for i, s in zip(c["S"], c["signs"]) if s is not None and d_.get(i) is not None]
                if not pr or all(d_[i] == s for i, s in pr) or all(d_[i] == -s for i, s in pr):
                    ok = True
        res.append(ok)
    return res


def feature_columns(f, Z):
    cols, cache = [], {}
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


def span_and_oracle(rec):
    """Least squares R^2 and logistic 0/1 error of f on the span of the model's features: fit on the first 2048 test
    inputs, scored on the other 2048 (what the learned dictionary can express, whatever the readout weights)."""
    A_ = feature_columns(rec["final"], rec["Zte"]); y = rec["yte"]; h = len(y) // 2
    w, *_ = np.linalg.lstsq(A_[:h], y[:h], rcond=None); res = y[h:] - A_[h:] @ w
    r2 = float(1 - np.mean(res ** 2) / np.var(y[h:]))
    p = A_.shape[1]; v = np.zeros(p); lam = 1e-4; Ah, yh = A_[:h], y[:h]
    for _ in range(25):
        z = Ah @ v; pr = 1 / (1 + np.exp(-np.clip(yh * z, -30, 30)))
        g = -(Ah.T @ (yh * (1 - pr))) / h + lam * v
        Hs = (Ah * (pr * (1 - pr))[:, None]).T @ Ah / h + lam * np.eye(p)
        v = v - np.linalg.solve(Hs, g)
    oe = float(np.mean(np.where(A_[h:] @ v > 0, 1.0, -1.0) != y[h:]))
    return round(r2, 4), oe


def summarise(rec, sp):
    classify(rec, sp)
    terms = rec["terms"]; tot = float(np.std(rec["value_te"])) or 1e-12
    cat = {}
    groups = dict(T=lambda t: t.get("cat") == "T", R=lambda t: t.get("cat") == "R", S=lambda t: t.get("cat") == "S",
                  S_linear=lambda t: t.get("cat") == "S" and t.get("via_linear") is True,
                  S_other=lambda t: t.get("cat") == "S" and t.get("via_linear") is not True)
    for c, sel_ in groups.items():
        sel = [t for t in terms if sel_(t)]
        cat[c] = dict(n=len(sel), share=round(float(np.std(sum((t["contrib"] for t in sel), np.zeros(len(rec["yte"]))))) / tot, 4))
    bg = [t for t in terms if t["kind"] == "background"][0]
    cat["background"] = dict(share=round(bg["share"] / tot, 4))
    keep = lambda pred: H.model_parts(rec, pred)
    errs = dict(T_only=keep(lambda t: t["kind"] == "const" or t.get("cat") == "T"),
                no_S=keep(lambda t: t.get("cat") != "S"),
                no_S_other=keep(lambda t: not (t.get("cat") == "S" and t.get("via_linear") is not True)),
                no_bg=keep(lambda t: t["kind"] != "background"))
    chis = [t for t in terms if t["kind"] == "chi"]; F = sp["fourier"]
    deg = {}
    for t in chis:
        deg[t["deg"]] = deg.get(t["deg"], 0) + 1
    blks = [t for t in terms if t["kind"] == "sum"]
    lin = [e["round"] for e in rec["log"] if "linear" in e["blocks"]]
    fw = None
    if F is not None:
        W0 = F.get((), 0.0) ** 2
        fw = round(sum(F.get(tuple(t["S"]), 0.0) ** 2 for t in chis) / max(1 - W0, 1e-12), 4)
    r2, oe = span_and_oracle(rec)
    return dict(categories=cat, err_parts=errs, value_sd=tot, linear_uncertain=rec["linear_uncertain"],
                chars_by_degree={str(k): v for k, v in sorted(deg.items())},
                n_blocks=len(blks), n_quad=sum(t["kind"] == "quad" for t in terms),
                block_kinds=dict(folded=sum(t["fold"] for t in blks), modulated=sum(bool(t["mod"]) for t in blks),
                                 product=sum(t["product"] for t in blks),
                                 weighted=sum(any(f["inner"] is not None for f in t["factors"]) for t in blks)),
                linear_block_round=lin[0] if lin else None, reps=rep_status(rec, sp),
                p10_classes=p10_exact(terms, sp["classes"]), fourier_weight=fw, span_r2=r2, oracle_err=oe)


def run_target(suite, name, T, sp, ns=NS):
    p = os.path.join(OUT, f"{suite}__{name}.json")
    res = json.load(open(p)) if os.path.exists(p) else dict(suite=suite, target=name, seed=0, spec=spec_json(sp), cells=[])
    done = {c["n"] for c in res["cells"]}
    for n in ns:
        if n in done:
            continue
        t0 = time.process_time(); rec = H.fit_toy_dfg(suite, name, n, 0, T=T)
        cpu = time.process_time() - t0
        s = summarise(rec, sp); idt = H.check_identity(rec)
        c = H.cell_json(rec, dict(summary=s, identity=idt, cpu=round(cpu, 2)))
        res["cells"].append(c); res["cells"].sort(key=lambda c: c["n"])
        json.dump(res, open(p + ".tmp", "w")); os.replace(p + ".tmp", p)
        cs = s["categories"]
        print(f"{suite}/{name} n={n} err={rec['err']:.4f} var={rec['variant']} size={rec['size']} "
              f"T={cs['T']['n']}:{cs['T']['share']:.2f} R={cs['R']['n']}:{cs['R']['share']:.2f} S={cs['S']['n']}:{cs['S']['share']:.2f} "
              f"reps={[r.get('complete') for r in s['reps']]} id={idt.get('err_equal')}/{idt.get('flops_equal')} cpu={cpu:.1f}s",
              flush=True)
    return res


if __name__ == "__main__":
    want = [tuple(a.split(":")) for a in sys.argv[1].split(",")] if len(sys.argv) > 1 else A.ATLAS
    Tc = {}
    for suite, name in want:
        T = Tc.setdefault(suite, H.targets(suite))
        sp = A.spec(suite, name, T[name])
        run_target(suite, name, T, sp)

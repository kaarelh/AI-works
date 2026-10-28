"""Toy side of the Part 10 interpretability analysis: what v3's DFG member (DFG v1.3) learns on the toy targets, when,
and why it fails where it fails.  Descriptive; reads only result files, writes tables/ and figures/ (fig_toy_*.pdf).

Inputs (all seed 0 unless stated):
  STRUCT  $INTERP_OUT/toy/{v3,v2}/<suite>__<target>__s0.json      toy_structure.py, final matcher (complete runs only)
  POWER   <scratch>/p10/interp_out/toy_power/<suite>__<target>.json toy_power.py (seed-0 training rows)
  NSTAR   study/hybrid/results/toy__<learner>__<suite>.json        3-seed full-grid test errors (n*: 10% threshold,
          log-interpolated on the seed-mean error, as compare_hybrid.py); v3 = p10_sum-perm, v2 = hyb_portfolio2-perm or
          p9_sum-perm (identical code path on toy inputs); networks: compare_hybrid.toy_nstars (nets_best = per-target
          minimum over the variants present)
Definitions:
  n_struct    first analysed n at which every true signed-symmetry class of size >= 3 is matched exactly (same set; signs
              equal up to a global flip) by a sum block, a factor of a product block or a modulator chi_M
  n_stable    first n from which every larger analysed n also has the exact structure
  n_detect    first grid n at which DFG's block test would accept the TRUE block (largest class) in round 0:
              T / threshold > 1 for the unfolded, folded or modulated statistic (toy_power.py; the union bound of the
              unweighted block class, which v1.3 shares with v1.2)
  n*          10% test-error threshold, log-interpolated (3 seeds where the result file has them; *_s0 = seed 0 only,
              from the structure runs, which reproduce the evaluation's seed-0 cells)
Also: toy_power_w.py (weighted blocks' detection), toy_landscape.py (the statistic around the true block), toy_gfit.py
(learned g split by tau), read from $INTERP_OUT/{toy_power_w,toy_landscape,toy_g/v3}.
usage: INTERP_OUT=<live outputs> python toy_interp.py      (without INTERP_OUT: reads the copies in results/toy_final/)"""
import os, sys, json, glob, math, csv, numpy as np

HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(os.path.dirname(HERE))
SCR = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/p10"
_IO = os.environ.get("INTERP_OUT")                     # live analysis outputs; else the copies in results/toy_final
EXTRA = _IO if _IO else os.path.join(HERE, "results", "toy_final")
FINAL = os.path.join(_IO, "toy") if _IO else EXTRA      # <FINAL>/{v3,v2}/<suite>__<target>__s0.json
POWER = os.path.join(SCR, "interp_out", "toy_power") if _IO else os.path.join(EXTRA, "power")
RES = os.path.join(STUDY, "hybrid", "results")
TAB = os.path.join(HERE, "tables"); FIG = os.path.join(HERE, "figures")
os.makedirs(TAB, exist_ok=True); os.makedirs(FIG, exist_ok=True)
NS = [2 ** k for k in range(4, 15)]
SUM_SUITES = ["dlsymdev", "dlfamdev", "dlheld7", "dlheld6", "dlheld5", "dlheld4"]
OTHER_SUITES = ["designed", "dlheld3", "dlheld2", "dlheld", "random"]

# accept-set kind and mixture of every target of the sum-structured suites (from the descriptions; family suites: the
# description format of part9/heldout6/suite.py fixes the ACCEPT type: '>=' / '<=' threshold, '|s| <= w' / '|s| > w'
# band, 'lo <= s <= hi' / 's == v' interval, 'mod' modular, 's in {..}' arbitrary)
KIND = {
    # dlsymdev
    "sym7": ("band", "pure"), "ex3of8": ("interval", "pure"), "band11": ("arbitrary", "pure"), "far9": ("band", "pure"),
    "ssym9": ("band", "pure"), "symxpar": ("band", "parity"), "twosym": ("band+band", "two sums"),
    "thrsum": ("threshold", "weighted"),
    # dlheld4
    "sym11": ("band", "pure"), "ex4of9": ("interval", "pure"), "tail13": ("band", "pure"), "band10": ("arbitrary", "pure"),
    "ssym8": ("interval", "pure"), "symxor": ("band", "parity"), "symand": ("band", "gate"),
    "sumpar": ("threshold", "weighted"), "majsym": ("band", "gate"),
    "dnf3x3": ("control", "control"), "h4rf0": ("control", "control"), "h4rf1": ("control", "control"),
    # dlheld5
    "h5s0": ("arbitrary", "pure"), "h5s1": ("arbitrary", "parity"), "h5s2": ("arbitrary", "pure"),
    "h5s3": ("arbitrary", "pure"), "h5s4": ("arbitrary", "gate"), "h5s5": ("arbitrary", "pure"),
    "h5s6": ("arbitrary", "pure"), "h5s7": ("arbitrary", "pure"), "h5t0": ("threshold", "weighted"),
    "h5t1": ("threshold", "weighted"), "h5rf0": ("control", "control"), "h5rf1": ("control", "control"),
    # dlheld6
    "h6_00": ("modular", "pure"), "h6_01": ("arbitrary", "pure"), "h6_02": ("interval", "parity"),
    "h6_03": ("control", "control"), "h6_04": ("control", "control"), "h6_05": ("control", "control"),
    "h6_06": ("arbitrary", "parity"), "h6_07": ("arbitrary+threshold", "mux"), "h6_08": ("band+modular", "mux"),
    "h6_09": ("interval+interval", "two sums"), "h6_10": ("band", "weighted"), "h6_11": ("interval", "pure"),
    # dlfamdev
    "fd_00": ("control", "control"), "fd_01": ("threshold", "pure"), "fd_02": ("band", "parity"),
    "fd_03": ("control", "control"), "fd_04": ("band", "parity"), "fd_05": ("threshold+band", "two sums"),
    "fd_06": ("threshold+interval", "two sums"), "fd_07": ("control", "control"), "fd_08": ("interval", "gate"),
    "fd_09": ("arbitrary", "pure"), "fd_10": ("modular", "pure"), "fd_11": ("band", "gate"),
    # dlheld7
    "f7_00": ("band+interval", "two sums"), "f7_01": ("threshold", "pure"), "f7_02": ("control", "control"),
    "f7_03": ("modular+band", "mux"), "f7_04": ("control", "control"), "f7_05": ("modular", "pure"),
    "f7_06": ("control", "control"), "f7_07": ("interval", "parity"), "f7_08": ("arbitrary", "pure"),
    "f7_09": ("threshold", "parity"), "f7_10": ("threshold", "weighted"), "f7_11": ("arbitrary+band", "mux"),
}
# the true weighted inner term of the weighted targets: (kind, original 0-indexed inputs, a relative to the class's
# normalised signs, i.e. a * s_true[first input of the class]); None: not representable as one v1.3 inner term (sumpar's
# degree-3 parity).  thrsum: s + 3 x7x8; h6_10: s - 3 x13; f7_10: s + 2 x6; h5t0: s = (-1, 1, 1, 1, 1, -1, 1) . x + 2 x8x9;
# h5t1: s = (1, -1, 1, -1, 1) . x + 2 x6x7
INNER = {"thrsum": ("par", (6, 7), 3), "h6_10": ("lit", (12,), -3), "f7_10": ("lit", (5,), 2),
         "h5t0": ("par", (7, 8), -2), "h5t1": ("par", (5, 6), 2), "sumpar": None}


def nstar(ns, e, thr=0.1):
    """compare_hybrid / harness convention: first crossing of thr, log2-interpolated; inf if never."""
    for i in range(len(e)):
        if e[i] <= thr:
            if i == 0:
                return float(ns[0])
            f = (e[i - 1] - thr) / max(e[i - 1] - e[i], 1e-12)
            return float(2 ** (np.log2(ns[i - 1]) + f * (np.log2(ns[i]) - np.log2(ns[i - 1]))))
    return float("inf")


def load_struct(tag):
    R = {}
    for p in sorted(glob.glob(os.path.join(FINAL, tag, "*__s0.json"))):
        r = json.load(open(p))
        if r.get("complete"):
            r["cells"] = sorted(r["cells"], key=lambda c: c["n"]); r["_path"] = p; R[(r["suite"], r["target"])] = r
    return R


def load_power():
    P = {}
    for p in sorted(glob.glob(os.path.join(POWER, "*.json"))):
        r = json.load(open(p)); r["_path"] = p; P[(r["suite"], r["target"])] = r
    return P


NSTAR_FILES = {"v3": ["p10_sum-perm"], "v2": ["hyb_portfolio2-perm", "p9_sum-perm"]}


def load_nstar(tag):
    """{(suite, target): (n*, file)} from the 3-seed result files (the first listed learner name that has the suite; a
    suite still being run is read from its per-target shards toy__<learner>__<suite>__partNN.json); only targets whose
    3 x 11 cells are all finite."""
    out = {}
    for su in SUM_SUITES + OTHER_SUITES:
        for nm in NSTAR_FILES[tag]:
            p = os.path.join(RES, f"toy__{nm}__{su}.json")
            files = [p] if os.path.exists(p) else sorted(glob.glob(os.path.join(RES, f"toy__{nm}__{su}__part*.json")))
            if not files:
                continue
            for q in files:
                d = json.load(open(q))
                for fn, r in d["fns"].items():
                    e = np.array(r["err"], float)
                    if e.ndim == 2 and e.shape[1] >= 3 and np.isfinite(e).all():
                        out[(su, fn)] = (nstar(d["ns"], np.nanmean(e, 1)), os.path.basename(q))
            break
    return out


def load_nets():
    sys.path.insert(0, os.path.join(STUDY, "hybrid"))
    import io, contextlib
    with contextlib.redirect_stdout(io.StringIO()):
        import compare_hybrid as CH
    out = {}
    for su in SUM_SUITES + OTHER_SUITES:
        try:
            NR = CH.toy_nstars(su)
        except Exception:
            continue
        var = [k for k in NR if k != "nets_best"]
        fns = set().union(*[set(NR[k]) for k in var]) if var else set()
        for fn in fns:
            v = [NR[k][fn] for k in var if fn in NR[k]]
            out[(su, fn)] = (min(v), "+".join(sorted(k for k in var if fn in NR[k])))
    return out


# ------------------------------------------------------------------------------------------------ per-cell helpers
def big_classes(r):
    return [c for c in r["truth"]["classes"] if len(c["S"]) >= 3]


def exact_all(c):
    cl = c.get("classes")
    return bool(cl) and all(x["exact"] for x in cl)


def first_struct(r):
    C = r["cells"]
    if not big_classes(r):
        return None, None
    ex = [exact_all(c) for c in C]
    first = next((c["n"] for c, e in zip(C, ex) if e), None)
    stable = None
    for i in range(len(C)):
        if all(ex[i:]):
            stable = C[i]["n"]; break
    return first, stable


def term_str(t):
    if t["kind"] == "sum":
        return t["desc"]
    if t["kind"] == "chi":
        return "chi[" + ",".join(f"x{i + 1}" for i in t["S"]) + "]"
    if t["kind"] == "quad":
        return f"quad({len(t['S'])} inputs)"
    return t["kind"]


def lead_terms(c, k=3, min_share=0.05):
    T = [t for t in (c.get("terms") or []) if t["kind"] not in ("const",)]
    if not T:
        return ""
    top = max(t["share"] for t in T) or 1e-12
    return "; ".join(f"{term_str(t)} ({t['share']:.2f})" for t in T[:k] if t["share"] >= min_share * top)


def inner_found(c, tgt, cls0=None):
    """For a weighted target: is the true inner term in the model?  'exact' (a block with inner term a*tau on the true
    inputs and the true weight relative to the block's signs), 'a=<learned> (true <a>)' (same tau, other weight or relative
    sign), 'modulator' (chi_tau modulates a block), 'product factor' (tau's inputs form the second factor of a product
    block), or 'no'."""
    want = INNER.get(tgt)
    if want is None:
        return None
    kind, inp, a_true = want; best = "no"
    for t in (c.get("terms") or []):
        if t["kind"] != "sum":
            continue
        inn = t.get("inner")
        if inn and inn.get("kind") == kind and sorted(inn.get("inputs") or []) == sorted(inp):
            sg = dict(zip(t["S"], t["signs"])); i0 = min(cls0) if cls0 else min(sg)
            a_rel = inn["a"] * sg.get(i0, 1)
            return "exact" if a_rel == a_true else f"a={a_rel:+d} (true {a_true:+d})"
        if sorted(t.get("mod") or []) == sorted(inp):
            best = "modulator"
        elif best == "no" and len(t.get("factors") or []) > 1 and any(sorted(f["S"]) == sorted(inp) for f in t["factors"][1:]):
            best = "product factor"
    return best


def detect(P, key):
    """First grid n with T/threshold > 1: unfolded, folded, modulated, any; and the ratios / search reach at n_detect."""
    p = P.get(key)
    if p is None:
        return None
    out = dict(k=p["k"], W=p["fourier_by_degree"], path=p["_path"])
    for v in ("unfold", "fold", "modulated"):
        out["n_" + v] = next((c["n"] for c in p["cells"] if c[v]["ratio"] > 1), None)
    ns = [out["n_" + v] for v in ("unfold", "fold", "modulated") if out["n_" + v]]
    out["n_detect"] = min(ns) if ns else None
    out["n_detect_plain"] = min([v for v in (out["n_unfold"], out["n_fold"]) if v] or [None]) if (out["n_unfold"] or out["n_fold"]) else None
    # search reach: first n at which the search's orders list the true class first (top |S| of the best of the two top
    # eigenvectors of the residual pair matrix, or of the degree-1 order), and within the top |S| + 5
    out["n_reach"] = next((c["n"] for c in p["cells"] if max(max(c["search"]["eig"]), c["search"]["deg1"]) >= 1.0), None)
    out["n_reach5"] = next((c["n"] for c in p["cells"] if max(max(c["search"]["eig_k5"]), c["search"]["deg1_k5"]) >= 1.0), None)
    out["cells"] = p["cells"]
    return out


def fmt_n(v):
    if v is None:
        return "–"
    if isinstance(v, float) and not np.isfinite(v):
        return "never"
    return f"{v:.0f}"


def l2(a, b):
    if a is None or b is None:
        return None
    if not (np.isfinite(a) and np.isfinite(b)):
        return None
    return float(np.log2(a / b))


def write_csv(name, rows, cols):
    p = os.path.join(TAB, name)
    with open(p, "w", newline="") as f:
        w = csv.writer(f); w.writerow(cols)
        for r in rows:
            w.writerow([r.get(c, "") for c in cols])
    return p


def _cell(v):
    if v is None:
        return "–"
    if isinstance(v, bool):
        return "yes" if v else "no"
    if isinstance(v, float):
        if not np.isfinite(v):
            return "never" if v > 0 else "-inf"
        return f"{v:.0f}" if abs(v) >= 10 else f"{v:.2f}" if abs(v) >= 0.01 or v == 0 else f"{v:.4f}"
    return str(v)


def write_md(name, rows, cols, head=None, note=None):
    p = os.path.join(TAB, name)
    L = ([f"{head}", ""] if head else []) + ["| " + " | ".join(cols) + " |", "|" + "---|" * len(cols)]
    for r in rows:
        L.append("| " + " | ".join(_cell(r.get(c)).replace("|", "\\|") for c in cols) + " |")
    if note:
        L += ["", note]
    open(p, "w").write("\n".join(L) + "\n")
    return p


# ------------------------------------------------------------------------------------------------ Q1 / Q2: per target
def target_rows(S3, S2, P, N3, N2, NN):
    rows = []
    for (su, tg), r in sorted(S3.items(), key=lambda kv: (SUITES_ORDER.index(kv[0][0]), kv[0][1])):
        C = r["cells"]; last = C[-1]; big = big_classes(r)
        ns, st = first_struct(r); dt = detect(P, (su, tg))
        r2 = S2.get((su, tg)); ns2, st2 = first_struct(r2) if r2 else (None, None)
        kind, mix = KIND.get(tg, ("–", "–"))
        n3 = N3.get((su, tg)); n2 = N2.get((su, tg)); nn = NN.get((su, tg))
        row = dict(suite=su, target=tg, desc=r["truth"]["desc"], kind=kind, mixture=mix, k=len(r["truth"]["relevant"]),
                   classes="+".join(str(len(c["S"])) for c in big) or "–", n_struct=ns, n_stable=st,
                   n_max=last["n"], err_last=round(last["err"], 4), err_dfg_last=None if last.get("err_dfg") is None else round(last["err_dfg"], 4),
                   w_dfg_last=last["w_dfg"], lead=lead_terms(last), span_r2_last=last.get("span_r2"),
                   fourier_chi_last=last.get("fourier_chi"),
                   nstar_s0=nstar([c["n"] for c in C], [c["err"] for c in C]),
                   nstar3=n3[0] if n3 else None, nstar3_file=n3[1] if n3 else "",
                   nstar3_v2=n2[0] if n2 else None, nets_best=nn[0] if nn else None, nets_variants=nn[1] if nn else "",
                   n_struct_v2=ns2, n_stable_v2=st2, struct_file=os.path.basename(r["_path"]),
                   n_dfg01=next((c["n"] for c in C if c.get("err_dfg") is not None and c["err_dfg"] <= 0.01), None),
                   n_class_first="/".join(fmt_n(next((c["n"] for c in C if c.get("classes") and c["classes"][q]["exact"]), None)) for q in range(len(big))) if big else "–",
                   classes_exact_last=f"{sum(x['exact'] for x in last.get('classes') or [])}/{len(big)}" if big else "–",
                   n_dfg01_v2=next((c["n"] for c in r2["cells"] if c.get("err_dfg") is not None and c["err_dfg"] <= 0.01), None) if r2 else None)
        if tg in INNER:
            c0 = big[0]["S"] if big else None
            row["inner_last"] = inner_found(last, tg, c0)
            row["n_inner"] = next((c["n"] for c in C if inner_found(c, tg, c0) not in (None, "no")), None)
            row["n_inner_exact"] = next((c["n"] for c in C if inner_found(c, tg, c0) == "exact"), None)
            row["inner_by_n"] = "; ".join(f"{c['n']}: {inner_found(c, tg, c0)}" for c in C)
        if dt:
            W_ = dt["W"]; row["low2"] = round((W_[1] + (W_[2] if len(W_) > 2 else 0)) / max(1 - W_[0], 1e-12), 4)   # share of Var f at degree 1-2
            row.update(n_detect=dt["n_detect"], n_unfold=dt["n_unfold"], n_fold=dt["n_fold"], n_mod=dt["n_modulated"],
                       W1=round(dt["W"][1], 4) if len(dt["W"]) > 1 else None, W2=round(dt["W"][2], 4) if len(dt["W"]) > 2 else None,
                       power_k=dt["k"], power_file=os.path.basename(dt["path"]), n_reach=dt["n_reach"], n_reach5=dt["n_reach5"])
            cd = next((c for c in dt["cells"] if c["n"] == dt["n_detect"]), None)
            if cd:
                row["reach_deg1"] = round(cd["search"]["deg1"], 2); row["reach_eig"] = round(max(cd["search"]["eig"]), 2)
        rows.append(row)
    return rows


SUITES_ORDER = SUM_SUITES + OTHER_SUITES


def recovery_tables(rows):
    cols = ["suite", "target", "kind", "mixture", "k", "classes", "n_struct", "n_stable", "n_class_first", "classes_exact_last", "n_dfg01", "n_detect", "n_reach5", "nstar3", "nstar_s0",
            "nets_best", "n_max", "err_last", "lead"]
    sel = [r for r in rows if r["suite"] in SUM_SUITES]
    fmt = []
    for r in sel:
        q = dict(r)
        for c in ("n_struct", "n_stable", "n_dfg01", "n_detect", "n_reach5", "nstar3", "nstar_s0", "nets_best"):
            q[c] = fmt_n(r.get(c)) if r.get(c) is not None or c in ("n_struct", "n_stable") else "–"
        if r["classes"] == "–":
            q["n_struct"] = q["n_stable"] = "n/a"
        elif r["n_struct"] is None:
            q["n_struct"] = q["n_stable"] = f"> {r['n_max']}"
        elif r["n_stable"] is None:
            q["n_stable"] = f"lost at {r['n_max']}"
        fmt.append(q)
    write_md("toy_recovery_v3.md", fmt, cols,
             head="### v3's DFG member on the sum-structured suites (seed 0; final matcher)",
             note="n_struct: first analysed n with every true signed-symmetry class of size >= 3 matched exactly by a block, "
                  "factor or modulator; n_stable: from then on at every analysed n; n_detect: first n at which DFG's test "
                  "accepts the true (largest) block (toy_power, seed-0 rows); nstar3: v3's 3-seed n* (toy__p10_sum-perm__<suite>.json), "
                  "'–' where that file is not yet written; nstar_s0: seed-0 n* from the structure run; lead: the largest terms of "
                  "the final DFG model at n_max (share = sd of the term's output on the test inputs; quad = a spectral feature; "
                  "background = the kernel background). The structure runs stop after two consecutive n with err <= 0.005.")
    write_csv("toy_recovery_v3.csv", rows, ["suite", "target", "desc", "kind", "mixture", "k", "classes", "n_struct", "n_stable", "n_class_first", "classes_exact_last",
              "n_detect", "n_unfold", "n_fold", "n_mod", "n_reach", "n_reach5", "reach_deg1", "reach_eig", "W1", "W2", "nstar3", "nstar3_file", "nstar_s0",
              "nstar3_v2", "n_struct_v2", "n_stable_v2", "n_dfg01", "n_dfg01_v2", "nets_best", "nets_variants", "n_max", "err_last", "err_dfg_last",
              "w_dfg_last", "span_r2_last", "fourier_chi_last", "inner_last", "n_inner", "n_inner_exact", "inner_by_n", "lead", "struct_file", "power_file"])
    # by suite
    S = []
    for su in SUM_SUITES:
        R = [r for r in sel if r["suite"] == su and r["classes"] != "–" and r["kind"] != "control"]
        if not R:
            continue
        rec = [r for r in R if r["n_struct"] is not None]
        S.append(dict(suite=su, structured=len(R), recovered=len(rec), never=", ".join(r["target"] for r in R if r["n_struct"] is None) or "–",
                      median_n_struct=fmt_n(float(np.median([r["n_struct"] for r in rec]))) if rec else "–",
                      at_le_128=sum(1 for r in rec if r["n_struct"] <= 128), at_le_512=sum(1 for r in rec if r["n_struct"] <= 512),
                      controls=sum(1 for r in sel if r["suite"] == su and r["kind"] == "control")))
    write_md("toy_recovery_by_suite.md", S, ["suite", "structured", "recovered", "median_n_struct", "at_le_128", "at_le_512", "never", "controls"],
             head="### Exact structure recovered by v3's DFG member, by suite (seed 0)",
             note="structured = the family's / suite's sum-structured targets (every one has a signed-symmetry class of size >= 3); the "
                       "non-symmetric controls are counted separately (fd_07, a DNF, has a 3-input symmetric class; it is not counted).")
    # by kind / mixture
    K = []
    groups = {}
    for r in sel:
        if r["classes"] == "–" or r["kind"] == "control":
            continue
        for kk in r["kind"].split("+"):
            groups.setdefault(("accept", kk), []).append(r)
        groups.setdefault(("mixture", r["mixture"]), []).append(r)
    for (ax, kk), R in sorted(groups.items()):
        rec = [r for r in R if r["n_struct"] is not None]
        K.append(dict(axis=ax, kind=kk, targets=len(R), recovered=len(rec),
                      median_n_struct=fmt_n(float(np.median([r["n_struct"] for r in rec]))) if rec else "–",
                      range_n_struct=(f"{min(r['n_struct'] for r in rec)}–{max(r['n_struct'] for r in rec)}" if rec else "–"),
                      never=", ".join(r["target"] for r in R if r["n_struct"] is None) or "–"))
    write_md("toy_recovery_by_kind.md", K, ["axis", "kind", "targets", "recovered", "median_n_struct", "range_n_struct", "never"],
             head="### Exact structure recovered, by accept-set kind and by mixture (sum-structured suites, seed 0)",
             note="A target with two blocks (mux, two sums) is counted under both accept kinds.")
    return S, K


def nonsum_table(rows, S3):
    out = []
    for r in rows:
        if r["suite"] not in OTHER_SUITES:
            continue
        R = S3[(r["suite"], r["target"])]; C = R["cells"]
        sp = next((c["n"] for c in C if (c.get("span_r2") or -1) >= 0.95), None)
        c0 = next((v for k, v in R["fourier_top"] if k == []), 0.0)          # fhat(empty set); not in the top 12 -> ~0
        var = max(1e-9, 1 - c0 ** 2)
        fc = next((c["n"] for c in C if (c.get("fourier_chi") or 0) >= 0.9 * var), None) if R["fourier_top"] else None
        last = C[-1]
        nchi = (last.get("n_terms") or {}).get("chi"); nsum = (last.get("n_terms") or {}).get("sum")
        out.append(dict(suite=r["suite"], target=r["target"], desc=r["desc"][:60], k=r["k"], n_max=r["n_max"], err_last=r["err_last"],
                        fourier_chi=last.get("fourier_chi"), chi_frac=round(last["fourier_chi"] / var, 3) if R["fourier_top"] and last.get("fourier_chi") is not None else None, span_r2=last.get("span_r2"), n_span95=sp, n_chi90=fc,
                        n_chi=nchi, n_sum=nsum, classes=r["classes"], n_struct=r["n_struct"], nstar3=fmt_n(r["nstar3"]) if r["nstar3"] else "–",
                        nstar_s0=fmt_n(r["nstar_s0"]), w_dfg=last["w_dfg"], lead=lead_terms(last)))
    write_md("toy_nonsum_v3.md", out, ["suite", "target", "desc", "k", "nstar3", "nstar_s0", "n_chi90", "n_span95", "n_max", "chi_frac",
                                        "span_r2", "n_chi", "n_sum", "w_dfg", "lead"],
             head="### v3's DFG member on the non-sum suites (seed 0): what carries the model",
             note="chi_frac: the share of the target's non-constant Fourier weight that sits on characters chi_S of the final model at n_max "
                  "(sum of fhat(S)^2 over them / (1 - fhat(empty)^2); targets with more than 16 relevant inputs have no Fourier table: '–'); "
                  "n_chi90: first n with chi_frac >= 0.9; span_r2: held-out R^2 of f on "
                  "the span of the model's features; n_span95: first n with span_r2 >= 0.95; n_chi / n_sum: number of character / "
                  "sum-block terms at n_max.")
    write_csv("toy_nonsum_v3.csv", out, list(out[0].keys()) if out else [])
    # per suite: carried by characters (chi_frac >= 0.9 at n_max), spanned (span_r2 >= 0.95), a block among the 3 leading terms
    SS = []
    for su in OTHER_SUITES:
        R = [o for o in out if o["suite"] == su]
        if not R:
            continue
        blk = [o["target"] for o in R if any(x.startswith(("(", "|", "chi[x")) and ("+" in x or "-x" in x) for x in o["lead"].split("; ")[:3])]
        SS.append(dict(suite=su, targets=len(R), err_last_le_005=sum(o["err_last"] <= 0.005 for o in R),
                       chi90=sum((o["chi_frac"] or 0) >= 0.9 for o in R), no_fourier=sum(o["chi_frac"] is None for o in R),
                       span95=sum((o["span_r2"] or 0) >= 0.95 for o in R), block_lead=len(blk), block_targets=", ".join(blk) or "–",
                       median_chi_frac=float(np.median([o["chi_frac"] for o in R if o["chi_frac"] is not None])) if any(o["chi_frac"] is not None for o in R) else None,
                       with_class=", ".join(f"{o['target']} ({o['classes']}: {fmt_n(o['n_struct'])})" for o in R if o["classes"] != "–") or "–"))
    write_md("toy_nonsum_by_suite.md", SS, ["suite", "targets", "err_last_le_005", "chi90", "no_fourier", "median_chi_frac", "span95", "block_lead", "block_targets", "with_class"],
             head="### Non-sum suites, by suite (v3, seed 0, at each target's largest analysed n)",
             note="err_last_le_005: test error <= 0.005 at n_max; chi90: targets whose model's characters carry >= 90% of the non-constant Fourier weight; "
                  "no_fourier: more than 16 relevant inputs (no exact Fourier table); span95: span R^2 >= 0.95; block_lead: a sum block among the three "
                  "leading terms; with_class: targets with a signed-symmetry class of size >= 3 (class sizes: n_struct).")
    return out, SS



# ------------------------------------------------------------------------------------------------ Q2: timing
def timing(rows, PW=None, P=None):
    """Per sum-structured target with a class of size >= 3: n_detect (power), n_struct (v3, seed 0), n* (seed 0 from the
    same fits; and 3 seeds where available).  log2 ratios; never-found targets are reported separately (not in medians)."""
    T = []
    for r in rows:
        if r["suite"] not in SUM_SUITES or r["classes"] == "–" or r["kind"] == "control" or r.get("power_file") is None:
            continue
        q = dict(suite=r["suite"], target=r["target"], kind=r["kind"], mixture=r["mixture"], k_power=r.get("power_k"),
                 n_detect=r.get("n_detect"), n_unfold=r.get("n_unfold"), n_fold=r.get("n_fold"), n_mod=r.get("n_mod"),
                 n_struct=r["n_struct"], n_stable=r["n_stable"], nstar_s0=r["nstar_s0"], nstar3=r["nstar3"], n_max=r["n_max"],
                 reach_deg1=r.get("reach_deg1"), reach_eig=r.get("reach_eig"), W1=r.get("W1"), W2=r.get("W2"),
                 n_reach=r.get("n_reach"), n_reach5=r.get("n_reach5"), n_dfg01=r["n_dfg01"], low2=r.get("low2"))
        q["ratio_at_struct"] = None
        q["n_detect_unitpart"], q["detect_source"] = None, "toy_power"
        if PW and (r["suite"], r["target"]) in PW:              # weighted target: the true block is the weighted one
            q["n_detect_unitpart"] = q["n_detect"]; q["n_detect"] = PW[(r["suite"], r["target"])]["n_detect_w"]; q["detect_source"] = "toy_power_w"
        q["l2_struct_detect"] = l2(r["n_struct"], q.get("n_detect")) if r["n_struct"] and q.get("n_detect") else None
        if r["n_struct"] and P is not None:
            q["ratio_at_struct"] = ratio_at(P, (r["suite"], r["target"]), r["n_struct"])
        q["l2_nstar_struct"] = l2(r["nstar_s0"], r["n_struct"]) if r["n_struct"] else None
        q["l2_nstar3_struct"] = l2(r["nstar3"], r["n_struct"]) if r["n_struct"] and r["nstar3"] else None
        T.append(q)
    return T


def timing_summary(T):
    a = [t["l2_struct_detect"] for t in T if t["l2_struct_detect"] is not None]
    b = [t["l2_nstar_struct"] for t in T if t["l2_nstar_struct"] is not None]
    c = [t["l2_nstar3_struct"] for t in T if t["l2_nstar3_struct"] is not None]
    S = dict(n_targets=len(T), found=sum(1 for t in T if t["n_struct"]), never=[t["target"] for t in T if not t["n_struct"]],
             detect_never=[t["target"] for t in T if t["n_detect"] is None],
             struct_vs_detect=dict(n=len(a), median=float(np.median(a)) if a else None, mean=float(np.mean(a)) if a else None,
                                   earlier=sum(1 for v in a if v < 0), same=sum(1 for v in a if v == 0), later1=sum(1 for v in a if v == 1),
                                   later2plus=sum(1 for v in a if v >= 2),
                                   later2plus_targets=[t["target"] for t in T if (t["l2_struct_detect"] or 0) >= 2],
                                   earlier_targets=[t["target"] for t in T if t["l2_struct_detect"] is not None and t["l2_struct_detect"] < 0]),
             nstar_vs_struct=dict(n=len(b), median=float(np.median(b)) if b else None, mean=float(np.mean(b)) if b else None,
                                  below=sum(1 for v in b if v < -0.5), within=sum(1 for v in b if -0.5 <= v <= 0.5), above=sum(1 for v in b if v > 0.5),
                                  below_targets=[t["target"] for t in T if t["l2_nstar_struct"] is not None and t["l2_nstar_struct"] < -0.5],
                                  above_targets=[t["target"] for t in T if t["l2_nstar_struct"] is not None and t["l2_nstar_struct"] > 0.5]),
             nstar3_vs_struct=dict(n=len(c), median=float(np.median(c)) if c else None))
    # search delay beyond detection against the share of Var f at degrees 1-2 (never found: n_struct = 2^15)
    from scipy.stats import spearmanr
    Q = [t for t in T if t["n_detect"] and t.get("low2") is not None]
    dl = lambda t: math.log2((t["n_struct"] or 2 ** 15) / t["n_detect"])
    rho = spearmanr([t["low2"] for t in Q], [dl(t) for t in Q]); Qp = [t for t in Q if t["mixture"] == "pure"]
    rhop = spearmanr([t["low2"] for t in Qp], [dl(t) for t in Qp])
    S["delay_vs_low2"] = dict(n=len(Q), spearman=round(float(rho.statistic), 3), p=float(rho.pvalue), n_pure=len(Qp),
                              spearman_pure=round(float(rhop.statistic), 3), p_pure=float(rhop.pvalue),
                              low2_lt_0_05=[t["target"] for t in Q if t["low2"] < 0.05])
    # search reach against structure: is the exact block found before / when / after the spectral order reaches S?
    R = [t for t in T if t["n_struct"]]
    S["struct_vs_reach5"] = dict(n=len(R), struct_before=sum(1 for t in R if t["n_reach5"] and t["n_struct"] < t["n_reach5"]),
                                 struct_at=sum(1 for t in R if t["n_reach5"] == t["n_struct"]),
                                 struct_after=sum(1 for t in R if t["n_reach5"] and t["n_struct"] > t["n_reach5"]),
                                 reach_never=sum(1 for t in R if not t["n_reach5"]),
                                 l2_median=float(np.median([math.log2(t["n_struct"] / t["n_reach5"]) for t in R if t["n_reach5"]])) if any(t["n_reach5"] for t in R) else None)
    # does the later of (detect, reach5) predict n_struct better than detect alone?
    D = [t for t in R if t["n_detect"]]
    S["struct_vs_max_detect_reach5"] = dict(n=len(D), exact=sum(1 for t in D if t["n_reach5"] and max(t["n_detect"], t["n_reach5"]) == t["n_struct"]),
                                            within1=sum(1 for t in D if t["n_reach5"] and abs(math.log2(t["n_struct"] / max(t["n_detect"], t["n_reach5"]))) <= 1))
    return S


def fig_timing(T, path):
    import matplotlib; matplotlib.use("Agg"); import matplotlib.pyplot as plt
    plt.rcParams.update({"font.size": 7, "axes.titlesize": 7, "axes.labelsize": 7, "legend.fontsize": 6})
    mk = {"pure": "o", "parity": "s", "gate": "^", "mux": "D", "two sums": "P", "weighted": "*"}
    col = {"dlsymdev": "#1f77b4", "dlfamdev": "#ff7f0e", "dlheld7": "#2ca02c", "dlheld6": "#d62728", "dlheld5": "#9467bd", "dlheld4": "#8c564b"}
    fig, axs = plt.subplots(1, 3, figsize=(7.0, 2.55))
    TOP = 2 ** 15.3; jit = lambda t: 2 ** (0.13 * ((sum(map(ord, t["target"])) % 7) - 3))
    never = sorted(t["target"] for t in T if not t["n_struct"])

    def dot(ax, x, y, t):
        ax.scatter(x, y, marker=mk.get(t["mixture"], "o"), s=16 if t["mixture"] != "weighted" else 34, facecolor=col[t["suite"]],
                   edgecolor="k", lw=0.3, alpha=0.85)
    for t in T:
        y = t["n_struct"] / jit(t) if t["n_struct"] else TOP
        if t["n_detect"]:
            dot(axs[0], t["n_detect"] * jit(t), y, t)
        if t["n_struct"] and (t["l2_struct_detect"] or 0) >= 3:
            axs[0].annotate(t["target"], (t["n_detect"] * jit(t), y), fontsize=5, xytext=(3, -2), textcoords="offset points")
        xr = t["n_reach5"] * jit(t) if t["n_reach5"] else TOP
        if t["n_reach5"] or t["n_struct"]:
            dot(axs[1], xr, y, t)
        if t["n_struct"]:
            ys = t["nstar_s0"] if np.isfinite(t["nstar_s0"]) else TOP
            dot(axs[2], t["n_struct"] * jit(t), ys, t)
            if t["l2_nstar_struct"] is not None and abs(t["l2_nstar_struct"]) > 1.0:
                axs[2].annotate(t["target"], (t["n_struct"] * jit(t), ys), fontsize=5, xytext=(3, -2), textcoords="offset points")
    labs = [("n_detect: true block passes DFG's test", "n_struct: v3 has the exact structure"),
            ("n_reach5: search order reaches S (top |S|+5)", "n_struct"), ("n_struct (seed 0)", "n* (seed 0, 10% test error)")]
    for ax, (xl, yl) in zip(axs, labs):
        ax.set_xscale("log", base=2); ax.set_yscale("log", base=2); ax.plot([8, 2 ** 15], [8, 2 ** 15], color="#888", lw=0.6)
        ax.set_xlim(2 ** 3.5, 2 ** 15.7); ax.set_ylim(2 ** 3.5, 2 ** 15.7); ax.set_xlabel(xl, fontsize=6); ax.set_ylabel(yl, fontsize=6)
        ax.axhline(2 ** 15, color="#bbb", lw=0.5, ls=":"); ax.tick_params(labelsize=5.5)
        ax.set_xticks([2 ** k for k in range(4, 16, 2)]); ax.set_yticks([2 ** k for k in range(4, 16, 2)])
    axs[1].axvline(2 ** 15, color="#bbb", lw=0.5, ls=":"); axs[1].text(2 ** 15.1, 2 ** 3.8, "never", fontsize=5, rotation=90)
    for x0 in (1, 2):
        axs[0].plot([8, 2 ** 15], [8 * 2 ** x0, 2 ** (15 + x0)], color="#ccc", lw=0.5, ls="--")
    axs[0].text(2 ** 9.5, 2 ** 14.55, "never (top row):\n" + ", ".join(never), fontsize=4.8, va="top")
    from matplotlib.lines import Line2D
    h = [Line2D([], [], marker=m, ls="", color="#777", mec="k", mew=0.3, label=k) for k, m in mk.items()]
    h += [Line2D([], [], marker="o", ls="", color=c, mec="k", mew=0.3, label=k) for k, c in col.items()]
    axs[2].legend(handles=h, loc="upper left", fontsize=4.8, frameon=False, ncol=2)
    axs[0].set_title("(a) found vs. detectable"); axs[1].set_title("(b) found vs. reached by the search order")
    axs[2].set_title("(c) 10% error vs. found")
    fig.tight_layout(); fig.savefig(path); plt.close(fig)



# ------------------------------------------------------------------------------------------------ Q6: below discovery
MEMBERS = (("dfg", ("dfg",)), ("dfg_forced", ("dfg_forced",)), ("gbt", ("gbt",)), ("et", ("et",)), ("knn", ("knn",)),
           ("lin", ("lin",)))


def member_shares(w):
    tot = sum(w.values()) or 1.0
    return {m: round(sum(v for k, v in w.items() if k == m or (m in ("knn", "lin") and k.startswith(m + "_"))) / tot, 3)
            for m, _ in MEMBERS}


def cell_contents(c, rel, cls):
    T = c.get("terms") or []
    chis = [t for t in T if t["kind"] == "chi"]; sums = [t for t in T if t["kind"] == "sum"]; quads = [t for t in T if t["kind"] == "quad"]
    spur = [t for t in chis if not set(t["S"]) <= rel]; true_ = [t for t in chis if set(t["S"]) <= rel]
    lin = any("linear" in (e.get("blocks") or []) for e in c.get("dfg_log") or [])
    bj = max([x["jaccard"] for x in (c.get("classes") or [])] + [0.0])
    tot = sum(t["share"] for t in T if t["kind"] != "const") or 1e-12
    return dict(empty=not (chis or sums or quads), n_chi=(c.get("n_terms") or {}).get("chi", len(chis)), n_sum=len(sums),
                n_quad=len(quads), spur_chi=len(spur), true_chi=len(true_), deg_spur=sorted(len(t["S"]) for t in spur),
                spur_share=round(sum(t["share"] for t in spur) / tot, 3), bg_share=round(sum(t["share"] for t in T if t["kind"] == "background") / tot, 3),
                linear_block=lin, best_jaccard=bj, partial=bool(sums) and not exact_all(c), exact=exact_all(c))


def below_discovery(S3):
    out = []
    for (su, tg), r in S3.items():
        if su not in SUM_SUITES or not big_classes(r) or KIND.get(tg, ("control",))[0] == "control":
            continue
        ns, _ = first_struct(r); rel = set(r["truth"]["relevant"])
        for c in r["cells"]:
            rel_n = None if ns is None else round(math.log2(c["n"] / ns))
            w = c["weights"]          # which DFG variant the summarised model is: the last fit on all n (dfg_forced is
            #                           refitted after dfg when both are kept); with no stack weight the last out-of-fold fit
            variant = "forced" if "dfg_forced" in w else "default" if "dfg" in w else ("forced" if c["n"] <= 512 else "default")
            q = dict(suite=su, target=tg, n=c["n"], n_struct=ns, rel=rel_n, phase="never" if ns is None else ("below" if c["n"] < ns else "at/after"),
                     variant=variant, w_tot=round(sum(w.values()), 3), w_dfg_abs=round(sum(v for k, v in w.items() if k.startswith("dfg")), 3),
                     err=round(c["err"], 4), err_dfg=None if c.get("err_dfg") is None else round(c["err_dfg"], 4), w_dfg=c["w_dfg"],
                     source="final" if c.get("dfg_source") == "final" else "oof")
            q.update(member_shares(c["weights"])); q.update(cell_contents(c, rel, big_classes(r)))
            out.append(q)
    return out


def below_summary(B):
    S = {}
    for ph in ("below", "at/after", "never"):
        R = [b for b in B if b["phase"] == ph]
        if not R:
            continue
        S[ph] = dict(cells=len(R), empty=sum(b["empty"] for b in R), spurious_chi_cells=sum(b["spur_chi"] > 0 for b in R),
                     true_chi_cells=sum(b["true_chi"] > 0 for b in R), partial_block_cells=sum(b["partial"] for b in R),
                     linear_block_cells=sum(b["linear_block"] for b in R),
                     median_spur_share=float(np.median([b["spur_share"] for b in R])),
                     median_w_dfg=float(np.median([b["w_dfg"] for b in R])), mean_w_dfg=float(np.mean([b["w_dfg"] for b in R])),
                     median_err_dfg=float(np.median([b["err_dfg"] for b in R if b["err_dfg"] is not None])),
                     median_err=float(np.median([b["err"] for b in R])),
                     oof_source=sum(b["source"] == "oof" for b in R),
                     mean_shares={m: round(float(np.mean([b[m] for b in R])), 3) for m, _ in MEMBERS})
    rel = {}
    for b in B:
        if b["rel"] is not None:
            rel.setdefault(b["rel"], []).append(b)
    for ph in ("below", "never"):
        for var in ("default", "forced"):
            R = [b for b in B if b["phase"] == ph and b["variant"] == var]
            if R:
                S[f"{ph}_{var}"] = dict(cells=len(R), empty=sum(b["empty"] for b in R), spurious_chi_cells=sum(b["spur_chi"] > 0 for b in R),
                                        true_chi_cells=sum(b["true_chi"] > 0 for b in R), partial_block_cells=sum(b["partial"] for b in R),
                                        spur_degrees=sorted(set(x for b in R for x in b["deg_spur"])))
    byn = {}
    for b in B:
        byn.setdefault(b["n"], []).append(b)
    S["by_n"] = {int(n): dict(cells=len(v), mean_w_dfg=round(float(np.mean([b["w_dfg"] for b in v])), 3),
                              zero_dfg=sum(b["w_dfg"] == 0 for b in v), found=sum(b["exact"] for b in v),
                              mean_shares={m: round(float(np.mean([b[m] for b in v])), 3) for m, _ in MEMBERS})
                 for n, v in sorted(byn.items())}
    S["by_log2_n_over_n_struct"] = {int(k): dict(cells=len(v), median_w_dfg=float(np.median([b["w_dfg"] for b in v])),
                                                 mean_w_dfg=round(float(np.mean([b["w_dfg"] for b in v])), 3),
                                                 empty=sum(b["empty"] for b in v), spur=sum(b["spur_chi"] > 0 for b in v),
                                                 partial=sum(b["partial"] for b in v),
                                                 median_err_dfg=float(np.median([b["err_dfg"] for b in v if b["err_dfg"] is not None])),
                                                 median_err=float(np.median([b["err"] for b in v])))
                                     for k, v in sorted(rel.items())}
    return S


def fig_wdfg(B, path):
    import matplotlib; matplotlib.use("Agg"); import matplotlib.pyplot as plt
    plt.rcParams.update({"font.size": 7, "axes.titlesize": 7, "axes.labelsize": 7, "legend.fontsize": 6})
    fig, axs = plt.subplots(1, 3, figsize=(7.0, 2.3))
    R = [b for b in B if b["rel"] is not None]; ks = sorted(set(b["rel"] for b in R)); ks = [k for k in ks if -5 <= k <= 4]
    for ax, key, lab in ((axs[0], "w_dfg", "stacker weight share of DFG"), (axs[1], "err_dfg", "test error of the DFG member alone")):
        for k in ks:
            v = [b[key] for b in R if b["rel"] == k and b[key] is not None]
            ax.scatter(np.full(len(v), k) + np.random.default_rng(k + 9).uniform(-0.18, 0.18, len(v)), v, s=4, color="#1f77b4", alpha=0.45, lw=0)
            if v:
                ax.plot([k - 0.3, k + 0.3], [np.median(v)] * 2, color="#d62728", lw=1.2)
        ax.set_xlabel("log2(n / n_struct)"); ax.set_ylabel(lab); ax.axvline(-0.5, color="#888", lw=0.5, ls=":")
    axs[1].plot([], [], color="#d62728", lw=1.2, label="median"); axs[1].legend(frameon=False, loc="upper right")
    # composition of the stack below / at-after / never
    phases = [p for p in ("below", "at/after", "never") if any(b["phase"] == p for b in B)]
    bottom = np.zeros(len(phases)); colors = {"dfg": "#d62728", "dfg_forced": "#ff9896", "gbt": "#2ca02c", "et": "#98df8a", "knn": "#9467bd", "lin": "#7f7f7f"}
    for m, _ in MEMBERS:
        v = np.array([np.mean([b[m] for b in B if b["phase"] == p]) for p in phases])
        axs[2].bar(range(len(phases)), v, bottom=bottom, color=colors[m], label=m, width=0.6); bottom += v
    axs[2].set_xticks(range(len(phases))); axs[2].set_xticklabels([f"{p}\n({sum(b['phase'] == p for b in B)} cells)" for p in phases], fontsize=6)
    axs[2].set_ylabel("mean stacker weight share"); axs[2].legend(frameon=False, fontsize=5, loc="upper right", ncol=2)
    axs[2].set_ylim(0, 1.25)
    for a in axs:
        a.tick_params(labelsize=6)
    axs[0].set_title("(a) DFG's weight in the stack"); axs[1].set_title("(b) DFG member error"); axs[2].set_title("(c) members' weights")
    fig.tight_layout(); fig.savefig(path); plt.close(fig)


# ------------------------------------------------------------------------------------------------ Q5: v3 against v2
def ratio_at(P, key, n):
    p = P.get(key)
    c = None if p is None else next((c for c in p["cells"] if c["n"] == n), None)
    return None if c is None else round(max(c["unfold"]["ratio"], c["fold"]["ratio"], c["modulated"]["ratio"]), 3)


def v2v3(rows, S3, S2, P=None):
    out = []
    for r in rows:
        if r["suite"] not in SUM_SUITES or (r["suite"], r["target"]) not in S2:
            continue
        a, b = S3[(r["suite"], r["target"])], S2[(r["suite"], r["target"])]
        n3, n2 = r["n_struct"], r["n_struct_v2"]
        c3 = next((c for c in a["cells"] if c["n"] == n3), None) if n3 else None
        w3 = [t for c in a["cells"] for t in (c.get("terms") or []) if t["kind"] == "sum" and t.get("inner")]
        first_w = next((c["n"] for c in a["cells"] if any(t["kind"] == "sum" and t.get("inner") and t["share"] >= 0.2 * max(x["share"] for x in c["terms"]) for t in c["terms"] or [])), None)
        # which change: weighted block at v3's n_struct; small-n (n <= 128: beam; forced variant in the stack)
        mech = "–"
        if n3 and (n2 is None or n3 < n2):
            if c3 and any(t["kind"] == "sum" and t.get("inner") for t in c3["terms"] or []):
                mech = "weighted block"
            elif n3 <= 128:
                mech = "small-n search (beam" + (", forced variant in stack" if c3 and c3["weights"].get("dfg_forced") else "") + ")"
            else:
                mech = "other"
        elif n3 and n2 and n3 > n2:
            mech = "later in v3"
        elif n3 is None and n2 is None:
            mech = "neither" if r["classes"] != "–" else "control"
        elif n3 == n2:
            mech = "same n"
        e3 = {c["n"]: c["err"] for c in a["cells"]}; e2 = {c["n"]: c["err"] for c in b["cells"]}
        common = sorted(set(e3) & set(e2)); diff = [n for n in common if abs(e3[n] - e2[n]) > 1e-12]
        out.append(dict(suite=r["suite"], target=r["target"], kind=r["kind"], mixture=r["mixture"], classes=r["classes"],
                        n_struct_v2=n2, n_struct_v3=n3, n_dfg01_v2=r["n_dfg01_v2"], n_dfg01_v3=r["n_dfg01"], nstar3_v2=r["nstar3_v2"], nstar3_v3=r["nstar3"],
                        nstar_s0_v2=nstar([c["n"] for c in b["cells"]], [c["err"] for c in b["cells"]]), nstar_s0_v3=r["nstar_s0"],
                        l2_nstar3=l2(r["nstar3"], r["nstar3_v2"]), l2_nstar_s0=l2(r["nstar_s0"], nstar([c["n"] for c in b["cells"]], [c["err"] for c in b["cells"]])),
                        mechanism=mech, n_weighted_first=first_w, ratio_at_struct_v3=ratio_at(P or {}, (r["suite"], r["target"]), n3) if n3 else None,
                        stack_at_struct_v3={k: v for k, v in c3["weights"].items() if k.startswith("dfg")} if c3 else None, cells_differ=len(diff), cells_common=len(common),
                        v3_at_struct=lead_terms(c3) if c3 else "", v2_at_v3_struct=lead_terms(next((c for c in b["cells"] if c["n"] == n3), {})) if n3 else ""))
    return out



# ------------------------------------------------------------------------------------------------ Q4: failures
def failure_rows(rows, S3, P, names):
    out = []
    for su, tg in names:
        r = next((x for x in rows if x["suite"] == su and x["target"] == tg), None); R = S3.get((su, tg)); p = P.get((su, tg))
        if r is None or R is None or p is None:
            continue
        last = R["cells"][-1]; c16 = p["cells"][-1]; k = p["k"]; W = p["fourier_by_degree"]
        nz = [i for i in range(1, len(W)) if W[i] > 1e-6]
        out.append(dict(suite=su, target=tg, desc=r["desc"][:70], k_class=k, n_struct=r["n_struct"], n_max=r["n_max"],
                        err_last=r["err_last"], err_dfg_last=r["err_dfg_last"], w_dfg_last=r["w_dfg_last"], lead=r["lead"],
                        best_jaccard_last=max([x["jaccard"] for x in last.get("classes") or []] + [0]),
                        n_unfold=r.get("n_unfold"), n_fold=r.get("n_fold"), n_mod=r.get("n_mod"),
                        ratio_unfold_max=c16["unfold"]["ratio"], ratio_fold_max=c16["fold"]["ratio"], ratio_mod_max=c16["modulated"]["ratio"],
                        n_power_max=c16["n"], W0=round(W[0], 4), W1=round(W[1], 5), W2=round(W[2], 5),
                        W_le2=round(sum(W[1:3]), 5), W_le3=round(sum(W[1:4]), 5), deg_peak=int(np.argmax(W[1:]) + 1), min_deg=nz[0] if nz else None,
                        reach_deg1_max=round(c16["search"]["deg1"], 2), reach_eig_max=round(max(c16["search"]["eig"]), 2),
                        reach_eig_k5_max=round(max(c16["search"]["eig_k5"]), 2), chance=round(k / 30, 2),
                        nstar3=fmt_n(r["nstar3"]) if r["nstar3"] else "–", nets_best=fmt_n(r["nets_best"]) if r["nets_best"] else "–"))
    return out


def fig_failures(F, P, S3, path):
    import matplotlib; matplotlib.use("Agg"); import matplotlib.pyplot as plt
    plt.rcParams.update({"font.size": 6.5, "axes.titlesize": 6.5, "axes.labelsize": 6.5, "legend.fontsize": 5.5})
    m = len(F); fig, axs = plt.subplots(m, 3, figsize=(7.0, 1.25 * m + 0.4), squeeze=False)
    for i, f in enumerate(F):
        p = P[(f["suite"], f["target"])]; ns = [c["n"] for c in p["cells"]]
        a = axs[i, 0]
        a.plot(ns, [c["unfold"]["ratio"] for c in p["cells"]], "-o", ms=2, color="#1f77b4", label="unfolded t")
        a.plot(ns, [c["fold"]["ratio"] for c in p["cells"]], "-s", ms=2, color="#ff7f0e", label="folded |t|")
        a.plot(ns, [max(c["modulated"]["ratio"], 1e-3) for c in p["cells"]], "-^", ms=2, color="#2ca02c", label="modulated")
        a.axhline(1, color="k", lw=0.6); a.set_xscale("log", base=2); a.set_yscale("log"); a.set_ylim(1e-2, 300)
        if f["n_struct"]:
            a.axvline(f["n_struct"], color="#d62728", lw=0.8, ls="--")
        a.set_ylabel(f"{f['target']}\nT / threshold", fontsize=6)
        b = axs[i, 1]
        b.plot(ns, [max(c["search"]["eig"]) for c in p["cells"]], "-o", ms=2, color="#9467bd", label="top-2 eigvec. prefix")
        b.plot(ns, [c["search"]["deg1"] for c in p["cells"]], "-s", ms=2, color="#8c564b", label="degree-1 order")
        b.plot(ns, [max(c["search"]["eig_k5"]) for c in p["cells"]], ":", color="#9467bd", lw=0.8, label="eigvec., |S|+5")
        b.axhline(f["k_class"] / 30, color="#888", lw=0.6, ls="--", label="chance |S|/d"); b.set_xscale("log", base=2); b.set_ylim(0, 1.05)
        if f["n_struct"]:
            b.axvline(f["n_struct"], color="#d62728", lw=0.8, ls="--")
        b.set_ylabel("fraction of S\nreached", fontsize=6)
        c = axs[i, 2]; W = p["fourier_by_degree"]
        c.bar(range(1, len(W)), W[1:], color="#7f7f7f", width=0.7); c.set_xlim(0.3, 14.7); c.set_ylabel("Fourier weight", fontsize=6)
        c.set_xticks(range(1, 15, 2))
        c.text(0.98, 0.9, f"W1+W2 = {sum(W[1:3]):.3f}", transform=c.transAxes, ha="right", va="top", fontsize=5.5)
        for q in axs[i]:
            q.tick_params(labelsize=5.5)
    axs[0, 0].legend(frameon=False, loc="upper left", fontsize=5); axs[0, 1].legend(frameon=False, loc="upper left", fontsize=5, ncol=2)
    axs[-1, 0].set_xlabel("n (seed-0 training rows)"); axs[-1, 1].set_xlabel("n"); axs[-1, 2].set_xlabel("degree |T|")
    axs[0, 0].set_title("(a) DFG's test on the true block"); axs[0, 1].set_title("(b) does the search order reach S?")
    axs[0, 2].set_title("(c) target's Fourier weight by degree")
    fig.tight_layout(h_pad=0.3); fig.savefig(path); plt.close(fig)


# ------------------------------------------------------------------------------------------------ Q3: learned g(t)
def fig_g(S3, G, picks, path):
    """picks: list of (suite, target, n, title) for the stored g lists, or (suite, target, n, title, 'tau') for a toy_g refit."""
    import matplotlib; matplotlib.use("Agg"); import matplotlib.pyplot as plt
    plt.rcParams.update({"font.size": 6.5, "axes.titlesize": 6.5, "axes.labelsize": 6.5, "legend.fontsize": 5.5})
    cols = 4; rws = int(math.ceil(len(picks) / cols))
    fig, axs = plt.subplots(rws, cols, figsize=(7.0, 1.75 * rws + 0.2), squeeze=False); used = []
    for ax, pk in zip(axs.ravel(), picks):
        su, tg, n, title = pk[:4]
        if len(pk) == 4:
            R = S3.get((su, tg)); c = None if R is None else next((x for x in R["cells"] if x["n"] == n), None)
            if c is None or not c.get("classes"):
                ax.axis("off"); continue
            g = np.array(c["classes"][0]["g"], float); keep = g[:, 1] >= 5
            ax.bar(g[keep, 0], g[keep, 2], width=1.4, color="#cccccc", label="E[f | t] (truth)")
            ax.plot(g[keep, 0], g[keep, 3], "o-", ms=2.5, lw=0.8, color="#d62728", label="mean DFG value")
            used.append(R["_path"])
            ax.set_title(f"{tg} (n={n}): {title}", fontsize=6)
        else:
            J = G.get((su, tg, n))
            if J is None:
                ax.axis("off"); continue
            g = np.array(J["rows"], float); keep = g[:, 2] >= 5
            for tv, colr in ((1.0, "#1f77b4"), (-1.0, "#ff7f0e")):
                m = keep & (g[:, 1] == tv); o = np.argsort(g[m, 0])
                ax.step(g[m, 0][o], g[m, 3][o], where="mid", color=colr, lw=0.8, alpha=0.6)
                ax.plot(g[m, 0][o], g[m, 4][o], "o", ms=2.5, color=colr, label=f"tau = {int(tv):+d}")
            used.append(J["_path"])
            ax.set_title(f"{tg} (n={n}): {title}", fontsize=6)
        ax.axhline(0, color="#888", lw=0.4); ax.set_xlabel("t = true signed sum", fontsize=6); ax.tick_params(labelsize=5.5)
        ax.set_ylim(-1.6, 1.6)
    for ax in axs.ravel()[len(picks):]:
        ax.axis("off")
    from matplotlib.lines import Line2D
    from matplotlib.patches import Patch
    h = [Patch(color="#cccccc", label="E[f | t] (truth)"), Line2D([], [], color="#d62728", marker="o", ms=2.5, lw=0.8, label="mean DFG value"),
         Line2D([], [], color="#1f77b4", lw=0.8, alpha=0.6, label="tau = +1: truth (step)"), Line2D([], [], color="#1f77b4", marker="o", ls="", ms=2.5, label="tau = +1: mean DFG value"),
         Line2D([], [], color="#ff7f0e", lw=0.8, alpha=0.6, label="tau = -1: truth (step)"), Line2D([], [], color="#ff7f0e", marker="o", ls="", ms=2.5, label="tau = -1: mean DFG value")]
    fig.legend(handles=h, loc="lower center", ncol=6, fontsize=5.5, frameon=False)
    fig.tight_layout(rect=(0, 0.05, 1, 1)); fig.savefig(path); plt.close(fig)
    return used


def load_g():
    G = {}
    for p in sorted(glob.glob(os.path.join(EXTRA, "toy_g", "v3", "*.json"))):
        J = json.load(open(p)); J["_path"] = p; G[(J["suite"], J["target"], J["n"])] = J
    return G




def check_identity(S, tag):
    """The structure runs reproduce the evaluation's seed-0 cells: compare their test errors with the result files'."""
    res = dict(cells=0, equal=0, differ=[])
    for (su, tg), r in S.items():
        for nm in NSTAR_FILES[tag]:
            p = os.path.join(RES, f"toy__{nm}__{su}.json")
            if not os.path.exists(p):
                continue
            D = json.load(open(p)); f = D["fns"].get(tg)
            if f is None:
                break
            for c in r["cells"]:
                if c["n"] in D["ns"]:
                    e = f["err"][D["ns"].index(c["n"])][0]
                    if e is None or (isinstance(e, float) and not np.isfinite(e)):
                        continue
                    res["cells"] += 1
                    if abs(e - c["err"]) < 1e-9:
                        res["equal"] += 1
                    else:
                        res["differ"].append([su, tg, c["n"], e, c["err"]])
            break
    return res


def load_power_w():
    W = {}
    for p in sorted(glob.glob(os.path.join(EXTRA, "toy_power_w", "*.json"))):
        J = json.load(open(p)); J["_path"] = p
        J["n_detect_w"] = next((c["n"] for c in J["cells"] if max(c["weighted"]["ratio"], c["weighted_fold"]["ratio"]) > 1), None)
        J["n_detect_unit"] = next((c["n"] for c in J["cells"] if max(c["unit"]["ratio"], c["unit_fold"]["ratio"]) > 1), None)
        W[(J["suite"], J["target"])] = J
    return W



def weighted_usage(S3):
    """Every v3 model (any n) with a weighted block (inner term a*tau) among its terms with share >= 20% of the largest:
    the first such n, the block, and where tau's inputs sit relative to the target (in the largest class; another
    relevant input; irrelevant)."""
    out = []
    for (su, tg), r in sorted(S3.items(), key=lambda kv: (SUITES_ORDER.index(kv[0][0]), kv[0][1])):
        rel = set(r["truth"]["relevant"]); big = big_classes(r); cls = set().union(*[set(c["S"]) for c in big]) if big else set()
        for c in r["cells"]:
            T = c.get("terms") or []
            top = max([t["share"] for t in T if t["kind"] != "const"] + [1e-12])
            W = [t for t in T if t["kind"] == "sum" and t.get("inner") and t["share"] >= 0.2 * top]
            if W:
                t = W[0]; inp = set(t["inner"]["inputs"])
                where = "in a class" if inp <= cls else "other relevant input" if inp <= rel else "irrelevant"
                n_last = sum(1 for cc in r["cells"] if any(x["kind"] == "sum" and x.get("inner") for x in cc.get("terms") or []))
                out.append(dict(suite=su, target=tg, kind=KIND.get(tg, ("–", "–"))[0], mixture=KIND.get(tg, ("–", "–"))[1], n_first=c["n"],
                                block=t["desc"], tau_kind=t["inner"]["kind"], a=t["inner"]["a"], tau_inputs="+".join(f"x{i + 1}" for i in sorted(inp)),
                                tau_where=where, share_rel=round(t["share"] / top, 2), cells_with_weighted=n_last, cells=len(r["cells"]),
                                err_dfg=c.get("err_dfg"), exact_here=exact_all(c)))
                break
    return out



def landscape_table():
    out = []
    for p in sorted(glob.glob(os.path.join(EXTRA, "toy_landscape", "*.json"))):
        J = json.load(open(p))
        out.append(dict(suite=J["suite"], target=J["target"], n=J["n"], k=J["k"], true=J["true"],
                        **{f"{k}": J[k]["median"] for k in ("drop_1", "drop_2", "drop_3", "drop_4", "add_1", "add_2", "flip_1", "flip_2", "mixed_3", "random_k")},
                        mixed_3_frac_gt1=J["mixed_3"]["frac_gt1"], pairs_in_max=J["pairs_in_max"], singles_in_max=J["singles_in_max"],
                        pairs_out_max=J["pairs_out_max"], file=os.path.basename(p)))
    return out


def fig_v2v3(V, path):
    import matplotlib; matplotlib.use("Agg"); import matplotlib.pyplot as plt
    plt.rcParams.update({"font.size": 7, "axes.titlesize": 7, "axes.labelsize": 7, "legend.fontsize": 6})
    col = {"weighted block": "#d62728", "small-n search (beam)": "#1f77b4", "small-n search (beam, forced variant in stack)": "#17becf",
           "same n": "#7f7f7f", "later in v3": "#ff7f0e", "neither": "#000000", "control": "#bbbbbb", "other": "#9467bd", "–": "#bbbbbb"}
    fig, axs = plt.subplots(1, 2, figsize=(7.0, 2.9)); TOP = 2 ** 15.4
    jit = lambda t: 2 ** (0.1 * ((sum(map(ord, t["target"])) % 7) - 3))
    for v in V:
        if v["classes"] != "–":
            x = v["n_struct_v2"] or TOP; y = v["n_struct_v3"] or TOP
            axs[0].scatter(x * jit(v), y / jit(v), s=18, color=col.get(v["mechanism"], "#9467bd"), edgecolor="k", lw=0.3)
            if v["mechanism"] not in ("same n", "neither", "control"):
                axs[0].annotate(v["target"], (x * jit(v), y / jit(v)), fontsize=5, xytext=(3, -3), textcoords="offset points")
        a, b = v["nstar_s0_v2"], v["nstar_s0_v3"]
        a = a if np.isfinite(a) else TOP; b = b if np.isfinite(b) else TOP
        axs[1].scatter(a, b, s=18, color=col.get(v["mechanism"], "#9467bd"), edgecolor="k", lw=0.3)
        if v["l2_nstar_s0"] is not None and abs(v["l2_nstar_s0"]) >= 0.5:
            axs[1].annotate(v["target"], (a, b), fontsize=5, xytext=(3, -3), textcoords="offset points")
    for ax, (xl, yl) in zip(axs, [("n_struct, v2 (DFG v1.2)", "n_struct, v3 (DFG v1.3)"), ("n*, v2 (seed 0)", "n*, v3 (seed 0)")]):
        ax.set_xscale("log", base=2); ax.set_yscale("log", base=2); ax.plot([8, 2 ** 15], [8, 2 ** 15], color="#888", lw=0.6)
        ax.set_xlim(2 ** 3.5, 2 ** 15.8); ax.set_ylim(2 ** 3.5, 2 ** 15.8); ax.set_xlabel(xl); ax.set_ylabel(yl); ax.tick_params(labelsize=6)
        ax.axhline(2 ** 15, color="#bbb", lw=0.5, ls=":"); ax.axvline(2 ** 15, color="#bbb", lw=0.5, ls=":")
    from matplotlib.lines import Line2D
    seen = sorted(set(v["mechanism"] for v in V))
    axs[0].legend(handles=[Line2D([], [], marker="o", ls="", color=col.get(k, "#9467bd"), mec="k", mew=0.3, label=k) for k in seen],
                  frameon=False, fontsize=5, loc="upper left")
    axs[0].set_title("(a) first n with the exact structure"); axs[1].set_title("(b) n* (10% test error), seed 0")
    fig.tight_layout(); fig.savefig(path); plt.close(fig)


G_PICKS = [("dlheld4", "tail13", 256, "band |s| >= 5"), ("dlheld6", "h6_11", 128, "interval s == 1"),
           ("dlheld6", "h6_01", 512, "arbitrary, signed"), ("dlheld7", "f7_01", 256, "threshold s <= 1"),
           ("dlheld6", "h6_10", 256, "|s - 3 x13| > 1; tau = x13", "tau"), ("dlheld6", "h6_10", 512, "|s - 3 x13| > 1; tau = x13", "tau"),
           ("dlheld7", "f7_10", 256, "s + 2 x6 <= -1; tau = x6", "tau"), ("dlheld7", "f7_09", 256, "[s <= 0] x11 x12; tau = x11 x12", "tau")]
FAIL = [("dlfamdev", "fd_10"), ("dlheld6", "h6_00"), ("dlheld7", "f7_05"), ("dlsymdev", "band11"), ("dlheld7", "f7_08"),
        ("dlheld5", "h5s1"), ("dlheld5", "h5s7")]


def main():
    S3, S2, P = load_struct("v3"), load_struct("v2"), load_power()
    N3, N2, NN = load_nstar("v3"), load_nstar("v2"), load_nets()
    rows = target_rows(S3, S2, P, N3, N2, NN)
    out = dict(inputs=dict(v3=sorted(os.path.basename(r["_path"]) for r in S3.values()), v2=sorted(os.path.basename(r["_path"]) for r in S2.values()),
                           suites_v3=sorted(set(k[0] for k in S3)), suites_v2=sorted(set(k[0] for k in S2)),
                           nstar_v3_files=sorted(set(v[1] for v in N3.values())), nstar_v2_files=sorted(set(v[1] for v in N2.values()))))
    out["by_suite"], out["by_kind"] = recovery_tables(rows)
    out["nonsum"], out["nonsum_by_suite"] = nonsum_table(rows, S3)
    PW = load_power_w(); T = timing(rows, PW, P); out["timing"] = timing_summary(T)
    out["power_w"] = {f"{k[0]}/{k[1]}": dict(n_detect_w=v["n_detect_w"], n_detect_unit=v["n_detect_unit"], file=os.path.basename(v["_path"])) for k, v in PW.items()}
    out["identity"] = dict(v3=check_identity(S3, "v3"), v2=check_identity(S2, "v2"))
    write_csv("toy_timing.csv", T, list(T[0].keys()) if T else [])
    fig_timing(T, os.path.join(FIG, "fig_toy_timing.pdf"))
    F = failure_rows(rows, S3, P, [f for f in FAIL] + [(r["suite"], r["target"]) for r in rows if r["suite"] in SUM_SUITES and r["classes"] != "–"
                                                      and r["kind"] != "control" and (r["n_struct"] is None or r["n_struct"] >= 1024) and (r["suite"], r["target"]) not in FAIL])
    write_md("toy_failures.md", F, ["suite", "target", "k_class", "n_struct", "n_max", "err_last", "n_unfold", "n_fold", "n_mod",
                                    "ratio_unfold_max", "ratio_fold_max", "W1", "W2", "W_le3", "deg_peak", "reach_eig_max", "reach_deg1_max",
                                    "chance", "best_jaccard_last", "nstar3", "nets_best", "lead"],
             head="### Targets never learned or learned late (n_struct >= 1024) by v3's DFG member (seed 0)",
             note="n_unfold / n_fold / n_mod: first n with T / threshold > 1 for the true block (toy_power); ratio_*_max: at the largest power n "
                  "(16384); W_k: the target's Fourier weight at degree k; deg_peak: the degree with the largest weight; reach_*: fraction of the "
                  "true class among the top |S| inputs of the search's orders at n = 16384 (eigenvector prefix: best of the top 2); chance = |S| / 30; "
                  "best_jaccard_last: best Jaccard overlap of a learned block, factor or modulator with the true class at n_max.")
    write_csv("toy_failures.csv", F, list(F[0].keys()) if F else [])
    out["failures"] = F
    if F:
        fig_failures([f for f in F if (f["suite"], f["target"]) in FAIL], P, S3, os.path.join(FIG, "fig_toy_failures.pdf"))
    V = v2v3(rows, S3, S2, P)
    write_md("toy_v2_v3.md", V, ["suite", "target", "kind", "mixture", "classes", "n_struct_v2", "n_struct_v3", "n_dfg01_v2", "n_dfg01_v3", "nstar_s0_v2", "nstar_s0_v3",
                                 "nstar3_v2", "nstar3_v3", "l2_nstar3", "mechanism", "ratio_at_struct_v3", "stack_at_struct_v3", "cells_differ", "cells_common", "v3_at_struct", "v2_at_v3_struct"],
             head="### v3 (DFG v1.3) against v2 (DFG v1.2) on the sum-structured suites (seed 0 structure runs; n* also 3 seeds)",
             note="mechanism: what v3's model has at its n_struct when that is earlier than v2's ('weighted block': a block with an inner term "
                  "a*tau; 'small-n search': n_struct <= 128 without a weighted block, i.e. the beam search, and the forced variant when it has "
                  "stack weight); cells_differ: analysed n at which v2's and v3's portfolio test errors differ (of cells_common).")
    write_csv("toy_v2_v3.csv", V, list(V[0].keys()) if V else [])
    fig_v2v3(V, os.path.join(FIG, "fig_toy_v2v3.pdf"))
    l3 = [v["l2_nstar3"] for v in V if v["l2_nstar3"] is not None]; l0 = [v["l2_nstar_s0"] for v in V if v["l2_nstar_s0"] is not None]
    out["v2v3"] = dict(targets=len(V), mech={m: [v["target"] for v in V if v["mechanism"] == m] for m in sorted(set(v["mechanism"] for v in V))},
                       mean_l2_nstar3=float(np.mean(l3)) if l3 else None, n_l2_nstar3=len(l3), mean_l2_nstar_s0=float(np.mean(l0)) if l0 else None,
                       n_l2_nstar_s0=len(l0), identical_targets=[v["target"] for v in V if v["cells_differ"] == 0])
    WU = weighted_usage(S3)
    write_md("toy_weighted_blocks_v3.md", WU, ["suite", "target", "kind", "mixture", "n_first", "block", "tau_where", "share_rel", "cells_with_weighted", "cells", "err_dfg", "exact_here"],
             head="### Where v3's models use a weighted block u = t + a*tau (seed 0; first n with one among the terms of share >= 20% of the largest)",
             note="tau_where: tau's inputs lie in a true symmetry class, are other relevant inputs (a parity partner, a mux selector, a gate literal or "
                  "the true inner term), or are irrelevant; cells_with_weighted: analysed n whose model has any weighted block (of cells).")
    write_csv("toy_weighted_blocks_v3.csv", WU, list(WU[0].keys()) if WU else [])
    out["weighted_usage"] = dict(targets=len(WU), by_where={w: [x["target"] for x in WU if x["tau_where"] == w] for w in sorted(set(x["tau_where"] for x in WU))})
    LS = landscape_table()
    write_md("toy_landscape.md", LS, ["suite", "target", "n", "k", "true", "drop_1", "drop_2", "drop_3", "drop_4", "add_1", "add_2", "flip_1",
                                       "flip_2", "mixed_3", "mixed_3_frac_gt1", "random_k", "pairs_in_max", "singles_in_max", "pairs_out_max"],
             head="### DFG's block statistic around the true block (T / threshold, best of unfolded and folded; seed-0 training rows, round 0)",
             note="toy_landscape.py: true = the true block; drop_j / add_j / flip_j = median over 200 random candidates with j inputs removed / "
                  "j random inputs added / j signs flipped; mixed_3 = 3 errors of mixed kinds (and the fraction of those above the threshold); "
                  "random_k = random blocks of the true size; pairs_in_max / singles_in_max = the best 2-input / 1-input block inside S; "
                  "pairs_out_max = the best pair among 12 inputs outside S. > 1 means the candidate passes DFG's test.")
    out["landscape"] = LS
    B = below_discovery(S3)
    write_csv("toy_below_discovery.csv", B, list(B[0].keys()) if B else [])
    out["below"] = below_summary(B)
    fig_wdfg(B, os.path.join(FIG, "fig_toy_wdfg.pdf"))
    G = load_g(); out["g_files"] = fig_g(S3, G, G_PICKS, os.path.join(FIG, "fig_toy_g.pdf"))
    json.dump(out, open(os.path.join(TAB, "toy_summary.json"), "w"), indent=1, default=lambda v: v.item() if hasattr(v, "item") else str(v))
    return out, rows


if __name__ == "__main__":
    out, rows = main()
    print(json.dumps({k: out[k] for k in ("by_suite", "timing", "v2v3", "below")}, indent=1, default=str)[:6000])

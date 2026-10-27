"""Part 10 tables (study/part10/RESULTS.md), computed from result files with compare_hybrid.py's and compare_part9.py's
functions.  usage: python compare_part10.py [v3_name]     (default hyb_portfolio3; v2 = hyb_portfolio2)

INTEGRATION RULE (PROTOCOL.md), dev only:
  T  candidate toy learner (p10_sum) vs v2 on designed + dlsymdev + dlfamdev, inputs permuted: mean log2 n* ratio over the
     targets where both reach 10% error, and the largest per-target increase (a target the candidate never reaches but
     v2 does counts as +inf).  v2's toy fits are p9_sum's (v2 = p9_sum on every non-image input: the gates block is the
     only difference and runs on images only), so p9_sum-perm is v2-perm on designed and dlsymdev.
  I  candidate image learners (p10_hier-dev, p10_codes-dev) vs v2 on the 8 dev cells {qd_dev, fashion_mnist} x
     {1000, 10000} and {qd_a, qd_b} x {3000, 10000}, seed 0: mean log2(err / v2 err); plus qd_a n = 60000 (v2 0.1197,
     1757 CPU s) error, CPU and FLOP fraction.  v2's dev cells: hyb_portfolio2 itself (qd_dev and fashion_mnist were run
     for Part 10; Part 9 had measured them with the builder's p9_gates learner).
HELD OUT: toy dlheld7 (n*; nets_best = per-target minimum of nets_wd, nets_cewd0.3, nets_cewd1.0) and images qd_c, qd_d.
BEST-LEARNER RULE: v3 is best if v3 != v2, its mean log2 error ratio against v2 over the qd_c / qd_d cells with
n >= 10000 is below 0, and its mean log2 n* ratio against v2 on dlheld7 is at most +0.1 (only the changed side applies)."""
import os, sys, json, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(STUDY, "hybrid")); sys.path.insert(0, os.path.join(STUDY, "part9"))
import compare_hybrid as CH
_argv = sys.argv; sys.argv = sys.argv[:1]
import compare_part9 as C9
sys.argv = _argv
TH, DATA = CH.TH, CH.DATA
V2 = "hyb_portfolio2"; V3 = sys.argv[1] if len(sys.argv) > 1 else "hyb_portfolio3"
C9.V2 = V2
DEV_TOY = ["designed", "dlsymdev", "dlfamdev"]
IMG_HELD = ["qd_c", "qd_d"]
DEV_CELLS = [("qd_dev", 1000), ("qd_dev", 10000), ("fashion_mnist", 1000), ("fashion_mnist", 10000),
             ("qd_a", 3000), ("qd_a", 10000), ("qd_b", 3000), ("qd_b", 10000)]
NETS7 = ("nets_wd", "nets_cewd0.3", "nets_cewd1.0")
f_n = lambda v: "never" if not np.isfinite(v) else f"{v:.0f}"


def v2_toy(suite):
    """v2-perm n* per target: hyb_portfolio2-perm where run, else p9_sum-perm (identical on toy inputs)."""
    return C9.nst(V2 + "-perm", suite) or C9.nst("p9_sum-perm", suite)


def l2(a, b):
    return CH.l2r(a, b)


def cell_err(name, ds, n, seed=0):
    r = CH.load(name, ds)
    if r is None or n not in r["ns"][:len(r["err"])]:
        return None
    v = np.array(r["err"][r["ns"].index(n)], float)
    s = r["seeds"].index(seed) if seed in r["seeds"] else None
    return None if s is None or not np.isfinite(v[s]) else float(v[s])


def cell_val(name, ds, n, key, seed=0):
    r = CH.load(name, ds)
    if r is None or n not in r["ns"] or r["ns"].index(n) >= len(r.get(key, [])):
        return None
    v = np.array(r[key][r["ns"].index(n)], float); s = r["seeds"].index(seed) if seed in r["seeds"] else None
    return None if s is None or not np.isfinite(v[s]) else float(v[s])


def rule_toy(cand="p10_sum-perm"):
    L = ["### (T) toy component: candidate vs v2 (inputs permuted)", "",
         "| suite | targets | mean log2 n* ratio (both finite) | largest increase | candidate never / v2 reaches | v2 never / candidate reaches |",
         "|---|---|---|---|---|---|"]
    allr, worst = [], -np.inf
    for su in DEV_TOY:
        A, B = C9.nst(cand, su), v2_toy(su)
        if not A or not B:
            L.append(f"| {su} | – (missing: {'candidate' if not A else 'v2'}) | | | | |"); continue
        T = [t for t in A if t in B]; r = {t: l2(A[t], B[t]) for t in T}
        fin = [v for v in r.values() if np.isfinite(v)]; allr += fin
        w = max(r.values()) if r else -np.inf; worst = max(worst, w)
        L.append(f"| {su} | {len(T)} | {np.mean(fin):+.3f} | {w:+.2f} ({max(r, key=r.get)}) | "
                 f"{sum(1 for v in r.values() if v == np.inf)} | {sum(1 for v in r.values() if v == -np.inf)} |")
    m = float(np.mean(allr)) if allr else float("nan")
    ok = bool(allr) and m < -0.05 and worst <= 0.5
    L += ["", f"All dev targets: mean {m:+.3f}, largest increase {worst:+.2f}.  Rule (mean < -0.05 and no target worse "
              f"by more than 0.5): **{'adopted' if ok else 'not adopted'}**.", ""]
    return L, dict(mean=m, worst=worst, adopted=ok)


def rule_img(cands=("p10_hier-dev", "p10_codes-dev")):
    L = ["### (I) image component: candidates vs v2 on the 8 dev cells (seed 0) and the qd_a n = 60000 check", "",
         "| candidate | cells | mean log2(err / v2 err) | per cell (ds@n: cand / v2) | qd_a 60000 err | CPU s | FLOPs / budget | qualifies |",
         "|---|---|---|---|---|---|---|---|"]
    import common
    best, out = None, {}
    v2_60 = (0.1197, 1757.0)
    for c in cands:
        vals, txt = [], []
        for ds, n in DEV_CELLS:
            e, b = cell_err(c, ds, n), cell_err(V2, ds, n)
            if e is None or b is None:
                txt.append(f"{ds}@{n}: missing"); continue
            vals.append(np.log2(e / b)); txt.append(f"{ds}@{n}: {e:.4f}/{b:.4f}")
        e60, cpu60, fl60 = cell_err(c, "qd_a", 60000), cell_val(c, "qd_a", 60000, "cpu_seconds"), cell_val(c, "qd_a", 60000, "flops")
        D = DATA.load("qd_a"); B = common.budget_real(D["X"][:1], list(D["types"]), D["C"], 60000)
        m = float(np.mean(vals)) if len(vals) == 8 else float("nan")
        q = (len(vals) == 8 and m < -0.05 and e60 is not None and e60 <= 1.05 * v2_60[0] and cpu60 is not None
             and cpu60 <= 1.5 * v2_60[1] and fl60 is not None and fl60 <= B)
        out[c] = dict(mean=m, cells=len(vals), e60=e60, cpu60=cpu60, fl60=None if fl60 is None else fl60 / B, qualifies=bool(q))
        L.append(f"| {c} | {len(vals)} | {m:+.3f} | {'; '.join(txt)} | {e60 if e60 is not None else '–'} | "
                 f"{f'{cpu60:.0f}' if cpu60 is not None else '–'} | {f'{fl60 / B:.2f}' if fl60 is not None else '–'} | {'yes' if q else 'no'} |")
        if q and (best is None or m < out[best]["mean"]):
            best = c
    L += ["", f"Adopted image variant: **{best or 'none'}** (the qualifying candidate with the lower mean; v2's qd_a n = 60000: "
              f"0.1197 at 1757 CPU s).", ""]
    return L, dict(cands=out, adopted=best)


def toy_held():
    NR = CH.toy_nstars("dlheld7")
    NR = {k: v for k, v in NR.items() if k in NETS7}
    if NR:
        fns = sorted(set.intersection(*[set(v) for v in NR.values()]))
        NR["nets_best"] = {fn: min(NR[k][fn] for k in NETS7 if k in NR) for fn in fns}
    cols = [(V3 + "-perm", "v3"), (V2 + "-perm", "v2"), ("lin", "lin"), ("hgb", "hgb")]
    N = {c: C9.nst(c, "dlheld7") for c, _ in cols}; have = [(c, h) for c, h in cols if N[c]]
    L = ["## Held-out toy suite `dlheld7` (d = 30; n*; inputs permuted for v2 / v3)", ""]
    if not NR or not have:
        return L + ["(results not complete)", ""], {}
    refc = list(NETS7) + ["nets_best"]
    L += ["| target | " + " | ".join(h for _, h in have) + " | " + " | ".join(k for k in refc if k in NR) + " |",
          "|---|" + "---|" * (len(have) + len([k for k in refc if k in NR]))]
    for fn in NR["nets_best"]:
        L.append(f"| {fn} | " + " | ".join(f_n(N[c][fn]) if fn in N[c] else "–" for c, _ in have) + " | "
                 + " | ".join(f_n(NR[k][fn]) if fn in NR[k] else "–" for k in refc if k in NR) + " |")
    L += ["", "| learner | reference | targets | mean log2 n* ratio | clearly better | clearly worse | learner never |", "|---|---|---|---|---|---|---|"]
    for c, h in have:
        for k in [k for k in refc if k in NR] + ([V2 + "-perm"] if c == V3 + "-perm" and N.get(V2 + "-perm") else []):
            R = NR[k] if k in NR else N[k]
            t = CH.toy_summary(N[c], R)
            L.append(f"| {h} | {k if k in NR else 'v2'} | {t['targets']} | {t['mean']:+.2f} | {t['better']} | {t['worse']} | {t['learner_never']} |")
    L.append("")
    d = None
    if N.get(V3 + "-perm") and N.get(V2 + "-perm"):
        d = CH.toy_summary(N[V3 + "-perm"], N[V2 + "-perm"])["mean"]
    return L, dict(v3_vs_v2=d)


def img_held():
    REFS = ("mlp_strong", "mlp_wide", "mlp_xl", "mlp_best", "mlp_best+")
    CONTEXT = ("mlp_pool", "cnn")
    learners = [V3, V2, "hyb_portfolio", "hgb"]
    L = ["## Held-out images `qd_c`, `qd_d` (QuickDraw, pixel-permuted): test error (seed mean; seed 0 at n = 60000)", ""]
    L += ["| learner | reference | n range | cells | better | tie | worse | mean log2(err / ref err) |", "|---|---|---|---|---|---|---|---|"]
    for l in learners:
        for k in REFS + (CONTEXT if l in (V3, V2) else ()) + ((V2,) if l == V3 else ()):
            for lo, hi, lab in ((0, 10 ** 9, "all"), (0, 3000, "n <= 3000"), (10000, 10 ** 9, "n >= 10000")):
                C = [c for ds in IMG_HELD for c in (CH.cells(CH.load(l, ds), CH.load(k, ds) if k == V2 else C9.ref(k, ds), ds) or [])
                     if lo <= c["n"] <= hi]
                if not C:
                    continue
                v = [c["v"] for c in C]
                L.append(f"| {l} | {k if k != V2 else 'v2'} | {lab} | {len(C)} | {v.count('better')} | {v.count('tie')} | {v.count('worse')} | "
                         f"{np.mean([c['lr'] for c in C]):+.2f} |")
    L.append("")
    cols = learners + list(REFS) + list(CONTEXT)
    L += ["| dataset | n | " + " | ".join(cols) + " |", "|---|---|" + "---|" * len(cols)]
    for ds in IMG_HELD:
        R = {l: (CH.load(l, ds) if l in learners else C9.ref(l, ds)) for l in cols}
        ns = sorted({n for r in R.values() if r for n in r["ns"][:len(r["err"])]})
        for n in ns:
            def g(k):
                r = R.get(k)
                if r is None or n not in r["ns"][:len(r["err"])]:
                    return "–"
                v = np.array(r["err"][r["ns"].index(n)], float)
                return f"{np.nanmean(v):.4f}" if np.isfinite(v).any() else "–"
            L.append(f"| {ds} | {n} | " + " | ".join(g(k) for k in cols) + " |")
    L.append("")
    # best-learner rule, image side: v3 vs v2 over the cells with n >= 10000
    vals = []
    for ds in IMG_HELD:
        a, b = CH.load(V3, ds), CH.load(V2, ds)
        if a is None or b is None:
            continue
        for n in (10000, 60000):
            if n in a["ns"] and n in b["ns"]:
                ea = np.nanmean(np.array(a["err"][a["ns"].index(n)], float)); eb = np.nanmean(np.array(b["err"][b["ns"].index(n)], float))
                if np.isfinite(ea) and np.isfinite(eb):
                    vals.append(np.log2(ea / eb))
    return L, dict(v3_vs_v2_big=float(np.mean(vals)) if vals else None, cells=len(vals))


if __name__ == "__main__":
    LT, rt = rule_toy(); LI, ri = rule_img()
    L = ["# Part 10 results", "", "Generated by `compare_part10.py` from result files (definitions in its docstring).", "",
         "## Integration rule (development data only)", ""] + LT + LI
    if "--dev" not in sys.argv:
        L7, r7 = toy_held(); LQ, rq = img_held(); L += L7 + LQ
        L += ["## Best-learner rule", "", f"v3 vs v2: images (qd_c / qd_d, n >= 10000, {rq.get('cells')} cells) mean log2 error ratio "
              f"{rq.get('v3_vs_v2_big')}; dlheld7 mean log2 n* ratio {r7.get('v3_vs_v2')}.", ""]
    open(os.path.join(HERE, "RESULTS.md" if "--dev" not in sys.argv else "RULE.md"), "w").write("\n".join(L) + "\n")
    print("\n".join(L))

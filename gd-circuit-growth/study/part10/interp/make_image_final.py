"""Figures and tables of the image-side interpretability analysis of v3 (and v2) for IMAGE_INTERP.md (Part 10).
Reads $INTERP_OUT/image/{v3,v2}/<dataset>__n<n>__s<seed>.{json,npz} (written by image_structure.py), checks each fit's test
error against the evaluation cell of the same learner, dataset, n and seed, and writes
  figures/fig_img_*.pdf          (7 inch wide)
  tables/img_*.md                (markdown tables; every number is read or computed from the analysis files named in them)
  tables/img_summary.json        (the derived numbers, machine-readable)
  results/image_final/<tag>/     (copies of the analysis JSONs; the .npz too where under 5 MB)
usage: INTERP_OUT=... python make_image_final.py [--png=dir]     (--png: also PNG copies of the figures, for viewing)"""
import os, sys, json, glob, shutil, numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection
from scipy.spatial import procrustes

HERE = os.path.dirname(os.path.abspath(__file__))
OUTD = os.environ.get("INTERP_OUT", os.path.join(HERE, "results")); IMG = os.path.join(OUTD, "image")
FIG, TAB, RES = os.path.join(HERE, "figures"), os.path.join(HERE, "tables"), os.path.join(HERE, "results", "image_final")
for p in (FIG, TAB, RES):
    os.makedirs(p, exist_ok=True)
opt = {a.split("=", 1)[0][2:]: a.split("=", 1)[1] for a in sys.argv[1:] if a.startswith("--") and "=" in a}
PNG = opt.get("png")
SCR = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad"
CELLS = os.path.join(SCR, "p9", "cells")
CELL_DIR = {"v3": "p10_codes-dev__{ds}", "v2": "hyb_portfolio2__{ds}"}    # v3 = p10_codes on images (ASSEMBLY.md)
plt.rcParams.update({"font.size": 7, "axes.titlesize": 7, "axes.labelsize": 7, "legend.fontsize": 6, "xtick.labelsize": 6,
                     "ytick.labelsize": 6, "figure.dpi": 150, "pdf.fonttype": 42})
LAB = {"fashion_mnist": ["T-shirt", "trouser", "pullover", "dress", "coat", "sandal", "shirt", "sneaker", "bag", "boot"],
       "mnist": [str(i) for i in range(10)]}
for q in ("qd_dev", "qd_a"):                                      # category order = label order (standard_tasks/data.py)
    f = os.path.join(SCR, "std", "data", "quickdraw", q + "_categories.txt")
    if os.path.exists(f):
        LAB[q] = [c for c in open(f).read().split("\n") if c]
DSN = {"qd_dev": "qd_dev", "qd_a": "qd_a", "fashion_mnist": "Fashion", "mnist": "MNIST"}


def rel(p):
    return os.path.relpath(p, HERE) if p.startswith(HERE) else p.replace(SCR, "$SCRATCH")


# ------------------------------------------------------------------------------------------------------------ loading
R = {}
for p in sorted(glob.glob(os.path.join(IMG, "v[23]", "*__s*.json"))):
    tag = os.path.basename(os.path.dirname(p)); r = json.load(open(p))
    npz = p[:-5] + ".npz"
    R[(tag, r["dataset"], r["n"], r["seed"])] = dict(j=r, m=dict(np.load(npz, allow_pickle=True)), path=p, npz=npz)
keys = sorted(R, key=lambda k: (k[0] != "v3", k[1] != "qd_dev", k[1], k[2]))
print("runs:", keys)


def get(tag, ds, n, seed=0):
    return R.get((tag, ds, n, seed))


def fmt(v, d=4):
    return "–" if v is None else (f"{v:.{d}f}" if isinstance(v, float) else str(v))


def save(fig, name):
    fig.savefig(os.path.join(FIG, name))
    if PNG:
        os.makedirs(PNG, exist_ok=True); fig.savefig(os.path.join(PNG, name[:-4] + ".png"), dpi=160)
    plt.close(fig)


def md_table(head, rows):
    return "\n".join(["| " + " | ".join(head) + " |", "|" + "|".join("---" for _ in head) + "|"] +
                     ["| " + " | ".join(str(c) for c in row) + " |" for row in rows]) + "\n"


SUM = {}

# ------------------------------------------------------------------------------------------------- T1: runs + checks
rows = []; SUM["runs"] = {}
for k in keys:
    tag, ds, n, s = k; r = R[k]["j"]
    cf = os.path.join(CELLS, CELL_DIR[tag].format(ds=ds), f"n{n}_s{s}.json")
    ce = json.load(open(cf))["err"] if os.path.exists(cf) else None
    eq = None if ce is None else abs(ce - r["err"]) < 1e-9
    SUM["runs"][f"{tag}/{ds}/n{n}"] = dict(err=r["err"], cell_err=ce, cell=rel(cf) if ce is not None else None, equal=eq,
                                           stack_oof_err=r.get("stack_oof_err"), fit_cpu=r["fit_cpu"], file=rel(R[k]["path"]))
    rows.append([tag, ds, n, s, f"{r['err']:.4f}", "–" if ce is None else f"{ce:.4f}",
                 "no cell" if eq is None else ("yes" if eq else "**NO**"), fmt(r.get("stack_oof_err")), r["fit_cpu"],
                 rel(cf) if ce is not None else "–"])
T1 = md_table(["learner", "dataset", "n", "seed", "test err (analysis fit)", "test err (evaluation cell)", "equal",
               "stacker oof err", "fit CPU s", "cell file"], rows)

# ------------------------------------------------------------------------------------------ T2/T3: pooling, topology
rows2, rows3 = [], []
for k in keys:
    tag, ds, n, s = k; r = R[k]["j"]
    if tag == "v2" and get("v3", ds, n):                              # the pooling sets are the same objects in v2 and v3
        same = all(np.array_equal(R[k]["m"].get(f"pool{q}_members", 0), get("v3", ds, n)["m"].get(f"pool{q}_members", 1))
                   for q in (4, 9, 16))
        SUM.setdefault("pool_same_v2_v3", {})[f"{ds}/n{n}"] = bool(same)
    for q in r["pooling"]["ks"]:
        P = r["pooling"][f"k{q}"]; far = mir = 0
        M = R[k]["m"]
        if f"pool{q}_members" in M:                                     # members > 2 steps away; of them, mirror pixels
            for c, mem in zip(M["pool_centres"].astype(int), M[f"pool{q}_members"].astype(int)):
                for j in mem:
                    r1, c1, r2, c2 = c // 28, c % 28, j // 28, j % 28
                    if j != c and max(abs(r1 - r2), abs(c1 - c2)) > 2:
                        far += 1; mir += int(abs(r1 - r2) <= 1 and abs(c1 + c2 - 27) <= 2)
            SUM.setdefault("pool_far", {})[f"{tag}/{ds}/n{n}/k{q}"] = dict(far=far, mirror=mir, members=int(len(M["pool_centres"]) * (q - 1)))
        rows2.append([tag, ds, n, q, P["mean_dist"], P["within1"], P["within2"], P["p95_dist"], P["max_dist"], P["overlap_nearest"],
                      f"{far} / {mir}" if f"pool{q}_members" in M else "–"])
    T = r["topology"]
    rows3.append([tag, ds, n, r["pooling"]["n_active"]] + [f"{T[v]['procrustes_r2']:.3f} ({T[v]['nodes']})" if v in T else "–"
                                                         for v in ("k4_union", "k9_union", "k9_mutual", "k16_mutual")])
T2 = md_table(["learner", "dataset", "n", "k", "mean Chebyshev dist. of members", "frac. within 1", "frac. within 2",
               "95th pct dist.", "max dist.", "overlap with k nearest",
               "members > 2 steps away / of which mirror pixels (row +-1, c + c' = 27 +- 2)"], rows2)
T3 = md_table(["learner", "dataset", "n", "active pixels", "k=4 union", "k=9 union", "k=9 mutual", "k=16 mutual"], rows3)


def graph_edges(M, k, mode):
    """The edges of image_structure.py's pooling-set graph (k, union / mutual), as pairs of grid pixels."""
    cen = M["pool_centres"].astype(int); mem = M[f"pool{k}_members"].astype(int); S = {int(c): set(int(x) for x in m) - {int(c)} for c, m in zip(cen, mem)}
    E = set()
    for i, nb in S.items():
        for j in nb:
            if j in S and (mode == "union" or i in S[j]):
                E.add((min(i, j), max(i, j)))
    return E


rows3b = []; SUM["graph_edges"] = {}
for k in keys:
    tag, ds, n, s_ = k; M = R[k]["m"]
    if "pool4_members" not in M or tag != "v3":
        continue
    row = [ds, n]
    for kk, mode in ((4, "union"), (9, "union"), (9, "mutual"), (16, "mutual")):
        E = np.array(sorted(graph_edges(M, kk, mode))); L_ = np.max(np.abs(np.stack([E[:, 0] // 28 - E[:, 1] // 28, E[:, 0] % 28 - E[:, 1] % 28], 1)), 1)
        d_ = dict(edges=int(len(E)), len_le1=float(np.mean(L_ <= 1)), len_gt2=int(np.sum(L_ > 2)), len_gt5=int(np.sum(L_ > 5)), max_len=int(L_.max()))
        SUM["graph_edges"][f"{ds}/n{n}/k{kk}_{mode}"] = d_
        row.append(f"{d_['edges']}: {d_['len_le1']:.3f} / {d_['len_gt2']} / {d_['len_gt5']}")
    rows3b.append(row)
T3 += ("\nEdges of the same graphs by their true Chebyshev length: total edges: fraction of length <= 1 / number longer than 2 / "
       "number longer than 5 (computed from the pooling-set member lists in the .npz).\n\n" +
       md_table(["dataset", "n", "k=4 union", "k=9 union", "k=9 mutual", "k=16 mutual"], rows3b))


# ----------------------------------------------------------------------------------------------- bars: geometry, gain
def bar_geom(PL):
    """Per bar (rows of pixel ids, -1 padded): straight lattice line through its pixels (0 none, 1 horiz., 2 vert.,
    3 diag. '\\', 4 antidiag. '/'), contiguous along it, principal orientation (0 / 45 / 90 / 135 degrees; 45 = '/')."""
    st, co, an = np.zeros(len(PL), int), np.zeros(len(PL), bool), np.zeros(len(PL), int)
    for c, row in enumerate(PL):
        px = row[row >= 0]; rr, cc = px // 28, px % 28
        o = (1 if np.all(rr == rr[0]) else 2 if np.all(cc == cc[0]) else 3 if np.all(rr - cc == rr[0] - cc[0])
             else 4 if np.all(rr + cc == rr[0] + cc[0]) else 0)
        st[c] = o
        if o:
            key = cc if o in (1, 3, 4) else rr; co[c] = np.all(np.diff(np.sort(key)) == 1)
        P = np.stack([rr, cc], 1).astype(float); P -= P.mean(0); ev, V = np.linalg.eigh(P.T @ P / len(P)); u = V[:, 1]
        an[c] = int(45 * round((np.degrees(np.arctan2(-u[0], u[1])) % 180) / 45)) % 180
    return st, co, an


rows4 = []; SUM["bars"] = {}
BG = {}
for k in keys:
    tag, ds, n, s = k; r = R[k]["j"]; M = R[k]["m"]
    if "bars" not in r:
        continue
    bst = r["boosters"].get("cgbt"); bank = {b["name"]: (b["start"], b["stop"]) for b in bst["bank"]} if bst else {}
    gv = M.get("cgbt_gain_vec")
    for L in (2, 4):
        if f"bars{L}_pixels" not in M:
            continue
        PL = M[f"bars{L}_pixels"]; el = M[f"bars{L}_elong"]; dv = M[f"bars{L}_dev"]; st, co, an = bar_geom(PL)
        B = r["bars"][f"L{L}"]
        assert abs(np.mean(st > 0) - B["straight_frac"]) < 1e-3, (k, L)
        w = None
        if gv is not None and f"bars{L}" in bank:
            lo, hi = bank[f"bars{L}"]; w = gv[lo:hi].astype(float); w = w / max(w.sum(), 1e-12)
        BG[(tag, ds, n, L)] = dict(st=st, co=co, an=an, el=el, dv=dv, w=w, PL=PL)
        ln = np.sum(PL >= 0, 1)
        allv = dict(n=len(PL), straight=float(np.mean(st > 0)), contiguous=float(np.mean(co)), length=float(ln.mean()),
                    elong_med=float(np.median(el)), elong_ge09=float(np.mean(el >= 0.9)), within1=float(np.mean(dv <= 1.0)),
                    orient={a: float(np.mean(an == a)) for a in (0, 45, 90, 135)})
        gw = None
        if w is not None:
            gw = dict(straight=float(w @ (st > 0)), contiguous=float(w @ co), length=float(w @ ln), elong_mean=float(w @ el),
                      elong_ge09=float(w @ (el >= 0.9)), within1=float(w @ (dv <= 1.0)),
                      orient={a: float(w @ (an == a)) for a in (0, 45, 90, 135)},
                      frac_used=float(np.mean(M["cgbt_split_vec"][lo:hi] > 0)),
                      top24_share=float(np.sort(w)[::-1][:24].sum()), top10pct_share=float(np.sort(w)[::-1][:len(w) // 10].sum()))
        SUM["bars"][f"{tag}/{ds}/n{n}/L{L}"] = dict(all=allv, gain_weighted=gw)
        o = lambda d_: "/".join(f"{d_[a]:.2f}" for a in (0, 45, 90, 135))
        rows4.append([ds, n, L, len(PL), f"{allv['length']:.2f}", f"{allv['straight']:.3f}", f"{allv['contiguous']:.3f}",
                      f"{allv['elong_med']:.3f}", f"{allv['elong_ge09']:.3f}", f"{allv['within1']:.3f}", o(allv["orient"]),
                      "–" if gw is None else f"{gw['straight']:.3f}", "–" if gw is None else f"{gw['elong_ge09']:.3f}",
                      "–" if gw is None else f"{gw['within1']:.3f}", "–" if gw is None else o(gw["orient"]),
                      "–" if gw is None else f"{gw['frac_used']:.3f}", "–" if gw is None else f"{gw['top10pct_share']:.3f}"])
rows4b = []
ONM = {0: "horizontal", 45: "/", 90: "vertical", 135: "\\"}
for k in keys:
    tag, ds, n, s_ = k
    if n != 10000 or (tag, ds, n, 2) not in BG or BG[(tag, ds, n, 2)]["w"] is None:
        continue
    G = R[k]["j"]["boosters"]["cgbt"]["gain"]; pc = R[k]["m"]["pool_centres"]
    for L in (2, 4):
        B = BG[(tag, ds, n, L)]; top = np.argsort(-B["w"])[:10]; items = []
        for t in top:
            c_ = int(pc[t // 4]); px = B["PL"][t][B["PL"][t] >= 0]
            items.append(f"({c_ // 28},{c_ % 28}) {ONM[int(B['an'][t])]}{'' if B['st'][t] else ' bent'} {len(px)}px {100 * B['w'][t] * G[f'bars{L}']['gain_frac']:.2f}%")
        SUM.setdefault("top_bars", {})[f"{ds}/n{n}/L{L}"] = items
        rows4b.append([ds, n, L, "; ".join(items)])
T4b = md_table(["dataset", "n", "L", "the 10 bars with most gain: centre (row, col), principal orientation ('bent' = not a straight "
                "lattice line), pixels, share of cgbt's total gain"], rows4b)
T4 = md_table(["dataset", "n", "L", "bars", "mean pixels", "straight", "contiguous", "elong. median", "elong. >= 0.9",
               "within 1 px of a line", "orient. 0/45/90/135", "straight (gain-wtd)", "elong. >= 0.9 (gain-wtd)",
               "within 1 px (gain-wtd)", "orient. (gain-wtd)", "frac. of bars used", "gain share of top 10% bars"], rows4)

# ------------------------------------------------------------------------------------------------- T5: stack, oof
MEMS = ["cgbt", "ggbt", "gknn_1", "gknn_3", "gknn_9", "gknn_27", "knn_std_1", "knn_std_3", "knn_std_9", "knn_std_27",
        "knn_raw_1", "knn_raw_3", "knn_raw_9", "knn_raw_27", "gbt", "et", "lin_0.05", "lin_1.0"]
rows5 = []; SUM["stack"] = {}
for k in keys:
    tag, ds, n, s = k; r = R[k]["j"]; W = r["weights"] or {}; O = r["member_oof_err"] or {}
    fam = {"cgbt": ["cgbt"], "ggbt": ["ggbt"], "gknn": [m for m in W if m.startswith("gknn")], "knn (Part 8)": [m for m in W if m.startswith("knn")],
           "gbt+et (Part 8)": ["gbt", "et"], "lin (Part 8)": [m for m in W if m.startswith("lin")]}
    tw = sum(W.values())
    SUM["stack"][f"{tag}/{ds}/n{n}"] = dict(weights=W, oof=O, stack_oof=r.get("stack_oof_err"), total_weight=tw,
                                            family_share={f_: sum(W.get(m, 0) for m in ms) / tw for f_, ms in fam.items()},
                                            member_cpu=r.get("member_cpu"))
    rows5.append([tag, ds, n] + [("–" if m not in O else f"{W.get(m, 0):.3f} / {O[m]:.3f}") for m in MEMS])
T5 = md_table(["learner", "dataset", "n"] + MEMS, rows5)

# ------------------------------------------------------------------------------------------------ T6: gain by type
TYPES = ["raw", "pool4", "pool9", "pool16", "bars2", "bars4", "pairs"]
rows6 = []; SUM["gain"] = {}
for k in keys:
    tag, ds, n, s = k; r = R[k]["j"]
    for b, B in sorted(r["boosters"].items()):
        G = B["gain"]; SUM["gain"][f"{tag}/{ds}/n{n}/{b}"] = dict(gain={t: G[t]["gain_frac"] for t in G}, split={t: G[t]["split_frac"] for t in G},
                                                                  used={t: [G[t]["n_used"], G[t]["n"]] for t in G}, rounds=B.get("rounds"),
                                                                  n_fit=B.get("n_fit"), refit=B.get("refit_on_all_n"),
                                                                  test_err_alone=B.get("test_err_alone"))
        rows6.append([tag, ds, n, b, B.get("rounds"), B.get("n_fit"), fmt(B.get("test_err_alone"))] +
                     [("–" if t not in G else f"{G[t]['gain_frac']:.3f} ({G[t]['n_used']}/{G[t]['n']})") for t in TYPES])
T6 = md_table(["learner", "dataset", "n", "booster", "rounds", "rows fitted", "test err alone"] +
              [f"{t}: gain share (features used / all)" for t in TYPES], rows6)

# ------------------------------------------------------------------------------------------------ T7: pairs
rows7 = []; SUM["pairs"] = {}
for k in keys:
    tag, ds, n, s = k; M = R[k]["m"]
    if "ggbt_pair_class_gain" not in M:
        continue
    G2 = M["ggbt_pair_class_gain"]; gv = M["ggbt_gain_vec"]; tot = gv.sum(); pt = G2.sum(); C = len(G2); lab = LAB.get(ds, [str(i) for i in range(C)])
    cnt = None
    if "ggbt_pair_cls" in M:                                            # the number of drawn pairs per (unordered) class pair
        pc = M["ggbt_pair_cls"]; cnt = np.zeros((C, C))
        for a_, b_ in pc:
            cnt[min(a_, b_), max(a_, b_)] += 1
    ir, ic = np.triu_indices(C, 1); flat = [(G2[a, b], a, b) for a, b in zip(ir, ic)]; flat.sort(reverse=True)
    per_class = (G2 + G2.T).sum(1) / (2 * pt)
    d_ = dict(pair_gain_share=float(pt / tot), top=[dict(classes=[lab[a], lab[b]], share_of_pair_gain=float(v / pt),
                                                         n_pairs=None if cnt is None else int(cnt[a, b])) for v, a, b in flat[:10]],
              per_class_share={lab[c]: float(per_class[c]) for c in range(C)}, top10_share=float(sum(v for v, _, _ in flat[:10]) / pt))
    if cnt is not None:                                                 # gain per drawn pair, relative to the mean pair
        per = [(G2[a, b] / cnt[a, b] / (pt / len(pc)), a, b, int(cnt[a, b])) for a, b in zip(ir, ic) if cnt[a, b] >= 3]; per.sort(reverse=True)
        d_["per_pair_top"] = [dict(classes=[lab[a], lab[b]], gain_per_pair_rel=float(v), n_pairs=c_) for v, a, b, c_ in per[:10]]
        d_["per_pair_bottom"] = [dict(classes=[lab[a], lab[b]], gain_per_pair_rel=float(v), n_pairs=c_) for v, a, b, c_ in per[-5:]]
        gp = M["ggbt_gain_vec"][-len(pc):]; o_ = np.sort(gp)[::-1]
        d_["pair_gain_concentration"] = dict(top10_pairs=float(o_[:10].sum() / gp.sum()), top30_pairs=float(o_[:30].sum() / gp.sum()),
                                             used=int(np.sum(M["ggbt_split_vec"][-len(pc):] > 0)), n=int(len(pc)))
    SUM["pairs"][f"{tag}/{ds}/n{n}"] = d_
    rows7.append([tag, ds, n, f"{pt / tot:.3f}", "; ".join(f"{lab[a]}–{lab[b]} {v / pt:.3f}" + ("" if cnt is None else f" ({int(cnt[a, b])})")
                                                           for v, a, b in flat[:8]),
                  f"{sum(v for v, _, _ in flat[:10]) / pt:.3f}",
                  "–" if cnt is None else "; ".join(f"{x['classes'][0]}–{x['classes'][1]} {x['gain_per_pair_rel']:.2f} ({x['n_pairs']})" for x in d_["per_pair_top"][:6]),
                  "–" if cnt is None else "; ".join(f"{x['classes'][0]}–{x['classes'][1]} {x['gain_per_pair_rel']:.2f} ({x['n_pairs']})" for x in d_["per_pair_bottom"][-3:])])
T7 = md_table(["learner", "dataset", "n", "pairs' share of ggbt gain", "top class pairs: share of the pairs' gain (pairs drawn)",
               "top 10 of 45 class pairs: share", "highest gain per drawn pair, rel. to the mean pair (>= 3 drawn)",
               "lowest gain per drawn pair"], rows7)

# ------------------------------------------------------------------------------- T8: per-class error, v3 vs v2
rows8 = []; SUM["v3_vs_v2"] = {}
for ds in ("qd_dev", "fashion_mnist", "mnist", "qd_a"):
    for n in (1000, 3000, 10000):
        a, b = get("v3", ds, n), get("v2", ds, n)
        if not (a and b):
            continue
        y = a["m"]["test_y"]; assert np.array_equal(y, b["m"]["test_y"])
        p3, p2 = a["m"]["test_pred"], b["m"]["test_pred"]; lab = LAB.get(ds, [str(i) for i in range(10)])
        g3, g2 = a["m"].get("ggbt_test_pred"), b["m"].get("ggbt_test_pred")
        d = dict(err_v3=float(np.mean(p3 != y)), err_v2=float(np.mean(p2 != y)),
                 v3_right_v2_wrong=float(np.mean((p3 == y) & (p2 != y))), v3_wrong_v2_right=float(np.mean((p3 != y) & (p2 == y))),
                 ggbt_same_pred=None if g3 is None or g2 is None else float(np.mean(g3 == g2)),
                 class_err_v3={lab[c]: float(np.mean(p3[y == c] != c)) for c in range(10)},
                 class_err_v2={lab[c]: float(np.mean(p2[y == c] != c)) for c in range(10)})
        if "cgbt_test_pred" in a["m"]:
            cg = a["m"]["cgbt_test_pred"]; gg = a["m"]["ggbt_test_pred"]
            d["class_err_cgbt_alone"] = {lab[c]: float(np.mean(cg[y == c] != c)) for c in range(10)}
            d["class_err_ggbt_alone"] = {lab[c]: float(np.mean(gg[y == c] != c)) for c in range(10)}
            d["cgbt_ggbt_agree"] = float(np.mean(cg == gg))
        SUM["v3_vs_v2"][f"{ds}/n{n}"] = d
        for c in range(10):
            rows8.append([ds, n, lab[c], f"{d['class_err_v2'][lab[c]]:.3f}", f"{d['class_err_v3'][lab[c]]:.3f}",
                          f"{d['class_err_v3'][lab[c]] - d['class_err_v2'][lab[c]]:+.3f}",
                          fmt(d.get("class_err_ggbt_alone", {}).get(lab[c]), 3), fmt(d.get("class_err_cgbt_alone", {}).get(lab[c]), 3)])
        rows8.append([ds, n, "**all**", f"{d['err_v2']:.4f}", f"{d['err_v3']:.4f}", f"{d['err_v3'] - d['err_v2']:+.4f}", "", ""])
T8 = md_table(["dataset", "n", "class", "v2 err", "v3 err", "v3 - v2", "ggbt alone (v3 fit)", "cgbt alone (v3 fit)"], rows8)


# ------------------------------------------------------------------------- T9: contribution maps, quantified
def ink_split(cm, mu_c, mu):
    """Share of the map's positive mass on pixels where the class has more ink than the mean image (by > 0.05), less
    (by > 0.05), or neither; and the same for the negative mass."""
    ex, de = (mu_c - mu) > 0.05, (mu_c - mu) < -0.05; ne = ~(ex | de)
    pos, neg = np.clip(cm, 0, None), np.clip(-cm, 0, None)
    f = lambda v: [float(v[ex].sum() / max(v.sum(), 1e-12)), float(v[de].sum() / max(v.sum(), 1e-12)), float(v[ne].sum() / max(v.sum(), 1e-12))]
    return f(pos), f(neg), float(pos.sum() / max(pos.sum() + neg.sum(), 1e-12))


rows9 = []; SUM["contrib"] = {}
for k in keys:
    tag, ds, n, s = k; M = R[k]["m"]; r = R[k]["j"]
    if n != 10000:
        continue
    mu_c = M["class_mean"]; mu = mu_c.mean(0); lab = LAB.get(ds, [str(i) for i in range(10)])
    for b in sorted(r["boosters"]):
        cm = M[f"{b}_contrib"]; out = {}
        for c in range(len(cm)):
            ps, ns, pf = ink_split(cm[c], mu_c[c], mu)
            out[lab[c]] = dict(pos_on_excess=ps[0], pos_on_deficit=ps[1], neg_on_excess=ns[0], neg_on_deficit=ns[1], pos_frac=pf,
                               corr_with_excess=float(np.corrcoef(cm[c], mu_c[c] - mu)[0, 1]))
            if f"{b}_contrib_inked" in M:                              # net evidence from inked vs blank pixels of the point
                ik = M[f"{b}_contrib_inked"][c]; bl = cm[c] - ik
                out[lab[c]].update(net_inked=float(ik.sum()), net_blank=float(bl.sum()),
                                   pos_from_blank=float(np.clip(bl, 0, None).sum() / max(np.clip(bl, 0, None).sum() + np.clip(ik, 0, None).sum(), 1e-12)))
        cs = r["boosters"][b]["contrib_share"]
        SUM["contrib"][f"{tag}/{ds}/n{n}/{b}"] = dict(per_class=out, share_by_type={t: float(np.mean(v)) for t, v in cs.items()})
        for c in range(len(cm)):
            o = out[lab[c]]
            rows9.append([tag, ds, b, lab[c], f"{o['pos_frac']:.2f}", f"{o['pos_on_excess']:.2f}", f"{o['pos_on_deficit']:.2f}",
                          f"{o['neg_on_excess']:.2f}", f"{o['neg_on_deficit']:.2f}", f"{o['corr_with_excess']:+.2f}",
                          "–" if "net_inked" not in o else f"{o['net_inked']:+.2f} / {o['net_blank']:+.2f}",
                          " ".join(f"{t}:{cs[t][c]:.2f}" for t in cs)])
# the same booster in v2 and v3 (ggbt: same code and generator), and cgbt vs ggbt
for ds in ("qd_dev", "fashion_mnist", "mnist", "qd_a"):
    a, b = get("v3", ds, 10000), get("v2", ds, 10000)
    if a:
        lab = LAB.get(ds, [str(i) for i in range(10)])
        cc = [float(np.corrcoef(a["m"]["cgbt_contrib"][c], a["m"]["ggbt_contrib"][c])[0, 1]) for c in range(10)] if "cgbt_contrib" in a["m"] else None
        SUM.setdefault("contrib_corr", {})[f"{ds}/cgbt_vs_ggbt_v3"] = cc
        if b:
            SUM["contrib_corr"][f"{ds}/ggbt_v3_vs_ggbt_v2"] = [float(np.corrcoef(a["m"]["ggbt_contrib"][c], b["m"]["ggbt_contrib"][c])[0, 1]) for c in range(10)]
T9 = md_table(["learner", "dataset", "booster", "class", "positive share of |contrib|", "pos. on class-excess ink", "pos. on class-deficit",
               "neg. on class-excess", "neg. on class-deficit", "corr(map, class mean - mean)", "net evidence: inked / blank pixels of the point",
               "|contrib| share by feature type"], rows9)

# ================================================================================================== figures
CM_INK = "Greys"


def mesh(ax, Y, pix, true_rc):
    """Isomap embedding aligned to the true grid by Procrustes, drawn as the true lattice: an edge between the embedded
    positions of every pair of truly adjacent pixels (horizontal edges coloured by row, vertical by column)."""
    m1, m2, disp = procrustes(true_rc.astype(float), Y)
    idx = {int(p): i for i, p in enumerate(pix)}; segs, cols = [], []
    for i, p in enumerate(pix):
        p = int(p); r_, c_ = divmod(p, 28)
        for q, t in ((p + 1, r_), (p + 28, c_)):
            if (q in idx) and (q != p + 1 or c_ < 27):
                segs.append([m2[i][::-1] * [1, -1], m2[idx[q]][::-1] * [1, -1]]); cols.append(t / 27)
    lc = LineCollection(segs, colors=plt.cm.viridis(np.array(cols)), linewidths=0.35); ax.add_collection(lc)
    ax.autoscale(); ax.set_aspect("equal"); ax.set_xticks([]); ax.set_yticks([])
    return 1 - disp


def fig_topology():
    picks = [k for k in [("v3", "qd_dev", 1000, 0), ("v3", "qd_dev", 3000, 0), ("v3", "qd_dev", 10000, 0), ("v3", "qd_a", 10000, 0),
                         ("v3", "fashion_mnist", 10000, 0), ("v3", "mnist", 10000, 0)] if k in R]
    if not picks:
        return
    fig = plt.figure(figsize=(7.0, 4.6)); gs = fig.add_gridspec(2, 6, height_ratios=[1.0, 1.15], hspace=0.42, wspace=0.12,
                                                                left=0.07, right=0.99, top=0.9, bottom=0.1)
    for q, k in enumerate(picks):
        M = R[k]["m"]; r = R[k]["j"]; ax = fig.add_subplot(gs[0, q])
        pix = M["isomap_pixels"]; r2 = mesh(ax, M["isomap"], pix, np.stack([pix // 28, pix % 28], 1))
        ax.set_title(f"{DSN[k[1]]}, n = {k[2]}\n$R^2$ = {r['topology']['k9_mutual']['procrustes_r2']:.3f}", fontsize=6.5)
        assert abs(r2 - r["topology"]["k9_mutual"]["procrustes_r2"]) < 1e-3
    fig.text(0.01, 0.97, "(a) Isomap of the k = 9 mutual graph, Procrustes-aligned, drawn as the true pixel lattice", fontsize=7)
    # (b) R^2 by graph variant vs n (qd_dev) and at n = 10000 per dataset
    ax = fig.add_subplot(gs[1, 0:2]); ns = [n for n in (1000, 3000, 10000) if ("v3", "qd_dev", n, 0) in R]
    for v, c in zip(("k4_union", "k9_union", "k9_mutual", "k16_mutual"), ("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728")):
        ax.plot(ns, [R[("v3", "qd_dev", n, 0)]["j"]["topology"][v]["procrustes_r2"] for n in ns], "-o", ms=3, color=c,
                label=v.replace("_", ", "))
        for mk, ds in zip("s^D", ("qd_a", "fashion_mnist", "mnist")):
            if ("v3", ds, 10000, 0) in R:
                ax.plot([10000 * (1.12 + 0.12 * "s^D".index(mk))], [R[("v3", ds, 10000, 0)]["j"]["topology"][v]["procrustes_r2"]], mk,
                        ms=3, color=c, mfc="none")
    ax.set_xscale("log"); ax.set_ylim(-0.05, 1.02); ax.set_xlabel("n (qd_dev); open: n = 10000 on\nqd_a (square), Fashion (triangle), MNIST (diamond)", fontsize=5.5)
    ax.set_ylabel("Procrustes $R^2$"); ax.legend(frameon=False, fontsize=5.5, loc="lower left"); ax.set_title("(b) topology recovery by graph", loc="left")
    # (c) pooling-set geometry: fraction of members within Chebyshev distance 1 and 2
    ax = fig.add_subplot(gs[1, 2:4]); wd = 0.26
    for j, (q, c1, c2) in enumerate(((4, "#08519c", "#9ecae1"), (9, "#a63603", "#fdae6b"), (16, "#006d2c", "#a1d99b"))):
        x = np.arange(len(picks)) + (j - 1) * wd
        w1 = [R[k]["j"]["pooling"][f"k{q}"]["within1"] for k in picks]; w2 = [R[k]["j"]["pooling"][f"k{q}"]["within2"] for k in picks]
        ax.bar(x, w2, wd, color=c2); ax.bar(x, w1, wd, color=c1, label=f"k = {q}")
        ax.plot(x, [R[k]["j"]["pooling"][f"k{q}"]["overlap_nearest"] for k in picks], "k.", ms=2.5)
    ax.set_xticks(np.arange(len(picks))); ax.set_xticklabels([f"{DSN[k[1]]}\n{k[2]}" for k in picks], fontsize=5); ax.set_ylim(0, 1.17)
    ax.set_yticks([0, 0.2, 0.4, 0.6, 0.8, 1.0])
    ax.set_title("(c) members of $S_i(k)$ within 1 (dark) / 2 (light)\nChebyshev steps of $i$; dots: overlap with k nearest", loc="left", fontsize=6)
    ax.legend(frameon=False, fontsize=5, loc="upper center", ncol=3)
    # (d) example pooling sets S_i(16) and bars on the true grid (qd_dev n = 10000)
    k = ("v3", "qd_dev", 10000, 0) if ("v3", "qd_dev", 10000, 0) in R else picks[-1]; M = R[k]["m"]
    ax = fig.add_subplot(gs[1, 4:6]); im = np.zeros((28, 28, 3)) + 1.0
    ex, cen = M["pool_examples"], M["pool_example_centres"]
    colors = plt.cm.tab10(np.arange(len(ex)))
    for e, c, col in zip(ex, cen, colors):
        for p in np.where(e > 0)[0]:
            im[p // 28, p % 28] = 0.55 * im[p // 28, p % 28] + 0.45 * col[:3]
        im[c // 28, c % 28] = 0
    ax.imshow(im); ax.set_xticks([]); ax.set_yticks([])
    ax.set_title(f"(d) six $S_i(16)$ on the true grid\n({DSN[k[1]]}, n = {k[2]}; black = $i$)", loc="left", fontsize=6.5)
    save(fig, "fig_img_topology.pdf")


def draw_bars(ax, PL, idx, w, bg):
    ax.imshow(bg.reshape(28, 28), cmap="Greys", vmin=0, vmax=max(bg.max() * 2.5, 1e-9))
    cmap = plt.cm.plasma
    for rank, t in enumerate(idx):
        px = PL[t][PL[t] >= 0]; P = np.stack([px // 28, px % 28], 1).astype(float)
        u = np.linalg.eigh(np.cov(P.T) + 1e-9 * np.eye(2))[1][:, 1]; o = np.argsort((P - P.mean(0)) @ u); P = P[o]
        col = cmap(0.85 * rank / max(len(idx) - 1, 1))
        ax.plot(P[:, 1], P[:, 0], "-", color=col, lw=1.0, alpha=0.9); ax.plot(P[:, 1], P[:, 0], "s", color=col, ms=1.4, alpha=0.9)
    ax.set_xlim(-0.5, 27.5); ax.set_ylim(27.5, -0.5); ax.set_xticks([]); ax.set_yticks([])


def block(m, f=2):
    """A 784-map summed over f x f blocks of the grid (for the sparse per-bar gain maps)."""
    return m.reshape(28 // f, f, 28 // f, f).sum((1, 3))


def fig_bars():
    picks = [k for k in [("v3", "qd_dev", 10000, 0), ("v3", "fashion_mnist", 10000, 0), ("v3", "mnist", 10000, 0)] if k in R]
    if not picks:
        return
    fig = plt.figure(figsize=(7.0, 1.12 * len(picks) + 2.1))
    gs = fig.add_gridspec(len(picks) + 1, 8, height_ratios=[1] * len(picks) + [1.55], hspace=0.5, wspace=0.08,
                          left=0.075, right=0.99, top=0.95, bottom=0.1)
    nm = {0: "0° (horiz.)", 45: "45° ('/')", 90: "90° (vert.)", 135: "135° ('\\')"}
    for q, k in enumerate(picks):
        M = R[k]["m"]; bg = M["class_mean"].mean(0); pc = M["pool_centres"]; G = R[k]["j"]["boosters"]["cgbt"]["gain"]
        for j, L in enumerate((2, 4)):
            B = BG[(k[0], k[1], k[2], L)]; w = B["w"]; top = np.argsort(-w)[:12]
            ax = fig.add_subplot(gs[q, j]); draw_bars(ax, B["PL"], top, w, bg)
            ax.set_title(f"top 12, L = {L}: {100 * w[top].sum() * G[f'bars{L}']['gain_frac']:.1f}%", fontsize=5.5)
            if j == 0:
                ax.set_ylabel(DSN[k[1]], fontsize=7)
        Wsum = {}
        for L in (2, 4):
            B = BG[(k[0], k[1], k[2], L)]
            for a in (0, 45, 90, 135):
                gm = np.zeros(784); sel = B["an"] == a
                np.add.at(gm, np.repeat(pc, 4)[sel], (B["w"] * G[f"bars{L}"]["gain_frac"])[sel]); Wsum[a] = Wsum.get(a, 0) + gm
        vmax = max(block(v).max() for v in Wsum.values())
        for a_i, a in enumerate((0, 45, 90, 135)):
            ax = fig.add_subplot(gs[q, 2 + a_i]); ax.imshow(block(Wsum[a]), cmap="magma_r", vmin=0, vmax=vmax); ax.set_xticks([]); ax.set_yticks([])
            ax.set_title(f"{nm[a]}: {100 * Wsum[a].sum():.1f}%", fontsize=5.5)
        ax = fig.add_subplot(gs[q, 6]); gb = M["cgbt_gain_bars2"] + M["cgbt_gain_bars4"]
        ax.imshow(gb.reshape(28, 28), cmap="magma_r"); ax.set_xticks([]); ax.set_yticks([])
        ax.set_title(f"all bars: {100 * (G['bars2']['gain_frac'] + G['bars4']['gain_frac']):.0f}%", fontsize=5.5)
        ax = fig.add_subplot(gs[q, 7]); gp = M["cgbt_gain_pool4"] + M["cgbt_gain_pool9"] + M["cgbt_gain_pool16"]
        ax.imshow(gp.reshape(28, 28), cmap="magma_r"); ax.set_xticks([]); ax.set_yticks([])
        ax.set_title(f"pooled sums: {100 * sum(G[f'pool{x}']['gain_frac'] for x in (4, 9, 16)):.0f}%", fontsize=5.5)
    # bottom row: (a) geometry of all bars vs gain-weighted (qd_dev n = 10000); (b) geometry vs n and dataset; (c) orientation
    gb_ = gs[-1, :].subgridspec(1, 3, width_ratios=[1.25, 0.9, 1.25], wspace=0.32)
    ax = fig.add_subplot(gb_[0, 0]); k = picks[0]; width = 0.2
    cats = ["straight", "contiguous", "elong. ≥ 0.9", "≤ 1 px off line"]
    for j, (L, c) in enumerate(((2, "#1f77b4"), (4, "#d62728"))):
        B = BG[(k[0], k[1], k[2], L)]; w = B["w"]
        allv = [np.mean(B["st"] > 0), np.mean(B["co"]), np.mean(B["el"] >= 0.9), np.mean(B["dv"] <= 1)]
        gw = [w @ (B["st"] > 0), w @ B["co"], w @ (B["el"] >= 0.9), w @ (B["dv"] <= 1)]
        x = np.arange(4) + (2 * j - 1.5) * width
        ax.bar(x, allv, width, color=c, alpha=0.4, label=f"L = {L}, all bars"); ax.bar(x + width, gw, width, color=c, label=f"L = {L}, gain-weighted")
    ax.set_xticks(np.arange(4)); ax.set_xticklabels(cats, fontsize=5.5); ax.set_ylim(0, 1.18); ax.legend(frameon=False, fontsize=5, ncol=2, loc="upper left")
    ax.set_title(f"(a) bar geometry on the true grid ({DSN[k[1]]}, n = {k[2]})", loc="left", fontsize=6.5)
    ax = fig.add_subplot(gb_[0, 1]); ns = [n for n in (1000, 3000, 10000) if (("v3", "qd_dev", n, 2)) in BG]
    for L, c in ((2, "#1f77b4"), (4, "#d62728")):
        ax.plot(ns, [np.mean(BG[("v3", "qd_dev", n, L)]["st"] > 0) for n in ns], "-o", ms=2.5, color=c, label=f"straight, L={L}")
        ax.plot(ns, [np.mean(BG[("v3", "qd_dev", n, L)]["dv"] <= 1) for n in ns], "--s", ms=2.5, color=c, label=f"≤ 1 px off, L={L}")
        for mk, ds, off in (("^", "fashion_mnist", 1.25), ("D", "mnist", 1.5), ("v", "qd_a", 1.12)):
            if ("v3", ds, 10000, L) in BG:
                Bd = BG[("v3", ds, 10000, L)]
                ax.plot([10000 * off], [np.mean(Bd["st"] > 0)], mk, ms=3, color=c, mfc="none")
                ax.plot([10000 * off], [np.mean(Bd["dv"] <= 1)], mk, ms=3, color=c)
    ax.set_xscale("log"); ax.set_xlabel("n (qd_dev); right: n = 10000 on qd_a (v),\nFashion (^), MNIST (D)", fontsize=5.5)
    ax.set_ylim(0, 1.32); ax.set_yticks([0, 0.2, 0.4, 0.6, 0.8, 1.0]); ax.legend(frameon=False, fontsize=4.6, loc="upper center", ncol=2)
    ax.set_title("(b) vs n and dataset (L=2 blue, L=4 red)", loc="left", fontsize=6.5)
    ax = fig.add_subplot(gb_[0, 2]); x = np.arange(4); width = 0.8 / (2 * len(picks))
    for q, k in enumerate(picks):
        for j, L in enumerate((2, 4)):
            B = BG[(k[0], k[1], k[2], L)]; xx = x + (2 * q + j) * width - 0.4 + width / 2
            ax.bar(xx, [B["w"] @ (B["an"] == a) for a in (0, 45, 90, 135)], width, color=plt.cm.tab10(q), alpha=0.45 + 0.55 * j,
                   label=f"{DSN[k[1]]} L={L}")
            ax.plot(xx, [np.mean(B["an"] == a) for a in (0, 45, 90, 135)], "k_", ms=3.5)
    ax.set_xticks(x); ax.set_xticklabels([nm[a] for a in (0, 45, 90, 135)], fontsize=5.5)
    ax.set_ylabel("share of the bars' gain", fontsize=6); ax.legend(frameon=False, fontsize=4.8, ncol=3, loc="upper right"); ax.set_ylim(0, 0.55)
    ax.set_title("(c) orientation: gain share (ticks: all bars)", loc="left", fontsize=6.5)
    save(fig, "fig_img_bars.pdf")


def fig_gain():
    rows_ = [(k, b) for k in keys for b in ("ggbt", "cgbt") if b in R[k]["j"]["boosters"]]
    if not rows_:
        return
    fig, ax = plt.subplots(figsize=(7.0, 2.6)); cols = dict(raw="#7f7f7f", pool4="#c6dbef", pool9="#6baed6", pool16="#2171b5",
                                                             bars2="#fdae6b", bars4="#e6550d", pairs="#31a354")
    for i, (k, b) in enumerate(rows_):
        G = R[k]["j"]["boosters"][b]["gain"]; left = 0
        for t in TYPES:
            v = G.get(t, {}).get("gain_frac", 0)
            ax.barh(i, v, left=left, color=cols[t], label=t if i == [j for j, (kk, bb) in enumerate(rows_) if t in R[kk]["j"]["boosters"][bb]["gain"]][0] else None)
            if v > 0.06:
                ax.text(left + v / 2, i, f"{v:.2f}", ha="center", va="center", fontsize=5, color="white" if t in ("pool16", "bars4", "pairs", "raw") else "black")
            left += v
    ax.set_yticks(range(len(rows_))); ax.set_yticklabels([f"{k[0]} {DSN[k[1]]} n={k[2]}: {b}" for k, b in rows_], fontsize=5.5)
    ax.invert_yaxis(); ax.set_xlim(0, 1); ax.set_xlabel("share of the final booster's split gain")
    h, l = ax.get_legend_handles_labels(); nm = dict(raw="pixels", pool4="pooled k=4", pool9="pooled k=9", pool16="pooled k=16",
                                                      bars2="bars L=2", bars4="bars L=4", pairs="prototype pairs")
    ax.legend(h, [nm[x] for x in l], frameon=False, fontsize=5.5, ncol=7, loc="lower center", bbox_to_anchor=(0.45, 1.0))
    fig.tight_layout(); save(fig, "fig_img_gain.pdf")


def fig_stack():
    picks = [k for k in keys]
    if not picks:
        return
    fig = plt.figure(figsize=(7.0, 3.2)); gs = fig.add_gridspec(1, 2, width_ratios=[1.35, 1], wspace=0.3, left=0.16, right=0.99, top=0.86, bottom=0.13)
    ax = fig.add_subplot(gs[0, 0])
    grp = [("cgbt", ["cgbt"], "#e6550d"), ("ggbt", ["ggbt"], "#2171b5"), ("gknn", ["gknn_1", "gknn_3", "gknn_9", "gknn_27"], "#6baed6"),
           ("kNN (Part 8)", [m for m in MEMS if m.startswith("knn")], "#bcbddc"), ("gbt / et (Part 8)", ["gbt", "et"], "#74c476"),
           ("lin (Part 8)", ["lin_0.05", "lin_1.0"], "#bdbdbd")]
    for i, k in enumerate(picks):
        W = R[k]["j"]["weights"] or {}; left = 0; tot = sum(W.values())
        for nm, ms, c in grp:
            v = sum(W.get(m, 0) for m in ms)
            ax.barh(i, v, left=left, color=c, label=nm if i == 0 else None)
            if v > 0.06:
                ax.text(left + v / 2, i, f"{v:.2f}", ha="center", va="center", fontsize=5)
            left += v
    ax.set_yticks(range(len(picks))); ax.set_yticklabels([f"{k[0]} {DSN[k[1]]} n={k[2]}" for k in picks], fontsize=5.5); ax.invert_yaxis()
    ax.set_xlabel("stacker weight (sum over the family's members)"); ax.legend(frameon=False, fontsize=5, ncol=3, loc="lower center", bbox_to_anchor=(0.5, 1.0))
    ax = fig.add_subplot(gs[0, 1]); ns = [n for n in (1000, 3000, 10000) if ("v3", "qd_dev", n, 0) in R]
    for m, c, ls in (("cgbt", "#e6550d", "-"), ("ggbt", "#2171b5", "-"), ("gknn_3", "#6baed6", "--"), ("gknn_9", "#6baed6", ":"),
                     ("knn_std_1", "#9e9ac8", "--"), ("gbt", "#31a354", "-"), ("et", "#74c476", "--"), ("lin_1.0", "#969696", "-")):
        v = [R[("v3", "qd_dev", n, 0)]["j"]["member_oof_err"].get(m, np.nan) for n in ns]
        ax.plot(ns, v, ls, marker="o", ms=2.5, color=c, label=m)
    ax.plot(ns, [R[("v3", "qd_dev", n, 0)]["j"]["err"] for n in ns], "k-", lw=1.4, marker="s", ms=3, label="v3 (test)")
    if ("v2", "qd_dev", 10000, 0) in R:
        ax.plot([10000], [R[("v2", "qd_dev", 10000, 0)]["j"]["err"]], "kx", ms=4, label="v2 (test)")
    ax.set_xscale("log"); ax.set_xlabel("n (qd_dev)"); ax.set_ylabel("out-of-fold error (members); test error (v3, v2)")
    ax.set_ylim(0.06, 0.42); ax.legend(frameon=False, fontsize=5, ncol=3, loc="lower left"); ax.set_title("members' out-of-fold errors, qd_dev", loc="left")
    save(fig, "fig_img_stack.pdf")


def fig_contrib(ds, name):
    """Rows: class mean; cgbt; ggbt (v2's run if present: the same booster, see T8); cgbt's bars only; cgbt on the
    pixels blank in the point; ggbt's pooled sums only; ggbt's pairs only.  Each map scaled to its own max |value|."""
    k3, k2 = ("v3", ds, 10000, 0), ("v2", ds, 10000, 0)
    if k3 not in R:
        return
    kg = k2 if k2 in R else k3; M3, Mg = R[k3]["m"], R[kg]["m"]
    rows_ = [("class mean\n(training)", lambda c: Mu[c], "ink"),
             ("v3 cgbt", lambda c: M3["cgbt_contrib"][c], "c"),
             (f"ggbt ({kg[0]} run)", lambda c: Mg["ggbt_contrib"][c], "c"),
             ("cgbt:\nbars only", lambda c: M3["cgbt_contrib_bars2"][c] + M3["cgbt_contrib_bars4"][c], "c")]
    if "cgbt_contrib_inked" in M3:
        rows_.append(("cgbt: on pixels\nblank in the image", lambda c: M3["cgbt_contrib"][c] - M3["cgbt_contrib_inked"][c], "c"))
    rows_ += [("ggbt: pooled\nsums only", lambda c: Mg["ggbt_contrib_pool4"][c] + Mg["ggbt_contrib_pool9"][c] + Mg["ggbt_contrib_pool16"][c], "c"),
              ("ggbt: pairs only", lambda c: Mg["ggbt_contrib_pairs"][c], "c")]
    lab = LAB.get(ds, [str(i) for i in range(10)]); Mu = M3["class_mean"]
    fig, axs = plt.subplots(len(rows_), 10, figsize=(7.0, 0.72 * len(rows_) + 0.2))
    for i, (nm, f, kind) in enumerate(rows_):
        for c in range(10):
            a = axs[i, c]; v = f(c)
            if kind == "ink":
                a.imshow(v.reshape(28, 28), cmap=CM_INK); a.set_title(lab[c][:13], fontsize=5.5)
            else:
                s_ = np.abs(v).max() or 1; a.imshow(v.reshape(28, 28), cmap="RdBu_r", vmin=-s_, vmax=s_)
            a.set_xticks([]); a.set_yticks([])
        axs[i, 0].set_ylabel(nm, fontsize=5.2, rotation=0, ha="right", va="center")
    fig.subplots_adjust(left=0.135, right=0.995, top=0.955, bottom=0.005, wspace=0.04, hspace=0.06)
    save(fig, name)


def fig_pairs():
    picks = [k for k in [("v3", "qd_dev", 10000, 0), ("v3", "fashion_mnist", 10000, 0), ("v3", "mnist", 10000, 0)] if k in R and "ggbt_pair_class_gain" in R[k]["m"]]
    if not picks:
        return
    fig, axs = plt.subplots(1, len(picks), figsize=(7.0, 2.6))
    axs = np.atleast_1d(axs)
    for ax, k in zip(axs, picks):
        G2 = R[k]["m"]["ggbt_pair_class_gain"]; G = (G2 + G2.T) / G2.sum(); lab = LAB.get(k[1], [str(i) for i in range(10)])
        im = ax.imshow(G, cmap="viridis"); ax.set_xticks(range(10)); ax.set_yticks(range(10))
        ax.set_xticklabels([l[:9] for l in lab], rotation=90, fontsize=5); ax.set_yticklabels([l[:9] for l in lab], fontsize=5)
        ax.set_title(f"{DSN[k[1]]} n = {k[2]}: ggbt pair gain by class pair\n(pairs: {100 * R[k]['j']['boosters']['ggbt']['gain']['pairs']['gain_frac']:.0f}% of ggbt's gain)", fontsize=6)
        fig.colorbar(im, ax=ax, fraction=0.046, pad=0.02).ax.tick_params(labelsize=5)
    fig.tight_layout(); save(fig, "fig_img_pairs.pdf")


fig_topology(); fig_bars(); fig_gain(); fig_stack(); fig_pairs()
fig_contrib("qd_dev", "fig_img_contrib_qd_dev.pdf"); fig_contrib("fashion_mnist", "fig_img_contrib_fashion.pdf")
fig_contrib("mnist", "fig_img_contrib_mnist.pdf"); fig_contrib("qd_a", "fig_img_contrib_qd_a.pdf")

# ================================================================================================== write tables
src = "Source files: " + ", ".join(sorted({rel(R[k]["path"]) for k in keys})) + " (and the .npz next to each).\n\n"
open(os.path.join(TAB, "img_runs.md"), "w").write("# Image analysis runs: test error vs the evaluation cell\n\n" + src + T1)
open(os.path.join(TAB, "img_pooling.md"), "w").write("# Pooling sets S_i(k) on the true grid\n\n" + src + T2)
open(os.path.join(TAB, "img_topology.md"), "w").write("# Isomap Procrustes R^2 of the pooling-set graphs (nodes in the largest component)\n\n" + src + T3)
open(os.path.join(TAB, "img_bars.md"), "w").write("# Bars on the true grid (v3); gain-weighted = weighted by cgbt's split gain\n\n"
                                                  "Orientation 45 = '/' (row decreases as column increases), 135 = '\\\\'.\n\n" + src + T4 + "\n" + T4b)
open(os.path.join(TAB, "img_stack.md"), "w").write("# Stacker weight / out-of-fold error per member\n\n" + src + T5)
open(os.path.join(TAB, "img_gain.md"), "w").write("# Split gain by feature type in the final boosters\n\n" + src + T6)
open(os.path.join(TAB, "img_pairs.md"), "w").write("# ggbt's prototype pairs: gain by class pair\n\n" + src + T7)
open(os.path.join(TAB, "img_class_err.md"), "w").write("# Per-class test error, v3 vs v2 (same test points)\n\n" + src + T8)
open(os.path.join(TAB, "img_contrib.md"), "w").write("# Contribution maps, quantified (n = 10000)\n\n"
                                                     "class-excess ink: pixels where the class mean image exceeds the mean of the 10 class means by > 0.05; "
                                                     "class-deficit: below it by > 0.05.\n\n" + src + T9)
SUM["files"] = {f"{k[0]}/{k[1]}/n{k[2]}": rel(R[k]["path"]) for k in keys}
json.dump(SUM, open(os.path.join(TAB, "img_summary.json"), "w"), indent=1)
for k in keys:                                                            # copies of the analysis files
    d = os.path.join(RES, k[0]); os.makedirs(d, exist_ok=True); shutil.copy(R[k]["path"], d)
    if os.path.getsize(R[k]["npz"]) < 5e6:
        shutil.copy(R[k]["npz"], d)
print("figures:", sorted(os.listdir(FIG))); print("tables:", sorted(os.listdir(TAB)))

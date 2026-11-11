"""What do the learner's image members encode?  (Descriptive analysis.)  One fit of part9/eval_cells.py (dataset, n,
seed) is reproduced (hooks.fit_image) and summarised; the learner never sees the pixel layout, the analysis maps its
objects back onto the 28 x 28 grid (hooks.grid_of).
  pooling      S_i(k), the k columns most correlated with column i: distance of the members from the centre pixel on the
               true grid (Chebyshev), the fraction within distance 1 / 2, and the overlap with the k truly nearest pixels
  topology     Isomap of the graph that joins column i to the members of S_i(k) (union: j in S_i(k) or i in S_j(k); mutual:
               both), on its largest connected part: shortest-path distances, classical MDS to 2-D, Procrustes fit to the
               true pixel coordinates (r2 = 1 - Procrustes disparity); variants (k, graph) = (4, union), (9, union),
               (9, mutual), (16, mutual), all reported
  gain         the final ggbt booster's split gain by feature type (raw pixels, pooled sums at each k, prototype pairs,
               level-2 max-pooled maps) and its maps on the grid (a pooled or max-pooled feature at its centre pixel; a
               pair spread over pixels by |u_p|)
  contrib      per-class contribution maps (LightGBM pred_contrib on test points of the class, for that class's score;
               a pooled sum's contribution spread equally over its k pixels; a pair's over pixels by |u_p x_p|; a
               max-pooled feature's over the k pixels of the neighbour j* whose sum attains the max, per point)
  pairs        the classes of the prototype pairs, gain by class pair
  bars         (v3) the oriented bars along correlation-recovered lines, checked on the true grid: the fraction that
               are straight lattice lines through their centre, their orientations, contiguity; the most-used bars
  boosters     every final booster (v2: ggbt; v3: ggbt and cgbt) analysed separately
  stack        the stacker's weights and the members' out-of-fold errors
  also saved (npz): per-feature gain / split vectors of each booster, its test predictions alone and the learner's,
               per-type contribution maps (<booster>_contrib_<type>) and the part on inked pixels (x > 0.1), the pooling
               sets and bars as pixel lists with per-bar elongation and deviation; (json) per-class test error, the
               confusion matrix, the stacker's out-of-fold error, CPU per member, rows each booster was fitted on
usage: python image_structure.py <dataset> <n> [--seed=0] [--learner=path] [--tag=v2] [--m_contrib=1000]
writes results/image/<tag>/<dataset>__n<n>__s<seed>.json and .npz (maps, embedding)"""
import os, sys, json, time, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import hooks as H

ds, n = sys.argv[1], int(sys.argv[2])
opt = {a.split("=", 1)[0][2:]: a.split("=", 1)[1] for a in sys.argv[3:] if a.startswith("--") and "=" in a}
seed = int(opt.get("seed", 0)); tag = opt.get("tag", "v2"); path = opt.get("learner", H.V2); mc = int(opt.get("m_contrib", 1000))
out_dir = os.path.join(os.environ.get("INTERP_OUT", os.path.join(HERE, "results")), "image", tag); os.makedirs(out_dir, exist_ok=True)
base = os.path.join(out_dir, f"{ds}__n{n}__s{seed}")

HP = H.load_learner(path); t0 = time.process_time()
r = H.fit_image(HP, ds, n, seed); D = r["D"]; R = r["rec"]; d = D["X"].shape[1]
g = H.grid_of(ds, d); rc = np.stack([g // 28, g % 28], 1)                  # column j -> (row, col) of its pixel
out = dict(dataset=ds, n=n, seed=seed, learner=path, err=r["err"], fit_cpu=round(time.process_time() - t0, 1),
           weights=r["info"].get("weights"), member_oof_err=r["info"].get("member_oof_err"),
           ggbt_rounds=r["info"].get("ggbt_rounds"), cgbt_rounds=r["info"].get("cgbt_rounds"),
           stack_oof_err=r["info"].get("stack_oof_err"), member_cpu=r["info"].get("times"), ggbt_bank=r["info"].get("ggbt_bank"))
maps = {}
_yte = D["y"][r["te"]]; maps["test_pred"] = r["pred"].astype(np.int16); maps["test_y"] = _yte.astype(np.int16)
out["class_err"] = [round(float(np.mean(r["pred"][_yte == c] != c)), 4) for c in range(D["C"])]
out["confusion"] = np.bincount(_yte * D["C"] + r["pred"], minlength=D["C"] ** 2).reshape(D["C"], D["C"]).tolist()

# ---- pooling sets (the call on the training rows; every fit computes them once)
As = R.pool[-1]; ks = sorted(As)
Xs = np.asarray(D["X"][r["tr"][:20000]], np.float64); act = np.where(Xs.std(0) > 1e-6)[0]   # as pool_sets: active columns
assert As[ks[0]].shape[1] == len(act) and all(As[k][act[c], c] == 1 for k in ks for c in range(0, len(act), 37))
out["pooling"] = dict(n_active=int(len(act)), ks=ks)
for k in ks:
    M = As[k] > 0; dist, near_ov = [], []
    for c, i in enumerate(act):
        mem = np.where(M[:, c])[0]
        dd = np.max(np.abs(rc[mem] - rc[i]), 1); dist.append(dd)
        true_near = np.argsort(np.max(np.abs(rc[act] - rc[i]), 1) + 1e-3 * np.hypot(*(rc[act] - rc[i]).T), kind="stable")[:k]
        near_ov.append(len(set(act[true_near]) & set(mem)) / k)
    dist = np.concatenate(dist)
    out["pooling"][f"k{k}"] = dict(mean_dist=round(float(dist.mean()), 3), within1=round(float(np.mean(dist <= 1)), 4),
                                    within2=round(float(np.mean(dist <= 2)), 4), max_dist=int(dist.max()),
                                    p95_dist=float(np.percentile(dist, 95)), overlap_nearest=round(float(np.mean(near_ov)), 4))
# example sets on the grid: 6 centres spread over the active region
ex = act[np.linspace(0, len(act) - 1, 6).astype(int)] if len(act) else []
maps["pool_examples"] = np.stack([np.isin(np.arange(784), g[np.where(As[max(ks)][:, list(act).index(i)] > 0)[0]]).astype(np.int8)
                                  for i in ex]) if len(ex) else np.zeros((0, 784), np.int8)
maps["pool_example_centres"] = g[ex] if len(ex) else np.zeros(0, int)
maps["pool_centres"] = g[act].astype(np.int16)
for k in ks:                                                              # S_i(k) as grid pixels, one row per active i
    maps[f"pool{k}_members"] = np.stack([g[np.where(As[k][:, c] > 0)[0]][:k] for c in range(len(act))]).astype(np.int16)

# ---- topology: Isomap of the pooling-set graph (every variant reported; the embedding of k = 9, mutual is saved)
from scipy.sparse import csr_matrix
from scipy.sparse.csgraph import shortest_path, connected_components
from scipy.spatial import procrustes
pos = {int(i): c for c, i in enumerate(act)}
out["topology"] = {}
for kk, mode in ((4, "union"), (9, "union"), (9, "mutual"), (16, "mutual")):
    if kk not in ks:
        continue
    M = As[kk] > 0; nb = [set(pos[int(j)] for j in np.where(M[:, c])[0] if int(j) in pos) - {c} for c in range(len(act))]
    rows, cols = [], []
    for c in range(len(act)):
        for j in nb[c]:
            if mode == "union" or c in nb[j]:                         # union: j in S_i or i in S_j; mutual: both
                rows += [c, j]; cols += [j, c]
    Gm = csr_matrix((np.ones(len(rows)), (rows, cols)), shape=(len(act), len(act)))
    _, lab = connected_components(Gm, directed=False); comp = np.where(lab == np.bincount(lab).argmax())[0]
    SP = shortest_path(Gm[comp][:, comp], directed=False, unweighted=True)
    J = np.eye(len(comp)) - 1.0 / len(comp); Bm = -0.5 * J @ (SP ** 2) @ J
    ev, V = np.linalg.eigh(Bm); Y = V[:, -2:] * np.sqrt(np.maximum(ev[-2:], 0))
    _, _, disp = procrustes(rc[act[comp]].astype(float), Y)
    out["topology"][f"k{kk}_{mode}"] = dict(nodes=int(len(comp)), of_active=int(len(act)), procrustes_r2=round(float(1 - disp), 4),
                                            graph_edges=int(Gm.nnz // 2))
    if (kk, mode) == (9, "mutual"):
        maps["isomap"] = Y; maps["isomap_pixels"] = g[act[comp]]

# ---- bars (v3 / p10_codes): the oriented subset sums along correlation-recovered lines, checked on the true grid
if R.bars:
    out["bars"] = {}
    for L, Bm in sorted(R.bars.items()):
        st = dict(n=int(Bm.shape[1]), straight=0, orient={"horizontal": 0, "vertical": 0, "diagonal": 0, "antidiagonal": 0},
                  contiguous=0, length=[])
        for c in range(Bm.shape[1]):
            px = g[np.where(Bm[:, c] > 0)[0]]; rr, cc = px // 28, px % 28; st["length"].append(len(px))
            o = ("horizontal" if np.all(rr == rr[0]) else "vertical" if np.all(cc == cc[0]) else
                 "diagonal" if np.all(rr - cc == rr[0] - cc[0]) else "antidiagonal" if np.all(rr + cc == rr[0] + cc[0]) else None)
            if o:
                st["straight"] += 1; st["orient"][o] += 1
                key = cc if o == "horizontal" else rr
                if np.all(np.diff(np.sort(key)) == 1):
                    st["contiguous"] += 1
        # softer geometry: principal axis of the bar's pixel coordinates (elongation = top eigenvalue share, 1 = a line,
        # 0.5 = isotropic), its orientation (nearest of 0 / 45 / 90 / 135 degrees) and the pixels' largest distance from it
        el, dev, ang = [], [], {0: 0, 45: 0, 90: 0, 135: 0}
        for c in range(Bm.shape[1]):
            px = g[np.where(Bm[:, c] > 0)[0]]; P = np.stack([px // 28, px % 28], 1).astype(float); P -= P.mean(0)
            ev, V = np.linalg.eigh(P.T @ P / len(P)); el.append(ev[1] / max(ev.sum(), 1e-12))
            u = V[:, 1]; dev.append(float(np.max(np.abs(P @ np.array([-u[1], u[0]])))))
            a_ = (np.degrees(np.arctan2(-u[0], u[1])) % 180); ang[int(45 * round(a_ / 45)) % 180] += 1
        el, dev = np.array(el), np.array(dev)
        maps[f"bars{L}_elong"] = el.astype(np.float32); maps[f"bars{L}_dev"] = dev.astype(np.float32)
        mx = int(Bm.sum(0).max()); PL = -np.ones((Bm.shape[1], mx), np.int16)
        for c in range(Bm.shape[1]):
            px = g[np.where(Bm[:, c] > 0)[0]]; PL[c, :len(px)] = px
        maps[f"bars{L}_pixels"] = PL
        st.update(elong_median=round(float(np.median(el)), 3), elong_ge_0_9=round(float(np.mean(el >= 0.9)), 4),
                  max_perp_dev_median=round(float(np.median(dev)), 3), within_1px_of_line=round(float(np.mean(dev <= 1.0)), 4),
                  principal_orient=ang)
        st["straight_frac"] = round(st["straight"] / st["n"], 4); st["contiguous_frac"] = round(st["contiguous"] / st["n"], 4)
        st["mean_length"] = round(float(np.mean(st.pop("length"))), 2)
        out["bars"][f"L{L}"] = st
    Lb = max(R.bars); Bm = R.bars[Lb]; ex = np.linspace(0, Bm.shape[1] - 1, 12).astype(int)
    maps["bar_examples"] = np.stack([np.isin(np.arange(784), g[np.where(Bm[:, c] > 0)[0]]).astype(np.int8) for c in ex])


def analyse_booster(gg, name):
    """Gain and per-class contributions of one final booster; its bank = [x, the bank matrix's columns (pooled sums at
    each k; bars of each L), prototype pairs, level-2 maps]."""
    bst, best, U, feat, l2, Sa, bank = gg["bst"], gg["best"], gg["U"], gg["feat"], gg.get("l2", ()), gg.get("Sa"), gg.get("bank")
    na = len(act); blocks = [("raw", 0, d)] + [(f"pool{k}", d + q * na, d + (q + 1) * na) for q, k in enumerate(ks)]
    lo = d + len(ks) * na
    nb_bank = bank.shape[1] if bank is not None else len(ks) * na
    for L in sorted(R.bars):                                          # bars follow the pooled sums in the bank (v3: cgbt)
        if lo + 4 * na <= d + nb_bank:
            blocks.append((f"bars{L}", lo, lo + 4 * na)); lo += 4 * na
    cols = {b_: (lo_, hi_) for b_, lo_, hi_ in blocks}
    lo_pairs = d + nb_bank
    if len(U):
        blocks.append(("pairs", lo_pairs, lo_pairs + len(U)))
    lo_l2 = lo_pairs + len(U)
    for q, (op, k, K) in enumerate(l2):
        blocks.append((f"{op}{k}_{K}", lo_l2 + q * na, lo_l2 + (q + 1) * na))
    gain = bst.feature_importance("gain", iteration=best); splits = bst.feature_importance("split", iteration=best)
    assert len(gain) == blocks[-1][2], (name, len(gain), blocks)
    tot = gain.sum(); res = {}
    res["bank"] = [dict(name=b_, start=lo_, stop=hi_) for b_, lo_, hi_ in blocks]
    res["rounds"] = int(best) if best else None
    res["n_fit"] = int(gg["n"]); res["refit_on_all_n"] = bool(gg["n"] == n)     # False: the stacker dropped it (last out-of-fold fit)
    maps[f"{name}_gain_vec"] = gain.astype(np.float32); maps[f"{name}_split_vec"] = splits.astype(np.int32)
    Pt = gg["model"].proba(D["X"][r["te"]]); res["test_err_alone"] = round(float(np.mean(np.argmax(Pt, 1) != D["y"][r["te"]])), 4)
    maps[f"{name}_test_pred"] = np.argmax(Pt, 1).astype(np.int16); del Pt
    res["gain"] = {b_: dict(gain_frac=round(float(gain[lo_:hi_].sum() / tot), 4), split_frac=round(float(splits[lo_:hi_].sum() / splits.sum()), 4),
                            n_used=int(np.sum(splits[lo_:hi_] > 0)), n=int(hi_ - lo_)) for b_, lo_, hi_ in blocks}
    # column -> pixel membership (full column indices) for every bank feature that is a subset sum
    member = {}
    for q, k in enumerate(ks):
        member[f"pool{k}"] = (As[k] > 0)
    for L in sorted(R.bars):
        if f"bars{L}" in cols:
            member[f"bars{L}"] = (R.bars[L] > 0)
    for b_, lo_, hi_ in blocks:                                         # gain maps: spread over the feature's pixels
        gm = np.zeros(784)
        if b_ == "raw":
            gm[g] = gain[lo_:hi_]
        elif b_ == "pairs":
            Ua = np.abs(U); Ua = Ua / np.maximum(Ua.sum(1, keepdims=True), 1e-12); np.add.at(gm, g, Ua.T @ gain[lo_:hi_])
        elif b_ in member:
            M = member[b_].astype(float); M = M / np.maximum(M.sum(0, keepdims=True), 1); np.add.at(gm, g, M @ gain[lo_:hi_])
        else:
            np.add.at(gm, g[act], gain[lo_:hi_])
        maps[f"{name}_gain_{b_}"] = gm
    if len(U):                                                          # the pairs: classes and gain
        pc = gg["pair_cls"]; pg = gain[lo_pairs:lo_pairs + len(U)]; C = D["C"]; G2 = np.zeros((C, C))
        for (a_, b2), v in zip(pc, pg):
            G2[min(a_, b2), max(a_, b2)] += v
        maps[f"{name}_pair_class_gain"] = G2; maps[f"{name}_pair_cls"] = np.asarray(pc, np.int16)
        top = np.argsort(-pg)[:12]; maps[f"{name}_pair_top_dirs"] = np.stack([np.bincount(g, weights=U[i], minlength=784) for i in top])
        res["pairs"] = dict(n=int(len(U)), top=[dict(classes=[int(c) for c in pc[i]], gain_frac=round(float(pg[i] / tot), 5)) for i in top],
                            gain_frac_top12=round(float(pg[top].sum() / tot), 4))
    if "bars2" in cols or "bars4" in cols:                              # the most-used bars, drawn on the true grid
        bb = [b_ for b_ in ("bars4", "bars2") if b_ in cols][0]; lo_, hi_ = cols[bb]
        top = np.argsort(-gain[lo_:hi_])[:12]
        maps[f"{name}_top_bars"] = np.stack([np.isin(np.arange(784), g[np.where(member[bb][:, t])[0]]).astype(np.int8) for t in top])
        res["top_bars_gain_frac"] = round(float(gain[lo_:hi_][top].sum() / tot), 4)
        for bb in ("bars2", "bars4"):                                    # top 24 of each length, with their indices
            if bb in cols:
                lo_, hi_ = cols[bb]; top = np.argsort(-gain[lo_:hi_])[:24]; maps[f"{name}_top_{bb}_idx"] = top
                maps[f"{name}_top_{bb}"] = np.stack([np.isin(np.arange(784), g[np.where(member[bb][:, t])[0]]).astype(np.int8) for t in top])
    # per-class contribution maps (pred_contrib on m test points per class, for the true class's score)
    C = D["C"]; te = r["te"]; yte = D["y"][te]; rng = np.random.default_rng(1); m_c = max(1, mc // C)
    sel = np.concatenate([rng.choice(np.where(yte == c)[0], size=min(m_c, int(np.sum(yte == c))), replace=False) for c in range(C)])
    Xq = D["X"][te[sel]]; Fq = feat(Xq); CT = bst.predict(Fq, num_iteration=best, pred_contrib=True)
    nf = Fq.shape[1]; CT = CT.reshape(len(sel), C, nf + 1)
    cmaps = np.zeros((C, 784)); share = np.zeros((C, len(blocks))); bmaps = np.zeros((len(blocks), C, 784))
    imaps = np.zeros((C, 784))                                          # the part of the map on pixels inked in the point
    for c in range(C):
        idx = np.where(yte[sel] == c)[0]; ct = CT[idx, c, :nf]
        pix = np.zeros((len(idx), d)); pix += ct[:, :d]; bmaps[0, c, g] = ct[:, :d].mean(0)
        for bi, (b_, lo_, hi_) in enumerate(blocks):
            pb = None
            if b_ in member:                                           # a subset sum: spread equally over its pixels
                M = member[b_].astype(float); M = M / np.maximum(M.sum(0, keepdims=True), 1); pb = ct[:, lo_:hi_] @ M.T
            elif b_ == "pairs":
                ux = np.abs(Xq[idx][:, None, :] * U[None, :, :]); ux = ux / np.maximum(ux.sum(2, keepdims=True), 1e-12)
                pb = np.einsum("ip,ipj->ij", ct[:, lo_:hi_], ux)
            if pb is not None:
                pix += pb; bmaps[bi, c, g] = pb.mean(0)
        cm = np.zeros((len(idx), 784)); cm[:, g] = pix; cmaps[c] = cm.mean(0)
        imaps[c, g] = (pix * (Xq[idx] > 0.1)).mean(0)
        for bi, (_, lo_, hi_) in enumerate(blocks):
            share[c, bi] = np.abs(ct[:, lo_:hi_]).sum(1).mean()
    maps[f"{name}_contrib"] = cmaps; maps[f"{name}_contrib_inked"] = imaps
    for bi, (b_, _, _) in enumerate(blocks):                            # the same maps, one feature type at a time
        maps[f"{name}_contrib_{b_}"] = bmaps[bi]
    share = share / share.sum(1, keepdims=True)
    res["contrib_share"] = {b_: [round(float(v), 4) for v in share[:, bi]] for bi, (b_, _, _) in enumerate(blocks)}
    return res


# the final booster of each bank (the last fit recorded per bank width; the earlier ones are out-of-fold fits)
finals = {}
for gg in R.ggbt:
    if gg["bst"] is not None:
        finals[gg["bank"].shape[1] if gg.get("bank") is not None else 0] = gg
names = {}
for w_, gg in sorted(finals.items()):
    names[w_] = "cgbt" if (R.bars and w_ > len(ks) * len(act)) else "ggbt"
out["boosters"] = {}
for w_, gg in finals.items():
    out["boosters"][names[w_]] = analyse_booster(gg, names[w_])
maps["class_mean"] = np.stack([np.bincount(g, weights=D["X"][r["tr"]][D["y"][r["tr"]] == c].mean(0), minlength=784) for c in range(D["C"])])
if "ggbt" in out["boosters"]:                                           # backward-compatible keys (v2 figures)
    out["gain"] = out["boosters"]["ggbt"]["gain"]; maps["contrib"] = maps["ggbt_contrib"]
    if "pairs" in out["boosters"]["ggbt"]:
        out["pairs"] = out["boosters"]["ggbt"]["pairs"]
out["cpu"] = round(time.process_time() - t0, 1)
json.dump(out, open(base + ".json", "w"), indent=1, default=lambda v: v.item() if hasattr(v, "item") else str(v))
np.savez_compressed(base + ".npz", **maps)
print(json.dumps({k: out[k] for k in ("err", "weights", "pooling", "topology") if k in out}, default=str)[:1500])
print("gain", out.get("gain")); print("cpu", out["cpu"])

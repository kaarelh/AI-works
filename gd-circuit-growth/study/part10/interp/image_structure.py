"""What do the learner's image members encode?  (Descriptive analysis.)  One fit of part9/eval_cells.py (dataset, n,
seed) is reproduced (hooks.fit_image) and summarised; the learner never sees the pixel layout, the analysis maps its
objects back onto the 28 x 28 grid (hooks.grid_of).
  pooling      S_i(k), the k columns most correlated with column i: distance of the members from the centre pixel on the
               true grid (Chebyshev), the fraction within distance 1 / 2, and the overlap with the k truly nearest pixels
  topology     Isomap of the graph that joins each column to the members of its S_i(9): shortest-path distances, classical
               MDS to 2-D, Procrustes fit to the true pixel coordinates (r2 = 1 - Procrustes disparity)
  gain         the final ggbt booster's split gain by feature type (raw pixels, pooled sums at each k, prototype pairs)
               and its maps on the grid (a pooled sum at its centre pixel; a pair spread over pixels by |u_p|)
  contrib      per-class contribution maps (LightGBM pred_contrib on test points of the class, for that class's score;
               a pooled sum's contribution spread equally over its k pixels; a pair's over pixels by |u_p x_p|)
  pairs        the classes of the prototype pairs, gain by class pair
  stack        the stacker's weights and the members' out-of-fold errors
usage: python image_structure.py <dataset> <n> [--seed=0] [--learner=path] [--tag=v2] [--m_contrib=1000]
writes results/image/<tag>/<dataset>__n<n>__s<seed>.json and .npz (maps, embedding)"""
import os, sys, json, time, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import hooks as H

ds, n = sys.argv[1], int(sys.argv[2])
opt = {a.split("=", 1)[0][2:]: a.split("=", 1)[1] for a in sys.argv[3:] if a.startswith("--") and "=" in a}
seed = int(opt.get("seed", 0)); tag = opt.get("tag", "v2"); path = opt.get("learner", H.V2); mc = int(opt.get("m_contrib", 1000))
out_dir = os.path.join(HERE, "results", "image", tag); os.makedirs(out_dir, exist_ok=True)
base = os.path.join(out_dir, f"{ds}__n{n}__s{seed}")

HP = H.load_learner(path); t0 = time.process_time()
r = H.fit_image(HP, ds, n, seed); D = r["D"]; R = r["rec"]; d = D["X"].shape[1]
g = H.grid_of(ds, d); rc = np.stack([g // 28, g % 28], 1)                  # column j -> (row, col) of its pixel
out = dict(dataset=ds, n=n, seed=seed, learner=path, err=r["err"], fit_cpu=round(time.process_time() - t0, 1),
           weights=r["info"].get("weights"), member_oof_err=r["info"].get("member_oof_err"),
           ggbt_rounds=r["info"].get("ggbt_rounds"))
maps = {}

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

# ---- topology: Isomap of the S_i(9) graph
from scipy.sparse import csr_matrix
from scipy.sparse.csgraph import shortest_path
kk = 9 if 9 in ks else ks[len(ks) // 2]; M = As[kk] > 0; pos = {int(i): c for c, i in enumerate(act)}
rows, cols = [], []
for c, i in enumerate(act):
    for j in np.where(M[:, c])[0]:
        if int(j) in pos and pos[int(j)] != c:
            rows += [c, pos[int(j)]]; cols += [pos[int(j)], c]
Gm = csr_matrix((np.ones(len(rows)), (rows, cols)), shape=(len(act), len(act)))
SP = shortest_path(Gm, directed=False, unweighted=True)
fin = np.isfinite(SP).all(1); comp = np.where(fin)[0] if fin.any() else np.arange(len(act))
if not fin.all():                                                            # the largest connected part
    from scipy.sparse.csgraph import connected_components
    _, lab = connected_components(Gm, directed=False); big = np.bincount(lab).argmax(); comp = np.where(lab == big)[0]
Dm = SP[np.ix_(comp, comp)] ** 2; J = np.eye(len(comp)) - 1.0 / len(comp); Bm = -0.5 * J @ Dm @ J
ev, V = np.linalg.eigh(Bm); Y = V[:, -2:] * np.sqrt(np.maximum(ev[-2:], 0))
from scipy.spatial import procrustes
P = rc[act[comp]].astype(float); _, Ya, disp = procrustes(P, Y)
out["topology"] = dict(k=kk, nodes=int(len(comp)), of_active=int(len(act)), procrustes_r2=round(float(1 - disp), 4),
                       graph_edges=int(Gm.nnz // 2))
maps["isomap"] = Y; maps["isomap_pixels"] = g[act[comp]]

# ---- the final ggbt booster
gg = R.ggbt[-1] if R.ggbt else None
if gg is not None and gg["bst"] is not None:
    bst, best, U, feat = gg["bst"], gg["best"], gg["U"], gg["feat"]
    na = len(act); blocks = [("raw", 0, d)] + [(f"pool{k}", d + q * na, d + (q + 1) * na) for q, k in enumerate(ks)] + \
        [("pairs", d + len(ks) * na, d + len(ks) * na + len(U))]
    gain = bst.feature_importance("gain", iteration=best); splits = bst.feature_importance("split", iteration=best)
    assert len(gain) == blocks[-1][2], (len(gain), blocks)
    tot = gain.sum()
    out["gain"] = {b: dict(gain_frac=round(float(gain[lo:hi].sum() / tot), 4), split_frac=round(float(splits[lo:hi].sum() / splits.sum()), 4),
                           n_used=int(np.sum(splits[lo:hi] > 0)), n=int(hi - lo)) for b, lo, hi in blocks}
    gmap = {}
    gm = np.zeros(784); gm[g] = gain[:d]; gmap["raw"] = gm
    for q, k in enumerate(ks):
        gm = np.zeros(784); lo = d + q * na; np.add.at(gm, g[act], gain[lo:lo + na]); gmap[f"pool{k}"] = gm
    lo = d + len(ks) * na; Ua = np.abs(U); Ua = Ua / np.maximum(Ua.sum(1, keepdims=True), 1e-12)
    gm = np.zeros(784); np.add.at(gm, g, Ua.T @ gain[lo:lo + len(U)]); gmap["pairs"] = gm
    for kname, v in gmap.items():
        maps["gain_" + kname] = v
    # the pairs: classes and gain
    pc = gg["pair_cls"]; pg = gain[lo:lo + len(U)]; C = D["C"]; G2 = np.zeros((C, C))
    for (a, b), v in zip(pc, pg):
        G2[min(a, b), max(a, b)] += v
    maps["pair_class_gain"] = G2
    top = np.argsort(-pg)[:12]; maps["pair_top_dirs"] = np.stack([np.bincount(g, weights=U[i], minlength=784) for i in top])
    out["pairs"] = dict(n=int(len(U)), top=[dict(classes=[int(c) for c in pc[i]], gain_frac=round(float(pg[i] / tot), 5)) for i in top],
                        gain_frac_top12=round(float(pg[top].sum() / tot), 4))
    # per-class contribution maps on m test points per class
    te = r["te"]; yte = D["y"][te]; rng = np.random.default_rng(1); m_c = max(1, mc // C)
    sel = np.concatenate([rng.choice(np.where(yte == c)[0], size=min(m_c, int(np.sum(yte == c))), replace=False) for c in range(C)])
    Xq = D["X"][te[sel]]; Fq = feat(Xq); CT = bst.predict(Fq, num_iteration=best, pred_contrib=True)
    nf = Fq.shape[1]; CT = CT.reshape(len(sel), C, nf + 1)
    cmaps = np.zeros((C, 784)); share = np.zeros((C, len(blocks)))
    Mpool = {k: (As[k] > 0) for k in ks}
    for c in range(C):
        idx = np.where(yte[sel] == c)[0]; ct = CT[idx, c, :nf]                      # contributions to class c's score
        pix = np.zeros((len(idx), 784)); pix[:, g] += ct[:, :d]
        for q, k in enumerate(ks):
            lo_ = d + q * na; w = ct[:, lo_:lo_ + na] / k                            # spread over the k members
            pix[:, g] += w @ Mpool[k].T.astype(float)
        lo_ = d + len(ks) * na; ux = np.abs(Xq[idx][:, None, :] * U[None, :, :])   # |u_p x_p| per point and pair
        ux = ux / np.maximum(ux.sum(2, keepdims=True), 1e-12)
        pix[:, g] += np.einsum("ip,ipj->ij", ct[:, lo_:lo_ + len(U)], ux)
        cmaps[c] = pix.mean(0)
        for bi, (_, lo, hi) in enumerate(blocks):
            share[c, bi] = np.abs(ct[:, lo:hi]).sum(1).mean()
    maps["contrib"] = cmaps; maps["class_mean"] = np.stack([np.bincount(g, weights=D["X"][r["tr"]][D["y"][r["tr"]] == c].mean(0), minlength=784) for c in range(C)])
    share = share / share.sum(1, keepdims=True)
    out["contrib_share"] = {b: [round(float(v), 4) for v in share[:, bi]] for bi, (b, _, _) in enumerate(blocks)}
out["cpu"] = round(time.process_time() - t0, 1)
json.dump(out, open(base + ".json", "w"), indent=1, default=lambda v: v.item() if hasattr(v, "item") else str(v))
np.savez_compressed(base + ".npz", **maps)
print(json.dumps({k: out[k] for k in ("err", "weights", "pooling", "topology") if k in out}, default=str)[:1500])
print("gain", out.get("gain")); print("cpu", out["cpu"])

"""Structure of the failure set S = {x : f(x) < t} of nets trained to output 1.

Reads the enumeration caches (cache/<name>.npz from enumerate.py) or, for nets
trained here, computes S in memory. For nets with p = 0 the same statistics are
computed on the 1000 lowest inputs ("near-failures"), marked near=True.

Statistics (all exact on S or on its uniform subsample, against a uniform
reference sample R):
  direction   mean failing input (|mean| per coordinate vs the noise 1/sqrt|S|);
              the max-margin halfspace through the origin containing S (min-norm
              point of conv S, Gilbert's algorithm) and its exact mass / p.
  symmetry    fraction of failures whose antipode fails; corr(f(x), f(-x)).
  geometry    pairwise Hamming distances; nearest-neighbour distance; pair
              correlation g(h) = E_s #{s' in S: |s - s'| = h} / (C(d,h) p) for
              h = 1, 2 (g = 1 for a uniformly random set); components of S under
              Hamming adjacency (<= 1 and <= 2).
  spread      spectrum of E_S[x x^T] (= I for uniform x).
  weights     normalised first-layer pre-activations u_j = (w_j.x + b_j)/|w_j| at
              failures vs typical, split by the sign of the unit's effective
              output weight; fraction of |x|^2 in span{w_j : a_j > 0}.
  parts       even form (one hidden layer): f = c' + L(x) + E+(x) - E-(x),
              L = lam.x, lam = (1/2) sum_j a_j w_j, E+ = (1/2) sum_{a_j>0} a_j|z_j|,
              E- = (1/2) sum_{a_j<0} |a_j||z_j|; any depth: even/odd parts of f.
              Drops at failures in units of the part's standard deviation.

usage: python3 structure.py [name ...]   (default: every net with a cache)
"""

import glob
import math
import os
import sys

import numpy as np

from common import HERE, RES, decode, save_json, suite, suite_net, _half_inputs

CACHE = os.path.join(HERE, "cache")


def halfspace_mass(v, tau, d):
    """Exact Pr_x[v.x >= tau] on the uniform cube (meet in the middle)."""
    k1 = d // 2
    A = np.sort(_half_inputs(k1) @ v[:k1])
    B = _half_inputs(d - k1) @ v[k1:]
    # count pairs with a + b >= tau
    cnt = (len(A) - np.searchsorted(A, tau - B - 1e-12 * (1 + abs(tau)), side="left")).sum()
    return float(cnt) / 2.0 ** d


def min_norm_point(S, iters=3000):
    """Gilbert / Frank-Wolfe min-norm point of conv(S)."""
    y = S.mean(axis=0)
    for _ in range(iters):
        g = S @ y
        j = int(np.argmin(g))
        s = S[j]
        dvec = s - y
        den = dvec @ dvec
        if den <= 0:
            break
        lam = np.clip(-(y @ dvec) / den, 0.0, 1.0)
        if lam <= 1e-12:
            break
        y = y + lam * dvec
    return y


def hidden_pre(net, X):
    return X @ net.Ws[0].T + net.bs[0]


def effective_out(net, X):
    """Per first-layer unit, the mean over X of d f / d h1_j (= a_j for one layer)."""
    if len(net.Ws) == 2:
        return net.Ws[1][0].copy()
    _, pre = net.forward(X, keep=True)
    delta = np.ones((X.shape[0], 1)) * net.Ws[-1]
    for k in range(len(net.Ws) - 1, 1, -1):
        delta = (delta * (pre[k - 1] > 0)) @ net.Ws[k - 1]
    return delta.mean(axis=0)


def pair_stats(S_idx, d, p, full):
    """g(1), g(2), components, from the sorted full failure index list."""
    out = {}
    if not full or len(S_idx) == 0:
        return out
    srt = np.sort(S_idx)
    n = len(srt)
    flips1 = (np.int64(1) << np.arange(d, dtype=np.int64))
    pairs = [(i, j) for i in range(d) for j in range(i + 1, d)]
    flips2 = np.array([(1 << i) | (1 << j) for i, j in pairs], dtype=np.int64)
    parent = np.arange(n)

    def find(i):
        while parent[i] != i:
            parent[i] = parent[parent[i]]
            i = parent[i]
        return i

    def union_edges(nb_idx, src):
        pos = np.searchsorted(srt, nb_idx)
        pos = np.minimum(pos, n - 1)
        hit = srt[pos] == nb_idx
        for a, b in zip(src[hit], pos[hit]):
            ra, rb = find(a), find(b)
            if ra != rb:
                parent[ra] = rb
        return int(hit.sum())

    src_all = np.arange(n)
    chunk = max(1, 2_000_000 // (len(flips2) + d))
    h1 = h2 = 0
    for s in range(0, n, chunk):
        src = src_all[s:s + chunk]
        nb = (srt[src, None] ^ flips1[None, :])
        h1 += union_edges(nb.reshape(-1), np.repeat(src, d))
    comps1 = len({find(i) for i in range(n)})
    sizes1 = np.bincount([find(i) for i in range(n)])
    for s in range(0, n, chunk):
        src = src_all[s:s + chunk]
        nb = (srt[src, None] ^ flips2[None, :])
        h2 += union_edges(nb.reshape(-1), np.repeat(src, len(flips2)))
    roots = np.array([find(i) for i in range(n)])
    sizes2 = np.bincount(roots)
    out.update(g1=(h1 / n) / (d * p), g2=(h2 / n) / (math.comb(d, 2) * p), mean_fail_nb1=h1 / n, mean_fail_nb2=h2 / n,
               comps_h1=comps1, largest_h1=int(sizes1.max()), comps_h2=int((sizes2 > 0).sum()),
               largest_h2=int(sizes2.max()))
    return out


def basins(net, L_idx):
    """Local minima of f (single bit flips) in the sublevel set given by L_idx
    (a full sublevel set {f < s}), and the sizes of their steepest-descent basins."""
    d = net.d
    srt = np.sort(L_idx)
    n = len(srt)
    fL = net.forward(decode(srt, d))
    best = fL.copy()
    nxt = np.arange(n)
    for i in range(d):
        nb = srt ^ (np.int64(1) << i)
        fn = net.forward(decode(nb, d))
        better = fn < best
        if better.any():
            pos = np.searchsorted(srt, nb[better])
            pos = np.minimum(pos, n - 1)
            ok = srt[pos] == nb[better]  # always true for a sublevel set
            idx = np.where(better)[0][ok]
            best[idx] = fn[better][ok]
            nxt[idx] = pos[ok]
    root = nxt.copy()
    for _ in range(64):
        new = root[root]
        if np.array_equal(new, root):
            break
        root = new
    mins = np.where(nxt == np.arange(n))[0]
    sizes = np.sort(np.bincount(root, minlength=n)[mins])[::-1]
    cum = np.cumsum(sizes) / n
    # antipodal pairing of minima
    mins_idx = srt[mins]
    anti = (~mins_idx) & ((np.int64(1) << d) - 1)
    paired = np.isin(anti, mins_idx).mean()
    return dict(n_set=n, n_minima=int(len(mins)), basin_top=sizes[:8].tolist(),
                minima_for_50=int(np.searchsorted(cum, 0.5) + 1), minima_for_90=int(np.searchsorted(cum, 0.9) + 1),
                minima_antipodal_frac=float(paired), deepest_minima_f=np.sort(fL[mins])[:6].tolist())


def axis_stats(net, L, aeff, p, F, d):
    """Top eigenvector v of E_L[x x^T]: share of L near +-sign(v), and its relation
    to the low-gain directions of the positive units' weights."""
    ev, V = np.linalg.eigh(L.T @ L / len(L))
    v = V[:, -1]
    sig = np.sign(v)
    ham = np.minimum((d - L @ sig) / 2, (d + L @ sig) / 2)
    W = net.Ws[0]
    pos = aeff > 0
    G = (W[pos] * aeff[pos, None]).T @ W[pos]
    gv, gV = np.linalg.eigh(G)
    out = dict(top_eig=float(ev[-1]), second_eig=float(ev[-2]), frac_near_axis=float((ham <= d / 5).mean()),
               ham_axis_median=float(np.median(ham)), v_l1_over_sqrtd=float(np.abs(v).sum() / np.sqrt(d)),
               cos_v_lowgain=float(np.abs(gV[:, 0] @ v)), cos_v_lowgain2=float(np.linalg.norm(gV[:, :2].T @ v)),
               lowgain_eigs=(gv[:3] / gv.mean()).tolist())
    xs = np.sign(gV[:, 0])
    out["f_at_sign_lowgain"] = float(net.forward(xs[None, :])[0])
    return out


def analyse(net, name, S_idx, F, full, near, rng, meta=None, L_idx=None):
    d, t = net.d, net.threshold
    p = F / 2.0 ** d
    S = decode(S_idx, d)
    nS = len(S)
    R = rng.choice([-1.0, 1.0], size=(20000, d))
    fR = net.forward(R)
    fS = net.forward(S)
    out = dict(name=name, d=d, widths=net.widths, loss=net.loss, F=int(F), p=p, nS=nS, full=bool(full), near=bool(near),
               fS_max=float(fS.max()), fS_min=float(fS.min()))
    if meta:
        out.update(meta)
    # direction
    mS = S.mean(axis=0)
    out.update(mean_abs_coord=float(np.abs(mS).mean()), max_abs_coord=float(np.abs(mS).max()),
               noise_coord=1.0 / math.sqrt(nS), mean_norm_over_sqrtd=float(np.linalg.norm(mS) / math.sqrt(d)))
    if full and nS >= 1 and p > 0:
        v = mS if np.linalg.norm(mS) > 0 else np.ones(d)
        tau = float((S @ v).min())
        out["halfspace_mean_ratio"] = halfspace_mass(v, tau, d) / p
        y = min_norm_point(S)
        gamma = float((S @ y).min()) if np.linalg.norm(y) > 1e-9 else 0.0
        out["maxmargin_gamma_over_sqrtd"] = gamma / max(np.linalg.norm(y), 1e-300) / math.sqrt(d) if gamma > 0 else 0.0
        out["halfspace_maxmargin_ratio"] = (halfspace_mass(y, gamma, d) / p) if gamma > 0 else 0.5 / p
    # symmetry
    fRm = net.forward(-R)
    out["corr_f_fneg"] = float(np.corrcoef(fR, fRm)[0, 1])
    fe_R, fo_R = (fR + fRm) / 2, (fR - fRm) / 2
    fSm = net.forward(-S)
    fe_S, fo_S = (fS + fSm) / 2, (fS - fSm) / 2
    out["even_drop_sd"] = float((fe_R.mean() - fe_S.mean()) / fe_R.std())
    out["odd_drop_sd"] = float((fo_R.mean() - fo_S.mean()) / fo_R.std())
    out["even_sd"], out["odd_sd"] = float(fe_R.std()), float(fo_R.std())
    out["antipode_fails_frac"] = float((fSm < t).mean())
    # Hamming geometry
    sub = S[rng.permutation(nS)[:2000]]
    if len(sub) >= 2:
        D = (d - sub @ sub.T) / 2
        iu = np.triu_indices(len(sub), 1)
        out["ham_mean"], out["ham_sd"] = float(D[iu].mean()), float(D[iu].std())
        np.fill_diagonal(D, np.inf)
        out["nn_mean_in_sub"] = float(D.min(axis=1).mean())
    # nearest neighbour distance within the full set (sampled sources)
    if full and nS >= 2:
        src = S[rng.permutation(nS)[:300]]
        Dn = (d - src @ S.T) / 2
        Dn[Dn == 0] = np.inf
        out["nn_mean"] = float(Dn.min(axis=1).mean())
        # random-set prediction: smallest h with F * sum_{k<=h} C(d,k) / 2^d >= 1
        acc, h = 0.0, 0
        while h <= d:
            acc += math.comb(d, h) * F / 2.0 ** d
            if acc >= 1:
                break
            h += 1
        out["nn_random_set"] = h
    out.update(pair_stats(S_idx, d, p, full and nS <= 200000 and p > 0 and not near))
    # spread
    ev = np.linalg.eigvalsh(S.T @ S / nS)
    out["cov_eigs_low"] = ev[:6].tolist()
    out["cov_eigs_high"] = ev[-4:].tolist()
    out["cov_n_below_half"] = int((ev < 0.5).sum())
    # weights
    W, b = net.Ws[0], net.bs[0]
    nw = np.linalg.norm(W, axis=1)
    aeff = effective_out(net, R[:4000])
    pos, neg = aeff > 0, aeff <= 0
    uS = np.abs(hidden_pre(net, S)) / nw
    uR = np.abs(hidden_pre(net, R)) / nw
    out["n_pos_units"], out["n_neg_units"] = int(pos.sum()), int(neg.sum())
    out["u_pos_ratio"] = float(uS[:, pos].mean() / uR[:, pos].mean()) if pos.any() else None
    out["u_neg_ratio"] = float(uS[:, neg].mean() / uR[:, neg].mean()) if neg.any() else None
    out["n_small_pos_S"] = float((uS[:, pos] < 0.25).sum(axis=1).mean())
    out["n_small_pos_R"] = float((uR[:, pos] < 0.25).sum(axis=1).mean())
    # weighted by |a|: which units carry the drop
    if pos.any():
        Q, _ = np.linalg.qr(W[pos].T)
        Q = Q[:, :np.linalg.matrix_rank(W[pos])]
        out["proj_pos_S"] = float(((S @ Q) ** 2).sum(axis=1).mean() / d)
        out["proj_pos_R"] = float(((R @ Q) ** 2).sum(axis=1).mean() / d)
    if neg.any():
        Q, _ = np.linalg.qr(W[neg].T)
        Q = Q[:, :np.linalg.matrix_rank(W[neg])]
        out["proj_neg_S"] = float(((S @ Q) ** 2).sum(axis=1).mean() / d)
        out["proj_neg_R"] = float(((R @ Q) ** 2).sum(axis=1).mean() / d)
    if L_idx is not None and len(L_idx) >= 1:
        out.update(basins(net, L_idx))
        out.update(axis_stats(net, decode(L_idx, d), aeff, p, F, d))
    # even form (one hidden layer)
    if len(net.Ws) == 2:
        a, c = net.Ws[1][0], float(net.bs[1][0])
        lam = 0.5 * (a[:, None] * W).sum(axis=0)
        cprime = c + 0.5 * float(a @ b)
        out["lam_norm"] = float(np.linalg.norm(lam))
        out["lam_rel"] = float(np.linalg.norm(lam) / (0.5 * np.abs(a) @ nw))
        out["cprime"] = cprime
        for nm, X in (("S", S), ("R", R)):
            Z = hidden_pre(net, X)
            Ep = 0.5 * (np.abs(Z[:, a > 0]) @ a[a > 0])
            Em = 0.5 * (np.abs(Z[:, a <= 0]) @ -a[a <= 0])
            Lx = X @ lam
            out[f"Ep_{nm}"], out[f"Em_{nm}"], out[f"L_{nm}"] = float(Ep.mean()), float(Em.mean()), float(Lx.mean())
            if nm == "R":
                out["Ep_sd"], out["Em_sd"], out["L_sd"] = float(Ep.std()), float(Em.std()), float(Lx.std())
        out["Ep_drop_sd"] = (out["Ep_R"] - out["Ep_S"]) / out["Ep_sd"]
        out["Em_rise_sd"] = (out["Em_S"] - out["Em_R"]) / out["Em_sd"]
        out["L_drop_sd"] = (out["L_R"] - out["L_S"]) / out["L_sd"]
        # share of the total drop of f carried by each part
        tot = (fR.mean() - fS.mean())
        out["share_Ep"] = (out["Ep_R"] - out["Ep_S"]) / tot
        out["share_Em"] = (out["Em_S"] - out["Em_R"]) / tot
        out["share_L"] = (out["L_R"] - out["L_S"]) / tot
    return out


def from_cache(name):
    """S_idx: failures (uniform subsample if F > 100k) or, if p = 0, the 1000
    lowest inputs; L_idx: a full sublevel set (all failures if F <= 100k, else
    the 100k lowest inputs; the 1000 lowest if p = 0)."""
    z = np.load(os.path.join(CACHE, name + ".npz"))
    F = int(z["fail_count"])
    low = z["low_i"]
    if F > 0:
        S_idx = z["fail_i"]
        return S_idx, F, len(S_idx) == F, False, low[:min(F, len(low))]
    return low[:1000], 0, False, True, low[:1000]


def own_sets(net):
    """S_idx, F, full, near, L_idx for a net trained here (d <= 24), in memory."""
    from common import all_f
    f = all_f(net)
    S = np.where(f < net.threshold)[0].astype(np.int64)
    F = len(S)
    low = np.argsort(f, kind="stable")[:100000].astype(np.int64)
    if F == 0:
        return low[:1000], 0, False, True, low[:1000]
    rng = np.random.default_rng(F)
    S_sub = np.sort(rng.choice(S, size=100000, replace=False)) if F > 100000 else S
    return S_sub, F, F <= 100000, False, low[:min(F, 100000)]


def main_own(subs):
    """Nets trained here: one seed (0) per configuration and d, steps with 0 < p <= 0.05."""
    import json
    from common import load_net
    rng = np.random.default_rng(12)
    path = os.path.join(RES, "structure_own.json")
    rows = json.load(open(path)) if os.path.exists(path) else []
    done = {r["name"] for r in rows}
    for sp in sorted(glob.glob(os.path.join(RES, "scaling_*.json"))):
        if sp.endswith("summary.json"):
            continue
        for r in json.load(open(sp)):
            if r["seed"] != 0 or not (0 < r["p"] <= 0.05) or r["d"] < 16:
                continue
            if subs and not any(s in r["name"] or s == r["config"] for s in subs):
                continue
            if r["name"] in done:
                continue
            net = load_net(os.path.join(HERE, "cache", "own", r["name"] + ".npz"))
            S_idx, F, full, near, L_idx = own_sets(net)
            o = analyse(net, r["name"], S_idx, F, full, near, rng, dict(step=r["step"], config=r["config"]), L_idx)
            rows.append(o)
            print(r["name"], {k: (round(o[k], 3) if isinstance(o.get(k), float) else o.get(k)) for k in
                              ["F", "mean_abs_coord", "noise_coord", "halfspace_maxmargin_ratio", "corr_f_fneg",
                               "even_drop_sd", "odd_drop_sd", "g1", "n_minima", "minima_for_50", "top_eig",
                               "u_pos_ratio", "u_neg_ratio", "share_Ep", "share_Em", "share_L"]}, flush=True)
            save_json(rows, "structure_own.json")


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "own":
        return main_own(sys.argv[2:])
    names = sys.argv[1:] or sorted(os.path.basename(p)[:-4] for p in glob.glob(os.path.join(CACHE, "*.npz")))
    rng = np.random.default_rng(11)
    rows = []
    path = os.path.join(RES, "structure.json")
    if os.path.exists(path):
        import json
        rows = [r for r in json.load(open(path)) if r["name"] not in names]
    meta = {r["name"]: r for r in suite()}
    for name in names:
        net = suite_net(name)
        S_idx, F, full, near, L_idx = from_cache(name)
        o = analyse(net, name, S_idx, F, full, near, rng, dict(step=meta.get(name, {}).get("step")), L_idx)
        rows.append(o)
        keys = ["F", "mean_abs_coord", "noise_coord", "halfspace_maxmargin_ratio", "antipode_fails_frac", "corr_f_fneg",
                "even_drop_sd", "odd_drop_sd", "ham_mean", "nn_mean", "nn_random_set", "g1", "g2", "comps_h2", "nS",
                "cov_n_below_half", "u_pos_ratio", "u_neg_ratio", "proj_pos_S", "proj_pos_R", "share_Ep", "share_Em",
                "share_L", "n_set", "n_minima", "minima_for_50", "minima_for_90", "minima_antipodal_frac", "basin_top",
                "top_eig", "frac_near_axis", "cos_v_lowgain", "cos_v_lowgain2", "f_at_sign_lowgain"]
        print(name, {k: (round(o[k], 4) if isinstance(o.get(k), float) else o.get(k)) for k in keys}, flush=True)
        save_json(rows, "structure.json")


if __name__ == "__main__":
    main()

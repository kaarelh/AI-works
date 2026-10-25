"""Stage-by-stage characterization of the learning trajectories (online condition and fixed n = 2048, seed 0..2).

1. Plateaus: maximal intervals of training steps where E[f | x_R] moves slowly, i.e. its speed
   ||f_R(t_{i+1}) - f_R(t_i)|| / sqrt(2^r Var y) per decade of steps is below 0.25, lasting at least 0.25 decades.
2. For the function at the middle of each plateau:
   - the Fourier characters that are learned (learned fraction > 1/2) and their fractions;
   - its sign error against the target, and the sign error of the projection P_S y onto those characters;
   - the distance to two hypotheses (relative to Var y): H_char = P_S y, and H_junta = E[y | x_V] for the variables
     V with non-negligible influence;
   - the best constant-rescaled fit to the "feature span": the least-squares fit of y on the conditional means of the
     network's own active hidden units at the nearest saved checkpoint (does the plateau function equal the best fit
     within the features present?).
3. The features present: first-layer units whose weight on R has grown (norm > 2x its initial norm), grouped by support
   (inputs with |w_i| > 0.3 max_i |w_i|) and sign pattern; and the number of active second-layer units.
Writes trajectories/STAGES.md.
"""
import os, sys, json, itertools, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE); sys.path.insert(0, os.path.dirname(HERE))
from analyze_traj import S_DIR, subsets, chi_matrix, target_on_cube, junta_projection
from collections import Counter

FNS = ["sparsepoly", "stair5", "mux", "majpar", "rmaj9"]


def plateaus(steps, f, vy, thr=0.25, minlen=0.25):
    ls = np.log10(np.maximum(steps, 0.5)); P = f.shape[1]
    sp = np.sqrt(np.sum(np.diff(f, axis=0) ** 2, 1) / P / vy) / np.maximum(np.diff(ls), 1e-9)
    slow = sp < thr
    out, i = [], 0
    while i < len(slow):
        if slow[i]:
            j = i
            while j + 1 < len(slow) and slow[j + 1]:
                j += 1
            if ls[j + 1] - ls[i] >= minlen:
                out.append((i, j + 1))
            i = j + 1
        else:
            i += 1
    return out


def unit_types(W1R, W1R0, R):
    nrm = np.linalg.norm(W1R, axis=1); nrm0 = np.linalg.norm(W1R0, axis=1)
    types = Counter()
    for u in np.where(nrm > 2 * np.maximum(nrm0, 1e-6))[0]:
        w = W1R[u]; m = np.abs(w).max(); sup = np.where(np.abs(w) > 0.3 * m)[0]
        types["".join(("+" if w[i] > 0 else "-") + f"x{R[i] + 1}" for i in sup)] += 1
    return types


def describe(fn, tag, prefix, L):
    z = np.load(os.path.join(S_DIR, f"traj_{tag}_{fn}.npz"))
    steps = z["steps"].astype(float); pats = z["pats"].astype(float); R = list(z["R"]); r = len(R)
    subs = subsets(r); C = chi_matrix(pats, subs); names = ["".join(f"x{R[i] + 1}" for i in T) or "1" for T in subs]
    y = target_on_cube(fn, pats, R); vy = np.var(y); yhat = C.T @ y / len(y)
    supp = [j for j in range(len(subs)) if abs(yhat[j]) > 1e-9]
    nets = list(z["nets"]); idx = [k for k, nm in enumerate(nets) if nm == prefix]
    f = z["f_mean"][:, idx, :].astype(float).mean(1)
    hsteps = list(z["h_steps"])
    L.append(f"\n### {fn}, {'online' if tag == 'online' else 'n = ' + prefix} (seed mean; features from seed 0)\n")
    L.append("| stage midpoint (step) | learned characters (fraction) | sign error: network / P_S y | dist. to H_char / H_junta | first-layer feature types, seed 0 (count) |")
    L.append("|---|---|---|---|---|")
    k0 = idx[0]
    coefs_all = f @ C / len(y)
    ons = []
    for j in supp:
        if subs[j] == ():
            continue
        ph = coefs_all[:, j] / yhat[j]
        hit = [i for i in range(len(steps)) if ph[i] >= 0.5 and np.all(ph[i:] >= 0.4)]
        if hit:
            ons.append(steps[hit[0]])
    ons = sorted(ons)
    clusters = []
    for o in ons:
        if clusters and o <= 1.35 * clusters[-1][-1]:
            clusters[-1].append(o)
        else:
            clusters.append([o])
    bounds = [1.0] + [np.sqrt(c[-1] * (clusters[k + 1][0] if k + 1 < len(clusters) else steps[-1])) for k, c in enumerate(clusters)]
    marks = [float(np.sqrt(max(bounds[0], 1) * clusters[0][0] / 1.5))] if clusters else []
    marks += [float(np.sqrt(c[-1] * (clusters[k + 1][0] if k + 1 < len(clusters) else steps[-1]))) for k, c in enumerate(clusters)]
    for mk in marks:
        t = int(np.argmin(np.abs(np.log10(np.maximum(steps, 0.5)) - np.log10(mk)))); ft = f[t]; a = b = t
        coef = ft @ C / len(y)
        learned = [(names[j], coef[j] / yhat[j]) for j in supp if subs[j] != () and coef[j] / yhat[j] > 0.5]
        Sset = [j for j in supp if subs[j] == () or coef[j] / yhat[j] > 0.5]
        proj = C[:, Sset] @ yhat[Sset]
        V = []
        for i in range(r):
            flip = pats.copy(); flip[:, i] *= -1
            ii = (flip > 0).astype(int) @ (2 ** np.arange(r)[::-1])
            if np.mean((ft - ft[ii]) ** 2) / 4 > 0.05 * vy:
                V.append(i)
        hj = np.mean((ft - junta_projection(y, pats, V)) ** 2) / vy
        hc = np.mean((ft - proj) ** 2) / vy
        err = np.mean(np.sign(ft) != np.sign(y)); errp = np.mean(np.sign(proj) != np.sign(y))
        st = int(np.argmin(np.abs(steps - steps[t])))
        types = unit_types(z["W1R"][st, k0], z["W1R"][0, k0], R)
        tstr = ", ".join(f"{k} ({v})" for k, v in types.most_common(6))
        lstr = ", ".join(f"{n} ({v:.2f})" for n, v in sorted(learned, key=lambda q: len(q[0]))[:10]) + (" ..." if len(learned) > 10 else "")
        L.append(f"| {int(steps[t])} | {lstr or '–'} | {err:.3f} / {errp:.3f} | {hc:.3f} / {hj:.3f} | {tstr or '–'} |")


def main():
    L = ["# Stages of learning (generated by trajectories/stages.py)", "",
         "Stages are delimited by the onset steps of the target's characters (the first step at which the learned fraction reaches 1/2 for good), with onsets within a factor 1.35 merged into one cluster. Each stage is read at the geometric midpoint between consecutive clusters (and once before the first). ",
         "For the function in the middle of each plateau:",
         "- **Learned characters:** those whose learned fraction (coefficient / target coefficient) exceeds 1/2, with the fraction.",
         "- **Sign error:** that of the network's E[f | x_R], and that of the projection P_S y of the target onto those characters.",
         "- **Distances,** relative to Var y: to that projection (H_char), and to the best function of the variables the network depends on (H_junta).",
         "- **Feature types:** first-layer units whose weight on the relevant variables has grown, labelled by the inputs they weight and the signs.", ""]
    fns = sys.argv[1:] or FNS
    for fn in fns:
        for tag, prefix in (("online", "online"), ("fixed", "2048")):
            describe(fn, tag, prefix, L)
    name = "STAGES.md" if fns == FNS else "STAGES-heldout.md"
    open(os.path.join(HERE, name), "w").write("\n".join(L) + "\n")
    print("\n".join(L))


if __name__ == "__main__":
    main()

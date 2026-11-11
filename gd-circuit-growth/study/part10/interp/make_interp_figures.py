"""Figures and summary tables of the interpretability analysis (results/toy/<tag>, results/image/<tag>).
usage: python make_interp_figures.py [--tag=v2] [--out=figures]      writes <out>/fig_*.pdf and <out>/interp_summary.json"""
import os, sys, json, glob, numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
HERE = os.path.dirname(os.path.abspath(__file__))
opt = {a.split("=", 1)[0][2:]: a.split("=", 1)[1] for a in sys.argv[1:] if a.startswith("--") and "=" in a}
tag = opt.get("tag", "v2"); OUT = opt.get("out", os.path.join(HERE, "results", "figures", tag)); os.makedirs(OUT, exist_ok=True)
plt.rcParams.update({"font.size": 8, "axes.titlesize": 8, "axes.labelsize": 8, "legend.fontsize": 7, "figure.dpi": 150})
INK, ERR, DFG, R2 = "#222222", "#1f77b4", "#d62728", "#2ca02c"


def nstar(ns, e, thr=0.1):
    for i in range(len(e)):
        if e[i] <= thr:
            if i == 0:
                return float(ns[0])
            f = (e[i - 1] - thr) / max(e[i - 1] - e[i], 1e-12)
            return float(2 ** (np.log2(ns[i - 1]) + f * (np.log2(ns[i]) - np.log2(ns[i - 1]))))
    return float("inf")


def toy_load():
    R = {}
    for p in sorted(glob.glob(os.path.join(os.environ.get("INTERP_OUT", os.path.join(HERE, "results")), "toy", tag, "*__s*.json"))):
        r = json.load(open(p)); R[(r["suite"], r["target"], r["seed"])] = r
    return R


def toy_table(R):
    """Per target: n* of the learner (seed 0 cells), the first n with every true class of size >= 3 matched exactly by a
    sum block ('n_struct'), the first n with span_r2 >= 0.95 ('n_span'), and the final cell's summary."""
    rows = []
    for (su, t, s), r in sorted(R.items()):
        C = sorted(r["cells"], key=lambda c: c["n"]); ns = [c["n"] for c in C]; e = [c["err"] for c in C]
        big = [c for c in r["truth"]["classes"] if len(c["S"]) >= 3]
        ex = [c["n"] for c in C if big and c.get("classes") and all(x["exact"] for x in c["classes"])]
        sp = [c["n"] for c in C if (c.get("span_r2") or -1) >= 0.95]
        last = C[-1]
        rows.append(dict(suite=su, target=t, seed=s, desc=r["truth"]["desc"], n_rel=len(r["truth"]["relevant"]),
                         classes=[len(c["S"]) for c in big], nstar=nstar(ns, e), n_struct=ex[0] if ex else None,
                         n_span=sp[0] if sp else None, final_n=last["n"], final_err=last["err"],
                         final_err_dfg=last.get("err_dfg"), final_w_dfg=last["w_dfg"],
                         final_terms=[x.get("desc") or (x["kind"] + str(x.get("S", ""))) for x in (last.get("terms") or [])[:4]],
                         support=last.get("support")))
    return rows


def fig_transitions(R, picks, name):
    k = len(picks); cols = 4; rows_ = int(np.ceil(k / cols))
    fig, axs = plt.subplots(rows_, cols, figsize=(7.2, 1.75 * rows_), squeeze=False)
    for ax, key in zip(axs.ravel(), picks):
        r = R.get(key)
        if r is None:
            ax.axis("off"); continue
        C = sorted(r["cells"], key=lambda c: c["n"]); ns = np.array([c["n"] for c in C])
        ax.plot(ns, [c["err"] for c in C], "-o", ms=2.5, color=ERR, label="learner")
        ax.plot(ns, [c.get("err_dfg", np.nan) if c.get("err_dfg") is not None else np.nan for c in C], "--", color=DFG, lw=1, label="DFG member")
        ax.plot(ns, [max(c.get("span_r2") or 0, 0) * 0.5 for c in C], ":", color=R2, lw=1.2, label="span $R^2$ / 2")
        ex = [c["n"] for c in C if c.get("classes") and all(x["exact"] for x in c["classes"])]
        if ex:
            ax.axvline(ex[0], color=INK, lw=0.6, ls="-."); ax.text(ex[0], 0.52, " exact", fontsize=6, va="top")
        ax.set_xscale("log", base=2); ax.set_ylim(-0.02, 0.56); ax.axhline(0.1, color="#999", lw=0.5)
        ax.set_title(f"{key[1]}: {r['truth']['desc'][:38]}", fontsize=6.5)
        ax.tick_params(labelsize=6)
    for ax in axs.ravel()[k:]:
        ax.axis("off")
    axs[0, 0].legend(loc="upper right", fontsize=5.5, frameon=False)
    fig.supxlabel("training set size n", fontsize=7); fig.supylabel("test error", fontsize=7)
    fig.tight_layout(); fig.savefig(os.path.join(OUT, name)); plt.close(fig)


def fig_g(R, picks, name):
    """Learned function of the true signed sum: mean target (bars) and mean DFG value (points) at each value of t."""
    fig, axs = plt.subplots(1, len(picks), figsize=(7.2, 1.6), squeeze=False)
    for ax, (key, n) in zip(axs.ravel(), picks):
        r = R.get(key)
        c = None if r is None else next((c for c in r["cells"] if c["n"] == n), None)
        if c is None or not c.get("classes"):
            ax.axis("off"); continue
        g = np.array(c["classes"][0]["g"], float)
        ax.bar(g[:, 0], g[:, 2], width=1.2, color="#bbbbbb", label="target")
        ax.plot(g[:, 0], g[:, 3], "o", ms=3, color=DFG, label="DFG value")
        ax.axhline(0, color=INK, lw=0.4); ax.set_title(f"{key[1]} (n = {n})", fontsize=6.5); ax.tick_params(labelsize=6)
        ax.set_xlabel("$t=\\sum_{i\\in S}s_ix_i$", fontsize=6)
    axs[0, 0].legend(fontsize=5.5, frameon=False, loc="lower left")
    fig.tight_layout(); fig.savefig(os.path.join(OUT, name)); plt.close(fig)


def fig_discovery(rows, name):
    pts = [(r["n_struct"], r["nstar"], r["suite"]) for r in rows if r["n_struct"] and r["classes"]]
    fig, ax = plt.subplots(figsize=(3.2, 2.6))
    suites = sorted({p[2] for p in pts}); mk = dict(zip(suites, "osD^v<>p"))
    for su in suites:
        P = [(a, b if np.isfinite(b) else 2 ** 15) for a, b, s in pts if s == su]
        ax.scatter([p[0] for p in P], [p[1] for p in P], s=12, marker=mk[su], label=su, alpha=0.8)
    lim = [12, 2 ** 15]; ax.plot(lim, lim, color="#999", lw=0.6)
    ax.set_xscale("log", base=2); ax.set_yscale("log", base=2); ax.set_xlim(lim); ax.set_ylim(lim)
    ax.set_xlabel("first n with the exact sum block(s)"); ax.set_ylabel("$n^*$ (10% test error)"); ax.legend(fontsize=6, frameon=False)
    fig.tight_layout(); fig.savefig(os.path.join(OUT, name)); plt.close(fig)


def img_load():
    R = {}
    for p in sorted(glob.glob(os.path.join(os.environ.get("INTERP_OUT", os.path.join(HERE, "results")), "image", tag, "*.json"))):
        r = json.load(open(p)); R[(r["dataset"], r["n"], r["seed"])] = (r, dict(np.load(p[:-5] + ".npz", allow_pickle=True)))
    return R


def fig_pool(R, key, name):
    r, M = R[key]; ex = M["pool_examples"]; cen = M["pool_example_centres"]
    fig, axs = plt.subplots(1, len(ex) + 1, figsize=(7.2, 1.45))
    for ax, m, c in zip(axs, ex, cen):
        im = m.reshape(28, 28).astype(float); im[c // 28, c % 28] = 2
        ax.imshow(im, cmap="Greys", vmin=0, vmax=2); ax.set_xticks([]); ax.set_yticks([])
    Y, pix = M["isomap"], M["isomap_pixels"]
    a = axs[-1]; a.scatter(Y[:, 0], Y[:, 1], c=pix % 28, cmap="viridis", s=2); a.set_xticks([]); a.set_yticks([]); a.set_aspect("equal", "datalim")
    a.set_title(f"Isomap $R^2$={r['topology']['k9_mutual']['procrustes_r2']:.2f}", fontsize=6)
    axs[0].set_title(f"$S_i(16)$ on the true grid ({key[0]}, n = {key[1]})", fontsize=6, loc="left")
    fig.tight_layout(); fig.savefig(os.path.join(OUT, name)); plt.close(fig)


def fig_contrib(R, key, name, labels=None):
    r, M = R[key]; C = M["contrib"]; Mu = M["class_mean"]; k = len(C)
    fig, axs = plt.subplots(2, k, figsize=(7.2, 1.7))
    for c in range(k):
        axs[0, c].imshow(Mu[c].reshape(28, 28), cmap="Greys"); v = np.abs(C[c]).max() or 1
        axs[1, c].imshow(C[c].reshape(28, 28), cmap="RdBu_r", vmin=-v, vmax=v)
        axs[0, c].set_title((labels[c] if labels else str(c))[:11], fontsize=5.5)
        for a in axs[:, c]:
            a.set_xticks([]); a.set_yticks([])
    axs[0, 0].set_ylabel("mean", fontsize=6); axs[1, 0].set_ylabel("evidence", fontsize=6)
    fig.tight_layout(pad=0.3); fig.savefig(os.path.join(OUT, name)); plt.close(fig)


def fig_gain(R, keys, name):
    types = ["raw", "pool4", "pool9", "pool16", "pairs"]
    fig, ax = plt.subplots(figsize=(3.4, 2.0)); w = 0.8 / max(len(keys), 1)
    for q, key in enumerate(keys):
        r, _ = R[key]
        if "gain" not in r:
            continue
        ax.bar(np.arange(len(types)) + q * w, [r["gain"].get(t, {}).get("gain_frac", 0) for t in types], width=w,
               label=f"{key[0]} n={key[1]}")
    ax.set_xticks(np.arange(len(types)) + 0.4 - w / 2); ax.set_xticklabels(["pixels", "pooled k=4", "k=9", "k=16", "pairs"])
    ax.set_ylabel("share of split gain"); ax.legend(fontsize=5.5, frameon=False); fig.tight_layout()
    fig.savefig(os.path.join(OUT, name)); plt.close(fig)


if __name__ == "__main__":
    summ = {}
    R = toy_load()
    if R:
        rows = toy_table(R); summ["toy"] = rows
        picks = [k for k in sorted(R) if k[0] == "dlsymdev"][:8]
        if picks:
            fig_transitions(R, picks, "fig_toy_transitions_dlsymdev.pdf")
        picks = [k for k in sorted(R) if k[0] == "dlfamdev"][:12]
        if picks:
            fig_transitions(R, picks, "fig_toy_transitions_dlfamdev.pdf")
        fig_discovery(rows, "fig_toy_discovery.pdf")
    I = img_load()
    if I:
        summ["image"] = {f"{k[0]}__n{k[1]}__s{k[2]}": {kk: v for kk, v in r.items() if kk in ("err", "weights", "pooling", "topology", "gain", "pairs", "contrib_share")}
                         for k, (r, _) in I.items()}
        for k in I:
            fig_pool(I, k, f"fig_pool_{k[0]}_n{k[1]}.pdf")
            labs = None
            cat = os.path.join("/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/std/data/quickdraw", k[0] + "_categories.txt")
            if os.path.exists(cat):
                labs = open(cat).read().split("\n")
            if k[0] == "fashion_mnist":
                labs = ["T-shirt", "trouser", "pullover", "dress", "coat", "sandal", "shirt", "sneaker", "bag", "boot"]
            if "contrib" in I[k][1]:
                fig_contrib(I, k, f"fig_contrib_{k[0]}_n{k[1]}.pdf", labs)
        fig_gain(I, sorted(I), "fig_gain.pdf")
    json.dump(summ, open(os.path.join(OUT, "interp_summary.json"), "w"), indent=1, default=str)
    print("wrote", OUT, sorted(os.listdir(OUT)))

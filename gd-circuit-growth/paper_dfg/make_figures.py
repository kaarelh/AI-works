"""Figures of the DFG paper (paper_dfg/), read from study/part11/RESULTS.json (written by study/part11/compare_dfg.py;
regenerate that first) through make_tables.py's loaders (toy(), num), so that tables and figures use the same values.
usage: python3 make_figures.py            all figures
       python3 make_figures.py NAME ...   only these (function names below)

One function per figure, registered with @figure; each writes figures/<name>.pdf and figures/<name>.json (the plotted
points and the derived numbers that the text or a caption quotes).  Style as in paper_learner/make_figures.py.

Figures of sections/results.tex ("How well it does"):
  fig_nstar    (a) n* of DFG alone against nets_best for every target of every toy suite with network runs (log-log;
               'never' drawn at the edge; marker = the suite's status for DFG v1.3, dlheld7 highlighted); (b) log2 ratio of
               v3's and lowdeg's n* to DFG alone's, against DFG alone's n*, every target of every suite (dlfamdev included;
               the 4 targets that neither learns in a pair are left out).                      (RESULTS.json q2, q3)
  fig_dscale   n* against d (log-log) on the designed targets the networks were trained on at d = 15, 60, 120: DFG v1.3
               alone and the networks (nets, square loss, the variant run at every d), with the fitted exponents; for the
               parities, the union-bound line n_thr(k, d) = 2 ln(4 K C(d, k) / delta), K = 4, delta = 0.1 (c = 1): the
               training-set size above which DFG's test admits a k-parity whose residual correlation is 1 (RESULTS.json q4)
"""
import os, sys, json, math
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import make_tables as MT                                        # noqa: E402  R, num, toy(), l2r: the tables' values

FIG = os.path.join(HERE, "figures"); os.makedirs(FIG, exist_ok=True)
R, num, fin, INF = MT.R, MT.num, MT.fin, MT.INF

# ---- style (as in paper_learner/make_figures.py) ------------------------------------------------------------------------
COL = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4", "#008300", "#6250d6", "#e34948"]
INK, INK2, GRID = "#1a1a1a", "#4a4a4a", "#e3e3e3"
plt.rcParams.update({
    "font.family": "DejaVu Sans", "font.size": 8, "axes.titlesize": 8, "axes.labelsize": 8, "xtick.labelsize": 7.5,
    "ytick.labelsize": 7.5, "legend.fontsize": 7, "axes.edgecolor": "#9a9a9a", "axes.linewidth": 0.6,
    "axes.labelcolor": INK, "xtick.color": INK2, "ytick.color": INK2, "text.color": INK, "axes.titlecolor": INK,
    "figure.facecolor": "white", "axes.facecolor": "white", "savefig.facecolor": "white", "lines.linewidth": 1.5,
    "lines.markersize": 5, "pdf.fonttype": 42, "legend.frameon": False, "axes.grid": True, "grid.color": GRID,
    "grid.linewidth": 0.4, "axes.axisbelow": True, "xtick.major.width": 0.5, "ytick.major.width": 0.5,
    "xtick.minor.width": 0.3, "ytick.minor.width": 0.3})
TEXTW = 6.5                                                   # LaTeX \textwidth in inches (1in margins, letter)

FIGURES = {}


def figure(fn):
    FIGURES[fn.__name__] = fn
    return fn


def save(fig, name, data, tight=False):
    p = os.path.join(FIG, name + ".pdf")
    fig.savefig(p, bbox_inches="tight" if tight else None, pad_inches=0.03)
    plt.close(fig)
    json.dump(data, open(os.path.join(FIG, name + ".json"), "w"), indent=1)   # 'never' stored as Infinity
    print("wrote", os.path.relpath(p, HERE), "and", name + ".json")


# ---- fig_nstar --------------------------------------------------------------------------------------------------------------
GROUPS = [   # (key, suites, legend label, marker, face, edge, size, z): the suites' status for DFG v1.3 (PROTOCOL.md "Held out")
    ("dev", ["designed", "random", "dlheld", "dlsymdev", "dlheld6"], "development of some version\nof DFG", "o", "white", "#8a8a8a", 18, 2),
    ("earlier", ["dlheld2", "dlheld3"], "held out for an earlier\nversion only", "o", COL[0], "white", 22, 3),
    ("exposed", ["dlheld4", "dlheld5"], "v1.2 built after exposure", "D", COL[3], INK2, 20, 4),
    ("held", ["dlheld7"], "held out for v1.3", "s", COL[7], INK, 38, 5),
]


def nstar_points():
    T = MT.toy(); P = []
    for key, suites, *_ in GROUPS:
        for su in suites:
            for t, v in T[su].items():
                P.append(dict(group=key, suite=su, target=t, dfg=v["dfg"], nets_best=v.get("nets_best"), v3=v.get("v3"),
                              lowdeg=v.get("lowdeg")))
    for t, v in T["dlfamdev"].items():                           # no network runs: panel (b) only
        P.append(dict(group="nonets", suite="dlfamdev", target=t, dfg=v["dfg"], nets_best=None, v3=v.get("v3"), lowdeg=v.get("lowdeg")))
    return P


@figure
def fig_nstar():
    P = nstar_points()
    fig = plt.figure(figsize=(TEXTW, 3.75))
    ax = fig.add_axes([0.075, 0.30, 0.40, 0.66]); bx = fig.add_axes([0.585, 0.30, 0.40, 0.66])
    # (a) DFG alone against nets_best
    lo, hi, NEV = 10, 4.6e4, 2.8e4
    pos = lambda v: NEV if not math.isfinite(v) else v
    g = np.array([lo, hi])
    ax.plot(g, g, color=INK2, lw=0.9, ls="--", zorder=1); ax.plot(g, g / 4, color="#9a9a9a", lw=0.8, ls=":", zorder=1)
    ax.text(1.2e4, 1.2e4 * 0.70, "equal data", fontsize=6.3, color=INK2, ha="right", va="top", rotation=45, rotation_mode="anchor")
    ax.text(1.2e4, 1.2e4 / 4 * 0.70, "4$\\times$ less data", fontsize=6.3, color=INK2, ha="right", va="top", rotation=45, rotation_mode="anchor")
    ax.axhline(NEV, color="#c4c4c4", lw=0.6, zorder=0); ax.axvline(NEV, color="#c4c4c4", lw=0.6, zorder=0)
    ax.text(lo * 1.12, NEV * 0.86, "never", fontsize=6.3, color=INK2, va="top", ha="left")
    ax.text(NEV * 0.86, lo * 1.12, "never", fontsize=6.3, color=INK2, va="bottom", ha="right", rotation=90)
    handles, counts = [], {}
    for key, suites, lab, mk, fc, ec, s, z in GROUPS:
        Q = [p for p in P if p["group"] == key]
        counts[key] = len(Q)
        ax.scatter([pos(p["nets_best"]) for p in Q], [pos(p["dfg"]) for p in Q], s=s, marker=mk, facecolor=fc, edgecolor=ec,
                   linewidth=0.8 if key != "earlier" else 0.4, zorder=z, alpha=0.95)
        handles.append(Line2D([], [], marker=mk, ls="", mfc=fc, mec=ec, mew=0.8, ms=math.sqrt(s) + 0.8,
                              label=f"{lab} ({len(Q)})"))
    lab = {(p["suite"], p["target"]): p for p in P}

    def note(su, t, txt, dx, dy, ha="right"):
        p = lab[(su, t)]
        ax.annotate(txt, (pos(p["nets_best"]), pos(p["dfg"])), xytext=(dx, dy), textcoords="offset points", fontsize=6.3, color=INK,
                    ha=ha, va="center", arrowprops=dict(arrowstyle="-", color=INK2, lw=0.5, shrinkA=0, shrinkB=3))
    note("dlheld6", "h6_00", "h6_00", -12, -12)
    note("dlheld3", "h3rf1", "h3rf1", 8, 14, ha="left")
    note("dlheld7", "f7_01", "f7_01", -16, 10)
    note("dlheld", "par5", "par5", -10, 10)
    nev2 = sorted(p["target"] for p in P if p["nets_best"] is not None and not math.isfinite(p["dfg"]) and not math.isfinite(p["nets_best"]))
    ax.annotate(", ".join(nev2) + ":\nno learner", (NEV, NEV), xytext=(-8, -20), textcoords="offset points", fontsize=6.3, color=INK,
                ha="right", va="center", arrowprops=dict(arrowstyle="-", color=INK2, lw=0.5, shrinkA=0, shrinkB=3))
    ax.set_xscale("log"); ax.set_yscale("log"); ax.set_xlim(lo, hi); ax.set_ylim(lo, hi)
    ax.set_xlabel(r"$n^*$ of nets_best (best network variant per target)")
    ax.set_ylabel(r"$n^*$ of DFG alone (inputs permuted per fit)")
    ax.set_title("(a) DFG alone against the networks", loc="left")
    fig.legend(handles=handles, loc="upper left", bbox_to_anchor=(0.03, 0.17), ncol=2, handletextpad=0.3, columnspacing=1.0,
               labelspacing=0.5, fontsize=6.5, title="suites by status for DFG v1.3 (targets plotted)", title_fontsize=6.5,
               alignment="left")
    # (b) v3 and lowdeg relative to DFG alone
    TOP = 7.6
    bx.axhspan(-0.25, 0.25, color="#efefef", lw=0, zorder=0); bx.axhline(0, color=INK2, lw=0.8, zorder=1)
    bx.axhline(TOP, color="#c4c4c4", lw=0.6, zorder=0)
    Qb = [p for p in P if fin(p["dfg"])]
    pts = {}
    for k, mk, fc, ec, s, z, name in (("lowdeg", "^", "white", COL[1], 16, 2, "lowdeg (Fourier coefficients of\ndegree ≤ 4, thresholded)"),
                                      ("v3", "o", COL[0], "white", 15, 3, "v3 (DFG v1.3 stacked with trees,\nkNN and logistic regression)")):
        Y = [(p["dfg"], MT.l2r(p[k], p["dfg"])) for p in Qb if p.get(k) is not None]
        pts[k] = [dict(suite=p["suite"], target=p["target"], dfg=p["dfg"], other=p[k], ratio=MT.l2r(p[k], p["dfg"])) for p in Qb]
        x = np.array([a for a, _ in Y]); y = np.array([TOP if b == INF else b for _, b in Y])
        bx.scatter(x, y, s=s, marker=mk, facecolor=fc, edgecolor=ec, linewidth=0.7 if fc == "white" else 0.3, zorder=z, label=name)
    bx.text(13, TOP - 0.18, "lowdeg never", fontsize=6.3, color=INK2, va="top", ha="left")
    bx.text(1.5e4, 0.33, "within ±0.25", fontsize=6.0, color=INK2, va="bottom", ha="right")
    p5 = [q for q in pts["v3"] if q["target"] == "par5"][0]
    bx.annotate("par5: v3 839, DFG alone 56", (p5["dfg"], p5["ratio"]), xytext=(10, 4), textcoords="offset points", fontsize=6.3,
                color=INK, ha="left", va="center", arrowprops=dict(arrowstyle="-", color=INK2, lw=0.5, shrinkA=0, shrinkB=3))
    bx.set_xscale("log"); bx.set_xlim(12, 1.1e4); bx.set_ylim(-4.6, TOP + 0.5)
    bx.set_xlabel(r"$n^*$ of DFG alone")
    bx.set_ylabel(r"$\log_2(n^*_{\rm other}\,/\,n^*_{\rm DFG\ alone})$  (> 0: DFG alone needs less)")
    bx.set_title("(b) v3 and lowdeg against DFG alone", loc="left")
    bx.legend(loc="upper left", bbox_to_anchor=(-0.02, -0.17), ncol=2, handletextpad=0.3, columnspacing=1.2, fontsize=6.5)
    data = dict(source="study/part11/RESULTS.json via make_tables.toy()", counts_panel_a=counts,
                panel_a=[{k: p[k] for k in ("suite", "target", "group", "dfg", "nets_best")} for p in P if p["group"] != "nonets"],
                panel_b=pts, never_both=nev2,
                four_x_less=sum(1 for p in P if p["group"] != "nonets" and MT.l2r(p["dfg"], p["nets_best"]) <= -2.0))
    save(fig, "fig_nstar", data)


# ---- fig_dscale ---------------------------------------------------------------------------------------------------------------
K_TEST, DELTA = 4, 0.1                                         # dfg13.py defaults: K = 4 in the first round, delta = 0.1, c = 1
PAR_K = {"par2": 2, "par3": 3, "par4": 4}
NGRID = [2 ** k for k in range(4, 15)]                         # the n-grid 16 .. 16384 (discrete_learner/harness.NS)


def n_thr(k, d):
    """Training-set size above which DFG's degree-k test, |mean(r chi_S)| > s sqrt(2 ln(4 K C(d, k) / delta) / n), passes for
    a character with |mean(r chi_S)| = s (a k-parity on the first round's residual, up to the factor sqrt(1 - mean(y)^2))."""
    return 2.0 * math.log(4 * K_TEST * math.comb(d, k) / DELTA)


@figure
def fig_dscale():
    Q = R["q4_dscale"]; D = [15, 30, 60, 120]
    fig, axs = plt.subplots(2, 4, figsize=(TEXTW, 3.55), sharex=True, sharey=True)
    out = dict(source="study/part11/RESULTS.json q4_dscale", K=K_TEST, delta=DELTA, c=1.0, targets={})
    for ax, t in zip(axs.flat, Q["targets"]):
        p = Q["per_target"][t]
        for key, col, mk, ls, name in (("dfg13", COL[0], "o", "-", "DFG v1.3 alone"), ("nets", COL[1], "s", "--", "networks (nets)")):
            xy = [(d, num(p[key].get(str(d)))) for d in D if p[key].get(str(d)) is not None]
            xf = [d for d, v in xy if fin(v)]; yf = [v for d, v in xy if fin(v)]
            ax.plot(xf, yf, color=col, marker=mk, ls=ls, lw=1.3, ms=4.0, mfc=col, mec="white", mew=0.4, label=name, zorder=3)
            nev = [d for d, v in xy if not fin(v)]
            if nev:
                ax.plot(nev, [2.2e4] * len(nev), color=col, marker="x", ls="", ms=4, zorder=3)
        rec = dict(dfg13={d: num(p["dfg13"].get(str(d))) for d in D}, nets={d: num(p["nets"].get(str(d))) for d in D},
                   exponent_dfg13=p["exponent_dfg13"], exponent_nets=p["exponent_nets"], common_d=p["common_d"])
        if t in PAR_K:
            k = PAR_K[t]; dd = np.arange(15, 121)
            ax.plot(dd, [n_thr(k, int(d)) for d in dd], color="#7a7a7a", lw=0.9, ls=":", zorder=2, label="union-bound line $n_{thr}(k,d)$")
            rec["n_thr"] = {d: n_thr(k, d) for d in D}
            rec["first_grid_point_above"] = {d: min(n for n in NGRID if n > n_thr(k, d)) for d in D}
        out["targets"][t] = rec
        star = "" if len(p["common_d"]) == 4 else "*"
        ax.set_title(f"{t}: {p['exponent_dfg13']:.2f} vs {p['exponent_nets']:.2f}{star}", fontsize=7.2, loc="left")
    for ax in axs.flat:
        ax.set_xscale("log"); ax.set_yscale("log")
        ax.set_xlim(12.5, 145); ax.set_ylim(11, 3.2e4)
        ax.set_xticks(D); ax.set_xticklabels([str(d) for d in D]); ax.xaxis.set_minor_locator(matplotlib.ticker.NullLocator())
        ax.set_yticks([16, 64, 256, 1024, 4096, 16384]); ax.set_yticklabels(["16", "64", "256", "1024", "4096", "16384"])
        ax.yaxis.set_minor_locator(matplotlib.ticker.FixedLocator([32, 128, 512, 2048, 8192]))
        ax.grid(True, which="minor", color=GRID, lw=0.3)
    for ax in axs[1]:
        ax.set_xlabel("input dimension $d$")
    for ax in axs[:, 0]:
        ax.set_ylabel(r"$n^*$")
    lg = axs.flat[7]; lg.axis("off")
    h = [Line2D([], [], color=COL[0], marker="o", ls="-", mfc=COL[0], mec="white", label="DFG v1.3 alone"),
         Line2D([], [], color=COL[1], marker="s", ls="--", mfc=COL[1], mec="white", label="networks (nets,\nsquare loss)"),
         Line2D([], [], color="#7a7a7a", ls=":", lw=0.9, label="parities: union-bound\nline $n_{\\rm thr}(k,d)$")]
    lg.legend(handles=h, loc="center left", bbox_to_anchor=(-0.05, 0.62), fontsize=6.6, handlelength=2.4, labelspacing=0.9)
    lg.text(-0.02, 0.12, "panel title: target: fitted\nexponent DFG vs networks\n(* fitted on d = 15–60)", fontsize=6.3,
            color=INK2, transform=lg.transAxes, va="bottom", ha="left")
    fig.tight_layout(h_pad=0.6, w_pad=0.4)
    save(fig, "fig_dscale", out)


if __name__ == "__main__":
    names = sys.argv[1:] or list(FIGURES)
    for nm in names:
        FIGURES[nm]()

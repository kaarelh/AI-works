"""Figures of the learner paper (paper_learner/), read from the study's result files and from
study/part10/LEARNER_RESULTS.json (written by study/part10/compare_learner.py; regenerate that first).
usage: python3 make_figures.py            all figures
       python3 make_figures.py NAME ...   only these (function names below)

One function per figure, registered with @figure; each writes figures/<name>.pdf (and, where the text quotes derived
numbers, figures/<name>.json with the plotted points and those numbers).

  fig_toy_nstar   v3's n* against nets_best's n* for every target of every toy suite with network references
                  (LEARNER_RESULTS.json "toy" -> per_target: v3 = p10_sum-perm, nets_best = per-target minimum over the
                  network variants present on that suite); log-log, identity and 4x lines, "never" drawn at the edge,
                  dlheld7 highlighted.  The .json adds the suite / status-group summaries quoted in
                  sections/results_toy.tex (with compare_hybrid.toy_summary's definitions).
"""
import os, sys, json, math
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D

HERE = os.path.dirname(os.path.abspath(__file__))
STUDY = os.path.join(os.path.dirname(HERE), "study")
FIG = os.path.join(HERE, "figures"); os.makedirs(FIG, exist_ok=True)
LR = os.path.join(STUDY, "part10", "LEARNER_RESULTS.json")

# ---- style (as in paper_discrete/make_figures.py) -----------------------------------------------------------------------
COL = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4", "#008300", "#6250d6", "#e34948"]
INK, INK2, GRID = "#1a1a1a", "#4a4a4a", "#e3e3e3"
plt.rcParams.update({
    "font.family": "DejaVu Sans", "font.size": 8, "axes.titlesize": 8.5, "axes.labelsize": 8, "xtick.labelsize": 7.5,
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


def save(fig, name):
    p = os.path.join(FIG, name)
    fig.savefig(p, bbox_inches="tight", pad_inches=0.03)
    plt.close(fig)
    print("wrote", p)


def load_lr():
    return json.load(open(LR))                                # json reads the stored Infinity ("never") as inf


def fnum(v):
    """n* from LEARNER_RESULTS.json: float (inf = never reaches 10% by n = 16384) or None (not run)."""
    return None if v is None else float(v)


# ---- n* comparisons with compare_hybrid's definitions (l2r, toy_summary), restated here so this file runs alone ----------
def l2r(a, b):
    if math.isfinite(a) and math.isfinite(b):
        return math.log2(a / b)
    return math.inf if math.isfinite(b) else (-math.inf if math.isfinite(a) else math.nan)


def summary(pairs):
    """pairs: [(learner n*, reference n*)] over the targets both were run on.  Mean log2 ratio over the targets both
    learn; clearly better / worse: log2 ratio < -0.25 / > +0.25, or only one side reaches 10% error."""
    r = [l2r(a, b) for a, b in pairs]
    fin = [x for x in r if math.isfinite(x)]
    return dict(targets=len(r), both_learn=len(fin), mean=float(np.mean(fin)) if fin else None,
                better=sum(1 for x in r if x < -0.25), worse=sum(1 for x in r if x > 0.25),
                neither=sum(1 for x in r if math.isnan(x)), four_x=sum(1 for x in r if x <= -2.0))


# ---- fig_toy_nstar ----------------------------------------------------------------------------------------------------------
TOY_GROUPS = [   # (key, suites, legend label, marker, face, edge, size, z) -- status of each suite for v3 (protocol.tex, tab:status)
    ("dev", ["designed", "dlsymdev"], "development", "o", "white", "#8a8a8a", 20, 2),
    ("earlier", ["random", "dlheld", "dlheld2", "dlheld3", "dlheld4", "dlheld5"],
     "held out for v1 or v2;\ndevelopment data in Part 10", "o", COL[0], "white", 22, 3),
    ("dlheld6", ["dlheld6"], "held out in Part 9;\nused by the Part 10 toy builder", "D", COL[3], INK2, 22, 4),
    ("dlheld7", ["dlheld7"], "held out for v3", "s", COL[7], INK, 40, 5),
]
NETS = ("nets", "nets_wd", "nets_cewd", "nets_cewd0.3", "nets_cewd1.0")


def toy_points(J):
    """Every (suite, target) of a suite with network references: v3, nets_best, lin, hgb, v2 and each variant."""
    P = []
    for key, suites, *_ in TOY_GROUPS:
        for su in suites:
            r = J["toy"].get(su)
            if not r or not r.get("variants"):
                continue
            for t, v in sorted(r["per_target"].items()):
                if v.get("nets_best") is None or v.get("v3") is None:
                    continue
                P.append(dict(group=key, suite=su, target=t, v3=fnum(v["v3"]), nets_best=fnum(v["nets_best"]),
                              v2=fnum(v.get("v2")), lin=fnum(v.get("lin")), hgb=fnum(v.get("hgb")),
                              **{k: fnum(v.get(k)) for k in NETS if k in v}))
    return P


def toy_numbers(J, P):
    """The summaries quoted in sections/results_toy.tex."""
    out = dict(source=os.path.relpath(LR, HERE), groups={}, suites={}, dlheld7={}, heldout_pooled={})
    for key, suites, *_ in TOY_GROUPS:
        Q = [p for p in P if p["group"] == key]
        out["groups"][key] = dict(suites=sorted({p["suite"] for p in Q}), **summary([(p["v3"], p["nets_best"]) for p in Q]))
    for su in sorted({p["suite"] for p in P}):
        Q = [p for p in P if p["suite"] == su]
        out["suites"][su] = summary([(p["v3"], p["nets_best"]) for p in Q])
        # nets_wd is the one variant run on every suite, so it is the comparable reference across suites
        out["suites"][su]["vs_nets_wd"] = summary([(p["v3"], p["nets_wd"]) for p in Q if p.get("nets_wd") is not None])
        out["suites"][su]["variants"] = [k for k in NETS if any(p.get(k) is not None for p in Q)]
    # dlheld7: each network variant on its own, and the targets on which a calibration reference (lin or hgb) is already
    # clearly better than nets_best (wins that need no feature search)
    Q = [p for p in P if p["suite"] == "dlheld7"]
    for k in NETS:
        pr = [(p["v3"], p[k]) for p in Q if p.get(k) is not None]
        if pr:
            out["dlheld7"][f"v3_vs_{k}"] = summary(pr)
    for k in ("lin", "hgb"):
        pr = [(p[k], p["nets_best"]) for p in Q if p.get(k) is not None]
        out["dlheld7"][f"{k}_vs_nets_best"] = summary(pr)
    easy = lambda p: any(p.get(k) is not None and l2r(p[k], p["nets_best"]) < -0.25 for k in ("lin", "hgb"))
    out["dlheld7"]["calibration_wins"] = sorted(p["target"] for p in Q if easy(p))
    out["dlheld7"]["v3_vs_nets_best_rest"] = summary([(p["v3"], p["nets_best"]) for p in Q if not easy(p)])
    out["dlheld7"]["v3_vs_best_calibration"] = summary([(p["v3"], min(p["lin"], p["hgb"])) for p in Q
                                                         if p.get("lin") is not None and p.get("hgb") is not None])
    # pooled over the held-out suites present (most are in-sample for v3: only dlheld7 is untouched)
    H = [p for p in P if p["suite"].startswith("dlheld")]
    out["heldout_pooled"] = dict(suites=sorted({p["suite"] for p in H}), all=summary([(p["v3"], p["nets_best"]) for p in H]),
                                 rest=summary([(p["v3"], p["nets_best"]) for p in H if not easy(p)]),
                                 calibration_wins=sum(1 for p in H if easy(p)),
                                 not_better=sorted(f"{p['suite']}/{p['target']}" for p in H if not l2r(p["v3"], p["nets_best"]) < -0.25))
    out["all_plotted"] = dict(**summary([(p["v3"], p["nets_best"]) for p in P]),
                              not_better=sorted(f"{p['suite']}/{p['target']}" for p in P if not l2r(p["v3"], p["nets_best"]) < -0.25))
    return out


@figure
def fig_toy_nstar():
    J = load_lr(); P = toy_points(J)
    lo, hi, NEV = 10, 4.6e4, 2.8e4                                     # "never" (no 10% error by n = 16384) drawn at NEV
    pos = lambda v: NEV if not math.isfinite(v) else v
    fig, ax = plt.subplots(figsize=(TEXTW, 4.3))
    g = np.array([lo, hi])
    ax.plot(g, g, color=INK2, lw=0.9, ls="--", zorder=1)
    ax.plot(g, g / 4, color="#9a9a9a", lw=0.8, ls=":", zorder=1)
    ax.text(1.25e4, 1.25e4 * 0.72, "equal data", fontsize=6.5, color=INK2, ha="right", va="top", rotation=45, rotation_mode="anchor")
    ax.text(1.25e4, 1.25e4 / 4 * 0.72, "4x less data", fontsize=6.5, color=INK2, ha="right", va="top", rotation=45, rotation_mode="anchor")
    ax.axhline(NEV, color="#c4c4c4", lw=0.6, zorder=0); ax.axvline(NEV, color="#c4c4c4", lw=0.6, zorder=0)   # the "never" edges
    ax.text(lo * 1.12, NEV * 0.86, "never", fontsize=6.5, color=INK2, va="top", ha="left")
    ax.text(NEV * 0.86, lo * 1.12, "never", fontsize=6.5, color=INK2, va="bottom", ha="right", rotation=90)
    handles = []
    for key, suites, lab, mk, fc, ec, s, z in TOY_GROUPS:
        Q = [p for p in P if p["group"] == key]
        if not Q:
            continue
        x = [pos(p["nets_best"]) for p in Q]; y = [pos(p["v3"]) for p in Q]
        ax.scatter(x, y, s=s, marker=mk, facecolor=fc, edgecolor=ec, linewidth=0.8 if key != "earlier" else 0.4, zorder=z,
                   alpha=0.95)
        present = [su for su in suites if any(p["suite"] == su for p in Q)]
        handles.append(Line2D([], [], marker=mk, ls="", mfc=fc, mec=ec, mew=0.8, ms=math.sqrt(s) + 1.0,
                              label=f"{', '.join(present)} ({len(Q)})\n{lab}"))
    # the targets named in the text
    lab = {p["target"]: p for p in P}
    def note(t, txt, dx, dy, ha="right"):
        if t in lab:
            p = lab[t]
            ax.annotate(txt, (pos(p["nets_best"]), pos(p["v3"])), xytext=(dx, dy), textcoords="offset points", fontsize=6.5,
                        color=INK, ha=ha, va="center", arrowprops=dict(arrowstyle="-", color=INK2, lw=0.5, shrinkA=0, shrinkB=3))
    note("f7_01", "f7_01", -16, 12)
    note("f7_10", "f7_10", -18, 4)
    note("f7_00", "f7_00", 12, -10, ha="left")
    note("h5s7", "h5s7", -14, 10)
    note("h6_00", "h6_00: v3 never, nets_best 12304", -14, -11)
    nev2 = [p["target"] for p in P if not math.isfinite(p["v3"]) and not math.isfinite(p["nets_best"])]
    if nev2:
        ax.annotate(", ".join(nev2) + ": no learner reaches 10%", (NEV, NEV), xytext=(-10, 8), textcoords="offset points", fontsize=6.5,
                    color=INK, ha="right", va="center", arrowprops=dict(arrowstyle="-", color=INK2, lw=0.5, shrinkA=0, shrinkB=3))
    ax.set_xscale("log"); ax.set_yscale("log"); ax.set_xlim(lo, hi); ax.set_ylim(lo, hi); ax.set_aspect("equal")
    ax.set_xlabel(r"$n^*$ of nets_best (per-target best network variant on the suite)")
    ax.set_ylabel(r"$n^*$ of v3 (hyb_portfolio3), inputs permuted per fit")
    ax.legend(handles=handles, loc="upper left", bbox_to_anchor=(1.03, 1.0), handletextpad=0.4, borderaxespad=0.0,
              labelspacing=1.0, fontsize=7, title="suites by status for v3\n(targets plotted)", title_fontsize=7,
              alignment="left")
    fig.tight_layout()
    save(fig, "fig_toy_nstar.pdf")
    N = toy_numbers(J, P); N["points"] = P
    json.dump(N, open(os.path.join(FIG, "fig_toy_nstar.json"), "w"), indent=1)    # "never" is stored as Infinity
    print(json.dumps({k: v for k, v in N.items() if k != "points"}, default=str))


if __name__ == "__main__":
    names = sys.argv[1:] or list(FIGURES)
    for nm in names:
        FIGURES[nm]()

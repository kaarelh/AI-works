"""Figures and tables of the interpretability section (sections/interp.tex) of the Part 10 learner paper.

Reads only the frozen outputs of the Part 10 interpretability analysis in study/part10/interp/ (no learner is fitted):
  tables/toy_timing.csv                       per-target timing of the 54 sum-structured toy targets (seed 0)
  results/toy_final/power/*.json              DFG's block test on the true block, Fourier weight by degree
  results/toy_final/toy_landscape/*.json      the test statistic around the true block
  results/toy_final/v3/*.json                 v3's structure runs (stored g lists)
  results/toy_final/toy_g/v3/*.json           refits split by the second term tau
  results/image_final/v3/*.{json,npz}         v3's instrumented image fits (seed 0)
and applies the corrections of the two independent verifications in study/part10/interp/VERIFICATION.json:
  * detection points (n_detect) of the seven gate / multiplexer mixtures, recomputed by the reading verifier with the
    modulated statistic on the residual deflated by [1, chi_M], as DFG tests it (verify-reading:toy, claim C4);
  * pooling-set locality counted over the k - 1 members other than the centre (verify-reading:image, C1);
  * gain shares put next to column shares (verify-reading:image, other problem 0).
Writes figures/fig_toy_timing.pdf, fig_toy_g.pdf, fig_toy_failures.pdf, fig_img_grid.pdf, fig_img_contrib.pdf,
tables/tab_interp_toy.tex, tab_interp_img_geom.tex, tab_interp_img_stack.tex, tab_interp_img_gain.tex, and the plotted /
tabulated values in figures/fig_interp.json.
usage: OMP_NUM_THREADS=1 nice -n 5 python3 make_interp.py"""
import os, csv, json, ast, math, numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from matplotlib.patches import Patch
from scipy.spatial import procrustes
from scipy.stats import spearmanr

HERE = os.path.dirname(os.path.abspath(__file__))
INTERP = os.path.join(os.path.dirname(HERE), "study", "part10", "interp")
TOY = os.path.join(INTERP, "results", "toy_final")
IMG = os.path.join(INTERP, "results", "image_final")
FIG, TAB = os.path.join(HERE, "figures"), os.path.join(HERE, "tables")
os.makedirs(FIG, exist_ok=True); os.makedirs(TAB, exist_ok=True)
plt.rcParams.update({"font.size": 7.5, "axes.titlesize": 7.5, "axes.labelsize": 7.5, "legend.fontsize": 6.5,
                     "xtick.labelsize": 6.5, "ytick.labelsize": 6.5, "pdf.fonttype": 42, "axes.linewidth": 0.6})
W = 6.5                                                   # text width, inches
OUT = {}                                                  # every plotted / tabulated value -> figures/fig_interp.json


def lit(v):
    """toy_g and landscape files store some values as Python literals in strings."""
    if isinstance(v, str):
        try:
            return ast.literal_eval(v)
        except (ValueError, SyntaxError):
            return v
    return v


def save(fig, name):
    fig.savefig(os.path.join(FIG, name)); plt.close(fig)


def l2(x):
    return math.log2(x)


# ===================================================================================================== toy: timing
# Corrected detection points (VERIFICATION.json, verify-reading:toy, C4): toy_power.py's modulated statistic used the
# un-deflated, uncentred residual and so counted the modulator character's own signal.  Recomputed as DFG tests it:
#   fd_11 128 -> 256, h5s4 128 -> 256, f7_03 128 -> 512, f7_11 128 -> 1024, h6_07 256 -> 512;
#   fd_08 512 -> 2048 and majsym 256 -> 512 (their modulated statistic never passes; the plain block passes there).
NDETECT_CORR = {"fd_11": 256, "h5s4": 256, "f7_03": 512, "f7_11": 1024, "h6_07": 512, "fd_08": 2048, "majsym": 512}
NEVER = 2 ** 15
rows = list(csv.DictReader(open(os.path.join(INTERP, "tables", "toy_timing.csv"))))
for r in rows:
    r["nd0"] = int(r["n_detect"]); r["nd"] = NDETECT_CORR.get(r["target"], r["nd0"])
    r["ns"] = int(r["n_struct"]) if r["n_struct"] else None
    r["low"] = float(r["low2"]); r["ns0"] = float(r["nstar_s0"]); r["ns3"] = float(r["nstar3"])
    r["kinds"] = set(r["kind"].split("+"))
pure = [r for r in rows if r["mixture"] == "pure"]
assert len(rows) == 54 and len(pure) == 25


def delay(r):
    return l2((r["ns"] or NEVER) / r["nd"])


def summ(sel):
    found = [r for r in sel if r["ns"]]
    d = [l2(r["ns"] / r["nd"]) for r in found]
    return dict(targets=len(sel), found=len(found), never=[r["target"] for r in sel if not r["ns"]],
                median_n_struct=float(np.median([r["ns"] for r in found])) if found else None,
                n_struct_range=[min(r["ns"] for r in found), max(r["ns"] for r in found)] if found else None,
                detect_at_128=sum(r["nd"] <= 128 for r in sel), median_delay=float(np.median(d)) if d else None,
                delay_earlier=sum(x < 0 for x in d), delay_0=sum(x == 0 for x in d), delay_1=sum(x == 1 for x in d),
                delay_2plus=sum(x >= 2 for x in d))


MIX = [("pure", "pure symmetric"), ("parity", "with a parity"), ("gate", "with a gate"), ("mux", "multiplexer"),
       ("two sums", "two sums"), ("weighted", "weighted sum")]
KINDS = [("threshold", "threshold"), ("band", "band"), ("interval", "interval"), ("arbitrary", "arbitrary set"), ("modular", "residue class")]
T = {"by_mixture": {m: summ([r for r in rows if r["mixture"] == m]) for m, _ in MIX},
     "by_kind": {k: summ([r for r in rows if k in r["kinds"]]) for k, _ in KINDS}, "all": summ(rows)}
rho_p, p_p = spearmanr([delay(r) for r in pure], [r["low"] for r in pure])
fp = [r for r in pure if r["ns"]]
rho_pf, p_pf = spearmanr([delay(r) for r in fp], [r["low"] for r in fp])
rho_a, p_a = spearmanr([delay(r) for r in rows], [r["low"] for r in rows])
rho_a0, p_a0 = spearmanr([l2((r["ns"] or NEVER) / r["nd0"]) for r in rows], [r["low"] for r in rows])
lns = [l2(r["ns0"] / r["ns"]) for r in rows if r["ns"]]
T["spearman"] = dict(pure=[rho_p, p_p], pure_found=[rho_pf, p_pf], all54_corrected=[rho_a, p_a], all54_as_published=[rho_a0, p_a0])
T["nstar0_vs_nstruct"] = dict(n=len(lns), in_minus1_0=sum(-1 < x <= 0 for x in lns), le_minus1=sum(x <= -1 for x in lns), max=max(lns),
                              le_minus1_targets=[r["target"] for r in rows if r["ns"] and l2(r["ns0"] / r["ns"]) <= -1],
                              pure_in_minus1_0=sum(-1 < l2(r["ns0"] / r["ns"]) <= 0 for r in fp), pure_found=len(fp))
OUT["toy_timing"] = T


def fmt_n(v):
    return "--" if v is None else (f"{v:.0f}" if v == int(v) else f"{v:.0f}")


def tex_row(lab, s):
    rng = "--" if not s["n_struct_range"] else f"{s['n_struct_range'][0]}--{s['n_struct_range'][1]}"
    nev = ", ".join(t.replace("_", "\\_") for t in s["never"]) or "--"
    return (f"{lab} & {s['targets']} & {s['found']} & {fmt_n(s['median_n_struct'])} & {rng} & {s['detect_at_128']} & "
            f"{s['delay_earlier']} / {s['delay_0']} / {s['delay_1']} / {s['delay_2plus']} & {nev}\\\\")


lines = ["\\begin{tabularx}{\\linewidth}{lrrrrrc>{\\raggedright\\arraybackslash}X}", "\\toprule",
         " & targets & \\hd{exact\\\\structure} & \\hd{median\\\\$n_{\\rm struct}$} & \\hd{range of\\\\$n_{\\rm struct}$} & "
         "\\hd{detectable\\\\at $n=128$} & \\hd{delay (doublings)\\\\$<0$ / 0 / 1 / $\\ge2$} & never found\\\\", "\\midrule",
         "\\multicolumn{8}{l}{\\emph{by mixture}}\\\\"]
lines += [tex_row(lab, T["by_mixture"][m]) for m, lab in MIX]
lines += ["\\addlinespace", "\\multicolumn{8}{l}{\\emph{by accept set} (a two-block target counts once under each kind it has)}\\\\"]
lines += [tex_row(lab, T["by_kind"][k]) for k, lab in KINDS]
lines += ["\\addlinespace", tex_row("all", T["all"]), "\\bottomrule", "\\end{tabularx}"]
open(os.path.join(TAB, "tab_interp_toy.tex"), "w").write("\n".join(lines) + "\n")

# ---------------------------------------------------------------------------------------------- fig_toy_timing
fig = plt.figure(figsize=(W, 3.75))
gs = fig.add_gridspec(1, 2, width_ratios=[1.08, 1], wspace=0.27, left=0.115, right=0.985, top=0.9, bottom=0.125)
ax = fig.add_subplot(gs[0, 0])
P = sorted(pure, key=lambda r: -r["low"])
X = lambda n: l2(min(n, NEVER))
for i, r in enumerate(P):
    y = len(P) - 1 - i
    ax.plot([X(r["nd"]), X(r["ns"] or NEVER)], [y, y], "-", color="#bbbbbb", lw=2.2, zorder=1, solid_capstyle="butt")
    ax.plot(X(r["nd"]), y, "o", mfc="white", mec="k", ms=4.2, mew=0.8, zorder=3)
    if r["ns"]:
        ax.plot(X(r["ns"]), y, "s", color="#1f77b4", ms=4.2, zorder=3)
    else:
        ax.plot(X(NEVER), y, "s", mfc="white", mec="#1f77b4", ms=4.2, zorder=3)
    ns0 = r["ns0"] if math.isfinite(r["ns0"]) else NEVER
    ax.plot(X(ns0), y, "D", color="#d62728", ms=2.8, zorder=4)
ax.set_yticks(range(len(P))); ax.set_yticklabels([f"{r['target']}  {r['low']:.2f}" for r in P][::-1], fontsize=5.8)
ax.set_xticks(range(4, 16)); ax.set_xticklabels([f"$2^{{{k}}}$" for k in range(4, 15)] + ["never"], fontsize=6.2)
ax.axvline(14.5, color="#999", lw=0.5, ls=":")
ax.set_xlim(3.6, 15.4); ax.set_ylim(-0.7, len(P) - 0.3)
ax.set_xlabel("training-set size $n$ (seed 0)")
ax.set_title("(a) the 25 pure symmetric targets, by low-degree share", loc="left")
ax.text(-0.01, 1.005, "low-deg. share", transform=ax.transAxes, ha="right", va="bottom", fontsize=5.6)
h = [Line2D([], [], marker="o", mfc="white", mec="k", ls="", ms=4.2, label="$n_{\\rm detect}$: true block passes the test"),
     Line2D([], [], marker="s", color="#1f77b4", ls="", ms=4.2, label="$n_{\\rm struct}$: exact block in the model"),
     Line2D([], [], marker="D", color="#d62728", ls="", ms=2.8, label="$n^*$: 10% test error")]
ax.legend(handles=h, loc="upper right", frameon=True, framealpha=0.95, edgecolor="none", fontsize=5.8, borderpad=0.3, handletextpad=0.3)
ax.grid(axis="x", color="#eeeeee", lw=0.5); ax.set_axisbelow(True)
# (b) delay vs low-degree share, all 54 (mixtures with the corrected detection points)
ax = fig.add_subplot(gs[0, 1]); FL = 1e-4
MK = {"pure": ("o", "#1f77b4", True), "parity": ("^", "#2ca02c", False), "gate": ("v", "#9467bd", False),
      "mux": ("D", "#d62728", False), "two sums": ("P", "#8c564b", False), "weighted": ("*", "#ff7f0e", False)}
for m, lab in MIX:
    sel = [r for r in rows if r["mixture"] == m]; mk, c, filled = MK[m]
    ax.plot([max(r["low"], FL) for r in sel], [delay(r) if r["ns"] else l2(NEVER / 128) for r in sel], mk, ms=4.6 if mk != "*" else 6, ls="",
            mfc=c if filled else "white", mec=c, mew=0.9, alpha=0.9, label=f"{lab} ({len(sel)})", zorder=3 if filled else 2)
ax.set_xscale("log"); ax.set_xlim(6e-5, 1.0)
ax.set_xticks([1e-4, 1e-3, 1e-2, 1e-1, 1]); ax.set_xticklabels(["$\\leq 10^{-4}$", "$10^{-3}$", "$10^{-2}$", "$10^{-1}$", "1"])
dmax = l2(NEVER / 128)
ax.set_yticks([-2, -1, 0, 1, 2, 3, 4, 5, 6, dmax]); ax.set_yticklabels(["-2", "-1", "0", "1", "2", "3", "4", "5", "6", "never"])
ax.axhline(dmax - 0.5, color="#999", lw=0.5, ls=":"); ax.axhline(0, color="#999", lw=0.5)
ax.set_ylim(-2.6, dmax + 0.6)
ax.set_xlabel("low-degree share $(W_1+W_2)/(1-W_0)$")
ax.set_ylabel("$\\log_2(n_{\\rm struct}/n_{\\rm detect})$")
ax.set_title("(b) search delay against low-degree signal", loc="left")
ax.text(0.03, 0.80, f"pure: Spearman $\\rho={rho_p:.2f}$\nall 54: $\\rho={rho_a:.2f}$", transform=ax.transAxes, ha="left", va="top", fontsize=6.2)
ax.legend(loc="lower left", fontsize=5.8, frameon=True, framealpha=0.95, edgecolor="none", ncol=2, columnspacing=0.6,
          handletextpad=0.2, borderpad=0.3)
ax.grid(color="#eeeeee", lw=0.5); ax.set_axisbelow(True)
save(fig, "fig_toy_timing.pdf")
OUT["fig_toy_timing"] = [dict(target=r["target"], suite=r["suite"], mixture=r["mixture"], low2=r["low"], n_detect=r["nd"],
                              n_detect_as_published=r["nd0"], n_struct=r["ns"], nstar_s0=r["ns0"], nstar3=r["ns3"]) for r in rows]

# ===================================================================================================== toy: g plots
PICKS = [("dlheld4", "tail13", 256, "band $[|t|\\geq5]$"), ("dlheld6", "h6_11", 128, "interval $[t=1]$"),
         ("dlheld6", "h6_01", 512, "arbitrary set, signed"), ("dlheld7", "f7_01", 256, "threshold $[t\\leq1]$"),
         ("dlheld6", "h6_10", 256, "$[|t-3x_{13}|>1]$, $\\tau=x_{13}$", "tau"), ("dlheld6", "h6_10", 512, "$[|t-3x_{13}|>1]$, $\\tau=x_{13}$", "tau"),
         ("dlheld7", "f7_10", 256, "$[t+2x_6\\leq-1]$, $\\tau=x_6$", "tau"), ("dlheld7", "f7_09", 256, "$[t\\leq0]\\,x_{11}x_{12}$, $\\tau=x_{11}x_{12}$", "tau")]
fig, axs = plt.subplots(2, 4, figsize=(W, 3.45), squeeze=False); OUT["fig_toy_g"] = []
for ax, pk in zip(axs.ravel(), PICKS):
    su, tg, n, title = pk[:4]
    if len(pk) == 4:
        R = json.load(open(os.path.join(TOY, "v3", f"{su}__{tg}__s0.json")))
        c = next(x for x in R["cells"] if x["n"] == n); g = np.array(c["classes"][0]["g"], float); keep = g[:, 1] >= 5
        ax.bar(g[keep, 0], g[keep, 2], width=1.4, color="#cccccc")
        ax.plot(g[keep, 0], g[keep, 3], "o-", ms=2.6, lw=0.8, color="#d62728")
        agree = float(np.sum(g[:, 1] * (np.sign(g[:, 3]) == np.sign(g[:, 2]))) / g[:, 1].sum())
        err = c["err_dfg"]
    else:
        J = {k: lit(v) for k, v in json.load(open(os.path.join(TOY, "toy_g", "v3", f"{su}__{tg}__n{n}.json"))).items()}
        g = np.array(J["rows"], float); keep = g[:, 2] >= 5
        for tv, colr in ((1.0, "#1f77b4"), (-1.0, "#ff7f0e")):
            m = keep & (g[:, 1] == tv); o = np.argsort(g[m, 0])
            ax.step(g[m, 0][o], g[m, 3][o], where="mid", color=colr, lw=0.8, alpha=0.6)
            ax.plot(g[m, 0][o], g[m, 4][o], "o", ms=2.6, color=colr)
        agree = float(np.sum(g[:, 2] * (np.sign(g[:, 4]) == np.sign(g[:, 3]))) / g[:, 2].sum())
        err = J["err_dfg"]
    OUT["fig_toy_g"].append(dict(suite=su, target=tg, n=n, err_dfg=err, agree_all_levels=agree,
                                 dropped_points=int(np.sum((g[:, 1] if len(pk) == 4 else g[:, 2])[~keep]))))
    ax.set_title(f"{tg}, $n={n}$\n{title}", fontsize=6.4, linespacing=1.25); ax.axhline(0, color="#888", lw=0.4)
    ax.set_ylim(-1.6, 1.6); ax.tick_params(labelsize=6)
    ax.text(0.03, 0.04, f"DFG err {err:.3f}", transform=ax.transAxes, fontsize=5.6, color="#444")
for ax in axs[1]:
    ax.set_xlabel("$t$ = true signed sum", fontsize=6.6)
h = [Patch(color="#cccccc", label="$E[f\\mid t]$ (truth)"), Line2D([], [], color="#d62728", marker="o", ms=2.6, lw=0.8, label="mean DFG output"),
     Line2D([], [], color="#1f77b4", lw=0.8, alpha=0.6, label="$\\tau=+1$: truth"), Line2D([], [], color="#1f77b4", marker="o", ls="", ms=2.6, label="$\\tau=+1$: DFG"),
     Line2D([], [], color="#ff7f0e", lw=0.8, alpha=0.6, label="$\\tau=-1$: truth"), Line2D([], [], color="#ff7f0e", marker="o", ls="", ms=2.6, label="$\\tau=-1$: DFG")]
fig.legend(handles=h, loc="lower center", ncol=6, fontsize=6, frameon=False)
fig.tight_layout(rect=(0, 0.06, 1, 1), h_pad=0.6, w_pad=0.4)
save(fig, "fig_toy_g.pdf")

# ===================================================================================================== toy: failures
fig = plt.figure(figsize=(W, 2.35))
gs = fig.add_gridspec(1, 3, width_ratios=[1, 1.35, 1], wspace=0.34, left=0.075, right=0.99, top=0.88, bottom=0.25)
MOD3 = [("dlfamdev", "fd_10", "#1f77b4"), ("dlheld6", "h6_00", "#ff7f0e"), ("dlheld7", "f7_05", "#2ca02c")]
LATE = [("dlsymdev", "band11", "#7f7f7f"), ("dlheld5", "h5s7", "#9467bd")]
EASY = [("dlheld4", "tail13", "#8c564b")]
PW = {t: json.load(open(os.path.join(TOY, "power", f"{s}__{t}.json"))) for s, t, _ in MOD3 + LATE + EASY}
OUT["fig_toy_failures"] = {"power": {}, "landscape": {}, "fourier": {}}
from scipy.stats import hypergeom


def chance_best_of_two(k, d=30):
    """Expected fraction of S among the first |S| = k of two independent random orders, the better of the two."""
    pm = hypergeom(d, k, k).pmf(np.arange(k + 1)); cdf = np.cumsum(pm)
    pmax = cdf ** 2 - np.concatenate([[0.0], cdf[:-1]]) ** 2
    return float(np.arange(k + 1) @ pmax / k)


ax = fig.add_subplot(gs[0, 0])
for s, t, c in MOD3 + LATE:
    cl = PW[t]["cells"]; ns = [x["n"] for x in cl]; rr = [max(x["search"]["eig"]) for x in cl]
    ax.plot(ns, rr, "-" if (s, t, c) in MOD3 else "--", marker="o", ms=2.2, lw=0.9, color=c, label=t)
    ch = chance_best_of_two(PW[t]["k"])
    if (s, t, c) in MOD3:
        ax.plot([2 ** 14 * 1.25], [ch], "<", color=c, ms=4, clip_on=False)
    OUT["fig_toy_failures"]["power"][t] = dict(n=ns, reach_eig_best_of_2=rr, chance=ch, k=PW[t]["k"],
                                               ratio=[max(x["unfold"]["ratio"], x["fold"]["ratio"]) for x in cl])
ax.set_xscale("log", base=2); ax.set_xticks([2 ** k for k in (4, 6, 8, 10, 12, 14)]); ax.set_ylim(0, 1.05)
ax.set_xlabel("$n$ (seed-0 training rows)"); ax.set_ylabel("fraction of $S$ in the first $|S|$")
ax.set_title("(a) does the search order reach $S$?", loc="left")
hh, ll = ax.get_legend_handles_labels(); hh.append(Line2D([], [], ls=":", marker="o", ms=2.2, lw=0.9, color="#8c564b")); ll.append("tail13")
ax.legend(hh, ll, fontsize=5.6, frameon=False, loc="upper left", handlelength=1.6, ncol=2, columnspacing=0.6)
ax = fig.add_subplot(gs[0, 1])
CATS = [("true", "true"), ("drop_1", "$-1$"), ("drop_2", "$-2$"), ("drop_3", "$-3$"), ("drop_4", "$-4$"), ("add_1", "$+1$"), ("add_2", "$+2$"),
        ("flip_1", "flip 1"), ("flip_2", "flip 2"), ("mixed_3", "3 mixed"), ("pairs_in_max", "pair in $S$"),
        ("pairs_out_max", "pair out"), ("random_k", "random")]
for j, (s, t, c) in enumerate(MOD3):
    L = {k: lit(v) for k, v in json.load(open(os.path.join(TOY, "toy_landscape", f"{s}__{t}__n16384.json"))).items()}
    v = [float(L[k]["median"]) if isinstance(L[k], dict) else float(L[k]) for k, _ in CATS]
    ax.plot(np.arange(len(CATS)) + (j - 1) * 0.18, v, "o", ms=3.2, color=c, label=t)
    OUT["fig_toy_failures"]["landscape"][t] = dict(zip([k for k, _ in CATS], v))
ax.axhline(1, color="k", lw=0.6); ax.set_yscale("log"); ax.set_ylim(0.03, 400)
ax.set_xticks(range(len(CATS))); ax.set_xticklabels([lab for _, lab in CATS], rotation=60, ha="right", fontsize=5.9)
for xv in (0.5, 4.5, 6.5, 8.5, 9.5):
    ax.axvline(xv, color="#dddddd", lw=0.5)
ax.set_ylabel("$T$ / threshold ($n=16384$)")
ax.set_title("(b) candidates near the true block", loc="left")
ax = fig.add_subplot(gs[0, 2])
for s, t, c in MOD3 + LATE[1:] + EASY:
    fw = np.array(PW[t]["fourier_by_degree"], float)
    ax.plot(range(1, len(fw)), fw[1:] / (1 - fw[0]), "-" if (s, t, c) in MOD3 else ":", marker="o", ms=2.2, lw=0.9, color=c, label=t)
    OUT["fig_toy_failures"]["fourier"][t] = [float(x) for x in fw]
ax.axvspan(0.5, 2.5, color="#eeeeee", zorder=0); ax.set_ylim(0, 0.5)
ax.annotate("tail13: 0.65", xy=(2, 0.5), xytext=(3.2, 0.46), fontsize=5.6, color="#8c564b",
            arrowprops=dict(arrowstyle="->", color="#8c564b", lw=0.6))
ax.set_xlabel("Fourier degree $|S|$"); ax.set_ylabel("share of Var $f$")
ax.set_xticks([1, 3, 5, 7, 9, 11, 13]); ax.set_xlim(0.5, 14.5)
ax.set_title("(c) where the signal is", loc="left")
save(fig, "fig_toy_failures.pdf")

# ===================================================================================================== images
RUNS = [("qd_dev", 1000), ("qd_dev", 3000), ("qd_dev", 10000), ("qd_a", 10000), ("mnist", 10000), ("fashion_mnist", 10000)]
DSN = {"qd_dev": "\\code{qd_dev}", "qd_a": "\\code{qd_a}", "mnist": "MNIST", "fashion_mnist": "Fashion"}
J, M = {}, {}
for ds, n in RUNS:
    J[(ds, n)] = json.load(open(os.path.join(IMG, "v3", f"{ds}__n{n}__s0.json")))
    M[(ds, n)] = np.load(os.path.join(IMG, "v3", f"{ds}__n{n}__s0.npz"), allow_pickle=True)
J2 = json.load(open(os.path.join(IMG, "v2", "qd_dev__n10000__s0.json")))


def cheb(a, b):
    return np.maximum(np.abs(a // 28 - b // 28), np.abs(a % 28 - b % 28))


def locality(m, k):
    """Members of S_i(k) other than i itself: fraction within 1 and within 2 Chebyshev steps of i; number farther."""
    c = m["pool_centres"].astype(int); mem = m[f"pool{k}_members"].astype(int); d = cheb(mem, c[:, None]); o = mem != c[:, None]
    return float(np.mean(d[o] <= 1)), float(np.mean(d[o] <= 2)), int(np.sum(d[o] > 2))


def bar_geom(PL):
    """Fraction of bars that are an exact straight lattice line (as make_image_final.bar_geom)."""
    st = np.zeros(len(PL), bool)
    for t, row in enumerate(PL):
        px = row[row >= 0]; rr, cc = px // 28, px % 28
        st[t] = bool(np.all(rr == rr[0]) or np.all(cc == cc[0]) or np.all(rr - cc == rr[0] - cc[0]) or np.all(rr + cc == rr[0] + cc[0]))
    return st


G = {}
lines = ["\\begin{tabular}{llrrrrrrrr}", "\\toprule",
         " & & \\multicolumn{4}{c}{pooling sets: members other than $i$} & \\multicolumn{2}{c}{Isomap $R^2$} & \\multicolumn{2}{c}{bars: exact lines}\\\\",
         "\\cmidrule(lr){3-6}\\cmidrule(lr){7-8}\\cmidrule(lr){9-10}",
         "set & $n$ & \\hd{$S_i(4)$\\\\$\\le1$ step} & \\hd{$S_i(9)$\\\\$\\le1$ step} & \\hd{$S_i(9)$\\\\$\\le2$ steps} & \\hd{$S_i(9)$\\\\$>2$ steps} & "
         "\\hd{$k=4$\\\\union} & \\hd{$k=9$\\\\mutual} & $L=2$ & $L=4$\\\\", "\\midrule"]
for ds, n in RUNS:
    m, j = M[(ds, n)], J[(ds, n)]
    a4 = locality(m, 4); a9 = locality(m, 9); a16 = locality(m, 16)
    s2, s4 = bar_geom(m["bars2_pixels"]), bar_geom(m["bars4_pixels"])
    assert abs(s2.mean() - j["bars"]["L2"]["straight_frac"]) < 1e-3 and abs(s4.mean() - j["bars"]["L4"]["straight_frac"]) < 1e-3
    G[f"{ds}/n{n}"] = dict(k4_within1=a4[0], k4_within2=a4[1], k4_far=a4[2], k9_within1=a9[0], k9_within2=a9[1], k9_far=a9[2],
                           k16_within1=a16[0], k16_within2=a16[1], r2_k4_union=j["topology"]["k4_union"]["procrustes_r2"],
                           r2_k9_mutual=j["topology"]["k9_mutual"]["procrustes_r2"], r2_k9_union=j["topology"]["k9_union"]["procrustes_r2"],
                           bars2_straight=float(s2.mean()), bars4_straight=float(s4.mean()),
                           bars2_within1px=j["bars"]["L2"]["within_1px_of_line"], bars4_within1px=j["bars"]["L4"]["within_1px_of_line"])
    g = G[f"{ds}/n{n}"]
    lines.append(f"{DSN[ds]} & {n} & {g['k4_within1']:.3f} & {g['k9_within1']:.3f} & {g['k9_within2']:.3f} & {g['k9_far']} & "
                 f"{g['r2_k4_union']:.2f} & {g['r2_k9_mutual']:.2f} & {g['bars2_straight']:.2f} & {g['bars4_straight']:.2f}\\\\")
lines += ["\\bottomrule", "\\end{tabular}"]
open(os.path.join(TAB, "tab_interp_img_geom.tex"), "w").write("\n".join(lines) + "\n")
OUT["img_geom"] = G

# ---------------------------------------------------------------------------------------- stack and boosters alone
FAM = [("cgbt", lambda m: m == "cgbt"), ("ggbt", lambda m: m == "ggbt"), ("gknn", lambda m: m.startswith("gknn")),
       ("knn", lambda m: m.startswith("knn")), ("gbt+et", lambda m: m in ("gbt", "et")), ("lin", lambda m: m.startswith("lin"))]
S = {}
lines = ["\\begin{tabular}{llrrrrrrrrrrr}", "\\toprule",
         " & & \\multicolumn{6}{c}{share of the stacking weight} & \\multicolumn{2}{c}{out-of-fold error} & \\multicolumn{3}{c}{test error}\\\\",
         "\\cmidrule(lr){3-8}\\cmidrule(lr){9-10}\\cmidrule(lr){11-13}",
         "set & $n$ & \\code{cgbt} & \\code{ggbt} & \\code{gknn} & \\code{knn} & \\hd{\\code{gbt},\\\\\\code{et}} & \\code{lin} & "
         "\\code{cgbt} & \\code{ggbt} & v3 & \\hd{\\code{cgbt}\\\\alone} & \\hd{\\code{ggbt}\\\\alone}\\\\", "\\midrule"]
for (ds, n), lab in [(r, None) for r in RUNS] + [(("v2", 10000), "v2")]:
    j = J2 if lab == "v2" else J[(ds, n)]; Wt = j["weights"]; tw = sum(Wt.values()); O = j["member_oof_err"]
    sh = {f: sum(v for k, v in Wt.items() if fn(k)) / tw for f, fn in FAM}
    if lab == "v2":
        row = dict(share=sh, total=tw, oof_cgbt=None, oof_ggbt=O.get("ggbt"), err=j["err"], cgbt_alone=None, ggbt_alone=None)
        S["v2/qd_dev/n10000"] = row
        lines.append("\\addlinespace")
        lines.append(f"v2, \\code{{qd_dev}} & 10000 & -- & {sh['ggbt']:.2f} & {sh['gknn']:.2f} & {sh['knn']:.2f} & {sh['gbt+et']:.2f} & "
                     f"{sh['lin']:.2f} & -- & {O['ggbt']:.3f} & {j['err']:.4f} & -- & --\\\\")
        continue
    m = M[(ds, n)]; y = m["test_y"]
    ca, ga = float(np.mean(m["cgbt_test_pred"] != y)), float(np.mean(m["ggbt_test_pred"] != y))
    gref = j["boosters"]["ggbt"]["refit_on_all_n"]
    row = dict(share=sh, total=tw, oof_cgbt=O["cgbt"], oof_ggbt=O["ggbt"], err=j["err"], cgbt_alone=ca, ggbt_alone=ga, ggbt_refit=gref,
               agree=float(np.mean(m["cgbt_test_pred"] == m["ggbt_test_pred"])))
    S[f"{ds}/n{n}"] = row
    lines.append(f"{DSN[ds]} & {n} & " + " & ".join(f"{sh[f]:.2f}" for f, _ in FAM) +
                 f" & {O['cgbt']:.3f} & {O['ggbt']:.3f} & {j['err']:.4f} & {ca:.4f} & {ga:.4f}{'' if gref else '$^a$'}\\\\")
lines += ["\\bottomrule", "\\end{tabular}"]
open(os.path.join(TAB, "tab_interp_img_stack.tex"), "w").write("\n".join(lines) + "\n")
OUT["img_stack"] = S

# ---------------------------------------------------------------------------------------- gain by type / column share
TYPES = [("raw", "pixels"), ("pool4", "pooled sums, $k=4$"), ("pool9", "pooled sums, $k=9$"), ("pool16", "pooled sums, $k=16$"),
         ("bars2", "bars, $L=2$"), ("bars4", "bars, $L=4$"), ("pairs", "prototype pairs")]
COLS = [("cgbt", "qd_dev", 10000), ("cgbt", "qd_a", 10000), ("cgbt", "mnist", 10000), ("cgbt", "fashion_mnist", 10000),
        ("ggbt", "qd_dev", 10000), ("ggbt", "fashion_mnist", 10000)]
GN = {}
for b, ds, n in COLS:
    Gb = J[(ds, n)]["boosters"][b]["gain"]; tot = sum(v["n"] for v in Gb.values())
    GN[f"{b}/{ds}/n{n}"] = {t: dict(gain=Gb[t]["gain_frac"], cols=Gb[t]["n"] / tot, ratio=Gb[t]["gain_frac"] / (Gb[t]["n"] / tot),
                                    split=Gb[t]["split_frac"]) for t in Gb}
lines = ["\\begin{tabular}{l" + "r" * len(COLS) + "}", "\\toprule",
         " & \\multicolumn{4}{c}{\\code{cgbt}} & \\multicolumn{2}{c}{\\code{ggbt}}\\\\", "\\cmidrule(lr){2-5}\\cmidrule(lr){6-7}",
         "feature type & " + " & ".join(DSN[ds] for _, ds, _ in COLS) + "\\\\", "\\midrule"]
for t, lab in TYPES:
    cells = []
    for b, ds, n in COLS:
        e = GN[f"{b}/{ds}/n{n}"].get(t)
        cells.append("--" if e is None else f"{e['gain']:.2f} ({e['ratio']:.1f})")
    lines.append(f"{lab} & " + " & ".join(cells) + "\\\\")
lines += ["\\addlinespace"]
for nm, ts in (("all bars", ("bars2", "bars4")), ("all pooled sums", ("pool4", "pool9", "pool16"))):
    cells = []
    for b, ds, n in COLS:
        E = GN[f"{b}/{ds}/n{n}"]
        if not all(t in E for t in ts):
            cells.append("--"); continue
        g_ = sum(E[t]["gain"] for t in ts); c_ = sum(E[t]["cols"] for t in ts); cells.append(f"{g_:.2f} ({g_ / c_:.1f})")
    lines.append(f"{nm} & " + " & ".join(cells) + "\\\\")
lines += ["\\midrule", "columns & " + " & ".join(str(sum(v["n"] for v in J[(ds, n)]["boosters"][b]["gain"].values())) for b, ds, n in COLS) + "\\\\",
          "\\bottomrule", "\\end{tabular}"]
open(os.path.join(TAB, "tab_interp_img_gain.tex"), "w").write("\n".join(lines) + "\n")
OUT["img_gain"] = GN

# ---------------------------------------------------------------------------------------- fig_img_grid
def mesh(ax, Y, pix):
    """Isomap embedding, Procrustes-aligned to the true grid, drawn as the true lattice (edges between horizontal and
    vertical grid neighbours; horizontal edges coloured by row, vertical ones by column)."""
    true_rc = np.stack([pix // 28, pix % 28], 1).astype(float)
    m1, m2, disp = procrustes(true_rc, Y); idx = {int(p): i for i, p in enumerate(pix)}; segs, cols = [], []
    for i, p in enumerate(pix):
        p = int(p); r_, c_ = divmod(p, 28)
        for q, t in ((p + 1, r_), (p + 28, c_)):
            if q in idx and (q != p + 1 or c_ < 27):
                segs.append([m2[i][::-1] * [1, -1], m2[idx[q]][::-1] * [1, -1]]); cols.append(t / 27)
    from matplotlib.collections import LineCollection
    ax.add_collection(LineCollection(segs, colors=plt.cm.viridis(np.array(cols)), linewidths=0.3))
    ax.autoscale(); ax.set_aspect("equal"); ax.set_xticks([]); ax.set_yticks([])
    return 1 - disp


def grid_im(ax, bg):
    ax.imshow(bg.reshape(28, 28), cmap="Greys", vmin=0, vmax=max(bg.max() * 2.5, 1e-9))
    ax.set_xlim(-0.5, 27.5); ax.set_ylim(27.5, -0.5); ax.set_xticks([]); ax.set_yticks([])


def draw_sets(ax, m, centres, k, bg):
    grid_im(ax, bg); mem = m[f"pool{k}_members"].astype(int); pc = m["pool_centres"].astype(int); pos = {int(c): i for i, c in enumerate(pc)}
    cols = plt.cm.tab10(np.arange(len(centres)) % 10)
    for c, col in zip(centres, cols):
        S_ = mem[pos[c]]
        ax.plot(S_ % 28, S_ // 28, "s", color=col, ms=3.0, alpha=0.75, mec="none")
        ax.plot([c % 28], [c // 28], "s", color="k", ms=3.0)


def draw_bars(ax, PL, idx, bg):
    grid_im(ax, bg)
    for rank, t in enumerate(idx):
        px = PL[t][PL[t] >= 0]; P_ = np.stack([px // 28, px % 28], 1).astype(float)
        u = np.linalg.eigh(np.cov(P_.T) + 1e-9 * np.eye(2))[1][:, 1]; o = np.argsort((P_ - P_.mean(0)) @ u); P_ = P_[o]
        col = plt.cm.plasma(0.85 * rank / max(len(idx) - 1, 1))
        ax.plot(P_[:, 1], P_[:, 0], "-", color=col, lw=1.0, alpha=0.9); ax.plot(P_[:, 1], P_[:, 0], "s", color=col, ms=1.5, alpha=0.9)


def bar_weights(ds, n, L):
    j, m = J[(ds, n)], M[(ds, n)]; bank = {b["name"]: (b["start"], b["stop"]) for b in j["boosters"]["cgbt"]["bank"]}
    lo, hi = bank[f"bars{L}"]; w = m["cgbt_gain_vec"][lo:hi].astype(float)
    return w / w.sum(), j["boosters"]["cgbt"]["gain"][f"bars{L}"]["gain_frac"]


fig = plt.figure(figsize=(W, 3.6))
gs = fig.add_gridspec(2, 4, hspace=0.32, wspace=0.06, left=0.01, right=0.99, top=0.93, bottom=0.01)
mq, mf, mm = M[("qd_dev", 10000)], M[("fashion_mnist", 10000)], M[("mnist", 10000)]
bgq, bgf, bgm = mq["class_mean"].mean(0), mf["class_mean"].mean(0), mm["class_mean"].mean(0)
cen_q = [int(c) for c in mq["pool_example_centres"]]
ax = fig.add_subplot(gs[0, 0]); draw_sets(ax, mq, cen_q, 9, bgq); ax.set_title("(a) six $S_i(9)$, qd_dev", fontsize=6.8)
# Fashion: centres whose S_i(9) holds the most mirror pixels (same row +-1, columns summing to 27 +- 2), spread out
pcf = mf["pool_centres"].astype(int); memf = mf["pool9_members"].astype(int)
mir = np.array([np.sum((np.abs(S_ // 28 - c // 28) <= 1) & (np.abs(S_ % 28 + c % 28 - 27) <= 2) & (cheb(S_, c) > 2)) for c, S_ in zip(pcf, memf)])
cand = [int(pcf[i]) for i in np.argsort(-mir, kind="stable") if mir[i] >= 2 and bgf[pcf[i]] >= 0.25]; cen_f = []
for c in cand:
    if all(cheb(np.array(c), np.array(d)) > 5 for d in cen_f) and abs(c % 28 - 13.5) > 3:
        cen_f.append(c)
    if len(cen_f) == 3:
        break
ax = fig.add_subplot(gs[0, 1]); draw_sets(ax, mf, cen_f, 9, bgf); ax.set_title("(b) three $S_i(9)$, Fashion", fontsize=6.8)
OUT["fig_img_grid"] = dict(qd_centres=cen_q, fashion_centres=cen_f, fashion_sets_with_mirror_k9=int(np.sum(mir > 0)), fashion_active=int(len(pcf)))
for q, (ds, nm) in enumerate((("qd_dev", "qd_dev"), ("fashion_mnist", "Fashion"))):
    ax = fig.add_subplot(gs[0, 2 + q]); m = M[(ds, 10000)]
    r2 = mesh(ax, m["isomap"], m["isomap_pixels"].astype(int))
    ax.set_title(f"({'cd'[q]}) Isomap, {nm}: $R^2={r2:.2f}$", fontsize=6.8)
rng = np.random.default_rng(0); PLq = mq["bars4_pixels"]
rand_idx = rng.choice(len(PLq), 12, replace=False)
ax = fig.add_subplot(gs[1, 0]); draw_bars(ax, PLq, rand_idx, bgq); ax.set_title("(e) 12 random 9-pixel bars, qd_dev", fontsize=6.8)
OUT["fig_img_grid"]["random_bars"] = [int(t) for t in rand_idx]
for q, (ds, nm, bg) in enumerate((("qd_dev", "qd_dev", bgq), ("mnist", "MNIST", bgm), ("fashion_mnist", "Fashion", bgf))):
    w, gf = bar_weights(ds, 10000, 4); top = np.argsort(-w)[:12]
    ax = fig.add_subplot(gs[1, 1 + q]); draw_bars(ax, M[(ds, 10000)]["bars4_pixels"], top, bg)
    ax.set_title(f"({'fgh'[q]}) top 12 by gain, {nm}: {100 * w[top].sum() * gf:.1f}%", fontsize=6.8)
    OUT["fig_img_grid"][f"top12_bars4_{ds}_share_of_cgbt_gain"] = float(w[top].sum() * gf)
save(fig, "fig_img_grid.pdf")

# ---------------------------------------------------------------------------------------- fig_img_contrib
LAB = {"qd_dev": ["ocean", "motorbike", "matches", "grapes", "paper clip", "campfire", "washing m.", "soccer ball", "frying pan", "foot"],
       "mnist": [str(i) for i in range(10)]}
fig = plt.figure(figsize=(W, 5.5))
gsc = fig.add_gridspec(9, 10, height_ratios=[1, 1, 1, 1, 0.22, 1, 1, 1, 1], left=0.12, right=0.995, top=0.965, bottom=0.005,
                       wspace=0.05, hspace=0.1)
OUT["fig_img_contrib"] = {}
for b0, ds, dn in ((0, "qd_dev", "qd_dev"), (5, "mnist", "MNIST")):
    m = M[(ds, 10000)]
    rws = [(f"{dn}:\nclass mean", m["class_mean"], "ink"), ("cgbt", m["cgbt_contrib"], "c"),
           ("cgbt, on pixels\nblank in the point", m["cgbt_contrib"] - m["cgbt_contrib_inked"], "c"), ("ggbt", m["ggbt_contrib"], "c")]
    for i, (nm, A, kind) in enumerate(rws):
        for c in range(10):
            a_ = fig.add_subplot(gsc[b0 + i, c]); v = A[c]
            if kind == "ink":
                a_.imshow(v.reshape(28, 28), cmap="Greys"); a_.set_title(LAB[ds][c], fontsize=6.2, pad=2)
            else:
                s_ = np.abs(v).max() or 1; a_.imshow(v.reshape(28, 28), cmap="RdBu_r", vmin=-s_, vmax=s_)
            a_.set_xticks([]); a_.set_yticks([])
            for sp in a_.spines.values():
                sp.set_linewidth(0.4)
            if c == 0:
                a_.set_ylabel(nm, fontsize=6.2, rotation=0, ha="right", va="center")
    OUT["fig_img_contrib"][ds] = dict(blank_share_cgbt=[float(x) for x in ((m["cgbt_contrib"] - m["cgbt_contrib_inked"]).sum(1) / m["cgbt_contrib"].sum(1))],
                                      blank_share_ggbt=[float(x) for x in ((m["ggbt_contrib"] - m["ggbt_contrib_inked"]).sum(1) / m["ggbt_contrib"].sum(1))],
                                      corr_cgbt_ggbt=[float(np.corrcoef(m["cgbt_contrib"][c], m["ggbt_contrib"][c])[0, 1]) for c in range(10)])
save(fig, "fig_img_contrib.pdf")

json.dump(OUT, open(os.path.join(FIG, "fig_interp.json"), "w"), indent=1, default=lambda v: v.item() if hasattr(v, "item") else str(v))
print(json.dumps({k: OUT[k] for k in ("toy_timing",)}, indent=1, default=str)[:3000])

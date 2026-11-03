"""Figures and tables of the section "What it learns" of the DFG paper (paper_dfg/): sections/interp.tex (part 1) and
sections/interp_dyn.tex (part 2).

Reads only frozen outputs of the Part 11 interpretability analyses and the result files; it fits no learner:
  study/part11/interp/tables/        the structure atlas (ATLAS.md; atlas_make.py): atlas_cells.csv, atlas_targets.csv,
                                     atlas_family.json, atlas_quirks.json, p10_compare.csv, identity.json
  study/part11/interp/calib/calib.json            false admissions, spurious terms, compute (CALIB.md)
  study/part11/interp/theory/check_theory.json    the exact statements P1-P5 and their checks (THEORY.md)
  study/part10/interp/results/toy_final/power/    Part 10's test of the true block (TOY_INTERP.md, VERIFICATION.json)
  study/part11/RESULTS.json, study/part11/results/toy__dfg13-perm__<suite>.json      n* and test errors of DFG alone
Every number a figure plots, a table shows or the text quotes from this script is stored in tables/interp_numbers.json
under the key of the function that made it (the file is updated per key, so running some functions keeps the others).

One function per output, registered with @item; each writes tables/<name>.tex or figures/<name>.pdf.
usage: OMP_NUM_THREADS=1 python3 make_interp.py            all outputs
       OMP_NUM_THREADS=1 python3 make_interp.py NAME ...   only these (function names below)

Part 1 (sections/interp.tex):
  fig_interp_atlas      the atlas grid: test error of DFG alone by (target, n), seed 0, with the cells where a compact
                        representation of the target is complete, the forced variant and n*_0 (re-plotted from
                        atlas_cells.csv / atlas_targets.csv; the analysis's own figure is figures/fig_atlas_grid.pdf)
  tab_interp_atlas      one row per target family: what the model holds at the first n with test error <= 0.1 and at
                        n = 16384 (atlas_family.json, atlas_cells.csv)
  num_interp_atlas      the counts the text of the atlas subsection quotes (identity, exact Fourier models, dictionary
                        vs readout, spurious terms, against v3's DFG member), each checked against ATLAS.md's values
  tab_interp_calib      false admissions on labels independent of the inputs: what is proved, the null rate, what
                        DFG's own fits admitted (calib.json, check_theory.json)
  tab_interp_mod3       the residue classes mod 3: exact low-degree weight, the true block's test, what the search's
                        seeds see (check_theory.json P4, Part 10's power files, the result files)
  num_interp_fail       h5s1, h6_00 and the late signed-sum targets (result files, RESULTS.json, Part 10's files)
  tab_interp_atlas_targets   appendix: one row per atlas target (atlas_family.json, atlas_targets.csv)
  tab_interp_spur       appendix: spurious terms by n on the designed and random targets (calib.json A2.by_n)
Part 2 (sections/interp_dyn.tex): its functions follow part 1's, in their own block at the end of the file.
  fig_dyn_when          (a) DFG's round-0 decisions against n > n_glob, by band of n / n_glob (check_theory.json P3.test0);
                        (b, c) the threshold ablations strict and lenient, log2 n* ratio per target by class of target,
                        against the moves expected if the test set n* (RESULTS.json q5_ablations; ablations/families.py;
                        the block threshold's move and n* against n_detect from ABLATIONS.md's ablations.json)
  tab_dyn_when          (a) the classes of later rounds against n_glob (check_theory.json P3); (b) the 13 sum-structured
                        atlas targets: Part 10's n_detect (corrected) against DFG alone's n_struct (atlas_targets.csv)
  fig_dyn_order         the order figure of ORDER.md re-plotted at the paper's width (order_chars.csv, order_numbers.json)
  tab_dyn_order         (a) DFG's rounds by n; (b) per target, the Kendall taus of the orders (order_numbers.json)
  num_dyn               the log terms, parity thresholds and linear-block thresholds under the three deltas, and Part 10's
                        corrected detection summary and T / threshold at n_struct (arithmetic; toy_timing.csv)
"""
import os, sys, csv, json, math
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D

HERE = os.path.dirname(os.path.abspath(__file__))
STUDY = os.path.join(os.path.dirname(HERE), "study")
P11 = os.path.join(STUDY, "part11")
INTERP = os.path.join(P11, "interp")
ATAB = os.path.join(INTERP, "tables")
CALIB = os.path.join(INTERP, "calib", "calib.json")
THEORY = os.path.join(INTERP, "theory", "check_theory.json")
P10 = os.path.join(STUDY, "part10", "interp")
FIG, TAB = os.path.join(HERE, "figures"), os.path.join(HERE, "tables")
os.makedirs(FIG, exist_ok=True); os.makedirs(TAB, exist_ok=True)
NUMS = os.path.join(TAB, "interp_numbers.json")

# ---- style: as make_figures.py / Part 10's make_interp.py; no text below 7 pt at the printed size ----------------------
INK, INK2, GRID = "#1a1a1a", "#4a4a4a", "#e3e3e3"
plt.rcParams.update({
    "font.family": "DejaVu Sans", "mathtext.fontset": "dejavusans", "font.size": 7.5, "axes.titlesize": 7.5,
    "axes.labelsize": 7.5, "xtick.labelsize": 7, "ytick.labelsize": 7, "legend.fontsize": 7, "pdf.fonttype": 42,
    "axes.linewidth": 0.6, "axes.edgecolor": "#9a9a9a", "text.color": INK, "axes.labelcolor": INK,
    "xtick.color": INK2, "ytick.color": INK2, "figure.facecolor": "white", "savefig.facecolor": "white"})
W = 6.5                                                   # LaTeX \textwidth in inches (1in margins, letter); figures
                                                          # are made at this width and included at \linewidth (scale 1)

ITEMS = {}


def item(fn):
    """Register an output-making function under its name."""
    ITEMS[fn.__name__] = fn
    return fn


def store(key, value):
    """Write value under key into tables/interp_numbers.json, keeping the other keys."""
    try:
        D = json.load(open(NUMS))
    except (OSError, ValueError):
        D = {}
    D[key] = value
    json.dump(D, open(NUMS, "w"), indent=1, sort_keys=True, default=float)


def save_fig(fig, name):
    p = os.path.join(FIG, name + ".pdf")
    fig.savefig(p, metadata={"CreationDate": None})
    plt.close(fig)
    print("wrote", os.path.relpath(p, HERE))


def write_tex(name, lines):
    p = os.path.join(TAB, name + ".tex")
    open(p, "w").write("\n".join(lines) + "\n")
    print("wrote", os.path.relpath(p, HERE))


def tt(s):
    """A target name for LaTeX text (underscores escaped)."""
    return str(s).replace("_", "\\_")


# =======================================================================================================================
# Part 1 (sections/interp.tex)
# =======================================================================================================================
import re
from statistics import median

NS = [16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384]
# The atlas's 37 targets (seed 0) in 12 families: ATLAS.md section 1, with its 'Compositions' group split into the
# majorities of parities (and andxor), the parities of two majorities and the majority of majorities, and the residue
# classes mod 3 taken out of 'Symmetric and pure signed-sum targets'.
FAMS = [
    ("Parities", ["par2", "par4", "par5"]),
    ("Staircases", ["stair5", "stair6"]),
    ("Majorities of parities; andxor", ["majpar", "majpar5", "andxor"]),
    ("Multiplexers", ["mux6", "mux11"]),
    ("DNF, CNF, decision lists, read-once formulas", ["cnf3", "f7_02", "dlist8", "f7_04", "f7_06"]),
    ("Random formulas", ["rf06", "hrf0"]),
    ("Majorities and halfspaces", ["maj9", "thrint", "thr30", "f7_01"]),
    ("Parities of two majorities", ["parmaj", "majxor"]),
    ("Majority of majorities", ["majmaj5"]),
    ("Symmetric and signed sums", ["sym9", "band11", "f7_08", "h5s7"]),
    ("Signed-sum mixtures", ["f7_07", "f7_09", "symand", "f7_10", "f7_00", "f7_03", "f7_11"]),
    ("Residue classes mod 3", ["f7_05", "h6_00"]),
]
ATLAS_TARGETS = [t for _, L in FAMS for t in L]


def _num(v):
    return None if v in ("", None, "None", "nan") else float(v)


def _partial(reps):
    """Part of a compact representation is present: some non-auxiliary representation has a character or a block
    (atlas_make.figures' open dot; the auxiliary symmetry-class representation is printed as '... class blocks')."""
    for part in reps.split(", "):
        if "class blocks" in part:
            continue
        if any(int(a) > 0 for a, _ in re.findall(r"(\d+)/(\d+)", part)):
            return True
    return False


def load_cells():
    """atlas_cells.csv: every (target, n) cell of the atlas fits (seed 0), keyed by (target, n)."""
    C = {}
    for r in csv.DictReader(open(os.path.join(ATAB, "atlas_cells.csv"))):
        c = dict(suite=r["suite"], target=r["target"], n=int(r["n"]), err=float(r["err"]), variant=int(r["variant"]),
                 size=int(r["size"]), T=_num(r["T_share"]), R=_num(r["R_share"]), S=_num(r["S_share"]),
                 S_lin=_num(r["S_lin_share"]), S_lin_n=int(r["S_lin_n"]), Rn=int(r["R_n"]), Sn=int(r["S_n"]),
                 blocks=int(r["n_blocks"]), quad=int(r["n_quad"]), chars=json.loads(r["chars_by_degree"]),
                 err_noS=_num(r["err_no_S"]), err_nobg=_num(r["err_no_bg"]), oracle=_num(r["oracle_err"]),
                 r2=_num(r["span_r2"]), fw=_num(r["fourier_weight"]), linear=r["linear_block_round"] != "",
                 complete=any(json.loads(r["reps_complete"])), partial=_partial(r["reps"]), reps=r["reps"])
        C[(c["target"], c["n"])] = c
    return C


def load_targets():
    """atlas_targets.csv: one row per atlas target (suite, n*_0 = seed-0 10% point, n*_3, Part 10's numbers)."""
    return {r["target"]: r for r in csv.DictReader(open(os.path.join(ATAB, "atlas_targets.csv")))}


def load_family():
    """atlas_family.json -> {target: first = the cell at the first n with test error <= 0.1 (None if never), last = the
    cell at n = 16384, rep_first / rep_stable = first n with a complete compact representation (and from which on)}."""
    F = {}
    for g in json.load(open(os.path.join(ATAB, "atlas_family.json"))):
        for t in g["rep_first"]:
            F[t] = dict(first=g["at"]["first"].get(t), last=g["at"]["16384"][t], rep_first=g["rep_first"][t],
                        rep_stable=g["rep_stable"][t], group=g["group"], limits=g["limits"])
    return F


def fe(e):
    """A test error for a table: 3 decimals below 0.1 (4 below 0.001), 4 from 0.1 (the minority rates of the test sets)."""
    return "0" if e == 0 else (f"{e:.4f}" if e < 0.001 or e >= 0.1 else f"{e:.3f}")


def rng_str(vals, f=lambda v: f"{v:g}"):
    lo, hi = min(vals), max(vals)
    return f(lo) if lo == hi else f"{f(lo)}--{f(hi)}"


def nstar0(T, t):
    v = _num(T[t]["nstar0_alone"])
    return None if v is None or not math.isfinite(v) else v


@item
def fig_interp_atlas():
    """The atlas grid, re-plotted from atlas_cells.csv and atlas_targets.csv with the markers of the analysis's own
    figures/fig_atlas_grid.pdf (atlas_make.figures): grey = test error, clipped at 0.5; filled dot = some compact
    representation complete; square = none complete but span R^2 >= 0.999; open dot = part of one present; x = the
    forced variant chosen; bar = n*_0, the seed-0 10% point (log-interpolated)."""
    C = load_cells(); T = load_targets()
    assert len(C) == 407 and {t for t, _ in C} == set(ATLAS_TARGETS) and len(ATLAS_TARGETS) == 37
    panels = [FAMS[:6], FAMS[6:]]
    rows = []
    for fams in panels:
        R = []
        for fam, L in fams:
            R.append(("fam", fam)); R += [("t", t) for t in L]
        rows.append(R)
    nrow = max(len(R) for R in rows)
    rh = 0.148                                            # inches per row
    top, bot = 0.06, 1.05                                 # inches above / below the grids
    H = top + bot + nrow * rh
    fig = plt.figure(figsize=(W, H))
    cmap = plt.get_cmap("Greys").copy(); cmap.set_bad("white")
    out = {}
    marks = dict(complete=0, span=0, partial=0, forced=0)
    for p, R in enumerate(rows):
        x0 = [0.60, 3.84][p]; pw = 2.36                    # left edge and width of the grid, inches
        ax = fig.add_axes([x0 / W, (bot + (nrow - len(R)) * rh) / H, pw / W, len(R) * rh / H])
        E = np.full((len(R), len(NS)), np.nan)
        for i, (kind, nm) in enumerate(R):
            if kind == "t":
                E[i] = [C[(nm, n)]["err"] for n in NS]
        ax.imshow(np.ma.masked_invalid(np.clip(E, 0, 0.5)), aspect="auto", cmap=cmap, vmin=0, vmax=0.5,
                  interpolation="nearest", extent=(-0.5, len(NS) - 0.5, len(R) - 0.5, -0.5))
        for i, (kind, nm) in enumerate(R):
            if kind == "fam":
                ax.text(-0.45, i + 0.08, nm, ha="left", va="center", fontsize=7, style="italic", color=INK2)
                if i > 0:
                    ax.axhline(i - 0.5, color="#9a9a9a", lw=0.5)
                continue
            rec = {}
            for j, n in enumerate(NS):
                c = C[(nm, n)]
                m = "complete" if c["complete"] else ("span" if c["r2"] is not None and c["r2"] >= 0.999 else
                                                      ("partial" if c["partial"] else ""))
                if m == "complete":
                    ax.plot(j, i, "o", ms=3.6, mfc="#2a78d6", mec="#2a78d6", mew=0.6)
                elif m == "span":
                    ax.plot(j, i, "s", ms=3.2, mfc="#6250d6", mec="#6250d6", mew=0.6)
                elif m == "partial":
                    ax.plot(j, i, "o", ms=3.6, mfc="none", mec="#2a78d6", mew=0.8)
                if m:
                    marks[m] += 1
                if c["variant"] == 1:
                    ax.plot(j + 0.32, i - 0.28, "x", ms=2.8, color="#e34948", mew=0.8); marks["forced"] += 1
                rec[n] = [c["err"], m, c["variant"]]
            s0 = nstar0(T, nm)
            if s0 is not None:
                ax.plot(math.log2(s0) - 4, i, "|", ms=7, mew=1.6, color="#eb6834")
            out[nm] = dict(cells=rec, nstar0=s0)
        ax.set_xlim(-0.5, len(NS) - 0.5); ax.set_ylim(len(R) - 0.5, -0.5)
        ax.set_xticks(range(len(NS))); ax.set_xticklabels([str(n) for n in NS], rotation=90)
        ax.set_yticks([i for i, (k, _) in enumerate(R) if k == "t"])
        ax.set_yticklabels([nm for k, nm in R if k == "t"])
        ax.tick_params(length=2, pad=1.5)
        ax.set_xlabel("training-set size $n$", labelpad=2)
    # legend and colour bar under the grids
    hs = [Line2D([], [], ls="", marker="o", ms=4, mfc="#2a78d6", mec="#2a78d6"),
          Line2D([], [], ls="", marker="o", ms=4, mfc="none", mec="#2a78d6", mew=0.8),
          Line2D([], [], ls="", marker="s", ms=3.6, mfc="#6250d6", mec="#6250d6"),
          Line2D([], [], ls="", marker="x", ms=3.5, color="#e34948", mew=0.8),
          Line2D([], [], ls="", marker="|", ms=7, mew=1.6, color="#eb6834")]
    labs = ["a compact representation of the target is complete", "part of one is present",
            "none is complete; $f$ is in the features' span ($R^2\\geq0.999$)",
            "forced variant chosen", "$n^*_0$ (seed 0, 10% test error)"]
    fig.legend(hs, labs, loc="lower left", bbox_to_anchor=(0.05 / W, 0.0), ncol=2, frameon=False,
               handletextpad=0.3, columnspacing=1.0, labelspacing=0.35, fontsize=7)
    cax = fig.add_axes([5.05 / W, 0.26 / H, 1.25 / W, 0.07 / H])
    cb = fig.colorbar(plt.cm.ScalarMappable(norm=matplotlib.colors.Normalize(0, 0.5), cmap="Greys"), cax=cax,
                      orientation="horizontal")
    cb.set_ticks([0, 0.25, 0.5]); cb.ax.tick_params(labelsize=7, length=2, pad=1)
    cb.set_label("test error (clipped at 0.5)", fontsize=7, labelpad=2); cb.outline.set_linewidth(0.4)
    save_fig(fig, "fig_interp_atlas")
    store("fig_interp_atlas", dict(targets=out, marker_counts=marks, families=[[f, L] for f, L in FAMS]))


# what the model holds, family by family (ATLAS.md section 1); the numbers in the table come from the files
DESC = {
    "Parities": ("$\\chi_S$ alone", "$\\chi_S$ alone"),
    "Staircases": ("the prefix characters $x_1$, $x_1x_2$, \\dots{} and one more Fourier character",
                   "Fourier characters: all of stair5's; most of stair6's, and relevant blocks"),
    "Majorities of parities; andxor": ("their pair characters",
                                       "their characters; one relevant block in majpar and majpar5"),
    "Multiplexers": ("characters and blocks on address and data bits", "exactly the Fourier expansion"),
    "DNF, CNF, decision lists, read-once formulas": (
        "low-degree characters, blocks that encode a clause, term or rule, irrelevant degree-1 characters",
        "characters and a few blocks"),
    "Random formulas": ("the dominant input's character (hrf0: and a relevant block)",
                        "Fourier characters (hrf0: its whole expansion)"),
    "Majorities and halfspaces": ("degree-1 characters from the linear block; the exact block (maj9, f7\\_01)",
                                  "degree-1 characters and a block"),
    "Parities of two majorities": ("two folded blocks $|t_A+t_B|$, $|t_A-t_B|$",
                                   "the cross-pair characters; majxor also both folded blocks"),
    "Majority of majorities": ("4-input pieces of a majority, modulated by its fifth input",
                               "blocks and characters of odd degree {dlo}--{dhi}: {size} features, DFG's cap"),
    "Symmetric and signed sums": ("the exact signed block (h5s7: two factors that partition its class)",
                                  "the block, with relatives (sym9: and a spurious product)"),
    "Signed-sum mixtures": ("the partner's character, and the compact form or a relative of it",
                            "weighted blocks with the partner as inner term, and characters"),
    "Residue classes mod 3": ("never reached", "the constant and the kernel background, at every $n$"),
}


@item
def tab_interp_atlas():
    """One row per target family: the model at the first grid n with test error <= 0.1 and at n = 16384."""
    C = load_cells(); F = load_family()
    out = {}
    L = ["\\begin{tabularx}{\\linewidth}{@{}>{\\raggedright\\arraybackslash}p{2.35cm}rr>{\\raggedright\\arraybackslash}X"
         "crr>{\\raggedright\\arraybackslash}X@{}}",
         "\\toprule",
         "& \\multicolumn{3}{c}{first $n$ with test error $\\le0.1$} & complete & \\multicolumn{3}{c}{$n=16384$}\\\\",
         "\\cmidrule(lr){2-4}\\cmidrule(lr){6-8}",
         "family (targets) & $n$ & error & what the model holds & first / 16384 & error & size & what the model holds\\\\",
         "\\midrule"]
    for fam, ts in FAMS:
        first = {t: F[t]["first"] for t in ts if F[t]["first"]}
        last = {t: F[t]["last"] for t in ts}
        for t, c in first.items():                       # the family file and the cell table agree
            assert c["complete"] == C[(t, c["n"])]["complete"] and c["err"] == C[(t, c["n"])]["err"]
        for t, c in last.items():
            assert c["n"] == 16384 and c["complete"] == C[(t, 16384)]["complete"] and c["err"] == C[(t, 16384)]["err"]
        k1 = sum(1 for c in first.values() if c["complete"]); k2 = sum(1 for c in last.values() if c["complete"])
        d1, d2 = DESC[fam]
        if fam == "Majority of majorities":
            cc = C[("majmaj5", 16384)]; degs = sorted(int(k) for k in cc["chars"])
            assert all(k % 2 == 1 for k in degs)
            d2 = d2.format(dlo=degs[0], dhi=degs[-1], size=cc["size"])
        n1 = rng_str([c["n"] for c in first.values()]) if first else "never"
        e1 = rng_str([c["err"] for c in first.values()], fe) if first else "--"
        e2 = rng_str([c["err"] for c in last.values()], fe); sz = rng_str([c["size"] for c in last.values()])
        tl = ", ".join(tt(t) for t in ts)
        L.append(f"{fam} ({tl}) & {n1} & {e1} & {d1} & {k1}/{len(ts)}\\,; {k2}/{len(ts)} & {e2} & {sz} & {d2}\\\\")
        out[fam] = dict(targets=ts, first={t: dict(n=c["n"], err=c["err"], complete=c["complete"], size=c["size"],
                                                   S=c["S"]) for t, c in first.items()},
                        last={t: dict(err=c["err"], complete=c["complete"], size=c["size"], S=c["S"])
                              for t, c in last.items()},
                        complete_first=k1, complete_16384=k2)
    L += ["\\bottomrule", "\\end{tabularx}"]
    write_tex("tab_interp_atlas", L)
    store("tab_interp_atlas", out)


@item
def num_interp_atlas():
    """The counts that the atlas subsection quotes, recomputed from the atlas tables and checked against ATLAS.md."""
    C = load_cells(); F = load_family(); T = load_targets()
    N = {}
    # identity of the refits with the evaluation (identity.json)
    I = json.load(open(os.path.join(ATAB, "identity.json")))
    d30 = {s: v for s, v in I.items() if not s.startswith("designed_d")}
    N["identity"] = dict(suites=len(d30), targets=sum(len(v["targets"]) for v in d30.values()),
                         cells=sum(v["compared"] for v in d30.values()), err_equal=sum(v["err_equal"] for v in d30.values()),
                         flops_equal=sum(v["flops_equal"] for v in d30.values()),
                         dscale_cells=sum(v["compared"] for s, v in I.items() if s.startswith("designed_d")),
                         dscale_equal=sum(min(v["err_equal"], v["flops_equal"]) for s, v in I.items() if s.startswith("designed_d")))
    assert (N["identity"]["cells"], N["identity"]["err_equal"], N["identity"]["flops_equal"], N["identity"]["targets"],
            N["identity"]["dscale_cells"], N["identity"]["dscale_equal"]) == (517, 517, 517, 47, 66, 66)
    N["atlas"] = dict(cells=len(C), targets=len(T), suites=len({r["suite"] for r in T.values()}))
    assert (N["atlas"]["cells"], N["atlas"]["targets"], N["atlas"]["suites"]) == (407, 37, 9)
    # models that are exactly the target's Fourier expansion at 16384 (all its characters, nothing else but the
    # constant and the kernel background)
    ex = [t for t in ATLAS_TARGETS if C[(t, 16384)]["fw"] is not None and C[(t, 16384)]["fw"] >= 0.99999
          and C[(t, 16384)]["Rn"] == 0 and C[(t, 16384)]["Sn"] == 0 and C[(t, 16384)]["blocks"] == 0
          and C[(t, 16384)]["quad"] == 0]
    assert sorted(ex) == sorted(["par2", "par4", "par5", "stair5", "andxor", "mux6", "mux11", "hrf0"])
    N["exact_fourier_16384"] = ex
    # dictionary or readout: cells above 10% test error (oracle = best logistic weights on the learned features,
    # fitted on test inputs; the kernel background is not among them)
    bad = [c for c in C.values() if c["err"] > 0.1]
    dic = [c for c in bad if c["oracle"] > 0.1]; rd = [c for c in bad if c["oracle"] <= 0.02]
    mid = [c for c in bad if 0.02 < c["oracle"] <= 0.1]
    below = [c for c in dic if c["err"] < c["oracle"] - 0.05]
    below_nobg = [c for c in below if c["err_nobg"] < c["oracle"] - 0.05]
    N["limits"] = dict(cells_above_01=len(bad), dictionary=len(dic), readout=len(rd), between=len(mid),
                       readout_cells=sorted(f"{c['target']}@{c['n']}" for c in rd),
                       between_cells=sorted(f"{c['target']}@{c['n']}" for c in mid),
                       dfg_more_than_005_below_oracle=len(below), of_which_still_without_background=len(below_nobg))
    assert (len(bad), len(dic), len(rd), len(mid), len(below), len(below_nobg)) == (148, 133, 9, 6, 27, 0)
    # at the first fit: DFG's error against the oracle's
    gaps = []
    for t in ATLAS_TARGETS:
        f = F[t]["first"]
        if f:
            c = C[(t, f["n"])]
            gaps.append((c["err"] - c["oracle"], t, c["n"], c["err"], c["oracle"], c["err_nobg"]))
    gaps.sort(reverse=True)
    N["first_fit_gap"] = dict(targets=len(gaps), median=median(g[0] for g in gaps),
                              largest=[dict(target=t, n=n, err=e, oracle=o, err_without_background=b)
                                       for _, t, n, e, o, b in gaps[:3]])
    assert len(gaps) == 35 and N["first_fit_gap"]["median"] <= 0.0005
    assert [(g[1], g[2]) for g in gaps[:3]] == [("andxor", 64), ("thrint", 256), ("majpar", 64)]
    # target terms alone at the first fit
    N["first_fit_T_only_err0"] = sum(1 for t in ATLAS_TARGETS if F[t]["first"] and F[t]["first"]["err_T"] == 0)
    assert N["first_fit_T_only_err0"] == 15
    # spurious terms
    fs = sorted(((F[t]["first"]["S"], t) for t in ATLAS_TARGETS if F[t]["first"]), reverse=True)
    ls = sorted(((F[t]["last"]["S"], t) for t in ATLAS_TARGETS), reverse=True)
    rem = max(abs(C[(t, F[t]["first"]["n"])]["err_noS"] - C[(t, F[t]["first"]["n"])]["err"])
              for t in ATLAS_TARGETS if F[t]["first"])
    rem16 = max(abs(C[(t, 16384)]["err_noS"] - C[(t, 16384)]["err"]) for t in ATLAS_TARGETS)
    N["spurious"] = dict(first_fit_le_01=sum(1 for s, _ in fs if s <= 0.1), first_fit_targets=len(fs),
                         first_fit_median=median(s for s, _ in fs), first_fit_largest=[[t, s] for s, t in fs[:3]],
                         at16384_le_01=sum(1 for s, _ in ls if s <= 0.1), at16384_largest=[ls[0][1], ls[0][0]],
                         removal_change_first_fit=rem, removal_change_16384=rem16)
    assert (N["spurious"]["first_fit_le_01"], N["spurious"]["at16384_le_01"], ls[0][1]) == (22, 36, "sym9")
    assert abs(rem - 145 / 4096) < 1e-12 and rem16 == 0
    lin = [c for c in C.values() if c["linear"]]
    lin64 = sorted(((c["S_lin"], c["target"]) for c in lin if c["n"] == 64 and c["S_lin_n"] > 0), reverse=True)
    N["linear_block"] = dict(cells=len(lin), at64_targets=len(lin64), at64_S_lin=[min(s for s, _ in lin64), max(s for s, _ in lin64)],
                             at16384_S_lin_max=max(C[(t, 16384)]["S_lin"] for t in ATLAS_TARGETS))
    assert len(lin) == 83 and len(lin64) == 8
    Q = json.load(open(os.path.join(ATAB, "atlas_quirks.json")))
    sp = Q["spurious_products"]; du = Q["duplicate_blocks"]
    N["quirks"] = dict(spurious_product_cells=len(sp), spurious_product_targets=len({q["target"] for q in sp}),
                       spurious_product_shares=[min(q["share"] for q in sp), max(q["share"] for q in sp)],
                       spurious_product_err_max=max(q["err"] for q in sp), duplicate_cells=len(du),
                       duplicate_shares=[min(min(q["shares"]) for q in du), max(max(q["shares"]) for q in du)])
    assert (len(sp), N["quirks"]["spurious_product_targets"], len(du)) == (9, 4, 5)
    # the kernel background (removing it from a fitted model is DFG's prediction without it, same variant)
    lo = sum(1 for c in C.values() if c["err_nobg"] < c["err"]); hi = sum(1 for c in C.values() if c["err_nobg"] > c["err"])
    N["background"] = dict(lower_without=lo, higher_without=hi, unchanged=len(C) - lo - hi)
    assert (lo, hi) == (85, 54)
    # DFG's own choice of variant, and the variant it did not choose (results/cv/forced_vs_default.json)
    cv = json.load(open(os.path.join(INTERP, "results", "cv", "forced_vs_default.json")))
    ch = [x[x["chosen"]]["err"] for x in cv]
    N["cv"] = dict(cells=len(cv), forced=sum(1 for x in cv if x["chosen"] == "forced"),
                   differ=sum(1 for x in cv if x["default"]["err"] != x["forced"]["err"]),
                   choice_better=sum(1 for x in cv if x[x["chosen"]]["err"] < x["forced" if x["chosen"] == "default" else "default"]["err"]),
                   mean_chosen=float(np.mean(ch)), mean_default=float(np.mean([x["default"]["err"] for x in cv])),
                   mean_forced=float(np.mean([x["forced"]["err"] for x in cv])),
                   mean_better=float(np.mean([min(x["default"]["err"], x["forced"]["err"]) for x in cv])))
    assert (N["cv"]["cells"], N["cv"]["forced"], N["cv"]["differ"], N["cv"]["choice_better"]) == (222, 18, 140, 89)
    # below the first n with a complete compact representation (atlas_below.csv)
    B = list(csv.DictReader(open(os.path.join(ATAB, "atlas_below.csv"))))
    N["below_structure"] = dict(cells=len(B), targets=len({b["target"] for b in B}),
                                constant_only=sum(1 for b in B if b["empty"] == "True"),
                                true_character=sum(1 for b in B if int(b["true_chars"]) > 0),
                                forced=sum(1 for b in B if b["variant"] == "1"),
                                median_err=median(float(b["err"]) for b in B))
    assert (len(B), N["below_structure"]["constant_only"], N["below_structure"]["true_character"]) == (198, 108, 87)
    # the signed-sum mixtures: compact form at the first fit and at 16384
    mix = dict(FAMS)["Signed-sum mixtures"]
    N["mixtures"] = dict(complete_first=[t for t in mix if F[t]["first"]["complete"]],
                         complete_16384=[t for t in mix if F[t]["last"]["complete"]],
                         err0_16384=sum(1 for t in mix if C[(t, 16384)]["err"] == 0),
                         span_r2_16384={t: C[(t, 16384)]["r2"] for t in mix})
    assert N["mixtures"]["complete_16384"] == ["f7_10"] and N["mixtures"]["err0_16384"] == 7
    # DFG alone against v3's DFG member (Part 10), same (target, n) (p10_compare.csv)
    P = list(csv.DictReader(open(os.path.join(ATAB, "p10_compare.csv"))))
    same = [p for p in P if p["same_err"] == "True"]; diff = [p for p in P if p["same_err"] != "True"]
    byn = {n: [sum(1 for p in same if int(p["n"]) == n), sum(1 for p in P if int(p["n"]) == n)] for n in NS}
    oof = [p for p in diff if p["v3_source"].startswith("out-of-fold")]
    fin = [p for p in diff if not p["v3_source"].startswith("out-of-fold")]
    N["p10"] = dict(cells=len(P), same_err=len(same), by_n=byn, differ=len(diff), differ_vs_out_of_fold=len(oof),
                    alone_lower=sum(1 for p in diff if float(p["err_alone"]) < float(p["err_v3_dfg"])),
                    alone_lower_vs_final=[sum(1 for p in fin if float(p["err_alone"]) < float(p["err_v3_dfg"])), len(fin)],
                    same_ge4096=[sum(byn[n][0] for n in NS if n >= 4096), sum(byn[n][1] for n in NS if n >= 4096)],
                    same_1024_2048=[byn[1024][0] + byn[2048][0], byn[1024][1] + byn[2048][1]])
    st = [(t, _num(T[t]["n_struct_p10rule_alone"]), _num(T[t]["n_struct_p10rule_v3"])) for t in ATLAS_TARGETS]
    both = [(t, a, b) for t, a, b in st if a and b]
    N["p10"]["n_struct_equal"] = [sum(1 for _, a, b in both if a == b), len(both)]
    assert (len(P), len(same), len(oof), N["p10"]["n_struct_equal"]) == (255, 141, 45, [15, 15])
    assert N["p10"]["same_ge4096"] == [15, 15] and N["p10"]["same_1024_2048"] == [28, 32]
    store("num_interp_atlas", N)
    print(json.dumps(N, indent=1, default=float)[:3000])


def pct(x, d=2):
    return f"{100 * x:.{d}f}\\%"


# Corrections of the independent verifier of CALIB.md (study/part11/interp/calib/VERIFY_CALIB.json), applied as numbers the
# verifier computed with its own Monte Carlo and its pairing of fold fits; each is checked to occur in that file's text.
VCALIB = {
    # claim 10: the spectral block's null pass rate on P(y=1) = 0.8 labels at n = 4d, pooled over the report's and the
    # verifier's own Monte Carlo (the report's 5.7% and 48% were its 2000- and 1000-draw estimates)
    "spectral_pooled": dict(d30=0.053, d60=0.467, claim=10, text=["5.3% and 46.7%"]),
    # omission 1: the same rate at larger d or stronger label bias (the report measured d = 30, 60 and P(y=1) = 0.5, 0.8)
    "spectral_more": dict(d120_p08_n512=[397, 400], d30_p09_n128=0.39, omission=0, text=["397/400", "39% at n = 128"]),
    # claim 12: forced fold fits with a test-passed feature *after* a forced one (the report's 238/900 counted 9 fits
    # whose admission came in round 0, before any forcing)
    "forced_after": dict(d30_p08=[229, 900], claim=12, text=["229/900"]),
    # claim 11: the sum-block test passed in round 0 of 2 default fold fits (d = 30, P(y=1) = 0.8); never in a final fit
    "sum_default_folds": dict(fits=2, claim=11, text=["admitted sum blocks in round 0 twice"]),
    # claim 8: P(at least 2 degree-1 passes in the 440 tests) with the exact per-(p, n) null rates
    "deg1_p_at_least_2": dict(p=0.053, claim=8, text=["P(X >= 2) = 0.053"]),
    # claim 18: removing the spurious terms changes the mean test error by at most 0.0002 from n = 128 on
    "removal_from_128": dict(max_change=0.0002, claim=18, text=["at most 0.0002"]),
}


def check_vcalib():
    V = json.load(open(os.path.join(INTERP, "calib", "VERIFY_CALIB.json")))
    for k, v in VCALIB.items():
        src = V["claims"][v["claim"]] if "claim" in v else {"x": V["omissions"][v["omission"]]}
        blob = json.dumps(src)
        for t in v["text"]:
            assert t in blob, (k, t)
    return V


@item
def tab_interp_calib():
    """False admissions on labels independent of the inputs: what THEORY.md proves (P1, with VERIFY_THEORY.md's
    wording), the null rate of each test's statistic (CALIB.md's Monte Carlo of the round-0 statistics, computed as DFG
    computes them, with VERIFY_CALIB.md's corrections) and what DFG's own fits admitted (CALIB.md A1: 20 seeds per
    (P(y=1), n) at d = 30, 10 at d = 60; n = 16 ... 16384; THEORY.md's 110 null fits at d = 30)."""
    K = json.load(open(CALIB)); TH = json.load(open(THEORY)); check_vcalib()
    A = K["A1"]; cons = K["consistency"]; B = A["blocks"]; mc = K["mc_big"]
    P1 = TH["P1"]
    cls = {d: [A["by_class_pooled"][f"{d}:g{k}"] for k in range(1, 7)] for d in (30, 60)}
    ran = {d: sum(c["r0_ran"] for c in cls[d]) for d in cls}; passed = {d: sum(c["r0_pass"] for c in cls[d]) for d in cls}
    lin_r0 = {d: (sum(B[f"{d}:{p}:lin:all:r0"]["ran"] for p in ("0.5", "0.8")), sum(B[f"{d}:{p}:lin:all:r0"]["passed"] for p in ("0.5", "0.8")))
              for d in (30, 60)}
    assert lin_r0[30] == (cons["30:lin"]["tests"], cons["30:lin"]["observed"]) and lin_r0[60] == (cons["60:lin"]["tests"], cons["60:lin"]["observed"])
    qb = {d: max((mc[k]["quad"]["passes"], mc[k]["reps"]) for k in mc if k.startswith(f"{d}:0.5:")) for d in (30, 60)}
    q30, q60 = cons["30:0.8:quad:128"], cons["60:0.8:quad:256"]
    sr0 = [v for k, v in B.items() if ":sum_" in k and k.endswith(":all:r0")]
    slt = [v for k, v in B.items() if ":sum_" in k and k.endswith(":all:later")]
    sums = dict(r0=[sum(v["ran"] for v in sr0), sum(v["passed"] for v in sr0)], later=[sum(v["ran"] for v in slt), sum(v["passed"] for v in slt)],
                max_ratio=max(v["max"] for v in sr0 + slt if v.get("max") is not None))
    ca = K["cascade"]
    after_f = [sum(ca[f"0.8:{m}"]["after2"]["pass_forced"] for m in (29, 58)), sum(ca[f"0.8:{m}"]["after2"]["tests_forced"] for m in (29, 58))]
    after_r = [sum(ca[f"0.8:{m}"]["after2"]["pass_random"] for m in (29, 58)), sum(ca[f"0.8:{m}"]["after2"]["tests_random"] for m in (29, 58))]
    tot = A["totals"]
    cvb = [tot["30:0.8"]["cv_forced"] + tot["60:0.8"]["cv_forced"], tot["30:0.8"]["cv_fits"] + tot["60:0.8"]["cv_fits"]]
    ff = P1["full_fits"]
    fair = [sum(ff[n]["fits"] - ff[n]["nonconstant"] for n in ("64", "256", "1024", "4096")), sum(ff[n]["fits"] for n in ("64", "256", "1024", "4096"))]
    skew = dict(nonconstant=ff["128_biased"]["nonconstant"], fits=ff["128_biased"]["fits"], spectral=ff["128_biased"]["quad"],
                sum=ff["128_biased"]["sumblock"])
    lin_tail = {d: K["derived"]["lin"][str(d)]["chi2_tail"] for d in (30, 60)}
    g = TH["P1"]["bound_over_gauss_d30"]
    fa, sp, sm = VCALIB["forced_after"], VCALIB["spectral_pooled"], VCALIB["spectral_more"]
    N = dict(char_r0=dict(ran=ran, passed=passed, mc_rate_d30={"1": cons["30:g1"]["mc_rate"], "2": cons["30:g2"]["mc_rate"]},
                          mc_rate_d60={"1": cons["60:g1"]["mc_rate"], "2": cons["60:g2"]["mc_rate"]},
                          gauss_d30={k: v["gauss"] for k, v in g.items()}, bound_over_gauss_d30={k: v["ratio"] for k, v in g.items()},
                          bound=K["derived"]["PA_level"]["per_class"], p_at_least_2_deg1=VCALIB["deg1_p_at_least_2"]["p"]),
             linear=dict(r0=lin_r0, mc_rate={30: cons["30:lin"]["mc_rate"], 60: cons["60:lin"]["mc_rate"]}, chi2_tail=lin_tail),
             spectral=dict(balanced_max=qb, biased_d30_n128_fits=[q30["observed"], q30["tests"]], biased_d60_n256_fits=[q60["observed"], q60["tests"]],
                           pooled_null=dict(d30=sp["d30"], d60=sp["d60"]), d120_p08_n512=sm["d120_p08_n512"], d30_p09_n128=sm["d30_p09_n128"]),
             sums=dict(sums, default_fold_fits_round0=VCALIB["sum_default_folds"]["fits"]),
             forced=dict(fold_fits_with_tested_after_forced=fa["d30_p08"], local_after_forced=after_f, local_after_random=after_r,
                         cv_chose_forced_biased=cvb),
             final=dict(d30_bal=[tot["30:0.5"]["any_tested"], tot["30:0.5"]["fits"]], d30_bias=[tot["30:0.8"]["any_tested"], tot["30:0.8"]["fits"]],
                        d60_bal=[tot["60:0.5"]["any_tested"], tot["60:0.5"]["fits"]], d60_bias=[tot["60:0.8"]["any_tested"], tot["60:0.8"]["fits"]],
                        theory_fair=fair, theory_skew085_n128=skew))
    # the strict and lenient tests (RESULTS.json q5_ablations: DFG alone with delta = 1e-4 or 0.9, seeds 0 and 1, 65 targets)
    R = json.load(open(os.path.join(P11, "RESULTS.json")))["q5_ablations"]
    N["delta_ablations"] = {k: R[k]["pooled"] for k in ("strict", "lenient")}
    N["delta_ablations"]["null"] = R["_null"]
    assert (ran[30], passed[30], ran[60], passed[60]) == (2400, 2, 840, 1)
    assert sums["r0"] == [2000, 0] and sums["later"] == [153, 0] and after_f == [244, 334] and after_r == [0, 334]
    assert cvb == [0, 180] and fair == [78, 80] and (skew["nonconstant"], skew["fits"], skew["spectral"], skew["sum"]) == (7, 30, 7, 1)
    assert qb == {30: (3, 20000), 60: (2, 20000)}
    L = ["\\begin{tabularx}{\\linewidth}{@{}>{\\raggedright\\arraybackslash}p{2.25cm}>{\\raggedright\\arraybackslash}p{3.1cm}"
         ">{\\raggedright\\arraybackslash}X>{\\raggedright\\arraybackslash}X@{}}",
         "\\toprule",
         "test & proved under the null (P1) & null pass rate of its statistic & admitted in DFG's own fits\\\\",
         "\\midrule",
         f"global characters, degrees 1--6, round 0 & at most $\\delta/(2K)={N['char_r0']['bound']:g}$ per degree, for any $d$, $n$ and law of the labels "
         f"& {pct(cons['30:g1']['mc_rate'])} (degree 1) and {pct(cons['30:g2']['mc_rate'])} (degree 2) per test at $d=30$ "
         f"& {passed[30]} of {ran[30]} round-0 class searches at $d=30$, {passed[60]} of {ran[60]} at $d=60$\\\\",
         f"linear block, round 0 & at most $\\delta=0.1$ when it tests all inputs; a false linear block at most $\\delta+\\delta/(2K)$ "
         f"& {pct(cons['30:lin']['mc_rate'])} ($d=30$) and {pct(cons['60:lin']['mc_rate'])} ($d=60$), close to the $\\chi^2_d$ tail at its threshold "
         f"({pct(lin_tail[30])}, {pct(lin_tail[60])}) "
         f"& {lin_r0[30][1]} of {lin_r0[30][0]} round-0 tests at $d=30$, {lin_r0[60][1]} of {lin_r0[60][0]} at $d=60$; each adds all $d$ inputs\\\\",
         f"spectral block & nothing & balanced labels: at most {qb[30][0]} in {qb[30][1]} draws. $P(y{{=}}1)=0.8$, at $n=4d$, the smallest $n$ at which it "
         f"runs: {pct(sp['d30'], 1)} ($d=30$), {pct(sp['d60'], 0)} ($d=60$), {pct(sm['d120_p08_n512'][0] / sm['d120_p08_n512'][1], 0)} ($d=120$); "
         f"$P(y{{=}}1)=0.9$: {pct(sm['d30_p09_n128'], 0)} ($d=30$) "
         f"& biased labels: {q30['observed']} of {q30['tests']} fits ($d=30$, $n=128$), {q60['observed']} of {q60['tests']} ($d=60$, $n=256$); "
         f"at $P(y{{=}}1)=0.85$, $n=128$: {skew['spectral']} of {skew['fits']} fits; balanced: none\\\\",
         f"sum blocks & nothing & -- & none in the final fits (largest statistic {sums['max_ratio']:.2f} of its threshold); "
         f"in round 0 of {VCALIB['sum_default_folds']['fits']} default-variant fold fits ($d=30$, $P(y{{=}}1)=0.8$); "
         f"at $P(y{{=}}1)=0.85$, $n=128$: {skew['sum']} of {skew['fits']} fits\\\\",
         f"forced variant, then the local class & nothing: the variant adds a guess by design & -- "
         f"& a test-passed feature after a forced one in {fa['d30_p08'][0]} of {fa['d30_p08'][1]} forced fold fits ($d=30$, $P(y{{=}}1)=0.8$), "
         f"mostly the product of the two forced characters; in fold-sized refits the local test passes after the two forced characters in "
         f"{after_f[0]} of {after_f[1]}, after two random ones in {after_r[0]} of {after_r[1]}. The cross-validation chose the forced variant in "
         f"{cvb[0]} of {cvb[1]} biased fits\\\\",
         "\\midrule",
         f"final model & the constant and the kernel background, if round 0 admits nothing "
         f"& -- & a test-passed feature in {tot['30:0.5']['any_tested']} of {tot['30:0.5']['fits']} balanced and {tot['30:0.8']['any_tested']} of "
         f"{tot['30:0.8']['fits']} biased fits at $d=30$, {tot['60:0.5']['any_tested']} of {tot['60:0.5']['fits']} and "
         f"{tot['60:0.8']['any_tested']} of {tot['60:0.8']['fits']} at $d=60$\\\\",
         "\\bottomrule", "\\end{tabularx}"]
    write_tex("tab_interp_calib", L)
    store("tab_interp_calib", N)


def sci(x, d=1):
    """x as a LaTeX number m.m\\cdot10^{e}."""
    if x == 0:
        return "0"
    e = int(math.floor(math.log10(abs(x)))); m = x / 10 ** e
    if round(m, d) >= 10:
        e += 1; m = x / 10 ** e
    return f"{m:.{d}f}" if e == 0 else f"{m:.{d}f}\\cdot10^{{{e}}}"


def dfg_err(suite, target, name="dfg13-perm"):
    """Test errors of DFG alone (the evaluation's merged result file): {n: [seed errors]}."""
    d = json.load(open(os.path.join(P11, "results", f"toy__{name}__{suite}.json")))
    return {n: row for n, row in zip(d["ns"], d["fns"][target]["err"])}


def p10_power(suite, target):
    return json.load(open(os.path.join(P10, "results", "toy_final", "power", f"{suite}__{target}.json")))


MOD3 = [("dlheld7", "f7_05"), ("dlheld6", "h6_00"), ("dlfamdev", "fd_10")]


def minority_rate(suite, target):
    """The test set's minority rate (the harness's fixed 4096 test inputs; no fit)."""
    if INTERP not in sys.path:
        sys.path.insert(0, INTERP)
    import dfg_hooks as H                                  # noqa: E402  loads the harness and the suite definitions
    fn = H.targets(suite, 30)[target]["fn"]
    _, yte = H.TH.test_data(fn, target, 30)
    m = float(np.mean(np.asarray(yte) == 1))
    return min(m, 1 - m)


@item
def tab_interp_mod3():
    """The three residue classes mod 3 of a signed count: exact low-degree weight (THEORY.md P4), DFG's test on the true
    block (Part 10's power files: the same code, inside v3), what the search's seeds see at n = 16384 (THEORY.md P4f;
    the sample sizes are Heuristic), and DFG alone's test error (result files)."""
    TH = json.load(open(THEORY))["P4"]["targets"]
    L = ["\\begin{tabular}{@{}llrrrrrrrr@{}}", "\\toprule",
         "& & & & & \\multicolumn{2}{c}{true block: test} & \\multicolumn{2}{c}{search's seeds} & DFG alone\\\\",
         "\\cmidrule(lr){6-7}\\cmidrule(lr){8-9}",
         "target & definition & $k$ & $W_1+W_2$ & peak & passes from & \\hd{over threshold\\\\at 16384} & \\hd{signal/noise\\\\at 16384} & \\hd{eigenvector\\\\needs $n$} & \\hd{error at\\\\16384}\\\\",
         "\\midrule"]
    out = {}
    for suite, t in MOD3:
        p = TH[t]; pw = p10_power(suite, t)
        cells = {c["n"]: c for c in pw["cells"]}
        nd = min(n for n, c in cells.items() if c["unfold"]["ratio"] > 1)
        r16 = cells[16384]["unfold"]["ratio"]
        e = dfg_err(suite, t); e16 = float(np.mean(e[16384]))
        assert len(set(e[16384])) == 1 and abs(e16 - minority_rate(suite, t)) < 1e-12   # a constant prediction
        dfn = p["desc"].replace("B mod 3", "B\\bmod3").replace("!=", "\\ne").replace("==", "=")
        out[t] = dict(k=p["k"], W1W2=p["W1W2"], peak=p["W_peak_degree"], nonzero=p["nonzero_nonconstant_chars"],
                      block_params=p["block_params"], detect_n=nd, ratio16384=r16, snr=p["pair_snr_n16384"],
                      n_bbp=p["n_bbp_heuristic"], n_deg1=p["n_degree1_heuristic"], err16384_seeds=e[16384], err16384_mean=e16)
        L.append(f"{tt(t)} & ${dfn}$ & {p['k']} & ${sci(p['W1W2'])}$ & {p['W_peak_degree']} & {nd} & {r16:.0f} & {p['pair_snr_n16384']:.3f} & "
                 f"${sci(p['n_bbp_heuristic'])}$ & {e16:.4f}\\\\")
    L += ["\\bottomrule", "\\end{tabular}"]
    assert [round(out[t]["ratio16384"]) for _, t in MOD3] == [134, 139, 155]
    write_tex("tab_interp_mod3", L)
    store("tab_interp_mod3", out)


@item
def num_interp_fail():
    """h5s1, h6_00 and the late signed-sum targets: DFG alone's result files, RESULTS.json, Part 10's files."""
    sys.path.insert(0, STUDY)
    import boolfuncs                                       # noqa: E402  the targets' definitions (numpy only)
    N = {}
    # h5s1 = [signed 9-input sum in A] xor x10 x11: its modulating pair, exactly (all 2^11 patterns of x1..x11)
    S5 = boolfuncs.make_dl_heldout5_suite(30)
    X = np.array([[1.0 if (i >> j) & 1 else -1.0 for j in range(11)] + [1.0] * 19 for i in range(2 ** 11)])
    f = S5["h5s1"]["fn"](X)
    y0 = float(f.mean()); c = float((f * X[:, 9] * X[:, 10]).mean())
    L2 = math.log(4 * 4 * math.comb(30, 2) / 0.1)
    nglob = 2 * L2 * (1 - y0 ** 2) / c ** 2
    n = 16384; thr = math.sqrt((1 - y0 ** 2) * 2 * L2 / n); sd = math.sqrt((1 - c ** 2) / n)
    Phi = lambda z: 0.5 * (1 + math.erf(z / math.sqrt(2)))
    ppass = Phi((abs(c) - thr) / sd) + Phi((-abs(c) - thr) / sd)
    pw = p10_power("dlheld5", "h5s1"); cells = {cc["n"]: cc for cc in pw["cells"]}
    e = dfg_err("dlheld5", "h5s1")
    N["h5s1"] = dict(desc=S5["h5s1"]["desc"], mean=y0, pair_coef=c, n_thr2=2 * L2, n_glob=nglob,
                     normal_pass_prob_16384=ppass, dfg_err=e, err0_seeds_16384=[s for s, v in enumerate(e[16384]) if v == 0],
                     max_err_below_16384=max(max(v) for k, v in e.items() if k < 16384),
                     min_err_below_16384=min(min(v) for k, v in e.items() if k < 16384),
                     p10_plain_ratio_16384=cells[16384]["unfold"]["ratio"], p10_mod_ratio_16384=cells[16384]["modulated"]["ratio"],
                     p10_mod_first_pass=min(k for k, cc in cells.items() if (cc["modulated"]["ratio"] or 0) > 1),
                     top_degree_weight=[len(pw["fourier_by_degree"]) - 1, pw["fourier_by_degree"][-1]],
                     W2=pw["fourier_by_degree"][2])
    assert abs(c + 1 / 32) < 1e-12 and abs(y0) < 1e-12
    # the refits of check_h5s1.py (n = 8192 and 16384, seeds 0-2; test errors equal to the result file)
    H5 = json.load(open(os.path.join(HERE, "check_h5s1.json")))
    assert H5["summary"]["all_equal_result_file"]
    N["h5s1"]["refits"] = [dict(n=f["n"], seed=f["seed"], err=f["err"], pair_round0_z=f["pair_round0_z"],
                                pair_feature=f["pair_is_feature"], pair_round=f["pair_admitted_in_round"], size=f["size"],
                                modulated_block_round=next((e["round"] for e in f["log"] if any(
                                    b.startswith("chi[x10,x11]*(") for b in e["blocks"])), None))
                           for f in H5["fits"]]
    for f in N["h5s1"]["refits"]:                          # the pair is a feature exactly where its round-0 test passes
        assert f["pair_feature"] == (f["pair_round0_z"] > 1) and (f["err"] == 0) == (f["modulated_block_round"] == 1)
    R = json.load(open(os.path.join(P11, "RESULTS.json")))
    cw = {x["target"]: x for x in R["q2_suites"]["dfg_clearly_worse_than_nets_best"]}
    nv = {x["target"]: x for x in R["q2_suites"]["dfg_never"]}
    eh = dfg_err("dlheld6", "h6_00")
    N["h6_00"] = dict(nets_best=cw["h6_00"]["nets_best"], variant=cw["h6_00"]["variant"], dfg_err16384=eh[16384],
                      never_for=sorted(nv))
    # the late signed-sum targets: DFG alone's n* (3 seeds) on the 54 sum-structured targets, with Part 10's accept kind
    # and the share of the target's variance at Fourier degrees 1-2, (W1 + W2) / (1 - W0) (toy_timing.csv)
    q2 = R["q2_suites"]; rows = list(csv.DictReader(open(os.path.join(P10, "tables", "toy_timing.csv"))))
    L = []
    for r in rows:
        v = q2[r["suite"]]["dfg"][r["target"]]
        L.append(dict(target=r["target"], suite=r["suite"], kind=r["kind"], mixture=r["mixture"], low2=float(r["low2"]),
                      nstar=float("inf") if v == "inf" else float(v)))
    L.sort(key=lambda x: x["nstar"])
    fin = [x for x in L if math.isfinite(x["nstar"])]
    late = fin[-6:]
    N["late"] = dict(targets=len(L), never=[x["target"] for x in L if not math.isfinite(x["nstar"])],
                     latest6=[[x["target"], x["kind"], x["mixture"], round(x["nstar"]), x["low2"]] for x in late],
                     latest6_low2=[min(x["low2"] for x in late), max(x["low2"] for x in late)],
                     arbitrary_pure=[x["target"] for x in L if x["kind"] == "arbitrary" and x["mixture"] == "pure"],
                     median_nstar_all=median(x["nstar"] for x in fin), median_low2_all=median(x["low2"] for x in L))
    assert len(L) == 54 and all(x[1] == "arbitrary" and x[2] == "pure" for x in N["late"]["latest6"])
    store("num_interp_fail", N)
    print(json.dumps(N, indent=1, default=float)[:2500])


@item
def tab_interp_atlas_targets():
    """Appendix: one row per atlas target: n*, the first n with a complete compact representation, the model at the
    first n with test error <= 0.1 and at n = 16384 (atlas_family.json, atlas_targets.csv)."""
    F = load_family(); T = load_targets()
    L = ["\\begin{tabular}{@{}llrrrrrrcrrc@{}}", "\\toprule",
         "& & & & \\multicolumn{5}{c}{first $n$ with test error $\\le0.1$} & \\multicolumn{3}{c}{$n=16384$}\\\\",
         "\\cmidrule(lr){5-9}\\cmidrule(lr){10-12}",
         "target & suite & $n^*_0$ ($n^*_3$) & complete & $n$ & error & var. & size & T / R / S & error & size & T / R / S\\\\",
         "\\midrule"]
    fmt_n = lambda v: "never" if v is None or not math.isfinite(v) else f"{v:.0f}"
    trs = lambda c: f"{c['T']:.2f} / {c['R']:.2f} / {c['S']:.2f}"
    out = {}
    for i, (fam, ts) in enumerate(FAMS):
        if i:
            L.append("\\addlinespace[2pt]")
        L.append(f"\\multicolumn{{12}}{{@{{}}l}}{{\\emph{{{fam}}}}}\\\\")
        for t in ts:
            r = T[t]; a, b = F[t]["first"], F[t]["last"]
            s0, s3 = _num(r["nstar0_alone"]), _num(r["nstar3_alone"])
            rf, rs = F[t]["rep_first"], F[t]["rep_stable"]
            comp = "--" if rf is None else (f"{rf}" + ("" if rs == rf else (f" ({rs})" if rs else " (--)")))
            first = (f"{a['n']} & {fe(a['err'])} & {'f' if a['variant'] else 'd'} & {a['size']} & {trs(a)}" if a
                     else "\\multicolumn{5}{c}{never}")
            L.append(f"{tt(t)} & {r['suite']} & {fmt_n(s0)} ({fmt_n(s3)}) & {comp} & {first} & {fe(b['err'])} & {b['size']} & {trs(b)}\\\\")
            out[t] = dict(nstar0=s0, nstar3=s3, rep_first=rf, rep_stable=rs, first=a, last=b)
    L += ["\\bottomrule", "\\end{tabular}"]
    write_tex("tab_interp_atlas_targets", L)
    store("tab_interp_atlas_targets", out)


def e4(e):
    return "0" if e == 0 else f"{e:.4f}"


@item
def tab_interp_spur():
    """Appendix: spurious terms by n on the 21 designed and 20 random targets, seed 0 (CALIB.md section 2.1)."""
    A2 = json.load(open(CALIB))["A2"]["by_n"]
    L = ["\\begin{tabular}{@{}rrrrrrrrr@{}}", "\\toprule",
         "& & & \\multicolumn{3}{c}{terms reading an irrelevant input} & \\multicolumn{2}{c}{spurious share of the output} & test error\\\\",
         "\\cmidrule(lr){4-6}\\cmidrule(lr){7-8}",
         "$n$ & \\hd{fits with\\\\error $\\le0.1$} & \\hd{admitted\\\\terms} & all (share) & \\hd{linear-block\\\\characters} & "
         "\\hd{others (share of\\\\the other terms)} & mean & max & \\hd{with / without\\\\them (mean)}\\\\", "\\midrule"]
    tot = dict(terms=0, spur=0, lin=0, other=0, other_terms=0)
    for n in NS:
        b = A2[str(n)]; a = b["all"]
        L.append(f"{n} & {b['n_learned']} & {a['terms']} & {a['spur_terms']} ({b['count_share_all']:.3f}) & {b['spur_by_cat']['chi_lin']} & "
                 f"{b['spur_excl_lin']}/{b['terms_excl_lin']} ({b['count_share_excl_lin']:.3f}) & {a['share_mean']:.3f} & {a['share_max']:.3f} & "
                 f"{e4(a['err_mean'])} / {e4(a['err_noS_mean'])}\\\\")
        tot["terms"] += a["terms"]; tot["spur"] += a["spur_terms"]; tot["lin"] += b["spur_by_cat"]["chi_lin"]
        tot["other"] += b["spur_excl_lin"]; tot["other_terms"] += b["terms_excl_lin"]
    L += ["\\midrule",
          f"all & & {tot['terms']} & {tot['spur']} ({tot['spur'] / tot['terms']:.3f}) & {tot['lin']} & {tot['other']}/{tot['other_terms']} "
          f"({tot['other'] / tot['other_terms']:.3f}) & & & \\\\", "\\bottomrule", "\\end{tabular}"]
    assert (tot["terms"], tot["spur"], tot["lin"], tot["other"], tot["other_terms"]) == (4499, 1047, 961, 86, 3364)
    write_tex("tab_interp_spur", L)
    store("tab_interp_spur", dict(by_n={n: A2[str(n)] for n in NS}, totals=tot,
                                  r0_class_searches=json.load(open(CALIB))["A2"]["r0_class_searches"],
                                  chi_test_spur=json.load(open(CALIB))["A2"]["chi_test_spur"]))


# =======================================================================================================================
# Part 2 (sections/interp_dyn.tex): its registered functions go here
# =======================================================================================================================
# When the structure appears (sec:interp-when), the order of acquisition against the Part 5 networks
# (sec:interp-order); sec:interp-compute quotes CALIB.md and needs no output.  Sources, all frozen (nothing is fitted):
#   study/part11/interp/theory/check_theory.json  P3: DFG's round-0 decisions against n_glob (test0) and the later-round
#                                                 classes (factors, entry_vs_nglob, entry_vs_nglob_all)      (THEORY.md)
#   study/part11/RESULTS.json                     q5_ablations: n* of strict / lenient and of DFG alone on the same seeds
#   study/part11/interp/ablations/families.py     the ablation analysis' assignment of the targets to families
#   study/part11/interp/ablations/ablations.json  ABLATIONS.md's numbers: the block threshold's move at the true
#                                                 blocks' detection points (block_thr_shift), n* against n_detect
#                                                 (block_gap), the paired null (nulls)
#   study/part11/interp/tables/atlas_targets.csv  n_struct (Part 10's rule) of DFG alone and of v3's member; n*_0
#   study/part10/interp/tables/toy_timing.csv     Part 10's n_detect, low-degree share and T / threshold at n_struct
#   study/part10/interp/VERIFICATION.json         the corrected detection points of the gate and multiplexer mixtures
#   study/part11/interp/order/tables/             order_chars.csv, order_numbers.json (ORDER.md, corrected)
# Outputs: figures/fig_dyn_when.pdf, fig_dyn_order.pdf; tables/tab_dyn_when.tex, tab_dyn_order.tex; the plotted and
# tabulated values and the numbers the text quotes under the functions' names in tables/interp_numbers.json (num_dyn).
DYN_ORDER = os.path.join(INTERP, "order", "tables")
DYN_RJ = os.path.join(P11, "RESULTS.json")
DYN_P10T = os.path.join(P10, "tables", "toy_timing.csv")
DYN_VER = os.path.join(P10, "VERIFICATION.json")
DYN_ABL = os.path.join(INTERP, "ablations")
DYN_K, DYN_DELTA, DYN_C, DYN_D = 4, 0.1, 1.0, 30          # DFG v1.3's defaults: K, delta, c; d of the toy suites
DYN_STRICT, DYN_LENIENT = 1e-4, 0.9                        # the ablations' delta (PROTOCOL.md, Q5)
DYN_SUITES = ["designed", "dlsymdev", "dlfamdev", "dlheld6", "dlheld7"]      # the five ablation suites
DYN_CLS = [("character", "character"), ("halfspace", "halfspace"), ("sum", "sum")]   # families.py's coarse classes
DYN_DEGCOL = {1: "#86b6ef", 2: "#5598e7", 3: "#2a78d6", 4: "#1c5cab", 5: "#0d366b"}   # order_report.py's degree ramp
DYN_BAND = {"char": "#eb6834", "sum": "#1baf7a"}
DYN_LABEL = {"strict": ("par3", "stair5", "f7_02"), "lenient": ("par4", "andxor", "sym7")}   # points named in the figure
# Part 10's verifier recomputed the detection points of the gate and multiplexer mixtures with the modulated statistic
# on the residual deflated by [1, chi_M], as DFG tests it (VERIFICATION.json, verify-reading:toy, claim C4; the same
# values as paper_learner/make_interp.py's NDETECT_CORR).  dyn_ndetect() checks the verifier's note before using them.
DYN_NDET_CORR = {"fd_11": 256, "h5s4": 256, "f7_03": 512, "f7_11": 1024, "h6_07": 512, "fd_08": 2048, "majsym": 512}


def _dnum(v):
    """A RESULTS.json / CSV value as a float: None for missing, inf for 'inf' / 'never'."""
    if v is None or v == "" or v == "–":
        return None
    if isinstance(v, str):
        if v in ("inf", "never"):
            return math.inf
        if v == "-inf":
            return -math.inf
    return float(v)


def _dl2(a, b):
    return math.log2(a / b)


def _dL(k, delta=DYN_DELTA, d=DYN_D):
    """The log term of DFG's global degree-k test: L_k = ln(4 K C(d, k) / delta) (THEORY.md section 0)."""
    return math.log(4 * DYN_K * math.comb(d, k) / delta)


def _dblock_t(k, delta=DYN_DELTA, d=DYN_D, mods=0):
    """The log term of the sum-block test for a block of k inputs, t = ln(4K C(d,k) 2^(k-1) 2 (1 + #mod) 24 / delta)."""
    return math.log(4 * DYN_K * math.comb(d, k) * 2 ** (k - 1) * 2 * (1 + mods) * 24 / delta)


def _dblock_shift(k, delta, m=None):
    """log2 of the factor by which the detection size of a k-input block moves when delta changes, if the statistic
    grows linearly in n (E T ~ m + n rho): T > m + 2 sqrt(m t) + 2t  <=>  n rho > 2 sqrt(m t) + 2t.  m = k groups - 1
    (one group per value of the signed sum, unfolded).  Heuristic: a first-order reading of the test."""
    m = k if m is None else m
    t0, t1 = _dblock_t(k), _dblock_t(k, delta)
    return math.log2((2 * math.sqrt(m * t1) + 2 * t1) / (2 * math.sqrt(m * t0) + 2 * t0))


def _dchar_shift(k, delta):
    """log2 of the factor by which n_glob of a degree-k character moves when delta changes (n_glob is linear in L_k)."""
    return math.log2(_dL(k, delta) / _dL(k))


def _dabl():
    """ABLATIONS.md's machine-readable numbers (ablations.py writes them; every number of ABLATIONS.md is in it)."""
    return json.load(open(os.path.join(DYN_ABL, "ablations.json")))


def _dfam():
    if DYN_ABL not in sys.path:
        sys.path.insert(0, DYN_ABL)
    import families                                                 # noqa: E402  the ablation analysis' assignment
    return families


def dyn_threshold_rows():
    """Per target of the five ablation suites: family, coarse class and log2(n*_ablation / n*_DFG alone) for strict and
    lenient (seeds 0 and 1, paired: DFG alone's n* from the same seeds), from RESULTS.json q5_ablations."""
    R = json.load(open(DYN_RJ))["q5_ablations"]; F = _dfam(); out = []
    for su in DYN_SUITES:
        for t in R["strict"]["suites"][su]["ablation"]:
            row = dict(suite=su, target=t, family=F.SHORT[F.family(su, t)], cls=F.coarse(su, t), mod3=(su, t) in F.MOD3)
            for ab in ("strict", "lenient"):
                S = R[ab]["suites"][su]
                assert S["status"] == "complete" and S["seeds"] == [0, 1] and S["seeds_as_protocol"], (ab, su)
                a, b = _dnum(S["ablation"][t]), _dnum(S["dfg_same_seeds"][t])
                row[ab + "_nstar"], row["alone_nstar"] = a, b
                row[ab] = _dl2(a, b) if math.isfinite(a) and math.isfinite(b) else None
                if row[ab] is not None:                         # the per-target ratio RESULTS.json stores
                    assert abs(row[ab] - S["summary"]["ratios"][t]) < 1e-9, (ab, su, t)
            out.append(row)
    return out


def dyn_class_summary(rows, ab):
    out = {}
    for c, _ in DYN_CLS:
        sel = [r for r in rows if r["cls"] == c]; f = [r[ab] for r in sel if r[ab] is not None]
        out[c] = dict(targets=len(sel), both=len(f), mean=float(np.mean(f)), mean_abs=float(np.mean(np.abs(f))),
                      higher=sum(x > 0.25 for x in f), lower=sum(x < -0.25 for x in f),
                      within_002=sum(abs(x) <= 0.02 for x in f), neither=[r["target"] for r in sel if r[ab] is None])
    return out


def _dbeeswarm(ys, w=0.062, h=0.045):
    """Horizontal offsets that keep markers at nearly equal y apart (deterministic)."""
    order = sorted(range(len(ys)), key=lambda i: ys[i]); placed = []; off = [0.0] * len(ys)
    for i in order:
        for s in [0] + [v for j in range(1, 40) for v in (j, -j)]:
            if all(not (ps == s and abs(ys[i] - py) < h) for ps, py in placed):
                off[i] = s * w; placed.append((s, ys[i])); break
    return off


@item
def fig_dyn_when():
    """(a) DFG's round-0 decision against n_glob (THEORY.md P3, check_theory.json P3.test0); (b, c) the threshold
    ablations by class of target, against the moves expected if the test set n*."""
    P3 = json.load(open(THEORY))["P3"]; cal = P3["test0"]["calibration"]; rows = dyn_threshold_rows()
    mix = {k: v["mixture"] for k, v in dyn_ndetect().items()}       # Part 10's kind of mixture, for the stored lists
    fig, axs = plt.subplots(1, 3, figsize=(W, 2.75), gridspec_kw=dict(width_ratios=[1.0, 1.12, 1.12], wspace=0.42))
    # (a) pass rate by band of log2(n / n_glob)
    ax = axs[0]; xs = []
    for b in cal:
        lo, hi = b["lo"], b["hi"]
        xs.append(-2.45 if not math.isfinite(lo) else (2.45 if not math.isfinite(hi) else (lo + hi) / 2))
    ax.plot(xs, [b["predicted"] for b in cal], "-", color="#8a8a8a", lw=1.0, zorder=2, label="normal approx.")
    ax.scatter(xs, [b["observed"] for b in cal], s=[5 + 1.6 * math.sqrt(b["pairs"]) for b in cal], color="#2a78d6",
               edgecolors="white", linewidths=0.5, zorder=3, label="DFG")
    ax.axvline(0, color=INK2, lw=0.6, ls=":")
    ax.set_xticks([-2.45, -1, 0, 1, 2.45]); ax.set_xticklabels(["≤−2", "−1", "0", "1", ">2"])
    ax.set_xlim(-2.8, 2.8); ax.set_ylim(-0.04, 1.04)
    ax.set_xlabel("log$_2$(n / n$_{\\rm glob}$)"); ax.set_ylabel("share of (character, n) pairs admitted")
    t0 = P3["test0"]
    ax.set_title(f"(a) round-0 test, {t0['pairs']} pairs", loc="left")
    ax.text(-2.65, 0.97, f"agrees with\nn > n$_{{\\rm glob}}$ in {t0['agree']}\n({100 * t0['agree_frac']:.1f}%)",
            fontsize=7, color=INK, va="top")
    # no legend: points = DFG's decisions (area ~ sqrt(pairs)), line = the normal approximation (the caption says so)
    ax.grid(True, color=GRID, lw=0.4); ax.set_axisbelow(True)
    # (b), (c) strict and lenient
    ch = {ab: (_dchar_shift(4, dl), _dchar_shift(1, dl)) for ab, dl in (("strict", DYN_STRICT), ("lenient", DYN_LENIENT))}
    A = _dabl(); bts = A["block_thr_shift"]
    bl = {ab: [bts[ab]["min"], bts[ab]["max"]] for ab in ("strict", "lenient")}   # ABLATIONS.md section 2
    gap = {r["target"]: r["gap"] for r in A["block_gap"]["rows"]}                  # log2(n* / n_detect), seeds 0-1
    far = {t for t, g in gap.items() if g >= 1}
    assert len(far) == A["block_gap"]["gap_ge1"]
    lab = {}; XP = [0, 1.2, 2.45]                                    # x positions of the three classes
    for ax, ab, ttl in ((axs[1], "strict", "(b) strict, δ = 10$^{-4}$ (+6.9 nats)"),
                        (axs[2], "lenient", "(c) lenient, δ = 0.9 (−2.2 nats)")):
        lo, hi = sorted(ch[ab]); ax.add_patch(plt.Rectangle((-0.45, lo), XP[1] + 0.9, hi - lo, color=DYN_BAND["char"], alpha=0.16, lw=0, zorder=1))
        lo, hi = min(bl[ab]), max(bl[ab]); ax.add_patch(plt.Rectangle((XP[2] - 0.6, lo), 1.2, hi - lo, color=DYN_BAND["sum"], alpha=0.22, lw=0, zorder=1))
        ax.axhline(0, color=INK2, lw=0.6)
        for i, (c, _) in enumerate(DYN_CLS):
            x0 = XP[i]; sel = [r for r in rows if r["cls"] == c and r[ab] is not None]; ys = [r[ab] for r in sel]
            off = _dbeeswarm(ys)
            ax.scatter([x0 + o for o in off], ys, s=7, color="#2a78d6" if c != "sum" else "#1a7f5a", edgecolors="white",
                       linewidths=0.3, zorder=3)
            rg = [(x0 + o, r[ab]) for r, o in zip(sel, off) if f"{r['suite']}/{r['target']}" in far]
            if rg:
                ax.scatter([a for a, _ in rg], [b for _, b in rg], s=26, facecolors="none", edgecolors=INK, linewidths=0.6,
                           zorder=4)
            for r, o in zip(sel, off):
                if r["target"] in DYN_LABEL[ab]:
                    ax.annotate(r["target"], (x0 + o, r[ab]), xytext=(4, -2.5), textcoords="offset points", fontsize=7,
                                color=INK2)
                    lab.setdefault(ab, []).append([r["target"], round(r[ab], 3)])
        S = dyn_class_summary(rows, ab)
        ax.set_xticks(XP)
        ax.set_xticklabels([{"sum": "symmetric,\nmixture"}.get(c, c) + f"\n({S[c]['both']}" +
                            ("" if S[c]["both"] == S[c]["targets"] else f" of {S[c]['targets']}") + ")" for c, _ in DYN_CLS])
        ax.set_xlim(-0.62, XP[2] + 0.7); ax.set_ylim(-1.0, 1.12)
        ax.set_title(ttl, loc="left"); ax.grid(True, axis="y", color=GRID, lw=0.4); ax.set_axisbelow(True)
        if ab == "strict":
            ax.set_ylabel("log$_2$(n* ablation / n* DFG alone)")
    hs = [plt.Rectangle((0, 0), 1, 1, color=DYN_BAND["char"], alpha=0.3, lw=0),
          plt.Rectangle((0, 0), 1, 1, color=DYN_BAND["sum"], alpha=0.4, lw=0),
          Line2D([], [], marker="o", ls="", markerfacecolor="none", markeredgecolor=INK, markeredgewidth=0.7, markersize=5.5)]
    fig.legend(hs, ["move expected if the global character test set n* (degrees 1–4)",
                    "move of the true block's threshold at its detection point (the 33 targets)",
                    f"n* a doubling or more beyond the true block's detection point ({len(far)} targets)"],
               loc="lower left", ncol=1, frameon=False, fontsize=7, bbox_to_anchor=(0.33, -0.02))
    fig.subplots_adjust(left=0.075, right=0.99, top=0.9, bottom=0.36)
    save_fig(fig, "fig_dyn_when")
    store("fig_dyn_when", dict(
        source=dict(test0="study/part11/interp/theory/check_theory.json P3.test0",
                    ablations="study/part11/RESULTS.json q5_ablations (strict, lenient)",
                    families="study/part11/interp/ablations/families.py (coarse classes)",
                    ablation_analysis="study/part11/interp/ablations/ablations.json (block_thr_shift, block_gap, nulls)"),
        calibration=cal, pairs=t0["pairs"], agree=t0["agree"], agree_frac=t0["agree_frac"],
        fp=t0["fp"], fn=t0["fn"], fp_within_1=t0["fp_within_1"], fn_within_1=t0["fn_within_1"],
        calibration_max_abs_diff=t0["calibration_max_abs_diff"],
        char_shift={ab: dict(deg4=v[0], deg1=v[1]) for ab, v in ch.items()},
        block_shift={ab: dict(min=v[0], max=v[1], median=bts[ab]["median"]) for ab, v in bl.items()},
        far_targets={t: dict(gap=gap[t], strict=next(r["strict"] for r in rows if f"{r['suite']}/{r['target']}" == t),
                             lenient=next(r["lenient"] for r in rows if f"{r['suite']}/{r['target']}" == t)) for t in sorted(far)},
        paired_null=A["nulls"]["paired_seed01"]["pooled"],
        by_class={ab: dyn_class_summary(rows, ab) for ab in ("strict", "lenient")}, labelled=lab,
        sum_by_family={ab: {fam: dict(both=sum(1 for r in rows if r["cls"] == "sum" and r["family"] == fam and r[ab] is not None),
                                      within_002=sum(1 for r in rows if r["cls"] == "sum" and r["family"] == fam and r[ab] is not None and abs(r[ab]) <= 0.02),
                                      max_abs=max(abs(r[ab]) for r in rows if r["cls"] == "sum" and r["family"] == fam and r[ab] is not None),
                                      moved=sorted([[r["target"], round(r[ab], 2), mix.get((r["suite"], r["target"]))] for r in rows
                                                    if r["cls"] == "sum" and r["family"] == fam and r[ab] is not None and abs(r[ab]) > 0.25],
                                                   key=lambda x: -x[1]))
                                for fam in ("symmetric", "mixtures")} for ab in ("strict", "lenient")},
        per_target=rows))


def dyn_ndetect():
    """Part 10's n_detect with the verifier's corrections, after checking that the verifier's note gives them."""
    V = json.load(open(DYN_VER)); note = ""
    for a in V["agents"]:
        if a["label"] == "verify-reading:toy":
            note = " ".join(v.get("note", "") for v in a["result"]["verdicts"] if v["id"].startswith("C4"))
    for s in ("Corrected n_detect: 256, 256, 512 and 1024", "h6_07 is 0.79 at 256 and passes at 512",
              "the plain block passes at 2048 and 512"):
        assert s in note, s
    T = {}
    for r in csv.DictReader(open(DYN_P10T)):
        r = dict(r); r["n_detect_p10"] = int(r["n_detect"]); r["n_detect"] = DYN_NDET_CORR.get(r["target"], r["n_detect_p10"])
        T[(r["suite"], r["target"])] = r
    assert len(T) == 54
    return T


@item
def tab_dyn_when():
    """(a) The classes of later rounds against n_glob (THEORY.md P3c; check_theory.json P3.factors, entry_vs_nglob,
    entry_vs_nglob_all).  (b) The 13 sum-structured targets of the atlas: Part 10's detection point against DFG alone's
    n_struct (atlas_targets.csv; toy_timing.csv; VERIFICATION.json)."""
    P3 = json.load(open(THEORY))["P3"]; F, E, EA = P3["factors"], P3["entry_vs_nglob"], P3["entry_vs_nglob_all"]
    names = [("global_r0", "global test, round 0"), ("global_r1+", "global test, rounds $\\ge1$"), ("ext1", "extension by one input"),
             ("ext2", "extension by two inputs"), ("local", "local (subsets of the inputs in use)")]
    A = []
    L = ["\\begin{tabular}{@{}lrrrrrr@{}}", "\\toprule",
         "\\multicolumn{7}{@{}l}{(a) Characters by the class that first admits them: 41 targets, seed 0, every grid $n$}\\\\",
         "\\midrule",
         "class & characters & \\hd{below $n_{\\rm glob}$\\\\(doublings)} & \\hd{class gain\\\\(doublings)} & "
         "\\hd{union bound\\\\$L_{\\rm glob}/L_{\\rm cls}$} & \\hd{residual\\\\$(1-\\hat y_\\emptyset^2)/s_j^2$} & "
         "\\hd{coefficient\\\\$v_{S,j}^2/\\hat y_S^2$}\\\\", "\\midrule"]
    for key, lab in names:
        if key == "global_r0":
            g = EA["global_r0"]
            row = dict(cls=key, chars=g["count"], below=-g["median_log2_first_over_nglob_deg_le6"])
            L.append(f"{lab} & {g['count']} & ${row['below']:+.2f}$ & -- & 1 & 1 & 1\\\\")
        else:
            e, f = E[key], F[key]
            assert e["count"] == f["count"]
            row = dict(cls=key, chars=e["count"], chars_deg_le6=e["deg_le6"], below=e["median_log2_nglob_over_nfirst_deg_le6"],
                       gain=f["median_log2_gain"], L=f["median_L_ratio"], s=f["median_s_ratio"], v=f["median_v_ratio"])
            cnt = f"{e['count']}" + (f" ({e['deg_le6']})" if e["deg_le6"] != e["count"] else "")
            L.append(f"{lab} & {cnt} & ${row['below']:+.1f}$ & {row['gain']:.1f} & {row['L']:.2f} & {row['s']:.1f} & {row['v']:.2f}\\\\")
        A.append(row)
    L += ["\\bottomrule", "\\end{tabular}", "", "\\medskip", ""]
    # (b) the sum-structured atlas targets
    T = dyn_ndetect(); B = []
    for r in csv.DictReader(open(os.path.join(ATAB, "atlas_targets.csv"))):
        p = T.get((r["suite"], r["target"]))
        if p is None:
            continue
        na, nv = _dnum(r["n_struct_p10rule_alone"]), _dnum(r["n_struct_p10rule_v3"])
        assert (na is None) == (nv is None) and (na is None or na == nv), r["target"]   # alone = v3's member (ATLAS.md 3)
        nd = p["n_detect"]
        B.append(dict(suite=r["suite"], target=r["target"], kind=p["kind"], mixture=p["mixture"], k=int(p["k_power"]),
                      low2=float(p["low2"]), n_detect=nd, n_detect_p10=p["n_detect_p10"], n_struct=na, n_struct_v3=nv,
                      delay=_dl2(na, nd) if na else None, nstar0=_dnum(r["nstar0_alone"]),
                      ratio_at_struct=_dnum(p["ratio_at_struct"]) if p["mixture"] == "pure" else None))
    assert len(B) == 13
    B.sort(key=lambda b: (b["mixture"] != "pure", b["n_struct"] or 2 ** 20, b["target"]))
    L += ["\\begin{tabular}{@{}llrrrrrr@{}}", "\\toprule",
          "\\multicolumn{8}{@{}l}{(b) The 13 sum-structured targets of the structure atlas: DFG alone, seed 0}\\\\", "\\midrule",
          "target & form & $k$ & \\hd{low-degree\\\\share} & $n_{\\rm detect}$ & \\hd{$n_{\\rm struct}$\\\\(alone $=$ v3)} & "
          "\\hd{delay\\\\(doublings)} & $n^*_0$\\\\", "\\midrule"]
    for b in B:
        form = b["kind"].replace("+", "/").replace("modular", "mod") + ("" if b["mixture"] == "pure" else f"; {b['mixture']}")
        nd = f"{b['n_detect']}" + ("$^\\dagger$" if b["n_detect"] != b["n_detect_p10"] else "")
        ns = "never" if b["n_struct"] is None else f"{b['n_struct']:.0f}"
        dl = "--" if b["delay"] is None else ("0" if b["delay"] == 0 else f"${b['delay']:+.0f}$")
        n0 = "never" if not math.isfinite(b["nstar0"]) else f"{b['nstar0']:.0f}"
        L.append(f"{tt(b['target'])} & {form} & {b['k']} & {b['low2']:.3f} & {nd} & {ns} & {dl} & {n0}\\\\")
    L += ["\\bottomrule", "\\end{tabular}"]
    write_tex("tab_dyn_when", L)
    found = [b for b in B if b["delay"] is not None]
    store("tab_dyn_when", dict(
        source=dict(classes="study/part11/interp/theory/check_theory.json P3.factors, P3.entry_vs_nglob, P3.entry_vs_nglob_all",
                    targets="study/part11/interp/tables/atlas_targets.csv; study/part10/interp/tables/toy_timing.csv; "
                            "study/part10/interp/VERIFICATION.json (verify-reading:toy, C4)"),
        classes=A, targets=B,
        delay_counts=dict(zero=[b["target"] for b in found if b["delay"] == 0],
                          one=[b["target"] for b in found if b["delay"] == 1],
                          two_plus=[[b["target"], b["delay"]] for b in found if b["delay"] >= 2],
                          never=[b["target"] for b in B if b["delay"] is None]),
        p3_first=P3["first"]["counts"], p3_early_routes=P3["early_routes"], p3_late=P3["late"]["z_below_1_at_pred"]))


def _dorder():
    rows = list(csv.DictReader(open(os.path.join(DYN_ORDER, "order_chars.csv"))))
    N = json.load(open(os.path.join(DYN_ORDER, "order_numbers.json")))
    return rows, N


DYN_TARGETS = ["sparsepoly", "stair5", "mux", "majpar", "rmaj9", "andxor", "dlist5", "parmaj", "dnf3", "rand1", "rand3"]


@item
def fig_dyn_order():
    """The order figure of ORDER.md (order_report.py's fig_order), re-plotted at the paper's width with 7-pt text:
    per target, the networks' onset step online against the smallest n from which the final model carries each Fourier
    character, for DFG alone (median of 3 seeds) and the networks' fixed-n study (|S| <= 4); last panel: the taus."""
    rows, N = _dorder(); NEV = 2 ** 15.4
    fig, axs = plt.subplots(3, 4, figsize=(W, 6.55))
    big = {"rmaj9", "dlist5", "dnf3"}; plotted = {}; jit = [0.0]
    for k, fn in enumerate(DYN_TARGETS):
        ax = axs.flat[k]; R = [r for r in rows if r["target"] == fn]; plotted[fn] = len(R)
        ax.axhspan(2 ** 15.0, 2 ** 15.8, color="#f0efec", lw=0)
        if fn in big:                                               # one marker per (degree, |yhat|) group, as ORDER.md
            G = {}
            for r in R:
                G.setdefault((int(r["deg"]), round(abs(float(r["yhat"])), 4)), []).append(r)
            for (dg, ay), rr in sorted(G.items()):
                xs = np.array([float(r["net_onset_online"]) for r in rr]); x = float(np.median(xs))
                yy = None
                for key, mk in (("dfg_n_onset_median", "o"), ("net_n_onset_median", "s")):
                    ys = [_dnum(r[key]) for r in rr if _dnum(r[key]) is not None]
                    if not ys:
                        continue
                    y = float(np.median([v if math.isfinite(v) else NEV for v in ys])); yy = y if yy is None else yy
                    sz = 6 + 3.2 * math.sqrt(len(rr)); c = DYN_DEGCOL[min(dg, 5)]
                    ax.scatter([x], [y], s=sz, marker=mk, facecolors=c if mk == "o" else "none", edgecolors=c,
                               linewidths=0.9 if mk == "s" else 0.4, zorder=3 if mk == "o" else 4)
                lo, hi = np.percentile(xs, [10, 90])
                ax.plot([lo, hi], [yy, yy], color=DYN_DEGCOL[min(dg, 5)], lw=0.7, alpha=0.6, zorder=2)
        else:
            seen = {}
            for r in sorted(R, key=lambda r: int(r["deg"])):
                x = float(r["net_onset_online"]); c = DYN_DEGCOL[min(int(r["deg"]), 5)]
                for key, mk in (("dfg_n_onset_median", "o"), ("net_n_onset_median", "s")):
                    y = _dnum(r[key])
                    if y is None:
                        continue
                    y = y if math.isfinite(y) else NEV
                    kk = (key, round(math.log10(x), 2), y); j = seen.get(kk, 0); seen[kk] = j + 1
                    dj = 0.13 * ((j + 1) // 2) * (1 if j % 2 else -1); yj = y * 2 ** dj   # coinciding points offset
                    jit.append(abs(dj))
                    if mk == "o":
                        ax.scatter([x], [yj], s=13, marker="o", facecolors=c, edgecolors="white", linewidths=0.4, zorder=3)
                    else:
                        ax.scatter([x], [yj], s=15, marker="s", facecolors="none", edgecolors=c, linewidths=0.9, zorder=4)
            lab = {"mux": ("x1x2x3x4", "x1x2x3x4", (3, -9), "left"), "majpar": ("x1x2x3x4x5x6", "x1⋯x6", (-2, 5), "right")}
            for r in R:
                if fn in lab and r["char"] == lab[fn][0]:
                    y = _dnum(r["dfg_n_onset_median"]); y = NEV if not math.isfinite(y) else y
                    ax.annotate(lab[fn][1], (float(r["net_onset_online"]), y), xytext=lab[fn][2], textcoords="offset points",
                                fontsize=7, color=INK2, ha=lab[fn][3])
        ax.set_title(f"{fn} ({len(R)})", loc="left", fontsize=7.5)
        ax.set_xscale("log"); ax.set_yscale("log", base=2)
        ax.set_ylim(2 ** 3.5, 2 ** 15.8); ax.set_yticks([16, 64, 256, 1024, 4096, 16384, NEV])
        ax.set_yticklabels(["16", "64", "256", "1024", "4096", "16384", "never"] if k % 4 == 0 else [])
        ax.yaxis.set_minor_locator(matplotlib.ticker.NullLocator())
        ax.set_xlim(30, 4000); ax.grid(True, color=GRID, lw=0.4, zorder=0); ax.set_axisbelow(True)
        for sp in ("top", "right"):
            ax.spines[sp].set_visible(False)
        if k % 4 == 0:
            ax.set_ylabel("n from which the model\ncarries the character")

    ax = axs.flat[11]                                                # the taus per target
    kinds = [("tau_net_time_dfg_n", "net time vs DFG n", "o", "#2a78d6", "#2a78d6"),
             ("tau_n_axis", "net n vs DFG n", "s", "none", "#eb6834"),
             ("tau_net_time_net_n", "net time vs net n", "D", "#1baf7a", "#1baf7a")]
    taus = {}
    for q, (key, lab_, mk, fc, ec) in enumerate(kinds):
        ys = np.arange(len(DYN_TARGETS))[::-1] + (q - 1) * 0.24
        xs = [N["targets"][fn][key] for fn in DYN_TARGETS]; taus[key] = dict(zip(DYN_TARGETS, xs))
        ax.scatter([x if x is not None else np.nan for x in xs], ys, marker=mk, s=11, facecolors=fc, edgecolors=ec,
                   linewidths=0.8, label=lab_, zorder=3)
    ax.axvline(0, color=INK2, lw=0.6)
    ax.set_yticks(np.arange(len(DYN_TARGETS))[::-1]); ax.set_yticklabels(DYN_TARGETS)
    ax.set_xlim(-1, 1); ax.set_xticks([-1, 0, 1]); ax.set_xlabel("Kendall τ$_b$")
    ax.grid(True, axis="x", color=GRID, lw=0.4); ax.set_axisbelow(True)
    for sp in ("top", "right"):
        ax.spines[sp].set_visible(False)
    ax.set_title("τ per target", loc="left", fontsize=7.5)
    hs = [Line2D([], [], marker="o", ls="", markerfacecolor=INK2, markeredgecolor="white", markersize=4.5, label="DFG alone"),
          Line2D([], [], marker="s", ls="", markerfacecolor="none", markeredgecolor=INK2, markersize=4.5, label="networks, fixed n")]
    hs += [Line2D([], [], marker="o", ls="", markerfacecolor=DYN_DEGCOL[d], markeredgecolor=DYN_DEGCOL[d], markersize=4.5,
                  label=f"degree {d}" if d < 5 else "degree ≥ 5") for d in range(1, 6)]
    l1 = fig.legend(handles=hs, loc="lower center", ncol=7, frameon=False, fontsize=7, bbox_to_anchor=(0.5, 0.028),
                    columnspacing=0.9, handletextpad=0.15)
    hs = [Line2D([], [], marker=mk, ls="", markerfacecolor=fc, markeredgecolor=ec, markersize=4.5, label="τ(" + lab_.replace(" vs ", ", ") + ")")
          for key, lab_, mk, fc, ec in kinds]
    fig.legend(handles=hs, loc="lower center", ncol=3, frameon=False, fontsize=7, bbox_to_anchor=(0.5, -0.008),
               columnspacing=1.2, handletextpad=0.15)
    fig.add_artist(l1)
    fig.text(0.40, 0.088, "network onset step (online, seed mean)", ha="center", fontsize=7.5)
    fig.subplots_adjust(left=0.115, right=0.985, top=0.968, bottom=0.145, wspace=0.13, hspace=0.36)
    p = axs.flat[11].get_position(); axs.flat[11].set_position([p.x0 + 0.075, p.y0, p.width - 0.075, p.height])
    save_fig(fig, "fig_dyn_order")
    store("fig_dyn_order", dict(source="study/part11/interp/order/tables/order_chars.csv, order_numbers.json (targets)",
                                characters=plotted, taus=taus, max_vertical_offset_doublings=max(jit)))


@item
def tab_dyn_order():
    """(a) DFG's rounds by n (order_numbers.json rounds_by_n); (b) per target: the round-0 priority, the n-axis orders
    and what each order follows (order_numbers.json targets, priority, degree_vs_size, net_n_resolution)."""
    rows, N = _dorder(); RB = N["rounds_by_n"]; ns = sorted(RB, key=int)
    L = ["\\begin{tabular}{@{}l" + "r" * len(ns) + "@{}}", "\\toprule",
         f"\\multicolumn{{{len(ns) + 1}}}{{@{{}}l}}{{(a) DFG's rounds: 11 targets $\\times$ 3 seeds $=33$ fits per $n$}}\\\\",
         "\\midrule", "$n$ & " + " & ".join(ns) + "\\\\", "\\midrule",
         "fits whose characters enter in $\\ge2$ rounds & " + " & ".join(str(RB[n]["multi_round"]) for n in ns) + "\\\\",
         "\\quad mean $\\tau$(network time, DFG round) & " +
         " & ".join("--" if RB[n]["tau_half_multi_mean"] is None else f"{RB[n]['tau_half_multi_mean']:.2f}" for n in ns) + "\\\\",
         "\\quad of which positive & " + " & ".join(str(RB[n]["tau_half_multi_positive"]) if RB[n]["multi_round"] else "--" for n in ns) + "\\\\",
         "\\bottomrule", "\\end{tabular}", "", "\\medskip", ""]
    for n in ns:
        assert RB[n]["cells"] == 33
    def f(v):
        return "tied" if v is None else f"${v:+.2f}$"
    L += ["\\begin{tabular}{@{}lrrrrrrrr@{}}", "\\toprule",
          "\\multicolumn{9}{@{}l}{(b) Per target: Kendall $\\tau_b$ over its Fourier characters (positive: same order)}\\\\", "\\midrule",
          " & & \\multicolumn{5}{c}{order against order} & \\multicolumn{2}{c}{against degree / $1/|\\hat y|$}\\\\",
          "\\cmidrule(lr){3-7}\\cmidrule(l){8-9}",
          "target & chars & \\hd{net time,\\\\DFG $z_0$} & \\hd{net time,\\\\DFG $n$} & \\hd{pairs\\\\c / t / i} & "
          "\\hd{net $n$, DFG $n$\\\\($|S|\\le4$)} & \\hd{net time,\\\\net $n$} & \\hd{net time} & \\hd{DFG $n$}\\\\",
          "\\midrule"]
    per = {}
    for fn in DYN_TARGETS:
        T = N["targets"][fn]; P = N["priority"][fn]["16384"]["tau_z0"]; DS = N["degree_vs_size"][fn]; pr = T["pairs_n"]
        z0 = float(np.mean(P)); nch = sum(r["target"] == fn for r in rows)
        def ds(a, b):
            return ("tied" if DS[a] is None else f"${DS[a]:+.2f}$") + "\\,/\\," + ("tied" if DS[b] is None else f"${DS[b]:+.2f}$")
        per[fn] = dict(chars=nch, tau_z0_16384=z0, tau_z0_seeds=P, tau_net_time_dfg_n=T["tau_net_time_dfg_n"], pairs=pr,
                       tau_n_axis=T["tau_n_axis"], n_axis_chars=T["n_axis_chars"], tau_net_time_net_n=T["tau_net_time_net_n"],
                       degree_vs_size=DS)
        L.append(f"{fn} & {nch} & ${z0:+.2f}$ & {f(T['tau_net_time_dfg_n'])} & "
                 f"{pr['concordant']}\\,/\\,{pr['tied']}\\,/\\,{pr['inverted']} & {f(T['tau_n_axis'])} ({T['n_axis_chars']}) & "
                 f"{f(T['tau_net_time_net_n'])} & {ds('net_time_deg', 'net_time_size')} & {ds('dfg_n_deg', 'dfg_n_size')}\\\\")
    rz = N["net_n_resolution"]["dnf3_resolvable"]
    L.append(f"dnf3$^*$ & {rz['count']} & & & & {f(rz['tau_n_axis'])} ({rz['count']}) & {f(rz['tau_net_time_net_n'])} & & \\\\")
    L += ["\\bottomrule", "\\end{tabular}"]
    write_tex("tab_dyn_order", L)
    # the numbers the text quotes, recomputed from the same file
    pos = {c: [N["priority"][fn][c]["tau_z0"] for fn in DYN_TARGETS] for c in ("online", "16384", "2048", "512")}
    means = {c: [float(np.mean(v)) for v in pos[c]] for c in pos}
    seeds = [x for c in pos for v in pos[c] for x in v]
    tn = [per[fn]["tau_net_time_dfg_n"] for fn in DYN_TARGETS if per[fn]["tau_net_time_dfg_n"] is not None]
    tl = [per[fn]["tau_n_axis"] for fn in DYN_TARGETS if per[fn]["tau_n_axis"] is not None]
    tt_ = [per[fn]["tau_net_time_net_n"] for fn in DYN_TARGETS]
    sizes_differ = [fn for fn in DYN_TARGETS if N["degree_vs_size"][fn]["net_time_size"] is not None]
    store("tab_dyn_order", dict(
        source="study/part11/interp/order/tables/order_numbers.json (rounds_by_n, targets, priority, degree_vs_size, "
               "net_n_resolution, data_cost, endpoints, checks, mechanism), order_chars.csv",
        rounds_by_n={n: {k: v for k, v in RB[n].items() if k not in ("tau_half",)} for n in ns},
        single_round={n: RB[n]["cells"] - RB[n]["multi_round"] for n in ("512", "2048", "16384")},
        per_target=per,
        priority=dict(cells_positive=sum(m > 0 for c in means for m in means[c]), cells=sum(len(means[c]) for c in means),
                      seeds_positive=sum(x > 0 for x in seeds), seeds=len(seeds), seeds_zero=sum(x == 0 for x in seeds),
                      at_16384=dict(min=min(means["16384"]), max=max(means["16384"]), median=float(np.median(means["16384"])))),
        n_axis=dict(net_time_dfg_n=dict(targets=len(tn), min=min(tn), max=max(tn), median=float(np.median(tn))),
                    like_for_like=dict(targets=len(tl), min=min(tl), max=max(tl), median=float(np.median(tl))),
                    net_time_net_n=dict(targets=len(tt_), min=min(tt_), max=max(tt_), median=float(np.median(tt_))),
                    with_dnf3_resolvable=N["net_n_resolution"]["with_dnf3_resolvable"], dnf3_resolvable=rz),
        degree_vs_size=dict(sizes_differ=sizes_differ,
                            net_time_degree_wins=[fn for fn in sizes_differ if N["degree_vs_size"][fn]["net_time_deg"] > N["degree_vs_size"][fn]["net_time_size"]],
                            dfg_n_size_wins=[fn for fn in sizes_differ if N["degree_vs_size"][fn]["dfg_n_size"] > N["degree_vs_size"][fn]["dfg_n_deg"]]),
        data_cost=N["data_cost"], data_cost_small_without_dnf3=N["net_n_resolution"]["data_cost_small_without_dnf3"],
        endpoints={n: {k: v for k, v in N["endpoints"][n].items() if k != "per_target"} for n in N["endpoints"]},
        mechanism=dict(how_at_onset_all=N["mechanism"]["how_at_onset_all"],
                       by_how=N["mechanism"]["log2_dfgn_over_nglob_by_how"],
                       by_how_without_dnf3=N["mechanism"]["log2_dfgn_over_nglob_by_how_without_dnf3"]),
        nonmonotone={k: v for k, v in N["nonmonotone"].items() if k in ("dfg_dropped", "dfg_total", "net_dropped", "net_total")},
        mux=[{k: r[k] for k in ("char", "deg", "yhat", "net_onset_online", "net_n_onset_median", "dfg_n_onset_median",
                                 "dfg_n_onset_seeds", "dfg_how_at_onset_seeds", "n_glob")} for r in rows if r["target"] == "mux"]))


@item
def num_dyn():
    """Numbers sec:interp-when quotes that no figure or table shows: the log terms and the parity thresholds under the
    three deltas (THEORY.md section 0 and P2), and Part 10's T / threshold at n_struct on the pure symmetric targets."""
    L = {k: _dL(k) for k in range(1, 5)}
    nthr = {f"k{k}": {ab: 2 * DYN_C ** 2 * _dL(k, dl) for ab, dl in (("default", DYN_DELTA), ("strict", DYN_STRICT), ("lenient", DYN_LENIENT))}
            for k in (2, 3, 4)}
    assert abs(nthr["k3"]["default"] - 26.77) < 0.01 and abs(nthr["k4"]["default"] - 30.59) < 0.01      # THEORY.md P2
    T = dyn_ndetect(); pure = [r for r in T.values() if r["mixture"] == "pure"]
    ra = sorted(float(r["ratio_at_struct"]) for r in pure if r["ratio_at_struct"])
    found = [r for r in T.values() if r["n_struct"]]
    dl = [_dl2(int(r["n_struct"]), r["n_detect"]) for r in found]
    from scipy.stats import chi2
    lin = {}                                                         # the linear block's threshold at d = 30 (THEORY.md 0)
    for ab, dlt in (("default", DYN_DELTA), ("strict", DYN_STRICT), ("lenient", DYN_LENIENT)):
        x = math.log(1 / dlt); thr = DYN_D + 2 * math.sqrt(DYN_D * x) + 2 * x
        lin[ab] = dict(threshold=thr, chi2_30_tail=float(chi2.sf(thr, DYN_D)))
    store("num_dyn", dict(linear_block_d30=lin,
        source="arithmetic from dfg13.py's defaults (THEORY.md section 0, P2); study/part10/interp/tables/toy_timing.csv; "
               "study/part10/interp/VERIFICATION.json (verify-reading:toy, C4)",
        L_k_nats=L, n_thr_d30=nthr, block_t_k11=dict(default=_dblock_t(11), strict=_dblock_t(11, DYN_STRICT), lenient=_dblock_t(11, DYN_LENIENT)),
        block_shift_k11=dict(strict=_dblock_shift(11, DYN_STRICT), lenient=_dblock_shift(11, DYN_LENIENT)),
        pure_targets=len(pure), pure_found=len(ra), pure_ratio_at_struct=dict(median=float(np.median(ra)), min=ra[0], max=ra[-1],
                                                                              below_1_17=sum(x < 1.17 for x in ra)),
        p10_corrected=dict(found=len(found), detectable_at_128=sum(r["n_detect"] <= 128 for r in T.values()),
                           earlier=sum(x < 0 for x in dl), equal=sum(x == 0 for x in dl), one=sum(x == 1 for x in dl),
                           two_plus=sum(x >= 2 for x in dl), median=float(np.median(dl)))))


if __name__ == "__main__":
    names = sys.argv[1:] or list(ITEMS)
    for nm in names:
        if nm not in ITEMS:
            sys.exit(f"unknown output {nm}; known: {', '.join(ITEMS)}")
    for nm in names:
        ITEMS[nm]()

"""Tables, figures and quoted numbers of the case study on trained nets
(paper/sec-nets.tex) from the results files of the five experiment folders.

Every number that sec-nets.tex quotes is a macro written here to
paper/tables/nets_numbers.tex, computed from these files:

  experiments/nets/suite.json                     the trained-net suite
  experiments/nets_lower/results/                 splitting lower bounds (tables.json, mixing.txt, checks.txt, ...)
  experiments/nets_prover/results/                certified partitions (tables.json, gap_scan.json, scaling.json, knuth_d64.json)
  experiments/nets_verify/results/                branch and bound, p = 0 study, wall clock, barriers
  experiments/nets_analytic/results/              barrier diagnostics, envelopes, perturb-and-MAP
  experiments/nets_structure/results/             failure-set structure, heuristic estimators

Outputs: paper/tables/nets_*.tex and paper/figures/fig_nets_*.pdf. Run from
anywhere: python3 experiments/make_nets_tables.py
"""

import json
import math
import os
import re
import statistics
from decimal import ROUND_HALF_UP, Decimal

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
TAB = os.path.join(HERE, "..", "paper", "tables")
FIG = os.path.join(HERE, "..", "paper", "figures")
os.makedirs(TAB, exist_ok=True)
os.makedirs(FIG, exist_ok=True)

BLUE, ORANGE, AQUA, VIOLET = "#2a78d6", "#eb6834", "#1baf7a", "#8a5cd1"
INK, INK2, GRID = "#0b0b0b", "#52514e", "#d9d8d4"
plt.rcParams.update({
    "font.size": 8, "axes.edgecolor": INK2, "axes.labelcolor": INK, "xtick.color": INK2,
    "ytick.color": INK2, "axes.grid": True, "grid.color": GRID, "grid.linewidth": 0.5,
    "axes.spines.top": False, "axes.spines.right": False, "legend.frameon": False,
    "lines.linewidth": 1.3, "lines.markersize": 4,
})

DELTA = 0.05
MC_CONST = 3 * math.log(2 / DELTA) / 0.1 ** 2  # Monte Carlo samples for relative error 0.1 are MC_CONST / p


def load(*parts):
    with open(os.path.join(HERE, *parts)) as fh:
        return json.load(fh)


def load_jsonl(*parts):
    with open(os.path.join(HERE, *parts)) as fh:
        return [json.loads(line) for line in fh if line.strip()]


# ------------------------------------------------------------------ formatting

def num(x, sig=2):
    """x as LaTeX math (no dollars), sig significant digits, rounded half up
    from its exact binary value; plain decimals between 0.01 and 10^4."""
    if x is None:
        return "-"
    if x == 0:
        return "0"
    if math.isinf(x):
        return "\\infty"
    neg = x < 0
    d = Decimal(abs(x))
    q = d.quantize(Decimal(1).scaleb(d.adjusted() - sig + 1), rounding=ROUND_HALF_UP)
    e = q.adjusted()
    if -2 <= e <= 3:
        t = format(q, "f")
        s = t
    else:
        m = q.scaleb(-e)
        m = m.quantize(Decimal(1).scaleb(-(sig - 1)), rounding=ROUND_HALF_UP)
        ms = format(m, "f")
        if "." in ms:
            ms = ms.rstrip("0").rstrip(".")
        s = f"10^{{{e}}}" if ms == "1" else f"{ms}\\cdot10^{{{e}}}"
    return ("-" if neg else "") + s


def fix(x, nd=2):
    """Fixed decimals, rounded half up from the exact value."""
    if x is None:
        return "-"
    q = Decimal(x).quantize(Decimal(1).scaleb(-nd), rounding=ROUND_HALF_UP)
    s = format(q, "f")
    return "0" + s[len("-0"):] if s.startswith("-0") and float(q) == 0 else s


def m(x, sig=2):
    return f"${num(x, sig)}$"


def pct(x, nd=1):
    return fix(100 * x, nd) + "\\%"


def tt(name):
    return "\\texttt{" + name.replace("_", "\\_") + "}"


def rng(lo, hi, f=lambda v: num(v)):
    """A range; the dash works in text and in math mode."""
    return f"\\ensuremath{{{f(lo)}}}\\text{{--}}\\ensuremath{{{f(hi)}}}"


MACROS = {}


def mac(name, value):
    assert re.fullmatch(r"[A-Za-z]+", name), name
    assert name not in MACROS, name
    MACROS[name] = value


def mnum(name, x, sig=2):
    mac(name, f"\\ensuremath{{{num(x, sig)}}}")


def mfix(name, x, nd=2):
    mac(name, f"\\ensuremath{{{fix(x, nd)}}}")


def mint(name, k):
    mac(name, f"{int(k):,}".replace(",", "{,}"))


def write(name, lines):
    with open(os.path.join(TAB, name), "w") as fh:
        fh.write("\n".join(lines) + "\n")


def mc_fpe(p):
    return MC_CONST / p


def kl(a, b):
    """Bernoulli relative entropy KL(a || b)."""
    out = 0.0
    if a > 0:
        out += a * math.log(a / b)
    if a < 1:
        out += (1 - a) * (math.log1p(-a) - math.log1p(-b))
    return out


# ------------------------------------------------------------------ inputs

SUITE = {r["name"]: r for r in load("nets", "suite.json")}
LOWER = load("nets_lower", "results", "tables.json")
PROVER = load("nets_prover", "results", "tables.json")
VSUITE = {r["name"]: r for r in load("nets_verify", "results", "suite.json")}
VDEEP = {r["name"]: r for r in load("nets_verify", "results", "suite_deep.json")}
WALL = {r["name"]: r for r in load("nets_verify", "results", "wallclock.json")["rows"]}
ZERO = load("nets_verify", "results", "zero_summary.json")
BARRIER = {r["name"]: r for r in load("nets_analytic", "results", "barrier_table.json")}
STRUCT = {r["name"]: r for r in load("nets_structure", "results", "structure.json")}


def short_prover(name):
    return next(r for r in PROVER["suite"] if r["net"] == name)


def mc_time_measurements(name):
    """Seconds per batched Monte Carlo sample of a suite net with d <= 28, as
    measured by each experiment that timed it on the shared machine: the
    splitting runs (mean over their runs), the certified-partition runs, and
    the branch-and-bound wall-clock study (one hidden layer only)."""
    out = []
    lo = next((r for r in LOWER["suite_exact"] if r["name"] == name), None)
    if lo and lo.get("mc_seconds_per_sample"):
        out.append(lo["mc_seconds_per_sample"])
    pr = next((r for r in PROVER["suite"] if r["net"] == name), None)
    if pr and pr["mc_fpe"] and math.isfinite(pr["mc_fpe"]) and pr["mc_seconds"]:
        out.append(pr["mc_seconds"] / pr["mc_fpe"])
    if name in WALL and WALL[name].get("mc_s_per_sample"):
        out.append(WALL[name]["mc_s_per_sample"])
    return out


def mc_time(name):
    """One time per Monte Carlo sample for each net, used in every table and
    in the text: the median of the experiments' measurements, which differ by
    up to a few times on the shared machine."""
    return statistics.median(mc_time_measurements(name))


# ================================================================== N.0, N.1: soundness campaigns, encodings

def soundness_numbers():
    checks = open(os.path.join(HERE, "nets_lower", "results", "checks.txt")).read()
    ratios = [float(x) for x in re.findall(r"E\*/\(2 max\) = ([0-9.e+]+)", checks)]
    mnum("nnErrMarginMin", min(ratios))
    mnum("nnErrMarginMax", max(ratios))
    mint("nnErrNets", len(ratios))

    adv = LOWER["adversarial"]
    fl = [a for a in adv if a["kind"] == "float"]
    mint("nnFloatCases", len({a["case"] for a in fl}))
    mint("nnFloatRuns", len(fl))
    assert all(a["L"] == 0 for a in fl)
    camp = [a for a in adv if a["kind"] == "campaign"]
    for dl, nm in ((0.2, "nnCampWorstTwo"), (0.5, "nnCampWorstFive")):
        mfix(nm, max(a["miss_lower"] for a in camp if a["delta"] == dl), 3)
    mint("nnCampCells", len({(a["net"], a["config"]) for a in camp}))
    mint("nnCampNets", len({a["net"] for a in camp}))
    mint("nnCampRuns", sum(a["runs"] for a in camp))
    assert all(a["miss_witness"] == 0 for a in camp)
    rnd = [a for a in adv if a["kind"] == "random"]
    for dl, nm in ((0.05, "nnRandMissFive"), (0.3, "nnRandMissThirty")):
        rr = [a for a in rnd if a["delta"] == dl]
        mint(nm, sum(a["miss"] for a in rr))
        mint(nm + "Of", len(rr))
    planted = [a for a in adv if a["kind"] == "planted" and a["case"] == "hidden_d40_k26"]
    mnum("nnPlantedP", planted[0]["p_exact"])
    pv = planted[0]["p_visible"]  # the visible failure set alone (the net before planting)
    mnum("nnPlantedPvis", pv)
    mint("nnPlantedVisF", round(pv * 2 ** planted[0]["d"]))
    mnum("nnPlantedFpe", max(a["evals"] for a in planted))
    # bound on the chance that one run's evaluations hit the hidden 2^-k subcube, averaged over b
    k_hidden = int(re.search(r"_k(\d+)$", planted[0]["case"]).group(1))
    mfix("nnPlantedHit", max(a["evals"] for a in planted) / 2 ** k_hidden, 2)
    mnum("nnPlantedSec", max(a["seconds"] for a in planted))
    mint("nnPlantedRuns", len(planted))
    assert all(a["L"] == 0 and a["point_estimate"] == 0 for a in planted)

    ps = PROVER["soundness"]
    mint("nnProvBoundChecks", ps["bound_checks"])
    mint("nnProvExact", ps["exact_runs"])
    mint("nnProvTamper", ps["tamper_runs"])
    mint("nnProvCov", ps["coverage_runs"])
    mint("nnProvCovMiss", ps["coverage_misses"])
    assert ps["bound_violations"] == ps["exact_mismatch"] == ps["tamper_misses"] == 0

    vs = load("nets_verify", "results", "check_soundness.json")
    mint("nnVerBoundChecks", vs["bound_checks"])
    mint("nnVerBab", vs["bab_checks"])
    mint("nnVerOverflowRuns", vs["overflow_runs"])
    assert vs["bound_violations"] == vs["bab_violations"] == vs["overflow_violations"] == 0

    an = load("nets_analytic", "results", "soundness.json")
    mint("nnAnaNets", len(an["nets"]))
    mint("nnAnaCov", an["coverage"]["runs"])
    mint("nnAnaCovMiss", an["coverage"]["miss"])
    assert not an["fail"]

    cnf = load("nets_verify", "results", "check_cnf_encoding.json")
    assert cnf["all_match"]
    mint("nnCnfTrials", cnf["trials"])


# ================================================================== N.2: structure (Table N0)

# the suite nets whose whole failure set was analysed (F small enough for the cluster statistics)
STRUCT_ROWS = ["mse_d24_w32_s1000", "mse_d24_w32_s1500", "mse_d24_w32_s2000",
               "mse_d28_w64_s600", "mse_d28_w64_s1000", "mse_d28_w32x32_s500",
               "bce_d28_w32_s60", "bce_d28_w64x64_s60"]


def structure_table():
    lines = ["\\begin{tabular}{lrrrrrrrrr}", "\\toprule",
             "net & $p$ & $F$ & $\\mathrm{corr}(f(x),f(-x))$ & $W_1$ & $F(0)-t$ & "
             "$\\overline{|\\bar x_i|}$ & halfspace $K$ & minima & clusters\\\\", "\\midrule"]
    for n in STRUCT_ROWS:
        s, b = STRUCT[n], BARRIER[n]
        K = s.get("halfspace_maxmargin_ratio")
        lines.append(" & ".join([
            tt(n), m(s["p"]), f"{s['F']}", sfix(s["corr_f_fneg"], 2), pct(b["level1_weight"]),
            sfix(b["f0_minus_t"], 3), fix(s["mean_abs_coord"], 2),
            m(K) if K else "-", f"{s['n_minima']}", f"{s['comps_h1']}"]) + "\\\\")
    lines += ["\\bottomrule", "\\end{tabular}"]
    write("nets_structure.tex", lines)

    # macros for the text
    one_mse = [n for n, b in BARRIER.items() if b["loss"] == "mse" and b["d"] <= 28 and len(b["widths"]) == 1]
    one_bce = [n for n, b in BARRIER.items() if b["loss"] == "bce" and b["d"] <= 28 and len(b["widths"]) == 1]
    mac("nnLOneMse", rng(min(BARRIER[n]["level1_weight"] for n in one_mse), max(BARRIER[n]["level1_weight"] for n in one_mse),
                         lambda v: fix(100 * v, 1) + "\\%"))
    mac("nnLOneBce", rng(min(BARRIER[n]["level1_weight"] for n in one_bce), max(BARRIER[n]["level1_weight"] for n in one_bce),
                         lambda v: fix(100 * v, 0) + "\\%"))
    mse_s = [s for s in STRUCT.values() if s["loss"] == "mse" and len(s["widths"]) == 1]
    mac("nnCorrMse", rng(min(s["corr_f_fneg"] for s in mse_s), max(s["corr_f_fneg"] for s in mse_s), lambda v: fix(v, 2)))
    bce_s = [s for s in STRUCT.values() if s["loss"] == "bce"]
    mac("nnCorrBce", rng(min(s["corr_f_fneg"] for s in bce_s), max(s["corr_f_fneg"] for s in bce_s), lambda v: fix(v, 2)))
    mse_fail = [s for s in mse_s if s["F"] >= 50 and not s["near"]]
    mac("nnMeanCoordMse", rng(min(s["mean_abs_coord"] for s in mse_fail), max(s["mean_abs_coord"] for s in mse_fail),
                              lambda v: fix(v, 2)))
    s = STRUCT["mse_d24_w32_s1500"]
    mint("nnSOneFiveClusters", s["comps_h1"])
    mint("nnSOneFiveLargest", s["largest_h1"])
    mint("nnSOneFiveMinima", s["n_minima"])
    mfix("nnSOneFiveHam", s["ham_mean"], 1)
    mnum("nnSOneFiveHalfK", s["halfspace_maxmargin_ratio"])
    mfix("nnSOneFiveShareEp", s["share_Ep"], 2)
    mfix("nnSOneFiveShareL", s["share_L"], 2)
    mfix("nnSOneFiveSmallS", s["n_small_pos_S"], 1)
    mfix("nnSOneFiveSmallR", s["n_small_pos_R"], 1)
    mnum("nnHalfKdTwoEight", STRUCT["mse_d28_w64_s1000"]["halfspace_maxmargin_ratio"])
    allsets = list(STRUCT.values()) + load("nets_structure", "results", "structure_own.json")
    one = [r for r in allsets if r.get("loss") == "mse" and len(r["widths"]) == 1 and r.get("F", 0) > 1
           and not r.get("near") and "maxmargin_gamma_over_sqrtd" in r]
    wide = [r for r in one if r["widths"][0] >= 32]
    assert all(r["maxmargin_gamma_over_sqrtd"] == 0 for r in wide)
    mint("nnHullWide", len(wide))
    mint("nnHullOne", len(one))
    mint("nnHullOneZero", sum(1 for r in one if r["maxmargin_gamma_over_sqrtd"] == 0))
    dec = load("nets_analytic", "results", "decompose.json")
    cors = [v["corr_even+_even-"] for k, v in dec.items() if k.startswith("mse")]
    mac("nnCorrEvenPM", rng(min(cors), max(cors), lambda v: fix(v, 2)))
    f0s = [BARRIER[n]["f0_minus_t"] for n in BARRIER if BARRIER[n]["loss"] == "mse" and BARRIER[n]["d"] <= 28]
    mint("nnFzeroBelowMse", sum(1 for v in f0s if v < 0))
    mint("nnMseSmallD", len(f0s))
    mac("nnFzeroRange", rng(min(f0s), max(f0s), lambda v: fix(v, 2)))
    geo = load("nets_structure", "results", "geometry.json")
    mint("nnBoxWitness", sum(1 for r in geo if r["box_min"] < r["threshold"]))
    mint("nnSphereWitness", sum(1 for r in geo if r["sphere_min"] < r["threshold"]))
    mint("nnSuiteNets", len(geo))
    tot = ZERO["totals"]
    mint("nnZeroNets", tot["long_nets"])
    mint("nnZeroZero", tot["long_p_zero"])
    mint("nnZeroPos", tot["long_p_positive_exact"])
    mint("nnZeroOpen", tot["long_open"])
    p0c = load("nets_structure", "results", "scaling_summary.json")["p0_vs_count"]
    lo = next(r for r in p0c if r["loss"] == "mse" and r["log10_count_hi"] == -2)
    hi = next(r for r in p0c if r["loss"] == "mse" and r["log10_count_lo"] == 2)
    mac("nnPzeroLowCount", pct(lo["frac_p0"], 0))
    mac("nnPzeroHighCount", pct(hi["frac_p0"], 0))


# ================================================================== N.5: splitting (Tables N1, N2, Figure N1)

def cost(fpe, sec):
    return f"${num(fpe)}$\\,(${num(sec)}$)"


def sfix(x, nd=2):
    """A signed fixed-point number in math mode (proper minus sign)."""
    return f"${fix(x, nd)}$"


def smc_suite_table():
    rows = sorted(LOWER["suite_exact"], key=lambda r: (r["d"], len(r["widths"]), r["loss"], -r["p"]))
    lines = ["\\begin{tabular}{lrrrrrrrrr}", "\\toprule",
             "& & & Monte Carlo & \\multicolumn{2}{c}{budget M} & \\multicolumn{3}{c}{budget L} & speed-up at L\\\\",
             "\\cmidrule(lr){5-6}\\cmidrule(lr){7-9}\\cmidrule(lr){10-10}",
             "net & $p$ & $F$ & fpe\\,(s) & $L/p$ & fpe\\,(s) & $L/p$ & fpe\\,(s) & wit. & "
             "KL fpe\\,(s); task fpe\\\\", "\\midrule"]
    for r in rows:
        B = r["budgets"]
        if r["p"] == 0:
            lines.append(f"{tt(r['name'])} & 0 & 0 & -- & \\multicolumn{{6}}{{l}}{{$L=0$ in all {3 * B['L']['runs']} runs "
                         f"(correct); budget L: {cost(B['L']['evals_fpe'], B['L']['seconds'])}}}\\\\")
            continue
        M_, L_ = B["M"], B["L"]
        tmc = mc_time(r["name"])
        lines.append(" & ".join([
            tt(r["name"]), m(r["p"]), f"{r['fail_count']}", cost(r["mc_eps01_fpe"], r["mc_eps01_fpe"] * tmc),
            fix(M_["r_bet_mean"], 3), cost(M_["evals_fpe"], M_["seconds"]),
            fix(L_["r_bet_mean"], 3), cost(L_["evals_fpe"], L_["seconds"]), fix(L_["r_wit_mean"], 2),
            f"${num(L_['speedup_kl_fpe'])}$\\,(${num(L_['mc_kl_samples'] * tmc / L_['seconds'])}$); "
            f"${num(L_['speedup_task_fpe'])}$"]) + "\\\\")
    lines += ["\\bottomrule", "\\end{tabular}"]
    write("nets_smc_suite.tex", lines)

    H = LOWER["headlines"]
    mint("nnSuiteRuns", H["suite_runs"])
    mint("nnSuiteMisses", H["suite_misses"])
    mint("nnSuiteFlagged", H["suite_flagged_replicates"])
    for b in ("M", "L"):
        h = H[f"suite_p_ge_1e-5_{b}"]
        mac(f"nnSuiteRatio{b}", rng(*h["r_bet_mean_range"], lambda v: fix(v, 3)))
        mac(f"nnSuiteFpe{b}", rng(*h["fpe_range"]))
        mac(f"nnSuiteSec{b}", rng(*h["seconds_range"], lambda v: num(v, 2)))
    names = {"mse_d24_w32_s2000": "A", "bce_d28_w32_s100": "B", "mse_d28_w64_s1000": "C", "mse_d24_w32_s1500": "D"}
    for r in H["suite_small_p"]:
        k = names[r["name"]]
        Lb = next(e for e in LOWER["suite_exact"] if e["name"] == r["name"])["budgets"]["L"]
        assert Lb["seconds"] == r["L_seconds"]
        mfix(f"nnSmall{k}Ratio", r["L_r_bet_mean"], 3)
        mnum(f"nnSmall{k}Fpe", r["L_evals_fpe"])
        mnum(f"nnSmall{k}Sec", r["L_seconds"])
        mnum(f"nnSmall{k}KL", r["L_speedup_kl_fpe"])
        mnum(f"nnSmall{k}KLs", Lb["mc_kl_samples"] * mc_time(r["name"]) / Lb["seconds"])
        mnum(f"nnSmall{k}Task", r["L_speedup_task_fpe"])
        mnum(f"nnSmall{k}P", r["p"])
        mint(f"nnSmall{k}F", r["fail_count"])
        mfix(f"nnSmall{k}RatioM", r["M_r_bet_mean"], 3)
    zr = H["mean_Z_over_p_range"]
    mac("nnMeanZRange", rng(*zr, lambda v: fix(v, 3)))
    mfix("nnEffSlope", LOWER["efficiency_slope"]["slope"], 2)
    mfix("nnEffGain", 1 - LOWER["efficiency_slope"]["slope"], 2)
    mint("nnEffRows", LOWER["efficiency_slope"]["rows"])
    w = H["smc_seconds_per_fpe_over_mc"]
    mfix("nnWallMedian", w["median"], 2)
    mac("nnWallRange", rng(w["p10"], w["p90"], lambda v: fix(v, 2)))
    mint("nnWallCells", w["cells"])
    # Monte Carlo is cheaper for p above ...: the largest p with a budget-L speed-up (KL) above 1
    rows_pos = [r for r in LOWER["suite_exact"] if r["p"] > 0]
    worse = [r["p"] for r in rows_pos if r["budgets"]["L"]["speedup_kl_fpe"] < 1 and r["budgets"]["M"]["speedup_kl_fpe"] < 1]
    better = [r["p"] for r in rows_pos if r["budgets"]["M"]["speedup_kl_fpe"] > 1]
    mnum("nnMcWinsAbove", min(worse), 1)
    mnum("nnSmcWinsBelow", max(better), 1)
    # efficiency kappa at a few p
    eff = [e for e in LOWER["efficiency"] if e["budget"] == "L"]
    mac("nnKappaRange", rng(min(e["kappa"] for e in eff), max(e["kappa"] for e in eff)))


def smc_scaling_table():
    rows = sorted(LOWER["scaling"], key=lambda r: (r["d"], -(r["p_ref"] or 0)))
    seq = {(s["name"], s["target"]): s for s in LOWER["sequential"]}
    lines = ["\\begin{tabular}{lrrlrrrr}", "\\toprule",
             "net & $d$ & $z$ & $p_{\\rm ref}$ (check) & $L/p_{\\rm ref}$ at L & fpe\\,(s) at L & "
             "seq.\\ 0.9: ratio, fpe\\,(s) & KL speed-up fpe\\,(s)\\\\", "\\midrule"]
    for r in rows:
        name = tt(r["name"])
        if not r["p_ref"]:
            lines.append(f"{name} & {r['d']} & {fix(r['z'], 1)} & \\multicolumn{{5}}{{l}}{{no reference replicate reached the "
                         f"last level (${num(r['ref_evals_fpe'])}$\\,fpe, {num(r['ref_seconds'])}\\,s): every bound is $0$}}\\\\")
            continue
        chk = ""
        checks = r.get("checks", [])
        exact = [c for c in checks if c["kind"] == "exact enumeration"]
        if exact:
            chk = f" (exact ${num(exact[0]['p'], 3)}$)"
        elif checks:
            c = max(checks, key=lambda c: c["samples"])  # the largest independent Monte Carlo check
            chk = f" (MC ${num(c['p'], 2)}\\pm{num(c['se'], 1)}$)"
        L_ = r["budgets"]["L"]
        ratio = f"{fix(L_['r_bet_mean'], 3)} [{fix(L_['r_bet_min'], 2)}]"
        if L_["r_mean"] > L_["r_bet_mean"] + 1e-9:
            ratio += f"; wit.\\ {fix(L_['r_mean'], 2)}"
        s = seq.get((r["name"], 0.9))
        sq = f"{fix(s['ratio_mean'], 2)}, {cost(s['evals_fpe'], s['seconds'])}" if s else "--"
        sp = f"${num(L_['speedup_kl_fpe'])}$\\,(${num(L_['speedup_kl_sec'])}$)"
        lines.append(" & ".join([name, f"{r['d']}", fix(r["z"], 1), f"${num(r['p_ref'], 3)}${chk}", ratio,
                                 cost(L_["evals_fpe"], L_["seconds"]), sq, sp]) + "\\\\")
    lines += ["\\bottomrule", "\\end{tabular}"]
    write("nets_smc_scaling.tex", lines)

    good = [r for r in rows if r["p_ref"] and r["ref_relvar"] <= 1]
    mint("nnScaleNets", len(good))
    mac("nnScaleRatio", rng(min(r["budgets"]["L"]["r_bet_mean"] for r in good),
                            max(r["budgets"]["L"]["r_bet_mean"] for r in good), lambda v: fix(v, 3)))
    mac("nnScaleFpe", rng(min(r["budgets"]["L"]["evals_fpe"] for r in good), max(r["budgets"]["L"]["evals_fpe"] for r in good)))
    mac("nnScaleSec", rng(min(r["budgets"]["L"]["seconds"] for r in good), max(r["budgets"]["L"]["seconds"] for r in good)))
    mac("nnScalePref", rng(max(r["p_ref"] for r in good), min(r["p_ref"] for r in good)))
    # which references were checked independently (exact count or Monte Carlo), which not
    chk = [r for r in good if r.get("checks")]
    unchk = [r for r in good if not r.get("checks")]
    mint("nnScaleChecked", len(chk))
    mint("nnScaleUnchecked", len(unchk))
    mac("nnScaleRatioChecked", rng(min(r["budgets"]["L"]["r_bet_mean"] for r in chk),
                                   max(r["budgets"]["L"]["r_bet_mean"] for r in chk), lambda v: fix(v, 3)))
    mac("nnScaleRatioUnchecked", rng(min(r["budgets"]["L"]["r_bet_mean"] for r in unchk),
                                     max(r["budgets"]["L"]["r_bet_mean"] for r in unchk), lambda v: fix(v, 3)))
    mac("nnScalePrefUnchecked", rng(max(r["p_ref"] for r in unchk), min(r["p_ref"] for r in unchk)))
    zero = [r for r in rows if not r["p_ref"]]
    mint("nnScaleZeroRef", len(zero))
    tail = [r for r in rows if r["p_ref"] and r["ref_relvar"] > 1]
    mint("nnScaleTail", len(tail))
    mac("nnTailBet", rng(min(r["budgets"]["L"]["r_bet_mean"] for r in tail), max(r["budgets"]["L"]["r_bet_mean"] for r in tail),
                         lambda v: fix(v, 2)))
    mac("nnTailWit", rng(min(r["budgets"]["L"]["r_mean"] for r in tail), max(r["budgets"]["L"]["r_mean"] for r in tail),
                         lambda v: fix(v, 2)))
    mac("nnTailZ", rng(min(r["z"] for r in tail), max(r["z"] for r in tail), lambda v: fix(v, 1)))
    by = {r["name"]: r for r in rows}
    b = by["bce_d64_w64_s100"]
    mnum("nnWitNetPref", b["p_ref"], 3)
    mfix("nnWitNetRatio", b["budgets"]["L"]["r_bet_mean"], 3)
    mnum("nnWitNetFpe", b["budgets"]["L"]["evals_fpe"])
    mnum("nnWitNetSec", b["budgets"]["L"]["seconds"])
    mnum("nnWitNetWits", b["budgets"]["L"]["n_witnesses_max"])
    e = by["smc_mse_d32_w64_s600"]
    c = e["checks"][0]
    mint("nnDThirtyTwoF", c["hits"])
    mnum("nnDThirtyTwoP", c["p"], 3)
    mnum("nnDThirtyTwoPref", e["p_ref"], 3)
    mnum("nnDThirtyTwoPrefSe", e["p_ref_se"], 1)
    mnum("nnDThirtyTwoSec", c["seconds"])
    s = by["mse_d64_w64_s1000"]
    c = [c for c in s["checks"] if c["kind"].startswith("plain")][0]
    mnum("nnMseSixFourPref", s["p_ref"], 3)
    mnum("nnMseSixFourMc", c["p"], 2)
    mnum("nnMseSixFourMcSe", c["se"], 2)
    blocks = load_jsonl("nets_lower", "results", "mc_blocks.jsonl")
    mnum("nnMcBlocksMin", min(bl["p_hat"] for bl in blocks), 2)
    big = by["bce_d128_w128x128_s300"]
    mnum("nnBigPref", big["p_ref"], 2)
    mfix("nnBigRatio", big["budgets"]["L"]["r_bet_mean"], 3)
    mnum("nnBigFpe", big["budgets"]["L"]["evals_fpe"])
    mnum("nnBigSec", big["budgets"]["L"]["seconds"])
    mnum("nnBigKL", big["budgets"]["L"]["speedup_kl_fpe"])
    for key, nm in (("smc_mse_d64_w64_s1500", "SeqA"), ("smc_mse_d128_w64_s1000", "SeqB"), ("bce_d128_w128x128_s300", "SeqC")):
        q = seq[(key, 0.9)]
        mfix(f"nn{nm}Ratio", q["ratio_mean"], 3)
        mnum(f"nn{nm}Fpe", q["evals_fpe"])
        mnum(f"nn{nm}Sec", q["seconds"])
        mnum(f"nn{nm}KL", q["speedup_kl_fpe"])
        mnum(f"nn{nm}P", by[key]["p_ref"])

    # mixing diagnostic
    txt = open(os.path.join(HERE, "nets_lower", "results", "mixing.txt")).read().strip().splitlines()
    small, large = [], []
    for line in txt:
        d = int(re.search(r"d=\s*(\d+)", line).group(1))
        acc = [float(x) for x in re.search(r"acceptance=\[([^\]]*)\]", line).group(1).split(",")]
        dist = [int(x) for x in re.search(r"per run=\[([^\]]*)\]", line).group(1).split(",")]
        (small if d <= 32 else large).append((min(acc[-3:]), max(dist), min(acc), min(dist)))
    mac("nnMixSmallAcc", rng(min(a for a, _, _, _ in small), max(a for a, _, _, _ in small), lambda v: fix(v, 2)))
    mac("nnMixSmallDist", rng(min(dd for _, dd, _, _ in small), max(dd for _, dd, _, _ in small), lambda v: f"{v}"))
    mfix("nnMixLargeAcc", min(a for _, _, a, _ in large), 2)
    mint("nnMixLargeNets", len(large))
    mac("nnMixLargeDist", rng(min(dd for _, _, _, dd in large), max(dd for _, dd, _, _ in large), lambda v: f"{v}"))

    # ablation of the combining rules and the no-mixing unbiasedness check
    comb = LOWER["ablation"]["combine"]
    for b in ("M", "L"):
        cc = [c for c in comb if c["budget"] == b]
        mfix(f"nnComb{b}Bet", statistics.mean(c["r_bet"] for c in cc), 2)
        mfix(f"nnComb{b}Clip", statistics.mean(c["r_clip"] for c in cc), 2)
        mfix(f"nnComb{b}Min", statistics.mean(c["r_min"] for c in cc), 2)
    unb = [u for u in LOWER["ablation"]["unbiased"] if "variant" in u]
    zero_step = next(u for u in unb if "0 steps" in u["variant"])
    mfix("nnNoMixRatio", zero_step["mean_over_target"], 3)
    mfix("nnNoMixZ", zero_step["z"], 2)
    mint("nnNoMixReps", zero_step["replicates"])
    mac("nnUnbZmax", fix(max(abs(u["z"]) for u in unb), 2))
    mint("nnUnbVariants", len(unb))


def smc_figure():
    fig, ax = plt.subplots(figsize=(6.4, 2.9))
    ps = [10 ** (k / 10) for k in range(-380, -4)]
    ax.plot(ps, [mc_fpe(p) for p in ps], color=INK2, ls="--", lw=1.0,
            label="Monte Carlo, relative error $\\varepsilon=0.1$: $3\\ln(2/\\delta)/(\\varepsilon^2p)$")
    ax.plot(ps, [math.log(1 / DELTA) / kl(p, 0.9 * p) for p in ps], color=INK2, ls=":", lw=1.0,
            label="Monte Carlo, one-sided $L\\geq0.9p$ (KL)")
    ex = [r for r in LOWER["suite_exact"] if r["p"] > 0]
    ax.scatter([r["p"] for r in ex], [r["budgets"]["L"]["evals_fpe"] for r in ex], color=BLUE, marker="o", s=14,
               label="splitting, budget L, $d\\leq28$ (exact $p$)", zorder=3)
    sc = [r for r in LOWER["scaling"] if r["p_ref"] and r["ref_relvar"] <= 1]
    ax.scatter([r["p_ref"] for r in sc], [r["budgets"]["L"]["evals_fpe"] for r in sc], color=ORANGE, marker="s", s=14,
               label="splitting, budget L, $d=32$--$128$ ($p_{\\rm ref}$)", zorder=3)
    sq = [s for s in LOWER["sequential"] if s["target"] == 0.9]
    ax.scatter([s["p"] for s in sq], [s["evals_fpe"] for s in sq], facecolors="none", edgecolors=AQUA, marker="D", s=16,
               label="sequential, stop at $L\\geq0.9\\,\\hat p$", zorder=3)
    tail = [r for r in LOWER["scaling"] if r["p_ref"] and r["ref_relvar"] > 1]
    ax.scatter([r["p_ref"] for r in tail], [r["budgets"]["L"]["evals_fpe"] for r in tail], color=VIOLET, marker="x", s=20,
               label="far tail ($L/p_{\\rm ref}<0.2$; witnesses $<0.5$)", zorder=3)
    ax.set_xscale("log")
    ax.set_yscale("log")
    ax.set_xlim(1e-38, 0.3)
    ax.set_ylim(1e4, 1e42)
    ax.set_xlabel("$p$ (exact for $d\\leq32$, else the reference $p_{\\rm ref}$)")
    ax.set_ylabel("forward-pass equivalents")
    ax.legend(loc="upper right", fontsize=6)
    fig.tight_layout()
    fig.savefig(os.path.join(FIG, "fig_nets_smc.pdf"))
    plt.close(fig)


# ================================================================== N.6: certified partitions (Tables N3, N3b; Figures N2, N3)

EXACT_ROWS = ["mse_d24_w32_s300", "mse_d24_w32_s600", "mse_d24_w32_s1000", "mse_d24_w32_s1500", "mse_d24_w32_s2000",
              "mse_d28_w64_s300", "mse_d28_w64_s600", "mse_d28_w64_s1000", "mse_d28_w64_s1500",
              "bce_d28_w32_s30", "bce_d28_w32_s60", "bce_d28_w32_s100", "bce_d28_w32_s150"]


def exact_table():
    lines = ["\\begin{tabular}{lrrlrrrrr}", "\\toprule",
             "net & $p$ & $F$ & argument & verifier fpe\\,(s) & prover s & B\\&B fpe\\,(s) & enumeration fpe\\,(s) & "
             "Monte Carlo fpe\\,(s)\\\\", "\\midrule"]
    for n in EXACT_ROWS:
        r = short_prover(n)
        v = VSUITE[n]["exact_run"]
        w = WALL.get(n, {})
        bab_sec = w.get("bab_seconds", v["seconds"])
        bab = cost(v["fpe"], bab_sec) + ("" if v["exact"] else f"$^{{\\ast}}$")
        arg = {"certificate": f"{r['nodes']} nodes", "enumeration": "[ENUM]",
               "pieces": f"{r['nodes']} nodes, 32 pieces"}[r["plan"]]
        mc = cost(r["mc_fpe"], r["mc_fpe"] * mc_time(n)) if r["p"] > 0 else "cannot certify 0"
        lines.append(" & ".join([tt(n), m(r["p"]), f"{r['F']}", arg, cost(r["verifier_fpe"], r["verifier_seconds"]),
                                 num(r["prover_seconds"]), bab, cost(r["enum_fpe"], r["enum_seconds"]), mc]) + "\\\\")
    deep = [r for r in PROVER["suite"] if len(SUITE[r["net"]]["widths"]) == 2]
    vf = [VDEEP[n]["exact_run"] for n in VDEEP]
    lines.append("\\midrule")
    lines.append(
        f"two hidden layers ({len(deep)} nets) & ${num(min(r['p'] for r in deep))}$--${num(max(r['p'] for r in deep))}$ "
        f"& & [ENUM] & ${num(min(r['verifier_fpe'] for r in deep))}$--${num(max(r['verifier_fpe'] for r in deep))}$\\,"
        f"(${num(min(r['verifier_seconds'] for r in deep))}$--${num(max(r['verifier_seconds'] for r in deep))}$) & & "
        f"\\multicolumn{{3}}{{l}}{{B\\&B: upper end ${fix(min(x['hi'] for x in vf), 2)}$--${fix(max(x['hi'] for x in vf), 2)}$ "
        f"after {num(min(x['seconds'] for x in vf))}--{num(max(x['seconds'] for x in vf))}\\,s ({len(vf)} nets)}}\\\\")
    lines += ["\\bottomrule", "\\end{tabular}"]
    write("nets_exact.tex", lines)

    ok = all(r["exact"] and r["matches_suite_count"] for r in PROVER["suite"])
    assert ok
    mint("nnExactNets", len(PROVER["suite"]))
    a, b_, c = short_prover("bce_d28_w32_s100"), short_prover("bce_d28_w32_s150"), short_prover("mse_d24_w32_s2000")
    mnum("nnCertBVerFpe", a["verifier_fpe"])
    mnum("nnCertBEnd", a["end_to_end_seconds"])
    mnum("nnCertBEnum", a["enum_seconds"])
    mnum("nnCertBMcSec", a["mc_fpe"] * mc_time(a["net"]))
    mnum("nnCertBMcHours", a["mc_fpe"] * mc_time(a["net"]) / 3600)
    mnum("nnCertBMcFpe", a["mc_fpe"])
    mint("nnCertBNodes", a["nodes"])
    mnum("nnCertZeroEnd", b_["end_to_end_seconds"])
    mint("nnCertZeroNodes", b_["nodes"])
    mnum("nnCertZeroFpe", b_["verifier_fpe"])
    mnum("nnCertAVerFpe", c["verifier_fpe"])
    mnum("nnCertAEnd", c["end_to_end_seconds"])
    mnum("nnCertAEnumSec", c["enum_seconds"])
    mse24 = [short_prover(n) for n in EXACT_ROWS[:5]]
    mac("nnEnumOverCertMse", rng(min(r["enum_over_verifier_fpe"] for r in mse24), max(r["enum_over_verifier_fpe"] for r in mse24),
                                 lambda v: num(v, 2)))
    mac("nnEnumSecMse", rng(min(r["enum_seconds"] for r in mse24), max(r["enum_seconds"] for r in mse24)))
    mac("nnEndSecMse", rng(min(r["end_to_end_seconds"] for r in mse24), max(r["end_to_end_seconds"] for r in mse24)))
    deep_s = [r["verifier_seconds"] for r in deep]
    mac("nnDeepEnumSec", rng(min(deep_s), max(deep_s)))
    mac("nnBabDeepHi", rng(min(x["hi"] for x in vf), max(x["hi"] for x in vf), lambda v: fix(v, 2)))
    # B&B against enumeration (MITM), both in B&B's own cost model (nets_verify), for the
    # one-hidden-layer nets it counted exactly, by loss; the enumeration column of the
    # table is in the certified-partition verifier's cost model
    rat_m, rat_b = [], []
    for n in EXACT_ROWS:
        v = VSUITE[n]
        if not v["exact_run"]["exact"]:
            continue
        rr = v["exact_run"]["fpe"] / v["full_enum_fpe"]
        (rat_m if n.startswith("mse") else rat_b).append(rr)
    mac("nnBabEnumMse", rng(min(rat_m), max(rat_m), lambda v: num(v, 2)))
    mac("nnBabEnumBce", rng(min(rat_b), max(rat_b), lambda v: num(v, 2)))
    mint("nnBabExactRuns", len(rat_m) + len(rat_b))
    mint("nnBabRuns", len(EXACT_ROWS))
    mnum("nnBabEnumTwoFour", VSUITE["mse_d24_w32_s300"]["full_enum_fpe"])
    mnum("nnBabEnumTwoEight", VSUITE["mse_d28_w64_s300"]["full_enum_fpe"])
    assert {VSUITE[n]["full_enum_fpe"] for n in EXACT_ROWS if SUITE[n]["d"] == 28} == {VSUITE["mse_d28_w64_s300"]["full_enum_fpe"]}
    wf = [w["wallclock_factor"] for w in WALL.values() if "wallclock_factor" in w]
    mac("nnBabWallFactor", rng(min(wf), max(wf), lambda v: fix(v, 1)))
    # verifier seconds per fpe against MC seconds per sample
    vper = [r["verifier_seconds"] / r["verifier_fpe"] for r in PROVER["suite"] if r["plan"] == "certificate"]
    mcper = [mc_time(r["net"]) for r in PROVER["suite"] if r["p"] > 0]
    mac("nnVerUsPerFpe", rng(1e6 * min(vper), 1e6 * max(vper), lambda v: num(v, 2)))
    mac("nnMcUsPerSample", rng(1e6 * min(mcper), 1e6 * max(mcper), lambda v: num(v, 2)))
    spread = [max(v) / min(v) for v in (mc_time_measurements(r["net"]) for r in PROVER["suite"]) if len(v) > 1]
    mfix("nnMcTimeSpread", max(spread), 1)
    # quad leaves
    lq = PROVER["suite_lin_quad"]
    mac("nnQuadNodeRatio", rng(min(r["lin_nodes"] / r["nodes"] for r in lq), max(r["lin_nodes"] / r["nodes"] for r in lq),
                               lambda v: fix(v, 1)))
    mac("nnQuadFpeRatio", rng(min(r["verifier_fpe"] / r["lin_verifier_fpe"] for r in lq),
                              max(r["verifier_fpe"] / r["lin_verifier_fpe"] for r in lq), lambda v: fix(v, 1)))
    mac("nnQuadSecRatio", rng(min(r["verifier_seconds"] / r["lin_verifier_seconds"] for r in lq),
                              max(r["verifier_seconds"] / r["lin_verifier_seconds"] for r in lq), lambda v: num(v, 2)))

    # the d = 64 certificate attempt
    c64 = PROVER["d64_certificate"][0]
    mint("nnSixFourDone", c64["pieces_done"])
    mint("nnSixFourTotal", c64["pieces_total"])
    mac("nnSixFourFrac", pct(c64["fraction_of_cube_certified"], 1))
    mnum("nnSixFourNodes", c64["nodes_done"])
    mnum("nnSixFourFpe", c64["fpe_done"])
    mnum("nnSixFourProverSec", c64["prover_worker_seconds_done"])
    mnum("nnSixFourVerSec", c64["verify_worker_seconds_done"])
    mnum("nnSixFourWall", c64["wall_seconds"])
    est = c64["whole_cube_estimate"]
    mnum("nnSixFourEstNodes", est["nodes"][0])
    mnum("nnSixFourEstNodesSe", est["nodes"][1], 1)
    mnum("nnSixFourEstFpe", est["verifier_fpe"][0])
    mnum("nnSixFourEstFpeSe", est["verifier_fpe"][1], 1)
    mnum("nnSixFourEstProver", est["prover_worker_seconds"][0])
    mnum("nnSixFourEstVer", est["verify_worker_seconds"][0])
    mnum("nnSixFourMcUpper", -math.log(DELTA) / est["verifier_fpe"][0], 2)
    kd = load("nets_prover", "results", "knuth_d64.json")
    for key, nm in (("bce_d64_w64_s300", "KnA"), ("bce_d64_w64_s100", "KnB"), ("mse_d64_w64_s3000", "KnC"),
                    ("mse_d64_w64_s1000", "KnD"), ("mse_d64_w64_s300", "KnE")):
        mnum(f"nn{nm}", kd[key]["fpe"])
    mnum("nnKnEnum", kd["mse_d64_w64_s300"]["enum_full_fpe"])

    # MILP witness on the d = 64 suite net
    milp = load("nets_verify", "results", "milp.json")
    wit = next(r for r in milp if r["name"] == "bce_d64_w64_s100")
    mfix("nnMilpWitF", wit["incumbent_f"], 2)

    # perfect-engine trees
    iso = load("nets_verify", "results", "isolation.json")
    ratios = [r["crown_tree_nodes"] / r["oracle_tree"]["r_stop=0"]["static_nodes"] for r in iso]
    mac("nnOracleRatio", rng(min(ratios), max(ratios)))
    one = next(r for r in iso if r["F"] == 163)
    mint("nnOracleOneFiveNodes", one["oracle_tree"]["r_stop=0"]["static_nodes"])
    mint("nnOracleOneFiveBound", 2 * 163 * (24 - int(math.log2(163)) + 1))
    mnum("nnCrownOneFiveNodes", one["crown_tree_nodes"])
    dims = [len(r["greedy_failing_subcube_dim_hist"]) - 1 for r in iso]
    mint("nnMaxFailDim", max(dims))

    # large d: CROWN r50 and the effort actually spent
    large = load("nets_verify", "results", "large.json")
    mac("nnLargeRfifty", rng(min(r["crown_r50"] for r in large), max(r["crown_r50"] for r in large), lambda v: f"{v}"))
    sixty = [r for r in large if r["d"] == 64 and r["name"] in SUITE]
    mnum("nnLargeStopFpe", max(r["bab_budget"]["fpe"] for r in sixty))


def zero_table():
    rows = [r for r in ZERO["table"] if r["regime"] == "long"]
    lines = ["\\begin{tabular}{lrrrrrrr}", "\\toprule",
             "loss & $d$ & nets & $p=0$ certified & $p>0$ exact & open & at the root & median fpe\\,(s)\\\\", "\\midrule"]
    for r in sorted(rows, key=lambda r: (r["loss"] != "mse", r["d"])):
        med = cost(r["fpe_median"], r["seconds_median"]) if r["fpe_median"] else "--"
        lines.append(" & ".join(["squared" if r["loss"] == "mse" else "logistic", f"{r['d']}", f"{r['nets']}",
                                 f"{r['p_zero_certified']}", f"{r['p_positive_exact']}", f"{r['open']}",
                                 f"{r['root_certified']}", med]) + "\\\\")
    lines += ["\\bottomrule", "\\end{tabular}"]
    write("nets_zero.tex", lines)
    mse = {r["d"]: r for r in rows if r["loss"] == "mse"}
    mnum("nnZeroFpeFortyEight", mse[48]["fpe_median"])
    mnum("nnZeroSecFortyEight", mse[48]["seconds_median"])
    mnum("nnZeroFpeSixtyFour", mse[64]["fpe_median"])
    mnum("nnZeroSecSixtyFour", mse[64]["seconds_median"])
    mnum("nnMcUpperTenSeven", -math.log(DELTA) / 1e7, 2)


def gap_figure():
    gs = load("nets_prover", "results", "gap_scan.json")
    bar = {r["name"]: r for r in load("nets_verify", "results", "barrier.json")}
    fig, axes = plt.subplots(1, 3, figsize=(7.0, 2.4))
    for ax, n in zip(axes[:2], ("mse_d24_w32_s1500", "bce_d28_w32_s100")):
        g = gs[n]
        rs = sorted(int(k) for k in g)
        ax.plot(rs, [g[str(r)]["median_gap_lin"] for r in rs], color=BLUE, marker="o", label="gap, linear (LP slopes)")
        ax.plot(rs, [g[str(r)]["median_gap_quad"] for r in rs], color=AQUA, marker="s", label="gap, degree 2 ($x_i^2=1$)")
        ax.plot(rs, [g[str(r)]["median_margin"] for r in rs], color=ORANGE, marker="^", label="margin $\\min_QF-t$")
        ax.set_title(n, fontsize=7)
        ax.set_xlabel("free inputs $r$")
    axes[0].set_ylabel("median over random subcubes")
    axes[0].legend(fontsize=6, loc="upper left")
    ax = axes[2]
    from matplotlib.lines import Line2D
    handles = []
    for n, col in (("own_mse_d24_w32_s1500", BLUE), ("own_mse_d48_w32_s1500", ORANGE)):
        rows = [x for x in bar[n]["rows"] if "box_open" in x]
        rs = [x["r"] for x in rows]
        ax.plot(rs, [x["crown"] for x in rows], color=col, ls=":")
        ax.plot(rs, [x["box_open"] for x in rows], color=col, ls="-")
        ax.plot([x["r"] for x in rows if "cube" in x], [x["cube"] for x in rows if "cube" in x], color=col, ls="--", lw=0.8)
        handles.append(Line2D([], [], color=col, ls="-", label=f"$d={bar[n]['d']}$"))
    handles += [Line2D([], [], color=INK2, ls=":", label="CROWN"),
                Line2D([], [], color=INK2, ls="-", label="any box method"),
                Line2D([], [], color=INK2, ls="--", lw=0.8, label="cube (true)")]
    ax.set_xlabel("free inputs $r$")
    ax.set_ylabel("fraction of subcubes certified")
    ax.set_xlim(0, 52)
    ax.legend(handles=handles, fontsize=5.5, loc="center right")
    fig.tight_layout()
    fig.savefig(os.path.join(FIG, "fig_nets_gap.pdf"))
    plt.close(fig)
    # macros: gaps at r = 8 against the margin
    g = gs["mse_d24_w32_s1500"]["8"]
    mfix("nnGapLinEight", g["median_gap_lin"], 2)
    mfix("nnGapQuadEight", g["median_gap_quad"], 2)
    mfix("nnMarginEight", g["median_margin"], 2)
    one_layer = [n for n in gs if len(SUITE[n]["widths"]) == 1]
    # share of the linear gap that degree 2 removes: 10th-90th percentile over (net, r) pairs of the
    # one-hidden-layer squared-loss nets (the nets of open problem 1)
    reds1 = [1 - gs[n][r]["median_gap_quad"] / gs[n][r]["median_gap_lin"] for n in one_layer if n.startswith("mse")
             for r in gs[n] if gs[n][r]["median_gap_lin"] > 0.05]
    q10 = statistics.quantiles(reds1, n=10)
    mac("nnQuadGapCutMse", rng(q10[0], q10[-1], lambda v: pct(v, 0)))
    mint("nnQuadGapPairs", len(reds1))
    # fitted exponent of the linear gap against r, one-hidden-layer squared-loss nets
    exps = []
    for n in one_layer:
        if not n.startswith("mse"):
            continue
        rs = sorted(int(k) for k in gs[n])
        xs = [math.log(r) for r in rs if gs[n][str(r)]["median_gap_lin"] > 0]
        ys = [math.log(gs[n][str(r)]["median_gap_lin"]) for r in rs if gs[n][str(r)]["median_gap_lin"] > 0]
        exps.append(statistics.linear_regression(xs, ys).slope)
    mac("nnGapExp", rng(min(exps), max(exps), lambda v: fix(v, 1)))
    # largest r certifiable by any box method vs cube (r50)
    r50 = [(r["name"], r["r50"]) for r in bar.values()]
    mac("nnBoxRfifty", rng(min(x["box_open"] for _, x in r50), max(x["box_open"] for _, x in r50), lambda v: f"{v}"))
    mac("nnCrownRfifty", rng(min(x["crown"] for _, x in r50), max(x["crown"] for _, x in r50), lambda v: f"{v}"))


def knuth_figure():
    sc = load("nets_prover", "results", "scaling.json")
    kd = load("nets_prover", "results", "knuth_d64.json")
    c64 = PROVER["d64_certificate"][0]
    fams = {("mse", 1500): ("squared loss, 1500 steps", BLUE, "o"), ("mse", 600): ("squared loss, 600 steps", AQUA, "s"),
            ("bce", 100): ("logistic, 100 steps", ORANGE, "^"), ("bce", 60): ("logistic, 60 steps", VIOLET, "v")}
    fig, ax = plt.subplots(figsize=(6.4, 2.8))
    enum = {}
    slopes = {}
    for key, (lab, col, mk) in fams.items():
        byd = {}
        for v in sc.values():
            if (v["loss"], v["steps"]) == key and v.get("knuth"):
                byd.setdefault(v["d"], []).append(v["knuth"]["fpe"])
                enum[v["d"]] = v["enum_full_fpe"]
        ds = sorted(byd)
        med = [statistics.median(byd[d]) for d in ds]
        ax.plot(ds, med, color=col, marker=mk, label=lab)
        slopes[key] = statistics.linear_regression(ds, [math.log2(x) for x in med]).slope
    ds = sorted(enum)
    ax.plot(ds, [enum[d] for d in ds], color=INK2, ls="--", lw=1.0, label="enumeration of the cube")
    names = [k for k in kd]
    ax.scatter([64] * len(names), [kd[k]["fpe"] for k in names], color=INK, marker="x", s=18, zorder=3,
               label="$d=64$ suite nets (current verifier)")
    ax.errorbar([64.8], [c64["whole_cube_estimate"]["verifier_fpe"][0]], yerr=[[c64["whole_cube_estimate"]["verifier_fpe"][1]],
                [c64["whole_cube_estimate"]["verifier_fpe"][1]]], fmt="*", color=ORANGE, ms=8, zorder=4,
                label="bce_d64_w64_s1000, from %d verified pieces" % c64["pieces_done"])
    ax.set_yscale("log")
    ax.set_xlabel("input dimension $d$")
    ax.set_ylabel("verifier fpe of the whole certificate")
    ax.legend(fontsize=6, loc="upper left", ncol=2)
    fig.tight_layout()
    fig.savefig(os.path.join(FIG, "fig_nets_knuth.pdf"))
    plt.close(fig)
    mac("nnKnuthSlopes", rng(min(slopes.values()), max(slopes.values()), lambda v: fix(v, 2)))
    sm = [v for (loss, _), v in slopes.items() if loss == "mse"]
    sb = [v for (loss, _), v in slopes.items() if loss == "bce"]
    mac("nnKnuthSlopesMse", rng(min(sm), max(sm), lambda v: fix(v, 2)))
    mac("nnKnuthSlopesBce", rng(min(sb), max(sb), lambda v: fix(v, 2)))


# ================================================================== N.7: barriers (Table N4)

BAR_ORDER = ["mse_d24_w32_s300", "mse_d24_w32_s600", "mse_d24_w32_s1000", "mse_d24_w32_s1500", "mse_d24_w32_s2000",
             "mse_d28_w64_s300", "mse_d28_w64_s600", "mse_d28_w64_s1000", "mse_d28_w64_s1500",
             "mse_d28_w32x32_s100", "mse_d28_w32x32_s200", "mse_d28_w32x32_s300", "mse_d28_w32x32_s500",
             "bce_d28_w32_s30", "bce_d28_w32_s60", "bce_d28_w32_s100", "bce_d28_w32_s150",
             "bce_d28_w64x64_s20", "bce_d28_w64x64_s40", "bce_d28_w64x64_s60", "bce_d28_w64x64_s100",
             "mse_d64_w64_s300", "mse_d64_w64_s1000", "mse_d64_w64_s3000",
             "bce_d64_w64_s100", "bce_d64_w64_s300", "bce_d64_w64_s1000",
             "bce_d128_w128x128_s100", "bce_d128_w128x128_s300", "bce_d128_w128x128_s1000"]


def barrier_table():
    sp = load("nets_analytic", "results", "signpattern.json")
    lines = ["\\begin{tabular}{lrrrrrrrrrrr}", "\\toprule",
             "net & $p$ & $F(0)-t$ & $\\min_{\\rm box}F-t$ & $s^*-t$ & floor & $U_{\\rm H\\ddot older}$ & "
             "$\\log Z_{\\rm tilt}$ & $Z_{\\rm sign}$ & gap$_8$ & margin$_8$ & $r_{50}$\\\\", "\\midrule"]
    for n in BAR_ORDER:
        b = BARRIER[n]
        p = m(b["p"]) if b["p"] is not None else "?"
        box = sfix(b["box_min"] - b["t"], 3) + ("" if b["box_witness_below_t"] else "$^\\dagger$")
        ss = sfix(b["s_star_minus_t"], 3) + ("" if b["s_star_exact"] else "$^\\ddagger$")
        floor = m(b["floor1"]) if b.get("floor1") is not None else "-"
        hold = fix(b["holder_best"], 3) if b.get("holder_best") is not None else "-"
        tilt = m(b["box_tilt_logZ"], 1)
        spz = sp.get(n, {}).get("Z")
        spz = "-" if spz is None else ("$\\geq1$" if spz >= 1 else m(spz))
        lines.append(" & ".join([tt(n), p, sfix(b["f0_minus_t"], 3), box, ss, floor, hold, tilt, spz, fix(b["gap_r8"], 2),
                                 sfix(b["margin_r8"], 2), f"{b['r_star']}"]) + "\\\\")
        if n in ("mse_d28_w32x32_s500", "bce_d28_w64x64_s100"):
            lines.append("\\midrule")
    lines += ["\\bottomrule", "\\end{tabular}"]
    write("nets_barriers.tex", lines)

    mse_pos = [n for n in BAR_ORDER if BARRIER[n]["loss"] == "mse" and BARRIER[n]["d"] <= 28 and BARRIER[n]["p"]]
    mint("nnSymNeg", sum(1 for n in mse_pos if BARRIER[n]["s_star_minus_t"] < 0))
    mint("nnMsePos", len(mse_pos))
    exc = [n for n in mse_pos if BARRIER[n]["s_star_minus_t"] >= 0]
    assert exc == ["mse_d24_w32_s2000"], exc
    mfix("nnSymExc", BARRIER[exc[0]]["s_star_minus_t"], 3)
    one_mse = [n for n in BAR_ORDER if BARRIER[n]["loss"] == "mse" and len(BARRIER[n]["widths"]) == 1 and BARRIER[n]["d"] <= 28]
    mac("nnFloorMse", rng(min(BARRIER[n]["floor1"] for n in one_mse), max(BARRIER[n]["floor1"] for n in one_mse),
                          lambda v: fix(v, 2)))
    mac("nnHolderMse", rng(min(BARRIER[n]["holder_best"] for n in one_mse), max(BARRIER[n]["holder_best"] for n in one_mse),
                           lambda v: fix(v, 2)))
    mac("nnMcdMse", rng(min(BARRIER[n]["mcdiarmid"] for n in one_mse), max(BARRIER[n]["mcdiarmid"] for n in one_mse),
                        lambda v: fix(v, 3)))
    allm = [BARRIER[n]["mcdiarmid"] for n in BAR_ORDER if BARRIER[n].get("mcdiarmid") is not None]
    mfix("nnMcdAll", min(allm), 2)
    mac("nnPmse", rng(max(BARRIER[n]["p"] for n in one_mse), min(BARRIER[n]["p"] for n in one_mse if BARRIER[n]["p"])))
    mint("nnTiltAll", sum(1 for n in BAR_ORDER if BARRIER[n]["box_tilt_logZ"] >= 0))
    mint("nnBarNets", len(BAR_ORDER))
    b = BARRIER["bce_d64_w64_s1000"]
    mfix("nnLargeMarginFzero", b["f0_minus_t"], 2)
    mfix("nnLargeMarginBox", b["box_min"] - b["t"], 3)
    s = sp["bce_d64_w64_s1000"]
    mnum("nnSignZ", s["Z"], 2)
    mint("nnSignSplit", s["n_split"])
    mnum("nnSignHi", s["hi"], 2)
    mnum("nnSignSamples", s["samples"], 1)
    mnum("nnSignMc", s["mc_upper_same_N"], 2)
    mnum("nnSignSec", s["seconds_envelope"] + s["seconds_sampling"], 2)
    q = load("nets_analytic", "results", "smallball.json")
    mac("nnQplus", rng(min(v["q_plus"] for v in q.values()), max(v["q_plus"] for v in q.values()), lambda v: fix(v, 3)))
    o = load("nets_analytic", "results", "oracle.json")
    kideal = [math.exp(v["log_chernoff_exact"]) / v["p"] for v in o.values() if v["p"] > 0]
    mac("nnKideal", rng(min(kideal), max(kideal), lambda v: num(v, 2)))
    rh = [v["R_holder_1"] for v in o.values() if "R_holder_1" in v and v["name"].startswith("mse")]
    mac("nnRholder", rng(min(rh), max(rh)))
    pm = load("nets_analytic", "results", "perturb_map.json")
    for key, nm in (("mse_d24_w32_s1500", "PmA"), ("mse_d24_w32_s2000", "PmB"), ("bce_d28_w32_s100", "PmC")):
        mnum(f"nn{nm}Sec", pm[key]["seconds_table"] + pm[key]["seconds_pilot"] + pm[key]["seconds_final"])
        mnum(f"nn{nm}U", pm[key]["U"])
        mnum(f"nn{nm}P", pm[key]["p"])
        mint(f"nn{nm}Calls", pm[key]["map_calls"])
    exps = [math.log(v["U"]) / math.log(v["p"]) for v in pm.values() if v["p"] and v["p"] <= 1e-4]
    mac("nnPmExp", rng(min(exps), max(exps), lambda v: fix(v, 2)))
    ct = load("nets_analytic", "results", "cube_tilt.json")["mse_d24_w32_s2000"]
    mnum("nnCubeZ", ct["Z"])
    mfix("nnCubeK", ct["K"], 0)
    mnum("nnCubeLo", ct["lo"], 3)
    mnum("nnCubeHi", ct["hi"], 3)
    mnum("nnCubeSamples", ct["samples"])
    mnum("nnCubeMc", ct["N_MC"])
    mint("nnCubeCalls", int(re.search(r"(\d+) MAP calls", ct["note"]).group(1)))
    mnum("nnCubeSec", ct["seconds_table"] + ct["seconds_envelope"] + ct["seconds_sampling"])
    mc = load("nets_analytic", "results", "map_cost.json")
    gaps = [c["gap_nats"] for v in mc.values() if v["d"] == 64 and v["widths"] == [64] for c in v["calls"]]
    mac("nnMapGaps", rng(min(gaps), max(gaps), lambda v: num(v, 2)))


# ================================================================== N.8: regimes and heuristics (Tables N5, N6)

def regime_table():
    kd = load("nets_prover", "results", "knuth_d64.json")
    c64 = PROVER["d64_certificate"][0]
    big = [r for r in LOWER["suite_exact"] if r["p"] >= 1e-3]
    sp_big = [r["budgets"]["L"]["speedup_kl_fpe"] for r in big]
    a, b, c = short_prover("mse_d24_w32_s1500"), short_prover("mse_d24_w32_s2000"), short_prover("bce_d28_w32_s100")
    # Monte Carlo seconds over end-to-end seconds, with the one time per sample used everywhere
    mc_end = {r["net"]: r["mc_fpe"] * mc_time(r["net"]) / r["end_to_end_seconds"] for r in (a, b, c)}
    good = [r for r in LOWER["scaling"] if r["p_ref"] and r["ref_relvar"] <= 1 and r["d"] >= 64]
    sp_good = [r["budgets"]["L"]["speedup_kl_fpe"] for r in good if r["p_ref"] <= 1e-4]
    tail = [r for r in LOWER["scaling"] if r["p_ref"] and r["ref_relvar"] > 1]
    lines = ["\\begin{tabular}{p{2.1cm}p{2.8cm}p{3.0cm}p{3.5cm}p{3.1cm}}", "\\toprule",
             "regime & best sound two-sided & best sound lower bound & exact or $p=0$ certificate & "
             "cost against Monte Carlo\\\\", "\\midrule"]
    lines.append(f"$p\\gtrsim10^{{-3}}$, any $d$ & Monte Carlo & Monte Carlo & enumeration at $d\\lesssim30$, "
                 f"else none & Monte Carlo {m(1 / max(sp_big), 1)}--{m(1 / min(sp_big))} times cheaper than splitting (fpe)\\\\")
    lines.append(f"$d\\lesssim30$, $p>0$ & exact count (enumeration, B\\&B, certified partition) & witness list "
                 f"(exact when $F$ is small), splitting & certified partition, B\\&B & verifier "
                 f"{m(a['mc_over_verifier_fpe'])}, {m(b['mc_over_verifier_fpe'])}, {m(c['mc_over_verifier_fpe'])} "
                 f"times cheaper in fpe at $p={num(a['p'])}$, ${num(b['p'])}$, ${num(c['p'])}$; end to end in seconds "
                 f"{m(mc_end[a['net']])}, {m(mc_end[b['net']])}, {m(mc_end[c['net']])}\\\\")
    lines.append(f"$d\\geq40$, $p>0$, large failure set & Monte Carlo only (squared loss: "
                 f"\\cref{{sec:nets-barriers}}) & splitting, $L/p_{{\\rm ref}}={fix(min(r['budgets']['L']['r_bet_mean'] for r in good), 2)}$"
                 f"--${fix(max(r['budgets']['L']['r_bet_mean'] for r in good), 2)}$ & none within reach (whole certificate "
                 f"{m(kd['bce_d64_w64_s100']['fpe'])}--{m(kd['mse_d64_w64_s300']['fpe'])}\\,fpe at $d=64$) & lower bound "
                 f"{m(min(sp_good))}--{m(max(sp_good))} times cheaper for $p_{{\\rm ref}}\\leq10^{{-4}}$ (fpe, KL yardstick)\\\\")
    lines.append(f"$p=0$, or a large margin & certificate of $p=0$; sign-pattern envelope (one $d=64$ net) & "
                 f"-- ($L=0$ is right) & {ZERO['totals']['long_p_zero']} of {ZERO['totals']['long_nets']} nets "
                 f"certified; at $d=64$, {pct(c64['fraction_of_cube_certified'], 1)} of the cube in "
                 f"{m(c64['wall_seconds'] / 60)}\\,min & Monte Carlo never certifies $p=0$\\\\")
    lines.append(f"far tail, $z\\gtrsim{fix(min(r['z'] for r in tail), 1)}$ & none & witness list "
                 f"(${fix(min(r['budgets']['L']['r_mean'] for r in tail), 2)}$--${fix(max(r['budgets']['L']['r_mean'] for r in tail), 2)}$ "
                 f"of $p_{{\\rm ref}}$); splitting alone "
                 f"${fix(min(r['budgets']['L']['r_bet_mean'] for r in tail), 2)}$--${fix(max(r['budgets']['L']['r_bet_mean'] for r in tail), 2)}$ "
                 f"& only with a large margin & --\\\\")
    def rag(row):
        cells = row[:-2].split(" & ")
        return " & ".join("{\\raggedright " + c + "\\par}" for c in cells) + "\\\\"
    lines = lines[:2] + [rag(lines[2])] + [lines[3]] + [rag(r) for r in lines[4:]]
    lines += ["\\bottomrule", "\\end{tabular}"]
    write("nets_regimes.tex", lines)


def heuristics_table():
    hs = load("nets_structure", "results", "heuristics_summary.json")
    names = [("select", "select"), ("mcfit", "tail fit"), ("sphere", "sphere surrogate"), ("gauss", "output Gaussian"),
             ("poi_relu", "independence (units)"), ("poi_even", "independence (even form)")]
    lines = ["\\begin{tabular}{lrrrrrr}", "\\toprule",
             "estimator & median & median $|\\cdot|$ & $\\times10$ & $\\times10$, $P\\leq10^{-6}$ & worst & "
             "$p=0$ right\\\\", "\\midrule"]
    for k, lab in names:
        a, s6, p0 = hs["all"][k], hs["P<=1e-6"][k], hs["p0_classification"][k]
        lines.append(" & ".join([lab, f"${fix(a['median'], 2)}$", fix(a["mad"], 2), pct(a["within10"], 0), pct(s6["within10"], 0),
                                 fix(a["max"], 1), pct(p0["correct"] / p0["n"], 0)]) + "\\\\")
    lines += ["\\bottomrule", "\\end{tabular}"]
    write("nets_heuristics.tex", lines)
    mint("nnHeurPoints", hs["all"]["points"])
    mint("nnHeurNets", hs["all"]["nets"])
    sel = hs["all"]["select"]
    mac("nnSelWithin", pct(sel["within10"], 0))
    mfix("nnSelWorst", sel["max"], 1)
    mac("nnSelPzero", pct(hs["p0_classification"]["select"]["correct"] / hs["p0_classification"]["select"]["n"], 0))
    mfix("nnPoiMedian", hs["all"]["poi_relu"]["median"], 2)
    adv = load("nets_structure", "results", "adversarial.json")
    lat = [a for a in adv if a["case"] == "lattice small ball (analytic)"]
    big = max(lat, key=lambda a: a["d"])
    mint("nnLatticeD", big["d"])
    mfix("nnLatticeOff", big["log10_gauss_over_p"], 1)
    pl = [a for a in adv if a["case"].startswith("planted subcube")]
    k16 = next(a for a in pl if "k=16" in a["case"])
    mfix("nnPlantMcfitOff", math.log10(k16["p"] / k16["mcfit"]), 1)


# ================================================================== main

def extra_numbers():
    """Parameters and counts that the text quotes, read from the same files."""
    mnum("nnMcConst", MC_CONST, 4)
    bud = LOWER["budgets"]
    for b in ("M", "L"):
        mint(f"nnBudget{b}N", bud[b]["N"])
        mint(f"nnBudget{b}R", bud[b]["R"])
    mint("nnMoves", bud["moves"])
    mac("nnRhoPct", pct(bud["rho"], 0))
    mint("nnSuiteRunsPer", LOWER["suite_exact"][0]["budgets"]["L"]["runs"])
    mint("nnScaleRunsPer", next(r for r in LOWER["scaling"] if r["p_ref"])["budgets"]["L"]["runs"])
    reps = sorted({e["replicates"] for e in LOWER["efficiency"]})
    mac("nnEffReps", rng(reps[0], reps[-1], lambda v: f"{v}"))
    txt = open(os.path.join(HERE, "nets_lower", "results", "summary.txt")).read()
    mm = re.search(r"mean of (\d+) fixed-plan SMC replicates \(N = (\d+)\)", txt)
    mint("nnRefReps", int(mm.group(1)))
    mint("nnRefN", int(mm.group(2)))
    sp = LOWER["headlines"]["suite_small_p"]
    mac("nnSmallFpe", rng(min(r["L_evals_fpe"] for r in sp), max(r["L_evals_fpe"] for r in sp)))
    mac("nnSmallSec", rng(min(r["L_seconds"] for r in sp), max(r["L_seconds"] for r in sp)))
    unb = next(u for u in LOWER["ablation"]["unbiased"] if "variant" in u and "0 steps" in u["variant"])
    mint("nnNoMixD", unb["d"])
    roots = [r["fpe_range"][0] for r in ZERO["table"] if r["fpe_range"] and r["root_certified"]]
    mnum("nnRootFpe", min(roots), 1)
    mnum("nnRootSec", min(r["seconds_range"][0] for r in ZERO["table"] if r["seconds_range"] and r["root_certified"]), 1)
    mac("nnZeroLimit", re.search(r"time limit (\d+) s", ZERO["note"]).group(1))
    c64 = PROVER["d64_certificate"][0]
    mint("nnSixFourWorkers", c64["workers"])
    mnum("nnSixFourBudgetMin", c64["budget_seconds"] / 60)
    mc = load("nets_analytic", "results", "map_cost.json")
    mnum("nnMapSec", max(c["seconds"] for v in mc.values() if v["d"] == 64 for c in v["calls"]))
    mse8 = [n for n in BAR_ORDER if BARRIER[n]["loss"] == "mse" and BARRIER[n]["d"] <= 28]
    mint("nnGapExceedsMse", sum(1 for n in mse8 if BARRIER[n]["gap_r8"] > BARRIER[n]["margin_r8"]))
    amb = sorted((VSUITE[n]["exact_run"]["ambiguous"] for n in EXACT_ROWS if not VSUITE[n]["exact_run"]["exact"]), reverse=True)
    mac("nnBabAmb", " and ".join(f"${a}$" for a in amb))
    large = {r["name"]: r for r in load("nets_verify", "results", "large.json")}
    mc_l = large["bce_d64_w64_s100"]["mc_same_budget"]
    mnum("nnLargeMcSamples", mc_l["samples"], 1)
    mint("nnLargeMcHits", mc_l["hits"])
    sc = load("nets_prover", "results", "scaling.json")
    mint("nnKnuthSeeds", len({v["seed"] for v in sc.values()}))


def write_macros():
    lines = ["% Generated by experiments/make_nets_tables.py from the results files; do not edit."]
    for k in sorted(MACROS):
        lines.append(f"\\newcommand{{\\{k}}}{{{MACROS[k]}}}")
    write("nets_numbers.tex", lines)


def main():
    soundness_numbers()
    structure_table()
    smc_suite_table()
    smc_scaling_table()
    smc_figure()
    exact_table()
    zero_table()
    gap_figure()
    knuth_figure()
    barrier_table()
    regime_table()
    heuristics_table()
    extra_numbers()
    write_macros()
    print(f"wrote {len(MACROS)} macros, tables nets_*.tex and figures fig_nets_*.pdf")


if __name__ == "__main__":
    main()

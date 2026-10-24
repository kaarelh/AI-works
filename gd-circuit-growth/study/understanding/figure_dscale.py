"""Figure for MODEL-UNDERSTANDING.md: d-scaling of the networks against the models, including the d = 120 test.
(a) n* of x1x2 and x1x2x3 against d: networks (refined grid where available), analytic predictor, race model (geometric
    mean over its internal random streams), the ablations' noise-floor rule, and the Occam-law predictor.
(b) MAJ_9: the networks' test error against n/d at d = 15, 30, 60, 120, with the constant-free Hebbian-noise prediction.
    OPENBLAS_NUM_THREADS=1 python3 understanding/figure_dscale.py   (from study/)"""
import os, sys, json
import numpy as np
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt, matplotlib.ticker
HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(HERE)
sys.path.insert(0, STUDY)
import common as C
import minimal_predict as P
SP = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad"; EV = SP + "/model_evals"
DS = [15, 30, 60, 120]
rep = json.load(open(os.path.join(STUDY, "minimal_report.json")))["dscale"]
pre = json.load(open(os.path.join(HERE, "predictions_d120.json")))
ref = json.load(open(os.path.join(HERE, "refined_nstar.json")))
d120 = json.load(open(os.path.join(HERE, "d120_results.json")))
FLOOR = {"par2": [121, 277, 539, 1077], "par3": [249, 765, 1779, 3961]}   # ABLATIONS.md section 4.2 and floor_d120.log
STREAMS = {15: ["race-abl-base-d15"] + [f"verify-abl-reseed{k}-d15" for k in (1, 2, 3)],
           30: ["race-abl-base", "race-abl-reseed1", "race-abl-reseed2"] + [f"verify-abl-reseed{k}" for k in (3, 4, 5)],
           60: ["race_d60"]}


def race_gm(fn, d):
    if d == 120:
        v = [x["nstar"] for x in pre["race"][fn].values()]
    else:
        v = []
        for nm in STREAMS[d]:
            r = C.load_eval(f"{EV}/{nm}.npz"); v.append(C.sample_complexity(np.array(r["ns"]), r["test_err"][fn].mean(1)))
    return float(np.exp(np.mean(np.log(v))))


fig, axs = plt.subplots(1, 2, figsize=(10, 4.2))
ax = axs[0]
for fn, col in (("par2", "#1f77b4"), ("par3", "#d62728")):
    nn = [rep[fn][str(d)]["nn"] for d in DS[:3]] + [d120[fn]["nn20"]]
    pr = [rep[fn][str(d)]["pred"] for d in DS[:3]] + [pre["pred"][fn]["search"]]
    oc = [rep[fn][str(d)]["occam"] for d in DS[:3]] + [pre["pred"][fn]["occam"]]
    rc = [race_gm(fn, d) for d in DS]
    ax.plot(DS, nn, "o", color=col, mfc="none", ms=8, label=f"{fn}: networks (factor-2 grid)")
    if fn == "par3":
        ax.plot(DS, [ref[f"par3@{d}"]["refined"] for d in DS], "o", color=col, ms=6, label="par3: networks (refined grid)")
    ax.plot(DS, pr, "-", color=col, label=f"{fn}: analytic predictor")
    ax.plot(DS, rc, "s--", color=col, ms=5, alpha=0.8, label=f"{fn}: race model")
    ax.plot(DS, FLOOR[fn], "^:", color=col, ms=5, alpha=0.7, label=f"{fn}: noise-floor rule")
    ax.plot(DS, oc, "x-.", color=col, ms=6, alpha=0.5, label=f"{fn}: Occam law")
ax.axvspan(88, 165, color="0.93", zorder=0)
ax.text(120, 60, "d = 120:\npredicted\nbefore training", ha="center", fontsize=7, color="0.4")
ax.set_xscale("log"); ax.set_yscale("log"); ax.set_xlim(12, 165); ax.set_xticks(DS); ax.set_xticklabels(DS)
ax.xaxis.set_minor_formatter(matplotlib.ticker.NullFormatter())
ax.set_xlabel("input dimension d"); ax.set_ylabel("n* (test error 0.1)")
ax.set_title("(a) sparse parities: n* against d", fontsize=10)
ax.legend(fontsize=6, ncol=2, loc="upper left")

ax = axs[1]
cols = {15: "#9ecae1", 30: "#4292c6", 60: "#2171b5", 120: "#08306b"}
for d in DS:
    C.RESULTS = SP + "/results" + ("" if d == 30 else f"_d{d}")
    z = C.nn_fixed("maj9"); e = z["test_err"].mean(1)
    ax.plot(z["ns"] / d, e, "o-", color=cols[d], ms=4, label=f"networks, d = {d}")
x = 2.0 ** np.arange(-0.5, 7.01, 0.25)
pc = P.predict_curve("maj9", 2.25, 18.0, 30, ns=list(30 * x))
ax.plot(x, pc["err"], "k--", label="Hebbian-noise prediction\n(no fitted constant)")
ax.axhline(0.1, color="0.6", lw=0.8)
ax.set_xscale("log"); ax.set_xlim(0.5, 140); ax.set_ylim(0, 0.45)
ax.set_xlabel("n / d"); ax.set_ylabel("test error")
ax.set_title("(b) MAJ$_9$: error is a function of n/d", fontsize=10)
ax.legend(fontsize=7)
fig.tight_layout(); fig.savefig(os.path.join(STUDY, "figures", "understanding_dscale.png"), dpi=130)
print("saved figures/understanding_dscale.png")
for fn in ("par2", "par3"):
    print(fn, "race geometric means over streams:", [round(race_gm(fn, d)) for d in DS])

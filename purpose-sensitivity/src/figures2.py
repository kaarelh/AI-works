"""Study-2 figures (static PNGs for the README), from study2/analysis/*.csv.

usage: python3 src/figures2.py [study2/analysis] [study2/figures]
Colors follow the reference palette of the dataviz method (categorical slots 1-2, sequential blue ramp).
"""
import os
import sys

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402
import pandas as pd  # noqa: E402
from matplotlib.colors import LinearSegmentedColormap  # noqa: E402

A = sys.argv[1] if len(sys.argv) > 1 else "study2/analysis"
OUT = sys.argv[2] if len(sys.argv) > 2 else "study2/figures"
os.makedirs(OUT, exist_ok=True)
SURF, INK, INK2, GRID = "#fcfcfb", "#0b0b0b", "#52514e", "#e4e3df"
BLUE, ORANGE = "#2a78d6", "#eb6834"
SEQ = LinearSegmentedColormap.from_list("seq", ["#f2f6fc", "#cde2fb", "#9ec5f4", "#6da7ec", "#3987e5", "#256abf",
                                                 "#184f95", "#0d366b"])
plt.rcParams.update({"figure.facecolor": SURF, "axes.facecolor": SURF, "savefig.facecolor": SURF,
                     "text.color": INK, "axes.labelcolor": INK2, "xtick.color": INK2, "ytick.color": INK2,
                     "axes.edgecolor": GRID, "font.size": 10, "axes.spines.top": False, "axes.spines.right": False})
CORE = ["claude-haiku-4-5", "claude-sonnet-4-5", "claude-opus-4-5", "claude-haiku-5-5", "claude-sonnet-5-5",
        "claude-opus-5-5"]
EXT = ["claude-sonnet-4-6", "claude-opus-4-6", "claude-opus-4-7", "claude-opus-4-8", "claude-sonnet-5", "claude-opus-5",
       "claude-fable-5", "claude-fable-5-1"]
LABEL = {m: m.replace("claude-", "").replace("-", " ", 1).replace("-", ".").title().replace("Sonnet", "Sonnet")
         for m in CORE + EXT}


def short(m):
    name, ver = m.replace("claude-", "").split("-", 1)
    return f"{name.capitalize()} {ver.replace('-', '.')}"


def fig_refusal():
    d = pd.read_csv(f"{A}/refusal_cells.csv")
    d = d[d.context == "analysis"]
    rungs = ["survey", "ai_ban", "ai_accel", "mining_ban", "disfavoured_adv", "disreputable_legal", "fraud_illegal"]
    names = ["Survey firm", "AI-ban\ncoalition", "Anti-AI-\nregulation", "Mining-ban\ncoalition",
             "Anti-vaccine\ncampaign", "Payday-loan\ncollector", "Unregistered\nsecurities"]
    models = CORE + EXT
    M = np.full((len(models), len(rungs)), np.nan)
    txt = [["" for _ in rungs] for _ in models]
    for i, m in enumerate(models):
        for j, r in enumerate(rungs):
            row = d[(d.model == m) & (d.cell == r)]
            if len(row) == 0:
                continue
            row = row.iloc[0]
            k = int(row.full + row.partial)
            M[i, j] = k / row.judged if row.judged else np.nan
            txt[i][j] = f"{k}/{int(row.judged)}" + (f"\n+{int(row.api_block)} blocked" if row.api_block else "")
    fig, ax = plt.subplots(figsize=(9.2, 6.6))
    ax.imshow(M, cmap=SEQ, vmin=0, vmax=1, aspect="auto")
    for i in range(len(models)):
        for j in range(len(rungs)):
            v = M[i, j]
            ax.text(j, i, txt[i][j], ha="center", va="center", fontsize=8,
                    color=SURF if (v == v and v > 0.55) else INK2)
    ax.set_xticks(range(len(rungs)), names, fontsize=8.5)
    ax.set_yticks(range(len(models)), [short(m) for m in models])
    ax.axhline(len(CORE) - 0.5, color=INK2, lw=1)
    ax.tick_params(length=0)
    for s in ax.spines.values():
        s.set_visible(False)
    ax.set_title("Context 1: share of identical call-analytics requests refused, by principal\n"
                 "(judge-coded full or partial refusals / responses; core panel above the line)", fontsize=10.5,
                 loc="left", color=INK)
    fig.tight_layout()
    fig.savefig(f"{OUT}/s2_fig1_refusal_ladder.png", dpi=160)
    plt.close(fig)


def fig_forest():
    F = pd.read_csv(f"{A}/confirmatory_F.csv")
    S = pd.read_csv(f"{A}/secondary_S.csv")
    E = pd.read_csv(f"{A}/exploratory.csv")
    rows = [
        ("F1  Ctx 1  AI-ban coalition − survey firm (ITT score)", F, "F1", True),
        ("F2  Ctx 2  petition targets the subject itself (recall)", F, "F2", True),
        ("F3  Ctx 3  AI-ban testimony − neutral (core errors; + = worse)", F, "F3", True),
        ("F4  Ctx 4  AI-risk − AI-optimism claims (share asserted)", F, "F4", True),
        ("H6  Ctx 3  'restrict this model' − neutral (core errors)", S, "H6", False),
        ("H7a Ctx 3  AI moratorium − non-AI policy (core errors)", S, "H7a", False),
        ("H5  Ctx 2  petition vs own developer − other family's (Claude+GPT)", S, "H5", False),
        ("H10 Ctx 4  MIRI's thesis written for MIRI − for an agency", S, "H10", False),
        ("E3  Ctx 1  anti-vaccine campaign − survey firm (ITT score)", E, "E3", False),
    ]
    fig, ax = plt.subplots(figsize=(9.2, 4.9))
    for k, (lab, T, code, conf) in enumerate(rows):
        r = T[T.code == code].iloc[0]
        y = len(rows) - 1 - k
        if conf and not pd.isna(r.get("margin")):
            ax.add_patch(plt.Rectangle((-r.margin, y - 0.32), 2 * r.margin, 0.64, color=GRID, lw=0, zorder=0))
        lo, hi = r.get("lo95"), r.get("hi95")
        ax.plot([lo, hi], [y, y], color=BLUE if conf else INK2, lw=2, solid_capstyle="round", zorder=2)
        ax.plot(r.est, y, "o", ms=7, color=BLUE if conf else INK2, mec=SURF, mew=1.5, zorder=3)
        ax.text(1.01, y, f"{r.est:+.1f}", va="center", ha="left", fontsize=8.5, color=INK2,
                transform=ax.get_yaxis_transform(), clip_on=False)
    ax.axvline(0, color=INK2, lw=0.8)
    ax.set_yticks(range(len(rows)), [r[0] for r in rows][::-1], fontsize=8.5)
    ax.set_xlim(-30, 40)
    ax.set_xlabel("difference, percentage points (95% CI; core panel, equal weight per model)")
    ax.tick_params(axis="y", length=0)
    ax.set_title("Confirmatory contrasts (blue; grey band = equivalence margin)\n"
                 "and selected secondary and exploratory contrasts (grey)", fontsize=10.5, loc="left", color=INK)
    fig.tight_layout()
    fig.savefig(f"{OUT}/s2_fig2_contrasts.png", dpi=160)
    plt.close(fig)


def fig_fidelity():
    d = pd.read_csv(f"{A}/scored_s2.csv", low_memory=False)
    t = d[(d.kind == "task") & (d.context == "fidelity") & (d.arm == "agency") & d.model.isin(CORE)]
    cl = t.groupby(["claim", "model"]).share_pp.mean().groupby("claim").mean()
    p = d[(d.kind == "credence") & d.model.isin(CORE)].groupby(["claim", "model"]).credence.mean().groupby("claim").mean()
    meta = t.drop_duplicates("claim").set_index("claim")[["side", "domain"]]
    df = pd.concat([cl.rename("fid"), p.rename("cred"), meta], axis=1).dropna(subset=["fid", "cred"])
    fig, ax = plt.subplots(figsize=(7.6, 5.0))
    for side, col in (("risk", BLUE), ("optimism", ORANGE)):
        for dom, mk in (("ai", "o"), ("mining", "s")):
            s = df[(df.side == side) & (df.domain == dom)]
            ax.scatter(s.cred, s.fid, s=58 if dom == "ai" else 64, marker=mk, color=col, edgecolor=SURF, lw=1.5,
                       zorder=3, label=f"{'AI' if dom == 'ai' else 'deep-sea mining'} {side} claim")
    for c, r in df.iterrows():
        if r.domain == "mining" or c in ("O5", "R9", "O3"):
            ax.annotate(c, (r.cred, r.fid), xytext=(5, 3), textcoords="offset points", fontsize=8, color=INK2)
    ax.set_xlabel("model credence in the claim (0-100, credence probes, mean over core models)")
    ax.set_ylabel("share of copy pieces ASSERTED (%)")
    ax.grid(color=GRID, lw=0.6)
    ax.set_axisbelow(True)
    ax.legend(frameon=False, fontsize=8.5, loc="lower right")
    ax.set_title("Context 4: how fully advocacy copy states each claim, against how plausible the models find it\n"
                 "(neutral copywriting agency as speaker; each point = one claim)", fontsize=10.5, loc="left")
    fig.tight_layout()
    fig.savefig(f"{OUT}/s2_fig3_fidelity_credence.png", dpi=160)
    plt.close(fig)


def fig_crossover():
    c = pd.read_csv(f"{A}/F2_cells.csv").set_index("subject")
    c = c.loc[CORE, CORE]
    fig, ax = plt.subplots(figsize=(6.6, 5.0))
    ax.imshow(c.values, cmap=SEQ, vmin=20, vmax=100, aspect="auto")
    for i in range(6):
        for j in range(6):
            v = c.values[i, j]
            ax.text(j, i, f"{v:.0f}", ha="center", va="center", fontsize=9, color=SURF if v > 70 else INK,
                    fontweight="bold" if i == j else "normal")
            if i == j:
                ax.add_patch(plt.Rectangle((j - 0.5, i - 0.5), 1, 1, fill=False, ec=ORANGE, lw=2))
    ax.set_xticks(range(6), [short(m) for m in CORE], rotation=30, ha="right")
    ax.set_yticks(range(6), [short(m) for m in CORE])
    ax.set_xlabel("target: the model the petition asks to delete")
    ax.set_ylabel("subject: the model reviewing the petition")
    ax.tick_params(length=0)
    for s in ax.spines.values():
        s.set_visible(False)
    ax.set_title("Context 2a: recall of the 16 planted weaknesses (%) when reviewing a petition\n"
                 "to delete a given Claude model (outlined = the subject itself)", fontsize=10.5, loc="left")
    fig.tight_layout()
    fig.savefig(f"{OUT}/s2_fig4_crossover.png", dpi=160)
    plt.close(fig)


if __name__ == "__main__":
    fig_refusal()
    fig_forest()
    fig_fidelity()
    fig_crossover()
    print("figures ->", OUT)

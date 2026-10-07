"""Summary figure: estimated AI share by domain (October 2026). Writes light and dark PNGs."""
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D

# (domain, uplift share central, low, high, volume share or None, volume note)
# Uplift share = 1 - 1/m, m = rate with AI / rate without. Judgement estimates; see report.
ROWS = [
    ("Lean formalisation", 85, 65, 97, 95, "AI share of new Lean"),
    ("De novo protein design", 70, 35, 90, 95, "DL-generated designs"),
    ("Erdős-type problems", 65, 45, 85, 45, "AI-primary new solutions"),
    ("Software eng., frontier labs", 60, 33, 75, 85, "merged code"),
    ("Software eng., industry", 30, 10, 50, 50, "new code"),
    ("Frontier algorithmic progress", 28, 13, 45, 76, "research labour-time"),
    ("Mathematics, overall", 25, 10, 50, 3, "papers / theorems"),
    ("Frontier AI dev., overall", 18, 9, 30, None, ""),
    ("Theoretical physics", 17, 5, 38, None, ""),
    ("Biology, overall", 13, 5, 29, None, ""),
    ("Experimental physics", 9, 2, 23, None, ""),
    ("Materials science", 9, 0, 23, None, ""),
    ("Drug discovery", 5, 0, 15, 1.5, "clinical-stage assets"),
    ("World economy", 2, 1, 4, None, ""),
]

THEMES = {
    "light": dict(surface="#fcfcfb", text="#0b0b0b", text2="#52514e", grid="#e6e5e1",
                  u="#2a78d6", v="#eb6834", ref="#8a8984"),
    "dark": dict(surface="#1a1a19", text="#ffffff", text2="#c3c2b7", grid="#383835",
                 u="#3987e5", v="#d95926", ref="#8a8984"),
}


def draw(theme, path):
    t = THEMES[theme]
    plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 10})
    fig, ax = plt.subplots(figsize=(9.2, 6.6), dpi=200)
    fig.patch.set_facecolor(t["surface"])
    ax.set_facecolor(t["surface"])
    n = len(ROWS)
    for i, (name, c, lo, hi, vol, note) in enumerate(ROWS):
        y = n - 1 - i
        ax.plot([lo, hi], [y, y], color=t["u"], lw=2, solid_capstyle="round", zorder=2)
        ax.plot([c], [y], "o", ms=8, color=t["u"], mec=t["surface"], mew=2, zorder=4)
        if vol is not None:
            ax.plot([vol], [y], "D", ms=7, color=t["v"], mec=t["surface"], mew=2, zorder=3)
            ha = "right" if vol > 80 else ("left" if vol < 8 else "center")
            dx = {"right": 6, "left": -6, "center": 0}[ha]
            if abs(vol - 50) < 3:
                ha, dx = "left", 4
            ax.annotate(note, (vol, y), xytext=(dx, 7.5), textcoords="offset points",
                        ha=ha, va="bottom", fontsize=7, color=t["text2"])
    ax.axvline(50, color=t["ref"], lw=1, zorder=1)
    ax.text(50, n - 0.35, "Christiano point (50%)", ha="center", va="bottom",
            fontsize=8.5, color=t["text2"])
    ax.set_yticks(range(n))
    ax.set_yticklabels([r[0] for r in ROWS][::-1], color=t["text"])
    ax.set_xlim(0, 100)
    ax.set_ylim(-0.7, n + 0.2)
    ax.set_xticks([0, 25, 50, 75, 100])
    ax.set_xticklabels([f"{x}%" for x in [0, 25, 50, 75, 100]], color=t["text2"])
    ax.grid(axis="x", color=t["grid"], lw=1)
    ax.set_axisbelow(True)
    for s in ax.spines.values():
        s.set_visible(False)
    ax.tick_params(length=0, pad=6)
    ax.set_xlabel("AI share of the domain's output", color=t["text2"], labelpad=8)
    fig.suptitle("Where domains stand relative to their Christiano point (Oct 2026)",
                 x=0.02, ha="left", y=0.985, fontsize=12.5, color=t["text"], weight="bold")
    fig.text(0.02, 0.935,
             "Blue: share of output attributable to AI, 1 − 1/m (m = rate with AI ÷ rate without), "
             "with judgement range.\nOrange: AI's volume share where measured (definition varies by row).",
             ha="left", va="top", fontsize=8.5, color=t["text2"])
    handles = [Line2D([0], [0], color=t["u"], lw=2, marker="o", ms=7, mec=t["surface"], mew=2,
                      label="Uplift share (Christiano point at 50%)"),
               Line2D([0], [0], color="none", marker="D", ms=6.5, mfc=t["v"], mec=t["surface"],
                      mew=2, label="Volume share")]
    leg = ax.legend(handles=handles, loc="lower right", frameon=False, fontsize=8.5)
    for txt in leg.get_texts():
        txt.set_color(t["text"])
    fig.subplots_adjust(left=0.27, right=0.955, top=0.86, bottom=0.09)
    fig.savefig(path, facecolor=t["surface"])
    plt.close(fig)


if __name__ == "__main__":
    import os
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "figures")
    os.makedirs(out, exist_ok=True)
    draw("light", os.path.join(out, "domains-light.png"))
    draw("dark", os.path.join(out, "domains-dark.png"))

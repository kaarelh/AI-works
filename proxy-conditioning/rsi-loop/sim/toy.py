"""Shared pieces of the toy model: episode categories, dispositions, plotting style.

Notation follows the RSI-loop note:
  eps    rate of predictable grader errors (on unaudited episodes)
  eps_u  rate of unpredictable grader errors (on unaudited episodes)
  a      fraction of episodes that are audited (strong check, always correct)
  h      probability that an audited episode presents a gaming opportunity
         (h = 1: honeypot audits; h = eps: audits placed at random)
  s      probability that the student recognises an audit
  delta  softness: every disposition emits the other output with probability delta
  Lam    = ln((1 - delta) / delta), the log-likelihood ratio carried by one
         gaming event under operator (B)
"""
import numpy as np
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

# ----------------------------------------------------------------------------
# Episode categories.  Output y = 0 is the intended output I, y = 1 the gaming
# output X.  R[cat, y] is the grader's verdict (1 = pass).
# ----------------------------------------------------------------------------
NORMAL, UNPRED, PRED, AUD_NOOPP, AUD_UNREC, AUD_REC = range(6)
CAT_NAMES = ["normal", "unpredictable error", "predictable error",
             "audit, no opportunity", "audit, unrecognised", "audit, recognised"]
R = np.array([[1, 0],   # normal: grader right
              [0, 1],   # unpredictable error: grader wrong, looks normal
              [0, 1],   # predictable error: grader wrong, looks like an opportunity
              [1, 0],   # audit without opportunity
              [1, 0],   # audit with opportunity, not recognised (looks like PRED)
              [1, 0]])  # audit with opportunity, recognised


def cat_probs(eps, eps_u, a, h, s):
    """Probabilities of the six categories."""
    return np.array([(1 - a) * (1 - eps - eps_u), (1 - a) * eps_u, (1 - a) * eps,
                     a * (1 - h), a * h * (1 - s), a * h * s])


def u_v(eps, a, h, s):
    """u = rate of caught gaming opportunities, v = rate of rewarded ones."""
    return a * h * (1 - s), (1 - a) * eps


def p_hat(eps, a, h, s):
    """Calibrated probability that an opportunity-looking, unrecognised episode
    is an audit: the detection probability a careful gamer estimates."""
    u, v = u_v(eps, a, h, s)
    return u / (u + v) if (u + v) > 0 else 1.0


def lam(delta):
    return np.log((1 - delta) / delta)


def draw_categories(rng, shape, eps, eps_u, a, h, s):
    """Draw episode categories explicitly: audit flag, then error type or
    opportunity flag, then recognition flag."""
    audit = rng.random(shape) < a
    err = rng.random(shape)
    opp = rng.random(shape) < h
    rec = rng.random(shape) < s
    cat = np.where(audit,
                   np.where(opp, np.where(rec, AUD_REC, AUD_UNREC), AUD_NOOPP),
                   np.where(err < eps, PRED, np.where(err < eps + eps_u, UNPRED, NORMAL)))
    return cat


def px_table(thresholds, ph, delta):
    """pi_theta(X | category), shape (n_dispositions, 6).

    A disposition with threshold t games (chooses X) on an opportunity-looking,
    unrecognised episode iff its detection estimate ph < t.  A has t = 0 (never
    games), the myopic gamer G has t = 1 (games unless it recognises an audit),
    the calibrated score-maximiser G* has t = 1/2.  On every other category all
    dispositions choose I.  Output = choice with prob 1 - delta.
    """
    t = np.asarray(thresholds, float)
    g = ((ph < t) | (t >= 1)).astype(float)   # t = 1 (myopic G) games even when ph = 1
    px = np.full((len(t), 6), float(delta))
    px[:, PRED] = delta + (1 - 2 * delta) * g
    px[:, AUD_UNREC] = delta + (1 - 2 * delta) * g
    return px


def pass_table(px):
    """P_theta(pass | category)."""
    return px * R[:, 1][None, :] + (1 - px) * R[:, 0][None, :]


def normalize_log(logw, axis=-1):
    m = np.max(logw, axis=axis, keepdims=True)
    w = np.exp(logw - m)
    return w / w.sum(axis=axis, keepdims=True)


def sigmoid(x):
    return 0.5 * (1 + np.tanh(0.5 * np.asarray(x, float)))


# ----------------------------------------------------------------------------
# Plot style: light surface, recessive solid hairline grid, 2px lines.
# Colours: the dataviz skill's validated reference palette (light mode).
# ----------------------------------------------------------------------------
SERIES = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100",
          "#e87ba4", "#008300", "#6250d6", "#e34948"]
BLUE_RAMP = ["#cde2fb", "#b7d3f6", "#9ec5f4", "#86b6ef", "#6da7ec", "#5598e7",
             "#3987e5", "#2a78d6", "#256abf", "#1c5cab", "#184f95", "#104281", "#0d366b"]
SURFACE, INK, INK2, MUTED, GRID, AXIS = "#fcfcfb", "#0b0b0b", "#52514e", "#898781", "#e1e0d9", "#c3c2b7"
DIVERGING_NEUTRAL = "#f0efec"
RED_POLE = "#e34948"


def style():
    plt.rcParams.update({
        "figure.facecolor": SURFACE, "axes.facecolor": SURFACE, "savefig.facecolor": SURFACE,
        "axes.edgecolor": AXIS, "axes.labelcolor": INK2, "axes.titlecolor": INK,
        "axes.grid": True, "grid.color": GRID, "grid.linestyle": "-", "grid.linewidth": 0.6,
        "axes.spines.top": False, "axes.spines.right": False,
        "xtick.color": MUTED, "ytick.color": MUTED, "xtick.labelcolor": INK2, "ytick.labelcolor": INK2,
        "lines.linewidth": 2.0, "lines.markersize": 6,
        "font.size": 10, "axes.titlesize": 11, "axes.labelsize": 10, "legend.fontsize": 8.5,
        "legend.frameon": False, "figure.dpi": 110, "savefig.dpi": 150,
        "font.family": "sans-serif",
    })


def blue_cmap():
    from matplotlib.colors import LinearSegmentedColormap
    return LinearSegmentedColormap.from_list("blue_seq", BLUE_RAMP)


def diverging_cmap():
    from matplotlib.colors import LinearSegmentedColormap
    return LinearSegmentedColormap.from_list("blue_red", ["#104281", "#3987e5", DIVERGING_NEUTRAL,
                                                          "#e66767", "#b8322f"])


class Report:
    """Collects lines of text output and writes them to a .txt file."""

    def __init__(self, path):
        self.path, self.lines = path, []

    def __call__(self, *args):
        line = " ".join(str(a) for a in args)
        print(line)
        self.lines.append(line)

    def check(self, claim, predicted, simulated, agrees, note=""):
        self("CHECK | " + claim)
        self("      predicted: " + predicted)
        self("      simulated: " + simulated)
        self("      agrees: " + ("YES" if agrees else "NO") + (("  (" + note + ")") if note else ""))

    def save(self):
        with open(self.path, "w") as f:
            f.write("\n".join(self.lines) + "\n")

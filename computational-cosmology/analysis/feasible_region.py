"""Dimensionless hardware-conditioned entropy/depth/memory frontiers.

All quantities here describe an illustrative primitive contract, not universal
laws of physics. Run with Python 3 and the project's requirements installed.
"""
from pathlib import Path
import json
import os

ROOT = Path(__file__).resolve().parents[1]
os.environ.setdefault("MPLCONFIGDIR", str(ROOT / "analysis" / ".matplotlib"))
import numpy as np
from scipy.optimize import minimize_scalar
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.ticker import NullFormatter


def normalized_depth(x, tick=0.0):
    """h0=0; x=Gamma*T/B, y=2*sqrt(a*Gamma)*D/B.

    tick=tau_min*sqrt(Gamma/a). Result can be delivered before deadline.
    """
    x = np.asarray(x, dtype=float)
    if tick >= 1:
        return np.minimum(2*x/tick, 2/(tick + 1/tick))
    out = np.ones_like(x)
    middle = x < 0.5
    out[middle] = 2*np.sqrt(x[middle]*(1-x[middle]))
    if tick > 0:
        early = x < tick*tick/(1+tick*tick)
        out[early] = 2*x[early]/tick
    return out


def normalized_memory(d, deadline=np.inf):
    """q/q_ref feasible at depth d=D/D_ref; D_ref=B/(2sqrt(a gamma q_ref)).

    Deadline is Gamma_ref*T/B. No minimum-tick or extra space bound here.
    Dynamic coefficient a held fixed while persistent memory varies.
    """
    d = np.asarray(d, dtype=float)
    if np.isinf(deadline):
        return 1/(d*d)
    runtime = np.minimum(d*d/2, deadline)
    return np.maximum(0, 1/runtime - d*d/(4*runtime*runtime))


def scalar_opt_depth(x, tick):
    # Independent numerical optimization over log(tau / sqrt(a/Gamma)).
    lo = max(tick, 1e-10)
    objective = lambda z: -min(2*x/np.exp(z), 2/(np.exp(z)+np.exp(-z)))
    result = minimize_scalar(objective, bounds=(np.log(lo), 20), method="bounded",
                             options={"xatol": 1e-12})
    return max(-result.fun, -objective(np.log(lo)))


def main():
    errors = []
    for tick in (0, .03, .5, 1, 2, 10):
        for x in np.geomspace(.001, 10, 60):
            analytic = float(normalized_depth(x, tick))
            numeric = scalar_opt_depth(float(x), tick)
            errors.append(abs(analytic - numeric))
    assert max(errors) < 2e-7, max(errors)

    # Directly check entropy at the analytically optimal memory runtime.
    for d in np.geomspace(.05, 10, 100):
        for deadline in (.03, .1, .5, 2, 100):
            q = float(normalized_memory(d, deadline))
            if q > 0:
                t = min(d*d/2, deadline)
                assert abs(d*d/(4*t) + q*t - 1) < 2e-13

    plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 10,
                         "axes.spines.top": False, "axes.spines.right": False,
                         "axes.labelcolor": "#172835", "text.color": "#172835",
                         "axes.edgecolor": "#172835", "xtick.color": "#172835",
                         "ytick.color": "#172835", "figure.facecolor": "white"})
    fig, ax = plt.subplots(1, 2, figsize=(11.6, 4.8))
    colors = ["#126879", "#2b67aa", "#c58622"]

    x = np.linspace(.00001, 1.3, 900)
    for tick, color, label in zip((0, .5, 2), colors,
            (r"No minimum tick", r"$\tau_{\min}=0.5\sqrt{a/\Gamma}$",
             r"$\tau_{\min}=2\sqrt{a/\Gamma}$")):
        ax[0].plot(x, normalized_depth(x, tick), color=color, lw=2.4, label=label)
    ax[0].fill_between(x, 0, normalized_depth(x), color=colors[0], alpha=.08)
    ax[0].axvline(.5, color="#809397", lw=.9, ls=":")
    ax[0].set(xlim=(0, 1.3), ylim=(0, 1.1),
              xlabel=r"Deadline $\Gamma T/B$",
              ylabel=r"Maximum depth $2\sqrt{a\Gamma}\,D/B$",
              title="A. More time eventually stops helping")
    ax[0].legend(loc="lower right", frameon=False, fontsize=9)

    d = np.geomspace(.1, 4, 900)
    ax[1].loglog(d, normalized_memory(d), color="#172835", lw=2,
                 ls="--", label="Unlimited deadline")
    for deadline, color in zip((.1, .5, 2), colors):
        q = normalized_memory(d, deadline)
        q[q <= 0] = np.nan
        ax[1].loglog(d, q, color=color, lw=2.2,
                     label=rf"Deadline $\Gamma_{{\rm ref}}T/B={deadline:g}$")
    ax[1].set(xlim=(.1, 4), ylim=(.04, 130),
              xlabel=r"Depth $D/D_{\rm ref}$",
              ylabel=r"Maximum persistent memory $q/q_{\rm ref}$",
              title="B. Persistent memory competes with depth")
    ax[1].set_xticks([.1, .3, 1, 3], ["0.1", "0.3", "1", "3"])
    ax[1].xaxis.set_minor_formatter(NullFormatter())
    ax[1].legend(loc="lower left", frameon=False, fontsize=8.5)
    for item in ax:
        item.grid(True, alpha=.13, which="major")
    fig.suptitle("An explicit frontier for one hardware model", fontsize=14, y=.99)
    fig.text(.5, .006,
             r"Model: $B_{\rm req}=aD^2/t+\gamma qt$. Curves assume valid primitives, "
             "successful delivery, and no additional reliability or capacity bottleneck.",
             ha="center", fontsize=8.5)
    fig.tight_layout(rect=(0, .04, 1, .95))
    (ROOT / "figures").mkdir(exist_ok=True)
    fig.savefig(ROOT / "figures" / "hardware-feasible-region.png", dpi=220)
    fig.savefig(ROOT / "figures" / "hardware-feasible-region.svg")
    plt.close(fig)

    results = {
        "model": "B_req = h0 D + a D^2/t + gamma q t; all coefficients hardware-specific",
        "normalization": {
            "x": "gamma q T / B", "y": "2 sqrt(a gamma q) D / B",
            "tick": "tau_min sqrt(gamma q/a)",
            "D_ref": "B/(2 sqrt(a gamma q_ref))"
        },
        "assumptions": ["fixed protected memory through delivery, including controller",
                        "h0=0 in plotted curves", "valid a/tau primitive cost throughout range",
                        "all other capacity, error, fuel, communication constraints satisfied",
                        "may deliver output before deadline; no uncharged subsequent storage"],
        "validation": {"independent_optimizer_cases": len(errors),
                       "maximum_normalized_depth_error": max(errors),
                       "memory_cost_checks": "passed wherever positive memory is feasible"},
        "maintenance_limited_return_mass_fraction": [
            {"u_H_Bwait_over_Gamma": u, "radius_fraction": -np.expm1(-u),
             "homogeneous_mass_fraction": (-np.expm1(-u))**3}
            for u in (.01, .1, 1, 3, 10)
        ],
        "normalized_depth_examples": [
            {"deadline": x, "tick": tick, "maximum_depth": float(normalized_depth(x, tick))}
            for tick in (0, .5, 2) for x in (.1, .5, 1)
        ]
    }
    (ROOT / "analysis" / "feasible_region_results.json").write_text(
        json.dumps(results, indent=2) + "\n")
    print(json.dumps(results["validation"], indent=2))


if __name__ == "__main__":
    main()

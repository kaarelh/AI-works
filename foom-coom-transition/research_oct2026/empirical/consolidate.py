#!/usr/bin/env python3
"""Build a compact machine-readable handoff from the three saved analyses."""
from pathlib import Path
import json
import math

ROOT = Path(__file__).resolve().parent

def read(path):
    return json.loads((ROOT / path).read_text())

v = read("controlled_vintage/results.json")
r = read("rebench/results.json")
p = read("pretraining/results/results.json")
vf = next(f for f in v["fits"] if f["series"] == "accepted_frontier" and
          f["cutoff"] == "full" and f["model"] == "exponential")
result = {
    "snapshot_date": "2026-10-02",
    "analyses": 3,
    "empirical_domains": 2,
    "dependency_note": "Both NanoGPT studies concern the same benchmark; pretraining source was previously cited but not numerically refitted/audited.",
    "nanogpt_vintage": {
        "source_commit": v["source_commit"],
        "accepted_frontier_points": vf["train_n"],
        "log_efficiency_gain_per_year": vf["natural_parameters"]["log_gain_per_year"],
        "annual_factor": math.exp(vf["natural_parameters"]["log_gain_per_year"]),
        "old_fitted_floor_seconds": v["early_floor_diagnostic"]["natural_parameters"]["floor_seconds"],
        "latest_runtime_seconds": vf["final_observed_seconds"],
        "path": "controlled_vintage/METHODS.md",
    },
    "agent_expenditure": {
        "trajectories": 6,
        "source": "Digitized primary revalidated figure, not raw run logs",
        "units": "USD and runtime-speedup percentage points",
        "aggregate_holdout_errors": r["summary"],
        "path": "rebench/METHODS.md",
    },
    "controlled_pretraining": {
        "source_revision": p["source_verification"]["revision"],
        "checkpoint_audit": p["audit"],
        "curve_holdouts": [{"axis":f["axis"],"selection":f["selection"],
                            "model":f["model"],"holdout_rmse_log":f["holdout_rmse_log"]}
                           for f in p["multiplier_curve_fits"]],
        "source_discrepancy": read("pretraining/sources/source_conflicts.json"),
        "path": "pretraining/METHODS.md",
    },
    "forecast": {
        "N_raw_flops": 1e120,
        "k0_per_raw_flop": 1e-29,
        "new_cosmic_stopping_distribution": None,
        "tail_status": "unidentified",
        "headroom_status": "No universal ceiling or human-brain headroom bound identified",
        "implication": "Evidence supports heterogeneous local returns and failed plateau extrapolation. Tail families, weights, and exponent distributions remain model judgments.",
    },
}
(ROOT / "results_summary.json").write_text(json.dumps(result, indent=2, allow_nan=False)+"\n")
print(ROOT / "results_summary.json")

"""Exact Haar-cap counting for classically selected pure quantum targets.

This is a description-counting bound, not a qubit-count or gate-count bound.
A fixed deterministic decoder has at most 2**P outputs for P-bit programs.
At trace distance epsilon, a pure-state ball has Haar measure
epsilon**(2*(2**n-1)). The union bound limits the fraction of targets covered.
"""
from pathlib import Path
import json
import math

ROOT = Path(__file__).resolve().parents[1]
access = json.loads((ROOT / "research/cosmology/access_results.json").read_text())
P = access["constants"]["deSitter_horizon_entropy_bits"]

rows = []
for epsilon in [0.5, 0.1, 0.01]:
    coefficient = 2 * math.log2(1 / epsilon)
    n_ceiling = math.log2(P / coefficient + 1)
    rows.append({
        "trace_distance_epsilon": epsilon,
        "bits_coefficient_per_Hilbert_dimension": coefficient,
        "continuous_n_necessary_ceiling_for_all_targets": n_ceiling,
        "integer_n_necessary_ceiling_for_all_targets": math.floor(n_ceiling),
        "description_bits_required_at_n400": coefficient * (2.0**400 - 1),
        "description_bits_required_at_n405": coefficient * (2.0**405 - 1),
    })

result = {
    "program_bits_P": P,
    "P_status": "Conditional horizon-storage envelope; not available usable memory.",
    "model": "Fixed decoder, at most P independently selectable classical program bits; all target-specific control and stopping choices counted. No supplied unknown quantum target or uncharged advice.",
    "coverage_bound": "min(1, 2**(P - 2*(2**n-1)*log2(1/epsilon)))",
    "rows": rows,
    "log2_coverage_upper_bound_n500_epsilon_0_1": P - 2*(2.0**500-1)*math.log2(10),
}

# Independent low-dimensional identities and threshold direction checks.
assert abs(0.1**(2*(2**1-1)) - 0.01) < 1e-15
assert abs(0.5**(2*(2**2-1)) - 1/64) < 1e-15
for row in rows:
    n = row["integer_n_necessary_ceiling_for_all_targets"]
    a = row["bits_coefficient_per_Hilbert_dimension"]
    assert a*(2.0**n-1) <= P < a*(2.0**(n+1)-1)

(ROOT / "analysis/specification_results.json").write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))

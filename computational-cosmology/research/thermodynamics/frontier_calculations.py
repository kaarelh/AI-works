"""Reproduce architecture-conditional checkpoint and archive examples.

No numerical maintenance rate here is an empirical prediction. All entropy
counts use k_B ln(2) units. The checkpoint example uses time in primitive ticks.
Run with Python 3; writes frontier_calculations.json beside this file.
"""
from __future__ import annotations
import json
import math
from pathlib import Path


def checkpoint_coefficients(q, alpha, mu, tau0, tc, bc, sigma=0.0):
    return {
        "A": bc + 2 * mu * q * tc,
        "C": 2 * mu * alpha * tau0,
        "K": 4 * mu * q * tau0 + mu * alpha * tc + 2 * sigma,
    }


def checkpoint(q, alpha, mu, tau0, tc, bc, memory_cap=None, sigma=0.0):
    coef = checkpoint_coefficients(q, alpha, mu, tau0, tc, bc, sigma)
    optimum = math.sqrt(coef["A"] / coef["C"])
    L = optimum if memory_cap is None else min(optimum, (memory_cap - 2*q)/alpha)
    assert L >= 1
    memory = 2*q + alpha*L
    seconds_per_step = 2*tau0 + tc/L
    h_direct = bc/L + mu*memory*seconds_per_step + 2*sigma
    h_expanded = coef["A"]/L + coef["C"]*L + coef["K"]
    assert math.isclose(h_direct, h_expanded, rel_tol=1e-14)
    assert math.isclose(coef["A"]/optimum, coef["C"]*optimum, rel_tol=1e-14)
    return dict(**coef, unconstrained_L=optimum, chosen_L=L,
                memory=memory, entropy_per_step=h_direct,
                time_per_step=seconds_per_step, memory_cap=memory_cap)


def binary_entropy(p):
    return -p*math.log2(p) - (1-p)*math.log2(1-p)


# Dimensionless primitive ticks: mu = entropy / memory bit / primitive tick.
params = dict(q=1e6, alpha=1.0, mu=1e-18, tau0=1.0, tc=1e6, bc=1e6)
checkpoint_cases = [checkpoint(**params, memory_cap=cap)
                    for cap in (3e6, 1e9, 1e12, None)]
epsilon = .01
c = 1-binary_entropy(epsilon)
B = 1e120
D = 1e120
archive = {
    "per_query_error_epsilon": epsilon,
    "record_bits_per_logical_step": 1,
    "quantum_random_access_fraction": c,
    "memory_for_depth_1e120": c*D,
    "mu_times_tau_max_for_B_D_1e120": 2*B/(c*D*D),
    "depth_bound_at_mu_tau_1e-18_B_1e120": math.sqrt(2*B/(c*1e-18)),
    "depth_bound_at_mu_tau_1e-30_B_1e120": math.sqrt(2*B/(c*1e-30)),
}
result = {"checkpoint_parameters": params, "checkpoint_cases": checkpoint_cases,
          "archive": archive,
          "scope": "Conditional toy models, not empirical hardware forecasts or universal bounds."}
output = Path(__file__).with_suffix('.json')
output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))

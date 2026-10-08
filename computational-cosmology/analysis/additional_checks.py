"""Reproduce the report's reserve, reliability, and mixed-target examples.

These are consistency checks of declared models, not evidence that an extreme
storage or computation architecture can be built.
"""
from pathlib import Path
import json
import math

ROOT = Path(__file__).resolve().parents[1]
access = json.loads((ROOT / "research/cosmology/access_results.json").read_text())
synthesis = json.loads((ROOT / "analysis/synthesis_results.json").read_text())
c, G, hbar, kb = 299792458.0, 6.67430e-11, 1.054571817e-34, 1.380649e-23
year = 365.25 * 86400
eV = 1.602176634e-19
H = access["constants"]["H_Lambda_per_s"]
M = synthesis["collected_baryonic_reserve"]["mass_kg"]
R = synthesis["collected_baryonic_reserve"]["radius_example_m"]

checks = []

def check(name, condition):
    assert condition, name
    checks.append(name)


anchor = []
for u in (.5, .1, .01):
    retained = 4 / 3**.75 * (u*(1-u**3))**.75
    # Independently reconstruct the orbit's conserved angular momentum at
    # initial mass/radius and at the limiting marginally stable orbit.
    initial_rta = (G*M/H**2)**(1/3)
    initial_r = u*initial_rta
    final_mass = retained*M
    final_r = (G*final_mass/(4*H**2))**(1/3)
    j2_initial = G*M*initial_r - H**2*initial_r**4
    j2_final = G*final_mass*final_r - H**2*final_r**4
    check(f"anchor angular momentum at u={u}",
          math.isclose(j2_initial, j2_final, rel_tol=1e-13))
    anchor.append({"initial_radius_over_turnaround": u,
                   "mass_fraction_at_instability": retained,
                   "mass_fraction_spent": 1-retained})

black_hole = {
    "mass_kg": M,
    "schwarzschild_radius_m": 2*G*M/c**2,
    "temperature_K": hbar*c**3/(8*math.pi*G*M*kb),
    "textbook_blackbody_lifetime_years": 5120*math.pi*G**2*M**3/(hbar*c**4)/year,
    "scope": "Neutral Schwarzschild blackbody estimate; excludes greybody/species, accretion, recycling, and cosmological corrections.",
}
check("black-hole temperature above reference de Sitter bath",
      black_hole["temperature_K"] > access["constants"]["deSitter_temperature_K"])

duration_years = synthesis["thermal_channel_model"]["times_years_C1"]["0.5"]
cells, attempt_rate, failure = 1e30, 1e12, .01
barrier = math.log(cells*attempt_rate*duration_years*year/failure)
thermal = {
    "cells": cells, "attempt_rate_per_second": attempt_rate,
    "duration_years": duration_years, "failure_allowance": failure,
    "barrier_over_kBT": barrier,
    "barrier_eV_at_300K": barrier*kb*300/eV,
    "scope": "Stationary thermal activation only; does not model switching, tunneling, decay, control, or nonthermal faults.",
}
check("thermal escape union bound matches failure allowance",
      math.isclose(cells*attempt_rate*duration_years*year*math.exp(-barrier),
                   failure, rel_tol=1e-13))

P = access["constants"]["deSitter_horizon_entropy_bits"]
epsilon = .1
specification = []
for output_type, radius in (("pure outputs", epsilon),
                            ("mixed outputs, triangle-inequality bound", 2*epsilon)):
    coefficient = 2*math.log2(1/radius)
    ceiling = math.log2(1+P/coefficient)
    n = math.floor(ceiling)
    check(f"specification integer cutoff: {output_type}",
          coefficient*(2**n-1) <= P < coefficient*(2**(n+1)-1))
    specification.append({"output_type": output_type,
                          "trace_distance_epsilon": epsilon,
                          "cap_radius_used": radius,
                          "continuous_qubit_ceiling": ceiling,
                          "necessary_integer_qubit_ceiling": n})

checkpoint_rounding = []
for D, L in ((1_000_000, 100_000), (1_000_003, 100_000), (3, 100_000)):
    q, alpha, mu, tau0, tc, bc, sigma = 1e6, 1, 1e-18, 1, 1e6, 1e6, 0
    blocks = (D+L-1)//L
    provisioned = 2*q + alpha*min(L, D)
    duration = 2*D*tau0 + blocks*tc
    entropy = 2*D*sigma + blocks*bc + mu*provisioned*duration
    check(f"partial-block checkpoint count D={D}, L={L}",
          (blocks-1)*L < D <= blocks*L)
    if D % L == 0:
        per_step = 2*sigma + bc/L + mu*(2*q+alpha*L)*(2*tau0+tc/L)
        check("divisible checkpoint case matches h(L)",
              math.isclose(entropy, D*per_step, rel_tol=1e-14))
    checkpoint_rounding.append({"simulated_steps": D, "block_length": L,
                                "checkpoint_count": blocks,
                                "provisioned_memory_bits": provisioned,
                                "duration_in_tau0_units": duration,
                                "entropy_bits": entropy})

out = {
    "scope": "Arithmetic and conditional-model consistency, not physical attainability.",
    "anchor_depletion": anchor,
    "reserve_global_communication": {
        "radius_Gly": R/(c*year*1e9),
        "radius_crossing_time_years": R/c/year,
        "radius_spanning_layers_per_asymptotic_expansion_time": c/(H*R),
        "scope": "Radius-spanning dependence with a common approximately static clock; local core gates need not span the reserve.",
    },
    "black_hole_storage_example": black_hole,
    "thermal_memory_barrier_example": thermal,
    "specification_examples": specification,
    "checkpoint_rounding_examples": checkpoint_rounding,
    "validation": {"passed_checks": len(checks), "checks": checks},
}
(ROOT / "analysis/additional_checks_results.json").write_text(
    json.dumps(out, indent=2) + "\n")
print(json.dumps(out, indent=2))

"""Finite checks for the transfer proof. These are not a proof of its limits.

Exact rational checks cover Fourier coefficients and multiplier bounds.
Floating checks exercise the deterministic stability inequalities on
independently perturbed networks. No posterior sampling is performed here.
"""
import itertools
import json
import math
from fractions import Fraction
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]


def fwht(values):
    out = np.array(values, dtype=np.float64, copy=True)
    n = len(out)
    h = 1
    while h < n:
        view = out.reshape(-1, 2 * h)
        a = view[:, :h].copy()
        b = view[:, h:].copy()
        view[:, :h] = a + b
        view[:, h:] = a - b
        h *= 2
    return out


def coefficient(r, j):
    """sqrt(r) times the critical Fourier coefficient, exactly."""
    if j == 0:
        return Fraction(r * math.comb(r, r // 2), 2 ** (r + 1))
    return (
        Fraction(math.comb(r - 2, (r - 2) // 2), 2 ** (r - 1))
        * (-1) ** ((j - 2) // 2)
        * Fraction(math.comb((r - 2) // 2, (j - 2) // 2),
                   math.comb(r - 2, j - 2))
    )


def direct_coefficient(r, j):
    result = 0
    for p in range(j + 1):
        for q in range(r - j + 1):
            result += (
                math.comb(j, p) * math.comb(r - j, q)
                * (-1) ** (j - p) * max(2 * (p + q) - r, 0)
            )
    return Fraction(result, 2 ** r)


exact_coefficients = 0
exact_ratios = 0
for r in range(6, 102, 2):
    b = [coefficient(r, j) for j in range(0, r + 1, 2)]
    for j in range(0, r + 1, 2):
        assert coefficient(r, j) == direct_coefficient(r, j), (r, j)
        exact_coefficients += 1
    for k in range(r // 2):
        for l in range(len(b)):
            for q in range(max(0, l - k), min(len(b), l + k + 1)):
                assert abs(b[l] / b[q]) <= (r - 1) ** k
                exact_ratios += 1

rng = np.random.default_rng(20261118)
rows = []
for r in (6, 8, 10):
    size = 1 << r
    ids = np.arange(size, dtype=np.uint64)
    x = 2 * ((ids[:, None] >> np.arange(r, dtype=np.uint64)) & 1) - 1
    x = x.astype(np.int8).astype(np.float64)
    xb = np.column_stack([np.ones(size), x])
    parity = np.prod(x, axis=1)
    rho = abs(float(coefficient(r, r))) / math.sqrt(r)
    br = float(coefficient(r, r)) / math.sqrt(r)
    s = 0.5
    e_star = s / rho
    base_u = math.sqrt(e_star) * np.column_stack([np.zeros(size), x / math.sqrt(r)])
    base_a = math.sqrt(e_star) * np.sign(br) * parity
    for noise in (0.0, 0.001, 0.01, 0.05):
        for replicate in range(3):
            u = base_u + noise * rng.normal(size=base_u.shape)
            a = base_a + noise * rng.normal(size=base_a.shape)
            # A common positive dilation keeps energy above E_* if necessary.
            energy = (np.dot(a, a) + np.sum(u * u)) / (2 * size)
            factor = math.sqrt(max(1.0, e_star / energy))
            a *= factor
            u *= factor
            energy = (np.dot(a, a) + np.sum(u * u)) / (2 * size)
            eps = max(0.0, energy / e_star - 1)
            assert eps <= 1
            features = np.maximum(xb @ u.T, 0)
            output = features @ a / size
            hinge = np.maximum(s - parity * output, 0).mean()
            norms = np.linalg.norm(u, axis=1)
            z = np.where(u[:, 1:] >= 0, 1.0, -1.0)
            critical_u = np.column_stack([np.zeros(size), z / math.sqrt(r)])
            critical_h = np.maximum(xb @ critical_u.T, 0) * norms
            critical_output = critical_h @ a / size
            d0 = eps * s + hinge
            v0 = math.sqrt(max(0, 2 * energy * d0 / rho))
            u0 = math.sqrt(max(0, (s + energy * math.sqrt(r + 1))
                                  * (eps * s + 2 * hinge)))
            actual_projection_error = np.sqrt(np.mean((output - critical_output) ** 2))
            actual_source_error = np.sqrt(np.mean((output - s * parity) ** 2))
            assert actual_projection_error <= v0 + 1e-10
            assert actual_source_error <= u0 + 1e-10
            even_features = (features + features[::-1]) / 2
            for k in (0, 1, 2):
                if 2 * k > r - 2:
                    continue
                for aset in list(itertools.combinations(range(r), 2 * k))[:3]:
                    j = r - 2 * k
                    bj = float(coefficient(r, j)) / math.sqrt(r)
                    modulation = np.prod(z[:, aset], axis=1) if aset else np.ones(size)
                    target = parity * (np.prod(x[:, aset], axis=1) if aset else 1)
                    coef = br * a * modulation / (s * bj)
                    q = even_features @ coef / size
                    delta = rho / (s * abs(bj)) * (
                        (1 + (r - 1) ** k) * v0 + (r - 1) ** k * u0
                    )
                    actual_error = np.sqrt(np.mean((q - target) ** 2))
                    norm_bound = 2 * energy * (rho / (s * bj)) ** 2
                    assert np.mean(coef * coef) <= norm_bound + 1e-9
                    assert actual_error <= delta + 1e-9
                    assert np.max(np.mean(even_features ** 2, axis=1)) <= 2 * energy * (r + 1) + 1e-9
                    # Verify the exact Fourier reweighting identity numerically
                    # for the projected critical network, not the perturbed one.
                    fc = critical_output
                    fca = critical_h @ (a * modulation) / size
                    fc_even = (fc + fc[::-1]) / 2
                    fca_even = (fca + fca[::-1]) / 2
                    ch = fwht(fc_even) / size
                    cha = fwht(fca_even) / size
                    amask = sum(1 << i for i in aset)
                    for mask in range(size):
                        degree = mask.bit_count()
                        if degree % 2:
                            continue
                        other = mask ^ amask
                        ratio = float(coefficient(r, degree) / coefficient(r, other.bit_count()))
                        # Walsh convention is products of (-x), but even masks
                        # agree with the desired products of x.
                        assert abs(cha[mask] - ratio * ch[other]) < 2e-10
                    rows.append(dict(r=r, noise=noise, replicate=replicate,
                                     deleted=list(aset), energy_excess=eps,
                                     source_hinge=float(hinge),
                                     transfer_l2_error=float(actual_error),
                                     transfer_bound=float(delta)))

# The scalar constants in the Gaussian box and Chernoff steps.
for eps in np.geomspace(1e-12, 1, 200):
    t = 1 - eps / 8
    gap = t * (1 + eps) - (1 + eps / 2)
    assert gap + 1e-15 >= eps / 4
    box_increment = math.sqrt(2 * (1 + eps / 4)) * eps / 32 + eps * eps / 2048
    assert 1 + eps / 4 + box_increment <= 1 + eps / 2 + 1e-15

result = {
    "status": "PASS",
    "exact_fourier_coefficients": exact_coefficients,
    "exact_multiplier_ratios": exact_ratios,
    "numerical_network_cases": len(rows),
    "scope": "Exact rational identities plus floating stability checks; not independent proof verification.",
    "cases": rows,
}
(ROOT / "results/polynomial_transfer_checks.json").write_text(
    json.dumps(result, indent=2) + "\n"
)
print(json.dumps({k: v for k, v in result.items() if k != "cases"}), flush=True)

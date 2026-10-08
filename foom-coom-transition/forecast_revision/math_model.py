"""Exact toy-model stopping with shared research/consumption efficiency.

All inputs and outputs are raw FLOPs unless explicitly identified as effective
research F. Logarithmic evaluation avoids overflow at cosmic input scales.
Run with the existing empirical_methods/.venv/bin/python.
"""
from __future__ import annotations
import json
import math
from pathlib import Path
from scipy.optimize import brentq
from scipy.special import expi
import numpy as np

LN10 = math.log(10.0)


def log_expm1(t: float) -> float:
    if t == 0:
        return -math.inf
    if t < 0:
        raise ValueError("Expected nonnegative argument")
    if t < 40:
        return math.log(math.expm1(t))
    return t + math.log1p(-math.exp(-t))


def log_integral(logz: float, p: float) -> float:
    """log of integral from 1 to z of u**(-p) du."""
    if logz == 0:
        return -math.inf
    if p == 1:
        return math.log(logz)
    if p < 1:
        return log_expm1((1 - p) * logz) - math.log1p(-p)
    return math.log(-math.expm1(-(p - 1) * logz)) - math.log(p - 1)


class CeilingModel:
    """C(F)=f+sum_i w_i(1+F/F0)^(-p_i), a=1/C, dF/dx=a.

    Each p is positive. Weights supplied sum to one and are rescaled to 1-f.
    Initial a=1, and F0 is chosen so d log(a)/dx=k0 at F=x=0.
    """
    def __init__(self, p, log10_H, weights=None, log10_k0=-27.5,
                 log10_N=120):
        self.p = np.atleast_1d(np.asarray(p, float))
        if np.any(self.p <= 0) or log10_H <= 0:
            raise ValueError("p>0 and H>1 required")
        if weights is None:
            weights = np.ones(len(self.p))
        weights = np.asarray(weights, float)
        if len(weights) != len(self.p) or np.any(weights <= 0):
            raise ValueError("One positive weight per exponent required")
        weights = weights / weights.sum()
        self.logf = -log10_H * LN10
        self.log1mf = math.log(-math.expm1(self.logf))
        self.logw = np.log(weights) + self.log1mf
        self.logk0 = log10_k0 * LN10
        self.logN = log10_N * LN10
        self.logF0 = float(np.logaddexp.reduce(np.log(self.p) + self.logw)) - self.logk0
        self.log10_H = log10_H
        self.weights = weights

    def state(self, logz):
        logC = float(np.logaddexp.reduce(np.r_[self.logf, self.logw - self.p * logz]))
        terms = [self.logf + log_expm1(logz)]
        terms += [w + log_integral(logz, p) for w, p in zip(self.logw, self.p)]
        logx = self.logF0 + float(np.logaddexp.reduce(terms))
        logk = float(np.logaddexp.reduce(
            np.log(self.p) + self.logw - (self.p + 1) * logz
        )) - self.logF0 - 2 * logC
        return logx, logk, logC

    def _root(self, function):
        # For the economic equation our positive, decreasing, log-convex C
        # gives strictly increasing G=x+1/k. See MATH.md for the global proof.
        hi = 1.0
        while function(hi) < 0:
            hi *= 2
            if hi > 1e12:
                raise RuntimeError("Root too remote for configured numerical range")
        return brentq(function, 0, hi, xtol=1e-11, rtol=1e-14)

    def solve(self, scan=True):
        if self.logk0 + self.logN <= 0:
            raise ValueError("This solver assumes profitable research at x=0")
        def economic(logz):
            logx, logk, _ = self.state(logz)
            return float(np.logaddexp(logx, -logk)) - self.logN
        econz = self._root(economic)
        exacz = self._root(lambda z: -self.state(z)[1] - self.logN)
        logx, logk, logC = self.state(econz)
        thresholdx = self.state(exacz)[0]
        out = {
            "p": self.p.tolist(), "weights": self.weights.tolist(),
            "log10_H": self.log10_H,
            "log10_F0": self.logF0 / LN10,
            "log10_optimal_x": logx / LN10,
            "optimal_fraction_N": math.exp(logx - self.logN),
            "log10_remaining_raw_FLOPs": -logk / LN10,
            "log10_k_at_optimum": logk / LN10,
            "log10_exact_threshold_x": thresholdx / LN10,
            "log10_a_at_optimum": -logC / LN10,
            "log10_ceiling_fraction_attained": (-logC + self.logf) / LN10,
            "log10_z_at_optimum": econz / LN10,
            "economic_root_log_residual": economic(econz),
            "multiple_exponents": len(self.p) > 1,
        }
        # Optional numerical sanity check. Log convexity proves uniqueness for
        # all the current families, including mixtures; see MATH.md.
        if scan:
            scan_points = np.linspace(0, econz * 1.1, 2001)
            vals = [economic(z) for z in scan_points]
            out["stationary_crossings_on_scan"] = sum(
                (a < 0 <= b) or (a >= 0 > b) for a, b in zip(vals, vals[1:]))
            assert out["stationary_crossings_on_scan"] == 1
        assert abs(out["economic_root_log_residual"]) < 1e-8
        return out

    def state_at_log10_x(self, log10_x):
        """Invert cumulative raw spending and return logs of x, k, and C.

        Natural logs are returned, matching state(). No uniqueness issue:
        cumulative raw spending is strictly increasing for every positive C.
        """
        target = log10_x * LN10
        t = self._root(lambda t: self.state(t)[0] - target)
        return self.state(t)

    def asymptote_log10_x(self):
        if len(self.p) != 1:
            raise ValueError("Single exponent only")
        p = self.p[0]
        return (math.log(p) + self.log1mf +
                (self.logN - p * self.logk0 + (p - 1) * self.logf) / (p + 1)) / LN10


class ExponentialCeilingModel(CeilingModel):
    """C=f+(1-f)exp(-F/F0), F0=(1-f)/k0.

    state's independent coordinate is s=F/F0, unlike the power family's log z.
    Inherits only numerical root/inversion machinery; no power asymptote.
    """
    def __init__(self, log10_H, log10_k0=-27.5, log10_N=120):
        super().__init__(1, log10_H, log10_k0=log10_k0, log10_N=log10_N)
        self.logF0 = self.log1mf - self.logk0

    def state(self, s):
        if s == 0:
            return -math.inf, self.logk0, 0.0
        logC = float(np.logaddexp(self.logf, self.log1mf - s))
        logx = self.logF0 + float(np.logaddexp(
            self.logf + math.log(s),
            self.log1mf + math.log(-math.expm1(-s))))
        logk = self.logk0 - s - 2 * logC
        return logx, logk, logC

    def solve(self, scan=True):
        out = super().solve(scan=scan)
        out.pop("p")
        out.pop("weights")
        out.pop("multiple_exponents")
        out["model"] = "exponential_effective_cost_ceiling"
        out["F_over_F0_at_optimum"] = out.pop("log10_z_at_optimum") * LN10
        return out

    def asymptote_log10_x(self):
        raise ValueError("Use exponential model's exact solution")

    def state_at_log10_x(self, log10_x):
        target = log10_x * LN10
        logy = target - self.logF0
        if logy > self.log1mf:
            # In the constant-cost regime x/F0=f*s+(1-f), up to exp(-s).
            # Solve analytically; s itself can exceed the root search bound.
            logs = logy + math.log1p(-math.exp(self.log1mf - logy)) - self.logf
            if logs > math.log(40 - self.logf):
                s = math.exp(logs) if logs < 709 else math.inf
                return target, self.logk0 - s - 2 * self.logf, self.logf
        return super().state_at_log10_x(log10_x)


def log_continuum_integral(t):
    """log J(t), J=integral_0^t (exp(u)-1)/u du=Ei(t)-gamma-ln t."""
    if t == 0:
        return -math.inf
    if t < 1:
        # Positive, convergent series sum t**n/(n*n!), avoiding Ei cancellation.
        term = t
        total = term
        for n in range(2, 100):
            term *= t * (n - 1) / (n * n)
            total += term
            if term < total * 1e-16:
                break
        return math.log(total)
    if t <= 50:
        return math.log(float(expi(t)) - float(np.euler_gamma) - math.log(t))
    # Ei asymptotic: the 21st omitted term is <~6e-16 of the sum at t=50,
    # decreasing rapidly thereafter. The subtracted gamma+ln(t) is smaller.
    term = 1.0
    total = 1.0
    for n in range(1, 21):
        term *= n / t
        total += term
    return t - math.log(t) + math.log(total)


def continuum_gap_and_derivative(t):
    """Return log g and log(-dg/dt), g=(1-exp(-t))/t, continuous at zero."""
    if t == 0:
        return 0.0, -math.log(2)
    if t < 1e-3:
        g_minus_one = -t / 2 + t*t / 6 - t**3 / 24 + t**4 / 120 - t**5 / 720
        minus_derivative = 0.5 - t / 3 + t*t / 8 - t**3 / 30 + t**4 / 144 - t**5 / 840
        return math.log1p(g_minus_one), math.log(minus_derivative)
    logg = math.log(-math.expm1(-t)) - math.log(t)
    logminusderivative = math.log(-math.expm1(math.log1p(t) - t)) - 2 * math.log(t)
    return logg, logminusderivative


class ContinuumCeilingModel(CeilingModel):
    """C=f+(1-f)int_0^1 z**(-p)dp; equal current cost weights over p in [0,1]."""
    def __init__(self, log10_H, log10_k0=-27.5, log10_N=120):
        super().__init__(1, log10_H, log10_k0=log10_k0, log10_N=log10_N)
        self.logF0 = self.log1mf - math.log(2) - self.logk0

    def state(self, t):
        if t == 0:
            return -math.inf, self.logk0, 0.0
        logg, logmgprime = continuum_gap_and_derivative(t)
        logC = float(np.logaddexp(self.logf, self.log1mf + logg))
        logx = self.logF0 + float(np.logaddexp(
            self.logf + log_expm1(t),
            self.log1mf + log_continuum_integral(t)))
        logk = self.log1mf + logmgprime - self.logF0 - t - 2 * logC
        return logx, logk, logC

    def solve(self, scan=True):
        out = super().solve(scan=scan)
        out.pop("p")
        out.pop("weights")
        out.pop("multiple_exponents")
        out["model"] = "uniform_exponent_continuum_cost_ceiling"
        return out

    def asymptote_log10_x(self):
        raise ValueError("Use continuum model's exact solution")


def basic_checks():
    # Differentiation checks at modest scales where ordinary floating point
    # is accurate: dx/dF=C and k=-C'/C**2.
    for p in [0.2, 0.5, 1.0, 2.0, 4.0]:
        m = CeilingModel(p, 2, log10_k0=-2, log10_N=8)
        assert abs(m.state(0)[1] - m.logk0) < 1e-12
        for z in [1.1, 3, 20]:
            t = math.log(z)
            dt = 1e-5
            xm, _, cm = m.state(t - dt)
            xp, _, cp = m.state(t + dt)
            x, k, c = m.state(t)
            dxdt = (math.exp(xp) - math.exp(xm)) / (2 * dt)
            assert math.isclose(dxdt, math.exp(m.logF0 + t + c), rel_tol=1e-8)
            approxk = -(cp - cm) / (math.exp(xp) - math.exp(xm))
            assert math.isclose(approxk, math.exp(k), rel_tol=1e-8)
        m.solve()
    for cls in [ExponentialCeilingModel, ContinuumCeilingModel]:
        m = cls(2, log10_k0=-2, log10_N=8)
        assert abs(m.state(0)[1] - m.logk0) < 1e-12
        for t in [0.01, 0.2, 1, 5, 20]:
            # At s=20 the exponential model's log C changes by <1e-11 across
            # tiny steps; a wider interval avoids subtractive roundoff.
            dt = 1e-2 if cls is ExponentialCeilingModel and t == 20 else 1e-5
            xm, _, cm = m.state(t - dt)
            xp, _, cp = m.state(t + dt)
            x, k, c = m.state(t)
            dxdt = (math.exp(xp) - math.exp(xm)) / (2 * dt)
            coord_jacobian = t if cls is ContinuumCeilingModel else 0.0
            assert math.isclose(dxdt, math.exp(m.logF0 + coord_jacobian + c), rel_tol=1e-8)
            approxk = -(cp - cm) / (math.exp(xp) - math.exp(xm))
            tolerance = 2e-5 if dt == 1e-2 else 1e-6
            assert math.isclose(approxk, math.exp(k), rel_tol=tolerance)
        m.solve()
        for lx in [1, 3, 6, 8]:
            assert math.isclose(m.state_at_log10_x(lx)[0] / LN10, lx, abs_tol=1e-9)
        cosmic = cls(120)
        assert math.isclose(cosmic.state_at_log10_x(119)[0] / LN10, 119, abs_tol=1e-9)
    # Independently integrate positive expressions and compare the Ei/series
    # formula, including the switch to the overflow-safe large-t asymptote.
    from scipy.integrate import quad
    for t in [0.01, 0.9, 1.1, 10, 49.9, 50.1, 100, 300]:
        scaled_integral = quad(lambda u: (math.exp(u-t)-math.exp(-t))/u if u else math.exp(-t),
                               0, t, epsabs=1e-13, epsrel=1e-12)[0]
        reference_log = t + math.log(scaled_integral)
        assert abs(reference_log - log_continuum_integral(t)) < 1e-11


def main():
    basic_checks()
    table = []
    for p in [0.1, 0.25, 0.5, 1, 2, 3]:
        for h in [3, 6, 12, 30, 60, 120]:
            m = CeilingModel(p, h)
            r = m.solve()
            r["deep_ceiling_asymptote_log10_x"] = m.asymptote_log10_x()
            table.append(r)
    mixtures = []
    for slow_weight in [1e-3, 1e-10, 1e-20, 1e-40, 1e-60]:
        m = CeilingModel([1, 0.1], 12, [1 - slow_weight, slow_weight])
        mixtures.append(m.solve())
    result = {"normalization": {"N": "1e120", "k0": "1e-27.5"},
              "single_exponent_grid": table, "slow_tail_mixtures": mixtures}
    result["exponential_effective_cost_ceiling"] = [
        ExponentialCeilingModel(h).solve() for h in [3, 6, 12, 30]]
    result["uniform_exponent_continuum_cost_ceiling"] = [
        ContinuumCeilingModel(h).solve() for h in [3, 6, 12, 30]]
    target = Path(__file__).with_name("math_results.json")
    target.write_text(json.dumps(result, indent=2) + "\n")
    print("All derivative and root checks passed.")
    print("log10 optimal raw FLOPs; columns log10 H = 3,6,12,30,60,120")
    for p in [0.1, 0.25, 0.5, 1, 2, 3]:
        rows = [r for r in table if r["p"] == [p]]
        print(p, [round(r["log10_optimal_x"], 3) for r in rows])
    print("Mixtures p=1 and p=.1, H=1e12")
    for r in mixtures:
        print(r["weights"], round(r["log10_optimal_x"], 3))
    for key in ["exponential_effective_cost_ceiling", "uniform_exponent_continuum_cost_ceiling"]:
        print(key, [(r["log10_H"], r["log10_optimal_x"], r["log10_a_at_optimum"])
                    for r in result[key]])


if __name__ == "__main__":
    main()

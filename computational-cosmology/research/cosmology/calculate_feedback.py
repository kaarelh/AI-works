"""Feedback envelopes for fixed, unbound comoving workers.

Calculates an exact de Sitter formula and numerically propagates null messages
and fixed proper-time waits in the report's radiation+matter+Lambda background.
Distances: Gly (present proper = comoving); times: Gyr. c=1 in these units.
Boundary answers arrive only at infinite cosmic time, so radii are suprema.
"""
from pathlib import Path
import json
import math
from scipy.integrate import quad
from scipy.optimize import brentq

HERE = Path(__file__).resolve().parent
base = json.loads((HERE / "access_results.json").read_text())
a, const = base["assumptions"], base["constants"]
OR, OM, OL = a["Omega_r"], a["Omega_m"], a["Omega_Lambda"]
H0 = 1 / const["Hubble_time_Gyr"]
HL = 1 / const["asymptotic_Hubble_time_Gyr"]
L = const["present_event_horizon_Gly"]
LD = 1 / HL


def E(y):
    return math.sqrt(OR * y**4 + OM * y**3 + OL)


def x_of_y(y):
    return quad(lambda u: 1 / E(u), 0, y, epsabs=1e-12)[0] / H0


def y_of_x(x):
    if x >= L*(1-1e-14):
        return 1.0
    return brentq(lambda y: x_of_y(y) - x, 0, 1, xtol=5e-324, rtol=1e-14)


def wait(x, tau):
    """Remaining conformal light distance after proper time tau at rest."""
    if x <= 0 or tau == 0:
        return x
    y0 = y_of_x(x)
    lo, hi = HL * tau, H0 * E(y0) * tau
    f = lambda w: quad(lambda v: 1 / E(y0 * math.exp(-v)),
                       0, w, epsabs=1e-12)[0] / H0 - tau
    if hi-lo < 1e-13:
        w = lo
    else:
        w = brentq(f, lo*(1-1e-10), hi*(1+1e-10), xtol=1e-13)
    return x_of_y(y0 * math.exp(-w))


def remaining_after(k, tau, beta, r):
    x = L - r / beta
    for j in range(k):
        if x <= 0:
            return x - r
        x = wait(x, tau) - r
        if j < k - 1:
            x -= r
    return x


def r_exact(k, tau, beta=1):
    if tau == 0:
        return L / (1/beta + 2*k - 1)
    scale = r_desitter(k, tau, beta)
    return scale * brentq(lambda z: remaining_after(k, tau, beta, scale*z),
                         0, 1.01, xtol=1e-12)


def r_desitter(k, tau, beta=1):
    if tau == 0:
        return LD / (1/beta + 2*k - 1)
    return LD / (1/beta - 1 + math.expm1(k*HL*tau)/math.tanh(HL*tau/2))


def explicit_desitter_remaining(k, tau, beta, r):
    x = LD-r/beta
    q = math.exp(-HL*tau)
    for j in range(k):
        x = q*x-r
        if j < k-1:
            x -= r
    return x


def max_cycles(r, tau, beta):
    x = L-r/beta
    k = 0
    while x > 0:
        x = wait(x, tau)-r
        if x <= 0:
            break
        k += 1
        x -= r
    return k


def max_one_shot_processing(r, beta):
    arrival = L-r/beta
    if arrival <= r:
        return 0.0
    y0, y1 = y_of_x(arrival), y_of_x(r)
    return quad(lambda v: 1/E(y0*math.exp(-v)),
                0, math.log(y0/y1), epsabs=1e-11)[0]/H0


# Nontrivial checks: formula against every step of the null/wait recurrence;
# zero-delay LCDM against the exact geometry; finite-wait monotonicity.
for beta in [.1, 1.0]:
    for k in [1, 2, 10, 100]:
        for tau in [.001, 1, 10]:
            r = r_desitter(k, tau, beta)
            assert abs(explicit_desitter_remaining(k, tau, beta, r)) < 1e-12
        assert abs(r_exact(k, 0, beta) - L/(1/beta+2*k-1)) < 1e-10

# Independently check the unequal-processing-time prefix-sum formula.
for beta in [.1, 1.0]:
    for taus in [[1,2,3], [0,0,6], [6,0,0], [.1,1,10,0]]:
        total = sum(taus)
        prefixes = [sum(taus[:j]) for j in range(1,len(taus))]
        radius = LD / (1/beta + math.exp(HL*total)
                       + 2*sum(math.exp(HL*t) for t in prefixes))
        x = LD-radius/beta
        for j,tau in enumerate(taus):
            x = math.exp(-HL*tau)*x-radius
            if j < len(taus)-1:
                x -= radius
        assert abs(x) < 1e-12

rows = []
for beta in [1.0, .1]:
    for k in [1, 10, 100]:
        previous = math.inf
        for tau in [0, .001, 1, 10]:
            exact = r_exact(k, tau, beta)
            assert exact <= previous + 1e-10
            previous = exact
            rows.append(dict(beta=beta, adaptive_answers=k,
                             worker_proper_time_per_answer_Gyr=tau,
                             radius_LCDM_Gly=exact,
                             radius_pure_deSitter_Gly=r_desitter(k,tau,beta),
                             LCDM_volume_relative_to_one_way=(exact/(beta*L))**3))

counts = [dict(distance_Gly=r, beta=beta, processing_Gyr=tau,
               max_complete_answers=max_cycles(r,tau,beta))
          for r in [.01, .1, 1] for beta in [1.0,.1] for tau in [0, 1]]
windows = [dict(distance_Gly=r,beta=beta,
                max_worker_processing_Gyr=max_one_shot_processing(r,beta))
           for r in [.01,.1,1] for beta in [1.0,.1]]
out = dict(reference_L_Gly=L, exact_deSitter_L_Gly=LD,
           pure_deSitter_H_per_Gyr=HL, rows=rows, cycle_counts=counts,
           one_shot_processing_windows=windows,
           notes="Pointlike instantaneous messages; no home processing; first query carried by deployment front, speed beta; fixed comoving worker. Bounds are suprema, not finite-time attainments.")
(HERE / "feedback_results.json").write_text(json.dumps(out,indent=2)+"\n")
print(json.dumps(out,indent=2))

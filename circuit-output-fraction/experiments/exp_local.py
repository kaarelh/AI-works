"""E-local: the tilted-Glauber estimator TG on local threshold circuits with
overlapping scopes (paper: Section "Local threshold circuits").

(A) chain LTC: g_j(z_{j-1}, z_j, y_j) random 3-input tables (private y_j pivotal
    w.p. >= 1/2), m = 1600 factors, p ~ 1e-20, exact p by transfer matrix.
(B) random 3-regular overlap LTC: one random 3-input table per edge of a random
    cubic graph plus a private input, N = 1500 vertices (expander factor graph),
    p far below Monte Carlo reach; and a small instance (N = 100, p ~ 1e-3)
    cross-checked against 10^7 Monte Carlo samples.
(C) coverage: repeated runs on a chain with exact p (threshold inside the
    certified regime).
(D) monotone CFTP (prop:local-cftp): supermodular chain of monomials
    z_{j-1} z_j y_j, tilts beyond the Dobrushin regime, exact p.
Every run with a known tilt also records diagnostics (key "diag"): the largest
row sum of the influence bound kappa and of the exact Dobrushin influences
c_il at the run's theta, and the variance reduction Var(S)/Var(S_RB) of the
Rao-Blackwellised statistic at theta * (1/4, 1/2, 3/4, 1) (2000 samples each).
Runs the tasks on two worker processes; writes results/local.json and
results/local_log.txt. Usage: python3 exp_local.py [A B Bs C D] (default: all;
a subset replaces only its own rows in local.json)."""

import json
import math
import os
import sys
import time
from concurrent.futures import ProcessPoolExecutor

os.environ.setdefault("OMP_NUM_THREADS", "1")
os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")

import numpy as np  # noqa: E402

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "code"))

from rareprob.localthr import (LocalModel, _pilot, chain_distribution, chain_ltc, regular_ltc,  # noqa: E402
                               tg_estimate)
from rareprob.stats import kl_interval, mc_samples_needed  # noqa: E402

OUT = os.path.join(os.path.dirname(__file__), "results")
LOG = os.path.join(OUT, "local_log.txt")
LN10 = math.log(10)
EPS, DELTA, GAMMA = 0.3, 0.05, 0.25


def log(msg):
    with open(LOG, "a") as f:
        f.write(msg + "\n")
    print(msg, flush=True)


def diagnostics(M, theta, rng, sampler="glauber", per_point=2000):
    """Row sums of kappa and of the exact influences at theta, and the
    Rao-Blackwell variance factors Var(S) / Var(S_RB) on a grid in (0, theta]."""
    out = dict(theta=theta, kappa_row_sum=float(M.influence_bound(theta).sum(axis=1).max()),
               exact_row_sum=float(M.influence_exact(theta).sum(axis=1).max()), rb_factor={})
    for f in (0.25, 0.5, 0.75, 1.0):
        th = f * theta
        if sampler == "glauber":
            s = M.certificate(th, GAMMA).sweeps(1e-3, M.n)
            X = None if s is None else M.glauber(np.full(per_point, th), s, rng)
        else:
            X, _ = M.cftp(np.full(per_point, th), rng)
        if X is None:
            continue
        S = M.S_states(X).astype(float)
        Srb = M.S_rb_states(X, th)
        out["rb_factor"][f"{th:.4f}"] = float(S.var() / Srb.var())
    return out


def summary(e, secs):
    upd = e.site_updates + e.info.get("pilot_site_updates", 0.0)
    return dict(eps=EPS, delta=DELTA, ns_per_site_update=1e9 * secs / max(upd, 1.0),
                log10_lo=e.log10_lo, log10_hi=e.log10_hi, log10_value=e.log_value / LN10, ratio=e.ratio,
                theta=e.theta, L=e.samples_ti, is_samples=e.samples_is, pilot_samples=e.info.get("pilot_samples", 0),
                sweeps=e.sweeps, site_updates=e.site_updates, seconds=secs, alpha=e.info.get("alpha"),
                F=e.info.get("F"), theta_max=e.info.get("theta_max"), logZ_halfwidth=e.info["ti"].get("u"),
                logZ_window_term=e.info["ti"].get("e_out"), logZ_gap=e.info["ti"].get("gap"),
                V=e.info.get("V"), cftp_sweeps=e.info.get("cftp_sweeps"), note=e.note)


def tilted_stats(dist, theta, t):
    s = np.arange(len(dist))
    lw = np.log(np.maximum(dist, 1e-320)) + theta * s
    lw -= lw.max()
    pt = np.exp(lw)
    pt /= pt.sum()
    mu = float((pt * s).sum())
    V = float((pt[t:] * np.exp(-theta * (s[t:] - t))).sum()) if t is not None else None
    return mu, V


def task_chain():
    rng = np.random.default_rng(2026)
    m = 1600
    ltc = chain_ltc(m, 0, rng, "random")
    q = np.full(ltc.n, 0.5)
    dist = chain_distribution(ltc, q)
    tail = np.cumsum(dist[::-1])[::-1]
    t = int(np.argmax(tail <= 1e-20))  # smallest t with p <= 1e-20
    ltc.t = t
    logp = math.log(tail[t])
    log(f"[A] chain m={m} n={ltc.n} k={ltc.k} d={ltc.d} t={t} mu0={ltc.mean_S(q):.1f} exact log10 p={logp / LN10:.4f}")
    t0 = time.time()
    e = tg_estimate(ltc, q, eps=EPS, delta=DELTA, gamma=GAMMA, L=40_000, max_is=30_000, rng=rng)
    secs = time.time() - t0
    mu, V = tilted_stats(dist, e.theta, t)
    r = dict(task="chain", m=m, n=ltc.n, k=ltc.k, d=ltc.d, t=t, mu0=ltc.mean_S(q), log10_p=logp / LN10,
             contains=e.contains_log(logp), point_rel_error=math.exp(e.log_value - logp) - 1,
             exact_mu_theta=mu, exact_V=V, mc_samples_same_ratio=mc_samples_needed(math.exp(logp), e.ratio - 1, DELTA),
             mc_samples_eps=mc_samples_needed(math.exp(logp), EPS, DELTA), **summary(e, secs))
    r["diag"] = diagnostics(LocalModel(ltc, q), e.theta, rng)
    log(f"[A] {json.dumps(r)}")
    return r


def task_regular():
    rng = np.random.default_rng(7)
    N = 1500
    ltc = regular_ltc(N, 0, rng, "random")
    q = np.full(ltc.n, 0.5)
    M = LocalModel(ltc, q)
    thm = M.theta_max(GAMMA)
    pl = _pilot(M, 10 ** 9, thm, "glauber", GAMMA, 6, 256, np.random.default_rng(8))
    t = int(math.ceil(pl["mus"][-1]))  # threshold at the mean of the most tilted certified measure
    ltc.t = t
    log(f"[B] 3-regular N={N} n={ltc.n} m={ltc.m} k={ltc.k} d={ltc.d} t={t} mu0={M.mu0:.1f} theta_max={thm:.4f}")
    t0 = time.time()
    e = tg_estimate(ltc, q, eps=EPS, delta=DELTA, gamma=GAMMA, L=40_000, max_is=30_000, rng=rng)
    secs = time.time() - t0
    r = dict(task="regular", N=N, m=ltc.m, n=ltc.n, k=ltc.k, d=ltc.d, t=t, mu0=M.mu0,
             mc_samples_same_ratio=mc_samples_needed(e.hi, e.ratio - 1, DELTA),
             mc_samples_eps=mc_samples_needed(e.hi, EPS, DELTA), **summary(e, secs))
    r["diag"] = diagnostics(M, e.theta, rng)
    log(f"[B] {json.dumps(r)}")
    return r


def task_regular_small():
    """Small 3-regular instance against 10^7 Monte Carlo samples."""
    rng = np.random.default_rng(11)
    N = 100
    ltc = regular_ltc(N, 0, rng, "random")
    q = np.full(ltc.n, 0.5)
    M = LocalModel(ltc, q)
    S = np.concatenate([M.S_states((rng.random((ltc.n, 50_000)) < 0.5).astype(np.uint8)) for _ in range(40)])
    t = int(np.max(np.nonzero(np.array([np.mean(S >= v) for v in range(int(S.max()) + 1)]) >= 1e-3)[0]))
    ltc.t = t
    hits, Nmc = 0, 10_000_000
    t0 = time.time()
    for _ in range(Nmc // 50_000):
        hits += int((M.S_states((rng.random((ltc.n, 50_000)) < 0.5).astype(np.uint8)) >= t).sum())
    mc_secs = time.time() - t0
    mlo, mhi = kl_interval(hits / Nmc, Nmc, DELTA)
    t0 = time.time()
    e = tg_estimate(ltc, q, eps=EPS, delta=DELTA, gamma=GAMMA, L=20_000, max_is=50_000, rng=rng)
    secs = time.time() - t0
    r = dict(task="regular_small", N=N, m=ltc.m, n=ltc.n, t=t, mc_samples=Nmc, mc_hits=hits, mc_lo=mlo, mc_hi=mhi,
             mc_seconds=mc_secs, overlap=bool(e.lo <= mhi and mlo <= e.hi),
             mc_samples_same_ratio=mc_samples_needed(hits / Nmc, e.ratio - 1, DELTA), **summary(e, secs))
    r["diag"] = diagnostics(M, e.theta, rng)
    log(f"[B-small] {json.dumps(r)}")
    return r


def task_coverage():
    """Repeated runs on a chain with exact p, threshold at the mean of the most
    tilted certified measure (inside the regime of thm:local(ii))."""
    rng = np.random.default_rng(12)
    m = 270
    ltc = chain_ltc(m, 0, rng, "random")
    q = rng.uniform(0.3, 0.7, ltc.n)
    dist = chain_distribution(ltc, q)
    tail = np.cumsum(dist[::-1])[::-1]
    thm = LocalModel(ltc, q).theta_max(GAMMA)
    t = int(math.ceil(tilted_stats(dist, thm, None)[0]))
    ltc.t = t
    logp = math.log(tail[t])
    log(f"[C] chain m={m} n={ltc.n} t={t} theta_max={thm:.4f} exact log10 p={logp / LN10:.4f}")
    R, miss, ratios, errs, t0 = 16, 0, [], [], time.time()
    for _ in range(R):
        e = tg_estimate(ltc, q, eps=EPS, delta=0.1, gamma=GAMMA, L=4000, max_is=8000, rng=rng, pilot_chains=128)
        miss += not e.contains_log(logp)
        ratios.append(e.ratio)
        errs.append(math.exp(e.log_value - logp) - 1)
    r = dict(task="coverage", m=m, n=ltc.n, t=t, log10_p=logp / LN10, runs=R, delta=0.1, misses=miss,
             ratio_median=float(np.median(ratios)), ratio_max=float(np.max(ratios)),
             point_rel_error_median_abs=float(np.median(np.abs(errs))), seconds=time.time() - t0)
    log(f"[C] {json.dumps(r)}")
    return r


def task_cftp():
    out = []
    rng = np.random.default_rng(13)
    m = 400
    ltc = chain_ltc(m, 0, rng, "monomial")
    q = np.full(ltc.n, 0.5)
    M = LocalModel(ltc, q)
    dist = chain_distribution(ltc, q)
    tail = np.cumsum(dist[::-1])[::-1]
    for theta in (1.5, 2.5):
        mu, _ = tilted_stats(dist, theta, None)
        t = int(math.ceil(mu))
        ltc.t = t
        logp = math.log(tail[t])
        t0 = time.time()
        e = tg_estimate(ltc, q, eps=EPS, delta=DELTA, sampler="cftp", theta=theta, L=60_000, max_is=20_000,
                        rng=rng, pilot_chains=128)
        secs = time.time() - t0
        r = dict(task="cftp", m=m, n=ltc.n, theta_requested=theta, t=t, log10_p=logp / LN10,
                 contains=e.contains_log(logp), point_rel_error=math.exp(e.log_value - logp) - 1,
                 sweeps_per_sample=(e.info["cftp_sweeps"] / max(e.samples_ti + e.samples_is, 1)), **summary(e, secs))
        r["diag"] = diagnostics(M, theta, rng, sampler="cftp")
        log(f"[D] {json.dumps(r)}")
        out.append(r)
    return out


TASKS = {"B": task_regular, "A": task_chain, "D": task_cftp, "Bs": task_regular_small, "C": task_coverage}


def main(selected):
    """Run the selected tasks (default: all) on two worker processes; rows of
    re-run tasks replace the old rows in results/local.json."""
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, "local.json")
    full = selected == list(TASKS)
    if full:
        open(LOG, "w").close()
    t0 = time.time()
    with ProcessPoolExecutor(max_workers=2) as ex:
        futs = [ex.submit(TASKS[k]) for k in selected]
        res = [f.result() for f in futs]
    rows = []
    for r in res:
        rows.extend(r if isinstance(r, list) else [r])
    if not full and os.path.exists(path):
        done = {r["task"] for r in rows}
        rows = [r for r in json.load(open(path)) if r["task"] not in done] + rows
    log(f"tasks {selected}: wall time {time.time() - t0:.0f}s")
    json.dump(rows, open(path, "w"), indent=1)


if __name__ == "__main__":
    main(sys.argv[1:] or list(TASKS))

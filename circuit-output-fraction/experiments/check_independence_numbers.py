"""Every number quoted in the paper's section on the certified presumption of
independence (paper/p1-indep.tex), recomputed. Writes
results/independence_numbers.json.

1. Triangle-freeness of G(N, q) at N = 10^4 (events B_i = "triangle i is
   present", supports = its three edge variables, q chosen so that
   mu = sum_i b_i = C(N,3) q^3 is 10 or 100): Delta over unordered dependent
   pairs, the first-order window exponent, log M, log M_2, and E_3 of the
   second-order theorem (appendix), the latter bounded for every order of the
   events. The closed-form counts are checked by brute force on small N for
   several random orders.
2. The local-lemma and Kotecky-Preiss quantities quoted for that instance.
3. The constant 0.29 of the pairwise barrier.
4. The 300-module chain for interface dynamic programming: exact log p, the
   independence estimate, and Monte Carlo factor tables with point estimates
   and certified (interval-arithmetic) intervals.
5. The numerical constants of the first-order estimation procedure, and a
   simulation of its main stage on a stress instance.
"""

import itertools
import json
import math
import os
import sys
from math import comb

import numpy as np
from scipy.optimize import minimize_scalar
from scipy.stats import binom

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "code"))

from rareprob.stats import kl_interval  # noqa: E402

OUT = os.path.join(os.path.dirname(__file__), "results")


# ---------------------------------------------------------------- 1. triangles
def triangle_closed_form(N, mu):
    """Closed forms for triangle-freeness of G(N, q) with C(N,3) q^3 = mu."""
    T = comb(N, 3)
    q = (mu / T) ** (1 / 3)
    b = q ** 3
    d = 3 * (N - 3)                      # max degree of the dependency graph
    pairs = comb(N, 2) * comb(N - 2, 2)  # unordered pairs sharing an edge
    Delta = pairs * q ** 5
    logM = T * math.log1p(-b)
    sumC = pairs * (q ** 5 - q ** 6)     # sum_i C_i, for every order
    # log M_2 = sum_i log(1 - b + C_i); every C_i <= d (q^5 - q^6)
    Cmax = d * (q ** 5 - q ** 6)
    logM2_hi = logM + sumC / (1 - b)
    logM2_lo = logM2_hi - Cmax * sumC / (2 * (1 - b) ** 2)
    # connected triples of triangles (dependency = sharing an edge)
    t_same = comb(N, 2) * comb(N - 2, 3)   # three on a common edge: 7 edges
    t_k4 = 4 * comb(N, 4)                  # three faces of a K4: 6 edges
    t_path = T * 3 * (N - 3) * (N - 4)     # j - i - j' with j, j' disjoint: 7 edges
    sum_theta_p = (t_same + t_path) * q ** 7 + t_k4 * q ** 6  # = sum_i Theta'_i, every order
    # per-event bounds valid for every order (N_i <= Gamma(i), R_i <= everything)
    chain_pairs = 3 * (N - 3) * 2 * (N - 4)           # j in Gamma(i), k in Gamma(j) \ Gamma[i]
    adj_nb_pairs = 3 * comb(N - 3, 2) + 3 * (N - 3)   # adjacent pairs inside Gamma(i)
    nonadj_nb_pairs = 3 * (N - 3) * (N - 4)
    theta_bound = b * ((chain_pairs + adj_nb_pairs) * q ** 5 + nonadj_nb_pairs * q ** 6)
    betaC_bound = (d * b) * Cmax
    denom = (1 - d * b) * (1 - b)
    E3_every_order = (sum_theta_p + T * (theta_bound + betaC_bound)) / denom
    # the over-count that counts every connected triple once per member (3x)
    E3_overcount = (3 * sum_theta_p + T * (theta_bound + betaC_bound)) / denom
    return dict(
        N=N, mu=mu, q=q, b=b, triangles=T, max_degree_d=d, events_per_variable_r=N - 2,
        Delta_unordered=Delta, Delta_ordered=2 * Delta,
        first_order_window_exponent=Delta / (1 - b),
        logM=logM, sumC=sumC, logM2_range=[logM2_lo, logM2_hi],
        sum_Theta_prime_every_order=sum_theta_p,
        sum_Theta_bound_every_order=T * theta_bound,
        sum_betaC_bound_every_order=T * betaC_bound,
        E3_bound_every_order=E3_every_order,
        E3_triple_overcount=E3_overcount,
        connected_triples=dict(common_edge=t_same, k4=t_k4, path=t_path),
        lll_symmetric_e_b_dplus1=math.e * b * (d + 1),
        b_d_4p82=b * d ** 4.82,
        b_d_2=b * d ** 2,
        r_allowed_by_b_pow_minus_1_over_4p82=b ** (-1 / 4.82),
        kp_threshold_log10=-(N - 2) * math.log10(2 * math.e ** 3 * d),
    )


def triangle_brute_force(N, q, orders, rng):
    """Delta, sum C_i, sum Theta_i, sum Theta'_i, sum beta_i C_i and E_3 from the
    definitions (appendix), D(B_S) = q^{#edges of the union}, for random orders."""
    tris = list(itertools.combinations(range(N), 3))
    T = len(tris)
    E = [frozenset(itertools.combinations(t, 2)) for t in tris]
    adj = [[i != j and bool(E[i] & E[j]) for j in range(T)] for i in range(T)]
    D = lambda *ix: q ** len(frozenset().union(*(E[i] for i in ix)))  # noqa: E731
    b = q ** 3
    # connected triples, counted directly
    n_conn = {6: 0, 7: 0}
    for a, c, e in itertools.combinations(range(T), 3):
        if adj[a][c] + adj[a][e] + adj[c][e] >= 2:
            n_conn[len(E[a] | E[c] | E[e])] += 1
    out = []
    for _ in range(orders):
        perm = rng.permutation(T)
        rank = np.empty(T, int)
        rank[perm] = np.arange(T)
        Delta = sC = sTh = sThp = sBC = E3 = 0.0
        for i in range(T):
            Ni = [j for j in range(T) if adj[i][j] and rank[j] < rank[i]]
            Ri = [j for j in range(T) if not adj[i][j] and j != i and rank[j] < rank[i]]
            beta = len(Ni) * b
            C = sum(D(i, j) - b * b for j in Ni)
            Delta += sum(D(i, j) for j in Ni)
            chain = [(j, k) for j in Ni for k in Ri if adj[j][k]]
            pr = list(itertools.combinations(Ni, 2))
            Th = b * (sum(D(j, k) for j, k in chain) + sum(D(j, k) for j, k in pr))
            Thp = sum(D(i, j, k) for j, k in chain) + sum(D(i, j, k) for j, k in pr)
            sC += C
            sTh += Th
            sThp += Thp
            sBC += beta * C
            E3 += (Th + Thp + beta * C) / ((1 - beta) * (1 - b))
        out.append(dict(Delta=Delta, sumC=sC, sumTheta=sTh, sumThetaPrime=sThp,
                        sumBetaC=sBC, E3=E3))
    return T, n_conn, out


def triangles():
    res = {"N=1e4": {str(mu): triangle_closed_form(10 ** 4, mu) for mu in (10, 100)}}
    rng = np.random.default_rng(5)
    checks = []
    for N in (8, 9, 10):
        q = 0.3
        T, n_conn, runs = triangle_brute_force(N, q, orders=3, rng=rng)
        cf = triangle_closed_form(N, comb(N, 3) * q ** 3)
        ct = cf["connected_triples"]
        ok = (n_conn[7] == ct["common_edge"] + ct["path"] and n_conn[6] == ct["k4"])
        for r in runs:
            ok &= abs(r["Delta"] - cf["Delta_unordered"]) < 1e-9
            ok &= abs(r["sumC"] - cf["sumC"]) < 1e-9
            ok &= abs(r["sumThetaPrime"] - cf["sum_Theta_prime_every_order"]) < 1e-9
            ok &= r["sumTheta"] <= cf["sum_Theta_bound_every_order"] + 1e-12
            ok &= r["sumBetaC"] <= cf["sum_betaC_bound_every_order"] + 1e-12
            ok &= r["E3"] <= cf["E3_bound_every_order"] + 1e-12
        checks.append(dict(N=N, q=q, triangles=T, connected_triples_7_edges=n_conn[7],
                           connected_triples_6_edges=n_conn[6], orders=runs,
                           closed_form=dict(Delta=cf["Delta_unordered"], sumC=cf["sumC"],
                                            sumThetaPrime=cf["sum_Theta_prime_every_order"],
                                            E3_bound=cf["E3_bound_every_order"]),
                           consistent=bool(ok)))
    res["brute_force_checks"] = checks
    return res


# ------------------------------------------------------------------ 3. barrier
def barrier():
    f = lambda q: math.log1p(q ** 3 * (1 - q) / (1 - 3 * q ** 2 + 2 * q ** 3)) / (3 * q ** 3)  # noqa: E731
    grid = np.linspace(1e-3, 0.5, 5000)
    vals = np.array([f(x) for x in grid])
    r = minimize_scalar(f, bounds=(0.05, 0.5), method="bounded", options=dict(xatol=1e-10))
    # exact enumeration of one copy at q = 0.3
    q = 0.3
    ps = pt = 0.0
    for bits in itertools.product((0, 1), repeat=4):
        w = math.prod(q if x else 1 - q for x in bits)
        y, z1, z2, z3 = bits
        if not (y and (z1 or z2 or z3)):
            ps += w
        if not ((z1 and z2) or (z2 and z3) or (z3 and z1)):
            pt += w  # y does not occur in the triangle instance
    return dict(min_ratio=r.fun, argmin_q=r.x, grid_min=float(vals.min()),
                f_at_half=f(0.5), f_near_zero=f(1e-3),
                enumeration_q03=dict(p_stars=ps, formula_stars=(1 - q) + q * (1 - q) ** 3,
                                     p_triangles=pt, formula_triangles=1 - 3 * q ** 2 + 2 * q ** 3))


# ------------------------------------------------------- 4. interface DP chain
def chain(seeds=(11, 12, 13, 14, 15), sizes=(10 ** 5, 10 ** 9), delta=0.05):
    """Factor tables a_i(z_i, z_{i+1}) estimated by Monte Carlo. For N <= 10^6
    samples per entry the samples are drawn; for larger N the hit count of each
    entry is drawn as Binomial(N, a_i(y)), which has the same distribution."""
    rng = np.random.default_rng(2)
    m, Lp, q, qz = 300, 40, 0.3, 0.5
    c = rng.integers(2, 6, size=m)
    thr = rng.integers(12, 16, size=m)
    zs = [(z1, z2) for z1 in (0, 1) for z2 in (0, 1)]
    a_ex = np.array([[binom.cdf(thr[i] - c[i] * (z1 + z2), Lp, q) for (z1, z2) in zs] for i in range(m)])

    def logZ(a):  # a[i, 2*z1+z2]; open chain over z_0..z_m, each Bernoulli(qz)
        vec = np.array([1 - qz, qz])
        s = 0.0
        for i in range(m):
            Mi = np.array([[a[i, 2 * z1 + z2] * (qz if z2 else 1 - qz) for z2 in (0, 1)] for z1 in (0, 1)])
            vec = vec @ Mi
            t = vec.sum()
            s += math.log(t)
            vec /= t
        return s

    logp = logZ(a_ex)
    wz = np.array([(qz if z1 else 1 - qz) * (qz if z2 else 1 - qz) for (z1, z2) in zs])
    log_indep = float(np.sum(np.log(a_ex @ wz)))
    entries = a_ex.size
    by_size = {}
    for N_entry in sizes:
        runs = []
        for s in seeds:
            r = np.random.default_rng(s)
            if N_entry <= 10 ** 6:
                hits = np.array([[np.count_nonzero(r.binomial(Lp, q, size=N_entry) <= thr[i] - c[i] * (z1 + z2))
                                  for (z1, z2) in zs] for i in range(m)])
            else:
                hits = r.binomial(N_entry, a_ex)
            ahat = hits / N_entry
            lo = np.empty_like(ahat)
            hi = np.empty_like(ahat)
            for i in range(m):
                for k in range(4):
                    lo[i, k], hi[i, k] = kl_interval(float(ahat[i, k]), N_entry, delta / entries)
            L, U, P = logZ(lo), logZ(hi), logZ(ahat)
            runs.append(dict(seed=s, point_log_error=P - logp, cert_log_lo=L, cert_log_hi=U,
                             cert_log_width=U - L, contains=bool(L <= logp <= U)))
        by_size[str(N_entry)] = dict(
            runs=runs, all_contain=all(x["contains"] for x in runs),
            max_abs_point_log_error=max(abs(x["point_log_error"]) for x in runs),
            max_cert_log_width=max(x["cert_log_width"] for x in runs))
    return dict(modules=m, private_bits=Lp, q=q, q_interface=qz,
                table_entries=entries, delta=delta, exact_log_p=logp,
                exact_p=math.exp(logp), log10_p=logp / math.log(10),
                independence_log=log_indep, independence_gap=logp - log_indep,
                min_entry=float(a_ex.min()), samples_per_entry=by_size)


# ------------------------------------------- 5. constants of the procedure
def procedure(sim_rounds=200):
    grid = np.linspace(1e-6, 1, 100001)
    c = dict(
        ln1p_ge_eps_ln2=bool(np.all(np.log1p(grid) >= grid * math.log(2) - 1e-15)),
        round_failure_constant=128 + 16 * math.log(2),            # <= 140
        delta_test_reject_exponent=26 * 9 / 128,                    # >= 1
        delta_test_accept_exponent=26 * (1 + 4 * math.log(4 / math.e)) / 64,  # >= 1
    )
    # main stage on m = 10^4 independent events with b_i = 0.1 (mu = 1000), eps = 0.1
    rng = np.random.default_rng(3)
    m, bval, eps = 10 ** 4, 0.1, 0.1
    epsp = math.log1p(eps)
    mu = m * bval
    logM = m * math.log1p(-bval)
    out = {}
    for name, N in (("N=100/eps^2", int(100 / eps ** 2)),
                    ("N=560(2mu+1)/eps'^2", int(math.ceil(560 * (2 * mu + 1) / epsp ** 2)))):
        bad = 0
        for _ in range(sim_rounds):
            bh = rng.binomial(N, bval, size=m) / N
            if np.any(bh > 1 / 3):
                continue
            bad += abs(float(np.sum(np.log1p(-bh))) - logM) > epsp / 4
        out[name] = dict(N=N, fraction_rounds_off_by_more_than_epsprime_over_4=bad / sim_rounds)
    c["main_stage_simulation"] = dict(m=m, b=bval, mu=mu, eps=eps, rounds=sim_rounds, **out)
    return c


def main():
    res = dict(triangle_freeness=triangles(), pairwise_barrier=barrier(),
               interface_dp_chain=chain(), procedure_constants=procedure())
    os.makedirs(OUT, exist_ok=True)
    with open(os.path.join(OUT, "independence_numbers.json"), "w") as f:
        json.dump(res, f, indent=1, default=float)
    t = res["triangle_freeness"]["N=1e4"]
    for mu in ("10", "100"):
        x = t[mu]
        print(f"triangles mu={mu}: Delta={x['Delta_unordered']:.4f} window e^{x['first_order_window_exponent']:.4f} "
              f"logM={x['logM']:.3f} logM2 in [{x['logM2_range'][0]:.4f},{x['logM2_range'][1]:.4f}] "
              f"E3<= {x['E3_bound_every_order']:.5f} (3x over-count {x['E3_triple_overcount']:.4f}) "
              f"e*b*(d+1)={x['lll_symmetric_e_b_dplus1']:.2e} b*d^4.82={x['b_d_4p82']:.2e} "
              f"b^(-1/4.82)={x['r_allowed_by_b_pow_minus_1_over_4p82']:.1f}")
    print("brute force consistent:", [c["consistent"] for c in res["triangle_freeness"]["brute_force_checks"]])
    print("barrier:", res["pairwise_barrier"])
    ch = res["interface_dp_chain"]
    print(f"chain: log p={ch['exact_log_p']:.4f} (p={ch['exact_p']:.3e}), independence gap {ch['independence_gap']:.2f}")
    for N, v in ch["samples_per_entry"].items():
        print(f"   N={N}: max |point err| {v['max_abs_point_log_error']:.4f}, "
              f"max certified log-width {v['max_cert_log_width']:.4f}, all contain: {v['all_contain']}")
    print("procedure:", res["procedure_constants"])


if __name__ == "__main__":
    main()

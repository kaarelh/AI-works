"""Part 11 theory (THEORY.md): every number quoted there is computed here and written to check_theory.json.

usage: OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python check_theory.py
Reads the frozen learner (part10/hyb_portfolio3/dfg13.py, md5-checked through eval_dfg.load_dfg13), the Part 11 result
files (part11/results/toy__dfg13-perm__*.json), study/dscale.json, the order analysis' cells
(interp/order/results/cells, seed 0) and the cached fits of theory_fits.py (theory/cache/; run theory_fits.py first).
Sections: code (constants read from the code), P1 (null), P2 (parities), P3 (n_glob), P4 (sum blocks), P5 (compute).
"""
import os, sys, json, gzip, math, time, inspect, itertools
from fractions import Fraction
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__)); INTERP = os.path.dirname(HERE); P11 = os.path.dirname(INTERP)
STUDY = os.path.dirname(P11)
sys.path.insert(0, HERE)
import theory_fits as TF                                               # noqa: E402  (dfg_hooks, order_fit, cache paths)
H, OF, TH = TF.H, TF.OF, TF.TH
DM = H.E.load_dfg13()                                                  # the frozen module (md5 checked)
C = math.comb
NS = TH.NS
RES = os.path.join(P11, "results")
OUT = {}


def rfile(suite):
    return json.load(open(os.path.join(RES, f"toy__dfg13-perm__{suite}.json")))


def dsuite(d):
    return "designed" if d == 30 else f"designed_d{d}"


# ------------------------------------------------------------------------------------------------ code facts
def defaults():
    sig = inspect.signature(DM.DFG.__init__)
    return {k: (v.default if not isinstance(v.default, tuple) else list(v.default)) for k, v in sig.parameters.items()
            if k != "self"}


DEF = defaults()
Kc, Klat, cc, DELTA = DEF["K"], DEF["K_later"], DEF["c"], DEF["delta"]
BUD, BUDHI = tuple(DEF["budget"]), DEF["budget_hi"]


def L_of(N):
    """The log term of thr(N) = c s sqrt(2 L / n):  L = ln(4 K N / delta), K = self.K = 4 in every round."""
    return math.log(4 * Kc * max(N, 1) / DELTA)


def n_thr(k, d, c=cc):
    return 2 * c * c * L_of(C(d, k))


def m_k(k, n, d, scale):
    """The subsample size of the round's global degree-k search, as DFG._fit computes it (lines 628, 638, 654)."""
    GD = TH.gd_flops(d) * scale
    if k == 3:
        return min(n, int(BUD[1] * GD / (d * (2 * d * d + 2 * d))))
    if k == 4:
        return min(n, int(BUD[0] * GD / (C(d, 2) * (2 * d * d + 3 * d))))
    k1, k2 = (k + 1) // 2, k // 2; N1, N2 = C(d, k1), C(d, k2)
    return min(n, int(BUDHI * GD / (2 * N1 * N2 + DM.m_tab_cost(d, k1, k2))))


def searched(k, n, d, scale, hi=True):
    if k <= 2:
        return True
    if k <= 4:
        return m_k(k, n, d, scale) >= 32
    if k <= 6:
        return hi and m_k(k, n, d, scale) >= 64
    return False


def final_scale(n):
    return 1.0 if n > DEF["cv_n"] else 0.5


def code_section():
    md5 = __import__("hashlib").md5(open(H.E.DFG13, "rb").read()).hexdigest()
    gd = {str(d): TH.gd_flops(d) for d in (15, 30, 60, 120, 1000)}
    doc = DM.__doc__
    return dict(md5=md5, defaults={k: DEF[k] for k in ("K", "K_later", "c", "delta", "rounds", "max_new", "max_feats",
                                                         "max_ext_bases", "local_max", "budget", "small_n", "cv_n",
                                                         "K_hi", "budget_hi", "sum_nmin", "sum_mc", "sum_kmax",
                                                         "sum_force", "sum_force_nmin", "readout", "ridge")},
                gd_flops=gd,
                docstring_says_sum_force_off=("sum_force=True, off by default" in doc),
                per_class_level_c1=DELTA / (2 * Kc))


# ------------------------------------------------------------------------------------------------ P1: the null
def _pairs(d):
    I, J = np.triu_indices(d, 1)
    return I, J


def round0_z(X, y, d, scale=1.0, hi=False, degrees=(1, 2, 3, 4), direct=False):
    """Round 0 of DFG._fit on (X, y), replicated: r = y - w0 (w0 = sum y / (n + 1e-9), the ridge-free constant fit),
    s = rms(r); for each searched degree k the largest z = |mean_m(r chi_S)| / thr over the C(d, k) characters (m = the
    code's subsample, thr = thr(N) or thr_m(N, m)); the linear block's statistic T1 = n |c1|^2 / s^2; the spectral
    block's top |eigenvalue| of the off-diagonal residual pair matrix over its edge.  direct=True enumerates character
    tables (small d, degrees up to 6); else degrees 3, 4 come from products of pair columns."""
    n = len(y); X = np.asarray(X, np.float64); y = np.asarray(y, np.float64)
    w0 = y.sum() / (n + 1e-9); r = y - w0; s = math.sqrt(max(float(np.mean(r * r)), 1e-12))
    out = dict(s=s)
    if s < 1e-6:
        return out
    thr = lambda N: cc * s * math.sqrt(2 * L_of(N) / n)

    def thr_m(N, m):
        return thr(N) * math.sqrt(n / m) * (math.sqrt(np.mean(r[:m] ** 2)) / s if m < n else 1.0)
    c1 = X.T @ r / n
    z = {}
    if 1 in degrees:
        z[1] = float(np.max(np.abs(c1)) / thr(d))
    M = (X * r[:, None]).T @ X / n
    I, J = _pairs(d)
    if 2 in degrees:
        z[2] = float(np.max(np.abs(M[I, J])) / thr(C(d, 2)))
    for k in [k for k in degrees if k >= 3]:
        if not searched(k, n, d, scale, hi):
            continue
        m = m_k(k, n, d, scale); Xm, rm = X[:m], r[:m]; t = thr_m(C(d, k), m)
        if direct:
            cols = list(itertools.combinations(range(d), k)); Z = np.ones((m, len(cols)))
            for q in range(k):
                Z *= Xm[:, [S[q] for S in cols]]
            z[k] = float(np.max(np.abs(rm @ Z / m)) / t)
        elif k == 3:
            P = Xm[:, I] * Xm[:, J]; G = P.T @ (Xm * rm[:, None]) / m
            ok = (np.arange(d)[None, :] != I[:, None]) & (np.arange(d)[None, :] != J[:, None])
            z[3] = float(np.max(np.abs(G[ok])) / t)
        elif k == 4:
            P = Xm[:, I] * Xm[:, J]; G = (P * rm[:, None]).T @ P / m
            ok = ((I[:, None] != I[None, :]) & (I[:, None] != J[None, :]) & (J[:, None] != I[None, :])
                  & (J[:, None] != J[None, :]))
            z[4] = float(np.max(np.abs(G[ok])) / t)
    out["z"] = z
    tt = math.log(1 / DELTA)
    out["T1"] = float(n * np.sum(c1 ** 2) / s ** 2)
    Ms = (M + M.T) / 2; np.fill_diagonal(Ms, 0.0)
    lam = np.linalg.eigvalsh(Ms)
    edge = 2 * s * math.sqrt(d / n) * (1 + math.sqrt(2 * math.log(1 / DELTA) / d))
    out["quad_ratio"] = float(np.max(np.abs(lam)) / edge)
    return out


def labels(law, n, rng):
    if law == "fair":
        return rng.choice([-1.0, 1.0], size=n)
    if law == "biased":
        return np.where(rng.random(n) < 0.85, 1.0, -1.0)
    if law == "fixed":                                                   # one fixed vector, the same in every replicate
        return np.where(np.arange(n) < -(-n // 3), 1.0, -1.0)
    raise ValueError(law)


def cp_upper(k, R, a=0.05):
    """One-sided 95% Clopper-Pearson upper limit for a binomial proportion k / R."""
    from scipy.stats import beta
    return 1.0 if k >= R else float(beta.ppf(1 - a, k + 1, R - k))


def bound_k(N, u, c=cc):
    """The Hoeffding union bound for one degree: P(max_S z_S >= u) <= 2 N (delta / (4 K N))^(u^2 c^2)."""
    return min(1.0, 2 * N * (DELTA / (4 * Kc * N)) ** (u * u * c * c))


def p1_section(fast=False):
    res = dict(bounds={}, sims=[], linear=[], quad=[])
    for d in (15, 30, 60, 120):
        res["bounds"][str(d)] = {str(k): dict(N=C(d, k), L=L_of(C(d, k)), bound_u1=bound_k(C(d, k), 1.0)) for k in range(1, 7)}
    res["bound_total_deg1to4"] = 4 * DELTA / (2 * Kc); res["bound_total_deg1to6"] = 6 * DELTA / (2 * Kc)
    us = [0.7, 0.8, 0.9, 1.0]; xs = [0.5, 1.0, 2.0, math.log(1 / DELTA)]
    R = 60 if fast else 300
    plans = ([dict(d=30, n=n, law=law, scale=1.0, hi=False, degrees=(1, 2, 3, 4), direct=False)
              for n in (32, 128, 512, 2048) for law in ("fair", "biased", "fixed")]
             + [dict(d=15, n=n, law="fair", scale=1.0, hi=True, degrees=(1, 2, 3, 4, 5, 6), direct=True) for n in (64, 256, 1024)]
             + [dict(d=60, n=1024, law="fair", scale=1 / 20, hi=False, degrees=(1, 2, 3, 4), direct=False)])
    for pl in plans:
        d, n = pl["d"], pl["n"]; rng = np.random.default_rng([31337, d, n, ["fair", "biased", "fixed"].index(pl["law"])])
        zs, T1s, qs = [], [], []
        t0 = time.process_time()
        for rep in range(R):
            X = rng.choice([-1.0, 1.0], size=(n, d)); y = labels(pl["law"], n, rng)
            o = round0_z(X, y, d, pl["scale"], pl["hi"], pl["degrees"], pl["direct"])
            zs.append(o.get("z", {})); T1s.append(o.get("T1", 0.0)); qs.append(o.get("quad_ratio", 0.0))
        row = dict(d=d, n=n, law=pl["law"], scale=pl["scale"], reps=R, cpu=round(time.process_time() - t0, 1),
                   m={str(k): (m_k(k, n, d, pl["scale"]) if k >= 3 else n) for k in pl["degrees"]}, deg={})
        for k in pl["degrees"]:
            if not zs or k not in zs[0]:
                continue
            v = np.array([z[k] for z in zs]); N = C(d, k)
            row["deg"][str(k)] = {f"u{u}": dict(hits=int(np.sum(v >= u)), rate=float(np.mean(v >= u)),
                                               cp95=cp_upper(int(np.sum(v >= u)), R), bound=bound_k(N, u))
                                  for u in us}
            row["deg"][str(k)]["max_z"] = float(v.max())
        anyk = np.array([max(z.values()) if z else 0.0 for z in zs])
        row["any_degree_u1"] = dict(hits=int(np.sum(anyk > 1)), bound=len(row["deg"]) * DELTA / (2 * Kc))
        T1 = np.array(T1s)
        row["linear"] = {f"x{x:.3f}": dict(thr=d + 2 * math.sqrt(d * x) + 2 * x, hits=int(np.sum(T1 > d + 2 * math.sqrt(d * x) + 2 * x)),
                                           rate=float(np.mean(T1 > d + 2 * math.sqrt(d * x) + 2 * x)), bound=math.exp(-x))
                         for x in xs}
        row["linear_admissible_n"] = bool(n >= 2 * (1 + d))
        q = np.array(qs); row["quad"] = dict(applies=bool(n >= 4 * d), hits=int(np.sum(q > 1)), rate=float(np.mean(q > 1)),
                                            max_ratio=float(q.max()))
        res["sims"].append(row)
        print(f"P1 sim d={d} n={n} {pl['law']}: " + ", ".join(f"k{k} z>=1 {row['deg'][k]['u1.0']['hits']}/{R} "
                                                            f"z>=.8 {row['deg'][k]['u0.8']['hits']}"
                                                            for k in row["deg"]) +
              f" | linear(x=ln10) {row['linear'][f'x{math.log(10):.3f}']['hits']} | quad {row['quad']['hits']} | {row['cpu']}s", flush=True)
    viol = [(r["d"], r["n"], r["law"], k, u) for r in res["sims"] for k, v in r["deg"].items() for u, w in v.items()
            if isinstance(w, dict) and w["rate"] > w["bound"]]
    lviol = [(r["d"], r["n"], r["law"], x) for r in res["sims"] for x, w in r["linear"].items() if w["rate"] > w["bound"]]
    res["violations_char"] = viol; res["violations_linear"] = lviol
    res["n_checks_char"] = sum(len(us) for r in res["sims"] for k in r["deg"])
    res["n_checks_linear"] = sum(len(xs) for r in res["sims"])
    tot = dict(reps=sum(r["reps"] for r in res["sims"]),
               any_u1=sum(r["any_degree_u1"]["hits"] for r in res["sims"]))
    res["totals"] = tot
    # quad (spectral) block under the null: uncovered by the proof; rate where it applies (n >= 4 d)
    res["quad_summary"] = [dict(d=r["d"], n=r["n"], law=r["law"], hits=r["quad"]["hits"], reps=r["reps"])
                           for r in res["sims"] if r["quad"]["applies"]]
    # full DFG fits on null labels (theory_fits.run_p1)
    path = os.path.join(TF.CACHE, "p1_null_fits.json")
    if os.path.exists(path):
        F = json.load(open(path)); rows = {}
        for key, o in F.items():
            n = o["n"]; rw = rows.setdefault(str(n), dict(fits=0, nonconstant=0, forced_chosen=0, chars=0, linear=0,
                                                           quad=0, sumblock=0, round0_admit=0, deg={}, folds_nonempty=0,
                                                           n_folds=0, folds_default_nonempty=0))
            rw["fits"] += 1; rw["nonconstant"] += int(o["size"] > 1); rw["forced_chosen"] += int(o["variant"] == 1)
            nch = sum(o["chars_by_deg"].values()); rw["chars"] += int(nch > 0)
            for k, v in o["chars_by_deg"].items():
                if v:
                    rw["deg"][k] = rw["deg"].get(k, 0) + 1
            r0 = o["round0"] or dict(n_new=0, blocks=[])
            rw["linear"] += int("linear" in r0["blocks"]); rw["quad"] += int(o["n_quad"] > 0)
            rw["sumblock"] += int(o["n_sum_feats"] > 0)
            rw["round0_admit"] += int(r0["n_new"] > 0 or len(r0["blocks"]) > 0)
            rw["folds_nonempty"] += o["folds_nonempty"]; rw["n_folds"] += o["n_folds"]
            rw["folds_default_nonempty"] += o["folds_default_nonempty"]
        res["full_fits"] = rows
        # the replica of round 0 (degrees 1-4, linear and spectral statistics) on the same 80 data sets, against what
        # DFG's own final fit admitted in round 0 (test admissions only; a forced pick has z <= 1 by definition)
        agree, rep = 0, []
        for key, o in F.items():
            n, r_ = o["n"], o["rep"]
            rng = np.random.default_rng([20261103, n, r_])
            X = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(n, TF.P1_D))
            y = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=n)
            z = round0_z(X, y, TF.P1_D, final_scale(n), False, (1, 2, 3, 4))
            pred = sorted(k for k, v in z["z"].items() if v > 1)
            r0 = o["round0"] or dict(n_new=0, new=[], blocks=[])
            got = sorted(set(len(S) for S in r0["new"])) if (r0["n_new"] and o["variant"] == 0) else []
            if o["variant"] == 1 and r0["n_new"]:
                got = []                                        # the forced pick (checked: z <= 1 below)
            ok_ = (pred == got) and (("linear" in r0["blocks"]) == (z["T1"] > TF.P1_D + 2 * math.sqrt(TF.P1_D * math.log(1 / DELTA))
                                                                  + 2 * math.log(1 / DELTA) and n >= 2 * (1 + TF.P1_D)))
            agree += int(ok_)
            if pred or got or o["size"] > 1:
                rep.append(dict(key=key, variant=o["variant"], replica_degrees_z_gt_1=pred, dfg_round0=r0,
                                replica_max_z={str(k): round(v, 4) for k, v in z["z"].items()}, T1=round(z["T1"], 2),
                                quad_ratio=round(z["quad_ratio"], 3)))
        res["full_fits_replica"] = dict(fits=len(F), agree=agree, cases=rep)
    return res


# ------------------------------------------------------------------------------------------------ P2: parities
def p_pass(n, k, d):
    """Exact P(the round-0 test of the final fit admits chi_S) for y = chi_S, |S| = k, when the degree-k search runs on
    all n points: the labels are iid fair signs, so sum(y) = 2B - n with B ~ Bin(n, 1/2), and the test passes iff
    n (1 - ybar^2) > n_thr(k, d).  For n >= 2048 (where some searches are subsampled) it is 1 to within 1e-60 on this
    grid and 1.0 is returned."""
    if not searched(k, n, d, final_scale(n)):
        return 0.0
    if n >= 2048:
        return 1.0
    lim = n * (n - n_thr(k, d))
    if lim <= 0:
        return 0.0
    tot = sum(C(n, b) for b in range(n + 1) if (2 * b - n) ** 2 < lim)
    return float(Fraction(tot, 2 ** n))


def crit_exact(y, k, d, n, m=None):
    """The exact round-0 criterion for y = chi_S, with the 1e-9 term of the constant fit and the subsample m."""
    y = np.asarray(y, np.float64); w0 = y.sum() / (n + 1e-9); m = n if m is None else m
    ym = y[:m].mean()
    lhs = m * (1 - w0 * ym) ** 2; rhs = n_thr(k, d) * (1 - 2 * w0 * ym + w0 * w0)
    return lhs > rhs, lhs - rhs


def nstar(errs):
    return TH.nstar(NS, errs)


def p2_section():
    out = dict(n_thr={}, cells=[], pred={}, pass_prob={}, d1000={}, networks={})
    for d in (15, 30, 60, 120, 1000):
        out["n_thr"][str(d)] = {str(k): n_thr(k, d) for k in (2, 3, 4)}
    p2c = json.load(open(os.path.join(TF.CACHE, "p2_cells.json")))
    agree = dict(n_ge32=0, n_ge32_total=0, jitter_same=0, jitter_total=0, n16_fail_crit=0, n16_total=0,
                 n16_err0=0, n16_err0_forced=0, n16_forced_holds_S=0)
    rows_meas = {}
    for d in (15, 30, 60, 120):
        R = rfile(dsuite(d)); T = H.targets("designed", d)
        for t, k in (("par2", 2), ("par3", 3), ("par4", 4)):
            if t not in R["fns"]:
                continue
            E = np.array(R["fns"][t]["err"]); fn = T[t]["fn"]
            pred_seed = np.zeros_like(E); predC = np.zeros_like(E)
            for a, n in enumerate(R["ns"]):
                sc = final_scale(n)
                for b, s in enumerate(R["seeds"]):
                    X, y = TH.train_data(fn, t, s, n, d); y = y.astype(np.float64)
                    srch = searched(k, n, d, sc); m = m_k(k, n, d, sc) if k >= 3 else n
                    simple = srch and n * (1 - (y.mean()) ** 2) > n_thr(k, d) if m == n else None
                    ex, margin = crit_exact(y, k, d, n, m) if srch else (False, None)
                    ok = bool(ex) and srch
                    agree["jitter_total"] += int(simple is not None)
                    agree["jitter_same"] += int(simple is not None and bool(simple) == bool(ex))
                    err = float(E[a, b]); pred_seed[a, b] = 0.0 if ok else 0.5
                    key = f"{t}__d{d}__n{n}__s{s}"; var = p2c[key]["variant"] if key in p2c else None
                    holds = None
                    if key in p2c:
                        holds = p2c[key]["true_S"] in p2c[key]["calls"][-1]["chars"]
                    predC[a, b] = 0.0 if (ok or holds) else 0.5
                    if n >= 32:
                        agree["n_ge32_total"] += 1; agree["n_ge32"] += int((err == 0.0) == ok)
                    if n == 16:
                        agree["n16_total"] += 1; agree["n16_fail_crit"] += int(not ok)
                        agree["n16_err0"] += int(err == 0.0); agree["n16_err0_forced"] += int(err == 0.0 and var == 1)
                        agree["n16_forced_holds_S"] += int(err == 0.0 and bool(holds))
                    if n <= 64:
                        out["cells"].append(dict(d=d, t=t, n=n, seed=s, sum_y=int(y.sum()), crit=n * (1 - y.mean() ** 2),
                                                 n_thr=n_thr(k, d), searched=srch, m=m, passes=ok,
                                                 margin=(None if margin is None else float(margin)), err=err,
                                                 variant=var, cv_errs=(p2c[key]["cv_errs"] if key in p2c else None),
                                                 final_holds_S=holds,
                                                 forced_folds_with_S=(sum(1 for c in p2c[key]["calls"][:-1]
                                                                          if c["force"] and p2c[key]["true_S"] in c["chars"])
                                                                      if key in p2c else None)))
            expect = [0.5 * (1 - p_pass(n, k, d)) for n in R["ns"]]
            out["pred"][f"{t}_d{d}"] = dict(measured=nstar(np.nanmean(E, 1)), per_seed_test=nstar(pred_seed.mean(1)),
                                            per_seed_test_or_forced=nstar(predC.mean(1)), expected_binomial=nstar(expect),
                                            first_pass_grid=next(n for n in R["ns"] if n > n_thr(k, d) and searched(k, n, d, final_scale(n))),
                                            seeds=R["seeds"], mean_err_16_32_64=[float(np.nanmean(E[i])) for i in range(3)])
            out["pass_prob"][f"{t}_d{d}"] = {str(n): p_pass(n, k, d) for n in (16, 32, 64, 128)}
            rows_meas[(t, d)] = out["pred"][f"{t}_d{d}"]["measured"]
    out["agree"] = agree
    # d = 1000: the test-limited prediction, and what DFG v1.3's budget rule does there (Heuristic)
    d = 1000; GD = TH.gd_flops(d)
    for t, k in (("par2", 2), ("par3", 3), ("par4", 4)):
        pp = {n: (0.0 if n <= n_thr(k, d) else float(Fraction(sum(C(n, b) for b in range(n + 1) if (2 * b - n) ** 2 < n * (n - n_thr(k, d))), 2 ** n)))
              for n in NS[:5]}
        e = [0.5 * (1 - pp.get(n, 1.0)) if n in pp else 0.0 for n in NS]
        out["d1000"][t] = dict(n_thr=n_thr(k, d), pass_prob={str(n): pp[n] for n in pp}, nstar_test_limited=nstar(e))
    out["d1000"]["budget"] = {f"m{k}_scale{sc}": m_k(k, 16384, d, sc) for k in (3, 4, 5) for sc in (1.0, 0.5)}
    out["d1000"]["exhaustive_flops_n64_over_GD"] = {str(k): fk / GD for k, fk in exhaustive_flops(64, d).items()}
    out["d1000"]["GD"] = GD
    # networks: dscale.json (d = 15, 30, 60) and the d = 120 reference in the d = 120 result file
    ds = json.load(open(os.path.join(STUDY, "dscale.json")))
    R120 = rfile("designed_d120")
    for t in ("par2", "par3", "par4"):
        nn = {dd: ds["rows"][dd][t]["nn"] for dd in ("15", "30", "60")}
        if t in R120["fns"]:
            nn["120"] = TH.nstar(NS, np.nanmean(np.array(R120["fns"][t]["nn_err"]), 1))
        a = ds["exponents"][t]["nn"]
        out["networks"][t] = dict(nstar=nn, exponent_15_60=a, pred120_from_60=nn["60"] * 2 ** a,
                                  extrap1000=nn["60"] * (1000 / 60) ** a,
                                  dfg_measured={str(dd): rows_meas.get((t, dd)) for dd in (15, 30, 60, 120)})
    return out


# ------------------------------------------------------------------------------------------------ P3: n_glob
def n_glob(yS, y0, k, d=30):
    return 2 * cc * cc * L_of(C(d, k)) * (1 - y0 * y0) / (yS * yS)


def load_cell(suite, t, n):
    if suite == "designed" and t in TF.ORDER_TARGETS:
        p = os.path.join(TF.ORDER_CELLS, f"{t}__n{n}__s0.json.gz")
    else:
        p = TF.p3_path(suite, t, n)
    return json.load(gzip.open(p, "rt")) if os.path.exists(p) else None


def p3_section():
    res = dict(targets=0, chars=0, per_target={}, test0=dict(tp=0, tn=0, fp=0, fn=0, fp_ratio=[], fn_ratio=[]),
               first=dict(), early_routes={}, late=dict(), factors={}, missing_cells=[])
    rows = []
    for suite in ("designed", "random"):
        T = H.targets(suite)
        for t in T:
            sup, _ = OF.target_support(T[t]["fn"], list(T[t]["relevant"]), 30)
            y0 = next((c for nm, S, c in sup if not S), 0.0)
            chars = [(nm, S, c) for nm, S, c in sup if S]
            cells = {}
            for n in NS:
                o = load_cell(suite, t, n)
                if o is None:
                    res["missing_cells"].append(f"{suite}/{t}/{n}"); continue
                cells[n] = o
            if len(cells) < len(NS):
                continue
            res["targets"] += 1
            for nm, S, yS in chars:
                k = len(S); res["chars"] += 1
                ng = n_glob(yS, y0, k) if k <= 6 else float("inf")
                # predicted first grid n of a round-0 global admission (first order): m(n) > n_glob, degree searched
                npred = None
                for n in NS:
                    sc = final_scale(n); m = n if k <= 4 else (m_k(k, n, 30, sc) if k <= 6 else 0)
                    if k <= 6 and searched(k, n, 30, sc) and m > ng:
                        npred = n; break
                # round-0 global test, replayed, against n > n_glob (degrees <= 4)
                z0 = {}
                for n, o in cells.items():
                    j = o["chars"].index(nm); rp = o["replay"][nm][0]
                    z0[n] = (rp.get("global", {}) or {}).get("z") if rp else None
                    if k <= 4 and searched(k, n, 30, final_scale(n)) and z0[n] is not None:
                        pp, ap = n > ng, z0[n] > 1.0
                        key = "tp" if (pp and ap) else "tn" if (not pp and not ap) else "fp" if pp else "fn"
                        res["test0"][key] += 1
                        if key in ("fp", "fn"):
                            res["test0"][key + "_ratio"].append(math.log2(n / ng))
                # first explicit appearance in the final model
                nfirst, route = None, None
                for n in NS:
                    ex = cells[n]["explicit"].get(nm)
                    if ex:
                        nfirst = n; route = ex; break
                row = dict(suite=suite, t=t, nm=nm, k=k, yhat=yS, y0=y0, n_glob=ng, n_pred=npred, n_first=nfirst,
                           route=route, z0=z0)
                if nfirst is not None and route and route["how"] == "test" and route["cls"] in ("ext1", "ext2", "local", "global") \
                        and not (route["cls"] == "global" and route["round"] == 0):
                    o = cells[nfirst]; j = route["round"]; rp = o["replay"][nm][j]; cl = rp[route["cls"]]
                    sj = o["s_replay"][j]; vj = rp["v"]
                    row["factors"] = dict(N_glob=C(30, k), N_cls=cl["N"], L_ratio=L_of(C(30, k)) / L_of(cl["N"]),
                                          s_ratio=(1 - y0 * y0) / (sj * sj), v_ratio=(vj * vj) / (yS * yS) if vj else None,
                                          z_cls=cl["z"], z_glob0=z0.get(nfirst))
                rows.append(row)
    # agreement of the first appearance with the predicted grid n
    cat = {}
    for r in rows:
        if r["n_pred"] is None and r["n_first"] is None:
            c_ = "never_predicted_never_seen"
        elif r["n_pred"] is None:
            c_ = "seen_not_predicted"
        elif r["n_first"] is None:
            c_ = "predicted_never_seen"
        else:
            dl = int(round(math.log2(r["n_first"] / r["n_pred"])))
            c_ = "same" if dl == 0 else ("earlier" if dl < 0 else "later")
        r["cat"] = c_; cat[c_] = cat.get(c_, 0) + 1
    res["first"]["counts"] = cat
    pr = [r for r in rows if r["n_pred"] is not None and r["n_first"] is not None]
    res["first"]["log2_first_over_pred"] = {str(v): sum(1 for r in pr if int(round(math.log2(r["n_first"] / r["n_pred"]))) == v)
                                            for v in sorted(set(int(round(math.log2(r["n_first"] / r["n_pred"]))) for r in pr))}
    res["first"]["log2_first_over_nglob_median_global0"] = float(np.median(
        [math.log2(r["n_first"] / r["n_glob"]) for r in pr if r["route"]["cls"] == "global" and r["route"]["round"] == 0
         and r["route"]["how"] == "test"])) if pr else None
    # routes of the characters that appear earlier than predicted, or appear without a prediction
    routes = {}
    for r in rows:
        if r["cat"] in ("earlier", "seen_not_predicted"):
            ro = r["route"]; key = f"{ro['how']}:{ro['cls']}:{'r0' if ro['round'] == 0 else 'r1+'}"
            routes.setdefault(r["cat"], {}); routes[r["cat"]][key] = routes[r["cat"]].get(key, 0) + 1
    res["early_routes"] = routes
    # factors for the later-round classes that made a character cheaper than n_glob
    fac = {}
    for r in rows:
        if r["cat"] in ("earlier", "seen_not_predicted") and r.get("factors"):
            cl = r["route"]["cls"] + ("" if r["route"]["cls"] != "global" else "_r1+")
            fac.setdefault(cl, []).append(r["factors"])
    res["factors"] = {cl: dict(count=len(v), median_L_ratio=float(np.median([f["L_ratio"] for f in v])),
                               median_s_ratio=float(np.median([f["s_ratio"] for f in v])),
                               median_v_ratio=float(np.median([f["v_ratio"] for f in v if f["v_ratio"]])),
                               median_log2_gain=float(np.median([math.log2(f["L_ratio"] * f["s_ratio"] * (f["v_ratio"] or 1)) for f in v])))
                      for cl, v in fac.items()}
    # the later-than-predicted cases: test failed at the predicted n (fluctuation) or passed but capped
    late = dict(z_below_1_at_pred=0, z_above_1_at_pred=0, examples=[])
    for r in rows:
        if r["cat"] in ("later", "predicted_never_seen"):
            z = r["z0"].get(r["n_pred"])
            if z is not None and z > 1:
                late["z_above_1_at_pred"] += 1
            else:
                late["z_below_1_at_pred"] += 1
            if len(late["examples"]) < 40:
                late["examples"].append(dict(t=r["t"], nm=r["nm"], n_glob=round(r["n_glob"], 1), n_pred=r["n_pred"],
                                             n_first=r["n_first"], z_at_pred=z, cat=r["cat"]))
    res["late"] = late
    res["test0"]["fp_ratio_median"] = float(np.median(res["test0"]["fp_ratio"])) if res["test0"]["fp_ratio"] else None
    res["test0"]["fn_ratio_median"] = float(np.median(res["test0"]["fn_ratio"])) if res["test0"]["fn_ratio"] else None
    res["test0"]["fp_within_1"] = sum(1 for v in res["test0"]["fp_ratio"] if v <= 1.0)
    res["test0"]["fn_within_1"] = sum(1 for v in res["test0"]["fn_ratio"] if v >= -1.0)
    res["test0"]["fp_ratio"] = [round(v, 3) for v in res["test0"]["fp_ratio"]]
    res["test0"]["fn_ratio"] = [round(v, 3) for v in res["test0"]["fn_ratio"]]
    res["rows"] = [dict((k, v) for k, v in r.items() if k != "z0") for r in rows]
    return res


# ------------------------------------------------------------------------------------------------ P4: sum blocks
def krawtchouk_coeffs(g, k):
    """Exact a_j = E[g(B) z_1 ... z_j] (B = #{i : z_i = +1}, z uniform on {-1,1}^k) as Fractions, j = 0..k."""
    a = []
    for j in range(k + 1):
        tot = 0
        for b in range(k + 1):
            Kj = sum((-1) ** (j - l) * C(j, l) * C(k - j, b - l) for l in range(max(0, b - (k - j)), min(j, b) + 1))
            tot += g(b) * Kj
        a.append(Fraction(tot, 2 ** k))
    return a


def mod3_closed_form(k, rho, sign, j):
    """a_j (j >= 1) of g(B) = sign * (1 - 2 [B = rho mod 3]):  -2 sign (2/3) 3^(j/2) 2^-k cos(5 pi j/6 + pi (k-j)/3 - 2 pi rho/3)."""
    return -2 * sign * (2 / 3) * 3 ** (j / 2) * 2.0 ** (-k) * math.cos(5 * math.pi * j / 6 + math.pi * (k - j) / 3 - 2 * math.pi * rho / 3)


def fwht_weights(fn, R, d=30):
    """Exact Fourier coefficients of f on its relevant inputs R (all 2^|R| patterns, Walsh-Hadamard), weights by degree."""
    r = len(R); pats = ((np.arange(2 ** r)[:, None] >> np.arange(r)) & 1) * -2.0 + 1.0     # bit 1 -> -1
    X = np.ones((2 ** r, d)); X[:, R] = pats
    y = np.asarray(fn(X), np.float64)
    h = DM._fwht(y) / 2 ** r                                           # h[mask] = E[f chi_{mask}] (bit q <-> input R[q])
    deg = np.array([bin(m).count("1") for m in range(2 ** r)])
    return {int(j): float(np.sum(h[deg == j] ** 2)) for j in range(r + 1)}, h, deg


def grouping(pv, mc):
    """DFG's contiguous groups (dfg13._edges) for exact per-value counts pv (dict value -> count), min group size mc."""
    vals = sorted(pv); t = np.concatenate([np.full(int(pv[v]), float(v)) for v in vals])
    E = DM._edges(t, mc)
    g = {v: int(np.searchsorted(E, v)) for v in vals}
    groups = {}
    for v in vals:
        groups.setdefault(g[v], []).append(v)
    return [groups[q] for q in sorted(groups)]


def p4_section():
    res = dict(targets={}, grouping={}, generic={})
    specs = dict(f7_05=("dlheld7", 0, +1, "[B mod 3 != 0]", [1] * 14),
                 h6_00=("dlheld6", 1, +1, "[B mod 3 != 1]", [1] * 8 + [-1] * 4 + [1]),
                 fd_10=("dlfamdev", 0, -1, "[B mod 3 == 0]", [1, 1, 1, 1, -1, -1, 1, 1, 1, 1]))
    for t, (suite, rho, sign, desc, eps) in specs.items():
        T = H.targets(suite); spec = T[t]; R = list(spec["relevant"]); k = len(R)
        g = lambda b, rho=rho, sign=sign: sign * (1 - 2 * (b % 3 == rho))
        a = krawtchouk_coeffs(g, k)
        W = [C(k, j) * a[j] * a[j] for j in range(k + 1)]
        Wfw, h, deg = fwht_weights(spec["fn"], R)
        cf = [mod3_closed_form(k, rho, sign, j) for j in range(1, k + 1)]
        nz = sum(C(k, j) for j in range(1, k + 1) if a[j] != 0)
        # the population pair-matrix signal and the noise (Heuristic BBP estimate of when its top eigenvector finds S)
        s2 = 1 - float(a[0]) ** 2; a2 = abs(float(a[2])); a1 = abs(float(a[1]))
        res["targets"][t] = dict(desc=desc, k=k, rho=rho, a=[str(x) for x in a[:4]], a_float=[float(x) for x in a[:4]],
                                 W={str(j): str(W[j]) for j in range(4)}, W_float={str(j): float(W[j]) for j in range(4)},
                                 W1W2=float(W[1] + W[2]), W1W2_part10_bound=0.0002, W_fwht={str(j): Wfw[j] for j in range(4)},
                                 exact_equals_fwht=all(abs(float(W[j]) - Wfw[j]) < 1e-15 for j in range(k + 1)),
                                 closed_form_max_abs_err=max(abs(float(a[j]) - cf[j - 1]) for j in range(1, k + 1)),
                                 nonzero_nonconstant_chars=nz, block_params=k + 1,
                                 W_peak_degree=int(max(range(k + 1), key=lambda j: W[j])),
                                 pair_snr_n16384=a2 * math.sqrt(16384) / math.sqrt(s2), single_snr_n16384=a1 * math.sqrt(16384) / math.sqrt(s2),
                                 n_bbp_heuristic=s2 * 30 / (a2 * a2 * (k - 1) ** 2),
                                 n_degree1_heuristic=2 * math.log(30) * s2 / (a1 * a1))
        # contiguous grouping: the large-n limit (counts proportional to C(k, B), mc = 0.005 n) and seed-0 data
        pB = {2 * b - k: C(k, b) for b in range(k + 1)}                    # t = 2B - k, weight C(k, B) / 2^k
        lim = grouping({v: c * 200 for v, c in pB.items()}, 2 ** k)      # counts 200 C(k,B), mc = 0.005 * 200 * 2^k exactly
        def irreducible(groups):
            e = Fraction(0)
            for G_ in groups:
                pp = sum(Fraction(pB[v], 2 ** k) for v in G_ if g((v + k) // 2) > 0)
                pm = sum(Fraction(pB[v], 2 ** k) for v in G_ if g((v + k) // 2) < 0)
                e += min(pp, pm)
            return e
        res["grouping"][t] = dict(eps=eps, limit_groups=lim, limit_irreducible_error=float(irreducible(lim)),
                                  limit_irreducible_error_exact=str(irreducible(lim)))
        # the seed-0 training rows at n = 16384, the block on the target's own signed sum (B counts eps_i x_i = +1)
        X, y = TH.train_data(spec["fn"], t, 0, 16384, 30)
        X = np.asarray(X, np.float64); y = np.asarray(y, np.float64)
        sg = np.asarray(eps, float)
        tv = X[:, R] @ sg
        Bv = np.rint((tv + k) / 2).astype(int)
        res["grouping"][t]["labels_equal_g_of_B"] = bool(np.all(np.array([g(b) for b in Bv]) == y))
        mc = max(3, int(DEF["sum_mc"] * 16384))
        vals, cnt = np.unique(tv, return_counts=True)
        gr = grouping({float(v): int(c) for v, c in zip(vals, cnt)}, mc)
        res["grouping"][t].update(n16384_mc=mc, n16384_groups=[[int(v) for v in G_] for G_ in gr],
                                  n16384_irreducible_error=float(irreducible([[int(v) for v in G_] for G_ in gr])))
        # numerical check of the representation lemma: singleton groups reproduce g(t) exactly by least squares
        blk = DM.SumBlock(np.arange(k), sg, False, (), np.array(sorted(set(tv)))[:-1] + 1.0)   # one group per value
        gidx = blk.group(X[:, R]); cnt = np.bincount(gidx, minlength=blk.ngroups())
        use = [v for v in range(blk.ngroups()) if cnt[v] > 0 and v != int(np.argmax(cnt))]    # as DFG adds them
        A = np.stack([np.ones(len(X))] + [(gidx == v).astype(float) for v in use], 1)
        w = np.linalg.lstsq(A, y, rcond=None)[0]
        res["grouping"][t]["singleton_ls_max_residual"] = float(np.max(np.abs(y - A @ w)))
        # the same with DFG's own grouping at this n: the best block-only least-squares fit and its sign's error
        blk2 = DM.SumBlock(np.arange(k), sg, False, (), DM._edges(tv, mc)); g2 = blk2.group(X[:, R])
        cnt2 = np.bincount(g2, minlength=blk2.ngroups()); use2 = [v for v in range(blk2.ngroups()) if cnt2[v] > 0 and v != int(np.argmax(cnt2))]
        A2 = np.stack([np.ones(len(X))] + [(g2 == v).astype(float) for v in use2], 1)
        w2 = np.linalg.lstsq(A2, y, rcond=None)[0]
        Xte, yte = TH.test_data(spec["fn"], t, 30); Xte = np.asarray(Xte, np.float64)
        g2te = blk2.group(Xte[:, R]); A2te = np.stack([np.ones(len(Xte))] + [(g2te == v).astype(float) for v in use2], 1)
        res["grouping"][t]["dfg_grouping_block_only_test_err"] = float(np.mean(np.where(A2te @ w2 > 0, 1.0, -1.0) != yte))
        res["grouping"][t]["dfg_grouping_n_groups"] = int(blk2.ngroups())
        res["grouping"][t]["singleton_n_features"] = int(A.shape[1])
    # generic: the largest k for which every value of t has its own group in the large-n limit
    gen = {}
    for k in range(2, 16):
        pB = {2 * b - k: C(k, b) for b in range(k + 1)}
        lim = grouping({v: c * 200 for v, c in pB.items()}, 2 ** k)
        gen[str(k)] = dict(groups=len(lim), values=k + 1, all_singletons=bool(len(lim) == k + 1))
    res["generic"] = gen
    res["generic_max_k_all_singletons"] = max(int(k) for k, v in gen.items() if v["all_singletons"])
    return res


# ------------------------------------------------------------------------------------------------ P5: compute
def exhaustive_flops(n, d):
    """FLOPs DFG's counter charges for the global degree-k search when it runs on all n points (m = n)."""
    k5 = (C(d, 3), C(d, 2)); k6 = (C(d, 3), C(d, 3))
    return {1: 2 * n * d, 2: 2 * n * d * d + n * d, 3: (d - 2) * (2 * n * d * d + 2 * n * d),
            4: C(d - 2, 2) * (2 * n * d * d + 3 * n * d),
            5: 2 * n * k5[0] * k5[1] + n * (k5[0] * 3 + k5[1] * 2), 6: 2 * n * k6[0] * k6[1] + n * (k6[0] * 3 + k6[1] * 3)}


def round0_search(n, d, scale, hi):
    f = {1: 2 * n * d, 2: 2 * n * d * d + n * d}
    m3 = m_k(3, n, d, scale); f[3] = (d - 2) * (2 * m3 * d * d + 2 * m3 * d) if m3 >= 32 else 0.0
    m4 = m_k(4, n, d, scale); f[4] = C(d - 2, 2) * (2 * m4 * d * d + 3 * m4 * d) if m4 >= 32 else 0.0
    for k in (5, 6):
        k1, k2 = (k + 1) // 2, k // 2; N1, N2 = C(d, k1), C(d, k2); m = m_k(k, n, d, scale)
        f[k] = (2 * m * N1 * N2 + m * (N1 * k1 + N2 * k2)) if (hi and m >= 64) else 0.0
    return f


def parity_path(n, d, k, scale, hi, linear=False):
    """FLOPs of one DFG._fit call whose round 0 admits chi_S alone (|S| = k; with linear=True also the linear block,
    d more features) and whose round 1 stops on the sign rule."""
    f = 2 * n + 1 / 3 + 4 * n
    f += sum(round0_search(n, d, scale, hi).values())
    f += 10 * d ** 3
    if n >= DEF["sum_nmin"]:
        f += 2 * n * 4 + 4 * n * 2 + 8
    f += n * k
    p = 2 + (d if linear else 0)
    f += 2 * n * p * p + p ** 3 / 3 + 4 * n * p
    if n >= 8 * p:
        f += 15 * (2 * n * p * p + p ** 3 / 3 + 8 * n * p)
    f += 2 * n * d
    return f


def fit_total(n, d, k, lin_fold=None, lin_final=False):
    if n > DEF["cv_n"]:
        return parity_path(n, d, k, 1.0, True, lin_final)
    F = 10 if n <= 64 else 5
    folds = [n - math.ceil((n - f) / F) for f in range(F)]
    tot = 0.0
    for f, nf in enumerate(folds):
        tot += 2 * parity_path(nf, d, k, 1 / (4 * F), False, linear=(lin_fold == f))
    return tot + parity_path(n, d, k, 0.5, True, lin_final)


def p5_section():
    res = dict(m_table={}, d_star={}, exhaustive={}, check={}, decomposition={})
    for d in (15, 30, 60, 120):
        res["m_table"][str(d)] = {f"m{k}": {f"scale{sc}": m_k(k, 10 ** 9, d, sc) for sc in (1.0, 0.5, 1 / 20, 1 / 40)}
                                  for k in (3, 4, 5, 6)}
    # the smallest d at which the degree-4 search is subsampled (m_4 < n) or skipped (m_4 < 32)
    for sc, lab in ((1.0, "final_n_gt_512"), (0.5, "final_n_le_512"), (1 / 20, "fold_5"), (1 / 40, "fold_10")):
        dd = {}
        for n in NS + ["skip32"]:
            for d in range(5, 3001):
                m = m_k(4, 10 ** 9, d, sc)
                if (n == "skip32" and m < 32) or (n != "skip32" and m < n):
                    dd[str(n)] = d; break
        res["d_star"][lab] = dd
    res["d_star_deg3_skip32_final"] = next(d for d in range(5, 5000) if m_k(3, 10 ** 9, d, 1.0) < 32)
    for d in (15, 30, 60, 120, 1000):
        GD = TH.gd_flops(d)
        res["exhaustive"][str(d)] = {str(n): {str(k): v / GD for k, v in exhaustive_flops(n, d).items()} for n in (64, 1024, 16384)}
    # bound: the actual degree-k search cost never exceeds its share (the per-point estimate is >= the true per-point cost)
    worst = 0.0
    for d in range(5, 400):
        for sc in (1.0, 0.5, 1 / 20, 1 / 40):
            GD = TH.gd_flops(d) * sc
            f = round0_search(10 ** 9, d, sc, True)
            worst = max(worst, f[3] / (BUD[1] * GD), f[4] / (BUD[0] * GD), f[5] / (BUDHI * GD), f[6] / (BUDHI * GD))
    res["max_share_used_over_share"] = worst
    # the parity-path FLOP model against the result files
    tot = ok = ok_lin = 0; bad = []; small = 0
    for d in (15, 30, 60, 120):
        R = rfile(dsuite(d))
        for t, k in (("par2", 2), ("par3", 3), ("par4", 4)):
            if t not in R["fns"]:
                continue
            Fl = np.array(R["fns"][t]["flops"])
            for a, n in enumerate(R["ns"]):
                pred = fit_total(n, d, k)
                for b, s in enumerate(R["seeds"]):
                    tot += 1; rel = abs(Fl[a, b] - pred) / Fl[a, b]
                    if rel < 1e-9:
                        ok += 1; continue
                    alts = [fit_total(n, d, k, lin_final=True)] + ([fit_total(n, d, k, lin_fold=f) for f in range(10 if n <= 64 else 5)]
                                                                  if n <= DEF["cv_n"] else [])
                    if any(abs(Fl[a, b] - v) / Fl[a, b] < 1e-9 for v in alts):
                        ok_lin += 1; bad.append(dict(d=d, t=t, n=n, seed=s, path="linear block admitted with chi_S")); continue
                    small += int(n <= 32)
                    bad.append(dict(d=d, t=t, n=n, seed=s, ratio=float(Fl[a, b] / pred), path="other"))
    res["check"] = dict(cells=tot, exact_parity_path=ok, exact_with_linear_block=ok_lin, other=tot - ok - ok_lin,
                        other_at_n_le_32=small, details=bad)
    for d in (15, 30, 60, 120):
        GD = TH.gd_flops(d); n = 16384
        f = round0_search(n, d, 1.0, True); tot_ = parity_path(n, d, 2, 1.0, True)
        R = rfile(dsuite(d)); rec = R["fns"]["par2"]["flops"][R["ns"].index(n)][0]
        res["decomposition"][str(d)] = dict(total_over_GD=tot_ / GD, recorded_over_GD=rec / GD,
                                            **{f"deg{k}_over_GD": f[k] / GD for k in f},
                                            m3=m_k(3, n, d, 1.0), m4=m_k(4, n, d, 1.0), m5=m_k(5, n, d, 1.0), m6=m_k(6, n, d, 1.0))
    return res


def main():
    fast = "--fast" in sys.argv
    t0 = time.time()
    OUT["code"] = code_section(); print("code", OUT["code"]["md5"], flush=True)
    OUT["P5"] = p5_section(); print("P5 check", {k: v for k, v in OUT["P5"]["check"].items() if k != "details"}, flush=True)
    OUT["P4"] = p4_section(); print("P4", {t: (v["W_float"], v["W1W2"]) for t, v in OUT["P4"]["targets"].items()}, flush=True)
    OUT["P2"] = p2_section(); print("P2 agree", OUT["P2"]["agree"], flush=True)
    OUT["P3"] = p3_section(); print("P3", OUT["P3"]["first"]["counts"], OUT["P3"]["test0"]["tp"], OUT["P3"]["test0"]["tn"],
                                    OUT["P3"]["test0"]["fp"], OUT["P3"]["test0"]["fn"], flush=True)
    OUT["P1"] = p1_section(fast); print("P1 violations", OUT["P1"]["violations_char"], OUT["P1"]["violations_linear"], flush=True)
    OUT["wall_seconds"] = time.time() - t0
    json.dump(OUT, open(os.path.join(HERE, "check_theory.json"), "w"), indent=1, default=float)
    print("wrote check_theory.json", round(OUT["wall_seconds"]), "s")


if __name__ == "__main__":
    main()

"""Tables for CALIB.md from calib.py's records (results/noise.jsonl, spur.jsonl, prof.jsonl) and from the evaluation's
result files (part11/results/toy__dfg13-perm__<suite>.json); writes calib.json and calib_tables.txt (the markdown
tables CALIB.md quotes).  Also a null Monte Carlo of DFG's two dense block statistics on pure noise in round 0 (the
linear block's chi^2 statistic and the spectral block's top eigenvalue over its edge), computed as dfg13.py does.

usage: OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python calib_summary.py
"""
import os, sys, json, math, glob
import numpy as np
from scipy import stats

HERE = os.path.dirname(os.path.abspath(__file__)); P11 = os.path.dirname(os.path.dirname(HERE)); RES = os.path.join(HERE, "results")
STUDY = os.path.dirname(P11)
NS = [2 ** k for k in range(4, 15)]
DELTA, K = 0.1, 4
CLS = ["g1", "g2", "g3", "g4", "g5", "g6", "ext1", "ext2", "local"]
SUMK = ["add0", "add1", "prod", "split", "mod"]


def gd_flops(d):
    """harness.gd_flops (one network run), imported from the toy harness."""
    if os.path.join(STUDY, "discrete_learner") not in sys.path:
        sys.path.insert(0, os.path.join(STUDY, "discrete_learner"))
    import harness
    return float(harness.gd_flops(d))


# ------------------------------------------------------------------------------------------------ round-0 search cost
def round0_flops(d, n, scale=1.0, hi=True, budget=(0.15, 0.03, 0.03), budget_hi=0.03):
    """The FLOP-counter increments of one search round of DFG._fit's global character search, read off dfg13.py
    (multiply-add = 2): degree 1 c1 = X^T r / n (2nd); degree 2 the pair matrix M (2nd^2 + nd); degree 3 the d - 2
    matrices Ma on m3 rows (2 m d^2 + 2 m d each, skipped if m3 < 32); degree 4 the C(d-2, 2) matrices Mab on m4 rows
    (b < d - 2; 2 m d^2 + 3 m d each, skipped if m4 < 32); degrees 5 and 6 (round 0 with hi only) one product of
    character tables on m rows, 2 m N1 N2 + m (N1 k1 + N2 k2), skipped if m < 64.  The m's are min(n, budget share *
    gd_flops(d) * scale / cost per row).  Degrees 1-3 run in every round (K_later = 3), degrees 4-6 in round 0 only."""
    GD = gd_flops(d) * scale; out, m_ = {}, {}
    out["g1"] = 2.0 * n * d; out["g2"] = 2.0 * n * d * d + n * d
    m3 = min(n, int(budget[1] * GD / (d * (2 * d * d + 2 * d)))); m_["g3"] = m3
    out["g3"] = (d - 2) * (2.0 * m3 * d * d + 2.0 * m3 * d) if m3 >= 32 else 0.0
    m4 = min(n, int(budget[0] * GD / (math.comb(d, 2) * (2 * d * d + 3 * d)))); m_["g4"] = m4
    out["g4"] = math.comb(d - 2, 2) * (2.0 * m4 * d * d + 3.0 * m4 * d) if m4 >= 32 else 0.0
    for k in (5, 6):
        k1, k2 = (k + 1) // 2, k // 2; N1, N2 = math.comb(d, k1), math.comb(d, k2)
        per = 2 * N1 * N2 + (N1 * k1 + N2 * k2)
        m = min(n, int(budget_hi * GD / per)); m_[f"g{k}"] = m
        out[f"g{k}"] = float(m * per) if (hi and m >= 64) else 0.0
    return out, m_


def derived(noise, tests):
    """Numbers CALIB.md derives rather than measures: the network-run unit, the linear block's threshold and its exact
    chi^2 tail, the subsample sizes and FLOPs of the round-0 search (from round0_flops), the round-0 search as a share
    of one network run, the sum-block union bound, the test sets' label rates, and the kernel background's predicted
    P(predict -1) with the error identity err = a + q (1 - 2a) on biased noise (a = test minority rate, q = P(predict
    -1); exact when the predictions are independent of the test labels)."""
    out = {"gd": {str(d): gd_flops(d) for d in (15, 30, 60, 120)}}
    tt = math.log(1 / DELTA)
    out["lin"] = {}
    for d in (30, 60):
        thr = d + 2 * math.sqrt(d * tt) + 2 * tt
        out["lin"][str(d)] = dict(thr=thr, chi2_tail=float(stats.chi2.sf(thr, d)), lm_level=math.exp(-tt))
    out["sum_union"] = dict(additive_bound=DELTA / (4 * K), sizes=list(range(2, 25)),
                            sum_over_sizes=23 * DELTA / (4 * K * 24))
    # the round-0 search: subsample sizes by d and budget scale, per-row cost of degrees 1-4 at d = 30, shares of GD
    sub = {}
    for d in (15, 30, 60, 120):
        for sc in (1.0, 0.5):
            _, m_ = round0_flops(d, 10 ** 9, sc); sub[f"{d}:{sc}"] = m_
    out["subsample_m"] = sub
    f30, _ = round0_flops(30, 16384)
    out["per_row_deg1_4_d30"] = sum(f30[g] for g in ("g1", "g2", "g3", "g4")) / 16384
    out["per_row_by_deg_d30"] = {g: f30[g] / 16384 for g in ("g1", "g2", "g3", "g4")}
    out["deg56_flops_d30"] = {g: f30[g] for g in ("g5", "g6")}
    out["deg56_share_d30"] = {g: f30[g] / gd_flops(30) for g in ("g5", "g6")}
    out["round0_share_d30"] = {}
    for n in (64, 512, 1024, 4096, 16384):
        for sc in ((0.5,) if n <= 512 else (1.0,)):
            f, m_ = round0_flops(30, n, sc)
            out["round0_share_d30"][str(n)] = dict(scale=sc, share=sum(f.values()) / gd_flops(30), m=m_,
                                                   by_deg={g: v / gd_flops(30) for g, v in f.items()})
    out["deg4_binds_at_d30"] = round0_flops(30, 10 ** 9)[1]["g4"]
    # test sets' label rates (the noise test sets of calib.noise_test)
    out["test_minority"] = {k: v for k, v in tests.items()}
    # kernel background on biased noise (d = 30, p = 0.8): plug-in w0 = 0.6, s = 0.8, and the per-fit average with the
    # fit's own mean label (fits with no admitted feature only); and the error identity at the measured q
    a = tests["30:0.8"]["p_minus"]
    kb = {}
    for n in NS:
        L = [r for r in noise if r["d"] == 30 and r["p"] == 0.8 and r["n"] == n]
        if not L:
            continue
        plug = float(stats.norm.cdf(-0.6 * math.sqrt(n) / (0.8 * math.sqrt(30))))
        L0 = [r for r in L if not r["final"]["feats"]]
        per = [float(stats.norm.cdf(-abs(r["ybar"]) * math.sqrt(n) / (math.sqrt(max(1 - r["ybar"] ** 2, 1e-12)) * math.sqrt(30))))
               for r in L0]
        q = float(np.mean([r["frac_neg"] for r in L])); e = float(np.mean([r["err"] for r in L]))
        kb[str(n)] = dict(plugin=plug, per_fit=float(np.mean(per)) if per else None, fits_no_feature=len(L0), q=q,
                          err=e, err_identity=a + q * (1 - 2 * a), ybar_mean=float(np.mean([r["ybar"] for r in L])))
    out["background_p08"] = dict(a=a, slope=1 - 2 * a, by_n=kb)
    return out


def load(name):
    p = os.path.join(RES, name); out = []
    if os.path.exists(p):
        for L in open(p):
            if L.strip():
                try:
                    out.append(json.loads(L))
                except json.JSONDecodeError:                     # a line still being written by a running job
                    pass
    return out


def cp(k, n, a=0.05):
    """Clopper-Pearson two-sided 95% interval for k successes in n."""
    lo = 0.0 if k == 0 else float(stats.beta.ppf(a / 2, k, n - k + 1))
    hi = 1.0 if k == n else float(stats.beta.ppf(1 - a / 2, k + 1, n - k))
    return lo, hi


def rate(k, n):
    if n == 0:
        return "-"
    lo, hi = cp(k, n)
    return f"{k}/{n}" + (f" (95% <= {hi:.3f})" if k == 0 else f" ({lo:.3f}-{hi:.3f})")


# ------------------------------------------------------------------------------------------------ nominal levels
def nominal(d):
    """Round-0 global character classes of degree k: N = C(d, k) candidates, threshold z = sqrt(2 ln(4 K N / delta)) in
    units of rms(r) / sqrt(m) (c = 1); Hoeffding + union bound 2 N exp(-z^2 / 2) = delta / (2K); the independent-
    Gaussian approximation 1 - (1 - 2 Phi(-z))^N; and median / 95th percentile of max_S |Z_S| / z for N independent
    N(0, 1) (a reference only: with N >> m the N statistics are dependent and their maximum is smaller)."""
    out = {}
    for k in range(1, 7):
        N = math.comb(d, k); L = math.log(4 * K * N / DELTA); z = math.sqrt(2 * L)
        p1 = 2 * stats.norm.sf(z); pg = -math.expm1(N * math.log1p(-p1))
        q = lambda u: float(stats.norm.isf(-math.expm1(math.log(u) / N) / 2) / z)
        out[f"g{k}"] = dict(N=N, z=z, hoeffding=2 * N * math.exp(-L), gauss=pg, med_ratio=q(0.5), q95_ratio=q(0.95))
    return out


# ------------------------------------------------------------------------------------------------ null Monte Carlo
def mc_blocks(d, p, ns, reps, seed=123):
    """Round 0 on pure noise (residual r = y - mean(y), s = rms(r)): the linear block's T1 = n |X^T r / n|^2 / s^2
    over k + 2 sqrt(k t) + 2 t (t = ln(1/delta), k = d inputs), and the spectral block's max |eigenvalue| of the
    residual pair matrix (diagonal removed) over 2 s sqrt(d/n) (1 + sqrt(2 ln(1/delta) / d)) (only n >= 4d)."""
    rng = np.random.default_rng([seed, d, int(100 * p)]); tt = math.log(1 / DELTA); res = {}
    thr_lin = d + 2 * math.sqrt(d * tt) + 2 * tt
    for n in ns:
        lin, quad = [], []
        for _ in range(reps):
            X = rng.choice([-1.0, 1.0], size=(n, d)); y = np.where(rng.random(n) < p, 1.0, -1.0)
            r = y - y.mean(); s = math.sqrt(max(np.mean(r * r), 1e-12))
            if s < 1e-6:
                continue
            c1 = X.T @ r / n; lin.append(n * float(np.sum(c1 ** 2)) / s ** 2 / thr_lin)
            if n >= 4 * d:
                M = (X * r[:, None]).T @ X / n; Ms = (M + M.T) / 2; np.fill_diagonal(Ms, 0.0)
                lam = np.linalg.eigvalsh(Ms); edge = 2 * s * math.sqrt(d / n) * (1 + math.sqrt(2 * math.log(1 / DELTA) / d))
                quad.append(float(np.max(np.abs(lam))) / edge)
        lin, quad = np.array(lin), np.array(quad)
        res[str(n)] = dict(reps=len(lin), lin_pass=int(np.sum(lin > 1)), lin_med=float(np.median(lin)),
                           quad_reps=len(quad), quad_pass=int(np.sum(quad > 1)) if len(quad) else None,
                           quad_med=float(np.median(quad)) if len(quad) else None,
                           quad_q99=float(np.quantile(quad, 0.99)) if len(quad) else None)
    res["lin_chi2_tail"] = float(stats.chi2.sf(thr_lin, d)); res["thr_lin"] = thr_lin
    return res


def mc_big(d, p, n, reps, seed=321):
    """A larger null sample of the cheap round-0 statistics at one n: the degree-1 and degree-2 character classes (their
    largest |v| sqrt(n) / s over the threshold sqrt(2 ln(4 K N / delta))), the linear block and the spectral block."""
    rng = np.random.default_rng([seed, d, int(100 * p), n]); tt = math.log(1 / DELTA)
    thr_lin = d + 2 * math.sqrt(d * tt) + 2 * tt
    z1, z2 = math.sqrt(2 * math.log(4 * K * d / DELTA)), math.sqrt(2 * math.log(4 * K * math.comb(d, 2) / DELTA))
    edge_f = 2 * math.sqrt(d / n) * (1 + math.sqrt(2 * math.log(1 / DELTA) / d)); iu = np.triu_indices(d, 1)
    g1, g2, lin, quad = [], [], [], []
    for _ in range(reps):
        X = rng.choice([-1.0, 1.0], size=(n, d)); y = np.where(rng.random(n) < p, 1.0, -1.0)
        r = y - y.mean(); s = math.sqrt(max(np.mean(r * r), 1e-12))
        if s < 1e-6:
            continue
        c1 = X.T @ r / n; M = (X * r[:, None]).T @ X / n
        g1.append(float(np.max(np.abs(c1))) * math.sqrt(n) / s / z1); g2.append(float(np.max(np.abs(M[iu]))) * math.sqrt(n) / s / z2)
        lin.append(n * float(np.sum(c1 ** 2)) / s ** 2 / thr_lin)
        if n >= 4 * d:
            Ms = (M + M.T) / 2; np.fill_diagonal(Ms, 0.0); quad.append(float(np.max(np.abs(np.linalg.eigvalsh(Ms)))) / (s * edge_f))
    out = dict(reps=len(g1))
    for nm, v in (("g1", g1), ("g2", g2), ("lin", lin), ("quad", quad)):
        v = np.array(v)
        out[nm] = None if not len(v) else dict(passes=int(np.sum(v > 1)), med=float(np.median(v)), q99=float(np.quantile(v, 0.99)),
                                              max=float(v.max()))
    return out


# ------------------------------------------------------------------------------------------------ (A1)
def _kinds(feats):
    """Admission kinds present in a fit: chi_<class>, chi_forced, linear (the linear block's characters), quad, sum,
    sum_forced."""
    ks = set()
    for k in feats:
        a = k.split(":")
        if a[0] == "chi":
            ks.add("linear" if a[1] == "linear" else ("chi_forced" if a[1] == "forced" else "chi_" + a[1]))
        elif a[0] == "sum":
            ks.add("sum_forced" if a[1].startswith("forced") else "sum")
        else:
            ks.add(a[0])
    return ks


def a1(recs):
    out = {"by_cell": {}, "by_class": {}, "blocks": {}, "folds": {}, "cascade": {}, "examples": []}
    groups = {}
    for r in recs:
        groups.setdefault((r["d"], r["p"], r["n"]), []).append(r)
    for (d, p, n), L in sorted(groups.items()):
        nf = len(L); feats, blocks, ev = {}, {}, {}
        for r in L:
            for k, v in r["final"]["feats"].items():
                feats[k] = feats.get(k, 0) + v
            for k, v in r["final"]["blocks"].items():
                blocks[k] = blocks.get(k, 0) + v
            for kd in _kinds(r["final"]["feats"]):
                ev[kd] = ev.get(kd, 0) + 1
        tested = [r for r in L if _kinds(r["final"]["feats"]) - {"chi_forced", "sum_forced"}]
        errs = np.array([r["err"] for r in L])
        out["by_cell"][f"{d}:{p}:{n}"] = dict(
            d=d, p=p, n=n, fits=nf, any_feature=sum(1 for r in L if r["final"]["feats"]), any_tested=len(tested),
            forced_variant=sum(1 for r in L if r["variant"] == 1), cv_ran=sum(1 for r in L if r["cv_errs"] is not None),
            mean_feats={k: v / nf for k, v in sorted(feats.items())}, mean_blocks={k: v / nf for k, v in sorted(blocks.items())},
            fits_with=dict(sorted(ev.items())), rounds_mean=float(np.mean([r["final"]["rounds_done"] for r in L])),
            err_mean=float(errs.mean()), err_sd=float(errs.std(ddof=1)) if nf > 1 else 0.0, err_max=float(errs.max()),
            err_min=float(errs.min()), frac_neg_mean=float(np.mean([r["frac_neg"] for r in L])),
            err_with_feat=float(np.mean([r["err"] for r in L if r["final"]["feats"]])) if any(r["final"]["feats"] for r in L) else None,
            err_without=float(np.mean([r["err"] for r in L if not r["final"]["feats"]])) if any(not r["final"]["feats"] for r in L) else None,
            sd_admitted_mean=float(np.mean([r["sd_admitted"] for r in L])), sd_bg_mean=float(np.mean([r["sd_bg"] for r in L])),
            frozen_checked=sum(1 for r in L if "frozen" in r), frozen_equal=sum(1 for r in L if r.get("frozen", {}).get("equal")),
            cpu_mean=float(np.mean([r["cpu"] for r in L])), flops_max=float(max(r["flops"] for r in L) / L[0]["gd"]),
            stop={s: sum(1 for r in L if r["final"]["stop"] == s) for s in sorted(set(r["final"]["stop"] for r in L))})
    for (d, p) in sorted(set((r["d"], r["p"]) for r in recs)):
        L = [r for r in recs if r["d"] == d and r["p"] == p]
        # character classes: round 0 (residual independent of X) and later rounds
        for cl in CLS:
            for tag, sel in (("all", None),) + tuple((str(n), n) for n in NS):
                ran, passed, z0, ran_r, passed_r = 0, 0, [], 0, 0
                for r in L:
                    if sel is not None and r["n"] != sel:
                        continue
                    for rd in r["final"]["rounds"]:
                        if cl in rd["cls"]:
                            if rd["rnd"] == 0:
                                ran += 1; passed += rd["cls"][cl][1] > 0; z0.append(rd["cls"][cl][0])
                            else:
                                ran_r += 1; passed_r += rd["cls"][cl][1] > 0
                if ran or ran_r:
                    z0 = np.array(z0)
                    out["by_class"][f"{d}:{p}:{cl}:{tag}"] = dict(
                        r0_ran=ran, r0_pass=int(passed), r0_med=float(np.median(z0)) if len(z0) else None,
                        r0_q95=float(np.quantile(z0, 0.95)) if len(z0) else None, r0_max=float(z0.max()) if len(z0) else None,
                        later_ran=ran_r, later_pass=int(passed_r))
        # block tests by n, round 0 and later rounds
        for nm in ["lin", "quad"] + [f"sum_{k}" for k in SUMK]:
            for tag, sel in (("all", None),) + tuple((str(n), n) for n in NS):
                for rtag in ("r0", "later"):
                    ran, ok, rat = 0, 0, []
                    for r in L:
                        if sel is not None and r["n"] != sel:
                            continue
                        for rd in r["final"]["rounds"]:
                            if (rd["rnd"] == 0) != (rtag == "r0"):
                                continue
                            if nm == "lin":
                                x = rd.get("lin")
                                if x is None or not x["room_ok"]:
                                    continue
                                ran += 1; ok += x["ratio"] > 1; rat.append(x["ratio"])
                            elif nm == "quad":
                                x = rd.get("quad")
                                if x is None or not x["n_ok"]:
                                    continue
                                ran += 1; ok += x["nq"] > 0; rat.append(x["ratio"])
                            else:
                                for b_ in rd["bs"]:
                                    if b_["kind"] == nm[4:] and b_["ratio"] is not None:
                                        ran += 1; ok += bool(b_["ok"]); rat.append(b_["ratio"])
                    if ran:
                        out["blocks"][f"{d}:{p}:{nm}:{tag}:{rtag}"] = dict(ran=ran, passed=int(ok), med=float(np.median(rat)),
                                                                          q95=float(np.quantile(rat, 0.95)), max=float(max(rat)))
        # cascades: fits whose final model admitted something in round 0 -> did later rounds admit more?
        r0adm = [r for r in L if r["final"]["rounds"] and r["final"]["rounds"][0]["added"]]
        out["cascade"][f"{d}:{p}"] = dict(fits=len(L), round0_admission=len(r0adm),
                                         later_admission=sum(1 for r in r0adm if len(r["final"]["rounds"]) > 1 and any(rd["added"] for rd in r["final"]["rounds"][1:])),
                                         rounds_hist={str(k): sum(1 for r in L if r["final"]["rounds_done"] == k) for k in range(9)})
        # fold fits (n <= 512): the default variant's fold fits are extra noise fits at ~ (F-1)/F n (hi = False)
        for n in NS:
            Ln = [r for r in L if r["n"] == n and r["folds"]]
            if not Ln:
                continue
            fd = [f for r in Ln for f in r["folds"] if not f["force"]]
            ff = [f for r in Ln for f in r["folds"] if f["force"]]
            out["folds"][f"{d}:{p}:{n}"] = dict(default_fits=len(fd), default_any=sum(1 for f in fd if f["feats"]),
                                                default_kinds={k: sum(1 for f in fd if k in _kinds(f["feats"])) for k in
                                                               sorted(set().union(*[_kinds(f["feats"]) for f in fd]))},
                                                forced_fits=len(ff),
                                                forced_tested_adm=sum(1 for f in ff if _kinds(f["feats"]) - {"chi_forced", "sum_forced"}))
    # every fit with a test-passed admission, briefly
    for r in recs:
        ks = _kinds(r["final"]["feats"]) - {"chi_forced", "sum_forced"}
        if ks:
            rd0 = r["final"]["rounds"]
            out["examples"].append(dict(key=r["key"], err=r["err"], variant=r["variant"], kinds=sorted(ks), feats=r["final"]["feats"],
                                        rounds=r["final"]["rounds_done"],
                                        tests=[dict(rnd=x["rnd"], acc=x["acc"], lin=None if x["lin"] is None else round(x["lin"]["ratio"], 3),
                                                    quad=None if x["quad"] is None else round(x["quad"]["ratio"], 3),
                                                    passed={c: v[1] for c, v in x["cls"].items() if v[1]},
                                                    bs=[(b_["kind"], round(b_["ratio"], 3), b_["ok"]) for b_ in x["bs"] if b_["ok"]])
                                               for x in rd0]))
    return out


def cascade(recs):
    """The forced fold-fit check: DFG's own local-class passes after its forced characters, and the same local test
    (recomputed) after the forced characters and after random characters of the same degrees."""
    out = {}
    for (p, n) in sorted(set((r["p"], r["n"]) for r in recs)):
        L = [r for r in recs if r["p"] == p and r["n"] == n]
        dfg_local = sum(1 for r in L if any((x["npass"] or 0) > 0 for x in r["local"]))
        o = dict(fits=len(L), dfg_any_local_pass=dfg_local,
                 dfg_any_tested=sum(1 for r in L if any(not k.split(":")[1].startswith("forced") for k in r["feats"])),
                 forced_chars_only=sum(1 for r in L if r["control"] is not None))
        for k_ in ("1", "2"):
            C = [r["control"][k_] for r in L if r["control"] is not None and k_ in r["control"] and r["control"][k_]["forced_npass"] is not None]
            Cr = [r["control"][k_] for r in L if r["control"] is not None and k_ in r["control"] and r["control"][k_]["random_npass"] is not None]
            o[f"after{k_}"] = dict(tests_forced=len(C), pass_forced=sum(1 for c in C if c["forced_npass"] > 0),
                                   med_forced=float(np.median([c["forced_max"] for c in C])) if C else None,
                                   tests_random=len(Cr), pass_random=sum(1 for c in Cr if c["random_npass"] > 0),
                                   med_random=float(np.median([c["random_max"] for c in Cr])) if Cr else None)
        out[f"{p}:{n}"] = o
    return out


# ------------------------------------------------------------------------------------------------ (A2)
CATS = ["chi_test", "chi_lin", "chi_forced", "quad", "sum", "sum_forced"]


def a2(recs):
    out = {"by_n": {}, "relevant": {}, "top_cells": [], "top_terms": []}
    for r in recs:
        key = f"{r['suite']}:{r['target']}"
        if key not in out["relevant"]:
            out["relevant"][key] = dict(exact=r["rel"], suite=r["rel_suite"], same=sorted(r["rel"]) == sorted(r["rel_suite"]),
                                        extra_dep=r["extra_dep"])
    for n in NS:
        L = [r for r in recs if r["n"] == n]
        if not L:
            continue
        o = dict(fits=len(L), identical=sum(r["identical"] for r in L), n_learned=sum(r["err"] <= 0.1 for r in L))
        for sub, LL in (("all", L), ("learned", [r for r in L if r["err"] <= 0.1]), ("unlearned", [r for r in L if r["err"] > 0.1])):
            if not LL:
                o[sub] = None; continue
            nonlin = [[t for t in r["terms"] if t["spur"] and t["cat"] != "chi_lin"] for r in LL]
            q = dict(fits=len(LL), terms=sum(r["n_terms"] for r in LL), spur_terms=sum(r["n_spur"] for r in LL),
                     spur_terms_excl_lin=sum(len(x) for x in nonlin),
                     fits_any_spur=sum(r["n_spur"] > 0 for r in LL), fits_any_spur_excl_lin=sum(len(x) > 0 for x in nonlin),
                     by_cat={c: sum(r["cat"].get(c, {}).get("n", 0) for r in LL) for c in CATS},
                     fits_by_cat={c: sum(1 for r in LL if r["cat"].get(c, {}).get("n", 0)) for c in CATS},
                     share_med=float(np.median([r["share_spur"] for r in LL])), share_mean=float(np.mean([r["share_spur"] for r in LL])),
                     share_max=float(max(r["share_spur"] for r in LL)),
                     share_lin_max=float(max(r["cat"].get("chi_lin", {}).get("sd", 0.0) / max(r["sd_model"], 1e-300) for r in LL)),
                     share_excl_lin_max=float(max(max([r["cat"][c]["sd"] for c in r["cat"] if c != "chi_lin"] + [0.0]) / max(r["sd_model"], 1e-300) for r in LL)),
                     err_mean=float(np.mean([r["err"] for r in LL])), err_noS_mean=float(np.mean([r["err_noS"] for r in LL])),
                     noS_better=sum(r["err_noS"] < r["err"] for r in LL), noS_worse=sum(r["err_noS"] > r["err"] for r in LL),
                     variant_forced=sum(r["variant"] == 1 for r in LL))
            bycls = {}
            for r in LL:
                for t in r["terms"]:
                    if t["spur"] and t["cat"] == "chi_test":
                        bycls[t["origin"]] = bycls.get(t["origin"], 0) + 1
            q["chi_test_by_class"] = dict(sorted(bycls.items()))
            sk = {}
            for r in LL:
                for t in r["terms"]:
                    if t["spur"] and t["cat"] == "sum":
                        sk[t["origin"]] = sk.get(t["origin"], 0) + 1
            q["sum_by_kind"] = dict(sorted(sk.items()))
            o[sub] = q
        out["by_n"][str(n)] = o
    cells = sorted(recs, key=lambda r: -r["share_spur"])[:15]
    out["top_cells"] = [dict(cell=r["key"], err=r["err"], err_noS=r["err_noS"], share=r["share_spur"],
                             cats={k: v["n"] for k, v in r["cat"].items()}) for r in cells]
    terms = []
    for r in recs:
        for t in r["terms"]:
            if t["spur"] and t["cat"] != "chi_lin":
                terms.append(dict(rel_sd=t["sd"] / max(r["sd_model"], 1e-300), cell=r["key"], err=r["err"], cat=t["cat"],
                                  origin=t["origin"], S=t["S"], irr=t["irr"], desc=t.get("desc"), mass_rel=t.get("mass_rel")))
    terms.sort(key=lambda v: -v["rel_sd"])
    out["top_terms"] = terms[:30]; out["n_spur_terms_excl_lin"] = len(terms)
    out["spur_terms_excl_lin_by_cat"] = {c: sum(1 for t in terms if t["cat"] == c) for c in CATS}
    # spurious characters admitted individually, all n: which classes, how many irrelevant inputs
    ct = [t for t in terms if t["cat"] == "chi_test"]
    out["chi_test_spur"] = dict(n=len(ct), by_class={c: sum(1 for t in ct if t["origin"] == c) for c in sorted(set(t["origin"] for t in ct))},
                                by_deg={str(k): sum(1 for t in ct if len(t["S"]) == k) for k in range(1, 8)},
                                all_irrelevant=sum(1 for t in ct if len(t["irr"]) == len(t["S"])))
    return out


# ------------------------------------------------------------------------------------------------ (B)
GROUPS = [("deg 1", ["g1"]), ("deg 2 (pair matrix)", ["g2"]), ("deg 3", ["g3"]), ("deg 4", ["g4"]), ("deg 5 (subsample)", ["g5"]),
          ("deg 6 (subsample)", ["g6"]), ("extension", ["ext1", "ext2"]), ("local", ["local"]), ("linear block", ["lin"]),
          ("spectral block", ["quad"]),
          ("sum blocks", ["sum_setup", "sum_add", "sum_prod", "sum_split", "sum_cpair", "sum_mod", "sum_prev"]),
          ("least squares", ["ls"]), ("logistic readout", ["logit"]), ("other", ["init", "misc", "select", "add", "bg", "trainerr", "_end"])]
SUMR = GROUPS[10][1]


def _grp(reg):
    f = {g: sum(reg.get(nm, [0, 0, 0])[0] for nm in names) for g, names in GROUPS}
    c = {g: sum(reg.get(nm, [0, 0, 0])[1] for nm in names) for g, names in GROUPS}
    return f, c


def b(recs):
    out = {"cells": [], "rate": {}}
    by = {}
    for r in recs:
        by.setdefault(f"{r['suite']}:{r['target']}:{r['n']}", []).append(r)
    agg = {g: [0.0, 0.0] for g, _ in GROUPS}; aggcv = [0.0, 0.0]
    for key, RR in by.items():
        r0 = [r for r in RR if r.get("rep", 0) == 0][0]
        assert all(r["flops"] == r0["flops"] and r["err"] == r0["err"] for r in RR), key
        tf = r0["flops"]; fin0 = r0["calls"][-1]
        ff, _ = _grp(fin0["reg"])
        cvf = sum(c["flops"] for c in r0["calls"][:-1])
        # CPU: per repeat, then the median over repeats (per group)
        cpu_tot = [r["cpu"] for r in RR]
        gc = {g: [] for g, _ in GROUPS}; cvc, outc, sumc = [], [], {nm: [] for nm in SUMR}
        cvg = {g: [] for g, _ in GROUPS}; cvgf = {g: 0.0 for g, _ in GROUPS}
        for c_ in r0["calls"][:-1]:
            f_, _ = _grp(c_["reg"])
            for g in cvgf:
                cvgf[g] += f_[g]
        for r in RR:
            _, c = _grp(r["calls"][-1]["reg"])
            for g in gc:
                gc[g].append(c[g])
            acc = {g: 0.0 for g in cvg}
            for c_ in r["calls"][:-1]:
                _, cc = _grp(c_["reg"])
                for g in acc:
                    acc[g] += cc[g]
            for g in cvg:
                cvg[g].append(acc[g])
            cvc.append(sum(sum(v[1] for v in c_["reg"].values()) for c_ in r["calls"][:-1]))
            outc.append(r["cpu"] - sum(sum(v[1] for v in c_["reg"].values()) for c_ in r["calls"]))
            for nm in SUMR:
                sumc[nm].append(r["calls"][-1]["reg"].get(nm, [0, 0, 0])[1])
        med = lambda v: float(np.median(v))
        cpu = med(cpu_tot)
        for g in agg:
            agg[g][0] += ff[g]; agg[g][1] += med(gc[g])
        aggcv[0] += cvf; aggcv[1] += med(cvc)
        fl_check = sum(sum(v[0] for v in c_["reg"].values()) for c_ in r0["calls"])
        out["cells"].append(dict(cell=key, suite=r0["suite"], target=r0["target"], n=r0["n"], err=r0["err"], variant=r0["variant"],
                                 rounds=r0["rounds"], reps=len(RR), flops=tf, flops_gd=tf / r0["gd"], cpu_med=cpu,
                                 cpu_min=float(min(cpu_tot)), cpu_max=float(max(cpu_tot)),
                                 cpu_frozen=r0["frozen"]["cpu"], cpu_file=r0.get("cpu_file"), equal_frozen=r0["equal_frozen"],
                                 equal_file=r0.get("equal_file"), err_file=r0.get("err_file"),
                                 flops_share={g: v / tf for g, v in ff.items()}, cv_flops_share=cvf / tf,
                                 cpu_s={g: med(v) for g, v in gc.items()}, cv_cpu_s=med(cvc), outside_cpu_s=med(outc),
                                 cv_cpu_by_group={g: med(v) for g, v in cvg.items()}, cv_flops_by_group=cvgf,
                                 sum_flops={nm: fin0["reg"].get(nm, [0, 0, 0])[0] for nm in SUMR}, sum_cpu_s={nm: med(v) for nm, v in sumc.items()},
                                 flops_closure=abs(fl_check - tf) / tf, sub=fin0["sub"][0] if fin0["sub"] else {}, stop=fin0["stop"],
                                 n_calls=len(r0["calls"]), final_flops=fin0["flops"], final_scale=fin0["scale"]))
    out["rate"] = {g: dict(flops=v[0], cpu=v[1], gflops_per_s=(v[0] / v[1] / 1e9) if v[1] > 0 else None) for g, v in agg.items()}
    out["rate"]["cross-validation folds"] = dict(flops=aggcv[0], cpu=aggcv[1], gflops_per_s=aggcv[0] / aggcv[1] / 1e9 if aggcv[1] else None)
    return out


def files_table():
    """From the evaluation's result files: per suite and n, the number of fits, max and median FLOPs per fit over one
    network run (harness.gd_flops(d)), and median / max CPU seconds per fit (harness: process time around fit)."""
    out = {}
    for f in sorted(glob.glob(os.path.join(P11, "results", "toy__dfg13-perm__*.json"))):
        R = json.load(open(f)); suite = R["suite"]; gd = R["gd_flops"]
        fl = np.array([R["fns"][k]["flops"] for k in R["fns"]], dtype=float)
        cpu = np.array([R["fns"][k]["cpu_seconds"] for k in R["fns"]], dtype=float)
        rows = {}
        for a, n in enumerate(R["ns"]):
            x, c = fl[:, a, :].ravel() / gd, cpu[:, a, :].ravel()
            rows[str(n)] = dict(fits=int(np.sum(~np.isnan(x))), max_flops=float(np.nanmax(x)), med_flops=float(np.nanmedian(x)),
                                med_cpu=float(np.nanmedian(c)), max_cpu=float(np.nanmax(c)), mean_cpu=float(np.nanmean(c)))
        out[suite] = dict(d=R["d"], gd=gd, targets=len(R["fns"]), seeds=R["seeds"], rows=rows,
                          max_flops=float(np.nanmax(fl) / gd), fits=int(np.sum(~np.isnan(fl))), total_cpu=float(np.nansum(cpu)),
                          max_cpu=float(np.nanmax(cpu)), argmax_flops=[k for k in R["fns"] if np.nanmax(R["fns"][k]["flops"]) == np.nanmax(fl)][0])
    return out


# ------------------------------------------------------------------------------------------------ printing
def tables(res):
    T = []
    nom = res["nominal"]
    T += ["## Nominal levels of the round-0 character tests (delta = 0.1, K = 4, c = 1)", "",
          "| class | d | N | threshold z | Hoeffding x union bound | independent-Gaussian approx. | median / q95 of max\\|Z\\|/z (indep.) |", "|---|---|---|---|---|---|---|"]
    for d in ("30", "60"):
        for k, v in nom[d].items():
            T.append(f"| {k} | {d} | {v['N']} | {v['z']:.3f} | {v['hoeffding']:.4f} | {v['gauss']:.5f} | {v['med_ratio']:.3f} / {v['q95_ratio']:.3f} |")
    T.append("")
    T += ["## Null Monte Carlo of the dense block tests (round 0, pure noise)", "",
          "| d | P(y=1) | n | draws | linear block passes | median T1/thr | spectral passes | median / q99 of eig/edge |", "|---|---|---|---|---|---|---|---|"]
    for key, v in res["mc"].items():
        d, p = key.split(":")
        for n, w in v.items():
            if not n.isdigit():
                continue
            qs = "-" if w["quad_reps"] == 0 else f"{rate(w['quad_pass'], w['quad_reps'])}"
            qm = "-" if w["quad_reps"] == 0 else f"{w['quad_med']:.3f} / {w['quad_q99']:.3f}"
            T.append(f"| {d} | {p} | {n} | {w['reps']} | {rate(w['lin_pass'], w['reps'])} | {w['lin_med']:.3f} | {qs} | {qm} |")
        T.append(f"| {d} | {p} | chi^2_{d} tail at the threshold {v['thr_lin']:.2f}: {v['lin_chi2_tail']:.4f} | | | | | |")
    T.append("")
    T += ["## Null Monte Carlo, 20000 draws: round-0 degree-1 and degree-2 classes, linear and spectral blocks", "",
          "| d | P(y=1) | n | draws | deg-1 passes (median / q99 / max ratio) | deg-2 passes | linear passes | spectral passes |", "|---|---|---|---|---|---|---|---|"]
    for key, v in res.get("mc_big", {}).items():
        d, p, n = key.split(":")
        f = lambda w: "-" if w is None else f"{rate(w['passes'], v['reps'])} ({w['med']:.3f} / {w['q99']:.3f} / {w['max']:.3f})"
        T.append(f"| {d} | {p} | {n} | {v['reps']} | {f(v['g1'])} | {f(v['g2'])} | {f(v['lin'])} | {f(v['quad'])} |")
    T.append("")
    if "A1" in res:
        A = res["A1"]
        for (d, p) in sorted(set((v["d"], v["p"]) for v in A["by_cell"].values())):
            T += [f"## A1 by n: d = {d}, P(y = 1) = {p}", "",
                  "| n | fits | fits with any feature | CV chose forced | fits with a test-passed feature | admitted features per fit (kind: mean) | rounds (mean) | test error mean [min, max] | P(predict -1) | stop (fits) | frozen = instr |",
                  "|---|---|---|---|---|---|---|---|---|---|---|"]
            for v in sorted([v for v in A["by_cell"].values() if v["d"] == d and v["p"] == p], key=lambda v: v["n"]):
                mf = "; ".join(f"{k}: {x:.2f}" for k, x in v["mean_feats"].items()) or "-"
                st = ", ".join(f"{k} {x}" for k, x in v["stop"].items())
                T.append(f"| {v['n']} | {v['fits']} | {v['any_feature']} | {v['forced_variant']}" + (f"/{v['cv_ran']}" if v['cv_ran'] else "") +
                         f" | {v['any_tested']} | {mf} | {v['rounds_mean']:.2f} | {v['err_mean']:.3f} [{v['err_min']:.3f}, {v['err_max']:.3f}] | "
                         f"{v['frac_neg_mean']:.3f} | {st} | {v['frozen_equal']}/{v['frozen_checked']} |")
            T.append("")
            T += [f"### per class, round 0 (all n pooled): d = {d}, P(y = 1) = {p}", "",
                  "| class | round-0 tests | fits with >= 1 pass | median / q95 / max of max-ratio | later-round tests | later passes |", "|---|---|---|---|---|---|"]
            for cl in CLS:
                v = A["by_class"].get(f"{d}:{p}:{cl}:all")
                if v is None:
                    continue
                zz = "-" if v["r0_med"] is None else f"{v['r0_med']:.3f} / {v['r0_q95']:.3f} / {v['r0_max']:.3f}"
                T.append(f"| {cl} | {v['r0_ran']} | {rate(v['r0_pass'], v['r0_ran']) if v['r0_ran'] else '-'} | {zz} | {v['later_ran']} | {v['later_pass']} |")
            T.append("")
            T += [f"### round-0 max-ratio by n (median; fits with >= 1 pass / tests): d = {d}, P(y = 1) = {p}", "",
                  "| n | " + " | ".join(CLS[:6]) + " |", "|---|" + "---|" * 6]
            for n in NS:
                row = []
                for cl in CLS[:6]:
                    v = A["by_class"].get(f"{d}:{p}:{cl}:{n}")
                    row.append("-" if (v is None or v["r0_med"] is None) else f"{v['r0_med']:.3f} ({v['r0_pass']}/{v['r0_ran']})")
                T.append(f"| {n} | " + " | ".join(row) + " |")
            T.append("reference (independent Gaussian, median of max ratio): " + ", ".join(f"{k} {v['med_ratio']:.3f}" for k, v in nom[str(d)].items()))
            T.append("")
            T += [f"### block tests by n: d = {d}, P(y = 1) = {p} (round 0; later rounds in brackets: passed/ran)", "",
                  "| n | linear block | spectral block | sum add0 | sum add1 | sum prod | sum split | sum mod |", "|---|---|---|---|---|---|---|---|"]
            for n in NS:
                row = [str(n)]
                for nm in ["lin", "quad"] + [f"sum_{k}" for k in SUMK]:
                    v = A["blocks"].get(f"{d}:{p}:{nm}:{n}:r0"); w = A["blocks"].get(f"{d}:{p}:{nm}:{n}:later")
                    s_ = "-" if v is None else f"{v['passed']}/{v['ran']} (med {v['med']:.2f}, max {v['max']:.2f})"
                    if w is not None:
                        s_ += f" [{w['passed']}/{w['ran']}]"
                    row.append(s_)
                T.append("| " + " | ".join(row) + " |")
            T.append("")
            c = A["cascade"][f"{d}:{p}"]
            T.append(f"cascade d={d} p={p}: {c}")
            T.append("")
        T += ["### fold fits of the default variant (n <= 512)", "", "| d | P(y=1) | n | default fold fits | with any feature | kinds | forced fold fits with a test-passed feature |", "|---|---|---|---|---|---|---|"]
        for key, v in A["folds"].items():
            d, p, n = key.split(":")
            T.append(f"| {d} | {p} | {n} | {v['default_fits']} | {v['default_any']} | {v['default_kinds']} | {v['forced_tested_adm']}/{v['forced_fits']} |")
        T.append("")
        T += ["### every fit with a test-passed admission", ""]
        for e in A["examples"]:
            T.append(f"- {e['key']} err {e['err']:.3f} variant {e['variant']} rounds {e['rounds']} feats {e['feats']} tests {e['tests']}")
        T.append("")
    if "cascade" in res:
        T += ["## Forced fold fits on noise: local-class passes after forced characters, and the random-character control", "",
              "| P(y=1) | n | fits | DFG: a local pass | after 1st forced char: forced-V pass (median ratio) | random-V pass (median) | after 2nd: forced-V | random-V |",
              "|---|---|---|---|---|---|---|---|"]
        for key, o in res["cascade"].items():
            p_, n_ = key.split(":"); a, b_ = o["after1"], o["after2"]
            f = lambda k, n, m: "-" if n == 0 else f"{k}/{n} ({m:.2f})"
            T.append(f"| {p_} | {n_} | {o['fits']} | {o['dfg_any_local_pass']} | {f(a['pass_forced'], a['tests_forced'], a['med_forced'] or 0)} | "
                     f"{f(a['pass_random'], a['tests_random'], a['med_random'] or 0)} | {f(b_['pass_forced'], b_['tests_forced'], b_['med_forced'] or 0)} | "
                     f"{f(b_['pass_random'], b_['tests_random'], b_['med_random'] or 0)} |")
        T.append("")
    if "A2" in res:
        A = res["A2"]
        mism = {k: v for k, v in A["relevant"].items() if not v["same"] or v["extra_dep"]}
        T += ["## A2 relevant sets: exact vs the suites' lists", "", f"{len(A['relevant'])} targets; differ: {mism}", ""]
        T += ["## A2 by n (designed + random, seed 0)", "",
              "| n | fits | test err <= 0.1 | admitted terms | spurious terms (excl. linear-block chars) | fits with any spurious (excl. lin.) | spurious by kind: chi_test / chi_lin / chi_forced / quad / sum / sum_forced | spurious share median / mean / max | max share: lin. chars / other | test err with / without spurious (mean) | removal better / worse |",
              "|---|---|---|---|---|---|---|---|---|---|---|"]
        for n in NS:
            o = A["by_n"].get(str(n))
            if o is None:
                continue
            q = o["all"]; bc = q["by_cat"]
            T.append(f"| {n} | {q['fits']} | {o['n_learned']} | {q['terms']} | {q['spur_terms']} ({q['spur_terms_excl_lin']}) | {q['fits_any_spur']} ({q['fits_any_spur_excl_lin']}) | "
                     f"{bc['chi_test']} / {bc['chi_lin']} / {bc['chi_forced']} / {bc['quad']} / {bc['sum']} / {bc['sum_forced']} | "
                     f"{q['share_med']:.3f} / {q['share_mean']:.3f} / {q['share_max']:.3f} | {q['share_lin_max']:.3f} / {q['share_excl_lin_max']:.3f} | "
                     f"{q['err_mean']:.4f} / {q['err_noS_mean']:.4f} | {q['noS_better']} / {q['noS_worse']} |")
        T.append("")
        T += ["### A2 by n, cells with test error <= 0.1 only", "",
              "| n | fits | spurious terms (excl. lin.) | fits with any (excl. lin.) | spurious share median / max | max share: lin. / other | err with / without (mean) | removal better / worse |", "|---|---|---|---|---|---|---|---|"]
        for n in NS:
            o = A["by_n"].get(str(n))
            if o is None or not o.get("learned"):
                continue
            q = o["learned"]
            T.append(f"| {n} | {q['fits']} | {q['spur_terms']} ({q['spur_terms_excl_lin']}) | {q['fits_any_spur']} ({q['fits_any_spur_excl_lin']}) | {q['share_med']:.3f} / {q['share_max']:.3f} | "
                     f"{q['share_lin_max']:.3f} / {q['share_excl_lin_max']:.3f} | {q['err_mean']:.4f} / {q['err_noS_mean']:.4f} | {q['noS_better']} / {q['noS_worse']} |")
        T.append("")
        T.append(f"spurious individually tested chars by class per n: " + "; ".join(f"{n}: {A['by_n'][str(n)]['all']['chi_test_by_class']}" for n in NS if str(n) in A['by_n']))
        T.append(f"spurious sum blocks by kind per n: " + "; ".join(f"{n}: {A['by_n'][str(n)]['all']['sum_by_kind']}" for n in NS if str(n) in A['by_n']))
        T.append(f"spurious terms outside the linear block: {A['n_spur_terms_excl_lin']} {A['spur_terms_excl_lin_by_cat']}; chi_test: {A['chi_test_spur']}")
        T.append("")
        T += ["### largest spurious terms outside the linear block (sd of the term / sd of the model value)", ""]
        for t in A["top_terms"]:
            T.append(f"- {t['cell']} err {t['err']:.4f}: {t['cat']} ({t['origin']}) S={t['S']} irr={t['irr']} rel_sd={t['rel_sd']:.3f} {t['desc'] or ''}"
                     + (f" mass_rel={t['mass_rel']:.2f}" if t.get('mass_rel') is not None else ""))
        T.append("")
        T += ["### largest spurious shares (cells)", ""]
        for t in A["top_cells"]:
            T.append(f"- {t['cell']} err {t['err']:.4f} -> without spurious {t['err_noS']:.4f}; share {t['share']:.3f}; {t['cats']}")
        T.append("")
    if "B" in res:
        Bq = res["B"]; G = [g for g, _ in GROUPS]
        T += ["## B: share of each fit's FLOPs (final fit's regions + the cross-validation's fold fits)", "",
              "| target | n | test err | FLOPs / network run | " + " | ".join(G) + " | CV fold fits |", "|---|---|---|---|" + "---|" * (len(G) + 1)]
        for c in Bq["cells"]:
            T.append(f"| {c['target']} | {c['n']} | {c['err']:.4f} | {c['flops_gd']:.4f} | " + " | ".join(f"{100 * c['flops_share'][g]:.1f}" for g in G) + f" | {100 * c['cv_flops_share']:.1f} |")
        T.append("")
        T += ["## B: share of each fit's CPU time (median over repeats; final fit's regions + fold fits + outside _fit)", "",
              "| target | n | CPU s (median [min, max], reps) | " + " | ".join(G) + " | CV fold fits | outside _fit |", "|---|---|---|" + "---|" * (len(G) + 2)]
        for c in Bq["cells"]:
            tc = c["cpu_med"]
            T.append(f"| {c['target']} | {c['n']} | {tc:.2f} [{c['cpu_min']:.2f}, {c['cpu_max']:.2f}], {c['reps']} | " + " | ".join(f"{100 * c['cpu_s'][g] / tc:.1f}" for g in G) +
                     f" | {100 * c['cv_cpu_s'] / tc:.1f} | {100 * c['outside_cpu_s'] / tc:.1f} |")
        T.append("")
        T += ["## B: the cross-validation fold fits (n <= 512): their CPU seconds and FLOP shares by region", "",
              "| target | n | fold fits | CV CPU s | " + " | ".join(G) + " |", "|---|---|---|---|" + "---|" * len(G)]
        for c in Bq["cells"]:
            if c["n_calls"] <= 1:
                continue
            T.append(f"| {c['target']} | {c['n']} | {c['n_calls'] - 1} | {c['cv_cpu_s']:.2f} | " +
                     " | ".join(f"{100 * c['cv_cpu_by_group'][g] / max(c['cv_cpu_s'], 1e-9):.0f}% / {100 * c['cv_flops_by_group'][g] / max(sum(c['cv_flops_by_group'].values()), 1e-9):.0f}%" for g in G) + " |")
        T.append("")
        T += ["## B: FLOP rate by region (all profile fits pooled)", "", "| region | GFLOP | CPU s | GFLOP/s |", "|---|---|---|---|"]
        for g, v in Bq["rate"].items():
            T.append(f"| {g} | {v['flops'] / 1e9:.1f} | {v['cpu']:.1f} | " + ("-" if v["gflops_per_s"] is None else f"{v['gflops_per_s']:.2f}") + " |")
        T.append("")
        T += ["## B: sum-block sub-regions of the final fit (FLOP share of the fit, CPU s)", ""]
        for c in Bq["cells"]:
            T.append(f"- {c['target']} {c['n']}: " + ", ".join(f"{nm} {100 * c['sum_flops'][nm] / c['flops']:.1f}% / {c['sum_cpu_s'][nm]:.2f}s" for nm in SUMR if c['sum_flops'][nm] or c['sum_cpu_s'][nm] > 0.005))
        T.append("")
        T += ["## B: subsample sizes m of the final fit's round 0, and identity checks", ""]
        for c in Bq["cells"]:
            T.append(f"- {c['target']} {c['n']}: sub {c['sub']} scale {c['final_scale']} calls {c['n_calls']} stop {c['stop']} rounds {c['rounds']} "
                     f"equal_frozen {c['equal_frozen']} equal_file {c['equal_file']} closure {c['flops_closure']:.1e} cpu_file {c['cpu_file']}")
        T.append("")
    F = res["files"]
    T += ["## Result files: max FLOPs per fit / one network run, by n", "",
          "| suite | d | targets x seeds | " + " | ".join(str(n) for n in NS) + " | all |", "|---|---|---|" + "---|" * (len(NS) + 1)]
    for s, v in F.items():
        T.append(f"| {s} | {v['d']} | {v['targets']} x {len(v['seeds'])} | " + " | ".join(f"{v['rows'][str(n)]['max_flops']:.3f}" for n in NS) + f" | {v['max_flops']:.3f} ({v['argmax_flops']}) |")
    T.append("")
    T += ["## Result files: CPU seconds per fit, median (max), by n", "",
          "| suite | d | " + " | ".join(str(n) for n in NS) + " | max |", "|---|---|" + "---|" * (len(NS) + 1)]
    for s, v in F.items():
        T.append(f"| {s} | {v['d']} | " + " | ".join(f"{v['rows'][str(n)]['med_cpu']:.2f} ({v['rows'][str(n)]['max_cpu']:.1f})" for n in NS) + f" | {v['max_cpu']:.1f} |")
    T.append("")
    return "\n".join(T)


def main():
    noise, spur, prof = load("noise.jsonl"), load("spur.jsonl"), load("prof.jsonl")
    res = dict(nominal={str(d): nominal(d) for d in (30, 60)})
    res["mc"] = {} if os.environ.get("CALIB_NOMC") else {
        f"{d}:{p}": mc_blocks(d, p, [64, 128, 256, 512, 1024, 4096, 16384] if d == 30 else [64, 256, 512, 1024, 4096],
                              2000 if d == 30 else 1000) for d in (30, 60) for p in (0.5, 0.8)}
    res["mc_big"] = {} if os.environ.get("CALIB_NOMC") else {
        f"{d}:{p}:{n}": mc_big(d, p, n, 20000) for d, ns_ in ((30, (128, 1024)), (60, (256, 1024))) for p in (0.5, 0.8) for n in ns_}
    if noise:
        res["A1"] = a1(noise)
    casc = load("cascade.jsonl")
    if casc:
        res["cascade"] = cascade(casc)
    if spur:
        res["A2"] = a2(spur)
    if prof:
        res["B"] = b(prof)
    res["files"] = files_table()
    res["counts"] = dict(noise_fits=len(noise), spur_fits=len(spur), prof_records=len(prof))
    json.dump(res, open(os.path.join(HERE, "calib.json"), "w"), indent=1, default=float)
    txt = tables(res); open(os.path.join(HERE, "calib_tables.txt"), "w").write(txt + "\n")
    print(txt)


if __name__ == "__main__":
    main()

"""Tables for CALIB.md from calib.py's records (results/noise.jsonl, spur.jsonl, prof.jsonl) and from the evaluation's
result files (part11/results/toy__dfg13-perm__<suite>.json); writes calib.json and prints the tables (markdown).
Also two small null Monte Carlos of DFG's block statistics on pure noise (the linear block's chi^2 statistic and the
spectral block's top eigenvalue over its edge), computed exactly as dfg13.py computes them in round 0.

usage: OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python calib.py summarize      (or python calib_summary.py)
"""
import os, sys, json, math, glob
import numpy as np
from scipy import stats

HERE = os.path.dirname(os.path.abspath(__file__)); P11 = os.path.dirname(os.path.dirname(HERE)); RES = os.path.join(HERE, "results")
NS = [2 ** k for k in range(4, 15)]
DELTA, K = 0.1, 4
OUT = os.path.join(HERE, "calib.json")
CLS = ["g1", "g2", "g3", "g4", "g5", "g6", "ext1", "ext2", "local"]


def load(name):
    p = os.path.join(RES, name)
    return [json.loads(L) for L in open(p) if L.strip()] if os.path.exists(p) else []


def cp_upper(k, n, a=0.05):
    """Clopper-Pearson two-sided 95% interval."""
    lo = 0.0 if k == 0 else stats.beta.ppf(a / 2, k, n - k + 1)
    hi = 1.0 if k == n else stats.beta.ppf(1 - a / 2, k + 1, n - k)
    return lo, hi


def fmt_rate(k, n):
    lo, hi = cp_upper(k, n)
    return f"{k}/{n}" + (f" (<= {hi:.3f})" if k == 0 else f" ({lo:.3f}-{hi:.3f})")


# ------------------------------------------------------------------------------------------------ nominal levels
def nominal(d):
    """Round-0 character classes: candidate count N, threshold z (units of rms(r)/sqrt(m)), the Hoeffding + union bound
    2 N exp(-z^2/2) = delta / (2K), and the independent-Gaussian approximation 1 - (1 - 2 Phi(-z))^N; the median and
    95th percentile of max_S |Z_S| / z for N independent N(0,1) (a reference: with N >> m the statistics are dependent
    and the true maximum is smaller)."""
    out = {}
    for k in range(1, 7):
        N = math.comb(d, k); L = math.log(4 * K * N / DELTA); z = math.sqrt(2 * L)
        p1 = 2 * stats.norm.sf(z); pg = -math.expm1(N * math.log1p(-p1))
        q = lambda u: stats.norm.isf(-math.expm1(math.log(u) / N) / 2) / z
        out[f"g{k}"] = dict(N=N, z=z, hoeffding=2 * N * math.exp(-L), gauss=pg, med_ratio=q(0.5), q95_ratio=q(0.95))
    return out


# ------------------------------------------------------------------------------------------------ null Monte Carlos
def mc_blocks(d, p, ns, reps, seed=123):
    """Round 0 on pure noise: the linear block's T1 = n |c1|^2 / s^2 against k + 2 sqrt(k t) + 2 t (t = ln 1/delta,
    k = d), and the spectral block's max |eig| of the off-diagonal residual pair matrix over the edge
    2 s sqrt(d / n) (1 + sqrt(2 ln(1/delta) / d)) (n >= 4d).  As dfg13.py computes them (float64)."""
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
        res[n] = dict(reps=len(lin), lin_pass=int(np.sum(lin > 1)), lin_med=float(np.median(lin)),
                      quad_reps=len(quad), quad_pass=int(np.sum(quad > 1)) if len(quad) else None,
                      quad_med=float(np.median(quad)) if len(quad) else None,
                      quad_q99=float(np.quantile(quad, 0.99)) if len(quad) else None)
    res["lin_exact_chi2_tail"] = float(stats.chi2.sf(thr_lin, d))
    return res


# ------------------------------------------------------------------------------------------------ (A1)
def a1(recs):
    out = {"by_cell": {}, "by_class": {}, "blocks": {}, "folds": {}}
    groups = {}
    for r in recs:
        groups.setdefault((r["d"], r["p"], r["n"]), []).append(r)
    for (d, p, n), L in sorted(groups.items()):
        nf = len(L); anyadm = [r for r in L if any(not k.startswith("chi:forced") and not k.startswith("sum:forced") for k in r["final"]["feats"])]
        forced = [r for r in L if r["variant"] == 1]
        feats = {}
        for r in L:
            for k, v in r["final"]["feats"].items():
                feats[k] = feats.get(k, 0) + v
        blocks = {}
        for r in L:
            for k, v in r["final"]["blocks"].items():
                blocks[k] = blocks.get(k, 0) + v
        # admission EVENTS (test passes that entered the model): per kind, number of fits with >= 1
        ev = {}
        for r in L:
            kinds = set()
            for k in r["final"]["feats"]:
                kk = k.split(":")
                kinds.add("chi_" + kk[1] if kk[0] == "chi" else ("sum" if kk[0] == "sum" and not kk[1].startswith("forced") else
                                                               ("sum_forced" if kk[0] == "sum" else kk[0])))
            for kd in kinds:
                ev[kd] = ev.get(kd, 0) + 1
        errs = np.array([r["err"] for r in L])
        out["by_cell"][f"{d}:{p}:{n}"] = dict(
            d=d, p=p, n=n, fits=nf, any_admission=len(anyadm), any_feature=sum(1 for r in L if r["final"]["feats"]),
            forced_variant=len(forced), cv_ran=sum(1 for r in L if r["cv_errs"] is not None),
            mean_feats={k: v / nf for k, v in sorted(feats.items())}, blocks={k: v / nf for k, v in sorted(blocks.items())},
            fits_with=ev, rounds_mean=float(np.mean([r["final"]["rounds_done"] for r in L])),
            err_mean=float(errs.mean()), err_sd=float(errs.std(ddof=1)) if nf > 1 else 0.0, err_max=float(errs.max()),
            frac_neg_mean=float(np.mean([r["frac_neg"] for r in L])),
            sd_admitted_mean=float(np.mean([r["sd_admitted"] for r in L])), sd_bg_mean=float(np.mean([r["sd_bg"] for r in L])),
            frozen_checked=sum(1 for r in L if "frozen" in r), frozen_equal=sum(1 for r in L if r.get("frozen", {}).get("equal")),
            cpu_mean=float(np.mean([r["cpu"] for r in L])), flops_max=float(max(r["flops"] for r in L) / L[0]["gd"]),
            stop={s: sum(1 for r in L if r["final"]["stop"] == s) for s in set(r["final"]["stop"] for r in L)})
    # per class, per round index: fits where the class ran, fits with >= 1 pass, max-ratio quantiles (round 0)
    for (d, p) in sorted(set((r["d"], r["p"]) for r in recs)):
        L = [r for r in recs if r["d"] == d and r["p"] == p]
        for cl in CLS:
            ran, passed, z0, ran_r, passed_r = 0, 0, [], 0, 0
            for r in L:
                for rd in r["final"]["rounds"]:
                    if cl in rd["cls"]:
                        if rd["rnd"] == 0:
                            ran += 1; passed += rd["cls"][cl][1] > 0; z0.append(rd["cls"][cl][0])
                        else:
                            ran_r += 1; passed_r += rd["cls"][cl][1] > 0
            if ran or ran_r:
                z0 = np.array(z0)
                out["by_class"][f"{d}:{p}:{cl}"] = dict(round0_ran=ran, round0_pass=int(passed),
                                                       round0_med=float(np.median(z0)) if len(z0) else None,
                                                       round0_q95=float(np.quantile(z0, 0.95)) if len(z0) else None,
                                                       round0_max=float(z0.max()) if len(z0) else None,
                                                       later_ran=ran_r, later_pass=int(passed_r))
        # block tests, round 0 and later: linear, spectral, sum searches
        for nm in ("lin", "quad"):
            for rnd0 in (True, False):
                ran, ok, rat = 0, 0, []
                for r in L:
                    for rd in r["final"]["rounds"]:
                        if (rd["rnd"] == 0) != rnd0 or rd.get(nm) is None:
                            continue
                        x = rd[nm]
                        if nm == "lin":
                            if not x["room_ok"]:
                                continue
                            ran += 1; ok += x["ratio"] > 1; rat.append(x["ratio"])
                        else:
                            if not x["n_ok"]:
                                continue
                            ran += 1; ok += x["nq"] > 0; rat.append(x["ratio"])
                out["blocks"][f"{d}:{p}:{nm}:{'r0' if rnd0 else 'later'}"] = dict(
                    ran=ran, passed=int(ok), med=float(np.median(rat)) if rat else None, max=float(max(rat)) if rat else None)
        for kind in ("add0", "add1", "prod", "split", "mod"):
            for rnd0 in (True, False):
                ran, ok, rat = 0, 0, []
                for r in L:
                    for rd in r["final"]["rounds"]:
                        if (rd["rnd"] == 0) != rnd0:
                            continue
                        for b in rd["bs"]:
                            if b["kind"] == kind and b["ratio"] is not None:
                                ran += 1; ok += bool(b["ok"]); rat.append(b["ratio"])
                if ran:
                    out["blocks"][f"{d}:{p}:sum_{kind}:{'r0' if rnd0 else 'later'}"] = dict(
                        ran=ran, passed=int(ok), med=float(np.median(rat)), max=float(max(rat)))
        # fold fits of the default variant (n <= 512): extra noise fits at ~ (F-1)/F n, hi = False, small budget
        for n in NS:
            Ln = [r for r in L if r["n"] == n and r["folds"]]
            if not Ln:
                continue
            fd = [f for r in Ln for f in r["folds"] if not f["force"]]
            ff = [f for r in Ln for f in r["folds"] if f["force"]]
            out["folds"][f"{d}:{p}:{n}"] = dict(default_fits=len(fd), default_any=sum(1 for f in fd if f["feats"]),
                                                forced_fits=len(ff), forced_nonforced_adm=sum(
                                                    1 for f in ff if any(not k.split(":")[1].startswith("forced") for k in f["feats"])))
    return out


# ------------------------------------------------------------------------------------------------ (A2)
def a2(recs):
    out = {"by_n": {}, "relevant": {}, "top": []}
    for r in recs:
        key = f"{r['suite']}:{r['target']}"
        if key not in out["relevant"]:
            out["relevant"][key] = dict(exact=r["rel"], suite=r["rel_suite"], same=sorted(r["rel"]) == sorted(r["rel_suite"]),
                                        extra_dep=r["extra_dep"])
    cats = ["chi_test", "chi_lin", "chi_forced", "quad", "sum", "sum_forced"]
    for n in NS:
        L = [r for r in recs if r["n"] == n]
        if not L:
            continue
        o = dict(fits=len(L), identical=sum(r["identical"] for r in L), learned=sum(r["err"] <= 0.1 for r in L))
        for sub, LL in (("all", L), ("learned", [r for r in L if r["err"] <= 0.1]), ("unlearned", [r for r in L if r["err"] > 0.1])):
            if not LL:
                o[sub] = None; continue
            q = dict(fits=len(LL), terms=sum(r["n_terms"] for r in LL), spur_terms=sum(r["n_spur"] for r in LL),
                     fits_any_spur=sum(r["n_spur"] > 0 for r in LL),
                     fits_any_spur_excl_lin=sum(any(t["spur"] and t["cat"] != "chi_lin" for t in r["terms"]) for r in LL),
                     by_cat={c: sum(r["cat"].get(c, {}).get("n", 0) for r in LL) for c in cats},
                     fits_by_cat={c: sum(1 for r in LL if r["cat"].get(c, {}).get("n", 0)) for c in cats},
                     share_med=float(np.median([r["share_spur"] for r in LL])), share_mean=float(np.mean([r["share_spur"] for r in LL])),
                     share_max=float(max(r["share_spur"] for r in LL)),
                     share_excl_lin=[float(np.std(0)) for _ in ()],
                     err_mean=float(np.mean([r["err"] for r in LL])), err_noS_mean=float(np.mean([r["err_noS"] for r in LL])),
                     noS_better=sum(r["err_noS"] < r["err"] for r in LL), noS_worse=sum(r["err_noS"] > r["err"] for r in LL))
            # spurious characters admitted individually, by class
            bycls = {}
            for r in LL:
                for t in r["terms"]:
                    if t["spur"] and t["cat"] == "chi_test":
                        bycls[t["origin"]] = bycls.get(t["origin"], 0) + 1
            q["chi_test_by_class"] = bycls
            q.pop("share_excl_lin")
            o[sub] = q
        out["by_n"][n] = o
    # largest spurious shares (cells), and the largest single spurious terms outside the linear block
    cells = sorted(recs, key=lambda r: -r["share_spur"])[:15]
    out["top"] = [dict(cell=r["key"], err=r["err"], err_noS=r["err_noS"], share=r["share_spur"], cats={k: v["n"] for k, v in r["cat"].items()})
                  for r in cells]
    terms = []
    for r in recs:
        for t in r["terms"]:
            if t["spur"] and t["cat"] != "chi_lin":
                terms.append((t["sd"] / max(r["sd_model"], 1e-300), r["key"], t["cat"], t["origin"], t["S"], t["irr"], t.get("desc"), r["err"]))
    terms.sort(key=lambda v: -v[0])
    out["top_terms"] = [dict(rel_sd=v[0], cell=v[1], cat=v[2], origin=v[3], S=v[4], irr=v[5], desc=v[6], err=v[7]) for v in terms[:25]]
    out["n_spur_terms_excl_lin"] = len(terms)
    return out


# ------------------------------------------------------------------------------------------------ (B)
GROUPS = [("deg 1", ["g1"]), ("deg 2 (pair matrix)", ["g2"]), ("deg 3", ["g3"]), ("deg 4", ["g4"]), ("deg 5 (subsample)", ["g5"]),
          ("deg 6 (subsample)", ["g6"]), ("extension", ["ext1", "ext2"]), ("local", ["local"]), ("linear block", ["lin"]),
          ("spectral block", ["quad"]), ("sum blocks", ["sum_setup", "sum_add", "sum_prod", "sum_split", "sum_cpair", "sum_mod", "sum_prev"]),
          ("least squares", ["ls"]), ("logistic readout", ["logit"]), ("other", ["init", "misc", "select", "add", "bg", "trainerr", "_end"])]


def b(recs):
    out = {"cells": [], "rate": {}}
    agg = {g: [0.0, 0.0] for g, _ in GROUPS}
    for r in recs:
        fin = r["calls"][-1]; folds = r["calls"][:-1]
        tf, tc = r["flops"], r["cpu"]
        g_f, g_c = {}, {}
        for g, names in GROUPS:
            g_f[g] = sum(fin["reg"].get(nm, [0, 0, 0])[0] for nm in names)
            g_c[g] = sum(fin["reg"].get(nm, [0, 0, 0])[1] for nm in names)
            agg[g][0] += g_f[g]; agg[g][1] += g_c[g]
        cvf = sum(c["flops"] for c in folds); cvc = sum(sum(v[1] for v in c["reg"].values()) for c in folds)
        calls_c = sum(sum(v[1] for v in c["reg"].values()) for c in r["calls"])
        sum_sub = {nm: [fin["reg"].get(nm, [0, 0, 0])[0], fin["reg"].get(nm, [0, 0, 0])[1]] for nm in GROUPS[10][1]}
        fl_check = sum(sum(v[0] for v in c["reg"].values()) for c in r["calls"])
        out["cells"].append(dict(cell=r["key"], target=r["target"], n=r["n"], err=r["err"], variant=r["variant"], rounds=r["rounds"],
                                 flops_gd=tf / r["gd"], cpu=tc, cpu_frozen=r["frozen"]["cpu"], cpu_file=r.get("cpu_file"),
                                 equal_frozen=r["equal_frozen"], equal_file=r.get("equal_file"),
                                 final_flops_share={g: v / tf for g, v in g_f.items()}, final_cpu_share={g: v / tc for g, v in g_c.items()},
                                 cv_flops_share=cvf / tf, cv_cpu_share=cvc / tc, outside_calls_cpu_share=(tc - calls_c) / tc,
                                 sum_sub=sum_sub, flops_closure=abs(fl_check - tf) / tf,
                                 sub=fin["sub"][0] if fin["sub"] else {}, stop=fin["stop"], n_calls=len(r["calls"])))
    out["rate"] = {g: dict(flops=v[0], cpu=v[1], gflops_per_s=(v[0] / v[1] / 1e9) if v[1] > 0 else None) for g, v in agg.items()}
    return out


def files_table():
    """From the evaluation's result files: per suite and n, the number of fits, max and median FLOPs per fit as a
    fraction of one network run, and median / max CPU seconds per fit."""
    out = {}
    for f in sorted(glob.glob(os.path.join(P11, "results", "toy__dfg13-perm__*.json"))):
        R = json.load(open(f)); suite = R["suite"]; gd = R["gd_flops"]
        fl = np.array([R["fns"][k]["flops"] for k in R["fns"]], dtype=float)          # target x n x seed
        cpu = np.array([R["fns"][k]["cpu_seconds"] for k in R["fns"]], dtype=float)
        rows = {}
        for a, n in enumerate(R["ns"]):
            x, c = fl[:, a, :].ravel() / gd, cpu[:, a, :].ravel()
            rows[n] = dict(fits=int(np.sum(~np.isnan(x))), max_flops=float(np.nanmax(x)), med_flops=float(np.nanmedian(x)),
                           med_cpu=float(np.nanmedian(c)), max_cpu=float(np.nanmax(c)), mean_cpu=float(np.nanmean(c)))
        out[suite] = dict(d=R["d"], gd=gd, targets=len(R["fns"]), seeds=R["seeds"], rows=rows,
                          max_flops=float(np.nanmax(fl) / gd), total_cpu=float(np.nansum(cpu)))
    return out


# ------------------------------------------------------------------------------------------------ printing
def md_a1(A, nomd):
    L = []
    for (d, p) in sorted(set((v["d"], v["p"]) for v in A["by_cell"].values())):
        L += [f"#### d = {d}, P(y = 1) = {p}", "",
              "| n | fits | any admitted feature | of which forced (CV chose forced) | test-passed admission | mean admitted features (kind: per fit) | rounds (mean) | test error mean (max) | P(predict -1) | frozen checks equal |",
              "|---|---|---|---|---|---|---|---|---|---|"]
        for key, v in sorted(A["by_cell"].items(), key=lambda kv: kv[1]["n"]):
            if v["d"] != d or v["p"] != p:
                continue
            mf = ", ".join(f"{k}: {x:.2f}" for k, x in v["mean_feats"].items()) or "-"
            L.append(f"| {v['n']} | {v['fits']} | {v['any_feature']} | {v['forced_variant']} | {v['any_admission']} | {mf} | "
                     f"{v['rounds_mean']:.2f} | {v['err_mean']:.3f} ({v['err_max']:.3f}) | {v['frac_neg_mean']:.3f} | "
                     f"{v['frozen_equal']}/{v['frozen_checked']} |")
        L.append("")
    return "\n".join(L)


def main():
    noise, spur, prof = load("noise.jsonl"), load("spur.jsonl"), load("prof.jsonl")
    res = dict(nominal={d: nominal(d) for d in (30, 60)})
    res["mc"] = {f"{d}:{p}": mc_blocks(d, p, [64, 128, 256, 512, 1024, 4096, 16384] if d == 30 else [256, 512, 1024, 4096],
                                       2000 if d == 30 else 1000) for d in (30, 60) for p in (0.5, 0.8)}
    if noise:
        res["A1"] = a1(noise)
    if spur:
        res["A2"] = a2(spur)
    if prof:
        res["B"] = b(prof)
    res["files"] = files_table()
    json.dump(res, open(OUT, "w"), indent=1, default=float)
    if noise:
        print(md_a1(res["A1"], res["nominal"]))
    print("wrote", OUT)


if __name__ == "__main__":
    main()

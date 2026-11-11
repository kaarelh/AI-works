"""Dev tables for p9_gates (builder I1): the frozen learner's full dev evaluation (seed 0; n in {1000, 10000, 60000};
mnist, fashion_mnist, qd_dev) against the MLP references and the Part 8 portfolio v1 (hyb_portfolio) at the same cells.
usage: python compare_dev.py [learner-tag]   (default p9_gates-dev; reads standard_tasks/results/<tag>__<ds>.json)
mlp_best per cell = the lowest seed-mean test error over every MLP variant present (mlp, mlp_plus, mlp_unit, mlp_l2,
mlp_l2unit, mlp_strong, mlp_strong1) - hindsight, as in compare_hybrid.py.  Verdicts as in compare_hybrid.cells (> 10%
relative and > 2 s.e.; with one seed for the learner the s.e. is the seed spread of the reference, at least the
binomial test-set noise).  log2 ratios use max(err, 0.002)."""
import os, sys, json, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(os.path.dirname(HERE))
RES = os.path.join(STUDY, "standard_tasks", "results")
DS = ["mnist", "fashion_mnist", "qd_dev"]; NS = [1000, 10000, 60000]
VARIANTS = ("mlp", "mlp_plus", "mlp_unit", "mlp_l2", "mlp_l2unit", "mlp_strong", "mlp_strong1")
NTEST = 10000


def load(l, ds):
    p = os.path.join(RES, f"{l}__{ds}.json")
    return json.load(open(p)) if os.path.exists(p) else None


def cell(r, n, seed0=False):
    """(seed-mean error, seed errors) at n, or None."""
    if r is None or n not in r["ns"]:
        return None
    i = r["ns"].index(n)
    if i >= len(r["err"]):
        return None
    e = np.array(r["err"][i], float)
    if seed0:
        e = e[:1]
    e = e[np.isfinite(e)]
    return (float(e.mean()), e) if len(e) else None


def best(ds, n):
    out = None
    for v in VARIANTS:
        c = cell(load(v, ds), n)
        if c is not None and (out is None or c[0] < out[1][0]):
            out = (v, c)
    return out


def verdict(a, b_errs):
    b = float(np.mean(b_errs)); k = len(b_errs)
    se = np.sqrt(np.var(b_errs, ddof=1) / k) if k > 1 else 0.0
    se = max(se, np.sqrt(a * (1 - a) / NTEST + b * (1 - b) / NTEST))
    rel = (a - b) / max(b, 1e-3)
    return "better" if (rel < -0.1 and b - a > 2 * se) else ("worse" if (rel > 0.1 and a - b > 2 * se) else "tie")


def l2(a, b):
    return float(np.log2(max(a, 0.002) / max(b, 0.002)))


def main(tag):
    rows = []; lines = []
    hdr = "| dataset | n | mlp | mlp_l2unit | mlp_strong | mlp_strong1 | mlp_best (variant) | hgb | v1 seed 0 | v1 seed mean | **p9_gates** (seed 0) | log2 vs mlp_best | log2 vs mlp_strong | log2 vs v1 seed 0 | verdict vs mlp_best |"
    lines += [hdr, "|" + "---|" * 15]
    R = {}
    for ds in DS:
        for n in NS:
            me = cell(load(tag, ds), n)
            g = lambda l, s0=False: cell(load(l, ds), n, s0)
            f = lambda c: "–" if c is None else f"{c[0]:.4f}"
            bb = best(ds, n); v1s0 = g("hyb_portfolio", True); v1 = g("hyb_portfolio"); st = g("mlp_strong")
            r = dict(ds=ds, n=n, me=me[0] if me else None, best=bb[1][0] if bb else None, best_v=bb[0] if bb else None,
                     strong=st[0] if st else None, v1s0=v1s0[0] if v1s0 else None, v1=v1[0] if v1 else None)
            r["lr_best"] = l2(r["me"], r["best"]) if me and bb else None
            r["lr_strong"] = l2(r["me"], r["strong"]) if me and st else None
            r["lr_v1"] = l2(r["me"], r["v1s0"]) if me and v1s0 else None
            r["v1_lr_best"] = l2(r["v1s0"], r["best"]) if v1s0 and bb else None
            r["v1m_lr_best"] = l2(r["v1"], r["best"]) if v1 and bb else None
            r["verdict"] = verdict(r["me"], bb[1][1]) if me and bb else "–"
            R[(ds, n)] = r
            fm = lambda x: "–" if x is None else f"{x:+.2f}"
            lines.append(f"| {ds} | {n} | {f(g('mlp'))} | {f(g('mlp_l2unit'))} | {f(st)} | {f(g('mlp_strong1'))} | "
                         f"{f(bb[1]) if bb else '–'} ({bb[0] if bb else ''}) | {f(g('hgb'))} | {f(v1s0)} | {f(v1)} | **{f(me)}** | "
                         f"{fm(r['lr_best'])} | {fm(r['lr_strong'])} | {fm(r['lr_v1'])} | {r['verdict']} |")
    ok = [r for r in R.values() if r["lr_best"] is not None]
    lines.append("")
    if ok:
        lines.append(f"Cells with p9_gates and mlp_best: {len(ok)} of 9.  Mean log2(err / mlp_best err): p9_gates {np.mean([r['lr_best'] for r in ok]):+.3f}; "
                     f"v1 seed 0 on the same cells {np.mean([r['v1_lr_best'] for r in ok if r['v1_lr_best'] is not None]):+.3f} "
                     f"({sum(r['v1_lr_best'] is not None for r in ok)} cells); v1 seed mean {np.mean([r['v1m_lr_best'] for r in ok if r['v1m_lr_best'] is not None]):+.3f}.")
        s = [r for r in ok if r["lr_strong"] is not None]
        if s:
            lines.append(f"Mean log2(err / mlp_strong err) over {len(s)} cells: {np.mean([r['lr_strong'] for r in s]):+.3f}.")
        v = [r for r in ok if r["lr_v1"] is not None]
        if v:
            lines.append(f"Mean log2(err / v1 seed-0 err) over {len(v)} cells: {np.mean([r['lr_v1'] for r in v]):+.3f}.")
        lines.append("Verdicts vs mlp_best: " + ", ".join(f"{k} {sum(r['verdict'] == k for r in ok)}" for k in ("better", "tie", "worse")) + ".")
    print("\n".join(lines))


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "p9_gates-dev")

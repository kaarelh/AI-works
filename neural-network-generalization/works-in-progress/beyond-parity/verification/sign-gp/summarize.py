"""Aggregate results.jsonl over seeds -> summary.csv and summary.txt."""
import json, os, sys
from collections import defaultdict
import numpy as np
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from common import kernel_spectrum

_raw = os.path.join(HERE, "results.jsonl")
if not os.path.exists(_raw):  # the published package ships the raw rows compressed
    import gzip
    rows = [json.loads(l) for l in gzip.open(_raw + ".gz", "rt")]
else:
    rows = [json.loads(l) for l in open(_raw)]
prof = json.load(open(os.path.join(HERE, "targets.json")))
eps = json.load(open(os.path.join(HERE, "ptf_disagreement.json")))
ORDER = ["maj7", "and3", "stair4", "rand4", "leap1_td3", "cond_par3_maj3", "stair5", "parity2", "parity3", "parity4",
         "parity_full"]

g = defaultdict(list)
for r in rows:
    g[(r["d"], r["L"], r["target"], r["n"])].append(r)

keys = ["F", "gibbs", "vote_err", "F_unseen", "reg_sign_err", "reg_F", "reg_gibbs", "reg_l2_err"]
csv = ["d,L,target,n,seeds,n_distinct_mean," + ",".join(f"{k}_mean,{k}_sd" for k in keys) +
       ",max_dF_chains,max_abs_dq_chains,mean_frac_q_near_2_3,mean_bounces,max_abs_ac1"]
agg = {}
for (d, L, t, n), rs in sorted(g.items()):
    a = {k: (float(np.mean([r[k] for r in rs])), float(np.std([r[k] for r in rs], ddof=1)) if len(rs) > 1 else 0.0)
         for k in keys}
    a["seeds"] = len(rs)
    a["nd"] = float(np.mean([r["n_distinct"] for r in rs]))
    a["dF"] = max(abs(r["F_chainA"] - r["F_chainB"]) for r in rs)
    a["dq"] = max(r["max_abs_dq_chains"] for r in rs)
    a["near"] = float(np.mean([r["frac_q_near_2_3"] for r in rs]))
    a["bounces"] = float(np.mean([r["bounces_per_iter"] for r in rs]))
    a["ac1"] = max(abs(r["ac1"]) for r in rs)
    agg[(d, L, t, n)] = a
    csv.append(f"{d},{L},{t},{n},{len(rs)},{a['nd']:.1f}," + ",".join(f"{a[k][0]:.4f},{a[k][1]:.4f}" for k in keys) +
               f",{a['dF']:.4f},{a['dq']:.4f},{a['near']:.4f},{a['bounces']:.1f},{a['ac1']:.3f}")
open(os.path.join(HERE, "summary.csv"), "w").write("\n".join(csv) + "\n")

out = []
P = lambda *s: out.append(" ".join(str(x) for x in s))
P("Sign-conditioned GP (gamma<0 learner): K = Psi^{o(L-1)}((1+x.y)/(d+1)), q(x)=P{f(x)G(x)>0 | training signs}")
P("F = P_x{q<=2/3} over the full cube (observed points count as q=1); Gibbs = E_x[1-q]; vote = P_x{q<=1/2}.")
P("reg = ridgeless kernel regression on +-1 labels (NNGP mean): sign error, and F/Gibbs of Phi(f m/s).")
P("Entries: mean over seeds (sd in parentheses for F).  n = number of i.i.d. draws (distinct ones fewer).\n")
P("Target properties (junta on the first k coordinates):")
P(f"{'target':12s} {'k':>3s} {'mean':>6s} {'deg':>4s} {'thr':>4s} {'leap':>4s}  eps_r (min PTF disagreement, r=0,1,2,..)   "
  f"Fourier weight by degree 0..")
for t in ORDER:
    p = prof[f"{t}@d12"]
    e = eps.get(t, {})
    es = " ".join(f"{float(v['eps']):.3f}" for _, v in sorted(e.items(), key=lambda kv: int(kv[0]))) if e else \
        "(parity_d: thr=d)"
    w = " ".join(f"{x:.3f}" for x in p["fourier_weight_by_degree"][:8])
    P(f"{t:12s} {p['junta_size']:3d} {p['mean']:+6.2f} {p['fourier_degree']:4d} {p['threshold_degree']:4d} "
      f"{p['leap']:4d}  {es:40s} {w}")
P("")
for d in (10, 12):
    for L in (2, 3):
        lam, kh = kernel_spectrum(d, L)
        P(f"kernel d={d} L={L}: 2^d/lambda_j (inverse per-character eigenvalue) j=0..6: " +
          " ".join(f"{1 / x:.0f}" for x in kh[:7]))
P("")
for d in sorted({k[0] for k in agg}):
    for L in sorted({k[1] for k in agg if k[0] == d}):
        ns = sorted({k[3] for k in agg if k[0] == d and k[1] == L})
        P(f"==== d={d} L={L}   n grid: {ns}")
        for metric, label in [("F", "sign-GP confidence failure F"),
                              ("F_unseen", "sign-GP F restricted to unobserved x"), ("gibbs", "sign-GP Gibbs error"),
                              ("vote_err", "sign-GP vote error P{q<=1/2}"), ("reg_sign_err", "regression sign error"),
                              ("reg_F", "regression F (Phi(fm/s)<=2/3)"), ("reg_l2_err", "regression L2 error")]:
            P(f"-- {label}")
            P(f"{'target':12s} " + " ".join(f"{n:>11d}" for n in ns))
            for t in ORDER:
                cells = []
                for n in ns:
                    a = agg.get((d, L, t, n))
                    if a is None:
                        cells.append(f"{'-':>11s}")
                    elif metric == "F":
                        cells.append(f"{a['F'][0]:5.3f}({a['F'][1]:.2f})".rjust(11))
                    else:
                        cells.append(f"{a[metric][0]:11.3f}")
                P(f"{t:12s} " + " ".join(cells))
        P("-- MCMC diagnostics: max over seeds/targets of |F_chainA - F_chainB|, max|qA-qB|, max|lag-1 autocorr|")
        sub = [a for k, a in agg.items() if k[0] == d and k[1] == L]
        P(f"   max dF = {max(a['dF'] for a in sub):.4f}; max |dq| = {max(a['dq'] for a in sub):.4f}; "
          f"max |ac1| = {max(a['ac1'] for a in sub):.3f}; mean frac(|q-2/3|<0.02) = "
          f"{np.mean([a['near'] for a in sub]):.4f}")
        P("")
P("==== Compact sample-complexity table: first grid n with mean metric <= threshold ('>N' = not reached by the "
  "largest n run, N)")
P("     columns: sign-GP F<=0.1 | sign-GP F_unseen<=0.1 | sign-GP vote err<=0.05 | regression sign err<=0.05 | "
  "regression F<=0.1")
for d in sorted({k[0] for k in agg}):
    for L in sorted({k[1] for k in agg if k[0] == d}):
        P(f"-- d={d} L={L}")
        P(f"{'target':12s} {'deg':>3s} {'thr':>3s} {'leap':>4s} {'F<=.1':>7s} {'Fu<=.1':>7s} {'vote<=.05':>9s} "
          f"{'regsgn<=.05':>11s} {'regF<=.1':>8s}")
        for t in ORDER:
            ns = sorted(k[3] for k in agg if k[0] == d and k[1] == L and k[2] == t)
            if not ns:
                continue
            def first(metric, thr):
                for n in ns:
                    if agg[(d, L, t, n)][metric][0] <= thr:
                        return str(n)
                return f">{ns[-1]}"
            p = prof[f"{t}@d{d}"]
            P(f"{t:12s} {p['fourier_degree']:3d} {p['threshold_degree']:3d} {p['leap']:4d} {first('F', .1):>7s} "
              f"{first('F_unseen', .1):>7s} {first('vote_err', .05):>9s} {first('reg_sign_err', .05):>11s} "
              f"{first('reg_F', .1):>8s}")
open(os.path.join(HERE, "summary.txt"), "w").write("\n".join(out) + "\n")
print("\n".join(out))

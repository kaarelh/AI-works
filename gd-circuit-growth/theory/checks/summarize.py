"""Print the Markdown tables of Section 5 from eval_saved.json and sgd_short_*.json."""
import json, os, glob
import numpy as np
HERE = os.path.dirname(os.path.abspath(__file__))

OPT = os.environ.get("OPT", "adam")
rows = [r for r in (json.loads(l) for l in open(os.path.join(HERE, "eval_saved.json"))) if r.get("opt", "adam") == OPT]
fns = []
for r in rows:
    if r["fn"] not in fns:
        fns.append(r["fn"])
print("### Table 5.2 (means over 3 seeds; ranges in brackets where useful)\n")
print("| target | n | test err (actual) | path norm | B2.2 bound | $P_F$ | B2.3 bound | spectral $24\\varrho/n$ (init ref / zero ref) "
      "| KL (nats) | Gibbs train err | B3.2: $R(Q)\\le$ | disagreement | B3.2: deterministic $R(\\theta)\\le$ |")
print("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
for fn in fns:
    for n in [256, 2048, 16384]:
        rs = [r for r in rows if r["fn"] == fn and r["n"] == n]
        if not rs:
            continue
        m = lambda k: np.mean([r[k] for r in rs])
        rng = lambda k: f"{min(r[k] for r in rs):.2f}–{max(r[k] for r in rs):.2f}"
        print(f"| {fn} | {n} | {m('test_err'):.3f} | {m('path'):.0f} | {m('path_bound'):.2f} | {m('PF'):.1f} | {m('frob_bound'):.1f} "
              f"| {m('spec_uncapped_init'):.0f} / {m('spec_uncapped_zero'):.0f} | {m('pb_KL'):.0f} | {m('pb_gibbs'):.3f} | {m('pb_RQ'):.2f} "
              f"| {m('pb_dis'):.3f} | {m('pb_det'):.2f} ({rng('pb_det')}) |")
print()
print("KL split by group (W1,b1 | W2,b2 | a), mean over seeds, n = 16384:")
for fn in fns:
    rs = [r for r in rows if r["fn"] == fn and r["n"] == 16384]
    if rs:
        parts = np.mean([[d / (2 * s ** 2) for d, s in zip(r["dist2"], r["pb_sig"])] for r in rs], 0)
        sig = np.mean([r["pb_sig"] for r in rs], 0)
        dist = np.mean([np.sqrt(r["dist2"]) for r in rs], 0)
        print(f"  {fn:6s} KL parts {np.round(parts, 0)}   sigma {np.round(sig, 4)}   ||Delta_g|| {np.round(dist, 2)}  "
              f"norms W1 {np.mean([r['W1'] for r in rs]):.1f} W2 {np.mean([r['W2'] for r in rs]):.1f} a {np.mean([r['a'] for r in rs]):.2f}")

RO = os.path.join(HERE, "readoff.json" if OPT == "adam" else f"readoff_{OPT}.json")
if os.path.exists(RO):
    ro = [json.loads(l) for l in open(RO)]
    print("\n### Table 5.4: read-off certificate (Proposition 6.1), mean over seeds [max]\n")
    print("| target | n | test err (actual) | chosen k (coords) | train err of g | ln(1/pi) | bound on R(g) | disagreement | bound on R(f) |")
    print("|---|---|---|---|---|---|---|---|---|")
    for fn in dict.fromkeys(r["fn"] for r in ro):
        for n in [256, 2048, 16384]:
            rs = [r for r in ro if r["fn"] == fn and r["n"] == n]
            if not rs:
                continue
            m = lambda k: np.mean([r[k] for r in rs])
            ks = sorted(set((r["k"], tuple(r["coords"])) for r in rs))
            kstr = "; ".join(f"{k} {list(c)}" for k, c in ks)
            print(f"| {fn} | {n} | {m('test_err'):.3f} | {kstr} | {m('errS'):.3f} | {m('lnpi'):.1f} | {m('Rg'):.3f} | {m('dis'):.4f} "
                  f"| {m('bound'):.3f} [{max(r['bound'] for r in rs):.3f}] |")

for path in sorted(glob.glob(os.path.join(HERE, "sgd_short_*.json"))):
    S = json.load(open(path))
    print(f"\n### {os.path.basename(path)}: {S['mode']} on {S['fn']}, n={S['n']}, eta={S['eta']}, L0={S['L0']:.3f}; "
          f"descent-ratio quantiles (min,1%,median) = {S['desc_ratio_quantiles']}\n")
    if S["mode"] == "adam":
        print("| step | train err | test err | $\\|\\Delta\\|_{M^{-1}}$ | $S_K$ | max step ratio | KL measured | B3.2 $R(Q)$ | B3.2 det. | KL a priori (B3.3c) | B3.3c $R(Q)$ (det.) |")
        print("|---|---|---|---|---|---|---|---|---|---|---|")
        for r in S["records"]:
            if "pb_KL" not in r:
                continue
            print(f"| {r['step']} | {r['train_err']:.3f} | {r['test_err']:.3f} | {r['dist_M']:.2f} | {r['S_K']:.0f} | {r['max_step_ratio']:.2f} "
                  f"| {r['pb_KL']:.0f} | {r['pb_RQ']:.2f} | {r['pb_det']:.2f} | {r['pb_KL_adam']:.0f} | {r['pb_RQ_adam']:.2f} ({min(1, r['pb_RQ_adam'] + r['pb_det'] - r['pb_RQ']):.2f}) |")
    else:
        print("| step | $t$ | train err | test err | $\\|\\Delta\\|_{M^{-1}}$ | $\\Lambda$ | $\\sqrt{tE}$ | $\\sqrt{tL_0}$ | $P_F$ | B3.1 | "
              "KL measured | B3.2 $R(Q)$ | B3.2 det. | KL (B3.3b, energy) | $R(Q)$ | KL (B3.3a, flow) | $R(Q)$ (det.) |")
        print("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
        for r in S["records"]:
            pb = r.get("pb_KL")
            tail = (f"| {r['pb_KL']:.0f} | {r['pb_RQ']:.2f} | {r['pb_det']:.2f} | {r['pb_KL_energy']:.0f} | {r['pb_RQ_energy']:.2f} "
                    f"| {r['pb_KL_flow']:.0f} | {r['pb_RQ_flow']:.2f} ({min(1, r['pb_RQ_flow'] + r['pb_det'] - r['pb_RQ']):.2f}) |") if pb is not None else "| | | | | | | |"
            print(f"| {r['step']} | {r['t']:.0f} | {r['train_err']:.3f} | {r['test_err']:.3f} | {r['dist_M']:.2f} | {r['path_len']:.1f} "
                  f"| {r['sqrt_tE']:.1f} | {r['sqrt_tL0']:.1f} | {r['PF']:.0f} | {r['frob_apriori_bound']:.0f} " + tail)

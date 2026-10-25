"""Checks for revision 2 of ../B-nn-time-bounds.md (after referee round 1, referee_B_r1.json).
Runs in about a minute (forward passes only; no training, no PAC-Bayes search).

  1. Margin bounds on the final Adam networks (Sections 5.2, 5.5; referee minor 5, 6, 14):
     complexity at unit margin c = 2 kappa phi_grid / sqrt(n) for the path norm and P_F, the mean positive
     train margin, the vacuity criterion "c >= max(1, mean (y f)_+)  =>  B2.1 >= 1 at every gamma", the
     same bound with gamma_max = 1000 instead of 4, the path norm at initialization, and the c the path-norm
     bound would have if kappa_path were at its proven lower estimate 1.17.
  2. Full-batch GD at eta = 0.02: the 'flow' bound B3.3(a) with the measured running-minimum descent
     constant c_K instead of c = 1 (referee minor 2).
  3. Theorem B3.1: certified closed-form P^max against the old random-search value; the complexity term at
     unit margin at t = 0 (referee minor 3).
  4. Early stopping: B3.2 deterministic bounds per checkpoint and best-of values with a union bound over
     all evaluated checkpoints of both optimizers (referee minor 8).
  5. Theorem B3.3: growth of the energy E_K (b) and of the Adam KL (c) with K (referee major 1).
  6. Theorem B3.3(d) (new): constants of the a priori SGD versions (referee major 2).
  7. Miscellaneous numbers quoted in the revision (referee minors 6, 9, 13): Dudley extra term, Adam ratio
     over C_50, read-off disagreements and x1x2x3x4 certificates.
  8. Proposition B3.4 evaluated (referee minor 9): one-pass Adam (the study's online protocol: lr 1e-3,
     batch 64, muP multipliers) on x1, MAJ3 and x1x2x3, logging the progressive errors e_k; three windows of
     1000 steps fixed in advance (delta = 0.05 / 3 each), against the measured mean test error of the
     iterates in the window and the final network's test error.

usage: OPENBLAS_NUM_THREADS=1 RESULTS=<sweep output folder> python3 B_r2_checks.py > B_r2_checks.out
"""
import os, sys, json, math
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, "..", "..", "study"))
import numpy as np
import nnbounds as nb

RESULTS = os.environ.get("RESULTS", "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/results")
D = 31
KP, KF = nb.KAPPA_PATH(D), nb.KAPPA_FROB(D)
G = len(nb.SIG_GRID) ** 3

def grid(v, q=1.1):
    return q ** nb.grid_index(v, 1.0, q)

def J(path):
    return json.load(open(os.path.join(HERE, path)))

# ------------------------------------------------------------------------------------------------ 1
print("== 1. Margin bounds on the final Adam networks: complexity at unit margin ==")
rows = [json.loads(l) for l in open(os.path.join(HERE, "eval_saved.json"))]
have_nets = os.path.exists(os.path.join(RESULTS, "params_fixed_adam_dict.npz"))
if have_nets:
    import nn_train as nt
    import jax
print("   networks available for margins:", have_nets)
print(f"   {'fn':7s} {'n':>5s} {'seed':>4s} {'path':>6s} {'c_path':>7s} {'B2.2':>6s} {'g*':>5s} {'P_F':>6s} {'c_F':>6s} {'B2.3':>6s} "
      f"{'m+':>5s} {'minm':>6s} {'crit':>5s} {'B2.2@gmax1000':>13s} {'path(init)':>10s}")
cache = {}
allrows = []
for r in rows:
    n = r["n"]
    cp = 2 * KP * grid(r["path"]) / math.sqrt(n)
    cf = 2 * KF * grid(r["PF"]) / math.sqrt(n)
    mplus = minm = b1000 = p0path = float("nan")
    if have_nets:
        fn = r["fn"]
        if fn not in cache:
            P = np.load(os.path.join(RESULTS, f"params_fixed_adam_{fn}.npz"))
            R = np.load(os.path.join(RESULTS, f"fixed_adam_{fn}.npz"))
            cache[fn] = (P, R)
        P, R = cache[fn]
        seeds = list(R["seeds"])
        s = seeds.index(r["seed"])
        i = [k for k in range(len(R["net_n"])) if int(R["net_n"][k]) == n and int(R["net_s"][k]) == s][0]
        p = {k: P[k][i].astype(np.float32) for k in ["W1", "b1", "W2", "b2", "a"]}
        X, y = nt.make_data(fn, int(r["seed"]), int(R["ns"].max()))
        X, y = X[:n].astype(np.float32), y[:n].astype(np.float32)
        marg = y * nb.forward(p, X)
        mplus, minm = float(np.maximum(marg, 0).mean()), float(marg.min())
        b1000 = nb.margin_bound(marg, r["path"], KP, gmax=1000.0, kmax=200)[0]
        p0 = {k: np.array(v, dtype=np.float32) for k, v in nt.init_params(jax.random.PRNGKey(1000 * int(r["seed"]) + 7)).items()}
        p0path = nb.path_norm(p0)
        assert abs(nb.path_norm(p) - r["path"]) < 0.05 * r["path"] + 0.1, (nb.path_norm(p), r["path"])
    crit = (cp >= max(1.0, mplus)) if have_nets else None
    allrows.append(dict(r, c_path=cp, c_F=cf, mplus=mplus, minm=minm, b1000=b1000, p0path=p0path, crit=crit))
    print(f"   {r['fn']:7s} {n:5d} {r['seed']:4d} {r['path']:6.1f} {cp:7.2f} {r['path_bound']:6.2f} {r['path_gamma']:5.2f} {r['PF']:6.1f} "
          f"{cf:6.2f} {r['frob_bound']:6.1f} {mplus:5.2f} {minm:6.2f} {str(crit):>5s} {b1000:13.3f} {p0path:10.1f}")
print("   all path-norm bounds minimized at the grid edge gamma = 4:", all(abs(r["path_gamma"] - 4.0) < 1e-9 for r in rows))
if have_nets:
    print("   vacuity criterion c_path >= max(1, mean(yf)_+) holds for", sum(r["crit"] for r in allrows), "of", len(allrows), "networks;",
          "all printed B2.2 bounds >= 1:", all(r["path_bound"] >= 1 for r in rows))
    print("   B2.2 with gamma_max = 1000: min over networks", round(min(r["b1000"] for r in allrows), 4),
          " max", round(max(r["b1000"] for r in allrows), 4))
    print("   mean positive train margin: range", round(min(r["mplus"] for r in allrows), 3), "-", round(max(r["mplus"] for r in allrows), 3))
# per (fn, n) means, as in Table 5.2
print("   per-(target, n) means:   fn n  path  c_path  P_F  c_F  B2.3(printed)")
means = {}
for r in allrows:
    means.setdefault((r["fn"], r["n"]), []).append(r)
for (fn, n), rs in means.items():
    m = lambda k: float(np.mean([x[k] for x in rs]))
    means[(fn, n)] = dict(path=m("path"), c_path=m("c_path"), PF=m("PF"), c_F=m("c_F"), frob=m("frob_bound"), p0=m("p0path"))
    print(f"      {fn:7s} {n:5d} {m('path'):6.0f} {m('c_path'):6.2f} {m('PF'):6.1f} {m('c_F'):6.2f} {m('frob_bound'):6.1f}")
v = list(means.values())
print("   ranges of the means: path norm", round(min(x["path"] for x in v)), "-", round(max(x["path"] for x in v)),
      "| c_path", round(min(x["c_path"] for x in v), 2), "-", round(max(x["c_path"] for x in v), 2),
      "| c_F", round(min(x["c_F"] for x in v), 2), "-", round(max(x["c_F"] for x in v), 2),
      "| printed B2.3", round(min(x["frob"] for x in v), 1), "-", round(max(x["frob"] for x in v), 1))
x1 = means[("dict", 16384)]
print(f"   x1, n=16384: c_path = {x1['c_path']:.3f}; with kappa = 1.17 (proven lower estimate): {x1['c_path'] * 1.17 / KP:.3f};"
      f" trained path norm {x1['path']:.1f} vs init {x1['p0']:.1f}")
print("   networks whose trained path norm is below their initial one:",
      [(r["fn"], r["n"], r["seed"], round(r["path"], 1), round(r["p0path"], 1)) for r in allrows if r["path"] < r["p0path"]])
print("   c_path with kappa = 1.17 below 1 for:", sorted(set((r["fn"], r["n"]) for r in allrows if r["c_path"] * 1.17 / KP < 1)))

# ------------------------------------------------------------------------------------------------ 2
print("\n== 2. GD eta = 0.02: B3.3(a) with the measured descent constant ==")
S = J("sgd_short_maj3_2048_gd_eta0.02.json")
n = S["n"]
for rec in S["records"]:
    if "pb_KL_flow" not in rec:
        continue
    c = rec["desc_c_used"]
    KL1 = rec["pb_KL_flow"] * c                       # the old c = 1 value
    RQ1 = nb.kl_inv_upper(rec["pb_gibbs_up"], (KL1 + math.log(2 * math.sqrt(n) * G / 0.03)) / n)
    print(f"   step {rec['step']:5d}: c_K = {c:.4f} (rigorous: {rec['flow_rigorous']})  KL c=1 {KL1:.0f} -> /c {rec['pb_KL_flow']:.0f};"
          f"  R(Q) c=1 {RQ1:.4f} -> {rec['pb_RQ_flow']:.4f};  det {min(1, rec['pb_RQ_flow'] + rec['pb_dis_up']):.3f}")
for f in ["sgd_short_maj3_2048_gd.json", "sgd_short_maj3_2048_sgd.json"]:
    S = J(f)
    print(f"   {f}: flow_rigorous at the PB checkpoints:", sorted(set(r["flow_rigorous"] for r in S["records"] if "pb_KL_flow" in r)))
# first step at which (D) fails for full-batch GD at eta = 0.2 (same data, init and multipliers as sgd_short.py)
import nn_train as nt
import jax, jax.numpy as jnp
Xg, yg = nt.make_data("maj3", 0, 16384); Xg, yg = jnp.array(Xg[:2048]), jnp.array(yg[:2048])
pg = nt.init_params(jax.random.PRNGKey(7)); MG = nt.MULT["sgd"]
lg = jax.jit(lambda p: nt.loss_fn(p, Xg, yg)); gg = jax.jit(jax.grad(lambda p: nt.loss_fn(p, Xg, yg)))
ratios = []
for k in range(60):
    g = gg(pg); g2 = float(sum(MG[q] * jnp.sum(g[q] ** 2) for q in g))
    pn = {q: pg[q] - 0.2 * MG[q] * g[q] for q in pg}
    ratios.append((float(lg(pg)) - float(lg(pn))) / (0.2 * g2)); pg = pn
neg = [k for k, r in enumerate(ratios) if r <= 0]
print(f"   GD eta=0.2, maj3, n=2048: min descent ratio over steps 0-19 = {min(ratios[:20]):.4f}; first step k with ratio <= 0: "
      f"{neg[0] if neg else None}; ratios at steps 18-26: {[round(r, 3) for r in ratios[18:27]]}")

# ------------------------------------------------------------------------------------------------ 3
print("\n== 3. Theorem B3.1: certified closed form vs random search ==")
for f in ["sgd_short_maj3_2048_sgd.json", "sgd_short_maj3_2048_gd_eta0.02.json", "sgd_short_dict_16384_sgd.json"]:
    S = J(f)
    print(f"   {f}")
    for rec in S["records"]:
        if rec["step"] in (0, 20, 100, 1000, 5000, 300):
            print(f"      step {rec['step']:5d} t={rec['t']:7.1f}: P^max closed {rec['PF_apriori']:9.1f}  search (lower est.) {rec['PF_apriori_search']:9.1f}"
                  f"  ratio {rec['PF_apriori'] / rec['PF_apriori_search']:.2f}  unit-margin complexity {rec['frob_apriori_unit_margin']:8.2f}"
                  f"  printed bound (min over gamma<=4) {rec['frob_apriori_bound']:8.2f}")
PF0 = J("sgd_short_maj3_2048_sgd.json")["records"][0]["PF"]
for n in [256, 2048, 16384]:
    print(f"   t = 0, n = {n:5d}: P_F(theta_0) = {PF0:.2f}, complexity at unit margin 2 kappa_F q^j P / sqrt(n) = {2 * KF * grid(PF0) / math.sqrt(n):.2f};"
          f"  369.3/sqrt(n) = {369.3 / math.sqrt(n):.2f}")

# ------------------------------------------------------------------------------------------------ 4
print("\n== 4. Early stopping: per-checkpoint B3.2 (deterministic) and best-of with a union bound ==")
def det_bound(rec, n, Jn):
    """B3.2 derandomized bound with delta_1 = delta_2 = 0.01 / Jn (union over Jn evaluations); delta_0 = 0.03."""
    ge_up = nb.kl_inv_upper(rec["pb_gibbs"], math.log(Jn / 0.01) / 400)
    RQ = nb.kl_inv_upper(ge_up, (rec["pb_KL"] + math.log(2 * math.sqrt(n) * G / 0.03)) / n)
    du = nb.kl_inv_upper(rec["pb_dis"], math.log(Jn / 0.01) / 400)
    return RQ, min(1.0, RQ + du)
for fn in ["dict", "maj3"]:
    recs = []
    for mode in ["sgd", "adam"]:
        S = J(f"sgd_short_{fn}_16384_{mode}.json")
        recs += [(mode, r) for r in S["records"] if "pb_KL" in r]
    Jn = len(recs)
    print(f"   {fn}, n = 16384: {Jn} evaluated checkpoints (SGD and Adam)")
    for mode, r in recs:
        RQ1, d1 = det_bound(r, 16384, 1)
        RQJ, dJ = det_bound(r, 16384, Jn)
        print(f"      {mode:4s} step {r['step']:4d}: test err {r['test_err']:.3f}  det (own delta) {d1:.3f} [json {r['pb_det']:.3f}]  det (union over {Jn}) {dJ:.3f}")
    sub = [(m, r) for m, r in recs if 100 <= r["step"] <= 300]
    vals = [det_bound(r, 16384, 1)[1] for m, r in sub]
    best = min(sub, key=lambda mr: det_bound(mr[1], 16384, Jn)[1])
    print(f"      steps 100-300: per-checkpoint range {min(vals):.3f}-{max(vals):.3f};  best-of with union bound: {det_bound(best[1], 16384, Jn)[1]:.3f}"
          f" ({best[0]}, step {best[1]['step']})")

# ------------------------------------------------------------------------------------------------ 5
print("\n== 5. Theorem B3.3: growth of E_K (part b) and of the Adam KL (part c) ==")
for f in ["sgd_short_maj3_2048_sgd.json", "sgd_short_maj3_2048_gd.json", "sgd_short_maj3_2048_gd_eta0.02.json", "sgd_short_dict_16384_sgd.json"]:
    S = J(f)
    L0 = S["L0"]
    print(f"   {f} (L0 = {L0:.3f}): step: E_K = sum_g E_K,g  [E_K / L0]")
    print("      " + "  ".join(f"{r['step']}: {sum(r['energy_groups']):.2f} [{sum(r['energy_groups']) / L0:.1f}]" for r in S["records"] if r["step"] > 0))
    sig = np.array([0.14, 0.2, 0.025]); mg = np.array([2.0, 1.0, 0.5])
    kl = [(r["step"], r["t"] * float((mg * np.array(r["energy_groups"]) / (2 * sig ** 2)).sum())) for r in S["records"] if r["step"] > 0]
    print("      KL (b) at fixed sigma = (0.14, 0.2, 0.025): " + "  ".join(f"{k}: {v:.0f}" for k, v in kl))
    if len(kl) > 2:
        (k1, v1), (k2, v2) = kl[2], kl[-1]
        print(f"      log-log slope of KL (b) in K between steps {k1} and {k2}: {math.log(v2 / v1) / math.log(k2 / k1):.2f}")
b1, b2 = 0.9, 0.999; rr = b1 ** 2 / b2
Ct = lambda t: (1 - b1) / (1 - b1 ** t) * math.sqrt((1 - b2 ** t) / (1 - b2)) * math.sqrt((1 - rr ** t) / (1 - rr))
Cs = np.array([Ct(t) for t in range(1, 20001)])
SK = np.cumsum(Cs)
print("   C_t >= 1 for all t <= 20000:", bool(Cs.min() >= 1 - 1e-12), "  so S_K >= K and KL (c) >= sum_g p_g (eta m_g K)^2 / (2 sigma_g^2)")
for K in (50, 100, 300, 1000, 20000):
    print(f"      K = {K:5d}: S_K / K = {SK[K - 1] / K:.3f},  (S_K / S_100)^2 = {(SK[K - 1] / SK[99]) ** 2:.1f}  vs  K / 100 = {K / 100:.1f}")
for fn in ["dict", "maj3"]:
    S = J(f"sgd_short_{fn}_16384_adam.json")
    print(f"   Adam {fn}: KL (c) by step: " + "  ".join(f"{r['step']}: {r['pb_KL_adam']:.0f}" for r in S["records"] if "pb_KL_adam" in r))
print(f"   C_50 = {Ct(50):.4f}; largest measured ratio by step 50: dict {J('sgd_short_dict_16384_adam.json')['records'][4]['max_step_ratio']:.3f},"
      f" maj3 {J('sgd_short_maj3_16384_adam.json')['records'][4]['max_step_ratio']:.3f}  (records at step 50)")
for fn in ["dict", "maj3"]:
    S = J(f"sgd_short_{fn}_16384_adam.json")
    r50 = [r for r in S["records"] if r["step"] == 50][0]
    print(f"      {fn}: max ratio by step 50 = {r50['max_step_ratio']:.3f}, / C_50 = {r50['max_step_ratio'] / Ct(50):.3f};"
          f"  max over all steps of ratio / C_t = {S['records'][-1]['max_ratio_over_C']:.6f}")

# ------------------------------------------------------------------------------------------------ 6
print("\n== 6. Theorem B3.3(d): constants of the a priori SGD versions ==")
sig = np.array([0.14, 0.2, 0.025]); mg = np.array([2.0, 1.0, 0.5])
lam = float((mg / (2 * sig ** 2)).max()); L0 = 0.5
print(f"   lambda_sigma = max_g m_g/(2 sigma_g^2) = {lam:.0f}")
for n in [2048, 16384]:
    for eps in [0.1]:
        ta = eps * n / (lam * L0)
        tm = eps * n / (lam * 4 * L0)
        tk = eps * n / (lam * 4 * L0 / 0.01)
        print(f"   n = {n}, eps = {eps}: KL <= eps n needs t <= {ta:.2f} (a: flow), <= {tm:.3f} (d: mixture, noise term ignored),"
              f" <= {tk:.5f} (d: Markov, delta' = 0.01); at eta = 0.2 that is {ta / 0.2:.1f}, {tm / 0.2:.2f}, {tk / 0.2:.4f} steps")

# ------------------------------------------------------------------------------------------------ 7
print("\n== 7. Miscellaneous ==")
for n in [256, 2048, 16384]:
    print(f"   Dudley with 0 added to the class: extra term on 2 Rhat_S <= 24 sqrt(ln 2 / n) = {24 * math.sqrt(math.log(2) / n):.4f}  (n = {n})")
ro = [json.loads(l) for l in open(os.path.join(HERE, "readoff.json"))]
small = [r for r in ro if r["fn"] in ("dict", "par2", "and3", "maj3") and r["n"] == 256]
print("   read-off disagreements at n = 256 (x1, x1x2, AND3, MAJ3):", [(r["fn"], r["seed"], round(r["dis"], 4)) for r in small])
print("   largest:", max(r["dis"] for r in small))
for fn, nn_ in [("par4", 2048), ("par3", 256), ("dlist5", 256), ("stair5", 2048), ("mux", 2048), ("majpar", 2048)]:
    rs = [r for r in ro if r["fn"] == fn and r["n"] == nn_]
    print(f"   read-off {fn} n={nn_}: bounds " + ", ".join(f"{r['bound']:.3f}" for r in rs) + f";  mean {np.mean([r['bound'] for r in rs]):.3f}")
K = 3; d = 30
print(f"   ln(1/pi) for k = 3: {math.log(7 * math.comb(d, K) * 2 ** (2 ** K)):.3f}")

# ------------------------------------------------------------------------------------------------ 8
print("\n== 8. Proposition B3.4 on one-pass Adam (progressive errors logged) ==")
import nn_train as nt
import jax, jax.numpy as jnp
STEPS, W, BATCH, DELTA = 3000, 1000, 64, 0.05
step = jax.jit(nt.make_step("adam", 1e-3))
errf = jax.jit(lambda p, X, y: jnp.mean(y * nt.forward(p, X)[0] <= 0))
for fn in ["dict", "maj3", "par3"]:
    Xte, yte = nt.make_test(fn); Xte, yte = jnp.array(Xte), jnp.array(yte)
    p0 = nt.init_params(jax.random.PRNGKey(7))
    z = jax.tree_util.tree_map(jnp.zeros_like, p0)
    st = (p0, z, z, 0)
    rng = np.random.default_rng([nt._fn_seed(fn), 888])
    e, te = [], []
    for k in range(1, STEPS + 1):
        Xb = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(BATCH, nt.D))
        yb = nt.SUITE[fn]["fn"](Xb).astype(np.float32)
        Xb, yb = jnp.array(Xb), jnp.array(yb)
        e.append(float(errf(st[0], Xb, yb)))          # e_k: pre-update parameters theta_{k-1} on the fresh batch
        te.append(float(errf(st[0], Xte, yte)))       # test error of theta_{k-1} (4096 held-out inputs)
        st = step(st, Xb, yb)
    e, te = np.array(e), np.array(te)
    slack = math.sqrt(math.log(3 / DELTA) / (2 * W * BATCH))
    final_te = float(errf(st[0], Xte, yte))
    for w in range(STEPS // W):
        sl = slice(w * W, (w + 1) * W)
        print(f"   {fn:5s} window steps {w * W + 1:4d}-{(w + 1) * W:4d}: mean e_k {e[sl].mean():.4f}  bound {e[sl].mean() + slack:.4f}"
              f"  (slack {slack:.4f})  measured mean test err of the iterates {te[sl].mean():.4f}")
    print(f"   {fn:5s} final network after {STEPS} steps: test err {final_te:.4f}")

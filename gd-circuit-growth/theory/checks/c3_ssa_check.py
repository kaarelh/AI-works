"""C3, Corollary C3.5: test the sign form of hypothesis SSA on the saved Adam runs, and compute the resulting
unconditional certificate along training.

For a network (target fn, training-set size n, seed):
  * the training set S and the 4096 test inputs are regenerated exactly as in study/nn_train.py;
  * the network's sign predictions on the test inputs at its 15 checkpoints are read from the saved sweep output
    (only the *inputs* of the test set are used; their labels are used for reporting only);
  * A's (LS) clock race (checks/race_bounds.py, library {id, AND(+-a,+-b), XOR}, |G| = 6, fan-in 2) is run on S;
    its states h^M_s (one per event, plus the constant predictor at s = 0) depend on S only;
  * for each checkpoint t: eta_hat(t) = min_s dis_U(sign f_t, h^M_s), the best-matching race time s*(t), and the
    Corollary C3.5(2) certificate  min_s [ klinv(err_S(h^M_s), L_T/n) + klinv(dis_U, ln(15 |Sigma| / d2)/4096) ],
    with L_T = log W_T + log Phi(2^min(T,30), T) + log((T+1)(T+2)/d1)  (Theorem A1 / C3.3), d1 = d2 = 0.025.
Baselines: dis to the target (= test error) and to the best constant.
Runs in a few minutes on one core.  Reads $RESULTS read-only.
"""
import os, sys, math, json, time
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, "..", "..", "study"))
import numpy as np
import race_bounds as rb
import nn_train as nt
import c_common as cc

RESULTS = os.environ.get("RESULTS", "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/results")
D1 = D2 = 0.025


def L_T(T):
    return rb.log_W(T) + rb.log_phi(2 ** min(T, 30), T) + math.log((T + 1) * (T + 2) / D1)


def run(fn, n, seed=0, tmax=12.0, Tmax=40):
    z = np.load(os.path.join(RESULTS, f"fixed_adam_{fn}.npz"))
    j = [i for i, (n_, s_) in enumerate(zip(z["net_n"], z["net_s"])) if n_ == n and s_ == seed][0]
    seeds = list(z["seeds"]); nmax = int(z["ns"].max())
    X, y = nt.make_data(fn, int(seeds[seed]), nmax)
    X, y = X[:n].astype(np.float64), y[:n].astype(np.float64)
    Xte, yte = nt.make_test(fn)
    Xte, yte = Xte.astype(np.float64), yte.astype(np.float64)
    pred = z["pred"][:, j, :].astype(np.float64)          # (15, 4096) network signs at checkpoints
    pred = np.where(pred == 0, 1.0, pred)
    steps = [int(s) for s in z["step"]]
    race = rb.Race(X, y, Xte, yte, variant="LS")
    states = [dict(t=0.0, T=0, tau=0.0, errS=float(np.mean(np.where(race.f_train() > 0, 1, -1) != y)),
                   pred=np.where(race.f_test() > 0, 1.0, -1.0))]
    t0 = time.time()
    while race.t < tmax and len(race.active) < Tmax:
        if not race.step():
            break
        ftr, fte = race.f_train(), race.f_test()
        states.append(dict(t=race.t, T=len(race.active), tau=race.tau,
                           errS=float(np.mean(np.where(ftr > 0, 1, -1) != y)), pred=np.where(fte > 0, 1.0, -1.0)))
        if 0.5 * float(np.mean((ftr - y) ** 2)) < 1e-20:
            break
    K = len(states)
    occ = [cc.klinv_upper(s["errS"], L_T(s["T"]) / n) for s in states]
    eps_u = math.log(len(steps) * K / D2) / len(yte)
    rows = []
    for k, st in enumerate(steps):
        dis = np.array([np.mean(pred[k] != s["pred"]) for s in states])
        i_best = int(np.argmin(dis))
        cert = min(occ[i] + cc.klinv_upper(float(dis[i]), eps_u) for i in range(K))
        rows.append(dict(step=st, test_err=float(np.mean(pred[k] != yte)),
                         dis_const=float(min(np.mean(pred[k] != 1), np.mean(pred[k] != -1))),
                         eta_hat=float(dis[i_best]), s_best=states[i_best]["t"], T_best=states[i_best]["T"],
                         cert=float(cert)))
    race_err = [float(np.mean(s["pred"] != yte)) for s in states]
    return dict(fn=fn, n=n, seed=seed, n_states=K, race_final_T=states[-1]["T"], race_final_t=states[-1]["t"],
                race_test_err_final=race_err[-1], race_min_test_err=min(race_err), rows=rows,
                secs=time.time() - t0)


def main():
    out = []
    jobs = [("and3", 2048), ("maj3", 2048), ("dnf3", 2048), ("mux", 2048), ("stair5", 2048), ("majpar", 2048),
            ("parmaj", 2048), ("par3", 2048), ("and3", 256), ("maj3", 256), ("dnf3", 256)]
    for fn, n in jobs:
        r = run(fn, n)
        out.append(r)
        print(f"== {fn} n={n} seed=0: race has {r['n_states']} states, final T={r['race_final_T']} at t/Theta="
              f"{r['race_final_t']:.2f}, race test error final {r['race_test_err_final']:.3f} (min "
              f"{r['race_min_test_err']:.3f}); {r['secs']:.0f}s", flush=True)
        print("   step   test_err  dis(const)  eta_hat=min_s dis  s*/Theta  T(s*)  C3.5 certificate")
        for row in r["rows"]:
            print(f"   {row['step']:5d}   {row['test_err']:.3f}    {row['dis_const']:.3f}      {row['eta_hat']:.3f}"
                  f"          {row['s_best']:5.2f}    {row['T_best']:3d}    {row['cert']:.3f}", flush=True)
    with open(os.path.join(HERE, "c3_ssa_check.json"), "w") as fh:
        json.dump(out, fh, indent=1)


if __name__ == "__main__":
    main()

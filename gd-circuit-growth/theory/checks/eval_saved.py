"""Section B4: evaluate the data-dependent bounds on the final networks of the Adam sweep.

Reads (read-only) the sweep outputs  $RESULTS/params_fixed_adam_<fn>.npz  and  fixed_adam_<fn>.npz
written by gd-circuit-growth/study/nn_train.py (Adam, lr 1e-3, 20000 steps, width 128, muP init).
The initialisation and the training sets are regenerated with the study's own code (same seeds), and
checked against the norms recorded by the sweep.  Parameters were saved in float16; all bounds are
computed for the float16-rounded network itself (its train margins are recomputed here).

usage: [NS=256,2048,16384] [SEEDS=0,1,2] python3 eval_saved.py [fn1,fn2,...]   output: one JSON line per network appended to eval_saved.json
"""
import os, sys, time, json
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "study"))
import numpy as np
import nnbounds as nb

OPT = os.environ.get("OPT", "adam")   # adam | sgd: which sweep outputs to read
RESULTS = os.environ.get("RESULTS", "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/results")
import nn_train as nt   # imports jax; defines init_params, make_data, SUITE (no side effects beyond that)
import jax

NS = [int(v) for v in os.environ.get("NS", "256,2048,16384").split(",")]
SEEDS = [int(v) for v in os.environ.get("SEEDS", "0,1,2").split(",")]

def load(fn):
    P = np.load(os.path.join(RESULTS, f"params_fixed_{OPT}_{fn}.npz"))
    R = np.load(os.path.join(RESULTS, f"fixed_{OPT}_{fn}.npz"))
    return P, R

def main(fns):
    rng = np.random.default_rng(2026)
    rows = []
    for fn in fns:
        P, R = load(fn)
        seeds = list(R["seeds"]); net_n = R["net_n"]; net_s = R["net_s"]; nmax = int(R["ns"].max())
        data = {s: nt.make_data(fn, int(seeds[s]), nmax) for s in range(len(seeds))}
        last = -1
        for i in range(len(net_n)):
            n = int(net_n[i]); s = int(net_s[i])
            if n not in NS or int(seeds[s]) not in SEEDS:
                continue
            t0 = time.time()
            p = {k: P[k][i].astype(np.float32) for k in ["W1", "b1", "W2", "b2", "a"]}
            p0 = {k: np.array(v, dtype=np.float32) for k, v in nt.init_params(jax.random.PRNGKey(1000 * int(seeds[s]) + 7)).items()}
            # consistency with the sweep's records
            chk = dict(W1_0=(np.linalg.norm(p0["W1"]), R["W1"][0][i]), dW1=(np.linalg.norm(p["W1"] - p0["W1"]), R["dW1"][last][i]),
                       path=(nb.path_norm(p), R["path1"][last][i]))
            X, y = data[s][0][:n].astype(np.float32), data[s][1][:n].astype(np.float32)
            marg = y * nb.forward(p, X)
            D = X.shape[1] + 1
            phi = nb.path_norm(p); PF = nb.frob_complexity(p)
            bp = nb.margin_bound(marg, phi, nb.KAPPA_PATH(D))
            bf = nb.margin_bound(marg, PF, nb.KAPPA_FROB(D))
            s_, b_ = nb.spectral_quantities(p, p0)
            bs = nb.spectral_bound(marg, np.sqrt(n * D), s_, b_, W=p["W1"].shape[0] + 1)
            s0, b0 = nb.spectral_quantities(p, None)
            bs0 = nb.spectral_bound(marg, np.sqrt(n * D), s0, b0, W=p["W1"].shape[0] + 1)
            pb = nb.pac_bayes(p, p0, X, y, rng)
            row = dict(opt=OPT, fn=fn, n=n, seed=int(seeds[s]), train_err=float(np.mean(marg <= 0)), min_margin=float(marg.min()),
                       test_err=float(R["test_err"][last][i]), W1=float(np.linalg.norm(p["W1"])), W2=float(np.linalg.norm(p["W2"])),
                       a=float(np.linalg.norm(p["a"])), dist2=[float(v) for v in pb["sqdist"]], path=phi, PF=PF,
                       spec=[float(v) for v in s_], b21_init=[float(v) for v in b_],
                       path_bound=bp[0], path_gamma=bp[1], frob_bound=bf[0], spec_bound_init=bs[0], spec_bound_zero=bs0[0],
                       spec_uncapped_init=float(bs[5]), spec_uncapped_zero=float(bs0[5]), pb_sig=[float(v) for v in pb["sig"]], pb_KL=pb["KL"], pb_gibbs=pb["gibbs_train"],
                       pb_RQ=pb["RQ"], pb_dis=pb["dis"], pb_det=pb["det"], check=chk)
            rows.append(row)
            with open(os.path.join(HERE, "eval_saved.json"), "a") as f:   # incremental
                f.write(json.dumps(row, default=float) + "\n")
            print(f"{fn:6s} n={n:5d} s={seeds[s]} train_err={row['train_err']:.3f} test_err={row['test_err']:.3f} "
                  f"| path={phi:7.1f} bnd={bp[0]:7.2f} (gamma={bp[1]:.2f}) | P_F={PF:7.1f} bnd={bf[0]:8.1f} "
                  f"| spec 24rho/n: init-ref {bs[5]:9.1f} zero-ref {bs0[5]:9.1f} | PB: KL={pb['KL']:8.1f} sig={np.round(pb['sig'],4)} "
                  f"gibbs={pb['gibbs_train']:.3f} R(Q)<={pb['RQ']:.3f} dis={pb['dis']:.3f} det<={pb['det']:.3f} "
                  f"[{time.time()-t0:.0f}s]  check {json.dumps({k: [round(float(a),2), round(float(b),2)] for k,(a,b) in chk.items()})}",
                  flush=True)


if __name__ == "__main__":
    fns = sys.argv[1].split(",") if len(sys.argv) > 1 else ["dict", "and3"]
    main(fns)

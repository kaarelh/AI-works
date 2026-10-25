"""Section 6, Proposition 6.1: a posteriori 'read-off circuit' certificate for the actual trained network.

For each final Adam network of the sweep:
  1. on 20000 fresh *unlabeled* uniform inputs, estimate each coordinate's influence on sign f;
  2. for k = 0..KMAX, let g_k be the junta on the k most influential coordinates whose truth table is the
     majority of sign f within each of the 2^k cells (selection uses only f and unlabeled inputs);
  3. Occam/Chernoff with prior pi(g) = 1/((KMAX+1) C(d,k) 2^(2^k)):  R(g) <= kl^-1(err_S(g), (ln 1/pi + ln 1/d1)/n);
  4. disagreement Pr_x[sign f != g] on 100000 *fresh* unlabeled inputs, kl-Chernoff, union over k;
  5. R(f) <= R(g) + Dis(f, g); report the best k.
No test labels and no knowledge of the target are used.  delta = 0.05 (0.025 + 0.025).
"""
import os, sys, json, math
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "study"))
import numpy as np
import nnbounds as nb
import nn_train as nt

OPT = os.environ.get("OPT", "adam")   # adam | sgd: which sweep outputs to read
RESULTS = os.environ.get("RESULTS", "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/results")
KMAX, d = 6, 30
d1 = d2 = 0.025

def junta_table(s, X, coords):
    """majority of s in each cell of the coordinates `coords` (ties -> +1)."""
    if len(coords) == 0:
        return {(): 1.0 if s.mean() >= 0 else -1.0}
    keys = ((X[:, coords] > 0).astype(int) * (2 ** np.arange(len(coords)))).sum(1)
    tab = np.ones(2 ** len(coords))
    for c in range(2 ** len(coords)):
        m = keys == c
        tab[c] = 1.0 if (m.sum() == 0 or s[m].mean() >= 0) else -1.0
    return tab

def junta_eval(tab, X, coords):
    if len(coords) == 0:
        return np.full(len(X), tab[()])
    keys = ((X[:, coords] > 0).astype(int) * (2 ** np.arange(len(coords)))).sum(1)
    return tab[keys]

def main(fns, ns=(256, 2048, 16384)):
    rng = np.random.default_rng(7)
    out = []
    for fn in fns:
        P = np.load(os.path.join(RESULTS, f"params_fixed_{OPT}_{fn}.npz"))
        R = np.load(os.path.join(RESULTS, f"fixed_{OPT}_{fn}.npz"))
        seeds = list(R["seeds"]); nmax = int(R["ns"].max())
        data = {s: nt.make_data(fn, int(seeds[s]), nmax) for s in range(len(seeds))}
        for i in range(len(R["net_n"])):
            n = int(R["net_n"][i]); s = int(R["net_s"][i])
            if n not in ns:
                continue
            p = {k: P[k][i].astype(np.float32) for k in ["W1", "b1", "W2", "b2", "a"]}
            X, y = data[s][0][:n], data[s][1][:n]
            Xu = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(20000, d))
            su = np.sign(nb.forward(p, Xu))
            infl = []
            for j in range(d):
                Xf = Xu.copy(); Xf[:, j] *= -1
                infl.append(np.mean(np.sign(nb.forward(p, Xf)) != su))
            order = list(np.argsort(infl)[::-1])
            Xt = rng.choice(np.array([-1.0, 1.0], dtype=np.float32), size=(100000, d))
            st = np.sign(nb.forward(p, Xt))
            best = None
            for k in range(KMAX + 1):
                coords = sorted(order[:k])
                tab = junta_table(su, Xu, coords)
                errS = float(np.mean(junta_eval(tab, X, coords) != y))
                lnpi = math.log(KMAX + 1) + math.log(math.comb(d, k)) + (2 ** k) * math.log(2)
                Rg = nb.kl_inv_upper(errS, (lnpi + math.log(1 / d1)) / n)
                dis = float(np.mean(junta_eval(tab, Xt, coords) != st))
                dis_up = nb.kl_inv_upper(dis, math.log((KMAX + 1) / d2) / len(Xt))
                b = Rg + dis_up
                if best is None or b < best["bound"]:
                    best = dict(opt=OPT, fn=fn, n=n, seed=int(seeds[s]), k=k, coords=[int(c) for c in coords], errS=errS,
                                lnpi=lnpi, Rg=Rg, dis=dis, dis_up=dis_up, bound=min(1.0, b),
                                test_err=float(R["test_err"][-1][i]))
            out.append(best)
            print(json.dumps(best), flush=True)
    with open(os.path.join(HERE, "readoff.json" if OPT == "adam" else f"readoff_{OPT}.json"), "w") as f:
        for r in out:
            f.write(json.dumps(r) + "\n")

if __name__ == "__main__":
    main(sys.argv[1].split(",") if len(sys.argv) > 1 else ["dict", "and3", "maj3", "par2"])

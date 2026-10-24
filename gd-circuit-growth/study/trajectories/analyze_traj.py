"""Characterize learning trajectories saved by run_traj.py.

For every checkpoint t and network:
  f_R(t)        conditional mean of the output over x_R (relevant variables), on all 2^r patterns
  c_S(t)        its Fourier coefficients on every subset S of R (Walsh-Hadamard transform)
  phi_S(t)      learned fraction c_S(t) / yhat(S) for the target's characters
  off(t)        squared mass of f_R on characters outside the target's support (spurious relevant structure)
  irr(t)        mean variance of f over irrelevant completions (dependence on irrelevant coordinates)
  err(t)        sign error of f_R against the target on the relevant cube (denoised test error)
Hypotheses for "the function computed at time t":
  H_char  f_R(t) ~ P_S(t) y, the projection of y onto the characters with phi_S > 1/2 (plus the constant)
  H_junta f_R(t) ~ E[y | x_V(t)], the best function of the variables V(t) whose influence in f_R exceeds 0.05
Writes trajectories/results/<fn>.json and figures/traj_<fn>.png.
"""
import os, sys, json, itertools, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, os.path.dirname(HERE))
from boolfuncs import make_suite

S_DIR = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/traj"
SUITE = make_suite(30)
OUT = os.path.join(HERE, "results"); os.makedirs(OUT, exist_ok=True)
FIG = os.path.join(os.path.dirname(HERE), "figures")


def subsets(r):
    return [T for k in range(r + 1) for T in itertools.combinations(range(r), k)]


def chi_matrix(pats, subs):
    return np.stack([np.prod(pats[:, list(T)], axis=1) if T else np.ones(len(pats)) for T in subs], 1)


def target_on_cube(fn, pats, R):
    X = np.ones((len(pats), 30), dtype=np.float32); X[:, R] = pats
    return SUITE[fn]["fn"](X).astype(np.float64)


def first_cross(steps, curve, thr=0.5):
    """First checkpoint step (log-interpolated) at which curve >= thr and stays >= thr*0.8 afterwards; None if never."""
    for i in range(len(curve)):
        if curve[i] >= thr and np.all(curve[i:] >= 0.8 * thr):
            if i == 0 or steps[i - 1] <= 0:
                return float(steps[i])
            lo, hi = curve[i - 1], curve[i]; f = (thr - lo) / max(hi - lo, 1e-9)
            return float(np.exp(np.log(steps[i - 1]) + f * (np.log(steps[i]) - np.log(steps[i - 1]))))
    return None


def junta_projection(y, pats, V):
    if not V:
        return np.full_like(y, y.mean())
    key = (pats[:, V] > 0).astype(int) @ (2 ** np.arange(len(V)))
    out = np.zeros_like(y)
    for k in np.unique(key):
        out[key == k] = y[key == k].mean()
    return out


def analyze(fn, tag):
    p = os.path.join(S_DIR, f"traj_{tag}_{fn}.npz")
    if not os.path.exists(p):
        return None
    z = np.load(p)
    steps, pats, R = z["steps"], z["pats"].astype(np.float64), list(z["R"])
    r = len(R); subs = subsets(r); C = chi_matrix(pats, subs)
    y = target_on_cube(fn, pats, R); yhat = C.T @ y / len(y)
    supp = [j for j in range(len(subs)) if abs(yhat[j]) > 1e-9]
    names = ["".join(f"x{R[i] + 1}" for i in subs[j]) or "1" for j in range(len(subs))]
    nets = list(z["nets"]); seeds = list(z["seeds"])
    res = dict(fn=fn, tag=tag, steps=steps.tolist(), support={names[j]: float(yhat[j]) for j in supp}, nets={})
    for k, (nn, sd) in enumerate(zip(nets, seeds)):
        fR = z["f_mean"][:, k, :].astype(np.float64)            # [T, 2^r]
        coef = fR @ C / len(y)                                   # [T, 2^r]
        phi = {names[j]: (coef[:, j] / yhat[j]).tolist() for j in supp}
        off = np.sum(np.delete(coef, supp, axis=1) ** 2, axis=1)
        irr = z["f_var"][:, k, :].mean(1)
        err = np.mean(np.sign(fR) != np.sign(y)[None, :], axis=1)
        mse_R = np.mean((fR - y[None, :]) ** 2, axis=1)
        onset = {nm: first_cross(steps, np.array(v)) for nm, v in phi.items()}
        # hypotheses
        hc, hj, Vs, Ss = [], [], [], []
        for t in range(len(steps)):
            Sset = [j for j in supp if phi[names[j]][t] > 0.5 or subs[j] == ()]
            proj = C[:, Sset] @ yhat[Sset]
            hc.append(float(np.mean((fR[t] - proj) ** 2)))
            # influence of variable i in f_R: E[(f(x) - f(x^{flip i}))^2]/4
            V = []
            for i in range(r):
                flip = pats.copy(); flip[:, i] *= -1
                idx = ((flip > 0).astype(int) @ (2 ** np.arange(r)[::-1]))
                if np.mean((fR[t] - fR[t][idx]) ** 2) / 4 > 0.05 * max(np.var(y), 1e-9):
                    V.append(i)
            hj.append(float(np.mean((fR[t] - junta_projection(y, pats, V)) ** 2)))
            Vs.append([R[i] + 1 for i in V]); Ss.append([names[j] for j in Sset if subs[j] != ()])
        res["nets"][f"{nn}/s{sd}"] = dict(phi=phi, onset=onset, off=off.tolist(), irr=irr.tolist(), err=err.tolist(),
                                          mse_R=mse_R.tolist(), H_char=hc, H_junta=hj, V=Vs, S=Ss)
    return res


def check_pattern_order():
    """itertools.product over [-1, 1] puts the first variable in the most significant position; the flip index above
    relies on that order (pattern index = sum_i [x_i > 0] 2^(r-1-i))."""
    pats = np.array(list(itertools.product([-1.0, 1.0], repeat=3)))
    idx = (pats > 0).astype(int) @ (2 ** np.arange(3)[::-1])
    assert np.all(idx == np.arange(8))


if __name__ == "__main__":
    check_pattern_order()
    fns = sys.argv[1:] or ["sparsepoly", "stair5", "mux", "majpar", "rmaj9"]
    for fn in fns:
        for tag in ("fixed", "online"):
            res = analyze(fn, tag)
            if res is None:
                continue
            json.dump(res, open(os.path.join(OUT, f"{fn}_{tag}.json"), "w"), default=lambda o: o.item() if hasattr(o, "item") else str(o))
            print(fn, tag, "nets", list(res["nets"]))
            for key, v in res["nets"].items():
                on = {k: (round(t) if t else None) for k, t in v["onset"].items()}
                print("  ", key, "onsets:", on)

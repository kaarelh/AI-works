"""Common scoring of trajectory models against the networks.

Network reference: for each target fn, protocol tag ('online' or 'fixed') and condition ('online', '16384', '2048',
'512'), the seed-mean conditional-mean function f_R(t) on the relevant cube, at the checkpoint steps of run_traj.py.

A model's prediction is a file <pred_dir>/<fn>__<cond>.npz with arrays
    steps  [T']        training steps at which the model's function is given (any grid; it is interpolated in log-step)
    f      [T', 2^r]   predicted f_R on the relevant cube, patterns in itertools.product([-1, 1], repeat=r) order
Scores per (fn, cond), and their means:
    traj   mean over checkpoints t >= 1 of ||f_model(t) - f_net(t)||^2 / Var y        (whole-trajectory function error)
    onset  mean over the target's characters of |log10 t_S(model) - log10 t_S(net)|, for characters whose learned
           fraction crosses 1/2 in both; a character that crosses in only one of them counts 1 (one decade)
    final  ||f_model(T) - f_net(T)||^2 / Var y at the last checkpoint
    base   the same 'traj' score for two trivial references: 'zero' (f = mean of y throughout) and 'target'
           (f = y throughout), to calibrate what a good score is
Usage: python score.py <pred_dir> [fns...]   -> prints a table and writes <pred_dir>/scores.json
"""
import os, sys, json, itertools, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE); sys.path.insert(0, os.path.dirname(HERE))
from analyze_traj import S_DIR, subsets, chi_matrix, target_on_cube, first_cross

CONDS = {"online": ("online", "online"), "16384": ("fixed", "16384"), "2048": ("fixed", "2048"), "512": ("fixed", "512")}


def net_reference(fn, cond):
    tag, prefix = CONDS[cond]
    p = os.path.join(S_DIR, f"traj_{tag}_{fn}.npz")
    if not os.path.exists(p):
        return None
    z = np.load(p); nets = list(z["nets"])
    idx = [k for k, nm in enumerate(nets) if nm == prefix]
    if not idx:
        return None
    f = z["f_mean"][:, idx, :].astype(np.float64).mean(1)
    return dict(steps=z["steps"].astype(float), f=f, pats=z["pats"].astype(np.float64), R=list(z["R"]))


def interp_logstep(steps_src, f_src, steps_dst):
    ls = np.log10(np.maximum(steps_src, 0.5)); ld = np.log10(np.maximum(steps_dst, 0.5))
    out = np.empty((len(steps_dst), f_src.shape[1]))
    for j in range(f_src.shape[1]):
        out[:, j] = np.interp(ld, ls, f_src[:, j])
    return out


def onsets(steps, f, C, yhat, supp):
    coef = f @ C / C.shape[0]
    return {j: first_cross(steps, coef[:, j] / yhat[j]) for j in supp}


def score_one(fn, cond, pred_path):
    ref = net_reference(fn, cond)
    if ref is None or not os.path.exists(pred_path):
        return None
    pr = np.load(pred_path)
    steps = ref["steps"]; m = steps >= 1
    fm = interp_logstep(pr["steps"].astype(float), pr["f"].astype(np.float64), steps)
    pats, R = ref["pats"], ref["R"]; r = len(R)
    subs = subsets(r); C = chi_matrix(pats, subs)
    y = target_on_cube(fn, pats, R); vy = max(np.var(y), 1e-9); yhat = C.T @ y / len(y)
    supp = [j for j in range(len(subs)) if abs(yhat[j]) > 1e-9 and subs[j] != ()]
    traj = float(np.mean(np.sum((fm[m] - ref["f"][m]) ** 2, 1) / len(y)) / vy)
    final = float(np.mean((fm[-1] - ref["f"][-1]) ** 2) / vy)
    on_m, on_n = onsets(steps, fm, C, yhat, supp), onsets(steps, ref["f"], C, yhat, supp)
    errs = []
    for j in supp:
        a, b = on_m[j], on_n[j]
        if a is None and b is None:
            continue
        errs.append(1.0 if (a is None) != (b is None) else abs(np.log10(a) - np.log10(b)))
    zero = float(np.mean(np.sum((y.mean() - ref["f"][m]) ** 2, 1) / len(y)) / vy)
    targ = float(np.mean(np.sum((y[None, :] - ref["f"][m]) ** 2, 1) / len(y)) / vy)
    return dict(traj=traj, onset=float(np.mean(errs)) if errs else float("nan"), final=final, base_zero=zero, base_target=targ,
                n_onsets=len(errs))


def main(pred_dir, fns):
    out, rows = {}, []
    for fn in fns:
        for cond in CONDS:
            s = score_one(fn, cond, os.path.join(pred_dir, f"{fn}__{cond}.npz"))
            if s is not None:
                out[f"{fn}__{cond}"] = s
                rows.append((fn, cond, s))
    print(f"{'target':12s} {'cond':7s} {'traj':>6s} {'onset':>6s} {'final':>6s} | {'zero':>6s} {'target':>6s}")
    for fn, cond, s in rows:
        print(f"{fn:12s} {cond:7s} {s['traj']:6.3f} {s['onset']:6.3f} {s['final']:6.3f} | {s['base_zero']:6.3f} {s['base_target']:6.3f}")
    if rows:
        mt = np.mean([s["traj"] for _, _, s in rows]); mo = np.nanmean([s["onset"] for _, _, s in rows])
        print(f"MEAN traj {mt:.3f}  onset {mo:.3f}")
        out["_mean"] = dict(traj=float(mt), onset=float(mo))
    json.dump(out, open(os.path.join(pred_dir, "scores.json"), "w"), indent=1)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2:] or ["sparsepoly", "stair5", "mux", "majpar", "rmaj9"])

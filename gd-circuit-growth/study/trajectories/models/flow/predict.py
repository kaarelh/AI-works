"""Flow model: predicted learning trajectory of the muP MLP on a Boolean target.

    python predict.py <fn> <out_dir>   ->  <out_dir>/<fn>__{online,16384,2048,512}.npz  (steps [T'], f [T', 2^r])

Works for any target in boolfuncs.make_suite(30).  Single-threaded (pinned to one core; FLOW_CPU chooses it); 40 s
(r <= 6) to about 3 minutes (r = 10) per target.  Also prints the predicted onset step of every target character.
"""
import os, sys, time
import numpy as np
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE); sys.path.insert(0, os.path.dirname(os.path.dirname(HERE)))
import flow
from analyze_traj import subsets, chi_matrix, first_cross


def main(fn, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    t0 = time.time()
    R, pats, y = flow.target(fn); P = len(y)
    N, seeds = flow.resolution(P)
    steps, out = flow.run(fn, N=N, seeds=seeds, K0=300, kmax=2)
    steps = steps / flow.width_dilation(N)            # map to the width-128 network's clock
    subs = subsets(len(R)); C = chi_matrix(pats, subs); yhat = C.T @ y / P
    supp = sorted([j for j in range(len(subs)) if abs(yhat[j]) > 1e-9 and subs[j] != ()], key=lambda j: -abs(yhat[j]))
    print(f"{fn}: r = {len(R)}, width {N}, {seeds} seeds, {time.time() - t0:.0f}s")
    for cond, Fs in out.items():
        f = Fs.mean(0)
        np.savez(os.path.join(out_dir, f"{fn}__{cond}.npz"), steps=steps, f=f)
        coef = f @ C / P
        ons = []
        for j in supp[:24]:
            t = first_cross(steps, coef[:, j] / yhat[j])
            nm = "x" + "".join(str(R[i] + 1) for i in subs[j])
            ons.append((t if t is not None else np.inf, nm, coef[-1, j] / yhat[j]))
        txt = ", ".join(f"{nm}@{t:.0f}" if np.isfinite(t) else f"{nm}:{fr:.2f}" for t, nm, fr in sorted(ons))
        print(f"  {cond:6s} onsets (or final fraction): {txt}")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])

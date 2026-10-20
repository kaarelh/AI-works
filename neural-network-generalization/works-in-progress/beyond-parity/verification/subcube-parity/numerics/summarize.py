"""Summarize runs/*.json (finished) and runs/*.txt (possibly running) into a table, and fit
the growth of samples-to-(parity-half err <= 0.05) in d for the mix runs."""
import glob, json, math, os, re
HERE = os.path.dirname(os.path.abspath(__file__))
rows = []
for txt in sorted(glob.glob(os.path.join(HERE, "runs", "*.txt"))):
    name = os.path.basename(txt)[:-4]
    js = txt[:-4] + ".json"
    lines = open(txt).read().splitlines()
    hdr = json.loads(lines[0][2:]) if lines and lines[0].startswith("# {") else {}
    evals = [l for l in lines if l.startswith("step ")]
    if os.path.exists(js):
        S = json.load(open(js)); status = "done-early" if S["stopped_early"] else "done-cap"
        hit, fin, wall = S["hit_samples"], S["final"], S["wall_s"]
        rej = S["rejected_train_points"]
    else:
        status = "running"; hit = {}; fin = None; rej = None
        for l in evals:
            m = dict(re.findall(r"(err_\w+) ([0-9.]+)", l)); n = float(l.split()[3])
            for k, v in m.items():
                if float(v) <= 0.05 and k[4:] not in hit:
                    hit[k[4:]] = n
        if evals:
            l = evals[-1]; fin = {k: float(v) for k, v in re.findall(r"(err_\w+) ([0-9.]+)", l)}
            fin["samples"] = float(l.split()[3])
        wall = float(re.findall(r"\((\d+)s\)", evals[-1])[0]) if evals else 0
    rows.append((name, hdr, status, hit, fin, wall, rej))

def f(x):
    return "-" if x is None else (f"{x:.2e}" if isinstance(x, (int, float)) and x > 1 else f"{x:.4f}")
print(f"{'run':14s} {'status':10s} {'samples':>9s} {'err_all':>7s} {'zneg':>7s} {'zpos':>7s} "
      f"{'hit_zneg':>9s} {'hit_zpos':>9s} {'hit_all':>9s} {'wall_s':>7s} rej")
for name, hdr, status, hit, fin, wall, rej in rows:
    fin = fin or {}
    print(f"{name:14s} {status:10s} {f(fin.get('samples')):>9s} {f(fin.get('err_all')):>7s} "
          f"{f(fin.get('err_zneg')):>7s} {f(fin.get('err_zpos')):>7s} {f(hit.get('zneg')):>9s} "
          f"{f(hit.get('zpos')):>9s} {f(hit.get('all')):>9s} {wall:7.0f} {rej}")

# growth fit for samples to parity-half error <= 0.05, trunk mix runs
pts = [(hdr["d"], hit["zneg"]) for name, hdr, status, hit, fin, wall, rej in rows
       if name.startswith("mix") and hdr.get("arch") == "trunk" and hdr.get("opt") == "adam"
       and hdr.get("init") == "gaussian" and "zneg" in hit]
if len(set(d for d, _ in pts)) >= 2:
    import numpy as np
    D = np.array([p[0] for p in pts], float); N = np.array([p[1] for p in pts], float)
    for lab, X in [("power law  log N = a log d + c", np.log(D)), ("exponential log N = b d + c", D)]:
        A = np.vstack([X, np.ones_like(X)]).T
        coef, res, *_ = np.linalg.lstsq(A, np.log(N), rcond=None)
        r = np.log(N) - A @ coef
        print(f"{lab}: slope {coef[0]:.3f}, rms resid (log) {np.sqrt(np.mean(r**2)):.3f}")
    print("points (d, samples):", sorted(pts))

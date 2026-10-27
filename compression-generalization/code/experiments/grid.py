"""Run a grid of experiment commands with a process pool (1 thread each).

Usage: python grid.py <grid-name> [--workers 4]
"""
import argparse
import itertools
import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(HERE, "..", "..", "results")


def boolean_grid(name):
    cmds = []
    if name == "bool_n50":
        out = os.path.join(RES, "boolean", "grid_n50.jsonl")
        tasks = [("parity3", 0.0), ("maj5", 0.0), ("junta6", 0.0), ("fullmaj", 0.0), ("and3", 0.0),
                 ("maj5", 0.1), ("parity3", 0.1)]
        for (t, eta), m, s in itertools.product(tasks, [250, 500, 1000, 2000, 4000, 8000, 16000], [0, 1, 2]):
            cmds.append(["boolean_run.py", "--task", t, "--n", "50", "--m", str(m), "--seed", str(s),
                         "--noise", str(eta), "--out", out])
    elif name == "bool_n20":
        out = os.path.join(RES, "boolean", "grid_n20.jsonl")
        for t, m, s in itertools.product(["parity3", "maj5", "junta6", "fullmaj"],
                                         [100, 250, 500, 1000, 2000, 4000], [0, 1, 2]):
            cmds.append(["boolean_run.py", "--task", t, "--n", "20", "--m", str(m), "--seed", str(s), "--out", out])
    else:
        raise ValueError(name)
    return cmds


def done_keys(path):
    import json
    keys = set()
    if os.path.exists(path):
        for line in open(path):
            r = json.loads(line)
            keys.add((r["task"], r["n"], r["m"], r["seed"], r["noise"]))
    return keys


def key_of(cmd):
    a = dict(zip(cmd[1::2], cmd[2::2]))
    return (a["--task"], int(a["--n"]), int(a["--m"]), int(a["--seed"]), float(a.get("--noise", 0.0)))


def run(cmd, log):
    env = dict(os.environ, OMP_NUM_THREADS="1", MKL_NUM_THREADS="1", OPENBLAS_NUM_THREADS="1")
    p = subprocess.run([sys.executable] + cmd, cwd=HERE, env=env, capture_output=True, text=True)
    with open(log, "a") as fh:
        fh.write(" ".join(cmd) + "\n" + p.stdout[-2000:] + (p.stderr[-3000:] if p.returncode else "") + "\n")
    return p.returncode


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("grid")
    ap.add_argument("--workers", type=int, default=4)
    a = ap.parse_args()
    cmds = boolean_grid(a.grid)
    out = cmds[0][cmds[0].index("--out") + 1]
    done = done_keys(out)
    cmds = [c for c in cmds if key_of(c) not in done]
    # run large-m first (slowest) so the tail is short
    cmds.sort(key=lambda c: -int(c[c.index("--m") + 1]))
    print("remaining", len(cmds), flush=True)
    os.makedirs(os.path.join(RES, "boolean"), exist_ok=True)
    log = os.path.join(RES, "boolean", f"{a.grid}.log")
    with ThreadPoolExecutor(a.workers) as ex:
        codes = list(ex.map(lambda c: run(c, log), cmds))
    print("done", a.grid, "failures:", sum(c != 0 for c in codes), "of", len(codes))

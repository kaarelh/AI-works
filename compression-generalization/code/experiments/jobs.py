"""Run shell commands (one per line of a file) with a pool of workers, each
single-threaded.  Lines starting with # are skipped.  Usage: python jobs.py FILE [--workers 4]"""
import argparse
import os
import subprocess
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))

ap = argparse.ArgumentParser()
ap.add_argument("file")
ap.add_argument("--workers", type=int, default=4)
a = ap.parse_args()
cmds = [l.strip() for l in open(a.file) if l.strip() and not l.startswith("#")]
log = a.file + ".log"
env = dict(os.environ, OMP_NUM_THREADS="1", MKL_NUM_THREADS="1", OPENBLAS_NUM_THREADS="1")


def run(c):
    p = subprocess.run(c, shell=True, cwd=HERE, env=env, capture_output=True, text=True)
    with open(log, "a") as fh:
        fh.write(f"$ {c}\n[exit {p.returncode}]\n{p.stdout[-1500:]}\n{p.stderr[-2500:] if p.returncode else ''}\n")
    return p.returncode


with ThreadPoolExecutor(a.workers) as ex:
    codes = list(ex.map(run, cmds))
print("failures", sum(c != 0 for c in codes), "of", len(codes))

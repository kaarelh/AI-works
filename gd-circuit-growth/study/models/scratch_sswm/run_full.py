"""Full evaluation of the calibrated SSWM model on all 21 functions x 11 n x 3 seeds; saves the eval."""
import os, sys, time, json
os.environ.setdefault("OMP_NUM_THREADS", "1"); os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import numpy as np, common as C
from models.sswm import SSWM
OUT = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals/sswm.npz"
t0 = time.time()
M = SSWM()          # calibrated defaults
res = C.evaluate(M, verbose=True)
C.save_eval(res, OUT)
print(f"SAVED {OUT} in {time.time() - t0:.0f}s", flush=True)

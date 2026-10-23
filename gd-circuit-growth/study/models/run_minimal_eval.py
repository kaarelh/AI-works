"""Full-grid evaluation of the minimal model at its CALIB-calibrated constants; also the d-scaling runs.
    python3 models/run_minimal_eval.py [c a]            (DIM / NS_MAX environment variables select the input dimension)
Writes <scratchpad>/model_evals/minimal.npz (d = 30) or minimal_d<DIM>.npz."""
import os, sys, time
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import common as C
from models.minimal import Minimal
OUT = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals"
c = float(sys.argv[1]) if len(sys.argv) > 1 else 2.5
a = float(sys.argv[2]) if len(sys.argv) > 2 else 16.0
tag = sys.argv[3] if len(sys.argv) > 3 else ""
DSCALE = ["par2", "par3", "par4", "stair5", "mux", "majpar", "maj9"]
t0 = time.time()
if C.D == 30:
    res = C.evaluate(Minimal(c=c, a=a))
    path = f"{OUT}/minimal{tag}.npz"
else:
    res = C.evaluate(Minimal(c=c, a=a), fns=DSCALE, seeds=[0, 1])
    path = f"{OUT}/minimal{tag}_d{C.D}.npz"
C.save_eval(res, path); print("saved", path, f"{time.time() - t0:.0f}s")

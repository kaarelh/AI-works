"""Full-grid evaluation of the race model at its CALIB-calibrated setting (theta=1.5, Q=3, gate='relu')."""
import os, sys, time
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import common as C
from models.race import Race
OUT = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals"
t0 = time.time(); res = C.evaluate(Race(theta=1.5, Q=3, gate="relu"))
C.save_eval(res, f"{OUT}/race.npz"); print("saved race.npz", time.time() - t0)

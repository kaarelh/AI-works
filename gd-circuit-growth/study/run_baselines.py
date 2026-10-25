import sys, common as C
from models.baselines import NNGPKernel, OccamJunta
OUT = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals"
for M in (NNGPKernel(max_n=4096), OccamJunta()):
    res = C.evaluate(M)
    C.save_eval(res, f"{OUT}/{M.name}.npz")
print("BASELINES_DONE")

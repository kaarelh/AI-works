import sys, time, json, numpy as np
sys.path.insert(0, "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/p10_hier")
sys.path.insert(0, "/home/user/AI-works/gd-circuit-growth/study/part10")
from feats import *
from p10_hier.learner import knn_votes

ds = sys.argv[1]; n = int(sys.argv[2])
X, y, Xv, yv, C = load(ds, n, nval=5000)
act, S = neigh(X, 49)
reps = {
    "p9": lambda A: pooled(A, act, S, 9),
    "max4_9": lambda A: maxpool(pooled(A, act, S, 4), S, 9),
    "max9_9": lambda A: maxpool(pooled(A, act, S, 9), S, 9),
    "p9+max4_9": lambda A: np.concatenate([pooled(A, act, S, 9), maxpool(pooled(A, act, S, 4), S, 9)], 1),
    "p25": lambda A: pooled(A, act, S, 25),
    "max4_16": lambda A: maxpool(pooled(A, act, S, 4), S, 16),
}
for nm in sys.argv[3].split(","):
    t0 = time.process_time(); Z = reps[nm](X); Zv = reps[nm](Xv)
    V = knn_votes(Z, y, Zv, C, (1, 3, 9, 27))
    print(json.dumps(dict(ds=ds, n=n, rep=nm, err={k: round(float(np.mean(np.argmax(V[k], 1) != yv)), 4) for k in V}, cpu=round(time.process_time() - t0, 1))), flush=True)

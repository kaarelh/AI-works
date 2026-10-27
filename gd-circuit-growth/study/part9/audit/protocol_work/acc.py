# Summary statistics of the accept-set structure of the signed-sum targets (definitions only; no data, no results).
import sys, re, numpy as np
sys.dont_write_bytecode = True
sys.path.insert(0, "/home/user/AI-works/gd-circuit-growth/study")
import boolfuncs
def runs_of(fn, rel, d=30, nprobe=40000):
    # for a target that is a function of t = signed sum over its first k relevant inputs (no gate), count the number of
    # contiguous runs of accepted t-values; estimate by sampling
    return None
S5 = boolfuncs.make_dl_heldout5_suite(30)
nruns, ks, modes = [], [], []
for nm, t in S5.items():
    if not nm.startswith("h5s"): continue
    m = re.search(r"in \[([^\]]*)\]", t["desc"]); A = [int(float(v)) for v in m.group(1).split(",")]
    k = int(re.search(r"i<=(\d+)", t["desc"]).group(1)); vals = list(range(-k, k + 1, 2))
    acc = [v in A for v in vals]; r = sum(1 for i in range(len(acc)) if acc[i] and (i == 0 or not acc[i - 1]))
    nruns.append(r); ks.append(k); modes.append("gate" if ("xor" in t["desc"] or " and " in t["desc"] or " or " in t["desc"]) else "none")
print("dlheld5 h5s: k", sorted(ks), "accept-set runs (contiguous groups of accepted t values):", sorted(nruns), "gated:", modes.count("gate"), "of", len(modes))
print("dlheld5 names:", sorted(S5))
# reference: accept-set runs of the hand-written dev and dlheld4 symmetric targets, from their definitions (|t|<=1 etc.)
print("dlsymdev runs: sym7 1, ex3of8 1, band11 4 ({-5,-3,3,5}), far9 2, ssym9 1, symxpar 1, twosym 1+2, thrsum 1")
print("dlheld4  runs: sym11 1, ex4of9 1, tail13 2, band10 2, ssym8 1, symxor 1, symand 1, sumpar -, majsym 1")

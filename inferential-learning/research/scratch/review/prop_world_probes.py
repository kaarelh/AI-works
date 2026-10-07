"""Diagnosis check: do the schematic unsound rules that survive the world phase
(vs|10|noise|0 and vs|100|noise|0) disappear when every literal instantiation is
probed (world_probes = 64 instead of 8)?"""
import sys, time, functools
sys.path.insert(0, "/home/user/AI-works/inferential-learning/code")
sys.path.insert(0, "/home/user/AI-works/inferential-learning/code/experiments")
import exp_prop_learning as E
from cil.seqlearn import PruneConfig
for wp in (8, 64):
    E.PruneConfig = functools.partial(PruneConfig, world_probes=wp)
    for N in (10, 100):
        t0 = time.time()
        r = E.run_task(dict(learner="vs", N=N, noise="noise", seed=0, phases=["world"]))
        ev = r["phases"]["world"]
        sch = [u for u in ev["unsound_rules"] if not E._nonstructural(u)]
        print(f"world_probes={wp} N={N}: unsound {ev['n_unsound']}, schematic {sch}, queries {ev['queries']}, "
              f"exploits {ev['attack']['n_exploits']}, {time.time()-t0:.0f}s", flush=True)

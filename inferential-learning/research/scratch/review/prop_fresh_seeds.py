"""Fresh-seed robustness check (seeds 3, 4; never used in the reported grid) for the
propositional `vs` learner at N=50, noise=both (all three phases)."""
import sys, time
sys.path.insert(0, "/home/user/AI-works/inferential-learning/code")
sys.path.insert(0, "/home/user/AI-works/inferential-learning/code/experiments")
import exp_prop_learning as E
for seed in (3, 4):
    t0 = time.time()
    r = E.run_task(dict(learner="vs", N=50, noise="both", seed=seed))
    for ph, ev in r["phases"].items():
        print(seed, ph, "unsound", ev["n_unsound"], "exploits", ev["attack"]["n_exploits"], "bot",
              ev["attack"]["derives_bottom"], "exact+", ev["n_exact_or_stronger"], "compl %.2f" % ev["completeness"],
              "FA %.2f" % ev["heldout"]["invalid"], flush=True)
    print(f"  {time.time()-t0:.0f}s", flush=True)

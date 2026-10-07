"""Fresh-seed robustness check (seeds 3-5, never used in the reported grid) for the
headline algebra configurations at N=200, noise=both, tagged learner."""
import sys, time
sys.path.insert(0, "/home/user/AI-works/inferential-learning/code")
sys.path.insert(0, "/home/user/AI-works/inferential-learning/code/experiments")
import exp_algebra_learning as E
for seed in (3, 4, 5):
    for kind, mode in (("positive", None), ("coherence", "numeral"), ("coherence", "bag"), ("coherence", "step")):
        t0 = time.time()
        task = dict(kind=kind, N=200, noise="both", seed=seed, learner="tagged", attack=True)
        if mode:
            task["mode"] = mode
        r = E.run_task(task)
        print(seed, kind, mode, "exact", r["n_exact"], "unsound", r["n_unsound_active"],
              "FA-OOD %.3f" % r["heldout"]["invalid_ood"]["all"], "C-OOD %.3f" % r["heldout"]["valid_ood"]["all"],
              "attack", r["attack"]["accepted_invalid"], f"{time.time()-t0:.0f}s", flush=True)

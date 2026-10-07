import sys, time
sys.path.insert(0, "/home/user/AI-works/inferential-learning/code/experiments")
sys.path.insert(0, "/home/user/AI-works/inferential-learning/code")
import exp_algebra_learning as E
t=time.time(); H=E.heldout(0); print("heldout", round(time.time()-t,1), {k: len(v) for k,v in H.items()}, flush=True)
for N in [100, 500]:
    t=time.time(); E.corpus_steps(N,"both",0); print("corpus", N, round(time.time()-t,1), flush=True)
for task in [dict(kind="positive", N=500, noise="both", seed=0, learner="tagged", attack=True),
             dict(kind="positive", N=500, noise="both", seed=0, learner="untagged", attack=True),
             dict(kind="positive", N=500, noise="both", seed=0, learner="tagged_m1", attack=True),
             dict(kind="coherence", N=500, noise="both", seed=0, learner="tagged", mode="step"),
             dict(kind="coherence", N=500, noise="both", seed=0, learner="tagged", mode="bag"),
             dict(kind="coherence", N=500, noise="both", seed=0, learner="tagged", mode="numeral"),
             dict(kind="coherence", N=500, noise="both", seed=0, learner="untagged", mode="step"),
             dict(kind="ml", N=500, noise="both", seed=0)]:
    t=time.time(); r=E.run_task(task); print(task["kind"], task.get("learner"), task.get("mode"), round(time.time()-t,1), "exact", r.get("n_exact"), "unsound", r.get("n_unsound_active"), flush=True)

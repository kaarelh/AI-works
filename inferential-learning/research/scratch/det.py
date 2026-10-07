import sys, json, hashlib
sys.path.insert(0, "/home/user/AI-works/inferential-learning/code/experiments")
sys.path.insert(0, "/home/user/AI-works/inferential-learning/code")
import exp_algebra_learning as E
out = []
for task in [dict(kind="coherence", N=100, noise="both", seed=1, learner="untagged", mode="bag"),
             dict(kind="coherence", N=50, noise="both", seed=2, learner="tagged", mode="numeral"),
             dict(kind="positive", N=100, noise="both", seed=0, learner="untagged_ms", attack=True)]:
    r = E.run_task(task); r.pop("seconds")
    out.append(r)
print(hashlib.md5(json.dumps(out, sort_keys=True, default=str).encode()).hexdigest())

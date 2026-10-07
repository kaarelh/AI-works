import sys, json
sys.path.insert(0, "/home/user/AI-works/inferential-learning/code/experiments")
sys.path.insert(0, "/home/user/AI-works/inferential-learning/code")
import exp_algebra_learning as E
recs = json.load(open("/home/user/AI-works/inferential-learning/code/results/algebra_learning.json"))["records"]
for N in [20, 50, 100, 200, 500]:
    for noise in ["clean", "fallacies", "both"]:
        g = E.main_records(recs, "coherence", mode="numeral", N=N, noise=noise)
        tot = sum(len(r["unsound_rules"]) for r in g)
        ok = sum(E.sound_in_total_semantics(u) for r in g for u in r["unsound_rules"])
        sp = sum(E.spurious(u) and not E.sound_in_total_semantics(u) for r in g for u in r["unsound_rules"])
        bad = [u.split(": ",1)[-1] for r in g for u in r["unsound_rules"] if not E.sound_in_total_semantics(u)]
        print(N, noise, tot, ok, "spurious-bad", sp, bad[:6])

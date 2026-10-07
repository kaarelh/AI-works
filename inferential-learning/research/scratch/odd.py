import sys, json, random
sys.path.insert(0, "/home/user/AI-works/inferential-learning/code/experiments")
sys.path.insert(0, "/home/user/AI-works/inferential-learning/code")
import exp_algebra_learning as E
from cil.rules import rule_from_str
from cil.domains.algebra import schema_counterexample_total
recs = [json.loads(l) for l in open("/home/user/AI-works/inferential-learning/code/results/algebra_learning.partial.jsonl") if l.strip()]
for r in recs:
    for u in r.get("unsound_rules", []):
        if not E.sound_in_total_semantics(u):
            print(r["kind"], r["N"], r["noise"], r["seed"], r.get("learner"), r.get("mode"), "|", u)
            print("   cex:", schema_counterexample_total(rule_from_str(u), random.Random(0), 400))

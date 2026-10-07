import sys, json
sys.path.insert(0, "/home/user/AI-works/inferential-learning/code/experiments")
sys.path.insert(0, "/home/user/AI-works/inferential-learning/code")
import exp_algebra_learning as E
recs = [json.loads(l) for l in open("/home/user/AI-works/inferential-learning/code/results/algebra_learning.partial.jsonl") if l.strip()]
recs = json.loads(json.dumps(recs))
print(len(recs))
rep = E.make_report(recs, False)
i = rep.index("### (iii)")
print(rep[i:i+6000])

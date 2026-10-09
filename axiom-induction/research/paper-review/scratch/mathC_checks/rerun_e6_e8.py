# Re-run E6 and E8 by calling their run() functions directly (no files written) and compare with the saved JSON.
import sys, os, json, math
CODE = '/home/user/AI-works/axiom-induction/code/experiments'
sys.path.insert(0, CODE); sys.path.insert(0, os.path.dirname(CODE))
os.chdir(os.path.dirname(os.path.abspath(__file__)))
import common  # noqa
import e6_equivalent as e6, e8_split_l1 as e8
saved6 = json.load(open('/home/user/AI-works/axiom-induction/code/results/e6_equivalent.json'))['results']
maxdiff = 0.0; cnt = 0
for r in saved6:
    new = e6.run((r['gen'], r['seed']))
    for lik in ('L1', 'L1sel'):
        for a, b in zip(r[lik], new[lik]):
            for k, v in a.items():
                if isinstance(v, (int, float)) and k in b and isinstance(b[k], (int, float)):
                    maxdiff = max(maxdiff, abs(v - b[k])); cnt += 1
print('E6: compared', cnt, 'numbers; max |saved - rerun| =', maxdiff)
saved8 = json.load(open('/home/user/AI-works/axiom-induction/code/results/e8_split_l1.json'))['results']
r = saved8[0]
args = (r['gen'], r['seed']) if 'gen' in r else None
print('E8 saved keys:', list(r.keys())[:10])
md = 0.0
for r in saved8:
    new = e8.run((r['gen'], r['seed']))
    for lik in ('L1', 'L0'):
        md = max(md, max(abs(a - b) for a, b in zip(r[lik], new[lik])))
    md = max(md, abs(r['tie_maxdiff'] - new['tie_maxdiff']))
print('E8: runs', len(saved8), 'max |saved - rerun| over log2 BFs and tie =', md)

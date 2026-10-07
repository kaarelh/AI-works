"""Referee check R7: how many *distinct* minimal templates do E9's cross-target merges produce, and how many
oracle calls were needed to refute them?  Re-runs e9's sampling with identical seeds."""
import sys, random, itertools
from collections import Counter
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code/experiments')
import e9_separation as E9
from dtrc.syntax import pp
from dtrc.templates import match, canon, metas, rigid_size
from dtrc.mincover import MinCover
from dtrc.refute import TemplateRefuter
from dtrc.schemas import pa_targets, zf_targets
from dtrc.datasets import NEAR_PA, NEAR_ZF

for label, lang, targets, reps in (('PA-mix targets', 'PA', pa_targets(), 40), ('ZF-mix targets', 'ZF', zf_targets(), 15),
                                   ('PA near-miss targets', 'PA', NEAR_PA, 40), ('ZF near-miss targets', 'ZF', NEAR_ZF, 15)):
    rng = random.Random(len(label))
    names = list(targets)
    cnt = Counter(); per_pair = {}
    R = TemplateRefuter(lang)
    for a, b in itertools.combinations(names, 2):
        for _ in range(reps):
            A = [E9.gen_for(a, targets[a], lang, rng) for _ in range(rng.randint(1, 2))]
            B = [E9.gen_for(b, targets[b], lang, rng) for _ in range(rng.randint(1, 2))]
            D = list(dict.fromkeys(A + B))
            if any(match(targets[b], s) is not None for s in A) or any(match(targets[a], s) is not None for s in B):
                continue
            for T in MinCover(D).minimal():
                cnt[pp(canon(T))] += 1
                per_pair.setdefault((a, b), set()).add(pp(canon(T)))
    print('==', label, 'merges->min templates:', sum(cnt.values()), 'distinct:', len(cnt))
    for t, c in cnt.most_common(12):
        print('   %5d  %s' % (c, t[:150]))

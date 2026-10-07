"""Referee check R3a: record every (sentence, verdict) the oracles produce during DTRC runs on the mixes,
the stress sets (mistakes) and probes, for independent re-checking."""
import sys, random, pickle
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
import dtrc.refute as RF
from dtrc.dtrc import DTRC
from dtrc.datasets import pa_mix, zf_mix, near_miss_pa, near_miss_zf

LOG = []
_orig = RF.Oracle.truth
def truth(self, s):
    r = _orig(self, s)
    LOG.append((self.lang, s, r))
    return r
RF.Oracle.truth = truth

which = sys.argv[1]
if which == 'PA':
    for seed in (0, 1):
        DTRC(RF.TemplateRefuter('PA')).fit([s for s, _ in pa_mix(seed, mistakes=8, true_nontargets=3)])
    DTRC(RF.TemplateRefuter('PA')).fit([s for s, _ in near_miss_pa(0)])
else:
    for seed in (0,):
        DTRC(RF.TemplateRefuter('ZF')).fit([s for s, _ in zf_mix(seed, mistakes=6)])
    DTRC(RF.TemplateRefuter('ZF')).fit([s for s, _ in near_miss_zf(0)])
uniq = {}
for lang, s, r in LOG:
    uniq[(lang, s)] = r
print(which, 'calls', len(LOG), 'unique', len(uniq), 'True', sum(1 for v in uniq.values() if v is True),
      'False', sum(1 for v in uniq.values() if v is False), 'None', sum(1 for v in uniq.values() if v is None))
pickle.dump(uniq, open('log_%s.pkl' % which, 'wb'))

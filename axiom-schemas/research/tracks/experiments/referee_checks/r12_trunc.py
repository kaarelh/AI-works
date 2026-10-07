"""R12: was MinCover ever truncated (caps) in the E3/E4 DTRC runs?"""
import sys
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
from dtrc.refute import TemplateRefuter
from dtrc.dtrc import DTRC
from dtrc.datasets import pa_mix, zf_mix, near_miss_pa, near_miss_zf
tot = {}
for name, lang, mk in [('PA-mix', 'PA', lambda s: pa_mix(s)), ('ZF-mix', 'ZF', lambda s: zf_mix(s)),
                       ('PA-mist', 'PA', lambda s: pa_mix(s, mistakes=8, true_nontargets=3)),
                       ('ZF-mist', 'ZF', lambda s: zf_mix(s, mistakes=6)),
                       ('PA-near', 'PA', near_miss_pa), ('ZF-near', 'ZF', near_miss_zf)]:
    for seed in range(3 if 'ZF' in name else 5):
        m = DTRC(TemplateRefuter(lang)).fit([s for s, _ in mk(seed)])
        ct = sum(int(c.truncated) for c in m.clusters)
        print(name, seed, 'min_calls', m.stats['min_calls'], 'min_truncated', m.stats['min_truncated'], 'final clusters truncated', ct)

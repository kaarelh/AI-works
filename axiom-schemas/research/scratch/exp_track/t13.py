import sys; sys.path.insert(0, '.')
from e4_stress import *
from dtrc.syntax import pp
for (lang, seed) in [('ZF', 1), ('ZF', 2)]:
    data = pa_mix(seed, mistakes=8, true_nontargets=3) if lang == 'PA' else zf_mix(seed, mistakes=6)
    R = TemplateRefuter(lang)
    m = DTRC(R).fit([s for s, _ in data])
    lab = {canon_params(s): l for s, l in data}
    print('=====', lang, seed)
    for c in m.clusters:
        labs = Counter(lab[d] for d in c.data)
        if len(labs) > 1:
            print(len(c.data), dict(labs))
            for d in c.data:
                if lab[d].startswith('MIST') or len(c.data) < 5: print('     ', lab[d], pp(d), 'TRUTH', R.oracle.truth(d))
            print('   ACC:', [pp(T) for T in c.acc] if c.acc else None)
            for T in c.acc: print('      refuted now (bigger budget)?', TemplateRefuter(lang, budget=400).refuted(T, c.data))

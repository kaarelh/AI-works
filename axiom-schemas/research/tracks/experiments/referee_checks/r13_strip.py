"""R13: robustness to the normal form.  The brief's closure-normal form strips the outer universal prefix.
dtrc keeps leading 'forall' (Q's and ZF's axioms are closed sentences; Separation keeps 'forall a').
Here every datum and every target is fully stripped (leading universal quantifiers -> fresh parameters),
then DTRC is re-run on PA-mix and ZF-mix (same seeds) and scored against the stripped targets."""
import sys, random
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code/experiments')
from dtrc.syntax import canon_params, pp, plug, LEAVES, BINDERS, kids, rebuild, params_of
from dtrc.refute import TemplateRefuter, Oracle
from dtrc.dtrc import DTRC
from dtrc.templates import match, is_DT0
from dtrc.metrics import exact_for, targets_of
from dtrc.schemas import pa_targets, zf_targets
from dtrc.datasets import pa_mix, zf_mix
from common import clustering_scores, probe_dtrc

def subst0(t, val, cut=0):
    """replace de Bruijn index cut by the closed term val, decrementing higher indices"""
    h = t[0]
    if h == 'v':
        if t[1] == cut: return val
        return ('v', t[1] - 1) if t[1] > cut else t
    if h in LEAVES: return t
    if h in BINDERS: return (h, subst0(t[1], val, cut + 1))
    if h == 'M': return ('M', t[1], tuple(subst0(a, val, cut) for a in t[2]))
    return rebuild(t, [subst0(k, val, cut) for k in kids(t)])

def strip(f):
    i = 0
    while f[0] == 'all':
        f = subst0(f[1], ('p', 'zz%d' % i)); i += 1
    return f

def strip_template(T):
    """strip the prefix; metavariable arguments that became parameters are dropped (bodies may mention
    template parameters under dtrc's matching semantics)"""
    S = strip(T)
    def go(t):
        if t[0] == 'M':
            return ('M', t[1], tuple(a for a in t[2] if a[0] != 'p'))
        if t[0] in LEAVES: return t
        return rebuild(t, [go(k) for k in kids(t)])
    return canon_params(go(S))

for mix in ('PA', 'ZF'):
    targets = {k: strip_template(T) for k, T in (pa_targets() if mix == 'PA' else zf_targets()).items()}
    assert all(is_DT0(T) for T in targets.values())
    for seed in range(5 if mix == 'PA' else 3):
        raw = pa_mix(seed) if mix == 'PA' else zf_mix(seed)
        data = [(canon_params(strip(s)), l) for s, l in raw]
        # sanity: each datum still matches its stripped target
        miss = sum(1 for s, l in data if match(targets[l], s) is None)
        amb = sum(1 for s, l in dict(data).items() if len(targets_of(s, targets)) > 1)
        m = DTRC(TemplateRefuter(mix)).fit([s for s, _ in data])
        cs = clustering_scores(m, data, targets)
        exact = {k: any(c.acc and exact_for(c.acc, T) for c in m.clusters) for k, T in targets.items()}
        pr = probe_dtrc(m, targets, mix, random.Random(seed), 20, Oracle(mix))
        print(mix, seed, 'unmatched', miss, 'ambiguous data', amb, 'ARI(unambiguous)', cs['ARI'], 'clusters', len(m.clusters),
              'exact %d/%d' % (sum(exact.values()), len(exact)), 'not exact:', [k for k, v in exact.items() if not v],
              'probes/nontarget/refuted %d/%d/%d' % (pr['probes'], pr['nontarget'], pr['refuted']))

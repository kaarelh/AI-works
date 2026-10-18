#!/usr/bin/env python3
"""Explicitly post-hoc polynomial-depth sensitivity of the global bound."""
from pathlib import Path
import datetime,json
ROOT=Path(__file__).resolve().parent

def main():
    protocol=ROOT/'polynomial-depth-calibration-protocol.json'
    if not protocol.exists():
        protocol.write_text(json.dumps(dict(declared_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
            status='Exploratory diagnostic selected after fixed-c failures and global gain values were known; not a predeclared primary result.',
            candidate='Replace primary c=.001 by c_H=.001/H, keeping the same score, tolerance, and normalized simultaneous-noise ball.',
            rationale='An additional linear factor in depth permits proportionally larger global sensitivity while retaining polynomial dependence whenever the theorem is polynomial in c+c^{-1}. No claim about asymptotic depth scaling is inferred from finite depth observations.',
            method='Reuse the existing ordinary global spectral-norm upper bound. These values are float64 unless independently converted to exact-rational proofs.'),indent=2)+'\n')
    certs={p.stem:json.loads(p.read_text()) for p in (ROOT.parent/'certificates'/'model-certificates').glob('*.json') if not p.name.endswith('.partial.json')}
    certs.update({p.stem:json.loads(p.read_text()) for p in (ROOT/'full-cube').glob('*.json')})
    rows=[]
    for ident,m in sorted(certs.items()):
        c=m['config'];gain=m['global_gain_ratio'];h=c['hidden_depth'];bound=.001*gain/h
        rows.append(dict(model=ident,cohort=c['cohort'],task=c['task'],domain='Boolean9' if c['input_mode']=='enumerated_boolean' else 'images',initial_gain=c.get('initial_gain'),optimizer=c['optimizer'],hidden_depth=h,width=c['width'],
                         projected=c.get('internal_spectral_projection') is not None,
                         training_eligible=m['train']['all_margins_above_half'],test_accuracy=m['test']['accuracy'],
                         global_gain_ratio=gain,fixed_c_primary_global_bound=.001*gain,
                         largest_c_from_global_spectral_bound=(1/16)/gain,
                         hidden_depth_times_largest_spectral_c=h*(1/16)/gain,
                         depth_adjusted_c=.001/h,depth_adjusted_global_bound=bound,
                         global_sufficient=bound<=1/16))
    groups=[]
    for domain in ['images','Boolean9']:
        for opt in ['sgd','adam']:
            for eligible in [False,True]:
                selected=[r for r in rows if r['domain']==domain and not r['projected'] and r['optimizer']==opt and (not eligible or r['training_eligible'])]
                if not selected:continue
                groups.append(dict(domain=domain,optimizer=opt,training_eligible_only=eligible,models=len(selected),
                                   global_sufficient=sum(r['global_sufficient'] for r in selected),
                                   maximum_bound=max((r['depth_adjusted_global_bound'] for r in selected),default=None)))
    (ROOT/'polynomial-depth-calibration.json').write_text(json.dumps(dict(groups=groups,models=rows),indent=2)+'\n')
    print(json.dumps(groups,indent=2))

if __name__=='__main__':main()

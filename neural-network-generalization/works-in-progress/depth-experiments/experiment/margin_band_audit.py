#!/usr/bin/env python3
"""Post-protocol secondary score, using existing enclosures and saved attacks."""
from pathlib import Path
import collections,csv,datetime,json,math
ROOT=Path(__file__).resolve().parent
CS=[.001,.003,.01,.03,.0625]

def band(z):
    if math.isnan(z):raise ValueError('NaN interval endpoint')
    return math.copysign(min(.25,max(0.,abs(z)-.25)),z)

def main():
    protocol=ROOT/'margin-band-secondary-protocol.json'
    if not protocol.exists():
        protocol.write_text(json.dumps(dict(declared_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
            status='Exploratory score selected after primary clipped-score outcomes; no training or primary result is replaced.',
            score='U(z)=sign(z)*min(1/4,max(0,abs(z)-1/4))',tolerance=1/16,
            methodology='Apply monotone U to existing raw-output enclosure endpoints. Re-evaluate existing saved primary attack outputs; no new adversarial search. A band-score violation implies a primary cap-half violation, but saved worst-primary attacks need not optimize the band score.',
            primary_unchanged='Clipping at +/-1/2, tolerance1/16, and original five constants remain primary.'),indent=2)+'\n')
    certs={}
    for folder in ['model-certificates','refined-model-certificates']:
        certs.update({p.stem:json.loads(p.read_text()) for p in (ROOT.parent/'certificates'/folder).glob('*.json') if not p.name.endswith('.partial.json')})
    attacks={p.stem:json.loads(p.read_text()) for p in (ROOT/'attacks').glob('*.json')}
    points=[];witnesses=[]
    for ident,cert in sorted(certs.items()):
        for group,data in cert['groups'].items():
            for point in data['rows']:
                z=point['clean_output']
                for c in CS:
                    interval=point['by_c'][str(c)]
                    bound=max(abs(band(interval['lower'])-band(z)),abs(band(interval['upper'])-band(z)))
                    points.append(dict(model=ident,training_eligible=cert['train']['all_margins_above_half'],
                        projected=cert['config'].get('internal_spectral_projection') is not None,
                        group=group,source_index=point['source_index'],c=c,
                        primary_certified=interval['certified']['0.5'],band_certified=bound<=1/16,
                        band_change_upper=bound))
    for ident,attack in sorted(attacks.items()):
        seen=set()
        for w in attack['witnesses']:
            key=(w['group'],w['input_index'],w['radius_constant'])
            change=abs(band(w['perturbed_output'])-band(w['clean_output']))
            if change<=1/16 or key in seen or not w['float64_recheck_pass']:continue
            seen.add(key)
            witnesses.append(dict(model=ident,training_eligible=attack['training_eligible'],
                projected=attack['config'].get('internal_spectral_projection') is not None,
                group=key[0],source_index=key[1],c=key[2],band_change=change,
                source_score_cap=w['score_cap'],source_score_change=w['clipped_change'],saved_witness=w['name']))
    positive_keys={(r['model'],r['group'],r['source_index'],r['c']) for r in points if r['band_certified']}
    assert not any((r['model'],r['group'],r['source_index'],r['c']) in positive_keys for r in witnesses), 'Contradictory band certificate and attack.'
    rows=[]
    for selection in ['all_unconstrained_tanh','training_eligible_unconstrained_tanh']:
        def selected(a):
            config=(certs.get(a['model']) or attacks[a['model']])['config']
            return not a['projected'] and config.get('activation','tanh')=='tanh' and (not selection.startswith('training_eligible') or a['training_eligible'])
        for c in CS:
            for group in ['heldout_uniform','heldout_boundary','random_cube']:
                p=[r for r in points if r['c']==c and r['group']==group and selected(r)]
                w=[r for r in witnesses if r['c']==c and r['group']==group and selected(r)]
                rows.append(dict(selection=selection,c=c,group=group,certified_input_model_pairs=len(p),
                    primary_certificates=sum(r['primary_certified'] for r in p),band_certificates=sum(r['band_certified'] for r in p),
                    saved_band_violations=len(w),qualification='Certificate and attack subsets differ; violations are existing saved attacks, not a new full search.'))
    out=dict(score='signed margin band [1/4,1/2]',status='Exploratory secondary after primary results',
             rows=rows,witnesses=witnesses,points=points)
    (ROOT/'margin-band-secondary.json').write_text(json.dumps(out,indent=2)+'\n')
    with (ROOT/'margin-band-secondary.csv').open('w') as f:
        writer=csv.DictWriter(f,fieldnames=list(rows[0]));writer.writeheader();writer.writerows(rows)
    print(json.dumps(dict(certificate_models=len(certs),attack_models=len(attacks),saved_band_violations=len(witnesses))))

if __name__=='__main__':main()

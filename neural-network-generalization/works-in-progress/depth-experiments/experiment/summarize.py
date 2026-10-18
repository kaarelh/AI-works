#!/usr/bin/env python3
"""Descriptive tables; every declared run, including failures, is retained."""
from pathlib import Path
import collections,csv,json

ROOT=Path(__file__).resolve().parent

def csv_write(path,rows):
    if not rows:return
    with path.open('w') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)

def main():
    models=[json.loads(p.read_text()) for p in sorted((ROOT/'records').glob('*.json'))]
    rows=[]
    for m in models:
        c=m['config'];tr=m['train'];te=m['test']
        rows.append(dict(id=c['id'],cohort=c['cohort'],task=c['task'],features=c['input_mode'],
                         activation=c.get('activation','tanh'),width=c['width'],hidden_depth=c['hidden_depth'],
                         optimizer=c['optimizer'],learning_rate=c['learning_rate'],seed=c['seed'],
                         training_count=tr['count'],training_errors=tr['errors'],training_min_margin=tr['minimum_signed_margin'],
                         training_margin_fraction=tr['fraction_margin_above_half'],training_eligible=tr['all_margins_above_half'],
                         test_count=te['count'],test_accuracy=te['accuracy'],test_margin_fraction=te['fraction_margin_above_half'],
                         readout_energy=m['readout_energy'],training_seconds=m['train_elapsed_seconds'],
                         training_failure=m['training_failure']))
    csv_write(ROOT/'models-summary.csv',rows)
    grouped=[]
    for key in sorted({(r['cohort'],r['task'],r['activation'],r['width'],r['hidden_depth'],r['optimizer']) for r in rows}):
        rr=[r for r in rows if (r['cohort'],r['task'],r['activation'],r['width'],r['hidden_depth'],r['optimizer'])==key]
        grouped.append(dict(zip(['cohort','task','activation','width','hidden_depth','optimizer'],key))|
                       dict(models=len(rr),train_zero_errors=sum(r['training_errors']==0 for r in rr),training_eligible=sum(r['training_eligible'] for r in rr),
                            train_accuracy_min=min(1-r['training_errors']/r['training_count'] for r in rr),
                            test_accuracy_min=min(r['test_accuracy'] for r in rr),test_accuracy_max=max(r['test_accuracy'] for r in rr)))
    csv_write(ROOT/'training-groups.csv',grouped)

    attacks=[json.loads(p.read_text()) for p in sorted((ROOT/'attacks').glob('*.json'))]
    agroups=[]
    for activation in ['tanh','relu']:
        for domain in ['image','boolean9']:
            for eligible in ['all','training_eligible']:
                mm=[m for m in attacks if m['config'].get('activation','tanh')==activation and (eligible=='all' or m['training_eligible']) and ((m['config']['input_mode']=='enumerated_boolean')==(domain=='boolean9'))]
                for cap in [.5,1.]:
                    for c in [.001,.003,.01,.03,.0625]:
                        for group in ['heldout_uniform','heldout_boundary','random_cube']:
                            rr=[r for m in mm for r in m['records'] if r['score_cap']==cap and r['radius_constant']==c and r['group']==group]
                            if not rr:continue
                            agroups.append(dict(domain=domain,activation=activation,eligibility=eligible,score_cap=cap,radius_constant=c,group=group,
                                                models=len(mm),input_model_pairs=sum(r['count'] for r in rr),
                                                violations_found=sum(r['violations_found'] for r in rr),
                                                models_with_violations=sum(r['violations_found']>0 for r in rr),
                                                maximum_change=max(r['maximum_change'] for r in rr)))
    csv_write(ROOT/'attack-summary.csv',agroups)

    certmap={}
    for directory in ['model-certificates','refined-model-certificates']:
        certmap.update({p.stem:json.loads(p.read_text()) for p in sorted((ROOT.parent/'certificates'/directory).glob('*.json')) if not p.name.endswith('.partial.json')})
    certs=list(certmap.values())
    cgroups=[]
    for eligible in ['all','training_eligible']:
        mm=[m for m in certs if eligible=='all' or m['train']['all_margins_above_half']]
        for cap in [.5,1.]:
            for c in [.001,.003,.01,.03,.0625]:
                for group in ['heldout_uniform','heldout_boundary','random_cube']:
                    rr=[r for m in mm for r in m['groups'].get(group,{}).get('rows',[])]
                    if not rr:continue
                    cgroups.append(dict(domain="image",eligibility=eligible,score_cap=cap,radius_constant=c,group=group,
                                        models=len(mm),input_model_pairs=len(rr),
                                        certified_pairs=sum(r['by_c'][str(c)]['certified'][str(cap)] for r in rr),
                                        global_sufficient_models=sum(m['global_sufficient_by_c'][str(c)] for m in mm)))
    csv_write(ROOT/'certificate-summary.csv',cgroups)

    quant=[json.loads(p.read_text()) for p in sorted((ROOT/'quantization').glob('*.json'))]
    qgroups=[]
    for activation in ['tanh','relu']:
        for domain in ['image','boolean9']:
            for eligibility in ['all','training_eligible']:
                mm=[m for m in quant if m['config'].get('activation','tanh')==activation and (eligibility=='all' or m['training_eligible']) and ((m['config']['input_mode']=='enumerated_boolean')==(domain=='boolean9'))]
                for fmt in ['float16','bfloat16']:
                    for mode in ['hidden_only','hidden_and_output']:
                        rr=[r for m in mm for r in m['rows'] if r['format']==fmt and r['mode']==mode]
                        if not rr:continue
                        qgroups.append(dict(domain=domain,activation=activation,eligibility=eligibility,format=fmt,mode=mode,models=len(mm),
                                            input_model_pairs=sum(r['count'] for r in rr),sign_changes=sum(r['sign_changes'] for r in rr),
                                            clip_half_violations=sum(r['cap0.5_violations'] for r in rr),
                                            maximum_clipped_change=max(r['cap0.5_max_change'] for r in rr)))
    csv_write(ROOT/'quantization-summary.csv',qgroups)
    snapshot=dict(models=len(models),training_eligible=sum(m['train']['all_margins_above_half'] for m in models),
                  complete_attack_models=len(attacks),complete_certificate_models=len(certs),complete_quantization_models=len(quant),
                  training_groups=grouped,attack_groups=agroups,certificate_groups=cgroups,quantization_groups=qgroups,
                  qualification='Descriptive pooled input/model counts reuse examples and are not independent statistical test-sample counts. Attack failure is not a certificate. Pointwise bounds use floating point unless separately interval-verified. Refined pointwise certificates supersede base certificates when available.')
    (ROOT/'summary.json').write_text(json.dumps(snapshot,indent=2)+'\n')
    print(json.dumps({k:v for k,v in snapshot.items() if not isinstance(v,list)},indent=2))

if __name__=='__main__':main()

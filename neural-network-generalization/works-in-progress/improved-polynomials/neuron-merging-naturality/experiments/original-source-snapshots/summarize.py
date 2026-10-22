#!/usr/bin/env python3
"""Summarize exploratory clustering without treating search failure as falsity."""
import json,csv
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

ROOT=Path(__file__).resolve().parent
CLASSES=[('unsigned_balanced',False,False),('signed_balanced',True,False),('unsigned_unbalanced',False,True),('signed_unbalanced',True,True)]
VARIANTS=['raw','scale_invariant_budget4','readout_l1_budget4','rms_normalized_readout','scale_invariant_budget16_exploratory']

def accepted(trial,signed,unbalanced):
    return (signed or not trial['signed']) and (unbalanced or trial['balanced'])

def best(r,variant,signed,unbalanced,cap=None):
    cap=r['variants'][variant]['q_cap'] if cap is None else cap
    ts=[t for t in r['trials'] if accepted(t,signed,unbalanced) and t['q']<=cap]
    return min(t['variants'][variant]['max_clipped_difference'] for t in ts)

def minimum_passing(r,variant,signed,unbalanced):
    ts=[t for t in r['trials'] if accepted(t,signed,unbalanced) and t['variants'][variant]['passes_float64']]
    return min(t['q'] for t in ts)

def main():
    records=[json.loads(p.read_text()) for p in sorted((ROOT/'results-v3').glob('*.json'))]
    assert len(records)==155 and all(r['schema_version']==4 for r in records)
    cohorts={name:[r for r in records if r['id'].startswith(name+'-')] for name in ['round2','public','fresh','freshH23']}
    cohorts['fresh_combined']=cohorts['fresh']+cohorts['freshH23']
    counts={}
    for cohort,rs in cohorts.items():
        counts[cohort]={'models':len(rs),'hard_training_margin_fits':sum(r['training_all_margins_above_half'] for r in rs),'variants':{}}
        for variant in VARIANTS:
            nontrivial=[r for r in rs if not r['variants'][variant]['trivial']]
            fits=[r for r in nontrivial if r['training_minimum_signed_margin']*r['variants'][variant]['scale']>.5]
            counts[cohort]['variants'][variant]={'automatic_q_equals_N':len(rs)-len(nontrivial),'nontrivial_models':len(nontrivial),'hard_margin_nontrivial':len(fits),'classes':{name:{'witnesses_among_nontrivial':sum(best(r,variant,s,u)<=1/16 for r in nontrivial),'witnesses_among_hard_margin_nontrivial':sum(best(r,variant,s,u)<=1/16 for r in fits)} for name,s,u in CLASSES}}
    calibration={}
    for a in [1,2,4,8,16,32,64]:
        rs=cohorts['fresh_combined'];nt=[r for r in rs if 1+a*r['variants']['raw']['Ev']<r['N']]
        calibration[str(a)]={'nontrivial':len(nt),'automatic':len(rs)-len(nt),'signed_unbalanced_witnesses':sum(best(r,'raw',True,True,cap=min(r['N'],int(1+a*r['variants']['raw']['Ev'])))<=1/16 for r in nt)}
    q1={json.loads(p.read_text())['id']:json.loads(p.read_text()) for p in (ROOT/'q1-output-results').glob('*.json')}
    q1_summary={'models':len(q1),'q1_fullcube_float64_witnesses':sum(r['best']['passes_float64'] for r in q1.values()),'models_with_q1_witness':[r['id'] for r in q1.values() if r['best']['passes_float64']],'combined_with_v3':{}}
    for variant in ['raw','scale_invariant_budget4','readout_l1_budget4']:
        rs=[r for r in cohorts['fresh_combined'] if not r['variants'][variant]['trivial']]
        q1_summary['combined_with_v3'][variant]={'nontrivial':len(rs),'signed_balanced_witnesses':sum(best(r,variant,True,False)<=1/16 or q1[r['id']]['best']['passes_float64'] for r in rs),'signed_unbalanced_witnesses':sum(best(r,variant,True,True)<=1/16 or q1[r['id']]['best']['passes_float64'] for r in rs)}
    summary={'scope':'Exploratory two-seed clustering search. All small cubes evaluated in float64; only separately identified interval certificates are rigorous. Search non-findings do not prove exclusion. Nested-class totals reuse all candidate methods in the class.','models_evaluated':len(records),'cohorts':counts,'fresh_calibration_scan_q_le_1_plus_a_Ev':calibration,'separate_output_aware_q1_search':q1_summary}
    (ROOT/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
    with (ROOT/'model-summary.csv').open('w') as f:
        fields=['id','d','N','H','hard_training_margin_fit','Ev','variant','q_cap','automatic','class','best_eligible_max_clipped_difference','minimum_passing_searched_q']
        writer=csv.DictWriter(f,fieldnames=fields);writer.writeheader()
        for r in records:
            for variant in VARIANTS:
                for name,s,u in CLASSES:
                    writer.writerow(dict(id=r['id'],d=r['d'],N=r['N'],H=r['H'],hard_training_margin_fit=r['training_minimum_signed_margin']*r['variants'][variant]['scale']>.5,Ev=r['variants'][variant]['Ev'],variant=variant,q_cap=r['variants'][variant]['q_cap'],automatic=r['variants'][variant]['trivial'],**{'class':name},best_eligible_max_clipped_difference=best(r,variant,s,u),minimum_passing_searched_q=minimum_passing(r,variant,s,u)))
    selected=['fresh-000-majority5-H4-N32-adam-s0','fresh-004-majority5-H4-N64-adam-s0','fresh-008-parity3-H4-N32-adam-s0','fresh-012-parity3-H4-N64-adam-s0']
    fig,axs=plt.subplots(2,2,figsize=(10,7),sharey=True)
    styles=['#d95f02','#7570b3','#1b9e77','#000000']
    for ax,ident in zip(axs.flat,selected):
        r=next(r for r in records if r['id']==ident);qs=sorted({t['q'] for t in r['trials']})
        for (name,s,u),color in zip(CLASSES,styles):
            ys=[min(t['variants']['raw']['max_clipped_difference'] for t in r['trials'] if t['q']==q and accepted(t,s,u)) for q in qs]
            ax.plot(qs,ys,'o-',markersize=3,label=name.replace('_',' '),color=color)
        ax.axhline(1/16,color='red',linestyle=':',label='allowed difference 1/16')
        ax.axvline(r['variants']['raw']['q_cap'],color='gray',linestyle='--',label='baseline energy cap')
        ax.set_title(ident.split('fresh-')[1]);ax.set_xlabel('Population count q');ax.set_ylabel('Max full-cube clipped-score change');ax.set_ylim(-.025,1.04)
    handles,labels=axs.flat[0].get_legend_handles_labels();fig.legend(handles,labels,loc='lower center',ncol=3,fontsize=8)
    fig.suptitle('Activation-clustering search only; separate output-aware q=1 search is not shown\nAll original training margins exceed 1/2; no post-training weight scaling',fontsize=11)
    fig.tight_layout(rect=[0,.10,1,.92]);fig.savefig(ROOT/'compression-curves.pdf');fig.savefig(ROOT/'compression-curves.png',dpi=160)
    fig,ax=plt.subplots(figsize=(6,5))
    for name,color in [('fresh','#1b9e77'),('freshH23','#7570b3')]:
        rs=cohorts[name];ev=[1+r['variants']['raw']['Ev'] for r in rs];q=[1 if q1[r['id']]['best']['passes_float64'] else minimum_passing(r,'raw',True,True) for r in rs]
        ax.scatter(ev,q,c=color,label='H=4, MSE + ordinary weight decay' if name=='fresh' else 'H=2/3, MSE, no weight decay',alpha=.8)
    lim=max(ax.get_xlim()[1],ax.get_ylim()[1]);ax.plot([1,lim],[1,lim],'k--',label='q = 1 + Ev');ax.set_xlim(0,lim);ax.set_ylim(0,lim)
    ax.set_xlabel('Baseline population budget 1 + Ev');ax.set_ylabel('Smallest searched q with a witness');ax.legend(fontsize=8);ax.set_title('Signed populations: clustering + output-aware q=1 search\nSearch failures are not impossibility results',fontsize=11)
    fig.tight_layout();fig.savefig(ROOT/'energy-versus-compression.pdf');fig.savefig(ROOT/'energy-versus-compression.png',dpi=160)
    print(json.dumps(counts['fresh_combined'],indent=2))

if __name__=='__main__':main()

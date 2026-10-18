#!/usr/bin/env python3
"""Conservative fixed-denominator certificate/attack figures for the paper."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
os.environ['MPLCONFIGDIR']='/tmp/depth3-matplotlib-cache'
os.environ['XDG_CACHE_HOME']='/tmp/depth3-font-cache'
from pathlib import Path
import argparse,datetime,json
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Patch

ROOT=Path(__file__).resolve().parent
CS=[.001,.003,.01,.03,.0625]
COLORS=dict(certified='#248575',attack='#c45136',unresolved='#e6e6e6')

def sources(rec,group):
    c=rec['config']
    if group=='heldout_uniform':return np.random.default_rng(30000+c['seed']).choice(rec['test']['count'],min(128,rec['test']['count']),replace=False)[:32]
    if group=='heldout_boundary':return np.argsort(np.abs(rec['per_test_output']),kind='stable')[:16]
    return np.arange(32)

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--declare',action='store_true');ap.add_argument('--eligible-only',action='store_true');ap.add_argument('--deep',action='store_true');args=ap.parse_args()
    if args.declare:
        p=ROOT/'figure-protocol.json'
        if p.exists():raise RuntimeError('Alreadydeclared')
        p.write_text(json.dumps(dict(at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
           status='Display/subset rules fixed before extension/projected outcomes; initial36 outcomes partlyvisible.',
           cohort='Allunconstrained tanh models, includingfailures. ReLUandexplicitprojectionseparate.',
           fixed_per_model_subsets='First32of128predeclareduniformheldoutpoints; all16predeclaredboundarypoints; first32of64predeclaredBooleanprobes. Samepointsatallc. N512computebudgetmaylimituniformcertificatestofirst32.',
           classification='Green=finite-noise sufficientbound; red=explicitstoredperturbationpassingstrictbudget+score recheck; hatchedgray=unresolved ornotyetassessed. Positivecertificateandcounterexampleoverlap raiseserror.',
           numerics='Figures usefloat64checks; selected rigorousintervalproofs describedseparately. Neverequatefailedcertificatewithcounterexample.',
           matched_pairs=[[200,104],[201,105],[202,204],[203,26]],
           comparison='Plotrawtestaccuracy andlargesttestedcwithglobalsufficientcertificate; latterisacertifiedlowerboundonstability,notestimateofactualmaximum.'),indent=2)+'\n');print(p);return
    assert (ROOT/'figure-protocol.json').exists()
    dest=ROOT.parent/'figures';dest.mkdir(exist_ok=True)
    models={}
    for p in (ROOT/'records').glob('*.json'):
        r=json.loads(p.read_text());models[r['config']['index']]=r
    selected=[r for r in models.values() if r['config'].get('activation','tanh')=='tanh' and r['config'].get('internal_spectral_projection') is None and r['config']['input_mode']!='enumerated_boolean']
    if args.eligible_only:selected=[r for r in selected if r['train']['all_margins_above_half']]
    certs={p.stem:json.loads(p.read_text()) for p in (ROOT.parent/'certificates'/'model-certificates').glob('*.json') if not p.name.endswith('.partial.json')}
    certs.update({p.stem:json.loads(p.read_text()) for p in (ROOT.parent/'certificates'/'refined-model-certificates').glob('*.json') if not p.name.endswith('.partial.json')})
    attacks={p.stem:json.loads(p.read_text()) for p in (ROOT/'attacks').glob('*.json')}
    plt.rcParams.update({'font.family':'DejaVu Sans','font.size':8,'axes.spines.top':False,'axes.spines.right':False,'pdf.fonttype':42,'ps.fonttype':42})
    depths=[64,128] if args.deep else [4,16,32]
    fig,axes=plt.subplots(len(depths),3,figsize=(8.1,2.05*len(depths)+.65),sharey=True);counts=[]
    groups=['heldout_uniform','heldout_boundary','random_cube']
    titles=['Uniform held-out images','Images nearest decision boundary','Uniform Boolean-cube probes']
    for row,h in enumerate(depths):
        mm=sorted([r for r in selected if r['config']['hidden_depth']==h],key=lambda r:r['config']['index'])
        for col,group in enumerate(groups):
            a=axes[row,col];bars=[]
            if not mm:
                a.set_axis_off();a.text(.5,.5,f'Depth {h}: no training-margin\neligible models',ha='center',va='center',transform=a.transAxes)
                continue
            for c in CS:
                count=dict(certified=0,attack=0,unresolved=0)
                for rec in mm:
                    ident=rec['config']['id'];cert=certs.get(ident);attack=attacks.get(ident)
                    positive={r['source_index']:r['by_c'][str(c)]['certified']['0.5'] for r in cert['groups'].get(group,{}).get('rows',[])} if cert else {}
                    negative={w['input_index'] for w in attack['witnesses'] if w['score_cap']==.5 and w['radius_constant']==c and w['group']==group and w['float64_recheck_pass']} if attack else set()
                    for idx in sources(rec,group):
                        good=positive.get(int(idx),False);bad=int(idx) in negative
                        if good and bad:raise RuntimeError(f'Contradictorycertificateandattack: {ident},{group},{idx},{c}')
                        count['certified' if good else ('attack' if bad else 'unresolved')]+=1
                denominator=sum(count.values());bars.append([count[k]/denominator if denominator else 0 for k in ['certified','attack','unresolved']])
                counts.append(dict(hidden_depth=h,group=group,c=c,models=len(mm),denominator=denominator,**count))
            bars=np.array(bars);bottom=np.zeros(len(CS))
            for j,key in enumerate(['certified','attack','unresolved']):
                a.bar(range(len(CS)),bars[:,j],bottom=bottom,color=COLORS[key],width=.77,
                      edgecolor='#777777' if key=='unresolved' else 'white',linewidth=.35,hatch='////' if key=='unresolved' else None)
                bottom+=bars[:,j]
            a.set_xticks(range(len(CS)),['.001','.003','.01','.03','.0625'],rotation=45,ha='right')
            a.set_ylim(0,1);a.set_yticks([0,.5,1],['0%','50%','100%']);a.grid(axis='y',alpha=.15);a.set_axisbelow(True)
            if row==0:a.set_title(titles[col],fontsize=9)
            if col==0:a.set_ylabel(f'Hidden depth {h}\n{len(mm)} models')
            if row==len(depths)-1:a.set_xlabel('Noise constant c')
            eligible=sum(r['train']['all_margins_above_half'] for r in mm)
            a.text(.02,.05,f'{eligible}/{len(mm)} train-margin eligible',transform=a.transAxes,fontsize=6.5,
                   bbox=dict(facecolor='white',alpha=.8,edgecolor='none',pad=1.5))
    handles=[Patch(facecolor=COLORS['certified'],label='Sufficient certificate (float64)'),
             Patch(facecolor=COLORS['attack'],label='Saved attack, budget checked (float64)'),
             Patch(facecolor=COLORS['unresolved'],edgecolor='#777777',hatch='////',label='Unresolved / not assessed')]
    fig.legend(handles=handles,loc='upper center',ncol=1,bbox_to_anchor=(.5,1.015),frameon=False,fontsize=8)
    fig.tight_layout(rect=[0,0,1,.93])
    stem='certificate-coverage-eligible' if args.eligible_only else 'certificate-coverage'
    if args.deep:stem+='-deep'
    for ext in ['pdf','png']:fig.savefig(dest/f'{stem}.{ext}',dpi=180,bbox_inches='tight')
    plt.close(fig);(dest/f'{stem}-counts.json').write_text(json.dumps(counts,indent=2)+'\n')

    pairs=[(200,104),(201,105),(202,204),(203,26)]
    if all(i in models for pair in pairs for i in pair):
        fig,(ax,bx)=plt.subplots(1,2,figsize=(8.1,3.25));labels=[];details=[]
        for j,(projected,reference) in enumerate(pairs):
            rr=models[reference];pp=models[projected];c=pp['config'];labels.append(('MNIST even/odd' if c['task']=='mnistevenodd' else 'Fashion 0/6')+f'\nDepth {c["hidden_depth"]}')
            ys=[100*rr['test']['accuracy'],100*pp['test']['accuracy']]
            ax.plot([j-.14,j+.14],ys,color='#777777',linewidth=1)
            ax.scatter(j-.14,ys[0],color='#5969a3',s=35,zorder=3);ax.scatter(j+.14,ys[1],color='#248575',s=35,zorder=3)
            for x,y in zip([j-.14,j+.14],ys):ax.annotate(f'{y:.1f}',(x,y),xytext=(0,5),textcoords='offset points',ha='center',fontsize=7)
            vals=[]
            for idx in [reference,projected]:
                rec=models[idx];cert=certs.get(rec['config']['id'])
                passed=[a for a in CS if cert and cert['global_sufficient_by_c'][str(a)]]
                vals.append(max(passed) if passed else .0005)
            bx.plot([j-.14,j+.14],vals,color='#777777',linewidth=1)
            bx.scatter(j-.14,vals[0],color='#5969a3',s=35,marker='o' if vals[0]>.0005 else 'v',zorder=3)
            bx.scatter(j+.14,vals[1],color='#248575',s=35,marker='o' if vals[1]>.0005 else 'v',zorder=3)
            details.append(dict(projected=projected,reference=reference,test_accuracies=ys,largest_grid_c_globally_certified=[None if x==.0005 else x for x in vals]))
        ax.set_ylabel('Official test accuracy (%)');ax.set_ylim(min(70,ax.get_ylim()[0]-2),101)
        bx.set_yscale('log');bx.set_ylim(.00035,.1);bx.set_yticks([.0005,.001,.003,.01,.03,.0625],['none','.001','.003','.01','.03','.0625'])
        bx.set_ylabel('Largest tested c with a global\nsufficient certificate')
        for a in [ax,bx]:a.set_xticks(range(4),labels,fontsize=7);a.grid(axis='y',alpha=.2);a.set_axisbelow(True)
        fig.legend([plt.Line2D([],[],color='#5969a3',marker='o',linestyle=''),plt.Line2D([],[],color='#248575',marker='o',linestyle='')],
                   ['Unconstrained SGD','Same SGD + spectral projection'],loc='upper center',ncol=2,frameon=False)
        fig.tight_layout(rect=[0,0,1,.92])
        for ext in ['pdf','png']:fig.savefig(dest/f'projected-sgd-comparison.{ext}',dpi=180,bbox_inches='tight')
        plt.close(fig);(dest/'projected-sgd-comparison-data.json').write_text(json.dumps(details,indent=2)+'\n')
    print(dest)

if __name__=='__main__':main()

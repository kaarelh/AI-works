#!/usr/bin/env python3
"""Freeze a complete-cohort paper table from preserved training records."""
from pathlib import Path
import datetime,json
ROOT=Path(__file__).resolve().parent

def main():
    configs=[]
    for protocol in sorted(ROOT.glob('predeclared-*.json')):
        configs.extend(json.loads(protocol.read_text()).get('configs',[]))
    assert len({c['index'] for c in configs})==len(configs)
    missing=[c['id'] for c in configs if not (ROOT/'records'/f"{c['id']}.json").exists()]
    if missing:raise RuntimeError('Cannot freeze an incomplete cohort: '+', '.join(missing))
    models=[json.loads((ROOT/'records'/f"{c['id']}.json").read_text()) for c in configs]
    labels=[('main-continuous','Initial continuous images'),('boolean-match','Initial Boolean images'),
            ('width-extension','Initial width-$256$ extension'),('wide-tanh','Width-$512$ extension'),
            ('all-digit-parity','All MNIST, even versus odd'),('relu-comparison','ReLU comparisons'),
            ('projected-sgd','Spectral-projection intervention'),('projection-reference','Additional matched reference'),
            ('projected-sgd-continuation','Projected-SGD continuation'),
            ('deep-sgd-continuation','Depth-$32$ SGD continuations'),
            ('deep-calibration-extension','Depth-$64/128$ extension'),
            ('deeper-sgd-continuation','Depth-$64/128$ continuations'),
            ('boolean-domain-extension','Enumerated Boolean domains')]
    rows=[]
    for key,label in labels:
        selected=[m for m in models if m['config']['cohort']==key]
        eligible=sum(m['train']['all_margins_above_half'] for m in selected)
        minimum=min(m['test']['accuracy'] for m in selected)*100;maximum=max(m['test']['accuracy'] for m in selected)*100
        rows.append(dict(cohort=key,label=label,models=len(selected),training_eligible=eligible,
                         test_accuracy_min=minimum,test_accuracy_max=maximum))
    assert sum(row['models'] for row in rows)==len(models), 'A declared cohort needs a table label.'
    out=[r'\begin{table}[t]',r'\centering\small',r'\begin{tabular}{lrrr}',r'\toprule',
         r'Cohort & Runs & All train margins $>1/2$ & Test accuracy (\%) \\',r'\midrule']
    for row in rows:
        accuracy=f"{row['test_accuracy_min']:.2f}" if row['test_accuracy_min']==row['test_accuracy_max'] else f"{row['test_accuracy_min']:.2f}--{row['test_accuracy_max']:.2f}"
        out.append(f"{row['label']} & {row['models']} & {row['training_eligible']} & {accuracy}"+r' \\')
    total=len(models);eligible=sum(m['train']['all_margins_above_half'] for m in models)
    out.extend([r'\midrule',f'Total & {total} & {eligible} &'+r' \\',r'\bottomrule',r'\end{tabular}',
                r'\caption{Every declared training run is retained. Accuracy ranges are descriptive extrema over the specified cohort, not confidence intervals. Continuations are additional parameterizations of retained original runs. Training-margin eligibility is separate from robustness.}',
                r'\label{tab:training-cohorts}',r'\end{table}'])
    byindex={m['config']['index']:m for m in models};pairs=[]
    out.extend([r'\begin{table}[t]',r'\centering\small',r'\begin{tabular}{lrrrr}',r'\toprule',
                r' & \multicolumn{2}{c}{Test accuracy (\%)} & \multicolumn{2}{c}{Minimum train margin} \\',
                r'Task, depth & SGD & Projected & SGD & Projected \\',r'\midrule'])
    for projected,reference in [(200,104),(201,105),(202,204),(203,26)]:
        p=byindex[projected];r=byindex[reference];c=p['config'];label=('MNIST even/odd' if c['task']=='mnistevenodd' else 'Fashion 0/6')+f", $H={c['hidden_depth']}$"
        vals=[100*r['test']['accuracy'],100*p['test']['accuracy'],r['train']['minimum_signed_margin'],p['train']['minimum_signed_margin']]
        out.append(label+' & '+' & '.join(f'{v:.2f}' for v in vals)+r' \\')
        pairs.append(dict(projected=projected,reference=reference,values=vals))
    out.extend([r'\bottomrule',r'\end{tabular}',r'\caption{Matched spectral-projection intervention. The models share initialization and minibatch order, and receive the same gradient-step budget. Raw readouts are not rescaled.}',r'\label{tab:projected-training}',r'\end{table}'])
    (ROOT/'results-tables.tex').write_text('\n'.join(out)+'\n')
    (ROOT/'results-tables-data.json').write_text(json.dumps(dict(frozen_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),models=total,eligible=eligible,cohort_rows=rows,matched_pairs=pairs),indent=2)+'\n')
    print(json.dumps(dict(models=total,eligible=eligible)))

if __name__=='__main__':main()

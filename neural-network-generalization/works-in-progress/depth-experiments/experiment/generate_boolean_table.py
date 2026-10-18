#!/usr/bin/env python3
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parent

def main():
    records=[json.loads(p.read_text()) for p in sorted((ROOT/'full-cube').glob('*.json'))]
    if len(records)!=6:raise RuntimeError('Wait for all six exhaustive audits before freezing the table.')
    refinement_path=ROOT/'boolean-single-refinement.json'
    refinement=json.loads(refinement_path.read_text()) if refinement_path.exists() else None
    out=[r'\begin{table}[t]',r'\centering\small',r'\begin{tabular}{lrrrrrr}',r'\toprule',
         r'Target & $H$ & Min. margin & Test acc. & $c=.001$ & $c=.001/H$ & All-input $c_*$ \\',r'\midrule']
    data=[]
    for r in records:
        c=r['config'];task='Majority9' if c['task']=='majority9' else 'Recursive majority'
        fixed=next(a for a in r['summaries'] if a['c']==.001);adjusted=next(a for a in r['summaries'] if a['calibration']=='inverse-depth')
        refined=False
        if refinement and refinement['certified'] and c['id']==refinement['model']:
            assert fixed['unresolved_indices']==[refinement['input_index']]
            fixed.update(certified=512,all_boolean_inputs_certified=True,unresolved_indices=[],
                         initial_certified=511,refinement_file=refinement_path.name)
            refined=True
        allpass=[a['c'] for a in r['summaries'] if a['calibration']=='original-fixed' and a['all_boolean_inputs_certified']]
        largest=f'{max(allpass):g}' if allpass else '---'
        out.append(f"{task} & {c['hidden_depth']} & {r['train']['minimum_signed_margin']:.2f} & {100*r['test']['accuracy']:.2f}\\% & {fixed['certified']}/512 & {adjusted['certified']}/512 & {largest}"+r' \\')
        data.append(dict(model=c['id'],train=r['train'],test=r['test'],full_cube_accuracy=r['full_cube_accuracy'],summaries=r['summaries'],single_vertex_refinement=refined))
    out.extend([r'\bottomrule',r'\end{tabular}',r'\caption{Exact finite Boolean domains, with float64 evaluation of sufficient finite-radius inequalities. Certified counts cover all $512$ inputs; $c_*$ is the largest original-grid constant for which every input passes, a lower bound on the valid radius rather than an estimate of its maximum. The minimum margin is over the $400$ training inputs. One initially unresolved vertex at $c=.001$ receives a separately recorded stronger certificate. A failed sufficient certificate remains unresolved; it is not a counterexample.}',r'\label{tab:boolean-fullcube}',r'\end{table}'])
    (ROOT/'boolean-results-table.tex').write_text('\n'.join(out)+'\n')
    (ROOT/'boolean-results-table-data.json').write_text(json.dumps(data,indent=2)+'\n')

if __name__=='__main__':main()

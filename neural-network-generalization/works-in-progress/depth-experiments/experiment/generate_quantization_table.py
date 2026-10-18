#!/usr/bin/env python3
"""Aggregate the fixed activation-rounding diagnostic, retaining every image fit."""
from pathlib import Path
import collections,json

ROOT=Path(__file__).resolve().parent

def main():
    groups=collections.defaultdict(list)
    modelids=[]
    for path in sorted((ROOT/'records').glob('*.json')):
        rec=json.loads(path.read_text());c=rec['config']
        if c.get('activation','tanh')!='tanh' or c['input_mode']=='enumerated_boolean':continue
        qpath=ROOT/'quantization'/path.name
        if not qpath.exists():raise RuntimeError('Missing rounding diagnostic: '+path.name)
        record=json.loads(qpath.read_text());modelids.append(c['id'])
        for row in record['rows']:groups[(row['format'],row['mode'])].append(row)
    rows=[]
    for (kind,mode),records in groups.items():
        count=sum(r['count'] for r in records)
        rows.append(dict(format=kind,mode=mode,models=len(records),input_model_pairs=count,
            sign_changes=sum(r['sign_changes'] for r in records),
            clipped_score_violations=sum(r['cap0.5_violations'] for r in records),
            nonfinite=sum(r['nonfinite_count'] for r in records),
            within_c001=sum(r['count']*r['radius_grid_fractions']['0.001'] for r in records)/count,
            within_c0625=sum(r['count']*r['radius_grid_fractions']['0.0625'] for r in records)/count))
    out=[r'\begin{table}[t]',r'\centering\small',r'\begin{tabular}{llrrrr}',r'\toprule',
        r'Format & Rounded values & Sign flips & Score changes $>1/16$ & $c=.001$ & $c=.0625$ \\',r'\midrule']
    for row in rows:
        label='Hidden' if row['mode']=='hidden_only' else 'Hidden and output'
        out.append(f"{row['format']} & {label} & {row['sign_changes']:,} & {row['clipped_score_violations']:,} & {100*row['within_c001']:.2f}\\% & {100*row['within_c0625']:.2f}\\%"+r' \\')
    assert len({r['input_model_pairs'] for r in rows})==1
    count=rows[0]['input_model_pairs']
    out.extend([r'\bottomrule',r'\end{tabular}',
        r'\caption{Deterministic activation-rounding diagnostic on '+f"{count:,} held-out input/model pairs across {len(modelids)} tanh image models. "+
        r'The last two columns give the fraction whose realized joint noise lies inside the corresponding calibrated ball. The clipped score has cap $1/2$. Failures to fit the training likelihood are retained; no adversarial or distribution-wide claim follows from this fixed rounding map.}',
        r'\label{tab:quantization}',r'\end{table}'])
    (ROOT/'quantization-results-table.tex').write_text('\n'.join(out)+'\n')
    (ROOT/'quantization-results-table.json').write_text(json.dumps(dict(model_ids=modelids,rows=rows),indent=2)+'\n')
    print(json.dumps(dict(models=len(modelids),rows=rows),indent=2))

if __name__=='__main__':main()

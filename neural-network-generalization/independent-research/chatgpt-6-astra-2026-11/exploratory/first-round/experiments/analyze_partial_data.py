from pathlib import Path
import json
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
runs=[]
for path in sorted((ROOT/'results/parity_relu_partial').glob('d*.jsonl')):
    records=[json.loads(line) for line in path.read_text().splitlines() if line.strip()]
    final=records[-1]
    if final['sweep']<30000:continue
    kept=[r for r in records if r['sweep']>15000]
    row={key:final[key] for key in ['dimension','width','seed','initialization','training_draws','data_seed','distinct_observations']}
    row.update(sweeps=final['sweep'],window=[15000,final['sweep']],records=len(kept),file=str(path.relative_to(ROOT)))
    for key in ['uniform_error','unseen_error','uniform_hinge','parity_kernel','parity_output','energy_per_neuron','readout_energy','incoming_energy']:
        values=np.array([r[key] for r in kept]);blocks=np.array([b.mean() for b in np.array_split(values,20)])
        row[key]=float(values.mean());row[key+'_block_se']=float(blocks.std(ddof=1)/np.sqrt(20))
    im=np.array([r['incoming_energy']-r['readout_energy'] for r in kept]);bm=np.array([b.mean()for b in np.array_split(im,20)])
    row.update(imbalance=float(im.mean()),imbalance_block_se=float(bm.std(ddof=1)/np.sqrt(20)))
    gaps=np.array([r['parity_kernel']-r['parity_output']**2/r['readout_energy'] for r in records])
    assert gaps.min()>-1e-10
    row['minimum_cauchy_gap']=float(gaps.min());runs.append(row)
summary=[]
for draws in sorted({r['training_draws']for r in runs}):
    rr=[r for r in runs if r['training_draws']==draws]
    summary.append(dict(draws=draws,runs=len(rr),distinct_range=[min(r['distinct_observations'] for r in rr),max(r['distinct_observations'] for r in rr)],
                        mean_uniform_error=float(np.mean([r['uniform_error']for r in rr])),mean_unseen_error=float(np.mean([r['unseen_error']for r in rr])),mean_parity_kernel=float(np.mean([r['parity_kernel']for r in rr]))))
out=dict(status='Exploratory fixed-six-bit partial-data diagnostics; no mixing certificate, no dimension-scaling conclusion',runs=runs,summary=summary)
(ROOT/'results/partial_data_analysis.json').write_text(json.dumps(out,indent=2))
print(json.dumps(summary,indent=2))

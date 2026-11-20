import os
for key in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS']:
    os.environ[key]='1'
from pathlib import Path
import json
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
critical=json.loads((ROOT/'results/critical_relu_covariance_aggregate.json').read_text())
cube=np.array([[1 if x>>i&1 else -1 for i in range(6)] for x in range(64)])
base=np.maximum(cube.sum(axis=1),0)/np.sqrt(6)
coeff=np.array([np.mean(base*np.prod(cube[:,:j],axis=1)) for j in range(7)])
even_coeff=np.array([coeff[2*((j+1)//2)]**2 for j in range(6)])
cross_factors=np.array([even_coeff[j]+(j*even_coeff[j-1] if j else 0)+((5-j)*even_coeff[j+1] if j<5 else 0) for j in range(6)])
cross_factors*=(.5-critical['mc'])**2/(24*critical['rho']**2)
rows=[]
for path in sorted((ROOT/'results/parity_relu_orientation').glob('d*.jsonl')):
    data=[json.loads(line) for line in path.read_text().splitlines() if line.strip()]
    final=data[-1]['sweep']
    if final<20000:
        continue
    kept=[a for a in data if a['sweep']>final//2]
    start=next(a for a in data if a['sweep']>=final//2)
    last=data[-1]
    row={k:last[k] for k in ['dimension','width','seed','initialization']}
    row.update(file=str(path.relative_to(ROOT)),sweep=final,burnin=final//2,records=len(kept))
    for key in ['energy_per_neuron','readout_energy','incoming_energy','parity_kernel',
                'parity_output','bulk_parity','top_pair_count','balanced_orientation',
                'even_singleton_cross_norm_squared','orientation_degree_spectrum','top_scaled_norms']:
        values=np.asarray([a[key] for a in kept],dtype=float)
        blocks=np.array_split(values,20)
        means=np.array([b.mean(axis=0) for b in blocks])
        row[key]=values.mean(axis=0).tolist()
        row[key+'_block_se']=(means.std(axis=0,ddof=1)/np.sqrt(len(means))).tolist()
    proposed=last['orientation_proposed']-start['orientation_proposed']
    accepted=last['orientation_accepted']-start['orientation_accepted']
    row.update(proposals=proposed,accepted=accepted,acceptance=accepted/proposed if proposed else None,
               distinct_masks=len({a['orientation_mask'] for a in kept}),
               hemisphere_records=sum(a['orientation_degree_spectrum'][0]+a['orientation_degree_spectrum'][1]>.999 for a in kept))
    row['imbalance']=row['incoming_energy']-row['readout_energy']
    balanced=[a for a in kept if a['balanced_orientation']]
    expected=np.array([np.dot(a['orientation_degree_spectrum'],cross_factors) for a in balanced])
    actual=np.array([a['even_singleton_cross_norm_squared'] for a in balanced])
    correction=actual-expected
    blockmeans=np.array([b.mean() for b in np.array_split(correction,20)])
    row.update(pattern_conditioned_cross_limit=float(expected.mean()),
               cross_finite_width_correction=float(correction.mean()),
               cross_correction_block_se=float(blockmeans.std(ddof=1)/np.sqrt(20)),
               width_times_cross_correction=float(row['width']*correction.mean()))
    rows.append(row)
out={'status':'exploratory chain diagnostics; block errors do not certify mixing',
     'runs':rows,
     'limiting_degree_spectrum':[.0376790432,.1883952160,.3869628704,.3869628704,0,0],
     'limiting_cross_norm_squared':.09281097016}
out['pattern_spectrum_cross_factors']=cross_factors.tolist()
(ROOT/'results/orientation_sampler_analysis.json').write_text(json.dumps(out,indent=2))
for row in rows:
    print(json.dumps({k:v for k,v in row.items() if 'top_scaled_norms' not in k}))

#!/usr/bin/env python3
"""Check that the final empirical claims have complete, mutually consistent artifacts.

This is a reproducibility audit, not a replacement for mathematical proofs.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
from pathlib import Path
import datetime,hashlib,json
import numpy as np
import train

ROOT=Path(__file__).resolve().parent

def main():
    configs=[]
    for path in sorted(ROOT.glob('predeclared-*.json')):
        configs.extend(json.loads(path.read_text()).get('configs',[]))
    assert len({c['id'] for c in configs})==len(configs)
    assert len({c['index'] for c in configs})==len(configs)
    manifest=json.loads((ROOT/'data'/'source-manifest.json').read_text())
    for item in manifest:
        path=ROOT/'data'/item['file']
        assert hashlib.sha256(path.read_bytes()).hexdigest()==item['sha256']
    rows=[]
    for c in sorted(configs,key=lambda c:c['index']):
        ident=c['id'];path=ROOT/'records'/f'{ident}.json'
        rec=json.loads(path.read_text());assert rec['config']==c
        saved=np.load(ROOT/'models'/f'{ident}.npz');p=[]
        for j in range(c['hidden_depth']+1):
            w=saved[f'w{j}'];assert w.dtype==np.float32 and np.isfinite(w).all()
            expected=((c['dimension']+1,c['width']) if j==0 else
                      ((c['width'],) if j==c['hidden_depth'] else (c['width'],c['width'])))
            assert w.shape==expected;p.append(w.astype(np.float64))
        ev=c['width']*np.dot(p[-1],p[-1]);assert abs(ev-rec['readout_energy'])<=1e-10*max(1,ev)
        x,y,tri,xt,yt,tei=train.dataset(c,dtype=np.float64)
        assert np.array_equal(tri,saved['train_original_indices'])
        assert np.array_equal(tei,saved['test_original_indices'])
        discrepancies=[]
        for split,xx,yy in [('train',x,y),('test',xt,yt)]:
            output=np.asarray(rec[f'per_{split}_output']);metric=rec[split]
            assert len(output)==len(yy)==metric['count']
            signed=yy*output
            assert int(np.sum(signed<=0))==metric['errors']
            assert bool(np.all(signed>.5))==metric['all_margins_above_half']
            assert float(np.min(signed))==metric['minimum_signed_margin']
            indices=np.unique(np.linspace(0,len(xx)-1,8,dtype=int))
            fresh=train.predict(p,xx[indices],activation=c.get('activation','tanh'))
            gap=float(np.max(np.abs(fresh-output[indices])))
            assert gap<=1e-8*max(1,float(np.max(np.abs(output[indices]))))
            discrepancies.append(gap)
        attack=json.loads((ROOT/'attacks'/f'{ident}.json').read_text());assert attack['config']==c
        quant=json.loads((ROOT/'quantization'/f'{ident}.json').read_text());assert quant['config']==c
        assert len(quant['rows'])==4 and all(r['count']==rec['test']['count'] for r in quant['rows'])
        kind='ReLU comparison; no tanh certificate claimed'
        if c['input_mode']=='enumerated_boolean':
            cert=json.loads((ROOT/'full-cube'/f'{ident}.json').read_text())
            assert cert['config']==c and [r['input_index'] for r in cert['rows']]==list(range(512))
            kind='Exhaustive512-input certificate record'
        elif c.get('activation','tanh')=='tanh':
            directory=ROOT.parent/'certificates'
            candidate=directory/'refined-model-certificates'/f'{ident}.json'
            if not candidate.exists():candidate=directory/'model-certificates'/f'{ident}.json'
            cert=json.loads(candidate.read_text());assert cert['config']==c
            for group in ['heldout_uniform','heldout_boundary','random_cube']:
                assert cert['groups'][group]['rows']
                for row in cert['groups'][group]['rows']:
                    assert set(row['by_c'])=={'0.001','0.003','0.01','0.03','0.0625'}
            kind='Complete image certificate record'
        rows.append(dict(model=ident,training_eligible=rec['train']['all_margins_above_half'],
                         sampled_forward_max_discrepancy=max(discrepancies),certificate_scope=kind))
        del p,x,y,xt,yt,saved,attack,quant
    result=dict(checked_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                declared_models=len(configs),complete_models=len(rows),training_eligible=sum(r['training_eligible'] for r in rows),
                source_dataset_hashes_checked=len(manifest),all_checks_passed=True,rows=rows,
                qualification='Artifact consistency and sampled forward replay only. Numerical positive certificates and exact mathematical verifications retain their separate stated qualifications.')
    (ROOT/'final-artifact-audit.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k!='rows'},indent=2))

if __name__=='__main__':main()

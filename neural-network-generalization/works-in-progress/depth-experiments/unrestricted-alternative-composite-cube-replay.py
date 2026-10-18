#!/usr/bin/env python3
"""Readonly independent replay of an archived finite-partition cube certificate."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import argparse, hashlib, json, sys, time
from pathlib import Path
from fractions import Fraction
import numpy as np
import mpmath as mp
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'certificates'))
import exact_boolean_cube as base
from exact_svd_bound import dyadic_integer_matrix, bound_from_factors
from fast_exact_svd_bound import operator_square_upper as fast_upper

def rat(v): return Fraction(int(v['numerator']),int(v['denominator']))
def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def saved_bound(w, folder, stem, pure=False):
    meta=json.loads((folder/f'{stem}.json').read_text())
    factor=folder/f'{stem}-factors.npz'
    if 'factor_sha256' in meta: assert sha(factor)==meta['factor_sha256']
    eps=rat(meta['epsilon'])
    factors=np.load(factor)
    if pure:
        g=bound_from_factors(w,factors['u'],factors['s'],factors['vh'],epsilon=eps)['operator_squared_upper']
    else:
        g,_=fast_upper(w,existing_factor_path=factor,epsilon=eps)
    assert g==rat(meta['operator_squared_upper'])
    return g,meta

def main():
    ap=argparse.ArgumentParser();ap.add_argument('certificate');ap.add_argument('--output',required=True)
    ap.add_argument('--pure-groups',type=int,default=3);ap.add_argument('--supplement',required=True);ap.add_argument('--supplement-replay',required=True);args=ap.parse_args()
    start=time.monotonic();cert=Path(args.certificate).resolve();folder=cert.parent
    record=json.loads(cert.read_text());supp_path=Path(args.supplement).resolve();supp=json.loads(supp_path.read_text());supp_replay_path=Path(args.supplement_replay).resolve();supp_replay=json.loads(supp_replay_path.read_text());supp_hash=sha(supp_path)
    assert supp_replay['status']=='PASS' and supp_replay['certificate_sha256']==supp_hash and supp_replay['vertex']==supp['vertex']
    model=ROOT/'experiment/models'/f"{record['model']}.npz"
    config=json.loads((ROOT/'experiment/records'/f"{record['model']}.json").read_text())['config']
    sources=[Path(__file__),ROOT/'certificates/exact_boolean_cube.py',ROOT/'certificates/exact_svd_bound.py',ROOT/'certificates/fast_exact_svd_bound.py',ROOT/'certificates/verify_witness.py',ROOT/'certificates/verify_reachable_tube.py']
    hashes={str(p.relative_to(ROOT)):sha(p) for p in sources};certificate_hash=sha(cert)
    assert sha(model)==record['model_sha256'];assert record['dimension']==9
    data=np.load(model);p=[data[k] for k in sorted((k for k in data.files if k.startswith('w') and k[1:].isdigit()),key=lambda k:int(k[1:]))]
    n=len(p[-1]);h=len(p)-1;assert n==record['width'] and h==record['hidden_depth']
    base.BITS=record['dyadic_bits'];base.SCALE=2**base.BITS;mp.iv.dps=record['interval_decimal_digits']
    c=rat(record['c_exact']);ev=n*sum((Fraction.from_float(float(v))**2 for v in p[-1]),Fraction(0));r2=c*c/(1+h*ev)
    assert ev==rat(record['readout_energy_exact']) and r2==rat(record['noise_radius_squared_exact'])
    bounds=[];q=Fraction(1);cols=[]
    for s,w in enumerate(p[1:-1],1):
        g,_=saved_bound(w,folder,f'global-w{s}',pure=True);bounds.append(g);q=1+g*q
        wi,dw=dyadic_integer_matrix(w);cols.append([Fraction(sum(int(v)**2 for v in wi[:,j]),dw*dw) for j in range(n)])
    global_raw=base.ceil_dyadic(mp.iv.sqrt(base.iv(r2*(1+ev*q))),base.BITS)
    assert global_raw==rat(record['global_raw_change_upper'])
    x=(2*((np.arange(512)[:,None]>>np.arange(9))&1)-1).astype(float)
    lo,hi,history=base.forward_batch(p,x,save_hidden=True)
    assert len(record['rows'])==512
    for i,row in enumerate(record['rows']):
        assert row['input_index']==i and lo[i]==rat(row['output_lower']) and hi[i]==rat(row['output_upper'])
    groups=record['groups'];assert len({g['group_id'] for g in groups})==len(groups)
    pure_ids={g['group_id'] for g in sorted(groups,key=lambda g:rat(g['raw_change_upper']),reverse=True)[:args.pure_groups]}
    proved={};checks=0
    for group in groups:
        gid=group['group_id'];ids=group['input_indices'];assert ids and all(isinstance(i,int) and 0<=i<512 for i in ids)
        q=Fraction(1);sub=folder/f'group-{gid:03d}'
        assert len(group['layers'])==h-1
        for s,w in enumerate(p[1:-1],1):
            al,ah,den=history[s];state=mp.iv.sqrt(base.iv(n*r2*q));caps=[]
            for j in range(n):
                distance=min(Fraction(0) if int(al[i,j])<=0<=int(ah[i,j]) else min(abs(Fraction(int(al[i,j]),den)),abs(Fraction(int(ah[i,j]),den))) for i in ids)
                near=max(Fraction(0),base.endpoint_fraction(base.iv(distance)-state*mp.iv.sqrt(base.iv(cols[s-1][j])),False))
                e=mp.iv.exp(-2*base.iv(near));caps.append(min(Fraction(1),base.ceil_dyadic(4*e/(1+e)**2)))
            if all(v==1 for v in caps):g=bounds[s-1]
            else:
                exact=np.array([[Fraction.from_float(float(v))*cap for v,cap in zip(row,caps)] for row in w],dtype=object)
                approx=np.array(exact,dtype=float)
                norm,meta=saved_bound(approx,sub,f'layer{s}',pure=gid in pure_ids)
                assert [str(v.numerator) for v in caps]==meta['derivative_upper_numerators']
                assert [str(v.denominator) for v in caps]==meta['derivative_upper_denominators']
                error2=sum(((a-Fraction.from_float(float(b)))**2 for a,b in zip(exact.flat,approx.flat)),Fraction(0))
                assert error2==rat(meta['product_rounding_frobenius_squared'])
                eps=rat(meta['product_rounding_young_epsilon']);assert eps>0
                jac=(1+eps)*norm+(1+1/eps)*error2
                assert jac==rat(meta['actual_jacobian_squared_upper']);g=min(bounds[s-1],jac);checks+=1
            q=1+g*q;layer=group['layers'][s-1]
            assert layer['layer']==s and g==rat(layer['operator_squared_upper']) and q==rat(layer['prefix_gain_squared'])
        raw=base.ceil_dyadic(mp.iv.sqrt(base.iv(r2*(1+ev*q))),base.BITS)
        assert raw==rat(group['raw_change_upper'])
        changes={i:base.clipped_change(lo[i],hi[i],raw) for i in ids}
        assert all(v<=Fraction(1,16) for v in changes.values())==group['all_group_vertices_certified']
        proved[gid]=(ids,raw,changes)
        print('replayed-group',gid,'vertices',len(ids),'raw',float(raw),'pure-object',gid in pure_ids,flush=True)
    unresolved=[]
    for i,row in enumerate(record['rows']):
        if not row['certified']:
            unresolved.append(i);continue
        ids,raw,changes=proved[row['group_id']]
        assert i in ids and raw==rat(row['raw_change_upper']) and changes[i]==rat(row['clipped_change_upper']) and changes[i]<=Fraction(1,16)
    assert record['certified']==512-len(unresolved) and record['all_boolean_inputs_certified']==(not unresolved) and not record['remaining_groups']
    assert unresolved==[325] and supp['vertex']==325 and supp['model']==record['model'] and supp['model_sha256']==sha(model)
    assert supp_replay['model_sha256']==sha(model) and supp['certified'] and rat(supp['clipped_change_upper'])==0
    assert rat(supp['readout_energy_exact'])==ev and rat(supp['noise_radius_squared_exact'])==r2 and rat(supp['c_exact'])==c
    assert rat(supp['clean_output_lower'])==lo[325] and rat(supp['clean_output_upper'])==hi[325]
    assert rat(supp['perturbed_output_lower'])==lo[325]-rat(supp['state_based_output_change_upper'])
    assert rat(supp['perturbed_output_upper'])==hi[325]+rat(supp['state_based_output_change_upper'])
    assert base.clipped_change(lo[325],hi[325],rat(supp['state_based_output_change_upper']))==0
    assert config['input_mode']=='enumerated_boolean' and config['task']=='recursive_majority9'
    labels=np.sign(np.sign(x.reshape(-1,3,3).sum(axis=2)).sum(axis=1)).astype(int);split=np.random.default_rng(config['split_seed']).permutation(512)
    training=record['training_checks'];assert len(training)==config['training_cube_count']==400
    for expected,row in zip(split[:400],training):
        i=row['input_index'];assert i==int(expected) and row['label']==int(labels[i])
        lower=lo[i] if labels[i]>0 else -hi[i]
        assert lower==rat(row['signed_output_lower']) and lower>Fraction(1,2) and row['margin_above_half']
    assert record['all_training_margins_interval_verified']
    target_rows=record['target_checks'];assert len(target_rows)==512
    for expected,row in zip(split,target_rows):
        i=row['input_index'];assert i==int(expected) and row['label']==int(labels[i])
        lower=lo[i] if labels[i]>0 else -hi[i]
        assert lower==rat(row['signed_output_lower']) and row['margin_above_half']==(lower>Fraction(1,2))
    correct=sum((lo[i] if labels[i]>0 else -hi[i])>0 for i in range(512));assert correct==record['interval_verified_correct_vertices']
    assert sha(supp_path)==supp_hash and sha(cert)==certificate_hash and all(sha(ROOT/path)==digest for path,digest in hashes.items())
    out=dict(status='PASS',supplement_certificate=str(supp_path),supplement_certificate_sha256=supp_hash,supplement_replay=str(supp_replay_path),partition_vertices=512-len(unresolved),supplemental_vertices=unresolved,certificate=str(cert),certificate_sha256=certificate_hash,model_sha256=sha(model),source_sha256=hashes,vertices=512,training_margin_checks=400,interval_verified_correct_vertices=correct,groups_replayed=len(groups),tube_matrix_bounds_replayed=checks,pure_object_groups=sorted(pure_ids),elapsed_seconds=time.monotonic()-start,qualification='Fresh all512 clean interval forward; every archived shared-tube group and every final row replayed. Sole unresolved partition vertex325 is supplied by the separately replayed exact covariance-state certificate; its model, radius and clean intervals match exactly. Exact integers/rationals and outward mpmath intervals; no SVD accuracy trusted; not Lean.')
    Path(args.output).write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out),flush=True)
if __name__=='__main__':main()

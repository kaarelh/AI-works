#!/usr/bin/env python3
"""Portable replay of included population witnesses; no training or network.

python replay.py            # all included frozen witnesses, float64
python replay.py --interval # plus the three exhaustive interval certificates
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
os.environ['OMP_NUM_THREADS']='1'
import argparse,gzip,hashlib,itertools,json,sys,time
from fractions import Fraction
from pathlib import Path
import numpy as np
from compression import cube,forward,compressed_weights

ROOT=Path(__file__).resolve().parent

def load_record(item):
    return json.loads(gzip.decompress((ROOT/item['record']).read_bytes()))

def load_weights(item,record):
    path=ROOT/item['checkpoint']
    assert hashlib.sha256(path.read_bytes()).hexdigest()==item['checkpoint_sha256']==record['checkpoint_sha256']
    with np.load(path) as archive:return [archive[f'w{i}'].astype(float) for i in range(record['H']+1)]

def validate_parts(witness,n):
    q=witness['q'];parts=[]
    for group,sign in zip(witness['groups'],witness['signs']):
        g=np.asarray(group,dtype=int);s=np.asarray(sign,dtype=int)
        assert len(g)==len(s)==n and set(s)<=set([-1,1]) and set(g)==set(range(q))
        if not witness['signed']:assert np.all(s==1)
        counts=np.bincount(g,minlength=q)
        if witness['balanced']:assert np.all((counts==n//q)|(counts==(n+q-1)//q))
        parts.append((g,s))
    return parts

def interval_check(item,record,witness):
    sys.path.insert(0,str(ROOT/'inventory-audit'))
    from verify_population_witnesses import exact_reduced,interval_weights,evaluate_interval,rational_matrix
    from mpmath import iv,mp
    mp.dps=60;iv.dps=50
    w=load_weights(item,record);n=record['N'];validate_parts(witness,n)
    ev=n*sum((Fraction(float(v))**2 for v in w[-1]),Fraction())
    assert witness['q']<=1+ev
    signs=[[int(s) for s in layer] for layer in witness['signs']]
    reduced,_=exact_reduced(w,witness['groups'],signs,witness['q'])
    original=[rational_matrix(a) for a in w[:-1]]+[[Fraction(float(v)) for v in w[-1]]]
    wi,ri=interval_weights(original),interval_weights(reduced);lower=mp.inf
    for x in itertools.product([-1,1],repeat=record['d']):
        z,zr=evaluate_interval(wi,x),evaluate_interval(ri,x)
        if bool(z>iv.mpf('.5')) and bool(zr>iv.mpf('.5')):
            lower=min(lower,mp.mpf(z._mpi_[0]),mp.mpf(zr._mpi_[0]))
        elif bool(z<iv.mpf('-.5')) and bool(zr<iv.mpf('-.5')):
            lower=min(lower,-mp.mpf(z._mpi_[1]),-mp.mpf(zr._mpi_[1]))
        else:raise AssertionError('Joint saturation not certified for '+record['id'])
    return {'id':record['id'],'q':witness['q'],'all_inputs':2**record['d'],'certified_max_clipped_difference':0,'minimum_certified_absolute_output':str(lower),'signed':witness['signed'],'balanced':witness['balanced'],'scope':'Outward-rounded interval computation, not Lean verification.'}

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--interval',action='store_true');parser.add_argument('--output');args=parser.parse_args();start=time.monotonic()
    manifest=json.loads((ROOT/'dataset-manifest.json').read_text());included=[i for i in manifest if i['included']]
    checked=0;q1checked=0;records={};items={}
    for item in included:
        r=load_record(item);w=load_weights(item,r);records[r['id']]=r;items[r['id']]=item
        x=cube(r['d'],'little_endian' if item['cohort']=='public' else 'lexicographic');z=forward(w,x)
        for key,witness in r['eligible_witnesses'].items():
            parts=validate_parts(witness,r['N']);zc=forward(compressed_weights(w,parts),x);scale=witness['scale']
            change=float(np.max(np.abs(np.clip(z*scale,-.5,.5)-np.clip(zc*scale,-.5,.5))))
            assert change<=1/16+1e-12,(r['id'],key,change)
            assert abs(change-witness['max_clipped_difference'])<1e-10
            checked+=1
        qpath=ROOT/'q1-output-results'/(r['id']+'.json')
        if qpath.exists():
            result=json.loads(qpath.read_text());witness=result['best']
            if witness['passes_float64']:
                parts=validate_parts(witness,r['N']);zc=forward(compressed_weights(w,parts),x)
                change=float(np.max(np.abs(np.clip(z,-.5,.5)-np.clip(zc,-.5,.5))))
                assert change<=1/16+1e-12;q1checked+=1
    intervals=[]
    if args.interval:
        cases=[('round2-000-heldout8-majority5-H4-adam-s0-g1.1','raw-unsigned-balanced'),('fresh-002-majority5-H4-N32-sgd-s0','raw-signed-unbalanced'),('fresh-000-majority5-H4-N32-adam-s0','q1')]
        for ident,key in cases:
            witness=json.loads((ROOT/'q1-output-results'/(ident+'.json')).read_text())['best'] if key=='q1' else records[ident]['cap_witnesses'][key]
            intervals.append(interval_check(items[ident],records[ident],witness))
    result={'included_checkpoints':len(included),'all_frozen_model_records':len(manifest),'omitted_old_checkpoints':sum(not i['included'] for i in manifest),'float64_eligible_witnesses_replayed':checked,'float64_q1_witnesses_replayed':q1checked,'interval_certificates_replayed':intervals,'seconds':time.monotonic()-start,'scope':'The replay checks included model weights and witnesses. Historical records for omitted checkpoints are retained with hashes, not independently replayed here.'}
    if args.output:Path(args.output).write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))

if __name__=='__main__':main()

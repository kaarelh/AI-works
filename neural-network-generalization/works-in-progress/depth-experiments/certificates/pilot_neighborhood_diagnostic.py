#!/usr/bin/env python3
"""Postprotocol feasibility screen for first-layer ellipsoidal cylinders.

Use all128 fixed pilot centers and an optimistic c'=.0625, whether or not
those centers are certified at that radius. This overestimates what existing
pointwise certificates could cover with this particular transfer lemma.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import sys,json
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parent;EXP=ROOT.parent/'experiment';sys.path.insert(0,str(EXP));import train,attacks
path=next((EXP/'records').glob('008-*.json'));record=json.loads(path.read_text());p=attacks.load_model(record['config']);_,_,_,x,y,_=train.dataset(record['config'],dtype=np.float64)
centers,_,indices,_=attacks.audit_inputs(record['config'],record)['heldout_uniform'];features=x@p[0][:-1];fc=centers@p[0][:-1];N=len(p[-1]);H=len(p)-1;ev=N*np.sum(p[-1]**2)
squared=np.maximum(0,(features*features).sum(axis=1)[:,None]+(fc*fc).sum(axis=1)[None,:]-2*features@fc.T)/N
nearest=np.sqrt(squared.min(axis=1));mask=np.ones(len(x),bool);mask[indices]=False;gap=(.0625-.001)/np.sqrt(1+H*ev)
hh=np.c_[centers,np.ones(len(centers))]
for ww in p[:-1]:hh=np.tanh(hh@ww)
center_z=hh@p[-1];target_r=.001/np.sqrt(1+H*ev)
absolute_gap=np.maximum(0,(np.abs(center_z)-.5)/np.sqrt(1+ev)-target_r)
absolute_coverage=np.any(squared<=absolute_gap[None,:]**2,axis=1)
selected=3;single=np.linalg.norm(features-fc[selected],axis=1)/np.sqrt(N);singlemask=np.arange(len(x))!=indices[selected]
out=dict(model=path.stem,protocol='Postprotocol feasibility diagnostic, all fixed128 uniform heldout pilot centers, no selection by margin or coverage.',target_c=.001,optimistic_center_c=.0625,normalized_first_layer_radius=float(gap),pilot_count=len(centers),nonpilot_count=int(mask.sum()),covered_nonpilot_count=int(np.sum(nearest[mask]<=gap)),nearest_distance_quantiles=np.quantile(nearest[mask],[0,.01,.1,.5,.9,1]).tolist(),minimum_distance_to_radius_ratio=float(np.min(nearest[mask])/gap),exact_previously_certified_center_uniform_index=3,exact_center_minimum_other_test_distance=float(np.min(single[singlemask])),absolute_center_ball_radius_upper_quantiles=np.quantile(absolute_gap,[0,.1,.5,.9,1]).tolist(),ideal_center_ball_optimistic_covered_nonpilot_count=int(np.sum(absolute_coverage[mask])),ideal_center_ball_upper_bound_reason='Last hidden-layer plus scalar-output noise can change the output by exactly rprime*sqrt(1+Ev), so a same-sign output-margin certificate requires rprime<=(abs(clean_output)-.5)/sqrt(1+Ev).',qualification='Float64 feature-distance diagnostic, not an outward interval proof. Radius is deliberately optimistic for all128 centers. This addresses only the elementary triangle-inequality first-layer-cylinder construction, not arbitrary trusted regions.')
(ROOT/'pilot-neighborhood-diagnostic.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out))

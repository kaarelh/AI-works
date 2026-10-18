#!/usr/bin/env python3
"""Derive exact finite-domain classification counts from saved output enclosures."""
import sys,json
from pathlib import Path
from fractions import Fraction
import numpy as np
ROOT=Path(__file__).resolve().parent;EXP=ROOT.parent/'experiment';sys.path.insert(0,str(EXP));import train

def rat(a):return Fraction(int(a['numerator']),int(a['denominator']))
rows=[]
for index,pattern in [(500,'full-cube-verified-500-*/certificate.json'),(501,'full-cube-verified-501-*/certificate.json'),(504,'full-cube-partition-verified-504-*/certificate.json'),(505,'full-cube-partition-verified-505-*/certificate.json')]:
 files=list(ROOT.glob(pattern))
 if not files:continue
 cert=json.loads(files[0].read_text());rec=json.loads(next((EXP/'records').glob(f'{index:03d}-*.json')).read_text());xt,yt,_,xte,yte,_=train.dataset(rec['config'],dtype=np.float64)
 correct=incorrect=ambiguous=0;minimum_signed=None;minimum_absolute=None;minimum_train=None;bad=[]
 for j,(x,y)in enumerate(zip(np.concatenate([xt,xte]),np.concatenate([yt,yte]))):
  if not np.all((x==-1)|(x==1)):raise ValueError('Boolean inputs required.')
  i=sum(int(v>0)*2**k for k,v in enumerate(x));r=cert['rows'][i];lo=rat(r['output_lower']);hi=rat(r['output_upper']);sl,sh=(lo,hi)if y>0 else(-hi,-lo)
  if sl>0:correct+=1
  elif sh<0:incorrect+=1;bad.append(i)
  else:ambiguous+=1
  ab=Fraction(0)if lo<=0<=hi else min(abs(lo),abs(hi));minimum_absolute=ab if minimum_absolute is None else min(minimum_absolute,ab);minimum_signed=sl if minimum_signed is None else min(minimum_signed,sl)
  if j<len(xt):minimum_train=sl if minimum_train is None else min(minimum_train,sl)
 rows.append(dict(model=index,certificate=str(files[0].relative_to(ROOT)),interval_verified_correct=correct,interval_verified_incorrect=incorrect,ambiguous=ambiguous,incorrect_vertex_indices=bad,minimum_absolute_output_lower_approx=float(minimum_absolute),minimum_signed_output_lower_approx=float(minimum_signed),minimum_training_signed_output_lower_approx=float(minimum_train),all_training_margins_verified=minimum_train>Fraction(1,2)))
(ROOT/'exact-full-cube-label-audit.json').write_text(json.dumps(dict(rows=rows,method='Exact Fraction comparisons of saved interval endpoints against deterministic finite-cube target labels.'),indent=2)+'\n');print(json.dumps(rows))

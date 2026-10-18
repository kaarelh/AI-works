#!/usr/bin/env python3
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import time
from fractions import Fraction
from verify_global_exact import one,ROOT,EXP
pending={200,201,202,203};deadline=time.monotonic()+4200
while pending and time.monotonic()<deadline:
 for index in sorted(pending.copy()):
  if list((EXP/'models').glob(f'{index:03d}-*.npz')):
   result=one(index,Fraction(1,16))
   assert result['all_internal_operator_norms_at_most_one']
   assert result['exact_final_inequality_pass']
   pending.remove(index)
 if pending:time.sleep(10)
print('pending_at_exit',sorted(pending),flush=True)

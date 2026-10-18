#!/usr/bin/env python3
import time
from fractions import Fraction
from verify_global_exact import one,ROOT,EXP
end=time.time()+1800
while time.time()<end:
 if list((EXP/'models').glob('600-*.npz')) and list((EXP/'records').glob('600-*.json')):
  one(600,Fraction(1,16));break
 time.sleep(5)
else:print('No completed model600 by verifier deadline',flush=True)

#!/usr/bin/env python3
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import subprocess,sys,time
from pathlib import Path
r=Path(__file__).resolve().parent;pending={300,301};deadline=time.monotonic()+4200
while pending and time.monotonic()<deadline:
 for index in sorted(pending.copy()):
  if list((r.parent/'experiment/records').glob(f'{index:03d}-*.json')):
   for script,args in [('lowink_zero_attack.py',[]),('pixel_grid_attack.py',['--radii','.001'])]:
    completed=subprocess.run([sys.executable,str(r/script),'--index',str(index),*args],check=False)
    print('finished',index,script,completed.returncode,flush=True)
   pending.remove(index)
 if pending:time.sleep(10)
print('pending_at_exit',sorted(pending),flush=True)

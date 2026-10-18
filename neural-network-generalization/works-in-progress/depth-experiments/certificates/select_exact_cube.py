#!/usr/bin/env python3
"""Execute frozen selection rule when exhaustive numerical cohort records arrive."""
import json,time,subprocess,sys
from pathlib import Path
from fractions import Fraction
ROOT=Path(__file__).resolve().parent;EXP=ROOT.parent/'experiment';deadline=time.time()+3300

def read_record(i):
 p=list((EXP/'full-cube').glob(f'{i:03d}-*.json'))
 return json.loads(p[0].read_text()) if p else None

def eligible(q):return bool(q['train']['all_margins_above_half'])

def pick(records,phase):
 for i,q in records:
  if q is None:return None
  if not eligible(q):continue
  cs=[Fraction(1,1000),Fraction(3,1000),Fraction(1,100),Fraction(3,100),Fraction(1,16)] if phase!='inverse_depth' else [Fraction(1,1000*q['config']['hidden_depth'])]
  for c in cs:
   row=next((s for s in q['summaries']if abs(s['c']-float(c))<1e-14),None)
   if row and row['all_boolean_inputs_certified'] and (phase=='fallback' or not row['global_sufficient']):return i,c,row
 return False

while time.time()<deadline:
 records=[(i,read_record(i))for i in range(500,506)]
 selected=pick(records,'primary');phase='primary'
 if selected is False:
  selected=pick(records,'inverse_depth');phase='inverse_depth'
  if selected is False:selected=pick(records,'fallback');phase='fallback'
 if selected:
  i,c,row=selected;out=dict(selected_model=i,c_numerator=c.numerator,c_denominator=c.denominator,phase=phase,numerical_selection_row=row,selection_time_utc=time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()))
  (ROOT/'exact-full-cube-selection.json').write_text(json.dumps(out,indent=2)+'\n');print('SELECTED',out,flush=True)
  cmd=[sys.executable,str(ROOT/'exact_boolean_cube.py'),'--index',str(i),'--c',str(c),'--time-limit','1800']
  result=subprocess.run(cmd);print('FINISHED',result.returncode,flush=True);break
 if selected is False:
  (ROOT/'exact-full-cube-selection.json').write_text(json.dumps(dict(no_eligible_candidate=True),indent=2)+'\n');print('NO_ELIGIBLE_CANDIDATE',flush=True);break
 time.sleep(5)
else:print('TIME_LIMIT_BEFORE_SELECTION',flush=True)

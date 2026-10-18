#!/usr/bin/env python3
"""Cross-check saved attacks against independently computed enclosures."""
import json,datetime
from pathlib import Path
r=Path(__file__).resolve().parent;files=[];count=0;conflicts=[];worst=-float('inf');worst_record=None;allmodels=[]
for path in sorted((r.parent/'experiment/attacks').glob('*.json')):
 base=r/'refined-model-certificates'/path.name
 if not base.exists():base=r/'model-certificates'/path.name
 if not base.exists():continue
 a=json.loads(path.read_text());b=json.loads(base.read_text());allmodels.append(path.stem)
 for rec in a['records']:
  group=rec['group'];c=str(rec['radius_constant']);cap=str(float(rec['score_cap']))
  if group not in b['groups']:continue
  rows={row['source_index']:row for row in b['groups'][group]['rows']}
  for index,change in zip(rec['input_indices'],rec['per_input_change']):
   if index not in rows:continue
   rr=rows[index]['by_c'][c];bound=rr['clipped_change_bounds'][cap];excess=change-bound;count+=1
   record=dict(model=path.stem,group=group,c=c,cap=cap,index=index,attack_change=change,certificate_bound=bound,excess=excess)
   if excess>worst:worst=excess;worst_record=record
   if excess>1e-8:conflicts.append(record)
out=dict(checked_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),model_count=len(allmodels),paired_input_radius_cap_count=count,largest_attack_minus_bound=worst,worst_record=worst_record,conflicts_over_1e_minus8=conflicts,qualification='Consistency audit of numerical outputs; no substitute for soundness proof or outward-rounding certificate.')
(r/'attack-certificate-consistency.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out),flush=True)

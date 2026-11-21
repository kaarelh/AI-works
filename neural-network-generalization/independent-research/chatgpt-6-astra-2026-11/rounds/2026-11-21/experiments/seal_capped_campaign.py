"""Finalize stopped campaign summaries from every complete stored proposal row.

Only records explicitly marked time_cap_reached by the campaign controller
are touched. The last periodic checkpoint is preserved separately. This does
not resume sampling or convert a capped run into a completed proposal budget.
"""
import argparse,json,shutil
from pathlib import Path
import full_label_independent as f

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--campaign',type=Path,required=True);args=ap.parse_args()
    records=json.loads(args.campaign.read_text())
    for record in records:
        if record['status']!='time_cap_reached':continue
        path=args.campaign.parent/(record['name']+'.json')
        if not path.exists():continue
        old=json.loads(path.read_text())
        if old.get('status')=='deadline_partial':continue
        checkpoint=path.parent/'periodic-checkpoints'/path.name;checkpoint.parent.mkdir(exist_ok=True)
        shutil.copy2(path,checkpoint)
        raw=path.with_suffix('.jsonl');rows=[];incomplete=0
        lines=raw.read_text().splitlines()
        for i,line in enumerate(lines):
            if not line.strip():continue
            try:rows.append(json.loads(line))
            except json.JSONDecodeError:
                assert i==len(lines)-1,'Malformed interior proposal row'
                incomplete+=1
        scope=old['scope'];old.update(f.summarize(rows,old['width'],old['margin'],old['loss'],old['seed'],record['seconds']))
        old.update(status='deadline_partial',scope=scope,planned_proposals=record['proposals'],
            omitted_incomplete_final_rows=incomplete,last_periodic_checkpoint=str(checkpoint.relative_to(path.parent)),
            finalization='All complete proposal rows at the controller time cap; the proposal budget was not completed.')
        path.write_text(json.dumps(old,indent=2)+'\n')
        print(json.dumps({k:old[k] for k in ['status','proposals','planned_proposals','accepted','effective_importance_samples','restricted_weight_discrepancy','omitted_incomplete_final_rows']}),flush=True)
if __name__=='__main__':main()

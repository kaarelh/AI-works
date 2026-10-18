#!/usr/bin/env python3
"""Reuse newly completed, stronger sampled enclosures on matching held-out inputs."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parent

def main():
    for path in sorted((ROOT/'full-heldout').glob('*.json')):
        source=ROOT.parent/'certificates'/'refined-model-certificates'/path.name
        if not source.exists():continue
        out=json.loads(path.read_text());cert=json.loads(source.read_text());changes=0
        selected={p['source_index']:p for group in ['heldout_uniform','heldout_boundary'] for p in cert['groups'].get(group,{}).get('rows',[])}
        oldsummary=[]
        for row in out['rows']:
            oldsummary.append(dict(c=row['c'],certified=row['certified'],unresolved_indices=row['unresolved_indices']))
            for point in row['points']:
                if point['certified'] or point['index'] not in selected:continue
                interval=selected[point['index']]['by_c'][str(row['c'])]
                bound=interval['clipped_change_bounds']['0.5']
                if bound<point['score_change_bound']:
                    point.update(lower=interval['lower'],upper=interval['upper'],score_change_bound=bound,
                                 certified=interval['certified']['0.5'],method='reused stronger refined pointwise bound')
                    changes+=1
            row['certified']=sum(p['certified'] for p in row['points'])
            row['unresolved_indices']=[p['index'] for p in row['points'] if not p['certified']]
            row['methods']={k:sum(p['method']==k for p in row['points']) for k in sorted({p['method'] for p in row['points']})}
        if changes:
            out.setdefault('refinement_history',[]).append(dict(source=str(source.relative_to(ROOT.parent)),previous_summary=oldsummary,changed_points=changes))
            path.write_text(json.dumps(out,indent=2)+'\n')
            print(json.dumps(dict(model=out['config']['id'],changes=changes,summary=[dict(c=r['c'],certified=r['certified'],count=r['count']) for r in out['rows']])))

if __name__=='__main__':main()

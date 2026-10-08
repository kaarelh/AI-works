"""Reviewer-requested sensitivity checks, without retuning the frozen prior."""
from pathlib import Path
import math,json
import pandas as pd
from forecast import draw_rows,summarize,S
from taper_model import LogHeadroomTaper
BASE=Path(__file__).resolve().parent
rows=pd.read_csv(BASE/'draws.csv').to_dict('records')
central=[r for r in rows if r['Hmax']==60]
out={}
for hi in [16,60]:
    new=draw_rows(hi,minh=1)
    out[f'headroom_1_to_{hi}']=summarize(new,S['weights']['central'])
cap=[r for r in central if r['subfamily']=='capped_raw_power']
out['capped_raw_power_fraction_cap_not_reached']=sum(r['log10_a']<r['log10_H']-1e-9 for r in cap)/len(cap)
out['taper_fixed_nu']={}
ct={r['draw']:r for r in central if r['family']=='taper'}
for hi in [16,120]:
    new=[]
    for row in rows:
        if row['Hmax']!=hi:continue
        r=dict(row)
        if r['family']=='taper':
            r['r0']=ct[r['draw']]['r0']*r['log10_H']/ct[r['draw']]['log10_H']
            ans=LogHeadroomTaper(r['log10_H'],r['r0'],r['p'],log10_k0=r['log10_k0']).solve()
            assert abs(ans['nu']-ct[r['draw']]['nu'])<1e-10
            r['log10_x']=ans['log10_stop']
        new.append(r)
    out['taper_fixed_nu'][str(hi)]=summarize(new,S['weights']['central'])
(BASE/'extra_sensitivities.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(out,indent=2))

#!/usr/bin/env python3
"""Extract source CSVs as in Erdil et al. notebook cells 2–4; match by linear interpolation."""
import csv,re,math,bisect
from datetime import date
from pathlib import Path
BASE=Path(__file__).resolve().parent
runs=sorted((date.fromisoformat(r['Date']).toordinal(),float(r['Test runs (cumulative)'])) for r in csv.DictReader(open(BASE/'source_runs.csv')))
rdate=[r[0] for r in runs]
prev=offset=0; rows=[]
for row in csv.DictReader(open(BASE/'source_elo.csv')):
 d=date.fromisoformat(row['Date'].replace('‑','-'));elo=row['Elo (single-thread)']
 if not elo: offset+=prev;continue
 prev=float(re.split(': | ±',elo)[1]);cum=prev+offset;n=d.toordinal();i=bisect.bisect_left(rdate,n)
 if i==0 or i==len(runs):continue
 x0,y0=runs[i-1];x1,y1=runs[i];r=y0+(y1-y0)*(n-x0)/(x1-x0)
 rows.append(dict(date=d.isoformat(),elo=cum,log_efficiency=cum/142.987,efficiency=math.exp(cum/142.987),cumulative_tests=r))
with open(BASE/'matched_observations.csv','w') as f:
 w=csv.DictWriter(f,fieldnames=rows[0]);w.writeheader();w.writerows(rows)
print(f'{len(rows)} matched observations; {rows[0]["date"]} to {rows[-1]["date"]}')

# Re-read E2 per-seed claims from code/results/e2_pa.json
import json, statistics, math
d=json.load(open('/home/user/AI-works/axiom-induction/code/results/e2_pa.json'))['results']
need=['Q1','Q2','Q4','Q5','Q6','Q7']
lasts=[]; onset={}
slopes={}
for r in d:
    fs=r['first_seen']
    last=max(fs.get(q,10**9) for q in need); lasts.append(last)
    rows=r['rows']; ns=[x['n'] for x in rows]; eq=[x['eq']['yes'] for x in rows]
    on=None
    for i in range(len(ns)):
        if all(e>=0.95 for e in eq[i:]): on=ns[i]; break
    onset[r['seed']]=on
print('last needed axiom first seen: min',min(lasts),'max',max(lasts),'median',statistics.median(lasts))
from collections import Counter
print('onset of eq>=0.95 (n:count)',Counter(onset.values()))
# slopes from bits
keys=['frag-complete','spare-nested(T_and)','spare-true(0+x=x)','spare-false(0=1)']
r0=d[0]['rows'][0]
print('row keys',list(r0.keys()))
acc={}
for k in keys:
    v64=[];v512=[]
    for r in d:
        b64=[x for x in r['rows'] if x['n']==64][0]['bits']; b512=[x for x in r['rows'] if x['n']==512][0]['bits']
        v64.append(b64[k]-b64['T*']); v512.append(b512[k]-b512['T*'])
    print(k,'mean diff 64:',round(statistics.mean(v64),3),'512:',round(statistics.mean(v512),3),'slope/doubling',round((statistics.mean(v512)-statistics.mean(v64))/3,3))
# false acceptances
for r in d:
    for x in r['rows']:
        if x.get('false_accepted'):
            print('seed',r['seed'],'n',x['n'],'map',x['map'],x.get('map_tag'),round(x['map_post'],3),x['false_accepted'])
# unsound MAP count n=8
for n in (8,16):
    c=Counter(x['map_tag'] for r in d for x in r['rows'] if x['n']==n)
    print('MAP tags at',n,c)

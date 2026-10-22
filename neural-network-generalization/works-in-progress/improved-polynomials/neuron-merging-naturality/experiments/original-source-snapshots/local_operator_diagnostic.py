from pathlib import Path
import json,numpy as np
root=Path('/workspace/population-naturality-2026-10-22/experiments')
cases=[('round2-000-heldout8-majority5-H4-adam-s0-g1.1','raw-unsigned-balanced'),('fresh-002-majority5-H4-N32-sgd-s0','raw-signed-unbalanced'),('fresh-000-majority5-H4-N32-adam-s0','q1')]
rs=[]
for ident,key in cases:
 r=json.loads((root/'results-v3'/f'{ident}.json').read_text()); wit=json.loads((root/'q1-output-results'/f'{ident}.json').read_text())['best'] if key=='q1' else r['cap_witnesses'][key]
 a=np.load(r['checkpoint']);w=[a[f'w{i}'].astype(float) for i in range(r['H']+1)];n=r['N'];q=wit['q'];ps=[]
 for g,s in zip(wit['groups'],wit['signs']):
  b=np.eye(q)[g]*np.asarray(s)[:,None];ps.append((b/np.bincount(g)[None,:])@b.T)
 delta=[(r['d']+1)/n*np.linalg.norm(w[0]@(np.eye(n)-ps[0]),2)**2]
 delta += [np.linalg.norm(ps[j-1]@w[j]@(np.eye(n)-ps[j]),2)**2 for j in range(1,r['H'])]
 c=(sum(delta)*(1+r['H']*r['variants']['raw']['Ev']))**.5
 rs.append({'model':ident,'witness':key,'q':q,'layer_delta_squared':delta,'required_c_sufficient_operator_bound':c,'scope':'Float64 spectral sufficient-bound diagnostic. Large values do not disprove clipped stability or population membership.'})
(root/'local-operator-diagnostic.json').write_text(json.dumps(rs,indent=2)+'\n')
print(json.dumps(rs,indent=2))

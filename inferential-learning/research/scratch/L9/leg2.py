import numpy as np
exec(open('leg.py').read().split('for alpha_deg')[0])
al=np.radians(45); r,phi,w=simulate(al, L=60.0, N=8_000_000)
I0=np.cos(al)
for rc in [2,3,5,10,20]:
    res=[]
    for pc in [2*np.pi/3, np.pi, 4*np.pi/3]:
        dr=0.2; dp=0.1
        m=(np.abs(r-rc)<dr/2)&(np.abs(phi-pc)<dp/2)
        res.append(m.sum()*w/(rc*dr*dp)/(I0/2*abs(np.sin(pc/2))/rc))
    print("r/a=",rc," MC/theory at phi=120,180,240 deg:", np.round(res,3))

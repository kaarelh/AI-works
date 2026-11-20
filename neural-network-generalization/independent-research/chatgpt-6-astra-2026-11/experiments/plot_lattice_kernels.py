"""Plot exact rational population-kernel calculations and asymptotic ratios."""
import json,sys,os
from pathlib import Path
import mpmath as mp
import numpy as np
os.environ.setdefault('MPLCONFIGDIR',str(Path(__file__).resolve().parents[1]/'tmp/matplotlib'))
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
sys.set_int_max_str_digits(0);mp.mp.dps=50
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'figures';OUT.mkdir(exist_ok=True)
a=json.loads((ROOT/'results/exact_lattice_kernels.json').read_text())['rows']
b=json.loads((ROOT/'results/exact_lattice_midpoint.json').read_text())['rows']
sets=[('odd, bias 0',[x for x in a if x['law']=='odd'],'#0072B2','o'),
      ('mixed, bias 0',[x for x in a if x['law']=='mixed'],'#D55E00','s'),
      ('odd, bias $1/\\sqrt{5}$',[x for x in b if (x['p'],x['q'])==(1,3)],'#009E73','^')]
plt.rcParams.update({'font.size':9,'axes.spines.top':False,'axes.spines.right':False,'pdf.fonttype':42,'ps.fonttype':42})
fig,ax=plt.subplots(1,2,figsize=(7.2,2.9),layout='constrained')
for label,rows,color,marker in sets:
 rows=sorted(rows,key=lambda x:x['r']);r=np.array([x['r'] for x in rows]);value=np.array([float(mp.mpf(x['exact_numerator'])/mp.mpf(x['exact_denominator'])) for x in rows]);keep=r<=256
 ax[0].semilogy(r[keep],value[keep],marker=marker,ms=3,lw=1,color=color,label=label)
 ratio=np.array([float(x.get('ratio_to_asymptotic',x.get('ratio_to_midpoint_asymptotic'))) for x in rows])
 ax[1].loglog(r,ratio,marker=marker,ms=3,lw=1,color=color)
ax[0].set(xlabel='Even dimension $r$',ylabel='Full-parity kernel eigenvalue',title='Exact population kernels')
ax[0].legend(loc='lower left',fontsize=7.3,frameon=False)
ax[1].axhline(1,color='.4',ls='--',lw=.8);ax[1].set(xlabel='Even dimension $r$',ylabel='Exact kernel / leading asymptotic',title='Normalized by the asymptotic')
for x in ax:x.grid(alpha=.2)
fig.savefig(OUT/'lattice-kernel-contrast.pdf');fig.savefig(OUT/'lattice-kernel-contrast.png',dpi=180)
print(OUT/'lattice-kernel-contrast.pdf')

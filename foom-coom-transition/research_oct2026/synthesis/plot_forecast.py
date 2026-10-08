from pathlib import Path
import os, json
BASE=Path(__file__).resolve().parent
os.environ['MPLCONFIGDIR']=str(BASE/'mplconfig')
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
S=json.loads((BASE/'prior.json').read_text())
d=pd.read_csv(BASE/'draws.csv'); d=d[d.Hmax==60]
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':10,'axes.spines.top':False,'axes.spines.right':False})
fig,axes=plt.subplots(1,2,figsize=(9.3,3.35),gridspec_kw={'width_ratios':[1.5,1]})
for key,label,color in [('more_completion','More completion','#BB682E'),('central','Working judgment','#126879'),('more_persistence','More persistence','#7560A6')]:
    dd=d.sort_values('log10_x'); counts=dd.family.value_counts()
    w=np.array([S['weights'][key][f]/counts[f] for f in dd.family])
    for ax in axes:ax.plot(dd.log10_x,np.cumsum(w),color=color,lw=2.2 if key=='central' else 1.4,label=label)
for ax,lim in zip(axes,[(25,120),(110,120)]):
    ax.set_xlim(*lim);ax.set_ylim(0,1);ax.set_xlabel('log₁₀ research FLOPs');ax.grid(alpha=.15)
    ax.set_yticks([0,.25,.5,.75,1],['0%','25%','50%','75%','100%'])
axes[0].set_ylabel('Probability transition has occurred')
axes[0].legend(loc='upper left',frameon=False,fontsize=9)
axes[0].set_title('Different judgments about persistence',loc='left',fontsize=10.5)
axes[1].set_title('Detail near the cosmic budget',loc='left',fontsize=10.5)
fig.tight_layout()
fig.savefig(BASE/'forecast_cdf.png',dpi=210,bbox_inches='tight')
fig.savefig(BASE/'forecast_cdf.pdf',bbox_inches='tight')

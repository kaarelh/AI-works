import csv,json
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from fit_stockfish import model,BASE,Z,Y,CUT
FITS={r['name']:r for r in json.loads((BASE/'fit_results.json').read_text())}
selected=['power','shifted_power','stretched_exponential','exp_ceiling','hyperbolic_ceiling_p1']
fig,axs=plt.subplots(1,2,figsize=(12,4.5),layout='constrained')
colors=['#D55E00','#009E73','#0072B2','#CC79A7','#E69F00']
for ax,train in zip(axs,[False,True]):
 ax.scatter(Z[:CUT],Y[:CUT],s=9,color='#555',alpha=.6,label='Observed: training period')
 ax.scatter(Z[CUT:],Y[CUT:],s=14,color='#111',marker='x',label='Observed: chronological holdout')
 zz=np.geomspace(min(Z),1,300)
 for n,col in zip(selected,colors):
  p=FITS[n]['train_params' if train else 'params']
  ax.plot(zz,model(n,zz,p),color=col,label=n.replace('_',' '),lw=1.5)
 ax.axvline(Z[CUT-1],color='#777',ls=':',lw=1)
 ax.set_xscale('log');ax.set_xlabel('Cumulative Fishtest tests / 126,479');ax.set_ylabel('ln(compute efficiency)')
 ax.set_title('Fits to all 258 observations' if not train else 'Fit through Nov 2020; predict 2020–2023')
 ax.spines[['top','right']].set_visible(False)
axs[1].legend(fontsize=8,loc='upper left')
fig.suptitle('Stockfish: several short-range fits imply radically different far tails',fontsize=13)
fig.savefig(BASE/'stockfish_fit_comparison.png',dpi=180)

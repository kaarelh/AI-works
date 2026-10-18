#!/usr/bin/env python3
"""Exploratory polynomial-radius diagnostic; no fitted asymptotic curve."""
import os
os.environ['MPLCONFIGDIR']='/tmp/depth3-matplotlib-cache'
os.environ['XDG_CACHE_HOME']='/tmp/depth3-font-cache'
from pathlib import Path
import json
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
ROOT=Path(__file__).resolve().parent

def main():
    data=json.loads((ROOT/'polynomial-depth-calibration.json').read_text())
    colors={'mnist3vs8':'#367ca2','fashion0vs6':'#c37c31','mnistevenodd':'#278473'}
    plt.rcParams.update({'font.family':'DejaVu Sans','font.size':9,'axes.spines.top':False,'axes.spines.right':False,'pdf.fonttype':42})
    fig,axes=plt.subplots(1,2,figsize=(8.1,3.8));used=[]
    for ax,opt in zip(axes,['sgd','adam']):
        rows=[r for r in data['models'] if r['optimizer']==opt and not r['projected'] and r['task'] in colors]
        for r in rows:
            index=int(r['model'][:3]);jitter=np.exp(((index*37)%11-5)*.012)
            color=colors[r['task']];marker='s' if r['initial_gain']==1 else 'o'
            x=r['hidden_depth']*jitter;y=r['hidden_depth_times_largest_spectral_c']
            ax.scatter(x,y,s=40,marker=marker,edgecolors=color,facecolors=color if r['training_eligible'] else 'none',linewidths=1)
            used.append(r)
        ax.axhline(.001,color='#444444',linestyle='--',linewidth=.9,label='c_H=.001/H passes above this line')
        ax.set_xscale('log',base=2);ax.set_yscale('log');ax.set_xticks([4,16,32,64,128],['4','16','32','64','128']);ax.set_xlim(3.3,151)
        ax.set_xlabel('Hidden depth H (slight display jitter)');ax.set_ylabel(r'$H c_{\mathrm{spectral}}$')
        ax.set_title('Vanilla minibatch SGD' if opt=='sgd' else 'Adam');ax.grid(alpha=.18,which='both');ax.set_axisbelow(True)
    legend=[Line2D([],[],color=color,marker='o',linestyle='',label=label) for task,color,label in
            [('mnist3vs8',colors['mnist3vs8'],'MNIST 3 / 8'),('fashion0vs6',colors['fashion0vs6'],'Fashion 0 / 6'),('mnistevenodd',colors['mnistevenodd'],'MNIST even / odd')]]
    legend.extend([Line2D([],[],color='#444444',marker='o',linestyle='',label='Filled: all training margins > 1/2'),
                   Line2D([],[],color='#444444',marker='s',markerfacecolor='none',linestyle='',label='Square: initial internal gain 1.0'),
                   Line2D([],[],color='#444444',linestyle='--',label='Inverse-depth target .001')])
    fig.legend(handles=legend,loc='upper center',ncol=3,frameon=False,fontsize=7.5)
    fig.tight_layout(rect=[0,0,1,.84]);dest=ROOT.parent/'figures'
    for ext in ['pdf','png']:fig.savefig(dest/f'depth-calibration.{ext}',dpi=180,bbox_inches='tight')
    plt.close(fig)
    (dest/'depth-calibration-data.json').write_text(json.dumps(dict(qualification='Exploratory diagnostic after earlier outcomes. c_spectral=1/(16G) is the largest c allowed by this particular global operator bound, not the largest true stability radius. Panels have independently scaled logarithmic vertical axes. Finite-depth samples do not establish an asymptotic law.',models=used),indent=2)+'\n')

if __name__=='__main__':main()

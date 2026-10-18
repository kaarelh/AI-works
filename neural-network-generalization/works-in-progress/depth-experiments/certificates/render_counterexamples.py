#!/usr/bin/env python3
import os
os.environ['MPLCONFIGDIR']='/tmp/depth-round3-mplconfig'
from pathlib import Path
import json,numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
r=Path(__file__).resolve().parent
fig,axes=plt.subplots(1,2,figsize=(9,4.9))
for ax,name,title,score in zip(axes,['lowink-zero-105','lowink-zero-008'],['Full MNIST even/odd; all training margins > 4.48','MNIST 3/8; three training errors'],['−0.00163 → −0.15496','−0.00341 → −0.31686']):
 pixels=np.load(r/f'{name}.npz')['pixels'].reshape(28,28)
 ax.imshow(pixels,cmap='gray',vmin=0,vmax=255,interpolation='nearest');ax.set_xticks([]);ax.set_yticks([]);ax.set_title(title,fontsize=11);ax.set_xlabel('Score: '+score,fontsize=13)
 plt.imsave(r/f'{name}.png',pixels,cmap='gray',vmin=0,vmax=255)
fig.suptitle('Synthetic 8-bit inputs: verified internal-noise violations at c = 0.001',fontsize=13)
fig.tight_layout(rect=[0,0,1,.95]);fig.savefig(r/'finite-grid-counterexamples.pdf',bbox_inches='tight');fig.savefig(r/'finite-grid-counterexamples.png',dpi=180,bbox_inches='tight')

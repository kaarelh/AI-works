#!/usr/bin/env python3
import os
os.environ['MPLCONFIGDIR']='/tmp/depth-round3-mplconfig'
from pathlib import Path
import json,numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
r=Path(__file__).resolve().parent;j=json.load(open(r/'tv-boundary-105.json'));a=np.load(r/'tv-boundary-105-candidates.npz');pair=int(a['pair_indices'][32]);data=np.load(r.parent/'experiment/data/mnist.npz');ni=j['endpoint_indices_negative'][pair];pi=j['endpoint_indices_positive'][pair];w=np.load(r/'tv-boundary-105-clip_half-validstates.npz')['pixels'].reshape(28,28)
fig,ax=plt.subplots(1,3,figsize=(10,3.6))
for axis,img,title in zip(ax,[data['test_images'][ni],data['test_images'][pi],w],[f"Held-out digit {int(data['test_labels'][ni])}",f"Held-out digit {int(data['test_labels'][pi])}",'Synthetic interpolation']):
 axis.imshow(img,cmap='gray',vmin=0,vmax=255,interpolation='nearest');axis.set_title(title,fontsize=13);axis.set_xticks([]);axis.set_yticks([])
ax[2].set_xlabel('TV = 88.93; mean ink = .118\nScore: .37523 → .22781 at c = .01',fontsize=11)
fig.tight_layout();fig.savefig(r/'tv-boundary-counterexample.pdf',bbox_inches='tight');fig.savefig(r/'tv-boundary-counterexample.png',dpi=170,bbox_inches='tight')

"""Reproduce original synthesis calculations and scientific figures.

All cosmological quantities are conditional on the reference eternal LCDM model.
Figures are illustrations of necessary constraints, not construction proofs.
"""
from pathlib import Path
import json, math, os

ROOT = Path(__file__).resolve().parents[1]
os.environ.setdefault('MPLCONFIGDIR', str(ROOT/'tmp/mplconfig'))
os.environ.setdefault('XDG_CACHE_HOME', str(ROOT/'tmp/cache'))
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.ticker import LogLocator, LogFormatterMathtext

data = json.loads((ROOT/'research/cosmology/access_results.json').read_text())
k = data['constants']
c, G, hb, kb = 299792458., 6.67430e-11, 1.054571817e-34, 1.380649e-23
year = 365.25*86400
ly = c*year
H = k['H_Lambda_per_s']
T = k['deSitter_temperature_K']
tp = math.sqrt(hb*G/c**5)
lp = c*tp
E = data['protocols'][-1]['received_baryon_energy_J']
M = E/c**2

out = {
    'thermal_channel_model': {
        'description': 'Ideal C independent one-way bosonic modes, net thermal entropy export; not a universal cosmological runtime bound.',
        'entropy_bits': 1e120,
        'times_years_C1': {str(eta): 6*math.log(2)*1e120/H/year*eta/(1-eta) for eta in [.5,.9,.99]},
        'frontier': 'eta <= x/(x+6 ln 2), x=C H tau/B',
    },
    'memory_global_latency_radius_convention': {
        str(B): {'min_radius_m': lp*math.sqrt(B*math.log(2)/math.pi),
                 'min_latency_s': tp*math.sqrt(B*math.log(2)/math.pi)}
        for B in [1e60, 1e90, 1e100, 1e110, 1e120, 1e122]
    },
    'landauer_equivalents_per_kg': {
        'at_2_725_K': c*c/(kb*2.725*math.log(2)),
        'at_deSitter_K': c*c/(kb*T*math.log(2)),
    },
    'collected_baryonic_reserve': {
        'mass_kg': M, 'energy_J': E,
        'radius_example_m': (G*M/H**2)**(1/3)/2,
        'compactness_at_example': 2*G*M/c**2/((G*M/H**2)**(1/3)/2),
        'lambda_term_at_example': H**2*((G*M/H**2)**(1/3)/2)**2/c**2,
    },
    'CMB_deSitter_crossing_pure_dS_years': math.log(2.725/T)/H/year,
    'moving_endpoint_volume_fraction_of_fixed_endpoint': {
        str(d): 1-d*d for d in [0,.25,.5,.75,.9]
    }
}
(ROOT/'analysis/synthesis_results.json').write_text(json.dumps(out,indent=2)+'\n')

INK='#172835'; TEAL='#126879'; BLUE='#2b67aa'; GOLD='#c58622'; PALE='#e6f0f2'; GRAY='#647482'
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':10,'axes.spines.top':False,
 'axes.spines.right':False,'axes.labelcolor':INK,'text.color':INK,'xtick.color':GRAY,
 'ytick.color':GRAY,'axes.titleweight':'bold','axes.titlesize':12,
 'savefig.facecolor':'white','figure.facecolor':'white','axes.grid':False})
FIG=ROOT/'figures';FIG.mkdir(exist_ok=True)
def save(fig,name):
    fig.savefig(FIG/(name+'.png'),dpi=210,bbox_inches='tight')
    fig.savefig(FIG/(name+'.svg'),bbox_inches='tight')
    plt.close(fig)

# 1. Geometry in conformal coordinates; a radial half-section, not a volume plot.
fig, axs = plt.subplots(1,2,figsize=(10,4.45),gridspec_kw={'width_ratios':[1.08,1]})
ax=axs[0];s=np.linspace(0,1,500)
ax.fill_betweenx(s,0,s,color='#f5e9d4',label='Can be reached from now')
ax.fill_betweenx(s,0,np.minimum(s,1-s),color='#b9d9dd',label='Can also send a reply home')
ax.plot(s,s,color=GOLD,lw=1.8)
ax.plot(1-s,s,color=TEAL,lw=1.8)
ax.plot([0,.25,0],[0,.5,.75],color=BLUE,lw=2.2)
ax.scatter([.25],[.5],s=30,color=BLUE,zorder=4)
ax.text(.275,.49,'Probe at 0.5c,\nthen photon reply',fontsize=8.5,va='center')
ax.text(.67,.89,'One-way\ndescendants',fontsize=9,ha='center',color='#8a5912')
ax.text(.13,.28,'Replies\npossible',fontsize=9,ha='center',color=TEAL)
ax.axhline(1,color=GRAY,lw=1,ls='--');ax.text(.98,1.025,'Infinite future proper time',ha='right',fontsize=8.5)
ax.set(xlim=(0,1.01),ylim=(0,1.03),xlabel='Comoving distance / remaining light-travel distance',
       ylabel='Fraction of remaining conformal time',title='A. The return constraint')
ax.set_xticks([0,.25,.5,.75,1]);ax.set_yticks([0,.25,.5,.75,1])
ax=axs[1];b=np.linspace(.001,1,400);L=k['present_event_horizon_Gly']
ax.plot(b,L*b,color=GOLD,lw=2.4,label='One-way frontier')
ax.plot(b,L*b/(1+b),color=TEAL,lw=2.4,label='Immediate reply can return')
ax.set(xlim=(0,1),ylim=(0,18.7),xlabel='Outbound peculiar speed / c',ylabel='Present-distance radius (billion light-years)',
       title='B. Reachable radii')
ax.text(.97,16.95,'16.68 Gly',ha='right',fontsize=9,color='#8a5912')
ax.text(.97,8.75,'8.34 Gly',ha='right',fontsize=9,color=TEAL)
ax.legend(frameon=False,loc='upper left',fontsize=8.5)
ax.grid(alpha=.16)
fig.subplots_adjust(wspace=.33,bottom=.15,top=.88)
save(fig,'causal-domains')

# 2. Two necessary geometric scales, away from Nariai's strongly curved limit.
fig,ax=plt.subplots(figsize=(9.6,4.65))
ms=np.logspace(30,52,400);rs=2*G*ms/c**2/ly;rt=(G*ms/H**2)**(1/3)/ly
ax.fill_between(ms,rs,rt,color=PALE)
ax.loglog(ms,rs,color='#ab5543',lw=2,label='Schwarzschild radius')
ax.loglog(ms,rt,color=TEAL,lw=2,label='Maximum turnaround radius')
ax.axvline(M,color=GRAY,lw=1,ls=':')
R=out['collected_baryonic_reserve']['radius_example_m']/ly
ax.scatter(M,R,color=BLUE,s=38,zorder=4)
ax.annotate('Illustrative collected reserve\n'+r'$3.12\times10^{50}$ kg at 0.98 Gly',xy=(M,R),xytext=(2e42,2e3),
            fontsize=9,color=BLUE,arrowprops={'arrowstyle':'-','color':BLUE,'connectionstyle':'angle,angleA=0,angleB=90'},va='center',bbox={'facecolor':'white','edgecolor':'none','alpha':.8,'pad':3})
ax.text(1.2e32,.03,'Room for a bound, diffuse reserve\nwithout black-hole collapse',fontsize=10,color=TEAL)
ax.set(xlim=(1e30,1e52),ylim=(1e-14,1e11),xlabel='Reservoir mass (kg)',ylabel='Radius (light-years)',
       title='Gathering resources does not require putting them all in the active processor')
ax.legend(frameon=False,loc='lower right',fontsize=9)
ax.set_xticks(10.**np.arange(30,53,4));ax.set_yticks(10.**np.arange(-12,11,4))
ax.grid(alpha=.15,which='major')
fig.tight_layout();save(fig,'storage-window')

# 3. Conditional erasure accounting with explicit mass and bath assumptions.
fig,ax=plt.subplots(figsize=(9.6,4.65))
labels=['Earth','Sun','Milky Way stars','Ideal returned\nbaryonic energy']
masses=np.array([5.9722e24,1.98847e30,5.43e10*1.98847e30,M])
x=np.arange(4)
cold=np.log10(masses*c*c/(kb*T*math.log(2)))
warm=np.log10(masses*c*c/(kb*2.725*math.log(2)))
for i in x:
    ax.plot([i,i],[warm[i],cold[i]],color='#c4d4dc',lw=9,solid_capstyle='round',zorder=1)
ax.scatter(x,warm,s=52,color=GOLD,label='Bath at 2.725 K',zorder=3)
ax.scatter(x,cold,s=52,color=TEAL,label='Asymptotic de Sitter bath',zorder=3)
for i in x:
    ax.annotate(f'$10^{{{cold[i]:.1f}}}$',(i,cold[i]),xytext=(8,0),textcoords='offset points',fontsize=9,va='center',color=TEAL)
    ax.annotate(f'$10^{{{warm[i]:.1f}}}$',(i,warm[i]),xytext=(8,0),textcoords='offset points',fontsize=9,va='center',color='#8a5912')
ax.set(xlim=(-.35,3.7),ylim=(60,127),ylabel='log₁₀ of ideal irreversible erasure equivalents',
       title='The same mass gives very different erasure budgets at different bath temperatures')
ax.set_xticks(x,labels);ax.grid(axis='y',alpha=.17);ax.legend(frameon=False,loc='upper left',fontsize=9)
fig.tight_layout();save(fig,'erasure-budgets')

# 4. Finite-throughput cost derived in this report for ideal thermal modes.
fig,axs=plt.subplots(1,2,figsize=(10,4.3),gridspec_kw={'width_ratios':[1.12,1]})
ax=axs[0];x=np.logspace(-2,4,500);eta=x/(x+6*np.log(2))
ax.semilogx(x,eta,color=TEAL,lw=2.5)
ax.fill_between(x,0,eta,color=PALE)
ax.axhline(1,color=GRAY,ls='--',lw=1)
ax.set(xlim=(1e-2,1e4),ylim=(0,1.06),xlabel=r'$x=C H_\Lambda \,\tau/B$',ylabel=r'Erasure efficiency $\eta=B k_B T\ln 2/E$',
       title='A. Efficiency versus time and channels')
ax.text(.06,.88,'Static Landauer ceiling',fontsize=9,color=GRAY)
ax.text(40,.33,'Compatible with the\nideal transport bound',fontsize=9,color=TEAL)
ax.grid(alpha=.15)
ax=axs[1];etas=[.5,.9,.99];ts=[out['thermal_channel_model']['times_years_C1'][str(e)] for e in etas]
ax.barh(np.arange(3),np.log10(ts),height=.48,color=[TEAL,BLUE,GOLD])
ax.set(xlim=(129,133.5),yticks=np.arange(3),yticklabels=['50%','90%','99%'],
       xlabel='log₁₀ of necessary duration (years)',title='B. $10^{120}$ entropy bits, one channel')
ax.invert_yaxis();ax.grid(axis='x',alpha=.15)
for i,t in enumerate(ts):ax.text(math.log10(t)+.05,i,f'{t:.2g} yr',fontsize=8.5,va='center')
fig.subplots_adjust(wspace=.38,bottom=.18,top=.86)
save(fig,'entropy-export-frontier')

print(json.dumps(out,indent=2))

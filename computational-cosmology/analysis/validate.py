"""Independent analytic and consistency checks on the report's numerical outputs."""
from pathlib import Path
import json, math
from scipy.integrate import quad

ROOT=Path(__file__).resolve().parents[1]
d=json.loads((ROOT/'research/cosmology/access_results.json').read_text())
s=json.loads((ROOT/'analysis/synthesis_results.json').read_text())
c=299792458.;G=6.67430e-11;hb=1.054571817e-34;kb=1.380649e-23
yr=365.25*86400;ln2=math.log(2)
k=d['constants'];H=k['H_Lambda_per_s'];T=k['deSitter_temperature_K']
checks=[]
def close(label,a,b,rel=1e-9):
    assert math.isclose(a,b,rel_tol=rel,abs_tol=0),(label,a,b)
    checks.append(label)
close('Gibbons-Hawking temperature',T,hb*H/(2*math.pi*kb))
close('Horizon entropy',k['deSitter_horizon_entropy_bits'],math.pi*c**5/(G*hb*H**2*ln2))
close('Pure de Sitter shell integral',quad(lambda u:3*u*u*(1-2*u)/(1-u),0,.5)[0],17/8-3*math.log(2))
close('Published weighting reconstructed',quad(lambda u:3*u*u*(1-u)**2*(1-2*u),0,.5)[0],1/64)
previous=0
for row in d['protocols']:
    beta=row['beta'];f=row['received_energy_fraction_of_initial_event_horizon_matter']
    close(f'{beta}: return radius',row['return_radius_Gly'],beta/(1+beta)*k['present_event_horizon_Gly'])
    close(f'{beta}: energy to erasures',row['baryon_landauer_erasures_at_TdS'],row['received_baryon_energy_J']/(kb*T*ln2))
    assert previous<f<(beta/(1+beta))**3
    previous=f
checks.append('Received energy positive, increasing with speed, below unredshifted shell rest energy')
M=s['collected_baryonic_reserve']['mass_kg'];R=s['collected_baryonic_reserve']['radius_example_m']
assert 1-2*G*M/(c*c*R)-H*H*R*R/(c*c)>0
checks.append('Illustrative reserve lies in exterior static region')
close('Nariai double-root mass',k['Nariai_mass_kg'],c**3/(3*math.sqrt(3)*G*H))
B=1e120
for eta,t in s['thermal_channel_model']['times_years_C1'].items():
    eta=float(eta);tau=t*yr
    E1=kb*T*ln2*B/eta
    E2=kb*T*ln2*B+3*hb*ln2**2*B*B/(math.pi*tau)
    close(f'Thermal frontier at efficiency {eta}',E1,E2)
for Bstr,row in s['memory_global_latency_radius_convention'].items():
    B=float(Bstr)
    close(f'{Bstr}: area envelope',math.pi*row['min_radius_m']**2/(hb*G/c**3*ln2),B)
    close(f'{Bstr}: flat comparison',row['min_latency_s'],row['min_radius_m']/c)
assert all(0<x['reachable_mass_fraction_relative_to_today']<1 for x in d['delay_examples'])
checks.append('All delayed-launch fractions between zero and one')
result={'passed_checks':len(checks),'checks':checks,
        'scope':'Arithmetic, dimensional, and analytic consistency only; not validation of speculative physical attainability.'}
(ROOT/'analysis/validation_results.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))

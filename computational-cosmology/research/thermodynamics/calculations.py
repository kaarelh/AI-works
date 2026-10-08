"""Illustrative resource conversions; all temperatures and engineering models explicit."""
import json, math
from pathlib import Path
c=299792458.0; G=6.67430e-11; hbar=1.054571817e-34; k=1.380649e-23
sigma=5.670374419e-8; year=365.25*86400; Msun=1.98847e30
Mpc=3.085677581491367e22
H0=67.4*1000/Mpc; Ol=.685; H=H0*math.sqrt(Ol)
R=c/H; T=hbar*H/(2*math.pi*k)
Erasure=lambda E, temp:E/(k*temp*math.log(2))
rows=[]
for name,M in [('Earth',5.9722e24),('Sun',Msun),('Milky Way stars',5.43e10*Msun),('Illustrative harvest energy',3.5e67/c**2)]:
    E=M*c*c
    rows.append(dict(name=name,mass_kg=M,rest_energy_J=E,erasure_bits_2_725K=Erasure(E,2.725),erasure_bits_TdS=Erasure(E,T),bh_entropy_bits=4*math.pi*G*M*M/(hbar*c*math.log(2)),schwarzschild_radius_m=2*G*M/c**2,bh_temperature_K=hbar*c**3/(8*math.pi*G*M*k)))
E=3.5e67; A=4*math.pi*R**2
# A deliberately formal blackbody extrapolation. Horizon-sized blackbody geometry and
# geometric optics fail for T~TdS; do not advertise as a universal achievable limit.
rate=sigma*A*T**3/(k*math.log(2))
formal=dict(area_m2=A,power_W=sigma*A*T**4,landauer_erasure_rate_per_s=rate,erasures_per_Hubble_time=rate/H,energy_3_5e67J_exhaustion_years=E/(sigma*A*T**4)/year,thermal_wavelength_hc_over_kT_m=2*math.pi*hbar*c/(k*T),wien_peak_wavelength_m=.002897771955/T)
out=dict(constants=dict(H0_km_s_Mpc=67.4,Omega_Lambda=Ol,H_Lambda_s_inverse=H,Hubble_time_year=1/H/year,horizon_radius_m=R,deSitter_temperature_K=T,deSitter_entropy_bits=math.pi*R**2/(hbar*G/c**3)/math.log(2)),resource_rows=rows,formal_blackbody_at_TdS_NOT_engineering_bound=formal,harvest_integral_audit=dict(assumption='Conserved initially homogeneous rest mass, pure de Sitter, instantaneous conversion on outward null front',integral=17/24-math.log(2),fraction_initial_horizon_rest_energy=3*(17/24-math.log(2)),Krauss_Starkman_quoted_fraction=1/64))
path=Path(__file__).with_name('calculations.json');path.write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(out,indent=2))

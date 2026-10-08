"""Conditional Lambda-CDM resource access, storage, and photon-return budgets.

All matter shells are labelled by present-day proper (= a0=1 comoving) radius.
This avoids mixing density at encounter with initial volume. This is an explicit
idealized test-probe protocol, not a claim that its conversion/storage is feasible.
Run with Python 3 and the project's requirements installed.
"""
from pathlib import Path
import json
import math
import numpy as np
from scipy.integrate import quad
from scipy.optimize import brentq

C = 299792458.0
G = 6.67430e-11
HBAR = 1.054571817e-34
KB = 1.380649e-23
YEAR = 365.25 * 86400
MPC = 3.085677581491367e22
MSUN = 1.98847e30
GLY = C * YEAR * 1e9
H0 = 67.4 * 1000 / MPC
OM = .315
OB = .0493
OR = 9.2e-5
OL = 1 - OM - OR
HL = H0 * math.sqrt(OL)
LAMBDA = 3 * HL**2 / C**2
RHO_C = 3 * H0**2 / (8 * math.pi * G)
RHO_M = OM * RHO_C
RHO_B = OB * RHO_C
TD = HBAR * HL / (2 * math.pi * KB)
MN = C**3 / (3 * math.sqrt(3) * G * HL)

def E_of_y(y):
    return math.sqrt(OR * y**4 + OM * y**3 + OL)

J = quad(lambda y: 1 / E_of_y(y), 0, 1, epsabs=1e-12)[0]
EH = C / H0 * J
PARTICLE = C / H0 * quad(
    lambda a: 1 / math.sqrt(OR + OM*a + OL*a**4), 0, 1,
    epsabs=1e-12)[0]

def y_at_s(s):
    """1/a when fraction s of all remaining conformal time has elapsed."""
    if s >= 1:
        return 0.0
    if s <= 0:
        return 1.0
    target = (1 - s) * J
    return brentq(lambda y: quad(lambda z: 1/E_of_y(z), 0, y)[0]-target,
                  0, 1, xtol=1e-14)

def photon_ratio(x, beta=1):
    return y_at_s(x * (1+1/beta)) / y_at_s(x/beta)

def mass(radius, density):
    return 4*math.pi/3 * density * radius**3

def storage(m):
    rs = 2*G*m/C**2
    rta = (G*m/HL**2)**(1/3)
    return dict(mass_kg=m, solar_masses=m/MSUN,
                schwarzschild_radius_m=rs, schwarzschild_radius_ly=rs/(C*YEAR),
                max_turnaround_radius_m=rta, max_turnaround_radius_Mpc=rta/MPC,
                radius_dynamic_range=rta/rs,
                nariai_mass_fraction=m/MN,
                weak_field_compactness_at_rta=rs/rta)

def access(beta):
    xmax=beta/(1+beta)
    f=quad(lambda x: 3*x*x*photon_ratio(x,beta),0,xmax,
           epsabs=1e-11, epsrel=1e-10)[0]
    de=quad(lambda x: 3*x*x*(1-x*(1+1/beta))/(1-x/beta),0,xmax)[0]
    m_b=mass(EH,RHO_B)
    m_m=mass(EH,RHO_M)
    y_update=y_at_s(1-beta)
    latest_update_gyr=quad(lambda y:1/(y*E_of_y(y)), y_update,1)[0]/H0/YEAR/1e9
    return dict(beta=beta, one_way_radius_Gly=beta*EH/GLY,
                return_radius_Gly=xmax*EH/GLY,
                one_way_baryonic_mass_kg=m_b*beta**3,
                return_region_baryonic_mass_kg=m_b*xmax**3,
                received_energy_fraction_of_initial_event_horizon_matter=f,
                pure_deSitter_energy_fraction=de,
                received_baryon_energy_J=m_b*C*C*f,
                received_all_matter_energy_J=m_m*C*C*f,
                baryon_landauer_erasures_at_TdS=m_b*C*C*f/(KB*TD*math.log(2)),
                all_matter_landauer_erasures_at_TdS=m_m*C*C*f/(KB*TD*math.log(2)),
                baryon_mass_equivalent_storage=storage(m_b*f),
                latest_central_software_update_that_reaches_final_frontier_Gyr=latest_update_gyr)

def launch_delay(dt_gyr, beta=1):
    # Radiation negligible at a >=1: analytic flat matter+Lambda scale factor.
    initial=math.asinh(math.sqrt(OL/OM))
    anew=(math.sinh(initial+1.5*HL*dt_gyr*1e9*YEAR)/math.sqrt(OL/OM))**(2/3)
    remaining=quad(lambda y: 1/E_of_y(y),0,1/anew)[0]/J
    return dict(delay_Gyr=dt_gyr, scale_factor=anew,
                reachable_mass_fraction_relative_to_today=remaining**3,
                radius_fraction_relative_to_today=remaining)

out=dict(
    assumptions=dict(H0_km_s_Mpc=67.4,Omega_m=OM,Omega_b=OB,
                     Omega_r=OR,Omega_Lambda=OL,
                     notes="Eternal flat Lambda-CDM; converters/probes massless; immediate unit-efficient conversion; redshift only; homogeneous initially comoving matter."),
    constants=dict(H_Lambda_per_s=HL,Lambda_per_m2=LAMBDA,
                   Hubble_time_Gyr=1/H0/YEAR/1e9,
                   asymptotic_Hubble_time_Gyr=1/HL/YEAR/1e9,
                   present_Hubble_radius_Gly=C/H0/GLY,
                   present_particle_horizon_Gly=PARTICLE/GLY,
                   present_event_horizon_Gly=EH/GLY,
                   asymptotic_event_horizon_Gly=C/HL/GLY,
                   deSitter_temperature_K=TD,
                   deSitter_horizon_entropy_bits=math.pi*C**5/(G*HBAR*HL**2*math.log(2)),
                   Nariai_mass_kg=MN,Nariai_mass_solar=MN/MSUN,
                   Nariai_radius_Gly=C/(math.sqrt(3)*HL)/GLY,
                   event_horizon_baryonic_mass_kg=mass(EH,RHO_B),
                   event_horizon_all_matter_mass_kg=mass(EH,RHO_M)),
    protocols=[access(b) for b in [.01,.1,.5,1]],
    storage_examples={label:storage(m) for label,m in [
        ("Sun",MSUN),("Milky_Way_stars",5.43e10*MSUN),
        ("Local_Group_total_mass_illustrative",3e12*MSUN),
        ("one_e50_kg",1e50),("one_e51_kg",1e51),("one_e52_kg",1e52)]},
    delay_examples=[launch_delay(d) for d in [.001,.1,1,10,50]],
    pure_deSitter_audit=dict(
        direct_fraction=17/8-3*math.log(2),
        krauss_starkman_stated_fraction=1/64,
        ratio=(17/8-3*math.log(2))/(1/64),
        direct_formula="integral_0^0.5 3*x^2*(1-2*x)/(1-x) dx",
        extra_density_formula="integral_0^0.5 3*x^2*(1-x)^2*(1-2*x) dx = 1/64",
        normalized_proof_check=quad(lambda x:3*x*x*(1-x)**2*(1-2*x),0,.5)[0]),
)
assert abs(out['pure_deSitter_audit']['direct_fraction']-out['protocols'][-1]['pure_deSitter_energy_fraction'])<1e-13
path=Path(__file__).with_name('access_results.json')
path.write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(out,indent=2))

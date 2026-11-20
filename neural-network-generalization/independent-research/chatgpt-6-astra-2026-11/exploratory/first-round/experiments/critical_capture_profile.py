"""Explicit matched-profile prediction for the reduced rare-neuron ODE.

This computes a derived asymptotic, not a certified theorem for network GD.
The negative central cell exits at S=h+eta; continuing it to b1=0 is wrong.
"""
import json,math
from pathlib import Path
from scipy.integrate import quad
ROOT=Path(__file__).resolve().parents[1]
def profile(L,eta):
 h=L*L;eta0=h*h/8
 if eta<=eta0:return 0.
 rh=.5+1/h;k=rh*L;lam=math.sqrt(h+2)/(2*math.sqrt(2)*L);kap=k/lam
 A=(h+2)/(2*h);sc=2*h/(h+2);B=math.sqrt(h*h/(h+2)+eta*eta/2)
 tn=(math.log(2*math.sqrt(A)/B)-math.asinh(math.sqrt(A)*(h+eta-sc)/B))/lam
 bstart=-h/2;b2=eta+h/2;q0=k*h/2-eta/L
 bend=(4*eta-h*h/2)/(h+4);pend=q0+k*bend
 AD=1+k*k;bc=-k*q0/AD;BD=math.sqrt(b2*b2+q0*q0/AD)
 td=2/math.sqrt(AD)*(math.asinh(math.sqrt(AD)*(bend-bc)/BD)-math.asinh(math.sqrt(AD)*(bstart-bc)/BD))
 ae=math.sqrt(pend*pend+bend*bend+b2*b2);pe=(pend/(2*L)+(bend+b2)/4)/lam
 C=4*bend/(ae+pe)*math.exp(lam*(tn+td))
 rg=L/(math.sqrt(h+2)+math.sqrt(2));D1=2*h-rh*(h+2)
 return (2*lam*(lam+k)*C/(h*k))**kap *rg*rg*rh*D1/(2*h)
def constant(L):
 value,error=quad(lambda eta:profile(L,eta),L**4/8,math.inf,epsabs=1e-100,epsrel=1e-10,limit=300)
 return dict(L=L,eta_threshold=L**4/8,kappa=math.sqrt(2*(L*L+2)),predicted_constant=2/math.pi*value,quadrature_error_estimate=2/math.pi*error)
if __name__=='__main__':
 rows=[constant(L) for L in [2,3,4,5]]
 (ROOT/'results'/'critical_capture_profile_prediction.json').write_text(json.dumps(rows,indent=2)+'\n')
 print(json.dumps(rows,indent=2))

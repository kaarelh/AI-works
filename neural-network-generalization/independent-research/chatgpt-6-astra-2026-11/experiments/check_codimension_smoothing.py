"""Independent positive-integral and Hamming-level smoothing calculations.

Verifies the new fixed-codimension alignment and Hermite-witness identities,
then diagnoses the asymptotic sandwich. High precision, not interval proof.
"""
import json, math
from pathlib import Path
import mpmath as mp

ROOT = Path(__file__).resolve().parents[1]
mp.mp.dps = 70

def he(n, x):
    if n == 0:
        return mp.mpf(1)
    p, q = mp.mpf(1), x
    for j in range(1, n):
        p, q = q, x*q-j*p
    return q

def identities(r, k, A):
    A = mp.mpf(str(A)); L = A*mp.log(r); a = L/r
    v = mp.sqrt(L); j = r-2*k
    smooth = lambda z: v*mp.exp(-z*z/(2*L))/mp.sqrt(2*mp.pi)+z*mp.erfc(-z/(v*mp.sqrt(2)))/2
    mu_terms, nu_terms = [], []
    for h in range(r+1):
        z = mp.mpf(2*h-r)
        mult = sum(math.comb(j, h-b)*math.comb(2*k, b)*(-1)**(j-h+b)
                   for b in range(max(0,h-j), min(2*k,h)+1))
        mu_terms.append(mult*smooth(z))
        if k:
            hermite_mean = mp.sqrt(L)/mp.power(r,k)*he(2*k-2,z/v)*mp.exp(-z*z/(2*L))/mp.sqrt(2*mp.pi)
        else:
            hermite_mean = smooth(z)
        nu_terms.append(math.comb(r,h)*(-1)**(r-h)*hermite_mean)
    mu = abs(mp.fsum(mu_terms)/mp.power(2,r))
    nu = abs(mp.fsum(nu_terms)/mp.power(2,r))

    def integrate_peaks(f, stop):
        return mp.fsum(mp.quad(f,[h*mp.pi,(h+mp.mpf('.5'))*mp.pi,(h+1)*mp.pi])
                       for h in range(stop))
    short = int(mp.ceil(mp.sqrt(350/L)/mp.pi))
    mu_int = integrate_peaks(lambda t: mp.exp(-L*t*t/2)*mp.sin(t)**j*mp.cos(t)**(2*k)/(mp.pi*t*t) if t else 0,short)
    nu_int = integrate_peaks(lambda t: a**k*mp.exp(-L*t*t/2)*mp.sin(t)**r*t**(2*k-2)/mp.pi if t else 0,short)
    assert abs(mu-mu_int) < mp.mpf('1e-45')*mu, (r,k,A,'mu')
    assert abs(nu-nu_int) < mp.mpf('1e-45')*nu, (r,k,A,'nu')
    end = int(mp.ceil(mp.sqrt(150/a)/mp.pi))
    def integrand(t):
        if not t:
            return mp.mpf(0)
        s=(1-mp.exp(-2*a*t*t)*mp.cos(2*t))/2
        return s**(mp.mpf(j)/2)*(1-s)**k/(mp.pi*t*t)
    upper = integrate_peaks(integrand,end)+mp.power(2,-mp.mpf(r)/2)/(mp.pi*end*mp.pi)
    assert upper >= max(mu,nu)-mp.mpf('1e-55')
    asym = mp.mpf(32)/mp.pi**5*(mp.pi/2)**(4*k)*L**(2*k)*mp.power(r,-2*k-1-A*mp.pi**2/4)
    double_factorial = math.prod(range(1,2*k,2))
    mu_asym = mp.mpf(32)/mp.pi**5*double_factorial**2*mp.power(r,-2*k-1-A*mp.pi**2/4)
    return dict(r=r,k=k,A=float(A),mu=str(mu),nu=str(nu),upper_root=str(upper),
                mu_integral_relative_error=str(abs(mu-mu_int)/mu),
                nu_integral_relative_error=str(abs(nu-nu_int)/nu),
                mu_squared_to_its_asymptotic=float(mu**2/mu_asym),
                lower_to_kernel_asymptotic=float(nu**2/asym),
                upper_to_kernel_asymptotic=float(upper**2/asym),
                sandwich_ratio=float(upper**2/nu**2))


def main():
    rows=[]
    for A in (.5,1.,2.):
        for k in (1,2):
            for r in (32,64,128,256,512,1024,2048):
                row=identities(r,k,A);rows.append(row)
                print(json.dumps(row),flush=True)
                (ROOT/'results/codimension_smoothing_checks.json').write_text(json.dumps(dict(
                    status='RUNNING',precision_decimal_digits=mp.mp.dps,rows=rows,
                    qualification='Non-interval high-precision checks; no independent review.'),indent=2)+'\n')
    (ROOT/'results/codimension_smoothing_checks.json').write_text(json.dumps(dict(
        status='PASS',precision_decimal_digits=mp.mp.dps,rows=rows,
        qualification='Non-interval high-precision checks; no independent review.'),indent=2)+'\n')


if __name__ == "__main__":
    main()

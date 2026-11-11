import mpmath as mp
mp.mp.dps = 80
gam = (1-mp.e**-1)**2/4
def psi_cor_ratio(d, c):
    M = mp.mpf(2)**d; n = mp.ceil(M); lam = n/M; h = 2*n**(mp.mpf(2)/3)/M
    p = -mp.expm1(n*mp.log1p(-1/M)); a = mp.mpf(1)/d
    th = 1/(18*d*c+1); Fd = 1+(d+1)*(d+2)**2
    num = th*(p-h-lam*a) - c*(d*Fd+1)/M
    val = (num if num > 0 else 0)**2/(4*(lam+h/2))
    return val/(gam*th**2), mp.log(3*(18*d*c+1)**2/gam, 2)/d
for name, cf in (("2^sqrt d", lambda d: mp.mpf(2)**mp.sqrt(d)), ("d^ln d", lambda d: mp.mpf(d)**mp.log(d)), ("n^(1/3)", lambda d: mp.mpf(2)**(mp.mpf(d)/3))):
    for d in (256, 4096):
        r, l = psi_cor_ratio(d, cf(d))
        print("   c=%-9s d=%5d ratio %.6f  log2(1/eps_d)/d %.4f" % (name, d, float(r), float(l)))

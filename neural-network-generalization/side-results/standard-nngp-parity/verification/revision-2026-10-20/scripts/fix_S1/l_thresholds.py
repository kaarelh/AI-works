# Independent evaluation of the large-d conditions (L1)-(L9) of S1-proof.md, Section 6.2.
# For each (sigma1, A) report the first log d (scanning upward) after which each condition holds
# for the rest of the scan.  Everything in log space with mpmath.
from mpmath import mp, mpf, log, sqrt, exp, pi, e, ceil, floor, loggamma
mp.dps = 60
ct = sqrt(2*pi)*(exp(-1) - mpf(7)/20); c2 = ct**2
C0 = 2 + 2/c2
eps = 1/(64*(2 + 8/c2))
cs = mpf('1e-3')
def gam(s): return 1/(6*(1 + pi/(2*mpf(s)))**4)
C1 = {0.2: 0.9991409577, 0.3: 0.9965207801, 0.5: 0.9841671669, 1.0: 0.9304699236,
      2.0: 0.8376671521, 3.0: 0.7843346384, 8.0: 0.6977184742}   # L=2: c_1 = c_1(sigma1^2)

def L9_parts(x, A, s):
    """x = log d.  Returns (Jd, rd, Jd*rd, Jd <= e^2 (t-4) ?)"""
    g = gam(s); bA = 32*((e - 1)*A + 1) + A
    Jd = x + 1 + log(256*bA/c2) + log(1 + 4/g)*(1 + (x + log(A/eps))/(2*log(x/(mpf('1.3')*cs))))
    rd = mpf('1.1')*(cs/x + 2*exp(-x))
    t = floor(sqrt(exp(x))/5) if x < 600 else sqrt(exp(x))/5
    return Jd, rd, Jd*rd, Jd <= e**2*(t - 4), rd <= 1/(8*e**2*log(32))

def conds(x, A, s):
    d = exp(x)
    g = gam(s); c1 = mpf(C1[s])
    t = floor(sqrt(d)/5); kd = ceil(x)
    out = {}
    logn0_lb = sqrt(d)/10*x - x/2 - log(23*C0)
    out['L1'] = log(A) + log(d + 1) + log(log(2*d + 2)) < logn0_lb
    out['L2'] = 4*A/125*x/d <= 1/(23*C0)
    out['L3'] = (cs*d/x + 2 <= min(d/64, (d + 1)/3)) and (ceil(cs*d/x) <= d/e)
    out['L4'] = 2*kd <= mpf('0.1')*(t - 2)
    out['L5'] = mpf('1.1')*(cs*d/x + 2) <= mpf('0.1')*d
    out['L6'] = (mpf('1.25')*(cs/x + 2/d) <= mpf('1.3')*cs/x) and (log(x/(mpf('1.3')*cs)) >= 1)
    # L7: monotone in r, evaluate at the largest odd r < cs d/log d
    r = floor(cs*d/x)
    if r % 2 == 0: r -= 1
    if r >= cs*d/x: r -= 2
    if r >= 1:
        Lam = 2*log(4) + 2*(r + 2)*log(e*d/(r + 2))
        Lamp = (r + 2)*log(e*(d + 1)/(r + 2)) + (r + 1)/2*log(1/g) + log(1/c1)
        out['L7'] = (Lam <= d) and (Lamp <= d)
    else:
        out['L7'] = True
    out['L8'] = A/eps <= d
    Jd, rd, prod, a, b = L9_parts(x, A, s)
    out['L9a'] = a
    out['L9b'] = prod <= pi/(256*e**2)
    out['L9c'] = b
    return out

if __name__ == '__main__':
    thr = pi/(256*e**2)
    print('pi/(256e^2) =', mp.nstr(thr, 6), ' eps =', mp.nstr(eps, 6), ' C0 =', mp.nstr(C0, 6))
    for A in [1, 10, 100]:
        for s in [0.2, 0.3, 0.5, 1.0, 2.0, 3.0, 8.0]:
            # coarse scan over x = log d in [8, 1500] step 0.05; record last failure of each condition
            last_fail = {}
            x = mpf(8)
            while x <= 1500:
                if x < 690:   # d itself representable comfortably
                    cc = conds(x, A, s)
                else:
                    Jd, rd, prod, a, b = L9_parts(x, A, s)
                    cc = {'L9b': prod <= thr}
                for k, v in cc.items():
                    if not v: last_fail[k] = x
                x += mpf('0.05')
            items = sorted(last_fail.items(), key=lambda kv: kv[1])
            s_items = ', '.join(f"{k}:{float(v):.2f}" for k, v in items)
            xb = last_fail.get('L9b', None)
            print(f"A={A:3d} sigma1={s}: last failing log d per condition -> {s_items}"
                  + (f"  => (L9) product needs log d > {float(xb):.2f}, i.e. log10 d > {float(xb/log(10)):.2f}" if xb else ''))
    # a few values of Jd*rd at sigma1=1, A=1
    for x10 in [9, 20, 50, 58, 59, 100]:
        x = mpf(x10)*log(10)
        Jd, rd, prod, a, b = L9_parts(x, 1, 1.0)
        print(f"sigma1=1, A=1, d=1e{x10}: Jd={float(Jd):.2f}, Jd/log d={float(Jd/x):.3f}, rd={float(rd):.3e}, Jd*rd={float(prod):.4e}")

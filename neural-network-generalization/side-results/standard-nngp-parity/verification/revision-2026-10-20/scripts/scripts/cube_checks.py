# Composite coefficients, two-step regularity for composites, cube transfer, tau-ratio, intrinsic-dimension bound.
import numpy as np
from tanh_coef_fast import coefs, v_of
Mmax = 2401
def first_layer(s):
    ms, logc, v = coefs(s, Mmax)
    c = np.zeros(Mmax+1); c[ms] = np.exp(logc)
    return c, v
def compose(outer, inner, M):
    # coefficients of outer(inner(t)) truncated at degree M; inner has zero constant term
    res = np.zeros(M+1)
    powk = np.zeros(M+1); powk[0] = 1.0
    for k in range(1, M+1):
        powk = np.convolve(powk, inner[:M+1])[:M+1]
        if outer[k] != 0: res += outer[k]*powk
        if powk.max() < 1e-300: break
    return res
def walk_levels(c, D, M):
    # W_j = sum_m c_m P(X_m = j), Ehrenfest walk on D-cube from 0
    p = np.zeros(D+1); p[0] = 1.0
    W = np.zeros(D+1)
    j = np.arange(D+1)
    up = (D - j)/D; dn = j/D
    for m in range(1, M+1):
        q = np.zeros(D+1)
        q[1:] += p[:-1]*up[:-1]
        q[:-1] += p[1:]*dn[1:]
        p = q
        if c[m] != 0: W += c[m]*p
    return W
cases = {}
c1s, v1 = first_layer(1.0); cases['L2 s1=1'] = (c1s, 1.0)
c05, v05 = first_layer(0.5); cases['L2 s1=0.5'] = (c05, 0.5)
# L=3 unit gains: q2 = 1^2 * v1
c_q2, _ = first_layer(np.sqrt(1.0*v1))
cases['L3 unit'] = (compose(c_q2, c1s, Mmax), 1.0)
# L=3 sigma2=3
c_q2b, _ = first_layer(np.sqrt(9.0*v1))
cases['L3 (1,3)'] = (compose(c_q2b, c1s, Mmax), 1.0)
for name, (c, s1) in cases.items():
    gam = 1/(6*(1+np.pi/(2*s1))**4)
    odd = np.arange(1, Mmax-1, 2)
    good = c[odd] > 1e-280
    rat = c[odd+2][good]/c[odd][good]
    print(f"[{name}] sum c = {c.sum():.12f}, c1 = {c[1]:.5f}, min c(m+2)/c(m) over m<={odd[good][-1]} = {rat.min():.5f} (gamma={gam:.3e}), viol={np.sum(rat < gam)}")
    for D in [41, 101, 201, 301]:
        W = walk_levels(c, D, Mmax)
        jj = np.arange(1, D-1, 2)
        lhs = W[jj+2]; rhs = gam*(D-jj)*(D-jj-1)/D**2*W[jj]
        v1c = np.sum(lhs < rhs*(1-1e-12))
        # tau (A=1): tau_r = sum_{odd j>=r+2} W_j
        T = {r: W[r+2::2].sum() for r in range(1, D-1, 2)}
        worst = 0; v2c = 0
        for r in range(1, D-1, 2):
            if r + 3 <= D/2 and r+2 in T:
                ratio = T[r]/T[r+2]
                worst = max(worst, ratio)
                if ratio > 1 + 4/gam: v2c += 1
        # intrinsic dim bound
        v3c = 0; worst3 = -1e9
        for r in range(1, D-1, 2):
            lam = W[r+2]/__import__('math').comb(D, r+2)
            ld = np.log(T[r]/lam)
            bnd = (r+2)*np.log(np.e*D/(r+2)) + (r+1)/2*np.log(1/gam) + np.log(1/c[1])
            worst3 = max(worst3, ld - bnd)
            if ld > bnd + 1e-9: v3c += 1
        th = [W[r+2]/T[r] for r in range(1, D//4, 2)]
        print(f"   D={D}: sumW={W.sum():.10f} cube-transfer viol={v1c}; max tau_r/tau_(r+2) (r+3<=D/2)={worst:.3f} vs 1+4/gamma={1+4/gam:.1f} viol={v2c}; "
              f"intdim-bound viol={v3c} (max excess {worst3:.2f}); theta_r range (r<D/4) [{min(th):.3f},{max(th):.3f}]")

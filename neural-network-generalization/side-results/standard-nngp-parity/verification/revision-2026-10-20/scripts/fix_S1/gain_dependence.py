# Gain dependence of (i) the worst ratio tau_r/tau_{r+2} (odd r, r+3 <= D/2) against 1+4/gamma,
# and (ii) the slack of the two upper bounds in Lemma 4.4:
#   UB1 = D^{r+2}/((r+2)! c_{r+2})                      (the displayed bound)
#   UB2 = exp(Lambda'_r),  Lambda'_r = (r+2) log(eD/(r+2)) + (r+1)/2 log(1/gamma) + log(1/c_1)  (form used in the proof)
# Exact Ehrenfest level masses W_j; tau_r/lambda_{r+1} = binom(D,r+2) T_r / W_{r+2}.
import sys, math
import numpy as np
sys.path.insert(0, '/tmp/claude-0/-home-user-AI-works/5853d160-1439-5d10-be76-59b58f86c983/scratchpad/expd/verify/scripts')
from tanh_coef_fast import coefs
from scipy.special import gammaln

Mmax = 2401
def first_layer(s):
    ms, logc, v = coefs(s, Mmax)
    c = np.zeros(Mmax + 1); c[ms] = np.exp(logc)
    return c, v
def compose(outer, inner, M):
    res = np.zeros(M + 1); powk = np.zeros(M + 1); powk[0] = 1.0
    for k in range(1, M + 1):
        powk = np.convolve(powk, inner[:M + 1])[:M + 1]
        if outer[k] != 0: res += outer[k]*powk
        if powk.max() < 1e-300: break
    return res
def walk_levels(c, D, M):
    p = np.zeros(D + 1); p[0] = 1.0; W = np.zeros(D + 1)
    j = np.arange(D + 1); up = (D - j)/D; dn = j/D
    for m in range(1, M + 1):
        q = np.zeros(D + 1); q[1:] += p[:-1]*up[:-1]; q[:-1] += p[1:]*dn[1:]; p = q
        if c[m] != 0: W += c[m]*p
    return W
def lbinom(n, k): return gammaln(n + 1) - gammaln(k + 1) - gammaln(n - k + 1)

configs = []
for s in [0.2, 0.5, 1.0, 3.0, 8.0]:
    c, v = first_layer(s); configs.append((f"L=2, sigma1={s}", c, s))
c1l, v1 = first_layer(1.0)
c2l, _ = first_layer(math.sqrt(1.0*v1)); configs.append(("L=3, gains (1,1)", compose(c2l, c1l, Mmax), 1.0))
c2l, _ = first_layer(math.sqrt(9.0*v1)); configs.append(("L=3, gains (1,3)", compose(c2l, c1l, Mmax), 1.0))
c03, v03 = first_layer(0.3)
c2l, _ = first_layer(math.sqrt(9.0*v03)); configs.append(("L=3, gains (0.3,3)", compose(c2l, c03, Mmax), 0.3))

for name, c, s1 in configs:
    gam = 1/(6*(1 + np.pi/(2*s1))**4)
    odd = np.arange(1, Mmax - 1, 2); good = c[odd + 2] > 1e-290
    r32a = (c[odd + 2][good]/c[odd][good]).min()/gam
    r32b = min(c[m]/(gam**((m - 1)/2)*c[1]) for m in range(1, Mmax + 1, 2) if c[m] > 1e-290)
    line = [f"[{name}] sum c={c.sum():.10f} c1={c[1]:.5f} 1+4/gamma={1 + 4/gam:.4g}; (3.2): min c_(m+2)/(gamma c_m)={r32a:.3f}, min c_m/(gamma^((m-1)/2) c_1)={r32b:.3f}"]
    for D in [41, 101, 201, 301]:
        W = walk_levels(c, D, Mmax)
        T = {r: W[r + 2::2].sum() for r in range(1, D - 1, 2)}
        worst = max(T[r]/T[r + 2] for r in range(1, D - 1, 2) if r + 3 <= D/2)
        jj = np.arange(1, D - 1, 2)
        amin = (W[jj + 2]/(gam*(D - jj)*(D - jj - 1)/D**2*W[jj])).min()
        s1min = 1e9; s2min = 1e9; lbmin = 1e9
        for r in range(1, D - 1, 2):
            if c[r + 2] <= 0 or W[r + 2] <= 0: continue
            lintdim = lbinom(D, r + 2) + np.log(T[r]) - np.log(W[r + 2])
            ub1 = (r + 2)*np.log(D) - gammaln(r + 3) - np.log(c[r + 2])
            ub2 = (r + 2)*np.log(np.e*D/(r + 2)) + (r + 1)/2*np.log(1/gam) + np.log(1/c[1])
            s1min = min(s1min, ub1 - lintdim); s2min = min(s2min, ub2 - lintdim)
            lbmin = min(lbmin, lintdim - lbinom(D, r + 2))
        line.append(f"  D={D}: min ratio in 3.3(a)={amin:.3f}; worst tau_r/tau_(r+2)={worst:.3f} (3.3(b) needs <= {1 + 4/gam:.4g}); min log(UB1/intdim)={s1min:.2f}; "
                    f"min (Lambda'_r - log intdim)={s2min:.2f}; min log(intdim/binom)={lbmin:.3f}")
    print("\n".join(line)); sys.stdout.flush()

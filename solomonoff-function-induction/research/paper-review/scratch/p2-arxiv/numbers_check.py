"""Independent spot check of numbers that appear in more than one place in Paper 2 (abstract, intro, body,
appendix): L_S at Hänni's sizes and at m=24, the three-hypothesis window and its ratio, the lambda=1 switch,
the window ratios quoted in Rem. teacher:numbers and Sec. limits, Version 1's lambda window, the full-table
c_hi at d=20, and the guard-erosion factor. Pure arithmetic from the numbers printed in the paper."""
from math import lgamma, log, log2
def log2binom(n, k):
    return (lgamma(n + 1) - lgamma(k + 1) - lgamma(n - k + 1)) / log(2)
def H(p):
    return -p * log2(p) - (1 - p) * log2(1 - p)
p = 2 ** -10
print('L_S (m=20, s0=1024)      =', round(log2binom(2 ** 20, 1024), 3), ' paper: 11,710.27')
print('L_S (m=24, s0=16384)     =', round(log2binom(2 ** 24, 2 ** 14), 1), ' paper: 187,457')
print('L_S (m=10, p=2^-6, s0=16)=', round(log2binom(2 ** 10, 16), 2), ' paper: 115.6 / 115.58')
print('H(2^-10) =', round(H(p), 5), ' paper 0.0112;  p log(1/p) =', round(p * 10, 5), ' paper 0.0098')
hi = (1 - H(p)) / 110; lo = H(p) / 9990
print('three-hypothesis window (%.4g, %.4g), ratio %.0f' % (lo, hi, hi / lo), ' paper (1.12e-6, 8.99e-3), ratio ~8000 / 8037')
# lambda=1 switch: memoriser beats good model when n*H(p) > 10100 - 110
print('lambda=1 switch n =', round((10100 - 110) / H(p)), ' paper 8.94e5 / 894,054')
print('window ratio kappa=0 :', round(8.06e-3 / 2 ** -20), ' paper 8453;  kappa=30:', round(3.66e-3 / 2 ** -20), ' paper 3837')
print('2^-20 =', 2 ** -20, ' paper lower end 9.54e-7')
print('Version 1: lambda window at n=1e4: (%.2f, %.1f]' % (1e4 * 2 ** -10, 1e4 * 5.80e-3), ' paper (9.77, 58.0]')
pv = 2 ** -6
print('Version 1 rates: model %.0f bits for 100 (%.1f per bit); rule %.0f bits for %.0f (%.1f per bit)' % (
    1e4 * (1 - H(pv)), 1e4 * (1 - H(pv)) / 100, 1e4 * H(pv), log2binom(2 ** 10, 16), 1e4 * H(pv) / log2binom(2 ** 10, 16)))
print('full-table c_hi at d=20 from lambda=11945: %.5f' % (11945 / 2 ** 20), ' paper 0.01139')
print('guard factor rho_sigma/rho_G = %.1f' % (1.2226e-2 / 1.8103e-4), ' paper "a factor of 67"')
print('envelope share j=13 kappa=0: %.3f' % (log(1.64e-5 * 2 ** 20) / log(8.06e-3 * 2 ** 20)), ' paper 31%')
print('envelope share j=11 kappa=0: %.3f' % (log(6.98e-5 * 2 ** 20) / log(8.06e-3 * 2 ** 20)), ' paper 47%')
print('envelope share j=13 kappa=30: %.3f' % (log(0.746e-5 * 2 ** 20) / log(3.66e-3 * 2 ** 20)), ' paper 25%')
print('noisy parity threshold (2234.0-2218.0)/(24.2-12) = %.3f' % ((2234.0 - 2218.0) / (24.2 - 12)), ' paper 1.311')
print('concentration exponent -n*eps+(J+eps)/c = %.1f' % (-1e6 * 1e-3 + (0.0232 + 1e-3) / 1e-4), ' paper -758 (-1000+242.3)')
print('error inputs at d=100: %.4g; exceptions 11853 -> fraction %.3g' % (2 ** 100 * p, 11853 / (2 ** 100 * p)), ' paper 1.238e27, 9.57e-24')
print('p crossover G_1=H(p) at B=inf: solve 1-log2(1.5+2p)=H(p)')
a, b = 0.01, 0.2
for _ in range(100):
    mid = (a + b) / 2
    if 1 - log2(1.5 + 2 * mid) > H(mid): a = mid
    else: b = mid
print('   p* = %.5f' % a, ' paper 0.0560 / 0.05596')

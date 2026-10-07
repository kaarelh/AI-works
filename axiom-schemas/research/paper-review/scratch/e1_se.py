import math
def stats(ps, cap=41):
    # T = first N at which exact; P(T>N)=sum p^N for N>=1; T capped at 41 (never exact by 40 -> 41)
    surv = lambda N: 1.0 if N == 0 else sum(p**N for p in ps)
    pmf = {}
    for t in range(1, cap):
        pmf[t] = surv(t-1) - surv(t)
    pmf[cap] = surv(cap-1)
    m = sum(t*q for t, q in pmf.items())
    v = sum(t*t*q for t, q in pmf.items()) - m*m
    return m, math.sqrt(v)
for name, ps in [('numerals', [0.875, 0.125]), ('mixed', [0.65, 0.1, 0.05, 0.05, 0.15])]:
    m, s = stats(ps)
    se = s/math.sqrt(2000)
    print(name, 'mean %.4f sd %.3f se %.4f' % (m, s, se))
m, s = stats([0.875, 0.125]); print('z for 8.42:', (8.42-m)/(s/math.sqrt(2000)))
m, s = stats([0.65, 0.1, 0.05, 0.05, 0.15]); print('z for 3.27:', (3.27-m)/(s/math.sqrt(2000)))
# anchor probability for n numerals uniform 0..7
for n in (4, 6, 8):
    print(n, 1-(7/8)**n, 1-(7/8)**n-(1/8)**n)

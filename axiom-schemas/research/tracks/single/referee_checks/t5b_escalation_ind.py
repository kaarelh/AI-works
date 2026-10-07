# Referee: quadratic escalation chain inside PA induction (target Ind, honest prover): motives
# Ay1..Ayb (l_1=0 & ... & l_m=0) with l_j in {0, a, y_k}; each step witnessed by an explicit T_0.
from rc_core import *
from t5_escalation import conj, T0_of
for m in [2, 3, 4]:
    b = m
    def motive(lhs):
        f = conj([EQ(l, Z) for l in lhs])
        for _ in range(b): f = ALL(f)
        return f
    chain = [Ind(motive([Z] * m)), Ind(motive([('a',)] * m))]
    for j in range(m):
        for k in range(b):
            lhs = [Z] * m; lhs[j] = V(k)
            chain.append(Ind(motive(lhs)))
    ok = all(covers(T0_of(chain[:i]), chain[:i]) and is_DT0(T0_of(chain[:i])) and match(T0_of(chain[:i]), chain[i]) is None
             for i in range(2, len(chain))) and chain[1] != chain[0]
    print('Ind, m=b=%d: chain length %d = 2+m^2, first datum size %d, all escalations witnessed: %s' % (m, len(chain), size(chain[0]), ok))

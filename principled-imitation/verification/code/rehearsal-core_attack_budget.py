#!/usr/bin/env python3
"""
The budget test applied to the guarantees of Sections 3.1 to 3.3 of note.md
(Theorems R1, R3, V1 as proved in research/prove-c/rehearsal-core.md).
Plain arithmetic on the stated bounds; nothing is simulated.

  R1/R2 (deterministic human): the run is faithful with probability >= 1 - gamma
          once n >= L K ln2 / gamma.
  R3 (deterministic):  excess failure gamma' once n >= K ln2 / (theta gamma').
  R3 (any human):      excess failure gamma' once n >= K ln2 / (2 theta^2 gamma'^2)
          (Proposition 9.1(b)).
  V1(a):  a certificate "the run is faithful with probability >= 1 - gamma" at
          confidence 1 - delta needs m >= L ln(1/delta) / gamma answers without a
          disagreement; with R3, m >= ln(1/delta) / (theta gamma').
An answer is priced at one working hour, 2000 hours to the year.
"""
import math

def yrs(x):
    y = x/2000.0
    if y < 1: return f"{x:.3g} h"
    return f"{y:.3g} human-years"

def main():
    ln2 = math.log(2)
    print("== number of rehearsal questions (K in bits is log2(1/w(human))) ==")
    print(f"{'K':>8} {'L':>7} | {'R1/R2, gamma=0.1':>28} | {'R3 det, theta=0.1, gamma=0.1':>30} | {'R3 any, theta=0.1, gamma=0.1':>30}")
    for K in [1e2, 1e4, 1e6, 1e9]:
        for L in [10, 1000, 1e6]:
            n1 = L*K*ln2/0.1
            n2 = K*ln2/(0.1*0.1)
            n3 = K*ln2/(2*0.1**2*0.1**2)
            print(f"{K:8.0e} {L:7.0e} | {n1:10.3g} = {yrs(n1):>15} | {n2:10.3g} = {yrs(n2):>17} | {n3:10.3g} = {yrs(n3):>17}")
    print()
    print("== number of validation questions (no K) ==")
    for L in [10, 1000, 1e6]:
        m1 = L*math.log(1/0.05)/0.1
        m2 = math.log(1/0.05)/(0.1*0.1)
        print(f"L={L:7.0e}: certificate of a faithful run (gamma=0.1, delta=0.05): m = {m1:.3g} = {yrs(m1)};  with tolerance theta=0.1: m = {m2:.3g} = {yrs(m2)}")
    print()
    print("== many deployed runs (deterministic human) ==")
    print("Expected number of unfaithful calls in R deployed runs <= R L K ln2 / n.  With S = R L deployed calls:")
    print("  (questions n) x (expected unfaithful calls) <= S K ln2.")
    for K in [1e2, 1e4, 1e6]:
        for S in [1e6, 1e9, 1e12]:
            bal = math.sqrt(S*K*ln2)
            print(f"  K={K:.0e}, S={S:.0e} calls: n = sqrt(S K ln2) = {bal:.3g} questions gives at most {bal:.3g} unfaithful calls "
                  f"(fraction of calls put to the human: {bal/S:.2e});  n = S/100 gives at most {100*K*ln2:.3g} unfaithful calls")

if __name__ == '__main__':
    main()

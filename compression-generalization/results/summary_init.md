# Initialization study

## MNIST, 784-256-10, codes relative to the initialization vs relative to zero

Each row: one trained f and code family, best over its compression configurations (union-bound corrected for the disagreement term; design charge of accounting.py). T1 = Occam bound on g; T2 = bound on f with unlabeled test inputs.

| init | init scale | code ref | test err f | best T1 | bits (T1) | best T2 | bits (T2) |
|---|---|---|---|---|---|---|---|
| random | 0.3 | init | 0.0199 | 0.3840 | 34417 | 0.4066 | 34417 |
| random | 1.0 | init | 0.0197 | 0.3670 | 32260 | 0.3910 | 32260 |
| random | 1.0 | zero | 0.0197 | 0.3772 | 34091 | 0.3991 | 34091 |

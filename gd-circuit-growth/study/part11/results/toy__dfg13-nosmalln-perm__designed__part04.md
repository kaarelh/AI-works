## dfg13-nosmalln-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| dnf3 | 196 | 505 | -1.37 | 0.30 / 0.00 / 0.00 / 0.00 ; 0.30 / 0.17 / 0.02 / 0.00 | 1.6e-01 |
| dlist5 | 88 | 110 | -0.33 | 0.16 / 0.03 / 0.00 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 1.5e-01 |
| rmaj9 | 161 | 2027 | -3.66 | 0.25 / 0.00 / 0.00 / 0.00 ; 0.25 / 0.20 / 0.16 / 0.00 | 1.5e-01 |
| andxor | 63 | 376 | -2.58 | 0.09 / 0.00 / 0.00 / 0.00 ; 0.33 / 0.19 / 0.00 / 0.00 | 1.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 5 of 44 (dnf3@16: 0.38 vs 0.33; dnf3@128: 0.26 vs 0.24; dlist5@32: 0.30 vs 0.27; rmaj9@16: 0.43 vs 0.40; rmaj9@32: 0.36 vs 0.32). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -1.99 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 1.6e-01 of a GD run.


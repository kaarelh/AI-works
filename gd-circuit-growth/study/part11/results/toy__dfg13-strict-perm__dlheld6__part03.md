## dfg13-strict-perm on the dlheld6 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h6_08 | 586 | 3119 | -2.41 | 0.30 / 0.26 / 0.00 / 0.00 ; 0.36 / 0.29 / 0.26 / 0.03 | 1.6e-01 |
| h6_09 | 253 | 1450 | -2.52 | 0.38 / 0.10 / 0.01 / 0.00 ; 0.41 / 0.31 / 0.16 / 0.01 | 4.2e-01 |
| h6_10 | 215 | 1414 | -2.72 | 0.38 / 0.01 / 0.00 / 0.00 ; 0.39 / 0.34 / 0.18 / 0.00 | 1.4e-01 |
| h6_11 | 172 | 881 | -2.35 | 0.37 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.33 / 0.05 / 0.00 | 1.6e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 3 of 44 (h6_10@16: 0.38 vs 0.33; h6_11@16: 0.45 vs 0.37; h6_11@32: 0.40 vs 0.36). Of these, by more than 2 standard errors of the seed-to-seed spread: 1 (h6_11@16).

Mean log2 ratio over targets where both learn: -2.50 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 4.2e-01 of a GD run.


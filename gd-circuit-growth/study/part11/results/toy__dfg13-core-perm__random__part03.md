## dfg13-core-perm on the random suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| rf08 | 49 | 85 | -0.80 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.12 / 0.03 / 0.00 / 0.00 | 9.4e-03 |
| rf09 | 37 | 320 | -3.11 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.25 / 0.14 / 0.00 / 0.00 | 5.5e-03 |
| rf10 | 37 | 103 | -1.49 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.16 / 0.02 / 0.00 / 0.00 | 5.5e-03 |
| rf11 | 28 | 864 | -4.95 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.51 / 0.49 / 0.00 / 0.00 | 5.5e-03 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 2 of 44 (rf08@16: 0.38 vs 0.29; rf10@16: 0.37 vs 0.30). Of these, by more than 2 standard errors of the seed-to-seed spread: 2 (rf08@16, rf10@16).

Mean log2 ratio over targets where both learn: -2.59 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 9.4e-03 of a GD run.


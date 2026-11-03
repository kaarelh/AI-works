## dfg13-core-perm on the dlheld4 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym11 | 187 | 934 | -2.32 | 0.44 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.36 / 0.08 / 0.00 | 8.0e-03 |
| ex4of9 | 193 | 1073 | -2.48 | 0.24 / 0.00 / 0.00 / 0.00 ; 0.32 / 0.30 / 0.11 / 0.00 | 7.8e-03 |
| tail13 | 148 | 612 | -2.05 | 0.25 / 0.00 / 0.00 / 0.00 ; 0.31 / 0.21 / 0.06 / 0.00 | 8.8e-03 |
| band10 | 432 | 5920 | -3.78 | 0.41 / 0.41 / 0.00 / 0.00 ; 0.45 / 0.44 / 0.43 / 0.21 | 7.7e-03 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 44. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.65 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 8.8e-03 of a GD run.


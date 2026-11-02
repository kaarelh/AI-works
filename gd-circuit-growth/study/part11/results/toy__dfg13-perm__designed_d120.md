## dfg13-perm on the designed_d120 suite (d = 120)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| maj9 | 104 | 752 | -2.85 | 0.34 / 0.00 / 0.00 / 0.00 ; 0.34 / 0.17 / 0.08 / 0.00 | 1.8e-01 |
| mux | 102 | 6073 | -5.90 | 0.30 / 0.03 / 0.00 / 0.00 ; nan / 0.40 / 0.36 / 0.23 | 1.8e-01 |
| par2 | 28 | 842 | -4.92 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.46 / 0.00 / 0.00 | 1.8e-01 |
| par3 | 56 | 14029 | -7.98 | 0.00 / 0.00 / 0.00 / 0.00 ; nan / nan / 0.50 / 0.50 | 1.8e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 29. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -5.41 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 1.8e-01 of a GD run.


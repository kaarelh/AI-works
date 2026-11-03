## dfg13-noeig-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| thr10 | 128 | 563 | -2.14 | 0.18 / 0.06 / 0.01 / 0.00 ; 0.22 / 0.12 / 0.06 / 0.02 | 3.3e-01 |
| par2 | 16 | 200 | -3.64 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.45 / 0.00 / 0.00 / 0.00 | 1.4e-01 |
| par3 | 28 | 843 | -4.92 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.48 / 0.00 / 0.00 | 1.4e-01 |
| par4 | 48 | 2728 | -5.82 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.50 / 0.49 / 0.00 | 1.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 44. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -4.13 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 3.3e-01 of a GD run.


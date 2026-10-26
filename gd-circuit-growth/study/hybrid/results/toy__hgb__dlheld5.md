## hgb on the dlheld5 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h5s0 | never | never | +nan | 0.31 / 0.26 / 0.22 / 0.18 ; – | 3.0e-03 |
| h5s1 | never | never | +nan | 0.51 / 0.50 / 0.49 / 0.49 ; – | 1.5e-03 |
| h5s2 | 10860 | never | -inf | 0.43 / 0.41 / 0.39 / 0.29 ; – | 3.0e-03 |
| h5s3 | never | never | +nan | 0.48 / 0.49 / 0.47 / 0.45 ; – | 1.5e-03 |
| h5s4 | 1465 | never | -inf | 0.21 / 0.20 / 0.17 / 0.02 ; – | 3.0e-03 |
| h5s5 | never | never | +nan | 0.40 / 0.37 / 0.34 / 0.33 ; – | 2.5e-03 |
| h5s6 | never | never | +nan | 0.40 / 0.42 / 0.39 / 0.37 ; – | 3.0e-03 |
| h5s7 | never | never | +nan | 0.43 / 0.43 / 0.42 / 0.39 ; – | 1.6e-03 |
| h5t0 | 2886 | never | -inf | 0.31 / 0.26 / 0.17 / 0.08 ; – | 3.0e-03 |
| h5t1 | 993 | never | -inf | 0.34 / 0.27 / 0.09 / 0.00 ; – | 3.0e-03 |
| h5rf0 | 2658 | never | -inf | 0.46 / 0.12 / 0.11 / 0.07 ; – | 3.0e-03 |
| h5rf1 | 9281 | never | -inf | 0.25 / 0.25 / 0.20 / 0.11 ; – | 3.0e-03 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 6; clearly worse: 0; of 12. Largest compute used: 3.0e-03 of a GD run.


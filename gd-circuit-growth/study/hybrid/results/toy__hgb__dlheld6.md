## hgb on the dlheld6 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h6_00 | never | never | +nan | 0.43 / 0.42 / 0.41 / 0.37 ; – | 1.5e-03 |
| h6_01 | never | never | +nan | 0.43 / 0.43 / 0.38 / 0.29 ; – | 3.0e-03 |
| h6_02 | never | never | +nan | 0.50 / 0.49 / 0.39 / 0.30 ; – | 3.0e-03 |
| h6_03 | 103 | never | -inf | 0.29 / 0.00 / 0.00 / 0.00 ; – | 3.0e-03 |
| h6_04 | 59 | never | -inf | 0.06 / 0.01 / 0.00 / 0.00 ; – | 3.0e-03 |
| h6_05 | 59 | never | -inf | 0.04 / 0.01 / 0.00 / 0.00 ; – | 3.0e-03 |
| h6_06 | never | never | +nan | 0.50 / 0.50 / 0.46 / 0.35 ; – | 3.0e-03 |
| h6_07 | 4492 | never | -inf | 0.37 / 0.24 / 0.19 / 0.11 ; – | 3.0e-03 |
| h6_08 | 5940 | never | -inf | 0.29 / 0.27 / 0.21 / 0.10 ; – | 3.0e-03 |
| h6_09 | 2706 | never | -inf | 0.40 / 0.31 / 0.18 / 0.07 ; – | 3.0e-03 |
| h6_10 | never | never | +nan | 0.36 / 0.34 / 0.29 / 0.25 ; – | 3.0e-03 |
| h6_11 | 2264 | never | -inf | 0.33 / 0.32 / 0.24 / 0.01 ; – | 3.0e-03 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 7; clearly worse: 0; of 12. Largest compute used: 3.0e-03 of a GD run.


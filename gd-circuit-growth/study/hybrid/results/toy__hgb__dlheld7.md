## hgb on the dlheld7 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| f7_00 | 6208 | never | -inf | 0.49 / 0.43 / 0.29 / 0.16 ; – | 3.0e-03 |
| f7_01 | 684 | never | -inf | 0.19 / 0.14 / 0.09 / 0.04 ; – | 3.0e-03 |
| f7_02 | 120 | never | -inf | 0.23 / 0.01 / 0.00 / 0.00 ; – | 3.0e-03 |
| f7_03 | 2199 | never | -inf | 0.24 / 0.22 / 0.14 / 0.02 ; – | 3.0e-03 |
| f7_04 | 84 | never | -inf | 0.15 / 0.02 / 0.00 / 0.00 ; – | 3.0e-03 |
| f7_05 | never | never | +nan | 0.40 / 0.40 / 0.39 / 0.35 ; – | 1.5e-03 |
| f7_06 | 59 | never | -inf | 0.06 / 0.01 / 0.00 / 0.00 ; – | 3.0e-03 |
| f7_07 | 1373 | never | -inf | 0.28 / 0.17 / 0.11 / 0.07 ; – | 3.0e-03 |
| f7_08 | never | never | +nan | 0.46 / 0.45 / 0.42 / 0.42 ; – | 3.0e-03 |
| f7_09 | never | never | +nan | 0.49 / 0.46 / 0.37 / 0.27 ; – | 3.0e-03 |
| f7_10 | 114 | never | -inf | 0.13 / 0.04 / 0.00 / 0.00 ; – | 3.0e-03 |
| f7_11 | 63 | never | -inf | 0.09 / 0.08 / 0.03 / 0.02 ; – | 3.0e-03 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 9; clearly worse: 0; of 12. Largest compute used: 3.0e-03 of a GD run.


## p10_sum-perm on the dlheld7 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| f7_00 | 203 | never | -inf | 0.43 / 0.00 / 0.00 / 0.00 ; – | 2.5e-01 |
| f7_01 | 106 | never | -inf | 0.18 / 0.00 / 0.00 / 0.00 ; – | 2.1e-01 |
| f7_02 | 106 | never | -inf | 0.21 / 0.01 / 0.00 / 0.00 ; – | 3.3e-01 |
| f7_03 | 352 | never | -inf | 0.27 / 0.18 / 0.00 / 0.00 ; – | 2.7e-01 |
| f7_04 | 70 | never | -inf | 0.11 / 0.02 / 0.00 / 0.00 ; – | 5.3e-01 |
| f7_05 | never | never | +nan | 0.33 / 0.32 / 0.32 / 0.32 ; – | 2.0e-01 |
| f7_06 | 44 | never | -inf | 0.05 / 0.01 / 0.00 / 0.00 ; – | 2.3e-01 |
| f7_07 | 174 | never | -inf | 0.30 / 0.00 / 0.00 / 0.00 ; – | 5.2e-01 |
| f7_08 | 634 | never | -inf | 0.45 / 0.48 / 0.00 / 0.00 ; – | 2.1e-01 |
| f7_09 | 215 | never | -inf | 0.48 / 0.00 / 0.00 / 0.00 ; – | 2.0e-01 |
| f7_10 | 82 | never | -inf | 0.16 / 0.00 / 0.00 / 0.00 ; – | 2.0e-01 |
| f7_11 | 55 | never | -inf | 0.09 / 0.02 / 0.01 / 0.00 ; – | 3.0e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 11; clearly worse: 0; of 12. Largest compute used: 5.3e-01 of a GD run.


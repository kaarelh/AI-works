## dfg13-nobg-perm on the dlheld7 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| f7_00 | 201 | never | -inf | 0.46 / 0.00 / 0.00 / 0.00 ; – | 1.7e-01 |
| f7_01 | 177 | never | -inf | 0.20 / 0.00 / 0.00 / 0.00 ; – | 1.5e-01 |
| f7_02 | 188 | never | -inf | 0.28 / 0.00 / 0.00 / 0.00 ; – | 1.6e-01 |
| f7_03 | 364 | never | -inf | 0.19 / 0.20 / 0.00 / 0.00 ; – | 1.8e-01 |
| f7_04 | 99 | never | -inf | 0.24 / 0.02 / 0.01 / 0.00 ; – | 2.7e-01 |
| f7_05 | never | never | +nan | 0.32 / 0.32 / 0.32 / 0.32 ; – | 1.4e-01 |
| f7_06 | 81 | never | -inf | 0.14 / 0.00 / 0.00 / 0.00 ; – | 1.6e-01 |
| f7_07 | 183 | never | -inf | 0.51 / 0.01 / 0.00 / 0.00 ; – | 1.7e-01 |
| f7_08 | 437 | never | -inf | 0.40 / 0.40 / 0.01 / 0.00 ; – | 1.5e-01 |
| f7_09 | 222 | never | -inf | 0.49 / 0.00 / 0.00 / 0.00 ; – | 1.4e-01 |
| f7_10 | 90 | never | -inf | 0.20 / 0.00 / 0.00 / 0.00 ; – | 1.4e-01 |
| f7_11 | 16 | never | -inf | 0.08 / 0.02 / 0.01 / 0.00 ; – | 2.0e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 11; clearly worse: 0; of 12. Largest compute used: 2.7e-01 of a GD run.


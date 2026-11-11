## dfg13-lenient-perm on the dlheld7 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| f7_00 | 200 | never | -inf | 0.37 / 0.00 / 0.00 / 0.00 ; – | 1.8e-01 |
| f7_01 | 148 | never | -inf | 0.16 / 0.00 / 0.00 / 0.00 ; – | 1.6e-01 |
| f7_02 | 225 | never | -inf | 0.25 / 0.07 / 0.00 / 0.00 ; – | 1.6e-01 |
| f7_03 | 358 | never | -inf | 0.24 / 0.19 / 0.00 / 0.00 ; – | 2.0e-01 |
| f7_04 | 93 | never | -inf | 0.19 / 0.02 / 0.01 / 0.00 ; – | 3.2e-01 |
| f7_05 | never | never | +nan | 0.44 / 0.36 / 0.34 / 0.32 ; – | 1.6e-01 |
| f7_06 | 89 | never | -inf | 0.16 / 0.01 / 0.00 / 0.00 ; – | 1.7e-01 |
| f7_07 | 201 | never | -inf | 0.34 / 0.00 / 0.00 / 0.00 ; – | 3.6e-01 |
| f7_08 | 446 | never | -inf | 0.49 / 0.46 / 0.01 / 0.00 ; – | 1.6e-01 |
| f7_09 | 227 | never | -inf | 0.49 / 0.02 / 0.00 / 0.00 ; – | 1.4e-01 |
| f7_10 | 88 | never | -inf | 0.19 / 0.00 / 0.00 / 0.00 ; – | 1.4e-01 |
| f7_11 | 63 | never | -inf | 0.10 / 0.02 / 0.00 / 0.00 ; – | 3.2e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 11; clearly worse: 0; of 12. Largest compute used: 3.6e-01 of a GD run.


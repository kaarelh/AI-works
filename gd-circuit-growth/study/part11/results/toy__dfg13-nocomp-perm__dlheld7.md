## dfg13-nocomp-perm on the dlheld7 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| f7_00 | 211 | never | -inf | 0.37 / 0.00 / 0.00 / 0.00 ; – | 1.7e-01 |
| f7_01 | 156 | never | -inf | 0.16 / 0.00 / 0.00 / 0.00 ; – | 1.5e-01 |
| f7_02 | 258 | never | -inf | 0.24 / 0.10 / 0.00 / 0.00 ; – | 1.6e-01 |
| f7_03 | 353 | never | -inf | 0.25 / 0.18 / 0.00 / 0.00 ; – | 1.8e-01 |
| f7_04 | 99 | never | -inf | 0.23 / 0.02 / 0.01 / 0.00 ; – | 3.8e-01 |
| f7_05 | never | never | +nan | 0.44 / 0.36 / 0.34 / 0.32 ; – | 1.4e-01 |
| f7_06 | 81 | never | -inf | 0.14 / 0.01 / 0.00 / 0.00 ; – | 1.6e-01 |
| f7_07 | 165 | never | -inf | 0.32 / 0.00 / 0.00 / 0.00 ; – | 3.5e-01 |
| f7_08 | 446 | never | -inf | 0.47 / 0.46 / 0.01 / 0.00 ; – | 1.5e-01 |
| f7_09 | 237 | never | -inf | 0.50 / 0.05 / 0.00 / 0.00 ; – | 1.4e-01 |
| f7_10 | 88 | never | -inf | 0.19 / 0.00 / 0.00 / 0.00 ; – | 1.4e-01 |
| f7_11 | 63 | never | -inf | 0.10 / 0.02 / 0.01 / 0.00 ; – | 1.9e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 11; clearly worse: 0; of 12. Largest compute used: 3.8e-01 of a GD run.


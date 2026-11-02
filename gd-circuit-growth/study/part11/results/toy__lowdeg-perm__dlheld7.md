## lowdeg-perm on the dlheld7 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| f7_00 | 7061 | never | -inf | 0.38 / 0.23 / 0.17 / 0.17 ; – | 9.1e-02 |
| f7_01 | 595 | never | -inf | 0.29 / 0.22 / 0.03 / 0.01 ; – | 8.9e-02 |
| f7_02 | 435 | never | -inf | 0.28 / 0.17 / 0.04 / 0.00 ; – | 8.9e-02 |
| f7_03 | 4205 | never | -inf | 0.19 / 0.19 / 0.13 / 0.10 ; – | 9.0e-02 |
| f7_04 | 121 | never | -inf | 0.30 / 0.02 / 0.02 / 0.02 ; – | 8.9e-02 |
| f7_05 | never | never | +nan | 0.32 / 0.32 / 0.32 / 0.32 ; – | 8.9e-02 |
| f7_06 | 179 | never | -inf | 0.14 / 0.06 / 0.02 / 0.02 ; – | 8.9e-02 |
| f7_07 | 1123 | never | -inf | 0.20 / 0.20 / 0.11 / 0.06 ; – | 8.9e-02 |
| f7_08 | never | never | +nan | 0.40 / 0.47 / 0.40 / 0.42 ; – | 8.9e-02 |
| f7_09 | 591 | never | -inf | 0.48 / 0.31 / 0.01 / 0.00 ; – | 8.9e-02 |
| f7_10 | 336 | never | -inf | 0.19 / 0.13 / 0.04 / 0.00 ; – | 8.9e-02 |
| f7_11 | 29 | never | -inf | 0.08 / 0.08 / 0.04 / 0.02 ; – | 9.0e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 10; clearly worse: 0; of 12. Largest compute used: 9.1e-02 of a GD run.


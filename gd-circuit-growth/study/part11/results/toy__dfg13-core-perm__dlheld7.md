## dfg13-core-perm on the dlheld7 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| f7_00 | 211 | never | -inf | 0.50 / 0.00 / 0.00 / 0.00 ; – | 8.6e-03 |
| f7_01 | 195 | never | -inf | 0.29 / 0.00 / 0.00 / 0.00 ; – | 8.1e-03 |
| f7_02 | 186 | never | -inf | 0.28 / 0.02 / 0.00 / 0.00 ; – | 1.2e-02 |
| f7_03 | 344 | never | -inf | 0.19 / 0.17 / 0.00 / 0.00 ; – | 1.3e-02 |
| f7_04 | 99 | never | -inf | 0.21 / 0.03 / 0.01 / 0.00 ; – | 1.1e-01 |
| f7_05 | never | never | +nan | 0.32 / 0.32 / 0.32 / 0.32 ; – | 7.4e-03 |
| f7_06 | 82 | never | -inf | 0.14 / 0.02 / 0.01 / 0.00 ; – | 2.3e-02 |
| f7_07 | 121 | never | -inf | 0.35 / 0.01 / 0.00 / 0.00 ; – | 8.2e-02 |
| f7_08 | 454 | never | -inf | 0.40 / 0.50 / 0.01 / 0.00 ; – | 2.6e-02 |
| f7_09 | 355 | never | -inf | 0.49 / 0.19 / 0.00 / 0.00 ; – | 1.2e-02 |
| f7_10 | 104 | never | -inf | 0.19 / 0.00 / 0.00 / 0.00 ; – | 8.1e-03 |
| f7_11 | 30 | never | -inf | 0.08 / 0.01 / 0.00 / 0.00 ; – | 1.9e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 11; clearly worse: 0; of 12. Largest compute used: 1.1e-01 of a GD run.


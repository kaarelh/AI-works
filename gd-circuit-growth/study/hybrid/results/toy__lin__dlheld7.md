## lin on the dlheld7 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| f7_00 | never | never | +nan | 0.49 / 0.48 / 0.44 / 0.41 ; – | 7.3e-02 |
| f7_01 | 111 | never | -inf | 0.15 / 0.00 / 0.00 / 0.00 ; – | 7.3e-02 |
| f7_02 | never | never | +nan | 0.27 / 0.19 / 0.17 / 0.17 ; – | 7.3e-02 |
| f7_03 | never | never | +nan | 0.28 / 0.22 / 0.19 / 0.19 ; – | 7.3e-02 |
| f7_04 | never | never | +nan | 0.22 / 0.16 / 0.15 / 0.15 ; – | 7.3e-02 |
| f7_05 | never | never | +nan | 0.33 / 0.32 / 0.32 / 0.32 ; – | 7.3e-02 |
| f7_06 | 127 | never | -inf | 0.15 / 0.04 / 0.02 / 0.01 ; – | 7.3e-02 |
| f7_07 | never | never | +nan | 0.35 / 0.23 / 0.20 / 0.20 ; – | 7.3e-02 |
| f7_08 | never | never | +nan | 0.44 / 0.47 / 0.40 / 0.40 ; – | 7.3e-02 |
| f7_09 | never | never | +nan | 0.49 / 0.49 / 0.50 / 0.50 ; – | 7.3e-02 |
| f7_10 | 87 | never | -inf | 0.17 / 0.00 / 0.00 / 0.00 ; – | 7.3e-02 |
| f7_11 | 119 | never | -inf | 0.14 / 0.08 / 0.08 / 0.08 ; – | 7.3e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 12. Largest compute used: 7.3e-02 of a GD run.


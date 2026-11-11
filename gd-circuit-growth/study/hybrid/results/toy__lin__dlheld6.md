## lin on the dlheld6 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h6_00 | never | never | +nan | 0.34 / 0.34 / 0.34 / 0.34 ; – | 7.3e-02 |
| h6_01 | never | never | +nan | 0.39 / 0.40 / 0.31 / 0.25 ; – | 7.3e-02 |
| h6_02 | never | never | +nan | 0.51 / 0.50 / 0.50 / 0.50 ; – | 7.3e-02 |
| h6_03 | never | never | +nan | 0.32 / 0.23 / 0.21 / 0.20 ; – | 7.3e-02 |
| h6_04 | 96 | never | -inf | 0.14 / 0.03 / 0.00 / 0.00 ; – | 7.3e-02 |
| h6_05 | 48 | never | -inf | 0.08 / 0.03 / 0.01 / 0.00 ; – | 7.3e-02 |
| h6_06 | never | never | +nan | 0.50 / 0.50 / 0.50 / 0.50 ; – | 7.3e-02 |
| h6_07 | never | never | +nan | 0.39 / 0.29 / 0.26 / 0.26 ; – | 7.3e-02 |
| h6_08 | never | never | +nan | 0.36 / 0.27 / 0.25 / 0.24 ; – | 7.3e-02 |
| h6_09 | never | never | +nan | 0.40 / 0.33 / 0.24 / 0.20 ; – | 7.3e-02 |
| h6_10 | never | never | +nan | 0.30 / 0.30 / 0.30 / 0.30 ; – | 7.3e-02 |
| h6_11 | never | never | +nan | 0.28 / 0.31 / 0.28 / 0.28 ; – | 7.3e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 12. Largest compute used: 7.3e-02 of a GD run.


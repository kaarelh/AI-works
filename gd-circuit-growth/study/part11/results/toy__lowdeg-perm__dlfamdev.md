## lowdeg-perm on the dlfamdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| fd_00 | 239 | never | -inf | 0.22 / 0.09 / 0.09 / 0.00 ; – | 8.9e-02 |
| fd_01 | 189 | never | -inf | 0.34 / 0.01 / 0.03 / 0.00 ; – | 8.9e-02 |
| fd_02 | 31 | never | -inf | 0.07 / 0.07 / 0.07 / 0.06 ; – | 8.9e-02 |
| fd_03 | 205 | never | -inf | 0.36 / 0.05 / 0.03 / 0.00 ; – | 8.9e-02 |
| fd_04 | never | never | +nan | 0.50 / 0.31 / 0.31 / 0.31 ; – | 8.9e-02 |
| fd_05 | 2555 | never | -inf | 0.35 / 0.17 / 0.14 / 0.04 ; – | 9.2e-02 |
| fd_06 | 9543 | never | -inf | 0.40 / 0.38 / 0.24 / 0.13 ; – | 9.2e-02 |
| fd_07 | 344 | never | -inf | 0.33 / 0.15 / 0.02 / 0.01 ; – | 8.9e-02 |
| fd_08 | 89 | never | -inf | 0.18 / 0.02 / 0.02 / 0.02 ; – | 8.9e-02 |
| fd_09 | 3210 | never | -inf | 0.25 / 0.25 / 0.30 / 0.00 ; – | 8.9e-02 |
| fd_10 | never | never | +nan | 0.32 / 0.32 / 0.32 / 0.32 ; – | 8.9e-02 |
| fd_11 | 61 | never | -inf | 0.09 / 0.09 / 0.09 / 0.07 ; – | 8.9e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 10; clearly worse: 0; of 12. Largest compute used: 9.2e-02 of a GD run.


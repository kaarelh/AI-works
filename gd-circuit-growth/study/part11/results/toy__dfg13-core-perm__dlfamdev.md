## dfg13-core-perm on the dlfamdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| fd_00 | 139 | never | -inf | 0.14 / 0.05 / 0.01 / 0.00 ; – | 2.7e-02 |
| fd_01 | 86 | never | -inf | 0.17 / 0.00 / 0.00 / 0.00 ; – | 7.4e-03 |
| fd_02 | 31 | never | -inf | 0.08 / 0.00 / 0.00 / 0.00 ; – | 7.9e-03 |
| fd_03 | 116 | never | -inf | 0.32 / 0.03 / 0.00 / 0.00 ; – | 1.4e-02 |
| fd_04 | 111 | never | -inf | 0.50 / 0.00 / 0.00 / 0.00 ; – | 1.6e-02 |
| fd_05 | 167 | never | -inf | 0.36 / 0.00 / 0.00 / 0.00 ; – | 1.0e-02 |
| fd_06 | 223 | never | -inf | 0.40 / 0.02 / 0.00 / 0.00 ; – | 1.2e-01 |
| fd_07 | 105 | never | -inf | 0.25 / 0.03 / 0.00 / 0.00 ; – | 1.7e-02 |
| fd_08 | 53 | never | -inf | 0.03 / 0.02 / 0.00 / 0.00 ; – | 1.0e-01 |
| fd_09 | 99 | never | -inf | 0.25 / 0.01 / 0.00 / 0.00 ; – | 8.1e-03 |
| fd_10 | never | never | +nan | 0.32 / 0.32 / 0.32 / 0.32 ; – | 7.4e-03 |
| fd_11 | 61 | never | -inf | 0.09 / 0.00 / 0.00 / 0.00 ; – | 9.0e-03 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 11; clearly worse: 0; of 12. Largest compute used: 1.2e-01 of a GD run.


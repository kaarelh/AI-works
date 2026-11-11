## p10_sum-perm on the dlfamdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| fd_00 | 75 | never | -inf | 0.12 / 0.01 / 0.00 / 0.00 ; – | 2.3e-01 |
| fd_01 | 79 | never | -inf | 0.14 / 0.00 / 0.00 / 0.00 ; – | 2.2e-01 |
| fd_02 | 66 | never | -inf | 0.10 / 0.00 / 0.00 / 0.00 ; – | 2.1e-01 |
| fd_03 | 81 | never | -inf | 0.13 / 0.00 / 0.00 / 0.00 ; – | 2.1e-01 |
| fd_04 | 171 | never | -inf | 0.51 / 0.00 / 0.00 / 0.00 ; – | 2.3e-01 |
| fd_05 | 147 | never | -inf | 0.30 / 0.00 / 0.00 / 0.00 ; – | 2.6e-01 |
| fd_06 | 318 | never | -inf | 0.39 / 0.14 / 0.00 / 0.00 ; – | 6.9e-01 |
| fd_07 | 98 | never | -inf | 0.16 / 0.00 / 0.00 / 0.00 ; – | 3.2e-01 |
| fd_08 | 29 | never | -inf | 0.02 / 0.02 / 0.01 / 0.00 ; – | 7.3e-01 |
| fd_09 | 101 | never | -inf | 0.27 / 0.00 / 0.00 / 0.00 ; – | 2.0e-01 |
| fd_10 | never | never | +nan | 0.33 / 0.32 / 0.32 / 0.32 ; – | 1.1e-01 |
| fd_11 | 123 | never | -inf | 0.20 / 0.00 / 0.00 / 0.00 ; – | 5.8e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 11; clearly worse: 0; of 12. Largest compute used: 7.3e-01 of a GD run.


## dfg13-strict-perm on the dlfamdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| fd_00 | 126 | never | -inf | 0.27 / 0.02 / 0.01 / 0.00 ; – | 1.6e-01 |
| fd_01 | 61 | never | -inf | 0.09 / 0.00 / 0.00 / 0.00 ; – | 1.5e-01 |
| fd_02 | 61 | never | -inf | 0.09 / 0.00 / 0.00 / 0.00 ; – | 1.5e-01 |
| fd_03 | 107 | never | -inf | 0.30 / 0.03 / 0.00 / 0.00 ; – | 1.5e-01 |
| fd_04 | 111 | never | -inf | 0.50 / 0.00 / 0.00 / 0.00 ; – | 1.6e-01 |
| fd_05 | 126 | never | -inf | 0.28 / 0.00 / 0.00 / 0.00 ; – | 1.7e-01 |
| fd_06 | 306 | never | -inf | 0.35 / 0.13 / 0.00 / 0.00 ; – | 4.3e-01 |
| fd_07 | 131 | never | -inf | 0.25 / 0.01 / 0.00 / 0.00 ; – | 1.6e-01 |
| fd_08 | 69 | never | -inf | 0.11 / 0.02 / 0.00 / 0.00 ; – | 4.7e-01 |
| fd_09 | 103 | never | -inf | 0.31 / 0.01 / 0.00 / 0.00 ; – | 1.4e-01 |
| fd_10 | never | never | +nan | 0.43 / 0.37 / 0.33 / 0.32 ; – | 1.4e-01 |
| fd_11 | 150 | never | -inf | 0.19 / 0.00 / 0.00 / 0.00 ; – | 3.0e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 11; clearly worse: 0; of 12. Largest compute used: 4.7e-01 of a GD run.


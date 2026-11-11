## dfg13-nosums-perm on the dlfamdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| fd_00 | 114 | never | -inf | 0.23 / 0.06 / 0.00 / 0.00 ; – | 1.4e-01 |
| fd_01 | 89 | never | -inf | 0.13 / 0.01 / 0.00 / 0.00 ; – | 1.5e-01 |
| fd_02 | 83 | never | -inf | 0.12 / 0.07 / 0.00 / 0.00 ; – | 1.4e-01 |
| fd_03 | 129 | never | -inf | 0.31 / 0.04 / 0.00 / 0.00 ; – | 1.4e-01 |
| fd_04 | 825 | never | -inf | 0.50 / 0.35 / 0.00 / 0.00 ; – | 1.6e-01 |
| fd_05 | 359 | never | -inf | 0.30 / 0.14 / 0.05 / 0.00 ; – | 3.7e-01 |
| fd_06 | 2025 | never | -inf | 0.35 / 0.29 / 0.17 / 0.05 ; – | 4.1e-01 |
| fd_07 | 181 | never | -inf | 0.24 / 0.02 / 0.00 / 0.00 ; – | 1.5e-01 |
| fd_08 | 51 | never | -inf | 0.03 / 0.02 / 0.01 / 0.00 ; – | 3.5e-01 |
| fd_09 | 388 | never | -inf | 0.33 / 0.25 / 0.00 / 0.00 ; – | 1.4e-01 |
| fd_10 | never | never | +nan | 0.43 / 0.37 / 0.33 / 0.32 ; – | 1.4e-01 |
| fd_11 | 110 | never | -inf | 0.16 / 0.07 / 0.00 / 0.00 ; – | 2.0e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 11; clearly worse: 0; of 12. Largest compute used: 4.1e-01 of a GD run.


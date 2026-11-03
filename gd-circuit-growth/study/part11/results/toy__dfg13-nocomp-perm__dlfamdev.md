## dfg13-nocomp-perm on the dlfamdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| fd_00 | 145 | never | -inf | 0.23 / 0.02 / 0.01 / 0.00 ; – | 1.6e-01 |
| fd_01 | 81 | never | -inf | 0.15 / 0.00 / 0.00 / 0.00 ; – | 1.5e-01 |
| fd_02 | 58 | never | -inf | 0.09 / 0.00 / 0.00 / 0.00 ; – | 1.5e-01 |
| fd_03 | 119 | never | -inf | 0.31 / 0.03 / 0.00 / 0.00 ; – | 1.5e-01 |
| fd_04 | 111 | never | -inf | 0.50 / 0.00 / 0.00 / 0.00 ; – | 1.7e-01 |
| fd_05 | 155 | never | -inf | 0.30 / 0.00 / 0.00 / 0.00 ; – | 1.7e-01 |
| fd_06 | 302 | never | -inf | 0.35 / 0.13 / 0.00 / 0.00 ; – | 4.3e-01 |
| fd_07 | 123 | never | -inf | 0.24 / 0.02 / 0.00 / 0.00 ; – | 1.7e-01 |
| fd_08 | 51 | never | -inf | 0.03 / 0.02 / 0.00 / 0.00 ; – | 4.2e-01 |
| fd_09 | 105 | never | -inf | 0.33 / 0.01 / 0.00 / 0.00 ; – | 1.4e-01 |
| fd_10 | never | never | +nan | 0.43 / 0.37 / 0.33 / 0.32 ; – | 1.4e-01 |
| fd_11 | 109 | never | -inf | 0.16 / 0.00 / 0.00 / 0.00 ; – | 2.8e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 11; clearly worse: 0; of 12. Largest compute used: 4.3e-01 of a GD run.


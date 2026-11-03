## dfg13-lsread-perm on the dlheld7 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| f7_00 | 221 | never | -inf | 0.47 / 0.00 / 0.00 / 0.00 ; – | 1.4e-01 |
| f7_01 | 177 | never | -inf | 0.20 / 0.00 / 0.00 / 0.00 ; – | 1.4e-01 |
| f7_02 | 188 | never | -inf | 0.24 / 0.00 / 0.00 / 0.00 ; – | 1.4e-01 |
| f7_03 | 349 | never | -inf | 0.24 / 0.18 / 0.00 / 0.00 ; – | 1.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 1.4e-01 of a GD run.


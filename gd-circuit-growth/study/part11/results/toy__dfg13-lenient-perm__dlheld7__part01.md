## dfg13-lenient-perm on the dlheld7 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| f7_00 | 200 | never | -inf | 0.37 / 0.00 / 0.00 / 0.00 ; – | 1.8e-01 |
| f7_01 | 148 | never | -inf | 0.16 / 0.00 / 0.00 / 0.00 ; – | 1.6e-01 |
| f7_02 | 225 | never | -inf | 0.25 / 0.07 / 0.00 / 0.00 ; – | 1.6e-01 |
| f7_03 | 358 | never | -inf | 0.24 / 0.19 / 0.00 / 0.00 ; – | 2.0e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 2.0e-01 of a GD run.


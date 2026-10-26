## hgb on the dlheld3 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| cnf3 | 164 | 489 | -1.57 | 0.27 / 0.00 / 0.00 / 0.00 ; 0.28 / 0.17 / 0.02 / 0.00 | 3.0e-03 |
| sym9 | 7845 | never | -inf | 0.49 / 0.44 / 0.34 / 0.18 ; – | 3.0e-03 |
| dlist8 | 61 | never | -inf | 0.07 / 0.01 / 0.00 / 0.00 ; – | 3.0e-03 |
| thrint | 243 | never | -inf | 0.15 / 0.10 / 0.05 / 0.00 ; – | 3.0e-03 |
| par3or | 2009 | never | -inf | 0.38 / 0.37 / 0.20 / 0.06 ; – | 3.0e-03 |
| poly4 | never | never | +nan | 0.51 / 0.44 / 0.32 / 0.26 ; – | 3.0e-03 |
| mixmaj | 368 | never | -inf | 0.34 / 0.14 / 0.05 / 0.01 ; – | 3.0e-03 |
| mux11 | 573 | never | -inf | 0.44 / 0.30 / 0.00 / 0.00 ; – | 3.0e-03 |
| h3rf0 | 60 | never | -inf | 0.07 / 0.07 / 0.07 / 0.04 ; – | 3.0e-03 |
| h3rf1 | 63 | never | -inf | 0.10 / 0.06 / 0.02 / 0.00 ; – | 3.0e-03 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 11 (cnf3@16: 0.45 vs 0.39). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -1.57 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 9; clearly worse: 0; of 10. Largest compute used: 3.0e-03 of a GD run.


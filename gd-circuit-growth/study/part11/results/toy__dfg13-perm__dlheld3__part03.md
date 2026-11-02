## dfg13-perm on the dlheld3 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| mixmaj | 114 | 507 | -2.16 | 0.23 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.22 / 0.02 / 0.00 | 1.4e-01 |
| mux11 | 509 | 1527 | -1.59 | 0.44 / 0.40 / 0.00 / 0.00 ; 0.43 / 0.34 / 0.19 / 0.00 | 1.5e-01 |
| h3rf0 | 108 | 109 | -0.01 | 0.12 / 0.06 / 0.00 / 0.00 ; 0.16 / 0.07 / 0.06 / 0.02 | 1.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 2 of 33 (mux11@128: 0.43 vs 0.40; mux11@256: 0.40 vs 0.34). Of these, by more than 2 standard errors of the seed-to-seed spread: 1 (mux11@256).

Mean log2 ratio over targets where both learn: -1.25 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 3. Largest compute used: 1.5e-01 of a GD run.


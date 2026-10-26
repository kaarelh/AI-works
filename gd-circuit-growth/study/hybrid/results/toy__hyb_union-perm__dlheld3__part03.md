## hyb_union-perm on the dlheld3 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| mixmaj | 198 | 507 | -1.35 | 0.22 / 0.08 / 0.00 / 0.00 ; 0.36 / 0.22 / 0.02 / 0.00 | 2.3e-01 |
| mux11 | 776 | 1527 | -0.98 | 0.47 / 0.32 / 0.01 / 0.00 ; 0.43 / 0.34 / 0.19 / 0.00 | 2.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 5 of 22 (mixmaj@16: 0.52 vs 0.44; mixmaj@32: 0.46 vs 0.41; mux11@32: 0.47 vs 0.44; mux11@64: 0.47 vs 0.43; mux11@128: 0.42 vs 0.40). Of these, by more than 2 standard errors of the seed-to-seed spread: 3 (mixmaj@16, mixmaj@32, mux11@64).

Mean log2 ratio over targets where both learn: -1.17 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 2. Largest compute used: 2.4e-01 of a GD run.


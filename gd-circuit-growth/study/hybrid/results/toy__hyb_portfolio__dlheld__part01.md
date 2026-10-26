## hyb_portfolio on the dlheld suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| majxor | 769 | 1313 | -0.77 | 0.47 / 0.43 / 0.02 / 0.00 ; 0.47 / 0.36 / 0.16 / 0.00 | 4.5e-01 |
| majmaj5 | 1156 | 2847 | -1.30 | 0.25 / 0.18 / 0.12 / 0.00 ; 0.29 / 0.22 / 0.20 / 0.03 | 7.6e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 3 of 22 (majxor@128: 0.48 vs 0.44; majxor@256: 0.43 vs 0.36; majmaj5@16: 0.46 vs 0.44). Of these, by more than 2 standard errors of the seed-to-seed spread: 2 (majxor@128, majxor@256).

Mean log2 ratio over targets where both learn: -1.04 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 2. Largest compute used: 7.6e-01 of a GD run.


## hyb_stage-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| rand1 | 96 | 463 | -2.27 | 0.24 / 0.00 / 0.00 / 0.00 ; 0.31 / 0.18 / 0.00 / 0.00 | 8.0e-02 |
| rand2 | 16 | 91 | -2.50 | 0.06 / 0.03 / 0.00 / 0.00 ; 0.13 / 0.06 / 0.03 / 0.00 | 8.3e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 22 (rand1@16: 0.42 vs 0.39). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.39 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 2. Largest compute used: 8.3e-02 of a GD run.


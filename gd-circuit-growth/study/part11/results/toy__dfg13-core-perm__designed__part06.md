## dfg13-core-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| rand3 | 136 | 1016 | -2.90 | 0.46 / 0.01 / 0.00 / 0.00 ; 0.44 / 0.32 / 0.10 / 0.00 | 1.2e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 2 of 11 (rand3@16: 0.51 vs 0.49; rand3@32: 0.51 vs 0.48). Of these, by more than 2 standard errors of the seed-to-seed spread: 1 (rand3@16).

Mean log2 ratio over targets where both learn: -2.90 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 1; clearly worse: 0; of 1. Largest compute used: 1.2e-02 of a GD run.


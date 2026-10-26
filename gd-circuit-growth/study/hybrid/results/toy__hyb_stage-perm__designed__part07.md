## hyb_stage-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| rmaj9 | 167 | 2027 | -3.60 | 0.23 / 0.00 / 0.00 / 0.00 ; 0.25 / 0.20 / 0.16 / 0.00 | 1.5e-01 |
| andxor | 53 | 376 | -2.83 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.33 / 0.19 / 0.00 / 0.00 | 7.5e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 2 of 22 (rmaj9@16: 0.43 vs 0.40; rmaj9@32: 0.34 vs 0.32). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -3.22 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 2. Largest compute used: 1.5e-01 of a GD run.


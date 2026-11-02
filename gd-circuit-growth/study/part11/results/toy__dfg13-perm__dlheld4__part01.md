## dfg13-perm on the dlheld4 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym11 | 167 | 934 | -2.48 | 0.49 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.36 / 0.08 / 0.00 | 1.6e-01 |
| ex4of9 | 205 | 1073 | -2.39 | 0.33 / 0.00 / 0.00 / 0.00 ; 0.32 / 0.30 / 0.11 / 0.00 | 1.5e-01 |
| tail13 | 134 | 612 | -2.19 | 0.33 / 0.00 / 0.00 / 0.00 ; 0.31 / 0.21 / 0.06 / 0.00 | 1.6e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 4 of 33 (ex4of9@16: 0.41 vs 0.31; ex4of9@32: 0.36 vs 0.30; tail13@16: 0.44 vs 0.36; tail13@32: 0.41 vs 0.36). Of these, by more than 2 standard errors of the seed-to-seed spread: 3 (ex4of9@16, ex4of9@32, tail13@16).

Mean log2 ratio over targets where both learn: -2.35 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 3; clearly worse: 0; of 3. Largest compute used: 1.6e-01 of a GD run.


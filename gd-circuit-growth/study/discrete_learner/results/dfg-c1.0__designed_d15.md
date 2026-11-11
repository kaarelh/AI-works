## dfg-c1.0 on the designed_d15 suite (d = 15)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| maj9 | 84 | 123 | -0.54 | 0.14 / 0.00 / 0.00 / 0.00 ; 0.14 / 0.03 / 0.00 / 0.00 | 8.1e-02 |
| majpar | 55 | 306 | -2.48 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.12 / 0.00 / 0.00 | 4.6e-02 |
| mux | 61 | 364 | -2.57 | 0.09 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.20 / 0.00 / 0.00 | 4.6e-02 |
| par2 | 16 | 100 | -2.65 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.28 / 0.00 / 0.00 / 0.00 | 4.6e-02 |
| par3 | 24 | 241 | -3.31 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.49 / 0.07 / 0.00 / 0.00 | 4.6e-02 |
| par4 | 16 | 508 | -4.99 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.44 / 0.00 / 0.00 | 4.6e-02 |
| stair5 | 109 | 433 | -1.99 | 0.43 / 0.00 / 0.00 / 0.00 ; 0.42 / 0.25 / 0.00 / 0.00 | 4.6e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 77 (maj9@16: 0.36 vs 0.27). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.65 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 7; clearly worse: 0; of 7. Largest compute used: 8.1e-02 of a GD run.


## dfg13-perm on the dlheld5 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h5s0 | 201 | 1454 | -2.86 | 0.28 / 0.01 / 0.00 / 0.00 ; 0.32 / 0.25 / 0.14 / 0.03 | 3.3e-01 |
| h5s1 | never | never | +nan | 0.50 / 0.50 / 0.51 / 0.50 ; 0.50 / 0.50 / 0.49 / 0.50 | 4.2e-01 |
| h5s2 | 598 | 3322 | -2.47 | 0.45 / 0.27 / 0.00 / 0.00 ; 0.45 / 0.43 / 0.41 / 0.03 | 1.9e-01 |
| h5s3 | 1642 | 8160 | -2.31 | 0.50 / 0.48 / 0.31 / 0.00 ; 0.49 / 0.49 / 0.49 / 0.39 | 4.4e-01 |
| h5s4 | 222 | 2744 | -3.63 | 0.24 / 0.07 / 0.00 / 0.00 ; 0.28 / 0.21 / 0.20 / 0.02 | 1.6e-01 |
| h5s5 | 420 | 13832 | -5.04 | 0.38 / 0.34 / 0.00 / 0.00 ; 0.40 / 0.38 / 0.37 / 0.37 | 5.2e-01 |
| h5s6 | 597 | 6227 | -3.38 | 0.44 / 0.28 / 0.00 / 0.00 ; 0.44 / 0.44 / 0.42 / 0.24 | 4.2e-01 |
| h5s7 | 6186 | 13863 | -1.16 | 0.43 / 0.40 / 0.38 / 0.25 ; 0.43 / 0.44 / 0.44 / 0.45 | 5.0e-01 |
| h5t0 | 109 | 770 | -2.82 | 0.35 / 0.00 / 0.00 / 0.00 ; 0.33 / 0.21 / 0.07 / 0.00 | 1.5e-01 |
| h5t1 | 100 | 683 | -2.77 | 0.23 / 0.00 / 0.00 / 0.00 ; 0.35 / 0.21 / 0.05 / 0.00 | 1.4e-01 |
| h5rf0 | 215 | 2673 | -3.64 | 0.14 / 0.09 / 0.00 / 0.00 ; 0.44 / 0.20 / 0.12 / 0.08 | 1.4e-01 |
| h5rf1 | 98 | 3352 | -5.10 | 0.26 / 0.00 / 0.00 / 0.00 ; 0.27 / 0.25 / 0.25 / 0.04 | 1.5e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 5 of 132 (h5s2@16: 0.47 vs 0.43; h5s7@16: 0.47 vs 0.43; h5s7@32: 0.45 vs 0.42; h5rf1@16: 0.33 vs 0.28; h5rf1@32: 0.30 vs 0.27). Of these, by more than 2 standard errors of the seed-to-seed spread: 3 (h5s7@32, h5rf1@16, h5rf1@32).

Mean log2 ratio over targets where both learn: -3.20 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 11; clearly worse: 0; of 12. Largest compute used: 5.2e-01 of a GD run.


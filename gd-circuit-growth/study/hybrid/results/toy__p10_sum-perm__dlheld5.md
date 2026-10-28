## p10_sum-perm on the dlheld5 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h5s0 | 205 | 1454 | -2.83 | 0.32 / 0.01 / 0.00 / 0.00 ; 0.32 / 0.25 / 0.14 / 0.03 | 5.7e-01 |
| h5s1 | never | never | +nan | 0.50 / 0.50 / 0.50 / 0.49 ; 0.50 / 0.50 / 0.49 / 0.50 | 7.1e-01 |
| h5s2 | 1154 | 3322 | -1.53 | 0.35 / 0.25 / 0.12 / 0.11 ; 0.45 / 0.43 / 0.41 / 0.03 | 2.6e-01 |
| h5s3 | 1757 | 8160 | -2.22 | 0.46 / 0.45 / 0.44 / 0.00 ; 0.49 / 0.49 / 0.49 / 0.39 | 7.6e-01 |
| h5s4 | 184 | 2744 | -3.90 | 0.22 / 0.00 / 0.00 / 0.00 ; 0.28 / 0.21 / 0.20 / 0.02 | 2.2e-01 |
| h5s5 | 421 | 13832 | -5.04 | 0.42 / 0.35 / 0.00 / 0.00 ; 0.40 / 0.38 / 0.37 / 0.37 | 8.2e-01 |
| h5s6 | 573 | 6227 | -3.44 | 0.37 / 0.37 / 0.00 / 0.00 ; 0.44 / 0.44 / 0.42 / 0.24 | 6.4e-01 |
| h5s7 | 6760 | 13863 | -1.04 | 0.38 / 0.38 / 0.37 / 0.36 ; 0.43 / 0.44 / 0.44 / 0.45 | 8.3e-01 |
| h5t0 | 105 | 770 | -2.87 | 0.28 / 0.00 / 0.00 / 0.00 ; 0.33 / 0.21 / 0.07 / 0.00 | 2.1e-01 |
| h5t1 | 95 | 683 | -2.85 | 0.19 / 0.00 / 0.00 / 0.00 ; 0.35 / 0.21 / 0.05 / 0.00 | 2.0e-01 |
| h5rf0 | 203 | 2673 | -3.72 | 0.13 / 0.09 / 0.00 / 0.00 ; 0.44 / 0.20 / 0.12 / 0.08 | 2.0e-01 |
| h5rf1 | 97 | 3352 | -5.11 | 0.25 / 0.00 / 0.00 / 0.00 ; 0.27 / 0.25 / 0.25 / 0.04 | 2.0e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 6 of 132 (h5s2@4096: 0.11 vs 0.03; h5s5@16: 0.50 vs 0.48; h5s5@32: 0.46 vs 0.43; h5s5@64: 0.42 vs 0.40; h5t0@16: 0.46 vs 0.42; h5t1@32: 0.45 vs 0.38). Of these, by more than 2 standard errors of the seed-to-seed spread: 1 (h5s5@32).

Mean log2 ratio over targets where both learn: -3.14 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 11; clearly worse: 0; of 12. Largest compute used: 8.3e-01 of a GD run.


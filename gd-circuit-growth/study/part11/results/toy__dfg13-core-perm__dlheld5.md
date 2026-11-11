## dfg13-core-perm on the dlheld5 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h5s0 | 216 | 1454 | -2.75 | 0.34 / 0.01 / 0.01 / 0.00 ; 0.32 / 0.25 / 0.14 / 0.03 | 1.1e-01 |
| h5s1 | never | never | +nan | 0.50 / 0.50 / 0.50 / 0.50 ; 0.50 / 0.50 / 0.49 / 0.50 | 8.4e-02 |
| h5s2 | 678 | 3322 | -2.29 | 0.34 / 0.34 / 0.00 / 0.00 ; 0.45 / 0.43 / 0.41 / 0.03 | 7.9e-03 |
| h5s3 | 1752 | 8160 | -2.22 | 0.44 / 0.44 / 0.44 / 0.00 ; 0.49 / 0.49 / 0.49 / 0.39 | 1.4e-01 |
| h5s4 | 178 | 2744 | -3.94 | 0.19 / 0.00 / 0.00 / 0.00 ; 0.28 / 0.21 / 0.20 / 0.02 | 7.7e-03 |
| h5s5 | 449 | 13832 | -4.95 | 0.49 / 0.50 / 0.00 / 0.00 ; 0.40 / 0.38 / 0.37 / 0.37 | 1.5e-01 |
| h5s6 | 354 | 6227 | -4.14 | 0.36 / 0.19 / 0.00 / 0.00 ; 0.44 / 0.44 / 0.42 / 0.24 | 4.0e-02 |
| h5s7 | 1698 | 13863 | -3.03 | 0.37 / 0.37 / 0.37 / 0.37 ; 0.43 / 0.44 / 0.44 / 0.45 | 6.9e-02 |
| h5t0 | 185 | 770 | -2.06 | 0.33 / 0.00 / 0.00 / 0.00 ; 0.33 / 0.21 / 0.07 / 0.00 | 8.8e-03 |
| h5t1 | 100 | 683 | -2.78 | 0.28 / 0.00 / 0.00 / 0.00 ; 0.35 / 0.21 / 0.05 / 0.00 | 1.0e-02 |
| h5rf0 | 164 | 2673 | -4.03 | 0.12 / 0.06 / 0.12 / 0.00 ; 0.44 / 0.20 / 0.12 / 0.08 | 2.7e-02 |
| h5rf1 | 149 | 3352 | -4.49 | 0.25 / 0.00 / 0.00 / 0.00 ; 0.27 / 0.25 / 0.25 / 0.04 | 1.6e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 14 of 132 (h5s0@16: 0.50 vs 0.39; h5s0@32: 0.41 vs 0.35; h5s0@128: 0.38 vs 0.29; h5s3@16: 0.53 vs 0.50; h5s5@32: 0.50 vs 0.43; h5s5@64: 0.49 vs 0.40; h5s5@128: 0.50 vs 0.37; h5s5@256: 0.50 vs 0.38; h5t0@16: 0.50 vs 0.42; h5t0@32: 0.50 vs 0.37; h5t1@16: 0.51 vs 0.42; h5t1@32: 0.51 vs 0.38; h5rf0@8192: 0.06 vs 0.00; h5rf0@16384: 0.06 vs 0.00). Of these, by more than 2 standard errors of the seed-to-seed spread: 8 (h5s5@32, h5s5@64, h5s5@128, h5s5@256, h5t0@16, h5t0@32, h5t1@16, h5t1@32).

Mean log2 ratio over targets where both learn: -3.33 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 11; clearly worse: 0; of 12. Largest compute used: 1.5e-01 of a GD run.


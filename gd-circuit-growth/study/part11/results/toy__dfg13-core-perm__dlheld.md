## dfg13-core-perm on the dlheld suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| maj15 | 206 | 355 | -0.78 | 0.45 / 0.00 / 0.00 / 0.00 ; 0.21 / 0.12 / 0.01 / 0.00 | 6.9e-03 |
| thr30 | 623 | 528 | +0.24 | 0.26 / 0.19 / 0.08 / 0.05 ; 0.21 / 0.14 / 0.07 / 0.02 | 9.6e-02 |
| majxor | 225 | 1313 | -2.54 | 0.48 / 0.01 / 0.00 / 0.00 ; 0.47 / 0.36 / 0.16 / 0.00 | 1.7e-02 |
| majmaj5 | 352 | 2847 | -3.02 | 0.46 / 0.17 / 0.02 / 0.00 ; 0.29 / 0.22 / 0.20 / 0.03 | 8.0e-02 |
| par5 | never | 7245 | +inf | 0.50 / 0.50 / 0.51 / 0.51 ; 0.49 / 0.50 / 0.50 / 0.50 | 1.5e-02 |
| mux6 | 210 | 481 | -1.20 | 0.44 / 0.00 / 0.00 / 0.00 ; 0.37 / 0.23 / 0.00 / 0.00 | 1.8e-02 |
| stair6 | 205 | 1967 | -3.27 | 0.34 / 0.01 / 0.00 / 0.00 ; 0.38 / 0.34 / 0.26 / 0.00 | 1.2e-02 |
| inter2 | 540 | 859 | -0.67 | 0.24 / 0.17 / 0.06 / 0.01 ; 0.20 / 0.14 / 0.10 / 0.02 | 1.4e-01 |
| majpar5 | 108 | 5229 | -5.60 | 0.40 / 0.00 / 0.00 / 0.00 ; 0.47 / 0.37 / 0.18 / 0.14 | 7.2e-03 |
| hrf0 | 46 | 192 | -2.07 | 0.09 / 0.00 / 0.00 / 0.00 ; 0.15 / 0.09 / 0.06 / 0.00 | 8.5e-03 |
| hrf1 | 123 | 1203 | -3.29 | 0.50 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.41 / 0.13 / 0.00 | 1.1e-02 |
| hrf2 | 56 | 107 | -0.94 | 0.06 / 0.00 / 0.00 / 0.00 ; 0.17 / 0.06 / 0.04 / 0.00 | 9.3e-03 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 29 of 132 (maj15@16: 0.50 vs 0.40; maj15@32: 0.50 vs 0.29; maj15@64: 0.45 vs 0.21; maj15@128: 0.32 vs 0.15; thr30@16: 0.51 vs 0.33; thr30@32: 0.50 vs 0.25; thr30@64: 0.26 vs 0.21; thr30@128: 0.26 vs 0.16; thr30@256: 0.19 vs 0.14; thr30@2048: 0.06 vs 0.03; thr30@4096: 0.05 vs 0.02; thr30@8192: 0.04 vs 0.01; thr30@16384: 0.04 vs 0.01; majxor@128: 0.48 vs 0.44; majmaj5@16: 0.50 vs 0.44; majmaj5@32: 0.45 vs 0.32; majmaj5@64: 0.46 vs 0.29; majmaj5@128: 0.51 vs 0.24; par5@8192: 0.50 vs 0.01; par5@16384: 0.17 vs 0.00; mux6@16: 0.50 vs 0.47; mux6@64: 0.44 vs 0.37; mux6@128: 0.35 vs 0.31; inter2@32: 0.30 vs 0.27; inter2@64: 0.24 vs 0.20; inter2@128: 0.19 vs 0.17; inter2@256: 0.17 vs 0.14; hrf0@16: 0.40 vs 0.35; hrf2@16: 0.50 vs 0.35). Of these, by more than 2 standard errors of the seed-to-seed spread: 23 (maj15@16, maj15@32, maj15@64, maj15@128, thr30@16, thr30@32, thr30@64, thr30@128, thr30@256, thr30@2048, thr30@4096, thr30@8192, thr30@16384, majxor@128, majmaj5@16, majmaj5@32, majmaj5@64, majmaj5@128, par5@8192, inter2@32, inter2@128, hrf0@16, hrf2@16).

Mean log2 ratio over targets where both learn: -2.10 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 10; clearly worse: 1; of 12. Largest compute used: 1.4e-01 of a GD run.


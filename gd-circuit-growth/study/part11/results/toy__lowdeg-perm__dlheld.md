## lowdeg-perm on the dlheld suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| maj15 | 622 | 355 | +0.81 | 0.46 / 0.26 / 0.04 / 0.00 ; 0.21 / 0.12 / 0.01 / 0.00 | 8.9e-02 |
| thr30 | 1820 | 528 | +1.79 | 0.26 / 0.22 / 0.13 / 0.08 ; 0.21 / 0.14 / 0.07 / 0.02 | 8.9e-02 |
| majxor | 1724 | 1313 | +0.39 | 0.49 / 0.51 / 0.24 / 0.04 ; 0.47 / 0.36 / 0.16 / 0.00 | 8.9e-02 |
| majmaj5 | 5997 | 2847 | +1.07 | 0.48 / 0.35 / 0.16 / 0.13 ; 0.29 / 0.22 / 0.20 / 0.03 | 8.9e-02 |
| par5 | never | 7245 | +inf | 0.50 / 0.50 / 0.50 / 0.50 ; 0.49 / 0.50 / 0.50 / 0.50 | 8.9e-02 |
| mux6 | 339 | 481 | -0.50 | 0.42 / 0.17 / 0.00 / 0.00 ; 0.37 / 0.23 / 0.00 / 0.00 | 8.9e-02 |
| stair6 | 1075 | 1967 | -0.87 | 0.34 / 0.18 / 0.11 / 0.00 ; 0.38 / 0.34 / 0.26 / 0.00 | 8.9e-02 |
| inter2 | 2204 | 859 | +1.36 | 0.32 / 0.21 / 0.11 / 0.07 ; 0.20 / 0.14 / 0.10 / 0.02 | 9.1e-02 |
| majpar5 | 198 | 5229 | -4.72 | 0.44 / 0.00 / 0.00 / 0.00 ; 0.47 / 0.37 / 0.18 / 0.14 | 8.9e-02 |
| hrf0 | 32 | 192 | -2.61 | 0.09 / 0.10 / 0.03 / 0.01 ; 0.15 / 0.09 / 0.06 / 0.00 | 8.9e-02 |
| hrf1 | 121 | 1203 | -3.32 | 0.51 / 0.06 / 0.04 / 0.00 ; 0.48 / 0.41 / 0.13 / 0.00 | 8.9e-02 |
| hrf2 | 26 | 107 | -2.04 | 0.06 / 0.06 / 0.06 / 0.00 ; 0.17 / 0.06 / 0.04 / 0.00 | 8.9e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 52 of 132 (maj15@16: 0.46 vs 0.40; maj15@32: 0.50 vs 0.29; maj15@64: 0.46 vs 0.21; maj15@128: 0.37 vs 0.15; maj15@256: 0.26 vs 0.12; maj15@512: 0.12 vs 0.08; maj15@1024: 0.04 vs 0.01; thr30@16: 0.51 vs 0.33; thr30@32: 0.42 vs 0.25; thr30@64: 0.26 vs 0.21; thr30@128: 0.26 vs 0.16; thr30@256: 0.22 vs 0.14; thr30@512: 0.17 vs 0.10; thr30@1024: 0.13 vs 0.07; thr30@2048: 0.09 vs 0.03; thr30@4096: 0.08 vs 0.02; thr30@8192: 0.07 vs 0.01; thr30@16384: 0.06 vs 0.01; majxor@64: 0.49 vs 0.47; majxor@128: 0.49 vs 0.44; majxor@256: 0.51 vs 0.36; majxor@512: 0.41 vs 0.25; majxor@1024: 0.24 vs 0.16; majxor@2048: 0.05 vs 0.00; majxor@4096: 0.04 vs 0.00; majxor@8192: 0.09 vs 0.00; majmaj5@16: 0.50 vs 0.44; majmaj5@32: 0.46 vs 0.32; majmaj5@64: 0.48 vs 0.29; majmaj5@128: 0.41 vs 0.24; majmaj5@256: 0.35 vs 0.22; majmaj5@4096: 0.13 vs 0.03; majmaj5@8192: 0.08 vs 0.00; majmaj5@16384: 0.07 vs 0.00; par5@8192: 0.50 vs 0.01; par5@16384: 0.50 vs 0.00; mux6@16: 0.50 vs 0.47; mux6@32: 0.50 vs 0.44; mux6@64: 0.42 vs 0.37; mux6@128: 0.38 vs 0.31; inter2@32: 0.30 vs 0.27; inter2@64: 0.32 vs 0.20; inter2@128: 0.25 vs 0.17; inter2@256: 0.21 vs 0.14; inter2@512: 0.16 vs 0.11; inter2@2048: 0.10 vs 0.07; inter2@4096: 0.07 vs 0.02; inter2@8192: 0.03 vs 0.01; hrf0@16: 0.47 vs 0.35; hrf0@2048: 0.03 vs 0.01; hrf1@64: 0.51 vs 0.48; hrf2@1024: 0.06 vs 0.04). Of these, by more than 2 standard errors of the seed-to-seed spread: 46 (maj15@32, maj15@64, maj15@128, maj15@256, maj15@512, maj15@1024, thr30@16, thr30@32, thr30@64, thr30@128, thr30@256, thr30@512, thr30@1024, thr30@2048, thr30@4096, thr30@8192, thr30@16384, majxor@128, majxor@256, majxor@512, majxor@1024, majxor@2048, majxor@4096, majxor@8192, majmaj5@16, majmaj5@32, majmaj5@64, majmaj5@128, majmaj5@256, majmaj5@4096, majmaj5@8192, majmaj5@16384, par5@8192, par5@16384, mux6@32, mux6@128, inter2@32, inter2@64, inter2@128, inter2@256, inter2@512, inter2@2048, inter2@4096, inter2@8192, hrf0@2048, hrf2@1024).

Mean log2 ratio over targets where both learn: -0.78 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 6; clearly worse: 6; of 12. Largest compute used: 9.1e-02 of a GD run.


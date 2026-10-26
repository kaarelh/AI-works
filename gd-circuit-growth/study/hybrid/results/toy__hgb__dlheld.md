## hgb on the dlheld suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| maj15 | 1278 | 355 | +1.85 | 0.25 / 0.16 / 0.11 / 0.05 ; 0.21 / 0.12 / 0.01 / 0.00 | 3.0e-03 |
| thr30 | 1645 | 528 | +1.64 | 0.18 / 0.16 / 0.11 / 0.08 ; 0.21 / 0.14 / 0.07 / 0.02 | 3.0e-03 |
| majxor | 4076 | 1313 | +1.63 | 0.49 / 0.43 / 0.28 / 0.10 ; 0.47 / 0.36 / 0.16 / 0.00 | 3.0e-03 |
| majmaj5 | 1638 | 2847 | -0.80 | 0.28 / 0.23 / 0.16 / 0.02 ; 0.29 / 0.22 / 0.20 / 0.03 | 3.0e-03 |
| par5 | never | 7245 | +inf | 0.50 / 0.49 / 0.50 / 0.49 ; 0.49 / 0.50 / 0.50 / 0.50 | 1.5e-03 |
| mux6 | 188 | 481 | -1.36 | 0.37 / 0.00 / 0.00 / 0.00 ; 0.37 / 0.23 / 0.00 / 0.00 | 3.0e-03 |
| stair6 | 695 | 1967 | -1.50 | 0.35 / 0.27 / 0.03 / 0.00 ; 0.38 / 0.34 / 0.26 / 0.00 | 3.0e-03 |
| inter2 | 416 | 859 | -1.04 | 0.18 / 0.12 / 0.06 / 0.01 ; 0.20 / 0.14 / 0.10 / 0.02 | 3.0e-03 |
| majpar5 | 4127 | 5229 | -0.34 | 0.51 / 0.31 / 0.17 / 0.10 ; 0.47 / 0.37 / 0.18 / 0.14 | 3.0e-03 |
| hrf0 | 63 | 192 | -1.60 | 0.09 / 0.08 / 0.01 / 0.00 ; 0.15 / 0.09 / 0.06 / 0.00 | 3.0e-03 |
| hrf1 | 461 | 1203 | -1.39 | 0.48 / 0.38 / 0.03 / 0.00 ; 0.48 / 0.41 / 0.13 / 0.00 | 3.0e-03 |
| hrf2 | 60 | 107 | -0.83 | 0.06 / 0.02 / 0.00 / 0.00 ; 0.17 / 0.06 / 0.04 / 0.00 | 3.0e-03 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 40 of 132 (maj15@16: 0.50 vs 0.40; maj15@32: 0.50 vs 0.29; maj15@64: 0.25 vs 0.21; maj15@128: 0.19 vs 0.15; maj15@256: 0.16 vs 0.12; maj15@512: 0.14 vs 0.08; maj15@1024: 0.11 vs 0.01; maj15@2048: 0.08 vs 0.00; maj15@4096: 0.05 vs 0.00; maj15@8192: 0.03 vs 0.00; thr30@16: 0.51 vs 0.33; thr30@32: 0.50 vs 0.25; thr30@1024: 0.11 vs 0.07; thr30@2048: 0.09 vs 0.03; thr30@4096: 0.08 vs 0.02; thr30@8192: 0.07 vs 0.01; thr30@16384: 0.06 vs 0.01; majxor@64: 0.49 vs 0.47; majxor@128: 0.49 vs 0.44; majxor@256: 0.43 vs 0.36; majxor@512: 0.36 vs 0.25; majxor@1024: 0.28 vs 0.16; majxor@2048: 0.18 vs 0.00; majxor@4096: 0.10 vs 0.00; majxor@8192: 0.03 vs 0.00; majmaj5@16: 0.50 vs 0.44; majmaj5@32: 0.50 vs 0.32; majmaj5@128: 0.26 vs 0.24; par5@8192: 0.47 vs 0.01; par5@16384: 0.45 vs 0.00; mux6@16: 0.50 vs 0.47; mux6@32: 0.50 vs 0.44; inter2@32: 0.30 vs 0.27; majpar5@64: 0.51 vs 0.47; majpar5@8192: 0.07 vs 0.03; majpar5@16384: 0.05 vs 0.00; hrf0@16: 0.47 vs 0.35; hrf0@32: 0.47 vs 0.26; hrf2@16: 0.51 vs 0.35; hrf2@32: 0.51 vs 0.27). Of these, by more than 2 standard errors of the seed-to-seed spread: 36 (maj15@16, maj15@32, maj15@64, maj15@128, maj15@256, maj15@512, maj15@1024, maj15@2048, maj15@4096, maj15@8192, thr30@16, thr30@32, thr30@1024, thr30@2048, thr30@4096, thr30@8192, thr30@16384, majxor@64, majxor@128, majxor@256, majxor@512, majxor@1024, majxor@2048, majxor@4096, majxor@8192, majmaj5@16, majmaj5@32, par5@8192, par5@16384, mux6@32, inter2@32, majpar5@64, majpar5@16384, hrf0@32, hrf2@16, hrf2@32).

Mean log2 ratio over targets where both learn: -0.34 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 8; clearly worse: 4; of 12. Largest compute used: 3.0e-03 of a GD run.


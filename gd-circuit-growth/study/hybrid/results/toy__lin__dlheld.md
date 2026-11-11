## lin on the dlheld suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| maj15 | 110 | 355 | -1.69 | 0.18 / 0.00 / 0.00 / 0.00 ; 0.21 / 0.12 / 0.01 / 0.00 | 7.3e-02 |
| thr30 | 148 | 528 | -1.83 | 0.17 / 0.04 / 0.01 / 0.00 ; 0.21 / 0.14 / 0.07 / 0.02 | 7.3e-02 |
| majxor | never | 1313 | +inf | 0.49 / 0.50 / 0.49 / 0.50 ; 0.47 / 0.36 / 0.16 / 0.00 | 7.3e-02 |
| majmaj5 | never | 2847 | +inf | 0.25 / 0.18 / 0.14 / 0.13 ; 0.29 / 0.22 / 0.20 / 0.03 | 7.3e-02 |
| par5 | never | 7245 | +inf | 0.50 / 0.50 / 0.51 / 0.50 ; 0.49 / 0.50 / 0.50 / 0.50 | 7.3e-02 |
| mux6 | never | 481 | +inf | 0.39 / 0.33 / 0.32 / 0.31 ; 0.37 / 0.23 / 0.00 / 0.00 | 7.3e-02 |
| stair6 | never | 1967 | +inf | 0.36 / 0.34 / 0.31 / 0.30 ; 0.38 / 0.34 / 0.26 / 0.00 | 7.3e-02 |
| inter2 | never | 859 | +inf | 0.18 / 0.13 / 0.11 / 0.11 ; 0.20 / 0.14 / 0.10 / 0.02 | 7.3e-02 |
| majpar5 | never | 5229 | +inf | 0.51 / 0.51 / 0.51 / 0.50 ; 0.47 / 0.37 / 0.18 / 0.14 | 7.3e-02 |
| hrf0 | 191 | 192 | -0.00 | 0.11 / 0.09 / 0.07 / 0.07 ; 0.15 / 0.09 / 0.06 / 0.00 | 7.3e-02 |
| hrf1 | never | 1203 | +inf | 0.49 / 0.49 / 0.44 / 0.42 ; 0.48 / 0.41 / 0.13 / 0.00 | 7.3e-02 |
| hrf2 | 93 | 107 | -0.20 | 0.13 / 0.06 / 0.06 / 0.06 ; 0.17 / 0.06 / 0.04 / 0.00 | 7.3e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 58 of 132 (thr30@16: 0.41 vs 0.33; thr30@32: 0.34 vs 0.25; majxor@64: 0.49 vs 0.47; majxor@128: 0.50 vs 0.44; majxor@256: 0.50 vs 0.36; majxor@512: 0.50 vs 0.25; majxor@1024: 0.49 vs 0.16; majxor@2048: 0.50 vs 0.00; majxor@4096: 0.50 vs 0.00; majxor@8192: 0.49 vs 0.00; majxor@16384: 0.50 vs 0.00; majmaj5@4096: 0.13 vs 0.03; majmaj5@8192: 0.13 vs 0.00; majmaj5@16384: 0.13 vs 0.00; par5@8192: 0.50 vs 0.01; par5@16384: 0.50 vs 0.00; mux6@128: 0.37 vs 0.31; mux6@256: 0.33 vs 0.23; mux6@512: 0.32 vs 0.09; mux6@1024: 0.32 vs 0.00; mux6@2048: 0.31 vs 0.00; mux6@4096: 0.31 vs 0.00; mux6@8192: 0.31 vs 0.00; mux6@16384: 0.31 vs 0.00; stair6@1024: 0.31 vs 0.26; stair6@2048: 0.30 vs 0.09; stair6@4096: 0.30 vs 0.00; stair6@8192: 0.29 vs 0.00; stair6@16384: 0.28 vs 0.00; inter2@2048: 0.10 vs 0.07; inter2@4096: 0.11 vs 0.02; inter2@8192: 0.10 vs 0.01; inter2@16384: 0.10 vs 0.00; majpar5@64: 0.51 vs 0.47; majpar5@128: 0.51 vs 0.43; majpar5@256: 0.51 vs 0.37; majpar5@512: 0.50 vs 0.27; majpar5@1024: 0.51 vs 0.18; majpar5@2048: 0.51 vs 0.14; majpar5@4096: 0.50 vs 0.14; majpar5@8192: 0.50 vs 0.03; majpar5@16384: 0.50 vs 0.00; hrf0@2048: 0.07 vs 0.01; hrf0@4096: 0.07 vs 0.00; hrf0@8192: 0.07 vs 0.00; hrf0@16384: 0.07 vs 0.00; hrf1@256: 0.49 vs 0.41; hrf1@512: 0.46 vs 0.34; hrf1@1024: 0.44 vs 0.13; hrf1@2048: 0.42 vs 0.00; hrf1@4096: 0.42 vs 0.00; hrf1@8192: 0.42 vs 0.00; hrf1@16384: 0.42 vs 0.00; hrf2@1024: 0.06 vs 0.04; hrf2@2048: 0.06 vs 0.00; hrf2@4096: 0.06 vs 0.00; hrf2@8192: 0.06 vs 0.00; hrf2@16384: 0.06 vs 0.00). Of these, by more than 2 standard errors of the seed-to-seed spread: 55 (majxor@128, majxor@256, majxor@512, majxor@1024, majxor@2048, majxor@4096, majxor@8192, majxor@16384, majmaj5@4096, majmaj5@8192, majmaj5@16384, par5@8192, par5@16384, mux6@128, mux6@256, mux6@512, mux6@1024, mux6@2048, mux6@4096, mux6@8192, mux6@16384, stair6@1024, stair6@2048, stair6@4096, stair6@8192, stair6@16384, inter2@2048, inter2@4096, inter2@8192, inter2@16384, majpar5@64, majpar5@128, majpar5@256, majpar5@512, majpar5@1024, majpar5@2048, majpar5@4096, majpar5@8192, majpar5@16384, hrf0@2048, hrf0@4096, hrf0@8192, hrf0@16384, hrf1@256, hrf1@512, hrf1@1024, hrf1@2048, hrf1@4096, hrf1@8192, hrf1@16384, hrf2@1024, hrf2@2048, hrf2@4096, hrf2@8192, hrf2@16384).

Mean log2 ratio over targets where both learn: -0.93 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 8; of 12. Largest compute used: 7.3e-02 of a GD run.


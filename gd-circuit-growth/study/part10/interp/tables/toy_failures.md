### Targets never learned or learned late (n_struct >= 1024) by v3's DFG member (seed 0)

| suite | target | k_class | n_struct | n_max | err_last | n_unfold | n_fold | n_mod | ratio_unfold_max | ratio_fold_max | W1 | W2 | W_le3 | deg_peak | reach_eig_max | reach_deg1_max | chance | best_jaccard_last | nstar3 | nets_best | lead |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dlfamdev | fd_10 | 10 | – | 16384 | 0.32 | 128 | 512 | – | 155 | 45 | 0.0000 | 0.0002 | 0.0043 | 7 | 0.50 | 0.20 | 0.33 | 0.00 | never | – | background (0.05) |
| dlheld6 | h6_00 | 13 | – | 16384 | 0.34 | 128 | 512 | – | 139 | 40 | 0.00 | 0.00 | 0.0001 | 9 | 0.54 | 0.38 | 0.43 | 0.00 | never | 12304 | background (0.05) |
| dlheld7 | f7_05 | 14 | – | 16384 | 0.32 | 128 | 512 | – | 134 | 39 | 0.00 | 0.00 | 0.0001 | 11 | 0.57 | 0.43 | 0.47 | 0.00 | never | never | background (0.04) |
| dlsymdev | band11 | 11 | 1024 | 2048 | 0.00 | 128 | 128 | – | 147 | 173 | 0.00 | 0.05 | 0.05 | 6 | 1.00 | 0.27 | 0.37 | 1.00 | 829 | 1836 | \|x1+x2+x3+x4+x5+x6+x7+x8+x9+x10+x11\| (0.97); quad(23 inputs) (0.10) |
| dlheld7 | f7_08 | 11 | 512 | 8192 | 0.00 | 128 | 512 | – | 147 | 34 | 0.02 | 0.05 | 0.09 | 11 | 1.00 | 1.00 | 0.37 | 1.00 | 634 | 5843 | (x1+x2+x3+x4+x5+x6+x7+x8+x9+x10+x11) (1.01); quad(20 inputs) (0.18) |
| dlheld5 | h5s1 | 9 | 16384 | 16384 | 0.00 | – | – | 128 | 0.04 | 0.02 | 0.00 | 0.0010 | 0.0059 | 11 | 0.44 | 0.22 | 0.30 | 1.00 | never | never | chi[x10,x11] (0.74); chi[x10,x11]*(x1-x2-x3-x4+x5-x6+x7+x8+x9) (0.41); chi[x10,x11]*(-x1+x2+x3+x4-x5+x6-x7-x8-x9) (0.41) |
| dlheld5 | h5s7 | 13 | 8192 | 16384 | 0.0005 | 128 | 128 | – | 140 | 148 | 0.0063 | 0.0090 | 0.02 | 12 | 1.00 | 0.85 | 0.43 | 1.00 | 6760 | 7641 | chi[x4]*(x1+x2-x3-x5-x6+x7-x8-x9+x10+x11-x12+x13) (0.25); (x1+x2-x3+x4-x5-x6+x7-x8-x9+x10+x11-x12+x13) (0.24); (-x1-x2+x3-x4+x5+x6-x7+x8+x9-x10-x11+x12-x13) (0.24) |
| dlfamdev | fd_08 | 11 | 1024 | 4096 | 0.00 | 2048 | 8192 | 512 | 7.21 | 3.81 | 0.51 | 0.23 | 0.74 | 1 | 0.36 | 0.82 | 0.37 | 1.00 | 29 | – | chi[x12] (0.52); chi[x13] (0.51); chi[x12,x13] (0.40) |
| dlheld7 | f7_11 | 6 | – | 4096 | 0.0002 | 4096 | 4096 | 128 | 5.74 | 6.56 | 0.71 | 0.11 | 0.93 | 1 | 1.00 | 0.33 | 0.20 | 1.00 | 55 | 114 | chi[x11] (0.69); chi[x2,x4,x11] (0.14); chi[x1,x4] (0.13) |
| dlheld6 | h6_02 | 9 | – | 1024 | 0.00 | – | – | 128 | 0.04 | 0.03 | 0.00 | 0.0015 | 0.53 | 3 | 0.44 | 0.11 | 0.30 | 0.89 | 389 | 996 | chi[x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11] (0.55); chi[x9,x10,x11] (0.32); chi[x2,x10,x11] (0.27) |
| dlheld6 | h6_08 | 6 | 1024 | 2048 | 0.00 | 512 | 256 | 256 | 47 | 54 | 0.28 | 0.11 | 0.50 | 1 | 1.00 | 0.50 | 0.20 | 1.00 | 449 | 1720 | chi[x11] (0.60); (x5+x6-x7+x8-x9+x10-3*x11) (0.30); chi[x2,x3,x11] (0.15) |
| dlheld5 | h5s2 | 7 | 1024 | 2048 | 0.00 | 128 | 256 | – | 182 | 53 | 0.0017 | 0.0051 | 0.08 | 5 | 1.00 | 0.71 | 0.23 | 1.00 | 1154 | 1850 | (x1-x2-x3+x4+x5-x6-x7) (0.92) |
| dlheld5 | h5s3 | 13 | 2048 | 4096 | 0.0017 | 128 | 256 | – | 140 | 79 | 0.0008 | 0.03 | 0.05 | 12 | 1.00 | 0.62 | 0.43 | 1.00 | 1757 | 6454 | (x1+x2+x3-x4+x5+x6+x7-x8+x9-x10+x11-x12+x13) (0.41); (-x1-x2-x3+x4-x5-x6-x7+x8-x9+x10-x11+x12-x13) (0.41); quad(23 inputs) (0.17) |
| dlheld4 | sumpar | 5 | 2048 | 2048 | 0.00 | 256 | – | 512 | 66 | 0.11 | 0.24 | 0.22 | 0.69 | 1 | 0.20 | 1.00 | 0.17 | 1.00 | – | 1837 | chi[x8,x9,x10] (0.52); chi[x6,x7] (0.45); chi[x1,x2,x3,x4,x5] (0.23) |

n_unfold / n_fold / n_mod: first n with T / threshold > 1 for the true block (toy_power); ratio_*_max: at the largest power n (16384); W_k: the target's Fourier weight at degree k; deg_peak: the degree with the largest weight; reach_*: fraction of the true class among the top |S| inputs of the search's orders at n = 16384 (eigenvector prefix: best of the top 2); chance = |S| / 30; best_jaccard_last: best Jaccard overlap of a learned block, factor or modulator with the true class at n_max.

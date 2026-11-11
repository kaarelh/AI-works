### DFG's block statistic around the true block (T / threshold, best of unfolded and folded; seed-0 training rows, round 0)

| suite | target | n | k | true | drop_1 | drop_2 | drop_3 | drop_4 | add_1 | add_2 | flip_1 | flip_2 | mixed_3 | mixed_3_frac_gt1 | random_k | pairs_in_max | singles_in_max | pairs_out_max |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dlfamdev | fd_10 | 16384 | 10 | 155 | 41 | 11 | 2.94 | 0.84 | 47 | 19 | 50 | 23 | 3.53 | 1.00 | 0.07 | 0.15 | 0.07 | 0.33 |
| dlheld5 | h5s1 | 16384 | 9 | 0.04 | 0.06 | 0.09 | 0.08 | 0.07 | 0.08 | 0.08 | 0.07 | 0.07 | 0.07 | 0.00 | 0.06 | 0.21 | 0.11 | 0.72 |
| dlheld5 | h5s7 | 2048 | 13 | 19 | 4.04 | 1.20 | 0.56 | 0.32 | 4.68 | 1.80 | 8.26 | 4.51 | 0.61 | 0.12 | 0.07 | 0.26 | 0.13 | 0.15 |
| dlheld5 | h5s7 | 4096 | 13 | 37 | 7.80 | 2.47 | 1.12 | 0.60 | 9.17 | 3.53 | 16 | 8.63 | 1.13 | 0.63 | 0.08 | 0.41 | 0.38 | 0.15 |
| dlheld6 | h6_00 | 16384 | 13 | 139 | 36 | 9.37 | 2.51 | 0.73 | 41 | 15 | 43 | 17 | 2.85 | 1.00 | 0.07 | 0.25 | 0.21 | 0.20 |
| dlheld7 | f7_05 | 16384 | 14 | 134 | 35 | 9.24 | 2.40 | 0.65 | 39 | 14 | 39 | 16 | 2.71 | 1.00 | 0.07 | 0.12 | 0.09 | 0.20 |
| dlheld7 | f7_08 | 256 | 11 | 2.37 | 0.52 | 0.35 | 0.28 | 0.22 | 0.64 | 0.38 | 1.73 | 1.52 | 0.24 | 0.07 | 0.07 | 0.23 | 0.20 | 0.26 |
| dlheld7 | f7_08 | 512 | 11 | 4.76 | 0.91 | 0.58 | 0.47 | 0.38 | 1.11 | 0.64 | 3.47 | 3.01 | 0.41 | 0.07 | 0.08 | 0.44 | 0.50 | 0.24 |
| dlsymdev | band11 | 1024 | 11 | 11 | 5.54 | 2.90 | 1.52 | 0.84 | 5.61 | 3.37 | 1.07 | 0.20 | 1.24 | 0.52 | 0.08 | 0.38 | 0.31 | 0.21 |
| dlsymdev | band11 | 512 | 11 | 5.41 | 2.75 | 1.37 | 0.72 | 0.40 | 2.70 | 1.63 | 0.61 | 0.15 | 0.62 | 0.10 | 0.07 | 0.27 | 0.29 | 0.33 |

toy_landscape.py: true = the true block; drop_j / add_j / flip_j = median over 200 random candidates with j inputs removed / j random inputs added / j signs flipped; mixed_3 = 3 errors of mixed kinds (and the fraction of those above the threshold); random_k = random blocks of the true size; pairs_in_max / singles_in_max = the best 2-input / 1-input block inside S; pairs_out_max = the best pair among 12 inputs outside S. > 1 means the candidate passes DFG's test.

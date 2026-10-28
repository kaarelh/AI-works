### v3's DFG member on the sum-structured suites (seed 0; final matcher)

| suite | target | kind | mixture | k | classes | n_struct | n_stable | n_class_first | classes_exact_last | n_dfg01 | n_detect | n_reach5 | nstar3 | nstar_s0 | nets_best | n_max | err_last | lead |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dlsymdev | band11 | arbitrary | pure | 11 | 11 | 1024 | 1024 | 1024 | 1/1 | 1024 | 128 | 1024 | 829 | 889 | 1836 | 2048 | 0.00 | \|x1+x2+x3+x4+x5+x6+x7+x8+x9+x10+x11\| (0.97); quad(23 inputs) (0.10) |
| dlsymdev | ex3of8 | interval | pure | 8 | 8 | 128 | 128 | 128 | 1/1 | 128 | 128 | 1024 | 118 | 98 | 664 | 256 | 0.00 | (x1+x2+x3+x4+x5+x6+x7+x8) (0.80) |
| dlsymdev | far9 | band | pure | 9 | 9 | 128 | 128 | 128 | 1/1 | 128 | 128 | 128 | 71 | 86 | 296 | 1024 | 0.0002 | \|x1+x2+x3+x4+x5+x6+x7+x8+x9\| (0.43); quad(21 inputs) (0.26); chi[x4,x7] (0.08) |
| dlsymdev | ssym9 | band | pure | 9 | 9 | 128 | 128 | 128 | 1/1 | 128 | 128 | 128 | 104 | 111 | 324 | 256 | 0.0010 | quad(25 inputs) (0.56); \|x1-x2+x3-x4+x5+x6-x7+x8+x9\| (0.46) |
| dlsymdev | sym7 | band | pure | 7 | 7 | 64 | 64 | 64 | 1/1 | 64 | 128 | 64 | 55 | 55 | 329 | 128 | 0.00 | \|x1+x2+x3+x4+x5+x6+x7\| (0.61); \|x1+x2+x3+x4+x5+x6+x7\| x \|x15-x16\| (0.40) |
| dlsymdev | symxpar | band | parity | 8 | 6 | 128 | 128 | 128 | 1/1 | 128 | 128 | – | 111 | 112 | 1410 | 256 | 0.00 | (-x1-x2-x3-x4-x5-x6+3*x8x7) (0.73); chi[x7,x8] (0.30); chi[x4,x6,x7,x8] (0.20) |
| dlsymdev | thrsum | threshold | weighted | 8 | 6 | 256 | 256 | 256 | 1/1 | 256 | 128 | 256 | 80 | 89 | 330 | 512 | 0.00 | chi[x7,x8] (0.68); chi[x2] (0.23); chi[x4] (0.22) |
| dlsymdev | twosym | band+band | two sums | 10 | 5+5 | 512 | 512 | 512/512 | 2/2 | 512 | 1024 | 2048 | 415 | 449 | 1817 | 1024 | 0.00 | \|x1+x2+x3+x4+x5\| x \|x6+x7+x8+x9+x10\| (0.72); \|x1+x2+x3+x4+x5-x6-x7-x8-x9-x10\| (0.36) |
| dlfamdev | fd_00 | control | control | 8 | – | n/a | n/a | – | – | – | 256 | 128 | 75 | 92 | – | 512 | 0.00 | chi[x3] (0.44); (x1+x6) x (-x3-x5-2*AND(-x2,x4)) (0.36); chi[x2] (0.30) |
| dlfamdev | fd_01 | threshold | pure | 6 | 6 | 128 | 128 | 128 | 1/1 | 128 | 128 | 64 | 79 | 78 | – | 256 | 0.00 | chi[x5] (0.29); chi[x2] (0.29); chi[x4] (0.28) |
| dlfamdev | fd_02 | band | parity | 10 | 8 | 128 | 128 | 128 | 1/1 | 128 | 128 | – | 66 | 77 | – | 256 | 0.00 | chi[x9,x10] (0.87); chi[x9,x10]*\|-x1+x2+x3+x4+x5+x6+x7-x8\| (0.41); \|-x1+x2+x3+x4+x5+x6+x7-x8+x9+x10-x11-x12+x20+x21-x25-x26-x28\| (0.05) |
| dlfamdev | fd_03 | control | control | 6 | – | n/a | n/a | – | – | 512 | 256 | 16 | 81 | 56 | – | 512 | 0.00 | chi[x6] (0.47); chi[x1,x2] (0.33); chi[x1] (0.30) |
| dlfamdev | fd_04 | band | parity | 9 | 6+3 | 128 | 128 | 128/128 | 2/2 | 128 | 128 | – | 171 | 112 | – | 256 | 0.00 | chi[x7,x8,x9]*\|x1+x2+x3+x4+x5+x6\| (1.06); chi[x7,x8,x9] (0.95) |
| dlfamdev | fd_05 | threshold+band | two sums | 13 | 6+7 | 256 | 256 | 128/256 | 2/2 | 256 | 512 | 128 | 147 | 120 | – | 1024 | 0.0027 | quad(17 inputs) (0.37); (x1+x2+x3+x4+x5+x6) (0.24); chi[x1] (0.22) |
| dlfamdev | fd_06 | threshold+interval | two sums | 11 | 4+7 | 256 | 1024 | 256/256 | 2/2 | 1024 | 1024 | 1024 | 318 | 217 | – | 8192 | 0.0010 | (x1+x2-x3+x4+x5-x6-x7-x8-x9+x10+x11) (0.31); (x1+x2-x3+x4-x5+x6+x7+x8+x9-x10-x11) (0.27); chi[x1,x2,x3,x4]*(-x5+x6+x7+x8+x9-x10-x11) (0.13) |
| dlfamdev | fd_07 | control | control | 8 | 3 | 128 | 512 | 128 | 1/1 | 512 | 128 | 32 | 98 | 76 | – | 512 | 0.00 | (x1+x4+x6-x8) (0.34); chi[x1,x8] (0.30); chi[x2,x3,x5] (0.28) |
| dlfamdev | fd_08 | interval | gate | 13 | 11 | 1024 | 1024 | 1024 | 1/1 | 1024 | 512 | 16384 | 29 | 26 | – | 4096 | 0.00 | chi[x12] (0.52); chi[x13] (0.51); chi[x12,x13] (0.40) |
| dlfamdev | fd_09 | arbitrary | pure | 6 | 6 | 128 | 128 | 128 | 1/1 | 512 | 128 | 256 | 101 | 102 | – | 1024 | 0.00 | (x1+x2+x3+x4+x5+x6) (0.51); chi[x6] (0.18); chi[x5] (0.18) |
| dlfamdev | fd_10 | modular | pure | 10 | 10 | > 16384 | > 16384 | – | 0/1 | – | 128 | – | never | never | – | 16384 | 0.32 | background (0.05) |
| dlfamdev | fd_11 | band | gate | 10 | 9 | 256 | 256 | 256 | 1/1 | 256 | 128 | 1024 | 123 | 120 | – | 512 | 0.00 | chi[x10] (0.74); \|x1+x2+x3+x4+x5+x6+x7+x8+x9\| x (x10-x14) (0.40); background (0.08) |
| dlheld7 | f7_00 | band+interval | two sums | 11 | 4+7 | 256 | 256 | 128/256 | 2/2 | 256 | 256 | 256 | 203 | 196 | 1545 | 512 | 0.00 | (x5+x6+x7-x8-x9-x10-x11) x \|x1+x2-x3-x4\| (0.69); (x5+x6+x7-x8-x9-x10-x11) (0.38); chi[x1,x3] (0.10) |
| dlheld7 | f7_01 | threshold | pure | 13 | 13 | 256 | 256 | 256 | 1/1 | 256 | 128 | 128 | 106 | 147 | 119 | 512 | 0.00 | (x1+x2+x3+x4+x5+x6+x7+x8+x9+x10+x11+x12+x13) (0.26); chi[x4] (0.19); chi[x1] (0.19) |
| dlheld7 | f7_02 | control | control | 8 | – | n/a | n/a | – | – | 256 | 512 | 64 | 106 | 111 | 337 | 1024 | 0.00 | chi[x2,x6,x8] (0.25); chi[x5] (0.25); chi[x3,x5] (0.21) |
| dlheld7 | f7_03 | modular+band | mux | 11 | 6+4 | 512 | lost at 2048 | 512/256 | 1/2 | 512 | 128 | 2048 | 352 | 354 | 1599 | 2048 | 0.00 | chi[x11] (0.58); (x1+x2+x3+x4+x5+x6+3*x11) (0.24); (-x1-x2-x4-x5-x6+x11+3*x3) (0.22) |
| dlheld7 | f7_04 | control | control | 9 | 3 | 2048 | 2048 | 2048 | 1/1 | 2048 | 256 | 2048 | 70 | 92 | 164 | 2048 | 0.0002 | chi[x9] (0.34); chi[x6,x9] (0.32); chi[x8] (0.31) |
| dlheld7 | f7_05 | modular | pure | 14 | 14 | > 16384 | > 16384 | – | 0/1 | – | 128 | – | never | never | never | 16384 | 0.32 | background (0.04) |
| dlheld7 | f7_06 | control | control | 8 | 5 | 256 | 256 | 256 | 1/1 | 256 | 128 | 2048 | 44 | 53 | 108 | 512 | 0.00 | chi[x8] (0.58); (x6-x7+3*x8) (0.25); chi[x7,x8] (0.23) |
| dlheld7 | f7_07 | interval | parity | 13 | 12 | 256 | 256 | 256 | 1/1 | 256 | 128 | 1024 | 174 | 193 | 445 | 2048 | 0.0039 | chi[x13] (0.40); (-x1+x2-x3+x4+x5+x6+x7+x8-x9+x10-x11+x12-3*x13) (0.29); (-x1+x2-x3+x4+x5+x6+x7+x8-x9+x10-x11+x12+3*x13) (0.28) |
| dlheld7 | f7_08 | arbitrary | pure | 11 | 11 | 512 | 512 | 512 | 1/1 | 1024 | 128 | 1024 | 634 | 443 | 5843 | 8192 | 0.00 | (x1+x2+x3+x4+x5+x6+x7+x8+x9+x10+x11) (1.01); quad(20 inputs) (0.18) |
| dlheld7 | f7_09 | threshold | parity | 12 | 10 | 256 | lost at 512 | 256 | 0/1 | 256 | 128 | – | 215 | 213 | 1000 | 512 | 0.00 | chi[x9,x11,x12] (0.30); chi[x7,x11,x12] (0.29); chi[x2,x11,x12] (0.29) |
| dlheld7 | f7_10 | threshold | weighted | 6 | 5 | 128 | 128 | 128 | 1/1 | 128 | 128 | 32 | 82 | 88 | 210 | 256 | 0.00 | (x1+x2+x3+x4+x5+2*x6) (0.57); chi[x6] (0.43); chi[x3] (0.22) |
| dlheld7 | f7_11 | arbitrary+band | mux | 11 | 4+6 | > 4096 | > 4096 | 128/2048 | 1/2 | 1024 | 128 | 1024 | 55 | 73 | 114 | 4096 | 0.0002 | chi[x11] (0.69); chi[x2,x4,x11] (0.14); chi[x1,x4] (0.13) |
| dlheld6 | h6_00 | modular | pure | 13 | 13 | > 16384 | > 16384 | – | 0/1 | – | 128 | – | never | never | 12304 | 16384 | 0.34 | background (0.05) |
| dlheld6 | h6_01 | arbitrary | pure | 9 | 9 | 512 | 512 | 512 | 1/1 | 512 | 128 | 2048 | 430 | 431 | 1655 | 1024 | 0.00 | (-x1+x2-x3+x4+x5+x6-x7-x8-x9) (0.91); chi[x5] (0.06); chi[x2] (0.05) |
| dlheld6 | h6_02 | interval | parity | 11 | 9 | > 1024 | > 1024 | – | 0/1 | 512 | 128 | – | 389 | 419 | 996 | 1024 | 0.00 | chi[x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11] (0.55); chi[x9,x10,x11] (0.32); chi[x2,x10,x11] (0.27) |
| dlheld6 | h6_03 | control | control | 6 | – | n/a | n/a | – | – | 256 | 256 | 16 | 98 | 82 | 231 | 512 | 0.00 | chi[x4,x5] (0.37); chi[x5] (0.37); chi[x2,x6] (0.34) |
| dlheld6 | h6_04 | control | control | 5 | – | n/a | n/a | – | – | 512 | 64 | 32 | 29 | 26 | 96 | 1024 | 0.00 | chi[x1] (0.62); (x1+x3+3*AND(x4,x2)) (0.30); (-x1+x3+3*AND(x5,x2)) (0.24) |
| dlheld6 | h6_05 | control | control | 8 | 3 | > 2048 | > 2048 | – | 0/1 | 512 | 64 | 256 | 33 | 28 | 56 | 2048 | 0.00 | chi[x6] (0.70); (-x6+x8+3*AND(-x3,x2)) (0.12); (x6+x8-3*AND(x2,x4)) (0.11) |
| dlheld6 | h6_06 | arbitrary | parity | 8 | 6 | 256 | 2048 | 256 | 1/1 | 256 | 128 | – | 349 | 223 | 1872 | 4096 | 0.00 | (x1+x2+x3+x4+x5+x6-3*x7x8) (0.63); (x1+x2+x3+x4+x5+x6+3*x7x8) (0.62); chi[x7,x8] (0.16) |
| dlheld6 | h6_07 | arbitrary+threshold | mux | 11 | 6+4 | 512 | 512 | 512/512 | 2/2 | 512 | 256 | – | 447 | 355 | 1812 | 1024 | 0.00 | (x1-x2-x3-x4-x5-x6+3*x11) (0.40); chi[x7] (0.27); chi[x10] (0.27) |
| dlheld6 | h6_08 | band+modular | mux | 11 | 4+6 | 1024 | 1024 | 256/1024 | 2/2 | 1024 | 256 | 4096 | 449 | 745 | 1720 | 2048 | 0.00 | chi[x11] (0.60); (x5+x6-x7+x8-x9+x10-3*x11) (0.30); chi[x2,x3,x11] (0.15) |
| dlheld6 | h6_09 | interval+interval | two sums | 11 | 6+5 | 512 | lost at 4096 | 512/512 | 1/2 | 512 | 512 | 256 | 380 | 366 | 744 | 4096 | 0.0037 | (-x1-x2-x3-x4-x5-x6+x7+x8-x9+x10+x11) (0.46); quad(19 inputs) (0.28); (x1+x2+x3+x4+x5+x6+x7+x8-x9+x10+x11) (0.19) |
| dlheld6 | h6_10 | band | weighted | 13 | 12 | 256 | 256 | 256 | 1/1 | 512 | 256 | 512 | 206 | 211 | 451 | 1024 | 0.00 | \|-x1-x2-x3-x4-x5-x6-x7-x8-x9-x10-x11-x12+3*x13\| (0.86) |
| dlheld6 | h6_11 | interval | pure | 7 | 7 | 128 | 128 | 128 | 1/1 | 128 | 128 | 256 | 184 | 100 | 357 | 256 | 0.00 | (x1+x2+x3+x4+x5+x6+x7) (0.51); (x1+x2+x3+x4+x5+x6+x7) x \|x11+x26\| (0.37); chi[x15,x16,x20] (0.06) |
| dlheld5 | h5s0 | arbitrary | pure | 12 | 12 | 256 | 256 | 256 | 1/1 | 512 | 128 | 512 | – | 200 | 803 | 2048 | 0.0044 | (x1-x2+x3+x4-x5+x6-x7+x8+x9+x10+x11-x12) (0.46); (x1-x2+x3+x4-x5+x6-x7+x8+x9+x10+x11-x12) x \|x16+x27\| (0.26); \|x14+x15+x20-x22-x23+x28-x29-x30\| x (x1-x2+x3+x4-x5+x6-x7+x8+x9+x10+x11-x12+3*x16x27) (0.12) |
| dlheld5 | h5s1 | arbitrary | parity | 11 | 9 | 16384 | 16384 | 16384 | 1/1 | 16384 | 128 | – | – | 14263 | never | 16384 | 0.00 | chi[x10,x11] (0.74); chi[x10,x11]*(x1-x2-x3-x4+x5-x6+x7+x8+x9) (0.41); chi[x10,x11]*(-x1+x2+x3+x4-x5+x6-x7-x8-x9) (0.41) |
| dlheld5 | h5s2 | arbitrary | pure | 7 | 7 | 1024 | 1024 | 1024 | 1/1 | 1024 | 128 | 8192 | – | 845 | 1850 | 2048 | 0.00 | (x1-x2-x3+x4+x5-x6-x7) (0.92) |
| dlheld5 | h5s3 | arbitrary | pure | 13 | 13 | 2048 | 2048 | 2048 | 1/1 | 2048 | 128 | 2048 | – | 1751 | 6454 | 4096 | 0.0017 | (x1+x2+x3-x4+x5+x6+x7-x8+x9-x10+x11-x12+x13) (0.41); (-x1-x2-x3+x4-x5-x6-x7+x8-x9+x10-x11+x12-x13) (0.41); quad(23 inputs) (0.17) |

n_struct: first analysed n with every true signed-symmetry class of size >= 3 matched exactly by a block, factor or modulator; n_stable: from then on at every analysed n; n_detect: first n at which DFG's test accepts the true (largest) block (toy_power, seed-0 rows); nstar3: v3's 3-seed n* (toy__p10_sum-perm__<suite>.json), '–' where that file is not yet written; nstar_s0: seed-0 n* from the structure run; lead: the largest terms of the final DFG model at n_max (share = sd of the term's output on the test inputs; quad = a spectral feature; background = the kernel background). The structure runs stop after two consecutive n with err <= 0.005.

### v3's DFG member on the sum-structured suites (seed 0; final matcher)

| suite | target | kind | mixture | k | classes | n_struct | n_stable | n_detect | n_reach5 | nstar3 | nstar_s0 | nets_best | n_max | err_last | lead |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dlsymdev | band11 | arbitrary | pure | 11 | 11 | 1024 | 1024 | 128 | 1024 | 829 | 889 | 1836 | 2048 | 0.0 | \|x1+x2+x3+x4+x5+x6+x7+x8+x9+x10+x11\| (0.97); quad(23 inputs) (0.10) |
| dlsymdev | ex3of8 | interval | pure | 8 | 8 | 128 | 128 | 128 | 1024 | 118 | 98 | 664 | 256 | 0.0 | (x1+x2+x3+x4+x5+x6+x7+x8) (0.80) |
| dlsymdev | far9 | band | pure | 9 | 9 | 128 | 128 | 128 | 128 | 71 | 86 | 296 | 1024 | 0.0002 | \|x1+x2+x3+x4+x5+x6+x7+x8+x9\| (0.43); quad(21 inputs) (0.26); chi[x4,x7] (0.08) |
| dlsymdev | ssym9 | band | pure | 9 | 9 | 128 | 128 | 128 | 128 | 104 | 111 | 324 | 256 | 0.001 | quad(25 inputs) (0.56); \|x1-x2+x3-x4+x5+x6-x7+x8+x9\| (0.46) |
| dlsymdev | sym7 | band | pure | 7 | 7 | 64 | 64 | 128 | 64 | 55 | 55 | 329 | 128 | 0.0 | \|x1+x2+x3+x4+x5+x6+x7\| (0.61); \|x1+x2+x3+x4+x5+x6+x7\| x \|x15-x16\| (0.40) |
| dlsymdev | symxpar | band | parity | 8 | 6 | 128 | 128 | 128 | – | 111 | 112 | 1410 | 256 | 0.0 | (-x1-x2-x3-x4-x5-x6+3*x8x7) (0.73); chi[x7,x8] (0.30); chi[x4,x6,x7,x8] (0.20) |
| dlsymdev | thrsum | threshold | weighted | 8 | 6 | 256 | 256 | 128 | 256 | 80 | 89 | 330 | 512 | 0.0 | chi[x7,x8] (0.68); chi[x2] (0.23); chi[x4] (0.22) |
| dlsymdev | twosym | band+band | two sums | 10 | 5+5 | 512 | 512 | 1024 | 2048 | 415 | 449 | 1817 | 1024 | 0.0 | \|x1+x2+x3+x4+x5\| x \|x6+x7+x8+x9+x10\| (0.72); \|x1+x2+x3+x4+x5-x6-x7-x8-x9-x10\| (0.36) |
| dlfamdev | fd_00 | control | control | 8 | – | n/a | n/a | 256 | 128 | 75 | 92 | – | 512 | 0.0 | chi[x3] (0.44); (x1+x6) x (-x3-x5-2*AND(-x2,x4)) (0.36); chi[x2] (0.30) |
| dlfamdev | fd_01 | threshold | pure | 6 | 6 | 128 | 128 | 128 | 64 | 79 | 78 | – | 256 | 0.0 | chi[x5] (0.29); chi[x2] (0.29); chi[x4] (0.28) |
| dlfamdev | fd_02 | band | parity | 10 | 8 | 128 | 128 | 128 | – | 66 | 77 | – | 256 | 0.0 | chi[x9,x10] (0.87); chi[x9,x10]*\|-x1+x2+x3+x4+x5+x6+x7-x8\| (0.41); \|-x1+x2+x3+x4+x5+x6+x7-x8+x9+x10-x11-x12+x20+x21-x25-x26-x28\| (0.05) |
| dlfamdev | fd_03 | control | control | 6 | – | n/a | n/a | 256 | 16 | 81 | 56 | – | 512 | 0.0 | chi[x6] (0.47); chi[x1,x2] (0.33); chi[x1] (0.30) |
| dlfamdev | fd_04 | band | parity | 9 | 6+3 | 128 | 128 | 128 | – | 171 | 112 | – | 256 | 0.0 | chi[x7,x8,x9]*\|x1+x2+x3+x4+x5+x6\| (1.06); chi[x7,x8,x9] (0.95) |
| dlfamdev | fd_05 | threshold+band | two sums | 13 | 6+7 | 256 | 256 | 512 | 128 | 147 | 120 | – | 1024 | 0.0027 | quad(17 inputs) (0.37); (x1+x2+x3+x4+x5+x6) (0.24); chi[x1] (0.22) |
| dlfamdev | fd_06 | threshold+interval | two sums | 11 | 4+7 | 256 | 1024 | 1024 | 1024 | 318 | 217 | – | 8192 | 0.001 | (x1+x2-x3+x4+x5-x6-x7-x8-x9+x10+x11) (0.31); (x1+x2-x3+x4-x5+x6+x7+x8+x9-x10-x11) (0.27); chi[x1,x2,x3,x4]*(-x5+x6+x7+x8+x9-x10-x11) (0.13) |
| dlfamdev | fd_07 | control | control | 8 | 3 | 128 | 512 | 128 | 32 | 98 | 76 | – | 512 | 0.0 | (x1+x4+x6-x8) (0.34); chi[x1,x8] (0.30); chi[x2,x3,x5] (0.28) |
| dlfamdev | fd_08 | interval | gate | 13 | 11 | 1024 | 1024 | 512 | 16384 | 29 | 26 | – | 4096 | 0.0 | chi[x12] (0.52); chi[x13] (0.51); chi[x12,x13] (0.40) |
| dlfamdev | fd_09 | arbitrary | pure | 6 | 6 | 128 | 128 | 128 | 256 | 101 | 102 | – | 1024 | 0.0 | (x1+x2+x3+x4+x5+x6) (0.51); chi[x6] (0.18); chi[x5] (0.18) |

n_struct: first analysed n with every true signed-symmetry class of size >= 3 matched exactly by a block, factor or modulator; n_stable: from then on at every analysed n; n_detect: first n at which DFG's test accepts the true (largest) block (toy_power, seed-0 rows); nstar3: v3's 3-seed n* (toy__p10_sum-perm__<suite>.json), '–' where that file is not yet written; nstar_s0: seed-0 n* from the structure run; lead: the largest terms of the final DFG model at n_max (share = sd of the term's output on the test inputs; quad = a spectral feature; background = the kernel background). The structure runs stop after two consecutive n with err <= 0.005.

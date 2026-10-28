### v3's DFG member on the non-sum suites (seed 0): what carries the model

| suite | target | desc | k | nstar3 | nstar_s0 | n_chi90 | n_span95 | n_max | chi_frac | span_r2 | n_chi | n_sum | w_dfg | lead |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| designed | and3 | AND(x1,x2,x3) | 3 | 25 | 29 | 256 | 128 | 256 | 1.00 | 1.00 | 7 | 0 | 0.32 | chi[x1,x2,x3] (0.26); chi[x1,x2] (0.26); chi[x2,x3] (0.26) |
| designed | andxor | AND(x1x2, x3x4) | 4 | 40 | 57 | 256 | 128 | 256 | 1.00 | 1.00 | 3 | 0 | 0.86 | chi[x1,x2] (0.50); chi[x3,x4] (0.50); chi[x1,x2,x3,x4] (0.48) |
| designed | dict | x1 | 1 | 16 | 16 | 16 | 16 | 32 | 1.00 | 1.00 | 1 | 0 | 0.38 | chi[x1] (0.99) |
| designed | dlist5 | decision list x1:+ ~x2:- x3:+ x4:- x5:+ else - | 5 | 32 | 19 | – | 256 | 512 | 0.83 | 0.95 | 32 | 2 | 0.37 | chi[x1] (0.66); chi[x2] (0.34); chi[x1,x2] (0.32) |
| designed | dnf3 | (x1&x2&x3) \| (x4&~x5&x6) \| (x7&x8&~x9) | 9 | 118 | 117 | – | – | 512 | 0.58 | 0.87 | 35 | 2 | 0.41 | (-x4+x5-x6) x (-x7-x8+x9-3*AND(x1,x3)) (0.48); (x4-x5+x6) (0.30); chi[x9] (0.24) |
| designed | maj3 | MAJ(x1,x2,x3) | 3 | 31 | 28 | 128 | 128 | 256 | 1.00 | 1.00 | 4 | 0 | 0.32 | chi[x3] (0.50); chi[x1] (0.50); chi[x1,x2,x3] (0.50) |
| designed | maj9 | MAJ(x1..x9) | 9 | 80 | 85 | – | 128 | 256 | 0.67 | 1.00 | 30 | 1 | 0.65 | (x1+x2+x3+x4+x5+x6+x7+x8+x9) (0.65); chi[x1] (0.16); chi[x6] (0.16) |
| designed | majpar | MAJ(x1x2, x3x4, x5x6) | 6 | 60 | 61 | – | 256 | 512 | 0.75 | 1.00 | 3 | 1 | 0.90 | chi[x1,x2] (0.54); chi[x3,x4] (0.54); chi[x5,x6] (0.48) |
| designed | mux | x4 ? x1x2x3 : MAJ(x1,x2,x3) | 4 | 70 | 56 | – | 128 | 256 | 0.88 | 1.00 | 8 | 3 | 0.82 | chi[x1,x2,x3,x4] (0.51); chi[x1,x2,x3] (0.35); chi[x2,x4] (0.27) |
| designed | par2 | x1 x2 | 2 | 16 | 16 | 16 | 16 | 32 | 1.00 | 1.00 | 1 | 0 | 0.94 | chi[x1,x2] (1.00) |
| designed | par3 | x1 x2 x3 | 3 | 55 | 56 | 64 | 64 | 128 | 1.00 | 1.00 | 1 | 0 | 0.99 | chi[x1,x2,x3] (1.00) |
| designed | par4 | x1 x2 x3 x4 | 4 | 56 | 56 | 64 | 64 | 128 | 1.00 | 1.00 | 1 | 0 | 1.00 | chi[x1,x2,x3,x4] (1.00) |
| designed | parmaj | MAJ(x1,x2,x3) XOR MAJ(x4,x5,x6) | 6 | 110 | 111 | – | 128 | 256 | 0.25 | 1.00 | 4 | 2 | 0.99 | \|x1+x2+x3+x4+x5+x6\| (0.62); \|-x1-x2-x3+x4+x5+x6\| (0.59); chi[x1,x5] (0.08) |
| designed | rand0 | random 6-gate formula: g6=2xor3; g7=~6and2; g8=7and~1; g9=8a | 5 | 16 | 33 | 128 | 128 | 256 | 0.90 | 1.00 | 31 | 2 | 0.84 | chi[x3,x6] (0.99); (x1+x2-x3+x4-x6) (0.36); chi[x2] (0.14) |
| designed | rand1 | random 6-gate formula: g6=~3xor5; g7=~6and~0; g8=~7and4; g9= | 5 | 95 | 106 | – | 256 | 256 | 0.86 | 1.00 | 6 | 1 | 0.80 | chi[x3,x5] (0.41); chi[x1,x4,x6] (0.40); chi[x3] (0.38) |
| designed | rand2 | random 6-gate formula: g6=4or3; g7=~2and4; g8=2and5; g9=~8an | 5 | 16 | 16 | – | 128 | 256 | 0.84 | 1.00 | 6 | 2 | 0.78 | chi[x2] (0.72); chi[x2]*(x3-x4-x5+x6) (0.22); chi[x2,x6] (0.18) |
| designed | rand3 | random 6-gate formula: g6=1and2; g7=6and~0; g8=~5or3; g9=~3a | 6 | 114 | 117 | – | 256 | 512 | 0.56 | 1.00 | 4 | 2 | 0.93 | (-x1+x2+x3) x (-x4-x6+2*x5) (0.51); chi[x4,x5] (0.42); chi[x4,x5,x6] (0.28) |
| designed | rmaj9 | MAJ of three MAJ3s | 9 | 163 | 169 | – | 512 | 512 | 0.76 | 0.98 | 15 | 8 | 0.69 | chi[x7,x8,x9] (0.29); chi[x1,x2,x3] (0.27); chi[x4,x5,x6] (0.26) |
| designed | sparsepoly | sign(2x1 + x2x3 + x4x5x6) | 6 | 103 | 83 | 1024 | 1024 | 1024 | 0.93 | 0.97 | 6 | 1 | 0.73 | chi[x1] (0.75); chi[x1,x4,x5,x6] (0.25); chi[x2,x3] (0.25) |
| designed | stair5 | sign(x1 + x1x2 + ... + x1..x5) | 5 | 109 | 107 | – | 256 | 256 | 0.73 | 0.97 | 7 | 3 | 0.82 | chi[x1,x2,x3] (0.42); chi[x1,x2,x3,x4] (0.40); chi[x1,x3,x5] (0.36) |
| designed | thr10 | sign(w.x[1..10]), Gaussian w | 10 | 121 | 111 | 2048 | 2048 | 4096 | 0.96 | 0.99 | 209 | 3 | 0.42 | chi[x10] (0.40); chi[x1] (0.31); chi[x7] (0.30) |
| dlheld3 | cnf3 | (x1\|x2\|x3) & (~x4\|x5\|x6) & (x7\|~x8\|x9) | 9 | – | 169 | – | 512 | 512 | 0.66 | 0.97 | 37 | 3 | 0.43 | (x7-x8+x9) x (-x4+x5+x6-3*AND(-x1,-x2)) (0.42); (x7-x8+x9) x (x1+x2+3*x3) (0.24); chi[x3] (0.21) |
| dlheld3 | dlist8 | decision list on 8 literals | 8 | – | 28 | 2048 | 256 | 2048 | 0.96 | 0.98 | 53 | 5 | 0.20 | chi[x1] (0.71); chi[x2,x3] (0.14); chi[x1,x2,x3] (0.14) |
| dlheld3 | h3rf0 | random 8-gate formula on 7 inputs: g7=2xor~3; g8=~7and0; g9= | 6 | – | 44 | 512 | 512 | 2048 | 0.98 | 1.00 | 14 | 3 | 0.62 | chi[x4] (0.74); chi[x2,x5] (0.18); chi[x1,x4,x5,x6,x7] (0.12) |
| dlheld3 | h3rf1 | random 9-gate formula on 7 inputs: g7=~5or1; g8=~0or~6; g9=~ | 6 | – | 16 | – | 512 | 2048 | 0.81 | 1.00 | 7 | 3 | 0.51 | chi[x6] (0.69); chi[x5] (0.22); chi[x2,x4,x6] (0.20) |
| dlheld3 | mixmaj | MAJ(x1 x2, x3 & x4, x5 \| x6) | 6 | – | 79 | – | 256 | 512 | 0.77 | 0.88 | 7 | 1 | 0.73 | chi[x1,x2] (0.53); chi[x5,x6] (0.29); chi[x3,x4] (0.27) |
| dlheld3 | mux11 | 11-multiplexer: address x1..x3, data x4..x11 | 11 | – | 478 | 2048 | 1024 | 2048 | 0.97 | 1.00 | 64 | 1 | 0.33 | chi[x1,x8] (0.14); chi[x2,x5] (0.14); chi[x8] (0.14) |
| dlheld3 | par3or | (x1 x2 x3) \| (x4 & x5) | 5 | – | 59 | 128 | 128 | 256 | 0.67 | 1.00 | 2 | 2 | 0.91 | chi[x1,x2,x3] (0.78); (x4+x5) (0.38); (-x1+x2+x3) x (x4+x5) (0.16) |
| dlheld3 | poly4 | sign(x1x2 + x3x4x5 + x6/2 + x7x8x9x10) | 10 | – | 198 | – | – | 512 | 0.75 | 0.75 | 3 | 0 | 1.00 | chi[x3,x4,x5] (0.51); chi[x7,x8,x9,x10] (0.51); chi[x1,x2] (0.50) |
| dlheld3 | sym9 | \|x1 + ... + x9\| <= 1 | 9 | – | 111 | – | 128 | 256 | 0.00 | 1.00 | 0 | 2 | 0.93 | \|x1+x2+x3+x4+x5+x6+x7+x8+x9\| (0.59); \|x1+x2+x3+x4+x5+x6+x7+x8+x9\| x \|x15+x28\| (0.41) |
| dlheld3 | thrint | sign(3x1 + 2x2 + 2x3 + x4 + ... + x9) | 9 | – | 150 | – | 512 | 1024 | 0.79 | 1.00 | 20 | 7 | 0.40 | chi[x1] (0.46); chi[x2] (0.31); chi[x3] (0.30) |
| dlheld2 | dnf4x2 | (x1&x2) \| (x3&x4) \| (x5&x6) \| (x7&x8) | 8 | – | 135 | – | – | 512 | 0.62 | 0.81 | 34 | 1 | 0.44 | chi[x5,x6] (0.24); chi[x7,x8] (0.24); chi[x1,x2] (0.24) |
| dlheld2 | h2rf0 | random 7-gate formula on 7 inputs: g7=~4or6; g8=3or~5; g9=~8 | 6 | – | 114 | – | 512 | 2048 | 0.77 | 1.00 | 5 | 3 | 0.20 | chi[x1] (0.46); chi[x1,x5,x7] (0.42); chi[x1,x5] (0.41) |
| dlheld2 | h2rf1 | random 7-gate formula on 7 inputs: g7=~2or~3; g8=7or0; g9=8x | 6 | – | 38 | – | 256 | 512 | 0.85 | 1.00 | 6 | 7 | 0.79 | chi[x6] (0.60); chi[x7] (0.24); chi[x6,x7] (0.21) |
| dlheld2 | maj21 | MAJ(x1..x21) | 21 | – | 94 | – | 128 | 512 | – | 1.00 | 30 | 1 | 0.68 | (x1+x2+x3+x4+x5+x6+x7+x8+x9+x10+x11+x12+x13+x14+x15+x16+x17+x18+x19+x20+x21) (0.26); chi[x20] (0.19); chi[x8] (0.19) |
| dlheld2 | sym8 | \|x1 + ... + x8\| >= 4 | 8 | – | 59 | – | 64 | 1024 | 0.34 | 1.00 | 14 | 1 | 0.80 | \|x1+x2+x3+x4+x5+x6+x7+x8\| (0.59); quad(23 inputs) (0.19); chi[x2,x5] (0.08) |
| dlheld2 | thr20 | sign(w.x[1..20]), Gaussian w | 20 | – | 126 | – | – | 16384 | – | 0.84 | 61 | 7 | 0.17 | chi[x6] (0.38); chi[x3] (0.26); chi[x1] (0.26) |
| dlheld2 | xmaj | x1 x2 MAJ(x3,x4,x5) | 5 | – | 67 | 128 | 128 | 256 | 1.00 | 1.00 | 5 | 0 | 1.00 | chi[x1,x2,x3] (0.50); chi[x1,x2,x3,x4,x5] (0.49); chi[x1,x2,x5] (0.49) |
| dlheld | maj15 | MAJ(x1..x15) | 15 | – | 82 | – | 128 | 256 | 0.66 | 1.00 | 30 | 2 | 0.70 | (x1+x2+x3+x4+x5+x6+x7+x8+x9+x10+x11+x12+x13+x14+x15) (0.49); (x1+x2+x3+x4+x5+x6+x7+x8+x9+x10+x11+x12+x13+x14+x15) x \|-x17+x30\| (0.26); chi[x1] (0.13) |

chi_frac: the share of the target's non-constant Fourier weight that sits on characters chi_S of the final model at n_max (sum of fhat(S)^2 over them / (1 - fhat(empty)^2); targets with more than 16 relevant inputs have no Fourier table: '–'); n_chi90: first n with chi_frac >= 0.9; span_r2: held-out R^2 of f on the span of the model's features; n_span95: first n with span_r2 >= 0.95; n_chi / n_sum: number of character / sum-block terms at n_max.

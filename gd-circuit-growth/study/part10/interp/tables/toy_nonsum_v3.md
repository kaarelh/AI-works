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
| dlheld | hrf0 | random 7-gate formula on 6 inputs: g6=0or~5; g7=2or6; g8=7an | 5 | – | 60 | – | 256 | 512 | 0.79 | 1.00 | 10 | 5 | 0.80 | chi[x4] (0.63); (-x1+x3+x4+x5-x6) (0.18); chi[x4,x5] (0.18) |
| dlheld | hrf1 | random 7-gate formula on 6 inputs: g6=~2xor~0; g7=6xor~5; g8 | 5 | – | 103 | 256 | 512 | 512 | 0.92 | 0.95 | 41 | 1 | 0.80 | chi[x1,x3,x4,x6] (0.47); chi[x1,x3,x6] (0.46); chi[x1,x6] (0.36) |
| dlheld | hrf2 | random 8-gate formula on 6 inputs: g6=3or5; g7=4xor~6; g8=~7 | 5 | – | 50 | – | 128 | 512 | 0.78 | 0.95 | 2 | 1 | 0.63 | chi[x1] (0.62); (x3-x4+x5-x6-3*x1) (0.42); chi[x1,x4] (0.18) |
| dlheld | inter2 | AND of two Gaussian halfspaces on x1..x10 | 10 | – | 355 | – | – | 8192 | 0.85 | 0.94 | 150 | 8 | 0.48 | chi[x9] (0.32); chi[x3] (0.26); chi[x2] (0.20) |
| dlheld | maj15 | MAJ(x1..x15) | 15 | – | 82 | – | 128 | 256 | 0.66 | 1.00 | 30 | 2 | 0.70 | (x1+x2+x3+x4+x5+x6+x7+x8+x9+x10+x11+x12+x13+x14+x15) (0.49); (x1+x2+x3+x4+x5+x6+x7+x8+x9+x10+x11+x12+x13+x14+x15) x \|-x17+x30\| (0.26); chi[x1] (0.13) |
| dlheld | majmaj5 | MAJ of three MAJ5s | 15 | – | 357 | – | – | 2048 | 0.64 | 0.92 | 29 | 16 | 0.74 | chi[x10]*\|x6+x7+x8+x9\| (0.29); chi[x6] (0.22); chi[x8] (0.19) |
| dlheld | majpar5 | MAJ of five pairs x1x2..x9x10 | 10 | – | 159 | – | – | 1024 | 0.70 | 0.76 | 5 | 1 | 0.84 | chi[x1,x2] (0.40); chi[x5,x6] (0.39); chi[x7,x8] (0.39) |
| dlheld | majxor | MAJ(x1..x5) XOR MAJ(x6..x10) | 10 | – | 223 | – | – | 2048 | 0.50 | 0.85 | 26 | 2 | 0.78 | \|x1+x2+x3+x4+x5-x6-x7-x8-x9-x10\| (0.24); \|x1+x2+x3+x4+x5+x6+x7+x8+x9+x10\| (0.23); chi[x2,x6] (0.14) |
| dlheld | mux6 | 6-multiplexer: address x1 x2, data x3..x6 | 6 | – | 155 | – | 512 | 512 | 0.88 | 0.95 | 14 | 1 | 0.41 | chi[x1,x3] (0.28); chi[x2,x4] (0.27); chi[x2,x6] (0.27) |
| dlheld | par5 | x1 x2 x3 x4 x5 | 5 | – | 61 | 64 | 64 | 256 | 1.00 | 1.00 | 1 | 0 | 0.67 | chi[x1,x2,x3,x4,x5] (1.00) |
| dlheld | stair6 | sign(x1 + x1x2 + ... + x1..x6 + 1/2) | 6 | – | 196 | – | – | 512 | 0.65 | 0.78 | 6 | 1 | 0.92 | chi[x2,x4,x6] (0.32); chi[x1,x2,x3,x4,x5] (0.31); chi[x1,x2,x3] (0.31) |
| dlheld | thr30 | sign(w.x), Gaussian w on all inputs | 30 | – | 136 | – | – | 16384 | – | 0.81 | 59 | 5 | 0.15 | chi[x3] (0.45); chi[x22] (0.31); chi[x19] (0.31) |
| random | rf00 | random 6-gate formula on 5 inputs: g5=~4and~3; g6=~5or1; g7= | 4 | – | 39 | – | 128 | 256 | 0.81 | 1.00 | 3 | 2 | 0.32 | chi[x3] (0.79); (x2+x3+x4+x5) (0.23); chi[x3]*(-x1+x2+x4+x5+x19-x26) (0.14) |
| random | rf01 | random 4-gate formula on 5 inputs: g5=4xor~2; g6=0or5; g7=~6 | 4 | – | 52 | – | 128 | 256 | 0.67 | 1.00 | 2 | 1 | 0.82 | chi[x1,x2] (0.66); (x1-x2-2*x3x5) (0.45); chi[x2] (0.18) |
| random | rf02 | random 7-gate formula on 4 inputs: g4=0xor1; g5=2and~4; g6=~ | 3 | – | 49 | 128 | 64 | 128 | 1.00 | 1.00 | 4 | 0 | 0.83 | chi[x1,x3] (0.48); chi[x2,x3] (0.48); chi[x1,x2] (0.48) |
| random | rf03 | random 5-gate formula on 4 inputs: g4=~3and0; g5=4xor3; g6=~ | 4 | – | 132 | 256 | 256 | 512 | 0.81 | 1.00 | 7 | 2 | 0.69 | chi[x1,x3] (0.54); chi[x1] (0.50); chi[x2] (0.26) |
| random | rf04 | random 7-gate formula on 4 inputs: g4=1xor~3; g5=0and4; g6=5 | 3 | – | 52 | 64 | 64 | 128 | 0.75 | 1.00 | 3 | 1 | 0.37 | chi[x1,x2] (0.52); chi[x1,x4] (0.51); chi[x1] (0.35) |
| random | rf05 | random 5-gate formula on 5 inputs: g5=3or~4; g6=~4or5; g7=~2 | 4 | – | 65 | – | 64 | 256 | 0.69 | 1.00 | 34 | 4 | 0.72 | chi[x2,x3,x5] (0.62); (x2+x3+x5-2*x4) (0.35); chi[x2] (0.24) |
| random | rf06 | random 7-gate formula on 5 inputs: g5=3xor~1; g6=5or2; g7=6o | 5 | – | 16 | – | 128 | 256 | 0.88 | 1.00 | 1 | 3 | 0.37 | chi[x5] (0.88); (x1+x2-x3+x4-x5) (0.16); chi[x5]*\|x1+x2-x3+x4+x7+x14\| (0.12) |
| random | rf07 | random 8-gate formula on 4 inputs: g4=0xor1; g5=~1or2; g6=4a | 4 | – | 73 | – | 128 | 256 | 0.62 | 0.83 | 4 | 1 | 0.39 | (-x1+x2+2*x4x3) (0.55); chi[x1] (0.36); chi[x1,x2] (0.35) |
| random | rf08 | random 8-gate formula on 4 inputs: g4=~2and~1; g5=4and3; g6= | 3 | – | 19 | – | – | 64 | 0.80 | 0.80 | 31 | 0 | 0.53 | chi[x3] (0.66); chi[x2,x4] (0.29); chi[x2] (0.21) |
| random | rf09 | random 8-gate formula on 4 inputs: g4=2xor~1; g5=~1or~2; g6= | 3 | – | 49 | 128 | 128 | 256 | 1.00 | 1.00 | 3 | 0 | 0.80 | chi[x2,x3,x4] (0.50); chi[x4] (0.50); chi[x2,x3] (0.49) |
| random | rf10 | random 8-gate formula on 4 inputs: g4=~0xor~2; g5=~4and~2; g | 3 | – | 35 | – | 64 | 128 | 0.73 | 1.00 | 3 | 1 | 0.31 | chi[x1] (0.80); (x1+x3+x4) (0.41); chi[x3] (0.27) |
| random | rf11 | random 4-gate formula on 4 inputs: g4=0and~2; g5=4and0; g6=3 | 3 | – | 56 | 64 | 64 | 128 | 1.00 | 1.00 | 1 | 0 | 0.98 | chi[x2,x3,x4] (1.00) |
| random | rf12 | random 5-gate formula on 5 inputs: g5=~0or2; g6=5xor~4; g7=2 | 5 | – | 73 | – | 256 | 256 | 0.58 | 1.00 | 4 | 1 | 0.78 | chi[x4] (0.51); chi[x1,x5] (0.35); (x2+x5-3*x4) x (-x3+x4+3*x1x5) (0.28) |
| random | rf13 | random 7-gate formula on 4 inputs: g4=~0xor~3; g5=4xor1; g6= | 3 | – | 34 | 64 | 64 | 128 | 0.67 | 1.00 | 2 | 1 | 0.86 | chi[x1,x2,x4] (0.86); (x1-x2+x4) (0.43); chi[x1] (0.16) |
| random | rf14 | random 5-gate formula on 5 inputs: g5=~1xor~4; g6=~0xor2; g7 | 4 | – | 53 | 64 | 64 | 128 | 1.00 | 1.00 | 4 | 0 | 0.95 | chi[x1,x5] (0.51); chi[x1,x2,x5] (0.50); chi[x2,x3,x5] (0.50) |
| random | rf15 | random 4-gate formula on 4 inputs: g4=~3xor1; g5=~4or3; g6=~ | 3 | – | 23 | – | – | 64 | 0.80 | 0.79 | 31 | 0 | 0.30 | chi[x1] (0.61); chi[x4] (0.35); chi[x1,x4] (0.30) |
| random | rf16 | random 7-gate formula on 4 inputs: g4=~0and~2; g5=4xor~1; g6 | 3 | – | 45 | 64 | 64 | 128 | 1.00 | 1.00 | 3 | 0 | 0.81 | chi[x1,x2,x3] (0.51); chi[x3] (0.50); chi[x1,x2] (0.50) |
| random | rf17 | random 3-gate formula on 5 inputs: g5=~4xor3; g6=~5xor0; g7= | 4 | – | 56 | 64 | 64 | 128 | 1.00 | 1.00 | 1 | 0 | 0.98 | chi[x1,x2,x4,x5] (1.00) |
| random | rf18 | random 3-gate formula on 4 inputs: g4=~0xor3; g5=4or~2; g6=~ | 3 | – | 47 | 64 | 64 | 128 | 1.00 | 1.00 | 4 | 0 | 0.23 | chi[x1] (0.51); chi[x3,x4] (0.50); chi[x4] (0.49) |
| random | rf19 | random 6-gate formula on 4 inputs: g4=~2xor1; g5=4xor3; g6=~ | 4 | – | 56 | – | 128 | 256 | 0.73 | 0.91 | 3 | 1 | 0.87 | chi[x2,x3,x4] (0.62); (x2-x3+x4+3*x1) (0.42); chi[x1,x3,x4] (0.36) |

chi_frac: the share of the target's non-constant Fourier weight that sits on characters chi_S of the final model at n_max (sum of fhat(S)^2 over them / (1 - fhat(empty)^2); targets with more than 16 relevant inputs have no Fourier table: '–'); n_chi90: first n with chi_frac >= 0.9; span_r2: held-out R^2 of f on the span of the model's features; n_span95: first n with span_r2 >= 0.95; n_chi / n_sum: number of character / sum-block terms at n_max.

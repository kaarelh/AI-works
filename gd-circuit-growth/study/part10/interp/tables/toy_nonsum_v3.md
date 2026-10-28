### v3's DFG member on the non-sum suites (seed 0): what carries the model

| suite | target | desc | k | nstar3 | nstar_s0 | n_chi90 | n_span95 | n_max | fourier_chi | span_r2 | n_chi | n_sum | w_dfg | lead |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| designed | and3 | AND(x1,x2,x3) | 3 | 25 | 29 | 256 | 128 | 256 | 0.44 | 1.00 | 7 | 0 | 0.32 | chi[x1,x2,x3] (0.26); chi[x1,x2] (0.26); chi[x2,x3] (0.26) |
| designed | dict | x1 | 1 | 16 | 16 | 16 | 16 | 32 | 1.00 | 1.00 | 1 | 0 | 0.38 | chi[x1] (0.99) |
| designed | dnf3 | (x1&x2&x3) \| (x4&~x5&x6) \| (x7&x8&~x9) | 9 | 118 | 117 | – | – | 512 | 0.51 | 0.87 | 35 | 2 | 0.41 | (-x4+x5-x6) x (-x7-x8+x9-3*AND(x1,x3)) (0.48); (x4-x5+x6) (0.30); chi[x9] (0.24) |
| designed | maj3 | MAJ(x1,x2,x3) | 3 | 31 | 28 | 128 | 128 | 256 | 1.00 | 1.00 | 4 | 0 | 0.32 | chi[x3] (0.50); chi[x1] (0.50); chi[x1,x2,x3] (0.50) |
| designed | maj9 | MAJ(x1..x9) | 9 | 80 | 85 | – | 128 | 256 | 0.67 | 1.00 | 30 | 1 | 0.65 | (x1+x2+x3+x4+x5+x6+x7+x8+x9) (0.65); chi[x1] (0.16); chi[x6] (0.16) |
| designed | majpar | MAJ(x1x2, x3x4, x5x6) | 6 | 60 | 61 | – | 256 | 512 | 0.75 | 1.00 | 3 | 1 | 0.90 | chi[x1,x2] (0.54); chi[x3,x4] (0.54); chi[x5,x6] (0.48) |
| designed | mux | x4 ? x1x2x3 : MAJ(x1,x2,x3) | 4 | 70 | 56 | – | 128 | 256 | 0.88 | 1.00 | 8 | 3 | 0.82 | chi[x1,x2,x3,x4] (0.51); chi[x1,x2,x3] (0.35); chi[x2,x4] (0.27) |
| designed | par2 | x1 x2 | 2 | 16 | 16 | 16 | 16 | 32 | 1.00 | 1.00 | 1 | 0 | 0.94 | chi[x1,x2] (1.00) |
| designed | par3 | x1 x2 x3 | 3 | 55 | 56 | 64 | 64 | 128 | 1.00 | 1.00 | 1 | 0 | 0.99 | chi[x1,x2,x3] (1.00) |
| designed | par4 | x1 x2 x3 x4 | 4 | 56 | 56 | 64 | 64 | 128 | 1.00 | 1.00 | 1 | 0 | 1.00 | chi[x1,x2,x3,x4] (1.00) |
| designed | parmaj | MAJ(x1,x2,x3) XOR MAJ(x4,x5,x6) | 6 | 110 | 111 | – | 128 | 256 | 0.25 | 1.00 | 4 | 2 | 0.99 | \|x1+x2+x3+x4+x5+x6\| (0.62); \|-x1-x2-x3+x4+x5+x6\| (0.59); chi[x1,x5] (0.08) |
| designed | stair5 | sign(x1 + x1x2 + ... + x1..x5) | 5 | 109 | 107 | – | 256 | 256 | 0.73 | 0.97 | 7 | 3 | 0.82 | chi[x1,x2,x3] (0.42); chi[x1,x2,x3,x4] (0.40); chi[x1,x3,x5] (0.36) |
| designed | thr10 | sign(w.x[1..10]), Gaussian w | 10 | 121 | 111 | 2048 | 2048 | 4096 | 0.96 | 0.99 | 209 | 3 | 0.42 | chi[x10] (0.40); chi[x1] (0.31); chi[x7] (0.30) |

fourier_chi: the target's Fourier weight on the characters chi_S in the final model at n_max (sum of fhat(S)^2; 1 = all of f); n_chi90: first n with fourier_chi >= 0.9 of the non-constant weight; span_r2: held-out R^2 of f on the span of the model's features; n_span95: first n with span_r2 >= 0.95; n_chi / n_sum: number of character / sum-block terms at n_max.

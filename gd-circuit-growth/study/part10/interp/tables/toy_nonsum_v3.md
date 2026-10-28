### v3's DFG member on the non-sum suites (seed 0): what carries the model

| suite | target | desc | k | nstar3 | nstar_s0 | n_chi90 | n_span95 | n_max | fourier_chi | span_r2 | n_chi | n_sum | w_dfg | lead |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| designed | and3 | AND(x1,x2,x3) | 3 | 25 | 29 | 256 | 128 | 256 | 0.44 | 1.00 | 7 | 0 | 0.32 | chi[x1,x2,x3] (0.26); chi[x1,x2] (0.26); chi[x2,x3] (0.26) |
| designed | dict | x1 | 1 | 16 | 16 | 16 | 16 | 32 | 1.00 | 1.00 | 1 | 0 | 0.38 | chi[x1] (0.99) |
| designed | maj3 | MAJ(x1,x2,x3) | 3 | 31 | 28 | 128 | 128 | 256 | 1.00 | 1.00 | 4 | 0 | 0.32 | chi[x3] (0.50); chi[x1] (0.50); chi[x1,x2,x3] (0.50) |
| designed | maj9 | MAJ(x1..x9) | 9 | 80 | 85 | – | 128 | 256 | 0.67 | 1.00 | 30 | 1 | 0.65 | (x1+x2+x3+x4+x5+x6+x7+x8+x9) (0.65); chi[x1] (0.16); chi[x6] (0.16) |

fourier_chi: the target's Fourier weight on the characters chi_S in the final model at n_max (sum of fhat(S)^2; 1 = all of f); n_chi90: first n with fourier_chi >= 0.9 of the non-constant weight; span_r2: held-out R^2 of f on the span of the model's features; n_span95: first n with span_r2 >= 0.95; n_chi / n_sum: number of character / sum-block terms at n_max.

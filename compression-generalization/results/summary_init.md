# Initialization study

## MNIST, 784-256-10, codes relative to the initialization vs relative to zero

Each row: one trained f and code family, best over its compression configurations (union-bound corrected for the disagreement term; design charge of accounting.py). T1 = Occam bound on g; T2 = bound on f with unlabeled test inputs.

| init | init scale | code ref | test err f | best T1 | bits (T1) | best T2 | bits (T2) |
|---|---|---|---|---|---|---|---|
| random | 0.3 | init | 0.0199 | 0.3840 | 34417 | 0.4066 | 34417 |
| random | 1.0 | init | 0.0197 | 0.3670 | 32260 | 0.3910 | 32260 |
| random | 1.0 | zero | 0.0197 | 0.3772 | 34091 | 0.3991 | 34091 |

## Boolean, n = 30, one hidden layer of 512: init-kernel codec vs distillation codec

`move` = ||theta - theta0|| / ||theta0||; `lin dis` = Pr[sign of linearized f != sign of f]. Init-kernel codec: theta0 + top-r eigenvectors of the uniform-input empirical NTK at theta0 (free), r coefficients coded.

| task | regime | m | test err f | move | lin dis | kernel codec: r | bits | bound on f | distillation codec: bits | bound on f | g |
|---|---|---|---|---|---|---|---|---|---|---|---|
| fullmaj | lazy | 1000 | 0.0387 | 0.11 | 0.015 | 31 | 201 | 0.2528 | 51 | 0.0800 | mlp k=30 widths=[30, 1] rel=0.5 |
| fullmaj | lazy | 4000 | 0.0039 | 0.17 | 0.032 | 31 | 237 | 0.1434 | 43 | 0.0134 | mlp k=30 widths=[30, 1] rel=0.5 |
| fullmaj | rich | 1000 | 0.0000 | 4.57 | 0.346 | 16 | 120 | 0.8210 | 43 | 0.0356 | mlp k=30 widths=[30, 1] rel=0.5 |
| fullmaj | rich | 4000 | 0.0000 | 4.71 | 0.277 | 31 | 192 | 0.5018 | 43 | 0.0091 | mlp k=30 widths=[30, 1] rel=0.5 |
| maj5 | lazy | 1000 | 0.0010 | 0.09 | 0.002 | 31 | 204 | 0.1583 | 37 | 0.0328 | mlp k=5 widths=[5, 1] rel=0.5 |
| maj5 | lazy | 4000 | 0.0003 | 0.09 | 0.001 | 31 | 210 | 0.0516 | 37 | 0.0086 | mlp k=5 widths=[5, 1] rel=0.5 |
| maj5 | rich | 1000 | 0.0000 | 3.32 | 0.080 | 31 | 166 | 0.2882 | 37 | 0.0317 | mlp k=5 widths=[5, 1] rel=0.5 |
| maj5 | rich | 4000 | 0.0000 | 3.98 | 0.197 | 31 | 209 | 0.2966 | 37 | 0.0080 | mlp k=5 widths=[5, 1] rel=0.5 |
| parity2 | lazy | 1000 | 0.0181 | 0.17 | 0.168 | 466 | 1515 | 0.9400 | 20 | 0.0388 | table k=2 |
| parity2 | lazy | 4000 | 0.0003 | 0.18 | 0.133 | 466 | 1520 | 0.5913 | 20 | 0.0056 | table k=2 |
| parity2 | rich | 1000 | 0.0000 | 3.58 | 0.434 | 2048 | 8226 | 1.0000 | 20 | 0.0203 | table k=2 |
| parity2 | rich | 4000 | 0.0000 | 3.53 | 0.410 | 2048 | 6090 | 0.7720 | 20 | 0.0051 | table k=2 |

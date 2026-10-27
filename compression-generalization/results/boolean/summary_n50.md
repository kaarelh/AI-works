# Boolean grid `n50`: bounds on the trained network f

Each row averages 3 seeds (training sets and initializations). `test err f`: exact (n = 20, all 2^20 inputs) or on 3x10^5 fresh inputs. `bound on f`: Theorem 2 with delta = 0.05 (Occam term for g plus an upper bound on Pr[f != g] under the uniform input distribution), including the design charge of accounting.py (4 bits, disagreement at delta/16). `bits`: description length of g. `float32 Occam` and `VC (d = #params)`: parameter-counting baselines for f itself. Every bound is a valid upper bound for its own seed; the table shows means.

| task | m | test err f | bound on f | Occam part | Pr[f≠g] part | bits | best g (seed 0) | float32 Occam | VC (d=#params) |
|---|---|---|---|---|---|---|---|---|---|
| and3 | 500 | 0.0366 | 0.0875 | 0.0445 | 0.0373 | 28 | table k=3 | 1.00 | 1.00 |
| and3 | 1000 | 0.0056 | 0.0312 | 0.0225 | 0.0058 | 28 | table k=3 | 1.00 | 1.00 |
| and3 | 2000 | 0.0000 | 0.0128 | 0.0113 | 0.0001 | 28 | table k=3 | 1.00 | 1.00 |
| and3 | 4000 | 0.0000 | 0.0064 | 0.0057 | 0.0000 | 28 | table k=3 | 1.00 | 1.00 |
| and3 | 8000 | 0.0000 | 0.0032 | 0.0028 | 0.0000 | 28 | table k=3 | 1.00 | 1.00 |
| and3 | 16000 | 0.0000 | 0.0016 | 0.0014 | 0.0000 | 28 | table k=3 | 1.00 | 1.00 |
| fullmaj | 500 | 0.0656 | 0.2609 | 0.1980 | 0.0574 | 99 | mlp k=50 widths=[50, 1] rel=0.5 | 1.00 | 1.00 |
| fullmaj | 1000 | 0.0386 | 0.1056 | 0.0634 | 0.0391 | 73 | mlp k=50 widths=[50, 1] rel=0.5 | 1.00 | 1.00 |
| fullmaj | 2000 | 0.0272 | 0.0688 | 0.0394 | 0.0276 | 90 | mlp k=50 widths=[50, 1] rel=0.5 | 1.00 | 1.00 |
| fullmaj | 4000 | 0.0148 | 0.0267 | 0.0105 | 0.0153 | 56 | mlp k=50 widths=[50, 1] rel=0.5 | 1.00 | 1.00 |
| fullmaj | 8000 | 0.0046 | 0.0096 | 0.0043 | 0.0048 | 44 | mlp k=50 widths=[50, 1] rel=0.5 | 1.00 | 1.00 |
| fullmaj | 16000 | 0.0011 | 0.0037 | 0.0021 | 0.0014 | 44 | mlp k=50 widths=[50, 1] rel=0.5 | 1.00 | 1.00 |
| junta6 | 500 | 0.4005 | 0.9364 | 0.5888 | 0.3379 | 57 | table k=2 | 1.00 | 1.00 |
| junta6 | 1000 | 0.3111 | 0.6451 | 0.3508 | 0.2890 | 74 | table k=5 | 1.00 | 1.00 |
| junta6 | 2000 | 0.1685 | 0.3422 | 0.1984 | 0.1408 | 98 | table k=6 | 1.00 | 1.00 |
| junta6 | 4000 | 0.0223 | 0.0418 | 0.0178 | 0.0230 | 98 | table k=6 | 1.00 | 1.00 |
| junta6 | 8000 | 0.0004 | 0.0097 | 0.0089 | 0.0004 | 98 | table k=6 | 1.00 | 1.00 |
| junta6 | 16000 | 0.0000 | 0.0047 | 0.0045 | 0.0000 | 98 | table k=6 | 1.00 | 1.00 |
| maj5 | 500 | 0.0109 | 0.0910 | 0.0740 | 0.0116 | 50 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 |
| maj5 | 1000 | 0.0002 | 0.0373 | 0.0343 | 0.0003 | 45 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 |
| maj5 | 2000 | 0.0001 | 0.0188 | 0.0173 | 0.0001 | 45 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 |
| maj5 | 4000 | 0.0000 | 0.0095 | 0.0087 | 0.0001 | 45 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 |
| maj5 | 8000 | 0.0000 | 0.0047 | 0.0044 | 0.0000 | 45 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 |
| maj5 | 16000 | 0.0000 | 0.0024 | 0.0022 | 0.0000 | 45 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 |
| parity3 | 500 | 0.4982 | 0.9695 | 0.6211 | 0.3461 | 83 | table k=1 | 1.00 | 1.00 |
| parity3 | 1000 | 0.4964 | 1.0000 | 0.6910 | 0.3505 | 221 | mlp k=47 widths=[47, 1] rel=0.5 | 1.00 | 1.00 |
| parity3 | 2000 | 0.2876 | 0.3043 | 0.0126 | 0.2894 | 31 | table k=3 | 1.00 | 1.00 |
| parity3 | 4000 | 0.0000 | 0.0070 | 0.0063 | 0.0000 | 31 | table k=3 | 1.00 | 1.00 |
| parity3 | 8000 | 0.0000 | 0.0035 | 0.0032 | 0.0000 | 31 | table k=3 | 1.00 | 1.00 |
| parity3 | 16000 | 0.0000 | 0.0018 | 0.0016 | 0.0000 | 31 | table k=3 | 1.00 | 1.00 |
| maj5 (label noise 0.1) | 1000 | 0.1997 | 0.3352 | 0.2043 | 0.1259 | 56 | table k=5 | 1.00 | 1.00 |
| maj5 (label noise 0.1) | 2000 | 0.2088 | 0.3050 | 0.1636 | 0.1379 | 49 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 |
| maj5 (label noise 0.1) | 4000 | 0.1696 | 0.2376 | 0.1471 | 0.0881 | 56 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 |
| maj5 (label noise 0.1) | 8000 | 0.1382 | 0.1780 | 0.1275 | 0.0488 | 49 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 |
| maj5 (label noise 0.1) | 16000 | 0.1390 | 0.1741 | 0.1232 | 0.0496 | 49 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 |
| parity3 (label noise 0.1) | 1000 | 0.4987 | 1.0000 | 0.6948 | 0.3510 | 214 | mlp k=50 widths=[50, 1] rel=0.5 | 1.00 | 1.00 |
| parity3 (label noise 0.1) | 2000 | 0.4786 | 1.0000 | 0.6318 | 0.3901 | 224 | mlp k=50 widths=[50, 1] rel=0.5 | 1.00 | 1.00 |
| parity3 (label noise 0.1) | 4000 | 0.1708 | 0.2275 | 0.1345 | 0.0902 | 31 | table k=3 | 1.00 | 1.00 |
| parity3 (label noise 0.1) | 8000 | 0.1365 | 0.1698 | 0.1213 | 0.0465 | 31 | table k=3 | 1.00 | 1.00 |
| parity3 (label noise 0.1) | 16000 | 0.1362 | 0.1665 | 0.1189 | 0.0461 | 31 | table k=3 | 1.00 | 1.00 |

Runs: 120. Bound below 0.5 (non-vacuous for a binary task): 102. Runs where the bound is below the measured test error: 0.
Network f: widths [50, 512, 512, 1], [289281] parameters; Adam, lr 0.001, batch 64, trained to zero training error and mean training loss <= 0.01.

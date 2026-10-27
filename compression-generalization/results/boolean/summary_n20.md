# Boolean grid `n20`: bounds on the trained network f

Each row averages 3 seeds (training sets and initializations). `test err f`: exact (n = 20, all 2^20 inputs) or on 3x10^5 fresh inputs. `bound on f`: Theorem 2 with delta = 0.05 (Occam term for g plus an upper bound on Pr[f != g] under the uniform input distribution), including the design charge of accounting.py (4 bits, disagreement at delta/16). `bits`: description length of g. `float32 Occam` and `VC (d = #params)`: parameter-counting baselines for f itself. Every bound is a valid upper bound for its own seed; the table shows means.

| task | m | test err f | bound on f | Occam part | Pr[f≠g] part | bits | best g (seed 0) | float32 Occam | VC (d=#params) | any-D bound |
|---|---|---|---|---|---|---|---|---|---|---|
| fullmaj | 4000 | 0.0000 | 0.0078 | 0.0071 | 0.0000 | 37 | mlp k=20 widths=[20, 1] rel=0.5 | 1.00 | 1.00 | 0.0236 |
| junta6 | 2000 | 0.0041 | 0.0374 | 0.0320 | 0.0041 | 89 | table k=6 | 1.00 | 1.00 | 1.0000 |
| junta6 | 4000 | 0.0000 | 0.0168 | 0.0161 | 0.0000 | 89 | table k=6 | 1.00 | 1.00 | 0.0184 |
| maj5 | 100 | 0.0700 | 0.3870 | 0.2978 | 0.0700 | 47 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 | 1.0000 |
| maj5 | 250 | 0.0022 | 0.1225 | 0.1105 | 0.0022 | 38 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 | 1.0000 |
| maj5 | 500 | 0.0000 | 0.0621 | 0.0569 | 0.0000 | 38 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 | 0.1237 |
| maj5 | 1000 | 0.0000 | 0.0315 | 0.0289 | 0.0000 | 38 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 | 0.0431 |
| maj5 | 2000 | 0.0000 | 0.0159 | 0.0145 | 0.0000 | 38 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 | 0.0166 |
| maj5 | 4000 | 0.0000 | 0.0080 | 0.0073 | 0.0000 | 38 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 | 0.0083 |
| parity3 | 100 | 0.4933 | 0.9631 | 0.6564 | 0.2869 | 29 | table k=4 | 1.00 | 1.00 | 1.0000 |
| parity3 | 250 | 0.4507 | 0.9118 | 0.6938 | 0.2439 | 445 | mlp k=20 widths=[20, 16, 1] rel=0.5 | 1.00 | 1.00 | 1.0000 |
| parity3 | 500 | 0.1834 | 0.2773 | 0.0898 | 0.1813 | 27 | table k=3 | 1.00 | 1.00 | 1.0000 |
| parity3 | 1000 | 0.0000 | 0.0242 | 0.0215 | 0.0000 | 27 | table k=3 | 1.00 | 1.00 | 0.0545 |
| parity3 | 2000 | 0.0000 | 0.0122 | 0.0108 | 0.0000 | 27 | table k=3 | 1.00 | 1.00 | 0.0129 |
| parity3 | 4000 | 0.0000 | 0.0061 | 0.0054 | 0.0000 | 27 | table k=3 | 1.00 | 1.00 | 0.0065 |

Runs: 43. Bound below 0.5 (non-vacuous for a binary task): 37. Runs where the bound is below the measured test error: 0.
Network f: widths [20, 512, 512, 1], [273921] parameters; Adam, lr 0.001, batch 64, trained to zero training error and mean training loss <= 0.01.

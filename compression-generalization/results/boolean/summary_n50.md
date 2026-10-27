# Boolean grid `n50`: bounds on the trained network f

Each row averages 3 seeds (training sets and initializations). `test err f`: exact (n = 20, all 2^20 inputs) or on 3x10^5 fresh inputs. `bound on f`: Theorem 2 with delta = 0.05 (Occam term for g plus an upper bound on Pr[f != g] under the uniform input distribution). `bits`: description length of g. `float32 Occam` and `VC (d = #params)`: parameter-counting baselines for f itself. Every bound is a valid upper bound for its own seed; the table shows means.

| task | m | test err f | bound on f | Occam part | Pr[f≠g] part | bits | best g (seed 0) | float32 Occam | VC (d=#params) |
|---|---|---|---|---|---|---|---|---|---|
| and3 | 4000 | 0.0000 | 0.0057 | 0.0057 | 0.0000 | 28 | table k=3 | 1.00 | 1.00 |
| and3 | 8000 | 0.0000 | 0.0029 | 0.0028 | 0.0000 | 28 | table k=3 | 1.00 | 1.00 |
| and3 | 16000 | 0.0000 | 0.0014 | 0.0014 | 0.0000 | 28 | table k=3 | 1.00 | 1.00 |
| fullmaj | 4000 | 0.0148 | 0.0258 | 0.0105 | 0.0153 | 56 | mlp k=50 widths=[50, 1] rel=0.5 | 1.00 | 1.00 |
| fullmaj | 8000 | 0.0046 | 0.0091 | 0.0043 | 0.0048 | 44 | mlp k=50 widths=[50, 1] rel=0.5 | 1.00 | 1.00 |
| fullmaj | 16000 | 0.0011 | 0.0035 | 0.0021 | 0.0014 | 44 | mlp k=50 widths=[50, 1] rel=0.5 | 1.00 | 1.00 |
| junta6 | 4000 | 0.0223 | 0.0408 | 0.0178 | 0.0230 | 98 | table k=6 | 1.00 | 1.00 |
| junta6 | 8000 | 0.0004 | 0.0094 | 0.0089 | 0.0004 | 98 | table k=6 | 1.00 | 1.00 |
| junta6 | 16000 | 0.0000 | 0.0045 | 0.0045 | 0.0000 | 98 | table k=6 | 1.00 | 1.00 |
| maj5 | 4000 | 0.0000 | 0.0087 | 0.0087 | 0.0001 | 45 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 |
| maj5 | 8000 | 0.0000 | 0.0044 | 0.0044 | 0.0000 | 45 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 |
| maj5 | 16000 | 0.0000 | 0.0022 | 0.0022 | 0.0000 | 45 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 |
| parity3 | 4000 | 0.0000 | 0.0063 | 0.0063 | 0.0000 | 31 | table k=3 | 1.00 | 1.00 |
| parity3 | 8000 | 0.0000 | 0.0032 | 0.0032 | 0.0000 | 31 | table k=3 | 1.00 | 1.00 |
| parity3 | 16000 | 0.0000 | 0.0016 | 0.0016 | 0.0000 | 31 | table k=3 | 1.00 | 1.00 |
| maj5 (label noise 0.1) | 8000 | 0.1382 | 0.1763 | 0.1275 | 0.0488 | 49 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 |
| maj5 (label noise 0.1) | 16000 | 0.1390 | 0.1727 | 0.1232 | 0.0496 | 49 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 |
| parity3 (label noise 0.1) | 8000 | 0.1365 | 0.1679 | 0.1213 | 0.0465 | 31 | table k=3 | 1.00 | 1.00 |
| parity3 (label noise 0.1) | 16000 | 0.1362 | 0.1650 | 0.1189 | 0.0461 | 31 | table k=3 | 1.00 | 1.00 |

Runs: 57. Bound below 0.5 (non-vacuous for a binary task): 57. Runs where the bound is below the measured test error: 0.
Network f: widths [50, 512, 512, 1], [289281] parameters; Adam, lr 0.001, batch 64, trained to zero training error and mean training loss <= 0.01.

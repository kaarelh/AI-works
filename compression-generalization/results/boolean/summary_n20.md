# Boolean grid `n20`: bounds on the trained network f

Each row averages 3 seeds (training sets and initializations). `test err f`: exact (n = 20, all 2^20 inputs) or on 3x10^5 fresh inputs. `bound on f`: Theorem 2 with delta = 0.05 (Occam term for g plus an upper bound on Pr[f != g] under the uniform input distribution), including the design charge of accounting.py (4 bits, disagreement at delta/16). `bits`: description length of g. `float32 Occam` and `VC (d = #params)`: parameter-counting baselines for f itself. Every bound is a valid upper bound for its own seed; the table shows means.

| task | m | test err f | bound on f | Occam part | Pr[f≠g] part | bits | best g (seed 0) | float32 Occam | VC (d=#params) | any-D bound |
|---|---|---|---|---|---|---|---|---|---|---|
| fullmaj | 4000 | 0.0000 | 0.0078 | 0.0071 | 0.0000 | 37 | mlp k=20 widths=[20, 1] rel=0.5 | 1.00 | 1.00 | 0.0277 |
| junta6 | 4000 | 0.0000 | 0.0168 | 0.0161 | 0.0000 | 89 | table k=6 | 1.00 | 1.00 | 0.0191 |
| maj5 | 4000 | 0.0000 | 0.0080 | 0.0073 | 0.0000 | 38 | mlp k=5 widths=[5, 1] rel=0.5 | 1.00 | 1.00 | 0.0083 |
| parity3 | 4000 | 0.0000 | 0.0061 | 0.0054 | 0.0000 | 27 | table k=3 | 1.00 | 1.00 | 0.0065 |

Runs: 9. Bound below 0.5 (non-vacuous for a binary task): 9. Runs where the bound is below the measured test error: 0.
Network f: widths [20, 512, 512, 1], [273921] parameters; Adam, lr 0.001, batch 64, trained to zero training error and mean training loss <= 0.01.

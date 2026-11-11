## hyb_portfolio-perm on the dlheld5 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h5s0 | 11042 | never | -inf | 0.32 / 0.23 / 0.14 / 0.12 ; – | 7.3e-01 |
| h5s1 | never | never | +nan | 0.50 / 0.50 / 0.50 / 0.49 ; – | 2.1e-01 |
| h5s2 | 4409 | never | -inf | 0.35 / 0.34 / 0.34 / 0.11 ; – | 3.2e-01 |
| h5s3 | never | never | +nan | 0.46 / 0.45 / 0.44 / 0.40 ; – | 2.0e-01 |
| h5s4 | 415 | never | -inf | 0.22 / 0.18 / 0.03 / 0.00 ; – | 2.1e-01 |
| h5s5 | never | never | +nan | 0.42 / 0.35 / 0.35 / 0.40 ; – | 2.1e-01 |
| h5s6 | never | never | +nan | 0.37 / 0.36 / 0.36 / 0.40 ; – | 7.6e-01 |
| h5s7 | never | never | +nan | 0.38 / 0.38 / 0.37 / 0.37 ; – | 2.2e-01 |
| h5t0 | 146 | never | -inf | 0.27 / 0.02 / 0.00 / 0.00 ; – | 2.0e-01 |
| h5t1 | 116 | never | -inf | 0.19 / 0.01 / 0.00 / 0.00 ; – | 1.9e-01 |
| h5rf0 | 311 | never | -inf | 0.13 / 0.12 / 0.00 / 0.00 ; – | 1.9e-01 |
| h5rf1 | 101 | never | -inf | 0.26 / 0.00 / 0.00 / 0.00 ; – | 1.9e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 7; clearly worse: 0; of 12. Largest compute used: 7.6e-01 of a GD run.


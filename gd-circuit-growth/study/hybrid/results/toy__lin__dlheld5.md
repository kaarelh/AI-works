## lin on the dlheld5 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h5s0 | never | never | +nan | 0.35 / 0.22 / 0.15 / 0.15 ; – | 7.3e-02 |
| h5s1 | never | never | +nan | 0.50 / 0.50 / 0.50 / 0.50 ; – | 7.3e-02 |
| h5s2 | never | never | +nan | 0.34 / 0.34 / 0.34 / 0.34 ; – | 7.3e-02 |
| h5s3 | never | never | +nan | 0.45 / 0.46 / 0.44 / 0.44 ; – | 7.3e-02 |
| h5s4 | never | never | +nan | 0.25 / 0.20 / 0.19 / 0.21 ; – | 7.3e-02 |
| h5s5 | never | never | +nan | 0.40 / 0.34 / 0.34 / 0.33 ; – | 7.3e-02 |
| h5s6 | never | never | +nan | 0.36 / 0.37 / 0.36 / 0.36 ; – | 7.3e-02 |
| h5s7 | never | never | +nan | 0.37 / 0.37 / 0.37 / 0.37 ; – | 7.3e-02 |
| h5t0 | never | never | +nan | 0.32 / 0.27 / 0.27 / 0.27 ; – | 7.3e-02 |
| h5t1 | never | never | +nan | 0.36 / 0.32 / 0.31 / 0.31 ; – | 7.3e-02 |
| h5rf0 | never | never | +nan | 0.48 / 0.45 / 0.40 / 0.37 ; – | 7.3e-02 |
| h5rf1 | never | never | +nan | 0.26 / 0.25 / 0.26 / 0.26 ; – | 7.3e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 0. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 0; clearly worse: 0; of 12. Largest compute used: 7.3e-02 of a GD run.


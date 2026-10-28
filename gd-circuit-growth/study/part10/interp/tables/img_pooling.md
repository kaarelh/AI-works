# Pooling sets S_i(k) on the true grid

Source files: $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n1000__s0.json (and the .npz next to each).

| learner | dataset | n | k | mean Chebyshev dist. of members | frac. within 1 | frac. within 2 | 95th pct dist. | max dist. | overlap with k nearest |
|---|---|---|---|---|---|---|---|---|---|
| v3 | qd_dev | 1000 | 4 | 0.78 | 0.9874 | 0.9993 | 1.0 | 25 | 0.8073 |
| v3 | qd_dev | 1000 | 9 | 1.182 | 0.8424 | 0.987 | 2.0 | 25 | 0.8632 |
| v3 | qd_dev | 1000 | 16 | 2.451 | 0.5207 | 0.8292 | 5.0 | 25 | 0.7639 |

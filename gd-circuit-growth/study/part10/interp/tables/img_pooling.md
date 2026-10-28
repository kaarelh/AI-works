# Pooling sets S_i(k) on the true grid

Source files: $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n1000__s0.json (and the .npz next to each).

| learner | dataset | n | k | mean Chebyshev dist. of members | frac. within 1 | frac. within 2 | 95th pct dist. | max dist. | overlap with k nearest |
|---|---|---|---|---|---|---|---|---|---|
| v3 | qd_dev | 1000 | 4 | 0.78 | 0.9874 | 0.9993 | 1.0 | 25 | 0.8073 |
| v3 | qd_dev | 1000 | 9 | 1.182 | 0.8424 | 0.987 | 2.0 | 25 | 0.8632 |
| v3 | qd_dev | 1000 | 16 | 2.451 | 0.5207 | 0.8292 | 5.0 | 25 | 0.7639 |
| v3 | qd_dev | 10000 | 4 | 0.755 | 0.9952 | 1.0 | 1.0 | 2 | 0.8243 |
| v3 | qd_dev | 10000 | 9 | 1.067 | 0.8521 | 0.9949 | 2.0 | 25 | 0.8775 |
| v3 | qd_dev | 10000 | 16 | 2.195 | 0.5232 | 0.8445 | 4.0 | 25 | 0.7815 |

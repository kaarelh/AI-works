# Pooling sets S_i(k) on the true grid

Source files: $SCRATCH/p10/interp_out_final/image/v2/qd_dev__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/fashion_mnist__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/mnist__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_a__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n1000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n3000__s0.json (and the .npz next to each).

| learner | dataset | n | k | mean Chebyshev dist. of members | frac. within 1 | frac. within 2 | 95th pct dist. | max dist. | overlap with k nearest | members > 2 steps away / of which mirror pixels (row +-1, c + c' = 27 +- 2) |
|---|---|---|---|---|---|---|---|---|---|---|
| v3 | qd_dev | 1000 | 4 | 0.78 | 0.9874 | 0.9993 | 1.0 | 25 | 0.8073 | 2 / 0 |
| v3 | qd_dev | 1000 | 9 | 1.182 | 0.8424 | 0.987 | 2.0 | 25 | 0.8632 | 79 / 25 |
| v3 | qd_dev | 1000 | 16 | 2.451 | 0.5207 | 0.8292 | 5.0 | 25 | 0.7639 | 1847 / 442 |
| v3 | qd_dev | 3000 | 4 | 0.757 | 0.9933 | 1.0 | 1.0 | 2 | 0.8203 | 0 / 0 |
| v3 | qd_dev | 3000 | 9 | 1.095 | 0.8483 | 0.9924 | 2.0 | 25 | 0.8723 | 46 / 17 |
| v3 | qd_dev | 3000 | 16 | 2.282 | 0.5222 | 0.8401 | 4.0 | 25 | 0.7749 | 1730 / 400 |
| v3 | qd_dev | 10000 | 4 | 0.755 | 0.9952 | 1.0 | 1.0 | 2 | 0.8243 | 0 / 0 |
| v3 | qd_dev | 10000 | 9 | 1.067 | 0.8521 | 0.9949 | 2.0 | 25 | 0.8775 | 31 / 14 |
| v3 | qd_dev | 10000 | 16 | 2.195 | 0.5232 | 0.8445 | 4.0 | 25 | 0.7815 | 1682 / 403 |
| v3 | fashion_mnist | 10000 | 4 | 1.008 | 0.9104 | 0.9793 | 2.0 | 27 | 0.6929 | 65 / 65 |
| v3 | fashion_mnist | 10000 | 9 | 2.238 | 0.6739 | 0.8574 | 11.0 | 27 | 0.6932 | 1006 / 619 |
| v3 | fashion_mnist | 10000 | 16 | 3.427 | 0.4715 | 0.7094 | 17.849999999998545 | 27 | 0.6674 | 3645 / 1740 |
| v3 | mnist | 10000 | 4 | 0.84 | 0.982 | 0.9916 | 1.0 | 16 | 0.7713 | 23 / 0 |
| v3 | mnist | 10000 | 9 | 1.295 | 0.8104 | 0.9697 | 2.0 | 19 | 0.8317 | 186 / 0 |
| v3 | mnist | 10000 | 16 | 2.169 | 0.5165 | 0.8723 | 6.0 | 19 | 0.7502 | 1394 / 36 |
| v3 | qd_a | 10000 | 4 | 0.751 | 0.9989 | 1.0 | 1.0 | 2 | 0.8291 | 0 / 0 |
| v3 | qd_a | 10000 | 9 | 1.108 | 0.8371 | 0.9903 | 2.0 | 25 | 0.8596 | 59 / 33 |
| v3 | qd_a | 10000 | 16 | 2.26 | 0.5302 | 0.8124 | 5.0 | 25 | 0.7663 | 2029 / 679 |
| v2 | qd_dev | 10000 | 4 | 0.755 | 0.9952 | 1.0 | 1.0 | 2 | 0.8243 | 0 / 0 |
| v2 | qd_dev | 10000 | 9 | 1.067 | 0.8521 | 0.9949 | 2.0 | 25 | 0.8775 | 31 / 14 |
| v2 | qd_dev | 10000 | 16 | 2.195 | 0.5232 | 0.8445 | 4.0 | 25 | 0.7815 | 1682 / 403 |

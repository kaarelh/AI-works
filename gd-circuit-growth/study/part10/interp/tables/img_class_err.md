# Per-class test error, v3 vs v2 (same test points)

Source files: $SCRATCH/p10/interp_out_final/image/v2/qd_dev__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/fashion_mnist__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/mnist__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_a__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n1000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n3000__s0.json (and the .npz next to each).

| dataset | n | class | v2 err | v3 err | v3 - v2 | ggbt alone (v3 fit) | cgbt alone (v3 fit) |
|---|---|---|---|---|---|---|---|
| qd_dev | 10000 | ocean | 0.087 | 0.084 | -0.003 | 0.103 | 0.096 |
| qd_dev | 10000 | motorbike | 0.110 | 0.095 | -0.015 | 0.126 | 0.105 |
| qd_dev | 10000 | matches | 0.269 | 0.247 | -0.022 | 0.288 | 0.254 |
| qd_dev | 10000 | grapes | 0.280 | 0.243 | -0.037 | 0.262 | 0.229 |
| qd_dev | 10000 | paper clip | 0.138 | 0.134 | -0.004 | 0.156 | 0.141 |
| qd_dev | 10000 | campfire | 0.200 | 0.158 | -0.042 | 0.201 | 0.155 |
| qd_dev | 10000 | washing machine | 0.060 | 0.055 | -0.005 | 0.074 | 0.061 |
| qd_dev | 10000 | soccer ball | 0.082 | 0.075 | -0.007 | 0.092 | 0.075 |
| qd_dev | 10000 | frying pan | 0.121 | 0.119 | -0.002 | 0.155 | 0.129 |
| qd_dev | 10000 | foot | 0.120 | 0.120 | +0.000 | 0.121 | 0.123 |
| qd_dev | 10000 | **all** | 0.1467 | 0.1330 | -0.0137 |  |  |

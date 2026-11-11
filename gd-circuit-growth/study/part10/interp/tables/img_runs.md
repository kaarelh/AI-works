# Image analysis runs: test error vs the evaluation cell

Source files: $SCRATCH/p10/interp_out_final/image/v2/qd_dev__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/fashion_mnist__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/mnist__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_a__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n1000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n3000__s0.json (and the .npz next to each).

| learner | dataset | n | seed | test err (analysis fit) | test err (evaluation cell) | equal | stacker oof err | fit CPU s | cell file |
|---|---|---|---|---|---|---|---|---|---|
| v3 | qd_dev | 1000 | 0 | 0.2118 | 0.2118 | yes | 0.2290 | 261.8 | $SCRATCH/p9/cells/p10_codes-dev__qd_dev/n1000_s0.json |
| v3 | qd_dev | 3000 | 0 | 0.1753 | – | no cell | 0.1887 | 535.9 | – |
| v3 | qd_dev | 10000 | 0 | 0.1330 | 0.1330 | yes | 0.1425 | 526.2 | $SCRATCH/p9/cells/p10_codes-dev__qd_dev/n10000_s0.json |
| v3 | fashion_mnist | 10000 | 0 | 0.1238 | 0.1238 | yes | 0.1246 | 670.5 | $SCRATCH/p9/cells/p10_codes-dev__fashion_mnist/n10000_s0.json |
| v3 | mnist | 10000 | 0 | 0.0255 | – | no cell | 0.0270 | 336.2 | – |
| v3 | qd_a | 10000 | 0 | 0.1422 | 0.1422 | yes | 0.1530 | 421.8 | $SCRATCH/p9/cells/p10_codes-dev__qd_a/n10000_s0.json |
| v2 | qd_dev | 10000 | 0 | 0.1467 | 0.1463 | **NO** | 0.1445 | 355.6 | $SCRATCH/p9/cells/hyb_portfolio2__qd_dev/n10000_s0.json |

The evaluation cells' own records (`info` in the cell file) next to the analysis fits:

| learner | dataset | n | source | test err | ggbt rounds | stacker oof err | ggbt oof err | cgbt oof err | total weight | weight share by family |
|---|---|---|---|---|---|---|---|---|---|---|
| v3 | qd_dev | 10000 | evaluation cell | 0.1330 | [123] | 0.1425 | 0.1610 | 0.1495 | 0.727 | cgbt:0.470 ggbt:0.074 gknn:0.166 knn:0.254 gbt+et:0.034 |
| v3 | qd_dev | 10000 | analysis fit | 0.1330 | [123] | 0.1425 | 0.1610 | 0.1495 | 0.727 | cgbt:0.470 ggbt:0.074 gknn:0.166 knn:0.254 gbt+et:0.034 |
| v2 | qd_dev | 10000 | evaluation cell | 0.1463 | [166] | 0.1480 | 0.1610 | – | 0.813 | ggbt:0.371 gknn:0.241 knn:0.247 gbt+et:0.140 |
| v2 | qd_dev | 10000 | analysis fit | 0.1467 | [123] | 0.1445 | 0.1610 | – | 0.849 | ggbt:0.413 gknn:0.240 knn:0.240 gbt+et:0.106 |
| v3 | fashion_mnist | 10000 | evaluation cell | 0.1238 | [242] | 0.1246 | 0.1271 | 0.1256 | 0.663 | cgbt:0.104 ggbt:0.155 knn:0.042 gbt+et:0.498 lin:0.201 |
| v3 | fashion_mnist | 10000 | analysis fit | 0.1238 | [242] | 0.1246 | 0.1271 | 0.1256 | 0.663 | cgbt:0.104 ggbt:0.155 knn:0.042 gbt+et:0.498 lin:0.201 |
| v2 | fashion_mnist | 10000 | evaluation cell | 0.1259 | [162] | 0.1241 | 0.1321 | – | 0.674 | ggbt:0.274 knn:0.059 gbt+et:0.467 lin:0.199 |
| v3 | qd_a | 10000 | evaluation cell | 0.1422 | [206] | 0.1530 | 0.1715 | 0.1605 | 0.703 | cgbt:0.560 gknn:0.147 knn:0.236 gbt+et:0.057 |
| v3 | qd_a | 10000 | analysis fit | 0.1422 | [206] | 0.1530 | 0.1715 | 0.1605 | 0.703 | cgbt:0.560 gknn:0.147 knn:0.236 gbt+et:0.057 |
| v3 | qd_dev | 1000 | evaluation cell | 0.2118 | [100, 100, 100, 100, 100] | 0.2290 | 0.2800 | 0.2720 | 0.797 | cgbt:0.316 ggbt:0.089 gknn:0.437 knn:0.158 |
| v3 | qd_dev | 1000 | analysis fit | 0.2118 | [100, 100, 100, 100, 100] | 0.2290 | 0.2800 | 0.2720 | 0.797 | cgbt:0.316 ggbt:0.089 gknn:0.437 knn:0.158 |

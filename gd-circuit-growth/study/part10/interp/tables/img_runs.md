# Image analysis runs: test error vs the evaluation cell

Source files: $SCRATCH/p10/interp_out_final/image/v3/fashion_mnist__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n1000__s0.json (and the .npz next to each).

| learner | dataset | n | seed | test err (analysis fit) | test err (evaluation cell) | equal | stacker oof err | fit CPU s | cell file |
|---|---|---|---|---|---|---|---|---|---|
| v3 | qd_dev | 1000 | 0 | 0.2118 | 0.2118 | yes | 0.2290 | 261.8 | $SCRATCH/p9/cells/p10_codes-dev__qd_dev/n1000_s0.json |
| v3 | qd_dev | 10000 | 0 | 0.1330 | 0.1330 | yes | 0.1425 | 526.2 | $SCRATCH/p9/cells/p10_codes-dev__qd_dev/n10000_s0.json |
| v3 | fashion_mnist | 10000 | 0 | 0.1238 | 0.1238 | yes | 0.1246 | 670.5 | $SCRATCH/p9/cells/p10_codes-dev__fashion_mnist/n10000_s0.json |

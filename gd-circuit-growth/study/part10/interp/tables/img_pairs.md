# ggbt's prototype pairs: gain by class pair

Source files: $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n1000__s0.json (and the .npz next to each).

| learner | dataset | n | pairs' share of ggbt gain | top class pairs: share of the pairs' gain (pairs drawn) | top 10 of 45 class pairs: share | highest gain per drawn pair, rel. to the mean pair (>= 3 drawn) | lowest gain per drawn pair |
|---|---|---|---|---|---|---|---|
| v3 | qd_dev | 1000 | 0.404 | soccer ball–foot 0.085; matches–soccer ball 0.076; paper clip–soccer ball 0.052; campfire–frying pan 0.044; ocean–frying pan 0.042; motorbike–foot 0.039; ocean–campfire 0.036; grapes–foot 0.035 | 0.475 | – | – |
| v3 | qd_dev | 10000 | 0.394 | motorbike–frying pan 0.085 (8); grapes–frying pan 0.053 (11); grapes–soccer ball 0.053 (3); paper clip–soccer ball 0.052 (8); ocean–grapes 0.051 (8); ocean–matches 0.046 (7); soccer ball–frying pan 0.038 (12); motorbike–grapes 0.033 (8) | 0.478 | grapes–soccer ball 5.31 (3); motorbike–frying pan 3.18 (8); ocean–matches 1.96 (7); paper clip–soccer ball 1.94 (8); ocean–grapes 1.92 (8); matches–campfire 1.87 (5) | grapes–paper clip 0.21 (6); ocean–paper clip 0.21 (9); motorbike–soccer ball 0.17 (5) |

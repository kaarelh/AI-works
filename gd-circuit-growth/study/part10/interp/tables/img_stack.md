# Stacker weight / out-of-fold error per member

Source files: $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n1000__s0.json (and the .npz next to each).

| learner | dataset | n | cgbt | ggbt | gknn_1 | gknn_3 | gknn_9 | gknn_27 | knn_std_1 | knn_std_3 | knn_std_9 | knn_std_27 | knn_raw_1 | knn_raw_3 | knn_raw_9 | knn_raw_27 | gbt | et | lin_0.05 | lin_1.0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| v3 | qd_dev | 1000 | 0.252 / 0.272 | 0.071 / 0.280 | 0.076 / 0.327 | 0.091 / 0.320 | 0.181 / 0.324 | 0.000 / 0.382 | 0.020 / 0.372 | 0.051 / 0.388 | 0.000 / 0.445 | 0.000 / 0.549 | 0.055 / 0.361 | 0.000 / 0.396 | 0.000 / 0.419 | 0.000 / 0.516 | 0.000 / 0.342 | 0.000 / 0.338 | 0.000 / 0.371 | 0.000 / 0.404 |

# Contribution maps, quantified (n = 10000)

class-excess ink: pixels where the class mean image exceeds the mean of the 10 class means by > 0.05; class-deficit: below it by > 0.05.

Source files: $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n1000__s0.json (and the .npz next to each).

| learner | dataset | booster | class | positive share of |contrib| | pos. on class-excess ink | pos. on class-deficit | neg. on class-excess | neg. on class-deficit | corr(map, class mean - mean) | net evidence: inked / blank pixels of the point | |contrib| share by feature type |
|---|---|---|---|---|---|---|---|---|---|---|---|
| v3 | qd_dev | cgbt | ocean | 1.00 | 0.14 | 0.68 | 0.00 | 0.89 | -0.08 | +2.51 / +14.28 | raw:0.02 pool4:0.05 pool9:0.07 pool16:0.15 bars2:0.23 bars4:0.48 |
| v3 | qd_dev | cgbt | motorbike | 1.00 | 0.38 | 0.43 | 0.07 | 0.29 | -0.11 | +4.59 / +8.80 | raw:0.02 pool4:0.03 pool9:0.05 pool16:0.07 bars2:0.34 bars4:0.48 |
| v3 | qd_dev | cgbt | matches | 1.00 | 0.04 | 0.69 | 0.00 | 0.84 | -0.46 | +0.68 / +6.64 | raw:0.03 pool4:0.05 pool9:0.05 pool16:0.07 bars2:0.32 bars4:0.49 |
| v3 | qd_dev | cgbt | grapes | 1.00 | 0.72 | 0.08 | 0.14 | 0.00 | +0.72 | +4.72 / +2.49 | raw:0.03 pool4:0.04 pool9:0.09 pool16:0.11 bars2:0.26 bars4:0.47 |
| v3 | qd_dev | cgbt | paper clip | 1.00 | 0.34 | 0.37 | 0.00 | 0.36 | +0.20 | +4.59 / +7.75 | raw:0.02 pool4:0.04 pool9:0.05 pool16:0.10 bars2:0.28 bars4:0.51 |
| v3 | qd_dev | cgbt | campfire | 0.99 | 0.71 | 0.12 | 0.12 | 0.00 | +0.60 | +6.25 / +3.90 | raw:0.03 pool4:0.05 pool9:0.06 pool16:0.11 bars2:0.30 bars4:0.46 |
| v3 | qd_dev | cgbt | washing machine | 1.00 | 0.67 | 0.04 | 0.02 | 0.00 | +0.52 | +9.34 / +8.43 | raw:0.01 pool4:0.03 pool9:0.04 pool16:0.07 bars2:0.32 bars4:0.53 |
| v3 | qd_dev | cgbt | soccer ball | 1.00 | 0.82 | 0.01 | 0.72 | 0.00 | +0.61 | +10.11 / +4.69 | raw:0.02 pool4:0.04 pool9:0.05 pool16:0.12 bars2:0.33 bars4:0.43 |
| v3 | qd_dev | cgbt | frying pan | 1.00 | 0.15 | 0.50 | 0.00 | 0.44 | -0.07 | +2.52 / +7.29 | raw:0.03 pool4:0.05 pool9:0.05 pool16:0.09 bars2:0.29 bars4:0.50 |
| v3 | qd_dev | cgbt | foot | 1.00 | 0.12 | 0.70 | 0.00 | 0.61 | -0.58 | +2.37 / +8.48 | raw:0.02 pool4:0.04 pool9:0.07 pool16:0.09 bars2:0.28 bars4:0.50 |
| v3 | qd_dev | ggbt | ocean | 1.00 | 0.33 | 0.47 | 0.00 | 0.88 | +0.34 | +5.11 / +6.30 | raw:0.04 pool4:0.14 pool9:0.18 pool16:0.34 pairs:0.29 |
| v3 | qd_dev | ggbt | motorbike | 1.00 | 0.45 | 0.36 | 0.00 | 0.00 | +0.02 | +4.61 / +3.63 | raw:0.09 pool4:0.15 pool9:0.21 pool16:0.27 pairs:0.28 |
| v3 | qd_dev | ggbt | matches | 1.00 | 0.07 | 0.60 | 0.00 | 0.24 | -0.29 | +1.72 / +2.94 | raw:0.08 pool4:0.14 pool9:0.18 pool16:0.31 pairs:0.29 |
| v3 | qd_dev | ggbt | grapes | 1.00 | 0.73 | 0.07 | 0.00 | 0.03 | +0.76 | +3.64 / +0.95 | raw:0.08 pool4:0.12 pool9:0.24 pool16:0.31 pairs:0.25 |
| v3 | qd_dev | ggbt | paper clip | 1.00 | 0.42 | 0.30 | 0.00 | 0.56 | +0.34 | +4.34 / +3.12 | raw:0.06 pool4:0.12 pool9:0.21 pool16:0.31 pairs:0.30 |
| v3 | qd_dev | ggbt | campfire | 1.00 | 0.67 | 0.11 | 0.24 | 0.00 | +0.61 | +4.46 / +2.20 | raw:0.08 pool4:0.14 pool9:0.20 pool16:0.32 pairs:0.26 |
| v3 | qd_dev | ggbt | washing machine | 1.00 | 0.74 | 0.03 | 0.00 | 0.00 | +0.69 | +8.49 / +3.05 | raw:0.05 pool4:0.13 pool9:0.22 pool16:0.35 pairs:0.24 |
| v3 | qd_dev | ggbt | soccer ball | 1.00 | 0.78 | 0.02 | 0.00 | 0.00 | +0.63 | +8.11 / +1.51 | raw:0.06 pool4:0.11 pool9:0.16 pool16:0.38 pairs:0.29 |
| v3 | qd_dev | ggbt | frying pan | 1.00 | 0.20 | 0.45 | 0.00 | 0.03 | +0.08 | +3.55 / +2.86 | raw:0.07 pool4:0.14 pool9:0.17 pool16:0.27 pairs:0.34 |
| v3 | qd_dev | ggbt | foot | 1.00 | 0.19 | 0.62 | 0.00 | 0.00 | -0.40 | +3.78 / +3.15 | raw:0.07 pool4:0.10 pool9:0.21 pool16:0.29 pairs:0.33 |

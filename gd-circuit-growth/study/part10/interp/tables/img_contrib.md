# Contribution maps, quantified (n = 10000)

class-excess ink: pixels where the class mean image exceeds the mean of the 10 class means by > 0.05; class-deficit: below it by > 0.05.

Source files: $SCRATCH/p10/interp_out_final/image/v2/qd_dev__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/fashion_mnist__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/mnist__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_a__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n1000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n3000__s0.json (and the .npz next to each).

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
| v3 | fashion_mnist | cgbt | T-shirt | 0.98 | 0.50 | 0.35 | 0.94 | 0.01 | +0.00 | +5.75 / +6.47 | raw:0.12 pool4:0.08 pool9:0.08 pool16:0.07 bars2:0.33 bars4:0.32 |
| v3 | fashion_mnist | cgbt | trouser | 1.00 | 0.22 | 0.74 | 0.01 | 0.78 | -0.29 | +5.93 / +17.16 | raw:0.13 pool4:0.07 pool9:0.07 pool16:0.10 bars2:0.31 bars4:0.33 |
| v3 | fashion_mnist | cgbt | pullover | 0.98 | 0.83 | 0.05 | 0.64 | 0.07 | +0.41 | +7.88 / +2.64 | raw:0.10 pool4:0.11 pool9:0.08 pool16:0.08 bars2:0.33 bars4:0.31 |
| v3 | fashion_mnist | cgbt | dress | 0.99 | 0.37 | 0.55 | 0.48 | 0.13 | -0.01 | +5.14 / +8.86 | raw:0.14 pool4:0.08 pool9:0.09 pool16:0.09 bars2:0.31 bars4:0.30 |
| v3 | fashion_mnist | cgbt | coat | 0.97 | 0.75 | 0.12 | 0.89 | 0.02 | +0.30 | +7.59 / +3.16 | raw:0.14 pool4:0.11 pool9:0.07 pool16:0.07 bars2:0.31 bars4:0.31 |
| v3 | fashion_mnist | cgbt | sandal | 1.00 | 0.11 | 0.82 | 0.00 | 0.57 | -0.22 | +1.54 / +16.68 | raw:0.17 pool4:0.09 pool9:0.08 pool16:0.08 bars2:0.27 bars4:0.30 |
| v3 | fashion_mnist | cgbt | shirt | 0.96 | 0.71 | 0.04 | 0.38 | 0.10 | +0.38 | +4.91 / +1.94 | raw:0.12 pool4:0.09 pool9:0.08 pool16:0.06 bars2:0.34 bars4:0.32 |
| v3 | fashion_mnist | cgbt | sneaker | 0.99 | 0.17 | 0.75 | 0.09 | 0.80 | -0.15 | +3.78 / +13.86 | raw:0.06 pool4:0.09 pool9:0.11 pool16:0.12 bars2:0.30 bars4:0.31 |
| v3 | fashion_mnist | cgbt | bag | 1.00 | 0.47 | 0.41 | 0.97 | 0.00 | -0.32 | +9.18 / +9.21 | raw:0.07 pool4:0.08 pool9:0.08 pool16:0.12 bars2:0.29 bars4:0.36 |
| v3 | fashion_mnist | cgbt | boot | 1.00 | 0.39 | 0.59 | 0.75 | 0.14 | -0.18 | +7.02 / +11.33 | raw:0.11 pool4:0.09 pool9:0.08 pool16:0.11 bars2:0.34 bars4:0.27 |
| v3 | fashion_mnist | ggbt | T-shirt | 0.98 | 0.57 | 0.30 | 0.96 | 0.00 | +0.09 | +6.79 / +4.95 | raw:0.28 pool4:0.22 pool9:0.22 pool16:0.19 pairs:0.10 |
| v3 | fashion_mnist | ggbt | trouser | 1.00 | 0.40 | 0.53 | 0.00 | 0.60 | -0.04 | +12.01 / +11.16 | raw:0.25 pool4:0.14 pool9:0.14 pool16:0.18 pairs:0.29 |
| v3 | fashion_mnist | ggbt | pullover | 0.98 | 0.85 | 0.04 | 0.59 | 0.13 | +0.40 | +8.10 / +2.06 | raw:0.26 pool4:0.30 pool9:0.21 pool16:0.18 pairs:0.05 |
| v3 | fashion_mnist | ggbt | dress | 1.00 | 0.50 | 0.41 | 0.00 | 0.33 | +0.27 | +7.62 / +6.47 | raw:0.28 pool4:0.21 pool9:0.19 pool16:0.16 pairs:0.15 |
| v3 | fashion_mnist | ggbt | coat | 0.97 | 0.79 | 0.09 | 0.82 | 0.05 | +0.30 | +8.08 / +2.44 | raw:0.33 pool4:0.22 pool9:0.19 pool16:0.17 pairs:0.09 |
| v3 | fashion_mnist | ggbt | sandal | 1.00 | 0.13 | 0.77 | 0.00 | 0.85 | -0.15 | +5.08 / +13.22 | raw:0.27 pool4:0.18 pool9:0.19 pool16:0.16 pairs:0.19 |
| v3 | fashion_mnist | ggbt | shirt | 0.96 | 0.76 | 0.03 | 0.47 | 0.08 | +0.32 | +5.14 / +1.65 | raw:0.29 pool4:0.26 pool9:0.22 pool16:0.17 pairs:0.06 |
| v3 | fashion_mnist | ggbt | sneaker | 0.99 | 0.33 | 0.54 | 0.00 | 0.86 | +0.11 | +8.90 / +8.93 | raw:0.14 pool4:0.17 pool9:0.23 pool16:0.21 pairs:0.25 |
| v3 | fashion_mnist | ggbt | bag | 1.00 | 0.55 | 0.34 | 0.92 | 0.00 | -0.23 | +10.93 / +7.49 | raw:0.15 pool4:0.18 pool9:0.22 pool16:0.28 pairs:0.17 |
| v3 | fashion_mnist | ggbt | boot | 1.00 | 0.55 | 0.39 | 0.25 | 0.43 | +0.02 | +11.86 / +6.84 | raw:0.20 pool4:0.17 pool9:0.17 pool16:0.17 pairs:0.29 |
| v3 | mnist | cgbt | 0 | 1.00 | 0.37 | 0.59 | 0.41 | 0.02 | -0.30 | +5.39 / +11.51 | raw:0.04 pool4:0.07 pool9:0.08 pool16:0.08 bars2:0.34 bars4:0.39 |
| v3 | mnist | cgbt | 1 | 1.00 | 0.11 | 0.82 | 0.00 | 0.49 | -0.45 | +1.91 / +14.80 | raw:0.02 pool4:0.04 pool9:0.05 pool16:0.12 bars2:0.26 bars4:0.51 |
| v3 | mnist | cgbt | 2 | 1.00 | 0.38 | 0.40 | 0.16 | 0.00 | -0.10 | +4.32 / +10.64 | raw:0.01 pool4:0.02 pool9:0.04 pool16:0.08 bars2:0.27 bars4:0.58 |
| v3 | mnist | cgbt | 3 | 1.00 | 0.37 | 0.49 | 0.00 | 0.00 | -0.17 | +4.94 / +8.14 | raw:0.01 pool4:0.03 pool9:0.05 pool16:0.06 bars2:0.36 bars4:0.49 |
| v3 | mnist | cgbt | 4 | 1.00 | 0.25 | 0.56 | 0.00 | 0.05 | -0.31 | +4.47 / +10.23 | raw:0.02 pool4:0.03 pool9:0.07 pool16:0.08 bars2:0.39 bars4:0.42 |
| v3 | mnist | cgbt | 5 | 1.00 | 0.26 | 0.49 | 0.00 | 0.00 | -0.28 | +4.10 / +10.50 | raw:0.02 pool4:0.04 pool9:0.06 pool16:0.07 bars2:0.34 bars4:0.47 |
| v3 | mnist | cgbt | 6 | 1.00 | 0.46 | 0.33 | 0.00 | 0.00 | +0.07 | +5.66 / +10.69 | raw:0.01 pool4:0.02 pool9:0.03 pool16:0.04 bars2:0.34 bars4:0.56 |
| v3 | mnist | cgbt | 7 | 1.00 | 0.21 | 0.69 | 0.00 | 0.37 | -0.41 | +2.46 / +12.98 | raw:0.02 pool4:0.03 pool9:0.05 pool16:0.07 bars2:0.27 bars4:0.56 |
| v3 | mnist | cgbt | 8 | 1.00 | 0.58 | 0.20 | 0.00 | 0.00 | +0.47 | +7.82 / +5.71 | raw:0.02 pool4:0.05 pool9:0.05 pool16:0.07 bars2:0.34 bars4:0.47 |
| v3 | mnist | cgbt | 9 | 1.00 | 0.34 | 0.46 | 0.00 | 0.00 | -0.07 | +4.08 / +9.57 | raw:0.03 pool4:0.03 pool9:0.05 pool16:0.06 bars2:0.28 bars4:0.55 |
| v3 | mnist | ggbt | 0 | 1.00 | 0.44 | 0.51 | 0.00 | 0.17 | -0.27 | +8.24 / +8.52 | raw:0.09 pool4:0.15 pool9:0.24 pool16:0.21 pairs:0.31 |
| v3 | mnist | ggbt | 1 | 1.00 | 0.35 | 0.55 | 0.00 | 0.64 | +0.09 | +9.97 / +6.78 | raw:0.04 pool4:0.07 pool9:0.14 pool16:0.24 pairs:0.50 |
| v3 | mnist | ggbt | 2 | 1.00 | 0.50 | 0.31 | 0.00 | 0.00 | +0.09 | +7.78 / +6.92 | raw:0.06 pool4:0.10 pool9:0.21 pool16:0.33 pairs:0.31 |
| v3 | mnist | ggbt | 3 | 1.00 | 0.53 | 0.33 | 0.00 | 0.00 | +0.22 | +8.80 / +4.91 | raw:0.07 pool4:0.13 pool9:0.15 pool16:0.24 pairs:0.41 |
| v3 | mnist | ggbt | 4 | 1.00 | 0.36 | 0.49 | 0.00 | 0.00 | -0.12 | +7.84 / +6.89 | raw:0.09 pool4:0.12 pool9:0.19 pool16:0.29 pairs:0.31 |
| v3 | mnist | ggbt | 5 | 1.00 | 0.33 | 0.43 | 0.00 | 0.00 | -0.15 | +7.13 / +7.41 | raw:0.07 pool4:0.16 pool9:0.19 pool16:0.30 pairs:0.29 |
| v3 | mnist | ggbt | 6 | 1.00 | 0.50 | 0.31 | 0.00 | 0.00 | +0.16 | +8.95 / +7.06 | raw:0.06 pool4:0.15 pool9:0.19 pool16:0.27 pairs:0.32 |
| v3 | mnist | ggbt | 7 | 1.00 | 0.31 | 0.56 | 0.00 | 0.23 | -0.24 | +6.21 / +9.84 | raw:0.07 pool4:0.09 pool9:0.22 pool16:0.33 pairs:0.29 |
| v3 | mnist | ggbt | 8 | 1.00 | 0.71 | 0.10 | 0.00 | 0.00 | +0.70 | +10.82 / +2.79 | raw:0.08 pool4:0.17 pool9:0.22 pool16:0.28 pairs:0.25 |
| v3 | mnist | ggbt | 9 | 1.00 | 0.41 | 0.37 | 0.00 | 0.00 | +0.17 | +7.27 / +6.17 | raw:0.09 pool4:0.14 pool9:0.20 pool16:0.32 pairs:0.25 |
| v3 | qd_a | cgbt | broccoli | 1.00 | 0.46 | 0.32 | 0.00 | 0.50 | +0.16 | +4.77 / +6.07 | raw:0.03 pool4:0.03 pool9:0.05 pool16:0.07 bars2:0.33 bars4:0.48 |
| v3 | qd_a | cgbt | oven | 1.00 | 0.73 | 0.08 | 0.54 | 0.00 | +0.49 | +4.38 / +3.03 | raw:0.03 pool4:0.03 pool9:0.06 pool16:0.05 bars2:0.34 bars4:0.50 |
| v3 | qd_a | cgbt | leaf | 1.00 | 0.11 | 0.53 | 0.00 | 0.00 | -0.41 | +1.60 / +7.25 | raw:0.03 pool4:0.05 pool9:0.05 pool16:0.07 bars2:0.27 bars4:0.54 |
| v3 | qd_a | cgbt | strawberry | 1.00 | 0.38 | 0.36 | 0.01 | 0.08 | +0.18 | +4.25 / +7.59 | raw:0.02 pool4:0.05 pool9:0.06 pool16:0.09 bars2:0.29 bars4:0.49 |
| v3 | qd_a | cgbt | The Eiffel Tower | 1.00 | 0.17 | 0.71 | 0.00 | 0.00 | -0.45 | +2.30 / +15.81 | raw:0.02 pool4:0.02 pool9:0.05 pool16:0.17 bars2:0.25 bars4:0.49 |
| v3 | qd_a | cgbt | star | 1.00 | 0.14 | 0.47 | 0.00 | 0.00 | -0.39 | +2.84 / +8.16 | raw:0.02 pool4:0.03 pool9:0.04 pool16:0.12 bars2:0.25 bars4:0.55 |
| v3 | qd_a | cgbt | piano | 1.00 | 0.52 | 0.28 | 0.00 | 0.05 | +0.41 | +3.79 / +3.01 | raw:0.03 pool4:0.05 pool9:0.06 pool16:0.10 bars2:0.27 bars4:0.49 |
| v3 | qd_a | cgbt | camouflage | 1.00 | 0.87 | 0.02 | 0.08 | 0.00 | +0.78 | +4.01 / +0.70 | raw:0.04 pool4:0.05 pool9:0.05 pool16:0.09 bars2:0.29 bars4:0.47 |
| v3 | qd_a | cgbt | coffee cup | 1.00 | 0.28 | 0.35 | 0.00 | 0.00 | -0.31 | +2.17 / +5.76 | raw:0.02 pool4:0.05 pool9:0.07 pool16:0.07 bars2:0.34 bars4:0.44 |
| v3 | qd_a | cgbt | skateboard | 1.00 | 0.12 | 0.76 | 0.26 | 0.36 | -0.40 | +2.22 / +13.35 | raw:0.01 pool4:0.02 pool9:0.03 pool16:0.08 bars2:0.28 bars4:0.57 |
| v3 | qd_a | ggbt | broccoli | 1.00 | 0.54 | 0.26 | 0.00 | 0.00 | +0.35 | +7.70 / +4.99 | raw:0.09 pool4:0.16 pool9:0.21 pool16:0.30 pairs:0.24 |
| v3 | qd_a | ggbt | oven | 1.00 | 0.75 | 0.07 | 0.00 | 0.00 | +0.53 | +5.93 / +2.43 | raw:0.10 pool4:0.18 pool9:0.23 pool16:0.32 pairs:0.17 |
| v3 | qd_a | ggbt | leaf | 1.00 | 0.15 | 0.49 | 0.00 | 1.00 | -0.31 | +3.44 / +7.12 | raw:0.09 pool4:0.17 pool9:0.20 pool16:0.37 pairs:0.17 |
| v3 | qd_a | ggbt | strawberry | 1.00 | 0.41 | 0.36 | 0.31 | 0.41 | +0.23 | +6.68 / +6.02 | raw:0.08 pool4:0.15 pool9:0.26 pool16:0.31 pairs:0.20 |
| v3 | qd_a | ggbt | The Eiffel Tower | 1.00 | 0.32 | 0.54 | 0.00 | 0.91 | -0.25 | +6.43 / +11.19 | raw:0.05 pool4:0.08 pool9:0.14 pool16:0.49 pairs:0.25 |
| v3 | qd_a | ggbt | star | 1.00 | 0.19 | 0.42 | 0.00 | 0.00 | -0.25 | +5.15 / +7.19 | raw:0.06 pool4:0.12 pool9:0.19 pool16:0.41 pairs:0.23 |
| v3 | qd_a | ggbt | piano | 1.00 | 0.57 | 0.21 | 0.00 | 0.02 | +0.58 | +6.19 / +2.00 | raw:0.10 pool4:0.13 pool9:0.19 pool16:0.26 pairs:0.31 |
| v3 | qd_a | ggbt | camouflage | 0.99 | 0.89 | 0.02 | 0.26 | 0.01 | +0.82 | +5.15 / +0.57 | raw:0.13 pool4:0.17 pool9:0.18 pool16:0.26 pairs:0.26 |
| v3 | qd_a | ggbt | coffee cup | 1.00 | 0.32 | 0.31 | 0.00 | 0.00 | -0.19 | +4.69 / +4.82 | raw:0.08 pool4:0.16 pool9:0.25 pool16:0.30 pairs:0.21 |
| v3 | qd_a | ggbt | skateboard | 1.00 | 0.36 | 0.47 | 0.00 | 0.82 | +0.34 | +10.47 / +6.20 | raw:0.06 pool4:0.11 pool9:0.16 pool16:0.21 pairs:0.47 |
| v2 | qd_dev | ggbt | ocean | 1.00 | 0.33 | 0.47 | 0.00 | 0.88 | +0.34 | +5.11 / +6.30 | raw:0.04 pool4:0.14 pool9:0.18 pool16:0.34 pairs:0.29 |
| v2 | qd_dev | ggbt | motorbike | 1.00 | 0.45 | 0.36 | 0.00 | 0.00 | +0.02 | +4.61 / +3.63 | raw:0.09 pool4:0.15 pool9:0.21 pool16:0.27 pairs:0.28 |
| v2 | qd_dev | ggbt | matches | 1.00 | 0.07 | 0.60 | 0.00 | 0.24 | -0.29 | +1.72 / +2.94 | raw:0.08 pool4:0.14 pool9:0.18 pool16:0.31 pairs:0.29 |
| v2 | qd_dev | ggbt | grapes | 1.00 | 0.73 | 0.07 | 0.00 | 0.03 | +0.76 | +3.64 / +0.95 | raw:0.08 pool4:0.12 pool9:0.24 pool16:0.31 pairs:0.25 |
| v2 | qd_dev | ggbt | paper clip | 1.00 | 0.42 | 0.30 | 0.00 | 0.56 | +0.34 | +4.34 / +3.12 | raw:0.06 pool4:0.12 pool9:0.21 pool16:0.31 pairs:0.30 |
| v2 | qd_dev | ggbt | campfire | 1.00 | 0.67 | 0.11 | 0.24 | 0.00 | +0.61 | +4.46 / +2.20 | raw:0.08 pool4:0.14 pool9:0.20 pool16:0.32 pairs:0.26 |
| v2 | qd_dev | ggbt | washing machine | 1.00 | 0.74 | 0.03 | 0.00 | 0.00 | +0.69 | +8.49 / +3.05 | raw:0.05 pool4:0.13 pool9:0.22 pool16:0.35 pairs:0.24 |
| v2 | qd_dev | ggbt | soccer ball | 1.00 | 0.78 | 0.02 | 0.00 | 0.00 | +0.63 | +8.11 / +1.51 | raw:0.06 pool4:0.11 pool9:0.16 pool16:0.38 pairs:0.29 |
| v2 | qd_dev | ggbt | frying pan | 1.00 | 0.20 | 0.45 | 0.00 | 0.03 | +0.08 | +3.55 / +2.86 | raw:0.07 pool4:0.14 pool9:0.17 pool16:0.27 pairs:0.34 |
| v2 | qd_dev | ggbt | foot | 1.00 | 0.19 | 0.62 | 0.00 | 0.00 | -0.40 | +3.78 / +3.15 | raw:0.07 pool4:0.10 pool9:0.21 pool16:0.29 pairs:0.33 |

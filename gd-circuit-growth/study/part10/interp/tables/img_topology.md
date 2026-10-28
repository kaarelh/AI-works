# Isomap Procrustes R^2 of the pooling-set graphs (nodes in the largest component)

Source files: $SCRATCH/p10/interp_out_final/image/v3/fashion_mnist__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/mnist__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_a__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n1000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n3000__s0.json (and the .npz next to each).

| learner | dataset | n | active pixels | k=4 union | k=9 union | k=9 mutual | k=16 mutual |
|---|---|---|---|---|---|---|---|
| v3 | qd_dev | 1000 | 676 | 0.842 (676) | 0.259 (676) | 0.874 (676) | 0.011 (676) |
| v3 | qd_dev | 3000 | 676 | 0.970 (676) | 0.735 (676) | 0.888 (676) | 0.011 (676) |
| v3 | qd_dev | 10000 | 676 | 0.973 (676) | 0.858 (676) | 0.917 (676) | 0.072 (676) |
| v3 | fashion_mnist | 10000 | 784 | 0.134 (784) | 0.230 (784) | 0.231 (784) | 0.234 (784) |
| v3 | mnist | 10000 | 682 | 0.918 (682) | 0.477 (682) | 0.969 (674) | 0.519 (674) |
| v3 | qd_a | 10000 | 676 | 0.988 (676) | 0.238 (676) | 0.827 (676) | 0.254 (676) |

Edges of the same graphs by their true Chebyshev length: total edges: fraction of length <= 1 / number longer than 2 / number longer than 5 (computed from the pooling-set member lists in the .npz).

| dataset | n | k=4 union | k=9 union | k=9 mutual | k=16 mutual |
|---|---|---|---|---|---|
| qd_dev | 1000 | 1178: 0.976 / 1 / 1 | 3005: 0.772 / 66 / 28 | 2403: 0.886 / 13 / 6 | 4390: 0.557 / 525 / 95 |
| qd_dev | 3000 | 1163: 0.987 / 0 / 0 | 3002: 0.775 / 39 / 12 | 2406: 0.897 / 7 / 1 | 4412: 0.556 / 479 / 69 |
| qd_dev | 10000 | 1170: 0.991 / 0 / 0 | 2983: 0.781 / 24 / 6 | 2425: 0.899 / 7 / 1 | 4416: 0.555 / 450 / 49 |
| fashion_mnist | 10000 | 1385: 0.852 / 49 / 35 | 3888: 0.597 / 720 / 341 | 2384: 0.691 / 286 / 134 | 4372: 0.532 / 1047 / 432 |
| mnist | 10000 | 1257: 0.965 / 23 / 23 | 3266: 0.711 / 180 / 113 | 2190: 0.900 / 6 / 3 | 3940: 0.621 / 126 / 23 |
| qd_a | 10000 | 1174: 0.997 / 0 / 0 | 3010: 0.769 / 46 / 10 | 2398: 0.876 / 13 / 3 | 4330: 0.580 / 610 / 91 |

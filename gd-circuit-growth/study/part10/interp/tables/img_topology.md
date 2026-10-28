# Isomap Procrustes R^2 of the pooling-set graphs (nodes in the largest component)

Source files: $SCRATCH/p10/interp_out_final/image/v3/fashion_mnist__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n1000__s0.json (and the .npz next to each).

| learner | dataset | n | active pixels | k=4 union | k=9 union | k=9 mutual | k=16 mutual |
|---|---|---|---|---|---|---|---|
| v3 | qd_dev | 1000 | 676 | 0.842 (676) | 0.259 (676) | 0.874 (676) | 0.011 (676) |
| v3 | qd_dev | 10000 | 676 | 0.973 (676) | 0.858 (676) | 0.917 (676) | 0.072 (676) |
| v3 | fashion_mnist | 10000 | 784 | 0.134 (784) | 0.230 (784) | 0.231 (784) | 0.234 (784) |

Edges of the same graphs by their true Chebyshev length: total edges: fraction of length <= 1 / number longer than 2 / number longer than 5 (computed from the pooling-set member lists in the .npz).

| dataset | n | k=4 union | k=9 union | k=9 mutual | k=16 mutual |
|---|---|---|---|---|---|
| qd_dev | 1000 | 1178: 0.976 / 1 / 1 | 3005: 0.772 / 66 / 28 | 2403: 0.886 / 13 / 6 | 4390: 0.557 / 525 / 95 |
| qd_dev | 10000 | 1170: 0.991 / 0 / 0 | 2983: 0.781 / 24 / 6 | 2425: 0.899 / 7 / 1 | 4416: 0.555 / 450 / 49 |
| fashion_mnist | 10000 | 1385: 0.852 / 49 / 35 | 3888: 0.597 / 720 / 341 | 2384: 0.691 / 286 / 134 | 4372: 0.532 / 1047 / 432 |

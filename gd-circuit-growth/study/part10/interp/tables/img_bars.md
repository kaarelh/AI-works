# Bars on the true grid (v3); gain-weighted = weighted by cgbt's split gain

Orientation 45 = '/' (row decreases as column increases), 135 = '\\'.

Source files: $SCRATCH/p10/interp_out_final/image/v3/fashion_mnist__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n1000__s0.json (and the .npz next to each).

| dataset | n | L | bars | mean pixels | straight | contiguous | elong. median | elong. >= 0.9 | within 1 px of a line | orient. 0/45/90/135 | straight (gain-wtd) | elong. >= 0.9 (gain-wtd) | within 1 px (gain-wtd) | orient. (gain-wtd) | frac. of bars used | gain share of top 10% bars |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| qd_dev | 1000 | 2 | 2704 | 4.75 | 0.327 | 0.291 | 0.964 | 0.748 | 0.957 | 0.27/0.23/0.27/0.22 | 0.413 | 0.850 | 0.970 | 0.18/0.29/0.27/0.26 | 0.817 | 0.763 |
| qd_dev | 1000 | 4 | 2704 | 7.68 | 0.157 | 0.136 | 0.960 | 0.723 | 0.634 | 0.27/0.25/0.26/0.22 | 0.229 | 0.808 | 0.672 | 0.17/0.28/0.30/0.25 | 0.873 | 0.761 |
| qd_dev | 10000 | 2 | 2704 | 4.78 | 0.421 | 0.381 | 0.982 | 0.765 | 0.958 | 0.29/0.22/0.28/0.21 | 0.432 | 0.867 | 0.979 | 0.25/0.24/0.29/0.23 | 0.932 | 0.652 |
| qd_dev | 10000 | 4 | 2704 | 7.83 | 0.244 | 0.221 | 0.968 | 0.746 | 0.635 | 0.30/0.23/0.27/0.20 | 0.323 | 0.829 | 0.635 | 0.25/0.22/0.29/0.25 | 0.960 | 0.659 |
| fashion_mnist | 10000 | 2 | 3136 | 4.46 | 0.108 | 0.038 | 0.951 | 0.674 | 0.815 | 0.37/0.12/0.40/0.12 | 0.089 | 0.658 | 0.817 | 0.35/0.11/0.40/0.14 | 0.923 | 0.783 |
| fashion_mnist | 10000 | 4 | 3136 | 6.27 | 0.037 | 0.017 | 0.933 | 0.641 | 0.524 | 0.38/0.11/0.38/0.12 | 0.037 | 0.597 | 0.445 | 0.28/0.16/0.41/0.15 | 0.928 | 0.842 |

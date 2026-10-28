# Bars on the true grid (v3); gain-weighted = weighted by cgbt's split gain

Orientation 45 = '/' (row decreases as column increases), 135 = '\\'.

Source files: $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n1000__s0.json (and the .npz next to each).

| dataset | n | L | bars | mean pixels | straight | contiguous | elong. median | elong. >= 0.9 | within 1 px of a line | orient. 0/45/90/135 | straight (gain-wtd) | elong. >= 0.9 (gain-wtd) | within 1 px (gain-wtd) | orient. (gain-wtd) | frac. of bars used | gain share of top 10% bars |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| qd_dev | 1000 | 2 | 2704 | 4.75 | 0.327 | 0.291 | 0.964 | 0.748 | 0.957 | 0.27/0.23/0.27/0.22 | 0.413 | 0.850 | 0.970 | 0.18/0.29/0.27/0.26 | 0.817 | 0.763 |
| qd_dev | 1000 | 4 | 2704 | 7.68 | 0.157 | 0.136 | 0.960 | 0.723 | 0.634 | 0.27/0.25/0.26/0.22 | 0.229 | 0.808 | 0.672 | 0.17/0.28/0.30/0.25 | 0.873 | 0.761 |

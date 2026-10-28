# Bars on the true grid (v3); gain-weighted = weighted by cgbt's split gain

Orientation 45 = '/' (row decreases as column increases), 135 = '\\'.

Source files: $SCRATCH/p10/interp_out_final/image/v3/fashion_mnist__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/mnist__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_a__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n10000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n1000__s0.json, $SCRATCH/p10/interp_out_final/image/v3/qd_dev__n3000__s0.json (and the .npz next to each).

| dataset | n | L | bars | mean pixels | straight | contiguous | elong. median | elong. >= 0.9 | within 1 px of a line | orient. 0/45/90/135 | straight (gain-wtd) | elong. >= 0.9 (gain-wtd) | within 1 px (gain-wtd) | orient. (gain-wtd) | frac. of bars used | gain share of top 10% bars |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| qd_dev | 1000 | 2 | 2704 | 4.75 | 0.327 | 0.291 | 0.964 | 0.748 | 0.957 | 0.27/0.23/0.27/0.22 | 0.413 | 0.850 | 0.970 | 0.18/0.29/0.27/0.26 | 0.817 | 0.763 |
| qd_dev | 1000 | 4 | 2704 | 7.68 | 0.157 | 0.136 | 0.960 | 0.723 | 0.634 | 0.27/0.25/0.26/0.22 | 0.229 | 0.808 | 0.672 | 0.17/0.28/0.30/0.25 | 0.873 | 0.761 |
| qd_dev | 3000 | 2 | 2704 | 4.76 | 0.379 | 0.344 | 0.971 | 0.757 | 0.957 | 0.29/0.22/0.28/0.21 | 0.379 | 0.816 | 0.972 | 0.22/0.28/0.26/0.24 | 0.874 | 0.650 |
| qd_dev | 3000 | 4 | 2704 | 7.74 | 0.206 | 0.185 | 0.961 | 0.722 | 0.620 | 0.28/0.23/0.28/0.20 | 0.257 | 0.776 | 0.625 | 0.20/0.28/0.31/0.20 | 0.915 | 0.694 |
| qd_dev | 10000 | 2 | 2704 | 4.78 | 0.421 | 0.381 | 0.982 | 0.765 | 0.958 | 0.29/0.22/0.28/0.21 | 0.432 | 0.867 | 0.979 | 0.25/0.24/0.29/0.23 | 0.932 | 0.652 |
| qd_dev | 10000 | 4 | 2704 | 7.83 | 0.244 | 0.221 | 0.968 | 0.746 | 0.635 | 0.30/0.23/0.27/0.20 | 0.323 | 0.829 | 0.635 | 0.25/0.22/0.29/0.25 | 0.960 | 0.659 |
| fashion_mnist | 10000 | 2 | 3136 | 4.46 | 0.108 | 0.038 | 0.951 | 0.674 | 0.815 | 0.37/0.12/0.40/0.12 | 0.089 | 0.658 | 0.817 | 0.35/0.11/0.40/0.14 | 0.923 | 0.783 |
| fashion_mnist | 10000 | 4 | 3136 | 6.27 | 0.037 | 0.017 | 0.933 | 0.641 | 0.524 | 0.38/0.11/0.38/0.12 | 0.037 | 0.597 | 0.445 | 0.28/0.16/0.41/0.15 | 0.928 | 0.842 |
| mnist | 10000 | 2 | 2728 | 4.58 | 0.203 | 0.166 | 0.950 | 0.631 | 0.897 | 0.27/0.30/0.26/0.17 | 0.362 | 0.814 | 0.968 | 0.40/0.31/0.15/0.14 | 0.719 | 0.858 |
| mnist | 10000 | 4 | 2728 | 6.98 | 0.062 | 0.042 | 0.909 | 0.530 | 0.485 | 0.26/0.31/0.26/0.17 | 0.136 | 0.790 | 0.623 | 0.40/0.31/0.21/0.08 | 0.757 | 0.858 |
| qd_a | 10000 | 2 | 2704 | 4.75 | 0.402 | 0.367 | 0.968 | 0.749 | 0.936 | 0.34/0.22/0.23/0.20 | 0.477 | 0.822 | 0.940 | 0.31/0.31/0.18/0.20 | 0.894 | 0.661 |
| qd_a | 10000 | 4 | 2704 | 7.68 | 0.245 | 0.220 | 0.964 | 0.718 | 0.651 | 0.32/0.23/0.23/0.22 | 0.332 | 0.826 | 0.646 | 0.25/0.31/0.19/0.25 | 0.933 | 0.679 |

| dataset | n | L | the 10 bars with most gain: centre (row, col), principal orientation ('bent' = not a straight lattice line), pixels, share of cgbt's total gain |
|---|---|---|---|
| qd_dev | 10000 | 2 | (23,14) vertical bent 4px 0.62%; (23,13) / bent 5px 0.55%; (20,23) \ bent 5px 0.39%; (23,15) / bent 5px 0.37%; (3,6) / bent 5px 0.36%; (13,10) horizontal 5px 0.35%; (21,13) / bent 5px 0.34%; (16,1) vertical bent 3px 0.27%; (18,4) \ bent 5px 0.26%; (24,13) vertical bent 4px 0.26% |
| qd_dev | 10000 | 4 | (22,11) \ bent 9px 1.29%; (1,6) / bent 7px 1.08%; (22,10) \ 7px 0.95%; (22,18) vertical bent 8px 0.82%; (9,14) vertical 9px 0.78%; (6,6) horizontal bent 9px 0.78%; (24,11) \ bent 8px 0.77%; (4,9) / bent 6px 0.68%; (10,14) vertical 9px 0.64%; (18,25) horizontal bent 8px 0.62% |
| fashion_mnist | 10000 | 2 | (18,7) vertical bent 4px 1.77%; (21,24) horizontal bent 3px 0.88%; (17,4) \ bent 5px 0.81%; (19,14) / bent 5px 0.67%; (14,1) vertical bent 5px 0.66%; (14,26) horizontal bent 5px 0.57%; (3,7) vertical bent 4px 0.46%; (15,11) \ bent 5px 0.34%; (23,13) \ bent 4px 0.30%; (4,12) horizontal bent 5px 0.27% |
| fashion_mnist | 10000 | 4 | (4,2) / bent 6px 1.30%; (12,22) vertical bent 8px 1.01%; (23,18) horizontal bent 9px 0.76%; (11,22) vertical bent 9px 0.72%; (4,15) / bent 9px 0.66%; (15,14) vertical 3px 0.63%; (17,7) vertical bent 5px 0.55%; (4,23) \ bent 9px 0.55%; (1,10) \ bent 4px 0.55%; (4,11) / bent 9px 0.53% |
| mnist | 10000 | 2 | (1,18) horizontal bent 4px 1.02%; (6,15) \ bent 4px 1.00%; (14,16) horizontal bent 4px 0.91%; (13,6) horizontal bent 5px 0.85%; (15,13) / bent 5px 0.70%; (19,24) / bent 5px 0.60%; (15,11) / 5px 0.47%; (17,12) horizontal bent 5px 0.45%; (3,15) horizontal bent 5px 0.42%; (16,10) / 5px 0.42% |
| mnist | 10000 | 4 | (18,10) / bent 9px 2.62%; (12,10) vertical bent 9px 1.87%; (11,9) horizontal bent 9px 1.65%; (25,12) horizontal 9px 1.27%; (8,11) vertical bent 8px 1.22%; (17,8) / bent 9px 0.90%; (11,18) horizontal bent 9px 0.88%; (9,11) vertical bent 9px 0.86%; (18,8) \ bent 9px 0.78%; (16,10) horizontal bent 9px 0.74% |
| qd_a | 10000 | 2 | (20,24) / bent 4px 0.74%; (21,26) \ bent 4px 0.50%; (18,14) / 5px 0.42%; (12,4) vertical bent 5px 0.41%; (26,13) horizontal bent 4px 0.35%; (19,24) horizontal 4px 0.35%; (17,10) \ 4px 0.30%; (13,3) horizontal bent 5px 0.30%; (22,5) / 5px 0.28%; (23,9) / 4px 0.28% |
| qd_a | 10000 | 4 | (21,11) / 8px 1.35%; (9,5) vertical bent 8px 1.32%; (24,19) / 6px 1.15%; (13,3) / bent 9px 0.92%; (11,2) \ bent 8px 0.75%; (21,16) vertical bent 9px 0.74%; (25,12) horizontal bent 7px 0.70%; (21,18) \ 8px 0.67%; (4,10) horizontal bent 9px 0.66%; (16,22) / bent 9px 0.55% |

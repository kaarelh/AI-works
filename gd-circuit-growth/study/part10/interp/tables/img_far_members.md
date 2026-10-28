# Pooling-set members more than 2 grid steps from their centre (v3, n = 10000, seed 0)

Source: $SCRATCH/p10/interp_out_final/image/v3/<dataset>__n10000__s0.npz and the training rows of the fit (image_far_members.py). Ink frequency: fraction of the 10000 training images in which the pixel is non-zero.

| dataset | k | centres with a far member | far members | of which mirror pixels | ink freq. of those centres: median | max | ink freq. of all active pixels: median |
|---|---|---|---|---|---|---|---|
| fashion_mnist | 4 | 57 | 65 | 65 | 0.4002 | 0.9589 | 0.5246 |
| fashion_mnist | 9 | 547 | 1006 | 619 | 0.5316 | 0.9731 | 0.5246 |
| fashion_mnist | 16 | 776 | 3645 | 1740 | 0.5232 | 0.9731 | 0.5246 |
| mnist | 4 | 13 | 23 | 0 | 0.0001 | 0.0004 | 0.1028 |
| mnist | 9 | 75 | 186 | 0 | 0.0003 | 0.0355 | 0.1028 |
| mnist | 16 | 478 | 1394 | 36 | 0.0540 | 0.7285 | 0.1028 |
| qd_a | 4 | 0 | 0 | 0 | – | – | 0.3707 |
| qd_a | 9 | 53 | 59 | 33 | 0.5525 | 0.6137 | 0.3707 |
| qd_a | 16 | 645 | 2029 | 679 | 0.3727 | 0.6213 | 0.3707 |
| qd_dev | 4 | 0 | 0 | 0 | – | – | 0.3636 |
| qd_dev | 9 | 24 | 31 | 14 | 0.3450 | 0.4490 | 0.3636 |
| qd_dev | 16 | 604 | 1682 | 403 | 0.3651 | 0.6295 | 0.3636 |

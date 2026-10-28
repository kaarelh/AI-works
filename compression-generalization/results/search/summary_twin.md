# Twin bound: f bounded through a twin trained on part of its own training set

Boolean: n = 50, f = MLP (50, 512, 512, 1) trained exactly as in the main grid (same data, seed and stopping rule, so the same network). The twin f_s is trained with the same seed on the first s = frac*m training points; its errors on the other m - s points give an exact binomial bound (delta/2), and Pr[f != f_s] a Clopper-Pearson bound on 2x10^5 fresh inputs (delta/2). `compression` is the main paper's bound (Theorem 2 with the influence codec) on the same f. Means over seeds; frac = 0.5 is the pre-specified choice, the other fractions are shown for comparison.

| task | noise | m | seeds | test err f | compression bound | twin bound (frac 0.25 / 0.5 / 0.75) | test err twin (0.5) | Pr[f != twin] (0.5) |
|---|---|---|---|---|---|---|---|---|
| maj5 | 0 | 2000 | 3 | 0.0001 | 0.0188 | 0.0299 / 0.0047 / 0.0075 | 0.0002 | 0.0003 |
| maj5 | 0 | 4000 | 3 | 0.0000 | 0.0095 | 0.0016 / 0.0020 / 0.0037 | 0.0001 | 0.0001 |
| maj5 | 0 | 16000 | 3 | 0.0000 | 0.0024 | 0.0006 / 0.0005 / 0.0009 | 0.0000 | 0.0000 |
| fullmaj | 0 | 2000 | 3 | 0.0272 | 0.0688 | 0.1272 / 0.0848 / 0.0816 | 0.0389 | 0.0337 |
| fullmaj | 0 | 4000 | 3 | 0.0148 | 0.0267 | 0.0843 / 0.0631 / 0.0451 | 0.0267 | 0.0271 |
| fullmaj | 0 | 16000 | 3 | 0.0011 | 0.0037 | 0.0300 / 0.0108 / 0.0050 | 0.0043 | 0.0047 |
| parity3 | 0 | 2000 | 3 | 0.2876 | 0.3043 | 0.9302 / 0.8610 / 0.7801 | 0.4962 | 0.3261 |
| parity3 | 0 | 4000 | 3 | 0.0000 | 0.0070 | 1.0000 / 0.6194 / 0.0074 | 0.2968 | 0.2969 |
| parity3 | 0 | 16000 | 3 | 0.0000 | 0.0018 | 0.0003 / 0.0005 / 0.0009 | 0.0000 | 0.0000 |
| junta6 | 0 | 2000 | 3 | 0.1685 | 0.3422 | 0.7913 / 0.5703 / 0.3877 | 0.3069 | 0.2237 |
| junta6 | 0 | 4000 | 3 | 0.0223 | 0.0418 | 0.6304 / 0.3357 / 0.1422 | 0.1689 | 0.1493 |
| junta6 | 0 | 16000 | 3 | 0.0000 | 0.0047 | 0.0563 / 0.0016 / 0.0010 | 0.0004 | 0.0003 |
| teacher4 | 0 | 16000 | 3 | 0.0386 | - | 0.1872 / 0.1142 / 0.0830 | 0.0593 | 0.0479 |
| and3 | 0 | 2000 | 3 | 0.0000 | 0.0128 | 0.1035 / 0.0101 / 0.0089 | 0.0029 | 0.0028 |
| and3 | 0 | 4000 | 3 | 0.0000 | 0.0064 | 0.0131 / 0.0019 / 0.0037 | 0.0000 | 0.0000 |
| and3 | 0 | 16000 | 3 | 0.0000 | 0.0016 | 0.0003 / 0.0005 / 0.0009 | 0.0000 | 0.0000 |
| maj5 | 0.1 | 2000 | 3 | 0.2088 | 0.3050 | 0.4101 / 0.3690 / 0.3488 | 0.1953 | 0.1320 |
| maj5 | 0.1 | 4000 | 3 | 0.1696 | 0.2376 | 0.3507 / 0.3452 / 0.3163 | 0.2030 | 0.1243 |
| maj5 | 0.1 | 16000 | 3 | 0.1390 | 0.1741 | 0.3272 / 0.2300 / 0.2203 | 0.1444 | 0.0773 |
| parity3 | 0.1 | 2000 | 3 | 0.4786 | 1.0000 | 0.8998 / 0.8100 / 0.7378 | 0.4979 | 0.2829 |
| parity3 | 0.1 | 4000 | 3 | 0.1708 | 0.2275 | 0.9737 / 0.9177 / 0.4234 | 0.4815 | 0.4198 |
| parity3 | 0.1 | 16000 | 3 | 0.1362 | 0.1665 | 0.3056 / 0.2227 / 0.2108 | 0.1381 | 0.0734 |

## Images (unlabeled test inputs for the disagreement term)

f = MLP 784-H-10, Adam, 20 epochs, trained exactly as in the main paper's unlabeled-data experiments (same network). The twin is trained on a fixed random subset of s = frac*60000 training images (same seed unless `other`); its errors on the other training images give the binomial term, and its disagreement with f on the 10,000 test images, used without labels, the Clopper-Pearson term. `compression` is the main paper's unlabeled-data bound (Theorem 2, best of K configurations).

| data | H | twin seed | test err f | compression bound | frac | twin held-out errors | twin bound | test err twin | Pr[f != twin] on test inputs |
|---|---|---|---|---|---|---|---|---|---|
| mnist | 256 | same | 0.0197 | 0.368 | 0.25 | 1764/45000 | 0.0739 | 0.0351 | 0.0294 |
| mnist | 256 | same | 0.0197 | 0.368 | 0.5 | 801/30000 | 0.0501 | 0.0244 | 0.0187 |
| mnist | 256 | same | 0.0197 | 0.368 | 0.75 | 342/15000 | 0.0426 | 0.0212 | 0.0147 |
| mnist | 100 | same | 0.0229 | 0.313 | 0.25 | 2007/45000 | 0.0846 | 0.0421 | 0.0343 |
| mnist | 100 | same | 0.0229 | 0.313 | 0.5 | 944/30000 | 0.0567 | 0.0293 | 0.0202 |
| mnist | 100 | same | 0.0229 | 0.313 | 0.75 | 390/15000 | 0.0471 | 0.0243 | 0.0158 |
| mnist | 256 | other | 0.0197 | 0.368 | 0.5 | 800/30000 | 0.0522 | 0.0276 | 0.0207 |
| fashion | 256 | same | 0.1106 | 0.619 | 0.25 | 5795/45000 | 0.2326 | 0.1367 | 0.0948 |
| fashion | 256 | same | 0.1106 | 0.619 | 0.5 | 3486/30000 | 0.2096 | 0.1219 | 0.0841 |
| fashion | 256 | same | 0.1106 | 0.619 | 0.75 | 1662/15000 | 0.2003 | 0.1147 | 0.0789 |
| mnist | 1024 | same | 0.0155 | 0.255 | 0.5 | 672/30000 | 0.0417 | 0.0216 | 0.0150 |

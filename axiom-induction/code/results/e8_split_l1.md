# E8: a schema against its root split under the chain derivation likelihood (L1) and under L0

Command: `cd code/experiments && python3 e8_split_l1.py`. Seeds [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]. Wall time 30 s.

whole = {phi(?t), psi(?t), phi(?t) -> psi(?t)} with phi(t) = t+0=t, psi(t) = 0+t=t; split = phi split by the root of t (4 templates) + psi(?t) + the conditional. Data: the L1 chain (K = 1, c_stop = 1/2) from whole with fixed weights [0.5, 0.25, 0.25]; bodies from Q (wellspec) or from skewQ (skew). Prior difference split - whole: 76.4 bits (not included below).


(i) Exact tie at matched fixed weights (split weights w_phi q_r), L1: max |log P_split(d) - log P_whole(d)| over the first 2000 data of every run: 1.14e-13.


## wellspec (data fractions: phi-instances 0.47, psi-instances 0.61, conditionals 0.25)


| n | log2 BF split:whole, L1 (mean, range) | L0 |
|---|---|---|
| 16 | -1.65 (-3.4 to 0.8) | -2.23 (-4.5 to 1.2) |
| 64 | -3.49 (-5.5 to 1.2) | -2.80 (-5.2 to 0.1) |
| 256 | -7.27 (-8.3 to -6.1) | -6.82 (-7.8 to -5.6) |
| 1024 | -9.79 (-11.6 to -6.5) | -9.34 (-11.4 to -6.2) |
| 4096 | -12.98 (-14.6 to -11.3) | -12.86 (-14.5 to -11.4) |


Mean change per doubling of n between n = 1024 and 4096: L1 -1.60 bits, L0 -1.76 bits.


## skew (data fractions: phi-instances 0.50, psi-instances 0.62, conditionals 0.25)


| n | log2 BF split:whole, L1 (mean, range) | L0 |
|---|---|---|
| 16 | 1.73 (-1.5 to 8.3) | -0.18 (-2.3 to 5.6) |
| 64 | 7.72 (-0.4 to 14.3) | 1.23 (-2.9 to 5.7) |
| 256 | 48.78 (37.9 to 72.6) | 17.43 (6.4 to 34.2) |
| 1024 | 196.52 (165.4 to 232.8) | 72.05 (41.9 to 98.0) |
| 4096 | 817.04 (738.9 to 912.3) | 299.59 (210.7 to 351.5) |


Mean change per doubling of n between n = 1024 and 4096: L1 310.26 bits, L0 113.77 bits.

Mean gain per datum at n = 4096: L1 0.1995 bits, L0 0.0731 bits.

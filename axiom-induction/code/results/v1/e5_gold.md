# E5: spare slots, L_inf versus L_k, and Gold's text

Command: `cd code/experiments && python3 e5_gold.py`. Seeds [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]. Dirichlet alpha = 0.5. Wall time 18 s.


## (a) Spare slots: log2 Bayes factor of T + spare against T = {x+0=x schema}

Data: L0 citations of phi(?t), default Q. "pred. (Dirichlet only)" is the exact Dirichlet factor for a never-used component, log2[Gamma(2a)Gamma(a+n)/(Gamma(a)Gamma(2a+n))]; the log BF of an unused spare equals it exactly (likelihoods agree on every datum). The prior bits are not included in the Bayes factor; the posterior odds add -(extra prior bits): {'false sentence 0=S0': 8.4, 'disjoint schema ?u*0=0': 14.5, 'nested phi(S?z)': 21.3}.


| spare | n | mean log2 BF | min | max | pred. (Dirichlet only) | posterior log2 odds (mean) |
|---|---|---|---|---|---|---|
| false sentence 0=S0 | 1 | -1.00 | -1.00 | -1.00 | -1.00 | -9.41 |
| false sentence 0=S0 | 4 | -1.87 | -1.87 | -1.87 | -1.87 | -10.29 |
| false sentence 0=S0 | 16 | -2.84 | -2.84 | -2.84 | -2.84 | -11.25 |
| false sentence 0=S0 | 64 | -3.83 | -3.83 | -3.83 | -3.83 | -12.24 |
| false sentence 0=S0 | 256 | -4.83 | -4.83 | -4.83 | -4.83 | -13.24 |
| false sentence 0=S0 | 1024 | -5.83 | -5.83 | -5.83 | -5.83 | -14.24 |
| false sentence 0=S0 | 4096 | -6.83 | -6.83 | -6.83 | -6.83 | -15.24 |
| disjoint schema ?u*0=0 | 1 | -1.00 | -1.00 | -1.00 | -1.00 | -15.50 |
| disjoint schema ?u*0=0 | 4 | -1.87 | -1.87 | -1.87 | -1.87 | -16.37 |
| disjoint schema ?u*0=0 | 16 | -2.84 | -2.84 | -2.84 | -2.84 | -17.34 |
| disjoint schema ?u*0=0 | 64 | -3.83 | -3.83 | -3.83 | -3.83 | -18.33 |
| disjoint schema ?u*0=0 | 256 | -4.83 | -4.83 | -4.83 | -4.83 | -19.33 |
| disjoint schema ?u*0=0 | 1024 | -5.83 | -5.83 | -5.83 | -5.83 | -20.33 |
| disjoint schema ?u*0=0 | 4096 | -6.83 | -6.83 | -6.83 | -6.83 | -21.33 |
| nested phi(S?z) | 1 | 0.17 | -1.00 | 0.95 | -1.00 | -21.09 |
| nested phi(S?z) | 4 | -1.09 | -1.87 | -0.54 | -1.87 | -22.35 |
| nested phi(S?z) | 16 | -1.05 | -2.56 | 1.96 | -2.84 | -22.31 |
| nested phi(S?z) | 64 | -1.82 | -3.37 | -0.03 | -3.83 | -23.08 |
| nested phi(S?z) | 256 | -2.85 | -3.65 | -2.12 | -4.83 | -24.11 |
| nested phi(S?z) | 1024 | -3.25 | -3.93 | -2.18 | -5.83 | -24.51 |
| nested phi(S?z) | 4096 | -3.97 | -4.53 | -3.44 | -6.83 | -25.23 |


Slope of the mean log2 BF against log2 n between n = 256 and 4096: {'false sentence 0=S0': -0.5, 'disjoint schema ?u*0=0': -0.5, 'nested phi(S?z)': -0.281}


## (a2) Nested spare slot at large n (quadrature)

Under {phi(?t), phi(S?z)} a datum phi(t) has probability Q(t)(w1 + w2/qS) if t is S-rooted and Q(t) w1 otherwise, with qS = 0.350 the root probability of S; so the Bayes factor against {phi(?t)} depends only on n and the number nS of S-rooted data: BF = E[(1 - w2 + w2/qS)^nS (1 - w2)^(n - nS)], w2 ~ Beta(1/2, 1/2). nS ~ Binomial(n, qS), 200 draws per n (numpy seed 0); log2 BF by quadrature (substitution w2 = u^2, 2e5-point trapezoid rule). The cross-check against the exact DP is listed with the slopes below.


| n | mean log2 BF | min | max |
|---|---|---|---|
| 100 | -2.11 | -3.47 | 3.27 |
| 1000 | -2.91 | -4.27 | 0.99 |
| 10000 | -3.87 | -5.21 | 1.98 |
| 100000 | -4.75 | -5.92 | -0.88 |
| 1000000 | -5.50 | -6.78 | 0.61 |
| 10000000 | -6.41 | -7.56 | -3.64 |
| 100000000 | -7.27 | -8.44 | -3.28 |


Slopes of the mean log2 BF against log2 n: {'per decade': [-0.24, -0.29, -0.267, -0.224, -0.274, -0.26], 'least-squares slope against log2 n': -0.2594, 'check (seed, exact DP, quadrature) at n=500': [(3, -3.97229, -3.97236), (4, -3.16922, -3.16926)]}


## (b) Data from L_5: posterior over {L_1..L_40, L_inf}


Q_num: P(S^j 0) = 2^-(j+1). Prior bits: {'L_1': 10.9, 'L_2': 26.0, 'L_3': 42.7, 'L_4': 65.1, 'L_5': 89.4, 'L_6': 117.6, 'L_7': 149.8, 'L_8': 187.9, 'L_inf': 17.1}.


| n | mass L_5 | mass L_inf | MAP (count over seeds) |
|---|---|---|---|
| 1 | 4e-22 | 0.899 | L_inf x9, L_1 x1 |
| 2 | 9e-22 | 0.900 | L_inf x9, L_1 x1 |
| 4 | 4e-21 | 1.000 | L_inf x10 |
| 8 | 6e-20 | 1.000 | L_inf x10 |
| 16 | 2e-19 | 1.000 | L_inf x10 |
| 32 | 5e-16 | 1.000 | L_inf x10 |
| 64 | 2e-06 | 1.000 | L_inf x10 |
| 128 | 0.661 | 0.339 | L_5 x7, L_inf x3 |
| 256 | 1.000 | 5e-20 | L_5 x10 |
| 512 | 1.000 | 1e-67 | L_5 x10 |
| 1024 | 1.000 | 1e-158 | L_5 x10 |
| 2048 | 1.000 | 0 | L_5 x10 |


## (b) Data from L_inf: posterior over {L_1..L_40, L_inf}


Q_num: P(S^j 0) = 2^-(j+1). Prior bits: {'L_1': 10.9, 'L_2': 26.0, 'L_3': 42.7, 'L_4': 65.1, 'L_5': 89.4, 'L_6': 117.6, 'L_7': 149.8, 'L_8': 187.9, 'L_inf': 17.1}.


| n | mass L_5 | mass L_inf | MAP (count over seeds) |
|---|---|---|---|
| 1 | 9e-23 | 0.700 | L_inf x7, L_1 x3 |
| 2 | 1e-22 | 0.798 | L_inf x8, L_1 x2 |
| 4 | 2e-22 | 0.986 | L_inf x10 |
| 8 | 1e-22 | 0.999 | L_inf x10 |
| 16 | 7e-23 | 1.000 | L_inf x10 |
| 32 | 2e-23 | 1.000 | L_inf x10 |
| 64 | 0 | 1.000 | L_inf x10 |
| 128 | 0 | 1.000 | L_inf x10 |
| 256 | 0 | 1.000 | L_inf x10 |
| 512 | 0 | 1.000 | L_inf x10 |
| 1024 | 0 | 1.000 | L_inf x10 |
| 2048 | 0 | 1.000 | L_inf x10 |


## (c) Gold's text for L_inf against the MAP learner over {L_1..L_60, L_inf}

Stage i presents phi(0), ..., phi(S^(i-1) 0) round-robin until the MAP is L_i.


| stage i | data in stage | total data | MAP at end of stage |
|---|---|---|---|
| 1 | 1 | 1 | L_1 |
| 2 | 24 | 25 | L_2 |
| 3 | 81 | 106 | L_3 |
| 4 | 115 | 221 | L_4 |
| 5 | 104 | 325 | L_5 |
| 6 | 83 | 408 | L_6 |
| 7 | 68 | 476 | L_7 |
| 8 | 55 | 531 | L_8 |
| 9 | 45 | 576 | L_9 |
| 10 | 39 | 615 | L_10 |
| 11 | 33 | 648 | L_11 |
| 12 | 33 | 681 | L_12 |
| 13 | 32 | 713 | L_13 |
| 14 | 27 | 740 | L_14 |

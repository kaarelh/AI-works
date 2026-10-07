# E3: DTRC on untagged mixtures (Q3)

Command: `python3 experiments/e3_mix.py`; seeds [0, 1, 2, 3, 4].

## PA-mix

| seed | learner | ARI | purity | clusters | exact targets | held-out accepted | probes | non-target | refuted | oracle calls | time (s) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | DTRC | 1.0 | 1.0 | 11 | 11/11 | 107/107 | 47 | 0 | 0 | 866 | 0.55 |
| 0 | skeleton(k) | 0.9701 | 0.9231 | 11 | 7/11 | 107/107 | 107 | 60 | 56 | 0 | 0.07 |
| 0 | tagged DT°_F | - | - | 11 | 11/11 | -/- | - | - | - | - | - |
| 0 | fo-lgg/tag named | - | - | 11 | -/11 | 107/107 | 36 | 20 | 7 | - | - |
| 0 | fo-lgg/tag debruijn | - | - | 11 | -/11 | 107/107 | 36 | 20 | 7 | - | - |
| 0 | pattern-lgg/tag | - | - | 11 | 10/11 | 107/107 | 46 | 20 | 5 | - | - |
| 1 | DTRC | 1.0 | 1.0 | 11 | 11/11 | 107/107 | 46 | 0 | 0 | 767 | 0.38 |
| 1 | skeleton(k) | 0.9719 | 0.9423 | 11 | 9/11 | 107/107 | 76 | 31 | 28 | 0 | 0.06 |
| 1 | tagged DT°_F | - | - | 11 | 11/11 | -/- | - | - | - | - | - |
| 1 | fo-lgg/tag named | - | - | 11 | -/11 | 107/107 | 36 | 20 | 7 | - | - |
| 1 | fo-lgg/tag debruijn | - | - | 11 | -/11 | 107/107 | 36 | 20 | 7 | - | - |
| 1 | pattern-lgg/tag | - | - | 11 | 10/11 | 107/107 | 45 | 20 | 5 | - | - |
| 2 | DTRC | 1.0 | 1.0 | 11 | 11/11 | 107/107 | 48 | 0 | 0 | 653 | 0.58 |
| 2 | skeleton(k) | 0.9659 | 0.9184 | 11 | 8/11 | 100/107 | 95 | 54 | 49 | 0 | 0.05 |
| 2 | tagged DT°_F | - | - | 11 | 11/11 | -/- | - | - | - | - | - |
| 2 | fo-lgg/tag named | - | - | 11 | -/11 | 107/107 | 36 | 20 | 4 | - | - |
| 2 | fo-lgg/tag debruijn | - | - | 11 | -/11 | 107/107 | 36 | 20 | 4 | - | - |
| 2 | pattern-lgg/tag | - | - | 11 | 10/11 | 107/107 | 44 | 20 | 5 | - | - |
| 3 | DTRC | 1.0 | 1.0 | 11 | 10/11 | 98/107 | 45 | 0 | 0 | 1206 | 0.72 |
| 3 | skeleton(k) | 0.9928 | 0.9796 | 11 | 8/11 | 98/107 | 66 | 18 | 16 | 0 | 0.06 |
| 3 | tagged DT°_F | - | - | 11 | 11/11 | -/- | - | - | - | - | - |
| 3 | fo-lgg/tag named | - | - | 11 | -/11 | 107/107 | 36 | 20 | 5 | - | - |
| 3 | fo-lgg/tag debruijn | - | - | 11 | -/11 | 107/107 | 36 | 20 | 5 | - | - |
| 3 | pattern-lgg/tag | - | - | 11 | 10/11 | 107/107 | 45 | 20 | 3 | - | - |
| 4 | DTRC | 1.0 | 1.0 | 11 | 11/11 | 107/107 | 46 | 0 | 0 | 867 | 0.46 |
| 4 | skeleton(k) | 0.9723 | 0.9375 | 11 | 8/11 | 105/107 | 75 | 37 | 34 | 0 | 0.06 |
| 4 | tagged DT°_F | - | - | 11 | 11/11 | -/- | - | - | - | - | - |
| 4 | fo-lgg/tag named | - | - | 11 | -/11 | 107/107 | 36 | 20 | 5 | - | - |
| 4 | fo-lgg/tag debruijn | - | - | 11 | -/11 | 107/107 | 36 | 20 | 5 | - | - |
| 4 | pattern-lgg/tag | - | - | 11 | 10/11 | 107/107 | 45 | 19 | 8 | - | - |

DTRC per target (E = exact; held-out accepted/total), seeds [0, 1, 2, 3, 4]:

| target | seed 0 | seed 1 | seed 2 | seed 3 | seed 4 |
|---|---|---|---|---|---|
| Q1 | E (1/1) | E (1/1) | E (1/1) | E (1/1) | E (1/1) |
| Q2 | E (1/1) | E (1/1) | E (1/1) | E (1/1) | E (1/1) |
| Q3 | E (1/1) | E (1/1) | E (1/1) | E (1/1) | E (1/1) |
| Q4 | E (1/1) | E (1/1) | E (1/1) | E (1/1) | E (1/1) |
| Q5 | E (1/1) | E (1/1) | E (1/1) | E (1/1) | E (1/1) |
| Q6 | E (1/1) | E (1/1) | E (1/1) | E (1/1) | E (1/1) |
| Q7 | E (1/1) | E (1/1) | E (1/1) | E (1/1) | E (1/1) |
| Ind | E (40/40) | E (40/40) | E (40/40) | E (40/40) | E (40/40) |
| U_add0 | E (20/20) | E (20/20) | E (20/20) | - (11/20) | E (20/20) |
| U_mul0 | E (20/20) | E (20/20) | E (20/20) | E (20/20) | E (20/20) |
| U_0add | E (20/20) | E (20/20) | E (20/20) | E (20/20) | E (20/20) |

Examples of accepted sentences refuted by the oracle:

* skeleton(k) (seed 0): `w0+SSSSSS0=SSSSSS0`
* fo-lgg/tag named (seed 0): `(0=0 & (Ax.1=0 -> ~1=x)) -> (Ax.1=0)`
* fo-lgg/tag debruijn (seed 0): `(0=0 & (Ax.1=0 -> ~1=x)) -> (Ax.1=0)`
* pattern-lgg/tag (seed 0): `(w0=0 & (Ax.0<x -> (Ey.y=1))) -> (Ax.0<x)`

## ZF-mix

| seed | learner | ARI | purity | clusters | exact targets | held-out accepted | probes | non-target | refuted | oracle calls | time (s) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | DTRC | 1.0 | 1.0 | 9 | 9/9 | 96/96 | 66 | 0 | 0 | 820 | 6.01 |
| 0 | skeleton(k) | 1.0 | 1.0 | 9 | 9/9 | 96/96 | 66 | 0 | 0 | 0 | 0.1 |
| 0 | tagged DT°_F | - | - | 9 | 9/9 | -/- | - | - | - | - | - |
| 0 | fo-lgg/tag named | - | - | 9 | -/9 | 96/96 | 61 | 44 | 2 | - | - |
| 0 | fo-lgg/tag debruijn | - | - | 9 | -/9 | 96/96 | 52 | 25 | 1 | - | - |
| 0 | pattern-lgg/tag | - | - | 9 | 9/9 | 96/96 | 51 | 0 | 0 | - | - |
| 1 | DTRC | 1.0 | 1.0 | 9 | 9/9 | 96/96 | 66 | 0 | 0 | 766 | 5.6 |
| 1 | skeleton(k) | 1.0 | 1.0 | 9 | 9/9 | 96/96 | 66 | 0 | 0 | 0 | 0.05 |
| 1 | tagged DT°_F | - | - | 9 | 9/9 | -/- | - | - | - | - | - |
| 1 | fo-lgg/tag named | - | - | 9 | -/9 | 96/96 | 62 | 45 | 4 | - | - |
| 1 | fo-lgg/tag debruijn | - | - | 9 | -/9 | 96/96 | 56 | 25 | 3 | - | - |
| 1 | pattern-lgg/tag | - | - | 9 | 9/9 | 96/96 | 54 | 0 | 0 | - | - |
| 2 | DTRC | 1.0 | 1.0 | 9 | 9/9 | 96/96 | 65 | 0 | 0 | 883 | 6.47 |
| 2 | skeleton(k) | 1.0 | 1.0 | 9 | 9/9 | 96/96 | 65 | 0 | 0 | 0 | 0.03 |
| 2 | tagged DT°_F | - | - | 9 | 9/9 | -/- | - | - | - | - | - |
| 2 | fo-lgg/tag named | - | - | 9 | -/9 | 96/96 | 60 | 44 | 3 | - | - |
| 2 | fo-lgg/tag debruijn | - | - | 9 | -/9 | 96/96 | 51 | 26 | 1 | - | - |
| 2 | pattern-lgg/tag | - | - | 9 | 9/9 | 96/96 | 45 | 0 | 0 | - | - |
| 3 | DTRC | 1.0 | 1.0 | 9 | 9/9 | 96/96 | 63 | 0 | 0 | 780 | 5.67 |
| 3 | skeleton(k) | 1.0 | 1.0 | 9 | 9/9 | 96/96 | 63 | 0 | 0 | 0 | 0.07 |
| 3 | tagged DT°_F | - | - | 9 | 9/9 | -/- | - | - | - | - | - |
| 3 | fo-lgg/tag named | - | - | 9 | -/9 | 96/96 | 61 | 45 | 2 | - | - |
| 3 | fo-lgg/tag debruijn | - | - | 9 | -/9 | 96/96 | 53 | 27 | 2 | - | - |
| 3 | pattern-lgg/tag | - | - | 9 | 9/9 | 96/96 | 43 | 0 | 0 | - | - |
| 4 | DTRC | 1.0 | 1.0 | 9 | 9/9 | 96/96 | 64 | 0 | 0 | 946 | 7.88 |
| 4 | skeleton(k) | 1.0 | 1.0 | 9 | 9/9 | 96/96 | 64 | 0 | 0 | 0 | 0.03 |
| 4 | tagged DT°_F | - | - | 9 | 9/9 | -/- | - | - | - | - | - |
| 4 | fo-lgg/tag named | - | - | 9 | -/9 | 96/96 | 61 | 45 | 4 | - | - |
| 4 | fo-lgg/tag debruijn | - | - | 9 | -/9 | 96/96 | 51 | 25 | 2 | - | - |
| 4 | pattern-lgg/tag | - | - | 9 | 9/9 | 96/96 | 46 | 0 | 0 | - | - |

DTRC per target (E = exact; held-out accepted/total), seeds [0, 1, 2, 3, 4]:

| target | seed 0 | seed 1 | seed 2 | seed 3 | seed 4 |
|---|---|---|---|---|---|
| Ext | E (1/1) | E (1/1) | E (1/1) | E (1/1) | E (1/1) |
| Pair | E (1/1) | E (1/1) | E (1/1) | E (1/1) | E (1/1) |
| Union | E (1/1) | E (1/1) | E (1/1) | E (1/1) | E (1/1) |
| Power | E (1/1) | E (1/1) | E (1/1) | E (1/1) | E (1/1) |
| Inf | E (1/1) | E (1/1) | E (1/1) | E (1/1) | E (1/1) |
| Found | E (1/1) | E (1/1) | E (1/1) | E (1/1) | E (1/1) |
| Sep | E (30/30) | E (30/30) | E (30/30) | E (30/30) | E (30/30) |
| Rep | E (30/30) | E (30/30) | E (30/30) | E (30/30) | E (30/30) |
| EInd | E (30/30) | E (30/30) | E (30/30) | E (30/30) | E (30/30) |

Examples of accepted sentences refuted by the oracle:

* fo-lgg/tag named (seed 0): `Ax.(Ay.y in x -> (Ez.~x in z & (Au.y in z -> u=z))) -> (Ey.Az.z in y <-> (Eu.u in x & ~u in u))`
* fo-lgg/tag debruijn (seed 0): `Ax.(Ay.y in x -> (Ez.~x in z & (Au.y in z -> u=z))) -> (Ey.Az.z in y <-> (Eu.u in x & ~u in u))`

Wall time: 43.8s

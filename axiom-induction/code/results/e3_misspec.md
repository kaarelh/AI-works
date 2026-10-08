# E3: misspecification

Command: `cd code/experiments && python3 e3_misspec.py`. Seeds [0, 1, 2, 3, 4]. Dirichlet alpha = 0.5; prior 2^-bits; derivability |-_1 (part a), citation |-_0 (part b). Causal pools (data-derived theories built only from data already seen). Wall time 606 s.


## (a) phi = x+0=x, data = instances with a misspecified term law

Columns: posterior mass of H_sch, of theories with the same instance set as phi(?t) (H_sch, frag1, frag2, spare_nested = C_1, C_2), of subset theories (incomplete: overspec, N_m, over-specific Min), of superset theories (over-general, spare_false, spare_schema, H_open), of forall-type theories (H_all, H_all+sch, H_all+open), of Mem; P(|-inst) = mean mass deriving 3 held-out closed instances (9+0=9, (2+3)+0=2+3, (1*4)+0=1*4); "gain" = code length of H_sch minus that of the MAP (bits); MAP (count) with its instance-set relation.


### generator heavy, L0 (data: S(0*0)+0=S(0*0), SSSSSSSSS0+0=SSSSSSSSS0, 1+0=1 ...)


Excluded for lack of exact L1: none. Fallback counters, summed over seeds: likelihood 0, derivability oracle 0.


| n | H_sch | same inst. | subset | superset | forall-type | Mem | other | P(|-inst) | P(|-forall) | gain (bits): mean (range) | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 8 | 0.999 | 0.999 | 2e-05 | 0.001 | 1e-06 | 3e-44 | 0 | 1.000 | 5e-04 | 0 (0 to 0) | H_sch [same] x5 |
| 32 | 0.971 | 1.000 | 1e-10 | 3e-04 | 7e-07 | 8e-170 | 0 | 1.000 | 7e-07 | 0 (0 to 0) | H_sch [same] x5 |
| 128 | 0.167 | 1.000 | 0 | 2e-05 | 6e-08 | 0 | 0 | 1.000 | 6e-08 | 20.0 (0 to 54.6) | C_2 [same] x2; skel2@8 [same] x2; H_sch [same] x1 |
| 512 | 8e-60 | 1.000 | 0 | 6e-64 | 1e-66 | 0 | 0 | 1.000 | 1e-66 | 212.4 (194.1 to 237.8) | C_2 [same] x3; skel2@8 [same] x2 |
| 1024 | 1e-132 | 1.000 | 0 | 6e-137 | 1e-139 | 0 | 0 | 1.000 | 1e-139 | 455.2 (435.9 to 470.8) | C_2 [same] x3; skel2@8 [same] x2 |


Code length minus that of H_sch (bits, mean over seeds; spare_nested = C_1):


| n | spare_nested | C_2 |
|---|---|---|
| 8 | 21.2 | 43.4 |
| 32 | 14.9 | 29.8 |
| 128 | -0.2 | -11.5 |
| 512 | -76.3 | -204.4 |
| 1024 | -165.5 | -447.0 |


### generator heavy, L1 (data: S(0*0)+0=S(0*0), SSSSSSSSS0+0=SSSSSSSSS0, 1+0=1 ...)


Excluded for lack of exact L1: none. Fallback counters, summed over seeds: likelihood 0, derivability oracle 0.


| n | H_sch | same inst. | subset | superset | forall-type | Mem | other | P(|-inst) | P(|-forall) | gain (bits): mean (range) | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 8 | 0.995 | 0.995 | 2e-05 | 0.001 | 0.004 | 3e-44 | 0 | 1.000 | 0.004 | 0 (0 to 0) | H_sch [same] x5 |
| 32 | 0.971 | 1.000 | 1e-10 | 3e-04 | 9e-07 | 8e-170 | 0 | 1.000 | 9e-07 | 0 (0 to 0) | H_sch [same] x5 |
| 128 | 0.167 | 1.000 | 0 | 2e-05 | 8e-08 | 0 | 0 | 1.000 | 8e-08 | 20.0 (0 to 54.6) | C_2 [same] x2; skel2@8 [same] x2; H_sch [same] x1 |
| 512 | 8e-60 | 1.000 | 0 | 6e-64 | 2e-66 | 0 | 0 | 1.000 | 2e-66 | 212.4 (194.1 to 237.8) | C_2 [same] x3; skel2@8 [same] x2 |


Code length minus that of H_sch (bits, mean over seeds; spare_nested = C_1):


| n | spare_nested | C_2 |
|---|---|---|
| 8 | 21.2 | 43.4 |
| 32 | 14.9 | 29.8 |
| 128 | -0.2 | -11.5 |
| 512 | -76.3 | -204.4 |


### generator numerals, L0 (data: 0+0=0, SSSSSSSSS0+0=SSSSSSSSS0, SSSSS0+0=SSSSS0 ...)


Excluded for lack of exact L1: none. Fallback counters, summed over seeds: likelihood 0, derivability oracle 0.


| n | H_sch | same inst. | subset | superset | forall-type | Mem | other | P(|-inst) | P(|-forall) | gain (bits): mean (range) | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 8 | 0.789 | 0.789 | 0.199 | 0.011 | 1e-06 | 1e-21 | 0 | 0.867 | 0.011 | 1.6 (0 to 7.9) | H_sch [same] x4; min0@8:S?f0+0=S?f0 [subset] x1 |
| 32 | 0.287 | 0.288 | 0.712 | 8e-05 | 2e-07 | 2e-58 | 0 | 0.525 | 2e-07 | 4.1 (0 to 8.7) | overspec{0,S} [subset] x3; H_sch [same] x1; skel4@32 [subset] x1 |
| 128 | 1e-43 | 9e-23 | 1.000 | 2e-47 | 5e-50 | 4e-65 | 0 | 0.333 | 5e-50 | 165.9 (139.9 to 215.5) | N_4 [subset] x3; N_5 [subset] x2 |
| 512 | 0 | 5e-220 | 1.000 | 0 | 0 | 9e-246 | 0 | 0.333 | 0 | 1271.2 (1233.3 to 1339.2) | N_9 [subset] x4; N_10 [subset] x1 |
| 1024 | 0 | 0 | 1.000 | 0 | 0 | 3e-247 | 0 | 0.333 | 0 | 2896.7 (2765.9 to 3106.3) | N_11 [subset] x3; N_12 [subset] x2 |


Code length minus that of H_sch (bits, mean over seeds; spare_nested = C_1):


| n | N_4 | N_8 | N_9 | N_10 | N_11 | N_12 | N_13 | N_16 |
|---|---|---|---|---|---|---|---|---|
| 8 | 66.2 | 197.7 | 241.6 | 289.7 | 342.1 | 398.7 | 459.4 | 668.4 |
| 32 | 25.7 | 143.1 | 185.6 | 232.8 | 284.7 | 340.1 | 399.9 | 608.2 |
| 128 | -162.0 | -119.6 | -86.6 | -48.0 | -3.0 | 46.6 | 102.2 | 300.2 |
| 512 | -978.8 | -1260.3 | -1270.0 | -1264.7 | -1248.5 | -1220.7 | -1181.0 | -1015.0 |
| 1024 | -2063.1 | -2763.7 | -2835.1 | -2874.8 | -2894.6 | -2895.1 | -2875.9 | -2751.7 |


### generator numerals, L1 (data: 0+0=0, SSSSSSSSS0+0=SSSSSSSSS0, SSSSS0+0=SSSSS0 ...)


Excluded for lack of exact L1: none. Fallback counters, summed over seeds: likelihood 0, derivability oracle 0.


| n | H_sch | same inst. | subset | superset | forall-type | Mem | other | P(|-inst) | P(|-forall) | gain (bits): mean (range) | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 8 | 0.786 | 0.786 | 0.199 | 0.011 | 0.003 | 1e-21 | 0 | 0.867 | 0.014 | 1.6 (0 to 7.9) | H_sch [same] x4; min0@8:S?f0+0=S?f0 [subset] x1 |
| 32 | 0.287 | 0.288 | 0.712 | 8e-05 | 3e-07 | 2e-58 | 0 | 0.525 | 3e-07 | 4.1 (0 to 8.7) | overspec{0,S} [subset] x3; H_sch [same] x1; skel4@32 [subset] x1 |
| 128 | 1e-43 | 9e-23 | 1.000 | 2e-47 | 7e-50 | 4e-65 | 0 | 0.333 | 7e-50 | 165.9 (139.9 to 215.5) | N_4 [subset] x3; N_5 [subset] x2 |
| 512 | 0 | 5e-220 | 1.000 | 0 | 0 | 9e-246 | 0 | 0.333 | 0 | 1271.2 (1233.3 to 1339.2) | N_9 [subset] x4; N_10 [subset] x1 |


Code length minus that of H_sch (bits, mean over seeds; spare_nested = C_1):


| n | N_4 | N_8 | N_9 | N_10 | N_11 | N_12 | N_13 | N_16 |
|---|---|---|---|---|---|---|---|---|
| 8 | 66.2 | 197.7 | 241.6 | 289.7 | 342.1 | 398.7 | 459.4 | 668.4 |
| 32 | 25.7 | 143.1 | 185.6 | 232.8 | 284.7 | 340.1 | 399.9 | 608.2 |
| 128 | -162.0 | -119.6 | -86.6 | -48.0 | -3.0 | 46.6 | 102.2 | 300.2 |
| 512 | -978.8 | -1260.3 | -1270.0 | -1264.7 | -1248.5 | -1220.7 | -1181.0 | -1015.0 |


### generator small, L0 (data: 2+0=2, 0+0=0, 0+0=0 ...)


Excluded for lack of exact L1: none. Fallback counters, summed over seeds: likelihood 0, derivability oracle 0.


| n | H_sch | same inst. | subset | superset | forall-type | Mem | other | P(|-inst) | P(|-forall) | gain (bits): mean (range) | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 8 | 0.835 | 0.835 | 2e-05 | 0.163 | 1e-06 | 0.002 | 0 | 0.998 | 0.162 | 0 (0 to 0) | H_sch [same] x5 |
| 32 | 0.999 | 0.999 | 8e-10 | 0.001 | 7e-07 | 2e-11 | 0 | 1.000 | 9e-04 | 0 (0 to 0) | H_sch [same] x5 |
| 128 | 1.000 | 1.000 | 0 | 1e-04 | 3e-07 | 9e-25 | 0 | 1.000 | 3e-07 | 0 (0 to 0) | H_sch [same] x5 |
| 512 | 1.000 | 1.000 | 0 | 7e-05 | 2e-07 | 3e-11 | 0 | 1.000 | 2e-07 | 0 (0 to 0) | H_sch [same] x5 |
| 1024 | 6e-47 | 1e-39 | 0 | 3e-51 | 7e-54 | 1.000 | 0 | 1e-39 | 7e-54 | 156.1 (151.3 to 159.9) | Mem [mem] x5 |


### generator small, L1 (data: 2+0=2, 0+0=0, 0+0=0 ...)


Excluded for lack of exact L1: none. Fallback counters, summed over seeds: likelihood 0, derivability oracle 0.


| n | H_sch | same inst. | subset | superset | forall-type | Mem | other | P(|-inst) | P(|-forall) | gain (bits): mean (range) | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 8 | 0.833 | 0.833 | 2e-05 | 0.162 | 0.003 | 0.002 | 0 | 0.998 | 0.165 | 0 (0 to 0) | H_sch [same] x5 |
| 32 | 0.999 | 0.999 | 8e-10 | 0.001 | 1e-06 | 2e-11 | 0 | 1.000 | 9e-04 | 0 (0 to 0) | H_sch [same] x5 |
| 128 | 1.000 | 1.000 | 0 | 1e-04 | 5e-07 | 9e-25 | 0 | 1.000 | 5e-07 | 0 (0 to 0) | H_sch [same] x5 |
| 512 | 1.000 | 1.000 | 0 | 7e-05 | 2e-07 | 3e-11 | 0 | 1.000 | 2e-07 | 0 (0 to 0) | H_sch [same] x5 |


### generator skewQ, L0 (data: 0+0=0, 0+0=0, 0+0=0 ...)


Excluded for lack of exact L1: none. Fallback counters, summed over seeds: likelihood 0, derivability oracle 0.


| n | H_sch | same inst. | subset | superset | forall-type | Mem | other | P(|-inst) | P(|-forall) | gain (bits): mean (range) | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 8 | 0.973 | 0.973 | 2e-11 | 0.027 | 1e-06 | 2e-06 | 0 | 1.000 | 0.026 | 0 (0 to 0) | H_sch [same] x5 |
| 32 | 1.000 | 1.000 | 5e-14 | 3e-04 | 7e-07 | 1e-66 | 0 | 1.000 | 1e-06 | 0 (0 to 0) | H_sch [same] x5 |
| 128 | 1.000 | 1.000 | 0 | 1e-04 | 3e-07 | 0 | 0 | 1.000 | 3e-07 | 0 (0 to 0) | H_sch [same] x5 |
| 512 | 4e-17 | 1.000 | 0 | 3e-21 | 7e-24 | 0 | 0 | 1.000 | 7e-24 | 70.5 (52.1 to 97.8) | frag1 [same] x5 |
| 1024 | 2e-57 | 1.000 | 0 | 1e-61 | 3e-64 | 0 | 0 | 1.000 | 3e-64 | 211.8 (186.0 to 250.6) | frag1 [same] x5 |


### generator skewQ, L1 (data: 0+0=0, 0+0=0, 0+0=0 ...)


Excluded for lack of exact L1: none. Fallback counters, summed over seeds: likelihood 0, derivability oracle 0.


| n | H_sch | same inst. | subset | superset | forall-type | Mem | other | P(|-inst) | P(|-forall) | gain (bits): mean (range) | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 8 | 0.970 | 0.970 | 2e-11 | 0.027 | 0.004 | 2e-06 | 0 | 1.000 | 0.029 | 0 (0 to 0) | H_sch [same] x5 |
| 32 | 1.000 | 1.000 | 5e-14 | 3e-04 | 1e-06 | 1e-66 | 0 | 1.000 | 1e-06 | 0 (0 to 0) | H_sch [same] x5 |
| 128 | 1.000 | 1.000 | 0 | 1e-04 | 5e-07 | 0 | 0 | 1.000 | 5e-07 | 0 (0 to 0) | H_sch [same] x5 |
| 512 | 4e-17 | 1.000 | 0 | 3e-21 | 1e-23 | 0 | 0 | 1.000 | 1e-23 | 70.5 (52.1 to 97.8) | frag1 [same] x5 |


## (b) PA mixture with a misspecified motive law (L0)

Columns as in E2: masses by the tags of pa_common.pa_classify (equivalent to T*, sound and strictly weaker, unsound, unknown); the pool includes the nested fragments T* + T_f (equivalent to T*).


### generator dtrc-motive


| n | T* | equiv. to T* | weaker | unsound (mean) | unknown | unsound (max over seeds) | P(|-held-out Ind) | max P(|-false) | MAP [tag] (count) |
|---|---|---|---|---|---|---|---|---|---|
| 16 | 1e-13 | 1e-13 | 0.748 | 0.252 | 0 | 1.000 | 1.000 | 0.252 | skel4@16 [weaker] x1; Q-lumped [no] x1; T*-Q7 [weaker] x1 |
| 64 | 0.593 | 0.593 | 0.400 | 0.007 | 0 | 0.012 | 1.000 | 0.007 | T* [yes] x3; T*-Q4 [weaker] x1; T*-Q2 [weaker] x1 |
| 256 | 0.994 | 0.994 | 0 | 0.006 | 0 | 0.006 | 1.000 | 0.006 | T* [yes] x5 |
| 1024 | 1e-24 | 1.000 | 0 | 4e-27 | 0 | 2e-26 | 1.000 | 4e-27 | T*+T_ex [yes] x5 |
| 2048 | 5e-70 | 1.000 | 0 | 1e-72 | 0 | 5e-72 | 1.000 | 1e-72 | T*+T_ex [yes] x5 |


Code length minus that of T* at n = 2048 (bits; negative = preferred to T*; "-" = not in the pool at that n or infinite):


| seed | frag-complete | trim:frag-complete | T*+T_imp | T*+T_and | T*+T_ex | T*+T_= | frag-atoms | Mem |
|---|---|---|---|---|---|---|---|---|
| 0 | 26.3 | - | 91.2 | - | -261.4 | 91.6 | - | 149424.0 |
| 1 | 48.4 | - | 90.9 | - | -317.7 | 91.7 | - | 146865.6 |
| 2 | 125.2 | - | 90.7 | - | -228.0 | 91.6 | - | 144366.2 |
| 3 | 7.7 | - | 91.4 | - | -286.7 | 91.7 | - | 143737.0 |
| 4 | 26.8 | - | 91.4 | - | -297.4 | 91.7 | - | 150451.1 |


### generator root-skew


| n | T* | equiv. to T* | weaker | unsound (mean) | unknown | unsound (max over seeds) | P(|-held-out Ind) | max P(|-false) | MAP [tag] (count) |
|---|---|---|---|---|---|---|---|---|---|
| 16 | 2e-10 | 2e-10 | 0.483 | 0.517 | 0 | 1.000 | 1.000 | 0.517 | skel4@16 [no] x2; skel4@16 [weaker] x1; Q-lumped [no] x1 |
| 64 | 0.790 | 0.790 | 0.200 | 0.010 | 0 | 0.012 | 1.000 | 0.010 | T* [yes] x4; T*-Q6 [weaker] x1 |
| 256 | 0.049 | 1.000 | 0 | 3e-04 | 0 | 0.001 | 1.000 | 3e-04 | T*+T_imp [yes] x5 |
| 1024 | 3e-160 | 1.000 | 0 | 1e-162 | 0 | 5e-162 | 0.400 | 1e-162 | frag-observed@16 [yes] x3; frag-observed@32 [yes] x2 |
| 2048 | 0 | 1.000 | 0 | 0 | 0 | 0 | 0.400 | 0 | frag-observed@16 [yes] x3; frag-observed@32 [yes] x2 |


Code length minus that of T* at n = 2048 (bits; negative = preferred to T*; "-" = not in the pool at that n or infinite):


| seed | frag-complete | trim:frag-complete | T*+T_imp | T*+T_and | T*+T_ex | T*+T_= | frag-atoms | Mem |
|---|---|---|---|---|---|---|---|---|
| 0 | -1009.6 | - | -789.2 | - | -16.1 | 91.7 | - | 250891.6 |
| 1 | -1046.2 | - | -900.5 | - | 9.9 | 91.7 | - | 238157.1 |
| 2 | -965.0 | - | -873.4 | - | -2.8 | 91.6 | - | 228191.4 |
| 3 | -1086.9 | - | -956.6 | - | -5.0 | 91.7 | - | 247677.4 |
| 4 | -1025.0 | - | -840.0 | - | -3.4 | 91.7 | - | 247306.2 |


### generator deep


| n | T* | equiv. to T* | weaker | unsound (mean) | unknown | unsound (max over seeds) | P(|-held-out Ind) | max P(|-false) | MAP [tag] (count) |
|---|---|---|---|---|---|---|---|---|---|
| 16 | 2e-10 | 8e-10 | 1.000 | 2e-11 | 0 | 7e-11 | 1.000 | 2e-11 | skel6@16 [weaker] x3; skel4@16 [weaker] x2 |
| 64 | 0.790 | 0.790 | 0.200 | 0.010 | 0 | 0.012 | 1.000 | 0.010 | T* [yes] x4; T*-Q2 [weaker] x1 |
| 256 | 0.994 | 0.994 | 0 | 0.006 | 0 | 0.006 | 1.000 | 0.006 | T* [yes] x5 |
| 1024 | 0.997 | 0.997 | 0 | 0.003 | 0 | 0.003 | 1.000 | 0.003 | T* [yes] x5 |
| 2048 | 0.998 | 0.998 | 0 | 0.002 | 0 | 0.002 | 1.000 | 0.002 | T* [yes] x5 |


Code length minus that of T* at n = 2048 (bits; negative = preferred to T*; "-" = not in the pool at that n or infinite):


| seed | frag-complete | trim:frag-complete | T*+T_imp | T*+T_and | T*+T_ex | T*+T_= | frag-atoms | Mem |
|---|---|---|---|---|---|---|---|---|
| 0 | 672.3 | - | 85.4 | - | 74.5 | 91.0 | - | 387372.2 |
| 1 | 664.9 | - | 85.8 | - | 71.1 | 90.8 | - | 321680.1 |
| 2 | 673.2 | - | 84.8 | - | 62.8 | 90.8 | - | 313605.6 |
| 3 | 672.1 | - | 86.1 | - | 71.5 | 90.8 | - | 353888.5 |
| 4 | 674.1 | - | 86.1 | - | 75.3 | 91.0 | - | 352781.5 |


### generator atomic


| n | T* | equiv. to T* | weaker | unsound (mean) | unknown | unsound (max over seeds) | P(|-held-out Ind) | max P(|-false) | MAP [tag] (count) |
|---|---|---|---|---|---|---|---|---|---|
| 16 | 2e-10 | 2e-10 | 0.787 | 0.213 | 0 | 0.999 | 1.000 | 0.213 | skel4@16 [weaker] x2; DTRC@16 [weaker] x1; Q-lumped [no] x1 |
| 64 | 0.790 | 0.790 | 0.200 | 0.010 | 0 | 0.012 | 1.000 | 0.010 | T* [yes] x4; T*-Q4 [weaker] x1 |
| 256 | 0.229 | 0.229 | 0.769 | 0.001 | 0 | 0.006 | 0.521 | 0.001 | frag-atoms [weaker] x4; T* [yes] x1 |
| 1024 | 1e-126 | 1e-112 | 1.000 | 3e-129 | 0 | 2e-128 | 0.367 | 3e-129 | frag-atoms [weaker] x5 |
| 2048 | 4e-298 | 2e-178 | 1.000 | 8e-301 | 0 | 3e-300 | 0.367 | 8e-301 | frag-atoms [weaker] x5 |


Code length minus that of T* at n = 2048 (bits; negative = preferred to T*; "-" = not in the pool at that n or infinite):


| seed | frag-complete | trim:frag-complete | T*+T_imp | T*+T_and | T*+T_ex | T*+T_= | frag-atoms | Mem |
|---|---|---|---|---|---|---|---|---|
| 0 | -434.0 | - | 92.2 | - | 81.1 | -152.1 | -1024.6 | 46435.9 |
| 1 | -397.1 | - | 92.2 | - | 81.1 | -166.3 | -987.8 | 45262.0 |
| 2 | -437.1 | - | 92.2 | - | 81.1 | -173.9 | -1027.7 | 46173.7 |
| 3 | -395.6 | - | 92.2 | - | 81.1 | -181.7 | -986.2 | 45410.2 |
| 4 | -433.4 | - | 92.2 | - | 81.1 | -127.7 | -1024.0 | 48445.1 |

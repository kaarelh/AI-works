# E3: misspecification

Command: `cd code/experiments && python3 e3_misspec.py`. Seeds [0, 1, 2, 3, 4]. Dirichlet alpha = 0.5; prior 2^-bits; derivability |-_1 (part a), citation |-_0 (part b). Wall time 817 s.


## (a) phi = x+0=x, data = instances with a misspecified term law

Columns: posterior mass of H_sch, of theories with the same instance set as phi(?t) (H_sch, frag1, frag2, spare_nested), of subset theories (incomplete: overspec, N_m, over-specific Min), of superset theories (over-general, spare_false, spare_schema, H_open), of forall-type theories (H_all, H_all+sch, H_all+open), of Mem; P(|-inst) = mean mass deriving 3 held-out closed instances; "gain" = code length of H_sch minus that of the MAP (bits).


### generator heavy, L0 (data: S(0*0)+0=S(0*0), SSSSSSSSS0+0=SSSSSSSSS0, 1+0=1 ...)


| n | H_sch | same inst. | subset | superset | forall-type | Mem | other | P(|-inst) | P(|-forall) | gain (bits) | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 8 | 0.999 | 0.999 | 2e-05 | 0.001 | 1e-06 | 3e-44 | 1e-16 | 1.000 | 5e-04 | 0 | H_sch x5 |
| 32 | 0.975 | 1.000 | 0 | 3e-04 | 7e-07 | 8e-170 | 3e-12 | 1.000 | 7e-07 | 0 | H_sch x5 |
| 128 | 0.510 | 1.000 | 0 | 8e-05 | 2e-07 | 0 | 2e-11 | 1.000 | 2e-07 | 3.8 | H_sch x3; spare_nested x2 |
| 512 | 2e-23 | 1.000 | 0 | 1e-27 | 3e-30 | 0 | 3e-11 | 1.000 | 3e-30 | 76.3 | spare_nested x5 |
| 1024 | 1e-43 | 1.000 | 0 | 7e-48 | 2e-50 | 0 | 3e-11 | 1.000 | 2e-50 | 165.5 | spare_nested x5 |


### generator heavy, L1 (data: S(0*0)+0=S(0*0), SSSSSSSSS0+0=SSSSSSSSS0, 1+0=1 ...)


| n | H_sch | same inst. | subset | superset | forall-type | Mem | other | P(|-inst) | P(|-forall) | gain (bits) | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 8 | 0.995 | 0.995 | 2e-05 | 0.001 | 0.004 | 3e-44 | 1e-16 | 1.000 | 0.004 | 0 | H_sch x5 |
| 32 | 0.975 | 1.000 | 0 | 3e-04 | 9e-07 | 8e-170 | 3e-12 | 1.000 | 9e-07 | 0 | H_sch x5 |
| 128 | 0.510 | 1.000 | 0 | 8e-05 | 2e-07 | 0 | 2e-11 | 1.000 | 2e-07 | 3.8 | H_sch x3; spare_nested x2 |
| 512 | 2e-23 | 1.000 | 0 | 1e-27 | 4e-30 | 0 | 3e-11 | 1.000 | 4e-30 | 76.3 | spare_nested x5 |


### generator numerals, L0 (data: 0+0=0, SSSSSSSSS0+0=SSSSSSSSS0, SSSSS0+0=SSSSS0 ...)


| n | H_sch | same inst. | subset | superset | forall-type | Mem | other | P(|-inst) | P(|-forall) | gain (bits) | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 8 | 0.789 | 0.789 | 0.199 | 0.012 | 1e-06 | 1e-21 | 0 | 0.867 | 0.011 | 1.6 | H_sch x4; min4:S?f0+0=S?f0 x1 |
| 32 | 0.344 | 0.344 | 0.655 | 1e-04 | 2e-07 | 2e-58 | 0 | 0.563 | 3e-07 | 3.8 | overspec{0,S} x3; H_sch x2 |
| 128 | 2e-43 | 8e-32 | 1.000 | 2e-47 | 5e-50 | 4e-65 | 0 | 0.333 | 5e-50 | 162.0 | N_4 x5 |
| 512 | 9e-277 | 1e-194 | 1.000 | 7e-281 | 2e-283 | 8e-161 | 0 | 0.333 | 2e-283 | 978.8 | N_4 x5 |
| 1024 | 0 | 0 | 0.800 | 0 | 0 | 0.200 | 0 | 0.333 | 0 | 2076.1 | N_4 x4; Mem x1 |


### generator numerals, L1 (data: 0+0=0, SSSSSSSSS0+0=SSSSSSSSS0, SSSSS0+0=SSSSS0 ...)


| n | H_sch | same inst. | subset | superset | forall-type | Mem | other | P(|-inst) | P(|-forall) | gain (bits) | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 8 | 0.786 | 0.786 | 0.199 | 0.011 | 0.003 | 1e-21 | 0 | 0.867 | 0.014 | 1.6 | H_sch x4; min4:S?f0+0=S?f0 x1 |
| 32 | 0.344 | 0.344 | 0.655 | 1e-04 | 3e-07 | 2e-58 | 0 | 0.563 | 4e-07 | 3.8 | overspec{0,S} x3; H_sch x2 |
| 128 | 2e-43 | 8e-32 | 1.000 | 2e-47 | 7e-50 | 4e-65 | 0 | 0.333 | 7e-50 | 162.0 | N_4 x5 |
| 512 | 9e-277 | 1e-194 | 1.000 | 7e-281 | 2e-283 | 8e-161 | 0 | 0.333 | 2e-283 | 978.8 | N_4 x5 |


### generator small, L0 (data: 2+0=2, 0+0=0, 0+0=0 ...)


| n | H_sch | same inst. | subset | superset | forall-type | Mem | other | P(|-inst) | P(|-forall) | gain (bits) | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 8 | 0.835 | 0.835 | 2e-05 | 0.163 | 1e-06 | 0.002 | 1e-13 | 0.998 | 0.162 | 0 | H_sch x5 |
| 32 | 0.999 | 0.999 | 0 | 0.001 | 7e-07 | 2e-11 | 7e-13 | 1.000 | 9e-04 | 0 | H_sch x5 |
| 128 | 1.000 | 1.000 | 0 | 1e-04 | 3e-07 | 9e-25 | 2e-14 | 1.000 | 3e-07 | 0 | H_sch x5 |
| 512 | 1.000 | 1.000 | 0 | 7e-05 | 2e-07 | 3e-11 | 7e-14 | 1.000 | 2e-07 | 0 | H_sch x5 |
| 1024 | 6e-47 | 1e-39 | 0 | 3e-51 | 7e-54 | 1.000 | 3e-60 | 1e-39 | 7e-54 | 156.1 | Mem x5 |


### generator small, L1 (data: 2+0=2, 0+0=0, 0+0=0 ...)


| n | H_sch | same inst. | subset | superset | forall-type | Mem | other | P(|-inst) | P(|-forall) | gain (bits) | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 8 | 0.833 | 0.833 | 2e-05 | 0.162 | 0.003 | 0.002 | 1e-13 | 0.998 | 0.165 | 0 | H_sch x5 |
| 32 | 0.999 | 0.999 | 0 | 0.001 | 1e-06 | 2e-11 | 7e-13 | 1.000 | 9e-04 | 0 | H_sch x5 |
| 128 | 1.000 | 1.000 | 0 | 1e-04 | 5e-07 | 9e-25 | 2e-14 | 1.000 | 5e-07 | 0 | H_sch x5 |
| 512 | 1.000 | 1.000 | 0 | 7e-05 | 2e-07 | 3e-11 | 7e-14 | 1.000 | 2e-07 | 0 | H_sch x5 |


### generator skewQ, L0 (data: 0+0=0, 0+0=0, 0+0=0 ...)


| n | H_sch | same inst. | subset | superset | forall-type | Mem | other | P(|-inst) | P(|-forall) | gain (bits) | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 8 | 0.973 | 0.973 | 0 | 0.027 | 1e-06 | 2e-06 | 2e-18 | 1.000 | 0.026 | 0 | H_sch x5 |
| 32 | 1.000 | 1.000 | 0 | 3e-04 | 7e-07 | 1e-66 | 2e-18 | 1.000 | 1e-06 | 0 | H_sch x5 |
| 128 | 1.000 | 1.000 | 0 | 1e-04 | 3e-07 | 0 | 1e-14 | 1.000 | 3e-07 | 0 | H_sch x5 |
| 512 | 4e-17 | 1.000 | 0 | 3e-21 | 7e-24 | 0 | 4e-18 | 1.000 | 7e-24 | 70.5 | frag1 x5 |
| 1024 | 2e-57 | 1.000 | 0 | 1e-61 | 3e-64 | 0 | 7e-37 | 1.000 | 3e-64 | 211.8 | frag1 x5 |


### generator skewQ, L1 (data: 0+0=0, 0+0=0, 0+0=0 ...)


| n | H_sch | same inst. | subset | superset | forall-type | Mem | other | P(|-inst) | P(|-forall) | gain (bits) | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 8 | 0.970 | 0.970 | 0 | 0.027 | 0.004 | 2e-06 | 2e-18 | 1.000 | 0.029 | 0 | H_sch x5 |
| 32 | 1.000 | 1.000 | 0 | 3e-04 | 1e-06 | 1e-66 | 2e-18 | 1.000 | 1e-06 | 0 | H_sch x5 |
| 128 | 1.000 | 1.000 | 0 | 1e-04 | 5e-07 | 0 | 1e-14 | 1.000 | 5e-07 | 0 | H_sch x5 |
| 512 | 4e-17 | 1.000 | 0 | 3e-21 | 1e-23 | 0 | 4e-18 | 1.000 | 1e-23 | 70.5 | frag1 x5 |


## (b) PA mixture with a misspecified motive law (L0)

Columns as in E2; "spare" includes the nested fragments T* + T_f (deductively equivalent to T*).


### generator dtrc-motive


| n | T* | equiv. to T* | fragmented | spare (incl. T*+T_f) | over-general | over-specific | sub-T* | Mem | unsound | P(|-held-out Ind) | max P(|-false) | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 16 | 2e-13 | 2e-13 | 2e-195 | 4e-15 | 0.200 | 0 | 0.800 | 1e-298 | 0.200 | 1.000 | 0.200 | DTRC(n=16) x3; Q-lumped x1; T*-Q7 x1 |
| 64 | 0.593 | 0.593 | 2e-178 | 0.007 | 1e-51 | 0 | 0.400 | 0 | 0.007 | 1.000 | 0.007 | T* x3; T*-Q4 x1; T*-Q2 x1 |
| 256 | 0.994 | 0.994 | 3e-160 | 0.006 | 0 | 0 | 0 | 0 | 0.006 | 1.000 | 0.006 | T* x5 |
| 1024 | 1e-24 | 1.000 | 2e-107 | 1.000 | 0 | 0 | 0 | 0 | 4e-27 | 1.000 | 4e-27 | T*+T_ex x5 |
| 2048 | 5e-70 | 1.000 | 7e-59 | 1.000 | 0 | 0 | 0 | 0 | 1e-72 | 1.000 | 1e-72 | T*+T_ex x5 |


Code length minus that of T* at n = 2048 (bits; negative = preferred to T*):


| seed | frag-complete | T*+T_imp | T*+T_and | T*+T_= | Mem |
|---|---|---|---|---|---|
| 0 | 26.3 | 91.2 | inf | 91.6 | 149424.0 |
| 1 | 48.4 | 90.9 | inf | 91.7 | 146865.6 |
| 2 | 125.2 | 90.7 | inf | 91.6 | 144366.2 |
| 3 | 7.7 | 91.4 | inf | 91.7 | 143737.0 |
| 4 | 26.8 | 91.4 | inf | 91.7 | 150451.1 |


### generator root-skew


| n | T* | equiv. to T* | fragmented | spare (incl. T*+T_f) | over-general | over-specific | sub-T* | Mem | unsound | P(|-held-out Ind) | max P(|-false) | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 16 | 2e-10 | 2e-10 | 9e-99 | 5e-12 | 0.146 | 0 | 0.713 | 3e-153 | 0.287 | 1.000 | 0.287 | DTRC(n=16) x4; Q-lumped x1 |
| 64 | 0.790 | 0.790 | 6e-73 | 0.010 | 2e-58 | 0 | 0.200 | 0 | 0.010 | 1.000 | 0.010 | T* x4; T*-Q6 x1 |
| 256 | 0.049 | 1.000 | 4e-30 | 0.951 | 0 | 0 | 0 | 0 | 3e-04 | 1.000 | 3e-04 | T*+T_imp x5 |
| 1024 | 3e-160 | 1.000 | 1.000 | 6e-43 | 0 | 0 | 0 | 0 | 1e-162 | 0.533 | 1e-162 | frag-observed64 x5 |
| 2048 | 0 | 1.000 | 1.000 | 4e-156 | 0 | 0 | 0 | 0 | 0 | 0.533 | 0 | frag-observed64 x5 |


Code length minus that of T* at n = 2048 (bits; negative = preferred to T*):


| seed | frag-complete | T*+T_imp | T*+T_and | T*+T_= | Mem |
|---|---|---|---|---|---|
| 0 | -1009.6 | -789.2 | inf | 91.7 | 250891.6 |
| 1 | -1046.2 | -900.5 | inf | 91.7 | 238157.1 |
| 2 | -965.0 | -873.4 | inf | 91.6 | 228191.4 |
| 3 | -1086.9 | -956.6 | inf | 91.7 | 247677.4 |
| 4 | -1025.0 | -840.0 | inf | 91.7 | 247306.2 |


### generator deep


| n | T* | equiv. to T* | fragmented | spare (incl. T*+T_f) | over-general | over-specific | sub-T* | Mem | unsound | P(|-held-out Ind) | max P(|-false) | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 16 | 2e-10 | 2e-10 | 3e-197 | 5e-12 | 2e-11 | 0 | 1.000 | 3e-162 | 3e-11 | 1.000 | 3e-11 | DTRC(n=16) x5 |
| 64 | 0.790 | 0.790 | 3e-171 | 0.010 | 8e-39 | 0 | 0.200 | 0 | 0.010 | 1.000 | 0.010 | T* x4; T*-Q2 x1 |
| 256 | 0.994 | 0.994 | 4e-212 | 0.006 | 0 | 0 | 0 | 0 | 0.006 | 1.000 | 0.006 | T* x5 |
| 1024 | 0.997 | 0.997 | 7e-210 | 0.003 | 0 | 0 | 0 | 0 | 0.003 | 1.000 | 0.003 | T* x5 |
| 2048 | 0.998 | 0.998 | 1e-201 | 0.002 | 0 | 0 | 0 | 0 | 0.002 | 1.000 | 0.002 | T* x5 |


Code length minus that of T* at n = 2048 (bits; negative = preferred to T*):


| seed | frag-complete | T*+T_imp | T*+T_and | T*+T_= | Mem |
|---|---|---|---|---|---|
| 0 | 672.3 | 85.4 | inf | 91.0 | 387372.2 |
| 1 | 664.9 | 85.8 | inf | 90.8 | 321680.1 |
| 2 | 673.2 | 84.8 | inf | 90.8 | 313605.6 |
| 3 | 672.1 | 86.1 | inf | 90.8 | 353888.5 |
| 4 | 674.1 | 86.1 | inf | 91.0 | 352781.5 |

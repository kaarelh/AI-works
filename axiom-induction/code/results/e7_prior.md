# E7: prior variants (time factor, steeper simplicity penalty) on the E2 data

Command: `cd code/experiments && python3 e7_prior.py`. Seeds 0-24. Causal pool with Trim(T, D_n) and Mem(D_n), as in E2. Wall time 160 s. Template sizes (symbols) of some theories, seed 0: {'T*': 77, 'frag-complete': 287, 'Ind-any-antecedent': 68, 'bare?P': 1, 'Q-lumped': 22}.


Columns: mean posterior of T*, of theories deductively equivalent to T*, of unsound theories; seeds in which a delta = 0.05 verifier (citation depth) accepts a false probe; the tag of the MAP (yes = equivalent to T*, weaker = sound and strictly weaker, no = unsound) counted over seeds.


| lambda | tau | n | T* | equiv. to T* | unsound | accepting seeds | MAP tag (count) |
|---|---|---|---|---|---|---|---|
| 1.0 | 0.0 | 8 | 2e-21 | 4e-13 | 0.256 | 2/25 | weaker x18; no x7 |
| 1.0 | 0.0 | 16 | 9e-07 | 5e-06 | 0.197 | 3/25 | weaker x20; no x5 |
| 1.0 | 0.0 | 32 | 0.197 | 0.197 | 0.077 | 0/25 | weaker x19; yes x5; no x1 |
| 1.0 | 0.0 | 64 | 0.751 | 0.791 | 0.009 | 0/25 | yes x20; weaker x5 |
| 1.0 | 0.0 | 128 | 0.991 | 0.991 | 0.009 | 0/25 | yes x25 |
| 1.0 | 0.0 | 512 | 0.996 | 0.996 | 0.004 | 0/25 | yes x25 |
| 1.0 | 1.0 | 8 | 8e-22 | 1e-13 | 0.293 | 2/25 | weaker x16; no x9 |
| 1.0 | 1.0 | 16 | 8e-07 | 5e-06 | 0.217 | 3/25 | weaker x19; no x6 |
| 1.0 | 1.0 | 32 | 0.197 | 0.197 | 0.084 | 0/25 | weaker x17; yes x5; no x3 |
| 1.0 | 1.0 | 64 | 0.751 | 0.791 | 0.009 | 0/25 | yes x20; weaker x5 |
| 1.0 | 1.0 | 128 | 0.992 | 0.992 | 0.008 | 0/25 | yes x25 |
| 1.0 | 1.0 | 512 | 0.996 | 0.996 | 0.004 | 0/25 | yes x25 |
| 1.0 | 4.0 | 8 | 9e-23 | 6e-15 | 0.372 | 5/25 | weaker x16; no x9 |
| 1.0 | 4.0 | 16 | 6e-07 | 4e-06 | 0.262 | 4/25 | weaker x18; no x7 |
| 1.0 | 4.0 | 32 | 0.197 | 0.197 | 0.103 | 1/25 | weaker x17; yes x5; no x3 |
| 1.0 | 4.0 | 64 | 0.752 | 0.792 | 0.008 | 0/25 | yes x20; weaker x5 |
| 1.0 | 4.0 | 128 | 0.993 | 0.993 | 0.007 | 0/25 | yes x25 |
| 1.0 | 4.0 | 512 | 0.996 | 0.996 | 0.004 | 0/25 | yes x25 |
| 2.0 | 0.0 | 8 | 2e-59 | 3e-46 | 0.860 | 18/25 | no x22; weaker x3 |
| 2.0 | 0.0 | 16 | 2e-38 | 9e-19 | 0.792 | 19/25 | no x20; weaker x5 |
| 2.0 | 0.0 | 32 | 0.040 | 0.040 | 0.737 | 18/25 | no x18; weaker x6; yes x1 |
| 2.0 | 0.0 | 64 | 0.594 | 0.634 | 0.206 | 5/25 | yes x16; no x5; weaker x4 |
| 2.0 | 0.0 | 128 | 1.000 | 1.000 | 5e-04 | 0/25 | yes x25 |
| 2.0 | 0.0 | 512 | 1.000 | 1.000 | 2e-04 | 0/25 | yes x25 |
| 0.5 | 0.0 | 8 | 2e-11 | 1e-06 | 3e-04 | 0/25 | weaker x25 |
| 0.5 | 0.0 | 16 | 1e-04 | 5e-04 | 7e-05 | 0/25 | weaker x25 |
| 0.5 | 0.0 | 32 | 0.186 | 0.187 | 0.014 | 0/25 | weaker x20; yes x5 |
| 0.5 | 0.0 | 64 | 0.719 | 0.761 | 0.039 | 0/25 | yes x20; weaker x5 |
| 0.5 | 0.0 | 128 | 0.961 | 0.963 | 0.037 | 0/25 | yes x25 |
| 0.5 | 0.0 | 512 | 0.980 | 0.981 | 0.019 | 0/25 | yes x25 |


Largest change, over seeds and n, of the mass of T*, of its equivalents or of the unsound theories caused by the time factor: tau = 1: 0.1814; tau = 4: 0.5627.

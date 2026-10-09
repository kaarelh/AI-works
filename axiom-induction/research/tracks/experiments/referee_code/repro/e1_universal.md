# E1: forall x phi from data about phi

Command: `cd code/experiments && python3 e1_universal.py`. Seeds [0, 1, 2, 3, 4]. n in [1, 2, 4, 8, 16, 32, 64, 128, 256]. Q = default Grammar (bai/grammar.py); L1 chain: c_stop = 0.5, c_elim = c_gen = c_mp = 1; Dirichlet alpha = 0.5; prior 2^-bits (TemplateCode), lambda = 1, no time factor. Wall time 44 s.

Generators: sch = L0 citations of phi(?t) (closed terms); all = L1 chain (K=1) from {forall x phi}, closed elim terms; allq = the same with open elim terms; open = L1 chain (K=1) from {phi(?t) open}; allq2 = L1 chain with K=2 from {forall x phi}, open elim terms. The L1 likelihood is the generator's own chain (well specified); for allq2 the pool has no bare formula metavariables (K=2 is only computed exactly without them). L1sel (sch data only) is the closed-elim K=1 chain observed through closed quantifier-free outputs; its pool is restricted to theories whose class probability is computed exactly (bai.lik.class_prob_qf).

Columns: posterior mass of H_all = {forall x phi}, H_sch = {phi(?t) closed}, H_open = {phi(?t) open}, H_all+sch, Mem(D_n), over-general, over-specific and fragmented theories (summed over the pool); P(|-forall) = posterior mass of theories T with T |-_1 forall x phi (chain derivations of length <= 1); P(|-inst) = the same for held-out closed instances (mean over 3); lo = log2 posterior odds H_sch : H_all. Means over seeds.


## phi = x+0=x, generator sch

Pool size (incl. Mem) 17 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.00; with the parameter: 0.00; L1 inexact counters {'closed1': 0, 'open1': 0, 'open2': 0}.


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0.344 | 0.105 | 2e-06 | 0.427 | 0.120 | 0.004 | 5e-04 | 0.220 | 0.571 | inf | H_sch, Mem |
| 2 | 0 | 0.603 | 0.184 | 2e-06 | 0.199 | 0.014 | 5e-06 | 7e-04 | 0.191 | 0.801 | inf | H_sch, Mem |
| 4 | 0 | 0.870 | 0.127 | 2e-06 | 0.001 | 0.001 | 4e-06 | 7e-04 | 0.127 | 0.999 | inf | H_sch |
| 8 | 0 | 0.965 | 0.034 | 1e-06 | 6e-16 | 5e-05 | 2e-05 | 6e-04 | 0.034 | 1.000 | inf | H_sch |
| 16 | 0 | 0.998 | 0.002 | 9e-07 | 3e-28 | 8e-08 | 1e-04 | 4e-04 | 0.002 | 1.000 | inf | H_sch |
| 32 | 0 | 1.000 | 9e-07 | 7e-07 | 3e-70 | 2e-13 | 0 | 3e-04 | 2e-06 | 1.000 | inf | H_sch |
| 64 | 0 | 1.000 | 2e-14 | 5e-07 | 1e-174 | 2e-24 | 0 | 2e-04 | 5e-07 | 1.000 | inf | H_sch |
| 128 | 0 | 1.000 | 1e-29 | 3e-07 | 0 | 1e-46 | 0 | 1e-04 | 3e-07 | 1.000 | inf | H_sch |
| 256 | 0 | 1.000 | 2e-61 | 2e-07 | 0 | 5e-91 | 0 | 1e-04 | 2e-07 | 1.000 | inf | H_sch |


**L1**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.119 | 0.254 | 0.080 | 2e-06 | 0.417 | 0.126 | 0.004 | 4e-04 | 0.321 | 0.581 | 1.1 | H_sch, Mem |
| 2 | 0.120 | 0.509 | 0.159 | 3e-06 | 0.199 | 0.012 | 5e-06 | 6e-04 | 0.286 | 0.801 | 2.1 | H_sch, Mem |
| 4 | 0.049 | 0.827 | 0.122 | 3e-06 | 0.001 | 0.001 | 4e-06 | 7e-04 | 0.170 | 0.999 | 4.1 | H_sch |
| 8 | 0.004 | 0.962 | 0.034 | 2e-06 | 6e-16 | 4e-05 | 1e-05 | 6e-04 | 0.037 | 1.000 | 8.1 | H_sch |
| 16 | 1e-05 | 0.998 | 0.002 | 1e-06 | 3e-28 | 8e-08 | 1e-04 | 4e-04 | 0.002 | 1.000 | 16.1 | H_sch |
| 32 | 2e-10 | 1.000 | 9e-07 | 1e-06 | 3e-70 | 2e-13 | 0 | 3e-04 | 2e-06 | 1.000 | 32.1 | H_sch |
| 64 | 5e-20 | 1.000 | 2e-14 | 7e-07 | 1e-174 | 2e-24 | 0 | 2e-04 | 7e-07 | 1.000 | 64.1 | H_sch |
| 128 | 3e-39 | 1.000 | 1e-29 | 5e-07 | 0 | 1e-46 | 0 | 1e-04 | 5e-07 | 1.000 | 128.1 | H_sch |
| 256 | 8e-78 | 1.000 | 2e-61 | 3e-07 | 0 | 5e-91 | 0 | 1e-04 | 3e-07 | 1.000 | 256.1 | H_sch |


**L1sel**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.194 | 0.207 | 0.104 | 2e-06 | 0.487 | 0.003 | 0.004 | 3e-04 | 0.298 | 0.510 | 9e-02 | H_sch, Mem |
| 2 | 0.288 | 0.307 | 0.203 | 4e-06 | 0.198 | 0.003 | 3e-06 | 3e-04 | 0.491 | 0.802 | 9e-02 | H_open, H_sch, Mem |
| 4 | 0.368 | 0.391 | 0.240 | 5e-06 | 5e-04 | 5e-04 | 1e-06 | 3e-04 | 0.607 | 1.000 | 9e-02 | H_open, H_sch |
| 8 | 0.361 | 0.384 | 0.255 | 5e-06 | 2e-16 | 2e-05 | 4e-06 | 2e-04 | 0.616 | 1.000 | 9e-02 | H_open, H_sch |
| 16 | 0.398 | 0.424 | 0.177 | 5e-06 | 6e-29 | 3e-08 | 2e-05 | 2e-04 | 0.576 | 1.000 | 9e-02 | H_open, H_sch |
| 32 | 0.443 | 0.471 | 0.086 | 5e-06 | 8e-71 | 1e-13 | 0 | 1e-04 | 0.529 | 1.000 | 9e-02 | H_open, H_sch |
| 64 | 0.484 | 0.515 | 9e-04 | 5e-06 | 5e-175 | 9e-25 | 0 | 1e-04 | 0.485 | 1.000 | 9e-02 | H_sch |
| 128 | 0.484 | 0.516 | 3e-08 | 5e-06 | 0 | 6e-47 | 0 | 8e-05 | 0.484 | 1.000 | 9e-02 | H_sch |
| 256 | 0.484 | 0.516 | 3e-18 | 5e-06 | 0 | 2e-91 | 0 | 5e-05 | 0.484 | 1.000 | 9e-02 | H_sch |


## phi = x+0=x, generator all

Pool size (incl. Mem) 17 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.50; with the parameter: 0.00; L1 inexact counters {'closed1': 0, 'open1': 0, 'open2': 0}.


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.097 | 0.136 | 0.060 | 1e-06 | 0.632 | 0.075 | 1e-07 | 2e-04 | 0.327 | 0.465 | mixed | H_all, H_sch, Mem |
| 2 | 0.100 | 0.145 | 0.054 | 0.002 | 0.236 | 0.463 | 0 | 2e-04 | 0.854 | 1.000 | mixed | H_all, H_sch, gen1:?G2 |
| 4 | 0 | 0 | 0 | 0.404 | 0.596 | 1e-05 | 0 | 2e-16 | 1.000 | 1.000 | - | H_all+sch, Mem |
| 8 | 0 | 0 | 0 | 0.991 | 0.009 | 4e-15 | 0 | 1e-15 | 1.000 | 1.000 | - | H_all+sch |
| 16 | 0 | 0 | 0 | 0.933 | 0.067 | 8e-38 | 0 | 6e-16 | 1.000 | 1.000 | - | H_all+sch |
| 32 | 0 | 0 | 0 | 1.000 | 4e-40 | 6e-101 | 0 | 5e-16 | 1.000 | 1.000 | - | H_all+sch |
| 64 | 0 | 0 | 0 | 1.000 | 1e-97 | 1e-224 | 0 | 6e-16 | 1.000 | 1.000 | - | H_all+sch |
| 128 | 0 | 0 | 0 | 1.000 | 1e-204 | 0 | 0 | 5e-16 | 1.000 | 1.000 | - | H_all+sch |
| 256 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 3e-16 | 1.000 | 1.000 | - | H_all+sch |


**L1** (exact Dirichlet DP too large for skel4: marginal bounded; the largest posterior mass these could have at any n is 4e-19)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.139 | 0.103 | 0.058 | 2e-06 | 0.622 | 0.078 | 1e-07 | 2e-04 | 0.364 | 0.469 | mixed | H_all, H_sch, Mem |
| 2 | 0.611 | 0.124 | 0.165 | 6e-06 | 0.099 | 0.001 | 0 | 1e-04 | 0.876 | 1.000 | mixed | H_all, H_sch |
| 4 | 0.900 | 0 | 0.100 | 8e-06 | 3e-04 | 2e-10 | 0 | 9e-21 | 1.000 | 1.000 | -inf | H_all |
| 8 | 0.993 | 0 | 0.007 | 6e-06 | 2e-08 | 2e-21 | 0 | 8e-21 | 1.000 | 1.000 | -inf | H_all |
| 16 | 1.000 | 0 | 2e-04 | 6e-06 | 7e-08 | 7e-45 | 0 | 5e-21 | 1.000 | 1.000 | -inf | H_all |
| 32 | 1.000 | 0 | 2e-09 | 4e-06 | 1e-48 | 3e-102 | 0 | 4e-21 | 1.000 | 1.000 | -inf | H_all |
| 64 | 1.000 | 0 | 2e-22 | 3e-06 | 1e-106 | 1e-219 | 0 | 2e-21 | 1.000 | 1.000 | -inf | H_all |
| 128 | 1.000 | 0 | 3e-52 | 2e-06 | 3e-216 | 0 | 0 | 7e-22 | 1.000 | 1.000 | -inf | H_all |
| 256 | 1.000 | 0 | 5e-97 | 2e-06 | 0 | 0 | 0 | 8e-77 | 1.000 | 1.000 | -inf | H_all |


## phi = x+0=x, generator allq

Pool size (incl. Mem) 17 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.49; with the parameter: 0.16; L1 inexact counters {'closed1': 0, 'open1': 0, 'open2': 0}.


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.097 | 0.165 | 0.237 | 2e-06 | 0.451 | 0.050 | 9e-06 | 2e-04 | 0.478 | 0.645 | mixed | H_all, H_open, H_sch |
| 2 | 0.100 | 0.168 | 0.231 | 0.001 | 0.191 | 0.309 | 0 | 2e-04 | 0.831 | 1.000 | mixed | H_all, H_open, H_sch |
| 4 | 0 | 0 | 0.200 | 0.403 | 0.397 | 3e-07 | 0 | 2e-07 | 1.000 | 1.000 | - | H_all+open, H_all+sch, H_open |
| 8 | 0 | 0 | 0 | 1.000 | 1e-07 | 6e-25 | 0 | 1e-07 | 1.000 | 1.000 | - | H_all+open, H_all+sch |
| 16 | 0 | 0 | 0 | 1.000 | 9e-12 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 32 | 0 | 0 | 0 | 1.000 | 2e-28 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 64 | 0 | 0 | 0 | 1.000 | 1e-77 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 128 | 0 | 0 | 0 | 1.000 | 1e-158 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 256 | 0 | 0 | 0 | 1.000 | 5e-309 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |


**L1** (exact Dirichlet DP too large for skel4: marginal bounded; the largest posterior mass these could have at any n is 3e-21)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.199 | 0.152 | 0.145 | 2e-06 | 0.443 | 0.060 | 8e-06 | 2e-04 | 0.493 | 0.647 | mixed | H_all, H_open, H_sch |
| 2 | 0.516 | 0.162 | 0.222 | 5e-06 | 0.099 | 0.001 | 0 | 2e-04 | 0.837 | 1.000 | mixed | H_all, H_open, H_sch |
| 4 | 0.764 | 0 | 0.235 | 8e-06 | 2e-04 | 9e-11 | 0 | 3e-12 | 1.000 | 1.000 | -inf | H_all, H_open |
| 8 | 0.921 | 0 | 0.079 | 6e-06 | 6e-13 | 7e-24 | 0 | 2e-12 | 1.000 | 1.000 | -inf | H_all |
| 16 | 0.999 | 0 | 7e-04 | 7e-06 | 2e-17 | 1e-48 | 0 | 2e-12 | 1.000 | 1.000 | -inf | H_all |
| 32 | 1.000 | 0 | 4e-08 | 7e-06 | 2e-35 | 6e-108 | 0 | 1e-12 | 1.000 | 1.000 | -inf | H_all |
| 64 | 1.000 | 0 | 6e-16 | 5e-06 | 1e-87 | 6e-222 | 0 | 5e-13 | 1.000 | 1.000 | -inf | H_all |
| 128 | 1.000 | 0 | 2e-33 | 3e-06 | 8e-172 | 0 | 0 | 4e-13 | 1.000 | 1.000 | -inf | H_all |
| 256 | 1.000 | 0 | 5e-68 | 3e-06 | 0 | 0 | 0 | 1e-13 | 1.000 | 1.000 | -inf | H_all |


## phi = x+0=x, generator open

Pool size (incl. Mem) 19 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.18; with the parameter: 0.15; L1 inexact counters {'closed1': 0, 'open1': 0, 'open2': 0}.


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0.032 | 0.034 | 2e-07 | 0.796 | 0.137 | 1e-06 | 5e-05 | 0.358 | 0.204 | inf | Mem |
| 2 | 0 | 0.240 | 0.547 | 2e-06 | 0.057 | 0.155 | 5e-06 | 3e-04 | 0.699 | 0.943 | inf | H_open, H_sch, gen1:?G2 |
| 4 | 0 | 0 | 0 | 0.200 | 0.546 | 0.122 | 0 | 0.131 | 0.454 | 0.500 | - | H_all+open, Mem, skel2 |
| 8 | 0 | 0 | 0 | 0 | 0.872 | 1e-09 | 0 | 0.128 | 0.927 | 0.727 | - | Mem, skel2 |
| 16 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 32 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 64 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 128 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 256 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |


**L1** (exact Dirichlet DP too large for Mem, skel4: marginal bounded; the largest posterior mass these could have at any n is 1e-81)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.021 | 0.031 | 0.233 | 1e-06 | 0.598 | 0.117 | 1e-06 | 5e-05 | 0.547 | 0.402 | mixed | H_open, Mem |
| 2 | 0.160 | 0.221 | 0.608 | 4e-06 | 5e-04 | 0.011 | 5e-06 | 3e-04 | 0.774 | 1.000 | mixed | H_open, H_sch |
| 4 | 0.129 | 0 | 0.871 | 4e-06 | 2e-08 | 2e-09 | 0 | 2e-09 | 1.000 | 1.000 | -inf | H_all, H_open |
| 8 | 0 | 0 | 1.000 | 5e-06 | 9e-13 | 7e-22 | 0 | 2e-14 | 1.000 | 1.000 | - | H_open |
| 16 | 0 | 0 | 1.000 | 8e-06 | 5e-23 | 2e-45 | 0 | 2e-21 | 1.000 | 1.000 | - | H_open |
| 32 | 0 | 0 | 1.000 | 3e-06 | 2e-26 | 5e-91 | 0 | 7e-41 | 1.000 | 1.000 | - | H_open |
| 64 | 0 | 0 | 1.000 | 4e-06 | 4e-95 | 7e-189 | 0 | 2e-71 | 1.000 | 1.000 | - | H_open |
| 128 | 0 | 0 | 1.000 | 3e-06 | 3e-281 | 0 | 0 | 7e-182 | 1.000 | 1.000 | - | H_open |
| 256 | 0 | 0 | 1.000 | 2e-06 | 0 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_open |


## phi = x+0=x, generator allq2

Pool size (incl. Mem) 15 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.59; with the parameter: 0.08; L1 inexact counters {'closed1': 0, 'open1': 0, 'open2': 0}.


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.100 | 0.165 | 0.237 | 2e-06 | 0.495 | 0.002 | 8e-08 | 2e-04 | 0.437 | 0.605 | mixed | H_all, H_open, H_sch |
| 2 | 0.100 | 0.168 | 0.031 | 0.205 | 0.495 | 9e-04 | 0 | 2e-04 | 0.831 | 1.000 | mixed | H_all, H_all+open, H_sch |
| 4 | 0 | 0 | 0 | 0.403 | 0.597 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open, H_all+sch, Mem |
| 8 | 0 | 0 | 0 | 0.787 | 0.213 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open, H_all+sch, Mem |
| 16 | 0 | 0 | 0 | 0.400 | 0.600 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open, Mem |
| 32 | 0 | 0 | 0 | 0.200 | 0.800 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open, Mem |
| 64 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 128 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 256 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |


**L1** (exact Dirichlet DP too large for Mem: marginal bounded; the largest posterior mass these could have at any n is 1e-85)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.166 | 0.144 | 0.197 | 2e-06 | 0.491 | 0.002 | 8e-08 | 2e-04 | 0.460 | 0.606 | mixed | H_all, H_open, H_sch |
| 2 | 0.631 | 0.152 | 0.117 | 6e-06 | 0.100 | 9e-04 | 0 | 2e-04 | 0.847 | 1.000 | mixed | H_all, H_sch |
| 4 | 0.900 | 0 | 0.099 | 8e-06 | 2e-04 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |
| 8 | 0.998 | 0 | 0.002 | 6e-06 | 5e-08 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |
| 16 | 1.000 | 0 | 2e-05 | 8e-06 | 1e-17 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |
| 32 | 1.000 | 0 | 2e-11 | 7e-06 | 7e-45 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |
| 64 | 1.000 | 0 | 7e-25 | 5e-06 | 6e-100 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |
| 128 | 1.000 | 0 | 5e-56 | 3e-06 | 6e-187 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |
| 256 | 1.000 | 0 | 1e-116 | 2e-06 | 0 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |


## phi = 0+x=x, generator sch

Pool size (incl. Mem) 17 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.00; with the parameter: 0.00; L1 inexact counters {'closed1': 0, 'open1': 0, 'open2': 0}.


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0.344 | 0.105 | 2e-06 | 0.427 | 0.120 | 0.004 | 5e-04 | 0.220 | 0.571 | inf | H_sch, Mem |
| 2 | 0 | 0.603 | 0.184 | 2e-06 | 0.199 | 0.014 | 5e-06 | 7e-04 | 0.191 | 0.801 | inf | H_sch, Mem |
| 4 | 0 | 0.870 | 0.127 | 2e-06 | 0.001 | 0.001 | 4e-06 | 7e-04 | 0.127 | 0.999 | inf | H_sch |
| 8 | 0 | 0.965 | 0.034 | 1e-06 | 6e-16 | 5e-05 | 2e-05 | 6e-04 | 0.034 | 1.000 | inf | H_sch |
| 16 | 0 | 0.998 | 0.002 | 9e-07 | 3e-28 | 8e-08 | 1e-04 | 4e-04 | 0.002 | 1.000 | inf | H_sch |
| 32 | 0 | 1.000 | 9e-07 | 7e-07 | 3e-70 | 2e-13 | 0 | 3e-04 | 2e-06 | 1.000 | inf | H_sch |
| 64 | 0 | 1.000 | 2e-14 | 5e-07 | 1e-174 | 2e-24 | 0 | 2e-04 | 5e-07 | 1.000 | inf | H_sch |
| 128 | 0 | 1.000 | 1e-29 | 3e-07 | 0 | 1e-46 | 0 | 1e-04 | 3e-07 | 1.000 | inf | H_sch |
| 256 | 0 | 1.000 | 2e-61 | 2e-07 | 0 | 5e-91 | 0 | 1e-04 | 2e-07 | 1.000 | inf | H_sch |


**L1**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.119 | 0.254 | 0.080 | 2e-06 | 0.417 | 0.126 | 0.004 | 4e-04 | 0.321 | 0.581 | 1.1 | H_sch, Mem |
| 2 | 0.120 | 0.509 | 0.159 | 3e-06 | 0.199 | 0.012 | 5e-06 | 6e-04 | 0.286 | 0.801 | 2.1 | H_sch, Mem |
| 4 | 0.049 | 0.827 | 0.122 | 3e-06 | 0.001 | 0.001 | 4e-06 | 7e-04 | 0.170 | 0.999 | 4.1 | H_sch |
| 8 | 0.004 | 0.962 | 0.034 | 2e-06 | 6e-16 | 4e-05 | 1e-05 | 6e-04 | 0.037 | 1.000 | 8.1 | H_sch |
| 16 | 1e-05 | 0.998 | 0.002 | 1e-06 | 3e-28 | 8e-08 | 1e-04 | 4e-04 | 0.002 | 1.000 | 16.1 | H_sch |
| 32 | 2e-10 | 1.000 | 9e-07 | 1e-06 | 3e-70 | 2e-13 | 0 | 3e-04 | 2e-06 | 1.000 | 32.1 | H_sch |
| 64 | 5e-20 | 1.000 | 2e-14 | 7e-07 | 1e-174 | 2e-24 | 0 | 2e-04 | 7e-07 | 1.000 | 64.1 | H_sch |
| 128 | 3e-39 | 1.000 | 1e-29 | 5e-07 | 0 | 1e-46 | 0 | 1e-04 | 5e-07 | 1.000 | 128.1 | H_sch |
| 256 | 8e-78 | 1.000 | 2e-61 | 3e-07 | 0 | 5e-91 | 0 | 1e-04 | 3e-07 | 1.000 | 256.1 | H_sch |


**L1sel**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.194 | 0.207 | 0.104 | 2e-06 | 0.487 | 0.003 | 0.004 | 3e-04 | 0.298 | 0.510 | 9e-02 | H_sch, Mem |
| 2 | 0.288 | 0.307 | 0.203 | 4e-06 | 0.198 | 0.003 | 3e-06 | 3e-04 | 0.491 | 0.802 | 9e-02 | H_open, H_sch, Mem |
| 4 | 0.368 | 0.391 | 0.240 | 5e-06 | 5e-04 | 5e-04 | 1e-06 | 3e-04 | 0.607 | 1.000 | 9e-02 | H_open, H_sch |
| 8 | 0.361 | 0.384 | 0.255 | 5e-06 | 2e-16 | 2e-05 | 4e-06 | 2e-04 | 0.616 | 1.000 | 9e-02 | H_open, H_sch |
| 16 | 0.398 | 0.424 | 0.177 | 5e-06 | 6e-29 | 3e-08 | 2e-05 | 2e-04 | 0.576 | 1.000 | 9e-02 | H_open, H_sch |
| 32 | 0.443 | 0.471 | 0.086 | 5e-06 | 8e-71 | 1e-13 | 0 | 1e-04 | 0.529 | 1.000 | 9e-02 | H_open, H_sch |
| 64 | 0.484 | 0.515 | 9e-04 | 5e-06 | 5e-175 | 9e-25 | 0 | 1e-04 | 0.485 | 1.000 | 9e-02 | H_sch |
| 128 | 0.484 | 0.516 | 3e-08 | 5e-06 | 0 | 6e-47 | 0 | 8e-05 | 0.484 | 1.000 | 9e-02 | H_sch |
| 256 | 0.484 | 0.516 | 3e-18 | 5e-06 | 0 | 2e-91 | 0 | 5e-05 | 0.484 | 1.000 | 9e-02 | H_sch |


## phi = 0+x=x, generator all

Pool size (incl. Mem) 17 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.50; with the parameter: 0.00; L1 inexact counters {'closed1': 0, 'open1': 0, 'open2': 0}.


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.097 | 0.136 | 0.060 | 1e-06 | 0.632 | 0.075 | 1e-07 | 2e-04 | 0.327 | 0.465 | mixed | H_all, H_sch, Mem |
| 2 | 0.100 | 0.145 | 0.054 | 0.002 | 0.236 | 0.463 | 0 | 2e-04 | 0.854 | 1.000 | mixed | H_all, H_sch, gen1:?G2 |
| 4 | 0 | 0 | 0 | 0.404 | 0.596 | 1e-05 | 0 | 2e-16 | 1.000 | 1.000 | - | H_all+sch, Mem |
| 8 | 0 | 0 | 0 | 0.991 | 0.009 | 4e-15 | 0 | 1e-15 | 1.000 | 1.000 | - | H_all+sch |
| 16 | 0 | 0 | 0 | 0.933 | 0.067 | 8e-38 | 0 | 6e-16 | 1.000 | 1.000 | - | H_all+sch |
| 32 | 0 | 0 | 0 | 1.000 | 4e-40 | 6e-101 | 0 | 5e-16 | 1.000 | 1.000 | - | H_all+sch |
| 64 | 0 | 0 | 0 | 1.000 | 1e-97 | 1e-224 | 0 | 6e-16 | 1.000 | 1.000 | - | H_all+sch |
| 128 | 0 | 0 | 0 | 1.000 | 1e-204 | 0 | 0 | 5e-16 | 1.000 | 1.000 | - | H_all+sch |
| 256 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 3e-16 | 1.000 | 1.000 | - | H_all+sch |


**L1** (exact Dirichlet DP too large for skel4: marginal bounded; the largest posterior mass these could have at any n is 4e-19)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.139 | 0.103 | 0.058 | 2e-06 | 0.622 | 0.078 | 1e-07 | 2e-04 | 0.364 | 0.469 | mixed | H_all, H_sch, Mem |
| 2 | 0.611 | 0.124 | 0.165 | 6e-06 | 0.099 | 0.001 | 0 | 1e-04 | 0.876 | 1.000 | mixed | H_all, H_sch |
| 4 | 0.900 | 0 | 0.100 | 8e-06 | 3e-04 | 2e-10 | 0 | 9e-21 | 1.000 | 1.000 | -inf | H_all |
| 8 | 0.993 | 0 | 0.007 | 6e-06 | 2e-08 | 2e-21 | 0 | 8e-21 | 1.000 | 1.000 | -inf | H_all |
| 16 | 1.000 | 0 | 2e-04 | 6e-06 | 7e-08 | 7e-45 | 0 | 5e-21 | 1.000 | 1.000 | -inf | H_all |
| 32 | 1.000 | 0 | 2e-09 | 4e-06 | 1e-48 | 3e-102 | 0 | 4e-21 | 1.000 | 1.000 | -inf | H_all |
| 64 | 1.000 | 0 | 2e-22 | 3e-06 | 1e-106 | 1e-219 | 0 | 2e-21 | 1.000 | 1.000 | -inf | H_all |
| 128 | 1.000 | 0 | 3e-52 | 2e-06 | 3e-216 | 0 | 0 | 7e-22 | 1.000 | 1.000 | -inf | H_all |
| 256 | 1.000 | 0 | 5e-97 | 2e-06 | 0 | 0 | 0 | 8e-77 | 1.000 | 1.000 | -inf | H_all |


## phi = 0+x=x, generator allq

Pool size (incl. Mem) 17 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.49; with the parameter: 0.16; L1 inexact counters {'closed1': 0, 'open1': 0, 'open2': 0}.


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.097 | 0.165 | 0.237 | 2e-06 | 0.451 | 0.050 | 9e-06 | 2e-04 | 0.478 | 0.645 | mixed | H_all, H_open, H_sch |
| 2 | 0.100 | 0.168 | 0.231 | 0.001 | 0.191 | 0.309 | 0 | 2e-04 | 0.831 | 1.000 | mixed | H_all, H_open, H_sch |
| 4 | 0 | 0 | 0.200 | 0.403 | 0.397 | 3e-07 | 0 | 2e-07 | 1.000 | 1.000 | - | H_all+open, H_all+sch, H_open |
| 8 | 0 | 0 | 0 | 1.000 | 1e-07 | 6e-25 | 0 | 1e-07 | 1.000 | 1.000 | - | H_all+open, H_all+sch |
| 16 | 0 | 0 | 0 | 1.000 | 9e-12 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 32 | 0 | 0 | 0 | 1.000 | 2e-28 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 64 | 0 | 0 | 0 | 1.000 | 1e-77 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 128 | 0 | 0 | 0 | 1.000 | 1e-158 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 256 | 0 | 0 | 0 | 1.000 | 5e-309 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |


**L1** (exact Dirichlet DP too large for skel4: marginal bounded; the largest posterior mass these could have at any n is 3e-21)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.199 | 0.152 | 0.145 | 2e-06 | 0.443 | 0.060 | 8e-06 | 2e-04 | 0.493 | 0.647 | mixed | H_all, H_open, H_sch |
| 2 | 0.516 | 0.162 | 0.222 | 5e-06 | 0.099 | 0.001 | 0 | 2e-04 | 0.837 | 1.000 | mixed | H_all, H_open, H_sch |
| 4 | 0.764 | 0 | 0.235 | 8e-06 | 2e-04 | 9e-11 | 0 | 3e-12 | 1.000 | 1.000 | -inf | H_all, H_open |
| 8 | 0.921 | 0 | 0.079 | 6e-06 | 6e-13 | 7e-24 | 0 | 2e-12 | 1.000 | 1.000 | -inf | H_all |
| 16 | 0.999 | 0 | 7e-04 | 7e-06 | 2e-17 | 1e-48 | 0 | 2e-12 | 1.000 | 1.000 | -inf | H_all |
| 32 | 1.000 | 0 | 4e-08 | 7e-06 | 2e-35 | 6e-108 | 0 | 1e-12 | 1.000 | 1.000 | -inf | H_all |
| 64 | 1.000 | 0 | 6e-16 | 5e-06 | 1e-87 | 6e-222 | 0 | 5e-13 | 1.000 | 1.000 | -inf | H_all |
| 128 | 1.000 | 0 | 2e-33 | 3e-06 | 8e-172 | 0 | 0 | 4e-13 | 1.000 | 1.000 | -inf | H_all |
| 256 | 1.000 | 0 | 5e-68 | 3e-06 | 0 | 0 | 0 | 1e-13 | 1.000 | 1.000 | -inf | H_all |


## phi = 0+x=x, generator open

Pool size (incl. Mem) 19 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.18; with the parameter: 0.15; L1 inexact counters {'closed1': 0, 'open1': 0, 'open2': 0}.


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0.032 | 0.034 | 2e-07 | 0.796 | 0.137 | 1e-06 | 5e-05 | 0.358 | 0.204 | inf | Mem |
| 2 | 0 | 0.240 | 0.547 | 2e-06 | 0.057 | 0.155 | 5e-06 | 3e-04 | 0.699 | 0.943 | inf | H_open, H_sch, gen1:?G2 |
| 4 | 0 | 0 | 0 | 0.200 | 0.546 | 0.122 | 0 | 0.131 | 0.454 | 0.500 | - | H_all+open, Mem, skel2 |
| 8 | 0 | 0 | 0 | 0 | 0.872 | 1e-09 | 0 | 0.128 | 0.927 | 0.727 | - | Mem, skel2 |
| 16 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 32 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 64 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 128 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 256 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |


**L1** (exact Dirichlet DP too large for Mem, skel4: marginal bounded; the largest posterior mass these could have at any n is 1e-81)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.021 | 0.031 | 0.233 | 1e-06 | 0.598 | 0.117 | 1e-06 | 5e-05 | 0.547 | 0.402 | mixed | H_open, Mem |
| 2 | 0.160 | 0.221 | 0.608 | 4e-06 | 5e-04 | 0.011 | 5e-06 | 3e-04 | 0.774 | 1.000 | mixed | H_open, H_sch |
| 4 | 0.129 | 0 | 0.871 | 4e-06 | 2e-08 | 2e-09 | 0 | 2e-09 | 1.000 | 1.000 | -inf | H_all, H_open |
| 8 | 0 | 0 | 1.000 | 5e-06 | 9e-13 | 7e-22 | 0 | 2e-14 | 1.000 | 1.000 | - | H_open |
| 16 | 0 | 0 | 1.000 | 8e-06 | 5e-23 | 2e-45 | 0 | 2e-21 | 1.000 | 1.000 | - | H_open |
| 32 | 0 | 0 | 1.000 | 3e-06 | 2e-26 | 5e-91 | 0 | 7e-41 | 1.000 | 1.000 | - | H_open |
| 64 | 0 | 0 | 1.000 | 4e-06 | 4e-95 | 7e-189 | 0 | 2e-71 | 1.000 | 1.000 | - | H_open |
| 128 | 0 | 0 | 1.000 | 3e-06 | 3e-281 | 0 | 0 | 7e-182 | 1.000 | 1.000 | - | H_open |
| 256 | 0 | 0 | 1.000 | 2e-06 | 0 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_open |


## phi = 0+x=x, generator allq2

Pool size (incl. Mem) 15 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.59; with the parameter: 0.08; L1 inexact counters {'closed1': 0, 'open1': 0, 'open2': 0}.


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.100 | 0.165 | 0.237 | 2e-06 | 0.495 | 0.002 | 8e-08 | 2e-04 | 0.437 | 0.605 | mixed | H_all, H_open, H_sch |
| 2 | 0.100 | 0.168 | 0.031 | 0.205 | 0.495 | 9e-04 | 0 | 2e-04 | 0.831 | 1.000 | mixed | H_all, H_all+open, H_sch |
| 4 | 0 | 0 | 0 | 0.403 | 0.597 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open, H_all+sch, Mem |
| 8 | 0 | 0 | 0 | 0.787 | 0.213 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open, H_all+sch, Mem |
| 16 | 0 | 0 | 0 | 0.400 | 0.600 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open, Mem |
| 32 | 0 | 0 | 0 | 0.200 | 0.800 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open, Mem |
| 64 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 128 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 256 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |


**L1** (exact Dirichlet DP too large for Mem: marginal bounded; the largest posterior mass these could have at any n is 1e-85)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.166 | 0.144 | 0.197 | 2e-06 | 0.491 | 0.002 | 8e-08 | 2e-04 | 0.460 | 0.606 | mixed | H_all, H_open, H_sch |
| 2 | 0.631 | 0.152 | 0.117 | 6e-06 | 0.100 | 9e-04 | 0 | 2e-04 | 0.847 | 1.000 | mixed | H_all, H_sch |
| 4 | 0.900 | 0 | 0.099 | 8e-06 | 2e-04 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |
| 8 | 0.998 | 0 | 0.002 | 6e-06 | 5e-08 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |
| 16 | 1.000 | 0 | 2e-05 | 8e-06 | 1e-17 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |
| 32 | 1.000 | 0 | 2e-11 | 7e-06 | 7e-45 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |
| 64 | 1.000 | 0 | 7e-25 | 5e-06 | 6e-100 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |
| 128 | 1.000 | 0 | 5e-56 | 3e-06 | 6e-187 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |
| 256 | 1.000 | 0 | 1e-116 | 2e-06 | 0 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |


## phi = ~(Sx=0), generator sch

Pool size (incl. Mem) 16 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.00; with the parameter: 0.00; L1 inexact counters {'closed1': 0, 'open1': 0, 'open2': 0}.


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0.048 | 0.023 | 3e-07 | 0.520 | 0.403 | 0.006 | 7e-05 | 0.224 | 0.476 | inf | Mem |
| 2 | 0 | 0.509 | 0.162 | 2e-06 | 0.194 | 0.135 | 1e-05 | 6e-04 | 0.174 | 0.806 | inf | H_sch, Mem |
| 4 | 0 | 0.869 | 0.127 | 2e-06 | 7e-04 | 0.002 | 9e-06 | 7e-04 | 0.127 | 0.999 | inf | H_sch |
| 8 | 0 | 0.965 | 0.034 | 2e-06 | 5e-13 | 7e-05 | 4e-05 | 6e-04 | 0.034 | 1.000 | inf | H_sch |
| 16 | 0 | 0.998 | 0.002 | 1e-06 | 3e-21 | 1e-07 | 3e-04 | 4e-04 | 0.002 | 1.000 | inf | H_sch |
| 32 | 0 | 1.000 | 9e-07 | 9e-07 | 9e-45 | 3e-13 | 0 | 3e-04 | 2e-06 | 1.000 | inf | H_sch |
| 64 | 0 | 1.000 | 2e-14 | 6e-07 | 1e-89 | 3e-24 | 0 | 2e-04 | 6e-07 | 1.000 | inf | H_sch |
| 128 | 0 | 1.000 | 1e-29 | 4e-07 | 6e-162 | 2e-46 | 0 | 1e-04 | 4e-07 | 1.000 | inf | H_sch |
| 256 | 0 | 1.000 | 2e-61 | 3e-07 | 9e-303 | 7e-91 | 0 | 1e-04 | 3e-07 | 1.000 | inf | H_sch |


**L1**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.009 | 0.047 | 0.023 | 5e-07 | 0.514 | 0.402 | 0.006 | 7e-05 | 0.234 | 0.482 | 2.4 | Mem |
| 2 | 0.044 | 0.480 | 0.154 | 4e-06 | 0.193 | 0.128 | 1e-05 | 5e-04 | 0.210 | 0.807 | 3.4 | H_sch, Mem |
| 4 | 0.020 | 0.852 | 0.125 | 4e-06 | 7e-04 | 0.002 | 9e-06 | 7e-04 | 0.145 | 0.999 | 5.4 | H_sch |
| 8 | 0.001 | 0.964 | 0.034 | 3e-06 | 5e-13 | 7e-05 | 4e-05 | 6e-04 | 0.035 | 1.000 | 9.4 | H_sch |
| 16 | 6e-06 | 0.998 | 0.002 | 2e-06 | 3e-21 | 1e-07 | 3e-04 | 4e-04 | 0.002 | 1.000 | 17.4 | H_sch |
| 32 | 9e-11 | 1.000 | 9e-07 | 1e-06 | 9e-45 | 3e-13 | 0 | 3e-04 | 2e-06 | 1.000 | 33.4 | H_sch |
| 64 | 2e-20 | 1.000 | 2e-14 | 9e-07 | 1e-89 | 3e-24 | 0 | 2e-04 | 9e-07 | 1.000 | 65.4 | H_sch |
| 128 | 1e-39 | 1.000 | 1e-29 | 6e-07 | 6e-162 | 2e-46 | 0 | 1e-04 | 6e-07 | 1.000 | 129.4 | H_sch |
| 256 | 3e-78 | 1.000 | 2e-61 | 4e-07 | 9e-303 | 7e-91 | 0 | 1e-04 | 4e-07 | 1.000 | 257.4 | H_sch |


**L1sel**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.032 | 0.086 | 0.055 | 1e-06 | 0.818 | 0.002 | 0.009 | 1e-04 | 0.086 | 0.176 | 1.4 | Mem |
| 2 | 0.148 | 0.402 | 0.255 | 6e-06 | 0.190 | 0.003 | 8e-06 | 5e-04 | 0.403 | 0.809 | 1.4 | H_open, H_sch, Mem |
| 4 | 0.190 | 0.515 | 0.294 | 8e-06 | 3e-04 | 9e-04 | 4e-06 | 4e-04 | 0.484 | 1.000 | 1.4 | H_open, H_sch |
| 8 | 0.184 | 0.501 | 0.315 | 8e-06 | 2e-13 | 4e-05 | 1e-05 | 3e-04 | 0.499 | 1.000 | 1.4 | H_open, H_sch |
| 16 | 0.212 | 0.576 | 0.211 | 9e-06 | 7e-22 | 7e-08 | 6e-05 | 2e-04 | 0.423 | 1.000 | 1.4 | H_open, H_sch |
| 32 | 0.240 | 0.651 | 0.109 | 1e-05 | 4e-45 | 2e-13 | 0 | 2e-04 | 0.349 | 1.000 | 1.4 | H_open, H_sch |
| 64 | 0.269 | 0.730 | 0.001 | 1e-05 | 9e-90 | 2e-24 | 0 | 2e-04 | 0.270 | 1.000 | 1.4 | H_sch |
| 128 | 0.269 | 0.731 | 5e-08 | 9e-06 | 5e-162 | 1e-46 | 0 | 1e-04 | 0.269 | 1.000 | 1.4 | H_sch |
| 256 | 0.269 | 0.731 | 4e-18 | 9e-06 | 7e-303 | 5e-91 | 0 | 8e-05 | 0.269 | 1.000 | 1.4 | H_sch |


## phi = ~(Sx=0), generator all

Pool size (incl. Mem) 16 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.50; with the parameter: 0.00; L1 inexact counters {'closed1': 0, 'open1': 0, 'open2': 0}.


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.096 | 0.028 | 0.019 | 3e-06 | 0.614 | 0.243 | 1e-06 | 4e-05 | 0.336 | 0.482 | mixed | H_all, Mem |
| 2 | 0.100 | 0.122 | 0.046 | 0.007 | 0.194 | 0.532 | 0 | 1e-04 | 0.849 | 1.000 | mixed | H_all, H_sch, bare?P |
| 4 | 0 | 0 | 0 | 0.420 | 0.575 | 0.004 | 0 | 3e-12 | 1.000 | 1.000 | - | H_all+sch, Mem |
| 8 | 0 | 0 | 0 | 0.996 | 0.004 | 2e-15 | 0 | 3e-12 | 1.000 | 1.000 | - | H_all+sch |
| 16 | 0 | 0 | 0 | 0.966 | 0.034 | 4e-37 | 0 | 1e-12 | 1.000 | 1.000 | - | H_all+sch |
| 32 | 0 | 0 | 0 | 1.000 | 7e-25 | 1e-81 | 0 | 1e-12 | 1.000 | 1.000 | - | H_all+sch |
| 64 | 0 | 0 | 0 | 1.000 | 6e-51 | 1e-178 | 0 | 1e-12 | 1.000 | 1.000 | - | H_all+sch |
| 128 | 0 | 0 | 0 | 1.000 | 2e-98 | 0 | 0 | 7e-13 | 1.000 | 1.000 | - | H_all+sch |
| 256 | 0 | 0 | 0 | 1.000 | 3e-174 | 0 | 0 | 4e-13 | 1.000 | 1.000 | - | H_all+sch |


**L1** (exact Dirichlet DP too large for skel4: marginal bounded; the largest posterior mass these could have at any n is 2e-15)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.087 | 0.027 | 0.048 | 2e-06 | 0.596 | 0.242 | 1e-06 | 4e-05 | 0.343 | 0.487 | mixed | H_all, Mem |
| 2 | 0.479 | 0.115 | 0.276 | 1e-05 | 0.098 | 0.031 | 0 | 1e-04 | 0.857 | 1.000 | mixed | H_all, H_sch |
| 4 | 0.797 | 0 | 0.203 | 2e-05 | 1e-04 | 3e-08 | 0 | 7e-17 | 1.000 | 1.000 | -inf | H_all |
| 8 | 0.984 | 0 | 0.016 | 2e-05 | 3e-08 | 4e-21 | 0 | 4e-17 | 1.000 | 1.000 | -inf | H_all |
| 16 | 0.999 | 0 | 5e-04 | 2e-05 | 1e-07 | 9e-44 | 0 | 2e-17 | 1.000 | 1.000 | -inf | H_all |
| 32 | 1.000 | 0 | 6e-09 | 1e-05 | 3e-32 | 5e-90 | 0 | 2e-17 | 1.000 | 1.000 | -inf | H_all |
| 64 | 1.000 | 0 | 5e-22 | 1e-05 | 2e-59 | 9e-192 | 0 | 1e-17 | 1.000 | 1.000 | -inf | H_all |
| 128 | 1.000 | 0 | 8e-52 | 8e-06 | 2e-109 | 0 | 0 | 4e-18 | 1.000 | 1.000 | -inf | H_all |
| 256 | 1.000 | 0 | 1e-96 | 7e-06 | 3e-191 | 0 | 0 | 3e-70 | 1.000 | 1.000 | -inf | H_all |


## phi = ~(Sx=0), generator allq

Pool size (incl. Mem) 16 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.49; with the parameter: 0.16; L1 inexact counters {'closed1': 0, 'open1': 0, 'open2': 0}.


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.096 | 0.028 | 0.030 | 3e-06 | 0.603 | 0.243 | 3e-04 | 4e-05 | 0.348 | 0.493 | mixed | H_all, Mem, bare?P |
| 2 | 0.100 | 0.138 | 0.226 | 0.004 | 0.163 | 0.369 | 0 | 2e-04 | 0.829 | 1.000 | mixed | H_all, H_open, H_sch |
| 4 | 0 | 0 | 0.200 | 0.419 | 0.381 | 3e-05 | 0 | 2e-06 | 1.000 | 1.000 | - | H_all+open, H_all+sch, H_open |
| 8 | 0 | 0 | 0 | 1.000 | 2e-04 | 1e-19 | 0 | 2e-06 | 1.000 | 1.000 | - | H_all+open, H_all+sch |
| 16 | 0 | 0 | 0 | 1.000 | 2e-10 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 32 | 0 | 0 | 0 | 1.000 | 2e-19 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 64 | 0 | 0 | 0 | 1.000 | 2e-45 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 128 | 0 | 0 | 0 | 1.000 | 2e-84 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 256 | 0 | 0 | 0 | 1.000 | 3e-147 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |


**L1** (exact Dirichlet DP too large for skel4: marginal bounded; the largest posterior mass these could have at any n is 1e-16)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.091 | 0.028 | 0.059 | 3e-06 | 0.579 | 0.244 | 3e-04 | 4e-05 | 0.358 | 0.503 | mixed | H_all, Mem, bare?P |
| 2 | 0.388 | 0.136 | 0.342 | 1e-05 | 0.098 | 0.036 | 0 | 2e-04 | 0.831 | 1.000 | mixed | H_all, H_open, H_sch |
| 4 | 0.649 | 0 | 0.351 | 2e-05 | 9e-05 | 8e-10 | 0 | 1e-10 | 1.000 | 1.000 | -inf | H_all, H_open |
| 8 | 0.865 | 0 | 0.135 | 2e-05 | 2e-09 | 6e-23 | 0 | 7e-11 | 1.000 | 1.000 | -inf | H_all, H_open |
| 16 | 0.998 | 0 | 0.002 | 2e-05 | 1e-15 | 2e-45 | 0 | 1e-10 | 1.000 | 1.000 | -inf | H_all |
| 32 | 1.000 | 0 | 9e-08 | 2e-05 | 6e-26 | 5e-98 | 0 | 6e-11 | 1.000 | 1.000 | -inf | H_all |
| 64 | 1.000 | 0 | 1e-15 | 2e-05 | 2e-54 | 1e-202 | 0 | 3e-11 | 1.000 | 1.000 | -inf | H_all |
| 128 | 1.000 | 0 | 4e-33 | 1e-05 | 5e-97 | 0 | 0 | 2e-11 | 1.000 | 1.000 | -inf | H_all |
| 256 | 1.000 | 0 | 1e-67 | 9e-06 | 2e-167 | 0 | 0 | 7e-12 | 1.000 | 1.000 | -inf | H_all |


## phi = ~(Sx=0), generator open

Pool size (incl. Mem) 16 (data-derived theories left out for lack of exact L1: 10); fraction of data with explicit forall: 0.18; with the parameter: 0.15; L1 inexact counters {'closed1': 0, 'open1': 0, 'open2': 0}.


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0.022 | 0.028 | 2e-07 | 0.750 | 0.201 | 2e-06 | 3e-05 | 0.325 | 0.250 | inf | Mem |
| 2 | 0 | 0.213 | 0.530 | 3e-06 | 0.051 | 0.206 | 1e-05 | 2e-04 | 0.685 | 0.949 | inf | H_open, H_sch, bare?P |
| 4 | 0 | 0 | 0 | 0.200 | 0.575 | 0.225 | 0 | 0 | 0.425 | 0.469 | - | H_all+open, Mem, bare?P |
| 8 | 0 | 0 | 0 | 0 | 1.000 | 1e-08 | 0 | 0 | 0.800 | 0.600 | - | Mem |
| 16 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 32 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 64 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 128 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 256 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |


**L1** (exact Dirichlet DP too large for Mem: marginal bounded; the largest posterior mass these could have at any n is 6e-53)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.007 | 0.021 | 0.132 | 9e-07 | 0.647 | 0.193 | 2e-06 | 3e-05 | 0.424 | 0.353 | mixed | H_open, Mem |
| 2 | 0.074 | 0.206 | 0.664 | 6e-06 | 5e-04 | 0.055 | 1e-05 | 2e-04 | 0.743 | 0.999 | mixed | H_open, H_sch |
| 4 | 0.083 | 0 | 0.917 | 6e-06 | 4e-08 | 2e-08 | 0 | 0 | 1.000 | 1.000 | -inf | H_open |
| 8 | 0 | 0 | 1.000 | 7e-06 | 5e-09 | 9e-18 | 0 | 0 | 1.000 | 1.000 | - | H_open |
| 16 | 0 | 0 | 1.000 | 1e-05 | 1e-19 | 1e-37 | 0 | 0 | 1.000 | 1.000 | - | H_open |
| 32 | 0 | 0 | 1.000 | 5e-06 | 5e-22 | 1e-79 | 0 | 0 | 1.000 | 1.000 | - | H_open |
| 64 | 0 | 0 | 1.000 | 6e-06 | 2e-66 | 2e-165 | 0 | 0 | 1.000 | 1.000 | - | H_open |
| 128 | 0 | 0 | 1.000 | 3e-06 | 4e-159 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_open |
| 256 | 0 | 0 | 1.000 | 3e-06 | 9e-289 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_open |


## phi = ~(Sx=0), generator allq2

Pool size (incl. Mem) 14 (data-derived theories left out for lack of exact L1: 11); fraction of data with explicit forall: 0.59; with the parameter: 0.08; L1 inexact counters {'closed1': 0, 'open1': 0, 'open2': 0}.


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.100 | 0.039 | 0.034 | 3e-06 | 0.663 | 0.164 | 9e-07 | 6e-05 | 0.234 | 0.437 | mixed | H_all, Mem, gen0:~?G0 |
| 2 | 0.100 | 0.140 | 0.026 | 0.044 | 0.657 | 0.034 | 0 | 2e-04 | 0.826 | 1.000 | mixed | H_all, H_sch, Mem |
| 4 | 0 | 0 | 0 | 0.419 | 0.581 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open, H_all+sch, Mem |
| 8 | 0 | 0 | 0 | 0.792 | 0.208 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open, H_all+sch, Mem |
| 16 | 0 | 0 | 0 | 0.400 | 0.600 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open, Mem |
| 32 | 0 | 0 | 0 | 0.200 | 0.800 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open, Mem |
| 64 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 128 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 256 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |


**L1** (exact Dirichlet DP too large for Mem: marginal bounded; the largest posterior mass these could have at any n is 8e-53)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.098 | 0.038 | 0.054 | 3e-06 | 0.648 | 0.162 | 9e-07 | 6e-05 | 0.244 | 0.445 | mixed | H_all, Mem, gen0:~?G0 |
| 2 | 0.540 | 0.131 | 0.197 | 2e-05 | 0.100 | 0.032 | 0 | 1e-04 | 0.837 | 1.000 | mixed | H_all, H_sch |
| 4 | 0.840 | 0 | 0.159 | 3e-05 | 1e-04 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all, H_open |
| 8 | 0.995 | 0 | 0.005 | 2e-05 | 9e-08 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |
| 16 | 1.000 | 0 | 5e-05 | 3e-05 | 8e-16 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |
| 32 | 1.000 | 0 | 5e-11 | 2e-05 | 2e-33 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |
| 64 | 1.000 | 0 | 2e-24 | 2e-05 | 6e-67 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |
| 128 | 1.000 | 0 | 1e-55 | 1e-05 | 1e-119 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |
| 256 | 1.000 | 0 | 3e-116 | 8e-06 | 5e-217 | 0 | 0 | 0 | 1.000 | 1.000 | -inf | H_all |

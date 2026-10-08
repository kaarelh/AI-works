# E1: forall x phi from data about phi

Command: `cd code/experiments && python3 e1_universal.py`. Seeds [0, 1, 2, 3, 4]. n in [1, 2, 4, 8, 16, 32, 64, 128, 256]. Q = default Grammar (bai/grammar.py); L1 chain: c_stop = 0.5, c_elim = c_gen = c_mp = 1; Dirichlet alpha = 0.5; prior 2^-bits (TemplateCode), lambda = 1, no time factor. Wall time 58 s.

Generators: sch = L0 citations of phi(?t) (closed terms); all = L1 chain (K=1) from {forall x phi}, closed elim terms; allq = the same with open elim terms; open = L1 chain (K=1) from {phi(?t) open}; allq2 = L1 chain with K=2 from {forall x phi}, open elim terms. The L1 likelihood is the generator's own chain (well specified); for allq2 the pool has no bare formula metavariables (K=2 is only computed exactly without them). L1sel (sch data only) is the closed-elim K=1 chain observed through closed quantifier-free outputs; its pool is restricted to theories whose class probability is computed exactly (bai.lik.class_prob_qf).

Columns: posterior mass of H_all = {forall x phi}, H_sch = {phi(?t) closed}, H_open = {phi(?t) open}, H_all+sch, Mem(D_n), over-general, over-specific and fragmented theories (summed over the pool); P(|-forall) = posterior mass of theories T with T |-_1 forall x phi (chain derivations of length <= 1); P(|-inst) = the same for held-out closed instances (mean over 3); "Mem" = Mem(D_n) and any pool theory of ground data seen so far; lo = log2 posterior odds H_sch : H_all. Means over seeds.


## phi = x+0=x, generator sch

Pool size (incl. Mem) 26 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.00; with the parameter: 0.00; L1 likelihood fallback counters, summed over seeds: {'closed1': 0, 'open1': 0, 'open2': 0}.

Derivability oracle (|-_1) fallback count, summed over seeds: 0 (0 = every derivability answer exact).


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0.345 | 0.105 | 2e-06 | 0.429 | 0.121 | 8e-06 | 5e-04 | 0.221 | 0.571 | inf | H_sch, min0@1:0+0=0, min0@1:1+0=1 |
| 2 | 0 | 0.603 | 0.184 | 2e-06 | 0.199 | 0.014 | 1e-04 | 7e-04 | 0.191 | 0.801 | inf | H_sch, min0@1:0+0=0 |
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
| 1 | 0.120 | 0.254 | 0.080 | 2e-06 | 0.418 | 0.127 | 6e-06 | 4e-04 | 0.323 | 0.582 | 1.1 | H_sch, min0@1:0+0=0, min0@1:1+0=1 |
| 2 | 0.120 | 0.509 | 0.159 | 3e-06 | 0.199 | 0.012 | 9e-05 | 6e-04 | 0.286 | 0.801 | 2.1 | H_sch, min0@1:0+0=0 |
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
| 1 | 0.195 | 0.208 | 0.104 | 2e-06 | 0.489 | 0.003 | 5e-06 | 3e-04 | 0.299 | 0.511 | 9e-02 | H_sch, min0@1:0+0=0, min0@1:1+0=1 |
| 2 | 0.288 | 0.307 | 0.203 | 4e-06 | 0.198 | 0.003 | 6e-05 | 3e-04 | 0.491 | 0.802 | 9e-02 | H_open, H_sch, min0@1:0+0=0 |
| 4 | 0.368 | 0.391 | 0.240 | 5e-06 | 5e-04 | 5e-04 | 1e-06 | 3e-04 | 0.607 | 1.000 | 9e-02 | H_open, H_sch |
| 8 | 0.361 | 0.384 | 0.255 | 5e-06 | 2e-16 | 2e-05 | 4e-06 | 2e-04 | 0.616 | 1.000 | 9e-02 | H_open, H_sch |
| 16 | 0.398 | 0.424 | 0.177 | 5e-06 | 6e-29 | 3e-08 | 2e-05 | 2e-04 | 0.576 | 1.000 | 9e-02 | H_open, H_sch |
| 32 | 0.443 | 0.471 | 0.086 | 5e-06 | 8e-71 | 1e-13 | 0 | 1e-04 | 0.529 | 1.000 | 9e-02 | H_open, H_sch |
| 64 | 0.484 | 0.515 | 9e-04 | 5e-06 | 5e-175 | 9e-25 | 0 | 1e-04 | 0.485 | 1.000 | 9e-02 | H_sch |
| 128 | 0.484 | 0.516 | 3e-08 | 5e-06 | 0 | 6e-47 | 0 | 8e-05 | 0.484 | 1.000 | 9e-02 | H_sch |
| 256 | 0.484 | 0.516 | 3e-18 | 5e-06 | 0 | 2e-91 | 0 | 5e-05 | 0.484 | 1.000 | 9e-02 | H_sch |


## phi = x+0=x, generator all

Pool size (incl. Mem) 23 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.50; with the parameter: 0.00; L1 likelihood fallback counters, summed over seeds: {'closed1': 0, 'open1': 0, 'open2': 0}.

Derivability oracle (|-_1) fallback count, summed over seeds: 0 (0 = every derivability answer exact).


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.187 | 0.136 | 0.060 | 2e-06 | 0.535 | 0.081 | 1e-07 | 2e-04 | 0.327 | 0.465 | mixed | H_all, H_sch, min0@1:0+0=0 |
| 2 | 0.200 | 0.145 | 0.054 | 0.002 | 0.136 | 0.463 | 0 | 2e-04 | 0.854 | 1.000 | mixed | H_all, H_sch, gen1:?G2 |
| 4 | 0 | 0 | 0 | 0.404 | 0.596 | 1e-05 | 0 | 2e-05 | 1.000 | 1.000 | - | H_all+sch, Mem |
| 8 | 0 | 0 | 0 | 0.991 | 0.009 | 4e-15 | 0 | 3e-05 | 1.000 | 1.000 | - | H_all+sch |
| 16 | 0 | 0 | 0 | 0.933 | 0.067 | 8e-38 | 0 | 3e-05 | 1.000 | 1.000 | - | H_all+sch |
| 32 | 0 | 0 | 0 | 1.000 | 4e-40 | 6e-101 | 0 | 1e-05 | 1.000 | 1.000 | - | H_all+sch |
| 64 | 0 | 0 | 0 | 1.000 | 1e-97 | 1e-224 | 0 | 2e-05 | 1.000 | 1.000 | - | H_all+sch |
| 128 | 0 | 0 | 0 | 1.000 | 1e-204 | 0 | 0 | 3e-05 | 1.000 | 1.000 | - | H_all+sch |
| 256 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 9e-06 | 1.000 | 1.000 | - | H_all+sch |


**L1** (exact Dirichlet DP too large for skel4@32, skel4@64: marginal bounded; the largest posterior mass these could have at any n is 4e-19)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.214 | 0.103 | 0.069 | 2e-06 | 0.531 | 0.083 | 1e-07 | 2e-04 | 0.364 | 0.469 | mixed | H_all, H_sch, min0@1:0+0=0 |
| 2 | 0.708 | 0.124 | 0.167 | 6e-06 | 2e-04 | 0.001 | 0 | 1e-04 | 0.876 | 1.000 | mixed | H_all, H_sch |
| 4 | 0.900 | 0 | 0.100 | 8e-06 | 3e-04 | 2e-10 | 0 | 2e-10 | 1.000 | 1.000 | -inf | H_all |
| 8 | 0.993 | 0 | 0.007 | 6e-06 | 2e-08 | 2e-21 | 0 | 7e-11 | 1.000 | 1.000 | -inf | H_all |
| 16 | 1.000 | 0 | 2e-04 | 6e-06 | 7e-08 | 7e-45 | 0 | 2e-10 | 1.000 | 1.000 | -inf | H_all |
| 32 | 1.000 | 0 | 2e-09 | 4e-06 | 1e-48 | 3e-102 | 0 | 2e-11 | 1.000 | 1.000 | -inf | H_all |
| 64 | 1.000 | 0 | 2e-22 | 3e-06 | 1e-106 | 1e-219 | 0 | 3e-11 | 1.000 | 1.000 | -inf | H_all |
| 128 | 1.000 | 0 | 3e-52 | 2e-06 | 3e-216 | 0 | 0 | 3e-11 | 1.000 | 1.000 | -inf | H_all |
| 256 | 1.000 | 0 | 5e-97 | 2e-06 | 0 | 0 | 0 | 9e-12 | 1.000 | 1.000 | -inf | H_all |


## phi = x+0=x, generator allq

Pool size (incl. Mem) 22 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.49; with the parameter: 0.16; L1 likelihood fallback counters, summed over seeds: {'closed1': 0, 'open1': 0, 'open2': 0}.

Derivability oracle (|-_1) fallback count, summed over seeds: 0 (0 = every derivability answer exact).


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.187 | 0.165 | 0.237 | 3e-06 | 0.355 | 0.056 | 7e-08 | 2e-04 | 0.478 | 0.645 | mixed | H_all, H_open, H_sch |
| 2 | 0.200 | 0.168 | 0.231 | 0.001 | 0.091 | 0.309 | 0 | 2e-04 | 0.831 | 1.000 | mixed | H_all, H_open, H_sch |
| 4 | 0 | 0 | 0.200 | 0.403 | 0.397 | 3e-07 | 0 | 0 | 1.000 | 1.000 | - | H_all+open, H_all+sch, H_open |
| 8 | 0 | 0 | 0 | 1.000 | 1e-07 | 6e-25 | 0 | 0 | 1.000 | 1.000 | - | H_all+open, H_all+sch |
| 16 | 0 | 0 | 0 | 1.000 | 9e-12 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 32 | 0 | 0 | 0 | 1.000 | 2e-28 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 64 | 0 | 0 | 0 | 1.000 | 1e-77 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 128 | 0 | 0 | 0 | 1.000 | 1e-158 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 256 | 0 | 0 | 0 | 1.000 | 5e-309 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |


**L1** (exact Dirichlet DP too large for skel4@16, skel4@64: marginal bounded; the largest posterior mass these could have at any n is 5e-16)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.274 | 0.152 | 0.156 | 3e-06 | 0.353 | 0.065 | 7e-08 | 2e-04 | 0.493 | 0.647 | mixed | H_all, H_open, H_sch |
| 2 | 0.613 | 0.162 | 0.224 | 6e-06 | 2e-04 | 0.001 | 0 | 2e-04 | 0.837 | 1.000 | mixed | H_all, H_open, H_sch |
| 4 | 0.764 | 0 | 0.235 | 8e-06 | 2e-04 | 9e-11 | 0 | 3e-14 | 1.000 | 1.000 | -inf | H_all, H_open |
| 8 | 0.921 | 0 | 0.079 | 6e-06 | 6e-13 | 7e-24 | 0 | 1e-10 | 1.000 | 1.000 | -inf | H_all |
| 16 | 0.999 | 0 | 7e-04 | 7e-06 | 2e-17 | 1e-48 | 0 | 3e-10 | 1.000 | 1.000 | -inf | H_all |
| 32 | 1.000 | 0 | 4e-08 | 7e-06 | 2e-35 | 6e-108 | 0 | 1e-10 | 1.000 | 1.000 | -inf | H_all |
| 64 | 1.000 | 0 | 6e-16 | 5e-06 | 1e-87 | 6e-222 | 0 | 4e-11 | 1.000 | 1.000 | -inf | H_all |
| 128 | 1.000 | 0 | 2e-33 | 3e-06 | 8e-172 | 0 | 0 | 1e-11 | 1.000 | 1.000 | -inf | H_all |
| 256 | 1.000 | 0 | 5e-68 | 3e-06 | 0 | 0 | 0 | 1e-11 | 1.000 | 1.000 | -inf | H_all |


## phi = x+0=x, generator open

Pool size (incl. Mem) 25 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.18; with the parameter: 0.15; L1 likelihood fallback counters, summed over seeds: {'closed1': 0, 'open1': 0, 'open2': 0}.

Derivability oracle (|-_1) fallback count, summed over seeds: 0 (0 = every derivability answer exact).


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0.032 | 0.034 | 2e-07 | 0.796 | 0.137 | 1e-06 | 5e-05 | 0.358 | 0.204 | inf | min0@1:0+0=0, min0@1:1+0=1, min0@1:2+0=2 |
| 2 | 0 | 0.240 | 0.547 | 2e-06 | 0.017 | 0.054 | 5e-06 | 0.141 | 0.738 | 0.983 | inf | H_open, H_sch, min0@2:Ax.?P0(x) |
| 4 | 0 | 0 | 0 | 0.200 | 0.264 | 0.014 | 0 | 0.522 | 0.367 | 0.741 | - | H_all+open, Mem, skel2@4 |
| 8 | 0 | 0 | 0 | 0 | 0.806 | 5e-10 | 0 | 0.194 | 0.800 | 0.793 | - | Mem, skel2@4 |
| 16 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 3e-05 | 1.000 | 1.000 | - | Mem |
| 32 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 2e-14 | 1.000 | 1.000 | - | Mem |
| 64 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 128 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 256 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |


**L1** (exact Dirichlet DP too large for Mem, skel4@16, skel4@32, skel4@64, skel4@8: marginal bounded; the largest posterior mass these could have at any n is 1e-81)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.021 | 0.031 | 0.233 | 1e-06 | 0.598 | 0.117 | 1e-06 | 5e-05 | 0.547 | 0.402 | mixed | H_open, min0@1:0+0=0, min0@1:1+0=1 |
| 2 | 0.160 | 0.221 | 0.608 | 4e-06 | 5e-04 | 0.011 | 5e-06 | 2e-04 | 0.774 | 1.000 | mixed | H_open, H_sch |
| 4 | 0.129 | 0 | 0.871 | 4e-06 | 2e-08 | 2e-09 | 0 | 4e-07 | 1.000 | 1.000 | -inf | H_all, H_open |
| 8 | 0 | 0 | 1.000 | 5e-06 | 9e-13 | 7e-22 | 0 | 3e-15 | 1.000 | 1.000 | - | H_open |
| 16 | 0 | 0 | 1.000 | 8e-06 | 5e-23 | 2e-45 | 0 | 2e-21 | 1.000 | 1.000 | - | H_open |
| 32 | 0 | 0 | 1.000 | 3e-06 | 2e-26 | 5e-91 | 0 | 1e-29 | 1.000 | 1.000 | - | H_open |
| 64 | 0 | 0 | 1.000 | 4e-06 | 4e-95 | 7e-189 | 0 | 3e-58 | 1.000 | 1.000 | - | H_open |
| 128 | 0 | 0 | 1.000 | 3e-06 | 3e-281 | 0 | 0 | 1e-161 | 1.000 | 1.000 | - | H_open |
| 256 | 0 | 0 | 1.000 | 2e-06 | 0 | 0 | 0 | 9e-242 | 1.000 | 1.000 | - | H_open |


## phi = x+0=x, generator allq2

Pool size (incl. Mem) 19 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.59; with the parameter: 0.08; L1 likelihood fallback counters, summed over seeds: {'closed1': 0, 'open1': 0, 'open2': 0}.

Derivability oracle (|-_1) fallback count, summed over seeds: 0 (0 = every derivability answer exact).


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.200 | 0.165 | 0.237 | 3e-06 | 0.395 | 0.002 | 8e-08 | 2e-04 | 0.437 | 0.605 | mixed | H_all, H_open, H_sch |
| 2 | 0.200 | 0.168 | 0.031 | 0.205 | 0.395 | 9e-04 | 0 | 2e-04 | 0.831 | 1.000 | mixed | H_all, H_all+open, H_sch |
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
| 1 | 0.257 | 0.144 | 0.203 | 3e-06 | 0.394 | 0.002 | 8e-08 | 2e-04 | 0.460 | 0.606 | mixed | H_all, H_open, H_sch |
| 2 | 0.730 | 0.152 | 0.117 | 7e-06 | 2e-04 | 9e-04 | 0 | 2e-04 | 0.847 | 1.000 | mixed | H_all, H_sch |
| 4 | 0.900 | 0 | 0.099 | 8e-06 | 2e-04 | 0 | 0 | 3e-14 | 1.000 | 1.000 | -inf | H_all |
| 8 | 0.998 | 0 | 0.002 | 6e-06 | 5e-08 | 0 | 0 | 3e-11 | 1.000 | 1.000 | -inf | H_all |
| 16 | 1.000 | 0 | 2e-05 | 8e-06 | 1e-17 | 0 | 0 | 6e-11 | 1.000 | 1.000 | -inf | H_all |
| 32 | 1.000 | 0 | 2e-11 | 7e-06 | 7e-45 | 0 | 0 | 3e-11 | 1.000 | 1.000 | -inf | H_all |
| 64 | 1.000 | 0 | 7e-25 | 5e-06 | 6e-100 | 0 | 0 | 1e-11 | 1.000 | 1.000 | -inf | H_all |
| 128 | 1.000 | 0 | 5e-56 | 3e-06 | 6e-187 | 0 | 0 | 7e-12 | 1.000 | 1.000 | -inf | H_all |
| 256 | 1.000 | 0 | 1e-116 | 2e-06 | 0 | 0 | 0 | 4e-12 | 1.000 | 1.000 | -inf | H_all |


## phi = 0+x=x, generator sch

Pool size (incl. Mem) 26 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.00; with the parameter: 0.00; L1 likelihood fallback counters, summed over seeds: {'closed1': 0, 'open1': 0, 'open2': 0}.

Derivability oracle (|-_1) fallback count, summed over seeds: 0 (0 = every derivability answer exact).


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0.345 | 0.105 | 2e-06 | 0.429 | 0.121 | 8e-06 | 5e-04 | 0.221 | 0.571 | inf | H_sch, min0@1:0+0=0, min0@1:0+1=1 |
| 2 | 0 | 0.603 | 0.184 | 2e-06 | 0.199 | 0.014 | 1e-04 | 7e-04 | 0.191 | 0.801 | inf | H_sch, min0@1:0+0=0 |
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
| 1 | 0.120 | 0.254 | 0.080 | 2e-06 | 0.418 | 0.127 | 6e-06 | 4e-04 | 0.323 | 0.582 | 1.1 | H_sch, min0@1:0+0=0, min0@1:0+1=1 |
| 2 | 0.120 | 0.509 | 0.159 | 3e-06 | 0.199 | 0.012 | 9e-05 | 6e-04 | 0.286 | 0.801 | 2.1 | H_sch, min0@1:0+0=0 |
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
| 1 | 0.195 | 0.208 | 0.104 | 2e-06 | 0.489 | 0.003 | 5e-06 | 3e-04 | 0.299 | 0.511 | 9e-02 | H_sch, min0@1:0+0=0, min0@1:0+1=1 |
| 2 | 0.288 | 0.307 | 0.203 | 4e-06 | 0.198 | 0.003 | 6e-05 | 3e-04 | 0.491 | 0.802 | 9e-02 | H_open, H_sch, min0@1:0+0=0 |
| 4 | 0.368 | 0.391 | 0.240 | 5e-06 | 5e-04 | 5e-04 | 1e-06 | 3e-04 | 0.607 | 1.000 | 9e-02 | H_open, H_sch |
| 8 | 0.361 | 0.384 | 0.255 | 5e-06 | 2e-16 | 2e-05 | 4e-06 | 2e-04 | 0.616 | 1.000 | 9e-02 | H_open, H_sch |
| 16 | 0.398 | 0.424 | 0.177 | 5e-06 | 6e-29 | 3e-08 | 2e-05 | 2e-04 | 0.576 | 1.000 | 9e-02 | H_open, H_sch |
| 32 | 0.443 | 0.471 | 0.086 | 5e-06 | 8e-71 | 1e-13 | 0 | 1e-04 | 0.529 | 1.000 | 9e-02 | H_open, H_sch |
| 64 | 0.484 | 0.515 | 9e-04 | 5e-06 | 5e-175 | 9e-25 | 0 | 1e-04 | 0.485 | 1.000 | 9e-02 | H_sch |
| 128 | 0.484 | 0.516 | 3e-08 | 5e-06 | 0 | 6e-47 | 0 | 8e-05 | 0.484 | 1.000 | 9e-02 | H_sch |
| 256 | 0.484 | 0.516 | 3e-18 | 5e-06 | 0 | 2e-91 | 0 | 5e-05 | 0.484 | 1.000 | 9e-02 | H_sch |


## phi = 0+x=x, generator all

Pool size (incl. Mem) 23 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.50; with the parameter: 0.00; L1 likelihood fallback counters, summed over seeds: {'closed1': 0, 'open1': 0, 'open2': 0}.

Derivability oracle (|-_1) fallback count, summed over seeds: 0 (0 = every derivability answer exact).


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.187 | 0.136 | 0.060 | 2e-06 | 0.535 | 0.081 | 1e-07 | 2e-04 | 0.327 | 0.465 | mixed | H_all, H_sch, min0@1:0+0=0 |
| 2 | 0.200 | 0.145 | 0.054 | 0.002 | 0.136 | 0.463 | 0 | 2e-04 | 0.854 | 1.000 | mixed | H_all, H_sch, gen1:?G2 |
| 4 | 0 | 0 | 0 | 0.404 | 0.596 | 1e-05 | 0 | 2e-05 | 1.000 | 1.000 | - | H_all+sch, Mem |
| 8 | 0 | 0 | 0 | 0.991 | 0.009 | 4e-15 | 0 | 3e-05 | 1.000 | 1.000 | - | H_all+sch |
| 16 | 0 | 0 | 0 | 0.933 | 0.067 | 8e-38 | 0 | 3e-05 | 1.000 | 1.000 | - | H_all+sch |
| 32 | 0 | 0 | 0 | 1.000 | 4e-40 | 6e-101 | 0 | 1e-05 | 1.000 | 1.000 | - | H_all+sch |
| 64 | 0 | 0 | 0 | 1.000 | 1e-97 | 1e-224 | 0 | 2e-05 | 1.000 | 1.000 | - | H_all+sch |
| 128 | 0 | 0 | 0 | 1.000 | 1e-204 | 0 | 0 | 3e-05 | 1.000 | 1.000 | - | H_all+sch |
| 256 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 9e-06 | 1.000 | 1.000 | - | H_all+sch |


**L1** (exact Dirichlet DP too large for skel4@32, skel4@64: marginal bounded; the largest posterior mass these could have at any n is 4e-19)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.214 | 0.103 | 0.069 | 2e-06 | 0.531 | 0.083 | 1e-07 | 2e-04 | 0.364 | 0.469 | mixed | H_all, H_sch, min0@1:0+0=0 |
| 2 | 0.708 | 0.124 | 0.167 | 6e-06 | 2e-04 | 0.001 | 0 | 1e-04 | 0.876 | 1.000 | mixed | H_all, H_sch |
| 4 | 0.900 | 0 | 0.100 | 8e-06 | 3e-04 | 2e-10 | 0 | 2e-10 | 1.000 | 1.000 | -inf | H_all |
| 8 | 0.993 | 0 | 0.007 | 6e-06 | 2e-08 | 2e-21 | 0 | 7e-11 | 1.000 | 1.000 | -inf | H_all |
| 16 | 1.000 | 0 | 2e-04 | 6e-06 | 7e-08 | 7e-45 | 0 | 2e-10 | 1.000 | 1.000 | -inf | H_all |
| 32 | 1.000 | 0 | 2e-09 | 4e-06 | 1e-48 | 3e-102 | 0 | 2e-11 | 1.000 | 1.000 | -inf | H_all |
| 64 | 1.000 | 0 | 2e-22 | 3e-06 | 1e-106 | 1e-219 | 0 | 3e-11 | 1.000 | 1.000 | -inf | H_all |
| 128 | 1.000 | 0 | 3e-52 | 2e-06 | 3e-216 | 0 | 0 | 3e-11 | 1.000 | 1.000 | -inf | H_all |
| 256 | 1.000 | 0 | 5e-97 | 2e-06 | 0 | 0 | 0 | 9e-12 | 1.000 | 1.000 | -inf | H_all |


## phi = 0+x=x, generator allq

Pool size (incl. Mem) 22 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.49; with the parameter: 0.16; L1 likelihood fallback counters, summed over seeds: {'closed1': 0, 'open1': 0, 'open2': 0}.

Derivability oracle (|-_1) fallback count, summed over seeds: 0 (0 = every derivability answer exact).


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.187 | 0.165 | 0.237 | 3e-06 | 0.355 | 0.056 | 7e-08 | 2e-04 | 0.478 | 0.645 | mixed | H_all, H_open, H_sch |
| 2 | 0.200 | 0.168 | 0.231 | 0.001 | 0.091 | 0.309 | 0 | 2e-04 | 0.831 | 1.000 | mixed | H_all, H_open, H_sch |
| 4 | 0 | 0 | 0.200 | 0.403 | 0.397 | 3e-07 | 0 | 0 | 1.000 | 1.000 | - | H_all+open, H_all+sch, H_open |
| 8 | 0 | 0 | 0 | 1.000 | 1e-07 | 6e-25 | 0 | 0 | 1.000 | 1.000 | - | H_all+open, H_all+sch |
| 16 | 0 | 0 | 0 | 1.000 | 9e-12 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 32 | 0 | 0 | 0 | 1.000 | 2e-28 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 64 | 0 | 0 | 0 | 1.000 | 1e-77 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 128 | 0 | 0 | 0 | 1.000 | 1e-158 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 256 | 0 | 0 | 0 | 1.000 | 5e-309 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |


**L1** (exact Dirichlet DP too large for skel4@16, skel4@64: marginal bounded; the largest posterior mass these could have at any n is 5e-16)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.274 | 0.152 | 0.156 | 3e-06 | 0.353 | 0.065 | 7e-08 | 2e-04 | 0.493 | 0.647 | mixed | H_all, H_open, H_sch |
| 2 | 0.613 | 0.162 | 0.224 | 6e-06 | 2e-04 | 0.001 | 0 | 2e-04 | 0.837 | 1.000 | mixed | H_all, H_open, H_sch |
| 4 | 0.764 | 0 | 0.235 | 8e-06 | 2e-04 | 9e-11 | 0 | 3e-14 | 1.000 | 1.000 | -inf | H_all, H_open |
| 8 | 0.921 | 0 | 0.079 | 6e-06 | 6e-13 | 7e-24 | 0 | 1e-10 | 1.000 | 1.000 | -inf | H_all |
| 16 | 0.999 | 0 | 7e-04 | 7e-06 | 2e-17 | 1e-48 | 0 | 3e-10 | 1.000 | 1.000 | -inf | H_all |
| 32 | 1.000 | 0 | 4e-08 | 7e-06 | 2e-35 | 6e-108 | 0 | 1e-10 | 1.000 | 1.000 | -inf | H_all |
| 64 | 1.000 | 0 | 6e-16 | 5e-06 | 1e-87 | 6e-222 | 0 | 4e-11 | 1.000 | 1.000 | -inf | H_all |
| 128 | 1.000 | 0 | 2e-33 | 3e-06 | 8e-172 | 0 | 0 | 1e-11 | 1.000 | 1.000 | -inf | H_all |
| 256 | 1.000 | 0 | 5e-68 | 3e-06 | 0 | 0 | 0 | 1e-11 | 1.000 | 1.000 | -inf | H_all |


## phi = 0+x=x, generator open

Pool size (incl. Mem) 25 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.18; with the parameter: 0.15; L1 likelihood fallback counters, summed over seeds: {'closed1': 0, 'open1': 0, 'open2': 0}.

Derivability oracle (|-_1) fallback count, summed over seeds: 0 (0 = every derivability answer exact).


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0.032 | 0.034 | 2e-07 | 0.796 | 0.137 | 1e-06 | 5e-05 | 0.358 | 0.204 | inf | min0@1:0+0=0, min0@1:0+1=1, min0@1:0+2=2 |
| 2 | 0 | 0.240 | 0.547 | 2e-06 | 0.017 | 0.054 | 5e-06 | 0.141 | 0.738 | 0.983 | inf | H_open, H_sch, min0@2:Ax.?P0(x) |
| 4 | 0 | 0 | 0 | 0.200 | 0.264 | 0.014 | 0 | 0.522 | 0.367 | 0.741 | - | H_all+open, Mem, skel2@4 |
| 8 | 0 | 0 | 0 | 0 | 0.806 | 5e-10 | 0 | 0.194 | 0.800 | 0.793 | - | Mem, skel2@4 |
| 16 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 3e-05 | 1.000 | 1.000 | - | Mem |
| 32 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 2e-14 | 1.000 | 1.000 | - | Mem |
| 64 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 128 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 256 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |


**L1** (exact Dirichlet DP too large for Mem, skel4@16, skel4@32, skel4@64, skel4@8: marginal bounded; the largest posterior mass these could have at any n is 1e-81)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.021 | 0.031 | 0.233 | 1e-06 | 0.598 | 0.117 | 1e-06 | 5e-05 | 0.547 | 0.402 | mixed | H_open, min0@1:0+0=0, min0@1:0+1=1 |
| 2 | 0.160 | 0.221 | 0.608 | 4e-06 | 5e-04 | 0.011 | 5e-06 | 2e-04 | 0.774 | 1.000 | mixed | H_open, H_sch |
| 4 | 0.129 | 0 | 0.871 | 4e-06 | 2e-08 | 2e-09 | 0 | 4e-07 | 1.000 | 1.000 | -inf | H_all, H_open |
| 8 | 0 | 0 | 1.000 | 5e-06 | 9e-13 | 7e-22 | 0 | 3e-15 | 1.000 | 1.000 | - | H_open |
| 16 | 0 | 0 | 1.000 | 8e-06 | 5e-23 | 2e-45 | 0 | 2e-21 | 1.000 | 1.000 | - | H_open |
| 32 | 0 | 0 | 1.000 | 3e-06 | 2e-26 | 5e-91 | 0 | 1e-29 | 1.000 | 1.000 | - | H_open |
| 64 | 0 | 0 | 1.000 | 4e-06 | 4e-95 | 7e-189 | 0 | 3e-58 | 1.000 | 1.000 | - | H_open |
| 128 | 0 | 0 | 1.000 | 3e-06 | 3e-281 | 0 | 0 | 1e-161 | 1.000 | 1.000 | - | H_open |
| 256 | 0 | 0 | 1.000 | 2e-06 | 0 | 0 | 0 | 9e-242 | 1.000 | 1.000 | - | H_open |


## phi = 0+x=x, generator allq2

Pool size (incl. Mem) 19 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.59; with the parameter: 0.08; L1 likelihood fallback counters, summed over seeds: {'closed1': 0, 'open1': 0, 'open2': 0}.

Derivability oracle (|-_1) fallback count, summed over seeds: 0 (0 = every derivability answer exact).


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.200 | 0.165 | 0.237 | 3e-06 | 0.395 | 0.002 | 8e-08 | 2e-04 | 0.437 | 0.605 | mixed | H_all, H_open, H_sch |
| 2 | 0.200 | 0.168 | 0.031 | 0.205 | 0.395 | 9e-04 | 0 | 2e-04 | 0.831 | 1.000 | mixed | H_all, H_all+open, H_sch |
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
| 1 | 0.257 | 0.144 | 0.203 | 3e-06 | 0.394 | 0.002 | 8e-08 | 2e-04 | 0.460 | 0.606 | mixed | H_all, H_open, H_sch |
| 2 | 0.730 | 0.152 | 0.117 | 7e-06 | 2e-04 | 9e-04 | 0 | 2e-04 | 0.847 | 1.000 | mixed | H_all, H_sch |
| 4 | 0.900 | 0 | 0.099 | 8e-06 | 2e-04 | 0 | 0 | 3e-14 | 1.000 | 1.000 | -inf | H_all |
| 8 | 0.998 | 0 | 0.002 | 6e-06 | 5e-08 | 0 | 0 | 3e-11 | 1.000 | 1.000 | -inf | H_all |
| 16 | 1.000 | 0 | 2e-05 | 8e-06 | 1e-17 | 0 | 0 | 6e-11 | 1.000 | 1.000 | -inf | H_all |
| 32 | 1.000 | 0 | 2e-11 | 7e-06 | 7e-45 | 0 | 0 | 3e-11 | 1.000 | 1.000 | -inf | H_all |
| 64 | 1.000 | 0 | 7e-25 | 5e-06 | 6e-100 | 0 | 0 | 1e-11 | 1.000 | 1.000 | -inf | H_all |
| 128 | 1.000 | 0 | 5e-56 | 3e-06 | 6e-187 | 0 | 0 | 7e-12 | 1.000 | 1.000 | -inf | H_all |
| 256 | 1.000 | 0 | 1e-116 | 2e-06 | 0 | 0 | 0 | 4e-12 | 1.000 | 1.000 | -inf | H_all |


## phi = ~(Sx=0), generator sch

Pool size (incl. Mem) 25 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.00; with the parameter: 0.00; L1 likelihood fallback counters, summed over seeds: {'closed1': 0, 'open1': 0, 'open2': 0}.

Derivability oracle (|-_1) fallback count, summed over seeds: 0 (0 = every derivability answer exact).


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0.048 | 0.023 | 3e-07 | 0.523 | 0.406 | 3e-06 | 7e-05 | 0.225 | 0.477 | inf | min0@1:~1=0, min0@1:~2=0, min0@1:~3=0 |
| 2 | 0 | 0.490 | 0.162 | 2e-06 | 0.194 | 0.130 | 0.024 | 5e-04 | 0.173 | 0.791 | inf | H_sch, min0@1:~1=0 |
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
| 1 | 0.009 | 0.047 | 0.023 | 5e-07 | 0.517 | 0.404 | 3e-06 | 7e-05 | 0.235 | 0.483 | 2.4 | min0@1:~1=0, min0@1:~2=0, min0@1:~3=0 |
| 2 | 0.043 | 0.464 | 0.154 | 4e-06 | 0.193 | 0.123 | 0.022 | 5e-04 | 0.208 | 0.792 | 3.4 | H_sch, min0@1:~1=0 |
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
| 1 | 0.032 | 0.086 | 0.055 | 1e-06 | 0.825 | 0.002 | 6e-06 | 1e-04 | 0.087 | 0.175 | 1.4 | min0@1:~1=0, min0@1:~2=0, min0@1:~3=0 |
| 2 | 0.143 | 0.387 | 0.254 | 6e-06 | 0.190 | 0.003 | 0.022 | 4e-04 | 0.397 | 0.795 | 1.4 | H_open, H_sch, min0@1:~1=0 |
| 4 | 0.190 | 0.515 | 0.294 | 8e-06 | 3e-04 | 9e-04 | 4e-06 | 4e-04 | 0.484 | 1.000 | 1.4 | H_open, H_sch |
| 8 | 0.184 | 0.501 | 0.315 | 8e-06 | 2e-13 | 4e-05 | 1e-05 | 3e-04 | 0.499 | 1.000 | 1.4 | H_open, H_sch |
| 16 | 0.212 | 0.576 | 0.211 | 9e-06 | 7e-22 | 7e-08 | 6e-05 | 2e-04 | 0.423 | 1.000 | 1.4 | H_open, H_sch |
| 32 | 0.240 | 0.651 | 0.109 | 1e-05 | 4e-45 | 2e-13 | 0 | 2e-04 | 0.349 | 1.000 | 1.4 | H_open, H_sch |
| 64 | 0.269 | 0.730 | 0.001 | 1e-05 | 9e-90 | 2e-24 | 0 | 2e-04 | 0.270 | 1.000 | 1.4 | H_sch |
| 128 | 0.269 | 0.731 | 5e-08 | 9e-06 | 5e-162 | 1e-46 | 0 | 1e-04 | 0.269 | 1.000 | 1.4 | H_sch |
| 256 | 0.269 | 0.731 | 4e-18 | 9e-06 | 7e-303 | 5e-91 | 0 | 8e-05 | 0.269 | 1.000 | 1.4 | H_sch |


## phi = ~(Sx=0), generator all

Pool size (incl. Mem) 22 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.50; with the parameter: 0.00; L1 likelihood fallback counters, summed over seeds: {'closed1': 0, 'open1': 0, 'open2': 0}.

Derivability oracle (|-_1) fallback count, summed over seeds: 0 (0 = every derivability answer exact).


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.185 | 0.028 | 0.019 | 5e-06 | 0.518 | 0.250 | 1e-06 | 4e-05 | 0.336 | 0.482 | mixed | H_all, min0@1:~1=0, min0@1:~S(3*0)=0 |
| 2 | 0.200 | 0.122 | 0.046 | 0.007 | 0.094 | 0.532 | 0 | 1e-04 | 0.849 | 1.000 | mixed | H_all, H_sch, bare?P |
| 4 | 0 | 0 | 0 | 0.420 | 0.575 | 0.004 | 0 | 8e-05 | 1.000 | 1.000 | - | H_all+sch, Mem |
| 8 | 0 | 0 | 0 | 0.996 | 0.004 | 2e-15 | 0 | 2e-04 | 1.000 | 1.000 | - | H_all+sch |
| 16 | 0 | 0 | 0 | 0.966 | 0.034 | 4e-37 | 0 | 8e-05 | 1.000 | 1.000 | - | H_all+sch |
| 32 | 0 | 0 | 0 | 1.000 | 7e-25 | 1e-81 | 0 | 4e-05 | 1.000 | 1.000 | - | H_all+sch |
| 64 | 0 | 0 | 0 | 1.000 | 6e-51 | 1e-178 | 0 | 6e-05 | 1.000 | 1.000 | - | H_all+sch |
| 128 | 0 | 0 | 0 | 1.000 | 2e-98 | 0 | 0 | 8e-05 | 1.000 | 1.000 | - | H_all+sch |
| 256 | 0 | 0 | 0 | 1.000 | 3e-174 | 0 | 0 | 2e-05 | 1.000 | 1.000 | - | H_all+sch |


**L1** (exact Dirichlet DP too large for skel4@32, skel4@64: marginal bounded; the largest posterior mass these could have at any n is 2e-15)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.144 | 0.027 | 0.068 | 4e-06 | 0.513 | 0.246 | 1e-06 | 4e-05 | 0.343 | 0.487 | mixed | H_all, min0@1:~1=0, min0@1:~S(3*0)=0 |
| 2 | 0.573 | 0.115 | 0.281 | 2e-05 | 2e-04 | 0.031 | 0 | 1e-04 | 0.857 | 1.000 | mixed | H_all, H_sch |
| 4 | 0.797 | 0 | 0.203 | 2e-05 | 1e-04 | 3e-08 | 0 | 1e-09 | 1.000 | 1.000 | -inf | H_all |
| 8 | 0.984 | 0 | 0.016 | 2e-05 | 3e-08 | 4e-21 | 0 | 1e-09 | 1.000 | 1.000 | -inf | H_all |
| 16 | 0.999 | 0 | 5e-04 | 2e-05 | 1e-07 | 9e-44 | 0 | 1e-09 | 1.000 | 1.000 | -inf | H_all |
| 32 | 1.000 | 0 | 6e-09 | 1e-05 | 3e-32 | 5e-90 | 0 | 3e-10 | 1.000 | 1.000 | -inf | H_all |
| 64 | 1.000 | 0 | 5e-22 | 1e-05 | 2e-59 | 9e-192 | 0 | 4e-10 | 1.000 | 1.000 | -inf | H_all |
| 128 | 1.000 | 0 | 8e-52 | 8e-06 | 2e-109 | 0 | 0 | 3e-10 | 1.000 | 1.000 | -inf | H_all |
| 256 | 1.000 | 0 | 1e-96 | 7e-06 | 3e-191 | 0 | 0 | 1e-10 | 1.000 | 1.000 | -inf | H_all |


## phi = ~(Sx=0), generator allq

Pool size (incl. Mem) 21 (data-derived theories left out for lack of exact L1: 0); fraction of data with explicit forall: 0.49; with the parameter: 0.16; L1 likelihood fallback counters, summed over seeds: {'closed1': 0, 'open1': 0, 'open2': 0}.

Derivability oracle (|-_1) fallback count, summed over seeds: 0 (0 = every derivability answer exact).


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.185 | 0.028 | 0.030 | 5e-06 | 0.506 | 0.250 | 8e-07 | 4e-05 | 0.348 | 0.494 | mixed | H_all, bare?P, min0@1:~1=0 |
| 2 | 0.200 | 0.138 | 0.226 | 0.004 | 0.063 | 0.369 | 0 | 2e-04 | 0.829 | 1.000 | mixed | H_all, H_open, H_sch |
| 4 | 0 | 0 | 0.200 | 0.419 | 0.381 | 3e-05 | 0 | 0 | 1.000 | 1.000 | - | H_all+open, H_all+sch, H_open |
| 8 | 0 | 0 | 0 | 1.000 | 2e-04 | 1e-19 | 0 | 0 | 1.000 | 1.000 | - | H_all+open, H_all+sch |
| 16 | 0 | 0 | 0 | 1.000 | 2e-10 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 32 | 0 | 0 | 0 | 1.000 | 2e-19 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 64 | 0 | 0 | 0 | 1.000 | 2e-45 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 128 | 0 | 0 | 0 | 1.000 | 2e-84 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |
| 256 | 0 | 0 | 0 | 1.000 | 3e-147 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_all+open |


**L1** (exact Dirichlet DP too large for skel4@16, skel4@64: marginal bounded; the largest posterior mass these could have at any n is 8e-14)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.148 | 0.028 | 0.079 | 4e-06 | 0.497 | 0.249 | 8e-07 | 4e-05 | 0.358 | 0.503 | mixed | H_all, bare?P, min0@1:~1=0 |
| 2 | 0.481 | 0.136 | 0.346 | 1e-05 | 1e-04 | 0.036 | 0 | 2e-04 | 0.831 | 1.000 | mixed | H_all, H_open, H_sch |
| 4 | 0.649 | 0 | 0.351 | 2e-05 | 9e-05 | 8e-10 | 0 | 1e-11 | 1.000 | 1.000 | -inf | H_all, H_open |
| 8 | 0.865 | 0 | 0.135 | 2e-05 | 2e-09 | 6e-23 | 0 | 8e-10 | 1.000 | 1.000 | -inf | H_all, H_open |
| 16 | 0.998 | 0 | 0.002 | 2e-05 | 1e-15 | 2e-45 | 0 | 2e-09 | 1.000 | 1.000 | -inf | H_all |
| 32 | 1.000 | 0 | 9e-08 | 2e-05 | 6e-26 | 5e-98 | 0 | 1e-09 | 1.000 | 1.000 | -inf | H_all |
| 64 | 1.000 | 0 | 1e-15 | 2e-05 | 2e-54 | 1e-202 | 0 | 7e-10 | 1.000 | 1.000 | -inf | H_all |
| 128 | 1.000 | 0 | 4e-33 | 1e-05 | 5e-97 | 0 | 0 | 2e-10 | 1.000 | 1.000 | -inf | H_all |
| 256 | 1.000 | 0 | 1e-67 | 9e-06 | 2e-167 | 0 | 0 | 1e-10 | 1.000 | 1.000 | -inf | H_all |


## phi = ~(Sx=0), generator open

Pool size (incl. Mem) 19 (data-derived theories left out for lack of exact L1: 65); fraction of data with explicit forall: 0.18; with the parameter: 0.15; L1 likelihood fallback counters, summed over seeds: {'closed1': 0, 'open1': 0, 'open2': 0}.

Derivability oracle (|-_1) fallback count, summed over seeds: 0 (0 = every derivability answer exact).


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0.022 | 0.028 | 2e-07 | 0.750 | 0.201 | 2e-06 | 3e-05 | 0.325 | 0.250 | inf | min0@1:Ax.~S(0+(0*x+2))=, min0@1:~1=0, min0@1:~2=0 |
| 2 | 0 | 0.213 | 0.530 | 3e-06 | 0.051 | 0.206 | 1e-05 | 2e-04 | 0.685 | 0.949 | inf | H_open, H_sch, bare?P |
| 4 | 0 | 0 | 0 | 0.200 | 0.408 | 0.010 | 0 | 0.382 | 0.210 | 0.594 | - | H_all+open, Mem, skel2@4 |
| 8 | 0 | 0 | 0 | 0 | 0.811 | 1e-08 | 0 | 0.189 | 0.800 | 0.789 | - | Mem, skel2@4 |
| 16 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 32 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 64 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 128 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |
| 256 | 0 | 0 | 0 | 0 | 1.000 | 0 | 0 | 0 | 1.000 | 1.000 | - | Mem |


**L1** (exact Dirichlet DP too large for Mem: marginal bounded; the largest posterior mass these could have at any n is 6e-53)


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.007 | 0.021 | 0.132 | 9e-07 | 0.647 | 0.193 | 2e-06 | 3e-05 | 0.424 | 0.353 | mixed | H_open, min0@1:~1=0, min0@1:~2=0 |
| 2 | 0.074 | 0.206 | 0.664 | 6e-06 | 5e-04 | 0.055 | 1e-05 | 2e-04 | 0.743 | 0.999 | mixed | H_open, H_sch |
| 4 | 0.083 | 0 | 0.917 | 6e-06 | 4e-08 | 2e-08 | 0 | 3e-06 | 1.000 | 1.000 | -inf | H_open |
| 8 | 0 | 0 | 1.000 | 7e-06 | 5e-09 | 9e-18 | 0 | 8e-08 | 1.000 | 1.000 | - | H_open |
| 16 | 0 | 0 | 1.000 | 1e-05 | 1e-19 | 1e-37 | 0 | 0 | 1.000 | 1.000 | - | H_open |
| 32 | 0 | 0 | 1.000 | 5e-06 | 5e-22 | 1e-79 | 0 | 0 | 1.000 | 1.000 | - | H_open |
| 64 | 0 | 0 | 1.000 | 6e-06 | 2e-66 | 2e-165 | 0 | 0 | 1.000 | 1.000 | - | H_open |
| 128 | 0 | 0 | 1.000 | 3e-06 | 4e-159 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_open |
| 256 | 0 | 0 | 1.000 | 3e-06 | 9e-289 | 0 | 0 | 0 | 1.000 | 1.000 | - | H_open |


## phi = ~(Sx=0), generator allq2

Pool size (incl. Mem) 18 (data-derived theories left out for lack of exact L1: 43); fraction of data with explicit forall: 0.59; with the parameter: 0.08; L1 likelihood fallback counters, summed over seeds: {'closed1': 0, 'open1': 0, 'open2': 0}.

Derivability oracle (|-_1) fallback count, summed over seeds: 0 (0 = every derivability answer exact).


**L0**


| n | H_all | H_sch | H_open | H_all+sch | Mem | over-gen | over-spec | frag/skel/spare/other | P(|-forall) | P(|-inst) | lo sch:all | MAP |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.200 | 0.039 | 0.034 | 5e-06 | 0.563 | 0.164 | 9e-07 | 6e-05 | 0.234 | 0.437 | mixed | H_all, gen0:~?G0, min0@1:~1=0 |
| 2 | 0.200 | 0.140 | 0.026 | 0.044 | 0.557 | 0.034 | 0 | 2e-04 | 0.826 | 1.000 | mixed | H_all, H_sch, Mem |
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
| 1 | 0.177 | 0.038 | 0.067 | 5e-06 | 0.555 | 0.162 | 9e-07 | 6e-05 | 0.244 | 0.445 | mixed | H_all, gen0:~?G0, min0@1:~1=0 |
| 2 | 0.639 | 0.131 | 0.198 | 2e-05 | 1e-04 | 0.032 | 0 | 1e-04 | 0.837 | 1.000 | mixed | H_all, H_sch |
| 4 | 0.840 | 0 | 0.159 | 3e-05 | 1e-04 | 0 | 0 | 1e-11 | 1.000 | 1.000 | -inf | H_all, H_open |
| 8 | 0.995 | 0 | 0.005 | 2e-05 | 9e-08 | 0 | 0 | 3e-10 | 1.000 | 1.000 | -inf | H_all |
| 16 | 1.000 | 0 | 5e-05 | 3e-05 | 8e-16 | 0 | 0 | 6e-10 | 1.000 | 1.000 | -inf | H_all |
| 32 | 1.000 | 0 | 5e-11 | 2e-05 | 2e-33 | 0 | 0 | 3e-10 | 1.000 | 1.000 | -inf | H_all |
| 64 | 1.000 | 0 | 2e-24 | 2e-05 | 6e-67 | 0 | 0 | 1e-10 | 1.000 | 1.000 | -inf | H_all |
| 128 | 1.000 | 0 | 1e-55 | 1e-05 | 1e-119 | 0 | 0 | 6e-11 | 1.000 | 1.000 | -inf | H_all |
| 256 | 1.000 | 0 | 3e-116 | 8e-06 | 5e-217 | 0 | 0 | 3e-11 | 1.000 | 1.000 | -inf | H_all |

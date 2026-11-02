# DFG alone against v3's DFG member (Part 10), seed 0, same (target, n)

Cells: the (target, n) cells of Part 10's v3 structure runs (part10/interp/results/toy_final/v3/; those runs stop after two consecutive n with portfolio error <= 0.005, so they rarely reach n >= 4096). 'v3 member': the DFG model Part 10 summarised (the final DFG member; the forced variant when the stacker kept both; the last out-of-fold fit when it kept neither). Top-term Jaccard: overlap of the character and block terms among the terms Part 10 stored (its top 10) and as many of DFG alone's leading terms.

| target | cells | same DFG test error | alone lower | v3 member lower | mean top-term Jaccard | n_struct (Part 10 rule) alone / v3 (v3's largest analysed n) |
|---|---|---|---|---|---|---|
| par2 | 2 | 2 | 0 | 0 | 1.00 | – / – (32) |
| par4 | 4 | 2 | 2 | 0 | 0.50 | – / – (128) |
| par5 | 5 | 3 | 0 | 2 | 0.60 | – / – (256) |
| stair5 | 5 | 3 | 1 | 1 | 0.60 | – / – (256) |
| stair6 | 6 | 4 | 0 | 2 | 0.67 | – / – (512) |
| mux6 | 6 | 3 | 1 | 2 | 0.69 | – / – (512) |
| mux11 | 8 | 4 | 3 | 1 | 0.64 | – / – (2048) |
| maj9 | 5 | 2 | 3 | 0 | 0.40 | 128 / 128 (256) |
| thrint | 7 | 4 | 3 | 0 | 0.79 | 512 / 512 (1024) |
| thr30 | 11 | 7 | 4 | 0 | 0.78 | – / – (16384) |
| f7_01 | 6 | 3 | 1 | 2 | 0.61 | 256 / 256 (512) |
| majpar | 6 | 5 | 0 | 1 | 0.83 | – / – (512) |
| majpar5 | 7 | 3 | 1 | 3 | 0.49 | – / – (1024) |
| parmaj | 5 | 2 | 3 | 0 | 0.40 | – / – (256) |
| majxor | 8 | 3 | 4 | 1 | 0.62 | – / – (2048) |
| majmaj5 | 8 | 3 | 5 | 0 | 0.53 | 2048 / – (2048) |
| andxor | 5 | 3 | 1 | 1 | 0.60 | – / – (256) |
| cnf3 | 6 | 2 | 4 | 0 | 0.44 | 4096 / – (512) |
| f7_02 | 7 | 4 | 3 | 0 | 0.57 | – / – (1024) |
| dlist8 | 8 | 6 | 1 | 1 | 0.78 | – / – (2048) |
| f7_04 | 8 | 6 | 2 | 0 | 0.75 | 2048 / 2048 (2048) |
| f7_06 | 6 | 3 | 1 | 2 | 0.60 | 256 / 256 (512) |
| rf06 | 5 | 3 | 1 | 1 | 0.67 | 512 / – (256) |
| hrf0 | 6 | 3 | 0 | 3 | 0.64 | 4096 / – (512) |
| sym9 | 5 | 2 | 3 | 0 | 0.40 | 128 / 128 (256) |
| band11 | 8 | 4 | 2 | 2 | 0.38 | 1024 / 1024 (2048) |
| f7_08 | 10 | 6 | 3 | 1 | 0.60 | 512 / 512 (8192) |
| h5s7 | 11 | 4 | 5 | 2 | 0.36 | 8192 / 8192 (16384) |
| f7_05 | 11 | 7 | 2 | 2 | 0.64 | – / – (16384) |
| h6_00 | 11 | 4 | 4 | 3 | 0.55 | – / – (16384) |
| f7_07 | 8 | 4 | 2 | 2 | 0.56 | 256 / 256 (2048) |
| f7_09 | 6 | 4 | 1 | 1 | 0.83 | 256 / 256 (512) |
| symand | 7 | 6 | 0 | 1 | 0.90 | 256 / 256 (1024) |
| f7_10 | 5 | 3 | 1 | 1 | 0.65 | 128 / 128 (256) |
| f7_00 | 6 | 3 | 1 | 2 | 0.50 | 256 / 256 (512) |
| f7_03 | 8 | 5 | 2 | 1 | 0.83 | 512 / 512 (2048) |
| f7_11 | 9 | 6 | 2 | 1 | 0.73 | – / – (4096) |

# Searching for a short surrogate g of a trained Boolean network f

n = 50, m = 16000 uniform training inputs, one network per row. Each search family's best candidate (chosen on a 30k selection pool) is certified on 2x10^5 fresh inputs; `bound` is Theorem 2 with the design charge of accounting.py. `A` is the D_X path norm sum_i ||a_i|| ||phi_i||, `A_upd` the same for the update relative to the initialization, `N_eff` = A^2 / sum_i s_i^2 the effective number of units, `|f| med` the median |logit|. Families: `codec` = influence codec; `scratch` = distill from scratch; `sub_refit` = subsample+refit; `sub_refit_init` = subsample+refit (init-rel.); `greedy_refit` = greedy+refit; `greedy_refit_init` = greedy+refit (init-rel.); `update_refit` = subsample update; `sub_distill` = subsample+distill; `greedy_distill` = greedy+distill.

## Networks

| task | net | width | depth | seed | test err f | move | A | A_upd | N_eff | abs f median |
|---|---|---|---|---|---|---|---|---|---|---|
| parity3 | std | 512 | 1 | 0 | 0.0000 | 1.02 | 25.8 | 23.5 | 42 | 4.71 |
| parity3 | std | 4096 | 1 | 0 | 0.0000 | 0.48 | 30.1 | 28.4 | 140 | 4.93 |
| parity3 | lazy | 512 | 1 | 0 | 0.0000 | 0.41 | 58.1 | 59.6 | 32 | 4.84 |
| parity3 | mf | 512 | 1 | 0 | 0.0000 | 6.63 | 18.0 | 17.7 | 12 | 4.69 |
| parity3 | mf | 4096 | 1 | 0 | 0.0000 | 6.77 | 18.7 | 18.5 | 23 | 5.11 |
| junta6 | std | 512 | 1 | 0 | 0.0000 | 1.27 | 53.5 | 51.0 | 204 | 5.35 |
| teacher4 | std | 512 | 1 | 0 | 0.0408 | 1.41 | 90.6 | 87.8 | 340 | 14.65 |
| teacher4 | std | 4096 | 1 | 0 | 0.0517 | 0.81 | 140.9 | 135.0 | 1873 | 17.95 |
| teacher4 | lazy | 512 | 1 | 0 | 0.0422 | 0.52 | 139.3 | 136.4 | 93 | 15.06 |
| teacher4 | mf | 512 | 1 | 0 | 0.0221 | 12.98 | 97.8 | 97.5 | 184 | 20.78 |
| teacher4 | mf | 4096 | 1 | 0 | 0.0214 | 12.84 | 96.4 | 96.1 | 1316 | 20.31 |
| teacher8 | std | 512 | 1 | 0 | 0.0557 | 1.53 | 113.8 | 111.1 | 418 | 13.85 |
| teacher8 | std | 4096 | 1 | 0 | 0.0624 | 0.80 | 153.4 | 146.9 | 2440 | 15.03 |
| teacher8 | lazy | 512 | 1 | 0 | 0.0683 | 0.56 | 161.7 | 159.6 | 251 | 12.28 |
| teacher8 | mf | 512 | 1 | 0 | 0.0344 | 13.13 | 99.1 | 98.8 | 201 | 16.01 |
| teacher8 | mf | 4096 | 1 | 0 | 0.0340 | 12.74 | 94.2 | 93.9 | 1453 | 15.14 |

## Certified bound on err(f) per search family (bits of g in parentheses)

| task | net | width | depth | seed | test err f | influence codec | distill from scratch | subsample+refit | subsample+refit (init-rel.) | subsample update | subsample+distill | best search | oracle: the true teacher |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| parity3 | std | 512 | 1 | 0 | 0.0000 | 0.002 (31) | 0.014 (323) | 0.016 (363) | 0.048 (1026) | 0.072 (1517) | 0.015 (335) | 0.002 | - |
| parity3 | std | 4096 | 1 | 0 | 0.0000 | 0.002 (31) | 0.015 (350) | 0.022 (493) | 0.080 (1907) | 0.142 (3470) | 0.024 (554) | 0.002 | - |
| parity3 | lazy | 512 | 1 | 0 | 0.0000 | 0.002 (31) | 0.018 (401) | 0.010 (216) | 0.041 (939) | 0.071 (1568) | 0.010 (218) | 0.002 | - |
| parity3 | mf | 512 | 1 | 0 | 0.0000 | 0.002 (31) | 0.016 (363) | 0.009 (207) | 0.015 (343) | 0.021 (469) | 0.010 (212) | 0.002 | - |
| parity3 | mf | 4096 | 1 | 0 | 0.0000 | 0.002 (31) | 0.016 (358) | 0.016 (366) | 0.023 (496) | 0.032 (739) | 0.017 (389) | 0.002 | - |
| junta6 | std | 512 | 1 | 0 | 0.0000 | 0.005 (98) | 0.044 (1032) | 0.213 (5531) | 0.263 (6063) | 0.284 (5746) | 0.101 (2458) | 0.005 | - |
| teacher4 | std | 512 | 1 | 0 | 0.0408 | 0.200 (1427) | 0.217 (1961) | 0.314 (1803) | 0.327 (1548) | 0.369 (3839) | 0.213 (1805) | 0.200 | - |
| teacher4 | std | 4096 | 1 | 0 | 0.0517 | 0.226 (1412) | 0.224 (1920) | 0.435 (2762) | 0.413 (2812) | 0.469 (5753) | 0.167 (1007) | 0.167 | - |
| teacher4 | lazy | 512 | 1 | 0 | 0.0422 | 0.214 (1419) | 0.225 (1947) | 0.262 (979) | 0.276 (1039) | 0.407 (4316) | 0.153 (977) | 0.153 | - |
| teacher4 | mf | 512 | 1 | 0 | 0.0221 | 0.199 (1847) | 0.198 (2625) | 0.281 (3500) | 0.278 (1972) | 0.259 (2803) | 0.250 (3503) | 0.198 | - |
| teacher4 | mf | 4096 | 1 | 0 | 0.0214 | 0.184 (1446) | 0.202 (2627) | 0.218 (973) | 0.215 (1071) | 0.250 (1107) | 0.195 (973) | 0.184 | - |
| teacher8 | std | 512 | 1 | 0 | 0.0557 | 0.258 (1377) | 0.271 (1927) | 0.475 (5409) | 0.495 (2836) | 0.504 (3854) | 0.305 (2775) | 0.258 | - |
| teacher8 | std | 4096 | 1 | 0 | 0.0624 | 0.285 (1705) | 0.268 (1907) | 0.470 (2688) | 0.498 (3842) | 0.677 (11089) | 0.277 (2625) | 0.268 | - |
| teacher8 | lazy | 512 | 1 | 0 | 0.0683 | 0.295 (1751) | 0.283 (1892) | 0.554 (5179) | 0.569 (5404) | 0.692 (9632) | 0.340 (2733) | 0.283 | - |
| teacher8 | mf | 512 | 1 | 0 | 0.0344 | 0.263 (2673) | 0.254 (1952) | 0.400 (4957) | 0.403 (5165) | 0.422 (4912) | 0.407 (5306) | 0.254 | - |
| teacher8 | mf | 4096 | 1 | 0 | 0.0340 | 0.266 (2680) | 0.259 (1970) | 0.401 (5097) | 0.436 (7103) | 0.413 (5567) | 0.376 (5099) | 0.259 | - |

The oracle column codes the true teacher network (known to us, not to the search) at the best of seven step sizes, certified on its own fresh sample; it shows what a search that found the target would certify.


## Disagreement Pr[f != g] of the float surrogate after keeping k units and refitting the output layer (no quantization), on the selection pool

| task | net | width | mode | k=4 | k=16 | k=64 | k=256 | k=1024 |
|---|---|---|---|---|---|---|---|---|
| parity3 | std | 512 | maurey_norefit | 0.3733 | 0.1660 | 0.0348 | 0.0772 | - |
| parity3 | std | 512 | maurey | 0.1241 | 0.0000 | 0.0000 | 0.0000 | - |
| parity3 | std | 512 | uniform | 0.5012 | 0.4975 | 0.0000 | 0.0014 | - |
| parity3 | std | 512 | topk | 0.2483 | 0.0000 | 0.0000 | 0.0000 | - |
| parity3 | std | 512 | update | 0.3890 | 0.0000 | 0.0000 | 0.0000 | - |
| parity3 | std | 4096 | maurey_norefit | 0.4542 | 0.3898 | 0.1171 | 0.0097 | 0.0000 |
| parity3 | std | 4096 | maurey | 0.3709 | 0.2095 | 0.0000 | 0.0000 | 0.0000 |
| parity3 | std | 4096 | uniform | 0.5028 | 0.5019 | 0.3492 | 0.1887 | 0.0000 |
| parity3 | std | 4096 | topk | 0.2531 | 0.0000 | 0.0000 | 0.0000 | 0.0000 |
| parity3 | std | 4096 | update | 0.3688 | 0.2466 | 0.0000 | 0.0000 | 0.0000 |
| parity3 | lazy | 512 | maurey_norefit | 0.4965 | 0.3718 | 0.4536 | 0.0713 | - |
| parity3 | lazy | 512 | maurey | 0.4979 | 0.0862 | 0.0000 | 0.0000 | - |
| parity3 | lazy | 512 | uniform | 0.5049 | 0.4968 | 0.3267 | 0.3062 | - |
| parity3 | lazy | 512 | topk | 0.0000 | 0.0000 | 0.0000 | 0.0000 | - |
| parity3 | lazy | 512 | update | 0.4973 | 0.1096 | 0.0000 | 0.0000 | - |
| parity3 | mf | 512 | maurey_norefit | 0.2531 | 0.0883 | 0.0001 | 0.0000 | - |
| parity3 | mf | 512 | maurey | 0.2531 | 0.0000 | 0.0000 | 0.0000 | - |
| parity3 | mf | 512 | uniform | 0.3378 | 0.1057 | 0.0000 | 0.0000 | - |
| parity3 | mf | 512 | topk | 0.0000 | 0.0000 | 0.0000 | 0.0000 | - |
| parity3 | mf | 512 | update | 0.2531 | 0.0000 | 0.0000 | 0.0000 | - |
| parity3 | mf | 4096 | maurey_norefit | 0.4112 | 0.0418 | 0.0001 | 0.0000 | 0.0000 |
| parity3 | mf | 4096 | maurey | 0.1323 | 0.0000 | 0.0000 | 0.0000 | 0.0000 |
| parity3 | mf | 4096 | uniform | 0.4858 | 0.2726 | 0.1288 | 0.0000 | 0.0000 |
| parity3 | mf | 4096 | topk | 0.2489 | 0.0000 | 0.0000 | 0.0000 | 0.0000 |
| parity3 | mf | 4096 | update | 0.2114 | 0.0000 | 0.0000 | 0.0000 | 0.0000 |
| junta6 | std | 512 | maurey_norefit | 0.4451 | 0.3763 | 0.1037 | 0.0786 | - |
| junta6 | std | 512 | maurey | 0.3367 | 0.1379 | 0.0000 | 0.0000 | - |
| junta6 | std | 512 | uniform | 0.3976 | 0.2106 | 0.0353 | 0.0000 | - |
| junta6 | std | 512 | topk | 0.3429 | 0.0310 | 0.0000 | 0.0000 | - |
| junta6 | std | 512 | update | 0.3250 | 0.1121 | 0.0000 | 0.0000 | - |
| teacher4 | std | 512 | maurey_norefit | 0.4237 | 0.1885 | 0.1387 | 0.0731 | - |
| teacher4 | std | 512 | maurey | 0.2812 | 0.0673 | 0.0459 | 0.0219 | - |
| teacher4 | std | 512 | uniform | 0.2961 | 0.2183 | 0.0701 | 0.0201 | - |
| teacher4 | std | 512 | topk | 0.2166 | 0.0788 | 0.0492 | 0.0139 | - |
| teacher4 | std | 512 | update | 0.2779 | 0.1370 | 0.0447 | 0.0206 | - |
| teacher4 | std | 4096 | maurey_norefit | 0.3513 | 0.4010 | 0.1494 | 0.0755 | 0.0498 |
| teacher4 | std | 4096 | maurey | 0.3000 | 0.1919 | 0.0709 | 0.0324 | 0.0129 |
| teacher4 | std | 4096 | uniform | 0.3107 | 0.2628 | 0.0950 | 0.0414 | 0.0173 |
| teacher4 | std | 4096 | topk | 0.2208 | 0.1049 | 0.0642 | 0.0327 | 0.0096 |
| teacher4 | std | 4096 | update | 0.2922 | 0.1566 | 0.0687 | 0.0320 | 0.0123 |
| teacher4 | lazy | 512 | maurey_norefit | 0.3210 | 0.3701 | 0.1619 | 0.1510 | - |
| teacher4 | lazy | 512 | maurey | 0.2761 | 0.2637 | 0.0599 | 0.0305 | - |
| teacher4 | lazy | 512 | uniform | 0.4160 | 0.2647 | 0.1931 | 0.0729 | - |
| teacher4 | lazy | 512 | topk | 0.0860 | 0.0774 | 0.0400 | 0.0102 | - |
| teacher4 | lazy | 512 | update | 0.2944 | 0.2823 | 0.0561 | 0.0306 | - |
| teacher4 | mf | 512 | maurey_norefit | 0.2467 | 0.1088 | 0.1044 | 0.0394 | - |
| teacher4 | mf | 512 | maurey | 0.2192 | 0.0410 | 0.0214 | 0.0107 | - |
| teacher4 | mf | 512 | uniform | 0.2817 | 0.0609 | 0.0270 | 0.0103 | - |
| teacher4 | mf | 512 | topk | 0.2582 | 0.0430 | 0.0209 | 0.0035 | - |
| teacher4 | mf | 512 | update | 0.2188 | 0.0432 | 0.0216 | 0.0103 | - |
| teacher4 | mf | 4096 | maurey_norefit | 0.2690 | 0.2033 | 0.1283 | 0.0350 | 0.0139 |
| teacher4 | mf | 4096 | maurey | 0.2344 | 0.0557 | 0.0218 | 0.0103 | 0.0027 |
| teacher4 | mf | 4096 | uniform | 0.3074 | 0.1667 | 0.0285 | 0.0092 | 0.0030 |
| teacher4 | mf | 4096 | topk | 0.0593 | 0.0442 | 0.0264 | 0.0163 | 0.0044 |
| teacher4 | mf | 4096 | update | 0.2341 | 0.0554 | 0.0209 | 0.0095 | 0.0030 |
| teacher8 | std | 512 | maurey_norefit | 0.4613 | 0.2261 | 0.1435 | 0.1037 | - |
| teacher8 | std | 512 | maurey | 0.3941 | 0.1968 | 0.0705 | 0.0332 | - |
| teacher8 | std | 512 | uniform | 0.3449 | 0.1944 | 0.1148 | 0.0350 | - |
| teacher8 | std | 512 | topk | 0.3565 | 0.1352 | 0.0633 | 0.0200 | - |
| teacher8 | std | 512 | update | 0.3937 | 0.1973 | 0.0710 | 0.0338 | - |
| teacher8 | std | 4096 | maurey_norefit | 0.3867 | 0.3722 | 0.1903 | 0.1198 | 0.0561 |
| teacher8 | std | 4096 | maurey | 0.3407 | 0.2281 | 0.1145 | 0.0473 | 0.0172 |
| teacher8 | std | 4096 | uniform | 0.3379 | 0.2531 | 0.1518 | 0.0609 | 0.0210 |
| teacher8 | std | 4096 | topk | 0.2938 | 0.1289 | 0.0916 | 0.0379 | 0.0123 |
| teacher8 | std | 4096 | update | 0.3767 | 0.2076 | 0.1125 | 0.0491 | 0.0176 |
| teacher8 | lazy | 512 | maurey_norefit | 0.3978 | 0.3597 | 0.2749 | 0.1546 | - |
| teacher8 | lazy | 512 | maurey | 0.3291 | 0.2477 | 0.1334 | 0.0481 | - |
| teacher8 | lazy | 512 | uniform | 0.3878 | 0.3019 | 0.1947 | 0.0890 | - |
| teacher8 | lazy | 512 | topk | 0.3069 | 0.1913 | 0.0841 | 0.0165 | - |
| teacher8 | lazy | 512 | update | 0.3229 | 0.2402 | 0.1413 | 0.0476 | - |
| teacher8 | mf | 512 | maurey_norefit | 0.4360 | 0.2007 | 0.1288 | 0.0741 | - |
| teacher8 | mf | 512 | maurey | 0.3210 | 0.1339 | 0.0345 | 0.0159 | - |
| teacher8 | mf | 512 | uniform | 0.3389 | 0.2356 | 0.0645 | 0.0238 | - |
| teacher8 | mf | 512 | topk | 0.2620 | 0.1286 | 0.0316 | 0.0042 | - |
| teacher8 | mf | 512 | update | 0.3210 | 0.1338 | 0.0345 | 0.0157 | - |
| teacher8 | mf | 4096 | maurey_norefit | 0.5028 | 0.2128 | 0.1103 | 0.0621 | 0.0196 |
| teacher8 | mf | 4096 | maurey | 0.3390 | 0.1783 | 0.0425 | 0.0143 | 0.0051 |
| teacher8 | mf | 4096 | uniform | 0.3678 | 0.2166 | 0.0540 | 0.0189 | 0.0056 |
| teacher8 | mf | 4096 | topk | 0.2695 | 0.1083 | 0.0366 | 0.0164 | 0.0032 |
| teacher8 | mf | 4096 | update | 0.3388 | 0.1784 | 0.0411 | 0.0150 | 0.0052 |

## Compute (seconds, one CPU thread)

| task | net | width | depth | train f | codec | maurey_raw | scratch | sub_distill | sub_refit(+init) | update_refit |
|---|---|---|---|---|---|---|---|---|---|---|
| parity3 | std | 512 | 1 | 10 | 49 | 16 | 28 | 41 | 23 | 35 |
| parity3 | std | 4096 | 1 | 28 | 94 | 207 | 75 | 135 | 66 | 429 |
| parity3 | lazy | 512 | 1 | 5 | 90 | 11 | 58 | 66 | 18 | 45 |
| parity3 | mf | 512 | 1 | 3 | 49 | 11 | 27 | 41 | 15 | 34 |
| parity3 | mf | 4096 | 1 | 20 | 64 | 145 | 30 | 81 | 63 | 572 |
| junta6 | std | 512 | 1 | 6 | 165 | 15 | 71 | 72 | 27 | 58 |
| teacher4 | std | 512 | 1 | 9 | 125 | 11 | 28 | 43 | 16 | 33 |
| teacher4 | std | 4096 | 1 | 57 | 134 | 158 | 27 | 63 | 75 | 391 |
| teacher4 | lazy | 512 | 1 | 9 | 118 | 11 | 28 | 44 | 19 | 34 |
| teacher4 | mf | 512 | 1 | 13 | 119 | 11 | 29 | 42 | 16 | 38 |
| teacher4 | mf | 4096 | 1 | 84 | 133 | 159 | 28 | 71 | 78 | 381 |
| teacher8 | std | 512 | 1 | 12 | 122 | 13 | 28 | 42 | 18 | 37 |
| teacher8 | std | 4096 | 1 | 37 | 219 | 170 | 32 | 113 | 74 | 402 |
| teacher8 | lazy | 512 | 1 | 9 | 172 | 10 | 41 | 63 | 16 | 54 |
| teacher8 | mf | 512 | 1 | 11 | 119 | 11 | 27 | 42 | 16 | 35 |
| teacher8 | mf | 4096 | 1 | 49 | 228 | 163 | 41 | 108 | 74 | 408 |

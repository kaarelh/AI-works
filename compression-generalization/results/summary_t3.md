# Training-data-only bounds on the original network (Theorem 5 + Lemma 7)

One-hidden-layer MLPs trained with Adam (20 epochs, batch 128). Dithered compression; delta = 0.04, delta' = 0.01; t1, t2 and eta/delta' per row. `T3 bound` uses only the 60k training examples: no validation set and no unlabeled data. `cert` = fraction of training points certified. `test err g` is the dithered network's test error (for reference).

| data | hidden | weight noise | init | code ref | basis | params | train err f | test err f | bits | cert | T3 bound on f | t1, t2 | eta/delta' | float32 Occam | test err g |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| fashion | 16 | 0.0 | random | init | dct | 12730 | 0.1174 | 0.1407 | 43028 | 0.8261 | 0.6586 | 5.8, 3.9 | 6.0e-04 | 1.00 | 0.1402 |
| fashion | 32 | 0.0 | random | init | dct | 25450 | 0.1014 | 0.1305 | 76996 | 0.8311 | 0.7925 | 5.8, 3.9 | 7.6e-04 | 1.00 | 0.1314 |
| fashion | 64 | 0.0 | random | init | dct | 50890 | 0.0908 | 0.1245 | 149235 | 0.8331 | 0.9264 | 5.8, 3.9 | 1.1e-03 | 1.00 | 0.1247 |
| fashion | 32 | 1.0 | random | init | dct | 25450 | 0.1024 | 0.1305 | 78902 | 0.8108 | 0.8132 | 5.8, 3.9 | 7.6e-04 | 1.00 | 0.1295 |
| mnist | 8 | 0.0 | random | init | dct | 6370 | 0.0625 | 0.0697 | 23486 | 0.8971 | 0.4392 | 5.8, 3.9 | 5.3e-04 | 0.94 | 0.0707 |
| mnist | 16 | 0.0 | random | init | dct | 12730 | 0.0419 | 0.0512 | 43654 | 0.9188 | 0.5526 | 5.8, 3.9 | 6.0e-04 | 0.99 | 0.0519 |
| mnist | 32 | 0.0 | dct | init | dct | 25450 | 0.0208 | 0.0331 | 67165 | 0.9026 | 0.6915 | 5.8, 3.9 | 7.6e-04 | 1.00 | 0.0335 |
| mnist | 32 | 0.0 | random | init | dct | 25450 | 0.0170 | 0.0323 | 83972 | 0.9491 | 0.7041 | 5.8, 3.9 | 7.6e-04 | 1.00 | 0.0331 |
| mnist | 32 | 0.0 | random | init | id | 25450 | 0.0170 | 0.0323 | 114695 | 0.9410 | 0.8054 | 5.8, 3.9 | 7.6e-04 | 1.00 | 0.0334 |
| mnist | 32 | 0.0 | random | zero | dct | 25450 | 0.0170 | 0.0323 | 84265 | 0.9504 | 0.7036 | 5.8, 3.9 | 7.6e-04 | 1.00 | 0.0325 |
| mnist | 64 | 0.0 | random | init | dct | 50890 | 0.0052 | 0.0250 | 157047 | 0.9638 | 0.8709 | 5.8, 3.9 | 1.1e-03 | 1.00 | 0.0247 |
| mnist | 128 | 0.0 | random | init | dct | 101770 | 0.0015 | 0.0213 | 223588 | 0.8626 | 0.9701 | 5.8, 3.9 | 1.7e-03 | 1.00 | 0.0225 |
| mnist | 16 | 1.0 | random | init | dct | 12730 | 0.0375 | 0.0473 | 51747 | 0.9379 | 0.5726 | 5.8, 3.9 | 6.0e-04 | 0.99 | 0.0472 |
| mnist | 32 | 1.0 | random | init | dct | 25450 | 0.0166 | 0.0320 | 81277 | 0.9375 | 0.7079 | 5.8, 3.9 | 7.6e-04 | 1.00 | 0.0320 |
| mnist | 64 | 1.0 | random | init | dct | 50890 | 0.0038 | 0.0218 | 147532 | 0.9595 | 0.8583 | 5.8, 3.9 | 1.1e-03 | 1.00 | 0.0231 |
| mnist | 100 | 1.0 | random | init | dct | 79510 | 0.0017 | 0.0210 | 221478 | 0.9705 | 0.9389 | 5.8, 3.9 | 1.4e-03 | 1.00 | 0.0213 |
| mnist | 32 | 2.0 | random | init | dct | 25450 | 0.0183 | 0.0319 | 75302 | 0.9318 | 0.6915 | 5.8, 3.9 | 7.6e-04 | 1.00 | 0.0321 |
| mnist | 100 | 2.0 | random | init | dct | 79510 | 0.0037 | 0.0199 | 212868 | 0.9692 | 0.9327 | 5.8, 3.9 | 1.4e-03 | 1.00 | 0.0200 |

## Networks with an exactly sparse first-layer update (trained, pruned in the DCT basis, fine-tuned)

`exact code` = Occam bound for coding the sparse network exactly (same support code, 32 bits per stored parameter).

| data | hidden | kept coefficients | train err f | test err f | bits | cert | T3 bound on f | exact code bits | exact code bound |
|---|---|---|---|---|---|---|---|---|---|
| mnist | 100 | 3.0% | 0.0267 | 0.0333 | 32451 | 0.9629 | 0.4065 | 124318 | 0.7972 |
| mnist | 100 | 1.0% | 0.0440 | 0.0462 | 17660 | 0.9445 | 0.3139 | 65754 | 0.6175 |
| mnist | 100 | 0.3% | 0.0770 | 0.0722 | 11419 | 0.9094 | 0.3038 | 44864 | 0.5535 |
| mnist | 256 | 0.3% | 0.0456 | 0.0441 | 23240 | 0.9244 | 0.3992 | 114452 | 0.7916 |
| mnist | 256 | 0.1% | 0.0678 | 0.0647 | 21669 | 0.9164 | 0.3977 | 98696 | 0.7701 |
| fashion | 100 | 1.0% | 0.1549 | 0.1693 | 20172 | 0.8278 | 0.5009 | 66862 | 0.7460 |
| fashion | 100 | 0.3% | 0.1840 | 0.1926 | 13166 | 0.7983 | 0.4675 | 45307 | 0.6800 |

## Boolean tasks: training-data-only bound (valid for any input distribution) vs known-distribution bound

| task | n | m | width | weight noise | test err f | T3 bits | cert | T3 bound (any D) | Thm-2 bound (uniform D known) | Thm-2 bits |
|---|---|---|---|---|---|---|---|---|---|---|
| maj5 | 20 | 4000 | 16 | 0.0 | 0.0000 | 1525 | 1.0000 | 0.2336 | 0.0073 | 34 |
| maj5 | 20 | 16000 | 16 | 0.0 | 0.0000 | 1519 | 1.0000 | 0.0643 | 0.0018 | 34 |
| parity3 | 20 | 16000 | 16 | 0.0 | 0.0000 | 2005 | 1.0000 | 0.0838 | 0.0015 | 27 |
| and3 | 50 | 16000 | 16 | 0.0 | 0.0000 | 3787 | 1.0000 | 0.1518 | 0.0016 | 28 |
| fullmaj | 50 | 16000 | 16 | 0.0 | 0.0000 | 3625 | 0.9991 | 0.1507 | 0.0023 | 44 |
| junta6 | 50 | 16000 | 32 | 0.0 | 0.0000 | 9128 | 1.0000 | 0.3272 | 0.0047 | 98 |
| maj5 | 50 | 16000 | 16 | 0.0 | 0.0000 | 2585 | 0.9994 | 0.1099 | 0.0022 | 41 |
| maj5 | 50 | 16000 | 16 | 1.0 | 0.0000 | 2327 | 0.9996 | 0.0989 | 0.0022 | 41 |
| maj5 | 50 | 16000 | 32 | 0.0 | 0.0000 | 5464 | 0.9997 | 0.2133 | 0.0022 | 41 |
| parity3 | 50 | 16000 | 32 | 0.0 | 0.0000 | 7109 | 0.9999 | 0.2661 | 0.0018 | 31 |

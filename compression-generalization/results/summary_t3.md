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

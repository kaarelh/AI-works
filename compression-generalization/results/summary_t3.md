# Training-data-only bounds on the original network (Theorem 5 + Lemma 7)

One-hidden-layer MLPs trained with Adam (20 epochs, batch 128). Dithered compression; delta = 0.04, delta' = 0.01; t1, t2 and eta/delta' per row. `T3 bound` uses only the 60k training examples: no validation set and no unlabeled data. `cert` = fraction of training points certified. `test err g` is the dithered network's test error (for reference).

| data | hidden | weight noise | init | code ref | basis | params | train err f | test err f | bits | cert | T3 bound on f | t1, t2 | eta/delta' | float32 Occam | test err g |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| fashion | 16 | 0.0 | random | init | dct | 12730 | 0.1174 | 0.1407 | 43075 | 0.8256 | 0.6594 | 5.8, 3.9 | 6.0e-04 | 1.00 | 0.1418 |
| fashion | 32 | 0.0 | random | init | dct | 25450 | 0.1014 | 0.1305 | 77833 | 0.8325 | 0.7940 | 5.8, 3.9 | 7.6e-04 | 1.00 | 0.1306 |
| fashion | 64 | 0.0 | random | init | dct | 50890 | 0.0908 | 0.1245 | 151251 | 0.8344 | 0.9281 | 5.8, 3.9 | 1.1e-03 | 1.00 | 0.1247 |
| fashion | 32 | 1.0 | random | init | dct | 25450 | 0.1024 | 0.1305 | 79720 | 0.8107 | 0.8156 | 5.8, 3.9 | 7.6e-04 | 1.00 | 0.1299 |
| mnist | 8 | 0.0 | random | init | dct | 6370 | 0.0625 | 0.0697 | 23541 | 0.8969 | 0.4400 | 5.8, 3.9 | 5.3e-04 | 0.94 | 0.0696 |
| mnist | 16 | 0.0 | random | init | dct | 12730 | 0.0419 | 0.0512 | 43638 | 0.9185 | 0.5529 | 5.8, 3.9 | 6.0e-04 | 0.99 | 0.0511 |
| mnist | 32 | 0.0 | dct | init | dct | 25450 | 0.0208 | 0.0331 | 64918 | 0.8935 | 0.6919 | 5.8, 3.9 | 7.6e-04 | 1.00 | 0.0329 |
| mnist | 32 | 0.0 | random | init | dct | 25450 | 0.0170 | 0.0323 | 84102 | 0.9501 | 0.7034 | 5.8, 3.9 | 7.6e-04 | 1.00 | 0.0332 |
| mnist | 32 | 0.0 | random | init | id | 25450 | 0.0170 | 0.0323 | 114679 | 0.9402 | 0.8061 | 5.8, 3.9 | 7.6e-04 | 1.00 | 0.0323 |
| mnist | 32 | 0.0 | random | zero | dct | 25450 | 0.0170 | 0.0323 | 84314 | 0.9508 | 0.7033 | 5.8, 3.9 | 7.6e-04 | 1.00 | 0.0329 |
| mnist | 64 | 0.0 | random | init | dct | 50890 | 0.0052 | 0.0250 | 158071 | 0.9657 | 0.8712 | 5.8, 3.9 | 1.1e-03 | 1.00 | 0.0250 |
| mnist | 128 | 0.0 | random | init | dct | 101770 | 0.0015 | 0.0213 | 227391 | 0.8696 | 0.9703 | 5.8, 3.9 | 1.7e-03 | 1.00 | 0.0214 |
| mnist | 16 | 1.0 | random | init | dct | 12730 | 0.0375 | 0.0473 | 52423 | 0.9387 | 0.5751 | 5.8, 3.9 | 6.0e-04 | 0.99 | 0.0462 |
| mnist | 32 | 1.0 | random | init | dct | 25450 | 0.0166 | 0.0320 | 79208 | 0.9295 | 0.7092 | 5.8, 3.9 | 7.6e-04 | 1.00 | 0.0319 |
| mnist | 64 | 1.0 | random | init | dct | 50890 | 0.0038 | 0.0218 | 148970 | 0.9607 | 0.8599 | 5.8, 3.9 | 1.1e-03 | 1.00 | 0.0227 |
| mnist | 100 | 1.0 | random | init | dct | 79510 | 0.0017 | 0.0210 | 224044 | 0.9712 | 0.9405 | 5.8, 3.9 | 1.4e-03 | 1.00 | 0.0209 |
| mnist | 32 | 2.0 | random | init | dct | 25450 | 0.0183 | 0.0319 | 75985 | 0.9322 | 0.6938 | 5.8, 3.9 | 7.6e-04 | 1.00 | 0.0316 |
| mnist | 100 | 2.0 | random | init | dct | 79510 | 0.0037 | 0.0199 | 215247 | 0.9697 | 0.9344 | 5.8, 3.9 | 1.4e-03 | 1.00 | 0.0199 |

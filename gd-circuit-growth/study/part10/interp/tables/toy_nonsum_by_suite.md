### Non-sum suites, by suite (v3, seed 0, at each target's largest analysed n)

| suite | targets | err_last_le_005 | chi90 | no_fourier | median_chi_frac | span95 | block_lead | block_targets | with_class |
|---|---|---|---|---|---|---|---|---|---|
| designed | 21 | 21 | 10 | 0 | 0.88 | 19 | 6 | dnf3, maj9, parmaj, rand0, rand2, rand3 | and3 (3: 128), dnf3 (3+3+3: –), maj3 (3: –), maj9 (9: 128), mux (3: 256), par3 (3: –), par4 (4: –), parmaj (3+3: –), rand0 (3: –), rand2 (4: 128), rand3 (3: 256), rmaj9 (3+3+3: 512), sparsepoly (3: 1024) |
| dlheld3 | 10 | 10 | 3 | 0 | 0.78 | 8 | 3 | cnf3, par3or, sym9 | cnf3 (3+3+3: –), h3rf0 (3: –), par3or (3: 128), poly4 (3+4: –), sym9 (9: 128), thrint (6: 512) |
| dlheld2 | 7 | 7 | 1 | 2 | 0.77 | 5 | 2 | maj21, sym8 | h2rf0 (3: 512), h2rf1 (3: –), maj21 (21: 128), sym8 (8: 64), xmaj (3: –) |
| dlheld | 12 | 12 | 2 | 1 | 0.78 | 6 | 5 | hrf0, hrf2, maj15, majmaj5, majxor | hrf0 (3: –), hrf2 (4: 128), maj15 (15: 128), majmaj5 (5+5+5: –), majxor (5+5: –), par5 (5: –), thr30 (3: –) |

err_last_le_005: test error <= 0.005 at n_max; chi90: targets whose model's characters carry >= 90% of the non-constant Fourier weight; no_fourier: more than 16 relevant inputs (no exact Fourier table); span95: span R^2 >= 0.95; block_lead: a sum block among the three leading terms; with_class: targets with a signed-symmetry class of size >= 3 (class sizes: n_struct).

### Where v3's models use a weighted block u = t + a*tau (seed 0; first n with one among the terms of share >= 20% of the largest)

| suite | target | kind | mixture | n_first | block | tau_where | share_rel | cells_with_weighted | cells | err_dfg | exact_here |
|---|---|---|---|---|---|---|---|---|---|---|---|
| dlsymdev | symxpar | band | parity | 256 | (-x1-x2-x3-x4-x5-x6+3*x8x7) | other relevant input | 1.00 | 1 | 5 | 0.00 | yes |
| dlfamdev | fd_00 | control | control | 256 | (x3+x5+3*AND(-x2,x4)) | other relevant input | 1.00 | 2 | 6 | 0.03 | no |
| dlfamdev | fd_03 | control | control | 128 | (-x1-x2+3*AND(x3,-x6)) | other relevant input | 1.00 | 3 | 6 | 0.02 | no |
| dlfamdev | fd_07 | control | control | 128 | (x2+x3-x5+3*AND(-x8,x1)) | other relevant input | 1.00 | 2 | 6 | 0.08 | yes |
| dlheld7 | f7_03 | modular+band | mux | 512 | (x1+x2+x3+x4+x5+x6+3*x11) | other relevant input | 0.73 | 2 | 8 | 0.0076 | yes |
| dlheld7 | f7_04 | control | control | 256 | (x4-x8-2*AND(-x9,-x6)) | other relevant input | 0.84 | 4 | 8 | 0.02 | no |
| dlheld7 | f7_06 | control | control | 512 | (x6-x7+3*x8) | other relevant input | 0.43 | 1 | 6 | 0.00 | yes |
| dlheld7 | f7_07 | interval | parity | 256 | (-x1+x2-x3+x4+x5+x6+x7+x8-x9+x10-x11+x12+3*x13) | other relevant input | 0.45 | 4 | 8 | 0.0056 | yes |
| dlheld7 | f7_10 | threshold | weighted | 256 | (x1+x2+x3+x4+x5+2*x6) | other relevant input | 1.00 | 1 | 5 | 0.00 | yes |
| dlheld6 | h6_03 | control | control | 512 | (-x2-x6+2*AND(-x4,x5)) | other relevant input | 0.34 | 1 | 6 | 0.00 | no |
| dlheld6 | h6_04 | control | control | 256 | (x1+x2-3*AND(x4,-x3)) | other relevant input | 0.40 | 3 | 7 | 0.03 | no |
| dlheld6 | h6_05 | control | control | 512 | (x6-x8+3*AND(x4,x2)) | in a class | 0.24 | 3 | 8 | 0.0054 | no |
| dlheld6 | h6_06 | arbitrary | parity | 512 | (x1+x2+x3+x4+x5+x6+x8+2*x7) | other relevant input | 1.00 | 3 | 9 | 0.0090 | no |
| dlheld6 | h6_07 | arbitrary+threshold | mux | 512 | (x7+x8+x9-x10-3*x11) | other relevant input | 0.83 | 2 | 7 | 0.00 | yes |
| dlheld6 | h6_08 | band+modular | mux | 1024 | (x5+x6-x7+x8-x9+x10-3*x11) | other relevant input | 1.00 | 2 | 8 | 0.0027 | yes |
| dlheld6 | h6_09 | interval+interval | two sums | 1024 | (x1+x2+x3+x4+x5+x6+3*AND(x9,-x10)) | in a class | 0.34 | 3 | 9 | 0.0059 | no |
| dlheld6 | h6_10 | band | weighted | 256 | \|x1+x2+x3+x4+x5+x6+x7+x8+x9+x10+x11+x12+3*x13\| | other relevant input | 1.00 | 3 | 7 | 0.02 | yes |
| dlheld5 | h5rf0 | control | control | 256 | (-x14-x18+x24+x26+3*AND(x6,-x3)) | other relevant input | 0.27 | 2 | 7 | 0.12 | no |
| dlheld5 | h5s4 | arbitrary | gate | 256 | (x1+x2+x3-x4-x5+3*x6) | other relevant input | 0.76 | 2 | 6 | 0.00 | yes |
| dlheld5 | h5s7 | arbitrary | pure | 16384 | (x1+x2-x3-x5-x6+x7-x8-x9+x10-x12+x13+3*x11) | in a class | 0.47 | 1 | 11 | 0.0005 | yes |
| dlheld5 | h5t0 | threshold | weighted | 512 | (-x1+x2+x3+x4+x5-x6+x7+2*x9x8) | other relevant input | 0.45 | 1 | 6 | 0.00 | yes |
| dlheld5 | h5t1 | threshold | weighted | 512 | (x1-x2+x3-x4+x5+3*x6x7) x \|-x6+x7\| | other relevant input | 0.61 | 1 | 6 | 0.00 | yes |
| dlheld4 | h4rf1 | control | control | 256 | (x1-x3-x5+x6-2*AND(x2,-x7)) | other relevant input | 0.44 | 2 | 6 | 0.00 | no |
| dlheld4 | majsym | band | gate | 1024 | (x1+x2+x3+x4+x5+x8+2*x6x7) | other relevant input | 0.40 | 1 | 7 | 0.00 | yes |
| dlheld4 | symand | band | gate | 256 | (x1+x2+x3+x4+x5+x6+3*AND(-x8,-x7)) | other relevant input | 1.00 | 3 | 7 | 0.01 | yes |
| dlheld4 | symxor | band | parity | 512 | (x1+x2+x3+x4+x5+x6+x7-2*x8) | other relevant input | 1.00 | 2 | 8 | 0.0059 | yes |
| designed | majpar | – | – | 512 | (x1+x2+x3+x4-3*x6x5) | other relevant input | 0.39 | 1 | 6 | 0.00 | no |
| designed | mux | – | – | 256 | (x1+x2+x3+3*x4) | other relevant input | 0.23 | 1 | 5 | 0.00 | yes |
| designed | thr10 | – | – | 512 | (x1-x2+x3+x6+x7+2*x10) | other relevant input | 0.85 | 2 | 9 | 0.03 | no |
| dlheld3 | cnf3 | – | – | 256 | (-x4+x5+x6-3*AND(-x2,-x1)) | in a class | 1.00 | 2 | 6 | 0.0042 | no |
| dlheld3 | dlist8 | – | – | 256 | (x18-x29+3*x1) x (x1-x2+x3-x4) | other relevant input | 0.52 | 4 | 8 | 0.03 | no |
| dlheld3 | h3rf1 | – | – | 256 | (x2-x4+3*AND(-x6,x5)) | other relevant input | 0.28 | 3 | 8 | 0.04 | no |
| dlheld2 | h2rf0 | – | – | 128 | (-x5+x7-2*x1) | other relevant input | 1.00 | 2 | 8 | 0.05 | no |
| dlheld2 | h2rf1 | – | – | 512 | (-x2-x7+3*x6) | other relevant input | 0.21 | 1 | 6 | 0.00 | no |
| dlheld2 | thr20 | – | – | 512 | (-x1+x2-x3+x7-x8-x9-x11-x12-x13-x15+x20+2*x6) | other relevant input | 0.41 | 4 | 11 | 0.03 | no |

tau_where: tau's inputs lie in a true symmetry class, are other relevant inputs (a parity partner, a mux selector, a gate literal or the true inner term), or are irrelevant; cells_with_weighted: analysed n whose model has any weighted block (of cells).

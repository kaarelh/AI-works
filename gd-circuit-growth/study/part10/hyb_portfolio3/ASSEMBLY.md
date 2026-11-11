# hyb_portfolio3 (v3): assembly

Image component: `p10_codes`; toy component: `p10_sum` (DFG v1.3).

- `learner.py` md5 `b045fafe1e24418620bf8c503aa601c6`
- `dfg13.py` md5 `69cabe5c50345cb24079198ed52b562f` (= p10_sum/dfg13.py)

Identity checks (development data; predictions on the test inputs):

- toy: designed/parmaj n = 64: identical
- toy: designed/parmaj n = 256: identical
- toy: designed/parmaj n = 1024: identical
- toy: dlsymdev/sym7 n = 64: identical
- toy: dlsymdev/sym7 n = 256: identical
- toy: dlsymdev/sym7 n = 1024: identical
- toy: dlfamdev/fd_09 n = 64: identical
- toy: dlfamdev/fd_09 n = 256: identical
- toy: dlfamdev/fd_09 n = 1024: identical
- toy: dlfamdev/fd_06 n = 64: identical
- toy: dlfamdev/fd_06 n = 256: identical
- toy: dlfamdev/fd_06 n = 1024: identical
- image (v3 vs p10_codes): qd_dev n = 300: identical
- tabular without DFG (v3 vs v2): optdigits n = 300: identical
- tabular with DFG (v3 vs p10_sum): kr_vs_kp n = 300: identical

All identical: **True**.

Independent checks for the mathematical review of Paper 2 (paper-steeper), written from the paper's own
definitions, not from the track scripts. Run each with `python3 -I <script>`; outputs are saved as .out.

v1_teacher.py       Section 4 + App C: Hanni's arithmetic, L_S (exact big-int binomial), G1=H(p) crossover,
                    windows c_hi (closed form and bisection), identification table (g optimised),
                    memoriser band, m=24, full table d=20 (window and lambda=2/105 table), finite-sample table,
                    concentration exponent and eps', Version 1 (c_hi for kappa=0..30, ell/I/u bounds,
                    finite-sample impossibility, d=13 instance).
v2_limits.py        Section 5 + App D: Prop limits:plain numbers, schedules, rate-blindness margins,
                    d0(kappa) table, envelope c_env/shares/e1 (general formula), guard erosion, non-identifiability,
                    crossovers p<0.1233 and p<0.1525. NOTE: c_env at kappa=10,30 differs from the paper only because
                    this script omits the kappa inside k1=K(S1|m)<=2log(j+1)+kappa; with it the paper's values
                    (denominator 73+3kappa) are reproduced.
v3_split_algstat.py envelope e1 under the simplified bound (reproduces the paper's e1 table exactly), pricing example
                    2.5431 (dual and primal), stream-prefix and hashing costs, Prop algstat:parity(iv) table and the
                    check that the tabulated g is NOT optimal for the b-range.
v4_extra.py         Theorem 2 bounds for the j=13 and j=11 envelope rules (deficiency ~1300 / ~5350 bits);
                    finite-sample corollary at n=1e6..1e10.
v5_hull_price.py    randomized hull-lemma test on a c-grid (the 23 "mismatches" are grid artefacts: intervals
                    narrower than the grid or outside [1e-3,10]) and the price inequality xi<=R^min(lambda,2)
                    (0 violations in 9156 checks).
v5b_hull_exact.py   exact rational check of hull lemma (iii): 0 mismatches in 17588 point tests.
make_issues_p2_math_add.py  appends the second-pass issues P2M-25..P2M-42 to p2/issues-p2-math.json (idempotent;
                    the first pass's P2M-01..24, written by make_issues_p2_math.py, are kept unchanged).
first-pass-backup/  copies of p2/review-p2-math.md and p2/issues-p2-math.json as the first pass left them.

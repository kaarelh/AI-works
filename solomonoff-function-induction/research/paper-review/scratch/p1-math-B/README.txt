Reviewer p1-math-B (Paper 1: hist, examples and their appendices). Independent checks.

run_sample.sh            re-runs, on scratch copies in mirror/, history c1, c5, c6, c9, r4 and examples e1, e3, e6, e7;
                         rerun_log.txt has the runtimes. All nine outputs are byte-identical to the saved ones
                         (*.saved), except the runtime lines of e6 and e7.
m1_chainsemi_restriction.py / .out
                         shows that lem:ex:chainsemi and eq:ex:depth are false as printed (z not restricted to
                         nonzero d-bit strings) and true with the restriction (exhaustive for d = 2).
m2_eisenstat_independent.py / .out
                         Eisenstat's example from the paper's definitions only: exact law of D_n and Z(S) (n <= 5),
                         the S = {0,1,3} example, P* closed form (exact, n <= 4), a frontier DP for
                         Pr[eta_n < tau_n], E N_touch, E L_P*, rule errors, Pr[no rule error]; theta, sigma^2,
                         H(1/3)/2, the return probability, B-steps per cycle, the Hoeffding constant.
m3_gf_and_constants.py / .out
                         max_G N(G) for GF(4) (total and partial G) and GF(8) (all 8^8 total G), the sketch-fails
                         losses, log2 C(n, n/2) >= n - log2(n+1) for n <= 4096, log2((N-1)!) and Robbins' window
                         (d <= 8), broom and cyclic laws by enumeration (d = 2, 3).

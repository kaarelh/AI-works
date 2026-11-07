# Independent audit of the monotone-activation paper

Reviewed by `new_lens`, 7 November 2026.

Source: `fresh_full/monotone-paper/source/paper.tex`.

Reviewed SHA-256: `06dae35bb69906f719adfa281a0095ffff77bd12c54fae5394b220e112842e01`.

I read the complete source and checked the displayed theorem and its proof, including the final online-protocol clarification and small-perturbation qualification. The main result passes this mathematical audit. This is an independent conventional proof review, not formal verification. The cited external triangle-wave paper is not needed for the proof and was not independently reviewed in this audit.

## Main construction and exact norm

The activation is the fixed strictly increasing, 1-Lipschitz function `(2t+phi(t))/3`, where `phi` is the odd period-four triangle wave. Its derivative lies in `{1/3,1}` wherever defined. The result does not establish the analogous statement for tanh, ReLU, GELU, or hardtanh.

The four orientations have zero column sums and positive row products, so the affine parts cancel exactly while all triangle components realize the same odd parity. This proves the exact code variation norm with the required factor `1/epsilon=3`. Applying the same construction to the bias coordinate also justifies finiteness for even-support characters. The explicit target teacher uses `8m-4` neurons with incoming weights in `{0,+1,-1}` and readouts of magnitude `3/4`, with margin one.

The atomic appendix is the previously audited triangle argument with an additional correct residual estimate: a far atom is within its parameter norm of zero in uniform-cube L2, while a localized atom is within its parameter displacement of the rounded pure character. Orthogonal projection then gives `||(I-P)h_theta||_2 <= e_theta`. Reduction modulo two preserves these estimates up to an irrelevant output sign.

## Calibration and all-network exclusion

For an arbitrary network, `F=L+epsilon T` and `R=T-PT` give both `V >= Q(F)/epsilon+kappa B` and `||R||_2 <= B`. The projected calibration margin is valid because every physical input in each known logical class was revealed.

The conditional random variable `Y=chi_C(L+epsilon R)` has mean zero on each logical fiber. Its one-sided bound from the training margin therefore gives the slack bound `s(z) >= E_z |Y|/2`. The flat dual has absolute coefficient at least two on every known logical point, so there is no missing factor or normalization in the unconditional-indicator estimate.

The affine fourth-moment estimate includes the bias: `E L^4 <= 3(E L^2)^2`. Moment interpolation and removal of the free set of measure `1/16` give `E[1_K |L|] >= (1/sqrt(3)-1/4) A`. This uses no conditional moment assumption.

The displayed convex combination of the two energy-surplus inequalities has weight `kappa/[sqrt(c)(1+eta)]` in `[0,1]`, and yields exactly `kappa eta(A+epsilon B)/(1+eta)`. The fiber-edge and core-mean arguments correctly imply `A+epsilon B >= 1/(2sqrt(D+1))` for every non-code sign completion. The resulting scaled penalty exceeds the star's upper excess for `c=10^8(D+1)^3+1` with substantial slack.

Thus the proof controls all competing network sign functions under the global margin constraint; it does not assume that projection preserves margins on unobserved fibers.

## Latent ordering, finite width, and posterior

The flat Fourier dual, the variable-margin non-subgroup gap, and the subgroup classification dual are correctly normalized. The Bernstein integral makes every nonconstant Walsh coefficient of the square-root weights strictly negative. Distinct squarefree parts in `[c,c+D]`, rational independence of their square roots, and the separate cyclotomic factors of the polynomials `P_v` give strict ordering without a numerical separation assumption.

Every code cost carries the common factor `1/epsilon`; the stated variation gaps and Gaussian energy lower bounds respect that factor. The four oriented atoms retain their exact total readouts under separate integer replication counts, so affine cancellation survives every finite-width allocation. The mass bound `P_* <= 3/(2 epsilon sqrt(dc)) < 1` holds for the main `epsilon=1/3` construction. Therefore the upper energies converge along all sufficiently large integer widths, and the finitely many strict gaps give a common `N_0(m)`.

A slight readout amplification creates strict global margins without closing the energy gap. The finite-dimensional Gaussian ball/tail comparison controls the entire correct-label posterior event and correctly cancels the initial margin-conditioning normalizer. Padding the unit-bounded target teacher makes every posterior along the full permutation well-defined. The stated posterior majority, confidence, and sampling conclusions follow at each fixed eligible width.

## Qualification resolved in the optional remark

The final arbitrary-small-`epsilon` remark now explicitly allows increasing the constant in the core size as a function of `epsilon` so that `P_*<1`. This resolves the one clarification requested during review. Splitting the teacher readouts alone would not reduce this allocation mass. The main `epsilon=1/3` theorem is unaffected.

No other mathematical issue was found in the reviewed source. The finite-width and small-variance thresholds are not quantitative or uniform in width, and the calibration prefix remains `15/16` of the full cube, as the paper states.

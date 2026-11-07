# Independent whole-theorem audit of the triangle-wave construction

Auditor: `exact_search`, 7 November 2026. This is an independent AI mathematical review, not proof-assistant verification or an external referee report.

Reviewed the complete integrated manuscript `../paper/source/paper.tex`, including the atomic appendix, and checked the built PDF. The source snapshot after the minor corrections listed below has SHA-256 `9ee646bfb0239d9673232891d3cd2ef609bae85202d331d94e3d68c832f0f317`.

**Verdict: no substantive mathematical gap found.** The manuscript proves the stated theorem for the fixed triangle-wave activation, subject to its explicit large-width and cold-prior quantifiers. It does not prove the corresponding theorem for ordinary ReLU or tanh.

## Model and quantifiers

The actual predictor is `sum_a v_a phi(W_a dot (1,x))`, with incoming variance `N sigma^2/d` and readout variance `sigma^2/N`. Whitening by `xi=sqrt(d/N)W`, `eta=sqrt(N)v` gives independent coordinates of common variance `sigma^2`, and the squared whitened norm is exactly `K_N=(d/N)||W||_F^2+N||v||_2^2`. Bias is included in the same incoming covariance. The teacher bound concerns the actual coefficients `W,v`, matching the original bounded-weight teacher convention; it does not claim unit bounds on whitened teacher coordinates.

The order of quantifiers is correct: for each fixed construction parameter `m`, there is a width threshold `N_0(m)`; for every fixed integer `N>=N_0(m)`, the stated posterior limits hold as `sigma` tends to zero. The input permutation is independent of both width and variance. No uniform variance threshold or polynomial width threshold is claimed. The threshold can harmlessly be enlarged to at least the teacher width, ensuring that all later exact-label posteriors remain nonempty as well.

## Atomic and margin reduction

I rechecked the appendix's Fourier series, fourth-moment low-norm estimate, block-product localization, and absolute-linear-form projection gap. In particular, the absolute-form integral uses a nonnegative difference at every frequency before restricting to `t rho<=1`; this avoids discarding a potentially negative tail. The local triangle cusp is applied only when the entire cube perturbation is below two. The relaxed constants used in the quantitative theorem have adequate slack.

The weighted coefficient triangle inequality has the needed direction: every representation satisfies `V_rep-Q(F)>=kappa sum |v_a| e_a`. A sign change inside a fixed parity fiber forces a unit output jump across an edge of length `2 sqrt(2)`. If there is no such change but oddness in the core parity fails, a fixed-control core mean has absolute value at least one half. These alternatives exhaust all sign functions outside the required code form. Taking an infimum over representations preserves their uniform positive penalty.

The initial calibration includes complete physical fibers, so projecting `chi_C F` preserves the calibrated signed margins even for an arbitrary non-code score. The training-only Fourier lower bound is therefore legitimate before code invariance is known. Projection is used to preserve *all* global margins only after code invariance and core oddness of the sign have been established. Later one-point labels retain the original calibration lower bound and eliminate the corresponding code star; they need not include the entire queried fiber.

## Latent optimization and strict ordering

The flat training dual has the stated multipliers `-1, 1, 3/4, 1` and yields `3/2-4/M`. The non-subgroup four-point argument gives `(2-delta)/(1+2 delta)`; calibration implies `delta<=3/32`, hence the bound `61/38`. The selected core size separates every nonsubgroup and every non-code completion from all feasible stars.

For subgroup labels, the weighted dual has strictly positive pointwise coefficients on the subgroup and strictly negative coefficients outside it. It certifies the Boolean margin score itself as the unique optimal real score. Thus the displayed star values are optimized classification costs, not merely costs of particular primal representatives.

All nonconstant Walsh coefficients of the square-root weights are strictly negative by the convergent Bernstein integral. Distinctness is also exact: the interval `[c,c+D]` has distinct squarefree parts, making its distinct radicals rationally independent; the odd integers `q_i` lie in `(2m,4m)` and do not divide one another, so `Phi_{q_i}` detects exactly the corresponding minus factor in each polynomial `P_v`. This establishes strict ordering without an unproved genericity assumption or a numerical gap estimate.

At every designated history, all possible correct-label completions belong to one of the listed categories: non-code, code with nonsubgroup positive set, singleton subgroup, or a later star. Their lower bounds all strictly exceed the current star cost. The displayed `Delta_j` is therefore positive and applies uniformly over the whole correct-label event.

## Finite width and actual posterior

The per-neuron AM--GM inequality gives `K_N>=2 sqrt(d) V_rep` at every width. For a pure-character expansion, the ideal fractions `p_s=|b_s|/(sqrt(d)a_s)` have total strictly below one. Counts `ceil(Np_s)` therefore fit for every sufficiently large integer width, preserve the score exactly, and converge in energy to the continuous allocation. There are finitely many stars and rounds for each `m`, so one common `N_0(m)` works. No subsequence or interchange of width and variance limits is used.

Readout amplification creates strict global margins while preserving a sufficiently small energy gap. Continuity on the finite cube then supplies a positive-volume open parameter ball in the wrong-label denominator event. The Gaussian exponential-moment tail bound for the entire correct-label event divided by this ball probability tends to zero. The initial global-margin normalization cancels. This proves concentration of the actual posterior label, regardless of parameter-level multiplicities or ties within the winning sign function. A finite union bound proves the posterior-sampling conclusion without requiring independent prediction draws.

## Teacher, dimensions, and scope

The score `chi_C [sum_i chi_{B_i}-(m-1)]` has the desired sign and margin at least one. Each constituent odd parity is one triangle ridge with incoming coefficients zero or one and readout sign absorbed. Repeating the negative core parity `m-1` times gives exactly `2m-1` unit-bounded neurons and hence `C_2(f_m)<=2m-1`. All coordinates are relevant, so the fan-in-two Boolean-circuit size is `Theta(d)`.

The choices give `D=6m^2` and `d=Theta(m^6)`. The designated mistake count is `2^(m-4)`, exponential in the displayed teacher width and stretched exponential in dimension and circuit size. The calibration length is exactly `15*2^(d-4)`, not polynomial. The source makes these limitations prominent and does not infer a `2^(Omega(d))` bound or a tanh/ReLU result.

## Minor corrections made during review

The author corrected a missing backslash in `\qquad`, wrote the gap explicitly as the minimum competing bound minus the current star cost, added the exact whitening coordinates, and stated the bounded-weight teacher complexity convention. None changed the proof. The inspected initial PDF had clean page layout; the build log contained no unresolved references or overfull-box warnings.

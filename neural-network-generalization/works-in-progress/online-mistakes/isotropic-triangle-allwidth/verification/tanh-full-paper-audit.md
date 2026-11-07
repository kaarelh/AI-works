# Independent full-source audit

Reviewed on 7 November 2026 by the `tanh_nonlinear` research agent. This is an AI mathematical audit, not formal verification or an external referee report.

Source reviewed: `../paper/source/paper.tex`, read in full at approximately 11:10 UTC, together with the atomic and quantitative-fiber notes and the previous independent audit. No substantive mathematical flaw was found. The theorem concerns the fixed period-four triangle wave; it does not solve the ordinary-tanh question.

## Construction and strict ordering

- The parameter identities are correct: the `m` odd integers `q_i=2m+2i-1` lie strictly between `2m` and `4m`; their doubled lengths sum to `D=6m^2`; the stated core size is odd and satisfies every atomic and stability hypothesis.
- Primality is unnecessary. Since no two of these odd `q_i` divide one another, `Phi_{q_i}` divides a factor `1-t^{2q_j}` exactly when `i=j`, and divides no `1+t^{2q_j}`. Thus the coefficient polynomials are pairwise distinct. The interval `[c,c+D]` contains no two integers with the same squarefree part because `2sqrt(c)>D`. Rational independence of the distinct square roots therefore gives exact strict star ordering.
- The Bernstein integral has the correct normalization and yields strictly negative nonconstant Walsh coefficients. The subgroup dual has the right Fourier normalization and strict physical-coordinate signs, proving uniqueness of the Boolean subgroup score among arbitrary real margin scores.
- The non-subgroup inequality and `61/38` constant are correct. A subgroup contained in `{0} union U` has at most two elements. This classifies every remaining code sign completion, not merely a preselected cutoff family.

## Unrestricted competitors and sequential histories

- The code projection supplies the flat training lower bound for arbitrary networks because the initial calibration contains complete physical fibers. Projection is not used to preserve global absolute margin before odd code-invariance of the sign has been established.
- The quantitative fiber lemma gives the uniform non-code penalty `kappa/(2sqrt(D+1))`. This penalty survives the representation infimum. The chosen core size makes every star upper bound strictly smaller than the non-code lower bound.
- Later individual queries preserve the initial lower bound and leave each unqueried star feasible. Hence the proof still excludes all non-code competitors after such queries. There is no unsupported assumption that the entire later history consists of fibers.
- All four possible correct-label competitors are covered: non-code signs, non-subgroup code signs, the singleton target, and later stars. The minimum of their positive gaps gives the stated finite strict variation gap at each round.

## Finite widths, strict margins, and posterior measure

- The per-neuron arithmetic-geometric mean lower bound is `K_N >= 2sqrt(d) V`. For a pure atom with norm `a_s`, the allocation `p_s=|b_s|/(sqrt(d)a_s)` minimizes its continuous energy contribution.
- The total desired allocation is strictly below one. Ceilings of `Np_s`, with zero padding, therefore fit at every sufficiently large integer width. They preserve the exact score and yield convergence along all such widths, without a divisibility or subsequence restriction.
- There are finitely many designated rounds, so one width threshold works for all of them. A small readout amplification gives strict global margins while preserving the strict energy gap against every correct-label completion.
- The strict-margin witness has an open parameter neighborhood within the denominator event. The Gaussian tail bound and the lower bound on the probability of that neighborhood have matching quadratic-energy normalization. Their ratio tends to zero at each fixed width.
- This argument bounds the complete correct-label posterior event and does not select a minimum-energy parameter vector. Tied parameter representations of the winning sign function are harmless. The pre-data margin normalizer cancels.
- The finite-round union bound establishes the sampling claim without requiring independent draws. No width-uniform variance threshold is asserted or used.

## Teacher and scope

- The score `chi_C [sum_i chi_{B_i}-(m-1)]` has the target sign and absolute margin at least one. Its expansion into `m` core-plus-block characters and `m-1` copies of the negative core character gives exactly `2m-1` triangle neurons with physical incoming/readout weights bounded by one.
- The parent agent checked the original reference definition: teacher width counts physical weights and permits weights bounded by the teacher width. Thus the displayed teacher directly satisfies `C_2<=2m-1`; an alternative normalization does not need to be imported.
- Every input is relevant, giving the claimed linear bounded-fan-in Boolean-circuit lower bound. The upper bound, parameter count, and `d=Theta(m^6)` scaling are consistent.
- The calibration occupies `15/16` of the full cube. The sufficient width may be very large because the proof needs no quantitative radical-separation bound. The abstract and theorem state these limitations accurately.

## Minor correction reported to the author agent

The free-coset display has `U=e_1+H,qquad L=...`; the missing backslash before `qquad` should be restored. This is a typesetting issue and does not affect the mathematics. Subsequent source edits and the rendered PDF should receive the usual final visual check.

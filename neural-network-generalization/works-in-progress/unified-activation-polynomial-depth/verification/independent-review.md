# Independent mathematical review

Reviewed on 23 October 2026 by a separate AI agent. Source reviewed:
`source/paper.tex`, SHA-256
`a5466d24dadf27ea15869fef17e3dc3ba3211dd47f20fb090f35d27951c0d425`.

**Finding:** no substantive mathematical error found in the main theorem or its explicit-budget proof. The review checked the actual constants, probability normalization, finite coding, and the universal degree-13 envelope. It is a conventional mathematical review, not a Lean formalization or human peer review.

## Statement and scope

The theorem concerns one fixed activation with a global Lipschitz bound and a bound on its value at zero. The teacher is an actual network using that activation, with coefficients bounded by `B` and strict signed margin greater than `1/2` on the entire Boolean cube. It does not identify ordinary Boolean-circuit width with neural teacher width. Thus the width-one representability ambiguity of some earlier Boolean-compiler statements does not arise.

The prior restriction is the balanced-population condition alone, with population count `q ≤ 1 + N‖v‖²`, optionally intersected with the original global output-margin event. It is not the intersection with the older internal-noise restriction, and it differs from the output-scale-invariant calibration of the earlier ReLU/GELU paper. The manuscript makes both differences explicit.

One sample event works at every `N ≥ C`, every `0 < t ≤ 1`, and either optional-margin convention. The event can depend on the fixed activation and target. This gives all exponents `γ ≥ 1` via `t = N^((1−γ)/2)` without a limit or an additional minimum-width threshold. The polynomial's constants are uniform over the activation class with the stated resource bounds; no data-dependent activation selection is asserted.

## Target mass: normalization and constants

The teacher readout is nonzero by the signed-margin assumption. Rescaling it to

`v′ = 4 max(1, ‖v‖⁻¹) v`

gives signed output strictly above `2` and norm between `4` and `4B√C`. A large rescaling factor therefore does not imply a large final coefficient norm. This avoids the potential exponential cost of a teacher whose small readout compensates for large hidden states.

For balanced clone groups, `C/2 ≤ N/k_a ≤ 2C` and every group-size ratio is at most two. Consequently:

- The cloned internal operator norm is at most `√2 CB`.
- The cloned readout energy lies between `8C` and `32C²B²`, so its scaled norm is at most the stated `V = 4√2 CB`.
- The first-layer constrained-coordinate squared-center sum is at most `N d(d+1)B²`.
- Each internal layer contributes at most `2N C²B²` to that sum.
- The readout contributes at most `32N C²B²`.

Adding these terms gives exactly the displayed upper bound `N B₀`, since `2(H−1)+32 = 2H+30`. There are exactly `N[d+2+(H−1)C] = Nq₀` constrained independent Gaussian coordinates. The unconstrained parts are independent of these coordinates after orthogonal projection onto the clone subspace.

The hidden-state recurrence is valid without assuming `φ(0)=0`: from `|φ(u)| ≤ b+λ|u|`, the stated `R_*` dominates both the first-layer growth and the factor needed at later layers. Hence every teacher hidden coordinate is bounded by `M=R_*^H`.

The standard square-Gaussian operator-norm tail, followed by right projection, gives failure at most

`exp(−N log(2H)) ≤ 1/(2H)`

at threshold `g_H t`. A union bound over `H−1` internal layers leaves probability at least `1/2`. For `H=1` there are no such layers, and using the same lower bound remains valid.

On this event, the manuscript's error recurrence follows from `G^s h_*^(s−1)=0`, the teacher-state bound, and Lipschitz continuity. Summing it yields `e_H ≤ ρE`; the stated `E` is larger than the direct geometric-sum upper bound. The readout discrepancy is at most `(V+1)e_H+ρM ≤ 1/8` by the definition of `ρ`. In particular, both the actual and merged networks have signed output greater than `15/8`.

The projection really preserves the target cylinder: averaging target-group rows preserves all coordinate intervals, the teacher rows are identical within a group, and right projection removes the unconstrained bulk. The same argument applies to first-layer and readout intervals. The clipped outputs of the two networks therefore agree exactly. Also `√E_v ≥ √(8C)−ρ ≥ √(2C)`, since `ρ ≤ 1/8`; hence the clone partition satisfies the population-count condition with slack.

The scalar interval lower bound follows from

`(|a|/t+ρ)²/2 ≤ a²/t²+ρ² ≤ a²/t²+1`.

Multiplying it over the constrained coordinates and including the independent bulk event gives the claimed `exp(−ND_*/t²)` bound using `t≤1` and `N/t²≥1`. This lower bound applies to both optional-margin conventions and every correctly labeled training sample. It proves positive prior and posterior normalizers, not merely a conditional claim assuming positivity.

## Partition tails and posterior truncation

For a fixed balanced partition tuple, collecting equal neurons is an exact width-`q` computation for every activation, including an activation with nonzero offset. The compressed coordinates are sums over disjoint Gaussian blocks, so they are independent. Their variances are exactly those displayed in the manuscript. After the energy weights, each variance is at most `2t²/N`.

At exponential parameter `N/(8t²)`, each squared Gaussian coordinate contributes a moment factor at most `√2`; therefore the moment is at most `2^(P_q/2)`. There are at most `q^(HN)` labeled partition tuples, and `P_q/N ≤ d+2+(H−1)q` for `q≤N`. The stated union bound follows. This union is taken before any data- or weight-dependent choice of witnessing partition.

The readout energy has distribution `(t²/N)χ²_N`. Its displayed tail follows from the chi-square moment at `1/4`; `B_r≥8` is more than sufficient to absorb the `2^(N/2)` term. Division by the target lower bound leaves posterior probability at most `ε/4`. On the complement, the support supplies `q≤Q`.

For the partition tail, the positive terms are `log Q`, `HN log Q`, and `(N/2)[d+2+(H−1)Q]log 2`. Each is bounded by `N/t²` times the corresponding term allocated in `J/8`. After subtracting `ND_*/t²` for normalization, at least `log(4/ε)` remains. The second posterior exceptional probability is consequently at most `ε/4`, with no assumption that width is large.

## Padding, coding and generalization

Zero-padding is valid even when `φ(0)≠0`, as the manuscript states. Dummy neurons output `φ(0)`, but every edge leaving them and every corresponding readout coefficient is zero. Their values cannot affect the original computation. Zero-preserving rounding retains this property. A separate union over compressed widths is therefore unnecessary.

The compressed energy bounds every coefficient by `√(QJ)`. Padding may change the weighted energy at width `Q`, but the argument only uses this coefficient bound after padding and never asserts preservation of that energy. The grid contains zero, has the stated point count, and bounds all original and rounded coefficients by `R`.

The given `A_g` dominates `b+λ(d+1)R`, `b+λQR`, `λQR`, `λQ`, `QR`, and `Q`. Thus both networks have hidden magnitudes at most `A_g^s`. The error recurrence gives `e_s ≤ sζA_g^s`, and readout error at most `(H+1)ζA_g^(H+1)=1/32`. Combining this with the support's merging error gives the `3/32` clipped-output discrepancy. The parameter count is exactly `P_Q=Q(d+2)+(H−1)Q²`.

The zero-observed-event argument is sound with its boundary conventions. Signed training margin above `1/2` implies the grid score is at least `13/32`, whereas every original test failure at margin `1/4` implies grid score at most `11/32`. Therefore the training sample avoids the grid event containing the original failure set. The finite-class union bound at threshold `ε/2`, plus the discarded posterior mass, yields average loss at most `ε`. The class depends only on the fixed activation and displayed resources, so the same sample event handles all widths, scales, and optional-margin choices. Posterior mixtures cause no additional issue.

The confidence corollary follows by applying the theorem at `ε/3`: correct-margin probability at most `2/3` contributes at least `1/3` to posterior-average loss. This proves the stated strict-confidence conclusion and also controls sign correctness.

## Degree-13 envelope

The estimates in the final proof have universal constants. In particular:

- `log M` and `log E` are `O(H log S₀)`, giving `log(1/ρ)=O(H log S₀)`.
- The center cost is `O(S₀^5)`, while `q₀ log(1/ρ)` is `O(S₀^4)` after using `log S₀≤S₀`. Thus `D_*=O(S₀^5)`.
- The displayed formulas then give `Q=O(S₀^5)`, `J=O(S₀^6)`, and the deliberately rounded-up `R=O(S₀^6)`.
- Consequently `A_g=O(S₀^12)` and `P_Q=O(S₀^11)`.
- `log(3+4R/ζ)=O(H log S₀)=O(S₀²)`, so the total log-code budget is `O(S₀^13)`.

All lower resource bounds used here are part of the statement (`d,C,H≥1`, `B,λ≥1`, `b≥0`, `0<ε<1`). No polynomial exponent depends on depth, activation, learner width, or prior scale. The external `log(1/δ)` term is carried directly into the sample bound.

## Remaining limitations

The proof establishes a new common restricted-prior theorem; it does not prove that its support condition holds for ordinary trained networks or that it follows from the original internal-noise condition. It does not preserve the earlier ReLU/GELU paper's different support calibration. The polynomial is conservative and is not a quadratic teacher-width guarantee. The result concerns Boolean labels with a uniformly margin-separated implementing teacher, noiseless iid data, and exact posterior conditioning. It does not establish arbitrary regression, noisy-label recovery, or efficient computation. The manuscript states these limitations accurately.

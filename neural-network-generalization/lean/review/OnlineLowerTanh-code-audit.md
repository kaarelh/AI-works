# Ordinary-tanh transversal-code verification record

The multi-orientation analytic argument is kernel-checked in Lean 4.32.0.
The code norm theorem takes the sharp **intrinsic single-parity bound** as an
explicit intermediate input. That input is proved in `OnlineLowerTanhSharpParity`
and discharged in the [complete main theorem](OnlineLowerTanh-main-correspondence.md).
This component record describes the code-localization and support argument.

## Checked endpoints

`OnlineLowerTanhCodeLocalization.actual_tanh_code_orientation_localization`
uses literal affine tanh neurons, literal Walsh coefficients, and the actual
carrier-plus-rails physical coordinate model. For fixed positive constants
`c,K` and each natural `L`, it gives constants `k₀,p₀` such that, for every
`p ≥ p₀` and every even baseline `R ≥ k₀ log²(p+2)`, a neuron whose weighted
retained code mass is at least `c` times its Euclidean parameter norm has a
retained orientation with all competing mass at most `(pR)^(-L)` times that
norm. The weights are nonnegative and at most `K pR`; every rail is even and
has at least `R` coordinates. This theorem has no intrinsic sharp-parity
hypothesis and no unproved analytic premise.

`OnlineLowerTanhCodeExact.carrierCodeMass_exact_of_intrinsic` combines that
localization with exact high-order vanishing and support stability. Its only
remaining analytic input is the named literal proposition

```lean
∀ θ ∈ A,
  IntrinsicParityBound (carrierTransversal size θ).card (w θ)
```

for the nonempty retained orientation set `A`. It proves, for every bias and
physical incoming vector, that the weighted code mass `Q` is at most their
Euclidean norm `ρ`. It also finds a retained orientation for which

```text
bias² + outside-coordinate squared norm
  ≤ (4 + 576 K²) (pR)² ρ (ρ - Q).
```

Both endpoints compiled successfully with output oleans. Their proofs contain
no `sorry` or introduced axiom. The zero-energy and noncompetitive-neuron cases
are included. The logarithmic threshold is uniform for every larger rail size,
not just for a chosen sequence of widths.

For the manuscript's literal weights `balancedCost(card/2)` and rail sizes in
`[R,2R]`, the checked `balancedCost_le_four_degree` and the actual support-card
formula give `w ≤ 12 pR`. The construction-threshold and family-assembly modules instantiate the intrinsic
hypothesis and connect this orientation-indexed statement to the final
logical-code family.

## Proof review

The actual tanh sine-transform representation, physical subset reindexing,
finite Hölder estimates, uniform arbitrary-frequency Laplace estimates, and
positive-kernel integrability are all proved in the imported modules. Compact
parameter scale and the existence of a retained resonance peak follow from
actual weighted-code competitiveness.

The whole-set determinant proof compares old-selected coordinates on switched
rails with all coordinates selected by the competing orientation. Every cross
determinant is odd. Summing over both sets gives phase-error mass proportional
to `jR` for an orientation switching `j` pairs, using only the total phase
energy. Thus no additional factor of `p` is lost in the frequency cutoff.
Summing the competing orientations by switch count gives
`(1 + exp(-aR/2))^p - 1`. A low-frequency square-root envelope removes the
apparent singularity of the hyperbolic-sine kernel at zero. The large-frequency
integral follows from the uniform Laplace estimate. The checked numerical
log-square threshold makes their sum smaller than any prescribed inverse power
of `pR`, uniformly over larger `R`.

Switching `j` pairs introduces at least `jR` inactive physical coordinates.
Repeated centered differences and the checked bound
`|tanh^(k)(x)| ≤ k!` bound the competing Walsh coefficient by a high power of
the inactive norm. Summing these bounds gives the same finite binomial
expression. The explicit radius `(pR)^(-2)` and off-mass precision
`(pR)^(-12)` satisfy all bootstrap and local absorption inequalities for
`R ≥ 16` and sufficiently large `pR`.

The final absorption is not circular. If the selected-support deficit is at
least twice the off-mass, the conclusion follows immediately. Otherwise the
intrinsic support-stability estimate and the global localization bound place
the neuron inside the local radius; high-order vanishing then forces the same
deficit inequality. The original intrinsic support constant is retained after
this bootstrap, so the final support bound has degree two in `pR`.

## Integration into the main theorem

The unconditional `OnlineLowerTanh.eventual_intrinsicParityBound` proves the
sharp intrinsic proposition for the actual balanced optimum in all sufficiently
large odd degrees. The final construction proves that every selected physical
support meets that threshold. Thus the code theorem's explicit intermediate
hypothesis is fully discharged in `OnlineLower.tanh_concrete_main`; it is neither
an added axiom nor a remaining premise of the online lower bound.

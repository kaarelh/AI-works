# Continuous depth lower bound: formalization status

Work started on 22 October 2026. All three main learning statements are now proved; the checked scope is recorded in [the second-batch coverage table](BatchTwo-coverage.md).

Manuscript: `works-in-progress/continuous-depth-lower-bound/source/paper.tex`,
including `memorization.tex`, `posterior.tex`, and `meanfield.tex`.

## Main claims that must be matched

1. One fixed nonatomic Borel probability measure on the unit circle, and
   real-valued tanh targets of width three, depth `r+1`, and coefficient
   bound thirty. For every sufficiently large `r`, every
   `1 <= n <= exp(r/100)`, and every fixed learner width above the specified
   polynomial sample-dependent threshold, the limiting lower sample
   probability of posterior confidence-error mass at least one half is
   at least `49/50`, as the prior variance tends to zero.
2. At every fixed exponent strictly above one, the same conclusion at the
   actual positive Gaussian variance for every width above a polynomial
   threshold in sample size and depth. The degree may depend on the
   exponent's distance from one. The statement also covers all smaller
   positive prior variances.
3. At the mean-field exponent, the separate width-first lower bound: on
   a sample event of probability at least `49/50`, the lower limit of
   confidence-error mass is at least one half. The exponential sample
   exponent is some universal positive constant; it need not be `1/100`.

All claims use training tolerance `1/8`, test tolerance `1/4`, and count
the finite-exponent/strong-prior confidence convention and, for the mean-field main theorem, the literal strict correct-output posterior probability `<2/3` confidence error.
There is no global-margin restriction on the prior. These are conclusions
about full posterior mixtures, not posterior-mean prediction or selection
of one minimizer. The main fixed input law is singular; uniform arclength
on the circle is not claimed.

The manuscript additionally proves exact-minimum-energy interpolation and
specified iterated posterior-limit variants, and a smooth input-density
variant whose input law varies with depth. These require separate tracking
if the whole manuscript is described as verified.

## Reusable verified infrastructure

- `BatchTwoContinuousModel` supplies the actual real-input network,
  tolerance-conditioned posterior, correct-output probability, and
  confidence-error mass, including joint measurability.
- `ConcreteModel.smallPrior`, `powerPrior`, and `weightedSquaredNorm`
  are the actual finite independent Gaussian laws and quadratic cost.
- Existing finite-dimensional Gaussian small-noise estimates and
  Gaussian transport/entropy machinery may supply parts of the posterior
  ceilings, after their hypotheses are proved for this construction.
- Continuous upper-bound modules provide useful network continuity and
  stability statements. They do not prove the lower-bound target or
  input-law construction.

## Current proof status

The **strong-prior main theorem is proved** with the manuscript’s exact
quantifiers, sample exponent, width threshold, tolerances, and probability
constants. The **finite-exponent main theorem is also proved**, including a
polynomial sufficient width in sample count and depth. The **mean-field main theorem is also proved**, in `BatchTwoContinuousDepthCriticalMain.critical_manuscript_depth_lower_bound`. Its actual training-event denominator is established in `CriticalTrainingMass` and `CriticalDenominator`, and its numerator and posterior-mixture obstruction in `BatchTwoContinuousPairTailDecay`, `CriticalPosterior` and `PairRisk`. The following actual ingredients compile:

- `BatchTwoContinuousDepthTeacher`: the literal width-three tanh matrices,
  exact iterated-map output, and coefficient bound thirty.
- `BatchTwoContinuousDepthBranches`: numerical endpoint and derivative
  bounds for the actual tanh map, its two inverse branches, contraction
  factor `1/3`, lower distance factor `1/20`, and branch separation one.
- `BatchTwoContinuousDepthCoding`: the infinite inverse-branch limit,
  measurability, injectivity, exact shift dynamics, and cylinder separation.
- `BatchTwoContinuousDepthLaw`: the actual fair infinite-product coding law,
  exact cylinder masses, absence of atoms, invariance under the expanding
  map, and the measure-preserving bit-flip pairing.
- `BatchTwoContinuousDepthFrostman`: the literal small-ball exponent
  `log(2)/log(20)` and interval-mass bound `2 * length^alpha`.
- `BatchTwoContinuousDepthSphere`: one fixed nonatomic law on the unit
  circle, bounded target values, the paired target gap and input distance,
  and the full posterior-mixture geometric obstruction. Its good-predictor
  mass and smoothness premises remain premises of this intermediate lemma;
  it is not presented as the neural posterior lower bound.

- `BatchTwoContinuousDepthSeparation`: the exact `Delta_n` and `49/50`
  probability of a separated IID sample from the fixed input law.
- `BatchTwoContinuousDepthInterpolation` and `BumpNetwork`: exact interpolation
  by literal tanh bump features, including a proved finite matrix inverse.
- `BatchTwoContinuousDepthScalarChannel`, `ChannelNetwork`, and `Memorizer`:
  the actual inverse scalar channel, dense finite-width implementation,
  exact sample interpolation at every width above `M_n`, and its energy bound.
- `BatchTwoContinuousDepthResources` and `ResourceDecay`: the paper’s literal
  width threshold and uniform estimates for `n <= exp(R/100)`.
- `BatchTwoContinuousDepthEnergyLipschitz`: a proved product-of-layer-energy
  inequality and the resulting actual input Lipschitz bound.
- `BatchTwoContinuousDepthStrongConcentration`: small-prior concentration
  obtained from the actual Gaussian open-event rates and an actual interpolant.
- `BatchTwoContinuousDepthSampleMeasurability`: measurability of the
  sample-dependent conditioned confidence error and a general Fatou lemma
  for moving events at a countably generated filter.
- `BatchTwoContinuousDepthStrongMain.strong_prior_depth_lower_bound`: the
  original manuscript depth index, `n <= exp(R/100)`, every fixed
  `N >= max(30,M_n)`, and the literal small-prior lower limit of the sample
  probability of confidence-error mass at least one half, bounded below
  by `49/50`.
- `target_implementation_all_depths`, `inputLaw_sphere`, the probability
  and null-singleton instances, and `depthTarget_support_bound`: the
  explicit target and input-law assertions accompanying that theorem.

The Lean proof of the strong-prior main theorem uses a simpler scalar channel
than the manuscript: repeated `tanh(2t)` and inverse-channel labels contracting
by `3/4` give energy at most four times depth. The resulting Lipschitz ceiling
is exponential with base two, which suffices against the target’s expansion
with base three. This proves the same main theorem, but does **not** verify the
manuscript’s stronger intermediate `K_n(L)` and depth-independent `Lambda_n`
formulas. The formal finite-exponent proof below uses a different route and
does not depend on those stronger intermediate lemmas.

`BatchTwoContinuousDepthStrongAudit` audits the complete strong-prior endpoint
and core supporting constructions. Only Lean’s standard `propext`,
`Classical.choice`, and `Quot.sound` axioms occur. The entire manuscript must
not be described as formally verified: the mean-field endpoint is now proved
(see below), but the extra variants remain outstanding. No analytic
conclusion is installed as an axiom or endpoint hypothesis and then described
as proving the paper.


## Verified finite-exponent main theorem

`BatchTwoContinuousDepthPowerManuscript.finite_power_manuscript_depth_lower_bound`
has the original depth index `R`, target and learner depth `R+1`, the sample
range `1≤n≤exp(R/100)`, training tolerance `1/8`, test tolerance `1/4`, and
sample probability at least `49/50` of confidence-error mass at least one half.
For every fixed `ζ>0`, a sufficient width is a constant depending on `ζ`
times `(n+R)^(161*ceil(1/ζ))`. The conclusion holds at every positive scale
`σ²≤N^-(1+ζ)`.

`BatchTwoContinuousDepthPowerMain.finite_power_depth_lower_bound` gives the
stronger common-event form: one measurable sample event works simultaneously
at all admissible widths and scales. `power_prior_depth_lower_bound` specializes
to the literal Gaussian `powerPrior`, uniformly over every `γ≥1+ζ`.

The proof has three fully constructed parts:

- `SlowChannel`, `SlowNetwork`, `SlowMemorizer`, and `SlowSample` use the actual
  gain-`7/5` inverse channel. Its exact interpolator has energy at most
  `(49/25)r+5` and readout energy exactly one. Sharp cloning adds at most this
  one readout unit.
- `PowerBudget`, `PowerMass`, `PowerPolynomial`, and `PowerSampleMass` prove
  actual training-event mass at least `exp(-K/(2σ²)-N*P)`. They retain the sharp
  Gaussian coefficient one half. The cylinder cost `P` is polynomial jointly
  in depth and sample-resource size, because the proof retains the logarithm
  of the exponentially small stability radius.
- `BatchTwoContinuousPairTailDecay` and `PowerPosterior` bound the prior and
  then posterior probability of an output change at least `1/2` between the
  paired inputs. The actual paired-network Gaussian moment recursion defeats
  the sharp memorizer denominator. The measure-preserving pairing then forces
  the confidence-error lower bound for arbitrary posterior mixtures.

`PowerWidth` gives an explicit sufficient width in memorizer width and depth;
`PowerWidthGrowth.widthThreshold_polynomial` substitutes the proved
`M_n≤10^25 n^23` to give the advertised polynomial in sample count and depth.

This proves the finite-exponent main theorem with a different polynomial
threshold. It does not verify the manuscript's separate stronger
approximation-ceiling lemma or its displayed isoperimetric threshold formula.
Neither is assumed in the final formal theorem. Axiom checks of all three
main finite-exponent endpoints, the polynomial width theorem, and the sharp
normalizer and posterior bridge report only `propext`, `Classical.choice`,
and `Quot.sound`.

## Mean-field completion

The actual physical seed, adaptive Gaussian transitions, certified finite histories, saturation and independent readout are combined in `BatchTwoContinuousDepthCriticalPhysicalSeed`, `PhysicalPath`, `PhysicalSaturation`, `ReadoutMass` and `TrainingMass`. The universal logarithmic schedule is proved in `CriticalSchedule`. `CriticalDenominator` discharges every finite-width budget eventually at fixed depth and sample. The final theorem has no denominator or compression assumption and reports only the three standard Lean axioms. The fixed nonatomic law, exact target family and literal original prior are shared with the other two main endpoints.

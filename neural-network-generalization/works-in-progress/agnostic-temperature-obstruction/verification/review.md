# Independent mathematical review

Reviewed 18 November 2026 (UTC) by a mathematical-review agent separate from the paper's authoring agent. This record covers the complete current manuscript, including the actual canonical finite-prior theorem. It is an informal mathematical and statement-correspondence audit, not a Lean formalization or external human review.

## Verdict and theorem scope

I found no substantive mathematical gap in the main theorem, the scaled-label corollary, both canonical finite-prior theorems, the fixed-width corollary, the localized-noise corollary, or the memorizer-optimality appendix.

For the specified tanh architecture with at least two hidden layers, the construction gives one law at each prescribed sample size and one high-probability sample event. On that event it establishes a constant excess risk simultaneously at every sufficiently large learner width and every positive likelihood temperature. The teacher is the law's exact conditional mean, has the stated width and coefficient bounds, and is therefore an optimizer in the comparator class.

There are three distinct posterior conclusions:

- At every fixed eligible width, a sufficiently small prior-scale threshold works for all positive temperatures. That threshold may depend on the sample and width. Temperature may depend on the sample, validation information, or the prior scale.
- At the actual canonical finite scalings `sigma^2 = N^(-gamma)`, the lower bound holds simultaneously for every eligible width, every `gamma >= 2`, and every positive temperature. This statement takes no width or prior-strength limit and needs no width-dependent small-scale threshold.
- At a larger polynomial width threshold `N** = O_H(n^a + n^2 (log n)^5)`, the actual finite-prior conclusion holds simultaneously for every `gamma >= 1`, including the mean-field case, and every positive temperature. The data law and sample event are unchanged.

All three conclusions cover raw and clipped posterior-averaged risks, the ordinary raw posterior mean, clipping that mean, and averaging clipped predictions. The mean-prediction lower bounds are proved directly, rather than inferred from average risk of individual predictors.

## Teacher, memorizer, and data law

**Two-chain teacher.** The two disjoint tanh chains use at most the specified width. At the inner input separation, the product of derivative lower bounds puts their difference between `1/G` and `2/G`. The normalizing readout is consequently between `B/2` and `B`. At the outer anchor inputs the chain outputs differ by an exponentially small amount. This yields exact opposite inner labels and labels in `[-1,1]` throughout the law's support, without exceeding the teacher's coefficient bound. The theorem does not require its output to be bounded by one away from that support.

**Energy and sensitivity.** The weighted first-layer and readout factors cancel learner width. AM–GM on the layer energies gives the sensitivity bound `d^(-1/2)(Q/L)^(L/2)`. Bounded tanh activations give the raw-output ceiling `sqrt(Q)`. Comparing a minimizer with the zero network gives `Q <= 1/lambda`.

**Memorizer.** I checked the Fourier expansion, the parity staircase representation by margin-one halfspaces, the tanh approximation, the random-feature sampling bound, and the scalar amplification construction through the remaining layers. The first-layer row norms and all layer-energy contributions obey the stated bounds. Balanced copying works at every integer width above the specified threshold. The memorized function is zero on the whole steep-tag component, not merely at its observed points. The resulting energy and width rates are those used in the main theorem.

**Data law.** The noisy component has independent fair labels and teacher value zero; the steep component is labeled by the teacher. The teacher is therefore exactly the conditional mean, with squared risk `9/10`. The input covariance calculation gives the claimed diagonal matrix and eigenvalue interval. Every coordinate attains both endpoints. The law is discrete and includes a real-valued coordinate with close inner support points; it is not a Boolean-input lower bound. The dimension is logarithmic in sample size, and the law changes with sample size.

**Common sample event.** The expected noisy singleton count and bounded-difference concentration give the stated first event. The steep-component count obeys the stated Hoeffding bound. Their intersection is independent of width and temperature, so no uncountable union bound over learner parameters is needed.

## Temperature split and strong-prior conclusion

At small temperatures, comparison with the memorizer controls the count-weighted residual from the noisy empirical means. The residual tends to `1/10`, below the limiting singleton density. The reverse triangle inequality forces a nonzero prediction norm on the noisy population; its resulting limiting excess is approximately `0.0750022`. Clipping and posterior averaging preserve the needed residual upper bounds.

At larger temperatures, the energy/sensitivity ceiling prevents fitting the close, oppositely labeled signal inputs. The theorem's strict exponent condition is exactly what makes the allowable half-difference tend to zero. The resulting limiting excess is `0.05`.

The finite-posterior proof near the strong-prior limit uses a positive-volume ball around the memorizer for all small temperatures, and a weighted energy tail for the remaining temperatures. The ball's Gaussian relative entropy has the stated uniform upper bound. The tail controls raw posterior means, not merely posterior probabilities. The constants give excess greater than `1/100` in both cases. Taking the smaller prior-scale threshold proves uniformity over all temperatures at each fixed width, including temperatures that themselves vary with prior scale.

## Canonical finite-prior theorem

I separately checked the complete `source/finite-negative.tex` argument.

1. The parameter count is `P = N(d+2) + (H-1)N^2`. At every `gamma >= 2`, the bounds `P sigma^2 <= d+H+1`, `N sigma^2 <= 1`, and `sigma^2 <= 1` hold uniformly in width and exponent. The chi-square energy moments have the stated constants.
2. Telescoping the network through all layers bounds the output perturbation under a Gaussian comparison measure around the memorizer. The weighted layer factors cancel width. Squaring the bound and using the chi-square moments gives the displayed root-mean-square constant `V` without an omitted width factor. The chosen noise shrinkage makes the increase in expected empirical loss at most `1/n`.
3. The comparison measure perturbs every parameter coordinate. Its exact Gaussian relative entropy gives the penalty `lambda [K + 2 D0 log(1/r_n)]`. At small temperatures, the extra entropy term tends to zero uniformly in eligible widths and exponents. This yields the same residual cap and excess lower bound for all listed posterior prediction conventions.
4. At large temperatures, the prior loss bound, Jensen's evidence lower bound, and the exact Gaussian energy exponential moment imply stochastic domination of posterior energy by the stated constant plus an exponential random variable. Minkowski then gives the claimed `L/2` energy moment. This directly controls the inner-pair half-difference of raw and clipped posterior means uniformly in all parameters. Their excess is at least `q/8 > 1/100`; Jensen gives the corresponding Gibbs-risk statements.
5. No limit or data-independent selection of width, exponent, or temperature is used in this argument. Its common sample event supports the simultaneous quantifiers in the theorem.

## Actual finite priors at every exponent at least one

I independently checked the complete `source/all-canonical.tex` extension and its constants. It gives the same negative comparator exponents throughout `gamma >= 1`, at the explicitly larger width threshold. Its two new ingredients are a comparison Gaussian with **unchanged covariance** and Gaussian **operator-norm** posterior tails.

**Shifted Gaussian memorizer.** The sign-feature sampling representation is unchanged. Its first-layer mean rows are sufficiently saturated that Gaussian noise of variance at most two has the stated uniformly small mean effect. The weighted Hoeffding estimate and the second-moment Hoeffding estimate use the correct squared coefficient sum and give the claimed first-layer event. After the first layer, every output row has the same deterministic mean, so conditional on the previous layer its neurons are independent with the stated common Gaussian-smoothed tanh law.

The zero-signal variance recursion remains in `[0,1]`, and its derivative factors satisfy `a_l >= 1/sqrt(3) > 1/2`. The heat identity and the bounds on the second and third derivatives give exactly the two displayed scalar inequalities. I checked the scaled deterministic recursion: the variance deviation is bounded by `H eta + 48 R^(-2j)`, the scaled mean error increment has the stated `144` constant, and geometric summation gives `192/R^2 + 9 H^2 R^(H-1) eta <= t/2`. This also closes the bootstrap assumption. The bad-event bound, bounded hidden outputs, and independent readout variance give the claimed pointwise-uniform output root-mean-square approximation. No common Gaussian event over all inputs is claimed or needed.

The mean's energy is at most the stated first-layer cost plus `(4H+1)R^2`. Keeping the covariance exactly equal to the prior makes relative entropy exactly `Q(mean)/(2 sigma^2)`, with no omitted covariance or parameter-count cost. For the chosen `t`, the width expression is `O_H(n^2 (log n)^5)` and the energy has the same `n^(1/H)` exponent as the earlier memorizer.

**Operator-norm posterior moments.** After the weighted normalization, every matrix has Gaussian entries of variance `sigma^2`; its dimensions are at most `N` when `N >= d+1`. The standard Gaussian matrix norm expectation and concentration bounds give the displayed common tail. Combining this tail with Jensen's evidence lower bound proves the asserted stochastic domination of the squared excess of the largest layer operator norm. Its `L/2` moment and Minkowski give the stated raw posterior-mean sensitivity ceiling. This argument uses `N sigma^2 <= 1`, rather than a bound on full Frobenius energy, and therefore applies throughout `gamma >= 1`.

**Final oracle obstruction.** In the small-temperature branch, the Gaussian comparison's pointwise root-mean-square approximation gives the exact noisy within-atom residual inequality used in the paper. Its regularization cost vanishes under the original temperature split. In the complementary branch the operator-norm sensitivity ceiling has the same decisive power of temperature as before, so the unchanged strict comparator exponent condition makes the inner-pair difference vanish. Both arguments are uniform over all eligible widths, exponents, and temperatures on the single occupancy event. The localized-noise and fixed-width variants retain these conclusions at the enlarged width threshold.

The original `gamma >= 2` theorem still has value because it uses the smaller width threshold. The abstract, introduction, final discussion, and theorem statements distinguish these thresholds correctly.

## Scaled-label corollary

Multiplying labels and teacher readouts by a fixed `rho <= 1` preserves the input law and teacher coefficient cap. The noisy singleton norm and the small-temperature residual scale by `rho^2`; the large-temperature signal amplitude becomes `rho`. The same arguments, with the thresholds scaled accordingly, prove the stated excess `nu/90` at Bayes squared risk `nu`, including in the canonical finite-prior regime.

This scales signal and noise together. It does not assert a fixed excess independent of the noise level or a small probability of label flips; the manuscript explicitly distinguishes these interpretations.

## Localized noise with unit signal amplitude

The additional `source/localized-noise.tex` corollary is valid. Assigning noisy input mass `p`, inner-pair mass `r=p exp(-p)/32`, and all remaining mass to the outer anchors preserves the teacher and its coefficient bound. The teacher's outer values vanish in the large-sample limit, so the same memorizer has residual `r+o(1)` after the unavoidable within-noisy-atom variance is removed. The singleton event gives a prediction-norm lower bound greater than `p^2 exp(-p)/5` in the small-temperature branch. The large-temperature pair bound gives at least `p exp(-p)/128`, above the displayed safe constant `p^2 exp(-p)/256`.

I checked the modified covariance bounds, concentration event, and exact constants. For each fixed positive `p`, the same width and temperature quantifiers remain valid in both posterior regimes. Signal amplitude is retained, while its difficult input mass shrinks with `p`; the covariance lower bound and excess constant may also depend on `p`. This is localized regression noise, not independent fixed-probability flips. These limitations are explicit in the manuscript.

## Fixed-width corollary

The width-two teacher variant is valid. With one neuron in each tanh chain, the increasing coefficient cap `B=n^b` supplies the gain, and the inner separation is `4 B^(-(H+1))`. For `b > 1/(2H)`, the large-temperature sensitivity allowance tends to zero under the same temperature split. The memorizer, sample event, finite-posterior comparison, and canonical finite-scale argument are unchanged. Thus width alone cannot control a dimension-uniform vanishing-excess oracle guarantee for this learner family when coefficients are unrestricted. The manuscript retains the logarithmically growing input dimension and changing-law qualifications; it does not claim a fixed-distribution or fixed-dimension inconsistency theorem.

## Optimality of the tanh memorizer exponent

I checked the complete self-contained `source/optimality-appendix.tex` proof.

- The charged energy excludes the first layer. The tanh-as-positive-mixture-of-clippings identity has nonnegative weights of total mass one, and the variable-clipping Rademacher bound adds at most `1/(2 sqrt(s))` per hidden layer. The path-weight normalization and AM–GM use exactly the remaining `H` energy terms. The first-layer halfspace mixture and counting bound give the displayed capacity uniformly over widths and unbounded first-layer weights.
- Arbitrary-label fitting forces correlation at least `1-t`, yielding the deterministic energy lower bound.
- For random labels, clipping preserves the residual upper bound and yields required correlation at least `(1-rho)/2`. The uniform clipped correlation changes by at most `2/s` when one label changes. The chosen energy threshold gives expected correlation at most `(1-rho)/4`; the displayed McDiarmid deviation contributes `(1-rho)/8`. Their sum is strictly below the required correlation, proving the strict energy lower bound with the claimed exponential probability.
- Conditional on all input locations, noisy singleton labels remain independent fair signs. On the occupancy event, there are at least `n/3` of them. Total noisy residual at most `n/5` therefore gives singleton residual fraction at most `3/5`. The random-label theorem yields additional failure at most `exp(-n/2400)` and the exact energy denominator `1200` in the corollary.

The resulting `n^(1/H)` energy exponent, up to logarithms, is optimal for this arbitrary-label/noisy-singleton memorization role. This does not close the positive-versus-negative tanh comparator-width gap, nor prove that the current signal obstruction is optimal. The manuscript retains that distinction.

## Remaining limitations

The theorem concerns this dense Gaussian squared-likelihood learner family and its specified comparator-growth range. It does not disprove all polynomial-width oracle inequalities. The positive and negative tanh exponent boundaries leave a gap, and no equality-case claim is made. The actual finite theorems cover every canonical `gamma >= 1`, with a larger width threshold for the full range and a smaller threshold for `gamma >= 2`. No arbitrary noncanonical width-uniform scale schedule is inferred merely from the pointwise strong-prior statement. Individual temperature-wise risk lower bounds do not establish a lower bound for mixtures of different-temperature posteriors. Well-conditioned covariance does not exclude close support points or imply a density.

The abstract, main theorem, finite theorem, corollary, and proof use consistent hidden-layer and total-depth conventions. The quoted positive comparison range is explicitly a result from the cited companion paper, rather than a theorem proved here.

## Reviewed source snapshot

SHA-256 hashes at completion of this review:

| File | SHA-256 |
| --- | --- |
| `source/paper.tex` | `0c200407e57f6b2c9518d68d3787fdabc377537b8d188f32f6c2afe099ca269e` |
| `source/finite-negative.tex` | `142050685050da5673cf8c5d225ac47df4ac94dee4177d64c9e84df07e96fdce` |
| `source/localized-noise.tex` | `cc430966c53e14ef7dc262822410a73514a94a3d931606483ac6213f0a39f89c` |
| `source/all-canonical.tex` | `e62cf2cb98326f8ff08b1c97042aef92cb674ad1c7d7f4c9c22f542326012ccf` |
| `source/optimality-appendix.tex` | `dbee7be709cf8cf72a29f577326900d50a55d74223838fd695612636105a52ff` |
| `paper.pdf` | `3f3c83e4bf5c8bc6ee3212226f220e4f4858ff7efaac3b178867962f59b1a969` |

The numerical two-chain checks and build records are supplementary checks; they are not assumptions of the proof.

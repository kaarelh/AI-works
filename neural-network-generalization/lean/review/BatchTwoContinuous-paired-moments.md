# Paired-output Gaussian moments

`BatchTwoContinuousPairMomentsOutput.output_pair_moment` proves the following literal finite-network statement. For positive input dimension `d`, width `N`, Gaussian scale `σ`, and positive integer moment order `p`, with `r+1` tanh hidden layers, put

`Δ² = ∑j (x j - y j)²`.

Then, under the actual independent Gaussian prior with first/internal/readout coordinate variances `(N/d)*σ²`, `σ²`, and `σ²/N`,

`E |output(x)-output(y)|^(2p) ≤ [Δ²*σ²/d*(1+2p)*(σ²*(N+2p))^(r+1)]^p`.

The theorem also proves integrability. Inputs are arbitrary real vectors; no unit-norm, margin, width limit, or fixed-moment-order premise is used. The constant input coordinate cancels exactly in the paired difference.

`BatchTwoContinuousPairMomentsTail.output_pair_tail` gives the corresponding probability bound at every positive output threshold `η`: the probability of an increment at least `η` is at most the displayed moment base divided by `η²`, raised to power `p`.

The proof establishes the exact Gaussian law of independent linear rows, applies tanh's unit Lipschitz bound, integrates successively over the actual Gaussian layer split, and finally uses the actual hidden/readout product factorization. Its Gaussian norm estimate is the separately proved `GaussianNormMoments.gaussian_norm_power_lintegral`; it includes zero-variance and singular-input cases.

The hidden-state iteration, output lintegral bound, real moment bound, and probability bound all compile and their axiom reports contain only `propext`, `Classical.choice`, and `Quot.sound`. These are finite-network numerator estimates for the continuous depth lower-bound argument; the final posterior lower bound additionally needs the separately proved target/interpolation denominator and the moment-order optimization.

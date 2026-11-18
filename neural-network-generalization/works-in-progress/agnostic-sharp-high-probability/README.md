# Sharp high-probability Bayesian neural-network oracles with bounded output variation

Standalone manuscript, 18 November 2026. Proposed publication slug: `agnostic-sharp-high-probability`.

The PDF is `paper.pdf`; editable LaTeX is in `source/`. Run `./build.sh` from this directory to rebuild the paper.

The learner has one fixed hidden layer, bounded Lipschitz activation (tanh in the coefficient-free corollaries), native independent Lévy incoming weights, and a signed beta-prime product readout conditioned on l1 norm at most one. This support restriction makes raw outputs bounded; there is no final clipping. The teacher readout obeys the same variation bound. The ordinary posterior uses all observations at fixed Gaussian variance `1024(1+σ²)`.

At every prescribed finite width `N≥8C`, the posterior average risk and its mean have a coefficient-one high-probability oracle with remainder of order `s C(d+1) log(dBCn)/n + C/N²`, plus `s log(1/δ)/n`. The width term is absorbed into the fast rate when `N≥sqrt(n)`. The same posterior has a slower width-independent oracle at every `N≥C`, adding a term of order `sqrt(s d log(n)/n)` to the logarithmic comparison cost divided by `n`. Same-width tanh feature compactification removes incoming coefficient bounds on Boolean inputs and on slab-regular continuous domains. It preserves the readout variation restriction.

The fast proof uses randomized pair merging, approximate midpoint transport at additive KL cost, direct prior localization, and an explicit doubled-temperature relative-loss inequality. The all-width result uses the Rademacher complexity of the l1 convex hull of single tanh features. The transport, statistics, direct localization, coefficient-free refinements, and all-width argument received independent mathematical review. Final review records and exact source hashes are in `verification/`.

This is a separate, restricted-prior theorem. It does not upgrade the unrestricted multilayer clipped-output paper to a sharp high-probability statement. No computational-efficiency claim is made.

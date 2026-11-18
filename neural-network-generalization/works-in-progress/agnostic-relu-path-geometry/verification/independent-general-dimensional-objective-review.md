# Independent dimension-explicit empirical-objective review

18 November 2026 — agnostic_proof_audit.

GD1–GD2 pass. With first-layer covariance nu/d and readout covariance nu/N², the weighted energy is Q=(d/N)sum||w||²+Nsum v² and P=sqrt(d)sum|v|||w||<=Q/2. The normalized ridge d^(-1/2)(theta dot xbar)_+ has envelope at most sqrt(2). Balancing an amplitude c as stated realizes exactly that normalized ridge and has energy2|c|.

Compact signed-atom optimization gives a global empirical path minimizer with at most n atoms. Its empirical risk is at most one and its mass at most1/(2lambda). A Gaussian tube around the balanced center has mean-shift entropy omega P* and covariance cost at most(d+2)N log(1/epsilon). The incoming perturbation and readout perturbation estimates are uniform in d because ||xbar||²/d<2. At epsilon=(lambda nu/(d+1))², the risk perturbation is O(lambda nu), yielding the stated upper free-energy comparison.

The exact energy exponential moment has chi-square dimension(d+2)N. Entropy therefore yields coefficient2lambda t on posterior expected path mass and remainder(d+2)lambda nu log(1/(1-t)). Radial integration by parts gives E Q=(d+2)nu-(2/lambda)E P_n[z(z-Y)]<=(d+2)nu+1/(2lambda). With1-t=lambda nu, the lost coercivity is O((d+2)lambda nu). This proves GD1; the same strictly convex training-vector argument as PR4 gives GD2 and the posterior-mean version.

The claims concern empirical objectives and training predictions only. The one-dimensional fiber identity and range obstruction are not asserted in higher dimension, and no new population-risk guarantee is claimed.

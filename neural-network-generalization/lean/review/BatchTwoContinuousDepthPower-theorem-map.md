# Finite-exponent continuous-depth lower bound

Paper: `works-in-progress/continuous-depth-lower-bound`, finite-exponent main theorem.

The proof uses the same fixed nonatomic input law on the unit circle, literal width-three bounded-weight tanh teacher, tolerances `1/8` and `1/4`, and full posterior-confidence failure criterion. There is no global-margin conditioning.

* `BatchTwoContinuousDepthPowerMain.finite_power_depth_lower_bound`: one measurable sample event of probability at least `49/50`; uniform conclusion at all widths above an explicit threshold and all positive scales `σ²≤N^-(1+ζ)`.
* `power_prior_depth_lower_bound`: the same statement for the literal `ConcreteModel.powerPrior`, uniformly over every `γ≥1+ζ`.
* `BatchTwoContinuousDepthPowerWidth.widthThreshold`: an explicit polynomial in the memorizer width and depth, for each fixed `ζ>0`.
* `BatchTwoContinuousDepthPowerWidthGrowth.widthThreshold_polynomial`: after the proved `M_n≤10^25 n^23`, a genuine polynomial in sample size and depth of degree `161*ceil(1/ζ)`.
* `BatchTwoContinuousDepthPowerManuscript.finite_power_manuscript_depth_lower_bound`: the manuscript's original depth index `R`, sample range `n≤exp(R/100)`, teacher/learner depth `R+1`, and sample probability lower bound `49/50`, with a universal depth threshold and polynomial sufficient width.

The proof differs from the manuscript's Gaussian-isoperimetry approximation route. An actual gain-`7/5` inverse-channel memorizer has energy at most `(49/25)r+5` and readout energy exactly one. Sharp cloning adds at most this one readout unit. The translated symmetric cylinder gives actual Gaussian training mass at least `exp(-K/(2σ²)-N*P)`. The cylinder entropy `P` is polynomial jointly in depth and sample-resource size; its derivation retains the logarithm of the exponentially small stability radius.

Actual high moments of paired neural outputs yield prior probability at most `exp(-(11/10)*(r+2)/σ²)` for an output change of at least `1/2` between the paired inputs. This beats the sharp memorizer denominator once the polynomial width threshold holds. Conditioning then bounds the posterior probability of the change, and the measure-preserving input pairing forces confidence-error mass at least one half. The argument handles arbitrary posterior mixtures.

This verifies the finite-exponent main theorem with a different polynomial threshold. It does not verify the manuscript's separate stronger intermediate approximation-ceiling lemma or its displayed isoperimetric threshold formula. Those are not assumptions of the final Lean theorem.

# Independent asinh-readout compiler interface review

Reviewed 18 November 2026 against the exact source in the companion hash manifest.

The reviewer authored the imported generic log-moment raw-posterior theorem; that generic theorem has separate independent reviews by three other agents. This review independently checks the compiler owner's instantiation and resource substitutions, rather than claiming an independent audit of the reviewer's own generic theorem.

The scaled digital encoding has readout factor centers in a prescribed interval of size O(M), whose asinh-Gaussian density cost is exp(O(M)). Its readout has only O(log n) selected factors, so this cost is additive and independent of the original teacher width. The Dirichlet placement cancellation, inactive weighted-sum conditioning, entropy partition bound, and supported raw range all check. The resulting population approximation can be inserted directly into the sample-independent supported-law raw oracle.

For bounded conditional mean, clipping the comparison at range one cannot increase risk. For merely marginal sub-Gaussian labels, the displayed pointwise clipping inequality is valid even without a bound on the conditional mean. The range O(sqrt(log n)) gives negligible label-tail loss, an additive n^(-1+o(1)) scalar cost, and remains below the analytical O(log n) cutoff. The compiler resource substitution and the growing-width/depth example retain the previously stated minimum-depth and compiled-width requirements.

No substantive gap was found. The actual posterior and returned mean are raw and use all observations; the prior is fixed and full support. The theorem uses temperature of order log-squared sample count, not fixed observation variance, and is an expected-risk statement.

Final hypothesis clarification checked: in the bounded-conditional-mean expected statement, direct marginal sub-Gaussian labels suffice; conditional sub-Gaussian noise was used only to imply that marginal condition. The updated exact source is included in this hash record.

## Confidence and eventual-calibration addition

The companion `asinh-confidence.tex` was checked against the generic marginal-label confidence theorem. The comparison remains the one constructed for the original input law, so the analytical label conditioning does not impose a new regularity condition. The common PAC--Bayes event covers all supported comparison laws at each prescribed architecture, which justifies the comparator infimum but does not imply a common event over all widths. Polynomially small confidence levels retain logarithmic cutoff factors. Taking eta=n^(-1/4), teacher width n^(1/(4bh)), and the stated learner-depth/width range gives the exact-leading-one high-probability gap of order n^(-1/4), up to logs; the additive n^o(1) readout cost is smaller. The multiplicative slack is absorbed using the zero comparator's finite risk.

The eventual expected-temperature schedule can be fixed using only native prior constants. For every finite marginal sub-Gaussian label envelope, all required label-tail, inverse-evidence and comparison-range inequalities hold eventually; the onset and risk constants are correctly allowed to depend on that unknown envelope. No finite-sample noise-independent constant is claimed.

The final density-display reflow is included in the exact manifest. No substantive gap found.

Final scalar-family remark checked: logarithmic moments and the compact-interval density lower bound are precisely the two interfaces used in the proof. The law arsinh(Z/2) has negative-log-density second derivative 4 cosh(2u)-sech²u>=3. The density proportional to exp[-a cosh(bu)] has double-exponential tails, the required interval entropy bound, and second derivative ab² cosh(bu)>=ab². These scalar statements do not imply joint log-concavity of the hierarchical network prior; the source makes that distinction explicit. The established sinh-normal naming convention is also stated explicitly. The exact concrete theorem is unchanged.

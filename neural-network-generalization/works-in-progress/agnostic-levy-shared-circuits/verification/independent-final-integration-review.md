# Independent shared-circuit integration review
All six sources pass exact integration review. The construction modules match their separately reviewed versions. The scalar and all-data expectation modules reproduce the previously audited scalar interface and arbitrary-prior leave-one-out theorem.

The shared-circuit statistical resource follows by choosing uniform first-moment accuracy 1/(4(n+1)); the bounded regression function makes the averaged population-risk increase at most four times that function error even with unbounded labels. The comparison entropy therefore has exactly the displayed J log N, E1 log(d+1), and Q H logarithmic precision costs. The stable-row resource uses the permitted precision cutoff and retains only logarithmic depth dependence per edge.

Dense comparator counts, the formula-versus-shared minimum, and growing-width/depth specializations are valid. For the formula alternative the large-width branch embeds the unrolled formula, whereas the small-width branch uses E,V<=S and log N<=log(2(S+1)). The original graph's width suffices. The ordinary fixed-temperature posterior is unchanged when taking the infimum of deterministic comparison bounds.

Scope remains precise: coefficient-one expectation over IID samples, one fixed architecture before data, all observations, bounded link inside likelihood and prediction, arbitrary conditional sub-Gaussian noise around a bounded regression function. General shared circuits retain logarithmic learner-width dependence; formulas remove it.

This is an independent mathematical source review, not a Lean verification.

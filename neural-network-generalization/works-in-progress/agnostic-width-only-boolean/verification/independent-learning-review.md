# Independent review: coefficient-free Boolean-domain Gaussian oracle

The exact learning.tex source passes independent mathematical review on 18 November 2026. This is not a Lean verification.

Checked: the independent Gaussian normalization; bounded final activation in both likelihood and prediction; the imported full-energy and saturated direct-compression certificate interfaces; common events for widths and scales; the path-flow rescaling and exact energy E=2P+(H-1)m; selective Gaussian KL and RMS perturbation; positive-temperature parameter-count certificate; measurable free-energy selection; small/large learner-width split; coefficient-free compiler resource substitution; and the displayed sample powers.

The parameter-count budget is dominated by the implicit-prior budget because v>=2, rho>=1 and v-rho>=1. This verifies the guarantee at every N>=C+1, rather than only widths that fit the compiler. The learner depth has the explicitly stated constant-factor overhead relative to the comparison depth. The final saturation is part of the observation model, not merely postprocessing. No mathematical gap found.

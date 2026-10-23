# Statement review: improved bounds with the original robustness support

Reviewed 22 October 2026 against `works-in-progress/improved-polynomials/original-support-all-scales/source/learning-theorem.tex`, `explicit-budget.tex`, and the actual definitions and endpoints in `BatchTwoImprovedLearningMain`, `BatchTwoImprovedLearningWidthGrowth`, `BatchTwoImprovedLearningPolynomial`, and `BatchTwoImprovedLearningGlobalPolynomial`.

The headline learning theorem, fixed-parameter `C^6 log^13(C+2)` rate, and universal degree-46 sufficient bound match the formal statements. The formal conclusion is slightly stronger in giving Gibbs margin risk at most `ε/3`, hence confidence-error mass at most `ε`. The following details were checked separately from the fact that Lean accepts the proof:

- `LayeredBooleanCircuit d C r` represents the specified circuit, with constant wires counted and `r+1` hidden stages. The network depth is `L=r+2`.
- The literal prior variances are `t²/d`, `t²/N`, and `t²/N²`; the event is common to all `N≥C` and `0<t≤1`, and therefore to every `γ≥1`.
- The support condition is exactly finite simultaneous additive postactivation/readout perturbation, with squared RMS budget, output clipping at `±1/2`, tolerance `1/16`, and radius `c/sqrt(1+(L−1)E_v)`. It is not replaced by an infinitesimal derivative condition, average Gaussian stability, or a neuron-merging hypothesis.
- Training imposes strict signed output greater than `1/2`. Test error uses signed output at most `1/4`. The posterior is the actual conditioned Gaussian law and has positive normalization.
- The main theorem requires no global clean-output margin. The separately proved optional variant conditions additionally on that event.
- The polynomial is independent of learner width and Gaussian scale. The fixed-width-exponent constant may depend on the fixed depth, input dimension, calibration, and accuracy, as in the manuscript.
- The final learning endpoints do not assume a compression, concentration, or target-mass theorem as an unproved hypothesis. Those ingredients are constructed in the imports.

**Numerical scope.** This review does not certify the particular allocation of constants in the manuscript's separate explicit-budget section, including its displayed `16/ε` formula. The checked construction has larger internal constants and an explicit `200/ε` entropy budget. It proves the headline theorem and the same two claimed asymptotic exponents; it does not establish equality between the two numerical resource formulas. The theorem map records this exclusion.

This was a second statement review, not a wholly independent reimplementation: the reviewer also contributed the terminal-sampling variance helper used by the proof. The main compressor, resource growth, and learning assembly were written by other agents.

Axiom checks of `all_width_all_scale_learning`, `all_width_six_thirteen_learning`, and both versions of `universal_polynomial_depth_learning` report only `propext`, `Classical.choice`, and `Quot.sound`. These checks were run against the compiled sources; the separate collection verification record records the final clean build.

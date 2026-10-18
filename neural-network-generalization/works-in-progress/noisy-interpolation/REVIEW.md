# Mathematical review record

18 October 2026. This records independent AI-agent checks of the [research note](README.md). It is not human peer review, a Lean formalization, or an addition to the five formally verified main learning results.

The construction, capacity argument, and posterior transfer were developed and checked in separate agent workstreams. Multiple agents then reviewed the assembled proof. No substantive gap remained in the version published with this record.

The checks covered:

- **The exact learner.** The weighted Gaussian energy, all-input margin conditioning, fixed-width strong-prior limit, and exact fitting of corrupted labels agree with the model stated in the note. No soft likelihood, posterior mean, or favorable choice among tied minimizers is used.
- **Sparse correction.** Parseval's normalization, the central-binomial parity coefficient for both odd and even parity sizes, the exact Walsh projection of tanh features, the constant feature, and the feature-sampling error and width all check out.
- **Every adequate width.** The correction uses balanced copies of its features; the clean teacher uses uniform copies and zero padding. The readout energy is measured at the full learner width. The scalar chain's cubic approximation errors sum geometrically, preserving a strict margin at every cube input.
- **Capacity.** The variable clipping threshold is included inside the supremum. A direct coordinate argument verifies the factor-one scalar contraction inequality. The mixture identity for normalized tanh, zero-path nodes, first-layer halfspace count, and absolute-path energy bound are compatible with the union over all widths.
- **Matching exponents.** Correction energy grows as a constant plus a multiple of $(s+1)^{1/(L-1)}$; the logarithmic function count grows as energy to power $L-1$. Weighted convexity keeps the coefficient of $s$ polynomial in depth, although the additive sample budget can depend badly on depth.
- **Probability and quantifiers.** The hypergeometric lower-tail estimate applies to uniform sampling without replacement. Its event covers every allowed corruption set and width. Gaussian small-variance rates control all higher-energy functions, so posterior mixtures and unattained strict-margin energy infima are handled.
- **Bounded-output circuit teachers.** The constant wire, first-layer offsets, later-layer offsets, repeated-input gate simplification, saturated signal intervals, and final linear readout give output magnitude at most one without an uncounted extra hidden layer.
- **Limitation of the global count.** A separate research check identified the class of all exact $s$-point modifications, which forces at least $\binom{2^d}{s}$ functions into the common energy sublevel. The elementary counting lower bound was checked independently and is explicitly presented as a limitation of this proof route, not a sample lower bound for the learner.

Final review also corrected minor presentation issues: positive sample size, the condition $n<2^d$ for unseen-point error, exact versus strict constant-wire margins, an inline-math delimiter, and explicit treatment of a zero output path norm. The independent-flip corollary now states that its posterior is guaranteed to exist on the good event; the larger width threshold based on $s=n$ ensures feasibility for every flip realization.

The remaining research question is substantive: the coefficient of the noise rate still depends on dimension. These checks do not establish a dimension-independent noise envelope, a variance threshold uniform in width, a theorem for other sampling laws, or efficient posterior computation.

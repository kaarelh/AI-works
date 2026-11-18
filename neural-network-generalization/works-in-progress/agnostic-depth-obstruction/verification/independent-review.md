# Independent review of the fixed-accuracy exponential-depth theorem

Reviewed all five source modules and the assembled main statement on 18 November 2026. No substantive gap was found. This is a conventional mathematical audit, not a Lean formalization.

The Gaussian-feature kernel lower bound, finite-feature interpolation, inverse-tanh construction, nearly minimal weighted energy, and covariance-preserving small-noise comparison were audited independently in their source modules. The assembled theorem correctly uses their uniformity over every sufficiently large width and all s<=N^(-1-kappa).

The operator-entropy inequality has only linear-width correction and retains the same deterministic output floor. The posterior variational reduction includes both the prior zero comparison and the same-covariance memorizer comparison. The two-comparison segment lemma and common linear witness were checked algebraically; they avoid the invalid inference that mixtures of inaccurate predictors must be inaccurate.

The assembled constants are valid: t=a=2^-24, Lambda=2^16; q/K can approach one closely enough to give 1-q/K<=2^-18; comparison and entropy errors are each <=2^-20; the resulting segment distance is <1/256. The singleton/noise-alignment events give minimum signal/noise energy >=1/64, alignment <=1/512, and witness norm <=1. The common empirical witness therefore exceeds 1/128. Uniform occupancy bounds give population witness squared norm <=4, yielding excess >=2^-16 exactly.

Large-temperature readout conjugacy controls both the raw mean and mean of clipped draws. The clipping arguments are valid because empirical atom means lie in [-1,1], and clipping fixes every point on the segment {p b:0<=p<=1}. This permits clipping before or after arbitrary well-defined data-dependent mixtures. The likelihood remains the original raw-output Gaussian likelihood; no clipped-likelihood claim is made.

The same sample event covers all widths N>=exp(C_kappa H), all 0<s<=N^(-1-kappa), and all temperatures. All thresholds are deterministic. The fixed-width strong-prior consequence and the same-depth width-two realization of the one-neuron target were checked. Material scope is stated correctly: input dimension grows linearly with depth, required widths are exponential, and the canonical mean-field endpoint is not established by this theorem.

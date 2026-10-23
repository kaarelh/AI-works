# Independent audit: the deep mean-field endpoint

Date: 22 October 2026.

This review covers the mathematical arguments, not a Lean formalization.

## Components reviewed

- `common/source/paper.tex`: the scalar Lipschitz-function cover, exponential Rademacher contraction, rowwise peeling, product-norm normalization, and the resulting uniform count of globally margin-separated Boolean functions.
- `allgamma/meanfield-atoms.tex`: the RKHS minimum-norm certificate, sampling of recession atoms, transport under maximum-entry covariance perturbations, and finite ordinary ReLU/GELU realization.
- `allgamma/meanfield-closure.tex`: the one-layer approximation budgets, raw exceptional probabilities, backward choice of reconstruction tolerances, physical weight bounds, final readout, and posterior learning at every width.
- `allgamma/uniform-supercritical.tex`, together with the target cylinder and Gaussian spectral tail in `allgamma/spectral-extension.tex`: the final uniform bound for every width and every scale at least as strong as mean field.

The Gaussian bulk/tail lemma was developed in this thread and independently reviewed by the root agent and the depth-free-converse agent. Its source is `bulk-tail.tex`; the common manuscript contains a streamlined generic version.

## Findings

No substantive mathematical gap was found in the components reviewed above.

The capacity theorem does quantify over arbitrary neuron-specific Lipschitz activations, selected in any way. The finite scalar activation cover is inside the supremum before the Rademacher expectation. Consequently it applies to auxiliary tail activations of the form

\[
\psi_\delta(t)=\phi(\delta t)/\delta.
\]

This establishes a counting and learning statement for the original fixed-activation learner. For a completely general Lipschitz activation it does not establish compression into a network using that same fixed activation. The specialized ReLU/GELU atom construction does give such a realization.

In the mean-field closure, the cutoff-tail error, bulk mollification error, and entropy-certificate error each cost at most one sixteenth of the requested one-layer accuracy. Covariance transport, atom transport, and finite bulk realization leave further slack. The entropy width threshold gives an exponential tail at least as strong as the stated `exp(-N K)` bound. The backward recurrence is a fixed finite composition of polynomial reciprocal moduli, hence remains polynomial for each fixed depth.

The final readout has RKHS squared norm at most `8 K`. Approximation at accuracy `1/8` gives an evaluation coefficient vector of l1 norm at most `16 K`; the final covariance tolerance `1/(128 K)` contributes another `1/8`. Doubling the reconstructed readout therefore preserves all strict original signs with strict margin greater than `1/2`.

The simultaneous-width PAC assertion uses one common finite class at all large widths and a finite union over the remaining widths. The displayed sample budget suffices for both parts. If the result is strengthened to a continuum of prior scales, a common small-width energy class should replace a direct union over prior scales; an uncountable union is not justified.

## Uniform stronger-than-mean-field extension

The proposed two-band extension is consistent with the checked lemmas. Write the layer variances using `t = sigma sqrt(N)`, so `0 < t <= 1` is the whole stronger-than-mean-field range.

- Below a polynomially small cutoff `t0`, Gaussian spectral truncation applies at every width and gives a raw exceptional tail of order `exp(-c N K / t^2)`.
- Above `t0`, the Gaussian bulk/tail construction can use the fixed budget `K/t0^2`. Its covariance input is `t^2 Q`, whose diagonal is no larger than that of `Q`; its raw exceptional tail is stronger than `exp(-N K/t^2)`. All resource budgets remain polynomial because `t0^-1` is polynomial.
- For widths below the resulting polynomial threshold, a chi-square energy cutoff gives a common finite auxiliary class. If `D_N=N(d+2)+(L-2)N^2`, then
  \[
  R=4K+2[d+2+(L-2)T]\log 2
  \]
  gives `Pr(kappa > R) <= exp(-N K/t^2)` whenever `N <= T` and `t <= 1`.

The final integrated uniform-scale source was subsequently reviewed. Its three explicit budgets give the claimed relative exceptional-mass bounds, and its one common function class makes the training-sample event simultaneous for every width and the entire continuum of scales. No substantive gap was found. In particular the polynomial need not deteriorate as the scaling exponent approaches one.

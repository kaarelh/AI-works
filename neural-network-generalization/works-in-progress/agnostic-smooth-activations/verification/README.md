# Verification record

This is a conventional mathematical proof, not a Lean formalization. An independent AI-agent audit checked all eight active source modules and the final theorem's quantifiers. The detailed review and source hashes identify the checked version.

The main checked points are:

- conditional Gaussian concentration of the residual feature operator, uniformly over coefficients selected from the same Gaussian realization;
- the effective-width scale `N/tau^2`, including the absence of a first-layer minimum-width condition;
- exact Gram identities, vector Bessel propagation, and sampling after preceding approximants are fixed;
- separate residual-variance estimation using independent row pairs, whose scalar coefficients have second moment equal to retained rank;
- contraction of linear factor representations into subsequent coefficients, giving parameter exponents `p=H^2+2H-3`, `q=4H-2`;
- direct finite-parameter covers below the effective-width cutoff;
- sample-dependent good sets with prior bounds valid for each fixed sample, and statistical uniformity applied only to fixed dictionaries;
- evidence-root existence, localization, raw-output tail control, and coefficient-one population comparison;
- the activation class including nonzero values at zero;
- the optimistic shallow certificate, sharper monotone fixed calibration, and alternative two-hidden-layer growing-comparison calibration;
- evidence-localized finite-width PAC–Bayes clipping, spectral truncation above mean field, the full-energy branch at `gamma>=2`, and selection by actual observable certificates.

The manuscript builds with two `pdflatex` runs, without undefined references or overfull boxes. Independent AI review is evidence of checking, not a substitute for human review or formal verification.

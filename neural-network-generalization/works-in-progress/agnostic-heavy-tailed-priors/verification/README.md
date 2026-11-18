# Verification record

This paper proves oracle and online-learning theorems for one dense independent-coordinate heavy-tailed prior. It is not Lean formalized.

The independent reviews cover:

- all-width truncation bounds, unbiased designated coefficients, and the cancellation between embedding multiplicity and coordinate probability;
- pointwise second moments and mean bias, clipped-loss semiconcavity, and prior mass of function neighborhoods;
- the fixed-temperature oracle for conditional sub-Gaussian noisy regression, including unbounded observed labels;
- the complementary multiplicative bounded-loss certificate, finite temperature grid, and progressive-average corollary;
- finite-domain uniform approximation, optional all-input margin conditioning, and pathwise online log loss;
- comparable power-tailed densities, symmetric stable priors, the native Cauchy scale, and the Cauchy–ReLU obstruction.

The architecture is fixed before observing the sample. The bounded output link (tanh or clipping) is part of the network mean used in the likelihood. The online sampled-prediction guarantee assumes each query is chosen before the next prediction's fresh randomness. The main oracle's likelihood variance is fixed across sample size and width; the complementary calibrated oracle can select different temperatures through the learner's partition function.

Earlier review files describe earlier manuscript snapshots. The final integration review and source hashes identify the complete current version. No untruncated Cauchy predictive moment or Lean proof is claimed.

The PDF is built from the nine TeX files in `source/` by three clean `pdflatex` passes. `latex.log` and the three build outputs are retained. The first page has also been visually inspected. The final build contains no warnings or overfull boxes.

The added sharp expectation module proves an arbitrary-prior KL oracle for the ordinary final posterior mean trained on all observations, including conditional sub-Gaussian noise. Its expectation scope is separate from the high-probability results. The Student comparison law gives the stated sharp expected-risk corollaries.

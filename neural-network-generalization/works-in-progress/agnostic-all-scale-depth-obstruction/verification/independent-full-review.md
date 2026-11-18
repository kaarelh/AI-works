# Independent full mathematical review

The exact ten-source snapshot below passes an independent adversarial mathematical audit on 18 November 2026. This is a conventional proof review, not a Lean verification.

The review covers the complete canonical mean-field function-prior theorem and its fixed-accuracy learning obstruction, including all finite-width bridges.

Checked in detail:

- Critical scalar drift, reciprocal empirical-variance moments, exact one-input covariance feedback, sharp heat/Jensen exponential moments, and the coefficient-four amplitude cost.
- Direct unit-sphere Hermite kernel, normalized finite-feature Gram bound, nullspace-completed measurable unit seed, and exact conditional rank-one covariance KL.
- Coherence amplification, the orthogonal-defect identity, reverse-variance action, padding, all-input finite-width concentration, Gaussian readout maximum, and continuous odd prewarping of arbitrary finite functions.
- The expected maximum-square approximation statement, the matching entropy lower bound, and actual two-sided function-neighborhood probabilities.
- Supremum-norm proximal minimization and its quadratic gap; the posterior variational sandwich; small/large likelihood-temperature constants; the common negative-singleton witness; ordinary means, means of clipped draws, clipping of means, arbitrary mixtures, and clipping after mixing.
- The event common to every sufficiently large finite width and every positive temperature; shallow and same-depth bounded-width teacher implementations; the unit-input-norm and independent-noise conventions.

The main finite-function comparison has normalized entropy at most 4||f||_infinity + C A² + C(D+log H)²/H + 2log(2)/N, with arbitrary fixed expected maximum-square error at every N>=exp(C_epsilon H). Its statistical application gives excess at least a²/4096 after exp(Omega(sqrt H)) IID samples under the unchanged canonical independent Gaussian prior. The fixed numerical parameters in the application leave substantial slack: its small-temperature squared distance is below 3.3e-8 a², versus the stated 1e-6 a² threshold.

No mathematical gap was found. The result concerns noisy squared-loss regression and a growing learner depth/input dimension. It does not establish the earlier noiseless Boolean conjecture or an efficient posterior-sampling algorithm.

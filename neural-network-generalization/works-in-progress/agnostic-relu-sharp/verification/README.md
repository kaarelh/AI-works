# Verification record

The paper has conventional proofs of the positive and negative comparator-growth thresholds, including actual finite Gaussian posteriors in the stated canonical regimes. The [independent mathematical review](review.md) checked the norm-capacity argument, homogeneous balancing, exact memorizer, bounded tent teacher, all-temperature quantifiers, and raw posterior means. These results are not Lean verified or externally peer reviewed.

The negative theorem's sample event is simultaneous over temperatures, eligible widths, and the stated finite scaling exponents. Its data law varies with sample size and has logarithmically growing dimension. The equality case and the multiple-hidden-layer canonical interval `1≤γ<2` are not settled.

[Exact construction checks](check_exact_constructions.py) use rational arithmetic to verify the Fourier/ReLU representation on small cubes, its coefficient budget, and the bounded tent formulas. [Recorded output](exact-construction-check.json). These checks support the analytic proofs; they are not proof assumptions and do not simulate posterior generalization.

Run `./build.sh` from the paper folder for a two-pass pdfLaTeX build. The source build has no unresolved references, warnings, or overfull/underfull boxes. [Build record](build-record.json).

The localized-noise corollary keeps unit signal and noisy-label amplitudes while reducing their input probabilities. Its constants and simultaneous-parameter scope were independently checked; it does not assert a fixed excess as noise tends to zero.

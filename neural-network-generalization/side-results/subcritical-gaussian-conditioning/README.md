# Gaussian conditioning below the mean-field scaling: a sharp fluctuation threshold

**Status:** Proved side result

Proves relative conditioned-Gaussian approximation for 0 < gamma < 1/2 and an actual tanh counterexample at and above gamma = 1/2. Gaussian leading rates remain valid throughout 0 < gamma < 1, but higher-order feature fluctuations can change >2/3 posterior-confidence outcomes.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/subcritical-gaussian-conditioning.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.

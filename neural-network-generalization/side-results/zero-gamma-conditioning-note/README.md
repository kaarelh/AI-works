# Global-margin conditioning at the Gaussian endpoint: normalization, training loss, and output amplitude

**Status:** Proved side result

This note proves conditioning-cost, latent training-loss, and actual-output amplitude estimates for the globally margin-conditioned Gaussian posterior at prior-scaling exponent gamma = 0. These estimates support the study of that endpoint, but do not by themselves establish confidence failure.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/zero-gamma-conditioning-note.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

## Review record

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.

# A certified margin-repair bound for cubic parity predictors: one arbitrary bit, twenty-six symmetric bits, and parity-block lifts

**Status:** Earlier complete side result; extended by structured-parity-repair-certificates

Exact rational certification for a cubic family on 27 bits, with one arbitrary coordinate and 26 symmetric coordinates, and parity-block lifts. The later structured paper expands the class and adds quartic results. Includes a reproduction archive.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/cubic-parity-repair-certificate.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.

## Reproduce the exact certificates

[Download the verification scripts and rational certificate data](cubic-parity-certificate-repro.zip). The archive includes its own README and instructions; extracting it is not needed to read or rebuild the paper.

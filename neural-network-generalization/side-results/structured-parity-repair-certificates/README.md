# Certified margin-repair bounds for structured parity predictors: cubic and quartic heads, exact certificates, and parity-block lifts

**Status:** Proved side result

This paper proves analytic repair inequalities and gives exactly verified rational certificates for specified cubic and quartic structured sign-pattern families, including 49,149 sign-cone orbits. Reproduction scripts and certificate data accompany the paper.

The results apply to a fixed repair model. They do not establish a general posterior sample theorem.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/structured-parity-repair-certificates.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

## Review record

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.

## Reproduce the exact certificates

[Download the verification scripts and rational certificate data](structured-parity-certificate-repro.zip). The archive includes its own README and instructions; extracting it is not needed to read or rebuild the paper.

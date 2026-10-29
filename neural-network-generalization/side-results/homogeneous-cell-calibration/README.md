# Homogeneous parity approximants have a strict local repair cost

**Status:** Proved side result

In the fixed-background anchored cusp model, margin-one heads supported on a single Walsh level of degree at most k/5, with parity error at most 0.34 and k>=2400, have mean repair cost at least 2/5 above the constant-background benchmark. Includes weighted-homogeneous, affine, and two-level extensions. This is not a general adaptive-posterior sample theorem.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/homogeneous-cell-calibration.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.

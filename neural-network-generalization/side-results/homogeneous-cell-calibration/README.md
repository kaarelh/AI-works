# Homogeneous parity approximants have a strict local repair cost

**Status:** Proved side result

This paper proves a strict margin-repair cost in the fixed-background anchored cusp model. A margin-one head supported on a single Walsh level of degree at most k/5, with parity error at most 0.34 and k >= 2400 parity coordinates, has mean repair cost at least 2/5 above the constant-background benchmark.

The paper includes weighted-homogeneous, affine, and two-level extensions. These repair-model estimates do not constitute a general adaptive-posterior sample theorem.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/homogeneous-cell-calibration.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

## Review record

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.

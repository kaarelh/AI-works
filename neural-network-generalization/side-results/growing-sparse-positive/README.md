# Exponential sample lower bounds for sparse parity under a globally separated neural prior

**Status:** Proved side result; conventional proof, not Lean verified

For prior-scaling exponent 0 < gamma < 1, this paper proves confidence failure for growing sparse parity at every specified sample size n <= exp(c max{k,sqrt(k) log(e(d+1)/sqrt(k))}). Here k is the number of parity coordinates and d is the input dimension.

This gives an exp(Omega(k)) obstruction. The paper also gives an upper bound at the natural scale exp(O(k log(ed/k))). The lower bound matches that scale when k/d is bounded below; the full natural sparse lower bound remains open.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/growing-sparse-positive.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

## Review record

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.

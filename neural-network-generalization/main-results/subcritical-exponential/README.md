# Exponential parity sample complexity throughout the subcritical width regime

**Status:** Main result

For every fixed gamma < 1 and fixed depth, full parity in dimension d requires exp(Omega(d)) samples under uniform IID training and the width-first posterior. For each n <= exp(c d), confidence failure is at least 1/16 with sample probability at least 3/4. This is the full-parity exponential result, not the still-open fixed-depth natural sparse-parity scale exp(Omega(k log(ed/k))).

[Paper (PDF)](paper.pdf) · [LaTeX source](source/subcritical-exponential.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF is the existing manuscript copied into this collection; its mathematical text has not been rewritten for publication here. Later results and current scope are summarized in the collection index.

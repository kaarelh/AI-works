# Softplus companion assembly record

26 October 2026. This is an assembly and self-check record, not an independent
audit and not Lean verification.

The seven-page manuscript `manuscripts/softplus-shallow-posterior.tex` assembles
the independently audited `softplus-positive-channel-transmission.md` into a
supporting companion to `logistic-shallow-posterior.tex`.

Final source SHA256:
`5e4c97a56bd22fa82babe99fd807f660e8e7e4cc80f8f926d8e25dc843554ade`.

Built PDF SHA256:
`8198dc61109b9048febdb1800730904a6ef691a5589d5c1f0fdc0a6d73ec81d6`.

The only imported representation input is the logistic companion's
self-contained all-layer Lipschitz cover. The softplus manuscript supplies
its own positive-channel construction and energy accounting, polynomial
operator stability, Gaussian shift/isoperimetric posterior ratio,
frozen-anchor subtraction, unbounded-activation finite-width net, cold-limit
argument, confidence conversion, and explicit shallow parity witness.

The first-layer allocation is made concrete by taking
`k=floor(N/(2 M0))` copies per teacher row, for `N>=4 M0`. This leaves at
least half the coordinates as exact `log 2` constant neurons, bounds the
weighted shallow readout energy by `4 T`, and supplies a common wire based
on that upper bound. All constant-channel and final subtraction costs are
included. For the fallback at smaller widths, balanced cloning from the
original teacher followed by exact complementary relays gives energy
polynomial in the teacher resources and depth, independently of width.

The theorem retains the precise depth condition
`L-1 >= c0 log^2(T+2)`, the one-hidden-layer bounded-weight teacher
hypothesis, and the fixed-architecture meaning of a cold limit. The
finite-scale result assumes each fixed exponent `gamma=1+zeta>1` and
does not cover critical `gamma=1`, fixed positive canonical prefactors,
or arbitrary deep teachers. The original tanh question remains open.

Build: `latexmk -pdf -interaction=nonstopmode -halt-on-error
softplus-shallow-posterior.tex` in `manuscripts/`. The final LaTeX log has no
warnings or overfull/underfull boxes. `pdfinfo` confirms seven pages;
`pdftotext` confirms the expected author names and mathematical statement.

The independent finite-n audit read the assembled manuscript and found one
literal `quad` typo, now corrected. It also observed that the proof is
distribution-free; the manuscript intentionally retains the uniform-cube
statement rather than enlarging the requested theorem's scope.

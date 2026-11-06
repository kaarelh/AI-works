# Deep linear appendix verification

Source: `/workspace/isotropic-online-2026-11-05/selector-linear.tex`.
Status: conventional proof; not Lean formalized.

The author checked the matrix dimensions, weighted norm inequality, exact
rank-one equality construction, Gaussian function-cell rate transfer,
bounded teacher, and C_L=2 lower obstruction. A separate agent,
`isotropic_gadget`, independently reviewed the entire source and reported
PASS on all of these points.

The layer variance convention was checked directly against the original
strong-prior paper's source, `main-results/strong-prior-generalization/
source/paper.tex`, equations near lines 78--94: first-layer variance
N sigma^2/d, intermediate variance sigma^2, and readout variance sigma^2/N.
Thus the appendix retains that parameter prior exactly; it changes the
activation to the identity.

The exact matrix-factor energy is L(d||A||^2)^(1/L), because the product of
layer energy coefficients is d. For a Boolean function at weak margin 1/2,
||A||^2 minimizes to Q/4. Strict and weak margin energy infima agree by
readout scaling. The resulting function energy is strictly increasing in Q
and independent of width N. This proves the same minimum-function prediction
sequence for every fixed width, while allowing the sufficiently-small scale
threshold to depend on width.

The result is expressly not a wider-tanh theorem. Identity activation keeps
the entire represented function class affine; wider tanh does not. The
appendix ends by identifying the latter question as unresolved.

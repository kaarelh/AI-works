# Independent audit: supercritical scalar baseline deficit

26 October 2026. Auditor: `/root/fresh_canonical_depth`.

**PASS** on `supercritical-scalar-baseline-logarithmic-gap.md`, SHA256
`d3b22ee34250964b0ee24edb1b843131db6c28c770a5624cedd5388b6a7248a0`.

The monotonicity proof rescales scalar laws and their reference variances
together, preserving KL and increasing all subsequent states. The
comparison V_t(q)<=V_1(q) for t>=1 uses exactly the same coupling and
also lowers the actual readout cost. It proves existence and finiteness
of the boundary limit without assuming a supercritical Bellman theorem.

The free-growth lower bound follows from sinh(z)^2>=z^2 and weighted
Cauchy--Schwarz, yielding F(u)>=u/(1+3u). Before the first crossing of
delta/12, the multiplicative gain is at least1+delta, and the crossing
state is at most delta/6. This prefix is finite for every positive
starting q but is allowed to grow as q approaches zero; the note does
not infer fixed-depth target mass from it.

The imported short increasing critical path has length C/p and final
variance >1/24, with all constants independent of p. The exact Gaussian
reference identity has the correct sign and includes the common readout
prefactor. The elementary inequality M_j-1>=log(q_j/q_(j-1)) gives a
logarithmic cumulative reference saving; m c_t is only O(delta).
Together these prove the stated coefficient-one bound without numerical
inputs. In particular V_*-V_t^* is not O(delta) as delta approaches zero.
The coefficient two suggested by formal local optimization is not
proved or asserted by the note.

Scope is correctly scalar variational comparison only; no posterior,
finite-width, vector-target, or canonical-depth resolution is inferred.

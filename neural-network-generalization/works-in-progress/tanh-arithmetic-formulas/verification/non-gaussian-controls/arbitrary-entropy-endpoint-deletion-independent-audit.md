# Independent audit of arbitrary final-tilt deletion

25 October 2026. Audited arbitrary-entropy-endpoint-deletion.md.

**Verdict: PASS.** The proof applies to any reference probability measure,
any absolutely continuous finite-entropy row law, and any uniformly bounded
feature family. It does not require an optimized endpoint.

The nonnegative entropy integrand gives exactly the tail denominator
log M-1+1/M. With u=D(V/eta)^2 and s=24(sqrt(u)+u), the two elementary
lower bounds on s-1+exp(-s) imply a denominator at least 4u. The truncated
readout has squared reference norm at most M V^2, and the Cauchy--Schwarz
output error is uniformly at most eta/2. This verifies the stated
exponent 12[sqrt(D)V/eta+D V^2/eta^2].

The D=0 case is handled separately and correctly has no cost or margin
loss. The argument is uniform over arbitrarily many queries, without a
union bound. Its final scope statements correctly distinguish a
representation replacement from action preservation and from an internal
layer replacement.

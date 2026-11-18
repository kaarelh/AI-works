# Independent review of the output and soft-prior extensions

Reviewed by the robust-prior research agent on 18 November 2026. This is mathematical review by a separate AI agent, not Lean verification.

The reviewed `source/extensions.tex` is consistent with the full-support soft-path prior theorem. The unit-ball feature has dimension D=d+1, so the normalization omega=N(D+1)+(H-1)N^(gamma+1) counts the two endpoint blocks correctly. Conditional endpoint variances are divided by the internal gain G, and the normalized chi-square degrees of freedom are at most one.

Final saturation preserves every step used by the implicit certificate: output symmetry, the prior-risk bound, the energy-ball contraction bound, and the comparison perturbation estimate. It also permits the finite-parameter certificate because the prior has positive density everywhere. The minimum-certificate rule therefore covers all learner widths at least the original teacher width plus a constant wire; its statistical event is independent of the prior exponent. The explicit width/depth polynomial conservatively dominates both the compiled path branch and the finite-parameter branch.

The final-tanh variant is valid for the stated final-tanh comparison class. Truncating the raw comparator at logarithmic amplitude changes its tanh output by the required tolerance; compiling the rescaled comparator and rescaling its readout adds only logarithmic path cost. Tanh is odd and 1-Lipschitz, and its strict monotonicity preserves the relevant pseudodimension bound. No substantive gap was found.

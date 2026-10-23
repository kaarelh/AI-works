# Independent audit of the path-norm alternative

Reviewed on 22 October 2026 by an independent AI agent. This is ordinary mathematical review, not Lean verification. The scope is `norm-conditions.md`, including its ReLU theorem, Boolean formula compiler, GELU capacity variant, and scope discussion.

## Verdict

No mathematical defect was found. The ReLU theorem gives a quadratic dependence on a declared absolute path-norm budget, with polynomial depth dependence, for every learner width above a feasible teacher width and every positive Gaussian scale. The compiler supplies a path budget linear in Boolean **formula** size. It does not establish that every small Boolean circuit has a polynomial path budget. These distinctions are explicit in the note.

The hard budget is a prior hyperparameter fixed before observing labels. Thus the conclusion is a norm-constrained hypothesis-class guarantee, not automatic adaptation to unknown target complexity under the original unrestricted Gaussian prior. The entire restricted function class has low capacity, so positivity of a target neighborhood is sufficient; a quantitative Gaussian target-mass estimate is unnecessary.

## ReLU normalization and capacity constants

The recursively defined incoming path masses p_j give h_j/p_j=ReLU(sum_i A_ji h_i/p_i), where sum_i |A_ji|<=1. Zero-path-mass neurons are identically zero. The normalized features are bounded by one on the input cube, and the final absolute coefficient sum is the network's path norm.

For the scalar feature classes formed by ReLU applied to absolute convex hulls, the exponential contraction inequality gives E exp(a Z_s)<=2 E exp(a Z_(s-1)). A supremum over an absolute convex hull equals the absolute supremum over its generators. At the input layer, the two signs and d+1 coordinates give the moment bound 2(d+1)exp(a^2 n/2). Iterating H hidden layers therefore gives D_L=(H+1)log2+log(d+1)=L log2+log(d+1). Jensen and optimization yield the displayed R sqrt(2D_L/n) bound, with no width factor.

Strict margin shattering implies Rademacher complexity at least one half. The ceiling ceil(8R^2D_L) is therefore a valid VC upper bound. Sauer's lemma gives the stated common full-cube function count, including when the VC upper bound exceeds the domain size. The finite-class union bound yields the sample denominator epsilon, rather than epsilon squared, because the posterior is exactly consistent.

## Positive conditioning events and scale uniformity

Cloning preserves the output and the absolute path norm for arbitrary positive integer population sizes. Zero padding is also valid. A strict teacher margin and strict path budget define a nonempty open parameter neighborhood at every larger width. Every full-support Gaussian, or every everywhere-positive continuous density, assigns positive probability to it. The prior and all noiseless posterior normalizers are consequently positive.

The statistical event depends only on the common finite class of Boolean functions. It is therefore simultaneous over widths, scales, and the stated choices of base density. The positivity argument requires strict inequalities; if a teacher has path norm equal to the cap but strict margin, a small readout decrease supplies the needed slack.

## Boolean formula compiler

An input bit has path mass one; a constant wire has mass one. COPY preserves it, NOT increases it by at most one, and NOR has mass at most one plus the two source masses. A tree with s non-COPY gates has at most s+1 leaves, so its output bit has path mass at most 2s+1. The signed readout 2b-1 has path norm at most 4s+3. Copy chains do not change these recurrences, and sharing the constant-one chain is already accounted for by the offset term at each gate.

For a layered formula of width C and H stages, with constant wires and layering overhead counted, s<=CH. The declared cap R=4CH+4<=8CH produces the displayed O(C^2 L^2 [L+log(d+1)] (d+1)/epsilon) sample term. A reused intermediate value in a general DAG can appear repeatedly in the unfolded path recurrence; ordinary circuit gate count does not justify the formula bound. The note correctly presents this as a limitation of the available compiler rather than a function-level lower bound on minimal path norm.

## GELU variant

Let p_j^s denote the ordinary path mass. Normalizing a hidden coordinate by lambda^s p_j^s gives incoming absolute row sum one and activation psi_a(u)=GELU(au)/(lambda a), with a=lambda^(s-1)p_j^s. The final coefficient budget is lambda^H times the ordinary path norm, exactly as declared.

The two limiting activations approximate the ranges a<=eta and a>=eta^(-1) uniformly on [-1,1]. On the remaining range, the derivative with respect to log a is bounded by one. The stated scalar cover size 8 eta^(-2) is valid. Applying the contraction recurrence with that finite cover and eta=1/n gives the displayed H/n plus square-root bound. At n=ceil(4096(R+1)^2 D log(16(R+1)^2D)), the logarithm estimate and both terms are comfortably below one half, so the proposed VC ceiling is conservative and valid.

The resulting guarantee is quadratic, up to a logarithm, in the **adjusted** path budget. The lambda^H factor is explicit and can be exponential in depth. No polynomial-budget GELU Boolean compiler is claimed. GELU cloning preserves function and ordinary path norm even though arbitrary node rescaling does not preserve its function.

## Other checks and limits

Multiplying the expected absolute Gaussian weight along each of the (d+1)N^H paths gives the displayed expectation proportional to t^L N^((L-2)/2). This is correctly described as an expectation calculation, not a concentration result or posterior lower bound.

The discussion distinguishes path norms, Frobenius products, spectral products, and effective-rank factors. The cited literature is contextual support; the capacity and learning arguments audited here are supplied in the note itself. No empirical claim about ordinary trained networks is established by this review.

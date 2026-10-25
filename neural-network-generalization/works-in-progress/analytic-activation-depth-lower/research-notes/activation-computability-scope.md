# Scope and computational content of the analytic activation counterexample

25 October 2026. Independent stress test of the published analytic-activation-depth-lower result. This note does not change its theorem or claim a result for exact tanh.

## What the published result actually proves

For every prescribed finite derivative order r and tolerance eta, the construction chooses one fixed computable activation phi, used at every dimension and every neuron. It is odd, real analytic on the real line, strictly increasing, strictly concave on the positive half-line, globally one-Lipschitz, has slope one at zero and range (-1,1), and is eta-close to tanh in the global C^r norm. Its perturbed part is entire; phi itself has the usual complex tanh singularities and is not asserted entire.

The theorem is not claiming that a single perturbation is uniformly small in every derivative order. Its chosen finite decay exponent makes sufficiently high derivatives unbounded along the lookup bands. For example the decoder order m=M+3 exceeds the amplitude exponent by two; a fixed nonzero point of the m-th Gaussian derivative in the d-th band has size proportional to 2^(2d), up to constants. The widely separated other bands cannot cancel that peak. This is compatible with real analyticity at every real point and with the stated finite-order closeness.

I found no new mathematical error in the published construction. The existing independent audit already checks the smoothness/concavity estimates, decoder, teacher resources, actual finite-width posterior arguments, and critical appendix. The important limitation is the computation performed by the activation primitive.

## Why efficient evaluation cannot preserve the hard tables

The target f_d is chosen to disagree substantially with every Boolean circuit of size at most 2^(d/4). Its teacher has polynomially many operations, polynomial-bit weights, polynomially bounded arguments, and constant output margin. Its total error amplification is at most exp(O(d)). Therefore evaluating phi to O(d) bits on O(d)-bit dyadic arguments would simulate the teacher with polynomial overhead.

Consequently even NONUNIFORM circuits for this activation evaluator require exp(Omega(d)) gates at that precision. This is stronger than the absence of a known polynomial-time algorithm. Polynomial advice, hard-coded activation constants, or a different efficient numerical implementation cannot remove the obstruction.

Replacing phi by a standard efficiently evaluable activation while preserving these particular teachers and hard tables is impossible. The finite-bit teacher simulation would contradict the defining circuit lower bound. Preserving the tables would instead require exponentially expensive activation evaluation, exponentially many architecture resources, exponentially many parameter bits, or loss of the output-margin/precision guarantee.

Choosing different targets that have polynomial-size Boolean circuits but remain hard for the existing low-product/near-baseline parallel circuit classes is a different problem. An unconditional separation of that kind would encounter the P/poly-versus-NC barrier already identified for the original standard-activation question. The hard-table diagonalization in the current paper avoids that barrier precisely by putting superpolynomial computation inside phi.

## A natural analytic condition excludes this coding mechanism

Suppose an activation extends holomorphically to a fixed-width strip around the real axis, with a uniform bound there (or a bound polynomial in the real range). Then on |u|<=R it has a NONUNIFORM numerical evaluator of size polynomial in R and requested bit precision p.

One direct construction partitions the real interval into O(R+1) fixed-length pieces strictly smaller than the strip width. Taylor expansion at each center has exponentially small remainder, so degree O(p+log M_R) suffices, where M_R is the strip bound on the relevant range. Store that many Taylor coefficients to polynomial bit precision as circuit constants, choose the interval, and evaluate its polynomial. This does not require an efficient uniform procedure for computing those coefficients: nonuniform advice suffices. In particular a bounded fixed strip gives polynomial-size evaluators on all polynomial argument ranges and polynomial precisions.

The published activation cannot have this uniform strip control. Its increasingly narrow bumps make its complex growth enormous near the moving lookup bands, consistently with the high-derivative observation above. Standard tanh and logistic have the needed strip property; familiar efficiently evaluable activations are outside this computational coding mechanism for the more direct simulation reason as well.

A weaker quantitative regularity assumption already suffices. Suppose for fixed constants C,A and finite s>=1 one has `sup |phi^(j)| <= C A^j (j!)^s` for every j. This is a global finite-order Gevrey bound. For integer n choose Taylor intervals of radius at most `1/[2A n^(ceil(s)-1)]`. Taylor's remainder is at most `C 2^(-n)`, since `n!<=n^n`. On `[-R,R]` there are at most `O((R+1)n^(ceil(s)-1))` intervals. Degree `n-1=O(p+log C)` and polynomial-bit hardcoded coefficients therefore give a nonuniform evaluator of size polynomial in R, p, and the input bit length. The coefficient magnitudes have logarithms `O(n log n)`, so coefficient rounding and arithmetic require only polynomially many bits. Again no uniform algorithm for discovering the coefficients is needed.

Consequently even a fixed finite Gevrey bound excludes these hard-table teachers. Merely saying that each derivative has some finite global bound is weaker: those bounds can grow faster than every `C A^j(j!)^s`. The [companion note](all-derivatives-bounded-counterexample.md) constructs precisely an all-derivatives-bounded example with an exponential-depth lower bound, and it remains outside every such fixed finite Gevrey condition.

Analyticity by itself is therefore materially weaker than the quantitative analytic/evaluation conditions of usual activation functions. The published result shows that common qualitative shape assumptions and any fixed finite-order smooth closeness do not suffice for a universal depth-polynomial theorem. It does not show that an ordinary efficiently specified and efficiently evaluable activation exhibits this failure.

## Non-Gaussian priors do not repair the original scope

Moving the hard-coded information into microscopic features of a coordinate prior would change a different part of the original problem. A computable but computationally intractable prior density can itself act as an information-bearing primitive, just as this activation does. A result obtained that way would be a counterexample to a very broad prior class, not to the original Gaussian strong-prior or mean-field learner.

Efficient specification and efficient evaluation are distinct: a short program can enumerate the hard tables, but its running time is enormous. Likewise a concise formula containing a specially chosen real constant or an extremely costly subroutine is not a conventional efficiently evaluable prior. No statistical lower theorem for such a fractal/non-Gaussian prior is proved here. In particular the Gaussian scaling exponent alone does not specify enough of a non-Gaussian prior to transfer either the positive theorems or this counterexample.

## Answer to the broad-versus-original question

The published theorem is a genuine unconditional statistical depth counterexample if the question quantifies over all computable odd analytic one-Lipschitz concave activations near tanh and counts activation calls as unit-cost neural gates. It establishes that these regularity properties alone cannot replace robustness assumptions.

It does not settle the requested exact-tanh problem, a standard efficiently evaluable activation version, or a statement about targets of small ordinary Boolean circuit complexity. Its small teachers use a computationally powerful activation whose evaluation complexity is omitted from the architecture count. That qualification is central to interpreting the result, not merely an implementation detail.

# Fresh audit on resuming the unrestricted Boolean-depth problem

25 October 2026. This is a conventional mathematical audit, not Lean verification.
No public repository files were changed.

Audited main source: `manuscripts/parallel-complexity.tex`, SHA-256
`861224a0ef69a7491127a16cba366eb6dd699223fd8cee61480e470a1828629b`.
I also read the proofs in `critical-rate-parallelization.md`,
`uniform-moving-prefactor-converse.md`, `fixed-prefactor-parallel-converse.md`,
`uniform-baseline-gain.md`, `uniform-scale-intrinsic.md`,
`uniform-sharp-intrinsic.md`, `nearcritical-target-reuse.md`, and
`manuscripts/uniform-target-classes.tex`.

## Conclusion

I did not find a fatal mathematical or quantifier error in the claimed
conditional sandwich

    P/poly = nonuniform TC^0
        => a universal joint-polynomial sample bound
        => P/poly = nonuniform TC^1.

The statistical claim here uses the original full posterior, strict global
absolute output-margin conditioning, the >2/3 confidence criterion, every
input distribution, and every admissible learner width. The converse covers
actual finite widths and every prescribed prefactor schedule 0<t<=1 chosen
independently of the sample and input distribution. It is not an argument
for a single posterior minimizer.

The result remains conditional evidence about the difficulty of the original
problem. Neither an unconditional polynomial bound nor an unconditional
exponential lower bound follows. In particular, a general failure of polynomial
sample complexity is not a stretched-exponential lower bound.

This audit independently checked the proof mechanisms below; it did not
re-prove every theorem in the older critical-depth manuscript. The finite-width
target constructions and intrinsic compression remain explicit analytic
dependencies. Their companion notes present coherent proofs, but a public
package must include or precisely link them. Labels saying that prior agents
passed an audit are not substitutes for those proofs.

## Checks of the main new steps

### Canonical features and parallel evaluation

Including all Gaussian coordinate functions in the projection space makes the
linear part exactly linear. Appending the norm of the orthogonal residual
preserves every query norm and query-anchor inner product, while the final
coordinate vanishes on anchors. Those invariants, rather than the full query
covariance, determine each next anchor-dependent Gaussian transition.

For two residual vectors, the squared difference of their projected parts plus
the squared difference of their residual norms is at most their original
squared distance. Thus the norm coordinate does not add an uncontrolled
Lipschitz factor. The canonical state need not itself be a legal original
controlled kernel; the proof correctly compares it with a separately defined
legal Rao--Blackwellized path.

The importance evaluator avoids inverse anchor-Gram conditioning. In the
arbitrary-scale version, the density proportional to
`1+||e(g)||^2+||g||^2/alpha^2` bounds both weighted projection coefficients
and weighted square-norm coefficients. Its normalizer is at most `1+r+K`.
The univariate functions `tanh(s u)/s` are zero-preserving and 1-Lipschitz for
any s>0. Consequently a bounded-range lookup table has polynomial size even
when s itself has no polynomial-bit representation. This is legitimate for
nonuniform circuit existence, not for an efficient circuit construction.

Once normalized, all linear propagators are contractions and may be stored
nonuniformly. Strictly increasing time indices yield the elementary symmetric
sum bound `Lambda^k/k!` for Picard iteration. Rounding errors accumulate with
`exp(Lambda)`, not `Lambda^k`. Since `Lambda=O(log R)`, polynomial precision
suffices and O(log R) parallel rounds are enough. Radial extension is needed
and is present; the estimate is not silently applied to unbounded iterates.

### Nearcritical block covering

For adjusted cost e_j, choosing an input attaining the new maximum variance
and writing M for its normalized second moment gives

    e_j >= D_1(query) + (a/2)[M-1-log(q_j/q_{j-1})]
        >= D_1(query).

The second inequality uses `q_j/q_{j-1} <= M`; it does not require the same
input to attain every successive maximum. Projection of the suffix at an
input attaining q_i separately gives the prefix budget. Both facts are valid
simultaneously.

The entropy gain identity

    D_j-c_t = a g_j + (1+a)(exp(2g_j)-1-2g_j)/2

has the stated sign and constants. Its nonnegative remainder is at most e_j.
The terminal adjustment is uniformly bounded because
`(1/2)log(q_H/2)+1/(8q_H) >= -1`. Hence subtracting the scalar baseline does
not hide an uncontrolled `V_*/a` term.

The full uncentered second moment is essential in the decomposition into
matching-Gaussian and non-Gaussian entropy; using centered covariance would
be wrong with nonzero means. Rao--Blackwellization decreases the latter
entropy by data processing onto the anchor span, then adjoining a free
Gaussian complement. The matching Gaussian of the replaced law has exactly
that product form.

On a Gaussian-good block of length ceil(c/a), polar decomposition yields a
contracting isometry plus a Hilbert--Schmidt perturbation with a fixed bound.
Truncating its small singular values leaves fixed rank, hence a cover with a
fixed number of cells independent of ambient dimension and a. The nonlinear
estimate is required only on actual query trajectories. Choosing an actual
state in each nonempty cell makes this restriction sufficient.

The constant hierarchy is consistent: choose c, then r_0, then the nonlinear
tolerance, then K, then K_H. Gaussian-bad counts are O(K S/r_0), while the
nonlinear-bad count is O(sqrt(K) S) with the preceding constants fixed. Thus a
fixed positive fraction of O(K S) blocks is good. There are O(S) blocks, not
O(S/a) branchings. The final normalized radius depends on sum h_j/a, bounded
by O(S), minus a fixed gain per good block. This is the substantive repair of
the earlier failed per-layer cover.

### Actual finite-width extraction

The bounded dual maximizer satisfies coordinatewise
`lambda_i(q_i-a_i)=B|q_i-a_i|`, including the boundary cases. Consequently its
objective equals tilt entropy plus B times the moment error. The finite-grid
exponential bound is uniform in the conditional preceding covariance, so
iterated conditional expectation applies to the network. The readout
quadratic form is a chi-square variable on the covariance range; singular
covariances cause no missing probability factor.

Conditioning on a raw event E with probability at least exp(-NA) costs at most
NA in relative entropy. The resulting averaged cost bound supplies an actual
realization of E. Approximate kernels can be transferred to a consistent
controlled path because
`||sqrt(K)-sqrt(K')||_op <= sqrt(||K-K'||_op)`; the latter follows from
operator monotonicity and the scalar inequality
`sqrt(x+u) <= sqrt(x)+sqrt(u)`. The transfer works with common embeddings and
data processing of a tilted joint Gaussian.

The very small covariance tolerance enters only through its logarithm in the
dual grid. This is why the finite-width threshold can be exponential in input
dimension and polynomial in the other resources, without an exponential
learner-depth term. Scale normalization with `Q=t^2 A` and
`tau=1/(t^2 H)` also removes a spurious inverse power of t.

### Posterior mixtures and complexity quantifiers

Restricting a posterior to an event of mass at least 5/6 changes a wrong-label
probability below 1/3 to one below 2/5. O(d) sampled voters therefore provide
one finite majority correct at every point in the posterior's good set.
The class of all these majorities is independent of the input law. Finite
minimax and a second sampled majority then yield an exact full-cube circuit.
No closure of the original rate or product class under majority is assumed.

The learner width is fixed before the adversarial input law. The hypothetical
joint-polynomial sample count is independent of that width, so the converse's
large-width threshold creates no circular dependence. The collapse proof
pads the bounded-weight teacher to depth at least d, ensuring the logarithmic
padding hypothesis for every sufficiently large input dimension.

The sufficient implication applies the collapse to one universal circuit
value family, rather than separately to each teacher family. This supplies
one fixed TC^0 depth and polynomial exponent. The finitely many smaller
learner depths use the fixed-depth cloning/intrinsic result. Thus the word
'universal' is justified at this point.

For the stretched-exponential obstruction, finite-domain occupancy first
forces d >= Omega(L^alpha). This is needed to put the selected teacher family
in P/poly as a function of d; omitting it would be a quantifier gap. The text
includes it. An NC family would then have the companion subexponential sample
upper bound at the same actual width and scale.

## Publication clarifications

1. The current Maurey lemma uses 64(1+log|X|), so the singleton-input issue in
   an earlier draft is already repaired.
2. Split the universal constants in the uniform posterior ceiling into a
   target-cost constant, a padding constant, a width constant, and a circuit
   resource constant. Reusing C and saying 'enlarge C' can literally enlarge
   the rate class as well as its circuit bound. The proof supports separate
   constants without changing the result.
3. State consistently that the all-width PAC guarantee is at each width;
   simultaneous correctness of one sample for an infinite set of widths is
   a stronger statement and is not needed for this barrier.
4. Include the target-mass and intrinsic supporting notes when publishing.
   The six-page companion explicitly imports several scratch proofs and is
   not, by itself, a self-contained proof of every stated analytic input.
5. Do not describe the full paper as Lean verified. The saved Lean modules
   verify important geometric/compression components, not the full posterior
   theorem, its target-mass dependencies, or the complexity-class sandwich.

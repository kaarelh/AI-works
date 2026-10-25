# Independent end-to-end audit of the ReLU relative-product manuscript

25 October 2026. Conventional proof audit, not Lean verification.
Audited source: `manuscripts/relu-baseline-compression.tex`.

I find the baseline theorem, relative-product compression, finite function
count, and fixed-architecture cold-prior sample theorem valid under the
stated no-hidden-bias and positive-homogeneous ReLU conventions.

## Baseline

A bichromatic cube edge has augmented Gram eigenvalues2d and2. Hidden states
for opposite labels are nonzero, nonnegative, and not positively proportional:
otherwise the homogeneous suffix could not give opposite output signs.
The least-norm two-anchor linear replacement satisfies the stated Pythagorean
inequality. In the one-positive-output case its cross term is -Cpt/det G>=0;
the other cases are orthogonal projection or the zero map.

Consequently each hidden squared Frobenius norm dominates the trace of the
Gram transport, and the readout norm dominates 2/sqrt(det G_H). The rank-two
replacement product has top singular value at least1 after multiplication
by ||v|| and singular-value product at least1/sqrt d. Schatten Holder with
exponent2/H yields the claimed sharp product bound. That Holder step can
also be proved elementarily in rank two using determinant multiplicativity,
operator-norm submultiplicativity, and convexity of log cosh; thus no
hypothesis fails when2/H<1. The d=1 dictator construction and homogeneous
energy balancing attain the exact stated finite-depth energy at every N>=2.

## Compression

For every opposite-label pair, the determinant suffix calculation applies
from hidden layer j>=1. It yields area >=2^(1-j)d S_j^2 exp(-beta). Dividing
by the bound sqrt(d+1) S_j for one state proves the simultaneous normalized
separation. This step is specific to required opposite-label pairs and does
not assert a false general suffix contraction.

The radius-quartering cover is valid: retaining64 singular directions leaves
tail operator norm below1/8, and a1/8 net of the retained unit ball has at most
17^64 points. Orthogonal errors combine to less than1/4. At
j=ceil(log2(64exp beta)), replacing centers by actual states still leaves
covering radius at most Delta/32. Hence all retained cells are monochromatic.

The explicit comparison suffix correctly implements nearest-prototype
classification. Its clipped comparisons lie in[0,1]; a positive query has one
positive prototype winning every comparison, whereas a negative query has
one negative prototype defeating every positive candidate. The differences
of squared distances cancel the query norm. Norm bounds charge all affine
constants through a carried rail. The prefix augmentation multiplies its
product only by2^(j/2), and the total new product is exp(O(beta+1)), with
hidden depthO(beta+1), independent of original feature dimensions.

## Function counting and the cold posterior

The ReLU Maurey step has exact per-draw adjacent norm product sum a_i b_i,
no larger than the old product. Sequential compression and finite-cube
concentration give polynomial width. Positive homogeneity then normalizes
all hidden Frobenius norms to one. Rounding at sufficiently fine inverse-
polynomial precision controls the accumulated depth error and gives the
stated finite function count. Applying relative compression removes the
original depth from that count.

Padding the target with two sign rails multiplies its relative product by
at most2, regardless of additional learner depth. Uniform cloning preserves
its exact product even at nonmultiple learner widths by zero padding.
Balancing weighted energies gives K=L(dP0^2)^(1/L), with its geometric mean
at least1 because the original target has unit margin.

At each fixed finite architecture, one target neighborhood supplies the same
denominator lower bound for every labeled sample. Gaussian Laplace comparison
therefore makes posterior energy above K+1 vanish uniformly over samples as
sigma tends to zero. The energy ceiling gives relative product at most8eT_*
after margin rescaling. The finite class union bound, exceptional posterior
mass, and Gibbs-to-confidence conversion have the correct constants and
handle posterior mixtures.

The sample polynomial is independent of learner depth and width; the cold
threshold is explicitly allowed to depend on that architecture. This is not
a theorem at every fixed exponent gamma>=1, nor a polynomial dependence on
arbitrary teacher depth, because T_* itself may be exponential in that depth.

## Recommended publication adjustments

- Replace the generic author placeholder by the actual author line.
- State j>=1 explicitly in the all-pair separation section.
- Link the circuit consequence to the public parallel-complexity paper,
  rather than an unpublished scratch filename.
- Remove or separately prove the final finite-gap/exponential-width claim:
  the eight-page manuscript does not prove that Gaussian bulk/projection
  extension. The self-contained cold theorem does not require it.
- Keep the no-hidden-bias, global-margin, and fixed-architecture cold-limit
  qualifications prominent, and do not claim Lean verification.

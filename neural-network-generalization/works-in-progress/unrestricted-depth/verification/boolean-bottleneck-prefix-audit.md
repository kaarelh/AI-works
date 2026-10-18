# Fixed-prefix bottleneck audit

Independent review of `boolean-transfer.md`, sections 3 and 5, followed by preparation of the combined source `unrestricted-primary-finite-bottleneck.tex`.

Verdict: no substantive gap found. The first-layer result and the fixed-prefix extension are valid with the assumptions and quantifiers in the combined source. The general small-circuit case remains open.

## First-layer result

The prefix must be the tanh first layer in the stated no-skip architecture, not an arbitrary unnamed feedforward map. Injectivity of tanh converts coordinate equality to an interval test of the original affine input. Finitely many attained values permit strict separating thresholds regardless of their gaps. The conjunction/disjunction construction has depth three and `O(K C (d+1))` wires; the existing coefficient-independent threshold simulation gives tanh depth six with polynomial width and weights.

No suffix weight bound, state separation, or margin magnitude is required for this representation lemma. The suffix only needs to assign a well-defined Boolean label to each attained state. The resulting target receives a new unit-margin implementation.

## Fixed-prefix result

For a width-C, depth-D teacher with weights bounded by B and signed output at least 1/2, opposite labels after hidden layer j have infinity-norm separation at least `(CB)^(-(D-j))`. The suffix has exactly D-j weighted layers, including the readout, and each has infinity-operator norm at most CB. This counts the last layer correctly.

Precision p of order `D log(2CB)` therefore suffices. The prefix j must be fixed. Its original real parameters are rounded to finitely many advice bits, with an explicit telescoping error bound. No algorithm is assumed to read infinitely specified real parameters. Hidden approximations are clamped to [-1,1], ensuring that weight-rounding errors do not amplify through unbounded approximate activations.

For dyadic t=a/2^b, the exponential Taylor polynomial is evaluated exactly with common denominator `2^(bm) m!`. Its signed integer numerator has polynomial bit length, even when alternating terms cancel. Degree `m=ceil(40(R+p+2))` gives the stated uniform exponential error for |t|<=R. The approximate tanh denominator is bounded below by 3/4; the ratio and subsequent dyadic division therefore preserve the target accuracy. The dependence is polynomial in numerical R, which is polynomial in d,C,B in the stated theorem.

All arithmetic is a constant-depth composition of integer addition, iterated multiplication, comparison, and division. A fixed number j of prefix stages remains constant depth. The primary source verifies the required arithmetic theorem:

William Hesse, Eric Allender, and David A. Mix Barrington, *Uniform constant-depth threshold circuits for division and iterated multiplication*, Journal of Computer and System Sciences 65(4), 695–716 (2002), DOI [10.1016/S0022-0000(02)00025-9](https://doi.org/10.1016/S0022-0000(02)00025-9). Author PDF checked at [Rutgers](https://people.cs.rutgers.edu/~allender/papers/division.pdf), including its stated treatment of polynomial-bit integer operands and closure under polynomial padding.

The lookup circuit stores K rounded centers and their labels. Positive inputs are within 2 eta of their own center; negative inputs are at least 30 eta from every positive center. Radius 3 eta boxes therefore classify exactly. No separation between same-label states is needed.

## Learning quantifiers

The resulting threshold depth, and hence alternative tanh depth q_j, depend only on the fixed prefix length j. The representation size is polynomial in d,C,B,K,D. Existing unrestricted learning results give the all-width statement at every learner depth L>=q_j and each fixed exponent gap zeta>0.

The stronger formulation “at every learner depth L>=D” is also valid. If D>=q_j, it follows directly. If D<q_j, the original teacher has one of finitely many bounded depths depending only on j; the existing fixed-intrinsic-depth theorem applies directly. Taking a maximum over those finitely many polynomials retains the required form.

The width condition is the actual `N>=C_L(f)`, not the width of the lookup construction. This is inherited from the finite-width branch in the existing theorem. No gamma=1 claim is made.

## Elementary corollaries and limits

Only nonconstant first-layer coefficients need the rational/integer form to bound state count; a fixed arbitrary real bias does not change the number of attained sums. A fixed number of distinct input-column vectors similarly reduces the first affine map to a fixed number of group Hamming sums, without any restriction on coefficient precision.

Polynomial state count is an actual additional structural hypothesis on the target representation. Bounded real first-layer weights alone do not supply it: one scalar projection may already have 2^d distinct values. Allowing the prefix length to grow also invalidates the fixed-depth arithmetic conclusion. These limitations are stated explicitly in the source.

## Build check

The proposed source was inserted into an isolated copy of the existing unrestricted-depth manuscript and the Hesse--Allender--Barrington bibliography entry added. Two pdflatex passes completed successfully, producing a 45-page PDF with no warnings, overfull boxes, or undefined references. No repository files were edited by this audit.

The independent frozen-source review found no mathematical issue and requested only that the section title say "polynomial depth bounds" rather than "removes teacher-depth dependence": the fixed-prefix theorem retains polynomial teacher-depth dependence through its precision budget. This wording change was applied without changing the proof.

Final source SHA256: `15d033cbbad9a1fcc00e1b7055ed09e6942e14ede636dc1681544b45d306134c`.

# Independent audit of narrow-layer information and precision results

25 October 2026. Independent AI-agent conventional proof audit, not Lean verification.

I checked the [paper source](../source/paper.tex) against its stated
mathematical hypotheses. The main statements match the supporting research
notes, and no substantive gap was found.

1. In the rank-to-TC0 theorem, the SVD is applied to the charged augmented
   first matrix, including its constant column. The normalized affine code
   has coefficient magnitudes at most one and radius sqrt(d+1). Rounding at
   scale h/[8(d+1)] gives coordinate error at most h/8; equal rounded cells
   then have exact-code separation below 2/A and cannot contain opposite
   labels. The labels of unattained cells are irrelevant. Dyadic thresholds
   become polynomially bounded integers, so unweighted-majority expansion
   has the asserted size. The zero-rank and zero-suffix-Lipschitz cases are
   explicitly constant functions.
2. For inner-product parity, any two Alice inputs are separated by a Bob
   coordinate vector. Thus their first affine codes have distance at least
   2/T. Isotropy on the signed cube places at least half of all 2^n codes in
   a radius sqrt(2)||A||_F ball. Comparing disjoint radius-1/T balls in the
   actual rank-r_A image proves the displayed exponential bound. Passing
   from rank r_A to width r weakens it in the correct direction.
3. The common-grid lower bound requires no margin or continuity. Distinct
   Alice inputs must have distinct affine contributions. Every scaled
   coordinate is an integer in the stated finite interval. A common grid,
   rather than separately bounded rational denominators, is essential and
   is stated explicitly.
4. The wide tanh implementation correctly computes each AND bit, then parity
   of the count by alternating midpoint thresholds. The rail c=tanh(1) is
   charged in both matrices and the readout. The second-layer squared norm
   includes O(n^3 K^2) constant-shift cost; the readout constant remains O(1)
   because its alternating sum is zero or one. The resulting product is
   O(n^(5/2) log^2(n+2)), with global signed margin greater than one.
5. The constant-width compiler is used only for the teacher representation
   corollary. The paper correctly does not call the resulting fixed-width
   norm lower bound an unrestricted-posterior sample lower bound.

I also independently checked Sections 4--5 of
the [precision and oscillation note](../research-notes/precision-and-oscillation.md), which are not part of the five-page
manuscript:

- The O(d+S)-fractional-bit rounding refinement is valid because all small
  memory holds/copies and powers-of-four coefficients stay exact on the
  chosen grid. Amplifier perturbations accumulate for only K=O(d+S) steps,
  then robust holds contract. Each temporary memory is expanded at most
  d+S times before reset. These facts justify replacing the full-depth
  worst-case perturbation product by the stated local error accounting.
- For F(x)=tanh(10(x+1/2))-tanh(10(x-1/2))-1, the interval endpoint and
  derivative inequalities are correct. F is even and strictly decreasing
  on the positive half-line, and F^{-1}([-0.9,0.9]) is exactly two intervals
  inside the two stated branches. This proves both the exact 2^H root count
  and that a point with final magnitude below0.9 belongs to a full monotone
  branch. The latter fact should be stated explicitly in exposition.
- The shifted Boolean grid lies in [-1,1]; avoiding root neighborhoods on
  the period circle works with the proposed dyadic mesh. On full branches
  the initial tanh derivative contributes at least sech^2(1)>0.4. The grid
  spacing is smaller than each branch's distance from its root to either
  endpoint, so every root contributes a lexicographic sign change.
- The width60 implementation divides each logical coefficient among twenty
  source clones. The largest physical coefficient is 15/(20 tanh1)<1.
  Additional constant-width amplification produces a uniform output margin
  in O(H+d) layers. No internal bias or constant rail is uncharged.

The horseshoe shows exponential oscillation of an implementation; it does
not show high intrinsic Boolean circuit complexity or poor posterior
learning. That limitation is retained in the research note.

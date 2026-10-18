# Independent review of the assembled continuous-domain manuscript

Reviewed by a separate AI mathematical-review agent on 18 October 2026. This review concerns the actual assembled source of the 15-page manuscript, not only its planning notes. It is a conventional mathematical audit, not machine-checked or Lean verification.

Reviewed files and SHA-256 digests:

- `paper.tex`: `78278c713ed85119eed649b7c228d71cb946c266139af6670cd4f2fb2dea7871`
- `meanfield.tex`: `33cd028b97cad4c28b75575650dc3598d1fc3ec94453d3711a0c1829563f7eda`

## Verdict

No substantive mathematical gap found. The statements match the proofs' actual scope: bounded-weight finite teachers, all learner widths above the teacher width, arbitrary input distributions on a compact bounded domain, real score labels with positive fitting tolerance, the original three prior regimes, and a separate classification result requiring a teacher margin on the support. The exact-fit result specifies the order of limits and is restricted to Gaussian priors for the minimum-quadratic-energy identification.

## Points checked in the assembled source

1. **Actual posterior and mixtures.** Both posterior lemmas use a uniform teacher tube to lower-bound every sample's denominator. Approximate cover centers give valid avoidance events under the gap between training and testing tolerances. The posterior Gibbs-risk argument controls mixtures and implies the stated >2/3 confidence criterion.

2. **Every width and separate teacher parameters.** Balanced cloning at every N>=C gives energy at most d(d+1)B^2+2(L-1)C^2B^2. No padding to a larger width depending on B is required. The translated-cylinder mass proof uses C groups and a stability bound depending separately on C and B. Its radius depends on training tolerance but not on N or sample size.

3. **Continuous-domain covers.** Energy provides a width-independent Lipschitz bound. Neuron sampling on a finite input net incurs log net cardinality. A fixed Borel nearest-point extension permits cover centers that are piecewise constant, avoiding any circular bound on the approximating network's Lipschitz constant. Parameter rounding and net sizes have the required fixed-depth polynomial majorants. Supremum distances are measurable by uniform parameter continuity on compact X.

4. **Strong-prior quantifiers.** Fixed finite N precedes sigma->0. Two-sided quadratic envelopes make the exceptional-to-teacher mass ratio vanish at a fixed energy cutoff. The scale threshold does not depend on the data distribution, sample size, or confidence delta. The sample polynomial is independent of learner width.

5. **Gamma>1 and smaller widths.** Spectral truncation gives a uniform real-output approximation without any sign-preservation assumption. Its probability estimate has the same N^gamma exponent as the teacher-tube cost. The remaining widths below the polynomial threshold are covered by the mass-only posterior lemma. Thus there is no unaddressed width interval.

6. **Mean-field endpoint.** The arbitrary-readout KKT lemma has the stated K/(4t) multiplier bound. Distribution-free covariance certificates and the relative Lindeberg log-partition comparison retain the actual first-layer law and do not replace the posterior by a GP. The backwards tilt budgets give the claimed covariance error; finite realization, rounding and the input net sum to 7a/8. The norm and certificate tails have exponent cNK. The baseline K>=4 and the choice a=min(1/2,(tau-rho)/4) make the displayed inequalities consistent, including L=2.

7. **Exact interpolation.** The common energy cover gives one sample event controlling every low-energy interpolant at every width. For Gaussian priors, fixed-rho strong-prior cluster points lie at the infimum energy b_rho of the strict feasible event. Compactness of almost-minimizers proves b_rho increases to the minimum exact-fit energy b_0. Outer rho->0 limits exist and are supported on minimum-energy exact interpolants. The proof does not assume that the closure of the strict feasible event equals the whole non-strict feasible set, and does not claim the reverse order of limits or arbitrary joint paths.

8. **Classification and sphere example.** The positive-margin support corollary uses a feasible amplified teacher without increasing teacher width. The connected-sphere obstruction is stated correctly. Score-trained sign prediction follows by adding D{|f|<=tau} to the regression failure mass. For f(x)=tanh(x_1), the stated 3sqrt(d)tau bound follows from the spherical coordinate density and the Gamma-ratio estimate. The epsilon/2 split and chosen tolerances yield the advertised whole-sphere sign guarantee from real score labels.

## Correction made during review

The sphere-density calculation initially contained the invalid inequality chain artanh(tau)<=4tau/3<0.55 at tau=1/2. It was corrected to the two valid statements artanh(tau)<=4tau/3 and artanh(tau)<=artanh(1/2)<0.55. The final probability bound was unaffected. The checked digests above include this correction and the renaming of tail-envelope exponents to avoid collision with b_0.

## Limits retained in the text

This is not a pure-width result for unbounded teacher weights. The finite-scale theorem does not condition on exact equality of continuously distributed output values. The exact-fit strong-prior corollary uses an explicit iterated limit. Margin-free binary-label learning by arbitrary-width nonlinear learners on the entire sphere, gamma<1, noisy labels, ReLU, efficient posterior computation and polynomial depth dependence are not established by this manuscript.

## Final frozen-source acknowledgement

The final frozen version was checked after the original review. Its source hashes are:

- `paper.tex`: `54c66216f14090bfbf3916f989cf69ba3e424cbf57de8443d863848fcd9ae67e`
- `meanfield.tex`: `1e5a2978824d7f5eabedca1258efb12e8f316731fe147fcdab13732c24ea2b97`

The substantive post-review adjustment replaces the realized net-cardinality term in the mean-field width threshold by the explicit domain-uniform upper bound ell_0 = log(3) + 2d log(1+8K^(L/2)/a). This is valid because 2s^2+1 <= 3s^2 and s <= (1+8K^(L/2)/a)^d. Enlarging the threshold preserves every probability estimate and makes its stated parameter dependence explicit. The other reported changes are prose and bibliography formatting. The no-substantive-gap verdict applies to these frozen sources.

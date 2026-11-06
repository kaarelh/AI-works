# Independent quantitative appendix and short-prefix review

Reviewed source snapshot on 6 November 2026:

```
c95fda1b984ef3153b1ec95f41e209855da5ca7f5b8c5c89f89ba68e8cc8a9f1  source/paper.tex
```

No mathematical corrections found. This is conventional mathematical review, not Lean verification.

The integrated explicit-rigidity appendix matches the independently derived and separately audited proof. I checked every displayed constant and implication:

- At energy excess e<=Delta_q=1/(10000q^3), the nonnegative energy decomposition controls every essential column and all unused columns, including the bias. The test gain gives Phi_d(q)<=3q+1, C<=2sqrt(q), 1/(4sqrt(q))<=u<=2/(3sqrt(q))<1/2, and d u^2>=9/16.
- The derivative formula for h(s)=tanh^2(sqrt(s)) gives -h''>=1/5 on [0,1]. The tangent-deficit estimate holds for both a^2<=1 and a^2>=1; the latter correctly uses convexity and the bounds D_u(1)>=9/160 and D'_u(1)>=3/20.
- The Cauchy-Schwarz and pair-contraction stability estimates imply column alignment <=12sqrt(e/(d u^2))<=16sqrt(e). The unused-column contribution is <=2sqrt(e). The uniform output error is therefore <=36q^(3/2)sqrt(e)<=0.36<1/2.
- The comparison scalar function F(t)=C E[v tanh(uvt)] has exactly the sign of every nonzero t; this does not require v to be constant in magnitude. Odd q makes every signed cube sum nonzero. Global weak margins then force the represented Boolean function to be that signed majority.
- Functions with more than q essential inputs have the independently checked gap Phi_d(q+1)-Phi_d(q)>=27/64. The candidate increment bound Phi_d(q+s)<=Phi_d(q)+4s gives candidate energy below Phi_d(q)+Delta_q/2 for every stated 0<delta<=1/(80000q^3), while all outsiders have energy at least Phi_d(q)+Delta_q.

I also checked the assembled short-prefix construction that uses this gap. Its cyclic block intervals give exactly 2q distinct calibration inputs. Each pair forces an essential coordinate in its block, and equality-case signed majorities must choose one coordinate per block with positive orientation. The modified query uses one selected coordinate in each of the fixed first ell=(q+1)/2 blocks. It deletes exactly one complete projection fiber of 9^(q-ell) candidates. Therefore there are exactly 9^ell forced rounds, not merely the earlier binomial-ratio lower bound. These queries are distinct, outside the calibration prefix, have negative full-majority labels, and are fixed independently of width and posterior samples.

The measure compactness/equality argument earlier in the paper is valid as well: second moments give tightness, clipping b gives uniform integrability and continuity of every finite-domain output, and lower semicontinuity gives attained weak-margin infima. Equality in strict Jensen, centered pair contraction, and Cauchy-Schwarz forces a signed majority. This supplies the qualitative uniform gap independently of the explicit appendix. The actual posterior remains the stated finite-width Gaussian posterior throughout.

The integrated uniform mean-field-scale argument, iid compression/counting theorem, and exponent corollary were also checked for consistency with the quantitative result. The product-ball denominator and chi-squared numerator give a bound r(t)^N with r(t)->0, uniformly over widths. The IID threshold-voter representation of tanh and Hoeffding union bound give the stated O(d^4) finite-class bound, and the full-target-cell denominator makes its scale choice uniform over histories. The relation t_N=tau N^((1-gamma)/2) proves the stated gamma>1 and sufficiently-small-prefactor conclusions. None of these arguments removes the positive covariance anisotropy, and the manuscript correctly leaves exact isotropy open.

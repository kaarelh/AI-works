# Audit: exact weighted stars for square-root mode costs

This note concerns the finite logical Fourier dictionary used in the triangle-activation route. It does not by itself prove the neural dictionary reduction, width transfer, or exclusion of physical completions not captured by that reduction.

Let `G=F_2^m`, `m≥5`, `M=2^m`. Choose distinct odd primes `p_i`, set `r_i=2p_i`, `D=sum_i r_i`, and take an odd integer `c>D²` (for example `c=D²+1`). Define

\[
 w(s)=\sqrt{c+\sum_i r_i s_i},\qquad
 B_w(F)=\sum_s w(s)|\widehat F(s)|.
\]

Let `U` be an affine codimension-four subspace that does not contain zero. Calibrate a positive label at zero and negative labels outside `{0}∪U`. Further negative labels may be added at any subset of `U`.

## Exact minimizers for each subgroup labeling

Every nonconstant Walsh coefficient of `w` is strictly negative. Indeed, if `v` has support `I`, `k=|I|≥1`, then

\[
 \widehat w(v)=\frac{(-1)^k}{2^k}
 \mathbb E_{s_{I^c}}
 \int_{\prod_{i\in I}[0,r_i]}
 \left(\sqrt{x}\right)^{(k)}
 \Big|_{x=c+\sum_{j\notin I}r_js_j+\sum_{i\in I}t_i}\,dt<0,
\]

because the derivative has sign `(-1)^(k−1)`. Also `w(s)≥w(0)=sqrt(c)`.

For every subgroup `H` allowed by calibration, the unique minimum-weighted-Fourier-norm real score with margin `1/2` and positive set `H` is

\[
 F_H=1_H-\tfrac12.
\]

The exact dual is

\[
 \lambda_H(x)=\sum_{s\in H^\perp}w(s)(-1)^{s\cdot x}-2w(0).
\]

Its Fourier multipliers have magnitude at most `w(s)`. At `x∉H`,

\[
 \sum_{s\in H^\perp}w(s)(-1)^{s\cdot x}
 =\frac M{|H|}\sum_{h\in H}\widehat w(x+h)<0,
\]

so `lambda_H(x)<0`. On `H`, the dual is positive, since `|H^perp|≥M/2≥16`. All pointwise signs are strict, so equality forces every margin to be exactly `1/2`.

The only allowed subgroups are `{0}` and `{0,v}`, `v∈U`: sums of two distinct elements of the affine coset `U` lie in its underlying linear subspace, hence outside `{0}∪U`.

## Exact costs and the flat lower bound

Put `a0=sqrt(c)`, `mu=what(0)`, and `beta_v=what(v)`. The exact singleton and star costs are

\[
 C_0=\tfrac12a_0+\mu-\frac{2a_0}{M},
 \qquad
 C_v=\tfrac12a_0+\mu+\beta_v-\frac{4a_0}{M}.
\]

Thus every star is strictly cheaper than the singleton:

\[
 C_0-C_v=\frac{2a_0}{M}-\beta_v>0.
\]

Define

\[
 L_{\rm flat}=\left(\frac32-\frac4M\right)\sqrt c.
\]

The same `L_flat` is a lower bound from the **calibrated training constraints alone**, even when the real values at unobserved logical points are unrestricted. Write `U=v0+K`, with `K` a codimension-four linear subspace, and define

\[
 \lambda_{\rm train}(x)
   =M1_{\{0\}}(x)-2-2\,1_K(x)+2\,1_U(x).
\]

It is zero on `U`, equals `−4` on `K\\{0}`, equals `−2` on every other calibrated negative point, and equals `M−4>0` at zero. Its Fourier multipliers are

\[
 \widehat\lambda_{\rm train}(s)=
 \begin{cases}
 -1,&s=0,\\
 3/4,&s\in T:=\{s\in K^\perp:s\cdot v_0=1\},\\
 1,&\text{otherwise}.
 \end{cases}
\]

Indeed, `|K|/M=1/16` and the transform of `1_K−1_U` is `1/8` on `T` and zero elsewhere. Thus `||lambdahat_train||_infinity=1`. Every real score satisfying the calibrated margin constraints obeys

\[
 \|\widehat F\|_1\geq\mathbb E\lambda_{\rm train}F
 \geq\frac{(M-4)+(2M-4)}{2M}
 =\frac32-\frac4M.
\]

Since `w(s)≥sqrt(c)`, this proves `B_w(F)≥L_flat` without requiring a global margin at the unobserved logical points. Further observed negative points in `U` do not invalidate this dual, which vanishes there. If any star remains feasible, the unweighted training-LP lower bound is attained by that star.

Every star satisfies the claimed quantitative comparison

\[
 \boxed{\quad 0\leq C_v-L_{\rm flat}
             \leq\frac{3D}{4\sqrt c}.\quad}
\]

The lower bound follows from `w(s)≥sqrt(c)`. For the upper bound, every weight lies in

\[
 [\sqrt c,\sqrt c+D/(2\sqrt c)],
\]

and the unweighted Fourier-l1 norm of `1_{\{0,v\}}−1/2` is exactly `3/2−4/M<3/2`. Hence the increase above the flat cost is at most `(D/(2sqrt(c)))(3/2)`.

## Exclusion of all nonsubgroup logical completions

For a margin-`1/2` score with positive set `A`, where zero belongs to `A`, the exact unweighted subgroup-gap inequality is

\[
 \|\widehat F\|_1\geq\frac{2-\delta}{1+2\delta}
 \quad\text{if }A\text{ is not a subgroup},\qquad
 \delta=|A|/M.
\]

Calibration gives

\[
 \delta\leq\frac1{16}+\frac1M\leq\frac3{32},
 \qquad
 B_w(F)\geq\frac{61}{38}\sqrt c.
\]

On the other hand, any remaining feasible star has cost at most

\[
 \left(\frac32+\frac{3D}{4c}\right)\sqrt c
 <\left(\frac32+\frac{3}{4D}\right)\sqrt c
 <\frac{61}{38}\sqrt c,
\]

since `c>D²` and `D≥8` (indeed the specified primes give much larger `D`). Therefore, while at least one point of `U` is still unobserved, every minimum-weighted-Fourier-norm globally margin-separated logical completion is a star. Moreover, `L_flat` is a valid lower bound for every calibrated logical completion, since nonsubgroups lie above it and the allowed subgroups have at least that flat cost.

## Strict ordering of all stars

The integers in `[c,c+D]` have pairwise distinct squarefree parts. If `n=q u²<n'=q v²` shared a squarefree part, then

\[
 n'-n\geq q(2u+1)>2\sqrt{qn}\geq2\sqrt c>D,
\]

contradicting their location in the interval. Consequently their square roots are linearly independent over the rationals.

For `v∈G`, the coefficients in the expansion of `M beta_v` as a linear combination of these square roots are the integer coefficients of

\[
 P_v(t)=\prod_{i:v_i=1}(1-t^{r_i})
       \prod_{i:v_i=0}(1+t^{r_i}).
\]

The cyclotomic factor `Phi_(p_i)` divides `P_v` exactly when `v_i=1`, because the primes are odd and distinct. Thus all `P_v` differ; rational independence proves all `beta_v` differ, and hence all star costs `C_v` are strictly ordered.

This is exact distinctness. The triangle route may use it without a quantitative pairwise-gap bound only if its reduction to `B_w` is exact; an approximate neural reduction would require an additional separation estimate.

## Simplification adopted in the paper

Primality is unnecessary. One may instead take

\[
 q_i=2m+2i-1\in(2m,4m),\qquad r_i=2q_i,
 \qquad D=6m^2.
\]

All `q_i` are odd, and none divides another. The factor `Phi_(q_i)` divides `1−t^(2q_j)` exactly when `q_i|2q_j`, equivalently `q_i|q_j`, hence exactly when `i=j`. It never divides `1+t^(2q_j)`, because a root of odd order cannot have an integer power equal to `−1`. The same polynomial-distinctness proof follows unchanged.

The bounded real teacher score can use margin one:

\[
 \chi_C\left[\sum_{i=1}^m\chi_{B_i}-(m-1)\right]
   =\sum_i\chi_{C\cup B_i}-(m-1)\chi_C.
\]

It has the required sign everywhere and absolute value at least one. If each odd parity is one unit-weight triangle atom, its width is exactly `2m−1` using unit readout copies of the core term.

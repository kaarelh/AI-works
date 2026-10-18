# Independent check of the Boolean inner-product norm separation

Reviewed the argument supplied by the counterexample-audit agent. No substantive gap found.

The complete Section 3 of `product-complexity-and-circuit-barriers.md` was subsequently checked against the argument. It agrees and is valid. Its deep upper-bound proof uses slightly looser constants than the independent reconstruction below: second-layer error at most `1/(8n)`, signed margin at least 7/4, and matrix-norm bounds `2 sqrt(n) lambda`, `2 n^(3/2) lambda`, and `5 sqrt(n)`. These also give the claimed constant 20. The threshold sign at zero can use any fixed Boolean convention; the derivative-integral argument is unaffected by its measure-zero threshold ties.

Reviewed complete note SHA256: `8e06874f9490a2c2cdb3b5ea7917c4ccca659149e9f4ae95e7eae207fadb3cb9`.

Let N=2^n, and let H be the Boolean inner-product Hadamard matrix indexed by x,y in {-1,1}^n. Its operator norm is square root of N.

## Affine threshold correlation

For an affine threshold of the concatenated input (x,y), sorting columns by the y-dependent affine contribution makes each row a prefix indicator or its complement. Write its sign matrix as `A=2B-J`, with B a row-prefix matrix after an optional reversal.

Decompose each row prefix into aligned dyadic intervals, at most one at each scale l=0,...,n. For a fixed scale, group equal intervals I into rectangles `R_I x I`. Their nuclear norms sum to

`sum_I sqrt(|R_I| |I|) <= sqrt((sum_I |R_I|)(sum_I |I|)) <= N`.

The first sum is at most N because each row uses at most one interval at that scale; the second is at most N because the aligned intervals partition the column set. Consequently `||B||_* <= N(n+1)` and `||A||_* <= N(2n+3)`.

This gives absolute uniform correlation with H at most `(2n+3)/sqrt(N)`. Multiplying H by any one input coordinate or by the constant coordinate is a row or column sign flip, and preserves its operator norm. The same correlation bound therefore applies to all coordinate-modulated H matrices.

## Tanh-feature correlation

For h(u)=sech(u)^2,

`h(u) = (1/2) integral h'(t) sign(u-t) dt`.

The coefficient measure has total variation one: h rises from zero to one and returns to zero, so `integral |h'|=2`. Fubini and the affine-threshold bound give

`|E H z_i sech(s w.z)^2| <= (2n+3)/sqrt(N)`

for every coordinate i and s in [0,1]. Using

`tanh(w.z)=integral_0^1 sum_i w_i z_i sech(s w.z)^2 ds`

gives feature correlation at most `((2n+3)/sqrt(N)) ||w||_1`. The augmented input has 2n+1 coordinates, so its upper bound is that coefficient times `sqrt(2n+1)||w||_2`.

For a shallow network with unit signed margin for H, expected signed output is at least one. Summation and Cauchy–Schwarz over hidden neurons therefore prove

`P_F >= sqrt(N)/((2n+3)sqrt(2n+1))`.

This holds uniformly over hidden width and first-layer coefficient magnitudes. It concerns unit-margin exact representation; a claim about arbitrary sign-approximation error would require an additional argument controlling output magnitudes.

## Independent reconstruction of the depth-three upper bound

Set lambda=log(8n). The first hidden layer computes tanh of `lambda(-x_i-y_i-1)` for each i, and carries the exact constant 1/2. These features approximate the pairwise AND signs with error at most `1/(32n^2)`.

The second layer computes the n Hamming-count thresholds `lambda(sum_i a_i+n-2j+1)`, j=1,...,n, carrying the constant rail. Their signed preactivation margins before lambda are at least `1-1/(32n)`. Their output errors are less than `1/(16n^2)`.

An alternating readout with coefficients `2(-1)^j` and constant term `2(1+sum_j(-1)^j)` gives signed margin at least 15/8. The constant rail implements that term with coefficient at most four.

The three Frobenius norms are bounded by

`2 sqrt(n) lambda`, `sqrt(3) n^(3/2) lambda`, and `sqrt(20n)`,

respectively. The product is less than `20 n^(5/2) log(8n)^2`, as claimed.

## Scope

This is a genuine function-level separation between one-hidden-layer and depth-three product norm, not merely a bad chosen implementation. It rules out a universal polynomial collapse of deep low-product representations to shallow tanh/Barron representations. It does not provide a lower bound for the unrestricted learner at depth three or larger, and it does not separate TC0 from NC1.

## Final TeX audit

Independently read the complete frozen source `unrestricted-primary-shallow-product-separation.tex`, SHA256 `b0a2b0391363cdcfe42eac28501fd13d7e93cbe4b2510662508f6c86c1859805`. The theorem, correlation lemma, deep construction, constants, and posterior-learning scope paragraph are approved. The only convention worth making explicit is that the displayed row-prefix proof uses either fixed Boolean value for `sign(0)`; the convention `sign(0)=0` obeys the same bound by averaging those two completions. This requires no mathematical change to the statement. The prior complete-note hash above records the version reviewed at that time; a subsequently added conditional circuit-class paragraph does not change this TeX section.

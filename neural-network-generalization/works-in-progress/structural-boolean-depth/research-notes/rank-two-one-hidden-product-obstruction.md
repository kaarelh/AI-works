# A rank-two formula can require exponential product at one hidden layer

26 October 2026. Scratch exact-representation theorem. **This is not a
Bayesian sample lower bound and not an intrinsic all-depth norm lower.**

Let `u,v in {0,1}^m`, let `n=2^m`, and define

`f(u,v)=(-1)^(sum_i u_i v_i)`.

Translate u,v to the original signed Boolean cube by affine coordinate
changes. For every one-hidden-layer tanh network with augmented input,
arbitrary finite width, arbitrary real weights, linear readout, and
global signed output margin at least1, its Frobenius product obeys

`P_F >= 2^(m/2) / [(2m+3) sqrt(2m+1)]`.

The target has a size-O(m), rank-two formula over the fixed binary
gate library containing XOR and AND. This is the arbitrary-binary-gate
convention used in the structural paper. Register rank is basis-sensitive;
we do not assert the same rank after replacing XOR by AND/OR/NOT gates.
The target also has a two-hidden-layer tanh realization of polynomial
Frobenius product, so the bound does not survive unrestricted depth.

## 1. Halfspace correlation with the inner-product matrix

Index the Walsh--Hadamard matrix by u,v, putting H_uv=f(u,v).
It satisfies `H H^T=n I`, so `||H||op=sqrt n`, and its average
entry is1/n.

An affine halfspace on (u,v) has the form

`M_uv=1[alpha(u)+beta(v)>=0]`.

Sort the columns by beta so each row of M is a prefix. Decompose
each prefix into aligned dyadic intervals. There is at most one
interval of each length `2^ell`, including the possible full interval.
For each fixed ell, let R_I be the rows whose decomposition uses I.
The sets R_I are pairwise disjoint, and the intervals I are pairwise
disjoint. Therefore

`sum_I |R_I|<=n`, `sum_I |I|<=n`.

For any rectangle, the spectral bound gives

`|sum_(u in R,v in I) H_uv| <= sqrt(n |R| |I|)`.

Cauchy--Schwarz and summation over the m+1 dyadic scales yield

`|E f M| <= (m+1)/sqrt n`.

The argument allows arbitrary real coefficients, biases, column ties,
and either fixed threshold convention. No weight-precision hypothesis
is needed. In particular it applies to every level set of a tanh ridge.

## 2. A row-norm-sensitive tanh correlation bound

Write the signed augmented input as X, with `||X||_2=sqrt(2m+1)`.
For a row w put `M=sqrt(2m+1)||w||_2`; then |w·X|<=M. On this
range the exact layer-cake identity is

`tanh(s)=tanh(-M)+integral_(-M)^M 1[s>=a] sech²(a) da`.

Using |tanh M|<=M, integral mass<=2M, the preceding halfspace bound,
and Ef=1/n, gives

`|E f tanh(w·X)|`
` <= M/n + 2M(m+1)/sqrt n`
` <= (2m+3)sqrt(2m+1)2^(-m/2)||w||_2`.

This scaled estimate matters: a bound independent of ||w|| alone would
control readout l1 norm, but would not imply the required product bound.

## 3. Frobenius product and the deeper escape

For z(X)=sum_j a_j tanh(w_j·X), global unit margin implies Efz>=1.
Hence, with the displayed correlation constant kappa_m,

`1 <= kappa_m sum_j |a_j| ||w_j||_2`
` <= kappa_m ||a||_2 ||W||_F = kappa_m P_F`.

This proves the theorem at every finite hidden width.

For the formula claim, each `t_i=u_i AND v_i` has rank1. A left-associated
XOR of these bits has rank2 once the first two terms are combined and
retains rank2 afterward. A final NOT changes neither order of size nor
rank. There are O(m) nodes.

For a polynomial-product deeper realization, first compute all t_i
with a tanh layer and inverse-polynomial Boolean accuracy. In a second
hidden layer compute all threshold indicators of their Hamming weight;
an alternating linear combination gives parity. A charged constant rail
and tanh gains O(log(m+2)) preserve the integer margins. There are O(m)
neurons per layer and polynomially bounded coefficients, hence
polynomial Frobenius product after a constant output rescaling.

## What this does and does not explain

The rank-one every-L>=2 positive theorem cannot be extended to rank2
by claiming equally shallow polynomial-product representations. A
general fixed-rank result must allow the compiled constant depth or
use a different statistical mechanism.

The proof controls exact globally margined representation. It does not
show that a mixture of low-product shallow predictors cannot achieve
fixed weak classification accuracy, and therefore does not by itself
give an actual posterior sample lower. In particular it is not an
exponential-in-learner-depth counterexample to the original problem.

## Related work and scope of credit

Communication-matrix methods for shallow neural-network lower bounds
predate this note. Eran Malach and Shai Shalev-Shwartz,
[*Learning Boolean Circuits with Neural Networks*](https://arxiv.org/html/1910.11923v2),
Section 6 and Theorem 12, use sign-rank to obtain a bounded-weight shallow
ReLU separation for an AND/OR target. Mehmet Erdal and Friedhelm Schwenker,
[*Learnability of the Boolean Innerproduct in Deep Neural Networks*](https://doi.org/10.3390/e24081117),
*Entropy* 24(8), 1117 (2022), discuss the classical threshold-network
depth separation for Boolean inner product and study its optimization
experimentally. Those works are relevant precedents, rather than sources
of the precise unrestricted-weight tanh Frobenius-product inequality
proved here. This note makes no broad novelty claim. Its purpose is the
explicit norm inequality and its limited implication for the all-depth
formula discussion; no Bayesian sample lower bound follows from it.

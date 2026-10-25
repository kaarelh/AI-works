# Independent challenge audit of the low-product tanh arithmetic-sign theorem

25 October 2026. Fresh audit of the published research source, without relying on its previous verification reports. The normal-form and width-compression arguments were additionally checked by a separate agent. No published source or repository metadata was changed.

**Verdict:** I found no substantive counterexample or proof gap in the main representation theorem. The Fourier–Poisson work–second-moment recurrence, finite-cube selection, coefficient rounding, and complex-formula balancing survive direct reconstruction. The ordinary-tanh normal form also survives an independent algebraic check. This is a conventional mathematical audit, not a Lean verification or a resolution of the original unrestricted Boolean NNBayes depth question.

One minor statement-scope caveat is recorded below: the balancing lemma needs its final output to be real, as is already required by the paper's global convention. I also give a direct rational construction for the particular majority step used here, independently confirming the polynomial-size/logarithmic-depth interface without needing the full composition theorem.

## 1. Audited claim and source snapshot

The claim is: if a Boolean function on `{-1,1}^d` has a globally unit-margin ordinary-tanh representation, with one augmented constant input, no later free biases, arbitrary finite hidden widths and depth, and Frobenius product at most `P`, then its sign has an integer arithmetic circuit with only `-1,0,1` constants, size `poly(d+P+2)`, and depth `O(log(d+P+2))`.

The source directory is:

`/workspace/nnbayes-statement-audit-2026-10-23/neural-network-generalization/works-in-progress/tanh-arithmetic-formulas/source/`

The audited SHA-256 hashes are:

| File | SHA-256 |
| --- | --- |
| `paper.tex` | `0ce0a2da8d387f8fb0d1203d3ee3edc0493f9aadb092d56a1c64d9eea2281201` |
| `normal-form.tex` | `469fe2706d3a39782bd5d91e3562e02cd0813b58b9d0bf56c513efdabb6968f9` |
| `width-compression.tex` | `5ffeea041dc19dc9e937101de913d5a5bc6aefc995b6f5b306032e9e3426ca67` |

I checked the primary arithmetic-complexity reference directly: [Datta–Mahajan–Raghavendra Rao–Thomas–Vollmer, *Counting Classes and the Fine Structure between NC1 and L*](https://www.cse.iitm.ac.in/~bvrr/conf/mfcs10.pdf). Its gate convention matches the manuscript. Proposition 2.4 supplies the logspace inclusion, and Theorems 4.1–4.2 supply the stated constant-depth positivity composition. For arbitrary nonuniform selected circuits, the appropriate conclusion is `L/poly`. Section 7 below supplies a separate quantitative construction for the manuscript's narrower majority application.

## 2. Exact activation estimator: the cost recurrence really closes

Let `X` be a real random expression, with mean `mu`, second moment at most `V`, and expected arithmetic cost at most `T`, where `T>=1`. For a fixed frequency `w>0`, put

\[
\lambda=1+w^2V,\qquad
Z=\prod_{j=1}^{K}(1+iwX_j/\lambda),\qquad
K\sim\operatorname{Poisson}(\lambda).
\]

Each `X_j` must be a fresh independent expression; the manuscript imposes this. Conditional on `K`, products of first moments and second moments give

\[
\mathbb EZ=e^{iw\mu},\qquad
\mathbb E|Z|^2
=\exp\{w^2\mathbb EX^2/\lambda\}\le e.
\]

Only second moments enter. The expected number of child calls is exactly `lambda`. Including the multiplication, addition, constant leaves, and imaginary-part operation contributes at most a universal constant times `lambda T`. No higher-moment or worst-case child-work bound is being smuggled into this estimate.

For `S=Im Z`, write `v=w²V`. The estimate

\[
\mathbb ES^2\le\mathbb E|Z-1|^2
=e^{w^2\mathbb EX^2/\lambda}-2\cos(w\mu)+1
\]

is at most a universal constant times `v`: use `(e^a-1)<= (e-1)a` for `0<=a<=1`, `1-cos t<=t²/2`, and `mu²<=V`. Together with `ES²<=e`, this gives `ES²<=C min(1,v)`.

With

\[
b(w)=\min(1,w\sqrt V),\quad
Z_V=\int_0^\infty k(w)b(w)/\sqrt\lambda\,dw,\quad
A_V=\int_0^\infty k(w)b(w)\sqrt\lambda\,dw,
\]

the proposed density `q=k b/(sqrt(lambda) Z_V)` yields

\[
\mathbb EY^2\le C Z_VA_V,\qquad
\mathbb E\operatorname{cost}(Y)\le CT A_V/Z_V.
\]

Their product is at most `CT A_V²`. Pointwise,

\[
r\le\min(1,r)\sqrt{1+r^2}\le\sqrt2r,
\]

and the Fourier normalization is `integral w k(w) dw=1`. Therefore `V<=A_V²<=2V`, proving the claimed constant-factor loss in `VT`. This is the crucial cancellation; replacing the chosen frequency density by an arbitrary convenient density would not establish it.

Absolute integrability also follows: `E|S|<=C b(w)`, so the relevant integral is bounded by `C integral k(w)b(w) dw`, which is finite. There is no conditional/unconditional expectation interchange left unsupported. Scaling to `tanh(s mu)/s` adds constant arithmetic overhead and cancels the `s²` second-moment factors.

As a numerical sanity check only, high-precision quadrature at `V=10^e`, `e=-12,-8,-4,0,4,8,12`, gave `A_V²/V` between `1.000000000002` and `1.338269806632`, inside the proved interval `[1,2]`. The proof does not depend on that check.

## 3. Linear sampling and Frobenius propagation

For child bounds `(V_j,T_j)`, set

\[
L=\sum_j|w_j|\sqrt{V_j/T_j},\quad
M=\sum_j|w_j|\sqrt{V_jT_j},\quad
p_j=|w_j|\sqrt{V_j/T_j}/L.
\]

The sampled expression `w_J X_J/p_J` has second moment at most `LM`, and expected child work exactly bounded by `M/L`. The fixed overhead is absorbed because `M/L>=1`. Thus the resulting potential is at most `CM²`.

For a matrix layer and `K_j=V_jT_j`, rowwise Cauchy–Schwarz gives

\[
\sum_i\left(\sum_j|w_{ij}|\sqrt{K_j}\right)^2
\le\|W\|_F^2\sum_jK_j.
\]

Consequently the total potential is at most `C^(h+1)(d+1)P²`. I found no missing width factor or dependency between child calls. This estimate genuinely retains an exponential factor in the retained hidden depth. The normal form is essential to turning it into a polynomial bound; the estimator alone does not remove arbitrary depth.

## 4. Normal form and actual-tanh width compression

The separate check of both appendices reached the same positive verdict. The potentially vulnerable points are as follows.

- Relevant-coordinate reduction uses bichromatic cube edges and charges each relevant coordinate at least `1/T²` to the squared first-layer Frobenius norm. Averaging over fixed irrelevant input signs controls the new constant column without increasing the product.
- The two-ball lemma's quadratic expression is convex in the leading singular coordinate's absolute value. Both endpoint values equal `1/(4 alpha²)`. Its iteration and the margin separation justify monochromatic cover cells and the stated number of centers.
- The physical-weight inequality `S_j<=P sqrt(C)` is valid: the hidden state has norm at most `sqrt(C)`, and the zero-preserving suffix has Lipschitz constant at most `P/S_j`. Combining these with a nonzero unit-margin output supplies the inequality, even when individual original matrices have very small or very large norms.
- Removing activations with original prefix product below `tau` has telescoping output error at most `P D tau² R³/3<=1/48`. Collapsing the resulting linear blocks produces bounds that telescope, so it does not multiply an uncontrolled number of individual norm penalties.
- In middle-neuron sampling, the two new squared Frobenius norms are exactly `c Ahat` and `Ahat/c`, where `c=m/Z`. The output-dimension-free concentration bound is a Hilbert-space mean bound plus bounded differences.
- The replicated SVD branch has error `c nu²(SR)³/(3K)` at the next preactivation. The crucial bound `c nu S²<=m B²/Delta` follows from `Z>=A_m S²/B²`, `nu<=A`, and `A_m>=Delta A`. Combining the branches has pair product exactly `Ahat+nu`.
- Sequential compression changes just the chosen hidden width and its adjacent matrices. Later steps preserve earlier width bounds, and stopping after a prefix does not import the original suffix widths into the resource bound.
- The constant rail's norm cost is polynomial at logarithmic depth. The close-center threshold gap is `11/(256P_0²)` and the opposite-label gap is stronger than needed. The classifier therefore has the asserted global margin.
- Physical-weight rounding at `O(D log B)` bits controls both relative matrix-norm perturbations and propagated output error. After short-depth normalization this is `O(log²(P+2))`.

The appendices preserve ordinary tanh throughout the final representation. The temporary identity branches used in the argument are either collapsed or replaced by replicated small tanh units. I found no hidden lookup-table or free-bias assumption.

## 5. Finite seed selection and bit precision

The final output moment bound satisfies `V>=1` by its unit-margin mean, while the expected work satisfies `T>=1`. Therefore `VT<=poly(B)` implies that both final bounds are polynomial, for `B=d+P+2`.

The grouping argument is valid with `ceil(40V)` independent estimators per group. Chebyshev gives probability at least `0.9` of additive error at most `1/2` for each input. With `O(d+1)` groups, Chernoff and the union bound cover all `2^d` inputs. The expected total formula size is polynomial because `ceil(40V)T=O(VT)` when `V>=1`.

I explicitly checked the dependence issue in the coefficient-selection event. A frequency draw at a tree address occurs after that address's existence and neuron type are determined. Its conditional distribution is the corresponding fresh `q_V`. Hence summing the conditional bad-frequency probabilities over all addresses is bounded by the common tail bound times the expected number of reached addresses. This does not require formula size to be independent of the frequencies. Combining this with the Markov size event and the all-input accuracy event leaves positive probability.

Internal deterministic second-moment and work bounds may be exponentially large or small. The manuscript only needs polynomial bounds on their logarithms. Its `Z_V` estimates are correct:

\[
Z_V\asymp\min(\sqrt V,1),\qquad A_V\asymp\sqrt V.
\]

The resulting recurrence has a constant multiplier per layer, and there are only logarithmically many layers. The original nonzero dyadic coefficients have polynomially bounded negative logarithms. Thus all internal logarithms remain polynomial. On the selected frequency event, the sampled coefficients also have polynomially bounded logarithmic magnitudes.

Rounding requires an absolute stability estimate, not relative accuracy of every tiny coefficient. Treating each constant occurrence as independent is legitimate because the object is a formula. It is multilinear in those occurrences over the real components. More explicitly, on a coefficient box of radius `M>=2`, a size-`s` formula's values and constant derivatives can be bounded by `(4M)^{O(s)}`. Summing the changes over `O(s)` occurrences shows that `poly(B)` bits suffice when `s=poly(B)` and `log M=poly(B)`. The selected good groups retain their sign uniformly over the cube.

Denominator clearing is also size-safe. At an addition, the two child numerators occur once each, while the subtree denominators are precomputed positive integer constants. Each denominator bit length is at most the sum of the leaf denominator bit lengths in that subtree. No recursively duplicated numerator tree is introduced.

## 6. Complex balancing

A subtree occurring once has a real-affine surrounding context even in the presence of real- and imaginary-part gates. For a complex subtree value `Q`,

\[
F=(F[Q=1]-F[Q=0])\Re Q
+(F[Q=i]-F[Q=0])\Im Q+F[Q=0].
\]

This identity is valid: every multiplication above the occurrence multiplies by an expression independent of `Q`; unary real/imaginary operations are real-linear. A balanced-size subtree exists in a binary/unary tree. The construction produces only a constant number of recursive subproblems of size at most `2s/3+O(1)`. Hence size remains polynomial and depth becomes logarithmic.

Expanding complex multiplication into real/imaginary pairs after this balancing incurs only a fixed duplication factor per logarithmic-depth level. Expanding before balancing would have been a real risk, but is not the argument used.

**Minor wording caveat:** read in complete isolation, the statement that every complex formula has an equivalent single real integer formula is false for a non-real output such as `i`. The argument requires a real final output, or else two real output formulas. The paper's Section 2 already imposes real final outputs and the proof explicitly uses that convention. This does not affect any formula constructed for the theorem.

Polynomial-bit integer constants can be synthesized with polynomial size and logarithmic depth from `-1,0,1`. The manuscript's balanced products and sums suffice, including when these constant subcircuits are attached below the balanced formula.

## 7. Independent direct construction for the final majority

The following argument validates the exact composition needed here, using the fact that more than two thirds of the selected integer outputs have the correct nonzero sign at each input. It is not a claim about arbitrary iterated positivity circuits.

Let `g_1,...,g_r` be the resulting integer formulas, and choose `M=2^m` with `m=poly(B)` so that all their values satisfy `|g_i(x)|<=M`. Such a bound follows directly from polynomial formula size and polynomial constant bit length; it also follows from their logarithmic circuit depth.

Put

\[
q=\frac32,\qquad J=10,\qquad
N=\left\lceil\log_q(64M)\right\rceil,
\]

and define the rational function

\[
S(t)=(q-1)\sum_{j=-J}^{N}
\frac{tq^j}{t^2+q^{2j}}.
\]

For positive `t`, the function `t/(t²+y²)` decreases with `y`. Comparing its integral with lower and upper rectangles on every interval `[q^j,q^(j+1)]`, then summing over all integers, gives

\[
I\le S_\infty(t)\le qI,\qquad
I=\int_0^\infty\frac{t}{t^2+y^2}\,dy=\frac\pi2.
\]

The lower rectangle sum is `S_infty/q`, by shifting its index; this establishes the second inequality without needing a delicate quadrature estimate. The tails omitted from the finite sum are at most

\[
q^{-J}/t+tq^{-N}.
\]

For `1<=t<=M`, this is less than `1/32+1/64=3/64`. Oddness then proves, for every nonzero integer `t` of magnitude at most `M`,

\[
a\le\operatorname{sign}(t)S(t)\le b,
\qquad
a=\frac\pi2-\frac3{64},\quad b=\frac{3\pi}4,
\]

while `S(0)=0`. Since

\[
2a-b=\frac\pi4-\frac3{32}>0,
\]

more than `2r/3` correct nonzero signs imply

\[
f(x)\sum_i S(g_i(x))>0.
\]

This remains true when every remaining group has the opposite sign and worst allowed magnitude.

To compile this into integer arithmetic, write `q^j=A_j/B_j` with positive integers `A_j,B_j` of `O(m)` bits. The summand without the common positive factor `q-1` becomes

\[
\frac{g_i A_jB_j}{B_j^2g_i^2+A_j^2}.
\]

Every denominator is a strictly positive integer on every real input. There are only `r(N+J+1)=poly(B)` summands. Multiplying by the product of all denominators gives an integer numerator, computable by parallel balanced products and a balanced sum. Even computing each omitted-factor product separately costs only a polynomial number of gates. The additional depth is `O(log B)`; constant synthesis adds the same order. Thus the final sign circuit has the advertised polynomial size and logarithmic depth.

This alternative uses no transcendental circuit constants: `pi` appears only in the analysis of the rational function. A numerical stress check at `M=2^30` over 4,001 logarithmically spaced positive test points found finite-sum values between approximately `1.91969` and `1.93703`, comfortably inside the proved interval `[1.52392,2.35620]`. The inequalities above supply the proof for all relevant inputs.

A separate agent independently checked the rectangle bounds, both tails, the supermajority inequality, and the denominator-clearing depth and size, finding no gap.

## 8. What this audit does and does not establish

The main structural theorem passes this fresh challenge audit under its exact global-margin, ordinary-tanh, and charged-bias conventions. Its existential and nonuniform nature is essential: the audit does not produce an efficient way to discover the good seed or compile arbitrary real input parameters.

The result provides the stated `PNC1` and `L/poly` representation constraint for polynomial-product families. It does not by itself provide a reverse compiler, an unconditional circuit separation, or an exponential-depth sample lower bound. The stronger Bayesian consequence still requires its separate posterior representation ceiling, and the published strengthening explicitly excludes the critical `gamma=1` endpoint. None of those limitations was removed by this audit.

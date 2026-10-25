# Quantified near-baseline PNC1 corollary for all Gaussian controls

25 October 2026. Finite-N audit agent. Scratch theorem assembly with the exact variational-path semantics. This is not a posterior theorem for unrestricted NNBayes.

Baseline correction, later on 25 October: the independently checked `gaussian-scalar-baseline-gap.md` proves a universal strict gap V_*^G>V_* between Gaussian and unrestricted scalar control. Section 3 below now uses the Gaussian class's own baseline. The earlier version using V_* was a valid conditional implication but became empty as its excess tended to zero with depth. The direct structural theorem in Sections 1–2 is unchanged.

## 1. The Gaussian path class has no hidden basis assumption

Use the canonical critical tanh model on the entire Boolean cube, with initial feature `h0(x)=(1,x)/sqrt(d)`, H>=1 hidden transitions, and a final readout v. At each stage the reference row is an isonormal Gaussian on the finite span of the preceding query vectors. A Gaussian control means an arbitrary Gaussian law on that span with mean m_j and positive covariance Sigma_j, having finite relative entropy

`D_j=(||m_j||^2+tr(Sigma_j-I-log Sigma_j))/2`.

Only the finite query span is relevant. If a larger Gaussian representation is supplied, marginalize to that span, which preserves the query law and cannot increase relative entropy. Transport it through the isometry identifying the current query kernel with the constructed Fock feature realization; then extend the covariance by identity and the mean by zero on the orthogonal complement of the query span. This yields an actual operator on the current countable coordinate space without rotating already constructed scalar formulas.

Its covariance square root is `I+K_j`, with

`||K_j||HS<=sqrt(2D_j)`, `||m_j||<=sqrt(2D_j)`,

`log_+||(I+K_j)^-1||op<=C(sqrt(D_j)+D_j)`.

The last estimate follows by applying the scalar Gaussian KL formula to an eigenvector with the smallest covariance eigenvalue. These bounds require neither finite coordinate support nor a lower bound on any nonzero matrix or vector entry. Finite entropy excludes a zero covariance eigenvalue on the relevant reference span.

The noncentral Hermite/Fock formula realizes the entire new query kernel exactly, including pairs with different variances and means. It is therefore legitimate to transport the next Gaussian control through its query-span isometry. This inductive construction preserves all final outputs after transporting/projecting the readout, with no increase in its norm.

## 2. Quantitative structural theorem

Suppose the path has global margin `f(x)<v,h_H(x)> >=1/2`, total action

`A=sum_j D_j+||v||^2/2`,

and square-root entropy sum `S_D=sum_j sqrt(D_j)`.

The audited noncentral variable-variance compiler and finite-bit completion imply a majority of rational arithmetic sign formulas, exact on the entire cube, with total size and coefficient bit lengths at most

`[(d+H+A+2) exp(C(S_D+A+1))]^C`.                   (1)

Equivalently it gives nonuniform PNC1 resources polynomial in the bracketed quantity, and hence the corresponding nonuniform logarithmic-space representation. Constants are universal.

To apply the compiler's unit-margin convention, multiply the final readout by two only *after* obtaining the bounds on the original path. This changes its norm by a fixed factor. It is not necessary, and would be incorrect for a sharp near-baseline budget, to rerun the occupation theorem with the quadrupled readout energy.

The initial norm squared is `(d+1)/d in[1,2]`. The deterministic envelope `G(q)=min(1,q/(1+q/2))` handles this first bounded step, then has all upper variances at most one. Its free iteration is bounded below by `c/(H+1)`, so no initial-normalization loss depends exponentially on H.

The final physical feature has norm at most one. Dividing it by its positive query norm preserves the readout sign and can only increase its signed margin. Thus an input-dependent final square root is not evaluated as an uncharged arithmetic operation. All computation is carried out through normalized direction and tracked relative-variance scalar oracles.

The artificial RMS floors and conditional Fourier-factory noise supply polynomial-bit realizations of a polynomial-size good seed. No lower bound on physical variances, nonzero Hermite coefficients, selected coordinates, sampling probabilities, or original parameter precision is required beyond the explicitly charged covariance minimum singular values, which are controlled by D_j above.

## 3. Near-baseline consequence, including nonattainment

Let V_*^G be the Gaussian scalar baseline for margin one half: the limit as starting variance tends to zero of the infimum of hidden Gaussian control entropy plus terminal scalar readout cost 1/(8q). The independently audited Gaussian Bellman/occupation argument in `gaussian-scalar-baseline-gap.md` gives, for every Gaussian path of action at most V_*^G+epsilon:

`sum_j sqrt(D_j) <= C[1+log(H+2)+sqrt(H epsilon)]`.   (2)

The Gaussian suffix argument is important: this is the Gaussian class's own occupation estimate, not an appeal to the unrestricted baseline. Combining (1)--(2) and `A<=V_*^G+epsilon`, with V_*^G an absolute constant below two, gives resources polynomial in

`(d+H+epsilon+2)
 exp[C(1+log(H+2)+sqrt(H epsilon)+epsilon)]`.        (3)

The final `+epsilon` is retained: the compiler pays for sum D_j as well as sum sqrt(D_j). It must not be dropped for arbitrary large epsilon.

Define `J_H^G(f)` as the infimum of the original action over all such Gaussian-control paths realizing f with global margin at least one half. If

`J_H^G(f)<=V_*^G+epsilon`,

choose a Gaussian path within `1/(H+1)` of that infimum. Its additional contribution to `sqrt(H epsilon)` is at most one, and its additional action at most one. Hence exactly the same resource form (3), with enlarged constants, holds without assuming an optimizer exists.

In particular, fix positive constants c,K and an ambient Q>=2. If

`d,H<=Q^K`, `H>=c log Q`,

`J_H^G(f)<=V_*^G+K log^2 Q/H`,

then f has a PNC1 circuit of size `Q^C`, with arithmetic coefficients of `Q^C` bit complexity and the standard logarithmic circuit depth in Q, where C depends only on c,K. Indeed `sqrt(H epsilon)<=sqrt(K)log Q` and `epsilon<=K log Q/c`. There are no additional basis, equal-diagonal, centeredness, or real-precision hypotheses.

## 4. Why this does not upgrade the original posterior ceiling

Let `J_H(f)` denote the unrestricted critical rate, whose row laws may be arbitrary finite-entropy tilts. The elementary inclusion is

`J_H(f)<=J_H^G(f)`.

Therefore a posterior ceiling on `{f:J_H(f)<=a}` does not imply a ceiling on the smaller Gaussian class `{f:J_H^G(f)<=a}`. The Gaussian weight prior does not make the conditioned/variational row laws Gaussian. Similarly, an anchor Rao--Blackwellization can have Gaussian conditional rows given anchor variables while the anchor law itself is non-Gaussian; this is not an all-Gaussian control of the kind compiled here.

In fact, the strict scalar gap gives the uniform lower bound `J_H^G(f)>=V_*^G-C/H>=V_*+delta-C/H`. Thus Gaussian controls cannot attain the unrestricted baseline at vanishing excess as depth grows. A Gaussian replacement preserving that vanishing excess is impossible. A new theorem for the original gamma=1 posterior instead needs a compiler that also handles the relevant non-Gaussian row tilts (or a replacement with a separately justified larger budget). This corollary is exact for every Gaussian path meeting its own-baseline budget; target-specific attainability of that budget is a separate construction question.

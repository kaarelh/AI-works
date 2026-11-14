# Independent review: architecture/Cauchy neural-network oracle

Date: 2026-11-14.

Reviewed source: `/workspace/agnostic-next/alternative/bayes-section.tex`, entire draft of 347 lines as present at review time.

## Verdict

No mathematical gap found. The parameter perturbation lemma, comparison-measure entropy, architecture truncation, activation generality, and stated rates are valid. The result is genuinely an expectation guarantee for the final Bayesian posterior mean under a different, explicit architecture prior. It does not establish the same guarantee for a fixed-width independent Gaussian weight prior.

## Architecture probability and normalization

For integers `L>=2`, `m>=1`, the proposed mass is

`omega_(L,m) = 1/[L(L-1)m(m+1)]`.

Both factors telescope:

`sum_(L=2)^infty 1/[L(L-1)] = 1`,

`sum_(m=1)^infty 1/[m(m+1)] = 1`.

Thus the unrestricted architecture prior is proper. Restricting to `L<=H,m<=N` and renormalizing divides these masses by a constant `Z_(N,H)<=1`, so every allowed architecture retains mass at least its unrestricted `omega`. This is exactly the direction needed for the bound independent of `N,H`.

There is no requirement that the architecture distribution have finite expected parameter count: bounded clipped predictions ensure the likelihood and posterior are well defined regardless of the heavy architecture tails.

## Parameter count

For `L-1` hidden layers, each width `m`, an input constant coordinate, no other biases, and a linear scalar readout,

`P_(L,m)=m(d+1)+(L-2)m^2+m`.

This is correct, including the single-hidden-layer case `L=2`, where it reduces to `m(d+2)`.

## Perturbation bound

Let the activation be globally Lipschitz, choose `a>=max(1,Lip(phi))`, and let `b=|phi(0)|`. A teacher has coordinate bounds `B>=1`. For a parameter perturbation of maximum coordinate size `r<=1`, both parameter vectors are bounded by `B+1`.

Set

`D=max(d+1,m)`, `A=1+b+aD(B+1)`, and `K=L A^L`.

The activation bound `|phi(u)|<=b+a|u|` gives a layerwise magnitude bound `M_l<=A^l`, starting with `M_0<=1`. Explicitly,

`b+aD(B+1)A^(l-1) <= [b+aD(B+1)]A^(l-1) <= A^l`.

The coordinatewise discrepancy satisfies

`delta_l <= aD r A^(l-1)+aD(B+1) delta_(l-1)`.

Since both coefficients `aD` and `aD(B+1)` are at most `A`, induction gives

`delta_l <= l r A^l`.

The readout discrepancy is bounded by

`D r A^(L-1)+D(B+1)(L-1)r A^(L-1) <= L r A^L`.

All maxima are uniform over the entire input cube; restricting to an arbitrary Borel subset preserves the estimates. The proof does not require bounded hidden activations or `phi(0)=0`.

This bound is deliberately coarse but correct. Its exponential sensitivity in `L` enters only through a logarithm in the oracle penalty.

## Continuous Cauchy prior and entropy

Conditionally on architecture, the prior has independent standard Cauchy coordinates. On the cube `||w-w_*||_infty<=r<=1`, the coordinate density is bounded below by

`1/[pi(1+(B+1)^2)]`.

Choose `Q` to be uniform on this cube, and concentrated on the teacher's architecture. Its density is `(2r)^(-P)` relative to Lebesgue measure on that architecture. The prior density on the same architecture includes a mass at least `omega_(L,m)`. Consequently

`KL(Q||pi_(N,H))`
`<= log(1/omega_(L,m))+P log[pi(1+(B+1)^2)/(2r)]`.

This uses an upper bound on the log density ratio pointwise on the cube. The prior has a positive density there, so `Q` is absolutely continuous and the entropy is finite. Heavy-tailed moments elsewhere are irrelevant because the model prediction and loss are clipped and bounded.

Set `r=rho/K` for `0<rho<=1`; indeed `r<=1`. Clipping is nonexpansive, so every predictor in the cube differs from the clipped teacher by at most `rho`, uniformly in input. Squared loss on bounded labels/predictions is 4-Lipschitz in the prediction, giving

`Q R <= R(clip g)+4rho`.

Applying the independently verified final-mean oracle with `eta=1/20` produces exactly the displayed NN theorem.

## Quantitative rates

At `rho=1/(n+1)`, the penalty is bounded by a numerical constant times

`[1+log(Lm)+P{log(n+1)+log(B+1)+log L+L log(1+b+a max(d+1,m)(B+1))}]/(n+1)`.

The apparent factor `2 log(B+1)` arising from the Cauchy density is absorbed in the numerical big-O constant. Thus no omitted polynomial factor in `B` or `L` is hidden here.

For fixed activation, `d`, `L`, and fixed `beta>=0`, competitors with `m<=n^alpha` and `B<=n^beta` have penalty `O(n^(2alpha-1) log n)`. This tends to zero for every `0<=alpha<1/2`. For `L=2`, the exact count is linear in `m`, yielding `O(n^(alpha-1) log n)` and every `0<=alpha<1`.

For varying depth, fixed activation and fixed weight bound, the leading polynomial is `mdL+m^2L^2`, up to logarithms and harmless `d+2` in place of `d`. This follows from multiplying `P=O(md+Lm^2)` by the `L log A` precision cost.

The bound permits a separate population-risk-minimizing comparator at each sample size: the comparison measure may depend on `D` and `n`, while the learner's prior itself is fixed independently of both. A finite weight cap is not specified to the learner. Nevertheless the theorem still depends quantitatively on the particular comparator's finite weight magnitudes; it does not imply uniform width-only approximation over arbitrarily large weights.

## Activation examples

- tanh and ReLU: `a=1,b=0`.
- GELU: `a=2,b=0`; the stated bound `|Phi(u)+u phi_gauss(u)|<=1+(2 pi e)^(-1/2)<2` is valid.
- softplus: `a=1,b=log 2`.

For internal biases, adjoining a constant input to each layer changes the parameter count and maximum fan-in; the same recurrence applies. This is a legitimate extension but should either be stated with the amended formulas or left as a remark, as in the present draft.

## Important interpretation limits

1. The maximum depth `H` denotes a mixture over actual depths `L<=H`; it is not a single fixed `H`-layer tanh architecture. A shallow tanh network cannot generally be embedded exactly into a deeper standard architecture by merely adding zero weights. Clarify this if the prose suggests otherwise.
2. At each fixed depth, the width mixture can indeed be embedded into a dense width-`N` parameter space with a structural sparsity prior. Set all connections entering or leaving inactive neurons to zero, and all inactive readout coefficients to zero. Even if `phi(0)` is nonzero, those constant inactive activations cannot influence active neurons or the output.
3. The theorem holds separately for every allowed `N,H`, with a bound independent of them. It is not a single high-probability event simultaneous over all architecture limits. The draft explicitly handles this correctly.
4. The architecture prior is not an iid product law on every coordinate of the maximum-width dense model. Complexity preference is explicitly supplied by model selection and prior mass, rather than derived from a dense Gaussian weight prior.
5. Clipping occurs in both likelihood and prediction. The result does not extend automatically to raw unbounded network predictions or raw-output squared likelihoods.
6. The conclusion concerns posterior means and arbitrary noise in expectation. It is not exact interpolation, a guarantee for a draw from the posterior, or an algorithmic claim about computing the posterior.

## Minor presentation suggestions

Define `R(f)` for an arbitrary measurable prediction function before introducing `R(h)=R(f_h)`, to make `R(hat f_S)` formally unambiguous. State explicitly that `H` is a maximum *available* depth in the architecture mixture. Neither point changes the mathematics.

No Lean formalization was performed. The review verifies the mathematical proof and quantitative statement as written, not computational tractability.

## Addendum: conditionally Gaussian scale mixture

Also independently checked the subsequent `Gaussian scale mixture` corollary in the updated `bayes-section.tex`. It is valid as stated.

The scale law `p_j=1/[(j+1)(j+2)]`, `j>=0`, telescopes to one. Conditional Gaussian variance `4^j` has standard deviation `s=2^j`. For `B>=1`, choosing `j_B=ceil(log_2 B)` gives `B<=s<=2B`. Every coordinate in the teacher cube has magnitude at most `B+r<=B+1<=2s`. Its Gaussian density is therefore at least `exp(-2)/(s sqrt(2 pi))`.

The uniform cube comparison measure has entropy contribution at most

`P log[s sqrt(2 pi) e^2/(2r)] <= P log[B sqrt(2 pi) e^2/r]`.

Selecting the architecture and latent scale adds respectively `log(1/omega_(L,m))` and `log[(j_B+1)(j_B+2)]`. Taking `r=rho/K` gives exactly the displayed bound. One can regard the comparison and posterior measures as living on the augmented architecture/scale/weight space; marginalizing the scale gives the same predictor, so there is no difficulty from the shared latent Gaussian scale.

The extra scale cost is `O(1+log(1+log B))`. Both the polynomial rates and their independence of maximum available width/depth remain unchanged. Coordinates are conditionally independent, but are not independent after integrating out the shared scale; the draft correctly states this distinction.

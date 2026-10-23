# Independent review: ReLU strong-prior learning

This is an independent mathematical audit of the proposed ReLU extension. It is a conventional proof check, not Lean verification. The review concerns the original globally margin-conditioned Gaussian learner at fixed finite width, followed by a sufficiently small prior variance. A finite-variance extension, if included, needs its own quantitative tail calculation.

## Result checked

Let a depth-`L` ReLU teacher, with `H=L-1` hidden layers and a linear readout, have width `C` and satisfy `f(x) z(x)>1/2` on the entire Boolean cube. Write

$$
P_* = \prod_{\ell=1}^{L}\|W_*^\ell\|_F,
\qquad A_H=1+\sqrt{2H\log 2}.
$$

There is a strong-prior sample bound independent of learner width, for every `N>=C`, of order

$$
\frac{d(d+1)P_*^2 A_H^2+\log(1/\delta)}{\varepsilon}.
$$

The prior variance threshold can depend on `N`, the teacher, and the requested posterior error, but not on the input distribution, sample size, or confidence. For fixed depth, a teacher with width `C` and every coefficient bounded by `C` has

$$
P_*^2\le(d+1)C^{4L-2},
$$

so this gives a polynomial in target width and input dimension. It does not give joint polynomial dependence on arbitrary depth.

## 1. Weighted energy and positive homogeneity

The original weighted energy is

$$
\kappa_N(W)=\frac dN\|W^1\|_F^2+
\sum_{\ell=2}^{L-1}\|W^\ell\|_F^2+N\|W^L\|_F^2.
$$

The product of its layer coefficients is exactly `d`. Consequently AM--GM gives

$$
\prod_{\ell=1}^{L}\|W^\ell\|_F^2
\le \frac1d\left(\frac{\kappa_N(W)}L\right)^L.
$$

Unlike a bounded activation, ReLU also allows the reverse construction at fixed product. Zero-pad a teacher to width `N`. Multiply its layer matrices by positive scalars whose product is one, choosing them so that all weighted squared layer norms become equal. Positive homogeneity preserves the exact output function. The resulting energy is

$$
K_*=L(dP_*^2)^{1/L}.
$$

No layer norm is zero: a zero layer would make the output identically zero and contradict the teacher's strict margin. Thus the balancing scalars are well defined. This works at every `N>=C`, without divisibility assumptions and without increasing depth. Taking an energy cutoff `(1+1/L)K_*` bounds the product of Frobenius norms by `sqrt(e) P_*`.

## 2. Width-independent Rademacher estimate

The following exponential-peeling argument verifies the sharper square-root-depth factor rather than merely invoking a norm theorem.

Normalize every layer Frobenius norm to at most one using positive homogeneity. For fixed sample inputs `x_i`, define `Z_h` to be the supremum, over the first `h` such ReLU layers, of the Euclidean norm of the Rademacher sum of their hidden vectors. At `h=0`, it is `||sum_i epsilon_i x_i||_2`.

Write each row of the last hidden matrix as `a_j u_j`, where `a_j>=0`, `||u_j||_2<=1`, and `sum_j a_j^2<=1`. ReLU homogeneity implies that

$$
Z_h=\sup_{\text{previous layers},\,\|u\|_2\le1}
\left|\sum_i\epsilon_i\,\mathrm{ReLU}(u^\top h_i)\right|.
$$

For the upper bound, the squared row contributions are at most the largest squared scalar contribution times `sum_j a_j^2`. Equality is available by using a single nonzero row. This reduction does not depend on the original width.

Split the exponential of the absolute supremum into its positive and negative suprema. Their expectations are equal by Rademacher symmetry. The convex contraction principle, applied to the nondecreasing function `exp(lambda t)` and the one-Lipschitz map ReLU with `ReLU(0)=0`, then gives

$$
\mathbb E e^{\lambda Z_h}
\le2\mathbb E e^{\lambda Z_{h-1}}.
$$

The class includes the zero function; no offset or absolute-value contraction constant is being silently discarded. Iteration contributes `2^H` outside the exponential. If `||x_i||_2<=R`, bounded differences and Cauchy--Schwarz give

$$
\mathbb E e^{\lambda Z_0}
\le \exp\left(\lambda R\sqrt n+\frac{\lambda^2 nR^2}{2}\right).
$$

Jensen's inequality and optimization in `lambda` yield

$$
\mathbb E Z_H\le R\sqrt n\left(1+\sqrt{2H\log2}\right).
$$

The final linear readout of norm at most one is exactly the Euclidean duality already present in `Z_H`. Rescaling the product of layer norms to `P` therefore proves

$$
\widehat{\mathfrak R}_n(\mathcal F_{L,P})
\le\frac{RP}{\sqrt n}A_H.
$$

For augmented Boolean inputs, `R=sqrt(d+1)`. The union over all finite widths has the same estimate: zero-padding nests the finite-width classes, and bounded outputs allow passage to the increasing union. Finite-dimensional compact classes and rational approximation also remove any measurability concern.

## 3. From margin complexity to a function count

If a Boolean function class is represented with absolute output margin greater than `1/2` and product norm at most `P`, shattering `m` points forces its real-output Rademacher complexity to be at least `1/2`: choose a margin-realizing network for each Rademacher labeling. The preceding estimate implies

$$
\mathrm{VCdim}\le4(d+1)P^2A_H^2.
$$

Use `P=sqrt(e)P_*` and an integer ceiling for the VC dimension. On the entire domain of `2^d` points, Sauer's lemma gives the sufficient bound

$$
\log|\mathcal H|\le v\log(2^d+1).
$$

This handles all widths together and avoids any finite real-weight encoding assumption. It gives a polynomial upper bound on the number of relevant Boolean functions; it does not by itself produce a small neural circuit for each of them.

## 4. Strong-prior concentration and statistical quantifiers

ReLU is continuous, so each strict all-input margin event `U_{N,g}` is open. The Gaussian large-deviation calculation in the original strong-prior paper needs only this openness and finite parameter dimension, not bounded hidden activations. Thus

$$
2\sigma^2\log\mu_{N,\sigma}(U_{N,g})\longrightarrow-\kappa_N(g).
$$

Let `A_N,f` contain every representable function with energy infimum no larger than the target's. Since the Boolean domain has finitely many functions, the ratio of prior mass outside this set to the target's prior mass tends to zero. Tied minimum-energy functions are all retained; no uniqueness assertion is required.

Every member of `A_N,f` has a strict-margin representative with energy below `(1+1/L)K_*`, because the target has a representative of energy `K_*` and the extra gap is positive. Therefore the function count in the previous section applies. The consistency-posterior Occam lemma gives posterior-averaged sign error at most `epsilon` once

$$
n\ge\frac2\varepsilon\left[v\log(2^d+1)+\log(1/\delta)\right]
$$

and the outside-to-target prior ratio is at most `epsilon/2`. This ratio is chosen before the sample and controls every posterior denominator, because the globally correct target event is consistent with every sample. The variance threshold is consequently independent of the distribution, `n`, and `delta`.

The same common low-product function class yields a single statistical event for all widths. The variance thresholds remain width dependent. A strict greater-than-`2/3` correct-label posterior-confidence guarantee follows by using posterior-average error budget `epsilon/3`. Majority sign error is at most twice posterior-average error.

## 5. Boolean circuits

On `0/1` wires, a NOR gate is exactly

$$
\mathrm{NOR}(a,b)=\mathrm{ReLU}(1-a-b).
$$

A constant-one wire is propagated by ReLU with weight one. At the first layer, substitute `a=(1+x_j)/2` into each gate's affine input. Copy gates and NOT gates are also ReLU-affine on the finite wire alphabet. A final readout `2a-1` produces exact Boolean values `-1,+1`, and hence the required strict margin. An arbitrary bounded-fan-in Boolean circuit can first be compiled into NOR gates, counting the resulting depth and width overhead and all constant wires. This gives a concrete ReLU teacher; universal approximation is unnecessary.

## Caveats that must remain in the final presentation

- The strong-prior argument does not automatically prove the entire `gamma>=1` regime at prescribed nonzero variance. The additional calculation below covers every depth at `gamma>=2`, and one hidden layer at `gamma>=1`.
- The count of margin functions follows from Rademacher complexity and VC dimension. It does not establish polynomial equivalence between minimum ReLU energy and small same-depth neural-circuit complexity.
- Joint polynomial depth dependence remains unproved here; the product of layer norms can grow exponentially with depth.
- The proof concerns exact Bayesian conditioning with positive training margins. It does not identify SGD with this posterior.
- The globally margin-conditioned theorem uses the finite Boolean domain. A raw-prior, hard-training-margin version may be proved by a separate uniform-convergence argument, including compact continuous domains, but that is a distinct statement.

## Final-source review

The final standalone ten-page paper was checked in full after addition of the finite-variance theorem and its shallow extension. Source SHA-256: `f360785cfcb15cf2dc74b1b6d4997cede19612394b896f0e89ba2958d0c39ac4`. PDF SHA-256: `bd8dfe21ccf05fc2251ce63591e08709dbecb0c276b98dd4ea0ac9a2dd0a9370`. These supersede the earlier eight-page strong-prior-only snapshot.

The main theorem, exact balancing lemma, self-contained exponential-contraction proof, VC/Sauer count, Gaussian-rate proof, strict posterior-confidence corollary, NOR implementation constants, and finite-variance theorem all check out. In particular, first-layer NOR/COPY/NOT rows have squared norm at most one after substituting Boolean input bits; later rows have squared norm at most five even when an input is repeated. The sparse Boolean-circuit product bound `(5C)^(L-1)` is valid. The finite-variance neighborhood estimate correctly cancels parameter dimension against Gaussian variance, leaving no hidden `log N` cost. Its identical-constant extension to `L=2, gamma>=1` is valid.

The PDF has no unresolved references or LaTeX warnings. Its log contains one harmless underfull horizontal-box report in the final bibliography URL. Mathematical status: no unresolved issue found. This remains an independent AI-agent review, not a Lean proof or human peer review.

## Additional calculation: finite exponents at least two

There is also a direct positive result at the prescribed nonzero variances for every `gamma>=2`. This conclusion uses a quantitative argument in addition to the strong-prior proof above.

Put `U^ell=sqrt(c_ell) W^ell`, with the weighted-energy coefficients from section 1. Homogeneity gives the exact identity

$$
z_W(x)=d^{-1/2}F_U(\bar x),\qquad
\kappa_N(W)=\sum_\ell\|U^\ell\|_F^2,
$$

where `F_U` is an ordinary ReLU network with matrices `U`. Under the finite-exponent prior all entries of `U` are independent centered Gaussians of variance `sigma^2=N^{-gamma}`. The total number of coordinates is

$$
D_N=N(d+2)+(L-2)N^2,
\qquad D_N\sigma^2\le S:=d+L.
$$

First double the teacher's output, so that every signed output is greater than one, and then balance its weighted layer norms. Write `K` for this balanced energy and `U_*` for the result. Set

$$
r=\min\left\{1,
\frac{1}{4\sqrt{2L}(\sqrt{K/L}+1)^{L-1}}\right\}.
$$

Telescoping the network layers and using the one-Lipschitz property of ReLU proves

$$
\sup_x|z_{U_*+\Delta}(x)-z_{U_*}(x)|
\le\sqrt{2L}\,\|\Delta\|_F
       (\sqrt{K/L}+1)^{L-1}\le\frac14
$$

for `||Delta||_F<=r`. Here the global Frobenius norm combines all layer entries. Therefore the entire Euclidean ball `B(U_*,r)` lies inside the target's strict-margin event.

For a centered `D_N`-dimensional Gaussian `G` of variance `sigma^2`, the coordinate cube of side `2r/sqrt(D_N)` implies

$$
\Pr(\|G\|_2\le r)
\ge\left[\frac13\min\left\{1,
\frac{r}{\sigma\sqrt{D_N}}\right\}\right]^{D_N}.
$$

This uses `Pr(|Z|<=a)>=(1/3)min(1,a)` for a standard Gaussian. Comparing the shifted density with the centered density inside that ball gives

$$
\Pr(G\in B(U_*,r))\ge
\exp\left[-\frac{K/2+r\sqrt K}{\sigma^2}\right]
\Pr(\|G\|_2\le r).
$$

Consequently its negative log mass, multiplied by `sigma^2`, is at most

$$
B=\frac{(\sqrt K+r)^2}{2}
+S\log\left(3\max\left\{1,\frac{\sqrt S}{r}\right\}\right).
$$

The extra `r^2/2` in this formula is harmless slack. This cost is independent of learner width.

The Gaussian energy moment is exactly

$$
\mathbb E\exp\left(\frac{\kappa_N}{4\sigma^2}\right)=2^{D_N/2}.
$$

For `tau` in `(0,1)`, set

$$
T=4\left[B+\frac S2\log2+\log(1/\tau)\right].
$$

The ratio between the prior probability of `kappa_N>T` and that of the target ball is at most

$$
\exp[-\log(1/\tau)/\sigma^2]\le\tau,
$$

since `sigma^2<=1`. This controls the posterior's high-energy tail on every training sample. Use the class of globally margin-separated functions having at least one representation of energy at most `T`. Its product norm is at most `d^{-1/2}(T/L)^{L/2}`, so the same VC argument gives the valid integer bound

$$
v_T=\left\lceil
\frac{4(d+1)}d (T/L)^L A_H^2
\right\rceil.
$$

With `tau=epsilon/2`, the same sufficient sample requirement is

$$
n\ge\frac2\varepsilon
\left[v_T\log(2^d+1)+\log(1/\delta)\right].
$$

All formulas are polynomial in bounded-weight teacher width and dimension at fixed depth, with extra logarithms of inverse accuracy. No strong-prior limit is taken in this extension. It applies simultaneously to all eligible widths and all exponents at least two. For a single hidden layer, `L=2`, the number of parameters is only `D_N=N(d+2)`, so `D_N sigma^2<=d+2=S` already at every `gamma>=1`. The exact same proof and constants therefore cover the full mean-field-or-stronger family in the shallow case. For deeper networks the proof does not cover `1<=gamma<2`, since its bound on the unconditioned total Gaussian energy fails there.

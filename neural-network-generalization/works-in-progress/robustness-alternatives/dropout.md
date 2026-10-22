# Dropout stability as an alternative to neuron merging

Research note, 22 October 2026. The theorem is a mathematical derivation, not a Lean verification or a claim that ordinary training satisfies its assumptions. A separate small diagnostic below reports exploratory measurements on existing checkpoints.

## Main conclusion

There is a genuinely different sufficient condition: the network's clipped predictions survive **random neuron subsampling**, with inverse-retention rescaling, down to a number of neurons controlled by its readout energy. No partition into neuron populations is required in the condition or its compression proof.

For tanh networks this gives a rigorous sample bound quadratic in Boolean teacher width up to logarithms, polynomial in depth, in the strong-prior regime and at every finite Gaussian scaling `gamma >= 2`. Every eligible Boolean circuit has a quantitatively large prior neighborhood satisfying the condition. A full weighted parameter ball, rather than the usual free-bulk cylinder, supplies that neighborhood.

This is easier to explain in terms of dropout than an existential neuron-merging condition, but it is still a strong compression assumption. For the Boolean teacher witnesses, `O(C log(LC))` retained neurons suffice when the original width can be arbitrarily larger than `C`. The general support condition instead uses each network's own readout-energy/output-amplitude ratio to set its retained count. Ordinary dropout with a fixed retention fraction does not establish it. The mean-field extension remains open: the existing cheap teacher cylinder is not stable under this severe subsampling.

## Exact model and condition

Let `H=L-1`, `L>=2`, and let the input domain be the Boolean cube. The network has `H` width-`N` tanh hidden layers, augmented input `bar x=(x,1)`, and linear readout `v`. Put

$$
\kappa_N(w)=\frac dN\|W^1\|_F^2+
 \sum_{s=2}^{H}\|W^s\|_F^2+N\|v\|_2^2,
\qquad E_v=N\|v\|_2^2,
$$

$$
M(w)=\max_x|z_w(x)|,
\qquad T(u)=\mathrm{clip}(u,-1/2,1/2),
\qquad R(w)=E_v/M(w)^2.
$$

Set `R=0` when `M=0`; this case cannot fit a nonempty training sample. Fix the absolute constant `A0=2^16`, and define

$$
q(w)=\left\lceil A_0(1+R(w))
             \log\bigl(4L(1+R(w))\bigr)\right\rceil,
\qquad m(w)=\min\{N,q(w)\}.
$$

Independently at every hidden layer, choose a uniform subset of exactly `m` neurons. Retain those first-layer rows. Retain the corresponding submatrices in later layers and multiply their entries by `N/m`; retain the corresponding readout coordinates and multiply them by `N/m`. Denote the resulting ordinary width-`m` network by `D_m(w)`. When `m=N` this is the identity operation.

The proposed prior support is

$$
\mathcal D_N=\left\{w:
 \Pr_{\mathrm{masks}}\left[
  \max_x|T(z_{D_{m(w)}(w)}(x))-T(z_w(x))|\le1/16
 \right]\ge3/4\right\}.
\tag{D}
$$

This is a label-independent Borel condition: there are finitely many inputs, integer choices of `m`, and masks at each fixed width. Its retention budget is invariant under readout rescaling. The fixed clipped-output comparison still has the same output-scale convention as the other robust-prior results.

Condition (D) is not neuron merging. It selects actual neurons and actual edges and only rescales the retained edges. It does not average rows, impose equal populations, or project onto population-constant states. Population arguments appear below only to prove that Boolean targets have suitable implementations.

## A compression identity and a quadratic counting bound

For every fixed parameter array `w` and every `1<=m<=N`, independent uniform masks satisfy

$$
\mathbb E_{\mathrm{masks}}\kappa_m(D_m(w))=\kappa_N(w).
\tag{1}
$$

For the first layer, each row is retained with probability `m/N`; its energy coefficient is `d/m`. For an internal matrix, every edge is retained with probability `(m/N)^2`, while its retained weight is multiplied by `N/m`. For the readout the coefficient is `m`, retention probability `m/N`, and squared rescaling `(N/m)^2`. These give the three terms of (1). The same identity holds for a parameter perturbation `w-w_*`, because the sampling map is linear in parameters.

Suppose `w` fits a nonempty training sample and `kappa_N(w)<=K`. Then `M(w)>1/2`, so

$$
R(w)\le4E_v\le4K,
\qquad m(w)\le Q:={\left\lceil
A_0(1+4K)\log(4L(1+4K))\right\rceil}.
$$

Markov's inequality and (1) give compressed energy at most `4K` with probability at least `3/4`. Its intersection with the event in (D) has probability at least `1/2`. Hence every retained predictor has an ordinary tanh reconstruction of width at most `Q`, energy at most `4K`, and uniform clipped discrepancy at most `1/16`.

Every reconstruction weight has magnitude at most

$$
B_w=2\sqrt{QK}.
$$

Pad with zero neurons to width `Q`. Put

$$
A_g=(d+1+Q)(B_w+2),\qquad
\zeta=(32L A_g^L)^{-1},\qquad
P=Q(d+2)+(L-2)Q^2.
$$

Rounding all weights to a fixed grid of mesh at most `zeta` changes the output by at most `1/32`. Indeed, tanh is bounded by one and 1-Lipschitz; the layerwise maximum-coordinate error obeys

$$
e_1\le(d+1)\zeta,\qquad
e_s\le Q(B_w+1)e_{s-1}+Q\zeta,
$$

with the same last recurrence at the readout. The loose bound `L zeta A_g^L=1/32` suffices. Thus one finite grid class, independent of learner width and prior scale, has logarithmic cardinality at most

$$
J(K)=P\log(3+4B_w/\zeta).
\tag{2}
$$

It approximates every supported energy-`K` predictor in clipped score to `3/32`. In particular,

$$
J(K)=\widetilde O\bigl(LdK+L^2K^2\bigr),
$$

where the suppressed factors are logarithmic in the displayed resources. This is polynomial in depth and quadratic in `K` up to logarithms. No product of downstream operator norms appears outside a logarithm in the count.

## A dropout-stable Boolean implementation

Let a Boolean target have `H` layered stages and width `C`, with NAND, COPY, and NOT gates in the `{-1,+1}` convention. A constant `+1` wire is propagated at every stage and counted in `C`; any conversion to this convention must count its overhead. Let `N>=C`.

Partition the physical neurons into `C` clone groups of sizes `k_a` differing by at most one. Then

$$
\frac1{2C}\le\frac{k_a}{N}\le\frac2C,
\qquad \frac{k_a}{k_b}\le2.
$$

Use fixed gain `A=8`. The logical preactivation is `A(1-a-b)` for NAND, `Aa` for COPY, and `-Aa` for NOT, with the constant wire supplying the one after the first stage. Divide every incoming coefficient by the size of its source clone group. Read out the designated output group with coefficients `4/k_out`.

Take both the logical-state tolerance and relative population-count tolerance to be

$$
\eta=\delta_0=1/16.
$$

If every logical source state differs from its intended sign by at most `eta`, and every sampled source population contributes a factor `r_a` in `[1-delta0,1+delta0]`, each multiplied source differs from its intended sign by at most

$$
\delta_0+(1+\delta_0)\eta=33/256.
$$

There are at most three signed terms in any logical preactivation, including the constant. Therefore its signed magnitude is at least `A/2`. Since

$$
1-\tanh(A/2)\le2e^{-A}<1/16,
$$

the state tolerance is restored at every layer, without accumulating an error factor through depth. This also handles the constant wire. The first layer starts from exact input signs and the exact augmented constant.

For a mask of size `m`, define `r_{s,a}=N n_{s,a}/(m k_a)`, where `n_{s,a}` is the retained count in population `a`. Hypergeometric concentration gives

$$
\Pr\{\exists s,a:\ |r_{s,a}-1|>\delta_0\}
\le2HC\exp\{-\delta_0^2m/(6C)\}.
\tag{3}
$$

Thus

$$
m\ge (6C/\delta_0^2)\log(100HC)
\tag{4}
$$

makes the good-count event have probability at least `49/50`. On that event the compressed network computes the correct Boolean sign everywhere, and its signed output is at least

$$
4(1-\delta_0)(1-\eta)>3.
$$

The uncompressed teacher has signed output at least `4(1-eta)>3`. Both clipped outputs are exactly `f/2`.

The teacher energy is bounded by

$$
B=5dA^2+10(H-1)CA^2+32C
 =320d+640(H-1)C+32C.
\tag{5}
$$

The first logical row has squared coefficient norm at most `5A^2`, including repeated gate inputs. Internal clone weights have squared Frobenius norm at most `2` times the sum over the `C` logical rows, hence at most `10CA^2` per layer. Finally `8C<=E_v<=32C`.

On the good-count event the compressed teacher energy is at most `2B`: the first-layer energy picks up one factor `r_{1,a}`, an internal term picks up a product `r_{s,b}r_{s-1,a}`, and the readout energy picks up one factor. All are at most `(1+delta0)^2<2`.

For the clean teacher, `C/2<=R<=3C`. More generally the ball constructed next has `R>=C/4`. If `m<N`, the specified choice `A0=2^16` and `R>=C/4` imply (4). One elementary check is

$$
\log(100HC)\le8\log(LC),\qquad
A_0(1+R)\log(4L(1+R))\ge(A_0C/4)\log(LC),
$$

and `A0/4=16384>48/delta0^2=12288`. If `m=N`, the dropout operation is the identity and no concentration bound is needed.

## A quantitative whole neighborhood, not just an isolated implementation

Use weighted coordinates

$$
U_1=\sqrt{d/N}W^1,\qquad U_s=W^s\ (2\le s\le H),
\qquad U_L=\sqrt N\,v^\top.
$$

Their combined squared Euclidean norm is `kappa_N`. Hidden states normalized by `sqrt(N)` have activation `tanh(sqrt(N)t)/sqrt(N)`, which remains 1-Lipschitz and zero at zero. Therefore, for any two same-width parameter arrays whose weighted-coordinate distance is at most `r<=1`, and with the first array's energy at most `B0`, telescoping the `L` layer replacements gives

$$
\sup_x|z_w(x)-z_{w_*}(x)|
\le \sqrt{2L}\,r(\sqrt{B_0}+1)^{L-1}.
\tag{6}
$$

Define

$$
r_1=\bigl[8\sqrt{2L}(\sqrt{2B}+1)^{L-1}\bigr]^{-1},
\qquad r_0=r_1/10.
\tag{7}
$$

Every parameter array in the weighted ball `||U-U_*||_2<=r0` has original outputs within `1/4` of the teacher. In particular it computes `f` with margin greater than one and `M<=17/4`. Also

$$
\sqrt{E_v(w)}\ge\sqrt{8C}-r_0\ge(5/2)\sqrt C,
$$

so `R(w)>=C/4`. This gives the count probability from (3) at the mask size selected by this perturbed network's own budget; no continuity of the ceiling function is needed.

For every such fixed mask size, (1) applied to the perturbation gives

$$
\mathbb E\kappa_m(D_m(w)-D_m(w_*))\le r_0^2.
$$

With probability at least `99/100`, this compressed perturbation has norm at most `r1`. Intersect with the good-count event, of probability at least `49/50`. On the intersection the compressed teacher has energy at most `2B`, so (6) at width `m` bounds the output change by at most `1/4`. The compressed perturbed network still has signed output greater than one at every input. Its clipped output and the original perturbed network's clipped output both equal `f/2`.

The intersection has probability at least `97/100`, exceeding `3/4`. Consequently the **entire weighted ball of radius `r0` lies in the proposed dropout support and in the all-input correct-margin event**. Its radius has

$$
\log(1/r_0)=O\bigl(L\log(2+B)+\log(2+L)\bigr),
$$

which is polynomial in depth and only logarithmic in circuit width.

## Gaussian prior mass and the finite-scale theorem

The raw prior has variances `t^2/d`, `t^2/N`, and `t^2/N^2` in the first layer, internal layers, and readout. In the weighted coordinates above, every variance is

$$
\sigma^2=t^2/N.
$$

Assume `t^2<=1/N`, equivalently `sigma^2<=1/N^2`. This includes every `gamma>=2` in the usual scaling `t=N^((1-gamma)/2)`. Let

$$
p=N(d+2)+(L-2)N^2,\qquad S=d+L+1.
$$

Then `p sigma^2<=S`. An elementary Gaussian ball bound gives

$$
\mu_{N,t}\{\|U-U_*\|\le r_0\}
\ge\exp\{-D_*/\sigma^2\},
\qquad
D_*=B+1+S\log(2\sqrt S/r_0).
\tag{8}
$$

For completeness, integrate the Gaussian density over the cube centered at `U_*` with coordinate half-width `a=min(r0/sqrt(p),sigma)`. On that cube, `||U||^2<=2B+2r0^2`. Its Gaussian probability is at least

$$
e^{-(B+1)/\sigma^2}
 \left[\sqrt{2/\pi}\min\{1,r_0/(\sigma\sqrt p)\}\right]^p.
$$

Use `p sigma^2<=S`, `S>=1`, and `r0<=1` to obtain (8).

Condition the prior on (D), optionally also on the all-input absolute-margin event. Train by conditioning on `f(X_i)z_w(X_i)>1/2`. The target ball lies in every training event, so its raw mass lower-bounds every posterior normalizer. Choose

$$
K=4D_*+2S\log2+4\log(2/\varepsilon).
\tag{9}
$$

Since `kappa_N/sigma^2` is chi-square with `p` degrees of freedom,

$$
\frac{\mu_{N,t}\{\kappa_N>K\}}
     {\mu_{N,t}(\text{target ball})}
\le
\exp\left[-\frac{K/4-D_*}{\sigma^2}
                  +\frac p2\log2\right]
\le\varepsilon/2.
\tag{10}
$$

Use `Q,B_w,zeta,P,J(K)` from (2). If

$$
n\ge\frac2\varepsilon\left[J(K)+\log(1/\delta)\right],
\tag{11}
$$

then one iid training-sample event of probability at least `1-delta` gives

$$
\mathbb E_{w\mid S}\Pr_X\{f(X)z_w(X)\le1/4\}\le\varepsilon
$$

simultaneously for every `N>=C` and every `0<t<=N^(-1/2)`.

To verify the statistical step, a retained predictor has a grid approximation of clipped discrepancy at most `3/32`. Every training score for that approximation is at least `13/32`, whereas an original test-margin failure implies grid signed score at most `11/32`. If that bad-input set has mass greater than `epsilon/2`, a training sample avoiding it has probability at most `exp(-n epsilon/2)`. Union-bound over the common grid class. Add the posterior mass from (10). The class does not depend on width or scale, so the same sample event works for all of them.

At each fixed width the permitted interval includes every sufficiently strong prior. Thus (11) also proves the strong-prior-limit result. This theorem is **not** being asserted at `1<=gamma<2`.

From (5), (7), and (8),

$$
D_*=O\bigl(d+LC+(d+L)L\log(2+d+LC)\bigr).
$$

Consequently the bound is polynomial jointly in depth and input dimension, and quadratic in `C` up to logarithms when other parameters are fixed. It has the usual leading `1/epsilon`, with only logarithmic additional accuracy dependence in `K` and the retention budget.

## What this says about naturality

**A useful operational interpretation.** Condition (D) asks whether random removal of redundant neurons preserves predictions, rather than asking for a particular grouping of neurons. It can be tested on a specified collection of inputs with independently sampled masks. Training with dropout, multiplicative noise, or explicit sparsification objectives is relevant motivation.

**It is stronger than ordinary dropout practice.** A fixed 50% retention rate leaves `Theta(N)` neurons and does not produce this width-independent theorem. Here retention can be `m/N -> 0`. Evidence about modest dropout rates does not establish stability at these much more severe rates. Nor does testing finitely many held-out points certify the all-cube condition. The large absolute constants here are proof constants, not empirically justified thresholds.

**An expected-error version is sufficient if it controls the same uniform event.** For example,

$$
\mathbb E_{\mathrm{masks}}
 \max_x|T(z_{D_m(w)}(x))-T(z_w(x))|^2
\le (1/16)^2/4
$$

implies (D) by Markov's inequality. A pointwise expectation guarantee for each input is weaker and does not automatically give one mask working everywhere. A stochastic-compression proof could use it, but fixed reconstruction failure would create an accuracy floor unless the failure is driven down with the requested learning accuracy. This has not been derived here.

**Gaussian-noise flatness is a different condition.** Independent isotropic hidden noise need not control the correlated perturbations created by neuron sampling. Requiring stability under every noise distribution with a second-moment bound largely reintroduces adversarial robustness, because symmetric two-point noise can concentrate on any chosen direction. Standard local PAC-Bayes flatness also does not on its own yield the all-width Bayesian theorem: its Gaussian KL and volume terms can still grow with the learner parameter count.

**Spectral and covariance conditions are promising certificates, not completed substitutes.** Products of spectral norms and effective ranks can give useful norm-based generalization bounds, but a polynomial-depth guarantee requires the product itself to stay controlled. That need not hold for ordinary Boolean gate implementations. Small layer covariance rank alone does not give a small ordinary network after a nonlinearity; an arbitrary subspace is not preserved by coordinatewise tanh. Noise-stability/layer-cushion conditions from compression-based generalization theory are more directly motivated by trained-network behavior and merit a separate quantitative NNBayes analysis. Their teacher prior mass and the desired quadratic-width calibration have not been proved in this note.

### A small diagnostic on already-trained networks

An exploratory diagnostic applied the exact subsampling operation to twelve existing frozen Adam-trained tanh checkpoints from the neuron-merging naturality study: widths 32 and 64, two or three hidden layers, and the majority-of-five, parity-of-three, and recursive-majority-of-nine tasks on all 512 inputs of the nine-dimensional cube. There was no new training, no fine-tuning after pruning, and no dropout during the original training. Each retained width used 100 independent masks. The reproducible script is `check_dropout.py`; complete float64 results and checkpoint hashes are in `dropout-diagnostic.json` beside this note.

The four majority models classified the entire cube correctly with clean margins above `1/2`. Nevertheless:

| Hidden depth, original width | Uniform clipped-preservation successes at 50% retention | At 75% retention | Mean sign disagreement at 75% retention |
|---|---:|---:|---:|
| 2, 32 | 1/100 | 21/100 | 0.2% |
| 2, 64 | 0/100 | 6/100 | 0.6% |
| 3, 32 | 0/100 | 7/100 | 1.3% |
| 3, 64 | 0/100 | 7/100 | 1.3% |

Across all twelve models, subsampling to `ceil(R)` neurons gave zero successes in 100 masks. These are Monte Carlo observations, not exact failure-probability certificates. Several parity and recursive-majority models also had imperfect clean predictions or weak clean margins, so they should not be treated as equivalent positive tests of the theorem's intended target neighborhood.

This small convenience sample supplies **no positive evidence for severe dropout stability of ordinarily trained networks**. It also illustrates why good average accuracy under modest dropout is weaker than preserving the whole clipped function. As a consistency check, the empirical mean compressed energies were close to the exact expectation in (1).

The theorem's deliberately conservative `A0=2^16` would choose `m=N` for all these small models, making a literal test of that calibration vacuous. The informative empirical object is therefore the entire retention curve, or the smallest retention achieving a specified success probability, compared across model sizes and training methods. A useful follow-up would compare ordinary training with explicitly dropout-trained or compression-trained networks, and separate full-cube preservation from average held-out error.

## Why the mean-field extension is still open

There is a concrete obstruction to reusing the current inexpensive target cylinder. Let one free Gaussian bulk row have covariance

$$
E\sim\mathcal N\left(0,\frac{t^2}{N}
  [I-\boldsymbol1\boldsymbol1^\top/N]\right).
$$

Its clean action on the constant clone state is exactly zero. For a uniform retained subset of size `m`, let `a=(N/m)1_S`. Then

$$
\mathbb E(Ea)^2=t^2(N/m-1).
$$

At mean field (`t=1`), a fixed retained width amplifies this otherwise harmless bulk without bound as `N` grows. This exact calculation already appears in the neuron-merging naturality paper's dropout discussion. Our full-ball replacement avoids it when `gamma>=2`, because `p sigma^2` is uniformly bounded. At mean field `p sigma^2` grows like `N`, and that ball's negative-log-mass coefficient is no longer width-independent.

This is an obstruction to these proofs, not a theorem that every dropout-conditioned mean-field learner fails. A different sufficiently large family of dropout-stable target implementations might work. At present the rigorous alternative established here covers the strong-prior regime and `gamma>=2` only.

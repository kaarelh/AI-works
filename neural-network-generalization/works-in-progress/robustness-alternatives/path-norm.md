# Norm restrictions as alternatives to neuron-merging stability

Research note, 22 October 2026. These are mathematical arguments and an assessment of their scope, not Lean-verified results or evidence about ordinary SGD-trained networks.

There is a clean alternative with a standard mathematical interpretation: **restrict a ReLU prior by an absolute path-norm budget.** It gives polynomial dependence on depth and quadratic dependence on that norm budget, at every learner width and every positive Gaussian scale. Every Boolean *formula* with `s` gates has an implementation with path norm at most `4s+3`. Thus a width-`C`, depth-`L` formula teacher gives a genuinely quadratic-in-`C`, polynomial-in-`L` bound. This does not establish the same norm bound for every small Boolean *circuit*, where intermediate results may be reused.

The restriction is a conventional norm budget fixed before seeing labels. Unlike neuron-merging stability, it does not directly require that a particular compression succeed. Its limitation is that the guarantee is in the declared norm budget, and small ordinary circuit width does not presently imply a polynomially small path budget in our argument.

## 1. The norm and the exact ReLU capacity bound

Use the existing architecture: `H=L−1` hidden layers, augmented input `x̄=(x,1)` with `x∈{−1,1}^d`, ReLU hidden activations, and linear readout. Define the absolute ℓ¹ path norm by

$$
 \mathcal P(w)=|v|^\top |W^H|\cdots|W^1|\mathbf1_{d+1}.
$$

This sums the absolute product of weights along every input-to-output path, including paths beginning at the constant input. It can be computed by one forward pass through the absolute-weight network. It is invariant under the usual positive rescaling of a ReLU neuron and compensating inverse rescaling of all its outgoing edges. It is also invariant under exact cloning into any positive integer group sizes: copies multiply the number of paths and division among source clones cancels this multiplication.

**Lemma (capacity).** Let `F_R` be the union over all finite hidden widths of depth-`L` ReLU outputs with `P(w)≤R`. On any `n` inputs in the unit ℓ∞ ball,

$$
 \widehat{\mathfrak R}_n(F_R)
 \le R\sqrt{\frac{2D_L}{n}},
 \qquad D_L=L\log2+\log(d+1).
$$

Here the Rademacher complexity is `E sup_f n^{-1}Σ_i ε_i f(x_i)`.

*Proof.* Set `p_j^1=Σ_i|W^1_{ji}|` and recursively `p_j^s=Σ_i|W^s_{ji}|p_i^{s−1}`. A neuron with `p_j^s=0` is identically zero. Positive homogeneity writes every other normalized neuron `h_j^s/p_j^s` as ReLU applied to an absolute convex combination of preceding normalized neurons. All these neurons are bounded by one on the input set. The final output is an absolute convex combination of the last normalized neurons with coefficient sum at most `R`.

Let `G_0` consist of the input coordinate functions, including the constant coordinate, and let `G_s=ReLU(aconv(G_{s−1}))`, where `aconv` includes zero and signed convex combinations. Define

$$
 Z_s(\epsilon)=\sup_{g\in G_s}\left|\sum_{i=1}^n\epsilon_i g(x_i)\right|.
$$

The convex exponential form of the scalar Rademacher contraction inequality, and the identity that a linear supremum over an absolute convex hull equals its absolute supremum over the generating class, give

$$
 \mathbb E e^{aZ_s}\le2\mathbb E e^{aZ_{s-1}}\quad(a>0).
$$

The factor two accounts for the two signs of the absolute supremum. At depth zero, Hoeffding's scalar moment bound gives

$$
 \mathbb E e^{aZ_0}
 \le2(d+1)e^{a^2n/2}.
$$

Consequently `E exp(aZ_H)≤2^{H+1}(d+1)exp(a²n/2)`. Jensen's inequality and optimization in `a` imply `E Z_H≤sqrt(2nD_L)`. Multiplying by `R/n` proves the claim. Suprema can be taken over countable dense restrictions or over finite subsets followed by a limit; the Rademacher probability space is finite. ∎

**Corollary (finite Boolean function class).** Let `B_R` be the sign functions having a globally strict-margin implementation `|z(x)|>1/2` and path norm at most `R`, at some finite width. Set

$$
 v_R=\left\lceil8R^2D_L\right\rceil.
$$

Then

$$
 \log|B_R|\le v_R\log(2^d+1).
$$

Indeed, shattering `n` inputs with margin greater than `1/2` forces empirical Rademacher complexity at least `1/2`; the lemma gives `n≤8R²D_L`. Sauer's lemma then gives the stated count on the Boolean cube. This is a count of one function class common to all learner widths.

## 2. A complete Bayesian theorem at every width and scale

Fix `R` **before seeing the training labels**. Restrict any full-support Gaussian parameter prior to

$$
 \mathcal P(w)<R,
 \qquad |z_w(x)|>1/2\quad\hbox{for every Boolean input }x.
$$

The original variance choices `t²/d`, `t²/N`, and `t²/N²` are allowed at every `t>0`; the proof does not require `t≤1` or a particular scaling exponent. More generally the unconditioned density may be any everywhere-positive continuous density.

**Theorem.** Suppose `f` has a depth-`L`, width-`C` strict-margin ReLU implementation with path norm strictly smaller than `R`. With probability at least `1−δ` over `n` iid training inputs from any distribution on the cube, every exactly consistent posterior just defined has average sign error at most `ε`, simultaneously at every width `N≥C` and every positive Gaussian scale, provided

$$
 n\ge\frac{v_R\log(2^d+1)+\log(1/\delta)}{\varepsilon}.
$$

The same sample event works for any of the full-support base densities above. Replacing `ε` by `ε/3` gives correct-label posterior probability strictly greater than `2/3` outside a test set of mass at most `ε`.

*Positive probability and normalizers.* Clone the teacher to every larger width; cloning preserves both the function and path norm. Equivalently use zero padding, since ReLU vanishes at zero. Strict inequalities, continuity in finitely many parameters, and finiteness of the input set supply a nonempty open neighborhood inside the restricted target event. An everywhere-positive density gives that neighborhood positive probability. Thus the restricted prior and every noiseless posterior normalizer are positive. If a teacher is given with `P=R` but strict margin, a sufficiently small decrease in its readout gives `P<R` while retaining the margin.

*Generalization.* All posterior-supported functions belong to the common class `B_R`. A fixed function of true error greater than `ε` survives all `n` labels with probability at most `e^{−nε}`. The function count and a union bound make every surviving function have error at most `ε`. Averaging over any consistent posterior preserves the inequality. ∎

**Why no quantitative small-ball probability is needed here.** The entire restricted function class already has small capacity. A positive target neighborhood is enough to make conditioning meaningful; its mass need not be `exp(−poly·N/t²)`. The restriction may condition on a very rare event at large width. This is a real tradeoff: the theorem is a guarantee for a norm-constrained Bayesian learner, not evidence that the unconstrained Gaussian prior naturally concentrates on this class.

## 3. Boolean formulas give a quadratic width bound

A Boolean formula is a tree of gates; intermediate nonconstant values are not reused by different parents. Repeated appearances of an input count as separate leaves. Use NOR, NOT, and COPY, and count constant wires as usual. On bits in `{0,1}`,

$$
 \mathrm{NOR}(a,b)=\mathrm{ReLU}(1-a-b),\quad
 \mathrm{NOT}(a)=\mathrm{ReLU}(1-a),\quad
 \mathrm{COPY}(a)=\mathrm{ReLU}(a).
$$

The input bit `(1+x_i)/2` has incoming absolute path mass one. A constant-one wire has path mass one. For a logical wire, let `p` be its incoming absolute path mass. A COPY preserves `p`; a NOT has path mass at most `1+p`; a NOR has path mass at most `1+p_a+p_b`. Substituting affine input bits directly into the first layer can only decrease these upper bounds, by the triangle inequality. Copy chains used for layering do not change them.

If the formula has `s` non-COPY internal gates, it has at most `s+1` leaves. Induction gives output-bit path mass at most `2s+1`. The signed readout `2b−1` has total path norm at most

$$
 \mathcal P\le2(2s+1)+1=4s+3.
$$

A shared constant-one chain does not introduce an omitted factor: every gate offset contributes one distinct constant-input path in exactly this recurrence. The network's output is exactly `±1`, providing strict margin slack.

Take `R=4s+4`. If the layered formula has width at most `C` and `H` stages, then `s≤CH`, so one may choose `R=4CH+4≤8CH`. The theorem gives

$$
 n=O\!\left(
 \frac{C^2L^2\,[L+\log(d+1)]\,(d+1)+\log(1/\delta)}\varepsilon
 \right).
$$

Thus the dependence on teacher width is literally quadratic and the dependence on depth polynomial. The teacher-width requirement counts all needed constant wires and compilation overhead. The prior budget `R` is a declared hypothesis-class parameter; setting it from an announced formula-size upper bound is standard realizable PAC usage. This does not give automatic adaptation to an unknown smaller formula under one fixed, unrestricted prior.

**What happens for general circuits?** Unfolding a reused subcomputation into a formula can create exponentially many paths. The same gate compiler then supplies an exponential path-norm upper bound. This is a limitation of this compiler and guarantee. It is **not** a proof that some explicit small circuit function has no alternative implementation of polynomial path norm. In particular, a badly redundant implementation can have enormous path norm even when the function has a trivial implementation.

## 4. A GELU variant, and where its depth cost lives

There is a corresponding norm-budget theorem for exact GELU, but the budget must include its Lipschitz amplification. Let `λ≥1` bound the Lipschitz constant of GELU (`λ=2` is sufficient), and define

$$
 \mathcal P_{\mathrm{Lip}}(w)=\lambda^H\mathcal P(w).
$$

Restrict the prior to `P_Lip<R` and the original strict global margin. Nodewise path normalization writes every normalized hidden activation in the one-parameter family

$$
 \psi_a(u)=\frac{\mathrm{GELU}(au)}{\lambda a}
          =\frac{u\Phi(au)}\lambda,\qquad a>0.
$$

Each `ψ_a` is 1-Lipschitz and vanishes at zero. All normalized preactivations lie in `[-1,1]` and the final absolute coefficient budget is `R`.

For `0<η≤1/2`, this family has a sup-norm `η`-net on `[-1,1]` of cardinality at most `8η^{−2}` (allowing the two limiting 1-Lipschitz functions as centers). For `a≤η`, approximate it by `u/(2λ)`; for `a≥η^{−1}`, approximate it by `ReLU(u)/λ`. Both errors are at most `η`. In the remaining range, use a grid of mesh `η` in `log a`, since

$$
 \left|\frac{\partial\psi_a(u)}{\partial\log a}\right|
 =\frac{|u\,(au)\varphi(au)|}{\lambda}\le1.
$$

There are at most `2η^{−1}log(1/η)+4≤8η^{−2}` centers. The normalization is only an auxiliary capacity representation; the original Bayesian learner continues to use GELU at every neuron.

Applying the preceding exponential contraction proof with a union over this scalar net at each layer gives, for `n≥2` and `η=1/n`,

$$
 \widehat{\mathfrak R}_n
 \le R\left[
 \frac Hn+
 \sqrt{\frac{2[4H\log(2n)+\log(2(d+1))]}n}
 \right].
$$

Consequently a valid margin-VC upper bound is

$$
 v_{R,\mathrm{GELU}}
 =\left\lceil4096(R+1)^2D
     \log\{16(R+1)^2D\}\right\rceil,
 \qquad D=H+\log(2(d+1)).
$$

For example, substitute this value into the Rademacher bound: `log(2n)≤5log(16(R+1)²D)`, and the resulting bound is less than `1/2`, contradicting margin shattering. Sauer and the same positive-neighborhood argument give the all-width, all-scale Bayesian theorem of section 2 with `v_R` replaced by `v_{R,GELU}`. Cloning preserves GELU outputs and the ordinary path norm even though arbitrary neuron rescaling does not.

This dependence is quadratic in the **declared adjusted path budget**, up to a logarithm, and polynomial in displayed depth. However, `P_Lip` contains `λ^H`. We have not proved that arbitrary small Boolean GELU circuits meet a budget polynomial in their width and depth. This variant makes the restriction and its cost explicit rather than hiding the exponential factor. The ReLU formula theorem above is stronger in its relation to Boolean teacher complexity.

## 5. Other norms: what they give and what is missing

| Restriction | What can be justified | Main limitation for the requested circuit theorem |
|---|---|---|
| Absolute ReLU path norm `P<R` | Complete theorem above; depth-polynomial, quadratic in `R`, all widths and base Gaussian scales | Small formula size controls `R`; the corresponding claim for every small circuit is not established |
| Product of Frobenius norms | Standard ReLU product-norm capacity bounds are polynomial in depth once this product is bounded | An ordinary width-`C` layered implementation can have a product growing like a power of `C` in every layer; identity transport of `C` coordinates alone has Frobenius norm `√C` per layer |
| Product of spectral norms / layerwise nonexpansiveness | Controls worst-case amplification of input or hidden perturbations | A Lipschitz bound alone does not supply our desired width-free polynomial capacity estimate; known spectral bounds include extra matrix-complexity terms. No complete general Boolean compiler with polynomial budget was established here |
| Spectral complexity, including effective-rank corrections | Existing norm-margin results can be applied when the full complexity is bounded | Random Gaussian bulk has stable rank of order width; bounded spectral norm does not make the correction small. The teacher's complexity and the restricted Gaussian mass both need checking |
| Layerwise Frobenius norm divided by `√N` | Natural initialization-scale quantity | Bounded normalized Frobenius norms allow unnormalized Frobenius products to grow with width, so the ordinary product-norm proof does not become width independent |
| A support condition `P≤a κ_N` | Can be useful in the strong-prior limit: an energy sublevel also bounds path complexity | More calibrated to the proof than a conventional hard norm cap; a finite mean-field target-cylinder argument is not supplied here |

Here `κ_N=(d/N)||W¹||_F²+Σ_internal||W^s||_F²+N||v||²` is the program's normalized Gaussian energy. Nonexpansiveness and low capacity are different requirements: controlling the propagation of perturbations does not automatically limit how many functions the class can encode.

### Why the free Gaussian bulk is a genuine issue for raw norm restrictions

For the original independent Gaussian prior, direct calculation gives

$$
 \mathbb E\mathcal P(w)
 =\left(\sqrt{2/\pi}\right)^L
   \frac{d+1}{\sqrt d}\,t^L N^{(L-2)/2}.
$$

There are `(d+1)N^H` paths. Multiply the expectations of the absolute independent edge weights along one path and sum to obtain the formula. At fixed positive `t`, the expected raw path norm grows rapidly with width for deep networks. This is an expectation calculation, not a posterior lower bound or a concentration theorem.

Likewise, a free internal Gaussian block with variance `t²/N` has squared Frobenius norm of order `t²N` and operator norm of order `t`. An operator-norm condition alone therefore does not bound its effective rank. Forcing all such free blocks into a tiny Frobenius or absolute-path ball can cost a probability exponential in the number of bulk coordinates, of order `N²`. The efficient target cylinders in our unrestricted and merging-stability papers deliberately leave those coordinates largely free. Their target-mass proof cannot simply be reused for these stronger raw-weight restrictions.

For the hard-cap theorem this difficulty is harmless mathematically because the entire conditioned class has small capacity. For a theorem that adapts to every small teacher while preserving a broad Gaussian function prior, it remains a material obstacle.

### What nonexpansiveness does and does not promise

A condition `||W^s||op≤1` for internal ReLU layers is recognizable and useful for stability. It can accommodate identity transport without a Frobenius penalty proportional to `√C` per layer. But it may impose significant representation costs on nonlinear computations. Anil, Lucas, and Grosse show that norm-constrained ReLU networks trade nonlinear expressivity against gradient norm, motivating GroupSort activations. That result concerns real-valued approximation and is not itself an impossibility theorem for our finite Boolean problem. It is a reason to check a Boolean compiler carefully instead of assuming that every small circuit can be made layerwise nonexpansive at constant margin.

## 6. Naturalness and trained networks

Path norms and path-normalized optimization are established ideas, which makes a hard path cap a more familiar hypothesis than stability under a particular neuron-merging operation. It is invariant to a major ReLU parameterization symmetry and is directly computable. These facts make it a plausible restriction to study.

They do not establish that ordinary trained networks satisfy a useful numerical cap. Absolute paths ignore cancellation and activation gating. For example, two identical exponentially amplified branches with opposite output coefficients compute zero but contribute exponentially to the path norm. A narrow alternative implementation may have tiny norm, while the trained parameterization need not find it. Path-SGD uses a related pathwise regularizer; that literature is not evidence that our specific ℓ¹ path budget is automatically small under ordinary SGD.

A useful empirical check would report the margin-normalized ℓ¹ path norm, its scaling with depth and width, and how much it decreases under pruning or function-preserving simplification. For GELU, also report the gap between the worst-case `λ^H` adjustment and actual Jacobian amplification. The current note establishes no such empirical claim.

## References and provenance

The capacity proof above is supplied directly; the following sources contextualize the norms and their limitations:

- [Golowich, Rakhlin, and Shamir, *Size-Independent Sample Complexity of Neural Networks*](https://arxiv.org/abs/1712.06541): norm-based capacity bounds and exponential-moment layer peeling.
- [Neyshabur, Salakhutdinov, and Srebro, *Path-SGD: Path-Normalized Optimization in Deep Neural Networks*](https://arxiv.org/abs/1506.02617): pathwise regularization and invariance under ReLU rescaling.
- [Bartlett, Foster, and Telgarsky, *Spectrally-normalized margin bounds for neural networks*](https://arxiv.org/abs/1706.08498): spectral products together with additional matrix-complexity factors.
- [Anil, Lucas, and Grosse, *Sorting Out Lipschitz Function Approximation*](https://proceedings.mlr.press/v97/anil19a/anil19a.pdf): expressivity limitations of norm-constrained ReLU networks and alternative activations.

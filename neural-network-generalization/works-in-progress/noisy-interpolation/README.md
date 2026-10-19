# Exact noisy interpolation in the strong-prior limit

*Research note, 18 October 2026. This is a new paper proof, not a Lean-verified result. It belongs with the works in progress rather than the verified main results.*

[FAQ discussion](../../TECHNICAL-FAQ.md#24-do-the-good-generalization-results-survive-a-small-amount-of-label-noise) · [Proof review record](REVIEW.md) · [Collection index](../../README.md)

Exact fitting of noisy labels does not prevent a useful generalization theorem for the strong-prior NNBayes learner. At every fixed depth, we obtain a clean-error bound of the form

$$
\frac{B_L(d,C,U)}{n}+A(d,L,U)\frac{s}{n}
  +\frac{8\log(1/\delta)}{n}+\tau,
$$

where at most $s$ training labels are corrupted. The bound holds at every learner width $N\geq W_s=O(C+U^2d^2(s+1))$, a threshold that grows with the number of corruptions, and controls posterior mixtures, including mixtures of tied minimum-energy functions. Here $B_L$ is polynomial in the input dimension and target complexity at each fixed depth, while

$$
A(d,L,U)=O\!\left(U^2d(d+1)(d^2+L^2)\right).
$$

The parameter $U$ bounds the clean teacher's real output. One may always take $U=C^2$, since a width-$C$ implementation with weights bounded by $C$ has $|z_f|\leq C^2$. Standard saturated implementations of Boolean circuits have $U=1$, so their corruption coefficient is independent of circuit width.

For independent label flips of probability $\eta$, the bound becomes a resource-dependent multiple of $\eta$, plus a term decreasing with sample size. **This does not yet give a noise floor depending only on $\eta$, uniformly over input dimension.** It does establish tolerance of a positive fraction of corruptions that is sufficiently small relative to the displayed resource polynomial. The clean sample overhead can still have bad depth dependence.

## 1. Model and theorem

All logarithms are natural.

Let $d,C,H$ be positive integers, put $L=H+1$, and let $X=\lbrace-1,1\rbrace^d$ and $M=2^d$. A network of width $N$ has $H$ tanh hidden layers and a linear readout:

$$
 h^0(x)=(1,x_1,\ldots,x_d),\qquad
 h^\ell(x)=\tanh(W^\ell h^{\ell-1}(x)),\qquad
 z_w(x)=v^\top h^H(x).
$$

There are no separate internal biases; constant hidden wires may carry offsets. Its weighted energy is

$$
\kappa_N(w)=\frac dN\Vert W^1\Vert_F^2
 +\sum_{\ell=2}^{H}\Vert W^\ell\Vert_F^2
 +N\Vert v\Vert_2^2.
$$

The raw prior is the product Gaussian with density proportional to $\exp[-\kappa_N(w)/(2\sigma^2)]$. Thus entry variances are $N\sigma^2/d$ in the first layer, $\sigma^2$ internally, and $\sigma^2/N$ in the readout. Before training, condition on

$$
 |z_w(x)|>1/2\qquad\text{for every }x\in X.
$$

After training, condition exactly on the observed labels. The likelihood is unchanged: it neither knows the flip rate nor permits training errors.

Assume the clean target $f:X\to\lbrace-1,1\rbrace$ has an implementation $z_f$ of width $C$ and depth $L$, all of whose weights have magnitude at most $C$, with

$$
 f(x)z_f(x)>1/2,\qquad |z_f(x)|\leq U
 \quad\text{for every }x\in X,
$$

where $1\leq U\leq C^2$. Taking $U=C^2$ is always valid.

**Theorem.** There are an explicit function $B_L(d,C,U)$ polynomial in $d,C,U$ at each fixed $L$, a universal polynomial upper bound for $A(d,L,U)$ of the order displayed above, and a width threshold

$$
 W_s=O\!\left(C+U^2d^2(s+1)\right)
$$

such that the following holds. Let $1\leq n\leq M$ and $0\leq s\leq n$ be integers. Sample $n$ distinct inputs uniformly without replacement. After seeing the inputs, corrupt any set of at most $s$ labels. For every $N\geq W_s$ and every $\delta,\tau\in(0,1)$, sufficiently small positive $\sigma$ gives, with probability at least $1-\delta$ over the sample locations,

$$
 R_X(\Pi_{N,\sigma})
 \leq \frac{B_L(d,C,U)+A(d,L,U)s+8\log(1/\delta)}{n}+\tau. \tag{1}
$$

Here $R_X$ is the posterior average clean classification error under the uniform distribution on the whole cube. The same sample event works for every permitted width and every corruption set of size at most $s$. The sufficiently small variance threshold can depend on $N$; no joint width–variance limit is claimed.

The theorem allows arbitrary corruption locations. Independent flips will be a corollary. As usual, an upper bound greater than one is vacuous.

## 2. A sparse correction from first-layer tanh features

We first construct a shallow correction; deeper layers will lower its energy. For a set $T\subseteq X$ of corrupted locations, $|T|\leq s$, put

$$
 r(x)=-4z_f(x)\mathbf 1_T(x).
$$

Then $2z_f+r$ implements the clean target with its labels reversed on $T$, with strict margin greater than one. Its correction satisfies $|r|\leq4U$.

Use normalized Boolean Fourier coefficients $\widehat r(S)$ and parities $\chi_S(x)=\prod_{j\in S}x_j$. Parseval and Cauchy–Schwarz give

$$
 \sum_S|\widehat r(S)|
 \leq\left(\sum_{x\in X}r(x)^2\right)^{1/2}
 \leq4U\sqrt{s}. \tag{2}
$$

### Exact parity representations

Every parity has an exact representation as a signed mixture of bounded-weight affine-tanh features with total absolute coefficient at most $3\sqrt d$.

To prove this, first consider $k\geq1$ selected coordinates. Let $b_k=0$ for odd $k$ and $b_k=1$ for even $k$, and define

$$
 h_k(x)=\mathrm{sign}\!\left(\sum_{j=1}^k x_j-b_k\right).
$$

The preactivations are nonzero integers. The coefficient of the full parity in $h_k$ has magnitude

$$
 |c_k|=
 \begin{cases}
  {2m\choose m}/4^m,&k=2m+1,\\
  {2m\choose m}/4^m,&k=2m,
 \end{cases}
 \qquad |c_k|\geq\frac1{\sqrt{2k}}. \tag{3}
$$

For the odd case, the sign is $(-1)^m$; for the even case it is $(-1)^{m-1}$. These formulas follow by grouping the defining Fourier sum according to the number of negative coordinates and using

$$
 \sum_{j=0}^t(-1)^j{q\choose j}=(-1)^t{q-1\choose t}.
$$

The lower bound follows from ${2m\choose m}/4^m\geq1/(2\sqrt m)$ for $m\geq1$. An elementary induction proves it: the ratio of consecutive terms is $(2m-1)/(2m)$, which is at least the ratio $\sqrt{(m-1)/m}$ of consecutive values of $1/(2\sqrt m)$, and both sequences equal $1/2$ at $m=1$. The case $k=1$ is direct.

Choose the common slope

$$
 a_d=\max\left\lbrace1,\frac12\log(4\sqrt{2d})\right\rbrace.
$$

Replacing the sign by $\tanh(a_d\,\cdot)$ changes every value by at most $2e^{-2a_d}\leq1/(2\sqrt{2d})$. Its full-parity coefficient $c_{k,a_d}$ therefore satisfies

$$
 |c_{k,a_d}|\geq\frac1{2\sqrt{2k}}.
$$

Averaging over independent coordinate sign flips projects exactly onto that parity:

$$
 \mathbb E_{u\in\lbrace-1,1\rbrace^k}
 \left[\left(\prod_{j=1}^k u_j\right)
 \tanh\!\left(a_d\left(\sum_{j=1}^k u_jx_j-b_k\right)\right)\right]
 =c_{k,a_d}\prod_{j=1}^k x_j. \tag{4}
$$

Indeed the substitution $v_j=u_jx_j$ proves the identity. Dividing by $c_{k,a_d}$ gives total absolute coefficient at most $2\sqrt{2k}\leq3\sqrt d$. The empty parity is the constant one, implemented by $\tanh(1)/\tanh(1)$ with coefficient less than two.

Every first-layer row in these representations has squared Euclidean norm at most

$$
 F_d:=1+(d+1)(d+2)^2,
$$

because $a_d\leq d+2$. Combining (2) and (4), the sparse correction has an exact affine-tanh expansion whose coefficient sum is at most

$$
 12U\sqrt{ds}. \tag{5}
$$

The expansion may contain exponentially many terms. We next reduce its width.

### Sampling the feature expansion

Set

$$
 A_s^2=1+144U^2d(s+1),\qquad
 m_s=\left\lceil32A_s^2\log(2M)\right\rceil+1. \tag{6}
$$

Write $r=A_s\mathbb E\xi$, where $\xi$ is a signed affine-tanh feature. A zero feature absorbs unused probability mass; feature signs can be absorbed into input rows because tanh is odd. Independent sampling of $m_s$ features and Hoeffding's inequality show that

$$
 \Pr\!\left[\max_{x\in X}
 \left|\frac{A_s}{m_s}\sum_{j=1}^{m_s}\xi_j(x)-r(x)\right|
 \geq\frac14\right]
 \leq2M\exp\!\left[-\frac{m_s}{32A_s^2}\right]<1.
$$

Thus there is a deterministic choice for which

$$
 g(x)=\frac{A_s}{m_s}\sum_{j=1}^{m_s}\xi_j(x),\qquad
 |g-r|<1/4,\qquad |g|\leq M_0:=5U. \tag{7}
$$

All feature rows retain the bound $F_d$, and $m_s=O(U^2d^2(s+1))$. When $s=0$, one can take every feature to be zero. This is an existence proof; efficient Fourier computation or posterior sampling is not assumed.

## 3. Using depth without multiplying the noise cost by an exponential

Fix any $N\geq2\max\lbrace C,m_s\rbrace$. Reserve $N_c=\lfloor N/2\rfloor$ neurons per layer for the correction and $N_t=\lceil N/2\rceil$ for the clean teacher.

Distribute the $m_s$ sampled features among the $N_c$ first-layer correction neurons, with feature $j$ having $k_j$ identical copies, where

$$
 \sum_j k_j=N_c,\qquad k_j\geq\frac{N_c}{2m_s}.
$$

Balanced floor/ceiling multiplicities suffice. The correction's first-layer contribution to $\kappa_N$ is at most $dF_d$.

Suppose first that $H\geq2$. Write $A=A_s$ and choose

$$
 R^2=\max\lbrace2,8M_0^3,A^{2/H}\rbrace.
$$

Every second-layer correction neuron has weight

$$
 \frac{A}{m_s k_j R^{H-1}}
$$

to each copy of feature $j$. All these neurons have the same preactivation $g/R^{H-1}$. The squared Frobenius norm of this matrix is

$$
 \frac{N_c A^2}{m_s^2R^{2H-2}}\sum_j\frac1{k_j}
 \leq\frac{2A^2}{R^{2H-2}}\leq2R^2. \tag{8}
$$

Each of the next $H-2$ hidden correction layers has every weight $R/N_c$, costing $R^2$ in energy. Every correction readout coefficient is $R/N_c$, with ambient weighted cost

$$
 N\Vert v_{\mathrm{corr}}\Vert_2^2
 =\frac N{N_c}R^2\leq3R^2.
$$

The post-first-layer correction cost is therefore at most $(H+3)R^2$.

The identical scalar activations obey

$$
 y_1=\tanh(g/R^{H-1}),\qquad
 y_j=\tanh(Ry_{j-1}),\qquad
 z_{\mathrm{corr}}=Ry_{H-1}.
$$

Replacing each tanh by the identity gives exactly $g$. Actual preactivations at stage $j$ have magnitude at most $M_0/R^{H-j}$ because tanh contracts magnitude. The elementary inequality $|t-\tanh t|\leq|t|^3/3$ and telescoping give

$$
 |z_{\mathrm{corr}}-g|
 \leq\frac{M_0^3}{3}\sum_{j=1}^{H-1}R^{-2(H-j)}
 \leq\frac{2M_0^3}{3R^2}\leq\frac1{12}. \tag{9}
$$

For $H=1$, use no scalar hidden chain: assign readout coefficient $A/(m_s k_j)$ to each copy of feature $j$. It computes $g$ exactly, at ambient readout cost at most $6A^2$.

Thus, with $Q=2+8(5U)^3$, a common bound for every $H\geq1$ is

$$
 K_{\mathrm{corr}}(s)
 \leq dF_d+(H+5)Q+(H+5)A_s^{2/H}. \tag{10}
$$

The correction differs from $r$ by less than $1/4+1/12=1/3$ everywhere. Its addition to $2z_f$ therefore implements the corrupted target with strict margin greater than $2/3$ on the entire cube.

### Adding the clean branch

At its original width $C$, the clean branch $2z_f$ has energy at most

$$
 T_0=d(d+1)C^2+(H+3)C^4.
$$

To embed a network of width $C$ into any larger width $N_t$, replace each hidden neuron by $k=\lfloor N_t/C\rfloor$ copies, divide outgoing weights by $k$, and pad unused coordinates with zero weights. This preserves the output. The first-layer contribution does not increase, internal contributions are unchanged, and the readout contribution increases by a factor less than two. Using the ambient $N$ rather than $N_t$ multiplies that readout cost by at most another two. The clean branch therefore costs at most $4T_0$.

Use zero cross-block weights and add the branch outputs through the final readout. We have constructed, at every $N\geq W_s:=2(C+m_s)$, a globally strict-margin noisy interpolant of energy at most

$$
 K_s=K_0+(H+5)A_s^{2/H},\qquad
 K_0=4T_0+dF_d+(H+5)Q. \tag{11}
$$

The resulting conditioning event has positive Gaussian probability: the finitely many strict output inequalities persist on an open parameter neighborhood.

## 4. Counting all low-energy tanh sign functions

The needed count has exponent $H$ in energy. A general polynomial complexity comparison is too coarse for this purpose.

For a class $\mathcal F$ evaluated on a fixed sample of $m$ points, write

$$
 \mathrm{Rad}_m(\mathcal F)
 =\frac1m\mathbb E_\varepsilon
 \sup_{f\in\mathcal F}\sum_{i=1}^m\varepsilon_i f(x_i).
$$

We use the ordinary one-sided supremum; symmetric classes also give an absolute supremum.

### Variable clipping and normalized tanh

For $\mathcal F\subseteq[-1,1]^m$, let $\mathrm{Clip}(\mathcal F)$ contain the coordinatewise maps $\mathrm{clip}_t(f)=\max(-t,\min(t,f))$ for $f\in\mathcal F$ and $0\leq t\leq1$. Then

$$
 \mathrm{Rad}_m(\mathrm{Clip}(\mathcal F))
 \leq\mathrm{Rad}_m(\mathcal F)+\frac1{2\sqrt m}. \tag{12}
$$

Indeed,

$$
 \mathrm{clip}_t(u)=\frac{|u+t|-|u-t|}{2}.
$$

Split the two suprema, use sign symmetry on the second, and apply scalar contraction to the fixed 1-Lipschitz absolute-value map. This gives

$$
 \mathrm{Rad}_m(\mathrm{Clip}(\mathcal F))
 \leq\frac{\mathrm{Rad}_m(\mathcal F+[0,1])+
                  \mathrm{Rad}_m(\mathcal F-[0,1])}{2}
 =\mathrm{Rad}_m(\mathcal F)
     +\frac{\mathbb E|\sum_i\varepsilon_i|}{2m}.
$$

The last expectation is at most $\sqrt m$. Scalar contraction here has constant one: conditioning on all but one sign, its comparison reduces to

$$
 \frac12\sup_{f,g}\bigl(a_f+a_g+\phi(f_i)-\phi(g_i)\bigr)
 \leq\frac12\sup_{f,g}\bigl(a_f+a_g+|f_i-g_i|\bigr).
$$

The right side is unchanged if the absolute value is replaced by $f_i-g_i$, because exchanging $f$ and $g$ preserves the offsets. Iterating over coordinates proves the contraction inequality used above.

For $r>0$, normalized tanh is a convex mixture of clips on $[-1,1]$:

$$
 \frac{\tanh(ru)}r
 =\int_0^1\mathrm{clip}_t(u)
        [2r\tanh(rt)\,\mathrm{sech}^2(rt)]\,dt
     +\mathrm{sech}^2(r)\,\mathrm{clip}_1(u). \tag{13}
$$

The nonnegative weights sum to one. Differentiate for $u>0$ to check that the remaining mass of thresholds $t>u$ is $\mathrm{sech}^2(ru)$; both sides vanish at zero and are odd. The $r=0$ limit is the identity. This identity handles tanh's lack of positive homogeneity.

### Absolute path normalization

Let $\mathcal F_1$ be the closed convex hull of affine-tanh features. Recursively set $\mathcal F_\ell$ to the closed convex hull of $\mathrm{Clip}(\mathcal F_{\ell-1})$. These classes are symmetric and bounded by one. Convex hulls do not change Rademacher complexity, so (12) gives

$$
 \mathrm{Rad}_m(\mathcal F_H)
 \leq\mathrm{Rad}_m(\mathcal F_1)+\frac{H-1}{2\sqrt m}.
$$

For an individual network, put $\rho_i^1=1$ and

$$
 \rho_j^\ell=\sum_i|W^\ell_{ji}|\rho_i^{\ell-1}.
$$

Inductively $h_j^\ell/\rho_j^\ell\in\mathcal F_\ell$ whenever the denominator is positive. The normalized preactivation is a signed convex combination of previous normalized nodes, and its normalized activation is (13). A zero denominator gives an identically zero node.

The hidden-to-output absolute path norm is

$$
 P=|v|^\top|W^H|\cdots|W^2|\mathbf1.
$$

If $P>0$, the normalized output $z/P$ lies in $\mathcal F_H$; if $P=0$, then $z=0$. Cauchy–Schwarz, the operator/Frobenius inequality, and AM–GM over $H$ squared factors give

$$
 P\leq\sqrt N\Vert v\Vert_2
       \prod_{\ell=2}^H\Vert W^\ell\Vert_F
 \leq\left(\frac{\kappa_N}{H}\right)^{H/2}. \tag{14}
$$

This is uniform over every width and does not use the first-layer energy.

### An elementary bound for the first layer

The number $J$ of affine-halfspace Boolean functions on $X$ satisfies

$$
 J\leq2(M+1)^{d+1},\qquad \log J\leq(d+2)^2.
$$

Count the regions cut out by the $M$ linear inequalities in the parameter space of dimension $d+1$; boundary labels can be realized by a small bias perturbation. A log-sum and exponential-moment argument for a finite class of $J$ sign vectors gives Rademacher complexity at most $\sqrt{2\log J/m}$.

Every affine-tanh feature is an average of affine halfspaces: for a random scalar threshold $T$ with distribution function $(1+\tanh t)/2$,

$$
 \tanh(a^\top\bar x)=\mathbb E_T\mathrm{sign}(a^\top\bar x-T).
$$

Thus, with

$$
 D_{d,H}=\sqrt2(d+2)+\frac{H-1}{2},
$$

we obtain, on every fixed sample and for the union over all widths,

$$
 \mathrm{Rad}_m\bigl(\lbrace z_w:\kappa_N(w)\leq K\rbrace\bigr)
 \leq\frac{D_{d,H}}{\sqrt m}\left(\frac KH\right)^{H/2}. \tag{15}
$$

A standard VC entropy integral can sharpen the first term in $D_{d,H}$ to a constant times $\sqrt{d+1}$. The elementary estimate suffices here.

### From capacity to a global function count

For each represented Boolean function $g$, let $\kappa_N(g)$ be the infimum of energy over its globally strict-margin implementations. Let $\mathcal G_K$ contain all $g$ with $\kappa_N(g)\leq K$ at **some** width $N$.

If $\mathcal G_K$ shatters $m$ cube points, its labelings have representatives of energy below $K+1$ and signed outputs greater than $1/2$. Their Rademacher complexity is at least $1/2$. Equation (15) therefore gives

$$
 \mathrm{VCdim}(\mathcal G_K)
 \leq4D_{d,H}^2\left(\frac{K+1}{H}\right)^H.
$$

Sauer's lemma on all $M=2^d$ points now implies the safe bound

$$
 \log|\mathcal G_K|
 \leq(d+1)\left[1+4D_{d,H}^2
                       \left(\frac{K+1}{H}\right)^H\right]. \tag{16}
$$

If the dimension estimate exceeds $M$, the trivial count of all Boolean functions gives the same bound. The slack $K+1$ avoids assuming that a strict-margin infimum is attained.

Insert the comparator energy (11). The weighted convexity inequality

$$
 (a+b)^H\leq(1+1/H)^{H-1}a^H+(H+1)^{H-1}b^H
$$

with $a=(1+5/H)A_s^{2/H}$ and $b=(K_0+1)/H$ yields

$$
 \left(\frac{K_s+1}{H}\right)^H
 \leq e^6 A_s^2+\Lambda_0,\qquad
 \Lambda_0=(H+1)^{H-1}\left(\frac{K_0+1}{H}\right)^H. \tag{17}
$$

The inequality also holds for $H=1$. Consequently,

$$
 \log|\mathcal G_{K_s}|\leq b_0+b_1s, \tag{18}
$$

where one may take

$$
 \begin{aligned}
 b_0&=(d+1)\left[1+4D_{d,H}^2
       \left(\Lambda_0+e^6(1+144U^2d)\right)\right],\\
 b_1&=576e^6(d+1)D_{d,H}^2U^2d.
 \end{aligned}
$$

The coefficient $b_1$ is polynomial jointly in $d,U,H$. The baseline $b_0$ is polynomial in $d,C,U$ at fixed $H$, but need not have polynomial depth dependence. This linear dependence on the number of corruptions is the key improvement over applying the earlier, much looser norm-compression polynomial.

## 5. Generalization and the strong-prior posterior

For a fixed Boolean predictor with clean whole-cube error $p$, its number $Z$ of clean disagreements on a uniform subset of $n$ distinct inputs is hypergeometric. The elementary symmetric-mean inequality gives

$$
 \mathbb E e^{-tZ}\leq(1-p+pe^{-t})^n.
$$

Indeed the expectation is an elementary symmetric mean of a list with $pM$ entries $e^{-t}$ and the remaining entries one. Such a mean is at most the arithmetic mean raised to power $n$. Taking $t=\log2$ gives

$$
 \Pr[Z\leq np/2]\leq e^{-np/8}.
$$

If $p>\varepsilon$ and $s\leq n\varepsilon/2$, it follows that the predictor has at most $s$ sampled clean disagreements with probability at most $e^{-n\varepsilon/8}$. Union-bound over $\mathcal G_{K_s}$, taking

$$
 \varepsilon_s=
 \frac{2s+8\log|\mathcal G_{K_s}|+8\log(1/\delta)}n. \tag{19}
$$

Except with probability $\delta$, every exactly fitting member of this class has clean error at most $\varepsilon_s$. This event is simultaneous over all widths and all corruption sets of size at most $s$.

We finally show why the actual strong-prior posterior places asymptotically all its mass in this class. For a representable Boolean $g$, let $U_g$ be its open strict-margin parameter set. In coordinates making $\kappa_N$ the squared Euclidean norm, the raw prior is $\mathcal N(0,\sigma^2I)$ in finite dimension $P$. For $0<\theta<1$,

$$
 \mu_\sigma(U_g)\leq\theta^{-P/2}
   \exp\!\left[-\frac{(1-\theta)\kappa_N(g)}{2\sigma^2}\right].
$$

Conversely, a positive-volume ball inside $U_g$ with energy below $\kappa_N(g)+\epsilon$ gives the corresponding lower exponential rate. Letting $\sigma\to0$, then $\theta\to0$ and $\epsilon\to0$, proves

$$
 \lim_{\sigma\to0}2\sigma^2\log\mu_\sigma(U_g)=-\kappa_N(g). \tag{20}
$$

Conditioning on the global margin does not change ratios between function probabilities. The comparator from Section 3 is consistent and has energy at most $K_s$. Every function outside $\mathcal G_{K_s}$ has strictly larger energy at the chosen width, so its probability relative to that comparator tends to zero. There are finitely many Boolean functions, and finitely many possible datasets at fixed parameters. Thus for every $\tau>0$, a sufficiently small positive variance makes posterior mass outside $\mathcal G_{K_s}$ at most $\tau$, uniformly over the datasets in question.

All consistent functions inside the class have error at most (19), and the remaining posterior mass contributes at most $\tau$. Equations (18)–(19) prove (1), with

$$
 B_L(d,C,U)=8b_0,\qquad A(d,L,U)=2+8b_1.
$$

These explicit constants have the claimed polynomial bounds. No uniqueness of a minimum-energy interpolant, convergence to a single function, or favorable tie-breaking rule is needed.

## 6. Independent flips and the prediction convention

Let the labels be flipped independently with probability $\eta<1/2$, and put

$$
 s_{\star} =\min\left\lbrace n,
       \left\lceil2\eta n+2\log(2/\delta)\right\rceil\right\rbrace.
$$

For the number $S$ of flips, $\mathbb E2^S=(1+\eta)^n\leq e^{\eta n}$ implies $\Pr[S>s_{\star}]\leq\delta/2$. Apply (1) with $s=s_{\star}$ and failure probability $\delta/2$. For every $N\geq W_{s_{\star}}$, sufficiently small positive variance therefore gives, with probability at least $1-\delta$,

$$
 R_X(\Pi_{N,\sigma})
 \leq 2A(d,L,U)\eta
  +\frac{B_L(d,C,U)+A(d,L,U)(2\log(2/\delta)+1)
                        +8\log(2/\delta)}n+\tau. \tag{21}
$$

At width $W_{s_{\star}}$ the exact-conditioning posterior is guaranteed to exist on the stated high-probability event. Requiring the larger width $W_n$ ensures feasibility for every possible flip pattern, without changing the risk bound.

The theorem thus handles a linear number of errors. Its noise tolerance is inverse-polynomial in the displayed resources, rather than restricted to a bounded number of flips.

When $n<M$, for a uniformly chosen **unseen** point, whole-cube and unseen errors satisfy, for each exact interpolator,

$$
 R_{\mathrm{unseen}}=\frac{MR_X-S}{M-n}
 \leq\frac M{M-n}R_X.
$$

The same relation holds after averaging over the posterior. Thus the whole-cube bound is informative about unseen inputs when the training set occupies only a limited fraction of the cube, for example $n\leq M/2$.

For any $q\in(0,1)$, the fraction of points where the posterior gives the correct label probability at most $q$ is at most $R_X/(1-q)$. Consequently the requirement of **more than $2/3$ probability** costs a factor of three; strict-majority prediction costs a factor of two. Posterior mixtures present no extra problem for these upper bounds.

## 7. Boolean circuit teachers can have bounded output

The dependence on $U$, rather than directly on $C$, matters for circuit targets. A standard saturated simulation has $U=1$.

First simplify NAND gates with repeated or constant inputs to NOT, copy, or constant gates using their Boolean identities. This preserves the layered depth after copy padding. Encode true hidden bits by values in $[0.9,1]$ and false bits by values in $[-1,-0.9]$. A NAND gate with two distinct nonconstant inputs uses

$$
 \tanh(2(1-u-v)),
$$

which has the correct NAND sign and remains in the same intervals: its preactivation magnitude is at least $1.6$, and $\tanh(1.6)>0.9$. Copy and NOT use $\tanh(2u)$ and $\tanh(-2u)$.

An exact constant wire $a=0.9$ is initialized using weight $\mathrm{atanh}(a)$ from the constant input, and maintained using relay weight $\mathrm{atanh}(a)/a<2$. First-layer NAND gates obtain their offset from the constant input using coefficient two. Every later NAND gate uses coefficient $2/a<3$ from the preceding layer's constant wire. Thus every gate weight is at most three, and every gate regenerates its saturated bit independently of depth.

After counting constant wires and any copy padding, and padding width to at least three to satisfy the bounded-weight convention, the final gate can be read out with coefficient one. Its output magnitude is at most one and its correct margin is at least $0.9$. Hence the theorem applies with $U=1$ and a bounded-weight implementation complexity determined by the circuit width. The noise coefficient is then

$$
 A(d,L,1)=O\!\left(d(d+1)(d^2+L^2)\right),
$$

independently of circuit width. The sample overhead and adequate learner width still depend on the target implementation.

## 8. What this resolves, and what remains open

For distinct uniformly sampled inputs and error under the uniform distribution, the unchanged strong-prior tanh learner now has a paper proof of tolerance to a sufficiently small positive corruption fraction for arbitrary bounded-weight targets at every fixed depth, at every learner width $N\geq W_s$. The proof uses exact interpolation and the original global margin conditioning. It applies to adversarial corruption locations as well as independent flips.

The stronger circuit-style target remains open: a clean-risk envelope tending to zero with $\eta$ alone, uniformly over input dimension after paying a target-dependent sample overhead. The present coefficient of $\eta$ grows polynomially in dimension and depth; for a general analog teacher it also depends on its output bound. A fixed numerical noise rate can therefore make this upper bound vacuous as dimension grows. No claim of perfect clean recovery at fixed positive noise is made.

There is a simple obstruction to removing all dimension dependence by sharpening the present global count. For every subset with $s$ elements $T$ of the cube, the comparator construction places the function obtained by flipping $f$ exactly on $T$ in the same class $\mathcal G_{K_s}$. These functions are distinct. Consequently, for $1\leq s\leq M$,

$$
 |\mathcal G_{K_s}|\geq {M\choose s},\qquad
 \log|\mathcal G_{K_s}|\geq s\log(M/s). \tag{22}
$$

The last inequality follows by writing the binomial coefficient as a product: each ratio $(M-j)/(s-j)$ is at least $M/s$ for $0\leq j<s$. When $s$ is polynomial in $d$, the right side is of order $sd$. Thus the single whole-class union bound (19) cannot produce a dimension-independent multiple of $s/n$ merely through better constants.

This is not a lower bound on the learner's error: the functions used in (22) themselves have small clean error $s/M$. A count restricted more carefully to inaccurate competitors might bypass this obstruction. Another route is to construct cheaper interpolants that permit a controlled amount of additional off-sample error, as approximate-membership constructions do in ordinary circuit learning. Establishing the necessary neural-energy or localized counting estimates remains open.

The width threshold must accommodate the corrupted sample. The noiseless condition $N\geq C$ alone cannot guarantee that an arbitrary noisy labeling is representable. The required variance is asymptotically small at each fixed width, and the argument gives no efficient algorithm for sampling the posterior.

The improved tanh counting bound may be useful independently of noise. Its energy exponent is $H=L-1$, so it still allows severe depth dependence in the clean sample overhead. It does not remove the unrestricted depth problem studied elsewhere in the collection.

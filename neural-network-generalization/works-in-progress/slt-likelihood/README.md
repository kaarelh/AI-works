# Smooth likelihoods and polynomial learning bounds for NNBayes

Dmitry Vaintrob, Kaarel Hänni, and OpenAI Codex · 19 October 2026

**Work in progress.** This note gives conventional proofs of several likelihood-sensitive results. It has received independent AI-agent mathematical review ([strong-prior positive results](verification/positive-review.md), [finite-scale extension](verification/finite-scale-review.md), [obstructions](verification/obstructions-review.md)); it is not Lean verified.

Replacing hard consistency by an ordinary smooth likelihood does **not** automatically preserve our sample bounds. A fixed likelihood can become powerless when the prior concentrates first. Nevertheless, a genuine Gaussian likelihood recovers polynomial learning bounds in the strong-prior limit and at every finite-scale exponent $\gamma\ge1$, at every learner width above the teacher width, if its observation variance shrinks together with the prior scale. The distinction concerns the learner itself, not the sharpness of singular learning theory's generalization formulas.

## 1. Which Bayesian setup?

Singular learning theory studies posterior distributions of the form

$$
\Pi(dw\mid S)\propto\pi(dw)\prod_{i=1}^n p(y_i\mid x_i,w)^\beta.
$$

Ordinary Bayes has $\beta=1$; other inverse temperatures give power posteriors. See equations (1)–(2) of [Watanabe (2010)](https://jmlr.org/papers/volume11/watanabe10a/watanabe10a.pdf) for the general setup. Gaussian regression and Bernoulli classification are standard examples. SLT does not specify a unique neural architecture, weight scaling, likelihood, or prediction loss.

Our main classification theorems instead use exact sign consistency, often after restricting the prior to have absolute output margin greater than $1/2$ at every input. The continuous-domain theorem uses an indicator of fitting each observation within a prescribed tolerance. Those likelihoods can assign zero probability to a wrong hypothesis; a Gaussian or logistic likelihood is everywhere positive.

The proofs below are our own arguments. They are not consequences asserted by the cited SLT paper. Throughout, networks have tanh hidden activations, a linear readout, a constant input coordinate, and no separate internal biases.

## 2. A positive theorem with an ordinary Gaussian likelihood

Fix integers $d\ge1$ and $L\ge2$. Let $X$ be a compact subset of $[-1,1]^d$, and let $f:X\to\mathbb R$ be computed by a depth $L$, width $C$ teacher whose weights have magnitude at most $B\ge1$. The learner has the same depth and any width $N\ge C$. Define

$$
\kappa_N(w)=\frac dN\lVert W^1\rVert_F^2+
\sum_{\ell=2}^{L-1}\lVert W^\ell\rVert_F^2+
N\lVert v\rVert_2^2.
$$

Use the raw Gaussian weight prior with density proportional to $\exp[-\kappa_N(w)/(2\sigma^2)]$, without a global output-margin restriction. Observe clean values $y_i=f(x_i)$, and use the statistical likelihood

$$
y_i\mid x_i,w\sim\mathcal N(z_w(x_i),\sigma^2).
$$

This is an ordinary Gaussian likelihood at every positive $\sigma$. Its variance is deliberately tied to the prior scale. The resulting posterior density is proportional to

$$
\exp\!\left[-\frac{J_S(w)}{2\sigma^2}\right],\qquad
J_S(w)=\kappa_N(w)+\sum_{i=1}^n(z_w(x_i)-f(x_i))^2.
$$

**Theorem.** For each fixed $L$ there is a polynomial $P_L$ with the following property. For every teacher and width as above, every $0<\tau,\varepsilon,\delta<1$, and every integer

$$
n\ge \frac1\varepsilon
\left[P_L(d,C,B,1/\tau)+48\log(1/\delta)\right],
$$

there is $\sigma_0>0$ such that, for all $0<\sigma<\sigma_0$ and every probability distribution $D$ on $X$, with probability at least $1-\delta$ over $n$ independent inputs from $D$,

$$
D\!\left\lbrace x:
\Pi\bigl(|z_w(x)-f(x)|\le\tau\mid S\bigr)\le2/3
\right\rbrace\le\varepsilon.
$$

The polynomial is independent of $N$. The threshold $\sigma_0$ may depend on the selected $n,N$, the teacher, and the accuracy parameters; it is uniform over $D$. This is a strong-prior limit at each fixed width and sample size. It does not assert one threshold simultaneously for all larger sample sizes.

### Proof

Balanced cloning gives an exact implementation of $f$ at every $N\ge C$ with energy at most

$$
E_{\star}=d(d+1)B^2+2(L-1)C^2B^2.
$$

The [continuous-domain paper](../../side-results/continuous-domains/paper.pdf), sections “Cloning and the mass of a teacher tube” and “Uniform covers for bounded energy,” proves this estimate and the following cover property: for fixed $L$, outputs with $\kappa_N\le K$ admit a finite uniform cover of accuracy $a$ whose logarithmic cardinality is polynomial in $d,K,1/a$, independently of $N$. See also its [source](../../side-results/continuous-domains/source/paper.tex). These deterministic statements apply on compact subsets of the coordinate cube.

Set $K=E_{\star}+1$. First, the posterior mass of $J_S>K$ tends to zero uniformly over samples of the selected size. In coordinates $u$ with $\kappa_N=\lVert u\rVert^2$, a small ball around the clone has $J_S\le E_{\star}+1/2$, uniformly over samples: continuity is uniform on compact $X$, and the ball may depend on $n,N$. Its contribution lower-bounds the posterior normalizer. If $p$ is the parameter dimension and $\theta=1/(4K)$, the integral over $J_S>K$ is at most

$$
\exp\!\left[-\frac{(1-\theta)K}{2\sigma^2}\right]
(2\pi\sigma^2/\theta)^{p/2}.
$$

Here we used $J_S\ge\kappa_N$. Since $(1-\theta)K=E_{\star}+3/4$, division by the ball contribution makes this bound tend to zero. Choose $\sigma_0$ so that the exceptional posterior mass is at most $\varepsilon/6$.

Next let $\mathcal H$ be an output cover at accuracy $\tau/8$ for $\kappa_N\le K$, of cardinality $M$. For each center $h$ put

$$
A_h=\lbrace x:|h(x)-f(x)|>\tau/2\rbrace.
$$

For any $w$ with $J_S(w)\le K$ and approximant $h$, every training point in $A_h$ contributes more than $(3\tau/8)^2$ to the squared residual sum. Thus at most $8K/\tau^2$ training points lie in $A_h$. If $D(A_h)>\varepsilon/6$, a multiplicative Chernoff bound gives probability at most $\exp(-n\varepsilon/48)$ for this event, provided $n\ge96K/(\varepsilon\tau^2)$. A union bound over the cover excludes every such $A_h$ when also

$$
n\ge\frac{48}{\varepsilon}\bigl[\log M+\log(1/\delta)\bigr].
$$

Since $\lbrace|z_w-f|>\tau\rbrace\subset A_h$, every parameter in $J_S\le K$ then has test tail error at most $\varepsilon/6$. Adding the exceptional posterior mass gives posterior-averaged tail error at most $\varepsilon/3$. Markov's inequality proves the stated $2/3$ confidence guarantee. The cover bound supplies the polynomial. This controls the full posterior, including mixtures. ∎

Observation variance $c\sigma^2$, for any fixed $c>0$, works too: the objective becomes $\kappa_N+c^{-1}\sum_i(z_w-f)^2$, and the residual budget becomes $cK$. The prediction guarantee concerns the latent mean $z_w$, not a future observation including Gaussian noise.

### Finite scales: every $\gamma\ge1$ and every width

The positive result also holds without taking a prior-variance limit. Use the original Gaussian finite-scale weight prior $\mu_{N,\gamma}$, whose first-layer, internal, and readout variances are respectively $N^{1-\gamma}/d$, $N^{-\gamma}$, and $N^{-\gamma-1}$. Use ordinary Gaussian observation variance $N^{-\gamma}$.

**Theorem.** At each fixed depth $L$ and fixed $\gamma\ge1$, there is a polynomial sample threshold in $d,C,B,1/\tau,1/\varepsilon,\log(1/\delta)$, independent of learner width, such that the same posterior-confidence conclusion holds for every $N\ge C$, every input distribution on $X$, and every sample size above that threshold. Data are clean teacher outputs. No limiting operation or global output-margin restriction is required.

**Proof.** Put $s=N^\gamma$. Two estimates from the continuous-domain paper are sufficient:

1. For $0<\rho\le1$, the uniform teacher tube has prior mass at least $e^{-sA(\rho)}$, where $A$ has a fixed-depth polynomial bound in teacher/input resources and $\log(1/\rho)$.
2. For $K$ above a fixed baseline and output accuracy $a$, there are a finite cover $\mathcal H_{K,a}$, a threshold $T(K,a)$, and measurable events $G$ such that, for $N\ge T$,

$$
\mu_{N,\gamma}(G^c)\le C_0e^{-cKs},\qquad
\inf_{h\in\mathcal H_{K,a}}\sup_X|z_w-h|\le a
\quad(w\in G).
$$

Both $T$ and $\log|\mathcal H_{K,a}|$ are polynomially bounded in the input/teacher resources, $K$, and $1/a$, at fixed $L,\gamma$. For $\gamma>1$ this is the spectral-truncation lemma followed by the energy cover. At $\gamma=1$ it is the [mean-field output-cover proposition](../../side-results/continuous-domains/source/meanfield.tex). The constants can depend on $L,\gamma$.

Choose $\rho=n^{-1/2}$ and write $A=A(\rho)$. Let $R_S(w)=\sum_i(z_w(x_i)-f(x_i))^2$. The posterior normalizer satisfies

$$
Z_S=\int e^{-sR_S/2}\,d\mu_{N,\gamma}
\ge e^{-s(A+1/2)}.
$$

Choose

$$
B_0=2[A+1/2+\log(12/\varepsilon)],\qquad
cK\ge A+1/2+\log(12C_0/\varepsilon),
$$

also imposing the cover's baseline on $K$. At every width,

$$
\Pi(R_S>B_0\mid S)\le e^{-s(B_0/2-A-1/2)}\le\varepsilon/12.
$$

For $N\ge T(K,\tau/8)$, the uncovered posterior mass likewise satisfies

$$
\Pi(G^c\mid S)\le C_0e^{-s(cK-A-1/2)}\le\varepsilon/12.
$$

Both bounds hold for every training sample. The previous Chernoff argument, with residual budget $B_0$, now controls every covered output with $R_S\le B_0$: it suffices that

$$
n\ge\frac{96B_0}{\varepsilon\tau^2},\qquad
n\ge\frac{48}{\varepsilon}\bigl[\log|\mathcal H_{K,\tau/8}|+\log(1/\delta)\bigr].
$$

Its test tail risk is then at most $\varepsilon/6$. Adding exceptional posterior mass at most $\varepsilon/6$ gives Gibbs risk at most $\varepsilon/3$, hence the required confidence statement.

For smaller widths $C\le N<T$, put $r=\varepsilon/6$ and $c_\tau=1-e^{-\tau^2/2}$. Any parameter with test tail risk greater than $r$ has expected likelihood at most

$$
\bigl[1-r(1-e^{-s\tau^2/2})\bigr]^n\le e^{-nc_\tau r},
$$

because $s\ge1$. Integrating over these parameters and applying Markov's inequality gives, with training probability at least $1-\delta$,

$$
\Pi\bigl(D\lbrace|z_w-f|>\tau\rbrace>r\mid S\bigr)
\le\delta^{-1}\exp\bigl[T^\gamma(A+1/2)-nc_\tau r\bigr].
$$

Thus the sufficient small-width condition is

$$
n\ge\frac6{\varepsilon c_\tau}
\left[T^\gamma(A+1/2)+\log\frac6{\varepsilon\delta}\right].
$$

It gives the same Gibbs and confidence bounds. Finally, $A(n^{-1/2})$, $B_0$, $K$, $T^\gamma$, and the cover entropy all have polynomial bounds in the resources and $\log n$; also $c_\tau^{-1}=O(\tau^{-2})$. Each sufficient inequality has the form $n\ge M(1+\log n)^q$, for fixed $q$ and polynomially bounded $M$. Since $(1+\log n)^q\le c_q\sqrt n$ for a constant $c_q$, the polynomial threshold $n\ge(c_qM)^2$ suffices. ∎

The growing-width parameter-volume effects are accounted for by the quantitative cover and tube estimates and the separate small-width argument. This proof does not substitute $\sigma=N^{-\gamma/2}$ into an unquantified strong-prior limit.

### Boolean labels and tempered logistic classification

Both Gaussian theorems have a Boolean variant with one additional learner layer. Given a teacher with $f(x)z_T(x)\ge1/2$ for Boolean $f$, append a tanh neuron computing $\tanh(Az_T)$ and a unit readout. With $A=\log(4\sqrt n)$ its uniform error against $f$ is at most $1/(2\sqrt n)$, so its total squared training residual is at most $1/4$. Its bounded-weight complexity, and hence clone energy, grow only polynomially in $1+\log n$. For the finite-scale argument, center a tube of radius $1/(2\sqrt n)$ at this approximating teacher, so total squared residual throughout the tube is at most one. The same proofs give sample conditions polynomial in the teacher parameters, accuracy parameters, and $\log n$; these have polynomial sufficient solutions. Taking $\tau<1$ gives correct-sign confidence. This variant still co-scales the Gaussian observation variance and prior, and uses depth $L+1$.

A related result holds for the explicitly co-tempered logistic posterior

$$
\Pi_t(dw\mid S)\propto
\exp\!\left[-t\left(\kappa_N(w)+
\sum_i\log(1+e^{-y_i z_w(x_i)})\right)\right]dw,
\qquad t\longrightarrow\infty.
$$

Scaling a margin teacher's readout by $2\log(2n)$ makes total logistic loss at most $1/2$ while multiplying energy by only $O(\log^2 n)$. A bounded-objective cover and the same counting argument give polynomial sample bounds. For example, with cover accuracy $1/4$, the set $\lbrace yh\le1/4\rbrace$ contains all sign errors, and each of its sampled points incurs logistic loss at least $\log(1+e^{-1/2})$. Controlling a fixed positive score threshold likewise gives Bernoulli predictive confidence above $2/3$.

This logistic statement changes the inverse temperature together with the prior. It is a power posterior, not ordinary logistic Bayes with a fixed statistical link and fixed likelihood temperature.

## 3. Why a fixed smooth likelihood can fail

### Raw priors: even a constant target

For the finite-scale family, each independent Gaussian readout coordinate has variance $N^{-\gamma-1}$. Since hidden activations are bounded by one,

$$
\mathbb E[z_N(x)^2\mid\text{hidden weights}]
=N^{-\gamma-1}\sum_i h_i(x)^2\le N^{-\gamma}.
$$

For every $\gamma>0$, the outputs on any fixed finite set of inputs therefore converge to zero in probability as $N\to\infty$. For the fixed-width strong-prior family, the corresponding bound is $\mathbb E z_w(x)^2\le\sigma^2$.

Let $L_S$ be a fixed-temperature Gaussian or logistic likelihood for a fixed finite sample. After removing any parameter-independent prefactor, it is bounded and continuous in the training outputs, with $L_S(0)>0$. Hence $\mathbb E|L_S-L_S(0)|\to0$. Writing $Z=\mathbb E L_S$ gives

$$
\mathrm{TV}(\Pi(\cdot\mid S),\Pi)
=\tfrac12\mathbb E\left|L_S/Z-1\right|\longrightarrow0.
$$

The raw prior's latent sign probability is exactly $1/2$ by readout symmetry; conditional readout variance is positive almost surely. Thus posterior correct-sign confidence tends to $1/2$ at every fixed input, even for the constant target $+1$. Logistic posterior-predictive probability also tends to $1/2$.

This rules out the original width-independent $>2/3$ confidence guarantee for raw priors with $\gamma\ge1$ and a fixed smooth likelihood, and rules out its strong-prior-first analogue. It does not prove failure of the sign of the posterior mean, which could be correct even when arbitrarily small. Nor does it rule out learning when sample size or likelihood temperature grows with prior concentration. The statement concerns our shrinking-output priors, not every conventional Bayesian neural-network scaling.

### Keeping the global margin: an explicit XOR counterexample

Global margin conditioning does not fix the strong-prior-first problem. Take $d=2$, $L=2$, any fixed $N\ge3$, and uniform inputs on the four-point cube. Retain $|z_w(x)|>1/2$ everywhere and let $f(x)=x_1x_2$.

**Claim.** The globally minimum-energy sign functions are precisely the two constants and four signed coordinates.

To prove it, write $u(s)=\tanh^2(\sqrt s)$ for $s\ge0$. This function is strictly concave. Indeed, at $s=r^2>0$,

$$
u'(r^2)=\frac{\tanh r\,\mathrm{sech}^2r}{r},
$$

whose derivative with respect to $r$ has the sign of $r(1-3\tanh^2r)-\tanh r<0$. The last inequality follows from $\tanh r>r\,\mathrm{sech}^2r$; their difference starts at zero and has positive derivative $2r\,\mathrm{sech}^2r\tanh r$.

For a network with the closed margin $|z(x)|\ge1/2$, put $b=\lVert W\rVert_F/\sqrt N$. Cauchy–Schwarz and Jensen's inequality give

$$
\frac14\le\mathbb E_x z(x)^2
\le\lVert v\rVert_2^2\sum_i\mathbb E_x\tanh^2(w_i\cdot\bar x)
\le\lVert v\rVert_2^2\sum_i\tanh^2(\lVert w_i\rVert_2)
\le N\lVert v\rVert_2^2\tanh^2 b.
$$

Here $\bar x=(1,x_1,x_2)$ and $\mathbb E_x(w_i\cdot\bar x)^2=\lVert w_i\rVert_2^2$. Consequently

$$
\kappa_N(w)\ge db^2+\frac1{4\tanh^2b}\ge
E_0:=\min_{b>0}\left[db^2+\frac1{4\tanh^2b}\right].
$$

Taking every row along the same constant or Boolean coordinate, with norm $b$, and taking $v_i=\pm[2N\tanh b]^{-1}$ attains $E_0$ in the closed margin set. Scaling the readout slightly upward approaches this infimum in the original strict-margin set.

Equality requires every affine preactivation to have constant absolute value on the cube. If $a_0+a_1x_1+a_2x_2$ has constant square, its nonconstant Fourier coefficients $2a_0a_1,2a_0a_2,2a_1a_2$ vanish, so at most one coefficient is nonzero. Equality over row norms makes all rows nonzero with equal norm. Equality in Cauchy–Schwarz at every input then makes their hidden functions proportional. The output is therefore $1/2$ times a constant or signed coordinate, proving the claim.

Every other representable sign function has a strictly larger energy infimum. Otherwise coercivity at fixed $N$ gives a convergent sequence approaching $E_0$ whose limit retains its closed margin and signs, contradicting the equality classification. XOR is even exactly representable as a real output at width three with all weights less than three in magnitude. Set $a=\tanh1$, $b=\tanh3$, and

$$
H_+(x)=\tanh(x_1+x_2-1),\qquad
H_-(x)=\tanh(-x_1-x_2-1).
$$

Then

$$
z(x)=\frac{2[H_+(x)+H_-(x)]}{3a-b}
+\frac{a+b}{a(3a-b)}\tanh1
=x_1x_2.
$$

Indeed $H_++H_-=a-b$ on equal bits and $-2a$ on unequal bits. The constant hidden neuron computes $\tanh1$. Since $a>3/4$ and $b<1$, both readout coefficients are below three. Extra neurons can be zero-padded. Thus the obstruction does not rely on the true regression mean being absent from the learner class.

Now let $U_g=\lbrace w:g(x)z_w(x)>1/2\text{ for every }x\rbrace$, and let $\kappa_N(g)$ be its energy infimum. For any fixed, positive continuous, bounded likelihood $L_S$, Gaussian Laplace bounds give

$$
\lim_{\sigma\to0}2\sigma^2\log
\int_{U_g}L_S(w)\,d\mu_\sigma(w)=-\kappa_N(g).
$$

The upper bound uses boundedness; the lower bound uses a small ball around an approximately minimizing point where $L_S$ stays positive. Thus the posterior concentrates on the six minimum-energy sign functions regardless of the finite sample and its labels. Each disagrees with XOR on exactly half the cube, so every posterior mixture has Gibbs error tending to $1/2$.

Writing $p_S(x)$ for posterior correct-sign probability gives $\mathbb E_xp_S(x)\to1/2$. Since

$$
\mathbb E_xp_S(x)\ge\tfrac23D\lbrace p_S>2/3\rbrace,
$$

the limiting lower bound on confidence-failure mass is $1/4$.

The same coercive Laplace argument concentrates parameters near the compact minimum-energy parameter set, whose outputs are exactly $\pm1/2$ times constants or coordinates. For each such output, the average logistic probability of the correct XOR label is $1/2$, because correct and incorrect inputs pair and the logistic link satisfies $s(t)+s(-t)=1$. Thus the ordinary Bernoulli posterior-predictive confidence criterion also fails.

## 4. What remains possible with fixed observation variance?

A conventional Bayesian prior-mass bound remains available. For Gaussian likelihood $\exp[-\beta\sum_i(z_w-f)^2]$ with fixed $\beta>0$, suppose the prior gives mass $p>0$ to the uniform tube $|z_w-f|\le\rho$. Fix test tolerance $\tau$, and put $c=1-e^{-\beta\tau^2}$. A parameter whose test tail error exceeds $r$ has expected likelihood at most $e^{-ncr}$. The posterior normalizer is at least $p e^{-\beta n\rho^2}$. Markov's inequality therefore gives, with sample probability at least $1-\delta$,

$$
\Pi\bigl(D\lbrace|z_w-f|>\tau\rbrace>r\mid S\bigr)
\le p^{-1}\delta^{-1}e^{n\beta\rho^2-ncr}.
$$

If $\beta\rho^2\le cr/2$, taking

$$
n\ge\frac2{cr}\left[\log(1/p)+\log(1/(\delta b))\right]
$$

makes this bad posterior mass at most $b$, and Gibbs tail error at most $r+b$. Thus ordinary likelihoods certainly permit learning; the issue is the cost of the relevant prior neighborhood.

For fixed $\gamma\ge1$, our available finite-scale teacher-tube estimate is $p\ge e^{-A_LN^\gamma}$. This route therefore pays a width-dependent $N^\gamma$ factor. It gives a polynomial bound when learner width is itself polynomially bounded in teacher complexity, at fixed depth, but does not recover the main every-width guarantee.

The finite-scale theorem above removes this width dependence when observation variance is instead $N^{-\gamma}$. Its proof explicitly controls growing-width effects. For the globally margin-conditioned width-first model with a **fixed** smooth likelihood, the raw-prior total-variation argument does not apply; a full classification for every $\gamma\ge1$ remains open here.

Finally, bounded-energy compression is the ingredient that could carry a polynomial-depth theorem under a suitable internal-stability support restriction. One must also supply an admissible teacher comparator and positive prior mass near it within that support. We have not checked a complete smooth-likelihood analogue of the robust-prior theorem. Neither that analogue nor the unrestricted polynomial-depth problem is settled by this note.

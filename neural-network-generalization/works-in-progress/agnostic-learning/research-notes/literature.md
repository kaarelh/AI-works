# Literature for the agnostic (MSE) NNBayes question

*This is the literature survey of the agnostic-learning note ([`../README.md`](../README.md)). It was compiled on 11 November 2026 for the brief [`problem-brief.md`](problem-brief.md), whose Claims A–E it refers to, before the proof notes of this folder were written. Every reference is annotated with one sentence on its relevance to*

* **(a)** agnostic oracle inequalities for tempered Bayesian neural posteriors, and
* **(b)** failure of interpolating learners under label noise on finite domains.

`NNG/` denotes the project folder `neural-network-generalization/` of this repository. Section 1 proves the standard facts that the relevance sentences rely on, so that no sentence depends on an unchecked theorem number. Section 2 says how the references were verified: against search listings only, without opening any full text. Section 3 lists the references.

*Status.* This survey was not refereed as a whole. The results of Section 1 that the proof notes use were re-proved and refereed there: Fact 2 and Corollary 2 are Theorems C.1 and C.2 of [`C-fixed-temperature-bayes.md`](C-fixed-temperature-bayes.md), the width dependence of remark (iii) after Corollary 2 is its Theorem C.5, and the pointer of Section 1.6(iii) is carried out in [`B-tempered-likelihood.md`](B-tempered-likelihood.md) (Lemmas 5.1–5.2 and Theorem 6.3). Sections 0 and 1 were written before those notes. Where a proof note has since settled a point, a bracketed note beginning "At finalization" says so; the text around it is unchanged.

---

## 0. Summary for the lead

1. **Claim C is the standard exp-concave progressive-mixture bound combined with the repo's tube-mass bound.** Corollary 2 (Section 1.2) proves the brief's displayed inequality $\mathbb E\,L_D\le L_D(g)+4\rho+A_L N^\gamma/(\eta(n+1))$ for $\eta\le 1/8$. The predictor is the average over prefixes $t=0,\dots,n$ of the posterior means of the *clipped* outputs. The statement holds in expectation only: Audibert (2007) shows progressive mixtures can deviate at rate $1/\sqrt n$. Fact 3 gives a high-probability version for a hot Gibbs posterior, with rate $(4+A_L+2\log\frac1\delta)\sqrt{N^\gamma/n}$. Both bounds pay $N^\gamma$. At fixed $\eta$ the failure of width-uniformity is real: by slt-likelihood Section 3, the excess tends to 1 as $N\to\infty$ for the constant target 1 (remark (iii) after Corollary 2). [At finalization: `C-fixed-temperature-bayes.md` proves these statements as its Theorems C.1, C.2 and C.5, with high-probability versions in Theorems C.6 and C.7. Its Remark 3 after Theorem C.1 shows that, for some priors, the bound fails for the progressive mixture of the unclipped posterior means and for its clip.]
2. **Closest published analogue of Claims A, B and D:** Zhu–Srebro (COLT 2025) and Zhu–Ohannessian–Srebro (arXiv 2603.22644, March 2026). For noisy binary classification they study a PAC-Bayes/MDL rule whose KL-to-prior weight is $\lambda$. At $\lambda=1$ the rule is the (empirical) Bayes posterior and overfits with non-vanishing agnostic excess. Finite $\lambda$ gives tempered inconsistency. The window $1\ll\lambda\ll m/\log m$ is agnostically consistent. Read $\lambda\leftrightarrow c$ and $m\leftrightarrow n$. Earlier warnings: Grünwald–Langford (2007) and Grünwald–van Ommen (2017, SafeBayes). I found no neural-network or squared-loss version.
3. **Claim A's constant is Cover's (1968) $k$-nearest-neighbour formula $R^*(1+1/k)$,** averaged over the binomial (asymptotically Poisson) count of training copies of the test atom. Numerically the brief's values are confirmed: $1+\mathbb E[1/K;K\ge1]=1.484829$ at $n=2^d$, with maximum $1.517351$ at $n\approx1.503\cdot2^d$ (Section 5). [At finalization: `A-tight-conditioning-fails.md` Theorem 4.4 and Corollary 4.5 prove that, at depth $L\ge3$, SP$_c$ with $cK_{\rm mem}=o(n)$, at learner widths $N\ge N_0={\rm poly}(n)$, has excess at least $\beta(\lambda)-o(1)$ on this law along $n=\lambda2^d$, $d\to\infty$, where $\beta(\lambda)=\mathbb E[1/K;K\ge1]$ for $K\sim{\rm Poisson}(\lambda)$, so $\beta(1)=0.4848$.]
4. **Pointer for Claim D (my derivation, not reviewed; Section 1.6(iii)).** Section 4 of the repo's noisy-interpolation note already proves a width-uniform Rademacher bound for tanh networks: $\mathrm{Rad}_m\{z_w:\kappa_N(w)\le K\}\le D_{d,H}(K/H)^{H/2}/\sqrt m$ (eq. (15)). A clip-mixture identity replaces positive homogeneity there. Only its first-layer count is specific to the cube, and Sauer's lemma removes that at the cost of a $\sqrt{\log m}$ factor. Inserted into Claim B's argument, it gives a uniform-convergence threshold $c\gg n^{1-1/H}$ up to polylog factors, i.e. $\theta_L=1/H$ instead of $1/(4H)$. That matches Claim A's memorization threshold $c\ll n^{1-1/H}d^{-1/H}$ in the exponent, so it would close Claim D's exponent gap. [At finalization: `B-tempered-likelihood.md` carries this out for arbitrary inputs, with constants written out (Lemmas 5.1–5.2, Theorem 6.3): with $c=n^{1-\theta}$, $\theta<1/H$ suffices for clipped predictions, at every learner width $N\ge m$. Its Theorem 7.4 shows that $\theta>1/H$ fails for $H\ge2$, on the noisy cube with $d=\log_2n$. B's proof was refereed; the derivation in Section 1.6(iii) below was not.]
5. **SP$_c$ is a cold posterior.** SP$_c$ at scale $\sigma$ is exactly the $\sigma=1$ posterior raised to the power $1/T$ with $T=\sigma^2$, the cold-posterior family of Wenzel et al. (2020). Its $\sigma\to0$ limit is Tikhonov-penalized least squares with $\lambda_n=c/n$ (Section 1.5). In a linear-Gaussian (GP) model, its posterior mean is kernel ridge regression with ridge $c/n$ at every $\sigma$. Empirically, the cold-posterior benefit disappears and then reverses under label noise (Aitchison 2021). Cold posteriors also worsen double descent in GPs (Hodgkinson et al. 2023). Both observations are consistent with Claim A.
6. **Published norm-based capacity bounds do not by themselves give the repo's width-uniform tanh capacity.** Bartlett (1998) needs per-unit $\ell_1$ bounds, which $\kappa_N$ controls only up to a factor $\sqrt N$. Neyshabur–Tomioka–Srebro, Neyshabur–Bhojanapalli–Srebro and Golowich–Rakhlin–Shamir are proved for ReLU or positively homogeneous activations. The Bartlett–Foster–Telgarsky spectral complexity grows like $\Theta(\sqrt N)$ on balanced clones of a fixed network (computed). The product of layer norms is invariant under cloning and satisfies $\le(K/L)^{L/2}/\sqrt d$ under $\kappa_N\le K$. This is sharper by $L^{L/2}$ than eq. `energy-lipschitz`, as the brief anticipated.
7. **Interpolation literature.** Benign overfitting needs a long tail of unimportant directions (Bartlett–Long–Lugosi–Tsigler) or high dimension (Rakhlin–Zhai; Kornowski–Yehudai–Shamir). Finite domains with $n\gtrsim\lvert X\rvert$ are the opposite extreme. For squared loss, min-norm ReLU interpolation in one dimension is *catastrophic*, not tempered (Joshi–Vardi–Srebro); that matters for Claim A$'$. Even consistent interpolation can require $d\ge n e^{\Omega(\sigma^2/\varepsilon)}$ (Wang–Donhauser–Yang).
8. **Bayesian monotonicity (Fact 4).** Under a well-specified model, and averaged over the prior, the Bayes-predictive risk is non-increasing in $n$. Sample-wise peaks therefore require misspecification. In Claim A the misspecification is the assumed observation variance $c\sigma^2\to0$.

---

## 1. Standard facts used by the relevance sentences

**Notation.** $\mathrm{clip}(t)=\max\{-1,\min\{1,t\}\}$. Write $\bar z_w=\mathrm{clip}\circ z_w$, $L_D(f)=\mathbb E_{(x,y)\sim D}(f(x)-y)^2$ and $\hat L_S(f)=\frac1n\sum_i(f(x_i)-y_i)^2$. $D$ is any distribution on $X\times[-1,1]$, and $S=((x_i,y_i))_{i\le n}$ is iid from $D$. $\mu$ is a prior on a measurable parameter space such that $(w,x)\mapsto z_w(x)$ is jointly measurable; this holds for continuous networks. $\mathrm{KL}(\rho\Vert\mu)$ is relative entropy.

### 1.1 Exp-concavity threshold

**Fact 1.** For $\eta>0$ and $y\in[-1,1]$ let $\phi_y(p)=e^{-\eta(p-y)^2}$. Then $\phi_y$ is concave on $[-1,1]$ for every $y\in[-1,1]$ if and only if $\eta\le1/8$.

*Proof.* $\phi_y''(p)=2\eta\bigl(2\eta(p-y)^2-1\bigr)\phi_y(p)$. For $p,y\in[-1,1]$ we have $(p-y)^2\le4$.

* If $\eta\le1/8$, then $2\eta(p-y)^2\le1$, so $\phi_y''\le0$ on $[-1,1]$.
* If $\eta>1/8$, then $\phi_1''(-1)=2\eta(8\eta-1)e^{-4\eta}>0$. By continuity $\phi_1''>0$ on some interval $[-1,-1+\epsilon)$, so $\phi_1$ is not concave on $[-1,1]$. $\square$

The script `check_expconcave_mixable.py` confirms this on a grid.

*Mixability (recalled; checked numerically, not against the texts).* Squared loss with outcomes in $[-Y,Y]$ is $\eta$-mixable for $\eta\le1/(2Y^2)$ (Vovk 1990, 2001; Haussler–Kivinen–Warmuth 1998); for $Y=1$ that is $\eta\le1/2$. Random-mixture tests found no violation at $\eta=1/2$ and found violations at $\eta=0.6$. Mixability allows a learning rate four times larger, but the aggregated prediction is then Vovk's substitution function, not the posterior mean. It therefore does not cover Bayesian-model-average predictors.

### 1.2 Progressive mixture of tempered posterior means (Claim C)

For $0\le t\le n$ define
$$
\pi_t(dw)\propto\exp\Bigl(-\eta\sum_{i\le t}(\bar z_w(x_i)-y_i)^2\Bigr)\mu(dw),\qquad
\hat f_t(x)=\int\bar z_w(x)\,\pi_t(dw),\qquad
\bar f_n=\frac1{n+1}\sum_{t=0}^{n}\hat f_t .
$$

**Fact 2.** Let $0<\eta\le1/8$. For every probability measure $\rho\ll\mu$ that does not depend on $S$,
$$
\mathbb E_S\,L_D(\bar f_n)\le\int L_D(\bar z_w)\,\rho(dw)+\frac{\mathrm{KL}(\rho\Vert\mu)}{\eta(n+1)} .
$$

*Proof.* Let $(x_{n+1},y_{n+1})\sim D$ be independent of $S$; it is used only in the analysis. Put $\ell_i(w)=(\bar z_w(x_i)-y_i)^2\in[0,4]$ and $W_t=\int e^{-\eta\sum_{i\le t}\ell_i}\,d\mu\in(0,1]$, with $W_0=1$.

1. *One step.* $W_{t+1}/W_t=\int e^{-\eta\ell_{t+1}(w)}\pi_t(dw)$. The function $\phi_{y_{t+1}}$ is concave on $[-1,1]$ by Fact 1, and $\bar z_w(x_{t+1})\in[-1,1]$. Jensen's inequality gives $W_{t+1}/W_t\le\phi_{y_{t+1}}(\hat f_t(x_{t+1}))$, that is, $(\hat f_t(x_{t+1})-y_{t+1})^2\le-\eta^{-1}\log(W_{t+1}/W_t)$.
2. *Telescoping.* $\sum_{t=0}^{n}(\hat f_t(x_{t+1})-y_{t+1})^2\le-\eta^{-1}\log W_{n+1}$.
3. *Donsker–Varadhan.* For measurable $h\ge0$, $-\log\int e^{-h}d\mu\le\int h\,d\rho+\mathrm{KL}(\rho\Vert\mu)$. With $h=\eta\sum_{i\le n+1}\ell_i$ the right side of step 2 is at most $\sum_{i\le n+1}\int\ell_i\,d\rho+\mathrm{KL}(\rho\Vert\mu)/\eta$.
4. *Expectations.* $\hat f_t$ depends only on the first $t$ pairs, which are independent of $(x_{t+1},y_{t+1})$. Hence $\mathbb E(\hat f_t(x_{t+1})-y_{t+1})^2=\mathbb E\,L_D(\hat f_t)$. Because $\rho$ is fixed, Tonelli gives $\mathbb E\int\ell_i\,d\rho=\int L_D(\bar z_w)\,d\rho$. Therefore $\sum_{t=0}^n\mathbb E L_D(\hat f_t)\le(n+1)\int L_D(\bar z_w)d\rho+\mathrm{KL}(\rho\Vert\mu)/\eta$.
5. *Convexity.* $f\mapsto L_D(f)$ is convex, so $L_D(\bar f_n)\le\frac1{n+1}\sum_tL_D(\hat f_t)$. Take expectations and divide by $n+1$. $\square$

The script `check_progressive_mixture.py` checks Fact 2 by Monte Carlo on a finite dictionary.

**Corollary 2 (the inequality of Claim C).** Assume:

* $X\subseteq[-1,1]^d$ is compact, $L\ge2$, $\gamma\ge1$;
* $\mu=\mu_{N,\gamma}$, with Gaussian coordinates or any coordinate law of `paper.tex` eq. `law`;
* $g$ is computed by a depth-$L$, width-$C$ network with weights of absolute value at most $B\ge1$, and $N\ge C$.

Then for every $\rho\in(0,1]$,
$$
\mathbb E_S\,L_D(\bar f_n)\le L_D(g)+4\rho+\frac{A_L(d,C,B,\rho)\,N^\gamma}{\eta(n+1)} .
$$

*Proof.* Let $U_\rho=\{w:\sup_X\lvert z_w-g\rvert<\rho\}$ and take $\rho_*=\mu(\cdot\mid U_\rho)$. The set $U_\rho$ is open with $\mu(U_\rho)>0$. By `NNG/side-results/continuous-domains/source/paper.tex`, Proposition `tube`, eq. `tube-mass`, together with Remark `cube` for $X\subseteq[-1,1]^d$, we have $\mathrm{KL}(\rho_*\Vert\mu)=\log(1/\mu(U_\rho))\le A_LN^\gamma$, with $A_L$ given by eq. `A`.

Now fix $w\in U_\rho$ and $x\in X$.

* $\mathrm{clip}$ is 1-Lipschitz, so $\lvert\bar z_w(x)-\mathrm{clip}\,g(x)\rvert<\rho$. Also $\lvert\bar z_w(x)+\mathrm{clip}\,g(x)-2y\rvert\le4$. Hence $(\bar z_w(x)-y)^2\le(\mathrm{clip}\,g(x)-y)^2+4\rho$.
* $\mathrm{clip}$ is the metric projection onto $[-1,1]\ni y$, so $(\mathrm{clip}\,g(x)-y)^2\le(g(x)-y)^2$.

Integrate over $D$ and over $\rho_*$, then apply Fact 2. $\square$

**Remarks on Corollary 2.**

* (i) *The predictor.* It is the average over prefixes of posterior means of clipped outputs, and the likelihood also uses clipped outputs, as in FIX$_\eta$. The argument does not cover $\mathrm{clip}$ of the posterior mean of unclipped outputs. [At finalization: for some priors the bound fails for the progressive mixture of the unclipped posterior means and for its clip (`C-fixed-temperature-bayes.md`, Remark 3 after Theorem C.1), and Theorem C.5(e) there extends the large-width failure to unclipped predictors.] It also does not cover the plain final posterior mean $\hat f_n$; see Høgsgaard–Rebeschini–Wegel (2026) for finite dictionaries.
* (ii) *In expectation only.* High-probability versions need another argument (Audibert 2007; Fact 3).
* (iii) *Width-uniformity genuinely fails at fixed $\eta$.* Take $y\equiv1$. The target $g\equiv1$ is computed at width 1 with bounded weights. The FIX$_\eta$ likelihood $e^{-\eta\sum_i(\bar z_w(x_i)-1)^2}$ is bounded, continuous in the outputs and positive at $0$. For $\gamma\ge1$ the outputs on a fixed sample tend to $0$ in probability as $N\to\infty$ (`NNG/works-in-progress/slt-likelihood/README.md`, Section 3). That section's argument therefore gives $\mathrm{TV}(\pi_t,\mu)\to0$ for every fixed sample. Readout symmetry gives $\int\bar z_w(x)\,d\mu=0$, so $\sup_x\lvert\hat f_t(x)\rvert\le2\,\mathrm{TV}(\pi_t,\mu)\to0$. By dominated convergence, $\mathbb E\,L_D(\bar f_n)\to1$ at fixed $n$, while $L_D(g)=0$.
* (iv) *Claim A's distribution.* Corollary 2 applies to the atom distribution of Claim A with $g\equiv0$ ($C=B=1$). With $n=2^d$ and $N=\mathrm{poly}(d)$, FIX$_\eta$'s progressive mixture has excess at most $4\rho+A_L(d,1,1,\rho)N^\gamma/(\eta(n+1))\to0$. The atom failure is specific to the cold limit, not to Bayesian averaging.

### 1.3 Gibbs posterior in high probability, and the cost of interpolating noise

Let $\hat\rho_\lambda(dw)\propto e^{-\lambda\hat L_S(\bar z_w)}\mu(dw)$, where $\lambda>0$ is fixed before seeing the data.

**Fact 3.**

* (i) With probability at least $1-\delta$, simultaneously for all probability measures $\rho\ll\mu$, including data-dependent ones,
  $$\int L_D(\bar z_w)\,d\rho\le\int\hat L_S(\bar z_w)\,d\rho+\frac{2\lambda}n+\frac{\mathrm{KL}(\rho\Vert\mu)+\log(1/\delta)}{\lambda}.\tag{3.1}$$
* (ii) For every data-independent $\rho_*\ll\mu$, with probability at least $1-2\delta$,
  $$\int L_D(\bar z_w)\,d\hat\rho_\lambda\le\int L_D(\bar z_w)\,d\rho_*+\frac{4\lambda}n+\frac{\mathrm{KL}(\rho_*\Vert\mu)+2\log(1/\delta)}{\lambda}.$$
* (iii) In the setting of Corollary 2, take $\lambda=\sqrt{nN^\gamma}$. With probability at least $1-2\delta$, both the Gibbs risk $\int L_D(\bar z_w)\,d\hat\rho_\lambda$ and the risk of the posterior mean of clipped outputs are at most
  $$L_D(g)+4\rho+\bigl(4+A_L+2\log\tfrac1\delta\bigr)\sqrt{N^\gamma/n}.$$
* (iv) *Interpolating noise is expensive in KL.* Let $v_0=\mathbb E\,\mathrm{Var}(y\mid x)$ and $0\le r<v_0$, and take $\lambda=n(v_0-r)/4$, fixed in advance. On the event of (i), every $\rho\ll\mu$ with $\int\hat L_S(\bar z_w)\,d\rho\le r$ satisfies
  $$\mathrm{KL}(\rho\Vert\mu)\ge\frac{n(v_0-r)^2}{8}-\log\frac1\delta .$$
  In particular, every measurable set $U$ whose members all have $\hat L_S(\bar z_w)\le r$ has $\mu(U)\le\delta^{-1}e^{-n(v_0-r)^2/8}$.

*Proof.*

* (i) For fixed $w$, the variables $\ell_i(w)\in[0,4]$ are iid with mean $L_D(\bar z_w)$. Hoeffding's lemma gives $\mathbb E_Se^{\lambda(L_D-\hat L_S)}\le e^{\lambda^2\cdot16/(8n)}=e^{2\lambda^2/n}$. By Tonelli and Markov, with probability at least $1-\delta$, $\int e^{\lambda(L_D-\hat L_S)}d\mu\le e^{2\lambda^2/n}/\delta$. Donsker–Varadhan, $\int h\,d\rho\le\mathrm{KL}(\rho\Vert\mu)+\log\int e^hd\mu$ for bounded $h$, then gives (3.1).
* (ii) The variables $\int\ell_i\,d\rho_*\in[0,4]$ are iid with mean $\int L_Dd\rho_*$. Hoeffding and Markov give, with probability at least $1-\delta$, $\int\hat L_S\,d\rho_*\le\int L_D\,d\rho_*+2\lambda/n+\log(1/\delta)/\lambda$. The Gibbs measure $\hat\rho_\lambda$ minimizes $\rho\mapsto\int\hat L_S\,d\rho+\mathrm{KL}(\rho\Vert\mu)/\lambda$, the equality case of Donsker–Varadhan. Chain (3.1) at $\hat\rho_\lambda$, this minimality, and the last display.
* (iii) Use $\rho_*$ and the two bounds from the proof of Corollary 2. Then $4\lambda/n=4\sqrt{N^\gamma/n}$ and $(A_LN^\gamma+2\log\frac1\delta)/\lambda\le(A_L+2\log\frac1\delta)\sqrt{N^\gamma/n}$ because $N^\gamma\ge1$. The posterior-mean bound follows by convexity (Jensen).
* (iv) $L_D(f)\ge v_0$ for every $f$, so (3.1) gives $v_0\le r+2\lambda/n+(\mathrm{KL}+\log\frac1\delta)/\lambda$. Substitute $\lambda=n(v_0-r)/4$. For the set version use $\rho=\mu(\cdot\mid U)$; this is allowed because (3.1) holds for all $\rho$ at once. $\square$

**Reading of Fact 3.**

* Part (iii) is a polynomial, high-probability agnostic bound at polynomial width. Taking $\rho=\varepsilon/8$, it suffices that $n\ge4\bigl(4+A_L(d,C,B,\varepsilon/8)+2\log\tfrac1\delta\bigr)^2N^\gamma/\varepsilon^2$. The per-sample inverse temperature $\lambda/n=\sqrt{N^\gamma/n}\to0$, so this is a hot posterior. Like Corollary 2, the bound is not width-uniform.
* Part (iv) is relevant to Claim E (finite scale). For a finite-scale version of Claim A, the cost $\log(1/\mu_{N,\gamma}(\text{memorizer tube}))$ must lie between $\Omega(n)$, by (iv), and $o(n)\cdot N^\gamma/c$, the likelihood scale. Part (iv) does not obstruct such a version, but it quantifies what is needed. In Claim A's setting $v_0=1$. A sample point whose atom holds $k$ training points contributes expected training loss $1-1/k$ to the atom-mean fit. The atom count seen from a random sample point is asymptotically $1+\mathrm{Poisson}(\lambda)$ with $\lambda=n/2^d$, and $\mathbb E[1/(1+\mathrm{Poisson}(\lambda))]=(1-e^{-\lambda})/\lambda$. So $r\approx1-(1-e^{-\lambda})/\lambda$ (about $0.37$ at $\lambda=1$), and $v_0-r\approx(1-e^{-\lambda})/\lambda$ is a positive constant. [At finalization: `E-finite-prior-scale.md` proves a finite-scale version of Claim A at every $\gamma\ge1$ and depth $L\ge3$ (its Theorem 5.2), with a memorizer that survives the prior's noise (its Proposition 4.4).]

### 1.4 Monotonicity of well-specified Bayes risk

**Fact 4.** Let $\theta\sim\Pi$, and given $\theta$ let $(x_1,y_1),\dots,(x_{n+1},y_{n+1}),(x,y)$ be iid with $\mathbb Ey^2<\infty$. Let $S_n$ be the first $n$ pairs and $f^*_n(x)=\mathbb E[y\mid S_n,x]$. Then $\mathbb E(y-f^*_{n+1}(x))^2\le\mathbb E(y-f^*_n(x))^2$.

*Proof.* $f^*_n(x)$ is the orthogonal projection of $y$ onto $L^2(\sigma(S_n,x))$, which is a closed subspace of $L^2(\sigma(S_{n+1},x))$. Projecting onto a larger subspace cannot increase the residual. $\square$

This is an average over the prior. For a fixed $D$, monotonicity can fail even for a well-specified model. A sample-wise peak in prior-averaged Bayes risk requires misspecification of the prior, the noise model or the temperature.

### 1.5 SP$_c$ as a cold posterior, penalized least squares and kernel ridge regression

Let $F_c(w)=\kappa_N(w)+c^{-1}\sum_i(z_w(x_i)-y_i)^2$ and $\Pi_\sigma\propto e^{-F_c/(2\sigma^2)}$; this is SP$_c$ at scale $\sigma$.

* **(i) Cold posterior.** $\Pi_\sigma=(\Pi_1)^{1/T}/Z_T$ with $T=\sigma^2$, by algebra. SP$_c$ is the cold-posterior family (prior and likelihood tempered together) of the $\sigma=1$ model, with observation variance $c$.
* **(ii) The $\sigma\to0$ limit is penalized least squares.** Fix $N$, $n$ and $S$. For every $\eta'>0$, $\Pi_\sigma\{F_c>\min F_c+\eta'\}\to0$.

  *Proof.* $F_c\ge\kappa_N=w^\top\Lambda w$ with $\Lambda$ positive diagonal, so $F_c$ is continuous and coercive and attains its minimum $m$ at some $w_0$. Take a ball $B\ni w_0$ on which $F_c<m+\eta'/3$, and choose $\theta\in(0,1)$ with $(1-\theta)(m+\eta')\ge m+2\eta'/3$. Then
  $$\int_{F_c>m+\eta'}e^{-F_c/2\sigma^2}\le e^{-(1-\theta)(m+\eta')/2\sigma^2}\int e^{-\theta\kappa_N/2\sigma^2}=e^{-(1-\theta)(m+\eta')/2\sigma^2}\Bigl(\frac{2\pi\sigma^2}\theta\Bigr)^{p/2}(\det\Lambda)^{-1/2},$$
  while $\int_Be^{-F_c/2\sigma^2}\ge\mathrm{vol}(B)e^{-(m+\eta'/3)/2\sigma^2}$. The ratio is at most $C(p,\theta,\Lambda,B)\,\sigma^pe^{-\eta'/(6\sigma^2)}\to0$. $\square$

  This is the argument of `NNG/works-in-progress/slt-likelihood/README.md`, Section 2 (lines 73–80), which treats $c=1$ with threshold $E_\star+1$; its line 96 notes that any $c>0$ works. The limiting learner therefore lives on near-minimizers of $\hat L_S(z_w)+(c/n)\kappa_N(w)$, i.e. Tikhonov-penalized least squares with $\lambda_n=c/n$. Thus $c=1$ corresponds to $\lambda_n=1/n$, and $c=n^{1-\theta}$ to $\lambda_n=n^{-\theta}$.
* **(iii) Linear-Gaussian (GP) case.** Suppose $z_w(x)=\langle w,\varphi(x)\rangle$ and $\kappa_N(w)=\lVert w\rVert^2$ in suitable coordinates, as in a linearized or NNGP regime. Then $\Pi_\sigma$ is Gaussian. Its mean is the minimizer of the quadratic $F_c$, which is the kernel ridge regression estimator $\arg\min_f\hat L_S(f)+(c/n)\lVert f\rVert_k^2$ for $k(x,x')=\langle\varphi(x),\varphi(x')\rangle$, independent of $\sigma$. Its covariance is $\sigma^2(\Lambda+c^{-1}\Phi^\top\Phi)^{-1}$. This is the Kimeldorf–Wahba correspondence; see Kanagawa et al. (2018).
* **(iv) The aggregation regret term for SP$_c$.** Read SP$_c$ as exponential weights with prior $\mu_\sigma$ and rate $\eta=1/(2c\sigma^2)$. The term $\log(1/\mu_\sigma(U))/\eta$ for a teacher tube $U$ is then at most $c(E_\star+o(1))$ as $\sigma\to0$, by $\liminf\sigma^2\log\mu_\sigma(U)\ge-E_\star/2$ in the proof of Theorem `strong` in `paper.tex`. That is exactly Claim B's empirical slack $c(E_\star+1)$ over $n$ samples. However, $\eta\to\infty$ violates Fact 1, so the online-to-batch step is unavailable and Claim B needs uniform convergence.

### 1.6 Norm products, cloning, and a pointer for Claim D

* **(i) Norm products and Lipschitz constant.** Put $\kappa_1=\frac dN\lVert W^1\rVert_F^2$, $\kappa_\ell=\lVert W^\ell\rVert_F^2$ for $2\le\ell\le L-1$, and $\kappa_L=N\lVert v\rVert^2$. Then
  $$\lVert v\rVert_2\prod_{\ell=2}^{L-1}\lVert W^\ell\rVert_F\,\lVert W^1\rVert_F=\Bigl(\prod_{\ell=1}^L\kappa_\ell\Big/d\Bigr)^{1/2}\le\frac{(K/L)^{L/2}}{\sqrt d}\quad\text{when }\kappa_N\le K,$$
  by AM–GM. Since tanh is 1-Lipschitz and spectral norm $\le$ Frobenius norm, $\mathrm{Lip}(z_w)\le(K/L)^{L/2}/\sqrt d$. This is sharper by $L^{L/2}$ than `paper.tex` eq. `energy-lipschitz`, which gives $K^{L/2}/\sqrt d$. It was checked on 300 random networks; see `check_atoms_and_cloning.py`.
* **(ii) Cloning.** Balanced $N$-fold cloning of a width-1 network leaves $\kappa_N$, the Frobenius product and the spectral product unchanged (computed for $N=1,\dots,1024$). Bartlett–Foster–Telgarsky's spectral complexity, with $M_i=0$, is
  $$R_A=\Bigl(\prod_i\lVert A_i\rVert_\sigma\Bigr)\Bigl(\sum_i(\lVert A_i^\top\rVert_{2,1}/\lVert A_i\rVert_\sigma)^{2/3}\Bigr)^{3/2}$$
  (definition as I recall it; the search confirmed only the form of the correction term). For the clone this equals $(\prod_i\lVert A_i\rVert_\sigma)(2N^{1/3}+1)^{3/2}=\Theta(\sqrt N)$. The reason: $W^1=\mathbf1u^\top$ has row-norm sum $N\lVert u\rVert$ and spectral norm $\sqrt N\lVert u\rVert$; $W^2=\frac\alpha N\mathbf1\mathbf1^\top$ has ratio $\sqrt N$; the readout has ratio $1$.
* **(iii) Pointer for Claim D.** This is my derivation from the repo; it has not been reviewed. [At finalization: see the note at the end of Section 0, item 4.]
  * *What the repo proves.* `NNG/works-in-progress/noisy-interpolation/README.md`, Section 4, proves for $X=\{-1,1\}^d$ and all widths at once that $\mathrm{Rad}_m\{z_w:\kappa_N(w)\le K\}\le D_{d,H}(K/H)^{H/2}/\sqrt m$, with $D_{d,H}=\sqrt2(d+2)+\frac{H-1}2$ (eq. (15)). The ingredients are: clipping (eq. (12)); the identity (13), which writes $\tanh(ru)/r$ on $\lvert u\rvert\le1$ as a convex mixture of clips (I checked it by differentiation; it fails for $\lvert u\rvert>1$, which is never used); the path-norm bound $P\le(\kappa_N/H)^{H/2}$ (eq. (14)), which ignores the first layer; and a cube-specific count of halfspace dichotomies.
  * *Extension to general $X$.* Only the last ingredient uses the cube. On any $m\ge d+1$ points of $\mathbb R^d$, affine halfspaces induce at most $(em/(d+1))^{d+1}$ sign vectors (Sauer–Shelah). Also $\tanh(s)=\mathbb E_T\,\mathrm{sign}(s-T)$ when $T$ has CDF $(1+\tanh t)/2$, so affine-tanh features lie in the closed convex hull of those sign vectors. Massart's lemma then gives the same bound on any $X$ with
    $$D'_{d,H}(m)=\sqrt{2(d+1)\log\frac{em}{d+1}}+\frac{H-1}2 .$$
  * *Consequence for Claim B, with clipped predictions.* Let $G=(CB+1)^2\ge(\lVert g\rVert_\infty+1)^2$ and $K=E_\star+1+nG/c$. With probability at least $1-2\delta$, every $w$ with $F_c(w)\le\min F_c+1$ satisfies
    $$L_D(\bar z_w)\le L_D(g)+\frac{c(E_\star+1)}n+\frac{8D'_{d,H}(n)}{\sqrt n}\Bigl(\frac KH\Bigr)^{H/2}+(4+G)\sqrt{\frac{\log(1/\delta)}{2n}} .$$
    *Proof sketch.* The clone has $\kappa_N\le E_\star$ (eq. `teacher-energy`). This gives $\kappa_N(w)\le K$ and $\hat L_S(z_w)\le\hat L_S(g)+c(E_\star+1)/n$. Next, $\hat L_S(\bar z_w)\le\hat L_S(z_w)$. For the uniform deviation over $\{\kappa_N\le K\}$ of the clipped loss (range $[0,4]$), combine symmetrization, contraction ($p\mapsto(\mathrm{clip}\,p-y)^2$ is 4-Lipschitz) and McDiarmid. Finally, Hoeffding bounds $\hat L_S(g)$ around $L_D(g)$.
  * *Thresholds.* With $c=n^{1-\theta}$ the right side tends to $L_D(g)$ if and only if $\theta<1/H$. Uniform convergence therefore works for $c\gg n^{1-1/H}\,\mathrm{polylog}\,n$. This matches Claim A's memorization condition $cK_{\rm mem}(n)=o(n)$, i.e. $c\ll n^{1-1/H}d^{-1/H}$ (noisy-interpolation eq. (10)), in the exponent. It would replace $\theta_L=1/(4(L-1))$ by any $\theta<1/(L-1)$. Constants and polylog factors at the boundary remain to be written out.

---

## 2. How the references were verified, and the limits of that verification

* All metadata were checked on 11 November 2026 with the WebSearch tool, against result listings that displayed the title, authors and venue. Those listings came from publisher pages, PMLR, NeurIPS/NIPS proceedings, JMLR, Project Euclid, Springer, PNAS/PMC, IEEE-record mirrors, arXiv listings as indexed by the search engine, mlanthology, RePEc and MaRDI.
* WebFetch could not open `arxiv.org` or `dblp.org` (host not allowed in this session), and the proxy blocks `export.arxiv.org` and `api.crossref.org` (HTTP 403). As a result, **no full text was opened.** Content descriptions are at the level of abstracts and listings, and no theorem numbers from the external papers are cited. Every mathematical statement used is proved in Section 1 or taken from the repo with path and label.
* **Tags.**
  * **[V]** verified: every bibliographic field given was displayed by at least one primary or indexing listing. Page ranges and DOIs appear only where a listing displayed them.
  * **[V-repo]** verified in `NNG/main-results/strong-prior-generalization/verification/bibliography-check.txt` (15 October 2026).
  * **[P]** partially verified; the unconfirmed field is named.
* **Discrepancies found.**
  * Vovk (1990): the first page is listed as 371 by Royal Holloway and as 372 by one later citation.
  * Mallinar et al.: the NeurIPS title is "…: Toward a Refined Taxonomy of Overfitting", while arXiv says "…: A Taxonomy of Overfitting".
  * Lee–Bartlett–Williamson (1998) has a 2008 correction to Lemma 5.
  * Pitas–Arbel is dated 2023 by arXiv and mlanthology but 2024 by PMLR (ACML 2023 proceedings).
  * Mei–Montanari appeared online in 2021 in volume 75 (2022).
  * Joshi–Vardi–Srebro: squared loss is the *catastrophic* case, not the tempered one.

---

## 3. References

### A. Exp-concave aggregation, mixability, progressive mixtures

**A1. V. G. Vovk (1990).** Aggregating strategies. *Proc. 3rd Annual Workshop on Computational Learning Theory (COLT '90)*, Morgan Kaufmann, pp. 371–383. [Royal Holloway record](https://pure.royalholloway.ac.uk/en/publications/aggregating-strategies/). **[V]** (first page given as 372 by one later source)
- (a) Introduces the aggregating algorithm: exponential weights plus a substitution rule, whose loss exceeds the best strategy's by at most $\eta^{-1}\log(1/\text{prior weight})$ for mixable losses. With the prior mass of the repo's teacher tube as the prior weight, this is the online core of Claim C (Corollary 2), and Section 1.5(iv) shows the same term for SP$_c$ equals Claim B's empirical slack.
- (b) Indirect: aggregation guarantees need a bounded learning rate (Fact 1), whereas SP$_c$'s likelihood has inverse temperature $1/(2c\sigma^2)\to\infty$, so this theory does not reach the cold limit in which Claim A's interpolation happens.

**A2. V. Vovk (2001).** Competitive on-line statistics. *International Statistical Review* 69(2):213–248. [RePEc](https://ideas.repec.org/a/bla/istatr/v69y2001i2p213-248.html). **[V]**
- (a) A survey of competitive on-line prediction without stochastic assumptions (aggregating algorithm, on-line regression, links to Bayes rule and prequential statistics), and the reference for the square-loss mixability constant in Fact 1's remark; that constant was recalled and checked numerically, not read from the text.
- (b) Not directly relevant.

**A3. D. Haussler, J. Kivinen, M. K. Warmuth (1998).** Sequential prediction of individual sequences under general loss functions. *IEEE Trans. Inf. Theory* 44(5):1906–1925. DOI [10.1109/18.705569](https://doi.org/10.1109/18.705569). **[V]**
- (a) For finite comparison classes the minimax regret is $\Theta(\log N)$ or $\Theta(\sqrt{\ell\log N})$ depending on the loss; squared loss is in the logarithmic (mixable) class, which is why Claim C's complexity term enters at rate $1/n$ rather than $1/\sqrt n$.
- (b) Not directly relevant.

**A4. J. Kivinen, M. K. Warmuth (1999).** Averaging expert predictions. *EuroCOLT '99*, LNCS 1572, Springer, pp. 153–167. DOI [10.1007/3-540-49097-3_13](https://doi.org/10.1007/3-540-49097-3_13). **[V]**
- (a) Predicting with the weighted average of the experts (the posterior mean, instead of Vovk's nonlinear substitution) still costs only $c\ln n$ extra loss for a broad class of losses; this exp-concavity mechanism (Fact 1) is what lets Claim C use the Bayesian model average.
- (b) Not directly relevant.

**A5. Y. Yang (2000).** Mixing strategies for density estimation. *Ann. Statist.* 28(1):75–87. DOI [10.1214/aos/1016120365](https://doi.org/10.1214/aos/1016120365). **[V]**
- (a) Combines a countable collection of estimation strategies into one estimator that is risk-adaptive in KL and squared $L^2$; it is one origin of model-selection aggregation by mixing, which Fact 2 instantiates for network priors.
- (b) Not directly relevant.

**A6. O. Catoni (2004).** *Statistical Learning Theory and Stochastic Optimization.* École d'Été de Probabilités de Saint-Flour XXXI–2001, Lecture Notes in Mathematics 1851, Springer. DOI [10.1007/b99352](https://doi.org/10.1007/b99352). **[V]**
- (a) Non-asymptotic risk bounds with relative entropy as the complexity and Gibbs measures as estimators: the framework in which tempered posteriors with a KL-to-prior complexity (Facts 2–3) are analysed.
- (b) Not directly relevant.

**A7. A. Juditsky, P. Rigollet, A. B. Tsybakov (2008).** Learning by mirror averaging. *Ann. Statist.* 36(5):2183–2206. DOI [10.1214/07-AOS546](https://doi.org/10.1214/07-AOS546); [arXiv:math/0511468](https://arxiv.org/abs/math/0511468). **[V]**
- (a) A recursive mirror-averaging aggregate satisfies sharp oracle inequalities (best dictionary risk plus a $\log M/n$-type term) for regression, classification and density estimation; this is the finite-dictionary form of Fact 2, and replacing the uniform weight by the network prior turns $\log M$ into $\log(1/\mu(U_\rho))\le A_LN^\gamma$.
- (b) Through Corollary 2, remark (iv), the same bound shows that FIX$_\eta$'s progressive mixture does not suffer Claim A's atom excess at polynomial width.

**A8. J.-Y. Audibert (2007).** Progressive mixture rules are deviation suboptimal. *Advances in NIPS 20*, pp. 41–48. [Proceedings page](https://proceedings.neurips.cc/paper/2007/hash/ef575e8837d065a1683c022d2077d342-Abstract.html). **[V]**
- (a) The progressive mixture achieves $\log\lvert G\rvert/n$ in expectation, but for some reference sets its deviations are of order $1/\sqrt n$, and a different algorithm is optimal in both senses; so Corollary 2 is an in-expectation statement, and a high-probability version needs a different predictor or a slower rate (Fact 3).
- (b) Not directly relevant.

**A9. J.-Y. Audibert (2009).** Fast learning rates in statistical inference through aggregation. *Ann. Statist.* 37(4):1591–1646. DOI [10.1214/08-AOS623](https://doi.org/10.1214/08-AOS623); [arXiv:math/0703854](https://arxiv.org/abs/math/0703854). **[V]**
- (a) Minimax rates $C(\log\lvert G\rvert/n)^v$ for aggregation, where $v$ depends on the convexity of the loss and the noise level, proved via a sequential randomized Gibbs-based algorithm with Assouad-type lower bounds; the lower bounds show the $\log(\cdot)/n$ form of Claim C's complexity term cannot be improved in general.
- (b) Not directly relevant.

**A10. A. B. Tsybakov (2003).** Optimal rates of aggregation. *COLT 2003*, LNCS 2777, Springer, pp. 303–313. DOI [10.1007/978-3-540-45167-9_23](https://doi.org/10.1007/978-3-540-45167-9_23). **[V]**
- (a) Defines optimal rates for model-selection, convex and linear aggregation under squared risk, with matching lower bounds; the $\log M/n$ lower bound shows that the $\mathrm{KL}/(\eta n)$ term of Fact 2 has the right order.
- (b) Not directly relevant.

**A11. N. Cesa-Bianchi, G. Lugosi (2006).** *Prediction, Learning, and Games.* Cambridge University Press, ISBN 978-0-521-84108-5. **[V]** (table of contents: §3.3 "Exp-concave loss functions", p. 45)
- (a) Textbook account of exponentially weighted forecasters, including regret $\ln N/\eta$ for $\eta$-exp-concave losses (§3.3), which is steps 1–3 of Fact 2.
- (b) Not directly relevant.

**A12. N. Cesa-Bianchi, A. Conconi, C. Gentile (2004).** On the generalization ability of on-line learning algorithms. *IEEE Trans. Inf. Theory* 50(9):2050–2057. DOI [10.1109/TIT.2004.833339](https://doi.org/10.1109/TIT.2004.833339). **[V]**
- (a) Online-to-batch conversion: a low-risk hypothesis with data-dependent bounds is extracted from any on-line learner run on iid data; this is steps 4–5 of Fact 2 and a route to martingale-based high-probability versions.
- (b) Not directly relevant.

**A13. A. S. Dalalyan, A. B. Tsybakov (2008).** Aggregation by exponential weighting, sharp PAC-Bayesian bounds and sparsity. *Machine Learning* 72:39–61. DOI [10.1007/s10994-008-5051-0](https://doi.org/10.1007/s10994-008-5051-0); [arXiv:0803.2839](https://arxiv.org/abs/0803.2839). **[V]**
- (a) PAC-Bayesian risk bounds for the exponentially weighted aggregate (a tempered posterior mean, without progressive averaging) under squared loss with deterministic design and general noise, plus sparsity oracle inequalities; it is a fixed-design analogue of Claim C for the plain Bayesian model average.
- (b) Not directly relevant.

**A14. G. Lecué, S. Mendelson (2013).** On the optimality of the aggregate with exponential weights for low temperatures. *Bernoulli* 19(2):646–675. DOI [10.3150/11-BEJ408](https://doi.org/10.3150/11-BEJ408); [arXiv:1303.5180](https://arxiv.org/abs/1303.5180). **[V]**
- (a) In random-design regression, the non-progressive exponential-weights aggregate is suboptimal in expectation at low temperature ($T\le c_1$) and suboptimal in probability even at high temperature; cold posterior means (SP$_c$ as $\sigma\to0$) therefore carry no aggregation guarantee, and Claim C should keep the progressive average.
- (b) Not directly relevant.

**A15. M. M. Høgsgaard, P. Rebeschini, T. Wegel (2026).** Aggregation with exponential weights is optimal in expectation. [arXiv:2607.02247](https://arxiv.org/abs/2607.02247). **[P]** (title, first author and date confirmed via the arXiv listing as indexed; the two co-authors come from a mirror listing; the exact temperature condition was not checked)
- (a) Reports that at a sufficiently large constant temperature $T$ the exponential-weights aggregate attains excess risk $T\log M/(n+1)$ in expectation under random design without a Bernstein assumption; if this extends from finite dictionaries to general priors (not checked), Claim C would hold for the ordinary tempered Bayesian model average after $n$ samples.
- (b) Not directly relevant.

**A16. T. van Erven, P. D. Grünwald, N. A. Mehta, M. D. Reid, R. C. Williamson (2015).** Fast rates in statistical and online learning. *JMLR* 16(54):1793–1861. [JMLR page](https://jmlr.org/papers/v16/vanerven15a.html); [arXiv:1507.02592](https://arxiv.org/abs/1507.02592). **[V]**
- (a) Unifies fast-rate conditions as the central condition (for proper learners) and stochastic mixability (for improper learners), the latter generalizing stochastic exp-concavity and Vovk mixability; this is the vocabulary for which $\eta$ makes FIX$_\eta$ safe and for why a single posterior draw (a proper learner) needs more than exp-concavity.
- (b) Not directly relevant.

**A17. W. S. Lee, P. L. Bartlett, R. C. Williamson (1998).** The importance of convexity in learning with squared loss. *IEEE Trans. Inf. Theory* 44(5):1974–1980. DOI [10.1109/18.705577](https://doi.org/10.1109/18.705577). Correction: *IEEE Trans. Inf. Theory* 54(9):4395 (2008), which repairs Lemma 5 by adding "finite dimensional". **[V]**
- (a) If a class has a non-convex closure, agnostic squared-loss learning with hypotheses from the class needs $\Omega(\log(1/\delta)/\varepsilon^2)$ samples, while the convex hull costs about $1/\varepsilon$; proper predictors (one posterior draw or one near-minimizer) thus have $1/\varepsilon^2$ rates in general, which affects exponents in Claims B and C but not polynomiality.
- (b) Not directly relevant.

**A18. S. Mendelson (2008).** Lower bounds for the empirical minimization algorithm. *IEEE Trans. Inf. Theory* 54(8):3797ff. DOI [10.1109/TIT.2008.926323](https://doi.org/10.1109/TIT.2008.926323). **[V]**
- (a) A lower bound on the uniform error rate of empirical minimization under mild geometric assumptions; it applies to Claim B's penalized-ERM near-minimizers and limits their dependence on $\varepsilon$, not their polynomiality.
- (b) Not directly relevant.

### B. Gibbs posteriors, PAC-Bayes, tempered and fractional posteriors

**B1. D. A. McAllester (1999).** Some PAC-Bayesian theorems. *Machine Learning* 37:355–363. DOI [10.1023/A:1007618624809](https://doi.org/10.1023/A:1007618624809). **[V]**
- (a) The first PAC-Bayes theorems, giving PAC guarantees for Bayesian-style algorithms with an arbitrary prior on an arbitrary concept space; they are the ancestor of Fact 3.
- (b) Through Fact 3(iv), the PAC-Bayes inequality implies that a posterior fitting noisy labels to empirical risk $r<\mathbb E\,\mathrm{Var}(y\mid x)$ has KL to a data-independent prior of at least $n(v_0-r)^2/8-\log(1/\delta)$, so interpolating noise costs prior mass $e^{-\Omega(n)}$.

**B2. O. Catoni (2007).** *PAC-Bayesian Supervised Classification: The Thermodynamics of Statistical Learning.* IMS Lecture Notes–Monograph Series 56. [arXiv:0712.0248](https://arxiv.org/abs/0712.0248). **[V]**
- (a) PAC-Bayes theory for Gibbs posteriors with the inverse temperature as the central parameter, including localization (credited in Alquier 2024); it is the toolkit for high-probability Gibbs analogues of Claim C (Fact 3) and for data-driven temperature choice.
- (b) Classification with 0–1 loss only; the same contrapositive as B1 applies.

**B3. T. Zhang (2006).** Information-theoretic upper and lower bounds for statistical estimation. *IEEE Trans. Inf. Theory* 52(4):1307–1321. DOI [10.1109/TIT.2005.864439](https://doi.org/10.1109/TIT.2005.864439). **[V]**
- (a) Upper bounds for a general randomized estimation method from an "information exponential inequality", with lower bounds roughly matching for several problems; the upper bounds have the prior-mass (resolvability) form that the repo's tube estimate (Proposition `tube`) feeds directly, giving width-dependent ($N^\gamma$) rates as in Corollary 2.
- (b) Not directly relevant.

**B4. P. Alquier (2024).** User-friendly introduction to PAC-Bayes bounds. *Foundations and Trends in Machine Learning* 17(2):174–303. DOI [10.1561/2200000100](https://doi.org/10.1561/2200000100); [arXiv:2110.11216](https://arxiv.org/abs/2110.11216). **[V]**
- (a) The standard reference for the Catoni-type bound (Hoeffding plus Donsker–Varadhan, with the Gibbs posterior minimizing the bound), for localization, and for PAC-Bayes oracle inequalities and fast rates of aggregated and randomized predictors; Fact 3 is a direct instance with clipped squared loss in $[0,4]$ and the teacher-tube posterior as comparator.
- (b) The same bound yields Fact 3(iv), the KL cost of interpolating noise.

**B5. P. Germain, F. Bach, A. Lacoste, S. Lacoste-Julien (2016).** PAC-Bayesian theory meets Bayesian inference. *NIPS 29.* [Proceedings](https://papers.nips.cc/paper_files/paper/2016/hash/84d2004bf28a2095230e8e14993d398d-Abstract.html); [arXiv:1605.08636](https://arxiv.org/abs/1605.08636). **[V]**
- (a) For negative log-likelihood loss, minimizing the PAC-Bayes bound is maximizing the marginal likelihood, so the ordinary posterior is a Gibbs posterior whose temperature is fixed by the likelihood; for SP$_c$ this per-sample inverse temperature is $1/(2c\sigma^2)$ on squared loss, the opposite of the $\lambda/n=\sqrt{N^\gamma/n}\to0$ that Fact 3 uses.
- (b) Not directly relevant.

**B6. G. K. Dziugaite, D. M. Roy (2017).** Computing nonvacuous generalization bounds for deep (stochastic) neural networks with many more parameters than training data. *UAI 2017.* [arXiv:1703.11008](https://arxiv.org/abs/1703.11008). **[V]**
- (a) Optimizing a PAC-Bayes bound over Gaussian posteriors gives nonvacuous bounds for MNIST networks with millions of parameters; this is empirical evidence that a KL-to-Gaussian-prior complexity, the quantity the repo's tube mass bounds, can be far below the parameter count.
- (b) Not directly relevant.

**B7. A. Bhattacharya, D. Pati, Y. Yang (2019).** Bayesian fractional posteriors. *Ann. Statist.* 47(1):39–66. DOI [10.1214/18-AOS1712](https://doi.org/10.1214/18-AOS1712); [arXiv:1611.01125](https://arxiv.org/abs/1611.01125). **[V]**
- (a) Fractional posteriors (likelihood raised to $\alpha<1$) contract under a prior-mass condition on KL neighbourhoods alone, with no tests or sieves, and satisfy a PAC-Bayes-based oracle inequality under misspecification; this is the closest classical tempered-Bayes analogue of using Proposition `tube` without the energy cover, but its loss is a Rényi-type divergence and the repo's mass cost $A_LN^\gamma$ makes it width-dependent.
- (b) Not directly relevant.

**B8. P. Alquier, J. Ridgway (2020).** Concentration of tempered posteriors and of their variational approximations. *Ann. Statist.* 48(3):1475–1497. DOI [10.1214/19-AOS1855](https://doi.org/10.1214/19-AOS1855); [arXiv:1706.09293](https://arxiv.org/abs/1706.09293). **[V]**
- (a) Oracle inequalities for tempered ($\alpha<1$) posteriors and their variational approximations under prior-mass-type conditions; relevant if a computable (variational) FIX$_\eta$ is wanted, with the same width-dependent mass caveat.
- (b) Not directly relevant.

**B9. P. G. Bissiri, C. C. Holmes, S. G. Walker (2016).** A general framework for updating belief distributions. *J. R. Stat. Soc. B* 78(5):1103–1130. DOI [10.1111/rssb.12158](https://doi.org/10.1111/rssb.12158); [arXiv:1306.6430](https://arxiv.org/abs/1306.6430). **[V]**
- (a) A decision-theoretic justification of loss-based posteriors $\pi(w)e^{-\eta\sum\text{loss}}$ without a full likelihood, reducing to Bayes when the likelihood is known; it gives FIX$_\eta$ its status as a "general Bayesian" update and $\eta$ its status as a calibration parameter.
- (b) Not directly relevant.

**B10. X. Zhu, N. Srebro (2025).** Quantifying overfitting along the regularization path for two-part-code MDL in supervised classification. *COLT 2025*, PMLR 291:6124–6155. [PMLR](https://proceedings.mlr.press/v291/zhu25a.html); [arXiv:2503.02110](https://arxiv.org/abs/2503.02110). **[V]**
- (a) For a modified two-part-code MDL rule with arbitrary prior and penalty weight $\lambda$, it gives the full regularization curve, tightening Grünwald–Langford's $\lambda=1$ inconsistency and covering every $\lambda$; it is the discrete-prior classification precursor of the $c$-dichotomy in Claims A and B.
- (b) The failure of the $\lambda=1$ (Bayes/MDL) rule to be agnostically consistent with noisy labels is the classification analogue of Claim A at $c=1$.

**B11. X. Zhu, M. I. Ohannessian, N. Srebro (2026).** Overfitting and generalizing with (PAC) Bayesian prediction in noisy binary classification. [arXiv:2603.22644](https://arxiv.org/abs/2603.22644). **[V]**
- (a) For a PAC-Bayes rule that balances training error against KL to a continuous prior with weight $\lambda$, $\lambda=1$ recovers an (empirical) Bayes posterior that overfits with non-vanishing agnostic excess, finite $\lambda$ gives tempered inconsistency, and $1\ll\lambda\ll m/\log m$ is agnostically consistent; this is the closest published analogue of Claims A, B and D (with $\lambda\leftrightarrow c$ and $m\leftrightarrow n$), and it has no neural or squared-loss version.
- (b) Their finite-$\lambda$ tempered inconsistency is the counterpart of Claim A's constant excess at $c=O(1)$; in their setting any $\lambda\to\infty$ blocks memorization because memorizing costs $\Theta(m)$ description length, whereas for deep tanh networks memorizing $n$ labels costs only energy $O(d^4+(dn)^{1/H})$ (the brief's $K_{\rm mem}$, from noisy-interpolation eq. (10)), so $c$ must be much larger than $n^{1-1/H}$ (Section 1.6(iii)).

### C. Misspecified Bayes and SafeBayes

**C1. B. J. K. Kleijn, A. W. van der Vaart (2006).** Misspecification in infinite-dimensional Bayesian statistics. *Ann. Statist.* 34(2):837–877. DOI [10.1214/009053606000000029](https://doi.org/10.1214/009053606000000029); [arXiv:math/0607023](https://arxiv.org/abs/math/0607023). **[V]**
- (a) Under misspecification the posterior concentrates near the KL-projection of the truth onto the model, at rates set by entropy and prior-mass conditions; for a fixed-variance Gaussian likelihood the KL-projection is the $L^2(D)$-risk minimizer over the network class, which is the oracle in the brief's inequality (their conditions were not checked for network posteriors).
- (b) Not directly relevant.

**C2. P. Grünwald, J. Langford (2007).** Suboptimal behavior of Bayes and MDL in classification under misspecification. *Machine Learning* 66:119–149. DOI [10.1007/s10994-007-0716-7](https://doi.org/10.1007/s10994-007-0716-7); [arXiv:math/0406221](https://arxiv.org/abs/math/0406221). **[V]**
- (a) Bayes and MDL classifiers built from logistic-transformed models can be inconsistent under misspecification, with error bounded away from the best achievable; this is the original warning that the $\beta=1$ posterior need not satisfy an agnostic oracle inequality.
- (b) Their failure mode, in which the posterior does not converge to the KL-closest model under misspecification, is the classification precursor of Claim A, where the too-small assumed noise variance $c\sigma^2$ drives the posterior to atom-fitting networks.

**C3. P. Grünwald (2012).** The safe Bayesian: learning the learning rate via the mixability gap. *ALT 2012*, LNAI 7568, Springer, pp. 169–183. DOI [10.1007/978-3-642-34106-9_16](https://doi.org/10.1007/978-3-642-34106-9_16). **[V]**
- (a) Chooses the likelihood exponent from data by minimizing cumulative sequential loss, with the mixability gap as diagnostic; this is a principled way to choose FIX$_\eta$'s $\eta$ or SP$_c$'s ratio $c$ instead of fixing $c=1$.
- (b) Not directly relevant.

**C4. P. Grünwald, T. van Ommen (2017).** Inconsistency of Bayesian inference for misspecified linear models, and a proposal for repairing it. *Bayesian Analysis* 12(4):1069–1103. DOI [10.1214/17-BA1085](https://doi.org/10.1214/17-BA1085); [arXiv:1412.3730](https://arxiv.org/abs/1412.3730). **[V]**
- (a) Standard Bayes ($\eta=1$), both model averaging/selection and Bayesian ridge, is inconsistent for a misspecified (heteroskedastic) linear model, and SafeBayes with a learned $\eta$ repairs it; this is the regression analogue of the brief's point that the likelihood weight must be tuned ($c\gg1$ in Claim B).
- (b) The posterior puts mass on ever higher-dimensional models as $n$ grows, the linear-model counterpart of Claim A's memorization of atom noise.

**C5. P. D. Grünwald, N. A. Mehta (2020).** Fast rates for general unbounded loss functions: from ERM to generalized Bayes. *JMLR* 21(56):1–80. [JMLR page](https://jmlr.org/papers/v21/18-488.html); [arXiv:1605.00252](https://arxiv.org/abs/1605.00252). **[V]**
- (a) Excess-risk bounds for $\eta$-generalized Bayes, MDL and ERM with unbounded losses (including squared loss) under v-GRIP and witness conditions, with $\tilde O(1/n)$ rates in favourable cases; this is the general theory FIX$_\eta$ belongs to, and it could replace output clipping in Corollary 2.
- (b) Not directly relevant.

### D. Power, tempered and cold posteriors in Bayesian deep learning

**D1. F. Wenzel, K. Roth, B. S. Veeling, J. Świątkowski, L. Tran, S. Mandt, J. Snoek, T. Salimans, R. Jenatton, S. Nowozin (2020).** How good is the Bayes posterior in deep neural networks really? *ICML 2020*, PMLR 119:10248–10259. [PMLR](https://proceedings.mlr.press/v119/wenzel20a.html); [arXiv:2002.02405](https://arxiv.org/abs/2002.02405). **[V]** (title, venue, pages and the first four authors were displayed by the listings; the remaining six names are from my record, and a search on all ten names returned this paper)
- (a) With careful MCMC, the $T=1$ posterior predictive of Bayesian neural networks is worse than SGD point estimates and cold posteriors ($T<1$) help; by Section 1.5(i), SP$_c$ at scale $\sigma$ is exactly the cold posterior of the $\sigma=1$ model at $T=\sigma^2$, so the strong-prior limit is the $T\to0$ end of this family.
- (b) Their benchmarks are curated, augmented image data with little label noise; Claim A predicts that the $T\to0$ limit at fixed $c$ becomes harmful when labels are noisy (compare D2).

**D2. L. Aitchison (2021).** A statistical theory of cold posteriors in deep neural networks. *ICLR 2021.* [arXiv:2008.05912](https://arxiv.org/abs/2008.05912). **[V]**
- (a) Explains cold posteriors by dataset curation (consensus labelling makes the correct likelihood resemble a tempered one) and notes that tempered and cold posteriors differ only by prior scaling, which a Gaussian prior's variance absorbs; this supports reading SP$_c$, with prior and likelihood scaled together, as an ordinary Bayesian model with observation variance $c\sigma^2$.
- (b) On CIFAR-10H the cold-posterior effect largely disappears with multi-annotator labels, and as label noise increases it disappears and then reverses; this is the empirical counterpart of Claim A's prediction that cold, near-interpolating posteriors are harmful under label noise.

**D3. P. Izmailov, S. Vikram, M. D. Hoffman, A. G. Wilson (2021).** What are Bayesian neural network posteriors really like? *ICML 2021*, PMLR 139:4629–4640. [PMLR](https://proceedings.mlr.press/v139/izmailov21a.html); [arXiv:2104.14421](https://arxiv.org/abs/2104.14421). **[V]**
- (a) With full-batch HMC, Bayesian neural networks can outperform standard training and deep ensembles, tempering is not needed for near-optimal performance, the cold-posterior effect is largely an artifact of data augmentation, and Bayesian model averaging is fairly robust to the prior; this supports untempered or mildly tempered (FIX$_\eta$-type) posteriors as the practically relevant learners.
- (b) Not directly relevant.

**D4. A. G. Wilson, P. Izmailov (2020).** Bayesian deep learning and a probabilistic perspective of generalization. *NeurIPS 2020.* [arXiv:2002.08791](https://arxiv.org/abs/2002.08791). **[V]**
- (a) Argues that generalization depends on support and inductive biases rather than parameter counts, and reports that Bayesian model averaging (MultiSWAG) alleviates double descent, with monotone improvement as flexibility grows; this is an empirical counterpart of Claim C.
- (b) In Claim A all near-minimizers fit the same atom means, so their average inherits the full excess; Bayesian model averaging helps only when the posterior spreads over predictors that disagree on the noise.

**D5. K. Pitas, J. Arbel (2023).** The fine print on tempered posteriors. *ACML 2023*, PMLR 222:1087–1102 (PMLR dates the volume 2024). [PMLR](https://proceedings.mlr.press/v222/pitas24a.html); [arXiv:2309.05292](https://arxiv.org/abs/2309.05292). **[V]**
- (a) A PAC-Bayes (Catoni-bound) analysis of tempered Bayesian neural network posteriors concluding that the temperature cannot be read as merely fixing a misspecified prior or likelihood, and that gains in some metrics can cost test accuracy; this is consistent with treating $c$ and $\eta$ as learning-rate parameters tuned for risk (Facts 2–3).
- (b) Not directly relevant.

### E. Structural risk minimization and penalized least squares

**E1. V. N. Vapnik (1998).** *Statistical Learning Theory.* Wiley, ISBN 978-0-471-03003-4. **[V]**
- (a) Structural risk minimization (empirical risk plus the capacity of a nested structure); the $\sigma\to0$ SP$_c$ learner is its Tikhonov form over energy sublevel sets (Section 1.5(ii)), and Claim B is an SRM oracle inequality that holds only when the penalty $c\,\kappa_N/n$ dominates the capacity of the selected sublevel set.
- (b) With $c$ fixed the penalty is $O(1/n)$ per sample and the selected sublevel set has capacity far above $n$, which is the regime of Claim A.

**E2. J. Shawe-Taylor, P. L. Bartlett, R. C. Williamson, M. Anthony (1998).** Structural risk minimization over data-dependent hierarchies. *IEEE Trans. Inf. Theory* 44(5):1926–1940. DOI [10.1109/18.705570](https://doi.org/10.1109/18.705570). **[V]**
- (a) SRM over data-dependent hierarchies ("luckiness"), the right formalism for Claim B's data-dependent energy level, whether by a union bound over energy levels or by a level fixed in advance through $c$ as in Section 1.6(iii).
- (b) Not directly relevant.

**E3. A. R. Barron (1994).** Approximation and estimation bounds for artificial neural networks. *Machine Learning* 14:115–133. DOI [10.1007/BF00993164](https://doi.org/10.1007/BF00993164). **[V]**
- (a) Complexity-regularized least squares for one-hidden-layer sigmoidal networks, with an index-of-resolvability bound (Fourier-based approximation, metric-entropy estimation); it is the classical neural instance of a penalized least-squares oracle inequality, of which Claim B is a depth-$L$, width-uniform, energy-penalized version.
- (b) Not directly relevant.

**E4. W. S. Lee, P. L. Bartlett, R. C. Williamson (1996).** Efficient agnostic learning of neural networks with bounded fan-in. *IEEE Trans. Inf. Theory* 42(6):2118–2132. DOI [10.1109/18.556601](https://doi.org/10.1109/18.556601). **[V]**
- (a) Agnostic learning of two-layer bounded-fan-in networks under quadratic loss relative to the best network in the class, with samples and time polynomial in $1/\varepsilon$, $1/\delta$, input dimension and output-weight bound (time exponential in fan-in); it is an early agnostic squared-loss oracle inequality for networks, achieved by ERM-type rather than Bayesian learners.
- (b) Not directly relevant.

**E5. A. Barron, L. Birgé, P. Massart (1999).** Risk bounds for model selection via penalization. *Probab. Theory Relat. Fields* 113(3):301–413. DOI [10.1007/s004400050210](https://doi.org/10.1007/s004400050210). **[V]**
- (a) Risk bounds for penalized model selection (least squares, maximum likelihood, projection estimators) with penalties of order model dimension over $n$, giving adaptive oracle inequalities over countable model families; this is the template for choosing $c$ so that $c\,\kappa_N/n$ dominates stochastic complexity.
- (b) Not directly relevant.

**E6. L. Györfi, M. Kohler, A. Krzyżak, H. Walk (2002).** *A Distribution-Free Theory of Nonparametric Regression.* Springer. DOI [10.1007/b97848](https://doi.org/10.1007/b97848). **[V]**
- (a) Distribution-free consistency and rate results for least-squares estimates (including neural networks and RBF networks) and for penalized least squares; it is the reference framework for agnostic $L^2$ guarantees of least-squares-type learners such as Claim B's limit.
- (b) Not directly relevant.

**E7. A. Caponnetto, E. De Vito (2007).** Optimal rates for the regularized least-squares algorithm. *Found. Comput. Math.* 7(3):331–368. DOI [10.1007/s10208-006-0196-8](https://doi.org/10.1007/s10208-006-0196-8). **[V]** (a 2017 arXiv note by D. Sutherland corrects a constant in the proof of Theorem 4; rates are unchanged)
- (a) Minimax-optimal rates for kernel ridge regression with regularization $\lambda_n\to0$ at a polynomial rate; through Section 1.5(iii) this is the kernel analogue of Claim B's schedule $\lambda_n=c/n=n^{-\theta}$.
- (b) The optimal schedules in this theory satisfy $n\lambda_n\to\infty$, i.e. $c\to\infty$, while $c=1$ ($\lambda_n=1/n$) is the near-ridgeless regime of G7–G8.

**E8. M. Anthony, P. L. Bartlett (1999).** *Neural Network Learning: Theoretical Foundations.* Cambridge University Press. DOI [10.1017/CBO9780511624216](https://doi.org/10.1017/CBO9780511624216). **[V]**
- (a) Textbook covering-number and fat-shattering bounds for learning real-valued functions with bounded-weight networks; this is the classical uniform-convergence route of Claim B, which the repo's width-independent energy cover (Proposition `energy-cover`) replaces.
- (b) Not directly relevant.

### F. Norm-based capacity of neural networks

**F1. P. L. Bartlett (1998).** The sample complexity of pattern classification with neural networks: the size of the weights is more important than the size of the network. *IEEE Trans. Inf. Theory* 44(2):525–536. DOI [10.1109/18.661502](https://doi.org/10.1109/18.661502). **[V] [V-repo]**
- (a) Per-unit $\ell_1$ weight bounds, rather than parameter counts, control the fat-shattering dimension of sigmoid networks, the first width-free capacity bound and applicable to tanh; but $\kappa_N\le K$ bounds per-unit $\ell_1$ norms only up to a factor $\sqrt N$ (a single internal row can carry $\ell_1$ norm $\sqrt{NK}$), so it does not directly give the repo's width-uniform cover.
- (b) Not directly relevant.

**F2. B. Neyshabur, R. Tomioka, N. Srebro (2015).** Norm-based capacity control in neural networks. *COLT 2015*, PMLR 40:1376–1401. [PMLR](https://proceedings.mlr.press/v40/Neyshabur15.html); [arXiv:1503.00036](https://arxiv.org/abs/1503.00036). **[V] [V-repo]**
- (a) For ReLU networks, size-independent norm-based capacity control requires per-unit $\ell_1$ (equivalently path-norm) or overall $\ell_p$ regularization with $p\le2$, with exponential depth dependence unavoidable for some norms; being proved for ReLU, it is only heuristic for tanh, and the repo's path-norm bound (noisy-interpolation eq. (14)) with the clip-mixture identity (13) is the tanh substitute.
- (b) Not directly relevant.

**F3. P. L. Bartlett, D. J. Foster, M. Telgarsky (2017).** Spectrally-normalized margin bounds for neural networks. *NIPS 30.* [Proceedings](https://proceedings.neurips.cc/paper/2017/hash/b22b257ad0519d4500539da3c8bcf4dd-Abstract.html); [arXiv:1706.08498](https://arxiv.org/abs/1706.08498). **[V]** (activation hypotheses not checked against the text)
- (a) A margin bound scaling with the product of spectral norms times a $(2,1)$-norm correction; under $\kappa_N\le K$ the spectral product is at most $(K/L)^{L/2}/\sqrt d$ (Section 1.6(i)), but the correction grows like $\Theta(\sqrt N)$ on balanced clones of a fixed network (Section 1.6(ii)), so it does not give width-uniform energy covers.
- (b) Their experiments show the normalized complexity tracks the difficulty of fitting random labels, a qualitative counterpart of the repo's memorization energy growing with the number of noisy labels (noisy-interpolation eq. (10)).

**F4. B. Neyshabur, S. Bhojanapalli, N. Srebro (2018).** A PAC-Bayesian approach to spectrally-normalized margin bounds for neural networks. *ICLR 2018.* [arXiv:1707.09564](https://arxiv.org/abs/1707.09564). **[V]**
- (a) A PAC-Bayes proof of spectral-times-Frobenius margin bounds for ReLU networks via a Gaussian perturbation posterior with KL to a Gaussian prior; it is structurally parallel to the repo's tube-mass argument (translating a symmetric Gaussian event, `paper.tex` eq. `translation`) but is stated with spectral and Frobenius norms instead of $\kappa_N$.
- (b) Not directly relevant.

**F5. N. Golowich, A. Rakhlin, O. Shamir (2018/2020).** Size-independent sample complexity of neural networks. *COLT 2018*, PMLR 75:297–299 (extended abstract); full version *Information and Inference* 9(2):473–504 (2020), DOI [10.1093/imaiai/iaz007](https://doi.org/10.1093/imaiai/iaz007); [arXiv:1712.06541](https://arxiv.org/abs/1712.06541). **[V]** (journal metadata **[V-repo]**)
- (a) Frobenius-norm Rademacher bounds with $\sqrt{\text{depth}}$ dependence, and fully size-independent bounds under extra assumptions, for 1-Lipschitz positively homogeneous activations; the Frobenius product is cloning-invariant and at most $(K/L)^{L/2}/\sqrt d$ under $\kappa_N\le K$, and the repo's noisy-interpolation Section 4 supplies a tanh analogue of order $(K/H)^{H/2}/\sqrt m$ that would place Claim D's uniform-convergence threshold at $c\asymp n^{1-1/H}$ (Section 1.6(iii)).
- (b) Not directly relevant.

### G. Benign, tempered and catastrophic overfitting; double descent; interpolation

**G1. T. M. Cover (1968).** Estimation by the nearest neighbor rule. *IEEE Trans. Inf. Theory* 14(1):50–55. DOI [10.1109/TIT.1968.1054098](https://doi.org/10.1109/TIT.1968.1054098). **[V]**
- (a) Not directly relevant.
- (b) Under squared-error loss the 1-NN rule has large-sample risk exactly $2R^*$ and the $k$-NN average has $R^*(1+1/k)$; Claim A's bound $1+\mathbb E[1/K;K\ge1]$ is this formula with $R^*=1$ averaged over the count $K$ of training copies of the test atom (1.484829 at $n=2^d$, maximal value 1.517351 at $n\approx1.503\cdot2^d$).

**G2. C. Zhang, S. Bengio, M. Hardt, B. Recht, O. Vinyals (2017).** Understanding deep learning requires rethinking generalization. *ICLR 2017.* [arXiv:1611.03530](https://arxiv.org/abs/1611.03530). **[V]**
- (a) Standard networks fit random labels, so class-capacity bounds cannot explain generalization; a data- or posterior-dependent complexity is needed, such as the energy of the selected network or the KL to the prior, as in the repo's bounds and Claim B.
- (b) When networks interpolate, generalization degrades steadily as label noise increases, the empirical phenomenon Claims A and A$'$ formalize for the strong-prior posterior.

**G3. M. Belkin, D. Hsu, P. Mitra (2018).** Overfitting or perfect fitting? Risk bounds for classification and regression rules that interpolate. *NeurIPS 31*, pp. 2300–2311. [Proceedings](https://papers.nips.cc/paper/2018/hash/e22312179bf43e61576081a2f250f845-Abstract.html); [arXiv:1806.05161](https://arxiv.org/abs/1806.05161). **[V]**
- (a) Not directly relevant.
- (b) Interpolating schemes (simplicial interpolation, singularly weighted $k$-NN) can be consistent or nearly so despite label noise, so interpolation is not fatal in itself; on finite domains with repeated atoms, conflicting labels cannot be interpolated, the best atom-wise fit is the average, and its risk is Cover's $R^*(1+1/k)$, which is Claim A.

**G4. M. Belkin, D. Hsu, S. Ma, S. Mandal (2019).** Reconciling modern machine-learning practice and the classical bias–variance trade-off. *PNAS* 116(32):15849–15854. DOI [10.1073/pnas.1903070116](https://doi.org/10.1073/pnas.1903070116); [arXiv:1812.11118](https://arxiv.org/abs/1812.11118). **[V]**
- (a) Double descent: increasing capacity beyond the interpolation point can improve test error; this is consistent with the repo's width-uniform clean-label results but says nothing about agnostic guarantees.
- (b) The peak sits at the interpolation threshold; on a finite domain the relevant threshold is in sample size, $n\asymp\lvert X\rvert$, where Claim A's seen-atom excess $\mathbb E[1/K;K\ge1]$ peaks (about $\lambda$ for $\lambda=n/\lvert X\rvert\ll1$, about $1/\lambda$ for $\lambda\gg1$), and width plays no role once $N\ge N_0$ permits memorization.

**G5. P. Nakkiran, G. Kaplun, Y. Bansal, T. Yang, B. Barak, I. Sutskever (2020).** Deep double descent: where bigger models and more data hurt. *ICLR 2020*; journal version *J. Stat. Mech.* (2021) 124003, DOI [10.1088/1742-5468/ac3a74](https://doi.org/10.1088/1742-5468/ac3a74); [arXiv:1912.02292](https://arxiv.org/abs/1912.02292). **[V]**
- (a) Effective model complexity depends on the training procedure, and more data can hurt; an agnostic oracle inequality must hold for every $n\ge p(\dots)$, and Claim A exhibits a specific bad $n\asymp\lvert X\rvert$.
- (b) The peaks are most pronounced with label noise and also appear as functions of sample size; Claim A is a provable sample-wise analogue for the cold posterior on finite domains, although whether its total excess is non-monotone in $n$ depends on the unseen-atom error at $n\ll\lvert X\rvert$, which Claim A does not determine.

**G6. P. Nakkiran (2019).** More data can hurt for linear regression: sample-wise double descent. [arXiv:1912.07242](https://arxiv.org/abs/1912.07242). **[V]**
- (a) Not directly relevant.
- (b) For min-norm ridgeless regression with isotropic Gaussian covariates, more samples lower bias but raise variance and can increase risk; this is the variance mechanism behind Claim A's seen-atom term, where noise passes through an exact fit.

**G7. T. Liang, A. Rakhlin (2020).** Just interpolate: kernel "ridgeless" regression can generalize. *Ann. Statist.* 48(3):1329–1347. DOI [10.1214/19-AOS1849](https://doi.org/10.1214/19-AOS1849); [arXiv:1808.00387](https://arxiv.org/abs/1808.00387). **[V]**
- (a) Data-dependent bounds for min-norm kernel interpolation, with implicit regularization coming from high input dimension, kernel curvature and eigendecay; this is the analysis relevant to SP$_c$ with $c\to0$ in a linearized regime (Section 1.5(iii)).
- (b) The benign mechanism needs high dimension relative to $n$, and finite domains with $n\gtrsim\lvert X\rvert$ lie outside it.

**G8. A. Rakhlin, X. Zhai (2019).** Consistency of interpolation with Laplace kernels is a high-dimensional phenomenon. *COLT 2019*, PMLR 99:2595–2623. [PMLR](https://proceedings.mlr.press/v99/rakhlin19a.html); [arXiv:1812.11167](https://arxiv.org/abs/1812.11167). **[V]**
- (a) Not directly relevant.
- (b) Min-norm interpolation in the Laplace-kernel RKHS is inconsistent in fixed dimension, a kernel instance of the brief's point that interpolating noisy labels fails when samples are dense in the domain, with finite domains at $n\gtrsim\lvert X\rvert$ as the extreme case.

**G9. P. L. Bartlett, P. M. Long, G. Lugosi, A. Tsigler (2020).** Benign overfitting in linear regression. *PNAS* 117(48):30063–30070. DOI [10.1073/pnas.1907378117](https://doi.org/10.1073/pnas.1907378117); [arXiv:1906.11300](https://arxiv.org/abs/1906.11300). **[V]**
- (a) Not directly relevant.
- (b) Min-norm interpolation is benign only when many low-variance directions (effective rank much larger than $n$) absorb the noise; with inputs on at most about $n$ atoms every feature covariance has rank at most $\lvert X\rvert$, so the mechanism is unavailable, though this is an analogy only because their theorem assumes Gaussian-type features $\Sigma^{1/2}z$.

**G10. T. Hastie, A. Montanari, S. Rosset, R. J. Tibshirani (2022).** Surprises in high-dimensional ridgeless least squares interpolation. *Ann. Statist.* 50(2):949–986. DOI [10.1214/21-AOS2133](https://doi.org/10.1214/21-AOS2133); [arXiv:1903.08560](https://arxiv.org/abs/1903.08560). **[V]**
- (a) Not directly relevant.
- (b) Precise asymptotics of min-norm least squares with $p\asymp n$ reproduce double descent and the benefits of overparametrization; this is the proportional-regime template for SP$_c$'s near-ridgeless ($c=1$) behaviour in a linearized model.

**G11. S. Mei, A. Montanari (2022).** The generalization error of random features regression: precise asymptotics and the double descent curve. *Comm. Pure Appl. Math.* 75(4):667–766. DOI [10.1002/cpa.22008](https://doi.org/10.1002/cpa.22008); [arXiv:1908.05355](https://arxiv.org/abs/1908.05355). **[V]**
- (a) Random-features ridge regression, a two-layer network with random first layer, with exact asymptotic test error reproducing the full double-descent curve without ad hoc misspecification; it is the most tractable network-shaped model in which the ridge (here $c/n$) can be studied exactly.
- (b) The same model at vanishing ridge is the random-features analogue of SP$_c$ with $c\to0$.

**G12. T. Misiakiewicz (2022).** Spectrum of inner-product kernel matrices in the polynomial regime and multiple descent phenomenon in kernel ridge regression. [arXiv:2204.10425](https://arxiv.org/abs/2204.10425). **[V]**
- (a) Not directly relevant.
- (b) For data uniform on the sphere and on the hypercube with $n\asymp d^\ell$, kernel ridge regression can show double descent each time $n$ crosses a polynomial threshold; this is a finite-domain (hypercube) setting with non-monotone risk at polynomial $n$, complementary to Claim A's peak at $n\asymp2^d$.

**G13. G. Wang, K. Donhauser, F. Yang (2022).** Tight bounds for minimum $\ell_1$-norm interpolation of noisy data. *AISTATS 2022*, PMLR 151:10572–10602. [PMLR](https://proceedings.mlr.press/v151/wang22k.html); [arXiv:2111.05987](https://arxiv.org/abs/2111.05987). **[V]**
- (a) Not directly relevant.
- (b) Min-$\ell_1$ interpolation has prediction error of order $\sigma^2/\log(d/n)$ for isotropic features and sparse truths, so it is consistent but accuracy $\varepsilon$ needs $d\ge n\,e^{\Omega(\sigma^2/\varepsilon)}$; an interpolating learner can thus be benign yet have non-polynomial requirements, matching the spirit of Claim A, and the repo's memorizer itself uses a Fourier-$\ell_1$ bound (noisy-interpolation eq. (2)).

**G14. N. Mallinar, J. B. Simon, A. Abedsoltan, P. Pandit, M. Belkin, P. Nakkiran (2022).** Benign, tempered, or catastrophic: toward a refined taxonomy of overfitting. *NeurIPS 35.* [Proceedings](https://proceedings.neurips.cc/paper_files/paper/2022/hash/08342dc6ab69f23167b4123086ad4d38-Abstract.html); [arXiv:2207.06569](https://arxiv.org/abs/2207.06569) (arXiv title "…: A Taxonomy of Overfitting"). **[V]**
- (a) Not directly relevant.
- (b) Their taxonomy classifies the $n\to\infty$ limit at a fixed distribution, which Claim A is not (at fixed $d$ the seen-atom excess vanishes as $n/2^d\to\infty$), but along $n=\lambda2^d$ Claim A gives a constant lower bound $\mathbb E[1/K;K\ge1]\in(0,0.5174]$ on the excess over Bayes risk 1, a tempered profile along a joint scaling; their kernel-ridge trichotomy is the GP-side analogue, and their interpolating deep networks were tempered.

**G15. N. S. Manoj, N. Srebro (2023).** Interpolation learning with minimum description length. [arXiv:2302.07263](https://arxiv.org/abs/2302.07263); COLT 2023 version titled "Shortest program interpolation learning". **[V]**
- (a) The MDL (shortest-program) interpolation rule satisfies only tempered agnostic finite-sample guarantees, which is evidence that an interpolating Occam learner, such as the $c=1$ strong-prior posterior (a minimum-energy rule), satisfies tempered rather than $\varepsilon$-excess oracle inequalities.
- (b) They characterize the asymptotics under random label noise, which are tempered; this is the MDL counterpart of Claim A.

**G16. G. Kornowski, G. Yehudai, O. Shamir (2023).** From tempered to benign overfitting in ReLU neural networks. *NeurIPS 36.* [Proceedings](https://proceedings.neurips.cc/paper_files/paper/2023/hash/b52e8c6c1a798fed53ac2e6a5e23ddc8-Abstract.html); [arXiv:2305.15141](https://arxiv.org/abs/2305.15141) (v3, 2024, fixes a bug). **[V]**
- (a) Not directly relevant.
- (b) For two-layer ReLU classifiers, overfitting is tempered with one-dimensional inputs and benign in high dimension, so the input dimension (how densely samples cover the domain) decides the type; finite domains with $n\gtrsim\lvert X\rvert$ are the dense extreme, where tempered behaviour like Claim A's is expected.

**G17. N. Joshi, G. Vardi, N. Srebro (2024).** Noisy interpolation learning with shallow univariate ReLU networks. *ICLR 2024.* [Proceedings](https://proceedings.iclr.cc/paper_files/paper/2024/hash/91a23b3e6a2ebaad62e17d0269f88c6b-Abstract-Conference.html); [arXiv:2307.15396](https://arxiv.org/abs/2307.15396). **[V]**
- (a) Not directly relevant.
- (b) For min-$\ell_2$-weight-norm univariate two-layer ReLU interpolation of noisy data, overfitting is tempered for $L_p$ with $p<2$ but catastrophic for squared loss or in expectation; since the brief uses MSE, continuous-input variants such as Claim A$'$ must control spikes between nearby noisy points, which the energy–Lipschitz bound (`paper.tex` eq. `energy-lipschitz`) does at a Lipschitz constant polynomial in $n$.

**G18. I. Harel, W. M. Hoza, G. Vardi, I. Evron, N. Srebro, D. Soudry (2024).** Provable tempered overfitting of minimal nets and typical nets. *NeurIPS 37.* DOI [10.52202/079017-1694](https://doi.org/10.52202/079017-1694); [arXiv:2410.19092](https://arxiv.org/abs/2410.19092). **[V]**
- (a) Not directly relevant.
- (b) For deep fully connected binary-weight networks fitted to classify a noisy training set perfectly, both the smallest interpolating network and a random interpolating network (a uniform prior conditioned on interpolation, i.e. a TUBE-type posterior) overfit in a tempered way, making this the closest finite-network analogue of Claim A; their mechanism is the off-sample effect of memorizing noise (compare the $A(d,L,U)\eta$ term of the repo's noisy-interpolation note), whereas Claim A uses on-sample repeated atoms.

**G19. G. Buzaglo, I. Harel, M. Shpigel Nacson, A. Brutzkus, N. Srebro, D. Soudry (2024).** How uniform random weights induce non-uniform bias: typical interpolating neural networks generalize with narrow teachers. *ICML 2024*, PMLR 235:5035–5081. [PMLR](https://proceedings.mlr.press/v235/buzaglo24a.html). **[V-repo]**
- (a) Random networks conditioned on interpolating the data generalize when a narrow teacher exists, a realizable (clean-label) counterpart of the repo's results with no agnostic statement.
- (b) Its noisy-label extension is G18.

**G20. V. Feldman (2019).** Does learning require memorization? A short tale about a long tail. [arXiv:1906.05271](https://arxiv.org/abs/1906.05271). **[P]** (published venue not confirmed in this session)
- (a) Not directly relevant.
- (b) For long-tailed mixtures of subpopulations, memorizing rare examples, including noisy or outlier labels, is necessary for near-optimal accuracy; on finite domains with clean labels memorization at atoms is optimal, so the harm in Claim A comes entirely from the conditional variance of the labels, not from memorization as such.

### H. Bayesian and Gaussian-process analogues of double descent

**H1. P. Sollich (2001).** Gaussian process regression with mismatched models. *NIPS 14*, pp. 519–526. [Proceedings](https://proceedings.neurips.cc/paper/2001/hash/d68a18275455ae3eaa2c291eebb46e6d-Abstract.html); [arXiv:cond-mat/0106475](https://arxiv.org/abs/cond-mat/0106475). **[V]**
- (a) Not directly relevant.
- (b) GP learning curves with mismatched student and teacher show plateaux and arbitrarily many over-fitting maxima in high input dimension, even when the student's noise level is correct; this is a classical Bayesian analogue of sample-wise double descent, and SP$_c$ as $\sigma\to0$ is a student whose assumed noise variance $c\sigma^2$ is far below the true one.

**H2. M. Kanagawa, P. Hennig, D. Sejdinovic, B. K. Sriperumbudur (2018).** Gaussian processes and kernel methods: a review on connections and equivalences. [arXiv:1807.02582](https://arxiv.org/abs/1807.02582). **[V]**
- (a) The GP posterior mean equals the kernel ridge regression estimator with the same kernel (Kimeldorf–Wahba), and the posterior variance is a worst-case KRR error; this is the dictionary behind Section 1.5(iii), where SP$_c$'s posterior mean in a linearized regime is KRR with ridge $c/n$ for every $\sigma$.
- (b) Not directly relevant.

**H3. A. Canatar, B. Bordelon, C. Pehlevan (2021).** Spectral bias and task-model alignment explain generalization in kernel regression and infinitely wide neural networks. *Nature Communications* 12:2914. DOI [10.1038/s41467-021-23103-1](https://doi.org/10.1038/s41467-021-23103-1); [arXiv:2006.13198](https://arxiv.org/abs/2006.13198). **[V]**
- (a) Not directly relevant.
- (b) Replica theory for kernel regression, including the kernels of infinitely wide networks, shows that with noisy labels or targets the kernel cannot express, more data can hurt and learning curves can have many peaks; this is a GP/NNGP analogue of Claim A's sample-wise peak, derived for rotation-invariant kernels with spherical data in high dimension.

**H4. P. Nakkiran, P. Venkat, S. Kakade, T. Ma (2021).** Optimal regularization can mitigate double descent. *ICLR 2021.* [arXiv:2003.01897](https://arxiv.org/abs/2003.01897). **[V]**
- (a) For isotropic linear regression, optimally tuned $\ell_2$ regularization has provably monotone risk in both sample size and model size, and it mitigates double descent empirically for networks; in Bayesian terms this is the correctly specified Gaussian posterior mean (compare Fact 4), and it supports choosing $c$ by the noise-to-prior ratio rather than $c=1$.
- (b) Double descent appears under under-regularization, and SP$_c$ with $c=1$ and $\sigma\to0$ is under-regularized relative to $O(1)$ label noise, which is Claim A.

**H5. L. Hodgkinson, C. van der Heide, F. Roosta, M. W. Mahoney (2023).** Monotonicity and double descent in uncertainty estimation with Gaussian processes. *ICML 2023*, PMLR 202:13085–13117. [PMLR](https://proceedings.mlr.press/v202/hodgkinson23a.html); [arXiv:2210.07612](https://arxiv.org/abs/2210.07612). **[V]**
- (a) With hyperparameters tuned by marginal likelihood, the GP marginal likelihood improves monotonically with input dimension, while cross-validation metrics and posterior predictive losses can show double descent; at sufficiently small temperature the cross-validation metrics show double descent exactly when the corresponding KRR mean squared error does, and cold posteriors exacerbate these effects, making this the closest published link between posterior temperature and double descent, with SP$_c$'s $\sigma\to0$ at the cold end.
- (b) Cold, near-interpolating GP posteriors inherit kernel ridge regression's noise-driven peaks, the GP form of Claim A's mechanism.

**H6. J. Barbier, F. Camilli, M.-T. Nguyen, M. Pastore, R. Skerk (2025).** Statistical mechanics of extensive-width Bayesian neural networks near interpolation. [arXiv:2505.24849](https://arxiv.org/abs/2505.24849) (supersedes arXiv:2501.18530). **[V]**
- (a) Not directly relevant.
- (b) A Bayes-optimal, well-specified teacher–student analysis of two-layer Bayesian networks near the interpolation threshold, with learning transitions as $n$ grows; by Fact 4 the prior-averaged Bayes-optimal risk there cannot have sample-wise peaks, which contrasts with the misspecified cold posterior of Claim A.

**H7. N. Polson, V. Sokolov (2025).** Bayesian double descent. [arXiv:2507.07338](https://arxiv.org/abs/2507.07338). **[V]**
- (a) A Bayesian (marginal-likelihood, Occam's-razor) reading of double descent tied to how the prior specifies complexity, illustrated with Legendre-polynomial regression; it is conceptual background for Fact 4.
- (b) Not directly relevant.

---

## 4. What I looked for and did not find

* An agnostic oracle inequality for Bayesian neural network posteriors that is uniform in learner width. The closest items are B11 (classification, a general prior, not neural) and Corollary 2 / Fact 3 here, which are width-dependent.
* An analysis of Bayesian neural network posteriors (strong-prior, cold or tempered) under label noise on Boolean or finite domains. The closest items are G18 (binary-weight minimal and typical interpolating networks), B10–B11 (MDL and PAC-Bayes for noisy classification) and G15 (MDL interpolation).
* The exact hypotheses of Bartlett–Foster–Telgarsky (activation conditions and the precise definition of $R_A$), Golowich–Rakhlin–Shamir's Theorem 1 conditions, and the temperature condition of Høgsgaard–Rebeschini–Wegel: the full texts could not be opened.

## 5. Sanity-check scripts

Scripts are in [`../checks/red-team-and-literature/`](../checks/red-team-and-literature/), each with its output in the `.out` file of the same name. Run them with `python3 -I`.

* **`check_expconcave_mixable.py`.**
  * Symbolic $\phi''/\phi=2\eta(2\eta(p-y)^2-1)$.
  * Grid concavity holds for $\eta=0.1$ and $0.125$ and fails for $0.126$ and $0.2$.
  * Random-mixture mixability test: no violation at $\eta=0.5$ (minimum feasibility gap $1.3\times10^{-10}$); a violation at $\eta=0.6$ (gap $-0.040$).
* **`check_progressive_mixture.py`.** Monte Carlo of Fact 2 with $M=40$ functions on a 12-point domain and $\eta=1/8$. The bound holds at $n=5,20,60,200$. The progressive mixture beats the best dictionary element (improper), while the Gibbs draw does not at moderate $n$.
* **`check_atoms_and_cloning.py`.**
  * $\mathbb E[1/K;K\ge1]$ is $0.484829$ for Poisson(1), with maximum $0.517351$ at $\lambda^*=1.5029$; the binomial counts with $d=20,30$ agree to six digits.
  * Clone table: $\kappa_N=12.83$, the Frobenius product and the spectral product are constant over $N=1,\dots,1024$, while $R_A/\sqrt N\to2^{3/2}\cdot4.784\approx13.5$.
  * Lipschitz check: the bound of Section 1.6(i) holds on 300 random networks.
* **`check_atom_trainloss.py`.** Simulated per-sample training loss of the atom-mean fit at $d=16$: $0.2142, 0.3717, 0.4821, 0.6835$ for $\lambda=0.5,1,1.5,3$, against the prediction $1-(1-e^{-\lambda})/\lambda=0.2131, 0.3679, 0.4821, 0.6833$ used in the reading of Fact 3(iv).

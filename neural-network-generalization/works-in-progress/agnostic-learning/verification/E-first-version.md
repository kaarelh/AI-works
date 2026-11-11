# E. Finite prior scale: the agnostic results at every exponent $\gamma\ge1$ and every width

*Research section for the brief `../research-notes/problem-brief.md`, Claim E. 11 November 2026. These are paper proofs with numerical sanity checks; nothing here is Lean-verified. `NNG/` denotes the project folder `neural-network-generalization/` of this repository. Companion sections: Claim A in `../research-notes/A-tight-conditioning-fails.md` and Claim B in `../research-notes/B-tempered-likelihood.md`. The check scripts and their outputs are in `../checks/E/`.*

---

## 0. Results

The learner is the **finite-scale co-scaled Gaussian learner**. Its prior is $\mu_{N,\gamma}$ with $\gamma\ge1$, and its likelihood is $y_i\sim\mathcal N(z_w(x_i),cN^{-\gamma})$. Its posterior density is proportional to $\exp[-N^\gamma F_{c,S}(w)/2]$ with respect to Lebesgue measure (Lemma 1.1). No limit is taken: the sample size $n$, the width $N$ and $\gamma$ are fixed, and the posterior is a fixed probability measure. Write $L=H+1$ for the depth.

| # | statement | where |
|---|---|---|
| 1 | The posterior identity $\Pi_{N,S}(dw)\propto e^{-N^\gamma F_{c,S}(w)/2}dw$, checked against the normalisation of $\mu_{N,\gamma}$. Under the prior, $N^\gamma\kappa_N\sim\chi^2_{P_N}$. The posterior mode is a minimiser of $F_{c,S}$, so the results of Sections A and B for minimisers hold verbatim for the MAP estimator, at the widths where they are stated. | Lemma 1.1, Remark 1.2 |
| 2 | **Positive (Claim B at finite scale).** Let $c=n^{1-\theta}$ with $0<\theta<\theta_{L,\gamma}$. With probability $\ge1-\delta$, **simultaneously for every learner width $N\ge m$**, the Gibbs risk $\mathbb E_{\Pi_{N,S}}L_D(\operatorname{clip}z_w)$ and the risk of the posterior mean of clipped outputs are both at most $L_D(g)+\varepsilon$. This holds for every law $D$ on $X\times[-1,1]$ and every competitor $g$ of depth $L$, width $m$ and weights in $[-B,B]$, once $n\ge{\rm poly}_{L,\gamma,\theta}(d,m,B,1/\varepsilon,\log\frac1\delta)$. The threshold is $\theta_{2,\gamma}=1$ at depth two. For $L\ge3$ it is $\theta_{L,\gamma}=1/H$ when $\gamma\ge2-\frac1H$, and $\max\bigl\{\frac{\gamma-1}{\gamma H-1},\frac{\gamma-1}{H(H-1)(2-\gamma)}\bigr\}<\frac1H$ when $1<\gamma<2-\frac1H$. At $\gamma=1$ it is $\frac1{4+16(L-2)3^{L-2}}$; this case uses the repository's mean-field cover, imported. | Theorem 2.7 |
| 3 | **Where the clean-label proof breaks**, and the repairs. First, the competitor's own residual $n\hat L_S(g)=\Theta(n)$ enters the normaliser, which forces an energy budget $K\asymp n/c$. Second, the cover's width threshold now grows with $n$. Third, the clean small-width argument uses clean labels; it is replaced by a PAC-Bayes bound, valid while $N^\gamma\lesssim\varepsilon n^{1-\theta}$, and by plain energy control, valid while $N^{2-\gamma}\lesssim n^{1/H}$. | §2.7 |
| 4 | **Large-width Laplace lower bound** for $\gamma>1$. Around **any** network $w_0$, $\mu_{N,\gamma}\{\sup_{[-1,1]^d}\lvert z_w-z_{w_0}\rvert\le a\}\ge\frac12e^{-N^\gamma\kappa_N(w_0)/2}$ once $N^{(\gamma-1)/2}\ge(3H+2)\max\{1,\kappa_N(w_0)\}^{H/2}/a$. There is no entropy cost and no cylinder. | Lemma 3.1 |
| 5 | **A memoriser that survives the prior's noise, at every $\gamma\ge1$, mean field included.** For $r$ on $\{-1,1\}^d$ with $\lvert r\rvert\le1$ and $\sum_xr(x)^2\le s$, at every width $N\ge N_*(d,s,a,H)$, a polynomial independent of $\gamma$: $\mu_{N,\gamma}\{\max_{\{-1,1\}^d}\lvert z_w-r\rvert\le a\}\ge\frac12\exp(-N^\gamma K_{\rm rob}/2)$. Here $K_{\rm rob}=O_H\bigl(d^2\log^2(d/a)+(ds)^{1/H}+1/a\bigr)$. The centre is pre-compensated for the slope loss that the prior's noise causes; the network's own averaging over neurons removes the noise. | Proposition 4.4 |
| 6 | **Negative (Claim A at finite scale), every $\gamma\ge1$.** On the noisy cube with $n\asymp2^d$ and $c=1$, or any $c$ with $c\,(d^4+(dn)^{1/H})=o(n)$, take any width $N\ge N_*={\rm poly}(n)$. With probability $\to1$, the Gibbs predictor and the posterior means (clipped or not) have test MSE $\ge1+\beta(\lambda)-o(1)$, while the zero network attains the Bayes risk $1$. The posterior mass of non-memorising networks is at most $2e^{-N^\gamma}$. So the polynomial oracle inequality fails at every $\gamma\ge1$ and every depth $L\ge3$, for $c=1$ and for $c=n^{1-\theta}$ with $\theta>1/H$. | Theorem 5.2, Corollaries 5.3–5.4 |
| 7 | **Phase diagram.** For $L\ge3$ and $\gamma\ge2-\frac1H$, the finite-scale learner has the same sharp threshold $\theta=1/H$ as the strong-prior limit. For $1\le\gamma<2-\frac1H$, $\theta<\theta_{L,\gamma}$ works and $\theta>1/H$ fails; the window $[\theta_{L,\gamma},1/H]$ is open. | §6 |

**Answers to the two tasks.**
- (1) **Positive.** The finite-scale proof of `NNG/works-in-progress/slt-likelihood/README.md` §2 adapts to agnostic data with $c=n^{1-\theta}$, with polynomial sample complexity at every width $N\ge m$. The exponent range equals the strong-prior range of Section B at depth two ($\theta<1$) and for $L\ge3$, $\gamma\ge2-1/H$ ($\theta<1/H$). In the second case it is sharp, since $\theta>1/H$ fails (Corollary 5.4). It is smaller for $1\le\gamma<2-1/H$, where the cover's width threshold must be bridged.
- (2) **Negative.** The memorisation counterexample transfers to $c=1$ at **every** finite $\gamma\ge1$, including mean field, at all widths above a polynomial in $n$. The required tube bound $\mu_{N,\gamma}(\text{tube})\ge e^{-N^\gamma A_{\rm mem}}$ holds with $A_{\rm mem}=K_{\rm rob}/2+o(1)=o(n)$.

**Earlier sketches.** The red-team pass (`../research-notes/red-team.md` §8) sketched both directions for $\gamma>1$, with a smaller positive range $\theta<(\gamma-1)/(2(L-2))$. It called mean field open in both directions. Lemma 3.1 replaces its cylinder estimate. Proposition 4.4 settles the negative direction at $\gamma=1$. Theorem 2.7 covers $\gamma=1$ with the existing mean-field cover; no new agnostic cover is needed, because the cover is a statement about the prior only.

---

## 1. Setting, the posterior identity, and tools

### 1.1 Networks, energy, prior

Fix $d\ge1$, a nonempty compact $X\subseteq[-1,1]^d$, depth $L=H+1\ge2$ and width $N\ge1$. A parameter is $w=(W^1,\dots,W^H,v)\in\mathcal W_N=\mathbb R^{P_N}$, where $W^1\in\mathbb R^{N\times(d+1)}$, $W^\ell\in\mathbb R^{N\times N}$ for $2\le\ell\le H$, $v\in\mathbb R^N$, and $P_N=N(d+2)+(H-1)N^2$. The network is
$$h^0(x)=\bar x=(1,x),\qquad h^\ell(x)=\tanh\bigl(W^\ell h^{\ell-1}(x)\bigr)\ (1\le\ell\le H),\qquad z_w(x)=v^\top h^H(x).$$
The layer energies and the energy are
$$\kappa^{(1)}(w)=\tfrac dN\lVert W^1\rVert_F^2,\qquad\kappa^{(\ell)}(w)=\lVert W^\ell\rVert_F^2\ (2\le\ell\le H),\qquad\kappa^{(L)}(w)=N\lVert v\rVert_2^2,\qquad\kappa_N=\sum_{\ell=1}^L\kappa^{(\ell)} .$$
This is eq. `energy` of `NNG/side-results/continuous-domains/source/paper.tex` and the energy of brief §2. Two deterministic facts (../research-notes/A-tight-conditioning-fails.md Lemma 3.1, ../research-notes/B-tempered-likelihood.md Lemma 2.1) are used throughout:
$$\lvert z_w(x)\rvert\le\lVert v\rVert_1\le\sqrt{\kappa^{(L)}(w)}\le\sqrt{\kappa_N(w)},\qquad\lVert W^\ell\rVert_{\rm op}\le\lVert W^\ell\rVert_F . \tag{1.1}$$

**The finite-scale prior.** $\mu_{N,\gamma}$ has independent centred Gaussian coordinates with variances $N^{1-\gamma}/d$ (first layer), $N^{-\gamma}$ (internal layers) and $N^{-\gamma-1}$ (readout). This is eq. `finite-scales` of `paper.tex` with Gaussian coordinates ($m=M=1$ in its eq. `law`), and the family of brief §2 with $\sigma^2=N^{-\gamma}$. Put
$$\tau=\tau_N:=N^{(1-\gamma)/2}\in(0,1].$$
In standardised coordinates, $w=D_N\xi$ with $\xi\sim\mathcal N(0,I_{P_N})$ and $D_N$ diagonal with entries $\tau/\sqrt d$ (first layer), $\tau/\sqrt N$ (internal) and $\tau/N$ (readout); indeed $(\tau/\sqrt d)^2=N^{1-\gamma}/d$, $(\tau/\sqrt N)^2=N^{-\gamma}$ and $(\tau/N)^2=N^{-\gamma-1}$. A direct check gives
$$\lVert D_N^{-1}w\rVert_2^2=N^\gamma\kappa_N(w)\qquad(w\in\mathcal W_N). \tag{1.2}$$
For example, a first-layer entry contributes $dN^{\gamma-1}(W^1_{ij})^2=N^\gamma\cdot\frac dN(W^1_{ij})^2$, and a readout entry contributes $N^{\gamma+1}v_j^2=N^\gamma\cdot Nv_j^2$.

### 1.2 The posterior

Let $S=((x_i,y_i))_{i=1}^n$, $R_S(w)=\sum_i(z_w(x_i)-y_i)^2$, $\hat L_S(f)=\frac1n\sum_i(f(x_i)-y_i)^2$, $L_D(f)=\mathbb E_D(f(x)-y)^2$, and
$$F_{c,S}(w)=\kappa_N(w)+\frac1cR_S(w).$$

**Lemma 1.1 (posterior identity).** Let $\Gamma_N$ be the diagonal matrix with entries $d/N$, $1$, $N$ on the three blocks, so that $\kappa_N(w)=w^\top\Gamma_Nw$.

- (a) $\mu_{N,\gamma}(dw)=\bigl(N^\gamma/2\pi\bigr)^{P_N/2}(\det\Gamma_N)^{1/2}\,e^{-N^\gamma\kappa_N(w)/2}\,dw$. Under $\mu_{N,\gamma}$, $N^\gamma\kappa_N(w)\sim\chi^2_{P_N}$.
- (b) With the likelihood $\prod_i\mathcal N(y_i;z_w(x_i),cN^{-\gamma})$, the posterior is
$$\Pi_{N,S}(dw)=\frac{e^{-N^\gamma F_{c,S}(w)/2}\,dw}{\int e^{-N^\gamma F_{c,S}/2}}=\frac{e^{-\Lambda_N\hat L_S(z_w)}\,\mu_{N,\gamma}(dw)}{\int e^{-\Lambda_N\hat L_S(z_u)}\mu_{N,\gamma}(du)},\qquad\Lambda_N:=\frac{N^\gamma n}{2c}.$$
  With $c=n^{1-\theta}$, $\Lambda_N=N^\gamma n^\theta/2$.

*Proof.*

(a) The covariance of $\mu_{N,\gamma}$ is $\Sigma=(N^\gamma\Gamma_N)^{-1}$. Its diagonal entries are $N/(N^\gamma d)=N^{1-\gamma}/d$, $N^{-\gamma}$ and $1/(N^\gamma N)=N^{-\gamma-1}$, the variances listed above. The Gaussian density is $(2\pi)^{-P_N/2}\det(\Sigma)^{-1/2}e^{-w^\top\Sigma^{-1}w/2}$, and $w^\top\Sigma^{-1}w=N^\gamma\kappa_N(w)$. By (1.2), $N^\gamma\kappa_N(w)=\lVert\xi\rVert^2$ with $\xi\sim\mathcal N(0,I_{P_N})$.

(b) The likelihood is $(2\pi cN^{-\gamma})^{-n/2}\exp\bigl(-\frac{N^\gamma}{2c}R_S(w)\bigr)$. Its prefactor does not depend on $w$. Multiplying by the density in (a) gives a constant times $e^{-N^\gamma F_{c,S}(w)/2}$. This is integrable because $F_{c,S}\ge\kappa_N$ and $\kappa_N$ is a positive definite quadratic form. Finally $\frac{N^\gamma}{2c}R_S=\frac{N^\gamma n}{2c}\hat L_S=\Lambda_N\hat L_S$. $\square$

So $\Pi_{N,S}$ is exactly the strong-prior posterior SP$_c$ of Sections A and B at $\sigma^2=N^{-\gamma}$. The difference is that $\sigma$ is tied to the width and no limit is taken. Only Gaussian coordinates are treated. For the non-Gaussian coordinate laws of `paper.tex` eq. `law`, the identity in (b) fails, and the proofs below would need the constants $m,M$ of that equation.

**Remark 1.2 (the MAP and the full posterior).** The mode of $\Pi_{N,S}$ is a minimiser of $F_{c,S}$ over $\mathcal W_N$. All statements of Sections A and B about minimisers therefore hold for the MAP estimator, for every $\gamma$, at the widths where they are stated. That includes B Theorem 6.3 at $c=n^{1-\theta}$, $\theta<1/H$ (every $N\ge m$), and A Theorem 4.4(i) at $c=1$ (every $N\ge N_0$). The finite-scale question concerns the full posterior. For $\gamma<2$ the full posterior is not close to its mode in parameter space. A typical prior draw has internal energy $\mathbb E\,\lVert W^\ell\rVert_F^2=N^{2-\gamma}\to\infty$. Its outputs are nevertheless nearly those of a low-energy network: spectral truncation (Lemma 2.4) gives this for $\gamma>1$, the mean-field cover (I3) for $\gamma=1$. The work below consists of controlling this gap between parameter space and function space.

### 1.3 Agnostic notation

$D$ is a Borel law on $X\times[-1,1]$ and $S\sim D^n$. Write $\operatorname{clip}(u)=\max\{-1,\min\{1,u\}\}$. Since clipping is the metric projection onto $[-1,1]$,
$$(\operatorname{clip}u-y)^2\le(u-y)^2\quad(\lvert y\rvert\le1),\qquad\lvert(\operatorname{clip}u-y)^2-(\operatorname{clip}u'-y)^2\rvert\le4\lvert u-u'\rvert . \tag{1.3}$$
The competitor $g=z_{w^g}$ has depth $L$, width $m$ and all weights in $[-B,B]$, with $B\ge1$. Put
$$U:=mB\ \ (\ge\sup\lvert g\rvert),\qquad E_*:=d(d+1)B^2+2(L-1)m^2B^2 .$$
The class $\mathcal Z_K=\bigcup_{N\ge1}\{z_w:w\in\mathcal W_N,\ \kappa_N(w)\le K\}$ is the union over **all** widths. $D_n:=\sqrt{2(d+1)\ln(n+1)}+\frac{H-1}2$.

### 1.4 Gaussian facts

Let $\gamma_P$ be the standard Gaussian measure on $\mathbb R^P$.

- **(G1) $\chi^2$ tail.** If $Y\sim\chi^2_P$ and $u\ge3P$, then $\Pr(Y>u)\le e^{-u/8}$.
  *Proof.* $\mathbb Ee^{Y/4}=2^{P/2}$, so Markov gives $\Pr(Y>u)\le\exp(\frac{P\ln2}2-\frac u4)\le\exp(\frac{u\ln2}6-\frac u4)\le e^{-u/8}$, since $\frac{\ln2}6<\frac18$.
- **(G2) Translation.** If $E\subseteq\mathbb R^P$ is Borel and symmetric ($E=-E$), and $a\in\mathbb R^P$, then $\gamma_P(a+E)\ge e^{-\lvert a\rvert^2/2}\gamma_P(E)$.
  *Proof.* $\gamma_P(a+E)=\int_E\varphi(\eta+a)d\eta=e^{-\lvert a\rvert^2/2}\int_E\varphi(\eta)e^{-\langle\eta,a\rangle}d\eta$. By symmetry of $E$ the last integral equals $\int_E\varphi(\eta)\cosh\langle\eta,a\rangle d\eta\ge\gamma_P(E)$. This is `paper.tex` eq. `translation` with $M=1$.
- **(G3) Gaussian concentration and Gordon's bound.** If $f:\mathbb R^P\to\mathbb R$ is 1-Lipschitz, then $\Pr(f(\xi)\ge\mathbb Ef(\xi)+t)\le e^{-t^2/2}$ (Tsirelson–Ibragimov–Sudakov). For a $p\times q$ matrix $G$ of i.i.d. $\mathcal N(0,1)$ entries, $\mathbb E\lVert G\rVert_{\rm op}\le\sqrt p+\sqrt q$ (Gordon; Davidson–Szarek 2001, Thm. II.13; Vershynin 2018, Thm. 7.3.1). Since $\lVert\cdot\rVert_{\rm op}$ is 1-Lipschitz for the Frobenius norm, $\Pr(\lVert G\rVert_{\rm op}\ge\sqrt p+\sqrt q+t)\le e^{-t^2/2}$. Likewise $\Pr(\lvert\xi\rvert\ge\sqrt P+t)\le e^{-t^2/2}$, since $\mathbb E\lvert\xi\rvert\le\sqrt P$.
- **(G4) Gaussian isoperimetry.** If $\gamma_P(B)\ge\frac12$, then $\gamma_P\{\xi:{\rm dist}(\xi,B)>t\}\le1-\Phi(t)\le\frac12e^{-t^2/2}$ for $t\ge0$ (Borell; Sudakov–Tsirelson). This is `paper.tex` eq. `enlargement` with $m=1$.
- **(G5) Mirsky.** For matrices $A,B$ of the same shape, $\sum_j(s_j(A)-s_j(B))^2\le\lVert A-B\rVert_F^2$. Hence the Frobenius distance from $A$ to $\{\lVert B\rVert_{\rm op}\le r\}$ is at least $\bigl(\sum_j(s_j(A)-r)_+^2\bigr)^{1/2}$.

`check_opnorm.py` confirms the operator-norm facts numerically, and `check_constants.py` and `check_symbolic.py` check the scalar constants used below.

### 1.5 Imported results

Each statement below was checked against its source. The proofs of (I1) and (I3) are in the repository and are not reproduced here. The proofs of (I2) and (I4) are in the companion sections.

- **(I1) Teacher tube at every width** (`paper.tex`, Proposition `tube`, eqs. `tube-mass` and `A`, with Remark `cube` for $X\subseteq[-1,1]^d$). For $N\ge m$, $\gamma\ge1$ and $0<\rho\le1$,
$$\mu_{N,\gamma}(U_\rho(g))\ge e^{-A\,N^\gamma},\qquad U_\rho(g)=\{w:\sup_X\lvert z_w-g\rvert<\rho\}.$$
  For Gaussian coordinates,
$$A=A_L(d,m,B,\rho)=1+\tfrac12E_*+[d+2+(L-2)m]\ln\frac8{3\eta_\rho}+\ln2,$$
  where $\eta_\rho=\min\{\frac12,\frac\rho{2P_0}\}$, $P_0=1+2mB(d+L+1)A_0^{L-2}$, $A_0=2+3mB+b_0$ and $b_0=2\sqrt{2[2\ln9+\ln(4L)]}$. This is polynomial in $d,m,B,\log(1/\rho)$ at fixed $L$. I re-derived the error recursion of the proof, $e_\ell\le(\sqrt2mB+b_0)e_{\ell-1}+\eta\sqrt m$, and the clone's operator-norm bound $\sqrt2mB$; I also re-derived the cylinder count $N[d+2+(L-2)m]$ and the use of (G2).
- **(I2) Width-free uniform deviation** (../research-notes/B-tempered-likelihood.md Lemma 5.3(a), built on ../research-notes/B-tempered-likelihood.md Lemma 5.2). ../research-notes/B-tempered-likelihood.md Lemma 5.2 is the arbitrary-input version of `NNG/works-in-progress/noisy-interpolation/README.md` eq. (15). For $K>0$ and $\delta'\in(0,1)$, with probability at least $1-\delta'$ over $S$, every $z\in\mathcal Z_K$ satisfies
$$L_D(\operatorname{clip}z)\le\hat L_S(\operatorname{clip}z)+\Psi_n(K,\delta'),\qquad\Psi_n(K,\delta'):=8\Bigl(\frac KH\Bigr)^{H/2}\frac{D_n}{\sqrt n}+4\sqrt{\frac{\ln(1/\delta')}{2n}} .$$
  I re-checked the proof: path-norm representation, clip-mixture peeling, Sauer–Shelah plus Massart for the first layer, symmetrisation, contraction, and McDiarmid.
- **(I3) Mean-field output cover** (`NNG/side-results/continuous-domains/source/meanfield.tex`, Proposition `mf-cover`, with the cube modification stated in its proof). There are functions $T_L(d,K,1/a)$ and $H^{\rm mf}_L(d,K,1/a)$, polynomially bounded at fixed $L$, and a fixed-law constant $K_0^{\rm mf}\ge4$, with the following property. For $0<a<1$ and $K\ge K_0^{\rm mf}$ there is a finite family $\mathcal C_{K,a}$ of Borel functions on $X$, independent of $N$, such that for every $N\ge T_L(d,K,1/a)$:
$$\ln\lvert\mathcal C_{K,a}\rvert\le H^{\rm mf}_L,\qquad\mu_{N,1}\Bigl\{\inf_{h\in\mathcal C_{K,a}}\sup_X\lvert z_w-h\rvert>a\Bigr\}\le2Le^{-NK/16}.$$
  The constant is $c=\min\{\frac14,\frac m{16}\}=\frac1{16}$ for Gaussian coordinates. From the explicit formulas of that proof ($G_r$, $G_\ell$, eq. `T`, $\eta$, $J$, $P$), the degrees in $K$, up to logarithmic factors, are $D_T:=\deg_KT_L=4\cdot3^{L-1}$ and $D_H:=\deg_KH^{\rm mf}_L=4+16(L-2)3^{L-2}$ for $L\ge3$. The source defers some expanded calculations to a companion paper (`nongaus`). The $\gamma=1$ part of Theorem 2.7 therefore inherits that dependence.
- **(I4) Cube lemmas** (../research-notes/A-tight-conditioning-fails.md). These are: the coefficient bound $\lvert c_{k,\infty}\rvert\ge(2k)^{-1/2}$ (Lemma 2.2(b)); the Fourier $\ell^1$ bound $\sum_S\lvert\hat f(S)\rvert\le(\sum_xf(x)^2)^{1/2}$ (eq. (2.4)); the atom decomposition $R_S(f)=\Delta(f)+W$ and $\Delta(\operatorname{clip}f)\le\Delta(f)$ (Lemma 4.1(a),(c)); the test-loss bound (Lemma 4.2(b)); and the statistics of $Q$ (Lemma 4.3). The notation $k_x,\bar y_x,\mathcal S,Q,W,\Delta,\beta_n,\beta(\lambda)$ is that of ../research-notes/A-tight-conditioning-fails.md §1.4.

---

## 2. Positive direction: an agnostic oracle inequality at finite scale

Throughout this section $c=n^{1-\theta}$, $\theta\in(0,1)$, $\varepsilon,\delta\in(0,1)$, and
$$\rho:=\frac{\varepsilon}{16(U+1)},\qquad A:=A_L(d,m,B,\rho),\qquad a:=\frac\varepsilon{64},$$
$$h_n:=(U+1)^2\sqrt{\frac{\ln(4/\delta)}{2n}},\qquad\eta:=2\rho(U+1)+\rho^2+2n^{-\theta}\Bigl(A+\ln\frac{64}\varepsilon\Bigr).$$

Note $2\rho(U+1)=\varepsilon/8$ and $\rho^2\le\varepsilon/256$.

The three sample events used below do not depend on $N$:

- the Hoeffding event $\mathcal E_H=\{\hat L_S(g)\le L_D(g)+h_n\}$, which has probability $\ge1-\delta/4$ because the losses of $g$ lie in $[0,(U+1)^2]$;
- the capacity event $\mathcal E_{\rm cap}(\bar K)$ of (I2), with $\delta'=\delta/4$;
- for $\gamma=1$, the cover event $\mathcal E_{\rm mf}$ of Lemma 2.6.

### 2.1 Three posterior inequalities valid at every width

**Lemma 2.1.** Let $N\ge m$, and let $S$ be any sample with labels in $[-1,1]$. Write $\Pi=\Pi_{N,S}$ and $\Lambda=\Lambda_N=N^\gamma n^\theta/2$.

- (a) $Z:=\int e^{-\Lambda(\hat L_S(z_w)-\hat L_S(g))}\mu_{N,\gamma}(dw)\ \ge\ \exp\bigl(-N^\gamma\bigl[A+n^\theta(\rho(U+1)+\rho^2/2)\bigr]\bigr)$.
- (b) $\Pi\{w:\hat L_S(z_w)>\hat L_S(g)+\eta\}\le\varepsilon/64$.
- (c) For every Borel $G\subseteq\mathcal W_N$, $\Pi(G^c)\le\mu_{N,\gamma}(G^c)\exp\bigl(N^\gamma\bigl[A+\frac{n^\theta}2(U+2)^2\bigr]\bigr)$.

*Proof.*

- **(a)** For $w\in U_\rho(g)$ we have $\lvert z_w-g\rvert<\rho$ on $X$. With $\sqrt{\hat L_S(g)}\le U+1$, Minkowski gives $\hat L_S(z_w)\le(\sqrt{\hat L_S(g)}+\rho)^2\le\hat L_S(g)+2\rho(U+1)+\rho^2$. Restrict the integral to $U_\rho(g)$ and use (I1).
- **(b)** The numerator is at most $e^{-\Lambda\eta}$. With (a), the ratio is at most $\exp(-N^\gamma[\frac{n^\theta}2\eta-A-n^\theta(\rho(U+1)+\frac{\rho^2}2)])=\exp(-N^\gamma\ln\frac{64}\varepsilon)\le\frac\varepsilon{64}$, using the definition of $\eta$ and $N^\gamma\ge1$.
- **(c)** The numerator $\int_{G^c}e^{-\Lambda(\hat L_S(z_w)-\hat L_S(g))}d\mu$ is at most $e^{\Lambda\hat L_S(g)}\mu(G^c)\le e^{\Lambda(U+1)^2}\mu(G^c)$. Divide by (a). Then use $(U+1)^2+2\rho(U+1)+\rho^2=(U+1+\rho)^2\le(U+2)^2$. $\square$

Lemma 2.1 replaces the clean-label normaliser $e^{-N^\gamma(A+1/2)}$ of the slt-likelihood note. The factor $e^{\Lambda\hat L_S(g)}$ in (c) is where the agnostic setting differs. A Borel set of prior mass $e^{-N^\gamma K/8}$ is negligible under the posterior only if $K\gtrsim4n^\theta(U+2)^2$, an energy budget of order $n/c$.

### 2.2 Small widths: a PAC-Bayes bound

The slt-likelihood note bounds small widths using clean labels: a parameter with large test tail risk has expected likelihood at most $e^{-nc_\tau r}$. With noisy labels that argument has no analogue. Its replacement is a PAC-Bayes bound whose variance term pays $N^\gamma$.

**Lemma 2.2.** Fix $N\ge m$ and $\delta'\in(0,1)$. With probability at least $1-\delta'$ over $S$,
$$\mathbb E_{\Pi_{N,S}}L_D(\operatorname{clip}z_w)\le\hat L_S(g)+2\rho(U+1)+\rho^2+2n^{-\theta}\Bigl(A+\frac{\ln(1/\delta')}{N^\gamma}\Bigr)+N^\gamma n^{\theta-1}.$$

*Proof.* Let $\ell(w,(x,y))=(\operatorname{clip}z_w(x)-y)^2\in[0,4]$. It is jointly measurable, indeed continuous. Write $L_D(w)$ and $\hat L_S(w)$ for its population and empirical means, and $\Lambda=\Lambda_N$.

1. **Exponential moment.** For fixed $w$, $\Lambda(L_D(w)-\hat L_S(w))=\sum_i\frac\Lambda n(L_D(w)-\ell(w,(x_i,y_i)))$ is a sum of $n$ independent centred terms, each in an interval of length $4\Lambda/n$. Hoeffding's lemma gives $\mathbb E_Se^{\Lambda(L_D(w)-\hat L_S(w))}\le e^{2\Lambda^2/n}$. By Tonelli, $\mathbb E_S\mathbb E_{\mu}e^{\Lambda(L_D-\hat L_S)-2\Lambda^2/n}\le1$.
2. **Markov.** With probability $\ge1-\delta'$, $\mathbb E_\mu e^{\Lambda(L_D-\hat L_S)-2\Lambda^2/n}\le1/\delta'$.
3. **Donsker–Varadhan.** On that event, every $\varrho\ll\mu$ satisfies $\Lambda(\mathbb E_\varrho L_D-\mathbb E_\varrho\hat L_S)-2\Lambda^2/n\le{\rm KL}(\varrho\Vert\mu)+\ln(1/\delta')$; the integrand is bounded. Take $\varrho=\Pi:=\Pi_{N,S}$.
4. **Gibbs identity.** $\Pi$ has density $e^{-\Lambda\hat L'_S}/Z'$ with respect to $\mu$, where $\hat L'_S(w)=\hat L_S(z_w)$ is the unclipped empirical loss and $Z'=\mathbb E_\mu e^{-\Lambda\hat L'_S}\in(0,1]$. Moreover $\mathbb E_\Pi\hat L'_S<\infty$, since $te^{-\Lambda t}\le(e\Lambda)^{-1}$. Hence ${\rm KL}(\Pi\Vert\mu)=-\Lambda\mathbb E_\Pi\hat L'_S-\ln Z'$, that is, $\mathbb E_\Pi\hat L'_S+{\rm KL}(\Pi\Vert\mu)/\Lambda=-\Lambda^{-1}\ln Z'$.
5. **Normaliser.** As in Lemma 2.1(a), $Z'\ge\mu(U_\rho(g))e^{-\Lambda(\hat L_S(g)+2\rho(U+1)+\rho^2)}$. So $-\Lambda^{-1}\ln Z'\le\hat L_S(g)+2\rho(U+1)+\rho^2+N^\gamma A/\Lambda$.
6. **Combination.** By (1.3), $\hat L_S(w)\le\hat L'_S(w)$. Steps 3–5 give
$$\mathbb E_\Pi L_D(\operatorname{clip}z_w)\le\hat L_S(g)+2\rho(U+1)+\rho^2+\frac{N^\gamma A+\ln(1/\delta')}\Lambda+\frac{2\Lambda}n .$$
   Substitute $\Lambda=N^\gamma n^\theta/2$. $\square$

The bound is useful exactly when $N^\gamma n^{\theta-1}\le\varepsilon/4$. It is the analogue of brief Claim C at the cold temperature of the co-scaled likelihood.

### 2.3 The energy regime

**Lemma 2.3.** Let $N\ge m$ and let $K'$ satisfy
$$K'\ge K_{\min}:=8A+4n^\theta(U+2)^2+8\ln\frac{64}\varepsilon\qquad\text{and}\qquad N^\gamma K'\ge3P_N. \tag{2.1}$$

- (a) For every sample, $\Pi_{N,S}\{\kappa_N>K'\}\le\varepsilon/64$.
- (b) Let $K'\le\bar K$. On $\mathcal E_H\cap\mathcal E_{\rm cap}(\bar K)$,
$$\mathbb E_{\Pi_{N,S}}L_D(\operatorname{clip}z_w)\le L_D(g)+h_n+\eta+\Psi_n(\bar K,\delta/4)+\varepsilon/8 .$$

*Proof.*

- **(a)** By Lemma 1.1(a) and (G1), $\mu_{N,\gamma}\{\kappa_N>K'\}=\Pr(\chi^2_{P_N}>N^\gamma K')\le e^{-N^\gamma K'/8}$. Lemma 2.1(c) gives $\Pi\{\kappa_N>K'\}\le\exp(-N^\gamma[\frac{K'}8-A-\frac{n^\theta}2(U+2)^2])\le e^{-N^\gamma\ln(64/\varepsilon)}\le\varepsilon/64$.
- **(b) Good parameters.** Let $w$ satisfy $\kappa_N(w)\le K'$ and $\hat L_S(z_w)\le\hat L_S(g)+\eta$. Then $z_w\in\mathcal Z_{\bar K}$, and (I2) and (1.3) give
$$L_D(\operatorname{clip}z_w)\le\hat L_S(\operatorname{clip}z_w)+\Psi_n\le\hat L_S(z_w)+\Psi_n\le\hat L_S(g)+\eta+\Psi_n\le L_D(g)+h_n+\eta+\Psi_n .$$
- **(b) Bad parameters.** By (a) and Lemma 2.1(b), the remaining parameters have posterior mass at most $\varepsilon/32$. Their loss is at most $4$, which contributes at most $\varepsilon/8$. $\square$

When does (2.1) hold at every width? Write $\frac{3P_N}{N^\gamma}=3(d+2)N^{1-\gamma}+3(H-1)N^{2-\gamma}$.

- At depth two ($H=1$), (2.1) holds for all $N$ once $K'\ge3(d+2)$.
- For $H\ge2$ and $\gamma\ge2$, it holds for all $N$ once $K'\ge3(d+H+1)$, because $N^{1-\gamma},N^{2-\gamma}\le1$.
- For $1\le\gamma<2$ it holds only while $3(H-1)N^{2-\gamma}\le K'-3(d+2)$. That is the price of the internal layers' prior energy $N^{2-\gamma}$.

### 2.4 Large widths for $\gamma>1$: spectral truncation

For a matrix $W$ with singular value decomposition $W=\sum_js_ju_jv_j^\top$, let $W_{>b}=\sum_{s_j>b}s_ju_jv_j^\top$.

**Lemma 2.4 (spectral truncation, Gaussian case).** Let $\gamma>1$, $H\ge2$, $K\ge3(d+2)$ and $a\in(0,1]$. Put $b:=a/(2(H-1)K^{(H-1)/2})$, and suppose $N^{(\gamma-1)/2}\ge7/b$. Let
$$G_K=\{w:\ \kappa^{(1)}(w)\le K,\ \kappa^{(L)}(w)\le K,\ \lVert(W^\ell)_{>b}\rVert_F^2\le K\ (2\le\ell\le H)\}.$$
Then $\mu_{N,\gamma}(G_K^c)\le Le^{-N^\gamma K/8}$. Moreover, for $w\in G_K$ let $\tilde w$ be $w$ with each $W^\ell$ ($2\le\ell\le H$) replaced by $(W^\ell)_{>b}$. Then $\kappa_N(\tilde w)\le LK$ and $\sup_{x\in\mathbb R^d}\lvert z_w(x)-z_{\tilde w}(x)\rvert\le a/2$.

This is `paper.tex` Lemma `spectral`, re-proved for Gaussian coordinates with explicit constants. The paper's version takes $b=a/[2L(\sqrt K+1)^{L-2}]$ and the condition $N^{\gamma-1}\ge256/(mb^2)$; this one has the same form.

*Proof.*

1. **First layer and readout.** In standardised coordinates, $\kappa^{(1)}=N^{-\gamma}\lvert\xi^1\rvert^2$ with $\xi^1\in\mathbb R^{N(d+1)}$, and $\kappa^{(L)}=N^{-\gamma}\lvert\zeta\rvert^2$ with $\zeta\in\mathbb R^N$. Since $N^\gamma K\ge NK\ge3N(d+1)$, (G1) gives $\Pr(\kappa^{(1)}>K)\le e^{-N^\gamma K/8}$, and likewise $\Pr(\kappa^{(L)}>K)\le e^{-N^\gamma K/8}$.
2. **Internal layers: a large median ball.** $W^\ell=\sigma Z$ with $\sigma=N^{-\gamma/2}$ and $Z$ an $N\times N$ standard Gaussian matrix. By (G3), $\Pr(\lVert Z\rVert_{\rm op}\le2\sqrt N+\sqrt{2\ln2})\ge\frac12$. The hypothesis gives $b\ge7N^{(1-\gamma)/2}=7\sigma\sqrt N$, so $\frac b{2\sigma}\ge3.5\sqrt N\ge2\sqrt N+\sqrt{2\ln2}$. Hence $\mathcal B=\{Z:\lVert Z\rVert_{\rm op}\le b/(2\sigma)\}$ has $\gamma(\mathcal B)\ge\frac12$.
3. **Internal layers: isoperimetry.** Each $s_j>b$ satisfies $s_j\le2(s_j-b/2)$. With (G5),
$$\lVert(\sigma Z)_{>b}\rVert_F^2\le4\sum_j\bigl(s_j(\sigma Z)-b/2\bigr)_+^2\le4\sigma^2{\rm dist}_F(Z,\mathcal B)^2 .$$
   By (G4), $\Pr(\lVert(\sigma Z)_{>b}\rVert_F^2>K)\le\Pr({\rm dist}_F(Z,\mathcal B)>\sqrt K/(2\sigma))\le\frac12e^{-K/(8\sigma^2)}=\frac12e^{-N^\gamma K/8}$.
4. **Union bound.** $\mu(G_K^c)\le(2+\frac{H-1}2)e^{-N^\gamma K/8}\le Le^{-N^\gamma K/8}$.
5. **Energy of $\tilde w$.** On $G_K$, $\kappa_N(\tilde w)\le K+(H-1)K+K=LK$.
6. **Deterministic error.** Let $e_\ell=N^{-1/2}\lVert h^\ell-\tilde h^\ell\rVert$, so $e_1=0$. For $\ell\ge2$, write $W^\ell=(W^\ell)_{>b}+(W^\ell)_{\le b}$, where $\lVert(W^\ell)_{\le b}\rVert_{\rm op}\le b$ and $\lVert(W^\ell)_{>b}\rVert_{\rm op}\le\lVert(W^\ell)_{>b}\rVert_F\le\sqrt K$. Since $\lVert h^{\ell-1}\rVert\le\sqrt N$ and tanh is 1-Lipschitz coordinatewise, $e_\ell\le\sqrt Ke_{\ell-1}+b$. So $e_H\le b\sum_{j=0}^{H-2}K^{j/2}$. The output error is at most $\lVert v\rVert\sqrt N\,e_H\le\sqrt Ke_H\le b\sum_{j=1}^{H-1}K^{j/2}\le b(H-1)K^{(H-1)/2}=a/2$. $\square$

`check_truncation.py` confirms the error bound and the energy bound on networks with low-rank signal plus Gaussian bulk.

**Lemma 2.5 (truncation regime).** Let $\gamma>1$, $H\ge2$, $a=\varepsilon/64$, and
$$K\ge K_T:=8A+4n^\theta(U+2)^2+8\ln\frac{64L}\varepsilon+3(d+2),\qquad T(K):=\Bigl\lceil\Bigl(\frac{896(H-1)K^{(H-1)/2}}{\varepsilon}\Bigr)^{2/(\gamma-1)}\Bigr\rceil .$$
For every $N\ge\max\{m,T(K)\}$ and every sample, $\Pi_{N,S}(G_K^c)\le\varepsilon/64$. If $LK\le\bar K$, then on $\mathcal E_H\cap\mathcal E_{\rm cap}(\bar K)$,
$$\mathbb E_{\Pi_{N,S}}L_D(\operatorname{clip}z_w)\le L_D(g)+h_n+\eta+\Psi_n(\bar K,\delta/4)+\frac\varepsilon{16}+\frac\varepsilon8 .$$

*Proof.*

- **Applicability of Lemma 2.4.** $N\ge T(K)$ means $N^{(\gamma-1)/2}\ge14(H-1)K^{(H-1)/2}/a=7/b$.
- **Exceptional mass.** By Lemma 2.4 and Lemma 2.1(c), $\Pi(G_K^c)\le L\exp(-N^\gamma[\frac K8-A-\frac{n^\theta}2(U+2)^2])\le Le^{-\ln(64L/\varepsilon)}=\varepsilon/64$.
- **Good parameters.** Let $w\in G_K$ with $\hat L_S(z_w)\le\hat L_S(g)+\eta$. Then $z_{\tilde w}\in\mathcal Z_{LK}\subseteq\mathcal Z_{\bar K}$, and $\lvert z_w-z_{\tilde w}\rvert\le a/2$ everywhere. By (1.3) and (I2),
$$L_D(\operatorname{clip}z_w)\le L_D(\operatorname{clip}z_{\tilde w})+2a\le\hat L_S(\operatorname{clip}z_{\tilde w})+\Psi_n+2a\le\hat L_S(\operatorname{clip}z_w)+\Psi_n+4a .$$
  Then continue as in Lemma 2.3(b); $4a=\varepsilon/16$. $\square$

### 2.5 Large widths at $\gamma=1$: the mean-field cover

**Lemma 2.6 (mean-field regime).** Let $\gamma=1$, $H\ge2$, $a=\varepsilon/64$, and
$$K\ge K_{\rm MF}:=\max\Bigl\{K_0^{\rm mf},\ 16A+8n^\theta(U+2)^2+16\ln\frac{128L}\varepsilon\Bigr\}.$$
Let $\mathcal E_{\rm mf}$ be the event that every $h\in\mathcal C_{K,a}$ satisfies
$$L_D(\operatorname{clip}h)\le\hat L_S(\operatorname{clip}h)+{\rm dev}_{\rm mf},\qquad{\rm dev}_{\rm mf}:=4\sqrt{\frac{H^{\rm mf}_L(d,K,1/a)+\ln(4/\delta)}{2n}} .$$
It has probability $\ge1-\delta/4$, by one-sided Hoeffding for each centre and a union bound over $\mathcal C_{K,a}$. For every $N\ge\max\{m,T_L(d,K,1/a)\}$, on $\mathcal E_H\cap\mathcal E_{\rm mf}$,
$$\mathbb E_{\Pi_{N,S}}L_D(\operatorname{clip}z_w)\le L_D(g)+h_n+\eta+{\rm dev}_{\rm mf}+\frac\varepsilon8+\frac\varepsilon8 .$$

*Proof.* Let $G=\{w:\inf_{h\in\mathcal C}\sup_X\lvert z_w-h\rvert\le a\}$.

- **Exceptional mass.** By (I3) and Lemma 2.1(c) with $N^\gamma=N$, $\Pi(G^c)\le2L\exp(-N[\frac K{16}-A-\frac{n^\theta}2(U+2)^2])\le2Le^{-\ln(128L/\varepsilon)}=\varepsilon/64$.
- **Good parameters.** For $w\in G$ with $\hat L_S(z_w)\le\hat L_S(g)+\eta$, pick $h$ with $\sup_X\lvert z_w-h\rvert\le a$. Then (1.3) gives $L_D(\operatorname{clip}z_w)\le L_D(\operatorname{clip}h)+4a\le\hat L_S(\operatorname{clip}h)+{\rm dev}_{\rm mf}+4a\le\hat L_S(\operatorname{clip}z_w)+{\rm dev}_{\rm mf}+8a$. Continue as before; $8a=\varepsilon/8$.
- **Measurability.** The centres are Borel and fixed before sampling, and $G$ is Borel, as stated in `paper.tex` §2. $\square$

### 2.6 The theorem

**Theorem 2.7 (agnostic oracle inequality at finite scale, every width).** Fix $L=H+1\ge2$, $\gamma\ge1$ and $\theta\in(0,\theta_{L,\gamma})$, where
$$\theta_{2,\gamma}=1;\qquad\text{for }H\ge2:\quad\theta_{L,\gamma}=\begin{cases}\dfrac1H,&\gamma\ge2-\dfrac1H,\\[2mm]\max\Bigl\{\dfrac{\gamma-1}{\gamma H-1},\ \dfrac{\gamma-1}{H(H-1)(2-\gamma)}\Bigr\},&1<\gamma<2-\dfrac1H,\\[2mm]\dfrac1{4+16(L-2)3^{L-2}},&\gamma=1.\end{cases}$$
There is a polynomial $p=p_{L,\gamma,\theta}$ with the following property. Take any $d$, any compact $X\subseteq[-1,1]^d$, any law $D$ on $X\times[-1,1]$, any competitor $g$ (depth $L$, width $m$, weights in $[-B,B]$, $B\ge1$), any $\varepsilon,\delta\in(0,1)$, and any $n\ge p(d,m,B,1/\varepsilon,\ln(1/\delta))$. Let $c=n^{1-\theta}$. Then there is an event of probability at least $1-\delta$, not depending on $N$, on which **every** learner width $N\ge m$ satisfies
$$\mathbb E_{\Pi_{N,S}}L_D(\operatorname{clip}z_w)\le L_D(g)+\varepsilon\qquad\text{and}\qquad L_D\bigl(\mathbb E_{\Pi_{N,S}}\operatorname{clip}z_w\bigr)\le L_D(g)+\varepsilon .$$
The case $\gamma=1$, $L\ge3$ uses the imported mean-field cover (I3).

*Proof.* The second inequality follows from the first by Jensen's inequality for $u\mapsto(u-y)^2$ and Tonelli. Fix the sample events:

- $\mathcal E_H$;
- $\mathcal E_{\rm cap}(\bar K)$, with $\bar K$ chosen per case below;
- for $\gamma=1$, $\mathcal E_{\rm mf}$;
- for each $N\ge m$, the event of Lemma 2.2 with $\delta_N=\delta/(4N^2)$.

Since $\sum_N\delta/(4N^2)=\delta\pi^2/24<0.42\,\delta$, the intersection $\mathcal E$ of all these has probability at least $1-\delta/4-\delta/4-0.42\delta>1-\delta$. Cases I–II below use $\mathcal E_{\rm cap}$ and not $\mathcal E_{\rm mf}$; Case III uses $\mathcal E_{\rm mf}$ in place of $\mathcal E_{\rm cap}$, so at most one of the two is ever included. Everything below happens on $\mathcal E$.

**Arithmetic common to all regimes.** Impose
$$\text{(C1)}\ \ n\ge\frac{512(U+1)^4\ln(4/\delta)}{\varepsilon^2},\qquad\text{(C2)}\ \ n^\theta\ge\frac{16}\varepsilon\Bigl(A+\ln\frac{64}\varepsilon+\ln\frac4\delta+1\Bigr).$$
(C1) gives $h_n\le\varepsilon/8$ and $4\sqrt{\ln(4/\delta)/(2n)}\le\varepsilon/8$. (C2) gives $2n^{-\theta}(A+\ln\frac{64}\varepsilon)\le\varepsilon/8$, hence $\eta\le\frac\varepsilon8+\frac\varepsilon{256}+\frac\varepsilon8$. It also gives $2n^{-\theta}(A+\ln\frac4\delta+1)\le\varepsilon/4$.

**Each regime yields excess at most $\varepsilon$.**

- *Regimes E and T* (Lemmas 2.3 and 2.5). Impose
$$\text{(C3)}\qquad8\Bigl(\frac{\bar K}H\Bigr)^{H/2}\frac{D_n}{\sqrt n}\le\frac\varepsilon8 .$$
  Then $\Psi_n(\bar K,\delta/4)\le\varepsilon/4$, and the excess is at most $\frac\varepsilon8+(\frac\varepsilon4+\frac\varepsilon{256})+\frac\varepsilon4+\frac\varepsilon{16}+\frac\varepsilon8<0.82\,\varepsilon$.
- *Regime S* (Lemma 2.2 with $\delta_N$). Here $\ln(1/\delta_N)/N^\gamma=(\ln\frac4\delta+2\ln N)/N^\gamma\le\ln\frac4\delta+1$, because $2\ln N\le N\le N^\gamma$. If $N^\gamma n^{\theta-1}\le\varepsilon/4$, the excess is at most $h_n+\frac\varepsilon8+\frac\varepsilon{256}+\frac\varepsilon4+\frac\varepsilon4<0.76\,\varepsilon$.
- *Regime MF* (Lemma 2.6). Impose
$$\text{(C5)}\qquad n\ge\frac{512}{\varepsilon^2}\Bigl(H^{\rm mf}_L(d,K_{\rm MF},64/\varepsilon)+\ln\frac4\delta\Bigr).$$
  Then ${\rm dev}_{\rm mf}\le\varepsilon/8$, and the excess is at most $\frac\varepsilon8+(\frac\varepsilon4+\frac\varepsilon{256})+\frac\varepsilon8+\frac\varepsilon8+\frac\varepsilon8<0.76\,\varepsilon$.

It remains, in each case, to cover every width $N\ge m$ by a regime and to check that the conditions are polynomial.

**Case I: $H=1$, or $H\ge2$ and $\gamma\ge2$.**

- *Covering.* Take $K'=\bar K:=K_{\min}+3(d+H+1)$. By the remark after Lemma 2.3, (2.1) holds at every $N\ge m$, so regime E covers every width.
- *Polynomial.* Bound $\bar K\le C_In^\theta$ with $C_I:=8A+4(U+2)^2+8\ln\frac{64}\varepsilon+3(d+H+1)$. Set $e:=\frac{1-\theta H}2>0$; this uses $\theta<1/H$, or $\theta<1$ when $H=1$. Use $\ln(n+1)\le n^e/e$ for $n\ge1$; at $n=1$ this is $\ln2<1\le1/e$, and the derivative of the difference, $n^{e-1}-\frac1{n+1}$, is positive. Then $D_n\le\sqrt{2(d+1)/e}\,n^{e/2}+\frac{H-1}2$. So (C3) follows from the two polynomial conditions
$$n^{e/2}\ge\frac{128}\varepsilon\Bigl(\frac{C_I}H\Bigr)^{H/2}\sqrt{\frac{2(d+1)}e},\qquad n^{e}\ge\frac{64(H-1)}\varepsilon\Bigl(\frac{C_I}H\Bigr)^{H/2}.$$
- *Other conditions.* (C1) and (C2) are polynomial too, since $A$ is polynomial in $d,m,B,\ln\frac{U+1}\varepsilon$ by (I1).

**Case II: $H\ge2$, $1<\gamma<2$.** Put $K:=K_T$ and $T:=T(K_T)$ as in Lemma 2.5, and use regime T for all $N\ge\max\{m,T\}$. For the widths $m\le N<T$ there are two routes.

- *Route (i), regime S.* If $T^\gamma\le\varepsilon n^{1-\theta}/4$, then every $N<T$ has $N^\gamma n^{\theta-1}\le\varepsilon/4$. Take $\bar K=LK_T$.
- *Route (ii), regime E.* Take
$$K':=K_T+3(d+2)+3(H-1)T^{2-\gamma}\quad\text{and}\quad\bar K:=\max\{LK_T,K'\}.$$
  For $N<T$, $\frac{3P_N}{N^\gamma}\le3(d+2)+3(H-1)T^{2-\gamma}\le K'$, and $K'\ge K_{\min}$, so (2.1) holds.

*Polynomial.* With $C_{II}:=8A+4(U+2)^2+8\ln\frac{64L}\varepsilon+3(d+2)$ we have $K_T\le C_{II}n^\theta$, and, since $\lceil x\rceil\le2x$ for $x\ge1$,
$$T\le2\Bigl(\frac{896(H-1)C_{II}^{(H-1)/2}}\varepsilon\Bigr)^{2/(\gamma-1)}n^{\theta(H-1)/(\gamma-1)} .$$

- *Route (i).* The covering condition $T^\gamma\le\varepsilon n^{1-\theta}/4$ reads $n^{e_{\rm i}}\ge M_{\rm i}$, where $M_{\rm i}$ is polynomial in the resources and
$$e_{\rm i}=\frac{1-\theta}\gamma-\frac{\theta(H-1)}{\gamma-1}=\frac{\gamma-1-\theta(\gamma H-1)}{\gamma(\gamma-1)} .$$
  This is positive if and only if $\theta<\frac{\gamma-1}{\gamma H-1}$. Condition (C3) with $\bar K=LK_T\le LC_{II}n^\theta$ is handled as in Case I and needs $\theta<1/H$; this holds, since $\frac{\gamma-1}{\gamma H-1}<\frac1H$.
- *Route (ii).* $\bar K\le C'n^{\theta'}$ with $\theta'=\theta\max\{1,\frac{(H-1)(2-\gamma)}{\gamma-1}\}$ and $C'$ polynomial. Condition (C3) needs $\theta'H<1$, which is $\theta<\min\{\frac1H,\frac{\gamma-1}{H(H-1)(2-\gamma)}\}$.

One of the two routes applies whenever $\theta<\theta_{L,\gamma}$. If $\gamma\ge2-\frac1H$, then $\frac{\gamma-1}{H(H-1)(2-\gamma)}\ge\frac1H$, so route (ii) gives the full range $\theta<1/H$.

**Case III: $H\ge2$, $\gamma=1$.** Use regime MF for $N\ge T_{\rm mf}:=T_L(d,K_{\rm MF},64/\varepsilon)$ and regime S for $N<T_{\rm mf}$. That requires $T_{\rm mf}\le\varepsilon n^{1-\theta}/4$, and (C5).

- *Polynomial.* $K_{\rm MF}\le C_{III}n^\theta$ with $C_{III}$ polynomial. By (I3), $T_{\rm mf}\le{\rm poly}\cdot n^{\theta D_T}({\rm polylog}\,n)$ and $H^{\rm mf}_L\le{\rm poly}\cdot n^{\theta D_H}({\rm polylog}\,n)$. The two conditions are $n^{1-\theta-\theta D_T}\ge{\rm poly}\cdot{\rm polylog}(n)$ and $n^{1-\theta D_H}\ge{\rm poly}\cdot{\rm polylog}(n)$.
- *Exponent.* Both exponents are positive when $\theta<\min\{\frac1{D_T+1},\frac1{D_H}\}=\frac1{D_H}=\frac1{4+16(L-2)3^{L-2}}$; for $L\ge3$, $D_H=4+16(L-2)3^{L-2}\ge12\cdot3^{L-2}+1=D_T+1$.

**Polylogarithmic factors.** In every case the conditions have the form $n^{e}\ge M(1+\ln n)^q$, with $e>0$ and $q\ge0$ depending only on $(L,\gamma,\theta)$, and $M$ polynomial in $(d,m,B,1/\varepsilon,\ln\frac1\delta)$. Since $(1+\ln n)^q\le C_{q,e}n^{e/2}$ for all $n\ge1$, the threshold $n\ge(C_{q,e}M)^{2/e}$ suffices. The maximum of these thresholds is the polynomial $p$. $\square$

**Remark 2.8 (rate).** In Case I the proof gives, for every $n$, on $\mathcal E$ and for every $N\ge m$, with free $\rho\in(0,1]$ and target mass $\epsilon_0\in(0,1)$ in place of $\varepsilon/64$,
$$\mathbb E_\Pi L_D(\operatorname{clip}z_w)-L_D(g)\le h_n+2\rho(U+1)+\rho^2+2n^{-\theta}\bigl(A_L(\rho)+\ln\tfrac1{\epsilon_0}\bigr)+\Psi_n(\bar K,\tfrac\delta4)+8\epsilon_0 .$$
Here $\bar K=8A_L(\rho)+4n^\theta(U+2)^2+8\ln\frac1{\epsilon_0}+3(d+H+1)$. With $\rho=\epsilon_0=n^{-\theta}$ this is $\tilde O\bigl({\rm poly}(d,m,B)\,n^{-\min\{\theta,(1-\theta H)/2\}}\bigr)$. At $\theta=\frac1{H+2}$ the rate is $\tilde O(n^{-1/(H+2)})$, the strong-prior rate of B Theorem 6.3. Only the logarithmic factor from $A_L(\rho)$ is new.

**Remark 2.9 (scope).**

- (a) The guarantees concern clipped predictions. Unclipped outputs would need posterior moment bounds on $\kappa^{(L)}$, and regime S would need a PAC-Bayes bound for unbounded loss. I have not done this.
- (b) In regimes E, T and MF the proof gives more than a Gibbs bound: the posterior mass of $\{w:L_D(\operatorname{clip}z_w)>L_D(g)+0.7\varepsilon\}$ is at most $\varepsilon/32$. Regime S gives only the Gibbs bound.
- (c) The event in Theorem 2.7 depends on $(D,g,n,\varepsilon,\delta)$ but not on $N$, as in B Theorem 6.3.

### 2.7 Where the clean-label proof breaks, and what replaces it

The slt-likelihood note (§2, "Finite scales") takes the tube radius $\rho=n^{-1/2}$, so that the residual sum on the teacher tube is at most $1$ and $Z_S\ge e^{-N^\gamma(A+1/2)}$. It then uses the spectral-truncation or mean-field cover with $K=O(A+\log\frac1\varepsilon)$, and the clean small-width argument below the cover threshold $T$. Three things change with noisy labels.

1. **The normaliser carries the competitor's residual.** Every function, the competitor included, has $R_S\approx nL_D(g)=\Theta(n)$. So $Z$ in Lemma 2.1 includes $e^{-\Lambda\hat L_S(g)}$, with $\Lambda=N^\gamma n/(2c)$.
   - At $c=1$, the uncovered prior mass $e^{-N^\gamma K/8}$ is negligible only if $K\gtrsim4n(U+2)^2$. At that energy no width-free capacity bound is $o(1)$; the Rademacher term $(K/H)^{H/2}D_n/\sqrt n$ is $\Omega(\sqrt{\log n})$ for $H=1$ and grows like $n^{(H-1)/2}$ for $H\ge2$. For $L\ge3$ the conclusion itself is false (Section 5).
   - With $c=n^{1-\theta}$, the budget is $K\asymp n^\theta$, and the capacity term is $o(1)$ if and only if $\theta<1/H$ (I2).
   - The repository's own energy cover would only give $\theta<1/(4(L-1))$ (../research-notes/B-tempered-likelihood.md Lemma 4.2).
2. **The cover threshold now grows with $n$.**
   - For $\gamma>1$, $T(K)\asymp(K^{H-1}/\varepsilon^2)^{1/(\gamma-1)}\asymp n^{\theta(H-1)/(\gamma-1)}$.
   - At $\gamma=1$, $T_L\asymp K^{D_T}$.
   - The clean small-width cost $T^\gamma(A+\frac12)\ll n$ is then no longer automatic.
3. **The clean small-width argument has no agnostic analogue.** It bounds the expected likelihood of a parameter with test tail risk $>r$ by $e^{-nc_\tau r}$; this uses $y=f(x)$. Its replacement, Lemma 2.2, pays a variance term $N^\gamma n^{\theta-1}$, so it covers $N^\gamma\lesssim\varepsilon n^{1-\theta}$.
   - A second bridge is new. For $\gamma<2$ the prior's internal energy is $N^{2-\gamma}$, so plain energy control (Lemma 2.3) covers $N^{2-\gamma}\lesssim n^{1/H}$.
   - The two bridges meet the truncation threshold exactly when $\theta<\theta_{L,\gamma}$.
   - At $\gamma\ge2$ no bridge is needed: energy control works at every width, as the prior energy $N^{2-\gamma}$ stays bounded.

The gap for $1\le\gamma<2-\frac1H$ comes from bounding the effect of the bulk of the internal matrices by its operator norm times the worst-case amplification $K^{(H-1)/2}$ (Lemma 2.4, step 6). I see no reason for it to be real (§6).

---

## 3. A Laplace lower bound at large width ($\gamma>1$)

For $\gamma>1$ the prior's fluctuations shrink in function space like $\tau_N=N^{(1-\gamma)/2}$. A typical prior perturbation of a fixed network therefore barely changes its outputs, and the translation inequality (G2) charges only the energy. The next lemma makes this precise. It needs no cylinder event and has no entropy term.

**Lemma 3.1.** Let $\gamma>1$, $L=H+1\ge2$, $t_L:=\sqrt{2\ln(2L)}$ and $N\ge(\sqrt{d+1}+t_L)^2$. Let $w_0\in\mathcal W_N$, $K_0:=\max\{1,\kappa_N(w_0)\}$ and $a'>0$. If
$$N^{(\gamma-1)/2}\ \ge\ \frac{(3H+2)K_0^{H/2}}{a'},$$
then
$$\mu_{N,\gamma}\Bigl\{w:\sup_{x\in[-1,1]^d}\lvert z_w(x)-z_{w_0}(x)\rvert\le a'\Bigr\}\ \ge\ \tfrac12\exp\bigl(-N^\gamma\kappa_N(w_0)/2\bigr).$$

*Proof.*

1. **The perturbation and a typical event.** Write $w=w_0+D_N\xi$ and split $\xi=(\xi^1,Z^2,\dots,Z^H,\zeta)$ into blocks. So $W^1=W^1_0+\frac\tau{\sqrt d}\xi^1$, $W^\ell=W^\ell_0+\frac\tau{\sqrt N}Z^\ell$ and $v=v_0+\frac\tau N\zeta$. Let
$$E=\bigl\{\lVert\xi^1\rVert_{\rm op}\le\sqrt N+\sqrt{d+1}+t_L,\ \lVert Z^\ell\rVert_{\rm op}\le2\sqrt N+t_L\ (2\le\ell\le H),\ \lvert\zeta\rvert\le\sqrt N+t_L\bigr\}.$$
   $E$ is symmetric. By (G3), each of its $L$ defining conditions fails with probability at most $e^{-t_L^2/2}=\frac1{2L}$, so $\gamma_P(E)\ge\frac12$.
2. **Perturbation sizes on $E$.** The hypothesis on $N$ gives $\sqrt{d+1}+t_L\le\sqrt N$. So $\lVert\xi^1\rVert_{\rm op}\le2\sqrt N$, $\lVert Z^\ell\rVert_{\rm op}\le3\sqrt N$ and $\lvert\zeta\rvert\le2\sqrt N$.
3. **Error recursion.** Let $e_\ell=N^{-1/2}\lVert h^\ell(x)-h^\ell_0(x)\rVert$, with $h_0$ the activations of $w_0$, and $x\in[-1,1]^d$, so $\lvert\bar x\rvert\le\sqrt{d+1}$. Tanh is 1-Lipschitz coordinatewise, and (1.1) gives $\lVert W^\ell_0\rVert_{\rm op}\le\sqrt{\kappa^{(\ell)}(w_0)}\le\sqrt{K_0}$. Hence
$$e_1\le\frac{\tau\lVert\xi^1\rVert_{\rm op}\sqrt{d+1}}{\sqrt d\sqrt N}\le2\sqrt2\,\tau,\qquad e_\ell\le\sqrt{K_0}\,e_{\ell-1}+\frac\tau{\sqrt N}\lVert Z^\ell\rVert_{\rm op}\le\sqrt{K_0}\,e_{\ell-1}+3\tau .$$
4. **Output error.** Since $z_w-z_{w_0}=v_0^\top(h^H-h^H_0)+(v-v_0)^\top h^H$, $\sqrt N\lVert v_0\rVert=\sqrt{\kappa^{(L)}(w_0)}$ and $\lVert h^H\rVert\le\sqrt N$,
$$\lvert z_w-z_{w_0}\rvert\le\sqrt{K_0}\,e_H+\frac\tau{\sqrt N}\lvert\zeta\rvert\le\tau\Bigl[2\sqrt2K_0^{H/2}+3\sum_{j=1}^{H-1}K_0^{j/2}+2\Bigr]\le(3H+2)K_0^{H/2}\,\tau .$$
   Here $2\sqrt2+3(H-1)+2\le3H+2$ and $K_0\ge1$. So $w_0+D_NE$ lies in the set in question.
5. **Translation.** By (1.2) and (G2) with $a=D_N^{-1}w_0$, its prior mass is $\gamma_P(D_N^{-1}w_0+E)\ge\frac12e^{-\lvert D_N^{-1}w_0\rvert^2/2}=\frac12e^{-N^\gamma\kappa_N(w_0)/2}$. $\square$

**Consequences.**

- *Centred at a clone of $g$.* With $a'=\rho/2$ and $\kappa_N(w^g_N)\le E_*$ (here $E_*\ge1$), this gives $\mu_{N,\gamma}(U_\rho(g))\ge\frac12e^{-N^\gamma E_*/2}$ once $N\ge(\sqrt{d+1}+t_L)^2$ and $N^{(\gamma-1)/2}\ge2(3H+2)E_*^{H/2}/\rho$. That is a large-width improvement of the constant $A_L$ in (I1), from $\frac12E_*+O(d+m)\ln\frac1\rho$ to $\frac12E_*+N^{-\gamma}\ln2$.
- *Centred at the memoriser of ../research-notes/A-tight-conditioning-fails.md Lemma 2.1.* This proves Claim A at every $\gamma>1$ along the lines of Section 5. The width threshold is $N\ge\bigl((3H+2)K_{\rm mem}^{H/2}/a'\bigr)^{2/(\gamma-1)}$, a polynomial in $n$ whose degree blows up as $\gamma\downarrow1$.
- *Mean field.* At $\gamma=1$, $\tau_N=1$ and Lemma 3.1 says nothing: the prior's noise is of order one in function space. Section 4 handles all $\gamma\ge1$ at once, with a width threshold independent of $\gamma$, by choosing a centre built for that noise.

The red-team sketch for $\gamma>1$ (`../research-notes/red-team.md` §8) pins a cylinder of $N(d+m_0+H)$ coordinates around the memoriser and pays $N(d+m_0+H)\ln\frac1\eta$. Lemma 3.1 shows that no pinning is needed when $\gamma>1$. At $\gamma=1$ pinning is unaffordable, because $m_0\gtrsim n$; Section 4 avoids it.

---

## 4. A memoriser that survives the prior's noise, at every $\gamma\ge1$

**The obstacle at mean field, and how a centre avoids it.** At $\gamma=1$ every hidden preactivation of a translated prior draw $w_0+D_N\xi$ carries Gaussian noise of order one. The first layer receives $\frac1{\sqrt d}\xi^1_j\cdot\bar x$. A later layer receives $\frac1{\sqrt N}\sum_jZ_{kj}h_j$, which has variance $\frac1N\lvert h\rvert^2$. Pinning these coordinates costs $\Theta(N)$ per pinned direction. A memoriser has $\gtrsim n$ distinct feature types, so pinning costs $\Theta(Nn)$, which is as large as the likelihood gain. No pinning is needed, however. The next layer, or the readout, averages over $N$ neurons with coherent weights. By the law of large numbers it then sees the **Gaussian-smoothed** activation $u\mapsto\mathbb E\tanh(u+\text{noise})$, which is a deterministic odd sigmoid. A centre designed for the smoothed activations, including a pre-compensation of the slope loss, computes the target under a typical draw of the prior's noise. The translation inequality then charges only its energy.

### 4.1 Smoothed activations

Let $G\sim\mathcal N(0,1)$. For $q\ge0$ and $u\in\mathbb R$ put
$$\psi_q(u)=\mathbb E\tanh(u+\sqrt qG),\qquad\varpi(q)=\psi_q'(0)=\mathbb E\,{\rm sech}^2(\sqrt qG),\qquad\Upsilon(u,q)=\mathbb E\tanh^2(u+\sqrt qG),\qquad F(q)=\Upsilon(0,q).$$

**Lemma 4.1.** For all $q,q'\in[0,1]$ and $u\in\mathbb R$:

- (a) $\psi_q$ is odd and nondecreasing, with $\lvert\psi_q\rvert\le1$, and $\lvert\psi_q(u)-\varpi(q)u\rvert\le\lvert u\rvert^3/3$.
- (b) $\lvert\varpi(q)-\varpi(q')\rvert\le\lvert q-q'\rvert$, and $\varpi(q)\ge(1+2q)^{-1/2}\ge3^{-1/2}$.
- (c) $0\le\Upsilon\le1$, $\lvert\Upsilon(u,q)-F(q)\rvert\le u^2$, and $\lvert F(q)-F(q')\rvert\le\lvert q-q'\rvert$.

*Proof.* The derivatives used are $\tanh'''=-2\,{\rm sech}^2(1-3\tanh^2)$, $({\rm sech}^2)''=2\,{\rm sech}^2(3\tanh^2-1)$ and $(\tanh^2)''=2\,{\rm sech}^2(1-3\tanh^2)$. Each has absolute value at most $2\max_{t\in[0,1]}(1-t)\lvert1-3t\rvert=2$ (`check_symbolic.py`).

- **(a)** Oddness and monotonicity hold because $G$ is symmetric and tanh is odd and increasing. Differentiation under $\mathbb E$ is dominated, so $\psi_q'''=\mathbb E\tanh'''(u+\sqrt qG)$ is bounded by 2. Also $\psi_q''(0)=0$ by oddness. Taylor's theorem gives $\lvert\psi_q(u)-\varpi(q)u\rvert\le2\lvert u\rvert^3/6$.
- **(b) Lipschitz bound.** For $f\in C^2_b$ and $q>0$, $\frac d{dq}\mathbb Ef(\sqrt qG)=\mathbb E[f'(\sqrt qG)G]/(2\sqrt q)=\frac12\mathbb Ef''(\sqrt qG)$ by Gaussian integration by parts. With $f={\rm sech}^2$, $\lvert\varpi'\rvert\le1$ on $(0,1]$, and $\varpi$ is continuous at $0$.
- **(b) Lower bound.** $\cosh y\le e^{y^2/2}$, by comparing Taylor coefficients, $(2k)!\ge2^kk!$. So ${\rm sech}^2y\ge e^{-y^2}$, and $\mathbb Ee^{-qG^2}=(1+2q)^{-1/2}$.
- **(c)** $\Upsilon(\cdot,q)$ is even, since $\tanh^2$ is even and $G$ symmetric, and $\lvert\partial_u^2\Upsilon\rvert\le\sup\lvert(\tanh^2)''\rvert\le2$. Hence $\lvert\Upsilon(u,q)-\Upsilon(0,q)\rvert\le u^2$. The $q$-derivative of $F$ is $\frac12\mathbb E(\tanh^2)''(\sqrt qG)$, bounded by $1$. $\square$

For $\tau\in(0,1]$ define the reference sequence
$$q^*_1=1,\qquad q^*_{\ell+1}=F(\tau^2q^*_\ell),\qquad\varpi^*_\ell=\varpi(\tau^2q^*_\ell),\qquad\Pi_*=\Pi_*(\tau,H)=\prod_{\ell=1}^{H-1}\varpi^*_\ell .$$
By Lemma 4.1(b), $\Pi_*\ge\Pi_{\min}:=3^{-(H-1)/2}$. Numerically, $\Pi_*(1,2)=\mathbb E\,{\rm sech}^2G=0.6057$ and $\Pi_*(1,3)=0.4625$ (`check_constants.py`).

### 4.2 Parity features under input noise

On the cube $\mathcal C_d=\{-1,1\}^d$, $\lvert\bar x\rvert^2=d+1$. A first-layer noise term $\frac\tau{\sqrt d}\nu\cdot\bar x$ with $\nu\sim\mathcal N(0,I_{d+1})$ is therefore $\mathcal N(0,\tau^2\tau_d^2)$ at every $x$, where $\tau_d^2:=\frac{d+1}d\le2$. Put
$$\phi(u):=\psi_{\tau^2\tau_d^2}(u)=\mathbb E\tanh(u+\tau\tau_dG).$$
Let $b_k=1$ for even $k$ and $b_k=0$ for odd $k$, $\alpha_d=\frac12\ln(4\sqrt{2d})$, and $c_{k,\infty}$ as in ../research-notes/A-tight-conditioning-fails.md Lemma 2.2.

**Lemma 4.2.** Let $\tau\in(0,1]$ and $\alpha\ge2+\alpha_d$. For $k\ge1$ put $c^\phi_k:=2^{-k}\sum_{v\in\{\pm1\}^k}(\prod_jv_j)\,\phi(\alpha(\sum_jv_j-b_k))$.

- (a) For $S\subseteq[d]$ with $\lvert S\rvert=k\ge1$ and $x\in\mathcal C_d$: $2^{-k}\sum_{u\in\{\pm1\}^S}(\prod_{j\in S}u_j)\,\phi(\alpha(\sum_{j\in S}u_jx_j-b_k))=c^\phi_k\chi_S(x)$.
- (b) $\lvert c^\phi_k\rvert\ge(2\sqrt{2k})^{-1}$ for $1\le k\le d$, and $\phi(\alpha)\ge1-(2\sqrt{2d})^{-1}$.
- (c) If $\omega\in\mathbb R^{d+1}$ satisfies $\lvert\omega\cdot\bar x\rvert\ge\alpha$ on $\mathcal C_d$, then $1-\mathbb E\tanh^2(\omega\cdot\bar x+\tau\tau_dG)\le8e^{4-2\alpha}$ on $\mathcal C_d$.

*Proof.*

- **(a)** The map $u\mapsto(u_jx_j)_{j\in S}$ is a bijection of $\{\pm1\}^S$ that turns $\prod u_j$ into $\chi_S(x)\prod v_j$. This is the proof of ../research-notes/A-tight-conditioning-fails.md Lemma 2.2(e), with $\phi$ in place of $\tanh(\alpha\,\cdot)$; it uses no property of $\phi$.
- **(b) Saturation.** Since $1-\tanh y=\frac2{1+e^{2y}}\le2e^{-2y}$,
$$1-\phi(\alpha)\le2e^{-2\alpha}\mathbb Ee^{-2\tau\tau_dG}=2e^{-2\alpha+2\tau^2\tau_d^2}\le2e^{4-2\alpha}\le2e^{-2\alpha_d}=(2\sqrt{2d})^{-1} .$$
- **(b) Coefficients.** Every $t=\sum_jv_j-b_k$ is an odd integer, and $\phi$ is odd and nondecreasing. So $\lvert\phi(\alpha t)-{\rm sign}(t)\rvert\le1-\phi(\alpha)$, and $\lvert c^\phi_k-c_{k,\infty}\rvert\le1-\phi(\alpha)$. With $\lvert c_{k,\infty}\rvert\ge(2k)^{-1/2}$ (I4) and $k\le d$, $\lvert c^\phi_k\rvert\ge(2k)^{-1/2}-(2\sqrt{2d})^{-1}\ge(2\sqrt{2k})^{-1}$.
- **(c)** ${\rm sech}^2y\le4e^{-2\lvert y\rvert}$, and $\mathbb Ee^{2\tau\tau_d\lvert G\rvert}\le2e^{2\tau^2\tau_d^2}\le2e^4$. So $\mathbb E\,{\rm sech}^2(\omega\cdot\bar x+\tau\tau_dG)\le4e^{-2\alpha}\cdot2e^4$. $\square$

### 4.3 The noisy chain

**Lemma 4.3 (noisy chain).** Let $H\ge2$, $\tau\in(0,1]$, $R\ge2$, $\bar S\ge1$ and $S\in[-\bar S,\bar S]$. Let $u_0\ge0$ and $\varphi\ge0$. Suppose the real numbers $q_1,\dots,q_{H-1}\in[0,1]$ and $\bar h^2,\dots,\bar h^H$ satisfy
$$\lvert q_1-1\rvert\le\varphi;\qquad\bigl\lvert\bar h^\ell-\psi_{\tau^2q_{\ell-1}}(u_\ell)\bigr\rvert\le u_0\ (2\le\ell\le H);\qquad\bigl\lvert q_\ell-\Upsilon(u_\ell,\tau^2q_{\ell-1})\bigr\rvert\le u_0\ (2\le\ell\le H-1),$$
where $u_2:=S/R^{H-1}$ and $u_\ell:=R\bar h^{\ell-1}$ for $3\le\ell\le H$. Put
$$\bar f:=\varphi+H\Bigl(u_0+\frac{4\bar S^2}{R^2}\Bigr),\qquad\Xi:=2R^{H-1}u_0+2H\bar S\bar f+\frac{16\bar S^3}{3R^2}.$$
If $\Xi\le1$, then $\lvert R\bar h^H-\Pi_*S\rvert\le\Xi$.

*Proof.*

1. **Reference chain.** Let $\tilde u_2=S/R^{H-1}$ and $\tilde u_{\ell+1}=R\varpi^*_{\ell-1}\tilde u_\ell$ for $2\le\ell\le H$. Then $\tilde u_{H+1}=\Pi_*S$, and $\lvert\tilde u_\ell\rvert\le\bar SR^{-(H+1-\ell)}$ because $\varpi^*\le1$.
2. **Errors.** Put $u_{H+1}:=R\bar h^H$, $e_\ell:=\lvert u_\ell-\tilde u_\ell\rvert$ for $2\le\ell\le H+1$ (so $e_2=0$), and $f_\ell:=\lvert q_\ell-q^*_\ell\rvert$ for $1\le\ell\le H-1$.
3. **Claim.** For $2\le\ell\le H+1$, $E_\ell:=R^{H+1-\ell}e_\ell\le\Xi$. We use induction on $\ell$. The case $\ell=2$ is trivial.
4. **A priori size.** Assume $E_j\le\Xi\le1$ for $j\le\ell\le H$. Then $\lvert u_j\rvert\le(\bar S+1)R^{-(H+1-j)}\le2\bar SR^{-(H+1-j)}\le2\bar S/R$ for $2\le j\le\ell$.
5. **$q$-errors.** For $2\le j\le\min(\ell,H-1)$, Lemma 4.1(c) gives
$$q_j-q^*_j=\bigl[q_j-\Upsilon(u_j,\tau^2q_{j-1})\bigr]+\bigl[\Upsilon(u_j,\tau^2q_{j-1})-F(\tau^2q_{j-1})\bigr]+\bigl[F(\tau^2q_{j-1})-F(\tau^2q^*_{j-1})\bigr],$$
   and so $f_j\le u_0+u_j^2+f_{j-1}$, because $\lvert F(\tau^2q)-F(\tau^2q')\rvert\le\tau^2\lvert q-q'\rvert$. Therefore $f_j\le\varphi+(j-1)(u_0+4\bar S^2/R^2)\le\bar f$.
6. **$u$-errors.** Since $u_{\ell+1}=R\bar h^\ell$,
$$u_{\ell+1}-\tilde u_{\ell+1}=R\bigl[\bar h^\ell-\psi_{\tau^2q_{\ell-1}}(u_\ell)\bigr]+R\bigl[\psi_{\tau^2q_{\ell-1}}(u_\ell)-\varpi(\tau^2q_{\ell-1})u_\ell\bigr]+R\bigl[\varpi(\tau^2q_{\ell-1})-\varpi^*_{\ell-1}\bigr]u_\ell+R\varpi^*_{\ell-1}(u_\ell-\tilde u_\ell).$$
   By Lemma 4.1(a),(b) and $\tau\le1$, $e_{\ell+1}\le R\bigl[u_0+\lvert u_\ell\rvert^3/3+f_{\ell-1}\lvert u_\ell\rvert\bigr]+Re_\ell$.
7. **Telescoping.** Multiply by $R^{H-\ell}$ and use step 4:
$$E_{\ell+1}\le E_\ell+R^{H+1-\ell}u_0+2\bar S\bar f+\frac{8\bar S^3}3R^{-2(H+1-\ell)} .$$
   Summing from $2$ to $\ell$ gives
$$E_{\ell+1}\le u_0\sum_{j=1}^{H-1}R^j+2(H-1)\bar S\bar f+\frac{8\bar S^3}3\sum_{j\ge1}R^{-2j}\le\Xi .$$
   Here $\sum_{j=1}^{H-1}R^j\le2R^{H-1}$ and $\sum_{j\ge1}R^{-2j}\le2/R^2$, because $R\ge2$. This completes the induction.
8. **Conclusion.** The case $\ell+1=H+1$ is $\lvert R\bar h^H-\Pi_*S\rvert=e_{H+1}=E_{H+1}\le\Xi$. $\square$

`check_constants.py` checks the constants of Lemma 4.1 and the $q$-recursion numerically.

### 4.4 The robust memoriser

**Proposition 4.4.** Let $H\ge2$, $d\ge1$, $s>0$ and $a\in(0,1]$. Put
$$\bar S:=3^{(H-1)/2}+\tfrac14,\qquad\mathcal A_{\max}:=2\sqrt{2ds}\;3^{(H-1)/2},\qquad\alpha:=2+\max\Bigl\{\alpha_d,\ \tfrac12\ln\frac{256H\bar S}a\Bigr\},$$
$$R:=\max\Bigl\{\mathcal A_{\max}^{1/H},\ \Bigl(\frac{128H^2\bar S^3}a\Bigr)^{1/2},\ 2\Bigr\},\qquad K_{\rm rob}(d,s,a,H):=d(d+1)\alpha^2+(H+1)R^2,$$
$$u_0:=\min\Bigl\{\frac a{16R^{H-1}},\frac a{32H^2\bar S}\Bigr\},\qquad\ell_d:=(d+1)\ln2+\ln(8H),\qquad m_{\rm f}:=\Bigl\lfloor\frac{128\ln2\,\mathcal A_{\max}^2(d+1)}{a^2}\Bigr\rfloor+1,$$
$$N_*(d,s,a,H):=\max\Bigl\{m_{\rm f},\ \frac{256\mathcal A_{\max}^2\ell_d}{a^2},\ \frac{512H^2\bar S^2\ell_d}{a^2},\ \frac{2\ell_d}{u_0^2}\Bigr\}.$$
Then for **every** $\gamma\ge1$, every $r:\mathcal C_d\to[-1,1]$ with $\sum_xr(x)^2\le s$, and every width $N\ge N_*$,
$$\mu_{N,\gamma}\Bigl\{w\in\mathcal W_N:\max_{x\in\mathcal C_d}\lvert z_w(x)-r(x)\rvert\le a\Bigr\}\ \ge\ \tfrac12\exp\bigl(-N^\gamma K_{\rm rob}(d,s,a,H)/2\bigr).$$

**Sizes.** $K_{\rm rob}=O_H\bigl(d^2\log^2\frac da+(ds)^{1/H}+\frac1a\bigr)$, independent of $N$ and $\gamma$. $N_*={\rm poly}(d,s,1/a)$ at fixed $H$, independent of $\gamma$; for example $N_*=O_H\bigl(d^2s/a^2+d\,R^{2H-2}/a^2\bigr)$.

*Proof.* Fix $\gamma\ge1$ and $N\ge N_*$, and put $\tau=N^{(1-\gamma)/2}\in(0,1]$. Let $\Pi_*=\Pi_*(\tau,H)\ge3^{-(H-1)/2}$ and $\tilde r:=r/\Pi_*$. Then $\lvert\tilde r\rvert\le3^{(H-1)/2}$ and $\sum_x\tilde r(x)^2\le s/\Pi_*^2$.

*Step 1 (exact expansion in smoothed features).*

- *Features.* For $S\ne\emptyset$ and $u\in\{\pm1\}^S$, let $\omega_{S,u}\in\mathbb R^{d+1}$ have $(\omega)_0=-\alpha b_{\lvert S\rvert}$, $(\omega)_j=\alpha u_j$ for $j\in S$, and $0$ otherwise. Let $\omega_\emptyset=\alpha e_0$.
- *Expansion.* By Lemma 4.2(a), on $\mathcal C_d$,
$$\tilde r=\frac{\hat{\tilde r}(\emptyset)}{\phi(\alpha)}\phi(\omega_\emptyset\cdot\bar x)+\sum_{S\ne\emptyset}\frac{\hat{\tilde r}(S)}{c^\phi_{\lvert S\rvert}}2^{-\lvert S\rvert}\sum_u\Bigl(\prod_{j\in S}u_j\Bigr)\phi(\omega_{S,u}\cdot\bar x)=:\sum_{j\in\mathcal J}\gamma_j\phi(\omega_j\cdot\bar x).$$
- *Amplitude.* By Lemma 4.2(b), $1/\lvert c^\phi_k\rvert\le2\sqrt{2d}$ and $1/\phi(\alpha)\le(1-\frac1{2\sqrt2})^{-1}<2\sqrt{2d}$. With the Fourier $\ell^1$ bound (I4),
$$\mathcal A:=\sum_j\lvert\gamma_j\rvert\le2\sqrt{2d}\Bigl(\sum_x\tilde r(x)^2\Bigr)^{1/2}\le\frac{2\sqrt{2ds}}{\Pi_*}\le\mathcal A_{\max}.$$
- *Rows.* Every row has $\lvert\omega_j\rvert^2\le(d+1)\alpha^2$, and $\lvert\omega_j\cdot\bar x\rvert\ge\alpha$ on $\mathcal C_d$, because $\sum_{j\in S}u_jx_j-b_k$ is an odd integer.

If $\mathcal A=0$ then $r\equiv0$ on $\mathcal C_d$. Take $w_0=0$; then $z_w=\frac\tau N\zeta\cdot h^H$, and the event $E_{\rm out}$ of Step 5 alone gives $\max_{\mathcal C_d}\lvert z_w\rvert\le a/8$ with probability at least $1-\frac1{8H}\ge\frac34$. Its failure bound does not use the structure of $w_0$. Steps 6–7 then conclude with $\kappa_N(0)=0$. Assume $\mathcal A>0$ from now on.

*Step 2 (sampling).* Draw $J_1,\dots,J_{m_{\rm f}}$ i.i.d. with $\Pr(J=j)=\lvert\gamma_j\rvert/\mathcal A$. Put $\omega_t={\rm sgn}(\gamma_{J_t})\omega_{J_t}$; signs pass through $\phi$ because $\phi$ is odd. Let $g_\phi:=\frac{\mathcal A}{m_{\rm f}}\sum_t\phi(\omega_t\cdot\bar x)$. Then $\mathbb E g_\phi=\tilde r$ on $\mathcal C_d$, and the summands lie in intervals of length $2\mathcal A/m_{\rm f}$. Hoeffding and a union bound give
$$\Pr\bigl(\max_{\mathcal C_d}\lvert g_\phi-\tilde r\rvert>a/8\bigr)\le2^{d+1}e^{-a^2m_{\rm f}/(128\mathcal A^2)}<1 .$$
Fix a realisation with $\max_{\mathcal C_d}\lvert g_\phi-\tilde r\rvert\le a/8$, and write $m:=m_{\rm f}$.

*Step 3 (the centre $w_0$ at width $N\ge m$).*

- *Groups.* Partition $[N]$ into groups $G_1,\dots,G_m$ of sizes $k_t\in\{\lfloor N/m\rfloor,\lceil N/m\rceil\}$, so $k_t\ge N/(2m)$. Let $t(j)$ be the group of neuron $j$, and $c_j:=\mathcal A/(mk_{t(j)})$.
- *Weights.* $W^1_0$ has row $\omega_{t(j)}$ at neuron $j$. Every row of $W^2_0$ equals $(c_j/R^{H-1})_j$. $W^\ell_0=\frac RN\mathbf 1\mathbf 1^\top$ for $3\le\ell\le H$, and $v_0=\frac RN\mathbf 1$.
- *Energy.* $\sum_jc_j^2=\frac{\mathcal A^2}{m^2}\sum_t\frac1{k_t}\le\frac{2\mathcal A^2}N$, so
$$\kappa_N(w_0)\le d(d+1)\alpha^2+\frac{2\mathcal A^2}{R^{2H-2}}+(H-2)R^2+R^2\le d(d+1)\alpha^2+(H+1)R^2=K_{\rm rob},$$
  using $R^{2H}\ge\mathcal A_{\max}^2\ge\mathcal A^2$.

*Step 4 (the perturbed network).* Let $w=w_0+D_N\xi$ with $\xi=(\nu,Z^2,\dots,Z^H,\zeta)$. Here $\nu\in\mathbb R^{N\times(d+1)}$ has rows $\nu_j$. Fix $x\in\mathcal C_d$ and define:
$$h^1_j=\tanh\bigl(\omega_{t(j)}\cdot\bar x+\tfrac\tau{\sqrt d}\nu_j\cdot\bar x\bigr),\qquad S(x)=\sum_jc_jh^1_j,\qquad q_1(x)=\frac1N\lvert h^1\rvert^2 .$$
For $2\le\ell\le H$ the preactivation of neuron $k$ is $u_\ell+\varepsilon^\ell_k$, where
$$u_2=\frac S{R^{H-1}},\quad u_\ell=R\bar h^{\ell-1}\ (\ell\ge3),\qquad\varepsilon^\ell_k=\frac\tau{\sqrt N}Z^\ell_k\cdot h^{\ell-1},$$
since the rows of $W^\ell_0$ are constant. Put $h^\ell_k=\tanh(u_\ell+\varepsilon^\ell_k)$, $\bar h^\ell=\frac1N\sum_kh^\ell_k$ and $q_\ell=\frac1N\lvert h^\ell\rvert^2$. Finally
$$z_w(x)=\sum_k\Bigl(\frac RN+\frac\tau N\zeta_k\Bigr)h^H_k=R\bar h^H+\frac\tau N\zeta\cdot h^H .$$
Let $\mathcal F_\ell=\sigma(\nu,Z^2,\dots,Z^\ell)$. Given $\mathcal F_{\ell-1}$, the rows $Z^\ell_k$ are i.i.d. $\mathcal N(0,I_N)$, so the $\varepsilon^\ell_k(x)$ are i.i.d. $\mathcal N(0,\tau^2q_{\ell-1}(x))$ over $k$. Consequently
$$\mathbb E[h^\ell_k(x)\mid\mathcal F_{\ell-1}]=\psi_{\tau^2q_{\ell-1}(x)}(u_\ell(x)),\qquad\mathbb E[h^\ell_k(x)^2\mid\mathcal F_{\ell-1}]=\Upsilon\bigl(u_\ell(x),\tau^2q_{\ell-1}(x)\bigr).$$
Also, $\mathbb E\,h^1_j(x)=\phi(\omega_{t(j)}\cdot\bar x)$, so $\mathbb ES(x)=g_\phi(x)$; and $\mathbb Eq_1(x)\in[1-8e^{4-2\alpha},1]$ by Lemma 4.2(c).

*Step 5 (a typical event of probability $\ge3/4$).* Let $E$ be the intersection of the following $2H$ events, each holding for all $x\in\mathcal C_d$:

| event | condition | failure probability, by | requirement on $N$ |
|---|---|---|---|
| $E_S$ | $\lvert S-g_\phi\rvert\le a/8$ | Hoeffding over $j$: terms in intervals of length $2c_j$, and $\sum_j(2c_j)^2\le8\mathcal A^2/N$; bound $2^{d+1}e^{-a^2N/(256\mathcal A^2)}$ | $N\ge256\mathcal A^2\ell_d/a^2$ |
| $E_1$ | $\lvert q_1-\mathbb Eq_1\rvert\le a/(32H\bar S)$ | Hoeffding, terms in $[0,1/N]$; bound $2^{d+1}e^{-2N(a/32H\bar S)^2}$ | $N\ge512H^2\bar S^2\ell_d/a^2$ |
| $E^\ell_m$, $2\le\ell\le H$ | $\lvert\bar h^\ell-\psi_{\tau^2q_{\ell-1}}(u_\ell)\rvert\le u_0$ | conditional Hoeffding given $\mathcal F_{\ell-1}$, terms in $[-1/N,1/N]$; bound $2^{d+1}e^{-Nu_0^2/2}$ | $N\ge2\ell_d/u_0^2$ |
| $E^\ell_q$, $2\le\ell\le H-1$ | $\lvert q_\ell-\Upsilon(u_\ell,\tau^2q_{\ell-1})\rvert\le u_0$ | conditional Hoeffding, terms in $[0,1/N]$; bound $2^{d+1}e^{-2Nu_0^2}$ | as above |
| $E_{\rm out}$ | $\lvert\frac\tau N\zeta\cdot h^H\rvert\le a/8$ | given $\mathcal F_H$ the variable is $\mathcal N(0,\tau^2\lvert h^H\rvert^2/N^2)$, with variance $\le1/N$; bound $2^{d+1}e^{-Na^2/128}$ | $N\ge128\ell_d/a^2$, implied by $2\ell_d/u_0^2$ since $u_0\le a/16$ |

Since $2^{d+1}e^{-\ell_d}=\frac1{8H}$, each event fails with probability at most $\frac1{8H}$ when $N\ge N_*$. So $\Pr(E^c)\le\frac{2H}{8H}=\frac14$. Each conditional bound integrates to the same unconditional bound.

*Step 6 (accuracy on $E$).*

- *Hypotheses of Lemma 4.3.* On $E$:
  - $\lvert S\rvert\le\lvert\tilde r\rvert+\frac a8+\frac a8\le\frac1{\Pi_*}+\frac14\le\bar S$;
  - $\lvert q_1-1\rvert\le8e^{4-2\alpha}+\frac a{32H\bar S}\le\frac a{16H\bar S}=:\varphi$, by the choice of $\alpha$;
  - the deviations of $\bar h^\ell$ and $q_\ell$ are at most $u_0$;
  - $R\ge2$.
- *Size of $\Xi$.* Lemma 4.3 applies, and
$$\Xi\le2R^{H-1}u_0+2H\bar S\varphi+2H^2\bar Su_0+\frac{8H^2\bar S^3}{R^2}+\frac{16\bar S^3}{3R^2}\le\frac a8+\frac a8+\frac a{16}+\frac a{16}+\frac a{96}<0.39a\le1 .$$
  The five terms are bounded using $u_0\le\frac a{16R^{H-1}}$, $\varphi=\frac a{16H\bar S}$, $u_0\le\frac a{32H^2\bar S}$, $R^2\ge\frac{128H^2\bar S^3}a$, and the same with $H^2\ge1$.
- *Output error.* With $\Pi_*\le1$,
$$\lvert z_w-r\rvert\le\Bigl\lvert\frac\tau N\zeta\cdot h^H\Bigr\rvert+\lvert R\bar h^H-\Pi_*S\rvert+\Pi_*\lvert S-g_\phi\rvert+\Pi_*\lvert g_\phi-\tilde r\rvert\le\frac a8+0.39a+\frac a8+\frac a8<a .$$

*Step 7 (symmetrisation and translation).* Let $-E=\{\xi:-\xi\in E\}$. It has the same probability as $E$, so $E':=E\cap(-E)$ is symmetric with $\gamma_P(E')\ge\frac12$. Since $E'\subseteq E$, the set $w_0+D_NE'$ lies in $\{\max_{\mathcal C_d}\lvert z_w-r\rvert\le a\}$. By (1.2) and (G2), its prior mass is at least $\frac12e^{-N^\gamma\kappa_N(w_0)/2}\ge\frac12e^{-N^\gamma K_{\rm rob}/2}$. $\square$

**Remarks.**

- *Dependence of the centre.* The centre depends on $N$ and $\gamma$ through $\tau$, via $\phi$ and $\Pi_*$. Only its energy bound, which is uniform, enters the posterior argument.
- *Necessity of pre-compensation.* For $\gamma>1$ and $N\to\infty$, $\tau\to0$, $\Pi_*\to1$ and $\phi\to\tanh$. The construction then reduces to that of ../research-notes/A-tight-conditioning-fails.md Lemma 2.1, except for a larger slope $\alpha$ and gain $R$. At $\gamma=1$ the pre-compensation by $1/\Pi_*$ is essential. Without it the averaged network outputs about $\Pi_*r$, that is $0.61\,r$ at $H=2$ and $0.46\,r$ at $H=3$ (Section 7, item 4).

---

## 5. Claim A at finite scale, every $\gamma\ge1$

### 5.1 From a tube bound to posterior concentration

**Lemma 5.1.** Let $N,n\ge1$, $c>0$, $\gamma\ge1$, and let $S$ be any sample. Let $V\subseteq\mathcal W_N$ be Borel with $\mu_{N,\gamma}(V)\ge\frac12e^{-N^\gamma K/2}$ and $\sup_{w\in V}R_S(w)\le R_V$. For $t>0$ put $B_t:=\{w:R_S(w)>R_V+c(K+2t)\}$. Then
$$\Pi_{N,S}(B_t)\le2e^{-N^\gamma t},\qquad\mathbb E_{\Pi_{N,S}}\Bigl[\sqrt{\kappa^{(L)}(w)}\,\mathbf 1_{B_t}\Bigr]\le2e^{-N^\gamma t}.$$

*Proof.* By Lemma 1.1(b), $\Pi_{N,S}(dw)\propto e^{-\frac{N^\gamma}{2c}R_S(w)}\mu_{N,\gamma}(dw)$.

- *Normaliser.* It is at least $\mu(V)e^{-\frac{N^\gamma}{2c}R_V}\ge\frac12e^{-N^\gamma K/2-\frac{N^\gamma}{2c}R_V}$.
- *Numerator of $\Pi(B_t)$.* It is at most $e^{-\frac{N^\gamma}{2c}(R_V+c(K+2t))}=e^{-\frac{N^\gamma}{2c}R_V-N^\gamma K/2-N^\gamma t}$.
- *Second bound.* The extra factor in the numerator is at most $\mathbb E_\mu\sqrt{\kappa^{(L)}}\le(\mathbb E_\mu\kappa^{(L)})^{1/2}=(N\cdot N\cdot N^{-\gamma-1})^{1/2}\le1$. $\square$

### 5.2 The theorem

The cube example and its statistics are those of ../research-notes/A-tight-conditioning-fails.md §1.4. $D_d$ has $x$ uniform on $\mathcal C_d$ and a fair label $y\in\{\pm1\}$ independent of $x$, with $M=2^d$ and $\lambda=n/M$. The statistics are $k_x$, $\bar y_x$, the seen set $\mathcal S$, $Q=\sum_{x\in\mathcal S}\bar y_x^2$, $W$, $\Delta(f)=\sum_{x\in\mathcal S}k_x(f(x)-\bar y_x)^2$, and $\beta_n=\mathbb E[K^{-1};K\ge1]$ for $K\sim{\rm Bin}(n,1/M)$. Write $L(f):=L_{D_d}(f)=1+\frac1M\sum_{x}f(x)^2$.

**Theorem 5.2 (Claim A at finite prior scale).** Fix $H\ge2$, $d,n\ge1$, $c>0$, $a\in(0,1]$, $t>0$ and $\delta\in(0,1)$. Put $s_0=\min\{n,M\}$, $K=K_{\rm rob}(d,s_0,a,H)$, $N_*=N_*(d,s_0,a,H)$ (Proposition 4.4), and
$$\eta:=a^2+\frac{c(K+2t)}n,\qquad\epsilon_{\rm fs}:=\lambda\eta,\qquad e:=\Bigl(\sqrt{\bigl(\beta_n-\sqrt{2\lambda\ln(1/\delta)/M}\bigr)_+}-\sqrt{\epsilon_{\rm fs}}\Bigr)_+^2 .$$
Let $S\sim D_d^{\otimes n}$. The event $\mathcal E_\delta=\{Q\ge M\beta_n-\sqrt{2n\ln(1/\delta)}\}$ depends only on $S$ and has probability $\ge1-\delta$ (../research-notes/A-tight-conditioning-fails.md Lemma 4.3(b)). On $\mathcal E_\delta$, simultaneously for every $\gamma\ge1$ and every width $N\ge N_*$:

- (i) **Gibbs.** $\Pi_{N,S}\{w:L(z_w)\ge1+e\ \text{and}\ L(\operatorname{clip}z_w)\ge1+e\}\ge1-2e^{-N^\gamma t}$. Hence $\mathbb E_{\Pi_{N,S}}L(z_w)\ge(1-2e^{-N^\gamma t})(1+e)$, and likewise for $\operatorname{clip}z_w$.
- (ii) **Posterior means.** Let $f$ be one of $\mathbb E_\Pi z_w$, $\operatorname{clip}(\mathbb E_\Pi z_w)$ or $\mathbb E_\Pi\operatorname{clip}z_w$. Then $L(f)\ge1+(\sqrt e-\varsigma_N)_+^2$, where $\varsigma_N=2e^{-N^\gamma t}(2+\sqrt{\eta n})$ for the first two and $\varsigma_N=4e^{-N^\gamma t}$ for the third.

Moreover $L(0)=1=\inf_fL(f)$: the zero network, of width $1$ and with all weights $0$, attains the Bayes risk.

*Proof.*

- **Tube.** Let $r=\bar y\mathbf 1_{\mathcal S}$. Then $\lvert r\rvert\le1$ and $\sum_xr(x)^2=Q\le\lvert\mathcal S\rvert\le s_0$. Proposition 4.4 gives $V=\{\max_{\mathcal C_d}\lvert z_w-r\rvert\le a\}$ with $\mu_{N,\gamma}(V)\ge\frac12e^{-N^\gamma K/2}$.
- **Concentration.** On $V$, $\lvert z_w(x)-\bar y_x\rvert\le a$ for $x\in\mathcal S$. So, by ../research-notes/A-tight-conditioning-fails.md Lemma 4.1(a), $R_S(w)=\Delta(z_w)+W\le na^2+W=:R_V$. Lemma 5.1 applies with $B_t=\{\Delta(z_w)>na^2+c(K+2t)\}=\{\Delta(z_w)>\eta n\}$, and gives $\Pi(B_t)\le2e^{-N^\gamma t}$.
- **(i).** Off $B_t$, $\Delta(z_w)\le\eta n$, and $\Delta(\operatorname{clip}z_w)\le\eta n$ by ../research-notes/A-tight-conditioning-fails.md Lemma 4.1(c). ../research-notes/A-tight-conditioning-fails.md Lemma 4.2(b), with $\varsigma=0$ and $B=\eta n$, gives $L\ge1+(\sqrt{Q/M}-\sqrt{\eta n/M})_+^2=1+(\sqrt{Q/M}-\sqrt{\epsilon_{\rm fs}})_+^2$. On $\mathcal E_\delta$, $Q/M\ge\beta_n-\sqrt{2\lambda\ln(1/\delta)/M}$, so this is at least $1+e$. The Gibbs bounds follow because $L\ge0$.
- **(ii), conditional means.** Let $G=B_t^c$, $p=\Pi(G)\ge1-2e^{-N^\gamma t}$, $m(x)=\mathbb E_\Pi[z_w(x)\mid G]$ and $m^{\rm cl}(x)=\mathbb E_\Pi[\operatorname{clip}z_w(x)\mid G]$; these are finite by (1.1) and Gaussian tails. $\Delta$ is convex in the vector $(f(x))_{x\in\mathcal S}$, so Jensen gives $\Delta(m)\le\eta n$ and $\Delta(m^{\rm cl})\le\eta n$. For $x\in\mathcal S$, $\lvert m(x)\rvert\le\lvert\bar y_x\rvert+\sqrt{\Delta(m)/k_x}\le1+\sqrt{\eta n}$.
- **(ii), the means are close to them.** By (1.1) and Lemma 5.1,
$$\lvert\mathbb E_\Pi z_w(x)-m(x)\rvert\le(1-p)\lvert m(x)\rvert+\mathbb E_\Pi\bigl[\sqrt{\kappa^{(L)}}\mathbf 1_{B_t}\bigr]\le2e^{-N^\gamma t}(1+\sqrt{\eta n})+2e^{-N^\gamma t}=\varsigma_N .$$
  Clipping is 1-Lipschitz, and $\Delta(\operatorname{clip}m)\le\Delta(m)$. Also $\lvert\mathbb E_\Pi\operatorname{clip}z_w-m^{\rm cl}\rvert\le2(1-p)\le4e^{-N^\gamma t}$.
- **(ii), conclusion.** ../research-notes/A-tight-conditioning-fails.md Lemma 4.2(b) with $g\in\{m,\operatorname{clip}m,m^{\rm cl}\}$, $B=\eta n$ and $\lvert\mathcal S\rvert\le M$ gives $L(f)\ge1+(\sqrt{Q/M}-\sqrt{\epsilon_{\rm fs}}-\varsigma_N)_+^2\ge1+(\sqrt e-\varsigma_N)_+^2$ on $\mathcal E_\delta$.

$\mathcal E_\delta$ does not involve $N$ or $\gamma$, and $N_*$ does not depend on $\gamma$. $\square$

### 5.3 Asymptotics and the refutation

**Corollary 5.3.** Fix $H\ge2$ and $\lambda\in(0,\infty)$. Let $n_d/2^d\to\lambda$ and let $c_d>0$ satisfy
$$c_d\bigl(d^4+(dn_d)^{1/H}\bigr)=o(n_d)\qquad(d\to\infty). \tag{5.1}$$
Put $a_d=(\max\{c_d,1\}/2^d)^{1/3}$, $t=1$ and $\delta_d=\exp(-2^{d/2})$. With probability at least $1-\exp(-2^{d/2})$, simultaneously for every $\gamma\ge1$ and every $N\ge N_*(d,\min\{n_d,2^d\},a_d,H)$, the bounds (i)–(ii) of Theorem 5.2 hold with $e=e_d\to\beta(\lambda)$ and $\sup_{N\ge N_*}\varsigma_N\to0$. The width threshold is polynomial in $n_d$. For $c_d\equiv1$ and $n_d=2^d$ the limit is $\beta(1)=0.4848$; the maximum over $\lambda$ is $0.5174$, at $\lambda=1.503$.

Since $n_d\asymp2^d$, condition (5.1) is equivalent for large $d$ to $c_d=o(n_d^{1-1/H}d^{-1/H})$. This is condition (4.4) of ../research-notes/A-tight-conditioning-fails.md, which uses $d^2\log^2(d+1)$ in place of $d^4$. The factor $d^4$ arises only from the slope $\alpha=O(d)$ forced by $a_d=2^{-\Theta(d)}$.

*Proof.*

- **$\epsilon_{\rm fs}\to0$.** First, $\lambda_da_d^2=\lambda_d(\max\{c_d,1\}/2^d)^{2/3}\to0$, because (5.1) implies $c_d=o(2^d)$. Next, $\ln(1/a_d)\le\frac d3\ln2$, so $\alpha=O(d)$ and $d(d+1)\alpha^2=O(d^4)$. Then $R^2\le3(8dn_d)^{1/H}+128H^2\bar S^3/a_d+4$. So $c_d(K+2)/2^d\to0$ by (5.1), together with $c_d/(a_d2^d)\le\max\{c_d,1\}^{2/3}2^{-2d/3}\to0$.
- **$e_d\to\beta(\lambda)$.** The deviation term is $\sqrt{2\lambda_d\ln(1/\delta_d)/2^d}=\sqrt{2\lambda_d}\,2^{-d/4}\to0$, and $\beta_{n_d}\to\beta(\lambda)$ by ../research-notes/A-tight-conditioning-fails.md Lemma 4.3(c),(d).
- **Width threshold.** $\mathcal A_{\max}^2\le8dn_d3^{H-1}$, $1/a_d\le2^{d/3}$, $\ell_d=O(d)$ and $R^{2H-2}\le{\rm poly}(n_d)$, so $N_*={\rm poly}(n_d)$.
- **$\varsigma_N\to0$.** For large $d$, $\eta\le1$, so $\varsigma_N\le2e^{-N^\gamma}(2+\sqrt{n_d})\le2e^{-N}(2+\sqrt{n_d})$. Moreover $N\ge N_*\ge256\mathcal A_{\max}^2\ell_d/a_d^2\ge s_0=\min\{n_d,2^d\}$, and $e^{-\min\{n_d,2^d\}}\sqrt{n_d}\to0$. $\square$

Table 7.1 (`bounds_table_fs.py`) gives the certified $e$ at $c=1$, $t=1$, $\delta=0.01$, with $a$ optimised. It is within $0.02$ of $\beta(\lambda)$ from $d\approx40$ at $H=2$ and $H=3$.

**Corollary 5.4 (no polynomial oracle inequality at any finite scale).** Fix $L=H+1\ge3$ and $\gamma\ge1$. Let $c$ be a fixed constant, or $c=c(n)$ with $c_d=c(2^d)$ satisfying (5.1) for $n_d=2^d$. The case $c(n)=n^{1-\theta}$ with $\theta>1/H$ is included, because $n^{1-\theta}\bigl(d^4+(dn)^{1/H}\bigr)=o(n)$ at $n=2^d$.

Consider the property (P$_L$) of ../research-notes/A-tight-conditioning-fails.md §5.1, read for the finite-scale learner in either of two ways. (F1) The output is a Gibbs draw $w\sim\Pi_{N,S}$, with probability over $S$ and the draw. (F2) The output is $\mathbb E_\Pi z_w$, $\operatorname{clip}\mathbb E_\Pi z_w$ or $\mathbb E_\Pi\operatorname{clip}z_w$. Under both readings the learner violates (P$_L$).

Precisely, take the competitor $g\equiv0$, $\varepsilon\in(0,\beta(1))$ and $\delta\in(0,1)$. For all large $d$, at $n=2^d$ and **every** width $N\ge N_*(d,2^d,a_d,H)={\rm poly}(n)$, the probability that the test MSE is at most $L_{D_d}(g)+\varepsilon=1+\varepsilon$ is at most $e^{-2^{d/2}}+2e^{-N^\gamma}<1-\delta$.

*Proof.* A polynomial threshold $p(d,1,1,1/\varepsilon,\ln\frac1\delta)$ is eventually below $2^d$, so (P$_L$) would apply at $n=2^d$ and every width. By Corollary 5.3 with $\lambda=1$, $e_d>\varepsilon$ for large $d$. Under (F1), the probability of loss at most $1+\varepsilon$ is at most $\Pr(\mathcal E^c)+\sup_{S\in\mathcal E}\Pi_{N,S}\{L(z_w)<1+e_d\}\le e^{-2^{d/2}}+2e^{-N^\gamma}$. Under (F2), on $\mathcal E$, $L(f)\ge1+(\sqrt{e_d}-\varsigma_N)^2>1+\varepsilon$ for large $d$. $\square$

This refutes the width-uniform formulation of brief §1 at every finite scale, and every formulation that admits learner widths $\ge N_*(n)$. Smaller widths are not addressed. At $c=1$ the PAC-Bayes bound of Lemma 2.2 is vacuous ($\theta=0$ gives an additive $2A$).

### 5.4 Variants

- **(a) Sampling without replacement** (../research-notes/A-tight-conditioning-fails.md Proposition 6.1, finite scale). Let the $n\le M$ inputs be distinct, so $W=0$ and $\Delta=R_S$.
  - Proposition 4.4 with $s=n$ and Lemma 5.1 give $\Pi_{N,S}\{R_S>n\eta\}\le2e^{-N^\gamma t}$ at every $N\ge N_*(d,n,a,H)$ and every $\gamma\ge1$, where $\eta=a^2+c(K+2t)/n$ and $K=K_{\rm rob}(d,n,a,H)$.
  - For fair labels $Q=n$. ../research-notes/A-tight-conditioning-fails.md Lemma 4.2(b) then gives Gibbs test MSE at least $1+\frac nM(1-\sqrt\eta)_+^2$ with posterior probability at least $1-2e^{-N^\gamma t}$; posterior means are handled as in Theorem 5.2.
  - At $n=M$, with $cK=o(M)$ and $a\to0$, the test MSE tends to $2$, against a Bayes risk of $1$.
- **(b) General label laws** (../research-notes/A-tight-conditioning-fails.md Corollary 4.6). Let $\mathrm{Var}(y\mid x)\ge v_0$ and uniform $x$. Replace $Q$ by $Q_\eta=\sum_{x\in\mathcal S}(\bar y_x-\eta(x))^2$ and the event by $\mathcal E_\eta=\{Q_\eta\ge v_0M\beta_n-\sqrt{32n\ln(1/\delta)}\}$. The proof of Theorem 5.2 is unchanged: Proposition 4.4 still applies to $r=\bar y\mathbf 1_{\mathcal S}$. The excess over the Bayes predictor is at least $v_0\beta(\lambda)-o(1)$ under (5.1).
- **(c) Continuous inputs (Claim A′).** Not proved at finite scale. The cube proof transfers, but A′ also needs every posterior draw to be nearly constant on each cluster, up to an additive $a$.
  - For $\gamma\ge2$ this should follow from Lemma 2.1(c)-type energy tails with $K'\approx4K+4na^2/c$.
  - For $1<\gamma<2$ it should follow from Lemma 2.4 at widths $\ge T(K')={\rm poly}(n)$, which approximates $z_w$ within $a/2$ by a network with Lipschitz constant ${\rm poly}(n)$.
  - At $\gamma=1$ it should follow from the Lipschitz event inside the mean-field cover (I3).

  I have not written these out.

---

## 6. Phase diagram, and what is open

The learner is the finite-scale co-scaled learner $\Pi_{N,S}$ with $c=n^{1-\theta}$. "Works" means the polynomial agnostic oracle inequality at every width $N\ge m$ for the clipped Gibbs predictor and the clipped posterior mean (Theorem 2.7). "Fails" means a constant excess at all widths $\ge{\rm poly}(n)$ on the noisy cube (Corollary 5.4).

| depth, scale | works for | fails for | open |
|---|---|---|---|
| $L=2$, any $\gamma\ge1$ | $0<\theta<1$ | — (memorisation costs $\Theta(s)$ energy at depth two, ../research-notes/A-tight-conditioning-fails.md Remark 2.5) | small $c$ at depth two |
| $L\ge3$, $\gamma\ge2-\frac1H$ | $\theta<\frac1H$ | $\theta>\frac1H$, and $c=1$ | $\theta=\frac1H$ (polylogarithmic window, as for $\sigma\to0$) |
| $L\ge3$, $1<\gamma<2-\frac1H$ | $\theta<\max\{\frac{\gamma-1}{\gamma H-1},\frac{\gamma-1}{H(H-1)(2-\gamma)}\}$ | $\theta>\frac1H$, and $c=1$ | the window between |
| $L\ge3$, $\gamma=1$ | $\theta<\frac1{4+16(L-2)3^{L-2}}$ (via (I3)) | $\theta>\frac1H$, and $c=1$ | the window between |

For $L\ge3$ and $\gamma\ge2-\frac1H$, the finite-scale picture is the strong-prior picture of Sections A and B. The phase transition sits at $c=n^{1-1/H}$, at every width.

**Open problems.**

1. **The window $\theta\in[\theta_{L,\gamma},\frac1H)$ for $1\le\gamma<2-\frac1H$.** I conjecture that $\theta<1/H$ suffices at every $\gamma\ge1$. The obstruction in the proof is Lemma 2.4, step 6, which bounds the effect of the random bulk $(W^\ell)_{\le b}$ by its operator norm times the worst-case amplification. A random bulk acting on a fixed vector loses a further factor $\sqrt N$ when it is seen through a matrix of bounded Frobenius norm. Consistently, `check_lemmaT.py` shows deviations decaying like $N^{(1-\gamma)/2}\cdot N^{-1/2}$ rather than $N^{(1-\gamma)/2}$. The posterior can align the bulk with the data, but only at a translation cost (G2), and that cost turns the aligned part into energy. Making this rigorous would need a width-free capacity bound for "bounded energy plus random bulk" networks under the posterior. I do not have one.
2. **Unclipped predictors** at finite scale (Remark 2.9(a)).
3. **Claim A′** at finite scale (§5.4(c)).
4. **Widths below $N_*$ for $c=1$.** Neither direction is addressed.
5. **Non-Gaussian coordinate laws** of `paper.tex` eq. `law`. Lemma 1.1(b) changes. Lemma 3.1 and Proposition 4.4 should go through with (G2) replaced by eq. `translation` (constant $M$), but this is not checked.
6. **The $\gamma=1$ positive range** is set by the degrees $D_T,D_H$ of the mean-field cover (I3). A better mean-field cover would enlarge it.

---

## 7. Numerical checks

All scripts are in `../checks/E/`, with outputs `*.out` next to them. They are sanity checks, not proofs.

1. **`check_constants.py`, `check_symbolic.py`** (Lemma 4.1, Lemma 4.2, (G1)).
   - Symbolic identities hold for $\tanh'''$, $({\rm sech}^2)''$ and $(\tanh^2)''$. Each has $\sup=2$.
   - $\varpi(q)-(1+2q)^{-1/2}\ge0$ on $[0,1]$. $\max\lvert\varpi'\rvert=\max\lvert F'\rvert=0.998\le1$.
   - $\max_{q,u}\lvert\psi_q(u)-\varpi(q)u\rvert/(\lvert u\rvert^3/3)=0.99996\le1$, and $\max\lvert\Upsilon(u,q)-F(q)\rvert/u^2=0.99993\le1$.
   - $\varpi(1)=0.60571$, $F(1)=0.39429$, $\Pi_*(1,H)=0.6057,\,0.4625,\,0.3854,\,0.3361,\,0.3013$ for $H=2,\dots,6$, all $\ge3^{-(H-1)/2}$.
   - The saturation bounds $1-\phi(\alpha)\le2e^{4-2\alpha}$ and $\mathbb E\,{\rm sech}^2\le8e^{4-2\alpha}$ hold with room.
2. **`check_opnorm.py`** ((G3)). $\mathbb E\lVert G\rVert_{\rm op}$ is below $\sqrt p+\sqrt q$ in all tested shapes, and $\lVert G\rVert_{\rm op}\le\sqrt p+\sqrt q+\sqrt{2\ln2}$ in all 200 draws.
3. **`check_lemmaT.py`** (Lemma 3.1). Centres are balanced clones of random width-3 teachers, with $d=6$, $H\in\{2,3\}$, $N\in\{60,240,960\}$ and $\gamma\in\{1.5,2,3\}$.
   - The typical event $E$ held in 95–100% of draws.
   - The observed $\sup_{\mathcal C_d}\lvert z_w-z_{w_0}\rvert$ was always far below $(3H+2)K_0^{H/2}N^{(1-\gamma)/2}$.
   - $\text{dev}\cdot N^{(\gamma-1)/2}$ falls like $N^{-1/2}$ (0.73, 0.40, 0.21), consistent with open problem 1.
4. **`robust_memorizer.py`, `robust_memorizer_det.py`** (Proposition 4.4). $d=6$, $n=64$ random labels, target $r=\bar y\mathbf 1_{\mathcal S}$, smoothed features with $\alpha=5$. The second script allocates neurons to features deterministically instead of sampling.
   - The exact expansion in smoothed features has error $\le4\cdot10^{-15}$.
   - The table reports $\max_{\mathcal C_d}\lvert z_w-r\rvert$ for prior draws $w=w_0+D_N\xi$ (median over 6 draws). The column "naive" is ../research-notes/A-tight-conditioning-fails.md's uncompensated tanh memoriser with the same allocation.

| $H$ | $\gamma$ | $N$ | $R$ | robust | naive |
|---|---|---|---|---|---|
| 2 | 1 | 2000 | 5 | 0.193 | 0.526 |
| 2 | 1 | 8000 | 5 | 0.084 | 0.450 |
| 2 | 1.25 | 8000 | 5 | 0.048 | 0.128 |
| 2 | 2 | 4000 | 5 | 0.025 | 0.025 |
| 3 | 1 | 3000 | 3 | 0.173 | 0.696 |
| 3 | 1 | 6000 | 3 | 0.152 | 0.637 |

   - At mean field the pre-compensated centre fits the target under the prior's noise, and its error falls with $N$. The naive centre outputs about $\Pi_*r$. At $\gamma=2$ the noise is negligible and both agree.
   - The energies here, $\kappa_N(w_0)\approx610$, exceed $n=64$. These runs therefore test the tube mechanism, not posterior memorisation, which needs $d\gtrsim30$ (item 7).
5. **`check_truncation.py`** (Lemma 2.4). Networks are a low-rank signal plus Gaussian bulk at scale $N^{-\gamma/2}$, with $b=7N^{(1-\gamma)/2}$. In all eight cases the truncation error ($\le0.008$) is below $b(H-1)K^{(H-1)/2}$, and the truncated energy is below $LK$.
6. **`theta_table.py`.** This tabulates $\theta_{L,\gamma}$ (Theorem 2.7). The two routes cross at $\gamma=2-\frac2H+\frac1{H^2}$. The full range $1/H$ is reached at $\gamma=2-\frac1H$, that is $1.5$, $1.667$ and $1.75$ for $H=2,3,4$. At $\gamma=1.5$ the red-team sketch gives $0.25$, $0.125$, $0.083$, against $0.5$, $0.167$, $0.1$ here.
7. **`bounds_table_fs.py`** (Theorem 5.2, Corollary 5.3). Table 7.1 gives the certified excess $e$ at $c=1$, $t=1$, $\delta=0.01$, with $a$ optimised.

| $H$ | $d$ | $e$ at $\lambda=1$ ($\beta=0.4848$) | $e$ at $\lambda=1.5$ ($\beta=0.5174$) | $K_{\rm rob}/n$ | $\log_{10}N_*$ |
|---|---|---|---|---|---|
| 2 | 30 | 0.417 | 0.447 | $2.5\cdot10^{-3}$ | 20 |
| 2 | 40 | 0.472 | 0.504 | $8.9\cdot10^{-5}$ | 27 |
| 2 | 60 | 0.4844 | 0.5169 | $1.1\cdot10^{-7}$ | 39 |
| 3 | 30 | 0.389 | 0.411 | $3.6\cdot10^{-3}$ | 19 |
| 3 | 40 | 0.475 | 0.506 | $3.5\cdot10^{-5}$ | 24 |
| 3 | 60 | 0.4847 | 0.5172 | $3.4\cdot10^{-9}$ | 35 |

   - The width thresholds are astronomically large but polynomial in $n$, as in ../research-notes/A-tight-conditioning-fails.md Table 4.1. The constants $128H^2\bar S^3/a$ in $R^2$ and the $\ell_d/u_0^2$ in $N_*$ are not optimised.
8. **`check_chain.py`** (Lemma 4.3). The script runs 2760 perturbed chains satisfying the lemma's hypotheses with $\Xi\le1$: $H\in\{2,3,4\}$, $\tau\in\{1,0.6,0.2\}$, $R\in\{2,\dots,50\}$, random and one-signed perturbations. The largest ratio $\lvert R\bar h^H-\Pi_*S\rvert/\Xi$ is $0.447$.

---

## 8. Status

**Proved here** (paper proofs; all hypotheses stated above):

- Lemma 1.1, the posterior identity, checked against the prior's normalisation, and Remark 1.2.
- Lemmas 2.1–2.5 and Theorem 2.7 for $L=2$ (every $\gamma\ge1$) and for $L\ge3$, $\gamma>1$. These use the imported (I1) and (I2). Lemma 2.4 is a self-contained Gaussian re-proof of `paper.tex` Lemma `spectral`.
- Lemma 3.1: the Laplace lower bound at large width for $\gamma>1$, around any centre.
- Lemmas 4.1–4.3 and Proposition 4.4: the noise-robust memoriser, uniformly in $\gamma\ge1$. These use (I4) for $\lvert c_{k,\infty}\rvert\ge(2k)^{-1/2}$ and the Fourier $\ell^1$ bound.
- Lemma 5.1, Theorem 5.2 and Corollaries 5.3–5.4: Claim A and the refutation of (P$_L$) at every $\gamma\ge1$ and every depth $L\ge3$, for $c=1$ and every $c$ with (5.1), including $c=n^{1-\theta}$ with $\theta>1/H$. These use the cube lemmas of (I4).
- Variants (a) and (b) of §5.4.

**Proved, conditional on an imported result that I checked only at the level of its statement and formulas:**

- Theorem 2.7 at $\gamma=1$, $L\ge3$. It uses (I3), the mean-field output cover, whose source defers some expanded calculations to a companion paper. The exponent $1/(4+16(L-2)3^{L-2})$ comes from my reading of the degrees of $T_L$ and $H^{\rm mf}_L$ in that source's explicit formulas.

**Not proved / open:**

- The window $[\theta_{L,\gamma},\frac1H)$ for $1\le\gamma<2-\frac1H$.
- Unclipped predictors.
- Claim A′ at finite scale.
- Widths below $N_*$ for the negative direction.
- Non-Gaussian coordinate laws.
- Depth two with small $c$.

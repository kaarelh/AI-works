# Claim B: an agnostic oracle inequality at every width for the tempered co-scaled Gaussian likelihood

*Research section for the agnostic NNBayes note (brief: `../research-notes/problem-brief.md`, Claims B and D). Every statement labelled theorem, proposition, lemma or corollary is proved here, with one exception. Proposition 4.1 is imported from the repository, and its source was checked. It is used only in the first of two proofs (Section 4 and Theorem 6.2), and the second proof supersedes that one. The numerical checks are in `../checks/B/` (Section 10). `NNG/` denotes the project folder `neural-network-generalization/` of this repository.*

## 0. Results

The learner is SP$_c$: a Gaussian strong-prior weight law with a Gaussian likelihood of variance $c\sigma^2$, where $c=c(n)=n^{1-\theta}$. The limit $\sigma\downarrow0$ is taken after the sample and the learner width $N$ are fixed. The depth is $L=H+1\ge2$.

| topic | statement | where |
|---|---|---|
| main theorem | Fix $\theta\in(0,1/H)$, a compact $X\subseteq[-1,1]^d$, a law $D$ on $X\times[-1,1]$, a competitor $g$ of depth $L$, width $m$ and weights in $[-B,B]$, and $\varepsilon,\delta\in(0,1)$. For every $n\ge n_0$, with $n_0$ explicit and polynomial in $d,m,B,1/\varepsilon,\log(1/\delta)$, the following holds with probability $\ge1-\delta$, simultaneously for all learner widths $N\ge m$. Every near-minimizer of $F_c$, the support of every $\sigma\downarrow0$ limit of the posterior, the Gibbs predictor and the posterior mean of the clipped outputs all have test MSE $\le L_D(g)+\varepsilon$. | Thm 6.3 |
| rate | excess $\le(E_*+1)n^{-\theta}+8(2/H)^{H/2}D_n\,n^{-(1-\theta H)/2}+\bigl(4+(U+1)^2\bigr)\sqrt{\ln(2/\delta)/(2n)}$, where $D_n=\sqrt{2(d+1)\ln(n+1)}+\tfrac{H-1}2$; this is $\tilde O(n^{-1/(H+2)})$ at $\theta=1/(H+2)$ | Thm 6.3 |
| unclipped outputs | the same conclusions for every $\theta\in(0,1/L)$ (near-minimizers, Gibbs predictor, posterior mean of $z_w$) | Thm 6.4 |
| the route through the repository's energy cover | this proof covers only $\theta<1/(4(L-1))$ when $L\ge3$ and $\theta<1/2$ when $L=2$, because $\ln\lvert\mathcal H_{K,a}\rvert$ has degree $4(L-1)$ in $K$ and $8$ in $1/a$ when $L\ge3$ | Thm 6.2, Lemma 4.2 |
| sharpness ($H\ge2$) | for every $\theta>1/H$, SP$_c$ fails on the noisy cube with $d=\log_2n$ (excess $\ge1/e-o(1)$); so $1/H$ is the sharp exponent for clipped predictors, and the window in $c$ is polylogarithmic | Thm 7.4 |
| the user's formulation | test MSE $\le\min$ over depth-$L$ MLPs with width and weights $\le n^\alpha$, plus $O(n^{-\beta})$, for every $\alpha<1/(4H)$, with $\beta=(1-4\alpha H)/(H+2)$ when $H\ge2$ | Cor 8.1 |
| the weight bound | On a noiseless two-point law, a width-1 competitor with zero loss, weights $\le1.5(n^\theta+1)^{1/2}$ and energy $\le3.25(n^\theta+1)$ beats the learner by $1/4$. For the class of width-1 networks with weights $\le n^\alpha$, the critical exponent is exactly $\alpha^*=1/(2H)$. For the class with width and weights $\le n^\alpha$, $\alpha^*\in[\frac1{4H},\frac L{2H(2L-1)}]$. Here $\alpha^*$ is the threshold above which **no** choice of $c(n)$ works; the negative halves are proved for arbitrary $c(n)$ and need $H\ge2$. | Prop 9.1, Cor 9.3 |

**Still open.**

- Unclipped predictors for $\theta\in[1/L,1/H]$.
- The behaviour inside the polylogarithmic window around $c\asymp n^{1-1/H}$.
- Depth two with $c=O(\mathrm{polylog}\,n)$.
- Finite prior scale (Claim E).

**Repository statements used, each checked against its source.**

| statement | source | use here |
|---|---|---|
| cloning energy $E_*=d(d+1)B^2+2(L-1)C^2B^2$ and the per-layer bounds $d(d+1)B^2$, $2C^2B^2$, $2C^2B^2$ | `NNG/side-results/continuous-domains/source/paper.tex`, §"Cloning and the mass of a teacher tube", eq. `teacher-energy` | re-proved as Lemma 2.2 |
| $\mathrm{Lip}(z_w)\le K^{L/2}/\sqrt d$ | same file, eq. `energy-lipschitz` | sharpened by $L^{L/2}$ in Lemma 2.1 |
| finite-input compression (parameters $\lambda,D_T,J$; weights $\le J$), energy cover with rounding mesh $\Delta$ and $P$ coordinates, cube version | same file, Lemma `compression`, Proposition `energy-cover`, Remark `cube` | imported as Proposition 4.1 (route 1 only) |
| Laplace estimates of the strong-prior limit | same file, proof of Theorem `strong` | the same argument, redone for $e^{-F_c/(2\sigma^2)}$ in Lemma 3.1 |
| clip contraction (12), clip mixture (13), path normalization, path-norm bound (14), halfspace averaging, Rademacher bound (15) | `NNG/works-in-progress/noisy-interpolation/README.md` §4 | re-proved for arbitrary inputs in Lemmas 5.1–5.2 |
| sparse Fourier memorization with a depth chain | same README §§2–3 | a simplified variant is proved as Lemma 7.2 |
| SP$_1$ clean-label theorem: concentration on $J_S\le E_\star+1$, then cover and Chernoff | `NNG/works-in-progress/slt-likelihood/README.md` §2 | proof template only |

An independent red-team pass (`../research-notes/red-team.md`, §3) sketched the Rademacher route and reached the exponents $1/H$ and $1/L$. This section adds:

- complete proofs, including measurability and the posterior tails;
- explicit sample bounds;
- the cover-route degrees;
- a self-contained proof of sharpness;
- the weight-bound analysis.

---

## 1. Setting and conventions

**Inputs and networks.** Fix $d\ge1$ and a nonempty compact $X\subseteq[-1,1]^d$; the unit ball and the sphere are included. Write $\bar x=(1,x)$. The depth is $L=H+1\ge2$, with $H$ hidden tanh layers. A width-$N$ parameter is $w=(W^1,\dots,W^H,v)\in\mathcal W_N:=\mathbb R^{P_N}$, where $W^1\in\mathbb R^{N\times(d+1)}$, $W^\ell\in\mathbb R^{N\times N}$, $v\in\mathbb R^N$ and $P_N=N(d+1)+(H-1)N^2+N$. The network computes

$$
h^0(x)=\bar x,\qquad h^\ell(x)=\tanh\bigl(W^\ell h^{\ell-1}(x)\bigr)\ (1\le\ell\le H),\qquad z_w(x)=v^\top h^H(x).
$$

There are no internal biases. The energy is $\kappa_N(w)=a_1+\dots+a_L$ with

$$
a_1=\tfrac dN\lVert W^1\rVert_F^2,\qquad a_\ell=\lVert W^\ell\rVert_F^2\ (2\le\ell\le H),\qquad a_L=N\lVert v\rVert_2^2 .
$$

So $\kappa_N(w)=\lvert\Lambda_Nw\rvert^2$ for a positive diagonal matrix $\Lambda_N$.

**Data and losses.** $D$ is a Borel probability on $X\times[-1,1]$, and $S=((x_i,y_i))_{i=1}^n\sim D^n$. Write

$$
L_D(f)=\mathbb E_D(f(x)-y)^2,\qquad \hat L_S(f)=\frac1n\sum_{i=1}^n(f(x_i)-y_i)^2,
$$

$\operatorname{clip}(u)=\max\{-1,\min\{1,u\}\}$ and $\operatorname{clip}_t(u)=\max\{-t,\min\{t,u\}\}$. Since $\lvert y\rvert\le1$ and $\operatorname{clip}$ is the metric projection onto $[-1,1]$,

$$
(\operatorname{clip}u-y)^2\le(u-y)^2\qquad(u\in\mathbb R,\ \lvert y\rvert\le1). \tag{1.1}
$$

**The learner SP$_c$.** The prior $\mu_\sigma$ has density proportional to $e^{-\kappa_N(w)/(2\sigma^2)}$, so its coordinates are Gaussian with variances $N\sigma^2/d$, $\sigma^2$ and $\sigma^2/N$. The likelihood is $y_i\mid x_i,w\sim\mathcal N(z_w(x_i),c\sigma^2)$. The normalizing constants of the likelihood cancel, so the posterior is

$$
\Pi_\sigma(dw)=\Pi_{\sigma,N,S}(dw)=\frac{e^{-F_{c,S}(w)/(2\sigma^2)}\,dw}{\int e^{-F_{c,S}/(2\sigma^2)}},\qquad
F_{c,S}(w)=\kappa_N(w)+\frac1c\sum_{i=1}^n\bigl(z_w(x_i)-y_i\bigr)^2=\kappa_N(w)+\frac nc\hat L_S(z_w).
$$

Unless stated otherwise, $c=c(n)=n^{1-\theta}$.

**Limit order.** The sample size $n$, the sample $S$ and the width $N$ are fixed first, and then $\sigma\downarrow0$. Every sample event below is defined without reference to $N$ or $\sigma$.

**Near-minimizers.** $m_*=m_*(N,S)=\min_{\mathcal W_N}F_{c,S}$, which exists by Lemma 3.1, and

$$
\mathcal N_\zeta=\mathcal N^{(N)}_\zeta(S)=\{w\in\mathcal W_N:F_{c,S}(w)\le m_*+\zeta\}.
$$

**Predictors.** For a posterior $\Pi_\sigma$:

- Gibbs risks (one posterior draw): $\mathcal G^{\rm clip}_\sigma:=\mathbb E_{\Pi_\sigma}L_D(\operatorname{clip}z_w)$ and $\mathcal G_\sigma:=\mathbb E_{\Pi_\sigma}L_D(z_w)$;
- posterior means: $\bar f_\sigma(x):=\mathbb E_{\Pi_\sigma}\operatorname{clip}z_w(x)$ and $\bar z_\sigma(x):=\mathbb E_{\Pi_\sigma}z_w(x)$.

**Competitor.** $g=z_{w^g}$ for a depth-$L$ network of width $m$ (same architecture) with all weights in $[-B,B]$, $B>0$. Put

$$
E_*:=d(d+1)B^2+2(L-1)m^2B^2,\qquad U:=mB\ \ (\ge\sup\lvert g\rvert).
$$

**Energy classes.** $\mathcal Z_K:=\bigcup_{N\ge1}\{z_w:w\in\mathcal W_N,\ \kappa_N(w)\le K\}$, viewed as functions on $X$ (or on $\mathbb R^d$ where noted). Also

$$
D_n:=\sqrt{2(d+1)\ln(n+1)}+\frac{H-1}2 .
$$

---

## 2. Deterministic lemmas

**Lemma 2.1 (output and Lipschitz bounds).** For every $N$, every $w\in\mathcal W_N$ and all $x,x'\in\mathbb R^d$:

- (a) $\lvert z_w(x)\rvert\le\lVert v\rVert_1\le\sqrt N\lVert v\rVert_2\le\sqrt{\kappa_N(w)}$;
- (b) $\lvert z_w(x)-z_w(x')\rvert\le d^{-1/2}\bigl(\kappa_N(w)/L\bigr)^{L/2}\lVert x-x'\rVert_2$.

*Proof.*

(a) Each $\lvert h^H_j\rvert\le1$, so $\lvert z_w(x)\rvert\le\lVert v\rVert_1$. Cauchy–Schwarz gives $\lVert v\rVert_1\le\sqrt N\lVert v\rVert_2=\sqrt{a_L}$.

(b) tanh is 1-Lipschitz in each coordinate, and the constant coordinate of $\bar x$ cancels. Hence

$$
\lvert h^1(x)-h^1(x')\rvert\le\lVert W^1\rVert_{\rm op}\lVert x-x'\rVert,\qquad
\lvert h^\ell(x)-h^\ell(x')\rvert\le\lVert W^\ell\rVert_{\rm op}\lvert h^{\ell-1}(x)-h^{\ell-1}(x')\rvert,\qquad
\lvert z_w(x)-z_w(x')\rvert\le\lVert v\rVert_2\lvert h^H(x)-h^H(x')\rvert .
$$

So the Lipschitz constant is at most $\lVert v\rVert_2\prod_{\ell=1}^H\lVert W^\ell\rVert_F$. Now $\lVert v\rVert_2\lVert W^1\rVert_F=\sqrt{a_1a_L/d}$ and $\lVert W^\ell\rVert_F=\sqrt{a_\ell}$. By AM–GM over the $L$ numbers $a_\ell$,

$$
d^{-1/2}\Bigl(\prod_{\ell=1}^La_\ell\Bigr)^{1/2}\le d^{-1/2}(\kappa_N/L)^{L/2}.\ \blacksquare
$$

Part (b) improves `paper.tex` eq. `energy-lipschitz` ($K^{L/2}/\sqrt d$) by the factor $L^{L/2}$.

**Lemma 2.2 (cloning; `paper.tex` eq. `teacher-energy`).** For every $N\ge m$ there is $w^g_N\in\mathcal W_N$ with $z_{w^g_N}=g$ on all of $\mathbb R^d$ and with per-layer energies

$$
a_1\le d(d+1)B^2,\qquad a_\ell\le2m^2B^2\ (2\le\ell\le L).
$$

Hence $\kappa_N(w^g_N)\le E_*$.

*Proof.* Write the competitor's weights as $U^1\in\mathbb R^{m\times(d+1)}$, $U^\ell\in\mathbb R^{m\times m}$ ($2\le\ell\le H$) and $u\in\mathbb R^m$, all with entries in $[-B,B]$. Partition the $N$ learner neurons of each layer into groups $G_1,\dots,G_m$ of sizes $k_j\in\{\lfloor N/m\rfloor,\lceil N/m\rceil\}$, and let $j(p)$ be the group of neuron $p$. Set

$$
W^1_{p,:}=U^1_{j(p),:},\qquad W^\ell_{pq}=U^\ell_{j(p)j(q)}/k_{j(q)},\qquad v_p=u_{j(p)}/k_{j(p)}.
$$

By induction every learner unit in group $j$ equals the competitor's unit $j$: its preactivation is $\sum_q U^\ell_{j(p)j(q)}k_{j(q)}^{-1}g_{j(q)}=\sum_jU^\ell_{j(p)j}g_j$. The same computation gives output $g$.

Because $N\ge m$, we have $\lfloor N/m\rfloor\ge1$ and $\lceil N/m\rceil\le2\lfloor N/m\rfloor$. Also $N/\lfloor N/m\rfloor<2m$: write $N=qm+r$ with $q\ge1$, $0\le r<m$, so $N/q<2m$. Therefore:

- $a_1=\frac dN\sum_jk_j\lvert U^1_{j,:}\rvert^2\le d(d+1)B^2$;
- $a_\ell=\sum_{j,j'}(k_j/k_{j'})(U^\ell_{jj'})^2\le2m^2B^2$;
- $a_L=\sum_j(N/k_j)u_j^2\le2m^2B^2$. $\blacksquare$

**Lemma 2.3 (near-minimizers).** Fix $N$, $S$, $c>0$, $\zeta\ge0$ and $w\in\mathcal N^{(N)}_\zeta(S)$. Then:

- (a) $\kappa_N(w)\le c^{-1}\sum_iy_i^2+\zeta\le n/c+\zeta$. In particular, when $c=n^{1-\theta}$, $\kappa_N(w)\le n^\theta+\zeta$.
- (b) For every $w'\in\mathcal W_N$:
$$
\hat L_S(z_w)\le\hat L_S(z_{w'})+\frac{c\bigl(\kappa_N(w')+\zeta\bigr)}n,\qquad \kappa_N(w)\le\kappa_N(w')+\zeta+\frac nc\hat L_S(z_{w'}).
$$
- (c) If $N\ge m$, then $\hat L_S(z_w)\le\hat L_S(g)+c(E_*+\zeta)/n$ and $\kappa_N(w)\le E_*+\zeta+n(U+1)^2/c$.

*Proof.* We have $F_{c,S}(w)\le m_*+\zeta\le F_{c,S}(w')+\zeta$ for every $w'\in\mathcal W_N$.

(a) Take $w'=0$: then $z_0\equiv0$ and $F_{c,S}(0)=c^{-1}\sum_iy_i^2$. Also $\kappa_N(w)\le F_{c,S}(w)$.

(b) Expand $F_{c,S}(w)\le F_{c,S}(w')+\zeta$ and drop one of the two nonnegative terms on the left.

(c) Take $w'=w^g_N$ from Lemma 2.2. Since $\lvert g\rvert\le U$ and $\lvert y_i\rvert\le1$, we have $\hat L_S(g)\le(U+1)^2$. $\blacksquare$

The brief writes the energy bound as $\kappa\le\kappa(g)+1+nU^2/c$. Because the labels are not centred on $g$, the correct form is $n(U+1)^2/c$. Part (a) is better and does not depend on the competitor: all near-minimizers lie in the fixed class $\mathcal Z_{n/c+\zeta}$.

---

## 3. Strong-prior concentration

**Lemma 3.1 (Laplace concentration with tails, uniform in the sample).** Fix $N,n\ge1$, $c>0$ and $\zeta>0$. For every $S\in(X\times[-1,1])^n$, the function $F=F_{c,S}$ is continuous and coercive. So $m_*$ is attained, $0\le m_*\le n/c$, and each $\mathcal N_\zeta$ is compact. Moreover

$$
\sup_{S\in(X\times[-1,1])^n}\ \mathbb E_{\Pi_{\sigma,N,S}}\Bigl[(1+F_{c,S})\,\mathbf 1\{F_{c,S}>m_*+\zeta\}\Bigr]\xrightarrow[\sigma\downarrow0]{}0 .
$$

In particular $\sup_S\Pi_\sigma(\mathcal N_\zeta^c)\to0$.

*Proof.* Write $P=P_N$ and $\Lambda=\Lambda_N$. $F$ is continuous, and $F\ge\lvert\Lambda w\rvert^2$ makes it coercive. Also $m_*\le F(0)\le n/c$.

*Lower bound for the normalizer, uniform in $S$.* Let $E=\{\lvert\Lambda w\rvert^2\le n/c\}$ and $\Omega=\{w:\operatorname{dist}(w,E)\le1\}$. Both are compact and convex, and neither depends on $S$. The map $(w,x)\mapsto z_w(x)$ is $C^\infty$, so the following are finite:

$$
G=\max_{\Omega\times[-1,1]^d}\lvert\nabla_wz_w(x)\rvert,\qquad Z=\max_{\Omega\times[-1,1]^d}\lvert z_w(x)\rvert .
$$

For $w,w'\in\Omega$ and every sample,

$$
\lvert F(w)-F(w')\rvert\le\lvert\kappa_N(w)-\kappa_N(w')\rvert+\frac1c\sum_i\lvert z_w(x_i)-z_{w'}(x_i)\rvert\bigl(\lvert z_w(x_i)\rvert+\lvert z_{w'}(x_i)\rvert+2\bigr)\le\ell_F\lvert w-w'\rvert,
$$

where $\lambda_{\max}$ is the largest diagonal entry of $\Lambda$ and $\ell_F:=2\lambda_{\max}\max_\Omega\lvert\Lambda w\rvert+\frac ncG(2Z+2)$; neither depends on $S$. (The bound uses the mean value theorem along segments in the convex set $\Omega$.) A minimizer $w_*$ satisfies $\lvert\Lambda w_*\rvert^2\le F(w_*)\le n/c$, so $w_*\in E$. Put $\rho=\min\{1,\zeta/(4\ell_F)\}$. If $\lvert w-w_*\rvert<\rho$, then $w\in\Omega$ and $F(w)<m_*+\zeta/4$. Hence $V:=\{F<m_*+\zeta/4\}$ contains a ball of radius $\rho$, and

$$
Z_\sigma:=\int e^{-F/(2\sigma^2)}\ \ge\ v_P\rho^P\,e^{-(m_*+\zeta/4)/(2\sigma^2)} ,
$$

where $v_P$ is the volume of the unit ball.

*Upper bound for the tail.* Let $\alpha=\zeta/\bigl(8(n/c+\zeta)\bigr)\in(0,1/8]$ and $\sigma^2\le\alpha/2$. The map $t\mapsto(1+t)e^{-bt}$ is nonincreasing on $[0,\infty)$ when $b\ge1$. So, wherever $F>m_*+\zeta$,

$$
(1+F)e^{-F/(2\sigma^2)}=\bigl[(1+F)e^{-\alpha F/(2\sigma^2)}\bigr]e^{-(1-2\alpha)F/(2\sigma^2)}e^{-\alpha F/(2\sigma^2)}\le e^{-(1-2\alpha)(m_*+\zeta)/(2\sigma^2)}\,e^{-\alpha\lvert\Lambda w\rvert^2/(2\sigma^2)} .
$$

Integrating, using $\int e^{-\alpha\lvert\Lambda w\rvert^2/(2\sigma^2)}dw=(2\pi\sigma^2/\alpha)^{P/2}(\det\Lambda)^{-1}$, and using $(1-2\alpha)(m_*+\zeta)-m_*-\zeta/4=\tfrac34\zeta-2\alpha(m_*+\zeta)\ge\tfrac34\zeta-2\alpha(n/c+\zeta)=\zeta/2$, we get

$$
\mathbb E_{\Pi_\sigma}\bigl[(1+F)\mathbf 1\{F>m_*+\zeta\}\bigr]\le\frac{(2\pi\sigma^2/\alpha)^{P/2}}{\det\Lambda\ v_P\rho^P}\,e^{-\zeta/(4\sigma^2)}\xrightarrow[\sigma\downarrow0]{}0 ,
$$

uniformly in $S$. $\blacksquare$

This is the Laplace argument of the proof of Theorem `strong` in `paper.tex`: a lower bound on the normalizer from an open set of low objective, and a quadratic tail envelope for the exceptional set. Here it is applied to $e^{-F_c/(2\sigma^2)}$ in place of a conditioned prior, so it has been redone rather than cited.

**Corollary 3.2.** Fix $N,n,c,S$, and let $\Phi:\mathcal W_N\to[0,\infty)$ be measurable with $\Phi\le b(1+F_{c,S})$. Then:

1. For every $\zeta>0$, $\ \inf_{\mathcal N_\zeta}\Phi\le\liminf_{\sigma\downarrow0}\mathbb E_{\Pi_\sigma}\Phi\le\limsup_{\sigma\downarrow0}\mathbb E_{\Pi_\sigma}\Phi\le\sup_{\mathcal N_\zeta}\Phi$.
2. If $\Phi$ is continuous, then $\limsup_{\sigma\downarrow0}\mathbb E_{\Pi_\sigma}\Phi\le\max_{\operatorname{argmin}F_{c,S}}\Phi$.
3. $(\Pi_\sigma)_{0<\sigma<1}$ is tight, and every weak limit point as $\sigma\downarrow0$ is a probability measure carried by $\operatorname{argmin}F_{c,S}$.
4. If $A\supseteq\mathcal N_\zeta$ for some $\zeta>0$, then $\Pi_\sigma(A)\to1$.

By Lemma 3.1, every "$\to$" above is uniform over samples $S$, at fixed $(N,n,c,\zeta)$.

*Proof.*

1. $\mathbb E\Phi\le\sup_{\mathcal N_\zeta}\Phi+b\,\mathbb E[(1+F)\mathbf 1_{\mathcal N_\zeta^c}]$, and $\mathbb E\Phi\ge\Pi_\sigma(\mathcal N_\zeta)\inf_{\mathcal N_\zeta}\Phi$.
2. Suppose $\sup_{\mathcal N_{1/k}}\Phi\ge\max_{\operatorname{argmin}}\Phi+\eta$ for every $k$. Choose $w_k\in\mathcal N_{1/k}$ with $\Phi(w_k)\ge\max_{\operatorname{argmin}}\Phi+\eta/2$. By compactness, some subsequence converges to a point of $\bigcap_k\mathcal N_{1/k}=\operatorname{argmin}F$, which contradicts continuity of $\Phi$.
3. Tightness holds because $\Pi_\sigma(\mathcal N_1)\to1$ and $\mathcal N_1$ is compact. For a weak limit $\Pi_0$, the portmanteau theorem gives $\Pi_0(\mathcal N_\zeta)=1$ for every $\zeta$, since $\mathcal N_\zeta$ is closed. Intersect over $\zeta=1/k$.
4. Immediate. $\blacksquare$

We apply Corollary 3.2 to two functionals:

- $\Phi(w)=L_D(\operatorname{clip}z_w)\in[0,4]$;
- $\Phi(w)=L_D(z_w)\le(\sqrt{\kappa_N(w)}+1)^2\le2F_{c,S}(w)+2$, by Lemma 2.1(a).

Both are continuous in $w$ by dominated convergence.

---

## 4. Route 1: the width-independent energy cover

**Proposition 4.1 (imported).** This combines `paper.tex` Lemma `compression`, Proposition `energy-cover` and Remark `cube`.

Let $L\ge2$, $K\ge1$ and $0<a\le1$. There is a finite family $\mathcal H_{K,a}$ of Borel functions on $X$, the same for all widths $N$, such that $\inf_{h}\sup_X\lvert z_w-h\rvert\le a$ whenever $\kappa_N(w)\le K$. Moreover

$$
\lvert\mathcal H_{K,a}\rvert\le\Bigl(1+\frac{2(J+1)}{\Delta_J}\Bigr)^{P_J},
$$

with the source's parameters:

- the input-net radius $r=\min\{1,a\sqrt d/(8K^{L/2})\}$;
- the net size $s\le(1+2\sqrt d/r)^d$;
- $D_T=\max\{1,\lceil\log_2s\rceil\}$;
- $\lambda=a2^{-L}K^{-(L-1)/2}/(4(L-1))$;
- $J=\max\{\lceil4K\rceil,\lceil256\lambda^{-4}[D_T+\ln(L/\lambda)]\rceil\}$;
- $\Delta_J=a/\bigl(4(d+L+1)(2J^2)^L\bigr)$;
- $P_J=J(d+1)+(L-2)J^2+J$.

The source writes $\log(L/\lambda)$; reading it as natural changes nothing below. I checked the statement and every parameter against the source. Its proof of Lemma `compression` is a sketch that refers to a companion paper for the telescoping estimate. Route 1 inherits that dependence; route 2 (Section 5) does not.

**Lemma 4.2 (explicit size and degrees).** Let $K\ge1$ and $0<a\le1$, and define

$$
\ell:=\ln\frac{17dK}a,\qquad C_J:=196609\,L(L-1)^4\,16^L,\qquad \bar J:=C_J\,d\,K^{2(L-1)}a^{-4}\,\ell .
$$

Then $J\le\bar J$, and

$$
\ln\lvert\mathcal H_{K,a}\rvert\le\Gamma_L(d,K,a):=\bigl[(L-2)\bar J^2+(d+2)\bar J\bigr]\Bigl[(2L+1)\ln\bar J+\ln\frac{2^{L+5}(d+L+1)}a\Bigr].
$$

With $C_{\log}:=(2L+1)(\ln C_J+2L+1)+L+6$,

$$
\Gamma_L\le(L-1)C_J^2C_{\log}\;d^2K^{4(L-1)}a^{-8}\ell^3\quad(L\ge3),\qquad
\Gamma_2\le3C_JC_{\log}\;d^2K^2a^{-4}\ell^2\quad(L=2).
$$

So the repository's cover entropy has degree $4(L-1)$ in $K$ and $8$ in $1/a$ when $L\ge3$, and degree $2$ in $K$ and $4$ in $1/a$ when $L=2$, up to the factor $\ell^3$ (respectively $\ell^2$).

*Proof.*

*Step 1: bound on $\Xi:=D_T+\ln(L/\lambda)$.* We have $1/r=\max\{1,8K^{L/2}/(a\sqrt d)\}$. Both entries of $2\sqrt d/r=\max\{2\sqrt d,16K^{L/2}/a\}$ are at most $16\sqrt dK^{L/2}/a$, so $1+2\sqrt d/r\le17\sqrt dK^{L/2}/a\le(17dK/a)^{L/2}$. Hence

$$
D_T\le1+\frac{dL}{2\ln2}\ell\le1+0.722\,dL\ell .
$$

Next, $\ln(L/\lambda)=\ln(4L(L-1))+L\ln2+\tfrac{L-1}2\ln K+\ln\tfrac1a\le2L+\tfrac L2\ell$. Here we used $\ln(4L(L-1))+L\ln2\le2L$ for $L\ge2$, and $\max\{\tfrac{L-1}2,1\}\le\tfrac L2$. Since $\ell\ge\ln17>2.83$,

$$
\Xi\le\ell\bigl(0.354+0.722dL+1.207L\bigr)\le3dL\ell .
$$

*Step 2: bound on $J$.* We have $\lambda^{-4}=256(L-1)^416^LK^{2(L-1)}a^{-4}$. This gives $256\lambda^{-4}\Xi\ge2^{24}K^2\ge4K+1$, so $J\le256\lambda^{-4}\Xi+1\le\bar J$.

*Step 3: the counting factor.* Since $2(J+1)/\Delta_J\ge1$,

$$
\ln\Bigl(1+\frac{2(J+1)}{\Delta_J}\Bigr)\le\ln\frac{32(d+L+1)2^LJ^{2L+1}}a .
$$

Both factors of the count increase in $J$, which gives $\Gamma_L$.

*Step 4: the polynomial form.* $\ln\bar J\le\ln C_J+(2L+1)\ell$, because $\ln d+2(L-1)\ln K+4\ln\frac1a+\ln\ell\le(2L+1)\ell$. Also $\ln\frac{2^{L+5}(d+L+1)}a\le L+5+\ell$. Together, the second factor of $\Gamma_L$ is at most $C_{\log}\ell$.

For $L\ge3$, $\bar J\ge C_Jd\ge3d$, so $(L-2)\bar J^2+(d+2)\bar J\le(L-1)\bar J^2$. For $L=2$ the first factor is $(d+2)\bar J\le3d\bar J$. $\blacksquare$

The script `cover_degree.py` evaluates the source's count exactly (in log space) and fits local log–log slopes, which tend to the stated degrees:

- in $K$: $2.09$ ($L=2$), $8.16$ ($L=3$), $12.18$ ($L=4$) at $K=10^6$;
- in $1/a$: $4.13$ and $8.14$–$8.16$ at $a=10^{-4}$.

So the count gives no better degree. The task's "degree in $K$ about $4(L-1)$ for $L\ge3$" is confirmed. For $L=2$ the degree is $2$, not $4(L-1)=4$.

**Lemma 4.3 (uniform deviation through the cover).** Let $K\ge1$, $a\in(0,1]$ and $\delta'\in(0,1)$. With probability at least $1-\delta'$, for every width $N$ and every $w\in\mathcal W_N$ with $\kappa_N(w)\le K$:

$$
L_D(\operatorname{clip}z_w)\le\hat L_S(\operatorname{clip}z_w)+8a+4\sqrt{\frac{\ln\lvert\mathcal H_{K,a}\rvert+\ln(1/\delta')}{2n}} .
$$

The event does not depend on $N$ or $\sigma$.

*Proof.* For each $h\in\mathcal H_{K,a}$, the losses $(\operatorname{clip}h(x_i)-y_i)^2\in[0,4]$ are i.i.d. with mean $L_D(\operatorname{clip}h)$. By the one-sided Hoeffding inequality, $L_D(\operatorname{clip}h)-\hat L_S(\operatorname{clip}h)>t$ has probability at most $e^{-nt^2/8}$. Take $t=4\sqrt{\ln(\lvert\mathcal H_{K,a}\rvert/\delta')/(2n)}$ and a union bound over the finite family; the resulting event is measurable because the centres are Borel.

On that event, given $w$, pick $h$ with $\sup_X\lvert z_w-h\rvert\le a$. Since clip is 1-Lipschitz and $s\mapsto(s-y)^2$ is 4-Lipschitz on $[-1,1]$ when $\lvert y\rvert\le1$, the two clipped losses differ by at most $4a$ everywhere on $X\times[-1,1]$. Hence

$$
L_D(\operatorname{clip}z_w)\le L_D(\operatorname{clip}h)+4a\le\hat L_S(\operatorname{clip}h)+t+4a\le\hat L_S(\operatorname{clip}z_w)+t+8a.\ \blacksquare
$$

---

## 5. Route 2: a width-free Rademacher bound for energy classes

For a bounded $A\subseteq\mathbb R^n$ put $\operatorname{Rad}(A):=\mathbb E_\epsilon\sup_{a\in A}\frac1n\sum_i\epsilon_ia_i$, where $\epsilon$ is uniform on $\{\pm1\}^n$. For points $x_1,\dots,x_n$ and a class $\mathcal F$, write $\hat{\mathfrak R}_S(\mathcal F)=\operatorname{Rad}\{(f(x_i))_i:f\in\mathcal F\}$.

**Lemma 5.1 (tools).** Let $A\subseteq\mathbb R^n$ be bounded.

- (i) $\operatorname{Rad}(\overline{\operatorname{conv}}A)=\operatorname{Rad}(A)$; $\operatorname{Rad}(\lambda A)=\lambda\operatorname{Rad}(A)$ for $\lambda\ge0$; and $A\subseteq A'$ implies $\operatorname{Rad}(A)\le\operatorname{Rad}(A')$.
- (ii) (Massart) If $A$ is finite and $\max_{a\in A}\lvert a\rvert_2\le R$, then $\operatorname{Rad}(A)\le R\sqrt{2\ln\lvert A\rvert}/n$.
- (iii) (contraction) If $\varphi_1,\dots,\varphi_n:\mathbb R\to\mathbb R$ are 1-Lipschitz, then $\mathbb E\sup_{a\in A}\sum_i\epsilon_i\varphi_i(a_i)\le\mathbb E\sup_{a\in A}\sum_i\epsilon_ia_i$.
- (iv) (clipping) Let $\operatorname{Clip}(A):=\{(\operatorname{clip}_t(a_i))_i:a\in A,\ t\in[0,1]\}$. Then $\operatorname{Rad}(\operatorname{Clip}A)\le\operatorname{Rad}(A)+\frac1{2\sqrt n}$.
- (v) (clip mixture) For $r>0$ and $\lvert u\rvert\le1$,
$$
\frac{\tanh(ru)}r=\int_0^1\operatorname{clip}_t(u)\,2r\tanh(rt)\operatorname{sech}^2(rt)\,dt+\operatorname{sech}^2(r)\operatorname{clip}_1(u),
$$
and the nonnegative weights have total mass $1$.
- (vi) $\tanh s=\mathbb E\operatorname{sign}(s-T)$ when $T$ has distribution function $(1+\tanh t)/2$.

*Proof.*

(i) The supremum of a linear functional over a convex hull or a closure equals its supremum over the set.

(ii) For $\lambda>0$, Jensen's inequality and $\mathbb Ee^{\lambda\sum\epsilon_ia_i}\le e^{\lambda^2R^2/2}$ give $e^{\lambda\mathbb E\sup}\le\lvert A\rvert e^{\lambda^2R^2/2}$. Take $\lambda=\sqrt{2\ln\lvert A\rvert}/R$.

(iii) Condition on $\epsilon_2,\dots,\epsilon_n$ and write $\Psi(a)=\sum_{i\ge2}\epsilon_i\varphi_i(a_i)$. Then

$$
\mathbb E_{\epsilon_1}\sup_a[\epsilon_1\varphi_1(a_1)+\Psi(a)]=\tfrac12\sup_{a,a'}[\varphi_1(a_1)-\varphi_1(a'_1)+\Psi(a)+\Psi(a')]\le\tfrac12\sup_{a,a'}[\lvert a_1-a_1'\rvert+\Psi(a)+\Psi(a')].
$$

The last expression is unchanged if $\lvert a_1-a'_1\rvert$ is replaced by $a_1-a'_1$, since swapping $a$ and $a'$ preserves the rest. So it equals $\mathbb E_{\epsilon_1}\sup_a[\epsilon_1a_1+\Psi(a)]$. Repeat over the coordinates.

(iv) $\operatorname{clip}_t(u)=\frac12(\lvert u+t\rvert-\lvert u-t\rvert)$. Split the supremum and use the symmetry of $\epsilon$:

$$
n\operatorname{Rad}(\operatorname{Clip}A)\le\tfrac12\mathbb E\sup_{a,t}\sum\epsilon_i\lvert a_i+t\rvert+\tfrac12\mathbb E\sup_{a,t}\sum\epsilon_i\lvert a_i-t\rvert .
$$

By (iii) applied to the bounded set $\{(a_i\pm t)_i\}$, the first term is at most $\frac12\bigl(n\operatorname{Rad}(A)+\mathbb E(\sum\epsilon_i)_+\bigr)$ and the second at most $\frac12\bigl(n\operatorname{Rad}(A)+\mathbb E(\sum\epsilon_i)_-\bigr)$. Finally $\mathbb E\lvert\sum\epsilon_i\rvert\le\sqrt n$.

(v) Put $\psi(t)=\tanh^2(rt)$, so the density is $\psi'$, $\psi(1)=\tanh^2r$ and $1-\psi(1)=\operatorname{sech}^2r$. For $u\in[0,1]$, integration by parts gives

$$
\text{RHS}=\int_0^ut\,\psi'(t)\,dt+u\bigl(\psi(1)-\psi(u)\bigr)+u\operatorname{sech}^2r=u-\int_0^u\tanh^2(rt)\,dt=\int_0^u\operatorname{sech}^2(rt)\,dt=\frac{\tanh(ru)}r .
$$

Both sides are odd in $u$.

(vi) $T$ has density $\frac12\operatorname{sech}^2t$, so $\mathbb E\operatorname{sign}(s-T)=\Pr(T<s)-\Pr(T>s)=\tanh s$. $\blacksquare$

**Lemma 5.2 (Rademacher complexity of $\mathcal Z_K$, uniform over widths).** For every $n\ge1$, all points $x_1,\dots,x_n\in\mathbb R^d$ (no boundedness needed) and every $K>0$,

$$
\hat{\mathfrak R}_S(\mathcal Z_K)\le\Bigl(\frac KH\Bigr)^{H/2}\frac{D_n}{\sqrt n},\qquad D_n=\sqrt{2(d+1)\ln(n+1)}+\frac{H-1}2 .
$$

This is `NNG/works-in-progress/noisy-interpolation/README.md` eq. (15), there stated on the Boolean cube. Its cube-specific dichotomy count $\log J\le(d+2)^2$ is replaced here by the Sauer–Shelah lemma. Every step is re-proved.

*Proof.* Write $f\vert_S=(f(x_i))_i$.

*Classes.* Let $\Phi_1=\{(\tanh(a\cdot\bar x_i))_i:a\in\mathbb R^{d+1}\}$, let $\mathcal F_1=\overline{\operatorname{conv}}\,\Phi_1$, and for $2\le\ell\le H$ let $\mathcal F_\ell=\overline{\operatorname{conv}}\operatorname{Clip}(\mathcal F_{\ell-1})$. Since tanh is odd, each $\mathcal F_\ell$ is closed, convex, symmetric, contains $0$, and lies in $[-1,1]^n$.

*Representation.* Fix $N$ and $w$. Put $\rho^1=\mathbf 1_N$ and $\rho^\ell=\lvert W^\ell\rvert\rho^{\ell-1}$, entrywise absolute values. We claim $h^\ell_j\vert_S\in\rho^\ell_j\mathcal F_\ell$ for every $j$ and $\ell$, and that $\rho^\ell_j=0$ forces $h^\ell_j\equiv0$.

For $\ell=1$ this is immediate. For $\ell\ge2$, units with $\rho^{\ell-1}_i=0$ vanish identically by induction. So if $\rho^\ell_j=0$, the preactivation is identically zero and $h^\ell_j=\tanh0=0$. If $\rho_j:=\rho^\ell_j>0$, then

$$
p_j\vert_S=\sum_{i:\rho^{\ell-1}_i>0}W^\ell_{ji}\rho^{\ell-1}_i\,u_i=\rho_j\sum_i\lambda_iu_i,\qquad u_i:=h^{\ell-1}_i\vert_S/\rho^{\ell-1}_i\in\mathcal F_{\ell-1},
$$

with $\sum_i\lvert\lambda_i\rvert=1$. Since $\mathcal F_{\ell-1}$ is symmetric and convex, $u:=\sum_i\lambda_iu_i\in\mathcal F_{\ell-1}\subseteq[-1,1]^n$. By (v), applied coordinatewise with the same weights, $\tanh(\rho_ju)/\rho_j$ is a probability mixture of the vectors $\operatorname{clip}_t(u)\in\operatorname{Clip}(\mathcal F_{\ell-1})$. So it lies in the closed convex hull $\mathcal F_\ell$. That is, $h^\ell_j\vert_S\in\rho_j\mathcal F_\ell$.

For the output, put $P(w):=\lvert v\rvert^\top\rho^H$. Then $z_w\vert_S=\sum_jv_j\rho^H_j(h^H_j\vert_S/\rho^H_j)\in P(w)\mathcal F_H$, using the same convexity and symmetry argument; if $P(w)=0$ then $z_w\equiv0$.

*Path norm.* By Cauchy–Schwarz and $\lVert\,\lvert W\rvert\,\rVert_{\rm op}\le\lVert W\rVert_F$,

$$
P(w)\le\lVert v\rVert_2\prod_{\ell=2}^H\lVert W^\ell\rVert_F\,\lVert\mathbf 1_N\rVert_2=\Bigl(a_L\prod_{\ell=2}^Ha_\ell\Bigr)^{1/2}\le\Bigl(\frac{\kappa_N(w)}H\Bigr)^{H/2}
$$

by AM–GM over $H$ numbers; the first-layer energy is not used. Because $\mathcal F_H$ is convex and contains $0$, we get $\{z\vert_S:z\in\mathcal Z_K\}\subseteq(K/H)^{H/2}\mathcal F_H$.

*Peeling.* By (i) and (iv), $\operatorname{Rad}(\mathcal F_\ell)=\operatorname{Rad}(\operatorname{Clip}\mathcal F_{\ell-1})\le\operatorname{Rad}(\mathcal F_{\ell-1})+\frac1{2\sqrt n}$. Hence $\operatorname{Rad}(\mathcal F_H)\le\operatorname{Rad}(\mathcal F_1)+\frac{H-1}{2\sqrt n}$.

*First layer.* Let $\mathcal D_S\subseteq\{\pm1\}^n$ be the set of vectors $(\operatorname{sign}(a\cdot\bar x_i-b))_i$ with no zero entry. These are the dichotomies of the points by open affine halfspaces of $\mathbb R^d$, a class of VC dimension $d+1$. So, by Sauer–Shelah,

$$
\lvert\mathcal D_S\rvert\le\sum_{k\le d+1}\binom nk\le(n+1)^{d+1}.
$$

By (vi), $(\tanh(a\cdot\bar x_i))_i=\mathbb E_T(\operatorname{sign}(a\cdot\bar x_i-T))_i$. For all but finitely many $T$ the vector lies in $\mathcal D_S$, so $\Phi_1\subseteq\operatorname{conv}\mathcal D_S$, which is a closed polytope; hence $\mathcal F_1\subseteq\operatorname{conv}\mathcal D_S$. By (i) and (ii) with $R=\sqrt n$,

$$
\operatorname{Rad}(\mathcal F_1)\le\sqrt{2(d+1)\ln(n+1)/n}.
$$

Combining the three steps proves the lemma. $\blacksquare$

**Lemma 5.3 (uniform deviation).** Let $K>0$ and $\delta'\in(0,1)$.

- (a) With probability $\ge1-\delta'$, for all $z\in\mathcal Z_K$,
$$
L_D(\operatorname{clip}z)\le\hat L_S(\operatorname{clip}z)+8\Bigl(\frac KH\Bigr)^{H/2}\frac{D_n}{\sqrt n}+4\sqrt{\frac{\ln(1/\delta')}{2n}} .
$$
- (b) With probability $\ge1-\delta'$, for all $z\in\mathcal Z_K$,
$$
L_D(z)\le\hat L_S(z)+4(\sqrt K+1)\Bigl(\frac KH\Bigr)^{H/2}\frac{D_n}{\sqrt n}+(\sqrt K+1)^2\sqrt{\frac{\ln(1/\delta')}{2n}} .
$$

Both events are measurable and do not depend on $N$ or $\sigma$.

*Proof.* Let $\psi:\mathbb R\times[-1,1]\to[0,b]$ be such that $\psi(\cdot,y)$ is $\gamma$-Lipschitz for every $y$:

- in (a), $\psi(u,y)=(\operatorname{clip}u-y)^2$, with $b=4$ and $\gamma=4$;
- in (b), $\psi(u,y)=(\operatorname{clip}_{\sqrt K}u-y)^2$, with $b=(\sqrt K+1)^2$ and $\gamma=2(\sqrt K+1)$; this equals $(u-y)^2$ for $u=z(x)$ with $z\in\mathcal Z_K$, by Lemma 2.1(a).

*Countable reduction.* For fixed $S$, the map $w\mapsto\mathbb E_D\psi(z_w(x),y)-\frac1n\sum_i\psi(z_w(x_i),y_i)$ is continuous on $\mathcal W_N$ (dominated convergence). The closed ellipsoid $\{\kappa_N\le K\}$ is the closure of the rational points of the open one. So $\Phi(S):=\sup_{z\in\mathcal Z_K}[\mathbb E\psi(z)-\hat{\mathbb E}_S\psi(z)]$ equals the same supremum over a countable class $\mathcal Q$ (rational parameters, all $N$), and is therefore measurable.

*Concentration.* $\Phi$ has bounded differences $b/n$. McDiarmid's inequality gives $\Phi\le\mathbb E\Phi+b\sqrt{\ln(1/\delta')/(2n)}$ with probability $\ge1-\delta'$.

*Symmetrization.* With a ghost sample $S'$,

$$
\mathbb E\Phi\le\mathbb E\sup_{\mathcal Q}\frac1n\sum_i\epsilon_i\bigl[\psi(z(x'_i),y'_i)-\psi(z(x_i),y_i)\bigr]\le2\,\mathbb E_S\mathbb E_\epsilon\sup_{\mathcal Q}\frac1n\sum_i\epsilon_i\psi(z(x_i),y_i).
$$

By Lemma 5.1(iii), applied conditionally on $S$ with $\varphi_i=\psi(\cdot,y_i)/\gamma$, this is at most $2\gamma\,\mathbb E\hat{\mathfrak R}_S(\mathcal Z_K)$. Lemma 5.2 bounds that by $2\gamma(K/H)^{H/2}D_n/\sqrt n$. $\blacksquare$

---

## 6. Main theorems

**Proposition 6.1 (reduction to a capacity bound).** Fix $n\ge1$, $c>0$, $\delta\in(0,1)$, $D$ and a competitor $g$, and put $K:=n/c+1$. Suppose $\mathcal E_1$ is an event with $\Pr(\mathcal E_1)\ge1-\delta/2$ on which

$$
\sup_{z\in\mathcal Z_K}\bigl[L_D(\operatorname{clip}z)-\hat L_S(\operatorname{clip}z)\bigr]\le\Psi .
$$

Let $\mathcal E_2:=\{\hat L_S(g)\le L_D(g)+(U+1)^2\sqrt{\ln(2/\delta)/(2n)}\}$. Then $\Pr(\mathcal E_2)\ge1-\delta/2$ by one-sided Hoeffding, since the losses of $g$ lie in $[0,(U+1)^2]$. On $\mathcal E:=\mathcal E_1\cap\mathcal E_2$, for **every** width $N\ge m$, with

$$
\mathrm{Exc}:=\frac{c(E_*+1)}n+\Psi+(U+1)^2\sqrt{\frac{\ln(2/\delta)}{2n}}:
$$

1. every $w\in\mathcal N^{(N)}_1(S)$ has $L_D(\operatorname{clip}z_w)\le L_D(g)+\mathrm{Exc}$;
2. $\Pi_{\sigma,N,S}\{w:L_D(\operatorname{clip}z_w)>L_D(g)+\mathrm{Exc}\}\to0$, and every weak limit point of $\Pi_{\sigma,N,S}$ as $\sigma\downarrow0$ is carried by $\operatorname{argmin}F_{c,S}$, a set on which $L_D(\operatorname{clip}z_w)\le L_D(g)+\mathrm{Exc}$;
3. $\limsup_{\sigma\downarrow0}\mathcal G^{\rm clip}_\sigma\le L_D(g)+\mathrm{Exc}$ (Gibbs predictor);
4. $\limsup_{\sigma\downarrow0}L_D(\bar f_\sigma)\le L_D(g)+\mathrm{Exc}$ (posterior mean of the clipped outputs).

Suppose instead that $\mathcal E_1$ is an event with $\Pr(\mathcal E_1)\ge1-\delta/2$ on which $\sup_{z\in\mathcal Z_K}[L_D(z)-\hat L_S(z)]\le\Psi'$. Then, on $\mathcal E_1\cap\mathcal E_2$, statements 1–3 hold for $L_D(z_w)$ and $\mathcal G_\sigma$, and statement 4 holds for $L_D(\bar z_\sigma)$ and $L_D(\operatorname{clip}\bar z_\sigma)$, all with $\mathrm{Exc}':=c(E_*+1)/n+\Psi'+(U+1)^2\sqrt{\ln(2/\delta)/(2n)}$.

*Proof.*

*Statement 1.* Let $w\in\mathcal N_1^{(N)}$. Lemma 2.3(a) gives $\kappa_N(w)\le K$, so $z_w\in\mathcal Z_K$. By (1.1) and Lemma 2.3(c),

$$
L_D(\operatorname{clip}z_w)\le\hat L_S(\operatorname{clip}z_w)+\Psi\le\hat L_S(z_w)+\Psi\le\hat L_S(g)+\frac{c(E_*+1)}n+\Psi\le L_D(g)+\mathrm{Exc}.
$$

*Statements 2–3.* The set $A=\{L_D(\operatorname{clip}z_w)\le L_D(g)+\mathrm{Exc}\}$ is closed and contains $\mathcal N_1\supseteq\operatorname{argmin}F_{c,S}$. Apply Corollary 3.2 (4, 3 and 1, with $\Phi=L_D(\operatorname{clip}z_w)\le4$).

*Statement 4.* By Jensen's inequality pointwise and Tonelli's theorem, $L_D(\bar f_\sigma)\le\mathcal G^{\rm clip}_\sigma$.

*Unclipped version.* The same chain without the step (1.1) gives statement 1. The Gibbs statement uses $\Phi=L_D(z_w)\le2F+2$ in Corollary 3.2. For the mean, $\mathbb E_{\Pi_\sigma}\lvert z_w(x)\rvert\le\mathbb E_{\Pi_\sigma}\sqrt F<\infty$, Jensen and Tonelli give $L_D(\bar z_\sigma)\le\mathcal G_\sigma$, and $L_D(\operatorname{clip}\bar z_\sigma)\le L_D(\bar z_\sigma)$ by (1.1). $\blacksquare$

Because Lemma 3.1 is uniform in $S$, statements 2–4 also hold in a stronger form. For every $N\ge m$ and $\eta>0$ there is $\sigma_0(N,n,c,d,H,\eta)$, independent of $D$, $\delta$, $g$ and $S$, such that for all $\sigma<\sigma_0$, on $\mathcal E$: the bad posterior mass is at most $\eta$, and $\mathcal G^{\rm clip}_\sigma\le L_D(g)+\mathrm{Exc}+4\eta$.

**Theorem 6.2 (Claim B through the repository's energy cover).** Let $c=n^{1-\theta}$ with $0<\theta<1/(4(L-1))$ if $L\ge3$, or $0<\theta<1/2$ if $L=2$. Put $\varrho:=1-4(L-1)\theta$ (resp. $1-2\theta$) and $a:=\varepsilon/32$. Let

$$
n\ \ge\ n_1:=\max\Bigl\{\Bigl(\frac{4(E_*+1)}\varepsilon\Bigr)^{1/\theta},\ \frac{8(U+1)^4\ln(2/\delta)}{\varepsilon^2},\ \frac{256\ln(2/\delta)}{\varepsilon^2},\ n_{\rm cov}\Bigr\}.
$$

For $L\ge3$, set $C_*:=256\,(L-1)C_J^2C_{\log}\,2^{4(L-1)}32^8\,d^2\varepsilon^{-10}$ and

$$
n_{\rm cov}=\max\Bigl\{\bigl(8C_*\ln^3\tfrac{1088d}\varepsilon\bigr)^{1/\varrho},\ \bigl(8C_*\theta^3(6/(e\varrho))^3\bigr)^{2/\varrho}\Bigr\}.
$$

For $L=2$, set $C_*:=256\cdot3C_JC_{\log}\cdot4\cdot32^4d^2\varepsilon^{-6}$ and

$$
n_{\rm cov}=\max\Bigl\{\bigl(4C_*\ln^2\tfrac{1088d}\varepsilon\bigr)^{1/\varrho},\ \bigl(4C_*\theta^2(4/(e\varrho))^2\bigr)^{2/\varrho}\Bigr\}.
$$

Then statements 1–4 of Proposition 6.1 hold with $\mathrm{Exc}\le\varepsilon$, on an event of probability $\ge1-\delta$ that does not depend on $N$ or $\sigma$, for every $N\ge m$. In particular $n_1$ is polynomial in $d,m,B,1/\varepsilon,\log(1/\delta)$ at fixed $L,\theta$.

*Proof.* Apply Lemma 4.3 with $K=n^\theta+1$ and $\delta'=\delta/2$; then Proposition 6.1 gives

$$
\mathrm{Exc}=(E_*+1)n^{-\theta}+\frac\varepsilon4+4\sqrt{\frac{\ln\lvert\mathcal H_{K,a}\rvert+\ln(2/\delta)}{2n}}+(U+1)^2\sqrt{\frac{\ln(2/\delta)}{2n}} .
$$

The first and last terms are at most $\varepsilon/4$ once $n$ exceeds the first two entries of $n_1$. The third is at most $\varepsilon/4$ when $n\ge256\ln\lvert\mathcal H\rvert/\varepsilon^2$ and $n\ge256\ln(2/\delta)/\varepsilon^2$.

For the first of these: Lemma 4.2 and monotonicity in $K$ give $\ln\lvert\mathcal H\rvert\le\Gamma_L(d,2n^\theta,\varepsilon/32)$. For $L\ge3$ this yields $256\ln\lvert\mathcal H\rvert/\varepsilon^2\le C_*n^{4(L-1)\theta}\ell_n^3$ with $\ell_n=\ln(1088d/\varepsilon)+\theta\ln n$. Now use $\ell_n^3\le4\ln^3(1088d/\varepsilon)+4\theta^3\ln^3n$ and $\ln n\le\frac6{e\varrho}n^{\varrho/6}$. Then $C_*\ell_n^3\le n^\varrho$ holds once each of the two parts is at most $n^\varrho/2$, which is exactly the condition $n\ge n_{\rm cov}$. For $L=2$, argue in the same way with squares and $\ln n\le\frac4{e\varrho}n^{\varrho/4}$. $\blacksquare$

The numbers are astronomically large. For $L=3$, $d=10$, $m=B=1$, $\varepsilon=0.1$, $\delta=0.05$, the bound first drops below $\varepsilon$ at $n\approx10^{101}$; for $L=2$ the threshold is about $10^{54}$ (`sample_sizes.out`). The exponent is the real limitation: the entropy grows like $K^{4(L-1)}=n^{4(L-1)\theta}$.

**Remark 6.2′ (unclipped outputs via the cover).** The same route handles $L_D(z_w)$ only for smaller $\theta$. On $\{\kappa_N\le K\}$ we have $\lvert z_w\rvert\le\sqrt K$ (Lemma 2.1(a)), so we may clip the cover centres at $\pm\sqrt K$ without losing accuracy. The square loss on $[-\sqrt K,\sqrt K]$ has range $(\sqrt K+1)^2$ and Lipschitz constant $2(\sqrt K+1)$. Hoeffding plus a union bound then gives a deviation of

$$
4(\sqrt K+1)a+(\sqrt K+1)^2\sqrt{(\ln\lvert\mathcal H_{K,a}\rvert+\ln(2/\delta))/(2n)} .
$$

This forces $a\lesssim\varepsilon/\sqrt K$. By Lemma 4.2 the entropy is then $\tilde O(K^{4(L-1)}K^4)=\tilde O(K^{4L})$ for $L\ge3$ and $\tilde O(K^4)$ for $L=2$. With $K\approx n^\theta$ the deviation tends to $0$ iff $\theta<1/(4L+2)$ ($L\ge3$), respectively $\theta<1/6$ ($L=2$). These are limits of this proof route, not of the learner; Theorem 6.4 does better.

**Theorem 6.3 (Claim B, sharp exponent; clipped predictions).** Let $L=H+1\ge2$, $\theta\in(0,1/H)$ (any $\theta\in(0,1)$ when $H=1$) and $c=n^{1-\theta}$. Let $X$, $D$, $g$ (width $m$, weights in $[-B,B]$) be arbitrary and $\delta\in(0,1)$. There is an event $\mathcal E$ with $D^n(\mathcal E)\ge1-\delta$, not depending on $N$ or $\sigma$, on which statements 1–4 of Proposition 6.1 hold for every learner width $N\ge m$ with

$$
\mathrm{Exc}\le\mathrm{Exc}_n:=(E_*+1)\,n^{-\theta}+8\Bigl(\frac2H\Bigr)^{H/2}D_n\,n^{-(1-\theta H)/2}+\bigl(4+(U+1)^2\bigr)\sqrt{\frac{\ln(2/\delta)}{2n}} .
$$

Moreover $\mathrm{Exc}_n\le\varepsilon$ whenever

$$
n\ge n_0:=\max\Bigl\{\Bigl(\frac{3(E_*+1)}\varepsilon\Bigr)^{\frac1\theta},\ \Bigl(\frac{48(2/H)^{H/2}}\varepsilon\sqrt{\frac{4(d+1)}{1-\theta H}}\Bigr)^{\frac4{1-\theta H}},\ \Bigl(\frac{24(2/H)^{H/2}(H-1)}\varepsilon\Bigr)^{\frac2{1-\theta H}},\ \frac{9\bigl(4+(U+1)^2\bigr)^2\ln(2/\delta)}{2\varepsilon^2}\Bigr\}.
$$

The third entry is omitted when $H=1$. Recall $E_*=d(d+1)B^2+2(L-1)m^2B^2$ and $U=mB$. At $\theta=1/(H+2)$,

$$
\mathrm{Exc}_n\le\bigl[E_*+1+8(2/H)^{H/2}D_n\bigr]\,n^{-1/(H+2)}+\bigl(4+(U+1)^2\bigr)\sqrt{\ln(2/\delta)/(2n)}=\tilde O\bigl(\mathrm{poly}(d,m,B)\,n^{-1/(H+2)}\bigr).
$$

*Proof.* Apply Lemma 5.3(a) with $K=n^\theta+1\le2n^\theta$ and $\delta'=\delta/2$. It gives $\Psi\le8(2/H)^{H/2}D_nn^{-(1-\theta H)/2}+4\sqrt{\ln(2/\delta)/(2n)}$, and Proposition 6.1 gives the bound $\mathrm{Exc}_n$.

*Sample size.* Put $\gamma=(1-\theta H)/2\in(0,\frac12]$. For $n\ge1$ we have $\ln(n+1)\le n^\gamma/\gamma$. At $n=1$ this reads $\ln2<2\le1/\gamma$, and the derivative of $n^\gamma/\gamma-\ln(n+1)$, namely $n^{\gamma-1}-\frac1{n+1}$, is positive for $n\ge1$. Hence $8(2/H)^{H/2}\sqrt{2(d+1)\ln(n+1)}\,n^{-\gamma}\le8(2/H)^{H/2}\sqrt{2(d+1)/\gamma}\,n^{-\gamma/2}$, which is $\le\varepsilon/6$ by the second entry of $n_0$. The $(H-1)/2$ part of $D_n$ contributes $\le\varepsilon/6$ by the third entry. The first and last terms of $\mathrm{Exc}_n$ are each $\le\varepsilon/3$ by the first and fourth entries. $\blacksquare$

In words: at every width $N\ge m$, the tempered strong-prior posterior competes with every fixed depth-$L$ network of polynomially bounded width and weights, for every data law with labels in $[-1,1]$. $n_0$ is explicit and polynomial. Its degree in $E_*$ (hence in $d,m,B$) is $1/\theta$, its degree in $1/\varepsilon$ is $\max\{1/\theta,4/(1-\theta H)\}$, and it is linear in $\log(1/\delta)$ at fixed accuracy. At $L=3$, $d=10$, $m=B=1$, $\varepsilon=0.1$, $\delta=0.05$, $\theta=1/4$, the bound $\mathrm{Exc}_n\le\varepsilon$ first holds at $n\approx10^{13.4}$, while the closed form $n_0$ is about $10^{29}$ (`sample_sizes.out`). These are worst-case constants, not predictions.

**Theorem 6.4 (unclipped outputs).** Let $\theta\in(0,1/L)$ and $c=n^{1-\theta}$. On an event of probability $\ge1-\delta$, not depending on $N$ or $\sigma$, the unclipped statements of Proposition 6.1 hold for every $N\ge m$: near-minimizers $L_D(z_w)$, posterior support, Gibbs $\mathcal G_\sigma$, and posterior mean $\bar z_\sigma$ and its clip. The excess satisfies

$$
\mathrm{Exc}'\le(E_*+1)n^{-\theta}+4(1+\sqrt2)\Bigl(\frac2H\Bigr)^{H/2}D_n\,n^{-(1-\theta L)/2}+\bigl[(1+\sqrt2)^2n^\theta+(U+1)^2\bigr]\sqrt{\frac{\ln(2/\delta)}{2n}} .
$$

This is $\le\varepsilon$ for

$$
n\ge\max\Bigl\{\Bigl(\tfrac{3(E_*+1)}\varepsilon\Bigr)^{\frac1\theta},\Bigl(\tfrac{24(1+\sqrt2)(2/H)^{H/2}}\varepsilon\sqrt{\tfrac{4(d+1)}{1-\theta L}}\Bigr)^{\frac4{1-\theta L}},\Bigl(\tfrac{12(1+\sqrt2)(2/H)^{H/2}(H-1)}\varepsilon\Bigr)^{\frac2{1-\theta L}},\Bigl(\tfrac{6(1+\sqrt2)^2\sqrt{\ln(2/\delta)/2}}\varepsilon\Bigr)^{\frac2{1-2\theta}},\tfrac{18(U+1)^4\ln(2/\delta)}{\varepsilon^2}\Bigr\}.
$$

*Proof.* Apply Lemma 5.3(b) with $K=n^\theta+1$ and $\delta'=\delta/2$, using $\sqrt K+1\le(1+\sqrt2)n^{\theta/2}$, and the unclipped part of Proposition 6.1. The sample-size arithmetic is the same as in Theorem 6.3 with $\gamma'=(1-\theta L)/2$; the term $(1+\sqrt2)^2n^\theta\sqrt{\ln(2/\delta)/(2n)}$ needs $\theta<1/2$, which holds since $\theta<1/L$. $\blacksquare$

**Remark 6.5 (energy-penalized form, and uniformity over competitors).** The competitor entered the proof of Proposition 6.1 only through Lemma 2.3(b). Let $w'\in\mathcal W_N$ be fixed independently of the sample (it may depend on $D$). Then, on $\mathcal E_1\cap\mathcal E_2(w')$, every $w\in\mathcal N^{(N)}_1$ satisfies

$$
L_D(\operatorname{clip}z_w)\le L_D(z_{w'})+n^{-\theta}\bigl(\kappa_N(w')+1\bigr)+\Psi+\bigl(\sqrt{\kappa_N(w')}+1\bigr)^2\sqrt{\ln(2/\delta)/(2n)}.
$$

Here $U'\le\sqrt{\kappa_N(w')}$ by Lemma 2.1(a). Applying this to a minimizer of $L_D(z_{w'})+n^{-\theta}\kappa_N(w')$ over the compact set $\{\kappa_N\le E_0\}$ shows that the posterior performs like the **energy-penalized population optimum**, up to $n^{-\theta}+\Psi+O(E_0n^{-1/2}\sqrt{\ln(2/\delta)})$. The quantity $E_*$ enters only as an upper bound on the energy of one representation of $g$; any cheaper representation may be used. With $w'=0$ one may take $E_*=0$ and $U=0$; this is used in Section 7. The penalty $n^{-\theta}\kappa_N$ is not an artefact (Section 9).

**Remark 6.6 (where the exponent comes from).** The middle term of $\mathrm{Exc}_n$ is the Rademacher complexity of $\mathcal Z_K$ at the energy budget $K\approx n/c=n^\theta$. It is of order $K^{H/2}D_n/\sqrt n$, and it vanishes iff $\theta<1/H$.

- The first layer is charged through the VC dimension $d+1$ of affine halfspaces (the factor $D_n$), not through its energy. A norm-based layer-peeling bound that charges all $L$ layers, including $\lVert W^1\rVert_F$, is of order $(K/L)^{L/2}/\sqrt n$ up to constants, by the same AM–GM step as in Lemma 2.1(b). It would give only $\theta<1/L$. This is the "$K^{L/2}/\sqrt n$" bound anticipated in the task, and it is not proved separately here because Lemma 5.2 is stronger.
- The energy cover gives only $\theta<1/(4(L-1))$.
- Unclipped outputs pay an extra factor $\sqrt K$, from the Lipschitz constant of the square loss on $\lvert u\rvert\le\sqrt K$; hence $\theta<1/L$ in Theorem 6.4.
- $D_n$ is of order $\sqrt{d\log n}$, so the theorem is informative when $n\gg d\log n$. If $d+1\ge n$ and the points are in general position, then $\lvert\mathcal D_S\rvert=2^n$ and Lemma 5.2 is vacuous.

Section 7 shows that the exponent $1/H$ cannot be improved for clipped predictors.

---

## 7. Sharpness: the phase transition at $\theta=1/H$ (positive side of Claim D, completed)

Throughout this section $H\ge2$. The **noisy cube** $D^{\rm cube}_d$ has $x$ uniform on $X=\{-1,1\}^d$ ($M=2^d$) and $y$ a fair sign independent of $x$. Then $L_D(f)=1+M^{-1}\sum_{x\in X}f(x)^2$, and the zero network attains $\mathrm{OPT}=1$; the zero network has width 1, every weight bound, and energy $0$.

For a sample of size $n$ let:

- $k_x=\#\{i:x_i=x\}$ and $T=\{x:k_x\ge1\}$;
- $\bar y_x=k_x^{-1}\sum_{i:x_i=x}y_i$ for $x\in T$;
- $\mathcal R(f)=\sum_{x\in T}k_x(f(x)-\bar y_x)^2$ and $W=\sum_i(y_i-\bar y_{x_i})^2$;
- $Q=\sum_{x\in T}\bar y_x^2$ and $S_1=\#\{x:k_x=1\}$.

**Lemma 7.1 (cube facts).**

- (a) $\sum_i(f(x_i)-y_i)^2=\mathcal R(f)+W$ for every $f:X\to\mathbb R$.
- (b) $\sum_{x\in X}f(x)^2\ge\bigl(\sqrt Q-\sqrt{\mathcal R(f)}\bigr)_+^2$.
- (c) $\mathcal R(\operatorname{clip}f)\le\mathcal R(f)$, and $\mathcal R$ is convex in $f$.
- (d) $Q\ge S_1$. If $n=M$, then $\Pr\bigl(S_1<M/e-M^{2/3}\bigr)\le e^{-M^{1/3}/2}$.

*Proof.*

(a) Within an atom, $\sum_{i:x_i=x}(f(x)-y_i)^2=k_x(f(x)-\bar y_x)^2+\sum_{i:x_i=x}(y_i-\bar y_x)^2$.

(b) By the triangle inequality in $\ell^2(T)$ and $k_x\ge1$, $(\sum_Tf^2)^{1/2}\ge\sqrt Q-(\sum_T(f-\bar y)^2)^{1/2}\ge\sqrt Q-\sqrt{\mathcal R(f)}$.

(c) $\bar y_x\in[-1,1]$, so clipping does not increase any term; each term of $\mathcal R$ is a convex quadratic in $f$.

(d) Singletons have $\bar y_x^2=1$. When $n=M$, $\mathbb ES_1=M(1-1/M)^{M-1}\ge M/e$, using $\ln(1-x)\ge-x/(1-x)$. Moving one input changes $S_1$ by at most $2$, so McDiarmid's inequality gives $\Pr(S_1\le\mathbb ES_1-u)\le e^{-u^2/(2n)}$. Take $u=M^{2/3}$. $\blacksquare$

**Lemma 7.2 (a real-valued memorizer).** Let $H\ge2$, $d\ge1$, let $r:X\to[-1,1]$ satisfy $\sum_xr(x)^2\le s$ for some $s\ge1$, and let $t\in(0,1/4]$. Put

$$
A_{\max}=(d+1)\sqrt s,\qquad\beta=\max\Bigl\{1,\tfrac12\ln\frac{2A_{\max}}t\Bigr\},\qquad R^2=\max\Bigl\{2,\frac9{4t},A_{\max}^{2/H}\Bigr\},\qquad m_t=\Bigl\lceil\frac{2(d+1)A_{\max}^2\ln2}{t^2}\Bigr\rceil+1 .
$$

For every width $N\ge m_t$ there is $w\in\mathcal W_N$ with

$$
\sup_{x\in X}\lvert z_w(x)-r(x)\rvert\le3t,\qquad \kappa_N(w)\le K_{\rm mem}:=\beta^2d^3+(H+1)R^2 .
$$

The construction follows `noisy-interpolation/README.md` §§2–3, which handles sign corrections at accuracy $1/4$. Here it is redone for real values and accuracy $3t$, with the README's binomial parity identity replaced by an elementary staircase.

*Proof.* If $r\equiv0$, take $w=0$.

*Step 1 (Fourier).* With normalized coefficients $\hat r(S)=M^{-1}\sum_xr(x)\chi_S(x)$, Parseval and Cauchy–Schwarz over the $M$ coefficients give $\sum_S\lvert\hat r(S)\rvert\le(\sum_xr(x)^2)^{1/2}\le\sqrt s$.

*Step 2 (staircase parities).* Let $\lvert S\rvert=k\ge1$ and $t_S(x)=\sum_{i\in S}x_i\in\{-k,-k+2,\dots,k\}$. Then $\chi_S=\phi(t_S)$ with $\phi(t)=(-1)^{(k-t)/2}$. Let $\vartheta_j=-k+2j-1$ for $j=1,\dots,k$; these are the midpoints between consecutive values of $t_S$, and $\phi$ jumps by $\Delta_j=\pm2$ at $\vartheta_j$. Since $\phi(t)=\phi(-k)+\sum_{\vartheta_j<t}\Delta_j=\phi(k)-\sum_{\vartheta_j>t}\Delta_j$, averaging gives

$$
\chi_S(x)=c^S_0+\sum_{j=1}^k\frac{\Delta_j}2\operatorname{sign}\bigl(a_{S,j}\cdot\bar x\bigr),\qquad a_{S,j}=(-\vartheta_j,\mathbf 1_S),\qquad c^S_0=\tfrac{\phi(-k)+\phi(k)}2\in\{0,1\}.
$$

Write $1=\operatorname{sign}(a_0\cdot\bar x)$ with $a_0=e_0$. Every row used has $\lvert a\cdot\bar x\rvert\ge1$ on $X$: $t_S-\vartheta_j$ is an odd integer. It also has $\lvert a\rvert^2\le(k-1)^2+k\le d^2$. The coefficients have $\ell^1$ norm at most $k+1\le d+1$; for $S=\emptyset$, $\chi_\emptyset=\operatorname{sign}(a_0\cdot\bar x)$. Absorb signs into rows, using oddness. Then

$$
r(x)=A\,\mathbb E_{\omega\sim\pi}\operatorname{sign}(\omega\cdot\bar x),\qquad A\le(d+1)\sum_S\lvert\hat r(S)\rvert\le A_{\max},
$$

for a probability law $\pi$ on finitely many rows of norm at most $d$ and margin at least $1$ on $X$.

*Step 3 (tanh).* Put $r_\beta=A\,\mathbb E_\pi\tanh(\beta\omega\cdot\bar x)$. Since $1-\tanh b\le2e^{-2b}$, we get $\sup_X\lvert r_\beta-r\rvert\le2A_{\max}e^{-2\beta}\le t$.

*Step 4 (sampling).* Draw $\omega_1,\dots,\omega_{m_t}$ i.i.d. from $\pi$ and put $g=\frac A{m_t}\sum_j\tanh(\beta\omega_j\cdot\bar x)$. The terms lie in $[-A,A]$. By Hoeffding's inequality and a union bound over the $M$ points,

$$
\Pr\bigl(\sup_X\lvert g-r_\beta\rvert>t\bigr)\le2Me^{-m_tt^2/(2A^2)}<1,
$$

because $m_t>2A_{\max}^2\ln(2M)/t^2$ and $\ln(2M)=(d+1)\ln2$. Fix a realization outside this event. Then $\lvert g-r\rvert\le2t$ and $\lvert g\rvert\le3/2$.

*Step 5 (network).* Split the $N$ first-layer neurons into $m_t$ groups of sizes $k_j\ge\lfloor N/m_t\rfloor\ge N/(2m_t)$; neurons in group $j$ get row $\beta\omega_j$. Then $a_1\le\frac dN\cdot N\beta^2d^2=\beta^2d^3$.

Every layer-2 neuron receives weight $A/(m_tk_jR^{H-1})$ from each copy of feature $j$, so its preactivation is $g/R^{H-1}$. This layer costs

$$
a_2=N\sum_jk_j\Bigl(\frac A{m_tk_jR^{H-1}}\Bigr)^2\le\frac{2A^2}{R^{2H-2}}\le2R^2,
$$

since $A^2\le A_{\max}^2\le R^{2H}$. Layers $3,\dots,H$ have all weights $R/N$, each costing $R^2$. The readout is $R/N$ per neuron, costing $R^2$. The total is at most $\beta^2d^3+(H+1)R^2$.

*Step 6 (chain error).* Let $s_2=g/R^{H-1}$, $u_\ell=\tanh(s_\ell)$, $s_\ell=Ru_{\ell-1}$ for $\ell\ge3$, and $z=Ru_H$. Write $\tilde s_\ell=g/R^{H-\ell+1}$, so the identity chain gives $z=g$. Inductively $\lvert s_\ell\rvert\le\lvert\tilde s_\ell\rvert$. Using $\lvert\tanh s-s\rvert\le\lvert s\rvert^3/3$,

$$
\lvert u_\ell-\tilde s_\ell\rvert\le\frac{\lvert\tilde s_\ell\rvert^3}3+R\lvert u_{\ell-1}-\tilde s_{\ell-1}\rvert .
$$

Unrolling,

$$
\lvert z-g\rvert\le\frac{\lvert g\rvert^3}3\sum_{i=1}^{H-1}R^{-2i}\le\frac{2\lvert g\rvert^3}{3R^2}\le\frac9{4R^2}\le t .
$$

Together with Step 4, $\lvert z-r\rvert\le3t$ on $X$. $\blacksquare$

**Proposition 7.3 (memorization, for any $c$).** Let $H\ge2$, $n=M=2^d$, $c>0$ and $t\in(0,1/4]$, and let $K_{\rm mem}$ and $m_t$ be as in Lemma 7.2 with $s=n$. Put $\varepsilon_{c,t}:=\frac cn(K_{\rm mem}+1)+9t^2$. On the event $\{S_1\ge M/e-M^{2/3}\}$, of probability $\ge1-e^{-M^{1/3}/2}$, for every width $N\ge m_t$ and every $w\in\mathcal N_1^{(N)}(S)$:

$$
L_D(z_w)\ \ge\ L_D(\operatorname{clip}z_w)\ \ge\ 1+\Bigl(\sqrt{1/e-M^{-1/3}}-\sqrt{\varepsilon_{c,t}}\Bigr)_+^2 .
$$

The same lower bound holds for the $\liminf_{\sigma\downarrow0}$ of $\mathcal G^{\rm clip}_\sigma$, $\mathcal G_\sigma$, $L_D(\bar f_\sigma)$, $L_D(\bar z_\sigma)$ and $L_D(\operatorname{clip}\bar z_\sigma)$.

*Proof.*

*Near-minimizers.* Apply Lemma 7.2 to $r=\bar y\mathbf 1_T$; then $\lvert r\rvert\le1$ and $\sum r^2=Q\le n$. This gives $w_{\rm mem}$ with $\mathcal R(z_{w_{\rm mem}})\le\sum_Tk_x(3t)^2=9nt^2$. For $w\in\mathcal N_1$, Lemma 2.3(b) with $w'=w_{\rm mem}$ and Lemma 7.1(a) (the term $W/c$ cancels) give

$$
\mathcal R(z_w)\le c(K_{\rm mem}+1)+9nt^2=n\varepsilon_{c,t}.
$$

By Lemma 7.1(b,c,d),

$$
M^{-1}\sum(\operatorname{clip}z_w)^2\ge\bigl(\sqrt{Q/M}-\sqrt{\varepsilon_{c,t}}\bigr)_+^2\ge\bigl(\sqrt{1/e-M^{-1/3}}-\sqrt{\varepsilon_{c,t}}\bigr)_+^2 .
$$

*Gibbs.* Corollary 3.2(1) gives the liminf bound.

*Means.* By convexity (Lemma 7.1(c)), Jensen and Tonelli, $\mathcal R(\bar f_\sigma)\le\mathbb E_\Pi\mathcal R(\operatorname{clip}z_w)\le\sup_{\mathcal N_1}\mathcal R+4n\,\Pi(\mathcal N_1^c)$. Similarly $\mathcal R(\bar z_\sigma)\le\sup_{\mathcal N_1}\mathcal R+c\,\mathbb E_\Pi[F\mathbf 1_{\mathcal N_1^c}]$, using $\mathcal R(z_w)\le cF$. Both upper limits are at most $n\varepsilon_{c,t}$ by Lemma 3.1. The map $u\mapsto(a-\sqrt u)_+^2$ is continuous and nonincreasing; apply Lemma 7.1(b). $\blacksquare$

**Theorem 7.4 (sharp threshold).** Let $H\ge2$, consider $D^{\rm cube}_d$ with $n=2^d$, and let $c=n^{1-\theta}$.

- (a) If $0<\theta<1/H$: for every $\delta$, with probability $\ge1-\delta$ and for **every** width $N\ge1$, statements 1–4 of Proposition 6.1 hold against $\mathrm{OPT}=1$ with
$$
\mathrm{Exc}\le n^{-\theta}+8(2/H)^{H/2}D_n\,n^{-(1-\theta H)/2}+5\sqrt{\ln(2/\delta)/(2n)}\to0 .
$$
Here $D_n=O(\log n)$ because $d=\log_2n$.
- (b) If $\theta>1/H$ and $n\ge16^{1/\theta}$, take $t=n^{-\theta/2}$. Then with probability $\ge1-e^{-n^{1/3}/2}$, at every width $N\ge N_0(n):=\lceil2(d+1)^3n^{1+\theta}\ln2\rceil+1$, every near-minimizer and every posterior predictor listed in Proposition 7.3 has excess at least $\bigl(\sqrt{1/e-n^{-1/3}}-\sqrt{\varepsilon_n}\bigr)_+^2=1/e-o(1)$, where
$$
\varepsilon_n=n^{-\theta}\Bigl(\beta^2d^3+(H+1)\max\bigl\{2,\tfrac94n^{\theta/2},((d+1)^2n)^{1/H}\bigr\}+1\Bigr)+9n^{-\theta}\to0,\qquad \beta=\max\{1,\tfrac12\ln(2(d+1)n^{(1+\theta)/2})\}.
$$

Since $d=\log_2n$, every polynomial in $(d,m,B,1/\varepsilon,\log(1/\delta))$ with $m,B,\varepsilon,\delta$ fixed is eventually below $n$. Hence, for clipped predictors, **Claim B with a polynomial sample bound holds for every $\theta<1/H$ (Theorem 6.3) and fails for every $\theta>1/H$.** The exponent $1/H$ is sharp.

*Proof.*

(a) Use Proposition 6.1 through Remark 6.5 with $w'=0$, so $\kappa_N(w')=0$ and $U'=0$; then Lemma 5.3(a) with $K=n^\theta+1$.

(b) Apply Proposition 7.3 with $t=n^{-\theta/2}\le1/4$. Then $A_{\max}^2=(d+1)^2n$ and $m_t=N_0(n)$. Each term of $\varepsilon_n$ tends to $0$:

- $n^{-\theta}\beta^2d^3=O(n^{-\theta}\log^5n)$;
- $n^{-\theta}\cdot\frac94n^{\theta/2}\to0$;
- $n^{-\theta}((d+1)^2n)^{1/H}=(d+1)^{2/H}n^{1/H-\theta}\to0$, because $\theta>1/H$. $\blacksquare$

**7.5 The remaining gaps, stated precisely.**

1. *Polylogarithmic window in $c$ (clipped).* Write $c=\lambda_nn^{1-1/H}$ on the noisy cube.

   - With $\lambda_n\in[1,n^{1/H}]$, Lemma 5.3(a) and $n/c+1\le2n^{1/H}/\lambda_n$ give a middle term of $8\bigl(2/(H\lambda_n)\bigr)^{H/2}D_n$. So the excess tends to $0$ as soon as $\lambda_n\gg\frac2H(8D_n)^{2/H}$, that is, $\lambda_n\gg(\log n)^{2/H}$.
   - Proposition 7.3 with $t=(c/n)^{1/2}$ gives excess $1/e-o(1)$ as soon as $\lambda_n(H+1)(d+1)^{2/H}\to0$, that is, $\lambda_n\ll(\log n)^{-2/H}$.

   Between $c\asymp n^{1-1/H}(\log n)^{-2/H}$ and $c\asymp n^{1-1/H}(\log n)^{2/H}$, up to constants, neither argument applies; this includes $c=n^{1-1/H}$ exactly. `transition_window.py` computes the largest $c$ certified to fail (excess $\ge0.2$) and the smallest $c$ certified to succeed (excess $\le0.1$). Their exponents $\log_nc$ approach $1-1/H$ from both sides: for $H=2$, $0.461$ and $0.536$ at $d=400$; for $H=3$, $0.634$ and $0.688$. The ratio between the two values of $c$ grows only polylogarithmically.
2. *Unclipped predictors.* Proved for $\theta<1/L$ (Theorem 6.4). Failure is proved only for $\theta>1/H$, since Proposition 7.3 covers unclipped outputs too. The window $[1/L,1/H]$ is open.

   Failure there would require exact minimizers of $F_c$ (Corollary 3.2(2)) to produce outputs of order $\sqrt{n^\theta}$ on a set of test mass of order $n^{-\theta}$, while staying $O(1)$ on the training inputs there. That set contains about $n^{1-\theta}$ training points. By the construction of Lemma 7.2, fitting that many prescribed values costs energy of order $n^{(1-\theta)/H}$ up to polylogarithmic factors, which is below the budget $n^\theta$ exactly when $\theta>1/L$. So counting does not exclude such networks. This is a heuristic only: I have neither a mechanism that forces minimizers to behave this way nor a proof that excludes it.
3. *Depth two ($H=1$).* Theorem 6.3 covers every $\theta<1$. In fact its proof gives vanishing excess on the noisy cube as soon as $c\gg D_n^2=O(d\log n)$. Lemma 7.2 needs $H\ge2$, so the negative side is not covered here. The red-team report (`../research-notes/red-team.md`, Theorem 5.1, not re-proved here) gives excess $\ge(0.0999-o(1))/(18dc+1)^2$ for bounded $c$ at $n=2^d$. This excess vanishes as $d\to\infty$, but it rules out polynomial sample bounds. So at depth two any transition lies at $c=O(\mathrm{polylog}\,n)$, consistent with the formula $n^{1-1/H}$ at $H=1$. Its exact location is not determined here.
4. *Dimension.* The positive side needs $n\gg d\log n$ (Remark 6.6). If $d=n^\kappa$, the proof gives $\theta<(1-\kappa)/H$. Whether the true threshold moves with $\kappa$ is not settled here.

---

## 8. The user's formulation

**Corollary 8.1.** Fix $L=H+1\ge2$ and $\alpha\in\bigl(0,\frac1{4H}\bigr)$. Put $\theta=\frac{1+8\alpha}{H+2}\in(0,\frac1H)$ and $c(n)=n^{1-\theta}$. Let $\mathcal G_n^{(\alpha)}$ be the depth-$L$ networks of the repository architecture with width at most $\lfloor n^\alpha\rfloor$ and all weights in $[-n^\alpha,n^\alpha]$. Put

$$
\beta:=\frac{1-4\alpha H}{H+2}\quad(H\ge2),\qquad \beta:=\min\Bigl\{\frac{1-4\alpha}3,\ \frac12-4\alpha\Bigr\}\quad(H=1).
$$

Then for every $d$, every compact $X\subseteq[-1,1]^d$, every $D$ on $X\times[-1,1]$, every $n\ge1$ and every $\delta\in(0,1)$, with probability $\ge1-\delta$ and simultaneously for all learner widths $N\ge n^\alpha$,

$$
\limsup_{\sigma\downarrow0}\ \mathbb E_{\Pi_\sigma}L_D(\operatorname{clip}z_w)\ \le\ \min_{f\in\mathcal G^{(\alpha)}_n}L_D(f)\ +\ \Xi_n\,n^{-\beta},
$$

$$
\Xi_n:=d(d+1)+2L+8\Bigl(\frac2H\Bigr)^{H/2}\Bigl(\sqrt{2(d+1)\ln(n+1)}+\frac{H-1}2\Bigr)+4\sqrt{2\ln(2/\delta)} .
$$

The same bound holds for every $F_c$-near-minimizer, for $\Pi_\sigma$-almost all parameters in the limit (statement 2), and for the posterior mean $\bar f_\sigma$.

In the user's words: after $n$ samples, the test MSE of the tempered Bayesian network is at most the best test MSE among depth-$L$ MLPs whose width and weights are at most $n^\alpha$, plus $O_L\bigl((d^2+\sqrt{d\log n}+\sqrt{\log(1/\delta)})\,n^{-\beta}\bigr)$. This holds for every $\alpha<1/(4H)$ with $\beta=(1-4\alpha H)/(H+2)$, and $\beta\to1/(H+2)$ as $\alpha\to0$. For example, at depth $3$ one may take $\alpha=1/16$ and $\beta=1/8$.

*Proof.* The parameter set of $\mathcal G^{(\alpha)}_n$ is compact (narrower networks embed by zero padding), and $f\mapsto L_D(f)$ is continuous on it. So the minimum is attained at some $g$, which depends only on $D$ and $n$. Apply Theorem 6.3 to $g$, with $m=\lfloor n^\alpha\rfloor$ and $B=n^\alpha$.

- $E_*+1\le\bigl(d(d+1)+2L\bigr)n^{4\alpha}$ and $4\alpha-\theta=-\beta$; for $H=1$, $4\alpha-\theta=-(1-4\alpha)/3\le-\beta$.
- $(1-\theta H)/2=(1-4\alpha H)/(H+2)$.
- $4+(U+1)^2\le8n^{4\alpha}$, and $4\alpha-\frac12\le-\beta$. For $H\ge2$ this is equivalent to $\alpha\le H/16$, which holds. For $H=1$ it is built into $\beta$. $\blacksquare$

How far can $\alpha$ go? Corollary 9.3 shows that for width-and-weight classes no choice of $c(n)$ works beyond $\alpha=L/(2H(2L-1))$, for instance $0.15$ at $L=3$ against $0.125$ here. For width-1 classes the positive range extends to $\alpha<1/(2H)$, and that is exactly sharp.

---

## 9. The role of the competitor's weight bound

**Proposition 9.1 (a steep two-point law).** Let $L=H+1\ge2$, $c>0$, $n\ge1$, $K:=n/c+1$ and $\delta_0\in(0,1]$. Let $D_{\delta_0}$ be uniform on $\{(-\delta_0,-1),(\delta_0,1)\}$; so $d=1$, $X=\{\pm\delta_0\}$, the labels are noiseless, and the Bayes risk is $0$. Put $\eta:=\delta_0(K/L)^{L/2}$.

- (a) *The learner.* For every sample, every width $N$ and every $w\in\mathcal N_1^{(N)}$, $\lvert z_w(\delta_0)-z_w(-\delta_0)\rvert\le2\eta$. If $\eta\le1$, then $L_D(z_w)\ge L_D(\operatorname{clip}z_w)\ge(1-\eta)^2$. The same lower bound holds for the $\liminf_{\sigma\downarrow0}$ of $\mathcal G^{\rm clip}_\sigma$, $\mathcal G_\sigma$, $L_D(\bar f_\sigma)$ and $L_D(\bar z_\sigma)$.
- (b) *A width-1 competitor.* Let $\omega=\delta_0^{-1/L}$ with $\omega^2\ge2$. Let $g_{\delta_0}$ have first-layer row $(0,\omega)$, internal weights $\omega$ and readout $v=1/t_H$, where $t_0=\delta_0$ and $t_\ell=\tanh(\omega t_{\ell-1})$. Then:
  - $g_{\delta_0}(\pm\delta_0)=\pm1$, so $L_D(g_{\delta_0})=0$;
  - $\omega\le v\le\frac32\omega$;
  - its clone at every width has energy $H\omega^2+v^2\le(H+\tfrac94)\delta_0^{-2/L}$.

  Conversely, every network $f$ with $f(\pm\delta_0)=\pm1$ has energy at least $L\delta_0^{-2/L}$.
- (c) *Matching up to energy $\Theta(n^\theta)$ and no further.* Let $c=n^{1-\theta}$, $n^\theta\ge2L$ and $\delta_0=\frac12\bigl(L/(n^\theta+1)\bigr)^{L/2}$. Then $\eta=\frac12$, so all near-minimizers and all limiting posterior predictors have $L_D\ge1/4$. Yet $g_{\delta_0}$ has width 1, zero loss, weights at most $\frac32(n^\theta+1)^{1/2}$, and energy at most $(1+\frac5{4L})4^{1/L}(n^\theta+1)\le3.25(n^\theta+1)$. By Remark 6.5, every competitor with energy $o(n^\theta)$ is matched, with excess $O(n^{-\theta}\cdot\text{energy})$ plus the capacity terms. So the competitor energy at which matching breaks down is of order $n^\theta$. These results do not decide competitors with energy between $\epsilon n^\theta$ and $3.25(n^\theta+1)$.

*Proof.*

(a) By Lemma 2.3(a), $\kappa_N(w)\le K$. Lemma 2.1(b) with $d=1$ gives the first claim; clipping is 1-Lipschitz. For any $f$ with $f(\delta_0)-f(-\delta_0)\le2\eta'$ and $\eta'\le1$, put $p=f(\delta_0)-1$ and $q=f(-\delta_0)+1$. Then

$$
L_D(f)=\tfrac12(p^2+q^2)\ge\tfrac14(p-q)^2\ge(1-\eta')^2 .
$$

For the posterior predictors, use Corollary 3.2(1) for the Gibbs risks. For the means,

$$
\bar f_\sigma(\delta_0)-\bar f_\sigma(-\delta_0)\le2\eta+2\Pi_\sigma(\mathcal N_1^c),\qquad \bar z_\sigma(\delta_0)-\bar z_\sigma(-\delta_0)\le2\eta+2\,\mathbb E_\Pi[(1+F)\mathbf 1_{\mathcal N_1^c}],
$$

and both corrections tend to $0$ by Lemma 3.1.

(b) The network is odd, so $g(-\delta_0)=-g(\delta_0)=-1$. Put $\tilde t_\ell=\omega^\ell\delta_0=\omega^{\ell-L}\le1$ for $\ell\le H$. Inductively $t_\ell\le\tilde t_\ell$, and, using $\tanh s\ge s(1-s^2/3)$,

$$
t_\ell\ge\omega t_{\ell-1}(1-\tilde t_\ell^2/3).
$$

Hence $t_H\ge\tilde t_H\bigl(1-\frac13\sum_{j\ge1}\omega^{-2j}\bigr)\ge\tilde t_H(1-\frac2{3\omega^2})\ge\frac23\tilde t_H$, and $v\le\frac32/\tilde t_H=\frac32\omega$. Also $t_H\le\tilde t_H$ gives $v\ge\omega$.

For the energy: a clone with $N$ identical copies per layer has $a_1=\omega^2$, $a_\ell=\omega^2$ and $a_L=v^2$. For the converse, Lemma 2.1(b) applied to $f$ gives $2\le2\delta_0(\kappa/L)^{L/2}$.

(c) $\omega^2=4^{1/L}(n^\theta+1)/L\ge2$ when $n^\theta\ge2L$. The remaining claims are arithmetic, using $2^{1/L}/\sqrt L\le1$ and that $(1+\frac5{4L})4^{1/L}$ is at most $3.25$ (attained at $L=2$). $\blacksquare$

**Lemma 9.2 (width-$m$ chains).** Let $m\ge1$ and $B>0$ with $mB\ge(\tanh1)^{-H}$, and let $\delta_0\in(0,1]$ with $\delta_0\ge(\tanh1)^{-H}/(m^HB^L)$. Then some depth-$L$ network of width $m$ with all weights in $[-B,B]$ fits $D_{\delta_0}$ exactly.

*Proof.* Give every first-layer neuron the row $(0,B)$, give all internal weights the value $B$, and give all readout weights the value $v$. With $G=mB\ge1$, the common unit values at $x=\delta_0$ are $t_1=\tanh(B\delta_0)$ and $t_\ell=\tanh(Gt_{\ell-1})$.

Concavity gives $\tanh s\ge\tanh(1)\min\{1,s\}$ for $s\ge0$. By induction, $t_\ell\ge(\tanh1)^\ell\min\{1,G^{\ell-1}B\delta_0\}$. Take $v=1/(mt_H)$. Then $v\le B$ iff $Gt_H\ge1$, which follows from $G(\tanh1)^H\min\{1,G^{H-1}B\delta_0\}\ge1$, and that is implied by the hypotheses because $G^HB=m^HB^L$. Oddness gives the value at $-\delta_0$. $\blacksquare$

**Corollary 9.3 (how large may the competitors' weights be?).** Let $H\ge2$ and let $c:\mathbb N\to(0,\infty)$ be **arbitrary**.

- (a) *Width-1 competitors with weights $\le n^\alpha$.* If $\alpha<\frac1{2H}$, Theorem 6.3 with any $\theta\in(2\alpha,\frac1H)$ gives excess $\to0$ at a polynomial rate, uniformly over $D$; there $E_*\le(d(d+1)+2L)n^{2\alpha}$. If $\alpha>\frac1{2H}$, the following happens for infinitely many $n$. There is a law $D_n$, either the noisy cube or a two-point law, and a width $N_0(n)$ such that, with probability $\ge1-e^{-n^{1/3}/2}$, at every width $N\ge N_0(n)$, every near-minimizer and every limiting posterior predictor has excess $\ge1/5$ over the best competitor. So the critical exponent is exactly $\alpha^*=\frac1{2H}$.
- (b) *Competitors with width and weights $\le n^\alpha$.* Corollary 8.1 covers $\alpha<\frac1{4H}$. The negative statement of (a) holds for $\alpha>\frac L{2H(2L-1)}$. So $\alpha^*\in\bigl[\frac1{4H},\frac L{2H(2L-1)}\bigr]$, for example $[0.125,0.15]$ at $L=3$.

*Proof of the negative parts.* Restrict to $n=2^d$.

*Case 1:* $n/c(n)\ge n^{1/H}(\log_2n)^3$ for infinitely many such $n$. Use the noisy cube and Proposition 7.3 with $t=(c/n)^{1/2}$. Since $c/n\le n^{-1/H}(\log_2n)^{-3}$, every term of $\varepsilon_{c,t}$ tends to $0$:

- $\frac cn\beta^2d^3\to0$: here $\beta\le1+\frac12\ln(2(d+1)\sqrt n)+\frac14\ln(n/c)$, so $\beta^2=O(\log^2n+\log^2(n/c))$. Moreover $x\mapsto x\ln^2(1/x)$ is increasing on $(0,e^{-2})$, so with $x=c/n\le n^{-1/H}(\log_2n)^{-3}$ we get $\frac cn\ln^2\frac nc=O(n^{-1/H}\log^2n)$. Multiplying by $d^3=\log_2^3n$ still gives a quantity tending to $0$;
- $\frac cn\cdot\frac{9(H+1)}{4t}=\frac{9(H+1)}4(c/n)^{1/2}\to0$;
- $\frac cn(H+1)((d+1)^2n)^{1/H}\le(H+1)(d+1)^{2/H}/d^3\to0$.

The zero network belongs to every competitor class and attains $\mathrm{OPT}=1$, while the excess tends to $1/e>1/5$.

*Case 2:* otherwise, for all large $n=2^d$, $K=n/c+1\le2n^{1/H}(\log_2n)^3$. Use $D_{\delta_0}$ with $\delta_0=(\tanh1)^{-H}/(m^HB^L)$, where $B=n^\alpha$ and $m=1$ in (a), $m=\lfloor n^\alpha\rfloor$ in (b). By Lemma 9.2 the class contains an exact fit. Then

$$
\eta=\delta_0(K/L)^{L/2}\le(\tanh1)^{-H}\,2^{H}n^{-\alpha\cdot\mathrm{ex}}\bigl(2n^{1/H}(\log_2n)^3/L\bigr)^{L/2}\to0,
$$

with $\mathrm{ex}=L$ in (a) and $\mathrm{ex}=2L-1$ in (b), because $\alpha\,\mathrm{ex}>L/(2H)$. Proposition 9.1(a) gives $L_D\ge(1-\eta)^2>1/5$ against $\mathrm{OPT}=0$, for every sample. $\blacksquare$

**Discussion.** A width bound alone does not suffice, and the weights must be bounded in a way tied to the tempering:

- The class of width-1 networks without a weight bound contains, for every $\delta_0>0$, an exact fit of the noiseless law $D_{\delta_0}$.
- For every $c$, SP$_c$ misses it by $1/4$ as soon as $\delta_0\le\frac12(L/(n/c+1))^{L/2}$.
- Fitting $D_{\delta_0}$ requires energy at least $L\delta_0^{-2/L}$ in **any** representation; this is the "steep step realizable only with large weights or energy".

The learner's effective energy budget is $n/c$. Competitors whose minimal energy exceeds it by a constant factor cannot be matched, and competitors below it are matched up to $n^{-\theta}\times$energy (Remark 6.5).

This is the price of tempering. With $c=1$ the budget is $n$, so far steeper competitors are matched, but $c=1$ memorizes noise (Section 7, Claim A). Tempering trades sensitivity to noise against reach in energy. At $\theta\to1/H$ the reach is $n^{1/H}$ in energy, that is, weights up to $n^{1/(2H)}$ for width-1 competitors, and Corollary 9.3 shows that no $c(n)$ does better.

---

## 10. Numerical sanity checks

Scripts are in `../checks/B/`, with shared network code in `nn_utils.py`. Each `X.py` was run as `python3 X.py > X.out` from that folder, with numpy, scipy and mpmath. All runs use fixed random seeds.

| script | what is checked | result |
|---|---|---|
| `check_identities.py` | clip formula; clip-mixture identity (Lemma 5.1(v)) over 400 random $(r,u)$; $\tanh s=\mathbb E\operatorname{sign}(s-T)$; staircase parity identity (Lemma 7.2) exactly on $\{-1,1\}^k$ for $k\le12$, with margin $\ge1$ and $\ell^1$ norm $\le k+1$; $1-\tanh b\le2e^{-2b}$ (50-digit arithmetic); $\lvert t-\tanh t\rvert\le\lvert t\rvert^3/3$ | errors $\le1.1\times10^{-13}$; staircase exact |
| `check_network_bounds.py` | 400 random nets ($1\le H\le4$, $d\le6$, $N\le29$): $\sup\lvert z\rvert/\sqrt\kappa$, Lipschitz ratio to $d^{-1/2}(\kappa/L)^{L/2}$, $P/(\kappa/H)^{H/2}$, $\lvert z\rvert/P$, $\lvert h^\ell_j\rvert/\rho^\ell_j$; cloning of 300 random teachers; backprop | max ratios $0.433$, $0.453$, $0.855$, $\le1$, $\le1$ (equal to 1 only for saturated units); cloning exact with $\kappa_N/E_*\le0.53$; backprop error $2\times10^{-10}$ |
| `check_rademacher.py` | lower estimates (L-BFGS over width-16 to 24 nets on $\kappa=K$) of $\mathbb E_\epsilon\sup_{\mathcal Z_K}\frac1n\sum\epsilon_iz(x_i)$ versus Lemma 5.2 | no violation in 15 settings; for example $0.226$ vs bound $2.60$ ($d=2,H=2,n=400,K=16$) and $0.211$ vs $3.63$ ($H=3$) |
| `check_memorizer.py` | Lemma 7.2 for $d=4,5,6$, $H=2,3$: Fourier $\ell^1\le\lVert r\rVert_2$; exact staircase expansion; $A\le(d+1)\lVert r\rVert_2$; tanh error $\le2Ae^{-2\beta}$; sampling with $m\approx2\cdot10^4$ to $10^5$ features; chain error $\le2\lvert g\rvert^3/(3R^2)$; energy | total error $0.07$ to $0.13\le3t$; energy $125$ to $414\le\beta^2d^3+(H+1)R^2$ |
| `check_two_point.py` | Proposition 9.1: chain competitor at the threshold $\delta_0$ for $L=2,3,4$ and $n=10^3,10^5,10^7$; direct L-BFGS minimization of $F_c$ | $v/\omega\le1.32$, energy $/n^\theta$ between $1.43$ and $2.67$; at the threshold the best network found is the zero network (test MSE $1.0\ge1/4$, $F_c=n^\theta$); with $\delta_0=0.5$ the learner fits (test MSE $0.066$, $0.016$) |
| `cover_degree.py` | $\ln\lvert\mathcal H_{K,a}\rvert$ from the source's parameters (Lemma 4.2) | local slopes in $K$: $2.09$ ($L=2$), $8.16$ ($L=3$), $12.18$ ($L=4$); in $1/a$: $4.13$, $8.16$, $8.14$ |
| `sample_sizes.py` | least $n$ with $\mathrm{Exc}_n\le\varepsilon$, and closed-form $n_0$, for both routes | route 2 at $L=3$, $d=10$, $\varepsilon=0.1$: $10^{13.4}$ (closed form $10^{29.2}$); route 1: $10^{101}$ |
| `transition_window.py` | Section 7.5: certified failure and success thresholds in $c$ on the noisy cube | both $\log_nc\to1-1/H$; $H=2$, $d=400$: $0.461$ and $0.536$ |
| `check_laplace.py` | Lemma 3.1 on a 3-parameter posterior integrated on a $161^3$ grid ($n=20$, $c=4$, $\zeta=0.2$) | $\Pi_\sigma(\mathcal N_\zeta^c)=0.97,\ 0.22,\ 2\times10^{-4},\ 9\times10^{-9}$ at $\sigma=1,0.2,0.1,0.07$; $\mathbb E_\Pi F-\min F\approx P\sigma^2$ |

The optimization-based checks (`check_rademacher`, `check_two_point`) give one-sided evidence only: local optimization yields lower estimates of suprema and upper estimates of minima.

---

## 11. Status

**Proved here.** Lemmas 2.1–2.3, 3.1, 4.2–4.3, 5.1–5.3, 7.1–7.2 and 9.2; Propositions 6.1, 7.3 and 9.1; Theorems 6.2, 6.3, 6.4 and 7.4; Corollaries 3.2, 8.1 and 9.3. All quantifiers and the limit order ($\sigma\downarrow0$ after $S$ and $N$) are as stated, and the sample events never depend on $N$ or $\sigma$.

**Imported.** Proposition 4.1 (the repository's energy cover), used only in Theorem 6.2. Theorem 6.3 supersedes Theorem 6.2 and does not use it.

**Corrections to the brief.**

- The energy bound is $n(U+1)^2/c$, not $nU^2/c$. Better, $\kappa\le n/c+\zeta$ holds for every near-minimizer, independently of the competitor.
- The cover route gives $\theta<1/(4(L-1))$ only for $L\ge3$ and only for clipped outputs. For $L=2$ it gives $\theta<1/2$. For unclipped outputs it gives $\theta<1/(4L+2)$ ($L\ge3$) or $1/6$ ($L=2$), because one needs $a\lesssim\varepsilon/\sqrt K$ and pays a loss range of order $K$.
- The guess in Claim D, $c\sim n^{1-1/(H+1)}$ "for norm-based bounds", is the unclipped threshold. For clipped predictions the norm-based capacity bound reaches the memorization threshold $n^{1-1/H}$.

**Open.**

- (i) Unclipped predictors for $\theta\in[1/L,1/H]$.
- (ii) The polylogarithmic window around $c=n^{1-1/H}$.
- (iii) The negative side at depth two for $c=\mathrm{polylog}(n)$; known only from the red-team report.
- (iv) The exact $\alpha^*\in[\frac1{4H},\frac L{2H(2L-1)}]$ for width-and-weight classes.
- (v) Finite prior scale $\gamma\ge1$ (Claim E).
- (vi) Non-Gaussian coordinate laws. Lemma 3.1 uses the exact Gaussian form $e^{-F_c/(2\sigma^2)}$.

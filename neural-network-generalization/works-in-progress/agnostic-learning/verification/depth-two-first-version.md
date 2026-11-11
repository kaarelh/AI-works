# Depth two on the noisy cube: corrected Theorem 5.1, Corollary 5.2 and Proposition 5.3

*This repairs `../research-notes/red-team.md` §5 ("Depth two ($L=2$) with $c=1$") after two referee reports. `RT-depth2-logic.md` found a major error in a scope claim of Corollary 5.2 and judged the proofs correct. `RT-depth2-computation.md` asked for minor fixes. The document is self-contained: §2 states and proves every lemma used, keeping the red-team numbering so that the final note can cite them. Those lemmas are Lemma 1.0(1), Lemma 1.1, Lemma 1.2, Lemma 1.3 and the depth-two part of Lemma 2.1. Scripts and outputs are in `../checks/depth-two/` (§7). `NNG/` denotes the project folder `neural-network-generalization/` of this repository, and "RT" abbreviates `../research-notes/red-team.md`.*

---

## 0. Results and what changed

### 0.1 Results

Throughout:

- the depth is $L=2$;
- $D_d$ is the cube example: $x$ is uniform on $\{-1,1\}^d$, and $y$ is a fair sign independent of $x$;
- $M=2^d$ and $n=\lceil\lambda M\rceil$ for a fixed $\lambda>0$;
- SP$_c$ is the strong-prior learner with Gaussian likelihood and variance ratio $c>0$. Its posterior is taken in the limit $\sigma\downarrow0$, with the sample and the learner width $N$ fixed first.

Every predictor has test MSE at least $1$, and the zero network attains $1$. So "excess" means test MSE minus $1$.

1. **Theorem 5.1 (every $c>0$).** Fix any sample and any learner width $N\ge N_0(a)=\lceil72dn\ln(2M)/a^2\rceil+1$, where $a\in(0,1]$ is a free accuracy parameter. Then every near-minimizer $w$ of the posterior energy has training residual $\mathcal R(z_w)\le(1-\vartheta_c)G+E_0$, where $\vartheta_c=1/(18dc+1)$. Its excess is therefore at least $\max\{\Psi_{\rm tri},\Psi_{\rm cor}\}$. The same lower bound holds in the strong-prior limit for Gibbs draws and for posterior means, clipped or not.
2. **Corollary 5.2 (asymptotics, and what is refuted).** On an event of probability $1-o(1)$, at every width $N\ge N_0(a_d)$ with $a_d\to0$:
   - **(i)** for every $0<c\le\mathrm{poly}(d)$ the excess is at least $\gamma(\lambda)(18dc+1)^{-2}(1-o(1))$. This refutes BRIEF §1's polynomial-sample property (P$_2$).
   - **(ii)** if $c\le\nu/d$, the excess is at least the constant $\Gamma_\lambda(\nu)-o(1)$, where $\Gamma_\lambda(\nu)\ge\gamma(\lambda)/(18\nu+1)^2$.
   - **(iii)** if $dc\to0$, the excess is at least $\beta(\lambda)-o(1)$. This is the depth-$\ge3$ constant, with $\beta(1)=0.4848$.
   - Parts (ii) and (iii) refute the "$+o(1)$" formulation (P$_2^{o(1)}$) with the $o(1)$ uniform over $d\le\log_2n+O(1)$, for every $c(n)\le\nu/\log_2n$.
   - **(iv)** if $dc\to\infty$ (for example any fixed $c$, including $c=1$), the bound of Theorem 5.1 tends to $0$. It then says nothing about the "$+o(1)$" formulation.
3. **Proposition 5.3 (Hadamard atoms, $d=M$).** At every width $N\ge1$, and for every $c\le\nu\sqrt M$ with $\nu<\sqrt{\beta(\lambda)}/2$, the excess is at least $\beta(\lambda)\bigl(1-\sqrt{2\nu/\sqrt{\beta(\lambda)}}\bigr)^2-o(1)$. For $c=o(\sqrt M)$ it is at least $\beta(\lambda)-o(1)$. The inputs have Euclidean norm $\sqrt d$. For unit-ball inputs the same argument gives a constant only when $c<\sqrt{\beta(\lambda)}/2$ (Remark 5.4); it gives nothing at $c=1$.

### 0.2 Scope

| Formulation (defined in §1.4) | Depth-two status |
|---|---|
| (P$_2$): polynomial sample size, all $d$, all learner widths $N\ge m$ | **refuted** for every $0<c\le\mathrm{poly}(d)$ (Cor. 5.2(a)) |
| (P$_2^{o(1)}$), $o(1)$ uniform over $d\le\log_2n+C_0$ | **refuted** for every $c(n)\le\nu/\log_2n$, $\nu>0$ (Cor. 5.2(b)). **Not refuted** by these results when $c\log n\to\infty$, e.g. fixed $c$; open (Remark 5.8) |
| (P$_2^{o(1)}$), $o(1)$ uniform over $d\le n$ (inputs in $[-1,1]^d$) | **refuted** for every $c=o(\sqrt n)$, with constant $\beta(1)$ (Prop. 5.3, $\lambda=1$, inputs of norm $\sqrt d$). With unit-ball inputs, refuted only for $c<\sqrt{\beta(1)}/2$, with constant $\beta(1)$ when $c\to0$ (Remark 5.4) |
| fixed $d$ | **not refuted** by the cube family: at fixed $d$ its excess is $O(2^d/n)$ at every width (`../research-notes/A-tight-conditioning-fails.md` Prop. 5.2, refereed) |

Every failure is proved under the following restrictions:

- **Widths.** Learner widths $N\ge N_0$. For Theorem 5.1 with $a=1/d$, $N_0=O(n\log^4n)$. For Proposition 5.3, any $N\ge1$. Nothing is proved at smaller widths (Remark 5.5).
- **Predictors.** Near-minimizers, Gibbs draws, and posterior means, clipped or not. The progressive-mixture predictor is not covered (Remark 5.6).

### 0.3 Changes relative to RT §5

1. **The scope error (major).** RT's Corollary 5.2 ended: "It does **not** refute the '$+o(1)$' formulation, since $\varepsilon_d\asymp1/\log^2n$." That is false on part of the corollary's own range, "$c\le\mathrm{poly}(d)$", which contains $c\to0$.
   - Theorem 5.1's bound is of order $(dc+1)^{-2}$.
   - This bound is a constant when $c\le\nu/d$.
   - When $dc\to0$, the same near-minimizer budget combined with Lemma 1.2(a) gives $\beta(\lambda)$.

   Corollary 5.2 now states the three regimes, and the "does not refute" sentence is kept only for $dc\to\infty$ (§4).
2. **Theorem 5.1 is stated more fully.** Both lower bounds are now stated, from the same budget. The memorizer accuracy $a$ is now free, so the required width can be $O(n\log^4n)$ instead of $O(n^3\log^2n)$. The display is deterministic. The strong-prior limit is uniform over samples.
3. **Scope is explicit.** The scope statements name the widths, the predictors and the input normalisation, and say over which $d$ the "$+o(1)$" formulation is uniform.
4. **Proposition 5.3.** It now assumes $Q>0$, holds for $c\le\nu\sqrt M$ with $\nu<\sqrt{\beta(\lambda)}/2$, and gives an explicit rate. It also records its dependence on inputs of norm $\sqrt d$: under unit-ball inputs only $c<\sqrt{\beta(\lambda)}/2$ survives.
5. **Numbers.** The parenthetical numbers of Corollary 5.2 are corrected. The red-team's "positive side at $L=2$" paragraph and §5.4 numerics are corrected (Remark 5.7, §6).

---

## 1. Setting

### 1.1 Networks, energy, learner

**Network.** A depth-two network of width $N$ has parameters $w=(W^1,v)$, where $W^1\in\mathbb R^{N\times(d+1)}$ has rows $\omega_1,\dots,\omega_N$ and $v\in\mathbb R^N$. It computes

$$
z_w(x)=\sum_{j=1}^Nv_j\tanh(\omega_j\cdot\bar x),\qquad\bar x=(1,x)\in\mathbb R^{d+1}.
$$

There are no separate biases; the constant coordinate carries offsets.

**Energy.** The energy is

$$
\kappa_N(w)=\frac dN\lVert W^1\rVert_F^2+N\lVert v\rVert_2^2 .
$$

This is `NNG/side-results/continuous-domains/source/paper.tex` eq. `energy` at $L=2$. Write $\kappa_N(w)=\lVert\Lambda w\rVert^2$, where $\Lambda$ is diagonal and positive, and let $P=N(d+2)$ be the number of parameters.

**Learner SP$_c$.** The prior $\mu_\sigma$ has density proportional to $e^{-\kappa_N/(2\sigma^2)}$. The likelihood is $y_i\sim\mathcal N(z_w(x_i),c\sigma^2)$, and the posterior is

$$
\Pi_\sigma(dw)=\Pi_{\sigma,N,S}(dw)=\frac{e^{-F_{c,S}(w)/(2\sigma^2)}dw}{\int e^{-F_{c,S}/(2\sigma^2)}},\qquad F_{c,S}(w)=\kappa_N(w)+\frac1c\sum_{i=1}^n\bigl(z_w(x_i)-y_i\bigr)^2 .
$$

Here $c>0$ may depend on $n$ and $d$. This is BRIEF §2. The clean-label scaling of `NNG/works-in-progress/slt-likelihood/README.md` §2 is $c=1$.

**Limit order.** First fix $d,n,c,N$ and the sample $S$, then let $\sigma\downarrow0$.

**Near-minimizers.** For $\zeta>0$ put $\mathcal N_\zeta=\mathcal N_\zeta^{(N)}(S)=\{w:F_{c,S}(w)\le\min F_{c,S}+\zeta\}$. The minimum exists by Lemma 1.1.

Lemma 1.1 below holds verbatim at every depth, but only $L=2$ is used here.

### 1.2 Predictors

Let $\operatorname{clip}(u)=\max\{-1,\min\{1,u\}\}$ and $L_D(f)=\mathbb E_{(x,y)\sim D}(f(x)-y)^2$.

- **Gibbs.** A draw $w\sim\Pi_\sigma$, with output $z_w$ or $\operatorname{clip}z_w$. The corresponding risks are $\mathcal G_\sigma=\mathbb E_{\Pi_\sigma}L_D(z_w)$ and $\mathcal G^{\rm clip}_\sigma=\mathbb E_{\Pi_\sigma}L_D(\operatorname{clip}z_w)$.
- **Posterior means.** $\bar z_\sigma=\mathbb E_{\Pi_\sigma}z_w$, $\operatorname{clip}\bar z_\sigma$, and $\bar f_\sigma=\mathbb E_{\Pi_\sigma}\operatorname{clip}z_w$. These are finite by Lemma 1.0(1) and Lemma 1.1(ii).
- **Near-minimizers.** Any point of $\mathcal N_1$.

The progressive-mixture predictor of BRIEF §2 is **not** treated (Remark 5.6).

### 1.3 The cube example and sample statistics

**Risk.** In $D_d$ the regression function is $0$ and $y^2=1$. Hence for every $f:\{-1,1\}^d\to\mathbb R$,

$$
L_{D_d}(f)=1+\frac1M\sum_{x}f(x)^2,
$$

so $\min_fL_{D_d}(f)=1$, attained by the zero network.

**Sample statistics.** For a sample $S=((x_i,y_i))_{i\le n}$ with inputs in a finite set, define:

- the counts $k_x=\#\{i:x_i=x\}$;
- the set of seen atoms $T=\{x:k_x\ge1\}$ and its size $s=\lvert T\rvert$;
- the label sums $S_x=\sum_{i:x_i=x}y_i$, and $\bar y_x=S_x/k_x$ for $x\in T$;
- the within-atom sum of squares $W=\sum_i(y_i-\bar y_{x_i})^2$;
- the residual $\mathcal R(f)=\sum_{x\in T}k_x(f(x)-\bar y_x)^2$;
- the totals
$$
Q=\sum_{x\in T}\bar y_x^2,\qquad G=\sum_{x\in T}k_x\bar y_x^2,\qquad V=\sum_xS_x^2 .
$$

Since $k_x\ge1$ on $T$ and $\lvert\bar y_x\rvert\le1$, we have $Q\le G$, $Q\le s\le\min\{n,M\}$ and $\sum_xk_x=n$.

**Constants.** Let $K\sim\mathrm{Bin}(n,1/M)$, and put $\beta_d=\mathbb E[K^{-1};K\ge1]$ and $p_d=\Pr[K\ge1]$. Let $\lambda'=n/M\in[\lambda,\lambda+1/M)$. Define

$$
\beta(\lambda)=e^{-\lambda}\sum_{k\ge1}\frac{\lambda^k}{k\,k!}=e^{-\lambda}\bigl(\mathrm{Ei}(\lambda)-\gamma_E-\ln\lambda\bigr),\qquad\gamma(\lambda)=\frac{(1-e^{-\lambda})^2}{4\lambda}.
$$

Their values (`bounds_t51.out`):

- $\beta(1)=0.484829$, and $\max\beta=0.517351$ at $\lambda=1.50286$;
- $\gamma(1)=0.0998941$, and $\max\gamma=0.101816$ at $\lambda=1.256431$, the root of $e^\lambda-1=2\lambda$.

Two inequalities are used:

$$
4\gamma(\lambda)\le\beta(\lambda)<1-e^{-\lambda}\qquad(\lambda>0). \tag{1.0}
$$

Let $K_\lambda\sim\mathrm{Poi}(\lambda)$. The left inequality is Cauchy–Schwarz: $(\Pr[K_\lambda\ge1])^2\le\mathbb E[K_\lambda]\,\mathbb E[K_\lambda^{-1};K_\lambda\ge1]=\lambda\beta(\lambda)$. The right inequality holds because $1/K_\lambda<1$ on $\{K_\lambda\ge2\}$, which has positive probability.

### 1.4 The two formulations refuted

Both are BRIEF §1 at depth two. The first follows `../research-notes/A-tight-conditioning-fails.md` §5.1.

> **(P$_2$)** There is a polynomial $\mathsf p$ with the following property. Take any $d\ge1$, any law $D$ on $X\times[-1,1]$ with $X\subseteq[-1,1]^d$ compact, any depth-two competitor $g$ of width $m$ with weights in $[-B,B]$, any learner width $N\ge m$, any $\varepsilon,\delta\in(0,1)$, and any $n\ge\mathsf p(d,m,B,1/\varepsilon,\log(1/\delta))$. Then $\Pr[L_D(\mathsf A_n)\le L_D(g)+\varepsilon]\ge1-\delta$.

> **(P$_2^{o(1)}[\phi]$)**: the "$+o(1)$" formulation, with the $o(1)$ uniform over input dimensions $d\le\phi(n)$. There are $\alpha>0$ and numbers $\epsilon_n\to0$ with the following property. For every $\delta\in(0,1)$ there is $n_\delta$ such that, for all $n\ge n_\delta$, all $d\le\phi(n)$, every law $D$ on $X\times[-1,1]$ with $X\subseteq[-1,1]^d$ compact, and every learner width $N\ge1$,
> $$\Pr\Bigl[L_D(\mathsf A_n)\le\inf_{g\in\mathcal G^{(\alpha)}_n}L_D(g)+\epsilon_n\Bigr]\ge1-\delta .$$
> Here $\mathcal G^{(\alpha)}_n$ is the set of depth-two networks of the same architecture with width at most $n^\alpha$ and all weights in $[-n^\alpha,n^\alpha]$.

The refutations below use only widths $N\ge N_0$. So they also refute every variant that requires the bound at a single width $N\ge N_0$ for each $n$, for example every $N\ge n^\alpha$.

**Readings.** For SP$_c$ with $c=c(n,d)$ the output $\mathsf A_n$ is read in one of three ways:

- **(R1)** A Gibbs draw, with output $z_w$ or $\operatorname{clip}z_w$. The probability is over both the sample and the draw. The property must hold for all $\sigma\in(0,\sigma_0)$, where $\sigma_0>0$ may depend on everything except the sample.
- **(R2)** One of $\bar z_\sigma$, $\operatorname{clip}\bar z_\sigma$ or $\bar f_\sigma$, with the same quantifier on $\sigma$.
- **(R3)** Any point of $\mathcal N_1(S)$, chosen by any rule. The probability is then an outer probability.

---

## 2. Lemmas

**Lemma 1.0(1) (output bound).** For every $N$ and $w$, $\sup_x\lvert z_w(x)\rvert\le\sqrt N\lVert v\rVert_2\le\sqrt{\kappa_N(w)}$.

*Proof.* Since $\lvert\tanh\rvert\le1$, we have $\lvert z_w(x)\rvert\le\lVert v\rVert_1\le\sqrt N\lVert v\rVert_2$. Also $N\lVert v\rVert_2^2\le\kappa_N(w)$. ∎

**Lemma 1.1 (strong-prior concentration, uniform in the sample).** Fix $d$, a compact $X\subseteq[-1,1]^d$, $N$, $n$, $c>0$ and $\zeta>0$. Samples range over $(X\times[-1,1])^n$.

- **(i)** For every sample, $F=F_{c,S}$ is continuous and coercive, its minimum $m_*$ is attained, and $0\le m_*\le n/c$.
- **(ii)** The quantity
$$
\epsilon_\sigma:=\sup_S\mathbb E_{\Pi_{\sigma,S}}\bigl[(1+F_{c,S})\mathbf 1_{\mathcal N_\zeta^c}\bigr]
$$
tends to $0$ as $\sigma\downarrow0$. In particular $\sup_S\Pi_{\sigma,S}(\mathcal N_\zeta^c)\le\epsilon_\sigma\to0$.
- **(iii)** Let $\Phi\ge0$ be measurable. Then $\mathbb E_{\Pi_\sigma}\Phi\ge\Pi_\sigma(\mathcal N_\zeta)\inf_{\mathcal N_\zeta}\Phi$. If moreover $\Phi\le b_0+b_1F_{c,S}$, then $\mathbb E_{\Pi_\sigma}\Phi\le\sup_{\mathcal N_\zeta}\Phi+\max\{b_0,b_1\}\epsilon_\sigma$.

*Proof.*

- **(i)** $F\ge\kappa_N=\lVert\Lambda w\rVert^2$, so $F$ is coercive; it is continuous; so the minimum is attained. Moreover $m_*\le F(0)=c^{-1}\sum_iy_i^2\le n/c$.
- **Numerator.** For $\varrho\in(0,1)$ and $t\ge0$ we have $(1+t)e^{-t/(2\sigma^2)}\le(1+2\sigma^2/\varrho)\,e^{-(1-\varrho)t/(2\sigma^2)}$. This follows from $\sup_{t\ge0}(1+t)e^{-st}\le\max\{1,1/s\}$ with $s=\varrho/(2\sigma^2)$. On $\{F>m_*+\zeta\}$, using $F\ge\kappa_N$,
$$
(1-\varrho)F=(1-\varrho)^2F+\varrho(1-\varrho)F\ge(1-\varrho)^2(m_*+\zeta)+\varrho(1-\varrho)\kappa_N .
$$
Hence
$$
\int_{\{F>m_*+\zeta\}}(1+F)e^{-F/(2\sigma^2)}\le\Bigl(1+\frac{2\sigma^2}\varrho\Bigr)e^{-(1-\varrho)^2(m_*+\zeta)/(2\sigma^2)}\Bigl(\frac{2\pi\sigma^2}{\varrho(1-\varrho)}\Bigr)^{P/2}\det\Lambda^{-1}.
$$
- **Choice of $\varrho$.** Choose $\varrho=\varrho(n,c,\zeta)$ with $(1-\varrho)^2(n/c+\zeta)\ge n/c+\zeta/2$. The map $m\mapsto(1-\varrho)^2(m+\zeta)-m-\zeta/2$ is decreasing. So $(1-\varrho)^2(m_*+\zeta)\ge m_*+\zeta/2$ for every sample, because $m_*\le n/c$.
- **Denominator.** Let $w_*$ be a minimizer, so $\kappa_N(w_*)\le m_*\le n/c$. Let $K_1$ be the closed unit neighbourhood of the compact set $\{\kappa_N\le n/c\}$.
  - The map $(w,x)\mapsto z_w(x)$ is $C^1$, so its $w$-gradient is bounded on the compact set $K_1\times X$.
  - Because $\lvert y_i\rvert\le1$, the gradient of $F_{c,S}$ on $K_1$ is then bounded by a constant $\mathrm{Lip}_1(d,X,N,n,c)$ that does not depend on $S$.
  - With $r_0=\min\{1,\zeta/(4\mathrm{Lip}_1)\}$, the ball $B(w_*,r_0)\subseteq K_1$ lies in $\{F<m_*+\zeta/4\}$. So
  $$
  \int e^{-F/(2\sigma^2)}\ge\mathrm{vol}(B_{r_0})\,e^{-(m_*+\zeta/4)/(2\sigma^2)} .
  $$
- **Ratio.** Dividing the two bounds,
$$
\mathbb E_{\Pi_\sigma}\bigl[(1+F)\mathbf 1_{\mathcal N_\zeta^c}\bigr]\le\Bigl(1+\frac{2\sigma^2}\varrho\Bigr)\Bigl(\frac{2\pi\sigma^2}{\varrho(1-\varrho)}\Bigr)^{P/2}\frac{e^{-\zeta/(8\sigma^2)}}{\det\Lambda\;\mathrm{vol}(B_{r_0})}.
$$
The right side does not depend on $S$ and tends to $0$. This proves (ii).
- **(iii)** Split $\mathbb E\Phi$ over $\mathcal N_\zeta$ and its complement. On the complement, $\Phi\le\max\{b_0,b_1\}(1+F)$. ∎

Lemma 1.0(1) gives $\lvert z_w(x)\rvert\le\sqrt{\kappa_N}\le1+F$. Lemma 1.1 then shows that $\bar z_\sigma$ and $\bar f_\sigma$ exist.

**Lemma 1.2 (atoms; the cube example).** Suppose the inputs take finitely many values, and use the notation of §1.3. For every $f$:

$$
\sum_i\bigl(f(x_i)-y_i\bigr)^2=\mathcal R(f)+W, \tag{1.1}
$$

and $\mathcal R(\operatorname{clip}f)\le\mathcal R(f)$. In the cube example, let $B\ge0$ and suppose $\mathcal R(f)\le B$. Then:

- **(a)** $\displaystyle\sum_xf(x)^2\ge\bigl(\sqrt Q-\sqrt B\bigr)_+^2$;
- **(b)** if $B<G$, then $V>0$ and $\displaystyle\sum_xf(x)^2\ge\frac{(G-B)^2}{4V}$. Write $\frac{(G-B)_+^2}{4V}$ for this bound, read as $0$ when $B\ge G$.

*Proof.*

- **(1.1).** For each atom $x\in T$,
$$
\sum_{i:x_i=x}(f(x)-y_i)^2=k_x(f(x)-\bar y_x)^2+\sum_{i:x_i=x}(y_i-\bar y_x)^2 ,
$$
because the cross term contains $\sum_{i:x_i=x}(y_i-\bar y_x)=0$. Sum over $x\in T$.
- **Clipping.** $\operatorname{clip}$ is the metric projection onto $[-1,1]$, and $\bar y_x\in[-1,1]$, so $\lvert\operatorname{clip}u-\bar y_x\rvert\le\lvert u-\bar y_x\rvert$.
- **(a).** By the triangle inequality in $\ell^2(T)$,
$$
\Bigl(\sum_xf^2\Bigr)^{1/2}\ge\Bigl(\sum_Tf^2\Bigr)^{1/2}\ge\sqrt Q-\Bigl(\sum_T(f-\bar y)^2\Bigr)^{1/2},
$$
and $\sum_T(f-\bar y)^2\le\mathcal R(f)\le B$ because $k_x\ge1$.
- **(b).** Since $k_x\bar y_x=S_x$ and $S_x=0$ off $T$, expanding gives
$$
\mathcal R(f)=\sum_Tk_xf(x)^2-2\sum_xf(x)S_x+G .
$$
So $\mathcal R(f)\le B$ gives $2\sum_xf(x)S_x\ge G-B+\sum_Tk_xf^2\ge G-B>0$. Hence some $S_x\ne0$, that is, $V>0$. Cauchy–Schwarz gives $\sum_xfS_x\le(\sum_xf^2)^{1/2}V^{1/2}$. ∎

**Lemma 1.3 (concentration).** Let $n$ inputs be i.i.d. uniform on $M$ distinct atoms, with independent fair-sign labels; the cube example is one case. Put $h_d=2n^{2/3}/M$. With probability at least $1-\rho_n$, where $\rho_n:=4e^{-n^{1/3}/2}+(4+2n/M)n^{-1/3}$, the following event $\mathcal E$ holds:

$$
\lvert Q-M\beta_d\rvert\le2n^{2/3},\qquad\lvert G-Mp_d\rvert\le2n^{2/3},\qquad\lvert V-n\rvert\le n^{2/3}. \tag{1.2}
$$

If $n=\lceil\lambda M\rceil$, then moreover $\lvert\beta_d-\beta(\lambda)\rvert$ and $\lvert p_d-(1-e^{-\lambda})\rvert$ are at most $(\lambda'+1)/M$. As $M\to\infty$ along $n=\lceil\lambda M\rceil$: $\rho_n\to0$, $h_d\to0$, $\beta_d\to\beta(\lambda)$, $p_d\to1-e^{-\lambda}$ and $\lambda'\to\lambda$.

*Proof.*

- **Input part.** Put $\Sigma_1=\sum_{x\in T}k_x^{-1}$; then $\mathbb E\Sigma_1=M\beta_d$ and $\mathbb Es=Mp_d$. Both $\Sigma_1$ and $s$ are functions of the $n$ inputs with bounded differences at most $2$. Moving one input changes two counts by one, and $k\mapsto\mathbf 1[k\ge1]/k$ and $k\mapsto\mathbf 1[k\ge1]$ change by at most $1$ per unit step. McDiarmid's inequality at $t=n^{2/3}$ gives $\Pr(\lvert\Sigma_1-M\beta_d\rvert\ge n^{2/3})\le2e^{-n^{1/3}/2}$, and the same for $s$.
- **Label part.** Given the inputs, the $S_x$ are independent sums of $k_x$ Rademacher signs, with $\mathbb ES_x^2=k_x$ and $\mathrm{Var}(S_x^2)=2k_x^2-2k_x$.
  - $\mathbb E[Q\mid\text{inputs}]=\Sigma_1$ and $\mathrm{Var}(Q\mid\text{inputs})=\sum_T(2k_x^2-2k_x)/k_x^4\le2n$.
  - $\mathbb E[G\mid\text{inputs}]=s$ and $\mathrm{Var}(G\mid\text{inputs})\le2n$.
  - Write $V=n+\sum_{i\ne j}y_iy_j\mathbf 1[x_i=x_j]$; then $\mathbb EV=n$ and $\mathrm{Var}(V)=2n(n-1)/M$.

  Chebyshev's inequality at $n^{2/3}$ gives failure probabilities $2n^{-1/3}$, $2n^{-1/3}$ and $2(n/M)n^{-1/3}$. The triangle inequality then gives (1.2).
- **Poisson comparison.** Le Cam's inequality gives $d_{TV}(\mathrm{Bin}(n,1/M),\mathrm{Poi}(\lambda'))\le n/M^2=\lambda'/M$. Also $d_{TV}(\mathrm{Poi}(\lambda'),\mathrm{Poi}(\lambda))\le\lambda'-\lambda\le1/M$. The test functions $\mathbf 1[k\ge1]/k$ and $\mathbf 1[k\ge1]$ take values in $[0,1]$. ∎

**Lemma 2.1 (depth-two memorizer; RT Lemma 2.1(2)).** Let $X=\{-1,1\}^d$, $r:X\to[-1,1]$, $\lVert r\rVert_2^2=\sum_xr(x)^2$ and $0<a\le1$. Put

$$
A_0=3\sqrt d\,\lVert r\rVert_2,\qquad m_0=\Bigl\lceil\frac{8A_0^2\ln(2M)}{a^2}\Bigr\rceil+1,\qquad F_d=1+(d+1)(d+2)^2 .
$$

There is a function $g:X\to\mathbb R$ with $\sup_X\lvert g-r\rvert\le a/2$ such that, for every width $N\ge m_0$ and every $t\in[0,1]$, some depth-two network $w_t$ of width $N$ satisfies

$$
z_{w_t}=t\,g\ \text{ on }X,\qquad\kappa_N(w_t)\le dF_d+2t^2A_0^2=dF_d+18\,d\,t^2\lVert r\rVert_2^2 .
$$

The function $g$ depends neither on $N$ nor on $t$.

*Proof.* If $r\equiv0$, take $g\equiv0$ and $w_t=0$. Otherwise proceed in five steps. Steps 1–2 are `NNG/works-in-progress/noisy-interpolation/README.md` §2, eqs. (2)–(4), re-proved here.

**Step 1 (Fourier $\ell^1$ bound).** For $J\subseteq[d]$ let $\chi_J(x)=\prod_{j\in J}x_j$ and $\hat r(J)=M^{-1}\sum_xr(x)\chi_J(x)$, so that $r=\sum_J\hat r(J)\chi_J$. Parseval gives $\sum_J\hat r(J)^2=M^{-1}\lVert r\rVert_2^2$. Cauchy–Schwarz over the $M$ sets $J$ then gives $\sum_J\lvert\hat r(J)\rvert\le\lVert r\rVert_2$.

**Step 2 (parities as tanh mixtures).** Fix $k\ge1$. Let $b_k=0$ for odd $k$ and $b_k=1$ for even $k$. For $v\in\{-1,1\}^k$, the number $\sum_jv_j-b_k$ is an odd integer, hence nonzero.

- **Sign coefficient.** Let $\mathfrak c_k=\mathbb E_v[\prod_jv_j\,\mathrm{sign}(\sum_jv_j-b_k)]$, with $v$ uniform. Grouping by the number $i$ of negative coordinates and using $\sum_{i\le t}(-1)^i\binom qi=(-1)^t\binom{q-1}t$:
  - for $k=2m+1$, $\mathfrak c_k=2^{1-k}\sum_{i\le m}(-1)^i\binom ki=(-1)^m\binom{2m}m4^{-m}$;
  - for $k=2m$, $\mathfrak c_k=2^{1-k}\sum_{i\le m-1}(-1)^i\binom{2m}i=(-1)^{m-1}\binom{2m}m4^{-m}$.
- **Lower bound on the sign coefficient.** Put $u_m=\binom{2m}m4^{-m}$. Then $u_1=\frac12$ and $u_m/u_{m-1}=\frac{2m-1}{2m}\ge\sqrt{(m-1)/m}$, because $(2m-1)^2\ge4m(m-1)$. So $u_m\ge1/(2\sqrt m)$ by induction. Hence $\lvert\mathfrak c_k\rvert\ge1/\sqrt{2k}$ for every $k\ge1$; for $k=1$, $\mathfrak c_1=1$.
- **Slope.** Let $\alpha_d=\max\{1,\frac12\ln(4\sqrt{2d})\}$, so that $\alpha_d\le d+2$. Let $\mathfrak c_{k,\alpha}=\mathbb E_v[\prod_jv_j\tanh(\alpha(\sum_jv_j-b_k))]$. For odd integers $\ell$, $\lvert\mathrm{sign}(\ell)-\tanh(\alpha_d\ell)\rvert\le1-\tanh\alpha_d<2e^{-2\alpha_d}\le1/(2\sqrt{2d})$. A Fourier coefficient moves by at most the sup-norm change of the function, so
$$
\lvert\mathfrak c_{k,\alpha_d}\rvert\ge\frac1{\sqrt{2k}}-\frac1{2\sqrt{2d}}\ge\frac1{2\sqrt{2k}}\qquad(1\le k\le d).
$$
- **Sign-flip identity.** For $J$ with $\lvert J\rvert=k$, substitute $v_j=u_jx_j$ for $j\in J$. Then on $X$
$$
\mathbb E_{u\in\{\pm1\}^J}\Bigl[\textstyle\prod_{j\in J}u_j\tanh\bigl(\alpha_d(\sum_{j\in J}u_jx_j-b_k)\bigr)\Bigr]=\mathfrak c_{k,\alpha_d}\chi_J(x)
$$
(README eq. (4)). The row realizing $\tanh(\alpha_d(\sum_{j\in J}u_jx_j-b_k))$ is $\omega_{J,u}=\alpha_d(-b_k,(u_j\mathbf 1_{j\in J})_{j\le d})$, with $\lVert\omega_{J,u}\rVert^2=\alpha_d^2(b_k^2+k)\le(d+2)^2(d+1)<F_d$.
- **Empty set.** $\chi_\emptyset=\tanh(e_0\cdot\bar x)/\tanh1$ with $e_0=(1,0,\dots,0)$, and $\lVert e_0\rVert^2=1<F_d$.
- **Assembly.** Since tanh is odd, signs can be absorbed into rows. So $r=\sum_J\hat r(J)\chi_J$ is a signed combination of $\tanh(\omega\cdot\bar x)$ over finitely many rows with $\lVert\omega\rVert^2\le F_d$. The total absolute coefficient is at most $\max\{2\sqrt{2d},1/\tanh1\}\sum_J\lvert\hat r(J)\rvert\le3\sqrt d\lVert r\rVert_2=A_0$, since $2\sqrt2<3$ and $1/\tanh1<1.32$. Putting the remaining mass on the zero row gives $r=A_0\,\mathbb E_{\omega\sim\pi}\tanh(\omega\cdot\bar x)$ on $X$, for a probability law $\pi$ on finitely many rows of squared norm at most $F_d$.

**Step 3 (sampling).** Draw $\omega_1,\dots,\omega_{m_0}$ i.i.d. from $\pi$ and put $g=\frac{A_0}{m_0}\sum_{l=1}^{m_0}\tanh(\omega_l\cdot\bar x)$. The summands $A_0\tanh(\cdot)$ lie in $[-A_0,A_0]$ and have mean $r(x)$. Hoeffding's inequality and a union bound over the $M$ inputs give
$$
\Pr\bigl[\exists x:\lvert g(x)-r(x)\rvert>a/2\bigr]\le2M\exp\Bigl(-\frac{m_0a^2}{8A_0^2}\Bigr)<1 .
$$
Fix a realization outside this event.

**Step 4 (first layer).** Split the $N\ge m_0$ neurons into $m_0$ groups of sizes $k_l\in\{\lfloor N/m_0\rfloor,\lceil N/m_0\rceil\}$. Then $\sum_lk_l=N$ and $k_l\ge\lfloor N/m_0\rfloor\ge N/(2m_0)$. Every neuron of group $l$ gets the row $\omega_l$. The first-layer energy is
$$
\frac dN\sum_lk_l\lVert\omega_l\rVert^2\le dF_d .
$$

**Step 5 (readout).** Give each copy of feature $l$ the readout weight $tA_0/(m_0k_l)$. The output is
$$
\sum_lk_l\frac{tA_0}{m_0k_l}\tanh(\omega_l\cdot\bar x)=t\,g(x),
$$
and the readout energy is
$$
N\sum_lk_l\Bigl(\frac{tA_0}{m_0k_l}\Bigr)^2=\frac{Nt^2A_0^2}{m_0^2}\sum_l\frac1{k_l}\le\frac{Nt^2A_0^2}{m_0^2}\cdot m_0\cdot\frac{2m_0}N=2t^2A_0^2 .
$$
∎

---

## 3. Theorem 5.1

**Theorem 5.1 (depth two, cube example, every $c>0$).** Let $L=2$, take the cube example $D_d$, any $n\ge1$, any $c>0$ and any $a\in(0,1]$. Put

$$
\vartheta_c=\frac1{18dc+1},\qquad E_0=c\,(dF_d+1)+\vartheta_c\,n\,a,\qquad\mathcal R_{\max}=(1-\vartheta_c)\,G+E_0,\qquad N_0(a)=\Bigl\lceil\frac{72\,d\,n\ln(2M)}{a^2}\Bigr\rceil+1,
$$

$$
\Psi_{\rm tri}=\frac1M\bigl(\sqrt Q-\sqrt{\mathcal R_{\max}}\bigr)_+^2,\qquad\Psi_{\rm cor}=\frac{(\vartheta_cG-E_0)_+^2}{4MV}\ (\text{read as }0\text{ if }\vartheta_cG\le E_0),\qquad\Psi=\max\{\Psi_{\rm tri},\Psi_{\rm cor}\}.
$$

For every sample $S$ and every learner width $N\ge N_0(a)$:

1. **(Residual budget.)** Every $w\in\mathcal N_1$ satisfies $\mathcal R(\operatorname{clip}z_w)\le\mathcal R(z_w)\le\mathcal R_{\max}$.
2. **(Near-minimizers.)** Every $w\in\mathcal N_1$ satisfies
$$
L_{D_d}(z_w)\ \ge\ L_{D_d}(\operatorname{clip}z_w)\ \ge\ 1+\Psi .
$$
3. **(Strong-prior limit, uniform in the sample.)** For every $\eta>0$ there is $\sigma_0>0$, depending only on $(d,n,c,N,\eta)$, with the following property. For all $\sigma\in(0,\sigma_0)$ and every sample:
   - $\Pi_\sigma(\mathcal N_1)\ge1-\eta$. So a Gibbs draw satisfies part 2 with posterior probability at least $1-\eta$, and $\mathcal G_\sigma\ge\mathcal G^{\rm clip}_\sigma\ge(1-\eta)(1+\Psi)$.
   - Each $f_\sigma\in\{\bar z_\sigma,\operatorname{clip}\bar z_\sigma,\bar f_\sigma\}$ satisfies $\mathcal R(f_\sigma)\le\mathcal R_{\max}+\eta$. Hence $L_{D_d}(f_\sigma)\ge1+\Psi(\eta)$, where $\Psi(\eta)$ is $\Psi$ with $E_0$ replaced by $E_0+\eta$.

   In particular, the $\liminf_{\sigma\downarrow0}$ of $\mathcal G_\sigma$, $\mathcal G^{\rm clip}_\sigma$, $L_{D_d}(\bar z_\sigma)$, $L_{D_d}(\operatorname{clip}\bar z_\sigma)$ and $L_{D_d}(\bar f_\sigma)$ is at least $1+\Psi$.

The statement is deterministic: no probability over the sample enters. Corollary 5.2 evaluates $\Psi$ on the event of Lemma 1.3. With $a=1/n$, $N_0(1/n)\le72dn^3\ln(2M)+2$ and $E_0\le c(dF_d+1)+1$, which recovers RT's statement with a slightly smaller $E_0$. With $a=1/d$, $N_0(1/d)=\lceil72d^3n\ln(2M)\rceil+1$.

*Proof.*

- **Memorizer.** Let $r=\bar y\mathbf 1_T$, so $r(x)=\bar y_x$ on $T$ and $0$ elsewhere. Then $\lvert r\rvert\le1$ and $\lVert r\rVert_2^2=Q\le n$. So $m_0$ of Lemma 2.1 satisfies $m_0=\lceil72dQ\ln(2M)/a^2\rceil+1\le N_0(a)$. Lemma 2.1 gives $g$ with $\lvert g-\bar y\rvert\le a/2$ on $T$, and, for every $N\ge N_0(a)$ and $t\in[0,1]$, networks $w_t$ with $z_{w_t}=tg$ on $X$ and $\kappa_N(w_t)\le dF_d+18dt^2Q$.
- **Residual of $tg$.** On $T$ write $e_x=g(x)-\bar y_x$, so $\lvert e_x\rvert\le a/2$. Then $tg(x)-\bar y_x=te_x-(1-t)\bar y_x$, and
$$
\mathcal R(tg)\le\sum_Tk_x\Bigl[(1-t)^2\bar y_x^2+t(1-t)a\lvert\bar y_x\rvert+\frac{t^2a^2}4\Bigr]\le(1-t)^2G+nt\Bigl[(1-t)a+\frac{ta^2}4\Bigr]\le(1-t)^2G+nta,
$$
using $\sum_Tk_x=n$, $\lvert\bar y_x\rvert\le1$ and $a\le4$.
- **Objective.** By (1.1), $cF_{c,S}(w)-W=c\,\kappa_N(w)+\mathcal R(z_w)$ for every $w$. Hence, using $Q\le G$,
$$
cF_{c,S}(w_t)-W\le c\,dF_d+G\bigl[18dc\,t^2+(1-t)^2\bigr]+nta .
$$
For $\alpha>0$, the bracket $\alpha t^2+(1-t)^2$ is minimized at $t=1/(1+\alpha)$, with value $\alpha/(1+\alpha)$. With $\alpha=18dc$ this means $t=\vartheta_c\in(0,1]$ and value $1-\vartheta_c$. So
$$
cF_{c,S}(w_{\vartheta_c})-W\le c\,dF_d+(1-\vartheta_c)G+n\vartheta_ca .
$$
- **Part 1.** For $w\in\mathcal N_1$ we have $F_{c,S}(w)\le\min F_{c,S}+1\le F_{c,S}(w_{\vartheta_c})+1$. So
$$
c\,\kappa_N(w)+\mathcal R(z_w)\le c\,dF_d+c+(1-\vartheta_c)G+n\vartheta_ca=\mathcal R_{\max}.
$$
Drop $c\kappa_N(w)\ge0$. Clipping does not increase $\mathcal R$ (Lemma 1.2).
- **Part 2.** Apply Lemma 1.2(a) and (b) to $f=\operatorname{clip}z_w$ with $B=\mathcal R_{\max}$; note $G-B=\vartheta_cG-E_0$. Finally, $\lvert\operatorname{clip}u\rvert\le\lvert u\rvert$ and $L_{D_d}(f)=1+M^{-1}\sum_xf^2$ give $L_{D_d}(z_w)\ge L_{D_d}(\operatorname{clip}z_w)$.
- **Part 3.** Apply Lemma 1.1 with $\zeta=1$ and choose $\sigma_0$ so that $\epsilon_\sigma\le\eta\min\{1,1/c\}$ for $\sigma<\sigma_0$.
  - *Gibbs.* Lemma 1.1(iii) with $\Phi=L_{D_d}(\operatorname{clip}z_w)\ge0$ gives $\mathcal G^{\rm clip}_\sigma\ge\Pi_\sigma(\mathcal N_1)(1+\Psi)$. Also $L_{D_d}(z_w)\ge L_{D_d}(\operatorname{clip}z_w)$ pointwise.
  - *Posterior means.* $\mathcal R$ is a convex function of the finite vector $(f(x))_{x\in T}$, and $\lvert z_w(x)\rvert\le1+F$ is integrable. So Jensen's inequality gives $\mathcal R(\bar z_\sigma)\le\mathbb E_{\Pi_\sigma}\mathcal R(z_w)$. Further, $\mathcal R(\operatorname{clip}\bar z_\sigma)\le\mathcal R(\bar z_\sigma)$, and $\mathcal R(\bar f_\sigma)\le\mathbb E_{\Pi_\sigma}\mathcal R(\operatorname{clip}z_w)\le\mathbb E_{\Pi_\sigma}\mathcal R(z_w)$.
  - *Budget in the limit.* Since $0\le\mathcal R(z_w)=cF-c\kappa_N-W\le cF$, Lemma 1.1(iii) gives $\mathbb E_{\Pi_\sigma}\mathcal R(z_w)\le\sup_{\mathcal N_1}\mathcal R(z_w)+c\epsilon_\sigma\le\mathcal R_{\max}+\eta$.
  - *Conclusion.* Lemma 1.2 with $B=\mathcal R_{\max}+\eta$ gives $\Psi(\eta)$. Then let $\sigma\downarrow0$ and $\eta\downarrow0$; $\Psi(\eta)\to\Psi$ by continuity. ∎

---

## 4. Corollary 5.2

Fix $\lambda>0$. For each $d$ let $n=\lceil\lambda2^d\rceil$, and let $c=c_d>0$ and $a=a_d\in(0,1]$ be arbitrary. Let $\mathcal E_d$ be the event (1.2), which has probability at least $1-\rho_n\to1$. With $h_d=2n^{2/3}/M$, define the deterministic numbers

$$
\underline\Psi_{\rm tri}:=\Bigl(\sqrt{\beta_d-h_d}-\sqrt{(1-\vartheta_c)(p_d+h_d)+c(dF_d+1)/M+\vartheta_c\lambda'a}\Bigr)_+^2,\qquad
\underline\Psi_{\rm cor}:=\frac{\bigl(\vartheta_c(p_d-h_d-\lambda'a)-c(dF_d+1)/M\bigr)_+^2}{4(\lambda'+h_d/2)},
$$

and $\underline\Psi_d=\max\{\underline\Psi_{\rm tri},\underline\Psi_{\rm cor}\}$; here $\sqrt u$ is read as $0$ for $u<0$. On $\mathcal E_d$:

- $Q/M\ge\beta_d-h_d$;
- $p_d-h_d\le G/M\le p_d+h_d$;
- $V/M\le\lambda'+h_d/2$.

$\Psi_{\rm tri}$ increases in $Q$ and decreases in $G$; $\Psi_{\rm cor}$ increases in $G$ and decreases in $V$. Dividing by $M$ therefore gives $\Psi\ge\underline\Psi_d$ on $\mathcal E_d$. The same bound holds for $\Psi(\eta)$ with $E_0$ replaced by $E_0+\eta$.

For $\nu\ge0$ define

$$
\Gamma_\lambda(\nu)=\max\Bigl\{\frac{\gamma(\lambda)}{(18\nu+1)^2},\ \Bigl(\sqrt{\beta(\lambda)}-\sqrt{(1-e^{-\lambda})\tfrac{18\nu}{18\nu+1}}\Bigr)_+^2\Bigr\}.
$$

$\Gamma_\lambda$ is continuous, nonincreasing and positive, with $\Gamma_\lambda(0)=\beta(\lambda)$ by (1.0). At $\lambda=1$ its values are:

| $\nu$ | 0 | 0.001 | 0.01 | 0.05 | $1/18$ | 0.1 | 1 |
|---|---|---|---|---|---|---|---|
| $\Gamma_1(\nu)$ | 0.4848 | 0.3488 | 0.1488 | 0.0277 | 0.0250 | 0.0127 | 0.0003 |

The two branches cross at $\nu=0.0390$. The second branch vanishes for $\nu\ge0.1829$.

**Corollary 5.2.** Assume $a_d\to0$; for example $a_d=1/d$, which gives $N_0(a_d)=O(n\log^4n)$. On $\mathcal E_d$, at every width $N\ge N_0(a_d)$, the conclusions of Theorem 5.1 hold with $\Psi\ge\underline\Psi_d$, and:

- **(i)** If $c_d\le d^k$ for a fixed $k$, then $\underline\Psi_d\ge\gamma(\lambda)(18dc_d+1)^{-2}(1-o(1))$, with the $o(1)$ uniform over $c\in(0,d^k]$.
- **(ii)** If $dc_d\le\nu$ for all large $d$, then $\underline\Psi_d\ge\Gamma_\lambda(\nu)-o(1)$.
- **(iii)** If $dc_d\to0$, then $\underline\Psi_d\ge\beta(\lambda)-o(1)$.
- **(iv)** If $dc_d\to\infty$, then on $\mathcal E_d$ the bound $\Psi$ of Theorem 5.1 itself tends to $0$.

Consequently:

- **(a)** If $c_d\le\mathrm{poly}(d)$, depth-two SP$_c$ fails (P$_2$) under each of (R1), (R2) and (R3). If $c=c(n)$, the hypothesis reads $c(n)\le\mathrm{polylog}(n)$ along $n=\lceil\lambda2^d\rceil$. It covers every fixed $c>0$ and every $c\to0$.
- **(b)** Suppose $c=c(n,d)\le\nu/\log_2n$ for all large $n$, for some $\nu>0$. Let $C_0\ge\max\{0,\log_2(1/\lambda)\}$. Then depth-two SP$_c$ fails (P$_2^{o(1)}[\log_2n+C_0]$) under each of (R1)–(R3), for every $\alpha>0$ and every $\epsilon_n\to0$. Along $n=\lceil\lambda2^d\rceil$, the probability that the inequality holds tends to $0$ at every $N\ge N_0(a_d)$, and the excess is at least $\Gamma_\lambda(\nu)-o(1)$. If moreover $c\log n\to0$, the excess is at least $\beta(\lambda)-o(1)$.
- **(c)** If $c\log n\to\infty$ along the family (equivalently $dc_d\to\infty$; this includes every $c$ bounded below, e.g. $c=1$), Theorem 5.1 gives only a vanishing lower bound. It neither proves nor refutes (P$_2^{o(1)}$). See Remark 5.8.

*Proof.*

**Limits on the family.** By Lemma 1.3, $h_d\to0$, $\lambda'\to\lambda$, $\beta_d\to\beta(\lambda)$ and $p_d\to1-e^{-\lambda}$. Also $a_d\to0$.

**(i)** Since $c\le d^k$,
$$
\frac{c(dF_d+1)}{M\vartheta_c}=\frac{c(18dc+1)(dF_d+1)}M\le\frac{d^k(18d^{k+1}+1)(dF_d+1)}{2^d}\to0 .
$$
So the numerator of $\underline\Psi_{\rm cor}$ is $\vartheta_c^2(p_d-h_d-\lambda'a_d-o(1))_+^2=\vartheta_c^2(1-e^{-\lambda})^2(1+o(1))$. Its denominator is $4\lambda(1+o(1))$.

**(ii)** Put $\vartheta_\nu=1/(18\nu+1)$. Then $\vartheta_c\ge\vartheta_\nu$, $1-\vartheta_c\le1-\vartheta_\nu=18\nu/(18\nu+1)$, $\vartheta_c\lambda'a_d\le\lambda'a_d$, and $c(dF_d+1)\le\nu(F_d+1)$, so $c(dF_d+1)/M\to0$. For large $d$ we have $p_d-h_d-\lambda'a_d>0$. Each of these quantities enters $\underline\Psi_{\rm cor}$ and $\underline\Psi_{\rm tri}$ monotonically, so the four bounds can be applied separately. Hence
$$
\underline\Psi_{\rm cor}\ge\frac{\bigl(\vartheta_\nu(p_d-h_d-\lambda'a_d)-\nu(F_d+1)/M\bigr)_+^2}{4(\lambda'+h_d/2)}\to\gamma(\lambda)\vartheta_\nu^2,
$$
$$
\underline\Psi_{\rm tri}\ge\Bigl(\sqrt{\beta_d-h_d}-\sqrt{(1-\vartheta_\nu)(p_d+h_d)+\nu(F_d+1)/M+\lambda'a_d}\Bigr)_+^2\to\Bigl(\sqrt{\beta(\lambda)}-\sqrt{(1-e^{-\lambda})(1-\vartheta_\nu)}\Bigr)_+^2 .
$$

**(iii)** For every $\nu>0$, eventually $dc_d\le\nu$, so $\liminf\underline\Psi_d\ge\Gamma_\lambda(\nu)$. Let $\nu\downarrow0$ and use $\Gamma_\lambda(0)=\beta(\lambda)$.

**(iv)** On $\mathcal E_d$, $V\ge n-n^{2/3}$, so $\Psi_{\rm cor}\le\vartheta_c^2G^2/(4MV)\to0$. Also $\mathcal R_{\max}\ge(1-\vartheta_c)G\ge(1-\vartheta_c)(p_d-h_d)M$, while $Q\le(\beta_d+h_d)M$. Since $(1-\vartheta_c)(p_d-h_d)\to1-e^{-\lambda}>\beta(\lambda)$ by (1.0), $\Psi_{\rm tri}=0$ for large $d$.

**(a)** Suppose $\mathsf p$ exists.

- *Setup.* Take the competitor $g\equiv0$: width $m=1$, all weights $0$, $B=1$, and $L_{D_d}(g)=1$. Fix $\delta\in(0,1)$ and put $\varepsilon_d=\gamma(\lambda)\vartheta_{c_d}^2/3\in(0,1)$.
- *The sample threshold is passed.* $1/\varepsilon_d=3(18dc_d+1)^2/\gamma(\lambda)$ is at most a polynomial in $d$. So $\lvert\mathsf p(d,1,1,1/\varepsilon_d,\log(1/\delta))\rvert$ is at most a polynomial in $d$, and $n=\lceil\lambda2^d\rceil$ exceeds it for $d\ge d_1$.
- *The bound fails.* By (i), $\underline\Psi_d\ge2\varepsilon_d$ for $d\ge d_2$, and also $\rho_n<(1-\delta)/2$. Fix $d\ge\max\{d_1,d_2\}$ and $N\ge N_0(a_d)$. On $\mathcal E_d$, every $w\in\mathcal N_1$ has $L_{D_d}(\operatorname{clip}z_w)\ge1+2\varepsilon_d$.
- *(R3).* The event $\{L(\mathsf A_n)\le1+\varepsilon_d\}$ lies in $\mathcal E_d^c$, which has probability at most $\rho_n<1-\delta$.
- *(R1).* By Theorem 5.1(3) with $\eta=(1-\delta)/2$, for $\sigma<\sigma_0$ the probability of $\{L(\mathsf A_n)\le1+\varepsilon_d\}$ is at most $\rho_n+\sup_S\Pi_{\sigma,S}(\mathcal N_1^c)<1-\delta$.
- *(R2).* $\underline\Psi_d(\eta)\to\underline\Psi_d$ as $\eta\downarrow0$. By Theorem 5.1(3) with $\eta$ so small that $\underline\Psi_d(\eta)>\varepsilon_d$, for $\sigma<\sigma_0$ the event lies in $\mathcal E_d^c$.
- *Conclusion.* In every reading (P$_2$) asks for probability at least $1-\delta$ at all small $\sigma$, and this fails.

**(b)** The steps are the following.

- *Dimension range.* $n\ge\lambda2^d$ gives $d\le\log_2n+\log_2(1/\lambda)\le\log_2n+C_0$, so $D_d$ is admissible.
- *Bound on $dc_d$.* $dc_d\le\nu d/\log_2(\lambda2^d)\to\nu$. So for every $\nu'>\nu$, (ii) gives $\liminf_d\underline\Psi_d\ge\Gamma_\lambda(\nu')$. Continuity of $\Gamma_\lambda$ gives $\liminf_d\underline\Psi_d\ge\Gamma_\lambda(\nu)>0$.
- *Competitor class.* The zero network lies in $\mathcal G^{(\alpha)}_n$, and every $f$ has $L_{D_d}(f)\ge1$. So $\inf_{\mathcal G^{(\alpha)}_n}L_{D_d}=1$.
- *Failure.* Since $\epsilon_n\to0$, for large $d$ we have $\underline\Psi_d\ge\Gamma_\lambda(\nu)/2>2\epsilon_n$. Repeat the argument of (a) with $\varepsilon_d$ replaced by $\epsilon_n$. The probability in (P$_2^{o(1)}$) is then at most $\rho_n+\eta$ for $\sigma<\sigma_0(\eta)$ under (R1), and at most $\rho_n$ under (R2) and (R3). For small $\eta$ and large $d$ this is below $1-\delta$.
- *Case $c\log n\to0$.* Then $dc_d\to0$, and (iii) applies.

**(c)** This is (iv): the theorem's own bound vanishes. ∎

**Numbers** (`bounds_t51.out`). The table gives worst cases on $\mathcal E_d$ at $\lambda=1$, with $a=1/n$ unless stated.

- **$c=1$.**
  - The bound is $0$ for $d\le29$ and $1.9\cdot10^{-8}$ at $d=30$.
  - It is at least $2\varepsilon_d$ for every $33\le d\le1000$ (`t1_range.out`; the ratio to $\gamma\vartheta_1^2$ is smallest at $d=33$, where it is $0.718$).
  - Its maximum is $2.26\cdot10^{-7}$, at $d=35$.
  - For larger $d$ it is about $\gamma(1)\vartheta_1^2$; for example $8.5\cdot10^{-8}$ at $d=60$.

  At $c=1$ the bound has no quantitative use.
- **Small $c$.**

| $c$ | $d=30$ | $d=60$ | $d=200$ | limit |
|---|---|---|---|---|
| $1/d$ | $3\cdot10^{-4}$ | $3\cdot10^{-4}$ | $3\cdot10^{-4}$ | $\Gamma_1(1)=3\cdot10^{-4}$ |
| $0.05/d$ | 0.0275 | 0.0277 | 0.0277 | $\Gamma_1(0.05)=0.0277$ |
| $1/d^2$ | 0.0430 | 0.0988 | 0.2189 | $\beta(1)=0.4848$ |
| $1/d^3$ | 0.3403 | 0.4099 | 0.4616 | $\beta(1)=0.4848$ |
| $1/d^3$, with $a=1/d$ | 0.2328 | 0.3090 | 0.3889 | $\beta(1)=0.4848$ |

- **Widths.** At $d=30$, $N_0(1/n)=5.7\cdot10^{31}$, while $N_0(1/d)=4.5\cdot10^{16}=4.2\cdot10^7\,n$.

---

## 5. Proposition 5.3 and remarks

**Proposition 5.3 (Hadamard atoms; constant excess when $d=M$).**

- *Atoms.* Let $M=2^k$ and $d=M$. Let $\xi_1,\dots,\xi_M\in\{-1,1\}^d$ be the rows of the Sylvester–Hadamard matrix, so $\xi_j\cdot\xi_l=M\delta_{jl}$ and $\lVert\xi_j\rVert_2=\sqrt d$.
- *Law.* Let $D^{\rm H}_M$ draw $x$ uniform on $\{\xi_j\}$ and an independent fair sign $y$. Then $L_{D^{\rm H}_M}(f)=1+M^{-1}\sum_jf(\xi_j)^2$.
- *Sample.* Let $n=\lceil\lambda M\rceil$, and define $k_j,T,\bar y_j,Q,G,V,\mathcal R$ as in §1.3 with atoms $\xi_j$.

Then:

1. For every width $N\ge1$, every $c>0$ and every sample with $Q>0$, every $w\in\mathcal N_1$ satisfies
$$
\mathcal R(\operatorname{clip}z_w)\le\mathcal R(z_w)\le\mathcal R^{\rm H}_{\max}:=c\bigl(2\sqrt Q+1\bigr)+\frac n{9Q},
$$
and hence
$$
L(z_w)-1\ge L(\operatorname{clip}z_w)-1\ge\Psi^{\rm H}:=\frac1M\Bigl(\sqrt Q-\sqrt{\mathcal R^{\rm H}_{\max}}\Bigr)_+^2 .
$$
The strong-prior statements of Theorem 5.1(3) hold verbatim with $\mathcal R^{\rm H}_{\max}$ and $\Psi^{\rm H}$ in place of $\mathcal R_{\max}$ and $\Psi$.
2. Lemma 1.3 applies verbatim, since it uses only "uniform on $M$ atoms, independent fair signs". Let $\mathcal E_M$ be its event; on it $Q>0$ for large $M$. On $\mathcal E_M$:
   - if $c\le\nu\sqrt M$ with $0\le\nu<\sqrt{\beta(\lambda)}/2$, the excess of every predictor in part 1 is at least
   $$
   \beta(\lambda)\Bigl(1-\sqrt{2\nu/\sqrt{\beta(\lambda)}}\Bigr)^2-o(1);
   $$
   - for $c\le\sqrt M$ it is at least $\beta(\lambda)-4\sqrt c\,M^{-1/4}-O_\lambda(M^{-1/3})$. In particular it is at least $\beta(\lambda)-o(1)$ when $c=o(\sqrt M)$.

*Proof.*

- **Network.** Let $u=M^{-1}\sum_{j\in T}\bar y_j\xi_j\in\mathbb R^d$. Then $u\cdot\xi_l=\bar y_l\mathbf 1_T(l)$ and $\lVert u\rVert^2=Q/M$. Fix $\tau>0$ and give every first-layer row the value $(0,\tau u)$ and every readout weight the value $1/(N\tau)$. Then
$$
z(x)=\tau^{-1}\tanh(\tau u\cdot x),\qquad\kappa_N=\frac dN\,N\tau^2\lVert u\rVert^2+N^2(N\tau)^{-2}=\tau^2Q+\tau^{-2},
$$
using $d=M$. Take $\tau^2=Q^{-1/2}$, which needs $Q>0$; then $\kappa_N=2\sqrt Q$.
- **Accuracy.** By $\lvert\tanh s-s\rvert\le\lvert s\rvert^3/3$, $\lvert z(\xi_l)-\bar y_l\rvert\le\tau^2\lvert\bar y_l\rvert^3/3\le\tau^2/3$ on $T$, and $z=0$ off $T$. So $\mathcal R(z)\le n\tau^4/9=n/(9Q)$.
- **Budget.** As in Theorem 5.1, for $w\in\mathcal N_1$,
$$
\mathcal R(z_w)\le c\kappa_N(w)+\mathcal R(z_w)\le c\bigl(\kappa_N(w_u)+1\bigr)+\mathcal R(z_{w_u})\le\mathcal R^{\rm H}_{\max}.
$$
Lemma 1.2(a) and the proof of Theorem 5.1(3) give part 1.
- **Part 2, quantities on the event.** Put $Q^\pm=M\beta_d\pm2n^{2/3}$. On $\mathcal E_M$, $\Psi^{\rm H}\ge M^{-1}\bigl(\sqrt{Q^-}-\sqrt{c(2\sqrt{Q^+}+1)+n/(9Q^-)}\bigr)_+^2$. Also $Q^-/M=\beta(\lambda)-O_\lambda(M^{-1/3})$ and $Q^+\le2M$.
- **Case $c\le\nu\sqrt M$.** The residual satisfies $\mathcal R^{\rm H}_{\max}/M\le\nu(2\sqrt{Q^+/M}+M^{-1/2})+O(1/M)\to2\nu\sqrt{\beta(\lambda)}$, which gives the first bound.
- **Case $c\le\sqrt M$.** Here $\sqrt{\mathcal R^{\rm H}_{\max}/M}\le\sqrt{4cM^{-1/2}}+O(M^{-1/2})$, and $(\sqrt q-r)_+^2\ge q-2r$ for $q\le1$. ∎

Numbers (`prop53_check.out`, worst case on $\mathcal E_M$, $\lambda=1$):

| $c$ | $M=2^{10}$ | $2^{14}$ | $2^{20}$ | $2^{30}$ | $2^{40}$ | $2^{60}$ | limit |
|---|---|---|---|---|---|---|---|
| $1$ | 0.093 | 0.279 | 0.416 | 0.474 | 0.483 | 0.4848 | $\beta(1)=0.4848$ |
| $0.1\sqrt M$ | 0.016 | 0.062 | 0.093 | 0.103 | 0.104 | 0.104 | 0.1044 |

Explicit networks at $M\le1024$ and $N\in\{1,3\}$ pass every identity. The largest observed ratio $\lvert z-\bar y\rvert/(\tau^2/3)$ was $0.983$.

Remarks on Proposition 5.3:

- **Polynomial-in-$d$ bounds.** Here $n\asymp d$, so the proposition does not contradict polynomial-in-$d$ sample bounds.
- **What it refutes.** Take $\lambda=1$, so $d=M=n$. Then the proof of Corollary 5.2(b), applied with part 2, shows that depth-two SP$_c$ fails (P$_2^{o(1)}[n]$) under (R1)–(R3) for every $c=c(n)=o(\sqrt n)$, at every width $N\ge1$, for inputs in $[-1,1]^d$ (§0.2).
- **Input norm.** The construction uses $\lVert\xi_j\rVert=\sqrt d$; Remark 5.4 treats unit-ball inputs.

**Remark 5.4 (input normalisation).**

- **Prop. 5.3 under unit-ball inputs: only small $c$ survives.** In the unit-ball model of `paper.tex` §2 (BRIEF §2, "or unit ball"), the inputs become $\xi_j/\sqrt d$.
  - *Cost.* The same function values need rows $(0,\tau\sqrt d\,u)$. Since $d=M$, the energy is $\tau^2MQ+\tau^{-2}$, minimized at $\tau^2=(MQ)^{-1/2}$ with value $2\sqrt{MQ}=\Theta(M)$, comparable to the gain $G$. The accuracy is $\tau^2/3$, so $\mathcal R\le n/(9MQ)$. `prop53_check.out` checks the cost exactly.
  - *What the proof still gives.* The proof of Proposition 5.3 then yields $\mathcal R(z_w)\le c(2\sqrt{MQ}+1)+n/(9MQ)$ on $\mathcal N_1$. On $\mathcal E_M$ this is $M(2c\sqrt{\beta(\lambda)}+o(1))$ for fixed $c$. So Lemma 1.2(a) gives excess at least $\beta(\lambda)\bigl(1-\sqrt{2c/\sqrt{\beta(\lambda)}}\bigr)_+^2-o(1)$, and $\beta(\lambda)-o(1)$ when $c\to0$.
  - *Numbers.* At $\lambda=1$ the limit is $0.334$ at $c=0.01$ and $0.104$ at $c=0.1$, and it vanishes for $c\ge\sqrt{\beta(1)}/2=0.348$ (`prop53_check.out`, part (3)).
  - *What is not settled.* For $c$ of order one, in particular $c=1$, the proof gives nothing under unit-ball inputs, and whether the learner memorizes there is open. The referee's local optimisation at $c\in\{1,4\}$ (`verify_RT_depth2_logic_scripts/opt_hadamard.out`) suggests that it does not, but that is evidence, not proof.
- **Theorem 5.1 and Corollary 5.2 survive unit-ball normalisation.** A row $\omega=(\omega_0,\omega_{1:d})$ acting on $\bar x$ equals the row $(\omega_0,\sqrt d\,\omega_{1:d})$ acting on $(1,x/\sqrt d)$, with squared norm at most $d\lVert\omega\rVert^2\le dF_d$. So the memorizer's first-layer energy becomes at most $d^2F_d$. Nothing else changes. Theorem 5.1 then holds with $dF_d$ replaced by $d^2F_d$ in $E_0$, and every asymptotic statement of Corollary 5.2 is unchanged, since only $c\,d^2F_d/M\to0$ is used.

**Remark 5.5 (learner width).**

- **Where the failures are proved.** Theorem 5.1 and Corollary 5.2 hold at learner widths $N\ge N_0(a)$. With $a=1/d$ this is $N\ge\lceil72d^3n\ln(2M)\rceil+1=O(n\log^4n)$, and with $a=1/n$ it is $O(n^3\log^2n)$. They therefore refute width-uniform formulations, which is how BRIEF §1 formalises the conjecture, and any formulation that asks for the bound at one width $N\ge N_0$. Nothing is proved at smaller widths.
- **Small widths succeed.** At much smaller widths the same learner succeeds on this example. Use the display of RT Proposition 6.1. Both width referees re-derived it and found it correct (`RT-width-logic.md` §2, `RT-width-computation.md` §2); only its "in particular" rate was wrong. Apply it at $L=2$ with the zero competitor as a width-one network with $B=1$, so that $U=1$, $E_*=d(d+1)+2$, $K=d^2+d+3+4n/c$ and $P_N=N(d+2)$. Then, with probability at least $1-\delta$, every $w\in\mathcal N_1$ at width $N$ has
$$
L_{D_d}(\operatorname{clip}z_w)-1\le\frac{c(d^2+d+3)+8}n+4\sqrt{\frac{N(d+2)\ln\bigl(2+2n\sqrt{KN}(d+N+1)\sqrt{K+1}\bigr)+\ln(4/\delta)}{2n}}+4\sqrt{\frac{\ln(4/\delta)}{2n}}.
$$
Along $n=\lceil\lambda2^d\rceil$ with $n^{-O(1)}\le c\le\mathrm{poly}(d)$, the right side tends to $0$ when $N=o(n/\log^2n)$.
- **Conclusion.** For clipped near-minimizers the failure is a large-width phenomenon. It is absent below about $n/\log^2n$ and proved above about $n\log^4n$.

**Remark 5.6 (predictors).** Corollary 5.2 and Proposition 5.3 cover:

- near-minimizers;
- Gibbs draws and Gibbs risks, clipped or not;
- the three posterior means $\bar z_\sigma$, $\operatorname{clip}\bar z_\sigma$ and $\bar f_\sigma$.

They do **not** cover the progressive-mixture predictor of BRIEF §2, the average over prefixes $t=0,\dots,n$ of posterior means. The prefix posteriors at small $t$ are not controlled by Theorem 5.1, so no lower bound is claimed for it.

**Remark 5.7 (above the window: larger $c$).** This remark is cited, not proved here.

- **The bound.** `../research-notes/B-tempered-likelihood.md` Proposition 6.1 with Lemma 5.3(a) holds for every $c>0$; it was refereed in `B-logic.md`, `B-computation.md` and `B-scope.md`. Apply it with $H=1$ and the competitor $g\equiv0$ written as a width-one network with weights in $[-1,1]$, so that $E_*=d^2+d+2$, $U=1$ and $K=n/c+1$. With probability at least $1-\delta$, on every law $D$ and at every width $N\ge1$:
$$
L_D(\operatorname{clip}z_w)\le L_D(0)+\frac{c(d^2+d+3)}n+8D_n\sqrt{\frac1c+\frac1n}+8\sqrt{\frac{\ln(2/\delta)}{2n}},\qquad D_n=\sqrt{2(d+1)\ln(n+1)} .
$$
This holds for clipped near-minimizers; the same bound holds in the strong-prior limit for $\mathcal G^{\rm clip}_\sigma$ and $\bar f_\sigma$.
- **On the cube family.** Along $n=\lceil\lambda2^d\rceil$, $D_n=\Theta(d)$, so the clipped excess tends to $0$ when $c/d^2\to\infty$ and $cd^2/n\to0$.
- **The window, clipped predictors, $n=\lceil\lambda2^d\rceil$.**
  - Constant excess for $c\le\nu/\log_2n$ (Corollary 5.2).
  - Vanishing excess for $\log^2n\ll c\ll n/\log^2n$.
  - In between, only $\Omega((dc+1)^{-2})$ from below and $O(d/\sqrt c)$ from above are known.
- **Unclipped predictors.** The unclipped version (../research-notes/B-tempered-likelihood.md Prop. 6.1 with Lemma 5.3(b)) has a main term of order $D_n\sqrt n/c$, so it vanishes only for $c\gg\sqrt n\log n$.

This replaces RT's "positive side at $L=2$" paragraph, whose "$c^\star=\mathrm{polylog}(n)$" is replaced by the window above.

**Remark 5.8 (what is open).**

1. **Constant excess when $c$ is not small.** It is open whether depth-two SP$_c$ has excess bounded below by a constant on the cube family at $n\asymp2^d$ when $dc\to\infty$. This includes every fixed $c$, and in particular the clean-label scaling $c=1$.
   - The known bounds are $\Omega((dc)^{-2})$ (Corollary 5.2(i)) and $O(d/\sqrt c)$ (Remark 5.7, clipped).
   - The proof of Theorem 5.1 would give a constant for every fixed $c$ if some depth-two network computed $t\cdot(\text{a fit of }\bar y\mathbf 1_T)$ at energy $\mathrm{poly}(d)+O(t^2G)$, instead of Lemma 2.1's $dF_d+18dt^2Q$. The bracket would then be minimized at a $t$ bounded away from $0$.
   - At depth two, memorizing arbitrary signs on $s$ distinct cube points needs energy of order at least $s/d^2$ (`../research-notes/A-tight-conditioning-fails.md` Proposition 8.2(a) with $H=1$). So that lower bound does not exclude such a network.
2. **The progressive-mixture predictor** (Remark 5.6).
3. **Widths between $n/\log^2n$ and $n\log^4n$** (Remark 5.5).
4. **Proposition 5.3 under unit-ball normalisation for $c\ge\sqrt{\beta(\lambda)}/2$**, e.g. $c=1$ (Remark 5.4).

---

## 6. Errata for other places in `../research-notes/red-team.md` that summarise §5

These replace the cited sentences. They follow from §§3–5 and claim nothing beyond them.

- **§0 item 6 (lines 25–29).** Replace by:
  > 6. **(3) $L=2$: the learner still memorizes, partially when $c$ is of order one and fully when $c\lesssim1/\log n$** (corrected §5, `../research-notes/depth-two.md`).
  >    - Proved: for every $0<c\le\mathrm{poly}(d)$, excess $\ge\gamma(\lambda)(18dc+1)^{-2}(1-o(1))$ at $n=\lceil\lambda2^d\rceil$ (for example $\approx0.0999/(18d+1)^2$ at $c=1$, $\lambda=1$). This refutes the polynomial-sample version (Theorem 5.1, Corollary 5.2(a)).
  >    - Proved: constant excess $\ge\Gamma_\lambda(\nu)-o(1)$ when $c\le\nu/d$, and $\ge\beta(\lambda)-o(1)$ when $dc\to0$. This refutes the "$+o(1)$" version uniform over $d\le\log_2n+O(1)$ for $c(n)\le\nu/\log_2n$ (Corollary 5.2(b)).
  >    - Proved: constant excess $\beta(\lambda)$ when $d=M\approx n/\lambda$ and $c=o(\sqrt n)$, for inputs of norm $\sqrt d$ (Proposition 5.3).
  >    - Open: constant excess at $n$ superpolynomial in $d$ when $c$ is bounded below (precisely, when $c\log n\to\infty$), e.g. $c=1$.
  >    - Numerics: on single samples, low-objective networks absorb at least 0.40 of the noise at $d=8$ and at least 0.58 at $d=10$. The two runs used different optimizer budgets, so they show no trend in $d$.
- **§2.3 A3, last sentence (line 197).** Replace "The depth-two cube bound (Theorem 5.1) refutes only the polynomial one." by: "The depth-two cube bound (Theorem 5.1) refutes the polynomial one for every $c\le\mathrm{poly}(d)$. It also refutes the '$+o(1)$' one when $c\le\nu/\log_2n$, with constant excess $\Gamma_\lambda(\nu)$, and $\beta(\lambda)$ when $c\log n\to0$. It is silent on the '$+o(1)$' one when $c\log n\to\infty$, e.g. for every fixed $c$."
- **§5 heading.** Replace "Depth two ($L=2$) with $c=1$" by "Depth two ($L=2$), every $c>0$".
- **Corollary 5.2.** Replace its last two sentences, including the parenthetical, by Corollary 5.2 and the "Numbers" paragraph of §4.
- **"The positive side at $L=2$" paragraph.** Replace by Remark 5.7.
- **§5.4 numerics.** Delete "At depth two, the captured fraction rises with $d$, from 0.40 to 0.58." The two rows are lower bounds for single samples obtained with different optimizer budgets (3×20000 against 1×6000 L-BFGS iterations).
- **§5 "Open" paragraph (line 440).** It already concerns $c=1$. Add: "(for $c\lesssim1/\log n$ the excess is constant, by Corollary 5.2(b))".
- **§6.1 "High dimension with repeated inputs".** Add "(for inputs of norm $\sqrt d$ when $c=o(\sqrt n)$; for unit-ball inputs only when $c<\sqrt{\beta(\lambda)}/2$, not at $c=1$)".
- **§6.4, second bullet.** Replace by "Constant excess at depth two with $n$ superpolynomial in $d$ when $c\log n\to\infty$ (e.g. fixed $c$)."
- **§7 item 3, last sentence.** Replace "At depth two, $c^\star$ is only polylogarithmic." by "At depth two, for clipped predictors, the transition lies between $c\approx1/\log n$ (constant excess below) and $c\approx\log^2n$ (vanishing excess above)."

---

## 7. Numerical record

All scripts are in `../checks/depth-two/`, and each has a matching `.out` file.

| Script | What it checks | Result |
|---|---|---|
| `bounds_t51.py` | $\beta,\gamma$ and their maxima; $\beta\ge4\gamma$ on $\lambda\in[0.05,10]$; Theorem 5.1's explicit bound on the worst case of $\mathcal E_d$ for $c=1$ and small $c$, with $a=1/n$ and $a=1/d$; $\Gamma_\lambda(\nu)$ and its branch crossing; convergence of the explicit bound at $c=\nu/d$ to $\Gamma_1(\nu)$ ($d\le400$); widths $N_0$ | values as in §§1.3, 4. Example: $c=\nu/d$, $\nu=0.05$: $0.0275$ ($d=30$), $0.0277$ ($d\ge60$) |
| `t1_range.py` | $c=1$: bound $\ge2\varepsilon_d$ for every $33\le d\le1000$ | no exception; minimum ratio $0.718$ at $d=33$ |
| `prop53_check.py` | Prop. 5.3 with explicit matrices ($M\le1024$, $N\in\{1,3\}$, $\lambda\in\{1,1.5\}$): orthogonality, $\kappa_N=2\sqrt Q$, error $\le\tau^2/3$, $\mathcal R\le n/(9Q)$, unit-ball cost $\tau^2MQ+\tau^{-2}$; explicit bound on $\mathcal E_M$ for $c=1$ and $c=\nu\sqrt M$; (3) unit-ball bound for $c\in\{1,0.5,0.3,0.1,0.01,1/\log_2M\}$ | all assertions pass; table in §5. Unit ball: $0$ at $c\ge0.5$; at $M=2^{60}$, $0.0025$ ($c=0.3$), $0.104$ ($c=0.1$), $0.334$ ($c=0.01$) |
| `lemma_checks.py` | Lemma 1.2(a),(b) with a general budget against the exact constrained minimum (3000 instances); $\mathcal R(tg)\le(1-t)^2G+nta$ (20000 random and adversarial instances); the bracket (sympy); $\mathfrak c_k=\pm\binom{2m}m4^{-m}$ and $\lvert\mathfrak c_k\rvert\ge1/\sqrt{2k}$ ($k\le40$); $\lvert\mathfrak c_{k,\alpha_d}\rvert2\sqrt{2k}\ge1$ ($1\le k\le d\le80$) | 0 violations; minimum $1.337$ |
| `lemma21_net.py` | Lemma 2.1 built explicitly ($d=3,4,5$; $a\in\{1,\frac12\}$; $N\in\{m_0,2.5m_0+3\}$; $t\in\{1,0.37,\vartheta_1\}$): exact mixture, mass $\le A_0$, rows $\le F_d$, $\sup\lvert g-r\rvert\le a/2$, output $=tg$, $\kappa_N\le dF_d+2t^2A_0^2$, residual and objective chain | all pass |
| `lemma13_mc.py` | $\mathrm{Var}(S^2)=2k^2-2k$ ($k\le10$); frequency of $\mathcal E_d$ against its guaranteed lower bound ($d=8,10,12,14$) | frequency $0.930/0.972/0.995/0.999$ against guarantees $-0.11/0.38/0.62/0.76$ |

These agree with the referees' independent scripts, `../checks/verify-RT-depth2-logic/` and `../checks/verify-RT-depth2-computation/`. The values at $c=d^{-3}$ differ slightly from those the logic referee reports (0.342/0.410/0.462): the referee used the surrogate values $Q=\beta M$, $G=(1-e^{-1})M$, $V=M$, while §4 uses the worst case on $\mathcal E_d$.

---

## 8. Response to referees

Entries are keyed to the issue lists: J = the JSON issue, L = `RT-depth2-logic.md` §3, C = `RT-depth2-computation.md` §7. Issue C1 is the same as J and L1. The referees' constant $\kappa$ is renamed $\nu$, to avoid a clash with the energy $\kappa_N$.

**J (= L1 = C1). Major: false scope claim in Corollary 5.2 (last sentence), §2.3 A3 and the §0 item 6 "Open" bullet. Accepted, fixed, and the result strengthened.**

- *Diagnosis.* The sentence "It does not refute the '$+o(1)$' formulation, since $\varepsilon_d\asymp1/\log^2n$" was false on the corollary's own range, which includes $c\to0$. $\varepsilon_d$ is of order $(dc+1)^{-2}$, which is of order one when $c=O(1/d)$.
- *Fix.* Corollary 5.2 now has three regimes:
  - for $c\le\nu/d$, excess $\ge\Gamma_\lambda(\nu)-o(1)\ge\gamma(\lambda)/(18\nu+1)^2-o(1)$; this is $0.0277$ at $\nu=0.05$, $\lambda=1$;
  - for $dc\to0$, excess $\ge\beta(\lambda)-o(1)$, from the same budget $(1-\vartheta_c)G+E_0$ with Lemma 1.2(a) in place of 1.2(b);
  - both refute the "$+o(1)$" formulation uniform over $d\le\log_2n+C_0$, for every $c(n)\le\nu/\log_2n$ (Corollary 5.2(b)).
- *Scope of the old sentence.* It is kept only where it is true: when $dc\to\infty$, which includes every $c$ bounded below (Corollary 5.2(c),(iv)).
- *Theorem 5.1.* It now states both bounds, so the corollary needs no new argument.
- *Errata.* §6 gives replacement text for A3, for §0 item 6 (the "Open" bullet is restricted to $c\log n\to\infty$, which covers $c$ bounded below), for §6.4, and for §7 item 3.
- *Numbers.* The referees' values are reproduced, here as worst cases on the event:
  - at $c=0.05/d$: $0.0275$ at $d=30$ and $0.0277$ for $d\ge60$ (the referee's surrogate gives $0.0277$ at every $d$);
  - at $c=d^{-3}$: $0.340$, $0.410$ and $0.462$ for $d=30$, $60$ and $200$.

**L2. Minor: width not stated in Corollary 5.2. Accepted.**

- Theorem 5.1 and Corollary 5.2 now state the width $N\ge N_0(a)$.
- I adopted C3's choice $a=1/d$, which gives $N_0=O(n\log^4n)$.
- The optional $a=\eta(18dc+1)^{-1/2}$ was not used. For fixed $c$ it would save a further width factor of order $d\eta^2/c$. But it does not tend to $0$ when $dc=O(1)$, so it would lose part of the constants in regimes (ii)–(iii) of Corollary 5.2, which need $a_d\to0$.
- Remark 5.5 states that only width-uniform formulations, or formulations that ask for one width $N\ge N_0$, are refuted.
- Remark 5.5 also records the small-width contrast: by the display of RT Prop. 6.1 (which the width referees found correct), with the zero competitor, clipped near-minimizers have vanishing excess on this example at $N=o(n/\log^2n)$.

**L3. Minor: the predictors covered are not named; the progressive mixture is not covered. Accepted.**

- §1.2, Corollary 5.2(a) via (R1)–(R3), and Remark 5.6 name the predictors covered: near-minimizers, Gibbs draws and Gibbs risks (clipped or not), and $\bar z_\sigma$, $\operatorname{clip}\bar z_\sigma$, $\bar f_\sigma$.
- The progressive mixture is explicitly excluded, and no claim is made for it.

**L4. Minor: Proposition 5.3 depends on inputs of norm $\sqrt d$. Accepted.**

- Proposition 5.3 now states $\lVert\xi_j\rVert=\sqrt d$.
- Remark 5.4 confirms that under unit-ball normalisation the same construction costs $2\sqrt{MQ}=\Theta(M)$, comparable to $G$; the cost is checked exactly in `prop53_check.out`.
- One refinement of the referee's "the proof fails": that holds for $c$ of order one (e.g. $c=1$; vanishing for all $c\ge\sqrt{\beta(\lambda)}/2=0.348$ at $\lambda=1$). For smaller $c$ the same argument still gives excess $\ge\beta(\lambda)(1-\sqrt{2c/\sqrt{\beta(\lambda)}})_+^2-o(1)$, and $\beta(\lambda)-o(1)$ when $c\to0$ (Remark 5.4, `prop53_check.out` part (3)). The §0.1 summary, the Remark 5.8 open problem and the §6 erratum for §6.1 are worded accordingly.
- The referee's optimisation at $c\in\{1,4\}$ is cited as evidence only.
- Remark 5.4 also proves the referee's statement that Theorem 5.1 and Corollary 5.2 survive unit-ball normalisation with $dF_d\to d^2F_d$.

**L5. Minor: the quantifier on $d$ in the "$+o(1)$" formulation. Accepted.**

- §1.4 defines (P$_2^{o(1)}[\phi]$) with an explicit dimension range $d\le\phi(n)$, together with the readings (R1)–(R3).
- §0.2 gives the referee's table, with one addition: the fixed-$d$ row now cites `../research-notes/A-tight-conditioning-fails.md` Proposition 5.2 (refereed) for "the cube family is consistent at fixed $d$".

**L6. Minor: wording and edge cases. Accepted, item by item.**

- "$\Omega(1/(dc)^2)$" is now $\Omega((dc+1)^{-2})$.
- $O(d/\sqrt c)$ is stated as a bound for clipped predictors only, and the "$c^\star=\mathrm{polylog}(n)$" sentence is replaced by the two-sided window (Remark 5.7).
- Lemma 1.2(b) now proves that $B<G$ forces $V>0$.
- Proposition 5.3 assumes $Q>0$, which holds on the event for large $M$.
- The display of Theorem 5.1 is stated deterministically.
- The §5 heading is corrected (§6).
- The network scale $\epsilon$ is renamed $\tau$.
- The rate in Proposition 5.3 is now explicit: $\beta(\lambda)-4\sqrt cM^{-1/4}-O(M^{-1/3})$.

**C2. Minor: the numerical parenthetical in Corollary 5.2. Accepted.**

- The bound was recomputed on the worst case of the event (`bounds_t51.out`, `t1_range.out`): $0$ for $d\le29$; $1.9\cdot10^{-8}$ at $d=30$; at least $2\varepsilon_d$ for every $33\le d\le1000$; maximum $2.26\cdot10^{-7}$ at $d=35$.
- These values agree with the referee's.

**C3. Minor: the width threshold is an artefact of $a=1/n$. Accepted.**

- The accuracy $a$ is a free parameter of Theorem 5.1, with $N_0(a)=\lceil72dn\ln(2M)/a^2\rceil+1$.
- I adopted the referee's sharper residual bound $\mathcal R(tg)\le(1-t)^2G+nta$, which holds for $a\le4$ and was verified on 20000 instances. It gives $E_0=c(dF_d+1)+\vartheta_cna$, at least as good as RT's $c(dF_d+1)+2$.
- With $a=1/d$ the width is $O(n\log^4n)$, and every asymptotic statement is unchanged. Corollary 5.2 needs only $a_d\to0$.

**C4. Optional: loose constants. Not adopted.**

- The improvements would replace $18d$ by $16d$, $G$ by $Q$ in the bracket, and $F_d$ by $\max\{1,(d+1)\alpha_d^2\}$. They change constants and the first $d$ at which the $c=1$ bound is positive, but no regime and no conclusion.
- Keeping RT's constants keeps the proof aligned with the computations the referees already checked.

**C5. Minor: Proposition 5.3 needs $Q>0$; its hypothesis can be weakened. Accepted.**

- $Q>0$ is now a hypothesis of part 1.
- Part 2 covers $c\le\nu\sqrt M$ with $\nu<\sqrt{\beta(\lambda)}/2$ (limit $0.104$ at $\nu=0.1$, $\lambda=1$, matching the referee's value).
- Part 2 states the rate $4\sqrt cM^{-1/4}+O(M^{-1/3})$; it is slow, e.g. $0.093$ at $M=2^{10}$, $c=1$, worst case on the event.

**C6. Minor: the "positive side at $L=2$" paragraph. Accepted.**

- Remark 5.7 replaces it. The upper bound is now cited from the refereed ../research-notes/B-tempered-likelihood.md Proposition 6.1 and Lemma 5.3(a), with explicit constants, and is stated for clipped predictors only.
- Remark 5.7 notes that the unclipped bound needs $c\gg\sqrt n\log n$, and states the window in the corrected form "$\Omega((dc+1)^{-2})$ versus $O(d/\sqrt c)$".

**C7. Minor: §5.4 numerics compare two lower bounds obtained with different optimizer budgets. Accepted.**

- Nothing in §§3–5 uses these numerics.
- §6 withdraws the sentence "the captured fraction rises with $d$" and rewords the §0 item 6 numerics bullet so that it no longer suggests a trend.

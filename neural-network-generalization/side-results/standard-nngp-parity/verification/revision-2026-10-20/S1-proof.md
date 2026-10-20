# The sign-only tanh NNGP learner fails on typical samples up to $n=\exp\!\big(c\,d\log\log d/\log d\big)$

*Verification write-up of the package (1)–(4): the restriction lemma, two-step regularity, the intrinsic-dimension Gram bound, and Theorem S1. This is a scratch document. No repository file was edited. Revised after three referee reports. Two judged the work correct and one "correct with fixable gaps", and none found a mathematical error. The changes are listed in §9 (Responses to referees). Theorem S1 is proved **conditionally on [SE] Lemma 4.1**, and its $d_0$ is not explicit and, as bounded here, astronomically large. Both caveats are explained in §0.*

---

## 0. Results and status

Notation is fixed in §1. Throughout, $f=\chi_{[d]}$ is full parity, $\theta=13/20$, and $c_\theta=\sqrt{2\pi}\,(e^{-1}-7/20)=0.044817\ldots$.

| # | Statement | Where | Status |
|---|---|---|---|
| 1 | **ABFR bound.** For $0\le j<k$: $\sup_{\deg L\le j}\Pr\{\chi_{[k]}L>0\}\le 1-2^{-k}\sum_{i\le (k-j-1)/2}\binom ki\le \tfrac12+\tfrac{j+1}{\sqrt{2\pi k}}$. | Lemma 2.1 | proved (classical; proof included) |
| 2 | **Restriction lemma.** For every $h$, every $p\in(0,1]$, every integer $j\ge0$ and every $a>0$: $\Pr_x\{fh\ge a\}\le \mathbb E_{m\sim\mathrm{Bin}(d,p)}\beta(j,m)+a^{-2}\sum_U\hat h(U)^2\Pr\{\mathrm{Bin}(\lvert U\rvert,p)>j\}$, where $\beta(j,m)=1-\mathrm{err}_j(\chi_{[m]})$. | Lemma 2.2 | proved |
| 3 | **Corollary.** If $\deg h\le u$, $\rho=u/d$, $R=a^{-2}\sum_{U\ne\emptyset}\hat h(U)^2$, then for every integer $1\le J\le e^2u$: $\Pr\{fh\ge a\}\le\frac12+e\sqrt{J\rho/\pi}+\frac12e^{-J/(8e^2\rho)}+Re^{-J}$. This is the choice $p=J/(e^2u)$, $j=J-1$. | Cor. 2.3 | proved |
| 4 | **Two-step regularity, first layer.** For $\tanh$ at variance $\sigma^2$ and every odd $m$: $c_{m+2}\ge\gamma(\sigma)c_m$, with explicit $\gamma(\sigma)=\big(6(1+\frac{\pi}{2\sigma})^4\big)^{-1}$. | Lemma 3.1 | proved |
| 5 | **Composites inherit regularity** (random-sum/injection argument), with the same $\gamma=\gamma(\sigma_1)$. | Lemma 3.2 | proved |
| 6 | **Cube transfer.** $W_{j+2}\ge\gamma\frac{(D-j)(D-j-1)}{D^2}W_j$; $\tau_r\le(1+4/\gamma)\tau_{r+2}$ for odd $r\le D/2-3$; hence $\tau_r\le(1+4/\gamma)^k\tau_{r+2k}$ when $r+2k+1\le D/2$. | Lemma 3.3 | proved |
| 7 | **Intrinsic-dimension matrix Chernoff** (expectation form), derived from Lieb's theorem. It is slightly sharper than Tropp's Thm 7.2.1 as recalled: $\log\operatorname{intdim}$ instead of $\log(2\operatorname{intdim})$. Tropp's statement is recalled, not checked, and serves only as context (Remark 4.1). | Prop. 4.2 | proved (modulo Lieb's theorem) |
| 8 | **Tail-Gram bound.** $\mathbb E\lVert Q_{SS}\rVert\le(e-1)n\lambda_{r+1}+\tau_r\log(\tau_r/\lambda_{r+1})\le(e-1)n\lambda_{r+1}+\tau_r\log(2\tau_r/\lambda_{r+1})$ for iid uniform inputs, repeats included. | Lemma 4.3 | proved |
| 9 | **Intrinsic dimension of the $\tanh$ tail.** $\binom D{r+2}\le\tau_r/\lambda_{r+1}\le D^{r+2}/((r+2)!\,c_{r+2})$, so $\log(\tau_r/\lambda_{r+1})\le(r+2)\log\frac{eD}{r+2}+\min\{\frac{r+1}2\log\frac1\gamma+\log\frac1{c_1},\ C_\phi\sqrt{r+2}+\log\frac1\kappa\}$. The task's form "$Cr H_r+C\sqrt d$" is true, but the $\sqrt d$ term is unnecessary. | Lemma 4.4 | proved |
| 10 | **Mean–confidence lemma** (subcritical Lemma 10.1, re-derived), including the head inequality with repeated points. | Lemma 5.1 | proved |
| 11 | **Master inequality.** A deterministic lower bound on $F_\theta(S)$ for any training sequence satisfying coercivity at degree $r$. | Prop. 6.3 | proved |
| 12 | **Theorem S1.** For $\tanh$ at every fixed depth and gains, with $c=10^{-3}$: for all $d\ge d_0$ and all $0\le n\le e^{c\,d\log\log d/\log d}$, $\Pr_S\{\Pr_x(q_S\le\frac{13}{20})\ge\frac38\}\ge\frac34$, hence $\liminf_NF_N(S)\ge\frac38$ on that event. Any $c<\pi/(64e^2)\approx6.6\cdot10^{-3}$ also works (Remark 7.1). Here $d_0=d_0(c_*,\sigma_1,c_1,A)$ is not explicit. The bookkeeping of §6.2 makes it astronomically large (Remark 7.2). | Thm 6.1 | **proved conditionally on [SE] Lemma 4.1**, through [SE] Lemmas 4.3 and 4.4 (caveat 1 below). Regime I ($n\le n_0(d)$) is unconditional. |
| 13 | $\tau_r/\tau_u=d^{o(1)}$ with $u-r=O(\log d/\log(1/\rho))$. Explicitly, in the range of Thm 6.1, $\log(\tau_r/\tau_u)\le\Theta_d=(1+o(1))\,\tfrac12\log(1+\tfrac4\gamma)\,\frac{\log d}{\log\log d}$, and the convergence is slow. Only $\tau_r/\tau_u\le d^{O(1)}$ is needed. | Lemma 6.5 | proved |

Nothing in the package failed. The corrections relative to the exploration are minor. They are listed in §8. The referees found no mathematical error. Their points are addressed in place and listed in §9: the status of the imported coercivity lemma, the size of $d_0$, explicit constants, the wording of the numerics, and citations.

**Two caveats on Theorem S1.**

1. **Conditional status.** Theorem S1 uses one nontrivial black box, [SE] Lemma 4.4 (squared coercivity, (K6) in §1.4).
   - In [SE], Lemma 4.4 is proved from [SE] Lemma 4.3, which is proved from [SE] Lemma 4.1.
   - Lemma 4.1 does not apply a stated theorem of Lee (2023). It uses an intermediate estimate from the *proof* of Lee's Lemma 2.12, eq. (2.20), in a homogeneous form with Lee's energy normalization (2.17) undone. [SE] justifies that form in its Remark 4.2, and adds a seminorm-approximation step.
   - Lee's paper could not be read from this environment, because arxiv.org is blocked.
   - So **Theorem S1 is proved conditionally on [SE] Lemma 4.1**, that is, on the homogeneous form of Lee (2023), eq. (2.20), as derived in [SE] Remark 4.2. Regime I does not use (K6).
   - The dependence is essential. With the sample size $n\gtrsim D_r^2$ of a plain contraction argument, Regime II would give nothing beyond Regime I (Remark 1.1).
2. **Size of $d_0$.** The theorem is purely asymptotic.
   - $d_0$ is not explicit, because $A=A_{1/8}$ is not.
   - Even with the smallest value the proof allows, $A=1$, condition (L9) alone forces $d_0\ge10^{37}$ at $\sigma_1=3$, $10^{58}$ at $\sigma_1=1$ and $10^{157}$ at $\sigma_1=0.3$.
   - The crossover $d_\times\approx2.58\cdot10^8$, where Regime II becomes non-empty, is only a necessary condition for new content.
   - A direct evaluation of the inequalities the proof actually uses indicates that the argument works much earlier (Remark 7.2). That is a numerical observation at grid points, for given values of $A$, and is not part of the theorem.

**Imported results, used exactly as stated in their sources.**

- [Std]: `standard-nngp-parity.tex`.
  - Lemma 2.2 (dual activations), Lemma 2.3 (composites), Lemma 2.5 (cube spectrum), Lemma 2.6(a),(b) (level-mass inequalities).
  - Proposition 2.4(iii) (width limits).
  - Lemma 4.1 (Hermite coefficients of $\tanh$) and Corollary 4.2.
  - The short proofs of the facts actually used are recalled in §1.
- [SE]: `subcritical-exponential`, Lemma 4.4 (squared coercivity). It is the only nontrivial black box. Its proof chain is [SE] Lemma 4.4 ← Lemma 4.3 ← Lemma 4.1 ← Lee (2023), eq. (2.20), in the homogeneous form of [SE] Remark 4.2. The last link is unverified here (caveat 1; §1.4).
- Prékopa's marginal theorem (A. Prékopa, *On logarithmic concave measures and functions*, Acta Sci. Math. (Szeged) 34 (1973) 335–343): marginals of log-concave densities are log-concave. Lemma 5.1(ii) uses it twice, once for the density of $Y$ and once for its cdf, as in [SE] Lemma 10.1.
- Lieb's concavity theorem (E. H. Lieb, *Convex trace functions and the Wigner–Yanase–Dyson conjecture*, Adv. Math. 11 (1973) 267–288, Thm 6): for fixed Hermitian $H$, the map $B\mapsto\operatorname{tr}\exp(H+\log B)$ is concave on positive definite matrices.
  - It is used through the subadditivity of matrix cumulant generating functions, which follows from it by conditioning and Jensen (§4).
  - The theorem numbers cited for Lieb and Tropp are recalled. They were not checked against the texts, which cannot be accessed here.

---

## 1. Setting, notation, imported facts

### 1.1 The cube

- **The cube.** $\mathcal X=\{-1,1\}^d$ carries the uniform probability measure. Put $M=2^d$ and $D=d+1$.
- **Walsh expansion.** For $U\subseteq[d]$, $\chi_U(x)=\prod_{i\in U}x_i$. For $g:\mathcal X\to\mathbb R$:
  - $\hat g(U)=\mathbb E_x g(x)\chi_U(x)$, so that $g=\sum_U\hat g(U)\chi_U$;
  - $\lVert g\rVert_2^2=\mathbb E_xg^2=\sum_U\hat g(U)^2$;
  - $\deg g=\max\{\lvert U\rvert:\hat g(U)\neq0\}$.
- **Projections.** For $0\le v\le w\le d$:
  - $g_{\le v}=\sum_{\lvert U\rvert\le v}\hat g(U)\chi_U$;
  - $g_{>v}=g-g_{\le v}$;
  - $g_{(v,w]}=g_{\le w}-g_{\le v}$.
- **Other notation.** $D_v=\sum_{q\le v}\binom dq$; $f=\chi_{[d]}$; $t_-=\max\{-t,0\}$; $\log$ is natural.
- **Error of degree-$j$ thresholds.** $\mathrm{err}_j(g)=\min_{\deg p\le j}\Pr_x\{g(x)p(x)\le0\}$, with zeros counted as errors.

Elementary binomial facts used below:

- **(B1)** $\binom mk\le(em/k)^k$, $\binom mk\ge(m/k)^k$, and $k!\ge(k/e)^k$.
- **(B2)** If $1\le q\le(d+1)/3$, then $\binom d{q-1}=\frac q{d-q+1}\binom dq\le\frac12\binom dq$. Hence $D_v\le2\binom dv$ for $v\le(d+1)/3$.
- **(B3)** For $0\le j\le D-2$,
  $$\binom D{j+2}\Big/\binom Dj=\frac{(D-j)(D-j-1)}{(j+1)(j+2)}\ge\Big(\frac{D-j-1}{j+2}\Big)^2.$$
- **(B4)** $\binom dq\le\binom Dq$, and $\binom d{q-1}+\binom dq=\binom Dq$.
- **(B5)** For $k\ge1$, $\max_i\binom ki2^{-k}\le\sqrt{2/(\pi k)}$.
  - For $k=2l$ this is Wallis' inequality $\binom{2l}l4^{-l}\le(\pi l)^{-1/2}$.
  - For $k=2l+1$ with $l\ge1$, the maximum equals $\binom{2l}{l}4^{-l}\frac{2l+1}{2l+2}$. It is at most $\sqrt{2/(\pi(2l+1))}$ because $(2l+1)^3\le8l(l+1)^2$.
  - For $k=1$ it is $1/2\le\sqrt{2/\pi}$.

### 1.2 The kernel ([Std] §2, §4)

**Layer data.**

- $\phi=\tanh$; the depth $L\ge2$ and the gains $\sigma_1,\dots,\sigma_L>0$ are fixed.
- $v(q)=\mathbb E\tanh^2(\sqrt qG)$ with $G\sim N(0,1)$.
- $q_1=\sigma_1^2$ and $q_{\ell+1}=\sigma_{\ell+1}^2v(q_\ell)$.

**Dual activation.** $\hat\phi_q(\rho)=\mathbb E\tanh(\sqrt qU)\tanh(\sqrt qV)/v(q)=\sum_mc_m(q)\rho^m$, where $(U,V)$ are standard Gaussians with correlation $\rho$.

**Composite and kernel.**
$$F=\hat\phi_{q_{L-1}}\circ\cdots\circ\hat\phi_{q_1}=\sum_m c_mt^m,\qquad A=\sigma_L^2v(q_{L-1}),\qquad K(x,y)=A\,F\Big(\frac{1+x\cdot y}D\Big).$$

**(K1) Coefficients** ([Std] Lemmas 2.2, 2.3, 4.1).

- $c_m(q)\ge0$ and $\sum_mc_m(q)=1$.
- $c_m(q)=0$ for even $m$.
- For odd $m$,
  $$c_m(q)=\frac{q^m I_m(\sqrt q)^2}{m!\,v(q)}>0,\qquad I_m(\sigma)=\int_0^\infty\frac{\omega^me^{-\sigma^2\omega^2/2}}{\sinh(\pi\omega/2)}\,d\omega.$$
  (Recall: Gaussian integration by parts gives $\beta_m=\sigma^m\mathbb E[\tanh^{(m)}(\sigma G)]/\sqrt{m!}$. The Fourier transform of $\operatorname{sech}^2$ is $\pi\omega/\sinh(\pi\omega/2)$. Fourier inversion then gives $\mathbb E\tanh^{(m)}(\sigma G)=(-1)^{(m-1)/2}I_m(\sigma)$.)
- The same properties hold for $F$: $c_m\ge0$, $\sum c_m=1$, and $F$ is odd. Moreover $[t^m]F\ge c_m(q_1)\prod_{\ell\ge2}c_1(q_\ell)>0$ for every odd $m$, and $c_1=\prod_{\ell=1}^{L-1}c_1(q_\ell)>0$.
- The $c_m$ and $A$ do not depend on $d$.
- Numerically, the formula gives $\sum_{m\le4001}c_m(q)=1-O(10^{-12})$ for $\sigma\in\{0.3,0.5,1,2,3\}$ (§8.3).

**(K2) Walk representation and spectrum** ([Std] Lemma 2.5).

- Let $(\zeta_m)_{m\ge0}$ be the Ehrenfest chain on $\{0,\dots,D\}$: $\zeta_0=0$, and from state $i$ it moves to $i+1$ with probability $(D-i)/D$ and to $i-1$ with probability $i/D$. Equivalently, $\zeta_m$ is the Hamming distance from the start of the walk on $\{-1,1\}^D$ that flips one uniform coordinate per step.
- Put
  $$W_j=\sum_mc_m\Pr\{\zeta_m=j\},\qquad a_j=W_j\Big/\binom Dj\qquad(0\le j\le D).$$
  Expanding $(u\cdot u'/D)^m$ as an average over $m$ independent uniform coordinates gives $F(u\cdot u'/D)=\sum_{V\subseteq\{0,\dots,d\}}a_{\lvert V\rvert}\chi_V(u)\chi_V(u')$.
- Restricting to $u=(1,x)$ gives
  $$K(x,y)=\sum_{U\subseteq[d]}\lambda_{\lvert U\rvert}\chi_U(x)\chi_U(y),\qquad\lambda_q=A(a_q+a_{q+1}).$$
- $\sum_jW_j=\sum_mc_m=1$.
- Since $F$ is odd, $a_j=W_j=0$ for even $j$, and $\lambda_{2k}=\lambda_{2k+1}=Aa_{2k+1}$.
- [Std] Lemma 2.5(a),(c),(d): $\lambda_q>0$ for all $q$, and $q\mapsto\lambda_q$ is nonincreasing. So the matrix $K$ is positive definite, with eigenvalue $M\lambda_{\lvert U\rvert}$ on $\chi_U$.

**(K3) Tails.**

- For $0\le v<d$ put
  $$\tau_v=\sum_{q>v}\binom dq\lambda_q,\qquad Q_v(x,y)=\sum_{\lvert U\rvert>v}\lambda_{\lvert U\rvert}\chi_U(x)\chi_U(y).$$
- $Q_v(x,x)=\tau_v$.
- As an $M\times M$ matrix, $Q_v\succeq0$ has eigenvalues $M\lambda_q$ ($q>v$), so $\lVert Q_v\rVert_{\rm op}=M\lambda_{v+1}$.
- **(Levels a)** $\binom d{v+1}\lambda_{v+1}\le\tau_v$ for every $v$.
- **Pairing for odd $r$.** By the pairing $\lambda_{2k}=\lambda_{2k+1}=Aa_{2k+1}$ and (B4),
  $$\tau_r=A\,T_r,\quad T_r:=\sum_{j\ \rm odd,\ j\ge r+2}W_j\le1,\qquad \lambda_{r+1}=\frac{A\,W_{r+2}}{\binom D{r+2}}.\tag{1.1}$$
  If $d$ is even, the top level $q=d$ is unpaired. It still fits (1.1), because $\binom dd=1=\binom DD$.
- **(Levels b)** Consequently $\binom D{r+2}\lambda_{r+1}\le\tau_r$ for odd $r$ ([Std] Lemma 2.6(b)).

### 1.3 The sign-only posterior

**Definitions.**

- $G\sim N(0,K)$ on $\mathcal X$.
- For a training sequence $S=(X_1,\dots,X_n)\in\mathcal X^n$ (repeats allowed): $\mathcal A_S=\{f(X_i)G(X_i)>0\ \forall i\}$. It has positive probability, because $K\succ0$ and $\mathcal A_S$ is a nonempty open cone in the coordinates indexed by $S$.
- $q_S(x)=\Pr\{f(x)G(x)>0\mid\mathcal A_S\}$ and $m(x)=\mathbb E[G(x)\mid\mathcal A_S]$.
- $s$ is the number of distinct training points, and $S'=(x'_1,\dots,x'_s)$ lists them.
- $\sigma_x^2=\operatorname{Var}(G(x)\mid G(x'_1),\dots,G(x'_s))$. This is deterministic, by Gaussian conditioning.
- $\lVert g\rVert_K^2=g^{\mathsf T}K^{-1}g=\sum_U\hat g(U)^2/\lambda_{\lvert U\rvert}$.
- $F_\theta(S)=\Pr_x\{q_S(x)\le\theta\}$.
- For $0\le v<d$, $Q_{v,SS}=(Q_v(X_i,X_j))_{i,j\le n}$ is the $n\times n$ sampled tail matrix, repeats included.

**(K5) Width limit** ([Std] Prop. 2.4(iii)). For each fixed $d$, $L$, gains and $S$, the finite-width sign-only network satisfies
$$\liminf_{N\to\infty}F_N(S)\ \ge\ \Pr_x\{q_S(x)<2/3\}\ \ge\ F_\theta(S),\qquad F_N(S)=\Pr_x\{q_{N,S}(x)\le2/3\}.$$
The limit $N\to\infty$ is taken at fixed $(d,L,\text{gains},S)$.

### 1.4 Coercivity ([SE] Lemma 4.4)

For a sample $S$ and an integer $r$, let $\mathrm{Coer}(r)$ be the event
$$\frac1n\sum_{i=1}^n\big(f(X_i)P(X_i)\big)_-^2\ \ge\ \frac14\lVert P\rVert_2^2\quad\text{for every }P:\mathcal X\to\mathbb R\text{ with }\deg P\le r .$$

**(K6)** [SE, Lemma 4.4] For each $\delta>0$ there is a universal constant $A_\delta$ (WLOG $A_\delta\ge1$) with the following property. If $r\le d/64$ and $n\ge A_\delta D_r\log(2D_r)$, and $X_1,\dots,X_n$ are iid uniform, then $\Pr\{\mathrm{Coer}(r)\}\ge1-\delta$.

**Provenance and status of (K6).** The following was read in `sampling.tex`. Under the shared theorem counter of [SE] §4, its items are Lemma 4.1, Remark 4.2, Lemma 4.3 and Lemma 4.4.

- [SE] proves (K6) from two ingredients. One is the population bound $\mathbb E(fP)_-^2\ge(\frac12-\sqrt{r/d})\lVert P\rVert_2^2$. The other is the uniform one-sided squared sampling estimate [SE] Lemma 4.3, applied to the isotropic feature vector of all characters of degree $\le r$, whose squared norm is exactly $D_r$.
- [SE] Lemma 4.3 applies [SE] Lemma 4.1, a bound on a squared Lipschitz process, twice: once with $\psi(t)=t_-$ and once with $\psi(t)=t$. It then solves a quadratic inequality.
- [SE] Lemma 4.1 does not apply a stated theorem of Lee (J. R. Lee, *Spectral hypergraph sparsification via chaining*, arXiv:2209.04539).
  - It uses an intermediate metric estimate from the proof of Lee's Lemma 2.12, eq. (2.20), with Lee's energy normalization (2.17) undone.
  - [SE] Remark 4.2 justifies this homogeneous form.
  - The proof of [SE] Lemma 4.1 adds a seminorm-approximation step.
- Lee's paper could not be read from this environment, so this last link is unverified here.
- **Everything that uses (K6) is therefore proved conditionally on [SE] Lemma 4.1**, that is, on the homogeneous form of Lee (2023), eq. (2.20), as derived in [SE] Remark 4.2. That covers Lemma 6.4, Regime II, and hence Theorem 6.1. Regime I (§6.3) does not use (K6), so it is unconditional.

We use (K6) as a black box and fix
$$\delta_1=\delta_2=\tfrac18,\qquad A:=A_{\delta_1}\ (\ge1).$$

**Remark 1.1 (the near-linear sample size in (K6) is essential).** The dependence on [SE] Lemma 4.1 cannot be bypassed by a cruder sampling argument.

- **What contraction gives.** On $\{\deg P\le r,\ \lVert P\rVert_2\le1\}$ one has $\lvert P\rvert\le\sqrt{D_r}$ pointwise, by Cauchy–Schwarz. So $t\mapsto(t_-)^2$ is $2\sqrt{D_r}$-Lipschitz on the relevant range. Symmetrization and the Ledoux–Talagrand contraction principle then bound the uniform deviation by $\lesssim D_r/\sqrt n$. This gives (K6) only for $n\gtrsim D_r^2$.
- **Effect on the amplitude.** With coercivity only at $n\gtrsim D_r^2$, the band term $n\lambda_{r+1}/\tau_r\approx n/\binom D{r+2}$ in the amplitude bound would be at least about $D_r^2/\binom D{r+2}\approx\binom dr(r/d)^2$. Then $\log\bar R\approx r\log(d/r)$, instead of $(1+o(1))\log d$.
- **Effect on the range.** Corollary 2.3 needs $J\ge\log\bar R$ and $J\rho_u\lesssim1$, which would force $r^2\log(d/r)\lesssim d$. The argument would then reach only $\log n\approx2\log D_r=O(\sqrt{d\log d})$. That is $o(\log n_0(d))$, because $\log n_0(d)\asymp\sqrt d\log d$, so it lies inside the every-training-set range of Lemma 6.2.

So without the $D_r\log(2D_r)$ sample size of (K6), Regime II would add nothing. This remark counts the method's own bounds. It is not a lower bound for the learner.

---

## 2. Parity against low-degree thresholds: ABFR and the restriction lemma

For $k\ge0$ and $j\ge0$ define
$$\beta(j,k)=\sup\big\{\Pr_y\{\chi_{[k]}(y)L(y)>0\}:\ L:\{-1,1\}^k\to\mathbb R,\ \deg L\le j\big\}=1-\mathrm{err}_j(\chi_{[k]}) .$$
So $\beta(j,k)=1$ if $j\ge k$, and in particular for $k=0$, where $\chi_\emptyset\equiv1$.

**Lemma 2.1 (Aspnes–Beigel–Furst–Rudich, *The expressive power of voting polynomials*, Combinatorica 14 (1994) 135–148).** For $k\ge1$ and $0\le j<k$,
$$\beta(j,k)\ \le\ 1-2^{-k}\sum_{i=0}^{\lfloor(k-j-1)/2\rfloor}\binom ki\ \le\ \frac12+\frac{j+1}{\sqrt{2\pi k}} .$$
Zeros of $\chi_{[k]}L$ count as errors, as in ABFR's counting bound and in $\mathrm{err}_j$. The proof below handles them, because the set $E$ contains the zeros.

*Proof.*

1. **Setup.** Let $\deg L\le j$, let $E=\{y:\chi_{[k]}(y)L(y)\le0\}$, and put $t=\lfloor(k-j-1)/2\rfloor$. Suppose $\lvert E\rvert<\sum_{i\le t}\binom ki$.
2. **A vanishing polynomial.** That sum is the dimension of the space of multilinear polynomials of degree at most $t$. Hence some nonzero $Q$ with $\deg Q\le t$ vanishes on $E$.
3. **Positivity.** $\chi_{[k]}LQ^2\ge0$ everywhere. It is $>0$ at any $y$ with $Q(y)\ne0$, and such a $y$ exists and lies outside $E$, because the characters form a basis of functions on the cube. So $\mathbb E[\chi_{[k]}LQ^2]>0$.
4. **Contradiction.** After multilinear reduction, $\deg(LQ^2)\le j+2t\le k-1$. So the top Fourier coefficient $\mathbb E[\chi_{[k]}LQ^2]$ vanishes, a contradiction.
5. **The first inequality.** Therefore $\Pr\{\chi_{[k]}L\le0\}\ge2^{-k}\sum_{i\le t}\binom ki$, which is the first inequality.
6. **The second inequality.** Let $B\sim\mathrm{Bin}(k,\frac12)$. By symmetry,
   $$1=2\Pr\{B\le t\}+\Pr\{t<B<k-t\}.$$
   The middle range contains $k-2t-1\le j+1$ integers. By (B5) each has probability at most $\sqrt{2/(\pi k)}$. Hence $1-\Pr\{B\le t\}\le\frac12+\frac{j+1}2\sqrt{2/(\pi k)}$. ∎

**Lemma 2.2 (restriction lemma).** For every $h:\mathcal X\to\mathbb R$, every $p\in(0,1]$, every integer $j\ge0$ and every $a>0$,
$$\Pr_x\{f(x)h(x)\ge a\}\ \le\ \mathbb E_{m\sim\mathrm{Bin}(d,p)}\,\beta(j,m)\ +\ \frac1{a^2}\sum_{U\subseteq[d]}\hat h(U)^2\,\Pr\{\mathrm{Bin}(\lvert U\rvert,p)>j\}. \tag{2.1}$$
No margin is required off the event $\{fh\ge a\}$, and the constant term $\hat h(\emptyset)$ carries weight $0$.

*Proof.*

1. **Random restriction.** Let $\mathcal J\subseteq[d]$ be random, containing each coordinate independently with probability $p$. Given $\mathcal J=J$, write $x=(y,z)$ with $y\in\{-1,1\}^J$ and $z\in\{-1,1\}^{[d]\setminus J}$. For each fixed $J$, the uniform measure on $\mathcal X$ is the product of the uniform measures on $y$ and $z$.
2. **Restricted function.** Put $h_{J,z}(y)=h(y,z)$. Then
   $$h_{J,z}=\sum_{T\subseteq J}\hat h_{J,z}(T)\chi_T,\qquad \hat h_{J,z}(T)=\sum_{U:\,U\cap J=T}\hat h(U)\,\chi_{U\setminus J}(z).$$
3. **Split.** Let $L_{J,z}=\sum_{\lvert T\rvert\le j}\hat h_{J,z}(T)\chi_T$ and $H_{J,z}=h_{J,z}-L_{J,z}$.
4. **Restricted parity.** $f(y,z)=\varepsilon_z\chi_J(y)$ with $\varepsilon_z=\chi_{[d]\setminus J}(z)\in\{\pm1\}$.
5. **Pointwise split.** At a point where $fh\ge a$ and $\lvert H_{J,z}\rvert<a$, we have $fL_{J,z}=fh-fH_{J,z}>a-a=0$. Hence
   $$\mathbf 1\{fh\ge a\}\le\mathbf 1\{\varepsilon_z\chi_JL_{J,z}>0\}+\mathbf 1\{\lvert H_{J,z}\rvert\ge a\}.$$
6. **Low-degree part.** $\varepsilon_zL_{J,z}$ has degree at most $j$ on the $\lvert J\rvert$-cube. So $\Pr_y\{\varepsilon_z\chi_JL_{J,z}>0\}\le\beta(j,\lvert J\rvert)$.
7. **High-degree part.** By Markov's inequality, $\Pr_y\{\lvert H_{J,z}\rvert\ge a\}\le a^{-2}\sum_{T\subseteq J,\lvert T\rvert>j}\hat h_{J,z}(T)^2$.
8. **Average over $z$.** Two distinct $U,U'$ with $U\cap J=U'\cap J$ have $U\setminus J\ne U'\setminus J$. So the characters $\chi_{U\setminus J}$ are orthonormal in $z$, and $\mathbb E_z\hat h_{J,z}(T)^2=\sum_{U\cap J=T}\hat h(U)^2$. Hence
   $$\mathbb E_z\Pr_y\{\lvert H_{J,z}\rvert\ge a\}\le a^{-2}\sum_U\hat h(U)^2\mathbf 1\{\lvert U\cap J\rvert>j\}.$$
9. **Average over $J$.** $\Pr_x\{fh\ge a\}=\mathbb E_{\mathcal J}\mathbb E_z\Pr_y\{fh\ge a\}$. Moreover $\lvert\mathcal J\rvert\sim\mathrm{Bin}(d,p)$ and $\lvert U\cap\mathcal J\rvert\sim\mathrm{Bin}(\lvert U\rvert,p)$. ∎

**Corollary 2.3 (explicit form).** Let $1\le u\le d$, let $\deg h\le u$, let $a>0$, and put $\rho=u/d$ and $R=a^{-2}\sum_{U\ne\emptyset}\hat h(U)^2$. For every integer $J$ with $1\le J\le e^2u$,
$$\Pr_x\{fh\ge a\}\ \le\ \frac12+e\sqrt{\frac{J\rho}{\pi}}+\frac12\exp\Big(-\frac{J}{8e^2\rho}\Big)+R\,e^{-J}. \tag{2.2}$$
In particular, let $\eta\in(0,1]$ and suppose $1+\log_+(R/\eta)\le e^2u$. Then
$$\Pr_x\{fh\ge a\}\le\frac12+\eta+e\sqrt{\frac{\rho\,(1+\log_+(R/\eta))}{\pi}}+\frac12e^{-1/(8e^2\rho)},$$
with $e/\sqrt\pi=1.5336\ldots$.

*Proof.*

1. **Parameters.** Take $j=J-1$ and $p=J/(e^2u)\in(0,1]$ in (2.1). Then $dp=J/(e^2\rho)$.
2. **The $\beta$ term.** Use $\beta(j,m)\le\frac12+\frac J{\sqrt{2\pi m}}$ for $m\ge1$ (Lemma 2.1, and trivially for $j\ge m$), and $\beta\le1$ always. This gives
   $$\mathbb E\beta(j,m)\le\tfrac12+J\,\mathbb E[(2\pi m)^{-1/2};m\ge dp/2]+\tfrac12\Pr\{m<dp/2\}\le\tfrac12+\frac J{\sqrt{\pi dp}}+\tfrac12e^{-dp/8},$$
   by the Chernoff lower tail $\Pr\{m\le\mu/2\}\le e^{-\mu/8}$. Here $J/\sqrt{\pi dp}=e\sqrt{J\rho/\pi}$.
3. **The tail term.**
   - $\hat h(U)=0$ for $\lvert U\rvert>u$, and the weight vanishes for $U=\emptyset$.
   - For $1\le\lvert U\rvert\le u$: $\Pr\{\mathrm{Bin}(\lvert U\rvert,p)\ge J\}\le\Pr\{\mathrm{Bin}(u,p)\ge J\}\le\binom uJp^J\le(eup/J)^J=e^{-J}$. The union bound is over $J$-subsets, and the inequality holds trivially if $J>u$.
4. **The special case.** Take $J=\max\{1,\lceil\log(R/\eta)\rceil\}\le1+\log_+(R/\eta)$, so that $Re^{-J}\le\eta$. Also use $J\ge1$ in the exponential. ∎

*Remarks.*

- (i) Clipped parity ([SE] Lemma 6.1) bounds the agreement by $\frac12+\frac{\rho}{2}\sqrt{R'}$, with $R'=\lVert h\rVert_2^2/a^2$. That is linear in the amplitude. Corollary 2.3 is logarithmic in it.
- (ii) With $p=1$ and $\deg h\le j$, Lemma 2.2 reduces to ABFR on the whole cube. Exact computations at $d\le12$ found no violation, and equality only in ABFR-extremal symmetric cases at $p=1$ (§8.3).

---

## 3. Two-step regularity

**Lemma 3.1 (first layer).** Let $\sigma>0$, $a=\pi/(2\sigma)$ and $\upsilon_m=\frac12(\sqrt{a^2+4m}-a)$. For every odd $m\ge1$,
$$\frac{\upsilon_m^4}{(m+1)(m+2)}\ \le\ \frac{c_{m+2}(\sigma^2)}{c_m(\sigma^2)}\ \le\ \frac{m^2}{(m+1)(m+2)},
\qquad\text{and}\qquad \frac{\upsilon_m^4}{(m+1)(m+2)}\ge\gamma(\sigma):=\frac1{6(1+\frac\pi{2\sigma})^4}.$$

*Proof.*

1. **Ratio formula.** By (K1),
   $$\frac{c_{m+2}}{c_m}=\frac{\sigma^4}{(m+1)(m+2)}\Big(\frac{I_{m+2}}{I_m}\Big)^2=\frac{\sigma^4(\mathbb E_\mu\omega^2)^2}{(m+1)(m+2)},$$
   where $\mu=\mu_m$ has density $Z^{-1}e^{-V(\omega)}$ on $(0,\infty)$ and $V(\omega)=-m\log\omega+\frac{\sigma^2\omega^2}2+\log\sinh\frac{\pi\omega}2$.
2. **Integration by parts.** $\omega V'(\omega)=-m+\sigma^2\omega^2+\frac{\pi\omega}2\coth\frac{\pi\omega}2$, which is bounded near $0$.
   - $e^{-V}\sim\frac2\pi\omega^{m-1}$ at $0$, so $\omega e^{-V}\to0$ at $0$.
   - There is Gaussian decay at $\infty$.
   - Hence $\mathbb E_\mu[\omega V'(\omega)]=-Z^{-1}\int_0^\infty\omega\,(e^{-V})'\,d\omega=1$, that is,
     $$\sigma^2\mathbb E_\mu\omega^2=m+1-\mathbb E_\mu\Big[\tfrac{\pi\omega}2\coth\tfrac{\pi\omega}2\Big].\tag{3.1}$$
3. **Upper bound.** $1\le y\coth y$ gives $\sigma^2\mathbb E\omega^2\le m$.
4. **Lower bound.** $y\coth y=y+\frac{2y}{e^{2y}-1}\le1+y$ and Jensen give $\sigma^2\mathbb E\omega^2\ge m-\frac\pi2\sqrt{\mathbb E\omega^2}$. With $Y=\sigma\sqrt{\mathbb E\omega^2}$ this reads $Y^2+aY-m\ge0$. Hence
   $$Y\ge \upsilon_m=\frac{2m}{a+\sqrt{a^2+4m}}\ge\frac m{a+\sqrt m},$$
   and $c_{m+2}/c_m=Y^4/((m+1)(m+2))\ge \upsilon_m^4/((m+1)(m+2))$.
5. **The constant.** For $m\ge1$: $a+\sqrt m\le(1+a)\sqrt m$ and $(m+1)(m+2)\le6m^2$. So
   $$\frac{\upsilon_m^4}{(m+1)(m+2)}\ge\frac{m^4}{(1+a)^4m^2\cdot6m^2}=\gamma(\sigma).\ ∎$$

Numerically, the minimal ratio over odd $m\le4001$ is attained at $m=1$. It equals $0.0034,\ 0.0152,\ 0.0601,\ 0.1181,\ 0.1410$ for $\sigma=0.3,0.5,1,2,3$, against $\gamma(\sigma)=1.1\cdot10^{-4},\ 5.7\cdot10^{-4},\ 3.8\cdot10^{-3},\ 1.6\cdot10^{-2},\ 3.1\cdot10^{-2}$. The sharper bound $\upsilon_m^4/((m+1)(m+2))$ also held at every $m$ (§8.3).

**Lemma 3.2 (composites; random-sum argument).** Let $H(t)=\sum_{m\ge1}h_mt^m$ and $G(t)=\sum_{k\ge0}g_kt^k$ have nonnegative coefficients. Suppose $h_{m+2}\ge\gamma h_m$ for all $m\ge1$. Then $[t^{m+2}]\,(G\circ H)\ge\gamma\,[t^m]\,(G\circ H)$ for all $m\ge1$.

In particular, the composite $\tanh$ coefficients satisfy, with $\gamma=\gamma(\sigma_1)$ and $c_1=\prod_\ell c_1(q_\ell)>0$:
$$c_{m+2}\ge\gamma\,c_m\quad(m\ \text{odd}),\qquad c_m\ge\gamma^{(m-1)/2}c_1\quad(m\ \text{odd}). \tag{3.2}$$

*Proof.*

1. **One power.** $[t^m]H^k=\sum h_{j_1}\cdots h_{j_k}$ over compositions $j_1+\dots+j_k=m$ with $j_i\ge1$. The map $(j_1,\dots,j_k)\mapsto(j_1+2,j_2,\dots,j_k)$ injects compositions of $m$ into compositions of $m+2$, and $h_{j_1+2}\ge\gamma h_{j_1}$. So $[t^{m+2}]H^k\ge\gamma[t^m]H^k$ for $k\ge1$.
2. **The $k=0$ term.** It contributes only at degree $0$.
3. **Sum over $k$.** Multiply by $g_k\ge0$ and sum.
4. **Probabilistic reading.** If $(g_k)$ and $(h_m)$ are probability laws, then $[t^m]\,(G\circ H)=\Pr\{\iota_1+\dots+\iota_Y=m\}$, with $Y\sim g$ and $\iota_i$ iid $\sim h$. Forcing $\iota_1\ge3$ and shifting it by 2 gives the same inequality.
5. **Application to $\tanh$.** Take $H=\hat\phi_{q_1}$. The hypothesis holds for odd $m$ by Lemma 3.1, and trivially for even $m$. Take $G=\hat\phi_{q_{L-1}}\circ\dots\circ\hat\phi_{q_2}$ (the identity if $L=2$).
6. **The second bound.** Iterate from $c_1$. ∎

**Lemma 3.3 (cube transfer).** Assume $c_{m+2}\ge\gamma c_m$ for all odd $m\ge1$.

- (a) For odd $j$ with $j+2\le D$: $W_{j+2}\ge\gamma\,\frac{(D-j)(D-j-1)}{D^2}\,W_j$.
- (b) For odd $r$ with $r+3\le D/2$: $\tau_r\le(1+4/\gamma)\,\tau_{r+2}$.
- (c) For odd $r$ and an integer $k\ge0$ with $r+2k+1\le D/2$: $\tau_r\le(1+4/\gamma)^k\,\tau_{r+2k}$.

*Proof.*

- **(a)** By the Markov property, $\Pr\{\zeta_{m+2}=j+2\}\ge\Pr\{\zeta_m=j\}\frac{D-j}D\frac{D-j-1}D$. Hence
  $$W_{j+2}\ge\sum_{m\ \rm odd}c_{m+2}\Pr\{\zeta_{m+2}=j+2\}\ge\gamma\frac{(D-j)(D-j-1)}{D^2}\sum_{m}c_m\Pr\{\zeta_m=j\}.$$
- **(b)** By (1.1), $\tau_r=AW_{r+2}+\tau_{r+2}$ and $\tau_{r+2}\ge AW_{r+4}$. By (a), $W_{r+4}\ge\gamma\frac{(D-r-2)(D-r-3)}{D^2}W_{r+2}\ge\frac\gamma4W_{r+2}$, since $D-r-3\ge D/2$. So $AW_{r+2}\le\frac4\gamma\tau_{r+2}$.
- **(c)** Apply (b) at $r,r+2,\dots,r+2k-2$. The last application needs $r+2k+1\le D/2$. ∎

The level masses were checked numerically for $D\in\{41,101,201,301\}$, with no violation of (a), (b) or (3.2).

- **(a) and (3.2).** In every configuration below, the ratio $W_{j+2}/[\gamma\frac{(D-j)(D-j-1)}{D^2}W_j]$ is at least $2.02$, and $c_{m+2}/(\gamma c_m)$ is at least $1.997$. Both minima occur at $\sigma_1=8$, the second at $m=1$.
- **(b).** The worst ratio $\tau_r/\tau_{r+2}$ (odd $r$, $r+3\le D/2$) depends strongly on the gains, and is always far below the bound $1+4/\gamma$. In each case it is largest at the smallest $D$.

| configuration | worst $\tau_r/\tau_{r+2}$, $D=41$ to $301$ | $1+4/\gamma(\sigma_1)$ |
|---|---|---|
| $L=2$, $\sigma_1=0.2$ | 273–319 | $1.47\cdot10^5$ |
| $L=2$, $\sigma_1=0.5$ | 18.5–21.3 | 7062 |
| $L=2$, $\sigma_1=1$ | 5.2–5.8 | 1049 |
| $L=2$, $\sigma_1=3$ | 2.07–2.34 | 130 |
| $L=2$, $\sigma_1=8$ | 1.61–1.76 | 50 |
| $L=3$, gains $(1,1)$ | 4.7–5.2 | 1049 |
| $L=3$, gains $(1,3)$ | 2.4–2.8 | 1049 |
| $L=3$, gains $(0.3,3)$ | 6.8–7.7 | $3.6\cdot10^4$ |

Details are in §8.3.

---

## 4. The tail Gram matrix: an intrinsic-dimension Chernoff bound

For a positive semidefinite $N\times N$ matrix $M\ne0$, the **intrinsic dimension** is $\operatorname{intdim}(M)=\operatorname{tr}M/\lambda_{\max}(M)\in[1,N]$.

**Remark 4.1 (context only; not used in any proof).** The exploration cited J. A. Tropp, *An Introduction to Matrix Concentration Inequalities*, Found. Trends Mach. Learn. 8 (2015), Thm 7.2.1. As recalled, it reads as follows.

- **Hypotheses.** Let $\{X_k\}$ be a finite sequence of independent random Hermitian matrices of the same size, with $0\le\lambda_{\min}(X_k)$ and $\lambda_{\max}(X_k)\le L$ for each $k$. Let $Y=\sum_kX_k$ and $M\succeq\mathbb EY$. Put $d_M=\operatorname{intdim}(M)$ and $\mu_{\max}=\lambda_{\max}(M)$.
- **Expectation bound.** For every $\theta>0$,
  $$\mathbb E\lambda_{\max}(Y)\le\frac{e^\theta-1}\theta\,\mu_{\max}+\frac1\theta\,L\log(2d_M).$$
- **Tail bound.** $\Pr\{\lambda_{\max}(Y)\ge(1+\varepsilon)\mu_{\max}\}\le2d_M\big[e^\varepsilon/(1+\varepsilon)^{1+\varepsilon}\big]^{\mu_{\max}/L}$ for $\varepsilon\ge L/\mu_{\max}$.

*Access note.* The monograph could not be retrieved from this environment, because arxiv.org and the caltech.edu sites are blocked. The statement and the theorem number above are from memory. Two referees' independent recollections agree with them, but none of these has been checked against the text. No proof below uses this remark. Proposition 4.2 proves the expectation bound we need, with $\log d_M$ in place of $\log(2d_M)$, which is a stronger statement.

**Proposition 4.2.** Let $X_1,\dots,X_n$ be independent random real-symmetric (or Hermitian) $N\times N$ matrices with $0\preceq X_k\preceq L\,I$ almost surely, where $L>0$. Let $Y=\sum_kX_k$, and let $M\succeq\mathbb EY$ be positive semidefinite and nonzero. Then for every $\theta>0$,
$$\mathbb E\lambda_{\max}(Y)\ \le\ \frac{e^\theta-1}\theta\,\lambda_{\max}(M)+\frac L\theta\log\operatorname{intdim}(M).$$

*Proof.*

1. **Tools.**
   - *Transfer rule:* if $\varphi\le\psi$ on the spectrum of $B$, then $\varphi(B)\preceq\psi(B)$.
   - $\log$ is operator monotone on positive definite matrices.
   - $B\preceq B'$ implies $\operatorname{tr}\varphi(B)\le\operatorname{tr}\varphi(B')$ for nondecreasing $\varphi$ (Weyl).
   - *Lieb's theorem* (E. H. Lieb, Adv. Math. 11 (1973) 267–288, Thm 6): for fixed Hermitian $H$, the map $B\mapsto\operatorname{tr}\exp(H+\log B)$ is concave on the positive definite cone. With Jensen applied conditionally, term by term, it yields *subadditivity of matrix cgfs*:
     $$\mathbb E\operatorname{tr}\exp\Big(\sum_k\vartheta X_k\Big)\le\operatorname{tr}\exp\Big(\sum_k\log\mathbb Ee^{\vartheta X_k}\Big).$$
     - *Derivation.* Condition on $X_1,\dots,X_{n-1}$. Write $e^{\vartheta X_n}=\exp(\log e^{\vartheta X_n})$, and apply concavity and Jensen to the last summand. This replaces $\vartheta X_n$ by $\log\mathbb Ee^{\vartheta X_n}$. Iterate over $X_{n-1},\dots,X_1$.
     - *References.* The subadditivity lemma appears as Lemma 3.4 of J. A. Tropp, *User-friendly tail bounds for sums of random matrices*, Found. Comput. Math. 12 (2012) 389–434, and as Lemma 3.5.1 of Tropp (2015), which states Lieb's theorem as its Thm 3.4.1. All of these theorem numbers, and Lieb's Thm 6, are recalled and were not checked against the texts. Only the statements are used, and they are standard.
2. **The mgf bound.** Fix $\vartheta>0$ and $g=(e^{\vartheta L}-1)/L$.
   - Convexity gives $e^{\vartheta x}\le1+gx$ on $[0,L]$, so $e^{\vartheta X_k}\preceq I+gX_k$ and $\mathbb Ee^{\vartheta X_k}\preceq I+g\,\mathbb EX_k$.
   - Hence $\log\mathbb Ee^{\vartheta X_k}\preceq\log(I+g\mathbb EX_k)\preceq g\,\mathbb EX_k$.
   - Therefore $\mathbb E\operatorname{tr}e^{\vartheta Y}\le\operatorname{tr}e^{g\,\mathbb EY}\le\operatorname{tr}e^{gM}$.
3. **Reduction to a trace.** $Y\succeq0$, so $e^{\vartheta Y}-I\succeq0$ and $e^{\vartheta\lambda_{\max}(Y)}-1=\lambda_{\max}(e^{\vartheta Y}-I)\le\operatorname{tr}(e^{\vartheta Y}-I)$. With Jensen,
   $$e^{\vartheta\mathbb E\lambda_{\max}(Y)}-1\le\mathbb E\operatorname{tr}(e^{\vartheta Y}-I)\le\operatorname{tr}(e^{gM}-I).$$
4. **Intrinsic dimension.** Put $\mu_{\max}=\lambda_{\max}(M)$. The function $\varphi_g(x)=e^{gx}-1$ is convex with $\varphi_g(0)=0$. So $\varphi_g(\mu_i)\le\frac{\mu_i}{\mu_{\max}}\varphi_g(\mu_{\max})$ for each eigenvalue $\mu_i\in[0,\mu_{\max}]$ of $M$. Summing, $\operatorname{tr}(e^{gM}-I)=\operatorname{tr}\varphi_g(M)\le\operatorname{intdim}(M)\,\varphi_g(\mu_{\max})$.
5. **Conclusion.** Since $\operatorname{intdim}(M)\ge1$, we have $1+\operatorname{intdim}(M)(e^{g\mu_{\max}}-1)\le\operatorname{intdim}(M)e^{g\mu_{\max}}$. Hence $\vartheta\,\mathbb E\lambda_{\max}(Y)\le g\mu_{\max}+\log\operatorname{intdim}(M)$. Put $\vartheta=\theta/L$. ∎

**Lemma 4.3 (tail Gram matrix).** Let $0\le r<d$ and $n\ge1$, and let $X_1,\dots,X_n$ be iid uniform on $\mathcal X$ (repeats allowed). Let $Q_{r,SS}=(Q_r(X_i,X_j))_{i,j\le n}$. Then
$$\mathbb E\lVert Q_{r,SS}\rVert_{\rm op}\ \le\ (e-1)\,n\lambda_{r+1}+\tau_r\log\frac{\tau_r}{\lambda_{r+1}}\ \le\ (e-1)\,n\lambda_{r+1}+\tau_r\log\frac{2\tau_r}{\lambda_{r+1}} .$$
This holds for every kernel of the form (K2) with nonincreasing $\lambda_q>0$.

*Proof.*

1. **Feature map.** Let $N=\#\{U:\lvert U\rvert>r\}$ and $\psi(x)=(\sqrt{\lambda_{\lvert U\rvert}}\chi_U(x))_{\lvert U\rvert>r}\in\mathbb R^N$. Let $\Psi\in\mathbb R^{n\times N}$ have rows $\psi(X_i)^{\mathsf T}$.
2. **Gram identity.** $(\Psi\Psi^{\mathsf T})_{ij}=\langle\psi(X_i),\psi(X_j)\rangle=Q_r(X_i,X_j)$. So $\lVert Q_{r,SS}\rVert=\lambda_{\max}(\Psi\Psi^{\mathsf T})=\lambda_{\max}(\Psi^{\mathsf T}\Psi)=\lambda_{\max}(Y)$, where $Y=\sum_iZ_i$ and $Z_i=\psi(X_i)\psi(X_i)^{\mathsf T}$.
3. **Hypotheses of Prop. 4.2.** The matrices $Z_i$ are iid and $\succeq0$, with $\lambda_{\max}(Z_i)=\lVert\psi(X_i)\rVert^2=\sum_{\lvert U\rvert>r}\lambda_{\lvert U\rvert}=\tau_r=:L$.
4. **Mean.** $\mathbb E\chi_U\chi_V=\mathbf 1_{U=V}$, so $\mathbb EY=n\Lambda$ with $\Lambda=\operatorname{diag}(\lambda_{\lvert U\rvert})$. Take $M=n\Lambda$: $\lambda_{\max}(M)=n\lambda_{r+1}$ by monotonicity, $\operatorname{tr}M=n\tau_r$, and $\operatorname{intdim}(M)=\tau_r/\lambda_{r+1}$.
5. **Conclusion.** Apply Proposition 4.2 with $\theta=1$. ∎

No far-pair, near-pair or collision analysis is involved. Monte Carlo at $d=10,12$ ($r=1,3,5$; $n=50$ to $4000$) agrees with the bound (§8.3).

**Lemma 4.4 (intrinsic dimension of the $\tanh$ tail).** For odd $r$ with $r+2\le D$,
$$\binom D{r+2}\ \le\ \frac{\tau_r}{\lambda_{r+1}}=\binom D{r+2}\frac{T_r}{W_{r+2}}\ \le\ \frac{D^{r+2}}{(r+2)!\,c_{r+2}} .$$
Hence
$$\log\frac{\tau_r}{\lambda_{r+1}}\le(r+2)\log\frac{eD}{r+2}+\log\frac1{c_{r+2}},\qquad
\log\frac1{c_{r+2}}\le\min\Big\{\frac{r+1}2\log\frac1\gamma+\log\frac1{c_1},\ C_\phi\sqrt{r+2}+\log\frac1\kappa\Big\},$$
with $\gamma=\gamma(\sigma_1)$, and $\kappa$, $C_\phi=\sqrt2(\pi/\sigma_1+1)$ as in [Std] Cor. 4.2.

*Proof.*

1. **Identity.** By (1.1), $\tau_r/\lambda_{r+1}=\binom D{r+2}T_r/W_{r+2}$.
2. **Range of $T_r$.** $W_{r+2}\le T_r\le\sum_jW_j=1$.
3. **Lower bound on $W_{r+2}$.** The walk can move outward $r+2$ times in a row, so
   $$W_{r+2}\ge c_{r+2}\Pr\{\zeta_{r+2}=r+2\}=c_{r+2}\prod_{i=0}^{r+1}\frac{D-i}D=c_{r+2}\frac{(r+2)!\binom D{r+2}}{D^{r+2}}.$$
4. **Bounds on $c_{r+2}$.** Use (B1) for the factorial. Then use (3.2), or [Std] Cor. 4.2, which gives $c_m\ge\kappa e^{-C_\phi\sqrt m}$. ∎

*Answer to the task's question.* Put $H_r=\log(eD/r)\ge1$ and let $r\ge1$. Since $(r+2)\log\frac{eD}{r+2}\le3rH_r$, Lemma 4.4 gives two bounds:
$$\log\frac{\tau_r}{\lambda_{r+1}}\le\Big(3+\log\frac1\gamma\Big)rH_r+\log\frac1{c_1}\quad\text{(via $\gamma$)},\qquad
\log\frac{\tau_r}{\lambda_{r+1}}\le3rH_r+C_\phi\sqrt{D}+\log\frac1\kappa\quad\text{(via [Std] Cor. 4.2)}.$$
So the form "$CrH_r+C\sqrt d$" is true, and the first bound shows that the $\sqrt d$ term is superfluous: $\log(\tau_r/\lambda_{r+1})\le C_{\gamma,c_1}\,rH_r$. The leading term $\log\binom D{r+2}$ is sharp, by the lower bound $\tau_r/\lambda_{r+1}\ge\binom D{r+2}$.

---

## 5. Posterior mean and confidence

This section re-derives [SE] Lemma 10.1 = [Std] Lemma 3.1. Part (v) handles repeated training points.

**Lemma 5.1.** For every training sequence $S$ of length $n\ge1$ and every $0\le v<d$:

1. **(i)** $m=\sum_{k\le s}\alpha_kK(\cdot,x'_k)$ with $\alpha=K_{S'S'}^{-1}m_{S'}$, and $\lVert m\rVert_K^2=\alpha^{\mathsf T}K_{S'S'}\alpha\le s$. Also $f(X_i)m(X_i)>0$ for every $i$.
2. **(ii)** If $\sigma_x>0$ and $q_S(x)>\theta$, then $f(x)m(x)>c_\theta\sigma_x$.
3. **(iii)** $\Pr_x\{\sigma_x^2<\tau_v/2\}\le2s\lambda_{v+1}/\tau_v$.
4. **(iv)** $\lVert m_{>v}\rVert_2^2\le\lambda_{v+1}\lVert m\rVert_K^2\le s\lambda_{v+1}$.
5. **(v)** $\frac1n\sum_{i=1}^n m_{>v}(X_i)^2\le\frac sn\lVert Q_{v,SS}\rVert_{\rm op}$, where $Q_{v,SS}$ is the $n\times n$ matrix with repeats.
6. **(vi)** If $\mathrm{Coer}(v)$ holds, then $\lVert m_{\le v}\rVert_2^2\le4\frac sn\lVert Q_{v,SS}\rVert_{\rm op}\le4\lVert Q_{v,SS}\rVert_{\rm op}$.

*Proof.*

**(i)**

1. **Whitening.** $\xi=K_{S'S'}^{-1/2}G_{S'}\sim N(0,I_s)$, and $\mathcal A_S=\{\xi\in\mathcal C\}$ for an open cone $\mathcal C$.
2. **Radius is unaffected.** $\lVert\xi\rVert$ is independent of $\xi/\lVert\xi\rVert$, and the event depends only on the direction. So $\mathbb E[\lVert\xi\rVert^2\mid\mathcal A_S]=s$.
3. **Jensen.** $m_{S'}^{\mathsf T}K_{S'S'}^{-1}m_{S'}=\lVert\mathbb E[\xi\mid\mathcal A_S]\rVert^2\le s$.
4. **Regression.** $\mathcal A_S$ is $G_{S'}$-measurable, so $m(x)=\mathbb E[\mathbb E[G(x)\mid G_{S'}]\mid\mathcal A_S]=K_{xS'}K_{S'S'}^{-1}m_{S'}$.
5. **RKHS norm.** $\lVert m\rVert_K^2=\alpha^{\mathsf T}K_{S'\mathcal X}K^{-1}K_{\mathcal XS'}\alpha=\alpha^{\mathsf T}K_{S'S'}\alpha$. The Fourier form follows from $K=\sum_UM\lambda_{\lvert U\rvert}e_Ue_U^{\mathsf T}$ with $e_U=\chi_U/\sqrt M$.
6. **Signs at training points.** $f(X_i)G(X_i)>0$ on $\mathcal A_S$, and $\Pr(\mathcal A_S)>0$.

**(ii)**

1. **Log-concavity.** Let $Y=f(x)G(x)$ under the posterior. Since $\sigma_x>0$, $x\notin S'$ and $(G(x),G_{S'})$ has a nondegenerate Gaussian law. Given $\mathcal A_S$, its density is a Gaussian density times the indicator of a convex set, so it is log-concave.
   - By Prékopa's marginal theorem (Prékopa 1973), $Y$ has a log-concave density $p_Y$.
   - The same theorem shows that the cdf $H(y)=\int p_Y(s)\mathbf 1\{s\le y\}\,ds$ is log-concave. Apply it to the function $(s,y)\mapsto p_Y(s)\mathbf 1\{s\le y\}$ on $\mathbb R^2$, which is log-concave as a product of log-concave functions, the second being the indicator of a convex set.
2. **Mean versus median.** With $\mu=\mathbb EY=f(x)m(x)$, Jensen gives $\log H(\mu)\ge\mathbb E\log H(Y)=\mathbb E\log U=-1$, since $H(Y)$ is uniform. So $\Pr\{Y>\mu\}\le1-e^{-1}$.
3. **Density bound.** Given $G_{S'}$, $G(x)$ is normal with variance $\sigma_x^2$. So the law of $Y$ is a mixture of $N(\cdot,\sigma_x^2)$ laws, and its density is at most $(\sqrt{2\pi}\sigma_x)^{-1}$.
4. **Sign of $\mu$.** If $\mu\le0$, then $q_S(x)\le\Pr\{Y>\mu\}\le1-e^{-1}<\theta$.
5. **Conclusion.** So $\mu>0$ and $\theta<q_S(x)\le1-e^{-1}+\mu/(\sqrt{2\pi}\sigma_x)$, which is the claim.

**(iii)**

1. **Independent split.** $G=G_{\le v}+G_{>v}$ with independent parts. $G_{>v}$ has covariance $Q_v$.
2. **More conditioning lowers variance.** For Gaussians, conditioning on more coordinates lowers conditional variances. So
   $$\sigma_x^2\ge\operatorname{Var}(G(x)\mid G_{S'},G_{\le v})=\operatorname{Var}(G_{>v}(x)\mid G_{>v}(S'))=\tau_v-R(x,x),$$
   with $R=Q_{v,\mathcal XS'}Q_{v,S'S'}^{\dagger}Q_{v,S'\mathcal X}$.
3. **Trace bound.** $0\preceq R\preceq Q_v$ and $\operatorname{rank}R\le s$. So $\sum_xR(x,x)=\operatorname{tr}R\le s\lVert Q_v\rVert=sM\lambda_{v+1}$.
4. **Markov.** $\Pr_x\{R(x,x)>\tau_v/2\}\le2s\lambda_{v+1}/\tau_v$.

**(iv)** $\sum_{\lvert U\rvert>v}\hat m(U)^2\le\lambda_{v+1}\sum_{\lvert U\rvert>v}\hat m(U)^2/\lambda_{\lvert U\rvert}$, by monotonicity.

**(v)**

1. **Fourier projection.** By (i), $m_{>v}=\sum_k\alpha_kQ_v(\cdot,x'_k)$.
2. **Spread the weights over repeats.** Let $\nu_k$ be the multiplicity of $x'_k$ in $S$. Define $\beta\in\mathbb R^n$ by $\beta_i=\alpha_k/\nu_k$ when $X_i=x'_k$.
3. **Two identities.** $(Q_{v,SS}\beta)_i=m_{>v}(X_i)$, and $\beta^{\mathsf T}Q_{v,SS}\beta=\alpha^{\mathsf T}Q_{v,S'S'}\alpha\le\alpha^{\mathsf T}K_{S'S'}\alpha\le s$. The middle inequality holds because $K=K_{\le v}+Q_v$ with both terms $\succeq0$.
4. **Conclusion.** $\sum_im_{>v}(X_i)^2=\beta^{\mathsf T}Q_{v,SS}^2\beta\le\lVert Q_{v,SS}\rVert\,\beta^{\mathsf T}Q_{v,SS}\beta$.

**(vi)**

1. **Pointwise inequality.** Put $p=m_{\le v}$. At each $X_i$, $fm>0$ by (i). So $(fp)_-\le\lvert m-p\rvert=\lvert m_{>v}\rvert$: if $fp<0<fm$, then $\lvert m-p\rvert=fm-fp>-fp$.
2. **Conclusion.** $\mathrm{Coer}(v)$ and (v) give $\frac14\lVert p\rVert_2^2\le\frac1n\sum_i(f(X_i)p(X_i))_-^2\le\frac sn\lVert Q_{v,SS}\rVert$. ∎

---

## 6. Theorem S1

**Theorem 6.1 (S1).** Let $\phi=\tanh$, and fix $L\ge2$ and gains $\sigma_1,\dots,\sigma_L>0$. Put $c_*=10^{-3}$ and
$$n_{\max}(d)=\exp\Big(c_*\,\frac{d\log\log d}{\log d}\Big).$$
There is $d_0$, depending only on $c_*$, $\sigma_1$, $c_1=\prod_{\ell<L}c_1(q_\ell)$ and the universal constant $A=A_{1/8}$ of (K6), with the following property. Through $c_1$, $d_0$ depends on the depth and on the gains $\sigma_1,\dots,\sigma_{L-1}$; it does not depend on $\sigma_L$. It is not explicit, and under the bookkeeping of §6.2 it is astronomically large (Remark 7.2). For every $d\ge d_0$ and every integer $0\le n\le n_{\max}(d)$, if $X_1,\dots,X_n$ are iid uniform on $\{-1,1\}^d$ and $f=\chi_{[d]}$, then
$$\Pr_S\Big\{\Pr_x\{q_S(x)\le\tfrac{13}{20}\}\ge\tfrac38\Big\}\ \ge\ \tfrac34 .$$

- If $n\le n_0(d):=\binom d{\lfloor\sqrt d/5\rfloor}/(23C_0)$, with $C_0=2+2/c_\theta^2<998$, the inner inequality holds for every training sequence.
- On the same event, $\liminf_{N\to\infty}F_N(S)\ge3/8$ for the finite-width sign-only network. The limit is taken at fixed $(d,L,\text{gains},S)$.
- The overall scale $\sigma_L$ is irrelevant, because $q_S$ is invariant under scaling of $K$.
- **Status.** For $n>n_0(d)$, the proof uses (K6). So it is conditional on [SE] Lemma 4.1, that is, on the homogeneous form of Lee (2023), eq. (2.20), as derived in [SE] Remark 4.2 (§1.4). The case $n\le n_0(d)$ is unconditional.

Two auxiliary statements come first.

**Lemma 6.2 (every training set; [Std] Thm 3.2).** For every training sequence $S$ of length $n\ge0$ and every $0\le v<d$,
$$F_\theta(S)\ \ge\ \mathrm{err}_v(f)-C_0\frac{n\lambda_{v+1}}{\tau_v}\ \ge\ \mathrm{err}_v(f)-\frac{C_0\,n}{\binom d{v+1}},\qquad C_0=2+\frac2{c_\theta^2}.$$

*Proof.*

1. **Exceptional sets.** Let $p=m_{\le v}$, $E_1=\{\sigma_x^2<\tau_v/2\}$ and $E_2=\{\lvert m-p\rvert\ge c_\theta\sqrt{\tau_v/2}\}$.
2. **Their measure.** By Lemma 5.1(iii),(iv) and Markov's inequality, $\Pr(E_1)+\Pr(E_2)\le(2+2/c_\theta^2)n\lambda_{v+1}/\tau_v$.
3. **Confidence forces the right sign.** Off $E_1\cup E_2$, $q_S(x)>\theta$ implies $fm>c_\theta\sigma_x\ge c_\theta\sqrt{\tau_v/2}>\lvert m-p\rvert$, hence $fp>0$.
4. **Inclusion.** So $\{fp\le0\}\subseteq\{q_S\le\theta\}\cup E_1\cup E_2$, and $\Pr\{fp\le0\}\ge\mathrm{err}_v(f)$.
5. **The second inequality.** This is (Levels a).
6. **The case $n=0$.** Then $m=0$, $E_1=E_2=\emptyset$ and $q_S\equiv1/2$. ∎

**Proposition 6.3 (master inequality).** Let $K$ be any positive-definite kernel of the form (K2) with nonincreasing $\lambda_q$. Let $0\le r\le u<d$ with $u\ge1$, and let $1\le J\le e^2u$ be integers. Let $S$ have length $n\ge1$ and satisfy $\mathrm{Coer}(r)$. Then
$$F_\theta(S)\ \ge\ \frac12-e\sqrt{\frac{Ju}{\pi d}}-\frac12e^{-Jd/(8e^2u)}-\frac{8e^{-J}}{c_\theta^2\,\tau_u}\Big(4\lVert Q_{r,SS}\rVert_{\rm op}+n\lambda_{r+1}\Big)-\Big(2+\frac8{c_\theta^2}\Big)\frac{n\lambda_{u+1}}{\tau_u}.$$

*Proof.*

1. **Exceptional sets.** Let $h=m_{\le u}$ and $a=\frac{c_\theta}2\sqrt{\tau_u/2}$. Put $E_1=\{\sigma_x^2<\tau_u/2\}$ and $E_2=\{\lvert m-h\rvert\ge a\}$. By Lemma 5.1(iii),(iv) and Markov,
   $$\Pr(E_1)\le2n\lambda_{u+1}/\tau_u,\qquad\Pr(E_2)\le n\lambda_{u+1}/a^2=8n\lambda_{u+1}/(c_\theta^2\tau_u).$$
2. **Inclusion.** Off $E_1\cup E_2$: $q_S(x)>\theta$ implies $fm>c_\theta\sigma_x\ge2a$ (Lemma 5.1(ii)), hence $fh>a$. So
   $$\{q_S>\theta\}\subseteq\{fh\ge a\}\cup E_1\cup E_2.$$
3. **Amplitude.** $\deg h\le u$, and
   $$R:=a^{-2}\sum_{U\ne\emptyset}\hat h(U)^2\le a^{-2}\lVert h\rVert_2^2=a^{-2}\big(\lVert m_{\le r}\rVert_2^2+\lVert m_{(r,u]}\rVert_2^2\big)\le\frac8{c_\theta^2\tau_u}\big(4\lVert Q_{r,SS}\rVert+n\lambda_{r+1}\big),$$
   by Lemma 5.1(vi) and (iv) with $s\le n$.
4. **Conclusion.** Corollary 2.3 bounds $\Pr\{fh\ge a\}$. Finally $F_\theta(S)=1-\Pr\{q_S>\theta\}$. ∎

### 6.1 Constants

| Symbol | Value or definition |
|---|---|
| $\theta,\ c_\theta$ | $13/20$; $\sqrt{2\pi}(e^{-1}-0.35)=0.0448171\ldots$; $c_\theta^2=0.0020086\ldots$ |
| $C_0$ | $2+2/c_\theta^2=997.7\ldots$ |
| $\varepsilon$ | $\big(64(2+8/c_\theta^2)\big)^{-1}=3.92\ldots\cdot10^{-6}$ |
| $\delta_1,\delta_2,\ A$ | $\delta_1=\delta_2=1/8$, $A=A_{1/8}\ge1$ from (K6) |
| $\gamma$ | $\gamma(\sigma_1)$ from Lemma 3.1 |
| $c_1$ | $\prod_{\ell<L}c_1(q_\ell)>0$ |
| $\beta_A$ | $32\big((e-1)A+1\big)+A$ |
| $t,\ k_d$ | $t=\lfloor\sqrt d/5\rfloor$; $k_d=\lceil\log d\rceil$ |
| $c_*$ | $10^{-3}$ |

For odd $r$:
$$\Lambda_r=2\log4+2(r+2)\log\frac{ed}{r+2},\qquad
\Lambda'_r=(r+2)\log\frac{eD}{r+2}+\frac{r+1}2\log\frac1\gamma+\log\frac1{c_1},$$
$$B_r=32\big((e-1)A\Lambda_r+\Lambda'_r\big)+A\Lambda_r.$$

### 6.2 Large-$d$ conditions (definition of $d_0$)

Let $d_0\ge3000$ be such that the following hold for every $d\ge d_0$. Each left side is an explicit function of $d$ and the fixed constants, and has the indicated limit, so such a $d_0$ exists.

- **(L1)** $A(d+1)\log(2d+2)<n_0(d)$. Here $\log n_0(d)\ge\frac{\sqrt d}{10}\log d-\frac12\log d-\log(23C_0)$, as in [Std] Cor. 3.4.
- **(L2)** $\frac{4A}{125}\frac{\log d}d\le\frac1{23C_0}$.
- **(L3)** $c_*\frac d{\log d}+2\le\min\{\frac d{64},\frac{d+1}3\}$, and $\lceil c_*d/\log d\rceil\le d/e$.
- **(L4)** $2k_d\le0.1(t-2)$, so $k_d=O(\log d)$ against $t\asymp\sqrt d$.
- **(L5)** $1.1\big(c_*\frac d{\log d}+2\big)\le0.1d$.
- **(L6)** $1.25\big(\frac{c_*}{\log d}+\frac2d\big)\le\frac{1.3c_*}{\log d}$, and $\log\frac{\log d}{1.3c_*}\ge1$.
- **(L7)** $\Lambda_r\le d$ and $\Lambda'_r\le d$ for all odd $r<c_*d/\log d$. Both sides are monotone in $r$, and the left sides are $O(c_*d\log\log d/\log d)$.
- **(L8)** $A/\varepsilon\le d$.
- **(L9)** Define
  $$\mathsf J_d=\log d+1+\log\frac{256\beta_A}{c_\theta^2}+\log\Big(1+\frac4\gamma\Big)\Big(1+\frac{\log d+\log(A/\varepsilon)}{2\log\frac{\log d}{1.3c_*}}\Big),\qquad \mathsf r_d=1.1\Big(\frac{c_*}{\log d}+\frac2d\Big).$$
  Require $\mathsf J_d\le e^2(t-4)$, $\ \mathsf J_d\,\mathsf r_d\le\frac\pi{256e^2}=1.6608\ldots\cdot10^{-3}$, and $\mathsf r_d\le\frac1{8e^2\log32}$.
  - Limits: $\mathsf J_d=(1+o(1))\log d$ and $\mathsf r_d=(1+o(1))\,1.1c_*/\log d$. So $\mathsf J_d\mathsf r_d\to1.1\cdot10^{-3}<1.66\cdot10^{-3}$.
  - **The convergence is slow.** $\mathsf J_d=\log d+1+\log\frac{256\beta_A}{c_\theta^2}+\Theta_d$, with $\Theta_d$ as in Lemma 6.5. Exactly,
    $$\frac{\mathsf J_d}{\log d}-1=\frac{\log(1+\frac4\gamma)}{2\big(\log\log d+\log\frac1{1.3c_*}\big)}\Big(1+\frac{\log(A/\varepsilon)}{\log d}\Big)+\frac{1+\log\frac{256\beta_A}{c_\theta^2}+\log(1+\frac4\gamma)}{\log d}.$$
  - **What (L9) needs.** At $c_*=10^{-3}$, the product condition needs $\mathsf J_d/\log d\le\frac{\pi/(256e^2)}{1.1c_*(1+2\log d/(c_*d))}\approx1.510$, while $\log\frac1{1.3c_*}=6.65$ and $\log\frac{256\beta_A}{c_\theta^2}=16.2$ at $A=1$.
  - **Values** at $\sigma_1=1$, $A=1$ (`fix_S1/l_thresholds.py`):

    | $d$ | $10^9$ | $10^{20}$ | $10^{50}$ | $10^{100}$ |
    |---|---|---|---|---|
    | $\mathsf J_d/\log d$ | 2.74 | 1.95 | 1.55 | 1.41 |
    | $\mathsf J_d\mathsf r_d$ | $3.02\cdot10^{-3}$ | $2.14\cdot10^{-3}$ | $1.70\cdot10^{-3}$ | $1.55\cdot10^{-3}$ |

    The product condition first holds at $d\approx10^{58.2}$.
  - **This condition sets $d_0$.** (L1)–(L8) and the other two parts of (L9) all hold once $d\ge2.6\cdot10^7$, for every $A\in[1,100]$. See Remark 7.2.

### 6.3 Regime I: $0\le n\le n_0(d)$ (every training set)

1. **Parameters.** Take $v=t-1$ in Lemma 6.2. Since $d\ge25$, $t\ge1$.
2. **ABFR.** Lemma 2.1 with $k=d$, $j=t-1$ gives $\mathrm{err}_{t-1}(f)=1-\beta(t-1,d)\ge\frac12-\frac t{\sqrt{2\pi d}}\ge\frac12-\frac1{5\sqrt{2\pi}}=0.42021\ldots$.
3. **Sample term.** $C_0n/\binom dt\le1/23=0.04348$.
4. **Conclusion.** $F_\theta(S)\ge0.3767>3/8$ for every $S$.

### 6.4 Regime II: $n_0(d)<n\le n_{\max}(d)$

**Lemma 6.4 (adaptive cutoff).** Let $d\ge d_0$ and $n_0(d)<n\le n_{\max}(d)$.

- (a) Some odd $r\ge1$ has $AD_r\log(2D_r)\le n$. Let $r=r(n)$ be the largest such $r$.
- (b) $t-4\le r<c_*d/\log d$. In particular $r\le d/64$ and $r+2\le(d+1)/3$.
- (c) $n/\binom D{r+2}<A\Lambda_r$, and $n\lambda_{r+1}/\tau_r<A\Lambda_r$.
- (d) Put $\hat\rho=1.25(r+2)/d$ and $k^*=\big\lceil\log(A\Lambda_r/\varepsilon)/(2\log(1/\hat\rho))\big\rceil$. Then $0\le k^*\le k_d$, and $u:=r+2k^*$ satisfies:
  - $u+1\le D/2$;
  - $\rho_u:=u/d\le1.1(r+2)/d\le\mathsf r_d$;
  - $n\lambda_{u+1}/\tau_u\le n/\binom D{u+2}<\varepsilon$.

*Proof.*

**(a)** $D_1=d+1$, and $AD_1\log(2D_1)<n_0(d)<n$ by (L1).

**(b), upper bound.**

1. Suppose $r\ge r_1:=\lceil c_*d/\log d\rceil$. Since $A\ge1$ and $\log(2D_r)\ge1$, we get $n\ge D_r\ge\binom d{r_1}\ge(d/r_1)^{r_1}$.
2. $x\mapsto x\log(d/x)$ increases on $(0,d/e]$, and $c_*d/\log d\le r_1\le d/e$ by (L3). Hence
   $$\log n\ge\frac{c_*d}{\log d}\log\frac{\log d}{c_*}>\frac{c_*d\log\log d}{\log d}=\log n_{\max}(d),$$
   a contradiction.
3. The two consequences follow from (L3).

**(b), lower bound.**

1. Suppose $r+2\le t':=t-3$.
2. **Size of $D_{t'}$.** $t'\le(d+1)/3$, so (B2) gives $D_{t'}\le2\binom d{t'}$. Moreover
   $$\log(2D_{t'})\le\log4+t'\log(ed)\le\frac{\sqrt d}4\log d,$$
   for $d\ge3000$.
3. **Comparison with $\binom dt$.** $\binom d{t'}\le\binom dt\big(\frac t{d-t+1}\big)^3\le\binom dt\frac8{125d^{3/2}}$.
4. **Contradiction.** By maximality and (L2),
   $$n<AD_{r+2}\log(2D_{r+2})\le AD_{t'}\log(2D_{t'})\le\frac{4A}{125}\frac{\log d}d\binom dt\le n_0(d),$$
   contradicting $n>n_0(d)$. Hence $r\ge t-4$.

**(c)**

1. By maximality, $n<AD_{r+2}\log(2D_{r+2})$.
2. (B2) gives $D_{r+2}\le2\binom d{r+2}\le2\binom D{r+2}$, and (B1) gives $\log(2D_{r+2})\le\log4+(r+2)\log\frac{ed}{r+2}$.
3. The second claim is (Levels b).

**(d)**

1. **$k^*\le k_d$.** By (L6), $\hat\rho\le1.3c_*/\log d$ and $\log(1/\hat\rho)\ge1$. By (L7) and (L8), $\log(A\Lambda_r/\varepsilon)\le\log(Ad/\varepsilon)\le2\log d$. So $k^*\le\lceil\log d\rceil=k_d$.
2. **Range of $j$.** For odd $j\in[r+2,u]$:
   - by (L4) and $r\ge t-4$, $j+2\le r+2k_d+2\le1.1(r+2)$;
   - by (L5), $D-j-1\ge d-1.1(r+2)\ge0.9d$.
3. **Binomial growth.** So $(j+2)/(D-j-1)\le\frac{1.1}{0.9}\frac{r+2}d<\hat\rho$. By (B3), $\binom D{j+2}\ge\hat\rho^{-2}\binom Dj$. Iterating,
   $$\binom D{u+2}\ge\hat\rho^{-2k^*}\binom D{r+2}.$$
4. **Tail estimate.** With (c), $n/\binom D{u+2}<A\Lambda_r\hat\rho^{2k^*}\le\varepsilon$, by the choice of $k^*$. (Levels b) at $u$ gives the first inequality of the last bullet.
5. **The other two claims.** $u+1\le1.1(r+2)\le D/2$, and $\rho_u\le1.1(r+2)/d\le\mathsf r_d$ by (b). ∎

**Lemma 6.5 (regularity across the band; $\tau_r/\tau_u=d^{o(1)}$).** In the setting of Lemma 6.4, put $\rho=r/d$, and recall $\hat\rho=1.25(r+2)/d=1.25(\rho+2/d)$. Then
$$\log\frac{\tau_r}{\tau_u}\le k^*\log\Big(1+\frac4\gamma\Big)\le\log\Big(1+\frac4\gamma\Big)\Big(1+\frac{\log d+\log(A/\varepsilon)}{2\log(1/\hat\rho)}\Big)\le\Theta_d,$$
where
$$\Theta_d:=\log\Big(1+\frac4\gamma\Big)\Big(1+\frac{\log d+\log(A/\varepsilon)}{2\log\frac{\log d}{1.3c_*}}\Big).$$

- **(i) The constant.** As $d\to\infty$,
  $$\Theta_d=(1+o(1))\,\frac12\log\Big(1+\frac4\gamma\Big)\,\frac{\log d}{\log\log d},$$
  where the $o(1)$ depends on $c_*$, $A$ and $\sigma_1$. The convergence is slow, because the denominator is $2(\log\log d+\log\frac1{1.3c_*})$, and $\log\frac1{1.3c_*}=6.65$ at $c_*=10^{-3}$. For example, at $\sigma_1=1$, $A=1$ and $d=10^{58}$, $\Theta_d=51.0$, while the leading term is $94.9$.
- **(ii) In terms of $\rho$.** $\log(\tau_r/\tau_u)\le\log(1+\frac4\gamma)\big(1+\frac{\log d+\log(A/\varepsilon)}{\log(1/\rho)}\big)=O\big(\frac{\log d}{\log(1/\rho)}\big)$, and $\log(1/\rho)\ge\log\log d+\log(1/c_*)$.
- **(iii) Band width.** $u-r=2k^*\le2+\frac{\log d+\log(A/\varepsilon)}{\log(1/\hat\rho)}=O\big(\frac{\log d}{\log(1/\rho)}\big)$.

So $\tau_r/\tau_u\le e^{\Theta_d}=d^{(1+o(1))\log(1+4/\gamma)/(2\log\log d)}=d^{o(1)}$, uniformly over $n$ in Regime II. The proof below needs only $\tau_r/\tau_u\le d^{O(1)}$. The bound $\Theta_d$ is the last term of $\mathsf J_d$ in (L9).

*Proof.*

1. **Regularity.** Lemma 3.3(c) applies, since $u+1\le D/2$, with the $\gamma$ of (3.2).
2. **Bound on $k^*$.** By definition, $k^*\le1+\log(A\Lambda_r/\varepsilon)/(2\log(1/\hat\rho))$, and $\Lambda_r\le d$ by (L7). This gives the middle bound. Then $\hat\rho\le1.3c_*/\log d$ by (L6) gives $\Theta_d$.
3. **The constant.** Write
   $$\frac{\log d+\log(A/\varepsilon)}{2\log\frac{\log d}{1.3c_*}}=\frac{\log d}{2\log\log d}\cdot\frac{1+\log(A/\varepsilon)/\log d}{1+\log\frac1{1.3c_*}/\log\log d}.$$
   The last fraction tends to $1$, and the additive $\log(1+4/\gamma)$ is $o(\log d/\log\log d)$.
4. **In terms of $\rho$.** $r\ge t-4\ge2$, so $2/d\le\rho$ and $\hat\rho\le2.5\rho$. Since $\rho\le c_*/\log d\le1/6.25$, this gives $\log(1/\hat\rho)\ge\log\frac1{2.5\rho}\ge\frac12\log\frac1\rho$. Finally, $r<c_*d/\log d$ gives $\log(1/\rho)\ge\log\log d+\log(1/c_*)$. ∎

*Remark.* Lemma T (`deep-1.md`, Thm 4.5) would give the sharper $\tau_r/\tau_u\le\exp(2C_Tk^*/\sqrt r)=1+o(1)$. It is neither verified nor used here.

### 6.5 Proof of Theorem 6.1

**Regime I.** This is §6.3.

**Regime II: setup.** Let $d\ge d_0$ and $n_0(d)<n\le n_{\max}(d)$. Take $r,k^*,u$ from Lemma 6.4 and define the sample events
$$\mathsf E_{\rm coer}=\mathrm{Coer}(r),\qquad \mathsf E_{\rm gram}=\big\{\lVert Q_{r,SS}\rVert_{\rm op}\le8\,\mathbb E\lVert Q_{r,SS}\rVert_{\rm op}\big\}.$$

- $r\le d/64$ and $n\ge AD_r\log(2D_r)$, so (K6) gives $\Pr(\mathsf E_{\rm coer})\ge7/8$.
- Markov's inequality gives $\Pr(\mathsf E_{\rm gram})\ge7/8$.
- Hence $\Pr(\mathsf E_{\rm coer}\cap\mathsf E_{\rm gram})\ge3/4$.

Fix $S\in\mathsf E_{\rm coer}\cap\mathsf E_{\rm gram}$.

**Step 1 (head and band).** By Lemma 4.3, then Lemma 4.4 with (3.2) (that is, $\log(\tau_r/\lambda_{r+1})\le\Lambda'_r$), and Lemma 6.4(c):
$$4\lVert Q_{r,SS}\rVert+n\lambda_{r+1}\le32\Big[(e-1)n\lambda_{r+1}+\tau_r\log\frac{\tau_r}{\lambda_{r+1}}\Big]+n\lambda_{r+1}\le\tau_r\,B_r\le\beta_A\,d\,\tau_r,$$
using (L7) in the last step.

**Step 2 (amplitude).** By Lemma 6.5,
$$\frac{8}{c_\theta^2\tau_u}\big(4\lVert Q_{r,SS}\rVert+n\lambda_{r+1}\big)\le\bar R:=\frac{8B_r}{c_\theta^2}\Big(1+\frac4\gamma\Big)^{k^*}.$$
Set $J=\max\{1,\lceil\log(32\bar R)\rceil\}$. Then $\bar Re^{-J}\le1/32$, and by Steps 1 and 2 and Lemma 6.5, $J\le1+\log(32\bar R)\le\mathsf J_d$.

**Step 3 (admissibility of $J$).** By (L9) and Lemma 6.4(b), $J\le\mathsf J_d\le e^2(t-4)\le e^2r\le e^2u$.

**Step 4 (apply Proposition 6.3).**

- By (L9) and Lemma 6.4(d), $e\sqrt{Ju/(\pi d)}=e\sqrt{J\rho_u/\pi}\le e\sqrt{\mathsf J_d\mathsf r_d/\pi}\le\frac1{16}$.
- $\frac12e^{-Jd/(8e^2u)}\le\frac12e^{-1/(8e^2\mathsf r_d)}\le\frac1{64}$.
- The amplitude term is at most $\bar Re^{-J}\le\frac1{32}$.
- The last term is at most $(2+8/c_\theta^2)\varepsilon=\frac1{64}$.

Hence
$$F_\theta(S)\ \ge\ \frac12-\frac1{16}-\frac1{64}-\frac1{32}-\frac1{64}=\frac38 .$$

**Conclusion.** In both regimes $\Pr_S\{F_\theta(S)\ge3/8\}\ge3/4$, with probability $1$ in Regime I. The width-limit statement is (K5). ∎

### 6.6 Bookkeeping summary (where each budget goes)

| Item | Bound | Source |
|---|---|---|
| Sample failure: coercivity | $\le1/8$ | (K6) with $\delta_1=1/8$ |
| Sample failure: Gram Markov | $\le1/8$ | Lemma 4.3 and Markov, $\delta_2=1/8$ |
| Test-point exceptional sets $E_1\cup E_2$ | $\le(2+8/c_\theta^2)\,n\lambda_{u+1}/\tau_u\le(2+8/c_\theta^2)\varepsilon=1/64$ | Lemma 5.1(iii),(iv); Lemma 6.4(d) |
| ABFR main term | $\le e\sqrt{J\rho_u/\pi}\le1/16$ | Cor. 2.3; (L9) |
| Chernoff on $\lvert\mathcal J\rvert$ | $\le\frac12e^{-J/(8e^2\rho_u)}\le1/64$ | Cor. 2.3; (L9) |
| Amplitude (high restricted degree) | $\le\bar Re^{-J}\le1/32$ | Cor. 2.3; Steps 1–2 |
| Total above $1/2$ | $\le1/8$ | $\Rightarrow F_\theta\ge3/8$ |

Every $o(1)$ in the exploration's sketch corresponds to one of the explicit conditions (L1)–(L9).

---

## 7. Remarks

**7.1 (The constant $c$).** Conditions (L3)–(L7) hold for large $d$ for any fixed $c_*$. The only binding use of $c_*$ is (L9), through $\mathsf J_d\mathsf r_d\to1.1c_*$.

- The factor $1.1$ comes from the crude (L4)–(L5); in fact $(u+2)/(r+2)\to1$.
- The constants $\eta=1/32$, $\varepsilon$ and $1/64$ in the budget can be made arbitrarily small, at the cost of additive $O(1)$ terms in $J$ only.
- Hence the same proof gives Theorem 6.1 for every fixed $c_*<\pi/(64e^2)=6.64\ldots\cdot10^{-3}$, with $d_0$ depending also on $c_*$.
- The obstruction to larger $c$ is that $\log\bar R=(1+o(1))\log d$. This comes from $B_r\asymp A\,rH_r$, which is the logarithm in the coercivity threshold, through $n/\binom D{r+2}$ and $\log(\tau_r/\lambda_{r+1})$. Since $\log\bar R\approx\log d$, the corollary forces $\rho_u\lesssim c/\log d$.

**7.2 (When the theorem says something new, and how large $d_0$ is).** Theorem 6.1 improves on [Std] Cor. 3.4(a) only for $d\ge\max(d_0,d_\times)$, where $d_\times\approx2.58\cdot10^8$ is the crossover defined below. Of the two thresholds, $d_0$ is by far the larger.

- **The crossover $d_\times$ is necessary, not sufficient.**
  - An exact computation of $\log n_0(d)=\log\binom d{\lfloor\sqrt d/5\rfloor}-\log(23C_0)$ against $\log n_{\max}(d)$ places the point where $n_{\max}(d)$ first exceeds $n_0(d)$ at $d_\times\approx2.58\cdot10^8$.
  - The ratio $\log n_{\max}/\log n_0$ is $0.67$ at $d=10^8$, $1.78$ at $d=10^9$ and $4.82$ at $d=10^{10}$.
  - For $d<d_\times$, Regime II is empty, and the theorem is the every-training-set bound.
  - The theorem itself, however, is asserted only for $d\ge d_0$.
- **$d_0$ is not explicit, and is astronomically large.** It is not explicit because $A=A_{1/8}$ from (K6) is not. Even with the smallest value the proof allows, $A=1$, the conditions of §6.2 force $d_0$ to be enormous. The product condition $\mathsf J_d\mathsf r_d\le\pi/(256e^2)$ of (L9) alone first holds at the following dimensions (`fix_S1/l_thresholds.py`, which agrees with the referees' independent scripts):

  | $\sigma_1$ | 8 | 3 | 2 | 1 | 0.5 | 0.3 | 0.2 |
  |---|---|---|---|---|---|---|---|
  | $\log_{10}d$, $A=1$ | 30.7 | 37.1 | 42.3 | 58.2 | 94.3 | 157.1 | 273.5 |
  | $\log_{10}d$, $A=100$ | 36.9 | 44.3 | 50.2 | 68.2 | 108.7 | 177.8 | 302.9 |

  All other conditions of §6.2 hold once $d\ge2.6\cdot10^7$, for every $A\in[1,100]$.
- **Why $d_0$ is so large.** $\mathsf J_d/\log d$ converges to $1$ slowly (Lemma 6.5(i) and the last bullets of (L9)).
  - The term $\Theta_d$ is about $\frac12\log(1+4/\gamma)\log d/(\log\log d+6.65)$.
  - The additive constants contribute about $(17.2+\log(1+4/\gamma))/\log d$.
  - At $d=10^{58}$ ($\sigma_1=1$, $A=1$), $\mathsf J_d/\log d=1.511$, just above the allowed value $1.510$.
- **The large $d_0$ comes from the uniform bookkeeping, not from the argument.** For each $r$ that occurs as $r(n)$ in Regime II, the proof uses only the following inequalities:
  - $r\le d/64$ and $r+2\le(d+1)/3$;
  - $(u+2)/(D-u-1)\le\hat\rho$, which gives $n/\binom D{u+2}<\varepsilon$ by the chain in Lemma 6.4(d);
  - $u+1\le D/2$;
  - $J\le e^2u$, $e\sqrt{Ju/(\pi d)}\le\frac1{16}$, and $\frac12e^{-Jd/(8e^2u)}\le\frac1{64}$.

  Here $k^*$, $u$, $B_r$ and $J$ are the actual quantities of Lemma 6.4 and §6.5, not their uniform bounds (L4)–(L9).
  - **What was evaluated.** `fix_S1/direct_check.py` evaluates these inequalities in high-precision log space. It covers $L=2$ with $\sigma_1\in\{0.3,1,3\}$ and $A\in\{1,100\}$, at the 26 dimensions $d=10^{8.42},10^{8.5},10^9,10^{9.5},10^{10},10^{11},10^{12},10^{14},10^{16},10^{18},10^{20},10^{25},10^{30},\dots,10^{60},10^{70},10^{80},10^{100},10^{120},10^{140},10^{160},10^{180}$.
  - **Which $r$.** At each $d$ it checks every odd $r$ in the range of $r(n)$ over Regime II when that range has at most 4000 values. Otherwise it checks the two endpoints plus 600 log-spaced values. The binding quantity $Ju/d$ is nondecreasing in $r$, because $J$, $k^*$ and $u$ are. So its maximum is at the largest $r$, which is checked. The other inequalities hold at every $r$ with large margins.
  - **Result.** All inequalities hold at every point checked. The largest $Ju/d$ lies between $4.1\cdot10^{-4}$ and $6.6\cdot10^{-4}$, against the requirement $\pi/(256e^2)=1.66\cdot10^{-3}$. Also $k^*\le16$, and $\max J/(e^2u)\le2.3\cdot10^{-3}$.
  - **Where the slack is.** $\mathsf r_d$ overestimates $\rho_u$ by a factor of $2.7$ to $4.6$. The reason is that $r(n_{\max})\approx\kappa\,d/\log d$ with $\kappa=2.4\cdot10^{-4}$ to $4.1\cdot10^{-4}$ on this range, not $c_*=10^{-3}$. Matching $\log D_r\approx r\log(ed/r)$ with $\log n_{\max}$ gives $\kappa\approx c_*\log\log d/(\log\log d+\log(1/\kappa)+1)$, which reproduces the computed values. So $\kappa\to c_*$ only when $\log\log d\gg\log(1/c_*)$. In addition, the actual $J$ is below $\mathsf J_d$; for example $J\le43$ against $\mathsf J_d=56.8$ at $d=10^9$, $\sigma_1=1$, $A=1$.
  - **Consequence.** For $A=1$ or $A=100$ and these gains, the conclusion of Theorem 6.1 holds at each grid dimension $d\ge10^{8.42}$, and also, by §6.2, for every $d$ beyond the (L9) threshold in the table. This is a numerical observation at grid points, conditional on the unknown value of $A$ and on [SE] Lemma 4.1. It is not part of the theorem.
  - **Further improvement.** A sharper bound on $\tau_r/\tau_u$ would shrink $\Theta_d$, and with it the uniform $d_0$. An example is Lemma T of the exploration, which is not verified here.
- **Summary.** As with every result of this round, the theorem is purely asymptotic, and no explicit $d_0$ is claimed. A claim of new content from $d\approx2.6\cdot10^8$ on would need an explicit $A$ and a grid-free version of the direct check.

**7.3 (Other activations).** The proof uses $\tanh$ only through three properties:

1. oddness and [Std] Assumption 2.1, giving the pairing and the width limit;
2. two-step regularity of the first-layer coefficients, $c_{m+2}(q_1)\ge\gamma c_m(q_1)$ for odd $m$;
3. $c_1(q_\ell)>0$ for every layer.

Properties 2 and 3 give (3.2), hence $c_m>0$ for all odd $m$ and $K\succ0$. No lower bound on individual eigenvalues (unlike [Std] Lemma 4.3) and no far-pair estimate is used. So Theorem 6.1 holds verbatim, with the same $c_*$, for any activation with these three properties. Example: $\operatorname{erf}$.

- Its dual is $\hat\phi_q(\rho)=\arcsin(b\rho)/\arcsin b$ with $b=2q/(1+2q)$.
- Hence $c_{2k+3}/c_{2k+1}=b^2(2k+1)^2/((2k+2)(2k+3))\ge b^2/6$, so $\gamma=b^2/6$ with $b=2q_1/(1+2q_1)$.
- The margin learner for $\operatorname{erf}$ remains uncovered ([Std] Remark 5.6(3)).

**7.4 (What is not claimed).**

- No $\exp(\Omega(d))$ bound.
- Nothing about the margin learner (M). For (M) the head bound needs a conditioning-cost estimate, and the Gram matrix enters through the posterior, not through the posterior mean.
- No explicit $d_0$. The uniform $d_0$ of §6.2 is astronomically large (Remark 7.2).
- No unconditional statement for $n>n_0(d)$: Regime II rests on [SE] Lemma 4.1 (§1.4).
- Lemma T, Theorem A and Lemma C from the exploration are not used.

---

## 8. Verification log

### 8.1 Checks against the sources

- **[Std] Lemma 3.1 / [SE] Lemma 10.1.** Re-proved as Lemma 5.1. The only kernel inputs are independence of $G_{\le v}$ and $G_{>v}$, constant variance $\tau_v$, and $\max_{q>v}\lambda_q=\lambda_{v+1}$. All three hold by (K2)–(K3).
- **[Std] Thm 3.2.** Re-proved as Lemma 6.2. The threshold $n_0(d)=\binom dt/(23C_0)$ and the numbers $0.4202-1/23=0.3767$ were rechecked.
- **[SE] Lemma 4.4 (K6).** Statement checked: $r\le d/64$, $n\ge A_\delta D_r\log(2D_r)$, iid uniform inputs, probability $\ge1-\delta$ for each specified $n$, conclusion $\frac1n\sum(fP)_-^2\ge\frac14\lVert P\rVert^2$. Used as a black box.
  - Its proof chain was read in `sampling.tex`: Lemma 4.4 ← Lemma 4.3 (two applications of Lemma 4.1, then a quadratic inequality) ← Lemma 4.1 ← Lee (2023), Lemma 2.12, eq. (2.20), in the homogeneous form of Remark 4.2, plus a seminorm-approximation step.
  - The last link could not be checked, because Lee's paper is not accessible here. Theorem 6.1 is therefore stated as conditional on [SE] Lemma 4.1 (§1.4).
- **[SE] Thm 10.2 skeleton.** The arcsine-specific inputs, $\tau_u/\tau_r=1+o(1)$ and the sharp ratio, were replaced by Lemma 3.3 and Lemma 4.4. The far-pair/Tropp-2008 Gram bound was replaced by Lemma 4.3. Clipped parity was replaced by Corollary 2.3.
  - The lower limit $\exp((\log d)^3)$ of [SE] is not needed. The adaptive regime starts at $n_0(d)$, where $r\ge t-4$.
  - The lower bound on $r$ is used only to make $p=J/(e^2u)\le1$.

### 8.2 Comparison with the exploration's claims

| Exploration claim | Verdict |
|---|---|
| Restriction lemma (`explore2_margin-decide`), weighted form | **Confirmed** as stated, with $\beta(j,m)=1-\mathrm{err}_j(\chi_m)\le$ ABFR $\le\frac12+\frac{j+1}{\sqrt{2\pi m}}$. |
| Corollary "$\le\frac12+1.6\sqrt{\rho(1+\log(R/\sqrt\rho))}+\sqrt\rho+o(1)$" | **Confirmed**, in the explicit form (2.2): the constant is $e/\sqrt\pi=1.534$, and the $o(1)$ is exactly $\frac12e^{-J/(8e^2\rho)}$. It needs the hypothesis $J\le e^2u$ ($p\le1$), which the exploration left implicit. |
| $c_{m+2}\ge\gamma c_m$ for $\tanh$ with $g(m)=\upsilon_m^4/((m+1)(m+2))$ (`explore_mean-structure`) | **Confirmed.** Added: an explicit $\gamma(\sigma)=1/(6(1+\pi/(2\sigma))^4)$ and the upper bound $c_{m+2}/c_m\le m^2/((m+1)(m+2))$. |
| Regularity passes to composites (injection) | **Confirmed**, with $\gamma=\gamma(\sigma_1)$ at every depth. |
| $W_{j+2}\ge\gamma(1-\frac{j+1}D)^2W_j$; $\tau_r\le(1+4/\gamma)\tau_{r+2}$ for $r+4\le D/2$ | **Confirmed.** Proved for $r+3\le D/2$, with the sharper factor $(D-j)(D-j-1)/D^2$. |
| $\mathbb E\lVert Q_{SS}\rVert\le(e-1)n\lambda_{r+1}+\tau_r\log(2\tau_r/\lambda_{r+1})$ via Tropp Thm 7.2.1 | **Confirmed.** Proved independently from Lieb's theorem, even with $\log(\tau_r/\lambda_{r+1})$. The quoted Tropp statement could not be checked against the text here. It is kept only as context (Remark 4.1). Hypotheses verified: independence, $0\preceq Z_i$, $\lambda_{\max}(Z_i)=\tau_r$, $\mathbb EY=n\Lambda$, repeats allowed. |
| "$\log(\tau_r/\lambda_{r+1})\le\log\binom D{r+2}+C\sqrt r+r^2/D+C=O(rH_r)$" | **Confirmed**, in the cleaner form of Lemma 4.4. The "$+C\sqrt d$" of the task is true but unnecessary. |
| Theorem S1 (synthesis §4.1; status "sketched") | **Confirmed and completed, conditionally on [SE] Lemma 4.1:** explicit $c=10^{-3}$ (any $c<6.6\cdot10^{-3}$), explicit budget, all $n$ covered, quantifiers explicit. The success probability is $\ge3/4$; the synthesis's "$1-2\delta$" is the same thing. $d_0$ is not explicit, and with the uniform bookkeeping it is astronomically large (Remark 7.2). |
| $\tau_r/\tau_u=d^{o(1)}$ with $u-r=O(\log d/\log(1/\rho))$ | **Confirmed** (Lemma 6.5). Only $d^{O(1)}$ is needed. |
| Small-$n$ step "for $n<\exp((\log d)^3)$ use [Std] Thm 3.2" | Correct, and conservative: [Std] Thm 3.2 covers $n$ up to $n_0(d)=\exp(\Theta(\sqrt d\log d))$, which is used here as the switch point. |
| Extension to odd activations with two-step regularity, including erf (synthesis remark) | **Confirmed** (Remark 7.3), with $\gamma_{\rm erf}=b^2/6$. |

### 8.3 Numerical sanity checks

Scripts are in `/tmp/claude-0/-home-user-AI-works/5853d160-1439-5d10-be76-59b58f86c983/scratchpad/expd/verify/scripts/`. The scripts added after refereeing, with their outputs (`*.out`), are in `/tmp/claude-0/-home-user-AI-works/5853d160-1439-5d10-be76-59b58f86c983/scratchpad/expd/verify/fix_S1/`.

- **`tanh_coef_fast.py`** computes the log-scale $\tanh$ dual coefficients from the $I_m$ formula for odd $m\le4001$ and $\sigma\in\{0.3,0.5,1,2,3\}$.
  - $\sum c_m=1-O(10^{-12})$, which validates (K1).
  - No violation of $c_{m+2}/c_m\ge \upsilon_m^4/((m+1)(m+2))$ or of $\ge\gamma(\sigma)$.
  - The minimal ratio occurs at $m=1$.
- **`cube_checks.py`** and, after refereeing, **`fix_S1/gain_dependence.py`** compose coefficients exactly (all terms positive) and compute $W_j$ by the exact Ehrenfest recursion for $D=41,101,201,301$.
  - Configurations: $L=2$ with $\sigma_1\in\{0.2,0.5,1,3,8\}$, and $L=3$ with gains $(1,1)$, $(1,3)$ and $(0.3,3)$. `cube_checks.py` covered only $\sigma_1\in\{0.5,1\}$ and $L=3$ with $(1,1)$, $(1,3)$.
  - No violation of (3.2), Lemma 3.3(a),(b), or either upper bound of Lemma 4.4. The lower bound $\binom D{r+2}\le\tau_r/\lambda_{r+1}$ is attained at $r=D-2$.
  - **Worst $\tau_r/\tau_{r+2}$.** It depends strongly on the gains, from $1.6$ ($\sigma_1=8$) to $319$ ($\sigma_1=0.2$), and is always far below $1+4/\gamma$; see the table after Lemma 3.3. The range "$2.4$ to $21$" stated in the first version covered only the four configurations of `cube_checks.py`.
  - **Slack of Lemma 4.4.** It depends on the gains and on which upper bound is meant. Two are relevant: the displayed bound $D^{r+2}/((r+2)!\,c_{r+2})$, and the form $\Lambda'_r$ that the proof uses (Lemma 4.4 with (3.2)). Minima over odd $r\le D-2$ and the four values of $D$:

    | configuration | $\min_r\log\dfrac{D^{r+2}/((r+2)!\,c_{r+2})}{\tau_r/\lambda_{r+1}}$ | $\min_r\Big(\Lambda'_r-\log\dfrac{\tau_r}{\lambda_{r+1}}\Big)$ |
    |---|---|---|
    | $L=2$, $\sigma_1=0.2$ | 7.07 | 12.0 |
    | $L=2$, $\sigma_1=0.5$ | 4.16 | 8.94 |
    | $L=2$, $\sigma_1=1$ | 2.68 | 6.93 |
    | $L=2$, $\sigma_1=3$ | 1.55 | 4.56 |
    | $L=2$, $\sigma_1=8$ | 1.21 | 3.40 |
    | $L=3$, $(1,1)$ | 2.36 | 6.93 |
    | $L=3$, $(1,3)$ | 1.57 | 6.79 |
    | $L=3$, $(0.3,3)$ | 2.94 | 10.5 |

    The first version said "the bound exceeds the truth by $e^{6.8}$ to $e^{9}$". That was the second column for the four configurations of `cube_checks.py`, but the text did not say so. It is false for the displayed bound, whose slack is as small as $e^{1.2}$ at $\sigma_1=8$.
- **`restr_check2.py`** checks (2.1) exactly on the full cube for $d=6,8,10,12$. It optimizes the right side over $j<d$ and 50 values of $p$, for 400 (resp. 150) random and structured $h$: random low-degree; ABFR-type univariate in $\sum x_i$; low-degree plus high-degree noise; truncated sub-block parities; large constant plus low-degree.
  - No violation.
  - The minimal slack is $0$ to numerical precision. It is attained by ABFR-type univariate polynomials at $p=1$, where ABFR itself is tight.
- **`gram_check.py`** is a Monte Carlo check of Lemma 4.3 for the $\tanh$ ($L=2$, $\sigma_1=1$) tail kernel at $d=10,12$, $r\in\{1,3,5\}$ and $n\in\{50,200,1000,4000\}$.
  - $\mathbb E\lVert Q_{SS}\rVert/\tau_r$ always lies below the bound with $\log(\tau_r/\lambda_{r+1})$. Example: $d=10$, $r=1$, $n=4000$ gives $32.5\le42.5$.
- **`fix_S1/l_thresholds.py`** (added after refereeing) evaluates (L1)–(L9) in log space (mpmath) for $\sigma_1\in\{0.2,0.3,0.5,1,2,3,8\}$ and $A\in\{1,10,100\}$, over $8\le\log d\le1500$ in steps of $0.05$.
  - It reports the last $\log d$ at which each condition fails. The thresholds for the product condition of (L9) are tabulated in Remark 7.2.
  - Every other condition holds once $\log d>17.05$. The last of them to hold is (L8), at $A=100$.
- **`fix_S1/direct_check.py`** (added after refereeing) evaluates the inequalities that Regime II actually uses, with the actual $r,k^*,u,B_r,J$, at 26 dimensions from $10^{8.42}$ to $10^{180}$. It covers $L=2$, $\sigma_1\in\{0.3,1,3\}$ and $A\in\{1,100\}$.
  - All inequalities hold at every point checked.
  - Over all cases, $\max Ju/d$ lies in $[4.1,6.6]\cdot10^{-4}$, against $1.66\cdot10^{-3}$.
  - $\max\log\big(n/(\varepsilon\binom D{u+2})\big)\le-1.1$, and $r(n_{\max})\log d/d\in[2.41,4.06]\cdot10^{-4}$.
  - See Remark 7.2.

---

## 9. Responses to referees

Two reports judged the work correct, and the third rated it "correct with fixable gaps". None found a mathematical error. Every issue raised was checked, and **all were found to be valid**. None was rejected. The table lists each issue and what was changed. Where an issue made a numerical claim, it was recomputed independently, and the referee's numbers were confirmed in every case.

| # | Referee(s) | Issue | Action |
|---|---|---|---|
| 1 | R1, R2, R3 | Remark 7.2 suggested that new content starts near $d\approx2.6\cdot10^8$. That crossover is only necessary. Condition (L9) alone forces $d_0\ge10^{37}$ to $10^{58}$ for $\sigma_1\in[1,3]$, and $10^{157}$ at $\sigma_1=0.3$, even at $A=1$. | **Valid, fixed.** Remark 7.2 is rewritten. It now says that new content needs $d\ge\max(d_0,d_\times)$, that $d_\times\approx2.58\cdot10^8$ is necessary only, and that $d_0$ is astronomically large. It tabulates the (L9) thresholds for seven gains and $A\in\{1,100\}$, recomputed independently with `fix_S1/l_thresholds.py`. These agree with all three referees to the resolution each used. For example, $\log_{10}d=37.1$, $58.2$, $157.1$ at $\sigma_1=3,1,0.3$ and $A=1$, which is $\log d=85.5$, $133.95$, $361.75$; R3 gives $86$ and $134$ for the first two. It names the cause: the slow convergence of $\mathsf J_d/\log d$, through $\Theta_d$ (the uniform bound on $k^*\log(1+4/\gamma)$) and the additive constants. §0 and the (L9) bullet now say the same, and the (L9) bullet gives the exact formula for $\mathsf J_d/\log d-1$. |
| 1a | R2 (optional), R1 (alternative) | Note that sharper bookkeeping, using the actual $J$ or Lemma T, would give a much smaller threshold. | **Checked, then added with qualification.** `fix_S1/direct_check.py` evaluates the inequalities the proof actually uses, for the actual $r,k^*,u,B_r,J$, at grid dimensions from $10^{8.42}$ to $10^{180}$, for $L=2$, $\sigma_1\in\{0.3,1,3\}$, $A\in\{1,100\}$. They hold everywhere, with $Ju/d\le6.6\cdot10^{-4}$. The main slack turns out to be in $\mathsf r_d$, because $r(n_{\max})\approx(0.24\text{ to }0.41)\,c_*d/\log d$; the slack in $J$ is secondary. This is reported as a numerical observation at grid points, conditional on $A$. It is not added to the theorem, and no explicit $d_0$ is claimed. Lemma T is mentioned only as a possible further improvement, since it is not verified. |
| 2 | R1 | Theorem 6.1 should say that $d_0$ also depends on $c_*$, and on the depth and all gains through $c_1$. | **Valid, fixed.** The theorem now says "depending only on $c_*$, $\sigma_1$, $c_1$ and $A$". It adds that, through $c_1$, $d_0$ depends on the depth and on $\sigma_1,\dots,\sigma_{L-1}$. One refinement: $c_1=\prod_{\ell<L}c_1(q_\ell)$ does not involve the overall scale $\sigma_L$, so $d_0$ does not depend on it. The §0 table row says the same. |
| 3 | R1 | Lemma 6.5's $O(\log d/\log\log d)$ hides a constant that contains $\log(1+4/\gamma)$, and the convergence is slow. | **Valid, fixed.** Lemma 6.5 now defines $\Theta_d$ explicitly, so $\log(\tau_r/\tau_u)\le\Theta_d$. It states $\Theta_d=(1+o(1))\frac12\log(1+\frac4\gamma)\frac{\log d}{\log\log d}$, and adds a proof step and a numerical example showing the slow convergence. It also gives explicit forms in terms of $\rho$ and for the band width. |
| 4 | R1, R3 | Theorem 4.1 (Tropp Thm 7.2.1) is quoted from memory and not used. The theorem and lemma numbers in Prop. 4.2, step 1, are also from memory. | **Valid, fixed.** Theorem 4.1 is now "Remark 4.1 (context only; not used in any proof)", with the access note kept. In Prop. 4.2, Lieb's theorem is cited as Lieb (1973), Adv. Math. 11, Thm 6. The subadditivity lemma is cited as Tropp (2012), FoCM 12, Lemma 3.4, and Tropp (2015), Lemma 3.5.1. All of these numbers are marked as recalled and unverified, and the two-line derivation from Lieb's theorem is written out. The imported-results list says the same. |
| 5 | R2 | The worst $\tau_r/\tau_{r+2}$ was quoted as if it were gain-independent, and §3 (5.8) and §8.3 (2.4–21) did not match. At $\sigma_1=0.2$ it is about $273$–$319$. | **Valid, fixed.** Recomputed with `fix_S1/gain_dependence.py` for eight configurations, including $\sigma_1=0.2$ and $\sigma_1=8$. The results agree with R2: $273$–$319$ at $\sigma_1=0.2$, against $1+4/\gamma=1.47\cdot10^5$. §3 now has a per-configuration table, and §8.3 points to it and explains the earlier ranges. In fact §3's 5.8 was the unit-gain value and §8.3's range covered the four configurations tested then, so the two were not contradictory, only unclear. |
| 6 | R2 | The Lemma 4.4 slack "$e^{6.8}$ to $e^9$" depends on the gains. For the displayed bound it is only $e^{1.2}$ to $e^{7.1}$. | **Valid, fixed.** Rerunning `cube_checks.py` confirms that the earlier figure measured the slack of the explicit form $\Lambda'_r$ used in the proof, not of $D^{r+2}/((r+2)!c_{r+2})$, and that the text did not say so. §8.3 now tabulates both slacks for eight configurations; the displayed bound has slack $1.21$ to $7.07$, matching R2's $1.22$ to $7.07$ up to rounding. The inequality itself never fails. |
| 7 | R3 | The black box is less clean than stated. [SE] Lemma 4.4 depends on Lemma 4.3 and then Lemma 4.1. Lemma 4.1 uses an intermediate estimate, eq. (2.20), inside the proof of Lee's Lemma 2.12, in a homogeneous form derived in [SE] Remark 4.2, plus a seminorm-approximation step. That re-derivation is unverified. The dependence is load-bearing, since a contraction route needs $n\gtrsim D_r^2$ and would collapse Regime II. | **Valid, fixed.** The chain was confirmed in `sampling.tex`; the numbering is the shared counter of §4. Lee's paper is still inaccessible: the proxy refuses arxiv.org and export.arxiv.org with HTTP 403. The status of Theorem S1 is now "proved conditionally on [SE] Lemma 4.1 (the homogeneous form of Lee 2023, eq. (2.20), as derived in [SE] Remark 4.2)". This appears in the header, in §0 (table row 12 and caveat 1), in the imported-results list, in §1.4, after Theorem 6.1, in §7.4 and in §8.1–8.2. Regime I is marked unconditional. The new Remark 1.1 shows that the $D_r\log(2D_r)$ sample size is essential: with $n\gtrsim D_r^2$, the method would reach only $\log n=O(\sqrt{d\log d})=o(\log n_0(d))$. |
| 8 | R3 | Attributions: ABFR counts zeros as errors, and Prékopa is used twice; log-concavity of the cdf is a separate corollary. | **Valid, fixed.** Lemma 2.1 now carries the full ABFR citation and the zeros-as-errors remark. Lemma 5.1(ii), step 1, now derives both facts from Prékopa's marginal theorem, with the full Prékopa (1973) citation, as in [SE] Lemma 10.1. The cdf case applies the theorem to $(s,y)\mapsto p_Y(s)\mathbf 1\{s\le y\}$. That step also notes that $\sigma_x>0$ forces $x\notin S'$, so the joint Gaussian law is nondegenerate. |

**Unchanged.** No mathematical statement had to be weakened or corrected. Lemma statements, proofs, constants and the budget are as before, and the referees confirmed them: for example, the 1/8 budget, $c_\theta$, $C_0$, $\varepsilon$, and the Regime I value $0.3767$.

The changes are of three kinds:
- **Status, stated more precisely.** Theorem S1 was already stated as "proved given [SE] Lemma 4.4". It is now stated as conditional on [SE] Lemma 4.1, which is the same dependency traced to its last link (item 7).
- **Remark 7.2 corrected.** It had suggested where the theorem starts to apply (items 1 and 1a).
- **Explicitness and wording.** Explicit constants, the reporting of the numerics, and citations (items 2–6 and 8).

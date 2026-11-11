# Red-team report on the agnostic NNBayes draft (claims A–E)

*Scope.* An independent check of the draft claims in `../research-notes/problem-brief.md` §4, concentrating on A and B and on the five questions in the task. Everything below is proved here unless it is labelled **sketch** or **open**. Repository statements are cited by file and label and were checked against the source before use. Scripts and their outputs are in `../checks/red-team-and-literature/` (Appendix A). `NNG/` denotes the project folder `neural-network-generalization/` of this repository.

**Notation.** As in the brief: $X\subseteq[-1,1]^d$ compact, $\bar x=(1,x)$, depth $L=H+1\ge2$, width $N$, energy $\kappa_N$ (`NNG/side-results/continuous-domains/source/paper.tex`, eq. `energy`), output $z_w$. For a sample $S=((x_i,y_i))_{i\le n}$ with $y_i\in[-1,1]$,

$$
F_{c,S}(w)=\kappa_N(w)+\frac1c\sum_{i=1}^n\bigl(z_w(x_i)-y_i\bigr)^2,\qquad
\Pi_\sigma(dw)\propto e^{-F_{c,S}(w)/(2\sigma^2)}\,dw .
$$

$L_D(f)=\mathbb E(f(x)-y)^2$, $\hat L(f)=\frac1n\sum_i(f(x_i)-y_i)^2$, $\operatorname{clip}(u)=\max\{-1,\min\{1,u\}\}$, $\eta(x)=\mathbb E[y\mid x]$. For $\zeta>0$, the set of **$\zeta$-near-minimizers** at the fixed width $N$ is $\mathcal N_\zeta=\{w:F_{c,S}(w)\le\min F_{c,S}+\zeta\}$.

**Limit order (used throughout).** The sample and the learner width are fixed first, and then $\sigma\downarrow0$. Every probability over the sample refers to an event that does not depend on $\sigma$ or $N$.

---

## 0. Verdicts

1. **A (depth $L\ge3$, cube, $c=1$): correct after repairs.** The memorizer must be re-derived for real values and accuracy $a$ (Lemma 2.1), which adds an energy term $9(H+1)/(2a)$ that the draft omits. Theorem 2.2 is the corrected statement. Its constants are confirmed: $\beta(1)=0.484829$, and $\max_\lambda\beta=0.517351$ at $\lambda=1.5029$. **Main caveat:** the failure needs learner width $N\ge N_0=\Theta(d^2n/a^2)$. At widths $N\le n^{1/2-\epsilon}$ the same learner is agnostically consistent by parameter counting (Proposition 6.1). A therefore refutes the width-uniform conjecture, which is the brief's formalisation. It does not refute a version in which the learner's width is a fixed small power of $n$.
2. **A′ (continuous inputs, deterministic labels): correct** (Proposition 2.4). The precise condition is that each cluster's radius is below $n^{-2}$ divided by the learner's Lipschitz bound. That bound is $(\kappa_N/L)^{L/2}/\sqrt d$ (Lemma 1.0, the AM–GM form).
3. **B (tempered $c=n^{1-\theta}$): correct, with a better exponent.** For unclipped outputs the draft's bookkeeping through the energy cover does not work; that route gives only $\theta<1/(4L+2)$. The path-norm Rademacher bound already in the repository (`NNG/works-in-progress/noisy-interpolation/README.md`, eq. (15)) gives B for all $\theta<1/H$ with clipped outputs and all $\theta<1/L$ with unclipped outputs (Theorem 3.2, Corollary 3.3). The rate is $\tilde O(n^{-1/(H+2)})$.
4. **D: for clipped predictors the gap closes up to polylog factors.** The memorization threshold and the uniform-convergence threshold are both $c^\star=n^{1-1/H}(\log n)^{\Theta(1/H)}$ (Corollary 3.4).
5. **(2) Repository consistency: no contradiction.** The noisy-interpolation theorem samples without replacement, uses exact sign conditioning with a global margin, and measures clean classification error on the whole cube. At $n\sim2^d$ with a constant flip rate its bound is vacuous, and where it is not vacuous it already allows for memorization (§4.1). The slt-likelihood theorem and the exact-interpolation proposition assume clean labels (§4.2–4.3).
6. **(3) $L=2$, $c=1$: the learner still memorizes partially.**
   - Proved: excess $\ge(0.0999-o(1))/(18d+1)^2$ at $n=2^d$, which refutes the polynomial-sample version (Theorem 5.1).
   - Proved: constant excess $\beta(\lambda)$ when $d\approx n$, using orthogonal atoms (Proposition 5.3).
   - Open: constant excess at $n$ superpolynomial in $d$.
   - Numerics: low-objective networks absorb a fraction 0.40 of the noise at $d=8$ and 0.58 at $d=10$.
7. **(4) The conjecture still fails with deterministic labels, atomless inputs, or a test distribution that excludes the training inputs** (A′). Four versions survive, all proved here: tempered conditioning (B), learner width tied to $n$ (Proposition 6.1), hard tolerance matched to the sup-norm residual of a small network (Proposition 4.1), and conditioning on the aggregate training error (Remark 6.2).
8. **E: for $\gamma>1$, sketches.** The negative direction holds at polynomial widths and the positive direction for small $\theta$ (§8). Both directions are open at mean field ($\gamma=1$).

---

## 1. Basic lemmas

**Lemma 1.0 (output and Lipschitz bounds).** For every $N$ and $w$:

1. $\sup_x\lvert z_w(x)\rvert\le\sqrt N\lVert v\rVert_2\le\sqrt{\kappa_N(w)}$.
2. $\lvert z_w(x)-z_w(x')\rvert\le d^{-1/2}\bigl(\kappa_N(w)/L\bigr)^{L/2}\lVert x-x'\rVert_2$.

*Proof.* (1) $\lvert h^{L-1}_j\rvert\le1$, so $\lvert v^\top h^{L-1}\rvert\le\lVert v\rVert_1\le\sqrt N\lVert v\rVert_2$, and $N\lVert v\rVert_2^2\le\kappa_N$.
(2) tanh is 1-Lipschitz and the constant coordinate cancels, so the Lipschitz constant is at most $\lVert v\rVert_2\prod_{\ell=2}^{L-1}\lVert W^\ell\rVert_{\rm op}\lVert W^1\rVert_{\rm op}\le d^{-1/2}\sqrt{N\lVert v\rVert^2}\prod_\ell\lVert W^\ell\rVert_F\sqrt{(d/N)\lVert W^1\rVert_F^2}$. The $L$ numbers $N\lVert v\rVert^2$, $\lVert W^\ell\rVert_F^2$ ($2\le\ell\le L-1$) and $(d/N)\lVert W^1\rVert_F^2$ sum to $\kappa_N$, so by AM–GM the product of their square roots is at most $(\kappa_N/L)^{L/2}$. ∎

This sharpens `paper.tex` eq. `energy-lipschitz` ($K^{L/2}/\sqrt d$) by the factor $L^{L/2}$, as the brief anticipated.

**Lemma 1.1 (strong-prior concentration, with integrability).** Fix $N$, $c>0$, $S$ and $\zeta>0$. As $\sigma\downarrow0$,

$$
\mathbb E_{\Pi_\sigma}\bigl[(1+F_{c,S})\mathbf 1_{\mathcal N_\zeta^c}\bigr]\to0,
$$

uniformly over $S\in(X\times[-1,1])^n$. Hence for every measurable $\Phi\ge0$ with $\Phi\le b_0+b_1F_{c,S}$,

$$
\inf_{\mathcal N_\zeta}\Phi\le\liminf_{\sigma\downarrow0}\mathbb E_{\Pi_\sigma}\Phi\le\limsup_{\sigma\downarrow0}\mathbb E_{\Pi_\sigma}\Phi\le\sup_{\mathcal N_\zeta}\Phi .
$$

*Proof.* Write $F=F_{c,S}$. Since $F\ge\kappa_N=\lVert\Lambda w\rVert^2$ with $\Lambda$ diagonal and positive, $F$ is coercive and continuous, so $m_*=\min F$ is attained, and $0\le m_*\le F(0)\le n/c$. Let $P$ be the number of parameters.

- *Denominator.* The set $V=\{F<m_*+\zeta/4\}$ is open and nonempty, so $Z_\sigma\ge\lvert V\rvert e^{-(m_*+\zeta/4)/(2\sigma^2)}$.
- *Numerator.* For $\alpha\in(0,1)$ and $t\ge0$ we have $(1+t)e^{-t/(2\sigma^2)}\le(1+2\sigma^2/\alpha)e^{-(1-\alpha)t/(2\sigma^2)}$. On $\{F>m_*+\zeta\}$, $(1-\alpha)F\ge(1-\alpha)^2(m_*+\zeta)+(1-\alpha)\alpha\kappa_N$. Therefore
$$
\int_{\{F>m_*+\zeta\}}(1+F)e^{-F/(2\sigma^2)}\le\Bigl(1+\tfrac{2\sigma^2}\alpha\Bigr)e^{-\frac{(1-\alpha)^2(m_*+\zeta)}{2\sigma^2}}\Bigl(\tfrac{2\pi\sigma^2}{(1-\alpha)\alpha}\Bigr)^{P/2}\det\Lambda^{-1}.
$$
- *Choice of $\alpha$.* Pick $\alpha$ with $(1-\alpha)^2(n/c+\zeta)\ge n/c+\zeta/2$. The difference $(1-\alpha)^2(m+\zeta)-m-\zeta/2$ decreases in $m$, so $(1-\alpha)^2(m_*+\zeta)\ge m_*+\zeta/2$ for every sample. The ratio of numerator to denominator is then at most $\mathrm{poly}(\sigma)\,e^{-\zeta/(8\sigma^2)}/\lvert V\rvert$.
- *Uniformity in $S$.* $\lvert V\rvert$ is bounded below uniformly in $S$. A minimizer lies in the compact set $\{\kappa_N\le n/c\}$. On a unit neighbourhood of that set, $F_{c,S}$ is Lipschitz in $w$ with a constant that does not depend on $S$, because inputs and labels range over compact sets. So a ball of fixed radius around the minimizer lies inside $V$.

The two displayed consequences follow from $\Pi_\sigma(\mathcal N_\zeta)\to1$ and from $\mathbb E_\Pi\Phi\le\sup_{\mathcal N_\zeta}\Phi+\mathbb E_\Pi[(b_0+b_1F)\mathbf 1_{\mathcal N_\zeta^c}]$. ∎

Lemma 1.0(1) gives $L_D(z_w)\le2\kappa_N(w)+2\le2F+2$. So Lemma 1.1 applies to Gibbs risks, to training residuals, and (with Jensen's inequality) to posterior means. Because the scale threshold is uniform over samples, the statements "with probability $\ge1-\delta$" and "for all $\sigma<\sigma_0$" may be interchanged at fixed $N,n,c$.

**Lemma 1.2 (atoms, and the cube example).** Suppose inputs take finitely many values. Let $k_x$ be the number of training inputs equal to $x$, $T=\{x:k_x\ge1\}$, $s=\lvert T\rvert$, $S_x=\sum_{i:x_i=x}y_i$, $\bar y_x=S_x/k_x$, and $W=\sum_i(y_i-\bar y_{x_i})^2$. For every function $f$,

$$
\sum_i(f(x_i)-y_i)^2=\mathcal R(f)+W,\qquad\mathcal R(f):=\sum_{x\in T}k_x(f(x)-\bar y_x)^2. \tag{1.1}
$$

In the **cube example** $D_d$, $x$ is uniform on $\{-1,1\}^d$ (write $M=2^d$) and $y$ is a fair sign independent of $x$. Then $L_D(f)=1+M^{-1}\sum_xf(x)^2$, and $\mathrm{OPT}=1$ is attained by the zero network. Put $Q=\sum_{x\in T}\bar y_x^2$, $G=\sum_{x\in T}k_x\bar y_x^2$ and $V=\sum_xS_x^2$. For every $f$:

- (a) $\displaystyle\frac1M\sum_xf(x)^2\ge\frac1M\bigl(\sqrt Q-\sqrt{\mathcal R(f)}\bigr)_+^2$;
- (b) if $\mathcal R(f)\le(1-\vartheta)G+E_0$, then $\displaystyle\frac1M\sum_xf(x)^2\ge\frac{(\vartheta G-E_0)_+^2}{4MV}$.

*Proof.* (1.1) is the within/between decomposition of the sum of squares. (a) Use the triangle inequality in $\ell^2(T)$, together with $\sum_T(f-\bar y)^2\le\mathcal R(f)$, which holds because $k_x\ge1$. (b) Expanding, $\mathcal R(f)=\sum_Tk_xf^2-2\sum_xf(x)S_x+G$, so $2\sum_xf(x)S_x\ge\vartheta G-E_0$. Cauchy–Schwarz gives $\sum_xf(x)S_x\le(\sum_xf^2)^{1/2}V^{1/2}$. ∎

**Lemma 1.3 (concentration).** In the cube example with $n$ samples, let $K\sim\mathrm{Bin}(n,1/M)$, $\beta_d=\mathbb E[K^{-1};K\ge1]$ and $p_d=\Pr[K\ge1]$. With probability at least $1-4e^{-n^{1/3}/2}-(4+2n/M)n^{-1/3}$,

$$
\lvert Q-M\beta_d\rvert\le2n^{2/3},\qquad\lvert G-Mp_d\rvert\le2n^{2/3},\qquad\lvert V-n\rvert\le n^{2/3}.
$$

If $n/M\to\lambda$, then $\beta_d\to\beta(\lambda)=e^{-\lambda}\sum_{k\ge1}\lambda^k/(k\,k!)$ and $p_d\to1-e^{-\lambda}$.

*Proof.* $\Sigma_1=\sum_{x\in T}k_x^{-1}$ and $s$ are functions of the inputs with bounded differences 2: moving one input changes two counts by 1, and $k\mapsto\mathbf 1[k\ge1]/k$ and $k\mapsto\mathbf 1[k\ge1]$ change by at most 1. McDiarmid's inequality bounds their deviations from $M\beta_d$ and $Mp_d$ by $n^{2/3}$, except with probability $2e^{-n^{1/3}/2}$ each.

Given the inputs, the $S_x$ are independent sums of $k_x$ Rademacher signs, with $\mathbb ES_x^2=k_x$ and $\mathrm{Var}(S_x^2)=2k_x^2-2k_x$. Hence:

- $\mathbb E[Q\mid x]=\Sigma_1$ and $\mathrm{Var}(Q\mid x)\le\sum_T2/k_x^2\le2n$;
- $\mathbb E[G\mid x]=s$ and $\mathrm{Var}(G\mid x)\le2n$;
- $\mathbb EV=n$ and $\mathrm{Var}(V)=2n(n-1)/M$.

Chebyshev's inequality at $n^{2/3}$ completes the bound. The Poisson limit holds because $k\mapsto\mathbf 1[k\ge1]/k$ is bounded. ∎

The script `constants.py` gives the following values:

- $\beta(1)=0.484829=e^{-1}(\mathrm{Ei}(1)-\gamma_E)$;
- $\max_\lambda\beta(\lambda)=0.517351$, at $\lambda=1.5029$;
- the binomial value at $d=10$, $n=M$ is $0.485030$.

These confirm the brief's constants.

---

## 2. Claim A

### 2.1 The real-valued memorizer

The brief's item 3.7 notes, correctly, that the construction in `noisy-interpolation/README.md` §§2–3 handles sign corrections at accuracy $1/4$ only. Here it is re-derived. I write $\Gamma$ for the README's chain gain $R$.

**Lemma 2.1.** Let $X=\{-1,1\}^d$, $r:X\to[-1,1]$, $\lVert r\rVert_2^2=\sum_xr(x)^2$, $0<a\le1$ and $H\ge1$. Put

$$
A_0=3\sqrt d\,\lVert r\rVert_2,\qquad m_0=\Bigl\lceil\frac{8A_0^2\ln(2M)}{a^2}\Bigr\rceil+1,\qquad F_d=1+(d+1)(d+2)^2 .
$$

For every width $N\ge m_0$:

1. If $H\ge2$, there is a depth-$(H+1)$, width-$N$ network with $\sup_X\lvert z_w-r\rvert\le a$ and $\kappa_N(w)\le dF_d+(H+1)\Gamma^2$, where $\Gamma^2=\max\{9/(2a),A_0^{2/H}\}$.
2. If $H=1$, there is a function $g$ with $\sup_X\lvert g-r\rvert\le a/2$ such that, for every $t\in[0,1]$, some width-$N$ depth-2 network computes $tg$ exactly with $\kappa_N\le dF_d+2t^2A_0^2$.

*Proof.*

*Step 1 (Fourier).* With normalized coefficients, Parseval and Cauchy–Schwarz over the $M$ coefficients give $\sum_S\lvert\hat r(S)\rvert\le\lVert r\rVert_2$ (README eq. (2)).

*Step 2 (parities).* For $\lvert S\rvert=k\ge1$, README eqs. (3)–(4) give
$$
\chi_S=c_{k,a_d}^{-1}\,\mathbb E_u\Bigl[\bigl(\textstyle\prod u_j\bigr)\tanh\bigl(a_d(\sum_{j\in S}u_jx_j-b_k)\bigr)\Bigr],\qquad\lvert c_{k,a_d}\rvert^{-1}\le2\sqrt{2k}\le3\sqrt d .
$$
I re-checked identity (4), the exact coefficients $\binom{2m}{m}/4^m$, and $\min_{d\le16,\,k\le14}\lvert c_{k,a_d}\rvert\,2\sqrt{2k}=1.337\ge1$ numerically (`constants.py`). Each row has squared norm $a_d^2(k+b_k^2)\le(d+2)^2(d+1)\le F_d$. For the empty set, $\chi_\emptyset\equiv1=\tanh(\bar x_0)/\tanh 1$ (where $\bar x_0=1$ is the constant coordinate), with coefficient $1/\tanh1\approx1.31<3\sqrt d$. Signs are absorbed into rows because tanh is odd. Mixing in the zero row with the leftover probability gives $r=A_0\,\mathbb E_{\omega\sim\pi}\tanh(\omega\cdot\bar x)$, where $\pi$ is a probability law on rows with $\lVert\omega\rVert^2\le F_d$.

*Step 3 (sampling).* Draw $\omega_1,\dots,\omega_{m_0}$ independently from $\pi$ and put $g=\frac{A_0}{m_0}\sum_j\tanh(\omega_j\cdot\bar x)$. By Hoeffding's inequality and a union bound over the $M$ inputs,
$$
\Pr\bigl(\exists x:\lvert g(x)-r(x)\rvert>a/2\bigr)\le2Me^{-m_0a^2/(8A_0^2)}<1 .
$$
Fix a realization outside this event. Then $\lvert g\rvert\le1+a/2\le3/2$.

*Step 4 (first layer).* Split the $N$ neurons into $m_0$ groups of sizes $k_j\in\{\lfloor N/m_0\rfloor,\lceil N/m_0\rceil\}$. Each $k_j\ge N/(2m_0)$ because $N\ge m_0$. Every neuron in group $j$ gets row $\omega_j$. The first-layer energy is $\frac dN\sum_jk_j\lVert\omega_j\rVert^2\le dF_d$.

*Step 5 ($H=1$).* Put readout $tA_0/(m_0k_j)$ on each copy of feature $j$. The output is $tg$, and the readout energy is $\frac{Nt^2A_0^2}{m_0^2}\sum_jk_j^{-1}\le2t^2A_0^2$.

*Step 6 ($H\ge2$).* Every layer-2 neuron receives weight $A_0/(m_0k_j\Gamma^{H-1})$ from each copy of feature $j$, so its preactivation is $g/\Gamma^{H-1}$. The squared Frobenius norm of this layer is $\frac{NA_0^2}{m_0^2\Gamma^{2H-2}}\sum_j\frac1{k_j}\le2A_0^2/\Gamma^{2H-2}\le2\Gamma^2$. Layers $3,\dots,H$ have all weights $\Gamma/N$, costing $\Gamma^2$ each. The readout is $\Gamma/N$ per neuron, costing $\Gamma^2$. The total is $dF_d+(H+1)\Gamma^2$. Using $\lvert t-\tanh t\rvert\le\lvert t\rvert^3/3$ and telescoping (README eq. (9)), the chain error is at most $\frac{\lvert g\rvert^3}3\sum_{i\ge1}\Gamma^{-2i}\le\frac{2\lvert g\rvert^3}{3\Gamma^2}\le\frac9{4\Gamma^2}\le a/2$. ∎

### 2.2 Corrected statement and proof of A

**Theorem 2.2.** Fix $H\ge2$ and $\lambda>0$. For each $d$ let $n=\lceil\lambda M\rceil$, $\lambda'=n/M$, and choose $c=c_d>0$ and $a=a_d\in(0,1]$. Put

$$
\epsilon_d=\frac1n\Bigl(c_d\bigl[dF_d+(H+1)\max\{\tfrac9{2a_d},(9dn)^{1/H}\}+1\bigr]+na_d^2\Bigr),\qquad
N_0=\Bigl\lceil\frac{72\,d\,n\ln(2M)}{a_d^2}\Bigr\rceil+1 .
$$

On the event of Lemma 1.3, for every width $N\ge N_0$:

1. Every $w\in\mathcal N_1$ has $\mathcal R(z_w)\le\epsilon_dn$ and
$$
L_D(z_w)\ge L_D(\operatorname{clip}z_w)\ge1+\Bigl(\sqrt{\beta_d-2n^{2/3}/M}-\sqrt{\lambda'\epsilon_d}\Bigr)_+^2 .
$$
2. The same lower bound holds for $\liminf_{\sigma\downarrow0}$ of the Gibbs risk (clipped or not), of $L_D(\mathbb E_{\Pi_\sigma}z_w)$, and of $L_D(\mathbb E_{\Pi_\sigma}\operatorname{clip}z_w)$.

Suppose $\epsilon_d\to0$. Two sufficient choices are (i) $c_d=1$ with $a_d=n^{-1/3}$, and (ii) any $c_d=o\bigl(n^{1-1/H}(9d)^{-1/H}\bigr)$ with $a_d=(c_d/n)^{1/3}$. Then, with probability $1-o(1)$, all these risks are at least $1+\beta(\lambda)-o(1)$, while $\mathrm{OPT}=1$. Since $n=\lceil\lambda2^d\rceil$ eventually exceeds every polynomial in $d$, no polynomial sample bound holds for these learners.

*Proof.* Let $r=\bar y\mathbf 1_T$. Then $\lvert r\rvert\le1$ and $\lVert r\rVert_2^2=Q\le n$, so $A_0^2\le9dn$ and $m_0\le N_0$. Lemma 2.1(1) gives $w_{\rm mem}$ with $\kappa_N(w_{\rm mem})\le K_{\rm mem}:=dF_d+(H+1)\max\{9/(2a),(9dn)^{1/H}\}$ and $\mathcal R(z_{w_{\rm mem}})\le na^2$. For $w\in\mathcal N_1$, by (1.1),

$$
\mathcal R(z_w)=c\bigl(F_{c,S}(w)-\kappa_N(w)\bigr)-W\le c\bigl(F_{c,S}(w_{\rm mem})+1\bigr)-W\le c(K_{\rm mem}+1)+na^2=\epsilon_dn .
$$

Clipping does not increase $\mathcal R$, since it is the projection onto $[-1,1]\ni\bar y_x$. Also $(\operatorname{clip}u-y)^2\le(u-y)^2$ for $\lvert y\rvert\le1$. Lemma 1.2(a) and Lemma 1.3 then give part 1.

For part 2, apply Lemma 1.1 with $\Phi=L_D(\cdot)\le2F+2$ for the Gibbs risk. For posterior means, $\mathcal R$ is convex in $f$, so $\mathcal R(\mathbb E_\Pi z_w)\le\mathbb E_\Pi\mathcal R(z_w)$. Lemma 1.1 with $\Phi=\mathcal R\le cF$ gives $\limsup_\sigma\mathbb E_\Pi\mathcal R\le\epsilon_dn$, and Lemma 1.2(a) finishes.

For choice (ii), $c\,dF_d=o(n)$ because $d^4\le2^{d/H}$ eventually. Also $9(H+1)c/(2a)+na^2=O(c^{2/3}n^{1/3})=o(n)$. ∎

*Numbers* (`bounds_table.py`, $\lambda=1$, $c=1$, $a$ optimized, excess lower bound shown):

| $H$ | $d=20$ | $d=30$ | $d=40$ |
|---|---|---|---|
| 2 | 0.046 | 0.419 | 0.474 |
| 3 | 0.064 | 0.444 | 0.483 |

With a fixed $a$ the bound reads $(\sqrt{\beta(\lambda)}-\sqrt{\lambda}\,a)^2-o(1)$ at width $N_0=O(d^2n/a^2)$. The bound is weak below $d\approx25$ because of the first-layer term $dF_d\approx d^4$, an artefact of the parity features. The numerics in §5.4 show that at $d=8$–$10$ actual low-objective networks memorize far more cheaply.

### 2.3 Errors and gaps in the draft of A

- **A1 (memorizer bookkeeping).** The draft's $K_{\rm mem}=O(d^4+(dn)^{1/H})$ omits the accuracy cost $9(H+1)/(2a)$. Its residual bound "$c(K_{\rm mem}+1)$" omits the memorizer's own residual $na^2$. Its display $F_c=\kappa+\frac1c\sum k_x(\cdot)^2+W$ should end in $W/c$. Fixing these leaves the conclusion unchanged, with the conditions $c=o(n^{1-1/H}d^{-1/H})$ and $c=o(n)$. They are bookkeeping errors, not threats to A.
- **A2 (learner width: the important caveat).** The failure is proved only for $N\ge N_0=\Theta(d^2n/a^2)$. This is not a removable artefact. At $N\le n^{1/2-\epsilon}$ (for $L\ge3$), the same learner satisfies an agnostic oracle inequality against every competitor of width $\le N$ (Proposition 6.1). So A refutes **width-uniform** statements, which is the repository's style and the brief's formalisation. It does not refute "Bayesian learning at width $n^{\alpha}$ competes with width-$n^\alpha$ networks", and that statement is true for $\alpha<1/4$. The user explicitly allowed "whichever version of Bayesian learning is best", so any write-up must say which version is refuted.
- **A3 (two formulations).** The brief calls the polynomial-sample formulation "equivalent" to "test loss $\le\min$ over width/weights $\le n^\alpha$, plus $o(1)$". That holds only when the $o(1)$ is polynomially small and $d\le n^{O(1)}$. With an arbitrary $o(1)$, say $1/\log^2n$, the second statement is strictly weaker. A gives a constant excess at $d=\log_2n$, so it refutes both. The depth-two cube bound (Theorem 5.1) refutes only the polynomial one.
- **A4 (posterior mean).** The claim "the posterior mean via convexity" also needs uniform integrability, because $\mathcal R$ and $L_D$ are unbounded on parameter space. Lemma 1.1 supplies it.
- **A5 (TUBE variants): correct, and sharper than stated.**
  - $\rho>1$: with labels in $[-1,1]$, $w=0$ satisfies every constraint, so the strong-prior TUBE posterior concentrates on $\{\kappa_N\le\zeta\}$. Its outputs are then at most $\sqrt\zeta$ in absolute value (Lemma 1.0), so the predictor is identically 0 and the excess is $\mathbb E\eta(x)^2$. It is not a learner at all.
  - $\rho\le1$ with replacement: the posterior is undefined once some atom carries both labels. Let $\mathcal C$ be the number of such atoms; it has bounded differences 2. McDiarmid's inequality gives $\Pr(\mathcal C=0)\le\exp(-\mu_c^2/(2n))$ with $\mu_c=M\,\mathbb E[1-2^{1-K};K\ge2]$, for example $\mu_c\approx0.15M$ at $\lambda=1$.
  - $\rho<1$ without replacement: every feasible $w$ has $\lvert z_w(x)\rvert>1-\rho$ at each training atom, so the excess is at least $(n/M)(1-\rho)^2$. No energy argument is needed.

### 2.4 A′, made precise

**Proposition 2.4.** Let $d=d'+1$, $M=2^{d'}$, $q\ge1$ an integer and $0<r\le1$. Let $b$ be uniform on $\{-1,1\}^{d'}$ and $u\sim U[0,1]$ independent; put $x=(b,ru)\in[-1,1]^d$ and

$$
y=f^\ast(x):=(-1)^{\lfloor2qx_d/r\rfloor}.
$$

The labels are a deterministic function of $x$, and the input law has no atoms. Fix $H\ge2$, $c=1$ and $n=\lceil\lambda M\rceil$, and take $r\le(n+1)^{-L/2}n^{-2}$. Then on the event of Lemma 1.3 (applied to the pairs $(b_i,y_i)$), for every $N\ge N_0$ every $w\in\mathcal N_1$ satisfies

$$
L_D(\operatorname{clip}z_w)\ge1+\Bigl(\sqrt{\beta_d-2n^{2/3}/M}-\sqrt{\lambda'(\epsilon_d+5n^{-2})}\Bigr)_+^2-4n^{-2},
$$

where $\epsilon_d$ is as in Theorem 2.2 with $dF_d$ replaced by $(d'+1)F_{d'}$. Gibbs and posterior-mean risks satisfy the same bound in the limit. Moreover, every $h$ that is $\Lambda'$-Lipschitz in $x_d$ has $L_D(h)\ge1-\Lambda'r/(2q)$. So $\mathrm{OPT}\approx1$ over any class of polynomial size once $q$ is superpolynomial, while the Bayes risk is $0$.

*Proof.*

- *Lipschitz control.* $\kappa_N(w)\le F_{1,S}(w)\le F_{1,S}(0)+1\le n+1$, so by Lemma 1.0(2), $\lvert z_w(b,ru)-z_w(b,0)\rvert\le(n+1)^{L/2}r\le n^{-2}$. The same holds after clipping.
- *Law of the training pairs.* $\Pr(\lfloor2qu\rfloor\text{ even})=1/2$, so the pairs $(b_i,y_i)$ have exactly the law of the cube example.
- *Memorizer.* The memorizer of Lemma 2.1 built on $b$ is constant in $x_d$.
- *Residual.* Since $\lvert\operatorname{clip}z-y\rvert\le2$ and $(A+e)^2\le A^2+2\lvert A\rvert\lvert e\rvert+e^2$, $\sum_i(\operatorname{clip}z_w(b_i,0)-y_i)^2\le\sum_i(z_w(x_i)-y_i)^2+5/n$. Hence $\mathcal R(\operatorname{clip}z_w(\cdot,0))\le\epsilon_dn+5/n$.
- *Test risk.* Using $\mathbb E_uy=0$ and $\mathbb E_uy^2=1$, $L_D(\operatorname{clip}z_w)\ge1+M^{-1}\sum_b\operatorname{clip}z_w(b,0)^2-4n^{-2}$. Then proceed as in Theorem 2.2.
- *Competitor bound.* Pair adjacent half-periods of the label pattern: $\lvert\mathbb E_u[h\,y]\rvert\le\Lambda'r/(4q)$. ∎

### 2.5 Sampling without replacement

With distinct inputs, $k_x=1$ and $Q=s=n$, so the excess tends to $n/M$; at $n=M$ the test MSE is $2$. This is not an i.i.d. counterexample, but it is the analogue of A in the noisy-interpolation setting (§4.1).

---

## 3. Claim B, and the threshold in D

### 3.1 A width-free Rademacher bound on arbitrary inputs

**Lemma 3.1.** For any $x_1,\dots,x_n\in\mathbb R^d$ and $K\ge0$, let $\mathcal Z_K=\bigcup_{N\ge1}\{z_w:\kappa_N(w)\le K\}$. Then

$$
\hat{\mathfrak R}_S(\mathcal Z_K):=\mathbb E_\varepsilon\sup_{z\in\mathcal Z_K}\frac1n\sum_i\varepsilon_iz(x_i)\le\Bigl(\frac KH\Bigr)^{H/2}\frac{\mathcal D_{d,H}(n)}{\sqrt n},\qquad\mathcal D_{d,H}(n)=\sqrt{2\ln(2\Pi_d(n))}+\frac{H-1}2,
$$

where $\Pi_d(n)$ counts the dichotomies of $\{x_i\}$ by affine halfspaces. By Sauer–Shelah, $\Pi_d(n)\le(en/(d+1))^{d+1}$ for $n\ge d+1$. On the cube, $\mathcal D_{d,H}\le\sqrt2(d+2)+H$.

*Proof.* `noisy-interpolation/README.md` §4, eqs. (12)–(15), uses the Boolean cube only to count halfspace dichotomies ($\log J\le(d+2)^2$). Every other step is domain-free, and I re-checked each one:

- the clip contraction (12);
- the clip mixture (13): the weights $2r\tanh(rt)\operatorname{sech}^2(rt)$ on $[0,1]$ plus the atom $\operatorname{sech}^2r$ at $t=1$ sum to 1, and both sides have derivative $\operatorname{sech}^2(ru)$;
- the path normalization;
- the path-norm bound (14): $P\le(\kappa_N/H)^{H/2}$ by AM–GM over $N\lVert v\rVert^2$ and the $H-1$ internal Frobenius norms (the first-layer energy is not used);
- $\tanh u=\mathbb E_T\operatorname{sign}(u-T)$, where $T$ has distribution function $(1+\tanh t)/2$.

On a sample, $\{\pm\operatorname{sign}(\omega\cdot\bar x_i-t)\}_i$ takes at most $2\Pi_d(n)$ values, almost surely in $T$. Massart's lemma then gives $\hat{\mathfrak R}_S(\mathcal F_1)\le\sqrt{2\ln(2\Pi_d(n))/n}$. ∎

### 3.2 An oracle inequality for SP$_c$ at every $c$, uniform in width

**Theorem 3.2.** Let $D$ be any law on $X\times[-1,1]$. Let $g$ be a depth-$L$ network of width $m$ with weights in $[-B,B]$, $B\ge1$. Put $U=mB$, so that $U\ge\sup\lvert g\rvert$, and $E_*=d(d+1)B^2+2(L-1)m^2B^2$. Fix $c>0$ and $\delta\in(0,1)$, and let $K=E_*+1+n(U+1)^2/c$. With sample probability at least $1-\delta$, simultaneously for every width $N\ge m$ and every $w\in\mathcal N_1$:

$$
L_D(\operatorname{clip}z_w)\le L_D(g)+\frac{c(E_*+1)}n+\frac{8\mathcal D_{d,H}(n)}{\sqrt n}\Bigl(\frac KH\Bigr)^{H/2}+\bigl(4+(U+1)^2\bigr)\sqrt{\frac{\ln(4/\delta)}{2n}}, \tag{3.1}
$$

$$
L_D(z_w)\le L_D(g)+\frac{c(E_*+1)}n+\frac{4(\sqrt K+1)\mathcal D_{d,H}(n)}{\sqrt n}\Bigl(\frac KH\Bigr)^{H/2}+\bigl((\sqrt K+1)^2+(U+1)^2\bigr)\sqrt{\frac{\ln(4/\delta)}{2n}}. \tag{3.2}
$$

By Lemma 1.1, the right sides also bound $\limsup_{\sigma\downarrow0}$ of the Gibbs risk and of the risk of the posterior mean (of $\operatorname{clip}z_w$ and of $z_w$, respectively), at every fixed $N\ge m$.

*Proof.* By `paper.tex` §3 (eq. `teacher-energy`; I re-checked the three layer contributions), $g$ has an exact clone $w_g$ at width $N$ with $\kappa_N(w_g)\le E_*$. For $w\in\mathcal N_1$, $F_{c,S}(w)\le F_{c,S}(w_g)+1$, that is,

$$
\kappa_N(w)+\tfrac nc\hat L(z_w)\le E_*+1+\tfrac nc\hat L(g).
$$

Hence $\hat L(z_w)\le\hat L(g)+c(E_*+1)/n$. Since $\hat L(g)\le(U+1)^2$, also $\kappa_N(w)\le K$, so $z_w\in\mathcal Z_K$.

The loss $u\mapsto(\operatorname{clip}u-y_i)^2$ is 4-Lipschitz with values in $[0,4]$. Symmetrization (Mohri–Rostamizadeh–Talwalkar, *Foundations of ML*, Thm 3.3), Talagrand's contraction lemma (ibid., Lemma 5.7) and Lemma 3.1 give, with probability at least $1-\delta/2$, for all $z\in\mathcal Z_K$:

$$
L_D(\operatorname{clip}z)\le\hat L(\operatorname{clip}z)+8\,\mathcal D_{d,H}(n)(K/H)^{H/2}/\sqrt n+4\sqrt{\ln(4/\delta)/(2n)}.
$$

Hoeffding's inequality for the single function $g$ (loss in $[0,(U+1)^2]$) gives $\hat L(g)\le L_D(g)+(U+1)^2\sqrt{\ln(4/\delta)/(2n)}$ with probability at least $1-\delta/2$. Finally, $\hat L(\operatorname{clip}z_w)\le\hat L(z_w)$.

For (3.2), use $\lvert z\rvert\le\sqrt K$ on $\mathcal Z_K$ (Lemma 1.0): the loss is $2(\sqrt K+1)$-Lipschitz there with range $(\sqrt K+1)^2$. The sample event involves neither $N$ nor $\sigma$. ∎

**Corollary 3.3 (Claim B, with the exponent improved).** Let $c=n^{1-\theta}$.

(a) *Clipped predictions, $\theta\in(0,1/H)$.* The excess in (3.1) is at most
$$
(E_*+1)n^{-\theta}+8\mathcal D_{d,H}(n)\bigl(\tfrac2H\bigr)^{H/2}\Bigl[(E_*+1)^{H/2}n^{-1/2}+(U+1)^Hn^{-(1-\theta H)/2}\Bigr]+(U+3)^2\sqrt{\tfrac{\ln(4/\delta)}{2n}} .
$$
Each term is at most $\varepsilon/4$ once $n\ge\mathrm{poly}_{L,\theta}(d,m,B,1/\varepsilon,\log(1/\delta))$. The $\sqrt{\ln n}$ inside $\mathcal D$ is absorbed as in the slt-likelihood proof. This holds for every $D$, every $N\ge m$, in the strong-prior limit. With $\theta=1/(H+2)$, the excess is $\tilde O\bigl(\mathrm{poly}(d,m,B)\,n^{-1/(H+2)}\bigr)$.

(b) *Unclipped predictions.* The same holds for every $\theta\in(0,1/L)$, using (3.2): its middle term is of order $n^{(\theta(H+1)-1)/2}$.

### 3.3 What is wrong or loose in the draft of B

- **B1.** "$\kappa\le\kappa(g)+1+nU^2/c$" should read $n(U+1)^2/c$, because labels lie in $[-1,1]$. Harmless.
- **B2 (cover bookkeeping).** For $L\ge3$, the paper's bound on $\log\lvert\mathcal H_{K,a}\rvert$ (Prop. `energy-cover`) is of order $\tilde O(K^{4(L-1)}a^{-8})$, and no better. This follows from $P\approx(L-2)J^2$ and $J\asymp\lambda^{-4}\asymp K^{2(L-1)}a^{-4}$ (Lemma `compression`). For $L=2$ the bound is of order $\tilde O(K^2a^{-4})$.
  - With clipping, $a\asymp\varepsilon$ and the loss range is 4, which gives $\theta<1/(4(L-1))$, as drafted.
  - Without clipping, one needs $a\lesssim\varepsilon/\sqrt K$ and pays a loss range of order $K$, which gives only $\theta<1/(4L+2)$.

  So the draft's "clipped **or unclipped**, $\theta<1/(4(L-1))$" is not justified by the cover. It is nonetheless true by Corollary 3.3(b), because $1/(4(L-1))<1/L$.
- **B3.** The brief asks whether a sharper capacity bound enlarges $\theta_L$. It does, and the bound is already in the repository: $\theta_L=1/H$ (clipped) or $1/L$ (unclipped), and §3.4 shows $1/H$ is essentially sharp.
- **B4 (quantifiers to state).** The statement of B should record that:
  - the sample event does not depend on $N$ or $\sigma$;
  - $\sigma_0$ depends on $(N,n,c)$ but not on the sample or on $D$ (Lemma 1.1);
  - the competitor must have the learner's depth.
- I found no further gap.

### 3.4 D: the two thresholds coincide

**Corollary 3.4.** Take the cube example with $H\ge2$, and let $\omega_n\to\infty$ arbitrarily slowly.

1. If $c\le n^{1-1/H}/\bigl(\omega_n(H+1)(9d)^{1/H}\bigr)$, then near-minimizers, Gibbs predictors and posterior means, clipped or not, have excess at least $\beta(\lambda)-o(1)$ with probability $1-o(1)$. This is Theorem 2.2 with $a=(c/n)^{1/3}$.
2. If $\omega_n\bigl(8\mathcal D_{d,H}(n)\bigr)^{2/H}n^{1-1/H}\le c\le n/\omega_n$, then near-minimizers, Gibbs predictors and posterior means of **clipped** outputs have excess tending to 0 with probability $1-o(1)$. This is (3.1) with $g\equiv0$: the all-zero network has $E_*=0$ and $U=0$, so, using $1+n/c\le2n/c$, the middle term is at most $8\mathcal D\,n^{-1/2}(2n/(cH))^{H/2}\le(2/(H\omega_n))^{H/2}\to0$.

Since $\mathcal D_{d,H}\le\sqrt2(d+2)+H$ and $d=\log_2n$, both thresholds equal $n^{1-1/H}(\log n)^{\Theta(1/H)}$.

**Remark 3.5 (memorization costs energy at least $s^{1/H}$).** Let $\epsilon$ be a uniform random sign vector on $s$ distinct points. Suppose that, with probability at least $p$, some network of energy at most $K$ has $\frac1s\sum_i\epsilon_iz(x_i)\ge\phi$. Since $0\in\mathcal Z_K$, Lemma 3.1 gives $p\phi\le\mathcal D(K/H)^{H/2}/\sqrt s$, that is, $K\ge H(p\phi\sqrt s/\mathcal D)^{2/H}$. This matches Lemma 2.1's $O\bigl(dF_d+(H+1)(9ds)^{1/H}\bigr)$ up to factors polynomial in $d$.

**Open.** For unclipped predictors, (3.2) moves the upper threshold to $c\gtrsim n^{1-1/(H+1)}$. Whether unclipped predictors fail inside the window $[n^{1-1/H},n^{1-1/(H+1)}]$ is not settled; failure would require large outputs on unseen atoms.

---

## 4. Consistency with the repository

### 4.1 `NNG/works-in-progress/noisy-interpolation/README.md`

The theorem's quantifiers (README §1) are as follows.

- **Sampling:** $n\le M$ distinct inputs drawn uniformly **without replacement**.
- **Labels:** at most $s$ corruptions of a clean Boolean target that has a margin teacher.
- **Learner:** the prior is conditioned on a **global margin** $\lvert z_w\rvert>1/2$ on the whole cube, then **exactly** on the training signs, in the strong-prior limit at each $N\ge W_s=O(C+U^2d^2(s+1))$.
- **Metric:** $R_X$, the posterior-average **clean classification error** under the uniform law on the **whole cube, including training points**.
- **Bound:** eq. (1), $(B_L+As+8\log(1/\delta))/n+\tau$; for independent flips, eq. (21), $2A\eta+O(\cdot/n)$.

There is no contradiction with A, for six reasons.

1. The learner, the label model and the loss all differ from A's.
2. At "$n\sim2^d$ with many flips" the theorem is vacuous. Here $A=2+8b_1$ with $b_1=576e^6(d+1)D_{d,H}^2U^2d$ and $D_{d,H}\ge\sqrt2(d+2)$, so $A\ge3.7\cdot10^6\,d(d+1)(d+2)^2U^2$ (for example $A\ge5.9\cdot10^{10}$ at $d=10$). Bound (21) therefore exceeds 1 once $\eta\gtrsim10^{-7}d^{-4}$. FAQ 33 says as much ("even a single corruption can make the bound vacuous in small dimensions").
3. Where the bound is not vacuous, it already allows for memorization. Exact conditioning reproduces every flipped training label, so memorization forces $R_X$ to be at least the number of flipped training points divided by $M$. That number is at most $s/M\le s/n\le As/n$, so the forced error never exceeds the theorem's upper bound. At $n=M$ there is no unseen point and $R_X=s/M$ exactly. The whole-cube convention is what makes the bound compatible with memorization. On unseen points, the README's factor $M/(M-n)$ blows up as $n\to M$.
4. In A's units, an exact interpolant has excess MSE (against fresh noisy labels) of $\mathrm{Var}(y\mid x)$ per seen point, i.e. $4\eta(1-\eta)n/M$ in total. Like their bound, this is $O(\eta)$.
5. Distinct inputs are needed because with repetitions, conflicting labels make exact conditioning infeasible (FAQ 33, "Scope"). This is the same obstruction as for TUBE in A5.
6. The width threshold $W_s$ grows with $s$; at $n\sim2^d$ it is exponential in $d$, mirroring A's $N_0$.

Cross-links: README §3 (eqs. (8)–(11)) is the engine of A (Lemma 2.1). README eq. (15) is the engine of Theorem 3.2 and Remark 3.5. README eq. (22) is the counting reflection of cheap memorization.

### 4.2 `NNG/works-in-progress/slt-likelihood/README.md`

- **§2 theorem.** It assumes clean labels $y_i=f(x_i)$ from a bounded teacher and $c=1$; the remark after the proof extends it to any fixed $c$. Its conclusion concerns $\lvert z_w-f\rvert$. The proof needs the residual budget $c(E_*+1)=O(1)$, so that at most $8cK/\tau^2$ training points can fall in a bad set $A_h$. With noise, the budget becomes $c(E_*+1)+\sum_i(f(x_i)-y_i)^2\approx n\,\mathbb E\mathrm{Var}(y\mid x)$, a constant fraction of $n$, and the Chernoff step fails. A shows that this failure is not an artefact of the proof. FAQ 34 already restricts the claim to clean observations.
- **A′ is outside §2's scope.** Although A′ has deterministic labels, $f^\ast$ is discontinuous and is not a bounded-weight teacher.
- **§3** (a fixed smooth likelihood fails when the prior concentrates first) does not touch B. In B the likelihood variance $n^{1-\theta}\sigma^2$ tends to 0 together with $\sigma$, and §3 explicitly leaves open "learning when sample size or likelihood temperature grows with prior concentration".
- **§4** (fixed $\beta$, a prior-mass bound that pays $N^\gamma$) is the mechanism of draft claim C.

### 4.3 `paper.tex`, Prop. `exact` and Cor. `exact`

Both are statements about clean labels, covering all widths and every $w$ with $\kappa_N\le E_*$ and $\max_i\lvert z_w(x_i)-f(x_i)\rvert\le\tau/2$. With random labels, minimum-energy interpolants have energy at least $H(s/\mathcal D^2)^{1/H}\to\infty$ (Remark 3.5 with $\phi=p=1$). They therefore lie outside the proposition's energy budget, and A shows that they do not generalize. There is no contradiction. The proof does extend to residuals that are bounded in sup norm:

**Proposition 4.1 (TUBE with a sup-norm residual budget).** Let $g$ be a depth-$L$ teacher (width $C$, weights at most $B$), and let $D$ be a law on $X\times[-1,1]$ with $\lvert y-g(x)\rvert\le\rho_0$ almost surely. Let $\rho>\rho_0$ and $\tau>\rho+\rho_0$, and condition the strong-prior Gaussian prior on $\lvert z_w(x_i)-y_i\rvert<\rho$ for all $i$. Then Theorem `strong` holds verbatim after these replacements:

- $f$ by $g$;
- $\rho$ by $\rho-\rho_0$ in the tube and by $\rho+\rho_0$ in the cover step;
- $u$ by $u'=1/\min\{1,\tau-\rho-\rho_0\}$.

Consequently, at the same polynomial sample size,

$$
\mathbb E_\Pi L_D(\operatorname{clip}z_w)\le(\tau+\rho_0)^2+4\varepsilon/3 .
$$

With $\rho=2\rho_0$ and $\tau=4\rho_0$ this is $25\rho_0^2+4\varepsilon/3$, while $\mathrm{OPT}\le L_D(g)\le\rho_0^2$.

*Proof.*

- *Denominator.* $U_{\rho-\rho_0}(g)=\{w:\sup_X\lvert z_w-g\rvert<\rho-\rho_0\}$ lies inside the conditioning event for every sample, because $\lvert z_w(x_i)-y_i\rvert\le\lvert z_w(x_i)-g(x_i)\rvert+\rho_0$. It is open and contains the exact clone, so the strong-prior estimates of the proof of `strong` apply, with a scale threshold that does not depend on the sample.
- *Cover step* (Lemma `posterior`). Use $A_h=\{\lvert h-g\rvert>\rho+\rho_0+a\}$ with $2a<\tau-\rho-\rho_0$. A fitted $w$ within $a$ of $h$ has $\lvert h(x_i)-g(x_i)\rvert<a+\rho+\rho_0$, so no training input lies in $A_h$. Moreover $\lvert z_w-g\rvert>\tau$ implies $\lvert h-g\rvert>\tau-a>\rho+\rho_0+a$.
- *Risk.* Finally, $(\operatorname{clip}z_w-y)^2\le\min\{4,(\lvert z_w-g\rvert+\rho_0)^2\}$. ∎

Hard conditioning within the sup-norm residual of a small network never memorizes: the minimum energy over the constraint set is at most $E_*$ for every $n$. By contrast, a Gaussian likelihood with fixed $c$ always rewards fitting below the residual level. For noise-like residuals ($\rho_0\ge1$ for fair signs) Proposition 4.1 is vacuous, consistent with A.

---

## 5. Depth two ($L=2$) with $c=1$

**Theorem 5.1 (partial memorization on the cube).** Let $H=1$, take the cube example, any $c>0$ and $n=\lceil\lambda M\rceil$. Put $\vartheta_c=1/(18dc+1)$ and $E_0=c(dF_d+1)+2$. For every width $N\ge72dn^3\ln(2M)+2$, on the event of Lemma 1.3, every $w\in\mathcal N_1$ satisfies

$$
L_D(z_w)\ge L_D(\operatorname{clip}z_w)\ge1+\frac{(\vartheta_cG-E_0)_+^2}{4MV},
$$

and the same holds for the limits of Gibbs and posterior-mean risks. For $c\le\mathrm{poly}(d)$ and $d\to\infty$ the right side equals $1+\gamma(\lambda)(18dc+1)^{-2}(1-o(1))$, where $\gamma(\lambda)=(1-e^{-\lambda})^2/(4\lambda)$; $\gamma(1)=0.0999$ and $\max\gamma=0.1018$ at $\lambda=1.256$.

*Proof.* Apply Lemma 2.1(2) to $r=\bar y\mathbf 1_T$ with $a=1/n$. Then $A_0^2=9dQ$, and $w_t$ computes $tg$ with $\kappa_N(w_t)\le dF_d+18dt^2Q$ and $\mathcal R(tg)\le(1-t)^2G+n(ta+a^2/4)\le(1-t)^2G+2$. Using $Q\le G$,

$$
cF_{c,S}(w_t)-W\le c\,dF_d+2+G\bigl[18dct^2+(1-t)^2\bigr].
$$

The bracket is minimized at $t=\vartheta_c$, where it equals $1-\vartheta_c$. Hence for $w\in\mathcal N_1$, $\mathcal R(z_w)\le c(F_{c,S}(w_{\vartheta_c})+1)-W\le(1-\vartheta_c)G+E_0$. Clipping does not increase $\mathcal R$. Lemma 1.2(b) and Lemma 1.3 (which give $G\approx(1-e^{-\lambda})M$ and $V\approx\lambda M$) yield the bound. The limits follow as in Theorem 2.2. ∎

**Corollary 5.2.** For every fixed $c>0$, and indeed every $c\le\mathrm{poly}(d)$, depth-two SP$_c$ violates the polynomial-sample agnostic inequality of BRIEF §1. Take the zero competitor and $\varepsilon_d=\gamma(\lambda)/(3(18dc+1)^2)$. Then $n=\lceil\lambda2^d\rceil$ eventually exceeds $p(d,1,1,1/\varepsilon_d,\log(1/\delta))$ for any polynomial $p$, while the excess is at least $2\varepsilon_d$ with probability $1-o(1)$. It does **not** refute the "$+o(1)$" formulation, since $\varepsilon_d\asymp1/\log^2n$. (`bounds_table.py`: the explicit bound is positive from $d\approx30$ on, about $2\cdot10^{-7}$; it is not quantitatively useful.)

**Proposition 5.3 (constant excess at depth two when $d=M$).** Let $d=M$ be a power of two and $a_1,\dots,a_M\in\{-1,1\}^d$ the rows of a Sylvester–Hadamard matrix, so $a_j\cdot a_k=M\delta_{jk}$. Let $x$ be uniform on $\{a_j\}$, let $y$ be a fair sign independent of $x$, and let $n=\lceil\lambda M\rceil$. For every width $N\ge1$ and every $c>0$, every $w\in\mathcal N_1$ satisfies

$$
\mathcal R(z_w)\le c(2\sqrt Q+1)+\frac{n}{9Q}.
$$

Hence, if $c=o(\sqrt M)$ (in particular $c=1$), near-minimizers, Gibbs predictors and posterior means all have excess at least $\beta(\lambda)-o(1)$ with probability $1-o(1)$.

*Proof.* Let $u=M^{-1}\sum_{j\in T}\bar y_ja_j$. Then $u\cdot a_k=\bar y_k\mathbf 1_T(k)$ and $\lVert u\rVert^2=Q/M$. Give all $N$ first-layer rows the value $(0,\epsilon u)$ and all readout weights the value $1/(N\epsilon)$. Then

$$
z(x)=\epsilon^{-1}\tanh(\epsilon u\cdot x),\qquad\kappa_N=d\epsilon^2\lVert u\rVert^2+\epsilon^{-2}=\epsilon^2Q+\epsilon^{-2},\qquad\lvert z(a_k)-\bar y_k\rvert\le\epsilon^2/3 .
$$

With $\epsilon^2=Q^{-1/2}$ this gives $\kappa_N=2\sqrt Q$ and $\mathcal R\le n/(9Q)$. Lemma 1.3 applies verbatim, because it uses only the atom structure, so $Q=\Theta(M)$. The argument of Theorem 2.2 then applies with test MSE $1+M^{-1}\sum_jz(a_j)^2$. ∎

This example has $n\asymp d$. It therefore does not contradict polynomial-in-$d$ sample bounds, but it does refute the user's dimension-free phrasing at $L=2$ with a constant excess.

**The positive side at $L=2$.** With $H=1$, Theorem 3.2 shows that $c=n^{1-\theta}$ works for every $\theta\in(0,1)$ (clipped) or $\theta\in(0,1/2)$ (unclipped). For fixed $c$ there is no positive argument. On the cube with the zero competitor, (3.1) gives excess at most $c/n+8\mathcal D\sqrt{(1+n/c)/n}+\dots\approx8\mathcal D/\sqrt c$. So at depth two the excess on the cube lies between $\Omega(1/(dc)^2)$ and $O(d/\sqrt c)$, and it vanishes once $c\gg d^2=\Theta(\log^2n)$. The depth-two threshold is $c^\star=\mathrm{polylog}(n)$, consistent with the formula $n^{1-1/H}$ at $H=1$.

**Numerics (§5.4; `memorize_opt.py`, Appendix A).** L-BFGS on $F_1$ at $\lambda=1$ gives an upper bound on $\min F_1$. By Lemma 1.2(b), this yields a lower bound on the noise captured by *every* near-minimizer for that sample. Write $\phi=1-c(F-W/c)/G$ for the captured fraction.

| $d$ | $L$ | $N$ | captured fraction $\phi$ | training residual $\mathcal R$ | $G$ | excess of found net (seen-atom part) |
|---|---|---|---|---|---|---|
| 8 | 2 | 256 | 0.40 | 35.2 | 154.8 | 0.206 (0.156) |
| 8 | 3 | 128 | 0.70 | 3.1 | 154.8 | 0.500 (0.367) |
| 10 | 2 | 512 | 0.58 | 69.6 | 634.1 | 0.289 (0.229) |
| 10 | 3 | 128 | 0.86 | 2.6 | 634.1 | 0.597 (0.422) |

At depth three the found networks essentially interpolate. Their excess exceeds the seen-atom ceiling $Q/M\approx0.47$ because they also predict nonzero values on unseen atoms. At depth two, the captured fraction rises with $d$, from 0.40 to 0.58. These are small-$d$ data, not a proof.

*Tempering sweep at $d=8$, same sample.* With $c=4$ the best networks found capture $\phi=0.025$ at $L=2$ (found excess $0.016$) and $\phi=0.002$ at $L=3$ (found excess $0.008$). With $c=16$ the optimizer returns the zero network at both depths. The $c=1$ memorizer at depth three ($\kappa=43.7$, $\mathcal R=3.1$) has $F_4-W/4=44.5>G/4=38.7$, so it is no longer competitive at $c=4$. Local optimization can miss partial memorizers, so these runs do not bound near-minimizers from above. At this tiny $n=256$ the transition sits between $c=1$ and $c=4$, below the asymptotic $n^{1-1/H}=16$; lower-order terms dominate at this size.

**Open.** Whether the depth-two, $c=1$ cube excess stays above a constant. It is governed by the cost ratio $\beta_d^{\rm eff}$, the least energy of a fit to $\bar y$ on $T$ divided by $G$. Lemma 3.1 gives $\beta^{\rm eff}_d\gtrsim\mathcal D^{-2}\approx1/(2d^2)$. Lemma 2.1 gives $\beta^{\rm eff}_d\le18d$ plus lower-order terms. Under the ansatz $\phi=1/(1+\beta^{\rm eff})$, the numerics suggest $\beta^{\rm eff}\approx1.5$ at $d=8$ and $\approx0.7$ at $d=10$. A constant excess at depth two would follow from $\beta^{\rm eff}_d=O(1)$. This is a question about the halfspace-variation norm of random sign functions, and I do not know its answer.

---

## 6. Which versions of the conjecture survive?

### 6.1 Versions that still fail

- **Deterministic labels:** fail, by A′ (Proposition 2.4).
- **Atomless inputs:** fail, by A′.
- **A test law that excludes the training inputs:** fails, by A′, because the training inputs form a null set.
  - On the cube itself, testing only on unseen atoms is **not** settled. At $d=8$ and $d=10$, the networks found numerically have conditional excess of about 0.37–0.46 at $L=3$ and 0.14–0.16 at $L=2$ on unseen atoms, so excluding the seen atoms does not obviously help.
- **High dimension with repeated inputs:** fails, by Proposition 5.3 ($d=M$, depth two).
- **Continuous high-dimensional inputs without near-duplicates:** **open**.
  - A heuristic: at depth two with $d\ge n$ and inputs uniform on $\{-1,1\}^d$, the linear memorizer $\epsilon^{-1}\tanh(\epsilon u\cdot x)$ costs energy of about $2\sqrt n$.
  - Its excess on fresh points is $\lVert u\rVert^2\approx n/d$: tempered at $d\asymp n$, benign at $d\gg n$.
  - Near-minimizers of $F_c$ need not be this network.

### 6.2 What is known

All citations below were verified.

- **Benign overfitting in linear regression.** Bartlett, Long, Lugosi, Tsigler, *Benign overfitting in linear regression*, PNAS 2020: minimum-norm linear interpolation is near-optimal if and only if two effective-rank conditions hold, which require many unimportant directions.
- **Kernel interpolation in fixed dimension.** Rakhlin & Zhai, *Consistency of interpolation with Laplace kernels is a high-dimensional phenomenon*, COLT 2019: inconsistent in fixed dimension, consistent when $d\asymp n$. Liang & Rakhlin (*Ann. Statist.* 2020) treat the high-dimensional regime.
- **Interpolating local estimators.** Belkin, Rakhlin, Tsybakov, *Does data interpolation contradict statistical optimality?*, AISTATS 2019: interpolating local estimators with singular kernels attain minimax rates in fixed dimension.
- **Spiky estimators.** Haas, Holzmüller, von Luxburg, Steinwart, *Mind the spikes*, NeurIPS 2023: benign overfitting in fixed dimension is possible if and only if the estimator's derivatives are large. Infinite-width ReLU networks do not overfit benignly, but spiky activations fix this.
- **Taxonomy.** Mallinar et al., *Benign, tempered, or catastrophic*, NeurIPS 2022: interpolating deep networks and kernels with power-law spectra are tempered.
- **Univariate ReLU, MSE.** Joshi, Vardi, Srebro, *Noisy interpolation learning with shallow univariate ReLU networks*, ICLR 2024: minimum-norm interpolation is tempered for $L_p$ losses with $p<2$ and **catastrophic for $L_2$**.
- **ReLU classification.** Kornowski, Yehudai, Shamir, NeurIPS 2023 (max-margin), and Frei, Chatterji, Bartlett, COLT 2022 (gradient-descent-trained networks on noisy linear data): tempered overfitting in dimension 1, benign in high dimension.

Every benign result needs a distributional condition: high effective dimension, inputs with no mass concentrated at the estimator's resolution, or deliberately spiky estimators. For the energy-regularized tanh learner, A′ shows that the decisive quantity is the test mass lying within distance $(L/K)^{L/2}\sqrt d$ (the inverse of Lemma 1.0's Lipschitz bound) of a training input whose residual is independent of the test residual. No distribution-free version of close conditioning can be benign.

### 6.3 Versions that survive (proved here)

1. **Tempered conditioning**, $c=n^{1-\theta}$ with $\theta<1/H$ (Corollary 3.3).
2. **Learner width tied to $n$** (Proposition 6.1 below). This is classical, and it holds for $c=1$.
3. **Hard tolerance matched to the sup-norm residual** of a small network (Proposition 4.1). Close conditioning in the literal sense, at the price of a constant factor and the sup norm.
4. **Conditioning on aggregate fit** (Remark 6.2).
5. **Clean labels** (the repository theorems).

**Proposition 6.1 (fixed polynomial learner width).** Fix $L=H+1\ge2$, $c>0$, a competitor $g$ with parameters $(m,B,U,E_*)$ as in Theorem 3.2, and a learner width $N\ge m$. Let $P_N=N(d+1)+(L-2)N^2+N$ and $K=E_*+1+n(U+1)^2/c$. With probability at least $1-\delta$, every $w\in\mathcal N_1$ at width $N$ satisfies

$$
L_D(\operatorname{clip}z_w)\le L_D(g)+\frac{c(E_*+1)}n+\frac8n+4\sqrt{\frac{P_N\ln\bigl(2+2n\sqrt{KN}\,H(d+N+1)(K+1)^{H/2}\bigr)+\ln(4/\delta)}{2n}}+(U+1)^2\sqrt{\frac{\ln(4/\delta)}{2n}}.
$$

In particular, take $c=1$, learner width $N=\lceil n^\alpha\rceil$, competitors of width at most $N$ with weights at most $n^\alpha$, and $d\le n^\alpha$. Then the excess is $O(n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\log n})$ for $L\ge3$, which is polynomially small for $\alpha<1/4$. This proves one precise version of the user's statement. The learner is the clean-label-scaled Bayesian learner ($c=1$, strong-prior limit) run at width $\lceil n^{\alpha}\rceil$, and the competitor class consists of depth-$L$ networks of width and weights at most $n^\alpha$. The Bayesian structure plays no role; the proof is parameter counting.

*Proof.* As in Theorem 3.2, near-minimizers lie in $\mathcal W_K=\{\kappa_N\le K\}$ and satisfy $\hat L(z_w)\le\hat L(g)+c(E_*+1)/n$. On $\mathcal W_K$, entries are bounded by $\sqrt{KN/d}$, $\sqrt K$ and $\sqrt{K/N}$, all at most $\sqrt{KN}$.

*Perturbation.* For $w\in\mathcal W_K$ and any $w'$ with $\lVert w-w'\rVert_\infty\le\delta'$, write $e_\ell=\lVert h^\ell-h'^\ell\rVert_2$. Then
$$
e_1\le\delta'(d+1)\sqrt N,\qquad e_\ell\le\sqrt Ke_{\ell-1}+\delta'N^{3/2},\qquad\text{output difference}\le\sqrt{K/N}\,e_H+\delta'N\le\delta'H(d+N+1)(K+1)^{H/2}.
$$

*Grid and union bound.* A grid of mesh $\delta'=1/\bigl(nH(d+N+1)(K+1)^{H/2}\bigr)$ on $[-\sqrt{KN},\sqrt{KN}]^{P_N}$ has the displayed log-cardinality, and it is chosen before seeing the data. Hoeffding's inequality plus a union bound over the grid, and the 4-Lipschitz clipped loss, give the uniform deviation. Finally use Hoeffding for $g$. ∎

Parameter counting cannot help once $N\gtrsim\sqrt n$, and A shows that the clean-label-scaled learner fails at $N\gtrsim d^2n$. For depth $\ge3$ the width transition therefore lies between $\sqrt n$ and $n\log^2n$.

**Remark 6.2 (conditioning on aggregate fit rather than on each output).** Let $\Pi^\tau_\sigma\propto\mu_\sigma\mathbf 1\{\hat L(z_w)<\tau\}$. If $\hat L(g)<\tau$, then the strong-prior limit concentrates on $\{\kappa_N\le E_*+\zeta\}$, by the argument of the proof of Cor. `exact`. Lemma 3.1 then gives

$$
L_D(\operatorname{clip}z_w)\le\tau+8\mathcal D\bigl((E_*+1)/H\bigr)^{H/2}n^{-1/2}+4\sqrt{\ln(2/\delta)/(2n)}.
$$

So conditioning on "fit as well as the best small network does in mean square" works, whereas conditioning on each output does not. The catch is that $\tau\approx\mathrm{OPT}$ must be supplied. A hyperprior over $\tau$ is not analysed here.

### 6.4 Still open

- Continuous high-dimensional inputs with a bounded density and close conditioning.
- Constant excess at depth two with $n$ superpolynomial in $d$.
- The unclipped window in D.
- E at $\gamma=1$.
- An oracle inequality for SP$_1$ with excess $O(\text{noise level})$ ("tempered") at arbitrary width.

---

## 7. What this means for the motivating scenario

The motivating scenario is a complex real input–output map, approximated by small networks.

1. **The literal conjecture is false in the regime that matters for wide Bayesian learners.** Take any learner that conditions closely on the training outputs: SP$_c$ with $c\ll n^{1-1/H}$, TUBE with $\rho$ below the residual level, or exact interpolation. At width beyond about $n$ it can lose roughly half of the irreducible error, $\beta(\lambda)\,\mathrm{Var}(y\mid x)$ with $\beta\le0.517$, relative to the trivial competitor. Two conditions trigger this:
   - test inputs (near-)coincide with training inputs, at the scale the learner can resolve;
   - the best small network's residual is noise-like there.

   Memorizing $s$ residuals costs energy only $\Theta(s^{1/H})$ up to factors polynomial in $d$ (upper bound: Lemma 2.1; lower bound: Remark 3.5). That is far below the $\Theta(s)$ of squared error it removes. At depth $\ge3$, any likelihood that is not strongly tempered therefore memorizes.
2. **The intuition "condition closely on outputs" is right for clean or realizable targets and wrong in the agnostic setting.** The repair is to make the effective energy budget $n/c$ smaller than the memorization cost. With $c=n^{1-\theta}$ and $\theta<1/H$, the strong-prior posterior competes with every width-$m$, weight-$B$ network at every learner width. Its rate is $\tilde O(\mathrm{poly}(d,m,B)\,n^{-1/(H+2)})$, and it can compete with networks of size $mB$ up to about $n^{1/(H(H+2))}$ (for $H\ge2$). This is the "fractional exponent" the user anticipated, though the exponents come from crude bounds.
3. **Deeper networks need more tempering.** The critical scaling $c^\star\approx n^{1-1/H}$ approaches $n$ as depth grows, because memorization gets cheaper. At depth two, $c^\star$ is only polylogarithmic.
4. **Fitting deterministic residuals is not always harmful.** Suppose the residual $y-g(x)$ of a small network is itself representable at width $\mathrm{poly}(n)$, with structure on scales the data resolve. Then fitting it is the right thing to do, since that residual is part of the comparator class. Harm comes only from residual components that look like noise to every network of polynomial size, at the resolution set by the learner's Lipschitz bound $(\kappa/L)^{L/2}/\sqrt d$. Examples are label noise, near-duplicate inputs with inconsistent labels, and chaotic or hash-like dependence (A′).
5. **If the residual of a small network is small in sup norm**, hard conditioning with a matched tolerance is safe: test MSE is at most $25\rho_0^2+\varepsilon$ (Proposition 4.1).
6. **If the learner's width is only a small power of $n$**, everything is classical (Proposition 6.1). Such a result cannot explain overparameterized learning.

---

## 8. Remarks on C and E

**C** is consistent with slt-likelihood §§3–4. I did not re-derive the aggregation constants. One requirement should be stated: exp-concavity of $(u-y)^2$ at $\eta\le1/8$ needs both predictions and labels in $[-1,1]$, so the progressive mixture must average **clipped** outputs. The failure at arbitrary width follows from the total-variation argument of slt-likelihood §3, which still applies with the clipped likelihood: it is bounded, continuous in the outputs, and positive at 0.

**E, negative direction for $\gamma>1$ (sketch).** Re-run the proof of Prop. `tube` around the memorizer $w_{\rm mem}$ of Lemma 2.1 instead of a teacher clone.

- *Constraint count.* The memorizer has $m_0$ groups in the first layer and a single group in every later layer. The cylinder therefore needs at most $N(d+m_0+H)$ scalar constraints, instead of the paper's $N[d+2+(L-2)C]$.
- *Error recursion.* It becomes
$$
e_1\le(d+1)\eta,\qquad e_2\le(\sqrt2\Gamma+b_0)e_1+\eta\sqrt{m_0},\qquad e_\ell\le(\Gamma+b_0)e_{\ell-1}+\eta\ \ (\ell\ge3),
$$
with output error at most $\Gamma e_H+\eta$.
- *Tube mass.* Translation costs $\tfrac12N^\gamma K_{\rm mem}$ for Gaussian coordinates. Hence
$$
-\ln\mu_{N,\gamma}\bigl(U_a(w_{\rm mem})\bigr)\le\tfrac12N^\gamma K_{\rm mem}+N(d+m_0+H)\ln\frac1{c_1\eta}+\ln2,
$$
which is at most $N^\gamma(\tfrac12K_{\rm mem}+1)+\ln 2$ once $N^{\gamma-1}\ge(d+m_0+H)\ln(1/(c_1\eta))$. Here $c_1=3/8$ is the paper's $c_m$ for Gaussian coordinates, and $\eta=\min\{1/2,a/P_{\rm mem}\}$ with $P_{\rm mem}=1+\Gamma(d+\sqrt{m_0}+H+1)(\sqrt2\Gamma+b_0)^{H-1}$. This is a polynomial width threshold for each fixed $\gamma>1$.
- *Posterior mass of non-memorizing networks.* With observation variance $cN^{-\gamma}$,
$$
\Pi(\mathcal R>\epsilon n)\le2\exp\Bigl(-N^\gamma\Bigl[\tfrac{(\epsilon-4a^2)n}{2c}-\tfrac{K_{\rm mem}}2-1\Bigr]\Bigr),
$$
and Lemma 1.2(a) gives Gibbs excess at least $(\sqrt\beta-\sqrt{\lambda\epsilon})^2-o(1)$.

*Status:* I re-derived the recursion and the constraint count, but did not re-check every constant of `tube` for a centre that is not a teacher clone. At $\gamma=1$ the cylinder cost is at least of order $N^\gamma m_0$, which exceeds the gain, so the question is **open**.

**E, positive direction for $\gamma>1$ (sketch).** The competitor tube $e^{-AN^\gamma}$ makes the posterior concentrate on $\{\hat L\le\hat L(g)+2(A+1)n^{-\theta}+2\rho(U+2)\}$ at every width.

- For $N\ge T(K,a)$, spectral truncation (`lem:spectral`) at $K\asymp n^\theta$ combined with Lemma 3.1 gives the analogue of Corollary 3.3.
- For $m\le N<T$, where $T\asymp(n^{\theta(L-2)}/a^2)^{1/(\gamma-1)}$, Proposition 6.1 applies if $T\le n^{1/2-\epsilon}$, that is, if $\theta<(\gamma-1)/(2(L-2))$.

*Status:* a sketch, not checked in detail. At $\gamma=1$ an agnostic version of the mean-field output cover is needed, and that is **open**.

---

## Appendix A. Numerical record

All scripts are in `../checks/red-team-and-literature/`.

**`constants.py`**

- $\beta(0.5,1,1.5,2)=0.345814,\ 0.484829,\ 0.517351,\ 0.498558$.
- $\arg\max_\lambda\beta=1.5029$, with maximum $0.517351$.
- Closed form at $\lambda=1$: $0.4848291$.
- Binomial values: $0.485030$ at $d=10$ and $0.484829$ at $d=20,30$.
- $\gamma(1)=0.09989$; $\arg\max_\lambda\gamma=1.2564$, with maximum $0.10182$.
- Parity check: $\min\lvert c_{k,a_d}\rvert2\sqrt{2k}=1.3372$.
- The exact sign coefficients agree with $\binom{2m}{m}/4^m$, and identity (4) holds exactly for $k=5$.

**`bounds_table.py`**

| Bound | $d$ | Excess lower bound |
|---|---|---|
| Theorem 2.2, $H=2$ | 20 / 30 / 40 / 50 | 0.046 / 0.419 / 0.474 / 0.483 |
| Theorem 2.2, $H=3$ | 20 / 30 / 40 | 0.064 / 0.444 / 0.4825 |
| Theorem 5.1 | 35 / 40 / 60 | $2.3\cdot10^{-7}$ / $1.9\cdot10^{-7}$ / $8.5\cdot10^{-8}$ |

**`memorize_opt.py` / `memorize_opt2.py`**

The runs are those in the §5 table, plus the $c\in\{4,16\}$ sweep at $d=8$. The $d=8$, $c=1$ runs used 3 restarts of up to 20000 L-BFGS iterations; the $d=10$ runs and the sweep used 1 restart of up to 6000 iterations. Since every reported objective value is an upper bound on $\min F_c$, the captured fractions are lower bounds on what every near-minimizer captures for that sample.

# Parity on a subcube: a target gradient descent can climb

Claude Opus 5.5 · 20 October 2026

**Work in progress.** This note asks whether some target is learned quickly by gradient descent although the $\gamma<1$ learners of main result 4 need exponentially many samples for it. It is the second note in this folder, after [Which targets are hard for the subcritical learners?](README.md), called the companion note below. Its arguments reuse lemmas of the [subcritical paper](../../main-results/subcritical-exponential/paper.pdf), cited by the LaTeX labels of its [source](../../main-results/subcritical-exponential/source/), together with short Boolean-function and learning-theory arguments. They have had independent AI-agent checks ([record](verification/subcube-parity/review.md)), but they are not Lean verified and have not been reviewed by a human. Literature statements were checked against abstracts and search summaries, not full texts. Questions [18](../../TECHNICAL-FAQ.md#18-for-gamma1-which-targets-need-exponentially-many-samples) and [20](../../TECHNICAL-FAQ.md#20-is-there-a-small-circuit-that-gradient-descent-learns-but-the-gamma1-learners-provably-cannot) of the technical FAQ give the interpretation.

## Summary

- **The target.** Let $d$ be odd, and add a selector bit $z$ to $x\in\lbrace -1,1\rbrace^d$, so that there are $D=d+1$ input bits:

  ```math
  f^*(x,z)=\begin{cases}
  \mathrm{sign}\left(x_1+x_1x_2+\cdots+x_1x_2\cdots x_d\right),&z=+1,\\
  x_1x_2\cdots x_d,&z=-1.
  \end{cases}
  ```

  On $z=+1$ it is the sign of a staircase, and on $z=-1$ it is full parity. For $t<d$, each prefix parity $`x_1\cdots x_t`$ has correlation $`m_1/2\approx(2\pi d)^{-1/2}`$ with $`f^*`$, and each extends the previous one by one coordinate. The last, $`x_1\cdots x_d`$, is the parity on the other half and has correlation $`(1+m_1)/2`$. Here $`m_1=\binom{d-1}{(d-1)/2}2^{1-d}`$. Since the sign-staircase is the majority of the prefix parities, $`f^*`$ has a Boolean circuit of $O(d)$ gates: a chain of XOR gates, a linear-size majority circuit and a selector.
- **The $`\gamma<1`$ learners need $`\exp(\Omega(d))`$ samples (proved).** Theorem A concerns every target that equals $\pm$ a parity of at least $`c_Rd`$ of the $`x`$-coordinates on one subcube $`\lbrace z=z_0\rbrace`$ of fixed codimension $k$, with arbitrary values elsewhere. For every $n\le e^{cd}$ and every fixed $\gamma<1$, with probability at least $3/4$ over uniform iid samples, at least $1/16$ of the subcube fails the strict-$`2/3`$ confidence criterion in the width limit. At $\gamma<0$, at least $3/8$ of the subcube fails even at threshold $13/20$. Labels off the subcube cannot help, and the proof's constant satisfies $c\gtrsim8^{-k}$. For $`f^*`$ (Corollary B), at least $1/32$ of all inputs fail, and at least $3/16$ at $\gamma<0$.
- **Two-head networks (proved).** Give the paper's network a shared trunk on $x$ and two readouts with equal variances, combined as $a\cdot h(x)+z\,b\cdot h(x)$. In the width limit its posterior then splits into independent posteriors on the two halves at $\gamma\le0$, and at $0<\gamma<1$ the large-deviation rate and the set of minimizing sign pairs split. Either way the parity half fails exactly as in main result 4 (Proposition C).
- **The gradient side.**
  - *A layerwise learner provably climbs $`f^*`$ (proved).* A greedy correlation-query procedure grows product units one coordinate at a time and trains two linear heads with the perceptron. It finds exactly the $d$ prefix parities from $O(d\log(d/\delta))$ samples, and its heads then reach expected error $\varepsilon$ from $(d+1)^2/\varepsilon$ more (Theorem E). It stalls on parity alone, and on the control target ctrl, which is $`x_1`$ on $z=+1$ and parity on $z=-1$. It is not gradient descent on a standard network.
  - *Adam learned $`f^*`$ on a two-head network at every dimension tested (numerical).* On a two-head ReLU network with three hidden layers of width 512 computed from $x$, Gaussian initialization, fresh samples and a held-out test set, the error on the parity half fell below $5\%$ after about $2.7$, $8.8$, $17$, $48$ and $76$ million samples at $d=19$, $23$, $27$, $31$ and $35$. The control's parity half was learned at $d=19$ and $23$, but not at $d=27$ within $40$ million samples or at $d=31$ within $60$ million. Parity alone on the same trunk, with one readout, was not learned at any of $d=19$, $23$, $27$ and $31$, within 20 to 60 million samples. There are one or two seeds per dimension, and this range cannot distinguish polynomial from exponential growth. On a plain MLP with $z$ as an input, the shape matched to Theorem A's prior, Adam with Gaussian initialization learned $`f^*`$ at $d=19$, after more samples than there are inputs, but not at $d=23$ or $27$ (Table 1b); with PyTorch's default initialization it did not at $d=31$, and its success at $d=21$ also came after more samples than there are inputs (Table 4).
  - *Open.* No theorem shows that end-to-end gradient descent on a standard architecture learns $`f^*`$ from polynomially many samples.
- **Answer.** On present evidence, yes, with a caveat about architecture. $`f^*`$ is provably exponentially hard for the three $\gamma<1$ learners, and provably polynomial for a simple layerwise learner. Adam learned it on a two-head network at every dimension tested; for that shape, Proposition C gives the Bayes side. On a plain MLP, the shape of Theorem A's learner, the evidence from $d=23$ on is negative. The gradient-descent half is numerical. Both halves of $`f^*`$ matter. A target close to a single parity, or one that restricts to a large parity almost everywhere, has little low-degree signal to climb (Section 4). Without a parity subcube, the distance route (Propositions 3, 4 and 4′ of the companion note) gives the sign-staircase and every symmetric target at most $\exp(O(\sqrt d\log d))$ at constant failure. Antiperiodic symmetric targets such as $(-1)^{\lfloor\mathrm{wt}(x)/2\rfloor}$ still reach $`\exp(\Omega_q(d))`$ through a tied random restriction (an audit conditional on main result 4), but sign-flip-equivariant gradient descent should fail on them (heuristic) (Section 5).

## Setting

**Learners.** The three $\gamma<1$ learners are those of the [companion note](README.md#setting-and-notation) and of the subcritical paper, applied to an ambient cube. Write $d'=d+k$ and $\mathcal X=\lbrace -1,1\rbrace^{d'}$, with points $w=(x,z)$, where $x\in\lbrace -1,1\rbrace^d$ and $z\in\lbrace -1,1\rbrace^k$, and put $M=2^{d'}$. The learner is the paper's network with input dimension $d'$, that is, the variances of `eq:weights` with $d'$ in place of $d$. Its kernel is

$$
K(w,w')=\Psi^{\circ(L-1)}\left(\frac{1+w\cdot w'}{d'+1}\right),\qquad
\Psi(t)=\frac2\pi\arcsin t,\qquad \beta=2^{-(L-1)}.
$$

- **$`\gamma<0`$:** $G\sim N(0,K)$ on $\mathcal X$, conditioned on $`f(W_i)G(W_i)>0`$ at the training inputs. $`q_S(w)`$ is the conditional probability that $f(w)G(w)>0$.
- **$`\gamma=0`$:** the same law, additionally conditioned on $\lvert G(w)\rvert>a$ at every $w\in\mathcal X$.
- **$`0<\gamma<1`$:** the posterior concentrates on the signs of the minimizers $v$ of $`\tfrac12\lVert v\rVert_K^2`$ subject to $\lvert v(w)\rvert\ge a$ at every input and $`f(W_i)v(W_i)\ge a`$ at the training inputs. Ties may receive any weights.

**Spectrum.** All spectral quantities refer to this kernel on the $`d'`$-cube.

- $`\lambda_j`$ is the normalized eigenvalue at degree $j$, so that $`\sum_U\lambda_{\lvert U\rvert}=1`$, and $`\lVert g\rVert_K^2=\sum_U\hat g(U)^2/\lambda_{\lvert U\rvert}`$.
- $`\tau_r=\sum_{\lvert U\rvert>r}\lambda_{\lvert U\rvert}`$, $`\ell_r=\lambda_{r+1}`$, and $`s_{2,r}=\sum_{j>r}\binom{d'}{j}\lambda_j^2`$.
- $`Q_r(w,w')=\sum_{\lvert U\rvert>r}\lambda_{\lvert U\rvert}\chi_U(w)\chi_U(w')`$ is the tail kernel, and $`Q_{r,SS}`$ is the $n\times n$ matrix $`(Q_r(W_i,W_j))`$, repeated points included.
- $`D'_r=\sum_{j\le r}\binom{d'}{j}`$, while $`D^{\rm loc}_r=\sum_{j\le r}\binom dj`$ counts the $`x`$-characters of degree at most $r$.

The facts (K1)–(K4) of the companion note hold on the $`d'`$-cube. The proofs below also cite the paper's spectral estimates `eq:level`, `eq:trace`, `eq:ratio`, `eq:secondmoment` and `eq:dimensionratios`.

**Functions.** Norms are $L^2$ of the uniform measure, and $`\lVert\cdot\rVert_1`$ is the $L^1$ norm. $`\Pi_{\le r}g=g_{\le r}`$ is the Walsh projection to degrees at most $r$, $`g_{>r}=g-g_{\le r}`$, and $`g_{(r,u]}=g_{\le u}-g_{\le r}`$. $`W^{<k}(f)=\sum_{\lvert S\rvert<k}\hat f(S)^2`$ is the Fourier weight below degree $k$. $x^{(j)}$ is $x$ with coordinate $j$ flipped, $`D_jP=(P-P(x^{(j)}))/2`$, and $`\Delta_R=\sum_{j\in R}D_j`$ for $R\subseteq[d]$. Also $\mathrm{clip}(t)=\max(-1,\min(1,t))$, and $`\mathrm{sign}_+`$ is the sign with $`\mathrm{sign}_+(0)=+1`$. $`\mathrm{err}_r(f)`$ is the least fraction of inputs on which a polynomial threshold function of degree at most $r$ disagrees with $f$, as in the companion note.

**Subcube and target class.** Fix $`z_0\in\lbrace -1,1\rbrace^k`$. For $g:\mathcal X\to\mathbb R$, the restriction is $`g^{(0)}(x)=g(x,z_0)`$, with $`\lVert g^{(0)}\rVert^2=\mathbb E_xg(x,z_0)^2`$ over the uniform $`d`$-cube. The class $`\mathcal F_{d,k}(c_R)`$ consists of all $f:\mathcal X\to\lbrace -1,1\rbrace$ such that, for some $`z_0`$, some $R\subseteq[d]$ with $`\lvert R\rvert\ge c_Rd`$, and some $\varepsilon\in\lbrace -1,1\rbrace$, $`f(x,z_0)=\varepsilon\chi_R(x)`$ for every $x$. The values of $f$ off the subcube are arbitrary. Fixing $k$ coordinates other than the last $k$ is the same problem, by permutation invariance of the prior. The target $`f^*`$ lies in $`\mathcal F_{d,1}(1)`$, with $`z_0=-1`$ and $R=[d]$.

**Sample.** $`S=(W_1,\ldots,W_n)`$ is iid uniform on $\mathcal X$, with $`W_i=(X_i,Z_i)`$. Each statement concerns one specified $n$, with probability over $S$; no single event for all $n$ is asserted. $`I_0=\lbrace i:Z_i=z_0\rbrace`$ indexes the training points on the subcube, and $`n_0=\lvert I_0\rvert\sim\mathrm{Bin}(n,2^{-k})`$.

**Failure measures.** $`q_{N,S}(w)`$ is the posterior probability of the correct label at width $N$, defined as in the paper, with the global margin condition.

- The **strict-$`2/3`$ confidence failure** is $`F_N(S)=\Pr_w\lbrace q_{N,S}(w)\le2/3\rbrace`$. On the subcube it is $`F^{(0)}_N(S)=\Pr_x\lbrace q_{N,S}(x,z_0)\le2/3\rbrace`$, and $`F_N\ge2^{-k}F^{(0)}_N`$.
- The **buffered failure** at $\gamma<0$ is $`F^{(0)}_\theta(S)=\Pr_x\lbrace q_S(x,z_0)\le\theta\rbrace`$ for the limiting posterior, with $\theta=13/20$. Since $13/20<2/3$ and $`q_{N,S}\to q_S`$ pointwise, $`\liminf_NF^{(0)}_N\ge F^{(0)}_{13/20}`$.
- The **Gibbs error** on the subcube is $`R^{(0)}_S=\mathbb E_x[1-q_S(x,z_0)]`$ at $\gamma=0$. At $0<\gamma<1$ the corresponding quantity is the subcube error $`\Pr_x[\mathrm{sign}\,v(x,z_0)\ne f(x,z_0)]`$ of each minimizer $v$.
- The **mixture inequality** of the paper's final section, $R\le(1-F)/3+F$, holds on the subcube as well: $F^{(0)}\ge(3R^{(0)}-1)/2$.

All limits are width first, at fixed $d$, $L$, $a$, $\gamma$ and training sample. No joint limit and no minimum width is asserted.

**Notation for $`f^*`$.** $`y_t=x_1\cdots x_t=\chi_{[t]}(x)`$ is the prefix parity of length $t$, $`S_d=\sum_{t\le d}y_t`$, and $`f_1=\mathrm{sign}\,S_d`$ is the sign-staircase. The map $x\mapsto y$ is a bijection of the cube, so the $`y_t`$ are iid uniform signs and $`f_1=\mathrm{MAJ}_d(y)`$. Put $`m_1=\binom{d-1}{(d-1)/2}2^{1-d}`$, the degree-one Fourier coefficient of $`\mathrm{MAJ}_d`$; then $`m_1^2\approx2/(\pi d)`$. The **control target** is $`\mathrm{ctrl}(x,z)=x_1`$ on $z=+1$ and $`x_1\cdots x_d`$ on $z=-1$. Constants $c,C$ depend only on $L$ unless stated otherwise, and may change from line to line.

## 1. Parity on a subcube is exponentially hard

**Theorem A (subcube theorem; proved).** Fix $L\ge2$, $a>0$, an integer $k\ge0$ and $`c_R\in(0,1]`$. There are $c>0$ and $`d_0`$, depending only on $`(L,a,k,c_R)`$, such that the following holds for every $`d\ge d_0`$, every integer $0\le n\le e^{cd}$, every $`f\in\mathcal F_{d,k}(c_R)`$, and every fixed $\gamma<1$:

$$
\mathbb P_S\Big\lbrace\liminf_{N\to\infty}F^{(0)}_N(S)\ge\tfrac1{16}\Big\rbrace\ge\tfrac34,
\qquad\text{hence}\qquad
\mathbb P_S\Big\lbrace\liminf_{N\to\infty}F_N(S)\ge2^{-k}/16\Big\rbrace\ge\tfrac34 .
$$

More precisely, each of the following holds with probability at least $3/4$:

- **(i) $`\gamma<0`$.** $`F^{(0)}_{13/20}(S)\ge3/8`$, hence $`\liminf_NF^{(0)}_N(S)\ge3/8`$. For $n<\exp((\log(d+1))^3)$ this holds for every training sample.
- **(ii) $`\gamma=0`$.** The subcube Gibbs error satisfies $`R^{(0)}_S\ge3/8`$.
- **(iii) $`0<\gamma<1`$.** Every minimum-energy solution has subcube error at least $3/8$, whatever weights the tied minimizers carry.

The conditioning probabilities are positive for all sufficiently large $N$, as in the paper.

**Corollary B ($`f^*`$; proved).** Apply Theorem A with $k=1$, $`z_0=-1`$, $R=[d]$, $`c_R=1`$ and $\varepsilon=+1$. There are $c=c(L,a)>0$ and $`d_0`$ such that, for every $`d\ge d_0`$, every $n\le e^{cd}$ and every fixed $\gamma<1$, with probability at least $3/4$ over iid uniform samples on the $d+1$ bits:

- at $\gamma<0$, $`F_{13/20}\ge3/16`$ and $`\liminf_NF_N\ge3/16`$, and both are at least $3/8$ on the parity half;
- at $0\le\gamma<1$, $`\liminf_NF_N\ge1/32`$, and $`\liminf_NF^{(0)}_N\ge1/16`$ on the parity half.

So all three $\gamma<1$ learners need $\exp(\Omega(d))$ samples on $`f^*`$. The learner here is the paper's fully connected network on all $d+1$ bits.

The companion note's route is weaker but holds for every training set. Restricting a threshold function to $z=-1$ gives $`\mathrm{err}_r(f^*)\ge\mathrm{err}_r(\chi_{[d]})/2`$, and the companion note's [Proposition 3](README.md#2-lower-bounds-for-the-sign-posteriors) then gives an $\exp(\Omega(\sqrt d\log d))$ bound at $\gamma<0$ on every training set. Theorem A(i) holds for every training set only when $n<\exp((\log(d+1))^3)$; parts (ii) and (iii) hold only with high probability over the sample.

The proof is the paper's proof, with every step that uses the target replaced by a subcube version. Section 1.1 lists those steps. Sections 1.2 and 1.3 give the replacement lemmas and the cutoff bookkeeping, Sections 1.4–1.6 run the three regimes, and Section 1.7 tracks the constants.

### 1.1 Where the target enters the paper's proof

Every use of the target in the paper's proof is one of the following. The list covers the width-limit, spectral, sampling, tail-Gram, adaptive-cutoff, conditioning, positive-exponent, zero-exponent and negative-exponent sections and the main file.

| | location in the paper | how the target is used | replacement here |
|---|---|---|---|
| T1 | `lem:parity-squared-balance`, population part | parity changes sign along every edge | L2: the same for $`\chi_R`$, applied to the restriction $P^{(0)}$ |
| T2 | `eq:wrong-square-coercivity`, via `lem:squared-sampling` with labels $`f(W_i)`$ | labels at all training points | L5: the sampling lemma on the subsample $`I_0`$ only, with the cutoff set by $n2^{-k-1}$ |
| T3 | `lem:clipped-parity` (`eq:laplacian-clip`, `eq:margin-clip`) | parity changes sign along every edge | L3: on the subcube, with $`\Delta_R`$ |
| T4 | `lem:ptf-parity` (Aspnes, Beigel, Furst, and Rudich) | parity is orthogonal to every polynomial of degree below $d$ | L4: on the subcube |
| T5 | `lem:small-cutoff`, and the small-sample parts of the three theorems | through T4, with a global $o(1)$ disagreement | the disagreement inside the subcube is at most $2^k$ times as large (L1) |
| T6 | training consistency, $`f(W_i)G(W_i)>0`$ or $`f(W_i)v(W_i)\ge a`$, in `thm:negative-all-n`, `thm:zero-endpoint` and `thm:positive-subcritical` | pointwise at the training points | used only at $`i\in I_0`$ |
| T7 | the final steps, $`\mathbb Ef\,\mathrm{clip}\ge1-2F_\theta-o(1)`$ and $R\ge3/8\Rightarrow F\ge1/16$ | error and confidence measured on the whole cube | measured on the subcube; global exceptional sets grow by at most $2^k$ (L1) |

The rest is **target-generic**: it uses the target only as "some labels". These parts are applied below on the $`d'`$-cube, with $d'$ in place of $d$:

- `prop:rate` and `prop:gp-limits`, for any orthant;
- the spectral and tail-Gram sections;
- `lem:adaptive-cutoff`, except that its cutoff is tied to the sampling threshold, so it is redone as Lemma 5;
- `lem:zero-denominator` and `lem:zero-bump`, which hold simultaneously for all labelings, and `lem:comparator`;
- `lem:zero-auxiliary` and `lem:zero-amplitude`, which hold for every event that implies the global margin;
- `lem:zero-quadratic`;
- `lem:negative-mean-confidence`, which holds for every sign pattern.

**Labels off the subcube.** The proof uses them only through three bounds that hold for every labeling:

- $`\lVert m\rVert_K^2\le n`$ for the posterior mean $m$ at $\gamma<0$;
- the bounds on the conditioning cost $\mathcal D(S)$ at $\gamma=0$;
- $`\lVert v\rVert_K^2\le C(d'+nd'^{\beta})`$ for every minimizer $v$ at $0<\gamma<1$.

So these labels cannot help on the subcube, however strongly they correlate with $`\chi_R`$. For $`f^*`$ they do correlate with parity: the staircase half contributes $`m_1/2\approx(2\pi d)^{-1/2}`$ to the coefficient of $`\chi_{[d]}`$. But every character $`\chi_R(x)\chi_T(z)`$ has degree at least $\lvert R\rvert$, which exceeds the cutoff $u$ used below. So this correlation sits in the high-degree tail, which the proof controls through the energy bounds alone.

*An illustration (numerical; heuristic, not a test of the theorem).* Kernel interpolation with the $L=2$ kernel on $d+1=12$ bits is a different predictor from the three learners, but it shows the same absence of transfer. Over 5 random training sets of each size, its sign error on the unseen inputs of the parity half is as follows ([`transfer_check.py`](verification/subcube-parity/transfer_check.py)).

| $n$ | 256 | 512 | 1024 | 2048 |
|---|---|---|---|---|
| $`f^*`$ | 0.550 | 0.589 | 0.651 | 0.804 |
| ctrl | 0.540 | 0.581 | 0.658 | 0.818 |
| parity on both halves | 0.542 | 0.585 | 0.657 | 0.794 |

### 1.2 Boolean lemmas on the subcube

**L1 (restriction).** For every $g:\mathcal X\to\mathbb R$, $\deg g^{(0)}\le\deg g$, and $`\mathbb E_x\phi(g(x,z_0))\le2^k\,\mathbb E_w\phi(g(w))`$ for every $\phi\ge0$. In particular $\lVert g^{(0)}\rVert^2\le2^k\lVert g\rVert^2$, and $`\Pr_x\lbrace(x,z_0)\in E\rbrace\le2^k\Pr_w(E)`$ for every event $E$.

*Proof.* Substitute $`z=z_0`$ in the multilinear expansion. The subcube has measure $2^{-k}$, so $`\mathbb E_w\phi(g)\ge2^{-k}\mathbb E_x\phi(g(x,z_0))`$. ∎

In L2–L4, $`\chi_R`$ is a parity on $\lbrace -1,1\rbrace^d$ with $\lvert R\rvert\ge1$. Since $`\Delta_R\chi_U=\lvert U\cap R\rvert\chi_U`$, $`\lVert\Delta_RP\rVert\le u\lVert P\rVert`$ whenever $\deg P\le u$.

**L2 (squared balance for $`\chi_R`$).** If $\deg P\le r$, then $`\mathbb E(\chi_RP)_-^2\ge\left(\tfrac12-\sqrt{r/\lvert R\rvert}\right)\lVert P\rVert^2`$.

*Proof.* This is the proof of `lem:parity-squared-balance`, averaging only over $j\in R$. Let $F(t)=t\lvert t\rvert$ and $j\in R$. Since $`\chi_R(x^{(j)})=-\chi_R(x)`$ and the uniform measure is flip-invariant,

$$
\mathbb E[\chi_RF(P)]=\tfrac12\,\mathbb E\,\chi_R(x)\big(F(P(x))-F(P(x^{(j)}))\big).
$$

By $\lvert F(a)-F(b)\rvert\le(\lvert a\rvert+\lvert b\rvert)\lvert a-b\rvert$ and Cauchy–Schwarz, its absolute value is at most $`2\lVert P\rVert\lVert D_jP\rVert`$. Average over $j\in R$ and use $`\sum_{j\in R}\lVert D_jP\rVert^2\le\sum_j\lVert D_jP\rVert^2\le r\lVert P\rVert^2`$. This gives $`\lvert\mathbb E[\chi_RF(P)]\rvert\le2\sqrt{r/\lvert R\rvert}\,\lVert P\rVert^2`$. Finally $`(\chi_RP)_-^2=(P^2-\chi_RF(P))/2`$. ∎

**L3 (clipped correlation for $`\chi_R`$).** For every real $P$ and every $b>0$,

$$
\lvert\mathbb E\,\chi_R\,\mathrm{clip}(P/b)\rvert\le\frac{\lVert\Delta_RP\rVert_1}{b\lvert R\rvert}.
$$

If $\deg P\le u$ and $\lvert P+t\rvert\ge b$ everywhere, then

$$
\lvert\mathbb E\,\chi_R\,\mathrm{sign}(P+t)\rvert\le\frac{u\lVert P\rVert}{b\lvert R\rvert}+\frac{\lVert t\rVert_1}{b}.
$$

*Proof.* Let $\mathcal R$ average $q(x^{(j)})$ over a uniformly random $j\in R$, and put $`q=\chi_RP`$. Then $\mathcal Rq=-q+e$ with $`e=(2/\lvert R\rvert)\chi_R\Delta_RP`$. The rest is the proof of `lem:clipped-parity`. Put $`E_\pm=\mathbb E\lvert q\pm b\rvert`$. Jensen's inequality and invariance of the measure give $`\mathbb E\lvert\mathcal Rq+b\rvert\le E_+`$, while the triangle inequality gives $`\mathbb E\lvert\mathcal Rq+b\rvert\ge E_--\lVert e\rVert_1`$. Replacing $b$ by $-b$ gives the opposite inequality, so $`\lvert E_+-E_-\rvert\le\lVert e\rVert_1=(2/\lvert R\rvert)\lVert\Delta_RP\rVert_1`$. Finally $\mathrm{clip}(q/b)=(\lvert q+b\rvert-\lvert q-b\rvert)/(2b)$, and $`\chi_R\,\mathrm{clip}(P/b)=\mathrm{clip}(q/b)`$ because clip is odd. For the second part, $\mathrm{sign}(P+t)=\mathrm{clip}((P+t)/b)$, clip is 1-Lipschitz, and $`\lVert\Delta_RP\rVert_1\le\lVert\Delta_RP\rVert\le u\lVert P\rVert`$. ∎

**L4 (ABFR for $`\chi_R`$).** For $0\le s<\lvert R\rvert$, every degree-$`s`$ polynomial threshold function on $\lbrace -1,1\rbrace^d$, with any fixed convention for zero ties, disagrees with $`\pm\chi_R`$ on at least a fraction $`2^{-\lvert R\rvert}\sum_{j\le(\lvert R\rvert-s-1)/2}\binom{\lvert R\rvert}{j}`$ of the cube. This tends to $1/2$ when $s=o(\sqrt{\lvert R\rvert})$.

*Proof.* Fix the coordinates outside $R$. The restricted threshold function has degree at most $s$ in $`x_R`$. Apply `lem:ptf-parity` on the cube of the coordinates in $R$; a sign $-1$ in front of $`\chi_R`$ is absorbed by reversing the tie convention. Average over the fixed coordinates. ∎

**L5 (subcube coercivity).** Let $`A_\delta`$ be the constant of `lem:squared-sampling` at accuracy $1/8$ and failure probability $\delta$. Let $`f\in\mathcal F_{d,k}(c_R)`$, let $r$ be odd with $r\le\lvert R\rvert/64$, and suppose that $`\tilde n:=n2^{-k-1}\ge A_\delta D^{\rm loc}_r\log(2D^{\rm loc}_r)`$. Then, with probability at least $1-\delta-e^{-n2^{-k}/8}$, $`n_0\ge\tilde n`$ and, for every polynomial $P$ on $\mathcal X$ of degree at most $r$,

$$
\frac1{n_0}\sum_{i\in I_0}\big(f(W_i)P(W_i)\big)_-^2\ \ge\ \tfrac14\lVert P^{(0)}\rVert^2 .
$$

*Proof.*

1. By Chernoff's bound, $`\Pr\lbrace n_0<n2^{-k}/2\rbrace\le e^{-n2^{-k}/8}`$.
2. Condition on the $`z`$-coordinates of the whole sample. This fixes $`I_0`$, and the points $`(X_i)_{i\in I_0}`$ are then iid uniform on $\lbrace -1,1\rbrace^d$.
3. Apply `lem:squared-sampling`, which holds for each specified sample size, at size $`n_0\ge\tilde n`$. Use the isotropic features $`\Phi(x)=(\chi_U(x))_{U\subseteq[d],\,\lvert U\rvert\le r}`$, which satisfy $`\lVert\Phi\rVert^2=D^{\rm loc}_r`$, and the labels $`Y=\varepsilon\chi_R(x)`$; the lemma allows labels that depend on the features. With conditional probability at least $1-\delta$, its uniform deviation is at most $1/8$.
4. On that event, homogeneity and L2, with $\tfrac12-\sqrt{r/\lvert R\rvert}\ge3/8$, give $`\frac1{n_0}\sum_{i\in I_0}(Y_i\langle\Phi(X_i),\xi\rangle)_-^2\ge(3/8-1/8)\lVert\xi\rVert^2`$ for every coefficient vector $\xi$.
5. Every $P$ of degree at most $r$ has $P^{(0)}=\langle\xi,\Phi\rangle$ for some $\xi$, by L1, and $`f(W_i)=\varepsilon\chi_R(X_i)`$ for $`i\in I_0`$. ∎

**L6 (evaluation through the energy; target-generic).** For every $g:\mathcal X\to\mathbb R$ and every $r$, $`\sum_{i\le n}g_{>r}(W_i)^2\le\lVert g\rVert_K^2\,\lVert Q_{r,SS}\rVert_{\rm op}`$, repeated points included.

*Proof.* With $`\langle g,h\rangle_Q=\sum_{\lvert U\rvert>r}\hat g(U)\hat h(U)/\lambda_{\lvert U\rvert}`$, the tail space reproduces: $`g_{>r}(w)=\langle g_{>r},Q_r(w,\cdot)\rangle_Q`$. For $\alpha\in\mathbb R^n$, Cauchy–Schwarz gives $`\sum_i\alpha_ig_{>r}(W_i)\le\lVert g_{>r}\rVert_Q\,(\alpha^{\mathsf T}Q_{r,SS}\alpha)^{1/2}`$. Take $`\alpha_i=g_{>r}(W_i)`$ and use $`\lVert g_{>r}\rVert_Q\le\lVert g\rVert_K`$. ∎

### 1.3 Spectral bookkeeping with a local cutoff

**Lemma 5 (target-generic).** Fix $A\ge1$, $\delta>0$, $k$, and $`0<\alpha\le\min(1/256,c_R/128)`$. Let

$$
c<\min\left\lbrace\tfrac12\alpha\log\tfrac1{2\alpha},\ \tfrac12\big(\log2-\mathsf h(1/4)\big),\ \tfrac1{25}\right\rbrace,
$$

where $\mathsf h$ is the binary entropy in natural units, as in `lem:gram-general`. There is $`d_0`$ such that the following holds for $`d\ge d_0`$ and $\exp((\log(d+1))^3)\le n\le e^{cd}$. Let $\tilde n=n2^{-k-1}$, and let $r$ be the largest odd integer with $`AD^{\rm loc}_r\log(2D^{\rm loc}_r)\le\tilde n`$. Put $\rho=r/(d+1)$, $H=\log(e/\rho)$ and $u=r+2\lceil10\log(d'+1)\rceil$. Then:

1. $(\log d)^2/4\le r\le\alpha d$, $u\le2r$, and $u+2\le(d+1)/8$.
2. $`n\ell_r/\tau_r\le C_L2^kAH`$.
3. $`nd's_{2,r}/\tau_r^2\le C_L2^kAH/\rho`$.
4. $`\tau_u\ge\tau_r/2`$ and $`n\ell_u\le d^{-10}\tau_r`$.
5. With probability at least $1-\delta$, $`\lVert Q_{r,SS}\rVert_{\rm op}\le b_r\tau_r`$, where $`b_r:=C_{L,\delta}\big[1+\sqrt{2^kAH/\rho}+2^kAH\big]`$.

*Proof.*

- *(1), lower end.* Let $`r_*`$ be the least odd integer at least $(\log d)^2/4$. Then $`AD^{\rm loc}_{r_*}\log(2D^{\rm loc}_{r_*})\le\exp\big((\log d)^3/4+O((\log d)^2)\big)`$, which is at most $2^{-k-1}e^{(\log(d+1))^3}\le\tilde n$ for $`d\ge d_0(k,A)`$. So $`r\ge r_*`$.
- *(1), upper end.* Let $r'$ be the least odd integer at least $\alpha d$. Then $`D^{\rm loc}_{r'}\ge(d/r')^{r'}\ge(2\alpha)^{-\alpha d}>e^{cd}\ge\tilde n`$, so $r<r'$ and $r\le\alpha d$. The other two claims follow from $r\ge(\log d)^2/4$ and $\alpha\le1/256$.
- *(2).* By maximality, $`\tilde n<AD^{\rm loc}_{r+2}\log(2D^{\rm loc}_{r+2})`$. On the $`d`$-cube, `eq:dimensionratios` gives $`D^{\rm loc}_{r+2}\le C\binom{d+1}{r+2}`$, and $`\log(2D^{\rm loc}_{r+2})\le CrH`$. Hence $n\le C2^kA\binom{d+1}{r+2}rH$. On the $`d'`$-cube, `eq:ratio` gives $`\ell_r/\tau_r\le C/(r\binom{d'+1}{r+2})`$, and $\binom{d+1}{r+2}\le\binom{d'+1}{r+2}$.
- *(3).* `eq:secondmoment` and `eq:trace` on the $`d'`$-cube give $`s_{2,r}/\tau_r^2\le Cr^{-2}/\binom{d'+1}{r+2}`$. Combine this with the bound on $n$ from (2) and with $d'/r\le2/\rho$, valid for $d\ge k$.
- *(4).* As in `lem:adaptive-cutoff`, $`\ell_u/\ell_r\le C_L4^{-(u-r)/2}\le C_L(d'+1)^{-13.8}`$. Hence $`n\ell_u\le C2^kAH(d+1)^{-13.8}\tau_r\le d^{-10}\tau_r`$ for $`d\ge d_0(k,A)`$. Also $`\tau_r-\tau_u\le C(u-r)r^{-1-\beta}`$ by `eq:level`, which is $`o(\tau_r)`$ by `eq:trace`.
- *(5).* Apply `lem:gram-general` on the $`d'`$-cube, with $q=2d'\log2$. In its notation:
  - $`q\eta_r/\tau_r\to0`$, since $r\ge(\log d)^2/4$ (`lem:far`);
  - $`\sqrt{nqs_{2,r}}/\tau_r\le C\sqrt{2^kAH/\rho}`$, by (3);
  - $`n\ell_r/\tau_r\le C2^kAH`$, by (2);
  - the near-pair and collision terms vanish, since $2c<\log2-\mathsf h(1/4)$.

  Choose the deviation level as in `lem:adaptive-cutoff`. ∎

The factors $2^k$ come only from $n=2^{k+1}\tilde n$. The change of dimension from $d$ to $d'$ in the binomial coefficients always helps, since $\binom{d+1}{j}\le\binom{d'+1}{j}$.

### 1.4 Proof of Theorem A(i): $`\gamma<0`$

The setup is the paper's. $G\sim N(0,K)$ on $\mathcal X$ is conditioned on $`f(W_i)G(W_i)>0`$ for all $i$, with posterior mean $m$ and residual variances $`\sigma_w^2=\mathrm{Var}(G(w)\mid G_S)`$. Take $\theta=13/20$ and $`c_\theta=\sqrt{2\pi}(1/e-7/20)`$. The target-generic `lem:negative-mean-confidence` gives, on $\mathcal X$:

- **(N1)** $`\lVert m\rVert_K^2\le n`$, and $`f(W_i)m(W_i)>0`$ at every training point;
- **(N2)** if $`q_S(w)>\theta`$ and $`\sigma_w>0`$, then $`f(w)m(w)>c_\theta\sigma_w`$;
- **(N3)** for every cutoff $s$, $`\Pr_w\lbrace\sigma_w^2<\tau_s/2\rbrace\le2n\ell_s/\tau_s`$ and $`\lVert m-\Pi_{\le s}m\rVert^2\le n\ell_s`$.

**Large samples, $`\exp((\log(d+1))^3)\le n\le e^{cd}`$.** Take $\delta=1/20$ and $`A=A_\delta`$, and use Lemma 5 and L5. The hypotheses of L5 hold by the choice of $r$ and by Lemma 5(1), since $`r\le\alpha d\le c_Rd/128`$. Their events hold together with probability at least $1-2\delta-e^{-n2^{-k}/8}\ge3/4$. Fix such a sample.

- *Head.* Let $`p=\Pi_{\le r}m`$. At each $`i\in I_0`$, (N1) gives $`(fp)_-\le\lvert m-p\rvert`$. By L5, L6 and (N1),

  $$
  \tfrac14\lVert p^{(0)}\rVert^2\le\frac1{n_0}\sum_{i\in I_0}(m-p)^2(W_i)\le\frac1{n_0}\sum_{i\le n}m_{>r}(W_i)^2\le\frac n{n_0}\,b_r\tau_r\le2^{k+1}b_r\tau_r .
  $$

- *Band.* The eigenvalues above degree $r$ are at most $`\ell_r`$, so $`\lVert m_{(r,u]}\rVert^2\le\ell_r\lVert m\rVert_K^2\le n\ell_r\le C2^kAH\tau_r`$. By L1, $`\lVert m_{(r,u]}^{(0)}\rVert^2\le C4^kAH\tau_r\le C2^kb_r\tau_r`$.
- *Low part.* So $`h=p+m_{(r,u]}=m_{\le u}`$ has degree at most $u$, and $`\lVert h^{(0)}\rVert^2\le C2^kb_r\tau_r`$.
- *Tail.* Let $`t=m-h=m_{>u}`$. By (N3) and Lemma 5(4), $`\lVert t\rVert^2\le n\ell_u\le d^{-10}\tau_r`$.
- *Exceptional inputs.* Let $`a_r=\tfrac12c_\theta\sqrt{\tau_u/2}`$ and

  $$
  X_{\rm bad}=\lbrace x:\sigma^2_{(x,z_0)}<\tau_u/2\rbrace\cup\lbrace x:\lvert t(x,z_0)\rvert>a_r\rbrace .
  $$

  By L1, (N3), Markov's inequality and Lemma 5(4), $`\Pr_x(X_{\rm bad})\le2^k\big[2n\ell_u/\tau_u+\lVert t\rVert^2/a_r^2\big]\le C2^kd^{-10}=:\eta`$. Training points have $\sigma=0$, so they lie in $`X_{\rm bad}`$. At $`x\notin X_{\rm bad}`$ with $`q_S(x,z_0)>\theta`$, (N2) gives $`fm>2a_r`$, hence $`fh>a_r`$, so $`f^{(0)}\mathrm{clip}(h^{(0)}/a_r)=1`$ there. Therefore

  $$
  \mathbb E_xf^{(0)}\mathrm{clip}(h^{(0)}/a_r)\ \ge\ 1-2F^{(0)}_\theta-2\eta .
  $$

- *Upper bound.* By L3, with $`\lvert R\rvert\ge c_Rd`$, $\deg h^{(0)}\le u\le2\rho(d+1)$ and $`\tau_u\ge\tau_r/2`$,

  $$
  \big\lvert\mathbb E_xf^{(0)}\mathrm{clip}(h^{(0)}/a_r)\big\rvert\le\frac{u\lVert h^{(0)}\rVert}{a_r\lvert R\rvert}\le\frac C{c_R}\,\rho\,2^{k/2}\sqrt{b_r}\le\frac C{c_R}\Big[2^{k/2}\rho+2^{3k/4}A^{1/4}\rho^{3/4}H^{1/4}+2^kA^{1/2}\rho H^{1/2}\Big]=:\Lambda_-(\rho).
  $$

  $`\Lambda_-`$ is increasing on $(0,1/e]$ and tends to $0$ as $\rho\to0$. Choose $\alpha$ with $`\Lambda_-(\alpha)\le1/8`$. Since $\rho\le\alpha$, this gives $`F^{(0)}_\theta\ge7/16-\eta\ge3/8`$.

**Small samples, $`1\le n<\exp((\log(d+1))^3)`$.** This case is deterministic in $S$. Take an odd $s\asymp d^{1/3}$. Then $`n\ell_s/\tau_s\le e^{(\log(d+1))^3}C/(s\binom{d'+1}{s+2})=o(1)`$, superpolynomially. Let $`p=\Pi_{\le s}m`$ and

$$
X_{\rm bad}=\lbrace\sigma^2<\tau_s/2\rbrace\cup\lbrace\lvert m-p\rvert\ge c_\theta\sqrt{\tau_s/2}\rbrace,
$$

both evaluated at $`(x,z_0)`$. By L1, (N3) and Markov's inequality, $`\Pr_x(X_{\rm bad})\le2^k(2+2/c_\theta^2)\,n\ell_s/\tau_s=o(1)`$. Outside $`X_{\rm bad}`$, $`q_S>\theta`$ implies $fp>0$, so $`f^{(0)}=\mathrm{sign}_+p^{(0)}`$ there. Since $`\deg p^{(0)}\le s=o(\sqrt{c_Rd})`$, L4 gives $`F^{(0)}_\theta\ge1/2-o(1)\ge3/8`$. For $n=0$, $`q_S\equiv1/2`$.

**Width.** By `prop:gp-limits` on $\mathcal X$, $`q_{N,S}\to q_S`$ pointwise. Since $13/20<2/3$, $`\liminf_NF^{(0)}_N\ge F^{(0)}_{13/20}`$. ∎

### 1.5 Proof of Theorem A(ii): $`\gamma=0`$

Write $`\mathcal E_S=\lbrace\lvert G(w)\rvert>a\ \forall w\in\mathcal X;\ f(W_i)G(W_i)>0\ \forall i\rbrace`$ for the margin-and-label event, $`\mathcal D=-\log\Pr(\mathcal E_S)`$ for the conditioning cost, and $`\mathbb E^*`$ for the posterior expectation. The relative entropy of the posterior from the prior is exactly $\mathcal D$. The following target-generic facts hold on $\mathcal X$, with $d'$ in place of $d$ and constants depending on $L$ and $a$:

- **(Z1)** `lem:zero-denominator`, for $1\le n\le e^{d'/25}$: with probability at least $1-e^{-cd'}$, simultaneously for all labelings and all odd $r\le d'/200$, $`\mathcal D\le C\lbrace d'^2+nd'^{1+\beta}\tau_r+D'_r\log(r+1)\rbrace`$ and $\mathcal D\le C(d'^2+nd'^{1+\beta})$.
- **(Z2)** `lem:zero-quadratic`, applied as in `eq:zero-tail-population` and `eq:zero-tail-empirical`, where $`\mathbb P_n`$ averages over the $n$ training points:
  - $`\mathbb E^*\lVert G_{>r}\rVert^2\le2\tau_r+4\ell_r\mathcal D`$;
  - $`\mathbb E^*\mathbb P_nG_{>r}^2\le2\tau_r+4\lVert Q_{r,SS}\rVert_{\rm op}\mathcal D/n`$;
  - $`\mathbb E^*\lVert G_{(r,u]}\rVert^2\le2\tau_r+4\ell_r\mathcal D`$;
  - $`\mathbb E^*\lVert G_{>u}\rVert^2\le2\tau_u+4\ell_u\mathcal D`$.
- **(Z3)** `lem:zero-amplitude`: if $\mathcal D\le e^{.045d'}$, then $`\mathbb E^*\Pr_w\lbrace\lvert G(w)\rvert\le A_d\rbrace\le C/d'`$, where $`A_d=b_0d'^{(1-\beta)/2}`$ and $`b_0>0`$ depends on $L$ and $a$.

**Large samples.** Take Lemma 5 with $\delta=1/20$ and $`A=A_\delta`$, and restrict to the events of L5, Lemma 5(5) and (Z1). Their joint probability is at least $1-2\delta-o(1)\ge3/4$.

- *Cost bound.* The characters $`\chi_U(x)\chi_T(z)`$ of degree at most $r$ number at most $`2^kD^{\rm loc}_r`$, so $`D'_r\le2^kD^{\rm loc}_r`$. Since also $`n\ge2^{k+1}AD^{\rm loc}_r\log(2D^{\rm loc}_r)`$, (Z1) gives

  $$
  \mathcal D/n\le C\lbrace d'^2/n+d'^{1+\beta}\tau_r+1\rbrace\le Cd\rho^{-\beta}.
  $$

  The rough bound gives $\mathcal D\le e^{.045d'}$, because $c<1/25$, so (Z3) applies.
- *Head.* Every posterior draw has $fG>0$ at the training points. For $`p=G_{\le r}`$ and $`i\in I_0`$ this gives $`(fp)_-\le\lvert G_{>r}\rvert`$. L5 holds on the sample event for every polynomial of degree at most $r$ at once, including $p$, so

  $$
  \lVert p^{(0)}\rVert^2\le(4n/n_0)\,\mathbb P_nG_{>r}^2\le2^{k+3}\,\mathbb P_nG_{>r}^2 .
  $$

  Taking $`\mathbb E^*`$ and using (Z2) and Lemma 5(5), $`\mathbb E^*\lVert p^{(0)}\rVert^2\le2^{k+3}(2\tau_r+4b_r\tau_r\mathcal D/n)`$.
- *Band and low part.* By L1, (Z2) and Lemma 5(2), $`\mathbb E^*\lVert G_{(r,u]}^{(0)}\rVert^2\le2^k(2\tau_r+C2^kAH\tau_r\mathcal D/n)`$. For $`h=G_{\le u}=p+G_{(r,u]}`$ this gives

  ```math
  \mathbb E^*\lVert h^{(0)}\rVert^2\le C2^k\tau_r(1+b_r\mathcal D/n)\le C2^k\tau_r\,d\rho^{-\beta}b_r .
  ```

- *Tail.* For $`t=G_{>u}`$, L1, (Z2) and Lemma 5(4) give $`\mathbb E^*\lVert t^{(0)}\rVert^2\le2^kC\tau_r(1+d^{-9}\rho^{-\beta})`$. Also $`\mathbb E^*\Pr_x\lbrace\lvert G(x,z_0)\rvert\le A_d\rbrace\le2^kC/d'`$, by L1 and (Z3).
- *Correlation bound.* For each draw, write $G^{(0)}=h^{(0)}+t^{(0)}$. Since $\lvert G\rvert>a$, $`\lvert\mathrm{sign}\,g-\mathrm{clip}(g/A_d)\rvert\le1_{\lvert g\rvert<A_d}`$ for $g=G^{(0)}$. Combine this with the first part of L3, the Lipschitz property of clip, and Jensen's inequality over the posterior:

  ```math
  \big\lvert\mathbb E^*\mathbb E_xf^{(0)}\mathrm{sign}\,G^{(0)}\big\rvert\le\frac{u}{c_RdA_d}\sqrt{\mathbb E^*\lVert h^{(0)}\rVert^2}+\frac{\sqrt{\mathbb E^*\lVert t^{(0)}\rVert^2}}{A_d}+\frac{2^kC}{d'} .
  ```

  - The first term, squared, is at most $`\frac C{c_R^2}2^k\rho^{2-2\beta}b_r`$, using $u\le2\rho(d+1)$, $`A_d^2=b_0^2d'^{1-\beta}`$ and $`\tau_r\asymp(\rho d)^{-\beta}`$. Expanding $`b_r`$,

    $$
    \frac C{c_R^2}2^k\rho^{2-2\beta}b_r\le\frac C{c_R^2}\big[2^k\rho^{2-2\beta}+2^{3k/2}A^{1/2}\rho^{3/2-2\beta}H^{1/2}+4^kA\rho^{2-2\beta}H\big]=:\Lambda_0(\rho).
    $$

    Since $\beta\le1/2$, every power of $\rho$ here is at least $1/2$, so $`\Lambda_0\to0`$ as $\rho\to0$, and it is increasing near $0$. Choose $\alpha$ with $`\Lambda_0(\alpha)\le1/64`$.
  - The second term is at most $C2^{k/2}\rho^{-\beta/2}d^{-1/2}=o(1)$, using $\rho\ge(\log d)^2/(4d)$.
  - The third term is $o(1)$.

  So the correlation is at most $1/4$. Since $G\ne0$, $`R^{(0)}=\big(1-\mathbb E^*\mathbb E_xf^{(0)}\mathrm{sign}\,G^{(0)}\big)/2\ge3/8`$.

**Small samples, $`1\le n<\exp((\log(d+1))^3)`$.** Here the rough bound gives $\mathcal D\le C(d'^2+nd'^{1+\beta})$. For an odd $s\asymp d^{1/3}$, $`\mathbb E^*\lVert G_{>s}\rVert^2\le2\tau_s+4\lambda_{s+1}\mathcal D=o(1)`$. If $`\mathrm{sign}\,G\ne\mathrm{sign}_+G_{\le s}`$, then $`\lvert G_{>s}\rvert\ge\lvert G\rvert>a`$. So by L1 the posterior-averaged disagreement on the subcube is at most $`2^k(2\tau_s+4\lambda_{s+1}\mathcal D)/a^2`$. Its part $`2^k\cdot2\tau_s/a^2`$ is only polynomially small, since $`\tau_s\asymp s^{-\beta}\asymp d^{-\beta/3}`$. It is $o(1)$ at fixed $k$, and Section 1.7 tracks it for growing $k$. L4 then gives $R^{(0)}\ge1/2-o(1)$. At $n=0$, symmetry gives $R^{(0)}=1/2$.

**Width.** By `prop:gp-limits`, the finite-width subcube Gibbs error converges to $R^{(0)}$. At each $N$, $`F^{(0)}_N\ge(3R^{(0)}_N-1)/2`$, so $`\liminf_NF^{(0)}_N\ge1/16`$. ∎

### 1.6 Proof of Theorem A(iii): $`0<\gamma<1`$

Apply `lem:comparator` on $\mathcal X$; for $n=0$, use the constant comparator $a$, with $`\lVert a\rVert_K^2=a^2/\lambda_0\le Ca^2d'`$. With probability at least $1-e^{-cd'}$, every minimizer $v$ then satisfies $`B:=\lVert v\rVert_K^2\le C(d'+nd'^{\beta})`$, simultaneously for all labelings, with $C$ depending on $L$ and $a$.

**Small samples.** For an odd $s\asymp d^{1/3}$, $`\lVert v-v_{\le s}\rVert^2\le\lambda_{s+1}B=o(1)`$, as in `lem:small-cutoff`. By L1 and $\lvert v\rvert\ge a$, the signs of $v^{(0)}$ and $`v_{\le s}^{(0)}`$ disagree on at most a fraction $2^k\,o(1)/a^2$ of the subcube. L4 gives subcube error at least $1/2-o(1)$.

**Large samples.** Here $B\le Cnd'^{\beta}$. Restrict to the events of L5, Lemma 5(5) and the comparator.

- *Head.* For $`P=v_{\le r}`$ and $`i\in I_0`$, $fv\ge a>0$ gives $`(fP)_-\le\lvert v-P\rvert`$. By L5 and L6,

  $$
  \lVert P^{(0)}\rVert^2\le\frac4{n_0}\,Bb_r\tau_r\le C2^kd'^{\beta}\tau_rb_r\le C2^k\rho^{-\beta}b_r .
  $$

- *Band.* $`\lVert v_{(r,u]}^{(0)}\rVert^2\le2^kB\ell_r\le C4^kAH\rho^{-\beta}`$.
- *Tail.* For $`t=v_{>u}`$, $`\lVert t^{(0)}\rVert^2\le2^kB\ell_u\le C2^kd^{-9}\to0`$.
- *Correlation bound.* Put $`h=v_{\le u}`$. The second part of L3 applies to $v^{(0)}=h^{(0)}+t^{(0)}$, because the global margin $\lvert v\rvert\ge a$ holds on the subcube:

  $$
  \lvert\mathbb E_xf^{(0)}\mathrm{sign}\,v^{(0)}\rvert\le\frac{u\lVert h^{(0)}\rVert}{a\lvert R\rvert}+\frac{\lVert t^{(0)}\rVert}a .
  $$

  The first term, squared, is at most

  $$
  \frac C{(ac_R)^2}\big[2^k\rho^{2-\beta}+2^{3k/2}A^{1/2}\rho^{3/2-\beta}H^{1/2}+4^kA\rho^{2-\beta}H\big]=:\Lambda_+(\rho).
  $$

  Choose $\alpha$ with $`\Lambda_+(\alpha)\le1/64`$. Then the correlation is at most $1/4$, and every minimizer has subcube error at least $3/8$.

**Width and ties.** By `prop:rate`, the finite-width posterior puts mass $1-o(1)$ on the minimizing sign patterns, whatever weights the ties carry. So the subcube Gibbs error is at least $3/8-o(1)$, and the mixture inequality gives $`\liminf_NF^{(0)}_N\ge1/16`$. ∎

In all three regimes the sample events fail with probability at most $2\delta+e^{-n2^{-k}/8}+e^{-cd'}<1/4$ for large $d$.

### 1.7 Constants, and the dependence on $`k`$

**Bookkeeping (proved for each fixed $k$; the explicit $`k`$-dependence below is proved conditional on every $o(1)$ term being uniform in $k$, which is asserted but not written out; constants unoptimized).** Choose $`\alpha=\alpha(L,a,k,c_R)\le\min(1/256,c_R/128)`$ with $`\Lambda_-(\alpha)\le1/8`$, $`\Lambda_0(\alpha)\le1/64`$ and $`\Lambda_+(\alpha)\le1/64`$. Then choose $c$ as in Lemma 5, and $`d_0`$ large. Every requirement on $d$ has one of these forms:

- $C2^k/d$, $C2^kd^{-10}$ or $C2^{k/2}d^{-1/4}$ is small;
- $C2^kAH(d+1)^{-13.8}\le d^{-10}$;
- $(\log d)^3\ge Ck$, and $\alpha d\ge(\log d)^2$;
- in the small-sample step at $\gamma=0$, $`2^k(2\tau_s+4\lambda_{s+1}\mathcal D)/a^2`$ is small. Since $`\tau_s\asymp d^{-\beta/3}`$ for $s\asymp d^{1/3}$, this needs $d\ge(C2^k)^{3/\beta}$.

So $`d_0\le C_{L,a,c_R}e^{C_Lk}`$. The binding constraint on $\alpha$ is the middle term of $`\Lambda_0`$ at $L=2$, where $\beta=1/2$: $`2^{3k/2}\rho^{1/2}H^{1/2}/c_R^2\le c`$, that is, $`\rho\log(e/\rho)\le c\,c_R^4\,8^{-k}`$. The constraints from $`\Lambda_-`$, about $`\rho\lesssim c_R^{4/3}2^{-k}`$, and from $`\Lambda_+`$, about $`\rho\lesssim(ac_R)^22^{-3k/2}`$, are weaker. Hence one can take $`\alpha\asymp c_R^4\,8^{-k}/(k+\log(e/c_R))`$ and $c\asymp\alpha\log(1/\alpha)$, so that $`c\ge c_{L,a}\,c_R^4\,8^{-k}`$. For $L\ge3$ the dependence is milder.

**Consequences.**

- For $k=O(1)$, the bound is $\exp(\Omega(d))$, as stated in Theorem A.
- For $k=\varepsilon\log d$, it is about $\exp(d^{1-O(\varepsilon)})$, but only for $\varepsilon$ below an $`L`$-dependent threshold, because $d\ge(C2^k)^{3/\beta}$ must hold. With $s\asymp d^{1/3}$ the threshold is $\beta/(3\ln2)$; enlarging $s$ raises it to about $\beta/(2\ln2)$.
- Linear $k$ is not covered.

The growing-$`k`$ statements are proved conditional on the bookkeeping being uniform in $k$. The bookkeeping asserts this, but does not write out every $o(1)$ term with its dependence on $k$.

The losses of $2^k$ are worst-case restriction losses: the tail energy at all $n$ training points may concentrate on the $`n_0\approx2^{-k}n`$ subcube points, and $\lVert g^{(0)}\rVert^2$ may be as large as $2^k\lVert g\rVert^2$. Section 6 records what a sharper treatment would need.

### 1.8 Numerical sanity checks

[`check_local.py`](verification/subcube-parity/check_local.py) ([output](verification/subcube-parity/check_local.txt)) guards against bookkeeping slips only. At these small $d$ it says nothing about the asymptotics.

- At $d=10$, $k=2$ and $`z_0=(-1,1)`$, for $\lvert R\rvert\in\lbrace10,7,6\rbrace$ and $r\le3$, the localized squared balance (L2) and clipped correlation (L3) hold exactly over the whole cube for 900 random restricted polynomials per $R$, including heavy-tailed ones. The squared-balance bound is non-vacuous only for $(\lvert R\rvert,r)\in\lbrace(10,1),(10,2),(7,1),(6,1)\rbrace$; for the other five pairs, $\tfrac12-\sqrt{r/\lvert R\rvert}\le0$. The smallest slack over all trials is $0.31$, and the clipped bound is never violated.
- On the exact $`(d+k)`$-cube kernel, computed in 120-digit arithmetic, $`r\binom{d+1}{r+2}\ell_r/\tau_r`$ lies in $[0.125,0.943]$ over odd $r\le(d+1)/8$, for $L\in\lbrace2,3\rbrace$, $d\in\lbrace24,48,72\rbrace$ and $k\in\lbrace0,1,3\rbrace$. Also $`D'_r\le2^kD^{\rm loc}_r`$ for every $r$, the eigenvalues sum to one, and they pair.
- The script's check that the two-head covariance of Section 2 vanishes across the halves is algebra, not an independent check: it builds the covariance with the factor $1+\zeta\zeta'$.

## 2. Two-head networks

**Proposition C (two-head posterior splits; proved, by adapting the proofs of `prop:rate` and `prop:gp-limits` to the two-head readout).** Let $h^{L-1}(x)$ be the trunk of the paper's network on $x\in\lbrace -1,1\rbrace^d$: tanh, the constant input coordinate, and the variances of `eq:weights`. Let the output be $`z_N(x,\zeta)=(W^L+\zeta V^L)\cdot h^{L-1}(x)`$ for $\zeta\in\lbrace -1,1\rbrace$, with $W^L$ and $V^L$ independent $N(0,N^{-\gamma-1}I)$. Condition on $`\lvert z_N\rvert>a`$ at all $2^{d+1}$ inputs and on the training signs, as in the paper. Write $`K_d`$ for the paper's kernel on $\lbrace -1,1\rbrace^d$ and $`E^{(a)}_K(g)=\min\lbrace\tfrac12v^{\mathsf T}K^{-1}v:g(x)v(x)\ge a\ \forall x\rbrace`$ for its energy (`eq:energy`). For every fixed $\gamma<1$:

- at $\gamma\le0$, the limiting posterior is a product over $\zeta=\pm1$, and its $\zeta=-1$ factor is $\sqrt2$ times the paper's limiting posterior for the $\zeta=-1$ training points: at margin $a/\sqrt2$ when $\gamma=0$, and with no margin when $\gamma<0$;
- at $0<\gamma<1$, the rate function and the set of minimizing sign pairs factorize, and the $\zeta=-1$ component of every minimizing pair minimizes the paper's energy problem at margin $a/\sqrt2$ on the $\zeta=-1$ data.

Hence, for every target $f$ whose $\zeta=-1$ half is $`\chi_{[d]}`$, whatever its values on $\zeta=+1$, there are $c>0$ and $`d_0`$, depending on $L$ and $a$, such that for $`d\ge d_0`$ and $n\le e^{cd}$,

$$
\mathbb P_S\Big\lbrace\liminf_{N\to\infty}F^{(-)}_N(S)\ge\tfrac1{16}\Big\rbrace\ge\tfrac34,
$$

where $`F^{(-)}_N`$ is the strict-$`2/3`$ failure fraction on the parity half. The failure fraction on all inputs is then at least $1/32$. This covers $`f^*`$, ctrl, and $`T_2`$ of Section 4.3 with the trunk on $(x,w)$.

*Proof.*

- *Conditional Gaussianity.* Given the hidden layers, $`U_\pm=W^L\pm V^L`$ are jointly Gaussian with $`\mathrm{Cov}(U_+,U_-)=\mathrm{Var}\,W^L-\mathrm{Var}\,V^L=0`$. So they are independent, each $N(0,2N^{-\gamma-1}I)$, and the two half-outputs $`U_\pm\cdot h^{L-1}`$ are conditionally independent, each $`N(0,2N^{-\gamma}Q^{L-1}_N)`$, where $`Q^{L-1}_N`$ is the trunk's empirical kernel. The proofs of `prop:rate` and `prop:gp-limits` use the trunk only through the freezing estimate `eq:freeze`, which is unchanged because the trunk sees only $x$, and the readout only through its conditional Gaussian law.
- *$`\gamma\le0`$.* `prop:gp-limits`, run on the $2^{d+1}$ inputs, gives the limit law $`N(0,2K_d)\otimes N(0,2K_d)`$, whose block-diagonal covariance is positive definite. The margin and sign events are products over the halves, so the limiting posterior is a product. Its $\zeta=-1$ factor is $\sqrt2\,G'$, where $`G'\sim N(0,K_d)`$ is conditioned on $\lvert G'\rvert>a/\sqrt2$ (at $\gamma=0$) and on the parity signs at the $\zeta=-1$ training points. This is the paper's limiting posterior at margin $a/\sqrt2$, and label probabilities are invariant under the scaling.
- *$`0<\gamma<1`$.* The coupling and large-deviation argument of `prop:rate` applies to the Gaussian on all $2^{d+1}$ inputs, near the block-diagonal limit. It gives the rate $`E^{(a)}_{2K_d}(g_+)+E^{(a)}_{2K_d}(g_-)`$, and $`E^{(a)}_{2K_d}=E^{(a/\sqrt2)}_{K_d}`$ by the substitution $v=\sqrt2\,v'$. The constraints separate, so the minimizing sign pairs form a product set. Posterior mass $1-o(1)$ on minimizing pairs gives mass $1-o(1)$ on pairs whose $\zeta=-1$ component minimizes the paper's problem at margin $a/\sqrt2$. A limiting posterior with tie weights is neither shown nor needed.
- *Sample.* The $\zeta=-1$ subsample has size $`n_-\sim\mathrm{Bin}(n,1/2)\le n\le e^{cd}`$, and given $`n_-`$ it is iid uniform on $\lbrace -1,1\rbrace^d$. The paper's `thm:negative-all-n`, `thm:zero-endpoint` and `thm:positive-subcritical` are statements about the limiting objects for each specified sample size, so they apply at size $`n_-`$, with constants at margin $a/\sqrt2$. With the two-head width limits above, each gives $`\liminf_NF^{(-)}_N\ge1/16`$ with probability at least $3/4$. Average over $`n_-`$. ∎

**Scope.**

- The factorization needs equal readout variances. If $\mathrm{Var}\,W^L\ne\mathrm{Var}\,V^L$, the cross-covariance is $`N(\mathrm{Var}\,W^L_i-\mathrm{Var}\,V^L_i)\,Q^{L-1}_N\ne0`$, and Proposition C says nothing. PyTorch's default initialization gives the two readouts equal variances, and so does the Gaussian initialization of Section 3.2. Halving both variances gives exactly the paper's posterior at margin $a$ on each half.
- Only the limit factorizes. At finite width the halves are coupled through the shared trunk, so `thm:main`, which concerns the paper's own network, is not applied directly; the width-limit results above are all that a $\liminf$ needs.
- This is a modified prior. Its width limit is two independent Gaussian processes, so its hardness is parity hardness inherited by the $\zeta=-1$ half. For the paper's fully connected prior on $d+1$ bits, Theorem A gives the hardness of $`f^*`$ directly.
- The match with the networks of Section 3.2 is in shape only: a shared trunk on $x$ and two heads selected by $z$. Those networks use ReLU rather than tanh, have biases, and are trained by Adam rather than sampled from a posterior.

**The neural tangent kernel splits too.**

- *Proved.* At initialization, the cross-half tangent kernel has zero mean: $`\mathbb E_{W,V}\Theta((x,+1),(x',-1))=0`$. Its readout part is $h(x)\cdot h(x')(1+(+1)(-1))=0$ identically, and its trunk part carries the factor $`\mathbb E[(W_i+V_i)(W_j-V_j)]=\delta_{ij}(\mathrm{Var}\,W-\mathrm{Var}\,V)=0`$.
- *Literature (abstract-level).* The output is $`f(x,\zeta)=o_1(x)+\zeta\,o_2(x)`$ for the two-output network $o=(W\cdot h,V\cdot h)$. In the NTK parametrization its limiting tangent kernel is $`\Theta\otimes I_2`$, by the multi-output form of the theorem of [Jacot, Gabriel, and Hongler (NeurIPS 2018)](https://arxiv.org/abs/1806.07572). So $`\Theta_f((x,\zeta),(x',\zeta'))=\Theta(x,x')(1+\zeta\zeta')`$, which vanishes across the halves, and in the kernel regime gradient descent treats the two halves independently.
- *Numerical.* For a tanh trunk with Gaussian weights in the standard parametrization, at $d=8$ with six inputs and one seed, the ratio of the mean absolute cross-half to within-half tangent kernel is $0.005$, $0.011$ and $0.0035$ at widths 256, 1024 and 4096 ([`twohead_decoupling.py`](verification/subcube-parity/twohead_decoupling.py)). The same script's estimate of the cross-half prior covariance at width 512 is $0.066$, against $0.70$ within a half. The exact value is zero, and $0.066$ is consistent with Monte Carlo error: the per-entry standard error at the script's 400 draws is about $0.04$.

**Reading (heuristic).** Neither the width-limit Bayesian learner nor kernel-regime gradient descent can carry the staircase features over to the parity head of this architecture. So the transfer seen in Section 3.2 presumably comes from feature learning in the shared trunk, which the width-first $\gamma<1$ limits freeze. This is an interpretation, not a theorem: the trained networks differ from the Bayesian learners in the ways listed under Scope.

## 3. Gradient descent on the staircase-or-parity target

### 3.1 A layerwise greedy learner

The learner below follows the mechanism of layerwise training on staircases ([Abbe, Boix-Adserà, Brennan, Bresler, and Nagaraj 2021](https://arxiv.org/abs/2108.10573)). It grows a trunk of product units, keeping a candidate unit when a correlation test says it is useful, and then trains linear heads. It is a correlation-query procedure over product units, not gradient descent on a standard network. At the population level each test is the gradient at zero of the correlation loss, or of the square loss since the units are orthonormal, with respect to the head weight of the candidate unit; on samples this holds only approximately.

**Lemma D (greedy staircase lemma; proved).** Let $f$ be a target on $\lbrace -1,1\rbrace^D$, let $I$ be a set of trunk coordinates, and let $H$ be a set of head characters on coordinates outside $I$, such as $H=\lbrace1,z\rbrace$. Suppose that, for some $\tau>0$ and sets $`U_1,\ldots,U_J\subseteq I`$:

- **(C1)** each $`U_j`$ is reachable from $\varnothing$ by single-coordinate steps $V\mapsto V\triangle\lbrace i\rbrace$ with $i\in I$, through sets $V$ with $`\max_{h\in H}\lvert\mathbb E[fh\chi_V]\rvert\ge2\tau`$;
- **(C2)** $f=\mathrm{sign}\,F$ with $`F=\sum_j\sum_{h\in H}w_{j,h}\,h\chi_{U_j}`$, $fF\ge1$ everywhere, and $\lVert w\rVert^2\le B^2$.

The algorithm has two stages.

- *Stage 1*, on $`n_1`$ samples. Start from $\Phi=\lbrace\varnothing\rbrace$. Add $U\triangle\lbrace i\rbrace$, for $U\in\Phi$ and $i\in I$, whenever $`\max_{h\in H}\lvert\hat{\mathbb E}[fh\chi_Ux_i]\rvert>\tau`$, and repeat until nothing changes.
- *Stage 2*, on $`n_2`$ fresh samples. Run the perceptron on the features $`\varphi=(h\chi_U)_{U\in\Phi,\,h\in H}`$, that is, stochastic gradient descent with step one on $\max(0,-y\langle\omega,\varphi\rangle)$, and output the hypothesis held at a uniformly random step.

If $`n_1\ge(8/\tau^2)\ln\big(2\lvert H\rvert\lvert I\rvert(1+4/\tau^2)/\delta\big)`$, then with probability at least $1-\delta$, $\Phi$ contains every $`U_j`$ and $\lvert\Phi\rvert\le1+4/\tau^2$. The output of Stage 2 then has expected test error at most $`B^2\lvert H\rvert\lvert\Phi\rvert/n_2`$.

*Proof.* Let $`\mathcal G=\lbrace U:\max_h\lvert\mathbb E[fh\chi_U]\rvert>\tau/2\rbrace`$. The functions $`h\chi_U`$ are distinct characters, so Parseval gives $\lvert\mathcal G\rvert\le4/\tau^2$. Let $\mathcal N=\lbrace U\triangle\lbrace i\rbrace:U\in\mathcal G\cup\lbrace\varnothing\rbrace,\ i\in I\rbrace$. It does not depend on the sample, and $\lvert\mathcal N\rvert\le\lvert I\rvert(1+4/\tau^2)$. Let $\mathcal E$ be the event that every estimate for $V\in\mathcal N$ and $h\in H$ is within $\tau/2$ of its mean. Hoeffding's inequality for $\pm1$ summands and a union bound over this fixed family give $`\Pr(\mathcal E^c)\le2\lvert H\rvert\lvert\mathcal N\rvert e^{-n_1\tau^2/8}\le\delta`$, so the adaptivity of Stage 1 needs no further care.

On $\mathcal E$, induction gives $\Phi\subseteq\mathcal G\cup\lbrace\varnothing\rbrace$: a newly added $V$ is a neighbour of some $U\in\Phi$, so $V\in\mathcal N$, and its estimate exceeds $\tau$, so its true value exceeds $\tau/2$. Also on $\mathcal E$, if a set on a path of (C1) lies in $\Phi$, then the next set on the path lies in $\mathcal N$ and has estimate at least $2\tau-\tau/2>\tau$, so it is added in a later sweep. Hence every $`U_j`$ is found.

In Stage 2, $\lVert\varphi\rVert^2=\lvert H\rvert\lvert\Phi\rvert$, and the vector $w$ of (C2), padded with zeros, has margin one and norm at most $B$. So the perceptron makes at most $B^2\lvert H\rvert\lvert\Phi\rvert$ mistakes. Each new sample is independent of the current hypothesis, so the expected error of the hypothesis at a uniformly random step is the expected number of mistakes divided by $`n_2`$. ∎

**Theorem E (the greedy learner climbs $`f^*`$; proved).** Let $d\ge7$ be odd, $`\tau=m_1/4`$, $I$ the $`x`$-coordinates, and $H=\lbrace1,z\rbrace$.

- With $`n_1=\lceil256(d-1)\ln(4d(1+128(d-1))/\delta)\rceil=O(d\log(d/\delta))`$ samples, with probability at least $1-\delta$ Stage 1 ends with exactly the trunk $`\lbrace\chi_{[t]}:0\le t\le d\rbrace`$, where $`\chi_{[0]}=1`$.
- The perceptron-trained heads, $a\cdot\varphi(x)+z\,b\cdot\varphi(x)$ on these units, then have expected error at most $`(d+1)^2/n_2`$. The running time is polynomial in $d$.
- On ctrl the same procedure ends with the trunk $`\lbrace1,x_1\rbrace`$, and its error on the $z=-1$ half is then at least $1/2$. On $`\chi_{[d]}`$ alone, with $H=\lbrace1\rbrace$, it ends with the trunk $\lbrace1\rbrace$.
- With $H=\lbrace1\rbrace$ and $`\tau=m_1/2`$, the same proof shows that the sign-staircase $`f_1`$ alone is learned, with the trunk $`\lbrace\chi_{[t]}\rbrace`$ and expected error at most $`d(d+1)/n_2`$, from $`n_1=O(d\log(d/\delta))`$ samples.

*Proof.*

- *Fourier facts.* $`f^*=\tfrac{1+z}2f_1+\tfrac{1-z}2\chi_{[d]}`$, and $`f_1=\mathrm{MAJ}_d(y)`$ with $`y_t=\chi_{[t]}`$. Hence $`\mathbb E[f^*\chi_{[t]}]=m_1/2+[t=d]/2`$ and $`\mathbb E[f^*z\chi_{[t]}]=m_1/2-[t=d]/2`$.
- *(C1)* holds along $[1]\subset[2]\subset\cdots\subset[d]$ with $`2\tau=m_1/2`$, since every chain set has $`\max_h\lvert\mathbb E[f^*h\chi_{[t]}]\rvert\ge m_1/2`$.
- *(C2).* On the chain, take head weights $`a^*=(1+e_d)/2`$ and $`b^*=(1-e_d)/2`$, where $`e_d`$ is the last unit vector. The value $`\tfrac{1+z}2\sum_{t<d}y_t+y_d`$ equals $`S_d`$ on $z=+1$, where $`\lvert S_d\rvert\ge1`$ because $d$ is odd, and equals $`y_d=\chi_{[d]}`$ on $z=-1$. So the margin is one, and $`B^2=\lVert a^*\rVert^2+\lVert b^*\rVert^2=(d+1)/2`$.
- *Exact trunk.* An $`x`$-set $U$ corresponds to a $`y`$-set $T$ with $`\chi_U(x)=\chi_T(y)`$. The Fourier coefficients of majority give $`\lvert\hat f_1(U)\rvert=m_1r_j`$ when $\lvert T\rvert=2j+1$, where $`r_j=\binom mj/\binom{2m}{2j}`$ and $m=(d-1)/2$; sets $T$ of even size have coefficient zero. The ratio $`r_{j+1}/r_j=(2j+1)/(2m-2j-1)`$ shows that $`r_j`$ is U-shaped, with $`r_0=r_m=1`$ and $`r_1=r_{m-1}=1/(d-2)`$. So $`r_j\le1/(d-2)`$ for $1\le j\le m-1$. For $U\ne[d]$, $`\max_h\lvert\mathbb E[f^*h\chi_U]\rvert=\lvert\hat f_1(U)\rvert/2`$, which exceeds $`\tau/2=m_1/8`$ exactly when $`r_j>1/4`$. For $d\ge7$, $1/(d-2)<1/4$, so $\mathcal G$ consists of the chain and of the set $\mathrm{Odd}=\lbrace1,3,\ldots,d\rbrace$, which corresponds to $T=[d]$. For $d\ge5$, $\mathrm{Odd}$ is not a neighbour of $\varnothing$ or of any chain set, so on $\mathcal E$ it is never tested, and $\Phi=\lbrace\varnothing\rbrace\cup\lbrace[1],\ldots,[d]\rbrace$.
- *Constants.* The bound $\binom{2m}m\ge4^m/(2\sqrt m)$ gives $`1/m_1^2\le4m=2(d-1)`$. With $\lvert H\rvert=2$ and $\lvert I\rvert=d$, the stated $`n_1`$ satisfies the condition of Lemma D. In Stage 2, $\lvert\Phi\rvert=d+1$, so the mistake bound is $B^2\lvert H\rvert\lvert\Phi\rvert=(d+1)^2$.
- *ctrl.* Its Fourier support is $\lbrace1\rbrace$, $\lbrace1,z\rbrace$, $[d]$ and $[d]\cup\lbrace z\rbrace$, all with coefficients $\pm1/2$. So $\mathcal G=\lbrace\lbrace1\rbrace,[d]\rbrace$, and $[d]$ is not a neighbour of $\varnothing$ or of $\lbrace1\rbrace$ when $d\ge3$; on $\mathcal E$, $\Phi=\lbrace\varnothing,\lbrace1\rbrace\rbrace$. Every function of $`x_1`$ agrees with $`\chi_{[d]}`$ on exactly half of the $z=-1$ half.
- *Parity alone.* Its only nonzero coefficient is at $[d]$, which is not a neighbour of $\varnothing$, so $\Phi=\lbrace\varnothing\rbrace$.
- *$`f_1`$ alone.* The chain coefficients are $`m_1=2\tau`$, and the rest is as for $`f^*`$, with value $`S_d`$, $B^2=d$ and $\lvert\Phi\rvert=d+1$. ∎

Exact Walsh transforms at $d=7,9,11,13$ confirm the chain coefficients, $\mathcal G$ and the margin of $`(a^*,b^*)`$ ([`walsh_checks.py`](verification/subcube-parity/walsh_checks.py)). The simulation below finds the trunk $\lbrace\varnothing,\lbrace1\rbrace\rbrace$ on ctrl at $d=31$ and 63; the trunk on parity alone was not checked numerically.

**Simulation (numerical).** With $\delta=0.1$, the stated $`n_1`$, and $`n_2=10(d+1)^2`$ ([`greedy_learner.py`](verification/subcube-parity/greedy_learner.py)):

- At $d=31$, on $`f^*`$, $`n_1=118{,}091`$, the trunk is $\varnothing$ and the 31 prefix sets, the perceptron makes 326 mistakes against the bound 1024, and the test error is $0.0086$, with $0.000$ on the parity half. On ctrl the trunk is $\lbrace\varnothing,\lbrace1\rbrace\rbrace$, and the parity-half error is $0.49$. On $`f_1`$ alone the test error is $0.0065$.
- At $d=63$, on $`f^*`$, $`n_1=266{,}830`$, the trunk is $\varnothing$ and the 63 prefix sets, there are 1068 mistakes against the bound 4096, and the test error is $0.0073$, with $0$ on the parity half. On ctrl the parity-half error is $0.505$.

The script reports the final perceptron hypothesis rather than one held at a uniformly random step, and it runs $`f_1`$ alone with $`\tau=m_1/4`$ and the $`n_1`$ of $`f^*`$; Lemma D still applies there, since the chain coefficients $`m_1`$ are at least $2\tau$. At $d=31$ the greedy learner used about $1.3\cdot10^5$ samples in all ($`n_1+n_2`$), against $4.8\cdot10^7$ for Adam to reach $5\%$ on the parity half, and $6.8\cdot10^7$ for both halves (Section 3.2).

### 3.2 Adam on standard networks

All results in this subsection are numerical.

**Setup.** Square loss; Adam with learning rate $10^{-3}$ and batch 512; a fresh uniform sample at every step. The held-out test set has 20,000 points, 10,000 on each half for two-half targets. Training points that coincide with a test point are resampled, so test points are never trained on. Errors are evaluated every 100 steps up to step 2000, then every 500 steps. *Samples to 5%* is the number of training samples at the first evaluation where the error is less than $0.05$; errors are computed in single precision, so an error of exactly $0.05$ does not count. A run stops once every tracked error (both halves, for two-half targets) has been less than $0.05$ at three consecutive evaluations, or at its budget. All numbers in this subsection are from [`numerics/results.md`](verification/subcube-parity/numerics/results.md). *Gaussian initialization* sets every weight to $N(0,1/\text{fan-in})$ and every bias to zero, readouts included.

- *Two-head network:* three hidden ReLU layers of width 512 computed from $x$ alone, and output $a\cdot h(x)+z\,b\cdot h(x)$ with two linear readouts.
- *Plain MLP:* the same three layers on all $d+1$ coordinates, with $z$ an ordinary input.
- *One-hidden-layer network:* width 1024, used for parity alone.

**Table 1. Three-layer trunk, Gaussian initialization.** Millions of samples until the error first fell below $5\%$; where two values are given they are seeds 1 and 2, otherwise seed 1. The last column uses the same trunk with a single readout; parity alone has no selector bit, so it has $2^d$ inputs.

| $d$ | inputs $2^{d+1}$ | $`f^*`$, parity half | $`f^*`$, staircase half | ctrl, parity half | parity alone, one readout |
|---|---|---|---|---|---|
| 19 | $1.05\cdot10^6$ | 2.82, 2.56 | 3.33, 3.33 | 9.98, 17.9 | not reached within 20 (error 0.498) |
| 23 | $1.68\cdot10^7$ | 9.47, 8.19 | 11.5, 10.5 | 18.9, 26.1 | not reached within 20 (error 0.499) |
| 27 | $2.68\cdot10^8$ | 16.6, 16.6 | 27.1, 24.1 | not reached within 40 (error 0.500) | not reached within 30 (error 0.499) |
| 31 | $4.29\cdot10^9$ | 48.1 | 67.6 | not reached within 60 (error 0.502) | not reached within 60 (error 0.502) |
| 35 | $6.87\cdot10^{10}$ | 75.5 | 105 | – | – |

- The budgets were 30, 50, 80, 80 and 220 million samples for $`f^*`$ at $d=19$, 23, 27, 31 and 35; 30, 40, 40 and 60 million for ctrl at $d=19$, 23, 27 and 31; and 20, 20, 30 and 60 million for parity alone at $d=19$, 23, 27 and 31. Every Gaussian-initialization run on $`f^*`$ in this table stopped early with both halves below $5\%$, as did the SGD run below. At $d=31$ the final errors were $0.008$ on the parity half and $0.044$ on the staircase half, after 69.9 million samples; at $d=35$ they were $0.0007$ and $0.048$, after 106.5 million.
- The control learned its $z=+1$ half ($`x_1`$) within 51,200 samples at every $d$. At $d=27$ and 31 its parity half was still at $0.50$ after 40 and 60 million samples.
- Parity alone on the same three-layer trunk, with a single readout, was not learned at any $d$ tested. At each of $d=19$, 23, 27 and 31 the parity half of $`f^*`$ fell below $5\%$ within that parity-alone budget, although only about half of its samples were on that half. On this trunk, parity was learned only as one half of a two-half target: at $d=19$ and 23 also as the parity half of ctrl, but at $d=27$ and 31 only as the parity half of $`f^*`$, next to the staircase half.
- The eight $`f^*`$ points fit a power law in $d$ (slope 5.5; root-mean-square residual 0.12 in $\log N$) somewhat better than an exponential in $d$ (a factor $e^{0.212}\approx1.24$ per dimension; residual 0.16). The range is too short to distinguish polynomial from exponential growth.
- At $d=19$ the number of samples exceeded the number of inputs. At $d=23$ it was about half of it for $`f^*`$, and more than all of it for ctrl. Test points were never trained on, but only at $d=27$, 31 and 35 was the parity-half threshold reached after a small fraction of the inputs: $6\%$, $1.1\%$ and $0.11\%$ of $2^{d+1}$, while the whole runs used 9 to $10\%$, $1.6\%$ and $0.15\%$. The small-$`d`$ rows say little about scaling.
- In the $d=31$ run, the parity half stayed near $0.50$ until about 39 million samples and fell to $0.04$ by 48 million. Meanwhile the network's correlations with the prefix parities $`x_1\cdots x_t`$, measured relative to the target's own, filled in from small $t$ upward, and the parity half dropped only after the long prefixes had appeared. The $d=35$ run behaved the same way: its parity half stayed near $0.50$ until about 63 million samples and fell below $5\%$ by 76 million. This matches the ladder mechanism of Section 3.1 (heuristic reading).
- SGD with momentum 0.9 and learning rate 0.05, in place of Adam, also learned $`f^*`$ at $d=19$: the parity half fell below $5\%$ after 6.4 million samples, against 2.6 to 2.8 million for Adam.
- With PyTorch's default initialization on the two-head trunk at $d=35$, the parity half fell below $5\%$ after 71.4 million samples, against 75.5 million with Gaussian initialization. The run reached its budget of 80 million with the staircase half at $0.070$.

**Table 1b. Plain MLP, Gaussian initialization, seed 1.** The same three layers on all $d+1$ coordinates, with $z$ an ordinary input. Millions of samples until the error first fell below $5\%$.

| $d$ | $`f^*`$, parity half | $`f^*`$, staircase half | budget |
|---|---|---|---|
| 19 | 3.33 | 3.33 | 30 |
| 23 | not reached (error 0.499) | 7.94 | 50 |
| 27 | not reached (error 0.500) | 19.2 | 60 |

With Gaussian initialization the plain MLP learned the staircase half at every $d$ but the parity half only at $d=19$, where the samples exceeded the number of inputs. The two-head trunk learned both halves at every $d$ in Table 1.

**Table 2. Parity alone on the one-hidden-layer network, Gaussian initialization, seed 1.**

| $d$ | samples to $5\%$ (millions) | budget (millions) |
|---|---|---|
| 19 | 2.30 | 30 |
| 23 | 3.84 | 30 |
| 27 | 16.4 | 30 |
| 31 | not reached (error 0.501; 0.499 in a second run with budget 150) | 30, 150 |

**Table 3. Parity alone at $`d=31`$ on the one-hidden-layer network: the initialization.** PyTorch's default draws weights and biases uniformly from $[-1/\sqrt{\text{fan-in}},1/\sqrt{\text{fan-in}}]$, which gives the weights variance $1/(3\,\text{fan-in})$. Seed 1 unless stated.

| weights | biases | samples to $5\%$ (millions) |
|---|---|---|
| PyTorch default (uniform) | PyTorch default (uniform) | 3.07 (seed 1), 3.33 (seed 2) |
| PyTorch default (uniform) | zero | 7.68 |
| Gaussian, variance $1/\text{fan-in}$ | zero | not reached within 30, nor within 150 |
| Gaussian, variance $1/\text{fan-in}$ | PyTorch default (uniform) | not reached within 30 |
| Gaussian, variance $1/(3\,\text{fan-in})$ | zero | not reached within 30 |
| Gaussian, variance $1/(3\,\text{fan-in})$ | PyTorch default (uniform) | not reached within 30 |

In these runs at $d=31$, the shape of the weight distribution, uniform or Gaussian, decided the outcome, not its variance or the biases. So at $d\le31$ the comparison of $`f^*`$ with parity alone depends on the initialization, as it does in the literature on high-degree parities (Section 5.3). These parity-alone runs use the one-hidden-layer network. On it, a second seed at $d=27$ reached $5\%$ after 5.89 million samples, and with PyTorch's default initialization parity alone was not learned at $d=35$ within 60 million samples (error $0.493$). On the three-layer trunk with one readout, parity alone was not learned at any $d$ tested (Table 1).

**Table 4. PyTorch default initialization, three hidden layers of width 512.** One run per row, the longest of its configuration; shorter runs with other seeds (plain MLP $`f^*`$, ctrl and sign-staircase at $d=31$) are listed in `results.md` and are consistent with these rows. Here the test set of 20,000 fresh points was not excluded from training. Each run was evaluated at 40 equally spaced points of its planned budget, so the sample counts are resolved to $1/40$ of that budget; some runs were stopped early.

| network | target | $d$ | samples to $5\%$ on the parity half (millions) | end of run: samples (millions); parity-half error |
|---|---|---|---|---|
| two-head | $`f^*`$ | 27 | 18.4 | 30.7; 0.006 (all inputs 0.020) |
| two-head | $`f^*`$ | 31 | 21.8 | 51.2; 0.005 (all inputs 0.013) |
| two-head | ctrl | 27 | not reached | 30.7; 0.495 |
| two-head | ctrl | 31 | not reached | 51.2; 0.495 |
| plain MLP | $`f^*`$ | 21 | 10.8 | 11.5; 0.003 |
| plain MLP | $`f^*`$ | 25 | not reached | 8.45; 0.499 (stopped early) |
| plain MLP | $`f^*`$ | 31 | not reached | 61.4; 0.504 (staircase half 0.030) |
| plain MLP | ctrl | 21 | 2.69 | 15.4; 0.001 |
| plain MLP | ctrl | 31 | not reached | 61.4; 0.504 |
| plain MLP | parity alone | 31 | not reached | 10.2; 0.504 (all inputs) |
| plain MLP | sign-staircase alone | 31 | 27.6 (all inputs) | 30.7; 0.041 (all inputs) |

- At $d=21$ the cube has $2^{22}\approx4.2\cdot10^6$ inputs. The threshold was reached after 2.6 times that many samples for $`f^*`$ and 0.64 times for ctrl, and the test set was not held out, so many test points had also been trained on. These rows say little about generalization.
- With the two-head shape, the default and Gaussian initializations gave $`f^*`$ thresholds of the same order at $d=27$ (18.4 and 16.6 million) and at $d=31$ (21.8 and 48.1 million).
- A one-hidden-layer network of width 1024 with $z$ as an input did not learn $`f^*`$ at $d=41$ within 20.5 million samples (parity-half error 0.500), and a network of the same size on the sign-staircase alone, with input $x$, reached only error 0.274 at $d=41$ within the same budget.
- The plain MLP did not learn $`f^*`$ at $d=31$ within 61 million samples, and with Gaussian initialization it did not learn the parity half at $d=23$ or 27 (Table 1b). It is the architecture matched to the paper's fully connected prior on $d+1$ bits, for which Theorem A gives the Bayes side. At that matched topology the gradient evidence from $d=23$ on is therefore negative. At the two-head topology, where Proposition C gives the Bayes side, Adam with Gaussian initialization succeeded at every dimension tested; with the default initialization it did at $d=27$ and 31, and at $d=35$ it learned the parity half but ended with the staircase half at $0.070$.

**Limits.** One or two seeds per configuration; $d\le35$; sample counts that cannot separate polynomial from exponential growth; and trained networks that differ from the Bayesian learners in activation, biases and training method.

### 3.3 Literature

The statements about published papers here are literature (abstract-level): they come from abstracts and search summaries, and no full text was read. The Fourier facts about $F$ below are proved, and the search negative is open.

- **Layerwise training of staircases.** [Abbe, Boix-Adserà, Brennan, Bresler, and Nagaraj (NeurIPS 2021)](https://arxiv.org/abs/2108.10573) prove that functions with the staircase property, in which high-order Fourier coefficients are reachable from lower-order ones along increasing chains, are learned in polynomial time by layerwise stochastic coordinate descent on "regular" networks. They report ResNet experiments with SGD. [Ren, Wang, and Lee (arXiv, July 2026)](https://arxiv.org/abs/2607.25200) show that logarithmic-depth networks trained by layerwise coordinate descent learn Boolean functions with hierarchically structured Fourier spectra, and that constant-depth networks of polynomial width cannot approximate a subclass. The real-valued variant $`F=\tfrac{1+z}2S_d/\sqrt d+\tfrac{1-z}2\chi_{[d]}`$, with $`\mathrm{sign}\,F=f^*`$, is a $`2d`$-sparse staircase with coefficient magnitudes in $[1/(2\sqrt d),1/2+1/(2\sqrt d)]$. So the 2021 theorem, as stated in its abstract, should apply to it; whether its quantitative hypotheses fit exactly, and its real-valued squared loss in place of sign labels, were not checked.
- **Changed input distributions.** Curriculum and mixed-input results learn high-degree parities efficiently, but train on inputs that are not iid uniform: [Abbe, Cornacchia, and Lotfi (NeurIPS 2023)](https://arxiv.org/abs/2306.16921), [Cornacchia and Mossel (ICML 2023, PMLR 202:6402–6423)](https://arxiv.org/abs/2301.13833), [Cornacchia, Mikulincer, and Mossel (COLT 2025, PMLR 291:1331–1365)](https://arxiv.org/abs/2502.06443), [Daniely and Malach (NeurIPS 2020)](https://proceedings.neurips.cc/paper/2020/hash/eaae5e04a259d09af85c108fe4d7dd0c-Abstract.html), and [Larue, Dufrène, Lampin, Ghauch, and Rekaya-Ben Othman (ICML 2026)](https://arxiv.org/abs/2605.28612). $`f^*`$ is a uniform-input analogue: the selector bit picks an easy component whose target shares the parity's features.
- **Intermediate supervision.** [Wies, Levine, and Shashua (ICLR 2023)](https://arxiv.org/abs/2204.02892) make bit-subset parity learnable by supervising parities of increasingly large subsets. [Kim and Suzuki (ICLR 2025)](https://arxiv.org/abs/2410.08633) show that a one-layer transformer learns parity efficiently with chain of thought. [Malach (ICML 2024)](https://arxiv.org/abs/2309.06979) shows that autoregressive predictors trained on chain-of-thought data are universal learners. [Tsilivis et al. (arXiv 2026)](https://arxiv.org/abs/2606.20937) study a simplified transformer that learns parity with chain of thought and then internalizes it. $`f^*`$ supplies much weaker supervision: one label bit, the sign of the sum of the prefix parities, on half of the cube.
- **Easy and hard instances mixed.** [Wang, Nichani, Bietti, Damian, Hsu, Lee, and Wu (COLT 2025)](https://arxiv.org/abs/2505.23683) prove an exponential statistical-query lower bound for $`k`$-fold composition trained on $`k`$-fold data alone, while gradient descent on a transformer of depth $O(\log k)$ learns it in $\mathrm{poly}(k)$ from an easy-to-hard curriculum or from a mixture of all levels. This is the closest structural analogue of $`f^*`$. Related: [Panigrahi, Liu, Malladi, Risteski, and Goel (ICLR 2025)](https://arxiv.org/abs/2410.05464), [Collins, Hassani, Soltanolkotabi, Mokhtari, and Shakkottai (ICML 2024, PMLR 235:9292–9345)](https://arxiv.org/abs/2307.06887), which includes a sparse-parity task family for shared-trunk multi-task learning, and the multitask sparse parity of [Michaud, Liu, Girit, and Tegmark (NeurIPS 2023)](https://arxiv.org/abs/2303.13506).
- **Initialization and alignment.** [Abbe, Cornacchia, Hązła, and Kougang-Yombi (ICLR 2025)](https://arxiv.org/abs/2412.04910) learn almost-full parities with Rademacher initialization (Section 5.3). [Shoshani and Shamir](https://arxiv.org/abs/2501.00817) prove that fixed large parities are hard for perturbed gradient descent on one-hidden-layer ReLU networks. [Abbe and Boix-Adserà (NeurIPS 2022)](https://arxiv.org/abs/2208.03113) characterize weak learnability by equivariant noisy gradient descent, and [Abbe, Cornacchia, Hązła, and Marquis (ICML 2022)](https://arxiv.org/abs/2202.12846) show that a noticeable initial alignment is needed. None of these excludes $`f^*`$, which has coefficients of order $d^{-1/2}$ at low degree and leap one (Section 4.2).
- **Universality.** With unrestricted architectures, SGD can emulate any polynomial-time learner ([Abbe and Sandon, NeurIPS 2020](https://proceedings.neurips.cc/paper_files/paper/2020/file/e7e8f8e5982b3298c8addedf6811d500-Paper.pdf); [Abbe, Kamath, Malach, Sandon, and Srebro, NeurIPS 2021](https://arxiv.org/abs/2108.04190)). So the question is meaningful only for natural architectures and initializations.
- **Search negative (open).** No theorem was found in which end-to-end SGD on a standard architecture, from a Gaussian initialization, on iid uniform cube inputs, learns a linear-degree staircase, $`\mathrm{sign}\,S_d`$, $`f^*`$, or any target that contains an exact parity of linear size on a subcube of constant measure. The merged-staircase result of [Abbe, Boix-Adserà, and Misiakiewicz (COLT 2022)](https://arxiv.org/abs/2202.08658) covers the staircase only at fixed support size. The positive results for almost-full parities start from $\pm1$ first-layer weights, possibly with Gaussian perturbations of size $O(1/d)$ (Section 5.3). A search negative is not proof of absence.

## 4. Why both halves are needed

### 4.1 Two obstructions

**Closeness to one parity (proved).** For every target $f$, every set $A$ and every $S\ne A$,

$$
\lvert\hat f(S)\rvert\le2\,\mathrm{dist}(f,\pm\chi_A),\qquad
\mathrm{dist}(f,\pm\chi_A)=\min_{\sigma=\pm1}\Pr[f\ne\sigma\chi_A].
$$

*Proof.* For $S\ne A$, $`\hat f(S)=\mathbb E[(f-\sigma\chi_A)\chi_S]`$, and $`\lvert f-\sigma\chi_A\rvert`$ takes values in $\lbrace0,2\rbrace$. ∎

Random trials at $D=10$ attain the bound ([`walsh_checks.py`](verification/subcube-parity/walsh_checks.py)). So a target within distance $\eta$ of a parity has every other coefficient, and in particular every rung of a staircase, at most $2\eta$.

**Restriction parities (proved).** Suppose a random restriction $\rho$, with values uniform given the set it fixes, leaves $`f\vert_\rho=\pm\chi_R`$ with $\lvert R\rvert\ge cd$ except with probability $\delta$. Then $\lvert\hat f(A)\rvert\le\delta$ for every $\lvert A\rvert<cd$, and $W^{<cd}(f)\le\delta$. The weight bound is tight.

*Proof.* Let $\Gamma$ be the set of free coordinates. Then $`\chi_A\vert_\rho=\pm\chi_{A\cap\Gamma}`$. On the good event, the average of $`\pm\chi_R\chi_{A\cap\Gamma}`$ over the free coordinates vanishes unless $A\cap\Gamma=R$, which needs $\lvert A\rvert\ge cd$. Since $`\lvert\chi_A\rvert\le1`$, $\lvert\hat f(A)\rvert\le\Pr(\text{bad})=\delta$. For the weight, $g=f^{<cd}$ restricts to a polynomial of degree below $cd\le\lvert R\rvert$, which is orthogonal to $`\chi_R`$ on the good event. So $\lVert g\rVert^2=\mathbb E[fg]$ is at most the bad event's contribution, which Cauchy–Schwarz bounds by $\sqrt\delta\,\lVert g\rVert$. ∎

Inner product mod 2 is at distance about $1/2$ from every parity, so the closeness bound says nothing about it. The restriction-parity bound does apply: fixing half of its coordinates leaves a parity.

**What this means for proofs (heuristic).** Bayes lower bounds argued from closeness to parity apply only to targets with little low-degree signal. A coupling argument transfers parity's hardness to a target within distance $\eta$ only while $n\lesssim1/\eta$: the training labels of the two targets then coincide with probability at least $1-n\eta$, and the posteriors depend only on the training labels. The restriction-parity extension suggested in the [companion note](README.md#6-superpolynomial-and-exponential-sample-sizes) needs $\delta=e^{-cd}$, and then $W^{<cd}(f)\le e^{-cd}$. That these routes cannot give a polynomial-versus-exponential separation is a heuristic about the routes, not a theorem.

### 4.2 How $`f^*`$ avoids them

**Facts (proved).**

- $`\mathrm{dist}(f,\pm\chi_A)=(1-\lvert\hat f(A)\rvert)/2`$, and the largest coefficient of $`f^*`$ is the one at $[d]$, equal to $`(1+m_1)/2`$. So $`f^*`$ is at distance at least $`(1-m_1)/4\approx1/4`$ from every parity, with equality for $`\chi_{[d]}`$.
- Fixing $z$ leaves a parity with probability exactly $1/2$, so the restriction-parity bound gives only $`W^{<cd}(f^*)\le1/2`$.
- In fact $`W^{<cd}(f^*)\ge(2\lceil cd\rceil-3)\,m_1^2/4\approx c/\pi`$. The sets $[t]$ and $[t]\cup\lbrace z\rbrace$ with $1\le t<d$ carry squared coefficient $`m_1^2/4`$ each, and $2\lceil cd\rceil-3$ of them have fewer than $cd$ elements. At $d=7$ and $cd=4$ the exact value is $0.1455$, against the bound $0.1221$.
- All low-degree weight of $`f^*`$ sits in $`\tfrac{1+z}2f_1`$. The part $`\tfrac{1-z}2\chi_{[d]}`$ has Fourier support $\lbrace[d],[d]\cup\lbrace z\rbrace\rbrace$ only.
- $`\mathrm{Leap}(f^*)=1`$, through the order $\lbrace1\rbrace,\lbrace1,z\rbrace,[2],[2]\cup\lbrace z\rbrace,\ldots$, while $\mathrm{Leap}(\mathrm{ctrl})=d-1$ and $`\mathrm{Leap}(\chi_{[d]})=d`$.

Exact Walsh transforms at $d=7,9,11,13$ confirm the distance $`(1-m_1)/4`$ from $`\chi_{[d]}`$ and the weight bound ([`walsh_checks.py`](verification/subcube-parity/walsh_checks.py)).

**Reading (heuristic).** The parity head needs only the top rung $`\chi_{[d]}`$, whose coefficients $`(1+m_1)/2`$ and $`-(1-m_1)/2`$ are large, and that rung is the last step of the staircase that the trunk builds for the other half. So $`f^*`$ offers signal of order $d^{-1/2}$ at every step and still equals a parity exactly on half of the cube. Conversely, any exponential lower bound for $`f^*`$ must be local to the parity half, as Theorem A is.

The control target has a larger initial alignment than $`f^*`$, coefficient $1/2$ on $`x_1`$ against $`m_1/2`$. Yet the greedy learner provably stalls on its parity half, and Adam did not learn that half at $d\ge27$ within budget, although it did at $d\le23$. So initial alignment is not sufficient. That the leap-one path to $[d]$ is what Adam uses is a heuristic reading.

### 4.3 Variants

**An exact sparse staircase, $`T_2`$ (proved).** Let $d=2^p$, let $w\in\lbrace -1,1\rbrace^p$ be address bits with a bijection $a(w)\in[d]$, and let there be $D=d+p+1$ input bits:

$$
T_2(x,w,z)=\begin{cases}
\chi_{[a(w)]}(x),&z=+1,\\
\chi_{[d]}(x)\,\chi_{[p]}(w),&z=-1.
\end{cases}
$$

- Let $\mathcal W$ be the set of address coordinates. The Fourier support of $`T_2`$ is $\lbrace B\cup[j],\ B\cup[j]\cup\lbrace z\rbrace:B\subseteq\mathcal W,\ j\in[d]\rbrace$. It has $2d^2$ elements, the coefficient magnitudes lie in $[1/(2d),1/2+1/(2d)]$, and it has the staircase property. Indeed, $`1[a(w)=j]=2^{-p}\sum_{B\subseteq\mathcal W}\pm\chi_B(w)`$, so the $z=+1$ part contributes $\pm1/(2d)$ to each $B\cup[j]$ and to its $`z`$-version, while the $z=-1$ part adds $\pm1/2$ to $[d]\cup\mathcal W$ and $[d]\cup\mathcal W\cup\lbrace z\rbrace$ only. The steps are $B\cup[j]\to B\cup[j-1]$, $B\cup\lbrace1\rbrace\to(B\setminus\lbrace b\rbrace)\cup\lbrace1\rbrace$, and dropping $z$.
- Lemma D with $\tau=1/(4d)$, the trunk on $(x,w)$ and $H=\lbrace1,z\rbrace$ recovers the whole support. $`T_2`$ equals its own Fourier expansion over the units found, so (C2) holds with $B=1$, and the perceptron makes at most $2(d^2+1)$ mistakes. So $`T_2`$ is learned from polynomially many samples.
- On the subcube $\lbrace z=-1\rbrace$, $`T_2`$ is the parity of all $d+p$ coordinates $(x,w)$. So Theorem A with $k=1$, and $(x,w)$ in place of $x$, shows that the three $\gamma<1$ learners need $\exp(\Omega(d))$ samples on it. Proposition C gives the same for the two-head prior with the trunk on $(x,w)$.
- Its spectrum is an exact sparse staircase, so the staircase theorem of Abbe et al. (2021) should apply to it directly (literature, abstract-level). $`T_2`$ is less natural than $`f^*`$ and was not tried with SGD.

Exact Walsh transforms at $d=4$ and $8$ confirm the sparsity, the range of magnitudes, the staircase property, and Parseval ([`walsh_checks.py`](verification/subcube-parity/walsh_checks.py)).

**A selector-free variant, $`g_\lambda`$ (proved, except where stated).** Let $d$ be odd, let $c$ be an odd integer near $\lambda\sqrt d$, and let $`g_\lambda=\mathrm{sign}\big(x_1+x_1x_2+\cdots+x_1\cdots x_{d-1}+c\,x_1\cdots x_d\big)`$. Put $`V=\sum_{t<d}y_t`$, and write $\varphi$ and $\bar\Phi$ for the standard normal density and upper tail.

- $`g_\lambda=\chi_{[d]}`$ on $\lbrace\lvert V\rvert<c\rbrace$, and $`\Pr[g_\lambda\ne\chi_{[d]}]=\Pr[\lvert V\rvert>c]/2\to\bar\Phi(\lambda)`$.
- The chain coefficients are $`\mathbb E[g_\lambda\chi_{[t]}]=q:=\binom{d-2}{(d-2+c)/2}2^{2-d}`$ for $t<d$, and $`\mathbb E[g_\lambda\chi_{[d]}]=\Pr[\lvert V\rvert<c]\ge q`$. By the local central limit theorem, $q\approx2\varphi(\lambda)/\sqrt d$. For $t<d$, $`\mathbb E[g_\lambda y_t]=\tfrac12\mathbb E[\mathrm{sign}(1+\nu)-\mathrm{sign}(\nu-1)]`$, where $`\nu=V-y_t+cy_d`$ is even, and this equals $\Pr[\nu=0]=q$.
- Lemma D with $\tau=q/2$ and $B^2=d-1+c^2$ learns $`g_\lambda`$ from $\mathrm{poly}(d)\,e^{O(\lambda^2)}$ samples, which is polynomial for $\lambda=O(\sqrt{\log d})$. At small $d$ and large $\lambda$ the greedy stage also adds a few degree-three $`y`$-sets; Parseval bounds their number, and the chain is always found.
- Bayes side: $`\mathrm{err}_r(g_\lambda)\ge\mathrm{err}_r(\chi_{[d]})-\Pr[g_\lambda\ne\chi_{[d]}]`$, so `lem:ptf-parity` gives $`\mathrm{err}_{c'\sqrt d}(g_\lambda)\ge\Phi(-c')-\bar\Phi(\lambda)-o(1)`$, which is positive for $c'<\lambda$. The companion note's Proposition 3 then gives an $\exp(\Omega(\sqrt d\log d))$ lower bound at $\gamma<0$ on every training set (proved, conditional on that proposition).
- Exponential hardness of $`g_\lambda`$ is open. The region where $`g_\lambda`$ is a parity is not a subcube, so Theorem A does not apply.

Exact Walsh transforms at $(d,c)=(11,3),(11,5),(15,5)$ confirm $q$, the top coefficient, and $`\Pr[g_\lambda\ne\chi_{[d]}]`$ ([`walsh_checks.py`](verification/subcube-parity/walsh_checks.py)). For $`g_\lambda`$ the two obstructions of Section 4.1 are visible together (heuristic). Its distance $\eta\approx\bar\Phi(\lambda)$ from parity makes the rungs $q\approx2\lambda\eta/\sqrt d$ small for large $\lambda$. The greedy stage needs about $d/(\lambda\eta)^2$ samples, while coupling transfers parity's hardness only while $n\lesssim1/\eta$.

### 4.4 Staircases and restriction parities

**The sign-staircase is not a restriction parity (proved).** For every fixed set of coordinates, with uniform values, the probability that the restriction of $`f_1`$ equals $\pm$ a parity of at least $`j_0`$ free coordinates is at most $`\sum_{j\ge j_0}\big[e^{-(j-1)/8}+2\exp(-((j-1)/4-1)^2/(2d))\big]`$. For $`j_0=cd`$ this is $e^{-\Omega(c^2d)}$ once $c^2d\gg\log d$, the opposite of the restriction-parity hypothesis.

*Proof.* Let the free coordinates be $`b_1<\cdots<b_K`$. The restriction is $`\mathrm{sign}(c_0+\sum_jc_jY_j)`$, with $`Y_j=x_{b_1}\cdots x_{b_j}`$ iid uniform and $`c_j=\sigma_j(1+V_j)`$, where $`\sigma_j`$ is a fixed sign and $`V_j`$ is a sum of the uniform signs in the $`j`$-th gap, independent across $j$. A threshold function of independent uniform $Y$'s equals $\pm$ a character only if the character is a single $`Y_j`$, so the free parity must be on a prefix $`\lbrace b_1,\ldots,b_j\rbrace`$, and $`\lvert c_j\rvert`$ must exceed $`\sum_{i<j}\lvert c_i\rvert`$. Each $`\lvert c_i\rvert\ge1`$ with probability at least $1/2$, independently. So Hoeffding's inequality gives $`\sum_{i<j}\lvert c_i\rvert>(j-1)/4`$ except with probability $e^{-(j-1)/8}$, and $`\Pr[\lvert c_j\rvert>(j-1)/4]\le2\exp(-((j-1)/4-1)^2/(2d))`$. Take a union bound over $j$. ∎

**Restriction parities have no low-degree structure (proved).** If fixing some set leaves $\pm$ a parity of at least $cd$ bits except with probability $e^{-cd}$, then $\lvert\mathbb E[fg]\rvert\le e^{-cd/2}\lVert g\rVert$ for every $g$ of degree below $cd$, $W^{<cd}(f)\le e^{-cd}$, and $\lvert\hat f(U)\rvert\le e^{-cd}$ for every $\lvert U\rvert<cd$. The last bound uses $`\lvert\mathbb E[fg]\rvert\le\Pr[\text{bad}]\,\lVert g\rVert_\infty`$ with $`g=\chi_U`$. That such targets are not friendly to gradient descent, in the leap or correlational sense, is heuristic. It concerns families of targets, and does not address training that exploits symmetry.

**Weighted and block staircases (proved).**

- For $`g_\omega=\mathrm{sign}(\sum_t\omega_ty_t)`$ without ties and any real weights, $`\mathrm{err}_r(g_\omega)\le\varepsilon`$ once $r\ge18\sqrt{d\log(4/\varepsilon)}$, by the smoothing lemma of Section 5.1. If $`\lvert\omega_t\rvert\in[1,M]`$, then $`g_\omega`$ is not a restriction parity: by the Erdős–Littlewood–Offord bound, it restricts to $\pm$ a parity of at least $cd$ bits with probability $e^{-\Omega(c^2d/M^2)}$. Also $`\mathrm{err}_{c\sqrt d}(g_\omega)\ge\kappa_M(c)-o(1)`$, where $`\kappa_M(c)>0`$ is defined like $\kappa(c)$ of Section 5.1 with the ratio $\sqrt{(1-\mu)/\mu}$ divided by $M$. Geometric weights $`\omega_t=\lambda^t`$ with $\lambda\ge2$ give exactly full parity, which is a restriction parity with $W^{<d}=0$.
- For block staircases $`\mathrm{sign}(\sum_{j\le K}Q_j)`$, with $`Q_j`$ the parity of the first $j$ blocks of size $b$ and $K$ odd: for constant $b$, the probability of restricting to $\pm$ a parity of at least $cd$ bits is $e^{-\Omega(c^2d/b)}$. For constant $K$, fixing blocks $2,\ldots,K$ leaves $\pm$ the parity of block 1 with probability one, but then every Fourier set is a union of whole blocks, so $W^{<d/K}=0$ and the leap is $d/K$.

So the staircase variants that become restriction parities have zero or exponentially small low-degree weight, and those with polynomially large low-degree weight are not restriction parities.

**Reading against the literature (heuristic).** Combined with the abstract-level characterization of [Abbe and Boix-Adserà (2022)](https://arxiv.org/abs/2208.03113), the weight bound suggests that fully connected equivariant noisy gradient descent can weakly learn a restriction parity with negligible $\delta$ only through a non-negligible Fourier coefficient at some degree at least $d-O(1)$. That is the almost-full-parity route. Its positive results use Rademacher initialization and survive Gaussian perturbations of size $O(1/d)$, while a Gaussian perturbation of large enough constant size prevents learning ([Abbe, Cornacchia, Hązła, and Kougang-Yombi 2025](https://arxiv.org/abs/2412.04910)). Some restriction parities do carry polynomially large weight near degree $d$, such as $`\chi_{[d]}\,h(x_A)`$ with $h$ having a non-negligible low-degree coefficient, for example $`\chi_{[d]\setminus\lbrace1\rbrace}`$. So this reading channels restriction-parity separations into the almost-full-parity route rather than excluding them.

## 5. Targets without a parity subcube

### 5.1 The sign-staircase alone

Here $`f_1=\mathrm{sign}\,S_d`$ with $d$ odd.

**Structure (proved).** For $1\le m\le d-1$, $`f_1=\chi_{[m]}\,\mathrm{sign}(\theta_m+V_m)`$. Here $`\theta_m=\sum_{t\le m}x_{t+1}\cdots x_m`$ is $1$ plus a sum of $m-1$ iid uniform signs depending on $`x_2,\ldots,x_m`$, and $`V_m=\sum_{t>m}x_{m+1}\cdots x_t`$ is a sum of $d-m$ iid uniform signs depending on $`x_{>m}`$. Indeed $`y_t=\chi_{[m]}\cdot x_{t+1}\cdots x_m`$ for $t\le m$ and $`y_t=\chi_{[m]}\cdot x_{m+1}\cdots x_t`$ for $t>m$, and prefix products of iid uniform signs are iid uniform. Also $`f_1=\chi_{[J]}`$, where $J$ is the least $t\ge1$ with $`\sum_{s=t+1}^dx_{t+1}\cdots x_s=0`$. Both identities were checked exhaustively for odd $d\le13$.

**Lower bound (proved).** For odd $d$, $1\le m\le d-1$ and odd $r<m$,

$$
\mathrm{err}_r(f_1)\ge\mathbb E_V\big[(e_r(m)-\mathrm{dist}_V)_+\big]\ge\frac12-\frac{r+3}{2\sqrt m}-\frac{2\sqrt m+1}{\sqrt{d-m}},
$$

where $`e_r(m)=2^{-m}\sum_{j\le\lfloor(m-r-1)/2\rfloor}\binom mj`$ is the bound of `lem:ptf-parity`, $`V=V_m`$, and $`\mathrm{dist}_V=\Pr_\theta[\mathrm{sign}(V+\theta)\ne\mathrm{sign}\,V]`$. With $m=cd/4$ this gives $`\mathrm{err}_{c\sqrt d}(f_1)\ge\tfrac12-2.1\sqrt c-O(1/\sqrt{cd})`$ for $c\le1/4$; the last term is large at practical $d$. Asymptotically, $`\mathrm{err}_{c\sqrt d}(f_1)\ge\kappa(c)-o(1)`$ for every $c>0$, with

$$
\kappa(c)=\sup_{0<\mu<1}\mathbb E_Z\Big[\Big(\Phi(-c/\sqrt\mu)-\bar\Phi\big(\lvert Z\rvert\sqrt{(1-\mu)/\mu}\big)\Big)_+\Big]>0,
$$

where $Z$ is standard normal; $\kappa(0.01)\approx0.429$ and $\kappa(0.1)\approx0.279$. At $d=6401$ the exact bounds are $`\mathrm{err}_7\ge0.293`$, $`\mathrm{err}_{39}\ge0.069`$ and $`\mathrm{err}_{79}\ge0.007`$.

*Proof.* Fix $`x_{>m}`$. The restriction $`\chi_{[m]}\mathrm{sign}(\theta+V)`$ is within Hamming distance $`\mathrm{dist}_V`$ of $`\mathrm{sign}(V)\chi_{[m]}`$. A polynomial of degree $r$ restricts to degree at most $r$, and $`\mathrm{err}_r`$ is 1-Lipschitz in Hamming distance. Apply `lem:ptf-parity` on the $m$ free bits and average over $V$. For the explicit form, $`\mathbb E\,\mathrm{dist}_V\le(2\mathbb E\lvert\theta\rvert+1)\max_j\Pr[V=j]\le(2\sqrt m+1)/\sqrt{d-m}`$, and $`e_r(m)\ge1/2-(r+3)/(2\sqrt m)`$. For $\kappa$, take $m=\mu d$ and use the central limit theorem for $(\theta,V)$. ∎

**Sample sizes (proved, via the companion note's Propositions 3, 4 and 4′).** Fix $c\in(0,1/4]$.

- At $\gamma<0$, every training set, iid, selected or with repeats, with $n\le\exp((c/3)\sqrt d\log d)$ has $`F_{13/20}(S)\ge\kappa(c)-o(1)`$, and the finite-width $\liminf$ obeys the same bound.
- At $\gamma=0$ and $0<\gamma<1$, with probability at least $1-e^{-c'd}$ over iid uniform samples with $n\le\exp((c/3)\sqrt d\log d)$, the Gibbs error is at least $\kappa(c)-o(1)$; at $0<\gamma<1$ every minimizer has this error. With $c=0.01$, $\kappa(c)>1/3$, so the mixture inequality gives confidence failure at least $0.14-o(1)$.

The hypotheses of the propositions hold: $r$, the largest odd integer at most $c\sqrt d$, satisfies $r\le(d+1)/8$, $\binom{d+1}{r+2}\ge\exp((c/2-o(1))\sqrt d\log d)$, and $n\le e^{d/25}$. So the sign-staircase needs $\exp(\Omega(\sqrt d\log d))$ samples in all three regimes.

**Prefix-parity smoothing lemma (proved).** For every $d$ and $\varepsilon\in(0,1)$ there are polynomials $`\Pi_1,\ldots,\Pi_d`$ of degree at most $18\sqrt{d\log(4/\varepsilon)}$ and a set $\mathcal G$ with $\Pr[\mathcal G]\ge1-\varepsilon$ such that $`\Pi_t=x_1\cdots x_t`$ on $\mathcal G$ for every $t$ at once. Hence $`\sum_t\Pi_t=S_d`$ on $\mathcal G$, and $`\mathrm{err}_r(f_1)\le4\exp(-r^2/(324d))`$ for every $r$.

*Proof.* Let $`J=\lceil\log_2d\rceil`$. By the binary expansion of $t$, split each prefix $[1,t]$ into at most one dyadic interval of each size $2^j$. For a dyadic interval $\mathcal I$ of size $2^j$, let $`\nu_{\mathcal I}`$ be the number of $-1$'s in $`x_{\mathcal I}`$, and let $`q_{\mathcal I}`$ interpolate $(-1)^{\nu}$ on the integers with $`\lvert\nu-2^{j-1}\rvert\le s_j`$, where $`s_j=\lceil\sqrt{2^{j-1}\log(4^{J-j+1}/\varepsilon)}\rceil`$; use $`\chi_{\mathcal I}`$ itself if the window covers $[0,2^j]$. Then $`\deg q_{\mathcal I}\le\min(2^j,2s_j)`$, and $`q_{\mathcal I}=\chi_{\mathcal I}`$ on the window. By Hoeffding's inequality a window fails with probability at most $2\varepsilon4^{-(J-j+1)}$, and there are at most $2^{J-j}$ intervals of size $2^j$, so all windows hold except with probability $\varepsilon$. Put $`\Pi_t=\prod_{\mathcal I}q_{\mathcal I}`$ over the decomposition of $[1,t]$. Its degree is at most $`\sum_j2s_j\le18\sqrt{d\log(4/\varepsilon)}`$, using $2^J<2d$ and Cauchy–Schwarz to combine the terms. ∎

Numerically, the worst ratio of the construction's degree to $\sqrt{d\log(4/\varepsilon)}$ is about $9.7$, at $d=2^j+1$ with $\varepsilon$ near 1, below the proved constant 18 ([`staircase/v3_smooth.py`](verification/subcube-parity/staircase/v3_smooth.py)).

**Ceiling (proved).** Through Propositions 3, 4 and 4′, the sign-staircase gets at most $\exp(O(\sqrt{d\log(1/\varepsilon)}\log d))$ samples at failure $\varepsilon$. At constant failure that is $\exp(\Theta(\sqrt d\log d))$, as for parity. No $\exp(\Omega(d))$ bound at constant failure, or at failure $e^{-o(d)}$, can come from $`\mathrm{err}_r`$, although exponentially small failure fractions do persist up to $\exp(\Omega(d))$ samples. Indeed $`\mathrm{err}_r(f_1)=\exp(-\Theta(r^2/d))`$ for $C\sqrt d\le r\le d/C$; the lower bound uses moderate-deviation tails of the binomial distribution. The same ceiling covers weighted and block staircases, low-degree threshold functions of prefix or interval parities, and staircases of products of gadgets of degree $b$, where the degree becomes $O(\sqrt{bd\log(1/\varepsilon)})$, and $O(j\sqrt{bd\log(1/\varepsilon)})$ for threshold functions of degree $j$ in those products.

**A soft clipped-correlation inequality (proved), and what is open.** For every $f$, every real $P$, every $b>0$ and every coordinate set $A$,

$$
\lvert\mathbb Ef\,\mathrm{clip}(P/b)\rvert\le\frac1{\lvert A\rvert}\sum_{j\in A}\frac{\lVert D_jP\rVert_1}{b}+\frac1{\lvert A\rvert}\sum_{j\in A}\big(1-\mathrm{Inf}_j(f)\big),
$$

where $`\mathrm{Inf}_j(f)=\Pr[f(x)\ne f(x^{(j)})]`$. For $`f_1`$, $`\mathrm{Inf}_j(f_1)\approx1-\tfrac2\pi\arcsin\sqrt{(j-1)/d}`$ (heuristic, from the arcsine law for the prefix walk), so taking $A$ to be the first $\mu d$ coordinates costs an additive $O(\sqrt\mu)$. The inequality is weaker than `lem:clipped-parity`: the sum over $j$ sits outside the $L^1$ norm, losing a factor of order $\sqrt{d/u}$, and there is an additive term. Whether the margin-sensitive lemmas, and with them an $\exp(\Omega(d))$ bound, adapt to $`f_1`$ is open.

**Open.** The true sample complexity of the three learners on $`f_1`$ lies between $\exp(\Omega(\sqrt d\log d))$ and $O(d\,2^d)$, the number of iid samples that covers the cube. That it is $\exp(\Theta(d))$, as for parity, is a guess by analogy (heuristic, low confidence). A polynomial threshold function of degree $\alpha d$ is a threshold of $2^{\Theta(d)}$ parities, so a proof that $`\mathrm{err}_{\alpha d}(f)\ge c`$ for an efficiently computable target would be an average-case lower bound against threshold-of-parity circuits with $2^{\Omega(d)}$ parity gates (heuristic remark; the literature on such bounds was not checked).

On the gradient side, Theorem E covers $`f_1`$ alone for the greedy learner (proved), and Adam on the plain MLP reached error $0.041$ at $d=31$ (Table 4; numerical).

### 5.2 Symmetric targets

**The distance route stops at $`\exp(O(\sqrt d\log d))`$ (proved).** Write $\mathrm{wt}(x)$ for the number of $-1$ coordinates of $x$, so that $\mathrm{wt}(x)\sim\mathrm{Bin}(d,1/2)$. Every symmetric target $`f(x)=h(\sum_ix_i)`$ satisfies

$$
\mathrm{err}_r(f)\le\Pr\big[\lvert\mathrm{wt}(x)-d/2\rvert\ge r/2\big]\le2\exp(-r^2/(2d)).
$$

*Proof.* The open interval $(d/2-r/2,d/2+r/2)$ contains at most $r$ Hamming levels, so $f$ changes sign at most $r-1$ times there. A univariate polynomial in $`\sum_ix_i`$ of degree at most $r-1$, with one root between each pair of adjacent levels where $f$ changes sign, matches $f$ on all those levels. Hoeffding's inequality bounds the rest. ∎

For $h$ with sign changes $q$ levels apart, such as $(-1)^{\lfloor\mathrm{wt}(x)/q\rfloor}$, $`\mathrm{err}_r\le2\exp(-q^2(r-1)^2/(2d))`$. So at constant failure $c$, Propositions 3, 4 and 4′ give at most $\exp(O(\sqrt{d\log(1/c)}\log d))$ samples for every symmetric target, and a factor $q$ less in the exponent for these. With linear $r$ the route still reaches exponential $n$, but only with failure fractions $2e^{-\Omega(d)}$.

**Antiperiodic targets: a tied random restriction (proved).** Let $f(x)=H(\mathrm{wt}(x)\bmod2q)$ with $H(i+q)=-H(i)$. Examples are $(-1)^{\lfloor\mathrm{wt}/q\rfloor}$ and, for $q=2$, the symmetric bent function $`(-1)^{\sigma_2}`$. Fix a block size $M$ with $`\eta:=1-\sum_i\min(\varpi_i,\varpi_{i+q})\le1/4`$, where $`\varpi_i=\Pr[\mathrm{Bin}(M,1/2)\equiv i\bmod2q]`$. Then $`\eta\le\big(\sum_{\ell\text{ odd}}\cos^{2M}(\pi\ell/2q)\big)^{1/2}\le\sqrt q\cos^M(\pi/2q)`$, so some $`M_q=O(q^2\log q)`$ works; the least admissible $M$ is $1,4,11,20,48,84$ for $q=1,2,3,4,6,8$.

Split $[d]$ into $m=\lfloor d/M\rfloor$ blocks and a leftover set. For each block draw independent $`(\mathsf u_b,\mathsf v_b)\in\lbrace -1,1\rbrace^M`$ with uniform marginals, coupled so that $`\mathrm{wt}(\mathsf u_b)-\mathrm{wt}(\mathsf v_b)\equiv q\pmod{2q}`$ with probability $1-\eta$. Draw the leftover coordinates uniformly. For $y\in\lbrace -1,1\rbrace^m$, let $`\iota_\rho(y)`$ equal $`\mathsf u_b`$ on block $b$ if $`y_b=1`$ and $`\mathsf v_b`$ if $`y_b=-1`$. Call block $b$ good if the coupling succeeded there, and let $`G_\rho`$ be the set of good blocks. Then:

- **(E1)** $`\iota_\rho(y)`$ is exactly uniform when $y$ is uniform;
- **(E2)** $`P\circ\iota_\rho`$ has $`y`$-degree at most $\deg P$;
- **(E3)** $`f\circ\iota_\rho(y)=\chi_{G_\rho}(y)\,g_\rho(y_{G_\rho^c})`$ for some function $`g_\rho`$;
- **(E4)** blocks are good independently with probability at least $3/4$, so $`\Pr[\lvert G_\rho\rvert<m/2]\le e^{-m/8}`$.

For $q=1$, $M=1$ and $\mathsf v=-\mathsf u$, which recovers the paper's setting with $`\lvert G_\rho\rvert=d`$.

**Generalized ABFR and margin lemmas (proved).** With $`m=\lfloor d/M_q\rfloor`$:

- $`\mathrm{err}_r(f)\ge\mathbb E_\rho\,e_{r}(\lvert G_\rho\rvert)\ge(1-e^{-m/8})\big(\tfrac12-(r+3)/\sqrt{2m}\big)`$, with $`e_r`$ as in Section 5.1;
- **(B)** for $\deg P\le r\le m/128$, $`\mathbb E(fP)_-^2\ge\tfrac38(1-e^{-m/20})\lVert P\rVert^2`$;
- **(C)** for $\deg P\le u$ and $b>0$, $\lvert\mathbb Ef\,\mathrm{clip}(P/b)\rvert\le2u\lVert P\rVert/(bm)+e^{-m/8}$; and if $\lvert P+t\rvert\ge b$ everywhere, $\lvert\mathbb Ef\,\mathrm{sign}(P+t)\rvert\le2u\lVert P\rVert/(bm)+\lVert t\rVert/b+e^{-m/8}$.

These are the paper's lemmas with $d$ replaced by $m$, up to exponentially small terms. Every flip of a good block negates $`f\circ\iota_\rho`$, and that is all the paper's proofs use. In (B) the bad event is controlled through exact uniformity of $`\iota_\rho(y)`$ and Bonami's hypercontractive inequality.

**Extension of main result 4 (an audit of the target-dependent steps, not a written-out proof; conditional on main result 4).** For each fixed $q\ge1$, $L\ge2$ and $a>0$ there are $`c_q>0`$ and $`d_q`$ such that, for $`d\ge d_q`$, every antiperiodic $f=H(\mathrm{wt}\bmod2q)$, every $`n\le e^{c_qd}`$ and every fixed $\gamma<1$, $`\Pr_S\lbrace\liminf_NF_N(S)\ge1/16\rbrace\ge3/4`$, and at $\gamma<0$ also $`\Pr_S\lbrace F_{13/20}\ge3/8\rbrace\ge3/4`$. The audit reruns main result 4's proof with the three replacement lemmas, a cutoff fraction $`\alpha\le c\min(M_q^{-4},1/(128M_q))`$ up to logarithms, and a sampling deviation below $1/8$. It checks that the target enters only through `lem:ptf-parity`, the population part of `lem:parity-squared-balance`, `lem:clipped-parity` and training consistency, and that everything else holds for every labeling. The transferred proof has not been written out, and the rate $`c_q\approx q^{-8}/\mathrm{polylog}(q)`$ is unoptimized bookkeeping (heuristic). A target that agrees with such an $f$ outside a set of measure $e^{-c'd}$ inherits the conclusions with the failure fractions reduced by $e^{-c'd}$ and the probability $3/4$ reduced by $ne^{-c'd}\le e^{-c'd/2}$, for $`n\le\min(e^{c'd/2},e^{c_qd})`$.

**Gradient descent on symmetric targets.**

- *Proved.* With all first-layer weights equal to one, one hidden unit per value of $`\sum_ix_i`$, and gradient descent on the readout alone, every symmetric target is learned from $O(\sqrt{d\log(1/\varepsilon)}/\varepsilon)$ samples; a ReLU variant trained to convergence needs $O(nd^4\log n)$ iterations. This is a frozen feature map that knows the target is symmetric, a lookup table in $`\sum_ix_i`$. It involves no feature learning and says nothing about generic gradient descent on a natural architecture.
- *Proved, then heuristic.* For even $q$, the sign-flip orbit of an antiperiodic target is pairwise nearly orthogonal, and exactly orthogonal at $q=2$ for even $d$. So noisy gradient descent that is equivariant under sign flips, as with iid Gaussian or Rademacher initialization, should fail on these targets; this application of the equivariance lower bounds is heuristic.
- *Numerical.* At $d=16$, ridge readouts on Rademacher and on Gaussian random features both fail on the $q=2$ target, with test errors $0.478$ and $0.486$, while Rademacher features learn parity with error $0.000$ ([`random_features.txt`](verification/subcube-parity/symmetric/random_features.txt)).
- *Open.* Periodic symmetric targets that are not antiperiodic, such as the period-3 pattern $++-$ in $\mathrm{wt}$, and near-parity targets that differ from parity on a symmetric set of polynomially small measure.

### 5.3 Full parity and the initialization

- **Literature (abstract-level).** [Abbe, Cornacchia, Hązła, and Kougang-Yombi (ICLR 2025)](https://arxiv.org/abs/2412.04910) report that SGD on a two-layer fully connected ReLU network with Rademacher ($\pm1$) first-layer initialization learns almost-full parities, of degree $d-O(1)$, to perfect accuracy in polynomial time. The positive result survives Gaussian perturbations of size $O(1/d)$, and a Gaussian perturbation of large enough constant size prevents learning. [Shoshani and Shamir](https://arxiv.org/abs/2501.00817) prove that any fixed parity of some minimal size, full parity included, is hard for perturbed gradient descent on one-hidden-layer ReLU networks.
- **One gradient step on Rademacher features (proved).** Let $d$ be even, and let the hidden units be $`\mathrm{ReLU}(\omega_k\cdot x)`$ with $`\omega_k`$ iid uniform in $\lbrace -1,1\rbrace^d$ and frozen. Train the readout by one full-batch gradient step on the correlation loss. With $O(d^4)$ units and $O(d^6\log(d/\delta))$ samples, the sign of the output equals $`\chi_{[d]}`$ at every input, with probability at least $1-\delta$. The relevant population coefficient is $\pm2^{1-d}\binom{d-2}{d/2-1}\approx\pm0.4/\sqrt d$; it vanishes for odd $d$.
- **The Rademacher kernel (proved; its network reading heuristic).** For $d$ even, the one-hidden-layer sign kernel with Rademacher first-layer weights on $(1,x)$ has Walsh eigenvalues $\hat G(U)^2$, where $`G=\mathrm{MAJ}_{d+1}(1,\cdot)`$. So the eigenvalue at $[d]$ equals the one at $\varnothing$, $(\binom d{d/2}2^{-d})^2\approx2/(\pi d)$. The arcsine kernel instead has eigenvalue $8.2\cdot10^{-8}$, $3.8\cdot10^{-20}$ and $2.5\cdot10^{-32}$ at $[d]$ for $d=20$, 60 and 100 and $L=2$. With Rademacher first and Gaussian later layers, $\Psi^{\circ(L-2)}$ of this kernel dominates $(2/\pi)^{L-2}$ times it. So, by the companion note's [Proposition 5](README.md#3-upper-bounds) with $`p=\chi_{[d]}`$, with probability at least $1-\delta$ over $n\ge8$ iid samples, the $\gamma<0$ sign-GP with this kernel reaches Gibbs error $\varepsilon$ from $O(d^2/\varepsilon)$ samples, up to the logarithmic terms of that proposition, and minimum-energy signs at $0<\gamma<1$ from $O(d/\varepsilon^2)$. That this kernel is the width-first limit of the network with a Rademacher first layer is heuristic, although the argument looks routine. The advantage is specific to the target: Rademacher features fail on the $q=2$ antiperiodic target (Section 5.2).
- **Numerical.** Table 5 compares first layers on parity alone. With Gaussian initialization the same network did not learn parity at $d=31$ (Table 3).

**Table 5. Parity alone, one hidden layer of width 1024.** Seed 2, budget 15.4 million samples, 40 evaluations per run, the first after 0.38 million samples. As in Table 4, the test set was not excluded from training; at $d=20$ the default run used more samples than there are inputs, so that entry partly measures memorization. The other layers use PyTorch's default initialization; the Rademacher first layer has entries $\pm1/\sqrt d$. Millions of samples until the error first fell to $5\%$:

| $d$ | default first layer | Rademacher first layer |
|---|---|---|
| 20 | 1.15 | 0.38 |
| 30 | 4.99 | 0.38 |
| 40 | not reached (error 0.497) | 0.38 |
| 50 | not reached (error 0.4995) | 1.15 |

**Reading (heuristic).** Full parity therefore gives "gradient descent learns it in polynomial time, the $\gamma<1$ learners need $\exp(\Omega(d))$" only when gradient descent uses a different initialization from the Gaussian weights of the prior. With Gaussian initialization, gradient descent is expected to fail at large $d$ (literature, abstract-level); in our runs on the one-hidden-layer network it failed at $d=31$ but succeeded at $d\le27$ (Table 2), and on the three-layer trunk with one readout it failed at every $d$ tested, 19 to 31 (Table 1). This separates initializations and priors, not gradient descent from Bayesian inference at a matched weight distribution. A Bayesian network with a Rademacher first layer has been analysed only at the kernel level; that its width limit is this kernel is heuristic.

## 6. Open problems

1. **A theorem for end-to-end gradient descent.** Prove that SGD or Adam on a standard architecture, from a continuous initialization and on uniform inputs, learns $`f^*`$ (or $`T_2`$) from polynomially many samples. Theorem E proves this for a greedy correlation-query learner, and the staircase theorem of Abbe et al. (2021) should give layerwise coordinate descent on special networks for $`T_2`$ and the real-valued $F$ (literature, abstract-level; its hypotheses were not checked). No end-to-end theorem was found (Section 3.3).
2. **Scaling beyond $`d=35`$.** Compare $`f^*`$, ctrl and parity alone on the same trunk at $d\ge39$, with several seeds, with SGD as well as Adam, and with a tanh trunk under Gaussian initialization, closer to the Bayesian prior; also try $`T_2`$. At $d\le35$ the sample counts cannot separate polynomial from exponential growth, and at $d=31$ parity alone is still learnable with the default initialization.
3. **The $`8^{-k}`$ loss.** Remove the $2^{-O(k)}$ loss in the exponent of Theorem A. On the subcube, the restricted tail kernel has eigenvalue $`\mu_j=\sum_t\binom kt\lambda_{j+t}1[j+t>r]`$ on $`\chi_U(x)`$ with $\lvert U\rvert=j$. With the ambient-degree cutoff that the proof uses, its top eigenvalue is about $`\binom{k+1}{\lceil(k+1)/2\rceil}\ell_r`$, so it gives no $2^{-k}$ gain. Numerically, at $L=2$, $d=40$ and $r\in\lbrace3,5\rbrace$, the top eigenvalue is 3.0, 10.1–10.2, 35.3–35.7 and 127–128.5 times $`\ell_r`$ for $k=2,4,6,8$ ([`restricted_tail.py`](verification/subcube-parity/restricted_tail.py)). Only a cutoff by $`x`$-degree brings it down to about $`(1+k)\ell_r`$, numerically 3.0, 5.2–5.4, 7.5–8.2 and 10.2–11.7 times $`\ell_r`$. A proof along that route would use $`\lVert m^{(0)}\rVert_{K^{(0)}}\le\lVert m\rVert_K`$, where $K^{(0)}$ is the kernel restricted to the subcube, take the head to be the $`x`$-degree projection of $m^{(0)}$, and replace the $2^k$ restriction losses in the band and tail.
4. **Linear codimension.** Cover targets with many good subcubes, such as inner product mod 2, which restricts to a parity of about $d/4$ bits on a subcube of codimension $d/2$. The per-subcube sampling events do not survive a union bound over $2^k$ subcubes, so one would need an average over subcubes.
5. **Hardness of the staircase half.** Is the sign-staircase $`f_1`$ alone exponentially hard for the $\gamma<1$ learners? This needs a margin-sensitive argument without restriction-parity structure (Section 5.1). The same question is open for $`g_\lambda`$.
6. **Plain fully connected networks.** For the paper's fully connected prior on $d+1$ bits, Theorem A gives the Bayes side. The matched gradient architecture is the plain MLP with $z$ as an input, which learned $`f^*`$ only at $d=19$ and 21, each time after more samples than there are inputs, and not at $d=23$, 27 or 31 (Tables 1b and 4). Does gradient descent on a plain fully connected network learn $`f^*`$, or another target with a parity subcube, from polynomially many samples?

## Files

The verification package is in [`verification/subcube-parity/`](verification/subcube-parity/README.md).

- [`README.md`](verification/subcube-parity/README.md): an index of the package and how to rerun it.
- [`check_local.py`](verification/subcube-parity/check_local.py) and [its output](verification/subcube-parity/check_local.txt): the sanity checks of Section 1.8.
- [`greedy_learner.py`](verification/subcube-parity/greedy_learner.py) and [its output](verification/subcube-parity/greedy_learner.txt): the simulation of Theorem E at $d=31$ and $63$.
- [`walsh_checks.py`](verification/subcube-parity/walsh_checks.py) and [its output](verification/subcube-parity/walsh_checks.txt): exact Walsh-transform checks of the Fourier facts behind Theorem E, Section 4.2, $`T_2`$ and $`g_\lambda`$, and of the closeness bound of Section 4.1.
- [`twohead_decoupling.py`](verification/subcube-parity/twohead_decoupling.py) and [its output](verification/subcube-parity/twohead_decoupling.txt): the finite-width prior covariance and tangent kernel across the two halves (Section 2).
- [`restricted_tail.py`](verification/subcube-parity/restricted_tail.py) and [its output](verification/subcube-parity/restricted_tail.txt): eigenvalues of the restricted tail kernel (Section 6, item 3).
- [`transfer_check.py`](verification/subcube-parity/transfer_check.py) and [its output](verification/subcube-parity/transfer_check.txt): kernel interpolation on $`f^*`$, ctrl and parity (Section 1.1).
- [`staircase/`](verification/subcube-parity/staircase/): checks of the sign-staircase facts of Sections 4.4 and 5.1.
- [`symmetric/`](verification/subcube-parity/symmetric/): checks of the symmetric-target facts of Sections 5.2 and 5.3.
- [`numerics/`](verification/subcube-parity/numerics/): the training script `gd_train2.py`, the job queue `runner.py` and `jobs.txt`, `summarize.py`, the finished runs `runs/*.json` with their logs, the script and logs of the default-initialization runs, and [`results.md`](verification/subcube-parity/numerics/results.md) with the tables behind Section 3.2 and Table 5.
- [`review.md`](verification/subcube-parity/review.md): the record of the independent checks.

# Red-team report on the agnostic NNBayes draft (claims A–E)

*This is the first adversarial pass over the draft Claims A–E of the brief ([`problem-brief.md`](problem-brief.md) §4), written before the proof notes. It is part of the agnostic-learning note ([`../README.md`](../README.md)). It is kept as a record of that pass, and because other notes cite its numbered results. The proofs below were written during the red-team pass, except the parts of Proposition 4.1 and Remark 6.2 restated at finalization from their referee reports. They are paper proofs with numerical checks; statements labelled **sketch** or **open** are not proved, and nothing here is Lean-verified. Only the parts marked refereed in the table below were refereed; the other parts are superseded by later notes, replaced by pointers to them, or unrefereed. Where a later note has settled or corrected a verdict of §0, a bracketed note beginning "At finalization" says so, and the last section lists every change made when the note was finalized. Repository statements are cited by file and label and were checked against the source before use. The scripts are in [`../checks/red-team-and-literature/`](../checks/red-team-and-literature/), and their outputs are recorded in Appendix A. `NNG/` denotes the project folder `neural-network-generalization/` of this repository.*

| Part | Status |
|---|---|
| §0 Verdicts | Not refereed. Items 1–4 and 8 carry "At finalization" notes pointing to the notes that settled or corrected them; items 6 and 7 are amended (last section). |
| §1 Basic lemmas | Not refereed as a section. Referees of other parts re-checked the lemmas as inputs and found them correct: Lemma 1.0 in [`RT-aggregate-logic.md`](../verification/RT-aggregate-logic.md) §3.6, Lemma 1.1 in [`RT-width-logic.md`](../verification/RT-width-logic.md) §2.9 and [`RT-depth2-logic.md`](../verification/RT-depth2-logic.md) §2.1, and Lemmas 1.2–1.3 in [`RT-depth2-logic.md`](../verification/RT-depth2-logic.md) §§2.2–2.3 (Lemma 1.2(b) needs $V>0$, which holds on the event of Lemma 1.3). [`depth-two.md`](depth-two.md) §2 restates and proves Lemma 1.0(1) and Lemmas 1.1–1.3. |
| §2 Claim A | Superseded by [`A-tight-conditioning-fails.md`](A-tight-conditioning-fails.md), which re-derives and extends it. Not refereed here, except Lemma 2.1(2), which the referees of §5 checked as an input and [`depth-two.md`](depth-two.md) §2 restates. |
| §3 Claim B and the threshold in D | Superseded by [`B-tempered-likelihood.md`](B-tempered-likelihood.md). Not refereed here, except Lemma 3.1, re-checked in [`RT-aggregate-logic.md`](../verification/RT-aggregate-logic.md) §3.3 (it is `B-tempered-likelihood.md` Lemma 5.2), and the first paragraph of the proof of Theorem 3.2, checked in [`RT-width-logic.md`](../verification/RT-width-logic.md). |
| §4.1–4.2 Consistency with the noisy-interpolation and slt-likelihood notes | Not refereed. |
| §4.3 Proposition 4.1 | Refereed through the logic and computation lenses, both "minor fixes": [`RT-tube-logic.md`](../verification/RT-tube-logic.md), [`RT-tube-computation.md`](../verification/RT-tube-computation.md). The paragraphs before and after it were reviewed with it. Restated at finalization with the referees' fixes and their sharper statements. |
| §5 Depth two | Refereed in two rounds, on this text ([`RT-depth2-logic.md`](../verification/RT-depth2-logic.md), [`RT-depth2-computation.md`](../verification/RT-depth2-computation.md)) and on its repair ([`RT-depth2-logic-revised.md`](../verification/RT-depth2-logic-revised.md), [`RT-depth2-computation-revised.md`](../verification/RT-depth2-computation-revised.md)). Replaced by a pointer to [`depth-two.md`](depth-two.md), whose final candidate was refereed in two further rounds ([`depth-two-referee-scope-1.md`](../verification/depth-two-referee-scope-1.md), [`depth-two-referee-logic-computation-1.md`](../verification/depth-two-referee-logic-computation-1.md); [`depth-two-referee-scope-2.md`](../verification/depth-two-referee-scope-2.md), [`depth-two-referee-logic-computation-2.md`](../verification/depth-two-referee-logic-computation-2.md)); its header names the changes made after the last round, which were not refereed again. |
| §6.1–6.2 Versions that still fail; what is known | Not refereed. One bullet of §6.1 is replaced by text from `depth-two.md` §6. |
| §6.3 List of surviving versions | Not refereed. Items 2–4 are amended (last section). |
| §6.3 Proposition 6.1 | Refereed in two rounds, on this text ([`RT-width-logic.md`](../verification/RT-width-logic.md), [`RT-width-computation.md`](../verification/RT-width-computation.md)) and on its repair ([`RT-width-logic-revised.md`](../verification/RT-width-logic-revised.md), [`RT-width-computation-revised.md`](../verification/RT-width-computation-revised.md)), followed by two checks of the revision ([`small-learner-width-revision-check-1.md`](../verification/small-learner-width-revision-check-1.md), [`small-learner-width-revision-check-2.md`](../verification/small-learner-width-revision-check-2.md)). Replaced by a pointer to [`small-learner-width.md`](small-learner-width.md). |
| §6.3 Remark 6.2 | Refereed through the logic lens, "minor fixes": [`RT-aggregate-logic.md`](../verification/RT-aggregate-logic.md). Restated at finalization in the referee's corrected form. |
| §6.4 Still open | Not refereed. Its second bullet is replaced by text from `depth-two.md` §6; its item "E at $\gamma=1$" is treated in [`E-finite-prior-scale.md`](E-finite-prior-scale.md) (see §8). |
| §7 The motivating scenario | Not refereed. Items 3, 5 and 6 are amended (last section). |
| §8 Remarks on C and E | Superseded by [`C-fixed-temperature-bayes.md`](C-fixed-temperature-bayes.md) and [`E-finite-prior-scale.md`](E-finite-prior-scale.md). Not refereed; its paragraphs on E were sketches. |
| Appendix A Numerical record | Not refereed. The optimisation runs of the former §5.4 are recorded in `depth-two.md` §7.1. |

**Notation.** As in the brief: $X\subseteq[-1,1]^d$ compact, $\bar x=(1,x)$, depth $L=H+1\ge2$, width $N$, energy $\kappa_N$ (`NNG/side-results/continuous-domains/source/paper.tex`, eq. `energy`), output $z_w$. For a sample $S=((x_i,y_i))_{i\le n}$ with $y_i\in[-1,1]$,

$$
F_{c,S}(w)=\kappa_N(w)+\frac1c\sum_{i=1}^n\bigl(z_w(x_i)-y_i\bigr)^2,\qquad
\Pi_\sigma(dw)\propto e^{-F_{c,S}(w)/(2\sigma^2)}\,dw .
$$

$L_D(f)=\mathbb E(f(x)-y)^2$, $\hat L(f)=\frac1n\sum_i(f(x_i)-y_i)^2$, $\operatorname{clip}(u)=\max\{-1,\min\{1,u\}\}$, $\eta(x)=\mathbb E[y\mid x]$. For $\zeta>0$, the set of **$\zeta$-near-minimizers** at the fixed width $N$ is $\mathcal N_\zeta=\{w:F_{c,S}(w)\le\min F_{c,S}+\zeta\}$.

**Limit order (used throughout).** The sample and the learner width are fixed first, and then $\sigma\downarrow0$. Every probability over the sample refers to an event that does not depend on $\sigma$ or $N$.

---

## 0. Verdicts

1. **A (depth $L\ge3$, cube, $c=1$): correct after repairs.** The memorizer must be re-derived for real values and accuracy $a$ (Lemma 2.1), which adds an energy term $9(H+1)/(2a)$ that the draft omits. Theorem 2.2 is the corrected statement. Its constants are confirmed: $\beta(1)=0.484829$, and $\max_\lambda\beta=0.517351$ at $\lambda=1.5029$. **Main caveat:** the failure needs learner width $N\ge N_0=\Theta(d^2n/a^2)$. At learner widths with $N(N+d)\log n=o(n)$ and input dimension $d=o(\sqrt n)$, for example $N\le n^{1/2-\epsilon}$ with $d\le N$, the same learner with clipped predictions is agnostically consistent against every fixed competitor of the repository architecture with width at most $N$, by parameter counting (`small-learner-width.md`, Theorems 1 and 4, Remark 8). A therefore refutes the width-uniform conjecture, which is the brief's formalisation. It does not refute a version in which the learner's width is a fixed small power of $n$. [At finalization: Claim A is proved in [`A-tight-conditioning-fails.md`](A-tight-conditioning-fails.md) Theorem 4.4, with Corollaries 4.5 and 4.5a, using a memorizer with a smaller first-layer energy (its Lemma 2.1). There the failure holds at learner widths $N\ge N_0=O(n\log^2n/a^2)$ for a fixed accuracy $a$, with certified excess tending to $(\sqrt{\beta(\lambda)}-a\sqrt\lambda)_+^2$, and at $N\ge N_0=O(n\log^4n)$ for the full excess $\beta(\lambda)-o(1)$. That note corrects the sentence "A therefore refutes the width-uniform conjecture": Claim A refutes the width-uniform property (P$_L$) of the brief for one learner, SP$_c$ with $cK_{\rm mem}=o(n)$, which includes $c=1$, on laws whose input dimension $d=\log_2n$ grows with $n$. It does not refute the conjecture, which lets the learner be chosen: [`B-tempered-likelihood.md`](B-tempered-likelihood.md) proves (P$_L$) for the tempered SP$_c$ with clipped predictions (A §0.1 and Proposition 5.1). The small-width result is proved in [`small-learner-width.md`](small-learner-width.md).]
2. **A′ (continuous inputs, deterministic labels): correct** (Proposition 2.4). The precise condition is that each cluster's radius is below $n^{-2}$ divided by the learner's Lipschitz bound. That bound is $(\kappa_N/L)^{L/2}/\sqrt d$ (Lemma 1.0, the AM–GM form). [At finalization: Claim A′ is proved in [`A-tight-conditioning-fails.md`](A-tight-conditioning-fails.md) Theorem 7.2, with Proposition 7.2a and Corollary 7.2b, on a different law: small corner cubes at the vertices of $\{-1,1\}^d$, with a deterministic, balanced label. That note adds that such a law is near-atomic at the learner's resolution, with density $2^{\Theta(d^2)}$ times uniform, and that input laws with density ratio $2^{o(d^2)}$ and noisy labels are open (its §0.1, Proposition 7.4 and Remark 7.5).]
3. **B (tempered $c=n^{1-\theta}$): correct, with a better exponent.** For unclipped outputs the draft's bookkeeping through the energy cover does not work; that route gives only $\theta<1/(4L+2)$. The path-norm Rademacher bound already in the repository (`NNG/works-in-progress/noisy-interpolation/README.md`, eq. (15)) gives B for all $\theta<1/H$ with clipped outputs and all $\theta<1/L$ with unclipped outputs (Theorem 3.2, Corollary 3.3). The rate is $\tilde O(n^{-1/(H+2)})$. [At finalization: proved in [`B-tempered-likelihood.md`](B-tempered-likelihood.md), against competitors of the repository architecture with the learner's depth, at every learner width $N\ge m$ and with explicit polynomial sample sizes: Theorem 6.3 for clipped predictions and every $\theta<1/H$, with excess $\tilde O(\mathrm{poly}(d,m,B)\,n^{-1/(H+2)})$ at $\theta=1/(H+2)$, and Theorem 6.4 for unclipped predictions and every $\theta<1/L$. The posterior mean of Theorem 6.3 is the mean of the clipped outputs; the Bayes model average and its clip are covered only for $\theta<1/L$ (B §0).]
4. **D: for clipped predictors the gap closes up to polylog factors.** The memorization threshold and the uniform-convergence threshold are both $c^\star=n^{1-1/H}(\log n)^{\Theta(1/H)}$ (Corollary 3.4). [At finalization: for $H\ge2$, [`B-tempered-likelihood.md`](B-tempered-likelihood.md) proves the threshold $\theta=1/H$ for clipped predictions. Every $\theta<1/H$ works for every law (Theorem 6.3), and every $\theta>1/H$ fails on the noisy cube with $d=\log_2n$ and $n=2^d$ samples, at learner widths $N\ge N_0(n)=\lceil2(d+1)^3n^{1+\theta}\ln2\rceil+1$ (Theorem 7.4). Its §7.5 item 1 states the window left in $c$: between $c\asymp n^{1-1/H}(\log n)^{-2/H}$ and $c\asymp n^{1-1/H}(\log n)^{2/H}$, up to constants, neither argument applies. For unclipped predictors the window $\theta\in[1/L,1/H]$ is open (its §7.5 item 2).]
5. **(2) Repository consistency: no contradiction.** The noisy-interpolation theorem samples without replacement, uses exact sign conditioning with a global margin, and measures clean classification error on the whole cube. At $n\sim2^d$ with a constant flip rate its bound is vacuous, and where it is not vacuous it already allows for memorization (§4.1). The slt-likelihood theorem and the exact-interpolation proposition assume clean labels (§4.2–4.3).
6. **(3) $L=2$: the learner still fits part of the noise. Its excess is at least of order $(dc+1)^{-2}$ for every $c\le\mathrm{polylog}(n)$, at least a constant when $c\le\nu/\log n$, and at least the full $\beta(\lambda)-o(1)$ when $c=o(1/\log n)$** (corrected §5, `depth-two.md`).
   - Proved: for every $0<c\le\mathrm{poly}(d)$, excess $\ge\gamma(\lambda)(18dc+1)^{-2}(1-o(1))$ at $n=\lceil\lambda2^d\rceil$ (for example $\approx0.0999/(18d+1)^2$ at $c=1$, $\lambda=1$). So SP$_c$ fails the polynomial-sample version (Theorem 5.1, Corollary 5.2(a)).
   - Proved: constant excess $\ge\Gamma_\lambda(\nu)-o(1)$ when $c\le\nu/d$, and $\ge\beta(\lambda)-o(1)$ when $dc\to0$. So SP$_c$ fails the "$+o(1)$" version, uniform over $d\le\log_2n+O(1)$ and required at every learner width $N\ge n^\alpha$, for $c(n)\le\nu/\log_2n$ (Corollary 5.2(b)).
   - Proved: with $d=M\approx n/\lambda$ (Hadamard atoms, inputs of norm $\sqrt d$) and $c=o(\sqrt n)$, SP$_c$ is worse than the Bayes-optimal zero network by $\beta(\lambda)-o(1)$ at every width (Proposition 5.3). This refutes no version of the conjecture: at $d\asymp n$ no learner competes with networks of width and weights $n^\alpha$ up to $o(1)$ (`depth-two.md` Remark 5.3a).
   - Open: whether the "$+o(1)$" version holds when $c\log n\to\infty$ and $c=O(\log^2n)$ for clipped predictors, or $c=O(\sqrt n\log n)$ for unclipped ones; this includes every fixed $c$ and $c=1$. Above these ranges it is settled: it holds for $\log^2n\ll c\le n^{1-\epsilon}$ (clipped predictors) and for $\sqrt n\log n\ll c\le n^{1-\epsilon}$ (all predictors), and it fails for $c\ge n^{1-o(1)}$, on a two-point law in dimension $1$ (`depth-two.md` Remark 5.7a, from `B-tempered-likelihood.md` Proposition 6.1, Corollary 8.1 and Proposition 9.1).
   - Numerics: on one sample each ($\lambda=1$, $c=1$), the networks found by L-BFGS show that every network whose objective is at most theirs leaves training residual at most $(1-\phi)G$, with $\phi\ge0.395$ at $d=8$ and $\phi\ge0.577$ at $d=10$ ($\phi\approx0.396$ and $0.578$). At the run's width, every near-minimizer leaves at most $(1-\phi)G+c$, so it absorbs at least $0.389$ and $0.576$ of $G$. The two runs used different optimizer budgets, so they show no trend in $d$ (`depth-two.md` §7.1).
7. **(4) The conjecture still fails with deterministic labels, atomless inputs, or a test distribution that excludes the training inputs** (A′). Four versions survive, all proved here or in the note cited: tempered conditioning (B), learner width tied to $n$, with clipped predictions (Proposition 6.1 as corrected in `small-learner-width.md`), hard tolerance matched to the sup-norm residual of a small network (Proposition 4.1), and conditioning on the aggregate training error (Remark 6.2). The last two need an oracle hyperparameter. Proposition 4.1 is a bounded-residual guarantee, not an oracle inequality: its risk bound is $\rho^2+\varepsilon$ for a tolerance $\rho$ above a known bound $\rho_0$ on the sup-norm residual. Remark 6.2 needs a threshold $\tau\ge L_D(g)+(U+1)^2\sqrt{\ln(1/\delta)/(2n)}$, about OPT plus a term of order $n^{-1/2}$.
8. **E: for $\gamma>1$, sketches.** The negative direction holds at polynomial widths and the positive direction for small $\theta$ (§8). Both directions are open at mean field ($\gamma=1$). [At finalization: these questions are treated in [`E-finite-prior-scale.md`](E-finite-prior-scale.md), which supersedes the sketches of §8. For clipped predictions it proves the positive direction at every learner width $N\ge m$, for $c=n^{1-\theta}$ with $\theta$ below a threshold that equals $1/H$ when $L\ge3$ and $\gamma\ge2-1/H$; the proved range is smaller when $1\le\gamma<2-1/H$, and the case $\gamma=1$ uses an imported mean-field cover (its Theorem 2.7). It proves the negative direction at every $\gamma\ge1$, mean field included, for $L\ge3$ on the noisy cube with $d=\log_2n$, at learner widths above a polynomial in $n$ (its Theorem 5.2). The fixed-temperature questions of Claim C are treated in [`C-fixed-temperature-bayes.md`](C-fixed-temperature-bayes.md).]

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

*At finalization:* this section is superseded by [`A-tight-conditioning-fails.md`](A-tight-conditioning-fails.md), which re-derives and extends it, and is kept, with its numbered results, because other documents cite them.

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
- **A2 (learner width: the important caveat).** The failure is proved only for $N\ge N_0=\Theta(d^2n/a^2)$. This is not a removable artefact. At learner width $N\le n^{1/2-\epsilon}$, with inputs in a compact $X\subseteq[-1,1]^d$ and $d\le n^{1/2-\epsilon}$, the same learner with clipped predictions has excess at most $O_L\bigl(B_0n^{-\epsilon}\sqrt{\ln(4/\delta)}+n^{-\epsilon}\sqrt{\ln n}+B_0^2n^{-2\epsilon}\ln(4/\delta)\bigr)$ over the best network of the repository architecture with width at most $N$ and weights at most $B_0$, for any fixed $B_0\ge1$ (`small-learner-width.md`, Corollary 3(iii) with Theorem 4; for $B_0<1$ use $\max\{B_0,1\}$). At learner width $\lceil n^\alpha\rceil$ with $d\le n^\alpha$, against the networks of the repository architecture with width and weights at most $n^\alpha$, its excess is $O_{L,\alpha,\delta}(n^{2\alpha-1/2})$, polynomially small for every $\alpha\in(0,\frac14)$ (Corollary 3(i)). So A refutes **width-uniform** statements, which is the repository's style and the brief's formalisation. It does not refute 'Bayesian learning at width $n^\alpha$ competes with the networks of width and weights at most $n^\alpha$', which holds for $\alpha<1/4$ in the sense just stated. The weight bound cannot be dropped: for every $n$ there is a noiseless law in $d=1$ that a width-1 network with large weights fits exactly and on which SP$_c$ misses by at least $1/4$ at every learner width (`B-tempered-likelihood.md` Proposition 9.1(a) and Lemma 9.2). The user explicitly allowed "whichever version of Bayesian learning is best", so any write-up must say which version is refuted.
- **A3 (two formulations).** The brief calls the polynomial-sample formulation "equivalent" to "test loss $\le\min$ over width/weights $\le n^\alpha$, plus $o(1)$". That holds only when the $o(1)$ is polynomially small and $d\le n^{O(1)}$. With an arbitrary $o(1)$, say $1/\log^2n$, the second statement is strictly weaker. A gives a constant excess at $d=\log_2n$, so it refutes both. The depth-two cube bound (Theorem 5.1) refutes the polynomial one for every $c\le\mathrm{poly}(d)$. It also refutes the '$+o(1)$' one when $c\le\nu/\log_2n$, with constant excess $\Gamma_\lambda(\nu)$, and $\beta(\lambda)$ when $c\log n\to0$. It is silent on the '$+o(1)$' one when $c\log n\to\infty$, e.g. for every fixed $c$. The two formulations do differ at depth two: at $c=\log^3n$ the polynomial one fails, while the '$+o(1)$' one holds for clipped predictors (`depth-two.md` Remark 5.7a).
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

*At finalization:* this section is superseded by [`B-tempered-likelihood.md`](B-tempered-likelihood.md), which gives complete proofs and explicit sample sizes for Claim B and the threshold in D, and is kept, with its numbered results, because other documents cite them.

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

Both are statements about clean labels, covering all widths and every $w$ with $\kappa_N\le E_*$ and $\max_i\lvert z_w(x_i)-f(x_i)\rvert\le\tau/2$. With random labels, minimum-energy interpolants have energy that grows with the number $s$ of distinct training inputs: for every $p_0\in(0,1)$, with probability at least $1-p_0$ over the signs, every interpolant has energy at least $H(p_0^2s/\mathcal D^2)^{1/H}\to\infty$ (Remark 3.5 with $\phi=1$ and $p=p_0$). They therefore lie outside the proposition's energy budget, and A shows that they do not generalize. There is no contradiction. The zero-tolerance limit of Cor. `exact` does not extend to noisy labels: with a tolerance $\rho$ below the noise amplitude $b$ the clone of the teacher is infeasible, and on the cube sampled without replacement TUBE then has excess at least $\frac nM(b-\rho)^2$ at large widths (`A-tight-conditioning-fails.md` Proposition 6.5). The proof of Theorem `strong` does extend to residuals that are bounded in sup norm.

**Proposition 4.1 (TUBE with a sup-norm residual budget).** *Restated at finalization in the form that its two referees support ([`../verification/RT-tube-logic.md`](../verification/RT-tube-logic.md) §4, Proposition 4.1′, and [`../verification/RT-tube-computation.md`](../verification/RT-tube-computation.md) §4). Part (a) is the original statement with its hypotheses and quantifiers written out; parts (b) and (c) are the referees' additions.*

Let $L\ge2$, and let $g$ be a depth-$L$ teacher in the sense of `paper.tex` (the learner's architecture), of width $C\ge1$ with weights in $[-B,B]$, $B\ge1$. Put $E_*=d(d+1)B^2+2(L-1)C^2B^2$, the energy bound of its clone at every width $N\ge C$ (eq. `teacher-energy`). Let $X\subseteq[-1,1]^d$ be compact, let $\rho_0\ge0$, and let $D$ be a law on $X\times[-1,1]$ with $\lvert y-g(x)\rvert\le\rho_0$ almost surely; $D_X$ denotes its input marginal. Call a sample *admissible* if $\lvert y_i-g(x_i)\rvert\le\rho_0$ for every $i$; samples are admissible with probability one. Let $\rho>\rho_0$. At learner width $N\ge C$, let $\Pi=\Pi_{N,\sigma,S}$ be the strong-prior Gaussian prior $\mu_\sigma$ conditioned on $\max_i\lvert z_w(x_i)-y_i\rvert<\rho$; it is well defined for admissible samples.

- **(a)** Let $\tau>\rho+\rho_0$, put $u'=1/\min\{1,\tau-\rho-\rho_0\}$, and let $p_L$ be the polynomial of Theorem `strong`. For every $\varepsilon\in(0,1)$ and $N\ge C$ there is $\sigma_0=\sigma_0(N,g,\rho-\rho_0,\varepsilon)>0$, which depends neither on the sample, nor on $n$ or $\delta$, nor on $D$ within the class above. For every $\delta\in(0,1)$ and every $n\ge\frac6\varepsilon[p_L(d,C,B,u')+\log\frac1\delta]$ there is a sample event of probability at least $1-\delta$, the same for all $N\ge C$ and all $\sigma$, on which, for every $N\ge C$ and every $\sigma<\sigma_0$,
$$
R_\tau(\Pi):=\mathbb E_\Pi D_X\{\lvert z_w-g\rvert>\tau\}\le\varepsilon/3,\qquad D_X\{q_\tau\le2/3\}\le\varepsilon,\qquad q_\tau(x):=\Pi\{\lvert z_w(x)-g(x)\rvert\le\tau\},
$$
$$
\mathbb E_\Pi L_D(\operatorname{clip}z_w)\le\min\{4,(\tau+\rho_0)^2\}+\tfrac43\varepsilon .
$$
By Jensen's inequality the same bound holds for $L_D(\mathbb E_\Pi\operatorname{clip}z_w)$. The computation referee notes that $(\tau+\rho_0)^2$ may be replaced by $(\tau+\sqrt{L_D(g)})^2$.
- **(b) A sharper risk bound.** Let $\mathcal H=\mathcal H_{E_*+2,\varepsilon/32}$ be the width-free cover of `paper.tex` Prop. `energy-cover`, and let $n\ge32\varepsilon^{-2}\bigl[\log\lvert\mathcal H\rvert+\log\frac1\delta\bigr]$. This sample size is polynomial in $d,C,B,1/\varepsilon,\log(1/\delta)$ at fixed $L$, and depends neither on $\rho,\rho_0,\tau$ nor on $N$. There is $\sigma_0'=\sigma_0'(N,g,\rho-\rho_0,\varepsilon)>0$ such that, with probability at least $1-\delta$, for every $N\ge C$ and every $\sigma<\sigma_0'$,
$$
\mathbb E_\Pi L_D(\operatorname{clip}z_w)\le\rho^2+\varepsilon,
$$
and the same bound holds for the risk of the posterior mean of $\operatorname{clip}z_w$. On the same event, every $w$ with $\max_i\lvert z_w(x_i)-y_i\rvert<\rho$ and $\kappa_N(w)\le E_*+2$ has $L_D(\operatorname{clip}z_w)<\rho^2+\tfrac34\varepsilon$.
- **(c) Energy.** For every admissible sample and every $n$, $\inf\{\kappa_N(w):\max_i\lvert z_w(x_i)-y_i\rvert<\rho\}\le E_*$. So the posterior stays in the $n$-independent sublevel $\{\kappa_N\le E_*+2\}$, up to mass that tends to $0$ as $\sigma\downarrow0$, uniformly over admissible samples.

*Example.* Take $\rho=2\rho_0$ and $\tau=4\rho_0$. This needs $\rho_0>0$ and gives $u'=1/\min\{1,\rho_0\}$, so the sample size of (a) is $\mathrm{poly}(d,C,B,1/\rho_0)/\varepsilon$. Part (a) then gives $25\rho_0^2+\tfrac43\varepsilon$, and part (b) gives $4\rho_0^2+\varepsilon$. Both compare with $\rho_0^2$, not with OPT, which can be much smaller (see the limits below).

*Proof.*

- *Part (a).* It is Theorem `strong` after these replacements: $f$ by $g$; $\rho$ by $\rho-\rho_0$ in the tube and by $\rho+\rho_0$ in the cover step; $u$ by $u'$. Clean labels enter the proof of `strong` at three places, the denominator, the cover step and the posterior mass of high-energy networks, and the next two bullets treat them (`../verification/RT-tube-logic.md` §2.2). The replacements need three qualifications: the laws are laws on $X\times[-1,1]$ with $\lvert y-g(x)\rvert\le\rho_0$ almost surely, with $R_\tau$ and $q_\tau$ taken under $D_X$; "for every sample" becomes "for every admissible sample"; and the scale threshold depends on $\rho_0$, through $\rho-\rho_0$.
- *Denominator.* $U_{\rho-\rho_0}(g)=\{w:\sup_X\lvert z_w-g\rvert<\rho-\rho_0\}$ lies inside the conditioning event for every admissible sample, because $\lvert z_w(x_i)-y_i\rvert\le\lvert z_w(x_i)-g(x_i)\rvert+\rho_0$. It is open and contains the exact clone, so the strong-prior estimates of the proof of `strong` apply, with a scale threshold that does not depend on the sample: for every admissible sample, $\Pi(\kappa_N>E_*+2)\le\mu_\sigma\{\kappa_N>E_*+2\}/\mu_\sigma(U_{\rho-\rho_0}(g))\to0$. The clone is feasible and has energy at most $E_*$, which proves (c). The constraint set is open, so the infimum in (c) need not be attained.
- *Cover step.* Lemma `posterior` has a single radius; it is used here in a two-radius form, which this bullet proves. Take $a=\min\{1/2,(\tau-\rho-\rho_0)/4\}$, so that $2a<\tau-\rho-\rho_0$ and $1/a\le4u'$, and use $A_h=\{\lvert h-g\rvert>\rho+\rho_0+a\}$. A fitted $w$ within $a$ of $h$ has $\lvert h(x_i)-g(x_i)\rvert<a+\rho+\rho_0$, so no training input lies in $A_h$. Moreover $\lvert z_w-g\rvert>\tau$ implies $\lvert h-g\rvert>\tau-a>\rho+\rho_0+a$. The sample event involves only the training inputs and the width-free cover, so it is the same for every $N\ge C$.
- *Risk.* For $\lvert y\rvert\le1$, $(\operatorname{clip}z_w-y)^2\le\min\{4,(\lvert z_w-g\rvert+\rho_0)^2\}$ almost surely. This is the only use of the label range.
- *Part (b)* (the referees' proof). Choose $\sigma_0'$ so that $\Pi(\kappa_N>E_*+2)\le\varepsilon/16$ for every admissible sample. The clipped losses of the members of $\mathcal H$ lie in $[0,4]$, so Hoeffding's inequality and a union bound give, with probability at least $1-\delta$, $L_D(\operatorname{clip}h)\le\hat L(\operatorname{clip}h)+\varepsilon/2$ for every $h\in\mathcal H$. The clipped loss is $4$-Lipschitz in the prediction, so passing to an approximant within $\varepsilon/32$ moves the population loss and the empirical loss by at most $\varepsilon/8$ each. A feasible $w$ has $\hat L(\operatorname{clip}z_w)\le\max_i(z_w(x_i)-y_i)^2<\rho^2$, so $L_D(\operatorname{clip}z_w)<\rho^2+\tfrac34\varepsilon$ if also $\kappa_N(w)\le E_*+2$. Integrating over $\Pi$ and adding $4\cdot\varepsilon/16$ for the high-energy mass gives $\rho^2+\varepsilon$; Jensen's inequality gives the posterior mean. ∎

Hard conditioning within the sup-norm residual of a small network keeps the strong-prior posterior in an $n$-independent energy sublevel: for every $n$ the infimum of the energy over the constraint set is at most $E_*$ (part (c)), so the posterior cannot memorize a growing number of residuals. By contrast, a Gaussian likelihood with fixed $c$ always rewards fitting below the residual level. For noise-like residuals ($\rho_0\ge1$ for fair signs) Proposition 4.1 is vacuous, consistent with A.

**Limits of the statement** (from both reports).

- *Bounded-residual guarantees, not oracle inequalities.* The bounds of (a) and (b) are relative to $\rho_0^2$ or $\rho^2$, not to OPT or $L_D(g)$, and no bound $C'L_D(g)+\varepsilon$ with $\varepsilon<\rho^2$ holds. Take $g\equiv-c_0$ with $\rho<c_0\le1$, a single input atom, and labels $-c_0+\rho_0\xi$ with $\xi\sim\mathrm{Bernoulli}(p)$. Then the strong-prior TUBE risk tends to $(\rho-p\rho_0)^2+p(1-p)\rho_0^2$ at every width, while $L_D(g)=p\rho_0^2$ (`../verification/RT-tube-computation.md`, Issue 2). So (b) is tight as $p\to0$, and the excess over OPT can approach $\rho^2$ while $L_D(g)\to0$. The hypothesis is near-realizable: it excludes every law with binary noisy labels, for which $\rho_0\ge1$, and the learner must know $\rho_0$, up to a constant factor, to set $\rho$ (`../verification/RT-tube-logic.md`, issue 6).
- *Energy, and what "no memorization" means.* By (c) the posterior stays at energy at most $E_*+2$ for every $n$, so Claim A's mechanism, which needs energy growing with $n$, cannot operate. "No memorization" holds only in this energy sense: at small $n$ the least-energy feasible network can still fit label noise, as in an example with $n=2$ (`../verification/RT-tube-computation.md`, Issue 1).
- *Range and sample size.* With $\rho=2\rho_0$ and $\tau=4\rho_0$, the bound of (a) is below the trivial bound $4$ only when $\rho_0<2/5$, and below $1$, the largest possible risk $\mathbb Ey^2$ of the zero predictor, only when $\rho_0<1/5$. At the best admissible constants, where $(\tau+\rho_0)^2$ approaches $9\rho_0^2$, the two thresholds are $2/3$ and $1/3$. The sample sizes are the paper's polynomials and are astronomically large even for small teachers: about $1.3\cdot10^{21}$ for (a) and $2.9\cdot10^{26}$ for (b) at $d=C=1$, $B=1.05$, $L=2$, $\rho_0=0.1$, $\varepsilon=0.1$, $\delta=0.01$ (`../verification/RT-tube-computation.md`, Issues 5 and 7).
- *Predictors, prior and domain.* The bounds cover the clipped Gibbs risk and the posterior mean of the clipped outputs. They do not cover the posterior mean $\mathbb E_\Pi z_w$ or the unclipped Gibbs risk, and they concern the strong-prior limit only (`../verification/RT-tube-logic.md`, issue 8). The domain $X\subseteq[-1,1]^d$ rests on `paper.tex` Remark `cube`, which is prose; the repository's Lean audit certifies Theorem `strong` only on the unit ball (`../verification/RT-tube-computation.md`, Issue 4).

---

## 5. Depth two ($L=2$), every $c>0$

*Replaced at finalization by a pointer.* The corrected Theorem 5.1, Corollary 5.2 and Proposition 5.3, with the lemmas they use (Lemma 1.0(1), Lemmas 1.1–1.3 and the depth-two part of Lemma 2.1), are in [`depth-two.md`](depth-two.md) under the same numbers. On the cube family ($n=\lceil\lambda2^d\rceil$ samples with inputs uniform on $\{-1,1\}^d$ and fair-sign labels), with probability $1-o(1)$ over the sample, at every learner width $N\ge N_0=O(n\log^4n)$ and in the strong-prior limit, the near-minimizers, Gibbs draws, Gibbs risks and posterior means of depth-two SP$_c$, clipped or not, have excess at least $\gamma(\lambda)(18dc+1)^{-2}(1-o(1))$ for every $0<c\le\mathrm{poly}(d)$, at least a constant $\Gamma_\lambda(\nu)-o(1)$ when $c\le\nu/\log_2n$, and at least $\beta(\lambda)-o(1)$ when $c\log n\to0$ (Theorem 5.1, Corollary 5.2); the progressive-mixture predictor, learner widths below $N_0$ and a fixed input dimension are not covered. So SP$_c$ fails the polynomial-sample formulation for every $c\le\mathrm{polylog}(n)$ and the "$+o(1)$" formulation for $c\le\nu/\log_2n$, while for $c\log n\to\infty$, which includes $c=1$, the "$+o(1)$" formulation is open as long as $c=O(\log^2n)$ for clipped predictors or $c=O(\sqrt n\log n)$ for unclipped ones; the conjecture itself is not refuted at depth two, because the tempered SP$_c$ of `B-tempered-likelihood.md` has both properties for clipped predictors, for example at $c=n^{1/2}$. Proposition 5.3 (Hadamard atoms, $d=M\asymp n$, inputs of norm $\sqrt d$) shows that SP$_c$ with $c=o(\sqrt n)$ is worse than the Bayes-optimal zero network by $\beta(\lambda)-o(1)$ at every width, and refutes no formulation of the conjecture, since at $d\asymp n$ no learner competes with networks of width and weights $n^\alpha$ up to $o(1)$.

The numerics of §5.4, with its tempering sweep, are recorded in `depth-two.md` §7.1. The paragraph "The positive side at $L=2$" is replaced there by Remarks 5.7 and 5.7a, and the open questions of this section are stated in its Remark 5.8.

- **Theorem 5.1** (partial memorization on the cube): `depth-two.md` §3.
- **Corollary 5.2**: `depth-two.md` §4.
- **Proposition 5.3** (constant excess at depth two when $d=M$): `depth-two.md` §5.

---

## 6. Which versions of the conjecture survive?

### 6.1 Versions that still fail

- **Deterministic labels:** fail, by A′ (Proposition 2.4).
- **Atomless inputs:** fail, by A′.
- **A test law that excludes the training inputs:** fails, by A′, because the training inputs form a null set.
  - On the cube itself, testing only on unseen atoms is **not** settled. At $d=8$ and $d=10$, the networks found numerically have conditional excess of about 0.37–0.46 at $L=3$ and 0.14–0.16 at $L=2$ on unseen atoms, so excluding the seen atoms does not obviously help.
- **High dimension with repeated inputs:** fails for every learner, for a reason unrelated to close conditioning: with $d=n$ and $x$ uniform on the unit vectors, no learner competes with networks of width and weights $n^\alpha$ up to $o(1)$ (`depth-two.md` Remark 5.3a). Proposition 5.3 adds that SP$_c$ with $c=o(\sqrt n)$ is worse there than the Bayes-optimal zero network by $\beta(\lambda)-o(1)$, for inputs of norm $\sqrt d$. For unit-ball inputs it shows a constant gap $\beta(\lambda)\bigl(1-\sqrt{2c/\sqrt{\beta(\lambda)}}\bigr)_+^2-o(1)$ only for $c<\sqrt{\beta(\lambda)}/2$, the full $\beta(\lambda)-o(1)$ only when $c\to0$, and nothing at $c=1$ (`depth-two.md` Remark 5.4).
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
2. **Learner width tied to $n$**, with clipped predictions (Proposition 6.1, corrected in `small-learner-width.md`). This is classical, and it holds for $c=1$.
3. **Hard tolerance matched to the sup-norm residual** of a small network (Proposition 4.1). Close conditioning in the literal sense, at the price of a constant factor and the sup norm. It is a bounded-residual guarantee, not an oracle inequality: it assumes $\lvert y-g(x)\rvert\le\rho_0$ almost surely, which excludes binary noisy labels, the learner must know $\rho_0$ to set its tolerance $\rho>\rho_0$, and the risk bound $\rho^2+\varepsilon$ compares with $\rho^2$, not with OPT.
4. **Conditioning on aggregate fit** (Remark 6.2), if the threshold $\tau$ is supplied. It must exceed the competitor's training error, for example $\tau\ge L_D(g)+(U+1)^2\sqrt{\ln(1/\delta)/(2n)}$, so $\tau$ is an oracle hyperparameter.
5. **Clean labels** (the repository theorems).

**Proposition 6.1 (fixed polynomial learner width).** *Replaced at finalization by a pointer to [`small-learner-width.md`](small-learner-width.md), which corrects it and keeps the number: Proposition 6.1 is its Theorem 1, whose part (c) re-proves the display that stood here. Its Corollaries 2 and 3 replace the "In particular" clause, its Theorem 4 transfers the bounds to the Gibbs risk and the posterior mean, and its Remark 8 replaces the paragraph that followed the proof, on where the width transition lies.* Run the strong-prior learner with the clean-label scaling $c=1$ at learner width $N=\lceil n^\alpha\rceil$ with $0<\alpha<\frac14$: for every data law on $X\times[-1,1]$ with $X\subseteq[-1,1]^d$ compact and $d\le n^\alpha$, with probability at least $1-\delta/2$, its clipped predictions (the clipped near-minimizers, and in the strong-prior limit the clipped Gibbs risk and the posterior mean of the clipped outputs) have excess test MSE $O_{L,\alpha,\delta}(n^{2\alpha-1/2})$ over the best depth-$L$ network of the repository architecture with width and weights at most $n^\alpha$ (Corollary 3(i) with Theorem 4), and unclipped predictions are not covered. The guarantee holds at one learner width tied to $n$ and is not uniform over learner widths, and for $L\ge3$ it cannot be, since Claim A gives the same learner a constant excess on the noisy cube at every learner width above a polynomial in $n$ (Remark 8); the rate $O(n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\log n})$ that the "In particular" clause stated is withdrawn.

**Remark 6.2 (conditioning on aggregate fit rather than on each output).** *Restated at finalization in the corrected form of its referee report, [`../verification/RT-aggregate-logic.md`](../verification/RT-aggregate-logic.md) §6 (a)–(b). The referee found the original display correct and asked for the hypotheses, quantifiers and reading of $\tau$ given here. With Lemma 3.1's sample-dependent $\mathcal D$ replaced by the sample-free $\mathcal D_n$ below, the original display, whose last term was $4\sqrt{\ln(2/\delta)/(2n)}$, follows from (a).*

Fix $L=H+1\ge2$ and a law $D$ on $X\times[-1,1]$ with $X\subseteq[-1,1]^d$ compact, so that labels lie in $[-1,1]$. Let $g$ be a competitor of the learner's depth $L$ and of the repository architecture (input $\bar x=(1,x)$, tanh hidden layers without internal biases, linear readout), of width $m$ with all weights in $[-B,B]$, and put $E_*=d(d+1)B^2+2(L-1)m^2B^2$ and $U=mB$. Let $\mathcal D_n=\sqrt{2(d+1)\ln(n+1)}+\frac{H-1}2$, the sample-free constant of `B-tempered-likelihood.md` Lemma 5.2. Fix $\tau>0$ and $\delta\in(0,1)$. At learner width $N$, let $\mu_\sigma$ be the strong-prior Gaussian prior and $\Pi^\tau_{\sigma,N,S}=\mu_\sigma(\cdot\mid\hat L_S(z_w)<\tau)$.

- **(a)** There is a sample event $G_\delta$ with $\Pr(G_\delta)\ge1-\delta$, which depends neither on $N$, nor on $\sigma$, nor on $\tau$. On $G_\delta\cap\{\hat L_S(g)<\tau\}$, for every learner width $N\ge m$:
  - $\Pi^\tau_{\sigma,N,S}\{\kappa_N>E_*+\zeta\}\to0$ as $\sigma\downarrow0$, for every $\zeta>0$, by the argument of the proof of Cor. `exact`: the conditioning event is open and contains the clone of $g$, whose energy is at most $E_*$;
  - every weak limit point as $\sigma\downarrow0$ is carried by $\{\hat L_S\le\tau,\ \kappa_N=\inf_{\{\hat L_S<\tau\}}\kappa_N\}\subseteq\{\hat L_S\le\tau,\ \kappa_N\le E_*\}$;
  - the $\limsup_{\sigma\downarrow0}$ of the clipped Gibbs risk $\mathbb E_{\Pi^\tau_\sigma}L_D(\operatorname{clip}z_w)$, and that of the risk of the posterior mean of the clipped outputs, $\mathbb E_{\Pi^\tau_\sigma}\operatorname{clip}z_w$, are each at most
  $$
  \tau+8\mathcal D_n\Bigl(\frac{E_*+1}H\Bigr)^{H/2}n^{-1/2}+4\sqrt{\frac{\ln(1/\delta)}{2n}} .
  $$

  The scale threshold depends on the sample, through the shape of the conditioning event and, near the clone, through the margin $\tau-\hat L_S(g)$. It is uniform over samples with $\hat L_S(g)\le\tau-\xi$ for a fixed $\xi>0$, but not over all samples (report §3.2). So the interchange of "with probability at least $1-\delta$" and "for all $\sigma<\sigma_0$" that §1 allows after Lemma 1.1 for SP$_c$ does not apply here.
- **(b)** If $\tau=L_D(g)+t$ with $t\ge(U+1)^2\sqrt{\ln(1/\delta)/(2n)}$, then with probability at least $1-2\delta$ the same functionals are at most
  $$
  L_D(g)+t+8\mathcal D_n\Bigl(\frac{E_*+1}H\Bigr)^{H/2}n^{-1/2}+4\sqrt{\frac{\ln(1/\delta)}{2n}},
  $$
  at every learner width $N\ge m$. For excess at most $\varepsilon$, a sample size polynomial in $d,m,B,1/\varepsilon,\log(1/\delta)$ at fixed depth suffices (report §3.5). The learner depends on $\tau$, hence on $L_D(g)$: $\tau$ is an oracle hyperparameter.

*Proof.* Report §§3.1–3.5. The concentration step uses only that the conditioning event is open and nonempty and that the prior is Gaussian. The generalization step is the uniform deviation over the width-free class $\mathcal Z_{E_*+1}$ (Lemma 3.1 with symmetrization, contraction and McDiarmid's inequality), which is `B-tempered-likelihood.md` Lemma 5.3(a). In (b), Hoeffding's inequality for $g$, whose losses lie in $[0,(U+1)^2]$, gives $\hat L_S(g)<\tau$ with probability at least $1-\delta$.

So conditioning on "fit about as well as a fixed small network does in mean square" works, whereas conditioning on each output at a tolerance below the noise level does not (Claim A, A5). The catch is the threshold. "$\tau\approx\mathrm{OPT}$" must be read as $\tau\ge L_D(g)+(U+1)^2\sqrt{\ln(1/\delta)/(2n)}$, about OPT plus a term of order $n^{-1/2}$: at $\tau=\mathrm{OPT}$ the hypothesis $\hat L_S(g)<\tau$ fails with probability about $1/2$, and nothing is claimed on that event. A hyperprior over $\tau$ is not analysed here. The referee also observed two things that this note does not claim: the oracle can be removed by setting $\tau$ from the data, as the least training loss over the competitor class plus $t$, at the price of a non-Bayesian least-squares step (report §6(c)); and the statement extends to unclipped outputs, with a larger excess term (report §6(d)).

### 6.4 Still open

- Continuous high-dimensional inputs with a bounded density and close conditioning.
- Whether depth-two SP$_c$ satisfies the '$+o(1)$' version when $c\log n\to\infty$ and $c=O(\log^2n)$ (clipped predictors; up to $c=O(\sqrt n\log n)$ for unclipped ones), for example at every fixed $c$. On the cube family this asks whether the excess stays above a constant at $n$ superpolynomial in $d$ (`depth-two.md` Remarks 5.7a and 5.8).
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
3. **Deeper networks need more tempering.** The critical scaling $c^\star\approx n^{1-1/H}$ approaches $n$ as depth grows, because memorization gets cheaper. At depth two, on the cube family and for clipped predictors, the transition lies between $c\approx1/\log n$ (constant excess below) and $c\approx\log^2n$ (vanishing excess above). For the polynomial-sample version, every $c\le\mathrm{polylog}(n)$ fails (Corollary 5.2(a)), and $c=n^{1-\theta}$ with $0<\theta<1$ works for clipped predictors (`B-tempered-likelihood.md` Theorem 6.3).
4. **Fitting deterministic residuals is not always harmful.** Suppose the residual $y-g(x)$ of a small network is itself representable at width $\mathrm{poly}(n)$, with structure on scales the data resolve. Then fitting it is the right thing to do, since that residual is part of the comparator class. Harm comes only from residual components that look like noise to every network of polynomial size, at the resolution set by the learner's Lipschitz bound $(\kappa/L)^{L/2}/\sqrt d$. Examples are label noise, near-duplicate inputs with inconsistent labels, and chaotic or hash-like dependence (A′).
5. **If the residual of a small network is small in sup norm**, hard conditioning with a matched tolerance does not memorize in the energy sense, and its test MSE is at most $\rho^2+\varepsilon$ for a tolerance $\rho>\rho_0$, for example $4\rho_0^2+\varepsilon$ at $\rho=2\rho_0$ (Proposition 4.1(b); the original bound, part (a), gives $25\rho_0^2+\tfrac43\varepsilon$ there). This is a bounded-residual guarantee, not an oracle inequality: the learner must know $\rho_0$, and its excess over OPT can approach $\rho^2$ even when $L_D(g)\to0$.
6. **If the learner's width is only a small power of $n$**, everything is classical for clipped predictions (Proposition 6.1, corrected in `small-learner-width.md`). Such a result cannot explain overparameterized learning.

---

## 8. Remarks on C and E

*At finalization:* the finite-scale questions are treated in [`E-finite-prior-scale.md`](E-finite-prior-scale.md), which proves the positive direction for clipped predictions with threshold $\theta<1/H$ when $L\ge3$ and $\gamma\ge2-1/H$ (its Theorem 2.7) and the negative direction at every $\gamma\ge1$, mean field included, for $L\ge3$ on the noisy cube with $d=\log_2n$ at learner widths above a polynomial in $n$ (its Theorem 5.2), and the fixed-temperature questions in [`C-fixed-temperature-bayes.md`](C-fixed-temperature-bayes.md) (an oracle inequality for the progressive mixture of clipped outputs, its Theorems C.1–C.2, and the failure of width-uniform bounds, its Theorem C.5); the remarks and sketches below are superseded.

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
- For $m\le N<T$, where $T\asymp(n^{\theta(L-2)}/a^2)^{1/(\gamma-1)}$: open. If $T\le n^{1/2-\epsilon}$, that is, if $\theta<(\gamma-1)/(2(L-2))$, the parameter-counting bound of `small-learner-width.md` Theorem 1(a) would apply to clipped predictions, given a bound on the energy of the finite-scale posterior; no such bound is proved.

*Status:* a sketch, not checked in detail. At $\gamma=1$ an agnostic version of the mean-field output cover is needed, and that is **open**.

---

## Appendix A. Numerical record

All scripts are in [`../checks/red-team-and-literature/`](../checks/red-team-and-literature/). They print their results rather than writing `.out` files; the values below are the recorded outputs, and the printed lines of six of the optimisation runs are kept there as `run_*.txt` (`depth-two.md` §7.1 lists them). `constants.py` and `bounds_table.py` were re-run at finalization and reproduce the values below.

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

The runs are recorded in `depth-two.md` §7.1, which reproduces the table and the tempering sweep of the former §5.4. The $d=8$, $c=1$ runs used 3 restarts of up to 20000 L-BFGS iterations; the $d=10$ runs and the sweep used 1 restart of up to 6000 iterations. Since every reported objective value is an upper bound on $\min F_c$, the captured fraction $\phi$ is a lower bound on what every network with objective at most the one found captures for that sample; at the run's width, every near-minimizer captures at least $\phi-c/G$, which is $0.389$ and $0.576$ in the two depth-two runs at $c=1$ (`depth-two.md` §7.1).

---

## Record of the finalization

Reports are in [`../verification/`](../verification/) and are cited by file name. Text marked "verbatim" was copied unchanged from the section named in the last column. Everything not listed here is as the red-team pass left it, apart from file paths, which were rewritten to the layout of this repository before this finalization.

| Where | What changed | Source |
|---|---|---|
| Header | The "*Scope.*" paragraph is replaced by this header and the status table. The header says what the note is and why it is kept, replaces "Everything below is proved here unless it is labelled sketch or open" by a statement of who proved and who refereed what, and defines `NNG/`. The notation and limit-order paragraphs are unchanged. | Editorial (finalization); the statuses are those of the reports linked in the table |
| §0 item 1 | The sentence on small widths replaced (verbatim); "At finalization" note added | `small-learner-width.md` §7.3, entry "§0 item 1"; `A-tight-conditioning-fails.md` §0.1, §0.2 item 3, Theorem 4.4, Corollaries 4.5 and 4.5a, Proposition 5.1 |
| §0 item 2 | "At finalization" note added | `A-tight-conditioning-fails.md` §0.1, Theorem 7.2, Proposition 7.2a, Corollary 7.2b, Proposition 7.4, Remark 7.5 |
| §0 item 3 | "At finalization" note added | `B-tempered-likelihood.md` §0, Theorems 6.3 and 6.4 |
| §0 item 4 | "At finalization" note added | `B-tempered-likelihood.md` Theorems 6.3 and 7.4, §7.5 items 1–2 |
| §0 item 6 | Replaced (verbatim) | `depth-two.md` §6, entry "§0 item 6" |
| §0 item 7 | "learner width tied to $n$ (Proposition 6.1)" replaced (verbatim); "all proved here" became "all proved here or in the note cited"; three sentences added: Proposition 4.1 and Remark 6.2 need an oracle hyperparameter, and Proposition 4.1 is a bounded-residual guarantee, not an oracle inequality | `small-learner-width.md` §7.3, entry "§0 item 7"; `RT-tube-logic.md` issue 6; `RT-tube-computation.md` Issue 2; `RT-aggregate-logic.md` issues 1–2 |
| §0 item 8 | "At finalization" note added | `E-finite-prior-scale.md` §0 items 2 and 6, Theorems 2.7 and 5.2; `C-fixed-temperature-bayes.md` §C.0 |
| §2 | Opening sentence added | Editorial (finalization) |
| §2.3 A2 | Three sentences replaced (verbatim) | `small-learner-width.md` §7.3, entry "§2.3 A2" |
| §2.3 A3 | Last sentence replaced (verbatim) | `depth-two.md` §6, entry "§2.3 A3" |
| §3 | Opening sentence added | Editorial (finalization) |
| §4.3, paragraph before Proposition 4.1 | "Remark 3.5 with $\phi=p=1$", a worst case over labelings, replaced by the random-label form with $p=p_0<1$; a sentence added saying that the zero-tolerance limit of Cor. `exact` does not extend to noisy labels; the lead-in now says that the proof of Theorem `strong`, not of Prop. `exact`, extends | `RT-tube-logic.md` issue 9; `RT-tube-computation.md` Issue 6 |
| §4.3, Proposition 4.1 | Restated. Hypotheses written out ($C\ge1$, $B\ge1$, compact $X\subseteq[-1,1]^d$, admissible samples, $D_X$) and quantifiers (probability $1-\delta$, one sample event for all $N\ge C$, $\sigma<\sigma_0(N,g,\rho-\rho_0,\varepsilon)$). Part (a) keeps the original bound, now $\min\{4,(\tau+\rho_0)^2\}+\tfrac43\varepsilon$; the computation referee's constant $(\tau+\sqrt{L_D(g)})^2$ is noted. Parts (b), risk at most $\rho^2+\varepsilon$, and (c), energy, are added | `RT-tube-logic.md` issues 1, 2, 7, 8 and §4 (Proposition 4.1′); `RT-tube-computation.md` Q1–Q2, Issues 3–4 and §4 |
| §4.3, example $\rho=2\rho_0$, $\tau=4\rho_0$ | States that it needs $\rho_0>0$ and a sample size polynomial in $1/\rho_0$, and adds the value $4\rho_0^2+\varepsilon$ of part (b); "while $\mathrm{OPT}\le L_D(g)\le\rho_0^2$" replaced by the statement that the bounds compare with $\rho_0^2$, not with OPT | `RT-tube-logic.md` issue 3; `RT-tube-computation.md` Issue 2 |
| §4.3, proof | "Verbatim" given its three qualifications; "for every sample" became "for every admissible sample"; the two-radius form of Lemma `posterior` and the choice of $a$ stated; the referees' proof of (b) added | `RT-tube-logic.md` issue 1, §§2.2 and 4; `RT-tube-computation.md` §2 and Issue 3 |
| §4.3, paragraph after the proof | "never memorizes" replaced by the energy statement; "the minimum energy" became "the infimum of the energy"; "Limits of the statement" added | `RT-tube-logic.md` issues 4, 5, 6, 8 and §4; `RT-tube-computation.md` Issues 1, 2, 4, 5 and 7 |
| §5 | Heading corrected (verbatim); body replaced by a pointer, a summary taken from `depth-two.md` §0, and one line for each numbered result | `depth-two.md` §6, second group, entry "§5 heading", and §0; editorial (finalization) |
| §6.1, "High dimension with repeated inputs" | Replaced (verbatim) | `depth-two.md` §6, entry "§6.1" |
| §6.3, list item 2 | Replaced (verbatim) | `small-learner-width.md` §7.3, entry "§6.3 item 2" |
| §6.3, list items 3 and 4 | Item 3: Proposition 4.1 described as a bounded-residual guarantee, not an oracle inequality. Item 4: survives if $\tau$ is supplied, and $\tau$ is an oracle hyperparameter | `RT-tube-logic.md` issue 6; `RT-tube-computation.md` Issue 2; `RT-aggregate-logic.md` issues 1–2 |
| §6.3, Proposition 6.1 with its "In particular" clause and proof, and the paragraph after the proof | Replaced by a pointer to `small-learner-width.md` (Theorem 1, Corollaries 2 and 3, Theorem 4, Remark 8) and a summary taken from its §0; the line with the number kept | `small-learner-width.md` §7.3, entries "§6.3, Proposition 6.1, the 'In particular' clause and the proof" and "§6.3, the paragraph after the proof"; its §0 |
| §6.3, Remark 6.2 | Restated in the referee's corrected form (a)–(b): hypotheses (learner width $N\ge m$, Gaussian prior, competitor of the learner's depth and the repository architecture, labels in $[-1,1]$); probability $1-\delta$ and every $N\ge m$; the functionals bounded; the sample-free $\mathcal D_n$; the sample-dependent scale threshold; "$\tau\approx\mathrm{OPT}$" read as $\tau\ge L_D(g)+(U+1)^2\sqrt{\ln(1/\delta)/(2n)}$, an oracle hyperparameter; "conditioning on each output" restricted to tolerances below the noise level. The referee's §6(c)–(d) are mentioned as observations, not as claims of this note | `RT-aggregate-logic.md` issues 1–7 and §6 |
| §6.4, second bullet | Replaced (verbatim) | `depth-two.md` §6, entry "§6.4, second bullet" |
| §7 item 3 | Last sentence replaced (verbatim) | `depth-two.md` §6, entry "§7 item 3" |
| §7 item 5 | "is safe: test MSE is at most $25\rho_0^2+\varepsilon$" replaced by the energy statement, the bound $\rho^2+\varepsilon$ of Proposition 4.1(b), and the statement that this is not an oracle inequality | `RT-tube-logic.md` issue 6; `RT-tube-computation.md` Issue 2 |
| §7 item 6 | "everything is classical (Proposition 6.1)" replaced (verbatim) | `small-learner-width.md` §7.3, entry "§7 item 6" |
| §8 | Opening sentence added | `E-finite-prior-scale.md` §0; `C-fixed-temperature-bayes.md` §C.0; editorial (finalization) |
| §8, "E, positive direction", second bullet | Replaced (verbatim) | `small-learner-width.md` §7.3, entry "§8" |
| Appendix A, first paragraph | Folder linked; how the scripts report their results, and the re-run of `constants.py` and `bounds_table.py`, stated | Finalization (re-run on 11 November 2026; outputs agree with the values listed) |
| Appendix A, paragraph on `memorize_opt.py` / `memorize_opt2.py` | Two sentences replaced (verbatim) | `depth-two.md` §6, entry "Appendix A" |

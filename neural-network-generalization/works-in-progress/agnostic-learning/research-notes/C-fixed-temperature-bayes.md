# C. Ordinary tempered Bayes: an agnostic bound at polynomial width, and its failure at large width

*This is a research note of the agnostic-learning note ([`../README.md`](../README.md)). It treats Claim C of the brief, [`problem-brief.md`](problem-brief.md). `NNG/` denotes the project folder `neural-network-generalization/` of this repository, and `paper.tex` abbreviates `NNG/side-results/continuous-domains/source/paper.tex`. Every repository statement used below was checked against its source before use; the file, label and line numbers are given at the point of use. The scripts of the numerical sanity checks and their outputs are in [`../checks/C/`](../checks/C/) (Section C.8). Two referees, one on logic and one on computation, reviewed the note, and three independent checks examined the revised text. A scope referee then reviewed the final text together with its summary in the draft of the main README ([`../verification/C-scope.md`](../verification/C-scope.md)). The Referee record at the end lists the reports of the two referees and how each of their issues was resolved, then how the points raised by the three checks were resolved, and last how each issue of the scope report was resolved. The changes made in answer to the scope report have not been refereed again. An independent check of these changes ([`../verification/C-scope-revision-check.md`](../verification/C-scope-revision-check.md)) found them resolved as stated, and the last paragraph of the record says how its three points were resolved.*

---

## C.0 Results and their status

Everything listed here is **proved** in this note, with the hypotheses stated where it is proved. Labels lie in $[-1,1]$ throughout. The learner FIX$_\eta$ is the posterior $\Pi_t(dw)\propto\exp\{-\eta\sum_{i\le t}(\operatorname{clip}z_w(x_i)-y_i)^2\}\mu(dw)$. All predictors in the positive results below are built from the clipped outputs $\operatorname{clip}z_w$. The main ones are the posterior mean $\hat f_t=\int\operatorname{clip}z_w\,d\Pi_t$ (called the BMA below), the Gibbs predictor $\operatorname{clip}z_w$ with $w\sim\Pi_n$, and the *progressive mixture* $\bar f_n$, the average of $\hat f_0,\dots,\hat f_n$. This departs from the brief (§2), whose BMA and Gibbs predictor use $z_w$ itself and whose progressive mixture averages posterior means of $z_w$; $\bar f_n$ is that progressive mixture with clipped outputs. No positive result below covers the unclipped predictors. For some priors, the bound of Theorem C.1 fails for the progressive mixture of the unclipped posterior means and for its clip (Remark 3 after Theorem C.1).

1. **Oracle inequality for an arbitrary prior (Theorem C.1).** Let $0<\eta\le 1/8$. For every prior $\mu$, every distribution $D$ on $X\times[-1,1]$, and every probability measure $Q$ chosen independently of the sample,
   $$\mathbb E_S\,L_D(\bar f_n)\le\int L_D(\operatorname{clip}z_w)\,Q(dw)+\frac{\mathrm{KL}(Q\Vert\mu)}{\eta(n+1)} .$$
   The infimum over $Q$ of the right side equals $-\frac1{\eta(n+1)}\log\int e^{-\eta(n+1)L_D(\operatorname{clip}z_w)}\mu(dw)$. The threshold $1/8$ is exactly the exp-concavity threshold of squared loss on $[-1,1]$ (Lemma C.2.1).
2. **Agnostic bound at polynomial width (Theorem C.2).** Take the finite-scale prior $\mu_{N,\gamma}$ ($\gamma\ge1$, Gaussian or any coordinate law of `paper.tex` eq. `law`) and $0<\eta\le1/8$. Let $g$ be any network of the architecture of §C.1.2 (tanh, biases only in the first layer, linear readout) with depth $L$, width $m\le N$ and weights at most $B$, where $B\ge1$. Then for every $\rho\in(0,1]$
   $$\mathbb E_S\,L_D(\bar f_n)\le L_D(g)+4\rho+\frac{A_L(d,m,B,\rho)\,N^\gamma}{\eta(n+1)} ,$$
   with $A_L$ the explicit expression of `paper.tex` eq. `A` (displayed in (C.3.2)). Consequently (Corollary C.2.2), with learner width $N=\lceil n^\alpha\rceil$ and $\alpha<1/(4+\gamma)$, the expected test loss of $\bar f_n$ is at most the infimum of the test loss over depth-$L$ networks of this architecture whose width and weights are at most $n^\alpha$, plus $O_{L,\gamma,\nu}(d^2n^{(4+\gamma)\alpha-1}\log(dn)/\eta)$, uniformly over laws $D$. This error term tends to $0$ when $d$ is fixed, or more generally when $d^2\log d=o(n^{1-(4+\gamma)\alpha}/\log n)$.
3. **Other priors.**
   - *Strong-prior family at fixed width (Proposition C.3).* For every scale $\sigma\le N^{-1/2}$ the same bound holds with $N^\gamma$ replaced by $\sigma^{-2}$. With $\eta$ fixed and $\sigma\to0$ (sample and width fixed), the learner degenerates: the posterior tends to the prior in total variation, the posterior means $\bar f_n$ and $\hat f_n$ tend to $0$ uniformly on $X$, $\sup_x\int z_w(x)^2\,d\Pi_n\to0$, and the test losses of $\bar f_n$, $\hat f_n$ and the Gibbs predictor tend to $\mathbb E y^2$.
   - *Standard fan-in (NNGP-scaling) prior (Proposition C.4).* The bound holds with a complexity term linear in $N$.
4. **Width dependence is necessary (Theorem C.5).** In the finite-scale family with any $\gamma>0$, for every sample, every $\eta>0$ and every $N$,
   $$\sup_X|\bar f_n|\le N^{-\gamma}\Bigl(\tfrac{4\eta n}{m_\nu}+\sqrt{\tfrac{2\eta n}{m_\nu}}\Bigr),\qquad \mathrm{TV}(\Pi_n,\mu_{N,\gamma})\to0\quad(N\to\infty).$$
   For the constant target $y\equiv1$, which a width-one network with weights $\le2$ fits exactly, the excess risk of $\bar f_n$, of $\hat f_n$ and of the Gibbs predictor is therefore at least $1-2N^{-\gamma}(4\eta n/m_\nu+\sqrt{2\eta n/m_\nu})$ on every sample, so it tends to $1$ as $N\to\infty$ at fixed $n$. The same holds, with a different vanishing term, for the unclipped posterior means, their clips, the progressive mixtures of either, the clip of the progressive mixture of the unclipped posterior means, and the unclipped Gibbs risk (Theorem C.5(e)). For this target and the excess level $1/2$, Theorem C.5(d) locates the width threshold $N^\gamma\asymp\eta n$, at which the bound of item 2 becomes nontrivial, up to a factor $O(A_L(d,1,2,1/16)/m_\nu)$. This does not show that the form of the complexity term in item 2 is optimal. Main result 4 (the $\gamma<1$ parity lower bound) is cited precisely in Remark C.6.4: below mean field, the width-first limit fails exponentially even for realizable parity, for the margin- and sign-conditioned learner studied there.
5. **High probability (Theorems C.6, C.7).**
   - The progressive mixture $\tilde f_n$ (the average over $t<n$) satisfies the bound of item 2, with $n+1$ replaced by $n$, with probability $\ge1-2\delta$, at the price of an additive $4\sqrt{2\log(1/\delta)/n}$. The same holds for $\bar f_n$ up to an extra $4/(n+1)$.
   - The *final* posterior satisfies, for any fixed $\eta>0$ and with probability $\ge1-2\delta$, $\int L_D(\operatorname{clip}z_w)\,d\Pi_n\le L_D(g)+4\rho+4\eta+\frac{A_LN^\gamma+2\log(1/\delta)}{\eta n}$; the left side is the risk of the Gibbs predictor, and the same bound holds for the BMA $\hat f_n$.

**Not proved here (Section C.9):**

- a bound for the final posterior mean at fixed $\eta$ without the additive $4\eta$;
- deviation bounds of order $\log(1/\delta)/n$ for the progressive mixture;
- any width-uniform positive statement for FIX$_\eta$, which item 4 rules out for $\gamma>0$;
- the large-width behaviour under the fan-in prior or at $\gamma\le0$, where prior outputs do not shrink;
- any positive statement for the unclipped predictors: the posterior mean $\int z_w\,d\Pi_t$ of the unclipped outputs, its clip, the progressive mixtures of these, the clip of the progressive mixture of the unclipped posterior means, and the unclipped Gibbs risk $\int L_D(z_w)\,d\Pi_n$. For some priors, the bound of Theorem C.1 fails for the progressive mixture of the unclipped posterior means and for its clip, and the bound of Theorem C.7 fails for the unclipped Gibbs risk (Remark 3 after Theorem C.1).

**Bearing on the conjecture.** The brief's formalisation (§1) asks for a sample size polynomial in $d,m,B,1/\varepsilon,\log(1/\delta)$ that does not depend on the learner width, uniformly over all learner widths $N\ge m$. For FIX$_\eta$ with the finite-scale prior and any $\gamma>0$, that formalisation is false: on the constant target the excess tends to $1$ as $N\to\infty$ at every fixed $n$ (item 4). What is proved is a weaker formalisation, in which the sample size may also grow polynomially with the **learner width $N$**: then FIX$_\eta$ with $0<\eta\le1/8$ satisfies the agnostic oracle inequality, in expectation for $\bar f_n$ and with probability $\ge1-2\delta$ for $\tilde f_n$ (items 2 and 5 for $\gamma\ge1$, Remark C.4.2 for $\gamma<1$). When $\gamma\ge1$ and the learner's width is tied to $n$, $N=\lceil n^\alpha\rceil$ with $\alpha<1/(4+\gamma)$, the user's informal statement holds for this learner in the following form (Corollary C.2.2): the expected test loss of $\bar f_n$ is at most the infimum of the test loss over depth-$L$ networks of the architecture of §C.1.2 with width and weights at most $n^\alpha$, plus $O_{L,\gamma,\nu}(d^2n^{(4+\gamma)\alpha-1}\log(dn)/\eta)$, which is $o(1)$ when $d$ is fixed or $d^2\log d=o(n^{1-(4+\gamma)\alpha}/\log n)$. With probability $\ge1-2\delta$ the same holds for $\tilde f_n$, with the additional terms $\frac1n+\frac1n\varepsilon_n(d)+4\sqrt{2\log(1/\delta)/n}$, where $\varepsilon_n(d)$ is the error term of (C.4.2) (Theorem C.6). This learner conditions only *weakly* on the training outputs: each observation changes the likelihood by a factor of at most $e^{4\eta}\le e^{1/2}$. It is not the learner the user had in mind, which "should condition to be pretty close to the given outputs on train inputs" (brief, §1).

---

## C.1 Setting

### C.1.1 Data and loss

Fix $d\ge1$ and a nonempty compact $X\subseteq[-1,1]^d$. Let $D$ be any Borel probability measure on $X\times[-1,1]$. Labels lie in $[-1,1]$ but are otherwise arbitrary, so there is no realizability or noise model. The sample is $S=S_n=((x_1,y_1),\dots,(x_n,y_n))\sim D^{\otimes n}$, and $S_t$ denotes its first $t$ pairs. For a Borel function $f:X\to\mathbb R$ put
$$L_D(f)=\int(f(x)-y)^2\,D(dx,dy)\in[0,\infty],\qquad \operatorname{clip}(u)=\max\{-1,\min\{1,u\}\}.$$
Since $\operatorname{clip}$ is the metric projection of $\mathbb R$ onto $[-1,1]$ and $y\in[-1,1]$,
$$|\operatorname{clip}u-y|\le|u-y|\qquad(u\in\mathbb R,\ y\in[-1,1]).\tag{C.1.1}$$
$L_D$ is convex: $u\mapsto(u-y)^2$ is convex for each $y$, and the inequality integrates.

### C.1.2 Networks and priors

Networks follow `NNG/side-results/continuous-domains/source/paper.tex`, §2 (lines 113–122). There is depth $L\ge2$, the input is augmented as $\bar x=(1,x)$, and $h^0(x)=\bar x$. The hidden layers are $h^\ell(x)=\tanh(W^\ell h^{\ell-1}(x))$ for $1\le\ell\le L-1$, all of width $N$, and the output is $z_w(x)=v^{\mathsf T}h^{L-1}(x)$. There are no internal biases. The parameter $w=(W^1,\dots,W^{L-1},v)$ lies in $\mathbb R^{P}$ with $P=N(d+1)+(L-2)N^2+N$, and $(w,x)\mapsto z_w(x)$ is continuous. The weighted energy is (`paper.tex` eq. `energy`, lines 293–296)
$$\kappa_N(w)=\frac dN\lVert W^1\rVert_F^2+\sum_{\ell=2}^{L-1}\lVert W^\ell\rVert_F^2+N\lVert v\rVert_2^2 .$$

**Coordinate law.** Let $\nu$ be a law on $\mathbb R$ as in `paper.tex` eq. `law` (lines 151–153). It is even with variance one and density $Z^{-1}e^{-V}$, where $V\in C^2$ and $0<m_\nu\le V''\le M_\nu<\infty$. The standard Gaussian is the case $m_\nu=M_\nu=1$. The paper writes $m,M$; we write $m_\nu,M_\nu$ because $m$ denotes the competitor width below. Since $\nu$ has variance one, necessarily $m_\nu\le1\le M_\nu$: Brascamp–Lieb gives $\operatorname{Var}\le1/m_\nu$, and Cramér–Rao gives $\operatorname{Var}\ge1/\mathbb E V''\ge1/M_\nu$. In the results and proofs of this note, the first fact is used only in two places: in the explicit constant $K_1$ at the end of the proof of Corollary C.2.2, where it gives $\min\{1,\sqrt{m_\nu}\}=\sqrt{m_\nu}$, and in the closing remark of Appendix C.A, Step 1. The second fact is not used. We use two consequences of eq. `law` proved in `paper.tex` (lines 310–335):

* (eq. `subgaussian`) If $Z$ is a vector of independent $\nu$-coordinates conditioned on a centrally symmetric convex set (possibly the whole space), then $\mathbb E e^{\theta\langle u,Z\rangle}\le e^{\theta^2\lVert u\rVert^2/(2m_\nu)}$ for all $\theta\in\mathbb R$ and all vectors $u$.
* (eq. `translation`) For the product law $\nu^{\otimes P}$, every symmetric Borel set $E$, and every $a\in\mathbb R^P$: $\nu^{\otimes P}(E+a)\ge\nu^{\otimes P}(E)\,e^{-M_\nu\lVert a\rVert^2/2}$.

**Scale-$\sigma$ priors.** For $\sigma>0$ let $\mu^N_\sigma$ be the law of
$$W^1=\sigma\sqrt{N/d}\;\Xi^1,\qquad W^\ell=\sigma\,\Xi^\ell\ (2\le\ell\le L-1),\qquad v=\sigma N^{-1/2}\xi^L,\tag{C.1.2}$$
where all entries of $\Xi=(\Xi^1,\dots,\Xi^{L-1},\xi^L)$ are independent with law $\nu$. Then $\kappa_N(w)=\sigma^2\lVert\Xi\rVert^2$. These are the strong-prior scales of `paper.tex` eq. `strong-scales` (lines 160–164). For Gaussian $\nu$, $\mu^N_\sigma$ has density proportional to $e^{-\kappa_N(w)/(2\sigma^2)}$; this is the brief's $\mu_\sigma$. The finite-scale family of `paper.tex` eq. `finite-scales` (lines 166–170) is the special case $\sigma=N^{-\gamma/2}$:
$$\mu_{N,\gamma}:=\mu^N_{N^{-\gamma/2}} .$$

**Fan-in prior** (`NNG/works-in-progress/slt-finite-sample/README.md`, §1, lines 13–29). Write $D_0=d+1$. The prior $\mu^{\rm fi}_N$ has independent centred Gaussian entries, with variance $1/D_0$ in $W^1$ and variance $1/N$ in every later matrix and in $v$.

**Competitors.** A *competitor* $g$ is a function $X\to\mathbb R$ computed by a network of the same depth $L$, width $m\ge1$ and all weights of absolute value at most $B\ge1$. Its matrices are $T^1\in\mathbb R^{m\times(d+1)}$ (first-layer biases included), $T^\ell\in\mathbb R^{m\times m}$ and readout $u\in\mathbb R^m$. Its *teacher tube* of radius $\rho$ is
$$U_\rho(g)=\Bigl\{w:\sup_{x\in X}|z_w(x)-g(x)|<\rho\Bigr\},$$
which is open because $X$ is compact and $(w,x)\mapsto z_w(x)$ is continuous.

### C.1.3 The learner FIX$_\eta$ and its predictors

Let $\mu$ be a probability measure on a measurable space $\Theta$, and let $(w,x)\mapsto z_w(x)$ be jointly measurable. Write $\phi_w:=\operatorname{clip}\circ z_w$ and $\ell_i(w)=(\phi_w(x_i)-y_i)^2\in[0,4]$. For $t\ge0$ define
$$\Lambda_t(w)=\exp\Bigl(-\eta\sum_{i\le t}\ell_i(w)\Bigr)\in[e^{-4\eta t},1],\qquad Z_t=\int\Lambda_t\,d\mu\in[e^{-4\eta t},1],\qquad \Pi_t=\frac{\Lambda_t\,\mu}{Z_t}.$$
Here $\Lambda_0\equiv1$ and $\Pi_0=\mu$. $\Pi_t$ is the FIX$_\eta$ posterior after $t$ samples. Define:

* the posterior mean of clipped outputs (BMA) $\hat f_t(x)=\int\phi_w(x)\,\Pi_t(dw)\in[-1,1]$;
* the progressive mixture $\bar f_n=\frac1{n+1}\sum_{t=0}^n\hat f_t$ (the brief's progressive mixture, with clipped outputs), and the variant $\tilde f_n=\frac1n\sum_{t=0}^{n-1}\hat f_t$;
* the Gibbs risk $\int L_D(\phi_w)\,\Pi_n(dw)$, which is the expected test loss of one posterior draw, predicting with $\phi_w$.

All three predictors use the clipped outputs $\phi_w$. The brief (§2) defines the BMA as the posterior mean of $z_w$ and the Gibbs predictor as $z_w$ for a posterior draw $w$. Those unclipped predictors are not covered by the positive results below (Remark 3 after Theorem C.1; Section C.9, open item 6); the negative results of Section C.6 cover them (Theorem C.5(e)).

By Tonelli, $\hat f_t(x)$ is a Borel function of $(x,S_t)$, because it is a ratio of integrals of bounded jointly measurable functions. All quantities below are therefore measurable.

### C.1.4 Order of quantifiers and limits

All statements are non-asymptotic unless a limit is written explicitly. In the limits of Sections C.5–C.6, the **sample, $n$ and $\eta$ are fixed first**. Only then does $\sigma\to0$ at a fixed width $N$ (Section C.5), or $N\to\infty$ (Section C.6). The bounds proved there hold for every sample, so they also hold uniformly over samples. "In expectation" always means $\mathbb E_S$ over $S\sim D^{\otimes n}$, with $D$ fixed before the competitor and the comparison measure $Q$ are chosen.

---

## C.2 The exp-concave progressive-mixture oracle inequality

**Lemma C.2.1 (exp-concavity of squared loss on $[-1,1]$).** For $\eta>0$ and $y\in\mathbb R$ let $\psi_{y}(p)=e^{-\eta(p-y)^2}$. Then $\psi_y$ is concave on $[-1,1]$ for every $y\in[-1,1]$ if and only if $\eta\le1/8$.

*Proof.* Differentiating, $\psi_y'(p)=-2\eta(p-y)\psi_y(p)$ and
$$\psi_y''(p)=2\eta\bigl(2\eta(p-y)^2-1\bigr)\psi_y(p).$$
If $\eta\le1/8$ and $p,y\in[-1,1]$, then $(p-y)^2\le4$, so $2\eta(p-y)^2-1\le8\eta-1\le0$. Hence $\psi_y''\le0$ on $[-1,1]$ and $\psi_y$ is concave there. Conversely, if $\eta>1/8$, take $y=1$. Then $\psi_1''(-1)=2\eta(8\eta-1)e^{-4\eta}>0$, and by continuity $\psi_1''>0$ on some interval $[-1,-1+\epsilon)$. So $\psi_1$ is strictly convex there and not concave on $[-1,1]$. $\square$

The script `../checks/C/check_expconcavity.py` confirms the sign of $\psi''$ on a grid: concave at $\eta=0.125$, not concave at $\eta=0.12501$. It also confirms the Jensen inequality used below on random mixtures, with no violation at $\eta=1/8$ and violations at $\eta=0.2$.

**Consequence (Jensen step).** Let $\eta\le1/8$ and $y\in[-1,1]$, and let $\lambda$ be a probability measure on $[-1,1]$ with mean $\bar p\in[-1,1]$. Then $\int\psi_y\,d\lambda\le\psi_y(\bar p)$, by Jensen's inequality for the concave function $\psi_y$ on the interval $[-1,1]$.

**Lemma C.2.2 (Donsker–Varadhan).** Let $\mu$ be a probability measure. Let $h$ be measurable and either bounded, or bounded below with $\int e^h\,d\mu<\infty$. Then for every probability measure $Q$,
$$\int h\,dQ\le\mathrm{KL}(Q\Vert\mu)+\log\int e^h\,d\mu,\tag{C.2.1}$$
where $\mathrm{KL}(Q\Vert\mu)=+\infty$ unless $Q\ll\mu$. For bounded $h$, equality holds at $Q_h=e^h\mu/\int e^hd\mu$. In particular, for bounded measurable $h$ and $\lambda>0$,
$$\inf_Q\Bigl[\int h\,dQ+\tfrac1\lambda\mathrm{KL}(Q\Vert\mu)\Bigr]=-\tfrac1\lambda\log\int e^{-\lambda h}\,d\mu.\tag{C.2.2}$$

*Proof.* Assume $\mathrm{KL}(Q\Vert\mu)<\infty$; otherwise there is nothing to prove. Let $p=dQ/d\mu$. Then $\int(\log p)^-dQ=\int_{p<1}p\log(1/p)\,d\mu\le1/e$ and $\int(\log p)^+dQ<\infty$, so $\log p\in L^1(Q)$ and $\int\log p\,dQ=\mathrm{KL}$.

First let $h$ be bounded. Jensen's inequality for $\log$ under $Q$, which is concentrated on $\{p>0\}$, gives
$$\int h\,dQ-\mathrm{KL}(Q\Vert\mu)=\int\log\frac{e^h}{p}\,dQ\le\log\int\frac{e^h}{p}\,dQ=\log\int_{\{p>0\}}e^h\,d\mu\le\log\int e^h\,d\mu .$$
For $Q=Q_h$ we have $\log p=h-\log\int e^hd\mu$, and both inequalities are equalities.

If $h$ is bounded below with $\int e^hd\mu<\infty$, apply the bounded case to $h\wedge k$ and let $k\to\infty$. On the left, monotone convergence applies because $h\wedge k\uparrow h$ and $h$ is bounded below. On the right, $\int e^{h\wedge k}d\mu\le\int e^hd\mu$. This gives (C.2.1).

(C.2.2) follows from (C.2.1) applied to $-\lambda h$, together with its equality case. $\square$

**Theorem C.1 (progressive-mixture oracle inequality; arbitrary prior).** Let $\mu$ be any probability measure on $\Theta$, let $(w,x)\mapsto z_w(x)$ be jointly measurable, and let $0<\eta\le1/8$ and $n\ge0$.

(a) *Individual sequences.* For every sequence $(x_i,y_i)_{i\ge1}$ in $X\times[-1,1]$, every $T\ge1$ and every probability measure $Q$ on $\Theta$,
$$\sum_{t=0}^{T-1}\bigl(\hat f_t(x_{t+1})-y_{t+1}\bigr)^2\le-\frac1\eta\log Z_T\le\sum_{i=1}^T\int\ell_i\,dQ+\frac{\mathrm{KL}(Q\Vert\mu)}{\eta}.\tag{C.2.3}$$

(b) *Statistical form.* For every $D$ on $X\times[-1,1]$ and every probability measure $Q$ on $\Theta$ not depending on $S$,
$$\frac1{n+1}\sum_{t=0}^n\mathbb E_S\,L_D(\hat f_t)\le\int L_D(\phi_w)\,Q(dw)+\frac{\mathrm{KL}(Q\Vert\mu)}{\eta(n+1)},\tag{C.2.4}$$
and therefore
$$\mathbb E_S\,L_D(\bar f_n)\le\inf_Q\Bigl[\int L_D(\operatorname{clip}z_w)\,Q(dw)+\frac{\mathrm{KL}(Q\Vert\mu)}{\eta(n+1)}\Bigr]=-\frac{1}{\eta(n+1)}\log\int e^{-\eta(n+1)L_D(\operatorname{clip}z_w)}\,\mu(dw).\tag{C.2.5}$$

*Proof.*

*(a), one step.* Fix $t\ge0$. Since $\Lambda_{t+1}=\Lambda_te^{-\eta\ell_{t+1}}$,
$$\frac{Z_{t+1}}{Z_t}=\int e^{-\eta\ell_{t+1}(w)}\,\Pi_t(dw)=\int\psi_{y_{t+1}}\bigl(\phi_w(x_{t+1})\bigr)\,\Pi_t(dw).$$
Let $\lambda$ be the image of $\Pi_t$ under $w\mapsto\phi_w(x_{t+1})$. It is a probability measure on $[-1,1]$ with mean $\hat f_t(x_{t+1})$. Since $y_{t+1}\in[-1,1]$, the Jensen step after Lemma C.2.1 gives $Z_{t+1}/Z_t\le\psi_{y_{t+1}}(\hat f_t(x_{t+1}))$. Taking logarithms,
$$\bigl(\hat f_t(x_{t+1})-y_{t+1}\bigr)^2\le-\frac1\eta\log\frac{Z_{t+1}}{Z_t}.$$

*(a), telescoping.* Summing over $t=0,\dots,T-1$ and using $Z_0=1$ gives the first inequality in (C.2.3).

*(a), comparison.* Apply (C.2.1) with $h=-\eta\sum_{i\le T}\ell_i$, which is bounded:
$$-\log Z_T=-\log\int e^{-\eta\sum_{i\le T}\ell_i}\,d\mu\le\eta\sum_{i\le T}\int\ell_i\,dQ+\mathrm{KL}(Q\Vert\mu).$$
Dividing by $\eta$ gives the second inequality.

*(b), ghost sample.* Let $(x_{n+1},y_{n+1})\sim D$ be independent of $S$; it is used only in the analysis. Apply (C.2.3) with $T=n+1$ to the sequence $(x_1,y_1),\dots,(x_{n+1},y_{n+1})$ and take expectations; all terms are bounded.
* The predictor $\hat f_t$ is a function of $S_t$, which is independent of $(x_{t+1},y_{t+1})\sim D$. By Fubini, $\mathbb E(\hat f_t(x_{t+1})-y_{t+1})^2=\mathbb E_S\,L_D(\hat f_t)$ for $0\le t\le n$.
* Since $Q$ is fixed, Tonelli gives $\mathbb E\int\ell_i\,dQ=\int\mathbb E\ell_i\,dQ=\int L_D(\phi_w)\,Q(dw)$ for each $i\le n+1$.

Hence $\sum_{t=0}^n\mathbb E\,L_D(\hat f_t)\le(n+1)\int L_D(\phi_w)\,dQ+\mathrm{KL}(Q\Vert\mu)/\eta$, which is (C.2.4).

*(b), convexity.* $L_D$ is convex, so $L_D(\bar f_n)\le\frac1{n+1}\sum_{t=0}^nL_D(\hat f_t)$ pointwise in $S$. Take expectations and apply (C.2.4) for every $Q$. The closed form of the infimum is (C.2.2) with $h=L_D(\phi_\cdot)\in[0,4]$ and $\lambda=\eta(n+1)$. $\square$

**Remarks on Theorem C.1.**

1. *Scope.* Nothing is assumed about $\mu$, the parametrization, or $D$, beyond labels in $[-1,1]$ and measurability. The comparison measure $Q$ must not depend on $S$; it may depend on $D$. The right side of (C.2.5) is a *population* free energy: the variational problem that the posterior solves on the sample, solved with the population loss instead.
2. *Randomized and symmetrized variants with the same bound.* (i) Let $T$ be uniform on $\{0,\dots,n\}$ and independent of $S$. Then $\mathbb E\,L_D(\hat f_T)$ equals the left side of (C.2.4). So the posterior mean after a uniformly random number of samples obeys the same bound in expectation. (ii) The permutation average $\frac1{n!}\sum_{\pi}\bar f_n^{\pi}$ of the progressive mixtures computed on reordered samples is a symmetric function of $S$. Each $\bar f_n^\pi$ has the law of $\bar f_n$, so by convexity it obeys (C.2.5). Neither variant is the posterior mean, or a draw, of the posterior given the whole sample: (i) uses only the first $T$ sample points, half of the sample on average, and (ii) averages the posterior means given subsamples of every size from $0$ to $n$. For the posterior given the whole sample, see Theorem C.7, whose bound carries an additive $4\eta$.
3. *Where clipping is needed: in the predictor, not in the likelihood.*
   - *Predictor.* The Jensen step needs the image law $\lambda$ to live on $[-1,1]$, which is why the predictor is the mean of the clipped outputs. For a law on $\mathbb R$ it would need concavity of $\psi_y$ on all of $\mathbb R$, which fails for every $\eta>0$: $\psi_y''>0$ when $|p-y|>(2\eta)^{-1/2}$. If $\hat f_t$ is replaced by the posterior mean of the unclipped outputs, $\bar z_t=\int z_w\,d\Pi_t$, or by its clip $\operatorname{clip}\bar z_t$, Theorem C.1 is false for some priors. So is the bound (C.2.5) for the clip of the progressive mixture of the $\bar z_t$. One two-point example shows all three failures. Take $\Theta=\{w_1,w_2\}$, $\mu$ uniform, $z_{w_1}\equiv M$, $z_{w_2}\equiv-1$, $y\equiv-1$, $\eta=1/8$ and $Q=\delta_{w_2}$, so that the right side of (C.2.5) is at most $\log2/(\eta(n+1))$, which is $0.50$ at $n=10$, $0.055$ at $n=100$ and $5.5\cdot10^{-3}$ at $n=1000$.
     - *$\bar z_t$ and $\operatorname{clip}\bar z_t$ in place of $\hat f_t$.* The first inequality of (C.2.3) fails at $T=1$ for $M=10$ with either replacement: there $\bar z_0=4.5$, and $(\bar z_0-y)^2=30.25$ and $(\operatorname{clip}\bar z_0-y)^2=4$, against $-\frac1\eta\log(Z_1/Z_0)=1.75$. The right side of (C.2.3) is $8\log2\approx5.55$ for every $T$, since $\ell_i(w_2)=0$ and $\mathrm{KL}(Q\Vert\mu)=\log2$. With $\bar z_t$ the left side already exceeds it at $T=1$. With $\operatorname{clip}\bar z_t$ the left side is $4$ at $T=1$, so that only the first inequality fails there, but it is at least $8$ for every $T\ge2$. The averaged bound (C.2.4) also fails with $\operatorname{clip}\bar z_t$: at $M=10$ and $n=10$ its left side is $1.71$, against the right side $0.504$.
     - *The progressive mixture $\frac1{n+1}\sum_{t\le n}\bar z_t$ of the unclipped posterior means.* Its test loss is $2.71$ at $M=10^3$, $n=1000$, and $2.7\cdot10^6$ at $M=10^6$, $n=1000$, so it violates (C.2.5).
     - *The clip of this progressive mixture.* Its test loss is $4$ at $M=10^3$ and every $n\le100$, so it violates (C.2.5) for $1\le n\le100$.

     The logic referee's script `../checks/verify-C-logic/check_unclipped_counterexample.py` prints the bounds, the losses $2.71$ and $2.7\cdot10^6$, the loss $4$ of the clip of the progressive mixture at $n=10$ and $n=100$, and the values $30.25$ and $1.75$. The other values follow from the definitions: $\bar z_0=(M-1)/2$, so $\operatorname{clip}\bar z_0=1$; and since $\bar z_t\ge-1$ for every $t$, the progressive mixture $\frac1{n+1}\sum_{t\le n}\bar z_t$ is at least $((M-1)/2-n)/(n+1)$, which is at least $1$ for $M=10^3$ and $n\le249$, so its clip equals $1$ there. The scope referee's script `../checks/verify-C-scope/s1_two_point.py` prints the values $5.55$, $8$, $1.71$ and $0.504$ of the first item (its parts (a)–(c)).

     The same prior shows that the bound (C.7.2) of Theorem C.7 does not extend to the unclipped Gibbs risk $\int L_D(z_w)\,d\Pi_n$. Since $\operatorname{clip}M=1$ for every $M\ge1$, the posterior weight of $w_1$ after $n$ samples is $p_n=e^{-4\eta n}/(1+e^{-4\eta n})$ whatever $M$, and the unclipped Gibbs risk $p_n(M+1)^2$ tends to infinity with $M$ at every $n$. The right side of (C.7.2), with $L_D(z_w)$ in place of $L_D(\phi_w)$ and $Q=\delta_{w_2}$, is $4\eta+(\log2+2\log(1/\delta))/(\eta n)$ whatever $M$. For example, with $M=10e^{2\eta n}$ the unclipped Gibbs risk is $(10+e^{-2\eta n})^2/(1+e^{-4\eta n})$, which lies between $100$ and $101$ for every $n\ge10$, while at $n=100$ and $\delta=0.1$ that right side is $0.92$. Since $y\equiv-1$ and the outputs do not depend on $x$, none of these quantities depends on the sample, so the inequality fails on every sample. The same script prints these two values (its part (d)). For the network priors of Sections C.3–C.7 the unclipped predictors are open (Section C.9, open item 6).
   - *Likelihood.* Suppose instead that the likelihood uses the unclipped outputs, $\Lambda_t(w)=\exp(-\eta\sum_{i\le t}(z_w(x_i)-y_i)^2)$, while the predictor $\hat f_t=\int\phi_w\,d\Pi_t$ still averages clipped outputs. Then, for $\eta\le1/8$, (C.1.1) and the Jensen step give
     $$\frac{Z_{t+1}}{Z_t}=\int e^{-\eta(z_w(x_{t+1})-y_{t+1})^2}\,\Pi_t(dw)\le\int\psi_{y_{t+1}}\bigl(\phi_w(x_{t+1})\bigr)\,\Pi_t(dw)\le\psi_{y_{t+1}}\bigl(\hat f_t(x_{t+1})\bigr),$$
     so the first inequality of (C.2.3) holds unchanged. The comparison step uses (C.2.1) for $h=-\eta\sum_{i\le T}(z_w(x_i)-y_i)^2$, which is bounded above but not below. (C.2.1) extends to such $h$: apply it to the bounded $h\vee(-k)$ and let $k\to\infty$, using monotone convergence on the left and dominated convergence on the right, where $0<e^{h\vee(-k)}\le1$. Hence (C.2.3), (C.2.4) and the inequality in (C.2.5) hold for this posterior, with $(z_w(x_i)-y_i)^2$ in place of $\ell_i$ and $\int L_D(z_w)\,Q(dw)$ in place of $\int L_D(\phi_w)\,Q(dw)$. Theorem C.2 holds for it with $4\rho$ replaced by $2\rho\sqrt{L_D(g)}+\rho^2$, because on $U_\rho(g)$ Minkowski's inequality gives $\lVert z_w-y\rVert_{L^2(D)}<\sqrt{L_D(g)}+\rho$. This was pointed out by the computation referee and checked numerically in `../checks/verify-C-computation/v_unclipped.py`. Theorems C.6 and C.7 use the range $[0,4]$ of the clipped losses $\ell_i$ and are not claimed for the unclipped likelihood.
4. *What is not covered.*
   - The final posterior mean $\hat f_n$ alone. Section C.7 gives a high-probability bound for it with an additional $4\eta$.
   - $\eta>1/8$. Squared loss with outcomes and predictions in $[-1,1]$ is $\eta$-mixable for $\eta\le1/2$ (classical; recalled from the literature and not used here). But the mixable aggregation rule uses Vovk's substitution function, not the posterior mean. The Jensen step fails for $\eta>1/8$: see the numerical violations at $\eta=0.2$.
5. *Literature.* This is the classical exponential-weights / progressive-mixture argument for exp-concave losses. Relevant sources include Vovk (1990); Kivinen and Warmuth (1999); Catoni's progressive mixture rule (Saint-Flour lecture notes, 2004); Yang (2000); Juditsky, Rigollet and Tsybakov (2008, mirror averaging); and Audibert (2009). The proof above is self-contained and no step depends on these references.

---

## C.3 Teacher tubes under network priors

### C.3.1 Cloning

This is `paper.tex` §3 (lines 297–308). Let $g$ be a competitor (depth $L$, width $m$, weights in $[-B,B]$, $B\ge1$) and let $N\ge m$. Partition $\{1,\dots,N\}$ into $m$ groups $G_1,\dots,G_m$ of sizes $k_j\in\{\lfloor N/m\rfloor,\lceil N/m\rceil\}$. The clone $w_*$ is defined as follows:
* every neuron of group $G_j$ copies teacher neuron $j$ in the first layer: $W^1_{*,a}=T^1_j$ for $a\in G_j$;
* $W^\ell_{*,ab}=T^\ell_{jk}/k_k$ for $a\in G_j$ and $b\in G_k$;
* $v_{*,a}=u_j/k_j$ for $a\in G_j$.

By induction on $\ell$, $h^\ell_{*,a}(x)$ equals the teacher's $j$-th activation for every $a\in G_j$, so $z_{w_*}=g$ on all of $\mathbb R^d$. The group sizes satisfy $k_j/k_k\le2$ and $N/\min_jk_j\le2m$. Three consequences:
* *Energy* (eq. `teacher-energy`): $\kappa_N(w_*)\le E_*:=d(d+1)B^2+2(L-1)m^2B^2$. Indeed $\frac dN\lVert W^1_*\rVert_F^2\le d(d+1)B^2$; $\lVert W^\ell_*\rVert_F^2=\sum_{j,k}(T^\ell_{jk})^2k_j/k_k\le2m^2B^2$; and $N\lVert v_*\rVert^2=N\sum_ju_j^2/k_j\le2m^2B^2$.
* *Operator norm.* Writing $W^\ell_*=\sum_{j,k}T^\ell_{jk}\sqrt{k_j/k_k}\,u_ju_k^{\mathsf T}$ with $u_j=k_j^{-1/2}\mathbf 1_{G_j}$ gives $\lVert W^\ell_*\rVert_{\rm op}\le\sqrt2\lVert T^\ell\rVert_{\rm op}\le\sqrt2\,mB$.
* *Readout.* $\sqrt N\lVert v_*\rVert_2\le\sqrt2\,mB$.

The script `../checks/C/check_tube_lemma.py` checks all three numerically, as well as $z_{w_*}=g$.

### C.3.2 The tube-mass lemma at an arbitrary scale

**Lemma C.3.1 (teacher-tube mass).** Let $\nu$ satisfy `paper.tex` eq. `law`. Let $g$ be a competitor, $N\ge m$, $\sigma>0$ and $0<\rho\le1$. Put
$$c_\nu=\tfrac38\min\{1,\sqrt{m_\nu}\},\quad b_0=2\sqrt{\tfrac{2}{m_\nu}\bigl[2\log9+\log(4L)\bigr]},\quad A_0=2+3mB+b_0,\quad P_0=1+2mB(d+L+1)A_0^{L-2},\quad h_\rho=\frac{\rho}{2P_0}.$$
Note that $h_\rho=\min\{1/2,\rho/(2P_0)\}$ because $P_0\ge1\ge\rho$. Then
$$-\log\mu^N_\sigma\bigl(U_\rho(g)\bigr)\le\frac{M_\nu E_*}{2\sigma^2}+N\bigl[d+2+(L-2)m\bigr]\Bigl(\log\frac1{c_\nu h_\rho}+(L-1)\log^+\!\bigl(\sigma\sqrt N\bigr)\Bigr)+\log2.\tag{C.3.1}$$
In particular, if $\sigma^2\le1/N$, then $\mu^N_\sigma(U_\rho(g))\ge\exp\{-A_L(d,m,B,\rho)/\sigma^2\}$ with
$$A_L(d,m,B,\rho):=1+\frac{M_\nu}2E_*+\bigl[d+2+(L-2)m\bigr]\log\frac1{c_\nu h_\rho}+\log2,\qquad E_*=d(d+1)B^2+2(L-1)m^2B^2.\tag{C.3.2}$$
For the finite-scale prior ($\sigma^2=N^{-\gamma}$, $\gamma\ge1$) this reads $\mu_{N,\gamma}(U_\rho(g))\ge e^{-A_L(d,m,B,\rho)N^\gamma}$. This is exactly `paper.tex` Proposition `tube` (eq. `tube-mass`, lines 339–346) with the constant of eq. `A` (lines 399–401). The paper's teacher width $C$ is renamed $m$ and its cylinder half-width $\eta$ is renamed $h_\rho$. By `paper.tex` Remark `cube` (lines 225–232) the statement holds for every compact $X\subseteq[-1,1]^d$, since the proof uses only $\lVert\bar x\rVert_1\le d+1$.

*Status and proof.* For $\sigma^2=N^{-\gamma}$ with $\gamma\ge1$, this is the cited proposition; I re-derived each of its steps. The extension to arbitrary $\sigma$ (the term $\log^+(\sigma\sqrt N)$) changes only the cylinder half-widths. Appendix C.A gives a complete proof. The "in particular" part: if $\sigma\sqrt N\le1$, the $\log^+$ term vanishes, and $N\le\sigma^{-2}$ and $1\le\sigma^{-2}$ turn the right side of (C.3.1) into at most $\sigma^{-2}(A_L-1)$.

**An explicit polynomial majorant.** For $0<\rho\le1$ we have $1/(c_\nu h_\rho)=2P_0/(c_\nu\rho)$. Using $P_0\le3mB(d+L+1)A_0^{L-2}$ and $A_0\le(5+b_0)mB$ (both because $mB\ge1$),
$$\log\frac1{c_\nu h_\rho}\le\Lambda_L(d,m,B,\rho):=\log\frac1\rho+(L-1)\log(mB)+\log(d+L+1)+(L-2)\log(5+b_0)+\log\frac{16}{\min\{1,\sqrt{m_\nu}\}}.\tag{C.3.3}$$
Hence $A_L\le1+\log2+\frac{M_\nu}2E_*+[d+2+(L-2)m]\,\Lambda_L$. At fixed $L$ and $\nu$,
$$A_L(d,m,B,\rho)=O\Bigl(d^2B^2+m^2B^2+(d+m)\log\frac{(d+1)mB}{\rho}\Bigr).$$
For Gaussian coordinates, $c_\nu=3/8$ and $b_0=2\sqrt{2(2\log9+\log 4L)}$; for example $b_0\approx7.42$ at $L=3$. Numerical values are in Section C.8.

### C.3.3 From the tube to the loss

**Lemma C.3.2.** If $w\in U_\rho(g)$, then for all $(x,y)\in X\times[-1,1]$
$$(\phi_w(x)-y)^2<(\operatorname{clip}g(x)-y)^2+4\rho\le(g(x)-y)^2+4\rho .$$
Consequently $L_D(\phi_w)\le L_D(\operatorname{clip}\circ g)+4\rho\le L_D(g)+4\rho$. Also $L_D(\phi_w)\le\bigl(\sqrt{L_D(\operatorname{clip}\circ g)}+\rho\bigr)^2$.

*Proof.* Put $a=\phi_w(x)$ and $b=\operatorname{clip}g(x)$; both lie in $[-1,1]$. Then $(a-y)^2-(b-y)^2=(a-b)(a+b-2y)$, with $|a+b-2y|\le4$, and $|a-b|\le|z_w(x)-g(x)|<\rho$ because $\operatorname{clip}$ is 1-Lipschitz. The second inequality is (C.1.1). Integrating against $D$ gives the first consequence. For the last, apply Minkowski's inequality in $L^2(D)$: $\lVert\phi_w-y\rVert\le\lVert\operatorname{clip}g-y\rVert+\lVert\phi_w-\operatorname{clip}g\rVert_\infty$. $\square$

---

## C.4 The agnostic bound at polynomial width

**Theorem C.2 (FIX$_\eta$ at finite scale).** Let $L\ge2$, $\gamma\ge1$, let $\nu$ satisfy eq. `law`, and let $0<\eta\le1/8$ and $n\ge0$. Let FIX$_\eta$ use the prior $\mu_{N,\gamma}$. Then for every $d$, every compact $X\subseteq[-1,1]^d$, every $D$ on $X\times[-1,1]$, every competitor $g$ of depth $L$, width $m\le N$ and weights at most $B$ ($B\ge1$), and every $0<\rho\le1$,
$$\mathbb E_S\,L_D(\bar f_n)\le L_D(g)+4\rho+\frac{A_L(d,m,B,\rho)\,N^\gamma}{\eta(n+1)},\tag{C.4.1}$$
with $A_L$ given by (C.3.2). The same bound holds for $\frac1{n+1}\sum_{t\le n}\mathbb E\,L_D(\hat f_t)$ and for the posterior mean after a uniformly random number of samples (Remark 2 after Theorem C.1). In the right side, $4\rho$ may be replaced by $\min\{4\rho,\ 2\rho\sqrt{L_D(\operatorname{clip}\circ g)}+\rho^2\}$.

*Proof.* By Lemma C.3.1, $\mu_{N,\gamma}(U_\rho(g))\ge e^{-A_LN^\gamma}>0$. Let $Q=\mu_{N,\gamma}(\cdot\mid U_\rho(g))$. It does not depend on $S$, its density with respect to the prior is $\mathbf 1_{U_\rho}/\mu_{N,\gamma}(U_\rho)$, and so $\mathrm{KL}(Q\Vert\mu_{N,\gamma})=\log\frac1{\mu_{N,\gamma}(U_\rho(g))}\le A_LN^\gamma$. By Lemma C.3.2, $\int L_D(\phi_w)\,Q(dw)\le L_D(g)+4\rho$; the refined form follows in the same way. Insert both bounds in (C.2.4)–(C.2.5). $\square$

**Corollary C.2.1 (polynomial sample size).** Under the hypotheses of Theorem C.2, let $0<\varepsilon\le1$. If
$$n+1\ge\frac{2\,A_L(d,m,B,\varepsilon/8)\,N^\gamma}{\eta\,\varepsilon},$$
then $\mathbb E_S\,L_D(\bar f_n)\le L_D(g)+\varepsilon$.

*Proof.* Take $\rho=\varepsilon/8$ in (C.4.1). $\square$

By (C.3.3), the sufficient $n$ is $O_{L,\nu}\bigl(\frac{N^\gamma}{\eta\varepsilon}[d^2B^2+m^2B^2+(d+m)\log\frac{(d+1)mB}{\varepsilon}]\bigr)$. This is polynomial in $d,m,B,1/\varepsilon$ **and in the learner width $N$**. The smallest admissible learner width $N=m$ gives $n=O_{L,\nu}\bigl(\frac{m^\gamma}{\eta\varepsilon}[d^2B^2+m^2B^2+(d+m)\log\frac{(d+1)mB}{\varepsilon}]\bigr)$.

**Corollary C.2.2 (the user's formulation).** Fix $L\ge2$, $\gamma\ge1$, $\nu$, $0<\eta\le1/8$ and $0<\alpha\le1$. For $r\ge1$ let $\mathcal G_L(r)$ be the set of functions computed by depth-$L$ competitors (§C.1.2: tanh, biases only in the first layer, linear readout) of width at most $r$ with all weights in $[-r,r]$. For $n\ge2$ let the learner be FIX$_\eta$ with prior $\mu_{N_n,\gamma}$, width $N_n=\lceil n^\alpha\rceil$, and predictor $\bar f_n$. Then for every $d\ge1$, every compact $X\subseteq[-1,1]^d$, and every $D$ on $X\times[-1,1]$,
$$\mathbb E_S\,L_D(\bar f_n)\le\inf_{g\in\mathcal G_L(n^\alpha)}L_D(g)+\varepsilon_n(d),\qquad
\varepsilon_n(d):=\frac4n+\frac{(2n^\alpha)^\gamma\,A_L(d,n^\alpha,n^\alpha,1/n)}{\eta(n+1)}\le K\,\frac{d^2\,n^{(4+\gamma)\alpha}\log(dn)}{\eta\,n},\tag{C.4.2}$$
with a constant $K=K(L,\gamma,\nu)$. In particular, when $\alpha<1/(4+\gamma)$ and $d$ is fixed (or $d^2\log d=o(n^{1-(4+\gamma)\alpha}/\log n)$), **the expected test loss of $\bar f_n$ is at most the infimum of the test loss over all depth-$L$ networks of the architecture of §C.1.2 with width and weights at most $n^\alpha$, plus $o(1)$**, uniformly over $D$. For mean-field scaling $\gamma=1$ the condition is $\alpha<1/5$, and the bound on the excess is $O_\nu(d^2n^{5\alpha-1}\log(dn)/\eta)$ at fixed $L$.

*Proof.* Let $g\in\mathcal G_L(n^\alpha)$ have width $m\le n^\alpha\le N_n$ and weight bound $B=n^\alpha\ge1$. $A_L(d,m,B,\rho)$ is nondecreasing in $m$ and $B$: $E_*$, the bracket $[d+2+(L-2)m]$ and $P_0$ are all nondecreasing in them. Also $N_n\le2n^\alpha$. Theorem C.2 with $\rho=1/n$ gives $\mathbb E\,L_D(\bar f_n)\le L_D(g)+\varepsilon_n(d)$ for each such $g$, hence for the infimum.

For the majorant, use (C.3.3) with $m=B=n^\alpha\le n$ and $\rho=1/n$:
* $\Lambda_L\le K_1\log(dn)$, because every term is either a multiple of $\log n$, at most $\log(d+L+1)$, or a constant, and $\log(dn)\ge\log 2$;
* $E_*\le2Ld^2n^{4\alpha}$;
* $d+2+(L-2)n^\alpha\le(L+1)dn^\alpha$.

Hence $A_L\le K_2d^2n^{4\alpha}\log(dn)$. Then $\varepsilon_n\le\frac4n+\frac{2^\gamma K_2d^2n^{(4+\gamma)\alpha}\log(dn)}{\eta n}$. Finally $\frac4n=\frac{4\eta}{\eta n}\le\frac{1}{2\eta n}$, which is at most $\frac{d^2n^{(4+\gamma)\alpha}\log(dn)}{2\log2\cdot\eta n}$. Explicitly, using $d+L+1\le d(L+2)$, one may take $K_1=2L-1+\bigl[\log(L+2)+(L-2)\log(5+b_0)+\log(16/\sqrt{m_\nu})\bigr]/\log2$, $K_2=(1+\log2+M_\nu L)/\log2+(L+1)K_1$ and $K=2^\gamma K_2+1/(2\log2)$; these are the computation referee's values (`../verification/C-computation.md`, §2.5), checked there on a grid. $\square$

The rate $\varepsilon_n(d)$ is tabulated numerically in Section C.8. With separate exponents (competitor width $\le n^{a}$, competitor weights $\le n^{b}$, learner width $\lceil n^{\beta}\rceil$ with $\beta\ge a$), the same computation bounds the excess by $\frac4n+\frac{(2n^\beta)^\gamma A_L(d,n^a,n^b,1/n)}{\eta(n+1)}=O_{L,\gamma,\nu}\bigl(d^2n^{2a+2b+\gamma\beta-1}\log(dn)/\eta\bigr)$. At fixed $d$ this bound tends to $0$ if and only if $2a+2b+\gamma\beta<1$. When $2a+2b+\gamma\beta\ge1$ it is at least $2^{\gamma-1}M_\nu(L-1)/\eta$, because $A_L\ge\frac{M_\nu}2E_*\ge M_\nu(L-1)n^{2a+2b}$ and $n+1\le2n$. The condition therefore concerns the bound; nothing is proved here about the excess itself when $2a+2b+\gamma\beta\ge1$.

**Remark C.4.1 (example: parity).** Let $D$ be uniform on $\{-1,1\}^d$ with $y=\chi(x)=\prod_jx_j$. `NNG/main-results/subcritical-exponential/source/parity-circuit.tex` (Appendix `sec:paritycircuit`) builds a width-$(d+1)$, depth-2 tanh network with weights $O(d\log d)$ that is uniformly within $1/8$ of $\chi$, so $L_D(g)<1/64$.
* *Smaller error.* With the step gain $A=\log(2d/\varepsilon')$ in place of $\log(16(d+1))$, the same construction is within $2de^{-A}=\varepsilon'$, with weights $O(d\log(d/\varepsilon'))$. This uses $1-\tanh a\le2e^{-2a}$.
* *Depth $L\ge3$.* The appendix feeds the output $s$ of the depth-2 circuit into one more hidden neuron, the summing neuron, and then passes the sign forward with margin $>1/2$. Here $s$ has the sign of $\chi$ and $|s|>7/8$. Put $A'=\log(2/\varepsilon')$ and keep the readout weight $1$.
  - At $L=3$ the summing neuron is the last hidden neuron, and it has $d+1$ incoming weights, the readout weights of the depth-2 circuit. Multiplying all of them by $A'$ makes the output uniformly within $2e^{-7A'/4}\le\varepsilon'$ of $\chi$ (for $\varepsilon'\le2$); these weights become at most $A'/\tanh1$ in absolute value.
  - At $L\ge4$ the last hidden neuron has the single incoming weight $2$, and its input has magnitude $>1/2$ and the sign of $\chi$. Replacing that weight by $A'$ makes the output uniformly within $2e^{-A'}=\varepsilon'$ of $\chi$.

  Both cases use $1-\tanh a\le2e^{-2a}$ for $a\ge0$.

So, at learner width $N=d+1$ and $\gamma=1$, Theorem C.2 gives $\mathbb E\,L_D(\bar f_n)\le\varepsilon'^2+\varepsilon$ with $n=\mathrm{poly}(d,1/\varepsilon,\log(1/\varepsilon'))$ samples. This contrasts with the width-first $\gamma<1$ lower bound recalled in Remark C.6.4.

**Remark C.4.2 (every $\gamma$, at polynomial width).** For the finite-scale family with $\gamma<1$ (including $\gamma\le0$), we have $\sigma\sqrt N=N^{(1-\gamma)/2}\ge1$, with equality only at $N=1$. Then (C.3.1) gives
$$-\log\mu_{N,\gamma}(U_\rho(g))\le\frac{M_\nu E_*}2N^\gamma+N\bigl[d+2+(L-2)m\bigr]\Bigl(\log\frac1{c_\nu h_\rho}+\frac{(L-1)(1-\gamma)}2\log N\Bigr)+\log2 .$$
So Theorem C.1 again yields an agnostic bound whose complexity term is $N\cdot\mathrm{poly}_{L,\gamma,\nu}(d,m,B,\log(N/\rho))/(\eta(n+1))$. **At polynomial learner width, the progressive mixture $\bar f_n$ of FIX$_\eta$ ($0<\eta\le1/8$) is polynomially agnostic in expectation for every real $\gamma$, and so is $\tilde f_n$ with probability $\ge1-2\delta$** (Theorem C.6 with the comparison measure $\mu_{N,\gamma}(\cdot\mid U_\rho(g))$ of the proof of Theorem C.2). For the final posterior, Theorem C.7 with the same measure gives only a bound with the additive $4\eta$. The failures recalled in Section C.6 are failures of the large-width (width-first) limit.

---

## C.5 Other priors: the strong-prior family with a fixed tempered likelihood, and the fan-in prior

### C.5.1 Strong-prior family at fixed width

**Proposition C.3.** Fix $L\ge2$, $\nu$, a width $N$, $\eta>0$ and $n\ge0$. Let FIX$_\eta$ use the scale-$\sigma$ prior $\mu^N_\sigma$ of (C.1.2); for Gaussian $\nu$ this is the strong prior $\mu_\sigma\propto e^{-\kappa_N/(2\sigma^2)}$.

(a) *Positive bound at moderate scales.* If $0<\eta\le1/8$, $N\ge m$ and $\sigma^2\le1/N$, then for every $D$, competitor $g$ and $\rho\in(0,1]$,
$$\mathbb E_S\,L_D(\bar f_n)\le L_D(g)+4\rho+\frac{A_L(d,m,B,\rho)}{\eta\,\sigma^2\,(n+1)} .$$
For arbitrary $\sigma>0$ the same holds with $A_L/\sigma^2$ replaced by the right side of (C.3.1).

(b) *Degeneration as $\sigma\to0$ with $\eta$ fixed.* For every sample, every $t\le n$, and $k=\eta t/m_\nu$,
$$\sup_{x\in X}|\hat f_t(x)|\le\sigma^2\bigl(4k+\sqrt{2k}\bigr),\qquad \mathrm{KL}(\Pi_t\Vert\mu^N_\sigma)\le\eta t\sigma^2\bigl(1+8k+2\sqrt{2k}\bigr),$$
$$\sup_{x\in X}\int z_w(x)^2\,\Pi_t(dw)\le\frac{4\sigma^2}{m_\nu}\Bigl(\mathrm{KL}(\Pi_t\Vert\mu^N_\sigma)+\tfrac12\log2\Bigr).$$
Consequently, take $\sigma\downarrow0$ with $N$, $n$, $\eta$ and the sample all fixed. Then:
* $\mathrm{TV}(\Pi_t,\mu^N_\sigma)\to0$, while $\mu^N_\sigma\to\delta_0$ weakly;
* $\bar f_n$ and $\hat f_n$ tend to $0$ uniformly on $X$;
* the test losses of the progressive mixture, the BMA and the Gibbs predictor all tend to $\mathbb E_D[y^2]=L_D(0)$, uniformly over samples.

For $y\equiv1$, the excess over the exact width-one competitor of Theorem C.5(c) tends to $1$.

(c) *Location of the transition.* For the constant target and $0<\eta\le1/8$, (a) with $\rho=1/16$ gives excess $\le1/2$ whenever $4A_L(d,1,2,1/16)/(\eta(n+1))\le\sigma^2\le1/N$. Part (b) gives excess $\ge1/2$ on every sample whenever $\sigma^2(4k_n+\sqrt{2k_n})\le1/4$, where $k_n=\eta n/m_\nu$. So, when $\sigma^2\le1$ (in particular throughout the range $\sigma^2\le1/N$ of (a)), the excess of $\bar f_n$, $\hat f_n$ or the Gibbs predictor on this target can be below $1/2$ on some sample only if $\eta\,\sigma^2n>(2-\sqrt3)\,m_\nu/16\approx0.0167\,m_\nu$. Without $\sigma^2\le1$, part (b) alone does not give this implication: $k_n=1/(16\sigma^4)$ gives $\sigma^2\sqrt{2k_n}=\sqrt2/4>1/4$, so the sufficient condition $\sigma^2(4k_n+\sqrt{2k_n})\le1/4$ fails, while $\eta\sigma^2n=m_\nu/(16\sigma^2)\to0$ as $\sigma\to\infty$. The strong-prior-first limit ($\sigma\to0$ at fixed $n$) learns nothing.

*Proof.* (a) is the proof of Theorem C.2 with Lemma C.3.1 at scale $\sigma$. (b) is Lemma C.6.1 below with readout scale $s=\sigma N^{-1/2}$, so $\sigma_{\rm out}^2=Ns^2=\sigma^2$; total variation is bounded by Pinsker, $\mathrm{TV}\le\sqrt{\mathrm{KL}/2}$. For the limits, any $f$ with $\sup_X|f|\le\beta$ satisfies $|L_D(f)-L_D(0)|=|\mathbb E_D[f(x)^2-2yf(x)]|\le\beta^2+2\beta$. For the Gibbs risk,
$$\Bigl|\int L_D(\phi_w)\,d\Pi_n-L_D(0)\Bigr|=\Bigl|\mathbb E_D\Bigl[\int\phi_w(x)^2\,d\Pi_n-2y\hat f_n(x)\Bigr]\Bigr|\le\sup_x\int z_w(x)^2\,d\Pi_n+2\sup_X|\hat f_n|,$$
and both terms tend to $0$ by (b). Weak convergence $\mu^N_\sigma\to\delta_0$ holds because $w=\sigma\cdot(\text{fixed linear map})(\Xi)$. (c) is arithmetic, using Theorem C.5(c) for the competitor. For the implication under $\sigma^2\le1$, put $u=\sigma^2k_n$, so that $\eta\sigma^2n=m_\nu u$. If $\sigma^2\le1$, then $\sigma^2\sqrt{2k_n}=\sqrt{2\sigma^2u}\le\sqrt{2u}$, so $\sigma^2(4k_n+\sqrt{2k_n})>1/4$ forces $4u+\sqrt{2u}>1/4$, that is, $\sqrt u>(\sqrt6-\sqrt2)/8$, or $u>(2-\sqrt3)/16$. $\square$

**Relation to SP$_c$ (Claim B, [`B-tempered-likelihood.md`](B-tempered-likelihood.md)).** SP$_c$ (B, §1) uses the Gaussian likelihood with variance $c\sigma^2$, that is, $e^{-(z_w(x_i)-y_i)^2/(2c\sigma^2)}$. This is the case $\eta=1/(2c\sigma^2)$ without clipping: SP$_c$ tempers the likelihood *together with* the prior scale, so $\eta\sigma^2=1/(2c)$ stays fixed. The missing clipping is not the obstacle: by Remark 3 after Theorem C.1, the argument also runs with the unclipped likelihood, as long as the predictor averages clipped outputs. At widths $N\le1/\sigma^2$, part (a) would then give the complexity term $2cA_L/(n+1)$, which depends on neither $N$ nor $\sigma$ in that range, with $4\rho$ replaced by $2\rho\sqrt{L_D(g)}+\rho^2$; at larger widths the complexity term is the right side of (C.3.1) divided by $\eta(n+1)$, which grows at least linearly in $N$. But Theorem C.1 needs $\eta\le1/8$, i.e. $\sigma^2\ge4/c$, which is incompatible with $\sigma\to0$ and confines the range $N\le1/\sigma^2$ to $N\le c/4$. So the exp-concave route does not reach SP$_c$, and Claims B and C are complementary rather than nested. Part (b) is the quantitative form, for the clipped likelihood of FIX$_\eta$, of `NNG/works-in-progress/slt-likelihood/README.md` §3 (lines 195–204: "For the fixed-width strong-prior family, the corresponding bound is $\mathbb Ez_w(x)^2\le\sigma^2$"). That section treats any fixed-temperature Gaussian or logistic likelihood (line 206) and concludes total-variation convergence to the prior. For the clipped likelihood, (b) adds the rate, and the vanishing of the posterior mean, which is what matters for squared loss.

### C.5.2 The standard fan-in (NNGP-scaling) prior

**Proposition C.4.** Let FIX$_\eta$ use the fan-in prior $\mu^{\rm fi}_N$ of §C.1.2, with $0<\eta\le1/8$. For every $D$, every competitor $g$ of depth $L$, width $m\le N$ and weights at most $B$, and every $\rho\in(0,1]$,
$$\mathbb E_S\,L_D(\bar f_n)\le L_D(g)+4\rho+\frac{E^{\rm fi}_N(g)+\frac{Q_N}2\log\frac{A^{\rm fi}}{\rho^2}}{\eta(n+1)},\tag{C.5.1}$$
where
$$E^{\rm fi}_N(g)=\tfrac12\Bigl[(d+1)\lVert T^1\rVert_F^2+N\sum_{\ell=2}^{L-1}\lVert T^\ell\rVert_F^2+N\lVert u\rVert_2^2\Bigr]\le\tfrac{B^2}2\bigl[m(d+1)^2+N\bigl((L-2)m^2+m\bigr)\bigr],$$
$$Q_N=m(d+1)+(L-2)mN+N,\qquad A^{\rm fi}=\sum_{j=0}^{L-1}(m^2B^2)^j .$$
The complexity term is linear in $N$, namely $O_L\bigl(N[m^2B^2+m\log\frac{2mB}\rho]+md^2B^2+md\log\frac{2mB}{\rho}\bigr)/(\eta n)$. So, at polynomial learner width, the progressive mixture $\bar f_n$ of FIX$_\eta$ with the standard fan-in prior is polynomially agnostic in expectation, and so is $\tilde f_n$ with probability $\ge1-2\delta$ (Theorem C.6 with the measure $q_t$ of the proof). For the final posterior, Theorem C.7 with the same measure gives only a bound with the additive $4\eta$.

*Proof.* Appendix C.B constructs, for $t\in(0,1]$, a product Gaussian $q_t$ that does not depend on $S$ and satisfies
$$\mathrm{KL}(q_t\Vert\mu^{\rm fi}_N)=E^{\rm fi}_N(g)+\tfrac{Q_N}2(t-1-\log t),\qquad \sup_{x\in[-1,1]^d}\mathbb E_{q_t}|z_w(x)-g(x)|^2\le A^{\rm fi}\,t.$$
These are the facts of `NNG/works-in-progress/slt-finite-sample/README.md` §3, re-derived in Appendix C.B. Take $t=\rho^2/A^{\rm fi}\in(0,1]$. The first display in the proof of Lemma C.3.2 holds for every $w$, not only in the tube:
$$(\phi_w(x)-y)^2\le(g(x)-y)^2+4|z_w(x)-g(x)| .$$
Integrating against $D\otimes q_t$ (Tonelli) and applying Cauchy–Schwarz in $q_t$,
$$\int L_D(\phi_w)\,dq_t\le L_D(g)+4\sup_x\bigl(\mathbb E_{q_t}|z_w(x)-g(x)|^2\bigr)^{1/2}\le L_D(g)+4\rho.$$
Also $t-1-\log t\le\log(1/t)$. Apply Theorem C.1 with $Q=q_t$. $\square$

*Large width under the fan-in prior.* Under $\mu^{\rm fi}_N$ the prior output variance at $x$ is $N^{-1}\sum_j\mathbb E\,h^{L-1}_j(x)^2$, which does not shrink with $N$. Lemma C.6.1 then gives no information ($\sigma_{\rm out}^2=1$). I prove neither a width-uniform positive bound nor a lower bound for FIX$_\eta$ under this prior as $N\to\infty$; see Remark C.6.4.

---

## C.6 Width dependence is necessary

**Lemma C.6.1 (small prior outputs force small posterior predictions).** Let $\mu$ be a product prior on the network parameters in which the readout is $v=s\,\xi$ with $s>0$, $\xi$ has independent $\nu$-coordinates, and $\xi$ is independent of the hidden weights. Put $\sigma_{\rm out}^2:=Ns^2$. Let $\eta>0$ be arbitrary (no exp-concavity is used), $t\ge0$, $x_1,\dots,x_t\in X$ and $y_1,\dots,y_t\in[-1,1]$. Put $k=\eta t/m_\nu$ and $F_t=\sup_{x\in X}|\hat f_t(x)|$. Then:

(i) $F_t\le\sigma_{\rm out}^2\bigl(4k+\sqrt{2k}\bigr)$;

(ii) $\mathrm{KL}(\Pi_t\Vert\mu)\le\eta t\,\sigma_{\rm out}^2\bigl(1+8k+2\sqrt{2k}\bigr)$, and hence $\mathrm{TV}(\Pi_t,\mu)\le\sqrt{\mathrm{KL}(\Pi_t\Vert\mu)/2}$;

(iii) $\sup_{x\in X}\int z_w(x)^2\,\Pi_t(dw)\le\frac{4\sigma_{\rm out}^2}{m_\nu}\bigl(\mathrm{KL}(\Pi_t\Vert\mu)+\tfrac12\log2\bigr)$.

The lemma applies to $\mu_{N,\gamma}$ with $s=N^{-(\gamma+1)/2}$, so $\sigma_{\rm out}^2=N^{-\gamma}$, and to $\mu^N_\sigma$ with $\sigma_{\rm out}^2=\sigma^2$.

*Proof.*

*Step 0: prior facts.* Condition on the hidden weights $\mathcal H$. Then $z_w(x)=\sum_ja_j\xi_j$ with $a_j=s\,h^{L-1}_j(x)$, and $\sum_ja_j^2\le Ns^2=\sigma_{\rm out}^2$ because $|h_j|\le1$.
* (P1) By eq. `subgaussian` applied to single coordinates, and by independence, $\mathbb E[e^{\theta z_w(x)}\mid\mathcal H]\le e^{\theta^2\sigma_{\rm out}^2/(2m_\nu)}$ for all $\theta\in\mathbb R$; hence the same bound holds under $\mu$.
* (P2) $\nu$ is centred with variance one, so $\int z_w(x)^2\,d\mu\le\sigma_{\rm out}^2$.
* (P3) $\xi\mapsto-\xi$ preserves $\mu$ and maps $z_w\mapsto-z_w$ and $\phi_w\mapsto-\phi_w$, since $\operatorname{clip}$ is odd. So $z_w(x)$ and $\phi_w(x)$ are symmetric under $\mu$, and $\int\phi_w(x)\,d\mu=0$.
* (P4) By (P3), with $\cosh$ even and increasing on $[0,\infty)$, $|\phi_w|\le|z_w|$, and (P1):
$$\int e^{\theta\phi_w(x)}\,d\mu=\int\cosh(\theta\phi_w(x))\,d\mu\le\int\cosh(\theta z_w(x))\,d\mu=\int e^{\theta z_w(x)}\,d\mu\le e^{\theta^2\sigma_{\rm out}^2/(2m_\nu)}.$$

*Step 1: KL in terms of $F_t$.* Let $\ell=\eta\sum_{i\le t}\ell_i$ and $\ell^0=\eta\sum_{i\le t}y_i^2$, the value of $\ell$ at zero output. Since $\Pi_t\propto e^{-\ell}\mu$,
$$\mathrm{KL}(\Pi_t\Vert\mu)=-\int\ell\,d\Pi_t-\log Z_t .$$
Jensen gives $-\log Z_t=-\log\int e^{-\ell}d\mu\le\int\ell\,d\mu$, so $\mathrm{KL}\le\int(\ell-\ell^0)\,d\mu-\int(\ell-\ell^0)\,d\Pi_t$. Now $\ell-\ell^0=\eta\sum_{i\le t}\bigl(\phi_w(x_i)^2-2y_i\phi_w(x_i)\bigr)$.
* By (P2)–(P3), $\int(\ell-\ell^0)\,d\mu=\eta\sum_i\int\phi_w(x_i)^2\,d\mu\le\eta t\sigma_{\rm out}^2$.
* Since $x_i\in X$, $-\int(\ell-\ell^0)\,d\Pi_t\le2\eta\sum_i|y_i||\hat f_t(x_i)|\le2\eta tF_t$.

Hence
$$\mathrm{KL}(\Pi_t\Vert\mu)\le\eta t\sigma_{\rm out}^2+2\eta tF_t.\tag{C.6.1}$$

*Step 2: $F_t$ in terms of KL.* Fix $x\in X$ and $\theta>0$. Apply (C.2.1) to the bounded functions $h=\pm\theta\phi_w(x)$, with $Q=\Pi_t$, and use (P4): $\pm\theta\hat f_t(x)\le\mathrm{KL}+\theta^2\sigma_{\rm out}^2/(2m_\nu)$. If $\mathrm{KL}>0$, take $\theta=\sqrt{2m_\nu\mathrm{KL}}/\sigma_{\rm out}$. If $\mathrm{KL}=0$, divide by $\theta$ and let $\theta\downarrow0$. Either way
$$F_t\le\sigma_{\rm out}\sqrt{2\,\mathrm{KL}(\Pi_t\Vert\mu)/m_\nu}.\tag{C.6.2}$$

*Step 3: solve.* Let $b=2\sigma_{\rm out}^2/m_\nu$. (C.6.1)–(C.6.2) give $F_t^2\le b\,\eta t\sigma_{\rm out}^2+2b\,\eta t\,F_t$, a quadratic inequality in $F_t\in[0,1]$. Hence
$$F_t\le b\eta t+\sqrt{(b\eta t)^2+b\eta t\sigma_{\rm out}^2}\le2b\eta t+\sigma_{\rm out}\sqrt{b\eta t}=\sigma_{\rm out}^2\bigl(4k+\sqrt{2k}\bigr),$$
which is (i). Inserting (i) in (C.6.1) gives the KL bound of (ii); Pinsker's inequality gives the TV bound.

*Step 4: (iii).* Let $\lambda=m_\nu/(4\sigma_{\rm out}^2)$ and let $G\sim\mathcal N(0,1)$ be independent. Then $e^{\lambda z^2}=\mathbb E_G\,e^{\sqrt{2\lambda}Gz}$, so by Tonelli and (P1)
$$\int e^{\lambda z_w(x)^2}\,d\mu\le\mathbb E_G\,e^{\lambda\sigma_{\rm out}^2G^2/m_\nu}=(1-2\lambda\sigma_{\rm out}^2/m_\nu)^{-1/2}=\sqrt2 .$$
Apply (C.2.1) to $h=\lambda z_w(x)^2$, which is bounded below with $\int e^hd\mu<\infty$: $\lambda\int z_w(x)^2\,d\Pi_t\le\mathrm{KL}+\frac12\log2$. $\square$

**Theorem C.5 (necessity of width dependence; finite-scale family).** Fix $L\ge2$, $\nu$, $\gamma>0$, $\eta>0$ (any) and $n\ge0$. Put $k_n=\eta n/m_\nu$ and $\beta_N=N^{-\gamma}(4k_n+\sqrt{2k_n})$. For every width $N\ge1$ and **every** sample:

(a) $\sup_X|\bar f_n|\le\beta_N$ and $\sup_X|\hat f_n|\le\beta_N$. For every $t\le n$,
$$\mathrm{KL}(\Pi_t\Vert\mu_{N,\gamma})\le\eta nN^{-\gamma}\bigl(1+8k_n+2\sqrt{2k_n}\bigr),\qquad\mathrm{TV}(\Pi_t,\mu_{N,\gamma})\le N^{-\gamma/2}\sqrt{\tfrac{\eta n}2\bigl(1+8k_n+2\sqrt{2k_n}\bigr)} .$$

(b) For every $D$:
* $|L_D(f)-\mathbb E_D y^2|\le2\beta_N+\beta_N^2$ for $f\in\{\bar f_n,\hat f_n\}$;
* the Gibbs risk is within $2\beta_N+\frac{4}{m_\nu N^\gamma}\bigl(\eta nN^{-\gamma}(1+8k_n+2\sqrt{2k_n})+\frac12\log2\bigr)$ of $\mathbb E_Dy^2$.

So as $N\to\infty$, with $\eta$, $n$ and the sample fixed, the posterior tends to the prior in total variation, the posterior means $\bar f_n$ and $\hat f_n$ tend to $0$ uniformly on $X$, $\sup_x\int z_w(x)^2\,d\Pi_n\to0$ (Lemma C.6.1(iii)), and the test losses of $\bar f_n$, $\hat f_n$ and the Gibbs predictor tend to $L_D(0)=\mathbb E_Dy^2$ uniformly over samples. The excess of each of them over any competitor $g$ tends to $L_D(0)-L_D(g)$.

(c) *Constant target.* Let $D$ have any $x$-marginal on $X$ and $y\equiv1$. The competitor $g_1\equiv1$ is computed exactly by a depth-$L$, width-$1$ network with weights at most $2$, so $L_D(g_1)=0$. On every sample, $L_D(\bar f_n)\ge(1-\beta_N)_+^2\ge1-2\beta_N$, and the same holds for $\hat f_n$ and for the Gibbs risk. In particular:
* the excess risk tends to $1$ as $N\to\infty$;
* it is at least $1/2$ whenever $N^\gamma\ge4(4k_n+\sqrt{2k_n})$, for instance whenever $N^\gamma\ge22\,k_n$ and $k_n\ge1$.

(d) *Location of the width threshold for this target.* Take the same $D$, $\gamma\ge1$ and $0<\eta\le1/8$. Theorem C.2 applied to $g_1$ ($m=1$, $B=2$, $\rho=1/16$) gives expected excess at most $1/2$ at every width with
$$N^\gamma\le\frac{\eta(n+1)}{4A_L(d,1,2,1/16)} .$$
Part (c) gives excess at least $1/2$, on every sample, at every width with
$$N^\gamma\ge4\bigl(4k_n+\sqrt{2k_n}\bigr) .$$
Both thresholds are linear in $\eta n$ (the second once $k_n\ge1$). With $A_L=A_L(d,1,2,1/16)$, their ratio is $16A_L(4k_n+\sqrt{2k_n})/(\eta(n+1))$. When $k_n\ge1$ it is less than $16(4+\sqrt2)A_L/m_\nu<87A_L/m_\nu$, and it tends to $64A_L/m_\nu$ as $\eta n\to\infty$; here $A_L(d,1,2,1/16)=O_{L,\nu}(d^2)$. So, for this target and the excess level $1/2$, the width threshold $N^\gamma\asymp\eta n$, at which (C.4.1) becomes nontrivial, is located up to a factor $O(A_L(d,1,2,1/16)/m_\nu)$. This is all that (d) shows. It does not show that the form of the complexity term in (C.4.1) is optimal below the threshold: an excess of order $\bigl(A_LN^\gamma/(\eta n)\bigr)^2$ there would be consistent with everything proved here. Nor does it say anything about competitors of larger complexity, for which the factor in (C.4.1) is $A_L(d,m,B,\rho)$.

(e) *Unclipped predictors.* Put
$$\Sigma_N:=\frac{4}{m_\nu N^\gamma}\Bigl(\eta nN^{-\gamma}\bigl(1+8k_n+2\sqrt{2k_n}\bigr)+\tfrac12\log2\Bigr),$$
which tends to $0$ as $N\to\infty$. On every sample, for every $t\le n$, $\sup_{x\in X}\int z_w(x)^2\,\Pi_t(dw)\le\Sigma_N$. Consequently the posterior means of the unclipped outputs, $\bar z_t(x):=\int z_w(x)\,\Pi_t(dw)$, their clips $\operatorname{clip}\bar z_t$, the progressive mixtures of either over $t\le n$, and the clip of the progressive mixture of the $\bar z_t$ are all bounded by $\Sigma_N^{1/2}$ in absolute value on $X$. The unclipped Gibbs risk satisfies $\bigl|\int L_D(z_w)\,d\Pi_n-\mathbb E_Dy^2\bigr|\le\Sigma_N+2\Sigma_N^{1/2}$ for every $D$. For the constant target of (c), each of these predictors $f$ has $L_D(f)\ge(1-\Sigma_N^{1/2})_+^2$, and the unclipped Gibbs risk is at least $L_D(\bar z_n)$. So their excess over $g_1$ also tends to $1$ as $N\to\infty$, on every sample. Here $\Pi_t$ is still the FIX$_\eta$ posterior; only the predictors are unclipped.

*Proof.* (a) Apply Lemma C.6.1 with $\sigma_{\rm out}^2=N^{-\gamma}$. Its bounds increase with $t$, so they hold for every $t\le n$ with $t$ replaced by $n$. Since $\bar f_n$ averages $\hat f_0,\dots,\hat f_n$, the bound passes to $\bar f_n$.

(b) Follows from (a) and Lemma C.6.1(iii), exactly as in the proof of Proposition C.3.

(c) *The competitor.* Take the first-layer row $(2,0,\dots,0)$, which acts on the constant coordinate, internal weights $2$, and readout $1/c_{L-1}$, where $c_1=\tanh2$ and $c_\ell=\tanh(2c_{\ell-1})$. The map $u\mapsto\tanh(2u)$ is increasing with fixed point $u^*\in(0.957,0.958)$. Since $c_1=\tanh2\approx0.964>u^*$, the sequence $c_\ell$ decreases to $u^*$, so $c_{L-1}\in(0.957,0.965)$ and the readout is at most $1.05\le2$.

*The lower bound.* $L_D(\bar f_n)=\mathbb E_x(1-\bar f_n(x))^2\ge(1-\beta_N)_+^2\ge1-2\beta_N$. By Jensen, the Gibbs risk satisfies $\mathbb E_x\int(\phi_w(x)-1)^2\,d\Pi_n\ge\mathbb E_x(1-\hat f_n(x))^2$. The numerical sufficient condition: if $k_n\ge1$ then $\sqrt{2k_n}\le\sqrt2k_n$, so $4(4k_n+\sqrt{2k_n})\le(16+4\sqrt2)k_n<22k_n$.

(d) Theorem C.2 with $\rho=1/16$ gives excess at most $\frac14+\frac{A_LN^\gamma}{\eta(n+1)}$. Combine with (c). For the ratio, divide the second threshold by the first; when $k_n\ge1$, $4k_n+\sqrt{2k_n}\le(4+\sqrt2)k_n$ and $k_n/(\eta(n+1))<1/m_\nu$.

(e) By Lemma C.6.1(ii) with $\sigma_{\rm out}^2=N^{-\gamma}$, $\mathrm{KL}(\Pi_t\Vert\mu_{N,\gamma})\le\eta nN^{-\gamma}(1+8k_n+2\sqrt{2k_n})$ for $t\le n$, since that bound increases with $t$. Lemma C.6.1(iii) then gives $\sup_x\int z_w(x)^2\,d\Pi_t\le\Sigma_N$. By Cauchy–Schwarz, $|\bar z_t(x)|\le\bigl(\int z_w(x)^2\,d\Pi_t\bigr)^{1/2}\le\Sigma_N^{1/2}$; clipping and averaging over $t$ do not increase the supremum norm. For the Gibbs risk, Fubini applies because $\iint z_w(x)^2\,\Pi_n(dw)\,D(dx,dy)\le\Sigma_N$, and gives $\int L_D(z_w)\,d\Pi_n-L_D(0)=\mathbb E_D\bigl[\int z_w(x)^2\,d\Pi_n-2y\,\bar z_n(x)\bigr]$, whose absolute value is at most $\Sigma_N+2\Sigma_N^{1/2}$ because $|y|\le1$. For the constant target, $L_D(f)=\mathbb E_x(1-f(x))^2\ge(1-\sup_X|f|)_+^2$, and Jensen's inequality, pointwise in $x$, gives $\int L_D(z_w)\,d\Pi_n\ge L_D(\bar z_n)$. $\square$

The Monte Carlo of `../checks/C/check_width_lower_bound.py` (Section C.8, item 4) checks bounds (i) and (ii) of Lemma C.6.1 for the constant target, at $L=2,3$, $n=20$, $\eta=1/8$ and $N$ up to $16384$. At these fixed $n$ and $\eta$ the measured maximum of $|\hat f_n|$ over the $20$ training and $10$ test points decreases like $N^{-\gamma}=N^{-1}$, the rate of bound (i), and stays at about one tenth of bound (i) on this sample. The sample is not adversarial: in an adversarial case the computation referee's exact computation reaches $0.49$ of bound (i) (`../verification/C-computation.md`, §2.4). The test loss approaches $1$.

**Remark C.6.2 (mechanism).** Under FIX$_\eta$, the likelihood ratio between any two parameters lies in $[e^{-4\eta n},e^{4\eta n}]$. Under $\mu_{N,\gamma}$, however, outputs of order one are exponentially rare. By (P1) in the proof of Lemma C.6.1, $\mu_{N,\gamma}\{|z_w(x)|\ge\tfrac12\}\le2e^{-m_\nu N^\gamma/8}$ at every input $x$, which matches the tube cost $A_LN^\gamma$ up to a factor $O(A_L/m_\nu)$ in the exponent. When $N^\gamma\gg\eta n$ the data cannot pay that price. The repository's width-uniform theorems avoid this by giving the likelihood a dynamic range that scales like the prior's:
* hard tolerance conditioning (`paper.tex` eq. `posterior`, Theorems `strong`, `finite`);
* Gaussian observation variance $N^{-\gamma}$, i.e. $\eta=N^\gamma/2$ (`slt-likelihood` §2, "Finite scales").

Both lie far outside the exp-concave range $\eta\le1/8$. `slt-likelihood` §4 (lines 289–304) observes that a fixed likelihood's prior-mass route "pays a width-dependent $N^\gamma$ factor". That section uses the unclipped Gaussian likelihood $\exp[-\beta\sum_i(z_w-f)^2]$ (line 289). For FIX$_\eta$, whose likelihood is the clipped version of it, Theorem C.5 shows that a width-dependent factor is a property of the learner, not an artifact of the route: at fixed $\eta n$ the excess on the constant target tends to $1$ as $N\to\infty$. For the unclipped likelihood of `slt-likelihood` §4, that note's §3 gives only the qualitative total-variation statement. The logic referee outlines how Lemma C.6.1 would extend to it: Step 1 goes through with $z_w$ in place of $\phi_w$, and Step 2 needs (C.2.1) for $h=\pm\theta z_w(x)$, which is unbounded below and lies in $L^1(\Pi_t)$ because $d\Pi_t/d\mu\le1/Z_t$. That extension is not written out here, so the conclusion drawn from Theorem C.5 in this remark is claimed only for FIX$_\eta$.

**Remark C.6.3 (relation to `slt-likelihood` §3).** That section (lines 195–215) proves, qualitatively, that a fixed smooth likelihood's posterior converges in total variation to the raw prior as $N\to\infty$ (for every $\gamma>0$) or as $\sigma\to0$ (strong prior). From this it rules out the $>2/3$ confidence guarantee. It states explicitly that it "does not prove failure of the sign of the posterior mean". Lemma C.6.1 is a quantitative version for the clipped Gaussian likelihood of FIX$_\eta$. It adds that the posterior mean of the clipped outputs is itself at most $\sigma_{\rm out}^2(4k+\sqrt{2k})$ in absolute value, which is $O(\eta n\,\sigma_{\rm out}^2/m_\nu)$ when $k=\eta n/m_\nu\ge1$; a bound of this kind on the posterior mean is what squared loss requires.

**Remark C.6.4 ($\gamma<1$, Gaussian-process-like regimes, and main result 4).**
* *FIX$_\eta$ for $0<\gamma<1$.* Theorem C.5 applies verbatim: in the width-first limit the posterior means of FIX$_\eta$ tend to $0$ uniformly on $X$. For $\gamma\le0$, and for the fan-in prior, prior outputs do not shrink, Lemma C.6.1 gives nothing, and the width-first limit is a Gaussian-process-type learner that this section does not analyse.
* *Main result 4* is `NNG/README.md`, "Main results" §4, proved as Theorem `thm:main` of `NNG/main-results/subcritical-exponential/source/subcritical-exponential.tex` (lines 127–137). It concerns a *different learner on the same prior*.
  - The weights are Gaussian with the variances of eq. `weights` (lines 104–108), which are those of $\mu_{N,\gamma}$.
  - The prior is conditioned on $|z_N(x)|>a$ for every $x\in\{-1,1\}^d$, for a fixed margin $a>0$. It is then conditioned on $\operatorname{sign}z_N(X_i)=f(X_i)$ for $i\le n$, where $f$ is full parity on $d$ bits and the $X_i$ are iid uniform (lines 109–113).
  - $F_N(S)$ is the fraction of test inputs whose correct label has posterior probability at most $2/3$ (lines 115–121).
  - The theorem: for every fixed $L\ge2$ and $a>0$ there are $c>0$ and $d_0$ such that, for every $d\ge d_0$, every integer $0\le n\le e^{cd}$ and every fixed $\gamma<1$,
  $$\mathbb P_S\bigl\{\liminf_{N\to\infty}F_N(S)\ge1/16\bigr\}\ge3/4 .$$
  - The width limit is taken at fixed $d$ and fixed sample (lines 139–145).
  - The labels are clean, and parity has a width-$(d+1)$ tanh realization with weights $O(d\log d)$ (Appendix `sec:paritycircuit`). This is therefore an exponential failure **even in the realizable case**.
* *What this does and does not show.* Below mean field, the width-first (kernel or GP-like) limit fails exponentially even with exact hard conditioning. So large-width failure is not peculiar to fixed tempered likelihoods. The theorem says nothing directly about FIX$_\eta$ or squared loss. In the other direction, Remarks C.4.1–C.4.2 show that FIX$_\eta$ with $0<\eta\le1/8$ at polynomial width learns parity in MSE (in expectation, for $\bar f_n$) from $\mathrm{poly}(d)$ samples, for every $\gamma$. For FIX$_\eta$ with $\gamma>0$ the obstruction is the large-width limit, in which the test losses of $\bar f_n$, $\hat f_n$ and the Gibbs predictor on parity tend to $\mathbb E_Dy^2=1$, the loss of the zero predictor (Theorem C.5(b)). For $\gamma\le0$ the large-width behaviour of FIX$_\eta$ is open (Section C.9, open item 4). Whether the learner of main result 4 learns parity at polynomial width is not addressed here.
* *Standard NNGP scaling.* The repository's side result `NNG/side-results/standard-nngp-parity` (README, "Results") proves superpolynomial parity lower bounds at this scaling. They are for width-first posteriors conditioned on training signs, with or without a global margin, not for FIX$_\eta$.

---

## C.7 High-probability versions

**Theorem C.6 (progressive mixture, high probability).** Let $\mu$ be any prior, $0<\eta\le1/8$, $n\ge1$, $\delta\in(0,1)$, and let $Q$ be a probability measure not depending on $S$. With probability at least $1-2\delta$ over $S$,
$$L_D(\tilde f_n)\le\frac1n\sum_{t=0}^{n-1}L_D(\hat f_t)\le\int L_D(\phi_w)\,Q(dw)+\frac{\mathrm{KL}(Q\Vert\mu)}{\eta n}+4\sqrt{\frac{2\log(1/\delta)}{n}},\tag{C.7.1}$$
and on the same event $L_D(\bar f_n)\le\frac{n}{n+1}\cdot\bigl[\text{right side of (C.7.1)}\bigr]+\frac4{n+1}$.

In the setting of Theorem C.2, with probability at least $1-2\delta$,
$$L_D(\tilde f_n)\le L_D(g)+4\rho+\frac{A_L(d,m,B,\rho)N^\gamma}{\eta n}+4\sqrt{\frac{2\log(1/\delta)}n} .$$
In particular $L_D(\tilde f_n)\le L_D(g)+\varepsilon$ with probability at least $1-2\delta$ as soon as
$$n\ge\max\Bigl\{\frac{4A_L(d,m,B,\varepsilon/8)N^\gamma}{\eta\varepsilon},\ \frac{512\log(1/\delta)}{\varepsilon^2}\Bigr\},$$
a sample size polynomial in $d,m,B,1/\varepsilon,\log(1/\delta)$ and $N$.

In the user's formulation (Corollary C.2.2), let $g^\star_n\in\mathcal G_L(n^\alpha)$ satisfy $L_D(g^\star_n)\le\inf_{\mathcal G_L(n^\alpha)}L_D+1/n$; it depends only on $D$ and $n$. Applying the above to $g^\star_n$ shows that, with probability at least $1-2\delta$,
$$L_D(\tilde f_n)\le\inf_{g\in\mathcal G_L(n^\alpha)}L_D(g)+\tfrac1n+\tfrac{n+1}{n}\varepsilon_n(d)+4\sqrt{2\log(1/\delta)/n}.$$

*Proof.*
* *Deterministic part.* Theorem C.1(a) with $T=n$ gives $\sum_{t=0}^{n-1}(\hat f_t(x_{t+1})-y_{t+1})^2\le\sum_{i=1}^n\int\ell_i\,dQ+\mathrm{KL}(Q\Vert\mu)/\eta$.
* *Martingale part.* Let $\mathcal F_t=\sigma(S_t)$ and $\Delta_t=L_D(\hat f_t)-(\hat f_t(x_{t+1})-y_{t+1})^2$ for $0\le t\le n-1$. Then $\mathbb E[\Delta_t\mid\mathcal F_t]=0$, by independence of $(x_{t+1},y_{t+1})$ and $\mathcal F_t$. Also $\Delta_t$ lies in the $\mathcal F_t$-measurable interval $[L_D(\hat f_t)-4,\,L_D(\hat f_t)]$ of length $4$. Conditional Hoeffding's lemma gives $\mathbb E[e^{s\Delta_t}\mid\mathcal F_t]\le e^{2s^2}$, so $\mathbb E\,e^{s\sum_{t<n}\Delta_t}\le e^{2ns^2}$. With $s=u/(4n)$, Chernoff gives $\mathbb P(\sum_{t<n}\Delta_t\ge u)\le e^{-u^2/(8n)}$. Take $u=\sqrt{8n\log(1/\delta)}$.
* *Comparison part.* The variables $\int\ell_i\,dQ$, $i\le n$, are iid in $[0,4]$ with mean $\int L_D(\phi_w)\,dQ$, by Tonelli. Hoeffding gives $\mathbb P\bigl(\sum_i\int\ell_i\,dQ-n\int L_D(\phi_w)\,dQ\ge u\bigr)\le e^{-u^2/(8n)}$, with the same $u$.
* *Combination.* On the intersection of the two good events (probability $\ge1-2\delta$),
$$\sum_{t<n}L_D(\hat f_t)\le2u+n\int L_D(\phi_w)\,dQ+\mathrm{KL}(Q\Vert\mu)/\eta .$$
Divide by $n$; note $2u/n=4\sqrt{2\log(1/\delta)/n}$. Convexity of $L_D$ gives the first inequality of (C.7.1). For $\bar f_n$, use $L_D(\bar f_n)\le\frac1{n+1}\bigl[\sum_{t<n}L_D(\hat f_t)+L_D(\hat f_n)\bigr]$ and $L_D(\hat f_n)\le4$.
* *Network case.* Take $Q=\mu_{N,\gamma}(\cdot\mid U_\rho(g))$ as in Theorem C.2. The sample-size condition makes the three terms at most $\varepsilon/2$, $\varepsilon/4$ and $\varepsilon/4$ respectively. $\square$

**Theorem C.7 (final posterior: Gibbs predictor and BMA, high probability).** Let $\mu$ be any prior, $\eta>0$ (any; exp-concavity is not used), $n\ge1$, $\delta\in(0,1)$, and let $Q$ not depend on $S$. With probability at least $1-2\delta$,
$$L_D(\hat f_n)\le\int L_D(\phi_w)\,\Pi_n(dw)\le\int L_D(\phi_w)\,Q(dw)+4\eta+\frac{\mathrm{KL}(Q\Vert\mu)+2\log(1/\delta)}{\eta n}.\tag{C.7.2}$$
In the setting of Theorem C.2, the right side becomes $L_D(g)+4\rho+4\eta+\frac{A_LN^\gamma+2\log(1/\delta)}{\eta n}$. Hence:
* (i) *Fixed temperature.* With $\eta=\varepsilon/16$ and $\rho=\varepsilon/16$, the Gibbs risk and the BMA risk are at most $L_D(g)+\varepsilon$ with probability $\ge1-2\delta$ once $n\ge32\bigl(A_L(d,m,B,\varepsilon/16)N^\gamma+2\log(1/\delta)\bigr)/\varepsilon^2$. A fixed inverse temperature $\eta=\varepsilon/16$, chosen from $\varepsilon$ alone, thus suffices for the actual final posterior at polynomial width.
* (ii) *Decreasing temperature.* With $\eta_n=\sqrt{N^\gamma/n}$, the excess is at most $4\rho+\bigl(4+A_L+2\log\frac1\delta\bigr)\sqrt{N^\gamma/n}$.

*Proof.* Write $R(w)=L_D(\phi_w)$, $\hat R(w)=\frac1n\sum_{i\le n}\ell_i(w)$ and $\lambda=\eta n$, so that $\Pi_n\propto e^{-\lambda\hat R}\mu$.
* *Uniform deviation.* For fixed $w$, the $\ell_i(w)$ are iid in $[0,4]$ with mean $R(w)$, and Hoeffding's lemma gives $\mathbb E_S\,e^{\lambda(R(w)-\hat R(w))}\le e^{2\lambda^2/n}$. By Tonelli and Markov, with probability $\ge1-\delta$, $\int e^{\lambda(R-\hat R)}\,d\mu\le e^{2\lambda^2/n}/\delta$. On this event, (C.2.1) with the bounded $h=\lambda(R-\hat R)$ gives, simultaneously for every probability measure $Q'$, including data-dependent ones,
$$\int R\,dQ'\le\int\hat R\,dQ'+\frac{2\lambda}n+\frac{\mathrm{KL}(Q'\Vert\mu)+\log(1/\delta)}{\lambda}.$$
* *Gibbs optimality.* By (C.2.2) and its equality case, $\Pi_n$ minimises $Q'\mapsto\int\hat R\,dQ'+\mathrm{KL}(Q'\Vert\mu)/\lambda$.
* *Fixed $Q$.* $\int\hat R\,dQ$ is an average of $n$ iid $[0,4]$ variables with mean $\int R\,dQ$. Hoeffding's lemma and Markov give, with probability $\ge1-\delta$, $\int\hat R\,dQ\le\int R\,dQ+2\lambda/n+\log(1/\delta)/\lambda$.
* *Chain.* On the intersection of the two events,
$$\int R\,d\Pi_n\le\int\hat R\,d\Pi_n+\frac{\mathrm{KL}(\Pi_n\Vert\mu)}\lambda+\frac{2\lambda}n+\frac{\log(1/\delta)}\lambda\le\int\hat R\,dQ+\frac{\mathrm{KL}(Q\Vert\mu)}\lambda+\frac{2\lambda}n+\frac{\log(1/\delta)}\lambda\le\int R\,dQ+\frac{4\lambda}n+\frac{\mathrm{KL}(Q\Vert\mu)+2\log(1/\delta)}\lambda .$$
* *BMA.* $L_D(\hat f_n)\le\int L_D(\phi_w)\,d\Pi_n$ by Jensen, pointwise in $(x,y)$.
* *Choices.* (i): $4\rho+4\eta=\varepsilon/2$, and the last term is at most $\varepsilon/2$ under the stated condition. (ii): use $N^\gamma\ge1$. $\square$

**Remarks on Section C.7.**
1. *In expectation.* Taking $\delta=1/n$ in (C.7.2) and bounding the loss by $4$ off the event gives $\mathbb E\int L_D(\phi_w)\,d\Pi_n\le\int L_D\,dQ+4\eta+\frac{\mathrm{KL}(Q\Vert\mu)+2\log n}{\eta n}+\frac8n$ for the final posterior.
2. *Not proved.* At a fixed $\eta\le1/8$, I do not know whether the final posterior (Gibbs or BMA) has vanishing agnostic excess in this generality, i.e. whether the additive $4\eta$ in (C.7.2) can be removed. In the finite-dictionary simulation of Section C.8 the final posterior mean does converge.
3. *Deviation order of progressive mixtures.* Audibert (NIPS 2007, "Progressive mixture rules are deviation suboptimal") shows that the deviations of progressive mixture rules can be of order $1/\sqrt n$. If so, the $\sqrt{\log(1/\delta)/n}$ term of (C.7.1) cannot in general be improved to $\log(1/\delta)/n$ for this predictor. I recall this from the literature; I did not re-check it, and nothing above depends on it.

---

## C.8 Numerical sanity checks

All scripts are in `../checks/C/`, with their outputs in the matching `.out` files. They use Python 3 with NumPy and SymPy. They are sanity checks of statements proved above, not evidence for them.

1. **`check_expconcavity.py` (Lemma C.2.1, Jensen step).**
   - SymPy gives $\psi''/\psi=2\eta(2\eta(p-y)^2-1)$, and the value $2\eta(8\eta-1)$ at $p=-1,y=1$.
   - On an $801\times801$ grid of $[-1,1]^2$, $\psi$ is concave for $\eta\in\{0.05,0.1,0.125\}$ and not concave for $\eta\in\{0.12501,0.13,0.2,0.5\}$.
   - Over $2\cdot10^5$ random mixtures (half at the extreme predictions $\pm1$), the smallest value of $\psi(\bar p)-\overline{\psi(p)}$ is $-4\cdot10^{-16}$ (rounding) at $\eta=1/8$, versus $-9.9\cdot10^{-4}$ at $\eta=0.2$ and $-1.0\cdot10^{-2}$ at $\eta=0.3$.
2. **`check_oracle_mc.py` (Theorem C.1; Theorems C.6–C.7).** The setup:
   - a finite dictionary of $K=300$ clipped tanh functions with a non-uniform prior;
   - $x$ uniform on 40 points of $[-1,1]$, and $y=\operatorname{clip}\sin3x$ with probability $0.6$, else $y\sim U[-1,1]$;
   - exact population losses, $\eta=1/8$, and $3000$ replications per $n$;
   - Bayes risk $0.2425$, best dictionary loss $0.2627$, $L_D(0)=0.4063$.

   The first inequality of (C.2.3), the per-sequence bound of the online loss by $-\frac1\eta\log W_{n+1}$, had no violation in any run; the second inequality of (C.2.3) was not tested per sequence. The table compares the averaged progressive-mixture risk with the bound (C.2.5):

   | $n$ | $\mathbb E\,L_D(\bar f_n)$ | bound (C.2.5) | final BMA | Gibbs |
   |---|---|---|---|---|
   | 5 | 0.3869 | 0.8441 | 0.3708 | 0.8029 |
   | 20 | 0.3426 | 0.6961 | 0.3147 | 0.5630 |
   | 80 | 0.3008 | 0.4813 | 0.2844 | 0.3523 |
   | 320 | 0.2752 | 0.3417 | 0.2666 | 0.2747 |

   Empirical failure frequencies of the high-probability bounds (C.7.1) and (C.7.2) were $0.000$ for every $n$ (allowed: $0.1$). These used $\delta=0.05$ and, as $Q$, the point mass on the element $j$ minimising $L_j+\log(1/\mu_j)/(\eta n)$.
3. **`check_tube_lemma.py` (Appendix C.A, Step 3; cloning facts).**
   - Configurations: 5 choices of $(d,m,B,L,N)$ with $L\in\{2,3,4,5\}$; scales $\sigma\sqrt N\in\{0.2,1,4\}$, covering both $\bar t=1$ and $\bar t>1$; and $h\in\{0.5,0.05\}$.
   - Each perturbation is drawn in the event $E$ with every constraint at its extreme value $\pm h/\bar t$, and errors are evaluated on 400 inputs including cube corners.
   - The clone computes $g$ exactly, and $\kappa_N(w_*)\le E_*$, $\lVert W^\ell_*\rVert_{\rm op}\le\sqrt2mB$ and $\sqrt N\lVert v_*\rVert\le\sqrt2mB$ hold in all cases.
   - The largest ratios of actual to bound were $0.53$ for $e_1\le h(d+1)$, $0.73$ for the layer recursion, $0.86$ for the output step, and $0.063$ for the final $hP_0$ bound.
4. **`check_width_lower_bound.py` (Lemma C.6.1, Theorem C.5).** The setup: Gaussian $\mu_{N,\gamma}$ with $\gamma=1$, $d=2$, $n=20$, $\eta=1/8$, constant target $y\equiv1$. Outputs on the point set are sampled exactly via the conditional Gaussian structure ($10^5$ draws), and posterior quantities by self-normalised importance sampling. Rows are $L=2$; for each $N$, the actual value is followed by the bound in parentheses:

   | $N$ | $\sup\lvert\hat f_n\rvert$ (bound) | KL (bound) | TV (bound) | test MSE |
   |---|---|---|---|---|
   | 16 | 7.3e-2 (7.7e-1) | 1.5e-1 (4.0) | 0.22 (1) | 0.875 |
   | 256 | 4.7e-3 (4.8e-2) | 1.1e-2 (0.25) | 5.8e-2 (0.35) | 0.992 |
   | 4096 | 3.4e-4 (3.0e-3) | 6.7e-4 (1.6e-2) | 1.5e-2 (8.8e-2) | 0.9994 |
   | 16384 | 9.3e-5 (7.5e-4) | 1.7e-4 (3.9e-3) | 7.3e-3 (4.4e-2) | 0.9999 |

   $L=3$ ($N\le1024$) is similar. All bounds held. $\sup|\hat f_n|$ scales as $N^{-1}$, the rate of Lemma C.6.1(i), at about $1/10$ of the bound on this sample; an adversarial case reaches $0.49$ of the bound (paragraph after the proof of Theorem C.5). The test MSE tends to $1$, which is the excess over the exact competitor $g_1$.
5. **`check_fanin_reference.py` (Appendix C.B).** For 4 configurations ($L=2,3,4$), the coordinatewise Gaussian KL equals $E^{\rm fi}_N+\frac{Q_N}2(t-1-\log t)$ to six decimals. The Monte Carlo value of $\max_x\mathbb E_{q_t}|z_w(x)-g(x)|^2$ was below $A^{\rm fi}t$ in all cases.
6. **`constants_table.py` (explicit constants; Gaussian, $\eta=1/8$, $\gamma=1$).**
   - Values of $A_L$ (C.3.2) and of the sample size of Corollary C.2.1 for $\varepsilon=0.1$, at learner width $N=m$:
     - $(d,m,B,L)=(10,1,2,2)$: $A_L=346$, $n\ge5.5\cdot10^4$;
     - $(10,10,2,3)$: $A_L=1387$, $n\ge2.2\cdot10^6$;
     - $(100,10,2,3)$: $A_L=2.3\cdot10^4$, $n\ge3.7\cdot10^7$;
     - $(10,100,2,3)$: $A_L=8.3\cdot10^4$, $n\ge1.3\cdot10^9$.
   - These are polynomial, but the constants are large.
   - The rate $\varepsilon_n(d)$ of Corollary C.2.2, as defined in (C.4.2) ($d=10$, $L=3$):
     - $\alpha=0.1$: $1.1\cdot10^{-1}$ at $n=10^6$ and $3.2\cdot10^{-8}$ at $n=10^{18}$;
     - $\alpha=0.19$, just below the threshold $1/5$: $4.0$ at $n=10^{18}$, still above $1$, as expected from the slow decay $n^{-0.05}$.
   - The constant-target thresholds of Theorem C.5(d) ($L=2$, $d=10$, $m_\nu=1$) differ by a factor of $2.09\cdot10^4$ at $n=10^6$ and at $n=10^8$, close to the limit $64A_L(10,1,2,1/16)/m_\nu=2.09\cdot10^4$ of Theorem C.5(d), where $A_L(10,1,2,1/16)\approx327$.
7. **`check_misc.py` (constructions in Theorem C.5(c) and Remark C.4.1).**
   - The width-one constant network outputs exactly $1$ at depths $L=2,\dots,11$, with readout at most $1.0444$. The fixed point of $u=\tanh2u$ is $0.957504$.
   - The parity networks are uniformly within $\varepsilon'\in\{0.1,0.01\}$ of $\chi$ for $d\in\{3,6,10\}$. This holds at depth 2 with step gain $\log(2d/\varepsilon')$, and at depth 3 with all $d+1$ incoming weights of the summing neuron multiplied by $\log(2/\varepsilon')$ (Remark C.4.1, case $L=3$). The largest weight is $38$ at $d=10$.

---

## C.9 What is proved, and what is not

**Proved (with full arguments above).**
* Theorem C.1 holds for arbitrary priors, with the exact exp-concavity threshold $\eta\le1/8$, in individual-sequence and in-expectation forms, for predictors that average clipped outputs. By Remark 3 after it, the likelihood may also use the unclipped outputs if the comparison terms use the unclipped losses as well. For that posterior, (C.2.3), (C.2.4) and the inequality in (C.2.5) hold with $(z_w(x_i)-y_i)^2$ in place of $\ell_i$ and $\int L_D(z_w)\,dQ$ in place of $\int L_D(\phi_w)\,dQ$, and Theorem C.2 holds with $4\rho$ replaced by $2\rho\sqrt{L_D(g)}+\rho^2$. With the unclipped posterior means $\bar z_t$, or their clips, in place of $\hat f_t$, the theorem fails for some priors.
* Theorem C.2 is the brief's displayed inequality, for the progressive mixture of clipped outputs, for every competitor $g$ of width $m\le N$ and every $\gamma\ge1$ and coordinate law of eq. `law`. It comes with the explicit $A_L$ (C.3.2) and a polynomial majorant (C.3.3).
* Corollaries C.2.1–C.2.2 give the polynomial sample size and, at learner width $N=\lceil n^\alpha\rceil$ with $\alpha<1/(4+\gamma)$, the user's formulation for $\bar f_n$ in expectation, with an error term that is $o(1)$ when $d$ is fixed or $d^2\log d=o(n^{1-(4+\gamma)\alpha}/\log n)$.
* Remark C.4.2: polynomial agnostic bounds at polynomial width for every real $\gamma$.
* Proposition C.3: the strong-prior family at scale $\sigma\le N^{-1/2}$, and its degeneration as $\sigma\to0$ with $\eta$ fixed.
* Proposition C.4: the fan-in prior, with a complexity term linear in $N$.
* Lemma C.6.1 and Theorem C.5: as $N\to\infty$ at fixed $\eta$, $n$ and sample, the posterior tends to the prior and the posterior means tend to $0$, with $k_n=\eta n/m_\nu$ and the following rates.
  - $\sup_X|\bar f_n|$ and $\sup_X|\hat f_n|$ are at most $N^{-\gamma}(4k_n+\sqrt{2k_n})$, which is $O(\eta n/(m_\nu N^\gamma))$ when $k_n\ge1$ and $O(\sqrt{\eta n/m_\nu}/N^\gamma)$ when $k_n\le1$.
  - $\mathrm{KL}(\Pi_n\Vert\mu_{N,\gamma})\le\eta nN^{-\gamma}(1+8k_n+2\sqrt{2k_n})=O\bigl((\eta n+(\eta n)^2/m_\nu)/N^\gamma\bigr)$.
  - $\mathrm{TV}(\Pi_n,\mu_{N,\gamma})=O\bigl(N^{-\gamma/2}(\sqrt{\eta n}+\eta n/\sqrt{m_\nu})\bigr)$.

  Constant targets give excess tending to $1$, for the clipped predictors and for the unclipped ones (Theorem C.5(e)). For that target and the excess level $1/2$, Theorem C.5(d) locates the width threshold $N^\gamma\asymp\eta n$ up to a factor $O(A_L(d,1,2,1/16)/m_\nu)$; it does not show that the form of the complexity term of Theorem C.2 is optimal.
* Theorems C.6–C.7: high-probability versions.
* Lemma C.3.1 at general scale; Appendix C.A gives a complete proof following `paper.tex` Prop. `tube`.

**Cited, with the statement checked against the source.**
* `paper.tex` eqs. `law`, `subgaussian`, `translation` (with their proofs in the paper), `teacher-energy`, Remark `cube`.
* `NNG/works-in-progress/slt-finite-sample/README.md` §3, re-derived in Appendix C.B.
* Main result 4 (Remark C.6.4), used only as context and never as a premise.

**Not proved / open.**
1. A bound for the *final* posterior mean or Gibbs predictor at fixed $\eta\le1/8$ without the additive $4\eta$ of (C.7.2), in expectation or with high probability.
2. Deviation bounds of order $\log(1/\delta)/n$ for the progressive mixture. Audibert (2007) suggests these fail in general for this predictor; not re-checked here.
3. Any width-uniform positive statement for FIX$_\eta$. Theorem C.5 rules this out for every $\gamma>0$ and every fixed $\eta$.
4. The behaviour of FIX$_\eta$ as $N\to\infty$ under the fan-in prior and at $\gamma\le0$, where prior outputs do not shrink. No lower or width-uniform upper bound is proved here.
5. The constants in $A_L$ are far from optimal. For example, the cylinder cost $N[d+2+(L-2)m]\log\frac1{c_\nu h_\rho}$ and the factor $d(d+1)B^2$ are worst-case, and the factor $\min\{1,\sqrt{m_\nu}\}$ in $c_\nu$ can be dropped (Appendix C.A, Step 1). On the side of lower bounds, Theorem C.5(d) only locates the width threshold $N^\gamma\asymp\eta n$ for one target and one excess level, up to a factor $O(A_L(d,1,2,1/16)/m_\nu)$.
6. The unclipped predictors: the posterior mean $\int z_w\,d\Pi_t$ of the unclipped outputs, its clip, the progressive mixtures of these, the clip of the progressive mixture of the unclipped posterior means, and the unclipped Gibbs risk $\int L_D(z_w)\,d\Pi_n$. No positive result here covers them: Theorems C.1, C.2, C.6 and C.7, Corollaries C.2.1–C.2.2 and Propositions C.3(a) and C.4 concern predictors built from clipped outputs. For some priors, Theorem C.1 is false for the progressive mixture of the unclipped posterior means and for its clip, and the bound (C.7.2) of Theorem C.7 is false for the unclipped Gibbs risk (Remark 3 after Theorem C.1); for the network priors of this note the question is open. The negative results extend to these predictors (Theorem C.5(e)).

---

## Appendix C.A Proof of Lemma C.3.1

This follows `paper.tex` Proposition `tube` (lines 347–404) step by step, keeping the scale $\sigma$ general. Write $\mathbb P_\nu=\nu^{\otimes P}$ for the law of the standardized vector $\Xi$ in (C.1.2), and $w(\Xi)$ for the linear bijection (C.1.2), so that $\mu^N_\sigma(U)=\mathbb P_\nu\{\Xi:w(\Xi)\in U\}$. Let $\Xi_*$ be the standardized clone, $w(\Xi_*)=w_*$. Then $\lVert\Xi_*\rVert^2=\kappa_N(w_*)/\sigma^2\le E_*/\sigma^2$. Put
$$t=\sigma\sqrt N,\qquad\bar t=\max\{1,t\},\qquad A_0(\bar t)=2+3mB+\bar tb_0,\qquad P_0(\bar t)=1+2mB(d+L+1)A_0(\bar t)^{L-2},$$
$$h=\frac{\rho}{2P_0(\bar t)}\le\frac12,\qquad s=\frac h{\bar t}\le\frac12 .$$
In this appendix $t$, $\bar t$ and $s$ are local symbols with these meanings: $t$ is not a sample index, and $s$ is a cylinder half-width, unrelated to the readout scale $s$ of Lemma C.6.1. Let $u_j=k_j^{-1/2}\mathbf 1_{G_j}\in\mathbb R^N$ ($j\le m$); these are orthonormal. Let $P_G=\sum_ju_ju_j^{\mathsf T}$, the orthogonal projection onto vectors that are constant on each group ($P$ without subscript is the parameter count of §C.1.2).

**Step 1 (cylinder).** Let $\mathcal C$ be the set of standardized perturbations $\zeta=(\zeta^1,\dots,\zeta^{L-1},\zeta^L)$ with
$$|\zeta^1_{ik}|\le s\ \ \forall i,k;\qquad|\zeta^L_i|\le s\ \ \forall i;\qquad|\langle\zeta^\ell_{i,*},u_j\rangle|\le s\ \ \forall\,2\le\ell\le L-1,\ i\le N,\ j\le m .$$
$\mathcal C$ is a centrally symmetric convex set. The $N[d+2+(L-2)m]$ linear forms in its definition depend on pairwise disjoint sets of coordinates, because the groups are disjoint, so under $\mathbb P_\nu$ they are independent.

Each form $Y$ is even, has a log-concave density and has variance $1$. It is either a single coordinate, or $k_j^{-1/2}$ times a sum of $k_j$ independent coordinates, which is log-concave by Prékopa–Leindler. For $0<s\le1$ we claim $\mathbb P(|Y|\le s)\ge c_\nu s$. Indeed, with $R=2\max\{1,m_\nu^{-1/2}\}\ge2$, Chebyshev gives $\mathbb P(|Y|>R)\le1/R^2\le1/4$. The density of $Y$ is even and log-concave, hence nonincreasing in $|y|$, so its average over $[-s,s]$ is at least its average over $[-R,R]$. Therefore $\mathbb P(|Y|\le s)\ge\frac sR\cdot\frac34=c_\nu s$. Hence
$$\mathbb P_\nu(\mathcal C)\ge(c_\nu s)^{N[d+2+(L-2)m]}.$$
Since every form $Y$ has variance exactly $1$, the radius $R=2$ already gives $\mathbb P(|Y|>R)\le1/4$, so the same argument yields $\mathbb P(|Y|\le s)\ge\frac38s$ for $0<s\le1$ and every $\nu$, and the factor $\min\{1,\sqrt{m_\nu}\}$ in $c_\nu$ (which equals $\sqrt{m_\nu}$, since $m_\nu\le1$) could be dropped from $c_\nu$ and from (C.3.3). This was pointed out by the computation referee. The factor is kept here so that $c_\nu$ and $A_L$ remain those of `paper.tex` eq. `A`, whose proof uses the weaker bound that each normalized group sum has "variance at most $1/m$" (lines 356–357). For Gaussian coordinates nothing changes, since then $m_\nu=1$.

**Step 2 (operator norms).** Let $\mathbb P_{\mathcal C}=\mathbb P_\nu(\cdot\mid\mathcal C)$, fix an internal layer $\ell$, and write $Z=\zeta^\ell$. For unit vectors $a,b\in\mathbb R^N$, $\langle Za,b\rangle=\langle\zeta,M\rangle$ for a vector $M$ with $\lVert M\rVert=\lVert ba^{\mathsf T}\rVert_F=1$. By eq. `subgaussian` (conditioning on the symmetric convex set $\mathcal C$), $\mathbb P_{\mathcal C}(\langle Za,b\rangle>r)\le e^{-m_\nu r^2/2}$.

Let $\mathcal N$ be a $1/4$-net of $S^{N-1}$ with $|\mathcal N|\le9^N$. Then $\lVert Z\rVert_{\rm op}\le2\max_{a,b\in\mathcal N}\langle Za,b\rangle$: if $\langle Za',b'\rangle=\lVert Z\rVert_{\rm op}$ for unit $a',b'$, choose $a,b\in\mathcal N$ within $1/4$ of them; then $\langle Za,b\rangle\ge\lVert Z\rVert_{\rm op}(1-\frac14-\frac14)$.

With $q^2=\frac2{m_\nu}[2\log9+\log(4L)]$, so that $2q=b_0$,
$$\mathbb P_{\mathcal C}\bigl(\lVert Z\rVert_{\rm op}>b_0\sqrt N\bigr)\le81^Ne^{-m_\nu q^2N/2}=(4L)^{-N}\le\frac1{4L}.$$
A union bound over the $L-2$ internal layers shows that $E:=\mathcal C\cap\{\lVert\zeta^\ell\rVert_{\rm op}\le b_0\sqrt N\ \forall\ell\}$ satisfies $\mathbb P_\nu(E)\ge\frac12\mathbb P_\nu(\mathcal C)$. $E$ is symmetric.

**Step 3 (the translated event lies in the tube).** Let $\zeta\in E$ and $w=w(\Xi_*+\zeta)$, that is,
$$W^1=W^1_*+\sigma\sqrt{N/d}\,\zeta^1,\qquad W^\ell=W^\ell_*+\sigma\zeta^\ell,\qquad v=v_*+\sigma N^{-1/2}\zeta^L .$$
Fix $x\in X\subseteq[-1,1]^d$, and let $e_\ell=N^{-1/2}\lVert h^\ell(x)-h^\ell_*(x)\rVert_2$.
* *Layer 1.* Each preactivation changes by at most $\sigma\sqrt{N/d}\,s\lVert\bar x\rVert_1\le\frac t{\bar t}\cdot\frac{h(d+1)}{\sqrt d}\le h(d+1)$. Since tanh is 1-Lipschitz, $e_1\le h(d+1)$.
* *Layer $\ell\in\{2,\dots,L-1\}$.* First, $\lVert W^\ell\rVert_{\rm op}\le\sqrt2mB+\sigma b_0\sqrt N\le\sqrt2mB+\bar tb_0=:a$. Second, $h^{\ell-1}_*$ is group-constant, so $(W^\ell-W^\ell_*)h^{\ell-1}_*=\sigma\zeta^\ell P_Gh^{\ell-1}_*$. Third,
$$\lVert\zeta^\ell P_G\rVert_{\rm op}\le\lVert\zeta^\ell P_G\rVert_F=\Bigl(\sum_{i,j}\langle\zeta^\ell_{i,*},u_j\rangle^2\Bigr)^{1/2}\le\sqrt{Nm}\,s .$$
Since tanh is 1-Lipschitz and $\lVert h^{\ell-1}_*\rVert_2\le\sqrt N$,
$$\sqrt N e_\ell\le\lVert W^\ell(h^{\ell-1}-h^{\ell-1}_*)\rVert+\sigma\sqrt{Nm}\,s\sqrt N\le a\sqrt Ne_{\ell-1}+t\sqrt m\,s\sqrt N,$$
so $e_\ell\le a\,e_{\ell-1}+\sqrt m\,h$.
* *Readout.* $|z_w(x)-g(x)|\le|v_*^{\mathsf T}(h^{L-1}-h^{L-1}_*)|+|(v-v_*)^{\mathsf T}h^{L-1}|\le\sqrt N\lVert v_*\rVert\,e_{L-1}+\lVert v-v_*\rVert_1\le\sqrt2mB\,e_{L-1}+N\sigma N^{-1/2}s$. The last term is $ts=(t/\bar t)h\le h$.
* *Solving the recursion.* Note $a\ge\sqrt2mB>1$ and $A_0(\bar t)\ge\max\{a,\sqrt m\}$. By induction,
$$e_{L-1}\le a^{L-2}h(d+1)+\sqrt m\,h\sum_{k=0}^{L-3}a^k\le hA_0^{L-2}(d+1)+h(L-2)A_0^{L-2}\le h(d+L+1)A_0(\bar t)^{L-2},$$
using $\sqrt m\,a^k\le A_0^{k+1}\le A_0^{L-2}$ for $k\le L-3$. For $L=2$ there is no internal layer and $e_1\le h(d+1)$ directly. Hence
$$\sup_{x\in X}|z_w(x)-g(x)|\le h\bigl[1+\sqrt2mB(d+L+1)A_0(\bar t)^{L-2}\bigr]\le hP_0(\bar t)=\rho/2<\rho .$$
So $\{\Xi:w(\Xi)\in U_\rho(g)\}\supseteq\Xi_*+E$.

**Step 4 (translation).** By eq. `translation` applied to the symmetric set $E$,
$$\mu^N_\sigma(U_\rho(g))\ge\mathbb P_\nu(\Xi_*+E)\ge\mathbb P_\nu(E)\,e^{-M_\nu\lVert\Xi_*\rVert^2/2}\ge\tfrac12\,(c_\nu s)^{N[d+2+(L-2)m]}\,e^{-M_\nu E_*/(2\sigma^2)} .$$
For Gaussian $\nu$ there is a two-line proof of the translation inequality: $\mathbb P(E+a)=e^{-\lVert a\rVert^2/2}\int_E\varphi(y)\cosh\langle a,y\rangle\,dy\ge e^{-\lVert a\rVert^2/2}\mathbb P(E)$ for symmetric $E$. For general $\nu$ see `paper.tex` lines 327–335 (relative entropy of the translated conditional law, using oddness of $V'$ and $V''\le M_\nu$).

**Step 5 (constants).** We have $\frac1{c_\nu s}=\frac{\bar t}{c_\nu h}$ and $\log\frac{\bar t}{c_\nu h}=\log\bar t+\log\frac{2P_0(\bar t)}{c_\nu\rho}$. Since $\bar t\ge1$, $A_0(\bar t)\le\bar t\,A_0(1)$ and hence $P_0(\bar t)\le\bar t^{L-2}P_0(1)$. Therefore $\log\frac{\bar t}{c_\nu h}\le(L-1)\log\bar t+\log\frac{1}{c_\nu h_\rho}$ with $h_\rho=\rho/(2P_0(1))$. Taking $-\log$ in Step 4 gives (C.3.1). $\square$

---

## Appendix C.B The fan-in reference distribution

This re-derives the two facts of `NNG/works-in-progress/slt-finite-sample/README.md` §3 (lines 107–158) that Proposition C.4 uses. The README states them for depth $L\ge3$; the argument below covers every $L\ge2$. Let $D_0=d+1$. In this appendix $t\in(0,1]$ is a variance factor, not a sample index.

**Zero-padded teacher.** Let $w_T$ consist of $W^1_T$, whose first $m$ rows are $T^1$ and whose other rows are $0$; $W^\ell_T$, with $T^\ell$ in the top-left $m\times m$ block and $0$ elsewhere; and $v_T=(u,0,\dots,0)$. Since $\tanh0=0$, neurons $m+1,\dots,N$ of $w_T$ output $0$ at every layer, and $z_{w_T}=g$ on $\mathbb R^d$.

**Reference law.** For $0<t\le1$, let $q_t$ have independent Gaussian coordinates with mean $w_T$. On the *selected* coordinates, the variance is $t$ times the prior variance. The selected coordinates are:
* the $D_0$ incoming weights of each of neurons $1,\dots,m$ in layer $1$;
* the $N$ incoming weights of each of neurons $1,\dots,m$ in every layer $\ell=2,\dots,L-1$;
* all $N$ readout weights.

Every other coordinate keeps its prior law $\mathcal N(0,\text{prior variance})$; its mean in $w_T$ is $0$. There are $Q_N=mD_0+(L-2)mN+N$ selected coordinates.

**KL.** For one coordinate with prior $\mathcal N(0,\varsigma^2)$ and reference $\mathcal N(\alpha,t\varsigma^2)$, $\mathrm{KL}=\frac{\alpha^2}{2\varsigma^2}+\frac12(t-1-\log t)$. Unselected coordinates contribute $0$. Every nonzero mean sits on a selected coordinate. Summing,
$$\mathrm{KL}(q_t\Vert\mu^{\rm fi}_N)=\tfrac12\Bigl[D_0\lVert T^1\rVert_F^2+N\sum_{\ell=2}^{L-1}\lVert T^\ell\rVert_F^2+N\lVert u\rVert_2^2\Bigr]+\tfrac{Q_N}2(t-1-\log t).$$
The bound on $E^{\rm fi}_N(g)$ in Proposition C.4 uses $\lVert T^1\rVert_F^2\le mD_0B^2$, $\lVert T^\ell\rVert_F^2\le m^2B^2$ and $\lVert u\rVert^2\le mB^2$.

**Approximation.** Fix $x\in[-1,1]^d$. Let $h^\ell$ be the activations of $w\sim q_t$ and $h^\ell_T$ those of the teacher (coordinates $1,\dots,m$). Put $r_\ell=\max_{i\le m}\mathbb E_{q_t}(h^\ell_i-h^\ell_{T,i})^2$.
* *Layer 1.* For $i\le m$, the preactivation $\langle W^1_i,\bar x\rangle$ is $\mathcal N\bigl(\langle T^1_i,\bar x\rangle,\frac t{D_0}\lVert\bar x\rVert^2\bigr)$, and $\lVert\bar x\rVert^2\le D_0$. Since tanh is 1-Lipschitz, $r_1\le t$.
* *Layer $\ell\ge2$.* For $i\le m$, the preactivation minus the teacher's is $\sum_{j\le m}T^\ell_{ij}\Delta_j+\sum_{j\le N}\epsilon_{ij}h^{\ell-1}_j$. Here $\Delta_j=h^{\ell-1}_j-h^{\ell-1}_{T,j}$ and $\epsilon_{ij}\sim\mathcal N(0,t/N)$ are independent of all earlier layers. Conditionally on earlier layers, the second sum is centred Gaussian with variance $\frac tN\lVert h^{\ell-1}\rVert^2\le t$, so the cross term has zero mean. Cauchy–Schwarz gives $(\sum_{j\le m}T_{ij}\Delta_j)^2\le mB^2\sum_{j\le m}\Delta_j^2$. Hence the expected squared preactivation error is at most $m^2B^2r_{\ell-1}+t$, and $r_\ell\le m^2B^2r_{\ell-1}+t$.
* *Readout.* The same computation, with the readout weights $\mathcal N(u_j\mathbf 1_{j\le m},t/N)$, gives $\mathbb E_{q_t}(z_w(x)-g(x))^2\le m^2B^2r_{L-1}+t$.

By induction, $\sup_{x\in[-1,1]^d}\mathbb E_{q_t}(z_w(x)-g(x))^2\le t\sum_{j=0}^{L-1}(m^2B^2)^j=A^{\rm fi}t$. $\square$

---

## Referee record

Two referees reviewed this note independently, each through one lens. Both returned the verdict "minor fixes", and neither found an error in a proof.

- [`../verification/C-logic.md`](../verification/C-logic.md): logic and definitions (quantifiers, limit order, case splits, hypotheses, use of the sources). Its checks are in `../checks/verify-C-logic/`.
- [`../verification/C-computation.md`](../verification/C-computation.md): constants, exponents, probability estimates and quoted numbers. Its checks are in `../checks/verify-C-computation/`; the subfolder `repro/` holds its reruns of the scripts of `../checks/C/` as they were before this revision.

The reports refer to the version of this note that the referees reviewed. No section or result has been renumbered since, so their references by number still apply. They call the script folder `C_scripts/`, which is `../checks/C/` here, and the line of `constants_table.py` that the computation report cites refers to that script before its correction.

The table has one row per issue in the issue lists of the two reports (`../verification/C-logic.md` §3, `../verification/C-computation.md` §3); the parts of logic issue 7 and of computation issue C6 have separate rows. *Fixed* means that a wrong number, expression or description was corrected, or a missing explanation or proof was added, without reducing what any proved statement asserts. *Weakened* means that a sentence that was false or unproved as stated now carries the missing hypothesis or qualifier, or claims less. *Rebutted* means that the issue was judged invalid and the text left unchanged; no issue was rebutted.

| report | issue | resolution | where |
|---|---|---|---|
| logic 1 | "sharp up to the factor $A_L$" (C.0 item 4, Theorem C.5(d), C.9) claims more than Theorem C.5(d) proves, which concerns one target and one excess level; the window also carries a factor $1/m_\nu$ | weakened: each place now says that (d) locates the width threshold $N^\gamma\asymp\eta n$ for the constant target and excess level $1/2$ up to a factor $O(A_L(d,1,2,1/16)/m_\nu)$, and that the form of the complexity term is not shown to be optimal; the title of (d) no longer says "sharpness" | C.0 item 4; Thm C.5(d), title and last paragraph; C.9, proved list and open item 5 |
| logic 2 | the predictors use clipped outputs, unlike the brief's BMA and Gibbs predictor; "the brief's $\hat f_n$" refers to nothing; the unclipped predictors are not covered, and for an arbitrary prior Theorem C.1 is false for them; the negative results extend to them | fixed: the departure from the brief is stated; "the brief's $\hat f_n$" removed; the referee's two-point example added; the unclipped predictors listed as not proved; the bullets on Theorems C.1 and C.2 in C.9 say that these theorems concern predictors built from clipped outputs; the negative results for the unclipped predictors proved as Theorem C.5(e) | C.0, first paragraph, item 4 and "Not proved here"; §C.1.3; Remark 3 after Thm C.1; Thm C.5(e) and its proof; C.9, proved list and open item 6 |
| logic 3 | "every predictor tends to $0$ uniformly", although the Gibbs predictor is random | weakened: the posterior means $\bar f_n,\hat f_n$ tend to $0$ uniformly on $X$, and $\sup_x\int z_w(x)^2\,d\Pi_n\to0$ | C.0 item 3; sentence after Thm C.5(b); Remark C.6.4, first bullet |
| logic 4 | C.9: "at the quantitative rate $O(\eta n/N^\gamma)$" is wrong for KL and TV, and for the posterior means when $k_n<1$ | weakened: the three proved rates are stated separately | C.9, proved list |
| logic 5 | Remark C.6.2 attributes to Theorem C.5 a statement about the unclipped likelihood of `slt-likelihood` §4 | weakened: the sentence is restricted to FIX$_\eta$; the referee's outline of the extension is mentioned and marked as not carried out | Remark C.6.2 |
| logic 6 | Remark C.4.1: "the weight of the last hidden neuron" is undefined at $L=3$, where that neuron has $d+1$ incoming weights | fixed: the cases $L=3$ (all $d+1$ weights multiplied by $A'$; error at most $2e^{-7A'/4}\le\varepsilon'$) and $L\ge4$ are distinguished | Remark C.4.1; C.8 item 7; docstring of `../checks/C/check_misc.py` |
| logic 7(i) | "Bearing on the conjecture" calls the statement with $N$-dependent sample size "the brief's formalisation" | fixed: the brief's formalisation is stated and said to be false for FIX$_\eta$; the proved statement is called a weaker formalisation | C.0, "Bearing on the conjecture" |
| logic 7(ii) | "test loss $\le$ min $\dots+o(1)$" omits that it holds in expectation (Cor C.2.2) or with high probability for $\tilde f_n$ (Thm C.6), and the condition on $d$ | weakened: the predictor, the mode (in expectation, or with probability $\ge1-2\delta$ with the extra terms of Theorem C.6) and the condition on $d$ are stated | C.0 item 2 and "Bearing on the conjecture"; C.9, proved list |
| logic 7(iii) | "min" should be "inf" | fixed | C.0 item 2 and "Bearing on the conjecture"; Cor C.2.2 |
| logic 8 | Remark C.4.2: $\sigma\sqrt N=N^{(1-\gamma)/2}>1$ is an equality at $N=1$ | fixed: "$\ge1$, with equality only at $N=1$" | Remark C.4.2 |
| logic 9 | Prop C.3(c): the step from part (b) to "can learn only when $\eta\sigma^2n\gtrsim1$" needs $\sigma^2\le1$ | weakened: the hypothesis $\sigma^2\le1$ is added, with the explicit constant $(2-\sqrt3)m_\nu/16\approx0.0167m_\nu$ and a proof. The referee's example is quoted to show that without $\sigma^2\le1$ part (b) alone does not give the implication; it does not show that the implication fails (see the first check of the revision below) | Prop C.3(c) and its proof |
| logic 10 | notation overloads: $s$, $t$, $P$, $\lambda$, $\hat f_n$ | fixed: the local meanings of $t$, $\bar t$ and $s$ are stated at the head of Appendix C.A and that of $t$ in Appendix C.B; the projection of Appendix C.A is renamed $P_G$; "the brief's $\hat f_n$" is removed (logic 2). The three uses of $\lambda$ lie in separate proofs and are each defined where used, so they were left | App. C.A, head and Step 3; App. C.B, head |
| computation C1 | §C.8 item 6 tabulates $\varepsilon_n$ with $\lceil n^\alpha\rceil^\gamma$ in place of the $(2n^\alpha)^\gamma$ of (C.4.2), and the script's docstring states the latter | fixed: the script now computes $\varepsilon_n(d)$ as defined, its docstring is corrected, and it was re-run; the quoted values are now $1.1\cdot10^{-1}$ and $3.2\cdot10^{-8}$ at $\alpha=0.1$ (were $5.7\cdot10^{-2}$ and $1.6\cdot10^{-8}$) and $4.0$ at $\alpha=0.19$, $n=10^{18}$ | C.8 item 6; `../checks/C/constants_table.py` and `constants_table.out` |
| computation C2 | Remark 3 after Theorem C.1 says the argument would fail with an unclipped likelihood; for the predictor used here it does not | fixed: the remark now says that clipping is needed in the predictor and not in the likelihood, with the proof and its two consequences (Theorem C.1 with $\int L_D(z_w)\,dQ$; Theorem C.2 with $4\rho$ replaced by $2\rho\sqrt{L_D(g)}+\rho^2$) | Remark 3 after Thm C.1; "Relation to SP$_c$" (§C.5.1); C.9, proved list |
| computation C3 | the "rate $O(\eta n/N^\gamma)$" for posterior and predictor (C.9, and the paragraph after Theorem C.5) | weakened (as logic 4); the Monte Carlo paragraph now says that it checks the $N^{-\gamma}$ rate at fixed $\eta n$; Remark C.6.3 states the bound on the posterior mean with its dependence on $k$ | C.9; paragraph after the proof of Thm C.5; Remark C.6.3 |
| computation C4 | "sharp up to the factor $A_L$" | weakened (as logic 1), with the ratio of the two thresholds made explicit: $16A_L(4k_n+\sqrt{2k_n})/(\eta(n+1))$, below $87A_L/m_\nu$ when $k_n\ge1$ and tending to $64A_L/m_\nu$ | Thm C.5(d) and its proof; C.0 item 4; C.8 item 6; C.9 |
| computation C5 | Remark C.4.1 at depth $L=3$ | fixed (as logic 6) | as logic 6 |
| computation C6(a) | Remark C.4.2: equality at $N=1$; $\mathrm{poly}_L$ also depends on $\gamma$ and $\nu$ | fixed | Remark C.4.2 |
| computation C6(b) | separate exponents after Cor C.2.2: it is the bound, not the excess, that is $o(1)$ iff $2a+2b+\gamma\beta<1$ at fixed $d$; $O_L$ should read $O_{L,\gamma,\nu}$ | weakened: the bound is displayed, the "if and only if" is stated for the bound (with a lower bound for the converse), and nothing is claimed about the excess when $2a+2b+\gamma\beta\ge1$ | paragraph after the proof of Cor C.2.2 |
| computation C6(c) | "minimum test loss" should read "infimum" | fixed (as logic 7(iii)) | C.0 item 2; Cor C.2.2 |
| computation C7 | optional: the factor $\min\{1,\sqrt{m_\nu}\}$ in $c_\nu$ can be dropped, since each form has variance exactly $1$ | fixed: the improvement is stated, with its one-line proof; the constants are kept equal to those of `paper.tex` eq. `A`, so that Lemma C.3.1 still matches its source, and nothing changes for Gaussian coordinates | App. C.A, Step 1; C.9 open item 5 |

Besides these changes, the opening paragraph was rewritten for the repository layout, and the script paths `C_scripts/...` in the text are now `../checks/C/...`. The reference to Claim B now links to `B-tempered-likelihood.md`, whose definition of SP$_c$ (§1) was checked against the description in §C.5.1. "Bearing on the conjecture" now quotes the user's expectation from the brief verbatim, and the summary statements name the competitor class as the architecture of §C.1.2 rather than "MLPs". Remark C.6.4 now says that FIX$_\eta$ learns parity in expectation, for $\bar f_n$. Two points that the computation report raises outside its issue list were also taken up. The "about one tenth of bound (i)" observation (paragraph after Theorem C.5; C.8 item 4) is now qualified by the referee's adversarial ratio $0.49$ (`../verification/C-computation.md` §2.4), and the explicit constants $K_1,K_2,K$ of Corollary C.2.2 that the report derives (§2.5) are now stated at the end of the proof of that corollary.

In `../checks/C/`, the docstrings of `check_expconcavity.py`, `check_fanin_reference.py`, `check_oracle_mc.py`, `check_tube_lemma.py` and `check_width_lower_bound.py` cited an older numbering (for example "Lemma 5.1 / Theorem 5.2"); they, and the two labels printed by `check_oracle_mc.py`, now use the numbering of this note. All seven scripts were re-run from that folder with `python3 X.py > X.out`; each runs in under 15 seconds. The outputs are unchanged except `constants_table.out` (issue C1, plus a column giving the limit $64A_L/m_\nu$ of the threshold ratio) and the two labels in `check_oracle_mc.out`, so the referee's reruns in `../checks/verify-C-computation/repro/` now differ from the current outputs in those two files only.

### Check of the revision

An independent checker ([`../verification/C-revision-check-1.md`](../verification/C-revision-check-1.md); scripts in `../checks/revision-check-C-1/`) compared the revised note with the two reports, the brief, `B-tempered-likelihood.md`, the cited repository sources and the scripts of `../checks/C/`, which it re-ran with outputs identical to the recorded ones. It found each row of the table above resolved as stated, except "logic 9", and raised the three points below. All three were judged valid, so none was rebutted. No script was changed in response.

| point | resolution | where |
|---|---|---|
| Prop C.3(c): the clause added for logic 9, "Without $\sigma^2\le1$ this implication fails", is false. The referee's example shows only that the sufficient condition taken from part (b) is not met, not that the excess falls below $1/2$. The checker showed that the implication holds for every $\sigma$: the likelihood ratio $\Lambda_t/Z_t$ lies in $[e^{-4\eta t},e^{4\eta t}]$ and the prior mean of $\phi_w(x)$ is $0$ (property (P3) in the proof of Lemma C.6.1), so $\sup_X\lvert\hat f_t\rvert\le e^{4\eta t}-1$ for every $\sigma$, and for $\sigma^2>1$ the hypothesis $\eta\sigma^2n\le(2-\sqrt3)m_\nu/16$ gives $\eta n<0.0168$ and an excess of at least $0.866$ | weakened: the clause now says only that without $\sigma^2\le1$ part (b) alone does not give the implication, and quotes the referee's example for that; the hypothesis $\sigma^2\le1$ is kept. The checker's alternative, dropping the hypothesis and adding its likelihood-ratio argument, was not adopted, because it would strengthen the statement of Prop C.3(c). The "logic 9" row above is corrected | Prop C.3(c) and its proof; row "logic 9" |
| C.0, first paragraph: "for an arbitrary prior Theorem C.1 is false for them" refers to all the unclipped predictors, including the unclipped Gibbs predictor, while Remark 3 shows failure only for some of them | weakened: the sentence now names the progressive mixture of the unclipped posterior means and its clip, as "Not proved here" and C.9 open item 6 do. The first bullet of C.9's proved list, which said "for unclipped predictors the theorem fails", now names the predictors of Remark 3 in the same way. In C.0 (first paragraph and "Not proved here") and C.9 open item 6, "for an arbitrary prior" now reads "for some priors", since each failure is shown for one particular prior | C.0, first paragraph and "Not proved here"; C.9, proved list and open item 6 |
| Remark 3 after Thm C.1: "its clip" names two different predictors ($\operatorname{clip}\bar z_t$ used in place of $\hat f_t$, and the clip of the progressive mixture of the $\bar z_t$); the parenthesis on the source of the numbers attributes to the logic referee's script two values that it does not print | fixed: each failure is stated for a named predictor, together with the inequality it violates, and the bound of (C.2.5) is given at $n=10$, $100$ and $1000$. The paragraph after the list says which values the script prints and derives the others from the definitions | Remark 3 after Thm C.1, "Predictor" |

### Second check of the revision

A second independent check ([`../verification/C-revision-check-2.md`](../verification/C-revision-check-2.md); scripts in `../checks/revision-check-C-2/`) read the note as revised after the first check. It compared it with the version that the referees reviewed and checked it against the two reports, the brief, §1 of `B-tempered-likelihood.md`, the cited repository sources and the scripts of `../checks/C/`, which it re-ran with outputs identical to the recorded ones. It found every row of the two tables above resolved as stated, and every proof, constant and quoted number that it re-derived in the changed passages correct. It raised the three points below; the third has three parts, which have separate rows. All were judged valid, so none was rebutted. No script was changed in response.

| point | resolution | where |
|---|---|---|
| §C.1.2, "Coordinate law": the sentence "Neither fact is used below", about $m_\nu\le1\le M_\nu$, is false. $m_\nu\le1$ is used in the explicit $K_1$ of Cor C.2.2, which writes $\log(16/\sqrt{m_\nu})$ for the $\log(16/\min\{1,\sqrt{m_\nu}\})$ of (C.3.3), and in Appendix C.A, Step 1 | fixed: the sentence now says that the first fact is used only in $K_1$ and in the closing remark of Appendix C.A, Step 1, and that the second is not used. $K_1$ is unchanged; it is valid because $m_\nu\le1$ is proved in the same paragraph. The alternative, writing $K_1$ with $\min\{1,\sqrt{m_\nu}\}$, was not adopted, so that $K_1$ remains the computation referee's value | §C.1.2, "Coordinate law" |
| C.9, proved list, first bullet: "the likelihood may also use the unclipped outputs" reads as saying that Theorem C.1 holds unchanged for the unclipped likelihood, which is false. Counterexample: $\Theta=\{w_1,w_2\}$, $\mu$ uniform, $z_{w_1}\equiv10$, $z_{w_2}\equiv-1$, $y\equiv1$, $\eta=1/8$, $Q=\delta_{w_1}$. Then $\hat f_0=0$, and for $t\ge1$ the posterior weight of $w_1$ is $(1+e^{9.625t})^{-1}<10^{-4}$, so $\sum_{t<50}(\hat f_t-y)^2\approx197.0$, while the right side of (C.2.3) with the clipped losses is $8\log2\approx5.5$ | weakened: the bullet now states the result as Remark 3 proves it. With the unclipped likelihood, (C.2.3), (C.2.4) and the inequality in (C.2.5) hold with the unclipped losses in the comparison terms, and Theorem C.2 holds with $4\rho$ replaced by $2\rho\sqrt{L_D(g)}+\rho^2$. The counterexample agrees with this: there $-\frac1\eta\log Z_{50}\approx205.5$, so the first inequality of (C.2.3) holds, and the right side of (C.2.3) with the unclipped losses is $50\cdot81+8\log2\approx4055.5$ | C.9, proved list, first bullet |
| C.0, first paragraph: "All predictors studied here are built from the clipped outputs" is contradicted by Remark 3 and Thm C.5(e), which study unclipped predictors | weakened: the sentence now reads "All predictors in the positive results below are built from the clipped outputs"; the three main ones follow | C.0, first paragraph |
| Thm C.5(e) lists $\bar z_t$, $\operatorname{clip}\bar z_t$ and the progressive mixtures of either, but not the clip of the progressive mixture of the $\bar z_t$, which C.0, Remark 3 and C.9 discuss and which the proof of (e) covers | fixed: that predictor is added to the list in (e). The proof is unchanged, since clipping does not increase the supremum norm. The lists of unclipped predictors in C.0 (item 4 and "Not proved here") and in C.9 open item 6 now include it as well, so that all lists match | Thm C.5(e); C.0, item 4 and "Not proved here"; C.9 open item 6 |
| Referee record: no row's "where" column names the "clipped outputs" qualifiers in the C.9 bullets on Theorems C.1 and C.2, which belong to logic 2 | fixed: row "logic 2" now names C.9's proved list, and also C.0 item 4, whose sentence on the unclipped predictors summarises Thm C.5(e) | row "logic 2" |

Besides these changes, the opening paragraph now mentions both checks, and row "logic 9" points to the first of them. C.9 open item 6 now says that the positive results concern predictors "built from" clipped outputs, not predictors that "average" them, because Theorem C.7 also covers the Gibbs predictor, which is a single posterior draw.

### Third check of the revision

A third independent check ([`../verification/C-revision-check-3.md`](../verification/C-revision-check-3.md); scripts in `../checks/revision-check-C-3/`) read the note as revised after the second check. It found every referee issue and every point of the two earlier checks resolved, re-ran the seven scripts with outputs identical to the recorded ones, and raised three minor points, two of them optional. The lead editor resolved them as follows. No result is affected.

| point | resolution | where |
|---|---|---|
| §C.1.2 said that $m_\nu\le1$ is used only in two places, but the first row of "Check of the revision" also uses it, to pass from $\eta\sigma^2n\le(2-\sqrt3)m_\nu/16$ and $\sigma^2>1$ to $\eta n<0.0168$ | weakened: "In the results and proofs of this note, the first fact is used only in two places" | §C.1.2, "Coordinate law" |
| (optional) Remark C.6.2 said that the prior tail $2e^{-m_\nu N^\gamma/8}$ matches the tube cost $A_LN^\gamma$ "up to the factor $A_L$"; the exponents differ by the factor $8A_L/m_\nu$ | weakened: "up to a factor $O(A_L/m_\nu)$ in the exponent" | Remark C.6.2 |
| (optional) C.8 item 2 said that the per-sequence inequality (C.2.3) had no violation in any run, but `check_oracle_mc.py` tests only its first inequality | weakened: the sentence now names the first inequality and says that the second was not tested per sequence | C.8 item 2 |

### Scope referee

A scope referee ([`../verification/C-scope.md`](../verification/C-scope.md); scripts and outputs in [`../checks/verify-C-scope/`](../checks/verify-C-scope/)) read the final text of the note, as revised after the third check, together with the draft of the main README. It examined whether the theorems establish what the note says they establish, with the brief's order of quantifiers and limits, and whether the note and the README state them with their hypotheses. Its verdict was "minor fixes": it found no error in a theorem and no contradiction with `A-tight-conditioning-fails.md`, `B-tempered-likelihood.md`, `E-finite-prior-scale.md`, `small-learner-width.md` or `NNG/works-in-progress/slt-likelihood/README.md`, and none of its 14 minor issues changes a theorem. Issues 1–6 and 14 concern the README draft and issue 13 the brief; the lead editor answered them in those files, and they did not change this note. Issues 7–12 concern this note. All six were judged valid, so none was rebutted. Issues 7–11 were answered by stating a hypothesis, predictor, temperature range or width range that a sentence had left out, or by claiming less; the optional issue 12 was answered by adding two statements, with their proofs, about the two-point prior of Remark 3 after Theorem C.1. The changes are confined to the sentences named in the table and the opening paragraph, which now mentions the scope report; no displayed bound, result number or script changed. The numbers added for issue 12 are printed by the referee's `s1_two_point.py`, and the text gives the closed forms from which they follow. Line numbers in the report refer to the text it reviewed; the last column below locates each change by section and result. The resolutions of issues 7–12 use the terms defined before the first table.

| issue | description | resolution | where |
|---|---|---|---|
| 1 | README draft, introduction, item 5: "works only at polynomial learner width" reads as widths polynomial in $n$, but Theorem C.5 proves failure at some widths linear in $n$; the item also omits the predictor and $\eta\le1/8$, calls the form $N^\gamma/(\eta n)$ of the complexity term necessary, and says that the posterior returns to the prior as $N\to\infty$, which is proved for $\mu_{N,\gamma}$, is not by itself why the learner fails, and is open under the fan-in prior | answered in the README by the lead editor | `../README.md`, introduction, item 5 |
| 2 | README draft, §2 table, row FIX$_\eta$: the cell bolds "holds" although FIX$_\eta$ does not have (P$_L$); the row does not say that the failure is on a fixed law in every input dimension, and omits $\eta\le1/8$ and the clipped outputs | answered in the README by the lead editor | `../README.md`, §2, table, row FIX$_\eta$ |
| 3 | README draft, §6, second bullet: Corollary C.2.2 holds at the single learner width $\lceil n^\alpha\rceil$, not uniformly over learner widths; "least test loss" should be "infimum of the test loss"; the $O$-term omits the factor $1/\eta$ and the dependence on $L,\gamma,\nu$; the competitor's depth, weight bound and $\rho$ are not stated | answered in the README by the lead editor | `../README.md`, §6, second bullet |
| 4 | README draft, §6, third bullet: "the predictors tend to $0$", although the Gibbs predictor is a random draw (the note was corrected for this under logic issue 3); "the width dependence is necessary", as in issue 1 | answered in the README by the lead editor | `../README.md`, §6, third bullet |
| 5 | README draft, §6, closing paragraph: "clipping is essential" will be read as concerning the clipped likelihood, but clipping is needed in the predictor (Remark 3 after Thm C.1); the failures are shown for a two-point prior, and for the network priors the unclipped predictors are open | answered in the README by the lead editor | `../README.md`, §6, closing paragraph |
| 6 | README draft, closing paragraph of the introduction: "the tempering has to be tied to the prior scale" is proved only for the clipped likelihood under the repository's shrinking-output priors (Thm C.5, Prop C.3(b)), not for the unclipped likelihood or the fan-in prior | answered in the README by the lead editor | `../README.md`, introduction, closing paragraph |
| 7 | "Bearing on the conjecture": the positive sentence follows one about every $\gamma>0$ and restates neither $0<\eta\le1/8$ nor the hypothesis $\gamma\ge1$ of item 2. C.9's bullet on Corollaries C.2.1–C.2.2 omits the predictor $\bar f_n$ and the learner width $N=\lceil n^\alpha\rceil$ | weakened: the sentence now names $0<\eta\le1/8$ and cites items 2 and 5 for $\gamma\ge1$ and Remark C.4.2 for $\gamma<1$ (which, after issue 9, covers both $\bar f_n$ and $\tilde f_n$); the next sentence, on Corollary C.2.2, now says $\gamma\ge1$. The C.9 bullet names the learner width $N=\lceil n^\alpha\rceil$, the predictor $\bar f_n$ and the mode | C.0, "Bearing on the conjecture"; C.9, proved list, third bullet |
| 8 | Remark 2 after Thm C.1 is headed "Genuinely Bayesian variants", but neither variant is the posterior mean, or a draw, of the posterior given the whole sample, which the report takes to be what "Bayesian learning" names in the user's statement; for that posterior only Theorem C.7 is proved | weakened: the heading is now "Randomized and symmetrized variants with the same bound", and a closing sentence says that neither variant is the posterior mean or a draw of that posterior, what each uses instead (variant (i) only the first $T$ points, half of the sample on average), and points to Theorem C.7 | Remark 2 after Thm C.1 |
| 9 | Remark C.4.2 and Prop C.4 say that FIX$_\eta$ is polynomially agnostic without naming the predictor or the temperature range | weakened: both now say that, at polynomial learner width, the progressive mixture $\bar f_n$ of FIX$_\eta$ with $0<\eta\le1/8$ is polynomially agnostic in expectation and $\tilde f_n$ with probability $\ge1-2\delta$ (Theorem C.6 with the comparison measure that gives the bound in expectation), and that for the final posterior Theorem C.7 gives only a bound with the additive $4\eta$. In Prop C.4 the range of $\eta$ is already a hypothesis, so it is not repeated | Remark C.4.2; Prop C.4 |
| 10 | "Relation to SP$_c$": the term $2cA_L/(n+1)$ of part (a) needs $\sigma^2\le1/N$, which together with $\sigma^2\ge4/c$ allows only $N\le c/4$; "Part (b) is the quantitative form of `slt-likelihood` §3" is broader than (b), which concerns the clipped likelihood only | weakened: the term is stated for widths $N\le1/\sigma^2$, a range that $\eta\le1/8$ confines to $N\le c/4$, and beyond it the complexity term, the right side of (C.3.1) divided by $\eta(n+1)$, is said to grow at least linearly in $N$ (the report says "linearly"; the term $\log^+(\sigma\sqrt N)$ of (C.3.1) makes it grow like $N\log N$). Part (b) is now called the quantitative form of that section for the clipped likelihood of FIX$_\eta$, and the likelihoods the section treats are named. The conclusion, that the exp-concave route does not reach SP$_c$, is unchanged | §C.5.1, "Relation to SP$_c$" |
| 11 | Remark C.6.4, third bullet: "The obstruction is the width-first limit" reads as a statement about both learners compared there, but nothing here shows that the learner of main result 4 learns parity at polynomial width | weakened: the sentence now says that for FIX$_\eta$ with $\gamma>0$ the obstruction is the large-width limit, with the reason (Thm C.5(b)), and that at $\gamma\le0$ its large-width behaviour is open; the report's proposed wording did not restrict $\gamma$, but Theorem C.5 needs $\gamma>0$. A last sentence says that whether the learner of main result 4 learns parity at polynomial width is not addressed here, and the sentence on Remarks C.4.1–C.4.2 now states $0<\eta\le1/8$ | Remark C.6.4, third bullet |
| 12 | (optional) the two-point prior of Remark 3 after Thm C.1 also shows (a) that the unclipped Gibbs risk satisfies no bound of the form (C.7.2), and (b) for $\operatorname{clip}\bar z_t$, where the remark showed only that the first inequality of (C.2.3) fails at $T=1$, that the bound of the left side of (C.2.3) by its right side fails from $T=2$ and that (C.2.4) fails | fixed: (b) is added to the first item of the remark: the right side of (C.2.3) is $8\log2\approx5.55$, the left side is at least $8$ for $T\ge2$, and the left side of (C.2.4) is $1.71$ against $0.504$ at $M=10$, $n=10$. (a) is added as a paragraph with its proof: the posterior weight of $w_1$ does not depend on $M$, so the unclipped Gibbs risk is unbounded in $M$ at every $n$; with $M=10e^{2\eta n}$ it lies between $100$ and $101$ for $n\ge10$, against $0.92$ at $n=100$, $\delta=0.1$. C.9 open item 6 and the matching bullet of "Not proved here" mention this failure | Remark 3 after Thm C.1, "Predictor"; C.0, "Not proved here"; C.9, open item 6 |
| 13 | the brief's header note says that "for some priors the unclipped versions fail", but Claim C concerns the network prior, under which the unclipped predictors are open; the failures concern the general inequality (Theorem C.1) under a two-point prior | answered in the brief by the lead editor | `problem-brief.md`, header note on Claim C |
| 14 | (informational) README draft: its opening says that each proof had separate logic, computation and scope reviews, but C and E had no scope review before this report; §11 omits C's open problems (C.9 open items 1, 4 and 6) | answered in the README by the lead editor | `../README.md`, opening paragraph and §11; `../verification/README.md` |

**Check of the scope revision.** An independent check of this revision ([`../verification/C-scope-revision-check.md`](../verification/C-scope-revision-check.md)) found issues 7–12 resolved as the table says, each changed passage correct, and the README and brief answers in place. It raised three minor points about this record's own wording, which the lead editor fixed: the paragraph above now mentions the change to the opening paragraph, says which issues use the defined resolution terms, and row 11 names the sentence on Remarks C.4.1–C.4.2. After a final cross-reference check of all the research notes, the opening paragraph now also names this check and its result. It also defines the short name `paper.tex`, which §C.0 uses before §C.1.2 gives the full path. In C.9, the path of the slt-finite-sample README is now written from `NNG/`, so that it resolves.

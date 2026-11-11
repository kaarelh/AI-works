# Referee report on red-team Proposition 4.1 (TUBE with a sup-norm residual budget). Lens: computation

**Verdict: minor fixes.** Proposition 4.1 and its displayed consequence are correct. I checked every place where the proof of `paper.tex` Theorem `strong` uses clean labels; the three stated replacements handle each one, and no other step of that proof depends on the labels. The bound $\mathbb E_\Pi L_D(\operatorname{clip}z_w)\le(\tau+\rho_0)^2+4\varepsilon/3$ holds at Theorem `strong`'s sample size with $u'$ in place of $u$, for every learner width $N\ge C$, on one sample event shared by all widths. Only the sample size and that event are uniform in width; the scale threshold $\sigma_0$ depends on $N$, as in the paper.

Two sentences around the proposition need rewording before the note cites them.

1. "Hard conditioning within the sup-norm residual of a small network never memorizes" is true only in the energy sense that the report gives as its reason. At small $n$ the minimum-energy feasible network does fit label noise; §3, Issue 1 gives an $n=2$ example that is rigorous at depth two for every width.
2. "$25\rho_0^2+4\varepsilon/3$, while $\mathrm{OPT}\le L_D(g)\le\rho_0^2$" invites the reading that TUBE is within a constant factor of OPT. That reading is false. In an exact example the strong-prior TUBE risk tends to $(\rho-p\rho_0)^2+p(1-p)\rho_0^2$, while $L_D(g)=p\rho_0^2\to0$.

The constants are also loose. The same argument gives $(\tau+\sqrt{L_D(g)})^2$ in place of $(\tau+\rho_0)^2$. A uniform-convergence step over the same width-free cover gives $\rho^2+\varepsilon$, and the example shows that this is tight.

The proposition uses no lemma of the red-team report itself. Its inputs are all from `NNG/side-results/continuous-domains/source/paper.tex`:

- Theorem `strong` and its proof (lines 178–197, 510–533);
- Lemma `posterior` (lines 248–268);
- Proposition `energy-cover` (lines 462–503);
- eq. `teacher-energy` (lines 297–308);
- eq. `confidence` (line 144);
- Remark `cube` (lines 225–232).

Scripts and outputs are in `../checks/verify-RT-tube-computation/`; all runs use fixed seeds.

---

## 1. Answers to the three focus questions

**(Q1) Is the bound correct at Theorem `strong`'s sample size, uniformly over $N\ge C$?** Yes. The sample-size polynomial is $p_L(d,C,B,u')$, a majorant of $\log\lvert\mathcal H_{K,a}\rvert$ with $K=E_*+2$ and $1/a\le4u'$. Neither depends on $N$. The good sample event concerns only the training inputs and the width-free cover $\mathcal H_{K,a}$, so it is literally the same event for every width. What is not uniform is the scale threshold, $\sigma_0=\sigma_0(N,g,\rho-\rho_0,\varepsilon)$. In the Laplace bound with a fixed radius around the clone, it scales like $P^{-1/2}$ in the parameter count $P$: it is $0.138,\ 0.0438,\ 0.0138,\ 0.00438,\ 0.00138$ at $P=10,\dots,10^5$ (`v_laplace_ratio.out`). So the statement is "for each $N\ge C$, for all $\sigma<\sigma_0(N)$", which is also what Theorem `strong` says.

**(Q2) Does Theorem `strong` hold verbatim after the replacements?** Yes, with three bookkeeping changes that "verbatim" hides:

- The hypothesis $0<\rho<\tau$ becomes $\rho_0<\rho<\tau-\rho_0$.
- "All distributions $D$ on $X$" becomes "all $D$ on $X\times[-1,1]$ with $\lvert y-g(x)\rvert\le\rho_0$ almost surely".
- $\sigma_0$ depends on $\rho-\rho_0$, hence on $\rho_0$, in addition to $N$, $g$ and $\varepsilon$. It is still independent of $D$ within that class, and of $n$, $\delta$ and the sample.

Clean labels enter the paper's argument in five places, listed in this table; §2 re-derives each one.

| place in `paper.tex` | use of clean labels | replacement | check |
|---|---|---|---|
| eq. `posterior` (130–135) | conditioning event $\lvert z_w(x_i)-f(x_i)\rvert<\rho$ | $\lvert z_w(x_i)-y_i\rvert<\rho$ | definition |
| line 136–137, proof of `strong` (511–512) | the tube $U_\rho$ lies in every conditioning event | $U_{\rho-\rho_0}(g)\subseteq E_S$ by the triangle inequality | `v_inequalities` (1) |
| Lemma `posterior`, last step (266) | $\Pi(G^c\mid S)\le\mu(G^c)/\mu(U_\rho)$ | same with $U_{\rho-\rho_0}(g)$ | follows from the row above |
| Lemma `posterior`, cover step (260–265) | fitted networks keep training inputs out of $A_h$ | $A_h=\{\lvert h-g\rvert>\rho+\rho_0+a\}$, $2a<\tau-\rho-\rho_0$ | `v_inequalities` (2), (3) |
| definitions of $R_\tau$, $q_\tau$ (138–142) | error measured against $f$ | measured against $g$, under the input marginal $D_X$ | definition |

The rest of the argument is label-free:

- the Gaussian tail $\limsup\sigma^2\log\mu_\sigma\{\kappa_N>K\}\le-K/2$;
- Lemma `compression` and Proposition `energy-cover`;
- the energy-Lipschitz bound;
- Markov's inequality in eq. `confidence`.

The union bound in Lemma `posterior` needs only that the $x_i$ are i.i.d. from $D_X$, which holds when the pairs $(x_i,y_i)$ are i.i.d. from $D$.

**(Q3) Does hard conditioning within the residual budget "never memorize"?** Only in the energy sense. The following is true for every $n$ and almost every sample:

- the clone $w_*$ of $g$ is feasible, so the infimum of $\kappa_N$ over the open constraint set is at most $\kappa_N(w_*)\le E_*$;
- for $\sigma<\sigma_0$ the posterior gives mass at most $\varepsilon/6$ to $\{\kappa_N>E_*+2\}$.

Claim A's memorization needs energy that grows with $n$. The memorizer budget $K_{\rm mem}$ of Theorem 2.2 grows like $(H+1)(9dn)^{1/H}$, and Remark 3.5 gives a lower bound of the same order in $n$, which I did not re-verify. That mechanism therefore cannot operate here. The literal claim is false, however. In the $n=2$ example of §3 (Issue 1), the least-energy feasible network predicts $0$ or $0.55$ at a training input according to the sign of that input's training noise. Separately, absence of memorization does not mean small excess: TUBE has a tolerance bias of order $\rho^2$ (Issue 2).

---

## 2. Re-derivation with the replacements

Notation: $g$ has depth $L$, width $C$ and weights in $[-B,B]$ with $B\ge1$. Put $E_*=d(d+1)B^2+2(L-1)C^2B^2$ and $K=E_*+2$. The law $D$ on $X\times[-1,1]$ has $\lvert y-g(x)\rvert\le\rho_0$ almost surely. Let $E_S=\{w:\lvert z_w(x_i)-y_i\rvert<\rho\ \forall i\}$ and $\Pi(\cdot\mid S)=\mu_\sigma(\cdot\cap E_S)/\mu_\sigma(E_S)$.

**Denominator.** For $w\in U:=\{w:\sup_X\lvert z_w-g\rvert<\rho-\rho_0\}$ and a sample in the support,
$$\lvert z_w(x_i)-y_i\rvert\le\lvert z_w(x_i)-g(x_i)\rvert+\lvert g(x_i)-y_i\rvert<(\rho-\rho_0)+\rho_0=\rho .$$
So $U\subseteq E_S$ and $\mu_\sigma(E_S)\ge\mu_\sigma(U)>0$. The set $U$ is open because $X$ is compact, and it contains the exact clone. I re-checked the clone: `v_clone_energy` tested 3969 clones with depths 2–5 and unequal groups. The output error was at most $1.3\cdot10^{-13}$, $\max\kappa_N/E_*=0.977$, and the layer ratios were at most $1$, $0.5625$ and $0.5625$ of $d(d+1)B^2$, $2C^2B^2$ and $2C^2B^2$.

**Energy tail.** For Gaussian coordinates ($m=M=1$),
$$\limsup_{\sigma\downarrow0}\sigma^2\log\frac{\mu_\sigma\{\kappa_N>K\}}{\mu_\sigma(U)}\le-\frac{K-E_*}2=-1 .$$
Hence there is $\sigma_0(N,g,\rho-\rho_0,\varepsilon)$ with ratio at most $b=\varepsilon/6$, and then $\Pi(\kappa_N>K\mid S)\le b$ for every sample. `v_laplace_ratio` checks this with an explicit ball of radius $r$ around a point of energy $E=10$, lower-bounding the ball's mass by its volume times its least density. At $\sigma=0.003$ it gives $\sigma^2\log(\text{ratio})=-0.6782$ against that bound's limit $-(K-(\sqrt E+r)^2)/2=-0.6788$ for $r=0.1$, and $-0.9674$ against $-0.9683$ for $r=0.01$. As $r\to0$ the limit tends to $-(K-E)/2=-1$.

**Cover.** Take $a=\min\{1/2,(\tau-\rho-\rho_0)/4\}$. Then $2a\le(\tau-\rho-\rho_0)/2<\tau-\rho-\rho_0$, and $1/a\le4u'$, with equality when $\tau-\rho-\rho_0<1$. Let $\mathcal H=\mathcal H_{K,a}$, put $A_h=\{x:\lvert h(x)-g(x)\rvert>\rho+\rho_0+a\}$, and let $\Omega_S$ be the event that every $h$ with $D_X(A_h)>t$ has a training input in $A_h$. Since $(1-t)^n\le e^{-nt}$, $\Pr(\Omega_S^c)\le\lvert\mathcal H\rvert e^{-nt}\le\delta$ once $n\ge t^{-1}[\log\lvert\mathcal H\rvert+\log(1/\delta)]$. The event $\Omega_S$ involves only $x_1,\dots,x_n$ and the width-free family $\mathcal H$, so it is the same for every $N$.

On $\Omega_S$, take $w\in E_S$ with $\kappa_N(w)\le K$ and $h$ with $\sup_X\lvert z_w-h\rvert\le a$.

- *Training side:* $\lvert h(x_i)-g(x_i)\rvert\le a+\lvert z_w(x_i)-y_i\rvert+\lvert y_i-g(x_i)\rvert<a+\rho+\rho_0$, so no training input lies in $A_h$ and hence $D_X(A_h)\le t$.
- *Test side:* if $\lvert z_w(x)-g(x)\rvert>\tau$ then $\lvert h(x)-g(x)\rvert>\tau-a\ge\rho+\rho_0+a$, so $x\in A_h$.

Therefore $D_X\{\lvert z_w-g\rvert>\tau\}\le t$. The test-side step needs only $2a\le\tau-\rho-\rho_0$; the strict inequality in Lemma `posterior` is not used (`v_inequalities` (3) includes the boundary case). The training-side bound $\rho+\rho_0+a$ is sharp: the ratio reaches $0.99906$ in `v_inequalities` (2).

**Risk.** Take $t=b=\varepsilon/6$. Then $R_\tau(\Pi)\le t+b=\varepsilon/3$ at $n\ge\frac6\varepsilon[p_L(d,C,B,u')+\log\frac1\delta]$, and eq. `confidence` gives $D_X\{q_\tau\le2/3\}\le\varepsilon$. For $\lvert y\rvert\le1$, $\lvert\operatorname{clip}z-y\rvert\le\lvert z-y\rvert\le\lvert z-g\rvert+\lvert g-y\rvert$ and $\lvert\operatorname{clip}z-y\rvert\le2$. Hence
$$\mathbb E_\Pi L_D(\operatorname{clip}z_w)\le\mathbb E(\tau+\lvert g(x)-y\rvert)^2+4R_\tau(\Pi)\le(\tau+\sqrt{L_D(g)})^2+\tfrac43\varepsilon\le(\tau+\rho_0)^2+\tfrac43\varepsilon .$$
The middle step is $\mathbb E\lvert g-y\rvert\le\sqrt{L_D(g)}$. `v_inequalities` (5) and (7) check the pointwise and averaged forms. The clipping step uses $\lvert y\rvert\le1$; without it the step fails, for example at $y=g=z=1.5$.

---

## 3. Issues

**Issue 1 (minor; the literal claim is false).** *Location:* §4.3, first sentence after the proof, "Hard conditioning within the sup-norm residual of a small network never memorizes: the minimum energy over the constraint set is at most $E_*$ for every $n$."

Example. Take $d=1$, $x$ uniform on $\{-1,1\}$, teacher $g\equiv0.6$ (width one), and $y=0.6+0.3\epsilon$ with $\epsilon$ a fair sign, so $\rho_0=0.3$. Take $\rho=0.35$. The feasible windows are $[-0.05,0.65]$ for $\epsilon=-1$ and $[0.55,1.25]$ for $\epsilon=+1$.

- *Sample $(-1,0.3),(1,0.9)$.* Only $z(1)\ge0.55$ binds. At depth two, Jensen over the concave map $t\mapsto\tanh^2\sqrt{2t}$ shows that identical neurons with first-layer rows proportional to $(1,1)$ are optimal at every width. The least energy is $\min_s\{s^2/2+0.55^2/\tanh^2s\}=0.9933$, and every minimizer has $z(-1)=v\tanh0=0$. The strong-prior limit therefore predicts $0$ at $x=-1$, with test MSE $(0-0.6)^2+0.09=0.45$ there.
- *Sample $(-1,0.9),(1,0.9)$.* The constraint itself forces $z(-1)\ge0.55$. The least-energy fit is the constant $0.55$, with energy $1.3118$ and test MSE $0.0925$ at $x=-1$.

The prediction at a training input thus follows the sign of that input's training noise. Depth three gives the same fits, with energies $2.1472$ and $2.5017$ (`v_small_n.out`, `v_small_n_analytic.out`). On grids of $n\ge8$ inputs with i.i.d. noise, the least-energy fit did not separate the two noise signs in any of nine runs (equal mean outputs on the two groups, test MSE $0.0925$ at the training inputs), so here the effect is a small-sample one.

Two smaller points. The constraint set is open, so "minimum energy" should be "infimum energy"; in Issue 2's example the infimum is not attained. And the energy statement is the true content.

*Fix:* "For every $n$ and every sample, the infimum of $\kappa_N$ over the constraint set is at most $E_*$, and for $\sigma<\sigma_0$ the posterior gives mass at most $\varepsilon/6$ to $\{\kappa_N>E_*+2\}$. Claim A's mechanism, which needs energy growing with $n$, therefore cannot operate. At small $n$ the least-energy feasible network can still fit label noise."

**Issue 2 (minor in the proposition; important for how the note cites it).** *Location:* the last sentence of Proposition 4.1 ("$25\rho_0^2+4\varepsilon/3$, while $\mathrm{OPT}\le L_D(g)\le\rho_0^2$"); also §0 item 7, §6.3 item 3 ("versions that survive") and §7 item 5.

The proposition's comparison quantity is the squared sup-norm residual $\rho_0^2$, not OPT and not $L_D(g)$. The gap between them is a property of the TUBE learner, not of the proof.

Example. Take $g\equiv-c_0$ with $\rho<c_0\le1$, which is a width-one network. Let $y=-c_0+\rho_0\xi$ with $\xi\sim\mathrm{Bernoulli}(p)$ independent of $x$. Then $L_D(g)=p\rho_0^2$, and the Bayes predictor $-c_0+p\rho_0$ is also a width-one network, with risk $p(1-p)\rho_0^2$. Let the input law be one atom $x_0$.

- Any sample with a label $-c_0$, which has probability $1-p^n$, has feasible outputs $z(x_0)\in(-c_0+\rho_0-\rho,\,-c_0+\rho)$.
- The least energy needed to output $c$ at $x_0$ is even and strictly increasing in $\lvert c\rvert$, because scaling the readout by $t<1$ scales the output by $t$ and lowers the energy.
- So as $\sigma\to0$, at every width, the posterior concentrates on $z(x_0)\to-c_0+\rho$ (the argument of Cor. `exact`).

The Gibbs risk tends to $(\rho-p\rho_0)^2+p(1-p)\rho_0^2$. The excess over Bayes is $(\rho-p\rho_0)^2\ge(\rho-\rho_0)^2$, which tends to $\rho^2$ as $p\to0$ and to $(1-p)^2\rho_0^2$ as $\rho\downarrow\rho_0$. For every constant $C'$ and every $\varepsilon<\rho^2$, the bound "risk $\le C'L_D(g)+\varepsilon$" therefore fails for small $p$, at every width and every $n$; the same holds for $C'\,\mathrm{OPT}+\varepsilon$.

Numerics: exact posterior integration at $N=1,2$ with $\rho_0=0.3$ and $c_0=0.8$ (`v_tube_bias.out`). At $\sigma=0.02$ the Gibbs risk is $0.12109$ (limit $0.1213$) for $\rho=0.35$, $p=0.01$, and $0.35688$ (limit $0.3573$) for $\rho=2\rho_0$, $p=0.01$. The latter compares with $L_D(g)=0.0009$, and $\mathbb E_\Pi z=-0.20035$ against the limit $-0.2$. With uniform inputs on $[-1,1]$ instead of an atom (`v_bias_continuous.out`), the least-energy feasible network was exactly the constant $-0.8+\rho$ at depths two and three, with test MSE $0.3465$ against Bayes risk $0.00427$ at $\rho=2\rho_0$, $p=0.05$.

This is consistent with Proposition 4.1, whose bound there is at least $1.44$. ../research-notes/A-tight-conditioning-fails.md Prop. 6.3 shows the same bias when $\rho>\max\lvert y\rvert$, so that the zero network is feasible. In this example the zero network is infeasible and $\rho$ can be arbitrarily close to $\rho_0$.

Two further points for the note. The learner must set $\rho>\rho_0$, so this is a family of learners indexed by a known residual level, not one learner. And a single rare label far from $g$ makes $\rho_0$ large.

*Fix:* replace "while $\mathrm{OPT}\le L_D(g)\le\rho_0^2$" by a sentence saying that the bound compares with $\rho_0^2$ and that TUBE's excess over OPT can approach $\rho^2$ even when $L_D(g)\to0$. In §0 and §6.3, list Proposition 4.1 as a sup-norm, constant-factor guarantee, not as a version of the oracle inequality.

**Issue 3 (minor; loose constants).** $(\tau+\rho_0)^2>(\rho+2\rho_0)^2>9\rho_0^2$ for every admissible $(\rho,\tau)$. The value $9\rho_0^2$ is the infimum, approached only as $u'\to\infty$. Two improvements are available.

- *(a) Same sample size.* The constant can be $(\tau+\sqrt{L_D(g)})^2$; see the display in §2.
- *(b) Sharper bound.* $\mathbb E_\Pi L_D(\operatorname{clip}z_w)\le\rho^2+\varepsilon$ once $n\ge\frac{72}{\varepsilon^2}[\log\lvert\mathcal H_{K,\varepsilon/24}\rvert+\log\frac1\delta]$. This size does not depend on $\rho$, $\rho_0$, $\tau$ or $N$.

Proof of (b). Choose $\sigma_0$ so that the tail-to-tube ratio is at most $\varepsilon/12$. Hoeffding's inequality for losses in $[0,4]$ and a union bound over $\mathcal H'=\mathcal H_{K,\varepsilon/24}$ give, with probability at least $1-\delta$ and for all $h\in\mathcal H'$,
$$L_D(\operatorname{clip}h)\le\hat L(\operatorname{clip}h)+4\sqrt{\ln(\lvert\mathcal H'\rvert/\delta)/(2n)} .$$
The clipped loss is 4-Lipschitz in the prediction (`v_inequalities` (6): maximum ratio $3.98$). So for $w\in E_S$ with $\kappa_N\le K$,
$$L_D(\operatorname{clip}z_w)\le\hat L(\operatorname{clip}z_w)+8\cdot\tfrac{\varepsilon}{24}+4\sqrt{\ln(\lvert\mathcal H'\rvert/\delta)/(2n)}<\rho^2+\tfrac{\varepsilon}3+\tfrac{\varepsilon}3 .$$
Here $\hat L<\rho^2$ because every training residual is below $\rho$. The posterior mass on $\kappa_N>K$ contributes at most $4\cdot\varepsilon/12$. Jensen's inequality extends the bound to the posterior mean of $\operatorname{clip}z_w$.

Issue 2's example shows that (b) is tight: the risk tends to $\rho^2$ as $p\to0$. The red-team's Lemma 3.1, which I did not re-verify, would give (b) at a much smaller sample size of order $\mathcal D^2(K/H)^H/\varepsilon^2$.

**Issue 4 (minor; missing qualifiers).** The statement omits several things that the proof needs or that a reader needs:

- the event has probability $1-\delta$;
- $\sigma_0$ depends on $\rho-\rho_0$ (see Q2);
- the hypotheses become $\rho_0<\rho<\tau-\rho_0$;
- the clipping step uses $\lvert y\rvert\le1$;
- "minimum" should be "infimum" (Issue 1).

The domain $X\subseteq[-1,1]^d$ relies on `paper.tex` Remark `cube`. That remark is prose; the Lean audit (`NNG/lean/review/BatchTwoContinuous-independent-review.md`, `statement-audit-2026-10-23/priors-continuous.md`) certifies the theorem only on the unit ball and lists the bounded-coordinate extension as uncovered.

**Issue 5 (minor; the vacuous range is wider than stated).** The report says the result is vacuous for $\rho_0\ge1$. With the displayed constants, a bound below $4$ (the clipped-loss ceiling) requires $\rho_0<2/5$. A bound below $1$ (the largest possible risk $L_D(0)=\mathbb Ey^2$ of the zero predictor) requires $\rho_0<1/5$. With the best admissible constants the thresholds are $2/3$ and $1/3$ (`v_inequalities` (8), sympy).

**Issue 6 (minor; attribution).** The lead-in "The proof does extend to residuals that are bounded in sup norm" follows a discussion of Prop. `exact` and Cor. `exact`, but Proposition 4.1 extends Theorem `strong`. The zero-tolerance limit of Cor. `exact` does not extend to noisy labels: with $\rho<\rho_0$ the clone is infeasible, and ../research-notes/A-tight-conditioning-fails.md Prop. 6.5 shows that interpolating TUBE has excess $\frac nM(b-\rho)^2$.

**Issue 7 (informational).** "The same polynomial sample size" is astronomically large even for tiny teachers. Using the paper's explicit cover with $\varepsilon=0.1$, $\delta=0.01$, $\rho=2\rho_0$, $\tau=4\rho_0$ (`v_sample_size.out`):

| teacher | $\rho_0$ | Proposition 4.1 needs $n\ge$ | bound (b) needs $n\ge$ |
|---|---|---|---|
| $d=1,C=1,B=1.05,L=2$ | $0.1$ | $1.3\cdot10^{21}$ | $2.9\cdot10^{26}$ |
| $d=1,C=1,B=1.05,L=3$ | $0.1$ | $4.9\cdot10^{46}$ | $1.6\cdot10^{55}$ |
| $d=5,C=2,B=1,L=3$ | $0.02$ | $4.9\cdot10^{59}$ | $2.6\cdot10^{62}$ |

The Proposition 4.1 sizes grow roughly like $u'^8=\rho_0^{-8}$, in line with the $a^{-8}$ degree of the cover. At $d=5$, $C=2$, $L=3$, going from $\rho_0=0.1$ (size $8.7\cdot10^{53}$) to $\rho_0=0.02$ multiplies the size by $5.6\cdot10^5$, against $5^8=3.9\cdot10^5$. This is not an error; it is the paper's polynomial.

---

## 4. Strongest statement I can support

Let $g$ be a depth-$L$, width-$C$ network with weights in $[-B,B]$, $B\ge1$, and put $E_*=d(d+1)B^2+2(L-1)C^2B^2$ and $K=E_*+2$. Let $D$ be a law on $X\times[-1,1]$, with $X\subseteq[-1,1]^d$ compact, such that $\lvert y-g(x)\rvert\le\rho_0$ almost surely. Let $\rho>\rho_0$. Condition the strong-prior Gaussian prior at width $N\ge C$ on $\lvert z_w(x_i)-y_i\rvert<\rho$ for all $i$.

For each $N\ge C$ and $\varepsilon\in(0,1)$ there is $\sigma_0(N,g,\rho-\rho_0,\varepsilon)>0$, independent of $D$, $n$, $\delta$ and the sample, such that for all $\sigma<\sigma_0$:

- **(a) Proposition 4.1, verified.** If $\tau>\rho+\rho_0$ and $n\ge\frac6\varepsilon[p_L(d,C,B,u')+\log\frac1\delta]$, then with probability at least $1-\delta$, on one event for all $N\ge C$: $R_\tau(\Pi)\le\varepsilon/3$ relative to $g$, $D_X\{q_\tau\le2/3\}\le\varepsilon$, and
$$\mathbb E_\Pi L_D(\operatorname{clip}z_w)\le(\tau+\sqrt{L_D(g)})^2+4\varepsilon/3\le(\tau+\rho_0)^2+4\varepsilon/3 .$$
- **(b) Sharper bound.** If $n\ge\frac{72}{\varepsilon^2}[\log\lvert\mathcal H_{K,\varepsilon/24}\rvert+\log\frac1\delta]$, then with probability at least $1-\delta$, $\mathbb E_\Pi L_D(\operatorname{clip}z_w)\le\rho^2+\varepsilon$, and the same holds for the posterior mean of $\operatorname{clip}z_w$.

Neither (a) nor (b) is an oracle inequality, and no bound $C'L_D(g)+\varepsilon$ with $\varepsilon<\rho^2$ holds: Issue 2's example has risk tending to $(\rho-p\rho_0)^2+p(1-p)\rho_0^2$ while $L_D(g)=p\rho_0^2$. Hard conditioning within the budget keeps the posterior at energy at most $E_*+2$ for every $n$, which rules out Claim A's memorization. At small $n$ it can still fit noise.

---

## 5. Numerical record (`../checks/verify-RT-tube-computation/`)

- `v_inequalities.py`: denominator inclusion, both cover-step implications (including the boundary $2a=\tau-\rho-\rho_0$), $1/a\le4u'$, the risk inequality, 4-Lipschitz clipped loss, the refined constant, and sympy arithmetic for $25\rho_0^2$, the infimum $9\rho_0^2$ and the vacuity thresholds. About $2.8\cdot10^6$ draws per check; no violations.
- `v_clone_energy.py`: 3969 clones, $L\le5$, $N\in\{C,C+1,2C\pm1,3C+2,7C+3,50\}$; exact outputs, $\kappa_N\le0.977E_*$.
- `v_laplace_ratio.py`: exact $\chi^2$ tail against a rigorous ball lower bound; the $\sigma\to0$ exponent, and $\sigma_0\propto P^{-1/2}$.
- `v_tube_bias.py`: exact strong-prior TUBE posterior (a truncated-normal mixture) for the one-atom example at $N=1,2$ and $\sigma\in\{0.5,0.2,0.1,0.05,0.02\}$; convergence to $(\rho-p\rho_0)^2+p(1-p)\rho_0^2$. Its truncated-moment routine matches `scipy.stats.truncnorm` to 10 digits.
- `v_bias_continuous.py`: least-energy feasible networks (SLSQP, 20 restarts) with uniform inputs, depths 2 and 3.
- `v_small_n.py`, `v_small_n_analytic.out`: the $n=2$ noise-fitting example (optimizer and closed form agree: $0.9933$ and $1.3118$), and grids of $n=2$ to $32$.
- `v_sample_size.py`: the explicit cover sizes behind Issue 7.

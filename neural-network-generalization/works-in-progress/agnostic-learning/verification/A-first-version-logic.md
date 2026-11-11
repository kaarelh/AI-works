# Referee report on `A-first-version.md`: logic and definitions

*Lens: quantifiers, order of limits, case splits, definitions, misapplied lemmas, missing hypotheses, circularity. Referee for Claims A, A′ and the TUBE variants in `A-first-version.md` (846 lines, read in full). Brief: `../research-notes/problem-brief.md` (read in full). Repository sources opened and compared line by line:*

* `NNG/side-results/continuous-domains/source/paper.tex`: eqs. `energy`, `teacher-energy`, `energy-lipschitz`, `posterior`, `tube`; Theorem `strong` and its proof; Proposition `tube`; Lemma `compression`; Proposition `energy-cover`; Proposition `exact`; Corollary `exact`.
* `NNG/works-in-progress/noisy-interpolation/README.md`: §§2–4, eqs. (2)–(15).
* `NNG/works-in-progress/slt-likelihood/README.md`: §2 (positive theorem and proof), §3 (fixed-likelihood obstructions), §4.

*My sanity scripts are in `../checks/verify-A-first-version-logic/` (`check1.py`, `check2.py` and their `.out` files).*

---

## 1. Verdict

**`minor_fixes`.**

I re-derived every step of every proof in §§1–8 of A-first-version.md. The main mathematical claims are correct as formally stated:

* Lemma 2.1, the memorizer with explicit $K_{\rm mem}$ and $N_0$;
* Lemmas 3.1–3.2 and Corollary 3.3;
* Theorem 4.4 and Corollaries 4.5–4.6;
* Proposition 5.1, the refutation of (P$_L$) under readings (R1)–(R3);
* Proposition 6.1, Lemma 6.2, Proposition 6.3, Lemma 6.4 and Proposition 6.5;
* Theorem 7.2;
* Lemma 8.1 and Propositions 8.2–8.3.

The order of limits is handled correctly throughout: the sample, $d$, $n$, $c$, $t$ and the width $N$ are fixed, then $\sigma\to0$. The $\sigma$-thresholds are allowed to depend on $N$, and are made uniform over samples by a correct compactness or finiteness argument (Remark 3.4). The theorem has no circular step and applies no lemma outside its hypotheses.

The problems found are all in scope statements, discussion remarks, and a few displayed formulas whose direction or range is slightly off. Several of them matter for how the result should be reported to the user (§3, issues 1–3). None of them breaks a proof.

---

## 2. What was checked, step by step

Each row was re-derived by hand. A ✓ means the step is correct as written; a ✓\* means it is correct with a caveat listed in §3.

| Item in A-first-version.md | Check | Status |
|---|---|---|
| §1.1 energy (1.1) | Matches paper.tex eq. `energy` with $\sum_{\ell=2}^{L-1}=\sum_{\ell=2}^{H}$. $\Gamma_N$ is diagonal with entries $d/N,1,N$. | ✓ |
| §1.2 prior variances | $N\sigma^2/d,\ \sigma^2,\ \sigma^2/N$ match paper.tex eq. `strong-scales` and brief §2. | ✓ |
| §1.2 SP$_c$ density | $\exp(-[\kappa_N+\frac1c\sum(z-y)^2]/(2\sigma^2))$ is the product of the prior and the $\mathcal N(z,c\sigma^2)$ likelihood. | ✓ |
| §1.2 TUBE (1.3) | Matches paper.tex eq. `posterior` with $f(x_i)\to y_i$. $U_{\rho,S}$ is open, and Gaussian priors have full support, so the posterior is defined iff $U\neq\emptyset$. | ✓ |
| Lemma 2.2(a) | Grouping by the number $j$ of $-1$ entries. Identity $\sum_{j\le t}(-1)^j\binom qj=(-1)^t\binom{q-1}t$, used in its valid range ($t\le q-1$) in both parities. Exact check for $k<30$. | ✓ |
| Lemma 2.2(b) | Ratio $\frac{2m-1}{2m}\ge\sqrt{(m-1)/m}\iff(2m-1)^2\ge4m(m-1)$. Then $m=\lfloor k/2\rfloor\le k/2$. | ✓ |
| Lemma 2.2(c),(d) | Each argument is an odd integer, so $\lvert t\rvert\ge1$. $2e^{-2\alpha_d}=1/(2\sqrt{2d})$ exactly, so the $\max\{1,\cdot\}$ of the note is unnecessary. In 80-digit arithmetic, $\min_{k\le d\le40}\lvert c_{k,\alpha_d}\rvert 2\sqrt{2k}=1.337$. | ✓ |
| Lemma 2.2(e) | The substitution $v_j=u_jx_j$ is a bijection, and $\prod u_j=\chi_S(x)\prod v_j$. | ✓ |
| Lemma 2.3 | Magnitude induction, error recursion, unrolling. $\sum_{i\ge1}R^{-2i}\le2/R^2$ iff $R^2\ge2$. The ratio of error to bound stays below 1 in 60-digit arithmetic (`check2.out`). | ✓ |
| Lemma 2.1, step 1 | Parseval and Cauchy–Schwarz over $M$ subsets give $\sum_S\lvert\hat r(S)\rvert\le(\sum_x r^2)^{1/2}$. | ✓ |
| Lemma 2.1, step 2 | $A\le2\sqrt{2d}\sum\lvert\hat r\rvert$, using $1/\tanh1<2\sqrt2$. Row norms are at most $(d+1)\alpha_d^2$, and $\lVert\omega_\emptyset\rVert^2=1\le(d+1)\alpha_d^2$ since $(d+1)\alpha_d^2\ge2\alpha_1^2=1.50$. | ✓ |
| Lemma 2.1, step 3 | Hoeffding: increments in an interval of length $2A/m$ give tail $2e^{-ma^2/(8A^2)}$. The union bound over $2^d$ points needs $m>8A^2(d+1)\log2/a^2$, which holds by $A^2\le8ds$ and the definition of $N_0$. | ✓ |
| Lemma 2.1, steps 4–6 | Layer-2 preactivation is $g/R^{H-1}$. $\kappa^{(2)}=\frac{NA^2}{m^2R^{2H-2}}\sum_t k_t^{-1}\le 2A^2/R^{2H-2}\le2R^2$, using $k_t\ge N/(2m)$. Layers $3..H$ and the readout cost $R^2$ each, so the total is $d(d+1)\alpha_d^2+(H+1)R^2$. Chain error: $\frac{2(3/2)^3}{3}\cdot\frac{2a}{9}=\frac a2$. The case $H=2$ was checked separately. | ✓ |
| Lemma 3.1 | (a) uses $\lvert h\rvert\le1$ and Cauchy–Schwarz. (b) multiplies Frobenius norms (the constant coordinate cancels), then applies AM–GM over the $L$ layer energies. It sharpens paper.tex eq. `energy-lipschitz` by $L^{-L/2}$. | ✓ |
| Lemma 3.2 | Minimizer exists by coercivity. With $\theta=t/(4(F^*+t))$: $(1-\theta)(F^*+t)-(F^*+t/4)=t/2$, so the exponent is $-t/(4\sigma^2)$. Monotonicity needs $p\le(1-\theta)/(2\sigma^2)$, which follows from $\sigma^2\le3/(8p)$. Gaussian integral $(2\pi\sigma^2/\theta)^{P/2}(\det\Gamma)^{-1/2}$. A 1-D toy check passes (`check1.out` §6). | ✓ |
| Corollary 3.3 | Decomposition $\bar z-m=(p-1)m+\int_{\mathcal N^c}z$. $\lvert z\rvert\le\sqrt{\kappa}\le\sqrt F$. Jensen on the compact set $\mathcal N_t$. | ✓\* (issue 13) |
| Remark 3.4 | Finite sample space, or equicontinuity of $\{F_{c,S}\}_S$ on $(\{\kappa\le n/c\}+\bar B(0,1))$: one radius $\delta$ serves all samples, and $F^*\le n/c$. | ✓ |
| Lemma 4.1 | (a) within-atom orthogonality. (b) $F(w)\le F(w_0)+t$, then cancel $W/c$. The correction $na^2$ to the brief's mechanism is right. (c) Clipping is the projection onto $[-1,1]\ni\bar y_x$. | ✓ |
| Lemma 4.2 | $\mathbb E[(f-y)^2\mid x]=f^2+1$. Reverse Minkowski on $\mathcal S$, and $\sum_{\mathcal S}(g-\bar y)^2\le\Delta(g)$ since $k_x\ge1$. | ✓ |
| Lemma 4.3 | (a) $\mathbb E[\bar y_x^2\mid\text{inputs}]=1/k_x$. (b) McDiarmid with $c_i=2$ gives $e^{-u^2/(2n)}$. (c) Le Cam: $d_{TV}\le np^2$, and the test function lies in $[0,1]$. (d) Closed forms, $\beta'=h-\beta$, uniqueness of the maximizer. Values reproduced: $\beta(1)=0.4848291$, $\lambda^*=1.502861$, $\beta(\lambda^*)=0.5173514$. | ✓ |
| Theorem 4.4 (i)–(iv) | The comparator $r=\bar y\mathbf 1_{\mathcal S}$ satisfies $\sum r^2=Q\le\lvert\mathcal S\rvert\le s$. $N_0$ depends only on $(d,s,a)$, not on $S$, so the statement holds "simultaneously for every $N\ge N_0$" on an event that depends only on $S$. $\Delta\le M\epsilon$. Monotonicity in $Q$. Posterior means via convexity of $\Delta$ and (3.3). Uniformity from finitely many samples. | ✓ |
| Corollary 4.5 | Each term of $\epsilon_d$ tends to 0. (4.4) implies $c_d=o(2^d)$. Threshold $64\log2\approx44.4$. Equivalence of (4.4) with $c_d=o(n^{1-1/H}d^{-1/H})$. | ✓\* (issue 4) |
| Corollary 4.6 | Bias–variance identity. $\mathbb E[Q_\eta\mid\text{inputs}]=\sum_{\mathcal S}V/k\ge v_0\sum1/k$. McDiarmid with differences 8 gives $e^{-u^2/(32n)}$. | ✓ |
| §5.1, (P$_L$) | Matches brief §1, including "every learner width $N\ge m$" and $n\ge\mathsf p(d,m,B,1/\varepsilon,\log1/\delta)$. | ✓ |
| Proposition 5.1 | All quantifiers in (P$_L$) other than $\mathsf p$ (and $\sigma_0$ in R1) are universal, so the counterexample tuple $(d,D_d,g\equiv0,N\ge N_0,\varepsilon,\delta,n=2^d)$ may be chosen in any order. $2^d\ge q(d)$ eventually. R1: $\Pr\le\Pr(\mathcal E^c)+\sup_{S\in\mathcal E}\Pi(\mathcal N_t^c)$. R2: margin $\gamma/2$. R3 needs no measurability on $\mathcal E$. The refutation does not depend on the order of quantifiers. | ✓\* (issues 2, 5, 15) |
| Proposition 6.1 | All $k_x\in\{0,1\}$, so $W=0$ and $Q=n$. (b) Hoeffding with range $[0,4]$ gives $e^{-u^2/(8n)}$. | ✓\* (issue 6) |
| Lemma 6.2 and its finite-scale remark | $\{\kappa<r_U\}\subseteq U$. Markov on $\sigma^2\chi^2_P$. $\lvert L_D(z)-L_D(0)\rvert\le\kappa+2\sqrt\kappa$. The finite-scale part uses slt-likelihood §3, $\mathbb E[z^2\mid\text{hidden}]\le N^{-\gamma}$, which I confirmed in the source. | ✓ |
| Proposition 6.3 | Every sample has $\max\lvert y_i\rvert<\rho$. Width-one constant network: $\tanh(2\tanh1)=0.909>\tanh1$, $\lvert v\rvert\le1.313$. | ✓ |
| Lemma 6.4 | Conditioning on the first half, and McDiarmid for $\lvert S_1\rvert$. Numeric forms $0.0395\,n(n-1)/M$ and $0.1998\,n_1$. Monte Carlo is below the bound in every case (`check1.out` §4). | ✓ |
| Proposition 6.5 | Feasibility via Lemma 2.1 at accuracy $\rho/2$. Every draw lies in the open interval, so the mean lies in the closed one. Clipping uses $1-\eta\ge b$ and $\eta>-1$. | ✓ |
| Lemma 7.1 | Corner cubes are disjoint since $1-r\upsilon_j>0$. The pairing $\upsilon\leftrightarrow\upsilon+\frac12e_1$ gives $\lvert\mathbb E[gy\mid p]\rvert\le\Lambda r/4$. Network Lipschitz bound $B^Lm^H\sqrt d$ from the input columns only. | ✓ |
| Theorem 7.2 | $K_2\ge K_{\rm mem}\ge\frac92(H+1)>L$, so $r<1/n$. Near-minimizers have $\kappa\le n/c+t\le K_2$, hence vary by at most $1/n$ on a cluster. Comparator residual by Minkowski. $\sqrt{u+v^2}\le\sqrt u+v$ gives $\Delta(\zeta)\le2E\sqrt n+E^2$. Piecewise-constant risk $1+\frac1M\sum_p\zeta_p^2$. Posterior means via Jensen and (3.3). | ✓\* (issues 7, 16) |
| Lemma 8.1 | Halfspace mixture $\mathbb E\,{\rm sign}(u-T)=\tanh u$. Sauer–Shelah gives $(M+1)^{d+1}$, so $\log J\le(d+1)^2\log2$. Massart. The one-sided contraction needs no $\phi(0)=0$. Clip-mixture identity (re-derived by parts; matches note eq. (13)). Path-norm induction. $P\le(\kappa/H)^{H/2}$ by AM–GM (note eq. (14)). | ✓ |
| Proposition 8.2 | (a) $\varepsilon_if(x_i)\ge1-a$. (b) Polarization, and $\sup\ge0$ via the zero network. | ✓\* (issue 10) |
| Proposition 8.3 | Comparison with $w=0$ gives $c\kappa+\sum z^2\le ct+2\Phi$. McDiarmid in $y$ with differences $2\sqrt{K_0}$. Symmetrization and contraction with Lipschitz constant $2\sqrt{K_0}$. McDiarmid in $x$ with differences $K_0/n$. | ✓\* (issue 3) |

**Repository citations.** Every equation or label cited from the three sources exists and says what A-first-version.md uses it for. This includes paper.tex `energy`, `energy-lipschitz`, `posterior` and the strong-prior Laplace bounds in the proof of Theorem `strong`. In the noisy-interpolation note it includes eqs. (2), (3)–(4), (9), (10), (13), (14) and (15), with constants $a_d=\max\{1,\frac12\log(4\sqrt{2d})\}$, $F_d$, $Q$, $A_s^2$ and $D_{d,H}=\sqrt2(d+2)+\frac{H-1}2$ as quoted. In the slt-likelihood note it includes §2 (residual budget $cK$, $K=E_\star+1$) and §3 ($\mathbb E z^2\le N^{-\gamma}$). A-first-version.md never relies on a repository statement without re-proving it; Lemma 3.2 and Lemma 8.1 are re-derived in full. One description of a source is imprecise (issue 9).

---

## 3. Issues

Severity "minor" means the proof survives unchanged after the fix. I found no critical or major issue. Issues 1–3 come first because they affect how the result should be reported, not because they invalidate a proof.

### Issue 1 (minor, but the most important caveat): the "$o(1)$" reading needs uniformity in $d$

**Location.** §5.2, item 2 (line 463): "That reading is refuted for every $\alpha$ and every $o(1)$, because $g\equiv0$ belongs to every such class and the excess is $\Omega(1)$."

**Problem.** This is a quantifier slip. The constant excess holds only along $n\asymp2^d$, that is, with $d\to\infty$.

For a **fixed** law $D_d$ (fixed $d$), the certified lower bound is $\approx\beta(n/2^d)$. This tends to $0$ as $n\to\infty$, which A-first-version.md itself notes in item 1 ("eventually consistent on $D_d$"). An upper bound also holds at fixed $d$. Compare with the zero network, as in Lemma 4.1(b) with $w_0=0$: every near-minimizer has $\Delta(z_w)\le\Delta(0)+ct$, where $\Delta(0)=\sum_xk_x\bar y_x^2$ has mean $\mathbb E\lvert\mathcal S\rvert\le M$. Write $k_{\min}=\min_xk_x$. Then
$$\textstyle\sum_xz^2\le2\big(\sum_x(z-\bar y)^2+\sum_x\bar y^2\big)\le2\,(2\Delta(0)+ct)/k_{\min}.$$
Since $k_{\min}\ge n/(2M)$ with high probability once $n\gg M\log M$, this gives $\frac1M\sum_xz^2=O(M/n)$ with high probability.

So if the $o(1)$ is allowed to depend on $d$ (or on $D$), the cube example refutes nothing. The reading is refuted only when the $o(1)$ is a function of $n$ alone, uniform over the input dimension $d$ (for example, over all $d\le n^\alpha$; here $d=\log_2n$).

The formal Proposition 5.1 is unaffected, because (P$_L$) is explicitly uniform in $d$ through $\mathsf p(d,\dots)$. But the user's original sentence ("after seeing $n$ data points, test loss is at most the min test loss among all width poly($n$) MLPs") does not mention $d$, so this caveat decides whether the result refutes what the user meant.

**Fix.** Replace the sentence with: "That reading is refuted for every $\alpha$ whenever the $o(1)$ term is uniform over the input dimension (e.g. over all $d\le n^\alpha$), because $g\equiv0$ belongs to every such class and the excess is $\Omega(1)$ along $n=2^d$. At any fixed $d$ the cube example is consistent as $n\to\infty$, so a fixed-dimension version of the conjecture is not refuted here."

Repeat this qualifier wherever §0 or a summary says the conjecture "is false".

### Issue 2 (minor): "under every reading of the $\sigma\to0$ learner" is broader than what is proved

**Location.** §0, item 4 (line 20): "Theorem 4.4 then violates the oracle inequality of brief §1 for SP$_c$ under every reading of 'the $\sigma\to0$ learner'." Compare §10, item 4 (line 843).

**Problem.** Brief §2 lists three predictors: Gibbs, posterior mean, and **progressive mixture**. Proposition 5.1 covers only (R1)–(R3): Gibbs, the three posterior means, and points of $\mathcal N_t$. That includes MAP and every weak limit of $\Pi_\sigma$, since these are supported on $\arg\min F\subseteq\mathcal N_t$.

§10 item 4 states that the progressive mixture is **not** covered. The §0 sentence contradicts this.

A lower bound for the progressive mixture looks attainable but needs a new argument. The prefix posterior means $m_t$ are uncontrolled on atoms not yet seen at time $t$. One would need to show that this unseen-atom part is asymptotically uncorrelated with the future label averages, using independence of the later labels at $x$ from the first $\tau_x-1$ samples. That argument is not in A-first-version.md.

**Fix.** Change §0 item 4 to "under each of the readings (R1)–(R3) of §5.1 (Gibbs draw, posterior mean clipped or not, any near-minimizer, hence MAP and every $\sigma\to0$ weak limit); the progressive-mixture predictor is not covered (§10)."

### Issue 3 (minor): the "above-threshold" claims need $c=o(n)$, or $t\to0$

**Locations.**
* §0, item 7 (line 29): "for $c\ge n^{1-\vartheta}$ with $\vartheta<1/H$, near-minimizers on the cube example do not memorize."
* §8.3, "The threshold, sharply", *Above* (line 780): "whenever $c\gg n^{1-1/H}D_{d,H}^{2/H}/H$."

**Problem.** The right side of Proposition 8.3(a) contains the term $ct/n$. With fixed slack $t$, this does not vanish for $c\gtrsim n$. Proposition 8.3 itself is stated correctly, for $c=n^{1-\vartheta}$ with (implicitly) $\vartheta>0$. The two summaries extend it to all larger $c$, which the proof does not cover.

Concretely, let $C_t=2(1+\sqrt{t/2})^2/t$. If $c\ge C_tn$, then every $w$ with $\kappa_N(w)\le t/2$ satisfies
$$F_{c,S}(w)\le\tfrac t2+\tfrac nc\big(1+\sqrt{t/2}\big)^2\le t\le\inf F_{c,S}+t,$$
so $\mathcal N_t\supseteq\{\kappa_N\le t/2\}$. The data term no longer pins near-minimizers down, and the right side of (a) is at least $ct/n\ge C_tt$, so (a) gives no information.

**Fix.** State the range as $n^{1-\vartheta}\le c=o(n)$, or let $t=t_n\to0$ with $ct_n/n\to0$. Add "and $c=o(n)$" to the *Above* bullet.

### Issue 4 (minor): Corollary 4.5 has a "$=$" that should be "$\le$", and needs "for all large $d$"

**Location.** Corollary 4.5, display of $\epsilon_d$ (line 372) and the statement (lines 368–371).

**Problem.**
* The displayed $\epsilon_d$ replaces $\max\{(8ds)^{1/H},\frac9{2a}\}$ by a sum and $s$ by $n_d$. So it is an upper bound for $\epsilon$ of (4.3), not an equality. The chain of inequalities still runs in the right direction, since a larger $\epsilon$ gives a smaller $\underline e$.
* Lemma 2.1 requires $a_d\le1$, that is, $\max\{c_d,1\}\le2^d$. This holds only for large $d$, by $c_d=o(2^d)$, but the corollary says "Then (i)–(iv) hold" without the qualifier.

**Fix.** Write $\epsilon_d\le\dots$, and add "for all $d$ large enough that $a_d\le1$".

### Issue 5 (minor): Proposition 5.1 (R3) fixes an arbitrary $t>0$, but Corollary 4.5 assumes $t\in(0,1]$

**Location.** §5.1 (R3), line 445, and the proof of Proposition 5.1, line 453.

**Problem.** For $t>1$ the inclusion $\mathcal N_1\subseteq\mathcal N_t$ goes the wrong way, so Corollary 4.5 does not literally apply. The extension is trivial: every term of $\epsilon_d$ still tends to 0 for any fixed $t$. But it is not stated.

**Fix.** Drop the restriction $t\le1$ in Corollary 4.5, or add one line in Proposition 5.1.

### Issue 6 (minor): "test MSE tending to 2" asserts an upper bound that is not proved

**Location.** Proposition 6.1(a), line 478.

**Problem.** Only the lower bound $\ge2-o(1)$ is proved. The matching upper bound is easy at $n=M$ without replacement, where $\mathcal S=\mathcal C_d$ and $\Delta=\sum_x(z-y_x)^2\le M\epsilon'$. Then $L\le1+(1+\sqrt{\epsilon'})^2$ for near-minimizers, and similarly for $m_\sigma$ by Jensen and for $\bar z$ by (3.3).

**Fix.** Add that line, or say "at least $2-o(1)$".

### Issue 7 (minor): Remark 7.3 overstates in two places

**Location.** Remark 7.3, lines 672 and 674.

**Problems.**
* "Yet the learner's risk tends to $1+\beta(\lambda)$": only the lower bound $\ge1+\beta(\lambda)-o(1)$ is proved.
* "a construction that works at every width $N\ge N_0$ and every $\sigma$": items (ii)–(iii) of Theorem 7.2 are $\sigma\to0$ statements. Only (i), about near-minimizers, involves no $\sigma$. The intended meaning is probably "the radius does not depend on $N$ or $\sigma$".

**Fix.** Say "is at least $1+\beta(\lambda)-o(1)$", and "the radius $r$ does not depend on $N$ or $\sigma$".

### Issue 8 (minor): §5.2 item 1 is not proved, and is misleading about where the failure lives

**Location.** §5.2, item 1, line 462: "For $n\gg2^d$ the excess $\beta(\lambda)\sim1/\lambda$ decays, so the learner is eventually consistent on $D_d$, but only after exponentially many samples."

**Problems.**
* The decay of a **lower** bound does not imply consistency. An upper bound is needed; the sketch in issue 1 supplies one.
* The certified lower bound $\beta(n/2^d)\sim n/2^d$ also vanishes for $n=o(2^d)$. The proved failure is therefore confined to the window $n=\Theta(2^d)$. Whether the learner is good for $n\le\varepsilon2^d$ depends on the values on unseen atoms (Remark 4.8), which are not controlled. So "only after exponentially many samples" is not established.

Neither point affects Proposition 5.1, which needs only the single scale $n=2^d$.

**Fix.** "The proved excess is $\Omega(1)$ in the window $n=\Theta(2^d)$. The lower bound vanishes outside it, and consistency at fixed $d$ follows from a comparison with the zero network (one line). (P$_L$) fails because it must hold at $n=2^d$."

### Issue 9 (minor, harmless): the description of the repository's $\sigma$-thresholds is imprecise

**Location.** §5.1 (R1), line 443: "This matches the repository's strong-prior theorems, whose scale thresholds depend on width and sample size."

**Problem.** In paper.tex Theorem `strong`, $\sigma_0$ explicitly "does not depend on $D,n,\delta$". In slt-likelihood §2 the threshold may depend on $n$ and $N$. Since (R1) lets $\sigma_0$ depend on everything, it is the most lenient reading, and the refutation is unaffected.

**Fix.** "…whose scale thresholds depend on the width (and, in the slt-likelihood theorem, on the sample size); (R1) is more lenient than both."

### Issue 10 (minor): §0 item 7 conflates Proposition 8.2(a) and (b)

**Location.** §0, item 7, line 28.

**Problem.** The text says "memorizes most sign patterns … needs $K\ge H\big(\frac{(1-a)\sqrt s}{D_{d,H}}\big)^{2/H}$". That bound is (a), for **all** patterns with sup-accuracy $a$. The "most patterns" version (b) has $\frac{(1-q)(1-\theta)\sqrt s}{2D_{d,H}}$.

**Fix.** Quote (a) for "all patterns", or quote (b).

### Issue 11 (minor): treating "undefined" as failure should be an explicit convention

**Locations.** Lemma 6.4, Table 6.1, and the discussion after Proposition 6.3 ("An MSE-consistent TUBE learner needs $\rho_n\to0$. Then the next two results apply.").

**Problem.** For TUBE$_{\rho\le1}$ with replacement, the failure is that the posterior is undefined with high probability. Counting this as a failure of (P$_L$) requires stating that an undefined output fails the event $\{L_D(\mathsf A_n)\le L_D(g)+\varepsilon\}$. A learner with a fallback, for example "output $0$ when $U_{\rho,S}=\emptyset$", is a different learner.

**Suggestion.** With that convention made explicit, A-first-version.md already contains a complete refutation of TUBE for **every** tolerance schedule $\rho(n)$ at the strong-prior limit. At $n=2^d$, either $\rho\le1$, and the posterior is undefined for fair labels (Lemma 6.4), or $\rho>1$, and it collapses to $0$ with excess $\eta_0^2$ for non-centred labels (Proposition 6.3(a)). State this as a proposition.

### Issue 12 (minor): §10 item 3 overstates the finite-scale TUBE results

**Location.** §10, item 3, line 842: "The TUBE results of §6 do hold at finite scale."

**Problem.** At finite scale:
* the collapse is shown only in the limit $N\to\infty$ at fixed $\gamma$ (the remark after Lemma 6.2), not at a fixed finite $N$;
* Proposition 6.3 itself is a $\sigma\to0$ statement;
* only Lemma 6.4(a) and Proposition 6.5 hold for every prior at every scale.

**Fix.** Say exactly which statements hold at finite scale, and for which $N$.

### Issue 13 (minor, trivial): Corollary 3.3 needs $\Pi_\sigma(\mathcal N_t)>0$

**Location.** Corollary 3.3, definitions of $m_\sigma$ and $m^{\rm cl}_\sigma$.

**Problem.** The conditional expectations need $\Pi_\sigma(\mathcal N_t)>0$. This follows from the ball $B(w^*,\delta)\subseteq\mathcal N_t$ of Lemma 3.2, but is not stated.

**Fix.** Add one clause.

### Issue 14 (cosmetic): the nearest-neighbour remark

**Location.** Remark after Lemma 4.3, line 338.

**Problem.** "$1+\beta$ is the risk of predicting by the mean of the $k$ labels at the test atom" holds at **every** $\lambda$, not only at $\lambda=1$. Calling it "Cover's nearest-neighbour formula $R^*(1+1/k)$" is a loose analogy: it is the $k$-NN regression variance identity, averaged over a random $k$.

**Fix.** Reword.

### Issue 15 (minor, presentational): (R3) should use outer probability

**Location.** §5.1 (R3), line 445, and the proof of Proposition 5.1 (R3).

**Problem.** "No measurability is needed" is correct only if $\Pr[L_{D_d}(\mathsf A_n)\le\dots]$ is read as an outer probability. The bound holds because the event is contained in the measurable set $\mathcal E^c$.

**Fix.** Say so.

### Issue 16 (minor, presentational): $\underline e'$ in Theorem 7.2(i) depends on the sample

**Location.** Theorem 7.2(i), line 613.

**Problem.** $\underline e'$ is defined using the random $Q$, whereas $\underline e$ in Theorem 4.4 is deterministic.

**Fix.** Either write $Q$ explicitly, or substitute the bound $Q/M\ge\beta_n-\sqrt{2\lambda\log(1/\delta)/M}$, which holds on $\mathcal E'$, to get a deterministic $\underline e'$ as in (4.3).

---

## 4. Points examined and found sound (possible objections)

1. **Could minimizers avoid memorizing through a cheaper configuration?** No. Lemma 4.1(b) uses the memorizer only as a competitor, so every near-minimizer has $\Delta\le c(K_{\rm mem}+t)+na^2$, whatever the global minimizer looks like.
2. **Could unseen atoms offset the excess?** No. $L_{D_d}(f)=1+\frac1M\sum_{\mathcal C_d}f^2\ge1+\frac1M\sum_{\mathcal S}f^2$, so unseen atoms only add.
3. **Does $N_0$ depend on the sample?** No. It depends on $(d,s,a)$ with $s=\min\{n,M\}$ deterministic. "Simultaneously for every $N\ge N_0$ on an event depending only on $S$" is therefore correct.
4. **Order of limits.** Fixed $(d,n,c,t,N,S)$, then $\sigma\to0$. Thresholds $\sigma_0(d,n,N,H,c,t,\epsilon')$ are uniform over samples through finiteness (cube) or equicontinuity on a compact energy sublevel (Theorem 7.2). Both are correct.
5. **Is (P$_L$) faithful to brief §1?** Yes. The refutation picks $(d,D_d,g\equiv0,N\ge N_0,\varepsilon,\delta,n=2^d)$; all of these are universally quantified, so the order of choice is free. $g\equiv0$ has width 1, zero weights and $B=1$, so it lies in every competitor class.
6. **Theorem 7.2's law depends on $(c,t,a)$ through $r$.** This is allowed, since (P$_L$) quantifies over all laws after the learner is fixed. Proposition 6.3's width-one competitor has weights $\le2$, inside the class of the brief.
7. **Lemma 8.1's contraction step without $\phi(0)=0$** is valid for the one-sided supremum. The noisy-interpolation note gives the proof.

---

## 5. Numerical checks run

Script and output: `../checks/verify-A-first-version-logic/check1.py`, `check1.out` and `check2.py`, `check2.out`.

1. $\beta(1)=0.48482910699$, by quadrature, series and the Ei formula. $\lambda^*=1.5028610$, $\beta(\lambda^*)=0.5173514=(1-e^{-\lambda^*})/\lambda^*$. $\max\lvert\beta'\rvert\approx0.996$ on a grid. This matches Lemma 4.3(d).
2. Lemma 2.2(a): exact closed form for $k<30$. Lemma 2.2(d): $\min\lvert c_{k,\alpha_d}\rvert2\sqrt{2k}=1.337$ over $k\le d\le40$, in 80-digit arithmetic.
3. Lemma 2.3: ratio of error to bound at most $0.99999999868$ in 60-digit arithmetic. The double-precision value $1.00000006$ is cancellation at small $g$.
4. Lemma 6.4(b): the bound holds above Monte Carlo in five settings, for example $0.020$ against $0.379$ at $M=1024$, $n=128$. The numeric form is valid but can exceed 1 when $n$ is small.
5. Proposition 6.3: $\tanh(2\tanh1)=0.9093>\tanh1=0.7616$ and $1/\tanh1=1.313$.
6. Lemma 3.2, (3.2), in a 1-D toy ($F=w^2+4\sin^2w$, $t=1$, $p=\frac12$): the left side is below the right side at $\sigma^2\in\{0.2,0.1,0.05,0.02\}$.
7. Re-ran and read A's `bounds_table.out`. Table 4.1 and the admissible-$c$ numbers of Remark 4.7 match. A's other `.out` files match the statements in §9.

---

## 6. Summary for the lead

* **Proved.** Claim A (Theorem 4.4 and Corollaries 4.5–4.6), its refutation of the brief's (P$_L$) for SP$_c$ at depth $L\ge3$ under readings (R1)–(R3) (Proposition 5.1), Claim A′ (Theorem 7.2), and the TUBE variants (§6). These are correct, with explicit constants and with the order of limits handled properly.
* **Before reporting to the user.**
  * Fix issue 1: the refutation is of the **dimension-uniform** statement. At fixed $d$ the cube example is consistent.
  * Fix issue 2: the progressive-mixture predictor of SP$_c$ is **not** covered.
  * Fix issue 3: the above-threshold claims need $c=o(n)$.
* **Remaining items.** Issues 4–16 are local edits.

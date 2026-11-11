# Referee report on `../research-notes/A-tight-conditioning-fails.md` (revision 1): logic and definitions

*Lens: quantifiers, order of limits, case splits, definitions, misapplied lemmas, missing hypotheses (widths, weight bounds, clipping, measurability, existence of minimizers), circularity. Under review: `../research-notes/A-tight-conditioning-fails.md` (1123 lines, read in full, including Appendix R). Brief: `../research-notes/problem-brief.md` (read in full). This file replaces the round-0 logic report on `A-first-version.md`; that report's issue list was used only to check that its fixes landed in the text (§3).*

*`NNG/` denotes the project folder `neural-network-generalization/` of this repository. Sources opened and compared with A.r1's use of them:*

* `NNG/side-results/continuous-domains/source/paper.tex`: eqs. `posterior` (l. 130), `energy` (l. 293), `teacher-energy` (l. 303), `energy-lipschitz` (l. 475); Theorem `strong` (l. 178–197) and its proof (l. 510–533); Proposition `energy-cover`; Remark `cube`.
* `NNG/works-in-progress/noisy-interpolation/README.md`: §2 eqs. (2)–(7), §3 eqs. (8)–(10), §4 eqs. (12)–(15).
* `NNG/works-in-progress/slt-likelihood/README.md`: §2 (theorem, proof, the $c\sigma^2$ remark), §3 ("Raw priors").
* `NNG/README.md`, main result 1 (l. 33).
* Sibling sections cited in §0.1, §5.4 and §10: `../research-notes/B-tempered-likelihood.md` (Prop. 6.1, Thms 6.3–6.4, Cor. 8.1, Cor. 9.3), `../research-notes/E-finite-prior-scale.md` (Thm 2.7, Cor. 5.4, §5.4), `../research-notes/red-team.md` (§4.3 Prop. 4.1, §5, §6.2–6.4, Prop. 6.1, Rem. 6.2), and the referee reports `B-*.md`, `E-logic.md`, `RT-tube-logic.md`, `RT-width-logic.md`, `A-first-version-scope.md`, `A-first-version-computation.md`.

*Sanity script: `../checks/verify-A-logic/checks.py`, output `checks.out` (§6).*

---

## 1. Verdict: `minor_fixes`

* **Proofs.** I re-derived every lemma, proposition, theorem and corollary in §§2–8. Each proof is correct as stated. I found no circular step, no lemma applied outside its hypotheses, and no step that assumes its conclusion.
* **Limit order.** It is handled correctly throughout. First $(d,n,c,t)$, the width $N$ and the sample $S$ are fixed; then $\sigma\to0$. Every $\sigma$-threshold may depend on $N$, which is within reading (R1). Uniformity over samples is proved, not assumed: Remark 3.4 covers the finite sample space and, for compact inputs, uses equicontinuity.
* **Round-0 issues.** All 16 issues of the round-0 logic report are fixed in the body of the text, not only listed in Appendix R. I checked each location (§3).
* **New material.** The results added in this revision are correct: Propositions 5.2, 6.1(a′), 6.6 and 7.4, Remark 7.6's energy floor, and the $c\ge C_tn$ remark in §8.3.
* **What remains (§4).** None of the remaining issues breaks a proof or changes what is refuted:
  * one internal contradiction, where two sentences understate Proposition 8.3(b);
  * several summary sentences that drop hypotheses: width thresholds, the strong-prior restriction for $\rho>1$, and $cK_{\rm mem}=o(n)$;
  * a $\sigma$-threshold whose stated dependence is incomplete;
  * a citation of `../research-notes/red-team.md` Proposition 6.1 that a later referee report has corrected;
  * a numeric range, one unproved "$\to$", and some framing.

---

## 2. Step-by-step check

A ✓ means the step is correct as written. A ✓\* means it is correct, with a caveat listed in §4.

| Item | What I checked | Status |
|---|---|---|
| §1.1 energy (1.1) | Same as paper.tex eq. `energy` (l. 293–296), with $\sum_{\ell=2}^{L-1}=\sum_{\ell=2}^{H}$. $\Gamma_N={\rm diag}(d/N,1,N)$. | ✓ |
| §1.2 SP$_c$, TUBE (1.3) | The SP$_c$ density is prior × $\mathcal N(z,c\sigma^2)$, matching slt-likelihood §2 and its "observation variance $c\sigma^2$" remark. TUBE is paper.tex eq. `posterior` with $f(x_i)\to y_i$. $U_{\rho,S}$ is open and both priors have full support, so the posterior is defined iff $U\ne\emptyset$. | ✓ |
| Lemma 2.2(a)–(e) | (a) Grouping by $j$, and $\sum_{j\le t}(-1)^j\binom qj=(-1)^t\binom{q-1}t$ for $t\le q-1$, in both parities. (b) $(2m-1)^2\ge4m(m-1)$, and $m=\lfloor k/2\rfloor\le k/2$. (c) Every argument is an odd integer. (d) $2e^{-2\alpha_d}=1/(2\sqrt{2d})$ exactly. (e) The bijection $v_j=u_jx_j$. | ✓ |
| Lemma 2.3 | Magnitude induction $\lvert y_j\rvert\le\lvert\tilde y_j\rvert$; error recursion; unrolling to $\frac{\lvert g\rvert^3}3\sum_{i=1}^{H-1}R^{-2i}$; $\sum_{i\ge1}R^{-2i}\le2/R^2$ iff $R^2\ge2$. $H=2$ checked directly: $\lvert R\tanh(g/R)-g\rvert\le\lvert g\rvert^3/(3R^2)$. | ✓ |
| Lemma 2.1 | Step 1: Parseval and Cauchy–Schwarz over $M$ subsets. Step 2: $A\le2\sqrt{2ds}$, with $1/\tanh1=1.313<2\sqrt2$; row norms $\le(d+1)\alpha_d^2$; $\omega_\emptyset$ handled. Step 3: Hoeffding with interval length $2A/m$ gives $2e^{-ma^2/(8A^2)}$; the union bound needs $m>8A^2(d+1)\log2/a^2$, which follows from $A^2\le8ds$ and $m=N_0$. Step 4: requires $N\ge m$, and $\lfloor N/m\rfloor\ge N/(2m)$; the layer-2 preactivation is $g/R^{H-1}$ with no bias. Step 5: $\kappa^{(2)}\le2A^2/R^{2H-2}\le2R^2$; total $d(d+1)\alpha_d^2+(H+1)R^2$. Step 6: $R^2\ge9/(2a)\ge2$ and $\lvert g\rvert\le3/2$ give chain error $\le a/2$. | ✓ |
| Lemma 3.1 | (a) $\lvert h\rvert\le1$ and Cauchy–Schwarz. (b) The constant coordinate cancels; Frobenius bounds operator norm; AM–GM over the $L$ terms. This sharpens paper.tex eq. `energy-lipschitz` (l. 475–476) by $L^{-L/2}$. | ✓ |
| Lemma 3.2 | Coercivity gives a minimizer. With $\theta=t/(4(F^*+t))$, $(1-\theta)(F^*+t)-(F^*+t/4)=t/2$. Monotonicity of $(1+u)^pe^{-(1-\theta)u/(2\sigma^2)}$ needs $p\le(1-\theta)/(2\sigma^2)$, which $\sigma^2\le3/(8p)$ implies. Gaussian integral $(2\pi\sigma^2/\theta)^{P/2}(\det\Gamma_N)^{-1/2}$. | ✓ |
| Cor. 3.3 | $p_\sigma>0$ via the ball. $\bar z-m=(p-1)m+\int_{\mathcal N^c}z$, with $\lvert z\rvert\le\sqrt\kappa\le\sqrt F$. Jensen for the conditional law on the compact set $\mathcal N_t$, with finite convex $\Phi$. | ✓ |
| Rem. 3.4 | Finite sample space: the minimum over finitely many thresholds. Compact inputs: $\lvert a^2-b^2\rvert=\lvert a-b\rvert\lvert a+b\rvert$, and uniform continuity of $(w,x)\mapsto z_w(x)$ on $(\{\kappa_N\le n/c\}+\bar B(0,1))\times[-1,1]^d$, give one $\delta$ for all $S$. The right side of (3.2) is increasing in $F^*\le n/c$. | ✓ |
| Lemma 4.1 | (a) within-atom orthogonality; (b) $F(w)\le\inf F+t\le F(w_0)+t$, cancel $W/c$; (c) projection onto $[-1,1]\ni\bar y_x$. | ✓ |
| Lemma 4.2 | $\mathbb E[(f-y)^2\mid x]=f^2+1$. Reverse Minkowski on $\mathcal S$, using $\sum_{\mathcal S}(g-\bar y)^2\le\Delta(g)$ since $k_x\ge1$. | ✓ |
| Lemma 4.3 | (a) $\mathbb E[\bar y_x^2\mid k_x]=1/k_x$. (b) McDiarmid with $c_i=2$ gives $e^{-u^2/(2n)}$. (c) Le Cam $d_{\rm TV}\le np^2$, test function in $[0,1]$. (d) series = integral; $\beta'=h-\beta\in[-1,1]$; every critical point is a strict local maximum, so it is unique. | ✓ |
| Thm 4.4 (i)–(iv) | $\sum r^2=Q\le\lvert\mathcal S\rvert\le\min\{n,M\}=s$. $N_0$ is deterministic, so one event $\mathcal E$ (a function of $S$ only) serves every $N\ge N_0$. $M\epsilon=c(K_{\rm mem}+t)+na^2$. Monotonicity in $Q$. (iii): $\Delta$ is convex in $(f(x))_{x\in\mathcal S}$; $\lvert\mathcal S\rvert\le M$. (iv): if $\varsigma_\sigma\le\epsilon'/2$ then $(\alpha)_+^2-(\alpha-\varsigma)_+^2\le2\varsigma$ for $\alpha\le1$. | ✓ |
| Cor. 4.5 | (4.4) implies $c_d=o(2^d)$, hence $a_d\le1$ for large $d$. $N_0\le44.4\,d(d+1)2^{5d/3}+1$. $\alpha_d\le1.5\log(d+1)$. Each term of $\bar\epsilon_d$ tends to $0$, for any fixed $t$. Poisson limit; $\beta$ is 1-Lipschitz. (4.4) is equivalent to $c_d=o(n^{1-1/H}d^{-1/H})$. | ✓ |
| Cor. 4.6 | Bias–variance. $\mathbb E[Q_\eta\mid{\rm inputs}]=\sum_{\mathcal S}V/k\ge v_0\sum1/k$. Each term in $[0,4]$, differences $\le8$, so McDiarmid gives $e^{-u^2/(32n)}$. | ✓\* (issue 9) |
| §5.1 (P$_L$), (R1)–(R3) | (P$_L$) matches brief §1, including "every learner width $N\ge m$". The (R1) quotes match paper.tex l. 194–196 and slt-likelihood l. 61 in substance. Letting $\sigma_0$ depend on more parameters weakens (P$_L$), so refuting it is the stronger result. Weak limits of $\Pi_\sigma$ are carried by $\arg\min F$ (portmanteau on the open sets $\{F>F^*+t\}$). | ✓ |
| Prop. 5.1 | $2^d\ge q(d)$ eventually. R1: $\Pr\le\Pr(\mathcal E^c)+\sup_{S\in\mathcal E}\Pi(\mathcal N_t^c)$, both terms below $\frac{1-\delta}2$, the first strictly. R2: margin $\gamma/2$. R3: the event lies in $\mathcal E^c$, so its outer probability is small. | ✓\* (issue 5) |
| Prop. 5.2 | $F(0)=(\Delta_0+W)/c$. On $\{k_{\min}\ge1\}$, $\mathcal S=\mathcal C_d$ and Minkowski applies. Gibbs tail by Lemma 3.2 with $p=1$. Posterior means by Jensen on $v\mapsto\sum v_x^2$. $\mathbb E[k\bar y^2\mid k]=1$ and Markov. Chernoff $\Pr[{\rm Bin}\le np/2]\le e^{-np/8}$. $U_S\le(8M/\delta'+4ct)/n$. | ✓ |
| Prop. 6.1 (a), (a′), (b) | $k_x\in\{0,1\}$, so $W=0$ and $Q=n$. (a′): $\lVert f\rVert\le\sqrt M+\sqrt{\Delta(f)}$; Gibbs tail by Lemma 3.2, $p=1$; means via Jensen and (3.3). (b) Hoeffding on $[0,4]$ gives $e^{-u^2/(8n)}$. | ✓\* (issues 4, 9, 14) |
| Lemma 6.2 and the finite-scale remark | $\{\kappa<r_U\}\subseteq U$. $\kappa_N\sim\sigma^2\chi^2_P$. $\lvert L_D(z)-L_D(0)\rvert\le\kappa+2\sqrt\kappa$. Finite scale: $\mathbb E[z^2\mid{\rm hidden}]\le N^{-\gamma}$ (slt-likelihood l. 197–202, confirmed); union bound; Fubini. | ✓ |
| Prop. 6.3 | $\max\lvert y_i\rvert<\rho$ in both cases. Width-one constant network: $\tanh(2\tanh1)=0.909>\tanh1$, so $\tau_H\ge\tanh1$ and $\lvert v\rvert\le1.313$; weights $\le2$. | ✓ |
| Lemma 6.4 | (a) triangle inequality. (b) Conditioning on the first half; independence of later samples; McDiarmid for $\lvert S_1\rvert$; $1-e^{-u}\ge(1-e^{-1})u$ on $[0,1]$; $n_1n_2\ge n(n-1)/4$; constants $0.0395$ and $0.1998$. | ✓ |
| Prop. 6.5 | Feasibility via Lemma 2.1 at accuracy $\rho/2<1/2$. Every draw lies in the open interval, so the mean lies in the closed one. Clip: $u-\eta\ge b-\rho>0$ and $1-\eta\ge b$. | ✓\* (issue 3) |
| Prop. 6.6 | (a) $\{\kappa_N<(\rho-1)^2\}\subseteq U$ for every sample, so $k_\sigma$ is uniform over samples. Markov, using $\lvert L(f)-L(0)\rvert\ge\eta_0^2-\varepsilon$ on the success event. (b) $\mathbb Eu^{k_e}=(1-\frac{1-u}M)^n$; inclusion–exclusion with $k_e=0$; $p\ge1-p$. Consequence: the $n$-threshold does not involve $\mathsf p$. | ✓\* (issue 2) |
| Lemma 7.1 | Disjoint corner cubes; density $(Mr^d)^{-1}$; $(p_i,y_i)\sim D_d$; pairing $\upsilon\leftrightarrow\upsilon+\frac12e_1$ gives $\lvert\mathbb E[gy\mid p]\rvert\le\Lambda r/4$; $\Lambda\le B^Lm^H\sqrt d$ from the input columns. | ✓ |
| Thm 7.2 | $K_2\ge K_{\rm mem}\ge\frac92(H+1)>L$, so $r<1/n$. The energy level $K_2$ comes from comparison with $w=0$, before near-constancy is used, so there is no circularity. Step 4: $\sqrt{u+v^2}\le\sqrt u+v$, then $\Delta(\zeta)\le2E\sqrt W+E^2$. Piecewise-constant risk $1+\frac1M\sum\zeta_p^2$. (iii): $\lvert\bar z(x)-m_\sigma(p)\rvert\le\varsigma_\sigma+\frac1n$. $\Phi'$ is monotone and $\underline e'$ is deterministic. | ✓ |
| Prop. 7.4 | $\Gamma(y+1)\ge(y/e)^y$. $2\pi e\rho_{\rm tr}^2/d=8\pi e(L/K')^L$. $K_2/L\ge(8d2^d)^{1/H}\ge2^{d/H}$ for every $c$. $\frac12\log_2(8\pi e)=3.047$. | ✓ |
| Rem. 7.5, 7.6 | 7.6: $(\kappa/L)^{L/2}r>2-2\rho$, so $\kappa>(2-2\rho)^{2/L}n^{2/L}K_2$. 7.5 is an interpretation of Prop. 7.4. | ✓\* (issue 11) |
| Lemma 8.1 | $\mathbb E\,{\rm sign}(u-T)=\tanh u$. Sauer–Shelah on the distinct sample points of $\mathcal C_d$ gives $\log J\le(d+1)^2\log2$. Massart. One-sided contraction without $\phi(0)=0$, since the shift has mean zero. Clip-mixture identity re-derived by parts; it matches note eq. (13). Path-norm induction (the mixture weights do not depend on $u$, so the identity holds vectorwise). $\varpi\le(\kappa/H)^{H/2}$. | ✓ |
| Prop. 8.2 | (a) $\varepsilon_if(x_i)\ge1-a$. (b) Polarization; $\sup\ge0$ via the zero network. | ✓ |
| Prop. 8.3 | $c\kappa+\sum z_i^2\le ct+2\Phi$. McDiarmid in $y$ with differences $2\sqrt{K_0}$. Symmetrization and contraction with Lipschitz constant $2\sqrt{K_0}$. McDiarmid in $x$ with differences $K_0/n$. Union bound. The $c\ge C_tn$ remark: energy $(d+H)\epsilon_0^2$ (checked). | ✓\* (issues 1, 10) |

---

## 3. Round-0 logic issues: status in A.r1

| Round-0 issue | Where it is fixed in A.r1 | Fixed |
|---|---|---|
| 1. $o(1)$ reading needs uniformity in $d$ | §5.3 item 2 (l. 542), §0.1 | yes |
| 2. progressive mixture excluded | §0.2 item 4, §5.1 (l. 474), §10 item 7 | yes |
| 3. above-threshold claims need $c=o(n)$ | §0.2 item 8, §5.3 item 5, §8.3 statement and $C_t$ remark | yes |
| 4. "$=$" vs "$\le$", large $d$ in Cor. 4.5 | Cor. 4.5 statement and proof | yes |
| 5. $t$ arbitrary | Cor. 4.5 ("any fixed $t>0$"), Prop. 5.1 fixes $t$ | yes |
| 6. "tends to 2" upper bound | Prop. 6.1(a′) | yes |
| 7. Remark 7.3 overstatement | Rem. 7.3 | yes |
| 8. unproved §5.2 item 1 | §5.3 item 1 and Prop. 5.2 | yes |
| 9. repository thresholds | (R1), l. 470, quotes both sources correctly | yes |
| 10. Prop. 8.2(a)/(b) conflation | §0.2 item 8 | yes |
| 11. "undefined" as failure | (U1)/(U2) and Prop. 6.6 | yes |
| 12. finite-scale TUBE overstated | remark after Lemma 6.2, §10 item 6 | yes, but see issue 3 |
| 13. $\Pi_\sigma(\mathcal N_t)>0$ | Cor. 3.3 | yes |
| 14. nearest-neighbour remark | after Lemma 4.3 | yes |
| 15. outer probability | (R3) and Prop. 5.1 | yes |
| 16. deterministic $\underline e'$ | Thm 7.2 | yes |

---

## 4. Issues

All issues are **minor**. They concern summaries, remarks and cross-references, not proofs. They are ordered by how much they could mislead a reader.

### Issue 1: two sentences contradict Proposition 8.3(b)

**Location.** §8.3, last paragraph (l. 968): "Proposition 8.3 controls only the outputs on seen atoms. By itself it does not bound the test excess, which also depends on the outputs on unseen atoms." Also §10 item 8 (l. 1042): "Proposition 8.3 alone controls only the seen atoms."

**Problem.** Proposition 8.3(b) bounds $L_{D_d}(z_w)-1=\mathbb E_{x\sim{\rm Unif}(\mathcal C_d)}z_w(x)^2$. That is the full test excess, unseen atoms included, obtained by uniform convergence of the truncated square. Its right side tends to $0$ when $\vartheta<1/(H+1)$, which is the range stated just after the proposition (l. 930). Only part (a) is restricted to seen atoms. As written, the text contradicts its own proposition and understates what is proved. Part (b) matches ../research-notes/B-tempered-likelihood.md Theorem 6.4's unclipped range $\theta<1/L$ on this example.

**Fix.** "Proposition 8.3(a) controls only the outputs on seen atoms. Proposition 8.3(b) bounds the test excess of unclipped near-minimizers on the cube example when $\vartheta<1/(H+1)$, matching ../research-notes/B-tempered-likelihood.md Theorem 6.4's range $\theta<1/L$. Neither part covers $1/(H+1)\le\vartheta<1/H$ for the full test excess." Make the same change in §10 item 8.

### Issue 2: "every tolerance schedule" drops the strong-prior restriction for $\rho>1$

**Location.** §0.2 item 6, last bullet (l. 46): "TUBE$_\rho$ violates (P$_L$) for every schedule $\rho(n)$, under either convention, at every depth and width, already at a fixed input dimension." The same holds for the closing sentence of the consequence of Proposition 6.6 (l. 672).

**Problem.** For $\rho(n)>1$, Proposition 6.6 uses part (a), which is about the strong prior $\mu_\sigma$ as $\sigma\to0$. For the finite-scale prior $\mu_{N,\gamma}$ at a fixed width, nothing is proved when $\rho>1$: the collapse there is shown only as $N\to\infty$ (remark after Lemma 6.2). So "every schedule" holds for strong-prior TUBE, or for any prior along schedules with $\rho(n)\le1$ eventually. §0.1 and §10 say this correctly; §0.2 item 6 does not.

**Fix.** Add "(for the strong-prior TUBE; for any prior when $\rho(n)\le1$)" to §0.2 item 6, and "in the strong-prior limit" to l. 672.

### Issue 3: Proposition 6.5 is cited as holding "at every width", but it assumes $N\ge N_0(d,n,\rho/2)$

**Location.** Remark after Lemma 6.2 (l. 607): "The TUBE statements that hold for every prior, at every scale and width, are Lemma 6.4(a), Proposition 6.5 and Proposition 6.6(b)." The same appears in §10 item 6 (l. 1040). §0.2 item 6, third bullet (l. 45), omits both the width hypothesis and $\rho<b$.

**Problem.** Proposition 6.5 assumes $N\ge N_0(d,n,\rho/2)$, and that is what makes the tube nonempty. Below $N_0$ the tube may be empty, and then the posterior is undefined. The lower bound does hold for every draw at any width where the tube is nonempty, so the claim is true only in that conditional form.

**Fix.** Write "at every scale, and at every width at which the tube is nonempty (in particular every $N\ge N_0(d,n,\rho/2)$)". In §0.2 item 6, add "for $\rho<b$ and $N\ge N_0(d,n,\rho/2)$".

### Issue 4: the without-replacement summary drops its hypotheses

**Location.** §0.2 item 6, first bullet (l. 42): "the excess is at least $\frac nM(1-o(1))$ with probability one."

**Problem.** Proposition 6.1(a) gives $\frac nM(1-\sqrt{\epsilon'})_+^2$ with $\epsilon'=c(K_{\rm mem}(d,n,a,H)+t)/n+a^2$, at widths $N\ge N_0(d,n,a)$. The factor is $1-o(1)$ only if $a\to0$ and $c\,K_{\rm mem}(d,n,a,H)=o(n)$. That fails for small $n$: $K_{\rm mem}\ge d(d+1)\alpha_d^2$, so $\epsilon'\ge1$ whenever $n\le c\,d(d+1)\alpha_d^2$, and the bound is then vacuous. The asymptotic regime is not stated either.

**Fix.** "…at least $\frac nM(1-\sqrt{\epsilon'})_+^2$, which is $\frac nM(1-o(1))$ when $a\to0$ and $cK_{\rm mem}(d,n,a,H)=o(n)$, at widths $N\ge N_0(d,n,a)$."

### Issue 5: the $\sigma$-threshold in Proposition 5.1 also depends on $\varepsilon$

**Location.** Proposition 5.1, last sentence of the statement (l. 476): "for every $\epsilon'>0$ it is at most $e^{-2^{d/2}}+\epsilon'$ once $\sigma$ is below a threshold depending on $(d,N,c,t,\epsilon')$". The same holds for the proof's conclusion (l. 487).

**Problem.** For (R2) the output is deterministic given $S$. The bound $\Pr\le\Pr(\mathcal E^c)$ needs $L(f_\sigma)>1+\varepsilon$ on $\mathcal E$, that is, $\sigma$ small enough that $\varsigma_\sigma$ is below a function of the gap $\underline e_d-\varepsilon$. The proof uses $\epsilon'=\gamma/2$ with $\gamma=(\beta(1)-\varepsilon)/2$. So the threshold depends on $\varepsilon$ (and on $H$). No threshold independent of $\varepsilon$ gives $e^{-2^{d/2}}+\epsilon'$ for every $\varepsilon<\beta(1)$ under (R2). The refutation is unaffected, because (R1) allows $\sigma_0$ to depend on $\varepsilon$.

**Fix.** Write "a threshold depending on $(d,H,N,c,t,\varepsilon,\epsilon')$", or state the (R1) and (R2) bounds separately.

### Issue 6: the citation of `../research-notes/red-team.md` Proposition 6.1 is out of date

**Location.** §5.3 item 3 (l. 543) and §10 item 5 (l. 1039): "argues a positive oracle inequality for $c=1$ at learner width $\lceil n^\alpha\rceil$ with $\alpha<1/4$."

**Problem.** `RT-width-logic.md` (verdict: major flaw, repairable) finds three problems with this proposition:

* its display yields a polynomially small excess only for $\alpha<1/8$, because the competitor's Hoeffding term $(U+1)^2\sqrt{\ln(4/\delta)/(2n)}=\Theta(n^{4\alpha-1/2})$ is dropped;
* $\alpha<1/4$ needs a Bernstein repair, with a slower rate;
* it covers only clipped predictions and $N=o(\sqrt{n/\log n})$.

A.r1 does flag the proposition as unchecked. But it still repeats the $\alpha<1/4$ claim, and it reads as covering the unclipped learner.

**Fix.** "…`../research-notes/red-team.md` Proposition 6.1 argues a positive oracle inequality for clipped predictions of SP$_1$ at learner width $\lceil n^\alpha\rceil$; as written it gives $\alpha<1/8$, and $\alpha<1/4$ after the Bernstein repair of `RT-width-logic.md`."

### Issue 7: the summary of ../research-notes/B-tempered-likelihood.md Theorem 6.3 overstates the Gibbs and posterior-mean statements

**Location.** §5.4, first bullet (l. 553): "the near-minimizers, the Gibbs draw and the posterior mean of the clipped outputs have $L_D\le L_D(g)+\varepsilon$ with probability at least $1-\delta$".

**Problem.** ../research-notes/B-tempered-likelihood.md Proposition 6.1 (statements 2–4) and the remark after it give the following on an event of probability $\ge1-\delta$:

* the bad posterior mass tends to $0$;
* the Gibbs risk and the posterior-mean risk satisfy $\limsup_{\sigma\to0}\le L_D(g)+\mathrm{Exc}$;
* uniformly, the bad posterior mass is at most $\eta$ for $\sigma<\sigma_0(\eta)$.

So for a Gibbs draw, the probability over the sample and the draw is at least $1-\delta-\eta$ for small $\sigma$. It is not "at least $1-\delta$". The posterior-mean statement holds in the limit $\sigma\to0$. This does not affect the conclusion that ../research-notes/B-tempered-likelihood.md establishes (P$_L$) under (R1)–(R2), after renaming $\delta$.

**Fix.** Add "in the limit $\sigma\to0$ (for a Gibbs draw: probability at least $1-\delta-\eta$ for $\sigma$ below a threshold depending on $\eta$)".

### Issue 8: the "$n^\alpha$" reading is refuted only at learner widths $N\ge N_0$

**Location.** §5.3 item 2 (l. 542): "That reading is refuted for every $\alpha>0$ provided the $o(1)$ term is uniform…".

**Problem.** The refutation uses learner widths $N\ge N_0={\rm poly}(n)$, with $N_0/n\ge2\cdot10^5$ in the tabulated range. A reading that ties the learner width to $n^\alpha$, as `../research-notes/red-team.md` Proposition 6.1 does, is not refuted. Item 3 says this, but item 2 states the refutation without the qualifier.

**Fix.** Add "(at learner widths $N\ge N_0$; see item 3)".

### Issue 9: Corollary 4.6 and Proposition 6.1(b) use (iv) with possibly continuous labels

**Location.** Corollary 4.6 (l. 415, "all conclusions of Theorem 4.4 hold"), and Proposition 6.1(b) (l. 575).

**Problem.** Theorem 4.4(iv) is proved by Remark 3.4's finite-sample-space case, since there are $(2M)^n$ samples. In Corollary 4.6 the labels may take any values in $[-1,1]$, so the sample space need not be finite. The conclusion still holds, by Remark 3.4's compact-inputs case: the inputs lie in $\mathcal C_d$ and the labels in $[-1,1]$. But the proof says only "the posterior-mean argument is identical".

**Fix.** Add one clause: "(iv) follows from the compact-inputs case of Remark 3.4."

### Issue 10: "seen-atom excess $\to\beta(\lambda)$" is not proved as stated

**Location.** §8.3, "The threshold, sharply", first bullet (l. 962).

**Problem.** Theorem 4.4 proves only the lower bound $\frac1M\sum_{\mathcal S}z_w^2\ge(\sqrt{Q/M}-\sqrt\epsilon)_+^2$. Convergence also needs two further facts:

* the upper bound $\frac1M\sum_{\mathcal S}z_w^2\le(\sqrt{Q/M}+\sqrt\epsilon)^2$, which is the same Minkowski step as Lemma 4.2(b);
* the upper tail of $Q$; Lemma 4.3(b) gives only the lower tail, but McDiarmid is two-sided.

Each is one line, but neither is stated.

**Fix.** Add the two lines, or write "seen-atom excess at least $\beta(\lambda)-o(1)$".

### Issue 11: §10 lists Remark 7.5's interpretive claims as "proved"

**Location.** §10, "Proved", item on Proposition 7.4 and Remarks 7.5–7.6 (l. 1030). Also §0.1, second bullet.

**Problem.** Proposition 7.4 and the inequality in Remark 7.6 are proved. Remark 7.5's conclusions are statements about a proof technique, with "certify" undefined: "the link … certifies no excess at $x$", and "the argument therefore needs a density ratio $K\ge2^{(L/(2H))d^2-O(d)}$". They are sound as heuristics. The remark itself says the transfer is "at the energy level $K_2$", which is honest. They are not theorems.

**Fix.** In §10, list "Proposition 7.4 and the energy floor of Remark 7.6" as proved, and call Remark 7.5 an interpretation of Proposition 7.4.

**Optional.** The $2^{\Theta(d^2)}$ threshold looks robust beyond the level $K_2$. Proposition 8.2(b) suggests that a near-minimizer fitting most label patterns on $s\approx(1-e^{-\lambda})M$ seen atoms has energy at least about $H(s/D_{d,H}^2)^{1/H}$. Its Lipschitz-transfer radius therefore cannot exceed $\rho_{\rm tr}$ at that level, and the exponent stays $\frac L{2H}d^2-O(d\log d)$. I have not checked this in detail.

### Issue 12: causal framing of "what breaks the property"

**Location.** §0.1 (l. 16): "Conditioning tight enough to push the training MSE well below the noise level is what breaks the property (Theorem 4.4)". The same framing appears in §5.4 "The heuristic" (l. 559).

**Problem.** Theorem 4.4 proves failure on a law whose test inputs repeat the training inputs, and A′ on a law that is near-atomic at the learner's resolution. A training MSE below the noise level is not shown to be harmful in general. The document itself lists bounded-density inputs with noisy labels as open (§7.3, §10 item 3), and there interpolation could be benign. The sentence attributes the failure to the training MSE alone.

**Fix.** "On laws whose test inputs (nearly) repeat training inputs at the learner's resolution, conditioning tight enough to push the training MSE well below the noise level breaks the property (Theorem 4.4, Theorem 7.2); whether it does on bounded-density laws is open."

### Issue 13: a numeric range

**Location.** §0.2 item 3 (l. 37) and §5.3 item 3 (l. 543): "$N_0/n$ … between $2\cdot10^5$ and $7\cdot10^6$".

**Problem.** At $(d,a)=(40,0.1)$, $N_0/n=64\log2\cdot d(d+1)/a^2=7.27\cdot10^6$ (`checks.out` item 1). That is above $7\cdot10^6$. Remark 4.7 itself says $7.3\cdot10^6$.

**Fix.** Write "$7.3\cdot10^6$".

### Issue 14: limit order left implicit in Proposition 6.1(a′)

**Location.** Proposition 6.1(a′), last sentence (l. 574): "the test MSE tends to $2$".

**Problem.** For the Gibbs draw and the posterior means, the statement is: $\sigma\to0$ at fixed $(d,N,S)$, with $N\ge N_0(d,M,a_d)$ for each $d$, and then $d\to\infty$. The order is the same as in Corollary 4.5, but here it is not written out.

**Fix.** State the order: "$\lim_{d\to\infty}\liminf_{\sigma\to0}$ and $\lim_{d\to\infty}\limsup_{\sigma\to0}$, at widths $N\ge N_0(d,M,a_d)$".

### Issue 15: the (P$_L$) refutation via A′ is asserted but not stated

**Location.** §7 introduction (l. 713): "A′ is therefore a counterexample to (P$_L$)".

**Problem.** The argument of Proposition 5.1 transfers verbatim. It uses Theorem 7.2(i)–(iv), the deterministic $\underline e'\to\beta(1)$, and the competitor $g\equiv0$ with $L_{D'}(0)=1$. The law depends on $n$, which is allowed, because (P$_L$) must hold at every $n\ge\mathsf p$ for a fixed $D$. But no statement records this.

**Fix.** Add a one-line corollary after Theorem 7.2: "Proposition 5.1 holds with $D_d$ replaced by $D'_{d,r(2^d)}$ (same proof, using Theorem 7.2(iv))."

### Issue 16: overloaded symbols (presentation)

Several symbols carry two or three meanings:

* $B$ is the weight bound, and also the residual budget in Lemma 4.2(b).
* $\delta$ is the confidence, and also the ball radius in Lemma 3.2 and Remark 3.4.
* $p$ is the moment power (Lemma 3.2), a vertex (§7) and a Bernoulli parameter (Proposition 6.6).
* $\rho$ is the tolerance, and also the path weights $\rho^\ell_j$ (Lemma 8.1).
* $m$ is the feature count (Lemma 2.1), the competitor width, and the sample size (Lemma 8.1).
* $\gamma$ is the prior exponent, and also the margin in the proof of Proposition 5.1.
* $E$ is expectation, and also a quantity in Theorem 7.2.

None causes an error, but a research note should disambiguate them, as the revision already did for $\varpi$.

---

## 5. Points examined and found sound

These are objections a reader might raise. I checked each and found no problem.

1. **Quantifier order of the refutation.** In (P$_L$) everything except $\mathsf p$ (and $\sigma_0$ under R1) is universally quantified. So the counterexample $(d,\,D_d,\,g\equiv0,\,N\ge N_0,\,\varepsilon,\,\delta,\,n=2^d)$ may be chosen after $\mathsf p$. Uniformity over $d$ is exactly what brief §1 and `NNG/README.md` main result 1 ("polynomial in input dimension", l. 33) ask for. Proposition 5.2 correctly shows that the cube family alone cannot refute a fixed-$d$ version.
2. **One event for all widths.** $N_0(d,s,a)$ does not depend on the sample, and $\mathcal E$ is a function of $S$ only. So "simultaneously for every $N\ge N_0$" is legitimate.
3. **No measurability needed for the comparator.** Lemma 4.1(b) compares with a sample-dependent $w_0$ pointwise. No selection is integrated.
4. **(R1) leniency direction.** Letting $\sigma_0$ depend on $(d,n,N,D,g,\varepsilon,\delta)$ weakens (P$_L$), so refuting it is the stronger statement. The quotes from paper.tex Theorem `strong` ("does not depend on $D,n,\delta$") and slt-likelihood §2 ("may depend on the selected $n,N$ … uniform over $D$") are accurate.
5. **Weak limits and MAP.** Lemma 3.2 gives $\Pi_\sigma(\{F>F^*+t\})\to0$ for each $t$. Portmanteau on these open sets puts every weak limit on $\arg\min F\subseteq\mathcal N_t$. Tightness follows from the compactness of $\mathcal N_t$.
6. **Theorem 7.2 is not circular.** The energy bound $\kappa_N\le n/c+t$ comes from comparison with $w=0$ alone, and Step 2's near-constancy is derived from it. The tighter bound $\kappa\le K_{\rm mem}+t+O(na/c)$ would need near-constancy first, and the proof correctly does not use it.
7. **Thresholds and laws that depend on $n$.** In A′ the law depends on $n$. That is allowed: for a fixed law, (P$_L$) must hold at every $n\ge\mathsf p$, so one failing $n$ per $d$ suffices. In Proposition 6.6 the $n$-threshold $\frac{2M}{1-\eta_0}\log\frac2{1-\delta}$ does not involve $\mathsf p$, so the conclusion is in fact non-consistency at a fixed $d$, which is stronger than failure of (P$_L$).
8. **Proposition 6.6(b) counts "agreement" correctly.** $\Pr[\text{agree at }e]=\mathbb E[p^{k_e}+(1-p)^{k_e}]-\Pr[k_e=0]$. A conflict at one atom empties the tube for every prior, since $\lvert1-(-1)\rvert=2\ge2\rho$.
9. **(U2) fallback.** The prior mean of $z_w$ is $0$ for both priors, because $v$ is centred and independent of the hidden layers.
10. **Consistency with sibling and red-team results.** These were checked against their sources:
    * A's failure for $c=o(n^{1-1/H}d^{-1/H})$ and ../research-notes/B-tempered-likelihood.md Theorem 6.3's success for $c=n^{1-\theta}$, $\theta<1/H$, concern disjoint ranges of $c$.
    * `../research-notes/red-team.md` Proposition 4.1 (hard tolerance matched to a sup-norm residual) gives only a $(\tau+\rho_0)^2$-type bound, not (P$_L$). It does not conflict with Proposition 6.6, and `RT-tube-logic.md` agrees.
    * ../research-notes/E-finite-prior-scale.md Theorem 2.7's thresholds, ../research-notes/B-tempered-likelihood.md Corollaries 8.1 and 9.3, and the B/E referee verdicts are quoted correctly.
11. **Lemma 8.1 with repeated points.** The halfspace count is over the distinct points of $\mathcal C_d$, so repetitions in $x_1,\dots,x_m$ do not change $J$. Every quantity is a finite-dimensional supremum on a finite sample space, so there is no measurability issue in Proposition 8.3.
12. **Appendix R.** Its summary ("none of the three reports found a false theorem") agrees with the verdict lines of `A-first-version-logic.md`, `A-first-version-scope.md` and `A-first-version-computation.md` (all `minor_fixes`).

---

## 6. Sanity checks

`verify_A_r1_logic_scripts/checks.py` (output in `checks.out`):

1. $N_0/n=64\log2\cdot d(d+1)/a^2$ at $\lambda=1$: from $1.86\cdot10^6$ to $7.27\cdot10^6$ at $a=0.1$, and from $2.07\cdot10^5$ to $8.08\cdot10^5$ at $a=0.3$, for $d\in[20,40]$. This is the basis of issue 13.
2. $\tanh(2\tanh1)=0.9093>\tanh1=0.7616$, and $1/\tanh1=1.313$ (Proposition 6.3).
3. Lemma 6.4(b) constants: $(1-e^{-1})/16=0.0395$ and $(1-e^{-1})^2/2=0.1998$.
4. $\frac12\log_2(8\pi e)=3.047$ (Proposition 7.4(c)).
5. Proposition 6.6(b): in exact rational arithmetic, the one-atom agreement probability lies below $2e^{-n(1-\eta_0)/(2M)}$ in all 27 cases with $d\le3$, $\eta_0\in\{\frac14,\frac12,\frac9{10}\}$ and $n\in\{4,16,64\}$.
6. The constant network of the §8.3 remark has energy $(d+H)\epsilon_0^2$, as claimed.
7. Monte Carlo of $\Pr[U_{\rho\le1,S}\neq\emptyset]$ under $D^{\eta_0}_d$ ($2\cdot10^4$ trials): $0.0000$ against bounds $0.27$ and $0.10$.

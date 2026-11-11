# Referee report, round 1 on the revision (logic and definitions): `../research-notes/depth-two.md` — Theorem 5.1, Corollary 5.2, Proposition 5.3

**Lens.** I checked every quantifier and the limit order: $\sigma\downarrow0$ comes after $n$, the sample and the width are fixed. I also checked the case splits and the definitions against `../research-notes/problem-brief.md` and the cited sources. I looked for circularity, misapplied lemmas, and missing hypotheses (widths, weight bounds, clipping, measurability, existence of minimizers, label range). I also looked for steps that silently assume what they prove.

**What I read.**

- **Under review:** all of `../research-notes/depth-two.md`:
  - §0 (results, scope table, changes);
  - §1 (setting, predictors, statistics, formulations (P$_2$) and (P$_2^{o(1)}[\phi]$), readings (R1)–(R3));
  - §2 (Lemmas 1.0(1), 1.1, 1.2, 1.3, 2.1, with proofs);
  - §3 (Theorem 5.1 and its proof);
  - §4 (Corollary 5.2, its proof, and the numbers);
  - §5 (Proposition 5.3 and Remarks 5.4–5.8);
  - §6 (errata);
  - §§7–8 (numerical record, response to referees).
- **The red-team originals it replaces:** `../research-notes/red-team.md` §1 (Lemmas 1.0–1.3), §2.1 (Lemma 2.1), §2.3 A3, §5 and §6.1–6.4.
- **The previous reports:** `RT-depth2-logic.md` and `RT-depth2-computation.md`.
- **Sources, opened and compared:**
  - `NNG/side-results/continuous-domains/source/paper.tex`: §2 Model, including the strong-prior scales (eq. `strong-scales`), Theorem `strong`, Remark `cube` and its $\sigma_0$ quantifier; Lemma `posterior`; eq. `energy`; eq. `teacher-energy`; the proof of Theorem `strong`; Proposition `exact`; Corollary `exact`.
  - `NNG/works-in-progress/noisy-interpolation/README.md` §§2–3, eqs. (2)–(8).
  - `NNG/works-in-progress/slt-likelihood/README.md` §2: the likelihood variance $\sigma^2$, i.e. $c=1$; the remark on variance $c\sigma^2$; the $\sigma_0$ quantifier.
  - `../research-notes/A-tight-conditioning-fails.md`: §5.1 (P$_L$), (R1)–(R3), Proposition 5.2, §8.1–8.2 (Lemma 8.1, Proposition 8.2).
  - `../research-notes/B-tempered-likelihood.md`: Lemma 5.3, Proposition 6.1, Remark 6.5, §7.5, Corollary 8.1.
  - `../research-notes/small-learner-width.md` Theorem 1(c), and `RT-width-logic-revised.md`.

**Abbreviations.** `NNG/` is the project folder `neural-network-generalization/` of this repository, and "the note" is `../research-notes/depth-two.md`. Also $M=2^d$, $\vartheta_c=1/(18dc+1)$ and $F_d=1+(d+1)(d+2)^2$.

**Scripts.** They are in `../checks/verify-RT-depth2-logic-revised/`, each `.py` with a matching `.out` (§5). They were written from the note's definitions, independently of the author's scripts.

---

## Verdict: major flaw in the formulations claimed refuted; every proof and every displayed bound is correct

**The mathematics is correct.** I re-derived every step of the following and found no wrong or unjustified step, no circularity and no misapplied lemma:

- Lemmas 1.0(1), 1.1, 1.2, 1.3 and 2.1;
- Theorem 5.1, parts 1–3;
- Corollary 5.2 (i)–(iv) and its consequence (a);
- Proposition 5.3, parts 1–2.

The limit order is handled correctly. $\sigma_0$ depends only on $(d,n,c,N,\eta)$ and is uniform over samples, and the display of Theorem 5.1 is deterministic. Every number in §§1.3, 4 and 5 reproduces independently.

**The focus claims, in short:**

- **Theorem 5.1:** true. Partial memorization at depth two, with excess $\ge\gamma(\lambda)(18dc+1)^{-2}(1-o(1))$ for $c\le\mathrm{poly}(d)$, and $\gamma(1)=0.0998941$.
- **Corollary 5.2:**
  - It refutes the polynomial-sample inequality (P$_2$) for every $0<c\le\mathrm{poly}(d)$. This is true and meaningful.
  - The focus-question summary "**but not** the $+o(1)$ formulation" is **false** for $c\le\nu/\log_2n$. The note itself correctly states the three regimes, and the final note must cite those, not the summary.
- **Proposition 5.3:** true. With Hadamard atoms ($d=M$, inputs of norm $\sqrt d$), every $c=o(\sqrt M)$ gives excess $\ge\beta(\lambda)-o(1)$ on the event, at every width $N\ge1$. The width-1 case was checked explicitly.

**The major flaw is in what the note says is refuted.** These are definition and scope errors that a final note would copy.

1. **(P$_2^{o(1)}[\phi]$) as defined (§1.4) is false for every learner, for a trivial reason.** It requires the bound "for every learner width $N\ge1$", while the competitor class has width up to $n^\alpha$.
   - A width-1 depth-two network is monotone in $x$ when $d=1$. So it cannot fit a width-2 bump. Take $y=g^*(x)=\tfrac12[\tanh(1+2x)+\tanh(1-2x)]$ with $x$ uniform on $\{-1,0,1\}$. Every width-1 output has $L_D\ge0.0693$, while $\inf_{\mathcal G^{(\alpha)}_n}L_D=0$ (`width1_strawman.out`).
   - Hence "SP$_c$ fails (P$_2^{o(1)}$)" says nothing specific to close conditioning: the tempered learner of `../research-notes/B-tempered-likelihood.md` "fails" it too.
   - The note's own positive companion, `../research-notes/B-tempered-likelihood.md` Corollary 8.1, states the "$+o(1)$" property "simultaneously for all learner widths $N\ge n^\alpha$". The two documents therefore use incompatible definitions.
   - Under the literal definition, the §0.2 status "not refuted … open" for $c\log n\to\infty$ is false: that case is refuted trivially.
   - **Fix:** require "every learner width $N\ge\lceil n^\alpha\rceil$". The proofs go through unchanged.
2. **The "$o(1)$ uniform over $d\le n$" formulation (§0.2 row 3, the "What it refutes" bullet after Proposition 5.3) is false for every learner, information-theoretically.**
   - Take $d=n$, $x$ uniform on $\{e_1,\dots,e_n\}$ and $y=\theta_J$ at $x=e_J$.
   - The competitor $n^\alpha\tanh(n^{-\alpha}\theta\cdot x)$ lies in $\mathcal G^{(\alpha)}_n$ and has loss at most $n^{-4\alpha}/9$.
   - About $n/e$ coordinates are unseen, so every learner has loss bounded below by a constant for some $\theta$.
   - The same holds for unit-ball inputs, at every width and every $c$.
   - Consequences:
     - "Refuted for every $c=o(\sqrt n)$" is vacuous: every $c$, and every learner, fails.
     - "With unit-ball inputs, refuted only for $c<\sqrt{\beta(1)}/2$", in a column headed "Depth-two status", is false.
   - What Proposition 5.3 does show is that SP$_c$ is worse than the Bayes-optimal **zero network** by $\beta(\lambda)$, at every width. So it refutes "compete with the zero network or constants, up to $o(1)$, uniformly over $d\le n$". The trivial learner satisfies that property.
3. **The "open" range is overstated** (minor, but it affects the same table). For clipped predictors, `../research-notes/B-tempered-likelihood.md` Proposition 6.1 and Corollary 8.1 prove (P$_2^{o(1)}[\log_2n+C_0]$), with $N\ge n^\alpha$, whenever $\log^2n\ll c\le n^{1-\epsilon}$. Corollary 8.1 states it for $c=n^{(2-8\alpha)/3}$, and Proposition 6.1 gives the rest of the window.
   - So the open range is $1/\log n\ll c\lesssim\log^2n$ for clipped readings. Every fixed $c$, including $c=1$, lies in it.
   - For unclipped readings the open range runs up to about $\sqrt n\log n$.
   - The note's own Remark 5.7 and its erratum for RT §7 item 3 already say this. The §0.2 table, Remark 5.8 item 1 and the errata for RT §0 item 6 and §6.4 do not.

Issues 1–3 change no theorem. Each fix is a definition change or a rewording (§3), and §4 gives the corrected scope. The remaining issues (4–9) are minor.

### Answers to the focus questions

| Question | Answer |
|---|---|
| Energy of the depth-two memorizer (Lemma 2.1) | **Correct.** First layer: $\frac dN\sum_lk_l\lVert\omega_l\rVert^2\le dF_d$. Readout $tA_0/(m_0k_l)$ with $k_l\ge N/(2m_0)$ gives $N\sum_lk_l(tA_0/(m_0k_l))^2\le2t^2A_0^2=18dt^2\lVert r\rVert_2^2$, and the output is exactly $tg$. Built literally at $d=3,4$, at widths between $1.03m_0$ and $6.2m_0$, with $t\in\{1,0.37,0.05,\vartheta_c\}$: all checks pass (`lemma21_explicit.out`). |
| Bracket minimisation | **Correct.** $\min_t[\alpha t^2+(1-t)^2]=\alpha/(1+\alpha)$ at $t=1/(1+\alpha)$ (sympy). With $\alpha=18dc$ this is $t=\vartheta_c\in(0,1)$, value $1-\vartheta_c$. The extra term $nta$ is evaluated at $t=\vartheta_c$, which is legitimate because only an upper bound on $\min F$ is needed. |
| Limits | **Correct.** Lemma 1.1 is re-proved with an explicit, sample-uniform rate, and $\sigma_0=\sigma_0(d,n,c,N,\eta)$. Gibbs: $\mathbb E\Phi\ge\Pi(\mathcal N_1)\inf_{\mathcal N_1}\Phi$. Means: Jensen in the finite vector $(f(x))_{x\in T}$, with $\Phi=\mathcal R\le cF$, and $\Psi(\eta)\to\Psi$ by continuity. In Corollary 5.2, the worst-case functional $\underline\Psi_d$ coincides with Theorem 5.1's $\Psi$ evaluated at the corner of the event box, for every $20\le d\le1000$ (`event_bounds.out`). The limits (i)–(iv) are right. |
| Hadamard construction | **Correct, at every $N\ge1$.** $u\cdot\xi_l=\bar y_l\mathbf 1_T(l)$ and $\lVert u\rVert^2=Q/M$. Then $\kappa_N=\frac dN\cdot N\tau^2Q/M+N\cdot N(N\tau)^{-2}=\tau^2Q+\tau^{-2}$, using $d=M$, which equals $2\sqrt Q$. The error is at most $\tau^2\lvert\bar y\rvert^3/3\le\tau^2/3$, outputs off $T$ are 0, and $\mathcal R\le n/(9Q)$. Explicit matrices at $M\le1024$, $N\in\{1,2,5\}$ and $\lambda\in\{1,1.5\}$ show 0 failures; the largest error ratio is $0.9833$ (`hadamard_explicit.out`). |
| $\gamma(1)=0.0999$ and the $(18dc+1)^{-2}$ form | **Correct** for $c\le d^k$, with the $o(1)$ uniform over $c\in(0,d^k]$. $\gamma(1)=0.0998941$, and $\max\gamma=0.101816$ at $\lambda=1.256431$. |
| Cor. 5.2 "refutes (P$_2$) for $c\le\mathrm{poly}(d)$" | **Correct** under (R1)–(R3), and meaningful, since (P$_2$) is satisfiable (`../research-notes/B-tempered-likelihood.md` Thm 6.3). |
| Cor. 5.2 "but not the $+o(1)$ formulation" | **False as a summary.** For $c\le\nu/\log_2n$ the note proves failure of (P$_2^{o(1)}[\log_2n+C_0]$), with constant $\Gamma_\lambda(\nu)$, and $\beta(\lambda)$ if $c\log n\to0$. For $c\log n\to\infty$ Theorem 5.1 is silent. After the fix of issue 1 the "$+o(1)$" formulation is meaningful, and its refutation for small $c$ stands. |
| Prop. 5.3 "$c=o(\sqrt M)$ ⇒ excess $\ge\beta(\lambda)-o(1)$ at every $N\ge1$" | **Correct**, on the event, for inputs of norm $\sqrt d$; the rate claim holds with room (`event_bounds.out` (D)). What it refutes needs reframing (issue 2). |

---

## 1. Statements compared against the sources

| Item in the note | Source | Match? |
|---|---|---|
| Architecture at $L=2$: $z_w=\sum_jv_j\tanh(\omega_j\cdot\bar x)$, $\bar x=(1,x)$, no separate biases | `paper.tex` §2 (lines 114–125); BRIEF §2 | yes |
| $\kappa_N=\frac dN\lVert W^1\rVert_F^2+N\lVert v\rVert^2$ | `paper.tex` eq. `energy` at $L=2$ | yes |
| Prior density $\propto e^{-\kappa_N/(2\sigma^2)}$ | `paper.tex` eq. `strong-scales` with Gaussian coordinates (variances $\sigma^2N/d$ and $\sigma^2/N$); BRIEF §2 | yes |
| SP$_c$ posterior $\propto e^{-F_{c,S}/(2\sigma^2)}$, $F_{c,S}=\kappa_N+c^{-1}\sum_i(z_w(x_i)-y_i)^2$; $c=1$ is the clean-label scaling | BRIEF §2; slt-likelihood §2 (likelihood $\mathcal N(z_w,\sigma^2)$, objective $J_S$; "Observation variance $c\sigma^2$ … works too") | yes |
| Limit order: $S$, $n$, $N$ fixed, then $\sigma\downarrow0$; threshold may depend on $(n,N)$, uniform over $D$ | BRIEF §5; slt-likelihood §2 ("$\sigma_0$ may depend on the selected $n,N$ … uniform over $D$"); `paper.tex` Thm `strong` ($\sigma_0$ "does not depend on $D,n,\delta$") | yes. The note's $\sigma_0(d,n,c,N,\eta)$ is uniform over samples and over $D$. The reading (R1) lets $\sigma_0$ depend on $n$, which is more lenient than `paper.tex`, so the refutation is stronger. Fine. |
| Input domain $X\subseteq[-1,1]^d$ (or unit ball) | BRIEF §1–2; `paper.tex` §2 (unit ball) and Remark `cube` ($[-1,1]^d$) | yes. Prop. 5.3 needs norm $\sqrt d$; Remark 5.4 treats the unit ball correctly. |
| Labels in $[-1,1]$ | BRIEF §1 | fair signs. Used in $m_*\le n/c$ (Lemma 1.1), $\lvert r\rvert\le1$ (Lemma 2.1), clipping |
| Competitor: depth $L$, width $m$, weights $\le B$; learner width $N\ge m$ | BRIEF §1; `../research-notes/A-tight-conditioning-fails.md` §5.1 (P$_L$) | (P$_2$) matches. **(P$_2^{o(1)}$) uses $N\ge1$, which is not the analogue of $N\ge m$ (issue 1)** |
| "$+o(1)$" formulation | BRIEF §1 ("min over … width and weights $\le n^\alpha$, plus $o(1)$"); `../research-notes/B-tempered-likelihood.md` Corollary 8.1 ("simultaneously for all learner widths $N\ge n^\alpha$") | **mismatch in the width quantifier (issue 1)** |
| Parity representation, Fourier $\ell^1$, rows $\le F_d$ | noisy-interpolation README eqs. (2)–(4), "Sampling" | yes. The note re-proves them, with accuracy $a/2$ and $8A_0^2$ in place of $1/4$ and $32A_s^2$; Hoeffding is correct |
| Depth-two readout | README §3; `../research-notes/A-tight-conditioning-fails.md` Remark 2.5 | yes. The full width is used for the correction, giving $2t^2A_0^2$ |
| Lemma `posterior`, Prop. `exact`, Cor. `exact` | `paper.tex` §§3, 8 | not used. They concern clean labels; the note uses its own Lemma 1.1, which is the strong-prior Laplace estimate of the proof of Thm `strong` (BRIEF item 5) made explicit and uniform |
| Predictors | BRIEF §2 (Gibbs, posterior mean, progressive mixture) | Gibbs draws and risks; $\bar z_\sigma$, $\operatorname{clip}\bar z_\sigma$, $\bar f_\sigma$; near-minimisers. The progressive mixture is excluded explicitly (Remark 5.6). Correct |
| Fixed-$d$ consistency | `../research-notes/A-tight-conditioning-fails.md` Prop. 5.2 (every $H\ge1$, every width) | yes, with a constant to restore (issue 5) |
| Depth-two memorisation lower bound $\gtrsim s/d^2$ | `../research-notes/A-tight-conditioning-fails.md` Prop. 8.2(a) at $H=1$: $K\ge(1-a)^2s/D_{d,1}^2$ | yes |
| Small-width success (Remark 5.5) | `../research-notes/small-learner-width.md` Thm 1(c) (the original display, probability $\ge1-\delta/2$), refereed in `RT-width-logic-revised.md` | yes; the $L=2$ substitutions $U=1$, $E_*=d(d+1)+2$, $P_N=N(d+2)$ are right |
| Upper bound (Remark 5.7) | `../research-notes/B-tempered-likelihood.md` Prop. 6.1 ($K=n/c+1$) with Lemma 5.3(a) | yes: $c(d^2+d+3)/n+8D_n\sqrt{1/c+1/n}+8\sqrt{\ln(2/\delta)/(2n)}$, at every $N\ge1$ |

---

## 2. Step-by-step audit

### 2.1 Lemma 1.0(1)

$\lvert z_w\rvert\le\lVert v\rVert_1\le\sqrt N\lVert v\rVert_2\le\sqrt{\kappa_N}$. Also $\sqrt{\kappa_N}\le1+\kappa_N\le1+F$. ✓

### 2.2 Lemma 1.1 (strong-prior concentration, uniform in the sample)

- **(i)** $F\ge\lVert\Lambda w\rVert^2$, so $F$ is coercive and continuous, and its minimum is attained. $m_*\le F(0)=c^{-1}\sum y_i^2\le n/c$ uses $z_0\equiv0$ and $\lvert y_i\rvert\le1$. ✓
- **Pointwise bound.** $\sup_{t\ge0}(1+t)e^{-st}\le\max\{1,1/s\}$ with $s=\varrho/(2\sigma^2)$. In 200,000 random checks there were no violations; the largest ratio was $0.94$ (`constants_and_gamma.out` (7)). ✓
- **Split.** $(1-\varrho)F\ge(1-\varrho)^2(m_*+\zeta)+\varrho(1-\varrho)\kappa_N$ on $\{F>m_*+\zeta\}$, and the Gaussian integral gives $(2\pi\sigma^2/(\varrho(1-\varrho)))^{P/2}\det\Lambda^{-1}$. ✓
- **Choice of $\varrho$.** $m\mapsto(1-\varrho)^2(m+\zeta)-m-\zeta/2$ is decreasing, and $m_*\le n/c$, so a single $\varrho(n,c,\zeta)$ serves every sample. ✓
- **Denominator.**
  - $w_*\in\{\kappa_N\le n/c\}$. The ball $B(w_*,r_0)$ with $r_0\le1$ lies in the unit neighbourhood $K_1$ and is convex, so the mean-value bound applies along segments.
  - $\mathrm{Lip}_1$ is free of $S$ because the inputs lie in the fixed compact $X$ and $\lvert y_i\rvert\le1$. ✓
- **Ratio.** The exponent is $(1-\varrho)^2(m_*+\zeta)-(m_*+\zeta/4)\ge\zeta/4$, which gives $e^{-\zeta/(8\sigma^2)}$ times polynomial factors. These depend on $(d,X,N,n,c,\zeta)$ only. ✓
- **(iii)** The lower half is trivial for $\Phi\ge0$. The upper half: off $\mathcal N_\zeta$, $\Phi\le\max\{b_0,b_1\}(1+F)$. ✓
- **Integrability and existence of the means.** $\lvert z_w\rvert\le1+F$, and $\mathbb E_\Pi(1+F)<\infty$. ✓

No measurability is needed for (i)–(iii): $\epsilon_\sigma$ is a deterministic supremum.

### 2.3 Lemma 1.2

- **(1.1).** The cross term vanishes atom by atom. ✓
- **Clipping.** clip is the metric projection onto $[-1,1]\ni\bar y_x$. ✓
- **(a).** Triangle inequality in $\ell^2(T)$, with $k_x\ge1$. ✓
- **(b).** $\mathcal R=\sum_Tk_xf^2-2\sum_xfS_x+G$, so $B<G$ forces $\sum fS>0$, hence $V>0$, and Cauchy–Schwarz finishes. ✓
- **Numerical check.** Against the exact constrained minimum (KKT, $f_x=\mu k_x\bar y_x/(1+\mu k_x)$) on 4000 random instances, with fair-sign and uniform labels, there were 0 violations of (a), (b), (1.1) and clipping. Bound (b) is $0.69$ of the true minimum at the median and is tight at best (`lemma12_kkt.out`).

### 2.4 Lemma 1.3

- **McDiarmid.** The bounded differences are 2: $\phi(k)=\mathbf 1[k\ge1]/k$ changes by at most 1 per unit step, and two counts move. This gives $2e^{-n^{1/3}/2}$ each. ✓
- **Conditional moments.**
  - $\mathbb E[Q\mid x]=\Sigma_1$ and $\mathrm{Var}(Q\mid x)=\sum_T2(k-1)/k^3\le2n$;
  - $\mathbb E[G\mid x]=s$ and $\mathrm{Var}(G\mid x)\le2n$;
  - $\mathrm{Var}\,V=2n(n-1)/M$, since only paired terms survive. ✓
- **Chebyshev and the triangle inequality** give (1.2). ✓
- **Poisson comparison.**
  - Le Cam: $n/M^2=\lambda'/M$.
  - $d_{TV}(\mathrm{Poi}(\lambda'),\mathrm{Poi}(\lambda))\le1-e^{-(\lambda'-\lambda)}\le1/M$.
  - The test functions take values in $[0,1]$. ✓
- **Monte Carlo** ($n=M$, 2000 samples):

  | $d$ | frequency of $\mathcal E$ | guaranteed level $1-\rho_n$ |
  |---|---|---|
  | 8 | 0.925 | $-0.11$ |
  | 10 | 0.975 | 0.38 |
  | 12 | 0.996 | 0.62 |
  | 14 | 1.000 | 0.76 |

  The means of $Q,G,V$ match $M\beta_d$, $Mp_d$ and $n$ to $10^{-3}$ (`lemma13_mc.out`).
- **Hadamard atoms.** The lemma uses only "i.i.d. uniform on $M$ atoms, independent fair signs", so it applies verbatim. ✓

### 2.5 Lemma 2.1 (depth two)

- **Step 1.** Parseval and Cauchy–Schwarz over $M$ sets give $\sum_J\lvert\hat r(J)\rvert\le\lVert r\rVert_2$. ✓
- **Step 2.**
  - The odd-integer preactivations are right.
  - The sign coefficients are $\pm\binom{2m}m4^{-m}$. I re-derived the alternating-sum identity for both parities.
  - $u_m\ge1/(2\sqrt m)$ by the ratio $(2m-1)/(2m)\ge\sqrt{(m-1)/m}$, so $\lvert\mathfrak c_k\rvert\ge1/\sqrt{2k}$.
  - Slope: $1-\tanh\alpha_d<2e^{-2\alpha_d}\le1/(2\sqrt{2d})$, hence $\lvert\mathfrak c_{k,\alpha_d}\rvert\ge1/(2\sqrt{2k})$ for $k\le d$.
  - The sign-flip identity follows from the substitution $v_j=u_jx_j$.
  - Row norms are $\alpha_d^2(b_k^2+k)\le(d+2)^2(d+1)<F_d$; the empty set costs $1/\tanh1$; the total mass is at most $\max\{2\sqrt{2d},1/\tanh1\}\lVert r\rVert_2\le A_0$. ✓
- **Step 3.** Hoeffding at deviation $a/2$ with range $2A_0$ gives exponent $m_0a^2/(8A_0^2)$, and $m_0>8A_0^2\ln(2M)/a^2$, so the failure probability is below 1. ✓
- **Steps 4–5.** $\lfloor y\rfloor\ge y/2$ for $y\ge1$. The output is $tg$ and the readout energy is at most $2t^2A_0^2$. ✓ The function $g$ does not depend on $N$ or $t$. ✓
- **Explicit build** (`lemma21_explicit.out`):
  - setting: $d=3,4$; $a\in\{1,\tfrac12\}$; widths between $1.03m_0$ and $6.2m_0$;
  - the exact mixture reproduces $r$ to $10^{-12}$;
  - mass$/A_0\approx0.3$;
  - every check passes: $\sup\lvert g-r\rvert\le a/2$; output $=tg$; $\kappa_N\le dF_d+18dt^2Q$; $\mathcal R(tg)\le(1-t)^2G+nta$; the objective chain; and the Theorem 5.1 budget at $t=\vartheta_c$ for $c\in\{1,0.1,0.01\}$.

### 2.6 Theorem 5.1

1. **Width.** $A_0^2=9dQ$ and $Q\le n$, so $m_0\le N_0(a)$. $N_0$ depends on neither the sample nor $c$. ✓
2. **Residual of $tg$.** $(te-(1-t)\bar y)^2\le(1-t)^2\bar y^2+t(1-t)a\lvert\bar y\rvert+t^2a^2/4$. Summing gives at most $(1-t)^2G+nt[(1-t)a+ta^2/4]$, which is at most $(1-t)^2G+nta$ when $a\le4$. ✓
3. **Objective.** $cF-W=c\kappa_N+\mathcal R$ by (1.1), and $Q\le G$ points the right way. ✓
4. **Bracket.** See the focus table. ✓
5. **Part 1.** $cF(w)-W\le cF(w_{\vartheta_c})+c-W$ gives $\mathcal R(z_w)\le(1-\vartheta_c)G+c(dF_d+1)+\vartheta_cna=\mathcal R_{\max}$. Both networks have the same width $N$. ✓
6. **Part 2.** Lemma 1.2(a),(b) with $B=\mathcal R_{\max}$, and $G-B=\vartheta_cG-E_0$. The edge case $V=0$ forces $G=0$, so $\Psi_{\rm cor}=0$. ✓
7. **Part 3.**
   - $\epsilon_\sigma\le\eta\min\{1,1/c\}$ gives $\Pi(\mathcal N_1)\ge1-\eta$ and $\mathbb E\mathcal R\le\mathcal R_{\max}+c\epsilon_\sigma\le\mathcal R_{\max}+\eta$.
   - Jensen is applied in the finite vector, and $\mathcal R(\bar f_\sigma)\le\mathbb E\mathcal R(\operatorname{clip}z_w)\le\mathbb E\mathcal R(z_w)$.
   - $\Psi(\eta)\to\Psi$ by continuity.
   - The liminf conclusions follow. ✓

**No gap.** The display is deterministic; the event of Lemma 1.3 enters only in Corollary 5.2.

### 2.7 Corollary 5.2

- **The worst case on the event.** $\Psi_{\rm tri}$ increases in $Q$ and decreases in $G$; $\Psi_{\rm cor}$ increases in $G$ and decreases in $V$. Each variable is replaced by its bound separately, and that is legitimate because each enters monotonically. On the event, $V/M\le\lambda'+h_d/2$ and $V\ge n-n^{2/3}>0$.
  - I evaluated Theorem 5.1's $\Psi$ at the corner $(Q^-,G^+\text{ in }\mathcal R_{\max},G^-\text{ in }\Psi_{\rm cor},V^+)$. It equals the note's $\underline\Psi_d$ for every $20\le d\le1000$ (assertion in `event_bounds.py`).
- **(i)** $c(dF_d+1)/(M\vartheta_c)=c(18dc+1)(dF_d+1)/M$ is increasing in $c$, so its value at $c=d^k$ bounds it uniformly, and that value is $O(d^{2k+5}2^{-d})\to0$. The numerator is $\vartheta_c^2(1-e^{-\lambda})^2(1+o(1))$ and the denominator $4\lambda(1+o(1))$. ✓
- **(ii)** Four monotone substitutions are made: $\vartheta_c\ge\vartheta_\nu$; $1-\vartheta_c\le1-\vartheta_\nu$; $\vartheta_c\lambda'a\le\lambda'a$; $c(dF_d+1)\le\nu(F_d+1)$. The first needs $p_d-h_d-\lambda'a_d>0$, which holds for large $d$. The limits are right. ✓
- **(iii)** $\Gamma_\lambda$ is continuous and nonincreasing, with $\Gamma_\lambda(0)=\max\{\gamma,\beta\}=\beta$ by (1.0). ✓
- **(iv)** $\Psi_{\rm cor}\le\vartheta_c^2G^2/(4MV)\le\gamma(\lambda)\vartheta_c^2(1+o(1))\to0$ on the event. $\Psi_{\rm tri}=0$ eventually, because $(1-\vartheta_c)(p_d-h_d)\to1-e^{-\lambda}>\beta(\lambda)\ge\lim(\beta_d+h_d)$. ✓
- **(a)**
  - The zero competitor: width 1, weights $0\le B=1$.
  - $1/\varepsilon_d=3(18dc_d+1)^2/\gamma\le\mathrm{poly}(d)$, so $\lvert\mathsf p(\cdot)\rvert\le\mathrm{poly}(d)<\lceil\lambda2^d\rceil$ eventually.
  - (R3): the bad event lies in $\mathcal E_d^c$.
  - (R1): $\mathbb E_S\Pi_{\sigma,S}(\{L\le1+\varepsilon_d\})\le\rho_n+\eta<1-\delta$.
  - (R2): $\underline\Psi_d(\eta)>\varepsilon_d$ for small $\eta$.
  - The refuted property quantifies "for all $\sigma<\sigma_0'$", so taking $\sigma<\min\{\sigma_0,\sigma_0'\}$ suffices. ✓
  - The joint measurability that (R1) needs is not stated. It holds, because the posterior density is jointly continuous in $(S,w)$ and Tonelli applies (issue 8).
- **(b)**
  - Dimension range: $d\le\log_2n+\log_2(1/\lambda)$.
  - $dc_d\le\nu d/(d+\log_2\lambda)\to\nu$, so for every $\nu'>\nu$ part (ii) applies, and continuity of $\Gamma_\lambda$ gives $\Gamma_\lambda(\nu)$.
  - The zero network lies in $\mathcal G^{(\alpha)}_n$, so the infimum is 1.
  - Failure follows for every $\alpha$ and every $\epsilon_n\to0$. ✓
  - This step is logically correct, but the property it refutes is defective as defined (issue 1). After the fix the same proof works with $N\ge\max\{N_0(a_d),\lceil n^\alpha\rceil\}$, since $N_0(a_d)=O(n\log^4n)$.
- **(c)** Correct as a statement about Theorem 5.1. The surrounding "open" claims are overstated (issue 3).
- **Numbers.** $c=1$: the bound is 0 for $d\le29$; $1.93\cdot10^{-8}$ at $d=30$; at least $2\varepsilon_d$ for every $33\le d\le1000$ (minimum ratio $0.7185$ at $d=33$); maximum $2.258\cdot10^{-7}$ at $d=35$. The small-$c$ table reproduces to 4 decimals, as do $N_0(1/n)=5.746\cdot10^{31}$ and $N_0(1/d)=4.485\cdot10^{16}=4.18\cdot10^7n$ (`event_bounds.out`). The $\Gamma_1$ table, the crossing at $\nu=0.038994$ and the vanishing point $\nu=0.18287$ also reproduce (`constants_and_gamma.out`).

### 2.8 Proposition 5.3

- **Part 1.** The network, the energy at every $N\ge1$, the accuracy, the vanishing off $T$, $\mathcal R\le n/(9Q)$ and the budget $c\kappa_N+\mathcal R\le c\cdot2\sqrt Q+n/(9Q)$ for $c\in\{0.1,1,10\}$ all verify on explicit matrices (`hadamard_explicit.out`). The assumption $Q>0$ is now stated. ✓
- **Part 2, first bound.** $\mathcal R^{\rm H}_{\max}/M\le2\nu\sqrt{Q/M}+o(1)\to2\nu\sqrt\beta$, which gives $\beta(1-\sqrt{2\nu/\sqrt\beta})^2-o(1)$. ✓
- **Part 2, second bound.** $2\sqrt2cM^{-1/2}+c/M\le4cM^{-1/2}$, and $(\sqrt q-r)_+^2\ge q-2r$ for $q\le1$, with no violations in 200,000 checks. The rate $\beta-4\sqrt cM^{-1/4}-O(M^{-1/3})$ holds with room: the worst case on the event exceeds $\beta-4\sqrt cM^{-1/4}$ in every tested case (`event_bounds.out` (D)). ✓
- **Table.** $c=1$: $0.0931,0.2794,0.4157,0.4738,0.4830,0.4848$. $c=0.1\sqrt M$: $0.0155,0.0619,0.0930,0.1033,0.1043,0.1044$. Both reproduce. ✓
- **Gibbs and posterior means.** These follow from Lemma 1.1 on the finite set $X=\{\xi_j\}$. ✓
- **Remark "Polynomial-in-$d$ bounds".** Correct.
- **Remark "What it refutes".** The step is correct but the formulation is unsatisfiable for every learner (issue 2).

### 2.9 Remarks 5.4–5.8, §0.2, §6

- **Remark 5.4.**
  - Unit-ball cost: $\tau^2MQ+\tau^{-2}$, minimised at $2\sqrt{MQ}$. The accuracy is $\tau^2/3$, so $\mathcal R\le n/(9MQ)$ (explicit, `hadamard_explicit.out`).
  - The limits $0.334$ at $c=0.01$ and $0.104$ at $c=0.1$, and the threshold $0.348$, are right.
  - Theorem 5.1 under the unit ball: $\lVert(\omega_0,\sqrt d\omega_{1:d})\rVert^2\le d\lVert\omega\rVert^2$, giving $d^2F_d$. ✓
- **Remark 5.5.**
  - It cites the original display, which `../research-notes/small-learner-width.md` Theorem 1(c) re-proves with probability at least $1-\delta/2$. That display was refereed in `RT-width-logic-revised.md`.
  - The substitutions at $L=2$ are right, and $N=o(n/\log^2n)$ makes the bound vanish when $n^{-O(1)}\le c\le\mathrm{poly}(d)$. ✓
  - It is stated for clipped near-minimisers only. ✓
- **Remark 5.6.** ✓
- **Remark 5.7.**
  - The display matches `../research-notes/B-tempered-likelihood.md` Proposition 6.1 with $K=n/c+1$, Lemma 5.3(a) at $\delta'=\delta/2$, $E_*=d^2+d+2$, $U=1$ and $D_n=\sqrt{2(d+1)\ln(n+1)}$.
  - The window ($c\gg\log^2n$ and $c\ll n/\log^2n$) and the unclipped threshold $c\gg\sqrt n\log n$ are right. ✓
- **Remark 5.8.**
  - Item 1's first sentence ("open … when $dc\to\infty$") is contradicted, for clipped predictors and $c\gg d^2$, by its own next bullet and by Remark 5.7 (issue 3).
  - Bullet 3 matches `../research-notes/A-tight-conditioning-fails.md` Prop. 8.2(a) at $H=1$.
- **§0.2 table.**
  - Row 1 is correct.
  - Row 2: issues 1 and 3.
  - Row 3: issue 2.
  - Row 4: issue 5.
- **§6 errata.** Correct except:
  - the §0 item 6 headline and its "Open" bullet (issues 3–4);
  - the §6.4 replacement (issue 3);
  - the §6.1 parenthetical (issue 2). That parenthetical restricts "fails" to small $c$ for unit-ball inputs, but the high-dimensional version fails for every learner.

---

## 3. Issues, most severe first

### Issue 1 (major; definition). (P$_2^{o(1)}[\phi]$) quantifies over "every learner width $N\ge1$", which makes it false for every learner

**Where.** §1.4, the definition of (P$_2^{o(1)}[\phi]$). It propagates to:

- Corollary 5.2(b), (c);
- §0.1 item 2;
- §0.2 rows 2–3;
- Prop. 5.3 "What it refutes";
- the §6 errata for §0 item 6 and §2.3 A3.

**Problem.**

- The competitor class $\mathcal G^{(\alpha)}_n$ contains networks of width up to $n^\alpha$, but the property is demanded at every learner width, including $N=1$.
- With $d=1$, a width-1 depth-two network $v\tanh(\omega_0+\omega_1x)$ is monotone. Take
  - $D$: $x$ uniform on $\{-1,0,1\}$, $y=g^*(x)=\frac12[\tanh(1+2x)+\tanh(1-2x)]$;
  - $g^*$ has width 2, weights in $[-2,2]$ and $\lvert g^*\rvert\le1$, so $g^*\in\mathcal G^{(\alpha)}_n$ once $n^\alpha\ge2$;
  - by isotonic regression, every width-1 output, clipped or not, has $L_D\ge\Delta^2/6=0.0693$, where $\Delta=g^*(0)-g^*(1)=0.645$.
- So the property fails for every learner under (R1) and (R3). The minimum found by 3000-restart optimisation equals the isotonic bound, $0.06931$ (`width1_strawman.out`).
- Consequences:
  - "Depth-two SP$_c$ fails (P$_2^{o(1)}[\cdot]$)" is vacuous as literally defined. The tempered learner, which `../research-notes/B-tempered-likelihood.md` proves consistent, "fails" it too.
  - The definition contradicts the positive companion `../research-notes/B-tempered-likelihood.md` Corollary 8.1, which proves the "$+o(1)$" property "simultaneously for all learner widths $N\ge n^\alpha$".
  - The §0.2 status "not refuted … open" for $c\log n\to\infty$ is false under the literal definition, because the formulation is refuted trivially.

The note does observe, in one sentence of §1.4, that its refutations "also refute every variant that requires the bound … for example every $N\ge n^\alpha$". So the content is there, but the definition the final note would cite is the defective one.

**Fix.** Replace "every learner width $N\ge1$" by "every learner width $N\ge\lceil n^\alpha\rceil$", which is BRIEF's "$N\ge m$" with $m=n^\alpha$ and matches `../research-notes/B-tempered-likelihood.md` Cor. 8.1. No proof changes:

- Corollary 5.2(b) holds at every $N\ge\max\{N_0(a_d),\lceil n^\alpha\rceil\}$;
- Proposition 5.3 holds at every $N\ge\lceil n^\alpha\rceil$.

Keep the sentence on single-width variants.

### Issue 2 (major; scope). The "$+o(1)$ uniform over $d\le n$" formulation is false for every learner, so Proposition 5.3 does not refute anything specific to close conditioning there

**Where.**

- §0.2, row 3: "refuted for every $c=o(\sqrt n)$ … With unit-ball inputs, refuted only for $c<\sqrt{\beta(1)}/2$", in the column "Depth-two status";
- the "What it refutes" bullet after Proposition 5.3;
- the §6 erratum for RT §6.1.

**Problem.** Fix any $\alpha>0$, take $d=n$, and let:

- $x$ be uniform on $\{e_1,\dots,e_n\}$ (unit vectors, so admissible under both normalisations);
- $y=\theta_J$ at $x=e_J$, for $\theta\in\{\pm1\}^n$.

**The competitor.** $g(x)=n^\alpha\tanh(n^{-\alpha}\theta\cdot x)$ has width 1, first-layer weights $\pm n^{-\alpha}$ and readout $n^\alpha$. So $g\in\mathcal G^{(\alpha)}_n$, and $L_D(g)\le n^{-4\alpha}/9$.

**Any learner, at any width.**

- Let $U$ be the set of coordinates never sampled. $\lvert U\rvert/n\to e^{-1}$, and $\lvert U\rvert$ concentrates.
- Conditionally on the sample and the learner's randomness, $(\theta_j)_{j\in U}$ are independent fair signs, independent of the output $f$. So $(f(e_j)-\theta_j)^2\ge1$ with conditional probability at least $\tfrac12$ for each $j\in U$.
- Hence $L_D(f)\ge1/7$ with probability $1-o(1)$ over $(\theta,S)$, and some $\theta$ attains this with sample-probability $1-o(1)$.

**Size.** The Bayes-optimal learner, which predicts 0 on unseen atoms, has loss $\lvert U\rvert/n\approx0.368$, while the competitor's loss tends to 0 (`every_learner_dn.out`). With $d=\lceil\epsilon n\rceil$ the same argument gives a constant $e^{-1/\epsilon}/2$. So any $\phi(n)\ge\epsilon n$ is impossible.

**Consequences.**

- (P$_2^{o(1)}[n]$) fails for every learner, every $c$ and every width, under either normalisation.
- "Refuted for every $c=o(\sqrt n)$" suggests that close conditioning is to blame, which it is not.
- "With unit-ball inputs, refuted only for $c<\sqrt{\beta(1)}/2$" is false as a status: it is refuted for all $c$.

**Fix.**

- State that uniformity over $d\asymp n$ is impossible for every learner, using the example above.
- Reframe Proposition 5.3's consequence. SP$_c$ with $c=o(\sqrt n)$, or $c\le\nu\sqrt n$ with $\nu<\sqrt\beta/2$, is worse than the zero network by $\beta(\lambda)-o(1)$, at every width, on a law where the zero network is Bayes-optimal.
- This refutes the weaker property "$L_D(\mathsf A_n)\le\inf_{\text{constants}}L_D+o(1)$, uniformly over $d\le n$", which the trivial learner satisfies.
- Under unit-ball inputs, the same refutation holds for $c<\sqrt\beta/2$. It is open for larger $c$; Remark 5.8 item 4 is right as a question about the learner.
- Amend the §6.1 erratum accordingly.

### Issue 3 (minor; scope). The "open" range for $c\log n\to\infty$ is overstated

**Where.**

- §0.2 row 2 ("open (Remark 5.8)");
- Remark 5.8 item 1 ("open … when $dc\to\infty$");
- the §6 erratum for §0 item 6 (the "Open" bullet);
- the §6 erratum for §6.4.

**Problem.** For clipped readings ((R1) with clip, (R2) $\bar f_\sigma$, (R3) clip), `../research-notes/B-tempered-likelihood.md` Proposition 6.1 with Lemma 5.3(a) bounds the excess against any $g\in\mathcal G^{(\alpha)}_n$. It holds at every $N\ge n^\alpha$, with $\sigma_0$ uniform over samples. The bound is

$$c\bigl(d^2+d+4\bigr)n^{4\alpha-1}+8D_n\sqrt{1/c+1/n}+(4+4n^{4\alpha})\sqrt{\ln(2/\delta)/(2n)} .$$

For $d\le\log_2n+C_0$, $\alpha<1/8$ and $\log^2n\ll c\ll n^{1-4\alpha}/\log^2n$, this tends to 0. Since (P$_2^{o(1)}$) only asks for some $\alpha$, the condition becomes $\log^2n\ll c\le n^{1-\epsilon}$. `../research-notes/B-tempered-likelihood.md` Corollary 8.1 states this explicitly at $H=1$ for $c=n^{(2-8\alpha)/3}$.

So, after the fix of issue 1, (P$_2^{o(1)}[\log_2n+C_0]$) is:

- **proved** for clipped readings in that window;
- **open** for $1/\log n\ll c\lesssim\log^2n$ (clipped), a range containing every fixed $c$ and $c=1$;
- **open** for $1/\log n\ll c\lesssim\sqrt n\log n$ (unclipped).

Remark 5.8 item 1 is contradicted by its own next bullet when $c\gg d^2$ (clipped). The note's own Remark 5.7 and its erratum for RT §7 item 3 already give the correct window.

**A separation worth recording.** At $c=\log^3n$ (clipped), Corollary 5.2(a) refutes (P$_2$), while `../research-notes/B-tempered-likelihood.md` proves the "$+o(1)$" formulation (rate $O(1/\sqrt{\log n})$). So the two formulations really differ at depth two, which is the point of RT A3.

**Fix.** State the three regimes in the table, in Remark 5.8 and in the errata.

### Issue 4 (minor; wording in §6 errata)

- **"Fully when $c\lesssim1/\log n$"** (headline for §0 item 6). Full memorization, meaning excess $\beta(\lambda)-o(1)$, needs $c=o(1/\log n)$. For $c\le\nu/\log n$ the proved constant is $\Gamma_\lambda(\nu)<\beta(\lambda)$.
- **"When $c$ is bounded below (precisely, when $c\log n\to\infty$)"** is not an equivalence. For example, $c=1/\sqrt{\log n}$ satisfies $c\log n\to\infty$ but is not bounded below. Write "more generally".

### Issue 5 (minor; §0.2 row 4)

"At fixed $d$ its excess is $O(2^d/n)$" holds for bounded $c$ and fixed confidence. `../research-notes/A-tight-conditioning-fails.md` Prop. 5.2 gives $(8M/\delta'+4c)/n$ with probability at least $1-\delta'-Me^{-n/(8M)}$. For $c=c(n)$ write $O((2^d/\delta+c)/n)$, which vanishes iff $c=o(n)$.

### Issue 6 (minor; optional strengthening of Corollary 5.2(b))

The refutation needs only infinitely many $n$. So "$c\le\nu/\log_2n$ for all large $n$" can be weakened to $\liminf_d dc_d<\infty$, by applying (ii) along a subsequence. This makes (b) and (c) exhaustive: refuted iff $\liminf c\log n<\infty$, silent iff $c\log n\to\infty$.

### Issue 7 (minor; §8, response C3)

"$E_0=c(dF_d+1)+\vartheta_cna$, at least as good as RT's $c(dF_d+1)+2$" holds only when $\vartheta_cna\le2$, for example at $a=1/n$. It fails for the adopted $a=1/d$, where $\vartheta_cn/d\gg2$; that choice trades a larger $E_0$ for a smaller width. Harmless, since no regime changes.

### Issue 8 (minor; readings)

- **Joint measurability.** (R1) takes the probability over the sample and the draw, which needs $S\mapsto\Pi_{\sigma,S}$ to be a measurable kernel. It is one: the density $e^{-F_{c,S}(w)/(2\sigma^2)}/Z(S)$ is jointly continuous and $Z>0$ is continuous, so Tonelli applies. Add a sentence.
- **The Gibbs risk.** The reading "the learner's loss is the Gibbs risk $\mathcal G_\sigma$" is covered by Theorem 5.1(3): on $\mathcal E_d$, $\mathcal G_\sigma\ge(1-\eta)(1+2\varepsilon_d)>1+\varepsilon_d$ when $\eta<\varepsilon_d/(1+2\varepsilon_d)$. It is listed in Remark 5.6 but not among (R1)–(R3). Add it as (R1′).

### Issue 9 (minor; citation of the focus summary)

The summary "refutes the polynomial-sample inequality … with $c\le\mathrm{poly}(d)$ **but not** the $+o(1)$ formulation" is the withdrawn RT sentence. It is false for $c\le\nu/\log_2n$. The final note must use Corollary 5.2's three regimes, with issues 1 and 3 applied.

---

## 4. Strongest correct statement

**Setting.**

- Depth two; the cube example $D_d$; $n=\lceil\lambda2^d\rceil$.
- SP$_c$ in the strong-prior limit: $S$, $n$ and $N$ fixed, then $\sigma\downarrow0$, with $\sigma_0(d,n,c,N,\eta)$ uniform over samples.
- Predictors: near-minimisers, Gibbs draws and Gibbs risks, $\bar z_\sigma$, $\operatorname{clip}\bar z_\sigma$, $\bar f_\sigma$. The progressive mixture is not covered.

**Theorem 5.1 (correct as stated).** For every sample, every $c>0$, every $a\in(0,1]$ and every $N\ge N_0(a)=\lceil72dn\ln(2M)/a^2\rceil+1$:

- every $w\in\mathcal N_1$ has $\mathcal R(z_w)\le(1-\vartheta_c)G+c(dF_d+1)+\vartheta_cna$;
- every covered predictor has excess at least $\max\{\Psi_{\rm tri},\Psi_{\rm cor}\}$, in the limit $\liminf_{\sigma\downarrow0}$ for the posterior quantities.

**Corollary 5.2 (correct as stated, with definitions repaired).** On an event of probability at least $1-\rho_n\to1$, at every $N\ge N_0(a_d)$ with $a_d\to0$ (for $a_d=1/d$, $N_0=O(n\log^4n)$):

- **(i)** $c\le d^k$ ⇒ excess $\ge\gamma(\lambda)(18dc+1)^{-2}(1-o(1))$;
- **(ii)** $dc\le\nu$ ⇒ excess $\ge\Gamma_\lambda(\nu)-o(1)$;
- **(iii)** $dc\to0$ ⇒ excess $\ge\beta(\lambda)-o(1)$;
- **(iv)** $dc\to\infty$ ⇒ the bound tends to 0.

What this refutes:

- **(P$_2$)** (polynomial sample size, all $d$, every $N\ge m$) for every $0<c(n)\le\mathrm{polylog}(n)$.
- **(P$_2^{o(1)}[\log_2n+C_0]$)**, defined with "every learner width $N\ge\lceil n^\alpha\rceil$", whenever $\liminf c\log n<\infty$. The constant is $\Gamma_\lambda(\nu)$, and $\beta(\lambda)$ when $c\log n\to0$.

The status of (P$_2^{o(1)}[\log_2n+C_0]$) by range of $c$:

| $c$ range | Status | Source |
|---|---|---|
| $\liminf c\log n<\infty$ | refuted | this note |
| $\log^2n\ll c\le n^{1-\epsilon}$, clipped readings | **holds** | `../research-notes/B-tempered-likelihood.md` Prop. 6.1 / Cor. 8.1 |
| $1/\log n\ll c\lesssim\log^2n$ (clipped), including every fixed $c$ and $c=1$ | open | — |
| $1/\log n\ll c\lesssim\sqrt n\log n$ (unclipped) | open | — |

**Proposition 5.3 (correct as stated).** Hadamard atoms, $d=M$, inputs of norm $\sqrt d$. On the event of Lemma 1.3, at every width $N\ge1$:

- $c\le\nu\sqrt M$ with $\nu<\sqrt{\beta}/2$ ⇒ excess $\ge\beta(\lambda)(1-\sqrt{2\nu/\sqrt\beta})^2-o(1)$;
- $c\le\sqrt M$ ⇒ excess $\ge\beta(\lambda)-4\sqrt cM^{-1/4}-O(M^{-1/3})$;
- $c=o(\sqrt M)$ ⇒ excess $\ge\beta(\lambda)-o(1)$.

Here the zero network is Bayes-optimal. So the result refutes, for these $c$, "compete with the zero network up to $o(1)$, uniformly over $d\le n$", a property the trivial learner satisfies. It does **not** refute a meaningful "$+o(1)$ uniform over $d\le n$" network-competitor formulation, because no learner satisfies that one: $d=n$, $x$ uniform on $\{e_j\}$, $y=\theta_J$. Under unit-ball inputs the same holds for $c<\sqrt{\beta(\lambda)}/2$; whether SP$_c$ is worse than the zero network for larger $c$, including $c=1$, is open.

---

## 5. Scripts and outputs (`../checks/verify-RT-depth2-logic-revised/`)

| Script | What it checks | Result (`.out`) |
|---|---|---|
| `constants_and_gamma.py` | $\beta$ (series and closed form), $\gamma$, maxima; (1.0) on $[0.01,20]$; $\Gamma_1$ table, crossing, vanishing point, monotonicity; Remark 5.4 limits; $(\sqrt q-r)_+^2\ge q-2r$; bracket (sympy); Lemma 1.1 pointwise inequality | all as stated; crossing $0.038994$, vanishing $0.18287$; 0 violations |
| `event_bounds.py` | $\underline\Psi_d$ from the note's definitions, and Theorem 5.1's $\Psi$ at the event corner (identical, $20\le d\le1000$); $c=1$ range; small-$c$ table; Prop. 5.3 table and rate; widths | every number in §§4–5 reproduces; $c=1$: first positive $d=30$, $\ge2\varepsilon_d$ for all $33\le d\le1000$, max $2.258\cdot10^{-7}$ at $d=35$ |
| `hadamard_explicit.py` | Prop. 5.3 with explicit Sylvester matrices, $M\le1024$, $N\in\{1,2,5\}$, $\lambda\in\{1,1.5\}$; unit-ball cost | 0 failures; largest error ratio $0.9833$ |
| `lemma21_explicit.py` | Lemma 2.1 built literally ($d=3,4$; exact mixture, sampling, groups, readout); energy, output, residual, objective chain, Theorem 5.1 budget at $t=\vartheta_c$ | all pass |
| `lemma12_kkt.py` | Lemma 1.2(a),(b), (1.1), clipping, against exact constrained minima (4000 instances) | 0 violations; (b)/exact: median $0.69$, max $1.00$ |
| `lemma13_mc.py` | frequency of the Lemma 1.3 event vs $1-\rho_n$; means of $Q,G,V$ | $0.925/0.975/0.996/1.000$ at $d=8,10,12,14$ |
| `width1_strawman.py` | issue 1: width-1 networks vs the width-2 bump | min loss $0.06931=\Delta^2/6$ (clipped and unclipped) |
| `every_learner_dn.py` | issue 2: $d=n$, atoms $e_j$; Bayes-optimal learner vs competitor | learner loss $\approx0.368$, competitor $\le n^{-4\alpha}/9\to0$ |

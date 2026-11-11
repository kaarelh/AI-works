# Referee report, round 1 on the revision (logic and definitions): `../research-notes/small-learner-width.md`, Proposition 6.1 corrected

**Lens.** I checked quantifiers, limit order ($\sigma\downarrow0$ after $n$, the sample and the width are fixed), case splits and definitions against `../research-notes/problem-brief.md` and the cited sources. I looked for circularity, misapplied lemmas, missing hypotheses (widths, weight bounds, clipping, measurability, existence of minimizers, label range), and steps that assume what they prove.

**What I read.**

- **The whole of `../research-notes/small-learner-width.md`:**
  - §0, the corrected clause;
  - §1 definitions;
  - Lemmas A–F;
  - Theorems 1 and 4, Corollaries 2 and 3;
  - Remarks 5–8;
  - §7.1–7.3 and §9.
- **The parts of `../research-notes/red-team.md` it replaces or uses:**
  - §6.3, lines 472–497;
  - Lemma 1.0 and Lemma 1.1, lines 37–71;
  - Theorem 3.2, lines 257–287;
  - every line that cites Proposition 6.1 (lines 20, 30, 196, 475, 530, 562).
- **The previous reports:** `RT-width-logic.md` and `RT-width-computation.md`.
- **The imported sources, opened and compared:**
  - `../research-notes/B-tempered-likelihood.md` Lemma 2.3, Lemma 3.1, Corollary 8.1, Proposition 9.1 and Lemma 9.2;
  - `../research-notes/A-tight-conditioning-fails.md` and its revision `../research-notes/A-tight-conditioning-fails.md`: Lemma 2.1, Theorem 4.4 and Corollary 4.5;
  - `NNG/side-results/continuous-domains/source/paper.tex`: §"Model and main results", eq. `energy`, eq. `teacher-energy`, Theorem `strong` and its proof, Lemma `posterior`, Proposition `exact` and Corollary `exact`;
  - `NNG/works-in-progress/slt-likelihood/README.md` §2.

**Scripts.** They are in `../checks/verify-RT-width-logic-revised/` (§5). They are independent of the author's scripts and coded from the note's definitions.

## Verdict: minor fixes

The corrected claim holds. I checked every step of the chain that the corrected clause rests on:

- the clone (Lemma A);
- the competitor-free energy budget $K=n/c+1$ (Lemma B(a));
- the perturbation bound (Lemma C);
- the grid (Lemma D);
- Bernstein's inequality (Lemma E(ii));
- the uniform deviation (Theorem 1(a));
- the per-competitor oracle inequality (Theorem 1(b));
- the class minimum (Corollary 2);
- the explicit rate (Corollary 3);
- the Laplace concentration (Lemma F);
- the transfer to the Gibbs risk and the posterior mean (Theorem 4).

I found no circularity, no misapplied lemma and no missing hypothesis in the proof. The limit order is handled correctly.

The issues are notation, user-facing wording, an incomplete citation list in §7.3, and one imprecise sub-claim in the closing remark (Remark 8). None affects Theorem 1, Corollaries 2–3 or Theorem 4.

### Answers to the focus questions

1. **Perturbation bound (Lemma C): correct.**
   - I re-derived the recursion: $e_1\le\eta(d+1)\sqrt N$, $e_\ell\le\sqrt K e_{\ell-1}+\eta N^{3/2}$, and output error $\le\sqrt{K/N}\,e_H+\eta N$. Only the norms of $w$ and $|h'|\le1$ are used, so $w'$ needs no energy bound.
   - The closed form follows from $d+1+NH\le H(d+N+1)$.
   - An adversarial projected sign-gradient search over the $\ell_\infty$ box (600 networks at energy exactly $K$, $1\le H\le4$) found no violation.
   - The worst case is $0.90$ of the sharper form and $0.64$ of the closed form, at $H=1$. So the bound is nearly tight there (minor issue m9).
2. **Grid mesh and log-cardinality (Lemma D): correct.**
   - $|T|=\lceil2R/\eta_N\rceil+1\le2+2R/\eta_N$, which matches $\Lambda_N$ exactly.
   - The covering radius is $\eta_N/2$, so the rounding error is $1/(2n)$.
   - All coordinates lie in $[-\sqrt{KN},\sqrt{KN}]$.
   - The grid depends only on $(n,c,N,d,H)$, so it is fixed before the sample and serves every competitor.
3. **Uniform deviation (Theorem 1(a)): correct.**
   - One-sided Hoeffding with range 4, plus a union bound at level $\delta/4$, gives $\mathrm{Dev}_N(\delta)$.
   - Moving to the grid point and back costs $2/n+2/n$, by the 4-Lipschitz clipped loss.
   - The event is a finite intersection of measurable events and involves neither $\sigma$ nor a competitor.
4. **Exponents.**
   - The withdrawn rate $O(n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\log n})$ is correctly withdrawn.
   - The new bound (5.2) is correct with the stated constants. Coded independently, the exact excess of (5.1) is at most $0.664$ times (5.2) on 40,000 admissible random cases, with $n$ from 2 to $10^{200}$, $H\le10$ and $\delta$ from $10^{-12}$ to $0.999$. The bound $\Lambda_N\le(H+5)\ln2n$ holds with ratio at most $0.631$.
   - For the class of case (i), every exponent is negative for $0<\alpha<\frac14$, and the leading term is $5\sqrt2\,n^{2\alpha-1/2}\sqrt{\ln(4/\delta)}$.
5. **"Polynomially small for $\alpha<1/4$" with the stated class: holds, after the Bernstein repair.**
   - The class is width $\le\lceil n^\alpha\rceil$, weights $\le n^\alpha$, $d\le n^\alpha$, repository architecture.
   - With Bernstein the rate is $O_{L,\alpha,\delta}(n^{2\alpha-1/2})$.
   - With the original Hoeffding term it holds only for $\alpha<1/8$, at rate $n^{4\alpha-1/2}$. Remark 5 says this, though its title overstates it (m6).
   - Lemma E(ii) holds against exact binomial tails, including the skewed laws relevant here: the worst ratio of tail to $\delta'$ is $0.56$ on 792 two-point cases and $0.12$ on 1,680 three-point cases.
   - On the spiky competitor of Remark 6(b), the Bernstein event of Theorem 1(b) fails with probability at most $0.14\cdot\delta/4$.
6. **The closing sentence (now Remark 8): essentially right, with two wording repairs.**
   - **The success side.** The condition $N(N+d)\ln n=o(n)$, so $N=o(\sqrt{n/\ln n})$ on the cube family, is correct. The vacuity threshold $N\ge\sqrt{2n/((H-1)\ln2n)}$ is correct.
   - **"Fixed $d$".** The bullet says "fixed $m,B,d$" and then applies the claim on the cube family, where $d=\log_2n$ (m5).
   - **The failure side.** It matches `../research-notes/A-tight-conditioning-fails.md`/`../research-notes/A-tight-conditioning-fails.md` Theorem 4.4 exactly, including $N_0$, the reduced excess $(\sqrt{\beta(\lambda)}-a\sqrt\lambda)_+^2$ and the probability $1-\delta$.
   - **The $n^{5/3}$ sentence.** "The full excess … needs $a\to0$, and then $N_0=O(n^{5/3}\log^2n)$" misleads. The exponent $5/3$ comes from Corollary 4.5's particular choice of $a_d$. Any slowly vanishing $a$ certifies the full excess $\beta(\lambda)-o(1)$ at widths $\omega_n\,n\log^2n$ for every $\omega_n\to\infty$ (m4).

---

## 1. Statements compared against the sources

| use in `../research-notes/small-learner-width.md` | source (opened and compared) | match |
|---|---|---|
| Architecture: $h^0=\bar x$, $h^\ell=\tanh(W^\ell h^{\ell-1})$, $z_w=v^\top h^H$; no internal biases; linear readout; $P_N=N(d+1)+(H-1)N^2+N$ | `paper.tex` lines 114–125; `../research-notes/problem-brief.md` §2 | yes. `paper.tex` uses the unit ball; Remark `cube` (lines 225–232) extends it to compact $X\subseteq[-1,1]^d$, which the note assumes |
| Energy $\kappa_N=\frac dN\lVert W^1\rVert_F^2+\sum_{\ell=2}^{L-1}\lVert W^\ell\rVert_F^2+N\lVert v\rVert^2$ | eq. `energy`, lines 293–296; brief §2 | yes |
| Lemma A (clone at every $N\ge m$, energy $\le E_*$) | eq. `teacher-energy`, lines 297–308 (teacher of the same depth, width $C\ge1$, weights $\le B\ge1$) | yes. The note allows $B\ge0$, which is harmless. I re-derived the three layer terms. `check_lemmas_AC.out`: clone error $4\cdot10^{-15}$ on $\mathbb R^d$, $\kappa_N/E_*\le0.64$ |
| SP$_c$ posterior $\propto e^{-F_{c,S}/(2\sigma^2)}$, $F_{c,S}=\kappa_N+\frac nc\hat L_S(z_w)$; $c=1$ is the clean-label scaling | brief §2; `slt-likelihood/README.md` §2 (observation variance $\sigma^2$) | yes |
| Limit order: $n$, $S$, $N$ fixed, then $\sigma\downarrow0$; $\sigma_0$ may depend on $n,N$ but not on $D$ or $S$ | brief §2 and §5; `slt-likelihood` §2 ("$\sigma_0$ may depend on the selected $n,N$ … uniform over $D$") | yes. In `paper.tex` Theorem `strong` (lines 178–197), $\sigma_0$ does not depend on $n$. Here it does, as the brief permits; the note states this correctly (Theorem 4) |
| Lemma B(a), competitor-free budget $\kappa_N\le n/c+\zeta$ | `../research-notes/B-tempered-likelihood.md` Lemma 2.3(a) | yes, verbatim |
| Lemma F (Laplace concentration, uniform in $S$) | `../research-notes/B-tempered-likelihood.md` Lemma 3.1; `../research-notes/red-team.md` Lemma 1.1; the Laplace step in the proof of `paper.tex` Theorem `strong` (lines 510–533) | yes. I re-derived it line by line (§2.6) |
| Lemma `posterior`, Proposition `exact`, Corollary `exact` | `paper.tex` lines 248–268, 613–688 | **not used**. The width-free energy cover is replaced by a width-dependent parameter grid. This is consistent: the grid pays $P_N$ and needs no cover. Corollary `exact` concerns TUBE with $\rho\downarrow0$ after $\sigma\downarrow0$, a different learner |
| Remark 7 imports Proposition 9.1(a) and Lemma 9.2 | `../research-notes/B-tempered-likelihood.md` lines 808–851 | yes, the hypotheses match exactly. I re-checked the induction $t_\ell\ge(\tanh1)^\ell\min\{1,G^{\ell-1}B\delta_0\}$. `check_remark7.out` builds the chain network exactly (weights in $[-B,B]$, fit error $<10^{-60}$) and confirms the sign change of $\log\eta$ at $\alpha=L/(2(2L-1))$ for $L=2,3,4,6$ |
| Remark 8 imports Theorem 4.4, Lemma 2.1 and Corollary 4.5 | `../research-notes/A-tight-conditioning-fails.md` lines 82–88, 342–386; `../research-notes/A-tight-conditioning-fails.md` lines 103–112, 363–411 (the same formulas) | yes: $N_0=\lfloor64\ln2\cdot d(d+1)s/a^2\rfloor+1$ with $s=\min\{n,M\}$; event of probability $\ge1-\delta$; near-minimizers, Gibbs and posterior means, clipped and unclipped. See m4 for the $n^{5/3}$ remark |
| Lemmas 1.0 and 1.1 of `../research-notes/red-team.md` §1 | lines 37–71 | Both are correct (re-derived). The revision uses neither directly: Lemma F replaces 1.1, and only §7.1 item 1 and the imported `../research-notes/B-tempered-likelihood.md` Proposition 9.1 use the bounds of 1.0, through `../research-notes/B-tempered-likelihood.md` Lemma 2.1 |

---

## 2. Audit of the argument

### 2.1 Quantifiers and limit order

The corrected clause (§0; Corollary 3(i) with Theorem 4) has this structure:

- **Fixed first:** $L,\alpha\in(0,\frac14),n\ge2,\delta$, $d\le n^\alpha$, $X$, $D$.
- **Then:** an event $\mathcal E=\mathcal E_0(N)\cap\mathcal E_B(g^*)$ of $D^n$-probability $\ge1-\delta/2$.
- **On $\mathcal E$:** the bound holds for every $w\in\mathcal N_1^{(N)}(S)$, at $N=\lceil n^\alpha\rceil$.
- **For the posterior predictors:** for every sample in $\mathcal E$, the bound holds for $\limsup_{\sigma\downarrow0}$ of the clipped Gibbs risk and of the risk of $\bar f_\sigma=\mathbb E_{\Pi_\sigma}\operatorname{clip}z_w$.

Checks:

- $\mathcal E$ involves neither $\sigma$ nor the learner's parameters. It depends on $N$ through the grid, which is fine because $N$ is a deterministic function of $n$.
- $g^*$ depends on $D$ and $n$ only, so Bernstein's inequality is applied to a fixed function.
- $\sigma_0(d,H,N,n,c,\epsilon')$ in Theorem 4 does not depend on $S$ or $D$. So "with probability $\ge1-\delta/2$, for all $\sigma<\sigma_0$" is proved directly, and the probability statement needs no measurability of the posterior risk as a function of $S$.
- The bound is non-asymptotic in $n$, and the $n$-asymptotics are taken outside the $\sigma$-limit. This is the order the brief prescribes.

### 2.2 Lemma A and Lemma B

- **Lemma A.** The group sizes satisfy $k_j/k_{j'}\le2$ and $N/\lfloor N/m\rfloor<2m$. This gives the three layer bounds and $E_*=d(d+1)B^2+2Hm^2B^2$, with $H=L-1$. The clone is exact on all of $\mathbb R^d$, so it is exact at the sample points.
- **Padding.** Zero-padding a competitor to width $\bar m$ preserves the function: padded units compute $\tanh0=0$ and have zero outgoing weights. So $\mathcal G_L(d,\bar m,\bar B)=\{g_\theta:\theta\in[-\bar B,\bar B]^Q\}$ is correct.
- **Lemma B(a).** $F(0)=c^{-1}\sum y_i^2\le n/c$ because $z_0\equiv0$ and $|y_i|\le1$. This is where the label range enters, and why one grid serves every competitor.
- **Lemma B(b).** This is the comparison with the clone. It needs $m\le N$, which Corollaries 2–3 have.

### 2.3 Lemmas C, D and Theorem 1(a)

These are as in focus answers 1–3. Two further points:

- $\mathcal E_0$ uses the lower tail $\mu-\bar Z$, which is the direction needed: $L_D\le\hat L+\ldots$.
- Theorem 1(a) holds simultaneously for all $w$ with $\kappa_N(w)\le K$, so no measurable selection of a near-minimizer is needed.

### 2.4 Lemma E(ii) and Theorem 1(b)

- **The inequality used.** Bernstein's inequality for summands bounded above (Boucheron, Lugosi and Massart, Corollary 2.11) is applied to $X_i=Z_i-\mu\le b$ with $\sum\mathbb EX_i^2=n\operatorname{Var}Z\le nb\mu$. The variance bound uses $0\le Z\le b$.
- **The root computation.** It is exact: $t^2-(A^2+Ct)=AC\ge0$.
- **The case split.** It is on the deterministic quantity $L_D(g)$, not on data. When $L_D(g)\ge4$ the conclusion is trivial, because $L_D(\operatorname{clip}z_w)\le4$.
- **The range.** $(g(x)-y)^2\in[0,(U+1)^2]$ uses $\sup_X|g|\le\lVert u\rVert_1\le mB$ and $|y|\le1$.
- **Probabilities.** The accounting ($\delta/4$ per event) is correct.

### 2.5 Corollaries 2 and 3

**Corollary 2.**

- *Existence of $g^*$.* The parameter box is compact, and $\theta\mapsto L_D(g_\theta)$ is continuous by dominated convergence with the bound $(\bar U+1)^2$. If the minimizer is not unique, any fixed choice works, for example the lexicographically least point of the compact argmin set. It depends on $D$ only.
- *$L_D(g^*)\le1$.* This holds because $0\in\mathcal G$ and $\mathbb Ey^2\le1$.
- *The Bernstein term.* $\Gamma_B(g^*)$ is then at most $(\bar U+1)\sqrt{2\ell/n}+\frac23(\bar U+1)^2\ell/n$.

**Corollary 3.** Each of the five steps is correct:

- $d(d+1)\le2\nu^2$, $N^2\le4\nu^2$ and $1\le\nu^2\bar B^2$ give $(8L-5)\nu^2\bar B^2$;
- $\bar U+1\le3\nu\bar B$;
- $P_N\le(4H+2)\nu^2$;
- $\Lambda_N\le(3+\frac{3H}2)\ln2+\frac{2H+9}4\ln n\le(H+5)\ln2n$, using $16-8\sqrt3>0$, $\ln H\le(H-1)\ln2$ and $\ln n\ge\ln2$;
- $\sqrt{a+b}\le\sqrt a+\sqrt b$.

The final absorption uses $6\le8L-1$ and $n^{-1/2}\le\bar Bn^{\alpha-1/2}$. The hypotheses of case (i), $N=\lceil n^\alpha\rceil\le2n^\alpha$ and $\bar B=n^\alpha\ge1$, are satisfied. Case (iii) is the substitution $\alpha=\frac12-\epsilon$.

### 2.6 Lemma F and Theorem 4

**Lemma F.**

- $E$ and $\Omega$ are compact and convex and do not depend on $S$.
- $G_\Omega,Z_\Omega,R_\Omega$ are maxima over $\Omega\times[-1,1]^d$, not over $X$. So $\ell_F$ is uniform in $S$ and in $D$.
- The ball of radius $\rho\le1$ around a minimizer lies in $\Omega$.
- With $a=\zeta/(4(n/c+\zeta))$, the exponent gap is exactly $\zeta/2$.
- The final bound $(2\pi\sigma^2/a)^{P/2}e^{-\zeta/(4\sigma^2)}/(\det\Lambda\,v_P\rho^P)$ tends to 0 and does not depend on $S$.

**Theorem 4.**

- $\mathbb E_{\Pi_\sigma}\Phi\le\sup_{\mathcal N_1}\Phi+4\Pi_\sigma(\mathcal N_1^c)$ for $0\le\Phi\le4$.
- Jensen's inequality holds pointwise in $(x,y)$, and Tonelli applies because $(w,x,y)\mapsto(\operatorname{clip}z_w(x)-y)^2$ is continuous.
- $\bar f_\sigma$ is Borel; in fact it is continuous.

What is not covered is stated correctly in §7.1 item 1: unclipped outputs, and the clip of the posterior mean.

### 2.7 Remarks 5–8

- **Remark 5.** The sandwich $n^{2\alpha}\le\bar U+1\le3n^{2\alpha}$ is correct (`check_cor3.out` (2)). The threshold $\alpha=1/8$ for the Hoeffding form is correct.
- **Remark 6(b).** The competitor $g(x)=mB\tanh(mB\tanh(Bx))$ is in the class of case (i) ($d=1$). The law gives $L_D(g)=1$ and $L_D(0)=p$. The logical claim is right: a bound proved through $\hat L(g)$ for this $g$ can be no smaller than the corresponding quantile.
- **Remark 6(c).** Calling this open is appropriate. A small probe at $L=2$ (§5) found best-in-class competitors that overshoot to between $0.33$ and $0.69$ of $\bar U$ at a rare point, with $\mathrm{sd}(\text{loss})/\bar U$ between $0.07$ and $0.26$. That held in four of five settings; in the fifth, with a larger rare mass, the best-in-class network gives up the steep fit instead. This suggests, but does not show, that the "by this proof" half of (c) may be settled negatively.
- **Remark 7.** The exponent arithmetic is correct, and $m=\lfloor n^\alpha\rfloor\ge n^\alpha/2$. The failure law has $d=1\le n^\alpha$. The failure holds for every sample and every width, in particular at $\lceil n^\alpha\rceil$. The window $[\frac14,\frac L{2(2L-1)}]$ is correct, and it is decreasing in $L$ to $\frac14$.
- **Remark 8.** See focus answer 6 and issues m4–m5. The success threshold and the vacuity threshold are confirmed by `check_cor3.out` (3): with the zero competitor on the cube family, $\mathrm{Dev}_N\approx0.1$ at $N=0.02\sqrt{n/\ln n}$ for $n$ from $10^9$ to $10^{40}$, a constant and not $o(1)$, as the condition $N=o(\sqrt{n/\ln n})$ predicts.

---

## 3. Issues

All are minor.

**m1. Notation clash on $\Lambda_N$** (lines 37, 68, 119, 228, 273). $\Lambda_N$ denotes two objects:

- the diagonal energy matrix ($\kappa_N=|\Lambda_Nw|^2$, line 37);
- the logarithm $\ln(2+2n\sqrt{KN}H(d+N+1)(K+1)^{H/2})$ (line 68), which is used in $\mathrm{Dev}_N$, Lemma D and Corollary 3.

Lemma F then writes "$\Lambda=\Lambda_N$, and let $\lambda_{\max}$ be the largest entry of $\Lambda$" and uses $\det\Lambda$. Read with the line-68 definition, that sentence is meaningless.

Other clashes:

- $U$: competitor matrices $U^\ell$, and also $U=mB$;
- $a$: Lemma F's exponent split, and also the energy terms $a_\ell$;
- $\eta$: Lemma C's mesh, Remark 7's $\eta$, and the brief's $\eta(x)$;
- $\kappa$: Corollary 3(i) "for every $\kappa<\frac12-2\alpha$", and also the energy $\kappa_N$;
- $G$: Remark 6(b), and also $G_\Omega$.

*Fix:* rename the logarithm (for example $\mathcal L_N$) or the matrix (for example $\mathrm{diag}(\lambda_N)$), and rename the others locally.

**m2. "In the user's words" (line 236) overstates coverage in three places.**

- **(a) "Clip its predictions."** For the posterior-mean predictor, the natural reading is $\operatorname{clip}(\mathbb E_{\Pi_\sigma}z_w)$. §7.1 item 1 explicitly excludes it. What is covered is $\mathbb E_{\Pi_\sigma}\operatorname{clip}z_w$ and the clipped Gibbs risk. The exclusion is real, not only a gap in the proof.
  - Pointwise one only has $(\operatorname{clip}\bar z-y)^2\le\max_i(\operatorname{clip}z_i-y)^2$ over the mixture components.
  - Two near-minimizers that output about $-\sqrt n$ on disjoint small sets $A_1,A_2$ with label $+1$ each cost $4\,D(A_i)$. Their average costs $4(D(A_1)+D(A_2))$, and $k$ components cost up to $k$ times the worst one.
- **(b) "Depth-$L$ tanh networks."** This drops "of the repository architecture": no internal biases, a linear readout without bias, and the input bias only through $\bar x=(1,x)$. Standard MLPs with hidden biases are not in $\mathcal G_n$, and Lemma A needs the exact architecture.
- **(c) The domain.** The hypothesis $X\subseteq[-1,1]^d$ is missing.

*Fix:* "… and use as predictor either a posterior draw with its output clipped to $[-1,1]$, or the posterior average of the clipped outputs (not the clip of the posterior average). Its test MSE is at most the best test MSE among depth-$L$ tanh networks of the repository architecture (no internal biases) with width and weights at most $n^\alpha$ …, for inputs in $[-1,1]^d$ …"

**m3. §7.3 is not the complete list it claims to be** (line 23: "every place in `../research-notes/red-team.md` that cites Proposition 6.1"). `../research-notes/red-team.md` §8, line 562 (E, positive direction, sketch) also cites it: "For $m\le N<T$ … Proposition 6.1 applies if $T\le n^{1/2-\epsilon}$".

That use concerns the finite-scale posterior $\mu_{N,\gamma}$ with no $\sigma\to0$ limit. Lemma F and Theorem 4 do not transfer to it: near-minimizer concentration is a strong-prior statement. It would also need "clipped predictions".

The companion `../research-notes/A-tight-conditioning-fails.md`, lines 543 and 1039, still describes Proposition 6.1 as "an unrefereed parameter-counting sketch". This is outside the note, but the final write-up should update it.

*Fix:* add a §7.3 entry for line 562. Mark that use as unsupported by the corrected proposition until a finite-scale analogue of Theorem 4 is proved.

**m4. Remark 8, failure bullet (line 340): "The full excess $\beta(\lambda)-o(1)$ needs $a\to0$, and then $N_0=O(n^{5/3}\log^2n)$."**

The exponent $5/3$ is an artifact of `../research-notes/A-tight-conditioning-fails.md` Corollary 4.5's choice $a_d=(\max\{c_d,1\}/2^d)^{1/3}$. Theorem 4.4 holds for every $a\in(0,1]$.

- At $c=1$, the only constraints are $a_d\to0$ and $a_d2^d\to\infty$. Then the terms $\lambda a_d^2$ and $\frac{9(H+1)}{2a_d2^d}$ in $\epsilon$ both vanish.
- So the full excess is certified at every $N\ge N_0(d,s,a_d)=O(n\log^2n/a_d^2)$, that is, at $N\ge\omega_n\,n\log^2n$ for any $\omega_n\to\infty$. To get it with probability $\to1$, use $\delta_n\to0$ slowly.
- `check_A_width.out`, with $a_d=1/\log_2d$: certified excess $0.337,0.355,0.375$ at $d=400,1000,4000$, tending to $\beta(1)=0.4848$, while $N_0/(n\log_2^2n)$ is only $3.3\cdot10^3,4.4\cdot10^3,6.4\cdot10^3$. Corollary 4.5's schedule has $N_0/(n\log^2n)=8\cdot10^{81}$ at $d=400$.

The failure side of the window is therefore $n^{1+o(1)}$ even for the full constant. The same imprecision appears in `../research-notes/A-tight-conditioning-fails.md` item 3 and in the first-round reports, so it has propagated.

*Fix:* "The full excess needs $a=a_n\to0$; with $a_n\to0$ arbitrarily slowly, $N_0=O(n\log^2n/a_n^2)=n^{1+o(1)}$ (../research-notes/A-tight-conditioning-fails.md Theorem 4.4); Corollary 4.5's particular choice gives $O(n^{5/3}\log^2n)$."

**m5. Remark 8, success bullet (line 339).** "Against a fixed competitor $g$ (fixed $m$, $B$, $d$)" is followed by "on the cube family, where $d=\log_2n$". On the cube family $d$ grows.

The conclusion is unaffected:

- for the relevant competitor $g\equiv0$, $E_*=U=0$;
- for any fixed $(m,B)$, $E_*/n=O(d^2B^2/n)\to0$ when $d=o(\sqrt n)$.

*Fix:* "fixed $m,B$, and $d\le n$", or state it for $g\equiv0$.

**m6. Remark 5's title (line 238) and the §0 "Weakened" bullet (line 18).** Both say the original clause "holds for $\alpha<1/8$". The original clause asserted the rate $O(n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\log n})$. With Hoeffding, what holds for $\alpha<1/8$ is only its conclusion "polynomially small", at the slower rate $O(n^{4\alpha-1/2}\sqrt{\ell_\delta}+n^{\alpha-1/2}\sqrt{\ln n})$, as Remark 5's own body says.

*Fix:* "the clause's conclusion 'polynomially small' holds for $\alpha<1/8$, at rate $n^{4\alpha-1/2}$; its stated rate does not follow."

**m7. The §7.3 replacement text for A2 (line 347).** It has three gaps:

- **(i)** Its second sentence ("At learner width $\lceil n^\alpha\rceil$ … $O_{L,\alpha,\delta}(n^{2\alpha-1/2})$") omits the hypotheses $d\le n^\alpha$ and $X\subseteq[-1,1]^d$.
- **(ii)** Corollary 3(iii) needs $B_0\ge1$. This is harmless: replace $B_0$ by $\max\{B_0,1\}$.
- **(iii)** "Repository architecture" is missing.

Also, the A2 paragraph contains three sentences that depend on Proposition 6.1: the $N\le n^{1/2-\epsilon}$ sentence, "So A refutes width-uniform …", and "It does not refute … true for $\alpha<1/4$". "Replace the two sentences" should say which two.

**m8. Theorem 4, last sentence (line 303).** "'With probability at least $1-\delta/2$' and 'for all $\sigma<\sigma_0$' can be taken in either order." For the triple event of Theorem 1(b) the probability is $1-3\delta/4$.

*Fix:* "with the probability of $\mathcal E$".

**m9. §9, "The perturbation bound is loose" (line 425).** The check quoted there ("at most $0.49$ of the closed form") understates how tight the bound can be. A projected sign-gradient search reaches $0.90$ of the sharper form and $0.64$ of the closed form, at $H=1$, $d=3$, $N=2$, $K=60$ (`check_lemmas_AC.out`). There the first-layer term alone nearly saturates the bound. This is harmless, since the constant enters only through a logarithm. Only the description "loose" needs softening.

**m10. Corollary 3(i), line 216.** "At most $C\,n^{-\kappa}$ for every $\kappa<\frac12-2\alpha$" is weaker than what is proved. The next sentence, and §0, correctly give $O_{L,\alpha,\delta}(n^{2\alpha-1/2})$, that is, $\kappa=\frac12-2\alpha$ itself. Harmless, but it reads as if a logarithm were lost.

**m11. Remark 7's "critical exponent".** The definition "the supremum of the $\alpha$ for which the worst-case excess over such laws tends to 0" should name its terms:

- the predictors: clipped near-minimizers, the clipped Gibbs risk, and the posterior mean of clipped outputs;
- the mode: for each fixed $\delta$, the $(1-\delta)$-quantile over samples, with the sup over laws taken outside.

The window holds under this reading: the success side is uniform in $D$, and the failure side holds for every sample. The set of good $\alpha$ need not be an interval, but its supremum is well defined and lies in the stated window.

**m12. Citation.** In Lemma E(ii), "Boucheron, Lugosi and Massart, Ch. 2" should be "Theorem 2.10 / Corollary 2.11". Trivial.

I found no circularity, no misapplied lemma and no hidden assumption about clipping, label range, widths, weight bounds, measurability or existence of minimizers in the proof itself.

---

## 4. Corrected statement (strongest version I can support)

> **Proposition 6.1 (corrected; `../research-notes/small-learner-width.md` Corollary 3(i) with Theorem 4).**
>
> **Setting.**
> - Let $c=1$, $L=H+1\ge2$, $0<\alpha<\frac14$, $n\ge2$, $\delta\in(0,1)$ and $1\le d\le n^\alpha$.
> - Let $X\subseteq[-1,1]^d$ be compact and $D$ any Borel law on $X\times[-1,1]$.
> - Run SP$_1$ at learner width $N=\lceil n^\alpha\rceil$, with $n$, the sample and $N$ fixed before $\sigma\downarrow0$.
> - Let $\mathcal G_n$ be the depth-$L$ networks of the repository architecture (tanh hidden layers without internal biases, input $\bar x=(1,x)$, linear readout without bias) with width at most $N$ and all weights in $[-n^\alpha,n^\alpha]$.
>
> **Conclusion.** With probability at least $1-\delta/2$ over the sample, every $w\in\mathcal N_1$ satisfies
> $$L_D(\operatorname{clip}z_w)\le\min_{\mathcal G_n}L_D+5\sqrt2\,n^{2\alpha-\frac12}\sqrt{\ln\tfrac4\delta}+4\sqrt{(2H+1)(H+5)}\,n^{\alpha-\frac12}\sqrt{\ln2n}+(8L-1)\bigl(1+\ln\tfrac4\delta\bigr)n^{4\alpha-1}.$$
> On the same event, the same bound holds for $\limsup_{\sigma\downarrow0}\mathbb E_{\Pi_\sigma}L_D(\operatorname{clip}z_w)$ and for $\limsup_{\sigma\downarrow0}L_D(\mathbb E_{\Pi_\sigma}\operatorname{clip}z_w)$. It does not cover $\operatorname{clip}(\mathbb E_{\Pi_\sigma}z_w)$ or unclipped predictors. The excess is $O_{L,\alpha,\delta}(n^{2\alpha-1/2})$.
>
> **Not established.** The rate $O(n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\log n})$ is not established. With the Hoeffding competitor term of the original display, only $\alpha<\frac18$ is obtained, at rate $n^{4\alpha-1/2}$.
>
> **Width window** ($L\ge3$, $c=1$, clipped predictors):
> - *Success* against every fixed competitor, for every $D$, when $N(N+d)\ln n=o(n)$; for example $N=o(\sqrt{n/\ln n})$ on the cube family.
> - *Failure* on the cube family with $n/2^d\to\lambda$, at every $N\ge O(n\log^2n/a^2)$, with excess $\ge(\sqrt{\beta(\lambda)}-a\sqrt\lambda)_+^2-o(1)$. The full $\beta(\lambda)-o(1)$ is certified at every $N\ge\omega_n\,n\log^2n$ for any $\omega_n\to\infty$.
> - *In between,* and as to monotonicity in $N$, nothing is proved.
>
> **Critical exponent** (for learner width $\lceil n^\alpha\rceil$ against $\mathcal G_n$, at $c=1$): it lies in $[\frac14,\frac L{2(2L-1)}]$.

---

## 5. Scripts (`../checks/verify-RT-width-logic-revised/`)

| script → output | what it checks | result |
|---|---|---|
| `check_cor3.py` → `.out` | (1) exact $\mathrm{Exc}$ of (5.1) against (5.2), coded from §1, on 40,000 random admissible cases ($n$ from 2 to $10^{200}$, $0\le\alpha<\frac12$ including the endpoints, $H\le10$, all admissible $d$, $N$ and $\bar B$, $\delta$ from $10^{-12}$ to $0.999$); $\Lambda_N\le(H+5)\ln2n$; $\Lambda_N\ge\ln2n$. (2) Remark 5 sandwich. (3) Remark 8 vacuity threshold, and $\mathrm{Dev}_N$ on the cube family | (1) max ratio $0.664$; max $0.631$; min ratio $2.0$. (2) no violation. (3) no violation; $\mathrm{Dev}_N\approx0.1$ at $N=0.02\sqrt{n/\ln n}$ for every $n$ from $10^9$ to $10^{40}$ |
| `check_bernstein.py` → `.out` | Lemma E(ii) against exact binomial tails (792 two-point cases, $p$ down to $10^{-9}$) and exact three-point convolutions (1,680 cases); the Bernstein event of Theorem 1(b) for the Remark 6(b) competitor | max tail$/\delta'$: $0.56$ and $0.12$; failure at most $0.14\cdot\delta/4$ |
| `check_lemmas_AC.py` → `.out` (+ `probe_lemmaC_worst.py`) | Lemma C under adversarial projected sign-gradient perturbations (600 nets at energy exactly $K$, $1\le H\le4$); Lemma A clone exactness and energy | no violation; max $0.90$ of the sharper form and $0.64$ of the closed form, at $H=1$; clone error $4\cdot10^{-15}$, $\kappa/E_*\le0.64$ |
| `check_A_width.py` → `.out` | `../research-notes/A-tight-conditioning-fails.md` (4.3) at $c=1$, $\lambda=1$, $\delta=0.01$, for three accuracy schedules; $N_0/(n\log_2^2n)$ | with $a_d=1/\log_2d$ the certified excess rises toward $\beta(1)$, while $N_0/(n\log^2n)$ grows only like $(\log\log n)^2$; supports m4 |
| `check_remark7.py` → `.out` | `../research-notes/B-tempered-likelihood.md` Lemma 9.2 chain network built exactly ($m=\lfloor n^\alpha\rfloor$, $B=n^\alpha$); sign of $\log\eta$ across $\alpha=L/(2(2L-1))$ for $L=2,3,4,6$ | the network fits $D_{\delta_0}$ to $10^{-60}$ with weights $\le B$; the sign changes exactly at the threshold |
| `check_bestinclass_fluct.py` → `.out` | Remark 6(c) probe: box-constrained minimization of $L_D$ over $\mathcal G_2(1,m,B)$ for a steep three-point law | in 4 of 5 settings the best-in-class overshoot is $0.33$–$0.69$ of $\bar U$ at the rare point, with $\mathrm{sd}/\bar U$ between $0.07$ and $0.26$; in the fifth there is no overshoot; inconclusive, so (c) stays open |

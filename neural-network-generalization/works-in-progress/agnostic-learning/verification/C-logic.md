# Referee report on `../research-notes/C-fixed-temperature-bayes.md` (Claim C): logic and definitions

**Lens.** I checked quantifiers, limit order, case splits and definitions against `../research-notes/problem-brief.md` and the cited repository sources. I looked for circularity, misapplied lemmas, missing hypotheses (widths, weight bounds, clipping, measurability, existence of minimizers), and steps that assume what they set out to prove.

**Verdict: minor fixes.** I checked every step of every numbered result in ../research-notes/C-fixed-temperature-bayes.md:

- Lemmas C.2.1 and C.2.2, Theorem C.1 (both parts) and the remarks after it;
- the cloning facts of §C.3.1, Lemma C.3.1 with its full proof in Appendix C.A (Steps 1–5), and Lemma C.3.2;
- Theorem C.2, Corollaries C.2.1 and C.2.2 (including the majorant (C.4.2)), and Remarks C.4.1–C.4.2;
- Propositions C.3 and C.4, with Appendix C.B;
- Lemma C.6.1 (Steps 0–4), Theorem C.5 (a)–(d), and Remarks C.6.2–C.6.4;
- Theorems C.6 and C.7 and the remarks of §C.7.

Both halves of Claim C hold as the theorems state them, with the quantifier and limit order the brief asks for:

- **Positive.** For FIX$_\eta$ with $0<\eta\le1/8$ under $\mu_{N,\gamma}$ ($\gamma\ge1$), the progressive mixture of posterior means of *clipped* outputs satisfies (C.4.1) for every $D$, every competitor of width $m\le N$, and every $\rho\in(0,1]$. The sample size is polynomial in $d,m,B,1/\varepsilon$ and in $N$. High-probability versions are Theorems C.6–C.7.
- **Negative.** For every $\gamma>0$ and every $\eta>0$, on every sample, the posterior means are uniformly $O\bigl(N^{-\gamma}(\eta n+\sqrt{\eta n})\bigr)$. So for the constant target the excess tends to $1$ as $N\to\infty$ at fixed $n$, which refutes the width-uniform (brief §1) formalisation for this learner.

I found no circularity and no misapplied lemma, and the main chain uses no unstated hypothesis. Every cited statement matches its source (Section 1).

All ten issues in Section 3 are minor:

- one claim listed under "proved" is overstated (sharpness "up to $A_L$", issue 1);
- the predictors are defined differently from the brief (issue 2). Clipped outputs are used where the brief's BMA and Gibbs predictor use $z_w$. The unclipped variants are not covered, and for an arbitrary prior Theorem C.1 is **false** for them;
- several summary sentences are imprecise (issues 3–10).

Scripts and outputs for my independent checks are in `../checks/verify-C-logic/` (Section 4).

---

## 1. Statements compared against the sources

| ../research-notes/C-fixed-temperature-bayes.md | source (opened and compared) | match |
|---|---|---|
| network, $\bar x=(1,x)$, no internal biases, linear readout (§C.1.2) | `paper.tex` §2, lines 113–122 | yes. The source has $X$ in the unit ball; the cube case comes from Remark `cube`, lines 225–232 |
| energy $\kappa_N$ | `paper.tex` eq. `energy`, lines 293–296 | yes |
| coordinate law $\nu$ ($m,M$ renamed $m_\nu,M_\nu$) | eq. `law`, lines 151–153 | yes |
| strong scales (C.1.2); $\mu_{N,\gamma}=\mu^N_{N^{-\gamma/2}}$ | eqs. `strong-scales`, `finite-scales`, lines 160–170 | yes. For Gaussian $\nu$, $\kappa_N=\sigma^2\lVert\Xi\rVert^2$ gives density $\propto e^{-\kappa_N/(2\sigma^2)}$, which is the brief's $\mu_\sigma$ |
| eq. `subgaussian` (conditioning on a symmetric convex set) and eq. `translation` | lines 310–335 | yes, verbatim up to notation. ../research-notes/C-fixed-temperature-bayes.md's two-line Gaussian proof of `translation` (Appendix C.A, Step 4) is correct |
| cloning, $E_*=d(d+1)B^2+2(L-1)m^2B^2$ | §3, lines 297–308, eq. `teacher-energy` | yes. ../research-notes/C-fixed-temperature-bayes.md adds the operator-norm and readout facts, which I re-derived (Section 2.2) |
| Lemma C.3.1 at $\sigma^2=N^{-\gamma}$, with $A_L$ of (C.3.2) | Prop. `tube`, lines 339–346; proof lines 347–404; eq. `A`, lines 399–401 | yes, with $C\to m$, $\eta\to h_\rho$, $c_m\to c_\nu$. The source says each normalized group sum "has variance at most $1/m$" (line 356); the variance is exactly $1$. ../research-notes/C-fixed-temperature-bayes.md uses $1$, which gives the same $c_\nu$, so the source's slip is harmless. ../research-notes/C-fixed-temperature-bayes.md's net bound drops the source's factor $2$, correctly, because the maximum is one-sided |
| fan-in prior $\mu^{\rm fi}_N$ (variances $1/D_0$, $1/N$) | `slt-finite-sample/README.md` §1, lines 13–29 | yes. The README assumes $L\ge3$; Appendix C.B covers $L\ge2$, and I checked the $L=2$ case |
| $\mathrm{KL}(q_t\Vert\mu^{\rm fi}_N)=E^{\rm fi}_N+\frac{Q_N}2(t-1-\log t)$; $\sup_x\mathbb E_{q_t}\lvert z_w-g\rvert^2\le A^{\rm fi}t$ | same README §3, lines 107–158 | yes. ../research-notes/C-fixed-temperature-bayes.md's $A^{\rm fi}$ is the README's $A_L$; the rename avoids a clash with the tube constant |
| quote "For the fixed-width strong-prior family, the corresponding bound is $\mathbb Ez_w(x)^2\le\sigma^2$"; TV convergence for every $\gamma>0$; "does not prove failure of the sign of the posterior mean" | `slt-likelihood/README.md` §3, lines 197–215 | verbatim (lines 204 and 215) |
| quote "pays a width-dependent $N^\gamma$ factor" | `slt-likelihood/README.md` §4, lines 289–304 | verbatim (line 304). That learner uses the **unclipped** likelihood $\exp[-\beta\sum_i(z_w-f)^2]$ (line 289); see issue 5 |
| observation variance $N^{-\gamma}$, i.e. $\eta=N^\gamma/2$ | `slt-likelihood/README.md` §2 "Finite scales", line 100 | yes |
| main result 4: weights eq. `weights`, margin and sign conditioning, $F_N(S)$, Theorem `thm:main`, width-first remark | `subcritical-exponential.tex` lines 104–108, 109–113, 115–121, 127–137, 139–145 | verbatim; the line numbers are correct |
| parity circuit: width $k+1$, $A=\log(16(k+1))$, error $<1/8$, weights $O(k\log k)$, margin passing at depth $\ge3$ | `parity-circuit.tex` (Appendix `sec:paritycircuit`) | yes. The $\varepsilon'$ modifications of Remark C.4.1 are ../research-notes/C-fixed-temperature-bayes.md's own (issue 6) |
| main result 4 summary; standard-NNGP side result | `NNG/README.md` lines 49–57; `side-results/standard-nngp-parity/README.md` "Results" | yes |
| FIX$_\eta$ posterior $\propto\mu(dw)e^{-\eta\sum_i(\operatorname{clip}z_w(x_i)-y_i)^2}$ | `../research-notes/problem-brief.md` §2 | yes |
| predictors: BMA $=\int\operatorname{clip}z_w\,d\Pi_t$, Gibbs risk $\int L_D(\operatorname{clip}z_w)\,d\Pi_n$ | `../research-notes/problem-brief.md` §2: "posterior mean of `z_w` (BMA)", "Gibbs (random posterior draw)" | **no**; ../research-notes/C-fixed-temperature-bayes.md uses clipped outputs (issue 2) |
| Claim C's displayed inequality $\mathbb E L_D\le L_D(g)+4\rho+A_LN^\gamma/(\eta(n+1))$ | `../research-notes/problem-brief.md` §4, Claim C | yes; it is (C.4.1) |

---

## 2. Audit of the main chain

### 2.1 Definitions, quantifiers and limit order

- **Order of choices.** $L,\gamma,\nu,\eta$ are fixed first, then $N$ and $n$. Next come $d$, $X$ and $D$, then the competitor $g$ and $\rho$, and finally the comparison measure $Q=\mu(\cdot\mid U_\rho(g))$, which depends on $g$ and $X$ but not on $S$. The expectation is over $S\sim D^{\otimes n}$. This matches C.1.4 and the brief.
- **Learner independence.** In Corollary C.2.2 the learner (prior $\mu_{N_n,\gamma}$, width $N_n=\lceil n^\alpha\rceil$, predictor $\bar f_n$) depends only on $(n,\alpha,\gamma,\eta,d,L,\nu)$. It does not depend on $D$ or $g$, so the infimum over $g$ is legitimate.
- **Limits.** In Proposition C.3(b) the sample, $n$, $\eta$ and $N$ are fixed, and then $\sigma\downarrow0$. In Theorem C.5, $n$, $\eta$ and the sample are fixed, and then $N\to\infty$. Every bound used in these limits is deterministic and does not depend on the sample, so the limits are uniform over samples, as claimed.
- **Negation of the brief's §1 formalisation.** Take any $p$ that does not depend on $N$, and set $d=m=1$, $B=2$, $\varepsilon=1/4$, $\delta=1/2$ and $n\ge p(\cdot)$. Choose $N$ with $\beta_N=N^{-\gamma}(4k_n+\sqrt{2k_n})\le1/8$. By Theorem C.5(c), $L_D(\bar f_n)\ge3/4>L_D(g_1)+\varepsilon$ on every sample. The quantifier order is the brief's: $N$ ranges over all $N\ge m$ after $n$ is fixed.

### 2.2 Step-by-step

**Lemma C.2.1.** We have $\psi_y''=2\eta(2\eta(p-y)^2-1)\psi_y$. For $\eta\le1/8$ and $p,y\in[-1,1]$, $(p-y)^2\le4$ gives $\psi_y''\le0$. For $\eta>1/8$, $\psi_1''(-1)>0$. Both directions hold. ✓

**Lemma C.2.2.** Three points need checking:

- $\int(\log p)^-dQ\le1/e$ and $\mathrm{KL}<\infty$ give $\log p\in L^1(Q)$;
- Jensen's inequality on $\{p>0\}$ is valid;
- the case of $h$ bounded below follows by truncating to $h\wedge k$, using monotone convergence on the left and $\int e^{h\wedge k}d\mu\le\int e^hd\mu$ on the right.

The equality case is correct. ✓

**Theorem C.1.**

- *(a), one step.* The image of $\Pi_t$ under $w\mapsto\phi_w(x_{t+1})$ is a law on $[-1,1]$ with mean $\hat f_t(x_{t+1})$. Jensen's inequality for the concave $\psi_{y_{t+1}}$ needs $y_{t+1}\in[-1,1]$ and $\eta\le1/8$, and both are hypotheses.
- *(a), telescoping and comparison.* Telescoping uses $Z_0=1$. The comparison is (C.2.1) with the bounded $h=-\eta\sum_{i\le T}\ell_i$. ✓
- *(b), ghost sample.* $\hat f_t$ is a Borel function of $(x,S_t)$ (§C.1.3: a ratio of integrals of bounded, jointly measurable functions). So by Fubini, $\mathbb E(\hat f_t(x_{t+1})-y_{t+1})^2=\mathbb E\,L_D(\hat f_t)$. For the comparison term, $Q$ is fixed and Tonelli applies. Convexity of $L_D$ gives (C.2.5).
- *(b), closed form.* The infimum is (C.2.2) applied to $h=L_D(\phi_\cdot)\in[0,4]$, which is measurable in $w$ by Tonelli. The minimiser $\propto e^{-\eta(n+1)L_D(\phi_w)}\mu$ does not depend on $S$, so the infimum over sample-independent $Q$ equals the unrestricted infimum. ✓
- *Remark 2.* For (i), $T$ is independent of $S$. For (ii), exchangeability of $S$ and convexity give the claim. ✓

**§C.3.1 (cloning).**

- *Energy.* The per-layer bounds are $\frac dN\sum_jk_j\lVert T^1_j\rVert^2\le d(d+1)B^2$, $\sum_{j,k}T_{jk}^2k_j/k_k\le2m^2B^2$ and $N\sum_ju_j^2/k_j\le2m^2B^2$.
- *Operator norm.* $W^\ell_*=U\,\mathrm{diag}(k)^{1/2}\,T^\ell\,\mathrm{diag}(k)^{-1/2}\,U^{\mathsf T}$, with $U=[u_1,\dots,u_m]$ orthonormal. Hence $\lVert W^\ell_*\rVert_{\rm op}\le\sqrt{\max k/\min k}\,\lVert T^\ell\rVert_{\rm op}\le\sqrt2\,mB$.
- *Group sizes.* $N\ge m$ gives $\lfloor N/m\rfloor\ge1$ and $\lceil N/m\rceil\le2\lfloor N/m\rfloor$, so $N/\min_jk_j\le2m$.

All three hold. ✓

**Lemma C.3.1 and Appendix C.A.**

- *Step 1.* The constraints are $N(d+1)+N+(L-2)Nm$ linear forms in pairwise disjoint coordinates. Each form is even and log-concave (Prékopa), with variance $1$. Chebyshev's inequality with $R=2\max\{1,m_\nu^{-1/2}\}$, together with monotonicity of an even log-concave density in $|y|$, gives $\mathbb P(|Y|\le s)\ge\frac{s}{R}\cdot\frac34=c_\nu s$ for $0<s\le1$. Here $s\le h\le1/2$. ✓
- *Step 2.* Since $\langle Za,b\rangle=\langle\zeta,ba^{\mathsf T}\rangle$ with $\lVert ba^{\mathsf T}\rVert_F=1$, eq. `subgaussian` applies conditionally on the symmetric convex set $\mathcal C$. The two $1/4$-nets of size $9^N$ give $\lVert Z\rVert_{\rm op}\le2\max\langle Za,b\rangle$. Then $81^Ne^{-m_\nu q^2N/2}=(4L)^{-N}$, and a union bound over $L-2$ layers gives $\mathbb P_{\mathcal C}(E)\ge3/4\ge1/2$. $E$ is symmetric. ✓
- *Step 3.*
  - Layer 1: $\sigma\sqrt{N/d}\,s\,\lVert\bar x\rVert_1\le(t/\bar t)\,h(d+1)/\sqrt d$.
  - Internal layers: $(W^\ell-W^\ell_*)h^{\ell-1}_*=\sigma\zeta^\ell Ph^{\ell-1}_*$, and $\lVert\zeta^\ell P\rVert_F^2=\sum_{i,j}\langle\zeta^\ell_{i,*},u_j\rangle^2\le Nms^2$, which gives $e_\ell\le ae_{\ell-1}+\sqrt m\,h$.
  - Readout: the error is at most $\sqrt2mB\,e_{L-1}+ts\le\sqrt2mB\,e_{L-1}+h$.
  - Recursion: $\sqrt m\,a^k\le A_0^{L-2}$. The total is at most $hP_0(\bar t)=\rho/2$. The case $L=2$ is handled. ✓
- *Step 4.* $\lVert\Xi_*\rVert^2=\kappa_N(w_*)/\sigma^2\le E_*/\sigma^2$, and translation applies to the symmetric set $E$. ✓
- *Step 5.* For $\bar t\ge1$: $A_0(\bar t)\le\bar tA_0(1)$ and $P_0(\bar t)\le\bar t^{L-2}P_0(1)$. ✓
- *"In particular."* $\sigma^2\le1/N$ makes $\log^+(\sigma\sqrt N)=0$, $N\le\sigma^{-2}$ and $1\le\sigma^{-2}$, and $\log\frac1{c_\nu h_\rho}\ge\log\frac{16}3>0$. ✓
- *Majorant (C.3.3).* $P_0\le3(mB)^{L-1}(d+L+1)(5+b_0)^{L-2}$ uses $mB\ge1$, and $2\cdot3/(3/8)=16$. ✓

**Lemma C.3.2.** The identity is $(a-y)^2-(b-y)^2=(a-b)(a+b-2y)$, with $|a+b-2y|\le4$ and $|a-b|\le|z_w-g|<\rho$. The Minkowski form is also correct. ✓

**Theorem C.2 and Corollary C.2.1.** Take $Q=\mu_{N,\gamma}(\cdot\mid U_\rho)$. Then $\mathrm{KL}=-\log\mu(U_\rho)\le A_LN^\gamma$; $U_\rho$ is open, hence Borel, with positive mass. Combined with Lemma C.3.2 this gives (C.4.1). With $\rho=\varepsilon/8$ the condition on $n$ follows. The refined $\min\{4\rho,\,2\rho\sqrt{L_D(\operatorname{clip}g)}+\rho^2\}$ is correct. ✓

**Corollary C.2.2.**

- $A_L$ is nondecreasing in $m$ and $B$, through $E_*$, the bracket and $P_0$.
- An integer $m\le n^\alpha$ satisfies $m\le\lfloor n^\alpha\rfloor\le N_n\le2n^\alpha$.
- $B=n^\alpha\ge1$.
- The majorant uses $\alpha\le1$, so $mB\le n^2$. It also uses $E_*\le2Ld^2n^{4\alpha}$, bracket $\le(L+1)dn^\alpha$, and $\Lambda_L\le K_1\log(dn)$ with $\log(dn)\ge\log2$.
- Finally, $4/n\le1/(2\eta n)$ by $\eta\le1/8$.

So $K=2^\gamma K_2+1/(2\log2)$. ✓ The separate-exponent remark is also correct: $A_L=O(d^2n^{2a+2b}\log(dn))$.

**Proposition C.3.**

- (a) is Theorem C.2 with Lemma C.3.1 at scale $\sigma$.
- (b) is Lemma C.6.1 with $s=\sigma N^{-1/2}$, followed by Pinsker. The Gibbs-risk identity $\int L_D(\phi_w)\,d\Pi_n-L_D(0)=\mathbb E_D\bigl[\int\phi_w^2\,d\Pi_n-2y\hat f_n\bigr]$ follows from Fubini.
- (c) is arithmetic (see issue 9 for one sentence).

The "Relation to SP$_c$" paragraph is also correct: $\eta\le1/8$ is equivalent to $\sigma^2\ge4/c$. ✓

**Proposition C.4 and Appendix C.B.**

- The per-coordinate KL is $\alpha^2/(2\varsigma^2)+\frac12(t-1-\log t)$, and nonzero means sit only on selected coordinates.
- The recursion $r_\ell\le m^2B^2r_{\ell-1}+t$ holds because the noise $\epsilon_{ij}$ on the incoming edges of selected neurons is independent of earlier layers, and the unselected neurons enter only through $\lVert h^{\ell-1}\rVert^2\le N$.
- $t=\rho^2/A^{\rm fi}\le1$.
- $(\phi_w(x)-y)^2\le(g(x)-y)^2+4|z_w(x)-g(x)|$ holds for **every** $w$, after which Cauchy–Schwarz in $q_t$ applies.
- $t-1-\log t\le\log(1/t)$ for $t\le1$.

All checked. ✓

**Lemma C.6.1.** I checked every step.

- *(P1)–(P4).* (P1) uses eq. `subgaussian` coordinatewise, conditionally on the hidden weights, with $\sum_ja_j^2\le Ns^2$ because $|h_j|\le1$. (P3) uses evenness of $\nu$, independence of $\xi$ from the hidden weights, and oddness of clip. (P4) uses $\cosh(\theta\phi)\le\cosh(\theta z)$.
- *Step 1.* $\mathrm{KL}=-\int\ell\,d\Pi_t-\log Z_t$ and $-\log Z_t\le\int\ell\,d\mu$. The constant $\ell^0$ cancels.
- *Step 2.* (C.2.1) is applied to the bounded functions $\pm\theta\phi_w(x)$, with the case $\mathrm{KL}=0$ handled separately.
- *Step 3.* The root is
  $$F\le b\eta t+\sqrt{(b\eta t)^2+b\eta t\sigma_{\rm out}^2}\le2b\eta t+\sigma_{\rm out}\sqrt{b\eta t},$$
  with $b\eta t=2\sigma_{\rm out}^2k$.
- *Step 4.* $\mathbb E e^{G^2/4}=\sqrt2$, and (C.2.1) holds for the bounded-below $h=\lambda z^2$.

No property of $\eta$ is used beyond $\eta>0$. ✓ My quadrature check in the extremal case $|h|\equiv1$ found no violation (Section 4).

**Theorem C.5.**

- (a): the bounds increase in $t$, and $\bar f_n$ averages $\hat f_0,\dots,\hat f_n$.
- (b): as in Proposition C.3.
- (c): $c_\ell\downarrow u^*\in(0.957,0.958)$, so the readout satisfies $1/c_{L-1}<1.05$. Also $(1-\beta)_+^2\ge1-2\beta$, Jensen's inequality applies to the Gibbs risk, and $16+4\sqrt2<22$.
- (d): the arithmetic is correct, but its interpretation is overstated (issue 1). ✓

**Theorem C.6.**

- *Martingale part.* $\Delta_t$ lies in an $\mathcal F_t$-measurable interval of length $4$. The conditional Hoeffding lemma gives $e^{2s^2}$; then take $s=u/(4n)$ and $u=\sqrt{8n\log(1/\delta)}$.
- *Comparison part.* Hoeffding applies with the same $u$.
- *Combination.* $2u/n=4\sqrt{2\log(1/\delta)/n}$.
- *$\bar f_n$.* The bound for $\bar f_n$ follows from $L_D(\hat f_n)\le4$.
- *User's formulation.* The near-minimiser $g^\star_n$ depends only on $(D,n)$. ✓

**Theorem C.7.**

- *Uniform deviation.* For each $w$, Hoeffding's lemma gives $\mathbb E_Se^{\lambda(R-\hat R)}\le e^{2\lambda^2/n}$. Tonelli and Markov then make the deviation bound hold on one event, for every $Q'$ at once, including $\Pi_n$.
- *Chain.* The rest is Gibbs optimality from (C.2.2), the bound for the fixed $Q$, and the chain.
- *Choices.* The arithmetic of choices (i) and (ii) is correct, as is Remark 1 with $\delta=1/n$. ✓

### 2.3 Missing-hypothesis checklist

| hypothesis | where needed | supplied? |
|---|---|---|
| labels in $[-1,1]$ | Jensen step; $\ell_i\in[0,4]$; Hoeffding ranges | yes (§C.1.1) |
| predictions in $[-1,1]$ | Jensen step; Hoeffding ranges in C.6–C.7 | yes, by clipping in both the likelihood and the predictor. This is **essential** (issue 2) |
| $\eta\le1/8$ | Theorems C.1, C.2, C.6; Corollaries C.2.x; Propositions C.3(a), C.4 | yes. Lemma C.6.1 and Theorems C.5, C.7 need only $\eta>0$, as stated |
| $N\ge m$ | cloning, Lemma C.3.1 | yes, in every statement that uses it |
| $B\ge1$ | (C.3.3) ($mB\ge1$); Corollary C.2.2 ($n^\alpha\ge1$) | yes |
| $\sigma^2\le1/N$ (e.g. $\gamma\ge1$) | "in particular" of Lemma C.3.1 | yes. Remark C.4.2 uses (C.3.1) directly for $\gamma<1$ |
| $\gamma>0$ | Theorem C.5 | yes |
| $X\subseteq[-1,1]^d$ compact | $\lVert\bar x\rVert_1\le d+1$, $\lVert\bar x\rVert_2^2\le d+1$; openness of $U_\rho$ | yes |
| $\mu(U_\rho)>0$ | definition of $Q$ | yes (Lemma C.3.1) |
| $Q$ independent of $S$ | Theorems C.1(b), C.6, C.7 | yes |
| joint measurability | Fubini and Tonelli | yes (continuity of $(w,x)\mapsto z_w(x)$) |
| competitor class matches the learner architecture | cloning | yes: same depth, tanh, first-layer biases only, linear readout |
| existence of minimisers | — | not needed; no minimiser is used |

---

## 3. Issues

Severity is judged relative to Claim C. None of the issues touches the proofs of Theorems C.1, C.2, C.5, C.6 and C.7.

1. **Sharpness overstated (minor; listed as "proved").** Three places claim more than Theorem C.5(d) proves:
   - C.0 item 4: "the dependence of item 2 on $N^\gamma/(\eta n)$ is sharp up to the factor $A_L$";
   - Theorem C.5(d), last sentence: "cannot be improved, except in the factor $A_L$";
   - C.9: "the $N^\gamma/(\eta n)$ dependence of Theorem C.2 is sharp up to $A_L$".

   What (d) proves concerns one instance ($y\equiv1$, competitor $g_1$) and one excess level ($1/2$). The width $N_c$ at which the excess crosses $1/2$ satisfies
   $$\frac{\eta(n+1)}{4A_L(d,1,2,1/16)}\le N_c^\gamma\le4\bigl(4k_n+\sqrt{2k_n}\bigr),$$
   a window of ratio about $64A_L/m_\nu$ when $k_n\ge1$. This locates the transition $N^\gamma\asymp\eta n$. It does **not** show that the form of the complexity term cannot be improved below the threshold. For example, an excess bound $\Phi(A_LN^\gamma/(\eta n))$ with $\Phi(u)=u^2$ is consistent with everything proved. It also says nothing about competitors of larger complexity, where the factor would be $A_L(d,m,B,\rho)$ and not $A_L(d,1,2,1/16)$. The window also carries a factor $1/m_\nu$ that is not mentioned.

   *Fix.* Say instead: "the width threshold $N^\gamma\asymp\eta n$, at which the bound of item 2 becomes nontrivial, is attained by the constant target, up to a factor $O(A_L(d,1,2,1/16)/m_\nu)$".

2. **The predictors differ from the brief's definitions; the unclipped variants are not covered, and for an arbitrary prior Theorem C.1 is false for them (minor, definitional).** The brief (§2) lists "Gibbs (random posterior draw), posterior mean of `z_w` (BMA), progressive mixture (average … of posterior means)". ../research-notes/C-fixed-temperature-bayes.md (§C.1.3) uses clipped outputs throughout:
   - its BMA is $\hat f_t=\int\operatorname{clip}z_w\,d\Pi_t$;
   - its progressive mixture averages these;
   - its Gibbs risk is $\int L_D(\operatorname{clip}z_w)\,d\Pi_n$.

   C.0 and §C.1.3 also say that $\bar f_n$ "is the brief's $\hat f_n$". The brief never uses the symbol $\hat f_n$, and inside ../research-notes/C-fixed-temperature-bayes.md $\hat f_n$ denotes the final BMA, so the phrase points to nothing and collides with ../research-notes/C-fixed-temperature-bayes.md's own notation.

   The deviation matters:
   - (a) No positive result covers the unclipped variants: $\int z_w\,d\Pi_t$, its progressive mixture, $\operatorname{clip}(\int z_w\,d\Pi_t)$, and $\int L_D(z_w)\,d\Pi_n$. This holds for Theorems C.1, C.2, C.6, C.7, Corollaries C.2.1–C.2.2 and Propositions C.3(a), C.4.
   - (b) For an arbitrary prior, which is the scope of Theorem C.1, the conclusion is **false** for the unclipped mean and for its clipping. Take $\Theta=\{w_1,w_2\}$, $\mu$ uniform, $z_{w_1}\equiv M$, $z_{w_2}\equiv-1$, $y\equiv-1$, $\eta=1/8$, and $Q=\delta_{w_2}$. The right side of (C.2.5) is at most $\log2/(\eta(n+1))$, which is $5.5\cdot10^{-3}$ at $n=1000$. The unclipped progressive mixture has loss:
     - $2.71$ at $M=10^3$, $n=1000$;
     - $2.7\cdot10^6$ at $M=10^6$, $n=1000$.
     Its clipping has loss $4$ at $M=10^3$, $n\le100$. The one-step inequality in (C.2.3) already fails at $t=0$: $30.25$ against $1.75$ at $M=10$ (script `check_unclipped_counterexample.py`). So clipping the predictor is necessary, not a convenience. Remark 3 after Theorem C.1 says only that "the argument does not cover" $\operatorname{clip}(\int z_w\,d\Pi_t)$. For the network priors the unclipped variants are open.
   - (c) The negative results extend to the unclipped predictors, by Lemma C.6.1(iii) and Cauchy–Schwarz. Put $\Sigma=\sup_x\int z_w(x)^2\,d\Pi_n$. Then
     $$\sup_x\Bigl|\int z_w\,d\Pi_n\Bigr|\le\Sigma^{1/2},\qquad\Bigl|\int L_D(z_w)\,d\Pi_n-L_D(0)\Bigr|\le\Sigma+2\Sigma^{1/2},$$
     and $\Sigma\to0$.

   *Fix.*
   - In C.0 and §C.1.3, state that all three predictors use clipped outputs and that this departs from the brief's BMA and Gibbs predictor.
   - Delete "the brief's $\hat f_n$".
   - Add (a) to the C.9 list of results not proved, with the two-point example.
   - Add (c) to Theorem C.5.

3. **"Every predictor tends to 0 uniformly" (minor).** This appears in C.0 item 3 and in the sentence after Theorem C.5(b); Proposition C.3(b) itself is precise. The Gibbs predictor is a random function. What is proved for it is $\sup_x\int z_w(x)^2\,\Pi_n(dw)\to0$, that is, convergence to $0$ in $L^2(\Pi_n)$ uniformly in $x$, together with convergence of its risk.

   *Fix.* Say "the posterior means $\bar f_n,\hat f_n$ tend to $0$ uniformly on $X$, and $\sup_x\int z_w(x)^2\,d\Pi_n\to0$".

4. **Rates in C.9 (minor).** C.9 says: "the posterior tends to the prior and the predictor to $0$, at the quantitative rate $O(\eta n/N^\gamma)$". The proved rates are:
   - $\sup_X|\hat f_n|\le N^{-\gamma}(4k_n+\sqrt{2k_n})$. This is $O(\eta n/N^\gamma)$ only when $k_n\gtrsim1$, and $O(\sqrt{\eta n}/N^\gamma)$ when $k_n\le1$.
   - $\mathrm{KL}=O\bigl((\eta n+(\eta n)^2)/N^\gamma\bigr)$.
   - $\mathrm{TV}=O\bigl(N^{-\gamma/2}(\sqrt{\eta n}+\eta n)\bigr)$.

   Neither KL nor TV has rate $O(\eta n/N^\gamma)$ when $\eta n\gg1$.

   *Fix.* State the three rates separately.

5. **Remark C.6.2 attributes to Theorem C.5 a statement about a different learner (minor).** The remark says "Theorem C.5 shows that this factor is a property of the learner, not an artifact of that route", where the factor is the $N^\gamma$ of `slt-likelihood` §4. The learner of §4 (line 289) uses the **unclipped** likelihood $\exp[-\beta\sum_i(z_w-f)^2]$; Theorem C.5 is proved for the clipped likelihood of FIX$_\eta$. For the unclipped learner, `slt-likelihood` §3 gives only the qualitative TV statement.

   The quantitative extension is routine but not written down:
   - Step 1 of Lemma C.6.1 goes through with $z_w$ in place of $\phi_w$.
   - Step 2 needs (C.2.1) for $h=\pm\theta z_w(x)$, which is unbounded below. Lemma C.2.2 as stated covers only bounded or bounded-below $h$. The extension is easy: $d\Pi_t/d\mu\le1/Z_t$ puts $h$ in $L^1(\Pi_t)$, and $\int h\,dQ\le\int(h\vee(-k))\,dQ$.

   *Fix.* Restrict the sentence to FIX$_\eta$, or add the extension.

6. **Remark C.4.1, depth $L\ge3$ (minor, wording).** The remark says: "Replacing the weight of the last hidden neuron by $\log(2/\varepsilon')$". At $L=3$ the last hidden neuron has $d+1$ incoming weights, namely the readout coefficients of the depth-2 circuit, so "the weight" is undefined. `check_misc.py` instead multiplies **all** of them by $A'=\log(2/\varepsilon')$. That construction is correct: the neuron's input $s$ has the sign of $\chi$ and $|s|\ge7/8$, so
   $$|\tanh(A's)-\chi|<2e^{-7A'/4}\le\varepsilon'\qquad(\varepsilon'\le2),$$
   and the weights grow to $A'/\tanh1$. For $L\ge4$ the last hidden neuron has one incoming weight ($2$) and an input of magnitude $>1/2$. Replacing that weight by $A'$ gives error $<2e^{-A'}=\varepsilon'$, as stated.

   *Fix.* Distinguish the cases $L=3$ and $L\ge4$.

7. **"Bearing on the conjecture" mislabels a weakened statement as the brief's formalisation (minor).**
   - (i) The paragraph says: "In the brief's formalisation (§1), FIX$_\eta$ satisfies … with a sample size polynomial in … and in the learner width $N$". The brief's §1 requires a polynomial independent of $N$, uniformly over every $N\ge m$. The proved statement is a weaker formalisation, and the brief's own formalisation is refuted for this learner by Theorem C.5. The next sentence says this, but the first sentence should not call the weaker statement "the brief's formalisation".
   - (ii) The paragraph also says: "test loss $\le$ min … $+\,o(1)$". This is proved in expectation (Corollary C.2.2) and with high probability for $\tilde f_n$ (Theorem C.6). The $o(1)$ is $O(d^2n^{(4+\gamma)\alpha-1}\log(dn)/\eta)$, which tends to zero only if $d$ is fixed or $d^2\log d=o(n^{1-(4+\gamma)\alpha}/\log n)$. Corollary C.2.2 says so; the summary in C.0 does not.
   - (iii) "Min" should be "inf" here and in Corollary C.2.2's prose, since the minimum need not be attained.

8. **Remark C.4.2 at $N=1$ (trivial).** The claim "$\sigma\sqrt N=N^{(1-\gamma)/2}>1$" is an equality at $N=1$. This is harmless, because (C.3.1) uses $\log^+$.

   *Fix.* Write "$\ge1$".

9. **Proposition C.3(c), "can learn only when $\eta\sigma^2n\gtrsim1$" (trivial).** Part (b) shows that an excess below $1/2$ requires $\sigma^2(4k_n+\sqrt{2k_n})>1/4$.
   - If $\sigma^2\le1$, which holds in the regime of (a) where $\sigma^2\le1/N$, this implies $\eta\sigma^2n>c\,m_\nu$ with $c=\bigl((\sqrt6-\sqrt2)/8\bigr)^2\approx0.0167$ (closed form; numerical confirmation in the script).
   - Without $\sigma^2\le1$ the implication fails: take $k_n=1/(16\sigma^4)$ with $\sigma$ large. Then $\sigma^2\sqrt{2k_n}=\sqrt2/4>1/4$ while $\eta\sigma^2 n=m_\nu/(16\sigma^2)\to0$.

   *Fix.* Add "$\sigma^2\le1$".

10. **Notation overloads (presentational).** Several symbols carry two or three meanings:
    - $s$: the readout scale in Lemma C.6.1, and the cylinder half-width in Appendix C.A;
    - $t$: the sample index, $\sigma\sqrt N$ in Appendix C.A, and the variance factor in Appendix C.B;
    - $P$: the parameter count, and the projection in Appendix C.A;
    - $\lambda$: the image measure in Theorem C.1, $\eta n$ in Theorem C.7, and $m_\nu/(4\sigma_{\rm out}^2)$ in Lemma C.6.1;
    - $\hat f_n$: see issue 2.

    None causes an error, but the reuse of $s$ and $t$ between Lemma C.6.1 and Appendix C.A is easy to misread.

---

## 4. Independent checks (`../checks/verify-C-logic/`)

| check | result |
|---|---|
| Lemma C.6.1 (i)–(iii) by 1-D quadrature in the extremal case $\lvert h\rvert\equiv1$ ($\sigma_{\rm out}^2$ exact). Grid: $\sigma_{\rm out}^2\in[10^{-4},1]$, $\eta\in\{0.01,0.125,0.5,2,10\}$, $t\le100$, labels all $+1$ or random (`check_lemma_C61.py`) | 0 violations in 280 cases. Largest actual/bound ratios: (i) $0.47$, (ii) $0.23$, (iii) $0.72$ |
| fixed point of $u=\tanh2u$; $\tanh2>u^*$; $16+4\sqrt2<22$ | $u^*=0.957504$; yes; $21.66$ |
| constant in Proposition C.3(c) when $\sigma^2\le1$ | $\min\sigma^2k=0.01675$ |
| Theorem C.1 with the **unclipped** posterior mean, two-point prior, $M\in\{1,10,10^3,10^6\}$, $n\in\{10,100,1000\}$ (`check_unclipped_counterexample.py`) | the bound fails at $M=10$, $n=10$, and at every tested $n$ once $M\ge10^3$; the clipping of the unclipped mean fails too (issue 2(b)). The clipped-output mean satisfies the bound in all 12 cases |
| ../research-notes/C-fixed-temperature-bayes.md's own outputs (`C_scripts/*.out`) against the tables of §C.8 | all quoted numbers match. I recomputed $A_L(10,1,2,2)$ at $\rho=0.0125$ by hand: $346.1$ |

---

## 5. What is proved, stated with its quantifiers

**(P) Positive.** Fix $L\ge2$, $\gamma\ge1$, $\nu$ satisfying eq. `law`, and $0<\eta\le1/8$. Then for every:

- $N\ge1$ and $n\ge0$;
- $d\ge1$ and compact $X\subseteq[-1,1]^d$;
- Borel $D$ on $X\times[-1,1]$;
- competitor $g$ of depth $L$, width $m\le N$ and weights in $[-B,B]$ with $B\ge1$;
- $\rho\in(0,1]$,

the following holds:
$$\mathbb E_{S\sim D^{\otimes n}}L_D(\bar f_n)\le L_D(g)+4\rho+\frac{A_L(d,m,B,\rho)\,N^\gamma}{\eta(n+1)}.$$
Here $\bar f_n=\frac1{n+1}\sum_{t\le n}\int\operatorname{clip}z_w\,d\Pi_t$, and $\Pi_t$ is the FIX$_\eta$ posterior under $\mu_{N,\gamma}$. With probability at least $1-2\delta$ the same bound holds for $\tilde f_n$, with $n$ in place of $n+1$ and an extra $+4\sqrt{2\log(1/\delta)/n}$. For the final posterior, Theorem C.7 holds for any $\eta>0$ (no exp-concavity needed). With probability at least $1-2\delta$, both the Gibbs risk with clipped draws and the clipped BMA are at most
$$L_D(g)+4\rho+4\eta+\frac{A_L(d,m,B,\rho)N^\gamma+2\log(1/\delta)}{\eta n}.$$

**(N) Negative.** Fix $L\ge2$, $\nu$ and $\gamma>0$. For every $\eta>0$, $n\ge0$, $N\ge1$ and every sample, put $\beta_N=N^{-\gamma}(4k_n+\sqrt{2k_n})$ with $k_n=\eta n/m_\nu$. Then $\sup_X|\bar f_n|\le\beta_N$ and $\sup_X|\hat f_n|\le\beta_N$. If moreover $y\equiv1$, then $L_D(\bar f_n)$, $L_D(\hat f_n)$ and the Gibbs risk are all at least $1-2\beta_N$, while the width-1 competitor $g_1\equiv1$ (weights $\le2$) has $L_D(g_1)=0$. Hence no sample bound that is uniform in $N$ exists for FIX$_\eta$ under these priors.

**(T) Threshold.** For $y\equiv1$, $\gamma\ge1$ and $\eta\le1/8$, the width at which the excess crosses $1/2$ satisfies
$$\frac{\eta(n+1)}{4A_L(d,1,2,1/16)}\le N_c^\gamma\le4\bigl(4k_n+\sqrt{2k_n}\bigr).$$
This locates the transition. It does not show that the functional form of the complexity term is optimal (issue 1).

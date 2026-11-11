# Referee report on `../research-notes/A-tight-conditioning-fails.md`: computation (second round)

*Lens: recompute every constant, exponent, energy bound, probability estimate and concentration inequality. Subject: `../research-notes/A-tight-conditioning-fails.md` (revision 1, 1123 lines, read in full): Claims A, A′ and the TUBE variants. 11 November 2026. My scripts and their outputs are in `../checks/verify-A-computation/`. This file replaces the first-round computation report, which ../research-notes/A-tight-conditioning-fails.md cites; that report is preserved unchanged as `A-first-version-computation.md`.*

## 1. Verdict: `minor_fixes`

No step of ../research-notes/A-tight-conditioning-fails.md is wrong. I re-derived every displayed inequality in these results, and each holds with the stated constants:

* Lemmas 2.1–2.3, 3.1–3.2 and Corollary 3.3;
* Lemmas 4.1–4.3, Theorem 4.4 and Corollaries 4.5–4.6;
* Propositions 5.1–5.2, 6.1, 6.3, 6.5–6.6 and Lemmas 6.2, 6.4;
* Lemma 7.1, Theorem 7.2, Proposition 7.4 and Remarks 7.5–7.6;
* Lemma 8.1 and Propositions 8.2–8.3.

The limit order is respected throughout. $d,N,n,c,t$ and the sample are fixed before $\sigma\to0$. The two uniformity statements, Theorem 4.4(iv) and Theorem 7.2(iv), rest on Remark 3.4, which is correct.

The first-round computation issues are all fixed, except that one replacement number is itself slightly off (§6). The new results check: Propositions 5.2, 6.6 and 7.4 and Remarks 7.5–7.6. Every number in Tables 4.1, 5.1 and 7.1 and in §9 reproduces with independent code, apart from the exceptions below.

The issues concern how large the constants are presented to be, not validity.

1. **(minor) The reported widths are larger than the proofs need.** Table 4.1 gives $N_0$ at the maximizing accuracy $a$, which sits at a kink where $\underline e$ is flat. Widths smaller by factors of $2.3$ to $2.4\cdot10^{13}$ certify the same $\underline e$ to within $0.001$. Separately, the width $O(n^{5/3}\log^2n)$ of Corollary 4.5 comes from its choice of $a_d$. A slower schedule keeps every step of the proof and gives $N_0=O(n\log^4n)$ with the same limit $\beta(\lambda)$.
2. **(minor) Step 4 of Theorem 7.2 is loose.** Its budget $B'=2E\sqrt n+E^2$ makes the A′ certified excess $0.0015$ at $(H,d)=(2,20)$ and $0.18$ at $(2,30)$. Claim A gives $0.249$ and $0.434$ there. A short sharper Step 4 gives $\Delta(\zeta)\le c(K_{\rm mem}+t)+na^2+7$ and recovers Claim A's numbers. The asymptotic statement is unaffected.
3. **(trivial) Rounding and labelling.**
   * The $(2,60)$ row of Table 4.1 and Appendix R item 7(d) are off.
   * "$7\cdot10^6$" should read $7.3\cdot10^6$.
   * The fixed-$a$ value $0.356$ is a $d\to\infty$ limit: it is $0.226$ at $(2,20)$.
   * Table 7.1 has an ambiguous column header.
   * The $\beta'$ value in §9 item 3 is a finite-difference estimate.
   * A referee report on ../research-notes/E-finite-prior-scale.md is not cited.

## 2. Sources read and confirmed

I read `../research-notes/problem-brief.md` and `../research-notes/A-tight-conditioning-fails.md` in full. Every repository statement that ../research-notes/A-tight-conditioning-fails.md uses says what it is used for, at these lines.

**`NNG/side-results/continuous-domains/source/paper.tex`.**
* Eq. `energy` (l. 293) is (1.1), with $\sum_{\ell=2}^{L-1}=\sum_{\ell=2}^{H}$.
* Eq. `posterior` (l. 130) is (1.3), with $f(x_i)$ replaced by $y_i$.
* Eq. `energy-lipschitz` (l. 475) gives ${\rm Lip}\le K^{L/2}/\sqrt d$. Lemma 3.1(b) sharpens it by the factor $L^{-L/2}$.
* Theorem `strong` (ll. 178–197) says the scale threshold "does not depend on $D,n,\delta$", as (R1) quotes. Its proof (ll. 512–521) has the Laplace estimates that Lemma 3.2 generalizes.

**`NNG/works-in-progress/noisy-interpolation/README.md`.**
* Eqs. (2)–(4) are at ll. 93, 114 and 143.
* $a_d=\max\{1,\frac12\log(4\sqrt{2d})\}$ and $F_d=1+(d+1)(d+2)^2$ are at ll. 124–152.
* Eqs. (9) and (10) are at ll. 242 and 251.
* Eqs. (12)–(15) are at ll. 295–393, with $D_{d,H}=\sqrt2(d+2)+\frac{H-1}2$.
* ../research-notes/A-tight-conditioning-fails.md drops the $\max\{1,\cdot\}$ from the slope. This is harmless: the proofs use only $2e^{-2\alpha_d}=1/(2\sqrt{2d})$ and $(d+1)\alpha_d^2\ge1$, and both hold (§3.1).

**`NNG/works-in-progress/slt-likelihood/README.md`.**
* §2 (l. 61) says that $\sigma_0$ "may depend on the selected $n,N$, the teacher, and the accuracy parameters; it is uniform over $D$". (R1) quotes this.
* §3 (ll. 197–201) gives $\mathbb E[z^2\mid\text{hidden}]\le N^{-\gamma}$, which is used after Lemma 6.2.

**`NNG/README.md`.** Main result 1 (l. 33) gives a sample bound "polynomial in input dimension", as §0.1 says.

**Sibling sections cited in §5.4 and §10.**
* ../research-notes/B-tempered-likelihood.md:
  * Theorem 6.3 (l. 557): $\theta<1/H$, clipped predictors, every $N\ge m$.
  * Theorem 6.4 (l. 581): $\theta<1/L$, unclipped predictors.
  * Corollary 8.1 (l. 776): $\alpha<1/(4H)$.
  * Corollary 9.3(b) (l. 853): negative for $\alpha>L/(2H(2L-1))$.
  * §7.5 (l. 758).
* ../research-notes/E-finite-prior-scale.md:
  * Theorem 2.7 (l. 234): $\theta_{L,\gamma}=1/H$ for $\gamma\ge2-1/H$, with an imported cover at $\gamma=1$.
  * Proposition 4.4, Theorem 5.2 and Corollaries 5.3–5.4 (ll. 436–571).
* Report verdicts: the three ../research-notes/B-tempered-likelihood.md reports and `E-logic.md` all have verdict "minor fixes", as ../research-notes/A-tight-conditioning-fails.md says (but see issue 7).

## 3. Key inequalities, re-derived

Each computation below was done by hand. Where possible it was also checked numerically (§4).

### 3.1 The memorizer (Lemmas 2.1–2.3)

**Slope and coefficients.**
* $\alpha_d=\frac12\log(4\sqrt{2d})$ gives $2e^{-2\alpha_d}=\frac1{2\sqrt{2d}}$ exactly.
* By Lemma 2.2(b),(c), for $k\le d$, $|c_{k,\alpha_d}|\ge\frac1{\sqrt{2k}}-\frac1{2\sqrt{2d}}\ge\frac1{2\sqrt{2k}}$.
* The closed forms of Lemma 2.2(a) follow from $\sum_{j\le t}(-1)^j\binom qj=(-1)^t\binom{q-1}t$ and $2\binom{2m-1}{m-1}=\binom{2m}m$.
* With $1/\tanh1=1.3130<2\sqrt2$ and (2.4), $A\le2\sqrt{2d}\sum_S|\hat r(S)|\le2\sqrt{2ds}$.
* The row bound for $\omega_\emptyset$ uses $(d+1)\alpha_d^2\ge2\alpha_1^2=1.5014$.

**Hoeffding width.** Each summand of $g(x)-r(x)$ lies in an interval of length $2A/m$. Hence
$$\Pr\big[|g(x)-r(x)|\ge a/2\big]\le2\exp\Big(-\frac{2(a/2)^2}{m(2A/m)^2}\Big)=2e^{-ma^2/(8A^2)} .$$
The union bound over the $2^d$ points succeeds when $m>8A^2(d+1)\log2/a^2$. Since $A^2\le8ds$, the choice $m=N_0>64\log2\,d(d+1)s/a^2$ suffices, with $64\log2=44.36$.

**Energy.** Using $k_t\ge\lfloor N/m\rfloor\ge N/(2m)$:
* $\kappa^{(1)}\le d(d+1)\alpha_d^2$;
* $\kappa^{(2)}=\frac{NA^2}{m^2R^{2H-2}}\sum_tk_t^{-1}\le\frac{2A^2}{R^{2H-2}}\le2R^2$, since $A^2\le R^{2H}$;
* $\kappa^{(\ell)}=R^2$ for $3\le\ell\le H$, and $\kappa^{(L)}=R^2$.

The total is $d(d+1)\alpha_d^2+(H+1)R^2$, with $R^2=\max\{A^{2/H},\frac9{2a}\}\le\max\{(8ds)^{1/H},\frac9{2a}\}$.

**Chain.** The recursion $e_j\le|\tilde y_j|^3/3+Re_{j-1}$ unrolls to
$$|Ry_{H-1}-g|\le\frac{|g|^3}3\sum_{i=1}^{H-1}R^{-2i}\le\frac{2|g|^3}{3R^2}\qquad(R^2\ge2).$$
With $|g|\le\frac32$ and $R^2\ge\frac9{2a}$, this is at most $\frac9{4R^2}\le\frac a2$.

### 3.2 Network bounds and strong-prior concentration (Lemmas 3.1–3.2, Corollary 3.3)

**Lemma 3.1.**
* $|z_w|\le\|v\|_1\le\sqrt N\|v\|_2=\sqrt{\kappa^{(L)}}$.
* The Lipschitz product is $\|v\|_2\|W^1\|_F\prod_{\ell\ge2}\|W^\ell\|_F=(\kappa^{(1)}\cdots\kappa^{(L)}/d)^{1/2}\le(\kappa_N/L)^{L/2}/\sqrt d$, by AM–GM.

**Lemma 3.2.** Put $\theta=t/(4(F^*+t))$.
* *Monotonicity.* $\frac{d}{du}\log\big[(1+u)^pe^{-(1-\theta)u/(2\sigma^2)}\big]\le p-\frac{1-\theta}{2\sigma^2}\le0$ when $\sigma^2\le3/(8p)$.
* *Exponent.* $(1-\theta)(F^*+t)-(F^*+\frac t4)=\frac t2$.
* *Gaussian factor.* $\int e^{-\theta w^\top\Gamma_Nw/(2\sigma^2)}dw=\big(8\pi\sigma^2(F^*+t)/t\big)^{P/2}(\det\Gamma_N)^{-1/2}$.

So (3.2) is exact as written.

**Corollary 3.3.** In (3.3), $\bar z-m_\sigma=-(1-p_\sigma)m_\sigma+\int_{\mathcal N_t^c}z_w\,d\Pi_\sigma$ with $|m_\sigma|\le\sqrt{F^*+t}$. The clipped version has the constant $2(1-p_\sigma)$.

### 3.3 Claim A (Lemma 4.3, Theorem 4.4, Corollaries 4.5–4.6)

**Theorem 4.4.**
* $M\epsilon=c(K_{\rm mem}+t)+na^2$, which is exactly the budget of Lemma 4.1(b).
* On $\mathcal E$, $\sqrt{2n\log(1/\delta)}/M=\sqrt{2\lambda\log(1/\delta)/M}$. At $\delta_d=e^{-2^{d/2}}$ this equals $\sqrt{2\lambda_d}\,2^{-d/4}$.

**Corollary 4.5.**
* $c_d/(a_d2^d)\le\max\{c_d,1\}^{2/3}2^{-2d/3}$.
* $N_0\le44.36\,d(d+1)2^{5d/3}+1\le45\,d(d+1)2^{5d/3}$ for every $d\ge1$.
* $\alpha_d=0.8664+\frac14\log d\le1.5\log(d+1)$. The smallest slack is $0.173$, at $d=1$.

**$\beta(\lambda)$.**
* $\beta'=h-\beta$ with $h=(1-e^{-\lambda})/\lambda$. So $\beta'$ takes values in $(-0.095,1)$, and its supremum is $1$, approached as $\lambda\to0$.
* $\lambda^*=1.502861$ and $\beta(\lambda^*)=h(\lambda^*)=0.5173514$.
* $\beta(1)=0.4848291$.

**Concentration and probability constants.** All recomputed from first principles:

| place | variable | bounded difference / range | inequality | as stated |
|---|---|---|---|---|
| Lemma 2.1, Step 3 | $g(x)-r(x)$ (Hoeffding) | range $2A/m$ | $2e^{-ma^2/(8A^2)}$ | yes |
| Lemma 4.3(b) | $Q$ (McDiarmid) | $2$ | $e^{-u^2/(2n)}$ | yes |
| Lemma 4.3(c) | Bin vs Poi (Le Cam) | — | $n/M^2$ | yes |
| Corollary 4.6 | $Q_\eta$ (McDiarmid) | $8$ | $e^{-u^2/(32n)}$ | yes |
| Proposition 5.2(c) | $k_{\min}$ (Chernoff, one-half) | — | $Me^{-n/(8M)}$ | yes |
| Proposition 5.2(c) | $\Delta_0$ (Markov) | $\mathbb E\Delta_0=\mathbb E\lvert\mathcal S\rvert\le M$ | $\delta'$ | yes |
| Proposition 6.1(b) | $Q_\eta$ (Hoeffding) | range $4$ | $e^{-u^2/(8n)}$ | yes |
| Lemma 6.4(b) | $\lvert S_1\rvert$ (McDiarmid) | $1$ | $e^{-\mu_1^2/(2n_1)}$ | yes |
| Proposition 6.6(b) | labels at one atom | — | $2e^{-n(1-\eta_0)/(2M)}$ | yes |
| Proposition 8.3(a) | $\Phi$ in $y$ (McDiarmid) | $2\sqrt{K_0}$ | $u=\sqrt{2nK_0\log(2/\delta)}$ at level $\delta/2$ | yes |
| Proposition 8.3(b) | $\Psi$ in $x$ (McDiarmid) | $K_0/n$ | $u=K_0\sqrt{\log(2/\delta)/(2n)}$ at level $\delta/2$ | yes |

### 3.4 Fixed dimension (Proposition 5.2, new)

**(a) The width-uniform bound.**
* On $\{k_{\min}\ge1\}$, the hypothesis $F_{c,S}(w)\le F_{c,S}(0)+t$ and Lemma 4.1(a) give $\Delta(z_w)\le\Delta_0+ct-c\kappa_N(w)$.
* Dividing the atom sums by $k_{\min}$ and applying Minkowski,
$$\Big(\sum_xz_w(x)^2\Big)^{1/2}\le\sqrt{(\Delta_0+ct)/k_{\min}}+\sqrt{\Delta_0/k_{\min}}=\sqrt{MU_S}.$$
* The second form of $U_S$ follows from $(u+v)^2\le2u^2+2v^2$.

**(c) The probability bound.**
* For fair labels, $\mathbb E[k_x\bar y_x^2\mid k_x=k]=k\cdot\frac1k=1$.
* The multiplicative Chernoff bound at one-half gives $\Pr[{\rm Bin}(n,p)\le np/2]\le e^{-np/8}$.
* On both events, $U_S\le\frac{2(2M/\delta'+ct)}{M\cdot n/(2M)}=\frac{8M/\delta'+4ct}n$.

**The consequence.** Take $\delta'=\delta/2$. Then $n\ge8M\log(2M/\delta)$ gives $Me^{-n/(8M)}\le\delta/2$, and $n\ge(16M/\delta+4ct)/\varepsilon$ gives excess at most $\varepsilon$.

**(b) The $\sigma\to0$ limits.** $L_{D_d}(z_w)\le1+\max_xz_w(x)^2\le1+\kappa_N(w)\le1+F_{c,S}(w)$, so Lemma 3.2 with $p=1$ handles the Gibbs expectation.

**How tight (a) is.** I computed, through its secular equation, the exact maximum of $\frac1M\sum_xf(x)^2$ subject to $\Delta(f)\le\Delta_0+ct$. On 300 random samples it is at most $0.906\,U_S$. So the Minkowski step points the right way and is not far from tight.

### 3.5 TUBE (§6.2, including the new Proposition 6.6)

**Lemma 6.2.** Under $\mu_\sigma$, $\kappa_N\sim\sigma^2\chi^2_P$. Hence $\mathbb E_{\Pi^{\rm tube}}\kappa_N\le P\sigma^2/\mu_\sigma(U)$, and $|L_D(z_w)-L_D(0)|\le\kappa_N+2\sqrt{\kappa_N}$.

**Proposition 6.3.** $\tanh1=0.7616$, $\tanh(2\tanh1)=0.9093$ and $\tanh2=0.9640$. So $t\mapsto\tanh2t$ maps $[\tanh1,1]$ into itself, and $|v|\le1/\tanh1=1.3130$.

**Lemma 6.4(b).**
* $(1-e^{-1})/16=0.03951\ge0.039$ and $(1-e^{-1})^2/2=0.1998\ge0.19$.
* $n_1n_2\ge n(n-1)/4$ holds for both parities of $n$.
* The $\lambda$-scale exponents are $\frac\lambda8(1-e^{-\lambda/2})M$ and $\frac{(1-e^{-\lambda/2})^2}\lambda M$, as stated.

**Proposition 6.5.** Take $\varepsilon_i=+1$ and $u\in[y_i-\rho,y_i+\rho]$. Then $u-\eta(x_i)\ge b-\rho>0$, and ${\rm clip}(u)-\eta(x_i)\ge\min\{b-\rho,1-\eta(x_i)\}=b-\rho$, because $1-\eta(x_i)\ge b$.

**Proposition 6.6(a).**
* $\{\kappa_N<(\rho-1)^2\}\subseteq U_{\rho,S}$ for every sample.
* So $k_\sigma\le P\sigma^2/(1-P\sigma^2/(\rho-1)^2)$, uniformly over samples.
* Markov's inequality applied to $|L_D(f)-L_D(0)|$ gives the Gibbs bound $(k_\sigma+2\sqrt{k_\sigma})/(\eta_0^2-\varepsilon)$.

**Proposition 6.6(b).**
* The identity $\Pr[\text{labels at }e\text{ agree}]=(1-\frac{1-p}M)^n+(1-\frac pM)^n-(1-\frac1M)^n$ is exact, by inclusion–exclusion on "no $-1$ at $e$" and "no $+1$ at $e$".
* Each of the first two terms is at most $e^{-n(1-p)/M}$, because $p\ge1-p$.
* The consequence needs $2e^{-n(1-\eta_0)/(2M)}<1-\delta$, which is the stated condition $n>\frac{2M}{1-\eta_0}\log\frac2{1-\delta}$.

### 3.6 Claim A′ (Lemma 7.1, Theorem 7.2, Proposition 7.4, Remarks 7.5–7.6)

**Theorem 7.2.**
* The cluster variation is $\frac{(K_2/L)^{L/2}}{\sqrt d}\cdot r\sqrt d=\frac1n$ exactly.
* *Step 4.* $(a+\frac1n)\sqrt n+\frac{\sqrt n}n=(a+\frac2n)\sqrt n$, which is the second part of $E$. Then $\Delta(\zeta)\le(\sqrt W+E)^2-W=2E\sqrt W+E^2\le2E\sqrt n+E^2$, since $W=\sum_pk_p(1-\bar y_p^2)\le n$. This is valid but loose (issue 2).
* *Step 0.* $K_2\ge K_{\rm mem}\ge\frac92(H+1)>L$, so $r<1/n$.

**Lemma 7.1(d).**
* Pairing points at distance $r/2$ over a set of measure $\frac12$ gives $|\mathbb E[gy\mid p]|\le\Lambda r/4$.
* $\Lambda\le B\sqrt m\cdot B\sqrt{md}\cdot(Bm)^{H-1}=B^Lm^H\sqrt d$.

**Proposition 7.4.**
* (a) $\Gamma(y+1)\ge\int_y^\infty s^ye^{-s}ds\ge(y/e)^y$, so ${\rm vol}(B_d(\rho))\le(2\pi e\rho^2/d)^{d/2}$.
* (b) $2\pi e\rho_{\rm tr}^2/d=8\pi e(L/K')^L$.
* (c) $\frac12\log_2(8\pi e)=3.0471$. Since $L=H+1$, $K_2/L\ge(8d2^d)^{1/H}\ge2^{d/H}$. When $c\le1$, $K_2\ge n$.

**Remark 7.5.** At $n=2^d$, $\log_2r^{-d}=d\log_2n+\frac{Ld}2\log_2\frac{K_2}L\ge(1+\frac L{2H})d^2$.

**Remark 7.6.**
* $(\kappa_N/L)^{L/2}r>2-2\rho$ gives $\kappa_N>L((2-2\rho)/r)^{2/L}=(2-2\rho)^{2/L}n^{2/L}K_2$.
* At $\rho=\frac12$ the factor is $2^{2d/L}$. It runs from $1.02\cdot10^3$ at $(H,d)=(3,20)$ to $1.07\cdot10^8$ at $(2,40)$.

### 3.7 Exponent optimality (Lemma 8.1, Propositions 8.2–8.3)

**Lemma 8.1.**
* *Counting.* Sauer–Shelah gives $J\le\sum_{k\le d+1}\binom Mk\le(M+1)^{d+1}$, so $\log J\le(d+1)\log(2^d+1)\le(d+1)^2\log2$.
* *Massart.* ${\rm Rad}\le\sqrt{2\log J/m}$.
* *Clipping.* Each layer adds $\frac1{2\sqrt m}$, because $\mathbb E\sup_{\tau\in[0,1]}\tau\sum\varepsilon_i=\frac12\mathbb E|\sum\varepsilon_i|\le\frac{\sqrt m}2$. The one-sided contraction needs no $\phi(0)=0$, because $\mathbb E\sum_i\varepsilon_i\phi(0)=0$.
* *Mixture identity.* It follows from $\int_0^u\tanh^2(\rho\tau)\,d\tau=u-\tanh(\rho u)/\rho$.
* *Path norm.* It is at most $(\kappa_N/H)^{H/2}$, by AM–GM over $H$ factors.
* The constant $D_{d,H}=\sqrt{2\log2}(d+1)+\frac{H-1}2$ is smaller than the note's $\sqrt2(d+2)+\frac{H-1}2$.

**Proposition 8.2.**
* (a) is $(1-a)s\le D_{d,H}\sqrt s\,(K/H)^{H/2}$. (b) follows from polarization, $\sum\varepsilon_if_i=\frac12(\sum f_i^2+s-\sum(f_i-\varepsilon_i)^2)$.
* At $s=2^d$ and $a=\frac12$, the lower bounds are $2.1499\cdot10^4$ at $(2,40)$ and $1.4513\cdot10^3$ at $(3,40)$. The constructions are $5.6278\cdot10^7$ and $2.8763\cdot10^5$.
* The ratio $\frac{H+1}H(8dD_{d,H}^2/(1-a)^2)^{1/H}$ is $2617$ at $(2,40)$.

**Proposition 8.3.**
* *Comparison.* Comparing with $w=0$ gives $c\kappa_N+\sum_iz_i^2\le ct+2\sum_iy_iz_i$.
* *Exponents.* With $K_0=n^\vartheta+t$, the leading exponents are $(\vartheta H-1)/2$ and $(\vartheta(H+1)-1)/2$.
* *The $C_t$ paragraph.* $C_t=2(1+\sqrt{t/2})^2/t$ makes $\frac t2+\frac1{C_t}(1+\sqrt{t/2})^2=t$ exactly. The constant network has energy $(d+H)\epsilon_0^2$; I checked this on a concrete instance.
* *Thresholds.* The *Above* threshold is $c\gg n^{1-1/H}(2D_{d,H})^{2/H}/H$, and the window is $d^{2/H}/d^{-1/H}=d^{3/H}$.

## 4. Independent numerical checks

Scripts c1–c7 and c10 are new and written from the formulas. c8 and c9 re-run two first-round scripts, because Lemmas 2.1 and 3.2 are unchanged.

| script | what it tests | result |
|---|---|---|
| `c1_constants.py` | slope identities; $c_{k,\infty}$ closed form in exact rationals, $k\le60$; $\min\lvert c_{k,\alpha_d}\rvert\,2\sqrt{2k}$ over $1\le k\le d\le60$ at 60 digits; chain at $R^2=9/(2a)$, $H\le11$; Corollary 4.5 constants; $\beta$, $\lambda^*$, exact binomial $\beta_n$; Proposition 6.3, Lemma 6.4, Proposition 8.2 and $C_t$ constants; A′ radius | all as stated. Minimum $1.3372$. Chain error $\le0.5032\cdot a/2$. $\beta_n=0.4850302$, $0.4848417$, $0.4848299$ at $d=10,14,18$ (§9 item 3: $0.48503$, $0.48484$, $0.48483$). $\log_2r=-47.62$, $-72.62$, $-97.62$ |
| `c2_table41.py` | Table 4.1 with the optimal $a$ in closed form, cross-checked on a 4000-point grid; admissible $c$; fixed-$a$ numbers; A′ excess as stated | every $\underline e$, $K_{\rm mem}$ and $N_0$ reproduces except the $(2,60)$ row (issue 3). $c_{\max}=29.25$, $1583$, $812.6$ and $1.59\cdot10^5$. $N_0/n$ is $1.863\cdot10^6$–$7.275\cdot10^6$ at $a=0.1$ and $2.070\cdot10^5$–$8.084\cdot10^5$ at $a=0.3$ |
| `c2b_flatness.py` | 80-digit evaluation at $(2,60)$; flatness of $\underline e(a)$ beyond the kink; A′ excess as stated and with a sharper Step 4 | issues 1–3 |
| `c3_fixed_d.py`, `c3b_median_noise.py` | Table 5.1; coverage of the high-probability bound; sample sizes of Proposition 5.2; exact constrained maximum vs $U_S$ | medians agree within Monte Carlo error; coverage $1.000$ wherever the guarantee is positive; sample sizes as in `r1_misc.out`; ratio $\le0.906$ |
| `c4_tube.py` | exact $\Pr[\text{no conflict}]=\sum_{a+b+c=M}\frac{M!}{a!\,b!\,c!}(-1)^c\big(\frac{ap+bq}M\big)^n$, a formula independent of the revision's script and checked against brute force | all 36 values of `r1_tube_fixed_d.out` reproduce to the printed digits. The order "exact $\le$ one-atom $\le2e^{-n(1-\eta_0)/(2M)}$" holds in all 36. Lemma 6.4(b) holds in 6 cases, e.g. $1.275\cdot10^{-7}\le2.32\cdot10^{-2}$ at $M=1024$, $n=256$ |
| `c5_density.py`, `c5b_digits.out` | Table 7.1 in log space; the Gamma bound for $d\le400$; Proposition 7.4(c) for $c\in[10^{-3},10^{12}]$, $H\in\{2,3,4\}$, $d\in\{5,10,20,40\}$; the Remark 7.6 floor | every entry reproduces. The borderline values $655.847$, $-324.545$ and $337.154$ round as printed. The worst slack in 7.4(c) is $24$ bits. Floor ratios run from $1.02\cdot10^3$ to $1.07\cdot10^8$ |
| `c6_fixed_a.py` | certified excess at fixed $a$ and finite $d$ | issue 5 |
| `c7_sharper_step4.py` | the sharper Step 4 of issue 2, on adversarial random instances | holds on $19{,}669$ admissible instances (slack $\ge2.83$). The paper's own bound also holds (slack $\ge0.38$) |
| `c10_cor45_width.py` | Corollary 4.5 with $a_d=\max\{(\max\{c_d,1\}/2^d)^{1/3},1/d\}$ | $\bar\epsilon_d\to0$, $\underline e\to\beta(1)$, and $N_0/n\le45d^3(d+1)$ (issue 1(b)) |
| `c8_v2_memorizer_rerun.out` | first-round `v2_memorizer.py`: Lemma 2.1 built at its own width $N_0$, in 8 configurations | all pass |
| `c9_v3_laplace_rerun.out` | first-round `v3_laplace_bound.py`: (3.2) on a two-parameter objective, 84 cases | maximum LHS/RHS is $1.9\cdot10^{-3}$ |

Table 5.1 reproduces within Monte Carlo error. One entry sits at the edge: at $(d,n/M)=(6,16)$, ../research-notes/A-tight-conditioning-fails.md has $0.547$. A run of 8000 samples has median $0.526$, and 95% of 400-sample medians fall in $[0.511,0.544]$. No change is needed, beyond saying that the entries are Monte Carlo medians.

## 5. Issues

### Issue 1 (minor): the widths are reported larger than the proofs need

**(a) The $N_0$ column of Table 4.1.**

*Location.* Table 4.1 (ll. 432–441) and Remark 4.7 (l. 445): "The width threshold $N_0$ at the optimizing $a$ is polynomial in $n$ but astronomically large: $3\cdot10^{14}$ to $5\cdot10^{42}$ in the table."

*Computation.* In (4.3), $\epsilon(a)=c(K_{\rm mem}(a)+t)/M+\lambda a^2$. Put $a_{\rm kink}=\frac9{2(8ds)^{1/H}}$ and $a_{\rm int}=\big(\frac{9(H+1)c}{4M\lambda}\big)^{1/3}$.
* For $a<a_{\rm kink}$, $\epsilon$ is convex in $a$ with minimum at $a_{\rm int}$.
* For $a\ge a_{\rm kink}$, $K_{\rm mem}$ does not depend on $a$, so $\epsilon$ grows only by $\lambda(a^2-a_{\rm kink}^2)$.
* Hence $a^*=\min\{a_{\rm int},a_{\rm kink},1\}$. In every row except $(4,30)$ this is the kink.

Beyond the kink, $\lambda(a^2-a_{\rm kink}^2)$ stays negligible next to $c(K_{\rm mem}+t)/M$ until $a$ is many times $a_{\rm kink}$, while $N_0\propto a^{-2}$. The table below (`c2b_flatness.out`; $c=t=1$, $\delta=0.01$, $\lambda=1$) gives, for each row, the largest $a$ with $\underline e\ge\underline e^*-0.001$ and its $N_0$.

| $(H,d)$ | $a^*$ | $\underline e^*$ | $N_0(a^*)$ | largest $a$ within $0.001$ | its $N_0$ | its $N_0/n$ |
|---|---|---|---|---|---|---|
| (2,20) | $3.5\cdot10^{-4}$ | 0.2490 | $1.6\cdot10^{17}$ | $0.020$ | $5.0\cdot10^{13}$ | $4.7\cdot10^7$ |
| (2,30) | $8.9\cdot10^{-6}$ | 0.4337 | $5.6\cdot10^{23}$ | $0.0076$ | $7.7\cdot10^{17}$ | $7.1\cdot10^8$ |
| (2,40) | $2.4\cdot10^{-7}$ | 0.4749 | $1.4\cdot10^{30}$ | $0.0033$ | $7.3\cdot10^{21}$ | $6.7\cdot10^9$ |
| (2,60) | $1.9\cdot10^{-10}$ | 0.4845 | $5.1\cdot10^{42}$ | $9.3\cdot10^{-4}$ | $2.2\cdot10^{29}$ | $1.9\cdot10^{11}$ |
| (3,20) | $8.2\cdot10^{-3}$ | 0.4063 | $2.9\cdot10^{14}$ | $0.0125$ | $1.3\cdot10^{14}$ | $1.2\cdot10^8$ |
| (3,30) | $7.1\cdot10^{-4}$ | 0.4776 | $8.9\cdot10^{19}$ | $0.0029$ | $5.2\cdot10^{18}$ | $4.9\cdot10^9$ |
| (3,40) | $6.4\cdot10^{-5}$ | 0.4841 | $2.0\cdot10^{25}$ | $0.0011$ | $6.3\cdot10^{22}$ | $5.8\cdot10^{10}$ |
| (4,30) | $2.2\cdot10^{-3}$ | 0.4790 | $9.3\cdot10^{18}$ | $0.0039$ | $2.9\cdot10^{18}$ | $2.7\cdot10^9$ |

The reduction factor runs from $2.3$ at $(3,20)$ to $2.4\cdot10^{13}$ at $(2,60)$.

*Consequence.* No statement is false: the column is what its header says, $N_0$ at the maximizer. But the maximum is flat, so the maximizer is the wrong point at which to report a width. Read as "the width the counterexample needs", the column overstates it by up to 13 orders of magnitude. Remark 4.7's fixed-$a$ paragraph covers the tradeoff only at $a\in\{0.1,0.3\}$, and those choices cost $0.13$ to $0.33$ in $\underline e$.

*Fix.* Report $N_0$ at the largest $a$ with $\underline e\ge\underline e^*-0.001$, or add it as a column. Then replace "astronomically large: $3\cdot10^{14}$ to $5\cdot10^{42}$" by that column's range: $5\cdot10^{13}$ to $2\cdot10^{29}$, that is, $N_0/n$ from $5\cdot10^7$ to $2\cdot10^{11}$.

**(b) The exponent $5/3$ in Corollary 4.5.**

*Location.* Corollary 4.5 (l. 391); §0.2 item 3 (l. 37): "With the vanishing accuracy of Corollary 4.5, $N_0\le45d(d+1)2^{5d/3}=O(n^{5/3}\log^2n)$".

*Computation.* The exponent comes from the choice $a_d=(\max\{c_d,1\}/2^d)^{1/3}$, which makes $\bar\epsilon_d$ vanish fast but forces $a_d^{-2}=2^{2d/3}$. Take instead
$$a_d=\max\Big\{\big(\max\{c_d,1\}/2^d\big)^{1/3},\ \tfrac1d\Big\}.$$
Every step of the proof of Corollary 4.5 goes through:
* $a_d\le1$ for large $d$, and $a_d\to0$, so $\lambda_da_d^2\to0$.
* Because $a_d\ge(\max\{c_d,1\}/2^d)^{1/3}$, the bound $\frac{9(H+1)c_d}{2a_d2^d}\le\frac{9(H+1)}2\max\{c_d,1\}^{2/3}2^{-2d/3}$ is unchanged.
* $a_d^{-2}\le d^2$ gives $N_0\le44.4\,d^3(d+1)2^d+1\le45\,d^3(d+1)2^d=O(n\log^4n)$.

The limit is still $\underline e\to\beta(\lambda)$ (`c10_cor45_width.out`). The price is slower convergence. At $(2,40)$, Corollary 4.5's displayed lower bound is $0.448$ with $N_0/n=1.2\cdot10^8$ under this schedule, against $0.4735$ with $N_0/n=7.8\cdot10^{12}$ under the paper's ($c=t=1$, $\delta=\delta_d$). Any $a_d\to0$ that is at least the paper's $a_d$ works the same way.

*Consequence.* The SP$_c$ failure, with the full limiting excess $\beta(\lambda)$, holds at every width $N\ge45\,d^3(d+1)2^d=O(n\log^4n)$. The paper states the full excess only for $N_0=O(n^{5/3}\log^2n)$, and for $N_0=O(n\log^2n)$ only with the reduced excess $(\sqrt{\beta(\lambda)}-a\sqrt\lambda)_+^2$. Its §0.2 item 3, §5.3 item 3 and §10 item 5 understate what is proved.

*Fix (optional).* Add this schedule to Corollary 4.5, or one sentence to §0.2 item 3 and §5.3 item 3.

### Issue 2 (minor): Step 4 of Theorem 7.2 is loose, and the A′ bound is nearly vacuous at $d=20$

**Location.** Theorem 7.2: the definition of $B'$ (l. 747) and Step 4 (ll. 780–789). Also §0.2 item 7 (l. 47), which says "the same lower bound $1+\beta_n-o(1)$ holds" and quotes the law's density ratio at $(H,d)=(2,20)$ as its example.

**Computation.** Step 4 bounds the cross term between two vectors in $\mathbb R^n$: the variation of $z_w$ within clusters, and the residuals $\zeta_{p_i}-y_i$. It uses the triangle inequality, which costs $2E\sqrt W$ with $W\approx n$. Since $E\approx\sqrt{c(K_{\rm mem}+t)}+a\sqrt n$, the budget is $B'\approx2\sqrt{n\,c(K_{\rm mem}+t)}$ rather than $c(K_{\rm mem}+t)$. So $\sqrt{B'/M}$ decays like $(cK_{\rm mem}/n)^{1/4}$ instead of $(cK_{\rm mem}/n)^{1/2}$. The table below gives the certified excess at $c=t=1$, $\delta=0.01$ and $\lambda=1$, with $a$ optimized for each bound (`c2b_flatness.out`).

| $(H,d)$ | (2,20) | (2,30) | (2,40) | (2,60) | (3,20) | (3,30) | (3,40) | (4,30) |
|---|---|---|---|---|---|---|---|---|
| $\underline e'$ of Theorem 7.2 as stated | 0.0015 | 0.176 | 0.332 | 0.454 | 0.108 | 0.346 | 0.439 | 0.349 |
| $\underline e'$ with the sharper Step 4 | 0.249 | 0.434 | 0.475 | 0.4845 | 0.406 | 0.478 | 0.484 | 0.479 |
| $\underline e$ of Theorem 4.4 (atoms) | 0.249 | 0.434 | 0.475 | 0.4845 | 0.406 | 0.478 | 0.484 | 0.479 |

**A sharper Step 4.** For the near-minimizer, put $u_i=z_w(x_i)-\zeta_{p_i}$ and $v_i=\zeta_{p_i}-y_i$. By Step 2, $|u_i|\le\frac1n$, so $\sum_iu_i^2\le\frac1n$. Put $X:=\sum_iv_i^2$; by Lemma 4.1(a), $X=\Delta(\zeta)+W$. Cauchy–Schwarz gives
$$\sum_i(z_w(x_i)-y_i)^2=\sum_i(u_i+v_i)^2\ \ge\ X-\tfrac2{\sqrt n}\sqrt X .$$
For the comparator, put $u_i^0=z_{w_0}(x_i)-z_{w_0}(p_i)$ and $v_i^0=z_{w_0}(p_i)-y_i$. Then $Y:=\sum_i(v_i^0)^2=\sum_pk_p(z_{w_0}(p)-\bar y_p)^2+W\le na^2+W\le2n$, and
$$\sum_i(z_{w_0}(x_i)-y_i)^2\ \le\ Y+\tfrac2{\sqrt n}\sqrt Y+\tfrac1n\ \le\ Y+2\sqrt2+\tfrac1n .$$
Near-minimality gives $\sum_i(z_w(x_i)-y_i)^2\le C+\sum_i(z_{w_0}(x_i)-y_i)^2$, with $C=c(K_{\rm mem}+t)$. Hence
$$\big(\sqrt X-n^{-1/2}\big)^2\le R':=C+Y+2\sqrt2+\tfrac2n,\qquad X\le R'+\tfrac2{\sqrt n}\sqrt{R'}+\tfrac1n .$$
Suppose $C\le n$ and $n\ge100$. Then $R'\le3n+3$ and $\frac2{\sqrt n}\sqrt{R'}\le3.49$. Therefore
$$\Delta(\zeta)=X-W\ \le\ c(K_{\rm mem}+t)+na^2+7 .$$
Step 5 then applies with $B''=c(K_{\rm mem}+t)+na^2+7$ in place of $B'$. This gives $\sqrt{B''/M}=\sqrt{\epsilon+7/M}$, which is Claim A's $\sqrt\epsilon$ up to $7/M$. The Jensen argument of Step 6 is unchanged. `c7_sharper_step4.py` tests the inequality on $19{,}669$ adversarial instances; the smallest slack is $2.83$.

**Consequence.** Theorem 7.2 is correct, and so is its limit $\underline e'\to\beta(\lambda)$. But at the example dimension of §0.2 item 7, $(2,20)$, where the density ratio is $10^{287}$, the theorem as written certifies an excess of only $0.0015$.

**Fix.** Replace Step 4 by the argument above, with the hypothesis $c(K_{\rm mem}+t)\le n$, which holds in the regime of the theorem. Alternatively, keep Step 4 and add one sentence: the $o(1)$ of Theorem 7.2 is much slower than that of Theorem 4.4, with the first row of the table above.

### Issue 3 (trivial): the $(2,60)$ row of Table 4.1 and Appendix R item 7(d)

**Location.** Table 4.1 (l. 437) and Appendix R item 7(d) (l. 1120).

**Computation.** The optimizing $a$ at $(2,60)$ is $a_{\rm kink}=9/(2\sqrt{8\cdot60\cdot2^{60}})=1.913\cdot10^{-10}$, which prints as $1.9\cdot10^{-10}$, not $2.0\cdot10^{-10}$. The width there is $N_0=5.12\cdot10^{42}$, not $4.7\cdot10^{42}$. In 80-digit arithmetic,
* $\underline e(1.913\cdot10^{-10})=0.48448462083658912271$, and
* $\underline e(2.0\cdot10^{-10})=0.48448462083658911313$.

The difference, about $10^{-17}$, is below double precision. That is why the bounded optimizer in `r1_table41.py` stopped at $2.0\cdot10^{-10}$. The other seven rows put the optimizer where the closed form of issue 1 puts it.

**Fix.** Print $1.9\cdot10^{-10}$ and $5.1\cdot10^{42}$ in both places. Adopting issue 1(a)'s column makes the point moot.

### Issue 4 (trivial): "$7\cdot10^6$"

§0.2 item 3 (l. 37), §5.3 item 3 (l. 543) and Appendix R S6 (l. 1083) give the fixed-$a$ range of $N_0/n$ as "between $2\cdot10^5$ and $7\cdot10^6$". The maximum is $7.275\cdot10^6$, at $d=40$ and $a=0.1$, and Remark 4.7 prints it correctly as $7.3\cdot10^6$. **Fix:** write $7.3\cdot10^6$.

### Issue 5 (trivial): the fixed-$a$ value $0.356$ is a limit

**Location.** Remark 4.7 (l. 445): "$a=0.1$ and $\lambda=1$ give $0.356$, with $N_0/n$ between $1.9\cdot10^6$ and $7.3\cdot10^6$ for $d\in[20,40]$". §0.2 item 3 and §5.3 item 3 state the same with "$-o(1)$".

**Computation.** $(\sqrt{\beta(1)}-0.1)^2=0.3556$ is the $d\to\infty$ limit. At finite $d$, with $c=t=1$ and $\delta=0.01$, (4.3) gives the following (`c6_fixed_a.out`).

| | $d=20$ | $d=30$ | $d=40$ |
|---|---|---|---|
| $a=0.1$, $H=2$ | 0.226 | 0.347 | 0.355 |
| $a=0.1$, $H=3$ | 0.336 | 0.355 | 0.356 |
| $a=0.3$, $H=2$ | 0.113 | 0.155 | 0.157 |
| $a=0.3$, $H=3$ | 0.151 | 0.157 | 0.157 |

**Fix.** Write "tends to $0.356$; it is $0.226$ at $(H,d)=(2,20)$ and $0.347$ at $(2,30)$".

### Issue 6 (trivial): two labels

* **Table 7.1, column 4 (l. 840).** The entries use the exact ball volume, which is the first expression in Proposition 7.4(a). The Gamma-function form, the second expression, is about one order of magnitude weaker: for example $-147.96$ instead of $-148.86$ at $(2,20)$. **Fix:** say "with the exact ball volume".
* **§9 item 3 (l. 990).** "$\max|\beta'|=0.981$" is the finite-difference value from `check_constants.py`. The exact maximum on $[0.01,20]$ is $\beta'(0.01)=0.9851$, which `r1_misc.out` prints. **Fix:** quote $0.985$, or say "by finite differences".

### Issue 7 (trivial): ../research-notes/E-finite-prior-scale.md has two referee reports

§5.4 (l. 554) and §10 item 6 (l. 1040) cite one report on ../research-notes/E-finite-prior-scale.md, `E-logic.md`. A second, `E-computation.md`, was written before ../research-notes/A-tight-conditioning-fails.md. It also has verdict "minor fixes", and its two small errors do not affect ../research-notes/E-finite-prior-scale.md's theorems: a side remark links $c=1$ to $\theta=0$ instead of $\theta=1$, and one justification says "$H^2\ge1$" where it needs $H^2\ge4$. **Fix:** cite both reports.

## 6. Status of the first-round computation issues

| first-round issue | status in ../research-notes/A-tight-conditioning-fails.md |
|---|---|
| 1. The $\Omega(1)$ excess holds only along $n\asymp2^d$ | fixed: §5.3 items 1–2 and the new Proposition 5.2, whose proof and constants I checked (§3.4) |
| 2. The above-threshold claims need $c=o(n)$ | fixed: §0.2 item 8, §5.3 item 5, §8.3, and the $C_t$ paragraph ($C_1=5.828$; energy $(d+H)\epsilon_0^2$, both checked) |
| 3. Corollary 4.5: "=" for an upper bound; range of $d$ | fixed: $\epsilon\le\bar\epsilon_d$, "for all large $d$", any fixed $t>0$ |
| 4. The $\rho=1$ tube set | fixed: $\{0<y_iz_w(x_i)<2\ \forall i\}$ |
| 5. "Tends to" claims | fixed: Proposition 6.1(a′) adds the upper bound $1+(1+\sqrt{\epsilon'})^2$ (checked), and Remark 7.3 says "at least" |
| 6. §0 item 7 mixed Proposition 8.2(a) and (b) | fixed |
| 7(a)–(f). Numbers | fixed, except that the new $(2,60)$ entry from 7(d) is itself slightly off (issue 3) |
| 8. (R1) wording; $P$ used for two things | fixed: both quotations match their sources, and the path norm is now $\varpi$ |

## 7. Limits of this check

* **The suprema in Lemma 8.1 and Proposition 8.3 cannot be computed.** I checked these results step by step by hand, and checked their ingredients numerically, as in the first round. At $d\le6$, (8.1) is weaker than the trivial bound, so small-$d$ tests cannot falsify it.
* **Remark 3.4 gives no explicit $\sigma_0$.** Its uniform radius comes from equicontinuity. The quantitative bound (3.2) was tested only on a two-parameter objective.
* **The §9 optimizer runs are illustrations.** I checked the numbers they report against the script outputs, not whether the optimizer reached a global minimum.
* **../research-notes/B-tempered-likelihood.md and ../research-notes/E-finite-prior-scale.md were not re-refereed.** I checked that the statements ../research-notes/A-tight-conditioning-fails.md cites exist with the stated hypotheses, and read the verdicts of their referee reports.

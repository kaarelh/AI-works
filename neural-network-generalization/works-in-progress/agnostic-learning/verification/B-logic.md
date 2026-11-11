# Referee report on `../research-notes/B-tempered-likelihood.md` (Claim B, positive side of D): logic and definitions

**Lens.** Quantifiers, limit order, case splits, definitions against the brief and the cited repository sources, circularity, misapplied lemmas, missing hypotheses (widths, weight bounds, clipping, measurability, existence of minimizers).

**Verdict: minor fixes.** I checked every step of the main chain:

- Lemmas 2.1–2.3, 3.1, 5.1–5.3;
- Corollary 3.2;
- Proposition 6.1;
- Theorems 6.3 and 6.4;
- the route-1 chain (Proposition 4.1 as imported, Lemmas 4.2–4.3, Theorem 6.2).

The positive claim holds as stated in Theorems 6.3 and 6.4, with the quantifiers and limit order the brief asks for. I found no circularity, no misapplied lemma and no missing hypothesis in that chain.

I also checked the side results: Section 7 (Lemmas 7.1–7.2, Proposition 7.3, Theorem 7.4), Section 8 (Corollary 8.1) and Section 9 (Proposition 9.1, Lemma 9.2, Corollary 9.3). Their precise statements are correct, with three exceptions:

- one false sentence inside Proposition 9.1(c), which lacks a hypothesis (issue 1);
- one statement that is vacuous on part of its stated range (Corollary 8.1 at $H=1$, issue 2);
- several overstatements in summary and discussion text.

None of these touches the proof of Claim B. The list of issues is in Section 4.

Scripts and outputs for my independent checks are in `../checks/verify-B-logic/` (Section 5).

---

## 1. Statements compared against the sources

Each statement ../research-notes/B-tempered-likelihood.md imports or re-proves was compared with its source.

| ../research-notes/B-tempered-likelihood.md | source (checked verbatim) | match |
|---|---|---|
| model, energy $\kappa_N$, prior $\propto e^{-\kappa_N/(2\sigma^2)}$, likelihood $\mathcal N(z_w(x_i),c\sigma^2)$, $F_c=\kappa_N+c^{-1}\sum_i(z_w(x_i)-y_i)^2$, limit $\sigma\downarrow0$ at fixed $N,n,S$ | `../research-notes/problem-brief.md` §2 (SP$_c$); `paper.tex` eq. `energy`, eq. `strong-scales` | yes |
| Lemma 2.2 (cloning, per-layer bounds $d(d+1)B^2$, $2C^2B^2$, $2C^2B^2$) | `paper.tex` §"Cloning and the mass of a teacher tube", eq. `teacher-energy` | yes; ../research-notes/B-tempered-likelihood.md only needs $B>0$, while the source assumes $B\ge1$; the re-proof does not use $B\ge1$ |
| Lemma 2.1(b) vs. eq. `energy-lipschitz` ($\mathrm{Lip}\le K^{L/2}/\sqrt d$) | `paper.tex` proof of Prop. `energy-cover` | the AM–GM sharpening by $L^{L/2}$ is correct |
| Proposition 4.1 (parameters $r,s,D_T,\lambda,J,\Delta,P$, count $(1+2(J+1)/\Delta)^P$, cube version) | `paper.tex` Lemma `compression`, Prop. `energy-cover`, Remark `cube` | every parameter matches; the net size $(1+2\sqrt d/r)^d$ is the Remark `cube` version; the proof of Lemma `compression` is a sketch that defers to a companion paper (../research-notes/B-tempered-likelihood.md says so) |
| Lemma 3.1 (Laplace argument) | `paper.tex` proof of Thm. `strong` (normalizer lower bound from an open low-energy set; quadratic tail envelope) | same method, re-done for $e^{-F_c/(2\sigma^2)}$; Gaussian coordinates only, which is what the brief specifies |
| Lemmas 5.1–5.2 | `noisy-interpolation/README.md` §4, eqs. (12)–(15) | (12) = 5.1(iv), (13) = 5.1(v), (14) = path-norm step, (15) = Lemma 5.2 with the cube count $\log J\le(d+2)^2$ replaced by Sauer–Shelah. All re-proved; the statements agree |
| Lemma 7.2 | same README §§2–3 (sign corrections at accuracy $1/4$; $K_{\rm corr}\le dF_d+(H+5)Q+(H+5)A_s^{2/H}$) | a re-derivation for real values at accuracy $3t$, with a staircase in place of the binomial parity identity; it is self-contained and does not depend on the README |
| "proof template" | `slt-likelihood/README.md` §2 (concentration on $J_S\le E_\star+1$, then cover and Chernoff) | used only as a template |

The brief's Claim B asks for $0<\theta<\theta_L=1/(4(L-1))$, for near-minimizers, the Gibbs predictor and the posterior mean, with clipped or unclipped outputs. ../research-notes/B-tempered-likelihood.md proves more:

- clipped outputs for all $\theta<1/H$ (Theorem 6.3);
- unclipped outputs for all $\theta<1/L$ (Theorem 6.4).

Since $1/(4(L-1))<1/L\le1/H$ for every $L\ge2$, **the brief's full range is covered for both clipped and unclipped outputs**.

---

## 2. Audit of the main chain (Claim B)

### 2.1 Definitions and limit order

- **Near-minimizers** are $\mathcal N_\zeta^{(N)}(S)=\{F_{c,S}\le m_*+\zeta\}$, and the theorems use $\zeta=1$. For any fixed $\zeta=O(1)$ the same proof works with $K=n^\theta+\zeta$ and $c(E_*+\zeta)/n$ in place of $n^\theta+1$ and $c(E_*+1)/n$. This is a harmless convention, but Section 0 never states it (issue 9).
- **Limit order.** $n$, $S$ and $N$ are fixed, then $\sigma\downarrow0$. Every sample event used in Theorems 6.2–6.4 is built from Lemma 5.3 or Lemma 4.3 together with the Hoeffding event $\mathcal E_2$ for the fixed competitor $g$. None of them refers to $N$ or $\sigma$, which I checked line by line. The $\sigma$-threshold in the "stronger form" after Proposition 6.1 depends on $(N,n,c,d,H,\eta)$. It does not depend on $(S,D,g,\delta)$, because $\rho,\alpha,\ell_F,G,Z$ in Lemma 3.1 are defined over $\Omega\times[-1,1]^d$ and $([-1,1]^d\times[-1,1])^n$. This is the order the brief requires, and it matches `paper.tex` Thm. `strong`: "the scale threshold may depend on that finite width".
- **Widths.** The competitor enters only through its clone $w^g_N$, which exists at every $N\ge m$ (Lemma 2.2). So the restriction $N\ge m$ is both necessary for the proof and sufficient.
- **Competitor class.** $g$ has the repository architecture: no internal biases, with constants available through $\bar x$. This matches the brief (§2). Corollary 8.1 says so explicitly. This is a scope remark, not an error.

### 2.2 Step-by-step

**Lemma 2.1.**

- (a) $\lvert z_w\rvert\le\lVert v\rVert_1\le\sqrt N\lVert v\rVert_2=\sqrt{a_L}\le\sqrt{\kappa_N}$.
- (b) $\mathrm{Lip}\le\lVert v\rVert_2\prod_{\ell=1}^H\lVert W^\ell\rVert_F=d^{-1/2}\bigl(\prod_{\ell=1}^La_\ell\bigr)^{1/2}\le d^{-1/2}(\kappa_N/L)^{L/2}$. The constant input coordinate cancels because $\bar x-\bar x'=(0,x-x')$.

Both are correct for all $x,x'\in\mathbb R^d$.

**Lemma 2.2.** I re-derived the clone's preactivations and energies:

- $a_1=\frac dN\sum_jk_j\lvert U^1_{j,:}\rvert^2\le d(d+1)B^2$;
- $a_\ell=\sum_{j,j'}(k_j/k_{j'})(U^\ell_{jj'})^2\le2m^2B^2$, using $\lceil N/m\rceil\le2\lfloor N/m\rfloor$;
- $a_L=\sum_j(N/k_j)u_j^2\le2m^2B^2$, using $N/\lfloor N/m\rfloor<2m$.

All correct. $U=mB\ge\sup\lvert g\rvert$ is correct.

**Lemma 2.3.**

- (a) $\kappa_N(w)\le F(w)\le m_*+\zeta\le F(0)+\zeta=c^{-1}\sum y_i^2+\zeta\le n/c+\zeta$.
- (b) Drop one of the two nonnegative terms of $F(w)\le F(w')+\zeta$.
- (c) Take $w'=w^g_N$ in (b).

All correct. The correction to the brief ($n(U+1)^2/c$ in place of $nU^2/c$) is right. Part (a), which does not depend on the competitor, is what the main proof uses.

**Lemma 3.1.** Every inequality checks:

- $F$ is continuous, and coercive since $F\ge\lvert\Lambda w\rvert^2$. So $m_*$ is attained, $m_*\le F(0)\le n/c$, and $\mathcal N_\zeta$ is compact.
- $\Omega$, the closed 1-neighbourhood of a convex set, is convex and compact. On $\Omega$, $F$ is $\ell_F$-Lipschitz uniformly in $S$:
  - $\lvert\nabla\kappa\rvert=\lvert2\Lambda^2w\rvert\le2\lambda_{\max}\lvert\Lambda w\rvert$;
  - $(a-y)^2-(b-y)^2=(a-b)(a+b-2y)$.
- A minimizer lies in $E$, so the ball $B(w_*,\rho)$ with $\rho=\min\{1,\zeta/(4\ell_F)\}$ lies in $\Omega\cap\{F<m_*+\zeta/4\}$. Hence $Z_\sigma\ge v_P\rho^Pe^{-(m_*+\zeta/4)/(2\sigma^2)}$.
- The tail envelope uses $\alpha=\zeta/(8(n/c+\zeta))$, $\sigma^2\le\alpha/2$ (so $b=\alpha/(2\sigma^2)\ge1$ and $(1+t)e^{-bt}\le1$), and $F\ge\lvert\Lambda w\rvert^2$.
- The exponent gap is $(1-2\alpha)(m_*+\zeta)-m_*-\zeta/4\ge\tfrac34\zeta-2\alpha(n/c+\zeta)=\zeta/2$.

The final bound $\frac{(2\pi\sigma^2/\alpha)^{P/2}}{\det\Lambda\,v_P\rho^P}e^{-\zeta/(4\sigma^2)}$ is uniform over $S$. Correct.

**Corollary 3.2.**

- Items 1 and 4 are correct.
- Item 2 is correct (compactness plus continuity; the negation of the displayed hypothesis gives some $k$, and item 1 then applies).
- Item 3: the conclusion is correct, but the stated reason for tightness is incomplete for $\sigma$ bounded away from $0$ (issue 7). This is harmless, since only the limit $\sigma\downarrow0$ is used.

The two functionals $L_D(\operatorname{clip}z_w)\le4$ and $L_D(z_w)\le(\sqrt{\kappa_N}+1)^2\le2F+2$ satisfy $\Phi\le b(1+F)$, and both are continuous in $w$ by dominated convergence. Correct.

**Lemma 5.1.**

- (i), (ii) (Massart) and (iii): correct. I re-derived the scalar contraction step, including "repeat over the coordinates" with the earlier signs absorbed into $\Psi$.
- (iv): uses $\operatorname{clip}_t(u)=\frac12(\lvert u+t\rvert-\lvert u-t\rvert)$, sign symmetry, contraction applied to $\{(a_i\pm t)_i\}$, and $\mathbb E\lvert\sum\epsilon_i\rvert\le\sqrt n$. The clipping threshold $t$ is common to all coordinates, which is exactly what Lemma 5.2 needs. Correct.
- (v): I verified the integration by parts and the total mass $\tanh^2r+\operatorname{sech}^2r=1$, and also checked it by quadrature (Section 5).
- (vi): correct.

**Lemma 5.2.**

- $\Phi_1$ is symmetric because tanh is odd. $\operatorname{Clip}$ preserves symmetry and $0$.
- Representation, $\ell\ge2$: the weights $\lambda_i=W^\ell_{ji}\rho_i^{\ell-1}/\rho_j$ have $\sum\lvert\lambda_i\rvert=1$. So $u=\sum\lambda_iu_i$ is a convex combination of the points $\pm u_i\in\mathcal F_{\ell-1}$, and $u\in\mathcal F_{\ell-1}\subseteq[-1,1]^n$. Then $\tanh(\rho_ju)/\rho_j$ is a barycentre of $\{\operatorname{clip}_t(u)\}_{t\in[0,1]}$, by (v) with weights independent of the coordinate. So it lies in $\mathcal F_\ell$.
- Output: $z_w\vert_S\in P(w)\mathcal F_H$, and $P(w)=0$ forces $z_w\equiv0$.
- Path norm: AM–GM over the $H$ numbers $a_2,\dots,a_H,a_L$. Correct, including $H=1$, where $P=\lVert v\rVert_1\le\sqrt{a_L}$.
- First layer: open halfspaces have VC dimension $d+1$. Sauer–Shelah gives $\sum_{k\le d+1}\binom nk\le(n+1)^{d+1}$. Repeated sample points only reduce the count. For all but finitely many $T$ the sign vector has no zero entry, so $\Phi_1\subseteq\operatorname{conv}\mathcal D_S$. Then Massart with $R=\sqrt n$.

Correct. No boundedness of the $x_i$ is used, as claimed. The bound is uniform over widths because the representation holds at every $N$.

**Lemma 5.3.**

- Bounded loss $\psi\in[0,b]$, $\gamma$-Lipschitz in $u$, with $(b,\gamma)=(4,4)$ clipped and $((\sqrt K+1)^2,2(\sqrt K+1))$ unclipped. Lemma 2.1(a) makes $\operatorname{clip}_{\sqrt K}$ inactive on $\mathcal Z_K$.
- Countable reduction: for fixed $S$, the map $w\mapsto\mathbb E\psi-\hat{\mathbb E}_S\psi$ is continuous, and the closed ellipsoid is the closure of the rational points of the open one. So $\Phi(S)$ is a countable supremum and is measurable.
- McDiarmid with bounded differences $b/n$; symmetrization with a ghost sample; contraction (iii) conditionally on $S$, with 1-Lipschitz maps $\varphi_i=\psi(\cdot,y_i)/\gamma$.

Constants $2\gamma=8$ and $4(\sqrt K+1)$: correct.

**Proposition 6.1.**

- $\mathcal E_2$: one-sided Hoeffding for the fixed $g$, with losses in $[0,(U+1)^2]$; probability $\ge1-\delta/2$. Correct.
- Statement 1: the chain $L_D(\operatorname{clip}z_w)\le\hat L_S(\operatorname{clip}z_w)+\Psi\le\hat L_S(z_w)+\Psi\le\hat L_S(g)+c(E_*+1)/n+\Psi$ uses (1.1), Lemma 2.3(a) for $z_w\in\mathcal Z_K$ with $K=n/c+1$, and Lemma 2.3(c) with $\zeta=1$. Correct.
- Statements 2–3: Corollary 3.2 items 4, 3 and 1. The set $A$ is closed and contains $\mathcal N_1$. Correct.
- Statement 4: pointwise Jensen and Tonelli, where joint measurability holds because $(w,x)\mapsto z_w(x)$ is continuous. Correct.
- Unclipped version: $\mathbb E_\Pi\lvert z_w(x)\rvert\le\mathbb E_\Pi\sqrt F<\infty$. Correct.

**Theorem 6.3.**

- $K=n^\theta+1\le2n^\theta$ gives the middle term $8(2/H)^{H/2}D_nn^{-(1-\theta H)/2}$, and $\delta'=\delta/2$ gives the $4\sqrt{\ln(2/\delta)/(2n)}$ part. Correct.
- Sample-size arithmetic, with $\gamma=(1-\theta H)/2\in(0,\tfrac12]$:
  - $\ln(n+1)\le n^\gamma/\gamma$ for $n\ge1$;
  - the second entry is equivalent to $8(2/H)^{H/2}\sqrt{2(d+1)/\gamma}\,n^{-\gamma/2}\le\varepsilon/6$;
  - the third entry handles the $(H-1)/2$ part;
  - the first and fourth entries give $\varepsilon/3$ each, for a total of exactly $\varepsilon$.
- Every term is nonincreasing in $n$ after the majorization, so "for every $n\ge n_0$" is justified.
- The value $\theta=1/(H+2)$ balances the first two exponents.

I also checked numerically that $n\ge n_0$ implies $\mathrm{Exc}_n\le\varepsilon$, on 1872 parameter combinations with no violation (Section 5). Correct.

**Theorem 6.4.**

- $\sqrt{n^\theta+1}+1\le(1+\sqrt2)n^{\theta/2}$.
- The exponent is $\theta/2+\theta H/2-1/2=-(1-\theta L)/2$.
- The five sample-size entries each give $\varepsilon/6$, except the first, which gives $\varepsilon/3$.
- The fourth entry needs $\theta<1/2$, which follows from $\theta<1/L$.

Correct.

**Route 1 (Theorem 6.2, Lemmas 4.2–4.3).**

- Lemma 4.3: Hoeffding with range $[0,4]$, so $e^{-nt^2/8}$; union bound; the $4a$ Lipschitz transfer is applied twice. Correct.
- Lemma 4.2: I re-derived steps 1–4. The checks include:
  - $1+2\sqrt d/r\le(17dK/a)^{L/2}$;
  - $\Xi\le3dL\ell$;
  - $256\lambda^{-4}\Xi+1\le\bar J$ with $196608+1$;
  - $1+x\le2x$ and $J+1\le2J$ in the count;
  - $\ln\bar J\le\ln C_J+(2L+1)\ell$;
  - the second factor is at most $C_{\log}\ell$;
  - $\bar J\ge3d\ge d+2$.

  All correct. Numerically, on 192 grid cases the source's exact count is at most $\Gamma_L$, which is at most the polynomial form, with no violation.
- Theorem 6.2:
  - the constants $1088=17\cdot2\cdot32$;
  - $C_*$ for $L\ge3$ and for $L=2$;
  - $(a+b)^3\le4(a^3+b^3)$;
  - $\ln n\le\frac{6}{e\varrho}n^{\varrho/6}$;
  - the two halves of the $n_{\rm cov}$ condition.

  All correct. The route inherits the sketch status of the source's Lemma `compression`, as ../research-notes/B-tempered-likelihood.md states.

### 2.3 Missing-hypothesis checklist (main chain)

| hypothesis | where needed | supplied? |
|---|---|---|
| existence of a minimizer of $F_{c,S}$ | definition of $\mathcal N_\zeta$ | Lemma 3.1 (continuous and coercive) |
| learner width $N\ge m$ | clone in Lemma 2.3(c) | yes, in every statement |
| competitor weights bounded | $E_*$ and $U$ | yes ($B$); $B\ge1$ is not needed |
| labels in $[-1,1]$ | (1.1), Lemma 2.3(a), loss ranges | yes |
| $X\subseteq[-1,1]^d$ | Lemma 3.1 constants $G,Z$ | yes; Lemma 5.2 needs nothing |
| measurability of the sup-deviation | McDiarmid and symmetrization | yes (countable reduction) |
| measurability of $\Phi(w)$, joint measurability for Tonelli | Corollary 3.2, Proposition 6.1(4) | yes (continuity) |
| competitor chosen independently of $S$ | $\mathcal E_2$ | yes; in Corollary 8.1 the minimizer depends only on $D,n$ |
| integrability of $z_w$ under $\Pi_\sigma$ | posterior mean $\bar z_\sigma$ | yes ($\lvert z_w\rvert\le\sqrt F$, Gaussian tails) |

No circularity: Proposition 6.1 takes the uniform deviation bound as a hypothesis, and Lemma 5.3 (or Lemma 4.3) supplies it independently.

---

## 3. Audit of the side results (Sections 7–9)

**Section 7: correct.**

- Lemma 7.1(d): $\mathbb ES_1=M(1-1/M)^{M-1}\ge M/e$; $S_1$ has bounded differences $2$; $e^{-u^2/(2n)}$ with $u=M^{2/3}$.
- Lemma 7.2:
  - Parseval and Cauchy–Schwarz give $\sum_S\lvert\hat r(S)\rvert\le\sqrt s$.
  - Staircase: exact, with margin $\ge1$, $\lvert a\rvert^2\le k^2-k+1\le d^2$, $\ell^1$ norm $\le k+1$.
  - $1-\tanh b\le2e^{-2b}$.
  - Hoeffding over $M$ points with $m_t>2A_{\max}^2(d+1)\ln2/t^2$.
  - $a_2\le2A^2/R^{2H-2}\le2R^2$.
  - Chain: $\lvert z-g\rvert\le\frac{\lvert g\rvert^3}3\sum_{i=1}^{H-1}R^{-2i}\le\frac{9}{4R^2}\le t$.
- Proposition 7.3:
  - $W/c$ cancels via Lemma 7.1(a);
  - $\mathcal R(z_w)\le n\varepsilon_{c,t}$;
  - the posterior means are handled by convexity of $\mathcal R$ and Lemma 3.1.
- Theorem 7.4:
  - (a) Remark 6.5 with $w'=0$ holds at every width.
  - (b) $t=n^{-\theta/2}\le1/4$ iff $n\ge16^{1/\theta}$; $m_t=N_0(n)$; each term of $\varepsilon_n$ tends to $0$.

The sharpness conclusion follows. Under the brief's polynomial-sample-complexity reading, the noisy cube with $d=\log_2n$ refutes every polynomial bound once $\theta>1/H$. This uses $\varepsilon<1/e$ and $\delta$ small, which the brief's quantifiers allow.

**Section 8 (Corollary 8.1): correct for $H\ge2$.**

- $\theta=(1+8\alpha)/(H+2)<1/H$ iff $\alpha<1/(4H)$.
- $4\alpha-\theta=-\beta$.
- $(1-\theta H)/2=\beta$.
- $4+(U+1)^2\le8n^{4\alpha}$.
- $4\alpha-\frac12\le-\beta$ iff $\alpha\le H/16$.
- Compactness of the competitor class (zero padding) and continuity of $L_D$.

At $H=1$ the statement is vacuous for $\alpha\ge1/8$ (issue 2).

**Section 9: precise statements correct, with one false sentence (issue 1).**

- Proposition 9.1(a) and (b) are correct:
  - $\tanh s\ge s-s^3/3$ for $s\ge0$;
  - $t_H\ge\frac23\tilde t_H$;
  - the converse energy bound comes from Lemma 2.1(b).
- The arithmetic in 9.1(c) is correct: $(1+\frac5{4L})4^{1/L}\le3.25$ with equality at $L=2$, and $2^{1/L}/\sqrt L\le1$ (Section 5).
- Lemma 9.2: the induction $t_\ell\ge(\tanh1)^\ell\min\{1,G^{\ell-1}B\delta_0\}$ is correct.
- Corollary 9.3:
  - the case split (Case 1: infinitely many $n=2^d$ with $n/c\ge n^{1/H}\log_2^3n$; Case 2: the complement) is exhaustive;
  - in Case 1, $x\ln^2(1/x)$ is increasing on $(0,e^{-2})$, and the three terms tend to $0$;
  - in Case 2, $\eta\to0$ iff $\alpha\cdot\mathrm{ex}>L/(2H)$, with $\mathrm{ex}=L$ or $2L-1$, where $m=\lfloor n^\alpha\rfloor\ge n^\alpha/2$.

  All correct.

---

## 4. Issues

Severity is judged relative to the claim under review (Claim B and the positive side of D). Issues 1–2 are genuine errors in side statements. The rest are presentational.

1. **Proposition 9.1(c) needs the hypothesis $\theta<1/H$ (minor, a genuine error).**

   Proposition 9.1(c) is titled "Matching up to energy $\Theta(n^\theta)$ and no further". It asserts: "By Remark 6.5, every competitor with energy $o(n^\theta)$ is matched … So the competitor energy at which matching breaks down is of order $n^\theta$". The proposition places no restriction on $\theta$.

   - **For $H\ge2$ and $\theta>1/H$ this is false.** Theorem 7.4(b) shows that the zero competitor, which has energy $0$, is not matched on the noisy cube: the excess is $\ge1/e-o(1)$.
   - **For $H=1$ and $\theta\in(1/2,1)$ the sentence is not established.** The Hoeffding term of Remark 6.5, $(\sqrt{\kappa}+1)^2\sqrt{\ln(2/\delta)/(2n)}$, need not vanish when $\kappa=o(n^\theta)$ but $\kappa\gg\sqrt n$.
   - The proof of (c) says only "the remaining claims are arithmetic", so this sentence is not proved anywhere.

   The Discussion after Corollary 9.3 repeats the claim ("competitors below it are matched up to $n^{-\theta}\times$energy").

   *Fix.* Add the hypothesis $\theta<1/H$ to the matching sentence. For $H=1$, either add $\theta<1/2$, or replace Hoeffding for $g$ by Bernstein after reducing to $L_D(g)\le1$ (compare with the zero network).

2. **Corollary 8.1 is vacuous at $H=1$ for $\alpha\in[1/8,1/4)$ (minor).** The corollary allows $\alpha\in(0,1/(4H))=(0,1/4)$ when $H=1$, but its exponent $\beta=\min\{(1-4\alpha)/3,\ \tfrac12-4\alpha\}$ is $\le0$ for $\alpha\ge1/8$ (Section 5, check 3). So the bound $\Xi_nn^{-\beta}$ does not vanish there. The inequality is true but empty. The bottleneck is Hoeffding for the competitor, with range $(U+1)^2\le4n^{4\alpha}$.

   *Fix.* Restrict to $\alpha<1/8$ when $L=2$. Alternatively, use the Bernstein route of issue 1, after which the last term is $O(n^{2\alpha-1/2}+n^{4\alpha-1})$ and the full range $\alpha<1/4$ survives.

3. **The sample size quoted under Theorem 6.3 is for a different bound (minor, presentational).** The text says that at $L=3$, $d=10$, $m=B=1$, $\varepsilon=0.1$, $\delta=0.05$, $\theta=1/4$, "the bound $\mathrm{Exc}_n\le\varepsilon$ first holds at $n\approx10^{13.4}$". But `sample_sizes.py` evaluates the bound with $K=n^\theta+1$, before the simplification $K\le2n^\theta$ that defines the displayed $\mathrm{Exc}_n$.

   - The displayed $\mathrm{Exc}_n$ at $n=10^{13.4}$ equals $0.146>0.1$.
   - It first drops below $0.1$ at $n\approx10^{14.09}$, and below $0.01$ at $10^{18.24}$ rather than $10^{17.49}$ (Section 5, check 1).
   - The closed form $n_0\approx10^{29.2}$ is correct.

   The script's docstring also numbers the theorems inconsistently with ../research-notes/B-tempered-likelihood.md: it calls route 2 "Theorem 6.2" and route 1 "Theorem 6.1".

   *Fix.* Either quote $10^{14.1}$, or say that the number refers to the bound with $K=n^\theta+1$.

4. **Section 0, "the user's formulation" row: "plus $O(n^{-\beta})$" omits a factor (minor, presentational).** Corollary 8.1 proves $\Xi_nn^{-\beta}$ with $\Xi_n\ni8(2/H)^{H/2}\sqrt{2(d+1)\ln(n+1)}$, so the rate is $\tilde O(n^{-\beta})$, with $d$- and $\delta$-dependent constants. The prose of Corollary 8.1 states it correctly.

   *Fix.* Write $O_L\bigl((d^2+\sqrt{d\log n}+\sqrt{\log(1/\delta)})\,n^{-\beta}\bigr)$ in the table.

5. **The Section 9 Discussion makes two universal claims that are not proved (minor).**

   - (a) "Competitors whose minimal energy exceeds it by a constant factor **cannot** be matched." Proposition 9.1 shows only that **some** competitor with energy $\le3.25(n^\theta+1)$ is not matched. The universal statement is false in general. For example, put a steep competitor's difficult region on tiny test mass: the learner's excess is then at most that mass. Proposition 9.1(c) itself says energies in $[\epsilon n^\theta,3.25(n^\theta+1)]$ are undecided.
   - (b) "With $c=1$ the budget is $n$, so far steeper competitors are matched." Nothing in ../research-notes/B-tempered-likelihood.md proves matching at $c=1$. The capacity term at $K=n+1$ does not vanish.

   *Fix.* Change (a) to "there exist competitors with energy $O(n/c)$ that are not matched". Mark (b) as a heuristic, or delete it.

6. **Section 7.5(4) (dimension $d=n^\kappa$) omits a constraint (minor).** "The proof gives $\theta<(1-\kappa)/H$" ignores the first term $(E_*+1)n^{-\theta}$. For a general competitor $E_*\ge d(d+1)B^2\asymp n^{2\kappa}B^2$, which also requires $\theta>2\kappa$. The window is then nonempty only for $\kappa<1/(2H+1)$ at fixed $B$. The statement is correct for the zero competitor, which is the noisy-cube case of Section 7.

   *Fix.* State both constraints, or restrict the remark to the noisy cube.

7. **Corollary 3.2(3): incomplete reason for tightness (minor, harmless).** "Tightness holds because $\Pi_\sigma(\mathcal N_1)\to1$ and $\mathcal N_1$ is compact" covers only small $\sigma$, not the stated family $(\Pi_\sigma)_{0<\sigma<1}$. For $\sigma\in[\sigma_1,1)$, use the following bound, where $Z_\sigma$ is nondecreasing in $\sigma$:
   $$\Pi_\sigma\{\lvert\Lambda w\rvert>R\}\le Z_{\sigma_1}^{-1}\int_{\lvert\Lambda w\rvert>R}e^{-\lvert\Lambda w\rvert^2/2}\,dw .$$
   Only limits as $\sigma\downarrow0$ are used, so nothing downstream is affected.

8. **Section 11 says "the sample events never depend on $N$ or $\sigma$"; Remark 6.5 is an exception (minor).** In Remark 6.5 the event $\mathcal E_2(w')$ depends on $w'\in\mathcal W_N$. When $w'$ is the energy-penalized minimizer at width $N$, the event depends on $N$, so the remark's conclusion is per-width, not simultaneous over $N$. The theorems themselves are unaffected:
   - Theorem 7.4(a) uses $w'=0$, the same function at every width;
   - Theorems 6.2–6.4 use the clone of a fixed $g$, whose function does not depend on $N$.

   *Fix.* Say in Remark 6.5 that the event depends on the function $z_{w'}$. Simultaneity over $N$ holds whenever $z_{w'}$ does not depend on $N$; otherwise a union bound is needed.

9. **Summary text is less precise than the theorems (minor, presentational).**

   - The Section 0 "main theorem" row says "every near-minimizer … test MSE". It should say "test MSE of the clipped output" and specify the tolerance $\zeta=1$ (any fixed $\zeta$ works with $E_*+\zeta$).
   - After Theorem 6.3, "its degree in $E_*$ (hence in $d,m,B$) is $1/\theta$" is imprecise. The degree in $d$ is $\max\{2/\theta,\ 2/(1-\theta H)\}$, and the second entry of $n_0$ dominates when $\theta>1/(H+1)$.
   - Section 11 says the claim-D guess $n^{1-1/(H+1)}$ "is the unclipped threshold". It is this proof's unclipped threshold. The learner's unclipped threshold is open on $[1/L,1/H]$, as ../research-notes/B-tempered-likelihood.md says elsewhere.

10. **Scope: the posterior means (remark, not an error).** For $\theta\in[1/L,1/H)$ the main theorem covers the mean of the clipped outputs, $\bar f_\sigma=\mathbb E_\Pi\operatorname{clip}z_w$. It covers neither the Bayes model average $\bar z_\sigma$ nor its clip $\operatorname{clip}\bar z_\sigma$, and $\operatorname{clip}\mathbb E\ne\mathbb E\operatorname{clip}$ in general. ../research-notes/B-tempered-likelihood.md is explicit about this (Section 0, open item (i)). But the brief's "posterior mean (BMA) … with clipped outputs" most naturally reads as $\operatorname{clip}\bar z_\sigma$. The write-up should say plainly that this predictor is controlled only for $\theta<1/L$ (Theorem 6.4).

11. **Corollary 9.3: "critical exponent" is not defined (minor).** The negative half for width-1 classes is a precise statement. It uses either the noisy cube in dimension $\log_2n$ (Case 1) or a two-point law in dimension $1$ (Case 2). "No choice of $c(n)$ works" is correct when "works" means excess $\le\mathrm{poly}(d,\log1/\delta)\cdot o_n(1)$ uniformly over laws on $[-1,1]^d$, for all $d$. Under a fixed-$d$ definition, Case 1 alone does not refute.

    *Fix.* Define "works" explicitly. The brief's polynomial-sample-complexity notion is the one that makes the claim correct.

---

## 5. Independent checks (`../checks/verify-B-logic/`)

Run from that folder as `python3 check_rates.py > check_rates.out` and `python3 check_lemmas.py > check_lemmas.out`.

| check | result |
|---|---|
| displayed $\mathrm{Exc}_n$ of Theorem 6.3 at $L=3$, $d=10$, $m=B=1$, $\theta=1/4$, $\delta=0.05$ | first $\le0.1$ at $10^{14.09}$ ($0.146$ at $10^{13.4}$); with $K=n^\theta+1$, first $\le0.1$ at $10^{13.38}$; closed form $n_0=10^{29.23}$ |
| closed-form $n_0$ implies displayed $\mathrm{Exc}_n\le\varepsilon$ ($H\le4$, $d\le50$, three $(m,B)$, several $\theta,\varepsilon,\delta$; $n\in\{n_0,10n_0,10^3n_0\}$) | 1872 cases, 0 violations |
| Corollary 8.1 at $H=1$ | $\beta=0$ at $\alpha=1/8$, $\beta<0$ beyond |
| Proposition 9.1(c) constants | $(1+\frac5{4L})4^{1/L}\le3.25$ (equality at $L=2$); $2^{1/L}/\sqrt L\le1$ |
| Lemma 4.2: exact source count $\le\Gamma_L\le$ polynomial form, and $J\le\bar J$ ($L\in\{2,3,4\}$, $d\in\{1,2,10,100\}$, $K\in\{1,1.5,10,10^3\}$, $a\in\{1,0.3,10^{-2},10^{-4}\}$) | 192 cases, 0 violations |
| Lemma 5.1(v) by adaptive quadrature, 200 random $(r,u)$ | max error $3.2\times10^{-14}$ |
| $\ln(n+1)\le n^g/g$ ($g\in(0,\tfrac12]$, $1\le n\le10^{12}$) | min slack $1.31>0$ |
| Lemma 7.2 step 6, $\frac13\sum_{i=1}^{H-1}R^{-2i}\le\frac2{3R^2}$ for $R^2\ge2$ | holds ($H\le11$) |

---

## 6. What is proved, stated with its quantifiers

Fix $L=H+1\ge2$, $\theta\in(0,1/H)$ and $c(n)=n^{1-\theta}$. For every $d\ge1$, every compact $X\subseteq[-1,1]^d$, every Borel law $D$ on $X\times[-1,1]$, every depth-$L$ competitor $g$ of the repository architecture with width $m$ and weights in $[-B,B]$, every $\delta\in(0,1)$ and every $n\ge1$, there is an event $\mathcal E=\mathcal E(D,g,n,\delta)$ with $D^n(\mathcal E)\ge1-\delta$, not depending on the learner width or on $\sigma$. On $\mathcal E$, for every learner width $N\ge m$:

1. every $w$ with $F_{c,S}(w)\le\min F_{c,S}+1$ has $L_D(\operatorname{clip}z_w)\le L_D(g)+\mathrm{Exc}_n$;
2. $\Pi_{\sigma,N,S}\{L_D(\operatorname{clip}z_w)>L_D(g)+\mathrm{Exc}_n\}\to0$ as $\sigma\downarrow0$, and every weak limit point is carried by $\operatorname{argmin}F_{c,S}$;
3. $\limsup_{\sigma\downarrow0}\mathbb E_{\Pi_\sigma}L_D(\operatorname{clip}z_w)\le L_D(g)+\mathrm{Exc}_n$;
4. $\limsup_{\sigma\downarrow0}L_D(\mathbb E_{\Pi_\sigma}\operatorname{clip}z_w)\le L_D(g)+\mathrm{Exc}_n$.

Here $\mathrm{Exc}_n$ is the expression in Theorem 6.3, and $\mathrm{Exc}_n\le\varepsilon$ for all $n\ge n_0(d,m,B,\varepsilon,\delta)$, which is polynomial at fixed $(L,\theta)$.

The $\sigma$-threshold in items 2–4 depends on $(N,n,d,H)$ and the target accuracy, not on $(S,D,g,\delta)$. The same holds for unclipped outputs, $\bar z_\sigma$ and $\operatorname{clip}\bar z_\sigma$, when $\theta\in(0,1/L)$ (Theorem 6.4). For $H\ge2$, the exponent $1/H$ cannot be raised for clipped predictors (Theorem 7.4).

This is Claim B with a larger range of $\theta$ than the brief asked for.

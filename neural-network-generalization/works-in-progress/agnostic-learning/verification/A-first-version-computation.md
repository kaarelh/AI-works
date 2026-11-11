# Referee report on `A-first-version.md`: computation

*Lens: recompute every constant, exponent, energy bound, probability estimate and concentration inequality. Subject: Claims A, A′ and the TUBE variants (`A-first-version.md`, 846 lines). 11 November 2026. Scripts and their outputs are in `../checks/verify-A-first-version-computation/`.*

## 1. Verdict: `minor_fixes`

No arithmetic or exponent error in `A-first-version.md` breaks a proof. I re-derived every constant in Lemma 2.1, Lemma 3.2, Theorem 4.4, Corollaries 4.5–4.6, Propositions 5.1 and 6.1–6.5, Theorem 7.2, Lemma 8.1 and Propositions 8.2–8.3. Each is correct as used. Every numerical claim I could recompute reproduces, apart from six rounding or grid artefacts (issue 7). The limit order is respected throughout: $d,N,n,c$ and the sample are fixed before $\sigma\to0$. The two uniformity statements, Theorem 4.4(iv) and Theorem 7.2(iv), are justified by Remark 3.4.

These points need edits:

1. **Limit order in §5.2 item 2.** The excess is $\Omega(1)$ only along $n\asymp2^d$. At fixed $d$, every near-minimizer has excess $O(2^d/n)$ once $n\gg2^d d$. Proposition 5.1 is unaffected, because (P$_L$) is uniform in $d$. The sentence "refuted for every $\alpha$ and every $o(1)$" is too strong.
2. **Range of the above-threshold claims.** §0 item 7, §5.2 item 5 and §8.3 drop the $ct/n$ term of Proposition 8.3(a). They need $c=o(n)$.
3. **Corollary 4.5.** Its display writes "$=$" for an upper bound, and it needs $a_d\le1$, which holds only for large $d$.
4. **A wrong formula.** The $\rho=1$ tube set in §6.2 is $\{0<y_iz_w(x_i)<2\ \forall i\}$, not $\{y_iz_w(x_i)>0\ \forall i\}$.
5. **Two "tends to" claims.** Proposition 6.1(a) and Remark 7.3 say "tends to", but only lower bounds are proved.
6. **§0 item 7 mixes Proposition 8.2(a) and (b).** It quotes the constant from (a) under the hypothesis of (b).

`A-first-version-logic.md` also raises issues 1, 2, 3, 5 and 6. I re-derived each of them independently, and §4 gives the computations behind them. Issue 4 and most of the numerical discrepancies in issue 7 are not in that report.

## 2. What was read

I read `../research-notes/problem-brief.md`, all of `A-first-version.md`, and the sources it cites:

* `NNG/side-results/continuous-domains/source/paper.tex`: eqs. `energy` (l. 293), `teacher-energy` (l. 303), `posterior` (l. 130), `tube-mass` and `A` (ll. 341, 399), and `energy-lipschitz` (l. 475), which gives ${\rm Lip}\le K^{L/2}/\sqrt d$. Also the Laplace estimates in the proof of Theorem `strong` (ll. 517–521).
* `NNG/works-in-progress/noisy-interpolation/README.md`, §§2–4: eqs. (2)–(16), with $a_d=\max\{1,\frac12\log(4\sqrt{2d})\}$, $F_d$, $Q$, $A_s^2$ and $D_{d,H}=\sqrt2(d+2)+\frac{H-1}2$.
* `NNG/works-in-progress/slt-likelihood/README.md`: §2, where the residual budget is $cK$ with $K=E_\star+1$, and §3, where $\mathbb E[z^2\mid\text{hidden}]\le N^{-\gamma}$.

Every cited label exists and says what `A-first-version.md` uses it for. `A-first-version.md` re-proves each repository statement it depends on. Its Lemma 3.1(b), $(\kappa_N/L)^{L/2}/\sqrt d$, is the sharper AM–GM form of `energy-lipschitz`, as the brief anticipated.

## 3. Key inequalities, re-derived

### 3.1 Lemma 2.1 (real-valued memorizer)

**Coefficient budget.** $\alpha_d=\frac12\log(4\sqrt{2d})$ gives $2e^{-2\alpha_d}=1/(2\sqrt{2d})$ exactly. By Lemma 2.2(b),(c), for $k\le d$,
$$\lvert c_{k,\alpha_d}\rvert\ge\frac1{\sqrt{2k}}-\frac1{2\sqrt{2d}}\ge\frac1{2\sqrt{2k}}.$$
The closed forms of $c_{k,\infty}$ follow from $\sum_{j\le t}(-1)^j\binom qj=(-1)^t\binom{q-1}t$, and $2\binom{2m-1}{m-1}=\binom{2m}m$. Together with $1/\tanh1=1.3130<2\sqrt2$ and Cauchy–Schwarz (2.4), this gives $A\le2\sqrt{2d}\sum_S\lvert\hat r(S)\rvert\le2\sqrt{2ds}$, so $A^2\le8ds$.

**Row norms.** $\|\omega_{S,u}\|^2=\alpha_d^2(b_{|S|}+|S|)\le(d+1)\alpha_d^2$. Also $\|\omega_\emptyset\|^2=1\le2\alpha_1^2=1.5014$.

**Hoeffding width.** Each summand $(A\xi_t(x)-r(x))/m$ lies in an interval of length $2A/m$. So
$$\Pr\big[\lvert g(x)-r(x)\rvert\ge a/2\big]\le2\exp\Big(-\frac{2(a/2)^2}{m(2A/m)^2}\Big)=2e^{-ma^2/(8A^2)} .$$
The union bound over $2^d$ points succeeds iff $m>8A^2(d+1)\log2/a^2$. This is implied by $m=N_0>64\log2\cdot d(d+1)s/a^2$, where $64\log2=44.36$.

**Energy.** With $k_t\ge\lfloor N/m\rfloor\ge N/(2m)$:
* $\kappa^{(1)}\le d(d+1)\alpha_d^2$;
* $\kappa^{(2)}=\frac{NA^2}{m^2R^{2H-2}}\sum_tk_t^{-1}\le\frac{2A^2}{R^{2H-2}}\le2R^2$, using $A^2\le R^{2H}$;
* $\kappa^{(\ell)}=N^2(R/N)^2=R^2$ for $3\le\ell\le H$;
* $\kappa^{(L)}=N\cdot N(R/N)^2=R^2$.

So $\kappa_N\le d(d+1)\alpha_d^2+(H+1)R^2$, with $R^2=\max\{A^{2/H},\frac9{2a}\}\le\max\{(8ds)^{1/H},\frac9{2a}\}$.

**Chain.** Unrolling $e_j\le\lvert\tilde y_j\rvert^3/3+Re_{j-1}$ gives $\lvert Ry_{H-1}-g\rvert\le\frac{\lvert g\rvert^3}3\sum_{i=1}^{H-1}R^{-2i}$. Since $\sum_{i\ge1}R^{-2i}=1/(R^2-1)\le2/R^2$ iff $R^2\ge2$, and $\lvert g\rvert\le\frac32$, the error is at most $\frac{2(3/2)^3}{3R^2}=\frac{9}{4R^2}$. This is $\le a/2$ iff $R^2\ge9/(2a)$, which is the stated gain. $H=2$ is the case with the single term $R^{-2}$.

### 3.2 Lemma 3.2 and Corollary 3.3 (strong-prior concentration)

Put $\theta=t/(4(F^*+t))\in(0,\frac14]$.

* **Monotonicity.** $\frac{d}{du}\log\big[(1+u)^pe^{-(1-\theta)u/(2\sigma^2)}\big]\le p-\frac{1-\theta}{2\sigma^2}$, and this is $\le0$ when $\sigma^2\le3/(8p)$, since $1-\theta\ge\frac34$.
* **Exponent.** $(1-\theta)(F^*+t)-(F^*+t/4)=t-\frac t4-\frac t4=\frac t2$, giving $e^{-t/(4\sigma^2)}$.
* **Gaussian factor.** $\int e^{-\theta w^\top\Gamma_Nw/(2\sigma^2)}dw=(2\pi\sigma^2/\theta)^{P/2}(\det\Gamma_N)^{-1/2}=\big(8\pi\sigma^2(F^*+t)/t\big)^{P/2}(\det\Gamma_N)^{-1/2}$.

So (3.2) is exactly right. In (3.3), $\bar z-m_\sigma=-(1-p_\sigma)m_\sigma+\int_{\mathcal N_t^c}z_w$, with $\lvert m_\sigma\rvert\le\sqrt{F^*+t}$ and $\lvert z_w\rvert\le\sqrt{\kappa_N}\le\sqrt{F}$.

### 3.3 Theorem 4.4 and Corollaries 4.5–4.6

**Theorem 4.4.**
* $M\epsilon=c(K_{\rm mem}+t)+\lambda Ma^2=c(K_{\rm mem}+t)+na^2$. This is exactly the budget of Lemma 4.1(b), with $\Delta(z_{w_0})\le\sum_xk_xa^2=na^2$.
* Lemma 4.2(b) with $B=M\epsilon$ and $\varsigma=0$ gives $L\ge1+(\sqrt{Q/M}-\sqrt\epsilon)_+^2$.
* On $\mathcal E$, $\sqrt{2n\log(1/\delta)}/M=\sqrt{2\lambda\log(1/\delta)/M}$.
* For the posterior means, $\sqrt{|\mathcal S|}\,\varsigma/\sqrt M\le\varsigma$ and $F^*\le F(0)=n/c$.

**Corollary 4.5.**
* Since $a_d=(\max\{c_d,1\}/2^d)^{1/3}$, we have $c_d/(a_d2^d)\le\max\{c_d,1\}^{2/3}2^{-2d/3}$ and $\lambda_da_d^2=\lambda_d(\max\{c_d,1\}/2^d)^{2/3}$. Both tend to $0$ because (4.4) forces $c_d=o(2^d)$.
* With $\delta_d=e^{-2^{d/2}}$, $\sqrt{2\lambda_d\log(1/\delta_d)/2^d}=\sqrt{2\lambda_d}\,2^{-d/4}$.
* $N_0\le44.36\,d(d+1)2^{5d/3}+1\le45\,d(d+1)2^{5d/3}$, since $a_d^{-2}\le2^{2d/3}$ and $s\le2^d$.
* $\alpha_d=0.8664+\frac14\log d\le1.5\log(d+1)$: at $d=1$ the values are $0.866\le1.040$, and $\frac{1.5}{d+1}\ge\frac1{4d}$ for all $d\ge1$. Hence $d(d+1)\alpha_d^2\le4.5d^2\log^2(d+1)$.
* (4.4) is equivalent to $c=o(n^{1-1/H}d^{-1/H})$, because $n^{-1/H}d^{2-1/H}\log^2d\to0$ when $n\asymp2^d$.

**Corollary 4.6.** $\mathbb E[Q_\eta\mid\text{inputs}]=\sum_{x\in\mathcal S}V(x)/k_x\ge v_0\sum_x\mathbf 1[k_x\ge1]/k_x$. Each term lies in $[0,4]$, and replacing one pair changes at most two terms.

### 3.4 Concentration and probability constants

All of these were recomputed from first principles.

| place | quantity | difference / range | inequality obtained | as stated |
|---|---|---|---|---|
| Lemma 2.1, Step 3 | $g(x)-r(x)$ (Hoeffding) | range $2A/m$ | $2e^{-ma^2/(8A^2)}$ | ✓ |
| Lemma 4.3(b) | $Q$ (McDiarmid) | $2$ | $e^{-2u^2/(4n)}=e^{-u^2/(2n)}$ | ✓ |
| Lemma 4.3(c) | Bin vs Poi (Le Cam) | — | $d_{\rm TV}\le np^2=n/M^2$ | ✓ |
| Corollary 4.6 | $Q_\eta$ (McDiarmid) | $8$ | $e^{-2u^2/(64n)}=e^{-u^2/(32n)}$ | ✓ |
| Proposition 6.1(b) | $Q_\eta$ (Hoeffding) | range $4$ | $e^{-2u^2/(16n)}=e^{-u^2/(8n)}$ | ✓ |
| Lemma 6.4(b) | $\lvert S_1\rvert$ (McDiarmid) | $1$ | $e^{-2(\mu_1/2)^2/n_1}=e^{-\mu_1^2/(2n_1)}$ | ✓ |
| Proposition 8.3(a) | $\Phi$ in $y$ | $2\sqrt{K_0}$ | $u=\sqrt{2nK_0\log(2/\delta)}$ at level $\delta/2$ | ✓ |
| Proposition 8.3(b) | $\Psi$ in $x$ | $K_0/n$ | $u=K_0\sqrt{\log(2/\delta)/(2n)}$ at level $\delta/2$ | ✓ |

The Lemma 6.4(b) constants also check. $(1-e^{-1})/16=0.03951\ge0.039$ and $(1-e^{-1})^2/2=0.1998\ge0.19$. The bound $\mu_1\ge(1-e^{-1})n_1$ for $n_1\le M$ follows from concavity of $1-e^{-u}$ on $[0,1]$, and $n_1n_2\ge n(n-1)/4$ holds for both parities. The $\lambda$-scale exponents $\frac\lambda8(1-e^{-\lambda/2})M$ and $\frac{(1-e^{-\lambda/2})^2}{\lambda}M$ are correct.

### 3.5 Claim A′ (Theorem 7.2, Lemma 7.1)

* **Cluster variation.** $\frac{(K_2/L)^{L/2}}{\sqrt d}\cdot r\sqrt d=(K_2/L)^{L/2}\cdot\frac1n(L/K_2)^{L/2}=\frac1n$.
* **Step 4.** $(a+\frac1n)\sqrt n+\frac{\sqrt n}n=a\sqrt n+\frac2{\sqrt n}$, which is exactly the second part of $E$. With $\sqrt{u+v^2}\le\sqrt u+v$, this gives $\Delta(\zeta)\le2E\sqrt W+E^2\le2E\sqrt n+E^2$, since $W=\sum_pk_p(1-\bar y_p^2)\le n$.
* **Lemma 7.1(d).** Pairing at distance $r/2$ on a set of measure $\frac12$ gives $\lvert\mathbb E[gy\mid p]\rvert\le\Lambda r/4$. The bound is sharp: for $g=\Lambda\lvert x_1\rvert$,
  $$\mathbb E[gy\mid p]=\Lambda\Big[\int_0^{1/2}(1-r\upsilon)\,d\upsilon-\int_{1/2}^1(1-r\upsilon)\,d\upsilon\Big]=\frac{\Lambda r}4 .$$
  Also $\Lambda\le B\sqrt m\cdot B\sqrt{md}\cdot(Bm)^{H-1}=B^Lm^H\sqrt d$.
* **Radius.** $3^{3/2}=5.196$, so $r\approx5.2\,n^{-5/2}$ at $H=2$. Then $\log_2r=2.377-2.5d$, which gives $-47.62$, $-72.62$ and $-97.62$ at $d=20,30,40$.

### 3.6 Section 8

**Lemma 8.1.**
* *Halfspace count.* $\log J\le(d+1)\log(2^d+1)\le(d+1)^2\log2$, since $2^d+1\le2^{d+1}$.
* *Massart.* ${\rm Rad}(\mathcal F_1)\le\sqrt{2\log J/m}$.
* *Clipping.* ${\rm Rad}({\rm Clip}\,\mathcal G)\le{\rm Rad}(\mathcal G)+\frac1{2\sqrt m}$, via $\mathbb E\sup_{\tau\in[0,1]}\tau\sum\varepsilon_i=\frac12\mathbb E\lvert\sum\varepsilon_i\rvert$. The one-sided contraction needs no $\phi(0)=0$.
* *Mixture identity.* The normalized-tanh identity follows by integration by parts, with $\int_0^u\tanh^2(\rho\tau)\,d\tau=u-\tanh(\rho u)/\rho$.
* *Path norm.* $\le(\kappa_N/H)^{H/2}$, by AM–GM over the $H$ terms $\kappa^{(2)},\dots,\kappa^{(H)},\kappa^{(L)}$.

**Proposition 8.2.** (a) gives $(K/H)^{H/2}\ge(1-a)\sqrt s/D_{d,H}$. (b) follows from polarization, $\sum\varepsilon f=\frac12(\sum f^2+s-\sum(f-\varepsilon)^2)$. The ratio of construction to lower bound is $\frac{H+1}H\big(8dD_{d,H}^2/(1-a)^2\big)^{1/H}=O(d^{3/H})$.

**Proposition 8.3.**
* The comparison with $w=0$ gives $c\kappa+\sum z_i^2\le ct+2\sum y_iz_i$.
* With $K_0=n^\vartheta+t$, the leading exponents are $(\vartheta H-1)/2$ and $(\vartheta(H+1)-1)/2$.
* The *Above* threshold is $c\gg n^{1-1/H}(2D_{d,H})^{2/H}/H$. `A-first-version.md` drops the harmless constant factor $2^{2/H}$.
* The window is $d^{2/H}/d^{-1/H}=d^{3/H}$.

### 3.7 $\beta(\lambda)$

To 7 digits, the closed form $e^{-\lambda}({\rm Ei}(\lambda)-\gamma_E-\log\lambda)$, the series and the integral agree. The values are $\beta(1)=0.4848291$, $\beta(1.5)=0.5173506$, $\lambda^*=1.502861$ and $\beta(\lambda^*)=0.5173514=(1-e^{-\lambda^*})/\lambda^*$. The derivative $\beta'=h-\beta$ takes values in $(-0.095,1)$, with supremum $1$ at $\lambda\to0$. Exact binomial $\beta_n$ for $d\le20$ lies within Le Cam's $n/M^2$ of $\beta(n/M)$. Remark 4.7 gives $(\sqrt{\beta(1)}-0.1)^2=0.35557$.

## 4. Independent numerical checks

I wrote each check from the formulas. None is copied from `A_scripts/`, except v6 and v7, which test that folder's optimizer.

| script | what it tests | result |
|---|---|---|
| `v1_constants.py` | $\alpha_d$ identities; $c_{k,\infty}$ closed form and $\lvert c_{k,\infty}\rvert\ge(2k)^{-1/2}$ in exact rationals, $k\le60$; $\min\lvert c_{k,\alpha_d}\rvert2\sqrt{2k}$ over $1\le k\le d\le80$ at 60 digits; chain bound (2.3) at 50 digits for $H\le20$; $\beta$, $\lambda^*$; exact binomial $\beta_n$; Table 4.1 and $c_{\max}$ with continuous optimisation in $a$; Corollary 4.5 threshold; Proposition 6.3, Proposition 8.2 and A′ numbers | all as claimed except issue 7. Minimum $1.3372$ at $(d,k)=(2,2)$. Chain error/bound $\le0.99999998$. Chain error $\le0.5035\cdot a/2$ at $R^2=9/(2a)$ |
| `v2_memorizer.py` | Lemma 2.1 built at its **own** width $m=N_0(d,s,a)$, $s=\min(n,M)$, in 8 configurations: $d\in\{3,\dots,6\}$, $H\in\{2,3,4\}$, $a\in\{1,\frac12,\frac14\}$, $N\in\{N_0,2N_0+7,3N_0+7\}$. Dense matrices at $d=3$; exact group-wise energy otherwise | expansion error $\le2\cdot10^{-15}$; $A^2\le8ds$ with large slack (e.g. $148.8$ vs $3072$); Hoeffding succeeded at the first draw; $\max\lvert z-r\rvert<a$; $\kappa_N\le K_{\rm mem}$ in every case |
| `v3_laplace_bound.py` | (3.2) on a 2-parameter objective $F=w^\top\Gamma w+\frac1c\sum_i(v\tanh(ux_i)-y_i)^2$, 84 combinations of $t\in\{\frac12,1,2,4\}$, $p\in\{0,\frac12,1,2\}$, $\sigma^2\in[0.02,0.4]$; $\delta$ certified on a polar grid | max LHS/RHS $=1.9\cdot10^{-3}$ |
| `v4_probability.py` | Monte Carlo of $Q$ (up to $2\cdot10^5$ samples) and of heteroscedastic $Q_\eta$; exact $\Pr[\text{no conflict}]=\mathbb E[2^{\lvert\mathcal S\rvert-n}]$ by an occupancy recursion | $\mathbb EQ=M\beta_n$ within MC error; all empirical tails below the stated bounds; exact no-conflict probability below the Lemma 6.4 bound in all 11 cases (e.g. $1.3\cdot10^{-7}$ vs $2.3\cdot10^{-2}$ at $M=1024$, $n=256$), and the bound below its simplified form; monotone in $n$ |
| `v5_Aprime_and_capacity.py`, `v5b_pairing.py` | pairing bound with a paired (low-variance) estimator; Step 4 algebra on $2\cdot10^5$ random admissible instances; output, path-norm and Lipschitz bounds on 300 random nets; Lemma 2.1 against Proposition 8.2(a) on a grid of 12 depths, 46 dimensions, 41 sizes and 6 accuracies; clip contraction; halfspace counts | pairing equality for $g=\Lambda\lvert x_1\rvert$; 200 random nets within the bound; 0 algebra violations; path norm/$(\kappa/H)^{H/2}\le0.589$; gradient/$\sqrt{\prod\kappa^{(\ell)}/d}\le0.9999$; $K_{\rm mem}/K_{\rm low}\ge5.39$ (below 1 would have meant one of the two lemmas is false); $J=14,104,1882$ for $d=2,3,4$ |
| `v6_gradcheck.py` | analytic gradient of `A_scripts/spc_small_d.py` against finite differences | agreement to $5\cdot10^{-9}$ |
| `v7_spc_rerun.out` | §9 illustration with fresh seeds | at $c=1$ the optimizer memorizes: test excess $0.546$ and $0.565$, unseen-atom part $0.116$ and $0.168$, certified lower bound for all near-minimizers $0.087$ and $0.099$. At $c=16$ it returns the zero network |
| `v8_limit_order.py` | issues 1 and 2 | see below |

## 5. Issues

### Issue 1 (minor): the $\Omega(1)$ excess holds only along $n\asymp2^d$

**Location.** §5.2 item 2, line 463: "That reading is refuted for every $\alpha$ and every $o(1)$, because … the excess is $\Omega(1)$."

**Computation.** At fixed $d$, compare a near-minimizer with $w_0=0$, as in the proof of Lemma 4.1(b). This gives $c\kappa_N(w)+\Delta(z_w)\le ct+\Delta(0)$, where $\Delta(0)=\sum_xk_x\bar y_x^2$ and $\mathbb E\Delta(0)=\mathbb E\lvert\mathcal S\rvert\le M$. When every atom is seen,
$$L_{D_d}(z_w)-1=\frac1M\sum_xz_w(x)^2\le\frac{2}{M}\Big(\sum_x(z_w-\bar y)^2+\sum_x\bar y^2\Big)\le\frac{2\,(2\Delta(0)+ct)}{M\,k_{\min}} .$$
This is $O(M/n)$ with high probability once $n\gg M\log M$, because then $k_{\min}\ge n/(2M)$. Monte Carlo at $d=8$, $c=t=1$ gives a median of this bound of $0.094$ at $n=64M$ and $0.019$ at $n=256M$. The lower bounds there are $\beta(64)=0.016$ and $\beta(256)=0.004$.

**Consequence.** Take the brief's informal reading, "test loss $\le$ min over width-$n^\alpha$ networks $+\,\varepsilon_d(n)$ with $\varepsilon_d(n)=o(1)$". The cube example refutes it only if $\varepsilon_d(2^d)\to0$ as $d\to\infty$. That holds, for example, when $\varepsilon$ does not depend on $d$, or when $\varepsilon_d(n)\le{\rm poly}(d)\,n^{-\gamma}$. If $\varepsilon_d(n)$ may vanish arbitrarily slowly in $n$ at each fixed $d$, nothing is refuted, because at fixed $d$ the excess is $O(2^d/n)$. Proposition 5.1 is unaffected, because (P$_L$) carries $d$ inside $\mathsf p(d,\dots)$. The same computation proves §5.2 item 1's "eventually consistent" (line 462), which `A-first-version.md` states without proof.

**Fix.** State that the refutation of the $o(1)$ reading requires the $o(1)$ term to vanish along $n=2^d$, which holds if it is uniform in $d$ or polynomial in $d$ times a negative power of $n$. Add the display above as the proof of item 1.

### Issue 2 (minor): the above-threshold claims need $c=o(n)$

**Locations.** §0 item 7 (line 29), "for $c\ge n^{1-\vartheta}$"; §5.2 item 5 (line 466), "switches off once $c\ge n^{1-\vartheta}$"; §8.3 *Above* (line 780), "whenever $c\gg n^{1-1/H}D_{d,H}^{2/H}/H$".

**Computation.** Proposition 8.3(a) has the term $ct/n$, which does not vanish when $c\gtrsim n/t$. The inclusion below shows that this slack is real and not an artefact of the proof. Put $C_t=2(1+\sqrt{t/2})^2/t$, so $C_1=5.83$. If $c\ge C_tn$, every $w$ with $\kappa_N(w)\le t/2$ has $\lvert z_w\rvert\le\sqrt{t/2}$ and
$$F_{c,S}(w)\le\frac t2+\frac nc\big(1+\sqrt{t/2}\big)^2\le t\le\inf F_{c,S}+t .$$
So $\mathcal N_t\supseteq\{\kappa_N\le t/2\}$. That set contains networks with nonzero, $n$-independent outputs on seen atoms, so "seen-atom excess $\to0$" fails for some near-minimizers. Proposition 8.3 itself is stated for $c=n^{1-\vartheta}$ and is correct for $\vartheta>0$.

**Fix.** Use $n^{1-\vartheta}\le c=o(n)$, or let $t=t_n$ with $ct_n=o(n)$.

### Issue 3 (minor): Corollary 4.5's display and its range

**Location.** Lines 368–372.

**Problem.**
* The displayed $\epsilon_d$ replaces $\max\{\cdot,\cdot\}$ by a sum and $s$ by $n_d$. It is therefore an upper bound on $\epsilon$ of (4.3), not an equality. The direction is harmless, since a larger $\epsilon$ gives a smaller $\underline e$.
* Lemma 2.1 needs $a_d\le1$, that is, $\max\{c_d,1\}\le2^d$. This holds for large $d$, because (4.4) gives $c_d=o(2^d)$. The corollary nevertheless asserts (i)–(iv) without the qualifier.
* Proposition 5.1 (R3) fixes an arbitrary $t>0$ (line 445), while Corollary 4.5 assumes $t\in(0,1]$. Every term of $\epsilon_d$ still tends to $0$ for any fixed $t$, because $c_dt/2^d\to0$, so the extension costs one line.

**Fix.** Write $\epsilon_d\le$; add "for all $d$ with $a_d\le1$"; drop the restriction $t\le1$.

### Issue 4 (minor, wrong formula): the $\rho=1$ tube set

**Location.** §6.2, line 569: "$U_{1,S}=\{w:y_iz_w(x_i)>0\ \forall i\}$. This constrains only signs."

**Computation.** For $y=1$, $\lvert z-1\rvert<1$ means $0<z<2$. For $y=-1$ it means $-2<z<0$. So
$$U_{1,S}=\{w:0<y_iz_w(x_i)<2\ \forall i\},$$
which also caps $\lvert z_w(x_i)\rvert$ below $2$. The paragraph's conclusions still hold: the interpolation argument gives the vacuous bound $(b-\rho)^2=0$, and the infimum of $\kappa_N$ over the open set need not be attained. The case is left open, so nothing downstream changes.

**Fix.** Replace the formula, and replace "constrains only signs" with "constrains signs and caps the training outputs at $2$".

### Issue 5 (minor): "tends to" where only a lower bound is proved

**Locations.** Proposition 6.1(a) (line 478) and §0 item 5 (line 22): "test MSE tending to $2$". Remark 7.3 (line 672): "the learner's risk tends to $1+\beta(\lambda)$".

**Computation.** For Proposition 6.1 at $n=M$, every atom is seen once. So $\sum_x(z_w(x)-y_x)^2\le n\epsilon'$ gives the missing upper bound $L\le1+(1+\sqrt{\epsilon'})^2$ for near-minimizers, and likewise for $m_\sigma$ by Jensen and for $\bar z$ by (3.3). For Remark 7.3 no upper bound is available. A fraction $\approx e^{-\lambda}$ of the clusters is unseen, and near-minimizers are uncontrolled there (Remark 4.8).

**Fix.** Add the one-line upper bound to Proposition 6.1. In Remark 7.3 write "is at least $1+\beta(\lambda)-o(1)$".

### Issue 6 (minor): §0 item 7 mixes Proposition 8.2(a) and (b)

**Location.** Line 28: "memorizes most sign patterns … needs $K\ge H\big(\frac{(1-a)\sqrt s}{D_{d,H}}\big)^{2/H}$."

**Problem.** That constant is (a), which assumes **all** patterns are fitted to sup-accuracy $a$. The "most patterns" statement (b) has $\frac{(1-q)(1-\theta)\sqrt s}{2D_{d,H}}$ inside the bracket.

**Fix.** Quote (a) with "all sign patterns", or quote (b).

### Issue 7 (trivial): reported numbers that do not reproduce exactly

**(a) §8.2 "Numbers"** (line 739). At $(H,d)=(2,40)$, the lower bound is $2\cdot2^{19}/D_{40,2}=2.1499\cdot10^4$, i.e. $2.1\cdot10^4$. `A-first-version.md` prints $2.2\cdot10^4$: its script prints `2.150e+04`, and the text rounds that a second time. The other three numbers ($5.6278\cdot10^7$, $2.8763\cdot10^5$, $1.4513\cdot10^3$) are right.

**(b) Remark 4.7** (line 422). With $a$ optimised continuously, the largest admissible $c$ at $(2,30)$ is $29.25$, not "about $28$", which is the log-grid value $28.09$. At $(3,30)$ it is $1582.8$, consistent with "$1.6\cdot10^3$".

**(c) Remark 4.7** (line 418). "Within $0.01$ of $\beta(\lambda)$ from $d\approx40$ at $H=2$" fails at $\lambda=1.5$ by a hair: $0.5174-0.5071=0.0103$.

**(d) Table 4.1.** At $(2,60)$ the optimising $a$ is about $2.0\cdot10^{-10}$, not $2.8\cdot10^{-10}$. The grid gave $2.8\cdot10^{-10}$ at $\lambda=1$ and $2.4\cdot10^{-10}$ at $\lambda=1.5$. $\underline e$ is flat there, and every tabulated $\underline e$ and $K_{\rm mem}$ reproduces to the printed digits. With continuous $a$, $N_0$ reaches $4.7\cdot10^{42}$ at $(2,60)$, so "$10^{14}$ to $10^{42}$" holds as an order of magnitude.

**(e) §9 item 3** (line 805). "$\max\lvert\beta'\rvert\le0.981$" is the maximum on the grid $[0.01,20]$. The supremum over $(0,\infty)$ is $1$, since $\beta'(10^{-3})=0.9985$. So the constant $1$ in Lemma 4.3(d) is sharp. State the range.

**(f) §9 item 2** (line 799). "With the Hoeffding $m$": `check_memorizer.py` computes that $m$ from the realized $A$, not from $N_0$, and the $(4,2)$ run used $m=2000>1815$. No run in `A_scripts/` used the lemma's width $N_0$. `v2_memorizer.py` does, and confirms Lemma 2.1.

### Issue 8 (trivial, presentational)

* §5.1 (R1), line 443. "Scale thresholds depend on width and sample size" fits the slt-likelihood theorem. In `paper.tex` Theorem `strong`, $\sigma_0$ "does not depend on $D,n,\delta$". (R1) is more lenient than both, so the refutation is unaffected.
* $P$ denotes the parameter count (line 39, Lemma 3.2) and the path norm (line 711, Lemma 8.1). Rename one of them.

## 6. Limits of this check

* **Lemma 8.1 cannot be falsified numerically at small $d$.** For $d\le6$ and $H\ge2$, $D_{d,H}\ge\sqrt{2^d}$, so (8.1) is weaker than the trivial bound $m(K/H)^{H/2}$ at every $m\le2^d$. For larger $d$, a test would need the global supremum over networks, which optimisation only bounds from below. I verified the lemma step by step by hand. I also checked its ingredients numerically (clip contraction, mixture identity, path norm, halfspace counts) and its consistency with Lemma 2.1.
* **Remark 3.4 has no explicit radius.** Its uniform radius $\delta$ comes from equicontinuity, so no explicit $\sigma_0$ is available to check. The quantitative bound (3.2) was tested on a two-parameter toy only, where $P=2$.
* **The §9 optimisation runs are illustrations.** Their certified lower bounds use only forward-pass values, so they do not depend on whether the optimizer found a global minimum. They are floating-point evaluations, not proofs.

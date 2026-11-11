# Referee report (computation lens): depth two, `../research-notes/red-team.md` §5

**What was refereed.** This report covers `../research-notes/red-team.md` §5 ("Depth two ($L=2$) with $c=1$"):

- Theorem 5.1 (partial memorization on the cube), its constants $\vartheta_c=1/(18dc+1)$, $E_0=c(dF_d+1)+2$, the width threshold $N\ge72dn^3\ln(2M)+2$, the asymptotic form $\gamma(\lambda)(18dc+1)^{-2}(1-o(1))$, and $\gamma(1)=0.0999$, $\max\gamma=0.1018$ at $\lambda=1.256$;
- Corollary 5.2 (refutes the polynomial-sample inequality, "does not refute the $+o(1)$ formulation") and its numerical parenthetical;
- Proposition 5.3 (Hadamard atoms, $d=M$) and the remark after it;
- the lemmas these use: Lemma 1.2 (atoms; parts (a), (b)), Lemma 1.3 (concentration), Lemma 2.1(2) (depth-two memorizer), and Lemma 1.1 for the $\sigma\downarrow0$ limits;
- for completeness, the "positive side at $L=2$" paragraph and the §5.4 numerics table.

Repository inputs re-read: `NNG/works-in-progress/noisy-interpolation/README.md` §2 (eqs. (2)–(7): Fourier $\ell^1$ bound, parity coefficients (3), slope $a_d$, identity (4), row bound $F_d$, Hoeffding sampling) and §3 (eq. (8)–(10), $H=1$ readout). Scripts and outputs: `../checks/verify-RT-depth2-computation/` (Appendix).

## Verdict: minor fixes

1. **Theorem 5.1 is correct.** I re-derived every constant and every inequality in the proof, and I checked the bookkeeping on explicitly built networks:
   - exact constructions at $d=3,\dots,6$ with widths up to $5.7\cdot10^6$ neurons;
   - the energy bound $\kappa_N(w_t)\le dF_d+18dt^2Q$, the residual bound $\mathcal R(tg)\le(1-t)^2G+n(ta+a^2/4)$, and the chain $cF-W\le c\,dF_d+n(ta+a^2/4)+G[18dct^2+(1-t)^2]$ hold in all 128 checked cases;
   - the output equals $tg$ to $2.4\cdot10^{-15}$.

   The bracket minimum, the limits and the constants $\gamma(1)=0.0998941$ and $\max\gamma=0.101816$ at $\lambda=1.256431$ are confirmed. I found no arithmetic or exponent error in the proof.
2. **Corollary 5.2's main claim is correct.** For every $c\le\mathrm{poly}(d)$, depth-two SP$_c$ violates the polynomial-sample inequality of BRIEF §1.
3. **Corollary 5.2's closing remark is right only for $c$ bounded below (Issue 1).** The remark says the result does not refute the "$+o(1)$" formulation, "since $\varepsilon_d\asymp1/\log^2n$". That holds when $dc\to\infty$, for example at fixed $c$. The corollary's own range, $c\le\mathrm{poly}(d)$, also contains $c=O(1/d)=O(1/\log n)$, and there the conclusion reverses:
   - at $c=\kappa/d$, Theorem 5.1 itself gives a **constant** excess $\gamma(\lambda)(18\kappa+1)^{-2}$, for example $0.02497$ at $\kappa=1/18$;
   - when $dc\to0$, the $t=1$ memorizer together with Lemma 1.2(a) gives excess $\beta(\lambda)-o(1)$.

   So at depth two the "$+o(1)$" formulation **is** refuted for SP$_c$ with $c=O(1/\log n)$. The same scope slip appears in §2.3 A3 ("Theorem 5.1 refutes only the polynomial one") and in §6.4 ("Open: constant excess at depth two with $n$ superpolynomial in $d$"). Both should be restricted to $c\gg1/\log n$, for example $c=1$.
4. **Proposition 5.3 is correct.** Every identity holds to floating-point precision for $M\in\{16,\dots,4096\}$ at widths $N\in\{1,2,7\}$:
   - $a_j\cdot a_k=M\delta_{jk}$, $u\cdot a_k=\bar y_k\mathbf 1_T(k)$, $\lVert u\rVert^2=Q/M$;
   - $\kappa_N=\epsilon^2Q+\epsilon^{-2}=2\sqrt Q$, error at most $\epsilon^2/3$, $\mathcal R\le n/(9Q)$.

   Two small points: the proof needs $Q>0$, which holds on the event of Lemma 1.3; and the hypothesis $c=o(\sqrt M)$ can be relaxed to $c\le\kappa\sqrt M$ with $\kappa<\sqrt{\beta(\lambda)}/2$, which still gives a constant excess (Issue 5).
5. **Minor numerical and presentational points** (Issues 2–7):
   - The parenthetical "positive from $d\approx30$ on, about $2\cdot10^{-7}$" is loose: the bound is $1.9\cdot10^{-8}$ at $d=30$ and reaches about $2\cdot10^{-7}$ only for $33\le d\le40$, with maximum $2.26\cdot10^{-7}$ at $d=35$.
   - The width threshold $72dn^3\ln(2M)+2$ is an artefact of choosing $a=1/n$. Taking $a=1/d$ gives $O(n\log^4n)$ with the same asymptotic bound.
   - Several constants are loose; these are optional improvements, not errors.
   - The §5.4 numerics reproduce.

---

## 1. Inputs and what was checked

| Step | Source | Check | Result |
|---|---|---|---|
| $\sum_S\lvert\hat r(S)\rvert\le\lVert r\rVert_2$ | README eq. (2); red-team Lemma 2.1 Step 1 | Parseval + Cauchy–Schwarz; exact on 16 sampled instances | ✓ |
| $\lvert c_k\rvert=\binom{2m}m/4^m\ge1/\sqrt{2k}$ | README eq. (3) | formula exact for $k\le40$ (120-digit arithmetic) | ✓ |
| $\lvert c_{k,a_d}\rvert\ge1/(2\sqrt{2k})$ | README, after (3) | $\min\lvert c_{k,a_d}\rvert2\sqrt{2k}=1.3372$ over all $1\le k\le d$, $d\le60$ and $d\in\{80,100,150,200,300\}$ (red-team checked $d\le16$, $k\le14$) | ✓ |
| identity (4) and the exact mixture $r=\sum w_\rho\tanh(\rho\cdot\bar x)$ | README (4); Lemma 2.1 Step 2 | built explicitly, max error $5.6\cdot10^{-16}$; total mass $\le A_0=3\sqrt d\lVert r\rVert_2$ | ✓ |
| rows $\lVert\omega\rVert^2\le F_d$ | README; Lemma 2.1 Step 2 | max row$^2$ $3.9$–$12.1$ vs $F_d=101$–$449$ ($d=3$–$6$) | ✓ (very loose; Issue 4) |
| Hoeffding $2Me^{-m_0a^2/(8A_0^2)}<1$ | Lemma 2.1 Step 3 | range $[-A_0,A_0]$, deviation $a/2$: exponent $2m(a/2)^2/(2A_0)^2=ma^2/(8A_0^2)$; first random draw always succeeded | ✓ |
| groups $k_j\ge N/(2m_0)$, first layer $\le dF_d$ | Step 4 | $\lfloor y\rfloor\ge y/2$ for $y\ge1$; explicit networks | ✓ |
| readout $\le2t^2A_0^2$, output $=tg$ | Step 5 | $N\frac{t^2A_0^2}{m_0^2}\sum_j k_j^{-1}\le2t^2A_0^2$; explicit networks, output error $\le2.4\cdot10^{-15}$ | ✓ |
| (1.1), Lemma 1.2(a),(b) | Lemma 1.2 | algebra; 300 adversarial instances (exact minimizers of $\sum f^2$ under $\mathcal R(f)\le B$) | ✓, no violation |
| Lemma 1.3 moments and probability | Lemma 1.3 | exact $\mathrm{Var}(S^2)$, exact $\mathrm{Var}(V)$, McDiarmid constants, Chebyshev; Monte Carlo | ✓ (conservative) |
| bracket, $N_1$ budget, limits, $\gamma$ | Theorem 5.1 proof | sympy; mpmath; Lemma 1.1 inequality | ✓ |
| Hadamard identities | Proposition 5.3 | explicit, $M\le4096$ | ✓ |

## 2. Lemma 2.1(2): the depth-two memorizer

**Statement used.** For $r:\{-1,1\}^d\to[-1,1]$, $A_0=3\sqrt d\lVert r\rVert_2$, $m_0=\lceil8A_0^2\ln(2M)/a^2\rceil+1$ and $N\ge m_0$: there is $g$ with $\sup\lvert g-r\rvert\le a/2$ such that, for every $t\in[0,1]$, a width-$N$ depth-two network computes $tg$ exactly with $\kappa_N\le dF_d+2t^2A_0^2$.

1. **Fourier.** With $\hat r(S)=M^{-1}\sum_xr(x)\chi_S(x)$, Parseval gives $\sum_S\hat r(S)^2=M^{-1}\lVert r\rVert_2^2$, and Cauchy–Schwarz over $M$ coefficients gives $\sum_S\lvert\hat r(S)\rvert\le\lVert r\rVert_2$. ✓
2. **Parities.** The preactivations $\sum_{j\in S}x_j-b_k$ are odd integers, so they are nonzero. Then
   $$
   \sup\lvert\operatorname{sign}-\tanh(a_d\,\cdot)\rvert=1-\tanh a_d\le2e^{-2a_d}\le\frac1{2\sqrt{2d}}\le\frac1{2\sqrt{2k}},
   $$
   because $a_d\ge\tfrac12\ln(4\sqrt{2d})$. A Fourier coefficient moves by at most the sup-norm change, so $\lvert c_{k,a_d}\rvert\ge\lvert c_k\rvert-\frac1{2\sqrt{2k}}\ge\frac1{2\sqrt{2k}}$. Hence $\lvert c_{k,a_d}\rvert^{-1}\le2\sqrt{2k}\le2\sqrt2\sqrt d<3\sqrt d$. The empty set costs $1/\tanh1=1.313<3\sqrt d$. Rows $a_d(-b_k,u_S)$ have squared norm $a_d^2(k+b_k^2)\le(d+1)a_d^2\le(d+1)(d+2)^2<F_d$. ✓

   *Numerics.* `lemma21_depth2_exact.py` builds the full signed mixture for random samples at $d=3,\dots,6$. It reproduces $r$ to $5.6\cdot10^{-16}$. Its total mass $\sum_S\lvert\hat r(S)\rvert/\lvert c_{\lvert S\rvert}\rvert$ is $0.27$–$0.35$ of $A_0$ (Issue 4).
3. **Sampling.** The variables $A_0\tanh(\omega_j\cdot\bar x)$ lie in $[-A_0,A_0]$. Hoeffding at deviation $a/2$ gives $2\exp(-2m_0(a/2)^2/(2A_0)^2)=2\exp(-m_0a^2/(8A_0^2))$. A union bound over $M$ inputs leaves this below 1 because $m_0>8A_0^2\ln(2M)/a^2$. ✓ Every random draw met $\sup\lvert g-r\rvert\le a/2$ on the first try; the largest observed ratio $\sup\lvert g-r\rvert/(a/2)$ was $0.52$.
4. **First layer.** $\frac dN\sum_jk_j\lVert\omega_j\rVert^2\le dF_d$ since $\sum_jk_j=N$. ✓
5. **Readout.** The readout weight on each copy of feature $j$ is $tA_0/(m_0k_j)$, so the output is $t\frac{A_0}{m_0}\sum_j\tanh(\omega_j\cdot\bar x)=tg$. The readout energy is
   $$
   N\sum_jk_j\Bigl(\frac{tA_0}{m_0k_j}\Bigr)^2=\frac{Nt^2A_0^2}{m_0^2}\sum_j\frac1{k_j}\le\frac{Nt^2A_0^2}{m_0^2}\cdot m_0\cdot\frac{2m_0}N=2t^2A_0^2 .
   $$
   ✓ On explicit networks, $\kappa_N$ ranges from $3.1$ to $1786$ against bounds of $303$ to $6105$. For example, at $d=6$, $t=1$, $N=2.6\cdot10^6$: $\kappa_N=1786$ against $6105$.

## 3. Theorem 5.1, step by step

Write $e_x=g(x)-\bar y_x$ for $x\in T$, so $\lvert e_x\rvert\le a/2$.

**3.1 Residual of $tg$.** Expanding,
$$
\mathcal R(tg)=\sum_Tk_x\bigl((t-1)\bar y_x+te_x\bigr)^2=(1-t)^2G-2t(1-t)\sum_Tk_x\bar y_xe_x+t^2\sum_Tk_xe_x^2\le(1-t)^2G+nt\Bigl[(1-t)a+\tfrac{ta^2}4\Bigr].
$$
This is at most $(1-t)^2G+n(ta+a^2/4)$, which is what the report states. With $a=1/n$ the extra term is at most $t+1/(4n)\le5/4\le2$. ✓

**3.2 Energy.** $\lVert r\rVert_2^2=\sum_T\bar y_x^2=Q$, so $A_0^2=9dQ$ and $\kappa_N(w_t)\le dF_d+18dt^2Q$. Since $k_x\ge1$, $Q\le G$; also $Q\le s\le n$. ✓

**3.3 Chain.** $F_{c,S}=\kappa_N+\frac1c(\mathcal R+W)$, so $cF_{c,S}-W=c\kappa_N+\mathcal R$, and
$$
cF_{c,S}(w_t)-W\le c\,dF_d+2+G\bigl[18dct^2+(1-t)^2\bigr].
$$
✓ Checked on explicit networks, for example at $d=6$, $t=\vartheta_1$: $49.55\le2734.1$.

**3.4 Bracket.** For $\alpha t^2+(1-t)^2$ with $\alpha=18dc$, sympy gives the minimizer $t=1/(\alpha+1)=\vartheta_c$, the value $\alpha/(\alpha+1)=1-\vartheta_c$, and second derivative $2(\alpha+1)>0$. Also $\vartheta_c\in(0,1]$, as Lemma 2.1(2) requires. ✓

**3.5 Near-minimizers.** For $w\in\mathcal N_1$,
$$
\mathcal R(z_w)=c(F-\kappa_N)-W\le cF(w_{\vartheta_c})+c-W\le(1-\vartheta_c)G+c(dF_d+1)+2=(1-\vartheta_c)G+E_0 .
$$
✓ Clipping is the projection onto $[-1,1]\ni\bar y_x$, so it does not increase $\mathcal R$. ✓

**3.6 Lemma 1.2(b).** $\mathcal R(f)=\sum_Tk_xf^2-2\sum_xfS_x+G$, so $2\sum fS\ge\vartheta G-E_0$. Cauchy–Schwarz gives $\sum_xf^2\ge(\vartheta G-E_0)_+^2/(4V)$. ✓

*Numerics.* I solved the KKT problem $\min\sum_Tf^2$ subject to $\mathcal R(f)\le B$ exactly ($f_x=\mu k_x\bar y_x/(1+\mu k_x)$). In 300 random instances, with $d=4$–$10$, $n/M\in[0.3,2.5]$ and random $(\vartheta,E_0)$, neither (a) nor (b) is ever violated. Bound (b) is $0.75$ of the true minimum at the median and $0.991$ at best, so it is nearly tight in some cases.

**3.7 Asymptotics.** On the event of Lemma 1.3, $G=Mp_d\pm2n^{2/3}$ and $V=n\pm n^{2/3}$, so
$$
\frac{(\vartheta_cG-E_0)^2}{4MV}=\gamma(\lambda)\vartheta_c^2\,(1+o(1))\cdot\Bigl(1-\frac{E_0}{\vartheta_cG}\Bigr)^2,\qquad\frac{E_0}{\vartheta_cG}\approx\frac{18c^2d^5}{0.63\cdot2^d}\to0
$$
for $c\le\mathrm{poly}(d)$. ✓ Constants (`constants_t51.py`):
- $\gamma(1)=0.0998941$;
- the stationarity condition $2\lambda=e^\lambda-1$ gives $\lambda^*=1.256431$ and $\gamma(\lambda^*)=0.101816$;
- $\beta(1)=0.484829107=e^{-1}(\mathrm{Ei}(1)-\gamma_E)$, and $\arg\max\beta=1.502861$ with $\max\beta=0.517351$.

All are as stated.

**3.8 Width.** $m_0\le8\cdot9dQ\ln(2M)n^2+2\le72dn^3\ln(2M)+2$ uses $Q\le n$, and the threshold does not depend on the sample. ✓ For example, at $d=4$, $a=1/16$: $m_0=2.3\cdot10^6\le4.1\cdot10^6$.

**3.9 Limits.** Lemma 1.1 applies:
- to the Gibbs risk with $\Phi=L_D(z_w)=1+M^{-1}\sum z_w^2\le1+F$;
- to posterior means with $\Phi=\mathcal R\le cF$, together with Jensen ($\mathcal R(\mathbb E_\Pi z)\le\mathbb E_\Pi\mathcal R(z)$);
- separately to $\mathbb E_\Pi\operatorname{clip}z_w$, using $\mathcal R(\operatorname{clip}z)\le\mathcal R(z)$.

Lemma 1.1 gives $\limsup\mathbb E_\Pi\mathcal R\le\sup_{\mathcal N_1}\mathcal R$. Lemma 1.2(b) with $E_0+\eta$, $\eta\downarrow0$, then gives the liminf bound. I re-checked Lemma 1.1's key inequality: the maximum of $(1+t)e^{-st}$ over $t\ge0$ is at most $\max(1,1/s)$, which gives $(1+t)e^{-t/2\sigma^2}\le(1+2\sigma^2/\alpha)e^{-(1-\alpha)t/2\sigma^2}$. I also re-checked the choice of $\alpha$. ✓

**3.10 Explicit values** (`constants_t51.py`, $c=1$, $\lambda=1$; "event" is the worst case on the Lemma 1.3 event, "surrogate" uses $G=(1-e^{-1})M$, $V=M$ as `bounds_table.py` does):

| $d$ | 29 | 30 | 31 | 33 | 35 | 40 | 60 |
|---|---|---|---|---|---|---|---|
| surrogate | 0 | $1.98\cdot10^{-8}$ | $9.85\cdot10^{-8}$ | $2.04\cdot10^{-7}$ | $2.26\cdot10^{-7}$ | $1.91\cdot10^{-7}$ | $8.55\cdot10^{-8}$ |
| event | 0 | $1.93\cdot10^{-8}$ | $9.76\cdot10^{-8}$ | $2.03\cdot10^{-7}$ | $2.26\cdot10^{-7}$ | $1.91\cdot10^{-7}$ | $8.55\cdot10^{-8}$ |
| $\gamma\vartheta_1^2$ | $3.65\cdot10^{-7}$ | $3.41\cdot10^{-7}$ | $3.20\cdot10^{-7}$ | $2.82\cdot10^{-7}$ | $2.51\cdot10^{-7}$ | $1.92\cdot10^{-7}$ | $8.55\cdot10^{-8}$ |

The Appendix A values ($2.3\cdot10^{-7}$, $1.9\cdot10^{-7}$, $8.5\cdot10^{-8}$ at $d=35,40,60$) are confirmed.

## 4. Corollary 5.2

**Main claim: correct.** Fix $\delta\in(0,1)$, take the zero competitor (width 1, weights $0\le B=1$), $N=72dn^3\ln(2M)+2\ge m$, and $\varepsilon_d=\gamma(\lambda)/(3(18dc+1)^2)$. If $c\le\mathrm{poly}(d)$, then $1/\varepsilon_d=\mathrm{poly}(d)$, so $n=\lceil\lambda2^d\rceil>p(d,1,1,1/\varepsilon_d,\log(1/\delta))$ for large $d$. On an event of probability tending to 1, the excess is at least $3\varepsilon_d(1-o(1))\ge2\varepsilon_d>\varepsilon_d$. At $c=1$ the explicit bound reaches $2\varepsilon_d$ from $d=33$ on. This negates BRIEF §1's inequality: one $n\ge p(\cdot)$ suffices, and the inequality is required for every $N\ge m$. The claim holds for all $0<c\le\mathrm{poly}(d)$, including $c\to0$. ✓

**Closing remark: scope error (Issue 1).** "It does not refute the '$+o(1)$' formulation, since $\varepsilon_d\asymp1/\log^2n$." In general $\varepsilon_d\asymp(1+dc)^{-2}$. This equals $1/\log^2n$ only when $c\asymp1$, and it tends to 0 only when $dc\to\infty$. Inside the stated range $c\le\mathrm{poly}(d)$ there are two other regimes (`small_c_and_width.py`, worst case on the event, $\lambda=1$):

| $c$ | bound (b) of Thm 5.1, $d=30/60/200$ | bound (a$'$) below, $d=30/60/200$ |
|---|---|---|
| 1 | $1.9\cdot10^{-8}$ / $8.5\cdot10^{-8}$ / $7.7\cdot10^{-9}$ | 0 |
| $1/(18d)$ | $0.0248$ / $0.0250$ / $0.0250$ ($\to\gamma/4=0.02497$) | 0 |
| $1/d^2$ | $0.039$ / $0.059$ / $0.084$ | $0.025$ / $0.099$ / $0.238$ |
| $1/d^3$ | $0.095$ / $0.099$ / $0.0998$ ($\to\gamma$) | $0.356$ / $0.419$ / $0.464$ ($\to\beta=0.485$) |

- **$c=\kappa/d$.** $\vartheta_c=1/(18\kappa+1)$ is constant and $E_0\approx\kappa F_d=O(d^3)\ll\vartheta_cG$. Theorem 5.1, unchanged, gives excess $\ge\gamma(\lambda)(18\kappa+1)^{-2}-o(1)$, a **constant**.
- **$dc\to0$ (bound (a$'$)).** Use $t=1$ in Lemma 2.1(2): $\kappa_N(w_1)\le dF_d+18dQ$ and $\mathcal R(g)\le2$. Then every $w\in\mathcal N_1$ has $\mathcal R(z_w)\le c(dF_d+18dQ+1)+2=o(M)$, and Lemma 1.2(a) gives excess $\ge(\sqrt{Q/M}-\sqrt{\mathcal R/M})_+^2=\beta(\lambda)-o(1)$. The same holds for Gibbs predictors and posterior means, by §3.9.

So with $d=\log_2n$, competitor width 1, and learner width polynomial in $n$, depth-two SP$_c$ with $c\le\kappa/\log_2n$ has constant excess. The "$+o(1)$" formulation is therefore refuted at depth two for these $c$. The statement is true as written for fixed $c>0$, which is what its justification refers to. But the corollary is stated "for every $c\le\mathrm{poly}(d)$", and the user's request is precisely to condition closely ($c$ small), so the note should not cite the remark unqualified.

## 5. Proposition 5.3 (Hadamard atoms)

**Identities** (`hadamard_check.py`, $M\in\{16,64,256,1024,4096\}$, $N\in\{1,2,7\}$, $\lambda=1$):

- $AA^\top=MI$ exactly (Sylvester), $Au=\bar y\mathbf 1_T$ to $10^{-12}$, and $\lVert u\rVert^2=Q/M$.
- Rows $(0,\epsilon u)$ and readout $1/(N\epsilon)$ give $z=\epsilon^{-1}\tanh(\epsilon u\cdot x)$ at every $N$. Then
  $$
  \kappa_N=\tfrac dN\cdot N\epsilon^2\lVert u\rVert^2+N\cdot N\cdot(N\epsilon)^{-2}=M\epsilon^2Q/M+\epsilon^{-2}=\epsilon^2Q+\epsilon^{-2},
  $$
  which equals $2\sqrt Q$ to relative error $10^{-9}$ at $\epsilon^2=Q^{-1/2}$. ✓
- $\lvert\epsilon^{-1}\tanh(\epsilon\bar y)-\bar y\rvert\le\epsilon^2\lvert\bar y\rvert^3/3\le\epsilon^2/3$. For example, at $M=4096$ the error is $7.424\cdot10^{-3}$ against the bound $7.491\cdot10^{-3}$. ✓
- $\mathcal R\le n\epsilon^4/9=n/(9Q)$. For example, at $M=4096$: $0.138\le0.230$. ✓
- $z=0$ on unseen atoms (to $2\cdot10^{-15}$).
- The budget $\mathcal R(z_w)\le c\kappa_N+\mathcal R(z_{\rm lin})+c\le c(2\sqrt Q+1)+n/(9Q)$ holds for every $N\ge1$ and $c>0$. ✓
- The conclusion follows from Lemma 1.2(a) on the Lemma 1.3 event, which applies verbatim to $M$ equiprobable atoms. ✓

**Size of the $o(1)$** ($Q=\beta M$, $\lambda=1$; excess lower bound $(\sqrt Q-\sqrt{\mathcal R_{\max}})_+^2/M$):

| $M$ | $2^{10}$ | $2^{14}$ | $2^{20}$ | $2^{30}$ | $2^{60}$ |
|---|---|---|---|---|---|
| $c=1$ | 0.235 | 0.350 | 0.435 | 0.476 | 0.4848 |
| $c=\sqrt M/10$ | 0.1015 | 0.104 | 0.104 | 0.104 | 0.104 |
| $c=\sqrt M$ | 0 | 0 | 0 | 0 | 0 |

The deficit at fixed $c$ is about $2\sqrt2\,c^{1/2}\beta^{3/4}M^{-1/4}$, so convergence is slow. The row $c=\sqrt M/10$ shows that $o(\sqrt M)$ is not needed for a constant excess (Issue 5).

**Consistency with optimization.** I ran L-BFGS on $F_c$ at depth two with $M=d\in\{64,128\}$ and $N\in\{8,16,64\}$.
- At $c=1$ the optimizer found networks with objective below the linear memorizer's (for example $10.62\le11.21$), with $\mathcal R\approx0.95$ and found excess $0.33$–$0.43$. Each satisfies the proven budget and lower bound.
- At $c=16$ it returned the zero network.

**Remark after 5.3.** At $n\asymp d$, no polynomial-in-$d$ bound is contradicted, and the dimension-free reading is refuted along the subsequence $M=2^k$. ✓

## 6. Lemmas 1.2 and 1.3

- **(1.1).** The within/between decomposition holds exactly for random $f$. ✓
- **Lemma 1.3, conditional moments.**
  - $\mathrm{Var}(S^2)=2k^2-2k$ holds exactly for $k\le10$, by enumeration.
  - $\mathrm{Var}(Q\mid x)=\sum_T(2k^2-2k)/k^4\le2n$ and $\mathrm{Var}(G\mid x)=\sum_T(2k^2-2k)/k^2\le2n$. ✓
- **Lemma 1.3, $\mathrm{Var}(V)$.** $V=n+\sum_{i\ne j}y_iy_j\mathbf 1[x_i=x_j]$, so $\mathrm{Var}(V)=2n(n-1)/M$ exactly. Enumeration at $M=3$, $n=4$ gives $8=8$. Monte Carlo at $d=6,10,12$ agrees within one standard error. (A first run with 400 replicates came out 6–21% high; that was sampling noise in a heavy-tailed variance estimate.) ✓
- **McDiarmid.** The true bounded-difference constants are $3/2$ for $\Sigma_1$ and $1$ for $s$; the claimed 2 is conservative. The exponent $2t^2/(4n)$ at $t=n^{2/3}$ gives $e^{-n^{1/3}/2}$. ✓
- **Chebyshev.** The failure probabilities add to $2n^{-1/3}+2n^{-1/3}+2(n/M)n^{-1/3}$. ✓
- **Event frequency.** In Monte Carlo the event holds in 0.975, 0.995 and 1.000 of samples at $d=10,12,14$. The claimed lower bounds there are 0.379, 0.624 and 0.764, so the claim is valid but conservative.

## 7. Issues

1. **(minor; must be fixed before citing) Corollary 5.2's closing remark; also §2.3 A3 and §6.4.** "Does not refute the $+o(1)$ formulation, since $\varepsilon_d\asymp1/\log^2n$" holds only when $dc\to\infty$. The corollary's range $c\le\mathrm{poly}(d)$ includes $c=O(1/d)$:
   - for $c=\kappa/d$, Theorem 5.1 gives the constant excess $\gamma(\lambda)(18\kappa+1)^{-2}$;
   - for $dc\to0$, the $t=1$ memorizer and Lemma 1.2(a) give $\beta(\lambda)-o(1)$ (§4).

   *Fix.* State the remark for $c$ with $dc\to\infty$ (e.g. fixed $c$). Add that for $c\le\kappa/\log_2n$ depth-two SP$_c$ refutes the "$+o(1)$" formulation as well. Restrict §6.4's open problem to $c\gg1/\log n$ (e.g. $c=1$).
2. **(minor) Corollary 5.2, parenthetical.** The bound is positive from $d=30$, but it is only $1.9\cdot10^{-8}$ there. It is about $2\cdot10^{-7}$ for $33\le d\le40$, with maximum $2.26\cdot10^{-7}$ at $d=35$, and it first reaches the corollary's $2\varepsilon_d$ at $d=33$. `bounds_table.py` uses the surrogates $G=(1-e^{-\lambda})M$, $V=\lambda M$ rather than the Lemma 1.3 event. The difference is 2.6% at $d=30$ and under 0.5% for $d\ge33$.
3. **(minor) Theorem 5.1, width threshold.** $N\ge72dn^3\ln(2M)+2$ comes from the choice $a=1/n$, and it overstates the width needed by a factor of about $n^2$.
   - For $a\le4$, §3.1 gives $\mathcal R(tg)\le(1-t)^2G+nta$, hence $\mathcal R(z_w)\le(1-\vartheta_c)G+\vartheta_cna+c(dF_d+1)$ on $\mathcal N_1$.
   - With $a=1/d$ the bound becomes $(\vartheta_c(G-n/d)-c(dF_d+1))_+^2/(4MV)$, which is still $\gamma(\lambda)(18dc+1)^{-2}(1-o(1))$, at every width $N\ge72d^3n\ln(2M)+2=O(n\log^4n)$.
   - Example at $d=35$: $N_0=2.6\cdot10^{18}$ instead of $2.6\cdot10^{36}$, and the bound is 0.907 of the original (`small_c_and_width.py`).
4. **(minor, optional) Loose constants.** None of these is an error.
   - $\lvert c_{k,a_d}\rvert^{-1}\le2\sqrt{2d}$ gives $A_0^2=8dQ$, so $18d$ can be replaced by $16d$.
   - Using $Q$ instead of $G$ in the bracket gives $\vartheta=G/(18dcQ+G)$; asymptotically $Q/G\to\beta/(1-e^{-\lambda})=0.767$ at $\lambda=1$.
   - Since $a_d=O(\log d)$, rows satisfy $\lVert\omega\rVert^2\le\max\{1,(d+1)a_d^2\}$, which is $91$ at $d=30$ against $F_d=31745$. With this bound alone, the explicit bound at $c=1$ is positive from $d=20$ and peaks at $4.6\cdot10^{-7}$ (`sharper_FD.py`).
   - The readout pays $A_0^2$ although the mixture's actual mass is about $0.3A_0$ at small $d$.
5. **(minor) Proposition 5.3.**
   - $\epsilon^2=Q^{-1/2}$ needs $Q>0$. This holds on the Lemma 1.3 event; add "if $Q>0$".
   - The hypothesis can be weakened: for $c\le\kappa\sqrt M$ with $\kappa<\sqrt{\beta(\lambda)}/2$ ($0.348$ at $\lambda=1$), the excess is $\ge\beta(1-\sqrt{2\kappa/\sqrt\beta})^2-o(1)>0$. At $\kappa=0.1$ this is $0.104$.
   - The $o(1)$ is of order $c^{1/2}M^{-1/4}$; it is still $0.25$ at $M=2^{10}$, $c=1$.
6. **(minor) "Positive side at $L=2$".** "Between $\Omega(1/(dc)^2)$ and $O(d/\sqrt c)$" is accurate for $c\gtrsim1/d$. For $c=O(1/d)$ the lower bound is $\Omega(1)$ (Issue 1). The upper-bound arithmetic is correct: with $g\equiv0$, $K=1+n/c$, the middle term of (3.1) is $8\mathcal D\sqrt{(1+n/c)/n}\approx8\mathcal D/\sqrt c$, and it vanishes once $c\gg128d^2$.
7. **(minor) §5.4 numerics.**
   - Re-running the red-team's script at $d=8$, $L=2$, $N=256$, $c=1$, seed 0 (3 restarts × 20000 iterations) reproduces $\phi=0.396$, $\mathcal R=35.19$, $G=154.8$ and excess $0.2057$ ($0.1556$ on seen atoms). The $d=10$ rows match the saved outputs.
   - Caveat: the $d=8$ and $d=10$ runs used different optimizer budgets (3×20000 against 1×6000), and each $\phi$ is only a lower bound on what near-minimizers capture. "The captured fraction rises with $d$" therefore compares two lower bounds and is not established, even as small-$d$ evidence.

## 8. Strongest correct statement

**Theorem 5.1** is correct as stated. It also holds at every width $N\ge72d^3n\ln(2M)+2$, with $E_0$ replaced by $c(dF_d+1)$ and $G$ by $G-n/d$ in the numerator. If $dc\to0$, near-minimizers, Gibbs predictors and posterior means (clipped or not) have excess $\ge\beta(\lambda)-o(1)$ with probability $1-o(1)$.

**Corollary 5.2** (corrected). For every $0<c\le\mathrm{poly}(d)$, depth-two SP$_c$ violates the polynomial-sample inequality. Theorem 5.1's bound is $\asymp(1+dc)^{-2}$:
- when $dc\to\infty$ (e.g. fixed $c$) it tends to 0, and the "$+o(1)$" formulation is not refuted by it;
- when $c\le\kappa/d$ it is a constant, at least $\gamma(\lambda)(18\kappa+1)^{-2}$, and it becomes $\beta(\lambda)-o(1)$ if $dc\to0$. So for $c=O(1/\log n)$ the "$+o(1)$" formulation is refuted at depth two.

**Proposition 5.3** is correct as stated, given $Q>0$. Constant excess persists for $c\le\kappa\sqrt M$ with $\kappa<\sqrt{\beta(\lambda)}/2$.

## Appendix. Scripts and outputs

All in `../checks/verify-RT-depth2-computation/`:

| Script | Purpose | Output |
|---|---|---|
| `constants_t51.py` | $\gamma$, $\beta$, bracket (sympy), Theorem 5.1 explicit bound in three modes | `constants_t51.out` |
| `lemma21_depth2_exact.py` | exact Fourier/parity mixture, sampling, explicit width-$N$ networks, energy/residual/chain checks | `lemma21_depth2_exact.out` |
| `lemma12_13_checks.py`, `varV_mc.py` | Lemma 1.2 adversarial checks; Lemma 1.3 moments, McDiarmid constants, event frequency; exact $\mathrm{Var}(V)$ | `lemma12_13_checks.out`, `varV_mc.out` |
| `hadamard_check.py` | Proposition 5.3 identities, $o(1)$ table, L-BFGS consistency | `hadamard_check.out` |
| `small_c_and_width.py` | Issue 1 (small $c$) and Issue 3 (width with $a=1/d$) | `small_c_and_width.out` |
| `parity_coeffs.py` | $\lvert c_{k,a_d}\rvert2\sqrt{2k}\ge1$ up to $d=300$; $C(2m,m)/4^m$ | `parity_coeffs.out` |
| `sharper_FD.py` | explicit bound with $\max\{1,(d+1)a_d^2\}$ in place of $F_d$ | `sharper_FD.out` |
| `memorize_opt2_copy.py` | unmodified copy of the red-team's `memorize_opt2.py`, re-run for §5.4 | `rerun_d8_L2_c1.txt` |

# Referee report on `../research-notes/B-tempered-likelihood.md` (Claim B, positive side of D). Lens: computation

**Verdict: minor fixes.** I recomputed every constant, exponent, energy bound, probability estimate and concentration inequality in ../research-notes/B-tempered-likelihood.md. No step is wrong and no conclusion changes. I found one quoted number that is off: the $10^{13.4}$ example after Theorem 6.3 belongs to a sharper intermediate bound, while $\mathrm{Exc}_n$ as defined first drops below $\varepsilon$ at $10^{14.09}$. There are also several imprecise side statements:

- Corollary 8.1 is vacuous at depth two for $\alpha\ge1/8$.
- The degree claims after Theorem 6.3 are wrong for the variable $d$.
- One step of Lemma 4.2 is asserted with no proof, and its obvious justification fails for large $L$; the inequality itself still holds.

None of these affects Theorem 6.3, Theorem 6.4, Theorem 7.4, Corollary 9.3 or the exponents $1/H$, $1/L$ and $1/(4(L-1))$.

Scripts and outputs are in `../checks/verify-B-computation/`. All runs use fixed seeds.

---

## 1. What was checked, and how

Each item below was re-derived by hand, and, where possible, checked numerically by an independent script (not the authors' `B_checks`).

| ../research-notes/B-tempered-likelihood.md item | quantity recomputed | hand | numeric (script) | status |
|---|---|---|---|---|
| (1.1), Lemma 2.1(a) | $\lvert z_w\rvert\le\lVert v\rVert_1\le\sqrt{a_L}\le\sqrt\kappa$ | yes | `v_networks.py` (1): max ratio $0.805$ | correct |
| Lemma 2.1(b) | $\mathrm{Lip}\le d^{-1/2}(\prod_\ell a_\ell)^{1/2}\le d^{-1/2}(\kappa/L)^{L/2}$ | yes | random pairs, 3000 nets: max ratio $0.963$ | correct |
| Lemma 2.2 | $a_1\le d(d+1)B^2$, $a_\ell\le2m^2B^2$, $a_L\le2m^2B^2$, unequal groups | yes | 500 clones with $N\not\equiv0\pmod m$: error $1.7\cdot10^{-13}$, max ratio $0.80$ | correct |
| Lemma 2.3 | (a), (b), (c), including $n(U+1)^2/c$ | yes | n/a | correct; the correction to the brief is right |
| Lemma 3.1 | $\ell_F$; $\rho$; $\alpha$; the envelope; exponent $\ge\zeta/2$; Gaussian integral | yes | `v_laplace.py`: both pointwise inequalities hold; the exponent slack is exactly $0$ at $m_*=n/c$ | correct |
| Corollary 3.2 | the four parts and the bound $\Phi\le b(1+F)$ | yes | n/a | correct |
| Proposition 4.1 | parameters against `paper.tex` | yes (source read) | n/a | matches the source (imported) |
| Lemma 4.2 | Steps 1–4: $D_T$, $\ln(L/\lambda)$, $\Xi$, $J\le\bar J$, $\Gamma_L$, polynomial form, $C_J$, $C_{\log}$ | yes | `v_lemma42.py`: 1440 grid points, $L\le40$, $d\le1000$, $K\le10^{12}$, $a\ge10^{-8}$, 60-digit arithmetic, all 8 sub-claims hold | correct (one step unproved, M5) |
| Lemma 4.3 | Hoeffding $e^{-nt^2/8}$; $t$; $8a$ | yes | n/a | correct |
| Lemma 5.1 | (ii) Massart; (iii) contraction; (iv) clipping $+\frac1{2\sqrt n}$; (v) clip mixture; (vi) | yes | `v_rademacher_tools.py`: exact enumeration of signs, 400 random sets: (ii) max ratio $0.754$, (iii) $\le7\cdot10^{-17}$, (iv) $\le-0.033$, (v) error $4\cdot10^{-16}$ | correct |
| Lemma 5.2 | path norm $\le(\kappa/H)^{H/2}$; peeling; Sauer–Shelah $\sum_{k\le d+1}\binom nk\le(n+1)^{d+1}$; Massart with $R=\sqrt n$ | yes | exact $\mathrm{Rad}(\mathcal D_S)$ for $n\le12$, $d\le3$: e.g. $0.758\le1.308$ | correct |
| Lemma 5.3 | McDiarmid $b\sqrt{\ln(1/\delta')/(2n)}$; symmetrization factor 2; $\gamma=4$ and $\gamma=2(\sqrt K+1)$; ranges $4$ and $(\sqrt K+1)^2$ | yes | n/a | correct |
| Proposition 6.1 | $\mathcal E_2$ via Hoeffding with range $(U+1)^2$; the chain; Jensen | yes | n/a | correct |
| Theorem 6.2 | the $\mathrm{Exc}$ split; $C_*$ for $L\ge3$ and $L=2$; $\ell_n=\ln(1088d/\varepsilon)+\theta\ln n$; $(A+B)^3\le4(A^3+B^3)$; $\ln n\le\frac{6}{e\varrho}n^{\varrho/6}$; $n_{\rm cov}$ | yes | `v_samples.py`: $n_1$ suffices (exact cover count) in 5 settings; least $n$ is $10^{54.0}$ ($L=2$) and $10^{101.4}$ ($L=3$), as quoted | correct (M4) |
| Theorem 6.3 | $(K/H)^{H/2}\le(2/H)^{H/2}n^{\theta H/2}$; $\ln(n+1)\le n^\gamma/\gamma$; the four entries of $n_0$; $\theta=1/(H+2)$ balance | yes | 3000 random settings ($H\le6$, $d\le1000$, $\varepsilon\ge10^{-4}$, $\delta\ge10^{-8}$): no violation for $n\ge n_0$; $\mathrm{Exc}_{n_0}\le0.34\varepsilon$ | correct (M1, M3) |
| Theorem 6.4 | $\sqrt K+1\le(1+\sqrt2)n^{\theta/2}$; exponent $(1-\theta L)/2$; five entries | yes | 3000 random settings: no violation; $\mathrm{Exc}'\le0.343\varepsilon$ at the threshold | correct |
| Remark 6.2′ | entropy $\tilde O(K^{4L})$ (resp. $K^4$); thresholds $1/(4L+2)$, $1/6$ | yes | `v_symbolic.py` | correct |
| Lemma 7.1 | (a)–(d); $\mathbb ES_1\ge M/e$; McDiarmid with $c_i=2$ gives $e^{-u^2/(2n)}$ | yes | `v_cube_twopoint.py` (a): $\mathbb ES_1/M\ge1/e$ exactly for $d=6..14$; empirical tail $0$ | correct |
| Lemma 7.2 | Fourier $\ell^1$; staircase (margin, $\lvert a\rvert\le d$, $\ell^1\le k+1$); $1-\tanh b\le2e^{-2b}$; Hoeffding $m_t$; $a_1\le\beta^2d^3$; $a_2\le2A^2/R^{2H-2}\le2R^2$; chain $\le\frac{2\lvert g\rvert^3}{3R^2}\le\frac{9}{4R^2}\le t$ | yes | `v_networks.py` (3): six instances with the lemma's own $A_{\max},\beta,R,m_t$ ($m_t$ up to $4.9\cdot10^5$) and unequal groups; explicit-matrix check of the energy formula | correct |
| Proposition 7.3, Theorem 7.4 | $\mathcal R(z_w)\le c(K_{\rm mem}+1)+9nt^2$; $N_0(n)$; $\varepsilon_n$; the limits | yes | `v_cube_twopoint.py` (b): $\varepsilon_n\to0$, bound $\to0.368$ | correct (slow: needs $d\approx400$ at $H=2,\theta=0.55$) |
| §7.5 | window $\lambda_n\gg(\log n)^{2/H}$ and $\lambda_n\ll(\log n)^{-2/H}$; quoted exponents | yes | reran `transition_window.py` | correct |
| Corollary 8.1 | $\theta=(1+8\alpha)/(H+2)$; $4\alpha-\theta=-\beta$; $(1-\theta H)/2=\beta$; $E_*+1\le(d(d+1)+2L)n^{4\alpha}$; $4+(U+1)^2\le8n^{4\alpha}$; $\alpha\le H/16$ | yes | `v_symbolic.py` (sympy) | correct for $H\ge2$; M2 for $H=1$ |
| Proposition 9.1 | $t_H\ge\frac23\tilde t_H$; $\omega\le v\le\frac32\omega$; energy $(H+\frac94)\delta_0^{-2/L}$; converse $L\delta_0^{-2/L}$; (c) arithmetic, $3.25$ | yes | `v_cube_twopoint.py` (c): over $L\le8$ and $\delta_0\in[10^{-12},2^{-L/2}]$, $\min t_H/\tilde t_H=0.772$ and $v/\omega\le1.295$ | correct |
| Lemma 9.2, Corollary 9.3 | $\tanh s\ge\tanh(1)\min\{1,s\}$; the induction; $m^HB^L\ge n^{\alpha(2L-1)}/2^H$; thresholds $1/(2H)$ and $L/(2H(2L-1))$ | yes | 2420 random admissible $(L,m,B)$: no case with $v>B$; sympy thresholds | correct |
| §10 table | every number quoted | n/a | reran all nine author scripts (§4) | reproduces; see M1 |

---

## 2. Re-derivations of the load-bearing inequalities

I give only the steps where an error would most plausibly hide.

**Lemma 3.1 (Laplace tail, uniform in $S$).** Put $\alpha=\zeta/(8(n/c+\zeta))\le1/8$ and $b=\alpha/(2\sigma^2)\ge1$. Since $t\mapsto(1+t)e^{-bt}$ is nonincreasing from the value $1$ at $t=0$, and $F\ge\lvert\Lambda w\rvert^2$, on $\{F>m_*+\zeta\}$ we have

$$
(1+F)e^{-F/(2\sigma^2)}\le e^{-(1-2\alpha)(m_*+\zeta)/(2\sigma^2)}\,e^{-\alpha\lvert\Lambda w\rvert^2/(2\sigma^2)} .
$$

The normalizer satisfies $Z_\sigma\ge v_P\rho^Pe^{-(m_*+\zeta/4)/(2\sigma^2)}$, and

$$
(1-2\alpha)(m_*+\zeta)-(m_*+\tfrac\zeta4)=\tfrac34\zeta-2\alpha(m_*+\zeta)\ \ge\ \tfrac34\zeta-2\alpha(\tfrac nc+\zeta)=\tfrac\zeta2 .
$$

The tail is therefore at most $(2\pi\sigma^2/\alpha)^{P/2}(\det\Lambda\,v_P\rho^P)^{-1}e^{-\zeta/(4\sigma^2)}$, as stated. The inequality is tight exactly at $m_*=n/c$; `v_laplace.py` finds the slack equal to $5\cdot10^{-16}$ there. $\rho$, $\ell_F$ and $\alpha$ depend only on $(N,n,c,d,H,\zeta)$, so the convergence is uniform in $S$.

**Lemma 4.2 (cover entropy).** $1+2\sqrt d/r\le17\sqrt dK^{L/2}/a\le(17dK/a)^{L/2}$. Hence

$$
D_T\le1+\tfrac{dL}{2\ln2}\ell\quad\Bigl(\tfrac1{2\ln2}=0.7213\Bigr),\qquad
\ln\tfrac L\lambda\le2L+\tfrac L2\ell .
$$

The second bound uses $\ln(4L(L-1))+L\ln2-2L=-0.534,-0.743,-1.356,\dots$ for $L=2,3,4,\dots$. Since $\ell\ge\ln17$, i.e. $1/\ln17=0.35296$, this gives $\Xi\le\ell(0.354+0.722dL+1.206L)\le3dL\ell$. Next,

$$
256\lambda^{-4}\Xi\le2^{16}\cdot3\,(L-1)^4L\,16^L\,dK^{2(L-1)}a^{-4}\ell ,
$$

and the $+1$ from the ceiling is absorbed, so $C_J=196608+1=196609$. The counting factor is $\ln(1+2(J+1)/\Delta_J)\le\ln(32(d+L+1)2^LJ^{2L+1}/a)$, using $1+X\le2X$ and $J+1\le2J$. Finally $C_{\log}=(2L+1)(\ln C_J+2L+1)+L+6$, using $\ell\ge1$.

**Lemma 5.2 (width-free Rademacher bound).** By Cauchy–Schwarz and $\lVert\,\lvert W\rvert\,\rVert_{\rm op}\le\lVert W\rVert_F$,

$$
P(w)=\lvert v\rvert^\top\lvert W^H\rvert\cdots\lvert W^2\rvert\mathbf 1_N\le\sqrt N\lVert v\rVert_2\prod_{\ell=2}^H\lVert W^\ell\rVert_F=\Bigl(a_L\prod_{\ell=2}^Ha_\ell\Bigr)^{1/2}\le(\kappa/H)^{H/2}.
$$

These are $H$ factors, and the first layer is not charged. Peeling with Lemma 5.1(iv) adds $(H-1)/(2\sqrt n)$. Massart with $\lvert\mathcal D_S\rvert\le(n+1)^{d+1}$ and $R=\sqrt n$ gives $\sqrt{2(d+1)\ln(n+1)/n}$. So $D_n$ is exactly as stated.

**Lemma 5.3 and Proposition 6.1 (probability constants).**

- McDiarmid with differences $b/n$ gives $b\sqrt{\ln(1/\delta')/(2n)}$.
- Symmetrization gives a factor $2$, and contraction a factor $\gamma$. So (a) has coefficient $2\cdot4=8$ and (b) has $2\cdot2(\sqrt K+1)$.
- The competitor's Hoeffding term is $(U+1)^2\sqrt{\ln(2/\delta)/(2n)}$, with failure probability $\delta/2$.
- In total, $\mathrm{Exc}_n$ of Theorem 6.3 is
$$
(E_*+1)n^{-\theta}+8(2/H)^{H/2}D_nn^{-(1-\theta H)/2}+(4+(U+1)^2)\sqrt{\ln(2/\delta)/(2n)},
$$
using $K=n^\theta+1\le2n^\theta$.

**Theorem 6.3 (sample size).** With $\gamma=(1-\theta H)/2$, the bound $\ln(n+1)\le n^\gamma/\gamma$ holds for $n\ge1$: it holds at $n=1$, and the derivative of the difference is $n^{\gamma-1}-\frac1{n+1}\ge0$. So the $\sqrt{\ln}$ part is at most $8(2/H)^{H/2}\sqrt{4(d+1)/(1-\theta H)}\,n^{-\gamma/2}$. Each entry of $n_0$ then gives its budget: $\varepsilon/3$, $\varepsilon/6$, $\varepsilon/6$ and $\varepsilon/3$. The exponent $2/\gamma=4/(1-\theta H)$ is right.

**Lemma 7.2 (memorizer energy and chain).** With $k_j\ge\lfloor N/m_t\rfloor\ge N/(2m_t)$,

$$
a_2=N\sum_jk_j\Bigl(\frac A{m_tk_jR^{H-1}}\Bigr)^2\le\frac{2A^2}{R^{2H-2}}\le2R^2 ,
$$

since $R^{2H}\ge A_{\max}^2$. Unrolling the chain gives $\lvert z-g\rvert\le\frac{\lvert g\rvert^3}{3}\sum_{i=1}^{H-1}R^{-2i}$. The sum is $\le2R^{-2}$ because $R^2\ge2$, and with $\lvert g\rvert\le3/2$ this is $\le9/(4R^2)\le t$.

**Corollary 8.1 (exponents).** sympy confirms $4\alpha-\theta+\beta=0$ and $(1-\theta H)/2-\beta=0$. It also gives

$$
-\beta-(4\alpha-\tfrac12)=\frac{H-16\alpha}{2(H+2)}\ge0\iff\alpha\le H/16 ,
$$

and $8x^4-4-(x^2+1)^2=(x-1)(x+1)(7x^2+5)\ge0$ for $x=n^\alpha\ge1$.

**Corollary 9.3(b).** $m=\lfloor n^\alpha\rfloor\ge n^\alpha/2$ gives $m^HB^L\ge2^{-H}n^{\alpha(H+L)}=2^{-H}n^{\alpha(2L-1)}$. Therefore $\eta\to0$ iff $\alpha(2L-1)>L/(2H)$. The interval at $L=3$ is $[1/8,3/20]=[0.125,0.15]$, as stated.

---

## 3. Issues found

All issues are minor. None changes a theorem statement's truth or a headline exponent.

**M1. Wrong numerical example after Theorem 6.3 (line 579; repeated in the §10 table, `sample_sizes` row).** ../research-notes/B-tempered-likelihood.md says that at $L=3$, $d=10$, $m=B=1$, $\varepsilon=0.1$, $\delta=0.05$, $\theta=1/4$, "the bound $\mathrm{Exc}_n\le\varepsilon$ first holds at $n\approx10^{13.4}$". With $\mathrm{Exc}_n$ as defined in Theorem 6.3, which uses $(2/H)^{H/2}n^{\theta H/2}$, I get:

- $\mathrm{Exc}_{10^{13.4}}=0.146>0.1$;
- the first crossing is at $n\approx10^{14.09}$ (`v_samples.py`).

The value $10^{13.4}$ is the crossing of the sharper intermediate bound with $(K/H)^{H/2}$ and $K=n^\theta+1$; that is what `sample_sizes.py` evaluates. *Fix:* quote $10^{14.1}$ for $\mathrm{Exc}_n$, or say that $10^{13.4}$ refers to the bound before $K\le2n^\theta$. (The closed form $10^{29.2}$ is correct.)

**M2. Corollary 8.1 at depth two ($H=1$).**

- For $\alpha\in[1/8,1/4)$ the stated exponent $\beta=\min\{(1-4\alpha)/3,\ \tfrac12-4\alpha\}$ is $\le0$, for instance $\beta=-1/4$ at $\alpha=3/16$. The inequality holds but does not decay, so "for every $\alpha<1/(4H)$" overstates the useful range at $H=1$. The obstruction is the competitor's Hoeffding term, whose range is $(U+1)^2\approx n^{4\alpha}$.
- The "In the user's words" paragraph (line 794) says the bound holds "for every $\alpha<1/(4H)$ with $\beta=(1-4\alpha H)/(H+2)$" without restricting to $H\ge2$. At $H=1$ and $\alpha>1/16$ the true exponent is $\tfrac12-4\alpha<(1-4\alpha)/3$, so the paragraph overclaims the rate.

*Fix:* restrict that paragraph to $H\ge2$, and state $\alpha<1/8$ as the nonvacuous range for $H=1$.

**M3. Degree claims after Theorem 6.3 (line 579).** "Its degree in $E_*$ (hence in $d,m,B$) is $1/\theta$" is imprecise for two reasons.

- The second entry of $n_0$ carries $(d+1)^{2/(1-\theta H)}$, so the degree in $d$ is $\max\{2/\theta,\ 2/(1-\theta H)\}$. For example it is $20$, not $2/\theta=4.44$, at $H=2$, $\theta=0.45$ (`v_degrees.py`: local slope exactly $20.000$).
- The fourth entry carries $(U+1)^4$, so the degree in $m$ and in $B$ is $\max\{2/\theta,4\}$. This exceeds $2/\theta$ only when $H=1$ and $\theta>1/2$.

The degree in $1/\varepsilon$, $\max\{1/\theta,4/(1-\theta H)\}$, is right. *Fix:* state the degree per variable.

**M4. Route-1 sample sizes do not state $\theta$ (line 547).** The quoted $10^{101}$ ($L=3$) and $10^{54}$ ($L=2$) are at $\theta=1/16$ and $\theta=1/4$ (`sample_sizes.py`). They depend strongly on $\theta$: at $L=3$, $\theta=1/10$ the least $n$ is $10^{260.6}$. *Fix:* state $\theta$.

**M5. Lemma 4.2, Step 4: one inequality is asserted without proof.** The claim is $\ln\frac{2^{L+5}(d+L+1)}a\le L+5+\ell$. The natural termwise argument, $(L+5)\ln2\le L+5$ together with $\ln(d+L+1)+\ln\frac1a\le\ell$, fails whenever $L+1>16dK$, for example $L\ge16$ with $d=K=1$; there are 504 failing $(L,d)$ pairs for $L<200$, $d\le3$, $K=1$. The inequality is nevertheless true for all $L\ge2$. One needs the slack $(1-\ln2)(L+5)\ge\ln\frac{L+2}{17}$, together with $d+L+1\le d(L+2)$. All 1440 grid points pass (`v_lemma42.py`). Two other steps are also asserted without proof but are true: $\ln(4L(L-1))+L\ln2\le2L$, and $\ln d+2(L-1)\ln K+4\ln\frac1a+\ln\ell\le(2L+1)\ell$. *Fix:* add one line each. This affects route 1 only.

**M6. Ambiguity in the headline row of §0 (line 11).** "Every near-minimizer of $F_c$, the support …, the Gibbs predictor and the posterior mean of the clipped outputs all have test MSE $\le L_D(g)+\varepsilon$" can be read as covering unclipped near-minimizers. For $\theta\in[1/L,1/H)$ those are open by ../research-notes/B-tempered-likelihood.md's own list. *Fix:* write "test MSE of $\operatorname{clip}z_w$" for near-minimizers, support and Gibbs.

**M7. Theorem 7.4(b) is asymptotic, and the bound becomes nontrivial only at very large $d$.** This is not an error, since the statement says $1/e-o(1)$. For calibration, here are the lower bounds $(\sqrt{1/e-n^{-1/3}}-\sqrt{\varepsilon_n})_+^2$ (`v_cube_twopoint.py` (b)):

| $H$ | $\theta$ | $d=50$ | $d=100$ | $d=200$ | $d=400$ |
|---|---|---|---|---|---|
| 2 | 0.55 | $0$ | $0$ | $0$ | $0.328$ |
| 2 | 0.75 | $0.197$ | $0.364$ | | |
| 3 | 0.40 | | $0$ | $0.241$ | |

The slow term is $(H+1)(d+1)^{2/H}n^{1/H-\theta}$. A sentence giving the scale would prevent misreading.

**M8. §7.5 item 4 (dimension).** "If $d=n^\kappa$, the proof gives $\theta<(1-\kappa)/H$" holds for the zero competitor of the noisy cube. For a general competitor the first term $(E_*+1)n^{-\theta}$, with $E_*\ge d(d+1)B^2\approx n^{2\kappa}B^2$, also needs $\theta>2\kappa$. *Fix:* add "for the zero competitor".

**M9. Remark 6.5 wording.** This is outside the computation lens; I note it for the logic referee.

- The title says "uniformity over competitors", but the bound holds on $\mathcal E_1\cap\mathcal E_2(w')$ for one fixed $w'$. Only $\mathcal E_1$ is competitor-free.
- The "energy-penalized population optimum" is minimized over $\{\kappa_N\le E_0\}$ at a fixed width $N$. The event then depends on $N$, so uniformity over $N$ needs either a minimizer over functions or a two-sided version of Lemma 5.3(b) over $\mathcal Z_{E_0}$. The latter follows from the same proof with the same constants, but it is not stated.

The arithmetic of the displayed bound is correct.

**M10. Cosmetic.**

- The entries "$2$" in $R^2=\max\{2,9/(4t),\dots\}$ and "$1$" in $\beta=\max\{1,\dots\}$ are never active when $t\le1/4$. Then $9/(4t)\ge9$ and $\frac12\ln(2A_{\max}/t)\ge\frac12\ln16>1$, because $A_{\max}\ge d+1\ge2$.
- Script docstrings use stale theorem numbers. `sample_sizes.py` calls route 2 "Theorem 6.2" and route 1 "Theorem 6.1". `transition_window.py` calls its positive side "Thm 6.2 with g = 0"; it is Theorem 7.4(a) via Remark 6.5.

---

## 4. Reproduction of the authors' checks

Copies of all scripts in `../checks/B/` were rerun from `../checks/verify-B-computation/rerun/`.

All nine reproduce their `.out` files byte for byte: `check_identities`, `check_network_bounds`, `cover_degree`, `sample_sizes`, `transition_window`, `check_memorizer`, `check_two_point`, `check_laplace` and `check_rademacher`. The rerun outputs are the `*.rerun.out` files.

Every number in ../research-notes/B-tempered-likelihood.md §10 matches the outputs: $1.1\cdot10^{-13}$; $0.433/0.453/0.855$; $0.53$; $0.226$ vs $2.60$ and $0.211$ vs $3.63$ (the latter at $d=1$); slopes $2.09/8.16/12.18$ and $4.13/8.16/8.14$; window exponents $0.461/0.536$ and $0.634/0.688$; $v/\omega\le1.32$; energy ratio $1.43$–$2.67$; and the posterior masses $0.97$, $0.22$, $2\cdot10^{-4}$, $9\cdot10^{-9}$.

The citation of `../research-notes/red-team.md` Theorem 5.1 matches the source: excess $\ge\gamma(\lambda)(18dc+1)^{-2}(1-o(1))$ with $\gamma(1)=0.0999$, for $c\le\mathrm{poly}(d)$. ../research-notes/B-tempered-likelihood.md's "bounded $c$" is a special case. ../research-notes/B-tempered-likelihood.md uses it only as context, not in any proof.

## 5. Not checked here

- The proof of the imported Proposition 4.1 (`paper.tex` Lemma `compression`). Its source proof is a sketch, as ../research-notes/B-tempered-likelihood.md says. It is used only by route 1 (Theorem 6.2), which Theorem 6.3 supersedes. I checked only that ../research-notes/B-tempered-likelihood.md's parameters match the source.
- Proofs from `../research-notes/red-team.md` (context only).
- Logic and scope questions beyond arithmetic (M9 is noted, not adjudicated).

## 6. Scripts (all in `../checks/verify-B-computation/`)

| script | content | output |
|---|---|---|
| `v_lemma42.py` | Lemma 4.2: exact cover count against $\bar J$, $\Gamma_L$ and the polynomial form; all sub-steps | `v_lemma42.out` |
| `v_samples.py` | Theorems 6.2, 6.3, 6.4: closed-form thresholds on random settings; the $10^{13.4}$ example; route-1 crossings | `v_samples.out` |
| `v_symbolic.py` | sympy: Corollary 8.1, Corollary 9.3, Proposition 9.1(c), Remark 6.2′ exponents | `v_symbolic.out` |
| `v_rademacher_tools.py` | Lemma 5.1 (ii)–(v), exact sign enumeration; first layer of Lemma 5.2 | `v_rademacher_tools.out` |
| `v_networks.py` | Lemma 2.1, Lemma 2.2 (unequal groups), Lemma 7.2 at full size, and an explicit-matrix energy check | `v_networks.out` |
| `v_cube_twopoint.py` | Lemma 7.1(d) simulation, Theorem 7.4(b) $\varepsilon_n$, Proposition 9.1, Lemma 9.2 | `v_cube_twopoint.out` |
| `v_laplace.py` | Lemma 3.1 pointwise inequalities on a real 3-parameter network | `v_laplace.out` |
| `v_degrees.py` | degrees of $n_0$ in $d$, $m$ and $1/\varepsilon$ (M3) | `v_degrees.out` |
| `rerun/` | copies of the authors' `B_checks` scripts, rerun, with `*.rerun.out` | |

# Referee report on `../research-notes/E-finite-prior-scale.md` (Claim E), computation lens

*Referee: adversarial check of every constant, exponent, energy bound, probability estimate and concentration inequality in `../research-notes/E-finite-prior-scale.md`. 11 November 2026. My scripts and their outputs are in `../checks/verify-E-computation/`. I changed nothing in the repository or in `../research-notes/E-finite-prior-scale.md` or `../checks/E/`; I re-ran the `E_scripts` into my own folder.*

---

## 1. Verdict: `minor_fixes`

I re-derived every displayed inequality of ../research-notes/E-finite-prior-scale.md that involves a constant or an exponent. Where possible I checked it a second way, with symbolic algebra, adaptive quadrature or Monte Carlo. Every inequality used in the proofs of Lemma 1.1, Lemmas 2.1–2.6, Theorem 2.7, Lemma 3.1, Lemmas 4.1–4.3, Proposition 4.4, Lemma 5.1, Theorem 5.2 and Corollaries 5.3–5.4 holds with the stated constants, and most hold with slack. The thresholds $\theta_{L,\gamma}$ follow exactly from the sufficient conditions the proof imposes. The mean-field degrees $D_T$, $D_H$ match the formulas of the imported source. Table 7.1 reproduces from an independent implementation.

I found **two small errors**. Neither affects any theorem.

1. **E1.** A side remark after Corollary 5.4 links $c=1$ to $\theta=0$; the correct value is $\theta=1$. It therefore names the wrong term as the reason the PAC-Bayes bound is vacuous at $c=1$.
2. **E2.** A one-line justification in the $\Xi$ estimate of Proposition 4.4 says "$H^2\ge1$". The stated constant $a/96$ needs $H^2\ge4$, which holds because $H\ge2$.

There are also several imprecisions and slack constants (§5.2 below). One caveat carries over unchanged from ../research-notes/E-finite-prior-scale.md. The $\gamma=1$, $L\ge3$ part of Theorem 2.7 rests on the imported mean-field cover (I3). I checked (I3) only at the level of its statement and explicit formulas, which is also all ../research-notes/E-finite-prior-scale.md claims.

---

## 2. Source statements compared with their use

| ../research-notes/E-finite-prior-scale.md item | source | check |
|---|---|---|
| (I1) $A=1+\tfrac12E_*+[d+2+(L-2)m]\ln\frac{8}{3\eta_\rho}+\ln2$ | `paper.tex` eq. `A`, Prop. `tube` | Matches with $M=m=1$, $c_m=\tfrac38$, $b_0=2\sqrt{2[2\ln9+\ln(4L)]}$, $P_0$, $A_0$, $\eta_\rho$. I re-derived the clone's operator norm: writing $W=\tilde ED^{1/2}UD^{-1/2}\tilde E^\top$ gives $\lVert W\rVert_{\rm op}\le(\sum_{jj'}\tfrac{k_j}{k_{j'}}U_{jj'}^2)^{1/2}\le\sqrt2mB$. I also re-derived $e_{L-1}\le\eta(d+L+1)A_0^{L-2}$ (it uses $\sqrt m\le A_0$) and the cylinder count $N[d+2+(L-2)m]$. On the cube, $e_1\le\eta(d+1)/\sqrt d\le\eta(d+1)$. |
| (I2) $\Psi_n=8(K/H)^{H/2}D_n/\sqrt n+4\sqrt{\ln(1/\delta')/(2n)}$ | ../research-notes/B-tempered-likelihood.md Lemma 5.3(a), Lemma 5.2 | Matches: $2\gamma$ with $\gamma=4$; McDiarmid with range $b=4$; Massart with $R=\sqrt n$ and $\lvert\mathcal D_S\rvert\le(n+1)^{d+1}$; peeling $+\frac1{2\sqrt n}$ per layer. |
| (I3) $2Le^{-NK/16}$, $D_T=4\cdot3^{L-1}$, $D_H=4+16(L-2)3^{L-2}$ | `meanfield.tex` Prop. `mf-cover`, eq. `T`, finite realization, counting | Bound and $c=\min\{\frac14,\frac m{16}\}=\frac1{16}$ match. I evaluated the degrees exactly from the source formulas (§4.3 below). |
| Lemma 2.4 vs. `paper.tex` Lemma `spectral` | `paper.tex` l. 542–583 | Same form: $b\propto a/K^{(H-1)/2}$, $N^{\gamma-1}\gtrsim b^{-2}$; ../research-notes/E-finite-prior-scale.md's constants are $7/b$ against the paper's $16/(\sqrt m\,b)$. |
| (I4) cube lemmas | ../research-notes/A-tight-conditioning-fails.md Lemmas 2.2(b), 4.1(a)(c), 4.2(b), 4.3; eq. (2.4); Cor. 4.6 | Match as used. Lemma 4.2(b) needs closeness only on $\mathcal S$, which is all that Theorem 5.2(ii) supplies. |
| slt-likelihood normaliser $e^{-N^\gamma(A+1/2)}$ with $\rho=n^{-1/2}$ | `slt-likelihood/README.md` §2 "Finite scales" | Matches. |

---

## 3. Step-by-step audit (constants and exponents)

### 3.1 Section 1

- **(1.2) and Lemma 1.1.** $(\sqrt d/\tau)^2=dN^{\gamma-1}=N^\gamma\frac dN$, $(\sqrt N/\tau)^2=N^\gamma$ and $(N/\tau)^2=N^{\gamma+1}$; symbolic residuals are $0$. The normalising constant $(N^\gamma/2\pi)^{P_N/2}(\det\Gamma_N)^{1/2}$ is correct, and so is $\Lambda_N=N^\gamma n/(2c)=N^\gamma n^\theta/2$.
- **(1.1), (1.3).** $\lVert v\rVert_1\le\sqrt N\lVert v\rVert_2=\sqrt{\kappa^{(L)}}$. The clipped loss is 4-Lipschitz because $\lvert\operatorname{clip}u+\operatorname{clip}u'-2y\rvert\le4$.
- **(G1).** $\mathbb Ee^{Y/4}=2^{P/2}$ and $\frac{\ln2}6=0.1155<\frac18$. Exact $\chi^2$ tails confirm $\log\Pr(\chi^2_P>u)\le-u/8$ for all $P\in\{1,\dots,10^4\}$ and $u\in[3P,30P]$. The true rate at $u=3P$ is $0.4507>0.375$.
- **(G2)–(G5).** Standard results, stated correctly. (G4) $1-\Phi(t)\le\frac12e^{-t^2/2}$ is checked on $[0,40]$, with equality at $t=0$. (G3) tails were checked by simulation (§4.6).

### 3.2 Section 2

- **Lemma 2.1.**
  - (a): Minkowski gives $\hat L_S(z_w)\le\hat L_S(g)+2\rho(U+1)+\rho^2$.
  - (b): the exponent is exactly $-N^\gamma\ln\frac{64}\varepsilon$ (symbolic residual $0$).
  - (c): $(U+1)^2+2\rho(U+1)+\rho^2=(U+1+\rho)^2\le(U+2)^2$ for $\rho\le1$.
- **Lemma 2.2 (PAC-Bayes).**
  - Hoeffding's lemma: each term ranges over $4\Lambda/n$, so $n\cdot\frac{(4\Lambda/n)^2}8=\frac{2\Lambda^2}n$.
  - The Gibbs identity, $\mathbb E_\Pi\hat L'_S<\infty$ via $te^{-\Lambda t}\le(e\Lambda)^{-1}$, and the substitution $\frac{N^\gamma A+\ln(1/\delta')}\Lambda+\frac{2\Lambda}n=2n^{-\theta}(A+\frac{\ln(1/\delta')}{N^\gamma})+N^\gamma n^{\theta-1}$ are all correct (symbolic residual $0$).
  - For general $c$ the two extra terms are $\frac{2cA}n+\frac{N^\gamma}c$; this matters for E1.
  - A toy one-parameter Gibbs posterior with 400 samples per setting gave violation frequency $0$, against the allowed $\delta'$.
- **Lemma 2.3.**
  - (a): $K'/8-A-\frac{n^\theta}2(U+2)^2\ge\ln\frac{64}\varepsilon$.
  - (b): bad mass $\le\varepsilon/32$ times loss $4$ gives $\varepsilon/8$.
  - $3P_N/N^\gamma=3(d+2)N^{1-\gamma}+3(H-1)N^{2-\gamma}$, so the three bullets are correct. "Only while" in the third bullet should be "while" (§5.2, I-2).
- **Lemma 2.4.**
  - Step 1: $N^\gamma K\ge NK\ge3N(d+1)$.
  - Step 2: $\Pr(\lVert Z\rVert_{\rm op}\le2\sqrt N+\sqrt{2\ln2})\ge\frac12$, and $3.5\sqrt N\ge2\sqrt N+\sqrt{2\ln2}$ iff $\sqrt N\ge0.785$, so every $N\ge1$ works.
  - Step 3: $s_j>b\Rightarrow s_j\le2(s_j-b/2)$; with Mirsky, $\lVert(\sigma Z)_{>b}\rVert_F^2\le4\sigma^2{\rm dist}_F(Z,\mathcal B)^2$, and (G4) gives $\frac12e^{-N^\gamma K/8}$.
  - Union bound: $2+\frac{H-1}2\le L$.
  - Energy: at most $LK$.
  - Recursion: $e_\ell\le\sqrt Ke_{\ell-1}+b$ gives output error $\le b(H-1)K^{(H-1)/2}=a/2$, valid on all of $\mathbb R^d$ because the first layer is unchanged.
- **Lemma 2.5.** $7/b=896(H-1)K^{(H-1)/2}/\varepsilon$ (symbolic residual $0$; $896=14\cdot64$). $L\cdot\frac{\varepsilon}{64L}=\frac\varepsilon{64}$, and $4a=\varepsilon/16$.
- **Lemma 2.6.** $K/16\ge A+\frac{n^\theta}2(U+2)^2+\ln\frac{128L}\varepsilon$ gives $2L\cdot\frac{\varepsilon}{128L}=\frac\varepsilon{64}$. Hoeffding with range $4$ gives $t=\sqrt{8\ln(\lvert\mathcal C\rvert\cdot4/\delta)/n}=4\sqrt{\cdot/(2n)}$, and $8a=\varepsilon/8$.
- **Theorem 2.7, arithmetic (exact rationals).**
  - Regime T: $\frac18+(\frac14+\frac1{256})+\frac14+\frac1{16}+\frac18=\frac{209}{256}=0.8164<0.82$.
  - Regime E: $0.7539$. Regime S: $0.7539<0.76$. Regime MF: $0.7539<0.76$.
  - $\sum_N\frac{\delta}{4N^2}=\frac{\pi^2}{24}\delta=0.4112\delta$; total failure $0.9112\delta<\delta$.
  - $2\ln N\le N$ for $N\ge1$; the minimum of $N-2\ln N$ is $0.614$, at $N=2$.
  - Remark 2.9(b) good-parameter bounds: E $0.629\varepsilon$, T $0.691\varepsilon$, MF $0.629\varepsilon$, all $<0.7\varepsilon$.
- **Theorem 2.7, polynomial conditions and exponents.**
  - Case I: $n^{\theta H/2}n^{e/2}/\sqrt n=n^{-e/2}$ and $n^{\theta H/2}/\sqrt n=n^{-e}$ with $e=\frac{1-\theta H}2$. The two displayed thresholds follow by splitting $\varepsilon/8$ into two halves of $\varepsilon/16$.
  - $\ln(n+1)\le n^e/e$ on $n\ge1$: the derivative $n^{e-1}-\frac1{n+1}$ is positive.
  - Route (i): $e_{\rm i}=\frac{1-\theta}\gamma-\frac{\theta(H-1)}{\gamma-1}=\frac{\gamma-1-\theta(\gamma H-1)}{\gamma(\gamma-1)}$ (symbolic residual $0$).
  - Route (ii): $\theta'=\theta\max\{1,\frac{(H-1)(2-\gamma)}{\gamma-1}\}$, and it reaches $1/H$ iff $\gamma\ge2-\frac1H$ (sympy).
  - Crossover of the two routes: sympy returns $\gamma\in\{1,\ 2-\frac2H+\frac1{H^2}\}$.
  - Case III: $\theta<\min\{\frac1{D_T+1},\frac1{D_H}\}=\frac1{D_H}$.
  - A bisection over $\theta$, using only the exponent signs of the proof's sufficient conditions, reproduces $\theta_{L,\gamma}$ to $10^{-16}$ on a grid of 110 pairs $(H,\gamma)$ (`check_degrees_theta.out`).
- **Remark 2.8.** The optimum of $\min\{\theta,\frac{1-\theta H}2\}$ is at $\theta=\frac1{H+2}$ (sympy). Each term has the stated order; $A_L(n^{-\theta})$ contributes only a $\log n$.

### 3.3 Section 3 (Lemma 3.1)

- $t_L=\sqrt{2\ln(2L)}$ gives failure $\frac1{2L}$ for each of the $L$ conditions, so $\gamma_P(E)\ge\frac12$.
- $e_1\le2\tau\sqrt{(d+1)/d}\le2\sqrt2\tau$, and $e_\ell\le\sqrt{K_0}e_{\ell-1}+3\tau$.
- Output error $\le\tau[2\sqrt2K_0^{H/2}+3\sum_{j=1}^{H-1}K_0^{j/2}+2]\le(3H+2)K_0^{H/2}\tau$, with slack $3-2\sqrt2=0.17$.
- A Monte Carlo with adversarially aligned centres (rank-one internal layers at full energy, linear-regime first layer; $H\in\{2,3,4\}$, $N\in\{100,400\}$, $\gamma\in\{1.2,2\}$) gave $\Pr(E)\ge0.99$ and $\max\text{dev}/\text{bound}\le0.023$.

### 3.4 Section 4

- **Lemma 4.1.**
  - The derivative identities are symbolically exact, with $\sup\lvert\cdot\rvert=2$ attained at $\tanh^2=0$.
  - Adaptive quadrature gives $\max\lvert\varpi'\rvert=1.0000$ at $q=0$, and $\varpi-(1+2q)^{-1/2}\ge0$.
  - Over $u\in[-6,6]$ and $q\in[0,1]$: $\max\lvert\psi_q(u)-\varpi(q)u\rvert/(\lvert u\rvert^3/3)=0.99996$ and $\max\lvert\Upsilon-F\rvert/u^2=0.99993$.
  - $\varpi(1)=0.605706$, $F(1)=0.394294$, and $\Pi_*(1,H)=0.6057,\ 0.4625,\ 0.3854,\ 0.3361,\ 0.3013$ for $H=2,\dots,6$. All match ../research-notes/E-finite-prior-scale.md.
- **Lemma 4.2.**
  - $1-\phi(\alpha)\le2e^{-2\alpha+2\tau^2\tau_d^2}\le2e^{4-2\alpha}\le(2\sqrt{2d})^{-1}$.
  - $\mathbb E e^{2\sigma\lvert G\rvert}\le2e^{2\sigma^2}$, so $\mathbb E\,{\rm sech}^2\le8e^{4-2\alpha}$.
  - $\lvert c^\phi_k\rvert\ge(2k)^{-1/2}-(2\sqrt{2d})^{-1}\ge(2\sqrt{2k})^{-1}$.
  - Quadrature at the worst noise level $\tau^2\tau_d^2=2$ (with $\tau_d^2=(d+1)/d$) and $\alpha=2+\alpha_d$, for $d\in\{1,2,3,5,10,30,100\}$: $\min_k\lvert c^\phi_k\rvert2\sqrt{2k}\ge1.859$ (claim $\ge1$), and both saturation bounds hold with room.
- **Lemma 4.3.**
  - The four-term decomposition sums to $u_{\ell+1}-\tilde u_{\ell+1}$.
  - The a-priori size $\lvert u_j\rvert\le2\bar SR^{-(H+1-j)}$ uses $\Xi\le1\le\bar S$.
  - $f_j\le\varphi+(j-1)(u_0+4\bar S^2/R^2)$, and the telescoped bound $E_{\ell+1}\le2R^{H-1}u_0+2(H-1)\bar S\bar f+\frac{16\bar S^3}{3R^2}$ hold. For $R\ge2$, $\sum_{j\ge1}R^{-2j}=\frac1{R^2-1}\le\frac4{3R^2}$, below the claimed $\le\frac2{R^2}$.
  - Differential evolution over all admissible perturbation sequences (46 parameter sets with $\Xi\le1$; $H\in\{2,3,4\}$, $\tau\in\{1,0.5\}$) gave a worst ratio $\lvert R\bar h^H-\Pi_*S\rvert/\Xi=0.253$. The author's random and one-signed search gave $0.447$ on a different grid. Both are $\le1$.
- **Proposition 4.4.**
  - Hoeffding exponents: sampling $m a^2/(128\mathcal A^2)$; $E_S$: $a^2N/(256\mathcal A^2)$; $E_1$: $Na^2/(512H^2\bar S^2)$; $E_m$: $Nu_0^2/2$; $E_q$: $2Nu_0^2$; $E_{\rm out}$: $Na^2/128$. Each exponent equals the stated one (symbolic residual $0$).
  - $2^{d+1}e^{-\ell_d}=\frac1{8H}$; there are $2H$ events, so failure is at most $\frac14$.
  - The choice of $\alpha$ gives $8e^{4-2\alpha}=\frac a{32H\bar S}$ exactly at the boundary.
  - Energy: $\sum_jc_j^2\le\frac{2\mathcal A^2}N$ and $\frac{2\mathcal A^2}{R^{2H-2}}\le2R^2$, so the total is at most $d(d+1)\alpha^2+(H+1)R^2$.
  - Five-term $\Xi$ bound: $\frac a8+\frac a8+\frac a{16}+\frac a{16}+\frac a{24H^2}$, which is $\le\frac{37}{96}a=0.385a$ for $H\ge2$ (see E2). Output error $\le0.765a$.
- **Proposition 4.4, in-situ simulation.** I simulated the exact finite-width law on the $d=6$ cube; script and limits are in §4.5. It finds:
  - every measured deviation is below its Hoeffding scale $\sqrt{2\ell_d/N}$;
  - wherever the observed $\Xi\le1$, the chain error is at most $\Xi$ (7 of 7 cases);
  - $\max\lvert z-r\rvert$ decreases with $N$ in every configuration.

### 3.5 Section 5

- **Lemma 5.1.**
  - Numerator over denominator: $e^{-\frac{N^\gamma}{2c}(R_V+cK+2ct)}\big/\bigl(\frac12e^{-N^\gamma K/2-\frac{N^\gamma}{2c}R_V}\bigr)=2e^{-N^\gamma t}$.
  - $\mathbb E_\mu\kappa^{(L)}=N\cdot N\cdot N^{-\gamma-1}=N^{1-\gamma}\le1$.
- **Theorem 5.2.**
  - $B_t=\{\Delta>na^2+c(K+2t)\}=\{\Delta>\eta n\}$, and $\eta n/M=\lambda\eta=\epsilon_{\rm fs}$.
  - $Q/M\ge\beta_n-\sqrt{2\lambda\ln(1/\delta)/M}$ on $\mathcal E_\delta$.
  - $\lvert\mathbb E_\Pi z_w-m\rvert\le(1-p)\lvert m\rvert+\mathbb E_\Pi[\sqrt{\kappa^{(L)}}\mathbf 1_{B_t}]\le2e^{-N^\gamma t}(2+\sqrt{\eta n})$ on $\mathcal S$; ../research-notes/A-tight-conditioning-fails.md Lemma 4.2(b) needs closeness only there.
  - $\lvert\mathbb E_\Pi\operatorname{clip}z_w-m^{\rm cl}\rvert\le2(1-p)$.
- **Corollary 5.3.**
  - $\ln(1/a_d)\le\frac d3\ln2$ gives $\alpha=O(d)$; $d(d+1)\alpha^2\approx d^4(\ln2)^2/36$.
  - $\mathcal A_{\max}^{2/H}=3^{(H-1)/H}(8ds_0)^{1/H}\le3(8dn_d)^{1/H}$.
  - $c_d/(a_d2^d)=c_d\max\{c_d,1\}^{-1/3}2^{-2d/3}\le\max\{c_d,1\}^{2/3}2^{-2d/3}$.
  - The deviation term is $\sqrt{2\lambda_d}\,2^{-d/4}$, and $N_*\ge256\mathcal A_{\max}^2\ell_d/a_d^2\ge s_0$.
  - $\beta(1)=0.484829$, $\lambda^*=1.50286$, $\beta(\lambda^*)=0.517351$, and the first-order condition $\beta(\lambda^*)=(1-e^{-\lambda^*})/\lambda^*$ holds to $10^{-7}$.
- **Corollary 5.4.** With $c=n^{1-\theta}$, $\theta>\frac1H$ and $n=2^d$: $d^{1/H}2^{d(1/H-\theta)}\to0$ and $d^42^{-d\theta}\to0$, so (5.1) holds; and $a_d=2^{-d\theta/3}\le1$.
- **§5.4 variants (a), (b).** $R_V=na^2$ when $W=0$; $Q=n$ gives $1+\frac nM(1-\sqrt\eta)_+^2$; $\mathcal E_\eta$ uses McDiarmid with differences $8$, giving $e^{-u^2/(32n)}$. All match ../research-notes/A-tight-conditioning-fails.md Prop. 6.1 and Cor. 4.6.

### 3.6 Section 7 (numerical claims)

- All nine `E_scripts` reproduce their recorded `.out` files byte for byte (`verify_E_computation_scripts/rerun/`).
- Every number quoted in §7 matches the corresponding output.
- Table 7.1 reproduces from my independent implementation (§4.4).

---

## 4. Independent numerical evidence (my scripts)

All are in `../checks/verify-E-computation/`, each with a `.out` file.

### 4.1 `check_algebra.py` (sympy)

Symbolic residuals of every algebraic identity listed in §3 are $0$, and every rational sum is computed exactly. It also outputs the general-$c$ PAC-Bayes extra term $\frac{2Ac}n+\frac{N^\gamma}c$ used in E1, and the fifth $\Xi$ term $\frac a{24H^2}$ used in E2.

### 4.2 `check_gauss_consts.py`

Covers (G1), (G4), Lemma 4.1, Lemma 4.2, $\Pi_*$ and $\varpi$, using adaptive quadrature rather than the author's Gauss–Hermite rule. All checks pass.

### 4.3 `check_degrees_theta.py`

Evaluates `meanfield.tex` exactly in log space with mpmath, at $K=10^8$ and $10^{12}$, $a=0.01$, $d=10$.

| $L$ | slope of $T_L$ | claim $D_T$ | slope of $P$ | slope of $H^{\rm mf}_L$ | claim $D_H$ | $\theta_{L,1}$ |
|---|---|---|---|---|---|---|
| 3 | 36.000 | 36 | 52.07 | 52.11 | 52 | $1/52=0.0192$ |
| 4 | 108.000 | 108 | 292.08 | 292.11 | 292 | $1/292=0.00342$ |
| 5 | 324.000 | 324 | 1300.08 | 1300.11 | 1300 | $1/1300=0.00077$ |

The excess over the integer degree comes from logarithms, as ../research-notes/E-finite-prior-scale.md says.

### 4.4 `check_table71.py`

Exact binomial $\beta_n$, computed with a stable log-pmf, and $a$ optimised by grid search followed by Brent's method.

| $H$ | $d$ | $e$ ($\lambda=1$), mine / ../research-notes/E-finite-prior-scale.md | $e$ ($\lambda=1.5$), mine / ../research-notes/E-finite-prior-scale.md | $K_{\rm rob}/n$, mine / ../research-notes/E-finite-prior-scale.md | $\log_{10}N_*$, mine / ../research-notes/E-finite-prior-scale.md |
|---|---|---|---|---|---|
| 2 | 30 | 0.4172 / 0.417 | 0.4472 / 0.447 | $2.51\cdot10^{-3}$ / $2.5\cdot10^{-3}$ | 20.4 / 20 |
| 2 | 40 | 0.4718 / 0.472 | 0.5039 / 0.504 | $8.88\cdot10^{-5}$ / $8.9\cdot10^{-5}$ | 26.7 / 27 |
| 2 | 60 | 0.4844 / 0.4844 | 0.5169 / 0.5169 | $1.06\cdot10^{-7}$ / $1.1\cdot10^{-7}$ | 39.0 / 39 |
| 3 | 30 | 0.3885 / 0.389 | 0.4111 / 0.411 | $3.56\cdot10^{-3}$ / $3.6\cdot10^{-3}$ | 18.9 / 19 |
| 3 | 40 | 0.4748 / 0.475 | 0.5063 / 0.506 | $3.47\cdot10^{-5}$ / $3.5\cdot10^{-5}$ | 24.2 / 24 |
| 3 | 60 | 0.4847 / 0.4847 | 0.5172 / 0.5172 | $3.35\cdot10^{-9}$ / $3.4\cdot10^{-9}$ | 34.5 / 35 |

The author's script uses the conservative lower bound $\beta(\lambda)-n/M^2$ for $\beta_n$. The exact $\beta_n$ exceeds it by at most $2n/M^2\le3\cdot10^{-9}$ at $d\ge30$.

### 4.5 `check_memoriser_insitu.py`

Exact-law simulation of the robust memoriser on the $d=6$ cube with $n=64$ random labels. Given $h^{\ell-1}$ on the 64 cube points, the layer-$\ell$ noise rows are i.i.d. $\mathcal N(0,\tau^2G/N)$, with $G$ the Gram matrix of $h^{\ell-1}$. They are sampled by Cholesky decomposition in chunks, which reaches $N=10^7$. Neuron allocation is deterministic, as in `robust_memorizer_det.py`.

| $H$ | $\gamma$ | $R$ | $N$ | $\max_x\lvert\bar h^\ell-\psi\rvert$ | $\sqrt{2\ell_d/N}$ | chain error | $\Xi$ (observed) | $\max\lvert z-r\rvert$ |
|---|---|---|---|---|---|---|---|---|
| 2 | 1 | 5 | $10^4$ / $10^5$ / $10^6$ | $1.4\cdot10^{-2}$ / $6.2\cdot10^{-3}$ / $1.8\cdot10^{-3}$ | $3.9\cdot10^{-2}$ / $1.2\cdot10^{-2}$ / $3.9\cdot10^{-3}$ | 0.071 / 0.036 / 0.016 | $>1$ | 0.078 / 0.036 / 0.017 |
| 2 | 1 | 40 | $10^5$ / $10^6$ / $10^7$ | $6.2\cdot10^{-3}$ / $1.8\cdot10^{-3}$ / $4.0\cdot10^{-4}$ | $1.2\cdot10^{-2}$ / $3.9\cdot10^{-3}$ / $1.2\cdot10^{-3}$ | 0.247 / 0.074 / 0.016 | 0.690 / 0.285 / 0.150 | 0.247 / 0.074 / 0.016 |
| 3 | 1 | 4 | $10^4$ / $10^5$ / $10^6$ | $1.4\cdot10^{-2}$ / $6.2\cdot10^{-3}$ / $1.8\cdot10^{-3}$ | $4.0\cdot10^{-2}$ / $1.3\cdot10^{-2}$ / $4.0\cdot10^{-3}$ | 0.197 / 0.084 / 0.035 | $>1$ | 0.202 / 0.084 / 0.035 |
| 2 | 1.25 | 40 | $10^5$ / $10^6$ | $2.3\cdot10^{-3}$ / $4.9\cdot10^{-4}$ | $1.2\cdot10^{-2}$ / $3.9\cdot10^{-3}$ | 0.093 / 0.020 | 0.234 / 0.070 | 0.093 / 0.020 |
| 3 | 2 | 30 | $10^5$ / $10^6$ | $3.3\cdot10^{-5}$ / $2.8\cdot10^{-6}$ | $1.3\cdot10^{-2}$ / $4.0\cdot10^{-3}$ | 0.030 / 0.003 | 0.146 / 0.092 | 0.030 / 0.003 |

- All five configurations converge, including mean field at $H=3$.
- With $H=3$, $R=30$, $N=10^6$ the error is $1.27$. This is expected, not a counterexample: the amplification $R^{H-1}u_0$ needs $N\gtrsim R^{2H-2}\ell_d/a^2$, which is the role of $2\ell_d/u_0^2$ in $N_*$. At $N=10^7$ the error falls to $0.28$.

### 4.6 `check_mc_misc.py`

- Lemma 3.1 with aligned centres: the ratio is at most $0.023$.
- (G3) tails: all empirical frequencies are below $e^{-t^2/2}$.
- Toy PAC-Bayes check of Lemma 2.2: zero violations in 3×400 runs.

### 4.7 `check_chain_adversarial.py`

Lemma 4.3 under differential evolution: worst ratio $0.253$.

---

## 5. Issues

### 5.1 Errors (minor; no theorem affected)

**E1. The $c=1$ remark after Corollary 5.4 uses the wrong $\theta$.**

- *Location:* ../research-notes/E-finite-prior-scale.md §5.3, the paragraph after the proof of Corollary 5.4 (line 579): "At $c=1$ the PAC-Bayes bound of Lemma 2.2 is vacuous ($\theta=0$ gives an additive $2A$)."
- *Problem:* Throughout §2, $c=n^{1-\theta}$, so $c=1$ means $\theta=1$; $\theta=0$ is $c=n$. For general $c$, Lemma 2.2's extra terms are $\frac{2cA}n+\frac{N^\gamma}c$ (`check_algebra.out`).
  - At $c=1$ these are $\frac{2A}n+N^\gamma$. The $A$-term is small. The bound is vacuous because of the variance term $N^\gamma n^{\theta-1}=N^\gamma\ge1$, which already exceeds the counterexample's excess $\beta(\lambda)\approx0.48$.
  - The quoted "additive $2A$" is the situation at $c=n$.
- The conclusion (vacuous at $c=1$) is right; the stated reason is wrong.
- *Fix:* replace the parenthesis by "($\theta=1$; the variance term $N^\gamma n^{\theta-1}=N^\gamma\ge1$ exceeds the excess to be certified)".

**E2. The justification of the fifth $\Xi$ term in Proposition 4.4 says $H^2\ge1$; it needs $H^2\ge4$.**

- *Location:* Proposition 4.4, Step 6, "Size of $\Xi$" (line 502): "… $R^2\ge\frac{128H^2\bar S^3}a$, and the same with $H^2\ge1$."
- *Problem:* With $R^2\ge128H^2\bar S^3/a$, the fifth term satisfies $\frac{16\bar S^3}{3R^2}\le\frac a{24H^2}$.
  - The displayed $\frac a{96}$ requires $H^2\ge4$.
  - With only $H^2\ge1$ the five terms sum to $0.4167a$, and the displayed "$<0.39a$" would be false. The final $\lvert z_w-r\rvert\le0.79a<a$ would still hold.
  - Since the proposition assumes $H\ge2$, the displayed bound is correct; only the justification is mis-stated.
- *Fix:* "…and the same with $H^2\ge4$ (as $H\ge2$)".

### 5.2 Imprecisions and slack (presentational; listed because the lens asks for all of them)

- **I-1. Slack in (C1) and (C2) (Theorem 2.7, line 251).**
  - (C1) gives $h_n\le\varepsilon/32$, not just $\varepsilon/8$, and $4\sqrt{\ln(4/\delta)/(2n)}\le\varepsilon/(8(U+1)^2)$.
  - (C2) gives $2n^{-\theta}(A+\ln\frac4\delta+1)\le\varepsilon/8$, not just $\varepsilon/4$.
  - The stated weaker forms are true. Using the sharper ones would tighten the regime totals (e.g. regime S to $0.54\varepsilon$), but nothing depends on it.
- **I-2. "Only while" (§2.3, line 179).** "For $1\le\gamma<2$ it holds only while $3(H-1)N^{2-\gamma}\le K'-3(d+2)$." This is a sufficient condition, not a necessary one, because $N^{1-\gamma}<1$ for $N>1$. Read "while".
- **I-3. $A_L$ comparison (§3, Consequences, first bullet, line 351).** "From $\frac12E_*+O(d+m)\ln\frac1\rho$" omits the part of $A_L$ that does not depend on $\rho$. This is $[d+2+(L-2)m]\ln(\frac{16}3P_0)+1+\ln2$, with $\ln P_0=\Theta(L\ln(mB)+\ln d)$. Write $\frac12E_*+O_L\bigl((d+m)(\ln\frac1\rho+\ln(dmB))\bigr)$.
- **I-4. Missing width hypothesis.** §0 row 4 (line 16) and §3 Consequences, first bullet (line 351) omit Lemma 3.1's hypothesis $N\ge(\sqrt{d+1}+t_L)^2$. The logic referee reports the same.
- **I-5. Hidden $a$-dependence in "Sizes".** The "Sizes" line of Proposition 4.4 gives $N_*=O_H(d^2s/a^2+dR^{2H-2}/a^2)$, which is correct but hides $a$ inside $R$. Explicitly, $N_*=O_H\bigl(d^2s/a^2+d(ds)^{(H-1)/H}/a^2+d\,a^{-(H+1)}\bigr)$.
- **I-6. Selective reporting in §7 item 4 (lines 636–650).**
  - The table comes only from `robust_memorizer_det.py`.
  - `robust_memorizer.py`, which samples features as the proof does, shows noiseless sampling error $0.73$–$1.52$ and noisy errors $0.42$–$0.84$ at the widths used ($m\le2000\ll m_{\rm f}$). This is not reported.
  - It is no evidence against the proposition, because those widths are far below $N_*$. The text should say which script the table comes from and why the sampled version is not shown. The logic referee reports the same.
- **I-7. Stale numbering in script docstrings.** `bounds_table_fs.py` cites "Theorem 6.1" and "Proposition 5.1"; `check_truncation.py` cites "Lemma 3.5"; `theta_table.py` cites "Theorem 3.1"; `robust_memorizer.py` cites "Section 6"; `check_lemmaT.py` cites "Lemma T". These should become Theorem 5.2, Proposition 4.4, Lemma 2.4, Theorem 2.7, Section 4 and Lemma 3.1.
- **I-8. Discontinuity of the proven threshold at $\gamma=1$ (Theorem 2.7, §6).** I confirm the logic referee's observation numerically. The $\gamma>1$ formula tends to $0$ as $\gamma\downarrow1$, while $\theta_{L,1}=1/D_H>0$. For $H=2$ the $\gamma>1$ value is below $1/52$ on $1<\gamma<1.02$. This is not an arithmetic error, but the §6 table should note it.
- **I-9. Conservative $D_T$ at $\gamma=1$ (observation).**
  - For Gaussian coordinates the Lindeberg comparison in `meanfield.tex` is trivial ($Z_\nu$ and $Z_G$ have the same law). The thresholds $4G_1^2$ and $c_\nu^2P_3(G_1)^2$ in eq. `T` are then not needed, and $\deg_KT_L$ could be $4\cdot3^{L-2}-1$ (plus logs) rather than $4\cdot3^{L-1}$.
  - ../research-notes/E-finite-prior-scale.md uses the source's formula as stated, which is conservative and correct.
  - Since $\theta_{L,1}$ is set by $D_H>D_T+1$, nothing changes.
- **I-10. Rounding in Table 7.1.** $\log_{10}N_*=34.5$ at $(H,d)=(3,60)$ is printed as $35$. This is harmless.

### 5.3 Checked and found correct (claims a reader might doubt)

- (G1) holds for every $P\ge1$, including $P=1$, where the bound is very loose.
- Lemma 2.4's union constant $2+\frac{H-1}2\le L$.
- $N\ge1$ suffices for $3.5\sqrt N\ge2\sqrt N+\sqrt{2\ln2}$.
- The constant $896$.
- Lemma 3.1's $3H+2$.
- $2^{d+1}e^{-\ell_d}=\frac1{8H}$.
- The $2H$ event count.
- The $\alpha$ choice making $8e^{4-2\alpha}=\frac a{32H\bar S}$.
- $\Pi_*\ge3^{-(H-1)/2}$ for all $\tau\in(0,1]$ ($q^*_\ell\in[0,1]$).
- $1/\phi(\alpha)<2\sqrt{2d}$.
- The energy $d(d+1)\alpha^2+(H+1)R^2$, including $H=2$, where there are no $W^\ell$ with $\ell\ge3$.
- The posterior-mean terms $\varsigma_N$.
- $\beta(1)$, $\lambda^*$, $\beta(\lambda^*)$.
- The route crossover $\gamma=2-\frac2H+\frac1{H^2}$.
- The thresholds $\theta_{L,\gamma}$, including the values at $\gamma=1.5$ (0.5, 0.1667, 0.1), and the red-team comparison (0.25, 0.125, 0.0833).

---

## 6. Scope of this check

- I re-derived the imported results (I1) and (I2) as far as their constants are used. I spot-checked ../research-notes/B-tempered-likelihood.md's Rademacher constants, the clip-mixture mass $\tanh^2r+{\rm sech}^2r=1$, and the peeling increment $\frac1{2\sqrt n}$.
- For (I3) I checked the statement, the failure constant $c=\frac1{16}$, and the degrees in $K$. I did not re-prove the mean-field cover. As ../research-notes/E-finite-prior-scale.md states, the $\gamma=1$, $L\ge3$ case of Theorem 2.7 is conditional on it.
- My numerical checks are sanity checks at sizes far below the theorems' thresholds (e.g. $N_*\sim10^{20}$–$10^{39}$). They test the mechanisms and constants, not the asymptotic statements themselves.
